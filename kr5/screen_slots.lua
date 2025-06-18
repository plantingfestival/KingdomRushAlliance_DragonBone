local log = require("klua.log"):new("screen_slots")
local class = require("middleclass")
local F = require("klove.font_db")
local I = require("klove.image_db")
local V = require("klua.vector")
local storage = require("storage")
local timer = require("hump.timer").new()
local tween = require("klove.tween").new(timer)
local signal = require("hump.signal")
local S = require("sound_db")
local SU = require("screen_utils")
local km = require("klua.macros")
local GS = require("game_settings")
local i18n = require("i18n")
local input_machine = require("klove.input_state_machine")
local remote_config = require("remote_config")
local PS = require("platform_services")
local privacy_consent = require("privacy_policy_consent")
local features = require("features")

if DBG_SLIDE_EDITOR then
	local debug_editor = require("debug_view_editor")
end

require("constants")
require("gg_views")
require("gg_views_custom")
require("gg_views_game")
require("klove.kui")

local kui_db = require("klove.kui_db")
local var_0_21 = PS and PS.services.news
local var_0_22 = {
	required_sounds = {
		"common",
		"music_screen_slots"
	},
	required_textures = {
		"screen_slots",
		"screens_common_LOCALE",
		"gui_popups",
		"gui_slices"
	}
}

if not IS_MOBILE then
	table.insert(var_0_22.required_textures, "gui_popups_desktop")
end

if var_0_21 and var_0_21.texture_group then
	table.insert(var_0_22.required_textures, var_0_21.texture_group)
end

var_0_22.ref_w = 1728
var_0_22.ref_h = 768
var_0_22.ref_res = TEXTURE_SIZE_ALIAS.ipad

local function var_0_23(arg_1_0)
	return var_0_22.window:get_child_by_id(arg_1_0)
end

var_0_22.signal_handlers = {
	[SGN_PS_STATUS_CHANGED] = function(arg_2_0, arg_2_1, arg_2_2)
		log.debug(SGN_PS_STATUS_CHANGED .. " : %s %s", arg_2_0, arg_2_1)

		if arg_2_0 == "achievements" then
			local var_2_0 = PS.services.cloudsave
			local var_2_1

			var_2_1 = var_2_0 and var_2_0:no_signin()
		end
	end,
	[SGN_PS_SYNC_SLOTS_FINISHED] = function(arg_3_0, arg_3_1, arg_3_2, arg_3_3)
		log.debug(SGN_PS_SYNC_SLOTS_FINISHED .. " : %s %s", arg_3_0, arg_3_1)

		if arg_3_0 == "cloudsave" then
			var_0_22.cloudsave_req_id = nil

			if not var_0_22.popup_processing.hidden and not var_0_22.sync_purchases_req_id then
				var_0_22:hide_cloudsave_progress()

				if arg_3_1 then
					var_0_22.c_show_slots()
				else
					var_0_22:show_cloudsave_error(arg_3_3)
				end
			end

			if not arg_3_1 and PS.services.analytics then
				PS.services.analytics:log_event("kr_error_ps_sync_slots_finished", "status_code", arg_3_3)
			end
		end
	end,
	[SGN_REMOTE_CONFIG_UPDATED] = function(arg_4_0, arg_4_1)
		log.debug(SGN_REMOTE_CONFIG_UPDATED)

		if var_0_21 then
			var_0_21:cache_news()
		end

		local function var_4_0(arg_5_0, arg_5_1)
			local function var_5_0(arg_6_0)
				local var_6_0 = {}

				for iter_6_0 in arg_6_0:gmatch("(%d+)") do
					table.insert(var_6_0, tonumber(iter_6_0))
				end

				return var_6_0
			end

			local var_5_1 = var_5_0(arg_5_0)
			local var_5_2 = var_5_0(arg_5_1)

			for iter_5_0 = 1, math.max(#var_5_1, #var_5_2) do
				local var_5_3 = var_5_1[iter_5_0] or 0
				local var_5_4 = var_5_2[iter_5_0] or 0

				if var_5_3 ~= var_5_4 then
					return var_5_3 < var_5_4
				end
			end

			return false
		end

		if IS_MOBILE and remote_config.v.min_version and var_4_0(version.string_short, remote_config.v.min_version) then
			var_0_22:show_version_block()
		end
	end,
	[SGN_PS_NEWS_CACHED] = function(arg_7_0, arg_7_1, arg_7_2, arg_7_3)
		log.debug(SGN_PS_NEWS_CACHED .. " : %s %s %s", arg_7_0, arg_7_1, arg_7_2)
		var_0_22:check_news(1.5)
	end,
	[SGN_PS_NEWS_IMAGE_CACHED] = function(arg_8_0, arg_8_1, arg_8_2, arg_8_3)
		log.info(SGN_PS_NEWS_IMAGE_CACHED .. " : %s %s %s", arg_8_0, arg_8_1, arg_8_2)

		if var_0_21 then
			local var_8_0 = var_0_21:get_cached_request(arg_8_2)

			if var_8_0 and var_8_0.body then
				var_0_22:refresh_news()
			end
		end
	end,
	[SGN_PS_AUTH_FINISHED] = function(arg_9_0, arg_9_1, arg_9_2, arg_9_3)
		log.debug(SGN_PS_AUTH_FINISHED .. " : %s %s %s", arg_9_0, arg_9_1, arg_9_2, arg_9_3)

		var_0_22.auth_req_id = nil

		var_0_22:hide_auth_progress()

		if arg_9_1 then
			var_0_22.c_show_slots()
		else
			var_0_22:show_auth_error(arg_9_2, arg_9_3)
		end
	end,
	[SGN_PS_CHANNEL_QUIT_REQUESTED] = function(arg_10_0, arg_10_1)
		log.debug(SGN_PS_CHANNEL_QUIT_REQUESTED .. " : %s %s", arg_10_0, arg_10_1)
		var_0_22:show_auth_error(0, arg_10_1)
	end,
	[SGN_PS_SYNC_PURCHASES_FINISHED] = function(arg_11_0, arg_11_1)
		log.debug(SGN_PS_SYNC_PURCHASES_FINISHED .. " : %s %s", arg_11_0, arg_11_1)

		var_0_22.sync_purchases_req_id = nil

		if not var_0_22.popup_processing.hidden and not var_0_22.cloudsave_req_id then
			var_0_22:hide_cloudsave_progress()

			if arg_11_1 then
				var_0_22.c_show_slots()
			else
				var_0_22:show_cloudsave_error("Store sync")
			end
		end

		local var_11_0 = PS.services.iap

		var_0_23("group_more_games").hidden = var_11_0 and var_11_0:is_premium() and not remote_config.v.premium_show_more_games or not var_11_0:is_premium_valid() or not remote_config.v.link_more_games[version.bundle_id] or privacy_consent:is_underage()

		if var_11_0 and not var_11_0:is_premium() then
			var_0_22:check_news(1.6)
		end
	end,
	[SGN_PS_DEEP_LINK_CHANGED] = function(arg_12_0, arg_12_1)
		log.debug(SGN_PS_DEEP_LINK_CHANGED .. " %s", arg_12_1)
		var_0_22:process_deep_link(arg_12_1)
	end,
	[SGN_PS_PUSH_NOTI_SHOULD_SHOW_RATIONALE] = function(arg_13_0)
		if storage:load_global().push_noti_rationale_shown then
			log.debug("push_noti_rationale_view already shown")

			return
		end

		local var_13_0 = var_0_23("popup_message")

		if var_13_0 then
			var_13_0:set_msg(_("PUSH_NOTIFICATIONS_PERMISSION_RATIONALE"))
			var_13_0:enable()
			var_13_0:set_ok_fn(function()
				local var_14_0 = PS.services.push_noti

				if var_14_0 then
					var_14_0:request_permission()
				end
			end)
			var_13_0:set_no_fn(function()
				local var_15_0 = storage:load_global()

				var_15_0.push_noti_rationale_shown = true

				storage:save_global(var_15_0)
			end)
			var_13_0:show()
		end
	end,
	[SGN_PS_PUSH_NOTI_PERMISSION_FINISHED] = function(arg_16_0, arg_16_1)
		log.debug(SGN_PS_PUSH_NOTI_PERMISSION_FINISHED .. " : %s %s", arg_16_0, arg_16_1)

		local var_16_0 = storage:load_global()

		var_16_0.push_noti_rationale_shown = false

		storage:save_global(var_16_0)
	end
}

function var_0_22.init(arg_17_0, arg_17_1, arg_17_2, arg_17_3)
	arg_17_0.done_callback = arg_17_3

	if PS.services.iap and PS.services.iap:get_status() then
		arg_17_0.sync_purchases_req_id = PS.services.iap:sync_purchases(true)
	end

	local var_17_0, var_17_1, var_17_2, var_17_3 = SU.clamp_window_aspect(arg_17_1, arg_17_2, arg_17_0.ref_w, arg_17_0.ref_h)

	arg_17_0.w, arg_17_0.h = arg_17_1, arg_17_2
	arg_17_0.sw = var_17_0
	arg_17_0.sh = var_17_1
	arg_17_0.selected_locale = i18n.current_locale
	GGLabel.static.font_scale = var_17_2
	GGLabel.static.ref_h = arg_17_0.ref_h
	arg_17_0.default_base_scale = SU.get_default_base_scale(var_17_0, var_17_1)
	GG5PopUp.static.base_scale = arg_17_0.default_base_scale

	local var_17_4 = SU.new_screen_ctx(arg_17_0)

	var_17_4.context = "slots"
	var_17_4.hud_scale = SU.get_hud_scale(arg_17_1, arg_17_2, arg_17_0.ref_w, arg_17_0.ref_h)
	var_17_4.is_underage = privacy_consent:is_underage()
	var_17_4.hide_external_links = privacy_consent:is_underage() or features.hide_external_links or false
	var_17_4.hide_privacy_policy = features.hide_privacy_policy or false
	var_17_4.simple_priv = features.simple_privacy_button and true or false
	var_17_4.more_games_with_label = features.more_games_with_label or false
	var_17_4.show_age_rating_popup = features.show_age_rating_popup and true or false
	var_17_4.is_main = true

	if var_17_4.show_age_rating_popup then
		var_17_4.show_age_rating_popup_icon_data = love.graphics.newImage(features.show_age_rating_popup.icon)

		local var_17_5, var_17_6 = var_17_4.show_age_rating_popup_icon_data:getDimensions()

		var_17_4.show_age_rating_popup_icon_anchor = V.v(var_17_5 / 2, var_17_6 / 2)
		var_17_4.show_age_rating_popup_text_key = features.show_age_rating_popup.text_key
	end

	if features.show_options_footer then
		var_17_4.options_footer_text_key = features.show_options_footer.text_key
	end

	var_17_4.is_censored_cn = features.censored_cn and true or false

	local var_17_7 = kui_db:get_table("screen_slots", var_17_4)
	local var_17_8 = KWindow:new_from_table(var_17_7)

	var_17_8.scale = {
		x = var_17_2,
		y = var_17_2
	}
	var_17_8.size = {
		x = var_17_0,
		y = var_17_1
	}
	var_17_8.origin = var_17_3
	var_17_8.timer = timer
	var_17_8.ktw = tween

	local var_17_9 = PS.services.cloudsave

	if var_17_9 then
		arg_17_0.popup_processing = GG5PopUpProcessing:new_from_table(kui_db:get_table("popup_purchasing", var_17_4))
		arg_17_0.popup_processing.pos.x = var_17_8.size.x / 2
		arg_17_0.popup_processing.pos.y = 366.85
		arg_17_0.popup_processing:ci("label_purchasing").text = _("CLOUDSYNC_PLEASE_WAIT")
		arg_17_0.popup_processing_background = KView:new(V.v(var_17_0 * 2, var_17_1 * 2))
		arg_17_0.popup_processing_background.colors = {
			background = {
				0,
				0,
				0,
				200
			}
		}
		arg_17_0.popup_processing_background.alpha = 1
		arg_17_0.popup_processing_background.pos.x = -var_17_8.size.x / 2
		arg_17_0.popup_processing_background.pos.y = 0
		arg_17_0.popup_processing_background.propagate_on_click = true
		arg_17_0.popup_processing_background.propagate_drag = false
		arg_17_0.popup_processing.hidden = true
		arg_17_0.popup_processing_background.hidden = true

		var_17_8:add_child(arg_17_0.popup_processing_background)
		var_17_8:add_child(arg_17_0.popup_processing)
	end

	var_17_8:set_responder(var_17_8)

	arg_17_0.window = var_17_8

	if var_17_9 then
		arg_17_0.auth_req_id = var_17_9:do_signin()
	end

	if IS_MOBILE then
		var_0_23("button_start"):focus(true)

		var_0_23("button_start").on_click = function()
			S:queue("GUIButtonCommon")

			if not var_0_23("group_slots_list").hidden then
				var_0_22.c_hide_slots()
			else
				arg_17_0:hide_buttons()

				if arg_17_0.popup_news and not arg_17_0.popup_news.hidden then
					arg_17_0.popup_news.hidden = true
				end

				if PS then
					if arg_17_0.auth_req_id then
						arg_17_0:show_auth_progress(arg_17_0.auth_req_id)

						return
					elseif arg_17_0.cloudsave_req_id or arg_17_0.sync_purchases_req_id then
						arg_17_0:show_cloudsave_progress()

						return
					else
						local var_18_0 = PS.services.auth
						local var_18_1 = PS.services.cloudsave
						local var_18_2 = PS.services.iap
						local var_18_3 = false

						if var_18_0 and not var_18_0:is_auth() then
							local var_18_4 = var_18_0:auth()

							if var_18_4 then
								arg_17_0.auth_req_id = var_18_4

								arg_17_0:show_auth_progress(var_18_4)

								var_18_3 = true
							end
						end

						if var_18_2 and var_18_2:get_status() and not var_18_2:get_sync_status().purchases then
							local var_18_5 = PS.services.iap:sync_purchases(true)

							if var_18_5 then
								arg_17_0.sync_purchases_req_id = var_18_5

								arg_17_0:show_cloudsave_progress()

								var_18_3 = true
							end
						end

						if var_18_1 and var_18_1:get_status() then
							local var_18_6 = var_18_1:get_sync_status()

							if not var_18_6.slots or os.time() - var_18_6.slots > 300 then
								local var_18_7 = var_18_1:sync_slots()

								if var_18_7 then
									arg_17_0.cloudsave_req_id = var_18_7

									arg_17_0:show_cloudsave_progress()

									var_18_3 = true
								end
							end
						end

						if var_18_3 then
							return
						end
					end
				end

				timer:after(0.1, function()
					var_0_22.c_show_slots()
				end)
			end
		end
	else
		var_0_23("button_start_desktop"):focus(true)

		var_0_23("button_start_desktop").on_click = function(arg_20_0)
			S:queue("GUIButtonCommon")

			if not var_0_23("group_slots_list").hidden then
				var_0_22.c_hide_slots()
			else
				var_0_22.c_show_slots()
			end
		end
		var_0_23("button_quit_desktop").on_click = function(arg_21_0)
			S:queue("GUIButtonCommon")

			local var_21_0 = var_0_23("popup_message")

			var_21_0:set_msg(_("CONFIRM_EXIT"))
			var_21_0:enable()
			var_21_0:set_ok_fn(function()
				arg_21_0:disable(false)
				var_0_22.c_quit()
			end)
			var_21_0:show()
		end
	end

	if IS_MOBILE then
		var_0_23("label_start").text = _("TAP_TO_START")
	end

	var_0_23("button_news").on_click = function()
		S:queue("GUIButtonCommon")
		arg_17_0:show_news()
	end
	var_0_23("button_privacy_policy").on_click = function()
		S:queue("GUIButtonCommon")
		love.system.openURL(remote_config.v.url_privacy_policy[version.bundle_id] or remote_config.v.url_privacy_policy.default)
	end
	var_0_23("button_more_games").on_click = function()
		S:queue("GUIButtonCommon")

		if PS.services.channel then
			PS.services.channel:show_more_games()
		else
			local var_25_0 = remote_config.v.link_more_games[version.bundle_id]

			if not var_25_0 then
				log.error("link_more_games[%s] is nil", version.bundle_id)
			else
				love.system.openURL(var_25_0)
			end
		end
	end
	var_0_23("button_options").on_click = function(arg_26_0)
		S:queue("GUIButtonCommon")
		var_0_23("popup_options"):show("slots")
	end

	if features.censored_cn then
		var_0_23("cn_censored_8plus_button").on_click = function(arg_27_0)
			S:queue("GUIButtonCommon")
			var_0_23("popup_message_china"):show("slots")
		end
	end

	var_0_23("group_slots_list").hidden = true
	var_0_23("group_slots_list").show = function(arg_28_0)
		local var_28_0 = var_0_23("group_slots_list")

		for iter_28_0 = #var_28_0.children, 1, -1 do
			local var_28_1 = var_28_0.children[iter_28_0]

			if var_28_1:isInstanceOf(SlotView) then
				var_28_1:show()
			end
		end

		var_28_0.hidden = false
		var_28_0.pos.y = var_0_23("group_slots_list").pos_hidden.y

		if var_28_0.tweener then
			timer:cancel(var_28_0.tweener)
		end

		var_28_0:disable(false)

		var_28_0.tweener = timer:tween(0.4, var_0_23("group_slots_list").pos, {
			y = var_0_23("group_slots_list").pos_shown.y
		}, "out-back", function()
			var_28_0:enable(false)
		end)
	end
	var_0_23("group_slots_list").hide = function(arg_30_0)
		local var_30_0 = var_0_23("group_slots_list")

		var_30_0:disable(false)

		var_30_0.tweener = timer:tween(0.4, var_0_23("group_slots_list").pos, {
			y = var_0_23("group_slots_list").pos_hidden.y
		}, "in-back", function()
			var_0_23("group_slots_list").hidden = true
			var_0_23("group_slots_list").tweener = nil

			if IS_MOBILE then
				var_0_23("button_start"):focus(true)
			else
				var_0_23("button_start_desktop"):focus(true)
			end
		end)
	end
	var_0_23("button_close_popup").on_click = function()
		S:queue("GUIButtonOut")
		var_0_22:c_hide_slots()
	end
	var_0_23("group_restore").hidden = true

	local var_17_10 = {
		FIRST = {
			{
				"escape",
				input_machine.q_is_view_visible,
				{
					"popup_message"
				},
				input_machine.c_hide_view,
				{
					"popup_message"
				}
			},
			{
				"escape",
				input_machine.q_is_view_visible,
				{
					"popup_news"
				},
				input_machine.c_hide_view,
				{
					"popup_news"
				}
			},
			{
				"escape",
				input_machine.q_is_view_visible,
				{
					"popup_confirm"
				},
				input_machine.c_hide_view,
				{
					"popup_confirm"
				}
			},
			{
				"escape",
				input_machine.q_is_view_visible,
				{
					"popup_locale_list"
				},
				input_machine.c_hide_view,
				{
					"popup_locale_list"
				}
			},
			{
				"escape",
				input_machine.q_is_view_visible,
				{
					"popup_options"
				},
				input_machine.c_hide_view,
				{
					"popup_options"
				}
			},
			{
				"escape",
				input_machine.q_is_view_visible,
				{
					"popup_message_china"
				},
				input_machine.c_hide_view,
				{
					"popup_message_china"
				}
			},
			{
				"escape",
				input_machine.q_is_view_visible,
				{
					"group_slots_list"
				},
				var_0_22.c_hide_slots
			},
			{
				"escape",
				input_machine.q_is_escape_show_quit,
				[4] = var_0_22.c_show_quit_confirm
			},
			{
				"escape",
				input_machine.q_not_from_alias,
				[4] = input_machine.c_show_view,
				[5] = {
					"popup_options",
					"slots"
				}
			},
			{
				"return",
				true,
				[4] = input_machine.c_send_key,
				[5] = {
					"return"
				}
			},
			{
				"tab",
				true,
				[4] = input_machine.c_send_key,
				[5] = {
					"tab"
				}
			},
			{
				"reverse_tab",
				true,
				[4] = input_machine.c_send_key,
				[5] = {
					"reverse_tab"
				}
			},
			{
				"up",
				true,
				[4] = input_machine.c_send_key,
				[5] = {
					"up"
				}
			},
			{
				"down",
				true,
				[4] = input_machine.c_send_key,
				[5] = {
					"down"
				}
			},
			{
				"left",
				true,
				[4] = input_machine.c_send_key,
				[5] = {
					"left"
				}
			},
			{
				"right",
				true,
				[4] = input_machine.c_send_key,
				[5] = {
					"right"
				}
			},
			{
				"pageup",
				input_machine.q_is_view_visible,
				{
					"popup_options"
				},
				input_machine.c_call_view_fn,
				{
					"popup_options",
					"change_page",
					"prev"
				}
			},
			{
				"pagedown",
				input_machine.q_is_view_visible,
				{
					"popup_options"
				},
				input_machine.c_call_view_fn,
				{
					"popup_options",
					"change_page",
					"next"
				}
			},
			{
				"jleftxy",
				input_machine.q_rate_limit,
				[4] = input_machine.c_send_key_axis
			},
			{
				"ja",
				true,
				[4] = input_machine.c_send_key,
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
				[4] = input_machine.c_show_view,
				[5] = {
					"popup_options",
					"slots"
				}
			},
			{
				"jback",
				true,
				[4] = input_machine.c_show_view,
				[5] = {
					"popup_options",
					"slots"
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

	input_machine:init(var_17_10, var_17_8, DEFAULT_KEY_MAPPINGS, storage:load_settings())

	local var_17_11 = storage:load_settings()

	S:set_main_gain_music(var_17_11 and var_17_11.volume_music or 1)
	S:set_main_gain_fx(var_17_11 and var_17_11.volume_fx or 1)

	for iter_17_0, iter_17_1 in pairs(arg_17_0.signal_handlers) do
		signal.register(iter_17_0, iter_17_1)
	end

	remote_config:sync()

	if var_0_21 and not PS.services.remoteconfig then
		var_0_21:cache_news()
	end

	if PS.services.cloudsave and PS.services.cloudsave:get_status() then
		arg_17_0.cloudsave_req_id = PS.services.cloudsave:sync_slots()
	end

	if PS.services.iap and PS.services.iap:get_status() then
		PS.services.iap:sync_products()
	end

	local var_17_12 = {
		"group_more_games",
		"group_privacy_policy",
		"group_news",
		"group_options",
		"button_start",
		"group_slots_list",
		"group_start_desktop"
	}
	local var_17_13 = {}

	for iter_17_2, iter_17_3 in pairs(var_17_12) do
		if var_0_23(iter_17_3) then
			table.insert(var_17_13, var_0_23(iter_17_3))
		end
	end

	SU.apply_base_scale(var_17_13, arg_17_0.default_base_scale)

	if var_0_21 then
		var_0_21.texture_scale = arg_17_0.screen_scale
		arg_17_0.popup_news = var_0_23("popup_news")
	end

	if not S:sound_is_playing("MusicMainMenu") then
		S:queue("MusicMainMenu")
	end

	if not IS_MOBILE then
		var_0_23("bg_exo_main").pos.y = var_0_23("bg_exo_main").pos_shown.y
		var_0_23("bg_exo_logo").pos.y = var_0_23("bg_exo_logo").pos_shown.y
		var_0_23("bg_exo_tentacles").pos.y = var_0_23("bg_exo_tentacles").pos_shown.y
		var_0_23("bg_exo_main").base_scale = V.vv(0.75)
		var_0_23("bg_exo_logo").base_scale = V.vv(0.7)
		var_0_23("bg_exo_tentacles").base_scale = V.vv(0.75)
	end

	var_0_23("bg_exo_main").on_exo_finished = function(arg_33_0, arg_33_1)
		arg_33_0.exo_animation = "idle"
		arg_33_0.loop = true
	end
	var_0_23("bg_exo_logo").on_exo_finished = function(arg_34_0, arg_34_1)
		arg_34_0.exo_animation = "idle"
		arg_34_0.loop = true
	end
	var_0_23("bg_exo_tentacles").on_exo_finished = function(arg_35_0, arg_35_1)
		arg_35_0.exo_animation = "idle"
		arg_35_0.loop = true
	end

	local var_17_14 = var_0_23("intro_overlay")

	tween:tween(var_17_14, 0.33, var_17_14, {
		alpha = 0
	}, "linear", function()
		var_17_14.hidden = true
	end)
	arg_17_0:init_buttons()

	var_0_23("group_more_games").hidden = true
	var_0_23("group_news").hidden = true

	timer:after(1, function()
		arg_17_0:show_buttons()
		arg_17_0:check_deep_links()

		if IS_MOBILE then
			var_0_23("button_start").hidden = false
		end
	end)
	timer:after(1.5, function()
		signal.emit(SGN_PS_SCREEN_SLOTS_READY)

		if KR_PLATFORM == "android" and PS.services.push_noti then
			local var_38_0 = require("marketing"):md_get("session_count") or 0

			log.debug("session_count: %s", var_38_0)

			if var_38_0 > 4 then
				PS.services.push_noti:check_permission()
			end
		end

		signal.emit("ftue-step", "screen_slots")
	end)

	if storage:load_global().launch_count == 1 then
		timer:after(1.5, function()
			local var_39_0 = PS.services.achievements

			if var_39_0 and not privacy_consent:is_underage() then
				var_39_0:do_signin()
			end
		end)

		if PS.services.analytics then
			PS.services.analytics:log_event("kr_pp_first_launch", "age", privacy_consent:is_underage() and "underage" or "overage")
		end
	end

	if PS.services.analytics then
		PS.services.analytics:log_event("kr_screen_init", "file", "screen_slots")
		PS.services.analytics:log_event("kr_pp_launch", "age", privacy_consent:is_underage() and "underage" or "overage")
	end

	if DBG_SLIDE_EDITOR then
		-- block empty
	end
end

function var_0_22.destroy(arg_40_0)
	for iter_40_0, iter_40_1 in pairs(arg_40_0.signal_handlers) do
		signal.remove(iter_40_0, iter_40_1)
	end

	input_machine:destroy(arg_40_0.window)
	tween:clear()
	timer:clear()

	arg_40_0.window.timer = nil
	arg_40_0.window.ktw = nil

	arg_40_0.window:destroy()

	arg_40_0.window = nil

	SU.remove_references(arg_40_0, KView)
end

function var_0_22.update(arg_41_0, arg_41_1)
	arg_41_0.window:update(arg_41_1)
	timer:update(arg_41_1)
end

function var_0_22.draw(arg_42_0)
	arg_42_0.window:draw()
end

function var_0_22.mousepressed(arg_43_0, arg_43_1, arg_43_2, arg_43_3, arg_43_4)
	arg_43_0.window:mousepressed(arg_43_1, arg_43_2, arg_43_3, arg_43_4)
end

function var_0_22.mousereleased(arg_44_0, arg_44_1, arg_44_2, arg_44_3, arg_44_4)
	arg_44_0.window:mousereleased(arg_44_1, arg_44_2, arg_44_3, arg_44_4)
end

function var_0_22.wheelmoved(arg_45_0, arg_45_1, arg_45_2)
	arg_45_0.window:wheelmoved(arg_45_1, arg_45_2)
end

function var_0_22.handle_slot_button(arg_46_0, arg_46_1)
	signal.emit("ftue-step", "click_on_slot")

	local var_46_0 = false

	if not storage:load_slot(arg_46_1) then
		storage:create_slot(arg_46_1)

		var_46_0 = true
	end

	storage:set_active_slot(arg_46_1)

	if var_46_0 and not features.censored_cn then
		local var_46_1 = storage:load_slot(arg_46_1)

		var_46_1.levels = {
			{}
		}

		storage:save_slot(var_46_1)

		director.next_item_args = {
			level_idx = 1,
			level_mode = GAME_MODE_CAMPAIGN,
			level_difficulty = DIFFICULTY_NORMAL
		}
		director.next_item_name = "game"
	else
		arg_46_0.done_callback({
			next_item_name = "map",
			slot_idx = arg_46_1
		})
	end
end

function var_0_22.show_options(arg_47_0)
	local var_47_0 = var_0_23("popup_options")
end

function var_0_22.hide_options(arg_48_0)
	local var_48_0 = var_0_23("popup_options")
end

function var_0_22.start_animation(arg_49_0)
	return
end

local var_0_24 = {
	"group_logo",
	"group_more_games",
	"group_privacy_policy",
	"group_news",
	"group_options",
	"group_8plus"
}

function var_0_22.init_buttons(arg_50_0)
	for iter_50_0, iter_50_1 in pairs(var_0_24) do
		local var_50_0 = var_0_23(iter_50_1)

		if var_50_0 then
			var_50_0.pos_shown = V.v(var_50_0.pos.x, var_50_0.pos.y)

			local var_50_1 = var_0_22.sh / 4

			if iter_50_1 == "group_logo" then
				var_50_1 = var_0_22.sh
			end

			if iter_50_1 == "group_8plus" then
				var_50_1 = var_0_22.sh / 2
			end

			var_50_0.pos_hidden = V.v(var_50_0.pos.x, var_50_0.pos.y + var_50_1 * (var_50_0.pos.y > var_0_22.sh / 2 and 1 or -1))

			if iter_50_1 ~= "group_logo" then
				var_50_0.pos.y = var_50_0.pos_hidden.y
				var_50_0.hidden = true
			end
		end
	end
end

function var_0_22.show_buttons(arg_51_0)
	for iter_51_0, iter_51_1 in pairs(var_0_24) do
		local var_51_0 = var_0_23(iter_51_1)

		if var_51_0 and var_51_0.pos_shown then
			var_51_0.hidden = false

			if var_51_0.tweener then
				timer:cancel(var_51_0.tweener)
			end

			var_51_0.tweener = timer:tween(0.4, var_51_0.pos, {
				x = var_51_0.pos_shown.x,
				y = var_51_0.pos_shown.y
			}, "out-back")
		end
	end

	local var_51_1 = PS.services.iap

	var_0_23("group_more_games").hidden = var_51_1 and var_51_1:is_premium() and not remote_config.v.premium_show_more_games or var_51_1 and not var_51_1:is_premium_valid() or not remote_config.v.link_more_games[version.bundle_id] or privacy_consent:is_underage()
	var_0_23("group_news").hidden = var_51_1 and var_51_1:is_premium() and not remote_config.v.premium_show_news or var_51_1 and not var_51_1:is_premium_valid() or not var_0_21 or privacy_consent:is_underage()

	if IS_MOBILE then
		var_0_23("button_start"):enable()
		tween:cancel(var_0_23("label_start"))
		tween:tween(var_0_23("label_start"), 0.3, var_0_23("label_start"), {
			alpha = 1
		})
	else
		local var_51_2 = var_0_23("group_start_desktop")

		var_51_2.hidden = false

		var_51_2:disable(false)
		tween:cancel(var_51_2)
		tween:tween(var_51_2, 0.3, var_51_2, {
			alpha = 1
		}, "linear", function()
			var_51_2:enable(false)
		end)
	end
end

function var_0_22.hide_buttons(arg_53_0)
	for iter_53_0, iter_53_1 in pairs(var_0_24) do
		local var_53_0 = var_0_23(iter_53_1)

		if var_53_0 and var_53_0.pos_hidden then
			if var_53_0.tweener then
				timer:cancel(var_53_0.tweener)
			end

			var_53_0.tweener = timer:tween(0.4, var_53_0.pos, {
				x = var_53_0.pos_hidden.x,
				y = var_53_0.pos_hidden.y
			}, "out-back", function()
				var_53_0.hidden = true
			end)
		end
	end

	if IS_MOBILE then
		var_0_23("button_start"):disable(false)
		tween:cancel(var_0_23("label_start"))
		tween:tween(var_0_23("label_start"), 0.3, var_0_23("label_start"), {
			alpha = 0
		})
	else
		local var_53_1 = var_0_23("group_start_desktop")

		var_53_1:disable(false)
		tween:cancel(var_53_1)
		tween:tween(var_53_1, 0.3, var_53_1, {
			alpha = 0
		}, "linear", function()
			var_53_1.hidden = true
		end)
	end
end

function var_0_22.check_deep_links(arg_56_0)
	if PS.services.deep_links then
		local var_56_0 = PS.services.deep_links:get_link()

		if var_56_0 then
			var_0_22:process_deep_link(var_56_0)
		end
	end
end

function var_0_22.process_deep_link(arg_57_0, arg_57_1)
	if features.has_restore_savegame and var_0_23("group_restore") and arg_57_1 ~= nil then
		if not string.match(arg_57_1, remote_config.v.restore_extract_token_regex) then
			log.error("deep link does not match restore format : %s", arg_57_1)

			return
		else
			if PS.services.deep_links then
				PS.services.deep_links:accept_link(arg_57_1)
			end

			var_0_23("group_restore"):show(arg_57_1)

			return
		end
	else
		log.error("group_restore is missing. skipping restore")
	end
end

function var_0_22.check_news(arg_58_0, arg_58_1)
	if not var_0_21 then
		return
	end

	if PS.services.iap then
		local var_58_0 = PS.services.iap

		if not var_58_0:is_premium_valid() or var_58_0:is_premium() and not remote_config.v.premium_show_news then
			return
		end
	end

	if privacy_consent:is_underage() or var_0_23("group_slots_list").hidden == false then
		return
	end

	local function var_58_1(arg_59_0)
		tween:cancel(arg_59_0)
		tween:script(arg_59_0, function(arg_60_0)
			if not arg_59_0.base_scale_orig then
				arg_59_0.base_scale_orig = arg_59_0.base_scale and table.deepclone(arg_59_0.base_scale) or {
					x = 1,
					y = 1
				}
			end

			local var_60_0 = arg_59_0.base_scale_orig

			while true do
				tween:tween(arg_59_0, 0.5, arg_59_0.base_scale, {
					x = 0.95 * var_60_0.x,
					y = 0.95 * var_60_0.y
				}, "in-out-sine")
				arg_60_0(0.501)
				tween:tween(arg_59_0, 0.5, arg_59_0.base_scale, {
					x = 1 * var_60_0.x,
					y = 1 * var_60_0.y
				}, "in-out-sine")
				arg_60_0(0.501)

				if arg_59_0.stop_animation then
					arg_59_0.base_scale = V.v(1, 1)

					return
				end
			end
		end)
	end

	local var_58_2 = var_0_23("group_news")

	if var_0_21 and var_0_21:has_unseen() then
		if not var_58_2.timer then
			var_58_1(var_58_2)

			var_58_2.timer = true
		end

		var_58_2.hidden = nil
	elseif var_0_21 and var_0_21:get_news() then
		if var_58_2.timer then
			var_58_2.stop_animation = true
			var_58_2.timer = nil
		end

		var_58_2.hidden = nil
	else
		var_58_2.hidden = true
	end

	if var_0_21 then
		local var_58_3, var_58_4 = var_0_21:has_force_show()

		if var_58_3 then
			if arg_58_1 then
				local var_58_5 = var_0_23("popup_news")
				local var_58_6 = arg_58_0.window.ktw

				var_58_6:cancel(var_58_5)
				var_58_6:after(var_58_5, arg_58_1, function()
					arg_58_0:show_news(true, var_58_4)
				end)
			else
				arg_58_0:show_news(true, var_58_4)
			end
		end
	end
end

function var_0_22.show_news(arg_62_0, arg_62_1, arg_62_2)
	local var_62_0 = var_0_21 and var_0_21:get_news()

	if not var_62_0 then
		return
	end

	if PS.services.analytics then
		PS.services.analytics:log_event("kr_news_shown", "forced", arg_62_1 and 1 or 0)
	end

	if not IS_MOBILE and arg_62_0.popup_news and arg_62_0.popup_news.contents and GG5PopUp.static.base_scale and arg_62_0.popup_news.contents.base_scale == GG5PopUp.static.base_scale then
		arg_62_0.popup_news.contents.base_scale = table.deepclone(GG5PopUp.static.base_scale)
		arg_62_0.popup_news.contents.base_scale = V.vv(arg_62_0.popup_news.contents.base_scale.x * 1.25)
	end

	var_0_21:mark_seen()
	arg_62_0.popup_news:ci("group_news_container"):remove_children()

	local var_62_1 = 1040
	local var_62_2 = var_62_1 * (#var_62_0 + 2)
	local var_62_3 = arg_62_0.popup_news.slider_view

	var_62_3.size = V.v(var_62_2, arg_62_0.window.size.y)
	arg_62_0.popup_news.slider_container.size.x = 1040
	arg_62_0.popup_news.slider_container.size.y = 530
	var_62_3.drag_limits = V.r(0, 0, -var_62_2 + var_62_1, 0)
	var_62_3.elastic_limits = V.r(-var_62_2, 0, var_62_2 + var_62_1 + 200, 0)

	local var_62_4 = 0
	local var_62_5 = {}

	table.insert(var_62_5, var_62_0[#var_62_0])

	for iter_62_0, iter_62_1 in ipairs(var_62_0) do
		table.insert(var_62_5, iter_62_1)
	end

	table.insert(var_62_5, var_62_0[1])
	arg_62_0.popup_news:set_pages(#var_62_0)

	local var_62_6

	for iter_62_2 = 1, #var_62_5 do
		local var_62_7 = var_62_5[iter_62_2]

		if iter_62_2 == 2 then
			var_62_6 = var_62_7
		end

		local var_62_8 = KImageView:new_from_table(kui_db:get_table("news_item_view_kr5"))
		local var_62_9 = var_62_8:get_child_by_id("news_item_loading")
		local var_62_10 = var_62_8:get_child_by_id("news_item_image")
		local var_62_11 = var_62_8:get_child_by_id("news_item_text")

		if not var_62_7.image and not var_62_7.text then
			-- block empty
		else
			if var_62_7.image then
				if not I:i(var_62_7.image, true) then
					var_0_21:cache_image(var_62_7.image)

					var_62_8.pending_img = var_62_7.image
					var_62_9.hidden = nil
					var_62_10.hidden = true
					var_62_9.timer = true

					timer:script(function(arg_63_0)
						local var_63_0 = var_62_9

						while true do
							var_63_0.r = 0

							timer:tween(1, var_63_0, {
								r = -2 * math.pi
							})
							arg_63_0(1)
						end
					end)
				else
					var_62_10:set_image(var_62_7.image)

					var_62_10.hidden = false
				end
			else
				var_62_9.hidden = true
				var_62_10.hidden = true
			end

			if var_62_7.text and var_62_7.text ~= "" then
				var_62_11.text = var_62_7.text
				var_62_11.hidden = false
			else
				var_62_11.text = ""
				var_62_11.hidden = true
			end

			if var_62_7.link then
				var_62_8.news_url = var_62_7.link

				function var_62_11.on_click()
					var_62_3:open_link()
				end

				var_62_10.on_click = var_62_11.on_click
			end

			var_62_8.pos.x = var_62_8.pos.x + var_62_8.size.x * var_62_4
			var_62_8.post = var_62_7

			var_62_3:add_child(var_62_8)

			var_62_4 = var_62_4 + 1
		end
	end

	if var_62_6 then
		signal.emit(SGN_PS_NEWS_URL_SHOWN, var_62_6.link, "news")
	end

	arg_62_0:refresh_news()

	if arg_62_1 and arg_62_2 then
		log.debug("jumping to force_idx: %s", arg_62_2)
		arg_62_0.popup_news:jump_to_page(arg_62_2)
	end

	arg_62_0.popup_news:show()

	var_62_3.pos.x = -var_62_1
end

function var_0_22.hide_news(arg_65_0)
	arg_65_0:check_news()
	arg_65_0.popup_news:hide()
end

function var_0_22.refresh_news(arg_66_0)
	local var_66_0 = 15
	local var_66_1 = 200
	local var_66_2 = 2
	local var_66_3 = 0
	local var_66_4 = arg_66_0.popup_news:ci("group_news_container")

	for iter_66_0, iter_66_1 in ipairs(var_66_4.children) do
		local var_66_5 = iter_66_1:get_child_by_id("news_item_bg")
		local var_66_6 = iter_66_1:get_child_by_id("news_item_loading")
		local var_66_7 = iter_66_1:get_child_by_id("news_item_image")
		local var_66_8 = iter_66_1:get_child_by_id("news_item_text")

		if iter_66_1.pending_img and I:i(iter_66_1.pending_img, true) then
			var_66_7:set_image(iter_66_1.pending_img)

			var_66_7.hidden = false
			var_66_6.hidden = true
			iter_66_1.pending_img = nil
		end

		local var_66_9 = 1
		local var_66_10 = 0

		if not var_66_7.hidden then
			local var_66_11 = var_66_7.size.y
			local var_66_12 = var_66_5.size.x / var_66_7.size.x

			var_66_7.scale.x = var_66_12
			var_66_7.scale.y = var_66_12
		elseif not var_66_6.hidden then
			local var_66_13 = var_66_1
			local var_66_14 = 1
		end

		if var_66_8.hidden then
			var_66_8.size.y = 0
		else
			local var_66_15, var_66_16, var_66_17 = var_66_8:get_wrap_lines()
			local var_66_18 = var_66_16 * var_66_8:get_font_height()
			local var_66_19 = var_66_8:get_font_descent()

			var_66_8.size.y = var_66_18 - var_66_19
			var_66_8.text_size.y = var_66_18 - var_66_19
		end
	end
end

function var_0_22.show_age_rating_popup(arg_67_0)
	var_0_23("age_rating_label").text_key = features.show_age_rating_popup.text_key

	local var_67_0 = var_0_23("age_rating_popup")
	local var_67_1 = var_67_0.pos_shown and var_67_0.pos_shown.y or 160

	var_0_23("overlay_view").hidden = false
	var_0_23("overlay_view").alpha = 0

	timer:tween(0.4, var_0_23("overlay_view"), {
		alpha = 1
	})

	var_67_0.hidden = false

	timer:tween(0.4, var_0_23("age_rating_popup").pos, {
		y = var_67_1
	}, "out-back")
end

function var_0_22.hide_age_rating_popup(arg_68_0)
	local var_68_0 = var_0_23("age_rating_popup")
	local var_68_1 = var_68_0.pos_hidden and var_68_0.pos_hidden.y or -150

	timer:tween(0.4, var_0_23("overlay_view"), {
		alpha = 0
	}, "in-back", function()
		var_0_23("overlay_view").hidden = true
	end)
	timer:tween(0.4, var_0_23("age_rating_popup").pos, {
		y = var_68_1
	}, "in-back", function()
		var_0_23("age_rating_popup").hidden = true
	end)
end

function var_0_22.show_cloudsave_error(arg_71_0, arg_71_1)
	if not arg_71_0.popup_error then
		arg_71_0.popup_error = GG5PopUpError:new_from_table(kui_db:get_table("popup_error", nil))
		arg_71_0.popup_error.pos.x = arg_71_0.window.size.x / 2
		arg_71_0.popup_error.pos.y = 366.85
		arg_71_0.popup_error.hidden = false
		arg_71_0.popup_error:ci("label_button_ok").text = _("BUTTON_DONE")
		arg_71_0.popup_error:ci("button_popup_confirm_ok").on_click = function()
			arg_71_0.popup_error.hidden = true

			var_0_22.c_show_slots()
		end

		arg_71_0.window:add_child(arg_71_0.popup_error)
	end

	arg_71_0.popup_error.hidden = false

	arg_71_0.popup_error:show(string.format("Cloud error code: %s", arg_71_1))
end

function var_0_22.show_version_block(arg_73_0, arg_73_1)
	if not arg_73_0.popup_error then
		arg_73_0.popup_error = GG5PopUpError:new_from_table(kui_db:get_table("popup_error", nil))
		arg_73_0.popup_error.pos.x = arg_73_0.window.size.x / 2
		arg_73_0.popup_error.pos.y = 366.85
		arg_73_0.popup_error.hidden = false
		arg_73_0.popup_error:ci("label_error_msg").text = _("UPDATE_POPUP")
		arg_73_0.popup_error:ci("label_button_ok").text = _("BUTTON_DONE")
		arg_73_0.popup_error:ci("button_popup_confirm_ok").on_click = function()
			love.system.openURL(remote_config.v.url_store[version.bundle_id] or remote_config.v.url_store.default)
		end

		arg_73_0.window:add_child(arg_73_0.popup_error)
		var_0_22:hide_buttons()
		var_0_22:c_hide_slots()

		var_0_22.block = true

		var_0_23("button_start"):disable(true)
	end

	arg_73_0.popup_error.hidden = false

	arg_73_0.popup_error:show(_("ALERT_VERSION"))
end

function var_0_22.show_cloudsave_progress(arg_75_0)
	arg_75_0.popup_processing.hidden = false
	arg_75_0.popup_processing_background.hidden = false
end

function var_0_22.hide_cloudsave_progress(arg_76_0)
	arg_76_0.popup_processing.hidden = true
	arg_76_0.popup_processing_background.hidden = true
end

function var_0_22.show_auth_error(arg_77_0, arg_77_1, arg_77_2)
	local var_77_0
	local var_77_1
	local var_77_2

	if arg_77_2 and arg_77_2 ~= "" then
		local var_77_3

		var_77_3, var_77_1, var_77_2 = unpack(string.split(arg_77_2, "|"))

		log.error("title:%s content:%s", var_77_1, var_77_2)
	end

	if not arg_77_0.popup_error then
		arg_77_0.popup_error = GG5PopUpError:new_from_table(kui_db:get_table("popup_error", nil))
		arg_77_0.popup_error.pos.x = arg_77_0.window.size.x / 2
		arg_77_0.popup_error.pos.y = 366.85
		arg_77_0.popup_error.hidden = false
		arg_77_0.popup_error:ci("label_button_ok").text = _("BUTTON_DONE")
		arg_77_0.popup_error:ci("button_popup_confirm_ok").on_click = function()
			arg_77_0.popup_error.hidden = true
		end

		arg_77_0.window:add_child(arg_77_0.popup_error)
	end

	local var_77_4 = ""

	if var_77_1 then
		var_77_4 = var_77_1 .. "\n"
	end

	if var_77_2 then
		var_77_4 = var_77_4 .. var_77_2
	end

	if var_77_4 == "" then
		var_77_4 = _("ERROR_MESSAGE_GENERIC") .. "\n" .. tostring(arg_77_1)
	end

	local var_77_5 = "Auth error" .. "\n" .. tostring(var_77_4)

	arg_77_0.popup_error.hidden = false

	arg_77_0.popup_error:show(var_77_5)
end

function var_0_22.show_auth_progress(arg_79_0, arg_79_1)
	arg_79_0.popup_processing.hidden = false
	arg_79_0.popup_processing_background.hidden = false
end

function var_0_22.hide_auth_progress(arg_80_0)
	arg_80_0.popup_processing.hidden = true
	arg_80_0.popup_processing_background.hidden = true
end

function var_0_22.c_show_slots()
	if var_0_22.block then
		return
	end

	if not IS_MOBILE then
		local var_81_0 = var_0_22.window.ktw
		local var_81_1 = var_0_23("bg_exo_logo")

		var_81_0:cancel(var_81_1)
		var_81_0:tween(var_81_1, 0.2, var_81_1.pos, {
			y = var_81_1.pos_up.y
		}, "out-quad")
		var_81_0:tween(var_81_1, 0.2, var_81_1.scale, {
			x = var_81_1.scale_up.x,
			y = var_81_1.scale_up.y
		}, "out-quad")
		var_0_23("group_start_desktop"):disable(false)
	end

	var_0_23("group_slots_list").base_scale = V.vv(OVT(0.9, OV_PHONE, 0.9, OV_TABLET, 0.5, OV_DESKTOP, 0.6))

	var_0_23("group_slots_list"):show()
end

function var_0_22.c_hide_slots(arg_82_0, arg_82_1)
	if not IS_MOBILE then
		local var_82_0 = var_0_22.window.ktw
		local var_82_1 = var_0_23("bg_exo_logo")

		var_82_0:cancel(var_82_1)
		var_82_0:tween(var_82_1, 0.8, var_82_1.pos, {
			y = var_82_1.pos_shown.y
		}, "in-out-back")
		var_82_0:tween(var_82_1, 0.8, var_82_1.scale, {
			x = 1,
			y = 1
		}, "out-quad")
		var_0_23("group_start_desktop"):enable()
	end

	var_0_23("group_slots_list"):hide()

	if arg_82_1 == nil then
		timer:after(0.4, function()
			var_0_22:show_buttons()
		end)
	end
end

function var_0_22.c_show_quit_confirm(arg_84_0, arg_84_1)
	S:queue("GUIButtonCommon")

	local var_84_0 = var_0_23("popup_message")

	var_84_0:set_msg(_("CONFIRM_EXIT"))
	var_84_0:enable()
	var_84_0:set_ok_fn(function()
		var_0_22.c_quit()
	end)
	var_84_0:show()
end

function var_0_22.q_channel_quit()
	if PS.services.channel and PS.services.channel:should_hide_quit_prompt() then
		return true
	end
end

function var_0_22.c_channel_quit()
	PS.services.channel:quit_game()
end

function var_0_22.c_quit()
	var_0_22.done_callback({
		quit = true
	})
end

SlotView = class("SlotView", KView)

function SlotView.initialize(arg_89_0)
	local function var_89_0(arg_90_0)
		return arg_89_0:get_child_by_id(arg_90_0)
	end

	SlotView.super.initialize(arg_89_0)

	local var_89_1 = string.split(arg_89_0.id, "_")

	arg_89_0.slot_idx = var_89_1[#var_89_1]
	var_89_0("slot_used").on_click = function()
		S:queue("GUIButtonCommon")
		var_0_22:handle_slot_button(arg_89_0.slot_idx)
	end
	var_89_0("slot_empty").on_click = function()
		S:queue("GUIButtonCommon")
		var_0_22:handle_slot_button(arg_89_0.slot_idx)
	end
	var_89_0("slot_delete_request").on_click = function()
		S:queue("GUIButtonCommon")

		var_89_0("slot_used").hidden = true
		var_89_0("slot_delete").hidden = false

		var_89_0("slot_delete_cancel"):focus(true)
	end
	var_89_0("slot_delete_cancel").on_click = function()
		S:queue("GUIButtonCommon")

		var_89_0("slot_used").hidden = false
		var_89_0("slot_delete").hidden = true

		var_89_0("slot_used"):focus(true)
	end
	var_89_0("slot_delete_confirm").on_click = function()
		S:queue("GUIButtonCommon")
		arg_89_0:delete_slot(arg_89_0.slot_idx)
	end
	var_89_0("label_slot_name").text = string.format("%s %i", _("SLOT_NAME"), tostring(arg_89_0.slot_idx))

	arg_89_0:show()
end

function SlotView.show(self)
	local function get_child_by_id(id)
		return self:get_child_by_id(id)
	end

	local slot = storage:load_slot(self.slot_idx, true)

	if not slot then
		get_child_by_id("slot_used").hidden = true
		get_child_by_id("slot_empty").hidden = false
		get_child_by_id("slot_delete").hidden = true

		get_child_by_id("slot_empty"):focus(true)
	else
		get_child_by_id("slot_used").hidden = false
		get_child_by_id("slot_empty").hidden = true
		get_child_by_id("slot_delete").hidden = true

		get_child_by_id("slot_used"):focus(true)

		local num_progress, num_heroic, num_iron = storage:get_slot_stats(slot)
		num_heroic, num_iron = math.min(num_heroic, GS.last_level), math.min(num_iron, GS.last_level)
		local num_stars = num_progress + (num_heroic + num_iron) * (GS.stars_per_mode == 0 and -1 or 0)

		get_child_by_id("label_stars").text = tostring(num_stars) .. "/" .. tostring(GS.max_stars)
		get_child_by_id("label_heroic").text = tostring(num_heroic)
		get_child_by_id("label_iron").text = tostring(num_iron)
	end
end

function SlotView.delete_slot(arg_98_0)
	storage:delete_slot(arg_98_0.slot_idx)
	arg_98_0:show()
end

local var_0_25 = 1
local var_0_26 = 2
local var_0_27 = 3
local var_0_28 = 4
local var_0_29 = 5

RestoreView = class("RestoreView", KView)

function RestoreView.initialize(arg_99_0, arg_99_1)
	KView.initialize(arg_99_0, arg_99_1)

	arg_99_0:ci("restore_view_close_button").on_click = function(arg_100_0)
		S:queue("GUIButtonOut")
		arg_99_0:hide()
	end
end

function RestoreView.show(arg_101_0, arg_101_1)
	local function var_101_0(arg_102_0, arg_102_1, arg_102_2, arg_102_3, arg_102_4, arg_102_5)
		log.debug("cb_restore(status:%s, req.id:%s url:%s http_code:%s)", arg_102_0, arg_102_1.id, arg_102_2, arg_102_3)

		local var_102_0
		local var_102_1

		if arg_102_0 ~= 0 then
			local var_102_2 = string.format("http error: request failed. status:%s url:%s", arg_102_0, arg_102_2)

			log.error(var_102_2)
			arg_101_0:show_error(var_0_25, var_102_2)

			return
		elseif not arg_102_5 then
			local var_102_3 = string.format("http error: data is empty for url %s", arg_102_2)

			log.error(var_102_3)
			arg_101_0:show_error(var_0_26, var_102_3)

			return
		end

		arg_101_0.data = arg_102_5

		local var_102_4, var_102_5 = PS.services.http:parse_json(arg_102_5)
		local var_102_6 = var_102_5

		if not var_102_4 then
			local var_102_7 = string.format("http error: failed parsing json %s", arg_102_5)

			log.error(var_102_7)
			arg_101_0:show_error(var_0_27, var_102_7)

			return
		else
			arg_101_0:refresh(var_102_6)
		end
	end

	log.debug("requesting restore data...")

	local var_101_1 = string.match(arg_101_1, remote_config.v.restore_extract_token_regex)

	if not var_101_1 then
		local var_101_2 = string.format("link error: failed to extract the token from %s", arg_101_1)

		log.error(var_101_2)
		arg_101_0:show_error(var_0_28, var_101_2)

		return
	end

	local var_101_3 = string.format(remote_config.v.restore_url_fmt, var_101_1)
	local var_101_4 = {
		accept = "application/text",
		["ih-bundleId"] = version.bundle_id,
		ih_bundle = version.bundle_id,
		ih_appversion = version.string_short
	}

	arg_101_0.rid = PS.services.http:get(var_101_3, var_101_4, var_101_0, 30)
	arg_101_0:ci("restore_in_progress").hidden = false

	for iter_101_0, iter_101_1 in pairs({
		"restore_error_label",
		"restore_error_code_label",
		"restore_pick_slot_label",
		"restore_pick_slot_add_gems_label",
		"restore_new_stats",
		"restore_add_gems",
		"restore_slots"
	}) do
		local var_101_5 = arg_101_0:ci(iter_101_1)

		if var_101_5 then
			var_101_5.hidden = true
		end
	end

	if var_0_23("group_slots_list") and not var_0_23("group_slots_list").hidden then
		var_0_22:c_hide_slots({}, true)
	end

	var_0_22:hide_buttons()

	arg_101_0.hidden = false
end

function RestoreView.hide(arg_103_0)
	var_0_22:show_buttons()

	arg_103_0.hidden = true
end

function RestoreView.refresh(arg_104_0, arg_104_1)
	log.debug("restore_data data:%s", arg_104_1)

	local var_104_0, var_104_1 = storage:restore_slot(arg_104_1)

	if DEBUG then
		arg_104_0._new_slot = var_104_0
		arg_104_0._only_gems = var_104_1
	end

	if not var_104_0 then
		local var_104_2 = string.format("the restore data is invalid")

		log.error(var_104_2)
		arg_104_0:show_error(var_0_29, var_104_2)

		return
	end

	arg_104_0:ci("restore_in_progress").hidden = true
	arg_104_0:ci("restore_error_label").hidden = true
	arg_104_0:ci("restore_error_code_label").hidden = true
	arg_104_0:ci("restore_slots").hidden = false

	if var_104_1 then
		arg_104_0:ci("restore_pick_slot_add_gems_label").hidden = false

		local var_104_3 = arg_104_0:ci("restore_add_gems")

		var_104_3.hidden = false
		var_104_3:ci("l_gems").text = tostring(var_104_0.gems)
	else
		arg_104_0:ci("restore_pick_slot_label").hidden = false

		local var_104_4, var_104_5, var_104_6 = storage:get_slot_stats(var_104_0)
		local var_104_7 = var_104_4 + (var_104_5 + var_104_6) * (GS.stars_per_mode == 0 and -1 or 0)
		local var_104_8 = arg_104_0:ci("restore_new_stats")

		var_104_8.hidden = false
		var_104_8:ci("l_stars").text = tostring(var_104_7) .. "/" .. tostring(GS.max_stars)
		var_104_8:ci("l_heroic").text = tostring(var_104_5)
		var_104_8:ci("l_iron").text = tostring(var_104_6)
	end

	for iter_104_0, iter_104_1 in pairs(arg_104_0:ci("restore_slots").children) do
		iter_104_1:ci("slot_used").on_click = function()
			S:queue("GUIButtonCommon")

			if var_104_1 then
				log.debug("adding %s gems to slot %s", var_104_0.gems, iter_104_1.slot_idx)

				local var_105_0 = storage:load_slot(iter_104_1.slot_idx)

				var_105_0.gems = var_105_0.gems or 0
				var_105_0.gems = var_105_0.gems + var_104_0.gems or 0

				storage:save_slot(var_105_0, iter_104_1.slot_idx, true)
			else
				log.debug("replacing slot %s with new restore data", iter_104_1.slot_idx)
				storage:delete_slot(iter_104_1.slot_idx)
				storage:save_slot(var_104_0, iter_104_1.slot_idx, true)
			end

			arg_104_0:hide()
		end
		iter_104_1:ci("slot_empty").on_click = function()
			S:queue("GUIButtonCommon")
			log.debug("using empty slot %s with new restore data", iter_104_1.slot_idx)
			storage:save_slot(var_104_0, iter_104_1.slot_idx, true)
			arg_104_0:hide()
		end
		iter_104_1:ci("slot_delete_cancel").on_click = function()
			return
		end
		iter_104_1:ci("slot_delete_confirm").on_click = function()
			return
		end
		iter_104_1:ci("slot_delete_request").hidden = true

		iter_104_1:show()
	end
end

function RestoreView.show_error(arg_109_0, arg_109_1, arg_109_2)
	log.error("showing error code %s : %s", arg_109_1, arg_109_2)

	arg_109_0:ci("restore_error_label").hidden = false
	arg_109_0:ci("restore_error_code_label").hidden = false
	arg_109_0:ci("restore_error_code_label").text = "ERROR CODE:" .. tostring(arg_109_1)

	for iter_109_0, iter_109_1 in pairs({
		"restore_in_progress",
		"restore_pick_slot_label",
		"restore_pick_slot_add_gems_label",
		"restore_new_stats",
		"restore_add_gems",
		"restore_slots"
	}) do
		local var_109_0 = arg_109_0:ci(iter_109_1)

		if var_109_0 then
			var_109_0.hidden = true
		end
	end
end

return var_0_22
