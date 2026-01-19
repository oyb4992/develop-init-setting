-- ========================================
-- Spoons 플러그인 로딩
-- ========================================

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
	-- KSheet (단축키 치트시트)
	loadSpoon("KSheet")

	-- HSKeybindings (Hammerspoon 단축키 표시)
	loadSpoon("HSKeybindings")

	-- PopupTranslateSelection (선택 텍스트 번역)
	loadSpoon("PopupTranslateSelection")

	-- SpoonInstall (Spoon 설치)
	loadSpoon("SpoonInstall")
end

-- Export functions
spoonsLoader.loadAllSpoons = loadAllSpoons
spoonsLoader.loadSpoon = loadSpoon

return spoonsLoader
