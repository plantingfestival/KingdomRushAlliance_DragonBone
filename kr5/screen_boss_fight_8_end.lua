-- chunkname: @./kr5/screen_boss_fight_8_end.lua

require("klove.kui")

local S = require("sound_db")
local screen_comics = require("screen_comics")
local screen = {}

screen.required_sounds = {
	"common",
	"music_stage30"
}
screen.required_textures = {
	"comic_16"
}
screen.ref_w = 1728
screen.ref_h = 768
screen.ref_res = TEXTURE_SIZE_ALIAS.ipad

function screen:init(sw, sh, done_callback)
	self.sw = sw
	self.sh = sh
	self.done_callback = done_callback
	self.phase = "comic16"

	self:next_item()
end

function screen:update(dt)
	if self.active_screen then
		self.active_screen:update(dt)
	end
end

function screen:destroy()
	screen_comics:destroy()
end

function screen:draw()
	if self.active_screen then
		self.active_screen:draw()
	end
end

function screen:keypressed(key, isrepeat)
	if self.active_screen then
		self.active_screen:keypressed(key, isrepeat)
	end
end

function screen:mousepressed(x, y, button)
	if self.active_screen then
		self.active_screen:mousepressed(x, y, button)
	end
end

function screen:mousereleased(x, y, button)
	if self.active_screen then
		self.active_screen:mousereleased(x, y, button)
	end
end

function screen:gamepadpressed(joystick, button)
	if self.active_screen and self.active_screen.gamepadpressed then
		self.active_screen:gamepadpressed(joystick, button)
	end
end

function screen:next_item()
	local function cb()
		self:next_item()
	end

	if self.phase == "comic16" then
		screen_comics.comic_data = love.filesystem.read(director:get_comic_data_file(16))
		screen_comics.fade_in = {
			1,
			{
				0,
				0,
				0,
				255
			}
		}
		screen_comics.level_idx = 30

		screen_comics:init(self.sw, self.sh, cb)

		self.active_screen = screen_comics
		self.phase = "end"
	else
		S:stop_all()

		self.active_screen = nil

		self.done_callback({
			level_idx = 30,
			next_item_name = "map"
		})
	end
end

return screen
