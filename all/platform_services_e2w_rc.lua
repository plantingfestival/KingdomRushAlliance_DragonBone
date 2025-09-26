-- chunkname: @./all/platform_services_e2w_rc.lua

local log = require("klua.log"):new("platform_services_e2w_rc")

require("klua.table")

local signal = require("hump.signal")
local storage = require("storage")
local jnia = require("all.jni_android")
local PSU = require("platform_services_utils")
local RC = require("remote_config")
local PS = require("platform_services")
local srv = {}

srv.can_be_paused = true
srv.update_interval = 3
srv.SRV_DISPLAY_NAME = "E2W Remote Config"
srv.rc_data = {}
srv.signal_handlers = {}

function srv:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		if not PS.services.http or not PS.services.http.inited then
			log.error("%s requires platform_services_http inited", srv.SRV_DISPLAY_NAME)

			return nil
		end

		if not params.rc_url then
			log.error("%s requires rc_url", srv.SRV_DISPLAY_NAME)

			return nil
		end

		self.rc_url = params.rc_url
		self.prq = PSU:new_prq()

		for sn, fn in pairs(self.signal_handlers) do
			signal.register(sn, fn)
		end

		self.inited = true
	end

	if not self.names then
		self.names = {}
	end

	if not table.contains(self.names, name) then
		table.insert(self.names, name)
	end

	return true
end

function srv:shutdown(name)
	if self.inited then
		for sn, fn in pairs(self.signal_handlers) do
			signal.remove(sn, fn)
		end
	end

	self.names = nil
	self.inited = nil
end

function srv:get_status()
	return self.inited
end

function srv:get_string(key)
	return self.rc_data[key]
end

function srv:get_keys()
	return table.keys(self.rc_data)
end

function srv:sync()
	local function cb_sync_rc(status, req, url, code, header, data)
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

		if response_state == "client_error" or response_state == "unknown_error" or response_state == "server_error" then
			log.error("cb_sync_rc error: %s - status:%s req.id:%s code:%s url:%s data:%s", response_state, status, req.id, code, url, data)

			return
		end

		local ok, jdata = PS.services.http:parse_json(data)

		if not ok or not jdata or type(jdata) ~= "table" then
			log.error("cb_sync_rc: error parsing json data:%s", data)

			return
		end

		for _, row in pairs(jdata) do
			self.rc_data[row.name] = row.value
		end

		log.debug("remote config success")
		signal.emit(SGN_PS_REMOTE_CONFIG_SYNC_FINISHED, "remoteconfig", true)
	end

	local http = PS.services.http
	local url = string.format("%s/get_all_key_value_pairs?platform_type=%s&game_bundle_id=%s&game_version=%s", self.rc_url, KR_PLATFORM, version.bundle_id, version.string_short)
	local rid = http:get(url, nil, cb_sync_rc, 60)
	local req = http:get_pending_requests()[rid]

	log.debug("started remote config sync with rid:%s", rid)
end

return srv
