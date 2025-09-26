-- chunkname: @./sequels/screen_splash_message.lua

local log = require("klua.log"):new("screen_splash_message")
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
local features = require("features")

require("constants")
require("klove.kui")
require("kviews_gg_sequels")

local screen = {}

screen.ref_w = 1728
screen.ref_h = 768
screen.ref_res = TEXTURE_SIZE_ALIAS.ipad

function screen:init(w, h, done_callback)
	local data = features.show_splash_message

	self.done_callback = done_callback

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

	local contents = KView:new()

	contents.pos = v(sw / 2, sh / 2)
	contents.alpha = 0

	window:add_child(contents)

	local label = GGLabel:new(V.v(1024, 15))

	label.font_name = data.font_name or "sans"
	label.font_size = data.font_size or 48
	label.colors.text = data.font_color or {
		255,
		255,
		255
	}
	label.text = _(data.text_key)
	label.text_align = "center"
	label.vertical_align = "middle"

	local _h, lines = label:get_wrap_lines()

	label.size.y = lines * label.line_height * label:get_font_height()
	label.anchor = v(label.size.x / 2, label.size.y / 2)

	contents:add_child(label)

	if data.text_key_footer then
		local footer = GGLabel:new(V.v(1024, 30))

		footer.font_name = data.font_name_footer or "sans"
		footer.font_size = data.font_size_footer or 15
		footer.colors.text = data.font_color_footer or {
			255,
			255,
			255
		}
		footer.text = _(data.text_key_footer)
		footer.text_align = "center"
		footer.vertical_align = "bottom"

		local _h, lines = footer:get_wrap_lines()

		footer.size.y = lines * footer.line_height * footer:get_font_height()
		footer.anchor = v(footer.size.x / 2, footer.size.y)
		footer.pos = v(0, sh / 2 - 0.3 * footer.size.y)

		contents:add_child(footer)
	end

	ktw:script(contents, function(wait)
		ktw:tween(contents, 0.5, contents, {
			alpha = 1
		}, "in-quad")
		wait(data.duration)
		ktw:tween(contents, 0.5, contents, {
			alpha = 0
		}, "in-quad")

		local t = {
			prevent_loading = true
		}

		if screen.args then
			t.next_item_name = screen.args.after_item_name
		end

		self.done_callback(t)
	end)
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
