-- chunkname: @./all/platform_services_e2w_aa.lua

local log = require("klua.log"):new("platform_services_e2w_aa")

require("klua.table")

local signal = require("hump.signal")
local storage = require("storage")
local jnia = require("all.jni_android")
local PSU = require("platform_services_utils")
local RC = require("remote_config")
local srv = {}

srv.can_be_paused = true
srv.update_interval = 3
srv.SRV_ID = 32
srv.SRV_DISPLAY_NAME = "E2W Anti Addiction"
srv.signal_handlers = {}

local proxy

if KR_PLATFORM == "ios" then
	proxy = {}

	local ffi = require("ffi")

	ffi.cdef("void ke2w_set_service_param(const char* key, const char* value);\nbool ke2w_initialize(void);\n")

	local C = ffi.C

	function proxy.init_service(srvid)
		if C.ke2w_initialize() then
			return 1
		end
	end

	function proxy.set_service_param(key, value)
		C.ke2w_set_service_param(key, value)
	end

	function proxy.get_service_status(srvid)
		return true
	end
else
	log.error("%s does not fully work in platform %s", srv.SRV_DISPLAY_NAME, KR_PLATFORM)

	proxy = {
		init_service = function(srvid)
			log.error("NOT IMPLEMENTED")
		end,
		set_service_param = function(key, value)
			log.error("NOT IMPLEMENTED")
		end,
		get_service_status = function(srvid)
			log.error("NOT IMPLEMENTED")
		end
	}
end

function srv:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		proxy.set_service_param("e2w_biz_id", params.biz_id)
		proxy.set_service_param("e2w_sku", params.sku)

		do
			local result = proxy.init_service(self.SRV_ID)

			if result ~= 1 then
				log.error("%s init failed", name)

				return nil
			end
		end

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
	return proxy.get_service_status(self.SRV_ID) == 1
end

return srv
