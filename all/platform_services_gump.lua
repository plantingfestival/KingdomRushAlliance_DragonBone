-- chunkname: @./all/platform_services_gump.lua

local log = require("klua.log"):new("platform_services_gump")
local PSU = require("platform_services_utils")

require("klua.table")

local signal = require("hump.signal")
local gump = {}

gump.can_be_paused = true
gump.update_interval = 1
gump.SRV_ID = 4
gump.SRV_DISPLAY_NAME = "Google User Messaging Platform (CMP)"
gump.LONG_TIMEOUT = 900
gump.inited = false

if KR_PLATFORM == "ios" then
	gump.proxy = {}

	local ffi = require("ffi")

	ffi.cdef("void kgump_set_service_param(const char* key, const char* value);\nbool kgump_init_service(void);\nint kgump_get_request_status(int rid);\nvoid kgump_delete_request(int rid);\n\nint kgump_get_consent_status(void);\nint kgump_create_request_sync_consent_status(void);\nint kgump_create_request_show_consent_form(void);\nint kgump_create_request_show_consent_options(void);\n\nvoid kgump_reset_consent_status(void);\nvoid kgump_add_consent_test_device(const char* id);\nvoid kgump_add_consent_test_geography(const char* location); \n")

	local C = ffi.C

	function gump.proxy.set_service_param(key, value)
		C.kgump_set_service_param(key, value)
	end

	function gump.proxy.init_service()
		if C.kgump_init_service() then
			return 1
		end
	end

	function gump.proxy.get_request_status(rid)
		return C.kgump_get_request_status(rid)
	end

	function gump.proxy.delete_request(rid)
		C.kgump_delete_request(rid)
	end

	function gump.proxy.get_consent_status(srvid)
		return C.kgump_get_consent_status()
	end

	function gump.proxy.create_request_sync_consent_status(srvid)
		return C.kgump_create_request_sync_consent_status()
	end

	function gump.proxy.create_request_show_consent_form(srvid)
		return C.kgump_create_request_show_consent_form()
	end

	function gump.proxy.create_request_show_consent_options(srvid)
		return C.kgump_create_request_show_consent_options()
	end

	function gump.proxy.reset_consent_status(srvid)
		C.kgump_reset_consent_status()
	end

	function gump.proxy.add_consent_test_device(srvid, deviceid)
		C.kgump_add_consent_test_device(deviceid)
	end

	function gump.proxy.add_consent_test_geography(srvid, location)
		C.kgump_add_consent_test_geography(location)
	end
else
	gump.proxy = require("all.jni_android")
end

function gump:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		do
			local result = gump.proxy.init_service(self.SRV_ID)

			if result ~= 1 then
				log.error("platform_services_gump init failed")

				return nil
			end
		end

		self.prq = PSU:new_prq()
		self.inited = true

		if params.test_device then
			gump.proxy.add_consent_test_device(self.SRV_ID, params.test_device)
		end

		if params.test_geography then
			gump.proxy.add_consent_test_geography(self.SRV_ID, params.test_geography)
		end

		if params.sync_on_init then
			self:sync_consent_status()
		end
	end

	self.names = self.names or {}

	if not table.contains(self.names, name) then
		table.insert(self.names, name)
	end

	return true
end

function gump:shutdown(name)
	if self.inited then
		-- block empty
	end

	self.inited = nil
end

function gump:get_status()
	return self.inited
end

function gump:get_pending_requests()
	return self.prq
end

function gump:get_request_status(rid)
	local result = self.proxy.get_request_status(rid)

	log.paranoid("get_request_status (%s) result: %s", rid, result)

	return result
end

function gump:cancel_request(rid)
	if not rid then
		return
	end

	self.prq:remove(rid)
	self.proxy.delete_request(rid)
end

function gump:get_consent_status()
	return self.proxy.get_consent_status(self.SRV_ID)
end

function gump:sync_consent_status()
	local function cb(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		log.info("sync_consent_status complete for req.id:%s status:%s", req.id, status)

		local success

		success = status == 0 and true or false

		signal.emit(SGN_PS_SYNC_CONSENT_STATUS_FINISHED, "cmp", success)
	end

	local rid = self.proxy.create_request_sync_consent_status(self.SRV_ID)

	if rid < 0 then
		log.error("error creating sync_consent_status request")

		return nil
	end

	self.prq:add(rid, "sync_consent_status", cb)

	return rid
end

function gump:show_consent_form()
	local function cb(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		log.info("show_consent_form complete for req.id:%s status:%s", req.id, status)

		local success

		success = status == 0 and true or false

		signal.emit(SGN_PS_SHOW_CONSENT_FORM_FINISHED, "cmp", success)
	end

	local rid = self.proxy.create_request_show_consent_form(self.SRV_ID)

	if rid < 0 then
		log.error("error creating show_consent_form request")

		return nil
	end

	self.prq:add(rid, "show_consent_form", cb, self.LONG_TIMEOUT)

	return rid
end

function gump:show_consent_options()
	local function cb(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		log.info("show_consent_options complete for req.id:%s status:%s", req.id, status)

		local success

		success = status == 0 and true or false

		signal.emit(SGN_PS_SHOW_CONSENT_OPTIONS_FINISHED, "cmp", success)
	end

	local rid = self.proxy.create_request_show_consent_options(self.SRV_ID)

	if rid < 0 then
		log.error("error creating show_consent_options request")

		return nil
	end

	self.prq:add(rid, "show_consent_options", cb, self.LONG_TIMEOUT)

	return rid
end

return gump
