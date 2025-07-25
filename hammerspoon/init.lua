-- Hammerspoon 전원 관리 및 시스템 자동화 설정
-- 전원 상태 기반 카페인 자동화 및 BTT 관리에 집중
-- 개선된 버전: 에러 처리, 성능 최적화, 코드 모듈화 적용
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
        STATUS_DISPLAY_TIME = 10, -- 10초
        TEXT_SIZE = 12,
        PADDING = 20
    },
    DOCKER_COMPOSE = {
        -- todo: Docker Compose 프로젝트 경로 목록 (사용자 맞춤 설정)
        PROJECTS = {{
            name = "개발 환경",
            path = "~/IdeaProjects/kids_snsid_inapp"
        }, {
            name = "웹 프로젝트",
            path = "~/IdeaProjects/kids_snsid_inapp"
        }, {
            name = "마이크로서비스",
            path = "~/IdeaProjects/kids_snsid_inapp"
        }}
    },
    YARN_PROJECTS = {
        -- todo: Yarn 프로젝트 경로 목록 (사용자 맞춤 설정)
        PROJECTS = {{
            name = "React 앱",
            path = "~/IdeaProjects/kids_snsid_inapp",
            scripts = {"dev", "start", "build", "test"}
        }, {
            name = "Node.js 서버",
            path = "~/IdeaProjects/node-server",
            scripts = {"dev", "start", "build", "test", "watch"}
        }, {
            name = "Frontend 프로젝트",
            path = "~/IdeaProjects/frontend-project",
            scripts = {"dev", "start", "build", "test", "storybook"}
        }}
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

-- BTT 상태 변수들

-- ========================================
-- 백그라운드 작업 관리
-- ========================================

-- 백그라운드에서 실행 중인 yarn 작업들을 추적
local runningYarnTasks = {}

-- 상태 표시 성능 향상을 위한 개선된 캐시 시스템
local systemStatusCache = {
    info = nil,
    lastUpdate = 0,
    cacheDuration = 3, -- 3초간 캐시 유효
    -- 추가 캐시 항목들
    btt_running = nil,
    screen_info = nil,
    power_state = nil
}

-- 전원 상태 확인 (개선된 에러 처리)
local function isOnBatteryPower()
    local success, result = pcall(hs.battery.powerSource)
    if not success then
        print("⚠️ 전원 상태 확인 실패: " .. tostring(result))
        return false
    end
    return result == "Battery Power"
end

local function getCurrentPowerMode()
    return isOnBatteryPower() and "battery" or "power"
end

-- BTT 관리 함수들 (개선된 다중 방식 감지 및 에러 처리)
local function isBTTRunning()
    -- 캐시된 결과가 있으면 사용 (성능 최적화)
    local cacheKey = "btt_running"
    local now = os.time()
    if systemStatusCache[cacheKey] and (now - systemStatusCache[cacheKey].timestamp) < 2 then
        return systemStatusCache[cacheKey].value
    end

    local isRunning = false

    -- 방법 1: Bundle ID로 찾기 (가장 신뢰할 수 있는 방법)
    local success, bttApp = pcall(hs.application.find, CONFIG.BTT.BUNDLE_ID)
    if success and bttApp and bttApp:isRunning() then
        isRunning = true
    else
        -- 방법 2: 앱 이름으로 찾기
        success, bttApp = pcall(hs.application.find, CONFIG.BTT.APP_NAME)
        if success and bttApp and bttApp:isRunning() then
            isRunning = true
        else
            -- 방법 3: 실행 중인 앱 목록에서 직접 찾기
            local success2, runningApps = pcall(hs.application.runningApplications)
            if success2 and runningApps then
                for _, app in ipairs(runningApps) do
                    local success3, bundleID = pcall(app.bundleID, app)
                    if success3 and bundleID == CONFIG.BTT.BUNDLE_ID then
                        isRunning = true
                        break
                    end
                end
            end

            -- 방법 4: ps 명령어로 프로세스 확인 (fallback)
            if not isRunning then
                local output, success4 = hs.execute("ps aux | grep -i bettertouchtool | grep -v grep")
                if success4 and output and output:find("BetterTouchTool") then
                    isRunning = true
                end
            end
        end
    end

    -- 결과 캐싱
    systemStatusCache[cacheKey] = {
        value = isRunning,
        timestamp = now
    }

    return isRunning
end

local function startBTT()
    if isBTTRunning() then
        return true -- 이미 실행 중
    end

    -- 첫 번째 시도: Bundle ID로 실행
    local success, result = pcall(hs.application.launchOrFocus, CONFIG.BTT.BUNDLE_ID)
    if success and result then
        hs.alert.show("🎮 BTT 실행됨", 2)
        return true
    end

    -- 두 번째 시도: 앱 이름으로 실행
    success, result = pcall(hs.application.launchOrFocus, CONFIG.BTT.APP_NAME)
    if success and result then
        hs.alert.show("🎮 BTT 실행됨", 2)
        return true
    end

    -- 실행 실패
    print("⚠️ BTT 실행 실패 - Bundle ID: " .. tostring(result))
    hs.alert.show("❌ BTT 실행 실패", 3)
    return false
end

local function stopBTT()
    local success, bttApp = pcall(hs.application.find, CONFIG.BTT.BUNDLE_ID)
    if success and bttApp and bttApp:isRunning() then
        local killSuccess, killResult = pcall(bttApp.kill, bttApp)
        if killSuccess then
            hs.alert.show("🎮 BTT 종료됨", 2)
            return true
        else
            print("⚠️ BTT 종료 실패: " .. tostring(killResult))
            return false
        end
    end
    return true -- 이미 종료된 상태
end

-- 화면(모니터) 상태 확인 함수들 (개선된 에러 처리 및 캐싱)
local function getScreenCount()
    local cacheKey = "screen_count"
    local now = os.time()
    if systemStatusCache[cacheKey] and (now - systemStatusCache[cacheKey].timestamp) < 1 then
        return systemStatusCache[cacheKey].value
    end

    local success, screens = pcall(hs.screen.allScreens)
    local count = success and #screens or 0

    systemStatusCache[cacheKey] = {
        value = count,
        timestamp = now
    }

    return count
end

local function hasBuiltinScreen()
    local cacheKey = "builtin_screen"
    local now = os.time()
    if systemStatusCache[cacheKey] and (now - systemStatusCache[cacheKey].timestamp) < 1 then
        return systemStatusCache[cacheKey].value
    end

    local hasBuiltin = false
    local success, screens = pcall(hs.screen.allScreens)

    if success and screens then
        for _, screen in ipairs(screens) do
            local success2, name = pcall(screen.name, screen)
            name = success2 and name or ""
            if name:match("Built%-in") or name:match("Color LCD") or name:match("Liquid Retina") then
                hasBuiltin = true
                break
            end
        end
    end

    systemStatusCache[cacheKey] = {
        value = hasBuiltin,
        timestamp = now
    }

    return hasBuiltin
end

-- 카페인 상태 직접 제어 (개선된 에러 처리)
local function setCaffeineState(enabled, reason)
    local success, currentState = pcall(hs.caffeinate.get, "displayIdle")
    if not success then
        print("⚠️ 카페인 상태 확인 실패: " .. tostring(currentState))
        return false
    end

    if enabled and not currentState then
        -- 카페인 활성화 (디스플레이가 꺼지지 않도록)
        local setSuccess, setResult = pcall(hs.caffeinate.set, "displayIdle", true)
        if setSuccess then
            hs.alert.show("☕ 카페인 활성화: " .. reason, 3)
            return true
        else
            print("⚠️ 카페인 활성화 실패: " .. tostring(setResult))
            return false
        end
    elseif not enabled and currentState then
        -- 카페인 비활성화
        local setSuccess, setResult = pcall(hs.caffeinate.set, "displayIdle", false)
        if setSuccess then
            hs.alert.show("😴 카페인 비활성화: " .. reason, 3)
            return true
        else
            print("⚠️ 카페인 비활성화 실패: " .. tostring(setResult))
            return false
        end
    end
    -- 이미 원하는 상태라면 아무것도 하지 않음
    return true
end

-- 현재 카페인 상태 확인 (개선된 에러 처리)
local function isCaffeineActive()
    local success, result = pcall(hs.caffeinate.get, "displayIdle")
    if not success then
        print("⚠️ 카페인 상태 확인 실패: " .. tostring(result))
        return false
    end
    return result
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

-- 시스템 상태 정보 수집 (전원, 화면, BTT, 카페인) - 개선된 에러 처리
local function getSystemInfo()
    local info = {
        powerMode = "unknown",
        batteryLevel = 0,
        caffeineState = false,
        bttRunning = false,
        screenCount = 0,
        hasBuiltin = false
    }

    -- 각 정보를 안전하게 수집
    local success, result

    success, result = pcall(getCurrentPowerMode)
    if success then
        info.powerMode = result
    end

    success, result = pcall(hs.battery.percentage)
    if success then
        info.batteryLevel = result
    end

    success, result = pcall(isCaffeineActive)
    if success then
        info.caffeineState = result
    end

    success, result = pcall(isBTTRunning)
    if success then
        info.bttRunning = result
    end

    success, result = pcall(getScreenCount)
    if success then
        info.screenCount = result
    end

    success, result = pcall(hasBuiltinScreen)
    if success then
        info.hasBuiltin = result
    end

    return info
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

    statusCanvas = hs.canvas.new({
        x = absoluteX,
        y = absoluteY,
        w = windowWidth,
        h = windowHeight
    })

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

    -- ESC 키 핸들러 등록
    local escHandler
    escHandler = hs.hotkey.bind({}, "escape", function()
        if statusCanvas then
            statusCanvas:delete()
            statusCanvas = nil
            if escHandler then
                escHandler:delete() -- 핸들러 제거
                escHandler = nil
            end
        end
    end)

    -- CONFIG에 설정된 시간 후 자동으로 닫기
    hs.timer.doAfter(CONFIG.UI.STATUS_DISPLAY_TIME, function()
        if statusCanvas then
            statusCanvas:delete()
            statusCanvas = nil
            if escHandler then
                escHandler:delete() -- 핸들러 제거
            end
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

-- Git 상태 확인용 Canvas 표시 함수
local gitStatusCanvas = nil
local brewUpdateCanvas = nil

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
    }, {
        name = "Current Directory",
        path = hs.fs.currentDir() or os.getenv("PWD") or "."
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

-- Homebrew 업데이트 결과 표시용 Canvas 함수
local function showBrewUpdateCanvas(statusLines, displayTime)
    -- 기존 Homebrew 업데이트 창이 있으면 닫기
    if brewUpdateCanvas then
        brewUpdateCanvas:delete()
        brewUpdateCanvas = nil
    end

    -- 화면 선택 로직 (Git Canvas와 동일)
    local screen = nil
    local focusedWindow = hs.window.focusedWindow()
    if focusedWindow then
        screen = focusedWindow:screen()
    end

    if not screen then
        local mousePosition = hs.mouse.absolutePosition()
        local allScreens = hs.screen.allScreens()
        for _, s in ipairs(allScreens) do
            local frame = s:frame()
            if mousePosition.x >= frame.x and mousePosition.x < (frame.x + frame.w) and mousePosition.y >= frame.y and
                mousePosition.y < (frame.y + frame.h) then
                screen = s
                break
            end
        end
    end

    if not screen then
        screen = hs.screen.mainScreen()
    end

    local screenFrame = screen:frame()

    -- 창 크기와 위치 계산 (더 큰 창으로 설정)
    local windowWidth = math.min(900, screenFrame.w * 0.85)
    local windowHeight = math.min(700, #statusLines * 20 + CONFIG.UI.PADDING * 2)
    local x = (screenFrame.w - windowWidth) / 2
    local y = (screenFrame.h - windowHeight) / 2

    -- Canvas 생성
    local absoluteX = screenFrame.x + x
    local absoluteY = screenFrame.y + y

    brewUpdateCanvas = hs.canvas.new({
        x = absoluteX,
        y = absoluteY,
        w = windowWidth,
        h = windowHeight
    })

    -- 배경
    brewUpdateCanvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = {
            alpha = 0.95,
            red = 0.02,
            green = 0.08,
            blue = 0.02
        },
        roundedRectRadii = {
            xRadius = 10,
            yRadius = 10
        }
    }

    -- 텍스트 추가
    brewUpdateCanvas[2] = {
        type = "text",
        text = table.concat(statusLines, "\n"),
        textFont = "SF Mono",
        textSize = 12,
        textColor = {
            alpha = 1,
            red = 0.9,
            green = 1,
            blue = 0.9
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
    brewUpdateCanvas:show()

    -- ESC 키 핸들러 등록
    local escHandler
    escHandler = hs.hotkey.bind({}, "escape", function()
        if brewUpdateCanvas then
            brewUpdateCanvas:delete()
            brewUpdateCanvas = nil
            if escHandler then
                escHandler:delete()
                escHandler = nil
            end
        end
    end)

    -- 지정된 시간 후 자동으로 닫기
    hs.timer.doAfter(displayTime, function()
        if brewUpdateCanvas then
            brewUpdateCanvas:delete()
            brewUpdateCanvas = nil
            if escHandler then
                escHandler:delete()
            end
        end
    end)
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

-- PopupTranslateSelection (선택 텍스트 번역)
loadSpoon("PopupTranslateSelection")

-- ========================================
-- 단축키 정의
-- ========================================

-- ========================================
-- BTT & 카페인 관련 단축키
-- ========================================

-- 통합 상태 확인 (BTT + 카페인 + 시스템)
hs.hotkey.bind({"cmd", "ctrl", "alt"}, "s", "시스템 상태 확인", showSystemStatus)

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

        -- ESC 키로 KSheet 창 닫기 지원 추가
        if spoon.KSheet.sheetView and spoon.KSheet.sheetView:hswindow() and
            spoon.KSheet.sheetView:hswindow():isVisible() then
            local ksheetEscHandler
            ksheetEscHandler = hs.hotkey.bind({}, "escape", function()
                if spoon.KSheet.sheetView and spoon.KSheet.sheetView:hswindow() and
                    spoon.KSheet.sheetView:hswindow():isVisible() then
                    spoon.KSheet:hide()
                    if ksheetEscHandler then
                        ksheetEscHandler:delete()
                        ksheetEscHandler = nil
                    end
                end
            end)
        end
    else
        hs.alert.show("KSheet Spoon이 로드되지 않았습니다")
    end
end)

-- HSKeybindings: Hammerspoon 단축키 표시
hs.hotkey.bind({"ctrl", "shift"}, "/", "Hammerspoon 단축키 목록 표시/숨기기", function()
    if spoon.HSKeybindings then
        if spoon.HSKeybindings.sheetView and spoon.HSKeybindings.sheetView:hswindow() and
            spoon.HSKeybindings.sheetView:hswindow():isVisible() then
            spoon.HSKeybindings:hide()
        else
            spoon.HSKeybindings:show()

            -- ESC 키로 HSKeybindings 창 닫기 지원 추가
            if spoon.HSKeybindings.sheetView and spoon.HSKeybindings.sheetView:hswindow() and
                spoon.HSKeybindings.sheetView:hswindow():isVisible() then
                local hsKeybindingsEscHandler
                hsKeybindingsEscHandler = hs.hotkey.bind({}, "escape", function()
                    if spoon.HSKeybindings.sheetView and spoon.HSKeybindings.sheetView:hswindow() and
                        spoon.HSKeybindings.sheetView:hswindow():isVisible() then
                        spoon.HSKeybindings:hide()
                        if hsKeybindingsEscHandler then
                            hsKeybindingsEscHandler:delete()
                            hsKeybindingsEscHandler = nil
                        end
                    end
                end)
            end
        end
    else
        hs.alert.show("HSKeybindings Spoon이 로드되지 않았습니다")
    end
end)

-- ========================================
-- 새로운 Spoon 단축키 설정
-- ========================================

-- PopupTranslateSelection: 선택된 텍스트 번역
hs.hotkey.bind({"cmd", "ctrl"}, "t", "선택된 텍스트 번역", function()
    if spoon.PopupTranslateSelection then
        spoon.PopupTranslateSelection:translateSelectionPopup()
    else
        hs.alert.show("PopupTranslateSelection Spoon이 로드되지 않았습니다")
    end
end)

-- ========================================
-- DevCommander 개발자 명령어 실행기 (자체 구현)
-- ========================================

-- DevCommander: 개발자 명령어 실행기
hs.hotkey.bind({"cmd", "ctrl", "alt"}, "c", "개발자 명령어 실행기", function()
    -- 개발자 명령어 정의
    local choices = {{
        text = "Homebrew 업데이트",
        subText = "brew update && brew upgrade"
    }, {
        text = "Git 상태 확인",
        subText = "현재 디렉토리의 Git 변경사항 확인"
    }, {
        text = "Docker Compose 시작",
        subText = "특정 경로에서 docker-compose up -d 실행"
    }, {
        text = "Docker Compose 중지",
        subText = "특정 경로에서 docker-compose stop 실행"
    }, {
        text = "Yarn 백그라운드 실행",
        subText = "특정 프로젝트에서 yarn run 스크립트를 백그라운드로 실행"
    }, {
        text = "Yarn 백그라운드 종료",
        subText = "백그라운드에서 실행 중인 yarn 작업 종료"
    }, {
        text = "Brew 서비스 시작",
        subText = "특정 brew service 시작"
    }, {
        text = "Brew 서비스 종료",
        subText = "특정 brew service 종료"
    }, {
        text = "Docker 이미지 정리",
        subText = "사용하지 않는 Docker 이미지 제거"
    }, {
        text = "Node 모듈 캐시 정리",
        subText = "npm cache clean --force"
    }, {
        text = "Dock 재시작",
        subText = "killall Dock - Dock 프로세스 재시작"
    }, {
        text = "화면 즉시 잠금",
        subText = "pmset displaysleepnow"
    }}

    -- 선택기 생성 및 설정
    local chooser = hs.chooser.new(function(selectedItem)
        if not selectedItem then
            return
        end

        local command = selectedItem.text
        if command == "Docker 이미지 정리" then
            hs.alert.show("Docker 이미지 정리 시작...", 2)
            hs.task.new("/opt/homebrew/bin/docker", function(exitCode, stdOut, stdErr)
                if exitCode == 0 then
                    hs.alert.show("✅ Docker 이미지 정리 완료", 3)
                else
                    hs.alert.show("❌ Docker 이미지 정리 실패", 3)
                end
            end, {"image", "prune", "-f"}):start()
        elseif command == "Node 모듈 캐시 정리" then
            hs.alert.show("npm 캐시 정리 시작...", 2)
            hs.task.new("/usr/bin/npm", function(exitCode, stdOut, stdErr)
                if exitCode == 0 then
                    hs.alert.show("✅ npm 캐시 정리 완료", 3)
                else
                    hs.alert.show("❌ npm 캐시 정리 실패", 3)
                end
            end, {"cache", "clean", "--force"}):start()
        elseif command == "Homebrew 업데이트" then
            hs.alert.show("Homebrew 업데이트 시작...", 2)

            -- 먼저 brew update 실행
            hs.task.new("/opt/homebrew/bin/brew", function(updateExitCode, updateStdOut, updateStdErr)
                if updateExitCode == 0 then
                    -- update 성공 후 upgrade 실행하여 실제 업데이트 내역 확인
                    hs.task.new("/opt/homebrew/bin/brew", function(upgradeExitCode, upgradeStdOut, upgradeStdErr)
                        local statusLines = {"🍺 Homebrew 업데이트 결과", ""}

                        if upgradeExitCode == 0 then
                            hs.alert.show("✅ Homebrew 업데이트 완료", 2)

                            -- 업데이트된 패키지가 있는지 확인
                            if upgradeStdOut and upgradeStdOut:len() > 10 then
                                table.insert(statusLines,
                                    "✅ 업데이트 완료! 다음 패키지들이 업데이트되었습니다:")
                                table.insert(statusLines, "")

                                -- 업그레이드 출력 파싱
                                local updatedPackages = {}
                                local lines = {}
                                for line in upgradeStdOut:gmatch("[^\r\n]+") do
                                    table.insert(lines, line)
                                end

                                -- 주요 정보만 추출하여 표시
                                local inUpgradeSection = false
                                for _, line in ipairs(lines) do
                                    if line:match("Upgrading") or line:match("Installing") then
                                        inUpgradeSection = true
                                        local packageInfo = line:gsub("==> ", "📦 ")
                                        table.insert(statusLines, packageInfo)
                                    elseif line:match("^🍺") or line:match("Summary") then
                                        inUpgradeSection = false
                                    elseif inUpgradeSection and line:match("->") then
                                        -- 버전 정보가 있는 라인
                                        table.insert(statusLines, "   " .. line)
                                    elseif line:match("bottles") and line:match("downloaded") then
                                        -- 다운로드 정보
                                        table.insert(statusLines, "📥 " .. line)
                                    elseif line:match("Installed") or line:match("Upgraded") then
                                        -- 설치/업그레이드 완료 정보
                                        table.insert(statusLines, "✅ " .. line)
                                    end
                                end

                                -- 업데이트된 패키지 수 계산
                                local upgradeCount = 0
                                for line in upgradeStdOut:gmatch("[^\r\n]+") do
                                    if line:match("==> Upgrading") then
                                        upgradeCount = upgradeCount + 1
                                    end
                                end

                                if upgradeCount > 0 then
                                    table.insert(statusLines, "")
                                    table.insert(statusLines, "📊 총 " .. upgradeCount ..
                                        "개 패키지가 업데이트되었습니다.")
                                end
                            else
                                table.insert(statusLines, "ℹ️ 이미 모든 패키지가 최신 버전입니다.")
                                table.insert(statusLines, "업데이트할 패키지가 없습니다.")
                            end
                        else
                            hs.alert.show("❌ Homebrew 업데이트 실패", 3)
                            table.insert(statusLines, "❌ 업데이트 실패")
                            table.insert(statusLines, "")

                            if upgradeStdErr and upgradeStdErr:len() > 0 then
                                table.insert(statusLines, "오류 내용:")
                                for line in upgradeStdErr:gmatch("[^\r\n]+") do
                                    table.insert(statusLines, "  " .. line)
                                end
                            end
                        end

                        table.insert(statusLines, "")
                        table.insert(statusLines, "🔑 ESC 키를 눌러 창을 닫을 수 있습니다.")

                        -- Canvas로 결과 표시
                        showBrewUpdateCanvas(statusLines, CONFIG.UI.STATUS_DISPLAY_TIME)
                    end, {"upgrade"}):start()
                else
                    hs.alert.show("❌ Homebrew update 실패", 3)
                end
            end, {"update"}):start()
        elseif command == "Git 상태 확인" then
            checkGitStatus()
        elseif command == "Dock 재시작" then
            hs.execute("killall Dock")
            hs.alert.show("Dock 재시작됨", 2)
        elseif command == "화면 즉시 잠금" then
            hs.execute("pmset displaysleepnow")
        elseif command == "Brew 서비스 시작" then
            -- 사용 가능한 brew 서비스 목록 가져오기
            hs.task.new("/opt/homebrew/bin/brew", function(exitCode, stdOut, stdErr)
                if exitCode == 0 then
                    local services = {}
                    for line in stdOut:gmatch("[^\r\n]+") do
                        local serviceName = line:match("^([%w%-%.]+)")
                        if serviceName and not line:match("^Name") and serviceName ~= "" then
                            table.insert(services, {
                                text = serviceName,
                                subText = "brew services start " .. serviceName
                            })
                        end
                    end

                    if #services > 0 then
                        local serviceChooser = hs.chooser.new(function(selectedService)
                            if selectedService then
                                hs.alert.show("서비스 시작 중: " .. selectedService.text, 2)
                                hs.task.new("/opt/homebrew/bin/brew", function(startExitCode, startStdOut, startStdErr)
                                    if startExitCode == 0 then
                                        hs.alert.show("✅ " .. selectedService.text .. " 시작됨", 3)
                                    else
                                        hs.alert.show("❌ " .. selectedService.text .. " 시작 실패", 3)
                                    end
                                end, {"services", "start", selectedService.text}):start()
                            end
                        end)
                        serviceChooser:choices(services)
                        serviceChooser:placeholderText("시작할 서비스 선택...")
                        serviceChooser:show()
                    else
                        hs.alert.show("사용 가능한 서비스가 없습니다", 3)
                    end
                else
                    hs.alert.show("서비스 목록을 가져올 수 없습니다", 3)
                end
            end, {"services", "list"}):start()
        elseif command == "Brew 서비스 종료" then
            -- 실행 중인 brew 서비스 목록 가져오기
            hs.task.new("/opt/homebrew/bin/brew", function(exitCode, stdOut, stdErr)
                if exitCode == 0 then
                    local runningServices = {}
                    for line in stdOut:gmatch("[^\r\n]+") do
                        local serviceName = line:match("^([%w%-%.]+)%s+started")
                        if serviceName then
                            table.insert(runningServices, {
                                text = serviceName,
                                subText = "brew services stop " .. serviceName
                            })
                        end
                    end

                    if #runningServices > 0 then
                        local serviceChooser = hs.chooser.new(function(selectedService)
                            if selectedService then
                                hs.alert.show("서비스 종료 중: " .. selectedService.text, 2)
                                hs.task.new("/opt/homebrew/bin/brew", function(stopExitCode, stopStdOut, stopStdErr)
                                    if stopExitCode == 0 then
                                        hs.alert.show("✅ " .. selectedService.text .. " 종료됨", 3)
                                    else
                                        hs.alert.show("❌ " .. selectedService.text .. " 종료 실패", 3)
                                    end
                                end, {"services", "stop", selectedService.text}):start()
                            end
                        end)
                        serviceChooser:choices(runningServices)
                        serviceChooser:placeholderText("종료할 서비스 선택...")
                        serviceChooser:show()
                    else
                        hs.alert.show("실행 중인 서비스가 없습니다", 3)
                    end
                else
                    hs.alert.show("서비스 목록을 가져올 수 없습니다", 3)
                end
            end, {"services", "list"}):start()
        elseif command == "Docker Compose 시작" then
            -- Docker Compose 프로젝트 선택 후 시작
            local projects = {}
            for _, project in ipairs(CONFIG.DOCKER_COMPOSE.PROJECTS) do
                -- docker-compose.yml 파일이 존재하는지 확인
                local composeFile = project.path .. "/docker-compose.yml"
                local attrs = hs.fs.attributes(composeFile)
                if attrs then
                    table.insert(projects, {
                        text = project.name,
                        subText = "docker-compose up -d in " .. project.path,
                        path = project.path
                    })
                end
            end

            if #projects > 0 then
                local projectChooser = hs.chooser.new(function(selectedProject)
                    if selectedProject then
                        hs.alert.show("Docker Compose 시작 중: " .. selectedProject.text, 2)

                        -- docker-compose up -d 실행
                        local task = hs.task.new("/opt/homebrew/bin/docker-compose", function(exitCode, stdOut, stdErr)
                            if exitCode == 0 then
                                hs.alert.show("✅ " .. selectedProject.text .. " Docker Compose 시작됨", 3)
                                print("📦 Docker Compose 시작 성공: " .. selectedProject.text)
                                if stdOut and stdOut:len() > 0 then
                                    print("출력: " .. stdOut)
                                end
                            else
                                hs.alert.show("❌ " .. selectedProject.text .. " Docker Compose 시작 실패", 3)
                                print("⚠️ Docker Compose 시작 실패: " .. selectedProject.text)
                                if stdErr and stdErr:len() > 0 then
                                    print("오류: " .. stdErr)
                                end
                            end
                        end, {"up", "-d"})

                        -- 작업 디렉토리 설정
                        task:setWorkingDirectory(selectedProject.path)
                        task:start()
                    end
                end)
                projectChooser:choices(projects)
                projectChooser:placeholderText("시작할 Docker Compose 프로젝트 선택...")
                projectChooser:show()
            else
                hs.alert.show("사용 가능한 Docker Compose 프로젝트가 없습니다", 3)
            end
        elseif command == "Docker Compose 중지" then
            -- Docker Compose 프로젝트 선택 후 중지
            local projects = {}
            for _, project in ipairs(CONFIG.DOCKER_COMPOSE.PROJECTS) do
                -- docker-compose.yml 파일이 존재하는지 확인
                local composeFile = project.path .. "/docker-compose.yml"
                local attrs = hs.fs.attributes(composeFile)
                if attrs then
                    table.insert(projects, {
                        text = project.name,
                        subText = "docker-compose stop in " .. project.path,
                        path = project.path
                    })
                end
            end

            if #projects > 0 then
                local projectChooser = hs.chooser.new(function(selectedProject)
                    if selectedProject then
                        hs.alert.show("Docker Compose 중지 중: " .. selectedProject.text, 2)

                        -- docker-compose stop 실행
                        local task = hs.task.new("/opt/homebrew/bin/docker-compose", function(exitCode, stdOut, stdErr)
                            if exitCode == 0 then
                                hs.alert.show("✅ " .. selectedProject.text .. " Docker Compose 중지됨", 3)
                                print("📦 Docker Compose 중지 성공: " .. selectedProject.text)
                                if stdOut and stdOut:len() > 0 then
                                    print("출력: " .. stdOut)
                                end
                            else
                                hs.alert.show("❌ " .. selectedProject.text .. " Docker Compose 중지 실패", 3)
                                print("⚠️ Docker Compose 중지 실패: " .. selectedProject.text)
                                if stdErr and stdErr:len() > 0 then
                                    print("오류: " .. stdErr)
                                end
                            end
                        end, {"stop"})

                        -- 작업 디렉토리 설정
                        task:setWorkingDirectory(selectedProject.path)
                        task:start()
                    end
                end)
                projectChooser:choices(projects)
                projectChooser:placeholderText("중지할 Docker Compose 프로젝트 선택...")
                projectChooser:show()
            else
                hs.alert.show("사용 가능한 Docker Compose 프로젝트가 없습니다", 3)
            end
        elseif command == "Yarn 백그라운드 실행" then
            -- Yarn 프로젝트 선택 후 스크립트 실행
            local projects = {}
            for _, project in ipairs(CONFIG.YARN_PROJECTS.PROJECTS) do
                -- package.json 파일이 존재하는지 확인
                local expandedPath = project.path:gsub("^~", os.getenv("HOME"))
                local packageFile = expandedPath .. "/package.json"
                local attrs = hs.fs.attributes(packageFile)
                if attrs then
                    table.insert(projects, {
                        text = project.name,
                        subText = "yarn run in " .. project.path,
                        path = expandedPath,
                        scripts = project.scripts
                    })
                end
            end

            if #projects > 0 then
                local projectChooser = hs.chooser.new(function(selectedProject)
                    if selectedProject then
                        -- 스크립트 선택
                        local scriptChoices = {}
                        for _, script in ipairs(selectedProject.scripts) do
                            table.insert(scriptChoices, {
                                text = script,
                                subText = "yarn run " .. script,
                                project = selectedProject,
                                script = script
                            })
                        end

                        local scriptChooser = hs.chooser.new(function(selectedScript)
                            if selectedScript then
                                local taskKey = selectedScript.project.text .. ":" .. selectedScript.script

                                -- 이미 실행 중인지 확인
                                if runningYarnTasks[taskKey] then
                                    hs.alert.show("⚠️ 이미 실행 중: " .. taskKey, 3)
                                    return
                                end

                                hs.alert.show("🚀 Yarn 백그라운드 시작: " .. taskKey, 2)

                                -- yarn run 스크립트를 백그라운드로 실행
                                local task = hs.task.new("/opt/homebrew/bin/yarn", function(exitCode, stdOut, stdErr)
                                    -- 작업 완료 시 추적 목록에서 제거
                                    runningYarnTasks[taskKey] = nil

                                    if exitCode == 0 then
                                        hs.alert.show("✅ " .. taskKey .. " 완료됨", 3)
                                        print("📦 Yarn 작업 완료: " .. taskKey)
                                    else
                                        hs.alert.show("❌ " .. taskKey .. " 종료됨 (코드: " .. exitCode .. ")", 3)
                                        print("⚠️ Yarn 작업 종료: " .. taskKey .. " (종료 코드: " ..
                                                  exitCode .. ")")
                                        if stdErr and stdErr:len() > 0 then
                                            print("오류: " .. stdErr)
                                        end
                                    end
                                end, {"run", selectedScript.script})

                                -- 작업 디렉토리 설정
                                task:setWorkingDirectory(selectedScript.project.path)

                                -- 백그라운드 작업으로 추적
                                runningYarnTasks[taskKey] = {
                                    task = task,
                                    project = selectedScript.project.text,
                                    script = selectedScript.script,
                                    startTime = os.time()
                                }

                                task:start()
                                print("📦 Yarn 백그라운드 시작: " .. taskKey .. " (PID: " .. task:pid() .. ")")
                            end
                        end)
                        scriptChooser:choices(scriptChoices)
                        scriptChooser:placeholderText("실행할 스크립트 선택...")
                        scriptChooser:show()
                    end
                end)
                projectChooser:choices(projects)
                projectChooser:placeholderText("Yarn 프로젝트 선택...")
                projectChooser:show()
            else
                hs.alert.show("사용 가능한 Yarn 프로젝트가 없습니다", 3)
            end
        elseif command == "Yarn 백그라운드 종료" then
            -- 실행 중인 Yarn 작업 목록 표시
            local runningChoices = {}

            for taskKey, taskInfo in pairs(runningYarnTasks) do
                local runTime = os.time() - taskInfo.startTime
                local runTimeStr = string.format("%d분 %d초", math.floor(runTime / 60), runTime % 60)

                table.insert(runningChoices, {
                    text = taskKey,
                    subText = "실행 시간: " .. runTimeStr .. " (PID: " .. taskInfo.task:pid() .. ")",
                    taskKey = taskKey,
                    taskInfo = taskInfo
                })
            end

            if #runningChoices > 0 then
                local taskChooser = hs.chooser.new(function(selectedTask)
                    if selectedTask then
                        local taskInfo = selectedTask.taskInfo
                        local taskKey = selectedTask.taskKey

                        hs.alert.show("⏹️ Yarn 작업 종료 중: " .. taskKey, 2)

                        -- 작업 종료
                        taskInfo.task:terminate()

                        -- 추적 목록에서 제거
                        runningYarnTasks[taskKey] = nil

                        hs.alert.show("✅ " .. taskKey .. " 종료됨", 3)
                        print("📦 Yarn 백그라운드 종료: " .. taskKey)
                    end
                end)
                taskChooser:choices(runningChoices)
                taskChooser:placeholderText("종료할 Yarn 작업 선택...")
                taskChooser:show()
            else
                hs.alert.show("실행 중인 Yarn 작업이 없습니다", 3)
            end
        end
    end)

    chooser:choices(choices)
    chooser:searchSubText(true)
    chooser:placeholderText("개발자 명령어 검색...")
    chooser:show()
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
print("- 뚜껑 닫기 → BTT 종료")
print("- 뚜껑 열기 → BTT 실행")
print("- 시스템 잠들기 → BTT 종료")
print("- 시스템 깨어나기 → BTT 실행")
print("")
print("🧩 Spoon 플러그인 & 개발자 도구:")
print("- 단축키 치트시트: Cmd+Shift+/ (ESC로 닫기)")
print("- Hammerspoon 단축키 표시: Ctrl+Shift+/ (ESC로 닫기)")
print("- 선택 텍스트 번역: Cmd+Ctrl+T")
print("- 개발자 명령어 실행기: Cmd+Ctrl+Alt+C (자체 구현)")
print("")
print("🐳 Docker Compose 관리:")
print("- Docker Compose 시작: 설정된 프로젝트에서 up -d 실행")
print("- Docker Compose 중지: 설정된 프로젝트에서 stop 실행")
print("- 프로젝트 경로는 CONFIG.DOCKER_COMPOSE.PROJECTS에서 설정")
print("")
print("🧶 Yarn 백그라운드 작업 관리:")
print("- Yarn 백그라운드 실행: 설정된 프로젝트에서 yarn run 스크립트를 백그라운드로 실행")
print("- Yarn 백그라운드 종료: 실행 중인 백그라운드 yarn 작업 종료")
print("- 프로젝트 경로는 CONFIG.YARN_PROJECTS.PROJECTS에서 설정")
print("- 실행 시간 및 PID 추적 지원")
