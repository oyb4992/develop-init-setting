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

-- 특정 앱 이름 리스트 (여기에 앱의 정확한 이름을 추가하세요)
local targetApps = { "Antigravity", "kitty", "Code", "Obsidian", "WebStorm", "IntelliJ IDEA" }

-- ========================================
-- ESC 키 바인딩 (입력 소스 전환 수정 버전)
-- ========================================

-- [수정 1] local을 제거하고 전역 변수로 선언하여 가비지 컬렉션 방지
-- 충돌 방지를 위해 변수명을 조금 더 유니크하게 변경 (예: runnerEscBind)
runnerEscBind = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
	local keyCode = event:getKeyCode()

	-- 53은 ESC 키
	if keyCode == 53 then
		local frontAppObj = hs.application.frontmostApplication()

		-- 앱 객체가 없으면 무시 (오류 방지)
		if not frontAppObj then
			return false
		end

		local frontApp = frontAppObj:name()

		-- 디버깅용: 콘솔에 현재 앱 이름 출력 (문제가 계속되면 주석 해제해서 확인)
		-- print("ESC Pressed in: " .. frontApp)

		for _, appName in ipairs(targetApps) do
			if frontApp == appName then
				-- [수정 2] 현재 이미 영문 상태라면 불필요하게 변경하지 않음 (성능 최적화)
				local currentLayout = hs.keycodes.currentSourceID()

				-- 'com.apple.keylayout.ABC'는 일반적인 영문 레이아웃 ID입니다.
				-- 만약 작동하지 않으면 터미널에 `defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID` 입력하여 확인
				if currentLayout ~= "com.apple.keylayout.ABC" then
					hs.keycodes.setLayout("ABC")
				end
				break
			end
		end
	end
	return false -- ESC 본래 기능 수행
end)

runnerEscBind:start()

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
print("🧩 Spoon 플러그인 & 개발자 도구:")
print("- 단축키 치트시트: Cmd+Shift+/ (ESC로 닫기)")
print("- Hammerspoon 단축키 표시: Ctrl+Shift+/ (ESC로 닫기)")
print("- 개발자 명령어 실행기: Cmd+Ctrl+Alt+D (자체 구현)")
print("")
print("- 프로젝트 경로는 CONFIG.YARN_PROJECTS.PROJECTS에서 설정")
