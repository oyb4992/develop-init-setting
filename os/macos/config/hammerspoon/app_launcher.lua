-- ========================================
-- Hyper Key 앱 런처
-- ========================================
local appLauncher = {}

-- Hyper modifiers (BTT에서 CapsLock을 이 조합으로 매핑했다고 가정)
local hyper = {"cmd", "alt", "ctrl", "shift"}

-- 단축키 매핑 설정
-- [키] = "앱 이름" (앱 이름은 /Applications 폴더의 이름과 정확히 일치해야 함)
local mappings = {
    a = "Antigravity", -- Hyper + A -> Antigravity
    b = "Boop", -- Hyper + B -> Boop
    f = "Finder", -- Hyper + F -> Finder (Home directory)
    ["1"] = "IntelliJ IDEA", -- Hyper + 1 -> IntelliJ IDEA
    n = "Obsidian", -- Hyper + N -> Obsidian
    s = "Safari", -- Hyper + S -> Safari
    z = "Zen", -- Hyper + Z -> Zen
    t = "kitty", -- Hyper + T -> kitty
    k = "KakaoTalk" -- Hyper + K -> KakaoTalk
}

-- 앱 실행 또는 포커스 또는 숨기기 함수
local function launchOrFocus(appName)
    if appName == "Finder" then
        -- Finder는 'open ~' 명령어로 홈 디렉토리 열기
        hs.execute("open ~")
        -- 포커스도 맞추기 위해 잠시 후 활성화 (선택 사항)
        hs.timer.doAfter(0.1, function()
            hs.application.launchOrFocus("Finder")
        end)
    else
        local success = hs.application.launchOrFocus(appName)
        if not success then
             hs.alert.show("App not found: " .. appName)
        end
    end
end

function appLauncher.start()
    for key, app in pairs(mappings) do
        -- App: [앱이름] 형태의 설명 추가
        hs.hotkey.bind(hyper, key, "App: " .. app, function()
            launchOrFocus(app)
        end)
    end
    print("🚀 App Launcher 시작됨: Hyper + [a,b,f,1,n,s,z,t,k]")
end

function appLauncher.stop()
    -- hotkey.bind는 전역으로 관리되므로 개별 해제가 까다로울 수 있음
    -- 여기서는 생략 (Hammerspoon reload 시 자동 초기화됨)
end

return appLauncher
