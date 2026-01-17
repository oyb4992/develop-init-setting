-- ========================================
-- Hammerspoon 설정 상수 및 캐싱 시스템
-- ========================================
local CONFIG = {
    DELAYS = {
        BTT_START_DELAY = 2, -- 2초
        SYSTEM_WAKE_DELAY = 3, -- 3초
        LID_STATE_DELAY = 1 -- 1초
    },
    BTT = {
        APP_NAME = "BetterTouchTool",
        BUNDLE_ID = "com.hegenberg.BetterTouchTool"
    },
    UI = {
        CANVAS_WIDTH = 500,
        CANVAS_HEIGHT_MAX = 400,
        CANVAS_Y_POSITION = 0.2, -- 화면 상단에서 20%
        STATUS_DISPLAY_TIME = 10, -- 10초
        TEXT_SIZE = 12,
        PADDING = 20
    },
    INPUT_SOURCE = {
        -- ESC 키로 영문 전환할 앱 리스트
        TARGET_APPS = {"Antigravity", "kitty", "Code", "Obsidian", "WebStorm", "IntelliJ IDEA"},
        ENGLISH_LAYOUT_ID = "com.apple.keylayout.ABC",
        KOREAN_LAYOUT_ID = "com.apple.inputmethod.Korean.2SetKorean", -- 두벌식 한글 (정확한 ID)
        RIGHT_COMMAND_KEYCODE = 54
    },
    WINDOW_MANAGEMENT = {
        INTERNAL_DEVICE_NAME = 91, -- 내장 키보드 식별자 (필요시 조정)
        MODIFIERS = {"ctrl"},
        MOVE_MODIFIERS = {"ctrl", "shift"}
    },
    -- 내장 키보드 타입 ID (알아내기 위해 초기에는 nil로 설정하고 콘솔 로그 확인 필요)
    -- 보통 Apple Internal Keyboard는 58(ISO), 40(ANSI) 등의 값을 가짐
    INTERNAL_KEYBOARD_TYPE = 91
}

-- 상태 표시 성능 향상을 위한 개선된 캐시 시스템
local systemStatusCache = {
    info = nil,
    lastUpdate = 0,
    cacheDuration = 3, -- 3초간 캐시 유효
    -- 추가 캐시 항목들
    btt_running = nil,
    screen_info = nil,
    power_state = nil
}

return {
    CONFIG = CONFIG,
    systemStatusCache = systemStatusCache
}

