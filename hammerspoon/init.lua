-- Hammerspoon 개발자 유틸리티 설정
-- 모니터링 및 BTT 연동 기능 제거 버전
-- 텍스트 변환, 케이스 변환, 인코딩/디코딩, JSON 처리 등 개발자 유틸리티에 집중
-- 와이파이 기반 블루투스 자동화 기능 추가
print("Hammerspoon 개발자 유틸리티 설정 로드 중...")

-- ========================================
-- 설정 상수 및 캐싱 시스템
-- ========================================

-- 설정 상수들
local CONFIG = {
    DELAYS = {
        CLIPBOARD_WAIT = 200000, -- 200ms (usleep용)
        BTT_START_DELAY = 2, -- 2초
        SYSTEM_WAKE_DELAY = 3, -- 3초
        WIFI_STABILIZE_DELAY = 2, -- 2초
        LID_STATE_DELAY = 1 -- 1초
    },
    WIFI = {
        LG_NETWORKS = {"5G_LGWiFi_DBE9", "LGWiFi_DBE9"},
        HOME_NETWORK = "sporky"
    },
    BLUETOOTH = {
        CACHE_DURATION = 5 -- 5초간 블루투스 상태 캐시
    },
    BTT = {
        APP_NAME = "BetterTouchTool",
        BUNDLE_ID = "com.hegenberg.BetterTouchTool"
    },
    UI = {
        CANVAS_WIDTH = 500,
        CANVAS_HEIGHT_MAX = 400,
        CANVAS_Y_POSITION = 0.2, -- 화면 상단에서 20%
        STATUS_DISPLAY_TIME = 3, -- 3초
        TEXT_SIZE = 12,
        PADDING = 20
    }
}

-- blueutil 경로 캐싱
local BLUEUTIL_PATH = nil
local function getBlueUtilPath()
    if not BLUEUTIL_PATH then
        local paths = {"/opt/homebrew/bin/blueutil", "/usr/local/bin/blueutil", "/usr/bin/blueutil"}
        for _, path in ipairs(paths) do
            if hs.fs.attributes(path) then
                BLUEUTIL_PATH = path
                break
            end
        end
    end
    return BLUEUTIL_PATH
end

-- 블루투스 상태 캐싱
local bluetoothStateCache = {
    state = nil,
    lastCheck = 0
}

-- 안전한 명령어 실행 헬퍼 (단순화됨)
local function safeExecute(command, fallbackMessage)
    local output, success = hs.execute(command)

    if not success then
        if fallbackMessage then
            hs.alert.show("⚠️ " .. fallbackMessage, 2)
        end
        return nil
    end
    return output
end

-- ========================================
-- 전원 상태 기반 카페인 자동화 & BTT 자동화
-- ========================================

local currentPowerState = "unknown"
local powerWatcher = nil
local screenWatcher = nil
local caffeineWatcher = nil
local wifiWatcher = nil
local isLidClosed = false
local currentSSID = nil

-- BTT 관련 설정 (CONFIG 테이블로 이동됨)

-- 전원 상태 확인
local function isOnBatteryPower()
    local success, result = pcall(hs.battery.powerSource)
    return success and result == "Battery Power"
end

local function getCurrentPowerMode()
    return isOnBatteryPower() and "battery" or "power"
end

-- BTT 관리 함수들 (개선된 감지)
local function isBTTRunning()
    -- 방법 1: Bundle ID로 찾기
    local bttApp = hs.application.find(CONFIG.BTT.BUNDLE_ID)
    if bttApp and bttApp:isRunning() then
        return true
    end

    -- 방법 2: 앱 이름으로 찾기
    local bttApp2 = hs.application.find(CONFIG.BTT.APP_NAME)
    if bttApp2 and bttApp2:isRunning() then
        return true
    end

    -- 방법 3: 실행 중인 앱 목록에서 직접 찾기
    local runningApps = hs.application.runningApplications()
    for _, app in ipairs(runningApps) do
        local bundleID = app:bundleID()
        if bundleID == CONFIG.BTT.BUNDLE_ID then
            return true
        end
    end

    -- 방법 4: ps 명령어로 프로세스 확인 (fallback)
    local output, success = hs.execute("ps aux | grep -i bettertouchtool | grep -v grep")
    if success and output and output:find("BetterTouchTool") then
        return true
    end

    return false
end

local function startBTT()
    if not isBTTRunning() then
        local success = hs.application.launchOrFocus(CONFIG.BTT.BUNDLE_ID)
        if success then
            hs.alert.show("🎮 BTT 실행됨", 2)
        else
            -- Bundle ID로 실패시 앱 이름으로 시도
            local success2 = hs.application.launchOrFocus(CONFIG.BTT.APP_NAME)
            if success2 then
                hs.alert.show("🎮 BTT 실행됨", 2)
            else
                hs.alert.show("❌ BTT 실행 실패", 3)
            end
        end
    end
end

local function stopBTT()
    local bttApp = hs.application.find(CONFIG.BTT.BUNDLE_ID)
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
                hs.timer.doAfter(CONFIG.DELAYS.BTT_START_DELAY, startBTT)
                setCaffeineState(false, "배터리 모드")
            else
                -- 전원 연결: BTT 실행, 카페인 ON
                hs.timer.doAfter(CONFIG.DELAYS.BTT_START_DELAY, startBTT)
                hs.timer.doAfter(CONFIG.DELAYS.SYSTEM_WAKE_DELAY, function()
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
        hs.timer.doAfter(CONFIG.DELAYS.SYSTEM_WAKE_DELAY, function()
            local powerMode = getCurrentPowerMode()

            if hasBuiltinScreen() then
                isLidClosed = false
                -- BTT는 항상 실행
                startBTT()

                if powerMode == "power" then
                    -- 전원 연결: 카페인 ON
                    hs.timer.doAfter(CONFIG.DELAYS.LID_STATE_DELAY, function()
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
-- 와이파이 기반 블루투스 자동화 (macOS 기본 명령어 사용)
-- ========================================

-- 개선된 블루투스 상태 확인 (system_profiler를 primary method로 사용)
local function isBluetoothOn()
    local now = os.time()

    -- 캐시된 결과가 유효하면 반환
    if bluetoothStateCache.state ~= nil and (now - bluetoothStateCache.lastCheck) < CONFIG.BLUETOOTH.CACHE_DURATION then
        return bluetoothStateCache.state
    end

    -- primary: system_profiler 사용 (더 안정적)
    local output, success = hs.execute("system_profiler SPBluetoothDataType | grep -E 'State:'")
    if success and output then
        local isOn = output:find("State:%s*On") ~= nil
        bluetoothStateCache.state = isOn
        bluetoothStateCache.lastCheck = now
        return isOn
    end

    -- fallback: blueutil 사용 (Hammerspoon 환경에서 불안정할 수 있음)
    local blueUtilPath = getBlueUtilPath()
    if blueUtilPath then
        local output, success = hs.execute(blueUtilPath .. " -p")
        if success and output then
            local cleanOutput = output:gsub("%s+", "")
            if cleanOutput == "0" then
                bluetoothStateCache.state = false
                bluetoothStateCache.lastCheck = now
                return false
            elseif cleanOutput == "1" then
                bluetoothStateCache.state = true
                bluetoothStateCache.lastCheck = now
                return true
            end
        end
    end

    -- 모든 방법이 실패한 경우 기본값으로 false 반환
    return false
end

-- 개선된 블루투스 제어
local function setBluetoothState(enabled, reason)
    local currentState = isBluetoothOn()

    -- 이미 원하는 상태라면 아무것도 하지 않음
    if enabled == currentState then
        return
    end

    -- blueutil을 사용한 제어
    local blueUtilPath = getBlueUtilPath()
    if blueUtilPath then
        local cmd = blueUtilPath .. (enabled and " -p 1" or " -p 0") .. " 2>/dev/null"
        local output = safeExecute(cmd)

        if output ~= nil then -- 성공한 경우
            local emoji = enabled and "📶" or "📵"
            local action = enabled and "켜짐" or "꺼짐"
            hs.alert.show(emoji .. " 블루투스 " .. action .. ": " .. reason, 2)

            -- 캐시 무효화 (상태가 변경되었으므로)
            bluetoothStateCache.state = nil
            return
        end
    end

    -- fallback: 시스템 설정 열기
    hs.execute('open "x-apple.systempreferences:com.apple.preference.bluetooth"')
    local action = enabled and "켜기" or "끄기"
    hs.alert.show("📱 블루투스 설정 열림: " .. reason .. " (수동 " .. action .. " 필요)", 3)
    print("⚠️ blueutil을 찾을 수 없음. 'brew install blueutil' 명령어로 설치하세요.")
end

-- 현재 와이파이 SSID 확인 (개선된 버전)
local function getCurrentSSID()
    -- 먼저 hs.wifi.currentNetwork() 시도
    local success, ssid = pcall(hs.wifi.currentNetwork)
    if success and ssid and ssid ~= "" then
        return ssid
    end

    -- fallback 1: system_profiler 사용
    local output, success = hs.execute(
        "system_profiler SPAirPortDataType | grep -A1 'Current Network Information:' | grep ':'")
    if success and output then
        -- "            NetworkName:" 형식에서 네트워크 이름 추출
        local lines = {}
        for line in output:gmatch("[^\r\n]+") do
            table.insert(lines, line)
        end

        for _, line in ipairs(lines) do
            local network = line:match("^%s*([^:]+):")
            if network and not network:match("Current Network Information") and not network:match("Network Type") then
                network = network:gsub("^%s+", ""):gsub("%s+$", "")
                if network ~= "" then
                    return network
                end
            end
        end
    end

    -- fallback 2: networksetup 명령어 사용
    local output2, success2 = hs.execute("networksetup -getairportnetwork en0")
    if success2 and output2 then
        local network = output2:match("Current Wi%-Fi Network: (.+)")
        if network then
            network = network:gsub("[\r\n]", ""):gsub("^%s+", ""):gsub("%s+$", "")
            return network ~= "" and network or nil
        end
    end

    return nil
end

-- 네트워크별 블루투스 설정 확인
local function isLGNetwork(ssid)
    for _, network in ipairs(CONFIG.WIFI.LG_NETWORKS) do
        if ssid == network then
            return true
        end
    end
    return false
end

-- 와이파이 변경 처리
local function handleWifiChange()
    local newSSID = getCurrentSSID()

    -- SSID가 변경되었을 때만 처리
    if currentSSID ~= newSSID then
        local oldSSID = currentSSID or "없음"
        currentSSID = newSSID or nil

        if newSSID then
            print("📶 와이파이 연결 변경: " .. oldSSID .. " → " .. newSSID)

            -- LG 네트워크: 블루투스 끄기
            if isLGNetwork(newSSID) then
                local bluetoothState = isBluetoothOn()
                if bluetoothState then
                    setBluetoothState(false, "LGWiFi 네트워크 연결")
                else
                    hs.alert.show("📵 블루투스 이미 꺼짐 (LGWiFi)", 2)
                end

                -- HOME 네트워크: 블루투스 켜기
            elseif newSSID == CONFIG.WIFI.HOME_NETWORK then
                local bluetoothState = isBluetoothOn()
                if not bluetoothState then
                    setBluetoothState(true, CONFIG.WIFI.HOME_NETWORK .. " 네트워크 연결")
                else
                    hs.alert.show("📶 블루투스 이미 켜짐 (" .. CONFIG.WIFI.HOME_NETWORK .. ")", 2)
                end
            end
        else
            print("📶 와이파이 연결 해제: " .. oldSSID)
        end
    end
end

-- ========================================
-- 텍스트 처리 유틸리티
-- ========================================

local function getSelectedText()
    local originalClipboard = hs.pasteboard.getContents()
    hs.eventtap.keyStroke({"cmd"}, "c")
    hs.timer.usleep(CONFIG.DELAYS.CLIPBOARD_WAIT)
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
        hs.eventtap.keyStroke({"cmd"}, "v")
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
    local aerospaceLocations = {"/opt/homebrew/bin/aerospace", "/usr/local/bin/aerospace", "/usr/bin/aerospace",
                                "aerospace"}

    for _, location in ipairs(aerospaceLocations) do
        local fullCommand = location .. " " .. command
        local success, handle = pcall(io.popen, fullCommand .. " 2>&1")

        if success and handle then
            local result = handle:read("*a")
            local exitCode = handle:close()

            if result and result ~= "" and not result:match("command not found") and not result:match("No such file") then
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
    local result = executeAerospaceCommand("list-windows --workspace focused --format '%{app-name}'",
        "앱 목록 조회")
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

    local status = {"🚀 Aerospace 상태 확인", "",
                    "워크스페이스 명령어: " .. (workspaceResult and "✅ 정상" or "❌ 실패"),
                    "윈도우 명령어: " .. (windowResult and "✅ 정상" or "❌ 실패")}

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

    local info = {"🚀 Aerospace 워크스페이스 정보", "", "📍 현재 워크스페이스: " .. workspace,
                  "📱 활성 앱들: " .. apps, "🖥️ 디스플레이 개수: " .. #screens}

    hs.alert.show(table.concat(info, "\n"), 4)
end

-- 시스템 정보 수집 (상태 표시용 - 블루투스/와이파이 제외)
local function getSystemInfo()
    return {
        powerMode = getCurrentPowerMode(),
        batteryLevel = hs.battery.percentage(),
        caffeineState = isCaffeineActive(),
        bttRunning = isBTTRunning(),
        screenCount = getScreenCount(),
        hasBuiltin = hasBuiltinScreen()
    }
end

-- 상태 정보 포맷팅 (블루투스/와이파이 제외)
local function formatSystemStatus(info)
    local status = {"🖥️ 시스템 통합 상태", "", "🔋 전원: " ..
        (info.powerMode == "battery" and "배터리 (" .. math.floor(info.batteryLevel) .. "%)" or "연결됨"),
                    "☕ 카페인: " .. (info.caffeineState and "✅ 활성화" or "❌ 비활성화"),
                    "🎮 BTT: " .. (info.bttRunning and "✅ 실행 중" or "❌ 종료됨"), "",
                    "🖥️ 화면 개수: " .. info.screenCount,
                    "💻 내장 화면: " .. (info.hasBuiltin and "✅ 활성화" or "❌ 비활성화"),
                    "📱 뚜껑 상태: " .. (isLidClosed and "🔒 닫힌 상태" or "🔓 열린 상태")}
    return status
end

-- 자동화 규칙 설명 추가 (핵심 규칙만)
local function addAutomationRules(status)
    local rules = {"", "💡 자동화 규칙:", "🔌 전원 연결 시:",
                   "   • 뚜껑 열림/닫힘 → 카페인 ON, BTT 실행", "🔋 배터리 모드 시:",
                   "   • 뚜껑 열림 → 카페인 OFF, BTT 실행",
                   "   • 뚜껑 닫힘 → 카페인 OFF, BTT 종료", "📶 백그라운드 자동화:",
                   "   • 와이파이 변경 → 블루투스 자동 제어"}

    for _, rule in ipairs(rules) do
        table.insert(status, rule)
    end
    return status
end

-- 빠른 상태 표시를 위한 캐시 시스템
local systemStatusCache = {
    info = nil,
    lastUpdate = 0,
    cacheDuration = 3 -- 3초간 캐시 유효
}

-- Canvas 기반 상태 창 표시 (위치 조정 가능)
local statusCanvas = nil

local function showStatusWithCanvas(statusLines)
    -- 기존 창이 있으면 닫기
    if statusCanvas then
        statusCanvas:delete()
    end

    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()

    -- 창 크기와 위치 계산 (CONFIG 값 사용)
    local windowWidth = CONFIG.UI.CANVAS_WIDTH
    local windowHeight = math.min(CONFIG.UI.CANVAS_HEIGHT_MAX, #statusLines * 20 + CONFIG.UI.PADDING * 2)
    local x = (screenFrame.w - windowWidth) / 2
    local y = screenFrame.h * CONFIG.UI.CANVAS_Y_POSITION

    -- Canvas 생성
    statusCanvas = hs.canvas.new {
        x = x,
        y = y,
        w = windowWidth,
        h = windowHeight
    }

    -- 배경
    statusCanvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = {
            alpha = 0.9,
            red = 0.1,
            green = 0.1,
            blue = 0.1
        },
        roundedRectRadii = {
            xRadius = 10,
            yRadius = 10
        }
    }

    -- 텍스트 추가
    statusCanvas[2] = {
        type = "text",
        text = table.concat(statusLines, "\n"),
        textFont = "SF Mono",
        textSize = CONFIG.UI.TEXT_SIZE,
        textColor = {
            alpha = 1,
            red = 1,
            green = 1,
            blue = 1
        },
        textAlignment = "left",
        frame = {
            x = CONFIG.UI.PADDING,
            y = CONFIG.UI.PADDING,
            w = windowWidth - (CONFIG.UI.PADDING * 2),
            h = windowHeight - (CONFIG.UI.PADDING * 2)
        }
    }

    -- 창 표시
    statusCanvas:show()

    -- CONFIG에 설정된 시간 후 자동으로 닫기
    hs.timer.doAfter(CONFIG.UI.STATUS_DISPLAY_TIME, function()
        if statusCanvas then
            statusCanvas:delete()
            statusCanvas = nil
        end
    end)
end

-- 통합 상태 표시 (성능 최적화됨)
local function showSystemStatus()
    local now = os.time()
    local info

    -- 캐시된 정보가 유효한지 확인
    if systemStatusCache.info and (now - systemStatusCache.lastUpdate) < systemStatusCache.cacheDuration then
        info = systemStatusCache.info
    else
        -- 새로운 정보 수집
        info = getSystemInfo()
        systemStatusCache.info = info
        systemStatusCache.lastUpdate = now
    end

    local status = formatSystemStatus(info)
    status = addAutomationRules(status)

    -- Canvas 기반 창 표시 (위치 조정됨)
    showStatusWithCanvas(status)
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
hs.hotkey.bind({"cmd", "ctrl"}, "u", "선택한 텍스트를 대문자로 변환", function()
    transformAndPaste(string.upper)
end)

hs.hotkey.bind({"cmd", "ctrl"}, "l", "선택한 텍스트를 소문자로 변환", function()
    transformAndPaste(string.lower)
end)

-- 케이스 변환 (개발자용)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "c", "camelCase로 변환 (예: helloWorld)", function()
    transformAndPaste(toCamelCase)
end)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "p", "PascalCase로 변환 (예: HelloWorld)", function()
    transformAndPaste(toPascalCase)
end)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "s", "snake_case로 변환 (예: hello_world)", function()
    transformAndPaste(toSnakeCase)
end)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "k", "kebab-case로 변환 (예: hello-world)", function()
    transformAndPaste(toKebabCase)
end)

-- 인코딩/디코딩
hs.hotkey.bind({"ctrl", "shift"}, "b", "Base64로 인코딩", function()
    transformAndPaste(base64Encode)
end)

hs.hotkey.bind({"ctrl", "shift", "alt"}, "b", "Base64에서 디코딩", function()
    transformAndPaste(base64Decode)
end)

hs.hotkey.bind({"ctrl", "shift"}, "u", "URL 인코딩 (퍼센트 인코딩)", function()
    transformAndPaste(urlEncode)
end)

hs.hotkey.bind({"ctrl", "shift", "alt"}, "u", "URL 디코딩", function()
    transformAndPaste(urlDecode)
end)

-- 해시 생성
hs.hotkey.bind({"ctrl", "shift"}, "m", "MD5 해시 생성", function()
    transformAndPaste(generateMD5)
end)

hs.hotkey.bind({"ctrl", "shift"}, "h", "SHA256 해시 생성", function()
    transformAndPaste(generateSHA256)
end)

-- 색상 변환
hs.hotkey.bind({"ctrl", "shift"}, "r", "HEX 색상을 RGB로 변환 (예: #ff0000 → rgb(255, 0, 0))", function()
    transformAndPaste(hexToRgb)
end)

-- 개발자 유틸리티 (생성)
hs.hotkey.bind({"cmd", "ctrl"}, "t", "ISO 타임스탬프 생성 및 클립보드 복사", generateTimestamp)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "u", "UUID 생성 및 클립보드 복사", generateUUID)
hs.hotkey.bind({"cmd", "ctrl"}, "r", "16자리 랜덤 패스워드 생성", generateRandomPassword)

-- JSON 처리
hs.hotkey.bind({"cmd", "ctrl"}, "j", "클립보드의 JSON을 예쁘게 포맷팅", formatJSON)
hs.hotkey.bind({"cmd", "ctrl"}, "m", "클립보드의 JSON을 한 줄로 압축", minifyJSON)

-- Aerospace 관련 기능 (정보 확인만)
hs.hotkey.bind({"cmd", "ctrl"}, "w", "현재 워크스페이스와 앱 정보 표시", showWorkspaceInfo)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "a", "Aerospace 전체 상태 확인", showAerospaceStatus)

-- ========================================
-- BTT & 카페인 관련 단축키
-- ========================================

-- BTT 수동 토글
hs.hotkey.bind({"cmd", "ctrl"}, "b", "BetterTouchTool 실행/종료 토글", toggleBTT)

-- 통합 상태 확인 (BTT + 카페인 + 시스템)
hs.hotkey.bind({"cmd", "ctrl", "alt"}, "s", "시스템 상태 확인 (전원, 카페인, BTT, 화면 등)",
    showSystemStatus)

-- 카페인 수동 토글
hs.hotkey.bind({"cmd", "ctrl", "alt"}, "f", "카페인 활성화/비활성화 토글 (화면 끄기 방지)",
    toggleCaffeine)

-- ========================================
-- Spoon 단축키 설정
-- ========================================

-- KSheet: 단축키 치트시트
hs.hotkey.bind({"cmd", "shift"}, "/", "시스템 전체 단축키 치트시트 표시/숨기기", function()
    if spoon.KSheet then
        spoon.KSheet:toggle()
    else
        hs.alert.show("KSheet Spoon이 로드되지 않았습니다")
    end
end)

-- HSKeybindings: Hammerspoon 단축키 표시
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "/", "Hammerspoon 단축키 목록 표시/숨기기 (이 스크립트의 단축키들)", function()
    if spoon.HSKeybindings then
        if spoon.HSKeybindings.sheetView and spoon.HSKeybindings.sheetView:hswindow() and
            spoon.HSKeybindings.sheetView:hswindow():isVisible() then
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
    hs.timer.doAfter(CONFIG.DELAYS.LID_STATE_DELAY, handleLidStateChange) -- 안정화 대기
end)
screenWatcher:start()

-- 시스템 잠들기/깨어나기 감지 시작
caffeineWatcher = hs.caffeinate.watcher.new(handleSystemStateChange)
caffeineWatcher:start()

-- 와이파이 변경 감지 시작
wifiWatcher = hs.wifi.watcher.new(function()
    hs.timer.doAfter(CONFIG.DELAYS.WIFI_STABILIZE_DELAY, handleWifiChange) -- 연결 안정화 대기
end)
wifiWatcher:start()

-- 초기 상태 설정
hs.timer.doAfter(CONFIG.DELAYS.WIFI_STABILIZE_DELAY, function()
    -- 전원 상태 초기화
    local initialMode = getCurrentPowerMode()
    handlePowerStateChange(initialMode)

    -- 뚜껑 상태 초기화
    handleLidStateChange()

    -- 와이파이 상태 초기화
    currentSSID = getCurrentSSID()
    if currentSSID then
        print("📶 초기 와이파이: " .. currentSSID)
    end
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

print("🚀 Hammerspoon 개발자 유틸리티 설정 완료!")
print("")
print("🔤 텍스트 변환:")
print("- 대문자 변환: Cmd+Ctrl+U")
print("- 소문자 변환: Cmd+Ctrl+L")
print("")
print("🐪 케이스 변환 (개발자용):")
print("- camelCase: Cmd+Ctrl+Shift+C")
print("- PascalCase: Cmd+Ctrl+Shift+P")
print("- snake_case: Cmd+Ctrl+Shift+S")
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
print("☕ 카페인 자동화:")
print("- 전원 연결 시 자동 활성화")
print("- 배터리 모드 시 자동 비활성화")
print("- 뚜껑 닫기/시스템 잠들기 시 배터리 보호")
print("- 수동 제어: Cmd+Ctrl+Alt+F")
print("")
print("🎮 BTT 자동화:")
print("- BTT 수동 토글: Cmd+Ctrl+B")
print("- 뚜껑 닫기 → BTT 종료")
print("- 뚜껑 열기 → BTT 실행")
print("- 시스템 잠들기 → BTT 종료")
print("- 시스템 깨어나기 → BTT 실행")
print("")
print("📶 와이파이 기반 블루투스 자동화:")
print("- LGWiFi_DBE9 네트워크 연결 → 블루투스 끄기")
print("- sporky 네트워크 연결 → 블루투스 켜기")
print("")
print("🧩 Spoon 플러그인:")
print("- 단축키 치트시트: Cmd+Shift+/")
print("- Hammerspoon 단축키 표시: Cmd+Ctrl+Shift+/")
print("")
print("✨ 최신 개선사항:")
print("1. 설정 상수 외부화 (CONFIG 테이블)")
print("2. blueutil 경로 캐싱으로 성능 향상")
print("3. 블루투스 상태 캐싱 (5초간 유효)")
print("4. 긴 함수들을 작은 함수로 분해")
print("5. 안전한 명령어 실행 헬퍼 함수 추가")
print("6. 네트워크별 블루투스 설정 로직 개선")
print("7. 코드 중복 제거 (DRY 원칙 적용)")
print("8. 에러 처리 및 복구 메커니즘 개선")
print("9. 하드코딩된 지연 시간을 상수로 변경")
print("10. 모듈화된 상태 표시 함수")
print("11. 캐시 무효화 로직 추가")
print("12. 유지보수성 및 가독성 대폭 향상")
