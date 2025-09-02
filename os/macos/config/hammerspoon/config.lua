-- ========================================
-- Hammerspoon 설정 상수 및 캐싱 시스템
-- ========================================

local CONFIG = {
	DELAYS = {
		BTT_START_DELAY = 2, -- 2초
		SYSTEM_WAKE_DELAY = 3, -- 3초
		LID_STATE_DELAY = 1, -- 1초
	},
	BTT = {
		APP_NAME = "BetterTouchTool",
		BUNDLE_ID = "com.hegenberg.BetterTouchTool",
	},
	UI = {
		CANVAS_WIDTH = 500,
		CANVAS_HEIGHT_MAX = 400,
		CANVAS_Y_POSITION = 0.2, -- 화면 상단에서 20%
		STATUS_DISPLAY_TIME = 10, -- 10초
		TEXT_SIZE = 12,
		PADDING = 20,
	},
}

-- 상태 표시 성능 향상을 위한 개선된 캐시 시스템
local systemStatusCache = {
	info = nil,
	lastUpdate = 0,
	cacheDuration = 3, -- 3초간 캐시 유효
	-- 추가 캐시 항목들
	btt_running = nil,
	screen_info = nil,
	power_state = nil,
}

return {
	CONFIG = CONFIG,
	systemStatusCache = systemStatusCache,
}

