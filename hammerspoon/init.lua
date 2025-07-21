-- Hammerspoon 개발자 유틸리티 설정
-- 모니터링 및 BTT 연동 기능 제거 버전
-- 텍스트 변환, 케이스 변환, 인코딩/디코딩, JSON 처리 등 개발자 유틸리티에 집중

print("Hammerspoon 개발자 유틸리티 설정 로드 중...")

-- ========================================
-- 전원 상태 기반 카페인 자동화 & BTT 자동화
-- ========================================

local currentPowerState = "unknown"
local powerWatcher = nil
local screenWatcher = nil
local caffeineWatcher = nil
local isLidClosed = false

-- BTT 관련 설정
local BTT_APP_NAME = "BetterTouchTool"
local BTT_BUNDLE_ID = "com.hegenberg.BetterTouchTool"

-- 전원 상태 확인
local function isOnBatteryPower()
	local success, result = pcall(hs.battery.powerSource)
	return success and result == "Battery Power"
end

local function getCurrentPowerMode()
	return isOnBatteryPower() and "battery" or "power"
end

-- BTT 관리 함수들
local function isBTTRunning()
	local bttApp = hs.application.find(BTT_BUNDLE_ID)
	return bttApp ~= nil and bttApp:isRunning()
end

local function startBTT()
	if not isBTTRunning() then
		local success = hs.application.launchOrFocus(BTT_BUNDLE_ID)
		if success then
			hs.alert.show("🎮 BTT 실행됨", 2)
		else
			-- Bundle ID로 실패시 앱 이름으로 시도
			local success2 = hs.application.launchOrFocus(BTT_APP_NAME)
			if success2 then
				hs.alert.show("🎮 BTT 실행됨", 2)
			else
				hs.alert.show("❌ BTT 실행 실패", 3)
			end
		end
	end
end

local function stopBTT()
	local bttApp = hs.application.find(BTT_BUNDLE_ID)
	if bttApp and bttApp:isRunning() then
		bttApp:kill()
		hs.alert.show("🎮 BTT 종료됨", 2)
	end
end

-- 화면 상태 확인
local function getScreenCount()
	return #hs.screen.allScreens()
end

local function hasBuiltinScreen()
	local screens = hs.screen.allScreens()
	for _, screen in ipairs(screens) do
		-- 내장 화면은 보통 이름에 "Built-in"이 포함되거나 특정 해상도를 가짐
		local name = screen:name() or ""
		if name:match("Built%-in") or name:match("Color LCD") or name:match("Liquid Retina") then
			return true
		end
	end
	return false
end

-- 카페인 상태 직접 제어
local function setCaffeineState(enabled, reason)
	local currentState = hs.caffeinate.get("displayIdle")

	if enabled and not currentState then
		-- 카페인 활성화 (디스플레이가 꺼지지 않도록)
		hs.caffeinate.set("displayIdle", true)
		hs.alert.show("☕ 카페인 활성화: " .. reason, 3)
	elseif not enabled and currentState then
		-- 카페인 비활성화
		hs.caffeinate.set("displayIdle", false)
		hs.alert.show("😴 카페인 비활성화: " .. reason, 3)
	end
	-- 이미 원하는 상태라면 아무것도 하지 않음
end

-- 현재 카페인 상태 확인
local function isCaffeineActive()
	return hs.caffeinate.get("displayIdle")
end

-- 뚜껑 상태 감지 및 BTT + 카페인 제어
local function handleLidStateChange()
	local screenCount = getScreenCount()
	local hasBuiltin = hasBuiltinScreen()
	local newLidState = not hasBuiltin -- 내장 화면이 없으면 뚜껑이 닫힌 것으로 판단

	-- 외장 모니터만 있는 경우 (Clamshell 모드)를 추가로 감지
	if screenCount == 1 and not hasBuiltin then
		newLidState = true
	elseif screenCount >= 1 and hasBuiltin then
		newLidState = false
	end

	if isLidClosed ~= newLidState then
		isLidClosed = newLidState
		local powerMode = getCurrentPowerMode()

		if isLidClosed then
			-- 뚜껑 닫힘
			if powerMode == "battery" then
				-- 배터리 모드: BTT 종료, 카페인 OFF
				stopBTT()
				setCaffeineState(false, "배터리 모드 + 뚜껑 닫힘")
			else
				-- 전원 연결: BTT 유지, 카페인 ON 유지
				-- 아무것도 하지 않음 (현재 상태 유지)
			end
		else
			-- 뚜껑 열림
			if powerMode == "battery" then
				-- 배터리 모드: BTT 실행, 카페인 OFF
				hs.timer.doAfter(2, startBTT)
				setCaffeineState(false, "배터리 모드")
			else
				-- 전원 연결: BTT 실행, 카페인 ON
				hs.timer.doAfter(2, startBTT)
				hs.timer.doAfter(3, function()
					setCaffeineState(true, "전원 연결됨")
				end)
			end
		end
	end
end

-- 시스템 잠들기/깨어나기 감지
local function handleSystemStateChange(eventType)
	if eventType == hs.caffeinate.watcher.systemWillSleep then
		-- 시스템이 잠들 때
		local powerMode = getCurrentPowerMode()
		isLidClosed = true

		if powerMode == "battery" then
			-- 배터리 모드: BTT 종료, 카페인 OFF
			stopBTT()
			setCaffeineState(false, "배터리 모드 + 시스템 잠들기")
		else
			-- 전원 연결: BTT는 종료하지만 카페인은 유지
			-- (시스템이 잠들 때는 전원 연결이어도 BTT 종료가 합리적)
			stopBTT()
		end
	elseif eventType == hs.caffeinate.watcher.systemDidWake then
		-- 시스템이 깨어날 때
		hs.timer.doAfter(3, function()
			local powerMode = getCurrentPowerMode()

			if hasBuiltinScreen() then
				isLidClosed = false
				-- BTT는 항상 실행
				startBTT()

				if powerMode == "power" then
					-- 전원 연결: 카페인 ON
					hs.timer.doAfter(1, function()
						setCaffeineState(true, "시스템 깨어남 + 전원 연결됨")
					end)
				else
					-- 배터리 모드: 카페인 OFF
					setCaffeineState(false, "시스템 깨어남 + 배터리 모드")
				end
			end
		end)
	end
end

-- 통합 상태 확인 (BTT + 카페인)
local function showSystemStatus()
	local powerMode = getCurrentPowerMode()
	local batteryLevel = hs.battery.percentage()
	local caffeineState = isCaffeineActive()
	local running = isBTTRunning()
	local screenCount = getScreenCount()
	local hasBuiltin = hasBuiltinScreen()

	local status = {
		"🖥️ 시스템 통합 상태",
		"",
		"🔋 전원: "
			.. (powerMode == "battery" and "배터리 (" .. math.floor(batteryLevel) .. "%)" or "연결됨"),
		"☕ 카페인: " .. (caffeineState and "✅ 활성화" or "❌ 비활성화"),
		"🎮 BTT: " .. (running and "✅ 실행 중" or "❌ 종료됨"),
		"",
		"🖥️ 화면 개수: " .. screenCount,
		"💻 내장 화면: " .. (hasBuiltin and "✅ 활성화" or "❌ 비활성화"),
		"📱 뚜껑 상태: " .. (isLidClosed and "🔒 닫힌 상태" or "🔓 열린 상태"),
		"",
		"💡 자동화 규칙:",
		"🔌 전원 연결 시:",
		"   • 뚜껑 열림/닫힘 → 카페인 ON, BTT 실행",
		"🔋 배터리 모드 시:",
		"   • 뚜껑 열림 → 카페인 OFF, BTT 실행",
		"   • 뚜껑 닫힘 → 카페인 OFF, BTT 종료",
	}

	hs.alert.show(table.concat(status, "\n"), 7)
end

-- BTT 수동 토글
local function toggleBTT()
	if isBTTRunning() then
		stopBTT()
	else
		startBTT()
	end
end

-- 전원 상태 변경 처리
local function handlePowerStateChange(newMode)
	if currentPowerState == newMode then
		return
	end

	currentPowerState = newMode

	if newMode == "battery" then
		setCaffeineState(false, "배터리 모드")
	else
		setCaffeineState(true, "전원 연결됨")
	end
end

-- 카페인 수동 토글
local function toggleCaffeine()
	local currentState = isCaffeineActive()
	setCaffeineState(not currentState, "수동 토글")
end

-- ========================================
-- 텍스트 처리 유틸리티
-- ========================================

local function getSelectedText()
	local originalClipboard = hs.pasteboard.getContents()
	hs.eventtap.keyStroke({ "cmd" }, "c")
	hs.timer.usleep(200000)
	local selectedText = hs.pasteboard.getContents()
	if originalClipboard then
		hs.pasteboard.setContents(originalClipboard)
	end
	return selectedText
end

local function transformAndPaste(transformFunc)
	local text = getSelectedText()
	if text and transformFunc then
		local transformed = transformFunc(text)
		hs.pasteboard.setContents(transformed)
		hs.eventtap.keyStroke({ "cmd" }, "v")
	end
end

-- ========================================
-- 개발자 유틸리티 함수들
-- ========================================

-- 케이스 변환 함수들
local function toCamelCase(str)
	return str:gsub("[-_](%w)", function(c)
		return c:upper()
	end):gsub("^%u", string.lower)
end

local function toPascalCase(str)
	return str:gsub("[-_](%w)", function(c)
		return c:upper()
	end):gsub("^%l", string.upper)
end

local function toSnakeCase(str)
	return str:gsub("([a-z])([A-Z])", "%1_%2"):gsub("[-]", "_"):lower()
end

local function toKebabCase(str)
	return str:gsub("([a-z])([A-Z])", "%1-%2"):gsub("_", "-"):lower()
end

-- Base64 인코딩/디코딩
local function base64Encode(str)
	local success, result = pcall(hs.base64.encode, str)
	return success and result or str
end

local function base64Decode(str)
	local success, result = pcall(hs.base64.decode, str)
	return success and result or str
end

-- URL 인코딩/디코딩
local function urlEncode(str)
	return hs.http.encodeForQuery(str)
end

local function urlDecode(str)
	return str:gsub("+", " "):gsub("%%(%x%x)", function(h)
		return string.char(tonumber(h, 16))
	end)
end

-- 해시 생성 (MD5, SHA1, SHA256)
local function generateMD5(str)
	local success, result = pcall(hs.hash.MD5, str)
	return success and result or str
end

local function generateSHA256(str)
	local success, result = pcall(hs.hash.SHA256, str)
	return success and result or str
end

-- 랜덤 문자열 생성
local function generateRandomString(length)
	length = length or 8
	local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local result = ""
	for i = 1, length do
		local rand = math.random(1, #charset)
		result = result .. string.sub(charset, rand, rand)
	end
	return result
end

-- 색상 코드 변환 (HEX to RGB)
local function hexToRgb(hex)
	hex = hex:gsub("#", "")
	if #hex == 6 then
		local r = tonumber("0x" .. hex:sub(1, 2))
		local g = tonumber("0x" .. hex:sub(3, 4))
		local b = tonumber("0x" .. hex:sub(5, 6))
		return "rgb(" .. r .. ", " .. g .. ", " .. b .. ")"
	end
	return hex
end

-- ========================================
-- 개발자 유틸리티 메인 함수들
-- ========================================

local function generateTimestamp()
	local timestamp = os.date("%Y-%m-%dT%H:%M:%S")
	hs.pasteboard.setContents(timestamp)
	hs.alert.show("타임스탬프 복사됨: " .. timestamp)
end

local function generateUUID()
	local uuid = hs.host.uuid()
	hs.pasteboard.setContents(uuid)
	hs.alert.show("UUID 복사됨")
end

local function formatJSON()
	local clipboard = hs.pasteboard.getContents()
	if not clipboard then
		hs.alert.show("클립보드가 비어있습니다")
		return
	end

	local success, result = pcall(hs.json.decode, clipboard)
	if success then
		local formatted = hs.json.encode(result, true)
		hs.pasteboard.setContents(formatted)
		hs.alert.show("JSON 포맷팅 완료")
	else
		hs.alert.show("유효하지 않은 JSON")
	end
end

local function minifyJSON()
	local clipboard = hs.pasteboard.getContents()
	if not clipboard then
		hs.alert.show("클립보드가 비어있습니다")
		return
	end

	local success, result = pcall(hs.json.decode, clipboard)
	if success then
		local minified = hs.json.encode(result, false)
		hs.pasteboard.setContents(minified)
		hs.alert.show("JSON 압축 완료")
	else
		hs.alert.show("유효하지 않은 JSON")
	end
end

local function generateRandomPassword()
	local password = generateRandomString(16)
	hs.pasteboard.setContents(password)
	hs.alert.show("랜덤 패스워드 생성됨")
end

-- ========================================
-- Aerospace 유틸리티 (정보 확인만)
-- ========================================

-- Aerospace 명령어 실행
local function executeAerospaceCommand(command, description)
	local aerospaceLocations = {
		"/opt/homebrew/bin/aerospace",
		"/usr/local/bin/aerospace",
		"/usr/bin/aerospace",
		"aerospace",
	}

	for _, location in ipairs(aerospaceLocations) do
		local fullCommand = location .. " " .. command
		local success, handle = pcall(io.popen, fullCommand .. " 2>&1")

		if success and handle then
			local result = handle:read("*a")
			local exitCode = handle:close()

			if
				result
				and result ~= ""
				and not result:match("command not found")
				and not result:match("No such file")
			then
				return result:gsub("[\r\n]+$", "")
			end
		end
	end

	print("Aerospace " .. description .. " 실패: 명령어를 찾을 수 없음")
	return nil
end

local function getAerospaceWorkspace()
	local result = executeAerospaceCommand("list-workspaces --focused", "워크스페이스 조회")
	if result and result ~= "" then
		local workspace = result:match("^([^\r\n]*)")
		return workspace and workspace ~= "" and workspace or "unknown"
	end
	return "unknown"
end

local function getAerospaceApps()
	local result =
		executeAerospaceCommand("list-windows --workspace focused --format '%{app-name}'", "앱 목록 조회")
	if result and result ~= "" then
		local appList = {}
		for app in result:gmatch("[^\r\n]+") do
			app = app:match("^%s*(.-)%s*$")
			if app and app ~= "" and app ~= "nil" then
				table.insert(appList, app)
			end
		end

		if #appList > 0 then
			return table.concat(appList, ", ")
		end
	end
	return "none"
end

-- Aerospace 상태 확인
local function showAerospaceStatus()
	local workspaceResult = executeAerospaceCommand("list-workspaces", "전체 워크스페이스 조회")
	local windowResult = executeAerospaceCommand("list-windows --all", "전체 윈도우 조회")

	local status = {
		"🚀 Aerospace 상태 확인",
		"",
		"워크스페이스 명령어: " .. (workspaceResult and "✅ 정상" or "❌ 실패"),
		"윈도우 명령어: " .. (windowResult and "✅ 정상" or "❌ 실패"),
	}

	if workspaceResult then
		status[#status + 1] = ""
		status[#status + 1] = "사용 가능한 워크스페이스:"
		for workspace in workspaceResult:gmatch("[^\r\n]+") do
			if workspace and workspace ~= "" then
				status[#status + 1] = "- " .. workspace
			end
		end
	end

	hs.alert.show(table.concat(status, "\n"), 6)
end

local function showWorkspaceInfo()
	local workspace = getAerospaceWorkspace()
	local apps = getAerospaceApps()
	local screens = hs.screen.allScreens()

	local info = {
		"🚀 Aerospace 워크스페이스 정보",
		"",
		"📍 현재 워크스페이스: " .. workspace,
		"📱 활성 앱들: " .. apps,
		"🖥️ 디스플레이 개수: " .. #screens,
	}

	hs.alert.show(table.concat(info, "\n"), 4)
end

-- ========================================
-- Spoons 플러그인 로딩
-- ========================================

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

-- FnMate (Fn키 토글)
loadSpoon("FnMate")

-- KSheet (단축키 치트시트)
loadSpoon("KSheet")

-- HSKeybindings (Hammerspoon 단축키 표시)
loadSpoon("HSKeybindings")

-- ========================================
-- 단축키 정의
-- ========================================

-- 텍스트 변환 (기본)
hs.hotkey.bind({ "cmd", "ctrl" }, "u", function()
	transformAndPaste(string.upper)
end)

hs.hotkey.bind({ "cmd", "ctrl" }, "l", function()
	transformAndPaste(string.lower)
end)

-- 케이스 변환 (개발자용)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "c", function()
	transformAndPaste(toCamelCase)
end)

hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "p", function()
	transformAndPaste(toPascalCase)
end)

hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "n", function()
	transformAndPaste(toSnakeCase)
end)

hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "k", function()
	transformAndPaste(toKebabCase)
end)

-- 인코딩/디코딩
hs.hotkey.bind({ "ctrl", "shift" }, "b", function()
	transformAndPaste(base64Encode)
end)

hs.hotkey.bind({ "ctrl", "shift", "alt" }, "b", function()
	transformAndPaste(base64Decode)
end)

hs.hotkey.bind({ "ctrl", "shift" }, "u", function()
	transformAndPaste(urlEncode)
end)

hs.hotkey.bind({ "ctrl", "shift", "alt" }, "u", function()
	transformAndPaste(urlDecode)
end)

-- 해시 생성
hs.hotkey.bind({ "ctrl", "shift" }, "m", function()
	transformAndPaste(generateMD5)
end)

hs.hotkey.bind({ "ctrl", "shift" }, "h", function()
	transformAndPaste(generateSHA256)
end)

-- 색상 변환
hs.hotkey.bind({ "ctrl", "shift" }, "r", function()
	transformAndPaste(hexToRgb)
end)

-- 개발자 유틸리티 (생성)
hs.hotkey.bind({ "cmd", "ctrl" }, "t", generateTimestamp)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "u", generateUUID)
hs.hotkey.bind({ "cmd", "ctrl" }, "r", generateRandomPassword)

-- JSON 처리
hs.hotkey.bind({ "cmd", "ctrl" }, "j", formatJSON)
hs.hotkey.bind({ "cmd", "ctrl" }, "m", minifyJSON)

-- Aerospace 관련 기능 (정보 확인만)
hs.hotkey.bind({ "cmd", "ctrl" }, "w", showWorkspaceInfo)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "a", showAerospaceStatus)

-- ========================================
-- BTT & 카페인 관련 단축키
-- ========================================

-- BTT 수동 토글
hs.hotkey.bind({ "cmd", "ctrl" }, "b", toggleBTT)

-- 통합 상태 확인 (BTT + 카페인 + 시스템)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "s", showSystemStatus)

-- 카페인 수동 토글 (Hyper + ])
hs.hotkey.bind({ "cmd", "ctrl", "alt", "shift" }, "]", toggleCaffeine)

-- ========================================
-- Spoon 단축키 설정
-- ========================================

-- KSheet: 단축키 치트시트
hs.hotkey.bind({ "cmd", "shift" }, "/", function()
	if spoon.KSheet then
		spoon.KSheet:toggle()
	else
		hs.alert.show("KSheet Spoon이 로드되지 않았습니다")
	end
end)

-- HSKeybindings: Hammerspoon 단축키 표시
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "/", function()
	if spoon.HSKeybindings then
		if
			spoon.HSKeybindings.sheetView
			and spoon.HSKeybindings.sheetView:hswindow()
			and spoon.HSKeybindings.sheetView:hswindow():isVisible()
		then
			spoon.HSKeybindings:hide()
		else
			spoon.HSKeybindings:show()
		end
	else
		hs.alert.show("HSKeybindings Spoon이 로드되지 않았습니다")
	end
end)

-- ========================================
-- 초기화 및 감지 시작
-- ========================================

-- 전원 상태 변경 감지 시작
powerWatcher = hs.battery.watcher.new(function()
	local newMode = getCurrentPowerMode()
	handlePowerStateChange(newMode)
end)
powerWatcher:start()

-- 화면 변경 감지 시작 (뚜껑 닫힘/열림 감지)
screenWatcher = hs.screen.watcher.new(function()
	hs.timer.doAfter(1, handleLidStateChange) -- 1초 후 상태 확인 (안정화 대기)
end)
screenWatcher:start()

-- 시스템 잠들기/깨어나기 감지 시작
caffeineWatcher = hs.caffeinate.watcher.new(handleSystemStateChange)
caffeineWatcher:start()

-- 초기 상태 설정
hs.timer.doAfter(2, function()
	-- 전원 상태 초기화
	local initialMode = getCurrentPowerMode()
	handlePowerStateChange(initialMode)

	-- 뚜껑 상태 초기화
	handleLidStateChange()
end)

-- 설정 리로드 감지
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
		hs.reload()
	end
end

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- ========================================
-- 초기화 완료
-- ========================================

print("🚀 Hammerspoon 개발자 유틸리티 설정 완료!")
print("")
print("🔤 텍스트 변환:")
print("- 대문자 변환: Cmd+Ctrl+U")
print("- 소문자 변환: Cmd+Ctrl+L")
print("")
print("🐪 케이스 변환 (개발자용):")
print("- camelCase: Cmd+Ctrl+Shift+C")
print("- PascalCase: Cmd+Ctrl+Shift+P")
print("- snake_case: Cmd+Ctrl+Shift+N")
print("- kebab-case: Cmd+Ctrl+Shift+K")
print("")
print("🔐 인코딩/디코딩:")
print("- Base64 인코딩: Ctrl+Shift+B")
print("- Base64 디코딩: Ctrl+Shift+Alt+B")
print("- URL 인코딩: Ctrl+Shift+U")
print("- URL 디코딩: Ctrl+Shift+Alt+U")
print("")
print("🔗 해시 생성:")
print("- MD5 해시: Ctrl+Shift+M")
print("- SHA256 해시: Ctrl+Shift+H")
print("")
print("🎨 유틸리티:")
print("- HEX → RGB 변환: Ctrl+Shift+R")
print("- 타임스탬프 생성: Cmd+Ctrl+T")
print("- UUID 생성: Cmd+Ctrl+Shift+U")
print("- 랜덤 패스워드: Cmd+Ctrl+R")
print("")
print("📄 JSON 처리:")
print("- JSON 포맷팅: Cmd+Ctrl+J")
print("- JSON 압축: Cmd+Ctrl+M")
print("")
print("🚀 Aerospace 유틸리티:")
print("- 워크스페이스 정보 보기: Cmd+Ctrl+W")
print("- Aerospace 상태 확인: Cmd+Ctrl+Shift+A")
print("")
print("🎮 BTT 자동화:")
print("- BTT 수동 토글: Cmd+Ctrl+B")
print("- 뚜껑 닫기 → BTT 종료 (배터리 모드만)")
print("- 뚜껑 열기 → BTT 실행")
print("- 시스템 잠들기 → BTT 종료")
print("- 시스템 깨어나기 → BTT 실행")
print("")
print("☕ 카페인 스마트 제어:")
print("- 카페인 수동 토글: Cmd+Ctrl+Shift+F")
print("- 전원 연결 시: 항상 카페인 ON (뚜껑 상태 무관)")
print("- 배터리 모드 시: 항상 카페인 OFF (뚜껑 상태 무관)")
print("")
print("📊 통합 상태 확인:")
print("- 시스템 통합 상태: Cmd+Ctrl+Shift+S")
print("- 전원, 카페인, BTT, 화면, 뚜껑 상태 + 자동화 규칙")
print("")
print("🧩 Spoon 플러그인:")
print("- 단축키 치트시트: Cmd+Shift+/")
print("- Hammerspoon 단축키 표시: Cmd+Ctrl+Shift+/")
print("")
print("✨ 스마트 자동화 규칙:")
print("🔌 전원 연결 시:")
print("   • 뚜껑 열림/닫힘 → 카페인 ON, BTT 실행")
print("🔋 배터리 모드 시:")
print("   • 뚜껑 열림 → 카페인 OFF, BTT 실행")
print("   • 뚜껑 닫힘 → 카페인 OFF, BTT 종료")
print("")
print("🎯 최종 개선사항:")
print("1. 전원 상태 우선 로직으로 더 직관적인 동작")
print("2. 전원 연결 시 clamshell 모드 완벽 지원")
print("3. 배터리 모드 시 효율적인 전력 관리")
print("4. 사용 패턴에 최적화된 스마트 자동화")
print("5. 단축키 충돌 해결 (snake_case → Cmd+Ctrl+Shift+N)")
