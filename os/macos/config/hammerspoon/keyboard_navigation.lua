-- ========================================
-- Vim 스타일 키보드 내비게이션
-- ========================================
local config = require("config")
local CONFIG = config.CONFIG

local keyboardNavigation = {}
local eventTap = nil

-- 내장 키보드 확인 함수
local function isInternalKeyboard(event)
	-- 이벤트에서 디바이스 ID 확인 (대부분의 경우 이것으로 충분)
	local deviceID = event:getProperty(hs.eventtap.event.properties.keyboardEventKeyboardType)

	-- 디버깅용: 처음 설정 시 장치 ID 확인을 위해 주석 해제하여 사용
	-- print("Device ID: " .. tostring(deviceID))

	-- CONFIG에 설정된 ID와 비교 (설정값이 없으면 0이 아닌 모든 키보드를 대상으로 할 수도 있음)
	-- 여기서는 안전하게 모든 키보드에서 Fn+hjkl이 작동하도록 하되,
	-- 만약 외장 키보드 분리가 강력하게 필요하다면 ID 필터링을 활성화해야 함.
	-- 현재는 사용 편의성을 위해 '모든 키보드'에서 작동하게 하되, 간섭을 최소화하는 방향으로 구현.
	-- (내장 키보드만 감지하는 것은 hs.eventtap에서 완벽하지 않을 수 있음)

	-- (생략 가능, 현재 사용 안 함)
	return true
end

local function handleKeyDown(event)
	local keyCode = event:getKeyCode()
	local flags = event:getFlags()

	-- 내장 키보드 체크 (CONFIG에 설정된 ID 사용)
	local deviceID = event:getProperty(hs.eventtap.event.properties.keyboardEventKeyboardType)
	local targetDeviceID = CONFIG.INPUT_SOURCE.INTERNAL_KEYBOARD_TYPE -- 사용자가 91로 설정함

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
		-- 기존 이벤트(h/j/k/l)는 삼키고 새로운 방향키 이벤트를 생성하여 발송
		hs.eventtap.event.newKeyEvent({}, arrowKey, true):post()
		hs.eventtap.event.newKeyEvent({}, arrowKey, false):post()
		return true
	end

	return false
end

function keyboardNavigation.start()
	if eventTap then
		return
	end
	-- keyDown 이벤트만 가로챔
	eventTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, handleKeyDown)
	eventTap:start()
	print("Navigation: Fn+hjkl -> 방향키 (내장 키보드 한정)")
end

function keyboardNavigation.stop()
	if eventTap then
		eventTap:stop()
		eventTap = nil
	end
end

return keyboardNavigation
