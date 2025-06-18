-- chunkname: @./all/platform_services_firebase_m.lua

local log = require("klua.log"):new("platform_services_firebase_m")
local signal = require("hump.signal")

require("klua.table")
require("klua.string")
require("constants")

local fbm = {}

fbm.can_be_paused = true
fbm.update_interval = 5
fbm.SRV_ID = 52
fbm.SRV_DISPLAY_NAME = "Firebase Messaging"

local proxy

if KR_PLATFORM == "ios" then
	local ffi = require("ffi")

	ffi.cdef("bool kfb_m_init_service(void);\nconst char* kfb_m_get_messaging_token(void);\n")

	local C = ffi.C

	proxy = {
		init_service = function(srvid)
			if C.kfb_m_init_service() then
				return 1
			end
		end,
		get_messaging_token = function(srvid)
			return ffi.string(C.kfb_m_get_messaging_token())
		end,
		create_request_messaging_ask_permission = function(srvid)
			log.error("create_request_messaging_ask_permission() not implemented on iOS")

			return -1
		end,
		get_messaging_should_show_rationale = function(srvid)
			log.error("get_messaging_should_show_rationale")

			return -1
		end,
		get_messaging_should_request_permission = function(srvid)
			log.error("get_messaging_should_request_permission")

			return -1
		end
	}
else
	proxy = require("all.jni_android")
end

function fbm:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		do
			local result = proxy.init_service(self.SRV_ID)

			if result ~= 1 then
				log.error("%s native init failed", name)

				return nil
			end

			signal.emit("ftue-step", "push_notification")
		end

		self.inited = true
	end

	return true
end

function fbm:shutdown(name)
	if self.inited then
		-- block empty
	end

	self.inited = nil
end

function fbm:get_token()
	return proxy.get_messaging_token(self.SRV_ID)
end

function fbm:get_ids()
	return proxy.get_messaging_ids(self.SRV_ID)
end

function fbm:check_permission()
	if KR_PLATFORM ~= "android" then
		return
	end

	if proxy.get_messaging_permission_granted(self.SRV_ID) then
		log.debug("permission granted... done")

		return
	elseif proxy.get_messaging_should_show_rationale(self.SRV_ID) then
		log.debug("should show rationale...")
		signal.emit(SGN_PS_PUSH_NOTI_SHOULD_SHOW_RATIONALE, self.name)
	elseif proxy.get_messaging_should_request_permission(self.SRV_ID) then
		log.debug("should request permission...")
		self:request_permission()
	end
end

function fbm:request_permission()
	local function cb_ask(status, req)
		local success = status == 0

		signal.emit(SGN_PS_PUSH_NOTI_PERMISSION_FINISHED, "push_noti", success, req.id)
	end

	local rid = proxy.create_request_messaging_ask_permission(self.SRV_ID)

	log.debug("showing push noti permission with request: %s", rid)

	return rid
end

return fbm
