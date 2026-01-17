-- ========================================
-- 스마트 WiFi 환경 자동화
-- ========================================
local config = require("config")
local CONFIG = config.CONFIG

local wifiAutomator = {}
local wifiWatcher = nil

-- 볼륨 및 Mute 설정 함수
local function setVolume(vol, muted)
    local device = hs.audiodevice.defaultOutputDevice()
    if device then
        device:setVolume(vol)
        device:setMuted(muted)
    end
end

-- WiFi 변경 핸들러
local function handleWifiChange()
    local currentSSID = hs.wifi.currentNetwork()
    local homeSSIDs = CONFIG.WIFI_AUTOMATION.HOME_SSIDS
    local workSSIDs = CONFIG.WIFI_AUTOMATION.WORK_SSIDS
    local actions = CONFIG.WIFI_AUTOMATION.ACTIONS

    local mode = "DEFAULT"
    local action = actions.DEFAULT
    local networkName = currentSSID or "No WiFi"

    -- Home 체크
    for _, ssid in ipairs(homeSSIDs) do
        if currentSSID == ssid then
            mode = "HOME"
            action = actions.HOME
            break
        end
    end

    -- Work 체크 (Home이 아니면)
    if mode == "DEFAULT" then
        for _, ssid in ipairs(workSSIDs) do
            if currentSSID == ssid then
                mode = "WORK"
                action = actions.WORK
                break
            end
        end
    end

    -- 액션 수행
    setVolume(action.volume, action.muted)

    -- 알림 표시
    local icon = "☕"
    local modeName = "외구 (기본)"
    if mode == "HOME" then
        icon = "🏠"
        modeName = "집"
    elseif mode == "WORK" then
        icon = "🏢"
        modeName = "회사"
    end

    print(string.format("📶 WiFi: %s -> %s 모드 전환 (볼륨: %d%%, Mute: %s)", networkName, modeName,
        action.volume, tostring(action.muted)))

    hs.alert.show(string.format("%s %s 모드\nWiFi: %s\n볼륨: %d%%", icon, modeName, networkName, action.volume))
end

function wifiAutomator.start()
    if wifiWatcher then
        return
    end

    -- 초기 실행 (현재 상태 적용)
    handleWifiChange()

    -- 와이파이 감시자 시작
    wifiWatcher = hs.wifi.watcher.new(handleWifiChange)
    wifiWatcher:start()

    print("📡 WiFi 자동화 시스템 시작됨")
end

function wifiAutomator.stop()
    if wifiWatcher then
        wifiWatcher:stop()
        wifiWatcher = nil
    end
end

return wifiAutomator
