-- ========================================
-- Window Resizing (Ctrl + Option) - BTT 대체
-- ========================================
local windowResize = {}
local history = {} -- 창별 이전 프레임 저장소: { [windowID] = frame }

-- Modifier 키: Ctrl + Option
local mods = {"ctrl", "alt"}

-- 현재 창 상태 저장 (Restore용)
local function saveState(win)
    if not win then
        return
    end
    local id = win:id()
    if not history[id] then
        history[id] = win:frame()
    end
end

-- 상태 복구
local function restoreState()
    local win = hs.window.focusedWindow()
    if not win then
        return
    end
    local id = win:id()

    if history[id] then
        win:setFrame(history[id])
        -- 복구 후 기록 삭제? 아니면 유지? -> BTT 동작처럼 복구 후 삭제
        history[id] = nil
        hs.alert.show("↺ Restore")
    else
        hs.alert.show("No history")
    end
end

-- 창 이동/리사이즈 함수 공통화
local function moveWindow(func)
    local win = hs.window.focusedWindow()
    if not win then
        return
    end

    -- 변경 전 상태 저장 (이미 저장된 상태가 있으면 덮어쓰지 않음 = 최초 원본 보존)
    saveState(win)

    func(win)
end

function windowResize.start()
    -- 1. 반쪽 이동 (Half)
    hs.hotkey.bind(mods, "left", "Window: Left Half", function()
        moveWindow(function(w)
            w:moveToUnit(hs.layout.left50)
        end)
    end)
    hs.hotkey.bind(mods, "right", "Window: Right Half", function()
        moveWindow(function(w)
            w:moveToUnit(hs.layout.right50)
        end)
    end)
    hs.hotkey.bind(mods, "up", "Window: Top Half", function()
        moveWindow(function(w)
            w:moveToUnit({
                x = 0,
                y = 0,
                w = 1,
                h = 0.5
            })
        end)
    end)
    hs.hotkey.bind(mods, "down", "Window: Bottom Half", function()
        moveWindow(function(w)
            w:moveToUnit({
                x = 0,
                y = 0.5,
                w = 1,
                h = 0.5
            })
        end)
    end)

    -- 2. 전체 화면 / 중앙 (Maximize / Center)
    hs.hotkey.bind(mods, "f", "Window: Maximize", function()
        moveWindow(function(w)
            w:maximize()
        end)
    end)
    hs.hotkey.bind(mods, "c", "Window: Center", function()
        moveWindow(function(w)
            w:centerOnScreen()
        end)
    end)

    -- 3. 4분할 (Corners) - U/I/J/K
    hs.hotkey.bind(mods, "u", "Window: Top-Left-Corner", function() -- Top-Left
        moveWindow(function(w)
            w:moveToUnit({
                x = 0,
                y = 0,
                w = 0.5,
                h = 0.5
            })
        end)
    end)
    hs.hotkey.bind(mods, "i", "Window: Top-Right-Corner", function() -- Top-Right
        moveWindow(function(w)
            w:moveToUnit({
                x = 0.5,
                y = 0,
                w = 0.5,
                h = 0.5
            })
        end)
    end)
    hs.hotkey.bind(mods, "j", "Window: Bottom-Left-Corner", function() -- Bottom-Left
        moveWindow(function(w)
            w:moveToUnit({
                x = 0,
                y = 0.5,
                w = 0.5,
                h = 0.5
            })
        end)
    end)
    hs.hotkey.bind(mods, "k", "Window: Bottom-Right-Corner", function() -- Bottom-Right
        moveWindow(function(w)
            w:moveToUnit({
                x = 0.5,
                y = 0.5,
                w = 0.5,
                h = 0.5
            })
        end)
    end)

    -- 4. 복구 (Restore)
    hs.hotkey.bind(mods, "r", "Window: Restore history", restoreState)

    print("🪟 Window Resizing 시작됨: ^⌥ + [Arrow, F, C, R, U, I, J, K]")
end

function windowResize.stop()
    -- 생략
end

return windowResize
