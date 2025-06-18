-- chunkname: @./lib/sha1/init.lua

local common = require("sha1.common")
local sha1 = {
	_VERSION = "sha.lua 0.6.0",
	_DESCRIPTION = "SHA-1 secure hash and HMAC-SHA1 signature computation in Lua,\nusing bit and bit32 modules and Lua 5.3 operators when available\nand falling back to a pure Lua implementation on Lua 5.1.\nBased on code orignally by Jeffrey Friedl and modified by\nEike Decker and Enrique García Cota.",
	_URL = "https://github.com/mpeterv/sha1",
	_LICENSE = "MIT LICENSE\n\nCopyright (c) 2013 Enrique García Cota, Eike Decker, Jeffrey Friedl\nCopyright (c) 2018 Peter Melnichenko\n\nPermission is hereby granted, free of charge, to any person obtaining a\ncopy of this software and associated documentation files (the\n\"Software\"), to deal in the Software without restriction, including\nwithout limitation the rights to use, copy, modify, merge, publish,\ndistribute, sublicense, and/or sell copies of the Software, and to\npermit persons to whom the Software is furnished to do so, subject to\nthe following conditions:\n\nThe above copyright notice and this permission notice shall be included\nin all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS\nOR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF\nMERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.\nIN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY\nCLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,\nTORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE\nSOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
}

sha1.version = "0.6.0"

local function choose_ops()
	if pcall(require, "bit") then
		return "bit_ops"
	elseif pcall(require, "bit32") then
		return "bit32_ops"
	else
		return "pure_lua_ops"
	end
end

local ops = require("sha1." .. choose_ops())
local uint32_lrot = ops.uint32_lrot
local byte_xor = ops.byte_xor
local uint32_xor_3 = ops.uint32_xor_3
local uint32_xor_4 = ops.uint32_xor_4
local uint32_ternary = ops.uint32_ternary
local uint32_majority = ops.uint32_majority
local bytes_to_uint32 = common.bytes_to_uint32
local uint32_to_bytes = common.uint32_to_bytes
local sbyte = string.byte
local schar = string.char
local sformat = string.format
local srep = string.rep

local function hex_to_binary(hex)
	return (hex:gsub("..", function(hexval)
		return schar(tonumber(hexval, 16))
	end))
end

function sha1.sha1(str)
	local first_append = schar(128)
	local non_zero_message_bytes = #str + 1 + 8
	local second_append = srep(schar(0), -non_zero_message_bytes % 64)
	local third_append = schar(0, 0, 0, 0, uint32_to_bytes(#str * 8))

	str = str .. first_append .. second_append .. third_append

	assert(#str % 64 == 0)

	local h0 = 1732584193
	local h1 = 4023233417
	local h2 = 2562383102
	local h3 = 271733878
	local h4 = 3285377520
	local w = {}

	for chunk_start = 1, #str, 64 do
		local uint32_start = chunk_start

		for i = 0, 15 do
			w[i] = bytes_to_uint32(sbyte(str, uint32_start, uint32_start + 3))
			uint32_start = uint32_start + 4
		end

		for i = 16, 79 do
			w[i] = uint32_lrot(uint32_xor_4(w[i - 3], w[i - 8], w[i - 14], w[i - 16]), 1)
		end

		local a = h0
		local b = h1
		local c = h2
		local d = h3
		local e = h4

		for i = 0, 79 do
			local f, k

			if i <= 19 then
				f = uint32_ternary(b, c, d)
				k = 1518500249
			elseif i <= 39 then
				f = uint32_xor_3(b, c, d)
				k = 1859775393
			elseif i <= 59 then
				f = uint32_majority(b, c, d)
				k = 2400959708
			else
				f = uint32_xor_3(b, c, d)
				k = 3395469782
			end

			local temp = (uint32_lrot(a, 5) + f + e + k + w[i]) % 4294967296

			e = d
			d = c
			c = uint32_lrot(b, 30)
			b = a
			a = temp
		end

		h0 = (h0 + a) % 4294967296
		h1 = (h1 + b) % 4294967296
		h2 = (h2 + c) % 4294967296
		h3 = (h3 + d) % 4294967296
		h4 = (h4 + e) % 4294967296
	end

	return sformat("%08x%08x%08x%08x%08x", h0, h1, h2, h3, h4)
end

function sha1.binary(str)
	return hex_to_binary(sha1.sha1(str))
end

local xor_with_0x5c = {}
local xor_with_0x36 = {}

for i = 0, 255 do
	xor_with_0x5c[schar(i)] = schar(byte_xor(92, i))
	xor_with_0x36[schar(i)] = schar(byte_xor(54, i))
end

local BLOCK_SIZE = 64

function sha1.hmac(key, text)
	if #key > BLOCK_SIZE then
		key = sha1.binary(key)
	end

	local key_xord_with_0x36 = key:gsub(".", xor_with_0x36) .. srep(schar(54), BLOCK_SIZE - #key)
	local key_xord_with_0x5c = key:gsub(".", xor_with_0x5c) .. srep(schar(92), BLOCK_SIZE - #key)

	return sha1.sha1(key_xord_with_0x5c .. sha1.binary(key_xord_with_0x36 .. text))
end

function sha1.hmac_binary(key, text)
	return hex_to_binary(sha1.hmac(key, text))
end

setmetatable(sha1, {
	__call = function(_, str)
		return sha1.sha1(str)
	end
})

return sha1
