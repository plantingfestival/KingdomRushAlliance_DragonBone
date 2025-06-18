-- chunkname: @./all/platform_services_deep_links.lua

local log = require("klua.log"):new("platform_services_deep_links")
local signal = require("hump.signal")

require("klua.table")
require("klua.string")
require("constants")

local dl = {}

dl.can_be_paused = true
dl.update_interval = 3
dl.SRV_ID = 90
dl.SRV_DISPLAY_NAME = "Deep Links"

local proxy

if KR_PLATFORM == "ios" then
	proxy = {
		params = {}
	}

	local ffi = require("ffi")

	ffi.cdef("bool kdeeplink_initialize(void);\nvoid kdeeplink_shutdown(void);\nint kdeeplink_get_status(void);\nvoid kdeeplink_set_url_filter(const char* url);\nconst char* kdeeplink_get_deep_link(void);\nint kdeeplink_get_deep_link_epoch(void);\n")

	local C = ffi.C

	function proxy.init_service()
		if C.kdeeplink_initialize() then
			return 1
		end
	end

	function proxy.shutdown_service()
		C.kdeeplink_shutdown()
	end

	function proxy.set_service_param(key, val)
		if key == "url" then
			C.kdeeplink_set_url_filter(val)
		end
	end

	function proxy.get_deep_link()
		return ffi.string(C.kdeeplink_get_deep_link())
	end

	function proxy.get_deep_link_epoch()
		return C.kdeeplink_get_deep_link_epoch()
	end
else
	proxy = require("all.jni_android")
end

function dl:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		if not params or not params.url then
			log.error("%s requires url param", name)

			return nil
		end

		self.url = params.url

		proxy.set_service_param("url", self.url)

		do
			local result = proxy.init_service(self.SRV_ID)

			if result ~= 1 then
				log.error("%s native init failed", name)

				return nil
			end
		end

		self.inited = true
	end

	return true
end

function dl:shutdown(name)
	self.inited = nil
end

function dl:late_update(dt)
	local newlink, newepoch = self:get_deep_link()

	if newlink == self.last_link and newepoch == self.last_epoch then
		return
	end

	self.last_link_changed = true
	self.last_link = newlink
	self.last_epoch = newepoch

	signal.emit(SGN_PS_DEEP_LINK_CHANGED, self.name, newlink)
end

function dl:get_deep_link()
	local link = proxy.get_deep_link(self.SRV_ID)
	local epoch = proxy.get_deep_link_epoch(self.SRV_ID)

	return link, epoch
end

function dl:get_link()
	return self.last_link_changed and self.last_link or nil
end

function dl:get_epoch()
	return self.last_link_changed and self.last_epoch or nil
end

function dl:accept_link(link)
	if self.last_link == link then
		self.last_link_changed = nil
	end
end

return dl
