local log = require("klua.log"):new("screen_map")
local class = require("middleclass")
local DI = require("difficulty")
local E = require("entity_db")
local F = require("klove.font_db")
local G = love.graphics
local GS = require("game_settings")
local GU = require("gui_utils")
local I = require("klove.image_db")
local ISM = require("klove.input_state_machine")
local S = require("sound_db")
local SU = require("screen_utils")
local U = require("utils")
local UPGR = require("upgrades")
local V = require("klua.vector")
local km = require("klua.macros")
local i18n = require("i18n")
local storage = require("storage")
local signal = require("hump.signal")
local timer = require("hump.timer").new()
local ktw = require("klove.tween").new(timer)
local utf8 = require("utf8")
local utf8_string = require("klove.utf8_string")
local PP = require("privacy_policy_consent")
local PS = require("platform_services")
local RC = require("remote_config")
local marketing = require("marketing")
local features = require("features")
local achievements_data = require("data.achievements_data")
local map_data = require("data.map_data")
local iap_data = require("data.iap_data")

require("klove.kui")

local kui_db = require("klove.kui_db")

require("constants")
require("gg_views_game")
require("screen_map_classes")
require("shop_views")

local dbe

if DBG_OTO_EDITOR or DBG_HERO_ROOM_EDITOR or DBG_SHOP_EDITOR or DBG_MAP_EDITOR then
	dbe = require("debug_view_editor")
end

screen_map = {}

if DEBUG then
	screen_map.reload_list = {
		"screen_map_classes",
		"gg_views_game"
	}
end

screen_map.required_sounds = {
	"common",
	"music_screen_map"
}
screen_map.required_textures = {
	"screen_map",
	"screen_map_bg",
	"screen_map_hud",
	-- "screen_map_stage_thumbs",
	"room_achievements",
	"room_difficulty",
	"room_cards",
	"room_common",
	"room_shop",
	"room_hero",
	"room_tower",
	"room_upgrades",
	"room_item",
	"room_levelselect",
	-- "achievements",
	"gui_popups",
	"gui_portraits"
}

if not IS_MOBILE then
	table.insert(screen_map.required_textures, "gui_popups_desktop")
end

if KR_GAME ~= "kr5" then
	table.insert(screen_map.required_textures, "screen_map_road")
end

screen_map.ref_w = 1728
screen_map.ref_h = 768
screen_map.ref_res = TEXTURE_SIZE_ALIAS.ipad
screen_map.ism_state = "LAST"

local function wid(name)
	return screen_map.window:get_child_by_id(name)
end

screen_map.signal_handlers = {
	[SGN_SHOP_GEMS_CHANGED] = function()
		screen_map:update_gems()
	end,
	[SGN_SHOP_SHOW_IAP_PROGRESS] = function()
		screen_map:show_iap_progress()
	end,
	[SGN_SHOP_SHOW_MESSAGE] = function(kind, arg)
		arg = arg or "error unknown"

		if kind == "iap_error" then
			screen_map:show_error(arg)
		else
			screen_map:show_message(kind, arg)
		end
	end,
	[SGN_SHOW_GEMS_STORE] = function(no_title)
		return
	end,
	[SGN_PS_STATUS_CHANGED] = function(service_name, status, opt_msg)
		return
	end,
	[SGN_PS_REMOTE_CONFIG_SYNC_FINISHED] = function(service_name, status, opt_msg)
		if PS.services.iap then
			PS.services.iap:sync_products()
		end
	end,
	[SGN_PS_PURCHASE_PRODUCT_FINISHED] = function(service_name, success, product_id, currency, is_restored)
		log.debug(SGN_PS_PURCHASE_PRODUCT_FINISHED .. " : %s %s %s", service_name, success, product_id, currency, is_restored)
		screen_map:hide_iap_progress()

		if success then
			if PS.services.iap then
				local p = PS.services.iap:get_product(product_id, true)

				if p and p.gems then
					S:queue("InAppEarnGems")
				end
			end

			screen_map:update_gems()
			screen_map:update_hero_room()
			screen_map:update_tower_room()
			screen_map:update_item_room()

			if not wid("hero_room_view").hidden then
				local hero_name = string.gsub(product_id, "sale_", "")

				screen_map:show_hero_room(hero_name, true)
			end

			if not wid("tower_room_view").hidden then
				local tower = string.gsub(product_id, "tower_", "")

				tower = string.gsub(tower, "sale_", "")

				screen_map:show_tower_room(tower, true)
			end

			if not wid("shop_room_view").hidden then
				local offer, exp_time = marketing:get_active_offer()

				if not offer or offer and offer.id == product_id then
					offer = marketing:get_one_time_offer(false)

					if offer then
						exp_time = marketing:set_active_offer(offer)
					end
				end

				wid("shop_room_view"):refresh_offers(true)
				wid("group_offer_icon"):update_offer(offer, exp_time)

				local peristent_offers = marketing:get_candidate_offers(true) or {}

				for k, v in pairs(peristent_offers) do
					if v.season_offer and wid("group_offer_icon_" .. v.season_offer) then
						wid("group_offer_icon_" .. v.season_offer).hidden = false
					end
				end

				if PS.services.iap then
					screen_map:hide_shop()
					screen_map:show_product_cards(product_id)
				end
			end
		end
	end,
	[SGN_PS_SYNC_PRODUCTS_FINISHED] = function(service_name, success)
		if success then
			wid("shop_room_view"):refresh_offers(true)

			local offer, exp_time = marketing:get_active_offer()

			wid("group_offer_icon"):update_offer(offer, exp_time)

			local peristent_offers = marketing:get_candidate_offers(true) or {}

			for k, v in pairs(peristent_offers) do
				if v.season_offer and wid("group_offer_icon_" .. v.season_offer) then
					wid("group_offer_icon_" .. v.season_offer).hidden = false
				end
			end
		end
	end,
	[SGN_PS_RESTORE_PURCHASES_FINISHED] = function(service_name, success)
		log.debug(SGN_PS_RESTORE_PURCHASES_FINISHED .. " : %s", success)
	end,
	[SGN_PS_SYNC_PURCHASES_FINISHED] = function(service_name, success)
		screen_map:hide_iap_progress()
	end,
	[SGN_PS_AD_SHOW_VIDEO_FINISHED] = function(service_name, success, data, status)
		log.debug(SGN_PS_AD_SHOW_VIDEO_FINISHED .. " : %s reward:%s", success, data)
		screen_map:hide_iap_progress()

		if success then
			if PS.services.fullads then
				log.error("TODO!")
			elseif data and data.rewards and data.rewards.gems then
				screen_map:show_message("reward", data.rewards.gems)
				S:queue("InAppEarnGems")
			end

			screen_map:update_gems()
		elseif status == 31 then
			log.debug(SGN_PS_AD_SHOW_VIDEO_FINISHED .. " : video closed early, no reward given. status: %s", status)
		else
			screen_map:show_message("reward_error")
		end

		PS.services.ads:cache_video_ad()
	end,
	[SGN_PS_CHANNEL_QUIT_REQUESTED] = function(service_name, error_msg)
		return
	end,
	["map-pan-to-flag"] = function(flag)
		if not flag then
			return
		end

		local w = screen_map.window
		local mv = w:ci("map_view")
		local mx, my = flag:view_to_view(0, 0, mv)

		w:ci("map_view"):pan_to_map_coord(mx, my, true)
	end
}

function screen_map:init(w, h, done_callback)
	self.done_callback = done_callback

	local user_data = storage:load_slot(nil, true)

	E:load()
	DI:set_level(DIFFICULTY_NORMAL)
	DI:patch_templates()

	self.unlock_data = {}
	self.unlock_data.unlocked_levels = {}

	local map_data = require("data.map_data")

	if not PS.services.iap or PS.services.iap:is_premium() then
		screen_map.hero_data = table.deepclone(map_data.hero_data_free)
		screen_map.hero_order = map_data.hero_order_free
	else
		screen_map.hero_data = map_data.hero_data_iap
		screen_map.hero_order = map_data.hero_order_iap
	end

	self:update_tower_data()

	local levels = user_data.levels
	local victory = user_data.last_victory
	local show_card_rewards = false

	if victory then
		local level = levels[victory.level_idx]

		if not level then
			log.error("victory level %s was not shown in map before. ignoring victory", victory.level_idx)
		-- elseif victory.level_idx > GS.last_level then
			-- log.error("victory level %s was discarded for being from a newer version of the game", victory.level_idx)
		else
			if victory.level_mode == GAME_MODE_CAMPAIGN then
				if not level[GAME_MODE_CAMPAIGN] then
					level.stars = victory.stars
					self.unlock_data.show_stars_level = victory.level_idx
					self.unlock_data.star_count_before = 0

					local next_level_idx = U.find_next_level_in_ranges(GS.level_ranges, victory.level_idx)

					if not levels[next_level_idx] then
						levels[next_level_idx] = {}
						self.unlock_data.new_level = next_level_idx

						table.insert(self.unlock_data.unlocked_levels, self.unlock_data.new_level)
					end

					local premium, exceptions

					if PS.services.iap then
						premium, exceptions = PS.services.iap:is_premium()
					end

					if victory.level_idx > GS.main_campaign_levels then
						for k, v in pairs(screen_map.hero_data) do
							if v.available_at_stage == victory.level_idx + 1 and (not v.iap or not exceptions) then
								show_card_rewards = true

								break
							end
						end

						if not show_card_rewards then
							for k, v in pairs(screen_map.tower_data) do
								if v.available_at_stage == victory.level_idx + 1 and (not v.iap or not exceptions) then
									show_card_rewards = true

									break
								end
							end
						end
					else
						show_card_rewards = true
					end
				elseif victory.stars > level.stars then
					self.unlock_data.show_stars_level = victory.level_idx
					self.unlock_data.star_count_before = level.stars
					level.stars = victory.stars
				end
			elseif victory.level_mode == GAME_MODE_HEROIC then
				self.unlock_data.heroic_level = not level[GAME_MODE_HEROIC] and victory.level_idx or nil
			elseif victory.level_mode == GAME_MODE_IRON then
				self.unlock_data.iron_level = not level[GAME_MODE_IRON] and victory.level_idx or nil
			end

			level[victory.level_mode] = math.max(victory.level_difficulty, level[victory.level_mode] or 0)
		end

		user_data.last_victory = nil

		storage:save_slot(user_data)
	elseif #levels == 0 then
		self.unlock_data.unlocked_levels = {
			1
		}
		levels[1] = {}

		storage:save_slot(user_data)
	end

	local unlocked_campaigns = {}
	local owned_dlcs = PS.services.iap and PS.services.iap:get_dlcs(true) or {}

	if U.unlock_next_levels_in_ranges(self.unlock_data, levels, GS, owned_dlcs) then
		storage:save_slot(user_data)

		for i = 2, #GS.level_ranges - #GS.dlc_names do
			if table.contains(self.unlock_data.unlocked_levels, GS.level_ranges[i][1]) then
				local update_id = string.format("%02d", i - 1)

				table.insert(unlocked_campaigns, "update_" .. update_id)
			end
		end

		if #unlocked_campaigns >= 1 then
			show_card_rewards = true
		end
	end

	self.total_stars = U.count_stars(user_data)

	if PS.services.iap and PS.services.iap:get_status() then
		PS.services.iap:sync_purchases(true)
	end

	self:update_item_data()

	self.w, self.h = w, h

	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)

	self.sw, self.sh = sw, sh
	GGLabel.static.font_scale = scale
	GGLabel.static.ref_h = self.ref_h
	self.default_base_scale = SU.get_default_base_scale(sw, sh)
	GG5PopUp.static.base_scale = self.default_base_scale
	RoomView.static.base_scale = self.default_base_scale
	RoomView.static.sw = sw
	RoomView.static.sh = sh
	RoomView.static.scale = scale
	RoomView.static.origin = origin

	local ctx = SU.new_screen_ctx(self)

	ctx.context = "map"
	ctx.hud_scale = SU.get_hud_scale(w, h, self.ref_w, self.ref_h)
	ctx.premium = not PS.services.iap or PS.services.iap:is_premium()
	ctx.fullads = PS.services.fullads ~= nil
	ctx.hide_strategy_guide = (not PP:can_show("strategy") or features.hide_strategy_guide) and true or false
	ctx.hide_leaderboards = not PP:can_show("leaderboards") and true or false
	ctx.is_new_ui = storage.active_slot_idx == "3"
	ctx.is_underage = PP:is_underage()
	ctx.is_main = false
	ctx.is_censored_cn = features.censored_cn and true or false

	local tt = kui_db:get_table("screen_map", ctx)
	local window = KWindow:new_from_table(tt)

	window.scale = V.v(scale, scale)
	window.size = {
		x = sw,
		y = sh
	}
	window.origin = origin
	window.timer = timer
	window.ktw = ktw

	window:set_responder(window)

	self.window = window

	do
		local views = {}

		table.append(views, wid("group_map_hud").children)
		SU.apply_base_scale(views, self.default_base_scale)
		SU.apply_base_scale(views, V.vv(OVT(1, OV_TABLET, 0.6)))
	end

	SU.apply_base_scale({
		window:ci("card_rewards_view")
	}, V.vv(OVtargets(1, 1, 1, 0.8, 0.8)))
	SU.apply_base_scale({
		window:ci("level_select_view").contents
	}, V.vv(OVtargets(1, 1, 0.8, 0.65, 0.65)), true)

	local mv = wid("map_view")

	wid("map_touch_view"):set_puppet(wid("map_view"))

	local vignette = wid("vignette_view")

	vignette.scale.x = 1.02 * self.sw / wid("vignette_view").size.x
	vignette.scale.y = 1.02 * self.sh / wid("vignette_view").size.y
	vignette.pos.x = -0.01 * self.sw
	vignette.pos.y = -0.01 * self.sh

	self:init_bars()

	wid("button_map_options").on_click = function(this)
		S:queue("GUIButtonCommon")
		wid("popup_options"):show("map")
	end
	wid("label_map_stars").text = self.total_stars .. "/" .. GS.max_stars
	wid("button_map_heroes").on_click = function()
		S:queue("GUIButtonCommon")
		screen_map:show_hero_room()
	end

	wid("button_map_heroes"):focus(true)

	wid("button_map_towers").on_click = function()
		S:queue("GUIButtonCommon")
		screen_map:show_tower_room()
	end
	wid("button_map_upgrades").on_click = function()
		S:queue("GUIButtonCommon")
		screen_map:show_upgrades()
	end
	wid("button_map_achievements").on_click = function(this)
		S:queue("GUIButtonCommon")
		screen_map:show_achievements()
	end
	wid("button_map_shop").on_click = function(this)
		S:queue("GUIButtonCommon")
		screen_map:show_shop()
	end
	wid("button_map_hud_buy_gems").on_click = function(this)
		S:queue("GUIButtonCommon")
		screen_map:show_shop_gems()
	end
	wid("button_map_items").on_click = function()
		S:queue("GUIButtonCommon")
		screen_map:show_item_room()
	end
	wid("button_map_options").propagate_on_touch_move = true
	wid("button_map_heroes").propagate_on_touch_move = true
	wid("button_map_towers").propagate_on_touch_move = true
	wid("button_map_upgrades").propagate_on_touch_move = true
	wid("button_map_achievements").propagate_on_touch_move = true

	local st = storage:load_settings()

	S:set_main_gain_music(st and st.volume_music or 1)
	S:set_main_gain_fx(st and st.volume_fx or 1)
	S:queue("MusicMap")

	local ism_data = {
		MODAL = {
			{
				"return",
				self.q_is_modal,
				[4] = self.c_hide_modal
			},
			{
				"escape",
				"return"
			},
			{
				"ja",
				"return"
			},
			{
				"jb",
				"return"
			},
			{
				"STOP"
			}
		},
		LAST = {
			{
				"escape",
				self.q_is_picking_team,
				[4] = self.c_stop_picking_team
			},
			{
				"escape",
				self.q_is_picking_tower,
				[4] = self.c_stop_picking_tower
			},
			{
				"escape",
				ISM.q_is_view_visible,
				{
					"difficulty_room_view"
				}
			},
			{
				"escape",
				ISM.q_is_view_visible,
				{
					"gems_store_view"
				},
				ISM.c_hide_view,
				{
					"gems_store_view"
				}
			},
			{
				"escape",
				ISM.q_is_view_visible,
				{
					"shop_room_view"
				},
				ISM.c_hide_view,
				{
					"shop_room_view"
				}
			},
			{
				"escape",
				ISM.q_is_view_visible,
				{
					"item_room_view"
				},
				ISM.c_hide_view,
				{
					"item_room_view"
				}
			},
			{
				"escape",
				ISM.q_is_view_visible,
				{
					"achievements_room_view"
				},
				ISM.c_hide_view,
				{
					"achievements_room_view"
				}
			},
			{
				"escape",
				ISM.q_is_view_visible,
				{
					"message_view"
				},
				ISM.c_hide_view,
				{
					"message_view"
				}
			},
			{
				"escape",
				ISM.q_is_view_visible,
				{
					"popup_options"
				},
				self.hide_popup_options
			},
			{
				"escape",
				ISM.q_is_view_visible,
				{
					"endless_level_view"
				},
				ISM.c_hide_view,
				{
					"endless_level_view"
				}
			},
			{
				"escape",
				ISM.q_is_view_visible,
				{
					"level_select_view"
				},
				self.hide_level
			},
			{
				"escape",
				ISM.q_is_view_visible,
				{
					"hero_room_view"
				},
				self.hide_hero_room
			},
			{
				"escape",
				ISM.q_is_view_visible,
				{
					"tower_room_view"
				},
				self.hide_tower_room
			},
			{
				"escape",
				ISM.q_is_view_visible,
				{
					"upgrades_room_view"
				},
				self.hide_upgrades
			},
			{
				"escape",
				ISM.q_is_escape_show_quit,
				[4] = self.c_return_main_menu
			},
			{
				"escape",
				true,
				[4] = ISM.c_show_view,
				[5] = {
					"popup_options",
					"map"
				}
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
				ISM.q_is_view_visible,
				{
					"popup_options"
				},
				ISM.c_call_view_fn,
				{
					"popup_options",
					"change_page",
					"prev"
				}
			},
			{
				"pagedown",
				ISM.q_is_view_visible,
				{
					"popup_options"
				},
				ISM.c_call_view_fn,
				{
					"popup_options",
					"change_page",
					"next"
				}
			},
			{
				"pageup",
				ISM.q_is_view_visible,
				{
					"achievements_room_view"
				},
				ISM.c_call_view_fn,
				{
					"achievements_room_view",
					"change_page",
					"prev"
				}
			},
			{
				"pagedown",
				ISM.q_is_view_visible,
				{
					"achievements_room_view"
				},
				ISM.c_call_view_fn,
				{
					"achievements_room_view",
					"change_page",
					"next"
				}
			},
			{
				"pageup",
				self.q_is_flag_focused,
				[4] = self.c_focus_next_flag,
				[5] = {
					-1
				}
			},
			{
				"pagedown",
				self.q_is_flag_focused,
				[4] = self.c_focus_next_flag,
				[5] = {
					1
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
				"jleftshoulder",
				"pageup"
			},
			{
				"jrightshoulder",
				"pagedown"
			},
			{
				"jstart",
				"escape"
			},
			{
				"jback",
				"escape"
			},
			{
				"jstart",
				true,
				[4] = ISM.c_show_view,
				[5] = {
					"popup_options",
					"map"
				}
			},
			{
				"jback",
				true,
				[4] = ISM.c_show_view,
				[5] = {
					"popup_options",
					"map"
				}
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
		}
	}

	ISM:init(ism_data, window, DEFAULT_KEY_MAPPINGS, storage:load_settings())

	if PS then
		PS.paused = nil
	end

	for sn, fn in pairs(self.signal_handlers) do
		signal.register(sn, fn)
	end

	RC:sync()

	if PS.services.iap and PS.services.iap:get_status() then
		PS.services.iap:sync_purchases()
		PS.services.iap:sync_products()
	end

	if PS.services.ads then
		PS.services.ads:cache_video_ad()
	end

	self:update_badges()

	if show_card_rewards then
		wid("map_view"):show_flags_unlocked()

		if #unlocked_campaigns >= 1 and self.unlock_data.unlocked_levels[1] > GS.main_campaign_levels then
			wid("card_rewards_view"):show(nil, unlocked_campaigns)
		else
			wid("card_rewards_view"):show(victory.level_idx)
		end
	else
		wid("map_view"):show_flags()

		local offer, exp_time = marketing:get_active_offer()

		if not offer then
			offer = marketing:get_one_time_offer(false)

			if offer then
				exp_time = marketing:set_active_offer(offer)

				wid("group_offer_icon"):update_offer(offer, exp_time)
				
				local peristent_offers = marketing:get_candidate_offers(true) or {}

				for k, v in pairs(peristent_offers) do
					if v.season_offer and wid("group_offer_icon_" .. v.season_offer) then
						wid("group_offer_icon_" .. v.season_offer).hidden = false
					end
				end
			end
		end
	end

	if self.args and self.args.show == "shop" then
		self:show_shop()
	end

	if PS.services.analytics then
		PS.services.analytics:log_event("kr_screen_init", "file", "screen_map")
	end

	if PS and PS.services.channel and PS.services.channel.quit_requested then
		screen_map:show_message("channel_quit_game", PS.services.channel.quit_message)
	end

	if DBG_HERO_ROOM_EDITOR then
		dbe:inject_editor(wid("hero_room_view"), self)
	elseif DBG_SHOP_EDITOR then
		dbe:inject_editor(wid("shop_view"), self)
	elseif DBG_MAP_EDITOR then
		dbe:inject_editor(wid("gems_store_view"), self)
	end

	if DEBUG then
		local cheat_button = wid("cheat_button")

		function cheat_button.on_click(this)
			if this.cheat_view and this.cheat_view.view.hidden then
				for _, view in ipairs(this.cheat_view.views) do
					view:remove_from_parent()
				end

				this.cheat_view = nil
			end

			if this.cheat_view then
				for _, view in ipairs(this.cheat_view.views) do
					view:remove_from_parent()
				end

				this.cheat_view = nil
			else
				package.loaded.game_gui_cheats_map = nil
				this.cheat_view = require("game_gui_cheats_map")

				this.cheat_view:init()

				for _, view in ipairs(this.cheat_view.views) do
					this.parent:add_child(view)
				end
			end
		end
	end

	for _, v in pairs(window:flatten(function(v)
		return v and v:isInstanceOf(GG5ShaderLabel)
	end)) do
		v:prepare_canvas()
	end

	if not show_card_rewards then
		screen_map:process_new_dlc()
	end
end

function screen_map:destroy()
	for sn, fn in pairs(self.signal_handlers) do
		signal.remove(sn, fn)
	end

	ISM:destroy(self.window)
	ktw:clear()
	timer:clear()

	self.window.timer = nil
	self.window.ktw = nil

	self.window:destroy()

	self.window = nil

	SU.remove_references(self, KView)
end

function screen_map:update(dt)
	self.window:update(dt)

	if self.window.timer then
		self.window.timer:update(dt)
	end
end

function screen_map:draw()
	self.window:draw()
end

function screen_map:keypressed(key, isrepeat)
	if DEBUG and key == "g" then
		local user_data = storage:load_slot()

		if love.keyboard.isDown("lshift") then
			user_data.gems = user_data.gems + 100
		else
			user_data.gems = km.clamp(0, 10000, user_data.gems - 100)
		end

		storage:save_slot(user_data)
		self:update_gems()
	end

	if DBG_OTO_EDITOR or DBG_HERO_ROOM_EDITOR or DBG_SHOP_EDITOR or DBG_MAP_EDITOR then
		dbe:keypressed(self.SEL_VIEW, key, isrepeat)
	end

	if DEBUG_MAP then
		if isrepeat then
			return
		end

		local user_data = storage:load_slot()

		if not self._test_unlocked_level then
			self._test_unlocked_level = #user_data.levels
		end

		local function reset_unlock_data()
			self.unlock_data = {}
			self.unlock_data.unlocked_levels = {}
		end

		local function prepare_test_unlocked_level()
			local new_level = self._test_unlocked_level
			local levels = {}

			levels[new_level] = {}

			if new_level > 1 then
				for i = 1, new_level - 1 do
					levels[i] = {
						2,
						math.random() < 0.5 and 2,
						math.random() < 0.5 and 2,
						stars = math.random(1, 3)
					}
				end

				self.unlock_data.new_level = new_level
				self.unlock_data.show_stars_level = new_level - 1
				self.unlock_data.star_count_before = 0
				self.unlock_data.unlocked_levels = {
					new_level
				}

				if new_level == 16 then
					levels[19] = {}
					self.unlock_data.unlocked_levels = {
						16,
						19
					}
				end
			end

			user_data.levels = levels
		end

		local map_view = wid("map_view")

		if map_view.show_flags_in_progress then
			log.debug("show_flags in progress... skipping")

			return
		end

		if key == "r" then
			map_view:clear_flags()
			reset_unlock_data()

			self._test_unlocked_level = 1

			prepare_test_unlocked_level()
			log.error("restarting flags...")
			map_view:show_flags()
		elseif key == "n" then
			map_view:clear_flags()
			reset_unlock_data()

			self._test_unlocked_level = self._test_unlocked_level + 1

			prepare_test_unlocked_level()
			map_view:show_flags()
		end

		if self._test_unlocked_level > 1 then
			if key == "s" then
				map_view:clear_flags()
				reset_unlock_data()

				local lvl = self._test_unlocked_level - 1

				self.unlock_data.show_stars_level = lvl
				self.unlock_data.star_count_before = user_data.levels[lvl].stars
				user_data.levels[lvl].stars = km.clamp(1, 3, user_data.levels[lvl].stars + 1)

				storage:save_slot(user_data)
				map_view:show_flags()
			elseif key == "h" then
				map_view:clear_flags()
				reset_unlock_data()

				local lvl = self._test_unlocked_level - 1

				user_data.levels[lvl][2] = 2

				storage:save_slot(user_data)

				self.unlock_data.heroic_level = lvl

				map_view:show_flags()
			elseif key == "i" then
				map_view:clear_flags()
				reset_unlock_data()

				local lvl = self._test_unlocked_level - 1

				self.unlock_data.iron_level = lvl
				user_data.levels[lvl][3] = 2

				storage:save_slot(user_data)
				map_view:show_flags()
			end
		end
	end
end

function screen_map:keyreleased(key)
	return
end

function screen_map:wheelmoved(dx, dy)
	self.window:wheelmoved(dx, dy)
end

function screen_map:mousepressed(x, y, button, istouch)
	self.window:mousepressed(x, y, button, istouch)
end

function screen_map:mousereleased(x, y, button, istouch)
	self.window:mousereleased(x, y, button, istouch)
end

function screen_map:touchpressed(id, x, y, dx, dy, pressure)
	self.window:touchpressed(id, x, y, dx, dy, pressure)
end

function screen_map:touchreleased(id, x, y, dx, dy, pressure)
	self.window:touchreleased(id, x, y, dx, dy, pressure)
end

function screen_map:touchmoved(id, x, y, dx, dy, pressure)
	self.window:touchmoved(id, x, y, dx, dy, pressure)
end

function screen_map:get_ism_state()
	return self.ism_state
end

function screen_map:set_modal_view(view)
	self.modal_view = view
	self.ism_state = "MODAL"

	log.debug(" SETTING MODAL VIEW: %s", view)
end

function screen_map:remove_modal_view()
	if self.modal_view then
		self.modal_view = nil
		self.ism_state = "LAST"

		log.debug(" SETTING MODAL VIEW: %s", view)
	end
end

local bar_names

if IS_MOBILE then
	bar_names = {
		"group_bottom",
		"group_top_right",
		"group_top_left",
		"group_bottom_right",
		"group_offer_icon"
	}

	for k, s in pairs(GS.seasons) do
		table.insert(bar_names, "group_offer_icon_" .. s)
	end
else
	bar_names = {
		"group_bottom",
		"group_top_right",
		"group_top_left",
		"group_bottom_right"
	}
end

function screen_map:init_bars()
	if IS_MOBILE then
		if PS.services.iap and PS.services.iap:is_premium() and PS.services.iap:is_premium_valid() then
			wid("group_map_hud"):ci("button_map_hud_buy_gems").hidden = true

			local gr = wid("group_map_hud"):ci("group_bottom")
			local list = {
				"shop"
			}

			for _, n in pairs(list) do
				gr:ci("button_map_" .. n).hidden = true
				gr:ci("label_map_" .. n).hidden = true
			end

			gr.pos.x = (self.sw / 2 + (gr:ci("button_map_items").pos.x - gr:ci("button_map_upgrades").pos.x) / 2) * gr.base_scale.x
		end
	else
		wid("group_map_hud"):ci("label_map_gems").hidden = true
		wid("group_map_hud"):ci("bg_gems").hidden = true
		wid("group_map_hud"):ci("button_map_hud_buy_gems").hidden = true

		local gr = wid("group_map_hud"):ci("group_bottom")
		local list = {
			-- "items",
			"shop"
		}

		for _, n in pairs(list) do
			gr:ci("button_map_" .. n).hidden = true
			gr:ci("label_map_" .. n).hidden = true
		end

		gr.pos.x = self.sw / 2 + (gr:ci("button_map_towers").pos.x - gr:ci("button_map_heroes").pos.x) * gr.base_scale.x
	end

	for _, n in pairs(bar_names) do
		if string.find(n, "group_offer_icon") then
			-- block empty
		else
			local v = wid(n)

			if not v then
				log.error("could not find bar named %s", n)
			else
				local delta = self.sh / 2

				if not v.pos_shown then
					v.pos_shown = V.vclone(v.pos)
				end

				if not v.pos_hidden then
					v.pos_hidden = V.v(v.pos.x, v.pos.y + delta * (v.pos.y > self.sh / 2 and 1 or -1))
				end

				v.pos.y = v.pos_hidden.y
				v.hidden = true
			end
		end
	end

	if IS_MOBILE then
		local function init_offer_icon(offer_icon)
			local delta = self.sw / 2

			if not offer_icon.pos_shown then
				offer_icon.pos_shown = V.vclone(offer_icon.pos)
			end

			if not offer_icon.pos_hidden then
				offer_icon.pos_hidden = V.v(offer_icon.pos.x + delta, offer_icon.pos.y)
			end

			offer_icon.pos.x = offer_icon.pos_hidden.x
			offer_icon.hidden = true
		end

		local offer_icons = {
			"group_offer_icon"
		}

		for k, s in pairs(GS.seasons) do
			table.insert(offer_icons, "group_offer_icon_" .. s)
		end

		for k, v in pairs(offer_icons) do
			local offer_icon = wid(v)

			if offer_icon then
				init_offer_icon(offer_icon)
			end
		end
	end

	local new_hero = HeroRoomView:is_new_hero_available()
	local new_tower = TowerRoomView:is_new_tower_available()
	local current_points = UPGR:get_current_points_by_level() - UPGR:get_spent_points()
	local upgrade_points = current_points > 0

	if new_hero then
		wid("map_hud_notification_new_hero"):ci("label_txt_notification_icon").text = _("MAP_NEW_HERO_ALERT")
	else
		wid("map_hud_notification_new_hero").hidden = true
	end

	if not HeroRoomView:has_hero_points_to_spend() then
		wid("group_bottom"):ci("alert_heroes").hidden = true
	end

	wid("group_bottom"):ci("alert_towers").hidden = true

	if new_tower then
		wid("map_hud_notification_new_tower"):ci("label_txt_notification_icon").text = _("MAP_NEW_TOWER_ALERT")
	else
		wid("map_hud_notification_new_tower").hidden = true
	end

	if not upgrade_points then
		wid("group_bottom"):ci("alert_upgrades").hidden = true
	end

	local user_data = storage:load_slot()

	wid("group_bottom"):ci("alert_items").hidden = true
	wid("group_bottom"):ci("alert_shop").hidden = features.no_gems or true

	local achievement_claimed_pending = false

	for i = 1, #achievements_data do
		local ach = achievements_data[i]
		local achievement_completed = user_data.achievements[ach.name]

		if achievement_completed then
			local achievement_claimed

			if user_data.achievements_claimed then
				achievement_claimed = table.contains(user_data.achievements_claimed, ach.name)
			end

			if not achievement_claimed then
				achievement_claimed_pending = true
			end
		end
	end

	if IS_MOBILE and achievement_claimed_pending then
		wid("group_bottom_right"):ci("alert_achievements").hidden = false
	else
		wid("group_bottom_right"):ci("alert_achievements").hidden = true
	end

	local heroes_on_sale = PS.services.iap and PS.services.iap:get_hero_sales() or {}

	if IS_MOBILE and #heroes_on_sale > 1 then
		wid("group_sale_button_overlay_heroes").hidden = false
	else
		wid("group_sale_button_overlay_heroes").hidden = true
	end

	local towers_on_sale = PS.services.iap and PS.services.iap:get_tower_sales() or {}

	if IS_MOBILE and #towers_on_sale > 1 then
		wid("group_sale_button_overlay_towers").hidden = false
	else
		wid("group_sale_button_overlay_towers").hidden = true
	end

	wid("group_bottom"):ci("shadow").scale.x = 4
end

function screen_map:is_tutorial_complete()
	local user_data = storage:load_slot()

	for i, v in ipairs(user_data.levels) do
		if v.stars ~= nil then
			return true
		else
			break
		end
	end

	return false
end

function screen_map:show_bars()
	local is_tutorial_complete = self:is_tutorial_complete()

	for _, n in pairs(bar_names) do
		if is_tutorial_complete or string.find(n, "top", 1, true) then
			local v = wid(n)

			v.hidden = false

			if IS_MOBILE then
				if n == "group_offer_icon" then
					local offer, exp_time = marketing:get_active_offer()

					if not offer or not exp_time then
						v.hidden = true
					else
						local rem_time = os.difftime(exp_time, os.time())

						v:ci("label_map_shop").text = GU.format_countdown_time(rem_time, false)
					end
				elseif string.find(n, "group_offer_icon_") then
					v.hidden = true

					if v.season then
						local peristent_offers = marketing:get_candidate_offers(true) or {}

						for k, po in pairs(peristent_offers) do
							if po.season_offer and po.season_offer == v.season then
								v.hidden = false
							end
						end
					end
				end
			end

			ktw:cancel(v)

			local check_ask_rating = n == bar_names[1]

			ktw:tween(v, 0.4, v.pos, {
				x = v.pos_shown.x,
				y = v.pos_shown.y
			}, "out-quad", function()
				if not check_ask_rating then
					return
				end

				local global = storage:load_global()
				local user_data = storage:load_slot()
				local ask_for_rating_levels = RC.v.ask_for_rating_level or {
					4,
					7,
					12
				}
				local last_level_asked = global.rating_last_level_asked

				if last_level_asked and last_level_asked >= ask_for_rating_levels[#ask_for_rating_levels] then
					log.info("CHECK ASK FOR RATING FALSE. PAST LAST LEVEL")

					return
				end

				local ask_for_rating_level = ask_for_rating_levels[1]

				for i = 1, #ask_for_rating_levels do
					if not last_level_asked or last_level_asked < ask_for_rating_levels[i] then
						ask_for_rating_level = ask_for_rating_levels[i]

						break
					end
				end

				log.debug("ask_for_rating_level:%s", ask_for_rating_level)

				if RC.v.ask_for_rating and not features.censored_cn and global and not global.rating_accepted and user_data.levels[ask_for_rating_level] and not user_data.levels[ask_for_rating_level + 1] and not PP:is_underage() then
					global.rating_last_level_asked = ask_for_rating_level

					storage:save_global(global)

					if KR_PLATFORM == "android" then
						self:show_ask_for_rating()
					elseif PS.services.rating then
						PS.services.rating:request_review()
					end
				elseif not RC.v.ask_for_rating then
					log.info("CHECK ASK FOR RATING FALSE. Disabled in remote config")
				elseif not global or global.rating_accepted then
					log.info("CHECK ASK FOR RATING FALSE. No global save, or rating already accepted")
				elseif not user_data.levels[ask_for_rating_level] or user_data.levels[ask_for_rating_level + 1] then
					log.info("CHECK ASK FOR RATING FALSE. Should ask in level " .. ask_for_rating_level)

					if last_level_asked then
						log.info("Already asked in level " .. last_level_asked)

						return
					end
				else
					log.info("CHECK ASK FOR RATING FALSE. Underage")
				end
			end)
		end
	end

	self:update_gems()
end

function screen_map:hide_bars()
	for _, n in pairs(bar_names) do
		local v = wid(n)

		ktw:cancel(v)
		ktw:tween(v, 0.3, v.pos, {
			x = v.pos_hidden.x,
			y = v.pos_hidden.y
		}, "in-quad", function()
			v.hidden = true
		end)
	end
end

function screen_map:show_map_free_gems()
	wid("map_free_gems_view").hidden = false
	wid("map_free_gems_view").scale = V.v(0, 0)

	timer:tween(0.5, wid("map_free_gems_view").scale, {
		x = 1,
		y = 1
	}, "out-back")
end

function screen_map:hide_map_free_gems()
	timer:tween(0.5, wid("map_free_gems_view").scale, {
		x = 0,
		y = 0
	}, "in-back", function()
		wid("map_free_gems_view").hidden = true
	end)
end

function screen_map:give_free_gift(items)
	ktw:cancel(self)
	ktw:after(self, 0.5, function()
		self:update_gems()
		self:refresh_offers(true)
		self:hide_shop()
		self:show_cards(items)
	end)
end

function screen_map:show_difficulty(fn)
	fn = fn or function()
		self:update_badges()
		timer:after(1, function()
			self:show_bars()
		end)
		wid("map_view"):show_flags()
	end

	wid("difficulty_room_view"):show(fn)
end

function screen_map:show_achievements()
	wid("achievements_room_view"):show()

	wid("group_bottom_right"):ci("alert_achievements").hidden = true
end

function screen_map:hide_achievements()
	wid("achievements_room_view"):hide()
end

function screen_map:show_shop()
	wid("shop_room_view"):show()

	wid("group_bottom"):ci("alert_shop").hidden = true
end

function screen_map:show_shop_gems()
	wid("shop_room_view"):show("gems")

	wid("group_bottom"):ci("alert_shop").hidden = true
end

function screen_map:show_shop_offer()
	wid("shop_room_view"):show("offer")

	wid("group_bottom"):ci("alert_shop").hidden = true
end

function screen_map:show_shop_season()
	wid("shop_room_view"):show("season")

	wid("group_bottom"):ci("alert_shop").hidden = true
end

function screen_map:show_shop_dlc()
	wid("shop_room_view"):show("dlc")

	wid("group_bottom"):ci("alert_shop").hidden = true
end

function screen_map:hide_shop()
	wid("shop_room_view"):hide()
end

function screen_map:show_gems_store(no_title)
	wid("gems_store_view"):show(no_title)
end

function screen_map:hide_gems_store()
	wid("gems_store_view"):hide()
end

function screen_map:show_cards(cards)
	wid("card_rewards_view"):show(nil, cards)
end

function screen_map:show_hero_room(show_hero_name, just_purchased)
	wid("hero_room_view"):show(show_hero_name, just_purchased)

	wid("map_hud_notification_new_hero").hidden = true
	wid("group_bottom"):ci("alert_heroes").hidden = true
end

function screen_map:update_hero_room()
	wid("hero_room_view"):update_hero_data()
end

function screen_map:update_tower_room()
	wid("tower_room_view"):update_tower_data()
end

function screen_map:update_item_room()
	wid("item_room_view"):update_item_data()
end

function screen_map:show_product_cards(product_id)
	local p = PS.services.iap:get_product(product_id, true)
	local includes = p.includes_consumables or p.includes

	if string.find(product_id, "gems_") then
		includes = {
			{
				count = 1,
				name = product_id
			}
		}
	elseif includes then
		local queue = table.clone(includes)

		while #queue > 0 do
			local v = table.remove(queue, 1)
			local id = type(v) == "table" and v.name or v
			local sp = PS.services.iap:get_product(id, true)

			if sp then
				local sub_includes = sp.includes_consumables or sp.includes

				if sub_includes then
					table.append(includes, sub_includes)
					table.append(queue, sub_includes)
				end
			end
		end
	end

	if string.find(product_id, "dlc_") then
		if IS_DESKTOP then
			table.insert(includes, 1, product_id)
		end

		local dlc = product_id

		for _, v in pairs(p.includes) do
			if string.starts(v, "dlc_") then
				dlc = v

				break
			end
		end

		local dlc_first_level = U.get_dlc_level_range(dlc)[1]

		wid("map_view"):center_map_on_flags(dlc_first_level, dlc_first_level)

		local user_data = storage:load_slot(nil, true)

		if U.unlock_next_levels_in_ranges({}, user_data.levels, GS, {
			dlc
		}) then
			storage:save_slot(user_data)
		end

		local global = storage:load_global()

		if not global.unlocked_dlcs then
			global.unlocked_dlcs = {}
		end

		if not table.contains(global.unlocked_dlcs, dlc) then
			table.insert(global.unlocked_dlcs, dlc)
			storage:save_global(global)
		end
	end

	screen_map:show_cards(includes)
end

function screen_map:process_new_dlc()
	local user_data = storage:load_slot(nil, true)
	local reached_min_level = user_data.levels[GS.dlcs_unlock_level + 1]

	if reached_min_level and PS.services.iap then
		local is_premium, premium_excludes = PS.services.iap:is_premium()

		if is_premium and premium_excludes == nil then
			log.todo("TODO: is this the case for full premium?")

			return false
		end

		local dlcs = PS.services.iap:get_dlcs(true)

		for _, dlc in pairs(dlcs) do
			local dlc_first_level = U.get_dlc_level_range(dlc)[1]

			if not table.contains(user_data.levels, dlc_first_level) then
				local global = storage:load_global()

				if not global.unlocked_dlcs or not table.contains(global.unlocked_dlcs, dlc) then
					screen_map:show_product_cards(dlc)

					return true
				else
					local user_data = storage:load_slot(nil, true)

					if U.unlock_next_levels_in_ranges({}, user_data.levels, GS, {
						dlc
					}) then
						storage:save_slot(user_data)
					end

					return false
				end
			end
		end
	end

	return false
end

function screen_map:update_active_portraits_with_prefix(prefix)
	local slot = storage:load_slot()

	for i = 1, 2 do
		local portrait_view = wid(prefix .. "_active_portrait_" .. i)
		local hero_name = slot.heroes.team[i]
		local data = screen_map.hero_data[hero_name]
		local thumb_fmt = "heroroom_portraits_%04i"

		portrait_view:set_image(string.format(thumb_fmt, data.icon_idx))
	end

	for i = 1, 2 do
		local portrait_view = wid(prefix .. "_active_portrait_relic_" .. i)
		local relic_name = slot.relics.selected[i]
		local relic = E:get_template(relic_name)

		portrait_view:set_image(string.format("heroroom_upgradeIcons_%04i", relic.relic.rr_icon))
	end
end

function screen_map:hide_hero_room()
	wid("hero_room_view"):hide()
end

function screen_map:show_tower_room(show_tower_name, just_purchased)
	wid("tower_room_view"):show(show_tower_name, just_purchased)

	wid("map_hud_notification_new_tower").hidden = true
	wid("group_bottom"):ci("alert_towers").hidden = true
end

function screen_map:hide_tower_room()
	wid("tower_room_view"):hide()
end

function screen_map:check_tower_room()
	local slot = storage:load_slot()

	if #slot.towers.selected ~= 5 then
		return false
	end

	return true
end

function screen_map:show_item_room(show_item_name, just_purchased)
	wid("item_room_view"):show(show_item_name, just_purchased)
end

function screen_map:hide_item_room()
	wid("item_room_view"):hide()
end

function screen_map:check_item_room()
	local slot = storage:load_slot()

	if #slot.items.selected ~= 5 then
		return false
	end

	return true
end

function screen_map:show_upgrades()
	wid("upgrades_room_view"):show()

	wid("group_bottom"):ci("alert_upgrades").hidden = true
end

function screen_map:hide_upgrades()
	wid("upgrades_room_view"):hide()
end

function screen_map:show_level(level_idx, stars, diff_campaign, diff_heroic, diff_iron)
	wid("level_select_view"):show(level_idx, stars, diff_campaign, diff_heroic, diff_iron)
end

function screen_map:hide_level()
	wid("level_select_view"):hide()
end

function screen_map:hide_popup_options()
	wid("popup_options"):hide("map")
end

function screen_map:hide_top_left_bar()
	local tb = wid("top_left_bar_view")

	if not tb.hidden then
		if tb.showing then
			tb.showing = nil

			timer:cancel(tb.tweener)
		end

		tb.tweener = nil
		tb.hidden = true
	end
end

function screen_map:show_top_left_bar()
	local tb = wid("top_left_bar_view")

	if tb.hidden then
		local safe_frame = SU.get_safe_frame(self.w, self.h, self.ref_w, self.ref_h)

		tb.pos.x, tb.pos.y = safe_frame.l, -tb.size.y
		tb.tweener = timer:tween(0.5, tb.pos, {
			y = safe_frame.t
		}, "out-back", function()
			tb.showing = nil
			tb.tweener = nil
		end)
		tb.hidden = false
		tb.showing = true
	end
end

function screen_map:show_iap_progress()
	wid("processing_view"):show()
end

function screen_map:hide_iap_progress()
	wid("processing_view"):hide()
end

function screen_map:show_error(msg)
	wid("error_view"):show(msg)
end

function screen_map:hide_error()
	wid("error_view"):hide()
end

function screen_map:show_message(kind, arg)
	wid("message_view"):show(kind, arg)
end

function screen_map:hide_message()
	wid("message_view"):hide()
end

function screen_map:show_ask_for_rating()
	wid("message_view"):show("ask_for_rating")
end

function screen_map:hide_ask_for_rating()
	wid("message_view")
end

function screen_map:quit_to_slots()
	local user_data = storage:load_slot()

	storage:save_slot(user_data, nil, true)
	self.done_callback({
		next_item_name = "slots"
	})
end

function screen_map:start_level(level_idx, level_mode, extra_enemies)
	local user_data = storage:load_slot()

	storage:save_slot(user_data, nil, true)
	self.done_callback({
		next_item_name = "game",
		level_idx = level_idx,
		level_mode = level_mode,
		level_difficulty = user_data.difficulty,
		extra_enemies = extra_enemies
	})
end

function screen_map:is_stage_completed(stage, user_data)
	return user_data.levels[stage] and #user_data.levels[stage] > 0
end

function screen_map:is_content_stage_unlocked(content_data, user_data)
	if PS.services.iap then
		local premium, exceptions = PS.services.iap:is_premium()

		if exceptions and content_data.iap then
			return true
		end
	end

	return not content_data.available_at_stage or content_data.available_at_stage <= 1 or screen_map:is_stage_completed(content_data.available_at_stage - 1, user_data)
end

function screen_map:is_seen(key)
	local user_data = storage:load_slot()

	return user_data.seen[key]
end

function screen_map:set_seen(key)
	local user_data = storage:load_slot()

	user_data.seen[key] = true

	storage:save_slot(user_data)
end

function screen_map:refresh_offers(force)
	wid("shop_room_view"):refresh_offers(force)
end

function screen_map:update_gems(amount)
	local user_data = storage:load_slot()

	amount = amount or user_data.gems
	wid("label_map_gems").text = amount

	wid("shop_room_view"):update_gems(amount)
end

function screen_map:update_badges()
	local user_data = storage:load_slot()
	local has_all_upgrades = true

	for k, v in pairs(user_data.upgrades) do
		has_all_upgrades = has_all_upgrades and v == 5
	end
end

function screen_map:update_tower_data()
	if features.censored_cn then
		screen_map.tower_data = map_data.tower_data_iap
		screen_map.tower_order = map_data.tower_order_censored_cn
	elseif not PS.services.iap or PS.services.iap:is_premium() then
		screen_map.tower_data = table.deepclone(map_data.tower_data_free)
		screen_map.tower_order = map_data.tower_order_free
	else
		screen_map.tower_data = map_data.tower_data_iap
		screen_map.tower_order = map_data.tower_order_iap
	end

	if PS.services.iap then
		-- block empty
	end
end

function screen_map:update_item_data()
	screen_map.item_data = table.deepclone(iap_data.shop_data)
	
	if features.censored_cn then
		screen_map.item_order = map_data.item_order_censored_cn
	else
		screen_map.item_order = map_data.item_order
	end
end

function screen_map.q_is_picking_team()
	return wid("hero_room_view").picking_team_slot
end

function screen_map.q_is_picking_tower()
	return wid("tower_room_view").picking_team_slot
end

function screen_map.q_is_flag_focused(ctx)
	for _, v in pairs(screen_map.window:ci("group_map_flags").children) do
		if v:isInstanceOf(StageFlag5) and v:is_focused() then
			return true
		end
	end
end

function screen_map.q_is_modal()
	return screen_map.modal_view ~= nil
end

function screen_map.c_stop_picking_team()
	return wid("hero_room_view"):pick_team_slot_stop()
end

function screen_map.c_stop_picking_tower()
	return wid("tower_room_view"):pick_tower_slot_stop()
end

function screen_map.c_focus_next_flag(ctx, dir)
	screen_map.window:ci("map_view"):focus_next_flag(dir)
end

function screen_map.c_return_main_menu()
	screen_map:quit_to_slots()
end

function screen_map.c_hide_modal()
	if screen_map.modal_view then
		screen_map.modal_view:hide()
	end
end

return screen_map
