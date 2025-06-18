-- chunkname: @./lib/sha1/common.lua

local common = {}

function common.bytes_to_uint32(a, b, c, d)
	return a * 16777216 + b * 65536 + c * 256 + d
end

function common.uint32_to_bytes(a)
	local a4 = a % 256

	a = (a - a4) / 256

	local a3 = a % 256

	a = (a - a3) / 256

	local a2 = a % 256
	local a1 = (a - a2) / 256

	return a1, a2, a3, a4
end

return common
