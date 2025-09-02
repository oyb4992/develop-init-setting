-- ========================================
-- DevCommander 개발자 명령어 실행기
-- ========================================

local gitManager = require("git_manager")

local devCommander = {}

-- Aerospace 단축키 치트시트 표시 (동기 방식으로 변경)
local function showAerospaceCheatsheet()
	hs.alert.show("Aerospace 데이터 로드 중...", 0.5) -- 0.5초간 표시

	-- 동기 방식: 콜백 함수 없이 실행하여 결과를 직접 변수에 저장
	local stdOut = hs.execute("/opt/homebrew/bin/aerospace config --get mode --json")

	-- 명령어 실행 실패 또는 결과 없음 확인
	if stdOut == nil or stdOut == "" then
		hs.alert.show("Aerospace config 로드 실패: 명령어가 출력을 반환하지 않았습니다.")
		return
	end

	-- JSON 파싱
	local success, data = pcall(hs.json.decode, stdOut)
	if not success or type(data) ~= "table" then
		hs.alert.show("JSON 파싱 실패:\n" .. (data or "내용 없음"))
		return
	end

	local modes = data
	if not modes or type(modes) ~= "table" then
		hs.alert.show("로드된 데이터가 유효한 모드 객체가 아닙니다.")
		return
	end

	-- 모드 목록을 최상위 메뉴로 구성
	local rootBindings = {}
	for modeName, modeData in pairs(modes) do
		if modeData.binding then
			rootBindings[modeName] = { binding = modeData.binding, isMode = true }
		end
	end

	local function displayLevel(currentBindings, path)
		path = path or {}
		local choices = {}

		if #path > 0 then
			table.insert(choices, { text = "↩️ 뒤로가기", isBack = true })
		end

		for key, value in pairs(currentBindings) do
			local choice = { text = key }
			if type(value) == "table" then
				if value.isMode then
					choice.subText = "▶️ 모드 진입"
					choice.bindings = value.binding
				elseif value.cmd then
					choice.subText = value.cmd
				elseif value.binding then
					choice.subText = "▶️ 하위 메뉴"
					choice.bindings = value.binding
				else
					choice.subText = "기타 명령어"
				end
			else
				choice.subText = value
			end
			table.insert(choices, choice)
		end

		-- 값(subText)을 기준으로 선택 목록 정렬
		table.sort(choices, function(a, b)
			if a.isBack then
				return true
			end
			if b.isBack then
				return false
			end
			return (a.subText or "") < (b.subText or "")
		end)

		local chooser = hs.chooser.new(function(selected)
			if not selected then
				return
			end

			if selected.isBack then
				local prevBindings = table.remove(path)
				displayLevel(prevBindings, path)
			elseif selected.bindings then
				table.insert(path, currentBindings)
				displayLevel(selected.bindings, path)
			else
				hs.alert.show(selected.text .. " : " .. selected.subText)
			end
		end)

		chooser:choices(choices)
		chooser:searchSubText(true)
		chooser:placeholderText("Aerospace 단축키 검색...")
		chooser:show()
	end

	displayLevel(rootBindings, {})
end

-- DevCommander: 개발자 명령어 실행기
local function showDevCommander()
	-- 개발자 명령어 정의
	local choices = {
		{
			text = "Aerospace 단축키 치트시트",
			subText = "Aerospace 단축키 및 모드 확인",
		},
		{
			text = "Git 상태 확인",
			subText = "현재 디렉토리의 Git 변경사항 확인",
		},
		{
			text = "Dock 재시작",
			subText = "killall Dock - Dock 프로세스 재시작",
		},
	}

	-- 선택기 생성 및 설정
	local chooser = hs.chooser.new(function(selectedItem)
		if not selectedItem then
			return
		end

		local command = selectedItem.text
		if command == "Git 상태 확인" then
			gitManager.checkGitStatus()
		elseif command == "Dock 재시작" then
			hs.execute("killall Dock")
			hs.alert.show("Dock 재시작됨", 2)
		elseif command == "Aerospace 단축키 치트시트" then
			showAerospaceCheatsheet()
		end
	end)

	chooser:choices(choices)
	chooser:searchSubText(true)
	chooser:placeholderText("개발자 명령어 검색...")
	chooser:show()
end

-- Export functions
devCommander.showDevCommander = showDevCommander

return devCommander
