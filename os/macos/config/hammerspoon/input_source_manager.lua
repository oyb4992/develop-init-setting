-- ========================================
-- 입력 소스 관리 및 키 바인딩
-- + Vim 스타일 키보드 내비게이션 (keyboard_navigation에서 통합)
-- ========================================
local config = require("config")
local CONFIG = config.CONFIG

local inputSourceManager = {}

-- 이벤트 탭 변수
local keyDownEventTap = nil
local flagsEventTap = nil

-- 상태 추적 변수
local rightCommandDown = false
local otherKeyPressed = false

-- 입력 소스 토글 함수
local function toggleInputSource()
	local currentSource = hs.keycodes.currentSourceID()
	local englishLayout = CONFIG.INPUT_SOURCE.ENGLISH_LAYOUT_ID
	local koreanLayout = CONFIG.INPUT_SOURCE.KOREAN_LAYOUT_ID

	if currentSource == englishLayout then
		-- 1. Try setLayout (config ID)
		local result = hs.keycodes.setLayout(koreanLayout)
		if not result then
			-- 2. Try setMethod (Specific for Input Methods)
			hs.keycodes.setMethod("2-Set Korean")
		end
	else
		-- 1. Try setLayout (config ID)
		local result = hs.keycodes.setLayout(englishLayout)
		if not result then
			-- 2. Try setLayout (Name)
			hs.keycodes.setLayout("ABC")
		end
	end
end

-- Vim 스타일 내비게이션: Fn+HJKL → 방향키 (내장 키보드 한정)
local function handleVimNavigation(event)
	local keyCode = event:getKeyCode()
	local flags = event:getFlags()

	-- 내장 키보드 체크 (CONFIG에 설정된 ID 사용)
	local deviceID = event:getProperty(hs.eventtap.event.properties.keyboardEventKeyboardType)
	local targetDeviceID = CONFIG.INPUT_SOURCE.INTERNAL_KEYBOARD_TYPE

	-- 디바이스 ID가 설정되어 있고, 내장 키보드가 아니면 패스
	if targetDeviceID and deviceID ~= targetDeviceID then
		return false
	end

	-- Fn 키만 눌렸는지 확인
	local isFnOnly = flags.fn and not (flags.alt or flags.cmd or flags.shift or flags.ctrl)

	if not isFnOnly then
		return false
	end

	-- 키 매핑 (h=4, j=38, k=40, l=37) -> 방향키 (Left=123, Down=125, Up=126, Right=124)
	local arrowKey = nil
	if keyCode == 4 then
		arrowKey = 123 -- h -> Left
	elseif keyCode == 38 then
		arrowKey = 125 -- j -> Down
	elseif keyCode == 40 then
		arrowKey = 126 -- k -> Up
	elseif keyCode == 37 then
		arrowKey = 124 -- l -> Right
	end

	if arrowKey then
		hs.eventtap.event.newKeyEvent({}, arrowKey, true):post()
		hs.eventtap.event.newKeyEvent({}, arrowKey, false):post()
		return true
	end

	return false
end

-- KeyDown 핸들러 (ESC 로직 + 간섭 감지 + Vim 내비게이션)
local function handleKeyDown(event)
	-- 1. Vim 내비게이션 먼저 처리 (Fn+HJKL)
	local navResult = handleVimNavigation(event)
	if navResult then
		return true
	end

	local keyCode = event:getKeyCode()

	-- 2. Right Command 누른 상태에서 다른 키 입력 시 토글 취소
	if rightCommandDown then
		otherKeyPressed = true
	end

	-- 3. ESC 키 로직 (특정 앱에서 영문 전환)
	if keyCode == 53 then
		local frontAppObj = hs.application.frontmostApplication()
		if not frontAppObj then
			return false
		end

		local frontApp = frontAppObj:name()
		local targetApps = CONFIG.INPUT_SOURCE.TARGET_APPS

		for _, appName in ipairs(targetApps) do
			if frontApp == appName then
				local currentLayout = hs.keycodes.currentSourceID()
				local englishLayout = CONFIG.INPUT_SOURCE.ENGLISH_LAYOUT_ID

				if currentLayout ~= englishLayout then
					hs.keycodes.setLayout("ABC")
				end
				break
			end
		end
	end
	return false
end

-- FlagsChanged 핸들러 (Right Command 감지)
local function handleFlagsChanged(event)
	local keyCode = event:getKeyCode()
	local rightCmdCode = CONFIG.INPUT_SOURCE.RIGHT_COMMAND_KEYCODE or 54

	if keyCode == rightCmdCode then
		local flags = event:getFlags()

		-- 키보드 타입 확인
		local keyboardType = event:getProperty(hs.eventtap.event.properties.keyboardEventKeyboardType)

		-- 내장 키보드 제한이 설정되어 있다면 체크
		if CONFIG.INPUT_SOURCE.INTERNAL_KEYBOARD_TYPE then
			if keyboardType ~= CONFIG.INPUT_SOURCE.INTERNAL_KEYBOARD_TYPE then
				return false
			end
		end

		-- Command 키가 눌렸는지 확인
		if flags.cmd then
			-- 다른 수식 키(Shift, Ctrl, Alt)가 함께 눌리지 않았을 때만 활성화
			if not (flags.alt or flags.shift or flags.ctrl or flags.fn) then
				rightCommandDown = true
				otherKeyPressed = false
			else
				rightCommandDown = false
			end
		else
			-- Command 키를 뗐을 때
			if rightCommandDown and not otherKeyPressed then
				toggleInputSource()
			end
			rightCommandDown = false
			otherKeyPressed = false
		end
	end
	return false
end

-- 감지 시작
function inputSourceManager.start()
	if keyDownEventTap and flagsEventTap then
		keyDownEventTap:start()
		flagsEventTap:start()
		return
	end

	keyDownEventTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, handleKeyDown)
	keyDownEventTap:start()

	flagsEventTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, handleFlagsChanged)
	flagsEventTap:start()

	print("⌨️ 입력 소스 관리자 시작됨 (ESC: 영문전환, RightCmd: 한영전환, Fn+HJKL: 방향키)")
end

-- 감지 중지
function inputSourceManager.stop()
	if keyDownEventTap then
		keyDownEventTap:stop()
	end
	if flagsEventTap then
		flagsEventTap:stop()
	end
	print("⌨️ 입력 소스 관리자 중지됨")
end

return inputSourceManager
