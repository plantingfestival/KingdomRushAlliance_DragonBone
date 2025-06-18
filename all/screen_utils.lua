-- chunkname: @./all/screen_utils.lua

local log = require("klua.log"):new("screen_utils")
local V = require("klua.vector")

require("constants")

local SFO = require("safe_frame_override")
local SU = {}

function SU.clamp_window_aspect(w, h, ref_w, ref_h, min_aspect, max_aspect)
	min_aspect = min_aspect or MIN_SCREEN_ASPECT
	max_aspect = max_aspect or MAX_SCREEN_ASPECT

	local sw, sh, scale
	local origin = V.v(0, 0)

	if min_aspect > w / h then
		sw = ref_h * min_aspect
		sh = ref_h
		scale = w / sw
		origin.y = (h - sh * scale) / 2
	else
		sw = ref_h * (w / h)
		sh = ref_h
		scale = h / ref_h

		if max_aspect < sw / sh then
			sw = sh * max_aspect
			origin.x = (w - sw * scale) / 2
		end
	end

	return sw, sh, scale, origin
end

function SU.remove_references(screen, klass)
	for k, v in pairs(screen) do
		if v and type(v) == "table" and v.isInstanceOf and v:isInstanceOf(klass) then
			screen[k] = nil
		end
	end
end

function SU.get_device_safe_frame(factor, game, target, platform, os, device)
	local sf_dev

	if target == "phone" and platform == "android" then
		local jnia = require("all.jni_android")
		local sa = jnia.get_system_property("SAFE_AREA")

		if sa and sa ~= "" then
			local r, t, l, b = unpack(string.split(sa, ","))

			sf_dev = {
				r,
				t,
				l,
				b
			}
		end
	elseif platform == "ios" then
		local ffi = require("ffi")

		ffi.cdef(" size_t kr_get_device_safe_frame(char* buf, size_t bufSize); ")

		local buf_max_size = 1024
		local buffer = ffi.new("char[?]", buf_max_size)
		local buffer_length = ffi.C.kr_get_device_safe_frame(buffer, buf_max_size)
		local s = ffi.string(buffer, buffer_length)

		if s and s ~= "" then
			local r, t, l, b = unpack(string.split(s, ","))

			sf_dev = {
				r,
				t,
				l,
				b
			}
		end
	end

	if not sf_dev then
		return nil
	end

	local symmetrical_h = true
	local symmetrical_v = false

	if target == "phone" and platform == "android" then
		symmetrical_v = true
	end

	if symmetrical_h then
		sf_dev[1] = math.max(sf_dev[1], sf_dev[3])
		sf_dev[3] = math.max(sf_dev[1], sf_dev[3])
	end

	if symmetrical_v then
		sf_dev[2] = math.max(sf_dev[2], sf_dev[4])
		sf_dev[4] = math.max(sf_dev[2], sf_dev[4])
	end

	if factor then
		for i = 1, 12 do
			if sf_dev[i] then
				sf_dev[i] = sf_dev[i] * factor
			end
		end
	end

	local r, t, l, b = sf_dev[1], sf_dev[2], sf_dev[3], sf_dev[4]

	sf_dev[5], sf_dev[6], sf_dev[7], sf_dev[8] = sf_dev[5] or r, sf_dev[6] or l, sf_dev[7] or l, sf_dev[8] or r
	sf_dev[9], sf_dev[10], sf_dev[11], sf_dev[12] = sf_dev[9] or t, sf_dev[10] or t, sf_dev[11] or b, sf_dev[12] or b

	local ov = SFO:get_override(game, target, platform, os, device)

	if ov and ov.safe_frame then
		log.debug("MATCHED OVERRIDE FRAME: %s,%s,%s,%s : %s", game, target, platform, device, getdump(ov.safe_frame))

		for i = 1, 12 do
			sf_dev[i] = ov.safe_frame[i] ~= nil and ov.safe_frame[i] or sf_dev[i]
		end
	elseif ov and ov.safe_factors then
		log.debug("MATCHED OVERRIDE FACTORS: %s,%s,%s,%s : %s", game, target, platform, device, getdump(ov.safe_factors))

		for i = 1, 12 do
			sf_dev[i] = ov.safe_factors[i] ~= nil and sf_dev[i] ~= nil and ov.safe_factors[i] * sf_dev[i] or sf_dev[i]
		end
	end

	return sf_dev
end

function SU.get_safe_frame(w, h, ref_w, ref_h)
	local r, t, l, b, rt, lt, lb, rb, tr, tl, bl, br = 0, 0, 0, 0
	local device_safe_frame = SU.get_device_safe_frame(ref_h / h, KR_GAME, KR_TARGET, KR_PLATFORM, KR_OS, KR_DEVICE_MODEL)

	if main.params.safe_frame then
		log.debug("manual safe frame passed at init.")

		r, t, l, b, rt, lt, lb, rb, tr, tl, bl, br = unpack(main.params.safe_frame)

		local lr = math.max(l, r)
		local tb = math.max(t, b)

		rt, lt, lb, rb = rt or lr, lt or lr, lb or lr, rb or lr
		tr, tl, bl, br = tr or t, tl or t, bl or b, br or b

		local f = ref_h / h

		r, t, l, b = lr * f, tb * f, lr * f, tb * f
		rt, lt, lb, rb = lr * f, lr * f, lr * f, lr * f
		tr, tl, bl, br = tb * f, tb * f, tb * f, tb * f
	elseif device_safe_frame then
		log.debug("using device safe frame overrides")

		local dsf = device_safe_frame

		r, t, l, b = dsf[1], dsf[2], dsf[3], dsf[4]
		rt, lt, lb, rb = dsf[5] or r, dsf[6] or l, dsf[7] or l, dsf[8] or r
		tr, tl, bl, br = dsf[9] or t, dsf[10] or t, dsf[11] or b, dsf[12] or b
	else
		log.debug("falling back to SAFE_FRAME_DEFAULTS")

		local a = w / h
		local ca = 0
		local sf

		for k, v in pairs(SAFE_FRAME_DEFAULTS) do
			if k <= a and ca <= k then
				ca = k
				sf = v
			end
		end

		r, t, l, b = sf.r, sf.t, sf.l, sf.b
		rt, lt, lb, rb = sf.r, sf.l, sf.l, sf.r
		tr, tl, bl, br = sf.t, sf.t, sf.b, sf.b
	end

	if IS_KR5 then
		local factor = ref_h / h
		local min_margin_horizontal = 20 * factor

		r = math.max(r, min_margin_horizontal)
		l = math.max(l, min_margin_horizontal)
		rt = math.max(rt, min_margin_horizontal)
		rb = math.max(rb, min_margin_horizontal)
		lt = math.max(lt, min_margin_horizontal)
		lb = math.max(lb, min_margin_horizontal)

		local min_top = 28 * factor

		t = math.max(t, min_top)
		tl = math.max(tl, min_top)
		tr = math.max(tr, min_top)

		local min_bottom = 18 * factor

		b = math.max(b, min_bottom)
		bl = math.max(bl, min_bottom)
		br = math.max(br, min_bottom)
	end

	local safe = {
		r = r,
		t = t,
		l = l,
		b = b,
		rt = rt,
		lt = lt,
		lb = lb,
		rb = rb,
		tr = tr,
		tl = tl,
		bl = bl,
		br = br
	}

	return safe
end

function SU.get_hud_scale(w, h, ref_w, ref_h)
	if IS_TRILOGY then
		local a = w / h

		for _, v in pairs(HUD_SCALE_STEPS) do
			if a >= v[1] then
				return v[2]
			end
		end

		return HUD_SCALE_STEPS[#HUD_SCALE_STEPS][2]
	else
		return 1
	end
end

function SU.get_default_base_scale(sw, sh, fit_aspect)
	local fitted = 0.75

	if sw and sh then
		fit_aspect = fit_aspect or 1.7777777777777777
		fitted = sw / fit_aspect / REF_H
	end

	local bs = OVtargets(1, 1, fitted, 0.55, 0.65)

	return V.vv(bs)
end

function SU.apply_base_scale(views, base_scale, force)
	for _, v in pairs(views) do
		if force then
			v.base_scale = table.deepclone(base_scale)
		else
			local cbs = v.base_scale

			if cbs and cbs.x == 1 and cbs.y == 1 then
				cbs.x = base_scale.x
				cbs.y = base_scale.y
			end
		end
	end
end

function SU.factor_base_scale_list(list, factors, aspect)
	local function mul(v, f)
		if type(v) == "table" then
			return V.v(v.x * f, v.y * f)
		else
			return v * f
		end
	end

	local o = {}

	for k, v in pairs(list) do
		local f = 1

		if factors[k] then
			local ca = 0

			for ka, kv in pairs(factors[k]) do
				if ca <= ka and ka <= aspect then
					f = kv
					ca = ka
				end
			end
		end

		o[k] = mul(v, f)
	end

	return o
end

function SU.new_screen_ctx(screen)
	local s = screen
	local ctx = {
		OV = OV,
		OVT = OVT,
		OVP = OVP,
		OVO = OVO,
		OVt = OVtargets,
		default_base_scale = SU.get_default_base_scale(screen.sw, screen.sh),
		sw = screen.sw,
		sh = screen.sh,
		game = KR_GAME,
		target = KR_TARGET,
		platform = KR_PLATFORM,
		is_mobile = KR_TARGET == OV_PHONE or KR_TARGET == OV_TABLET,
		safe_frame = SU.get_safe_frame(s.w, s.h, s.ref_w, s.ref_h),
		shader_scale = screen.h / screen.sh
	}

	return ctx
end

return SU
