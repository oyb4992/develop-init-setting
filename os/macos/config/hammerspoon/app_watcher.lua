-- ========================================
-- App Watcher (앱 실행/종료 감지 자동화)
-- 앱 실행/종료 시 설정된 동작 자동 실행
-- ========================================
local config = require("config")
local CONFIG = config.CONFIG

local appWatcher = {}

-- 감시자 객체
local watcher = nil

-- 내장 동작 정의
local builtinActions = {
	-- DND (Do Not Disturb) 제어
	dnd_on = function(appName)
		-- macOS Monterey+ 에서 Focus 모드 활성화
		hs.execute(
			'shortcuts run "Turn On Do Not Disturb" 2>/dev/null || '
				.. 'osascript -e \'tell application "System Events" to keystroke "" using {}\'',
			true
		)
		hs.alert.show("🔕 DND 활성화 (" .. appName .. " 실행됨)", 3)
	end,

	dnd_off = function(appName)
		-- macOS Monterey+ 에서 Focus 모드 비활성화
		hs.execute(
			'shortcuts run "Turn Off Do Not Disturb" 2>/dev/null || '
				.. 'osascript -e \'tell application "System Events" to keystroke "" using {}\'',
			true
		)
		hs.alert.show("🔔 DND 비활성화 (" .. appName .. " 종료됨)", 3)
	end,

	-- 시스템 볼륨 제어
	mute = function(appName)
		local device = hs.audiodevice.defaultOutputDevice()
		if device then
			device:setMuted(true)
		end
		hs.alert.show("🔇 음소거 (" .. appName .. " 실행됨)", 3)
	end,

	unmute = function(appName)
		local device = hs.audiodevice.defaultOutputDevice()
		if device then
			device:setMuted(false)
		end
		hs.alert.show("🔊 음소거 해제 (" .. appName .. " 종료됨)", 3)
	end,

	-- 알림만 표시
	notify = function(appName)
		hs.alert.show("📱 " .. appName, 3)
	end,

	-- 연관 앱 종료 (rule.targets에 지정된 앱들을 함께 종료)
	quit_apps = function(appName, appObject, rule)
		local targets = rule and rule.targets
		if not targets or #targets == 0 then
			print("⚠️ App Watcher: quit_apps 동작에 targets이 없습니다")
			return
		end

		local quitList = {}
		for _, targetApp in ipairs(targets) do
			local app = hs.application.get(targetApp)
			if app then
				app:kill()
				table.insert(quitList, targetApp)
			end
		end

		if #quitList > 0 then
			hs.alert.show("🚪 " .. appName .. " 종료 → 연관 앱 종료:\n" .. table.concat(quitList, ", "), 4)
			print("🚪 App Watcher: " .. appName .. " 종료 → " .. table.concat(quitList, ", ") .. " 종료됨")
		end
	end,

	-- 연관 앱 실행 (rule.targets에 지정된 앱들을 함께 실행)
	launch_apps = function(appName, appObject, rule)
		local targets = rule and rule.targets
		if not targets or #targets == 0 then
			print("⚠️ App Watcher: launch_apps 동작에 targets이 없습니다")
			return
		end

		local launchList = {}
		for _, targetApp in ipairs(targets) do
			local app = hs.application.get(targetApp)
			if not app then
				hs.application.launchOrFocus(targetApp)
				table.insert(launchList, targetApp)
			end
		end

		if #launchList > 0 then
			hs.alert.show("🚀 " .. appName .. " 실행 → 연관 앱 실행:\n" .. table.concat(launchList, ", "), 4)
			print("🚀 App Watcher: " .. appName .. " 실행 → " .. table.concat(launchList, ", ") .. " 실행됨")
		end
	end,

	-- 입력 소스 전환 (rule.source: "english" 또는 "korean")
	set_input_source = function(appName, appObject, rule)
		local source = rule and rule.source
		if not source then
			print("⚠️ App Watcher: set_input_source 동작에 source가 없습니다")
			return
		end

		if source == "english" then
			local englishLayout = CONFIG.INPUT_SOURCE and CONFIG.INPUT_SOURCE.ENGLISH_LAYOUT_ID
				or "com.apple.keylayout.ABC"
			local result = hs.keycodes.setLayout(englishLayout)
			if not result then
				hs.keycodes.setLayout("ABC")
			end
		elseif source == "korean" then
			local koreanLayout = CONFIG.INPUT_SOURCE and CONFIG.INPUT_SOURCE.KOREAN_LAYOUT_ID
				or "com.apple.inputmethod.Korean.2SetKorean"
			local result = hs.keycodes.setLayout(koreanLayout)
			if not result then
				hs.keycodes.setMethod("2-Set Korean")
			end
		end
	end,
}

-- 이벤트 타입 매핑
local eventTypeMap = {
	[hs.application.watcher.launched] = "launched",
	[hs.application.watcher.terminated] = "terminated",
	[hs.application.watcher.activated] = "activated",
	[hs.application.watcher.deactivated] = "deactivated",
}

-- 앱 이벤트 핸들러
local function handleAppEvent(appName, eventType, appObject)
	if not CONFIG.APP_WATCHER or not CONFIG.APP_WATCHER.RULES then
		return
	end

	local eventStr = eventTypeMap[eventType]
	if not eventStr then
		return
	end

	for _, rule in ipairs(CONFIG.APP_WATCHER.RULES) do
		if rule.app == appName and rule.event == eventStr then
			local action = rule.action

			if type(action) == "string" then
				-- 내장 동작 실행
				local actionFn = builtinActions[action]
				if actionFn then
					actionFn(appName, appObject, rule)
				else
					print("⚠️ App Watcher: 알 수 없는 내장 동작: " .. action)
				end
			elseif type(action) == "function" then
				-- 사용자 정의 함수 실행
				local success, err = pcall(action, appName, appObject, rule)
				if not success then
					print("⚠️ App Watcher 동작 실행 실패: " .. tostring(err))
				end
			end
		end
	end
end

-- 모듈 시작
function appWatcher.start()
	if not CONFIG.APP_WATCHER or not CONFIG.APP_WATCHER.RULES then
		print("⏭️ App Watcher: 규칙이 없어 비활성화됨")
		return
	end

	watcher = hs.application.watcher.new(handleAppEvent)
	watcher:start()

	local ruleCount = #CONFIG.APP_WATCHER.RULES
	print("✔️ App Watcher 시작됨 (" .. ruleCount .. "개 규칙)")
end

-- 모듈 중지
function appWatcher.stop()
	if watcher then
		watcher:stop()
		watcher = nil
	end
	print("⏹️ App Watcher 중지됨")
end

return appWatcher
