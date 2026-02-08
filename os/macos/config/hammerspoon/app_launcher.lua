-- ========================================
-- Hyper Key 앱 런처
-- ========================================
local appLauncher = {}
local hotkeys = {} -- 등록된 핫키 저장

-- Hyper modifiers (BTT에서 CapsLock을 이 조합으로 매핑했다고 가정)
local hyper = { "cmd", "alt", "ctrl", "shift" }

-- 단축키 매핑 설정
-- [키] = "앱 이름" (앱 이름은 /Applications 폴더의 이름과 정확히 일치해야 함)
local mappings = {
	a = "Antigravity", -- Hyper + A -> Antigravity
	b = "Boop", -- Hyper + B -> Boop
	d = "DevToys", -- Hyper + D -> DevToys
	f = "Finder", -- Hyper + F -> Finder (Home directory)
	["1"] = "IntelliJ IDEA", -- Hyper + 1 -> IntelliJ IDEA
	["2"] = "WebStorm", -- Hyper + 2 -> WebStorm
	["3"] = "DataGrip", -- Hyper + 3 -> DataGrip
	n = "Obsidian", -- Hyper + N -> Obsidian
	s = "Safari", -- Hyper + S -> Safari
	z = "Zen", -- Hyper + Z -> Zen
	t = "kitty", -- Hyper + T -> kitty
	k = "KakaoTalk", -- Hyper + K -> KakaoTalk
}

-- 앱 실행 또는 포커스 또는 숨기기 함수
local function launchOrFocus(appName)
	if appName == "Finder" then
		-- Finder는 'open ~' 명령어로 홈 디렉토리 열기
		hs.execute("open ~")
		-- 포커스도 맞추기 위해 잠시 후 활성화 (선택 사항)
		hs.timer.doAfter(0.1, function()
			hs.application.launchOrFocus("Finder")
		end)
	elseif appName == "Zen" then
		-- 앱이 실행 중인지 확인
		local zenApp = hs.application.get("Zen")
		if zenApp then
			zenApp:activate()
		else
			-- macOS에서 Firefox 계열(Zen)은 Option(Alt) 키를 누르고 실행하면 안전 모드로 진입함
			-- Hyper Key에는 Alt가 포함되어 있으므로, 0.4초 지연 실행하여 키 간섭 방지
			hs.timer.doAfter(0.4, function()
				hs.application.launchOrFocus("Zen")
			end)
		end
	else
		local success = hs.application.launchOrFocus(appName)
		if not success then
			hs.alert.show("App not found: " .. appName)
		end
	end
end

function appLauncher.start()
	for key, app in pairs(mappings) do
		-- App: [앱이름] 형태의 설명 추가
		local hk = hs.hotkey.bind(hyper, key, "App: " .. app, function()
			launchOrFocus(app)
		end)
		table.insert(hotkeys, hk)
	end
	print("🚀 App Launcher 시작됨: Hyper + [a,b,d,f,1,2,3,n,s,z,t,k]")
end

function appLauncher.stop()
	for _, hk in ipairs(hotkeys) do
		hk:delete()
	end
	hotkeys = {}
	print("🚀 App Launcher 중지됨")
end

return appLauncher
