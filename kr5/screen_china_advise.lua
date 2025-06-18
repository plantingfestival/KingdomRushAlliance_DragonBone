-- chunkname: @./kr5/screen_china_advise.lua

local log = require("klua.log"):new("screen_china_advise")
local class = require("middleclass")
local F = require("klove.font_db")
local V = require("klua.vector")
local v = V.v
local km = require("klua.macros")
local timer = require("hump.timer").new()
local ktw = require("klove.tween").new(timer)
local S = require("sound_db")
local SU = require("screen_utils")
local ISM = require("klove.input_state_machine")
local i18n = require("i18n")
local storage = require("storage")

require("constants")
require("klove.kui")
require("gg_views_custom")
require("gg_views_game")

local screen = {}

screen.ref_h = IS_MOBILE and 320 or 768
screen.ref_w = 1728
screen.ref_res = TEXTURE_SIZE_ALIAS.ipad

local SCREEN_TIME = 3

function screen:init(w, h, done_callback)
	self.done_callback = done_callback
	self.waiting_time = 0

	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)

	self.sw = sw
	self.sh = sh

	local window = KWindow:new(v(sw, sh))

	window.scale = {
		x = scale,
		y = scale
	}
	window.size = {
		x = sw,
		y = sh
	}
	window.origin = origin
	window.colors.background = {
		0,
		0,
		0,
		255
	}

	window:set_responder(window)

	window.ktw = ktw
	self.window = window
	GGLabel.static.font_scale = scale
	GGLabel.static.ref_h = self.ref_h

	local label_w = 380
	local label = GGLabel:new(V.v(label_w, 15))

	label.pos = v(sw / 2, sh / 4)
	label.anchor = v(label.size.x / 2, 0)
	label.font_name = "NotoSansCJKkr-Regular"
	label.font_size = 21
	label.colors.text = {
		255,
		255,
		255
	}
	label.text = _("CHINA_STARTING_ADVICE_MESSAGE")
	label.text_align = "center"

	local _h, lines = label:get_wrap_lines()

	label.size.y = lines * label.line_height * label:get_font_height()
	label.alpha = 0
	self.label = label

	window:add_child(label)
end

function screen:destroy()
	timer:clear()
	ktw:clear()
	self.window:destroy()

	self.window = nil

	SU.remove_references(self, KView)
end

function screen:update(dt)
	timer:update(dt)
	self.window:update(dt)

	if not self.showing_label then
		self.showing_label = true

		timer:script(function(wait)
			timer:tween(0.2, self.label, {
				alpha = 1
			}, "in-quad")
		end)
	end

	self.waiting_time = self.waiting_time + dt

	if self.waiting_time > SCREEN_TIME then
		if self.end_done then
			return
		end

		self.end_done = true

		timer:script(function(wait)
			local t = {
				prevent_loading = true
			}

			if screen.args then
				t.next_item_name = screen.args.after_item_name
			end

			self.done_callback(t)
		end)
	end
end

function screen:draw()
	self.window:draw()
end

function screen:mousepressed(x, y, button)
	self.window:mousepressed(x, y, button)
end

function screen:mousereleased(x, y, button)
	self.window:mousereleased(x, y, button)
end

function screen:keypressed(key, isrepeat)
	self.window:keypressed(key, isrepeat)
end

return screen
