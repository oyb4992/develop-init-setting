-- Hammerspoon 전원 관리 및 시스템 자동화 설정
-- 전원 상태 기반 카페인 자동화 및 BTT 관리에 집중
print("Hammerspoon 전원 관리 시스템 로드 중...")

-- ========================================
-- 설정 상수 및 캐싱 시스템
-- ========================================

-- 설정 상수들
local CONFIG = {
    DELAYS = {
        BTT_START_DELAY = 2, -- 2초
        SYSTEM_WAKE_DELAY = 3, -- 3초
        LID_STATE_DELAY = 1 -- 1초
    },
    BTT = {
        APP_NAME = "BetterTouchTool",
        BUNDLE_ID = "com.hegenberg.BetterTouchTool"
    },
    UI = {
        CANVAS_WIDTH = 500,
        CANVAS_HEIGHT_MAX = 400,
        CANVAS_Y_POSITION = 0.2, -- 화면 상단에서 20%
        STATUS_DISPLAY_TIME = 3, -- 3초
        TEXT_SIZE = 12,
        PADDING = 20
    }
}

-- ========================================
-- 전원 상태 기반 카페인 자동화 & BTT 자동화
-- ========================================

local currentPowerState = "unknown"
local powerWatcher = nil
local screenWatcher = nil
local caffeineWatcher = nil
local wifiWatcher = nil
local isLidClosed = false
local currentSSID = nil

-- BTT 상태 변수들

-- 전원 상태 확인
local function isOnBatteryPower()
    local success, result = pcall(hs.battery.powerSource)
    return success and result == "Battery Power"
end

local function getCurrentPowerMode()
    return isOnBatteryPower() and "battery" or "power"
end

-- BTT 관리 함수들 (다중 방식 감지 및 제어)
local function isBTTRunning()
    -- 방법 1: Bundle ID로 찾기
    local bttApp = hs.application.find(CONFIG.BTT.BUNDLE_ID)
    if bttApp and bttApp:isRunning() then
        return true
    end

    -- 방법 2: 앱 이름으로 찾기
    local bttApp2 = hs.application.find(CONFIG.BTT.APP_NAME)
    if bttApp2 and bttApp2:isRunning() then
        return true
    end

    -- 방법 3: 실행 중인 앱 목록에서 직접 찾기
    local runningApps = hs.application.runningApplications()
    for _, app in ipairs(runningApps) do
        local bundleID = app:bundleID()
        if bundleID == CONFIG.BTT.BUNDLE_ID then
            return true
        end
    end

    -- 방법 4: ps 명령어로 프로세스 확인 (fallback)
    local output, success = hs.execute("ps aux | grep -i bettertouchtool | grep -v grep")
    if success and output and output:find("BetterTouchTool") then
        return true
    end

    return false
end

local function startBTT()
    if not isBTTRunning() then
        local success = hs.application.launchOrFocus(CONFIG.BTT.BUNDLE_ID)
        if success then
            hs.alert.show("🎮 BTT 실행됨", 2)
        else
            -- Bundle ID로 실패시 앱 이름으로 시도
            local success2 = hs.application.launchOrFocus(CONFIG.BTT.APP_NAME)
            if success2 then
                hs.alert.show("🎮 BTT 실행됨", 2)
            else
                hs.alert.show("❌ BTT 실행 실패", 3)
            end
        end
    end
end

local function stopBTT()
    local bttApp = hs.application.find(CONFIG.BTT.BUNDLE_ID)
    if bttApp and bttApp:isRunning() then
        bttApp:kill()
        hs.alert.show("🎮 BTT 종료됨", 2)
    end
end

-- 화면(모니터) 상태 확인 함수들
local function getScreenCount()
    return #hs.screen.allScreens()
end

local function hasBuiltinScreen()
    local screens = hs.screen.allScreens()
    for _, screen in ipairs(screens) do
        -- 내장 화면은 보통 이름에 "Built-in"이 포함되거나 특정 해상도를 가짐
        local name = screen:name() or ""
        if name:match("Built%-in") or name:match("Color LCD") or name:match("Liquid Retina") then
            return true
        end
    end
    return false
end

-- 카페인 상태 직접 제어
local function setCaffeineState(enabled, reason)
    local currentState = hs.caffeinate.get("displayIdle")

    if enabled and not currentState then
        -- 카페인 활성화 (디스플레이가 꺼지지 않도록)
        hs.caffeinate.set("displayIdle", true)
        hs.alert.show("☕ 카페인 활성화: " .. reason, 3)
    elseif not enabled and currentState then
        -- 카페인 비활성화
        hs.caffeinate.set("displayIdle", false)
        hs.alert.show("😴 카페인 비활성화: " .. reason, 3)
    end
    -- 이미 원하는 상태라면 아무것도 하지 않음
end

-- 현재 카페인 상태 확인
local function isCaffeineActive()
    return hs.caffeinate.get("displayIdle")
end

-- MacBook 뚜껑 상태 감지 및 자동 제어 (BTT + 카페인)
local function handleLidStateChange()
    local screenCount = getScreenCount()
    local hasBuiltin = hasBuiltinScreen()
    local newLidState = not hasBuiltin -- 내장 화면이 없으면 뚜껑이 닫힌 것으로 판단

    -- 외장 모니터만 있는 경우 (Clamshell 모드)를 추가로 감지
    if screenCount == 1 and not hasBuiltin then
        newLidState = true
    elseif screenCount >= 1 and hasBuiltin then
        newLidState = false
    end

    if isLidClosed ~= newLidState then
        isLidClosed = newLidState
        local powerMode = getCurrentPowerMode()

        if isLidClosed then
            -- 뚜껑 닫힘
            if powerMode == "battery" then
                -- 배터리 모드: BTT 종료, 카페인 OFF
                stopBTT()
                setCaffeineState(false, "배터리 모드 + 뚜껑 닫힘")
            else
                -- 전원 연결: BTT 유지, 카페인 ON 유지
                -- 아무것도 하지 않음 (현재 상태 유지)
            end
        else
            -- 뚜껑 열림
            if powerMode == "battery" then
                -- 배터리 모드: BTT 실행, 카페인 OFF
                hs.timer.doAfter(CONFIG.DELAYS.BTT_START_DELAY, startBTT)
                setCaffeineState(false, "배터리 모드")
            else
                -- 전원 연결: BTT 실행, 카페인 ON
                hs.timer.doAfter(CONFIG.DELAYS.BTT_START_DELAY, startBTT)
                hs.timer.doAfter(CONFIG.DELAYS.SYSTEM_WAKE_DELAY, function()
                    setCaffeineState(true, "전원 연결됨")
                end)
            end
        end
    end
end

-- 시스템 잠들기/깨어나기 감지
local function handleSystemStateChange(eventType)
    if eventType == hs.caffeinate.watcher.systemWillSleep then
        -- 시스템이 잠들 때
        local powerMode = getCurrentPowerMode()
        isLidClosed = true

        if powerMode == "battery" then
            -- 배터리 모드: BTT 종료, 카페인 OFF
            stopBTT()
            setCaffeineState(false, "배터리 모드 + 시스템 잠들기")
        else
            -- 전원 연결: BTT는 종료하지만 카페인은 유지
            -- (시스템이 잠들 때는 전원 연결이어도 BTT 종료가 합리적)
            stopBTT()
        end
    elseif eventType == hs.caffeinate.watcher.systemDidWake then
        -- 시스템이 깨어날 때
        hs.timer.doAfter(CONFIG.DELAYS.SYSTEM_WAKE_DELAY, function()
            local powerMode = getCurrentPowerMode()

            if hasBuiltinScreen() then
                isLidClosed = false
                -- BTT는 항상 실행
                startBTT()

                if powerMode == "power" then
                    -- 전원 연결: 카페인 ON
                    hs.timer.doAfter(CONFIG.DELAYS.LID_STATE_DELAY, function()
                        setCaffeineState(true, "시스템 깨어남 + 전원 연결됨")
                    end)
                else
                    -- 배터리 모드: 카페인 OFF
                    setCaffeineState(false, "시스템 깨어남 + 배터리 모드")
                end
            end
        end)
    end
end

-- BTT 수동 토글
local function toggleBTT()
    if isBTTRunning() then
        stopBTT()
    else
        startBTT()
    end
end

-- 전원 상태 변경 처리
local function handlePowerStateChange(newMode)
    if currentPowerState == newMode then
        return
    end

    currentPowerState = newMode

    if newMode == "battery" then
        setCaffeineState(false, "배터리 모드")
    else
        setCaffeineState(true, "전원 연결됨")
    end
end

-- 카페인 수동 토글
local function toggleCaffeine()
    local currentState = isCaffeineActive()
    setCaffeineState(not currentState, "수동 토글")
end



-- 시스템 상태 정보 수집 (전원, 화면, BTT, 카페인)
local function getSystemInfo()
    return {
        powerMode = getCurrentPowerMode(),
        batteryLevel = hs.battery.percentage(),
        caffeineState = isCaffeineActive(),
        bttRunning = isBTTRunning(),
        screenCount = getScreenCount(),
        hasBuiltin = hasBuiltinScreen()
    }
end

-- 시스템 상태 정보 포맷팅 (블루투스/와이파이 제외)
local function formatSystemStatus(info)
    local status = {"🖥️ 시스템 통합 상태", "", "🔋 전원: " ..
        (info.powerMode == "battery" and "배터리 (" .. math.floor(info.batteryLevel) .. "%)" or "연결됨"),
                    "☕ 카페인: " .. (info.caffeineState and "✅ 활성화" or "❌ 비활성화"),
                    "🎮 BTT: " .. (info.bttRunning and "✅ 실행 중" or "❌ 종료됨"), "",
                    "🖥️ 화면 개수: " .. info.screenCount,
                    "💻 내장 화면: " .. (info.hasBuiltin and "✅ 활성화" or "❌ 비활성화"),
                    "📱 뚜껑 상태: " .. (isLidClosed and "🔒 닫힌 상태" or "🔓 열린 상태")}
    return status
end

-- 시스템 자동화 규칙 설명 (주요 동작 방식)
local function addAutomationRules(status)
    local rules = {"", "💡 자동화 규칙:", "🔌 전원 연결 시:",
                   "   • 뚜껑 열림/닫힘 → 카페인 ON, BTT 실행", "🔋 배터리 모드 시:",
                   "   • 뚜껑 열림 → 카페인 OFF, BTT 실행",
                   "   • 뚜껑 닫힘 → 카페인 OFF, BTT 종료", "📶 백그라운드 자동화:",
                   "   • 와이파이 변경 → 블루투스 자동 제어"}

    for _, rule in ipairs(rules) do
        table.insert(status, rule)
    end
    return status
end

-- 상태 표시 성능 향상을 위한 캐시 시스템
local systemStatusCache = {
    info = nil,
    lastUpdate = 0,
    cacheDuration = 3 -- 3초간 캐시 유효
}

-- Canvas를 이용한 상태 창 표시 (멀티 모니터 지원)
-- 상태 창 표시용 Canvas 객체 (전역 변수)
local statusCanvas = nil

local function showStatusWithCanvas(statusLines)
    -- 기존 창이 있으면 닫기
    if statusCanvas then
        statusCanvas:delete()
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

    -- 디버깅용: 화면 정보 출력 (필요시 활성화)
    -- local screenName = screen:name() or "Unknown"
    -- print("🖥️ 상태창 표시 화면: " .. screenName .. " (출처: " .. screenSource .. ")")

    local screenFrame = screen:frame()

    -- 창 크기와 위치 계산 (CONFIG 값 사용)
    local windowWidth = CONFIG.UI.CANVAS_WIDTH
    local windowHeight = math.min(CONFIG.UI.CANVAS_HEIGHT_MAX, #statusLines * 20 + CONFIG.UI.PADDING * 2)
    local x = (screenFrame.w - windowWidth) / 2
    local y = screenFrame.h * CONFIG.UI.CANVAS_Y_POSITION

    -- Canvas 생성 (화면 좌표계를 고려한 절대 좌표 사용)
    local absoluteX = screenFrame.x + x
    local absoluteY = screenFrame.y + y

    statusCanvas = hs.canvas.new {
        x = absoluteX,
        y = absoluteY,
        w = windowWidth,
        h = windowHeight
    }

    -- 디버깅용: Canvas 위치 정보 (필요시 활성화)
    -- print("📍 Canvas 위치 - 화면: " .. (screen:name() or "Unknown") .. " | Canvas: " .. absoluteX .. "," .. absoluteY)

    -- 배경
    statusCanvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = {
            alpha = 0.9,
            red = 0.1,
            green = 0.1,
            blue = 0.1
        },
        roundedRectRadii = {
            xRadius = 10,
            yRadius = 10
        }
    }

    -- 텍스트 추가
    statusCanvas[2] = {
        type = "text",
        text = table.concat(statusLines, "\n"),
        textFont = "SF Mono",
        textSize = CONFIG.UI.TEXT_SIZE,
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
    statusCanvas:show()

    -- CONFIG에 설정된 시간 후 자동으로 닫기
    hs.timer.doAfter(CONFIG.UI.STATUS_DISPLAY_TIME, function()
        if statusCanvas then
            statusCanvas:delete()
            statusCanvas = nil
        end
    end)
end

-- 시스템 통합 상태 표시 (캐시 기반 성능 최적화)
local function showSystemStatus()
    local now = os.time()
    local info

    -- 캐시된 정보가 유효한지 확인
    if systemStatusCache.info and (now - systemStatusCache.lastUpdate) < systemStatusCache.cacheDuration then
        info = systemStatusCache.info
    else
        -- 새로운 정보 수집
        info = getSystemInfo()
        systemStatusCache.info = info
        systemStatusCache.lastUpdate = now
    end

    local status = formatSystemStatus(info)
    status = addAutomationRules(status)

    -- Canvas 기반 창 표시 (위치 조정됨)
    showStatusWithCanvas(status)
end

-- ========================================
-- Spoons 플러그인 로딩
-- ========================================

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

-- FnMate (Fn키 토글)
loadSpoon("FnMate")

-- KSheet (단축키 치트시트)
loadSpoon("KSheet")

-- HSKeybindings (Hammerspoon 단축키 표시)
loadSpoon("HSKeybindings")

-- ========================================
-- 단축키 정의
-- ========================================


-- ========================================
-- BTT & 카페인 관련 단축키
-- ========================================

-- BTT 수동 토글
hs.hotkey.bind({"cmd", "ctrl"}, "b", "BetterTouchTool 실행/종료 토글", toggleBTT)

-- 통합 상태 확인 (BTT + 카페인 + 시스템)
hs.hotkey.bind({"cmd", "ctrl", "alt"}, "s", "시스템 상태 확인 (전원, 카페인, BTT, 화면 등)",
    showSystemStatus)

-- 카페인 수동 토글
hs.hotkey.bind({"cmd", "ctrl", "alt"}, "f", "카페인 활성화/비활성화 토글 (화면 끄기 방지)",
    toggleCaffeine)

-- ========================================
-- Spoon 단축키 설정
-- ========================================

-- KSheet: 단축키 치트시트
hs.hotkey.bind({"cmd", "shift"}, "/", "시스템 전체 단축키 치트시트 표시/숨기기", function()
    if spoon.KSheet then
        spoon.KSheet:toggle()
    else
        hs.alert.show("KSheet Spoon이 로드되지 않았습니다")
    end
end)

-- HSKeybindings: Hammerspoon 단축키 표시
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "/",
    "Hammerspoon 단축키 목록 표시/숨기기 (이 스크립트의 단축키들)", function()
        if spoon.HSKeybindings then
            if spoon.HSKeybindings.sheetView and spoon.HSKeybindings.sheetView:hswindow() and
                spoon.HSKeybindings.sheetView:hswindow():isVisible() then
                spoon.HSKeybindings:hide()
            else
                spoon.HSKeybindings:show()
            end
        else
            hs.alert.show("HSKeybindings Spoon이 로드되지 않았습니다")
        end
    end)

-- ========================================
-- 초기화 및 감지 시작
-- ========================================

-- 전원 상태 변경 감지 시작
powerWatcher = hs.battery.watcher.new(function()
    local newMode = getCurrentPowerMode()
    handlePowerStateChange(newMode)
end)
powerWatcher:start()

-- 화면 변경 감지 시작 (뚜껑 닫힘/열림 감지)
screenWatcher = hs.screen.watcher.new(function()
    hs.timer.doAfter(CONFIG.DELAYS.LID_STATE_DELAY, handleLidStateChange) -- 안정화 대기
end)
screenWatcher:start()

-- 시스템 잠들기/깨어나기 감지 시작
caffeineWatcher = hs.caffeinate.watcher.new(handleSystemStateChange)
caffeineWatcher:start()

-- 초기 상태 설정
hs.timer.doAfter(CONFIG.DELAYS.SYSTEM_WAKE_DELAY, function()
    -- 전원 상태 초기화
    local initialMode = getCurrentPowerMode()
    handlePowerStateChange(initialMode)

    -- 뚜껑 상태 초기화
    handleLidStateChange()
end)

-- 설정 리로드 감지
-- Hammerspoon 설정 파일 변경 감지 및 자동 재로드
function reloadConfig(files)
    doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        -- 리로드 전에 모든 감지 기능 중지
        if powerWatcher then
            powerWatcher:stop()
        end
        if screenWatcher then
            screenWatcher:stop()
        end
        if caffeineWatcher then
            caffeineWatcher:stop()
        end
        if wifiWatcher then
            wifiWatcher:stop()
        end
        hs.reload()
    end
end

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- ========================================
-- 초기화 완료
-- ========================================

print("🚀 Hammerspoon 전원 관리 시스템 설정 완료!")
print("")
print("☕ 카페인 자동화:")
print("- 전원 연결 시 자동 활성화")
print("- 배터리 모드 시 자동 비활성화")
print("- 뚜껑 닫기/시스템 잠들기 시 배터리 보호")
print("- 수동 제어: Cmd+Ctrl+Alt+F")
print("")
print("🎮 BTT 자동화:")
print("- BTT 수동 토글: Cmd+Ctrl+B")
print("- 뚜껑 닫기 → BTT 종료")
print("- 뚜껑 열기 → BTT 실행")
print("- 시스템 잠들기 → BTT 종료")
print("- 시스템 깨어나기 → BTT 실행")
print("")
print("🧩 Spoon 플러그인:")
print("- 단축키 치트시트: Cmd+Shift+/")
print("- Hammerspoon 단축키 표시: Cmd+Ctrl+Shift+/")
print("")
print("✨ 주요 기능 및 개선사항:")
print("1. 설정 상수 외부화 - CONFIG 테이블로 중앙 관리")
print("2. 성능 최적화 - 상태 캐싱 및 지능적 리소스 관리")
print("3. 함수 모듈화 - 기능별 작은 함수로 분해하여 유지보수성 향상")
print("4. 안전한 명령어 실행 - 에러 처리 및 복구 메커니즘 추가")
print("5. 전원 기반 자동화 - 전원 상태에 따른 시스템 제어")
print("6. 화면 상태 감지 - 뚜껑 닫힘/열림에 따른 자동 제어")
print("7. 멀티 모니터 지원 - 포커스된 화면에 상태창 표시")
print("8. 캐시 시스템 - 성능 향상을 위한 지능적 캐싱")
print("9. 코드 품질 개선 - DRY 원칙 적용, 일관된 네이밍 규칙")
print("10. 사용자 경험 향상 - 직관적 알림 및 상태 피드백")
