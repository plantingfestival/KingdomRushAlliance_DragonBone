-- chunkname: @./lib/klove/input_state_machine.lua

local log = require("klua.log"):new("ism")
local J = love.joystick
local V = require("klua.vector")
local IS_PHONE = KR_TARGET == "phone"
local IS_PHONE_OR_TABLET = KR_TARGET == "phone" or KR_TARGET == "tablet"
local IS_CONSOLE = KR_TARGET == "console"
local IS_TABLET = KR_TARGET == "tablet"
local ism = {}

ism.default_key_mappings = nil
ism.default_prop_values = {
	joy_rate_limit_delay_repeat = 0.15,
	joy_y_axis_factor = -1,
	joy_rate_limit_delay = 0.4,
	joy_pointer_speed = 650,
	joy_pointer_threshold = 0.1,
	joy_pointer_accel = 2,
	joy_pointer_accel_max = 3,
	nav_key_step = 10,
	joy_pointer_accel_timeout = 0.2,
	nav_key_step_alt = 100,
	joy_pointer_power = 3
}
ism.prop_value_ranges = {
	joy_pointer_speed = {
		400,
		1200
	},
	joy_pointer_power = {
		1,
		6
	},
	joy_pointer_threshold = {
		0.05,
		0.8
	},
	joy_pointer_accel = {
		1,
		5
	},
	joy_pointer_accel_max = {
		1,
		5
	},
	joy_rate_limit_delay = {
		0.1,
		1
	},
	joy_rate_limit_delay_repeat = {
		0.01,
		0.5
	}
}

function ism:init(data, window, default_key_mappings, settings)
	log.debug("init data:%s, window:%s", data, window)

	if not default_key_mappings then
		log.error("ERROR intializing input_state_machine. default_key_mappings missing")

		return
	end

	self.default_key_mappings = default_key_mappings

	local wi, wc = window.size, window.scale

	self.j_active_axes = {
		leftxy = {
			"leftx",
			"lefty"
		},
		rightxy = {
			"rightx",
			"righty"
		}
	}
	self.j_pointer_pos = V.v(wi.x * wc.x / 2, wi.y * wc.y / 2)
	self.j_pointer_active = false

	if IS_PHONE or IS_TABLET then
		self.last_input = I_TOUCH
	elseif IS_CONSOLE then
		self.last_input = I_GAMEPAD
	else
		self.last_input = I_KEYBOARD
	end

	self:reset_prop_values()

	if settings then
		for k, v in pairs(self.default_prop_values) do
			if settings[k] then
				self:set_prop(k, settings[k])
			end
		end
	end

	self.key_mappings = {}

	if settings then
		for k, v in pairs(settings) do
			if string.starts(k, "key_") then
				self.key_mappings[v] = self.default_key_mappings[k]
			end
		end
	end

	if not self.j_counters then
		self.j_counters = {}
	end

	self.data = data
	self.window = window
end

function ism:destroy(window)
	if self.window == window then
		log.debug("destroy window:%s", window)

		self.data = nil
		self.window = nil
	end
end

function ism:reset_prop_values()
	for k, v in pairs(self.default_prop_values) do
		self:set_prop(k, v)
	end
end

local function tlerp(t, x)
	return t[1] + x * t[2] - t[1]
end

local function tlerpi(t, v)
	return (v - t[1]) / (t[2] - t[1])
end

function ism:get_prop(name, is_range)
	if not self[name] then
		log.error("could not find prop named %s", name)

		return nil
	end

	return self[name]
end

function ism:set_prop(name, value)
	self[name] = value
end

function ism:get_prop_range(name)
	if self.prop_value_ranges[name] then
		return self.prop_value_ranges[name]
	else
		return {
			0,
			1
		}
	end
end

function ism:new_j_counters()
	return {
		j_rate_limit_last_count = 0,
		j_axes_released_ts = love.timer.getTime(),
		j_rate_limit_ts = love.timer.getTime()
	}
end

function ism:joystickadded(joystick)
	log.debug("joystick added:%s", joystick)

	if not self.j_counters then
		self.j_counters = {}
	end

	self.j_counters[joystick] = self:new_j_counters()
end

function ism:joystickremoved(joystick)
	log.debug("joystick removed:%s", joystick)
end

function ism:update(dt, state)
	if not self.data then
		return false
	end

	for i, j in ipairs(J.getJoysticks()) do
		if not ism.j_counters[j] then
			ism.j_counters[j] = self:new_j_counters()
		end

		self:proc_axes(state, j)
	end

	if self:has_mouse() then
		local x, y = self.window:get_mouse_position()

		if self.last_mouse_x ~= x or self.last_mouse_y ~= y then
			self:set_last_input(I_MOUSE)

			self.j_pointer_active = false
			self.last_mouse_x = x
			self.last_mouse_y = y
			self.j_pointer_pos.x, self.j_pointer_pos.y = x, y
		end
	end
end

function ism:set_last_input(t)
	if self.last_input ~= t then
		self.last_input = t

		self:update_mouse_pointer_visibility()
	end
end

function ism:needs_focus_image()
	return self.last_input == I_GAMEPAD or self.last_input == I_KEYBOARD
end

function ism:has_mouse()
	return self.window and self.window:has_mouse()
end

function ism:force_hide_mouse_pointer(value)
	self.is_mouse_pointer_hidden = value

	self:update_mouse_pointer_visibility()
end

function ism:update_mouse_pointer_visibility()
	local t = self.last_input

	if self.is_mouse_pointer_hidden or t == I_GAMEPAD or t == I_TOUCH then
		love.mouse.setVisible(false)
	else
		love.mouse.setVisible(true)
	end
end

function ism:proc_key(state, key, isrepeat)
	if not self.data then
		return false
	end

	key = self.key_mappings[key] or key
	self.j_pointer_active = true

	local ctx = {}

	ctx.from_keys = true
	ctx.key = key
	ctx.isrepeat = isrepeat
	ctx.key_shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	ctx.key_ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")

	for _, row in pairs(self:get_sm_rows(state, key)) do
		if self:proc_sm_row(row, ctx) then
			return true
		end
	end
end

function ism:proc_click(state, button, x, y)
	if not self.data then
		return false
	end

	self.j_pointer_active = false

	local ctx = {}

	ctx.from_mouse = true
	ctx.button = "click" .. button
	ctx.x, ctx.y = x, y

	for _, row in pairs(self:get_sm_rows(state, ctx.button)) do
		if self:proc_sm_row(row, ctx) then
			return true
		end
	end
end

function ism:proc_button(state, joystick, button)
	if not self.data then
		return false
	end

	self.j_pointer_active = true

	love.mouse.setPosition(0, 0)

	local jbutton = "j" .. button
	local ctx = {}

	ctx.from_gamepad = true
	ctx.joystick = joystick
	ctx.button = jbutton
	ctx.isrepeat = isrepeat

	for _, row in pairs(self:get_sm_rows(state, jbutton)) do
		if self:proc_sm_row(row, ctx) then
			return true
		end
	end
end

function ism:proc_axes(state, joystick)
	if not self.data then
		return false
	end

	for ak, av in pairs(self.j_active_axes) do
		local aname = "j" .. ak

		for _, row in pairs(self:get_sm_rows(state, aname)) do
			local value = {}
			local over_th

			for _, an in pairs(av) do
				local v = joystick:getGamepadAxis(an)

				table.insert(value, v)

				over_th = over_th or math.abs(v) > self.joy_pointer_threshold
			end

			if over_th then
				self.j_pointer_active = true

				love.mouse.setPosition(0, 0)

				local ctx = {}

				ctx.from_gamepad = true
				ctx.joystick = joystick
				ctx.axis = aname
				ctx.axis_value = value
				ctx.counters = ism.j_counters and ism.j_counters[joystick]

				if self:proc_sm_row(row, ctx) then
					return true
				end
			else
				local c = ism.j_counters and ism.j_counters[joystick]

				if c then
					c.j_rate_limit_ts = 0
					c.j_axes_released_ts = love.timer.getTime()
				end
			end
		end
	end
end

function ism:proc_touch(state, event, id, x, y)
	if not self.data then
		return false
	end

	self.j_pointer_active = true

	local ctx = {}

	ctx.from_gamepad = false
	ctx.state = state
	ctx.event = event
	ctx.x, ctx.y = x, y

	for _, row in pairs(self:get_sm_rows(state, event)) do
		if self:proc_sm_row(row, ctx) then
			return true
		end
	end
end

local _empty_list = {}

function ism:proc_sm_row(row, ctx)
	ctx.dt = love.timer.getDelta()
	ctx.from_alias = row.from_alias

	local evnt, c_fn, c_arg, cmd_fn, cmd_fn_arg = unpack(row)

	c_arg = c_arg or _empty_list
	cmd_fn_arg = cmd_fn_arg or _empty_list

	if c_fn == true or type(c_fn) == "function" and c_fn(ctx, unpack(c_arg)) then
		if type(cmd_fn) == "function" then
			cmd_fn(ctx, unpack(cmd_fn_arg))
		end

		return true
	else
		return false
	end
end

function ism:get_sm_rows(state, event)
	local sm = self.data
	local rows = {}

	for i, mode in ipairs({
		"FIRST",
		"STATE",
		"LAST"
	}) do
		local smm
		local mode_key = mode == "STATE" and state or mode

		::label_24_0::

		smm = sm[mode_key]

		if smm and type(smm) == "string" then
			mode_key = smm

			goto label_24_0
		end

		if smm then
			local erows = table.filter(smm, function(k, v)
				return v[1] == event
			end)

			for _, row in pairs(erows) do
				if type(row[2]) == "string" then
					local arows = table.filter(smm, function(k, v)
						return v[1] == row[2]
					end)

					for _, arow in pairs(arows) do
						arow.from_alias = true

						table.insert(rows, arow)
					end
				else
					row.from_alias = nil

					table.insert(rows, row)
				end
			end

			local stop = table.filter(smm, function(k, v)
				return v[1] == "STOP"
			end)

			if #stop > 0 then
				return rows
			end
		end
	end

	return rows
end

function ism.get_dir_name(vx, vy)
	if vx >= math.abs(vy) then
		return "right"
	elseif vx <= -1 * math.abs(vy) then
		return "left"
	elseif vy >= math.abs(vx) then
		return "up"
	elseif vy <= -1 * math.abs(vx) then
		return "down"
	end
end

function ism.get_dir_idx(vx, vy)
	if vx >= math.abs(vy) then
		return 1
	elseif vx <= -1 * math.abs(vy) then
		return 3
	elseif vy >= math.abs(vx) then
		return 2
	elseif vy <= -1 * math.abs(vx) then
		return 4
	end
end

function ism.get_dir_step(name)
	local vx, vy = 0, 0

	if name == "right" then
		return 1, 0
	elseif name == "left" then
		return -1, 0
	elseif name == "up" then
		return 0, -1
	elseif name == "down" then
		return 0, 1
	end

	return vx, vy
end

function ism.q_is_view_visible(ctx, view)
	if not ism.window then
		return false
	end

	if not view then
		return false
	end

	local v

	if type(view) == "string" then
		v = ism.window:get_child_by_id(view)

		if not v then
			log.info("view with id %s could not be found in window", view)

			return false
		end
	else
		v = view
	end

	return not v.hidden
end

function ism.q_is_escape_show_quit()
	return IS_MOBILE and KR_PLATFORM == "android"
end

function ism.q_rate_limit(ctx, delay, delay_repeat)
	delay = delay or ism.joy_rate_limit_delay
	delay_repeat = delay_repeat or ism.joy_rate_limit_delay_repeat

	local c = ctx.counters

	if not c then
		log.error("ctx.counter is missing")

		return true
	end

	if love.timer.getTime() - c.j_rate_limit_ts > 1.1 * delay then
		c.j_rate_limit_last_dir = nil
		c.j_rate_limit_last_count = 0
	end

	if ctx.axis_value then
		local vx, vy = ctx.axis_value[1], ctx.axis_value[2] * ism.joy_y_axis_factor
		local cdir = ism.get_dir_name(vx, vy)
		local ldir = c.j_rate_limit_last_dir
		local lcount = c.j_rate_limit_last_count

		if ldir == nil then
			c.j_rate_limit_last_dir = cdir
		elseif ldir == cdir then
			if lcount > 1 then
				delay = delay_repeat
			end
		else
			c.j_rate_limit_last_dir = nil
			c.j_rate_limit_last_count = 0
		end
	end

	if delay < love.timer.getTime() - c.j_rate_limit_ts then
		c.j_rate_limit_ts = love.timer.getTime()
		c.j_rate_limit_last_count = c.j_rate_limit_last_count + 1

		return true
	end
end

function ism.q_not_from_alias(ctx)
	return not ctx.from_alias
end

function ism.c_hide_view(ctx, view)
	if not ism.window then
		return false
	end

	if not view then
		return false
	end

	local v

	if type(view) == "string" then
		v = ism.window:get_child_by_id(view)

		if not v then
			log.info("view with id %s could not be found in window", view)
		end
	else
		v = view
	end

	v:hide()

	return true
end

function ism.c_show_view(ctx, view, ...)
	if not ism.window then
		return false
	end

	if not view then
		return false
	end

	local v

	if type(view) == "string" then
		v = ism.window:get_child_by_id(view)

		if not v then
			log.info("view with id %s could not be found in window", view)
		end
	else
		v = view
	end

	v:show(...)

	return true
end

function ism.c_send_key(ctx, key)
	if not ism.window then
		return false
	end

	key = key or ctx.key

	return ism.window:keypressed(key, ctx.isrepeat)
end

function ism.c_send_key_axis(ctx, key)
	if ctx.axis_value then
		local vx, vy = ctx.axis_value[1], ctx.axis_value[2] * ism.joy_y_axis_factor
		local jdir = ism.get_dir_name(vx, vy)

		return ism.c_send_key(ctx, jdir)
	end
end

function ism.c_call_view_fn(ctx, view, fn_name, ...)
	if not ism.window then
		return false
	end

	if not view then
		return false
	end

	if type(view) == "string" then
		v = ism.window:get_child_by_id(view)

		if not v then
			log.info("view with id %s could not be found in window", view)
		end
	else
		v = view
	end

	local fn = v[fn_name]

	if not fn then
		log.error("could not find function %s in %s", fn_name, view)

		return false
	end

	fn(v, ...)

	return true
end

return ism
