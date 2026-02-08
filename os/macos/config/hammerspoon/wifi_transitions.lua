-- ========================================
-- WiFiTransitions Spoon 설정 모듈
-- ========================================
local config = require("config")
local CONFIG = config.CONFIG

local M = {}

local function setWifiVolume(vol, muted)
	local device = hs.audiodevice.defaultOutputDevice()
	if device then
		device:setVolume(vol)
		device:setMuted(muted)
	end
end

function M.getActions()
	local wifiActions = {}

	-- Home Actions (리스트 형태로 추가)
	if CONFIG.WIFI_AUTOMATION and CONFIG.WIFI_AUTOMATION.HOME_SSIDS then
		for _, ssid in ipairs(CONFIG.WIFI_AUTOMATION.HOME_SSIDS) do
			table.insert(wifiActions, {
				from = nil, -- 어디서 오든
				to = ssid, -- Lua 패턴 (정확 매칭 시 "^" .. ssid .. "$")
				fn = function(event, interface, prev_ssid, new_ssid)
					setWifiVolume(CONFIG.WIFI_AUTOMATION.ACTIONS.HOME.volume, CONFIG.WIFI_AUTOMATION.ACTIONS.HOME.muted)
					hs.alert.show(
						"🏠 Home WiFi: "
							.. new_ssid
							.. "\nVolume: "
							.. CONFIG.WIFI_AUTOMATION.ACTIONS.HOME.volume
							.. "%"
					)
				end,
			})
		end
	end

	-- Work Actions (리스트 형태로 추가)
	if CONFIG.WIFI_AUTOMATION and CONFIG.WIFI_AUTOMATION.WORK_SSIDS then
		for _, ssid in ipairs(CONFIG.WIFI_AUTOMATION.WORK_SSIDS) do
			table.insert(wifiActions, {
				from = nil,
				to = ssid,
				fn = function(event, interface, prev_ssid, new_ssid)
					setWifiVolume(CONFIG.WIFI_AUTOMATION.ACTIONS.WORK.volume, CONFIG.WIFI_AUTOMATION.ACTIONS.WORK.muted)
					hs.alert.show(
						"🏢 Work WiFi: "
							.. new_ssid
							.. "\nVolume: "
							.. CONFIG.WIFI_AUTOMATION.ACTIONS.WORK.volume
							.. "%"
					)
				end,
			})
		end
	end

	-- Default Action (홈/회사가 아닌 모든 WiFi 연결 시)
	if CONFIG.WIFI_AUTOMATION and CONFIG.WIFI_AUTOMATION.ACTIONS.DEFAULT then
		-- 모든 알려진 SSID를 수집
		local knownSSIDs = {}
		if CONFIG.WIFI_AUTOMATION.HOME_SSIDS then
			for _, ssid in ipairs(CONFIG.WIFI_AUTOMATION.HOME_SSIDS) do
				knownSSIDs[ssid] = true
			end
		end
		if CONFIG.WIFI_AUTOMATION.WORK_SSIDS then
			for _, ssid in ipairs(CONFIG.WIFI_AUTOMATION.WORK_SSIDS) do
				knownSSIDs[ssid] = true
			end
		end

		table.insert(wifiActions, {
			from = nil,
			to = ".*", -- 모든 SSID에 매칭 (Lua 패턴)
			fn = function(event, interface, prev_ssid, new_ssid)
				-- 알려진 SSID가 아닌 경우에만 DEFAULT 액션 실행
				if new_ssid and not knownSSIDs[new_ssid] then
					setWifiVolume(
						CONFIG.WIFI_AUTOMATION.ACTIONS.DEFAULT.volume,
						CONFIG.WIFI_AUTOMATION.ACTIONS.DEFAULT.muted
					)
					hs.alert.show(
						"🌐 Other WiFi: "
							.. new_ssid
							.. "\nVolume: "
							.. CONFIG.WIFI_AUTOMATION.ACTIONS.DEFAULT.volume
							.. "%"
					)
				end
			end,
		})
	end

	return wifiActions
end

return M
