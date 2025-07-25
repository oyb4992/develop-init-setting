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
    DOCKER_COMPOSE = {
        -- Docker Compose 프로젝트 경로 목록 (사용자 맞춤 설정)
        PROJECTS = {{
            name = "개발 환경",
            path = "~/IdeaProjects/kids_snsid_inapp"
        }, {
            name = "웹 프로젝트",
            path = "~/IdeaProjects/kids_snsid_inapp"
        }, {
            name = "마이크로서비스",
            path = "~/IdeaProjects/kids_snsid_inapp"
        }}
    },
    YARN_PROJECTS = {
        -- Yarn 프로젝트 경로 목록 (사용자 맞춤 설정)
        PROJECTS = {{
            name = "React 앱",
            path = "~/IdeaProjects/kids_snsid_inapp",
            scripts = {"dev", "start", "build", "test"}
        }, {
            name = "Node.js 서버",
            path = "~/IdeaProjects/node-server",
            scripts = {"dev", "start", "build", "test", "watch"}
        }, {
            name = "Frontend 프로젝트",
            path = "~/IdeaProjects/frontend-project",
            scripts = {"dev", "start", "build", "test", "storybook"}
        }}
    }
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