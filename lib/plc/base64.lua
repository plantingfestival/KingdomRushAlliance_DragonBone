-- chunkname: @./lib/plc/base64.lua

local byte, char, concat = string.byte, string.char, table.concat
local shl, shr, band, bor

if _G.bit then
	shl, shr, band, bor = _G.bit.lshift, _G.bit.rshift, _G.bit.band, _G.bit.bor
end

local B64CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local b64charmap = {}

for i = 1, 64 do
	b64charmap[byte(B64CHARS, i)] = i - 1
end

local function encode(s, filename_safe)
	local b64chars = B64CHARS
	local rn = #s % 3
	local st = {}
	local c1, c2, c3
	local t4 = {}
	local lln, maxlln = 1, 72

	for i = 1, #s, 3 do
		c1 = byte(s, i)
		c2 = byte(s, i + 1) or 0
		c3 = byte(s, i + 2) or 0
		t4[1] = char(byte(b64chars, shr(c1, 2) + 1))
		t4[2] = char(byte(b64chars, band(bor(shl(c1, 4), shr(c2, 4)), 63) + 1))
		t4[3] = char(byte(b64chars, band(bor(shl(c2, 2), shr(c3, 6)), 63) + 1))
		t4[4] = char(byte(b64chars, band(c3, 63) + 1))
		st[#st + 1] = concat(t4)
		lln = lln + 4

		if maxlln < lln then
			st[#st + 1] = "\n"
			lln = 1
		end
	end

	local llx = #st

	if st[llx] == "\n" then
		llx = llx - 1
	end

	if rn == 2 then
		st[llx] = string.gsub(st[llx], ".$", "=")
	elseif rn == 1 then
		st[llx] = string.gsub(st[llx], "..$", "==")
	end

	local b = concat(st)

	if filename_safe then
		b = string.gsub(b, "%+", "-")
		b = string.gsub(b, "/", "_")
		b = string.gsub(b, "[%s=]", "")
	end

	return b
end

local function decode(b)
	local cmap = b64charmap
	local e1, e2, e3, e4
	local st = {}
	local t3 = {}

	b = string.gsub(b, "%-", "+")
	b = string.gsub(b, "_", "/")
	b = string.gsub(b, "[=%s]", "")

	if b:find("[^0-9A-Za-z/+=]") then
		return nil, "invalid char"
	end

	for i = 1, #b, 4 do
		e1 = cmap[byte(b, i)]
		e2 = cmap[byte(b, i + 1)]

		if not e1 or not e2 then
			return nil, "invalid length"
		end

		e3 = cmap[byte(b, i + 2)]
		e4 = cmap[byte(b, i + 3)]
		t3[1] = char(bor(shl(e1, 2), shr(e2, 4)))

		if not e3 then
			t3[2] = nil
			t3[3] = nil
			st[#st + 1] = concat(t3)

			break
		end

		t3[2] = char(band(bor(shl(e2, 4), shr(e3, 2)), 255))

		if not e4 then
			t3[3] = nil
			st[#st + 1] = concat(t3)

			break
		end

		t3[3] = char(band(bor(shl(e3, 6), e4), 255))
		st[#st + 1] = concat(t3)
	end

	return concat(st)
end

return {
	encode = encode,
	decode = decode
}
