-- chunkname: @./all/window_utils.lua

local log = require("klua.log"):new("window_utils")

WU = {}

function WU.get_best_fullscreen_resolution()
	local full_screen_modes = love.window.getFullscreenModes()

	if not full_screen_modes or #full_screen_modes < 1 then
		log.error("could not list fullscreen resolutions")

		return nil
	end

	table.sort(full_screen_modes, function(e1, e2)
		return e1.width > e2.width
	end)

	local width = full_screen_modes[1].width
	local height = full_screen_modes[1].height

	log.debug("best resolution: %s x %s", width, height)

	return width, height
end

return WU
