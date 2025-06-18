-- chunkname: @./all/platform_services_appsflyer.lua

local log = require("klua.log"):new("platform_services_appsflyer")
local signal = require("hump.signal")

require("klua.table")
require("klua.string")
require("constants")

local UPGR = require("upgrades")
local PP = require("privacy_policy_consent")
local PS = require("platform_services")
local srv = {}

srv.can_be_paused = true
srv.update_interval = 3
srv.SRV_ID = 21
srv.SRV_DISPLAY_NAME = "Firebase Analytics"
srv.signal_handlers = {
	["ftue-step"] = function(step)
		if step == "tutorial_ends" then
			srv:log_event("af_tutorial_completion")
		end
	end,
	["game-victory"] = function(store)
		srv:log_events("af_level_achieved", {
			{
				"af_level",
				string.format("%s", store.level_idx)
			}
		})
	end,
	[SGN_PS_SYNC_CONSENT_STATUS_FINISHED] = function(sname, success)
		if success then
			log.debug("cmp sync success")

			local cmp = PS.services.cmp
			local cs = cmp:get_consent_status()

			if cs == -1 or cs == 0 then
				log.error("ERROR. consent status %s invalid after sync success", cs)

				return
			elseif cs == 2 then
				cmp:show_consent_form()
			else
				srv:native_init()
			end
		else
			log.error("cmp sync failed")
		end
	end,
	[SGN_PS_SHOW_CONSENT_FORM_FINISHED] = function(sname, success)
		if success then
			log.debug("cmp form finished: init native")
			srv:native_init()
		else
			log.error("cmp form failed to show")
		end
	end
}

local proxy

if KR_PLATFORM == "ios" then
	proxy = {}

	local ffi = require("ffi")

	ffi.cdef("typedef struct kafKeyValue{\n    const char* key;\n    const char* value;\n} kafKeyValue;\nvoid kaf_set_service_param(const char* key, const char* value);\nbool kaf_initialize(void);\nbool kaf_initialize_notifications(void);\nvoid kaf_log_analytics_events(const char* name, kafKeyValue *params, size_t size);\n")

	local C = ffi.C

	function proxy.init_service(srvid)
		if C.kaf_initialize() then
			return 1
		end
	end

	function proxy.set_service_param(key, value)
		C.kaf_set_service_param(key, value)
	end

	function proxy.log_analytics_event_multiparam(srvid, name, params)
		if not srv.inited then
			return -1
		end

		local kva
		local kva_size = 0

		if params then
			local keys = table.keys(params)

			kva_size = #keys
			kva = ffi.new("kafKeyValue[?]", #keys)

			local i = 0

			for k, v in pairs(params) do
				kva[i].key = tostring(k)
				kva[i].value = tostring(v)
			end
		end

		C.kaf_log_analytics_events(name, kva, kva_size)
	end
else
	proxy = require("all.jni_android")
end

function srv:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		if not params or not params.dev_key then
			log.error("%s requires params.dev_key", name)

			return nil
		end

		proxy.set_service_param("appsflyer_dev_key", params.dev_key)

		if KR_PLATFORM == "ios" then
			if not params or not params.apple_app_id then
				log.error("%s requires params.apple_app_id", name)

				return nil
			end

			proxy.set_service_param("appsflyer_apple_app_id", params.apple_app_id)
		end

		proxy.set_service_param("appsflyer_underage", PP:is_underage() and "true" or "false")
		proxy.set_service_param("appsflyer_has_cmp", params.has_cmp and "true" or "false")
		proxy.set_service_param("appsflyer_debug", (DEBUG or params.debug) and "true" or "false")
		log.debug("debug mode is %s", DEBUG or params.debug)

		if self.signal_handlers then
			for sn, fn in pairs(self.signal_handlers) do
				log.debug("registering signal %s", sn)
				signal.register(sn, fn)
			end
		end

		self.inited = true

		if params.has_cmp and not PP:is_underage() then
			local cmp = PS.services.cmp

			if not cmp then
				log.error("%s requires cmp service up and running", name)

				return false
			end

			if not cmp:get_status() then
				log.error("%s requires cmp to be up and running. get_status()==false", name)

				return false
			else
				log.debug("CMP READY cmp:get_consent_status():%s", cmp:get_consent_status())

				local cs = cmp:get_consent_status()

				if cs == -1 then
					log.error("could not get consent status from gump. do not init appsflyer")

					self.inited = false

					return false
				elseif cs == 0 or cs == 2 then
					cmp:sync_consent_status()

					return true
				else
					log.debug("consent not required or obtained... continue.")
				end
			end
		end

		self:native_init()
	end

	return true
end

function srv:shutdown(name)
	if self.inited then
		for sn, fn in pairs(self.signal_handlers) do
			signal.remove(sn, fn)
		end
	end

	self.inited = nil
end

function srv:native_init()
	log.debug("native init")
	signal.emit("ftue-step", "att")

	local result = proxy.init_service(self.SRV_ID)

	if result ~= 1 then
		log.error("%s native init failed", "appsflyer")

		return nil
	end
end

function srv:log_event(name, key, value)
	value = string.format("%s", value)

	proxy.log_analytics_event(self.SRV_ID, name, key, value)
end

function srv:log_events(name, params)
	proxy.log_analytics_event_multiparam(self.SRV_ID, name, params)
end

return srv
