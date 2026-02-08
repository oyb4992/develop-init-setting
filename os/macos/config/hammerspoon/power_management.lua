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
local manualCaffeineOverride = false -- 수동 카페인 설정 상태 추적

-- 상수 정의
local SCREEN_PATTERNS = { "Built%-in", "Color LCD", "Liquid Retina" }

-- 유틸리티 함수들
local function withCache(key, ttl, fetchFn)
	local now = os.time()
	if systemStatusCache[key] and (now - systemStatusCache[key].timestamp) < ttl then
		return systemStatusCache[key].value
	end

	local value = fetchFn()
	systemStatusCache[key] = {
		value = value,
		timestamp = now,
	}

	return value
end

local function safeCall(fn, ...)
	local success, result = pcall(fn, ...)
	if not success then
		print("⚠️ 함수 호출 실패: " .. tostring(result))
		return nil, result
	end
	return result, nil
end

-- 전원 상태 확인 (개선된 에러 처리)
local function isOnBatteryPower()
	local result, err = safeCall(hs.battery.powerSource)
	if err then
		print("⚠️ 전원 상태 확인 실패: " .. tostring(err))
		return false
	end
	return result == "Battery Power"
end

local function getCurrentPowerMode()
	return isOnBatteryPower() and "battery" or "power"
end

-- BTT 감지 방법들
local function tryBundleIdDetection()
	local bttApp, err = safeCall(hs.application.find, CONFIG.BTT.BUNDLE_ID)
	return bttApp and bttApp:isRunning()
end

local function tryAppNameDetection()
	local bttApp, err = safeCall(hs.application.find, CONFIG.BTT.APP_NAME)
	return bttApp and bttApp:isRunning()
end

local function tryRunningAppsDetection()
	local runningApps, err = safeCall(hs.application.runningApplications)
	if not runningApps then
		return false
	end

	for _, app in ipairs(runningApps) do
		local bundleID, err = safeCall(app.bundleID, app)
		if bundleID == CONFIG.BTT.BUNDLE_ID then
			return true
		end
	end
	return false
end

-- BTT 관리 함수들 (리팩토링된 감지 로직)
local function isBTTRunning()
	return withCache("btt_running", 2, function()
		local detectionMethods = { tryBundleIdDetection, tryAppNameDetection, tryRunningAppsDetection }

		for _, method in ipairs(detectionMethods) do
			if method() then
				return true
			end
		end
		return false
	end)
end

local function startBTT()
	if isBTTRunning() then
		return true -- 이미 실행 중
	end

	-- 첫 번째 시도: Bundle ID로 실행
	local result, err = safeCall(hs.application.launchOrFocus, CONFIG.BTT.BUNDLE_ID)
	if not err and result then
		hs.alert.show("🎮 BTT 실행됨", 2)
		return true
	end

	-- 두 번째 시도: 앱 이름으로 실행
	result, err = safeCall(hs.application.launchOrFocus, CONFIG.BTT.APP_NAME)
	if not err and result then
		hs.alert.show("🎮 BTT 실행됨", 2)
		return true
	end

	-- 실행 실패
	print("⚠️ BTT 실행 실패: " .. tostring(err))
	hs.alert.show("❌ BTT 실행 실패", 3)
	return false
end

local function stopBTT()
	local bttApp, err = safeCall(hs.application.find, CONFIG.BTT.BUNDLE_ID)
	if not err and bttApp and bttApp:isRunning() then
		local _, killErr = safeCall(bttApp.kill, bttApp)
		if not killErr then
			hs.alert.show("🎮 BTT 종료됨", 2)
			return true
		else
			print("⚠️ BTT 종료 실패: " .. tostring(killErr))
			return false
		end
	end
	return true -- 이미 종료된 상태
end

-- 화면(모니터) 상태 확인 함수들 (리팩토링된 캐시 사용)
local function getScreenCount()
	return withCache("screen_count", 1, function()
		local screens, err = safeCall(hs.screen.allScreens)
		return screens and #screens or 0
	end)
end

local function hasBuiltinScreen()
	return withCache("builtin_screen", 1, function()
		local screens, err = safeCall(hs.screen.allScreens)
		if not screens then
			return false
		end

		for _, screen in ipairs(screens) do
			local name, err = safeCall(screen.name, screen)
			if name then
				for _, pattern in ipairs(SCREEN_PATTERNS) do
					if name:match(pattern) then
						return true
					end
				end
			end
		end
		return false
	end)
end

-- 현재 카페인 상태 확인 (개선된 에러 처리)
local function isCaffeineActive()
	local result, err = safeCall(hs.caffeinate.get, "displayIdle")
	if err then
		print("⚠️ 카페인 상태 확인 실패: " .. tostring(err))
		return false
	end
	return result
end

-- 카페인 상태 직접 제어 (개선된 에러 처리)
local function setCaffeineState(enabled, reason)
	local currentState, err = safeCall(hs.caffeinate.get, "displayIdle")
	if err then
		print("⚠️ 카페인 상태 확인 실패: " .. tostring(err))
		return false
	end

	if enabled and not currentState then
		-- 카페인 활성화 (디스플레이가 꺼지지 않도록)
		local _, setErr = safeCall(hs.caffeinate.set, "displayIdle", true)
		if not setErr then
			hs.alert.show("☕ 카페인 활성화: " .. reason, 3)
			return true
		else
			print("⚠️ 카페인 활성화 실패: " .. tostring(setErr))
			return false
		end
	elseif not enabled and currentState then
		-- 카페인 비활성화
		local _, setErr = safeCall(hs.caffeinate.set, "displayIdle", false)
		if not setErr then
			hs.alert.show("😴 카페인 비활성화: " .. reason, 3)
			return true
		else
			print("⚠️ 카페인 비활성화 실패: " .. tostring(setErr))
			return false
		end
	end
	-- 이미 원하는 상태라면 아무것도 하지 않음
	return true
end

-- 조건부 카페인 제어 (수동 오버라이드 고려)
local function setCaffeineStateIfAuto(enabled, reason)
	if manualCaffeineOverride then
		return true -- 수동 모드에서는 아무것도 하지 않음
	end
	return setCaffeineState(enabled, reason)
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
				setCaffeineStateIfAuto(false, "배터리 모드 + 뚜껑 닫힘")
			else
				-- 전원 연결: BTT 유지, 카페인 ON 유지
				-- 아무것도 하지 않음 (현재 상태 유지)
			end
		else
			-- 뚜껑 열림
			if powerMode == "battery" then
				-- 배터리 모드: BTT 실행, 카페인 OFF
				hs.timer.doAfter(CONFIG.DELAYS.BTT_START_DELAY, startBTT)
				setCaffeineStateIfAuto(false, "배터리 모드")
			else
				-- 전원 연결: BTT 실행, 카페인 ON
				hs.timer.doAfter(CONFIG.DELAYS.BTT_START_DELAY, startBTT)
				hs.timer.doAfter(CONFIG.DELAYS.SYSTEM_WAKE_DELAY, function()
					setCaffeineStateIfAuto(true, "전원 연결됨")
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
			setCaffeineStateIfAuto(false, "배터리 모드 + 시스템 잠들기")
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
						setCaffeineStateIfAuto(true, "시스템 깨어남 + 전원 연결됨")
					end)
				else
					-- 배터리 모드: 카페인 OFF
					setCaffeineStateIfAuto(false, "시스템 깨어남 + 배터리 모드")
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
		setCaffeineStateIfAuto(false, "배터리 모드")
	else
		setCaffeineStateIfAuto(true, "전원 연결됨")
	end
end

-- 수동 오버라이드 해제 및 자동 제어 재활성화
local function resetCaffeineToAuto()
	manualCaffeineOverride = false
	local powerMode = getCurrentPowerMode()

	-- 현재 전원 상태에 따라 자동 제어로 복귀
	if powerMode == "battery" then
		setCaffeineState(false, "자동 제어 복귀 - 배터리 모드")
	else
		setCaffeineState(true, "자동 제어 복귀 - 전원 연결됨")
	end

	print("🔄 자동 카페인 제어 복귀")
	hs.alert.show("🔄 자동 카페인 제어 복귀", 2)
end

-- 카페인 수동 토글 (스마트 오버라이드 설정)
local function toggleCaffeine()
	local currentState = isCaffeineActive()
	local newState = not currentState
	local powerMode = getCurrentPowerMode()

	-- 자동 제어와 일치하는지 확인
	local autoState = (powerMode == "power") -- 전원 연결시 true, 배터리시 false

	if newState == autoState then
		-- 자동 제어와 일치하면 자동 모드로 복귀
		manualCaffeineOverride = false
		setCaffeineState(newState, "자동 제어 복귀 - 수동 토글")
		print("🔄 자동 카페인 제어 복귀 (설정 일치)")
		hs.alert.show("🔄 자동 카페인 제어 복귀", 2)
	else
		-- 자동 제어와 불일치하면 수동 모드 유지
		manualCaffeineOverride = true
		setCaffeineState(newState, "수동 토글")
		print("🔧 수동 카페인 설정 활성화 - 자동 제어 비활성화")
	end
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
powerManagement.resetCaffeineToAuto = resetCaffeineToAuto
powerManagement.isLidClosed = function()
	return isLidClosed
end
powerManagement.isManualCaffeineOverride = function()
	return manualCaffeineOverride
end

return powerManagement
