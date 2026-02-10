-- ========================================
-- Window Hints (화면 힌트) 모듈
-- 화면에 있는 창들에 힌트를 표시하여 빠르게 전환
-- ========================================
local config = require("config")
local CONFIG = config.CONFIG

local windowHints = {}

-- 힌트 설정 적용
local function applyHintsConfig()
	if CONFIG.HINTS then
		if CONFIG.HINTS.CHARS then
			hs.hints.hintChars = CONFIG.HINTS.CHARS
		end
		if CONFIG.HINTS.FONT_SIZE then
			hs.hints.style = "vimperator" -- 스타일 설정 (선택 사항)
			hs.hints.fontSize = CONFIG.HINTS.FONT_SIZE
		end
	end
end

-- 힌트 표시 함수
local function showHints()
	-- 설정 적용 (변경사항 반영을 위해 매번 호출하거나 초기화 시 호출 가능)
	applyHintsConfig()
	
	-- 현재 보이는 모든 창에 힌트 표시
	hs.hints.windowHints()
end

-- 모듈 초기화 (필요시)
local function start()
	applyHintsConfig()
	print("✔️ Window Hints 모듈 로드됨")
end

windowHints.showHints = showHints
windowHints.start = start

return windowHints
