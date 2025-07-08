local log = require("klua.log"):new("utils")

require("klua.table")

local km = require("klua.macros")
local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local V = require("klua.vector")
local P = require("path_db")
local GS = require("game_settings")

require("constants")

local U = {}

function U.frandom(from, to)
	return math.random() * (to - from) + from
end

function U.random_sign()
	if math.random() < 0.5 then
		return -1
	else
		return 1
	end
end

function U.random_table_idx(list)
	local rn = math.random()
	local acc = 0

	for i = 1, #list do
		if rn <= list[i] + acc then
			return i
		end

		acc = acc + list[i]
	end

	return #list
end

function U.y_ease_keys(store, key_tables, key_names, froms, tos, duration, easings, fn)
	local start_ts = store.tick_ts
	local phase

	easings = easings or {}

	repeat
		local dt = store.tick_ts - start_ts

		phase = km.clamp(0, 1, dt / duration)

		for i, t in ipairs(key_tables) do
			local kn = key_names[i]

			t[kn] = U.ease_value(froms[i], tos[i], phase, easings[i])
		end

		if fn then
			fn(dt, phase)
		end

		coroutine.yield()
	until phase >= 1
end

function U.y_ease_key(store, key_table, key_name, from, to, duration, easing, fn)
	U.y_ease_keys(store, {
		key_table
	}, {
		key_name
	}, {
		from
	}, {
		to
	}, duration, {
		easing
	}, fn)
end

function U.ease_value(from, to, phase, easing)
	return from + (to - from) * U.ease_phase(phase, easing)
end

function U.ease_phase(phase, easing)
	phase = km.clamp(0, 1, phase)
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

function U.hover_pulse_alpha(t)
	local min, max, per = HOVER_PULSE_ALPHA_MIN, HOVER_PULSE_ALPHA_MAX, HOVER_PULSE_PERIOD

	return min + (max - min) * 0.5 * (1 + math.sin(t * km.twopi / per))
end

function U.is_inside_ellipse(p, center, radius, aspect)
	aspect = aspect or 0.7

	local a = radius
	local b = radius * aspect

	return math.pow((p.x - center.x) / a, 2) + math.pow((p.y - center.y) / b, 2) <= 1
end

function U.point_on_ellipse(center, radius, angle, aspect)
	aspect = aspect or 0.7
	angle = angle or 0

	local a = radius
	local b = radius * aspect

	return V.v(center.x + a * math.cos(angle), center.y + b * math.sin(angle))
end

function U.dist_factor_inside_ellipse(p, center, radius, min_radius, aspect)
	aspect = aspect or 0.7

	local vx, vy = p.x - center.x, p.y - center.y
	local angle = V.angleTo(vx, vy)
	local a = radius
	local b = radius * aspect
	local v_len = V.len(vx, vy)
	local ab_len = V.len(a * math.cos(angle), b * math.sin(angle))

	if min_radius then
		local ma, mb = min_radius, min_radius * aspect
		local mab_len = V.len(ma * math.cos(angle), mb * math.sin(angle))

		return km.clamp(0, 1, (v_len - mab_len) / (ab_len - mab_len))
	else
		return km.clamp(0, 1, v_len / ab_len)
	end
end

function U.y_wait(store, time, break_func)
	local start_ts = store.tick_ts

	while time > store.tick_ts - start_ts do
		if break_func and break_func(store, time) then
			return true
		end

		coroutine.yield()
	end

	return false
end

function U.animation_start(entity, name, flip_x, ts, loop, idx, force_ts)
	loop = (loop == -1 or loop == true) and true or false

	local first, last

	if idx then
		first, last = idx, idx
	else
		first, last = 1, #entity.render.sprites
	end

	for i = first, last do
		local a = entity.render.sprites[i]

		if not a.ignore_start then
			local flip_x_i = flip_x

			if flip_x_i == nil then
				flip_x_i = a.flip_x
			end

			a.flip_x = flip_x_i

			if a.animated then
				a.loop = loop or a.loop_forced == true

				if not a.loop or force_ts then
					a.ts = ts
					a.runs = 0
				end

				if name and a.name ~= name then
					a.name = name
				end
			end
		end
	end
end

function U.animation_finished(entity, idx, times)
	idx = idx or 1
	times = times or 1

	local a = entity.render.sprites[idx]

	if a.loop then
		if times == 1 then
			log.debug("waiting fTor looping animation for entity %s - ", entity.id, entity.template_name)
		end

		return times <= a.runs
	else
		return a.runs > 0
	end
end

function U.y_animation_wait(entity, idx, times)
	idx = idx or 1

	while not U.animation_finished(entity, idx, times) do
		coroutine.yield()
	end
end

function U.animation_name_for_angle(e, group, angle, idx)
	idx = idx or 1

	local a = e.render.sprites[idx]
	local angles = a.angles and a.angles[group] or nil

	angle = km.unroll(angle)

	if not angles then
		return group, angle > math.pi / 2 and angle < 3 * math.pi / 2, 1
	elseif #angles == 1 then
		return angles[1], angle > math.pi / 2 and angle < 3 * math.pi / 2, 1
	elseif #angles == 2 then
		local flip_x = angle > math.pi / 2 and angle < 3 * math.pi / 2

		if angle > 0 and angle < math.pi then
			if a.angles_flip_horizontal and a.angles_flip_horizontal[1] then
				flip_x = not flip_x
			end

			return angles[1], flip_x, 1
		else
			if a.angles_flip_horizontal and a.angles_flip_horizontal[2] then
				flip_x = not flip_x
			end

			return angles[2], flip_x, 2
		end
	elseif #angles == 3 then
		local o_name, o_flip, o_idx
		local a1, a2, a3, a4 = 45, 135, 225, 315

		if a.angles_custom and a.angles_custom[group] then
			a1, a2, a3, a4 = unpack(a.angles_custom[group], 1, 4)
		end

		local quadrant = a._last_quadrant
		local stickiness = a.angles_stickiness and a.angles_stickiness[group]

		if stickiness and quadrant then
			local skew = stickiness * ((quadrant == 1 or quadrant == 3) and 1 or -1)

			a1, a3 = a1 - skew, a3 - skew
			a2, a4 = a2 + skew, a4 + skew
		end

		local angle_deg = angle * 180 / math.pi

		if a1 <= angle_deg and angle_deg < a2 then
			o_name, o_flip, o_idx = angles[2], false, 2
			quadrant = 1
		elseif a2 <= angle_deg and angle_deg < a3 then
			o_name, o_flip, o_idx = angles[1], true, 1
			quadrant = 2
		elseif a3 <= angle_deg and angle_deg < a4 then
			o_name, o_flip, o_idx = angles[3], false, 3
			quadrant = 3
		else
			o_name, o_flip, o_idx = angles[1], false, 1
			quadrant = 4
		end

		if stickiness then
			a._last_quadrant = quadrant
		end

		if a.angles_flip_vertical and a.angles_flip_vertical[group] then
			o_flip = angle > math.pi / 2 and angle < 3 * math.pi / 2
		end

		return o_name, o_flip, o_idx
	end
end

function U.animation_name_facing_point(e, group, point, idx, offset, use_path)
	local fx, fy

	if e.nav_path and use_path then
		local npos = P:node_pos(e.nav_path)

		fx, fy = npos.x, npos.y
	else
		fx, fy = e.pos.x, e.pos.y
	end

	if offset then
		fx, fy = fx + offset.x, fy + offset.y
	end

	local vx, vy = V.sub(point.x, point.y, fx, fy)
	local v_angle = V.angleTo(vx, vy)
	local angle = km.unroll(v_angle)

	return U.animation_name_for_angle(e, group, angle, idx)
end

function U.y_animation_play(entity, name, flip_x, ts, times, idx)
	local loop = times and times > 1

	U.animation_start(entity, name, flip_x, ts, loop, idx, true)

	while not U.animation_finished(entity, idx, times) do
		coroutine.yield()
	end
end

function U.animation_start_group(entity, name, flip_x, ts, loop, group)
	if not group then
		U.animation_start(entity, name, flip_x, ts, loop)

		return
	end

	for i = 1, #entity.render.sprites do
		local s = entity.render.sprites[i]

		if s.group == group then
			U.animation_start(entity, name, flip_x, ts, loop, i)
		end
	end
end

function U.animation_finished_group(entity, group, times)
	if not group then
		return U.animation_finished(entity, nil, times)
	end

	for i = 1, #entity.render.sprites do
		local s = entity.render.sprites[i]

		if s.group == group and U.animation_finished(entity, i, times) then
			return true
		end
	end
end

function U.y_animation_play_group(entity, name, flip_x, ts, times, group)
	if not group then
		U.y_animation_play(entity, name, flip_x, ts, times)

		return
	end

	local loop = times and times > 1

	U.animation_start_group(entity, name, flip_x, ts, loop, group)

	local idx

	for i = 1, #entity.render.sprites do
		local s = entity.render.sprites[i]

		if s.group == group then
			idx = i

			break
		end
	end

	if idx then
		while not U.animation_finished(entity, idx, times) do
			coroutine.yield()
		end
	end
end

function U.y_animation_wait_group(entity, group, times)
	if not group then
		U.y_animation_wait(entity, nil, times)

		return
	end

	for i = 1, #entity.render.sprites do
		local s = entity.render.sprites[i]

		if s.group == group then
			U.y_animation_wait(entity, i, times)

			break
		end
	end
end

function U.get_animation_ts(entity, group)
	if not group then
		return entity.render.sprites[1].ts
	else
		for i = 1, #entity.render.sprites do
			local s = entity.render.sprites[i]

			if s.group == group then
				return s.ts
			end
		end
	end
end

function U.sprites_hide(entity, from, to, keep)
	if not entity or not entity.render then
		return
	end

	from = from or 1
	to = to or #entity.render.sprites

	for i = from, to do
		local s = entity.render.sprites[i]

		if keep then
			if s.hidden and s.hidden_count == 0 then
				s.hidden_count = 1
			end

			if not s.hidden and s.hidden_count > 0 then
				s.hidden_count = 0
			end

			s.hidden_count = s.hidden_count + 1
		end

		s.hidden = true
	end
end

function U.sprites_show(entity, from, to, restore)
	if not entity or not entity.render then
		return
	end

	from = from or 1
	to = to or #entity.render.sprites

	for i = from, to do
		local s = entity.render.sprites[i]

		if restore then
			s.hidden_count = math.max(0, s.hidden_count - 1)
			s.hidden = s.hidden_count > 0
		else
			s.hidden_count = 0
			s.hidden = nil
		end
	end
end

function U.set_destination(e, pos)
	e.motion.dest = V.vclone(pos)
	e.motion.arrived = false
end

function U.set_heading(e, dest)
	if e.heading then
		local vx, vy = V.sub(dest.x, dest.y, e.pos.x, e.pos.y)
		local v_angle = V.angleTo(vx, vy)

		e.heading.angle = v_angle
	end
end

function U.walk(e, dt, accel, unsnapped)
	if e.motion.arrived then
		return true
	end

	local m = e.motion
	local pos = e.pos
	local vx, vy = V.sub(m.dest.x, m.dest.y, pos.x, pos.y)
	local v_angle = V.angleTo(vx, vy)
	local v_len = V.len(vx, vy)

	if accel then
		m.max_speed = m.max_speed + accel * dt
	end

	if m.accel and m.speed_limit and m.max_speed < m.speed_limit then
		m.max_speed = km.clamp(0, m.speed_limit, m.max_speed + m.accel * dt)
	end

	local step = m.max_speed * dt
	local nx, ny = V.normalize(V.rotate(v_angle, 1, 0))

	if v_len <= step then
		if unsnapped then
			local sx, sy = V.mul(step, nx, ny)

			pos.x, pos.y = V.add(pos.x, pos.y, sx, sy)
		else
			pos.x, pos.y = m.dest.x, m.dest.y
		end

		m.speed.x, m.speed.y = 0, 0
		m.arrived = true

		return true
	end

	if e.heading then
		e.heading.angle = v_angle
	end

	local sx, sy = V.mul(math.min(step, v_len), nx, ny)

	pos.x, pos.y = V.add(pos.x, pos.y, sx, sy)
	m.speed.x, m.speed.y = sx / dt, sy / dt
	m.arrived = false

	return false
end

function U.force_motion_step(this, dt, dest)
	local fm = this.force_motion
	local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
	local dist = V.len(dx, dy)
	local ramp_radius = fm.ramp_radius
	local df

	if not ramp_radius then
		df = 1
	elseif ramp_radius < dist then
		df = fm.ramp_max_factor
	else
		df = math.max(dist / ramp_radius, fm.ramp_min_factor)
	end

	fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step * df, dx, dy)))
	fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(dt, fm.a.x, fm.a.y))
	fm.v.x, fm.v.y = V.trim(fm.max_v, fm.v.x, fm.v.y)
	this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(dt, fm.v.x, fm.v.y))
	fm.a.x, fm.a.y = V.mul(-1 * fm.fr / dt, fm.v.x, fm.v.y)
end

function U.find_nearest_soldier(entities, origin, min_range, max_range, flags, bans, filter_func)
	local soldiers = U.find_soldiers_in_range(entities, origin, min_range, max_range, flags, bans, filter_func)

	if not soldiers or #soldiers == 0 then
		return nil
	else
		table.sort(soldiers, function(e1, e2)
			return V.dist(e1.pos.x, e1.pos.y, origin.x, origin.y) < V.dist(e2.pos.x, e2.pos.y, origin.x, origin.y)
		end)

		return soldiers[1]
	end
end

function U.find_soldiers_in_range(entities, origin, min_range, max_range, flags, bans, filter_func)
	local soldiers = table.filter(entities, function(k, v)
		return not v.pending_removal and v.soldier and v.vis and v.health and not v.health.dead and band(v.vis.flags, bans) == 0 and band(v.vis.bans, flags) == 0 and U.is_inside_ellipse(v.pos, origin, max_range) and (min_range == 0 or not U.is_inside_ellipse(v.pos, origin, min_range)) and (not filter_func or filter_func(v, origin))
	end)

	if not soldiers or #soldiers == 0 then
		return nil
	else
		return soldiers
	end
end

function U.find_nearest_enemy(entities, origin, min_range, max_range, flags, bans, filter_func)
	local targets = U.find_enemies_in_range(entities, origin, min_range, max_range, flags, bans, filter_func)

	if not targets or #targets == 0 then
		return nil
	else
		table.sort(targets, function(e1, e2)
			return V.dist(e1.pos.x, e1.pos.y, origin.x, origin.y) < V.dist(e2.pos.x, e2.pos.y, origin.x, origin.y)
		end)

		return targets[1], targets
	end
end

function U.find_targets_in_range(entities, origin, min_range, max_range, flags, bans, filter_func)
	local targets = table.filter(entities, function(k, v)
		return not v.pending_removal and v.vis and (v.enemy or v.soldier) and v.health and not v.health.dead and band(v.vis.flags, bans) == 0 and band(v.vis.bans, flags) == 0 and U.is_inside_ellipse(v.pos, origin, max_range) and (not v.nav_path or P:is_node_valid(v.nav_path.pi, v.nav_path.ni)) and (min_range == 0 or not U.is_inside_ellipse(v.pos, origin, min_range)) and (not filter_func or filter_func(v, origin))
	end)

	if not targets or #targets == 0 then
		return nil
	else
		return targets
	end
end

function U.find_first_target(entities, origin, min_range, max_range, flags, bans, filter_func)
	flags = flags or 0
	bans = bans or 0

	for _, v in pairs(entities) do
		if not v.pending_removal and v.health and not v.health.dead and v.vis and band(v.vis.flags, bans) == 0 and band(v.vis.bans, flags) == 0 and U.is_inside_ellipse(v.pos, origin, max_range) and (min_range == 0 or not U.is_inside_ellipse(v.pos, origin, min_range)) and (not filter_func or filter_func(v, origin)) then
			return v
		end
	end

	return nil
end

function U.find_random_target(entities, origin, min_range, max_range, flags, bans, filter_func)
	flags = flags or 0
	bans = bans or 0

	local targets = table.filter(entities, function(k, v)
		return not v.pending_removal and v.health and not v.health.dead and v.vis and band(v.vis.flags, bans) == 0 and band(v.vis.bans, flags) == 0 and U.is_inside_ellipse(v.pos, origin, max_range) and (min_range == 0 or not U.is_inside_ellipse(v.pos, origin, min_range)) and (not filter_func or filter_func(v, origin))
	end)

	if not targets or #targets == 0 then
		return nil, nil
	else
		local idx = math.random(1, #targets)

		return targets[idx], targets
	end
end

function U.find_random_enemy(entities, origin, min_range, max_range, flags, bans, filter_func)
	flags = flags or 0
	bans = bans or 0

	local enemies = table.filter(entities, function(k, v)
		return not v.pending_removal and v.enemy and v.vis and v.nav_path and v.health and not v.health.dead and band(v.vis.flags, bans) == 0 and band(v.vis.bans, flags) == 0 and U.is_inside_ellipse(v.pos, origin, max_range) and P:is_node_valid(v.nav_path.pi, v.nav_path.ni) and (min_range == 0 or not U.is_inside_ellipse(v.pos, origin, min_range)) and (not filter_func or filter_func(v, origin))
	end)

	if not enemies or #enemies == 0 then
		return nil, nil
	else
		local idx = math.random(1, #enemies)

		return enemies[idx], enemies
	end
end

function U.find_enemies_in_range(entities, origin, min_range, max_range, flags, bans, filter_func)
	local enemies = table.filter(entities, function(k, v)
		return not v.pending_removal and v.enemy and v.vis and v.nav_path and v.health and not v.health.dead and band(v.vis.flags, bans) == 0 and band(v.vis.bans, flags) == 0 and U.is_inside_ellipse(v.pos, origin, max_range) and P:is_node_valid(v.nav_path.pi, v.nav_path.ni) and (min_range == 0 or not U.is_inside_ellipse(v.pos, origin, min_range)) and (not filter_func or filter_func(v, origin))
	end)

	if not enemies or #enemies == 0 then
		return nil
	else
		return enemies
	end
end

function U.find_enemies_in_paths(entities, origin, min_node_range, max_node_range, max_path_dist, flags, bans, only_upstream, filter_func)
	max_path_dist = max_path_dist or 30
	flags = flags or 0
	bans = bans or 0

	local result = {}
	local nearest_nodes = P:nearest_nodes(origin.x, origin.y)

	for _, n in pairs(nearest_nodes) do
		local opi, ospi, oni, odist = unpack(n, 1, 4)

		if max_path_dist < odist or not P:is_node_valid(opi, oni) then
			-- block empty
		else
			for _, e in pairs(entities) do
				if not e.pending_removal and e.enemy and e.nav_path and e.health and not e.health.dead and e.nav_path.pi == opi and (only_upstream == true and oni > e.nav_path.ni or only_upstream == false and oni < e.nav_path.ni or only_upstream == nil) and e.vis and band(e.vis.flags, bans) == 0 and band(e.vis.bans, flags) == 0 and min_node_range <= math.abs(e.nav_path.ni - oni) and max_node_range >= math.abs(e.nav_path.ni - oni) and (not filter_func or filter_func(e, origin)) then
					table.insert(result, {
						enemy = e,
						origin = n
					})
				end
			end
		end
	end

	if not result or #result == 0 then
		return nil
	else
		table.sort(result, function(e1, e2)
			local p1 = e1.enemy.nav_path
			local p2 = e2.enemy.nav_path

			return P:nodes_to_goal(p1.pi, p1.spi, p1.ni) < P:nodes_to_goal(p2.pi, p2.spi, p2.ni)
		end)

		return result
	end
end

function U.find_foremost_enemy(entities, origin, min_range, max_range, prediction_time, flags, bans, filter_func, min_override_flags)
	flags = flags or 0
	bans = bans or 0
	min_override_flags = min_override_flags or 0

	local enemies = {}

	for _, e in pairs(entities) do
		if e.pending_removal or not e.enemy or not e.nav_path or not e.vis or e.health and e.health.dead or band(e.vis.flags, bans) ~= 0 or band(e.vis.bans, flags) ~= 0 or filter_func and not filter_func(e, origin) then
			-- block empty
		else
			local e_pos, e_ni

			if prediction_time and e.motion and e.motion.speed and (e.motion.speed.x ~= 0 or e.motion.speed.y ~= 0) then
				if e.motion.forced_waypoint then
					local dt = prediction_time == true and 1 or prediction_time

					e_pos = V.v(e.pos.x + dt * e.motion.speed.x, e.pos.y + dt * e.motion.speed.y)
					e_ni = e.nav_path.ni
				else
					local node_offset = P:predict_enemy_node_advance(e, prediction_time)

					e_ni = e.nav_path.ni + node_offset
					e_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)
				end
			else
				e_pos = e.pos
				e_ni = e.nav_path.ni
			end

			if U.is_inside_ellipse(e_pos, origin, max_range) and P:is_node_valid(e.nav_path.pi, e_ni) and (min_range == 0 or band(e.vis.flags, min_override_flags) ~= 0 or not U.is_inside_ellipse(e_pos, origin, min_range)) then
				e.__ffe_pos = V.vclone(e_pos)

				table.insert(enemies, e)
			end
		end
	end

	if not enemies or #enemies == 0 then
		return nil, nil, nil
	else
		table.sort(enemies, function(e1, e2)
			local p1 = e1.nav_path
			local p2 = e2.nav_path

			return P:nodes_to_goal(p1.pi, p1.spi, p1.ni) < P:nodes_to_goal(p2.pi, p2.spi, p2.ni)
		end)

		return enemies[1], enemies, enemies[1].__ffe_pos
	end
end

function U.find_towers_in_range(entities, origin, attack, filter_func)
	local towers = table.filter(entities, function(k, v)
		return not v.pending_removal and v.tower and not v.tower.blocked and (not attack.excluded_templates or not table.contains(attack.excluded_templates, v.template_name)) and U.is_inside_ellipse(v.pos, origin, attack.max_range) and (attack.min_range == 0 or not U.is_inside_ellipse(v.pos, origin, attack.min_range)) and (not filter_func or filter_func(v, origin, attack))
	end)

	if not towers or #towers == 0 then
		return nil
	else
		return towers
	end
end

function U.find_entity_at_pos(entities, x, y, filter_func)
	local found = {}

	for _, e in pairs(entities) do
		if e.pos and e.ui and e.ui.can_click then
			local r = e.ui.click_rect

			if x > e.pos.x + r.pos.x and x < e.pos.x + r.pos.x + r.size.x and y > e.pos.y + r.pos.y and y < e.pos.y + r.pos.y + r.size.y and (not filter_func or filter_func(e)) then
				table.insert(found, e)
			end
		end
	end

	table.sort(found, function(e1, e2)
		if e1.ui.z == e2.ui.z then
			return e1.pos.y < e2.pos.y
		else
			return e1.ui.z > e2.ui.z
		end
	end)

	if #found > 0 then
		local e = found[1]

		log.paranoid("entity:%s template:%s", e.id, e.template_name)

		return e
	else
		return nil
	end
end

function U.find_paths_with_enemies(entities, flags, bans, filter_func)
	local pis = {}

	for _, e in pairs(entities) do
		if not e.pending_removal and e.enemy and e.nav_path and e.health and not e.health.dead and e.vis and band(e.vis.flags, bans) == 0 and band(e.vis.bans, flags) == 0 and (not filter_func or filter_func(e)) then
			pis[e.nav_path.pi] = true
		end
	end

	local out = {}

	for pi, _ in pairs(pis) do
		table.insert(out, pi)
	end

	if #out < 1 then
		return nil
	else
		return out
	end
end

function U.find_entity_most_surrounded(entities)
	local sorted_entities = {}

	for _, e1 in ipairs(entities) do
		local distance_between_entities = 0

		for _, e2 in ipairs(entities) do
			if e1.id ~= e2.id and e1.health and not e1.health.dead and e2.health and not e2.health.dead and e1.pos and e2.pos then
				local distance = V.dist(e1.pos.x, e1.pos.y, e2.pos.x, e2.pos.y)

				distance_between_entities = distance_between_entities + distance
			end
		end

		table.insert(sorted_entities, {
			entity = e1,
			distance = distance_between_entities
		})
	end

	table.sort(sorted_entities, function(e1, e2)
		return e1.distance < e2.distance
	end)

	local out = {}

	for _, e in ipairs(sorted_entities) do
		table.insert(out, e.entity)
	end

	return out[1], out
end

function U.attack_order(attacks)
	local order = {}

	for i = 1, #attacks do
		local a = attacks[i]

		table.insert(order, {
			id = i,
			chance = a.chance or 1,
			cooldown = a.cooldown
		})
	end

	table.sort(order, function(o1, o2)
		if o1.chance ~= o2.chance then
			return o1.chance < o2.chance
		elseif o1.cooldown and o2.cooldown and o1.cooldown ~= o2.cooldown then
			return o1.cooldown > o2.cooldown
		else
			return o1.id < o2.id
		end
	end)

	local out = {}

	for i = 1, #order do
		out[i] = order[i].id
	end

	return out
end

function U.melee_slot_position(soldier, enemy, rank, back)
	if not rank then
		rank = table.keyforobject(enemy.enemy.blockers, soldier.id)

		if not rank then
			return nil
		end
	end

	local idx = km.zmod(rank, 3)
	local x_off, y_off = 0, 0
	local spread_x = soldier.soldier.melee_slot_spread and soldier.soldier.melee_slot_spread.x or -3
	local spread_y = soldier.soldier.melee_slot_spread and soldier.soldier.melee_slot_spread.y or -6

	if idx == 2 then
		x_off = spread_x
		y_off = spread_y
	elseif idx == 3 then
		x_off = spread_x
		y_off = -1 * spread_y
	end

	local soldier_on_the_right = math.abs(km.signed_unroll(enemy.heading.angle)) < math.pi / 2

	if back then
		soldier_on_the_right = not soldier_on_the_right
	end

	local soldier_pos = V.v(enemy.pos.x + (enemy.enemy.melee_slot.x + x_off + soldier.soldier.melee_slot_offset.x) * (soldier_on_the_right and 1 or -1), enemy.pos.y + enemy.enemy.melee_slot.y + y_off + soldier.soldier.melee_slot_offset.y)

	return soldier_pos, soldier_on_the_right
end

function U.rally_formation_position(idx, barrack, count, angle_offset)
	local pos

	count = count or #barrack.soldiers
	angle_offset = angle_offset or 0

	if count == 1 then
		pos = V.vclone(barrack.rally_pos)
	else
		local a = 2 * math.pi / count

		pos = U.point_on_ellipse(barrack.rally_pos, barrack.rally_radius, (idx - 1) * a - math.pi / 2 + angle_offset)
	end

	local center = V.vclone(barrack.rally_pos)

	return pos, center
end

function U.get_blocker(store, blocked)
	if blocked.enemy and #blocked.enemy.blockers > 0 then
		local blocker_id = blocked.enemy.blockers[1]
		local blocker = store.entities[blocker_id]

		return blocker
	end

	return nil
end

function U.get_blocked(store, blocker)
	local blocked_id = blocker.soldier.target_id
	local blocked = store.entities[blocked_id]

	return blocked
end

function U.blocker_rank(store, blocker)
	local blocked_id = blocker.soldier.target_id
	local blocked = store.entities[blocked_id]

	if blocked then
		return table.keyforobject(blocked.enemy.blockers, blocker.id)
	end

	return nil
end

function U.is_blocked_valid(store, blocker)
	local blocked_id = blocker.soldier.target_id
	local blocked = store.entities[blocked_id]

	return blocked and not blocked.health.dead and (not blocked.vis or bit.band(blocked.vis.bans, F_BLOCK) == 0)
end

function U.unblock_all(store, blocked)
	for _, blocker_id in pairs(blocked.enemy.blockers) do
		local blocker = store.entities[blocker_id]

		if blocker then
			blocker.soldier.target_id = nil
		end
	end

	blocked.enemy.blockers = {}
end

function U.unblock_target(store, blocker)
	local blocked_id = blocker.soldier.target_id
	local blocked = store.entities[blocked_id]

	if blocked then
		table.removeobject(blocked.enemy.blockers, blocker.id)

		if #blocked.enemy.blockers > 1 then
			local last = table.remove(blocked.enemy.blockers)

			table.insert(blocked.enemy.blockers, 1, last)
		end
	end

	blocker.soldier.target_id = nil
end

function U.block_enemy(store, blocker, blocked)
	if blocker.soldier.target_id ~= blocked.id then
		U.unblock_target(store, blocker)
	end

	if not table.keyforobject(blocked.enemy.blockers, blocker.id) then
		table.insert(blocked.enemy.blockers, blocker.id)

		blocker.soldier.target_id = blocked.id
	end
end

function U.replace_blocker(store, old, new)
	local blocked_id = old.soldier.target_id
	local blocked = store.entities[blocked_id]

	if blocked then
		local idx = table.keyforobject(blocked.enemy.blockers, old.id)

		if idx then
			blocked.enemy.blockers[idx] = new.id
			new.soldier.target_id = blocked.id
			old.soldier.target_id = nil
		end
	end
end

function U.cleanup_blockers(store, blocked)
	local blockers = blocked.enemy.blockers

	if not blockers then
		return
	end

	for i = #blockers, 1, -1 do
		local blocker_id = blockers[i]

		if not store.entities[blocker_id] then
			log.debug("cleanup_blockers for (%s) %s removing id %s", blocked.id, blocked.template_name, blocker_id)
			table.remove(blockers, i)
		end
	end
end

function U.predict_damage(entity, damage)
	local e = entity
	local d = damage

	if band(d.damage_type, bor(DAMAGE_INSTAKILL, DAMAGE_EAT)) ~= 0 then
		return entity.health.hp
	end

	local protection

	if band(d.damage_type, DAMAGE_POISON) ~= 0 then
		protection = e.health.poison_armor
	elseif band(d.damage_type, bor(DAMAGE_TRUE, DAMAGE_DISINTEGRATE)) ~= 0 then
		protection = 0
	elseif band(d.damage_type, DAMAGE_PHYSICAL) ~= 0 then
		protection = e.health.armor - d.reduce_armor
	elseif band(d.damage_type, DAMAGE_MAGICAL) ~= 0 then
		protection = e.health.magic_armor - d.reduce_magic_armor
	elseif band(d.damage_type, bor(DAMAGE_EXPLOSION, DAMAGE_ELECTRICAL)) ~= 0 then
		protection = (e.health.armor - d.reduce_armor) / 2
	elseif d.damage_type == DAMAGE_NONE then
		protection = 1
	end

	protection = protection or 0

	local rounded_damage = d.value

	if band(d.damage_type, DAMAGE_MAGICAL) ~= 0 and e.health.damage_factor_magical then
		rounded_damage = km.round(rounded_damage * e.health.damage_factor_magical)
	end

	rounded_damage = km.round(rounded_damage * e.health.damage_factor)

	local actual_damage

	if entity.soldier then
		actual_damage = km.round(rounded_damage - math.floor(rounded_damage * km.clamp(0, 1, protection)))
	else
		actual_damage = math.floor(rounded_damage * km.clamp(0, 1, 1 - protection))
	end

	if band(d.damage_type, DAMAGE_NO_KILL) ~= 0 and e.health and actual_damage >= e.health.hp then
		actual_damage = e.health.hp - 1
	end

	return actual_damage
end

function U.is_seen(store, id)
	return store.seen[id]
end

function U.mark_seen(store, id)
	if not store.seen[id] then
		store.seen[id] = true
		store.seen_dirty = true
	end
end

function U.count_stars(slot)
	local campaign = 0
	local heroic = 0
	local iron = 0
	local heroic_stars = GS.stars_per_mode or 1
	local iron_stars = GS.stars_per_mode or 1

	for i, v in pairs(slot.levels) do
		if i < 80 then
			heroic = heroic + (v[GAME_MODE_HEROIC] and heroic_stars or 0)
			iron = iron + (v[GAME_MODE_IRON] and iron_stars or 0)
			campaign = campaign + (v.stars or 0)
		end
	end

	return campaign + heroic + iron, heroic, iron
end

function U.filter_level_indexes(slot, filter)
	local indexes = {}

	if not slot or not slot.levels or not filter then
		return indexes
	end

	for k, v in pairs(slot.levels) do
		if filter(v) then
			table.insert(indexes, tonumber(k))
		end
	end

	table.sort(indexes, function(v1, v2)
		return tonumber(v1) < tonumber(v2)
	end)

	return indexes
end

function U.find_next_level_in_ranges(ranges, cur)
	local last_range = ranges[#ranges]
	local nex = last_range[#last_range]

	for ri, r in ipairs(ranges) do
		if r.list then
			local idx = table.keyforobject(r, cur)

			if idx then
				if idx < #r then
					nex = r[idx + 1]

					break
				elseif ri < #ranges then
					nex = ranges[ri + 1][1]

					break
				end
			end
		else
			local r1, r2 = unpack(r)

			if r1 == cur or r2 and r1 <= cur and cur < r2 then
				nex = cur + 1

				break
			elseif r2 and cur == r2 and ri < #ranges then
				nex = ranges[ri + 1][1]

				break
			end
		end
	end

	return nex
end

function U.get_dlc_index(dlc)
	for i, v in ipairs(GS.dlc_names) do
		if v.id == dlc then
			return i
		end
	end

	log.error("error finding dlc index! dlc: " .. dlc)
end

function U.get_dlc_level_range(dlc)
	for _, v in pairs(GS.dlc_names) do
		if v.id == dlc then
			local range_idx

			for i, w in ipairs(GS.level_range_names) do
				if v.name == w then
					return GS.level_ranges[i]
				end
			end
		end
	end

	log.error("error finding dlc level range! dlc: " .. dlc)
end

function U.is_dlc_level(level_idx)
	for k, v in pairs(GS.dlc_names) do
		local range = U.get_dlc_level_range(v.id)

		if level_idx >= range[1] and level_idx <= range[2] then
			return true
		end
	end

	return false
end

function U.unlock_next_levels_in_ranges(unlock_data, levels, game_settings, unlocked_dlcs)
	local level_ranges = game_settings.level_ranges
	local level_range_names = game_settings.level_range_names
	local main_campaing_last_level = game_settings.main_campaign_levels
	local expansions_unlock_level = game_settings.expansions_unlock_level or {
		default = main_campaing_last_level
	}
	local dirty = false

	local function sanitize_unlock(idx)
		levels[idx] = {}

		if not unlock_data.new_level then
			unlock_data.new_level = idx
		end

		table.insert(unlock_data.unlocked_levels, idx)

		dirty = true

		log.debug(">>> sanitizing : added level %s", idx)
	end

	for i = 2, #level_ranges do
		local range = level_ranges[i]
		local name = level_range_names and level_range_names[i]
		local u_idx = name and expansions_unlock_level[name] or expansions_unlock_level.default

		if levels[u_idx] and levels[u_idx][GAME_MODE_CAMPAIGN] and not levels[range[1]] then
			levels[range[1]] = {}

			table.insert(unlock_data.unlocked_levels, range[1])

			dirty = true
		end
	end

	if unlocked_dlcs then
		for _, dlc in pairs(unlocked_dlcs) do
			local dlc_first_level = U.get_dlc_level_range(dlc)[1]

			if not levels[dlc_first_level] then
				if not unlock_data.unlocked_levels then
					unlock_data.unlocked_levels = {}
				end

				table.insert(unlock_data.unlocked_levels, dlc_first_level)

				levels[dlc_first_level] = {}
				dirty = true
			end
		end
	end

	for _, range in pairs(level_ranges) do
		if range[2] then
			if range.list then
				local prev

				for i, v in ipairs(range) do
					if prev and levels[prev] and levels[prev][GAME_MODE_CAMPAIGN] and not levels[v] then
						sanitize_unlock(v)

						break
					end

					prev = v
				end
			else
				for i = range[1], range[2] - 1 do
					if levels[i] and levels[i][GAME_MODE_CAMPAIGN] and not levels[i + 1] then
						sanitize_unlock(i + 1)

						break
					end
				end
			end
		end
	end

	return dirty
end

function U.flags_pass(vis, vis_x)
	return band(vis.flags, vis_x.vis_bans) == 0 and band(vis.bans, vis_x.vis_flags) == 0
end

function U.flag_set(value, flag)
	return bor(value, flag)
end

function U.flag_clear(value, flag)
	return band(value, bnot(flag))
end

function U.flag_has(value, flag)
	return band(value, flag) ~= 0
end

local vis_meta = {}

function vis_meta.__index(t, k)
	if k == "bans" then
		return t._bans_stack_value
	end
end

function vis_meta.__newindex(t, k, v)
	if k == "bans" then
		rawset(t, "_bans_stack", nil)
		rawset(t, "_bans_stack_value", nil)
		rawset(t, "bans", v)
	else
		rawset(t, k, v)
	end
end

function U.calc_vis_stack(s)
	local o = 0

	for _, r in pairs(s) do
		local op, flag = unpack(r)

		if op == "set" then
			o = flag
		else
			local fop = bit[op]

			if not fop then
				-- block empty
			else
				o = fop(o, flag)
			end
		end
	end

	return o
end

function U.push_bans(t, value, op)
	if not getmetatable(t) then
		setmetatable(t, vis_meta)
	end

	if not t._bans_stack then
		rawset(t, "_bans_stack", {})
		table.insert(t._bans_stack, {
			"set",
			t.bans
		})
		rawset(t, "bans", nil)
	end

	op = op or "bor"

	if op ~= "set" and not bit[op] then
		if DEBUG then
			assert(false, "error in push_ban: invalid bit op " .. tostring(op) .. " for vis table " .. tostring(t))
		else
			return
		end
	end

	local row = {
		op,
		value
	}

	table.insert(t._bans_stack, row)
	rawset(t, "_bans_stack_value", U.calc_vis_stack(t._bans_stack))

	return row
end

function U.pop_bans(t, ref)
	if not t._bans_stack then
		if DEBUG then
			log.error("error in pop_ban: nil _bans_stack for vis table %s", t)

			return
		else
			return
		end
	end

	if #t._bans_stack <= 1 then
		if DEBUG then
			assert(false, "error in pop_ban: popping with stack size <= 1 for vis " .. tostring(t))
		else
			return
		end
	end

	local ti = table.keyforobject(t._bans_stack, ref)

	if ti ~= nil then
		table.remove(t._bans_stack, ti)

		if #t._bans_stack == 1 then
			rawset(t, "bans", t._bans_stack[1][2])
			rawset(t, "_bans_stack", nil)
			rawset(t, "_bans_stack_value", nil)
		else
			rawset(t, "_bans_stack_value", U.calc_vis_stack(t._bans_stack))
		end
	end
end

function U.get_hero_level(xp, thresholds)
	local level = 1

	while level < 10 and xp >= thresholds[level] do
		level = level + 1
	end

	local phase

	if level > #thresholds then
		phase = 1
	elseif xp == thresholds[level] then
		phase = 0
	else
		local this_xp = thresholds[level - 1] or 0
		local next_xp = thresholds[level]

		phase = (xp - this_xp) / (next_xp - this_xp)
	end

	return level, phase
end

function U.get_modifiers(store, entity, list)
	local mods = table.filter(store.entities, function(k, v)
		return v.modifier and v.modifier.target_id == entity.id and (not list or table.contains(list, v.template_name))
	end)

	return mods
end

function U.has_modifiers(store, entity, mod_name)
	local mods = table.filter(store.entities, function(k, v)
		return v.modifier and v.modifier.target_id == entity.id and (not mod_name or mod_name == v.template_name)
	end)

	return #mods > 0, mods
end

function U.has_modifier_in_list(store, entity, list)
	for _, e in pairs(store.entities) do
		if e.modifier and e.modifier.target_id == entity.id and table.contains(list, e.template_name) then
			return true
		end
	end

	return false
end

function U.has_modifier_types(store, entity, ...)
	local types = {
		...
	}
	local mods = table.filter(store.entities, function(k, v)
		return v.modifier and v.modifier.target_id == entity.id and table.contains(types, v.modifier.type)
	end)

	return #mods > 0, mods
end

function U.balance_format(s, b)
	local function get_value(obj, path)
		local p = {}

		for v in path:gmatch("[^%.%[%]]+") do
			local i = tonumber(v)

			if i then
				table.insert(p, i)
			else
				table.insert(p, v)
			end
		end

		local val = obj

		log.paranoid("values are " .. getfulldump(p))

		for _, v in ipairs(p) do
			val = val[v]

			if not val then
				return nil
			end

			log.paranoid("value part is " .. v)
		end

		return val
	end

	local i, f

	if not s then
		return s
	end

	repeat
		i = string.find(s, "%$")

		if i then
			f = string.find(s, "%$", i + 1)

			if f then
				log.paranoid("index i " .. i .. " end " .. f)

				local p = string.sub(s, i + 1, f - 2)
				local v = get_value(b, p)

				if not v then
					v = ""
				elseif string.sub(s, f + 1, f + 1) == "%" then
					v = v * 100
				end

				s = string.sub(s, 1, i - 2) .. v .. string.sub(s, f + 1)
			end
		end
	until not i or not f

	return s
end

function U.format_countdown_time(rem_time, hour_format)
	local days = math.floor(rem_time / 86400)
	local hours = math.floor(rem_time % 86400 / 3600)
	local minutes = math.floor(rem_time % 3600 / 60)
	local seconds = math.floor(rem_time % 60)
	local text

	if hour_format then
		text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
	elseif days > 0 then
		text = string.format("%d%s %02d%s", days, _("DAYS_ABBREVIATION"), hours, _("HOURS_ABBREVIATION"))
	elseif hours > 0 then
		text = string.format("%d%s %02d%s", hours, _("HOURS_ABBREVIATION"), minutes, _("MINUTES_ABBREVIATION"))
	else
		text = string.format("%02d%s %02d%s", minutes, _("MINUTES_ABBREVIATION"), seconds, _("SECONDS_ABBREVIATION"))
	end

	return text
end

-- customization
function U.random_point_in_ellipse(center, radius, aspect)
	aspect = aspect or 0.7
	radius = radius + 1e-09
	local angle = math.random() * 2 * math.pi
	radius = math.sqrt(math.random()) * radius
	return U.point_on_ellipse(center, radius, angle, aspect)
end

function U.make_table_serializable(t, visited)
	local result = {}
	visited = visited or {}

	if visited[t] then
		return nil
	end
	visited[t] = true

	for k, v in pairs(t) do
		local vtype = type(v)

		if vtype == "string" or vtype == "number" or vtype == "boolean" or v == nil then
			result[k] = v
		elseif vtype == "table" then
			local sub = U.make_table_serializable(v, visited)
			if sub then
				result[k] = sub
			end
		end
	end

	return result
end

--[[makes a shallow copy of an array]]
function U.shallow_copy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

--[[returns sorted array of enemies by curret health. if same health, then by foremost]]
function U.sort_by_strongest_enemy(valid_enemies, origin)
	local sorted_enemies = U.shallow_copy(valid_enemies)
	table.sort(sorted_enemies, function(enemy1, enemy2)
		local hp1 = enemy1.health.hp
		local hp2 = enemy2.health.hp
		--[[if the health of the enemies is the same, then return the distance of the enemies to the origin]]
		if hp1 == hp2 then
			return V.dist(enemy1.pos.x, enemy1.pos.y, origin.x, origin.y) < V.dist(enemy2.pos.x, enemy2.pos.y, origin.x, origin.y)
	  	end
		--[[if the health of the enemies is not the same, then return the enemy with the higher health]]
		return hp1 > hp2
	end)
   
	return sorted_enemies
end

--[[finds the strongest enemy in range, returns the strongest enemy and a sorted list of all enemies by strongest]]
function U.find_strongest_enemy_in_range(entities, origin, min_range, max_range, prediction_time, flags, bans, filter_func, min_override_flags)
	flags = flags or 0
	bans = bans or 0
	min_override_flags = min_override_flags or 0
 
	--[[gets the array of enemies in range, sorted by the distance to the goal]]
	local _, valid_enemies = U.find_foremost_enemy(entities, origin, min_range, max_range, prediction_time, flags, bans, filter_func, min_override_flags)
	--[[if the array enemies doesn't exist, or the number of enemies is 0, then return nil]]
	if not valid_enemies or #valid_enemies == 0 then
		return nil, nil, nil
	end

	--[[returns the first strongest enemy, which makes it so that among equal hp strong enemies, it chooses the one closest to the goal]]
	if(valid_enemies and #valid_enemies > 0) then
		valid_enemies = U.sort_by_strongest_enemy(valid_enemies, origin)
	end

	return valid_enemies[1], valid_enemies, valid_enemies[1].__ffe_pos
end

function U.find_weakest_enemy_in_range(entities, origin, min_range, max_range, prediction_time, flags, bans, filter_func, min_override_flags)
	flags = flags or 0
	bans = bans or 0
	min_override_flags = min_override_flags or 0
 
	local _, valid_enemies = U.find_foremost_enemy(entities, origin, min_range, max_range, prediction_time, flags, bans, filter_func, min_override_flags)
	if not valid_enemies or #valid_enemies == 0 then
		return nil, nil, nil
	end

	if(valid_enemies and #valid_enemies > 0) then
		table.sort(valid_enemies, function(enemy1, enemy2)
			local hp1 = enemy1.health.hp
			local hp2 = enemy2.health.hp
			if hp1 == hp2 then
				return V.dist(enemy1.pos.x, enemy1.pos.y, origin.x, origin.y) < V.dist(enemy2.pos.x, enemy2.pos.y, origin.x, origin.y)
			end
			return hp1 < hp2
		end)
	end
 
	return valid_enemies[1], valid_enemies, valid_enemies[1].__ffe_pos
end

function U.find_farthest_enemy(entities, origin, min_range, max_range, prediction_time, flags, bans, filter_func, min_override_flags)
	flags = flags or 0
	bans = bans or 0
	min_override_flags = min_override_flags or 0

	local enemies = {}

	for _, e in pairs(entities) do
		if e.pending_removal or not e.enemy or not e.nav_path or not e.vis or e.health and e.health.dead or band(e.vis.flags, bans) ~= 0 or band(e.vis.bans, flags) ~= 0 or filter_func and not filter_func(e, origin) then
			-- block empty
		else
			local e_pos, e_ni

			if prediction_time and e.motion and e.motion.speed and (e.motion.speed.x ~= 0 or e.motion.speed.y ~= 0) then
				if e.motion.forced_waypoint then
					local dt = prediction_time == true and 1 or prediction_time

					e_pos = V.v(e.pos.x + dt * e.motion.speed.x, e.pos.y + dt * e.motion.speed.y)
					e_ni = e.nav_path.ni
				else
					local node_offset = P:predict_enemy_node_advance(e, prediction_time)

					e_ni = e.nav_path.ni + node_offset
					e_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)
				end
			else
				e_pos = e.pos
				e_ni = e.nav_path.ni
			end

			if U.is_inside_ellipse(e_pos, origin, max_range) and P:is_node_valid(e.nav_path.pi, e_ni) and (min_range == 0 or band(e.vis.flags, min_override_flags) ~= 0 or not U.is_inside_ellipse(e_pos, origin, min_range)) then
				e.__ffe_pos = V.vclone(e_pos)

				table.insert(enemies, e)
			end
		end
	end

	if not enemies or #enemies == 0 then
		return nil, nil, nil
	else
		table.sort(enemies, function(e1, e2)
			local p1 = e1.nav_path
			local p2 = e2.nav_path

			return P:nodes_to_goal(p1.pi, p1.spi, p1.ni) > P:nodes_to_goal(p2.pi, p2.spi, p2.ni)
		end)

		return enemies[1], enemies, enemies[1].__ffe_pos
	end
end

function U.find_enemy_crowds(entities, origin, min_range, max_range, flags, bans, filter_func, crowd_range, min_targets)
	local enemies = U.find_enemies_in_range(entities, origin, min_range, max_range, flags, bans, filter_func)
	if not enemies then
		return nil
	end
	local crowds = {}
	for i = #enemies, 1, -1 do
		local e = enemies[i]
		local crowd = U.find_enemies_in_range(entities, e.pos, 0, crowd_range, 0, 0)
		if crowd and #crowd >= min_targets then
			local t = {}
			t.center_unit = e
			t.crowd = crowd
			table.insert(crowds, t)
		end
	end
	if #crowds > 0 then
		return crowds
	end
	return nil
end

-- find_max_crowd为true时返回人数最多的，否则返回最接近终点的
function U.find_enemy_crowd(entities, origin, min_range, max_range, flags, bans, filter_func, crowd_range, min_targets, find_max_crowd)
	local crowds = U.find_enemy_crowds(entities, origin, min_range, max_range, flags, bans, filter_func, crowd_range, min_targets)
	if not crowds then
		return nil
	end
	if find_max_crowd then
		table.sort(crowds, function(t1, t2)
			return #t1.crowd > #t2.crowd
		end)
	else
		table.sort(crowds, function(t1, t2)
			local p1 = t1.center_unit.nav_path
			local p2 = t2.center_unit.nav_path
			return P:nodes_to_goal(p1.pi, p1.spi, p1.ni) < P:nodes_to_goal(p2.pi, p2.spi, p2.ni)
		end)
	end
	return crowds[1]
end

U.position_type = {}
-- 返回中心单位的位置
U.position_type.floor = 1
-- 返回中心单位正在前往的节点的位置
U.position_type.node_floor = 2
-- 返回和中心单位正在前往的节点邻近，且位于中间路线上的节点的位置
U.position_type.node_floor_center = 3
-- 返回和中心单位的位置邻近，且位于中间路线上的节点的位置
U.position_type.center = 4
-- 返回平均位置，但更接近中心单位
U.position_type.average = 5
function U.find_enemy_crowd_position(entities, origin, min_range, max_range, flags, bans, filter_func, crowd_range, min_targets, find_max_crowd, position_type, valid_only)
	local t = U.find_enemy_crowd(entities, origin, min_range, max_range, flags, bans, filter_func, crowd_range, min_targets, find_max_crowd)
	if not t then
		return nil, nil
	end
	local p = t.center_unit.nav_path
	if valid_only and not P:is_node_valid(p.pi, p.ni) then
		return nil, nil
	end
	local pos = nil
	if not position_type or position_type == U.position_type.floor then
		pos = V.vclone(t.center_unit.pos)
	elseif position_type == U.position_type.node_floor then
		pos = P:node_pos(p.pi, p.spi, p.ni)
	elseif position_type == U.position_type.node_floor_center then
		pos = P:node_pos(p.pi, 1, p.ni)
	elseif position_type == U.position_type.center then
		local path_indexes = { p.pi }
		local subpath_indexes = { 1 }
		local nearest = P:nearest_nodes(t.center_unit.pos.x, t.center_unit.pos.y, path_indexes, subpath_indexes, valid_only)
		if #nearest > 0 then
			local pi, spi, ni = unpack(nearest[1])
			return P:node_pos(pi, spi, ni), t
		end
	elseif position_type == U.position_type.average then
		-- 使位置更靠近中心单位
		local x, y = t.center_unit.pos.x, t.center_unit.pos.y
		for i, e in ipairs(t.crowd) do
			x, y = x + e.pos.x, y + e.pos.y
		end
		x, y = x / (#t.crowd + 1), y / (#t.crowd + 1)
		pos = V.v(x, y)
	end
	if not pos then
		pos = V.vclone(t.center_unit.pos)
	end
	return pos, t
end

function U.get_prediction_offset(entity, prediction_time)
	local offset = {}
	if prediction_time and entity.motion and entity.motion.speed and (entity.motion.speed.x ~= 0 or entity.motion.speed.y ~= 0) then
		if not entity.nav_path or entity.motion.forced_waypoint then
			local dt = prediction_time == true and 1 or prediction_time
			offset.x, offset.y, offset.node = dt * entity.motion.speed.x, dt * entity.motion.speed.y, 0
		else
			local node_offset = P:predict_enemy_node_advance(entity, prediction_time)
			offset.node = node_offset
			local ni = entity.nav_path.ni + node_offset
			local node_pos = P:node_pos(entity.nav_path.pi, entity.nav_path.spi, ni)
			offset.x, offset.y = node_pos.x - entity.pos.x, node_pos.y - entity.pos.y
		end
	end
	if not offset.x then
		offset.x, offset.y, offset.node = 0, 0, 0
	end
	return offset
end

function U.find_soldier_crowds(entities, origin, min_range, max_range, flags, bans, filter_func, crowd_range, min_targets)
	local soldiers = U.find_soldiers_in_range(entities, origin, min_range, max_range, flags, bans, filter_func)
	if not soldiers then
		return nil
	end
	local crowds = {}
	for i = #soldiers, 1, -1 do
		local e = soldiers[i]
		local crowd = U.find_soldiers_in_range(entities, e.pos, 0, crowd_range, 0, 0)
		if crowd and #crowd >= min_targets then
			local t = {}
			t.center_unit = e
			t.crowd = crowd
			table.insert(crowds, t)
		end
	end
	if #crowds > 0 then
		return crowds
	end
	return nil
end

-- find_max_crowd为true时返回人数最多的，否则返回最接近的
function U.find_soldier_crowd(entities, origin, min_range, max_range, flags, bans, filter_func, crowd_range, min_targets, find_max_crowd)
	local crowds = U.find_soldier_crowds(entities, origin, min_range, max_range, flags, bans, filter_func, crowd_range, min_targets)
	if not crowds then
		return nil
	end
	if find_max_crowd then
		table.sort(crowds, function(t1, t2)
			return #t1.crowd > #t2.crowd
		end)
	else
		table.sort(crowds, function(t1, t2)
			local e1 = t1.center_unit
			local e2 = t2.center_unit
			return V.dist2(e1.pos.x, e1.pos.y, origin.x, origin.y) < V.dist2(e2.pos.x, e2.pos.y, origin.x, origin.y)
		end)
	end
	return crowds[1]
end

function U.find_soldier_crowd_position(entities, origin, min_range, max_range, flags, bans, filter_func, crowd_range, min_targets, find_max_crowd, position_type, valid_only)
	local t = U.find_soldier_crowd(entities, origin, min_range, max_range, flags, bans, filter_func, crowd_range, min_targets, find_max_crowd)
	if not t then
		return nil, nil
	end
	local pos = nil
	if not position_type or position_type == U.position_type.floor then
		pos = V.vclone(t.center_unit.pos)
	elseif position_type == U.position_type.center then
		local subpath_indexes = { 1 }
		local nearest = P:nearest_nodes(t.center_unit.pos.x, t.center_unit.pos.y, nil, subpath_indexes, valid_only)
		if #nearest > 0 then
			local pi, spi, ni = unpack(nearest[1])
			return P:node_pos(pi, spi, ni), t
		end
	elseif position_type == U.position_type.average then
		-- 使位置更靠近中心单位
		local x, y = t.center_unit.pos.x, t.center_unit.pos.y
		for i, e in ipairs(t.crowd) do
			x, y = x + e.pos.x, y + e.pos.y
		end
		x, y = x / (#t.crowd + 1), y / (#t.crowd + 1)
		pos = V.v(x, y)
	end
	if not pos then
		pos = V.vclone(t.center_unit.pos)
	end
	return pos, t
end

U.search_type = {
	normal = 1,
	random = 2,
	max_health = 3,
	min_health = 4,
	close_to_exit = 5,
	far_from_exit = 6,
	find_max_crowd = 7,
}

function U.find_enemy_with_search_type(entities, origin, min_range, max_range, prediction_time, flags, bans, filter_func, min_override_flags, search_type, crowd_range, min_targets)
	flags = flags or 0
	bans = bans or 0
	min_override_flags = min_override_flags or 0

	if search_type == U.search_type.normal then
		local enemy, enemies = U.find_nearest_enemy(entities, origin, min_range, max_range, flags, bans, filter_func)
		if not enemy then
			return nil, nil, nil
		end
		local offset = U.get_prediction_offset(enemy, prediction_time)
		enemy.__ffe_pos = V.v(enemy.pos.x + offset.x, enemy.pos.y + offset.y)
		return enemy, enemies, enemy.__ffe_pos
	elseif search_type == U.search_type.random then
		local enemy, enemies = U.find_random_enemy(entities, origin, min_range, max_range, flags, bans, filter_func)
		if not enemy then
			return nil, nil, nil
		end
		local offset = U.get_prediction_offset(enemy, prediction_time)
		enemy.__ffe_pos = V.v(enemy.pos.x + offset.x, enemy.pos.y + offset.y)
		return enemy, enemies, enemy.__ffe_pos
	elseif search_type == U.search_type.max_health then
		return U.find_strongest_enemy_in_range(entities, origin, min_range, max_range, prediction_time, flags, bans, filter_func, min_override_flags)
	elseif search_type == U.search_type.min_health then
		return U.find_weakest_enemy_in_range(entities, origin, min_range, max_range, prediction_time, flags, bans, filter_func, min_override_flags)
	elseif search_type == U.search_type.close_to_exit then
		return U.find_foremost_enemy(entities, origin, min_range, max_range, prediction_time, flags, bans, filter_func, min_override_flags)
	elseif search_type == U.search_type.far_from_exit then
		return U.find_farthest_enemy(entities, origin, min_range, max_range, prediction_time, flags, bans, filter_func, min_override_flags)
	elseif search_type == U.search_type.find_max_crowd then
		local crowd = U.find_enemy_crowd(entities, origin, min_range, max_range, flags, bans, filter_func, crowd_range or 60, min_targets or 1, true)
		if crowd then
			local enemy = crowd.center_unit
			local offset = U.get_prediction_offset(enemy, prediction_time)
			enemy.__ffe_pos = V.v(enemy.pos.x + offset.x, enemy.pos.y + offset.y)
			return enemy, crowd.crowd, enemy.__ffe_pos
		else
			return nil, nil, nil
		end
	end
	return U.find_foremost_enemy(entities, origin, min_range, max_range, prediction_time, flags, bans, filter_func, min_override_flags)
end

return U