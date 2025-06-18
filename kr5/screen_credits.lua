-- chunkname: @./kr5/screen_credits.lua

local log = require("klua.log"):new("screen_slots")
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

local LOCAL_IS_MOBILE = true
local screen = {}

screen.required_sounds = {
	"common",
	"music_screen_credits"
}
screen.required_textures = {
	"screen_credits",
	"screen_credits_bg"
}
screen.ref_h = IS_MOBILE and 320 or 768
screen.ref_w = 1728
screen.ref_res = TEXTURE_SIZE_ALIAS.ipad

function screen:init(w, h, done_callback, ending_version)
	if self.args and self.args.custom == "ending" then
		ending_version = true
	end

	local music_name = "MusicCredits"

	if not S:sound_is_playing(music_name) then
		S:queue(music_name)
	end

	package.loaded["data.credits_data"] = nil
	screen.credits_data = require("data.credits_data")
	self.ending_version = ending_version
	self.done_callback = done_callback
	self.end_credits_done = nil
	self.scroll_speed_max = LOCAL_IS_MOBILE and 50 or 80
	self.scroll_speed = LOCAL_IS_MOBILE and 0 or screen.scroll_speed_max
	self.scroll_phase = LOCAL_IS_MOBILE and 1 or nil

	if ending_version then
		self.scroll_phase = 0
	end

	self.waiting_time = 0
	self.scroll_paused = false

	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)

	self.sw = sw
	self.sh = sh

	local window = KWindow:new(v(sw, sh))

	window.scale = {
		x = scale,
		y = scale
	}
	window.origin = origin
	window.colors.background = ending_version and {
		0,
		0,
		0,
		255
	} or {
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
	self.scroll_paused = nil

	local container = KView:new(v(sw, sh))

	container.propagate_on_click = true
	self.container = container

	local label_w = LOCAL_IS_MOBILE and 380 or sw - 285
	local font_size_factor = 1

	if IS_PHONE then
		font_size_factor = 0.7
	elseif IS_TABLET then
		font_size_factor = 0.7
	elseif KR_TARGET == "console" then
		font_size_factor = 1.4
	end

	local font_name_h = LOCAL_IS_MOBILE and "body_bold" or i18n:cjk("body", "sans", nil, "h_noti")
	local current_y = 0

	for i = 1, #screen.credits_data do
		local type = screen.credits_data[i][2]

		if #screen.credits_data[i] == 0 or screen.credits_data[i][1] == "" then
			current_y = current_y + 50 * font_size_factor
		elseif not type or type == "body" then
			local label = GGLabel:new(V.v(label_w, 15))

			label.pos = v(sw / 2, current_y)
			label.anchor = v(label.size.x / 2, 0)
			label.font_name = "Comic Book Italic"
			label.font_size = 15 * font_size_factor
			label.colors.text = ending_version and {
				212,
				163,
				115
			} or {
				212,
				163,
				115
			}
			label.text = screen.credits_data[i][1]

			if screen.credits_data[i][3] then
				label.text_align = screen.credits_data[i][3]
			else
				label.text_align = "center"
			end

			local _h, lines = label:get_wrap_lines()

			label.size.y = lines * label.line_height * label:get_font_height()
			current_y = current_y + label.size.y

			container:add_child(label)
		elseif not type or type == "body_ja" or type == "body_all" then
			local label = GGLabel:new(V.v(label_w, 15))

			label.pos = v(sw / 2, current_y)
			label.anchor = v(label.size.x / 2, 0)
			label.font_name = type == "body_ja" and "NotoSansCJKjp-Regular" or "NotoSansCJKkr-Regular"
			label.font_size = 13 * font_size_factor
			label.line_height = 1.1
			label.colors.text = ending_version and {
				212,
				163,
				115
			} or {
				212,
				163,
				115
			}
			label.text = screen.credits_data[i][1]

			if screen.credits_data[i][3] then
				label.text_align = screen.credits_data[i][3]
			else
				label.text_align = "center"
			end

			local _h, lines = label:get_wrap_lines()

			label.size.y = lines * label.line_height * label:get_font_height()
			current_y = current_y + label.size.y

			container:add_child(label)
		elseif type == "h1" then
			local label = GGLabel:new(V.v(label_w, 15))

			label.pos = v(sw / 2, current_y)
			label.anchor = v(label.size.x / 2, 0)
			label.font_name = font_name_h
			label.font_size = 20 * font_size_factor
			label.colors.text = ending_version and {
				255,
				253,
				210
			} or {
				255,
				253,
				210
			}
			label.text = screen.credits_data[i][1]

			if screen.credits_data[i][3] then
				label.text_align = screen.credits_data[i][3]
			else
				label.text_align = "center"
			end

			local _h, lines = label:get_wrap_lines()

			label.size.y = lines * label.line_height * label:get_font_height()
			current_y = current_y + label.size.y

			container:add_child(label)
		elseif type == "h2" then
			local label = GGLabel:new(V.v(label_w, 15))

			label.pos = v(sw / 2, current_y)
			label.anchor = v(label.size.x / 2, 0)
			label.font_name = font_name_h
			label.font_size = 18 * font_size_factor
			label.colors.text = ending_version and {
				255,
				253,
				210
			} or {
				255,
				253,
				210
			}
			label.text = screen.credits_data[i][1]

			if screen.credits_data[i][3] then
				label.text_align = screen.credits_data[i][3]
			else
				label.text_align = "center"
			end

			local _h, lines = label:get_wrap_lines()

			label.size.y = lines * label.line_height * label:get_font_height()
			current_y = current_y + label.size.y

			container:add_child(label)
		elseif type == "h3" then
			local label = GGLabel:new(V.v(label_w, 15))

			label.pos = v(sw / 2, current_y)
			label.anchor = v(label.size.x / 2, 0)
			label.font_name = font_name_h
			label.font_size = 13 * font_size_factor
			label.colors.text = ending_version and {
				212,
				163,
				115
			} or {
				212,
				163,
				115
			}
			label.text = screen.credits_data[i][1]

			if screen.credits_data[i][3] then
				label.text_align = screen.credits_data[i][3]
			else
				label.text_align = "center"
			end

			local _h, lines = label:get_wrap_lines()

			label.size.y = lines * label.line_height * label:get_font_height()
			current_y = current_y + label.size.y

			container:add_child(label)
		elseif type == "image" then
			local img = KImageView:new(screen.credits_data[i][1])

			img.anchor = v(img.size.x / 2, 0)
			img.pos = v(sw / 2, current_y)

			container:add_child(img)

			if ending_version then
				current_y = current_y + img.size.y + 100
			else
				current_y = current_y + img.size.y + 8
			end
		elseif type == "logo_title" then
			local label = GGLabel:new(V.v(label_w, 15))

			label.pos = v(sw / 2, current_y)
			label.anchor = v(label.size.x / 2, 0)
			label.font_name = font_name_h
			label.font_size = 18 * font_size_factor
			label.colors.text = ending_version and {
				255,
				253,
				210
			} or {
				255,
				253,
				210
			}
			label.text = screen.credits_data[i][1]

			if screen.credits_data[i][3] then
				label.text_align = screen.credits_data[i][3]
			else
				label.text_align = "center"
			end

			local _h, lines = label:get_wrap_lines()

			label.size.y = lines * label.line_height * label:get_font_height()
			current_y = current_y + label.size.y - 20

			container:add_child(label)
		end
	end

	self.tot_y = current_y

	local scroller_width = sw
	local scroller

	scroller = KInertialView:new()
	scroller.size = V.v(scroller_width, 0)

	if LOCAL_IS_MOBILE and not ending_version then
		local ref_midv_left = KImageView:new("creditshalf")

		ref_midv_left.hidden = true

		local vy = -sh / 2

		while vy < self.tot_y + sh / 2 do
			local midv_left = KImageView:new("creditshalf")
			local midv_right = KImageView:new("credits2half_flip")

			midv_left.pos = v(0, vy - ref_midv_left.size.y / 2)
			midv_right.pos = v(sw - midv_right.size.x, vy)
			midv_right.anchor.x = 0
			vy = vy + midv_left.size.y

			scroller:add_child(midv_left)
			scroller:add_child(midv_right)
		end

		local midv_left = KImageView:new("creditshalf")

		midv_left.pos = v(0, vy - ref_midv_left.size.y / 2)

		scroller:add_child(midv_left)

		scroller.size.y = vy
	else
		scroller.size.y = self.tot_y + 100
	end

	scroller.clip_view = window
	scroller.pos = v(0, 0)

	scroller:add_child(container)

	if LOCAL_IS_MOBILE then
		scroller.inertia_damping = 0.99
		scroller.inertia_stop_speed = 0.0005
	else
		scroller.inertia_damping = 0.9
		scroller.inertia_stop_speed = 0.001
	end

	container.size.y = self.tot_y
	container.anchor = v(sw / 2, 0)
	container.pos.y = 100
	container.pos.x = scroller_width / 2
	container.propagate_on_down = true
	container.propagate_on_up = true
	container.clip_view = window

	if not LOCAL_IS_MOBILE or ending_version then
		container.size.y = self.tot_y + 100

		local logo
		local i = 1

		while not logo and screen.credits_data[i] do
			if screen.credits_data[i][2] == "image" then
				logo = KImageView:new(screen.credits_data[2][1])

				break
			end

			i = i + 1
		end

		logo.hidden = true
	end

	scroller.propagate_on_click = true
	scroller.can_drag = true

	if LOCAL_IS_MOBILE then
		scroller.drag_limits = V.r(scroller.pos.x, scroller.pos.y, 0, -container.size.y * scroller.scale.y + sh / 4)
	else
		scroller.drag_limits = V.r(scroller.pos.x, scroller.pos.y, 0, -container.size.y * scroller.scale.y)
	end

	if ending_version then
		scroller.drag_limits.size.y = scroller.drag_limits.size.y - sh
	end

	function scroller.on_down()
		self.scroll_paused = true
		self.scroll_paused_time = 0
	end

	function scroller.on_up()
		self.scroll_paused = nil
	end

	self.scroller = scroller

	window:add_child(scroller)

	if not ending_version and LOCAL_IS_MOBILE then
		-- block empty
	end

	if ending_version then
		local skip = GGLabel:new(V.v(128, 100))

		window:add_child(skip)

		local text = IS_MOBILE and _("CINEMATICS_TAP_TO_CONTINUE") or _("CLICK HERE TO SKIP.\nPLEASE DON'T")

		skip.text = text
		skip.pos = v(sw, sh)
		skip.vertical_align = "bottom"
		skip.text_align = "center"
		skip.font_name = "body"
		skip.font_size = 16 * font_size_factor * (IS_TABLET and 0.7 or 1)

		local min_w = skip:do_fit_lines(3)

		if min_w > skip.size.x then
			skip.size.x = min_w
		end

		skip.anchor = v(skip.size.x + 15, skip.size.y + 8)
		skip.colors.text = {
			158,
			119,
			87,
			255
		}
		skip.label_colors = {
			default = {
				158,
				119,
				87,
				255
			},
			hover = {
				232,
				211,
				139,
				255
			}
		}

		function skip.on_click()
			self:on_end_credits()
		end

		function skip.on_enter(this)
			this.colors.text = this.label_colors.hover
		end

		function skip.on_exit(this)
			this.colors.text = this.label_colors.default
		end

		timer:script(function(wait)
			skip.hidden = true
			skip.alpha = 0
			scroller.alpha = 0

			timer:tween(1, scroller, {
				alpha = 1
			}, "in-quad")
			wait(5)

			skip.hidden = false

			timer:tween(0.5, skip, {
				alpha = 1
			}, "in-quad")
		end)
	else
		local back = GG5Button:new("button_credits_close_0001", "button_credits_close_0003")

		back.pos = v(sw - 15 - back.size.x / 2, 15 + back.size.y / 2)
		back.anchor.x = back.size.x / 2
		back.anchor.y = back.size.y / 2
		back.propagate_drag = false
		back.focus_nav_ignore = true

		window:add_child(back)

		function back.on_click(this)
			S:queue("GUIButtonCommon")
			self:on_end_credits()
		end

		function back.on_keypressed(this, key, isrepeat)
			if key == "return" then
				this:on_click()

				return true
			end
		end

		if KR_PLATFORM == "nx" then
			local tbh1 = GGLabel:new(V.v(32, 32))

			tbh1.pos.x, tbh1.pos.y = 130, 116
			tbh1.text = ""
			tbh1.font_name = "symbols_nx"
			tbh1.font_size = 28
			tbh1.text_align = "center"
			tbh1.colors.text = back.label_colors.default
			self.tbh1 = tbh1

			back:add_child(tbh1)
		elseif KR_PLATFORM == "xbox" then
			local tbh1 = GGLabel:new(V.v(32, 32))

			tbh1.pos.x, tbh1.pos.y = 130, 126
			tbh1.text = ""
			tbh1.font_name = "symbols_xbox"
			tbh1.font_size = 28
			tbh1.text_align = "center"
			tbh1.colors.text = back.label_colors.default
			self.tbh1 = tbh1

			back:add_child(tbh1)
		end
	end

	local ism_data = {
		FIRST = {
			{
				"escape",
				true,
				[4] = function()
					self:on_end_credits()
				end
			},
			{
				"return",
				"escape"
			},
			{
				"space",
				true,
				[4] = function()
					self.scroll_paused = not self.scroll_paused
				end
			},
			{
				"up",
				true,
				[4] = self.c_scroll,
				[5] = {
					100
				}
			},
			{
				"down",
				true,
				[4] = self.c_scroll,
				[5] = {
					-100
				}
			},
			{
				"jleftxy",
				ISM.q_rate_limit,
				{
					0.1
				},
				self.c_scroll,
				{
					100
				}
			},
			{
				"ja",
				true,
				[4] = function()
					self.scroll_paused = not self.scroll_paused
				end
			},
			{
				"jb",
				"escape"
			},
			{
				"jdpup",
				"up"
			},
			{
				"jdpdown",
				"down"
			}
		}
	}

	ISM:init(ism_data, window, DEFAULT_KEY_MAPPINGS, storage:load_settings())
end

function screen:destroy()
	ISM:destroy(self.window)
	timer:clear()
	ktw:clear()
	self.window:destroy()

	self.window = nil

	SU.remove_references(self, KView)
end

function screen:on_end_credits()
	if self.end_credits_done then
		return
	end

	self.end_credits_done = true

	timer:script(function(wait)
		if self.ending_version then
			timer:tween(0.1, self.scroller, {
				alpha = 0
			}, "in-quad")
		end

		local t = {
			prevent_loading = false
		}

		if screen.args then
			t.next_item_name = screen.args.after_item_name
		end

		self.done_callback(t)
	end)
end

function screen.c_scroll(ctx, step)
	screen.scroll_paused = true
	screen.scroll_paused_time = 0

	if ctx.axis_value then
		local vx, vy = ctx.axis_value[1], ctx.axis_value[2] * ISM.joy_y_axis_factor

		step = (vy > 0 and 1 or -1) * step
	end

	local dl = screen.scroller.drag_limits

	screen.scroller.pos.y = km.clamp(dl.size.y, dl.pos.y, screen.scroller.pos.y + step)
end

function screen:update(dt)
	timer:update(dt)
	self.window:update(dt)

	if self.scroll_paused then
		if self.scroll_paused_time then
			self.scroll_paused_time = self.scroll_paused_time + dt

			if self.scroll_paused_time > 3 then
				self.scroll_paused = false
				self.scroll_phase = 1
				self.scroll_speed = 0
			end
		end
	else
		if self.scroll_phase == 0 then
			self.waiting_time = self.waiting_time + dt

			if self.waiting_time > 3 then
				self.scroll_phase = 1
			end
		elseif self.scroll_phase == 1 then
			self.scroll_speed = km.clamp(0, self.scroll_speed_max, self.scroll_speed + 0.25)

			if self.scroll_speed == self.scroll_speed_max then
				self.scroll_phase = 2
			end
		elseif self.scroll_phase == 2 then
			local dist = math.abs(self.scroller.pos.y - self.scroller.drag_limits.size.y)

			if dist < 50 then
				if self.ending_version then
					self:on_end_credits()
				else
					self.scroll_phase = 3
				end
			end
		elseif self.scroll_phase == 3 then
			local dist = math.abs(self.scroller.pos.y - self.scroller.drag_limits.size.y)

			self.scroll_speed = self.scroll_speed_max * (dist / 50)

			if self.scroll_speed < 0.1 then
				self.scroll_paused = true
				self.scroll_paused_time = 0

				self:on_end_credits()
			end
		elseif self.scroller.pos.y <= self.scroller.drag_limits.size.y + 1 and not self.scroll_paused then
			self.scroll_paused = true

			self:on_end_credits()
		end

		self.scroller.pos.y = km.clamp(self.scroller.drag_limits.size.y, self.scroller.drag_limits.pos.y, self.scroller.pos.y - self.scroll_speed * dt)
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
