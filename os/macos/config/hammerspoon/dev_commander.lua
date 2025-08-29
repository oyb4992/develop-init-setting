-- ========================================
-- DevCommander 개발자 명령어 실행기
-- ========================================

local config = require("config")
local gitManager = require("git_manager")
local CONFIG = config.CONFIG

local devCommander = {}

-- 백그라운드에서 실행 중인 yarn 작업들을 추적
local runningYarnTasks = {}

-- Homebrew 업데이트 결과 표시용 Canvas 함수
local brewUpdateCanvas = nil

local function showBrewUpdateCanvas(statusLines, displayTime)
    -- 기존 Homebrew 업데이트 창이 있으면 닫기
    if brewUpdateCanvas then
        brewUpdateCanvas:delete()
        brewUpdateCanvas = nil
    end

    -- 화면 선택 로직 (Git Canvas와 동일)
    local screen = nil
    local focusedWindow = hs.window.focusedWindow()
    if focusedWindow then
        screen = focusedWindow:screen()
    end

    if not screen then
        local mousePosition = hs.mouse.absolutePosition()
        local allScreens = hs.screen.allScreens()
        for _, s in ipairs(allScreens) do
            local frame = s:frame()
            if mousePosition.x >= frame.x and mousePosition.x < (frame.x + frame.w) and mousePosition.y >= frame.y and
                mousePosition.y < (frame.y + frame.h) then
                screen = s
                break
            end
        end
    end

    if not screen then
        screen = hs.screen.mainScreen()
    end

    local screenFrame = screen:frame()

    -- 창 크기와 위치 계산 (더 큰 창으로 설정)
    local windowWidth = math.min(900, screenFrame.w * 0.85)
    local windowHeight = math.min(700, #statusLines * 20 + CONFIG.UI.PADDING * 2)
    local x = (screenFrame.w - windowWidth) / 2
    local y = (screenFrame.h - windowHeight) / 2

    -- Canvas 생성
    local absoluteX = screenFrame.x + x
    local absoluteY = screenFrame.y + y

    brewUpdateCanvas = hs.canvas.new({
        x = absoluteX,
        y = absoluteY,
        w = windowWidth,
        h = windowHeight
    })

    -- 배경
    brewUpdateCanvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = {
            alpha = 0.95,
            red = 0.02,
            green = 0.08,
            blue = 0.02
        },
        roundedRectRadii = {
            xRadius = 10,
            yRadius = 10
        }
    }

    -- 텍스트 추가
    brewUpdateCanvas[2] = {
        type = "text",
        text = table.concat(statusLines, "\n"),
        textFont = "SF Mono",
        textSize = 12,
        textColor = {
            alpha = 1,
            red = 0.9,
            green = 1,
            blue = 0.9
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
    brewUpdateCanvas:show()

    -- ESC 키 핸들러 등록
    local escHandler
    escHandler = hs.hotkey.bind({}, "escape", function()
        if brewUpdateCanvas then
            brewUpdateCanvas:delete()
            brewUpdateCanvas = nil
            if escHandler then
                escHandler:delete()
                escHandler = nil
            end
        end
    end)

    -- 지정된 시간 후 자동으로 닫기
    hs.timer.doAfter(displayTime, function()
        if brewUpdateCanvas then
            brewUpdateCanvas:delete()
            brewUpdateCanvas = nil
            if escHandler then
                escHandler:delete()
            end
        end
    end)
end

-- DevCommander: 개발자 명령어 실행기
local function showDevCommander()
    -- 개발자 명령어 정의
    local choices = {{
        text = "Homebrew 업데이트",
        subText = "brew update && brew upgrade"
    }, {
        text = "Git 상태 확인",
        subText = "현재 디렉토리의 Git 변경사항 확인"
    }, {
        text = "Docker Compose 시작",
        subText = "특정 경로에서 docker-compose up -d 실행"
    }, {
        text = "Docker Compose 중지",
        subText = "특정 경로에서 docker-compose stop 실행"
    }, {
        text = "Yarn 백그라운드 실행",
        subText = "특정 프로젝트에서 yarn run 스크립트를 백그라운드로 실행"
    }, {
        text = "Yarn 백그라운드 종료",
        subText = "백그라운드에서 실행 중인 yarn 작업 종료"
    }, {
        text = "Brew 서비스 시작",
        subText = "특정 brew service 시작"
    }, {
        text = "Brew 서비스 종료",
        subText = "특정 brew service 종료"
    }, {
        text = "Docker 이미지 정리",
        subText = "사용하지 않는 Docker 이미지 제거"
    }, {
        text = "Node 모듈 캐시 정리",
        subText = "npm cache clean --force"
    }, {
        text = "Dock 재시작",
        subText = "killall Dock - Dock 프로세스 재시작"
    }, {
        text = "화면 즉시 잠금",
        subText = "pmset displaysleepnow"
    }}

    -- 선택기 생성 및 설정
    local chooser = hs.chooser.new(function(selectedItem)
        if not selectedItem then
            return
        end

        local command = selectedItem.text
        if command == "Docker 이미지 정리" then
            hs.alert.show("Docker 이미지 정리 시작...", 2)
            hs.task.new("/opt/homebrew/bin/docker", function(exitCode, stdOut, stdErr)
                if exitCode == 0 then
                    hs.alert.show("✅ Docker 이미지 정리 완료", 3)
                else
                    hs.alert.show("❌ Docker 이미지 정리 실패", 3)
                end
            end, {"image", "prune", "-f"}):start()
        elseif command == "Node 모듈 캐시 정리" then
            hs.alert.show("npm 캐시 정리 시작...", 2)
            hs.task.new("/usr/bin/npm", function(exitCode, stdOut, stdErr)
                if exitCode == 0 then
                    hs.alert.show("✅ npm 캐시 정리 완료", 3)
                else
                    hs.alert.show("❌ npm 캐시 정리 실패", 3)
                end
            end, {"cache", "clean", "--force"}):start()
        elseif command == "Homebrew 업데이트" then
            hs.alert.show("Homebrew 업데이트 시작...", 2)

            -- 먼저 brew update 실행
            hs.task.new("/opt/homebrew/bin/brew", function(updateExitCode, updateStdOut, updateStdErr)
                if updateExitCode == 0 then
                    -- update 성공 후 upgrade 실행하여 실제 업데이트 내역 확인
                    hs.task.new("/opt/homebrew/bin/brew", function(upgradeExitCode, upgradeStdOut, upgradeStdErr)
                        local statusLines = {"🍺 Homebrew 업데이트 결과", ""}

                        if upgradeExitCode == 0 then
                            hs.alert.show("✅ Homebrew 업데이트 완료", 2)

                            -- 업데이트된 패키지가 있는지 확인
                            if upgradeStdOut and upgradeStdOut:len() > 10 then
                                table.insert(statusLines,
                                    "✅ 업데이트 완료! 다음 패키지들이 업데이트되었습니다:")
                                table.insert(statusLines, "")

                                -- 업그레이드 출력 파싱
                                local updatedPackages = {}
                                local lines = {}
                                for line in upgradeStdOut:gmatch("[^\r\n]+") do
                                    table.insert(lines, line)
                                end

                                -- 주요 정보만 추출하여 표시
                                local inUpgradeSection = false
                                for _, line in ipairs(lines) do
                                    if line:match("Upgrading") or line:match("Installing") then
                                        inUpgradeSection = true
                                        local packageInfo = line:gsub("==> ", "📦 ")
                                        table.insert(statusLines, packageInfo)
                                    elseif line:match("^🍺") or line:match("Summary") then
                                        inUpgradeSection = false
                                    elseif inUpgradeSection and line:match("->") then
                                        -- 버전 정보가 있는 라인
                                        table.insert(statusLines, "   " .. line)
                                    elseif line:match("bottles") and line:match("downloaded") then
                                        -- 다운로드 정보
                                        table.insert(statusLines, "📥 " .. line)
                                    elseif line:match("Installed") or line:match("Upgraded") then
                                        -- 설치/업그레이드 완료 정보
                                        table.insert(statusLines, "✅ " .. line)
                                    end
                                end

                                -- 업데이트된 패키지 수 계산
                                local upgradeCount = 0
                                for line in upgradeStdOut:gmatch("[^\r\n]+") do
                                    if line:match("==> Upgrading") then
                                        upgradeCount = upgradeCount + 1
                                    end
                                end

                                if upgradeCount > 0 then
                                    table.insert(statusLines, "")
                                    table.insert(statusLines, "📊 총 " .. upgradeCount ..
                                        "개 패키지가 업데이트되었습니다.")
                                end
                            else
                                table.insert(statusLines, "ℹ️ 이미 모든 패키지가 최신 버전입니다.")
                                table.insert(statusLines, "업데이트할 패키지가 없습니다.")
                            end
                        else
                            hs.alert.show("❌ Homebrew 업데이트 실패", 3)
                            table.insert(statusLines, "❌ 업데이트 실패")
                            table.insert(statusLines, "")

                            if upgradeStdErr and upgradeStdErr:len() > 0 then
                                table.insert(statusLines, "오류 내용:")
                                for line in upgradeStdErr:gmatch("[^\r\n]+") do
                                    table.insert(statusLines, "  " .. line)
                                end
                            end
                        end

                        table.insert(statusLines, "")
                        table.insert(statusLines, "🔑 ESC 키를 눌러 창을 닫을 수 있습니다.")

                        -- Canvas로 결과 표시
                        showBrewUpdateCanvas(statusLines, CONFIG.UI.STATUS_DISPLAY_TIME)
                    end, {"upgrade"}):start()
                else
                    hs.alert.show("❌ Homebrew update 실패", 3)
                end
            end, {"update"}):start()
        elseif command == "Git 상태 확인" then
            gitManager.checkGitStatus()
        elseif command == "Dock 재시작" then
            hs.execute("killall Dock")
            hs.alert.show("Dock 재시작됨", 2)
        elseif command == "화면 즉시 잠금" then
            hs.execute("pmset displaysleepnow")
        elseif command == "Brew 서비스 시작" then
            -- 사용 가능한 brew 서비스 목록 가져오기
            hs.task.new("/opt/homebrew/bin/brew", function(exitCode, stdOut, stdErr)
                if exitCode == 0 then
                    local services = {}
                    for line in stdOut:gmatch("[^\r\n]+") do
                        local serviceName = line:match("^([%w%-%.]+)")
                        if serviceName and not line:match("^Name") and serviceName ~= "" then
                            table.insert(services, {
                                text = serviceName,
                                subText = "brew services start " .. serviceName
                            })
                        end
                    end

                    if #services > 0 then
                        local serviceChooser = hs.chooser.new(function(selectedService)
                            if selectedService then
                                hs.alert.show("서비스 시작 중: " .. selectedService.text, 2)
                                hs.task.new("/opt/homebrew/bin/brew", function(startExitCode, startStdOut, startStdErr)
                                    if startExitCode == 0 then
                                        hs.alert.show("✅ " .. selectedService.text .. " 시작됨", 3)
                                    else
                                        hs.alert.show("❌ " .. selectedService.text .. " 시작 실패", 3)
                                    end
                                end, {"services", "start", selectedService.text}):start()
                            end
                        end)
                        serviceChooser:choices(services)
                        serviceChooser:placeholderText("시작할 서비스 선택...")
                        serviceChooser:show()
                    else
                        hs.alert.show("사용 가능한 서비스가 없습니다", 3)
                    end
                else
                    hs.alert.show("서비스 목록을 가져올 수 없습니다", 3)
                end
            end, {"services", "list"}):start()
        elseif command == "Brew 서비스 종료" then
            -- 실행 중인 brew 서비스 목록 가져오기
            hs.task.new("/opt/homebrew/bin/brew", function(exitCode, stdOut, stdErr)
                if exitCode == 0 then
                    local runningServices = {}
                    for line in stdOut:gmatch("[^\r\n]+") do
                        local serviceName = line:match("^([%w%-%.]+)%s+started")
                        if serviceName then
                            table.insert(runningServices, {
                                text = serviceName,
                                subText = "brew services stop " .. serviceName
                            })
                        end
                    end

                    if #runningServices > 0 then
                        local serviceChooser = hs.chooser.new(function(selectedService)
                            if selectedService then
                                hs.alert.show("서비스 종료 중: " .. selectedService.text, 2)
                                hs.task.new("/opt/homebrew/bin/brew", function(stopExitCode, stopStdOut, stopStdErr)
                                    if stopExitCode == 0 then
                                        hs.alert.show("✅ " .. selectedService.text .. " 종료됨", 3)
                                    else
                                        hs.alert.show("❌ " .. selectedService.text .. " 종료 실패", 3)
                                    end
                                end, {"services", "stop", selectedService.text}):start()
                            end
                        end)
                        serviceChooser:choices(runningServices)
                        serviceChooser:placeholderText("종료할 서비스 선택...")
                        serviceChooser:show()
                    else
                        hs.alert.show("실행 중인 서비스가 없습니다", 3)
                    end
                else
                    hs.alert.show("서비스 목록을 가져올 수 없습니다", 3)
                end
            end, {"services", "list"}):start()
        elseif command == "Docker Compose 시작" then
            -- Docker Compose 프로젝트 선택 후 시작
            local projects = {}
            for _, project in ipairs(CONFIG.DOCKER_COMPOSE.PROJECTS) do
                -- docker-compose.yml 파일이 존재하는지 확인
                local composeFile = project.path .. "/docker-compose.yml"
                local attrs = hs.fs.attributes(composeFile)
                if attrs then
                    table.insert(projects, {
                        text = project.name,
                        subText = "docker-compose up -d in " .. project.path,
                        path = project.path
                    })
                end
            end

            if #projects > 0 then
                local projectChooser = hs.chooser.new(function(selectedProject)
                    if selectedProject then
                        hs.alert.show("Docker Compose 시작 중: " .. selectedProject.text, 2)

                        -- docker-compose up -d 실행
                        local task = hs.task.new("/opt/homebrew/bin/docker-compose", function(exitCode, stdOut, stdErr)
                            if exitCode == 0 then
                                hs.alert.show("✅ " .. selectedProject.text .. " Docker Compose 시작됨", 3)
                                print("📦 Docker Compose 시작 성공: " .. selectedProject.text)
                                if stdOut and stdOut:len() > 0 then
                                    print("출력: " .. stdOut)
                                end
                            else
                                hs.alert.show("❌ " .. selectedProject.text .. " Docker Compose 시작 실패", 3)
                                print("⚠️ Docker Compose 시작 실패: " .. selectedProject.text)
                                if stdErr and stdErr:len() > 0 then
                                    print("오류: " .. stdErr)
                                end
                            end
                        end, {"up", "-d"})

                        -- 작업 디렉토리 설정
                        task:setWorkingDirectory(selectedProject.path)
                        task:start()
                    end
                end)
                projectChooser:choices(projects)
                projectChooser:placeholderText("시작할 Docker Compose 프로젝트 선택...")
                projectChooser:show()
            else
                hs.alert.show("사용 가능한 Docker Compose 프로젝트가 없습니다", 3)
            end
        elseif command == "Docker Compose 중지" then
            -- Docker Compose 프로젝트 선택 후 중지
            local projects = {}
            for _, project in ipairs(CONFIG.DOCKER_COMPOSE.PROJECTS) do
                -- docker-compose.yml 파일이 존재하는지 확인
                local composeFile = project.path .. "/docker-compose.yml"
                local attrs = hs.fs.attributes(composeFile)
                if attrs then
                    table.insert(projects, {
                        text = project.name,
                        subText = "docker-compose stop in " .. project.path,
                        path = project.path
                    })
                end
            end

            if #projects > 0 then
                local projectChooser = hs.chooser.new(function(selectedProject)
                    if selectedProject then
                        hs.alert.show("Docker Compose 중지 중: " .. selectedProject.text, 2)

                        -- docker-compose stop 실행
                        local task = hs.task.new("/opt/homebrew/bin/docker-compose", function(exitCode, stdOut, stdErr)
                            if exitCode == 0 then
                                hs.alert.show("✅ " .. selectedProject.text .. " Docker Compose 중지됨", 3)
                                print("📦 Docker Compose 중지 성공: " .. selectedProject.text)
                                if stdOut and stdOut:len() > 0 then
                                    print("출력: " .. stdOut)
                                end
                            else
                                hs.alert.show("❌ " .. selectedProject.text .. " Docker Compose 중지 실패", 3)
                                print("⚠️ Docker Compose 중지 실패: " .. selectedProject.text)
                                if stdErr and stdErr:len() > 0 then
                                    print("오류: " .. stdErr)
                                end
                            end
                        end, {"stop"})

                        -- 작업 디렉토리 설정
                        task:setWorkingDirectory(selectedProject.path)
                        task:start()
                    end
                end)
                projectChooser:choices(projects)
                projectChooser:placeholderText("중지할 Docker Compose 프로젝트 선택...")
                projectChooser:show()
            else
                hs.alert.show("사용 가능한 Docker Compose 프로젝트가 없습니다", 3)
            end
        elseif command == "Yarn 백그라운드 실행" then
            -- Yarn 프로젝트 선택 후 스크립트 실행
            local projects = {}
            for _, project in ipairs(CONFIG.YARN_PROJECTS.PROJECTS) do
                -- package.json 파일이 존재하는지 확인
                local expandedPath = project.path:gsub("^~", os.getenv("HOME"))
                local packageFile = expandedPath .. "/package.json"
                local attrs = hs.fs.attributes(packageFile)
                if attrs then
                    table.insert(projects, {
                        text = project.name,
                        subText = "yarn run in " .. project.path,
                        path = expandedPath,
                        scripts = project.scripts
                    })
                end
            end

            if #projects > 0 then
                local projectChooser = hs.chooser.new(function(selectedProject)
                    if selectedProject then
                        -- 스크립트 선택
                        local scriptChoices = {}
                        for _, script in ipairs(selectedProject.scripts) do
                            table.insert(scriptChoices, {
                                text = script,
                                subText = "yarn run " .. script,
                                project = selectedProject,
                                script = script
                            })
                        end

                        local scriptChooser = hs.chooser.new(function(selectedScript)
                            if selectedScript then
                                local taskKey = selectedScript.project.text .. ":" .. selectedScript.script

                                -- 이미 실행 중인지 확인
                                if runningYarnTasks[taskKey] then
                                    hs.alert.show("⚠️ 이미 실행 중: " .. taskKey, 3)
                                    return
                                end

                                hs.alert.show("🚀 Yarn 백그라운드 시작: " .. taskKey, 2)

                                -- yarn run 스크립트를 백그라운드로 실행
                                local task = hs.task.new("/opt/homebrew/bin/yarn", function(exitCode, stdOut, stdErr)
                                    -- 작업 완료 시 추적 목록에서 제거
                                    runningYarnTasks[taskKey] = nil

                                    if exitCode == 0 then
                                        hs.alert.show("✅ " .. taskKey .. " 완료됨", 3)
                                        print("📦 Yarn 작업 완료: " .. taskKey)
                                    else
                                        hs.alert.show("❌ " .. taskKey .. " 종료됨 (코드: " .. exitCode .. ")", 3)
                                        print("⚠️ Yarn 작업 종료: " .. taskKey .. " (종료 코드: " ..
                                                  exitCode .. ")")
                                        if stdErr and stdErr:len() > 0 then
                                            print("오류: " .. stdErr)
                                        end
                                    end
                                end, {"run", selectedScript.script})

                                -- 작업 디렉토리 설정
                                task:setWorkingDirectory(selectedScript.project.path)

                                -- 백그라운드 작업으로 추적
                                runningYarnTasks[taskKey] = {
                                    task = task,
                                    project = selectedScript.project.text,
                                    script = selectedScript.script,
                                    startTime = os.time()
                                }

                                task:start()
                                print("📦 Yarn 백그라운드 시작: " .. taskKey .. " (PID: " .. task:pid() .. ")")
                            end
                        end)
                        scriptChooser:choices(scriptChoices)
                        scriptChooser:placeholderText("실행할 스크립트 선택...")
                        scriptChooser:show()
                    end
                end)
                projectChooser:choices(projects)
                projectChooser:placeholderText("Yarn 프로젝트 선택...")
                projectChooser:show()
            else
                hs.alert.show("사용 가능한 Yarn 프로젝트가 없습니다", 3)
            end
        elseif command == "Yarn 백그라운드 종료" then
            -- 실행 중인 Yarn 작업 목록 표시
            local runningChoices = {}

            for taskKey, taskInfo in pairs(runningYarnTasks) do
                local runTime = os.time() - taskInfo.startTime
                local runTimeStr = string.format("%d분 %d초", math.floor(runTime / 60), runTime % 60)

                table.insert(runningChoices, {
                    text = taskKey,
                    subText = "실행 시간: " .. runTimeStr .. " (PID: " .. taskInfo.task:pid() .. ")",
                    taskKey = taskKey,
                    taskInfo = taskInfo
                })
            end

            if #runningChoices > 0 then
                local taskChooser = hs.chooser.new(function(selectedTask)
                    if selectedTask then
                        local taskInfo = selectedTask.taskInfo
                        local taskKey = selectedTask.taskKey

                        hs.alert.show("⏹️ Yarn 작업 종료 중: " .. taskKey, 2)

                        -- 작업 종료
                        taskInfo.task:terminate()

                        -- 추적 목록에서 제거
                        runningYarnTasks[taskKey] = nil

                        hs.alert.show("✅ " .. taskKey .. " 종료됨", 3)
                        print("📦 Yarn 백그라운드 종료: " .. taskKey)
                    end
                end)
                taskChooser:choices(runningChoices)
                taskChooser:placeholderText("종료할 Yarn 작업 선택...")
                taskChooser:show()
            else
                hs.alert.show("실행 중인 Yarn 작업이 없습니다", 3)
            end
        end
    end)

    chooser:choices(choices)
    chooser:searchSubText(true)
    chooser:placeholderText("개발자 명령어 검색...")
    chooser:show()
end

-- Export functions
devCommander.showDevCommander = showDevCommander
devCommander.runningYarnTasks = runningYarnTasks

return devCommander