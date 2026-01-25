local M = {}
local log = hs.logger.new('PortKiller', 'info')

-- lsof 명령어를 사용하여 리스닝 중인 포트 목록 가져오기
function M.getListeningPorts()
    -- -iTCP: TCP 포트만, -sTCP:LISTEN: 리스닝 중인 상태만, -P: 포트 번호 그대로, -n: 호스트 이름 변환 안 함
    local cmd = "lsof -iTCP -sTCP:LISTEN -P -n | awk 'NR>1 {print $1 \"|\" $2 \"|\" $3 \"|\" $9}'"
    local output = hs.execute(cmd)

    local ports = {}
    if output then
        for line in output:gmatch("[^\r\n]+") do
            local command, pid, user, address = line:match("^(.*)|(.*)|(.*)|(.*)$")
            if command and pid and address then
                -- 주소에서 포트 추출 (예: *:3000 -> 3000, 127.0.0.1:8080 -> 8080)
                local port = address:match(":(%d+)$")
                if port then
                    table.insert(ports, {
                        text = string.format("[:%s] %s", port, command),
                        subText = string.format("PID: %s | User: %s | Address: %s", pid, user, address),
                        pid = pid,
                        port = port,
                        command = command
                    })
                end
            end
        end
    end

    -- 포트 번호 순으로 정렬
    table.sort(ports, function(a, b)
        return tonumber(a.port) < tonumber(b.port)
    end)

    return ports
end

-- 포트 킬러 UI 표시
function M.showPortKiller()
    local choices = M.getListeningPorts()

    if #choices == 0 then
        hs.alert.show("리스닝 중인 포트가 없습니다.")
        return
    end

    local chooser = hs.chooser.new(function(selected)
        if not selected then
            return
        end

        local pid = selected.pid
        local port = selected.port
        local cmd = selected.command

        hs.alert.show(string.format("포트 %s (%s) 종료 중...", port, cmd))

        -- 프로세스 강제 종료 (kill -9)
        local result = hs.execute("kill -9 " .. pid)
        if result then
            hs.alert.show(string.format("✅ 포트 %s (PID: %s) 종료 완료", port, pid))
        else
            hs.alert.show("❌ 종료 실패")
        end
    end)

    chooser:choices(choices)
    chooser:searchSubText(true)
    chooser:placeholderText("종료할 포트 또는 프로세스 선택...")
    chooser:show()
end

return M
