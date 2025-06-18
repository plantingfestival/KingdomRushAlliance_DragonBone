-- chunkname: @./lib/sha1/pure_lua_ops.lua

local common = require("sha1.common")
local ops = {}
local bytes_to_uint32 = common.bytes_to_uint32
local uint32_to_bytes = common.uint32_to_bytes

function ops.uint32_lrot(a, bits)
	local power = 2^bits
	local inv_power = 4294967296 / power
	local lower_bits = a % inv_power

	return lower_bits * power + (a - lower_bits) / inv_power
end

local function make_op_cache(bit_op, bits)
	if bits == 1 then
		return {
			[0] = bit_op(0, 0),
			bit_op(0, 1),
			bit_op(1, 0),
			bit_op(1, 1)
		}
	end

	local half_bits = bits / 2
	local size = 2^bits
	local half_size = 2^half_bits
	local half_cache = make_op_cache(bit_op, half_bits)
	local cache = {}

	for a1 = 0, half_size - 1 do
		local a1_half_size = a1 * half_size

		for a2 = 0, half_size - 1 do
			local a2_size = a2 * half_size
			local a_size = (a1_half_size + a2) * size

			for b1 = 0, half_size - 1 do
				local a_size_plus_b1_half_size = a_size + b1 * half_size
				local v1_half_size = half_cache[a1_half_size + b1] * half_size

				for b2 = 0, half_size - 1 do
					cache[a_size_plus_b1_half_size + b2] = v1_half_size + half_cache[a2_size + b2]
				end
			end
		end
	end

	return cache
end

local byte_and_cache = make_op_cache(function(a, b)
	return a * b
end, 8)
local byte_xor_cache = make_op_cache(function(a, b)
	return a == b and 0 or 1
end, 8)

function ops.byte_xor(a, b)
	return byte_xor_cache[a * 256 + b]
end

function ops.uint32_xor_3(a, b, c)
	local a1, a2, a3, a4 = uint32_to_bytes(a)
	local b1, b2, b3, b4 = uint32_to_bytes(b)
	local c1, c2, c3, c4 = uint32_to_bytes(c)

	return bytes_to_uint32(byte_xor_cache[a1 * 256 + byte_xor_cache[b1 * 256 + c1]], byte_xor_cache[a2 * 256 + byte_xor_cache[b2 * 256 + c2]], byte_xor_cache[a3 * 256 + byte_xor_cache[b3 * 256 + c3]], byte_xor_cache[a4 * 256 + byte_xor_cache[b4 * 256 + c4]])
end

function ops.uint32_xor_4(a, b, c, d)
	local a1, a2, a3, a4 = uint32_to_bytes(a)
	local b1, b2, b3, b4 = uint32_to_bytes(b)
	local c1, c2, c3, c4 = uint32_to_bytes(c)
	local d1, d2, d3, d4 = uint32_to_bytes(d)

	return bytes_to_uint32(byte_xor_cache[a1 * 256 + byte_xor_cache[b1 * 256 + byte_xor_cache[c1 * 256 + d1]]], byte_xor_cache[a2 * 256 + byte_xor_cache[b2 * 256 + byte_xor_cache[c2 * 256 + d2]]], byte_xor_cache[a3 * 256 + byte_xor_cache[b3 * 256 + byte_xor_cache[c3 * 256 + d3]]], byte_xor_cache[a4 * 256 + byte_xor_cache[b4 * 256 + byte_xor_cache[c4 * 256 + d4]]])
end

function ops.uint32_ternary(a, b, c)
	local a1, a2, a3, a4 = uint32_to_bytes(a)
	local b1, b2, b3, b4 = uint32_to_bytes(b)
	local c1, c2, c3, c4 = uint32_to_bytes(c)

	return bytes_to_uint32(byte_and_cache[b1 * 256 + a1] + byte_and_cache[c1 * 256 + 255 - a1], byte_and_cache[b2 * 256 + a2] + byte_and_cache[c2 * 256 + 255 - a2], byte_and_cache[b3 * 256 + a3] + byte_and_cache[c3 * 256 + 255 - a3], byte_and_cache[b4 * 256 + a4] + byte_and_cache[c4 * 256 + 255 - a4])
end

function ops.uint32_majority(a, b, c)
	local a1, a2, a3, a4 = uint32_to_bytes(a)
	local b1, b2, b3, b4 = uint32_to_bytes(b)
	local c1, c2, c3, c4 = uint32_to_bytes(c)

	return bytes_to_uint32(byte_and_cache[a1 * 256 + b1] + byte_and_cache[c1 * 256 + byte_xor_cache[a1 * 256 + b1]], byte_and_cache[a2 * 256 + b2] + byte_and_cache[c2 * 256 + byte_xor_cache[a2 * 256 + b2]], byte_and_cache[a3 * 256 + b3] + byte_and_cache[c3 * 256 + byte_xor_cache[a3 * 256 + b3]], byte_and_cache[a4 * 256 + b4] + byte_and_cache[c4 * 256 + byte_xor_cache[a4 * 256 + b4]])
end

return ops
