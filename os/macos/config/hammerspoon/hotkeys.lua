-- ========================================
-- 단축키 정의
-- ========================================

local powerManagement = require("power_management")
local systemStatus = require("system_status")
local devCommander = require("dev_commander")

local hotkeys = {}

-- 모든 단축키 설정
local function setupHotkeys()
	-- BTT & 카페인 관련 단축키
	-- 통합 상태 확인 (BTT + 카페인 + 시스템)
	hs.hotkey.bind({ "cmd", "ctrl", "alt" }, "s", "시스템 상태 확인", systemStatus.showSystemStatus)

	-- 카페인 수동 토글
	hs.hotkey.bind(
		{ "cmd", "ctrl", "alt" },
		"f",
		"카페인 활성화/비활성화 토글 (화면 끄기 방지)",
		powerManagement.toggleCaffeine
	)

	-- Spoon 단축키 설정
	-- KSheet: 단축키 치트시트
	hs.hotkey.bind({ "cmd", "shift" }, "/", "시스템 전체 단축키 치트시트 표시/숨기기", function()
		if spoon.KSheet then
			spoon.KSheet:toggle()

			-- ESC 키로 KSheet 창 닫기 지원 추가
			if
				spoon.KSheet.sheetView
				and spoon.KSheet.sheetView:hswindow()
				and spoon.KSheet.sheetView:hswindow():isVisible()
			then
				local ksheetEscHandler
				ksheetEscHandler = hs.hotkey.bind({}, "escape", function()
					if
						spoon.KSheet.sheetView
						and spoon.KSheet.sheetView:hswindow()
						and spoon.KSheet.sheetView:hswindow():isVisible()
					then
						spoon.KSheet:hide()
						if ksheetEscHandler then
							ksheetEscHandler:delete()
							ksheetEscHandler = nil
						end
					end
				end)
			end
		else
			hs.alert.show("KSheet Spoon이 로드되지 않았습니다")
		end
	end)

	-- HSKeybindings: Hammerspoon 단축키 표시
	hs.hotkey.bind({ "ctrl", "shift" }, "/", "Hammerspoon 단축키 목록 표시/숨기기", function()
		if spoon.HSKeybindings then
			if
				spoon.HSKeybindings.sheetView
				and spoon.HSKeybindings.sheetView:hswindow()
				and spoon.HSKeybindings.sheetView:hswindow():isVisible()
			then
				spoon.HSKeybindings:hide()
			else
				spoon.HSKeybindings:show()

				-- ESC 키로 HSKeybindings 창 닫기 지원 추가
				if
					spoon.HSKeybindings.sheetView
					and spoon.HSKeybindings.sheetView:hswindow()
					and spoon.HSKeybindings.sheetView:hswindow():isVisible()
				then
					local hsKeybindingsEscHandler
					hsKeybindingsEscHandler = hs.hotkey.bind({}, "escape", function()
						if
							spoon.HSKeybindings.sheetView
							and spoon.HSKeybindings.sheetView:hswindow()
							and spoon.HSKeybindings.sheetView:hswindow():isVisible()
						then
							spoon.HSKeybindings:hide()
							if hsKeybindingsEscHandler then
								hsKeybindingsEscHandler:delete()
								hsKeybindingsEscHandler = nil
							end
						end
					end)
				end
			end
		else
			hs.alert.show("HSKeybindings Spoon이 로드되지 않았습니다")
		end
	end)

	-- PopupTranslateSelection: 선택된 텍스트 번역
	hs.hotkey.bind({ "cmd", "ctrl" }, "t", "선택된 텍스트 번역", function()
		if spoon.PopupTranslateSelection then
			spoon.PopupTranslateSelection:translateSelectionPopup()
		else
			hs.alert.show("PopupTranslateSelection Spoon이 로드되지 않았습니다")
		end
	end)

	-- DevCommander: 개발자 명령어 실행기
	hs.hotkey.bind({ "cmd", "ctrl", "alt" }, "d", "개발자 명령어 실행기", devCommander.showDevCommander)
end

-- Export functions
hotkeys.setupHotkeys = setupHotkeys

return hotkeys

