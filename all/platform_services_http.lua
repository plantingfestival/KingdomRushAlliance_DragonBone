local log = require("klua.log"):new("platform_services_http")

require("klua.table")
require("klua.string")

local signal = require("hump.signal")
local json = require("json")
local PSU = require("platform_services_utils")

require("constants")
require("version")

local http = {}

http.can_be_paused = true
http.update_interval = 1
http.SRV_ID = 80
http.SRV_DISPLAY_NAME = "Http client"

local proxy, ffi

if KR_PLATFORM == "ios" or KR_PLATFORM == "mac" or KR_PLATFORM == "mac-appstore" or KR_PLATFORM == "win" then
	ffi = require("ffi")

	ffi.cdef("bool khttps_init_service(void);\nint  khttps_get_request_status(int rid);\nvoid khttps_delete_request(int rid);\nint  khttps_create_request_https(const char* method, const char* url, const char* headers, const char* body, int body_length);\nvoid khttps_delete_https_response(int rid);\nint  khttps_get_https_response_code(int rid);\n    ")

	if KR_PLATFORM == "win" then
		ffi.cdef("size_t khttps_get_https_response_headers(int rid, char* buffer, size_t bufSize); \nsize_t khttps_get_https_response_data(int rid, unsigned long* len, char* buffer, size_t bufSize);\n")
	else
		ffi.cdef("const char* khttps_get_https_response_headers(int rid);\nconst char* khttps_get_https_response_data(int rid, unsigned long* len);\n")
	end

	proxy = {}

	if KR_PLATFORM == "ios" then
		proxy.C = ffi.C
	end

	function proxy.init_service(srvid)
		if proxy.C.khttps_init_service() then
			return 1
		end
	end

	function proxy.create_request_https(srvid, method, url, headers, body)
		if not http.inited then
			return -1
		end

		local body_length = 0

		if body and body ~= "" and #body > 0 then
			body_length = #body
		end

		local result = proxy.C.khttps_create_request_https(method, url, headers, body, body_length)

		return result
	end

	function proxy.delete_https_response(srvid, rid)
		proxy.C.khttps_delete_https_response(rid)
	end

	function proxy.delete_request(rid)
		proxy.C.khttps_delete_request(rid)
	end

	function proxy.get_https_response_code(srvid, rid)
		if not http.inited then
			return -1
		end

		return proxy.C.khttps_get_https_response_code(rid)
	end

	function proxy.get_https_response_headers(srvid, rid)
		if not http.inited then
			return ""
		end

		local str

		if KR_PLATFORM == "win" then
			local result_size = 2097152
			local result = ffi.new("char[?]", result_size)
			local actual_size = proxy.C.khttps_get_https_response_headers(rid, result, result_size)

			str = ffi.string(result, actual_size)
		else
			str = ffi.string(proxy.C.khttps_get_https_response_headers(rid))
		end

		return str
	end

	function proxy.get_https_response_data(srvid, rid)
		if not http.inited then
			return ""
		end

		local str
		local len = ffi.new("unsigned long[1]", 0)

		if KR_PLATFORM == "win" then
			local result_size = 1048576
			local result = ffi.new("char[?]", result_size)
			local actual_size = proxy.C.khttps_get_https_response_data(rid, len, result, result_size)

			str = ffi.string(result, actual_size)
		else
			local buf = proxy.C.khttps_get_https_response_data(rid, len)

			str = ffi.string(buf, len[0])
		end

		if DEBUG then
			local dd = require("debug_tools")
			local slen = string.len(str)
		end

		return str
	end

	function proxy.get_request_status(rid)
		if http.inited then
			local result = proxy.C.khttps_get_request_status(rid)

			return result
		else
			return -1
		end
	end
else
	proxy = require("all.jni_android")
end

http.proxy = proxy

function http:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		if KR_PLATFORM == "android" then
			-- block empty
		elseif KR_PLATFORM == "mac" or KR_PLATFORM == "mac-appstore" then
			self.lib = PSU:load_library("krequest", ffi)
			self.lib = PSU:load_library("khttps", ffi)

			if not self.lib then
				log.error("Error loading khttps library")

				return false
			end

			proxy.C = self.lib
		elseif KR_PLATFORM == "win" then
			self.lib = PSU:load_library("libcurl-x64", ffi)
			self.lib = PSU:load_library("khttps", ffi)

			if not self.lib then
				log.error("Error loading %s library", name)

				return false
			end

			proxy.C = self.lib
		end

		do
			local result = proxy.init_service(self.SRV_ID)

			if result ~= 1 then
				log.error("platform_services_http init failed")

				return nil
			end
		end

		self.prq = PSU:new_prq()
		self.inited = true
	end

	return true
end

function http:shutdown(name)
	if self.inited then
		-- block empty
	end

	self.inited = nil
	self.lib = nil
end

function http:get_pending_requests()
	return self.prq
end

function http:get_request_status(rid)
	local result = proxy.get_request_status(rid)

	--log.paranoid("get_request_status (%s) result: %s", rid, result)

	return result
end

function http:cancel_request(rid)
	if not rid then
		return
	end

	self.prq:remove(rid)
	proxy.delete_https_response(self.SRV_ID, rid)
	proxy.delete_request(rid)
end

function http:string_to_header(str)
	local t = {}

	if not str then
		log.error("header string is nil")

		return t
	end

	local lines = string.split(str, "\n")

	for _, l in pairs(lines) do
		local k, v = unpack(string.split(l, ":"))

		t[k] = v
	end

	return t
end

function http:header_to_string(t)
	if not t then
		return ""
	end

	return table.concat(table.map(t, function(k, v)
		return string.format("%s:%s", k, v)
	end), "\n")
end

function http:parse_json(data)
	local ok, out = pcall(json.decode, data)

	if not ok then
		log.error("invalid json: %s", out)
	end

	return ok, out
end

function http:date_to_time(date)
	local m = {
		string.match(date, "(%d%d%d%d)%-(%d%d)%-(%d%d)T?(%d?%d?):?(%d?%d?)")
	}

	if not m or #m < 3 then
		log.error("invalid input date:%s. fallback to current date", date)

		return os.time()
	end

	local t = {
		year = m[1],
		month = m[2],
		day = m[3],
		hour = m[4] or 0,
		min = m[5] or 0
	}
	local o = os.time(t)

	if not o then
		local y = tonumber(t.year)

		if y and y >= 2038 then
			t.year = 2038
			t.month = 1
			t.day = 1
			t.hour = 0
			t.min = 0
		elseif y and y <= 1902 then
			t.year = 1902
			t.month = 1
			t.day = 1
			t.hour = 0
			t.min = 0
		end

		o = os.time(t)
	end

	o = o or os.time()

	return o
end

function http:time_to_date(time)
	return os.date("%Y-%m-%dT%TZ", time)
end

function http:get(url, header, callback, timeout)
	local function cb_get(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		log.debug("cb_get(status:%s, req.id:%s)", status, req.id)

		local success = status == 0
		local rid, code, header_out, data

		if success then
			rid = req.id
			code = proxy.get_https_response_code(self.SRV_ID, rid)
			header_out = self:string_to_header(proxy.get_https_response_headers(self.SRV_ID, rid))
			data = proxy.get_https_response_data(self.SRV_ID, rid)
		else
			code = status
		end

		if callback then
			callback(status, req, url, code, header_out, data)
		end
	end

	local header_str = self:header_to_string(header)
	local rid = proxy.create_request_https(self.SRV_ID, "GET", url, header_str, "")

	self.prq:add(rid, "http_get:" .. url, cb_get, timeout)
	log.debug("http get:%s, rid:%s, header:%s", url, rid, header_str)

	return rid
end

function http:post(url, header, body, callback, timeout)
	local function cb_post(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		--log.debug("cb_post(status:%s, req.id:%s)", status, req.id)

		local success = status == 0
		local rid, code, header_out, data

		if success then
			rid = req.id
			code = proxy.get_https_response_code(self.SRV_ID, rid)
			header_out = self:string_to_header(proxy.get_https_response_headers(self.SRV_ID, rid))
			data = proxy.get_https_response_data(self.SRV_ID, rid)
		else
			code = status
		end

		if callback then
			callback(status, req, url, code, header_out, data)
		end
	end

	local header_str = self:header_to_string(header)
	local rid = proxy.create_request_https(self.SRV_ID, "POST", url, header_str, body)

	self.prq:add(rid, "http_post:" .. url, cb_post, timeout)
	log.debug("http post:%s rid:%s header:%s\nbody:%s", url, rid, header_str, body)

	return rid
end

return http
