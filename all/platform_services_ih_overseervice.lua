-- chunkname: @./all/platform_services_ih_overseervice.lua

local log = require("klua.log"):new("platform_services_ih_overseervice")
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

local PS = require("platform_services")
local PSU = require("platform_services_utils")
local GS = require("game_settings")
local RC = require("remote_config")
local srv = {}

srv.can_be_paused = true
srv.update_interval = 5
srv.SRV_DISPLAY_NAME = "Ironhide Overseervice"
srv.TIMEOUT_SENDING = 60
srv.TIMEOUT_ERROR_RETRY = DEBUG and 15 or 300
srv.MAX_BACKOFF_COUNT = 24
srv.MAX_EVENTS_STORED = 50
srv.MAX_NEW_EVENTS_SENT_PER_CYCLE = 5
srv.MAX_FAILED_EVENTS_SENT_PER_CYCLE = 2
srv.PROTOCOL_VERSION = 1

local ES_NEW = "new"
local ES_SENT = "sent"
local ES_SENDING = "sending"
local ES_FAILED = "failed"
local ES_INVALID = "invalid"
local proxy = {}

srv.proxy = proxy

if KR_PLATFORM == "ios" then
	local ffi = require("ffi")
elseif KR_PLATFORM == "android" then
	local jnia = require("all.jni_android")
end

srv.signal_handlers = {
	[SGN_PS_APPSFLYER_INIT_FINISHED] = function()
		log.debug("appsflyer init finished received. sending install event")
		srv:queue_event_install()
	end,
	[SGN_PS_GLVL2_CHECK_LICENSE_FINISHED] = function()
		log.debug("glvl2 check license finished received. sending install event")
		srv:queue_event_install()
	end,
	quit = function()
		log.debug("quit requested")
		srv:persist_event_buffer()
	end,
	["focus-changed"] = function(focus)
		log.debug("focus changed to %s", focus)

		if not focus then
			srv:persist_event_buffer()
		end
	end
}

function srv:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		if not PS.services.http or not PS.services.http.inited then
			log.error("%s requires platform_services_http inited", srv.SRV_DISPLAY_NAME)

			return nil
		end

		if not params then
			log.error("%s requires: api_url, api_key, shared_secret", srv.SRV_DISPLAY_NAME)

			return nil
		end

		if not params.FORCE_PRODUCTION and (DEBUG or params.FORCE_STAGING) then
			log.warning("%s: setting to STAGING environment", srv.SRV_DISPLAY_NAME)

			params.api_key = params.staging.api_key
			params.shared_secret = params.staging.shared_secret
			params.api_url = params.staging.api_url
		else
			log.warning("%s: setting to PRODUCTION environment", srv.SRV_DISPLAY_NAME)

			params.api_key = params.production.api_key
			params.shared_secret = params.production.shared_secret
			params.api_url = params.production.api_url
		end

		if not params.api_key or not params.shared_secret or not params.api_url then
			log.error("%s requires: api_url, api_key, shared_secret", srv.SRV_DISPLAY_NAME)

			return nil
		end

		self.api_key = params.api_key
		self.shared_secret = params.shared_secret
		self.api_url = params.api_url
		self.params = params

		if KR_PLATFORM == "ios" then
			local ffi = require("ffi")

			self.lib = ffi.C
		end

		self.data = {
			online_status = true,
			last_offline_ts = 0,
			initial_love_time = love.timer.getTime(),
			initial_os_time = os.time()
		}
		self.data.event_buffer = {}

		do
			local cache = storage:load_cache()

			if cache.ih_overseervice and cache.ih_overseervice.event_buffer then
				self.data.event_buffer = table.deepclone(cache.ih_overseervice.event_buffer)
			end
		end

		self.data.install_id = self:get_install_id()

		if params.send_install_on_init then
			self:queue_event_install()
		end

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

	return true
end

function srv:shutdown(name)
	if self.inited and self.signal_handlers then
		for sn, fn in pairs(self.signal_handlers) do
			log.debug("removing signal %s", sn)
			signal.remove(sn, fn)
		end
	end

	self.names = nil
	self.inited = nil
end

function srv:get_status()
	return self.inited
end

function srv:late_update(dt)
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

	local new_sent_count = 0
	local failed_sent_count = 0

	for _, e in pairs(self.data.event_buffer) do
		log.paranoid("processing event:%s  status:%s is_online:%s new:%s failed:%s", e, e.status, self.data.online_status, e.status == ES_NEW, e.status == ES_FAILED)

		if e.status == ES_SENDING and self:get_ts() - e.status_ts > self.TIMEOUT_SENDING then
			log.debug("timeout: marking event %s as falied", e.event)

			e.status = ES_FAILED

			self:set_online(false)

			dirty = true
		end

		if self:check_online() and (e.status == ES_NEW or e.status == ES_FAILED) then
			if e.status == ES_FAILED then
				if failed_sent_count >= self.MAX_FAILED_EVENTS_SENT_PER_CYCLE then
					goto label_8_0
				end

				failed_sent_count = failed_sent_count + 1
			else
				if new_sent_count >= self.MAX_NEW_EVENTS_SENT_PER_CYCLE then
					goto label_8_0
				end

				new_sent_count = new_sent_count + 1
			end

			self:send_event_to_server(e)

			dirty = true
		end

		::label_8_0::
	end

	if dirty and not PS.paused then
		self:persist_event_buffer()
	end
end

function srv:get_global(key, default)
	local global = storage:load_global()
	local v

	if global and global.ih_overseervice then
		v = global.ih_overseervice[key]
	end

	return v or default
end

function srv:set_global(key, value)
	local global = storage:load_global()

	global.ih_overseervice = global.ih_overseervice or {}
	global.ih_overseervice[key] = value

	storage:save_global(global)
end

function srv:get_ts(love_time)
	love_time = love_time or love.timer.getTime()

	local ts_f = love_time - self.data.initial_love_time + self.data.initial_os_time

	return math.floor(ts_f)
end

function srv:get_install_id()
	local iid = self:get_global("install_id")

	if not iid then
		iid = uuid:getUUID()

		log.debug("creating install_id: %s", iid)
		self:set_global("install_id", iid)
	end

	return iid
end

function srv:send_event_to_server(event)
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

			self:set_online(true)
			log.error("cb_send_event classified as:%s - status:%s req.id:%s code:%s url:%s data:%s", response_state, status, req.id, code, url, data)
			signal.emit("http-client-error", "ih_overseer_client", url, code, data)
		elseif response_state == "unknown_error" or response_state == "server_error" then
			req.event.status = ES_FAILED

			self:set_online(false)
			log.error("cb_send_event classified as:%s - status:%s req.id:%s code:%s url:%s data:%s", response_state, status, req.id, code, url, data)

			if not req.event._signal_emitted then
				signal.emit("http-client-error", "ih_overseer_other", url, code, data)

				req.event._signal_emitted = true
			end
		else
			log.debug("cb_send_event classified as:%s - status:%s req.id:%s code:%s url:%s data:%s", response_state, status, req.id, code, url, data)

			req.event.status = ES_SENT

			self:set_online(true)
		end
	end

	local ok, msg = pcall(json.encode, event.body)

	if not ok then
		log.error("error json encoding event %s:\n%s", event.event, getdump(event.body and event.body or {}))

		event.status = ES_INVALID
	else
		local http = PS.services.http
		local rid = http:post(self.api_url .. "/" .. event.event, self:get_http_headers(msg), msg, cb_send_event, self.TIMEOUT_SENDING)
		local req = http:get_pending_requests()[rid]

		req.event = event
		event.rid = rid
		event.status = ES_SENDING
		event.status_ts = self:get_ts()

		log.debug("sent event %s %s with rid:%s", event.event, event.random, rid)
	end
end

function srv:get_http_headers(msg)
	local h = {}

	h["cache-control"] = "no-cache"
	h["content-type"] = "application/json"
	h.apikey = self.api_key

	local rawchecksum = pbin.hextos(sha1.hmac(self.shared_secret, msg))

	h.checksum = b64.encode(rawchecksum)

	return h
end

function srv:persist_event_buffer()
	log.debug("saving event_buffer...")

	local cache = storage:load_cache()

	cache.ih_overseervice = cache.ih_overseervice or {}
	cache.ih_overseervice.event_buffer = self.data.event_buffer

	storage:save_cache(cache)
	log.debug("done saving event_buffer")
end

function srv:set_online(value)
	self.data.online_status = value

	if value then
		self.data.offline_count = nil

		log.debug("resetting backoff")
	else
		self.data.last_offline_ts = self:get_ts()
		self.data.offline_count = math.min(self.MAX_BACKOFF_COUNT, (self.data.offline_count or 0.5) * 2)

		log.debug("increasing backoff to %s", self.data.offline_count)
	end
end

function srv:check_online()
	if self.data.online_status then
		return true
	end

	local backoff_count = self.data.offline_count or 1

	if self:get_ts() - self.data.last_offline_ts < self.TIMEOUT_ERROR_RETRY * backoff_count then
		return false
	end

	self.data.online_status = true
	self.data.last_offline_ts = self:get_ts()

	return true
end

function srv:queue_event(name, payload)
	local body = {
		installId = self:get_install_id(),
		bundleId = version.bundle_id,
		appVersion = version.string_short,
		timestamp = self:get_ts()
	}

	if payload then
		table.merge(body, payload)
	end

	log.debug("queue_event:%s %s", name, getdump(body and body or {}))
	table.insert(self.data.event_buffer, {
		event = name,
		body = body,
		status = ES_NEW,
		random = math.random()
	})
end

function srv:queue_event_install()
	local payload = {}

	if not self.params.appsflyer_disabled and PS.services.appsflyer and PS.services.appsflyer.inited then
		local aid = PS.services.appsflyer:get_uid()

		if aid then
			payload.appsflyer = {
				id = aid
			}
		else
			log.error("Could not get appsflyer uid. Event install not sent.")

			return
		end
	end

	local iap = PS.services.iap

	if KR_PLATFORM == "android" and iap and PS.services.license then
		local jnia = require("all.jni_android")
		local ldata = jnia.get_license_data(PS.services.license.SRV_ID)

		if not ldata or ldata == "" then
			log.error("Could not get the license validation token from Google Play. Event install not sent")

			return
		end

		payload.googlePlay = {
			licenseValidationToken = ldata
		}
	end

	if KR_PLATFORM == "ios" and iap and iap.get_inapp_receipt then
		local receipt = iap:get_inapp_receipt()

		if not receipt or receipt == "" then
			log.error("Could not get the StoreKit receipt. Event install not sent.")

			return
		end

		payload.appleAppStore = {
			receipt = receipt
		}
	end

	self:queue_event("events/install", payload)
end

return srv
