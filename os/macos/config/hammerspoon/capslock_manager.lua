-- ========================================
-- CapsLock 관리 (Hyper Key 제거됨)
-- ========================================
local capslockManager = {}

function capslockManager.start()
	hs.hotkey.bind({ "cmd", "ctrl", "alt" }, "c", "CapsLock 토글", function()
		local newState = not hs.hid.capslock.get()
		hs.hid.capslock.set(newState)
		if newState then
			hs.alert.show("🅰️ CapsLock ON")
		else
			hs.alert.show("a CapsLock OFF")
		end
	end)
	print("Capslock Manager Started (Cmd+Ctrl+Alt+C to toggle)")
end

function capslockManager.stop()
	-- 정지할 리소스가 없음
end

return capslockManager
