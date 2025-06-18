local log = require("klua.log"):new("game_gui")
local km = require("klua.macros")

require("klua.table")
require("klove.kui")

local kui_db = require("klove.kui_db")
local utf8_string = require("klove.utf8_string")
local timer = require("hump.timer").new()
local ktw = require("klove.tween").new(timer)
local signal = require("hump.signal")
local class = require("middleclass")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local AC = require("achievements")
local F = require("klove.font_db")
local I = require("klove.image_db")
local ISM = require("klove.input_state_machine")
local LU = require("level_utils")
local S = require("sound_db")
local SH = require("klove.shader_db")
local SU = require("screen_utils")
local STU = require("script_utils")
local E = require("entity_db")
local U = require("utils")
local V = require("klua.vector")
local P = require("path_db")
local GR = require("grid_db")
local GS = require("game_settings")
local GU = require("gui_utils")
local storage = require("storage")
local RC = require("remote_config")
local UP = require("upgrades")
local W = require("wave_db")
local balance = require("balance/balance")
local features = require("features")
local G = love.graphics

require("constants")
require("gg_views_custom")
require("gg_views_game")
require("game_gui_classes")

local PS = require("platform_services")
local dbe

if DBG_SLIDE_EDITOR then
	dbe = require("debug_view_editor")
end

if DEBUG and PS.services and PS.services.remote_balance and PS.services.remote_balance.inited then
	require("game_editor_classes")
	require("remote_balance_classes")

	KE_CONST.PROP_W = 600
	KE_CONST.PROP_H = 28
	KE_CONST.font_size = 14
end

local data = require("data.game_gui_data")
local tower_menus
local IS_PHONE = KR_TARGET == "phone"
local IS_TABLET = KR_TARGET == "tablet"
local DRAG_ENTITY_LOOKUP_MARGIN = 15
local DRAG_ENTITY_THRESHOLD = IS_MOBILE and 10 or 25
local DRAG_TOWER_THRESHOLD = IS_MOBILE and 10 or 25
local POWER_BUTTON_DRAG_SCALE = 1.6
local QUICK_CLICK_TIME = 0.2
local PAN_TO_ENTITY_TIME = 0.6
local TOWERMENU_SHOW_TOOLTIP_ON_MAXED_POWER = not IS_MOBILE
local SHOW_INGAME_SHOP = true
local game_gui = {}

if DEBUG then
	game_gui.reload_list = {
		"gui_utils",
		"data.game_gui_data",
		"gg_views_custom",
		"gg_views_game",
		"game_gui_classes"
	}

	if PS.services and PS.services.remote_balance then
		table.insert(game_gui.reload_list, "remote_balance_classes")
	end
end

game_gui.required_textures = {
	"gui_common",
	"gui_portraits",
	"gui_slices",
	"gui_popups",
	"encyclopedia",
	"gui_notifications_common",
	"gui_notifications_bg",
	"go_enemies_common",
	"white_rectangle"
}

if not IS_MOBILE then
	table.insert(game_gui.required_textures, "gui_popups_desktop")
end

if SHOW_INGAME_SHOP then
	table.insert(game_gui.required_textures, "gui_shop")
end

game_gui.ref_w = GUI_REF_W
game_gui.ref_h = GUI_REF_H
game_gui.ref_res = TEXTURE_SIZE_ALIAS.ipad
game_gui._last_mouse_pos_x, game_gui._last_mouse_pos_y = 0, 0
game_gui.tutorial = {}
game_gui.base_scale_list = {
	wave_flag = V.vv(OVT(1, OV_PHONE, 1)),
	enemy_alert = V.vv(OVT(0.65, OV_PHONE, 0.95)),
	wave_alert = V.vv(OVT(1.25, OV_PHONE, 1.5)),
	incoming_tooltip = V.vv(OVT(0.8, OV_PHONE, 1)),
	tower_menu = OVT(0.9, OV_PHONE, 1),
	tower_tooltip = OVT(0.8, OV_PHONE, 1),
	notification = V.vv(OVT(0.6, OV_PHONE, 1)),
	balloon_world = V.vv(OVT(0.5, OV_PHONE, 0.5, OV_TABLET, 0.5)),
	popup_ingame_options = V.vv(OVT(1, OV_PHONE, 1, OV_TABLET, 0.6)),
	hud = V.vv(OVT(1, OV_PHONE, 1.53, OV_DESKTOP, 0.7)),
	boss_bar = V.vv(OVT(1, OV_PHONE, 1.53, OV_DESKTOP, 1.1)),
	achievement = V.vv(OVT(1, OV_PHONE, 1.53)),
	bottom = V.vv(OVT(0.8, OV_PHONE, 1.18, OV_DESKTOP, 0.75)),
	info = V.vv(OVT(1.1, OV_PHONE, 1.42, OV_DESKTOP, 0.9)),
	noti_icons = V.vv(OVT(1, OV_PHONE, 1.53)),
	victory = V.vv(OVT(0.8, OV_PHONE, 1, OV_TABLET, 0.8)),
	defeat = V.vv(OVT(0.8, OV_PHONE, 1, OV_TABLET, 0.8)),
	feedback = V.vv(OVT(1, OV_PHONE, 1.6)),
	shop_ingame = V.vv(OVT(0.8, OV_PHONE, 0.95, OV_TABLET, 0.8))
}
game_gui.base_scale_aspect_factors = {
	bottom = {
		[1.78] = 1,
		[0] = OVT(1, OV_PHONE, 0.85, OV_TABLET, 0.85),
		[1.5] = OVT(1, OV_PHONE, 0.85, OV_TABLET, 1)
	},
	info = {
		[1.78] = 1,
		[0] = OVT(1, OV_PHONE, 0.85, OV_TABLET, 0.85),
		[1.5] = OVT(1, OV_PHONE, 0.85, OV_TABLET, 1)
	}
}

local function wid(name)
	return game_gui.window:ci(name)
end

function game_gui:init(w, h, game)
	self.game = game
	self.mode = GUI_MODE_IDLE
	self.keys_disabled = nil
	self.tower_ranges = {}
	self.last_tower_hover = nil
	self.dpi_scale = love.window.getPixelScale()

	log.info("pixel scale is " .. self.dpi_scale)

	self.tutorial = {
		hide_ui = false,
		block_movement = false,
		block_towers = false,
		enabled_tower = ""
	}

	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)

	self.w = w
	self.h = h
	self.clamped_h = sh * scale
	self.sw = sw
	self.sh = sh
	self.gui_scale = scale
	self.safe_frame = SU.get_safe_frame(w, h, self.ref_w, self.ref_h)
	self.bs = SU.factor_base_scale_list(game_gui.base_scale_list, game_gui.base_scale_aspect_factors, sw / sh)

	log.info("WindowData\nw:%f - h:%f - ch:%f - sw:%f - sh:%f - scale:%f", self.w, self.h, self.clamped_h, self.sw, self.sh, self.gui_scale)
	log.info("SafeFrame: %s", getfulldump(self.safe_frame))

	GGLabel.static.font_scale = scale
	GGLabel.static.ref_h = self.ref_h
	self.default_base_scale = SU.get_default_base_scale(sw, sh)
	GG5PopUp.static.base_scale = self.default_base_scale
	package.loaded["data.tower_menus_data"] = nil
	tower_menus = require("data.tower_menus_data")

	local slot = storage:load_slot()
	local selected_holders = slot.towers.selected
	local index = 1

	if game.store.level.available_towers then
		selected_holders = {}

		for _, tower in ipairs(game.store.level.available_towers) do
			local tower_name = tower:gsub("tower_build_", "")

			table.insert(selected_holders, tower_name)
		end
	end

	for i = 1, 5 do
		local tower_found = selected_holders[i]

		if tower_found then
			for _, holder in ipairs(tower_menus.holder[1]) do
				if holder.type == tower_found then
					holder.place = index
					index = index + 1

					break
				end
			end
		else
			local locked_holder = {
				check = "main_icons_0019",
				halo = "glow_ico_main",
				action = "tw_locked",
				type = "slot_locked",
				preview = "",
				image = "main_icons_0014",
				action_arg = "",
				place = index
			}

			table.insert(tower_menus.holder[1], locked_holder)

			index = index + 1
		end
	end

	local ctx = SU.new_screen_ctx(self)

	ctx.context = "ingame"
	ctx.safe_frame = self.safe_frame
	ctx.sw, ctx.sh = sw, sh
	ctx.endless = self.game.store.level_mode == GAME_MODE_ENDLESS
	ctx.bs = self.bs
	ctx.has_iap = SHOW_INGAME_SHOP
	ctx.remote_balance = PS.services and PS.services.remote_balance and PS.services.remote_balance.inited or false

	if ctx.remote_balance then
		ctx.rb_prop_w = KE_CONST.PROP_W
		ctx.rb_prop_h = KE_CONST.PROP_H
		ctx.rb_m = 10
		ctx.rb_font_name = KE_CONST.font_name
		ctx.rb_font_size = KE_CONST.font_size
	end

	local tt = kui_db:get_table("game_gui", ctx)
	local window = KWindow:new_from_table(tt)

	window.size = V.v(sw, sh)
	window.scale = V.v(scale, scale)
	window.origin = origin
	window.colors.background = {
		0,
		0,
		0,
		0
	}
	window.drag_threshold = 10 * scale
	window.timer = timer
	window.ktw = ktw

	window:set_responder(window)

	self.window = window
	self.ctx = ctx
	self.touch_view = wid("touch_view")
	self.layer_gui = wid("layer_gui")
	self.mouse_pointer = wid("mouse_pointer")

	self:refresh_bar_positions()

	local pause_button = wid("pause_button")

	function pause_button.on_click(this)
		S:queue("GUIButtonCommon")
		game_gui.c_pause()
	end

	local b_size = pause_button.size
	local rect_w, rect_h = b_size.x * 0.55, b_size.y * 0.55

	pause_button.hit_rect = {
		pos = V.v(pause_button.pos.x + (b_size.x - rect_w) * 0.5, pause_button.pos.y + (b_size.y - rect_h) * 0.5),
		size = V.v(rect_w, rect_h)
	}

	if self.game.store.level_mode == GAME_MODE_ENDLESS then
		-- block empty
	end

	local hud = wid("hud_view")

	function hud.update(this, dt)
		this.class.super.update(this, dt)

		local store = self.game.store

		this:ci("hud_lives_label").text = string.format("%d", store.lives)
		this:ci("hud_gold_label").text = string.format("%d", store.player_gold)
		this:ci("hud_waves_label").text = string.format(_("MENU_HUD_WAVES"), store.wave_group_number, store.wave_group_total)
	end

	wid("infobar_view").hide = function(this)
		if this.timer_h then
			timer:cancel(this.timer_h)
		end

		this.timer_h = timer:tween(0.4, this.pos, {
			y = this.hidden_y
		}, "out-back")
	end
	wid("infobar_view").show = function(this, e)
		if not e or not e.info then
			this:hide()

			return
		end

		for _, v in pairs(wid("infobar_part_a").children) do
			v.hidden = true
		end

		local stats = e.info.fn(e)
		local tv

		if e.health and (not stats or stats.type ~= STATS_TYPE_TEXT) then
			tv = wid("infobar_part_a"):ci("with_health")

			tv:ci("portrait"):set_image(e.info.portrait)
		elseif e.info.portrait then
			tv = wid("infobar_part_a"):ci("with_portrait")

			tv:ci("portrait"):set_image(e.info.portrait)
		else
			tv = wid("infobar_part_a"):ci("text_only")
		end

		tv.hidden = false

		local title_s

		if e.info and e.info.i18n_key then
			title_s = _(e.info.i18n_key .. "_NAME")
		else
			title_s = _(string.upper(e.template_name) .. "_NAME")
		end

		if IS_TRILOGY and not IS_KR3 then
			title_s = string.upper(title_s)
		end

		tv:ci("title").text = title_s

		local sv = wid("infobar_stats_type_" .. stats.type)

		if not sv then
			log.error("Entity %s has no infobar", e)
			this:hide()

			return
		end

		if stats.type == STATS_TYPE_TEXT and e.info.portrait then
			sv:ci("desc").pos.x = 59
		end

		sv.hidden = false

		this:update_stats(e)

		if this.timer_h then
			timer:cancel(this.timer_h)
		end

		this.timer_h = timer:tween(0.4, this.pos, {
			y = this.shown_y
		}, "out-back")
	end
	wid("infobar_view").show_text = function(this, title, desc)
		for _, v in pairs(wid("infobar_part_a").children) do
			v.hidden = true
		end

		local tv = wid("infobar_part_a"):ci("text_only")

		tv:ci("title").text = title
		tv.hidden = false

		local sv = wid("infobar_part_a"):ci("infobar_stats_type_9")

		sv:ci("desc").text = desc
		sv:ci("desc").pos.x = 11
		sv.hidden = false

		if this.timer_h then
			timer:cancel(this.timer_h)
		end

		this.timer_h = timer:tween(0.4, this.pos, {
			y = this.shown_y
		}, "out-back")
	end
	wid("infobar_view").update = function(this, dt)
		local e = self.selected_entity

		if e and e.health and e.health.dead and not e.hero then
			game_gui.c_deselect()
		elseif e and e.info then
			this:update_stats(e)
		end
	end
	wid("infobar_view").update_stats = function(this, e)
		local ddi = data.damage_icons
		local stats = e.info.fn(e)
		local pav = wid("infobar_part_a")
		local sv = wid("infobar_stats_type_" .. stats.type)
		local hv = pav:ci("health")
		local hb = pav:ci("health_bar")
		local hb_scale = stats.type == STATS_TYPE_ENEMY and V.v(1.1, 1) or V.v(1, 1)

		if hb and stats.hp then
			hb.scale.x = hb_scale.x * (stats.hp / stats.hp_max)
		end

		if e and e.info then
			local bp = pav:ci("with_health"):ci("portrait")

			bp.default_image_name = e.info.portrait
			bp.hover_image_name = e.info.portrait
			bp.click_image_name = e.info.portrait

			bp:set_focus_image(e.info.portrait)

			bp.on_click = nil
		end

		if stats.type == STATS_TYPE_ENEMY then
			local bp = pav:ci("with_health"):ci("portrait")

			function bp.on_click(this)
				game_gui.c_show_noti({
					force = true,
					id = e.template_name
				})
			end

			if stats.immune then
				hv.text = _("CArmor9")
			else
				hv.text = string.format("%i/%i", stats.hp, stats.hp_max)
			end

			sv:ci("damage").text = GU.damage_value_desc(stats.damage_min, stats.damage_max)
			sv:ci("lives").text = type(stats.lives) == "number" and stats.lives > 0 and stats.lives or "-"

			local armor_count = GU.armor_value_descrete(stats.armor)
			local magical_armor_count = GU.armor_value_descrete(stats.magic_armor)

			for i = 1, 3 do
				local armor_visible = i <= armor_count

				sv:ci("armor_icon_0" .. i).hidden = not armor_visible

				local magic_armor_visible = i <= magical_armor_count

				sv:ci("armor_icon_magic_0" .. i).hidden = not magic_armor_visible
			end
		elseif stats.type == STATS_TYPE_SOLDIER then
			hv.text = string.format("%i/%i", stats.hp, stats.hp_max)
			sv:ci("damage").text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

			sv:ci("damage_icon"):set_image(ddi[stats.damage_icon] or ddi[band(DAMAGE_BASE_TYPES, stats.damage_type or 0)] or ddi.default)

			sv:ci("respawn").text = stats.respawn and string.format("%is", stats.respawn) or "-"

			if features.censored_cn then
				sv:ci("respawn").text = stats.respawn and string.format("%i秒", stats.respawn) or "-"

				if sv:ci("respawn").font_name ~= "currency" then
					sv:ci("respawn").font_name = "currency"
				end
			end

			local armor_count = GU.armor_value_descrete(stats.armor)
			local magical_armor_count = GU.armor_value_descrete(stats.magic_armor)

			for i = 1, 3 do
				local armor_visible = i <= armor_count

				sv:ci("armor_icon_0" .. i).hidden = not armor_visible

				local magic_armor_visible = i <= magical_armor_count

				sv:ci("armor_icon_magic_0" .. i).hidden = not magic_armor_visible
			end
		elseif stats.type == STATS_TYPE_TOWER or stats.type == STATS_TYPE_TOWER_MAGE or stats.type == STATS_TYPE_TOWER_NO_RANGE then
			sv:ci("damage").text = GU.damage_value_desc(stats.damage_min, stats.damage_max)
			sv:ci("cooldown").text = GU.cooldown_value_desc(stats.cooldown)
			if stats.type ~= STATS_TYPE_TOWER_NO_RANGE then
				sv:ci("range").text = GU.range_value_desc(stats.range)
			end
		elseif stats.type == STATS_TYPE_TOWER_BARRACK then
			sv:ci("health").text = string.format("%i", stats.hp_max)
			sv:ci("damage").text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

			local armor_count = GU.armor_value_descrete(stats.armor)
			local magical_armor_count = GU.armor_value_descrete(stats.magic_armor)

			for i = 1, 3 do
				local armor_visible = i <= armor_count

				sv:ci("armor_icon_0" .. i).hidden = not armor_visible

				local magic_armor_visible = i <= magical_armor_count

				sv:ci("armor_icon_magic_0" .. i).hidden = not magic_armor_visible
			end
		elseif stats.type == STATS_TYPE_TEXT then
			sv:ci("desc").text = _(stats.desc)
		end
	end
	wid("notification_queue_view").remove_icon = function(this, child)
		local move = false

		for i, c in ipairs(this.children) do
			if c == child then
				move = true
			elseif move then
				timer:tween(0.3, c.pos, {
					y = c.pos.y - (c.size.y + this.icon_space_y)
				}, "out-quad")
			end
		end

		this:remove_child(child)
	end

	local cheat_button = wid("cheat_button")

	function cheat_button.on_click(this)
		local isFirstClick
		if this.cheat_view then
			for _, view in ipairs(this.cheat_view.views) do
				view:remove_from_parent()
			end

			this.cheat_view = nil

			log.debug("Removing cheats")
		else
			if not isFirstClick then
				isFirstClick = true
				package.loaded.game_gui_cheats = nil
			end
			this.cheat_view = require("game_gui_cheats")
			this.cheat_view:init()

			for _, view in ipairs(this.cheat_view.views) do
				this.parent:add_child(view)
			end

			log.debug("adding cheats")
		end
	end

	local health_texts_button = wid("health_texts_button")
	game_gui.game.store.level.show_health_texts = true
	function health_texts_button.on_click(this)
		if not game_gui.game.store.level.show_health_texts then
			game_gui.game.store.level.show_health_texts = true
		else
			game_gui.game.store.level.show_health_texts = false
		end
	end

	if DEBUG and PS.services and PS.services.remote_balance and PS.services.remote_balance.inited then
		wid("remote_balance_button").on_click = function(this)
			log.warning("remote balance clicked")

			local rbv = wid("remote_balance_view")

			if rbv.hidden then
				rbv:show()
			else
				rbv:hide()
			end
		end
	end

	local default_key_mappings = {
		key_hero_2 = "5",
		key_up = "up",
		key_down = "down",
		key_left = "left",
		key_pow_3 = "3",
		key_wave_info = "e",
		key_pointer = ".",
		key_wave = "w",
		key_right = "right",
		key_pow_1 = "1",
		key_hero_3 = "6",
		key_show_noti = "r",
		key_hero_1 = "4",
		key_pow_2 = "2"
	}

	ISM:init(self.ism_data, window, DEFAULT_KEY_MAPPINGS, storage:load_settings())

	for sn, fn in pairs(self.signal_handlers) do
		signal.register(sn, fn)
	end

	local st = storage:load_settings()

	S:set_main_gain_music(st and st.volume_music or 1)
	S:set_main_gain_fx(st and st.volume_fx or 1)

	local hv = wid("hud_view")
	local hv_r = hv:get_bounds_rect(true)
	local separation = 5

	wid("notification_queue_view").pos.y = hv_r.pos.y + hv_r.size.y + separation

	self:hide_gui_hud(true)
	self:show_gui_hud()
end

function game_gui:destroy()
	ISM:destroy(self.window)
	ktw:clear()
	timer:clear()

	self.window.timer = nil
	self.heroes = nil

	self.window:destroy()

	self.window = nil
	self.game = nil
	self.tower_ranges = nil
	self.wave_flags = nil
	self.selected_entity = nil
	self.swap_entity = nil

	SU.remove_references(self, KView)

	for sn, fn in pairs(self.signal_handlers) do
		signal.remove(sn, fn)
	end
end

game_gui.signal_handlers = {
	["enemy-reached-goal"] = function(enemy)
		if enemy and enemy.enemy and enemy.enemy.lives_cost > 0 then
			S:queue("GUILooseLife")
		end

		if enemy == game_gui.selected_entity then
			game_gui.c_deselect()
		end

		if enemy.ui and enemy.ui.alert_view then
			enemy.ui.alert_view:remove()
		end
	end,
	["early-wave-called"] = function(group, reward, remaining_time, score_reward)
		for i = 1, 3 do
			local b = wid("power_button_" .. i)

			if b then
				b:early_wave_bonus(remaining_time)
			end
		end

		if score_reward then
			wid("hud_bonus_view"):show(score_reward)
		end
	end,
	["next-wave-ready"] = function(group)
		log.debug("next_wave_ready_handler")
		S:queue("GUINextWaveReady")
		game_gui:create_wave_flags(group)

		if game_gui.gui_hud_hidden then
			game_gui:hide_wave_flags()
		end

		if game_gui.game.store.level.show_next_wave_balloon then
			game_gui.game.store.level.show_next_wave_balloon = nil

			game_gui:show_balloon("TB_WAVE")
		end

		if wid("next_wave_button") then
			wid("next_wave_button"):enable()
		end
	end,
	["next-wave-sent"] = function(group)
		log.debug("next_wave_sent_handler")
		game_gui:remove_wave_flags()
		game_gui:show_early_wave_reward()

		if wid("next_wave_button") then
			wid("next_wave_button"):disable()
		end

		if group.group_idx == 1 then
			local locks = game_gui.game.store.level.locked_powers

			for i = 1, 3 do
				local b = wid("power_button_" .. i)

				if not b then
					-- block empty
				elseif (not locks or #locks == 0 or locks[i] == false) and b.can_be_unlocked then
					b:set_mode("unlocked")
				end
			end

			S:stop_group("MUSIC")
			S:queue(string.format("MusicBattle_%02d", game_gui.game.store.level_idx))
		end

		S:queue("GUINextWaveIncoming")
	end,
	["hide-gui"] = function(disable_achievements)
		game_gui.c_deselect()
		game_gui:hide_gui_hud()

		if disable_achievements then
			game_gui.gui_achievements_disabled = true
		end
	end,
	["hide-bottom-info"] = function()
		game_gui.c_deselect()
	end,
	["start-cinematic"] = function()
		game_gui:set_mode(GUI_MODE_CINEMATIC_LOCK)
	end,
	["end-cinematic"] = function()
		game_gui:set_mode(GUI_MODE_IDLE)
	end,
	["start-tutorial"] = function()
		wid("overlay_view").hidden = false
		wid("overlay_view").colors.background = {
			0,
			0,
			0,
			255
		}

		timer:tween(2, wid("overlay_view").colors, {
			background = {
				0,
				0,
				0,
				0
			}
		}, "out-linear", function()
			wid("overlay_view").hidden = true
		end)
		game_gui.c_deselect()
		game_gui:hide_gui_hud_tutorial(true)
		game_gui:hide_second_hero()

		game_gui.tutorial.hide_ui = true
		game_gui.tutorial.wave_flag_disable = true
	end,
	["tutorial-tower-enable-only"] = function(tower)
		game_gui.tutorial.block_towers = true
		game_gui.tutorial.enabled_tower = tower
	end,
	["tutorial-stop-movement"] = function()
		game_gui.tutorial.block_movement = true
	end,
	["tutorial-resume-movement"] = function()
		game_gui.tutorial.block_movement = false
	end,
	["tutorial-stop-input"] = function()
		wid("touch_view"):disable()
		game_gui:set_mode(GUI_MODE_TUTORIAL_LOCK)
	end,
	["tutorial-resume-input"] = function()
		wid("touch_view"):enable()
		game_gui:set_mode(GUI_MODE_IDLE)
	end,
	["tutorial-tower-enable-all"] = function()
		game_gui.tutorial.block_towers = false
	end,
	["tutorial-hover-id"] = function(id)
		local e = game_gui.game.store.entities[id]

		if e and e.tower and e.tower.can_hover and ISM.last_input ~= I_TOUCH then
			game_gui:show_clickable_hover(e)
		end
	end,
	["show-balloon_tutorial"] = function(id, show)
		game_gui:show_balloon_tutorial(id, show)
	end,
	["hide-balloon-tutorial"] = function(id)
		local balloon = game_gui.tutorial_balloon

		if balloon then
			balloon:remove(true)

			game_gui.tutorial_balloon = nil
		end
	end,
	["tutorial-show-wave"] = function()
		game_gui.tutorial.wave_flag_disable = nil

		game_gui:show_wave_flags()
	end,
	["tutorial-focus-wave"] = function()
		if ISM.last_input ~= I_TOUCH then
			game_gui.c_select_wave_flags()
		end
	end,
	["tower-menu-hiding"] = function()
		game_gui.game.store.level.tower_menu_hiding = true
	end,
	["hide-hero"] = function(hero_idx)
		game_gui:hide_hero(hero_idx)
	end,
	["show-hero"] = function(hero_idx)
		game_gui:show_hero(hero_idx)
	end,
	["hide-second-hero"] = function()
		game_gui:hide_second_hero()
	end,
	boss_fight_start_tweened = function(boss, time)
		wid("boss_health_bar"):show(boss)

		local boss_hbar = wid("boss_health_bar")

		if boss_hbar then
			boss_hbar.hidden = false
			boss_hbar.alpha = 0

			timer:tween(time, boss_hbar, {
				alpha = 1
			}, "in-cubic")
		end
	end,
	boss_fight_start = function(boss)
		wid("boss_health_bar"):show(boss)
	end,
	boss_fight_end = function()
		wid("boss_health_bar"):hide()
	end,
	change_power_button = function(button, icon, cooldown)
		local b = wid(button)

		if cooldown then
			b.cooldown_time = cooldown

			b:set_mode("cooldown")
		end

		b:set_image(icon)
	end,
	["tower-menu-showing"] = function()
		game_gui.game.store.level.tower_menu_hiding = false
	end,
	["force-tower-swap"] = function(tower1, tower2)
		if game_gui.swap_entity and (game_gui.swap_entity.id == tower1.id or game_gui.swap_entity.id == tower2.id) and game_gui.mode == GUI_MODE_SWAP_TOWER then
			game_gui:set_mode(GUI_MODE_IDLE)
			game_gui:hide_ghost_hover()
		end
	end,
	["show-gui"] = function()
		game_gui:show_gui_hud()

		game_gui.gui_achievements_disabled = nil
		game_gui.tutorial.hide_ui = false
	end,
	["hero-added"] = function(hero)
		game_gui:add_hero(hero)
	end,
	["tower-removed"] = function(tower, holder)
		if game_gui.selected_entity == tower then
			game_gui:c_deselect_tower()
		end

		game_gui.hover_tower_upon_upgrade = {
			tower,
			holder
		}
	end,
	["tower-upgraded"] = function(new, old)
		log.debug("hover_tower_upon_upgrade: %s -> %s", old and old.id, new and new.id)

		game_gui.hover_tower_upon_upgrade = {
			old,
			new
		}
	end,
	["game-defeat"] = function()
		game_gui.c_show_defeat()
	end,
	["game-victory"] = function()
		local rest_count = game_gui.game.store.restart_count
		local wait_hide_HUD = 3
		local wait_show_victory = 4
		local items_to_reduce = {
			"boss_fight_1_end",
			"boss_fight_2_end",
			"boss_fight_3_end",
			"tutorial_end",
			"boss_fight_5_end",
			"boss_fight_6_end",
			"boss_fight_8_end"
		}

		if game_gui.game.store.custom_game_outcome and table.contains(items_to_reduce, game_gui.game.store.custom_game_outcome.next_item_name) then
			wait_hide_HUD = 1
			wait_show_victory = 1
		end

		if game_gui.game.store.custom_game_outcome and table.contains({
			"kr5_end"
		}, game_gui.game.store.custom_game_outcome.next_item_name) then
			wait_hide_HUD = 0
			wait_show_victory = 0
		end

		timer:after(wait_hide_HUD, function()
			if rest_count == game_gui.game.store.restart_count then
				game_gui.c_deselect()
				game_gui:set_mode(GUI_MODE_DISABLED)
				game_gui:hide_gui_hud()
			end
		end)
		timer:after(wait_show_victory, function()
			if rest_count == game_gui.game.store.restart_count then
				game_gui.c_show_victory()
			end
		end)
	end,
	["lock-user-power"] = function(power_idx)
		local b = wid("power_button_" .. power_idx)

		if b then
			b:set_mode("locked")
		end
	end,
	["unlock-user-power"] = function(power_idx)
		local b = wid("power_button_" .. power_idx)

		if b then
			b:set_mode("unlocked")
		end
	end,
	["lock-items"] = function(item_idx)
		local b = wid("bag_item_" .. item_idx)

		if b then
			b:set_mode("locked")
		end
	end,
	["wave-notification"] = function(type, id, force)
		log.debug("wave_notification - type:%s, id:%s", type, id)

		if type == "view" then
			game_gui.c_show_noti({
				id = id,
				force = force
			})
		elseif type == "icon" then
			game_gui:queue_notification(id, force)
		end
	end,
	["show-balloon"] = function(id)
		game_gui:show_balloon(id)
	end,
	["show-gems-reward"] = function(entity, amount)
		if features.no_gems then
			return
		end

		local v = GemsRewardFx:new(amount)

		v.world_pos = V.vclone(entity.pos)

		if entity.unit then
			v.world_offset = V.vclone(entity.unit.hit_offset)
		end

		wid("layer_gui_world"):add_child(v, 1)
		S:queue("InAppEarnGems")
	end,
	["got-enemy-gold"] = function(entity, amount)
		local store = game_gui.game.store

		if store.hand_of_midas_factor and amount > 0 then
			local bonus = km.round(amount * store.hand_of_midas_factor)

			store.player_gold = store.player_gold + bonus

			S:queue("GUICoins")

			local glow = wid("hud_gold_glow")

			if glow then
				glow.hidden = false
				glow.alpha = 0.9

				timer:tween(0.5, glow, {
					alpha = 0
				}, "in-cubic")
			end

			local v = WaveRewardFx:new(bonus)
			local px, py = game_gui:w2u(V.v(entity.pos.x + entity.unit.hit_offset.x, entity.pos.y + entity.unit.hit_offset.y))

			v.pos.x, v.pos.y = px, py
			v.anchor.y = v.size.y + 2
			v.scale = V.v(0.7, 0.7)

			wid("layer_gui_world"):add_child(v, 1)
		end
	end,
	["got-gold"] = function(pos, amount)
		local store = game_gui.game.store

		store.player_gold = store.player_gold + amount

		S:queue("GUICoins")

		local glow = wid("hud_gold_glow")

		if glow then
			glow.hidden = false
			glow.alpha = 0.9

			timer:tween(0.5, glow, {
				alpha = 0
			}, "in-cubic")
		end

		local v = WaveRewardFx:new(amount)
		local px, py = game_gui:w2u(V.v(pos.x, pos.y))

		v.pos.x, v.pos.y = px, py
		v.anchor.y = v.size.y + 2
		v.scale = V.v(0.7, 0.7)

		wid("layer_gui_world"):add_child(v, 1)
	end,
	["got-achievement"] = function(id)
		wid("achievement_view"):show(id)
	end,
	["show-curtains"] = function()
		local ct, cb = wid("curtain_top_view"), wid("curtain_bottom_view")

		ct.hidden, cb.hidden = false, false

		timer:tween(1, ct.pos, {
			y = ct.shown_y
		}, "out-cubic")
		timer:tween(1, cb.pos, {
			y = cb.shown_y
		}, "out-cubic")
	end,
	["hide-curtains"] = function()
		local ct, cb = wid("curtain_top_view"), wid("curtain_bottom_view")

		timer:tween(1, ct.pos, {
			y = ct.hidden_y
		}, "out-cubic", function()
			ct.hidden = true
		end)
		timer:tween(1, cb.pos, {
			y = cb.hidden_y
		}, "out-cubic", function()
			cb.hidden = true
		end)
	end,
	["fade-in"] = function(time)
		wid("overlay_view").hidden = false
		wid("overlay_view").colors.background = {
			0,
			0,
			0,
			255
		}

		timer:tween(time, wid("overlay_view").colors, {
			background = {
				0,
				0,
				0,
				0
			}
		}, "out-linear", function()
			wid("overlay_view").hidden = true
		end)
	end,
	["fade-out"] = function(time, color)
		wid("overlay_view").hidden = false
		color = color or {
			0,
			0,
			0,
			255
		}

		timer:tween(time, wid("overlay_view").colors, {
			background = color
		}, "out-linear", function()
			return
		end)
		signal.emit("winter-age-ends")
	end,
	["winter-age-starts"] = function()
		for _, v in ipairs(wid("item_fx_container").children) do
			wid("item_fx_container"):remove_child(v)
		end

		local tt = kui_db:get_table("item_winter_age", game_gui.ctx)
		local winter_age = KView:new_from_table(tt)

		wid("item_fx_container"):add_child(winter_age)

		local winter_age_layer = wid("layer_user_item_winter_age")

		winter_age_layer.alpha = 0
		winter_age_layer.hidden = false

		timer:tween(0.2, winter_age_layer, {
			alpha = 1
		}, "linear", function()
			return
		end)

		local snowflake_out_of_screen_percentage = 0.2
		local snowflake_spawn_offset_range = 500
		local snowflake_amount = 10

		for i = 1, 30 do
			for j = 1, snowflake_amount do
				local image_name = "winter_age_snowflake"

				if math.random(1, 2) == 1 then
					image_name = "winter_age_snowflake_small"
				end

				local pos_x = game_gui.sw * (i / 10 - snowflake_out_of_screen_percentage)

				pos_x = pos_x + (math.random(1, snowflake_spawn_offset_range) - snowflake_spawn_offset_range / 2)

				local pos_y = game_gui.sh * (j / 10)

				pos_y = pos_y + (math.random(1, snowflake_spawn_offset_range) - snowflake_spawn_offset_range / 2)

				local snowflake = KWinterAgeSnowflake:new(image_name, pos_x, pos_y)

				table.insert(winter_age_layer.children, snowflake)
			end
		end

		local dust_spawn_offset = game_gui.sw

		for i = 1, 10 do
			local pos_x = math.random(1, dust_spawn_offset) - dust_spawn_offset / 2
			local dust = KWinterAgeDust:new("winter_age_gust", pos_x, game_gui.sh * (i / 10))

			table.insert(winter_age_layer.children, dust)
		end
	end,
	["winter-age-ends"] = function()
		local winter_age_layer = wid("layer_user_item_winter_age")

		if winter_age_layer then
			timer:tween(0.2, winter_age_layer, {
				alpha = 0
			}, "linear", function()
				winter_age_layer.hidden = true

				local to_remove = {}

				for _, c in ipairs(winter_age_layer.children) do
					if c.class == KWinterAgeSnowflake then
						table.insert(to_remove, c)
					elseif c.class == KWinterAgeDust then
						table.insert(to_remove, c)
					end
				end

				for _, v in ipairs(to_remove) do
					winter_age_layer:remove_child(v)
				end
			end)
		end
	end,
	["second-breath"] = function()
		for i = 2, 3 do
			local p = wid("power_button_" .. i)

			if p.mode ~= "locked" then
				p:set_mode("ready")

				local inst_reload = p:ci("instant_reload")

				inst_reload.ts = 0
				inst_reload.hidden = false
				inst_reload.animation.paused = nil
			end
		end
	end,
	["medical-kit"] = function(pos, hearts)
		local store = game_gui.game.store
		local lh = wid("layer_gui_hud")
		local hud = wid("hud_view")
		local hud_lives = lh:ci("hud_lives_label")

		pos = V.v(game_gui:w2u(pos))

		local bag = KImageView:new("item_medical_kit_bag_0001")

		bag.animation = {
			hide_at_end = false,
			prefix = "item_medical_kit_bag",
			from = 1,
			to = 50
		}

		bag:animation_frame(bag.animation, 0, false)

		bag.pos.x, bag.pos.y = pos.x, pos.y
		bag.anchor.x, bag.anchor.y = bag.size.x / 2, bag.size.y / 2

		lh:add_child(bag)

		local dest_pos = V.v(hud:view_to_view(hud_lives.pos.x - 17, hud_lives.pos.y + 10, lh))
		local initial_delay = 0
		local delay_between = 12 / FPS
		local fly_time = 1

		for i = 1, hearts do
			local heart = KImageView:new("item_medical_kit_heart")

			heart.pos.x, heart.pos.y = pos.x + 3, pos.y - 40
			heart.anchor.x, heart.anchor.y = heart.size.x / 2, heart.size.y / 2
			heart.hidden = true

			lh:add_child(heart)
			timer:after(initial_delay + i * delay_between, function()
				heart.hidden = false

				timer:tween(fly_time, heart.pos, {
					x = dest_pos.x
				}, "in-expo")
				timer:tween(fly_time, heart.pos, {
					y = dest_pos.y
				}, "linear")
			end)
			timer:after(initial_delay + i * delay_between + fly_time, function()
				heart:remove_from_parent()

				local hud_heart = KImageView:new("item_medical_kit_heart_HUD_0001")

				hud_heart.animation = {
					hide_at_end = false,
					prefix = "item_medical_kit_heart_HUD",
					from = 1,
					to = 7
				}

				hud_heart:animation_frame(hud_heart.animation, 0, false)

				hud_heart.pos.x, hud_heart.pos.y = dest_pos.x, dest_pos.y
				hud_heart.anchor.x, hud_heart.anchor.y = hud_heart.size.x / 2, hud_heart.size.y / 2
				hud_heart.scale.x = hud_heart.scale.x * game_gui.gui_scale * 1.7
				hud_heart.scale.y = hud_heart.scale.y * game_gui.gui_scale * 1.7

				lh:add_child(hud_heart)

				store.lives = store.lives + 1

				S:queue("ItemsMedicalKitHeartAdd")
				timer:after(7 / FPS, function()
					hud_heart:remove_from_parent()
				end)
			end)
		end

		local bag_ending_pos_y = pos.y + 40

		timer:after(4 / FPS + hearts * delay_between + 0.5, function()
			timer:tween(0.75, bag, {
				alpha = 0,
				pos = V.v(pos.x, bag_ending_pos_y),
				r = -math.pi / 12
			}, "linear", function()
				bag:remove_from_parent()
			end)
		end)
	end,
	["veznan-wrath-starts"] = function()
		for _, v in ipairs(wid("item_fx_container").children) do
			wid("item_fx_container"):remove_child(v)
		end

		local tt = kui_db:get_table("item_veznan_wrath", game_gui.ctx)
		local veznan_wrath = KView:new_from_table(tt)

		wid("item_fx_container"):add_child(veznan_wrath)

		local overlay_dark = veznan_wrath:ci("layer_user_item_veznan_wrath_overlay_dark")

		overlay_dark.hidden = false

		overlay_dark:do_tween(0, 0.39215686274509803, 0.3)
	end,
	["veznan-wrath-enter-veznan"] = function()
		local veznan = wid("item_veznan_wrath_exo")

		veznan.hidden = false
		veznan.ts = 0
	end,
	["veznan-wrath-blink"] = function()
		local overlay_dark = wid("layer_user_item_veznan_wrath_overlay_dark")
		local overlay_green = wid("layer_user_item_veznan_wrath_overlay_green")

		if overlay_dark.hidden and overlay_green.hidden then
			overlay_dark.hidden = false
		else
			overlay_dark.hidden = not overlay_dark.hidden
			overlay_green.hidden = not overlay_green.hidden
		end
	end,
	["veznan-wrath-stop-blink"] = function()
		local overlay_dark = wid("layer_user_item_veznan_wrath_overlay_dark")
		local overlay_green = wid("layer_user_item_veznan_wrath_overlay_green")

		overlay_dark.hidden = true
		overlay_green.hidden = true
	end,
	["veznan-wrath-ends"] = function()
		local veznan = wid("item_veznan_wrath_exo")

		veznan.hidden = true
	end,
	["pan-zoom-camera"] = function(time, to_pos, to_zoom, easing)
		easing = easing or "in-out-quad"

		game_gui.touch_view:on_exit()

		local tox, toy = to_pos.x * game.game_scale, (game.ref_h - to_pos.y) * game.game_scale

		log.debug("pan-zoom-camera: to:%s,%s zooom:%s", tox, toy, to_zoom)
		game.camera:tween(timer, time, tox, toy, to_zoom, easing)
	end,
	["block-random-power"] = function(duration, style)
		local powers = {}

		for i = 1, 3 do
			local p = wid("power_button_" .. i)

			if p and not p:is_disabled() and table.contains({
				"default",
				"unlocked",
				"ready"
			}, p.mode) then
				table.insert(powers, p)
			end
		end

		local p = table.random(powers)

		if p then
			log.debug("blocking power: %s", p)

			local pbb = PowerButtonBlock:new(p, duration, style)

			p:add_child(pbb)
			pbb:block()
		end
	end,
	["debug-ready-user-powers"] = function()
		for i = 1, 3 do
			local b = wid("power_button_" .. i)

			if b then
				b:set_mode("ready")
			end
		end
	end,
	["highlight-gold"] = function(amount)
		local glow = wid("hud_gold_tutorial")

		if glow then
			glow.hidden = false
			glow.alpha = 1

			timer:tween(amount, glow, {
				alpha = 0
			}, "in-cubic")
		end
	end,
	[SGN_SHOP_SHOWN] = function()
		S:pause()

		game.store.paused = true
	end,
	[SGN_SHOP_HIDDEN] = function()
		S:resume()

		game.store.paused = false
	end,
	[SGN_SHOP_GEMS_CHANGED] = function()
		local user_data = storage:load_slot()
		local amount = user_data.gems

		wid("shop_gems").text = amount

		for _, c in pairs(wid("bag_contents_view").children) do
			if c:isInstanceOf(BagItemButton) then
				c:refresh()
			end
		end
	end,
	[SGN_SHOW_GEMS_STORE] = function()
		return
	end,
	[SGN_SHOP_SHOW_IAP_PROGRESS] = function()
		wid("processing_view"):show()
	end,
	[SGN_SHOP_SHOW_MESSAGE] = function(kind, arg)
		return
	end,
	[SGN_PS_PURCHASE_PRODUCT_FINISHED] = function(service_name, success, product_id)
		log.debug(SGN_PS_PURCHASE_PRODUCT_FINISHED .. " : %s %s %s", service_name, success, product_id)
		wid("processing_view"):hide()

		if success then
			if PS.services.iap then
				local p = PS.services.iap:get_product(product_id, true)

				if p and p.gems then
					S:queue("InAppEarnGems")
				end
			end

			local user_data = storage:load_slot()
			local amount = user_data.gems

			wid("popup_ingame_shop_container"):ci("group_item_gems"):ci("label_item_room_gems").text = amount

			wid("popup_ingame_shop_container"):show_screen_items()
		end
	end,
	[SGN_PS_AD_SHOW_VIDEO_FINISHED] = function(service_name, success, ddata, status)
		log.debug(SGN_PS_AD_SHOW_VIDEO_FINISHED .. " : %s data:%s", success, ddata)
		PS.services.ads:cache_video_ad()
	end
}

function game_gui:update(dt)
	timer:update(dt)
	self.window:update(dt)

	local e = game_gui.selected_entity

	if e and (e.tower and e.tower.blocked and e.tower.type ~= "tower_timed_destroy" and not string.find(e.tower.type, "tower_broken") or e.health and e.health.dead and not e.health.ignore_damage or e.trigger_deselect) then
		game_gui.c_deselect()

		e.trigger_deselect = nil
	end

	local st = game_gui.swap_entity

	if game_gui.mode == GUI_MODE_TOWER_COMBINATION and st and st.tower and st.tower.blocked then
		game_gui.c_deselect()
		game_gui.swap_entity = nil
	end

	if game_gui.mode == GUI_MODE_SWAP_TOWER and st and st.tower and st.tower.blocked then
		game_gui.c_deselect()
		game_gui.swap_entity = nil
	end

	if game_gui.hover_tower_upon_upgrade then
		local pht, ht = unpack(game_gui.hover_tower_upon_upgrade)

		if game_gui.last_tower_hover == pht and ht and ht.tower.can_hover and game_gui.game.store.entities[ht.id] then
			log.debug("hovering after upgrade: (%s)%s", ht.id, ht)

			game_gui.hover_tower_upon_upgrade = nil

			game_gui:show_clickable_hover(ht)
		end
	end

	if game_gui.mode == GUI_MODE_POINTER then
		if ISM.j_pointer_pos then
			local x, y = ISM.j_pointer_pos.x, ISM.j_pointer_pos.y
			local wx, wy = game_gui:s2g(V.v(x, y))
			local ee = game_gui:entity_at_pos(wx, wy)

			if ee and ee.tower and ee.tower.can_hover and ee ~= game_gui.last_tower_hover then
				game_gui:show_clickable_hover(ee)
			end
		end
	elseif game_gui.mode == GUI_MODE_IDLE or game_gui.mode == GUI_MODE_SWAP_TOWER or game_gui.mode == GUI_MODE_TOWER_COMBINATION then
		local x, y = game_gui.window:get_mouse_position()
		local lx, ly = game_gui._last_mouse_pos_x, game_gui._last_mouse_pos_y

		if x ~= lx or y ~= ly then
			game_gui._last_mouse_pos_x, game_gui._last_mouse_pos_y = x, y

			local wx, wy = game_gui:s2g(V.v(x, y))
			local ee = game_gui:entity_at_pos(wx, wy)
			local lastt = game_gui.last_tower_hover

			if ee and ee.tower and ee.tower.can_hover and ee ~= lastt then
				game_gui:show_clickable_hover(ee)
			elseif lastt and (not ee or ee ~= lastt) then
				game_gui:hide_clickable_hover()

				self.last_tower_hover = nil
			end
		end
	else
		game_gui:hide_clickable_hover()
	end
end

function game_gui:mousepressed(x, y, button, istouch)
	if button == 2 and not DEBUG_RIGHT_CLICK then
		game_gui.c_deselect()
	else
		self.window:mousepressed(x, y, button, istouch)
	end
end

function game_gui:mousereleased(x, y, button, istouch)
	self.window:mousereleased(x, y, button, istouch)
end

function game_gui:keypressed(key, isrepeat)
	if DEBUG and DEBUG_KEYS_ON and DBG_SLIDE_EDITOR and game_gui.SEL_VIEW and dbe:keypressed(game_gui.SEL_VIEW, key, isrepeat) then
		return true
	end
end

function game_gui:keyreleased(key, isrepeat)
	return
end

function game_gui:wheelmoved(dx, dy)
	self.window:wheelmoved(dx, dy)
end

function game_gui:gamepadpressed(joystick, button)
	if self.mouse_pointer then
		self.mouse_pointer:on_gamepad_pressed(joystick, button, self.mode)
	end
end

function game_gui:gamepadreleased(joystick, button)
	if self.mouse_pointer then
		self.mouse_pointer:on_gamepad_released(joystick, button, self.mode)
	end
end

function game_gui:touchpressed(id, x, y, dx, dy, pressure)
	self.window:touchpressed(id, x, y, dx, dy, pressure)
end

function game_gui:touchreleased(id, x, y, dx, dy, pressure)
	self.window:touchreleased(id, x, y, dx, dy, pressure)
end

function game_gui:touchmoved(id, x, y, dx, dy, pressure)
	self.window:touchmoved(id, x, y, dx, dy, pressure)
end

function game_gui:focus(focus)
	if focus or self.game.store.paused or self.gui_hud_hidden or DEBUG_IGNORE_FOCUS then
		return
	end

	if not IS_MOBILE and not self.pause_on_switch then
		return
	end

	local pv = self.window and self.window:ci("popup_ingame_options")

	if pv and pv.hidden then
		game_gui.c_pause()
	end
end

function game_gui:w2u(p, snap)
	local sx = (p.x * game.game_scale - game.camera.x) * game.camera.zoom / game_gui.gui_scale + self.sw / 2
	local sy = ((game.ref_h - p.y) * game.game_scale - game.camera.y) * game.camera.zoom / game_gui.gui_scale + self.sh / 2

	if snap then
		sx, sy = math.floor(sx + 0.5), math.floor(sy + 0.5)
	end

	return sx, sy
end

function game_gui:u2w(s)
	local px = ((s.x - self.sw / 2) * game_gui.gui_scale / game.camera.zoom + game.camera.x) / game.game_scale
	local py = game.ref_h - ((s.y - self.sh / 2) * game_gui.gui_scale / game.camera.zoom + game.camera.y) / game.game_scale

	return px, py
end

function game_gui:s2u(s)
	local ux, uy = s.x / self.gui_scale, s.y / self.gui_scale

	return ux, uy
end

function game_gui:u2s(u, snap)
	if snap then
		return math.floor(u.x * self.gui_scale + 0.5), math.floor(u.y * self.gui_scale + 0.5)
	else
		return u.x * self.gui_scale, u.y * self.gui_scale
	end
end

function game_gui:g2s(p, snap)
	local x, y = self:w2u(p, false)
	local sx, sy = self:u2s(V.v(x, y), snap)

	return sx, sy
end

function game_gui:s2g(s)
	local px, py = self:s2u(s)
	local wx, wy = self:u2w(V.v(px, py))

	return wx, wy
end

function game_gui:get_ism_state()
	return self.mode
end

function game_gui:set_mode(mode)
	local new_mode = mode or GUI_MODE_IDLE

	log.debug("  CHANGING MODE: %s -> %s", self.mode, new_mode)

	self.mode = new_mode

	self.mouse_pointer:update_pointer(mode)
end

function game_gui:entity_at_pos(x, y)
	local found = {}

	for _, e in pairs(self.game.simulation.store.entities) do
		if e.pos and e.ui and e.ui.can_click then
			local r = e.ui.click_rect

			if x > e.pos.x + r.pos.x and x < e.pos.x + r.pos.x + r.size.x and y > e.pos.y + r.pos.y and y < e.pos.y + r.pos.y + r.size.y then
				table.insert(found, e)
			end
		end
	end

	table.sort(found, function(e1, e2)
		if e1.ui.z == e2.ui.z then
			return e1.pos.y < e2.pos.y
		else
			return e1.ui.z > e2.ui.z
		end
	end)

	if #found > 0 then
		local e = found[1]

		return e
	else
		return nil
	end
end

function game_gui:drag_entity_around_pos(x, y, margin)
	local found = {}

	for _, e in pairs(self.game.simulation.store.entities) do
		if e.pos and e.ui and e.ui.can_click and (e.health and not e.health.dead or e.tower and e.motion) then
			local r = e.ui.click_rect

			if e.ui and e.ui.can_click and e.nav_grid and (x > e.pos.x + r.pos.x and x < e.pos.x + r.pos.x + r.size.x and y > e.pos.y + r.pos.y and y < e.pos.y + r.pos.y + r.size.y or x > e.pos.x + r.pos.x and x < e.pos.x + r.pos.x + r.size.x and y - margin > e.pos.y + r.pos.y and y - margin < e.pos.y + r.pos.y + r.size.y or x > e.pos.x + r.pos.x and x < e.pos.x + r.pos.x + r.size.x and y + margin > e.pos.y + r.pos.y and y + margin < e.pos.y + r.pos.y + r.size.y or x - margin > e.pos.x + r.pos.x and x - margin < e.pos.x + r.pos.x + r.size.x and y > e.pos.y + r.pos.y and y < e.pos.y + r.pos.y + r.size.y or x + margin > e.pos.x + r.pos.x and x + margin < e.pos.x + r.pos.x + r.size.x and y > e.pos.y + r.pos.y and y < e.pos.y + r.pos.y + r.size.y or x - margin > e.pos.x + r.pos.x and x - margin < e.pos.x + r.pos.x + r.size.x and y + margin > e.pos.y + r.pos.y and y + margin < e.pos.y + r.pos.y + r.size.y or x - margin > e.pos.x + r.pos.x and x - margin < e.pos.x + r.pos.x + r.size.x and y - margin > e.pos.y + r.pos.y and y - margin < e.pos.y + r.pos.y + r.size.y or x + margin > e.pos.x + r.pos.x and x + margin < e.pos.x + r.pos.x + r.size.x and y - margin > e.pos.y + r.pos.y and y - margin < e.pos.y + r.pos.y + r.size.y or x + margin > e.pos.x + r.pos.x and x + margin < e.pos.x + r.pos.x + r.size.x and y + margin > e.pos.y + r.pos.y and y + margin < e.pos.y + r.pos.y + r.size.y) then
				table.insert(found, e)
			end
		end
	end

	table.sort(found, function(e1, e2)
		if e1.ui.z == e2.ui.z then
			return e1.pos.y < e2.pos.y
		else
			return e1.ui.z > e2.ui.z
		end
	end)

	if #found > 0 then
		local e = found[1]

		log.paranoid("entity:%s template:%s", e.id, e.template_name)

		return e
	else
		return nil
	end
end

function game_gui:entity_by_id(id)
	return self.game.simulation.store.entities[id]
end

function game_gui:create_wave_flags(group)
	self:remove_wave_flags()

	self.wave_flags = {}

	local store = self.game.store
	local flags_positions = store.level.locations.entrances

	for _, w in pairs(group.waves) do
		local item = flags_positions[w.path_index]

		if item and P:is_path_active(w.path_index) and W:is_flag_visible(w.path_index) then
			local duration = group.group_idx > 1 and group.interval / FPS or nil
			local incoming_report = GU.incoming_wave_report(group, w.path_index, self.game.store.level_mode)

			if game_gui.game.store.level_idx == 16 and self.game.store.level_mode == GAME_MODE_CAMPAIGN then
				incoming_report = GU.incoming_wave_report(group, w.path_index, GAME_MODE_IRON)
			end

			local wf = WaveFlag:new(w.some_flying, duration, incoming_report)

			wf.pointer.r = item.r
			wf.hidden = false
			wf.path_index = w.path_index

			local vf = V.v(V.rotate(item.r, 1, 0))
			local wfx, wfy = self:w2u(item.pos)
			local pf = V.v(wfx, wfy)
			local margins = table.deepclone(self.safe_frame)

			margins.l = margins.l + 65
			margins.r = margins.r + 65
			margins.t = margins.t + 65
			margins.b = margins.b + 65
			wf.world_pos = item.pos

			wf:update(0)
			wid("layer_wave_flags"):add_child(wf, 1)
			table.insert(self.wave_flags, wf)

			local av = WaveAlertView:new(wf)

			wid("alerts_view"):add_child(av)

			wf.alert_view = av
		end
	end
end

function game_gui:deselect_wave_flags()
	if self.wave_flags then
		for _, v in pairs(self.wave_flags) do
			v:deselect()
		end
	end
end

function game_gui:show_wave_flags()
	if self.wave_flags then
		for _, v in pairs(self.wave_flags) do
			v:enable()

			v.hidden = false
		end
	end
end

function game_gui:hide_wave_flags()
	if self.wave_flags then
		for _, v in pairs(self.wave_flags) do
			v:disable(false)

			v.hidden = true
		end
	end
end

function game_gui:remove_wave_flags()
	if self.wave_flags then
		for _, v in pairs(self.wave_flags) do
			v:disable(false)
			v:remove_with_animation()
		end

		wid("incoming_tooltip"):hide()
	end
end

function game_gui:find_flag_position(pf, vf, margins, len)
	local function intersection(p1, v1, p2, v2)
		local v1xv2 = V.cross(v1.x, v1.y, v2.x, v2.y)

		if math.abs(v1xv2) < 1e-05 then
			return nil
		else
			local sx, sy = V.sub(p2.x, p2.y, p1.x, p1.y)
			local m = V.cross(sx, sy, v2.x, v2.y) / v1xv2
			local pi = V.v(V.add(p1.x, p1.y, V.mul(m, v1.x, v1.y)))
			local a = V.angleTo(v1.x, v1.y, pi.x - p1.x, pi.y - p1.y)

			return pi, math.abs(a) < math.pi / 4
		end
	end

	local vc = self.game.store.visible_coords
	local borders = {
		{
			V.v(0, vc.top),
			V.v(1, 0)
		},
		{
			V.v(0, vc.bottom),
			V.v(1, 0)
		},
		{
			V.v(vc.right, 0),
			V.v(0, 1)
		},
		{
			V.v(vc.left, 0),
			V.v(0, 1)
		}
	}
	local isects = {}

	for _, b in pairs(borders) do
		local pi, towards = intersection(pf, vf, b[1], b[2])

		if pi then
			table.insert(isects, pi)
		end
	end

	table.sort(isects, function(p1, p2)
		return V.dist2(pf.x, pf.y, p1.x, p1.y) < V.dist2(pf.x, pf.y, p2.x, p2.y)
	end)

	local pi = isects[1]
	local margin = 0

	if pi.y == vc.top then
		margin = margins.t
	elseif pi.y == vc.bottom then
		margin = margins.b
	elseif pi.x == vc.left then
		margin = margins.l
	elseif pi.x == vc.right then
		margin = margins.r
	else
		log.error("wave flag margin could not be determined. pos %s,%s", pf.x, pf.y)
	end

	if pi.y == vc.top or pi.y == vc.bottom then
		if margin > V.dist(pf.x, pf.y, pi.x, pi.y) then
			local ox, oy = V.mul(-margin, vf.x, vf.y)

			pi.x, pi.y = V.add(pi.x, pi.y, ox, oy)

			log.debug("top/bottom flag at %s,%s inside margin, pushing it back to %s,%s", pf.x, pf.y, pi.x, pi.y)

			return pi
		else
			return pf
		end
	else
		if len and V.dist(pf.x, pf.y, pi.x, pi.y) > len + margin then
			local ox, oy = V.mul(len, vf.x, vf.y)

			return V.v(V.add(pf.x, pf.y, ox, oy))
		else
			local ox, oy = V.mul(-margin, vf.x, vf.y)

			pi.x, pi.y = V.add(pi.x, pi.y, ox, oy)
		end

		return pi
	end
end

function game_gui:show_early_wave_reward()
	if game_gui.game.store.early_wave_reward > 0 then
		S:queue("GUICoins")

		local reward_fx = WaveRewardFx:new(game_gui.game.store.early_wave_reward)

		if IS_MOBILE then
			local x, y = self.window:get_mouse_position()
			local wx, wy = self.window:screen_to_view(x, y)

			wy = wy - reward_fx.size.y
			reward_fx.pos = V.v(wx, wy)

			wid("layer_gui_hud"):add_child(reward_fx)
			log.debug("show early wave reward at %s,%s", wx, wy)
		else
			local gv = wid("hud_view"):ci("hud_gold_label")

			reward_fx.pos = V.v(gv.pos.x, gv.pos.y + reward_fx.size.y)

			wid("hud_view"):add_child(reward_fx)
		end
	end
end

function game_gui:refresh_bar_positions()
	local lgh = wid("layer_gui_hud")
	local hv = wid("hero_portraits_view")
	local pv = wid("powers_view")
	local bv = wid("bag_view")
	local hv_r = hv:get_bounds_rect(true)

	if DEBUG and hv_r.size.x == 0 then
		log.error("DEBUG PATCH SETTING THE BOTTOM BAR POSITIONS. RESTART GAME TO FIX THEM")

		hv_r.size.x = 250
	end

	local sep = 0

	pv.pos.x = hv_r.pos.x + hv_r.size.x + sep

	local pv_r = pv:get_bounds_rect(true)
	local bv_r = bv:get_bounds_rect(true)
	local leftx = pv_r.pos.x + pv_r.size.x
	local rightx = bv_r.pos.x

	if features.no_gems then
		bv.hidden = true
		rightx = self.sw - self.safe_frame.rb
	end

	local ib = wid("infobar_view")

	if IS_MOBILE then
		ib.pos.x = (leftx + rightx) / 2
	else
		local ib_r = ib:get_bounds_rect(true)

		ib.pos.x = math.max(leftx + ib_r.size.x / 2, game_gui.sw / 2)
	end
end

function game_gui:add_hero(hero_entity)
	local hero_index
	local counter = 1

	for i, v in pairs(wid("hero_portraits_view").children) do
		if v:isInstanceOf(HeroPortrait) then
			if not v.hero_entity then
				v:set_hero_entity(hero_entity)

				hero_index = counter
				v.hero_idx = counter

				break
			end

			counter = counter + 1
		end
	end

	if not hero_index then
		return
	end

	if wid("notification_queue_view").with_heroes_y then
		wid("notification_queue_view").pos.y = wid("notification_queue_view").with_heroes_y
	end

	log.debug("Adding hero: %s - %i", hero_entity.template_name, hero_index)

	local power_index = hero_index + 1
	local button_id = "power_button_" .. power_index
	local button = wid(button_id)

	if button and hero_entity.hero.skills and hero_entity.hero.skills.ultimate then
		local image_name = "portraits_power_hero_" .. hero_entity.info.ultimate_icon

		button.can_be_unlocked = true

		button:set_image(image_name)

		button.default_image_name = image_name

		local pre = (hero_entity.info.i18n_key or string.upper(hero_entity.template_name)) .. "_" .. hero_entity.hero.skills.ultimate.key

		button.i18n_title = pre .. "_MENUBOTTOM_NAME"
		button.i18n_desc = pre .. "_MENUBOTTOM_DESCRIPTION"

		log.debug("hero power button prefix: %s", pre)
	end

	self:refresh_bar_positions()

	if self.mouse_pointer then
		self.mouse_pointer:refresh_hero_pointers()
	end
end

function game_gui:hide_hero(hero_idx)
	local portrait = wid("hero_portraits_view").children[hero_idx]

	if portrait:isInstanceOf(HeroPortrait) then
		portrait:close_door()
	end
end

function game_gui:show_hero(hero_idx)
	local portrait = wid("hero_portraits_view").children[hero_idx]

	if portrait:isInstanceOf(HeroPortrait) then
		portrait:open_door()
	end
end

function game_gui:show_gui_hud()
	local safe_frame = self.safe_frame

	self.gui_hud_hidden = nil

	if self.gui_hud_timer_handles then
		for _, h in pairs(self.gui_hud_timer_handles) do
			timer:cancel(h)
		end
	end

	local easing = "out-cubic"
	local st = 0.6

	self.gui_hud_timer_handles = {
		timer:tween(st, wid("hud_view").pos, {
			y = safe_frame.tl
		}, easing),
		timer:tween(st, wid("pause_button_view").pos, {
			y = safe_frame.tr
		}, easing),
		timer:tween(st, wid("notification_queue_view").pos, {
			x = safe_frame.l
		}, easing),
		timer:tween(st, wid("hero_portraits_view").pos, {
			y = wid("powers_view").shown_y
		}, easing),
		timer:tween(st, wid("powers_view").pos, {
			y = wid("powers_view").shown_y
		}, easing),
		timer:tween(st, wid("bag_view").pos, {
			y = wid("bag_view").shown_y
		}, easing)
	}
	wid("alerts_view").hidden = nil

	wid("touch_view"):enable()

	if self.game.store.level.hide_notifications then
		wid("notification_queue_view").hidden = true
	end

	for _, c in pairs(wid("bag_view").children) do
		if c:isInstanceOf(BagItemButton) then
			c:refresh()
		end
	end

	self:show_wave_flags()
	self:show_balloons()
end

function game_gui:hide_gui_hud(skip_animation)
	local safe_frame = self.safe_frame

	self.gui_hud_hidden = true

	if self.gui_hud_timer_handles then
		for _, h in pairs(self.gui_hud_timer_handles) do
			timer:cancel(h)
		end
	end

	if skip_animation then
		wid("hud_view").pos.y = -1.5 * wid("hud_view").size.y
		wid("pause_button_view").pos.y = -1.5 * wid("pause_button_view").size.y
		wid("notification_queue_view").pos.x = -1.5 * wid("notification_queue_view").size.x
		wid("hero_portraits_view").pos.y = wid("infobar_view").hidden_y
		wid("powers_view").pos.y = wid("powers_view").hidden_y or self.ref_h + wid("powers_view").anchor.y
		wid("infobar_view").pos.y = wid("infobar_view").hidden_y
		wid("bag_view").pos.y = wid("bag_view").hidden_y
	else
		local easing = "out-cubic"
		local st = 0.6

		self.gui_hud_timer_handles = {
			timer:tween(st, wid("hud_view").pos, {
				y = -1.5 * wid("hud_view").size.y
			}, easing),
			timer:tween(st, wid("pause_button_view").pos, {
				y = -1.5 * wid("pause_button_view").size.y
			}, easing),
			timer:tween(st, wid("notification_queue_view").pos, {
				x = -1.5 * wid("notification_queue_view").size.x
			}, easing),
			timer:tween(st, wid("hero_portraits_view").pos, {
				y = wid("hero_portraits_view").hidden_y
			}, easing),
			timer:tween(st, wid("powers_view").pos, {
				y = wid("powers_view").hidden_y or self.ref_h + wid("powers_view").anchor.y
			}, easing),
			timer:tween(st, wid("bag_view").pos, {
				y = wid("bag_view").hidden_y
			}, easing)
		}

		wid("infobar_view"):hide()
	end

	wid("alerts_view").hidden = true

	wid("touch_view"):disable()
	self:hide_wave_flags()
	self:hide_balloons()
end

function game_gui:hide_gui_hud_tutorial(skip_animation)
	local safe_frame = self.safe_frame

	self.gui_hud_hidden = true

	if self.gui_hud_timer_handles then
		for _, h in pairs(self.gui_hud_timer_handles) do
			timer:cancel(h)
		end
	end

	local easing = "out-cubic"
	local st = 0.4

	self.gui_hud_timer_handles = {
		timer:tween(st, wid("hud_view").pos, {
			y = safe_frame.t
		}, easing),
		timer:tween(st, wid("pause_button_view").pos, {
			y = safe_frame.t
		}, easing)
	}
	wid("bag_view").pos.y = self.ref_h + wid("bag_view").anchor.y
end

function game_gui:hide_second_hero()
	wid("hero_portrait_1").hidden = false
	wid("hero_portrait_2").hidden = true
	wid("power_button_3").hidden = true

	self:refresh_bar_positions()
end

function game_gui:show_feedback(name, x, y, wx, wy)
	if name == "rally" then
		local e = E:create_entity("decal_rally_feedback")

		e.pos.x = wx
		e.pos.y = wy
		e.render.sprites[1].ts = game_gui.game.store.tick_ts

		self.game.simulation:insert_entity(e)
	else
		local v = wid("feedback_" .. name .. "_view")

		v.pos.x, v.pos.y = x, y
		v.wx, v.wy = wx, wy
		v.hidden = false
		v.ts = 0
	end
end

function game_gui:show_tower_range(style, entity, range)
	local template

	if style == "rally" then
		template = "decal_rally_range_KR5"
	elseif style == "rally_upgrade" then
		template = "decal_rally_range_KR5"
	elseif style == "tower" then
		template = "decal_tower_range_KR5"
	elseif style == "upgrade" then
		template = "decal_tower_range_KR5"
	else
		log.error("invalid tower range style %s", style)

		return
	end

	local rr = E:create_entity(template)

	rr.range_shown = range
	rr.pos.x, rr.pos.y = entity.pos.x + entity.tower.range_offset.x, entity.pos.y + entity.tower.range_offset.y

	for i = 1, 1 do
		rr.render.sprites[i].scale.x = (i % 2 == 0 and -1 or 1) * range / rr.actual_radius
		rr.render.sprites[i].scale.y = (i > 2 and -1 or 1) * ASPECT * range / rr.actual_radius
	end

	if self.tower_ranges[style] then
		self:hide_tower_range(style)
	end

	self.tower_ranges[style] = rr

	self.game.simulation:insert_entity(rr)
end

function game_gui:hide_tower_range(style)
	if style == "all" then
		self:hide_tower_range("rally")
		self:hide_tower_range("rally_upgrade")
		self:hide_tower_range("tower")
		self:hide_tower_range("upgrade")
	elseif self.tower_ranges and self.tower_ranges[style] then
		self.game.simulation:remove_entity(self.tower_ranges[style])

		self.tower_ranges[style] = nil
	end
end

function game_gui:show_clickable_hover(entity)
	if game_gui.game.store.paused then
		return
	end

	if self.last_tower_hover then
		if self.last_tower_hover ~= entity then
			self:hide_clickable_hover()
		elseif self.clickable_hover_controller and not self.clickable_hover_controller.done then
			return
		end
	end

	if not entity or not game_gui.game.store.entities[entity.id] then
		log.debug("clickable not in store. skipping hover")

		return
	end

	self.last_tower_hover = entity

	if ISM.last_input ~= I_TOUCH then
		local h = E:create_entity("clickable_hover_circle_controller")

		h.target = entity

		self.game.simulation:insert_entity(h)

		self.clickable_hover_controller = h

		S:queue("GUIQuickMenuOver")
	end
end

function game_gui:hide_clickable_hover()
	if self.clickable_hover_controller then
		self.clickable_hover_controller.done = true
		self.clickable_hover_controller = nil
	end
end

function game_gui:show_ghost_hover()
	local h = E:create_entity("tower_ghost_hover_controller")

	self.game.simulation:insert_entity(h)

	self.tower_ghost_hover_controller = h
end

function game_gui:hide_ghost_hover()
	if self.tower_ghost_hover_controller then
		self.game.simulation:remove_entity(self.tower_ghost_hover_controller)

		self.tower_ghost_hover_controller = nil
	end
end

function game_gui:show_decal_preview(e)
	local h = E:create_entity(e.decal_preview_controller)
	h.owner = e
	self.game.simulation:insert_entity(h)
	self.tower_ghost_hover_controller = h
end

function game_gui:hide_decal_preview()
	if self.tower_ghost_hover_controller then
		self.game.simulation:remove_entity(self.tower_ghost_hover_controller)
		self.tower_ghost_hover_controller = nil
	end
end

function game_gui:queue_notification(id, force)
	local n = data.notifications[id]

	if not n then
		log.info("Notification with id:%s not found", id)

		return
	end

	if not n.icon then
		log.info("Notification with id:%s not icon found", id)

		return
	end

	if U.is_seen(game_gui.game.store, id) and not n.always and not force then
		log.info("Notification with id:%s already seen", id)

		return
	end

	U.mark_seen(game_gui.game.store, id)

	local nv = wid("notification_queue_view")
	local v_icon = NotificationIcon:new(n.icon, id, n.layout)

	v_icon.pos.y = v_icon.size.y / 2 + #nv.children * (v_icon.size.y + nv.icon_space_y)
	v_icon.pos.x = v_icon.size.x / 2 - 13

	nv:add_child(v_icon)
	log.info("Notification with id:%s show noti", id)
	S:queue("GUINotificationSecondLevel")

	if n.icon_signals then
		for _, s in pairs(n.icon_signals) do
			signal.emit(unpack(s))
		end
	end
end

function game_gui:show_balloon(id)
	log.debug("balloon %s", id)

	local b = TextBalloon:new(id)

	if b.world_pos then
		wid("layer_gui_world"):add_child(b, 1)
	else
		wid("layer_gui_hud"):add_child(b, 1)
	end

	if self.gui_hud_hidden then
		b.hidden = true
	end
end

function game_gui:show_balloon_tutorial(id, show)
	log.debug("balloon %s", id)

	local b = wid(id)

	if not b then
		if features.censored_cn then
			local function is_red(c)
				local delta = 50

				return c[1] > c[2] + delta and c[1] > c[3] + delta
			end

			local bd = data.text_balloons[id]

			if bd.text_color and is_red(bd.text_color) then
				bd.text_color = {
					180,
					0,
					255,
					255
				}
			end

			if bd.line_color and is_red(bd.line_color) then
				bd.line_color = {
					180,
					0,
					255,
					255
				}
			end
		end

		b = TextBalloon:new(id)

		if b.world_pos then
			wid("layer_gui_world"):add_child(b, 1)
		elseif not b.add_as_child then
			wid("layer_gui_hud"):add_child(b)
		end
	end

	self.tutorial_balloon = b
	b.hidden = show
end

function game_gui:show_balloons(keep_ts)
	for _, v in pairs({
		wid("layer_gui_world"),
		wid("layer_gui_hud")
	}) do
		for _, c in pairs(v.children) do
			if c:isInstanceOf(TextBalloon) then
				c:show(keep_ts)
			end
		end
	end
end

function game_gui:hide_balloons()
	for _, v in pairs({
		wid("layer_gui_world"),
		wid("layer_gui_hud")
	}) do
		for _, c in pairs(v.children) do
			if c:isInstanceOf(TextBalloon) then
				c:hide(true)
			end
		end
	end
end

function game_gui.get_pos_from_ctx(ctx)
	local x, y

	if ctx.x and ctx.y then
		x, y = ctx.x, ctx.y
	elseif ISM.j_pointer_pos then
		x, y = ISM.j_pointer_pos.x, ISM.j_pointer_pos.y
	else
		log.error("no position available")

		return nil
	end

	local wx, wy = game_gui:s2g(V.v(x, y))

	return x, y, wx, wy
end

function game_gui.q_move_pointer(ctx, constraints)
	local lpp = ISM.j_pointer_pos

	if ctx.key then
		local vx, vy = ISM.get_dir_step(ctx.key)
		local step = ctx.key_shift and ISM.nav_key_step_alt or ISM.nav_key_step

		lpp.x = lpp.x + vx * step * game_gui.sh / REF_H
		lpp.y = lpp.y + vy * step * game_gui.sh / REF_H
	elseif ctx.axis_value then
		local ts = love.timer.getTime()

		if not game_gui._j_last_move_accel or ts - ctx.counters.j_axes_released_ts < 0.1 then
			game_gui._j_last_move_accel = 1
		else
			game_gui._j_last_move_accel = km.clamp(1, ISM.joy_pointer_accel_max, game_gui._j_last_move_accel + ISM.joy_pointer_accel * ctx.dt)
		end

		local accel = game_gui._j_last_move_accel or 1
		local speed = ISM.joy_pointer_speed * game_gui.sh / REF_H
		local power = ISM.joy_pointer_power
		local vx, vy = ctx.axis_value[1], ctx.axis_value[2]

		lpp.x = lpp.x + km.sign(vx) * math.pow(math.abs(vx), power) * speed * ctx.dt * accel
		lpp.y = lpp.y + km.sign(vy) * math.pow(math.abs(vy), power) * speed * ctx.dt * accel
	end

	local e = game_gui.selected_entity

	if constraints and constraints == "rally" and e and e.barrack then
		local rc = V.v(V.add(e.pos.x, e.pos.y, e.tower.range_offset.x, e.tower.range_offset.y))
		local cx, cy = game_gui:g2s(rc)
		local rcx, __ = game_gui:g2s(V.v(rc.x + e.barrack.rally_range, rc.y))
		local rmax = (rcx - cx) * 0.99
		local a, r = V.toPolar(lpp.x - cx, (lpp.y - cy) / ASPECT)

		if rmax < r then
			r = rmax

			local nx, ny = V.fromPolar(a, r)

			lpp.x, lpp.y = nx + cx, ny * ASPECT + cy
		end
	else
		lpp.x = km.clamp(0, game_gui.sw * game_gui.gui_scale, lpp.x)
		lpp.y = km.clamp(0, game_gui.sh * game_gui.gui_scale, lpp.y)
	end

	return true
end

function game_gui.q_is_power_active(ctx, power)
	local b = wid("power_button_" .. power)

	if not b then
		log.info("power button %s is nil", power)

		return false
	end

	return not b:is_disabled()
end

function game_gui.q_is_hero_active(ctx, hero_idx)
	local hero_portrait = wid("hero_portrait_" .. hero_idx)

	return hero_portrait and not hero_portrait:is_disabled()
end

function game_gui.q_is_re_active(ctx)
	for _, e in E:filter_iter(game.store.entities, "reinforcement") do
		if e and e.ui and e.ui.can_click and e.ui.can_select and e.nav_grid and e.health and not e.health.dead then
			return true
		end
	end

	return false
end

function game_gui.q_is_hero_selected(ctx, hero_idx)
	local hero_portrait = wid("hero_portrait_" .. hero_idx)

	if not hero_portrait or hero_portrait:is_disabled() then
		return false
	end

	local hero_id = hero_portrait and hero_portrait.hero_id

	if not hero_id then
		return false
	end

	local e = game_gui:entity_by_id(hero_id)

	return e and e == game_gui.selected_entity
end

function game_gui.q_is_re_selected(ctx)
	local e = game_gui.selected_entity

	if e and e.reinforcement then
		return true
	end

	return false
end

function game_gui.q_matches_hero_states(ctx, hero_1_state, hero_2_state)
	local h1_active = game_gui.q_is_hero_active(ctx, 1)
	local h2_active = game_gui.q_is_hero_active(ctx, 2)
	local h1_sel = game_gui.q_is_hero_selected(ctx, 1)
	local h2_sel = game_gui.q_is_hero_selected(ctx, 2)
	local m1 = false

	if hero_1_state == "s" then
		m1 = h1_sel
	elseif hero_1_state == "a" then
		m1 = h1_active
	elseif hero_1_state == "i" then
		m1 = not h1_active
	elseif hero_1_state == "x" then
		m1 = true
	end

	local m2 = false

	if hero_2_state == "s" then
		m2 = h2_sel
	elseif hero_2_state == "a" then
		m2 = h2_active
	elseif hero_2_state == "i" then
		m2 = not h2_active
	elseif hero_2_state == "x" then
		m2 = true
	end

	return m1 and m2
end

function game_gui.q_can_click_tower(ctx, tower)
	local e = tower or game_gui.last_tower_hover

	if e and e.ui then
		if e.ui.can_click then
			return true
		elseif e.ui.click_proxies then
			for _, cp in pairs(e.ui.click_proxies) do
				if cp and cp.ui and cp.ui.can_click then
					return true
				end
			end
		end
	end
end

function game_gui.q_tower_selected(ctx)
	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	local e = game_gui:entity_at_pos(wx, wy)

	if e and e.ui and e.ui.can_click and e.tower then
		ctx.entity = e

		return true
	end

	return false
end

function game_gui.q_can_click_entity(ctx)
	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	local e = game_gui:entity_at_pos(wx, wy)

	log.debug("ENTITY:%s AT:%s,%s", e and e.id, wx, wy)

	if e and e.ui and e.ui.can_click then
		ctx.entity = e

		return true
	else
		log.debug("no entity found at %s,%s", wx, wy)

		return false
	end
end

function game_gui.q_can_drag_entity(ctx)
	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	local e = game_gui:drag_entity_around_pos(wx, wy, DRAG_ENTITY_LOOKUP_MARGIN)

	log.debug("DRAG_ENTITY:%s AT:%s,%s", e and e.id, wx, wy)

	if e and e.ui and e.ui.can_click and e.nav_grid then
		ctx.entity = e

		return true
	else
		log.debug("no entity found at %s,%s", wx, wy)

		return false
	end
end

function game_gui.q_selected_swappable_tower(ctx)
	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	local e = game_gui:entity_at_pos(wx, wy)
	local pressed_start = game_gui.pressed_ipos

	if e and e ~= game_gui.swap_entity and e.tower and e.tower.can_be_sold and e.ui and e.ui.can_click then
		ctx.entity = e

		return true
	end

	return false
end

function game_gui.q_selected_combined_tower(ctx)
	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)
	if not wx then
		return false
	end
	local e = game_gui:entity_at_pos(wx, wy)
	local h = game_gui.tower_ghost_hover_controller
	if e and e ~= game_gui.swap_entity and e.tower and e.ui and e.ui.can_click and h and h:filter_func(e) then
		ctx.entity = e
		return true
	end
	return false
end

function game_gui.q_selected_drag_entity(ctx)
	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	local e = game_gui.pressed_entity
	local pressed_start = game_gui.pressed_ipos

	if e then
		if e.soldier and e.soldier.tower_id then
			return false
		end

		local dist = V.dist(pressed_start.x, pressed_start.y, wx, wy)

		if dist > DRAG_ENTITY_THRESHOLD then
			return true
		end
	end

	return false
end

function game_gui.q_selected_drag_tower(ctx)
	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	local e = game_gui.pressed_entity
	local pressed_start = game_gui.pressed_ipos

	if e and e.soldier and e.soldier.tower_id then
		local dist = V.dist(pressed_start.x, pressed_start.y, wx, wy)

		if dist > DRAG_TOWER_THRESHOLD then
			return true
		end
	end

	return false
end

function game_gui.q_can_set_tower_rally(ctx)
	local e = game_gui.selected_entity

	if not e then
		log.error("selected_entity is nil")

		return false
	end

	local b = e.barrack

	if not b then
		log.error("tower %s is not a barrack", e.id)

		return false
	end

	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	local rc = V.v(V.add(e.pos.x, e.pos.y, e.tower.range_offset.x, e.tower.range_offset.y))

	if U.is_inside_ellipse(V.v(wx, wy), rc, b.rally_range) and (b.rally_anywhere or P:valid_node_nearby(wx, wy, nil, NF_RALLY) and GR:cell_is_only(wx, wy, b.rally_terrains)) then
		return true
	else
		local nodes = P:nearest_nodes(wx, wy, nil, {
			1,
			2,
			3
		}, true, NF_RALLY, function(node)
			return U.is_inside_ellipse(node, rc, b.rally_range) and GR:cell_is_only(node.x, node.y, b.rally_terrains)
		end, 3)
	
		if nodes and #nodes > 0 then
			local pi, spi, ni, dist = unpack(nodes[1])
			local npos = P:node_pos(pi, spi, ni)
			ctx.x, ctx.y = game_gui:g2s(npos)
			return true
		end

		game_gui:show_feedback("error", x, y, wx, wy)
		return false
	end
end

function game_gui.q_can_set_hero_rally(ctx, hero_idx)
	if hero_idx and not game_gui.q_is_hero_selected(ctx, hero_idx) then
		return false
	end

	local e = game_gui.selected_entity

	if not e then
		log.error("selected entity is nil")

		return false
	end

	if not e.hero then
		log.error("selected entitiy is not a hero")

		return false
	end

	return game_gui.q_can_set_rally(ctx)
end

function game_gui.q_can_set_mobile_tower_rally(ctx)
	local e = game_gui.selected_entity

	if not e then
		log.error("selected entity is nil")
		return false
	end

	if not e.tower then
		log.error("selected entitiy is not a tower")
		return false
	end

	return game_gui.q_can_set_rally(ctx)
end

function game_gui.q_can_set_rally(ctx)
	local e = game_gui.selected_entity

	if not e then
		log.error("selected entity is nil")

		return false
	end

	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	local rally_pos = e.reinforcement and e.nav_rally.center or e.nav_rally.pos

	if (not e.nav_rally.requires_node_nearby or P:valid_node_nearby(wx, wy, nil, NF_RALLY)) and GR:cell_is_only(wx, wy, e.nav_grid.valid_terrains_dest) then
		if e.teleport and not e.teleport.disabled and V.dist(wx, wy, e.pos.x, e.pos.y) > e.teleport.min_distance or e.launch_movement and not e.launch_movement.disabled and V.dist(wx, wy, e.pos.x, e.pos.y) > e.launch_movement.min_distance or e.nav_grid.ignore_waypoints then
			return true
		else
			local waypoints = GR:find_waypoints(e.pos, rally_pos, V.v(wx, wy), e.nav_grid.valid_terrains)

			if waypoints then
				ctx.cached_waypoints = waypoints

				return true
			end
		end
	end

	local nodes = P:nearest_nodes(wx, wy, nil, {
		1,
		2,
		3
	}, true, NF_RALLY, function(node)
		return GR:cell_is_only(node.x, node.y, e.nav_grid.valid_terrains)
	end, 3)

	if nodes and #nodes > 0 then
		local pi, spi, ni = unpack(nodes[1])
		local npos = P:node_pos(pi, spi, ni)

		ctx.rally_point_snap = {
			wx = npos.x,
			wy = npos.y
		}
		wx = npos.x
		wy = npos.y

		local waypoints = GR:find_waypoints(e.pos, rally_pos, V.v(wx, wy), e.nav_grid.valid_terrains)

		if waypoints then
			ctx.cached_waypoints = waypoints

			return true
		end
	end
	-- if not IS_MOBILE then
	-- 	-- block empty
	-- else
	-- end

	game_gui:show_feedback("error", x, y, wx, wy)

	return false
end

function game_gui.q_can_set_re_rally(ctx)
	local e = game_gui.selected_entity

	if not e then
		log.error("selected entity is nil")

		return false
	end

	if not e.reinforcement then
		log.error("selected entitiy is not a reinforcement")

		return false
	end

	return game_gui.q_can_set_rally(ctx)
end

function game_gui.q_can_fire_power(ctx, power_id)
	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	power_id = power_id or ctx.power_id

	local store = game_gui.game.store
	local e = E:create_entity("user_power_" .. power_id)

	if e.user_selection.can_select_point_fn(e, wx, wy, store) then
		return true
	else
		game_gui:show_feedback("error", x, y, wx, wy)

		return false
	end
end

function game_gui.q_can_fire_item(ctx, item_id)
	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	item_id = item_id or ctx.item_id

	local store = game_gui.game.store
	local e = E:create_entity("user_item_" .. item_id)
	local b = wid("bag_item_" .. item_id)

	e.item = b.item

	if e.user_selection.can_select_point_fn(e, wx, wy, store) then
		return true
	else
		game_gui:show_feedback("error", x, y, wx, wy)

		return false
	end
end

function game_gui.q_can_select_point(ctx)
	local store = game_gui.game.store
	local e = game_gui.selected_entity

	if not e then
		log.error("selected entity is nil")

		return false
	end

	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	if not e.user_selection.can_select_point_fn or e.user_selection.can_select_point_fn(e, wx, wy, store) then
		return true
	else
		game_gui:show_feedback("error", x, y, wx, wy)

		return false
	end
end

function game_gui.q_is_wave_ready(ctx)
	if game_gui.tutorial and game_gui.tutorial.wave_flag_disable then
		return false
	end

	return game_gui.game.store.next_wave_group_ready ~= nil
end

function game_gui.q_is_hero_custom_active(ctx)
	return false
end

function game_gui.q_has_noti_queued(ctx)
	return wid("notification_queue_view") and #wid("notification_queue_view").children > 0
end

function game_gui.c_pause(ctx, previous_gui_mode)
	if game_gui.mode == GUI_MODE_TUTORIAL_LOCK then
		previous_gui_mode = GUI_MODE_TUTORIAL_LOCK
	end

	S:pause()
	game_gui.c_deselect()
	game_gui:hide_gui_hud()

	game_gui.game.store.paused = true

	game_gui.window:focus_view()
	game_gui:set_mode(GUI_MODE_PAUSE)

	wid("popup_ingame_options").hidden = true

	wid("popup_ingame_options"):show()

	wid("popup_ingame_options").previous_gui_mode = previous_gui_mode

	signal.emit(SGN_GAME_GUI_PAUSE_SHOW)
end

function game_gui.c_resume(ctx)
	local previous_gui_mode = wid("popup_ingame_options").previous_gui_mode

	wid("popup_ingame_options"):hide()
	S:resume()

	local curtain = wid("curtain_top_view")

	if game_gui.tutorial.hide_ui then
		game_gui:hide_gui_hud_tutorial(true)

		if previous_gui_mode ~= GUI_MODE_TUTORIAL_LOCK then
			wid("touch_view"):enable()
		end

		game_gui:show_balloons()

		if not game_gui.tutorial.wave_flag_disable and game_gui.wave_flags then
			for _, v in pairs(game_gui.wave_flags) do
				v:enable()

				v.hidden = false
			end
		end
	elseif not curtain.hidden then
		game_gui:show_balloons(true)
	else
		game_gui:show_gui_hud()
	end

	game_gui.game.store.paused = false

	game_gui:set_mode(previous_gui_mode or GUI_MODE_IDLE)
	signal.emit(SGN_GAME_GUI_PAUSE_HIDE)
end

function game_gui.c_deselect(ctx, scope)
	if game_gui.mode == GUI_MODE_POWER_1 then
		game_gui.c_deselect_power(ctx, 1)
	elseif game_gui.mode == GUI_MODE_POWER_2 then
		game_gui.c_deselect_power(ctx, 2)
	elseif game_gui.mode == GUI_MODE_POWER_3 then
		game_gui.c_deselect_power(ctx, 3)
	elseif game_gui.mode == GUI_MODE_SELECT_POINT then
		game_gui.c_deselect_tower(ctx)
	elseif game_gui.mode == GUI_MODE_TOWER_MENU then
		game_gui.c_deselect_tower(ctx)
	elseif game_gui.mode == GUI_MODE_RALLY_TOWER or game_gui.mode == GUI_MODE_DRAG_RALLY_TOWER then
		game_gui.c_deselect_tower(ctx)
	elseif game_gui.mode == GUI_MODE_RALLY_HERO then
		local e = game_gui.selected_entity

		ctx = ctx or {}
		ctx.hero_id = e and e.id

		game_gui.c_deselect_heros(ctx)
	elseif game_gui.mode == GUI_MODE_RALLY_RE then
		game_gui.c_deselect_re(ctx)
	elseif game_gui.mode == GUI_MODE_POINTER then
		game_gui:set_mode(GUI_MODE_IDLE)
	elseif game_gui.mode == GUI_MODE_WAVE_FLAG then
		game_gui:deselect_wave_flags()
		game_gui.window:set_responder()
		game_gui.window:focus_view()
		game_gui:set_mode(GUI_MODE_IDLE)
	elseif game_gui.mode == GUI_MODE_ITEM_1 then
		game_gui.c_deselect_item(ctx, 1)
	elseif game_gui.mode == GUI_MODE_ITEM_2 then
		game_gui.c_deselect_item(ctx, 2)
	elseif game_gui.mode == GUI_MODE_ITEM_3 then
		game_gui.c_deselect_item(ctx, 3)
	elseif game_gui.mode == GUI_MODE_SWAP_TOWER then
		game_gui:hide_ghost_hover()
	elseif game_gui.mode == GUI_MODE_TOWER_COMBINATION then
		game_gui:hide_decal_preview()
	end

	if game_gui.selected_entity_markers then
		for _, m in pairs(game_gui.selected_entity_markers) do
			m.done = true
		end
	end

	game_gui.touch_view:disable_drag_line()

	game_gui.selected_entity = nil

	wid("infobar_view"):hide()
end

function game_gui.c_change_mode(ctx, new_state)
	game_gui:set_mode(new_state)
end

function game_gui.c_show_noti(ctx)
	local id = ctx.id
	local no_transition = ctx.no_transition
	local force_show = ctx.force
	local n = data.notifications[id]

	if not n then
		log.debug("Notification with id:%s not found", id)

		return
	end

	if not force_show and U.is_seen(game_gui.game.store, id) and not n.always then
		return
	end

	U.mark_seen(game_gui.game.store, id)

	if n and n.seen then
		for _, name in pairs(n.seen) do
			U.mark_seen(game_gui.game.store, name)
		end
	end

	game_gui.c_deselect()

	game_gui.game.store.paused = true

	game_gui:set_mode(GUI_MODE_NOTIFICATION)
	game_gui:hide_gui_hud()
	S:pause()

	n.id = id

	local tpl = kui_db:get_table("group_popup_notification_" .. n.template, n)
	local nv = NotificationView:new_from_table(tpl)

	wid("layer_gui_top"):add_child(nv, 1 + wid("layer_gui_top"):get_order(wid("modal_bg_transparent_view")))

	nv.pos.x = game_gui.sw / 2
	nv.pos.y = game_gui.sh / 2
	nv.notification = n
	nv.id = "notification_view"
	nv.base_scale = game_gui.base_scale_list.notification

	if DBG_SLIDE_EDITOR then
		dbe:inject_editor(nv, game_gui)
	end

	nv:show(no_transition)
end

function game_gui.c_hide_noti(ctx)
	local view = ctx and ctx.view

	view = view or wid("layer_gui_top"):get_child_by_id("notification_view")

	if not view then
		log.error("could not find notification view. bailing out")

		return
	end

	if ctx.show_next then
		view:remove_from_parent()
		game_gui.c_show_noti({
			no_transition = true,
			id = ctx.show_next
		})
	else
		view:hide()

		game_gui.game.store.paused = false

		game_gui:set_mode(GUI_MODE_IDLE)
		game_gui:show_gui_hud()
		S:resume()
	end
end

function game_gui.c_show_noti_queued(ctx)
	for _, c in pairs(wid("notification_queue_view").children) do
		if c and not c:is_disabled() then
			c:on_click()

			break
		end
	end
end

function game_gui.c_select_wave_flags(ctx)
	local v = wid("layer_wave_flags")

	if not v then
		log.error("could not find view %s in game_gui", "layer_wave_flags")

		return false
	end

	game_gui.c_deselect(ctx)
	game_gui:set_mode(GUI_MODE_WAVE_FLAG)
	game_gui.window:set_responder(v)

	for _, c in pairs(v.children) do
		if c:isInstanceOf(WaveFlag) then
			c:focus()
		end
	end
end

function game_gui.c_show_victory(ctx)
	game_gui.game.store.paused = true

	if game_gui.game.store.custom_game_outcome then
		game_gui.game.done_callback(game_gui.game.store.custom_game_outcome)
	else
		local pause_view = wid("popup_ingame_options")

		if pause_view and not pause_view.hidden then
			pause_view:hide()
		end

		game_gui:set_mode(GUI_MODE_DISABLED)

		local victory_view = wid("group_victory")

		victory_view:show()
		game_gui.window:set_responder(victory_view)
	end
end

function game_gui.c_show_defeat(ctx)
	game_gui.game.store.paused = true

	game_gui:hide_gui_hud()
	game_gui:hide_wave_flags()
	game_gui.c_deselect()
	game_gui:set_mode(GUI_MODE_DISABLED)
	wid("group_defeat"):show()
	game_gui.window:set_responder(wid("group_defeat"))
end

function game_gui.c_deselect_power(ctx, power)
	local b = wid("power_button_" .. power)

	if b then
		b:deselect()
		game_gui:set_mode(GUI_MODE_IDLE)
		signal.emit("power-deselected")
	else
		log.error("power button %s is nil", power)
	end
end

function game_gui.c_select_power(ctx, power)
	game_gui.c_deselect(ctx)

	local b = wid("power_button_" .. power)

	if b then
		local t = E:get_template("user_power_" .. power)

		if t and t.hero_id then
			local h = game.store.entities[t.hero_id]

			if h and h.hero and h.hero.skills.ultimate.skip_confirmation then
				game_gui.c_fire_power(ctx, power)

				return
			end
		end

		b:select()
		game_gui:set_mode("POWER_" .. power)
		signal.emit("power-selected", "POWER_" .. power)
	else
		log.error("button %s is nil", power)
	end
end

function game_gui.c_fire_power(ctx, power_id)
	power_id = power_id or ctx and ctx.power_id

	local x, y, wx, wy = 0, 0, 0, 0
	local e = E:create_entity("user_power_" .. power_id)
	local skip_confirmation = false

	if e and e.hero_id then
		local h = game.store.entities[e.hero_id]

		if h and h.hero and h.hero.skills.ultimate.skip_confirmation then
			skip_confirmation = true
		end
	end

	if not skip_confirmation then
		x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)
	end

	if not wx then
		return false
	end

	local store = game_gui.game.store

	if skip_confirmation or e.user_selection.can_select_point_fn(e, wx, wy, store) then
		e.pos.x, e.pos.y = wx, wy

		game_gui.game.simulation:insert_entity(e)

		local b = wid("power_button_" .. power_id)

		if IS_KR3 and power_id == 3 then
			local ut = E:get_template(store.main_hero.hero.skills.ultimate.controller_name)

			b.cooldown_time = ut.cooldown
		elseif e.power_cooldown_fn then
			local cooldown = e:power_cooldown_fn(game.store)

			if cooldown then
				log.debug("setting cooldown %f to power %i", cooldown, power_id)

				b.cooldown_time = cooldown
			end
		elseif e.cooldown then
			b.cooldown_time = e.cooldown
		end

		b:fire()
		game_gui:set_mode(GUI_MODE_IDLE)
		
		if not skip_confirmation then
			game_gui:show_feedback("ok", x, y, wx, wy)
		end

		signal.emit("power-used", power_id)
	else
		log.error("could not fire power %s at %s,%s", power_id, wx, wy)
	end
end

function game_gui.c_deselect_item(ctx, item)
	local b = wid("bag_item_" .. item)

	if b then
		b:deselect()
		game_gui:set_mode(GUI_MODE_IDLE)
		signal.emit("item-deselected")
	else
		log.error("item button %s is nil", item)
	end
end

function game_gui.c_fire_item(ctx, item_id)
	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	item_id = item_id or ctx.item_id

	local store = game_gui.game.store
	local e = E:create_entity("user_item_" .. item_id)
	local b = wid("bag_item_" .. item_id)

	e.item = b.item

	if e.user_selection.can_select_point_fn(e, wx, wy, store) then
		e.pos.x, e.pos.y = wx, wy

		game_gui.game.simulation:insert_entity(e)
		b:fire(b.item, x, y, nil)
		game_gui:set_mode(GUI_MODE_IDLE)
		game_gui:show_feedback("ok", x, y, wx, wy)
		signal.emit("item-used", item_id)
	else
		log.error("could not fire item %s at %s,%s", item_id, wx, wy)
	end
end

function game_gui.c_select_point(ctx)
	local store = game_gui.game.store
	local e = game_gui.selected_entity

	if not e then
		log.error("selected entity is nil")

		return false
	end

	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	if not e.user_selection.can_select_point_fn or e.user_selection.can_select_point_fn(e, wx, wy, store) then
		e.user_selection.in_progress = false
		e.user_selection.new_pos = V.v(wx, wy)

		game_gui.c_deselect()
	else
		log.error("could not select point at %s,%s", wx, wy)
	end
end

function game_gui.c_deselect_heros(ctx)
	local hero_portrait = wid("hero_portrait_1")

	if hero_portrait then
		hero_portrait:deselect()
	end

	hero_portrait = wid("hero_portrait_2")

	if hero_portrait then
		hero_portrait:deselect()
	end

	wid("infobar_view"):hide()

	if game_gui.selected_entity_markers then
		for _, m in pairs(game_gui.selected_entity_markers) do
			m.done = true
		end
	end

	game_gui.selected_entity = nil

	game_gui:set_mode(GUI_MODE_IDLE)
end

function game_gui.c_select_hero(ctx, hero_idx)
	if not hero_idx and ctx and wid("hero_portraits_view") then
		for i, h in ipairs(wid("hero_portraits_view").children) do
			if h.hero_id == ctx.hero_id then
				hero_idx = h.hero_idx

				break
			end
		end
	end

	local hero_portrait
	if hero_idx then
		hero_portrait = wid("hero_portrait_" .. hero_idx)
	end

	if hero_portrait and hero_portrait:is_disabled() then
		return false
	end

	local hero_id = hero_portrait and hero_portrait.hero_id or ctx.hero_id

	if not hero_id then
		log.error("could not find hero to select")

		return
	end

	local e = game_gui:entity_by_id(hero_id)

	if not e or not e.ui then
		return
	end

	if not e.ui.can_select then
		log.debug("cannot select hero %s: has ui.can_select == false", e.id)

		return
	end

	if e == game_gui.selected_entity then
		log.debug("cannot select hero %s: is already selected", e.id)

		return
	end

	game_gui.c_deselect(ctx)

	game_gui.selected_entity = e

	if hero_portrait then
		hero_portrait:select()
	end

	if ctx and ctx.from_gamepad then
		ISM.j_pointer_pos.x, ISM.j_pointer_pos.y = game_gui.g2s(game_gui, e.pos)
	end

	local m = E:create_entity("entity_marker_controller")

	m.target = e

	game_gui.game.simulation:insert_entity(m)

	game_gui.selected_entity_markers = {
		m
	}

	wid("infobar_view"):show(e)

	if ISM.last_input == I_KEYBOARD or ISM.last_input == I_GAMEPAD then
		signal.emit("pan-zoom-camera", PAN_TO_ENTITY_TIME, e.pos)
	end

	game_gui:set_mode(GUI_MODE_RALLY_HERO)
end

function game_gui.c_deselect_re(ctx)
	wid("infobar_view"):hide()

	if game_gui.selected_entity_markers then
		for _, m in pairs(game_gui.selected_entity_markers) do
			m.done = true
		end
	end

	game_gui.selected_entity = nil

	game_gui:set_mode(GUI_MODE_IDLE)
end

function game_gui.c_select_re(ctx, e)
	if not e or not e.ui then
		return
	end

	if not e.ui.can_click then
		log.debug("cannot click unit %s: has ui.can_click == false", e.id)

		return
	end

	e.ui.clicked = true

	if not e.ui.can_select then
		log.debug("cannot select unit %s: has ui.can_select == false", e.id)

		return
	end

	if e == game_gui.selected_entity then
		log.debug("cannot select unit %s: is already selected", e.id)

		return
	end

	game_gui.c_deselect(ctx)

	game_gui.selected_entity = e

	local mark_entities

	if e.reinforcement.squad_id then
		mark_entities = table.filter(game.store.entities, function(_, ee)
			return ee.reinforcement and ee.reinforcement.squad_id == e.reinforcement.squad_id
		end)
	else
		mark_entities = {
			e
		}
	end

	game_gui.selected_entity_markers = {}

	for _, ee in pairs(mark_entities) do
		local m = E:create_entity("entity_marker_controller")

		m.target = ee

		game_gui.game.simulation:insert_entity(m)
		table.insert(game_gui.selected_entity_markers, m)
	end

	wid("infobar_view"):show(e)

	if ISM.last_input == I_KEYBOARD or ISM.last_input == I_GAMEPAD then
		signal.emit("pan-zoom-camera", PAN_TO_ENTITY_TIME, e.pos)
	end

	if ctx and ctx.from_gamepad then
		ISM.j_pointer_pos.x, ISM.j_pointer_pos.y = game_gui.g2s(game_gui, e.pos)
	end

	S:queue("GUIQuickMenuOpen")
	game_gui:set_mode(GUI_MODE_RALLY_RE)
end

function game_gui.c_select_next_re(ctx)
	local se = game_gui.selected_entity
	local nse
	local list = table.filter(game.store.entities, function(_, e)
		return e.reinforcement and e.ui and e.ui.can_click and e.ui.can_select and e.nav_grid and e.health and not e.health.dead
	end)

	if #list < 1 then
		return
	end

	if not se or not se.reinforcement then
		nse = list[1]
	else
		table.sort(list, function(o1, o2)
			return (o1.reinforcement.squad_id or o1.id) < (o2.reinforcement.squad_id or o2.id)
		end)

		local se_i, f_i

		for i, e in ipairs(list) do
			local eid = e.reinforcement.squad_id or e.id
			local sid = se.reinforcement.squad_id or se.id

			if not se_i then
				if eid == sid then
					se_i = i
				end
			elseif eid ~= sid then
				f_i = i

				break
			end
		end

		if f_i then
			nse = list[f_i] or list[1]
		end
	end

	if nse and nse ~= se then
		game_gui.c_select_re(ctx, nse)
	else
		game_gui.c_deselect_re(se)
	end
end

function game_gui.c_deselect_tower(ctx)
	local e = game_gui.selected_entity or ctx and ctx.entity

	if not e or not e.tower then
		return
	end

	wid("tower_menu"):hide()
	wid("infobar_view"):hide()

	if game_gui.selected_entity_markers then
		for _, m in pairs(game_gui.selected_entity_markers) do
			m.done = true
		end
	end

	game_gui.selected_entity = nil

	game_gui:set_mode(GUI_MODE_IDLE)
end

function game_gui.c_select_tower(ctx, tower)
	local e = tower or game_gui.last_tower_hover

	if not e or not e.ui then
		return
	end

	if not game_gui.game.store.entities[e.id] then
		log.debug("tower %s is not in entities", e.id)

		return
	end

	if e.ui and e.ui.click_proxies then
		for _, cp in pairs(e.ui.click_proxies) do
			if cp and cp.ui and cp.ui.can_click then
				log.debug("click proxied from (%s)%s to (%s)%s", e.id, e.template_name, cp.id, cp.template_name)

				cp.ui.clicked = true
			end
		end
	end

	if not e.ui.can_click then
		log.debug("cannot click tower %s: has ui.can_click == false", e.id)

		return
	end

	e.ui.clicked = true

	if not e.ui.can_select then
		log.debug("cannot select tower %s: has ui.can_select == false", e.id)

		return
	end

	if e == game_gui.selected_entity then
		log.debug("cannot select tower %s: is already selected", e.id)

		return
	end

	game_gui.c_deselect(ctx)

	game_gui.selected_entity = e
	e.trigger_deselect = nil

	wid("tower_menu"):show(e, ctx.from_gamepad or ctx.from_keys)
	wid("infobar_view"):show(e)

	if ctx and ctx.from_gamepad then
		ISM.j_pointer_pos.x, ISM.j_pointer_pos.y = game_gui:g2s(e.pos)
	end

	if e.barrack then
		local m = E:create_entity("entity_marker_controller")

		m.target = e

		game_gui.game.simulation:insert_entity(m)

		game_gui.selected_entity_markers = {
			m
		}
	end

	game_gui:set_mode(GUI_MODE_TOWER_MENU)
end

function game_gui.c_select_unit(ctx, unit)
	local e = unit or ctx and ctx.entity

	if not e or not e.ui then
		return
	end

	if not e.ui.can_click then
		log.debug("cannot click unit %s: has ui.can_click == false", e.id)

		return
	end

	e.ui.clicked = true

	if not e.ui.can_select then
		log.debug("cannot select unit %s: has ui.can_select == false", e.id)

		return
	end

	if e == game_gui.selected_entity then
		log.debug("cannot select unit %s: is already selected", e.id)

		return
	end

	game_gui.c_deselect(ctx)

	game_gui.selected_entity = e

	if e.enemy or e.soldier then
		local m = E:create_entity("entity_marker_controller")

		m.target = e

		game_gui.game.simulation:insert_entity(m)

		game_gui.selected_entity_markers = {
			m
		}
	end

	wid("infobar_view"):show(e)

	if ISM.last_input == I_KEYBOARD or ISM.last_input == I_GAMEPAD then
		signal.emit("pan-zoom-camera", 1, e.pos)
	end
end

function game_gui.c_click_entity(ctx, entity)
	local e = entity or ctx and ctx.entity

	if not e or not e.ui then
		return
	end

	if not e.ui.can_click then
		log.debug("cannot click entity %s: has ui.can_click == false", e.id)

		return
	end

	e.ui.clicked = true

	if not e.ui.can_select then
		log.debug("cannot select entity %s: has ui.can_select == false", e.id)

		return
	end

	if not ctx.from_gamepad then
		if not e.tower then
			game_gui.c_deselect_tower(ctx)
		end

		if not e.soldier and not e.enemy then
			game_gui.c_deselect(ctx)
		end
	end

	if e.tower then
		return game_gui.c_select_tower(ctx, e)
	elseif e.hero then
		ctx.hero_id = e.id

		return game_gui.c_select_hero(ctx)
	elseif e.reinforcement and e.nav_grid and not IS_MOBILE then
		return game_gui.c_select_re(ctx, e)
	elseif e.soldier or e.enemy then
		return game_gui.c_select_unit(ctx, e)
	elseif e.ui and e.ui.can_click and e.info then
		return game_gui.c_select_unit(ctx, e)
	end
end

function game_gui.c_force_tower_select(ctx, entity)
	local e = entity or ctx and ctx.entity

	game_gui.c_deselect()
	game_gui.c_select_tower(ctx, e)
	game_gui:set_mode(GUI_MODE_TOWER_MENU)
end

function game_gui.c_down_dragable(ctx, entity)
	local e = entity or ctx and ctx.entity

	if not e or not e.ui then
		return
	end

	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	game_gui.pressed_entity = e
	game_gui.pressed_ipos = V.v(wx, wy)
end

function game_gui.c_drag_entity(ctx, entity)
	game_gui.c_deselect()
	game_gui:set_mode(GUI_MODE_DRAG_ENTITY)
end

function game_gui.c_drag_tower(ctx, entity)
	game_gui.c_deselect()

	local t_id = game_gui.pressed_entity.soldier.tower_id
	local t = game_gui.game.store.entities[t_id]

	if t and t.barrack then
		game_gui.selected_entity = t

		game_gui:show_tower_range("rally", t, t.barrack.rally_range)
		game_gui:set_mode(GUI_MODE_DRAG_RALLY_TOWER)
	end
end

function game_gui.c_update_line(ctx)
	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)
	local entity = game_gui.pressed_entity

	game_gui.touch_view:enable_drag_line(entity.pos, V.v(wx, wy), entity)
end

function game_gui.c_move_dragable(ctx)
	game_gui.selected_entity = game_gui.pressed_entity

	local e = game_gui.selected_entity

	if not e then
		log.error("selected entity is nil")
	elseif e.hero and game_gui.q_can_set_hero_rally(ctx) or e.reinforcement and game_gui.q_can_set_re_rally(ctx) or 
	e.tower and game_gui.q_can_set_mobile_tower_rally(ctx) then
		game_gui.c_set_rally(ctx)
	end

	game_gui.selected_entity = nil
	game_gui.pressed_entity = nil

	game_gui:set_mode(GUI_MODE_IDLE)
	game_gui.c_deselect()
end

function game_gui.c_deselect_dragable(ctx)
	game_gui.pressed_entity = nil
	game_gui.pressed_ipos = nil
end

function game_gui.c_set_tower_rally(ctx, entity)
	local e = game_gui.selected_entity

	if not e then
		log.error("selected_entity is nil")

		return false
	end

	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	log.debug("entity barrack.rally_pos to %s", e.barrack.rally_pos)
	S:queue("GUIPlaceRallyPoint")

	e.barrack.rally_pos = V.v(wx, wy)
	e.barrack.rally_new = true

	game_gui:show_feedback("rally", x, y, wx, wy)
	game_gui.c_deselect()

	return true
end

function game_gui.c_set_tower_rally_drag(ctx, entity)
	local e = game_gui.selected_entity

	if not e then
		log.error("selected_entity is nil")

		return false
	end

	local b = e.barrack

	if not b then
		log.error("tower %s is not a barrack", e.id)

		return false
	end

	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return false
	end

	local target_pos = V.v(wx, wy)
	local o = V.v(e.barrack.rally_pos.x, e.barrack.rally_pos.y)
	local rc = V.v(V.add(e.pos.x, e.pos.y, e.tower.range_offset.x, e.tower.range_offset.y))
	local len = V.len(wx - o.x, wy - o.y)
	local dir_x, dir_y = (wx - o.x) / len, (wy - o.y) / len
	local dir_size = 0
	local last_valid_size = 0

	::label_216_0::

	while dir_size < len do
		dir_size = dir_size + 3

		local ray = V.v(o.x + dir_x * dir_size, o.y + dir_y * dir_size)

		if not U.is_inside_ellipse(ray, rc, b.rally_range) then
			if last_valid_size > 0 then
				break
			else
				goto label_216_0
			end
		end

		if b.rally_anywhere or P:valid_node_nearby(ray.x, ray.y, nil, NF_RALLY) and GR:cell_is_only(ray.x, ray.y, b.rally_terrains) then
			last_valid_size = dir_size
		end
	end

	target_pos.x = e.barrack.rally_pos.x + dir_x * last_valid_size
	target_pos.y = e.barrack.rally_pos.y + dir_y * last_valid_size

	if b.rally_anywhere or P:valid_node_nearby(target_pos.x, target_pos.y, nil, NF_RALLY) and GR:cell_is_only(target_pos.x, target_pos.y, b.rally_terrains) then
		log.debug("entity barrack.rally_pos to %s", e.barrack.rally_pos)
		S:queue("GUIPlaceRallyPoint")

		if last_valid_size > 0 then
			e.barrack.rally_pos = V.v(target_pos.x, target_pos.y)
			e.barrack.rally_new = true
		end

		game_gui:show_feedback("rally", x, y, target_pos.x, target_pos.y)
	else
		game_gui:show_feedback("error", x, y, wx, wy)
	end

	game_gui.c_deselect()

	game_gui.pressed_entity = nil
	game_gui.pressed_ipos = nil

	game_gui:set_mode(GUI_MODE_IDLE)

	return true
end

function game_gui.c_swap_tower(ctx)
	local e = ctx.entity or game_gui.last_tower_hover

	if not e or not e.ui then
		return
	end

	if not game_gui.game.store.entities[e.id] then
		log.debug("tower %s is not in entities", e.id)

		return
	end

	if e.ui and e.ui.click_proxies then
		for _, cp in pairs(e.ui.click_proxies) do
			if cp and cp.ui and cp.ui.can_click then
				log.debug("click proxied from (%s)%s to (%s)%s", e.id, e.template_name, cp.id, cp.template_name)

				cp.ui.clicked = true
			end
		end
	end

	if not e.ui.can_click then
		log.debug("cannot click tower %s: has ui.can_click == false", e.id)

		return
	end

	e.ui.clicked = true

	if not e.ui.can_select then
		log.debug("cannot select tower %s: has ui.can_select == false", e.id)

		return
	end

	if e == game_gui.selected_entity then
		log.debug("cannot select tower %s: is already selected", e.id)

		return
	end

	local tower_selected = game_gui.swap_entity

	game_gui.c_deselect(ctx)

	local controller = E:create_entity("controller_tower_swap")

	controller.tower_1 = game_gui.swap_entity
	controller.tower_2 = e

	game_gui.game.simulation:insert_entity(controller)

	game_gui.swap_entity = nil

	game_gui:set_mode(GUI_MODE_IDLE)
	game_gui:hide_ghost_hover()
end

function game_gui.c_combine_tower(ctx)
	local e = ctx.entity or game_gui.last_tower_hover

	if not e or not e.ui then
		return
	end

	if not game_gui.game.store.entities[e.id] then
		log.debug("tower %s is not in entities", e.id)

		return
	end

	if e.ui and e.ui.click_proxies then
		for _, cp in pairs(e.ui.click_proxies) do
			if cp and cp.ui and cp.ui.can_click then
				log.debug("click proxied from (%s)%s to (%s)%s", e.id, e.template_name, cp.id, cp.template_name)

				cp.ui.clicked = true
			end
		end
	end

	if not e.ui.can_click then
		log.debug("cannot click tower %s: has ui.can_click == false", e.id)

		return
	end

	e.ui.clicked = true

	if not e.ui.can_select then
		log.debug("cannot select tower %s: has ui.can_select == false", e.id)

		return
	end

	if e == game_gui.selected_entity then
		log.debug("cannot select tower %s: is already selected", e.id)

		return
	end

	game_gui.c_deselect(ctx)

	local controller = E:create_entity(game_gui.swap_entity.tower_combination_controller)
	controller.tower_1 = game_gui.swap_entity
	controller.tower_2 = e
	game_gui.game.simulation:insert_entity(controller)
	game_gui.swap_entity = nil
	game_gui:set_mode(GUI_MODE_IDLE)
	game_gui:hide_decal_preview()
end

function game_gui.c_set_rally(ctx)
	local function set_rally(e, wx, wy, move_order, waypoints)
		local offset_x = e.nav_rally.pos.x - e.nav_rally.center.x
		local offset_y = e.nav_rally.pos.y - e.nav_rally.center.y

		e.nav_rally.new = true
		e.nav_rally.pos = V.v(offset_x + wx, offset_y + wy)
		e.nav_rally.center = V.v(wx, wy)
		e.nav_rally.move_order = move_order

		if not e.nav_grid.ignore_waypoints and waypoints and #waypoints > 0 then
			e.nav_grid.waypoints = table.deepclone(waypoints)

			if offset_x ~= 0 or offset_y ~= 0 then
				local lw = e.nav_grid.waypoints[#e.nav_grid.waypoints]

				if lw then
					lw.x = lw.x + offset_x
					lw.y = lw.y + offset_y
				end
			end
		end
	end

	local e = game_gui.selected_entity

	if not e then
		log.error("selected_entity is nil")

		return
	end

	local x, y, wx, wy = game_gui.get_pos_from_ctx(ctx)

	if not wx then
		return
	end

	if ctx.rally_point_snap then
		wx = ctx.rally_point_snap.wx
		wy = ctx.rally_point_snap.wy
		ctx.rally_point_snap = nil
	end

	if e.reinforcement and e.reinforcement.squad_id and e.nav_rally then
		local move_order = 0

		for _, es in pairs(game_gui.game.store.entities) do
			if es.reinforcement and es.reinforcement.squad_id == e.reinforcement.squad_id then
				set_rally(es, wx, wy, move_order, ctx.cached_waypoints)

				move_order = move_order + 1
			end
		end
	else
		set_rally(e, wx, wy, 0, ctx.cached_waypoints)
	end

	ctx.cached_waypoints = nil

	game_gui:show_feedback("ok", x, y, wx, wy)
	game_gui.c_deselect()
end

function game_gui.c_hover_next(ctx)
	local stepx, stepy

	if ctx.key then
		stepx, stepy = ISM.get_dir_step(ctx.key)
		stepy = stepy * -1
	else
		stepx, stepy = ctx.axis_value[1], ctx.axis_value[2] * ISM.joy_y_axis_factor
	end

	local idir = ISM.get_dir_idx(stepx, stepy)
	local t, t_hid
	local le = game_gui.last_tower_hover

	if le and le.ui and le.ui.nav_mesh_id then
		local lt_hid = tonumber(le.ui.nav_mesh_id)
		local next_entities = game.store.level.nav_mesh[lt_hid]

		if not next_entities then
			log.error("nav mesh missing for tower holder id %s", lt_hid)

			return
		else
			t_hid = next_entities[idir]
		end
	else
		local entities = {}

		for _, e in pairs(game_gui.game.store.entities) do
			if e.ui and e.ui.nav_mesh_id and e.ui.can_click and (not e.tower or e.tower.can_hover) then
				table.insert(entities, e)
			end
		end

		table.sort(entities, function(e1, e2)
			if idir == 1 then
				return e1.pos.x > e2.pos.x
			elseif idir == 2 then
				return e1.pos.y > e2.pos.y
			elseif idir == 3 then
				return e1.pos.x < e2.pos.x
			elseif idir == 4 then
				return e1.pos.y < e2.pos.y
			end
		end)

		if #entities < 1 then
			log.error("no towers can be hovered.")

			return
		end

		t_hid = tonumber(entities[1].ui.nav_mesh_id)
	end

	if t_hid then
		for _, e in pairs(game_gui.game.store.entities) do
			if e.ui and e.ui.nav_mesh_id and tonumber(e.ui.nav_mesh_id) == t_hid then
				t = e

				break
			end
		end
	end

	if t and t ~= game_gui.last_tower_hover and (not t.tower or t.tower.can_hover) then
		game_gui:show_clickable_hover(t)

		ISM.j_pointer_pos.x, ISM.j_pointer_pos.y = game_gui:g2s(t.pos)

		if ISM.last_input == I_KEYBOARD or ISM.last_input == I_GAMEPAD then
			signal.emit("pan-zoom-camera", 1, t.pos)
		end
	end
end

function game_gui.c_send_wave(ctx)
	game_gui.c_deselect()

	if game_gui.game.store.next_wave_group_ready ~= nil then
		game_gui.game.store.send_next_wave = true
	end
end

function game_gui.c_select_hero_custom(ctx)
	local list = LU.list_entities(game_gui.game.store.entities, "hero_durax_clone")

	if not list or #list < 1 then
		return false
	end

	table.sort(list, function(e1, e2)
		return e1.id < e2.id
	end)

	local sel_idx

	for i, e in ipairs(list) do
		if e == game_gui.selected_entity then
			sel_idx = i

			break
		end
	end

	game_gui.c_deselect()

	local next_idx = sel_idx or game_gui._last_hero_3_idx or 0

	for i = 1, #list do
		next_idx = km.zmod(next_idx + 1, #list)

		local e = list[next_idx]

		if e and e.ui and e.ui.can_click then
			game_gui._last_hero_3_idx = next_idx
			e.ui.clicked = true
			ctx.hero_id = e.id

			game_gui.c_select_hero(ctx)

			break
		end
	end
end

function game_gui.c_go_to_map(ctx, show)
	S:stop_all()
	S:stop("GUIWinStars")
	S:resume()

	if game_gui.game.store.hero_team and not GS.hero_xp_ephemeral then
		local slot = storage:load_slot()

		for _, hero in ipairs(game_gui.game.store.hero_team) do
			local hn = hero.template_name

			slot.heroes.status[hero.template_name].xp = hero.hero.xp
		end

		storage:save_slot(slot)
	elseif game_gui.game.store.main_hero and not GS.hero_xp_ephemeral then
		local hero = game_gui.game.store.main_hero
		local slot = storage:load_slot()

		slot.heroes.status[hero.template_name].xp = hero.hero.xp

		storage:save_slot(slot)
	end

	local settings = storage:load_settings()

	storage:save_settings(settings, true)
	signal.emit("game-quit", game_gui.game.store)
	timer:script(function(wait)
		wait(0.1)
		game_gui.game.done_callback({
			next_item_name = "map",
			show = show
		})
	end)
end

function game_gui.c_restart_game()
	S:stop_all()
	S:stop("GUIWinStars")
	S:resume()

	if game_gui.game.store.hero_team and not GS.hero_xp_ephemeral then
		local slot = storage:load_slot()

		for _, hero in ipairs(game_gui.game.store.hero_team) do
			local hn = hero.template_name

			slot.heroes.status[hero.template_name].xp = hero.hero.xp
		end

		storage:save_slot(slot)
	elseif game_gui.game.store.main_hero and not GS.hero_xp_ephemeral then
		local hero = game_gui.game.store.main_hero
		local slot = storage:load_slot()

		slot.heroes.status[hero.template_name].xp = hero.hero.xp

		storage:save_slot(slot)
	end

	if IS_KR3 then
		game_gui.game.store.hand_of_midas_factor = nil
	end

	signal.emit("game-restart", game_gui.game.store)
	game_gui.game:restart()
end

function game_gui.c_show_ingame_shop(ctx, previous_gui_mode)
	S:pause()
	game_gui.c_deselect()
	game_gui:hide_gui_hud()

	game_gui.game.store.paused = true

	game_gui.window:focus_view()
	game_gui:set_mode(GUI_MODE_SHOP_INGAME)

	wid("popup_ingame_shop_container").hidden = false
end

function game_gui.c_hide_ingame_shop(ctx)
	wid("popup_ingame_shop_container").hidden = true

	S:resume()

	local curtain = wid("curtain_top_view")

	if not curtain.hidden then
		game_gui:show_balloons(true)
	else
		game_gui:show_gui_hud()
	end

	game_gui.game.store.paused = false

	for _, c in pairs(wid("bag_view").children) do
		if c:isInstanceOf(BagItemButton) then
			c:refresh()
		end
	end

	game_gui:set_mode(GUI_MODE_IDLE)
end

function game_gui.c_show_ingame_shop_gems(ctx)
	wid("popup_ingame_shop_item").hidden = true

	wid("popup_ingame_shop_gems"):show()

	wid("popup_ingame_shop_container"):ci("button_item_room_buy_gems").hidden = true
end

local g = game_gui

g.ism_data = {
	FIRST = {
		{
			"escape",
			ISM.q_is_view_visible,
			{
				"no_joystick_view"
			}
		}
	},
	LAST = {},
	[GUI_MODE_DISABLED] = {},
	[GUI_MODE_TUTORIAL_LOCK] = {
		{
			"escape",
			true,
			[4] = g.c_pause,
			[5] = {
				GUI_MODE_TUTORIAL_LOCK
			}
		},
		{
			"jstart",
			"escape"
		}
	},
	[GUI_MODE_CINEMATIC_LOCK] = {
		{
			"escape",
			true,
			[4] = g.c_pause,
			[5] = {
				GUI_MODE_CINEMATIC_LOCK
			}
		},
		{
			"jstart",
			"escape"
		}
	},
	[GUI_MODE_IDLE] = {
		{
			"escape",
			true,
			[4] = g.c_pause
		},
		{
			"return",
			true,
			[4] = g.c_select_tower
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"up",
			true,
			[4] = g.c_hover_next
		},
		{
			"down",
			true,
			[4] = g.c_hover_next
		},
		{
			"left",
			true,
			[4] = g.c_hover_next
		},
		{
			"right",
			true,
			[4] = g.c_hover_next
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			".",
			true,
			[4] = g.c_change_mode,
			[5] = {
				GUI_MODE_POINTER
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			"escape"
		},
		{
			"jback",
			"r"
		},
		{
			"jdpright",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"jdpup",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"jdpleft",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"ja",
			g.q_can_click_tower,
			[4] = g.c_select_tower
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"jleftxy",
			ISM.q_rate_limit,
			[4] = g.c_hover_next
		},
		{
			"jleftstick",
			"."
		},
		{
			"click1",
			g.q_can_click_entity,
			[4] = g.c_click_entity
		},
		{
			"click1",
			true,
			[4] = g.c_deselect
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_move",
			g.q_selected_drag_tower,
			[4] = g.c_drag_tower
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	},
	[GUI_MODE_PAUSE] = {
		{
			"escape",
			true,
			[4] = g.c_resume
		},
		{
			"return",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"return"
			}
		},
		{
			"up",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"up"
			}
		},
		{
			"down",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"down"
			}
		},
		{
			"left",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"left"
			}
		},
		{
			"right",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"right"
			}
		},
		{
			"pageup",
			true,
			[4] = ISM.c_call_view_fn,
			[5] = {
				"popup_ingame_options",
				"change_page",
				"prev"
			}
		},
		{
			"pagedown",
			true,
			[4] = ISM.c_call_view_fn,
			[5] = {
				"popup_ingame_options",
				"change_page",
				"next"
			}
		},
		{
			"jstart",
			"escape"
		},
		{
			"jleftxy",
			ISM.q_rate_limit,
			[4] = ISM.c_send_key_axis
		},
		{
			"ja",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"return"
			}
		},
		{
			"jb",
			"escape"
		},
		{
			"jleftshoulder",
			"pageup"
		},
		{
			"jrightshoulder",
			"pagedown"
		},
		{
			"jdpright",
			"right"
		},
		{
			"jdpup",
			"up"
		},
		{
			"jdpleft",
			"left"
		},
		{
			"jdpdown",
			"down"
		}
	},
	[GUI_MODE_SHOP_INGAME] = {
		{
			"escape",
			true,
			[4] = g.c_hide_ingame_shop
		},
		{
			"return",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"return"
			}
		},
		{
			"up",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"up"
			}
		},
		{
			"down",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"down"
			}
		},
		{
			"left",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"left"
			}
		},
		{
			"right",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"right"
			}
		},
		{
			"jstart",
			"escape"
		},
		{
			"jleftxy",
			ISM.q_rate_limit,
			[4] = ISM.c_send_key_axis
		},
		{
			"ja",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"return"
			}
		},
		{
			"jb",
			"escape"
		},
		{
			"jleftshoulder",
			"pageup"
		},
		{
			"jrightshoulder",
			"pagedown"
		},
		{
			"jdpright",
			"right"
		},
		{
			"jdpup",
			"up"
		},
		{
			"jdpleft",
			"left"
		},
		{
			"jdpdown",
			"down"
		}
	},
	[GUI_MODE_WAVE_FLAG] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"return"
			}
		},
		{
			"e",
			"escape"
		},
		{
			"w",
			"return"
		},
		{
			"up",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"up"
			}
		},
		{
			"down",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"down"
			}
		},
		{
			"left",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"left"
			}
		},
		{
			"right",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"right"
			}
		},
		{
			"jleftxy",
			ISM.q_rate_limit,
			[4] = ISM.c_send_key_axis
		},
		{
			"ja",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"return"
			}
		},
		{
			"jb",
			"escape"
		},
		{
			"jx",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"return"
			}
		},
		{
			"jy",
			"escape"
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jdpleft",
			"1"
		},
		{
			"jdpup",
			"2"
		},
		{
			"jdpright",
			"3"
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"click1",
			g.q_can_click_entity,
			[4] = g.c_click_entity
		},
		{
			"click1",
			true,
			[4] = g.c_deselect
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_move",
			g.q_selected_drag_tower,
			[4] = g.c_drag_tower
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	},
	[GUI_MODE_FINISHED] = {
		{
			"escape",
			true,
			[4] = g.c_go_to_map
		},
		{
			"return",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"return"
			}
		},
		{
			"up",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"up"
			}
		},
		{
			"down",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"down"
			}
		},
		{
			"left",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"left"
			}
		},
		{
			"right",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"right"
			}
		},
		{
			"jleftxy",
			ISM.q_rate_limit,
			[4] = ISM.c_send_key_axis
		},
		{
			"ja",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"return"
			}
		},
		{
			"jb",
			"escape"
		},
		{
			"jdpright",
			"right"
		},
		{
			"jdpup",
			"up"
		},
		{
			"jdpleft",
			"left"
		},
		{
			"jdpdown",
			"down"
		}
	},
	[GUI_MODE_NOTIFICATION] = {
		{
			"escape",
			true,
			[4] = g.c_hide_noti
		},
		{
			"return",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"return"
			}
		},
		{
			"left",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"left"
			}
		},
		{
			"right",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"right"
			}
		},
		{
			"jleftxy",
			ISM.q_rate_limit,
			[4] = ISM.c_send_key_axis
		},
		{
			"ja",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"return"
			}
		},
		{
			"jb",
			"escape"
		},
		{
			"jdpright",
			"right"
		},
		{
			"jdpleft",
			"left"
		}
	},
	[GUI_MODE_TOWER_MENU] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"return"
			}
		},
		{
			"up",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"up"
			}
		},
		{
			"down",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"down"
			}
		},
		{
			"left",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"left"
			}
		},
		{
			"right",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"right"
			}
		},
		{
			"ja",
			true,
			[4] = ISM.c_send_key,
			[5] = {
				"return"
			}
		},
		{
			"jb",
			"escape"
		},
		{
			"jleftxy",
			ISM.q_rate_limit,
			[4] = ISM.c_send_key_axis
		},
		{
			"click1",
			g.q_can_click_entity,
			[4] = g.c_click_entity
		},
		{
			"click1",
			true,
			[4] = g.c_deselect
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"jdpright",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"jdpup",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"jdpleft",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_move",
			g.q_selected_drag_tower,
			[4] = g.c_drag_tower
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	},
	[GUI_MODE_RALLY_TOWER] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			g.q_can_set_tower_rally,
			[4] = g.c_set_tower_rally
		},
		{
			"up",
			g.q_move_pointer,
			{
				"rally"
			}
		},
		{
			"down",
			g.q_move_pointer,
			{
				"rally"
			}
		},
		{
			"left",
			g.q_move_pointer,
			{
				"rally"
			}
		},
		{
			"right",
			g.q_move_pointer,
			{
				"rally"
			}
		},
		{
			"ja",
			g.q_can_set_tower_rally,
			[4] = g.c_set_tower_rally
		},
		{
			"jb",
			"escape"
		},
		{
			"jleftxy",
			g.q_move_pointer,
			{
				"rally"
			}
		},
		{
			"click1",
			g.q_can_set_tower_rally,
			[4] = g.c_set_tower_rally
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"jdpleft",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"jdpup",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"jdpright",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_move",
			g.q_selected_drag_tower,
			[4] = g.c_drag_tower
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	},
	[GUI_MODE_POWER_1] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			g.q_can_fire_power,
			{
				1
			},
			g.c_fire_power,
			{
				1
			}
		},
		{
			"up",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"down",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"left",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"right",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"jleftxy",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"ja",
			"return"
		},
		{
			"jb",
			"escape"
		},
		{
			"click1",
			"return"
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"1",
			"escape"
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"jdpleft",
			"escape"
		},
		{
			"jdpright",
			"3"
		},
		{
			"jdpup",
			"2"
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_move",
			g.q_selected_drag_tower,
			[4] = g.c_drag_tower
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	},
	[GUI_MODE_POWER_2] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			g.q_can_fire_power,
			{
				2
			},
			g.c_fire_power,
			{
				2
			}
		},
		{
			"up",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"down",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"left",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"right",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"ja",
			"return"
		},
		{
			"jb",
			"escape"
		},
		{
			"jleftxy",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"click1",
			"return"
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			"escape"
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"jdpleft",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"jdpup",
			"escape"
		},
		{
			"jdpright",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_move",
			g.q_selected_drag_tower,
			[4] = g.c_drag_tower
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	},
	[GUI_MODE_POWER_3] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			g.q_can_fire_power,
			{
				3
			},
			g.c_fire_power,
			{
				3
			}
		},
		{
			"up",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"down",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"left",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"right",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"ja",
			"return"
		},
		{
			"jb",
			"escape"
		},
		{
			"jleftxy",
			g.q_move_pointer,
			{
				"power"
			}
		},
		{
			"click1",
			"return"
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			"escape"
		},
		{
			"4",
			"space"
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"jdpleft",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"jdpup",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"jdpright",
			"escape"
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_move",
			g.q_selected_drag_tower,
			[4] = g.c_drag_tower
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	},
	[GUI_MODE_RALLY_HERO] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			g.q_can_set_hero_rally,
			[4] = g.c_set_rally
		},
		{
			"space",
			g.q_matches_hero_states,
			{
				"s",
				"a"
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"space",
			g.q_matches_hero_states,
			{
				"s",
				"i"
			},
			g.c_deselect
		},
		{
			"space",
			g.q_matches_hero_states,
			{
				"x",
				"s"
			},
			g.c_deselect
		},
		{
			"up",
			g.q_move_pointer,
			{
				"hero_rally"
			}
		},
		{
			"down",
			g.q_move_pointer,
			{
				"hero_rally"
			}
		},
		{
			"left",
			g.q_move_pointer,
			{
				"hero_rally"
			}
		},
		{
			"right",
			g.q_move_pointer,
			{
				"hero_rally"
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_selected,
			{
				1
			},
			g.c_deselect
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_selected,
			{
				2
			},
			g.c_deselect
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"ja",
			"return"
		},
		{
			"jb",
			"escape"
		},
		{
			"jdpleft",
			"1"
		},
		{
			"jdpup",
			"2"
		},
		{
			"jdpright",
			"3"
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_can_set_hero_rally,
			{
				1
			},
			g.c_set_rally
		},
		{
			"jrightshoulder",
			g.q_can_set_hero_rally,
			{
				2
			},
			g.c_set_rally
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"jleftxy",
			g.q_move_pointer,
			{
				"hero_rally"
			}
		},
		{
			"click1",
			"return"
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	},
	[GUI_MODE_RALLY_RE] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			g.q_can_set_re_rally,
			[4] = g.c_set_rally
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"up",
			g.q_move_pointer,
			{
				"rally"
			}
		},
		{
			"down",
			g.q_move_pointer,
			{
				"rally"
			}
		},
		{
			"left",
			g.q_move_pointer,
			{
				"rally"
			}
		},
		{
			"right",
			g.q_move_pointer,
			{
				"rally"
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_re_selected,
			[4] = g.c_select_next_re
		},
		{
			"ja",
			"return"
		},
		{
			"jb",
			"escape"
		},
		{
			"jdpleft",
			"1"
		},
		{
			"jdpup",
			"2"
		},
		{
			"jdpright",
			"3"
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"jleftxy",
			g.q_move_pointer,
			{
				"rally"
			}
		},
		{
			"click1",
			"return"
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	},
	[GUI_MODE_SELECT_POINT] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			g.q_can_select_point,
			[4] = g.c_select_point
		},
		{
			"up",
			g.q_move_pointer,
			{
				"point"
			}
		},
		{
			"down",
			g.q_move_pointer,
			{
				"point"
			}
		},
		{
			"left",
			g.q_move_pointer,
			{
				"point"
			}
		},
		{
			"right",
			g.q_move_pointer,
			{
				"point"
			}
		},
		{
			"ja",
			"return"
		},
		{
			"jb",
			"escape"
		},
		{
			"jleftxy",
			g.q_move_pointer,
			{
				"point"
			}
		},
		{
			"click1",
			"return"
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"jdpleft",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"jdpup",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"jdpright",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		}
	},
	[GUI_MODE_POINTER] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			g.q_can_click_entity,
			[4] = g.c_click_entity
		},
		{
			"up",
			g.q_move_pointer,
			{
				"pointer"
			}
		},
		{
			"down",
			g.q_move_pointer,
			{
				"pointer"
			}
		},
		{
			"left",
			g.q_move_pointer,
			{
				"pointer"
			}
		},
		{
			"right",
			g.q_move_pointer,
			{
				"pointer"
			}
		},
		{
			"ja",
			g.q_can_click_entity,
			[4] = g.c_click_entity
		},
		{
			"jb",
			"escape"
		},
		{
			"jleftxy",
			g.q_move_pointer,
			{
				"pointer"
			}
		},
		{
			"jleftstick",
			"escape"
		},
		{
			"click1",
			g.q_can_click_entity,
			[4] = g.c_click_entity
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"jdpleft",
			"1"
		},
		{
			"jdpup",
			"2"
		},
		{
			"jdpright",
			"3"
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		}
	},
	[GUI_MODE_ITEM_1] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			g.q_can_fire_item,
			{
				1
			},
			g.c_fire_item,
			{
				1
			}
		},
		{
			"up",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"down",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"left",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"right",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"ja",
			"return"
		},
		{
			"jb",
			"escape"
		},
		{
			"jleftxy",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"click1",
			"return"
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"1",
			"escape"
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"jdpleft",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"jdpup",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"jdpright",
			"escape"
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_move",
			g.q_selected_drag_tower,
			[4] = g.c_drag_tower
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	},
	[GUI_MODE_ITEM_2] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			g.q_can_fire_item,
			{
				2
			},
			g.c_fire_item,
			{
				2
			}
		},
		{
			"up",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"down",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"left",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"right",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"ja",
			"return"
		},
		{
			"jb",
			"escape"
		},
		{
			"jleftxy",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"click1",
			"return"
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			"escape"
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"jdpleft",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"jdpup",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"jdpright",
			"escape"
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_move",
			g.q_selected_drag_tower,
			[4] = g.c_drag_tower
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	},
	[GUI_MODE_ITEM_3] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			g.q_can_fire_item,
			{
				3
			},
			g.c_fire_item,
			{
				3
			}
		},
		{
			"up",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"down",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"left",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"right",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"ja",
			"return"
		},
		{
			"jb",
			"escape"
		},
		{
			"jleftxy",
			g.q_move_pointer,
			{
				"item"
			}
		},
		{
			"click1",
			"return"
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			"escape"
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"jdpleft",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"jdpup",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"jdpright",
			"escape"
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_move",
			g.q_selected_drag_tower,
			[4] = g.c_drag_tower
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	},
	[GUI_MODE_DRAG_ENTITY] = {
		{
			"touch_up",
			true,
			[4] = g.c_move_dragable
		},
		{
			"touch_move",
			true,
			[4] = g.c_update_line
		}
	},
	[GUI_MODE_DRAG_RALLY_TOWER] = {
		{
			"touch_up",
			true,
			[4] = g.c_set_tower_rally_drag
		},
		{
			"touch_move",
			true,
			[4] = g.c_update_line
		}
	},
	[GUI_MODE_SWAP_TOWER] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			g.q_selected_swappable_tower,
			[4] = g.c_swap_tower
		},
		{
			"up",
			true,
			[4] = g.c_hover_next
		},
		{
			"down",
			true,
			[4] = g.c_hover_next
		},
		{
			"left",
			true,
			[4] = g.c_hover_next
		},
		{
			"right",
			true,
			[4] = g.c_hover_next
		},
		{
			"ja",
			g.q_selected_swappable_tower,
			[4] = g.c_swap_tower
		},
		{
			"jb",
			"escape"
		},
		{
			"jleftxy",
			ISM.q_rate_limit,
			[4] = g.c_hover_next
		},
		{
			"click1",
			g.q_selected_swappable_tower,
			[4] = g.c_swap_tower
		},
		{
			"click1",
			true,
			[4] = g.c_deselect
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"jdpleft",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"jdpup",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"jdpright",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_move",
			g.q_selected_drag_tower,
			[4] = g.c_drag_tower
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	},
	[GUI_MODE_TOWER_COMBINATION] = {
		{
			"escape",
			true,
			[4] = g.c_deselect
		},
		{
			"return",
			g.q_selected_combined_tower,
			[4] = g.c_combine_tower
		},
		{
			"up",
			true,
			[4] = g.c_hover_next
		},
		{
			"down",
			true,
			[4] = g.c_hover_next
		},
		{
			"left",
			true,
			[4] = g.c_hover_next
		},
		{
			"right",
			true,
			[4] = g.c_hover_next
		},
		{
			"ja",
			g.q_selected_combined_tower,
			[4] = g.c_combine_tower
		},
		{
			"jb",
			"escape"
		},
		{
			"jleftxy",
			ISM.q_rate_limit,
			[4] = g.c_hover_next
		},
		{
			"click1",
			g.q_selected_combined_tower,
			[4] = g.c_combine_tower
		},
		{
			"click1",
			true,
			[4] = g.c_deselect
		},
		{
			"e",
			g.q_is_wave_ready,
			[4] = g.c_select_wave_flags
		},
		{
			"w",
			g.q_is_wave_ready,
			[4] = g.c_send_wave
		},
		{
			"r",
			g.q_has_noti_queued,
			[4] = g.c_show_noti_queued
		},
		{
			"space",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"space",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"1",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"2",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"3",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"4",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"5",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"6",
			g.q_is_hero_custom_active,
			[4] = g.c_select_hero_custom
		},
		{
			"6",
			g.q_is_re_active,
			[4] = g.c_select_next_re
		},
		{
			"jstart",
			true,
			[4] = g.c_pause
		},
		{
			"jback",
			"r"
		},
		{
			"jx",
			"w"
		},
		{
			"jy",
			"e"
		},
		{
			"jdpleft",
			g.q_is_power_active,
			{
				1
			},
			g.c_select_power,
			{
				1
			}
		},
		{
			"jdpup",
			g.q_is_power_active,
			{
				2
			},
			g.c_select_power,
			{
				2
			}
		},
		{
			"jdpright",
			g.q_is_power_active,
			{
				3
			},
			g.c_select_power,
			{
				3
			}
		},
		{
			"jdpdown",
			"6"
		},
		{
			"jleftshoulder",
			g.q_is_hero_active,
			{
				1
			},
			g.c_select_hero,
			{
				1
			}
		},
		{
			"jrightshoulder",
			g.q_is_hero_active,
			{
				2
			},
			g.c_select_hero,
			{
				2
			}
		},
		{
			"touch_down",
			g.q_can_drag_entity,
			[4] = g.c_down_dragable
		},
		{
			"touch_move",
			g.q_selected_drag_entity,
			[4] = g.c_drag_entity
		},
		{
			"touch_move",
			g.q_selected_drag_tower,
			[4] = g.c_drag_tower
		},
		{
			"touch_up",
			true,
			[4] = g.c_deselect_dragable
		}
	}
}
TouchView = class("TouchView", KView)

function TouchView:initialize(size)
	KView.initialize(self, size)

	self.touch_fingers = {}
	self.mousestate = {}
	self.inertia_idx = 1
	self.inertia_deltas = {}
	self.multitouch = false

	for i = 1, 6 do
		self.inertia_deltas[i] = V.v()
		self.inertia_deltas[i].ts = 0
	end

	self.inertia_last_pos = V.v()
	self.inertia_duration = 1
	self.inertia_factor = 0.9
	self.inertia_dt = 1 / FPS
	self.pan_damping = 0.8
	self.pan_start_threshold = 30
	self.path_direction = E:create_entity("controller_path_direction")

	game_gui.game.simulation:insert_entity(self.path_direction)
end

function TouchView:on_scroll(button, x, y, istouch)
	local function s2w(s)
		local px = (s.x - game_gui.sw / 2) * game_gui.gui_scale / game.camera.zoom + game.camera.x
		local py = (s.y - game_gui.sh / 2) * game_gui.gui_scale / game.camera.zoom + game.camera.y

		return px, py
	end

	if game.camera and not istouch then
		local delta = V.v(game_gui.sw / 2 - x, game_gui.sh / 2 - y)
		local zoom = game.camera.zoom

		if button == "wd" then
			zoom = zoom * 0.9
		elseif button == "wu" then
			zoom = zoom * 1.1
		end

		zoom = km.clamp(game.camera.min_zoom_clamp, game.camera.max_zoom, zoom)

		local wmx, wmy = s2w(V.v(x, y))

		game.camera.x = wmx
		game.camera.y = wmy
		game.camera.zoom = zoom

		local wdx, wdy = s2w(V.v(delta.x + game_gui.sw / 2, delta.y + game_gui.sh / 2))

		game.camera.x = wdx
		game.camera.y = wdy

		game.camera:clamp()
	end
end

function TouchView:on_down(button, x, y, istouch)
	log.paranoid("button:%s istouch:%s", button, istouch)

	if button == 2 then
		local wx, wy = game_gui:u2w(V.v(x, y))

		if DEBUG_RIGHT_CLICK then
			DEBUG_RIGHT_CLICK(wx, wy)
		end
	elseif game.camera and not istouch then
		self.mousestate[button] = true

		self:on_touch_down("mouse", x, y)
	end

	if not istouch then
		self._on_down_ts = self:get_window().ts
	end
end

function TouchView:on_up(button, x, y, drag_view, istouch)
	log.paranoid("button:%s istouch:%s", button, istouch)

	if game.camera and not istouch then
		self.mousestate[button] = nil

		if game_gui.mode == GUI_MODE_DRAG_ENTITY or game_gui.mode == GUI_MODE_DRAG_RALLY_TOWER then
			self.ignore_next_click = true
		end

		self:on_touch_up("mouse", x, y)
		self:enable(false)
	end
end

function TouchView:on_click(button, x, y, istouch, moved)
	log.paranoid("button:%s istouch:%s moved:%s panning:%s", button, istouch, moved, self.panning)

	if self.ignore_next_click then
		log.debug("ignoring this click on TouchView")

		self.ignore_next_click = nil

		return
	end

	local is_quick_click

	if not istouch and button == 1 and self._on_down_ts then
		local click_time = self:get_window().ts - self._on_down_ts

		is_quick_click = not is_touch and self._on_down_ts and click_time < QUICK_CLICK_TIME
		self._on_down_ts = nil
	end

	if button == 1 and (not self.panning or is_quick_click) and not self.zooming and not self.selected_on_down then
		ISM:proc_click(game_gui.mode, button, game_gui:u2s(V.v(x, y)))
	end

	self.selected_on_down = nil
end

function TouchView:update(dt)
	local function s2w(s)
		local px = (s.x - game_gui.sw / 2) * game_gui.gui_scale / game.camera.zoom + game.camera.x
		local py = (s.y - game_gui.sh / 2) * game_gui.gui_scale / game.camera.zoom + game.camera.y

		return px, py
	end

	self.inertia_dt = dt

	if self.mousestate[1] then
		local x, y = game_gui.window:get_mouse_position()

		x, y = game_gui.window:screen_to_view(x, y)

		if game.camera then
			self:on_touch_move("mouse", x, y)
		end
	elseif game.camera.tweener then
		game.camera:clamp()

		return
	end

	if #self.touch_fingers == 1 and self.path_direction.selected_entity ~= nil then
		local start_pos = self.path_direction.start_pos
		local end_pos = self.path_direction.end_pos

		if V.dist(start_pos.x, start_pos.y, end_pos.x, end_pos.y) > 100 then
			wid("infobar_view"):hide()
		end
	end

	game.camera:clamp()
end

function TouchView:on_touch_down(id, x, y, dx, dy, pressure)
	log.paranoid("TouchView:on_touch_down(%s,%s,%s)", id, x, y)

	self.selected_tower = nil

	for i, v in pairs(self.touch_fingers) do
		if v[1] == id then
			goto label_239_0
		end
	end

	table.insert(self.touch_fingers, {
		id,
		x,
		y,
		x,
		y
	})

	::label_239_0::

	if #self.touch_fingers > 1 then
		self.multitouch = true

		if game_gui.selected_entity and game_gui.selected_entity.hero then
			self.path_direction.first_move = nil

			self:disable_drag_line()

			return
		end
	end

	if #self.touch_fingers ~= 1 then
		return
	end

	if self.touch_fingers[1] and not self.zooming and self.touch_fingers[1][1] == id then
		ISM:proc_touch(game_gui.mode, "touch_down", id, game_gui:u2s(V.v(x, y)))
	end

	self.panning = false
	self.zooming = false

	log.paranoid("resetting inertia for %s", id)

	for i = 1, #self.inertia_deltas do
		local d = self.inertia_deltas[i]

		d.x, d.y = 0, 0
		d.ts = 0
	end

	self.inertia_last_pos.x = game.camera.x
	self.inertia_last_pos.y = game.camera.y
	self.selected_on_down = nil

	game.camera:cancel_tween(timer)
end

function TouchView:on_touch_up(id, x, y, dx, dy, pressure)
	log.paranoid("TouchView:on_touch_up(%s,%s,%s)", id, x, y)

	if self.touch_fingers[1] and self.touch_fingers[1][1] == id then
		ISM:proc_touch(game_gui.mode, "touch_up", id, game_gui:u2s(V.v(x, y)))
	end

	for i = #self.touch_fingers, 1, -1 do
		if self.touch_fingers[i][1] == id then
			table.remove(self.touch_fingers, i)

			break
		end
	end

	if self.inertia_duration then
		local vx, vy = 0, 0
		local steps = #self.inertia_deltas
		local ts = game_gui.game.store.ts
		local count = 0

		for i = 1, steps do
			local p = self.inertia_deltas[i]
			local dt = ts - p.ts
			local time = 0.25

			if dt < time then
				vx = vx + p.x / game_gui.dpi_scale * (1 - dt / time)
				vy = vy + p.y / game_gui.dpi_scale * (1 - dt / time)
				count = count + 1
			end

			p.x, p.y = 0, 0
			p.ts = 0
		end

		if count > 0 then
			vx, vy = vx / count, vy / count

			if not self.multitouch and (math.abs(vx) > 400 or math.abs(vy) > 400) then
				local ddx = vx * self.inertia_duration * self.inertia_factor
				local ddy = vy * self.inertia_duration * self.inertia_factor

				game.camera:tween(timer, self.inertia_duration, game.camera.x + ddx, game.camera.y + ddy, nil, "out-quad")
				log.paranoid("inertia conditions. inertia_o:%s,%s inertia_d:%s,%s ", game.camera.x, game.camera.y, ddx, ddy)
			end
		end
	end

	if #self.touch_fingers == 0 then
		self.multitouch = false
		self.path_direction.first_move = nil
	end
end

function TouchView:on_touch_move(id, x, y, dx, dy, pressure)
	local fingers = self.touch_fingers
	local c = game.camera

	if game_gui.tutorial.block_movement then
		return
	end

	if self.touch_fingers[1] and self.touch_fingers[1][1] == id then
		ISM:proc_touch(game_gui.mode, "touch_move", id, game_gui:u2s(V.v(x, y)))
	end

	if game_gui.mode == GUI_MODE_DRAG_ENTITY or game_gui.mode == GUI_MODE_DRAG_RALLY_TOWER then
		return
	end

	if #fingers == 1 and fingers[1][1] == id then
		local ix, iy = fingers[1][2], fingers[1][3]
		local mth = self.pan_start_threshold

		if self.panning or mth < math.abs(ix - x) or mth < math.abs(iy - y) then
			self.panning = true

			local deltaX = (fingers[1][4] - x) * game_gui.gui_scale / game.camera.zoom
			local deltaY = (fingers[1][5] - y) * game_gui.gui_scale / game.camera.zoom

			c.x = c.x + deltaX
			c.y = c.y + deltaY
			self.inertia_idx = km.zmod(self.inertia_idx + 1, #self.inertia_deltas)

			local idelta = self.inertia_deltas[self.inertia_idx]
			local dt = self.inertia_dt

			idelta.x, idelta.y = deltaX / dt, deltaY / dt
			idelta.ts = game_gui.game.store.ts
			self.inertia_last_pos.x = c.x
			self.inertia_last_pos.y = c.y
		end

		fingers[1][4], fingers[1][5] = x, y
	elseif #fingers == 2 then
		self.zooming = true

		local f1x, f1y, f2x, f2y

		if fingers[1][1] == id then
			f1x, f1y, f2x, f2y = fingers[1][4], fingers[1][5], fingers[2][4], fingers[2][5]
			fingers[1][4], fingers[1][5] = x, y
		elseif fingers[2][1] == id then
			f1x, f1y, f2x, f2y = fingers[2][4], fingers[2][5], fingers[1][4], fingers[1][5]
			fingers[2][4], fingers[2][5] = x, y
		else
			return
		end

		local odist = V.dist(f1x, f1y, f2x, f2y)
		local imiddle = V.v((f1x + f2x) * 0.5, (f1y + f2y) * 0.5)
		local middle = V.v((x + f2x) * 0.5, (y + f2y) * 0.5)
		local ndist = V.dist(x, y, f2x, f2y)

		local function s2w(s)
			local px = (s.x - game_gui.sw / 2) * game_gui.gui_scale / game.camera.zoom + game.camera.x
			local py = (s.y - game_gui.sh / 2) * game_gui.gui_scale / game.camera.zoom + game.camera.y

			return px, py
		end

		local delta = V.v(game_gui.sw / 2 - middle.x - (middle.x - imiddle.x), game_gui.sh / 2 - middle.y - (middle.y - imiddle.y))
		local zoom = game.camera.zoom * ndist / odist

		zoom = km.clamp(game.camera.min_zoom_clamp, game.camera.max_zoom, zoom)

		local wmx, wmy = s2w(V.v(middle.x, middle.y))

		game.camera.x = wmx
		game.camera.y = wmy
		game.camera.zoom = (zoom + game.camera.zoom) * 0.5

		local wdx, wdy = s2w(V.v(delta.x + game_gui.sw / 2, delta.y + game_gui.sh / 2))

		game.camera.x = wdx
		game.camera.y = wdy

		game.camera:clamp()
	end
end

function TouchView:on_exit(drag_view)
	log.paranoid("TouchView:on_exit")

	self.touch_fingers = {}
	self.mousestate = {}

	for i = 1, #self.inertia_deltas do
		local d = self.inertia_deltas[i]

		d.x, d.y = 0, 0
		d.ts = 0
	end
end

function TouchView:enable_drag_line(start_pos, end_pos, entity)
	self.path_direction.start_pos = start_pos
	self.path_direction.end_pos = end_pos
	self.path_direction.selected_entity = entity

	for _, v in pairs(wid("hero_portraits_view").children) do
		if not v:is_disabled() then
			v:disable(false)

			v._disabled_from_drag = true
		end
	end

	for _, v in pairs(wid("powers_view").children) do
		if not v._disabled then
			v:disable(false)

			v._disabled_from_drag = true
		end
	end

	for _, v in pairs(wid("bag_view").children) do
		if not v._disabled then
			v:disable(false)

			v._disabled_from_drag = true
		end
	end

	wid("pause_button")._disabled = true

	if game_gui.wave_flags then
		for _, wf in ipairs(game_gui.wave_flags) do
			wf.propagate_on_down = true
			wf.propagate_on_up = true
			wf.propagate_on_touch_down = true
			wf.propagate_on_touch_up = true
			wf.propagate_on_touch_move = true
			wf.propagate_on_enter = true
		end
	end

	for _, v in pairs(wid("alerts_view").children) do
		v.propagate_on_down = true
		v.propagate_on_up = true
		v.propagate_on_touch_down = true
		v.propagate_on_touch_up = true
		v.propagate_on_touch_move = true
		v.propagate_on_enter = true
	end

	for i = 1, 3 do
		local b = wid("power_button_" .. i)

		if b then
			b.propagate_on_down = true
			b.propagate_on_up = true
			b.propagate_on_touch_down = true
			b.propagate_on_touch_up = true
			b.propagate_on_touch_move = true
			b.propagate_on_enter = true
		end
	end
end

function TouchView:disable_drag_line()
	self.path_direction.selected_entity = nil
	self.path_direction.start_pos = nil
	self.path_direction.end_pos = nil
	self.path_direction.started_from_entity = nil

	game_gui:set_mode(GUI_MODE_IDLE)

	for _, v in pairs(wid("hero_portraits_view").children) do
		if v._disabled_from_drag then
			v:enable(false)

			v._disabled_from_drag = nil
		end
	end

	for _, v in pairs(wid("powers_view").children) do
		if v._disabled_from_drag then
			v:enable(false)

			v._disabled_from_drag = nil
		end
	end

	for _, v in pairs(wid("bag_view").children) do
		if v._disabled_from_drag then
			v:enable(false)

			v._disabled_from_drag = nil
		end
	end

	wid("pause_button")._disabled = false

	if game_gui.wave_flags then
		for _, wf in ipairs(game_gui.wave_flags) do
			wf.propagate_on_enter = false
		end
	end

	for _, v in pairs(wid("alerts_view").children) do
		v.propagate_on_down = false
		v.propagate_on_up = false
		v.propagate_on_touch_down = false
		v.propagate_on_touch_up = false
		v.propagate_on_touch_move = false
		v.propagate_on_enter = false
	end

	for i = 1, 3 do
		local b = wid("power_button_" .. i)

		if b then
			b.propagate_on_down = false
			b.propagate_on_up = false
			b.propagate_on_touch_down = false
			b.propagate_on_touch_up = false
			b.propagate_on_touch_move = false
			b.propagate_on_enter = false
		end
	end
end

HeroPortrait = class("HeroPortrait", KImageView)

function HeroPortrait:initialize(image_name)
	self.hero_entity = nil

	KImageView.initialize(self, image_name)

	self.anchor.x, self.anchor.y = self.size.x / 2, self.size.y / 2
	self.pos.x = self.pos.x + self.anchor.x
	self.pos.y = self.pos.y + self.anchor.y

	local hover = self:ci("hover")

	hover.anchor.x, hover.anchor.y = hover.size.x / 2 - self.size.x / 2, hover.size.y / 2 - self.size.y / 2

	self:ci("hero_face"):set_image(image_name)

	self.propagate_on_down = false
	self.propagate_on_up = false
	self.propagate_on_touch_down = false
	self.propagate_on_touch_up = false
	self.propagate_on_touch_move = false
	self.propagate_on_enter = false
	self.hero_dead = false
	self.whiteShader = SH:get("p_add")
end

function HeroPortrait:set_hero_entity(e)
	self.hero_entity = e
	self.hero_id = e.id

	self:ci("hero_face"):set_image(e.info.hero_portrait)

	self.portrait_image_name = e.info.hero_portrait

	local image_number = string.sub(self.portrait_image_name, #self.portrait_image_name - 4)

	self.disable_image = "hero_portraits_disabled" .. image_number
	self.hidden = false

	self:ci("outline"):set_image("hero_portraits_selected" .. image_number)

	if not self:ci("door").hidden then
		self:ci("hero_face"):set_image(self.disable_image)

		self:ci("door").ts = 0
		self:ci("door").animation.paused = true
		self:ci("hero_face").hidden = false
	end
end

function HeroPortrait:close_door()
	self:ci("door").ts = 0
	self:ci("door").hidden = false
	self:ci("door").animation.paused = true
	self:ci("hero_face").hidden = true
	self.force_close_door = true
end

function HeroPortrait:open_door()
	if not self:ci("door").hidden then
		self:ci("hero_face"):set_image(self.disable_image)

		self:ci("door").ts = 0
		self:ci("door").animation.paused = true
		self:ci("hero_face").hidden = false
		self.force_close_door = false
	end
end

function HeroPortrait:update_xp(e)
	local levelup = false

	if e.hero.level == 10 then
		if self.hero_level ~= e.hero.level then
			self:ci("xp_bar").scale.x = 1
			self:ci("xp_level").text = 10
			self.hero_level = 10
		end
	else
		if self.hero_level ~= e.hero.level then
			log.debug("level up! %s - %s", e.id, e.template_name)

			self.hero_level = e.hero.level
			self.hero_xp_base = 0

			if e.hero.level > 1 then
				self.hero_xp_base = GS.hero_xp_thresholds[e.hero.level - 1]
			end

			self.hero_xp_next = GS.hero_xp_thresholds[e.hero.level]
			self:ci("xp_level").text = e.hero.level
			levelup = true
		end

		self:ci("xp_bar").scale.x = (e.hero.xp - self.hero_xp_base) / (self.hero_xp_next - self.hero_xp_base)
	end

	return levelup
end

function HeroPortrait:glow()
	local hf = self:ci("hero_face")

	if hf.tweener then
		timer:cancel(hf.tweener)
	end

	hf.tweener = timer:script(function(wait)
		wait(1 / FPS)

		hf.shader = self.whiteShader
		hf.colors = {
			tint = {
				255,
				255,
				255,
				0
			}
		}

		local time = game_gui.game.store.ts

		while game_gui.game.store.ts - time < 0.5 do
			local s = (game_gui.game.store.ts - time) / 0.5
			local v = (1 - s) * 255

			if hf.colors then
				hf.colors = {
					tint = {
						v,
						v,
						v,
						0
					}
				}
			end

			hf.colors.tint[1] = v
			hf.colors.tint[2] = v
			hf.colors.tint[3] = v

			wait(1 / FPS)
		end

		if not hf.colors.tint then
			hf.colors = {
				tint = {
					255,
					255,
					255,
					0
				}
			}
		end

		hf.colors.tint[1] = 255
		hf.colors.tint[2] = 255
		hf.colors.tint[3] = 255
		hf.colors.tint[4] = 255
		hf.tweener = nil
		hf.shader = nil
	end)
end

function HeroPortrait:update(dt)
	local e = self.hero_entity

	if not e or self.force_close_door then
		self:ci("hero_face").hidden = true
		self:ci("door").hidden = false
		self:ci("door").ts = 0
		self:ci("door").animation.paused = true

		self:enable()

		self:ci("health_bar").hidden = true
		self:ci("xp_level").hidden = true
		self:ci("xp_bar").hidden = true

		HeroPortrait.super.update(self, dt)

		self.lock = true

		return
	else
		self:ci("health_bar").hidden = false
		self:ci("xp_level").hidden = false
		self:ci("xp_bar").hidden = false
	end

	if self.lock and not game_gui.game.store.paused then
		self.lock = false

		timer:script(function(wait)
			self:disable()
			wait(1)

			self:ci("door").ts = 0
			self:ci("door").animation.paused = false
			self:ci("overlay").hidden = false
			self:ci("overlay").scale.y = -1
			self:ci("overlay").size.y = self:ci("overlay_img").pos.y

			wait(0.5)

			self:ci("overlay").hidden = true

			self:ci("hero_face"):set_image(self.portrait_image_name)
			self:glow()

			self:ci("door").hidden = true

			self:enable()
		end)
	end

	if not e or not e.health.hp then
		return
	end

	local new_level = self:update_xp(e)

	self:ci("health_bar").scale.x = e.health.hp / e.health.hp_max

	local is_dragging_hero = game_gui.touch_view.path_direction.selected_entity ~= nil

	if e.health.dead and not e.health.ignore_damage then
		if not self.hero_dead then
			self.hero_dead = true

			self:ci("hero_face"):set_image(self.disable_image)
		end

		if not self.death_start_ts then
			self.death_start_ts = game_gui.game.store.ts
		end

		if self:ci("overlay").hidden then
			if game_gui.selected_entity == e then
				game_gui.c_deselect()
			end

			if not e.info.hero_portrait_always_on then
				self:disable()
			end

			self:ci("overlay").hidden = false
			self:ci("overlay").scale.y = -1
		else
			local phase = km.clamp(0, 1, (game_gui.game.store.ts - self.death_start_ts) / e.health.dead_lifetime)

			self:ci("overlay").size.y = self:ci("overlay_img").pos.y - phase * self:ci("overlay_img").pos.y
		end
	elseif (e.health.dead or not e.health.ignore_damage) and (self:is_disabled() or not self:ci("overlay").hidden) then
		if self.hero_dead then
			if is_dragging_hero then
				self:enable()
			end

			self.hero_dead = false

			self:ci("hero_face"):set_image(self.portrait_image_name)

			self:ci("overlay").hidden = true

			self:glow()

			if is_dragging_hero then
				self:disable()
			end
		end

		if not is_dragging_hero then
			self:enable()
		end
	elseif not e.health.dead and self.death_start_ts and (game_gui.game.store.ts - self.death_start_ts) / e.health.dead_lifetime < 1 then
		local phase = km.clamp(0, 1, (game_gui.game.store.ts - self.death_start_ts) / e.health.dead_lifetime)

		self:ci("health_bar").scale.x = e.health.hp_max * phase / e.health.hp_max
	end

	if e.health.hp > 0 then
		self.death_start_ts = nil
	end

	if self.portrait_image_name ~= e.info.hero_portrait then
		self:ci("hero_face"):set_image(e.info.hero_portrait)

		self.portrait_image_name = e.info.hero_portrait
	end

	HeroPortrait.super.update(self, dt)
end

function HeroPortrait:select()
	S:queue("GUIQuickMenuOpen")

	self:ci("outline").hidden = false
end

function HeroPortrait:deselect()
	self:ci("outline").hidden = true
end

function HeroPortrait:on_click(button, x, y)
	if not self.hero_entity then
		return
	end

	if self.hero_entity == game_gui.selected_entity then
		game_gui.c_deselect_heros(nil)
		S:queue("GUIQuickMenuOpen")
	elseif self.hero_entity then
		game_gui.c_select_hero(nil, self.hero_idx)
	end
end

function HeroPortrait:on_enter()
	if ISM.last_input ~= I_TOUCH then
		S:queue("GUIQuickMenuOver")

		self:ci("hover").hidden = false
	end
end

function HeroPortrait:on_exit()
	self:ci("hover").hidden = true
	self.scale.x, self.scale.y = 1, 1
end

function HeroPortrait:on_down(button, x, y)
	GG5Button.static.down_bounce_ani(self)
end

function HeroPortrait:on_up(button, x, y)
	GG5Button.static.up_bounce_ani(self)
end

BagItemButton = class("BagItemButton", KImageView)
BagItemButton.static.init_arg_names = {
	"default_image_name",
	"selected_image_name",
	"icon_bg_image_name"
}

function BagItemButton:initialize(default_image_name, selected_image_name, icon_bg_image_name)
	KImageView.initialize(self, default_image_name)

	self.selected_item = nil
	self.propagate_on_down = false
	self.propagate_on_up = false
	self.propagate_on_touch_down = false
	self.propagate_on_touch_up = false
	self.propagate_on_touch_move = false
	self.propagate_on_enter = false

	local frame = self:ci("bag_item_button")

	function frame.on_click(this)
		self:on_click()
	end

	function frame.on_enter(this)
		self:on_enter()
	end

	function frame.on_exit(this)
		self:on_exit()
	end

	local selected = self:ci("selected")

	function selected.on_click(this)
		self:deselect()
	end

	function selected.on_enter(this)
		self:on_enter()
	end

	function selected.on_exit(this)
		self:on_exit()
	end

	local frame_buy = self:ci("bag_item_purchase")

	function frame_buy.on_click(this)
		self:on_click()
	end

	function frame_buy.on_enter(this)
		self:on_enter()
	end

	function frame_buy.on_exit(this)
		self:on_exit()
	end

	local rect_w, rect_h = frame.size.x * 0.75, frame.size.y * 0.75

	frame.hit_rect = {
		pos = V.v(frame.pos.x + (frame.size.x - rect_w) * 0.5, frame.pos.y + (frame.size.y - rect_h) * 0.5),
		size = V.v(rect_w, rect_h)
	}

	local slot = storage:load_slot()

	self:set_mode("unlocked")

	local item_name = slot.items.selected[self.item_id]
	local qty = slot.items.status[item_name] or 0

	self:set_item(item_name, qty)
end

function BagItemButton:set_mode(new_mode, item_name)
	local function sid(id)
		return self:ci(id)
	end

	local doors = sid("bag_item_door")
	local frame = sid("bag_item_button")

	sid("bag_item_purchase").hidden = true
	sid("bag_item_purchase_hover").hidden = true
	sid("selected").hidden = true
	self.mode = new_mode
	self.selected_item = nil

	if new_mode == "locked" then
		self:disable(false)

		doors.hidden = false
		doors.ts = 0
		doors.animation.paused = true
		sid("bag_item_qty").hidden = true
		sid("bag_item_qty_back").hidden = true
		sid("bag_item_purchase").hidden = true
		frame.hidden = false
	elseif new_mode == "unlocked" then
		self:enable(false)
		self:set_image(self.default_image_name)

		doors.hidden = false
		doors.ts = 0
		doors.animation.paused = nil
	elseif new_mode == "item" then
		self.selected_item = item_name

		game_gui.c_deselect()
		game_gui:set_mode("ITEM_" .. self.item_id)

		frame.hidden = true
		sid("selected").hidden = false
		sid("bag_item_qty").hidden = true
		sid("bag_item_qty_back").hidden = true

		wid("infobar_view"):show_text(_(string.upper("ITEM_" .. item_name .. "_NAME")), _(string.upper("ITEM_" .. item_name .. "_BOTTOM_INFO")))
	elseif new_mode == "buy" then
		game_gui.c_deselect()

		frame.hidden = true
		sid("bag_item_purchase").hidden = false
		sid("bag_item_qty").hidden = true
		sid("bag_item_qty_back").hidden = true
	else
		game_gui.c_deselect()
		self:enable(false)

		self.mode = "default"
		frame.hidden = false
		sid("bag_item_qty").hidden = false
		sid("bag_item_qty_back").hidden = false

		wid("infobar_view"):hide()
	end
end

function BagItemButton:deselect()
	if self.mode == "selected" or self.mode == "item" then
		S:queue("GUIQuickMenuOpen")
		self:set_mode("default")
	end
end

function BagItemButton:select_item(item_name)
	S:queue("GUIQuickMenuOpen")

	if SHOW_INGAME_SHOP then
		local slot = storage:load_slot()
		local qty = slot.items.status[item_name] or 0

		if qty <= 0 then
			wid("popup_ingame_shop_container"):show(slot.items.selected)
		else
			self:set_mode("item", item_name)
		end
	else
		self:set_mode("item", item_name)
	end
end

function BagItemButton:set_item(item_name, qty)
	self.item = item_name
	self:ci("bag_item_qty").text = qty

	if qty <= 0 then
		self:ci("item"):set_image("item_icons_" .. item_name .. "_disabled")
	else
		self:ci("item"):set_image("item_icons_" .. item_name)
	end

	if not SHOW_INGAME_SHOP and qty <= 0 then
		self:disable(false)
	end
end

function BagItemButton:refresh()
	local slot = storage:load_slot()
	local item_name = slot.items.selected[self.item_id]
	local qty = slot.items.status[item_name] or 0

	if SHOW_INGAME_SHOP and qty <= 0 and self.mode ~= "locked" then
		self:set_mode("buy", item_name)
	else
		self:set_item(item_name, qty)

		if qty > 0 then
			self:set_mode("default", item_name)
		end
	end

	self:ci("bag_item_qty").text = qty
end

function BagItemButton:fire(item_name, x, y, entity)
	self:deselect()

	local slot = storage:load_slot()
	local qty = slot.items.status[item_name] or 0

	qty = km.clamp(0, 9000000000, qty - 1)
	slot.items.status[item_name] = qty

	storage:save_slot(slot)

	self:ci("bag_item_qty").text = qty

	if SHOW_INGAME_SHOP then
		if qty <= 0 then
			self:ci("item"):set_image("item_icons_" .. item_name .. "_disabled")
			self:set_mode("buy", item_name)
		else
			self:ci("item"):set_image("item_icons_" .. item_name)
		end
	elseif qty < 1 then
		self:disable(false)
		self:ci("item"):set_image("item_icons_" .. item_name .. "_disabled")
	end
end

function BagItemButton:toggle_selection()
	log.debug("gui_mode:%s", game_gui.mode)

	if self.selected_item then
		self:deselect()
	else
		self:select_item(self.item)
	end
end

function BagItemButton:on_click()
	self:toggle_selection()
end

function BagItemButton:on_enter()
	if ISM.last_input ~= I_TOUCH then
		S:queue("GUIQuickMenuOver")

		if self.selected_item ~= nil then
			if self.mode == "buy" then
				self:ci("bag_item_purchase_hover").hidden = false
			else
				self:ci("hover_selected").hidden = false
			end
		elseif self.mode == "buy" then
			self:ci("bag_item_purchase_hover").hidden = false
		else
			self:ci("hover").hidden = false
		end
	end
end

function BagItemButton:on_exit()
	self:ci("hover_selected").hidden = true
	self:ci("hover").hidden = true
	self:ci("bag_item_purchase_hover").hidden = true
	self.scale.x, self.scale.y = 1, 1
end

ItemRewardParticles = class("ItemRewardParticles", KView)

function ItemRewardParticles:initialize(scale)
	ItemRewardParticles.super.initialize(self)

	scale = scale or 1

	local ss = I:s("lives_particle")
	local p_scale = (ss.ref_scale or 1) * scale
	local c = G.newCanvas(ss.size[1], ss.size[2])

	G.setCanvas(c)
	G.draw(I:i(ss.atlas), ss.quad, ss.trim[1], ss.trim[2])
	G.setCanvas()

	local ps = G.newParticleSystem(c, 500)

	ps:setDirection(-math.pi / 2)
	ps:setSpread(2 * math.pi)
	ps:setSizes(1 * p_scale, 0.5 * p_scale)
	ps:setParticleLifetime(0, 0.8)
	ps:setSpeed(50 * scale, 300 * scale)
	ps:setRadialAcceleration(-50 * scale)
	ps:setColors(255, 255, 255, 255, 255, 255, 255, 0)
	ps:emit(150)

	self.ps = ps

	timer:after(1, function()
		self.parent:remove_child(self)
		log.debug("remving particles :%s", self)
	end)
end

function ItemRewardParticles:update(dt)
	ItemRewardParticles.super.update(self, dt)
	self.ps:update(dt)
end

function ItemRewardParticles:draw()
	G.setBlendMode("add")
	G.draw(self.ps, 0, 0)
	G.setBlendMode("alpha")
	ItemRewardParticles.super.draw(self)
end

PowerButton = class("PowerButton", KImageView)
PowerButton.static.init_arg_names = {
	"power_id",
	"image_name"
}

function PowerButton:initialize(power_id, image_name)
	self.default_image_name = image_name

	KImageView.initialize(self, self.default_image_name)

	self.anchor.x, self.anchor.y = self.size.x / 2, self.size.y / 2
	self.pos.x = self.pos.x + self.anchor.x
	self.pos.y = self.pos.y + self.anchor.y
	self.propagate_on_down = false
	self.propagate_on_up = false
	self.propagate_on_click = false
	self.propagate_on_touch_down = false
	self.propagate_on_touch_up = false
	self.propagate_on_touch_move = false
	self.propagate_on_enter = false
	self.selected_gui_mode = _G["GUI_MODE_POWER_" .. power_id]
	self.power_id = power_id
	self.cooldown_time = 2

	local tm = self:ci("timer_mask")

	tm.clip = true
	tm.phase = 0

	function tm.clip_fn()
		G.rectangle("fill", 0, tm.pos.y + tm.size.y * tm.phase, tm.size.x, tm.size.y * (1 - tm.phase))
	end

	self.tm = tm
	self.shader = SH:get("p_add")
	self.colors = {
		tint = {
			0,
			0,
			0,
			0
		}
	}

	self:set_mode("locked")
end

function PowerButton:set_mode(new_mode)
	local ld, rd, doors = self:ci("left_door"), self:ci("right_door"), self:ci("doors")
	local glow = self:ci("glow")
	local inst_reload = self:ci("instant_reload")
	local mask = self:ci("mask")
	local tm = self:ci("timer_mask")
	local sel = self:ci("selected") or {}

	local function tween_glow()
		if self.tweener then
			timer:cancel(self.tweener)
		end

		self.tweener = timer:script(function(wait)
			self.colors.tint[1] = 255
			self.colors.tint[2] = 255
			self.colors.tint[3] = 255

			local time = game_gui.game.store.ts

			while game_gui.game.store.ts - time < 0.5 do
				local s = (game_gui.game.store.ts - time) / 0.5
				local v = (1 - s) * 255

				self.colors.tint[1] = v
				self.colors.tint[2] = v
				self.colors.tint[3] = v

				wait(1 / FPS)
			end

			self.colors.tint[1] = 0
			self.colors.tint[2] = 0
			self.colors.tint[3] = 0
			self.tweener = nil
		end)
	end

	local old_mode = self.mode

	self.mode = new_mode

	if new_mode == "locked" then
		self:disable(false)

		ld.ts = 0
		ld.animation.paused = true
		rd.hidden = true
		rd.ts = 0
		rd.animation.paused = true
		mask.hidden = false
		tm.hidden = true
		sel.hidden = true
		glow.hidden = true
		inst_reload.hidden = true
	elseif new_mode == "unlocked" then
		self:enable(false)

		ld.ts, rd.ts = 0, 0
		ld.animation.paused, rd.animation.paused = nil

		if IS_KR3 or not IS_TRILOGY then
			sel.hidden = true
		else
			self:set_image(self.default_image_name)
		end

		tween_glow()

		glow.ts = 0
		glow.hidden = false
		mask.hidden = true
		tm.hidden = true
	elseif new_mode == "cooldown" then
		if self.power_id > 1 then
			local upg = UP:get_upgrade("heroes_limit_pushing")
			local triggered_limit_pushing = false

			if upg then
				if not self._limit_pushing_deck then
					self._limit_pushing_deck = STU.deck_new(upg.trigger_cards, upg.total_cards, true)
				end

				triggered_limit_pushing = STU.deck_draw(self._limit_pushing_deck)
			end

			if triggered_limit_pushing then
				S:queue("UpgradeLimitPushing")
				self:set_mode("ready")

				inst_reload.ts = 0
				inst_reload.hidden = false
				inst_reload.animation.paused = nil

				return
			end
		end

		self:disable(false)

		if IS_KR3 or not IS_TRILOGY then
			sel.hidden = true
		else
			self:set_image(self.default_image_name)
		end

		mask.hidden = false
		tm.hidden = false
		tm.phase = 0
		tm.start_ts = game_gui.game.store.ts
		glow.hidden = true

		wid("infobar_view"):hide()
	elseif new_mode == "ready" then
		self:enable(false)

		ld.hidden, rd.hidden = true, true

		tween_glow()

		glow.ts = 0
		glow.hidden = false
		mask.hidden = true
		tm.hidden = true
		sel.hidden = true

		self:set_mode("default")
		S:queue("GUISpellRefresh")
	elseif new_mode == "selected" then
		if IS_KR3 or not IS_TRILOGY then
			sel.hidden = false
		else
			self:set_image(self.selected_image_name)
		end

		wid("infobar_view"):show_text(_(self.i18n_title), _(self.i18n_desc))
	else
		self:enable(false)

		if IS_KR3 or not IS_TRILOGY then
			sel.hidden = true
		else
			self:set_image(self.default_image_name)
		end

		if old_mode ~= "ready" then
			wid("infobar_view"):hide()
		end

		self.mode = "default"
	end
end

function PowerButton:update(dt)
	KImageView.update(self, dt)

	if self.mode == "cooldown" then
		local phase = km.clamp(0, 1, (game_gui.game.store.ts - self.tm.start_ts) / self.cooldown_time)

		self.tm.phase = phase

		if phase == 1 then
			self:set_mode("ready")
		end
	end
end

function PowerButton:select()
	S:queue("GUIQuickMenuOpen")
	self:set_mode("selected")
end

function PowerButton:deselect(keep_hover)
	S:queue("GUIQuickMenuOpen")

	if keep_hover then
		self:set_mode("highlighted")
	else
		self:set_mode("default")
	end
end

function PowerButton:fire(wx, wy)
	self:set_mode("cooldown")
end

function PowerButton:is_disabled()
	return self._disabled or self.mode == "locked" or self.mode == "cooldown"
end

function PowerButton:toggle_selection(keep_hover)
	if game_gui.mode == self.selected_gui_mode then
		if keep_hover then
			self:set_mode("highlighted")
		else
			self:set_mode("default")
		end

		game_gui.c_deselect_power(nil, self.power_id)
	elseif self.mode ~= "cooldown" then
		game_gui.c_select_power(nil, self.power_id)
	end
end

function PowerButton:early_wave_bonus(remaining_time)
	if self.mode == "cooldown" and remaining_time > 1 then
		self.tm.start_ts = self.tm.start_ts - remaining_time
	end
end

function PowerButton:on_click()
	self:toggle_selection(true)
end

function PowerButton:on_enter()
	if ISM.last_input ~= I_TOUCH then
		S:queue("GUIQuickMenuOver")

		self:ci("hover").hidden = false
	end
end

function PowerButton:on_exit()
	self:ci("hover").hidden = true
	self.scale.x, self.scale.y = 1, 1
	self.hit_rect = nil
end

function PowerButton:on_focus()
	self:on_enter()
end

function PowerButton:on_defocus()
	self:on_exit()
end

function PowerButton:on_down(id, x, y, dx, dy, pressure)
	GG5Button.static.down_bounce_ani(self)
	self:order_to_front()

	local m = self.size.x * POWER_BUTTON_DRAG_SCALE

	self.hit_rect = V.r(-m, -m, self.size.x + 2 * m, self.size.y + 2 * m)
end

function PowerButton:on_up(id, x, y, dx, dy, pressure)
	GG5Button.static.up_bounce_ani(self)

	self.hit_rect = nil
end

PowerButtonBlock = class("PowerButtonBlock", KImageView)

function PowerButtonBlock:initialize(power_button, duration, style_name)
	self.power_button = power_button
	self.duration = duration

	local styles = data.power_button_block_styles
	local style = styles[style_name] or styles.drow_queen

	KImageView.initialize(self, style.image)

	self.anchor = V.v(self.size.x / 2, self.size.y / 2)
	self.pos.x, self.pos.y = power_button.size.x / 2, power_button.size.y / 2
	self.animations = style.animations
end

function PowerButtonBlock:block()
	self.power_button:disable(false)

	self.start_ts = game_gui.game.store.ts
	self.animation = self.animations.block
	self.ts = 0
end

function PowerButtonBlock:unblock()
	self.power_button:enable(false)

	self.start_ts = nil
	self.animation = self.animations.unblock
	self.ts = 0

	timer:after((self.animation.to - self.animation.from + 1) / 30, function()
		self:remove_from_parent()
	end)
end

function PowerButtonBlock:update(dt)
	if self.start_ts and game_gui.game.store.ts - self.start_ts > self.duration then
		self:unblock()
	end

	PowerButtonBlock.super.update(self, dt)
end

TowerMenu = class("TowerMenu", KImageView)

function TowerMenu:initialize()
	TowerMenu.super.initialize(self, "ingame_ui_gui_ring")

	self.anchor = V.v(self.size.x / 2, self.size.y / 2)
	self.buttons = {}
	self.fit_screen_factor_x = 1.3
	self.fit_screen_factor_y = 1.3
end

function TowerMenu:show(entity, force_focus)
	if not entity.tower then
		return
	end

	self:enable()

	self.entity = entity

	if entity.user_selection then
		entity.user_selection.menu_shown = true
	end

	game_gui:hide_tower_range("all")

	if entity.attacks and entity.attacks.range then
		local range = entity.attacks.range

		game_gui:show_tower_range("tower", entity, range)
	elseif entity.barrack then
		local range = entity.barrack.rally_range

		game_gui:show_tower_range("rally", entity, range)
	end

	if entity.tower.type ~= "tower_timed_destroy" and not string.find(entity.tower.type, "tower_broken") and (not tower_menus[entity.tower.type] or not tower_menus[entity.tower.type][entity.tower.level]) then
		log.debug("tower_menus[%s][%s] not found", entity.tower.type, entity.tower.level)

		self.hidden = true

		return
	end

	local tm = tower_menus[entity.tower.type][entity.tower.level]

	if entity.tower.type == "tower_timed_destroy" then
		tm = tower_menus[entity.tower.type][1]
		self._shown_from_blocked_overseer = true
	end

	if string.find(entity.tower.type, "tower_broken") then
		tm = tower_menus[entity.tower.type][1]
	end

	if game_gui.tutorial.block_towers then
		for _, item in pairs(tm) do
			if item.place then
				if item.action_arg ~= game_gui.tutorial.enabled_tower then
					if item.action == "tw_upgrade" then
						item.action = "tw_locked"
					end
				elseif item.action_arg == game_gui.tutorial.enabled_tower then
					item.action = "tw_upgrade"
					item.tutorial_enabled_tower = true
				end
			end
		end
	else
		for _, item in pairs(tm) do
			if item.type ~= "slot_locked" and item.place and item.action == "tw_locked" then
				item.action = "tw_upgrade"
			end

			item.tutorial_enabled_tower = nil
		end
	end

	self.selected_button = nil

	self:remove_children()

	for _, item in pairs(tm) do
		if item.place then
			if (item.action == "tw_upgrade" or item.action == "tw_blocked") and game_gui.game.store.level.locked_towers and table.contains(game_gui.game.store.level.locked_towers, item.action_arg) and not DEBUG_UNLOCK_ALL_TOWERS then
				local b = KImageView:new("main_icons_0014")

				b.pos = V.vclone(data.tower_menu_button_places[item.place])
				b.pos.x, b.pos.y = b.pos.x + self.size.x / 2, b.pos.y + self.size.y / 2
				b.anchor = V.v(b.size.x * 0.5, b.size.y * 0.5)

				self:add_child(b)

				if IS_KR3 or not IS_TRILOGY then
					local cover = "ingame_ui_main_icons_over"

					if game_gui.tutorial.block_towers then
						cover = "ingame_ui_main_icons_over_highlighted"
					end

					local bo = KImageView:new(cover)

					bo.pos = V.v(math.floor(-0.5 * (bo.size.x - b.size.x) + 1), math.floor(-0.5 * (bo.size.y - b.size.y)))
					bo.propagate_on_click = true
					bo.disabled_tint_color = nil

					b:add_child(bo, 1)
				end
			elseif item.action == "tw_sell" and entity.tower and not entity.tower.can_be_sold then
				-- block empty
			elseif item.action == "tw_blocked" and entity.tower then
				local b = TowerMenuButton:new(item, entity)

				b.pos = V.vclone(data.tower_menu_button_places[item.place])
				b.pos.x, b.pos.y = b.pos.x + self.size.x / 2, b.pos.y + self.size.y / 2
				b.item_props = item

				self:add_child(b)
				b:disable()
			elseif item.action == "tw_locked" and entity.tower then
				local b = KImageView:new("main_icons_0014")

				b.pos = V.vclone(data.tower_menu_button_places[item.place])
				b.pos.x, b.pos.y = b.pos.x + self.size.x / 2, b.pos.y + self.size.y / 2
				b.anchor = V.v(b.size.x * 0.5, b.size.y * 0.5)

				self:add_child(b)

				if IS_KR3 or not IS_TRILOGY then
					local bo = KImageView:new("ingame_ui_main_icons_over")

					bo.pos = V.v(math.floor(-0.5 * (bo.size.x - b.size.x)), math.floor(-0.5 * (bo.size.y - b.size.y)))
					bo.propagate_on_click = true
					bo.disabled_tint_color = nil

					b:add_child(bo)
				end
			else
				local b = TowerMenuButton:new(item, entity)

				b.pos = V.vclone(data.tower_menu_button_places[item.place])
				b.pos.x, b.pos.y = b.pos.x + self.size.x / 2, b.pos.y + self.size.y / 2
				b.item_props = item

				if item.tutorial_enabled_tower and b.image_highlight then
					b.image_highlight.hidden = false
				end

				self:add_child(b)
				table.insert(self.buttons, b)

				if item.action == "tw_none" then
					b:disable()
				end

				if (IS_KR3 or not IS_TRILOGY) and game_gui.tutorial.block_towers then
					local bo = KImageView:new("ingame_ui_main_icons_over_highlighted")

					bo.pos = V.v(math.floor(-0.5 * (bo.size.x - b.size.x)), math.floor(-0.5 * (bo.size.y - b.size.y)))
					bo.propagate_on_click = true
					bo.disabled_tint_color = nil

					b:add_child(bo, 1)
				end
			end
		end
	end

	if self.tweeners then
		for _, t in pairs(self.tweeners) do
			timer:cancel(t)
		end
	end

	local ro = entity.tower.range_offset
	local mo = entity.tower.menu_offset
	local ewx, ewy = game_gui:w2u(V.v(entity.pos.x + ro.x + mo.x, entity.pos.y + ro.y + mo.y), true)

	self.pos = V.v(ewx, ewy)
	self.scale = V.v(game.camera.zoom * self.max_scale * 0.5, game.camera.zoom * self.max_scale * 0.5)
	self.alpha = 1
	self.hidden = false
	self.tweening = true
	self.tweeners = {
		timer:tween(0.16, self.scale, {
			x = game.camera.zoom * self.max_scale,
			y = game.camera.zoom * self.max_scale
		}, "out-quad", function()
			self.tweening = nil
			self.tweeners = {}

			self:get_window():set_responder(self)

			if force_focus then
				self:get_window():keypressed("tab")
			end
		end)
	}

	local esx = self.fit_screen_factor_x * self.size.x * game.camera.zoom * game_gui.gui_scale
	local esy = self.fit_screen_factor_y * self.size.y * game.camera.zoom * game_gui.gui_scale
	local ecx, ecy = entity.pos.x * game.game_scale, (game.ref_h - entity.pos.y) * game.game_scale
	local dcx, dcy = game.camera.x, game.camera.y
	local dzoom = game.camera.zoom
	local c_h = game_gui.clamped_h
	local cy_t = ecy + (c_h - esy) / (2 * game.camera.zoom)
	local cy_b = ecy - (c_h - esy) / (2 * game.camera.zoom)
	local off_t = 30 * game.game_scale / game.camera.zoom
	local off_b = 60 * game.game_scale / game.camera.zoom

	if cy_t < dcy + off_t then
		dcy = cy_t
		dcy = dcy - off_t
	elseif cy_b > dcy - off_b then
		dcy = cy_b
		dcy = dcy + off_b
	end

	local cx_l = ecx + (game_gui.w - esx) / (2 * dzoom)
	local cx_r = ecx + (esx - game_gui.w) / (2 * dzoom)

	if cx_l < dcx then
		dcx = cx_l
	elseif dcx < cx_r then
		dcx = cx_r
	end

	game_gui.touch_view:on_exit()
	game.camera:tween(timer, 0.75, dcx, dcy, game.camera.zoom, "in-out-quad")
	signal.emit("tower-menu-showing")
	S:queue("GUIQuickMenuOpen")
end

function TowerMenu:hide()
	self:disable()

	local entity = self.entity

	if entity and entity.user_selection then
		entity.user_selection.menu_shown = nil
	end

	self.entity = nil

	if self.selected_button then
		self.selected_button:deselect()
	end

	if self.tweeners then
		for _, t in pairs(self.tweeners) do
			timer:cancel(t)
		end
	end

	self.tweening = true
	self.tweeners = {
		timer:tween(0.08, self.scale, {
			x = game.camera.zoom * self.max_scale * 0.5,
			y = game.camera.zoom * self.max_scale * 0.5
		}, "out-quad", function()
			self.hidden = true
			self.tweening = false
			self.tweeners = {}
		end)
	}

	game_gui:hide_tower_range("all")
	wid("tower_menu_tooltip"):hide()
	signal.emit("tower-menu-hiding")

	self._shown_from_blocked_overseer = nil
end

function TowerMenu:update(dt)
	TowerMenu.super.update(self, dt)

	if self.hidden then
		return
	end

	local e = self.entity

	if not e or not e.tower then
		return
	end

	if e.tower.blocked and e.tower.type ~= "tower_timed_destroy" and not string.find(e.tower.type, "tower_broken") then
		game_gui.c_deselect()

		return
	end

	if string.find(e.tower.type, "tower_broken") and not e.tower.blocked then
		game_gui.c_deselect()

		return
	end

	if e.tower.blocked and e.tower.type == "tower_timed_destroy" and not self._shown_from_blocked_overseer then
		game_gui.c_deselect()

		return
	end

	if not self.tweening then
		self.scale.x = game.camera.zoom * self.max_scale
		self.scale.y = game.camera.zoom * self.max_scale
	end

	local mo = self.entity.tower.menu_offset
	local mx, my = game_gui:w2u(V.v(e.pos.x + mo.x, e.pos.y + 16 + mo.y))

	self.pos.x, self.pos.y = mx, my

	if e and e.attacks and e.attacks.range and game_gui.tower_ranges.tower and game_gui.tower_ranges.tower.range_shown ~= e.attacks.range then
		local showing_upg = game_gui.tower_ranges.upgrade
		local upg_range

		if showing_upg then
			upg_range = game_gui.tower_ranges.upgrade.range_shown
		end

		game_gui:hide_tower_range("all")
		game_gui:show_tower_range("tower", e, e.attacks.range)

		if showing_upg then
			game_gui:show_tower_range("upgrade", e, upg_range)
		end

		if not game_gui.tower_ranges.upgrade then
			-- block empty
		end
	elseif e.barrack and game_gui.tower_ranges.rally and game_gui.tower_ranges.rally.range_shown ~= e.barrack.rally_range then
		local showing_upg = game_gui.tower_ranges.rally_upgrade
		local upg_range

		if showing_upg then
			upg_range = game_gui.tower_ranges.rally_upgrade.range_shown
		end

		game_gui:hide_tower_range("all")
		game_gui:show_tower_range("rally", e, e.barrack.rally_range)

		if showing_upg then
			game_gui:show_tower_range("rally_upgrade", e, upg_range)
		end
	end
end

TowerMenuButton = class("TowerMenuButton", GG5Button)

function TowerMenuButton:initialize(item, entity)
	TowerMenuButton.super.initialize(self)

	self.item_image = item.image
	self.item = item
	self.entity = entity
	self.propagate_on_touch_down = false
	self.propagate_on_touch_up = false
	self.propagate_on_touch_move = false
	self.propagate_on_enter = false

	local b = KImageView:new(item.image)

	b.pos = V.v(0, 0)
	b.propagate_on_click = true
	b.disabled_tint_color = nil
	self.button = b

	self:add_child(b)

	self.anchor = V.v(b.size.x * 0.5, b.size.y * 0.5)

	local image_check, image_halo, image_frame

	if item.check and IS_MOBILE then
		image_check = KImageView:new(item.check)
		image_check.pos = V.v(0, 0)
		image_check.propagate_on_click = true
		image_check.hidden = true

		self:add_child(image_check)

		self.check = image_check
		self.check_image = item.check
	end

	if item.action == "tw_upgrade" or item.action == "tw_buy_soldier" or item.action == "tw_buy_attack" or item.action == "tw_unblock" or item.action == "tw_prevent_timed_destroy" or item.action == "tw_blocked" or item.action == "tw_repair" then
		image_frame = KImageView:new("ingame_ui_main_icons_over")
		image_frame.pos = V.v(math.floor(-0.5 * (image_frame.size.x - b.size.x)), math.floor(-0.5 * (image_frame.size.y - b.size.y)))
		image_frame.propagate_on_click = true
		image_frame.disabled_tint_color = nil
		image_halo = KImageView:new("ingame_ui_main_icons_over_hover")
		image_halo.pos = V.v(math.floor(-0.5 * (image_halo.size.x - b.size.x)), math.floor(-0.5 * (image_halo.size.y - b.size.y)))
	elseif item.action == "upgrade_power" or item.action == "tw_free_action" then
		if item.use_tw_upgrade_halo then
			image_frame = KImageView:new("ingame_ui_main_icons_over")
			image_frame.pos = V.v(math.floor(-0.5 * (image_frame.size.x - b.size.x)), math.floor(-0.5 * (image_frame.size.y - b.size.y)))
			image_frame.propagate_on_click = true
			image_halo = KImageView:new("ingame_ui_main_icons_over_hover")
			image_halo.pos = V.v(math.floor(-0.5 * (image_halo.size.x - b.size.x)), math.floor(-0.5 * (image_halo.size.y - b.size.y)))
		else
			image_frame = KImageView:new("ingame_ui_special_icons_bg")
			image_frame.pos = V.v(math.floor(-0.5 * (image_frame.size.x - b.size.x)), math.floor(-0.5 * (image_frame.size.y - b.size.y)))
			image_frame.propagate_on_click = true
			image_halo = KImageView:new("ingame_ui_special_icons_bg_hover")
			image_halo.pos = V.v(math.floor(-0.5 * (image_halo.size.x - b.size.x)), math.floor(-0.5 * (image_halo.size.y - b.size.y)))
		end
	elseif item.action == "tw_change_mode" then
		image_frame = KImageView:new("ingame_ui_action_icon_frame")
		image_frame.pos = V.v(math.floor(-0.5 * (image_frame.size.x - b.size.x)), math.floor(-0.5 * (image_frame.size.y - b.size.y)))
		image_frame.propagate_on_click = true
		image_frame.disabled_tint_color = nil
		image_halo = KImageView:new("ingame_ui_action_icon_frame_hover")
		image_halo.pos = V.v(math.floor(-0.5 * (image_halo.size.x - b.size.x)), math.floor(-0.5 * (image_halo.size.y - b.size.y)))
	elseif item.action == "tw_swap_mode" or item.action == "tw_combination" then
		image_frame = KImageView:new("ingame_ui_action_icon_frame")
		image_frame.pos = V.v(math.floor(-0.5 * (image_frame.size.x - b.size.x)), math.floor(-0.5 * (image_frame.size.y - b.size.y)))
		image_frame.propagate_on_click = true
		image_frame.disabled_tint_color = nil
		image_halo = KImageView:new("ingame_ui_action_icon_frame_hover")
		image_halo.pos = V.v(math.floor(-0.5 * (image_halo.size.x - b.size.x)), math.floor(-0.5 * (image_halo.size.y - b.size.y)))
	elseif item.action == "tw_sell" or item.action == "tw_rally" then
		local rect_w, rect_h = b.size.x * 0.5, b.size.y * 0.5

		self.hit_rect = {
			pos = V.v(self.pos.x + (b.size.x - rect_w) * 0.5, self.pos.y + (b.size.y - rect_h) * 0.5),
			size = V.v(rect_w, rect_h)
		}
	end

	if not image_halo and item.halo then
		image_halo = KImageView:new(item.halo)
		image_halo.pos = V.v(math.floor(-0.5 * (image_halo.size.x - b.size.x)), math.floor(-0.5 * (image_halo.size.y - b.size.y)))
	end

	if image_halo then
		image_halo.propagate_on_click = true
		image_halo.hidden = true
		self.image_halo = image_halo
	end

	if image_halo then
		self:add_child(image_halo)
	end

	if image_check then
		self:add_child(image_check)
	end

	if image_frame then
		self:add_child(image_frame)
	end

	if item.action == "upgrade_power" then
		local power = entity.powers[item.action_arg]

		if not item.no_upgrade_lights then
			self.power_buttons = {}

			local max_level = #power.price

			for i = 1, max_level do
				local pv

				if i > power.level then
					pv = KImageView:new("ingame_ui_power_rank_0002")
				else
					pv = KImageView:new("ingame_ui_power_rank_0001")
				end

				pv.pos = V.vclone(data.tower_menu_power_places[i])
				pv.pos.x, pv.pos.y = pv.pos.x - pv.size.x / 2, pv.pos.y - pv.size.y / 2
				pv.disabled_tint_color = nil
				pv.propagate_on_click = true

				self:add_child(pv)
				table.insert(self.power_buttons, pv)
			end
		end
	end

	self.image_highlight = KImageView:new("ingame_ui_main_icons_over_highlighted")
	self.image_highlight.pos = V.v(math.floor(-0.5 * (self.image_highlight.size.x - b.size.x)), math.floor(-0.5 * (self.image_highlight.size.y - b.size.y)))
	self.image_highlight.hidden = true

	self:add_child(self.image_highlight)

	local price_tag

	if item.action == "tw_upgrade" or item.action == "tw_blocked" then
		local nt = E:get_template(item.action_arg)

		if nt.build_name then
			nt = E:get_template(nt.build_name)
		end

		price_tag = tostring(nt.tower.price)
	elseif item.action == "tw_unblock" then
		price_tag = tostring(entity.tower_holder.unblock_price)
	elseif item.action == "tw_prevent_timed_destroy" then
		price_tag = tostring(entity.tower._prevent_timed_destroy_price)
	elseif item.action == "upgrade_power" then
		local power = entity.powers[item.action_arg]
		local price = power.level < #power.price and power.price[power.level + 1] or nil

		price_tag = price and tostring(price) or nil
	elseif item.action == "tw_buy_soldier" then
		local nt = E:get_template(item.action_arg)

		if type(nt.unit.price) == "table" then
			price_tag = tostring(nt.unit.price[km.clamp(1, #nt.unit.price, entity.barrack.max_soldiers + 1)])
		else
			price_tag = tostring(nt.unit.price)
		end
	elseif item.action == "tw_buy_attack" then
		price_tag = ""
	elseif item.action == "tw_repair" then
		price_tag = not entity.repair.active and entity.repair.cost or nil
	end

	if price_tag then
		local pt = GGLabel:new(nil, "ingame_ui_price_tag")

		pt.id = "price_tag"
		pt.pos = V.v(b.size.x / 2 - pt.size.x / 2, b.size.y - pt.size.y / 2)
		pt.text_algin = "center"
		pt.font_name = "numbers_italic"
		pt.font_size = 14.4
		pt.vertical_align = "middle-caps"
		pt.colors.text = {
			255,
			224,
			0
		}
		pt.disabled_tint_color = nil
		pt.propagate_on_click = true
		pt.text = price_tag
		pt.text_offset = V.v(-0.4, -1)
		pt.text_offset = V.v(-0.4, -2)
		self.price_tag = pt

		self:add_child(pt)
	end

	local ufx = KImageView:new("effect_powerbuy_0001")

	ufx.animation = {
		hide_at_end = true,
		prefix = "effect_powerbuy",
		from = 1,
		to = 12
	}
	ufx.pos = V.v(-8, -20)
	ufx.hidden = true
	ufx.propagate_on_click = true
	self.ufx = ufx

	self:add_child(ufx)

	self.size = V.vclone(b.size)
end

function TowerMenuButton:enable()
	self.click_disabled = false

	if self.check then
		self.check:set_image(self.check_image)
	end

	self.button:set_image(self.item_image)

	if self.price_tag then
		self.price_tag:set_image("ingame_ui_price_tag")

		self.price_tag.colors.text = {
			255,
			224,
			0
		}
	end
end

function TowerMenuButton:disable()
	self.click_disabled = true

	if self.item.action ~= "tw_change_mode" and self.item.action ~= "tw_swap_mode" and self.item.action ~= "tw_combination" then
		if self.check then
			self.check:set_image(self.check_image .. "_disabled")
		end

		self.button:set_image(self.item_image .. "_disabled")

		if self.price_tag then
			self.price_tag.colors.text = {
				153,
				144,
				129
			}
		end
	end
end

function TowerMenuButton:on_keypressed(key)
	if key == "return" then
		self:on_click()

		return true
	end
end

function TowerMenuButton:select()
	self.parent.selected_button = self

	if self.check then
		self.check.hidden = false

		if (IS_KR3 or not IS_TRILOGY) and self.item.action == "upgrade_power" then
			self.button.hidden = true
		end
	end

	local item = self.item
	local entity = self.entity

	log.debug("TowerMenuButton action:%s  action_arg:%s", item.action, item.action_arg)

	if item.action == "tw_upgrade" then
		local nt

		if item.preview then
			local tb = E:get_template(item.action_arg)

			nt = E:get_template(tb.build_name)
		else
			nt = E:get_template(item.action_arg)
		end

		local ux, uy = game_gui:w2u(V.v(V.add(entity.pos.x, entity.pos.y, entity.tower.range_offset.x, entity.tower.range_offset.y)))

		if nt and nt.attacks and nt.attacks.range then
			local new_range = nt.attacks.range

			game_gui:show_tower_range("upgrade", entity, new_range)
		elseif nt.barrack and nt.barrack.rally_range then
			if nt.barrack.range_upgradable or item.preview then
				game_gui:show_tower_range("rally_upgrade", entity, nt.barrack.rally_range)
			else
				game_gui:show_tower_range("rally", entity, nt.barrack.rally_range)
			end
		end
	elseif item.action == "upgrade_power" then
		if entity.powers then
			local power = entity.powers[item.action_arg]

			if power.level == power.max_level then
				if TOWERMENU_SHOW_TOOLTIP_ON_MAXED_POWER then
					if self.check then
						self.check.hidden = true
					end

					self.button.hidden = nil

					wid("tower_menu_tooltip"):show(entity, item)
					S:queue("GUIQuickMenuOver")
				else
					game_gui:c_deselect()
				end

				return
			end
		end
	elseif item.action == "tw_repair" and entity.repair.active and not TOWERMENU_SHOW_TOOLTIP_ON_MAXED_POWER then
		game_gui:c_deselect()

		return
	end

	if item.preview then
		local preview_ids = entity.tower_holder.preview_ids
		local preview_id = preview_ids[item.preview]

		entity.render.sprites[preview_id].hidden = false
	end

	wid("tower_menu_tooltip"):show(entity, item)
	S:queue("GUIQuickMenuOver")

	if entity.ui then
		entity.ui.hover_active = true
		entity.ui.args = item.action_arg
	end
end

function TowerMenuButton:deselect()
	if self.parent then
		self.parent.selected_button = nil
	end

	if self.check then
		self.check.hidden = true

		if (IS_KR3 or not IS_TRILOGY) and self.item.action == "upgrade_power" then
			self.button.hidden = nil
		end
	end

	local item = self.item
	local entity = self.entity

	game_gui:hide_tower_range("upgrade")
	game_gui:hide_tower_range("rally_upgrade")
	wid("tower_menu_tooltip"):hide()

	if item.preview then
		local preview_ids = entity.tower_holder.preview_ids

		for _, id in pairs(preview_ids) do
			entity.render.sprites[id].hidden = true
		end
	end

	if entity.ui then
		entity.ui.hover_active = nil
		entity.ui.args = nil
	end
end

function TowerMenuButton:confirm()
	self:disable()

	local inhibit_sounds = false
	local item = self.item
	local e = self.entity
	local new_mode

	if IS_MOBILE or item.action ~= "upgrade_power" then
		self.parent.selected_button = nil
	end

	if item.action == "tw_rally" then
		game_gui:set_mode(GUI_MODE_RALLY_TOWER)
		self.parent:hide()
		game_gui:show_tower_range("rally", e, e.barrack.rally_range)
	elseif item.action == "tw_point" then
		if e.user_selection then
			e.user_selection.in_progress = true
			e.user_selection.new_pos = nil
		end

		game_gui:set_mode(GUI_MODE_SELECT_POINT)

		local ux, uy = game_gui:w2u(e.pos)

		self.parent:hide()
	elseif item.action == "tw_upgrade" or item.action == "tw_unblock" then
		e.tower.upgrade_to = item.action_arg

		signal.emit("tower-built")
		game_gui.c_deselect()
	elseif item.action == "tw_prevent_timed_destroy" then
		local store = game_gui.game.store

		if store.player_gold >= e.tower._prevent_timed_destroy_price then
			e.tower._prevent_timed_destroy = true
			store.player_gold = store.player_gold - e.tower._prevent_timed_destroy_price

			game_gui.c_deselect()
		end
	elseif item.action == "upgrade_power" then
		local power = e.powers[item.action_arg]

		if power.level < power.max_level then
			power.level = power.level + 1
			power.changed = true

			if not item.no_upgrade_lights then
				for i, pv in ipairs(self.power_buttons) do
					if i == power.level then
						pv:set_image("ingame_ui_power_rank_0001")
					end
				end

				self.ufx.hidden = false
				self.ufx.ts = 0
			end

			local store = game_gui.game.store
			local spent = power.price[power.level]

			store.player_gold = store.player_gold - spent
			e.tower.spent = e.tower.spent + spent

			local upg = UP:get_upgrade("towers_favorite_customer")

			if upg and power.level == #power.price then
				local factor = upg.refund_cost_factor

				if power.level < 3 then
					factor = upg.refund_cost_factor_one_level
				end

				local refund = math.floor(power.price[power.level] * factor)

				store.player_gold = store.player_gold + refund
				e.tower.spent = e.tower.spent - refund

				S:queue("UpgradeFavoriteCustomer")
			end
			
			if power.disappear_on_upgrade then
				game_gui.c_deselect()
			end

			if IS_MOBILE then
				self:deselect()
			else
				wid("tower_menu_tooltip"):show(e, item)
			end

			if power.show_rally then
				e.tower.show_rally = true
			end

			signal.emit("tower-power-upgraded", e, power)
		else
			inhibit_sounds = true
		end
	elseif item.action == "tw_sell" then
		e.tower.sell = true

		game_gui.c_deselect()
	elseif item.action == "tw_buy_soldier" then
		e.barrack.unit_bought = item.action_arg

		game_gui.c_deselect()
	elseif item.action == "tw_buy_attack" then
		if e.user_selection then
			if e.user_selection.ignore_point then
				e.user_selection.arg = item.action_arg

				game_gui.c_deselect()
			else
				e.user_selection.in_progress = true
				e.user_selection.arg = item.action_arg
				e.user_selection.new_pos = nil

				game_gui:set_mode(GUI_MODE_SELECT_POINT)
				self.parent:hide()
			end
		end
	elseif item.action == "tw_change_mode" then
		if e.tower and not e.tower_upgrade_persistent_data.preparing then
			e.change_mode = true

			game_gui.c_deselect()

			new_mode = e.tower_upgrade_persistent_data.current_mode == 0 and 1 or 0
		end

		self.parent:hide()
	elseif item.action == "tw_free_action" then
		if e.user_selection then
			e.user_selection.in_progress = true
			e.user_selection.arg = item.action_arg
			e.user_selection.new_pos = nil
		end

		self.parent:hide()
	elseif item.action == "tw_swap_mode" then
		if e.tower then
			e.change_mode = true

			game_gui.c_deselect()

			new_mode = e.tower_upgrade_persistent_data.current_mode == 0 and 1 or 0
		end

		game_gui.swap_entity = e

		game_gui:set_mode(GUI_MODE_SWAP_TOWER)
		game_gui:show_ghost_hover()

		local ux, uy = game_gui:w2u(e.pos)

		self.parent:hide()
	elseif item.action == "tw_combination" then
		if e.tower then
			e.change_mode = true
			game_gui.c_deselect()
			new_mode = e.tower_upgrade_persistent_data.current_mode == 0 and 1 or 0
		end
		game_gui.swap_entity = e
		game_gui:set_mode(GUI_MODE_TOWER_COMBINATION)
		game_gui:show_decal_preview(e)
		self.parent:hide()
	elseif item.action == "tw_repair" then
		if e.user_selection then
			e.user_selection.in_progress = true
		end

		game_gui.c_deselect()
	end

	if item.sounds and not inhibit_sounds then
		if item.action == "tw_change_mode" and #item.sounds > 1 and new_mode then
			S:queue(item.sounds[new_mode + 1])
		else
			for _, sid in pairs(item.sounds) do
				S:queue(sid)
			end
		end
	end
end

function TowerMenuButton:update(dt)
	TowerMenuButton.super.update(self, dt)

	local store = game_gui.game.store
	local e = self.entity
	local item = self.item
	local is_unselected = self.parent and self.parent.selected_button and self.parent.selected_button ~= self

	if item.dynamic_rally then
		if e.tower and e.tower.show_rally then
			self.hidden = false
		else
			self.hidden = true

			return
		end
	end

	if self.item_props.action == "tw_point" and e and e.user_selection then
		if not e.user_selection.allowed then
			self:disable()
		else
			self:enable()
		end
	elseif e and self.item_props.action == "tw_upgrade" then
		local nt = E:get_template(self.item_props.action_arg)

		if nt.build_name then
			nt = E:get_template(nt.build_name)
		end

		if nt.tower.price > store.player_gold then
			self:disable()
		else
			self:enable()
		end
	elseif e and self.item_props.action == "tw_unblock" then
		if e.tower_holder.unblock_price > store.player_gold then
			self:disable()
		else
			self:enable()
		end
	elseif e and self.item_props.action == "tw_prevent_timed_destroy" then
		if e.tower._prevent_timed_destroy_price > store.player_gold then
			self:disable()
		else
			self:enable()
		end
	elseif e and self.item_props.action == "upgrade_power" then
		local power = e.powers[self.item_props.action_arg]
		local price = power.level < #power.price and power.price[power.level + 1] or nil
		local max_level = power.level >= #power.price

		if not max_level and price > store.player_gold then
			self:disable()
		else
			self:enable()

			self.click_disabled = max_level
		end

		local pt = self:get_child_by_id("price_tag")

		if pt then
			pt.text = tostring(price)
			pt.hidden = max_level
		end
	elseif e and self.item_props.action == "tw_buy_soldier" then
		local nt = E:get_template(self.item_props.action_arg)
		local price = nt.unit.price

		if type(price) == "table" then
			price = price[km.clamp(1, #nt.unit.price, e.barrack.max_soldiers + 1)]

			if price > store.player_gold or e.barrack.max_soldiers >= #nt.unit.price then
				self:disable()
			else
				self:enable()
			end
		elseif price > store.player_gold or #e.barrack.soldiers >= e.barrack.max_soldiers then
			self:disable()
		else
			self:enable()
		end

		local pt = self:get_child_by_id("price_tag")

		if pt then
			pt.text = tostring(price)
			pt.hidden = false
		end
	elseif e and self.item_props.action == "tw_buy_attack" then
		local price = e.attacks.list[self.item_props.action_arg].price

		if price > store.player_gold or e.user_selection and not e.user_selection.allowed then
			self:disable()
		else
			self:enable()
		end

		local pt = self:get_child_by_id("price_tag")

		if pt then
			pt.text = tostring(price)
			pt.hidden = false
		end
	elseif e and self.item_props.action == "tw_free_action" then
		if not e.user_selection.allowed then
			self:disable()
		else
			self:enable()
		end
	elseif e and self.item_props.action == "tw_change_mode" then
		if e.tower_upgrade_persistent_data.current_mode == 0 then
			if self.item_image == "quickmenu_action_icons_0001" then
				self.button:set_image("quickmenu_action_icons_0002")
			elseif self.item_image == "quickmenu_action_icons_0006" then
				self.button:set_image("quickmenu_action_icons_0005")
			elseif self.item_image == "quickmenu_action_icons_0007" then
				self.button:set_image("quickmenu_action_icons_0008")
			end
		elseif self.item_image == "quickmenu_action_icons_0002" then
			self.button:set_image("quickmenu_action_icons_0001")
		elseif self.item_image == "quickmenu_action_icons_0005" then
			self.button:set_image("quickmenu_action_icons_0006")
		elseif self.item_image == "quickmenu_action_icons_0008" then
			self.button:set_image("quickmenu_action_icons_0007")
		end
	elseif e and self.item_props.action == "tw_repair" then
		local price = e.repair.cost

		if price > store.player_gold then
			self:disable()
		else
			self:enable()

			self.click_disabled = e.repair.active
		end

		local pt = self:get_child_by_id("price_tag")

		if pt then
			pt.text = tostring(price)
			pt.hidden = false
		end
	end

	if IS_KR5 and is_unselected then
		if item.action == "upgrade_power" and e.powers then
			local power = e.powers[item.action_arg]

			if power.level == power.max_level then
				self.button:set_image(self.item_image .. "_turn_off")

				return
			end
		end

		if item.action ~= "tw_change_mode" and item.action ~= "tw_swap_mode" and item.action ~= "tw_combination" then
			if self.click_disabled then
				self.button:set_image(self.item_image .. "_disabled_turn_off")
			else
				self.button:set_image(self.item_image .. "_turn_off")
			end
		end
	end
end

function TowerMenuButton:on_enter()
	if self.image_halo and ISM.last_input ~= I_TOUCH then
		self.image_halo.hidden = false
	end

	if not IS_MOBILE then
		self:deselect()
		self:select()
	end
end

function TowerMenuButton:on_exit()
	if self.image_halo then
		self.image_halo.hidden = true
	end

	self.scale.x, self.scale.y = 1, 1

	if not IS_MOBILE then
		self:deselect()
	end
end

function TowerMenuButton:on_focus()
	self:on_enter()
end

function TowerMenuButton:on_defocus()
	self:on_exit()
end

function TowerMenuButton:on_down(button, x, y)
	GG5Button.static.down_bounce_ani(self)
end

function TowerMenuButton:on_up(button, x, y)
	GG5Button.static.up_bounce_ani(self)
end

function TowerMenuButton:on_click()
	if not self.parent then
		return
	end

	if self.parent.tweening then
		return
	end

	local sb = self.parent.selected_button
	local action = self.item_props.action
	local e = self.entity

	if action == "tw_rally" or action == "tw_point" or action == "tw_swap_mode" then
		if sb then
			sb:deselect()
		end

		if e and e.user_selection and not e.user_selection.allowed then
			return
		end

		self:confirm()
	elseif not sb then
		self:select()
	elseif sb == self and not self.click_disabled then
		self:confirm()
	else
		sb:deselect()
		self:select()
	end
end

TowerMenuTooltip = class("TowerMenuTooltip", KView)

function TowerMenuTooltip:show(entity, item)
	self.hidden = false
	self.entity = entity
	self.wide = true

	balance = nil
	balance = require("balance/balance")
	for _, v in pairs(self:ci("bottom_views").children) do
		v.hidden = true
	end

	local has_bottom_view = false

	if item.action == "tw_upgrade" then
		self:ci("title").text = item.tt_title or GU.balance_format(_(item.action_arg), balance)
		self:ci("desc").text = GU.balance_format(item.tt_desc, balance) or ""

		local te

		if entity.tower_holder then
			te = E:get_template(item.action_arg)

			if te and te.build_name then
				te = E:get_template(te.build_name)
			end
		else
			te = E:get_template(item.action_arg)
			self.wide = false
		end

		local stats = te.info.fn(te)

		if stats.type == STATS_TYPE_TOWER_BARRACK then
			local b = self:ci("bottom_type_barrack")

			b.hidden = false
			has_bottom_view = true
			b:ci("health").text = stats.hp_max

			local dl = b:ci("damage")

			dl.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

			dl:set_image("tooltip_icons_0007", V.v(dl.size.x, dl.size.y))

			b:ci("armor").text = GU.armor_value_desc(stats.armor)
		elseif stats.type == STATS_TYPE_TOWER or stats.type == STATS_TYPE_TOWER_MAGE then
			local b = self:ci("bottom_type_tower")

			b.hidden = false
			has_bottom_view = true

			local dl = b:ci("damage")

			dl.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

			dl:set_image(stats.type == STATS_TYPE_TOWER_MAGE and "tooltip_icons_0010" or "tooltip_icons_0007", V.v(dl.size.x, dl.size.y))

			b:ci("cooldown").text = GU.cooldown_value_desc(stats.cooldown)
		end
	elseif item.action == "upgrade_power" then
		local power = entity.powers[item.action_arg]

		if power.level == power.max_level and not TOWERMENU_SHOW_TOOLTIP_ON_MAXED_POWER then
			self.hidden = true
		else
			local show_level = km.clamp(1, #item.tt_list, power.level + 1)
			local texts = item.tt_list[show_level]

			self:ci("title").text = texts.tt_title
			self:ci("desc").text = GU.balance_format(texts.tt_desc, balance)

			if item.tt_phrase then
				local b = self:ci("bottom_type_phrase")

				b.hidden = false
				has_bottom_view = true
				b:ci("phrase").text = item.tt_phrase
			end
		end
	elseif item.action == "tw_buy_soldier" then
		self.wide = false

		if item.tt_list then
			local texts = item.tt_list[km.clamp(1, #item.tt_list, entity.barrack.max_soldiers + 1)]

			self:ci("title").text = texts.tt_title
			self:ci("desc").text = GU.balance_format(texts.tt_desc, balance) or ""
		else
			self:ci("title").text = item.tt_title
			self:ci("desc").text = GU.balance_format(item.tt_desc, balance) or ""
		end
	elseif item.action == "tw_buy_attack" or item.action == "tw_unblock" or item.action == "tw_free_action" or item.action == "tw_repair" or item.action == "tw_prevent_timed_destroy" then
		self.wide = false
		self:ci("title").text = item.tt_title
		self:ci("desc").text = GU.balance_format(item.tt_desc, balance) or ""
	elseif item.action == "tw_sell" then
		if entity.powers then
			self.wide = true
		end

		self:ci("title").text = _("Sell Tower")

		local refund = game_gui.game.store.wave_group_number == 0 and entity.tower.spent or km.round(entity.tower.refund_factor * entity.tower.spent)

		self:ci("desc").text = string.format(_("Sell this tower and get a %s GP refund."), refund)
	elseif item.action == "tw_change_mode" then
		if entity.powers then
			self.wide = true
		end

		if entity.tower_upgrade_persistent_data.current_mode == 0 then
			self:ci("title").text = item.tt_title_mode1
			if not entity.tower_upgrade_persistent_data.preparing then
				self:ci("desc").text = item.tt_desc_mode1
			else
				self:ci("desc").text = item.tt_desc_mode0
			end
			if item.tt_phrase_mode1 then
				local b = self:ci("bottom_type_phrase")
				b.hidden = false
				has_bottom_view = true
				b:ci("phrase").text = item.tt_phrase_mode1
			end
		else
			self:ci("title").text = item.tt_title_mode0
			if entity.tower_upgrade_persistent_data.preparing == nil or entity.tower_upgrade_persistent_data.preparing then
				self:ci("desc").text = item.tt_desc_mode0
			else
				self:ci("desc").text = item.tt_desc_mode1
			end
			if item.tt_phrase_mode0 then
				local b = self:ci("bottom_type_phrase")
				b.hidden = false
				has_bottom_view = true
				b:ci("phrase").text = item.tt_phrase_mode0
			end
		end
	elseif item.action == "tw_combination" then
		self:ci("title").text = item.tt_title
		self:ci("desc").text = item.tt_desc
	else
		self.hidden = true
	end

	if self.hidden then
		return
	end

	local margin_y = self:ci("title").pos.y - self:ci("title").size.y
	local title_h = self:ci("title").size.y
	local desc_w, desc_l = self:ci("desc"):get_wrap_lines()
	local desc_h = self:ci("desc"):get_font_height() * self:ci("desc").line_height * desc_l
	local bottom_h = 0

	if has_bottom_view then
		if self:ci("bottom_type_phrase").hidden then
			bottom_h = self:ci("bottom_views").size.y
		else
			local phrase_w, phrase_l = self:ci("phrase"):get_wrap_lines()
			local phrase_h = self:ci("phrase"):get_font_height() * self:ci("phrase").line_height * phrase_l
			local one_line = self:ci("phrase"):get_font_height() * self:ci("phrase").line_height

			bottom_h = self:ci("bottom_views").size.y + phrase_h - one_line
		end
	end

	local total_w = self.size.x
	local total_h = title_h + desc_h + bottom_h + 2 * margin_y
	local bg = self:ci("bg")

	if bg.size.y ~= total_h then
		local obg = bg

		self:remove_child(bg)

		bg = GG9SlicesView:new(V.v(total_w, total_h), obg.slices_prefix)
		bg.id = "bg"
		bg.slices_prefix = obg.slices_prefix
		bg.propagate_on_click = obg.propagate_on_click
		bg.propagate_on_down = obg.propagate_on_down
		bg.propagate_on_up = obg.propagate_on_up

		self:add_child(bg, 1)
	end

	self.size.x, self.size.y = bg.size.x, bg.size.y
	self.anchor.x, self.anchor.y = self.size.x / 2, self.size.y / 2
	self:ci("bottom_views").pos.y = self.size.y - bottom_h - margin_y

	if self.tweening and self.tweeners then
		for _, tw in pairs(self.tweeners) do
			timer:cancel(tw)
		end
	end

	self.show_side = nil

	self:update(0)

	self.alpha = 0.1
	self.scale = V.v(game.camera.zoom * 0.7 * self.max_scale, game.camera.zoom * 0.7 * self.max_scale)
	self.tweening = true
	self.tweeners = {
		timer:tween(0.3, self.scale, {
			x = game.camera.zoom * self.max_scale,
			y = game.camera.zoom * self.max_scale
		}, "out-back", function()
			self.tweening = nil
			self.tweeners = {}
		end),
		timer:tween(0.15, self, {
			alpha = 1
		}, "out-quad")
	}
end

function TowerMenuTooltip:hide()
	if self.tweeners then
		for _, tw in pairs(self.tweeners) do
			timer:cancel(tw)
		end
	end

	self.tweening = true
	self.tweeners = {
		timer:tween(0.3, self, {
			alpha = 0
		}, "out-quad", function()
			self.tweening = nil
			self.tweeners = {}
			self.hidden = true
		end)
	}
end

function TowerMenuTooltip:update(dt)
	TowerMenuTooltip.super.update(self, dt)

	if self.entity and not self.hidden then
		local ex, ey = game_gui:w2u(V.v(self.entity.pos.x + self.entity.tower.menu_offset.x, self.entity.pos.y + self.entity.tower.menu_offset.y + 14))

		if not self.tweening then
			self.scale.x = game.camera.zoom * self.max_scale
			self.scale.y = game.camera.zoom * self.max_scale
		end

		local tm = wid("tower_menu")
		local tmw = 0.5 * tm.size.x * tm.max_scale
		local ttw = self.size.x * self.max_scale
		local wide_offset = self.wide and self.wide_offset * self.max_scale or 0

		if not self.show_side then
			self.show_side = ex < game_gui.sw / 2 and "right" or "left"
		end

		if self.show_side == "right" then
			self.pos.x = ex + (tmw + ttw / 2 + wide_offset) * game.camera.zoom
		else
			self.pos.x = ex - (tmw + ttw / 2 + wide_offset) * game.camera.zoom
		end

		self.pos.y = ey
	end
end

IncomingTooltip = class("IncomingTooltip", KView)

function IncomingTooltip:initialize()
	IncomingTooltip.super.initialize(self, V.v(225, 112))

	local title = GGLabel:new(V.v(225, 25))

	title.text = _("INCOMING WAVE")
	title.font_name = "hud"
	title.font_size = 19
	title.text_align = "center"
	title.colors.text = {
		238,
		113,
		46,
		255
	}
	title.propagate_on_click = true

	local report = GGLabel:new(V.v(225, 112))

	report.font_name = "hud"
	report.font_size = 17
	report.text_align = "center"
	report.colors.text = {
		255,
		254,
		250,
		255
	}
	report.propagate_on_click = true

	local phrase = GGLabel:new(V.v(225, 40))

	phrase.font_name = "hud"
	phrase.font_size = 12
	phrase.colors.text = {
		160,
		157,
		155,
		255
	}
	phrase.text = _("WAVE_TOOLTIP_TAP_AGAIN")
	phrase.propagate_on_click = true
	phrase.vertical_align = "bottom"
	title.pos.x, title.pos.y = 0, 10
	report.pos.x, report.pos.y = 0, title.pos.y + title.size.y
	phrase.pos.x, phrase.pos.y = 0, 0

	local bw, bh = 225, self.size.y
	local background = KView:new(V.v(bw, bh))

	background.colors.background = {
		21,
		17,
		13,
		220
	}

	local vertices = GU.rounded_rectangle(0, 0, bw, bh, 5, nil, 1.6)

	background.shape = {
		name = "polygon",
		args = vertices
	}
	background.propagate_on_click = true
	background.anchor = V.v(bw / 2, bh / 2)
	background.pos = V.v(bw / 2, bh / 2)

	self:add_child(background)
	self:add_child(title)
	self:add_child(report)
	self:add_child(phrase)

	self.background = background
	self.title = title
	self.report = report
	self.phrase = phrase
	self.bg_margin = V.v(120, 16)
	self.base_scale = game_gui.base_scale_list.incoming_tooltip
end

function IncomingTooltip:set_report(text)
	local t, r, p = self.title, self.report, self.phrase

	self.report.text = text

	local title_w = t:get_text_width(t.text)
	local report_w = r:get_text_width(text)
	local phrase_w = p:get_text_width(p.text)
	local w = math.max(title_w, report_w, phrase_w)

	r.size.x = w
	t.size.x = w
	p.size.x = w
	self.size.x = w

	local width, lines = r:get_wrap_lines()
	local height = lines * r:get_font_height() * r.line_height

	r.size.y = height
	self.size.y = t.pos.y + t.size.y + height + p.size.y + 10
	p.pos.y = self.size.y - p.size.y - 10
	self.pos.x = self.pos.x - 5

	local bw, bh = self.size.x + self.bg_margin.x, self.size.y + self.bg_margin.y
	local vertices = GU.rounded_rectangle(0, 0, bw, bh, 5, nil, 1.6)

	self.background.shape = {
		name = "polygon",
		args = vertices
	}
	self.background.propagate_on_click = true
	self.background.anchor = V.v(bw / 2, bh / 2)
	self.background.pos = V.v(self.size.x / 2, self.size.y / 2)
end

function IncomingTooltip:show(x, y, r, report, tracking_flag)
	self.tracking_flag = tracking_flag

	self:set_report(report)

	local background = self.background
	local a = km.unroll(r)
	local tip_size = 4.800000000000001
	local wave_flags = wid("layer_wave_flags"):flatten(function(v)
		return v:isInstanceOf(WaveFlag)
	end)
	local wave_flag = #wave_flags > 0 and wave_flags[1]
	local waveflag_size = wave_flag and wave_flag.size.x * (wave_flag.base_scale and wave_flag.base_scale.x or 1) or 0
	local waveflag_radius = 0.6 * (waveflag_size / 2)
	local fwx, fwy = REF_W / 2, REF_H / 2

	if tracking_flag and tracking_flag.world_pos then
		fwx, fwy = tracking_flag.world_pos.x, tracking_flag.world_pos.y
	end

	if fwx > REF_W / 2 then
		background.scale.x = 1
		self.anchor.x = self.size.x + self.bg_margin.x / 2 + tip_size + waveflag_radius
	else
		background.scale.x = -1
		self.anchor.x = 0 - self.bg_margin.x / 2 - tip_size - waveflag_radius
	end

	if fwy > REF_H / 2 then
		background.scale.y = -1
		self.anchor.y = -self.bg_margin.y / 2 - tip_size - waveflag_radius
	else
		background.scale.y = 1
		self.anchor.y = self.size.y + self.bg_margin.y / 2 + tip_size + waveflag_radius
	end

	self.pos.x, self.pos.y = x, y

	if self.timer then
		timer:cancel(self.timer)
	end

	self.hidden = false
	self.alpha = 0
	self.timer = timer:tween(0.25, self, {
		alpha = 1
	}, "out-quad")
end

function IncomingTooltip:hide()
	if not self.hidden then
		if self.timer then
			timer:cancel(self.timer)
		end

		self.timer = timer:tween(0.25, self, {
			alpha = 0
		}, "out-quad", function()
			self.hidden = true
		end)
	end

	self.tracking_flag = nil
end

function IncomingTooltip:update(dt)
	if not self.hidden then
		if game_gui.mode ~= GUI_MODE_IDLE and game_gui.mode ~= GUI_MODE_WAVE_FLAG then
			self.hidden = true
			self.tracking_flag = nil
		elseif self.tracking_flag then
			local f = self.tracking_flag

			self.pos.x, self.pos.y = f.pos.x, f.pos.y
		end

		self.scale.x = game.camera.zoom
		self.scale.y = game.camera.zoom
	end
end

WaveFlag = class("WaveFlag", KView)

function WaveFlag:initialize(flying, duration, report)
	WaveFlag.super.initialize(self)

	self.duration = duration
	self.report = report
	self.start_game_ts = game_gui.game.store.ts
	self.ts = 0
	self.pulse_animation = true
	self.propagate_on_touch_down = false
	self.propagate_on_touch_up = false
	self.propagate_on_touch_move = false
	self.propagate_on_enter = false

	local halo = KImageView:new("waveFlag_selected")
	local bg_circle = KImageView:new("waveFlag_0003")
	local icon = KImageView:new(flying and "waveFlag_0002" or "waveFlag_0001")
	local pointer = KImageView:new("waveFlag_0004")

	self.size.x, self.size.y = halo.size.x, halo.size.y
	self.anchor.x, self.anchor.y = self.size.x / 2, self.size.y / 2

	for _, v in pairs({
		halo,
		bg_circle,
		icon
	}) do
		v.anchor.x, v.anchor.y = v.size.x / 2, v.size.y / 2
	end

	pointer.anchor.x = -4
	pointer.anchor.y = pointer.size.y / 2

	for _, v in pairs({
		halo,
		bg_circle,
		icon,
		pointer
	}) do
		v.pos.x, v.pos.y = self.size.x / 2, self.size.y / 2
		v.propagate_on_click = true

		self:add_child(v)
	end

	local rect_w, rect_h = icon.size.x * 0.8, icon.size.y * 0.8

	self.hit_rect = {
		pos = V.v(icon.pos.x / 2, icon.pos.y / 2),
		size = V.v(rect_w, rect_h)
	}
	halo.hidden = true
	pointer.r = -math.pi / 2
	bg_circle.phase = 0
	bg_circle.clip = true

	function bg_circle.clip_fn()
		local start_angle = 3 * math.pi / 2
		local stop_angle = 7 * math.pi / 2 - bg_circle.phase * 2 * math.pi

		G.arc("fill", bg_circle.size.x / 2, bg_circle.size.y / 2, bg_circle.size.x / 2, start_angle, stop_angle, 12)
	end

	self.halo = halo
	self.bg_circle = bg_circle
	self.pointer = pointer
	self.base_scale = game_gui.base_scale_list.wave_flag
end

function WaveFlag:update(dt)
	WaveFlag.super.update(self, dt)

	self.pos.x, self.pos.y = game_gui:w2u(self.world_pos)

	if self.pulse_animation then
		local scale = 0.85 + 0.15 * (0.5 * math.sin(2 * math.pi * self.ts * 1.25) + 1)

		self.scale.x, self.scale.y = scale * game.camera.zoom, scale * game.camera.zoom
	end

	if self.duration and self.duration > 0 then
		self.bg_circle.phase = km.clamp(0, 1, (self.duration - (game_gui.game.store.ts - self.start_game_ts)) / self.duration)
	end

	if not self.clicked and not self.hide_timer then
		if game_gui.mode == GUI_MODE_IDLE or game_gui.mode == GUI_MODE_WAVE_FLAG then
			self:enable()

			self.alpha = 1
		else
			self:disable()

			self.alpha = 0.2
		end
	end
end

function WaveFlag:remove_with_animation()
	self.pulse_animation = false

	if not self.hide_timer then
		self.hide_timer = timer:tween(0.5, self, {
			alpha = 0,
			scale = {
				x = 1.5,
				y = 1.5
			}
		}, "out-quad", function()
			self.hidden = true

			self:remove_from_parent()
		end)
	end

	if self.alert_view then
		self.alert_view:remove()
	end

	if self.marching_ants then
		self.marching_ants.done = true
		self.marching_ants = nil
	end
end

function WaveFlag:on_focus()
	self:select()
end

function WaveFlag:on_defocus()
	self:deselect()
end

function WaveFlag:on_keypressed(key, is_repeat)
	if key == "return" then
		self:on_click()

		return true
	end
end

function WaveFlag:select_show_tooltip()
	S:queue("GUIQuickMenuOver")

	self.selected = true
	self.halo.hidden = false

	wid("incoming_tooltip"):show(self.pos.x, self.pos.y, self.pointer.r + math.pi / 2, self.report, self)

	if self.marching_ants then
		self.marching_ants.done = true
		self.marching_ants = nil
	end

	self.marching_ants = E:create_entity("path_marching_ants_controller")
	self.marching_ants.pi = self.path_index

	game_gui.game.simulation:insert_entity(self.marching_ants)
end

function WaveFlag:select()
	if not IS_MOBILE then
		self:select_show_tooltip()
	end
end

function WaveFlag:deselect()
	self.selected = false
	self.halo.hidden = true

	wid("incoming_tooltip"):hide()

	if self.marching_ants then
		self.marching_ants.done = true
		self.marching_ants = nil
	end
end

function WaveFlag:on_click()
	if self.selected then
		log.debug(">>> sending next wave...")
		self:disable()

		self.clicked = true
		game_gui.game.store.send_next_wave = true

		game_gui.c_deselect()
	else
		game_gui.c_deselect()
		game_gui:set_mode(GUI_MODE_WAVE_FLAG)

		if IS_MOBILE then
			self:select_show_tooltip()
		end
	end
end

function WaveFlag:on_enter()
	self:select()
end

function WaveFlag:on_exit()
	if not IS_MOBILE then
		self:deselect()
	end
end

WorldImageView = class("WorldImageView", KImageView)

function WorldImageView:update(dt)
	WorldImageView.super.update(self, dt)

	if not self.hidden and self.wx and self.wy then
		self.pos.x, self.pos.y = game_gui:w2u(V.v(self.wx, self.wy))
	end
end

VictoryParticles = class("VictoryParticles", KView)

function VictoryParticles:initialize(w, h)
	VictoryParticles.super.initialize(self)

	local ss = I:s("victoryStars_star_0001")
	local p_scale = ss.ref_scale or 1
	local c = G.newCanvas(ss.size[1], ss.size[2])

	G.setCanvas(c)
	G.draw(I:i(ss.atlas), ss.quad, ss.trim[1], ss.trim[2])
	G.setCanvas()

	local ps = G.newParticleSystem(c, 500)

	ps:setDirection(-math.pi / 2)
	ps:setSpread(2 * math.pi / 3)
	ps:setSizes(1 * p_scale, 1.4 * p_scale)
	ps:setLinearAcceleration(0, 2000)
	ps:setParticleLifetime(0, 1.5)
	ps:setSpeed(400, 1000)
	ps:setRadialAcceleration(-200)
	ps:setColors(255, 255, 255, 255, 255, 255, 255, 0)
	ps:emit(150)

	self.ps = ps
	self.ss = ss
end

function VictoryParticles:update(dt)
	VictoryParticles.super.update(self, dt)
	self.ps:update(dt)
end

function VictoryParticles:draw()
	G.setBlendMode("add")
	G.draw(self.ps, 0, 0)
	G.setBlendMode("alpha")
	VictoryParticles.super.draw(self)
end

NotificationIcon = class("NotificationIcon", KImageView)

function NotificationIcon:initialize(image, notification_id, layout)
	NotificationIcon.super.initialize(self, image)

	self.anchor = V.v(self.size.x / 2, self.size.y / 2)
	self.notification_id = notification_id

	table.insert(self.children, KImageView:new("notification_enemies_exclamacion_0001"))
	self:show()
end

function NotificationIcon:loop_tween()
	local s = self.scale.x > 1 and 0.985 or 1.015

	timer:tween(0.3, self.scale, {
		x = s,
		y = s
	}, "in-out-sine", function()
		self:loop_tween()
	end)
end

function NotificationIcon:on_click()
	game_gui.c_show_noti({
		force = true,
		id = self.notification_id
	})
	self:remove()
end

function NotificationIcon:show()
	S:queue("GUINotificationSecondLevel")
	timer:tween(0.3, self, {
		alpha = 1
	}, "in-quad")

	self.scale.x, self.scale.y = 0.8, 0.8

	self:loop_tween()
end

function NotificationIcon:remove()
	self:disable(false)

	local s = 0.4

	timer:tween(0.4, self.scale, {
		x = s,
		y = s
	}, "in-back", function()
		if self.parent then
			self.parent:remove_icon(self)
		end
	end)
	timer:tween(0.4, self, {
		alpha = 0
	})
end

function NotificationIcon:on_keypressed(key, is_repeat)
	if key == "return" then
		self:on_click()

		return true
	end
end

NotificationView = class("NotificationView", KView)

function NotificationView:show(no_transition)
	local n = self.notification

	local function hide_fn(this)
		this:disable(false)
		game_gui.c_hide_noti({
			view = self
		})
	end

	local function next_fn(this)
		this:disable(false)
		game_gui.c_hide_noti({
			view = self,
			show_next = n.next
		})
	end

	if self:ci("ok_button") then
		self:ci("ok_button").on_click = hide_fn
	end

	if self:ci("continue_button") then
		self:ci("continue_button").on_click = next_fn
	end

	if self:ci("skip_button") then
		self:ci("skip_button").on_click = hide_fn
	end

	if self:ci("gotit_button") then
		self:ci("gotit_button").on_click = hide_fn
	end

	if self:ci("button_notification_done") then
		self:ci("button_notification_done").on_click = hide_fn
	end

	if self:ci("button_done") then
		self:ci("button_done").on_click = hide_fn
	end

	if n.template == "enemy" then
		self:ci("label_enemy_desc_title").text = _(string.upper(n.id) .. "_NAME")
		self:ci("label_enemy_desc_body").text = _(string.upper(n.id) .. "_DESCRIPTION")
		self:ci("label_enemy_desc_bullets").text = _(string.upper(n.id) .. "_EXTRA")

		self:ci("ingame_notifications_image_enemy_polaroid"):set_image(n.image)
	end

	self.animated_parts = {
		"title_bg",
		"label_title_enemy",
		"label_title_hint",
		"label_title_new_tip",
		"label_title_glare",
		"polaroid",
		"button_done"
	}

	for _, n in pairs(self.animated_parts) do
		if string.starts(n, "label_title") then
			local lt = self:ci(n)

			if lt then
				lt.anchor.x = lt.size.x / 2
				lt.pos.x = lt.pos.x + lt.size.x / 2
			end
		end
	end

	local ol = wid("modal_bg_transparent_view")

	ktw:cancel(ol)

	ol.hidden = false
	ol.alpha = 0

	ktw:tween(ol, 0.3, ol, {
		alpha = 1
	})

	self.alpha = 0

	ktw:cancel(self)
	ktw:after(self, 0.1, function()
		self.hidden = false

		if no_transition then
			self.alpha = 1
			self.scale = V.v(1, 1)
		else
			local bounciness = 3

			self.alpha = 0

			ktw:tween(self, 0.4, self, {
				alpha = 1
			}, "out-quad")

			self.scale.x = 1
			self.scale.y = 0.7

			ktw:tween(self, 0.4, self.scale, {
				x = 1,
				y = 1
			}, "out-back", nil, bounciness)

			local delay = 0.1
			local delay_inc = 0.1

			for _, n in pairs(self.animated_parts) do
				local v = self:ci(n)

				if v then
					ktw:cancel(v)

					v.scale.x = 0.8
					v.scale.y = 0.8
					v.alpha = 0

					ktw:after(v, delay, function()
						ktw:tween(v, 0.38, v.scale, {
							x = 1,
							y = 1
						}, "out-back", nil, bounciness)
						ktw:tween(v, 0.15, v, {
							alpha = 1
						}, "out-quad")
					end)

					delay = delay + delay_inc
				end
			end
		end

		self:get_window():set_responder(self)
		self:get_window():keypressed("tab")
		S:queue("GUINotificationOpen")
		signal.emit("notification-shown", n)

		if n.signals then
			for _, s in pairs(n.signals) do
				signal.emit(unpack(s))
			end
		end
	end)
end

function NotificationView:hide()
	if not self:get_window() then
		log.error("ERROR NotificationView hide() with no window")

		return
	end

	self:get_window():set_responder()
	signal.emit("notification-close", self.notification)
	S:queue("GUINotificationClose")

	local ol = wid("modal_bg_transparent_view")

	ktw:cancel(ol)

	ol.hidden = false

	ktw:tween(ol, 0.2, ol, {
		alpha = 0
	}, "linear", function()
		ol.hidden = true
	end)

	self.alpha = 1

	ktw:cancel(self)

	self.alpha = 1

	ktw:after(self, 0.1, function()
		ktw:tween(self, 0.25, self.scale, {
			y = 0.7
		}, "in-back")
		ktw:tween(self, 0.25, self, {
			alpha = 0
		}, "in-quad", function()
			self:remove_from_parent()
		end)
	end)

	local delay = 0
	local delay_inc = 0.05

	for _, n in pairs(table.reverse(self.animated_parts)) do
		local v = self:ci(n)

		if v then
			ktw:cancel(v)
			ktw:after(v, delay, function()
				ktw:tween(v, 0.3, v.scale, {
					x = 0.8,
					y = 0.8
				}, "in-back")
				ktw:tween(v, 0.1, v, {
					alpha = 0
				}, "in-quad")
			end)

			delay = delay + delay_inc
		end
	end
end

TextBalloon = class("TextBalloon", GG5BalloonView)

function TextBalloon:initialize(id)
	local bd = data.text_balloons[id]

	if not bd then
		log.error("Balloon with id:%s not found", id)

		return
	end

	local max_size = bd.size
	local prefix = bd.prefix or "balloon_map_slices"
	local flags = bd.flags
	local text = _(bd.text)
	local title = bd.title and _(bd.title) or nil
	local text_padding = bd.padding
	local text_separation
	local bg_color = bd.bg_color
	local text_color = bd.text_color
	local line_color = bd.line_color

	GG5BalloonView.initialize(self, max_size, prefix, flags, text, title, text_padding, text_separation, bg_color, text_color, line_color)

	self.id = id
	self.propagate_on_click = true
	self.propagate_on_down = true
	self.propagate_on_up = true
	self.balloon_on_hide = bd.balloon

	local function mf(t)
		return string.find(flags, t, 1, true) ~= nil
	end

	local ox, oy = 0, 0
	local x, y, w, h = 0, 0, game_gui.sw, game_gui.sh
	local mid = string.match(bd.origin, "id:([%w_]+):")

	if mid and wid(mid) and mf("add_as_child") then
		self.add_as_child = true

		wid(mid):add_child(self)

		x, y, w, h = 0, 0, wid(mid).size.x, wid(mid).size.y
	elseif mid and wid(mid) then
		local p = wid(mid)
		local px, py = p:view_to_view(0, 0, wid("layer_gui_hud"))
		local px1, py1 = p:view_to_view(1, 1, wid("layer_gui_hud"))
		local sx, sy = px1 - px, py1 - py

		x, y, w, h = px, py, px + p.size.x, py + p.size.y
	elseif string.match(bd.origin, "world") then
		local vc = game_gui.game.store.visible_coords

		x, y, w, h = vc.left, vc.top, vc.right, vc.bottom
	else
		local sf = game_gui.safe_frame

		x, y, w, h = sf.l, sf.t, w - sf.r, h - sf.b
	end

	self.show_time = bd.time
	self.scale_world = bd.scale_world

	local bs = game_gui.base_scale_list.balloon_world

	self.original_scale = {}
	self.original_scale.x = self.scale.x
	self.original_scale.y = self.scale.y

	if string.match(bd.origin, "top") then
		oy = y
	end

	if string.match(bd.origin, "bottom") then
		oy = h
	end

	if string.match(bd.origin, "left") then
		ox = x
	end

	if string.match(bd.origin, "right") then
		ox = w
	end

	if string.match(bd.origin, "center") then
		ox = (x + w) / 2
	end

	if string.match(bd.origin, "middle") then
		oy = (y + h) / 2
	end

	if string.match(bd.origin, "world") then
		self.world_pos = V.v(ox + bd.offset.x, oy + bd.offset.y)

		if string.match(bd.origin, "safe") then
			if string.match(bd.origin, "top") then
				self.world_pos.y = self.world_pos.y - game_gui.safe_frame.t
			elseif string.match(bd.origin, "bottom") then
				self.world_pos.y = self.world_pos.y + game_gui.safe_frame.b
			elseif string.match(bd.origin, "left") then
				self.world_pos.x = self.world_pos.x + game_gui.safe_frame.l
			elseif string.match(bd.origin, "right") then
				self.world_pos.x = self.world_pos.x - game_gui.safe_frame.r
			end
		end
	else
		self.pos.x, self.pos.y = ox + bd.offset.x, oy + bd.offset.y
	end

	self.sig_handles = {}

	local function sig_reg(name, fn)
		local hh = signal.register(name, fn)

		table.insert(self.sig_handles, {
			name,
			hh
		})
	end

	self.hide_cond = bd.hide_cond

	if self.hide_cond == "tower_built" then
		sig_reg("tower-built", function()
			self:remove(false)
		end)
		sig_reg("tower-menu-showing", function()
			self:hide()
		end)
		sig_reg("tower-menu-hiding", function()
			self:show()
		end)
	elseif self.hide_cond == "tap_twice" then
		sig_reg("tower-built", function()
			self:remove(false)
		end)
		sig_reg("tower-menu-showing", function()
			self:show()
		end)
		sig_reg("tower-menu-hiding", function()
			self:hide()
		end)
	elseif self.hide_cond == "power_selected_1" then
		sig_reg("power-selected", function(mode)
			if mode == GUI_MODE_POWER_1 then
				self:remove(true)
			end
		end)
	elseif self.hide_cond == "power_selected_2" then
		sig_reg("power-selected", function(mode)
			if mode == GUI_MODE_POWER_2 then
				self:remove(true)
			end
		end)
	elseif self.hide_cond == "power_selected_3" then
		sig_reg("power-selected", function(mode)
			if mode == GUI_MODE_POWER_3 then
				self:remove(true)
			end
		end)
	elseif self.hide_cond == "power_used" then
		sig_reg("power-used", function()
			self:remove(true)
		end)
		sig_reg("power-deselected", function()
			self:remove(true)
		end)
	elseif self.hide_cond == "noti_shown" then
		sig_reg("notification-shown", function()
			self:remove(true)
		end)
	elseif self.hide_cond == "wave_sent" then
		sig_reg("next-wave-sent", function()
			self:remove(true)
		end)
	elseif self.hide_cond == "custom_event_wait" then
		sig_reg("turn-off-balloon", function()
			self:remove(true)
		end)
	end

	sig_reg("game-defeat", function()
		self:remove(false)
	end)
	sig_reg("game-victory", function()
		self:remove(false)
	end)
	sig_reg("hide-gui", function()
		self:remove(false)
	end)

	self.make_animation = true

	if mf("dialog") then
		self.make_animation = false
	end

	self.hidden = true

	self:show()
end

function TextBalloon:show(keep_ts)
	log.debug("TextBalloon:show id:%s", self.id)

	if self.remove_requested then
		return
	end

	if not self.hidden then
		return
	end

	self.hidden = false

	if not keep_ts then
		self.show_ts = game_gui.game.store.tick_ts
	end

	if self.make_animation then
		self.scale = V.v(self.original_scale.x * 0.7, self.original_scale.y * 0.7)
		self.alpha = 0

		ktw:cancel(self)
		ktw:tween(self, 0.2, self, {
			alpha = 1,
			scale = {
				x = self.original_scale.x,
				y = self.original_scale.y
			}
		}, "in-quad", function()
			self:loop_tween()
		end)
	end
end

function TextBalloon:remove(animated)
	log.debug("TextBalloon:remove animated:%s, id:%s, parent:%s", animated, self.id, self.parent)

	for _, h in pairs(self.sig_handles) do
		local name, fn = unpack(h)

		signal.remove(name, fn)
	end

	self.remove_requested = true

	ktw:cancel(self)

	if animated then
		if self.balloon_on_hide then
			game_gui:show_balloon(self.balloon_on_hide)
		end

		local s = 0.4

		ktw:tween(self, 0.4, self, {
			alpha = 0,
			scale = {
				x = s,
				y = s
			}
		}, "in-back", function()
			self:remove_from_parent()
		end)
	else
		self:remove_from_parent()
	end
end

function TextBalloon:hide(not_animated)
	log.debug("TextBalloon:hide %s", self.id)

	if self.remove_requested then
		return
	end

	if self.hidden or not self.parent then
		return
	end

	if not_animated then
		self.hidden = true
	else
		ktw:cancel(self)

		local s = 0.4

		ktw:tween(self, 0.4, self, {
			alpha = 0,
			scale = {
				x = s,
				y = s
			}
		}, "in-back", function()
			self.hidden = true
		end)
	end
end

function TextBalloon:update(dt)
	TextBalloon.super.update(self, dt)

	if self.world_pos then
		self.pos.x, self.pos.y = game_gui:w2u(self.world_pos)

		if self.scale_world then
			local bs = game_gui.base_scale_list.balloon_world

			self.scale.x = game.camera.zoom * bs.x
			self.scale.y = game.camera.zoom * bs.y
		else
			self.scale.x = game.camera.zoom
			self.scale.y = game.camera.zoom
		end
	end

	if self.show_time and not self.remove_requested and game_gui.game.store.tick_ts - self.show_ts > self.show_time then
		self:remove(true)
	end
end

function TextBalloon:loop_tween()
	ktw:cancel(self)

	if self.hidden then
		return
	end

	local s = self.scale.x > self.original_scale.x and self.original_scale.x * 0.98 or self.original_scale.x * 1.02

	ktw:tween(self, 0.3, self.scale, {
		x = s,
		y = s
	}, "in-out-sine", function()
		self:loop_tween()
	end)
end

AlertsView = class("AlertsView", KView)

function AlertsView:update(dt)
	local store = game_gui.game.store

	for _, e in E:filter_iter(store.entities, "enemy") do
		if e.ui and e.health and not e.health.dead and e.enemy.lives_cost ~= 0 and not e.ui.alert_view and P:nodes_to_defend_point(e.nav_path) < ALERT_NODES_TO_DEFEND and e.nav_path.ni < P:get_visible_end_node(e.nav_path.pi) then
			local a = EnemyAlertView:new(e)

			self:add_child(a)

			e.ui.alert_view = a
		end
	end

	AlertsView.super.update(self, dt)
end

function AlertsView.static:get_alert_vector(sx, sy, bs)
	local vis, px, py, rot = false, 0, 0, 0
	local w, h = game_gui.sw, game_gui.sh
	local sf = game_gui.safe_frame
	local is_endless = game_gui.game.store.level_mode == GAME_MODE_ENDLESS
	local margins = {
		l = 25 + sf.l,
		r = 25 + sf.r,
		t = 25 + sf.t,
		b = 25 + sf.b
	}
	local left_min_y, left_max_y = 99.45 * bs.y + sf.t, h - 130 * bs.y - sf.b
	local right_min_y, right_max_y = 78 * bs.y + sf.t, h - 104 * bs.y - sf.b
	local top_min_x, top_max_x = 237.25 * bs.x + sf.l, w - 78 * bs.y - sf.r
	local bottom_min_x, bottom_max_x = 437.45 * bs.x + sf.l, w - 260 * bs.x - sf.r

	if sx < 0 then
		vis = true
		px = margins.l
		py = km.clamp(left_min_y, left_max_y, sy)
	elseif sx < w then
		if sy < 0 then
			px = km.clamp(top_min_x, top_max_x, sx)
			py = margins.t
			vis = true
		elseif sy < h then
			vis = false
		else
			px = km.clamp(bottom_min_x, bottom_max_x, sx)
			py = game_gui.sh - margins.b
			vis = true
		end
	else
		vis = true
		px = game_gui.sw - margins.r
		py = km.clamp(right_min_y, right_max_y, sy)
	end

	rot = -V.angleTo(sx - px, sy - py)

	if game_gui.tutorial.hide_ui then
		vis = false
	end

	return vis, px, py, rot
end

EnemyAlertView = class("EnemyAlertView", KImageView)

function EnemyAlertView:initialize(enemy)
	KImageView.initialize(self, "creepAlert")

	self.enemy = enemy
	self.pointer = KImageView:new("creepAlertArrow")
	self.pointer.anchor = V.v(-self.size.x / 2, self.pointer.size.y / 2)
	self.pointer.pos = V.v(self.size.x / 2, self.size.y / 2)
	self.anchor = V.v(self.size.x / 2, self.size.y / 2)

	self:add_child(self.pointer)
	self:update(0)

	self.propagate_on_touch_up = false
	self.propagate_on_touch_move = false
	self.propagate_on_touch_down = false
	self.propagate_on_down = false
	self.propagate_on_click = false
	self.propagate_on_up = false
	self.propagate_on_enter = false
	self.base_scale = game_gui.base_scale_list.enemy_alert
end

function EnemyAlertView:update(dt)
	local e = self.enemy
	local store = game_gui.game.store

	if not e or e.health.dead or not store.entities[e.id] then
		self:remove()

		return
	end

	local sx, sy = game_gui:w2u(e.pos)

	if P:nodes_to_defend_point(e.nav_path) >= ALERT_NODES_TO_DEFEND or e.nav_path.ni >= P:get_visible_end_node(e.nav_path.pi) then
		self.hidden = true
	else
		local vis, px, py, r = AlertsView:get_alert_vector(sx, sy, self.base_scale)

		self.hidden = not vis
		self.pos.x, self.pos.y = px, py
		self.pointer.r = r
	end
end

function EnemyAlertView:remove()
	self.enemy.ui.alert_view = nil
	self.enemy = nil

	self:remove_from_parent()
end

function EnemyAlertView:on_click()
	if self.enemy and self.enemy.pos then
		local wx, wy = self.enemy.pos.x, self.enemy.pos.y
		local cx, cy = wx * game.game_scale, (game.ref_h - wy) * game.game_scale

		game.camera:tween(timer, 0.4, cx, cy, nil, "in-out-quad")
	end
end

WaveAlertView = class("WaveAlertView", KImageView)

function WaveAlertView:initialize(wave_flag)
	KImageView.initialize(self, "wavealert")

	self.wave_flag = wave_flag
	self.pointer = KImageView:new("wavealert_arrow")
	self.pointer.anchor = V.v(-self.size.x / 2, self.pointer.size.y / 2)
	self.pointer.pos = V.v(self.size.x / 2, self.size.y / 2)
	self.anchor = V.v(self.size.x / 2, self.size.y / 2)

	self:add_child(self.pointer)
	self:update(0)

	self.propagate_on_touch_up = false
	self.propagate_on_touch_move = false
	self.propagate_on_touch_down = false
	self.propagate_drag = false
	self.propagate_on_down = false
	self.propagate_on_click = false
	self.propagate_on_up = false
	self.propagate_on_enter = false
	self.base_scale = game_gui.base_scale_list.wave_alert
end

function WaveAlertView:update(dt)
	local f = self.wave_flag

	if not f then
		self:remove()

		return
	end

	local vis, px, py, r = AlertsView:get_alert_vector(f.pos.x, f.pos.y, self.base_scale)

	self.hidden = not vis
	self.pos.x, self.pos.y = px, py
	self.pointer.r = r
end

function WaveAlertView:remove()
	if self.wave_flag then
		self.wave_flag.alert_view = nil
	end

	self.wave_flag = nil

	self:remove_from_parent()
end

function WaveAlertView:on_click()
	if self.wave_flag and self.wave_flag.world_pos then
		local wx, wy = self.wave_flag.world_pos.x, self.wave_flag.world_pos.y
		local cx, cy = wx * game.game_scale, (game.ref_h - wy) * game.game_scale

		log.error("alert moving to:%s,%s", cx, cy)
		game.camera:tween(timer, 0.4, cx, cy, nil, "in-out-quad")
	end
end

AchievementView = class("AchievementView", KImageView)

function AchievementView:initialize(image_name)
	AchievementView.super.initialize(self, image_name)
end

function AchievementView:show(id)
	if self.gui_achievements_disabled then
		return
	end

	if not self.ach_queue then
		self.ach_queue = {}
	end

	if not self.hidden then
		table.insert(self.ach_queue, id)

		return
	end

	local ach = AC:get_data(id)
	local akey = (IS_KR3 and "ELVES_ACHIEVEMENT_" or "ACHIEVEMENT_") .. ach.name

	self:ci("image_ingame_achievements_icon_ui"):set_image("achievement_ingame_icon_" .. string.format("%03i", ach.icon) .. "_0001")

	self:ci("label_achievement_name").text = utf8_string.upper(_(akey .. "_NAME"))
	self:ci("label_achievement_name").fit_size = true
	self:ci("label_achievement_desc").text = _(akey .. "_DESCRIPTION")

	S:queue("GUIAchievementWin", {
		ignore = 1
	})

	self.hidden = false

	self:enable(false)

	if self.timer_h then
		timer:cancel(self.timer_h)
	end

	timer:tween(0.4, self.pos, {
		y = self.shown_y
	}, "out-back")

	self:ci("animation_ingame_achievements_ui_fx").ts = 0
	self:ci("animation_ingame_achievements_ui_glow_fx").ts = 0
	self.timer_h = timer:after(2, function()
		self:hide()
	end)
	self.size.y = game_gui.sh / 8
end

function AchievementView:hide()
	if self.timer_h then
		timer:cancel(self.timer_h)
	end

	self.timer_h = timer:tween(0.4, self.pos, {
		y = self.hidden_y
	}, "out-back", function()
		self.hidden = true

		if self.ach_queue and #self.ach_queue > 0 then
			local ach_id = table.remove(self.ach_queue, 1)

			self:show(ach_id)
		end
	end)
end

function AchievementView:on_click()
	self:disable(false)
	self:hide()
end

VictoryView = class("VictoryView", KView)

function VictoryView:initialize()
	VictoryView.super.initialize(self)

	self:ci("timeline_defeat").hidden = true
	self:ci("group_defeattext").hidden = true
	self:ci("timeline_angry_start").hidden = true
	self:ci("timeline_angry_loop").hidden = true
	self:ci("timeline_victory_goblin_loop").hidden = true
	self:ci("timeline_victory_soldier_loop").hidden = true
	self:ci("group_victorytext").hidden = true
	self:ci("timeline_victory").hidden = true
	self:ci("timeline_victory_goblin_start").hidden = true
	self:ci("timeline_victory_soldier_start").hidden = true
	self:ci("timeline_victorychallengescape").hidden = true
	self:ci("timeline_victorychallenges").hidden = true
	self:ci("group_victorytextchallenges").hidden = true
	self:ci("timeline_victoryheroicshield").hidden = true
	self:ci("timeline_victory_heroic_soldier_start").hidden = true
	self:ci("timeline_victory_heroic_soldier_loop").hidden = true
	self:ci("timeline_victory_heroic_goblin_start").hidden = true
	self:ci("timeline_victory_heroic_goblin_loop").hidden = true
	self:ci("timeline_victoryiron_fist").hidden = true
	self:ci("timeline_victory_iron_soldier_start").hidden = true
	self:ci("timeline_victory_iron_soldier_loop").hidden = true
	self:ci("timeline_victory_iron_goblin_start").hidden = true
	self:ci("timeline_victory_iron_goblin_loop").hidden = true
	self:ci("timeline_victory"):ci("button_continue").on_click = function()
		S:queue("GUIButtonCommon")
		game_gui.c_go_to_map()
	end
	self:ci("timeline_victory"):ci("button_restart").on_click = function()
		S:queue("GUIButtonCommon")
		game_gui.c_restart_game()
	end
	self:ci("timeline_victorychallenges"):ci("button_continue").on_click = function()
		S:queue("GUIButtonCommon")
		game_gui.c_go_to_map()
	end
	self:ci("timeline_victorychallenges"):ci("button_restart").on_click = function()
		S:queue("GUIButtonCommon")
		game_gui.c_restart_game()
	end
end

function VictoryView:show()
	local function scale_in(view, min_scale, max_scale, delay)
		if not view.scale_shown then
			view.scale_shown = V.vclone(view.scale)
		end

		ktw:cancel(view)

		view.scale.x = view.scale_shown.x * min_scale
		view.scale.y = view.scale_shown.y * min_scale
		view.alpha = 0

		ktw:script(view, function(wait)
			wait(delay)
			ktw:tween(view, 0.25, view, {
				alpha = 1
			}, "out-quad")
			ktw:tween(view, 0.25, view.scale, {
				x = view.scale_shown.x * max_scale,
				y = view.scale_shown.y * max_scale
			}, "linear", function()
				ktw:tween(view, 0.1, view.scale, {
					x = view.scale_shown.x,
					y = view.scale_shown.y
				}, "linear", function()
					view.scale.x = view.scale_shown.x
					view.scale.y = view.scale_shown.y
				end)
			end)
		end)
	end

	S:stop_all()
	S:queue("GUIQuestCompleted")

	local background = wid("modal_bg_transparent_view")

	background.hidden = false
	background.alpha = 0

	local stars = game_gui.game.store.game_outcome.stars
	local level_mode = game_gui.game.store.level_mode
	local level_idx = game_gui.game.store.level_idx
	local gems = game_gui.game.store.gems_collected or 0

	self.parent.hidden = false

	if level_mode == GAME_MODE_CAMPAIGN then
		self:ci("timeline_victory").hidden = false
		self:ci("timeline_victory").play = "once"

		self:ci("timeline_victory"):start()

		self:ci("timeline_victory_goblin_start").hidden = false
		self:ci("timeline_victory_goblin_start").play = "once"

		self:ci("timeline_victory_goblin_start"):start()

		self:ci("timeline_victory_soldier_start").hidden = false
		self:ci("timeline_victory_soldier_start").play = "once"

		self:ci("timeline_victory_soldier_start"):start()

		for i = 1, 3 do
			if stars < i then
				self:ci("timeline_victory"):ci("animation_star_" .. i).alpha = 0
			else
				S:queue("GUIWinStars", {
					delay = 2.1 + 0.45 * i
				})
			end
		end

		self:ci("group_victorytext").hidden = false

		local label_gems = self:ci("group_victorytext"):ci("label_gems_amount")

		label_gems.hidden = true

		local label_victory = self:ci("group_victorytext")

		scale_in(label_victory, 0.85, 1.12, 0)

		if features.no_gems then
			self:ci("timeline_victory"):ci("animation_gem").alpha = 0
		else
			timer:script(function(wait)
				wait(1)

				label_gems.hidden = false
				self:ci("animation_gem").ts = 0

				local increment = 0

				while increment < gems do
					increment = increment + 1
					label_gems.text = increment

					S:queue("GUIGemCounterSingle")
					wait(1 / gems)
				end

				label_gems.text = gems

				S:queue("GUIGemCounterSingle")
			end)
		end

		self:ci("timeline_victory"):ci("button_continue"):focus(true)
	elseif level_mode == GAME_MODE_HEROIC then
		self:ci("timeline_victoryheroicshield").hidden = false
		self:ci("timeline_victoryheroicshield").play = "once"

		self:ci("timeline_victoryheroicshield"):start()

		self:ci("timeline_victory_heroic_soldier_start").hidden = false
		self:ci("timeline_victory_heroic_soldier_start").play = "once"

		self:ci("timeline_victory_heroic_soldier_start"):start()

		self:ci("timeline_victory_heroic_goblin_start").hidden = false
		self:ci("timeline_victory_heroic_goblin_start").play = "once"

		self:ci("timeline_victory_heroic_goblin_start"):start()

		self:ci("timeline_victorychallengescape").hidden = false
		self:ci("timeline_victorychallengescape").play = "once"

		self:ci("timeline_victorychallengescape"):start()

		self:ci("timeline_victorychallenges").hidden = false
		self:ci("timeline_victorychallenges").play = "once"

		self:ci("timeline_victorychallenges"):start()

		self:ci("group_victorytextchallenges").hidden = false

		local label_gems = self:ci("group_victorytextchallenges"):ci("label_gems_amount")

		label_gems.hidden = true

		local label_victory = self:ci("group_victorytextchallenges")

		scale_in(label_victory, 0.85, 1.12, 0)

		if features.no_gems then
			self:ci("timeline_victorychallenges"):ci("animation_gem").alpha = 0
		else
			timer:script(function(wait)
				wait(1)

				label_gems.hidden = false
				self:ci("animation_gem").ts = 0

				local increment = 0

				while increment < gems do
					increment = increment + 1
					label_gems.text = increment

					S:queue("GUIGemCounterSingle")
					wait(1 / gems)
				end

				label_gems.text = gems

				S:queue("GUIGemCounterSingle")
			end)
		end

		self:ci("timeline_victorychallenges"):ci("button_continue"):focus(true)
	elseif level_mode == GAME_MODE_IRON then
		self:ci("timeline_victoryiron_fist").hidden = false
		self:ci("timeline_victoryiron_fist").play = "once"

		self:ci("timeline_victoryiron_fist"):start()

		self:ci("timeline_victory_iron_soldier_start").hidden = false
		self:ci("timeline_victory_iron_soldier_start").play = "once"

		self:ci("timeline_victory_iron_soldier_start"):start()

		self:ci("timeline_victory_iron_goblin_start").hidden = false
		self:ci("timeline_victory_iron_goblin_start").play = "once"

		self:ci("timeline_victory_iron_goblin_start"):start()

		self:ci("timeline_victorychallengescape").hidden = false
		self:ci("timeline_victorychallengescape").play = "once"

		self:ci("timeline_victorychallengescape"):start()

		self:ci("timeline_victorychallenges").hidden = false
		self:ci("timeline_victorychallenges").play = "once"

		self:ci("timeline_victorychallenges"):start()

		self:ci("group_victorytextchallenges").hidden = false

		local label_gems = self:ci("group_victorytextchallenges"):ci("label_gems_amount")

		label_gems.hidden = true

		local label_victory = self:ci("group_victorytextchallenges")

		scale_in(label_victory, 0.85, 1.12, 0)

		if features.no_gems then
			self:ci("timeline_victorychallenges"):ci("animation_gem").alpha = 0
		else
			timer:script(function(wait)
				wait(1)

				label_gems.hidden = false
				self:ci("animation_gem").ts = 0

				local increment = 0

				while increment < gems do
					increment = increment + 1
					label_gems.text = increment

					S:queue("GUIGemCounterSingle")
					wait(1 / gems)
				end

				label_gems.text = gems

				S:queue("GUIGemCounterSingle")
			end)
		end

		self:ci("timeline_victory"):ci("button_continue"):focus(true)
	end

	self.level_mode = level_mode
	self.victory_shown = true
	self.victory_goblin_in_loop = false
	self.victory_soldier_in_loop = false

	timer:tween(0.4, background, {
		alpha = 1
	}, "in-quad")
	game_gui:set_mode(GUI_MODE_FINISHED)
end

function VictoryView:update(dt)
	VictoryView.super.update(self, dt)

	if self.victory_shown then
		if self.level_mode == GAME_MODE_CAMPAIGN then
			if self:ci("timeline_victory_goblin_start").last_frame >= self:ci("timeline_victory_goblin_start").frame_duration and not self.victory_goblin_in_loop then
				self.victory_goblin_in_loop = true
				self:ci("timeline_victory_goblin_start").hidden = true
				self:ci("timeline_victory_goblin_loop").hidden = false

				self:ci("timeline_victory_goblin_loop"):start()
			end

			if self:ci("timeline_victory_soldier_start").last_frame >= self:ci("timeline_victory_soldier_start").frame_duration and not self.victory_soldier_in_loop then
				self.victory_soldier_in_loop = true
				self:ci("timeline_victory_soldier_start").hidden = true
				self:ci("timeline_victory_soldier_loop").hidden = false

				self:ci("timeline_victory_soldier_loop"):start()
			end
		elseif self.level_mode == GAME_MODE_HEROIC then
			if self:ci("timeline_victory_heroic_soldier_start").last_frame >= self:ci("timeline_victory_heroic_soldier_start").frame_duration and not self.victory_goblin_in_loop then
				self.victory_goblin_in_loop = true
				self:ci("timeline_victory_heroic_soldier_start").hidden = true
				self:ci("timeline_victory_heroic_soldier_loop").hidden = false

				self:ci("timeline_victory_heroic_soldier_loop"):start()
			end

			if self:ci("timeline_victory_heroic_goblin_start").last_frame >= self:ci("timeline_victory_heroic_goblin_start").frame_duration and not self.victory_soldier_in_loop then
				self.victory_soldier_in_loop = true
				self:ci("timeline_victory_heroic_goblin_start").hidden = true
				self:ci("timeline_victory_heroic_goblin_loop").hidden = false

				self:ci("timeline_victory_heroic_goblin_loop"):start()
			end
		elseif self.level_mode == GAME_MODE_IRON then
			if self:ci("timeline_victory_iron_soldier_start").last_frame >= self:ci("timeline_victory_iron_soldier_start").frame_duration and not self.victory_goblin_in_loop then
				self.victory_goblin_in_loop = true
				self:ci("timeline_victory_iron_soldier_start").hidden = true
				self:ci("timeline_victory_iron_soldier_loop").hidden = false

				self:ci("timeline_victory_iron_soldier_loop"):start()
			end

			if self:ci("timeline_victory_iron_goblin_start").last_frame >= self:ci("timeline_victory_iron_goblin_start").frame_duration and not self.victory_soldier_in_loop then
				self.victory_soldier_in_loop = true
				self:ci("timeline_victory_iron_goblin_start").hidden = true
				self:ci("timeline_victory_iron_goblin_loop").hidden = false

				self:ci("timeline_victory_iron_goblin_loop"):start()
			end
		end
	end
end

DefeatView = class("DefeatView", KView)

function DefeatView:initialize()
	DefeatView.super.initialize(self)

	local gems = game_gui.game.store.gems_collected or 0

	self:ci("timeline_defeat").hidden = false
	self:ci("group_defeattext").hidden = false
	self:ci("timeline_victory").hidden = true
	self:ci("timeline_victory_soldier_loop").hidden = true
	self:ci("timeline_victory_soldier_loop").hidden = true
	self:ci("timeline_victory_goblin_loop").hidden = true
	self:ci("timeline_victory_goblin_start").hidden = true
	self:ci("group_victorytext").hidden = true
	self:ci("timeline_angry_loop").hidden = true
	self:ci("timeline_victorychallengescape").hidden = true
	self:ci("timeline_victorychallenges").hidden = true
	self:ci("group_victorytextchallenges").hidden = true
	self:ci("timeline_victory_heroic_soldier_start").hidden = true
	self:ci("timeline_victory_heroic_soldier_loop").hidden = true
	self:ci("timeline_victory_heroic_goblin_start").hidden = true
	self:ci("timeline_victory_heroic_goblin_loop").hidden = true
	self:ci("timeline_victory_iron_soldier_start").hidden = true
	self:ci("timeline_victory_iron_soldier_loop").hidden = true
	self:ci("timeline_victory_iron_goblin_start").hidden = true
	self:ci("timeline_victory_iron_goblin_loop").hidden = true
	self:ci("label_defeat").text = _("LEVEL_DEFEAT_TITLE")
	self:ci("timeline_defeat"):ci("button_continue").on_click = function()
		S:queue("GUIButtonCommon")
		game_gui.c_go_to_map()
	end
	self:ci("timeline_defeat"):ci("button_restart").on_click = function()
		S:queue("GUIButtonCommon")
		game_gui.c_restart_game()
	end
	self:ci("group_defeattext"):ci("label_gems_amount").text = gems
end

function DefeatView:show()
	local stars = game_gui.game.store.game_outcome.stars
	local level_mode = game_gui.game.store.level_mode
	local level_idx = game_gui.game.store.level_idx
	local gems = game_gui.game.store.gems_collected or 0

	self.parent.hidden = false

	local background = wid("modal_bg_transparent_view")

	background.hidden = false
	background.alpha = 0
	self:ci("timeline_defeat").play = "once"

	self:ci("timeline_defeat"):start()

	self:ci("timeline_angry_start").play = "once"

	self:ci("timeline_angry_start"):start()

	self.defeat_shown = true

	timer:script(function(wait)
		S:stop_all()
		S:queue("GUIQuestFailed")

		wid("modal_bg_transparent_view").hidden = false
	end)
	timer:tween(0.4, background, {
		alpha = 1
	}, "in-quad")

	local label_gems = self:ci("group_defeattext"):ci("label_gems_amount")

	label_gems.hidden = true

	if features.no_gems then
		self:ci("timeline_defeat"):ci("animation_gem").alpha = 0
	else
		timer:script(function(wait)
			wait(1)

			label_gems.hidden = false

			local increment = 0

			while increment < gems do
				increment = increment + 1
				label_gems.text = increment

				wait(1 / gems)
			end

			label_gems.text = gems
		end)
	end

	local function scale_in(view, min_scale, max_scale, delay)
		if not view.scale_shown then
			view.scale_shown = V.vclone(view.scale)
		end

		ktw:cancel(view)

		view.scale.x = view.scale_shown.x * min_scale
		view.scale.y = view.scale_shown.y * min_scale
		view.alpha = 0

		ktw:script(view, function(wait)
			wait(delay)
			ktw:tween(view, 0.25, view, {
				alpha = 1
			}, "out-quad")
			ktw:tween(view, 0.25, view.scale, {
				x = view.scale_shown.x * max_scale,
				y = view.scale_shown.y * max_scale
			}, "linear", function()
				ktw:tween(view, 0.1, view.scale, {
					x = view.scale_shown.x,
					y = view.scale_shown.y
				}, "linear", function()
					view.scale.x = view.scale_shown.x
					view.scale.y = view.scale_shown.y
				end)
			end)
		end)
	end

	local label_victory = self:ci("group_defeattext")

	scale_in(label_victory, 0.85, 1.12, 0)
	self:ci("timeline_defeat"):ci("button_continue"):focus(true)
	game_gui:set_mode(GUI_MODE_FINISHED)
end

function DefeatView:update(dt)
	DefeatView.super.update(self, dt)

	if self.defeat_shown and self:ci("timeline_angry_start").last_frame >= self:ci("timeline_angry_start").frame_duration and not self.defeat_in_loop then
		self.defeat_in_loop = true
		self:ci("timeline_angry_start").hidden = true
		self:ci("timeline_angry_loop").hidden = false

		self:ci("timeline_angry_loop"):start()
	end
end

BossHealthBar = class("BossHealthBar", KImageView)

function BossHealthBar:initialize(health_bar)
	BossHealthBar.super.initialize(self, health_bar)
end

function BossHealthBar:show(e)
	self.hidden = false
	self.boss_entity = e
	self:ci("boss_health_bar_title").text = _(e.info.i18n_key .. "_NAME")

	self:ci("portrait"):set_image(e.info.portrait_boss)
end

function BossHealthBar:hide()
	if self.hidden then
		return
	end

	if self.tweening then
		timer:cancel(self.tweening)
	end

	self.alpha = 1

	timer:tween(0.4, self, {
		alpha = 0
	}, "in-back")
	timer:tween(0.4, self.scale, {
		x = 0.5,
		y = 0.5
	}, "in-back", function()
		self:remove_from_parent()
	end)
end

function BossHealthBar:update(dt)
	BossHealthBar.super.update(self, dt)

	if self.boss_entity then
		self:ci("boss_health_bar_front").scale.x = self.boss_entity.health.hp / self.boss_entity.health.hp_max
	end

	local store = game_gui.game.store

	if store.lives < 1 then
		self:hide()
	end
end

GemsRewardFx = class("GemsRewardFx", KView)

function GemsRewardFx:initialize(amount)
	KView.initialize(self)

	self.ani_offset = 0
	self.world_offset = V.v(0, 0)

	local icon = KImageView:new("gemsReward_0001")

	icon.anchor.y = icon.size.y / 2

	self:add_child(icon)

	local digits = SpriteDigits:new("waveRewardTimer", "%i", amount)

	digits.anchor.y = digits.size.y / 2
	digits.pos.x = icon.size.x

	self:add_child(digits)

	self.anchor.x, self.anchor.y = (digits.size.x + icon.size.x) / 2, icon.size.y + 2
	self.scale = V.v(0.3, 0.3)

	timer:script(function(wait)
		timer:tween(0.21, self.scale, {
			x = 1,
			y = 1
		}, "out-back")
		wait(0.21)

		local dy = icon.size.y / 2

		timer:tween(0.4, self, {
			alpha = 0,
			ani_offset = -dy
		})
		wait(0.4)
		self:remove_from_parent()
	end)
end

function GemsRewardFx:update(dt)
	self.class.super.update(self, dt)

	if self.world_pos then
		local wp, wo = self.world_pos, self.world_offset

		self.pos.x, self.pos.y = game_gui:w2u(V.v(wp.x + wo.x, wp.y + wo.y))
		self.pos.y = self.pos.y + self.ani_offset
	end
end

TimeRewardFx = class("TimeRewardFx", KView)

function TimeRewardFx:initialize(amount)
	TimeRewardFx.super.initialize(self)

	local vd = SpriteDigits:new("waveRewardTimer", "-%is", amount)

	self:add_child(vd)

	self.size.x = vd.size.x
	self.anchor.x = self.size.x / 2
	self.alpha = 1

	timer:tween(1, self, {
		alpha = 0
	}, "out-quad", function()
		self:remove_from_parent()
	end)

	local dy = vd.size.y / 3

	timer:tween(1, vd.pos, {
		y = -dy
	}, "out-quad")
end

WaveRewardFx = class("WaveRewardFx", KImageView)

function WaveRewardFx:initialize(reward)
	WaveRewardFx.super.initialize(self, "nextwave_coin_0001")

	self.animation = {
		to = 14,
		prefix = "nextwave_coin",
		from = 1
	}
	self.ts = 0

	local vd = SpriteDigits:new("waveReward", "+%i", reward)

	self:add_child(vd)

	vd.pos.x = self.size.x
	self.anchor.x = (self.size.x + vd.size.x) / 2
	self.alpha = 1

	timer:tween(1.5, self, {
		alpha = 0
	}, "out-quad", function()
		self:remove_from_parent()
	end)
end

SpriteDigits = class("SpriteDigits", KView)

function SpriteDigits:initialize(prefix, format, ...)
	KView.initialize(self)

	local text_width = 0
	local offset = V.v(0, 0)
	local reward_string = string.format(format, ...)
	local img_fmt = prefix .. "_%04i"

	for i = 1, #reward_string do
		local c = string.sub(reward_string, i, i)
		local index

		index = c == "+" and 11 or c == "-" and 11 or c == "s" and 12 or tonumber(c)

		local v = KImageView:new(string.format(img_fmt, index))

		v.pos.x, v.pos.y = offset.x, offset.y

		local char_size = km.round(0.7 * v.size.x)

		offset.x = offset.x + char_size
		text_width = text_width + char_size

		self:add_child(v)

		self.size.y = math.max(v.size.y, self.size.y)
	end

	self.size.x = text_width
end

KWinterAgeDust = class("KWinterAgeDust", KImageView)

function KWinterAgeDust:initialize(image_name, pos_x, pos_y)
	KImageView.initialize(self, image_name)

	self.left_out_of_screen = 0 - self.size.x / 2
	self.right_out_of_screen = game_gui.sw + self.size.x / 2
	self.move_speed = math.random(15, 20) / 10
	self.pos.x = pos_x
	self.pos.y = pos_y

	timer:tween(self.move_speed, self, {
		pos = V.v(self.right_out_of_screen + 100, self.pos.y)
	}, "linear")
end

function KWinterAgeDust:update(dt)
	KWinterAgeDust.super.update(self, dt)

	if self.pos.x >= self.right_out_of_screen then
		self.pos.x = self.left_out_of_screen

		timer:cancel(self)
		timer:tween(self.move_speed, self, {
			pos = V.v(self.right_out_of_screen + 100, self.pos.y)
		}, "linear")
	end
end

KWinterAgeSnowflake = class("KWinterAgeSnowflake", KImageView)

function KWinterAgeSnowflake:initialize(image_name, pos_x, pos_y)
	KImageView.initialize(self, image_name)

	self.move_speed_x = math.random(100, 200)
	self.move_speed_y = math.random(80, 120)
	self.pos.x = pos_x
	self.pos.y = pos_y
	self.original_pos_x = self.pos.x
end

function KWinterAgeSnowflake:update(dt)
	KWinterAgeSnowflake.super.update(self, dt)

	self.pos.x = self.pos.x + self.move_speed_x * dt
	self.pos.y = self.pos.y + self.move_speed_y * dt

	if self.pos.y > game_gui.sh then
		self.pos.y = -50
		self.pos.x = self.original_pos_x - 100
	end
end

GenericFX = class("StarShineFX", KImageView)

function GenericFX:initialize(image_name)
	KImageView.initialize(self, image_name)

	self.ts = 0

	if self.wait then
		self.hidden = true
		self.wait_for = math.random(self.wait[1], self.wait[2])
	end
end

function GenericFX:update(dt)
	GenericFX.super.update(self, dt)

	if self.disabled or self._fading then
		return
	end

	if self.wait_for then
		if self.ts > self.wait_for then
			self.wait_for = nil
			self.hidden = nil
			self.path_finished = nil
			self.ts = 0
		else
			return
		end
	end

	local fade_in_alpha = self.fade_in_alpha or 1
	local fade_out_alpha = self.fade_out_alpha or 0
	local half_alpha = (fade_in_alpha - fade_out_alpha) / 2

	if self.fade_out_time and half_alpha < self.alpha and (not self.path or self.path_finished) then
		log.paranoid("general fade out , alpha:%s - %s", self.alpha, self.image_name)

		self._fading = true

		local v = self

		if self.path then
			self.disabled = true
		end

		timer:tween(self.fade_out_time, self, {
			alpha = fade_out_alpha
		}, "linear", function()
			v._fading = false
		end)
	elseif self.fade_in_time and half_alpha >= self.alpha and (not self.path or not self.path_idx and not self.path_finished) then
		log.paranoid("general fade in - %s", self.image_name)

		self.alpha = fade_out_alpha
		self._fading = true

		local v = self

		timer:tween(self.fade_in_time, self, {
			alpha = fade_in_alpha
		}, "linear", function()
			v._fading = false
		end)
	end

	local ani_finished

	if self.animation then
		ani_finished = self.ts >= self.animation.to / (self.fps or FPS)
	else
		ani_finished = true
	end

	if ani_finished and self.wait and self.wait then
		self.hidden = self.animation and true or false
		self.wait_for = math.random(self.wait[1], self.wait[2])
		self.ts = 0

		return
	end
end

return game_gui
