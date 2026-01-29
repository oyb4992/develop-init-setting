-- ========================================
-- WiFiTransitions Spoon 설정 모듈
-- ========================================
local config = require("config")
local CONFIG = config.CONFIG

local M = {}

-- 볼륨 조절 헬퍼 함수
local function setWifiVolume(vol, muted)
	local device = hs.audiodevice.defaultOutputDevice()
	if device then
		device:setVolume(vol)
		device:setMuted(muted)
	end
end

-- WiFiTransitions용 actions 테이블 생성
function M.getActions()
	local wifiActions = {}

	-- Home Actions
	if CONFIG.WIFI_AUTOMATION and CONFIG.WIFI_AUTOMATION.HOME_SSIDS then
		for _, ssid in ipairs(CONFIG.WIFI_AUTOMATION.HOME_SSIDS) do
			wifiActions[ssid] = function()
				setWifiVolume(CONFIG.WIFI_AUTOMATION.ACTIONS.HOME.volume, CONFIG.WIFI_AUTOMATION.ACTIONS.HOME.muted)
				hs.alert.show("🏠 Home WiFi Connected\nVolume: " .. CONFIG.WIFI_AUTOMATION.ACTIONS.HOME.volume .. "%")
			end
		end
	end

	-- Work Actions
	if CONFIG.WIFI_AUTOMATION and CONFIG.WIFI_AUTOMATION.WORK_SSIDS then
		for _, ssid in ipairs(CONFIG.WIFI_AUTOMATION.WORK_SSIDS) do
			wifiActions[ssid] = function()
				setWifiVolume(CONFIG.WIFI_AUTOMATION.ACTIONS.WORK.volume, CONFIG.WIFI_AUTOMATION.ACTIONS.WORK.muted)
				hs.alert.show("🏢 Work WiFi Connected\nVolume: " .. CONFIG.WIFI_AUTOMATION.ACTIONS.WORK.volume .. "%")
			end
		end
	end

	return wifiActions
end

return M
