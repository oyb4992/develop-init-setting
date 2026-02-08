-- ========================================
-- CapsLock 관리 (Hyper Key 제거됨)
-- ========================================
local capslockManager = {}
local hotkey = nil -- 등록된 핫키 저장

function capslockManager.start()
	hotkey = hs.hotkey.bind({ "cmd", "ctrl", "alt" }, "c", "CapsLock 토글", function()
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
	if hotkey then
		hotkey:delete()
		hotkey = nil
	end
	print("Capslock Manager 중지됨")
end

return capslockManager
