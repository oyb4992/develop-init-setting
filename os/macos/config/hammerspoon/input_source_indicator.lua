-- ========================================
-- Input Source Indicator
-- Shows the current input source near the focused input element.
-- ========================================
local config = require("config")
local CONFIG = config.CONFIG

local inputSourceIndicator = {}

local indicatorCanvas = nil
local dismissalTimer = nil

local function indicatorConfig()
	return CONFIG.INPUT_SOURCE.INDICATOR
end

local function closeIndicator()
	if dismissalTimer then
		dismissalTimer:stop()
		dismissalTimer = nil
	end

	if indicatorCanvas then
		indicatorCanvas:delete()
		indicatorCanvas = nil
	end
end

local function screenContaining(point)
	for _, screen in ipairs(hs.screen.allScreens()) do
		local frame = screen:frame()
		if point.x >= frame.x and point.x < frame.x + frame.w and point.y >= frame.y and point.y < frame.y + frame.h then
			return screen
		end
	end

	return hs.screen.mainScreen()
end

local function focusedInputFrame()
	local systemElement = hs.axuielement.systemWideElement()
	local focusedElement = systemElement:attributeValue("AXFocusedUIElement")
	if not focusedElement then
		return nil
	end

	local frame = focusedElement:attributeValue("AXFrame")
	if frame and frame.x and frame.y and frame.w and frame.h then
		return frame
	end

	local position = focusedElement:attributeValue("AXPosition")
	local size = focusedElement:attributeValue("AXSize")
	if position and size and position.x and position.y and size.w and size.h then
		return { x = position.x, y = position.y, w = size.w, h = size.h }
	end

	return nil
end

local function fallbackFrame()
	local focusedWindow = hs.window.focusedWindow()
	if focusedWindow then
		return focusedWindow:frame()
	end

	return hs.screen.mainScreen():frame()
end

local function indicatorPosition()
	local options = indicatorConfig()
	local targetFrame = focusedInputFrame() or fallbackFrame()
	local screen = screenContaining({ x = targetFrame.x, y = targetFrame.y })
	local screenFrame = screen:frame()
	local x = targetFrame.x + options.OFFSET
	local y = targetFrame.y - options.HEIGHT - options.OFFSET

	if y < screenFrame.y then
		y = targetFrame.y + targetFrame.h + options.OFFSET
	end

	x = math.max(screenFrame.x, math.min(x, screenFrame.x + screenFrame.w - options.WIDTH))
	y = math.max(screenFrame.y, math.min(y, screenFrame.y + screenFrame.h - options.HEIGHT))

	return { x = x, y = y, w = options.WIDTH, h = options.HEIGHT }
end

local function styleFor(sourceID)
	if sourceID == CONFIG.INPUT_SOURCE.KOREAN_LAYOUT_ID then
		return "한", { red = 0.85, green = 0.28, blue = 0.22 }
	end

	return "EN", { red = 0.12, green = 0.44, blue = 0.82 }
end

function inputSourceIndicator.showCurrentSource()
	local options = indicatorConfig()
	if not options.ENABLED then
		return
	end

	closeIndicator()

	local label, color = styleFor(hs.keycodes.currentSourceID())
	indicatorCanvas = hs.canvas.new(indicatorPosition())
	indicatorCanvas:level("floating")
	indicatorCanvas[1] = {
		type = "rectangle",
		action = "fill",
		fillColor = { red = 0.06, green = 0.07, blue = 0.09, alpha = 0.94 },
		roundedRectRadii = { xRadius = 5, yRadius = 5 },
	}
	indicatorCanvas[2] = {
		type = "text",
		text = label,
		textFont = "SF Pro Display",
		textSize = options.TEXT_SIZE,
		textColor = { red = color.red, green = color.green, blue = color.blue, alpha = 1 },
		textAlignment = "center",
		frame = { x = 0, y = 2, w = options.WIDTH, h = options.HEIGHT - 2 },
	}
	indicatorCanvas:show()

	local canvas = indicatorCanvas
	dismissalTimer = hs.timer.doAfter(options.DISPLAY_TIME, function()
		if indicatorCanvas == canvas then
			closeIndicator()
		end
	end)
end

function inputSourceIndicator.stop()
	closeIndicator()
end

return inputSourceIndicator
