-- chunkname: @./lib/plc/bin.lua

local byte, char, concat = string.byte, string.char, table.concat
local bit = require("bit")
local strf = string.format

local function stohex(s, ln, sep)
	if #s == 0 then
		return ""
	end

	if not ln then
		return (s:gsub(".", function(c)
			return strf("%02x", byte(c))
		end))
	end

	sep = sep or ""

	local t = {}

	for i = 1, #s - 1 do
		t[#t + 1] = strf("%02x%s", s:byte(i), i % ln == 0 and "\n" or sep)
	end

	t[#t + 1] = strf("%02x", s:byte(#s))

	return concat(t)
end

local function hextos(hs, unsafe)
	local tonumber = tonumber

	if not unsafe then
		hs = string.gsub(hs, "%s+", "")

		if string.find(hs, "[^0-9A-Za-z]") or #hs % 2 ~= 0 then
			error("invalid hex string")
		end
	end

	return hs:gsub("(%x%x)", function(c)
		return char(tonumber(c, 16))
	end)
end

return {
	stohex = stohex,
	hextos = hextos
}
