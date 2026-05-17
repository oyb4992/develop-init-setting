-- ========================================
-- Hammerspoon 설정 상수 및 캐싱 시스템
-- ========================================
local CONFIG = {
    FEATURES = {
        POWER_AUTOMATION = true, -- 전원/뚜껑/잠자기 상태에 따라 카페인과 BTT 실행 상태를 자동 제어
        INPUT_SOURCE = true,     -- ESC/앱 활성화 시 영문 입력 전환, Right Cmd 한영 전환, Fn+HJKL/UIOP 내비게이션
        APP_LAUNCHER = true,     -- Hyper 키 조합으로 자주 쓰는 앱 실행
        WINDOW_RESIZE = true,    -- Hammerspoon 기반 창 크기/위치 조정 단축키
        FILE_ORGANIZER = true,   -- Downloads 파일을 규칙에 따라 자동 이동/분류
        GIT_MANAGER = false,     -- 지정 경로의 Git 저장소 상태 확인 및 예약 업데이트
        WINDOW_HINTS = false,    -- 화면의 창에 힌트 문자를 띄워 키보드로 포커스 이동
        BREAK_REMINDER = false,  -- 작업/휴식 타이머와 메뉴바 휴식 알림
        APP_WATCHER = true,      -- 앱 실행/활성화/종료 이벤트에 따라 입력 소스 등 자동 처리
    },
    DELAYS = {
        BTT_START_DELAY = 2,   -- 2초
        SYSTEM_WAKE_DELAY = 3, -- 3초
        LID_STATE_DELAY = 1,   -- 1초
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
        TARGET_APPS = { "Antigravity", "kitty", "Code", "Obsidian", "WebStorm", "IntelliJ IDEA", "DataGrip", "Ghostty", "Zed" },
        ENGLISH_LAYOUT_ID = "com.apple.keylayout.ABC",
        KOREAN_LAYOUT_ID = "com.apple.inputmethod.Korean.2SetKorean", -- 두벌식 한글 (정확한 ID)
        RIGHT_COMMAND_KEYCODE = 54,
        -- 내장 키보드 타입 ID (알아내기 위해 초기에는 nil로 설정하고 콘솔 로그 확인 필요)
        -- 보통 Apple Internal Keyboard는 58(ISO), 40(ANSI) 등의 값을 가짐
        INTERNAL_KEYBOARD_TYPE = 91,
    },

    WIFI_AUTOMATION = {
        HOME_SSIDS = { "5G_LGWiFi_DBE9", "LGWiFi_DBE9" }, -- 집 WiFi 이름
        WORK_SSIDS = { "Assist." },                       -- 회사 WiFi 이름
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
            os.getenv("HOME") .. "/IdeaProjects",
        }, -- 자동 탐색 경로 추가
        -- 자동 탐색된 리포지토리의 기본 업데이트 타겟 브랜치
        DEFAULT_BRANCHES = { "main", "master", "develop", "stage" },
        SCHEDULE = {
            DAY = 4, -- 1:일, 2:월, 3:화, 4:수, 5:목, 6:금, 7:토
            HOUR = 9,
            MINUTE = 00,
        },
    },
    DOCKER = {
        PATH = "/opt/homebrew/bin/docker", -- M1/M2 Mac 기준, Intel: /usr/local/bin/docker
    },
    FILE_ORGANIZER = {
        WATCH_PATHS = { os.getenv("HOME") .. "/Downloads" },
        SCAN_EXISTING_ON_START = false,
        KAKAOTALK_PHOTO_DIR = os.getenv("HOME") .. "/Pictures/KakaoTalk",
        IMAGE_EXTENSIONS = {
            [".jpg"] = true,
            [".jpeg"] = true,
            [".png"] = true,
            [".gif"] = true,
            [".bmp"] = true,
            [".tiff"] = true,
            [".webp"] = true,
            [".svg"] = true,
            [".heic"] = true,
            [".raw"] = true,
        },
        DOCUMENT_EXTENSIONS = {
            [".pdf"] = true,
            [".doc"] = true,
            [".docx"] = true,
            [".xls"] = true,
            [".xlsx"] = true,
            [".ppt"] = true,
            [".pptx"] = true,
            [".txt"] = true,
            [".md"] = true,
            [".hwp"] = true,
            [".csv"] = true,
            [".pages"] = true,
            [".numbers"] = true,
            [".key"] = true,
        },
    },
    HINTS = {
        CHARS = "ASDFJKLGHNMXCZWQERTYUIOP", -- 힌트로 사용할 문자열 (왼손 위주)
        FONT_SIZE = 18,
    },
    URL_DISPATCHER = {
        ENABLED = true,
        DEFAULT_BROWSER = "com.google.Chrome", -- 기본 브라우저 (규칙 미매칭 시)
        RULES = {
            -- { pattern = "호스트에 포함된 문자열", browser = "앱 번들 ID" }
            { pattern = "github.com", browser = "com.openai.atlas" },
        },
    },
    BREAK_REMINDER = {
        WORK_MINUTES = 50,   -- 작업 시간 (분)
        BREAK_MINUTES = 10,  -- 휴식 시간 (분)
        ALERT_DURATION = 20, -- 알림 표시 시간 (초)
        SHOW_MENUBAR = true, -- 메뉴바 아이콘 표시 여부
        ALERT_STYLE = {
            strokeColor = { white = 1, alpha = 1 },
            fillColor = { black = 0, alpha = 0.8 },
            textColor = { white = 1, alpha = 1 },
            textSize = 35,
            radius = 12,
        },
    },
    APP_WATCHER = {
        RULES = {
            -- event: "launched", "terminated", "activated", "deactivated"
            -- action: "dnd_on", "dnd_off", "mute", "unmute", "notify",
            --         "quit_apps", "launch_apps", "set_input_source" 또는 커스텀 함수
            -- quit_apps/launch_apps: targets = { "앱1", "앱2" } 필수
            -- set_input_source: source = "english" 또는 "korean" 필수

            -- { app = "zoom.us", event = "launched", action = "dnd_on" },
            -- { app = "zoom.us", event = "terminated", action = "dnd_off" },

            -- JetBrains IDE 연쇄 종료
            -- { app = "IntelliJ IDEA", event = "terminated", action = "quit_apps", targets = { "WebStorm" } },
            -- { app = "WebStorm", event = "terminated", action = "quit_apps", targets = { "IntelliJ IDEA" } },

            -- JetBrains IDE 연쇄 실행
            -- { app = "IntelliJ IDEA", event = "launched", action = "launch_apps", targets = { "WebStorm" } },
            -- { app = "WebStorm", event = "launched", action = "launch_apps", targets = { "IntelliJ IDEA" } },

            -- IDE/터미널 활성화 시 영문 입력 자동 전환
            { app = "IntelliJ IDEA", event = "activated", action = "set_input_source", source = "english" },
            { app = "WebStorm",      event = "activated", action = "set_input_source", source = "english" },
            { app = "DataGrip",      event = "activated", action = "set_input_source", source = "english" },
            { app = "Ghostty",       event = "activated", action = "set_input_source", source = "english" },
            { app = "Antigravity",   event = "activated", action = "set_input_source", source = "english" },
            { app = "Zed",           event = "activated", action = "set_input_source", source = "english" },
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
