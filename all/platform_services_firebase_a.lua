-- chunkname: @./all/platform_services_firebase_a.lua

local log = require("klua.log"):new("platform_services_firebase_a")
local signal = require("hump.signal")

require("klua.table")
require("klua.string")
require("constants")

local UPGR = require("upgrades")
local PP = require("privacy_policy_consent")
local fba = {}

fba.can_be_paused = true
fba.update_interval = 3
fba.SRV_ID = 51
fba.SRV_DISPLAY_NAME = "Firebase Analytics"
fba.signal_handlers = {
	["got-achievement"] = function(ach_id)
		fba:log_event("kr_got_achievement", "id", ach_id)
	end,
	[SGN_MARKETING_OFFER_SHOWN] = function(o_name)
		fba:log_event("kr_offer_shown", "name", o_name)
	end,
	[SGN_MARKETING_OFFER_ICON_TOUCHED] = function(o_name)
		fba:log_event("kr_offer_icon_touched", "name", o_name)
	end,
	[SGN_PS_NEWS_URL_CLICKED] = function(url)
		fba:log_event("kr_news_clicked", "url", url)
	end,
	[SGN_PS_PURCHASE_PRODUCT_FINISHED] = function(srv, ok, prod, currency, is_restored)
		if is_restored then
			fba:log_event("kr_purchase_restore", "prod_id", prod)
		elseif currency ~= nil and currency ~= "" then
			fba:log_event("kr_purchase_" .. currency, "prod_id", prod)
		else
			if currency ~= nil and currency ~= "" then
				fba:log_event("kr_purchase_" .. currency, "prod_id", prod)
			else
				fba:log_event("kr_purchase", "prod_id", prod)
			end

			if string.starts(prod, "gem_") then
				fba:log_event("kr_purchase_product_gem", "prod_id", prod)
			end

			if game and game.game_gui ~= nil then
				fba:log_event("kr_purchase_in_game", "prod_id", prod)
			end
		end
	end,
	[SGN_PS_PREMIUM_UNLOCKED] = function(srv, id)
		fba:log_event("premium_unlock_" .. id)
	end,
	[SGN_PS_AD_SHOW_VIDEO_FINISHED] = function(srv, success, data, status)
		if success then
			fba:log_event("kr_ad_rewarded", "shown_in_game", tostring(game and game.game_gui ~= nil))
		end
	end,
	["game-start"] = function(store)
		if IS_TRILOGY then
			fba:log_event("kr_game_init", "level", tostring(store.level_idx))

			if store.level_challenge then
				fba:log_event("kr_ch_init", "acid", tostring(store.level_challenge.acid))
			end
		else
			local params = {
				{
					"level_idx",
					store.level_idx
				},
				{
					"level_mode",
					store.level_mode
				},
				{
					"level_difficulty",
					store.level_difficulty
				},
				{
					"gems",
					store.gems_collected or 0
				},
				{
					"hero_1",
					store.selected_team[1]
				},
				{
					"hero_2",
					store.selected_team[2] or ""
				},
				{
					"tower_1",
					store.selected_towers[1] or ""
				},
				{
					"tower_2",
					store.selected_towers[2] or ""
				},
				{
					"tower_3",
					store.selected_towers[3] or ""
				},
				{
					"tower_4",
					store.selected_towers[4] or ""
				},
				{
					"tower_5",
					store.selected_towers[5] or ""
				},
				{
					"item_1",
					store.selected_items[1] or ""
				},
				{
					"item_2",
					store.selected_items[2] or ""
				},
				{
					"item_3",
					store.selected_items[3] or ""
				},
				{
					"age",
					PP:is_underage() and "underage" or "overage"
				}
			}

			fba:log_event_table_multiparam("kr_game_init", params)
		end
	end,
	["game-defeat"] = function(store)
		if IS_TRILOGY then
			fba:log_event("kr_game_defeat", "level", tostring(store.level_idx))

			if store.restarted then
				fba:log_event("kr_game_defeat_multiple", "level", tostring(store.level_idx))
			end

			if store.level_challenge then
				fba:log_event("kr_ch_defeat", "acid", tostring(store.level_challenge.acid))
			end
		else
			local remaining_upgrade_points = UPGR:get_current_points_by_level() - UPGR:get_spent_points()
			local params = {
				{
					"level_idx",
					store.level_idx
				},
				{
					"level_mode",
					store.level_mode
				},
				{
					"level_difficulty",
					store.level_difficulty
				},
				{
					"gems",
					store.gems_collected or 0
				},
				{
					"lives",
					store.lives
				},
				{
					"gold",
					store.player_gold or 0
				},
				{
					"hero_1",
					store.selected_team[1]
				},
				{
					"hero_2",
					store.selected_team[2] or ""
				},
				{
					"tower_1",
					store.selected_towers[1] or ""
				},
				{
					"tower_2",
					store.selected_towers[2] or ""
				},
				{
					"tower_3",
					store.selected_towers[3] or ""
				},
				{
					"tower_4",
					store.selected_towers[4] or ""
				},
				{
					"tower_5",
					store.selected_towers[5] or ""
				},
				{
					"item_1",
					store.selected_items[1] or ""
				},
				{
					"item_2",
					store.selected_items[2] or ""
				},
				{
					"item_3",
					store.selected_items[3] or ""
				},
				{
					"wave",
					store.wave_group_number
				},
				{
					"upgrade_points",
					remaining_upgrade_points
				},
				{
					"age",
					PP:is_underage() and "underage" or "overage"
				}
			}

			fba:log_event_table_multiparam("kr_game_defeat", params)
		end
	end,
	["game-victory"] = function(store)
		if IS_TRILOGY then
			fba:log_event("kr_game_victory", "level", tostring(store.level_idx))

			if store.level_challenge then
				fba:log_event("kr_ch_victory", "acid", tostring(store.level_challenge.acid))
			end
		else
			local params = {
				{
					"level_idx",
					store.level_idx
				},
				{
					"level_mode",
					store.level_mode
				},
				{
					"level_difficulty",
					store.level_difficulty
				},
				{
					"gems",
					store.gems_collected or 0
				},
				{
					"lives",
					store.lives
				},
				{
					"gold",
					store.player_gold or 0
				},
				{
					"hero_1",
					store.selected_team[1]
				},
				{
					"hero_2",
					store.selected_team[2] or ""
				},
				{
					"tower_1",
					store.selected_towers[1] or ""
				},
				{
					"tower_2",
					store.selected_towers[2] or ""
				},
				{
					"tower_3",
					store.selected_towers[3] or ""
				},
				{
					"tower_4",
					store.selected_towers[4] or ""
				},
				{
					"tower_5",
					store.selected_towers[5] or ""
				},
				{
					"item_1",
					store.selected_items[1] or ""
				},
				{
					"item_2",
					store.selected_items[2] or ""
				},
				{
					"item_3",
					store.selected_items[3] or ""
				},
				{
					"age",
					PP:is_underage() and "underage" or "overage"
				}
			}

			fba:log_event_table_multiparam("kr_game_win", params)
		end
	end,
	["game-restart"] = function(store)
		if IS_TRILOGY then
			return
		end

		local params = {
			{
				"level_idx",
				store.level_idx
			},
			{
				"level_mode",
				store.level_mode
			},
			{
				"level_difficulty",
				store.level_difficulty
			},
			{
				"lives",
				store.lives
			},
			{
				"gold",
				store.player_gold or 0
			},
			{
				"hero_1",
				store.selected_team[1]
			},
			{
				"hero_2",
				store.selected_team[2] or ""
			},
			{
				"tower_1",
				store.selected_towers[1] or ""
			},
			{
				"tower_2",
				store.selected_towers[2] or ""
			},
			{
				"tower_3",
				store.selected_towers[3] or ""
			},
			{
				"tower_4",
				store.selected_towers[4] or ""
			},
			{
				"tower_5",
				store.selected_towers[5] or ""
			},
			{
				"item_1",
				store.selected_items[1] or ""
			},
			{
				"item_2",
				store.selected_items[2] or ""
			},
			{
				"item_3",
				store.selected_items[3] or ""
			},
			{
				"wave",
				store.wave_group_number
			},
			{
				"age",
				PP:is_underage() and "underage" or "overage"
			}
		}

		fba:log_event_table_multiparam("kr_game_restart", params)
	end,
	["game-quit"] = function(store)
		if IS_TRILOGY then
			return
		end

		local params = {
			{
				"level_idx",
				store.level_idx
			},
			{
				"level_mode",
				store.level_mode
			},
			{
				"level_difficulty",
				store.level_difficulty
			},
			{
				"lives",
				store.lives
			},
			{
				"gold",
				store.player_gold or 0
			},
			{
				"hero_1",
				store.selected_team[1]
			},
			{
				"hero_2",
				store.selected_team[2] or ""
			},
			{
				"tower_1",
				store.selected_towers[1] or ""
			},
			{
				"tower_2",
				store.selected_towers[2] or ""
			},
			{
				"tower_3",
				store.selected_towers[3] or ""
			},
			{
				"tower_4",
				store.selected_towers[4] or ""
			},
			{
				"tower_5",
				store.selected_towers[5] or ""
			},
			{
				"item_1",
				store.selected_items[1] or ""
			},
			{
				"item_2",
				store.selected_items[2] or ""
			},
			{
				"item_3",
				store.selected_items[3] or ""
			},
			{
				"wave",
				store.wave_group_number
			},
			{
				"age",
				PP:is_underage() and "underage" or "overage"
			}
		}

		fba:log_event_table_multiparam("kr_game_quit", params)
	end,
	["debug-event"] = function(arg1, arg2)
		fba:log_event("debug_event", arg1 or "", arg2 or "")
	end,
	["http-client-error"] = function(source, url, code, data)
		fba:log_event_table_multiparam(string.format("http_client_error_%s", source), {
			{
				"url",
				url
			},
			{
				"code",
				code or ""
			},
			{
				"data",
				data or ""
			}
		})
	end
}

local proxy

if KR_PLATFORM == "ios" then
	proxy = {}

	local ffi = require("ffi")

	ffi.cdef("\ntypedef struct kfbKeyValue{\n    const char* key;\n    const char* value;\n} kfbKeyValue;\n\nbool kfb_a_init_service(void);\nvoid kfb_a_log_analytics_event(const char* name, const char* key, const char* value);\nvoid kfb_a_log_analytics_event_multiparam(const char* name, kfbKeyValue *params, size_t size);\nvoid kfb_a_log_and_crash(const char* msg);\nvoid kfb_cr_set_collection(bool value);\nsize_t kr_get_loggerhead_id(char* buffer, size_t bufSize);\nint kr_get_loggerhead_time();\nsize_t kr_get_loggerhead_arch(char* buffer, size_t bufSize);\n")

	local C = ffi.C

	function proxy.init_service(srvid)
		if C.kfb_a_init_service() then
			return 1
		end
	end

	function proxy.log_analytics_event(srvid, name, key, value)
		if not fba.inited then
			return -1
		end

		C.kfb_a_log_analytics_event(name, key, value)
	end

	function proxy.log_analytics_event_multiparam(srvid, name, params)
		if not fba.inited then
			return -1
		end

		local keyValueArray = ffi.new("kfbKeyValue[?]", #params)

		for i, entry in ipairs(params) do
			keyValueArray[i - 1].key = tostring(entry[1])
			keyValueArray[i - 1].value = tostring(entry[2])
		end

		C.kfb_a_log_analytics_event_multiparam(name, keyValueArray, #params)
	end

	function proxy.crashlytics_log_and_crash(msg)
		if not fba.inited then
			return -1
		end

		C.kfb_a_log_and_crash(msg)
	end

	function proxy.crashlytics_set_collection(value)
		C.kfb_cr_set_collection(value)
	end

	function proxy.get_loggerhead_arch()
		return "64"
	end

	function proxy.get_loggerhead_id()
		local buf_max_size = 512
		local buffer = ffi.new("char[?]", buf_max_size)
		local buffer_length = ffi.C.kr_get_loggerhead_id(buffer, buf_max_size)
		local s = ffi.string(buffer, buffer_length)

		return s
	end

	function proxy.get_loggerhead_time()
		local time = ffi.C.kr_get_loggerhead_time()

		return string.format("%i", time)
	end
else
	proxy = require("all.jni_android")
end

function fba:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		if not params or params.disable_crashlytics ~= true then
			proxy.crashlytics_set_collection(true)
		end

		do
			local result = proxy.init_service(self.SRV_ID)

			if result ~= 1 then
				log.error("%s native init failed", name)

				return nil
			end
		end

		self.loggerhead_arch = proxy.get_loggerhead_arch()
		self.loggerhead_time = proxy.get_loggerhead_time()
		self.loggerhead_id = proxy.get_loggerhead_id()

		if self.loggerhead_id == "" then
			self.loggerhead_id = nil
		end

		if self.signal_handlers then
			for sn, fn in pairs(self.signal_handlers) do
				log.debug("registering signal %s", sn)
				signal.register(sn, fn)
			end
		end

		self.inited = true
	end

	return true
end

function fba:shutdown(name)
	if self.inited then
		for sn, fn in pairs(self.signal_handlers) do
			signal.remove(sn, fn)
		end
	end

	self.inited = nil
end

function fba:log_event(name, key, value)
	value = string.format("%s", value)

	local params = {}

	if key and key ~= "" and value then
		table.insert(params, {
			key,
			value
		})
	end

	self:log_event_table_multiparam(name, params)
end

function fba:log_event_table_multiparam(name, params)
	if params and self.loggerhead_id then
		table.insert(params, {
			"loggerhead_id",
			self.loggerhead_id
		})
		table.insert(params, {
			"loggerhead_time",
			self.loggerhead_time
		})
	end

	proxy.log_analytics_event_multiparam(self.SRV_ID, name, params)
end

function fba:log_and_crash(msg)
	proxy.crashlytics_log_and_crash(msg)
end

function fba:set_crash_collection(value)
	proxy.crashlytics_set_collection(value)
end

return fba
