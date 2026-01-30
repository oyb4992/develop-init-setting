-- ========================================
-- Spoons 플러그인 로딩
-- ========================================
local wifiTransitions = require("wifi_transitions")

local spoonsLoader = {}

-- Spoon 로딩 안전하게 처리
local function loadSpoon(spoonName)
	local success, result = pcall(hs.loadSpoon, spoonName)
	if success then
		print("✅ " .. spoonName .. " 로드 성공")
		return true
	else
		print("⚠️ " .. spoonName .. " 로드 실패: " .. tostring(result))
		return false
	end
end

-- 모든 Spoon 로드
local function loadAllSpoons()
	-- SpoonInstall 먼저 로드 (필수)
	if loadSpoon("SpoonInstall") then
		-- SpoonInstall 설정 (자동 설치 활성화)
		spoon.SpoonInstall.use_syncinstall = true

		-- 리포지토리 정보 업데이트 (최신 상태 유지)
		spoon.SpoonInstall:updateAllRepos()

		-- ReloadConfiguration.spoon
		spoon.SpoonInstall:andUse("ReloadConfiguration", {
			hotkeys = {
				reloadConfiguration = { { "cmd", "ctrl", "alt" }, "r", "Hammerspoon 설정 재로드" },
			},
			start = true,
		})

		-- KSheet (단축키 치트시트)
		spoon.SpoonInstall:andUse("KSheet")

		-- HSKeybindings (Hammerspoon 단축키 표시)
		-- -- ========================================
		-- -- 정렬: 설명 부분(: 뒤) 기준
		-- -- ========================================
		-- local function sortDesc(e)
		-- 	local msg = e.msg or ""
		-- 	-- "⌃⌥C: Window: Center" -> "Window: Center"
		-- 	return (msg:match("^[^:]+:%s*(.*)$") or msg):lower()
		-- end
		--
		-- table.sort(allKeys, function(a, b)
		-- 	local descA, descB = sortDesc(a), sortDesc(b)
		-- 	if descA ~= descB then
		-- 		return descA < descB
		-- 	end
		-- 	-- 설명이 같으면 전체 msg로 2차 정렬(안정성)
		-- 	return (a.msg or ""):lower() < (b.msg or ""):lower()
		-- end)
		-- .content > .col{
		--   width: 28%;                     /* 기존 23% → 28% */
		--   padding:20px 0 20px 20px;
		-- }
		-- .cmdtext{
		--   float: left;
		--   overflow: hidden;
		--   width: 220px;                  /* 기존 165px → 220px */
		--   white-space: nowrap;           /* 줄바꿈 방지 */
		--   text-overflow: ellipsis;       /* 넘치면 ... 표시 (선택) */
		-- }
		spoon.SpoonInstall:andUse("HSKeybindings")

		-- PopupTranslateSelection (선택 텍스트 번역)
		-- 오류 발생시 해당 spoon의 init.lua의 url 변수 확인 : local url = "http://translate.google.co.kr/?" ..
		spoon.SpoonInstall:andUse("PopupTranslateSelection")

		-- HeadphoneAutoPause (자동 일시정지)
		spoon.SpoonInstall:andUse("HeadphoneAutoPause", {
			start = true,
		})

		-- MouseCircle (마우스 위치 찾기)
		spoon.SpoonInstall:andUse("MouseCircle")

		-- WiFiTransitions (WiFi 자동화)
		-- 사용시 위치 정보 동의 필요 : 위치 정보 권한의 hammerspoon 미노출시 콘솔에 hs.location.get() 실행
		spoon.SpoonInstall:andUse("WiFiTransitions", {
			fn = function(s)
				-- 명시적으로 actions 할당
				s.actions = wifiTransitions.getActions()
			end,
			start = true,
		})
	end
end

-- Export functions
spoonsLoader.loadAllSpoons = loadAllSpoons
spoonsLoader.loadSpoon = loadSpoon

return spoonsLoader
