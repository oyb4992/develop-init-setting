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
		STATUS_DISPLAY_TIME = 0, -- 0 = 자동 닫기 비활성화
		TEXT_SIZE = 12,
		PADDING = 20,
	},
	INPUT_SOURCE = {
		-- ESC 키로 영문 전환할 앱 리스트
		TARGET_APPS = { "Antigravity", "kitty", "Code", "Obsidian", "WebStorm", "IntelliJ IDEA" },
		ENGLISH_LAYOUT_ID = "com.apple.keylayout.ABC",
		KOREAN_LAYOUT_ID = "com.apple.inputmethod.Korean.2SetKorean", -- 두벌식 한글 (정확한 ID)
		RIGHT_COMMAND_KEYCODE = 54,
	},
	WINDOW_MANAGEMENT = {
		INTERNAL_DEVICE_NAME = 91, -- 내장 키보드 식별자 (필요시 조정)
		MODIFIERS = { "ctrl" },
		MOVE_MODIFIERS = { "ctrl", "shift" },
	},
	-- 내장 키보드 타입 ID (알아내기 위해 초기에는 nil로 설정하고 콘솔 로그 확인 필요)
	-- 보통 Apple Internal Keyboard는 58(ISO), 40(ANSI) 등의 값을 가짐
	INTERNAL_KEYBOARD_TYPE = 91,

	WIFI_AUTOMATION = {
		HOME_SSIDS = { "5G_LGWiFi_DBE9", "LGWiFi_DBE9" }, -- 집 WiFi 이름
		WORK_SSIDS = { "Assist." }, -- 회사 WiFi 이름
		ACTIONS = {
			HOME = {
				volume = 50,
				muted = false,
			},
			WORK = {
				volume = 0,
				muted = true,
			},
			DEFAULT = {
				volume = 0,
				muted = true,
			}, -- 그 외 (카페 등)
		},
	},
	GIT_MANAGER = {
		-- 수동 탐색 경로 설정
		REPOS = {},
		-- 자동 탐색 경로 설정
		SCAN_PATHS = {
			os.getenv("HOME") .. "/Project/be",
			os.getenv("HOME") .. "/Project/fe",
			os.getenv("HOME") .. "/Project/flyway",
		}, -- 자동 탐색 경로 추가
		-- 자동 탐색된 리포지토리의 기본 업데이트 타겟 브랜치
		DEFAULT_BRANCHES = { "main", "master", "develop", "stage" },
		SCHEDULE = {
			DAY = 4, -- 1:일, 2:월, 3:화, 4:수, 5:목, 6:금, 7:토
			HOUR = 9,
			MINUTE = 00,
		},
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
