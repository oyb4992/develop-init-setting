-- ========================================
-- 시스템 상태 정보 수집 및 표시
-- ========================================

local config = require("config")
local powerManagement = require("power_management")
local CONFIG = config.CONFIG
local systemStatusCache = config.systemStatusCache

local systemStatus = {}

-- 상태 창 표시용 Canvas 객체 (전역 변수)
local statusCanvas = nil
-- ESC 모달 변수 (충돌 방지용)
local statusModal = nil

-- 시스템 상태 정보 수집 (전원, 화면, BTT, 카페인) - 개선된 에러 처리
local function getSystemInfo()
	local info = {
		powerMode = "unknown",
		batteryLevel = 0,
		caffeineState = false,
		bttRunning = false,
		screenCount = 0,
		hasBuiltin = false,
	}

	-- 각 정보를 안전하게 수집
	local success, result

	success, result = pcall(powerManagement.getCurrentPowerMode)
	if success then
		info.powerMode = result
	end

	success, result = pcall(hs.battery.percentage)
	if success then
		info.batteryLevel = result
	end

	success, result = pcall(powerManagement.isCaffeineActive)
	if success then
		info.caffeineState = result
	end

	success, result = pcall(powerManagement.isBTTRunning)
	if success then
		info.bttRunning = result
	end

	success, result = pcall(powerManagement.getScreenCount)
	if success then
		info.screenCount = result
	end

	success, result = pcall(powerManagement.hasBuiltinScreen)
	if success then
		info.hasBuiltin = result
	end

	return info
end

-- 시스템 상태 정보 포맷팅 (블루투스/와이파이 제외)
local function formatSystemStatus(info)
	local status = {
		"🖥️ 시스템 통합 상태",
		"",
		"🔋 전원: "
			.. (info.powerMode == "battery" and "배터리 (" .. math.floor(info.batteryLevel) .. "%)" or "연결됨"),
		"☕ Hammerspoon 카페인: " .. (info.caffeineState and "✅ 활성화" or "❌ 비활성화"),
		"🎮 BTT: " .. (info.bttRunning and "✅ 실행 중" or "❌ 종료됨"),
		"",
		"🖥️ 화면 개수: " .. info.screenCount,
		"💻 내장 화면: " .. (info.hasBuiltin and "✅ 활성화" or "❌ 비활성화"),
		"📱 뚜껑 상태: " .. (powerManagement.isLidClosed() and "🔒 닫힌 상태" or "🔓 열린 상태"),
	}
	return status
end

-- 시스템 자동화 규칙 설명 (주요 동작 방식)
local function addAutomationRules(status)
	if not CONFIG.FEATURES.POWER_AUTOMATION then
		table.insert(status, "")
		table.insert(status, "💡 절전 방지: Vorssaint에서 관리 (Ctrl+Option+Cmd+K)")
		table.insert(status, "🎮 BTT 실행/종료: Hammerspoon 자동 제어 비활성화")
		return status
	end
	local rules = {
		"",
		"💡 자동화 규칙:",
		"🔌 전원 연결 시:",
		"   • 뚜껑 열림/닫힘 → 카페인 ON, BTT 실행",
		"🔋 배터리 모드 시:",
		"   • 뚜껑 열림 → 카페인 OFF, BTT 실행",
		"   • 뚜껑 닫힘 → 카페인 OFF, BTT 종료",
		"📶 백그라운드 자동화:",
		"   • 와이파이 변경 → 블루투스 자동 제어",
	}

	for _, rule in ipairs(rules) do
		table.insert(status, rule)
	end
	return status
end

-- Canvas를 이용한 상태 창 표시 (멀티 모니터 지원)
local function showStatusWithCanvas(statusLines)
	-- 기존 창이 있으면 닫기
	if statusCanvas then
		statusCanvas:delete()
	end

	-- 화면 선택 로직 개선
	local screen = nil
	local screenSource = "main" -- 디버그용
	-- 자동 닫기 타이머 (displayTime이 양수일 때만 설정)
	local displayTime = CONFIG.UI.STATUS_DISPLAY_TIME

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
			if
				mousePosition.x >= frame.x
				and mousePosition.x < (frame.x + frame.w)
				and mousePosition.y >= frame.y
				and mousePosition.y < (frame.y + frame.h)
			then
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
		h = windowHeight,
	})

	-- 배경
	statusCanvas[1] = {
		type = "rectangle",
		action = "fill",
		fillColor = {
			alpha = 0.9,
			red = 0.1,
			green = 0.1,
			blue = 0.1,
		},
		roundedRectRadii = {
			xRadius = 10,
			yRadius = 10,
		},
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
			blue = 1,
		},
		textAlignment = "left",
		frame = {
			x = CONFIG.UI.PADDING,
			y = CONFIG.UI.PADDING,
			w = windowWidth - (CONFIG.UI.PADDING * 2),
			h = windowHeight - (CONFIG.UI.PADDING * 2),
		},
	}

	-- 창 표시
	statusCanvas:show()

	-- 기존 모달이 있으면 종료
	if statusModal then
		statusModal:exit()
		statusModal = nil
	end

	-- ESC 키 핸들러 등록 (modal 사용)
	statusModal = hs.hotkey.modal.new()

	local function closeStatus()
		if statusCanvas then
			statusCanvas:delete()
			statusCanvas = nil
		end
		if statusModal then
			statusModal:exit()
			statusModal = nil
		end
	end

	statusModal:bind({}, "escape", closeStatus)
	statusModal:bind({}, "q", closeStatus)
	statusModal:enter()

	-- CONFIG에 설정된 시간 후 자동으로 닫기
	if displayTime and displayTime > 0 then
		hs.timer.doAfter(displayTime, closeStatus)
	end
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

-- Export functions
systemStatus.showSystemStatus = showSystemStatus
systemStatus.getSystemInfo = getSystemInfo

return systemStatus
