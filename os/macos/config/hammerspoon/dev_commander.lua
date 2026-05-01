-- ========================================
-- DevCommander 개발자 명령어 실행기
-- ========================================
local gitManager = require("git_manager")
local portKiller = require("port_killer")
local dockerManager = require("docker_manager")

local devCommander = {}

-- ========================================
-- 유틸리티 함수
-- ========================================

-- UUID v4 생성
local function generateUUID()
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	return string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
		return string.format("%x", v)
	end)
end

-- 랜덤 문자열 생성
local function generateRandomString(length)
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local result = {}
	for i = 1, length do
		local idx = math.random(1, #chars)
		table.insert(result, chars:sub(idx, idx))
	end
	return table.concat(result)
end

-- 클립보드에 복사 + 알림
local function copyToClipboard(text, label)
	hs.pasteboard.setContents(text)
	hs.alert.show("📋 " .. label .. " 복사됨:\n" .. text, 3)
end

-- JSON Pretty Print
local function jsonPrettify(str)
	local decodeOk, decoded = pcall(hs.json.decode, str)
	if not decodeOk or decoded == nil then
		return nil, decoded or "invalid JSON"
	end

	local encodeOk, encoded = pcall(hs.json.encode, decoded, true)
	if not encodeOk then
		return nil, encoded
	end
	return encoded
end

-- JSON Minify
local function jsonMinify(str)
	local decodeOk, decoded = pcall(hs.json.decode, str)
	if not decodeOk or decoded == nil then
		return nil, decoded or "invalid JSON"
	end

	local encodeOk, encoded = pcall(hs.json.encode, decoded, false)
	if not encodeOk then
		return nil, encoded
	end
	return encoded
end

-- ========================================
-- 명령어 핸들러
-- ========================================

local function handleCommand(command)
	-- 기존 명령어
	if command == "Git 상태 확인" then
		gitManager.checkGitStatus()
	elseif command == "Dock 재시작" then
		hs.execute("killall Dock")
		hs.alert.show("🔄 Dock 재시작됨", 2)
	elseif command == "포트 관리 (Port Killer)" then
		portKiller.showPortKiller()
	elseif command == "도커 관리 (Docker Dashboard)" then
		dockerManager.showDockerDashboard()

	-- UUID/랜덤 문자열 생성
	elseif command == "UUID 생성" then
		math.randomseed(os.time())
		copyToClipboard(generateUUID(), "UUID")
	elseif command == "랜덤 문자열 생성 (32자)" then
		math.randomseed(os.time())
		copyToClipboard(generateRandomString(32), "랜덤 문자열")

	-- JSON 포맷터
	elseif command == "JSON 정렬 (Pretty Print)" then
		local clip = hs.pasteboard.getContents()
		if not clip or clip == "" then
			hs.alert.show("⚠️ 클립보드가 비어있습니다", 2)
			return
		end
		local pretty, err = jsonPrettify(clip)
		if pretty then
			hs.pasteboard.setContents(pretty)
			hs.alert.show("✅ JSON 정렬 완료 → 클립보드 복사됨", 3)
		else
			hs.alert.show("❌ JSON 파싱 실패\n" .. tostring(err), 4)
		end
	elseif command == "JSON 압축 (Minify)" then
		local clip = hs.pasteboard.getContents()
		if not clip or clip == "" then
			hs.alert.show("⚠️ 클립보드가 비어있습니다", 2)
			return
		end
		local mini = jsonMinify(clip)
		if mini then
			hs.pasteboard.setContents(mini)
			hs.alert.show("✅ JSON 압축 완료 → 클립보드 복사됨", 3)
		else
			hs.alert.show("❌ JSON 파싱 실패", 3)
		end

	-- 개발 캐시 정리
	elseif command == "Gradle 캐시 정리" then
		hs.execute("rm -rf ~/.gradle/caches/build-cache-*", true)
		hs.alert.show("🧹 Gradle 빌드 캐시 정리됨", 3)
	elseif command == "npm 캐시 정리" then
		hs.execute("npm cache clean --force 2>&1", true)
		hs.alert.show("🧹 npm 캐시 정리됨", 3)
	elseif command == "DNS 캐시 플러시" then
		hs.execute("sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder 2>&1", true)
		hs.alert.show("🧹 DNS 캐시 플러시됨", 3)

	-- 네트워크 유틸리티
	elseif command == "IP 주소 확인" then
		local internalIP = hs.execute("ipconfig getifaddr en0 2>/dev/null || echo '연결 안 됨'"):gsub("%s+$", "")
		local externalIP = hs.execute("curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo '확인 실패'")
			:gsub("%s+$", "")
		local info = "🏠 내부 IP: " .. internalIP .. "\n🌐 외부 IP: " .. externalIP
		hs.alert.show(info, 5)
		hs.pasteboard.setContents("내부: " .. internalIP .. " / 외부: " .. externalIP)

	-- 타임스탬프 변환
	elseif command == "현재 Unix 타임스탬프 복사" then
		local timestamp = tostring(os.time())
		copyToClipboard(timestamp, "Unix 타임스탬프")
	elseif command == "클립보드 타임스탬프 → 날짜 변환" then
		local clip = hs.pasteboard.getContents()
		if not clip then
			hs.alert.show("⚠️ 클립보드가 비어있습니다", 2)
			return
		end
		local ts = tonumber(clip:match("%d+"))
		if not ts then
			hs.alert.show("❌ 유효한 타임스탬프가 아닙니다: " .. clip, 3)
			return
		end
		-- 10자리(초) / 13자리(밀리초) 자동 감지
		if ts > 9999999999 then
			ts = math.floor(ts / 1000)
		end
		local dateStr = os.date("%Y-%m-%d %H:%M:%S", ts)
		copyToClipboard(dateStr, "변환된 날짜")
	end
end

-- ========================================
-- 메인 선택기
-- ========================================

local function showDevCommander()
	local choices = {
		-- 기존 명령어
		{
			text = "Git 상태 확인",
			subText = "현재 디렉토리의 Git 변경사항 확인",
		},
		{
			text = "포트 관리 (Port Killer)",
			subText = "실행 중인 포트(3000, 8080 등) 확인 및 프로세스 종료",
		},
		{
			text = "도커 관리 (Docker Dashboard)",
			subText = "도커 컨테이너 상태 확인 및 제어 (Start/Stop/Logs)",
		},
		{
			text = "Dock 재시작",
			subText = "killall Dock - Dock 프로세스 재시작",
		},
		-- UUID / 랜덤 문자열
		{
			text = "UUID 생성",
			subText = "UUID v4 생성 → 클립보드 복사",
		},
		{
			text = "랜덤 문자열 생성 (32자)",
			subText = "영문+숫자 32자 랜덤 문자열 → 클립보드 복사",
		},
		-- JSON 포맷터
		{
			text = "JSON 정렬 (Pretty Print)",
			subText = "클립보드의 JSON을 보기 좋게 정렬 → 클립보드 복사",
		},
		{
			text = "JSON 압축 (Minify)",
			subText = "클립보드의 JSON을 한 줄로 압축 → 클립보드 복사",
		},
		-- 개발 캐시 정리
		{
			text = "Gradle 캐시 정리",
			subText = "~/.gradle/caches/build-cache-* 삭제",
		},
		{
			text = "npm 캐시 정리",
			subText = "npm cache clean --force 실행",
		},
		{
			text = "DNS 캐시 플러시",
			subText = "macOS DNS 캐시 초기화 (sudo 필요)",
		},
		-- 네트워크 유틸리티
		{
			text = "IP 주소 확인",
			subText = "내부 IP + 외부 IP 확인 → 클립보드 복사",
		},
		-- 타임스탬프 변환
		{
			text = "현재 Unix 타임스탬프 복사",
			subText = "현재 시각의 Unix 타임스탬프 → 클립보드 복사",
		},
		{
			text = "클립보드 타임스탬프 → 날짜 변환",
			subText = "클립보드의 숫자를 사람이 읽을 수 있는 날짜로 변환 (초/밀리초 자동 감지)",
		},
	}

	local chooser = hs.chooser.new(function(selectedItem)
		if not selectedItem then
			return
		end
		handleCommand(selectedItem.text)
	end)

	chooser:choices(choices)
	chooser:searchSubText(true)
	chooser:placeholderText("개발자 명령어 검색...")
	chooser:show()
end

-- Export functions
devCommander.showDevCommander = showDevCommander

return devCommander
