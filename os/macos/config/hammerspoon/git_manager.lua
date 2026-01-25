-- ========================================
-- Git 상태 확인 및 관리
-- ========================================
local config = require("config")
local CONFIG = config.CONFIG

local gitManager = {}

-- Git 상태 확인용 Canvas 표시 함수
local gitStatusCanvas = nil

local function showGitStatusCanvas(statusLines, displayTime)
    -- 기존 Git 상태 창이 있으면 닫기
    if gitStatusCanvas then
        gitStatusCanvas:delete()
        gitStatusCanvas = nil
    end

    -- 화면 선택 로직 개선
    local screen = nil
    local screenSource = "main" -- 디버그용

    -- 1. 현재 포커스된 창이 있는 화면 찾기
    local focusedWindow = hs.window.focusedWindow()
    if focusedWindow then
        screen = focusedWindow:screen()
        screenSource = "focused-window"
    end

    -- 2. 포커스된 창이 없으면 마우스 커서가 있는 화면 사용
    if not screen then
        local mousePosition = hs.mouse.absolutePosition()
        local allScreens = hs.screen.allScreens()
        for _, s in ipairs(allScreens) do
            local frame = s:frame()
            if mousePosition.x >= frame.x and mousePosition.x < (frame.x + frame.w) and mousePosition.y >= frame.y and
                mousePosition.y < (frame.y + frame.h) then
                screen = s
                screenSource = "mouse-cursor"
                break
            end
        end
    end

    -- 3. 마지막으로 메인 화면 사용
    if not screen then
        screen = hs.screen.mainScreen()
        screenSource = "main-screen"
    end

    local screenFrame = screen:frame()

    -- 창 크기와 위치 계산
    local windowWidth = math.min(800, screenFrame.w * 0.8)
    local windowHeight = math.min(600, #statusLines * 20 + CONFIG.UI.PADDING * 2)
    local x = (screenFrame.w - windowWidth) / 2
    local y = (screenFrame.h - windowHeight) / 2

    -- Canvas 생성 (화면 좌표계를 고려한 절대 좌표 사용)
    local absoluteX = screenFrame.x + x
    local absoluteY = screenFrame.y + y

    gitStatusCanvas = hs.canvas.new({
        x = absoluteX,
        y = absoluteY,
        w = windowWidth,
        h = windowHeight
    })

    -- 배경
    gitStatusCanvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = {
            alpha = 0.95,
            red = 0.05,
            green = 0.05,
            blue = 0.05
        },
        roundedRectRadii = {
            xRadius = 10,
            yRadius = 10
        }
    }

    -- 텍스트 추가
    gitStatusCanvas[2] = {
        type = "text",
        text = table.concat(statusLines, "\n"),
        textFont = "SF Mono",
        textSize = 13,
        textColor = {
            alpha = 1,
            red = 1,
            green = 1,
            blue = 1
        },
        textAlignment = "left",
        frame = {
            x = CONFIG.UI.PADDING,
            y = CONFIG.UI.PADDING,
            w = windowWidth - (CONFIG.UI.PADDING * 2),
            h = windowHeight - (CONFIG.UI.PADDING * 2)
        }
    }

    -- 창 표시
    gitStatusCanvas:show()

    -- ESC 키 핸들러 등록
    local escHandler
    escHandler = hs.hotkey.bind({}, "escape", function()
        if gitStatusCanvas then
            gitStatusCanvas:delete()
            gitStatusCanvas = nil
            if escHandler then
                escHandler:delete() -- 핸들러 제거
                escHandler = nil
            end
        end
    end)

    -- 지정된 시간 후 자동으로 닫기
    hs.timer.doAfter(displayTime, function()
        if gitStatusCanvas then
            gitStatusCanvas:delete()
            gitStatusCanvas = nil
            if escHandler then
                escHandler:delete() -- 핸들러 제거
            end
        end
    end)
end

-- Git 상태 확인 함수 (여러 경로 지원, 브랜치 정보 포함)
local function checkGitStatus()
    -- 확인할 Git 리포지토리 경로 목록 (사용자 맞춤 설정)
    local gitPaths = {{
        name = "dev-init-setting",
        path = "/Users/oyunbog/IdeaProjects/dev-init-setting"
    }, {
        name = "Obsidian",
        path = "/Users/oyunbog/IdeaProjects/Obsidian"
    }}

    local statusLines = {"📋 Git 상태 종합 보고서", ""}
    local hasChanges = false

    for _, repo in ipairs(gitPaths) do
        local repoPath = repo.path
        local repoName = repo.name

        -- Git 리포지토리인지 확인
        local gitDir = repoPath .. "/.git"
        local attrs = hs.fs.attributes(gitDir)

        if attrs then
            -- 현재 브랜치 확인
            local branchCmd = "cd '" .. repoPath .. "' && git branch --show-current 2>/dev/null"
            local currentBranch = hs.execute(branchCmd):gsub("\n", "")
            if currentBranch == "" then
                currentBranch = "detached HEAD"
            end

            -- Git 상태 확인
            local statusCmd = "cd '" .. repoPath .. "' && git status --porcelain 2>/dev/null"
            local gitOutput = hs.execute(statusCmd)

            -- 문자열 결과 처리
            if gitOutput and gitOutput ~= "" then
                local changes = {}
                local modifiedCount = 0
                local addedCount = 0
                local deletedCount = 0
                local untrackedCount = 0

                for line in gitOutput:gmatch("[^\r\n]+") do
                    local status = line:sub(1, 2)
                    local filename = line:sub(4)

                    if status:match("M") then
                        modifiedCount = modifiedCount + 1
                    elseif status:match("A") then
                        addedCount = addedCount + 1
                    elseif status:match("D") then
                        deletedCount = deletedCount + 1
                    elseif status:match("?") then
                        untrackedCount = untrackedCount + 1
                    end

                    -- 처음 5개 파일만 표시
                    if #changes < 5 then
                        table.insert(changes, "  " .. status .. " " .. filename)
                    end
                end

                hasChanges = true
                table.insert(statusLines, "📁 " .. repoName .. " (브랜치: " .. currentBranch .. ")")

                -- 변경사항 요약
                local summary = {}
                if modifiedCount > 0 then
                    table.insert(summary, modifiedCount .. "개 수정")
                end
                if addedCount > 0 then
                    table.insert(summary, addedCount .. "개 추가")
                end
                if deletedCount > 0 then
                    table.insert(summary, deletedCount .. "개 삭제")
                end
                if untrackedCount > 0 then
                    table.insert(summary, untrackedCount .. "개 미추적")
                end

                table.insert(statusLines, "  ⚠️ 변경사항: " .. table.concat(summary, ", "))

                -- 상세 변경사항 (처음 5개)
                for _, change in ipairs(changes) do
                    table.insert(statusLines, change)
                end

                if #changes >= 5 and (modifiedCount + addedCount + deletedCount + untrackedCount) > 5 then
                    table.insert(statusLines, "  ... 및 " ..
                        ((modifiedCount + addedCount + deletedCount + untrackedCount) - 5) .. "개 추가 변경사항")
                end
            else
                table.insert(statusLines, "✅ " .. repoName .. " (브랜치: " .. currentBranch .. ")")
                table.insert(statusLines, "  깨끗한 상태 - 변경사항 없음")
            end
        else
            table.insert(statusLines, "❌ " .. repoName)
            table.insert(statusLines, "  Git 리포지토리가 아님 또는 접근 불가")
            table.insert(statusLines, "  경로: " .. repoPath)
        end

        table.insert(statusLines, "") -- 빈 줄 추가
    end

    -- 요약 정보 추가
    if hasChanges then
        table.insert(statusLines, "🚨 주의: 커밋하지 않은 변경사항이 있습니다!")
    else
        table.insert(statusLines, "✨ 모든 리포지토리가 깨끗한 상태입니다.")
    end

    table.insert(statusLines, "")
    table.insert(statusLines, "🔑 ESC 키를 눌러 창을 닫을 수 있습니다.")

    -- Canvas로 표시
    showGitStatusCanvas(statusLines, CONFIG.UI.STATUS_DISPLAY_TIME)
end

-- Export functions
gitManager.checkGitStatus = checkGitStatus

return gitManager

