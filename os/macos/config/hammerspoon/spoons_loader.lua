-- ========================================
-- Spoons 플러그인 로딩
-- ========================================
local spoonsLoader = {}

-- Spoon 로딩 안전하게 처리
local function loadSpoon(spoonName)
    local success, result = pcall(hs.loadSpoon, spoonName)
    if success then
        print("✅ " .. spoonName .. " 로드 성공")
        return true
    else
        print("⚠️ " .. spoonName .. " 로드 실패: " .. tostring(result))
        return false
    end
end

-- 모든 Spoon 로드
local function loadAllSpoons()
    -- SpoonInstall 먼저 로드 (필수)
    if loadSpoon("SpoonInstall") then
        -- SpoonInstall 설정 (자동 설치 활성화)
        spoon.SpoonInstall.use_syncinstall = true

        -- 리포지토리 정보 업데이트 (최신 상태 유지)
        spoon.SpoonInstall:updateAllRepos()

        -- ReloadConfiguration.spoon
        spoon.SpoonInstall:andUse("ReloadConfiguration")

        -- KSheet (단축키 치트시트)
        spoon.SpoonInstall:andUse("KSheet")

        -- HSKeybindings (Hammerspoon 단축키 표시)
        -- 해당 spoon의 init.lua의 정렬 로직 추가 (msg 기준 오름차순) -> 그룹핑 효과
        -- table.sort(allKeys, function(a, b)
        --     local msgA = a.msg or ""
        --     local msgB = b.msg or ""
        --     return msgA < msgB
        -- end)
        spoon.SpoonInstall:andUse("HSKeybindings")

        -- PopupTranslateSelection (선택 텍스트 번역)
        -- 오류 발생시 해당 spoon의 init.lua의 url 변수 확인 : local url = "http://translate.google.co.kr/?" ..
        spoon.SpoonInstall:andUse("PopupTranslateSelection")
    end
end

-- Export functions
spoonsLoader.loadAllSpoons = loadAllSpoons
spoonsLoader.loadSpoon = loadSpoon

return spoonsLoader
