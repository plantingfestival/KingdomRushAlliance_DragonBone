-- chunkname: @./all/http_download_thread.lua

local cin, cout, th_i = ...

require("love.filesystem")
require("love.image")
require("love.timer")

local http = require("socket.http")
local ltn12 = require("ltn12")

while true do
	local packet = cin:demand()

	if packet.cmd == "QUIT" then
		break
	end

	local method = packet.method or "GET"
	local url = packet.url
	local headers = packet.headers or {}
	local resp = {}
	local ok, code, header = http.request({
		method = method,
		url = url,
		headers = headers,
		sink = ltn12.sink.table(resp)
	})
	local body = ""

	for _, c in pairs(resp) do
		body = body .. c
	end

	cout:push({
		code ~= 200 and "ERROR" or "OK",
		url,
		code,
		header,
		body
	})
end

cout:supply({
	"DONE"
})
