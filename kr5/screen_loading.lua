-- chunkname: @./kr5/screen_loading.lua

local km = require("klua.macros")
local log = require("klua.log"):new("screen_loading")
local V = require("klua.vector")
local F = require("klove.font_db")
local I = require("klove.image_db")
local kui_db = require("klove.kui_db")
local S = require("sound_db")
local SU = require("screen_utils")
local GS = require("game_settings")
local i18n = require("i18n")

require("klove.kui")
require("gg_views_custom")
require("constants")

local data = require("data.director_data")
local screen = {}

if IS_MOBILE then
	screen.required_textures = {
		"loading_common"
	}
else
	screen.required_textures = {
		"loading_common_desktop",
		"loading_images_desktop"
	}
end

screen.required_sounds = {
	"common"
}
screen.ref_w = REF_W
screen.ref_h = REF_H
screen.ref_res = TEXTURE_SIZE_ALIAS.ipad
screen.keep_loaded = IS_MOBILE
screen.is_transition = true
screen.transition_state = "initial"
screen.max_progress_speed = IS_MOBILE and 1e+99 or 0.8

local function wid(name)
	return screen.window:ci(name)
end

function screen:update_required_textures(upcoming_item, level_idx, last_level_idx)
	if IS_MOBILE then
		return
	end

	local lin = data.loading_image_name
	local out = lin.default
	local idx = level_idx or last_level_idx

	if idx then
		for _, row in pairs(lin) do
			if type(row) == "table" then
				local image_name, levels = unpack(row)

				if type(levels) == "table" and table.contains(levels, idx) then
					out = image_name

					break
				end
			end
		end
	end

	self.loading_image_name = out
end

function screen:init(w, h, upcoming_item, level_idx)
	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)

	self.w = w
	self.h = h
	self.sw = sw
	self.sh = sh
	self.transition_state = "initial"
	self.transition_time = 0.3
	self.skip_cycles = 0

	local ctx = SU.new_screen_ctx(self)
	local tt = kui_db:get_table("loading_screen", ctx)
	local window = KWindow:new_from_table(tt)

	window.scale = V.v(scale, scale)
	window.size = {
		x = sw,
		y = sh
	}
	window.origin = origin

	window:set_responder(window)

	self.window = window
	screen.hold_enabled = true

	local loading_bg = self.window:ci("loading_bg")

	if loading_bg then
		loading_bg:set_image(self.loading_image_name)
	end

	local tip = self.window:ci("label_tip")

	if tip then
		if GS.gameplay_tips_count and GS.gameplay_tips_count > 0 then
			tip.text = _(string.format("TIP_%i", math.random(1, GS.gameplay_tips_count)))
		else
			tip.hidden = true
		end
	end

	local exo = self.window:ci("exo")
	local exo_scale = sw / self.ref_w

	if exo then
		exo.scale = V.v(exo_scale, exo_scale)

		function exo.on_exo_finished()
			local bar = wid("image_loading_door_loading_bar")

			if bar then
				bar.hidden = false
			end

			self.transition_state = "closed"
			exo.runs = 0
			exo.ts = 0
			exo.exo_animation = "loading"
			exo.on_exo_finished = nil
		end
	end

	local bar = exo and wid("image_loading_door_loading_bar") or wid("loading_bar")
	local bar_base_scale = IS_MOBILE and 250 / bar.size.x * exo_scale or 1

	if exo then
		bar.pos = V.v(120 * exo_scale, 156 * exo_scale)

		local bar_base_scale = 250 / bar.size.x * exo_scale

		bar.scale.x = -bar_base_scale
		bar.scale.y = 14 / bar.size.y * exo_scale
		bar.hidden = true
	else
		bar.scale.x = 0
		bar.hidden = false
	end

	bar.last_ts = screen.window.ts

	function bar.update(this, dt)
		local d_t = screen.window.ts - this.last_ts
		local p = 0.8 * I.progress + 0.2 * S.progress
		local step = km.clamp(0, screen.max_progress_speed * d_t, p)

		this.scale.x = exo and -bar_base_scale * (1 - step) or km.clamp(0, 1, this.scale.x + step)
		this.last_ts = screen.window.ts

		if exo then
			if p >= 1 then
				this.scale.x = 0
			else
				screen.hold_enabled = false
			end
		elseif this.scale.x >= 1 then
			screen.hold_enabled = false
		end
	end
end

function screen:destroy()
	self.window:destroy()

	self.window = nil
end

function screen:update(dt)
	self.window:update(dt)

	if self.skip_cycles > 0 then
		self.skip_cycles = self.skip_cycles - 1

		return
	end

	if self.transition_state == "close_requested" then
		self:start_closing()
	elseif self.transition_state == "open_requested" then
		self:start_opening()
	end
end

function screen:draw()
	self.window:draw()
end

function screen:keypressed(key, isrepeat)
	return
end

function screen:mousepressed(x, y, button)
	return
end

function screen:close()
	self.transition_state = "close_requested"

	if not IS_MOBILE then
		self.skip_cycles = 1
	end
end

function screen:open()
	self.transition_state = "open_requested"
end

function screen:start_closing()
	if IS_MOBILE then
		S:queue("GUITransitionClose")

		self.transition_state = "closing"
	else
		self.transition_state = "closed"
	end
end

function screen:start_opening()
	if IS_MOBILE then
		S:queue("GUITransitionOpen")

		self.transition_state = "opening"

		local exo = self.window:ci("exo")

		exo.runs = 0
		exo.ts = 0
		exo.exo_animation = "doors_out"

		local bar = wid("image_loading_door_loading_bar")

		if bar then
			bar.hidden = true
		end

		function exo.on_exo_finished()
			self.transition_state = "open"
		end
	else
		self.transition_state = "open"
	end
end

return screen
