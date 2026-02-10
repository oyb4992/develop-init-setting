-- ========================================
-- URL Dispatcher (URL 브라우저 분배기)
-- 외부 앱에서 URL 클릭 시 패턴에 따라 지정 브라우저로 열기
-- ========================================
local config = require("config")
local CONFIG = config.CONFIG

local urlDispatcher = {}

-- 원래 기본 브라우저 핸들러 저장 (stop 시 복원용)
local originalHandler = nil

-- URL 패턴 매칭 및 브라우저 선택
local function findBrowserForURL(host)
	if not CONFIG.URL_DISPATCHER or not CONFIG.URL_DISPATCHER.RULES then
		return nil
	end

	for _, rule in ipairs(CONFIG.URL_DISPATCHER.RULES) do
		if host and host:find(rule.pattern) then
			return rule.browser
		end
	end

	return nil
end

-- HTTP/HTTPS 콜백 핸들러
local function httpCallback(scheme, host, params, fullURL, senderPID)
	if not CONFIG.URL_DISPATCHER or not CONFIG.URL_DISPATCHER.ENABLED then
		-- 비활성화 상태면 기본 브라우저로 열기
		local defaultBrowser = CONFIG.URL_DISPATCHER and CONFIG.URL_DISPATCHER.DEFAULT_BROWSER or "com.apple.Safari"
		hs.urlevent.openURLWithBundle(fullURL, defaultBrowser)
		return
	end

	local targetBrowser = findBrowserForURL(host)

	if targetBrowser then
		print("🔗 URL Dispatcher: " .. fullURL .. " → " .. targetBrowser)
		hs.urlevent.openURLWithBundle(fullURL, targetBrowser)
	else
		-- 매칭 규칙이 없으면 기본 브라우저로 열기
		local defaultBrowser = CONFIG.URL_DISPATCHER.DEFAULT_BROWSER or "com.apple.Safari"
		print("🔗 URL Dispatcher: " .. fullURL .. " → Default (" .. defaultBrowser .. ")")
		hs.urlevent.openURLWithBundle(fullURL, defaultBrowser)
	end
end

-- 모듈 시작
function urlDispatcher.start()
	if not CONFIG.URL_DISPATCHER or not CONFIG.URL_DISPATCHER.ENABLED then
		print("⏭️ URL Dispatcher 비활성화 (config.URL_DISPATCHER.ENABLED = false)")
		return
	end

	-- 현재 기본 핸들러 저장 (복원용)
	originalHandler = hs.urlevent.getDefaultHandler("http")

	-- Hammerspoon을 기본 HTTP/HTTPS 핸들러로 등록
	hs.urlevent.setDefaultHandler("http")

	-- HTTP 콜백 등록
	hs.urlevent.httpCallback = httpCallback

	local ruleCount = CONFIG.URL_DISPATCHER.RULES and #CONFIG.URL_DISPATCHER.RULES or 0
	print("✔️ URL Dispatcher 시작됨 (" .. ruleCount .. "개 규칙)")
end

-- 모듈 중지 (원래 브라우저로 복원)
function urlDispatcher.stop()
	if originalHandler then
		hs.urlevent.setDefaultHandler("http", originalHandler)
		print("🔗 URL Dispatcher 중지: 기본 핸들러 복원 → " .. originalHandler)
	end
	hs.urlevent.httpCallback = nil
	originalHandler = nil
end

return urlDispatcher
