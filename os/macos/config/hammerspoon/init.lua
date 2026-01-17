-- ========================================
-- Hammerspoon 메인 설정 파일 (모듈화 버전)
-- 전원 관리 및 시스템 자동화 설정
-- ========================================
print("Hammerspoon 전원 관리 시스템 로드 중...")

-- ========================================
-- 모듈 로드
-- ========================================
hs.application.enableSpotlightForNameSearches(true)
-- 설정 및 캐시 시스템
local config = require("config")
local CONFIG = config.CONFIG

-- 전원 관리 및 BTT 자동화
local powerManagement = require("power_management")

-- Spoon 플러그인 로더
local spoonsLoader = require("spoons_loader")

-- 단축키 설정
local hotkeys = require("hotkeys")

-- 입력 소스 관리 (ESC 키 바인딩)
local inputSourceManager = require("input_source_manager")

-- Vim 스타일 키보드 내비게이션
local keyboardNavigation = require("keyboard_navigation")

-- WiFi 자동화
local wifiAutomator = require("wifi_automator")

-- Hyper Key 관리
local capslockManager = require("capslock_manager")

-- 입력 소스 시각화
-- local visualizer = require("input_source_visualizer")

-- ========================================
-- 전역 변수 및 감시자 설정
-- ========================================

local powerWatcher = nil
local screenWatcher = nil
local caffeineWatcher = nil
local wifiWatcher = nil

-- ========================================
-- 초기화 및 감지 시작
-- ========================================

-- Spoon 플러그인 로드
spoonsLoader.loadAllSpoons()

-- 단축키 설정
hotkeys.setupHotkeys()

-- 입력 소스 관리 시작
inputSourceManager.start()

-- 키보드 내비게이션 시작
keyboardNavigation.start()

-- WiFi 자동화 시작
wifiAutomator.start()

-- Hyper Key 시작
capslockManager.start()

-- 시각화 시작
-- visualizer.start()

-- 전원 상태 변경 감지 시작
powerWatcher = hs.battery.watcher.new(function()
    local newMode = powerManagement.getCurrentPowerMode()
    powerManagement.handlePowerStateChange(newMode)
end)
powerWatcher:start()

-- 화면 변경 감지 시작 (뚜껑 닫힘/열림 감지)
screenWatcher = hs.screen.watcher.new(function()
    hs.timer.doAfter(CONFIG.DELAYS.LID_STATE_DELAY, powerManagement.handleLidStateChange) -- 안정화 대기
end)
screenWatcher:start()

-- 시스템 잠들기/깨어나기 감지 시작
caffeineWatcher = hs.caffeinate.watcher.new(powerManagement.handleSystemStateChange)
caffeineWatcher:start()

-- 초기 상태 설정
hs.timer.doAfter(CONFIG.DELAYS.SYSTEM_WAKE_DELAY, function()
    -- 전원 상태 초기화
    local initialMode = powerManagement.getCurrentPowerMode()
    powerManagement.handlePowerStateChange(initialMode)

    -- 뚜껑 상태 초기화
    powerManagement.handleLidStateChange()
end)

-- ========================================
-- 설정 리로드 감지
-- ========================================

-- Hammerspoon 설정 파일 변경 감지 및 자동 재로드
function reloadConfig(files)
    doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        -- 리로드 전에 모든 감지 기능 중지
        if powerWatcher then
            powerWatcher:stop()
        end
        if screenWatcher then
            screenWatcher:stop()
        end
        if caffeineWatcher then
            caffeineWatcher:stop()
        end
        if wifiWatcher then
            wifiWatcher:stop()
        end

        -- 모듈별 정리
        inputSourceManager.stop()

        hs.reload()
    end
end

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- ========================================
-- 초기화 완료
-- ========================================

print("🚀 Hammerspoon 전원 관리 시스템 설정 완료!")
print("")
print("☕ 카페인 자동화:")
print("- 전원 연결 시 자동 활성화")
print("- 배터리 모드 시 자동 비활성화")
print("- 뚜껑 닫기/시스템 잠들기 시 배터리 보호")
print("- 수동 제어: Cmd+Ctrl+Alt+F")
print("")
print("🎮 BTT 자동화:")
print("- 뚜껑 닫기 → BTT 종료")
print("- 뚜껑 열기 → BTT 실행")
print("- 시스템 잠들기 → BTT 종료")
print("- 시스템 깨어나기 → BTT 실행")
print("")
print("⌨️ 입력 소스 자동화:")
print("- 특정 앱에서 ESC 키 입력 시 영문으로 자동 전환")
print("")
print("🧩 Spoon 플러그인 & 개발자 도구:")
print("- 단축키 치트시트: Cmd+Shift+/ (ESC로 닫기)")
print("- Hammerspoon 단축키 표시: Ctrl+Shift+/ (ESC로 닫기)")
print("- 개발자 명령어 실행기: Cmd+Ctrl+Alt+D (자체 구현)")
print("")
print("- 프로젝트 경로는 CONFIG.YARN_PROJECTS.PROJECTS에서 설정")
