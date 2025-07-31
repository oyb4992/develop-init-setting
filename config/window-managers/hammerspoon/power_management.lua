-- ========================================
-- 전원 상태 기반 카페인 자동화 & BTT 자동화
-- ========================================

local config = require("config")
local CONFIG = config.CONFIG
local systemStatusCache = config.systemStatusCache

local powerManagement = {}

-- 전역 변수들
local currentPowerState = "unknown"
local isLidClosed = false

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

-- Export functions
powerManagement.getCurrentPowerMode = getCurrentPowerMode
powerManagement.isBTTRunning = isBTTRunning
powerManagement.startBTT = startBTT
powerManagement.stopBTT = stopBTT
powerManagement.getScreenCount = getScreenCount
powerManagement.hasBuiltinScreen = hasBuiltinScreen
powerManagement.setCaffeineState = setCaffeineState
powerManagement.isCaffeineActive = isCaffeineActive
powerManagement.handleLidStateChange = handleLidStateChange
powerManagement.handleSystemStateChange = handleSystemStateChange
powerManagement.handlePowerStateChange = handlePowerStateChange
powerManagement.toggleCaffeine = toggleCaffeine
powerManagement.isLidClosed = function() return isLidClosed end

return powerManagement