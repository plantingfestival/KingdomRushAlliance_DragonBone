-- chunkname: @./lib/klua/macros.lua

local fmod = math.fmod
local pi = math.pi
local twopi = 2 * pi
local pi_2 = pi / 2
local pi_4 = pi / 4

local function UNROLL(a)
	return a % twopi
end

local function UNROLL_DEG(a)
	return a % 360
end

local function SIGNED_UNROLL(a)
	return fmod(a, twopi)
end

local function SIGNED_UNROLL_DEG(a)
	return fmod(a, 360)
end

local function SHORT_ANGLE(from, to)
	local diff = UNROLL(to - from)

	if diff == twopi then
		return 0
	elseif diff <= pi then
		return diff
	else
		return fmod(diff, pi) - pi
	end
end

local function SHORT_ANGLE_DEG(from, to)
	local diff = UNROLL_DEG(to - from)

	if diff == 360 then
		return 0
	elseif diff <= 180 then
		return diff
	else
		return fmod(diff, 180) - 180
	end
end

local function CLAMP_SIGNED(min, max, v)
	return v < min and min or max < v and max or v
end

local function CLAMP(a, b, v)
	if a < b then
		return CLAMP_SIGNED(a, b, v)
	else
		return CLAMP_SIGNED(b, a, v)
	end
end

local function ZMOD(value, module)
	return (value - 1) % module + 1
end

local function ROUND(value)
	return math.floor(value + 0.5)
end

local function SIGN(value)
	if value < 0 then
		return -1
	else
		return 1
	end
end

local function RAND_SIGN(prob_positive)
	prob_positive = prob_positive or 0.5

	return prob_positive <= math.random() and 1 or -1
end

local function RAND_UNIQ(qty, from, to)
	local t = {}

	for i = from, to do
		table.insert(t, i)
	end

	local o = {}
	local max_qty = math.min(qty, #t)

	for j = 1, max_qty do
		local i = math.random(1, #t)

		table.insert(o, table.remove(t, i))
	end

	return o
end

local function DEG2RAD(deg)
	return deg * pi / 180
end

local function RAD2DEG(rad)
	return rad * 180 / pi
end

local function EASE_PHASE(phase, easing)
	phase = CLAMP(0, 1, phase)
	easing = easing or ""

	local function rotate_fn(f)
		return function(s, ...)
			return 1 - f(1 - s, ...)
		end
	end

	local easing_functions = {
		linear = function(s)
			return s
		end,
		quad = function(s)
			return s * s
		end,
		cubic = function(s)
			return s * s * s
		end,
		quart = function(s)
			return s * s * s * s
		end,
		quint = function(s)
			return s * s * s * s * s
		end,
		sine = function(s)
			return 1 - math.cos(s * math.pi / 2)
		end,
		expo = function(s)
			return 2^(10 * (s - 1))
		end,
		circ = function(s)
			return 1 - math.sqrt(1 - s * s)
		end
	}
	local fn_name, first_ease = string.match(easing, "([^-]+)%-([^-]+)")
	local fn = easing_functions[fn_name]

	fn = fn or easing_functions.linear

	if first_ease == "outin" then
		if phase <= 0.5 then
			return fn(phase * 2) / 2
		else
			return 0.5 + rotate_fn(fn)((phase - 0.5) * 2) / 2
		end
	elseif first_ease == "inout" then
		if phase <= 0.5 then
			return rotate_fn(fn)(phase * 2) / 2
		else
			return 0.5 + fn((phase - 0.5) * 2) / 2
		end
	elseif first_ease == "in" then
		return rotate_fn(fn)(phase)
	else
		return fn(phase)
	end
end

local function EASE_VALUE(from, to, phase, easing)
	return from + (to - from) * EASE_PHASE(phase, easing)
end

return {
	twopi = twopi,
	pi = pi,
	pi_2 = pi_2,
	pi_4 = pi_4,
	unroll = UNROLL,
	unroll_deg = UNROLL_DEG,
	signed_unroll = SIGNED_UNROLL,
	signed_unroll_deg = SIGNED_UNROLL_DEG,
	short_angle = SHORT_ANGLE,
	short_angle_deg = SHORT_ANGLE_DEG,
	clamp_signed = CLAMP_SIGNED,
	clamp = CLAMP,
	zmod = ZMOD,
	round = ROUND,
	sign = SIGN,
	rand_sign = RAND_SIGN,
	rand_uniq = RAND_UNIQ,
	deg2rad = DEG2RAD,
	rad2deg = RAD2DEG,
	ease_phase = EASE_PHASE,
	ease_value = EASE_VALUE
}
