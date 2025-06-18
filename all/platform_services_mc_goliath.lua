-- chunkname: @./all/platform_services_mc_goliath.lua

local log = require("klua.log"):new("platform_services_mc_goliath")
local signal = require("hump.signal")
local sha1 = require("sha1")
local b64 = require("plc.base64")
local pbin = require("plc.bin")
local storage = require("storage")
local json = require("json")
local uuid = require("uuid4")

require("klua.table")
require("klua.string")
require("constants")

local UPGR = require("upgrades")
local PS = require("platform_services")
local PSU = require("platform_services_utils")
local GS = require("game_settings")
local RC = require("remote_config")
local mcg = {}

mcg.can_be_paused = true
mcg.update_interval = 5
mcg.SRV_DISPLAY_NAME = "Miniclip Goliath"
mcg.TIMEOUT_SENDING = 60
mcg.TIMEOUT_ERROR_RETRY = DEBUG and 15 or 300
mcg.MAX_EVENTS_STORED = 250
mcg.MAX_NEW_EVENTS_SENT_PER_CYCLE = 5
mcg.MAX_FAILED_EVENTS_SENT_PER_CYCLE = 2
mcg.MAX_SESSIONS_WITH_PENDING_USER_ID = 5
mcg.PROTOCOL_VERSION = 1.2

local ES_NEW = "new"
local ES_SENT = "sent"
local ES_SENDING = "sending"
local ES_FAILED = "failed"
local ES_INVALID = "invalid"
local UID_OFFLINE = "OFFL"
local UID_ICLOUD = "ICLD"
local UID_GPLAY = "GPLY"
local UID_STEAM = "STMM"
local UID_PENDING = "PENDING"

mcg.signal_handlers = {
	quit = function()
		log.debug("quit requested")

		local session_length = mcg:get_session_length()

		if session_length > 0 then
			mcg:queue_event("session", {
				session_length = session_length
			})
			mcg:persist_event_buffer()
		end
	end,
	["focus-changed"] = function(focus)
		log.debug("focus changed to %s", focus)

		if focus then
			if mcg.data.bg_ts <= 0 then
				log.error("recovering focus without previous background change... ignoring")

				return
			end

			if mcg.data.match_ts then
				mcg.data.match_ts = mcg.data.match_ts + (mcg:get_ts() - mcg.data.bg_ts)
			end

			if mcg:get_ts() - mcg.data.bg_ts < 120 then
				mcg:resume_session()
			else
				mcg:start_session()
			end
		else
			if mcg.data.match_ts and game and game.store and game.store.level_init_finished then
				mcg:queue_match_event(game.store, "away")
			end

			mcg:queue_event("session", {
				session_length = mcg:get_session_length()
			})
			mcg:persist_event_buffer()

			mcg.data.session_ts = 0
			mcg.data.bg_ts = mcg:get_ts()
		end
	end,
	["game-start"] = function(store)
		mcg.data.match_ts = mcg:get_ts()
		mcg.data.match_uuid = uuid:getUUID()
		mcg.data.match_complete = false
	end,
	["game-defeat"] = function(store)
		mcg.data.match_complete = true

		mcg:queue_match_event(store, "defeat")
	end,
	["game-victory"] = function(store)
		mcg.data.match_complete = true

		mcg:queue_match_event(store, "victory")
	end,
	["game-restart"] = function(store)
		mcg:queue_match_event(store, "restart")
	end,
	["game-quit"] = function(store)
		if mcg.data and not mcg.data.ftue_complete then
			mcg.data.ftue_complete = true
		end

		mcg:queue_match_event(store, "quit")
	end,
	[SGN_MARKETING_OFFER_SHOWN] = function(o_name, placement)
		mcg:queue_event("promo_impression", {
			placement = placement or "shop",
			offer_id = o_name
		})
	end,
	[SGN_MARKETING_OFFER_CLICKED] = function(o_name, placement)
		local params = {
			action_id = "purchase",
			interaction_type = "action",
			action_type = "transaction",
			placement = placement,
			offer_id = o_name,
			action_target = o_name
		}

		mcg:queue_event("promo_click", params)
	end,
	[SGN_PS_NEWS_URL_SHOWN] = function(url, placement)
		mcg:queue_event("promo_impression", {
			placement = placement,
			url = url
		})
	end,
	[SGN_PS_NEWS_URL_CLICKED] = function(url, placement)
		local params = {
			action_id = "openUrl",
			interaction_type = "action",
			action_type = "openUrl",
			placement = placement,
			action_target = url
		}

		mcg:queue_event("promo_click", params)
	end,
	[SGN_PS_PURCHASE_PRODUCT_FINISHED] = function(srv, ok, prod, currency, is_restored, purchase_data)
		if not is_restored and purchase_data then
			mcg:queue_inapp_event(prod, purchase_data)
		end
	end,
	[SGN_PS_SYNC_SLOTS_FINISHED] = function(srv, ok, rid, status)
		if not ok then
			return
		end

		if mcg.data and mcg.data.user_id and mcg.data.user_id == UID_PENDING then
			mcg.data.user_id = mcg:get_user_id()
		end
	end,
	[SGN_PS_PUSH_SLOT_FINISHED] = function(srv, ok, rid, slot_idx)
		if not ok then
			return
		end

		if mcg.data and mcg.data.user_id and mcg.data.user_id == UID_PENDING then
			mcg.data.user_id = mcg:get_user_id()
		end
	end,
	["ftue-step"] = function(step)
		mcg:queue_ftue_step(step)
	end,
	[SGN_REMOTE_CONFIG_UPDATED] = function()
		mcg:apply_active_trials()
	end
}

local proxy = {}

if KR_PLATFORM == "ios" or KR_PLATFORM == "mac" or KR_PLATFORM == "mac-appstore" or KR_PLATFORM == "win" then
	local ffi = require("ffi")

	ffi.cdef(" size_t kr_get_current_locale(char* buf, size_t bufSize); ")
	ffi.cdef(" size_t kr_get_os_version(char* buffer, size_t bufSize); ")
	ffi.cdef(" int kr_get_physical_memory_mb(); ")
	ffi.cdef(" size_t kr_get_timezone(char* buffer, size_t bufSize); ")
	ffi.cdef(" int kr_get_seconds_from_gmt(); ")
	ffi.cdef(" size_t kr_get_device_model(char* buf, size_t bufSize); ")
	ffi.cdef(" size_t kr_get_loggerhead_id(char* buffer, size_t bufSize); ")
	ffi.cdef(" size_t kr_get_loggerhead_time(); ")
	ffi.cdef(" size_t kr_get_loggerhead_arch(char* buffer, size_t bufSize); ")

	function proxy.get_device_locale()
		local s = PSU:get_ffi_func_string(mcg.lib.kr_get_current_locale)
		local ll, ls, lc = string.match(s, "^(%a%a)-?(%a*)_?(%a?%a?)")
		local o = ll

		if ls and ls ~= "" then
			o = o .. "-" .. ls
		end

		if lc and lc ~= "" then
			o = o .. "_" .. lc
		end

		return o or "unknown"
	end

	function proxy.get_device_model()
		local s = PSU:get_ffi_func_string(mcg.lib.kr_get_device_model)

		return s or "unknown"
	end

	function proxy.get_timezone()
		local ss = mcg.lib.kr_get_seconds_from_gmt()
		local sign = ss >= 0 and "+" or "-"
		local hours = math.floor(math.abs(ss) / 3600)
		local minutes = (math.abs(ss) - hours * 3600) / 60
		local s = string.format("GMT%s%02d:%02d", sign, hours, minutes)

		log.debug("timezone: %s", s)

		return s
	end

	function proxy.get_os_version()
		local s = PSU:get_ffi_func_string(mcg.lib.kr_get_os_version)

		log.debug("os version: %s", s)

		return s
	end

	function proxy.get_device_ram()
		return mcg.lib.kr_get_physical_memory_mb()
	end

	function proxy.get_ad_tracking_id()
		return nil
	end

	function proxy.is_ad_tracking_enabled()
		return false
	end

	function proxy.get_user_id()
		if PS.services and PS.services.cloudsave then
			local cs = PS.services.cloudsave

			if not cs:get_status() then
				return nil
			end

			local digest = sha1.hmac("901bkckio1ub.1obdjas", cs:get_identity())

			return string.format("%s%s", UID_ICLOUD, digest)
		elseif PS.services and PS.services.steam and PS.services.steam.steam_account_id then
			local digest = sha1.hmac("901bkckio1ub.1obdjas", PS.services.steam.steam_account_id)

			return string.format("%s%s", UID_STEAM, digest)
		else
			return nil
		end
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
		return ffi.C.kr_get_loggerhead_time()
	end
elseif KR_PLATFORM == "android" then
	local jnia = require("all.jni_android")

	function proxy.get_device_locale()
		local s = jnia.get_system_property("CURRENT_LOCALE")
		local ll, lc, ls = string.match(s, "^(%a%a)_?(%a?%a?)_?#?(%a*)")
		local o = ll

		if ls and ls ~= "" then
			o = o .. "-" .. ls
		end

		if lc and lc ~= "" then
			o = o .. "_" .. lc
		end

		return o or "unknown"
	end

	function proxy.get_device_model()
		local s = jnia.get_system_property("DEVICE_MODEL")

		return s or "unknown"
	end

	function proxy.get_timezone()
		local s = jnia.get_system_property("GMT_OFFSET")

		return s or "unknown"
	end

	function proxy.get_os_version()
		local s = jnia.get_system_property("OS_VERSION")

		return s
	end

	function proxy.get_device_ram()
		local s = jnia.get_system_property("DEVICE_RAM")

		if s and s ~= "" then
			return tonumber(s)
		else
			return 0
		end
	end

	function proxy.get_ad_tracking_id()
		return nil
	end

	function proxy.is_ad_tracking_enabled()
		return false
	end

	function proxy.get_user_id()
		if PS.services and PS.services.cloudsave then
			local id = jnia.get_cloud_identity(PS.services.cloudsave.SRV_ID)

			if not id or id == "" then
				return nil
			else
				local digest = sha1.hmac("901bkckio1ub.1obdjas", id)

				return string.format("%s%s", UID_GPLAY, digest)
			end
		else
			return nil
		end
	end

	function proxy.get_loggerhead_arch()
		return jnia.get_loggerhead_arch()
	end

	function proxy.get_loggerhead_id()
		return jnia.get_loggerhead_id()
	end

	function proxy.get_loggerhead_time()
		return jnia.get_loggerhead_time()
	end
elseif KR_PLATFORM == "win" then
	-- block empty
end

mcg.proxy = proxy

function mcg:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		if not PS.services.http or not PS.services.http.inited then
			log.error("platform_services_mc_goliath requires platform_services_http inited")

			return nil
		end

		if not PS.services.iap or not PS.services.iap.inited then
			log.error("platform_services_mc_goliath requires iap serivce inited")

			return nil
		end

		if not params then
			log.error("platform_services_mc_goliath requires: api_key, game_id, shared_secret, platform")

			return nil
		end

		if not params.FORCE_PRODUCTION and (DEBUG or params.FORCE_STAGING) then
			log.warning("platform_services_mc_goliath: setting to STAGING environment")

			params.api_key = params.staging.api_key
			params.shared_secret = params.staging.shared_secret
			params.api_url = params.staging.api_url
		else
			log.warning("platform_services_mc_goliath: setting to PRODUCTION environment")

			params.api_key = params.production.api_key
			params.shared_secret = params.production.shared_secret
			params.api_url = params.production.api_url
		end

		if not params.api_key or not params.game_id or not params.shared_secret or not params.platform then
			log.error("platform_services_mc_goliath requires: api_key, game_id, shared_secret, platform")

			return nil
		end

		self.api_key = params.api_key
		self.game_id = params.game_id
		self.shared_secret = params.shared_secret
		self.api_url = params.api_url
		self.platform = params.platform

		if KR_PLATFORM == "android" then
			-- block empty
		elseif KR_PLATFORM == "ios" then
			local ffi = require("ffi")

			self.lib = ffi.C
		elseif KR_PLATFORM == "mac" or KR_PLATFORM == "mac-appstore" or KR_PLATFORM == "win" then
			local ffi = require("ffi")

			self.lib = PSU:load_library("ksystem", ffi)

			if not self.lib then
				log.error("Error loading ksystem library")

				return false
			end
		end

		if KR_PLATFORM == "ios" or KR_PLATFORM == "android" then
			self.loggerhead_arch = proxy.get_loggerhead_arch()
			self.loggerhead_time = proxy.get_loggerhead_time()
			self.loggerhead_id = proxy.get_loggerhead_id()

			if self.loggerhead_id == "" then
				self.loggerhead_id = nil
			end
		end

		self.data = {
			online_status = true,
			session_ts = 0,
			bg_ts = 0,
			last_offline_ts = 0,
			initial_love_time = love.timer.getTime(),
			initial_os_time = os.time()
		}
		self.data.event_buffer = {}

		do
			local cache = storage:load_cache()

			if cache.mc_goliath and cache.mc_goliath.event_buffer then
				self.data.event_buffer = table.deepclone(cache.mc_goliath.event_buffer)
			end

			self.data.user_id = self:get_user_id()

			if self.data.user_id == UID_PENDING then
				local count = self:get_global("pending_sessions_count", 0) + 1

				self:set_global("pending_sessions_count", count)

				if count > self.MAX_SESSIONS_WITH_PENDING_USER_ID then
					self.data.user_id = self:get_user_id(true)
				end
			end

			self.data.ftue_complete = self:get_global("ftue_complete")
		end

		self:start_session()

		self.inited = true
	end

	self.names = self.names or {}

	if not table.contains(self.names, name) then
		table.insert(self.names, name)
	end

	if self.signal_handlers then
		for sn, fn in pairs(self.signal_handlers) do
			log.debug("registering signal %s", sn)
			signal.register(sn, fn)
		end
	end

	signal.emit("ftue-step", "launch_game")

	return true
end

function mcg:shutdown(name)
	if self.inited and self.signal_handlers then
		for sn, fn in pairs(self.signal_handlers) do
			log.debug("removing signal %s", sn)
			signal.remove(sn, fn)
		end
	end

	self.names = nil
	self.inited = nil
end

function mcg:get_status()
	return self.inited
end

function mcg:late_update(dt)
	local dirty = false

	for i = #self.data.event_buffer, 1, -1 do
		local e = self.data.event_buffer[i]

		if e.status == ES_SENT or e.status == ES_INVALID then
			table.remove(self.data.event_buffer, i)

			dirty = true

			if e.status == ES_INVALID then
				log.debug("Dropping invalid event %s", e.event)
			end
		end
	end

	if #self.data.event_buffer > self.MAX_EVENTS_STORED then
		while #self.data.event_buffer > self.MAX_EVENTS_STORED do
			log.warning("Dropping event because MAX_EVENTS_STORED was exceeded")
			table.remove(self.data.event_buffer, 1)

			dirty = true
		end
	end

	if self.data.user_id ~= UID_PENDING then
		local new_sent_count = 0
		local failed_sent_count = 0

		for _, e in pairs(self.data.event_buffer) do
			if e.status == ES_SENDING and self:get_ts() - e.status_ts > self.TIMEOUT_SENDING then
				log.debug("timeout: marking event %s as falied", e.event)

				e.status = ES_FAILED

				self:set_online(false)

				dirty = true
			end

			if self:is_online() and (e.status == ES_NEW or e.status == ES_FAILED) then
				if e.status == ES_FAILED then
					if failed_sent_count >= self.MAX_FAILED_EVENTS_SENT_PER_CYCLE then
						goto label_42_0
					end

					failed_sent_count = failed_sent_count + 1
				else
					if new_sent_count >= self.MAX_NEW_EVENTS_SENT_PER_CYCLE then
						goto label_42_0
					end

					new_sent_count = new_sent_count + 1
				end

				self:send_event_to_server(e)

				dirty = true
			end

			::label_42_0::
		end
	end

	if dirty and not PS.paused then
		self:persist_event_buffer()
	end
end

function mcg:get_global(key, default)
	local global = storage:load_global()
	local v

	if global and global.mc_goliath then
		v = global.mc_goliath[key]
	end

	return v or default
end

function mcg:set_global(key, value)
	local global = storage:load_global()

	global.mc_goliath = global.mc_goliath or {}
	global.mc_goliath[key] = value

	storage:save_global(global)
end

function mcg:get_ts(love_time)
	love_time = love_time or love.timer.getTime()

	return love_time - self.data.initial_love_time + self.data.initial_os_time
end

function mcg:get_session_length()
	if self.data and self.data.initial_love_time and self.data.initial_os_time and self.data.session_ts > 0 then
		return math.ceil(self:get_ts() - self.data.session_ts)
	else
		return -1
	end
end

function mcg:start_session()
	log.debug("")

	self.data.session_id = self:create_session_id()
	self.data.session_ts = self:get_ts()
	self.data.bg_ts = 0

	local init_params = {}

	init_params.platform = self.platform

	local dlcs

	if IS_MOBILE then
		local global = storage:load_global()

		if global and global.purchased_dlcs then
			dlcs = {}

			for _, n in pairs(global.purchased_dlcs) do
				table.insert(dlcs, n)
			end
		end
	else
		dlcs = PS.services.iap and PS.services.iap:get_dlcs(true)
	end

	if dlcs and #dlcs > 0 then
		init_params.dlcs = dlcs
	end

	local client_init_params = {
		timezone = self.proxy.get_timezone(),
		device_id = self.proxy.get_ad_tracking_id() or self:get_device_id(),
		device_name = self.proxy.get_device_model(),
		bundle_id = version.bundle_id,
		os_version = self.proxy.get_os_version(),
		os_name = KR_PLATFORM,
		device_ram = self.proxy.get_device_ram(),
		device_language = self.proxy.get_device_locale(),
		client_game_version = version.string_short,
		advertising_tracking_enabled = self.proxy.is_ad_tracking_enabled(),
		loggerhead_id = self.loggerhead_id
	}

	self:queue_event("init", init_params)
	self:queue_event("client_init", client_init_params)
end

function mcg:resume_session()
	log.debug("")

	self.data.session_ts = mcg:get_ts()
	self.data.bg_ts = 0
end

function mcg:queue_match_event(store, result)
	if KR_GAME ~= "kr5" then
		log.error("queue_match_event() not implemented for this game")

		return
	end

	if self.data and self.data.match_complete and (result == "quit" or result == "restart") then
		log.debug("queue_match_event() not sent: quit/restart only sent for incomplete matches")

		return
	end

	local stage_expansion = "?"

	for i, r in ipairs(GS.level_ranges) do
		if store.level_idx >= r[1] and store.level_idx <= r[2] then
			stage_expansion = GS.level_range_names[i] or tostring(i - 1)

			break
		end
	end

	local d = self.data
	local duration = math.ceil(self:get_ts() - (d.match_ts or d.session_ts))
	local params = {
		duration = duration,
		match_id = d.match_uuid,
		game_mode = tostring(store.level_mode),
		stage_id = store.level_idx,
		level_difficulty = store.level_difficulty,
		lives = math.floor(store.lives or 0),
		hero_1 = store.selected_team and store.selected_team[1] or "",
		hero_2 = store.selected_team and store.selected_team[2] or "",
		tower_1 = store.selected_towers and store.selected_towers[1] or "",
		tower_2 = store.selected_towers and store.selected_towers[2] or "",
		tower_3 = store.selected_towers and store.selected_towers[3] or "",
		tower_4 = store.selected_towers and store.selected_towers[4] or "",
		tower_5 = store.selected_towers and store.selected_towers[5] or "",
		item_1 = store.selected_items and store.selected_items[1] or "",
		item_2 = store.selected_items and store.selected_items[2] or "",
		item_3 = store.selected_items and store.selected_items[3] or "",
		wave = store.wave_group_number or 0,
		upgrade_points_unused = UPGR:get_current_points_by_level() - UPGR:get_spent_points(),
		upgrades_alliance = UPGR:get_upgrade_bitfield("alliance"),
		upgrades_heroes = UPGR:get_upgrade_bitfield("heroes"),
		upgrades_reinforcements = UPGR:get_upgrade_bitfield("reinforcements"),
		upgrades_towers = UPGR:get_upgrade_bitfield("towers"),
		result = result,
		gold = math.floor(store.player_gold or 0),
		stage_expansion = stage_expansion
	}

	self:queue_event("match", params)
end

function mcg:queue_inapp_event(prod_id, purchase_data)
	local iap = PS.services.iap
	local prod = iap:get_product(prod_id)

	if not prod then
		log.error("could not find product %s in iaps", prod_id)

		return
	end

	local receipt = purchase_data.receipt

	if iap.get_inapp_receipt then
		receipt = iap:get_inapp_receipt()
	end

	local placement

	if game and game.store and game.store.level_idx then
		placement = string.format("stage-%02i", game.store.level_idx)
	else
		placement = "map"
	end

	local currency_code = "unknown"

	if prod.price_currency_code then
		local csplit = string.split(prod.price_currency_code, "=")

		currency_code = csplit[2] or csplit[1]
	end

	local prod_split = string.split(prod_id, "_")
	local family = prod_split[1]
	local sub_family = placement == "map" and "map" or "stage"
	local product_expansion = prod.expansion or "base"
	local params = {
		in_app_purchase_event_id = purchase_data.order_id or purchase_data.transaction_id,
		product_id = prod_id,
		product_family = family,
		product_sub_family = sub_family,
		local_currency = currency_code,
		local_price = prod.price_micros and string.format("%.2f", tonumber(prod.price_micros) / 1000000) or "",
		receipt = receipt,
		signed_receipt = purchase_data.signature,
		transaction_id = purchase_data.transaction_id,
		placement = placement,
		product_expansion = product_expansion
	}

	self:queue_event("in_app_purchase", params)
end

function mcg:queue_ftue_step(step)
	if self.data.ftue_complete then
		return
	end

	if not self:get_global("ftue_complete") then
		self:set_global("ftue_complete", true)

		local user_data = storage:load_slot()

		if user_data then
			local tutorial_complete = user_data.levels[1] and user_data.levels[1][1] ~= nil

			if tutorial_complete then
				log.debug("level 1 is already complete, so marking data.ftue_complete")

				self.data.ftue_complete = true

				return
			end
		end
	end

	local is_mandatory = {
		click_instacall_confirm_4_wave = false,
		use_hero_power = false,
		click_instacall_confirm_2_wave = false,
		drop_reinforcements = false,
		click_instacall_confirm_1_wave = true,
		kill_first_enemy = true,
		click_instacall_confirm_3_wave = false,
		private_policy_age_gate = true,
		tutorial_ends = true,
		launch_game = true,
		click_on_slot = true,
		screen_slots = true,
		tutorial_begins = true,
		drag_hero = false,
		click_archers_build = true,
		click_paladin_build = true,
		push_notification = false,
		att = false
	}
	local params = {
		step = step,
		complementary = not is_mandatory[step]
	}

	self:queue_event("tutorial_funnel", params)

	if step == "tutorial_ends" then
		self.data.ftue_complete = true
	end
end

function mcg:queue_event(name, params)
	if not name or name == "" then
		log.error("trying to queue nil or empty envent")
	end

	local body = {}

	body.global_parameters = {
		user_id = self.data.user_id,
		session_id = self.data.session_id,
		timestamp = math.floor(self:get_ts() * 1000)
	}
	body.events = {}

	if params then
		body.events[name] = {
			params
		}
	end

	log.debug("queue_event:%s %s", name, getdump(params and params or {}))
	table.insert(self.data.event_buffer, {
		status = "new",
		event = name,
		body = body,
		random = math.random()
	})
end

function mcg:send_event_to_server(event)
	local function cb_send_event(status, req, url, code, header, data)
		local response_state = "ok"

		if status ~= 0 then
			response_state = "unknown_error"
		end

		local code_number = type(code) == "number" and code or nil

		if code_number then
			if code_number >= 400 and code_number <= 499 then
				response_state = "client_error"
			elseif code_number >= 500 and code_number <= 599 then
				response_state = "server_error"
			end
		end

		if response_state == "client_error" then
			req.event.status = ES_INVALID

			mcg:set_online(true)
			log.error("cb_send_event classified as:%s - status:%s req.id:%s code:%s url:%s data:%s", response_state, status, req.id, code, url, data)
			signal.emit("http-client-error", "goliath_client", url, code, data)
		elseif response_state == "unknown_error" or response_state == "server_error" then
			req.event.status = ES_FAILED

			mcg:set_online(false)
			log.error("cb_send_event classified as:%s - status:%s req.id:%s code:%s url:%s data:%s", response_state, status, req.id, code, url, data)

			if not req.event._signal_emitted then
				signal.emit("http-client-error", "goliath_other", url, code, data)

				req.event._signal_emitted = true
			end
		else
			log.debug("cb_send_event classified as:%s - status:%s req.id:%s code:%s url:%s data:%s", response_state, status, req.id, code, url, data)

			req.event.status = ES_SENT

			mcg:set_online(true)

			local ok, res = pcall(json.decode, data)

			if not ok then
				log.error("cb_send_event: error parsing response for req.id:%s : %s : %s", req.id, res or "", data)
			elseif req.event.event == "client_init" then
				if res and res.content and type(res.content) == "table" then
					local libra_configs = {}

					for _, c in pairs(res.content) do
						if not c.type or c.type ~= "user_property" or not c.name or not c.value then
							-- block empty
						else
							libra_configs[c.name] = c.value
						end
					end

					mcg:refresh_active_trials(libra_configs)
				else
					mcg:refresh_active_trials(nil)
				end
			end
		end
	end

	if event and event.body and event.body.global_parameters.user_id == UID_PENDING then
		event.body.global_parameters.user_id = self.data.user_id
	end

	local ok, msg = pcall(json.encode, event.body)

	if not ok then
		log.error("error json encoding event %s:\n%s", event.event, getdump(event.body and event.body or {}))

		event.status = ES_INVALID
	else
		local http = PS.services.http
		local rid = http:post(self.api_url, self:get_http_headers(msg), msg, cb_send_event, self.TIMEOUT_SENDING)
		local req = http:get_pending_requests()[rid]

		req.event = event
		event.rid = rid
		event.status = ES_SENDING
		event.status_ts = self:get_ts()

		log.debug("sent event %s %s with rid:%s", event.event, event.random, rid)
	end
end

function mcg:get_http_headers(msg)
	local h = {}

	h["cache-control"] = "no-cache"
	h["content-type"] = "application/json"
	h.apikey = self.api_key

	local rawchecksum = pbin.hextos(sha1.hmac(self.shared_secret, msg))

	h.checksum = b64.encode(rawchecksum)

	return h
end

function mcg:persist_event_buffer()
	log.debug("saving event_buffer...")

	local cache = storage:load_cache()

	cache.mc_goliath = cache.mc_goliath or {}
	cache.mc_goliath.event_buffer = self.data.event_buffer

	storage:save_cache(cache)
	log.debug("done saving event_buffer")
end

function mcg:get_device_id()
	local device_id = self:get_global("device_id")

	if not device_id then
		local uid = uuid:getUUID()

		self:set_global("device_id", uid)
		log.debug("created device_id %s", uid)

		device_id = uid
	end

	return device_id
end

function mcg:get_user_id(force)
	local user_id = self:get_global("user_id")

	if user_id then
		return user_id
	else
		local uid = self.proxy.get_user_id()

		if force then
			uid = UID_OFFLINE .. uuid:getUUID()

			log.debug("force creating a random user_id: %s", uid)
		end

		if not uid then
			return UID_PENDING
		else
			self:set_global("user_id", uid)

			return uid
		end
	end
end

function mcg:create_session_id()
	return uuid:getUUID()
end

function mcg:set_online(value)
	self.data.online_status = value

	if not value then
		self.data.last_offline_ts = self:get_ts()
	end
end

function mcg:is_online()
	if self.data.online_status then
		return true
	end

	if self:get_ts() - self.data.last_offline_ts < self.TIMEOUT_ERROR_RETRY then
		return false
	end

	self.data.online_status = true
	self.data.last_offline_ts = self:get_ts()

	return true
end

function mcg:refresh_active_trials(trials)
	log.debug("refresh_active_trials: %s", getfulldump(trials))
	self:set_global("active_trials", trials)
	self:apply_active_trials()
	signal.emit(SGN_PS_GOLIATH_LIBRA_RESPONSE_RECEIVED, trials)
end

function mcg:apply_active_trials()
	local trials = self:get_global("active_trials") or {}

	for k, v in pairs(trials) do
		if string.starts(k, "iap_pricing_offers") then
			if not PS or not PS.services or not PS.services.iap then
				log.error("%s requires iap platform service configured", self.names[1])

				return
			end

			local rc_key = "offers_" .. PS.services.iap.rc_suffix
			local trial_rc_key = rc_key .. "_" .. k .. "_" .. v
			local trial_rc_value = RC.v[trial_rc_key]

			if not trial_rc_value then
				log.error("could not find Goliath iap_pricing trial remote config with key %s", trial_rc_key)
			else
				log.debug("overwriting remote config %s with %s", rc_key, trial_rc_key)

				RC.v[rc_key] = trial_rc_value
			end
		else
			log.error("unknown libra trial type %s", k)
		end
	end
end

return mcg
