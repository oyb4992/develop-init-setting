local M = {}
local log = hs.logger.new('FileOrganizer', 'info')

M.watchers = {}

-- 파일 존재 여부 확인 헬퍼 함수
local function fileExists(path)
    local attr = hs.fs.attributes(path)
    if attr then
        return true
    else
        return false
    end
end

-- 디렉토리 생성 확인 헬퍼 (mkdir -p)
local function ensureDirectory(path)
    if not fileExists(path) then
        -- hs.fs.mkdir는 재귀적 생성을 지원하지 않으므로 시스템 명령어를 사용합니다.
        os.execute("mkdir -p '" .. path .. "'")
    end
end

-- 파일 확장자 추출 헬퍼
local function getExtension(filename)
    return filename:match("^.+(%..+)$")
end

-- 파일 이동 함수
local function moveFile(file, sourcePath, destinationPath)
    local filename = file:match("^.+/(.+)$")
    local ext = getExtension(filename) or ""
    local name = filename:sub(1, #filename - #ext)

    local targetFile = destinationPath .. "/" .. filename

    -- 파일명이 중복될 경우 타임스탬프를 추가하여 덮어쓰기 방지
    if fileExists(targetFile) then
        local timestamp = os.date("%Y%m%d_%H%M%S")
        targetFile = destinationPath .. "/" .. name .. "_" .. timestamp .. ext
    end

    local success, err = os.rename(file, targetFile)
    if success then
        log.i(string.format("이동 완료: %s -> %s", filename, targetFile))
        hs.notify.new({
            title = "파일 정리기",
            informativeText = filename .. " 파일을 이동했습니다."
        }):send()
    else
        log.e(string.format("이동 실패 %s: %s", filename, err))
    end
end

-- 규칙에 따라 디렉토리 내 파일 처리
local function processFiles(files, rules)
    for _, file in ipairs(files) do
        -- 파일이 존재하는지 확인 (이미 이동되었거나 삭제되었을 수 있음)
        if fileExists(file) then
            local filename = file:match("^.+/(.+)$")
            -- 숨김 파일 (.으로 시작)은 무시
            if filename and not filename:match("^%.") then
                -- 파일 속성 가져오기 (생성일자 등)
                local attr = hs.fs.attributes(file)

                for _, rule in ipairs(rules) do
                    if rule.predicate(file, filename, attr) then
                        local dest = rule.destination

                        -- destination이 함수일 경우 실행하여 동적 경로 생성 (날짜별 분류 등)
                        if type(dest) == "function" then
                            dest = dest(file, filename, attr)
                        end

                        if dest then
                            ensureDirectory(dest) -- 대상 디렉토리가 없으면 생성
                            moveFile(file, file:match("^(.+)/.+"), dest)
                        end
                        break -- 첫 번째로 매칭된 규칙만 적용하고 종료
                    end
                end
            end
        end
    end
end

-- 디렉토리 내 기존 파일 스캔 헬퍼 (배치 처리 포함)
-- 수천 개의 파일이 있을 때 UI 멈춤(Freezing) 현상을 방지합니다.
local function scanDirectory(path, rules)
    log.i("기존 파일 스캔 중: " .. path)
    local files = {}

    -- 1. 모든 파일 목록 수집 (디렉토리 순회는 빠름)
    for file in hs.fs.dir(path) do
        if file ~= "." and file ~= ".." then
            table.insert(files, path .. "/" .. file)
        end
    end

    if #files == 0 then
        return
    end

    -- 2. 배치 단위로 처리
    local BATCH_SIZE = 50
    local BATCH_DELAY = 0.1 -- 초 단위
    local totalFiles = #files

    log.i(string.format("파일 %d개 발견. 배치 처리를 시작합니다...", totalFiles))

    local function processBatch(startIndex)
        local endIndex = math.min(startIndex + BATCH_SIZE - 1, totalFiles)
        local batchFiles = {}

        for i = startIndex, endIndex do
            table.insert(batchFiles, files[i])
        end

        processFiles(batchFiles, rules)

        if endIndex < totalFiles then
            -- 다음 배치 예약
            hs.timer.doAfter(BATCH_DELAY, function()
                processBatch(endIndex + 1)
            end)
        else
            log.i("초기 스캔 완료: " .. path)
        end
    end

    -- 실행 시작
    processBatch(1)
end

-- 특정 디렉토리를 규칙에 따라 감시 시작
function M.watch(path, rules)
    -- 경로 정규화 (홈 디렉토리 확장)
    path = path:gsub("~", os.getenv("HOME"))

    if not fileExists(path) then
        log.w("경로가 존재하지 않습니다: " .. path)
        return
    end

    -- 기존 파일 초기 스캔 수행
    scanDirectory(path, rules)

    log.i("감시 시작: " .. path)

    local watcher = hs.pathwatcher.new(path, function(files, flagTables)
        -- 관련 이벤트 필터링 (생성, 이름 변경, 수정)
        -- 이 기본 버전에서는 단순함을 위해 변경된 모든 파일 중 존재하는 파일을 확인합니다.
        processFiles(files, rules)
    end)

    watcher:start()
    table.insert(M.watchers, watcher)
end

-- 사용 예시 / 기본 규칙 시작
function M.start()
    local home = os.getenv("HOME")

    -- 카카오톡 사진 저장 기본 경로
    local kakaoPhotoDir = home .. "/Pictures/KakaoTalk"

    -- 규칙 정의 영역
    local downloadsRules = { -- 규칙 1: 카카오톡 사진을 '년-월' 폴더로 자동 분류하여 이동
    {
        predicate = function(filepath, filename)
            -- 파일명이 "KakaoTalk_Photo_"로 시작하고 이미지 확장자인 경우
            local lowerName = filename:lower()
            return lowerName:match("^kakaotalk_photo_") and
                       (lowerName:match("%.jpg$") or lowerName:match("%.jpeg$") or lowerName:match("%.png$"))
        end,
        destination = function(filepath, filename, attr)
            -- 파일 생성일자(creation)를 기준으로 년-월 폴더 경로 생성
            -- attr.creation은 1970년 1월 1일 이후의 초 단위 시간입니다.
            local timestamp = attr.creation or os.time()
            local dateFolder = os.date("%Y-%m", timestamp) -- 예: 2024-01

            return kakaoPhotoDir .. "/" .. dateFolder
        end
    }, -- 규칙 2: 일반 이미지 파일 (Pictures/YYYY/MM)
    {
        predicate = function(filepath, filename)
            local lowerName = filename:lower()
            local imageExts = {
                [".jpg"] = true,
                [".jpeg"] = true,
                [".png"] = true,
                [".gif"] = true,
                [".bmp"] = true,
                [".tiff"] = true,
                [".webp"] = true,
                [".svg"] = true,
                [".heic"] = true,
                [".raw"] = true
            }
            local ext = filename:match("^.+(%..+)$")
            return ext and imageExts[ext:lower()]
        end,
        destination = function(filepath, filename, attr)
            local timestamp = attr.creation or os.time()
            return home .. "/Pictures/" .. os.date("%Y/%m", timestamp)
        end
    }, -- 규칙 3: 문서 파일 (Documents/확장자/YYYY/MM)
    {
        predicate = function(filepath, filename)
            local lowerName = filename:lower()
            local docExts = {
                [".pdf"] = true,
                [".doc"] = true,
                [".docx"] = true,
                [".xls"] = true,
                [".xlsx"] = true,
                [".ppt"] = true,
                [".pptx"] = true,
                [".txt"] = true,
                [".md"] = true,
                [".hwp"] = true,
                [".csv"] = true,
                [".pages"] = true,
                [".numbers"] = true,
                [".key"] = true
            }
            local ext = filename:match("^.+(%..+)$")
            return ext and docExts[ext:lower()]
        end,
        destination = function(filepath, filename, attr)
            local timestamp = attr.creation or os.time()
            local ext = filename:match("^.+(%..+)$"):sub(2):upper() -- 점(.) 제외하고 대문자로 변환
            return home .. "/Documents/" .. ext .. "/" .. os.date("%Y/%m", timestamp)
        end
    }}

    -- Downloads 폴더 감시 시작
    M.watch(home .. "/Downloads", downloadsRules)

    log.i("파일 정리기(File Organizer)가 시작되었습니다.")
end

-- 모든 감시자 중지
function M.stop()
    for _, watcher in ipairs(M.watchers) do
        watcher:stop()
    end
    M.watchers = {}
    log.i("파일 정리기(File Organizer)가 중지되었습니다.")
end

return M
