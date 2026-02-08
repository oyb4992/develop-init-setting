-- ========================================
-- DevCommander 개발자 명령어 실행기
-- ========================================
local gitManager = require("git_manager")
local portKiller = require("port_killer")
local dockerManager = require("docker_manager")

local devCommander = {}

-- DevCommander: 개발자 명령어 실행기
local function showDevCommander()
	-- 개발자 명령어 정의
	local choices = {
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
		elseif command == "포트 관리 (Port Killer)" then
			portKiller.showPortKiller()
		elseif command == "도커 관리 (Docker Dashboard)" then
			dockerManager.showDockerDashboard()
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
