-- ========================================
-- Hammerspoon 메인 설정 파일 (모듈화 버전)
-- 전원 관리 및 시스템 자동화 설정
-- 아래 명령어로 ~/.hammerspoon을 ~/.hammerspoon.bak으로 이동하고, /Users/oyunbog/IdeaProjects/dev-init-setting/os/macos/config/hammerspoon을 ~/.hammerspoon으로 링크합니다.
-- 반드시 폴더명 확인 필요
-- if [ -L ~/.hammerspoon ]; then rm ~/.hammerspoon; elif [ -d ~/.hammerspoon ]; then mv ~/.hammerspoon ~/.hammerspoon.bak; fi; ln -s /Users/oyunbog/IdeaProjects/dev-init-setting/os/macos/config/hammerspoon ~/.hammerspoon
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

-- 입력 소스 관리 (ESC 키 바인딩 + Vim 스타일 키보드 내비게이션)
local inputSourceManager = require("input_source_manager")

-- Hyper Key 앱 런처
local appLauncher = require("app_launcher")

-- Window Resizing (Ctrl+Option)
local windowResize = require("window_resize")

-- File Organizer (Hazel-like automation)
local fileOrganizer = require("file_organizer")

-- Git Manager (Scheduled Updates)
local gitManager = require("git_manager")

-- Window Hints (화면 힌트)
local windowHints = require("window_hints")

-- URL Dispatcher (URL 브라우저 분배기)
-- local urlDispatcher = require("url_dispatcher")

-- Break Reminder (휴식 알림)
local breakReminder = require("break_reminder")

-- App Watcher (앱 실행/종료 감지)
local appWatcher = require("app_watcher")

-- ========================================
-- 전역 변수 및 감시자 설정
-- ========================================

local powerWatcher = nil
local screenWatcher = nil
local caffeineWatcher = nil

-- ========================================
-- 초기화 및 감지 시작
-- ========================================

-- Spoon 플러그인 로드
spoonsLoader.loadAllSpoons()

-- 단축키 설정
hotkeys.setupHotkeys()

-- 입력 소스 관리 시작 (ESC 영문전환 + RightCmd 한영전환 + Fn+HJKL 방향키)
if CONFIG.FEATURES.INPUT_SOURCE then
	inputSourceManager.start()
end

-- 앱 런처 시작
if CONFIG.FEATURES.APP_LAUNCHER then
	appLauncher.start()
end

-- 창 리사이즈 시작
if CONFIG.FEATURES.WINDOW_RESIZE then
	windowResize.start()
end

-- 파일 정리 자동화 시작
if CONFIG.FEATURES.FILE_ORGANIZER then
	fileOrganizer.start()
end

-- Git Manager 시작
if CONFIG.FEATURES.GIT_MANAGER then
	gitManager.start()
end

-- Window Hints 시작
if CONFIG.FEATURES.WINDOW_HINTS then
	windowHints.start()
end

-- URL Dispatcher 시작
-- urlDispatcher.start()

-- Break Reminder 시작
if CONFIG.FEATURES.BREAK_REMINDER then
	breakReminder.start()
end

-- App Watcher 시작
if CONFIG.FEATURES.APP_WATCHER then
	appWatcher.start()
end

-- 전원 상태 변경 감지 시작
if CONFIG.FEATURES.POWER_AUTOMATION then
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
end
-- ========================================
-- 초기화 완료
-- ========================================

print("🚀 Hammerspoon 전원 관리 시스템 설정 완료!")
print("")
if CONFIG.FEATURES.POWER_AUTOMATION then
	print("☕ 카페인/BTT 자동화:")
	print("- 전원 연결 시 카페인 활성화")
	print("- 배터리 모드 시 카페인 비활성화")
	print("- 뚜껑/시스템 상태에 따라 BTT 실행 상태 조정")
	print("- 수동 제어: Cmd+Ctrl+Alt+F")
else
	print("☕ 카페인/BTT 자동화: 비활성화")
	print("- 수동 제어: Cmd+Ctrl+Alt+F")
end
print("")
print("⌨️ 입력 소스 자동화:")
print("- 특정 앱에서 ESC 키 입력 시 영문으로 자동 전환")
print("")
print("🧩 Spoon 플러그인 & 개발자 도구:")
print("- 단축키 치트시트: Cmd+Shift+/ (ESC로 닫기)")
print("- Hammerspoon 단축키 표시: Ctrl+Shift+/ (ESC로 닫기)")
print("- 개발자 명령어 실행기: Cmd+Ctrl+Alt+D (자체 구현)")
print("")
print("- 기능 토글은 config.lua의 CONFIG.FEATURES에서 설정")
