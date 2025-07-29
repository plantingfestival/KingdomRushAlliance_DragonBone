local log = require("klua.log"):new("gg_views_game")

require("klove.kui")

local V = require("klua.vector")
local class = require("middleclass")
local km = require("klua.macros")
local F = require("klove.font_db")
local G = love.graphics
local I = require("klove.image_db")
local i18n = require("i18n")
local kui_db = require("klove.kui_db")
local RC = require("remote_config")
local S = require("sound_db")
local signal = require("hump.signal")
local ISM = require("klove.input_state_machine")
local storage = require("storage")
local U = require("utils")
local GU = require("gui_utils")
local PS = require("platform_services")
local PP = require("privacy_policy_consent")
local map_data = require("data.map_data")
local iap_data = require("data.iap_data")
local SU = require("screen_utils")
local WU = require("window_utils")
local features = require("features")

require("gg_views")

GG5Button = class("GG5Button", GGImageButton)
GG5Button.static.init_arg_names = {
	"default_image_name",
	"focus_image_name"
}

function GG5Button.static.down_bounce_ani(this)
	local w = this:get_window()

	if w and w.ktw then
		local ktw = w.ktw

		ktw:cancel(this)
		ktw:tween(this, 0.016666666666666666, this.scale, V.v(0.95, 0.95), "out-quad")
	end
end

function GG5Button.static.up_bounce_ani(this)
	local w = this:get_window()

	if w and w.ktw then
		local ktw = w.ktw

		ktw:cancel(this)
		ktw:tween(this, 0.03333333333333333, this.scale, V.v(1.05, 1.05), "linear", function()
			ktw:tween(this, 0.03333333333333333, this.scale, V.v(0.98, 0.98), "linear", function()
				ktw:tween(this, 0.03333333333333333, this.scale, V.v(1, 1), "linear")
			end)
		end)
	end
end

function GG5Button:initialize(default_image_name, focus_image_name)
	GGImageButton.initialize(self, default_image_name, default_image_name, default_image_name)

	self.down_scale = nil
	self.down_bounce = true
	self.drag_threshold = 200
	self.focus_image_name = focus_image_name

	if self.focus_image_name then
		local h = KImageView:new(focus_image_name)

		h.anchor.x, h.anchor.y = h.size.x / 2 - self.size.x / 2, h.size.y / 2 - self.size.y / 2
		h.hidden = true

		if self.image_offset then
			h.image_offset = self.image_offset
		end

		self.halo_image = h

		self:add_child(h)
	end

	if self.text_key and self.children and self.children[1]:isInstanceOf(KLabel) then
		self.text = ""

		local c = self.children[1]

		c.text = _(self.text_key)
	end

	if self.children and self.children[1] and self.children[1]:isInstanceOf(KLabel) then
		local c = self.children[1]

		if c.font_name == "fla_h" and c.vertical_align == "top" and c.fit_size then
			c.vertical_align = "middle-caps"
		end
	end
end

function GG5Button:on_enter(drag_view, silent)
	GG5Button.super.on_enter(self, drag_view)

	if not silent and ISM.last_input ~= I_TOUCH then
		S:queue("GUIButtonHover")
	end

	if self.halo_image then
		self.halo_image.hidden = false
	end
end

function GG5Button:on_exit(drag_view)
	GG5Button.super.on_exit(self, drag_view)

	if self.halo_image then
		self.halo_image.hidden = true
	end

	if self.down_bounce then
		self.scale.x, self.scale.y = 1, 1
	end
end

function GG5Button:on_focus(silent)
	GG5Button.super.on_focus(self, silent)

	if self.halo_image then
		self.halo_image.hidden = not ISM:needs_focus_image()
	end
end

function GG5Button:on_keypressed(key, is_repeat)
	if key == "return" and not self:is_disabled() and self.on_click then
		self:on_click()

		return true
	end
end

function GG5Button:on_down(button, x, y)
	GG5Button.super.on_down(self, button, x, y)

	if self.down_bounce then
		GG5Button.static.down_bounce_ani(self)
	end
end

function GG5Button:on_up(button, x, y)
	GG5Button.super.on_up(self, button, x, y)

	if self.down_bounce then
		GG5Button.static.up_bounce_ani(self)
	end
end

function GG5Button:disable(tint, color)
	GG5Button.super.disable(self, tint, color)

	if self.halo_image then
		self.halo_image.hidden = true
	end
end

function GG5Button:enable(tint, color)
	GG5Button.super.enable(self)

	if self.halo_image and self:is_focused() then
		self.halo_image.hidden = false
	end
end

function GG5Button:update(dt)
	GG5Button.super.update(self, dt)

	if self.halo_image then
		if ISM.last_input == I_TOUCH then
			self.halo_image.alpha = 0
		else
			local pa = 1

			if ISM.last_input == I_GAMEPAD then
				pa = U.hover_pulse_alpha(self.ts)
			end

			self.halo_image.alpha = OVtargets(1, 1, 1, 1, pa)
		end
	end
end

function GG5Button:set_focus_image(image_name)
	local h = self.halo_image

	if h then
		h:set_image(image_name)
	end
end

function GG5Button:set_focus_below_child(child)
	local h = self.halo_image

	if h and child then
		h:order_below(child)
	end
end

GG5ToggleButton = class("GG5ToggleButton", GG5Button)
GG5ToggleButton.static.init_arg_names = {
	"true_image_name",
	"false_image_name",
	"focus_image_name"
}

function GG5ToggleButton:initialize(true_image_name, false_image_name, focus_image_name)
	GG5ToggleButton.super.initialize(self, true_image_name, focus_image_name)

	self.down_scale = 0.96
	self.true_image_name = true_image_name
	self.false_image_name = false_image_name
	self.focus_image_name = focus_image_name
	self.value = true
end

function GG5ToggleButton:on_click(button, x, y)
	self:set_value(not self.value)
end

function GG5ToggleButton:set_value(value)
	self.value = value

	local im = value and self.true_image_name or self.false_image_name

	self.default_image_name = im
	self.click_image_name = im
	self.hover_image_name = im

	self:set_image(im)

	if self.on_change then
		self:on_change(value)
	end
end

GG5Label = class("GG5Label", GGLabel)

function GG5Label:initialize(size, image_name)
	GG5Label.super.initialize(self, size, image_name)

	self.disabled_tint_color = {
		150,
		150,
		150,
		168.3
	}

	if self.line_height_extra then
		self:_load_font()

		local h = self.font:getHeight() / self._font_scale
		local nh = h + self.line_height_extra

		self.line_height = nh / h * 0.97
	end

	if features.censored_cn then
		GU.override_color(features.color_overrides, self.colors.text)
	end
end

GG5ShaderLabel = class("GG5ShaderLabel", GG5Label)

GG5ShaderLabel:include(KMShaderDraw)

GG5PopUp = class("GG5PopUp", KView)
GG5PopUp.static.init_arg_names = {
	"size",
	"image_name",
	"base_scale"
}
GG5PopUp.static.fade_in_time = 0.25
GG5PopUp.static.fade_out_time = 0.15
GG5PopUp.static.slide_dist = -60
GG5PopUp.static.base_scale = nil

function GG5PopUp:initialize(size, image_name, base_scale)
	KView.initialize(self, size, image_name)

	self.colors.background = {
		0,
		0,
		0,
		80
	}
	self.disabled_tint_color = nil
	self.hidden = true
	self.pos_shown = V.v(self.pos.x, self.pos.y)
	self.pos = V.v(0, 0)

	local contents = self:get_child_by_id("contents")

	if not contents then
		log.error("GG5PopUp has no contents child.")
	end

	self.contents = contents

	local content_scale = base_scale or GG5PopUp.static.base_scale

	if not content_scale then
		log.error("Remeber to define GG5PopUp.static.base_scale in the screen, before loading the templates")
	end

	self.base_scale = V.v(1, 1)

	if self.contents then
		self.contents.base_scale = content_scale
	end

	local close_button = self:get_child_by_id("button_close_popup")

	if close_button then
		function close_button.on_click(this)
			S:queue("GUIButtonOut")
			self:hide()
		end
	end

	if not self.initial_focus_id and close_button then
		self.initial_focus_id = "button_close_popup"
	end
end

function GG5PopUp:destroy()
	self.contents = nil

	GG5PopUp.super.destroy(self)
end

function GG5PopUp:show()
	if not self.hidden then
		return
	end

	local ktw = self:get_window().ktw

	if not ktw then
		log.error("GG5PopUp require the window to have a klua.tween initialized")
	end

	if self.contents then
		local contents = self.contents
		local fade_time = GG5PopUp.static.fade_in_time
		local slide_dist = self.disable_slide and 0 or GG5PopUp.static.slide_dist

		contents.pos = V.v(self.pos_shown.x, self.pos_shown.y + slide_dist)
		contents.alpha = 0

		ktw:cancel(contents)
		ktw:tween(contents, fade_time / 2, contents, {
			alpha = 1
		}, "in-quad")
		ktw:tween(contents, fade_time, contents, {
			pos = {
				y = self.pos_shown.y
			}
		}, "out-back")
	end

	ktw:cancel(self.colors.background)
	ktw:tween(self.colors.background, GG5PopUp.static.fade_in_time, self.colors.background, {
		0,
		0,
		0,
		190
	}, "in-quad", function()
		self:enable(false)
	end)

	self.propagating = false
	self.propagate_on_click = false
	self.propagate_on_down = false
	self.propagate_drag = false
	self.propagate_on_up = false
	self.hidden = false

	self:disable(false)

	local w = self:get_window()

	if w then
		if w.responder and w.responder ~= w then
			self._last_responder = w.responder
		end

		w:set_responder(self)

		if w.focused then
			self._last_focused = w.focused
		end
	end

	for _, c in pairs(self.children) do
		if not c.hidden and c.on_show then
			c:on_show()
		end
	end

	if self.on_show then
		self:on_show()
	end

	local initial_focus = self.initial_focus_id and self:get_child_by_id(self.initial_focus_id)

	log.debug("self.initial_focus_id:%s -> %s", self.initial_focus_id, initial_focus)

	if initial_focus then
		log.debug("focusing: %s", initial_focus)
		initial_focus:focus(true)
	end
end

function GG5PopUp:hide()
	self:disable(false)

	local ktw = self:get_window().ktw

	if self.contents then
		local contents = self.contents
		local slide_dist = self.disable_slide and 0 or GG5PopUp.static.slide_dist

		ktw:cancel(contents)
		ktw:tween(contents, GG5PopUp.static.fade_out_time, contents, {
			alpha = 0,
			pos = {
				y = self.pos_shown.y + slide_dist
			}
		}, "out-quad")
	end

	ktw:cancel(self.colors.background)
	ktw:tween(self.colors.background, GG5PopUp.static.fade_out_time, self.colors.background, {
		0,
		0,
		0,
		1
	}, "in-quad", function()
		self.hidden = true
	end)

	local w = self:get_window()

	if w then
		if self._last_focused then
			self._last_focused:focus(true)

			self._last_focused = nil
		end

		w:set_responder(self._last_responder or w)

		self._last_responder = nil
	end

	for _, c in pairs(self.children) do
		if not c.hidden and c.on_hide then
			c:on_hide()
		end
	end

	if self.on_hide then
		self:on_hide()
	end
end

function GG5PopUp:update(dt)
	GG5PopUp.super.update(self, dt)

	if self._timer then
		local slow_factor = DEBUG_TIMER_SLOW_FACTOR or 1

		self._timer:update(dt / slow_factor)
	end
end

function GG5PopUp:on_enter()
	return false
end

function GG5PopUp:on_exit()
	return false
end

GG59View = class("GG59View", KView)

GG59View:append_serialize_keys("slice_rect", "overdraw_sides")

GG59View.static.init_arg_names = {
	"image_name",
	"size",
	"slice_rect",
	"overdraw_sides"
}

function GG59View:initialize(image_name, size, slice_rect, overdraw_sides)
	if not slice_rect then
		log.error("No slice_rect. GG59View not created")

		return nil
	end

	if not size then
		log.error("No size. GG59View not created")

		return nil
	end

	local oss = I:s(image_name)

	if not oss then
		log.error("Image not found %s", image_name)

		return nil
	end

	self.image_name = image_name
	self.slice_rect = slice_rect
	self.overdraw_sides = overdraw_sides
	self.canvas = nil
	self.last_size = nil

	GG59View.super.initialize(self, size)

	if self.anchor then
		self.anchor_factor = V.v(self.anchor.x / self.size.x, self.anchor.y / self.size.y)
	end
end

function GG59View:_draw_self()
	if not self.canvas or not self.last_size or self.last_size.x ~= self.size.x or self.last_size.y ~= self.size.y then
		self:redraw()
	end

	GG59View.super._draw_self(self)
end

function GG59View:redraw()
	local oss = I:s(self.image_name)
	local slice_rect = self.slice_rect
	local overdraw_sides = self.overdraw_sides
	local size = self.size
	local ref_scale = oss.ref_scale or 1
	local oim = I:i(oss.atlas)
	local pr, pg, pb, pa = G.getColor()

	G.setColor(255, 255, 255, 255)

	local scx, scy, scw, sch = G.getScissor()
	local imgw, imgh = oss.size[1], oss.size[2]
	local img = G.newCanvas(imgw, imgh)

	G.push()
	G.setScissor()
	G.setCanvas(img)
	G.origin()
	G.clear()
	G.setBlendMode("replace", "premultiplied")
	if oss.textureRotated then
		G.draw(oim, oss.quad, oss.trim[1], oss.trim[2], - math.pi / 2, 1, 1, oss.f_quad[4], 0)
	else
		G.draw(oim, oss.quad, oss.trim[1], oss.trim[2], 0, 1, 1, 0, 0)
	end
	G.pop()

	local p1x, p2x = slice_rect.pos.x / ref_scale, (slice_rect.pos.x + slice_rect.size.x) / ref_scale
	local p1y, p2y = slice_rect.pos.y / ref_scale, (slice_rect.pos.y + slice_rect.size.y) / ref_scale
	local tw1, tw2, tw3 = p1x, slice_rect.size.x / ref_scale, imgw - p2x
	local th1, th2, th3 = p1y, slice_rect.size.y / ref_scale, imgh - p2y
	local o1w, o2w = tw1, size.x / ref_scale - tw3
	local o1h, o2h = th1, size.y / ref_scale - th3
	local cw, ch = size.x / ref_scale - tw1 - tw3, size.y / ref_scale - th1 - th3
	local csw, csh = cw / tw2, ch / th2
	local cx = size.x / (2 * ref_scale) - tw2 / 2
	local cy = size.y / (2 * ref_scale) - th2 / 2

	if csw < 1 or csh < 1 then
		log.warning("GG59View: specified size %s,%s is smaller than which is possible for the slice_rect:%s,%s,%s,%s. Disabling overdraw_sides", size.x, size.y, slice_rect.pos.x, slice_rect.pos.y, slice_rect.size.x, slice_rect.size.y)

		overdraw_sides = false
	end

	local quads = {
		{
			G.newQuad(0, 0, tw1, th1, imgw, imgh),
			G.newQuad(0, p1y, tw1, th2, imgw, imgh),
			G.newQuad(0, p2y, tw1, th3, imgw, imgh)
		},
		{
			G.newQuad(p1x, 0, tw2, th1, imgw, imgh),
			G.newQuad(p1x, p1y, tw2, th2, imgw, imgh),
			G.newQuad(p1x, p2y, tw2, th3, imgw, imgh)
		},
		{
			G.newQuad(p2x, 0, tw3, th1, imgw, imgh),
			G.newQuad(p2x, p1y, tw3, th2, imgw, imgh),
			G.newQuad(p2x, p2y, tw3, th3, imgw, imgh)
		}
	}
	local canvas = G.newCanvas(size.x / ref_scale, size.y / ref_scale)

	G.push()
	G.setCanvas(canvas)
	G.setScissor()
	G.origin()

	local ox, oy = 0, 0
	local draw_list = {
		{
			quads[2][2],
			o1w,
			o1h,
			csw,
			csh
		},
		{
			quads[2][1],
			o1w,
			0,
			csw,
			1
		},
		{
			quads[3][2],
			o2w,
			o1h,
			1,
			csh
		},
		{
			quads[2][3],
			o1w,
			o2h,
			csw,
			1
		},
		{
			quads[1][2],
			0,
			o1h,
			1,
			csh
		}
	}

	if overdraw_sides then
		local draw_sides = {
			{
				quads[2][1],
				cx,
				0,
				1,
				1
			},
			{
				quads[3][2],
				o2w,
				cy,
				1,
				1
			},
			{
				quads[2][3],
				cx,
				o2h,
				1,
				1
			},
			{
				quads[1][2],
				0,
				cy,
				1,
				1
			}
		}

		table.append(draw_list, draw_sides)
	end

	local draw_corners = {
		{
			quads[1][1],
			0,
			0,
			1,
			1
		},
		{
			quads[3][1],
			o2w,
			0,
			1,
			1
		},
		{
			quads[1][3],
			0,
			o2h,
			1,
			1
		},
		{
			quads[3][3],
			o2w,
			o2h,
			1,
			1
		}
	}

	table.append(draw_list, draw_corners)

	for _, d in pairs(draw_list) do
		local q, oox, ooy, sx, sy = unpack(d)

		G.push()
		G.translate(oox, ooy)
		G.draw(img, q, 0, 0, 0, sx, sy)
		G.pop()
	end

	G.pop()
	G.setScissor(scx, scy, scw, sch)
	G.setCanvas()
	G.setColor(pr, pg, pb, pa)
	G.setBlendMode("alpha")

	self.canvas = canvas

	local view_size = V.v(canvas:getDimensions())

	view_size.x, view_size.y = view_size.x * ref_scale, view_size.y * ref_scale

	self:set_image(self.canvas)

	self.size = view_size
	self.image_scale = ref_scale
	self.last_size = V.vclone(self.size)
	self.anchor = V.v(self.anchor_factor.x * self.size.x, self.anchor_factor.y * self.size.y)
end

GG5PopUpOptions = class("GG5PopUpOptions", GG5PopUp)
GG5PopUpOptions.static.init_arg_names = {
	"size",
	"image_name",
	"base_scale"
}

function GG5PopUpOptions:initialize(size, image_name, base_scale)
	GG5PopUpOptions.super.initialize(self, size, image_name, base_scale)
end

function GG5PopUpOptions:show(context)
	self:configure_buttons(context)
	GG5PopUpOptions.super.show(self)

	if context == "map" then
		screen_map:hide_bars()
	end
end

function GG5PopUpOptions:hide(context)
	GG5PopUpOptions.super.hide(self)

	if context == "map" then
		screen_map:show_bars()
	end
end

function GG5PopUpOptions:configure_buttons(context)
	local current_popup = context == "map" and "group_options_page_general" or "group_options_page_general_main"

	if PP:is_underage() then
		if context == "slots" then
			self:get_child_by_id("group_options_page_general_main_underage").hidden = true
		else
			self:get_child_by_id("group_options_page_general_underage").hidden = true
		end

		current_popup = current_popup .. "_underage"
	elseif context == "slots" then
		self:get_child_by_id("group_options_page_general_main").hidden = true
	else
		self:get_child_by_id("group_options_page_general").hidden = true
	end

	local function wid(id)
		return self:get_child_by_id(current_popup):get_child_by_id(id)
	end

	local function set_on_click(id, fn)
		local v = wid(id)

		if v then
			v.on_click = fn
		else
			log.debug("on_click button id not found:%s", id)
		end
	end

	local function set_on_change(id, fn)
		local v = wid(id)

		if v then
			v.on_change = fn
		else
			log.debug("on_change button id not found:%s", id)
		end
	end

	local function set_hidden(id, value)
		local v = wid(id)

		if v then
			v.hidden = value
		else
			log.debug("on_change button id not found:%s", id)
		end
	end

	set_hidden(current_popup, false)

	if wid("label_version") then
		wid("label_version").text = version.string_short
	end

	if KR_PLATFORM == "android" then
		set_hidden("toggle_cloud_save", true)
		set_hidden("label_cloud_save", true)
	else
		set_hidden("toggle_google_play", true)
		set_hidden("label_google_play", true)
	end

	if context == "slots" then
		set_on_click("button_language", function(this)
			S:queue("GUIButtonCommon")

			local w = this:get_window()

			if w then
				local p = this:get_window():ci("popup_locale_list")

				log.error("p:%s", p)

				if p then
					p:show()
				end
			end
		end)
		set_on_click("button_quit", function(this)
			log.error("HERE")

			local cv = this:get_window():ci("popup_confirm")

			if not cv then
				log.error("popup_confirm could not be found")
			else
				cv:set_msg(_("ARE YOU SURE YOU WANT TO QUIT?"))
				cv:set_ok_fn(function()
					love.event.quit()
				end)
				cv:show()
			end
		end)
		set_on_click("button_close_popup", function(this)
			S:queue("GUIButtonOut")
			self:hide("slots")
		end)
	elseif context == "map" then
		set_on_click("button_language", function(this)
			S:queue("GUIButtonCommon")

			local w = this:get_window()

			if w then
				local p = w:get_child_by_id("popup_locale_list")

				log.error("p:%s", p)

				if p then
					p:show()
				end
			end
		end)
		set_on_click("button_quit", function(this)
			screen_map:quit_to_slots()
		end)
		set_on_click("button_main_menu", function(this)
			screen_map:quit_to_slots()
		end)
		set_on_click("button_difficulty", function(this)
			S:queue("GUIButtonCommon")

			local function cb()
				self:refresh_buttons(context)
			end

			screen_map:show_difficulty(cb)
		end)
		set_on_click("button_close_popup", function(this)
			S:queue("GUIButtonOut")
			self:hide("map")
		end)

		if wid("label_restore_purchases") then
			wid("label_restore_purchases").text = _("RESTORE_PURCHASES")
		end

		set_on_click("button_restore_purchases", function(this)
			if PS.services and PS.services.iap then
				signal.emit(SGN_SHOP_SHOW_IAP_PROGRESS)
				PS.services.iap:restore_purchases()
			end
		end)
	end

	set_on_click("toggle_sfx", function(this)
		S:queue("GUIButtonCommon")
		this:set_value(not this.value)
	end)
	set_on_click("toggle_music", function(this)
		S:queue("GUIButtonCommon")
		this:set_value(not this.value)
	end)
	set_on_change("toggle_music", function(this, value)
		local svalue = value and 1 or 0

		S:set_main_gain_music(svalue)

		local settings = storage:load_settings()

		settings.volume_music = km.clamp(0, 1, svalue)

		storage:save_settings(settings)
	end)
	set_on_change("toggle_sfx", function(this, value)
		local svalue = value and 1 or 0

		S:set_main_gain_fx(svalue)

		local settings = storage:load_settings()

		settings.volume_fx = km.clamp(0, 1, svalue)

		storage:save_settings(settings)
	end)
	set_on_click("button_twitter", function(this)
		S:queue("GUIButtonCommon")
		log.info("press button twitter")
		love.system.openURL(RC.v.url_twitter[version.bundle_id] or RC.v.url_twitter.default)
	end)
	set_on_click("button_facebook", function(this)
		S:queue("GUIButtonCommon")
		love.system.openURL(RC.v.url_facebook[version.bundle_id] or RC.v.url_facebook.default)
	end)
	set_on_click("button_instagram", function(this)
		S:queue("GUIButtonCommon")
		love.system.openURL(RC.v.url_instagram[version.bundle_id] or RC.v.url_instagram.default)
	end)
	set_on_click("button_discord", function(this)
		S:queue("GUIButtonCommon")
		love.system.openURL(RC.v.url_discord[version.bundle_id] or RC.v.url_discord.default)
	end)
	set_on_click("button_tiktok", function(this)
		S:queue("GUIButtonCommon")
		love.system.openURL(RC.v.url_tiktok[version.bundle_id] or RC.v.url_tiktok.default)
	end)
	set_on_click("button_more_games", function(this)
		S:queue("GUIButtonCommon")
		love.system.openURL(RC.v.url_ih[version.bundle_id] or RC.v.url_ih.default)
	end)
	set_on_click("button_support", function(this)
		S:queue("GUIButtonCommon")

		local w = this:get_window()

		if w then
			local p = w:get_child_by_id("error_report_view")

			log.error("p:%s", p)

			if p then
				p:show()
			end
		end
	end)
	set_on_click("button_cloudsave", function(this)
		log.error("TODO!")
	end)
	set_on_click("button_achievements", function(this)
		S:queue("GUIButtonCommon")

		local ps_ach = PS.services.achievements

		if ps_ach and ps_ach:get_status() then
			ps_ach:show_achievements()
		end
	end)
	set_on_click("button_credits", function(this)
		director.active_item.done_callback({
			next_item_name = "credits",
			after_item_name = context
		})
	end)
	set_on_click("button_privacy_policy", function()
		S:queue("GUIButtonCommon")
		love.system.openURL(RC.v.url_privacy_policy[version.bundle_id] or RC.v.url_privacy_policy.default)
	end)
	self:refresh_buttons(context)
end

function GG5PopUpOptions:refresh_buttons(context)
	local st = storage:load_settings()

	self:ci("toggle_sfx"):set_value(not st or not st.volume_fx or st.volume_fx ~= 0)
	self:ci("toggle_music"):set_value(not st or not st.volume_music or st.volume_music ~= 0)

	if context == "map" then
		local user_data = storage:load_slot()

		self:ci("label_button_difficulty").text = GU.difficulty_desc(user_data.difficulty)
	end
end

GG5PopUpLocaleList = class("GG5PopUpLocaleList", GG5PopUp)

function GG5PopUpLocaleList:initialize(size, image_name)
	GG5PopUpLocaleList.super.initialize(self, size, image_name)

	local kr5_locales_order = {
		"en",
		"ru",
		"zh-Hant",
		"de",
		"zh-Hans",
		"fr",
		"ko",
		"pt",
		"ja",
		"es"
	}
	local idx = 1
	local item_names = {}
	local root = self:get_child_by_id("contents")

	for _, c in pairs(root.children) do
		if string.starts(c.id, "toggle_language_item_") then
			table.insert(item_names, c.id)
		end
	end

	table.sort(item_names)

	for __, n in pairs(item_names) do
		local c = self:get_child_by_id(n)
		local v = kr5_locales_order[idx]

		idx = idx + 1

		if not v or not table.contains(i18n.supported_locales, v) then
			c.hidden = true
		else
			c.hidden = false

			local label = c:get_child_by_id("label_locale")

			label.text = i18n.locale_names[v]

			if v == "zh-Hant" or v == "zh-Hans" or v == "ko" or v == "ja" then
				label.font_name = "locales_list"
			else
				label.font_name = "fla_numbers_2"
			end

			c.locale = v

			if c.locale == i18n.current_locale then
				function c.on_click(this)
					return
				end
			else
				function c.on_click(this)
					S:queue("GUIButtonCommon")
					this:set_value(not this.value)

					local w = this:get_window()
					local p = w:get_child_by_id("popup_message")

					if not p then
						log.error("GG5PopUpLocaleList requires a GG5PopUpMessage named popup_message in the window!")

						return
					end

					p:set_msg(_("CHANGE_LANGUAGE_QUESTION"))
					p:set_ok_fn(function()
						local settings = storage:load_settings()

						settings.locale = this.locale

						storage:save_settings(settings)
						main:set_locale(this.locale)
						director.active_item.done_callback({
							next_item_name = "slots"
						})
					end)
					p:show()
				end
			end
		end
	end

	self:highlight_locale(i18n.current_locale)
end

function GG5PopUpLocaleList:highlight_locale(locale)
	for _, c in pairs(self:get_child_by_id("contents").children) do
		if string.starts(c.id, "toggle_language_item_") then
			if c.locale == locale then
				c:set_value(true)
			else
				c:set_value(false)
			end
		end
	end
end

GG5PopUpConfirm = class("GG5PopUpConfirm", GG5PopUp)

function GG5PopUpConfirm:initialize(size, image_name)
	GG5PopUpConfirm.super.initialize(self, size, image_name)

	self.disable_slide = true

	local b_ok = self:get_child_by_id("button_popup_ok")
	local b_yes = self:get_child_by_id("button_popup_yes")
	local b_no = self:get_child_by_id("button_popup_no")

	if b_ok then
		function b_ok.on_click(this)
			S:queue("GUIButtonCommon")

			if self.ok_fn then
				self.ok_fn()
			end

			self:hide()
		end
	end

	if b_yes then
		function b_yes.on_click(this)
			S:queue("GUIButtonCommon")

			if self.ok_fn then
				self.ok_fn()
			end

			self:hide()
		end
	end

	if b_no then
		S:queue("GUIButtonCommon")

		function b_no.on_click(this)
			self:hide()
		end
	end
end

function GG5PopUpConfirm:set_msg(msg)
	self:get_child_by_id("label_confirm_msg").text = msg
end

function GG5PopUpConfirm:set_ok_fn(fn)
	self.ok_fn = fn
end

GG5PopUpBugReport = class("GG5PopUpBugReport", GG5PopUp)

function GG5PopUpBugReport:initialize(size, image_name)
	GG5PopUpBugReport.super.initialize(self, size, image_name)

	self.disable_slide = true

	local function start_email(subject)
		local body = "Platform: " .. KR_PLATFORM .. " Language: " .. i18n.current_locale .. " Version: " .. version.string_short .. "\n"

		if PS.services.iap and not PS.services.iap:is_premium() then
			local hero_data = map_data.hero_data_iap
			local hero_order = map_data.hero_order_iap

			body = body .. "Purchases:" .. "\n"

			for _, h in ipairs(hero_order) do
				if not hero_data[h] or not hero_data[h].iap then
					-- block empty
				else
					local p = PS.services.iap:get_product(h)

					if p.owned then
						body = body .. h .. "\n"
					end
				end
			end

			local tower_data = map_data.tower_data_iap
			local tower_order = map_data.tower_order_iap

			for _, t in ipairs(tower_order) do
				if not tower_data[t] or not tower_data[t].iap then
					-- block empty
				else
					local p = PS.services.iap:get_product("tower_" .. t)

					if p and p.owned then
						body = body .. t .. "\n"
					end
				end
			end
		end

		love.system.openURL(string.format("mailto:%s?subject=%s&body=%s", "support@ironhidegames.com", subject, body))
	end

	if self:ci("button_reportlostcontent") then
		self:ci("button_reportlostcontent"):ci("label_button_reportlostcontent").text = _("BUTTON_LOST_CONTENT")
		self:ci("button_reportlostcontent").on_click = function(this)
			S:queue("GUIButtonCommon")
			start_email("Report bug KR5A RESTORE CONTENT " .. os.time())
		end
	end

	if self:ci("button_reportbug") then
		self:ci("button_reportbug"):ci("label_button_reportbug").text = _("BUTTON_BUG_REPORT")
		self:ci("button_reportbug").on_click = function(this)
			S:queue("GUIButtonCommon")
			start_email("Report bug KR5A BUG " .. os.time())
		end
	end

	if self:ci("button_reportcrash") then
		self:ci("button_reportcrash"):ci("label_button_reportcrash").text = _("BUTTON_BUG_CRASH")
		self:ci("button_reportcrash").on_click = function(this)
			S:queue("GUIButtonCommon")
			start_email("Report bug KR5A OTHER " .. os.time())
		end
	end

	if self:ci("button_reportother") then
		self:ci("button_reportother"):ci("label_button_reportother").text = _("BUTTON_BUG_OTHER")
		self:ci("button_reportother").on_click = function(this)
			S:queue("GUIButtonCommon")
			start_email("Report bug KR5A CRASH " .. os.time())
		end
	end

	if self:ci("button_popup_confirm_ok") then
		self:ci("button_popup_confirm_ok"):ci("label_button_ok").text = _("BUTTON_DONE")
		self:ci("button_popup_confirm_ok").on_click = function(this)
			S:queue("GUIButtonCommon")

			if self.ok_fn then
				self.ok_fn()
			end

			self:hide()
		end
	end
end

GG5PopUpPurchasing = class("GG5PopUpPurchasing", GG5PopUp)

function GG5PopUpPurchasing:initialize(size, image_name)
	GG5PopUpPurchasing.super.initialize(self, size, image_name)

	self.disable_slide = true
	self.loading_arrow = self:ci("loading_arrow")
end

function GG5PopUpPurchasing:update(dt)
	GG5PopUpPurchasing.super.update(self, dt)

	self.loading_arrow.r = self.loading_arrow.r - dt * 4
end

GG5PopUpError = class("GG5PopUpError", GG5PopUp)

function GG5PopUpError:initialize(size, image_name)
	GG5PopUpError.super.initialize(self, size, image_name)

	self.disable_slide = true

	local ok = self:ci("button_popup_confirm_ok")

	if ok then
		ok:ci("label_button_ok").text = _("BUTTON_YES")

		function ok.on_click(this)
			S:queue("GUIButtonCommon")

			if self.ok_fn then
				self.ok_fn()
			end

			self:hide()
		end
	end
end

function GG5PopUpError:show(msg)
	GG5PopUpError.super.show(self)

	self:ci("label_error_msg2").text = msg
end

GG5PopUpMessage = class("GG5PopUpMessage", GG5PopUp)

function GG5PopUpMessage:initialize(size, image_name, base_scale)
	GG5PopUpMessage.super.initialize(self, size, image_name, base_scale)

	local b_yes = self:ci("button_popup_yes")
	local b_no = self:ci("button_popup_no")

	if b_yes then
		self:ci("button_popup_yes"):ci("label_button_yes").text = _("BUTTON_YES")

		function b_yes.on_click(this)
			S:queue("GUIButtonCommon")

			if self.ok_fn then
				self.ok_fn()
			end

			self:hide()
		end
	end

	if b_no then
		self:ci("button_popup_no"):ci("label_button_no").text = _("BUTTON_NO")

		function b_no.on_click(this)
			S:queue("GUIButtonCommon")

			if self.no_fn then
				self.no_fn()
			end

			self:hide()
		end
	end
end

function GG5PopUpMessage:show(kind, arg)
	GG5PopUpMessage.super.show(self)

	local function wid(name)
		return self:ci(name)
	end

	self.callback = nil

	if kind == "reward" then
		wid("label_desc").text = string.format(_("ADS_REWARD_EARNED"), arg)
	elseif kind == "reward_error" then
		wid("label_desc").text = _("ADS_NO_REWARD_VIDEO_AVAILABLE")

		if arg and arg.callback then
			self.callback = arg.callback
		end
	elseif kind == "iap_error" then
		local service_name = PS.services.iap and PS.services.iap.SRV_DISPLAY_NAME or "Store"

		wid("label_desc").text = string.format(string.gsub(_("IAP_CONNECTION_ERROR"), "@", "s"), service_name)
	elseif kind == "channel_quit_game" then
		if arg and arg ~= "" then
			local __, title, content = unpack(string.split(arg, "|"))

			wid("label_desc").text = title .. "\n" .. content
		end

		if PS.services.channel then
			wid("button_close_popup").on_click = function(this)
				S:queue("GUIButtonCommon")
				PS.services.channel:quit_game()
			end
		end
	elseif kind == "purchase_pending" then
		wid("label_desc").text = string.format(_("PURCHASE_PENDING_MESSAGE"), arg)
	elseif kind == "ask_for_rating" then
		wid("label_desc").text = _("KR5_RATE_US")
		self:ci("button_popup_yes").hidden = false
		self:ci("button_popup_yes").on_click = function(this)
			S:queue("GUIButtonCommon")

			local global = storage:load_global()

			if global then
				global.rating_accepted = true

				storage:save_global(global)
			end

			self:hide()

			if KR_PLATFORM == "android" then
				local jnia = require("all.jni_android")

				jnia.launch_market()
			end
		end
		self:ci("button_popup_no").on_click = function(this)
			S:queue("GUIButtonCommon")

			local global = storage:load_global()

			if global then
				global.rating_accepted = false

				storage:save_global(global)
			end

			self:hide()
		end
	elseif kind == "iap_progress" then
		wid("label_desc").text = _("PROCESSING YOUR REQUEST")
	elseif kind == "no_gems" then
		wid("label_desc").text = _("KR5_NO_GEMS")
		self:ci("button_popup_yes").on_click = function(this)
			S:queue("GUIButtonCommon")
			-- screen_map:hide_item_room()
			-- screen_map:show_shop(true)
			self:hide()
		end
	else
		log.error("show_message called with unknown kind. skipping")

		return
	end
end

function GG5PopUpMessage:on_hide()
	if self.callback then
		self.callback()
	end
end

function GG5PopUpMessage:set_msg(msg)
	self:get_child_by_id("label_desc").text = msg
end

function GG5PopUpMessage:set_ok_fn(fn)
	self.ok_fn = fn
end

function GG5PopUpMessage:set_no_fn(fn)
	self.no_fn = fn
end

GG5PopUpProcessing = class("GG5PopUpPurchasing", GG5PopUpPurchasing)
GG5PopUpNews = class("GG5PopUpNews", GG5PopUp)

function GG5PopUpNews:initialize(size, image_name, base_scale)
	GG5PopUpNews.super.initialize(self, size, image_name, base_scale)

	self.slider_container = KView:new(V.v(self.size.x, self.size.y))
	self.slider_container.clip = true

	self:ci("news_mask"):add_child(self.slider_container)

	self.slider_view = GG5PopUpNewsSlider:new()
	self.slider_view.id = "group_news_container"
	self.slider_view.size = V.v(self.size.x, self.size.y)
	self.slider_view.can_drag = true
	self.slider_view.inertia_damping = 0.8
	self.slider_view.inertia_stop_speed = 0.01
	self.slider_view.news_width = 1040
	self.slider_view.popup_news = self
	self.slider_view.current_page = 1

	self.slider_container:add_child(self.slider_view)

	self:ci("label_title_news").text = _("NEWS")

	if not IS_MOBILE then
		self:ci("button_news_prev").on_click = function(this)
			S:queue("GUIButtonCommon")
			self:flip_page(-1)
		end
		self:ci("button_news_next").on_click = function(this)
			S:queue("GUIButtonCommon")
			self:flip_page(1)
		end
		self:ci("button_news_open").on_click = function(this)
			S:queue("GUIButtonCommon")
			self:open_link()
		end
	end
end

function GG5PopUpNews:set_pages(amount)
	local full_dot_image = "gui_popups_image_ui_news_whitedot_1_"
	local empty_dot_image = "gui_popups_image_ui_news_whitedot_2_"

	self:ci("group_position_marker"):remove_children()

	local dot_amount = amount - 1
	local dot_separation = 10
	local full_dot = KImageView:new(full_dot_image)

	full_dot.pos.x = 0
	full_dot.anchor = V.v(14.8, 13.4)

	self:ci("group_position_marker"):add_child(full_dot)

	for i = 1, dot_amount do
		local empty_dot = KImageView:new(empty_dot_image)

		empty_dot.pos.x = (42 + dot_separation) * i
		empty_dot.anchor = V.v(14.8, 13.4)

		self:ci("group_position_marker"):add_child(empty_dot)
	end

	self:ci("group_position_marker").pos.x = dot_amount * (42 + dot_separation) / 2 * -1
end

function GG5PopUpNews:activate_dot(index)
	if index <= #self:ci("group_position_marker").children then
		for _, v in ipairs(self:ci("group_position_marker").children) do
			v:set_image("gui_popups_image_ui_news_whitedot_2_")
		end

		self:ci("group_position_marker").children[index]:set_image("gui_popups_image_ui_news_whitedot_1_")

		if self.slider_view.children[index + 1] and self.slider_view.children[index + 1].post then
			signal.emit(SGN_PS_NEWS_URL_SHOWN, self.slider_view.children[index + 1].post.link, "news")
		end
	end
end

function GG5PopUpNews:jump_to_page(idx)
	if self.slider_view then
		self.slider_view:jump_to_page(idx)
	end
end

function GG5PopUpNews:flip_page(dir)
	if self.slider_view then
		self.slider_view:flip_page(dir)
	end
end

function GG5PopUpNews:open_link()
	if self.slider_view then
		self.slider_view:open_link()
	end
end

GG5PopUpMessageChina = class("GG5PopUpMessageChina", GG5PopUp)

function GG5PopUpMessageChina:show(kind, arg)
	GG5PopUpMessageChina.super.show(self)

	self.callback = nil
end

GG5PopUpNewsSlider = class("GG5PopUpNewsSlider", KInertialView)

function GG5PopUpNewsSlider:jump_to_page(idx)
	local page_count = self.size.x / self.news_width - 2

	self.current_page = km.zmod(idx, page_count)
	self.pos.x = -1 * self.current_page * self.news_width

	self.popup_news:activate_dot(self.current_page)
end

function GG5PopUpNewsSlider:open_link()
	local item = self.children[self.current_page + 1]

	if not item then
		return
	end

	log.error("LINK: %s", item.news_url)

	if item.news_url then
		signal.emit(SGN_PS_NEWS_URL_CLICKED, item.news_url, "news")
		love.system.openURL(item.news_url)
	end
end

function GG5PopUpNewsSlider:flip_page(dir)
	self.current_page = self.current_page or 1

	local page_count = self.size.x / self.news_width - 2
	local next_page = self.current_page + dir
	local next_pos = -1 * next_page * self.news_width

	self.current_page = km.zmod(next_page, page_count)

	self.popup_news:activate_dot(self.current_page)

	local ktw = self:get_window().ktw

	if ktw then
		ktw:cancel(self)
		ktw:tween(self, 0.25, self.pos, {
			x = next_pos
		}, "in-quad", function()
			if next_page == 0 then
				self.pos.x = -1 * page_count * self.news_width
			elseif next_page == page_count + 1 then
				self.pos.x = -self.news_width
			end
		end)
	end
end

function GG5PopUpNewsSlider:on_drag()
	if not self.is_dragging then
		self.drag_start_pos = V.vclone(self.pos)
		self.is_dragging = true
	end
end

function GG5PopUpNewsSlider:on_dropped(istouch)
	if self.is_dragging then
		if self.pos.x - self.drag_start_pos.x <= 0 then
			self.current_page = math.floor((self.pos.x + self.news_width / 4) / self.news_width)
		else
			self.current_page = math.floor((self.pos.x + self.news_width - self.news_width / 4) / self.news_width)
		end

		self.current_page = self.current_page * -1

		local w = self:get_window()

		if w and w.ktw then
			local ktw = w.ktw

			ktw:cancel(self)
			ktw:tween(self, 0.2, self, {
				pos = V.v(self.current_page * self.news_width * -1, 0)
			}, "linear", function()
				if self.current_page == 0 then
					self.current_page = #self.children - 2
					self.pos.x = self.current_page * self.news_width * -1
				elseif self.current_page == #self.children - 1 then
					self.current_page = 1
					self.pos.x = -self.news_width
				end

				self.popup_news:activate_dot(self.current_page)
			end)
		end

		self.is_dragging = false
	end
end

GG5PopUpIngameOptions = class("GG5PopUpIngameOptions", GG5PopUp)

function GG5PopUpIngameOptions:initialize(size, image_name, base_scale)
	GG5PopUpIngameOptions.super.initialize(self, size, image_name, base_scale)

	self:ci("button_restart").on_click = function(this)
		S:queue("GUIButtonCommon")

		local w = this:get_window()
		local p = w:get_child_by_id("popup_message")

		if not p then
			log.error("GG5PopUpIngameOptions requires a GG5PopUpMessage named popup_message in the window!")

			return
		end

		p:set_msg(_("CONFIRM_RESTART"))
		p:set_ok_fn(function()
			this:disable()

			self.skip_resume = true

			game.game_gui.c_restart_game()
		end)
		p:show()
	end
	self:ci("button_quit").on_click = function(this)
		S:queue("GUIButtonCommon")

		local w = this:get_window()
		local p = w:get_child_by_id("popup_message")

		if not p then
			log.error("GG5PopUpIngameOptions requires a GG5PopUpMessage named popup_message in the window!")

			return
		end

		p:set_msg(_("CONFIRM_EXIT"))
		p:set_ok_fn(function()
			this:disable()

			self.skip_resume = true

			game.game_gui.c_go_to_map()
		end)
		p:show()
	end
	self:ci("button_close_popup").on_click = function(this)
		this:disable()
		S:queue("GUIButtonOut")
		game.game_gui.c_resume()
	end
	self:ci("toggle_ingame_music").on_click = function(this)
		S:queue("GUIButtonCommon")
		this:set_value(not this.value)
	end
	self:ci("toggle_ingame_sfx").on_click = function(this)
		S:queue("GUIButtonCommon")
		this:set_value(not this.value)
	end
	self:ci("toggle_ingame_music").on_change = function(this, value)
		local svalue = value and 1 or 0

		S:set_main_gain_music(svalue)

		local settings = storage:load_settings()

		settings.volume_music = km.clamp(0, 1, svalue)

		storage:save_settings(settings)
	end
	self:ci("toggle_ingame_sfx").on_change = function(this, value)
		local svalue = value and 1 or 0

		S:set_main_gain_fx(svalue)

		local settings = storage:load_settings()

		settings.volume_fx = km.clamp(0, 1, svalue)

		storage:save_settings(settings)
	end
end

function GG5PopUpIngameOptions:show()
	GG5PopUpIngameOptions.super.show(self)

	self.skip_resume = nil

	self:ci("button_restart"):enable()
	self:ci("button_quit"):enable()
	self:ci("button_close_popup"):enable()

	local st = storage:load_settings()

	self:ci("toggle_ingame_sfx"):set_value(not st or not st.volume_fx or st.volume_fx ~= 0)
	self:ci("toggle_ingame_music"):set_value(not st or not st.volume_music or st.volume_music ~= 0)
end

GG5BalloonView = class("GG5BalloonView", KView)
GG5BalloonView.static.init_arg_names = {
	"max_size",
	"prefix",
	"flags",
	"text",
	"title",
	"text_padding",
	"text_separation",
	"background_color",
	"line_color",
	"text_color",
	"title_color"
}

function GG5BalloonView:initialize(max_size, prefix, flags, text, title, text_padding, text_separation, background_color, line_color, text_color, title_color)
	max_size = max_size or V.v(256, 0)

	if self._deserialize_table then
		text = self._deserialize_table.text_key and _(self._deserialize_table.text_key) or text
		title = self._deserialize_table.title_key and _(self._deserialize_table.title_key) or title
	end

	if not text then
		log.error("Text is required for GGBalloonView with id %s", self.id)
	end

	local title_font, title_font_size = "body_bold", 30

	title_color = title_color or {
		16,
		101,
		161,
		255
	}

	local title_align = "left"
	local title_line_height = 0.85
	local text_font = "body"
	local text_font_size = title and 22 or 28

	text_color = text_color or {
		70,
		56,
		47,
		255
	}

	local text_align, text_vertical_align = "left", "middle"
	local text_line_height = 0.85
	local fit_lines, direction
	local padding = text_padding or V.v(10, 10)
	local separation = text_separation or 0

	background_color = background_color or {
		254,
		243,
		213,
		255
	}
	line_color = line_color or {
		127,
		104,
		86,
		255
	}

	local tip_offset = V.v(30, 0)
	local tip_size = 15

	local function mf(t)
		return string.find(flags, t, 1, true) ~= nil
	end

	if mf("red_title") then
		title_color = {
			156,
			0,
			4,
			255
		}
	end

	if mf("cyan_title") then
		title_color = {
			0,
			133,
			160,
			255
		}
	end

	if mf("blue_text") then
		text_color = {
			16,
			101,
			161,
			255
		}
	end

	if mf("yellow_text") then
		text_color = {
			255,
			255,
			0,
			255
		}
	end

	if mf("centered") then
		title_align = "center"
		text_align = "center"
	end

	if mf("one_line") then
		fit_lines = 1
	end

	if mf("small_title") then
		title_font_size = 22
	end

	if mf("medium_font") then
		title_font_size = 24
		text_font_size = 24
	end

	if mf("large_font") then
		title_font_size = 34
		text_font_size = 34
	end

	if mf("direction_v") then
		direction = "v"
	end

	if mf("direction_h") then
		direction = "h"
	end

	if mf("dialog") then
		text_font_size = 17
	end

	local l_title

	if title then
		l_title = GGLabel:new(max_size)
		l_title.text = title
		l_title.font_name = title_font
		l_title.font_size = title_font_size
		l_title.text_align = title_align
		l_title.fit_lines = fit_lines
		l_title.line_height = title_line_height

		if not l_title.colors then
			l_title.colors = {}
		end

		l_title.colors.text = title_color

		l_title:_load_font()
		l_title:_fit_text()

		local tw, tc = l_title:get_wrap_lines()
		local th = l_title:get_font_height()

		l_title.size.x = tw
		l_title.size.y = math.ceil(tc * th * title_line_height)
		text_vertical_align = "top"
	end

	local l_text = GGLabel:new(max_size)

	l_text.text = text
	l_text.font_name = text_font
	l_text.font_size = text_font_size
	l_text.text_align = text_align
	l_text.fit_lines = fit_lines
	l_text.vertical_align = text_vertical_align
	l_text.line_height = text_line_height

	if not l_text.colors then
		l_text.colors = {}
	end

	l_text.colors.text = text_color

	l_text:_load_font()
	l_text:_fit_text()

	local tw, tc = l_text:get_wrap_lines()
	local th = l_text:get_font_height()

	l_text.size.x = tw
	l_text.size.y = math.ceil(tc * th * text_line_height)

	local block_size = V.v(math.max(l_title and l_title.size.x or 0, l_text.size.x), (l_title and l_title.size.y or 0) + separation + l_text.size.y)

	if l_title then
		l_title.size.x = block_size.x
	end

	l_text.size.x = block_size.x

	GG5BalloonView.super.initialize(self, V.v(block_size.x + 2 * padding.x, block_size.y + 2 * padding.y))

	if mf("callout-") then
		local bw, bh = self.size.x, self.size.y
		local background = KView:new(V.v(bw, bh))

		if mf("left") then
			background.scale.x = -1
			tip_offset.x = bw - bw / 4
			self.anchor.x = bw / 4
		elseif mf("right") then
			tip_offset.x = bw - bw / 4
			self.anchor.x = 3 * bw / 4
		else
			tip_offset.x = bw / 2
			self.anchor.x = bw / 2
		end

		if mf("top") then
			background.scale.y = -1
			self.anchor.y = 0 - tip_size
		elseif mf("bottom") then
			self.anchor.y = bh + tip_size
		else
			log.todo("TODO: implement side callouts")

			self.anchor.y = bh / 2
		end

		local vertices = GU.rounded_rectangle(0, 0, bw, bh, 5, tip_offset, 1.6)

		background.colors.background = background_color
		background.shape = {
			name = "polygon",
			args = vertices
		}
		background.propagate_on_click = true
		background.anchor = V.v(bw / 2, bh / 2)
		background.pos = V.v(bw / 2, bh / 2)

		self:add_child(background)

		local border_vertices = table.clone(vertices)

		border_vertices[1] = "line"

		local line = KView:new(V.v(bw, bh))

		line.colors.background = line_color
		line.shape = {
			name = "polygon",
			args = border_vertices
		}
		line.propagate_on_click = true

		background:add_child(line)
	else
		local background = GG9SlicesView:new(V.v(block_size.x + 2 * padding.x, block_size.y + 2 * padding.y), prefix, direction)

		self:add_child(background)

		self.size.x = background.size.x
		self.size.y = background.size.y

		if mf("left") then
			self.anchor.x = 0
		elseif mf("right") then
			self.anchor.x = self.size.x
		else
			self.anchor.x = self.size.x / 2
		end

		if mf("top") then
			self.anchor.y = 0
		elseif mf("bottom") then
			self.anchor.y = self.size.y
		else
			self.anchor.y = self.size.y / 2
		end
	end

	if DEBUG then
		-- block empty
	end

	local x_margin = math.floor((self.size.x - block_size.x) * 0.5)
	local y_margin = math.floor((self.size.y - block_size.y) * 0.5)

	if l_title then
		l_title.pos = V.v(x_margin, y_margin)
		l_text.pos = V.v(x_margin, l_title.pos.y + l_title.size.y + separation)

		self:add_child(l_title)
	else
		l_text.pos = V.v(x_margin, y_margin)
	end

	self:add_child(l_text)

	if mf("ani-") then
		self.timer = require("hump.timer").new()
	end

	if mf("ani-pulse") then
		self.timer:script(function(wait)
			while true do
				self.timer:tween(0.4, self.scale, {
					x = 0.98,
					y = 0.98
				})
				wait(0.4)
				self.timer:tween(0.4, self.scale, {
					x = 1,
					y = 1
				})
				wait(0.4)
			end
		end)
	end
end

function GG5BalloonView:update(dt)
	GG5BalloonView.super.update(self, dt)

	if self.timer then
		self.timer:update(dt)
	end
end

GG5AlphaTweenView = class("GG5AlphaTweenView", KView)

function GG5AlphaTweenView:do_tween(alpha_start, alpha_end, tween_time)
	self.alpha = alpha_start

	local w = self:get_window()

	if w and w.ktw then
		local ktw = w.ktw

		ktw:cancel(self)
		ktw:tween(self, tween_time, self, {
			alpha = alpha_end
		}, "in-quad")
	end
end

GG5Pager = class("GG5Pager", KView)

function GG5Pager:initialize(size, image, base_scale)
	GG5Pager.super.initialize(self, size, image, base_scale)
end

function GG5Pager:setup(page_count, page_view, page_change_fn)
	self.page_view = page_view
	self.page_change_fn = page_change_fn
	self.page_count = page_count

	local btpl = self:ci("button_page_01")

	btpl.hidden = true

	local bg = self:ci("pager_bg")

	bg.size.x = bg.size.x + btpl.size.x * 1.1 * (page_count - 1)

	for i = 1, page_count do
		local b = btpl.class:new_from_table(kui_db:get_table(btpl.template_name))

		self:add_child(b)

		b.id = string.format("pager_page_%02i", i)
		b.pos.y = btpl.pos.y
		b.pos.x = btpl.pos.x + (i - 1) * btpl.size.x * 1.1
		b.page_idx = i
		b:ci("label_page").text = i

		function b.on_click(this)
			self:show_page(this.page_idx)
			S:queue("GUIButtonOut")
		end

		function b.on_focus(this)
			this.class.super.on_focus(this)
			this:on_click()
		end
	end
end

function GG5Pager:show_page(page_idx)
	if type(page_idx) == "string" then
		self.page_idx = self.page_idx or 1

		local dir = page_idx

		if dir == "next" then
			page_idx = km.clamp(1, self.page_count, self.page_idx + 1)
		elseif dir == "prev" then
			page_idx = km.clamp(1, self.page_count, self.page_idx - 1)
		end

		self.page_idx = page_idx
	end

	local show_id = string.format("pager_page_%02i", page_idx)
	local show_b = self:ci(show_id)

	if not show_b then
		log.error("could not find pager button for page: %s", page_idx)

		return
	end

	if not show_b.value then
		return
	end

	for _, c in pairs(self.children) do
		if string.starts(c.id, "pager_page_") then
			c:set_value(true)
		end
	end

	show_b:set_value(false)
	self.page_change_fn(self.page_view, page_idx)
end

GG5Slider = class("GG5Slider", KImageView)
GG5Slider.static.serialize_children = false

GG5Slider:append_serialize_keys("style", "range")

GG5Slider.static.init_arg_names = {
	"style",
	"range"
}

function GG5Slider:initialize(style, range)
	GG5Slider.super.initialize(self)

	local value_bar = self:ci("bar")
	local knob = self:ci("knob")
	local knobi = knob:ci("image")

	self.style = style or nil
	self.range = range or {
		0,
		1
	}
	self.value = (self.range[2] - self.range[1]) / 2
	self.steps = 25
	self.sfx_preview_sound = "GUISpellRefresh"

	if self.style == "music" then
		knobi:set_image("gui_popups_desktop_image_slider_knob_music_")
	elseif self.style == "sfx" then
		knobi:set_image("gui_popups_desktop_image_slider_knob_fx_")
	end

	knob.pos.x = value_bar.pos.x
	knob.focus_nav_ignore = true
	knobi.focus_nav_ignore = true

	function knobi.on_down(this, button, x, y)
		self._sliding = true

		if not self:is_focused() then
			self:focus()
		end
	end

	function knobi.on_up(this, button, x, y)
		self._sliding = nil

		if self.style == "sfx" then
			S:queue(self.sfx_preview_sound)
		end
	end

	function knobi.on_enter(this, drag_view, silent)
		if self.halo then
			self.halo.hidden = false
		end

		if not silent then
			S:queue("GUIButtonHover")
		end
	end

	function knobi.on_exit(this, drag_view)
		if self.halo then
			self.halo.hidden = true
		end
	end

	local ha = self:ci("glow")

	ha.propagate_on_click = true
	ha.hidden = true
	ha.track_button = knob

	function ha.update(this, dt)
		if ISM.last_input == I_TOUCH then
			this.alpha = 0
		else
			local pa = 1

			if ISM.last_input == I_GAMEPAD then
				this.ts = this.ts + dt
				pa = U.hover_pulse_alpha(this.ts)
			end

			this.alpha = OVtargets(1, 1, 1, 1, pa)
		end
	end

	self.value_bar = value_bar
	self.knob = knob
	self.halo = ha

	function self.on_focus(this)
		self.halo.hidden = false
	end

	function self.on_defocus(this)
		self.halo.hidden = true
	end

	function self.on_keypressed(this, key)
		if key == "right" or key == "left" then
			self.halo.hidden = false

			local dir = key == "right" and 1 or -1
			local step = (self.range[2] - self.range[1]) / self.steps

			self:set_value(self.value + dir * step)

			if self.style == "sfx" then
				S:queue(self.sfx_preview_sound)
			end

			return true
		end
	end

	self:set_value(self.value)
end

function GG5Slider:update(dt)
	GG5Slider.super.update(self, dt)

	local x, y, is_button_down = self:get_window():get_mouse_position()

	if not is_button_down then
		self._sliding = nil

		return
	end

	if self._sliding then
		local wx, wy = self:screen_to_view(x, y)
		local vbx = self.value_bar.pos.x
		local vbw = self.value_bar.size.x
		local phase = km.clamp(0, vbw, wx - vbx) / vbw
		local r1, r2 = unpack(self.range)
		local value = r1 + (r2 - r1) * phase

		self:set_value(value)
	end
end

function GG5Slider:set_value(value)
	if type(value) ~= "number" then
		log.error("trying to set slider to a non number value: %s", value)

		return
	end

	local r1, r2 = unpack(self.range)

	value = km.clamp(r1, r2, value)
	self.value = value
	self.phase = (value - r1) / (r2 - r1)
	self.value_bar.scale.x = self.phase

	local vbx = self.value_bar.pos.x
	local vbw = self.value_bar.size.x

	self.knob.pos.x = vbx + vbw * self.phase

	if self.on_change then
		self:on_change(value)
	end
end

function GG5Slider:set_range(range, steps)
	if not range then
		return
	end

	self.range = table.deepclone(range)
	self.value = range[1]
	self.steps = steps or self.steps
end

GG5PopUpOptionsDesktop = class("GG5PopUpOptionsDesktop", GG5PopUp)

function GG5PopUpOptionsDesktop:initialize(size, image_name, base_scale)
	GG5PopUpOptionsDesktop.super.initialize(self, size, image_name, base_scale)

	self:ci("controller_settings_reset_button").on_click = function(this)
		S:queue("GUIButtonCommon")
		ISM:reset_prop_values()
		self:reload_slider_values()
	end

	if self:ci("button_credits") then
		self:ci("button_credits").on_click = function(this)
			S:queue("GUIButtonCommon")
			director.active_item.done_callback({
				next_item_name = "credits",
				after_item_name = self.context
			})
		end
	end

	if self.context == "slots" then
		local c_highdpi = self:ci("toggle_options_highdpi")
		local c_fs = self:ci("toggle_options_fullscreen")
		local c_mp = self:ci("toggle_options_large_mouse_pointer")
		local l_highdpi = self:ci("label_options_highdpi")
		local l_mp = self:ci("label_options_large_mouse_pointer")
		local sl_disp = self:ci("selectlist_display")
		local sl_fps = self:ci("selectlist_fps")
		local sl_tex = self:ci("selectlist_image_quality")
		local sl_res = self:ci("selectlist_resolution")
		local texture_size_list

		if features.main_params and features.main_params.texture_size_list then
			texture_size_list = features.main_params.texture_size_list
		elseif features.main_params and features.main_params.texture_size then
			texture_size_list = {
				{
					"HD",
					features.main_params.texture_size
				}
			}
		else
			texture_size_list = {
				{
					"Full HD",
					"fullhd"
				},
				{
					"HD",
					"ipad"
				}
			}
		end

		for _, r in pairs(texture_size_list) do
			sl_tex:add_item(r[1], r[2])
		end

		for _, r in pairs({
			{
				"60",
				60
			},
			{
				"30",
				30
			}
		}) do
			sl_fps:add_item(r[1], r[2])
		end

		function c_fs.on_change(this, value)
			if this.value then
				c_highdpi:set_value(false)
				c_highdpi:disable()

				c_highdpi.hidden = true
				l_highdpi.hidden = true
				c_mp.hidden = false
				l_mp.hidden = false
			else
				c_highdpi:enable()

				c_highdpi.hidden = love.system.getOS() ~= "OS X"
				l_highdpi.hidden = c_highdpi.hidden
				c_mp.hidden = true
				l_mp.hidden = true
			end
		end

		c_highdpi.hidden = love.system.getOS() == "OS X"

		function c_highdpi.on_change(this, value)
			self:update_resolutions_list(c_fs.value, c_highdpi.value, sl_disp.selected_item and sl_disp.selected_item.custom_value)
		end

		l_highdpi.hidden = c_highdpi.hidden
		self:ci("video_settings_apply_button").on_click = function(this)
			self:apply_video_settings()
		end
	elseif self.context == "map" then
		self:ci("options_main_menu_button").on_click = function(this)
			S:queue("GUIButtonCommon")
			screen_map:quit_to_slots()
		end

		local user_data = storage:load_slot()

		self:ci("label_button_difficulty").text = GU.difficulty_desc(user_data.difficulty)
		self:ci("options_difficulty_button").on_click = function(this)
			S:queue("GUIButtonCommon")
			screen_map:show_difficulty(function()
				local slot = storage:load_slot()

				self:ci("label_button_difficulty").text = GU.difficulty_desc(slot.difficulty)
			end)
		end
	elseif self.context == "ingame" then
		self:ci("button_close_popup").on_click = function(this)
			this:disable(false)
			S:queue("GUIButtonOut")
			game.game_gui.c_resume()
		end
		self:ci("options_quit_button").on_click = function(this)
			S:queue("GUIButtonCommon")
			this:disable(false)
			game.game_gui.c_go_to_map()
		end
		self:ci("options_restart_button").on_click = function(this)
			this:disable(false)
			S:queue("GUIButtonCommon")
			game.game_gui.c_restart_game()
		end
		self:ci("options_continue_button").on_click = function(this)
			this:disable(false)
			S:queue("GUIButtonCommon")
			game.game_gui.c_resume()
		end
	end

	local function get_all_with_id(parent_id, id)
		return self:ci(parent_id):flatten(function(this)
			return this.id == id
		end)
	end

	local url_buttons = {
		{
			"button_privacy_policy",
			RC.v.url_privacy_policy[version.bundle_id] or RC.v.url_privacy_policy.default
		},
		{
			"button_more_games",
			RC.v.url_ih[version.bundle_id] or RC.v.url_ih.default
		},
		{
			"button_twitter",
			RC.v.url_twitter[version.bundle_id] or RC.v.url_twitter.default
		},
		{
			"button_facebook",
			RC.v.url_facebook[version.bundle_id] or RC.v.url_facebook.default
		},
		{
			"button_instagram",
			RC.v.url_instagram[version.bundle_id] or RC.v.url_instagram.default
		},
		{
			"button_discord",
			RC.v.url_discord[version.bundle_id] or RC.v.url_discord.default
		},
		{
			"button_tiktok",
			RC.v.url_tiktok[version.bundle_id] or RC.v.url_tiktok.default
		},
		{
			"button_more_games",
			RC.v.url_ih[version.bundle_id] or RC.v.url_ih.default
		}
	}

	for _, row in pairs(url_buttons) do
		local id, url = unpack(row)

		for _, c in pairs(get_all_with_id("page_01", id)) do
			function c.on_click(this)
				S:queue("GUIButtonCommon")
				love.system.openURL(url)
			end
		end
	end

	for _, c in pairs(get_all_with_id("page_01", "label_version")) do
		c.text = version.string_short
	end

	local function slider_on_change(this, value)
		if this.id == "volume_fx" then
			S:set_main_gain_fx(value)
		elseif this.id == "volume_music" then
			S:set_main_gain_music(value)
		elseif string.starts(this.id, "joy_") then
			ISM:set_prop(this.id, value)
		end
	end

	for _, view in pairs(self:ci("page_01").children) do
		for _, c in pairs(view.children) do
			if c:isInstanceOf(GG5Slider) then
				c.on_change = slider_on_change
			end
		end
	end

	for _, c in pairs(self:ci("page_03").children) do
		if c:isInstanceOf(GG5Slider) then
			c.on_change = slider_on_change
		end
	end

	if self:ci("button_language") then
		self:ci("button_language").on_click = function(this)
			S:queue("GUIButtonCommon")

			local w = this:get_window()

			if w then
				local p = this:get_window():ci("popup_locale_list")

				log.error("could not find popup_locale_list")

				if p then
					p:show()
				end
			end
		end
	end

	self.page_idx = 1
	self.pages = {}

	for i = 1, #self:ci("contents").children do
		local p = self:ci("contents"):ci(string.format("page_%02i", i))

		if i == 5 and self.context ~= "slots" then
			p.hidden = true
		elseif p then
			table.insert(self.pages, p)
		end
	end

	self:ci("pager"):setup(#self.pages, self, self.show_page)
	self:ci("pager"):show_page(1)
end

function GG5PopUpOptionsDesktop:show_page(page_idx)
	local p_name = string.format("page_%02i", page_idx)

	for __, p in pairs(self.pages) do
		if p.id == p_name then
			p.hidden = false

			if p.title_key then
				self:ci("title_text").text = _(p.title_key)
			end
		else
			p.hidden = true
		end
	end
end

function GG5PopUpOptionsDesktop:change_page(dir)
	self:ci("pager"):show_page(dir)
end

function GG5PopUpOptionsDesktop:reload_slider_values()
	local settings = storage:load_settings()

	for _, view in pairs(self:ci("page_01").children) do
		for _, c in pairs(view.children) do
			if c:isInstanceOf(GG5Slider) then
				c:set_value(settings[c.id] and settings[c.id] or 1)
			end
		end
	end

	for _, c in pairs(self:ci("page_03").children) do
		if c:isInstanceOf(GG5Slider) then
			c:set_range(ISM:get_prop_range(c.id))
			c:set_value(ISM:get_prop(c.id))
		end
	end
end

function GG5PopUpOptionsDesktop:reload_video_settings()
	local params = table.deepclone(storage:load_settings())
	local c_highdpi = self:ci("toggle_options_highdpi")
	local c_fs = self:ci("toggle_options_fullscreen")
	local c_mp = self:ci("toggle_options_large_mouse_pointer")
	local sl_disp = self:ci("selectlist_display")
	local sl_tex = self:ci("selectlist_image_quality")
	local sl_fps = self:ci("selectlist_fps")

	for _, c in pairs(sl_fps.children) do
		if c.custom_value == params.fps then
			sl_fps:select_item(c)
			sl_fps:scroll_to_show_y(c.pos.y)

			break
		end
	end

	self:ci("toggle_options_fullscreen"):set_value(params.fullscreen)
	self:ci("toggle_options_highdpi"):set_value(params.highdpi)
	self:update_displays_list(params.fullscreen)
	self:select_display(params.display)
	self:update_resolutions_list(c_fs.value, c_highdpi.value, sl_disp.selected_item and sl_disp.selected_item.custom_value)

	if params.player_customized then
		self:select_resolution(V.v(params.width, params.height), true)

		for _, c in pairs(sl_tex.children) do
			if c.custom_value == params.texture_size then
				sl_tex:select_item(c)
				sl_tex:scroll_to_show_y(c.pos.y)
			end
		end
	else
		local bw, bh = WU.get_best_fullscreen_resolution()

		c_fs:set_value(true)
		self:select_resolution(V.v(bw, bh), false)
	end

	self:ci("toggle_options_vsync"):set_value(params.vsync)
	self:ci("toggle_options_borderless"):set_value(params.fullscreentype == "desktop")
	self:ci("toggle_options_large_mouse_pointer"):set_value(params.large_pointer)
end

function GG5PopUpOptionsDesktop:update_resolutions_list(fullscreen, highdpi, display)
	local v = V.v
	local fallback_resolutions = {
		v(800, 600),
		v(1024, 768),
		v(1300, 768),
		v(1500, 800),
		v(1422, 800),
		v(1600, 1080),
		v(1365, 768),
		v(1280, 720),
		v(1600, 900),
		v(1920, 1080),
		v(1920, 1080),
		v(2048, 1080),
		v(2048, 1536),
		v(2560, 1440),
		v(2560, 1600),
		v(3840, 2160)
	}
	local display_resolutions = {}
	local full_screen_modes = love.window.getFullscreenModes(display)

	if full_screen_modes and #full_screen_modes > 0 and (fullscreen or full_screen_modes[1].width > full_screen_modes[1].height) then
		for _, item in pairs(love.window.getFullscreenModes(display)) do
			table.insert(display_resolutions, v(tonumber(item.width), tonumber(item.height)))
		end
	else
		display_resolutions = fallback_resolutions
	end

	table.sort(display_resolutions, function(r1, r2)
		return r1.x > r2.x or r1.x == r2.x and r1.y > r2.y
	end)

	local resolutions = {}
	local dt_w, dt_h = love.window.getDesktopDimensions()

	for _, r in pairs(display_resolutions) do
		local aspect = r.x / r.y

		if (not fullscreen or KR_OS == "GDK Desktop") and (aspect > 1.7777777777777777 or aspect < 1.3333333333333333) then
			-- block empty
		elseif r.x < 640 or r.y < 480 then
			-- block empty
		elseif not fullscreen and (highdpi or KR_OS == "GDK Desktop") and (dt_w < r.x or dt_h < r.y) then
			-- block empty
		else
			table.insert(resolutions, r)
		end
	end

	local function cb_on_select(this)
		local c_highdpi = self:get_window():ci("toggle_options_highdpi")
		local sl_tex = self:get_window():ci("selectlist_image_quality")

		if features.main_params and features.main_params.texture_size_list then
			local picked_size, picked_threshold

			for _, row in pairs(features.main_params.texture_size_list) do
				local name, size, threshold = unpack(row)

				if threshold then
					if picked_size == nil then
						picked_size = size
					end

					if picked_threshold == nil then
						picked_threshold = threshold
					end

					if this.custom_value and this.custom_value.y and threshold > this.custom_value.y * (c_highdpi.checked and 2 or 1) and threshold < picked_threshold then
						picked_threshold = threshold
						picked_size = size

						log.todo("picked_threshold:%s picked_size:%s", picked_threshold, picked_size)
					end
				end
			end

			if picked_size then
				for _, c in pairs(sl_tex.children) do
					if c.custom_value == picked_size then
						sl_tex:select_item(c)
						sl_tex:scroll_to_show_y(c.pos.y)
					end
				end
			end
		end
	end

	local sl_res = self:ci("selectlist_resolution")
	local prev_selection

	if sl_res.selected_item then
		prev_selection = {
			x = sl_res.selected_item.custom_value.x,
			y = sl_res.selected_item.custom_value.y
		}
	end

	sl_res:clear_rows()

	for _, r in pairs(resolutions) do
		sl_res:add_item(string.format("%s x %s", r.x, r.y), r, cb_on_select)
	end

	if prev_selection then
		self:select_resolution(prev_selection, true)
	end
end

function GG5PopUpOptionsDesktop:select_resolution(res, ignore_callback)
	local sl_res = self:get_window():ci("selectlist_resolution")

	for _, c in pairs(sl_res.children) do
		if c.custom_value.x == res.x and c.custom_value.y == res.y then
			sl_res:select_item(c, ignore_callback)
			sl_res:scroll_to_show_y(c.pos.y)

			break
		end
	end
end

function GG5PopUpOptionsDesktop:update_displays_list(fullscreen)
	local sl_disp = self:get_window():ci("selectlist_display")
	local c_fs = self:ci("toggle_options_fullscreen")
	local c_highdpi = self:ci("toggle_options_highdpi")
	local prev_sel

	if sl_disp.selected_item then
		prev_sel = sl_disp.selected_item.custom_value
	end

	sl_disp:clear_rows()

	sl_disp.select_item = nil

	local function cb_on_select(this)
		local display = sl_disp.selected_item and sl_disp.selected_item.custom_value

		self:update_resolutions_list(c_fs.value, c_highdpi.value, display)
	end

	for i = 1, love.window.getDisplayCount() do
		sl_disp:add_item(string.format("Display %s (%s)", i, love.window.getDisplayName(i)), i, cb_on_select)
	end

	if prev_sel then
		self:select_display(prev_sel)
	end
end

function GG5PopUpOptionsDesktop:select_display(display)
	local sl_disp = self:ci("selectlist_display")

	for _, c in pairs(sl_disp.children) do
		if c.custom_value == display then
			sl_disp:select_item(c)
			sl_disp:scroll_to_show_y(c.pos.y)

			break
		end
	end
end

function GG5PopUpOptionsDesktop:apply_video_settings()
	local c_highdpi = self:ci("toggle_options_highdpi")
	local c_fs = self:ci("toggle_options_fullscreen")
	local c_fst = self:ci("toggle_options_borderless")
	local c_mp = self:ci("toggle_options_large_mouse_pointer")
	local c_vsync = self:ci("toggle_options_vsync")
	local sl_disp = self:ci("selectlist_display")
	local sl_fps = self:ci("selectlist_fps")
	local sl_tex = self:ci("selectlist_image_quality")
	local sl_res = self:ci("selectlist_resolution")
	local params = storage:load_settings()

	if not params.player_customized then
		local texv = sl_tex.selected_item and sl_tex.selected_item.custom_value
		local resx = sl_res.selected_item and sl_res.selected_item.custom_value.x
		local resy = sl_res.selected_item and sl_res.selected_item.custom_value.y

		if texv and texv ~= params.texture_size or resx and resx ~= params.width or resy and resy ~= params.height or params.fullscreen ~= c_fs.checked then
			params.player_customized = true
		end
	end

	if sl_res.selected_item then
		params.width = sl_res.selected_item.custom_value.x
		params.height = sl_res.selected_item.custom_value.y
	end

	if sl_disp.selected_item then
		params.display = sl_disp.selected_item.custom_value
	end

	if sl_tex.selected_item then
		params.texture_size = sl_tex.selected_item.custom_value
	end

	if sl_fps.selected_item then
		params.fps = sl_fps.selected_item.custom_value
	end

	params.fullscreen = c_fs.value
	params.fullscreentype = c_fst.value and "desktop" or "exclusive"
	params.vsync = c_vsync.value
	params.large_pointer = c_mp.value
	params.highdpi = c_highdpi.value

	storage:save_settings(params)

	local p = self:get_window():get_child_by_id("popup_message")

	if p then
		p:set_msg(_("APPLY_SETTINGS_AND_RESTART"))
		p:set_ok_fn(function()
			love.event.quit("restart")
		end)
		p:show()
	end
end

function GG5PopUpOptionsDesktop:on_show()
	self:reload_slider_values()
	self:reload_video_settings()
	self:ci("button_close_popup"):enable()

	if self.context == "ingame" then
		self:ci("options_quit_button"):enable()
		self:ci("options_restart_button"):enable()
		self:ci("options_continue_button"):enable()
	end
end

function GG5PopUpOptionsDesktop:on_hide()
	local settings = storage:load_settings()
	local changed = false

	for _, view in pairs(self:ci("page_01").children) do
		for _, c in pairs(view.children) do
			if c:isInstanceOf(GG5Slider) and c.value ~= settings[c.id] then
				changed = true
				settings[c.id] = c.value
			end
		end
	end

	for _, c in pairs(self:ci("page_03").children) do
		if c:isInstanceOf(GG5Slider) and c.value ~= settings[c.id] then
			changed = true
			settings[c.id] = c.value
		end
	end

	if changed then
		storage:save_settings(settings)
	end
end

GG5PopupIngameShop = class("GG5PopupIngameShop", GG5PopUp)

function GG5PopupIngameShop:initialize(size, image_name, base_scale)
	GG5PopupIngameShop.super.initialize(self, size, image_name, base_scale)

	local function wid(name)
		return self:ci(name)
	end

	self.shop_item = wid("popup_ingame_shop_item")
	self.shop_gems = wid("popup_ingame_shop_gems")
	self.shop_gems_button = wid("popup_ingame_shop_gems_button")
	self.item_data = table.deepclone(iap_data.shop_data)
	self:ci("button_item_room_buy_gems").on_click = function(this)
		game.game_gui.c_show_ingame_shop_gems()
	end
	self:ci("button_ingame_shop_confirm_ok_gems").on_click = function(this)
		self:show_screen_items()
	end
end

function GG5PopupIngameShop:show(selected_items)
	GG5PopupIngameShop.super.show(self)

	self.shop_gems.hidden = true
	self.shop_gems_button.hidden = true
	self.shop_item.hidden = false
	self:ci("button_item_room_buy_gems").hidden = PS.services and PS.services.iap and PS.services.iap:is_premium() or false

	local slot = storage:load_slot()

	for i, item_name in ipairs(selected_items) do
		local item_element = self:ci("group_item_portrait_0" .. i)
		local qty = slot.items.status[item_name] or 0

		item_element:ci("label_amount").text = qty

		local key = "ITEM_" .. string.upper(item_name)

		item_element:ci("label_item_title").text = _(key .. "_NAME")
		item_element:ci("label_button_price").text = self.item_data[item_name].cost
		item_element:ci("image_icon_bg_greyscale").colors.tint = self.item_data[item_name].color_bg

		if features.censored_cn and item_name == "medical_kit" then
			item_element:ci("image_icon_bg_greyscale").colors.tint = {
				35.7,
				242.25,
				84.15,
				255
			}
		end

		local thumb_fmt = "item_thumb_%s"

		item_element:ci("image_item_icon"):set_image(string.format(thumb_fmt, item_name))

		item_element.item_shown = item_name
		item_element:ci("item_room_portrait_flash").hidden = true
		item_element.buy_fx = item_element:ci("animation_item_buy_fx")
		item_element.buy_fx.loop = false
		item_element:ci("button_ingame_shop_item_price").on_click = function(this)
			local user_data = storage:load_slot()
			local cost = self.item_data[item_element.item_shown].cost

			if cost > user_data.gems then
				S:queue("GUIButtonUnavailable")

				if not IS_MOBILE or not PS.services.iap or not PS.services.iap:is_premium() then
					local w = this:get_window()
					local p = w:get_child_by_id("popup_message")

					if not p then
						log.error("GG5PopupIngameShop requires a GG5PopUpMessage named popup_message in the window!")

						return
					end

					p:set_msg(_("KR5_NO_GEMS"))
					p:set_ok_fn(function()
						game.game_gui.c_show_ingame_shop_gems()
					end)
					p:show()
				end

				return
			end

			S:queue("GUIBuyUpgrade")

			user_data.items.status[item_element.item_shown] = user_data.items.status[item_element.item_shown] + 1
			user_data.gems = user_data.gems - cost

			storage:save_slot(user_data)

			local gems_label = self:ci("group_item_gems"):ci("label_item_room_gems")

			gems_label.text = string.format("%s", user_data.gems)

			local slot = storage:load_slot()
			local qty = slot.items.status[item_element.item_shown] or 0

			item_element:ci("label_amount").text = qty
			item_element.buy_fx.ts = 0
		end
	end

	local user_data = storage:load_slot()
	local gems_label = self:ci("group_item_gems"):ci("label_item_room_gems")

	gems_label.text = string.format("%s", user_data.gems)

	game.game_gui.c_show_ingame_shop()
end

function GG5PopupIngameShop:hide()
	GG5PopupIngameShop.super.hide(self)
	game.game_gui.c_hide_ingame_shop()
end

function GG5PopupIngameShop:show_screen_items()
	self.shop_gems.hidden = true
	self.shop_gems_button.hidden = true
	self.shop_item.hidden = false
	self:ci("button_item_room_buy_gems").hidden = PS.services and PS.services.iap and PS.services.iap:is_premium() or false
end

GG5ViewIngameShopItem = class("GG5ShopInGameItem", KView)

function GG5ViewIngameShopItem:initialize(size, image_name, base_scale)
	GG5ViewIngameShopItem.super.initialize(self, size, image_name, base_scale)

	self:ci("button_ingame_shop_confirm_ok_item").on_click = function(this)
		self.parent:hide()
	end
end

GG5ViewIngameShopGems = class("GG5ShopInGameGems", KView)

function GG5ViewIngameShopGems:initialize(size, image_name, base_scale)
	GG5ViewIngameShopGems.super.initialize(self, size, image_name, base_scale)
end

function GG5ViewIngameShopGems:show()
	local safe_frame = SU.get_safe_frame(game.screen_w, game.screen_h, game.ref_w, game.ref_h)

	self:ci("group_shop_room_cards_container").pos.x = safe_frame.l
	self.hidden = false
	self.parent:ci("popup_ingame_shop_gems_button").hidden = false
end

GG5ViewIngameShopGemsContainer = class("GG5ViewIngameShopGemsContainer", KInertialView)

function GG5ViewIngameShopGemsContainer:initialize(size, image_name, base_scale)
	GG5ViewIngameShopGemsContainer.super.initialize(self, size, image_name, base_scale)

	local safe_frame = SU.get_safe_frame(game.screen_w, game.screen_h, game.ref_w, game.ref_h)
	local offset_x = 30
	local button_width = 350
	local button_height = 520
	local drag_limit = 100
	local drag_width = #iap_data.gems_order * button_width

	self.size.x = drag_width + offset_x + safe_frame.l
	self.size.y = button_height
	self.elastic_limits = V.r(safe_frame.l + drag_limit, -(button_height / 2), -drag_width / 2 - drag_limit * 2, 0)
	self.drag_limits = V.r(safe_frame.l, -(button_height / 2), -drag_width / 2 + drag_limit * 2, 0)

	for i, v in ipairs(iap_data.gems_order) do
		local gem_data = iap_data.gems_data[v]
		local button_template = kui_db:get_table("button_ingame_shop_gems_portrait")
		local gem_button = GG5Button:new_from_table(button_template)
		local start_pos = safe_frame.l + offset_x

		start_pos = start_pos + (i - 1) * button_width + button_width / 2
		gem_button.pos = V.v(start_pos, button_height / 2)
		gem_button.item_name = v

		local product = PS.services.iap and PS.services.iap:get_product(v) or {}

		gem_button:ci("label_shop_title_gems").text = _("MAP_INAPP_GEM_PACK_" .. i)
		gem_button:ci("label_shop_portrait_gems_quantity").text = product.reward or ""

		local price = "?"

		if product.price then
			price = string.gsub(product.price, " ", "")
		end

		gem_button:ci("label_shop_portrait_gems_cost").text = price

		local thumb_gem = "gem_packs_portraits_%04i"

		gem_button:ci("image_gem_pack_portrait"):set_image(string.format(thumb_gem, gem_data.icon))

		if gem_data.is_most_popular then
			gem_button:ci("label_shop_gems_tag").text = _("SHOP_ROOM_MOST_POPULAR_TITLE")
		elseif gem_data.is_best_value then
			gem_button:ci("label_shop_gems_tag").text = _("SHOP_ROOM_BEST_VALUE_TITLE")
		else
			gem_button:ci("image_shop_gems_tag").hidden = true
			gem_button:ci("label_shop_gems_tag").hidden = true
		end

		function gem_button.on_click(this)
			S:queue("GUIButtonCommon")

			if not PS.services.iap or not PS.services.iap:purchase_product(this.item_name) then
				signal.emit(SGN_SHOP_SHOW_MESSAGE, "iap_error")
				log.error("Error trying to purchase product %s", this.item_name)

				return
			end

			signal.emit(SGN_SHOP_SHOW_IAP_PROGRESS)
		end

		self:add_child(gem_button)
	end
end

GG5SelectList = class("GG5SelectList", KScrollList)

function GG5SelectList:initialize(size)
	GG5SelectList.super.initialize(self, size)

	if self.scale and self.scale.x ~= 1 then
		self.size.x = self.size.x * self.scale.x
	end

	if self.scale and self.scale.y ~= 1 then
		self.size.y = self.size.y * self.scale.y
	end

	self.scale = V.v(1, 1)
	self.default_colors = {
		background = {
			150,
			170,
			180,
			255
		},
		scroller_background = {
			196,
			200,
			200,
			255
		},
		scroller_foreground = {
			78,
			120,
			128,
			255
		},
		text = {
			0,
			0,
			0,
			255
		},
		selection_background = {
			0,
			128,
			178,
			255
		},
		selection_text = {
			255,
			255,
			255,
			255
		},
		focused_outline = {
			255,
			255,
			0,
			255
		}
	}
	self._items = {}
	self.scroll_acceleration = 0
	self.scroll_amount = 24
	self.selected_item = nil
	self.colors.background = self.default_colors.background
	self.colors.scroller_foreground = self.default_colors.scroller_foreground
	self.colors.scroller_background = self.default_colors.scroller_background
	self.colors.focused_outline = self.default_colors.focused_outline

	self:set_scroller_size(24, 2)

	self.focused_outline_thickness = 4
end

function GG5SelectList:add_item(text, custom_value, cb_on_select)
	local l = GG5Label:new(V.v(self.size.x, 38))

	l.colors.background = self.default_colors.background
	l.text = text
	l.text_align = "left"
	l.font_name = "fla_numbers"
	l.font_size = 24
	l.text_offset = V.v(5, 3)
	l.colors.text = self.default_colors.text

	function l.on_click(this)
		self:select_item(l)
	end

	l.cb_on_select = cb_on_select
	l.custom_value = custom_value

	self:add_row(l)
end

function GG5SelectList:select_item(item, ignore_callback)
	for _, c in ipairs(self.children) do
		if c == item then
			c.colors.background = self.default_colors.selection_background
			c.colors.text = self.default_colors.selection_text
			self.selected_item = c

			if c.cb_on_select and not ignore_callback then
				c:cb_on_select()
			end
		else
			c.colors.background = self.default_colors.background
			c.colors.text = self.default_colors.text
		end
	end
end

function GG5SelectList:on_focus()
	return
end

function GG5SelectList:on_keypressed(key)
	local function get_item_index(item)
		for i, c in ipairs(self.children) do
			if c == item then
				return i
			end
		end

		return nil
	end

	if #self.children < 1 then
		return false
	end

	local i = get_item_index(self.selected_item)
	local ci = i

	if key == "up" then
		if i then
			i = km.clamp(1, #self.children, i - 1)

			self:select_item(self.children[i])
		else
			self:select_item(self.children[1])
		end

		self:scroll_to_show_y(self.selected_item.pos.y)

		return ci ~= 1
	elseif key == "down" then
		if i then
			i = km.clamp(1, #self.children, i + 1)

			self:select_item(self.children[i])
		else
			self:select_item(self.children[#self.children])
		end

		self:scroll_to_show_y(self.selected_item.pos.y)

		return ci ~= #self.children
	end
end
