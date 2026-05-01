-- ========================================
-- Git 상태 확인 및 관리
-- ========================================
local config = require("config")
local CONFIG = config.CONFIG

local gitManager = {}

-- Git 상태 확인용 Canvas 표시 함수
local gitStatusCanvas = nil
local inputMode = nil

local function shellQuote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function showGitStatusCanvas(statusLines, displayTime)
	-- 기존 Git 상태 창이 있으면 닫기
	if gitStatusCanvas then
		gitStatusCanvas:delete()
		gitStatusCanvas = nil
	end

	-- 기존 입력 모드가 있으면 종료 (중복 실행 방지)
	if inputMode then
		inputMode:exit()
		inputMode = nil
	end

	-- 화면 선택 로직 개선
	local screen = nil

	-- 1. 현재 포커스된 창이 있는 화면 찾기
	local focusedWindow = hs.window.focusedWindow()
	if focusedWindow then
		screen = focusedWindow:screen()
	end

	-- 2. 포커스된 창이 없으면 마우스 커서가 있는 화면 사용
	if not screen then
		local mousePosition = hs.mouse.absolutePosition()
		local allScreens = hs.screen.allScreens()
		for _, s in ipairs(allScreens) do
			local frame = s:frame()
			if
				mousePosition.x >= frame.x
				and mousePosition.x < (frame.x + frame.w)
				and mousePosition.y >= frame.y
				and mousePosition.y < (frame.y + frame.h)
			then
				screen = s
				break
			end
		end
	end

	-- 3. 마지막으로 메인 화면 사용
	if not screen then
		screen = hs.screen.mainScreen()
	end

	local screenFrame = screen:frame()

	-- 페이지네이션 설정
	local LINES_PER_PAGE = 25
	local totalLines = #statusLines
	local totalPages = math.max(1, math.ceil(totalLines / LINES_PER_PAGE))
	local currentPage = 1

	-- 창 크기와 위치 계산
	local windowWidth = math.min(800, screenFrame.w * 0.8)
	local windowHeight = math.min(600, LINES_PER_PAGE * 20 + CONFIG.UI.PADDING * 3) -- 높이 조정
	local x = (screenFrame.w - windowWidth) / 2
	local y = (screenFrame.h - windowHeight) / 2

	-- Canvas 생성
	local absoluteX = screenFrame.x + x
	local absoluteY = screenFrame.y + y

	gitStatusCanvas = hs.canvas.new({
		x = absoluteX,
		y = absoluteY,
		w = windowWidth,
		h = windowHeight,
	})

	-- 1. 배경
	gitStatusCanvas[1] = {
		type = "rectangle",
		action = "fill",
		fillColor = {
			alpha = 0.95,
			red = 0.05,
			green = 0.05,
			blue = 0.05,
		},
		roundedRectRadii = {
			xRadius = 10,
			yRadius = 10,
		},
	}

	-- 2. 텍스트 (내용)
	gitStatusCanvas[2] = {
		type = "text",
		text = "",
		textFont = "SF Mono",
		textSize = 13,
		textColor = {
			hex = "#FFFFFF",
		},
		textAlignment = "left",
		frame = {
			x = CONFIG.UI.PADDING,
			y = CONFIG.UI.PADDING,
			w = windowWidth - (CONFIG.UI.PADDING * 2),
			h = windowHeight - (CONFIG.UI.PADDING * 3),
		},
	}

	-- 3. 페이지 표시 (Footer)
	gitStatusCanvas[3] = {
		type = "text",
		text = "",
		textFont = "SF Mono",
		textSize = 11,
		textColor = {
			hex = "#AAAAAA",
		},
		textAlignment = "right",
		frame = {
			x = CONFIG.UI.PADDING,
			y = windowHeight - 30,
			w = windowWidth - (CONFIG.UI.PADDING * 2),
			h = 20,
		},
	}

	-- 키보드 모달 사전 선언 (전역 변수 사용)

	local function closeCanvas()
		if gitStatusCanvas then
			gitStatusCanvas:delete()
			gitStatusCanvas = nil
		end
		if inputMode then
			inputMode:exit()
			inputMode = nil
		end
	end

	-- 페이지 렌더링 함수
	local function renderPage()
		local startIdx = (currentPage - 1) * LINES_PER_PAGE + 1
		local endIdx = math.min(totalLines, currentPage * LINES_PER_PAGE)
		local pageLines = {}

		for i = startIdx, endIdx do
			table.insert(pageLines, statusLines[i])
		end

		gitStatusCanvas[2].text = table.concat(pageLines, "\n")

		local footerText =
			string.format("Page %d / %d (←/h: Prev, →/l: Next, ESC/q: Close)", currentPage, totalPages)
		gitStatusCanvas[3].text = footerText
	end

	renderPage()
	gitStatusCanvas:show()

	-- 키보드 모달 설정
	inputMode = hs.hotkey.modal.new()

	local function nextPage()
		if currentPage < totalPages then
			currentPage = currentPage + 1
			renderPage()
		end
	end

	local function prevPage()
		if currentPage > 1 then
			currentPage = currentPage - 1
			renderPage()
		end
	end

	-- 키 바인딩
	inputMode:bind({}, "escape", closeCanvas)
	inputMode:bind({}, "q", closeCanvas)
	inputMode:bind({}, "right", nextPage)
	inputMode:bind({}, "l", nextPage)
	inputMode:bind({}, "left", prevPage)
	inputMode:bind({}, "h", prevPage)

	inputMode:enter()

	-- 자동 닫기 타이머 (displayTime이 양수일 때만 설정)
	if displayTime and displayTime > 0 then
		hs.timer.doAfter(displayTime, closeCanvas)
	end
end

-- ========================================
-- Helper Functions
-- ========================================

-- 전체 리포지토리 수집 (설정된 것 + 자동 탐색)
local function collectAllRepositories()
	local allRepos = {}
	local knownPaths = {}

	-- 1. 명시적으로 설정된 리포지토리 추가
	if CONFIG.GIT_MANAGER.REPOS then
		for _, repo in ipairs(CONFIG.GIT_MANAGER.REPOS) do
			table.insert(allRepos, repo)
			knownPaths[repo.path] = true
		end
	end

	-- 2. 자동 탐색 경로에서 리포지토리 찾기
	if CONFIG.GIT_MANAGER.SCAN_PATHS then
		for _, scanPathLink in ipairs(CONFIG.GIT_MANAGER.SCAN_PATHS) do
			-- config.lua 타입 오류 방지 (중첩 테이블 가능성 처리)
			local scanPath = scanPathLink
			if type(scanPathLink) == "table" then
				scanPath = scanPathLink[1] -- {{path}} 형태 처리
			end

			if scanPath and hs.fs.attributes(scanPath) then
				for file in hs.fs.dir(scanPath) do
					if file ~= "." and file ~= ".." then
						local fullPath = scanPath .. "/" .. file
						local gitDir = fullPath .. "/.git"

						-- .git 디렉토리가 있고, 이미 등록되지 않은 경우 추가
						if hs.fs.attributes(gitDir) and not knownPaths[fullPath] then
							table.insert(allRepos, {
								name = file,
								path = fullPath,
								branches = CONFIG.GIT_MANAGER.DEFAULT_BRANCHES,
							})
							knownPaths[fullPath] = true
						end
					end
				end
			end
		end
	end

	-- 경로순 정렬
	table.sort(allRepos, function(a, b)
		return a.path:lower() < b.path:lower()
	end)

	return allRepos
end

-- Git 상태 확인 함수 (여러 경로 지원, 브랜치 정보 포함)
local function checkGitStatus()
	-- 확인할 Git 리포지토리 경로 목록 (사용자 맞춤 설정)
	local gitPaths = collectAllRepositories()

	if #gitPaths == 0 then
		hs.alert.show("설정된 Git 리포지토리가 없습니다.")
		return
	end

	local statusLines = { "📋 Git 상태 종합 보고서", "" }
	local hasChanges = false

	for _, repo in ipairs(gitPaths) do
		local repoPath = repo.path
		local repoName = repo.name

		-- Git 리포지토리인지 확인
		local gitDir = repoPath .. "/.git"
		local attrs = hs.fs.attributes(gitDir)

		if attrs then
			-- 현재 브랜치 확인
			local quotedRepoPath = shellQuote(repoPath)
			local branchCmd = "git -C " .. quotedRepoPath .. " branch --show-current 2>/dev/null"
			local currentBranch = (hs.execute(branchCmd) or ""):gsub("\n", "")
			if currentBranch == "" then
				currentBranch = "detached HEAD"
			end

			-- Git 상태 확인
			local statusCmd = "git -C " .. quotedRepoPath .. " status --porcelain 2>/dev/null"
			local gitOutput = hs.execute(statusCmd)

			-- 문자열 결과 처리
			if gitOutput and gitOutput ~= "" then
				local changes = {}
				local modifiedCount = 0
				local addedCount = 0
				local deletedCount = 0
				local untrackedCount = 0

				for line in gitOutput:gmatch("[^\r\n]+") do
					local status = line:sub(1, 2)
					local filename = line:sub(4)

					if status:match("M") then
						modifiedCount = modifiedCount + 1
					elseif status:match("A") then
						addedCount = addedCount + 1
					elseif status:match("D") then
						deletedCount = deletedCount + 1
					elseif status:match("?") then
						untrackedCount = untrackedCount + 1
					end

					-- 처음 5개 파일만 표시
					if #changes < 5 then
						table.insert(changes, "  " .. status .. " " .. filename)
					end
				end

				hasChanges = true
				table.insert(statusLines, "📁 " .. repoName .. " (브랜치: " .. currentBranch .. ")")

				-- 변경사항 요약
				local summary = {}
				if modifiedCount > 0 then
					table.insert(summary, modifiedCount .. "개 수정")
				end
				if addedCount > 0 then
					table.insert(summary, addedCount .. "개 추가")
				end
				if deletedCount > 0 then
					table.insert(summary, deletedCount .. "개 삭제")
				end
				if untrackedCount > 0 then
					table.insert(summary, untrackedCount .. "개 미추적")
				end

				table.insert(statusLines, "  ⚠️ 변경사항: " .. table.concat(summary, ", "))

				-- 상세 변경사항 (처음 5개)
				for _, change in ipairs(changes) do
					table.insert(statusLines, change)
				end

				if #changes >= 5 and (modifiedCount + addedCount + deletedCount + untrackedCount) > 5 then
					table.insert(
						statusLines,
						"  ... 및 "
							.. ((modifiedCount + addedCount + deletedCount + untrackedCount) - 5)
							.. "개 추가 변경사항"
					)
				end
			else
				table.insert(statusLines, "✅ " .. repoName .. " (브랜치: " .. currentBranch .. ")")
				table.insert(statusLines, "  깨끗한 상태 - 변경사항 없음")
			end
		else
			table.insert(statusLines, "❌ " .. repoName)
			table.insert(statusLines, "  Git 리포지토리가 아님 또는 접근 불가")
			table.insert(statusLines, "  경로: " .. repoPath)
		end

		table.insert(statusLines, "") -- 빈 줄 추가
	end

	-- 요약 정보 추가
	if hasChanges then
		table.insert(statusLines, "🚨 주의: 커밋하지 않은 변경사항이 있습니다!")
	else
		table.insert(statusLines, "✨ 모든 리포지토리가 깨끗한 상태입니다.")
	end

	table.insert(statusLines, "")
	table.insert(statusLines, "🔑 ESC 키를 눌러 창을 닫을 수 있습니다.")

	-- Canvas로 표시
	showGitStatusCanvas(statusLines, CONFIG.UI.STATUS_DISPLAY_TIME)
end

-- Git 자동 업데이트 스케줄러
-- ========================================

-- 리포지토리 업데이트 실행
local function updateRepositories()
	local repos = collectAllRepositories()
	local lastUpdate = hs.settings.get("git_manager.last_update") or 0
	local nextRun = hs.settings.get("git_manager.next_run") or 0
	local statusLines = { "  📋 Git 주간 정기 업데이트 알림", "" }
	table.insert(
		statusLines,
		"  ⚠️ 마지막 알림 일시: "
			.. os.date("%Y-%m-%d %H:%M:%S", lastUpdate)
			.. ", ✨ 다음 알림 일시: "
			.. os.date("%Y-%m-%d %H:%M:%S", nextRun)
	)
	table.insert(statusLines, "") -- 빈 줄 추가

	for _, repo in ipairs(repos) do
		local repoPath = repo.path
		local repoName = repo.name

		-- Repo 존재 확인
		if hs.fs.attributes(repoPath) then
			table.insert(statusLines, "    📁 경로: " .. repoPath)
		end
		--         table.insert(statusLines, "") -- 빈 줄 추가
	end

	showGitStatusCanvas(statusLines, CONFIG.UI.STATUS_DISPLAY_TIME)
	-- 마지막 업데이트 알림 시간 저장
	hs.settings.set("git_manager.last_update", os.time())
end

-- 다음 스케줄 예약
local updateTimer = nil
local function scheduleNextUpdate()
	local schedule = CONFIG.GIT_MANAGER.SCHEDULE
	local now = os.time()
	local nowDate = os.date("*t", now)

	-- 이번 주 타겟 시간 계산
	-- 일단 "오늘" 날짜에 타겟 시간(시/분)을 적용
	local targetTimeToday = os.time({
		year = nowDate.year,
		month = nowDate.month,
		day = nowDate.day,
		hour = schedule.HOUR,
		min = schedule.MINUTE,
		sec = 0,
	})

	-- 요일 차이 계산 (일=1 ~ 토=7)
	local diffDays = schedule.DAY - nowDate.wday

	-- "이번 주"의 타겟 시간
	local thisWeekTarget = targetTimeToday + (diffDays * 24 * 60 * 60)

	local nextRun = nil
	local lastUpdate = hs.settings.get("git_manager.last_update") or 0

	-- 로직:
	-- 1. 현재 시간이 이번 주 타겟 시간보다 늦었음 (이미 지남)
	if now > thisWeekTarget then
		-- 1-1. 근데 마지막 업데이트가 이번 주 타겟 시간보다 이전임 (안 돌았음)
		if lastUpdate < thisWeekTarget then
			print("Git Manager: 예정된 업데이트 시간을 놓쳤습니다. 즉시 실행합니다.")
			-- 즉시 실행 (1초 후)
			if updateTimer then
				updateTimer:stop()
			end
			updateTimer = hs.timer.doAfter(1, function()
				updateRepositories()
				scheduleNextUpdate()
			end)
			return
		else
			-- 1-2. 이미 돌았음 -> 다음 주 예약
			nextRun = thisWeekTarget + (7 * 24 * 60 * 60)
		end
	else
		-- 2. 아직 시간 안 됨 -> 이번 주 타겟 시간에 예약
		nextRun = thisWeekTarget
	end

	-- 다음 업데이트 알림 시간 저장
	hs.settings.set("git_manager.next_run", nextRun)
	local timeUntilNextRun = nextRun - now

	print(
		string.format(
			"📋 Git Manager: 다음 업데이트 알림은 %s에 실행됩니다. (약 %.1f시간 후)",
			os.date("%Y-%m-%d %H:%M:%S", nextRun),
			timeUntilNextRun / 3600
		)
	)

	if updateTimer then
		updateTimer:stop()
	end

	updateTimer = hs.timer.doAfter(timeUntilNextRun, function()
		updateRepositories()
		scheduleNextUpdate() -- 실행 후 다음 스케줄 예약
	end)
end

local function start()
	-- 리포지토리 설정 확인
	local hasRepos = CONFIG.GIT_MANAGER.REPOS and #CONFIG.GIT_MANAGER.REPOS > 0
	local hasScanPaths = CONFIG.GIT_MANAGER.SCAN_PATHS and #CONFIG.GIT_MANAGER.SCAN_PATHS > 0

	if not (hasRepos or hasScanPaths) then
		print("Git Manager: 설정된 리포지토리 경로가 없어 스케줄러를 시작하지 않습니다.")
		return
	end

	print("Git Manager: 스케줄러 시작됨")
	scheduleNextUpdate()
end

-- Export functions
gitManager.checkGitStatus = checkGitStatus
gitManager.start = start
gitManager.updateRepositories = updateRepositories -- 수동 실행용

return gitManager
