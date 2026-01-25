local M = {}
local log = hs.logger.new('DockerManager', 'info')

-- Docker 명령어 실행 헬퍼
local function dockerExec(cmd)
    -- Docker Path 설정 (Homebrew 등으로 설치된 경로)
    local dockerPath = "/opt/homebrew/bin/docker" -- M1/M2 Mac 기준, 필요시 수정
    return hs.execute(dockerPath .. " " .. cmd)
end

-- 컨테이너 목록 가져오기
function M.getContainers()
    -- Format: ID|Names|Image|Status|Ports
    local cmd = "ps -a --format \"{{.ID}}|{{.Names}}|{{.Image}}|{{.Status}}|{{.Ports}}\""
    local output = dockerExec(cmd)

    local containers = {}
    if output then
        for line in output:gmatch("[^\r\n]+") do
            local id, name, image, status, ports = line:match("^(.*)|(.*)|(.*)|(.*)|(.*)$")
            if id then
                local icon = "📦"
                if status:match("^Up") then
                    icon = "🟢"
                elseif status:match("^Exited") then
                    icon = "🔴"
                end

                table.insert(containers, {
                    text = string.format("%s %s (%s)", icon, name, image),
                    subText = string.format("Status: %s | Ports: %s", status, ports),
                    id = id,
                    name = name,
                    status = status
                })
            end
        end
    end
    return containers
end

-- 컨테이너 액션 처리
local function performAction(action, containerId, containerName)
    local cmd = ""
    local msg = ""

    if action == "start" then
        cmd = "start " .. containerId
        msg = "🚀 시작됨: " .. containerName
    elseif action == "stop" then
        cmd = "stop " .. containerId
        msg = "🛑 중지됨: " .. containerName
    elseif action == "restart" then
        cmd = "restart " .. containerId
        msg = "🔄 재시작됨: " .. containerName
    elseif action == "logs" then
        -- iTerm2 또는 터미널에서 로그 보기
        local script = string.format(
            'tell application "iTerm" to create window with default profile command "/opt/homebrew/bin/docker logs -f %s"',
            containerId)
        hs.osascript.applescript(script)
        return
    elseif action == "shell" then
        -- 컨테이너 쉘 접속
        local script = string.format(
            'tell application "iTerm" to create window with default profile command "/opt/homebrew/bin/docker exec -it %s /bin/sh"',
            containerId)
        hs.osascript.applescript(script)
        return
    end

    if cmd ~= "" then
        hs.alert.show("처리 중: " .. containerName .. " ...")
        local result = dockerExec(cmd)
        -- Docker start/stop 등은 성공 시 컨테이너 ID를 반환함
        if result then
            hs.alert.show(msg)
        else
            hs.alert.show("❌ 실패")
        end
    end
end

-- 액션 선택 메뉴 표시
local function showActions(container)
    local choices = {{
        text = "▶️ Start",
        subText = "컨테이너 시작",
        action = "start"
    }, {
        text = "⏹ Stop",
        subText = "컨테이너 중지",
        action = "stop"
    }, {
        text = "🔄 Restart",
        subText = "컨테이너 재시작",
        action = "restart"
    }, {
        text = "📜 Logs",
        subText = "새 창에서 로그 보기 (-f)",
        action = "logs"
    }, {
        text = "🐚 Shell",
        subText = "컨테이너 쉘 접속 (/bin/sh)",
        action = "shell"
    }, {
        text = "↩️ Back",
        subText = "목록으로 돌아가기",
        action = "back"
    }}

    local chooser = hs.chooser.new(function(selected)
        if not selected then
            return
        end

        if selected.action == "back" then
            M.showDockerDashboard()
        else
            performAction(selected.action, container.id, container.name)
        end
    end)

    chooser:choices(choices)
    chooser:placeholderText(string.format("Action for %s (%s)", container.name, container.id))
    chooser:show()
end

-- Docker Dashboard UI 표시
function M.showDockerDashboard()
    hs.alert.show("Docker 컨테이너 조회 중...", 0.5)
    local choices = M.getContainers()

    if #choices == 0 then
        hs.alert.show("컨테이너가 없거나 Docker가 실행 중이지 않습니다.")
        return
    end

    local chooser = hs.chooser.new(function(selected)
        if not selected then
            return
        end
        showActions(selected)
    end)

    chooser:choices(choices)
    chooser:searchSubText(true)
    chooser:placeholderText("관리할 컨테이너 선택...")
    chooser:show()
end

return M
