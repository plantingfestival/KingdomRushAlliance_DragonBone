-- chunkname: @./kr5/screen_consent.lua

local log = require("klua.log"):new("screen_consent")
local class = require("middleclass")
local F = require("klove.font_db")
local GS = require("game_settings")
local I = require("klove.image_db")
local RC = require("remote_config")
local S = require("sound_db")
local SU = require("screen_utils")
local V = require("klua.vector")
local class = require("middleclass")
local features = require("features")
local i18n = require("i18n")
local storage = require("storage")
local timer = require("hump.timer").new()
local v = V.v
local utf8_string = require("klove.utf8_string")
local ktw = require("klove.tween").new(timer)
local signal = require("hump.signal")
local PP = require("privacy_policy_consent")

require("constants")
require("gg_views")
require("gg_views_custom")
require("gg_views_game")
require("klove.kui")

local kui_db = require("klove.kui_db")

if DBG_SLIDE_EDITOR then
	local dbe = require("debug_view_editor")
end

local IS_PHONE = KR_TARGET == "phone"
local IS_TABLET = KR_TARGET == "tablet"
local screen = {}

screen.required_sounds = {
	"common",
	"music_screen_slots"
}
screen.required_textures = {
	"screen_slots",
	"gui_slices",
	"gui_popups"
}

if not IS_MOBILE then
	table.insert(screen.required_textures, "gui_popups_desktop")
end

if SN and SN.texture_group then
	table.insert(screen.required_textures, SN.texture_group)
end

screen.ref_w = 1728
screen.ref_h = 768
screen.ref_res = TEXTURE_SIZE_ALIAS.ipad

local function wid(name)
	return screen.window:get_child_by_id(name)
end

GG5PopUpAcceptPrivacyPolicy = class("GG5PopUpAcceptPrivacyPolicy", GG5PopUp)

function GG5PopUpAcceptPrivacyPolicy:initialize(size, image_name, base_scale)
	GG5PopUpAcceptPrivacyPolicy.super.initialize(self, size, image_name, base_scale)

	self:ci("label_welcometokr").text = _("PRIVACY_POLICY_WELCOME")
	self:ci("label_tellage").text = _("PRIVACY_POLICY_ASK_AGE")
	self:ci("label_pleaseconfirmterms").text = _("PRIVACY_POLICY_CONSENT_SHORT")
	self:ci("label_button_termsofservice").text = _("PRIVACY_POLICY_BUTTON_LINK")
	self:ci("label_button_privacypolicy").text = _("TERMS_OF_SERVICE_LINK")

	local current_month = os.date("%m")
	local current_year = os.date("%Y")

	self:ci("button_privacypolicy").on_click = function()
		love.system.openURL(RC.v.url_privacy_policy[version.bundle_id] or RC.v.url_privacy_policy.default)
	end
	self:ci("button_termsofservice").on_click = function()
		love.system.openURL(RC.v.url_terms_of_service[version.bundle_id] or RC.v.url_terms_of_service.default)
	end

	local months_parent = self:ci("template_agemonth")

	months_parent:ci("label_agemonth").text = current_month

	local visible_height = 250
	local months_container = KView:new(V.v(218, visible_height))

	months_container.pos = V.v(months_parent.pos.x, months_container.pos.y + 35)
	months_container.clip = true
	months_container.hidden = true

	months_parent:add_child(months_container)

	local drag_height = 876
	local months_slider = KInertialView:new()

	months_slider.id = "months_slider"
	months_slider.size = table.deepclone(months_container.size)
	months_slider.size.y = drag_height
	months_slider.pos = table.deepclone(months_container.pos)
	months_slider.pos.y = 200
	months_slider.can_drag = true
	months_slider.inertia_damping = 0.8
	months_slider.inertia_stop_speed = 0.01

	months_container:add_child(months_slider)

	months_slider.drag_limits = V.r(0, 0, 0, -drag_height)
	months_slider.elastic_limits = V.r(0, 0, 0, -drag_height + visible_height)

	for i = 1, 12 do
		local item = GG5PopupAcceptPPCombo:new_from_table(kui_db:get_table("popup_acceptpp_agemonth"))

		item.pos.y = months_parent.pos.y + i * 73 - 20
		item.pos.x = 109
		item:ci("label_agemonth").text = string.format("%02d", i)

		for _, c in ipairs(item.children) do
			function c.on_click()
				months_parent:ci("label_agemonth").text = item:ci("label_agemonth").text
				months_container.hidden = not months_container.hidden
			end
		end

		months_slider:add_child(item)
	end

	self:ci("button_agemonth").on_click = function()
		months_container.hidden = not months_container.hidden
	end

	local combo_parent = self:ci("template_ageyear")

	combo_parent:ci("label_agemonth").text = current_year

	local visible_height = 250
	local items_amount = 100
	local year_container = KView:new(V.v(218, visible_height))

	year_container.pos = V.v(combo_parent.pos.x - 204, year_container.pos.y + 35)
	year_container.clip = true
	year_container.hidden = true

	combo_parent:add_child(year_container)

	local drag_height = 73 * items_amount
	local year_slider = KInertialView:new()

	year_slider.id = "year_slider"
	year_slider.size = table.deepclone(year_container.size)
	year_slider.size.y = drag_height
	year_slider.pos = table.deepclone(year_container.pos)
	year_slider.pos.y = 200
	year_slider.can_drag = true
	year_slider.inertia_damping = 0.8
	year_slider.inertia_stop_speed = 0.01

	year_container:add_child(year_slider)

	year_slider.drag_limits = V.r(0, 0, 0, -drag_height)
	year_slider.elastic_limits = V.r(0, 0, 0, -drag_height + visible_height)

	for i = 0, items_amount do
		local item = GG5PopupAcceptPPCombo:new_from_table(kui_db:get_table("popup_acceptpp_ageyear"))

		item.pos.y = combo_parent.pos.y + i * 73 - 20
		item.pos.x = 109
		item:ci("label_agemonth").text = current_year + 1 - i

		for _, c in ipairs(item.children) do
			function c.on_click()
				combo_parent:ci("label_agemonth").text = item:ci("label_agemonth").text
				year_container.hidden = not year_container.hidden
			end
		end

		year_slider:add_child(item)
	end

	self:ci("button_ageyear").on_click = function()
		year_container.hidden = not year_container.hidden
	end
end

GG5PopupAcceptPPCombo = class("GG5PopupAcceptPPCombo", KView)

function GG5PopupAcceptPPCombo:initialize(size, image, base_scale)
	GG5PopupAcceptPPCombo.super.initialize(self, size, image, base_scale)

	self.size = V.v(0, 0)
	self.timer = require("hump.timer").new()
	self.start_pos = table.deepclone(self.pos)
	self.shake_amount = -20
end

function GG5PopupAcceptPPCombo:shake(objects_to_hide)
	local w = self:get_window()
	local ktw = w.ktw

	ktw:cancel(self)

	self.pos.x = self.start_pos.x

	local bounce_time = 0.17
	local back_time = 0.06

	ktw:script(self, function(wait)
		for _, v in ipairs(objects_to_hide) do
			v.hidden = true
		end

		ktw:tween(self, bounce_time, self, {
			pos = V.v(self.pos.x + self.shake_amount, self.start_pos.y)
		}, "in-out-back", function()
			return
		end)
		wait(bounce_time)
		ktw:tween(self, back_time, self, {
			pos = V.v(self.pos.x - self.shake_amount, self.start_pos.y)
		}, "in-out-cubic", function()
			return
		end)
		wait(back_time)
		ktw:tween(self, bounce_time, self, {
			pos = V.v(self.pos.x + self.shake_amount, self.start_pos.y)
		}, "in-out-back", function()
			return
		end)
		wait(bounce_time)
		ktw:tween(self, back_time, self, {
			pos = V.v(self.pos.x - self.shake_amount, self.start_pos.y)
		}, "in-out-cubic", function()
			return
		end)
		wait(back_time)

		for _, v in ipairs(objects_to_hide) do
			v.hidden = false
		end
	end)
end

GG5PopupAcceptPPAgemonth = class("GG5PopupAcceptPPAgemonth", GG5PopupAcceptPPCombo)

function GG5PopupAcceptPPAgemonth:initialize(size, image, base_scale)
	GG5PopupAcceptPPAgemonth.super.initialize(self, size, image, base_scale)

	self.shake_amount = -20
end

GG5PopupAcceptPPAgeyear = class("GG5PopupAcceptPPAgeyear", GG5PopupAcceptPPCombo)

function GG5PopupAcceptPPAgeyear:initialize(size, image, base_scale)
	GG5PopupAcceptPPAgeyear.super.initialize(self, size, image, base_scale)

	self.shake_amount = 20
end

function screen:init(w, h, done_callback)
	self.done_callback = done_callback

	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)

	self.w, self.h = w, h
	self.sw = sw
	self.sh = sh
	self.selected_locale = i18n.current_locale
	GGLabel.static.font_scale = scale
	GGLabel.static.ref_h = self.ref_h
	self.default_base_scale = SU.get_default_base_scale(sw, sh)
	GG5PopUp.static.base_scale = self.default_base_scale

	local ctx = SU.new_screen_ctx(self)

	ctx.context = "consent"
	ctx.safe_frame = SU.get_safe_frame(w, h, self.ref_w, self.ref_h)
	ctx.hud_scale = SU.get_hud_scale(w, h, self.ref_w, self.ref_h)

	local tt = kui_db:get_table("screen_consent", ctx)
	local window = KWindow:new_from_table(tt)

	window.scale = {
		x = scale,
		y = scale
	}
	window.size = {
		x = sw,
		y = sh
	}
	window.origin = origin
	window.timer = timer
	window.ktw = ktw

	window:set_responder(window)

	self.window = window

	if not IS_MOBILE then
		wid("bg_exo_main").pos.y = wid("bg_exo_main").pos_shown.y
		wid("bg_exo_logo").pos.y = wid("bg_exo_logo").pos_shown.y
		wid("bg_exo_tentacles").pos.y = wid("bg_exo_tentacles").pos_shown.y
		wid("bg_exo_main").base_scale = V.vv(0.75)
		wid("bg_exo_logo").base_scale = V.vv(0.7)
		wid("bg_exo_tentacles").base_scale = V.vv(0.75)
	end

	local iov = wid("intro_overlay")

	ktw:tween(iov, 0.33, iov, {
		alpha = 0
	}, "linear", function()
		iov.hidden = true
	end)

	local popup_pp_background = KView:new(V.v(sw * 2, sh * 2))

	popup_pp_background.colors = {
		background = {
			0,
			0,
			0,
			200
		}
	}
	popup_pp_background.alpha = 1
	popup_pp_background.pos.x = -window.size.x / 2
	popup_pp_background.pos.y = 0
	popup_pp_background.propagate_on_click = false
	popup_pp_background.propagate_drag = false
	popup_pp_background.hidden = true
	self.popup_pp = GG5PopUpAcceptPrivacyPolicy:new_from_table(kui_db:get_table("popup_accept_privacy_policy", ctx))
	self.popup_pp.pos.x = window.size.x / 2
	self.popup_pp.pos.y = 366.85
	self.popup_pp.hidden = true
	self.popup_pp.background = popup_pp_background

	window:add_child(popup_pp_background)
	window:add_child(self.popup_pp)
	self.popup_pp:show()

	if self.popup_pp.background then
		self.popup_pp.background.hidden = false
	end

	local now = os.time()
	local now_y = os.date("%Y", now)
	local now_m = os.date("%m", now)
	local dropdowns = {}

	for _, c in ipairs(wid("contents").children) do
		if c.class == KImageView and c.image_name == "gui_popups_image_ui_dropdown_" then
			table.insert(dropdowns, c)
		end
	end

	if #dropdowns == 2 then
		wid("template_agemonth").dropdown = dropdowns[1]
		wid("template_ageyear").dropdown = dropdowns[2]
	end

	local function kp_validate_fn(this)
		local vmin = this.valid_range and this.valid_range[1] or 0
		local vmax = this.valid_range and this.valid_range[2] or 9999

		if not tonumber(this.text) and this.text == this.placeholder then
			return false
		else
			local v = tonumber(this.text)

			if not v or v < vmin or vmax < v then
				return false
			end
		end

		return true
	end

	local function kp_error_fn(this)
		this:shake({
			this.dropdown
		})
	end

	wid("template_agemonth"):ci("label_agemonth").validate = kp_validate_fn
	wid("template_agemonth"):ci("label_agemonth").on_error = kp_error_fn
	wid("template_ageyear"):ci("label_agemonth").validate = kp_validate_fn
	wid("template_ageyear"):ci("label_agemonth").on_error = kp_error_fn
	wid("template_ageyear"):ci("label_agemonth").valid_range = {
		now_y - 100,
		now_y - 1
	}
	wid("button_popup_confirm_ok").on_click = function(this)
		S:queue("GUIButtonCommon")

		local bb_m = wid("template_agemonth"):ci("label_agemonth")
		local bb_y = wid("template_ageyear"):ci("label_agemonth")
		local m = tonumber(bb_m.text)
		local y = tonumber(bb_y.text)

		if not kp_validate_fn(bb_m) then
			kp_error_fn(wid("template_ageyear"))
			kp_error_fn(wid("template_agemonth"))

			return
		end

		if not kp_validate_fn(bb_y) then
			kp_error_fn(wid("template_ageyear"))
			kp_error_fn(wid("template_agemonth"))

			return
		end

		this:disable()
		self.done_callback({
			prevent_loading = true,
			privacy_policy_accepted = true,
			birth_month = m,
			birth_year = y
		})
	end

	signal.emit("ftue-step", "private_policy_age_gate")

	if DBG_SLIDE_EDITOR then
		-- block empty
	end
end

function screen:destroy()
	timer:clear()
	self.window:destroy()

	self.window = nil

	SU.remove_references(self, KView)
end

function screen:update(dt)
	self.window:update(dt)
	timer:update(dt)
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
	if DBG_SLIDE_EDITOR then
		dbe:keypressed(self.SEL_VIEW, key, isrepeat)
	end
end

return screen
