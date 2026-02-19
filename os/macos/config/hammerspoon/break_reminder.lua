-- ========================================
-- Break Reminder (휴식 알림)
-- 포모도로 스타일 작업/휴식 타이머
-- ========================================
local config = require("config")
local CONFIG = config.CONFIG

local breakReminder = {}

-- 상태 변수
local timer = nil
local menubar = nil
local sleepWatcher = nil
local state = "stopped" -- stopped, working, onbreak, paused
local remainingSeconds = 0
local pausedSeconds = 0

-- 기본 설정값
local function getWorkSeconds()
	local minutes = (CONFIG.BREAK_REMINDER and CONFIG.BREAK_REMINDER.WORK_MINUTES) or 50
	return minutes * 60
end

local function getBreakSeconds()
	local minutes = (CONFIG.BREAK_REMINDER and CONFIG.BREAK_REMINDER.BREAK_MINUTES) or 10
	return minutes * 60
end

local function getAlertDuration()
	return (CONFIG.BREAK_REMINDER and CONFIG.BREAK_REMINDER.ALERT_DURATION) or 10
end

local function getAlertStyle()
	return (CONFIG.BREAK_REMINDER and CONFIG.BREAK_REMINDER.ALERT_STYLE) or {}
end

-- 통합 알림 함수 (hs.alert + hs.notify)
local function sendNotification(message, title)
	-- 1. 화면 중앙 알림 (스타일 적용)
	hs.alert.show(message, getAlertStyle(), hs.screen.mainScreen(), getAlertDuration())

	-- 2. 시스템 알림 (알림 센터)
	hs.notify.new({
		title = title or "Break Reminder",
		informativeText = message,
		soundName = "Glass",
	}):send()
end

-- 시간 포맷팅 (MM:SS)
local function formatTime(seconds)
	local mins = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", mins, secs)
end

-- 메뉴바 업데이트
local function updateMenubar()
	if not menubar then
		return
	end

	local icon = ""
	local title = ""

	if state == "working" then
		icon = "🔴"
		title = icon .. " " .. formatTime(remainingSeconds)
	elseif state == "onbreak" then
		icon = "🟢"
		title = icon .. " " .. formatTime(remainingSeconds)
	elseif state == "paused" then
		icon = "⏸️"
		title = icon .. " " .. formatTime(remainingSeconds)
	else
		title = "⏱️"
	end

	menubar:setTitle(title)
end

-- 메뉴바 클릭 메뉴
local function buildMenu()
	local items = {}

	if state == "stopped" then
		table.insert(items, {
			title = "▶️ 타이머 시작",
			fn = function()
				breakReminder.startTimer()
			end,
		})
	elseif state == "working" or state == "onbreak" then
		table.insert(items, {
			title = "⏸️ 일시정지",
			fn = function()
				breakReminder.pauseTimer()
			end,
		})
		table.insert(items, { title = "-" })
		table.insert(items, {
			title = "⏹️ 중지",
			fn = function()
				breakReminder.stopTimer()
			end,
		})
	elseif state == "paused" then
		table.insert(items, {
			title = "▶️ 재개",
			fn = function()
				breakReminder.resumeTimer()
			end,
		})
		table.insert(items, { title = "-" })
		table.insert(items, {
			title = "⏹️ 중지",
			fn = function()
				breakReminder.stopTimer()
			end,
		})
	end

	table.insert(items, { title = "-" })
	table.insert(items, {
		title = "ℹ️ 작업: " .. math.floor(getWorkSeconds() / 60) .. "분 / 휴식: " .. math.floor(
			getBreakSeconds() / 60
		) .. "분",
		disabled = true,
	})

	return items
end

-- 타이머 틱 (1초마다)
local function tick()
	if state ~= "working" and state ~= "onbreak" then
		return
	end

	remainingSeconds = remainingSeconds - 1
	updateMenubar()

	if remainingSeconds <= 0 then
		if state == "working" then
			-- 작업 시간 종료 → 휴식 시작
			sendNotification(
				"☕ 휴식 시간입니다!\n" .. math.floor(getBreakSeconds() / 60) .. "분간 쉬세요.",
				"🔴 작업 종료 / 🟢 휴식 시작"
			)
			state = "onbreak"
			remainingSeconds = getBreakSeconds()
		elseif state == "onbreak" then
			-- 휴식 시간 종료 → 작업 시작
			sendNotification(
				"🔴 작업 시간입니다!\n" .. math.floor(getWorkSeconds() / 60) .. "분간 집중하세요.",
				"🟢 휴식 종료 / 🔴 작업 시작"
			)
			state = "working"
			remainingSeconds = getWorkSeconds()
		end
		updateMenubar()
	end
end

-- 타이머 시작
function breakReminder.startTimer()
	state = "working"
	remainingSeconds = getWorkSeconds()

	if timer then
		timer:stop()
	end
	timer = hs.timer.doEvery(1, tick)

	updateMenubar()
	sendNotification("🔴 포모도로 시작! " .. math.floor(getWorkSeconds() / 60) .. "분 집중", "Pomodoro Started")
end

-- 일시정지
function breakReminder.pauseTimer()
	if state == "working" or state == "onbreak" then
		pausedSeconds = remainingSeconds
		state = "paused"
		if timer then
			timer:stop()
			timer = nil
		end
		updateMenubar()
		hs.alert.show("⏸️ 타이머 일시정지", 2)
	end
end

-- 재개
function breakReminder.resumeTimer()
	if state == "paused" then
		remainingSeconds = pausedSeconds
		state = "working"
		timer = hs.timer.doEvery(1, tick)
		updateMenubar()
		hs.alert.show("▶️ 타이머 재개", 2)
	end
end

-- 타이머 중지
function breakReminder.stopTimer()
	state = "stopped"
	remainingSeconds = 0
	if timer then
		timer:stop()
		timer = nil
	end
	updateMenubar()
	hs.alert.show("⏹️ 포모도로 중지", 2)
end

-- 토글 (단축키용)
function breakReminder.toggle()
	if state == "stopped" then
		breakReminder.startTimer()
	elseif state == "paused" then
		breakReminder.resumeTimer()
	elseif state == "working" or state == "onbreak" then
		breakReminder.pauseTimer()
	end
end

-- 모듈 초기화
function breakReminder.start()
	-- 메뉴바 아이콘 생성
	menubar = hs.menubar.new()
	if menubar then
		menubar:setTitle("⏱️")
		menubar:setMenu(buildMenu)
	end

	-- 잠자기/화면잠금 감지 → 타이머 완전 중지
	sleepWatcher = hs.caffeinate.watcher.new(function(eventType)
		if eventType == hs.caffeinate.watcher.systemWillSleep or eventType == hs.caffeinate.watcher.screensDidLock then
			if state ~= "stopped" then
				breakReminder.stopTimer()
				print("😴 잠자기/화면잠금 감지 → Break Reminder 중지")
			end
		end
	end)
	sleepWatcher:start()

	print("✔️ Break Reminder 모듈 로드됨")
end

-- 모듈 중지
function breakReminder.stop()
	if timer then
		timer:stop()
		timer = nil
	end
	if sleepWatcher then
		sleepWatcher:stop()
		sleepWatcher = nil
	end
	if menubar then
		menubar:delete()
		menubar = nil
	end
	state = "stopped"
	remainingSeconds = 0
	print("⏹️ Break Reminder 중지됨")
end

return breakReminder
