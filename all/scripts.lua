local log = require("klua.log"):new("scripts")

require("klua.table")

local km = require("klua.macros")
local signal = require("hump.signal")
local AC = require("achievements")
local E = require("entity_db")
local GR = require("grid_db")
local GS = require("game_settings")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local LU = require("level_utils")
local UP = require("upgrades")
local V = require("klua.vector")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot

require("i18n")

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

local function queue_damage(store, damage)
	table.insert(store.damage_queue, damage)
end

local function fts(v)
	return v / FPS
end

local IS_KR1 = KR_GAME == "kr1"
local IS_KR2 = KR_GAME == "kr2"
local IS_KR3 = KR_GAME == "kr3" or KR_GAME == "kr5"
local IS_KR5 = KR_GAME == "kr5"

local function tpos(e)
	return e.tower and e.tower.range_offset and V.v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or e.pos
end

local scripts = {}

scripts.sequence = {}

function scripts.sequence.update(this, store, script)
	local function insert_fx(name)
		local fx = E:create_entity(name)

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	local s = this.sequence

	if s.fxs[0] then
		insert_fx(s.fxs[0])
	end

	::label_6_0::

	for i = 1, #s.steps do
		local fx = s.fxs[i]

		if fx then
			insert_fx(fx)
		end

		local step = s.steps[i]

		if type(step) == "number" then
			U.y_wait(store, step)
		elseif type(step) == "string" then
			U.y_animation_play(this, step, nil, store.tick_ts, 1, this.sequence.sprite_id)
		else
			log.error("id:%s - unknown step type for %s", this.id, step)
		end
	end

	if this.sequence.loop then
		goto label_6_0
	end

	if s.fxs[#s.steps + 1] then
		insert_fx(s.fxs[#s.steps + 1])
	end

	queue_remove(store, this)
end

scripts.delayed_sequence = {}

function scripts.delayed_sequence.update(this, store, script)
	local s = this.render.sprites[1]
	local d = this.delayed_sequence
	local current_idx = 0

	while true do
		U.y_wait(store, math.random(d.min_delay, d.max_delay))

		s.hidden = nil

		if d.random then
			current_idx = math.random(1, #d.animations)
		else
			current_idx = km.zmod(current_idx + 1, #d.animations)
		end

		local a = d.animations[current_idx]

		U.y_animation_play(this, a, nil, store.tick_ts)
	end
end

scripts.delayed_play = {}

function scripts.delayed_play.update(this, store, script)
	local s = this.render.sprites[1]
	local d = this.delayed_play
	local clicks = 0

	if math.random() < d.flip_chance then
		s.flip_x = not s.flip_x
	end

	if d.idle_animation then
		U.animation_start(this, d.idle_animation, nil, store.tick_ts, d.loop_idle)
	else
		s.hidden = true
	end

	d.delay = U.frandom(d.min_delay, d.max_delay)

	while true do
		if not d.disabled and this.ui and d.required_clicks then
			if this.ui.clicked then
				this.ui.clicked = nil
				clicks = clicks + 1

				if clicks < d.required_clicks then
					S:queue(d.click_sound)
				end

				if d.click_tweens and this.tween then
					this.tween.props[1].ts = store.tick_ts
					this.tween.disabled = false
				end
			end

			if clicks == d.required_clicks then
				if not d.idle_animation then
					s.hidden = false
				end

				S:queue(d.clicked_sound)

				if d.required_clicks_fx then
					SU.insert_sprite(store, d.required_clicks_fx, this.pos)
				end

				if d.required_clicks_hides then
					s.hidden = true
				elseif d.clicked_animation then
					U.y_animation_play(this, d.clicked_animation, nil, store.tick_ts, 1)
				end

				if d.achievement then
					AC:got(d.achievement)
				end

				if d.achievement_flag then
					AC:flag_check(unpack(d.achievement_flag))
				end

				if d.achievement_inc then
					AC:inc_check(d.achievement_inc)
				end

				if d.play_once then
					queue_remove(store, this)

					return
				end

				if not d.idle_animation then
					s.hidden = true
				else
					U.animation_start(this, d.idle_animation, nil, store.tick_ts, d.loop_play)
				end

				clicks = 0
				this.ui.clicked = nil
			end
		end

		if store.tick_ts - s.ts > d.delay then
			s.ts = store.tick_ts

			if d.disabled then
				-- block empty
			else
				if not d.idle_animation then
					s.hidden = false
				end

				if math.random() < d.flip_chance then
					s.flip_x = not s.flip_x
				end

				if d.play_animation then
					if d.play_sound then
						S:queue(d.play_sound)
					end

					if d.play_duration then
						U.animation_start(this, d.play_animation, nil, store.tick_ts, true)

						if U.y_wait(store, d.play_duration, function()
							return d.click_interrupts and this.ui.clicked
						end) then
							goto label_9_0
						end
					else
						U.animation_start(this, d.play_animation, nil, store.tick_ts, false)

						while not U.animation_finished(this) do
							if d.click_interrupts and this.ui.clicked then
								goto label_9_0
							end

							coroutine.yield()
						end
					end
				end

				if not d.idle_animation then
					s.hidden = true
				else
					U.animation_start(this, d.idle_animation, nil, store.tick_ts, d.loop_idle)
				end

				if this.ui and not d.click_interrupts then
					this.ui.clicked = nil
				end
			end
		end

		::label_9_0::

		coroutine.yield()
	end
end

scripts.click_play = {}

function scripts.click_play.update(this, store, script)
	local s = this.render.sprites[1]
	local c = this.click_play
	local clicks = 0

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			clicks = clicks + 1
		end

		if clicks >= c.required_clicks then
			if this.tween then
				this.tween.disabled = false
			elseif not c.idle_animation then
				s.hidden = false
			end

			S:queue(c.clicked_sound)
			U.y_animation_play(this, c.click_animation, nil, store.tick_ts, 1)

			this.ui.clicked = nil
			clicks = 0

			if not c.idle_animation or c.play_once then
				s.hidden = true
			else
				U.animation_start(this, c.idle_animation, nil, store.tick_ts, true)
			end

			if c.achievement then
				AC:got(c.achievement)
			end

			if c.achievement_flag then
				AC:flag_check(unpack(c.achievement_flag))
			end

			if c.play_once then
				queue_remove(store, this)

				return
			end
		end

		coroutine.yield()
	end
end

scripts.click_run_tween = {}

function scripts.click_run_tween.update(this, store)
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.tween.disabled = false
			this.tween.ts = store.tick_ts
			this.ui.can_click = false
		end

		coroutine.yield()
	end
end

scripts.click_pause = {}

function scripts.click_pause.update(this, store)
	local start_ts = store.tick_ts
	local pause_ts
	local s = this.render.sprites[1]

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil

			if pause_ts then
				start_ts = store.tick_ts - (pause_ts - start_ts)
				pause_ts = nil
			else
				pause_ts = store.tick_ts
			end
		end

		if pause_ts then
			s.ts = store.tick_ts - (pause_ts - start_ts)
		end

		coroutine.yield()
	end
end

scripts.clickable_hover_controller = {}

function scripts.clickable_hover_controller.insert(this, store)
	local sh = this.render.sprites[1]
	local t = this.target

	if not t then
		return false
	end

	if t.render then
		local st = t.render.sprites[1]

		if IS_TRILOGY then
			sh.name = t.ui and t.ui.hover_sprite_name or st.name .. "_over_console"
		else
			sh.name = t.ui and t.ui.hover_sprite_name or "default"
		end

		sh.offset = st.offset
		sh.scale = st.scale and V.vclone(st.scale)
		sh.flip_x = st.flip_x
	elseif t.ui and t.ui.hover_sprite_name then
		if IS_TRILOGY then
			sh.name = t.ui and t.ui.hover_sprite_name or st.name .. "_over_console"
		else
			sh.name = t.ui and t.ui.hover_sprite_name or "default"
		end
	else
		return false
	end

	this.pos = t.pos
	sh.ts = store.tick_ts

	if t.ui and t.ui.hover_sprite_anchor then
		sh.anchor = t.ui.hover_sprite_anchor
	end

	if t.ui and t.ui.hover_sprite_scale then
		sh.scale = t.ui.hover_sprite_scale
	end

	if t.ui and t.ui.hover_sprite_offset then
		sh.offset = t.ui.hover_sprite_offset
	end

	if t.ui then
		t.ui.hover_controller_active = true
	end

	return true
end

function scripts.clickable_hover_controller.update(this, store)
	local t = this.target

	while true do
		if this.done or not t or not store.entities[t.id] then
			break
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

function scripts.clickable_hover_controller.remove(this, store)
	local t = this.target

	if t and t.ui then
		t.ui.hover_controller_active = nil
	end

	return true
end

scripts.entity_marker_controller = {}

function scripts.entity_marker_controller.insert(this, store)
	this.markers = {}

	local function insert_marker(e)
		local suf

		if e.soldier then
			if IS_TRILOGY then
				suf = "soldier_small"
			elseif e.hero then
				if not e.unit.size or e.unit.size == UNIT_SIZE_SMALL then
					suf = "hero_small"
				elseif e.unit.size == UNIT_SIZE_MEDIUM then
					suf = "hero_med"
				elseif e.unit.size == UNIT_SIZE_LARGE then
					suf = "hero_big"
				end
			elseif not e.unit.size or e.unit.size == UNIT_SIZE_SMALL then
				suf = "soldier_small"
			elseif e.unit.size == UNIT_SIZE_MEDIUM then
				suf = "soldier_med"
			elseif e.unit.size == UNIT_SIZE_LARGE then
				suf = "soldier_big"
			end
		elseif e.enemy then
			if e.unit.size == UNIT_SIZE_SMALL then
				suf = "small"
			elseif e.unit.size == UNIT_SIZE_MEDIUM then
				suf = "med"
			elseif e.unit.size == UNIT_SIZE_LARGE then
				suf = "big"
			end
		end

		local m = E:create_entity("decal_entity_marker_" .. suf)

		m.target = e
		m.pos = e.pos
		m.render.sprites[1].offset = e.unit.marker_offset

		queue_insert(store, m)
		table.insert(this.markers, m)
	end

	local t = this.target

	if t.barrack then
		for _, s in pairs(t.barrack.soldiers) do
			if s and s.unit and not s.render.sprites[1].hidden then
				insert_marker(s)
			end
		end
	else
		local suf

		insert_marker(t)
	end

	return true
end

function scripts.entity_marker_controller.update(this, store)
	while true do
		if this.done or #this.markers == 0 then
			break
		end

		for i = #this.markers, 1, -1 do
			local m = this.markers[i]
			local t = m.target

			if not t or not store.entities[t.id] or t.ui and not t.ui.can_select or t.health and t.health.dead and not t.health.ignore_damage then
				queue_remove(store, m)
				table.remove(this.markers, i)
			end
		end

		coroutine.yield()
	end

	for _, m in pairs(this.markers) do
		queue_remove(store, m)
	end

	queue_remove(store, this)
end

scripts.fx_coin_shower = {}

function scripts.fx_coin_shower.update(this, store)
	for i = 1, this.coin_count do
		local tween_time = U.frandom(this.coin_tween_time[1], this.coin_tween_time[2])
		local tween_x = U.frandom(this.coin_tween_x_offset[1], this.coin_tween_x_offset[2]) * km.rand_sign()
		local fx = E:create_entity(this.coin_fx)

		fx.render.sprites[1].flip_x = math.random() < 0.5
		fx.render.sprites[1].ts = store.tick_ts
		fx.tween.props[2] = E:clone_c("tween_prop")
		fx.tween.props[2].name = "offset"
		fx.tween.props[2].keys = {
			{
				0,
				V.v(0, 0)
			},
			{
				tween_time,
				V.v(tween_x, 0)
			}
		}
		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y

		queue_insert(store, fx)
		U.y_wait(store, this.coin_delay)
	end

	queue_remove(store, this)
end

scripts.decal_path_marching_ant = {}

function scripts.decal_path_marching_ant.insert(this, store)
	this.render.sprites[1].alpha = 0
	this.pos = P:node_pos(this.nav_path)

	return true
end

function scripts.decal_path_marching_ant.update(this, store)
	this.tween.disabled = nil
	this.tween.ts = store.tick_ts
	this.done = nil

	while true do
		local next_pos, new = P:next_entity_node(this, store.tick_length)

		if not next_pos then
			queue_remove(store, this)

			return
		end

		if this.owner.done and not this.done then
			this.done = true
			this.tween.reverse = true
			this.tween.remove = true
			this.tween.ts = store.tick_ts
		end

		U.set_destination(this, next_pos)
		U.walk(this, store.tick_length)

		this.render.sprites[1].r = this.heading.angle

		coroutine.yield()

		this.motion.speed.x, this.motion.speed.y = 0, 0
	end
end

scripts.path_marching_ants_controller = {}

function scripts.path_marching_ants_controller.update(this, store)
	local function insert_ant(pi, ni)
		local e = E:create_entity(this.ant_template)

		e.nav_path.pi = pi
		e.nav_path.spi = 1
		e.nav_path.ni = ni
		e.owner = this

		queue_insert(store, e)
	end

	local path_pis = P:get_connected_paths(this.pi)
	local ni_reminder = 0

	for _, pi in pairs(path_pis) do
		ni_reminder = 0

		local sni = P:get_start_node(pi)

		sni = sni + ni_reminder

		local eni = P:get_end_node(pi)
		local last_ni = 0

		for ii = sni, eni, this.skip_nodes do
			insert_ant(pi, ii)

			last_ni = ii
		end

		ni_reminder = km.zmod(last_ni - sni, this.skip_nodes)
	end

	local start_node = P:get_start_node(this.pi)
	local ant_speed = E:get_template(this.ant_template).motion.max_speed
	local ant_dist = P.average_node_dist * this.skip_nodes

	while not this.done do
		U.y_wait(store, ant_dist / ant_speed)

		path_pis = P:get_connected_paths(this.pi)

		for _, pi in pairs(path_pis) do
			local sni = P:get_start_node(pi)

			insert_ant(pi, sni)
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.enemy_basic = {}

function scripts.enemy_basic.get_info(this)
	local min, max, attacks

	if this.melee and this.melee.attacks then
		for _, a in pairs(this.melee.attacks) do
			if a.damage_min then
				min, max = a.damage_min, a.damage_max

				break
			end
		end

		if this.unit and min then
			min, max = min * this.unit.damage_factor, max * this.unit.damage_factor
		end
	elseif this.ranged and this.ranged.attacks then
		for _, a in pairs(this.ranged.attacks) do
			if a.bullet then
				local b = E:get_template(a.bullet)

				if b and b.bullet.damage_min and b.bullet.damage_max then
					min, max = b.bullet.damage_min, b.bullet.damage_max

					break
				end
			end
		end
	end

	if min and max then
		min, max = math.ceil(min), math.ceil(max)
	end

	local armor = band(this.health.immune_to, DAMAGE_PHYSICAL) ~= 0 and 1 or this.health.armor
	local magic_armor = band(this.health.immune_to, DAMAGE_MAGICAL) ~= 0 and 1 or this.health.magic_armor

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_icon = this.info.damage_icon,
		armor = armor,
		magic_armor = magic_armor,
		lives = this.enemy and this.enemy.lives_cost or this._original_enemy and this._original_enemy.lives_cost,
		immune = this.health.immune_to == DAMAGE_ALL_TYPES
	}
end

function scripts.enemy_basic.insert(this, store, script)
	local next, new = P:next_entity_node(this, store.tick_length)

	if not next then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)

		return false
	end

	U.set_destination(this, next)
	U.set_heading(this, next)

	if not this.pos or this.pos.x == 0 and this.pos.y == 0 then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end

	if this.render then
		for _, s in pairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end

	if this.melee then
		this.melee.order = U.attack_order(this.melee.attacks)

		for _, a in pairs(this.melee.attacks) do
			a.ts = store.tick_ts
		end
	end

	if this.ranged then
		this.ranged.order = U.attack_order(this.ranged.attacks)

		for _, a in pairs(this.ranged.attacks) do
			a.ts = store.tick_ts
		end
	end

	if this.auras then
		for _, a in pairs(this.auras.list) do
			a.ts = store.tick_ts

			if a.cooldown == 0 then
				local e = E:create_entity(a.name)

				e.pos = V.vclone(this.pos)
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts

				queue_insert(store, e)
			end
		end
	end

	this.enemy.gold_bag = math.ceil(this.enemy.gold * 1.0)

	if this.water and this.spawn_data and this.spawn_data.water_ignore_pi then
		this.water.ignore_pi = this.spawn_data.water_ignore_pi
	end

	return true
end

function scripts.enemy_basic.remove(this, store, script)
	return true
end

scripts.enemy_passive = {}

function scripts.enemy_passive.update(this, store, script)
	local terrain_type

	if this.render.sprites[1].name == "raise" then
		local next_pos

		if this.motion.forced_waypoint then
			next_pos = this.motion.forced_waypoint
		else
			next_pos = P:next_entity_node(this, store.tick_length)
		end

		local an, af = U.animation_name_facing_point(this, "raise", next_pos)

		U.y_animation_play(this, an, af, store.tick_ts, 1)
	end

	while true do
		if this.cliff then
			terrain_type = SU.enemy_cliff_change(store, this)
		end

		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			SU.y_enemy_walk_until_blocked(store, this)
		end
	end
end

scripts.enemy_mixed = {}

function scripts.enemy_mixed.update(this, store, script)
	if this.render.sprites[1].name == "raise" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise, this.sound_events.raise_args)
		end

		this.health_bar.hidden = true

		local an, af = U.animation_name_facing_point(this, "raise", this.motion.dest)

		U.y_animation_play(this, an, af, store.tick_ts, 1)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	::label_29_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_29_0
					end
					
					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_29_0
						end

						coroutine.yield()
					end
				elseif ranged then
					while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							goto label_29_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_mixed_water = {}

function scripts.enemy_mixed_water.update(this, store, script)
	local terrain_type
	local water_trail = E:create_entity("ps_water_trail")

	water_trail.particle_system.track_id = this.id

	queue_insert(store, water_trail)

	::label_30_0::

	while true do
		if this.water then
			terrain_type = SU.enemy_water_change(store, this)
		end

		if this.health.dead then
			SU.y_enemy_death(store, this)

			water_trail.particle_system.emit = false

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local ignore_soldiers = terrain_type == TERRAIN_WATER

			water_trail.particle_system.emit = ignore_soldiers

			local ok, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, ignore_soldiers)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_30_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_30_0
						end

						coroutine.yield()
					end
				elseif ranged then
					while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							goto label_30_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_mixed_cliff = {}

function scripts.enemy_mixed_cliff.update(this, store, script)
	local terrain_type

	::label_31_0::

	while true do
		if this.cliff then
			terrain_type = SU.enemy_cliff_change(store, this)
		end

		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local ignore_soldiers = terrain_type == TERRAIN_CLIFF
			local ok, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, ignore_soldiers)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_31_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_31_0
						end

						coroutine.yield()
					end
				elseif ranged then
					while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							goto label_31_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemies_spawner = {}

function scripts.enemies_spawner.update(this, store, script)
	local sp = this.spawner
	local last_subpath = 0
	local cg

	if sp.count_group_type then
		cg = store.count_groups[sp.count_group_type]
	end

	if not sp.pi then
		local nodes = P:nearest_nodes(this.pos.x, this.pos.y)

		if #nodes < 1 then
			log.error("could not find nodes near spawner:%s at %s,%s", this.pos.x, this.pos.y)
			queue_remove(store, this)

			return
		end

		sp.pi, sp.spi, sp.ni = unpack(nodes[1])
	end

	if sp.animation_start then
		U.y_animation_play(this, sp.animation_start, nil, store.tick_ts, 1)
	end

	if sp.animation_concurrent then
		U.animation_start(this, sp.animation_concurrent, nil, store.tick_ts)
	end

	if sp.animation_loop then
		U.animation_start(this, sp.animation_loop, nil, store.tick_ts, true)
	end

	for i = 1, sp.count do
		if sp.interrupt then
			break
		end

		if sp.owner_id and (not store.entities[sp.owner_id] or store.entities[sp.owner_id].health.dead) then
			break
		end

		if cg and cg[sp.count_group_name] and cg[sp.count_group_name] >= sp.count_group_max then
			break
		end

		local e_pi = sp.pi
		local e_spi = sp.spi
		local e_ni = sp.ni

		if sp.allowed_subpaths then
			if sp.random_subpath then
				e_spi = sp.allowed_subpaths[math.random(1, #sp.allowed_subpaths)]
			else
				last_subpath = km.zmod(last_subpath + 1, #sp.allowed_subpaths)
				e_spi = sp.allowed_subpaths[last_subpath]
			end
		end

		if sp.random_node_offset_range then
			e_ni = sp.ni + math.random(unpack(sp.random_node_offset_range))
		else
			e_ni = sp.ni + sp.node_offset
		end

		if sp.check_node_valid and not P:is_node_valid(e_pi, e_ni) then
			-- block empty
		else
			local spawn = E:create_entity(sp.entity)

			spawn.nav_path.pi = e_pi
			spawn.nav_path.spi = e_spi
			spawn.nav_path.ni = e_ni

			if sp.use_node_pos then
				local npos = P:node_pos(e_pi, e_spi, e_ni)

				spawn.pos.x, spawn.pos.y = npos.x, npos.y
			else
				spawn.pos.x, spawn.pos.y = this.pos.x, this.pos.y + sp.pos_offset.y
			end

			if sp.forced_waypoint_offset then
				spawn.motion.forced_waypoint = V.v(this.pos.x + sp.forced_waypoint_offset.x, this.pos.y + sp.forced_waypoint_offset.y)
			end

			spawn.render.sprites[1].name = sp.initial_spawn_animation

			if spawn.unit then
				spawn.unit.spawner_id = this.id
			end

			if spawn.enemy and not sp.keep_gold then
				spawn.enemy.gold = 0
			end

			if sp.count_group_name then
				E:add_comps(spawn, "count_group")

				spawn.count_group.name = sp.count_group_name
				spawn.count_group.type = sp.count_group_type
			end

			queue_insert(store, spawn)
			S:queue(sp.spawn_sound, sp.spawn_sound_args)

			local wait_time = sp.random_cycle and U.frandom(unpack(sp.random_cycle)) or sp.cycle_time

			U.y_wait(store, wait_time, function()
				return sp.interrupt
			end)
		end
	end

	if sp.animation_end then
		U.y_animation_play(this, sp.animation_end, nil, store.tick_ts, 1)
		queue_remove(store, this)
	elseif this.tween then
		U.animation_start(this, "idle", nil, store.tick_ts)

		this.tween.disabled = false
		this.tween.remove = true
	else
		queue_remove(store, this)
	end
end

scripts.delayed_spawn = {}

function scripts.delayed_spawn.insert(this, store)
	this.payload = E:create_entity(this.entity)

	if not this.payload then
		log.error("delayed_spawn: could not find entity named %s", this.entity)

		return false
	end

	if this.render then
		for i = 1, #this.render.sprites do
			local s = this.render.sprites[i]

			s.ts = store.tick_ts

			if s.size_names then
				s.name = s.size_names[this.payload.unit.size]
			end
		end
	end

	return true
end

function scripts.delayed_spawn.update(this, store)
	U.y_wait(store, this.delay)

	local e = this.payload

	e.nav_path = table.deepclone(this.nav_path)
	e.pos = V.vclone(this.pos)

	if this.motion then
		e.motion.forced_waypoint = this.motion.forced_waypoint
	end

	queue_insert(store, e)
	U.y_animation_wait(this)
	queue_remove(store, this)
end

scripts.soldier_reinforcement = {}

function scripts.soldier_reinforcement.get_info(this)
	local attacks

	if this.melee and this.melee.attacks then
		attacks = this.melee.attacks
	elseif this.ranged and this.ranged.attacks then
		attacks = this.ranged.attacks
	end

	local min, max

	for _, a in pairs(attacks) do
		if a.damage_min then
			min, max = a.damage_min, a.damage_max

			break
		end
	end

	if this.unit and min then
		min, max = min * this.unit.damage_factor, max * this.unit.damage_factor
	end

	if min and max then
		min, max = math.ceil(min), math.ceil(max)
	end

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_icon = this.info.damage_icon,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor
	}
end

function scripts.soldier_reinforcement.insert(this, store, script)
	if this.melee then
		this.melee.order = U.attack_order(this.melee.attacks)
	end

	if this.ranged then
		this.ranged.order = U.attack_order(this.ranged.attacks)
	end

	if this.info and this.info.random_name_format then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end

	return true
end

function scripts.soldier_reinforcement.update(this, store, script)
	local brk, stam, star

	this.reinforcement.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts

	if this.reinforcement.fade or this.reinforcement.fade_in then
		SU.y_reinforcement_fade_in(store, this)
	elseif this.render.sprites[1].name == "raise" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise)
		end

		this.health_bar.hidden = true

		U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	while true do
		if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			this.health.hp = 0

			if IS_KR5 then
				SU.remove_modifiers(store, this)
			end

			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			SU.soldier_courage_upgrade(store, this)

			if this.melee then
				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
					goto label_38_1
				end
			end

			if this.ranged then
				brk, star = SU.y_soldier_ranged_attacks(store, this)

				if brk or star == A_DONE then
					goto label_38_1
				elseif star == A_IN_COOLDOWN then
					goto label_38_0
				end
			end

			if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
				goto label_38_1
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_38_1
			end

			::label_38_0::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_38_1::

		coroutine.yield()
	end
end

scripts.soldier_mercenary = {}

function scripts.soldier_mercenary.get_info(this)
	local t = scripts.soldier_barrack.get_info(this)

	t.respawn = nil

	return t
end

scripts.soldier_barrack = {}

function scripts.soldier_barrack.get_info(this)
	local attacks

	if this.melee and this.melee.attacks then
		attacks = this.melee.attacks
	elseif this.ranged and this.ranged.attacks then
		attacks = this.ranged.attacks
	end

	local min, max

	for _, a in pairs(attacks) do
		if a.damage_min then
			min, max = a.damage_min, a.damage_max

			break
		end
	end

	if this.unit and min then
		min, max = min * this.unit.damage_factor, max * this.unit.damage_factor
	end

	if min and max then
		min, max = math.ceil(min), math.ceil(max)
	end

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_icon = this.info.damage_icon,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.soldier_barrack.insert(this, store, script)
	if this.melee then
		this.melee.order = U.attack_order(this.melee.attacks)
	end

	if this.ranged then
		this.ranged.order = U.attack_order(this.ranged.attacks)
	end

	if this.auras then
		for _, a in pairs(this.auras.list) do
			if a.cooldown == 0 then
				local e = E:create_entity(a.name)

				e.pos = V.vclone(this.pos)
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts

				queue_insert(store, e)
			end
		end
	end

	if this.track_kills and this.track_kills.mod then
		local e = E:create_entity(this.track_kills.mod)

		e.pos = V.vclone(this.pos)
		e.modifier.target_id = this.id
		e.modifier.source_id = this.id

		queue_insert(store, e)
	end

	if this.track_damage and this.track_damage.mod then
		local e = E:create_entity(this.track_damage.mod)

		e.pos = V.vclone(this.pos)
		e.modifier.target_id = this.id
		e.modifier.source_id = this.id

		queue_insert(store, e)
	end

	if this.powers then
		for pn, p in pairs(this.powers) do
			for i = 1, p.level do
				SU.soldier_power_upgrade(this, pn)
			end
		end
	end

	if this.info and this.info.random_name_format then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""), math.random(this.info.random_name_count))
	end

	this.vis._bans = this.vis.bans
	this.vis.bans = F_ALL

	if this.render then
		for _, s in pairs(this.render.sprites) do
			s.ts = store.tick_ts - U.frandom(0, 1)
		end
	end

	return true
end

function scripts.soldier_barrack.remove(this, store, script)
	return true
end

function scripts.soldier_barrack.update(this, store, script)
	local brk, sta

	local function check_tower_damage_factor()
		local tower = store.entities[this.soldier.tower_id]
		if tower then
			for _, a in ipairs(this.melee.attacks) do
				if not a._original_damage_min then
					a._original_damage_min = a.damage_min
				end

				if not a._original_damage_max then
					a._original_damage_max = a.damage_max
				end

				a.damage_min = a._original_damage_min * tower.tower.damage_factor
				a.damage_max = a._original_damage_max * tower.tower.damage_factor
			end
		end
	end

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	if this.render.sprites[1].name == "raise" then
		this.health_bar.hidden = true

		U.animation_start(this, "raise", nil, store.tick_ts, 1)

		while not U.animation_finished(this) and not this.health.dead do
			coroutine.yield()
		end

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	while true do
		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					SU.soldier_power_upgrade(this, pn)
				end
			end
		end

		if this.cloak then
			this.vis.flags = band(this.vis.flags, bnot(this.cloak.flags))
			this.vis.bans = band(this.vis.bans, bnot(this.cloak.bans))
			this.render.sprites[1].alpha = 255
		end

		if not this.health.dead or SU.y_soldier_revive(store, this) then
			-- block empty
		else
			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			SU.soldier_courage_upgrade(store, this)

			if this.dodge and this.dodge.active then
				this.dodge.active = false

				if this.dodge.counter_attack and this.powers[this.dodge.counter_attack.power_name].level > 0 then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					U.animation_start(this, this.dodge.animation, nil, store.tick_ts, 1)

					while not U.animation_finished(this) do
						coroutine.yield()
					end
				end

				signal.emit("soldier-dodge", this)
			end

			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_43_1
				end
			end

			check_tower_damage_factor()

			if this.timed_actions then
				brk, sta = SU.y_soldier_timed_actions(store, this)

				if brk then
					goto label_43_1
				end
			end

			if this.timed_attacks then
				brk, sta = SU.y_soldier_timed_attacks(store, this)

				if brk then
					goto label_43_1
				end
			end

			if this.ranged and this.ranged.range_while_blocking then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					goto label_43_1
				end
			end

			if this.melee then
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_43_1
				end
			end

			if this.ranged and not this.ranged.range_while_blocking then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk or sta == A_DONE then
					goto label_43_1
				elseif sta == A_IN_COOLDOWN and not this.ranged.go_back_during_cooldown then
					goto label_43_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_43_1
			end

			::label_43_0::

			SU.soldier_idle(store, this)

			if this.cloak then
				this.vis.flags = bor(this.vis.flags, this.cloak.flags)
				this.vis.bans = bor(this.vis.bans, this.cloak.bans)

				if this.cloak.alpha then
					this.render.sprites[1].alpha = this.cloak.alpha
				end
			end

			SU.soldier_regen(store, this)
		end

		::label_43_1::

		coroutine.yield()
	end
end

scripts.hero_basic = {}

function scripts.hero_basic.get_info_melee(this)
	local a = this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

	min, max = min * this.unit.damage_factor, max * this.unit.damage_factor

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_type = a.damage_type,
		damage_icon = this.info.damage_icon,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_basic.get_info_ranged(this)
	local a = this.ranged.attacks[1]
	local b = E:get_template(a.bullet)
	local min, max = b.bullet.damage_min, b.bullet.damage_max
	if b.bullet.use_unit_damage_factor then
		min, max = min * this.unit.damage_factor, max * this.unit.damage_factor
	end

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_type = b.bullet.damage_type,
		damage_icon = this.info.damage_icon,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_basic.insert(this, store)
	if this.hero.fn_level_up then
		this.hero.fn_level_up(this, store, true)
	end

	if this.melee then
		this.melee.order = U.attack_order(this.melee.attacks)
	end

	if this.ranged then
		this.ranged.order = U.attack_order(this.ranged.attacks)
	end

	return true
end

scripts.tower_build = {}

function scripts.tower_build.update(this, store, script)
	local start_ts = store.tick_ts

	this.render.sprites[4].ts = start_ts

	while store.tick_ts - start_ts <= this.build_duration do
		coroutine.yield()
	end

	this.tower.upgrade_to = this.build_name
end

scripts.tower_common = {}

function scripts.tower_common.get_info(this)
	local min, max, d_type

	if this.attacks and this.attacks.list[1].damage_min then
		min, max = this.attacks.list[1].damage_min, this.attacks.list[1].damage_max
	elseif this.attacks and this.attacks.list[1].bullet then
		local b = E:get_template(this.attacks.list[1].bullet)

		min, max = b.bullet.damage_min, b.bullet.damage_max
		d_type = b.bullet.damage_type
	end

	min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)

	local cooldown

	if this.attacks and this.attacks.list[1].cooldown then
		cooldown = this.attacks.list[1].cooldown
	end

	return {
		type = d_type == DAMAGE_MAGICAL and STATS_TYPE_TOWER_MAGE or STATS_TYPE_TOWER,
		damage_min = min,
		damage_max = max,
		damage_type = d_type,
		range = this.attacks.range,
		cooldown = cooldown
	}
end

scripts.tower_archer = {}

function scripts.tower_archer.insert(this, store, script)
	return true
end

function scripts.tower_archer.update(this, store, script)
	local at = this.attacks
	local a = this.attacks.list[1]
	local shooter_sprite_ids = table.slice({
		3,
		4,
		5
	}, 1, #a.bullet_start_offset)
	local last_target_pos = V.v(0, 0)

	a.ts = store.tick_ts

	while true do
		local enemy

		if this.tower.blocked then
			-- block empty
		elseif store.tick_ts - a.ts < a.cooldown then
			-- block empty
		else
			enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, at.range, false, a.vis_flags, a.vis_bans)

			if enemy then
				a.ts = store.tick_ts
				a.count = a.count + 1

				local shooter_idx = a.count % #a.bullet_start_offset + 1
				local shooter_sid = shooter_sprite_ids[shooter_idx]
				local start_offset = a.bullet_start_offset[shooter_idx]
				local s = this.render.sprites[shooter_sid]
				local an, af = U.animation_name_facing_point(this, "shoot", enemy.pos, shooter_sid, start_offset)

				U.animation_start(this, an, af, store.tick_ts, 1, shooter_sid)

				last_target_pos = enemy.pos

				while store.tick_ts - a.ts < a.shoot_time do
					coroutine.yield()
				end

				enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, at.range, false, a.vis_flags, a.vis_bans)

				if enemy then
					last_target_pos = enemy.pos

					local an, af = U.animation_name_facing_point(this, "shoot", enemy.pos, shooter_sid, start_offset)

					this.render.sprites[shooter_sid].flip_x = af

					local bullet = E:create_entity(a.bullet)

					bullet.bullet.damage_factor = this.tower.damage_factor
					bullet.pos.x, bullet.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
					bullet.bullet.from = V.vclone(bullet.pos)
					bullet.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
					bullet.bullet.target_id = enemy.id
					bullet.bullet.source_id = this.id

					if bullet.bullet.flight_time_min and bullet.bullet.flight_time_factor then
						local dist = V.dist(bullet.bullet.to.x, bullet.bullet.to.y, bullet.bullet.from.x, bullet.bullet.from.y)

						bullet.bullet.flight_time = bullet.bullet.flight_time_min + dist / at.range * bullet.bullet.flight_time_factor
					end

					local u = UP:get_upgrade("archer_el_obsidian_heads")

					if u and enemy.health and enemy.health.armor == 0 then
						bullet.bullet.damage_min = bullet.bullet.damage_max
					end

					u = UP:get_upgrade("archer_precision")

					if u and math.random() < u.chance then
						bullet.bullet.damage_min = bullet.bullet.damage_min * u.damage_factor
						bullet.bullet.damage_max = bullet.bullet.damage_max * u.damage_factor
						bullet.bullet.pop = {
							"pop_crit"
						}
						bullet.bullet.pop_conds = DR_DAMAGE
					end

					queue_insert(store, bullet)

					u = UP:get_upgrade("archer_twin_shot")

					if u and math.random() < u.chance then
						local b2 = E:clone_entity(bullet)

						b2.bullet.flight_time = b2.bullet.flight_time - 1 / FPS

						queue_insert(store, b2)

						bullet.bullet.flight_time = bullet.bullet.flight_time + 1 / FPS
					end
				end

				while not U.animation_finished(this, shooter_sid) do
					coroutine.yield()
				end

				an, af = U.animation_name_facing_point(this, "idle", last_target_pos, shooter_sid, start_offset)

				U.animation_start(this, an, af, store.tick_ts, -1, shooter_sid)
			end

			if store.tick_ts - a.ts > this.tower.long_idle_cooldown then
				for _, sid in pairs(shooter_sprite_ids) do
					local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, sid)

					U.animation_start(this, an, af, store.tick_ts, -1, sid)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.tower_mage = {}

function scripts.tower_mage.get_info(this)
	local o = scripts.tower_common.get_info(this)

	o.type = STATS_TYPE_TOWER_MAGE

	if this.attacks and this.attacks.list[1].loops then
		local loops = this.attacks.list[1].loops

		o.damage_min = o.damage_min * loops
		o.damage_max = o.damage_max * loops
	end

	return o
end

function scripts.tower_mage.insert(this, store, script)
	return true
end

function scripts.tower_mage.update(this, store, script)
	local tower_sid = this.render.sid_tower
	local shooter_sid = this.render.sid_shooter
	local last_target_pos
	local a = this.attacks
	local aa = this.attacks.list[1]
	local shots = aa.loops or 1
	local ignore_out_of_range_check = aa.ignore_out_of_range_check or 1

	aa.ts = store.tick_ts

	while true do
		local enemy, enemies

		if this.tower.blocked then
			-- block empty
		elseif store.tick_ts - aa.ts <= aa.cooldown then
			-- block empty
		else
			enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)

			if enemy then
				aa.ts = store.tick_ts

				local shooter_offset_y = aa.bullet_start_offset[1].y
				local tx, ty = V.sub(enemy.pos.x, enemy.pos.y, this.pos.x, this.pos.y + shooter_offset_y)
				local t_angle = km.unroll(V.angleTo(tx, ty))
				local shooter = this.render.sprites[shooter_sid]
				local an, _, ai = U.animation_name_for_angle(this, aa.animation, t_angle, shooter_sid)

				U.animation_start(this, an, nil, store.tick_ts, 1, shooter_sid)
				U.animation_start(this, "shoot", nil, store.tick_ts, 1, tower_sid)

				last_target_pos = V.vclone(enemy.pos)

				while store.tick_ts - aa.ts < aa.shoot_time do
					coroutine.yield()
				end

				for i = 1, shots do
					enemy = enemies[km.zmod(i, #enemies)]

					local in_range = ignore_out_of_range_check or U.is_inside_ellipse(tpos(this), enemy.pos, a.range * 1.1)
					local bullet = E:create_entity(aa.bullet)

					bullet.bullet.shot_index = i
					bullet.bullet.damage_factor = this.tower.damage_factor
					bullet.bullet.source_id = this.id

					if in_range then
						bullet.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
						bullet.bullet.target_id = enemy.id
					else
						bullet.bullet.to = last_target_pos
						bullet.bullet.target_id = nil
					end

					local start_offset = aa.bullet_start_offset[ai]

					bullet.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
					bullet.pos = V.vclone(bullet.bullet.from)

					queue_insert(store, bullet)
				end

				while not U.animation_finished(this, tower_sid) do
					coroutine.yield()
				end

				U.animation_start(this, "idle", nil, store.tick_ts, -1, tower_sid)

				local an = U.animation_name_facing_point(this, "idle", last_target_pos, shooter_sid, aa.bullet_start_offset[1])

				U.animation_start(this, an, nil, store.tick_ts, -1, shooter_sid)
			end

			if store.tick_ts - aa.ts > this.tower.long_idle_cooldown then
				local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

				U.animation_start(this, an, af, store.tick_ts, -1, shooter_sid)
			end
		end

		coroutine.yield()
	end
end

scripts.tower_engineer = {}

function scripts.tower_engineer.insert(this, store, script)
	return true
end

function scripts.tower_engineer.update(this, store, script)
	local a = this.attacks
	local ba = this.attacks.list[1]

	ba.ts = store.tick_ts

	while true do
		if this.tower.blocked then
			coroutine.yield()
		elseif store.tick_ts - ba.ts < ba.cooldown then
			coroutine.yield()
		else
			local enemy, _, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, ba.node_prediction, ba.vis_flags, ba.vis_bans)

			if enemy then
				ba.ts = store.tick_ts

				for i = 2, 8 do
					U.animation_start(this, "shoot", nil, store.tick_ts, 1, i)
				end

				while store.tick_ts - ba.ts < ba.shoot_time do
					coroutine.yield()
				end

				local trigger_pos = pred_pos

				enemy, _, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, ba.node_prediction, ba.vis_flags, ba.vis_bans)

				local b = E:create_entity(ba.bullet)

				b.bullet.damage_factor = this.tower.damage_factor
				b.pos.x, b.pos.y = this.pos.x + ba.bullet_start_offset.x, this.pos.y + ba.bullet_start_offset.y
				b.bullet.from = V.vclone(b.pos)
				b.bullet.to = enemy and pred_pos or trigger_pos
				b.bullet.source_id = this.id

				queue_insert(store, b)

				while not U.animation_finished(this, 2) do
					coroutine.yield()
				end
			end

			for i = 2, 8 do
				U.animation_start(this, "idle", nil, store.tick_ts, -1, i)
			end

			coroutine.yield()
		end
	end
end

scripts.tower_barrack = {}

function scripts.tower_barrack.get_info(this)
	local s = E:create_entity(this.barrack.soldier_type)

	if this.powers then
		for pn, p in pairs(this.powers) do
			for i = 1, p.level do
				SU.soldier_power_upgrade(s, pn)
			end
		end
	end

	local s_info = s.info.fn(s)
	local attacks

	if s.melee and s.melee.attacks then
		attacks = s.melee.attacks
	elseif s.ranged and s.ranged.attacks then
		attacks = s.ranged.attacks
	end

	local min, max

	for _, a in pairs(attacks) do
		if a.damage_min then
			local damage_factor = this.tower.damage_factor
			min, max = a.damage_min * damage_factor, a.damage_max * damage_factor
			break
		end
	end

	if min and max then
		min, max = math.ceil(min), math.ceil(max)
	end

	return {
		type = STATS_TYPE_TOWER_BARRACK,
		hp_max = s.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = s.health.armor,
		respawn = s.health.dead_lifetime
	}
end

function scripts.tower_barrack.insert(this, store, script)
	if not this.barrack.rally_pos and this.tower.default_rally_pos then
		this.barrack.rally_pos = V.vclone(this.tower.default_rally_pos)
	end

	return true
end

function scripts.tower_barrack.remove(this, store, script)
	for _, s in pairs(this.barrack.soldiers) do
		if s.health then
			s.health.dead = true
		end

		queue_remove(store, s)
	end

	return true
end

function scripts.tower_barrack.update(this, store, script)
	local tower_sid = 2
	local door_sid = 3

	while true do
		local b = this.barrack

		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					for _, s in pairs(b.soldiers) do
						if s and s.powers and s.powers[pn] then
							s.powers[pn].level = p.level
							s.powers[pn].changed = true
						end
					end
				end
			end
		end

		if not this.tower.blocked then
			for i = 1, b.max_soldiers do
				local s = b.soldiers[i]

				if not s or s.health.dead and not store.entities[s.id] then
					if not b.door_open then
						if this.sound_events.open_door then
							S:queue(this.sound_events.open_door)
						else
							S:queue("GUITowerOpenDoor")
						end
						U.animation_start(this, "open", nil, store.tick_ts, 1, door_sid)

						while not U.animation_finished(this, door_sid) do
							coroutine.yield()
						end

						b.door_open = true
						b.door_open_ts = store.tick_ts
					end

					s = E:create_entity(b.soldier_type)
					s.soldier.tower_id = this.id
					s.soldier.tower_soldier_idx = i
					s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
					s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers)
					s.nav_rally.new = true

					if this.powers then
						for pn, p in pairs(this.powers) do
							s.powers[pn].level = p.level
						end
					end

					queue_insert(store, s)

					b.soldiers[i] = s

					signal.emit("tower-spawn", this, s)
				end
			end
		end

		if b.door_open and store.tick_ts - b.door_open_ts > b.door_hold_time then
			U.animation_start(this, "close", nil, store.tick_ts, 1, door_sid)

			while not U.animation_finished(this, door_sid) do
				coroutine.yield()
			end

			b.door_open = false
		end

		if b.rally_new then
			b.rally_new = false

			signal.emit("rally-point-changed", this)

			local all_dead = true

			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
				s.nav_rally.new = true
				all_dead = all_dead and s.health.dead
			end

			if not all_dead then
				S:queue(this.sound_events.change_rally_point)
			end
		end

		coroutine.yield()
	end
end

scripts.tower_barrack_mercenaries = {}

function scripts.tower_barrack_mercenaries.get_info(this)
	return {
		type = STATS_TYPE_TEXT,
		desc = _((this.info.i18n_key or string.upper(this.template_name)) .. "_DESCRIPTION")
	}
end

function scripts.tower_barrack_mercenaries.update(this, store, script)
	local b = this.barrack
	local door_sid = this.render.door_sid or 2

	while true do
		local old_count = #b.soldiers

		b.soldiers = table.filter(b.soldiers, function(_, s)
			return store.entities[s.id] ~= nil
		end)

		if #b.soldiers > 0 and #b.soldiers ~= old_count then
			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b)
			end
		end

		if b.unit_bought then
			if b.has_door and not b.door_open then
				U.animation_start(this, "open", nil, store.tick_ts, false, door_sid)
				U.y_animation_wait(this, door_sid)

				b.door_open = true
				b.door_open_ts = store.tick_ts
			end

			local s = E:create_entity(b.unit_bought)

			store.player_gold = store.player_gold - s.unit.price

			table.insert(b.soldiers, s)

			local i = #b.soldiers

			s.soldier.tower_id = this.id
			s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
			s.nav_rally.new = true

			queue_insert(store, s)

			for i, ss in ipairs(b.soldiers) do
				ss.nav_rally.pos, ss.nav_rally.center = U.rally_formation_position(i, b)
			end

			signal.emit("tower-spawn", this, s)

			b.unit_bought = nil
		end

		if b.has_door and b.door_open and store.tick_ts - b.door_open_ts > b.door_hold_time then
			U.animation_start(this, "close", nil, store.tick_ts, false, door_sid)
			U.y_animation_wait(this, door_sid)

			b.door_open = false
		end

		if b.rally_new then
			b.rally_new = false

			signal.emit("rally-point-changed", this)

			local sounds = {}
			local all_dead = true

			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b)
				s.nav_rally.new = true

				if s.sound_events.change_rally_point then
					table.insert(sounds, s.sound_events.change_rally_point)
				end

				all_dead = all_dead and s.health.dead
			end

			if not all_dead then
				if #sounds > 0 then
					S:queue(sounds[math.random(1, #sounds)])
				else
					S:queue(this.sound_events.change_rally_point)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.arrow = {}

function scripts.arrow.insert(this, store, script)
	local b = this.bullet
	local target = store.entities[b.target_id]

	if not target then
		return false
	end

	if b.reset_to_target_pos then
		b.to.x, b.to.y = target.pos.x, target.pos.y

		if target.unit and target.unit.hit_offset and not b.ignore_hit_offset then
			b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
		end
	end

	if b.predict_target_pos then
		local err_x, err_y = 0, 0

		if b.prediction_error then
			err_x = target.motion.speed.x == 0 and 0 or U.frandom(0, 1) * 10
			err_y = target.motion.speed.y == 0 and 0 or U.frandom(0, 1) * -10
		end

		b.to.x = b.to.x + target.motion.speed.x * b.flight_time + err_x
		b.to.y = b.to.y + target.motion.speed.y * b.flight_time + err_y
	end

	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)

	if b.rotation_speed then
		b.rotation_speed = b.rotation_speed * (b.to.x > this.pos.x and -1 or 1)

		if b.rotation_speed > 0 then
			this.render.sprites[1].flip_x = not this.render.sprites[1].flip_x
		end
	end

	if b.hide_radius then
		this.render.sprites[1].hidden = true
	end

	local s = this.render.sprites[1]
	if s.animated then
		s.ts = store.tick_ts
	end

	return true
end

function scripts.arrow.update(this, store, script)
	local b = this.bullet
	local ps
	local s = this.render.sprites[1]

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	while store.tick_ts - b.ts + store.tick_length <= b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if b.rotation_speed then
			s.r = s.r + b.rotation_speed * store.tick_length
		else
			s.r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)

			if b.asymmetrical and math.abs(s.r) > math.pi / 2 then
				s.flip_y = true
			end
		end

		if ps then
			ps.particle_system.emit_direction = s.r
		end

		if b.hide_radius then
			local at_start = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius
			local at_end = V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius

			s.hidden = at_start or at_end

			if ps then
				if b.extend_particles_cutoff then
					ps.particle_system.emit = not at_start
				else
					ps.particle_system.emit = not s.hidden
				end
			end
		end
	end

	local hit = false
	local target = store.entities[b.target_id]

	if target and target.health and not target.health.dead then
		local target_pos = V.vclone(target.pos)

		if target.unit and target.unit.hit_offset and not b.ignore_hit_offset then
			target_pos.x, target_pos.y = target_pos.x + target.unit.hit_offset.x, target_pos.y + target.unit.hit_offset.y
		end

		if V.dist(this.pos.x, this.pos.y, target_pos.x, target_pos.y) < b.hit_distance and not SU.unit_dodges(store, target, true) and (not b.hit_chance or math.random() < b.hit_chance) then
			hit = true

			local d = SU.create_bullet_damage(b, target.id, this.id)

			queue_damage(store, d)

			if b.mod then
				local mods = type(b.mod) == "table" and b.mod or {
					b.mod
				}

				for _, mod_name in pairs(mods) do
					local mod = E:create_entity(mod_name)

					mod.modifier.source_id = this.id
					mod.modifier.target_id = target.id
					mod.modifier.level = b.level
					mod.modifier.source_damage = d

					queue_insert(store, mod)
				end
			end

			if b.hit_fx then
				local fx = E:create_entity(b.hit_fx)

				fx.pos = V.vclone(target_pos)
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)
			end

			if b.hit_blood_fx and target.unit.blood_color ~= BLOOD_NONE then
				local sfx = E:create_entity(b.hit_blood_fx)

				sfx.pos = V.vclone(target_pos)
				sfx.render.sprites[1].ts = store.tick_ts

				if sfx.use_blood_color and target.unit.blood_color then
					sfx.render.sprites[1].name = target.unit.blood_color
					sfx.render.sprites[1].r = s.r
				end

				queue_insert(store, sfx)
			end
		end
	end

	if not hit then
		if GR:cell_is(this.pos.x, this.pos.y, TERRAIN_WATER) then
			if b.miss_fx_water then
				local water_fx = E:create_entity(b.miss_fx_water)

				water_fx.pos.x, water_fx.pos.y = b.to.x, b.to.y
				water_fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, water_fx)
			end
		else
			if b.miss_fx then
				local fx = E:create_entity(b.miss_fx)

				fx.pos.x, fx.pos.y = b.to.x, b.to.y
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)
			end

			if b.miss_decal then
				local decal = E:create_entity("decal_tween")

				decal.pos = V.vclone(b.to)
				decal.tween.props[1].keys = {
					{
						0,
						255
					},
					{
						2.1,
						0
					}
				}
				decal.render.sprites[1].ts = store.tick_ts
				decal.render.sprites[1].name = b.miss_decal
				decal.render.sprites[1].animated = false
				decal.render.sprites[1].z = Z_DECALS

				if b.rotation_speed then
					decal.render.sprites[1].flip_x = b.rotation_speed > 0
				else
					decal.render.sprites[1].r = -math.pi / 2 * (1 + (0.5 - math.random()) * 0.35)
				end

				if b.miss_decal_anchor then
					decal.render.sprites[1].anchor = b.miss_decal_anchor
				end

				queue_insert(store, decal)
			end
		end
	end

	if b.payload then
		local p = E:create_entity(b.payload)

		p.pos.x, p.pos.y = b.to.x, b.to.y
		p.target_id = b.target_id
		p.source_id = this.id

		if p.aura then
			p.aura.level = b.level
		end

		queue_insert(store, p)
	end

	if ps then
		if b.extend_particles_cutoff then
			ps.particle_system.emit = true

			coroutine.yield()
		end

		if ps.particle_system.emit then
			s.hidden = true
			ps.particle_system.emit = false

			U.y_wait(store, ps.particle_system.particle_lifetime[2])
		end
	end

	queue_remove(store, this)
end

scripts.bomb = {}

function scripts.bomb.insert(this, store, script)
	local b = this.bullet

	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)

	if b.rotation_speed then
		this.render.sprites[1].r = (math.random() - 0.5) * math.pi
		b.rotation_speed = b.rotation_speed * (b.to.x > b.from.x and -1 or 1)
	end

	if b.hide_radius then
		this.render.sprites[1].hidden = true
	end

	return true
end

function scripts.bomb.update(this, store, script)
	local b = this.bullet
	local dmin, dmax = b.damage_min, b.damage_max
	local dradius = b.damage_radius

	if b.level and b.level > 0 then
		if b.damage_radius_inc then
			dradius = dradius + b.level * b.damage_radius_inc
		end

		if b.damage_min_inc then
			dmin = dmin + b.level * b.damage_min_inc
		end

		if b.damage_max_inc then
			dmax = dmax + b.level * b.damage_max_inc
		end
	end

	local ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	while store.tick_ts - b.ts + store.tick_length < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
		elseif b.rotation_speed then
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
		end

		if b.hide_radius then
			this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
		end
	end

	local enemies = table.filter(store.entities, function(k, v)
		return v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, b.damage_bans) == 0 and band(v.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(v.pos, b.to, dradius)
	end)

	for _, enemy in pairs(enemies) do
		local d = E:create_entity("damage")

		d.damage_type = b.damage_type
		d.reduce_armor = b.reduce_armor
		d.reduce_magic_armor = b.reduce_magic_armor

		if b.damage_decay_random then
			d.value = U.frandom(dmin, dmax)
		elseif this.up_alchemical_powder_chance and math.random() < this.up_alchemical_powder_chance or UP:get_upgrade("engineer_efficiency") then
			d.value = dmax
		else
			local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, dradius)

			d.value = math.floor(dmax - (dmax - dmin) * dist_factor)
		end

		d.value = math.ceil(b.damage_factor * d.value)
		d.source_id = this.id
		d.target_id = enemy.id

		queue_damage(store, d)
		log.paranoid("bomb id:%s, radius:%s, enemy id:%s, dist:%s, damage:%s damage_type:%x", this.id, dradius, enemy.id, V.dist(enemy.pos.x, enemy.pos.y, b.to.x, b.to.y), d.value, d.damage_type)

		if this.up_shock_and_awe_chance and band(enemy.vis.bans, F_STUN) == 0 and band(enemy.vis.flags, bor(F_BOSS, F_CLIFF, F_FLYING)) == 0 and math.random() < this.up_shock_and_awe_chance then
			local mod = E:create_entity("mod_shock_and_awe")

			mod.modifier.target_id = enemy.id

			queue_insert(store, mod)
		end

		if b.mod then
			local mod = E:create_entity(b.mod)

			mod.modifier.target_id = enemy.id
			mod.modifier.source_id = this.id

			queue_insert(store, mod)
		end
	end

	local p = SU.create_bullet_pop(store, this)

	queue_insert(store, p)

	local cell_type = GR:cell_type(b.to.x, b.to.y)

	if b.hit_fx_water and band(cell_type, TERRAIN_WATER) ~= 0 then
		S:queue(this.sound_events.hit_water)

		local water_fx = E:create_entity(b.hit_fx_water)

		water_fx.pos.x, water_fx.pos.y = b.to.x, b.to.y
		water_fx.render.sprites[1].ts = store.tick_ts
		water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

		queue_insert(store, water_fx)
	elseif b.hit_fx then
		S:queue(this.sound_events.hit)

		local sfx = E:create_entity(b.hit_fx)

		sfx.pos = V.vclone(b.to)
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

		queue_insert(store, sfx)
	end

	if b.hit_decal and band(cell_type, TERRAIN_WATER) == 0 then
		local decal = E:create_entity(b.hit_decal)

		decal.pos = V.vclone(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		queue_insert(store, decal)
	end

	if b.hit_payload then
		local hp

		if type(b.hit_payload) == "string" then
			hp = E:create_entity(b.hit_payload)
		else
			hp = b.hit_payload
		end

		hp.pos.x, hp.pos.y = b.to.x, b.to.y

		if hp.aura then
			hp.aura.level = this.bullet.level
		end

		queue_insert(store, hp)
	end

	queue_remove(store, this)
end

scripts.enemy_bomb = {}

function scripts.enemy_bomb.insert(this, store, script)
	local b = this.bullet

	if b.flight_time_base and b.flight_time_factor then
		local dist = V.dist(b.to.x, b.to.y, b.from.x, b.from.y)

		b.flight_time = b.flight_time_base + dist * b.flight_time_factor
	end

	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)
	this.render.sprites[1].r = (math.random() - 0.5) * math.pi

	if b.hide_radius then
		this.render.sprites[1].hidden = true
	end

	return true
end

function scripts.enemy_bomb.update(this, store, script)
	local b = this.bullet
	local ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	local warp_factor = b.warp_time and b.warp_time or 1

	while (store.tick_ts - b.ts + store.tick_length) * warp_factor < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola((store.tick_ts - b.ts) * warp_factor, b.from, b.speed, b.g)

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
		else
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
		end

		if b.hide_radius then
			this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
		end
	end

	local targets
	local target = b.target_id and store.entities[b.target_id]

	if target and target.vis and U.flag_has(target.vis.flags, F_FLYING) then
		targets = {
			target
		}
	else
		targets = table.filter(store.entities, function(_, e)
			return e and e.health and not e.health.dead and e.vis and band(e.vis.flags, b.damage_bans) == 0 and band(e.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(e.pos, b.to, b.damage_radius)
		end)
	end

	for _, target in pairs(targets) do
		local d = E:create_entity("damage")

		d.damage_type = b.damage_type

		if b.damage_decay_random then
			d.value = math.ceil(U.frandom(b.damage_min, b.damage_max))
		else
			local dist_factor = U.dist_factor_inside_ellipse(target.pos, this.pos, b.damage_radius)

			d.value = math.floor(b.damage_max - (b.damage_max - b.damage_min) * dist_factor)
		end

		d.source_id = this.id
		d.target_id = target.id

		queue_damage(store, d)

		if b.mod then
			local mod = E:create_entity(b.mod)

			mod.modifier.target_id = target.id
			mod.modifier.source_id = this.id

			queue_insert(store, mod)
		end
	end

	local p = SU.create_bullet_pop(store, this)

	queue_insert(store, p)
	S:queue(this.sound_events.hit)

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos = V.vclone(b.to)
		sfx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, sfx)
	end

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)

		decal.pos = V.vclone(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		queue_insert(store, decal)
	end

	if b.hit_payload then
		local hp

		if type(b.hit_payload) == "string" then
			hp = E:create_entity(b.hit_payload)
		else
			hp = b.hit_payload
		end

		hp.pos.x, hp.pos.y = b.to.x, b.to.y

		if hp.aura then
			hp.aura.level = this.bullet.level
		end

		queue_insert(store, hp)
	end

	queue_remove(store, this)
end

scripts.missile = {}

function scripts.missile.insert(this, store, script)
	local b = this.bullet
	local ps = E:create_entity(b.particles_name)

	ps.particle_system.track_id = this.id

	queue_insert(store, ps)

	return true
end

function scripts.missile.update(this, store, script)
	local b = this.bullet
	local target = store.entities[b.target_id]
	local mspeed = b.min_speed
	local rot_dir = 1
	local follow = false
	local max_seek_angle = b.max_seek_angle or 0.2

	if this.render.sprites[1].animated then
		U.animation_start(this, "flying", nil, store.tick_ts, -1)
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.speed.x, b.speed.y)

		if b.rot_dir_from_long_angle and target then
			rot_dir = target.pos.x < this.pos.x and -1 or 1
		elseif b.speed.x < 0 then
			rot_dir = -1
		end

		coroutine.yield()
	end

	if not target or target.health and target.health.dead then
		local ref_pos = target and target.pos or this.pos

		target = U.find_foremost_enemy(store.entities, ref_pos, 0, b.retarget_range, false, b.vis_flags)
	end

	if target then
		b.to.x, b.to.y = target.pos.x, target.pos.y

		if target.unit.hit_offset then
			b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
		end
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		if not target or target.health and target.health.dead or band(target.vis.bans, b.vis_flags) ~= 0 then
			local ref_pos = target and target.pos or this.pos

			target = U.find_foremost_enemy(store.entities, ref_pos, 0, b.retarget_range, false, b.vis_flags)

			if b.rot_dir_from_long_angle and target then
				rot_dir = target.pos.x < this.pos.x and -1 or 1
			end
		end

		if target then
			b.to.x, b.to.y = target.pos.x, target.pos.y

			if target.unit.hit_offset then
				b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
			end
		end

		local d_angle = V.angleTo(b.speed.x, b.speed.y, b.to.x - this.pos.x, b.to.y - this.pos.y)

		if max_seek_angle < math.abs(d_angle) then
			local rot = b.turn_speed * store.tick_length * rot_dir
			local dir = V.angleTo(b.speed.x, b.speed.y)

			if dir > math.pi / 3 and dir < 2 * math.pi / 3 then
				rot = rot * (b.turn_helicoidal_factor or 1.5)
			end

			b.speed.x, b.speed.y = V.rotate(rot, b.speed.x, b.speed.y)
		else
			mspeed = mspeed + 30 * math.ceil(mspeed * 0.03333333333333333 * b.acceleration_factor)
			mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
			b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		end

		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.speed.x, b.speed.y)

		coroutine.yield()
	end

	if b.damage_radius and b.damage_radius > 0 then
		local enemies = table.filter(store.entities, function(k, v)
			return v.enemy and v.vis and v.unit and v.health and not v.health.dead and band(v.vis.flags, b.damage_bans) == 0 and band(v.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(V.v(v.pos.x + v.unit.hit_offset.x, v.pos.y + v.unit.hit_offset.y), b.to, b.damage_radius)
		end)
		local alchemical_powder = UP:get_upgrade("engineer_alchemical_powder")
		local alchemical_powder_on = alchemical_powder and math.random() < alchemical_powder.chance
		local shock_and_awe = UP:get_upgrade("engineer_shock_and_awe")

		for _, enemy in pairs(enemies) do
			local enemy_pos = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = enemy.id
			d.damage_type = b.damage_type
			d.reduce_armor = b.reduce_armor
			d.reduce_magic_armor = b.reduce_magic_armor

			if alchemical_powder_on then
				d.value = b.damage_max
			else
				local dist_factor = U.dist_factor_inside_ellipse(enemy_pos, this.pos, b.damage_radius)

				d.value = math.floor(b.damage_max - (b.damage_max - b.damage_min) * dist_factor)
			end

			d.value = math.ceil(b.damage_factor * d.value)

			queue_damage(store, d)

			if b.mod then
				local mod = E:create_entity(b.mod)

				mod.modifier.target_id = enemy.id

				queue_insert(store, mod)
			end

			if shock_and_awe and band(enemy.vis.bans, F_STUN) == 0 and band(enemy.vis.flags, bor(F_BOSS, F_CLIFF, F_FLYING)) == 0 and math.random() < shock_and_awe.chance then
				local mod = E:create_entity("mod_shock_and_awe")

				mod.modifier.target_id = enemy.id

				queue_insert(store, mod)
			end
		end
	elseif target then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)

		if b.mod then
			local mod = E:create_entity(b.mod)

			mod.modifier.target_id = target.id

			queue_insert(store, mod)
		end
	end

	local fx

	if b.hit_fx_air and target and band(target.vis.flags, F_FLYING) ~= 0 then
		fx = b.hit_fx_air

		S:queue(this.sound_events.hit)
	elseif b.hit_fx_water and not target and band(GR:cell_type(b.to.x, b.to.y), TERRAIN_WATER) ~= 0 then
		fx = b.hit_fx_water

		S:queue(this.sound_events.hit_water)
	elseif b.hit_fx then
		fx = b.hit_fx

		S:queue(this.sound_events.hit)
	end

	if fx then
		local is_air = target and band(target.vis.flags, F_FLYING) ~= 0
		local sfx = E:create_entity(fx)

		if b.hit_fx_ignore_hit_offset and target and not is_air then
			sfx.pos.x, sfx.pos.y = target.pos.x, target.pos.y
		else
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
		end

		sfx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, sfx)
	end

	queue_remove(store, this)
end

scripts.enemy_missile = {}

function scripts.enemy_missile.update(this, store, script)
	local b = this.bullet
	local target = store.entities[b.target_id]
	local mspeed = b.min_speed
	local rot_dir = 1
	local follow = false
	local max_seek_angle = b.max_seek_angle or 0.2

	if b.particles_name then
		local ps = E:create_entity(b.particles_name)

		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	if this.render.sprites[1].animated then
		U.animation_start(this, "flying", nil, store.tick_ts, -1)
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.speed.x, b.speed.y)

		if b.rot_dir_from_long_angle and target then
			rot_dir = target.pos.x < this.pos.x and -1 or 1
		elseif b.speed.x < 0 then
			rot_dir = -1
		end

		coroutine.yield()
	end

	if not target or target.health and target.health.dead then
		local ref_pos = target and target.pos or this.pos

		target = U.find_random_target(store.entities, ref_pos, 0, b.retarget_range, b.vis_flags, b.vis_bans)
	end

	if target then
		b.to.x, b.to.y = target.pos.x, target.pos.y

		if target.unit.hit_offset then
			b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
		end
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		if not target or target.health and target.health.dead or band(target.vis.bans, b.vis_flags) ~= 0 then
			local ref_pos = target and target.pos or this.pos

			target = U.find_random_target(store.entities, ref_pos, 0, b.retarget_range, b.vis_flags, b.vis_bans)

			if b.rot_dir_from_long_angle and target then
				rot_dir = target.pos.x < this.pos.x and -1 or 1
			end
		end

		if target then
			b.to.x, b.to.y = target.pos.x, target.pos.y

			if target.unit.hit_offset then
				b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
			end
		end

		local d_angle = V.angleTo(b.speed.x, b.speed.y, b.to.x - this.pos.x, b.to.y - this.pos.y)

		if max_seek_angle < math.abs(d_angle) then
			local rot = b.turn_speed * store.tick_length * rot_dir
			local dir = V.angleTo(b.speed.x, b.speed.y)

			if dir > math.pi / 3 and dir < 2 * math.pi / 3 then
				rot = rot * (b.turn_helicoidal_factor or 1.5)
			end

			b.speed.x, b.speed.y = V.rotate(rot, b.speed.x, b.speed.y)
		else
			mspeed = mspeed + 30 * math.ceil(mspeed * 0.03333333333333333 * b.acceleration_factor)
			mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
			b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		end

		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.speed.x, b.speed.y)

		coroutine.yield()
	end

	if b.damage_radius and b.damage_radius > 0 then
		local targets = table.filter(store.entities, function(k, v)
			return v.vis and v.unit and v.health and not v.health.dead and band(v.vis.flags, b.damage_bans) == 0 and band(v.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(V.v(v.pos.x + v.unit.hit_offset.x, v.pos.y + v.unit.hit_offset.y), b.to, b.damage_radius)
		end)

		for _, t in pairs(targets) do
			local t_pos = V.v(t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y)
			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = t.id
			d.damage_type = b.damage_type
			d.reduce_armor = b.reduce_armor
			d.reduce_magic_armor = b.reduce_magic_armor

			local dist_factor = U.dist_factor_inside_ellipse(t_pos, this.pos, b.damage_radius)

			d.value = math.floor(b.damage_max - (b.damage_max - b.damage_min) * dist_factor)
			d.value = math.ceil(b.damage_factor * d.value)

			queue_damage(store, d)

			if b.mod then
				local mod = E:create_entity(b.mod)

				mod.modifier.target_id = t.id

				queue_insert(store, mod)
			end
		end
	end

	local is_air_hit = target and band(target.vis.flags, F_FLYING) ~= 0
	local fx_name = is_air_hit and b.hit_fx_air or b.hit_fx

	if fx_name then
		S:queue(this.sound_events.hit)

		local sfx = E:create_entity(fx_name)

		if b.hit_fx_ignore_hit_offset and target and not is_air_hit then
			sfx.pos.x, sfx.pos.y = target.pos.x, target.pos.y
		else
			sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
		end

		sfx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, sfx)
	end

	queue_remove(store, this)
end

scripts.bolt_enemy = {}

function scripts.bolt_enemy.insert(this, store, script)
	local b = this.bullet

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	U.animation_start(this, "flying", nil, store.tick_ts, -1)

	return true
end

function scripts.bolt_enemy.update(this, store, script)
	local b = this.bullet
	local mspeed = b.min_speed
	local target, ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	if b.target_id then
		S:queue(this.sound_events.travel)
	else
		S:queue(this.sound_events.summon)
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		if b.target_id then
			target = store.entities[b.target_id]
		end

		if target then
			local ho = target.unit.hit_offset

			if U.flag_has(target.vis.bans, F_RANGED) or target.health.dead then
				b.target_id = nil
				target = nil
			elseif b.max_track_distance then
				local d = math.max(math.abs(target.pos.x + ho.x - b.to.x), math.abs(target.pos.y + ho.y - b.to.y))

				if d > b.max_track_distance then
					b.target_id = nil
					target = nil
				end
			else
				b.to.x, b.to.y = target.pos.x + ho.x, target.pos.y + ho.y
			end
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
		else
			this.render.sprites[1].flip_x = b.to.x < this.pos.x
		end

		if ps then
			ps.particle_system.emit_direction = this.render.sprites[1].r
		end

		coroutine.yield()
	end

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)

		if b.mod then
			local mod = E:create_entity(b.mod)

			mod.modifier.target_id = target.id

			queue_insert(store, mod)
		end

		if b.hit_payload then
			local hp

			if type(b.hit_payload) == "string" then
				hp = E:create_entity(b.hit_payload)
			else
				hp = b.hit_payload
			end

			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y

			queue_insert(store, hp)
		end
	end

	local sfx, sfx_ignore_offset

	if b.hit_fx_air and target and U.flag_has(target.vis.flags, F_FLYING) then
		sfx = b.hit_fx_air
		sfx_ignore_offset = b.hit_fx_ignore_offset_air
	elseif b.hit_fx then
		sfx = b.hit_fx
		sfx_ignore_offset = b.hit_fx_ignore_offset
	end

	if sfx then
		local sfx = E:create_entity(sfx)

		if sfx_ignore_offset and target then
			sfx.pos.x, sfx.pos.y = target.pos.x, target.pos.y
		else
			sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		end

		sfx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, sfx)
	end

	queue_remove(store, this)
end

scripts.bolt = {}

function scripts.bolt.insert(this, store, script)
	local b = this.bullet

	if b.target_id then
		local target = store.entities[b.target_id]

		if not target or band(target.vis.bans, F_RANGED) ~= 0 then
			return false
		end
	end

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	local s = this.render.sprites[1]

	if not b.ignore_rotation then
		s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
	end

	U.animation_start(this, "flying", nil, store.tick_ts, s.loop)

	return true
end

function scripts.bolt.update(this, store, script)
	local b = this.bullet
	local s = this.render.sprites[1]
	local mspeed = b.min_speed
	local target, ps
	local new_target = false
	local target_invalid = false

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	::label_79_0::

	if b.store and not b.target_id then
		S:queue(this.sound_events.summon)

		s.z = Z_OBJECTS
		s.sort_y_offset = b.store_sort_y_offset

		U.animation_start(this, "idle", nil, store.tick_ts, true)

		if ps then
			ps.particle_system.emit = false
		end
	else
		S:queue(this.sound_events.travel)

		s.z = Z_BULLETS
		s.sort_y_offset = nil

		U.animation_start(this, "flying", nil, store.tick_ts, s.loop)

		if ps then
			ps.particle_system.emit = true
		end
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		coroutine.yield()

		if not target_invalid then
			target = store.entities[b.target_id]
		end

		if target and not new_target then
			local tpx, tpy = target.pos.x, target.pos.y

			if not b.ignore_hit_offset then
				tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
			end

			local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

			if d > b.max_track_distance or band(target.vis.bans, F_RANGED) ~= 0 then
				target_invalid = true
				target = nil
			end
		end

		if target and target.health and not target.health.dead then
			if b.ignore_hit_offset then
				b.to.x, b.to.y = target.pos.x, target.pos.y
			else
				b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			end

			new_target = false
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		if not b.ignore_rotation then
			s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
		end

		if ps then
			ps.particle_system.emit_direction = s.r
		end
	end

	while b.store and not b.target_id do
		coroutine.yield()

		if b.target_id then
			mspeed = b.min_speed
			new_target = true

			goto label_79_0
		end
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)
		local u = UP:get_upgrade("mage_spell_of_penetration")

		if u and math.random() < u.chance then
			d.damage_type = DAMAGE_TRUE
		end

		queue_damage(store, d)

		if b.mod or b.mods then
			local mods = b.mods or {
				b.mod
			}

			for _, mod_name in pairs(mods) do
				local m = E:create_entity(mod_name)

				m.modifier.target_id = b.target_id
				m.modifier.level = b.level

				queue_insert(store, m)
			end
		end

		if b.hit_payload then
			local hp = b.hit_payload

			hp.pos.x, hp.pos.y = this.pos.x, this.pos.y

			queue_insert(store, hp)
		end
	end

	if b.payload then
		local hp = b.payload

		hp.pos.x, hp.pos.y = b.to.x, b.to.y

		queue_insert(store, hp)
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].runs = 0

		if target and sfx.render.sprites[1].size_names then
			sfx.render.sprites[1].name = sfx.render.sprites[1].size_names[target.unit.size]
		end

		queue_insert(store, sfx)
	end

	queue_remove(store, this)
end

scripts.bolt_blast = {}

function scripts.bolt_blast.insert(this, store, script)
	return true
end

function scripts.bolt_blast.update(this, store, script)
	local b = this.bullet
	local dradius = b.damage_radius + b.level * b.damage_radius_inc
	local dmin = b.damage_min + b.level * b.damage_inc
	local dmax = b.damage_max + b.level * b.damage_inc
	local explode_pos = V.v(this.pos.x, this.pos.y - 8)

	U.animation_start(this, "hit", nil, store.tick_ts, 1)

	local enemies = table.filter(store.entities, function(k, v)
		return v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, b.damage_bans) == 0 and band(v.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(v.pos, explode_pos, dradius)
	end)
	local d_value = U.frandom(dmin, dmax)

	for _, enemy in pairs(enemies) do
		local d = E:create_entity("damage")

		d.source_id = this.id
		d.target_id = enemy.id
		d.value = math.ceil(d_value)
		d.damage_type = b.damage_type
		d.track_damage = true

		queue_damage(store, d)
	end

	while not U.animation_finished(this) do
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.shotgun = {}

function scripts.shotgun.insert(this, store, script)
	local b = this.bullet

	if b.start_fx then
		local fx = E:create_entity(b.start_fx)

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

	if b.hide_radius then
		this.render.sprites[1].hidden = true
	end

	return true
end

function scripts.shotgun.update(this, store, script)
	local b = this.bullet
	local target = store.entities[b.target_id]
	local speed = b.min_speed
	local target_invalid = false
	local ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
		coroutine.yield()

		if not target_invalid then
			target = store.entities[b.target_id]
		end

		if target then
			local tpx, tpy = target.pos.x, target.pos.y

			if not b.ignore_hit_offset then
				tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
			end

			local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

			if d > b.max_track_distance or band(target.vis.bans, F_RANGED) ~= 0 then
				target_invalid = true
				target = nil
			end
		end

		if target and target.health and not target.health.dead then
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
		end

		b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		if b.hide_radius then
			this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
		end
	end

	if target and target.health and not target.health.dead then
		local u = UP:get_upgrade("archer_precision")

		if u and math.random() < u.chance and not b.ignore_upgrades then
			b.damage_min = b.damage_min * u.damage_factor
			b.damage_max = b.damage_max * u.damage_factor
			b.pop = {
				"pop_crit"
			}
			b.pop_conds = DR_DAMAGE
		end

		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)

		if b.hit_blood_fx and target.unit.blood_color ~= BLOOD_NONE then
			local sfx = E:create_entity(b.hit_blood_fx)

			sfx.pos.x, sfx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			sfx.render.sprites[1].ts = store.tick_ts

			if sfx.use_blood_color and target.unit.blood_color then
				sfx.render.sprites[1].r = this.render.sprites[1].r
				sfx.render.sprites[1].name = target.unit.blood_color
			end

			queue_insert(store, sfx)
		end
	elseif b.miss_fx_water and GR:cell_is(b.to.x, b.to.y, TERRAIN_WATER) then
		local fx = E:create_entity(b.miss_fx_water)

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	elseif b.miss_fx then
		local fx = E:create_entity(b.miss_fx)

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	queue_remove(store, this)
end

scripts.ray_simple = {}

function scripts.ray_simple.update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local dest = V.vclone(b.to)

	local function update_sprite()
		if this.track_target and target and target.motion then
			local tpx, tpy = target.pos.x, target.pos.y

			if not b.ignore_hit_offset then
				tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
			end

			local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

			if d > b.max_track_distance then
				log.paranoid("(%s) ray_simple target (%s) out of max_track_distance", this.id, target.id)

				target = nil
			else
				dest.x, dest.y = target.pos.x, target.pos.y

				if target.unit and target.unit.hit_offset then
					dest.x, dest.y = dest.x + target.unit.hit_offset.x, dest.y + target.unit.hit_offset.y
				end
			end
		end

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
	end

	if not b.ignore_hit_offset and this.track_target and target and target.motion then
		b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
	end

	s.scale = s.scale or V.v(1, 1)
	s.ts = store.tick_ts

	update_sprite()

	while store.tick_ts - s.ts < b.hit_time do
		coroutine.yield()

		if target and U.flag_has(target.vis.bans, F_RANGED) then
			target = nil
		end

		if this.track_target then
			update_sprite()
		end
	end

	if target and b.damage_type ~= DAMAGE_NONE then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)
	end

	if target and (b.mod or b.mods) then
		local mods = b.mods or {
			b.mod
		}

		for _, mod_name in pairs(mods) do
			local m = E:create_entity(mod_name)

			m.modifier.target_id = b.target_id
			m.modifier.level = b.level

			queue_insert(store, m)
		end
	end

	if b.hit_payload then
		local hp

		if type(b.hit_payload) == "string" then
			hp = E:create_entity(b.hit_payload)
		else
			hp = b.hit_payload
		end

		if hp.aura then
			hp.aura.level = this.bullet.level
			hp.aura.source_id = this.id

			if target then
				hp.pos.x, hp.pos.y = target.pos.x, target.pos.y
			else
				hp.pos.x, hp.pos.y = dest.x, dest.y
			end
		else
			hp.pos.x, hp.pos.y = dest.x, dest.y
		end

		queue_insert(store, hp)
	end

	if b.hit_fx then
		local is_air = target and band(target.vis.flags, F_FLYING) ~= 0
		local fx = E:create_entity(b.hit_fx)

		if b.hit_fx_ignore_hit_offset and target and not is_air then
			fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
		else
			fx.pos.x, fx.pos.y = dest.x, dest.y
		end

		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	if this.ray_duration then
		while store.tick_ts - s.ts < this.ray_duration and target and not target.health.dead do
			if this.track_target then
				update_sprite()
			end

			coroutine.yield()
		end
	else
		U.y_animation_wait(this)
	end

	queue_remove(store, this)
end

scripts.ray_enemy = {}

function scripts.ray_enemy.update(this, store, script)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	local ho = V.v(0, 0)
	local dest = b.to and V.vclone(b.to) or V.vclone(target.pos)

	s.scale = V.v(1, 1)

	local function update_sprite()
		if target and b.max_track_distance then
			if target.unit and target.unit.hit_offset and not b.ignore_hit_offset then
				ho.x, ho.y = target.unit.hit_offset.x, target.unit.hit_offset.y
			else
				ho.x, ho.y = 0, 0
			end

			local d = math.max(math.abs(target.pos.x + ho.x - dest.x), math.abs(target.pos.y + ho.y - dest.y))

			if d > b.max_track_distance then
				log.paranoid("ray_enemy: distance from %s,%s to target %s,%s exceeds max_track_distance: %s", dest.x, dest.y, target.pos.x, target.pos.y, b.max_track_distance)

				b.target_id = nil
				target = nil
			end
		end

		if target and target.motion then
			dest.x, dest.y = target.pos.x, target.pos.y

			if target.unit and target.unit.hit_offset and not b.ignore_hit_offset then
				dest.x, dest.y = dest.x + target.unit.hit_offset.x, dest.y + target.unit.hit_offset.y
			end
		end

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
	end

	s.ts = store.tick_ts

	while store.tick_ts - s.ts < b.hit_time do
		if target and target.vis and U.flag_has(target.vis.bans, F_RANGED) then
			target = nil
		end

		update_sprite()
		coroutine.yield()
	end

	local targets

	if b.damage_radius and b.damage_radius > 0 then
		targets = U.find_soldiers_in_range(store.entities, dest, 0, b.damage_radius, b.vis_flags, b.vis_bans)
	else
		targets = {
			target
		}
	end

	if targets and b.damage_type ~= DAMAGE_NONE then
		for _, t in pairs(targets) do
			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = t.id
			d.value = math.random(b.damage_min, b.damage_max)
			d.damage_type = b.damage_type

			queue_damage(store, d)
		end
	end

	if target and b.mod then
		local mod = E:create_entity(b.mod)

		mod.modifier.target_id = target.id

		queue_insert(store, mod)
	end

	if b.hit_fx then
		SU.insert_sprite(store, b.hit_fx, b.to)
	end

	while not U.animation_finished(this) do
		update_sprite()
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.fireball = {}

function scripts.fireball.update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local tl = store.tick_length
	local ps
	local targeted_hit_offset = false
	local flight_time = b.flight_time or 0.5

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	local target = store.entities[b.target_id]

	if target then
		if b.flight_time then
			flight_time = b.flight_time
		else
			local flight_to_x, flight_to_y = target.pos.x, target.pos.y

			if band(target.vis.flags, F_FLYING) ~= 0 and target.unit and target.unit.hit_offset then
				flight_to_x, flight_to_y = flight_to_x + target.unit.hit_offset.x, flight_to_y + target.unit.hit_offset.y
			end

			local dist = V.dist(this.pos.x, this.pos.y, flight_to_x, flight_to_y)

			flight_time = dist / mspeed
		end

		if b.node_prediction then
			local node_offset = P:predict_enemy_node_advance(target, flight_time)

			b.to = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)

			if band(target.vis.flags, F_FLYING) ~= 0 and target.unit and target.unit.hit_offset then
				targeted_hit_offset = true
				b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
			end
		else
			targeted_hit_offset = true
		end
	end

	if b.g then
		b.speed = SU.initial_parabola_speed(b.from, b.to, flight_time, b.g)
		b.ts = store.tick_ts
		b.last_pos = V.vclone(b.from)
	end

	if b.emit_decal then
		local d = E:create_entity(b.emit_decal)

		d.source_id = b.source_id
		d.pos.x, d.pos.y = this.pos.x, this.pos.y
		d.to = V.vclone(b.to)
		d.flight_time = flight_time

		queue_insert(store, d)
	end

	if b.g then
		while flight_time > store.tick_ts - b.ts + store.tick_length do
			coroutine.yield()

			b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
			this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

			if this.render then
				this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
			end
		end
	else
		while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * tl do
			b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
			this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl

			if this.render then
				this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
			end

			coroutine.yield()
		end
	end

	local hit_center = V.vclone(b.to)

	if target and target.unit and target.unit.hit_offset and targeted_hit_offset then
		hit_center.y = hit_center.y - target.unit.hit_offset.y
	end

	local targets = U.find_enemies_in_range(store.entities, hit_center, 0, b.damage_radius, b.vis_flags, b.vis_bans)

	if targets then
		for _, e in pairs(targets) do
			if b.damage_type ~= DAMAGE_NONE then
				local d = SU.create_bullet_damage(b, e.id, this.id)

				d.xp_dest_id = b.source_id

				queue_damage(store, d)
			end

			if b.mod then
				local mod = E:create_entity(b.mod)

				mod.modifier.target_id = e.id
				mod.xp_dest_id = b.source_id

				queue_insert(store, mod)
			end
		end
	end

	S:queue(this.sound_events.hit)

	local fx, air_hit

	if b.hit_fx_air and target and target.vis and band(target.vis.flags, F_FLYING) ~= 0 then
		fx = E:create_entity(b.hit_fx_air)
		air_hit = true
	elseif b.hit_fx then
		fx = E:create_entity(b.hit_fx)
	end

	if fx then
		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	if b.hit_decal and not air_hit then
		fx = E:create_entity(b.hit_decal)
		fx.pos.x, fx.pos.y = b.to.x, b.to.y

		if fx.render then
			fx.render.sprites[1].ts = store.tick_ts
		end

		if fx.aura then
			fx.aura.level = b.level
		end

		if fx.tween then
			fx.tween.ts = store.tick_ts
		end

		queue_insert(store, fx)
	end

	queue_remove(store, this)
end

scripts.bullet_illusion = {}

function scripts.bullet_illusion.insert(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]

	if not target then
		return false
	end

	b.to = V.vclone(target.pos)

	return true
end

function scripts.bullet_illusion.update(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	local start_ts = store.tick_ts
	local mspeed = U.frandom(b.min_speed, b.max_speed)
	local an, af
	local missed = false
	local phase
	local a = this.animations

	if a.start then
		phase = "start"
		an, af = U.animation_name_facing_point(this, a.start, b.to)

		U.animation_start(this, an, af, store.tick_ts, false)
	else
		phase = "loop"
		an, af = U.animation_name_facing_point(this, a.loop, b.to)

		U.animation_start(this, an, af, store.tick_ts, false)
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		target = store.entities[b.target_id]

		if not target or target.health.dead then
			missed = true

			goto label_91_0
		end

		b.to.x, b.to.y = target.pos.x, target.pos.y
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		if phase ~= "attack" and V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < mspeed * this.lead_time then
			phase = "attack"
			an, af = U.animation_name_facing_point(this, a.attack, b.to)

			U.animation_start(this, an, af, store.tick_ts, false)
		elseif phase == "start" and U.animation_finished(this) then
			phase = "loop"
			an, af = U.animation_name_facing_point(this, a.loop, b.to)

			U.animation_start(this, an, af, store.tick_ts, true)
		end

		coroutine.yield()
	end

	S:queue(this.sound_events.hit)

	do
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)

		if b.mod then
			local m = E:create_entity(b.mod)

			m.modifier.target_id = target.id
			m.modifier.source_id = b.source_id

			queue_insert(store, m)
		end
	end

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)

		fx.pos = V.vclone(target.pos)

		if target.unit.hit_offset then
			fx.pos.x, fx.pos.y = fx.pos.x + target.unit.hit_offset.x, fx.pos.y + target.unit.hit_offset.y
		end

		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

		if target.unit.blood_color and fx.use_blood_color then
			fx.render.sprites[1].name = target.unit.blood_color
		end

		queue_insert(store, fx)
	end

	U.y_animation_wait(this)

	::label_91_0::

	if missed then
		S:queue(this.sound_events.miss)

		if b.miss_fx then
			local fx = E:create_entity(b.miss_fx)

			fx.pos = V.vclone(this.pos)
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)
		end

		if a.miss then
			U.animation_start(this, a_death, nil, store.tick_ts)
			U.y_animation_wait(this)
		end
	end

	if a.death then
		S:queue(this.sound_events.death)
		U.animation_start(this, a_death, nil, store.tick_ts)
		U.y_animation_wait(this)
	end

	queue_remove(store, this)
end

scripts.aura_apply_mod = {}

function scripts.aura_apply_mod.insert(this, store, script)
	this.aura.ts = store.tick_ts

	if this.render then
		for _, s in pairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end

	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]

		if target and this.render and this.aura.use_mod_offset and target.unit and target.unit.mod_offset then
			local flip_sign = target.render and target.render.sprites[1].flip_x and -1 or 1
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x * flip_sign, target.unit.mod_offset.y
		end
	end

	this.actual_duration = this.aura.duration

	if this.aura.duration_inc then
		this.actual_duration = this.actual_duration + this.aura.level * this.aura.duration_inc
	end

	return true
end

function scripts.aura_apply_mod.update(this, store, script)
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	local victims_count = 0

	if this.aura.track_source and this.aura.source_id then
		local te = store.entities[this.aura.source_id]

		if te and te.pos then
			this.pos = te.pos
		end
	end

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	if this.aura.apply_delay then
		last_hit_ts = last_hit_ts + this.aura.apply_delay
	end

	while true do
		if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration then
			break
		end

		if this.aura.stop_on_max_count and this.aura.max_count and victims_count >= this.aura.max_count then
			break
		end

		if this.aura.track_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if not te or te.health and te.health.dead and not this.aura.track_dead then
				break
			end
		end

		if this.aura.requires_magic then
			local te = store.entities[this.aura.source_id]

			if not te or not te.enemy then
				goto label_93_0
			end

			if this.render then
				this.render.sprites[1].hidden = not te.enemy.can_do_magic
			end

			if not te.enemy.can_do_magic then
				goto label_93_0
			end
		end

		if this.aura.source_vis_flags and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.vis and band(te.vis.bans, this.aura.source_vis_flags) ~= 0 then
				goto label_93_0
			end
		end

		if this.aura.requires_alive_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.health and te.health.dead then
				goto label_93_0
			end
		end

		if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration or this.interrupt then
			-- block empty
		else
			if this.render and this.aura.cast_resets_sprite_id then
				this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
			end

			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts
			cycles_count = cycles_count + 1

			local targets = table.filter(store.entities, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
			end)

			for i, target in ipairs(targets) do
				if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
					break
				end

				if this.aura.max_count and victims_count >= this.aura.max_count then
					break
				end

				local mods = this.aura.mods or {
					this.aura.mod
				}

				for _, mod_name in pairs(mods) do
					local new_mod = E:create_entity(mod_name)

					new_mod.modifier.level = this.aura.level
					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						new_mod.render = nil
					end

					queue_insert(store, new_mod)

					victims_count = victims_count + 1
				end
			end
		end

		::label_93_0::

		coroutine.yield()
	end

	signal.emit("aura-apply-mod-victims", this, victims_count)
	queue_remove(store, this)
end

scripts.aura_apply_damage = {}

function scripts.aura_apply_damage.update(this, store, script)
	this.aura.ts = store.tick_ts

	local last_hit_ts = 0
	local cycles_count = 0

	while true do
		if this.aura.cycles then
			if cycles_count >= this.aura.cycles then
				break
			end
		elseif this.aura.duration >= 0 and store.tick_ts - this.aura.ts >= this.aura.duration + this.aura.level * this.aura.duration_inc then
			break
		end

		if this.aura.track_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if not te or te.health and te.health.dead then
				queue_remove(store, this)

				return
			end

			if te and te.pos then
				this.pos.x, this.pos.y = te.pos.x, te.pos.y
			end
		end

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			cycles_count = cycles_count + 1
			last_hit_ts = store.tick_ts

			local targets = table.filter(store.entities, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.excluded_entities or not table.contains(this.aura.excluded_entities, v.id))
			end)

			for _, target in pairs(targets) do
				local d = E:create_entity("damage")

				d.source_id = this.id
				d.target_id = target.id

				local dmin, dmax = this.aura.damage_min, this.aura.damage_max

				if this.aura.damage_inc then
					dmin = dmin + this.aura.damage_inc * this.aura.level
					dmax = dmax + this.aura.damage_inc * this.aura.level
				end

				d.value = math.random(dmin, dmax)
				d.damage_type = this.aura.damage_type
				d.track_damage = this.aura.track_damage
				d.xp_dest_id = this.aura.xp_dest_id
				d.xp_gain_factor = this.aura.xp_gain_factor

				queue_damage(store, d)

				local mods = this.aura.mods or {
					this.aura.mod
				}

				for _, mod_name in pairs(mods) do
					local m = E:create_entity(mod_name)

					m.modifier.level = this.aura.level
					m.modifier.target_id = target.id
					m.modifier.source_id = this.id

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						m.render = nil
					end

					queue_insert(store, m)
				end
			end
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.aura_unit_regen = {}

function scripts.aura_unit_regen.update(this, store)
	while true do
		local target = store.entities[this.aura.source_id]

		if not target or target.health.dead then
			queue_remove(store, this)

			return
		end

		local regen_cooldown = target.regen and target.regen.cooldown or this.regen.cooldown
		local regen_health = target.regen and target.regen.health or this.regen.health

		if regen_cooldown > store.tick_ts - this.aura.ts then
			-- block empty
		elseif (this.regen.ignore_stun or not target.unit.is_stunned) and (this.regen.ignore_freeze or not U.has_modifier_types(store, target, MOD_TYPE_FREEZE)) and (this.regen.ignore_mods or not U.flag_has(target.vis.bans, F_MOD)) then
			this.aura.ts = this.aura.ts + regen_cooldown
			target.health.hp = target.health.hp + regen_health
			target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp)
		else
			this.aura.ts = store.tick_ts
		end

		coroutine.yield()
	end
end

scripts.aura_hero_regen = {}

function scripts.aura_hero_regen.update(this, store)
	local owner = store.entities[this.aura.source_id]
	local regen = owner.regen

	while true do
		if regen.is_idle and store.tick_ts - regen.last_hit_ts > regen.last_hit_standoff_time then
			regen.ts_counter = regen.ts_counter + store.tick_length

			if regen.ts_counter > regen.cooldown then
				if owner.health.hp < owner.health.hp_max then
					owner.health.hp = km.clamp(0, owner.health.hp_max, owner.health.hp + owner.regen.health)

					signal.emit("health-regen", owner, regen.health)
				end

				regen.ts_counter = 0
			end
		end

		coroutine.yield()
	end
end

scripts.tunnel = {}

function scripts.tunnel.update(this, store, script)
	local tu = this.tunnel

	if not tu.pick_ni then
		tu.pick_ni = P:get_end_node(tu.pick_pi) - 1
	end

	if not tu.place_ni then
		tu.place_ni = 1
	end

	local pf = P:node_pos(tu.pick_pi, 1, tu.pick_ni)
	local pt = P:node_pos(tu.place_pi, 1, tu.place_ni)
	local length = V.dist(pf.x, pf.y, pt.x, pt.y)
	local picked_enemies = tu.picked_enemies

	tu.length = length

	while true do
		local enemies = table.filter(store.entities, function(_, e)
			return e and e.enemy and not e.health.dead and e.main_script and e.main_script.co ~= nil and e.nav_path and e.nav_path.pi == tu.pick_pi and e.nav_path.ni >= tu.pick_ni
		end)

		for _, enemy in pairs(enemies) do
			if tu.pick_fx then
				local fx = E:create_entity(tu.pick_fx)

				fx.pos = V.v(enemy.pos.x, enemy.pos.y)
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)
			end

			local release_ts = store.tick_ts + length / (tu.speed_factor * enemy.motion.max_speed)

			log.debug("tunnel %s picked %s", this.id, enemy.id)
			table.insert(picked_enemies, {
				release_ts = release_ts,
				entity = enemy
			})
			SU.remove_modifiers(store, enemy)
			SU.remove_auras(store, enemy)
			queue_remove(store, enemy)
			U.unblock_all(store, enemy)

			if enemy.ui then
				enemy.ui.can_click = false
			end

			enemy.main_script.co = nil
			enemy.main_script.runs = 0

			if enemy.count_group then
				enemy.count_group.in_limbo = true
			end
		end

		for i = #picked_enemies, 1, -1 do
			local p = picked_enemies[i]

			if p.release_ts > store.tick_ts then
				-- block empty
			else
				local enemy = p.entity

				enemy.nav_path.pi = tu.place_pi
				enemy.nav_path.ni = tu.place_ni
				enemy.pos = P:node_pos(enemy.nav_path)
				enemy.main_script.runs = 1

				if enemy.ui then
					enemy.ui.can_click = true
				end

				queue_insert(store, enemy)
				table.remove(picked_enemies, i)

				if tu.place_fx then
					local fx = E:create_entity(tu.place_fx)

					fx.pos = V.v(enemy.pos.x, enemy.pos.y)
					fx.render.sprites[1].ts = store.tick_ts

					queue_insert(store, fx)
				end

				log.debug("tunnel %s placed %s", this.id, enemy.id)
			end
		end

		coroutine.yield()
	end
end

scripts.decal_tunnel_light = {}

function scripts.decal_tunnel_light.update(this, store, script)
	if this.track_names then
		if not this.track_ids then
			this.track_ids = {}
		end

		for _, e in pairs(E:filter(store.entities, "tunnel")) do
			if table.contains(this.track_names, e.tunnel.name) then
				table.insert(this.track_ids, e.id)
			end
		end
	end

	while true do
		local empty = true

		for _, id in pairs(this.track_ids) do
			local e = store.entities[id]

			if #e.tunnel.picked_enemies > 0 then
				empty = false

				break
			end
		end

		this.render.sprites[1].hidden = empty

		coroutine.yield()
	end
end

scripts.loop_sound_aura = {}

function scripts.loop_sound_aura.update(this, store)
	while true do
		local target = store.entities[this.aura.source_id]

		if not target or target.health.dead or not target.motion then
			queue_remove(store, this)

			return
		end

		S:queue(this.sound_name)
		U.y_wait(store, this.loop_delay)
		coroutine.yield()
	end
end

scripts.aura_screen_shake = {}

function scripts.aura_screen_shake.update(this, store)
	local a = this.aura
	local start_ts = store.tick_ts
	local fx, fy, fy2 = 10 * a.freq_factor, 8 * a.freq_factor, 20 * a.freq_factor
	local sx, sy, sy2 = 12, 9, 9
	local phase = math.random(0, 2 * math.pi)

	while store.tick_ts - start_ts < a.duration do
		local t = store.tick_ts - start_ts
		local fade = km.clamp(0, 1, 1 - t / a.duration) * a.amplitude
		local wox = math.sin(t * fx + phase) * sx * fade
		local woy = math.sin(t * fy + phase) * sy * fade + math.cos(t * fy2) * sy2 * fade

		store.world_offset = V.v(wox, woy)

		coroutine.yield()
	end

	store.world_offset = nil

	queue_remove(store, this)
end

scripts.mod_mark_flags = {}

function scripts.mod_mark_flags.queue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	local mf = this.mark_flags

	if insertion then
		mf._pushed_bans = U.push_bans(target.vis, mf.vis_bans)
	elseif mf._pushed_bans then
		U.pop_bans(target.vis, mf._pushed_bans)

		mf._pushed_bans = nil
	end
end

function scripts.mod_mark_flags.dequeue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	local mf = this.mark_flags

	if insertion and mf._pushed_bans then
		U.pop_bans(target.vis, mf._pushed_bans)

		mf._pushed_bans = nil
	end
end

function scripts.mod_mark_flags.update(this, store, script)
	local m = this.modifier

	m.ts = store.tick_ts

	while true do
		local target = store.entities[m.target_id]

		if not target or target.health and target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration then
			queue_remove(store, this)

			return
		end

		coroutine.yield()
	end
end

scripts.mod_track_target = {}

function scripts.mod_track_target.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or target.health.dead then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)

		return false
	end

	if target and target.unit and this.render then
		for i = 1, #this.render.sprites do
			local s = this.render.sprites[i]

			if target.render then
				s.flip_x = target.render.sprites[1].flip_x
			end
			s.ts = store.tick_ts

			if s.size_names then
				s.name = s.size_names[target.unit.size]
			end
		end
	end

	return true
end

function scripts.mod_track_target.update(this, store, script)
	local m = this.modifier

	this.modifier.ts = store.tick_ts

	local target = store.entities[m.target_id]

	if not target or not target.pos then
		queue_remove(store, this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and target.nav_path.ni > m.last_node then
			queue_remove(store, this)

			return
		end

		if this.render and target.unit then
			local s = this.render.sprites[1]
			local flip_sign = 1

			if not s._original_offset then
				s._original_offset = V.vclone(s.offset)
			end
			if target.render then
				flip_sign = target.render.sprites[1].flip_x and -1 or 1
			end

			if m.health_bar_offset and target.health_bar then
				local hb = target.health_bar.offset
				local hbo = m.health_bar_offset
				s.offset.x, s.offset.y = hb.x + (s._original_offset.x + hbo.x) * flip_sign, hb.y + hbo.y + s._original_offset.y
			elseif m.use_mod_offset and target.unit.mod_offset then
				s.offset.x, s.offset.y = (s._original_offset.x + target.unit.mod_offset.x) * flip_sign, target.unit.mod_offset.y + s._original_offset.y
			end
		end

		coroutine.yield()
	end
end

scripts.mod_freeze = {}

function scripts.mod_freeze.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return false
	end

	if band(target.vis.flags, this.modifier.vis_bans) ~= 0 then
		return false
	end

	this._entity_frame_names = {}

	for _, es in pairs(target.render.sprites) do
		if es.animated then
			table.insert(this._entity_frame_names, es.frame_name)
		else
			table.insert(this._entity_frame_names, es.name)
		end
	end

	SU.stun_inc(target)

	if this.render then
		local s = this.render.sprites[1]

		if this.custom_suffixes then
			if this.custom_suffixes.flying and band(target.vis.flags, F_FLYING) ~= 0 then
				s.prefix = s.prefix .. this.custom_suffixes.flying
				s.offset = this.custom_offsets.flying
			else
				s.prefix = s.prefix .. "_ground"
			end
		end

		if this.custom_offsets then
			local co = this.custom_offsets[target.template_name]

			if co then
				s.offset = co
			end
		end

		s.offset.x = s.flip_x and -s.offset.x or s.offset.x
	end

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_freeze.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	m.ts = store.tick_ts
	this.pos.x, this.pos.y = target.pos.x, target.pos.y

	if this.render then
		if this.custom_animations then
			U.animation_start(this, this.custom_animations[1], nil, store.tick_ts)
		else
			this.render.sprites[1].ts = store.tick_ts
		end
	end

	coroutine.yield()

	local es = E:create_entity(this.freeze_decal_name)

	this._decal_freeze = es
	es.pos.x, es.pos.y = target.pos.x, target.pos.y
	es.render.sprites[1] = table.deepclone(target.render.sprites[1])
	local sprite1 = es.render.sprites[1]
	sprite1.shader = es.shader
	sprite1.shader_args = es.shader_args
	sprite1.animated = false
	sprite1.prefix = nil
	sprite1.name = this._entity_frame_names[1]

	queue_insert(store, es)
	coroutine.yield()
	U.sprites_hide(target, nil, nil, true)

	while target and not target.health.dead and store.tick_ts - m.ts < m.duration do
		this.pos.x, this.pos.y = target.pos.x, target.pos.y
		es.pos.x, es.pos.y = target.pos.x, target.pos.y

		if this.render then
			es.render.sprites[1].hidden = this.render.sprites[1].hidden
		end

		coroutine.yield()

		target = store.entities[m.target_id]
	end

	if target then
		if not target.health.dead or not target.unit.hide_during_death then
			U.sprites_show(target, nil, nil, true)
		end

		SU.stun_dec(target)
	end

	queue_remove(store, es)

	this._not_interrupted = true

	if this.render and this.custom_animations then
		U.y_animation_play(this, this.custom_animations[2], nil, store.tick_ts)
	end

	queue_remove(store, this)
end

function scripts.mod_freeze.remove(this, store)
	if this._not_interrupted then
		log.debug("NOT INTERRUPTED")

		return true
	end

	log.debug("INTERRUPTED")

	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		if not target.health.dead or not target.unit.hide_during_death then
			U.sprites_show(target, nil, nil, true)
		end

		SU.stun_dec(target)
	end

	if this._decal_freeze then
		queue_remove(store, this._decal_freeze)
	end

	return true
end

scripts.mod_stun = {}

function scripts.mod_stun.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or target.health.dead then
		return false
	end

	if target.vis and not U.flags_pass(target.vis, this.modifier) then
		-- log.error("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)

		return false
	end

	if target and target.unit and this.render then
		for i = 1, #this.render.sprites do
			local s = this.render.sprites[i]

			if not s.keep_flip_x and target.render then
				s.flip_x = target.render.sprites[1].flip_x
			end

			if s.size_names then
				s.prefix = s.prefix .. "_" .. s.size_names[target.unit.size]
			end

			if s.size_anchors then
				s.anchor = s.size_anchors[target.unit.size]
			end

			if m.custom_scales then
				s.scale = V.vclone(m.custom_scales[target.template_name] or m.custom_scales.default)
			end

			if m.custom_offsets then
				s.offset = V.vclone(m.custom_offsets[target.template_name] or m.custom_offsets.default)
				s.offset.x = s.offset.x * (s.flip_x and -1 or 1)
			elseif m.health_bar_offset then
				local hb = target.health_bar.offset
				local hbo = m.health_bar_offset

				s.offset.x, s.offset.y = hb.x + hbo.x, hb.y + hbo.y
			elseif m.use_mod_offset and target.unit.mod_offset then
				s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
			end
		end
	end

	m.ts = store.tick_ts

	if target.hero and m.duration_heroes then
		m.duration = m.duration_heroes
	end

	SU.stun_inc(target)
	log.paranoid("mod_stun.insert (%s)-%s for target (%s)-%s", this.id, this.template_name, target.id, target.template_name)
	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_stun.update(this, store, script)
	local start_ts, target_hidden
	local m = this.modifier
	local target = store.entities[this.modifier.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	this.pos = target.pos
	start_ts = store.tick_ts

	if m.animation_phases then
		U.animation_start(this, "start", nil, store.tick_ts)

		while not U.animation_finished(this) do
			if not target_hidden and m.hide_target_delay and store.tick_ts - start_ts > m.hide_target_delay then
				target_hidden = true

				if target.ui then
					target.ui.can_click = false
				end

				if target.health_bar then
					target.health_bar.hidden = true
				end

				U.sprites_hide(target, nil, nil, true)
				SU.hide_modifiers(store, target, true, this)
				SU.hide_auras(store, target, true)
			end

			coroutine.yield()
		end
	end

	U.animation_start(this, "loop", nil, store.tick_ts, true)

	while store.tick_ts - m.ts < m.duration and target and not target.health.dead do
		if this.render and m.use_mod_offset and target.unit.mod_offset and not m.custom_offsets then
			for i = 1, #this.render.sprites do
				local s = this.render.sprites[i]

				s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
			end
		end

		coroutine.yield()
	end

	if m.animation_phases then
		U.animation_start(this, "end", nil, store.tick_ts)

		if target_hidden then
			if target.ui then
				target.ui.can_click = true
			end

			if target.health_bar and not target.health.dead then
				target.health_bar.hidden = nil
			end

			U.sprites_show(target, nil, nil, true)
			SU.show_modifiers(store, target, true, this)
			SU.show_auras(store, target, true)
		end

		while not U.animation_finished(this) do
			coroutine.yield()
		end
	end

	queue_remove(store, this)
end

function scripts.mod_stun.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target then
		SU.stun_dec(target)
		log.paranoid("mod_stun.remove (%s)-%s for target (%s)-%s", this.id, this.template_name, target.id, target.template_name)
	else
		log.paranoid("mod_stun.remove target is nil for id %s", this.modifier.target_id)
	end

	return true
end

scripts.mod_dps = {}

function scripts.mod_dps.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)

		return false
	end

	if target and target.unit and this.render then
		local s = this.render.sprites[1]

		s.ts = store.tick_ts

		if s.size_names then
			s.name = s.size_names[target.unit.size]
		end

		if s.size_scales then
			s.scale = s.size_scales[target.unit.size]
		end

		if target.render then
			s.z = target.render.sprites[1].z
		end
	end

	this.dps.ts = store.tick_ts - this.dps.damage_every
	this.modifier.ts = store.tick_ts

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_dps.update(this, store, script)
	local cycles, total_damage = 0, 0
	local m = this.modifier
	local dps = this.dps
	local dmin = dps.damage_min + m.level * dps.damage_inc
	local dmax = dps.damage_max + m.level * dps.damage_inc
	local fx_ts = 0

	local function do_damage(target, value)
		total_damage = total_damage + value

		local d = E:create_entity("damage")

		d.source_id = this.id
		d.target_id = target.id
		d.value = value
		d.damage_type = dps.damage_type
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds

		queue_damage(store, d)
	end

	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead then
			break
		end

		if store.tick_ts - m.ts >= m.duration - 1e-09 then
			if dps.damage_last then
				do_damage(target, dps.damage_last)
			end

			break
		end

		if this.render and m.use_mod_offset and target.unit.mod_offset then
			local so = this.render.sprites[1].offset

			so.x, so.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		if dps.damage_every and store.tick_ts - dps.ts >= dps.damage_every then
			cycles = cycles + 1
			dps.ts = dps.ts + dps.damage_every

			local damage_value = math.random(dmin, dmax)

			if cycles == 1 and dps.damage_first then
				damage_value = dps.damage_first
			end

			if not dps.kill then
				damage_value = km.clamp(0, target.health.hp - 1, damage_value)
			end

			do_damage(target, damage_value)

			if dps.fx and (not dps.fx_every or store.tick_ts - fx_ts >= dps.fx_every) then
				fx_ts = store.tick_ts

				local fx = E:create_entity(dps.fx)

				if dps.fx_tracks_target then
					fx.pos = target.pos

					if m.use_mod_offset and target.unit.mod_offset then
						fx.render.sprites[1].offset.x = target.unit.mod_offset.x
						fx.render.sprites[1].offset.y = target.unit.mod_offset.y
					end
				else
					fx.pos = V.vclone(this.pos)

					if m.use_mod_offset and target.unit.mod_offset then
						fx.pos.x, fx.pos.y = fx.pos.x + target.unit.mod_offset.x, fx.pos.y + target.unit.mod_offset.y
					end
				end

				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[1].runs = 0

				if fx.render.sprites[1].size_names then
					fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
				end

				if fx.render.sprites[1].use_blood_color and target.unit.blood_color then
					fx.render.sprites[1].name = fx.render.sprites[1].name .. "_" .. target.unit.blood_color
				end

				if dps.fx_target_flip and target and target.render then
					fx.render.sprites[1].flip_x = target.render.sprites[1].flip_x
				end

				queue_insert(store, fx)
			end
		end

		coroutine.yield()
	end

	log.paranoid(">>>>> id:%s - mod_dps cycles:%s total_damage:%s", this.id, cycles, total_damage)
	queue_remove(store, this)
end

scripts.mod_hps = {}

function scripts.mod_hps.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	if target.health.hp == target.health.hp_max then
		return false
	end

	if this.render and target.unit then
		for _, s in pairs(this.render.sprites) do
			s.ts = store.tick_ts
			if s.size_names then
				s.name = s.size_names[target.unit.size]
			end
			if s.size_scales then
				s.scale = s.size_scales[target.unit.size]
			end
		end
	end

	this.hps.ts = store.tick_ts - this.hps.heal_every
	this.modifier.ts = store.tick_ts

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_hps.update(this, store, script)
	local m = this.modifier
	local hps = this.hps
	local duration = m.duration

	if m.duration_inc then
		duration = duration + m.level * m.duration_inc
	end

	local heal_min = hps.heal_min
	local heal_max = hps.heal_max

	if hps.heal_min_inc and hps.heal_max_inc then
		heal_min = hps.heal_min + m.level * hps.heal_min_inc
		heal_max = hps.heal_max + m.level * hps.heal_max_inc
	end

	if hps.heal_inc then
		heal_min = hps.heal_min + m.level * hps.heal_inc
		heal_max = hps.heal_max + m.level * hps.heal_inc
	end

	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or duration < store.tick_ts - m.ts then
			queue_remove(store, this)

			return
		end

		if this.render and m.use_mod_offset and target.unit.mod_offset then
			for i = 1, #this.render.sprites do
				local s = this.render.sprites[i]

				if not s.exclude_mod_offset then
					s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
				end
			end
		end

		if hps.heal_every and store.tick_ts - hps.ts >= hps.heal_every then
			hps.ts = store.tick_ts

			local hp_start = target.health.hp

			target.health.hp = target.health.hp + math.random(heal_min, heal_max)
			target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp)

			local heal_amount = target.health.hp - hp_start

			target.health.hp_healed = (target.health.hp_healed or 0) + heal_amount

			signal.emit("entity-healed", this, target, heal_amount)

			if hps.fx then
				local fx = E:create_entity(hps.fx)

				fx.pos = V.vclone(this.pos)
				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[1].runs = 0

				queue_insert(store, fx)
			end
		end

		coroutine.yield()
	end
end

scripts.mod_armor_buff = {}

function scripts.mod_armor_buff.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or target.enemy and not target.enemy.can_accept_magic then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)

		return false
	end

	local buff = this.armor_buff
	local inc = buff.max_factor

	if buff.magic then
		if buff.factor then
			inc = buff.factor * target.health.magic_armor
		end

		SU.magic_armor_inc(target, inc)
	else
		if buff.factor then
			inc = buff.factor * target.health.armor
		end

		SU.armor_inc(target, inc)
	end

	buff._total_factor = inc

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_armor_buff.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target then
		local buff = this.armor_buff

		if buff.magic then
			SU.magic_armor_dec(target, buff._total_factor)
		else
			SU.armor_dec(target, buff._total_factor)
		end
	end

	return true
end

function scripts.mod_armor_buff.update(this, store, script)
	local buff = this.armor_buff
	local m = this.modifier
	local last_ts = store.tick_ts
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or store.tick_ts - m.ts >= m.duration then
			queue_remove(store, this)

			return
		end

		if this.render and m.use_mod_offset and target.unit.mod_offset then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		if store.tick_ts - last_ts > buff.cycle_time then
			last_ts = store.tick_ts

			if buff.magic and target.health.magic_armor < buff.max_factor then
				SU.magic_armor_inc(target, buff.step_factor)

				buff._total_factor = buff._total_factor + buff.step_factor
			elseif not buff.magic and target.health.armor < buff.max_factor then
				SU.armor_inc(target, buff.step_factor)

				buff._total_factor = buff._total_factor + buff.step_factor
			end
		end

		coroutine.yield()
	end
end

scripts.mod_silence = {}

function scripts.mod_silence.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.enemy then
		return false
	end

	target.enemy.can_do_magic = false
	target.enemy.can_accept_magic = false

	local s = this.render.sprites[1]

	s.ts = store.tick_ts

	if s.size_names then
		s.name = s.size_names[target.unit.size]
	end

	if this.custom_offsets then
		s.offset = V.vclone(this.custom_offsets[target.template_name] or band(target.vis.flags, F_FLYING) ~= 0 and this.custom_offsets.flying or this.custom_offsets.default)
		s.offset.x = s.offset.x * (s.flip_x and -1 or 1)

		if target.unit and target.unit.mod_offset and this.modifier.use_mod_offset then
			s.offset.x = s.offset.x + target.unit.mod_offset.x
			s.offset.y = s.offset.y + target.unit.mod_offset.y
		end
	end

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_silence.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target and target.enemy then
		target.enemy.can_do_magic = true
		target.enemy.can_accept_magic = true
	end

	return true
end

scripts.mod_damage_factors = {}

function scripts.mod_damage_factors.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.unit then
		return false
	end

	if this.received_damage_factor then
		target.health.damage_factor = target.health.damage_factor * this.received_damage_factor
	end

	if this.inflicted_damage_factor then
		target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor
	end

	if IS_KR5 and (band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0) then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)

		return false
	end

	if this.render then
		for _, s in pairs(this.render.sprites) do
			s.ts = store.tick_ts

			if s.size_names then
				s.name = s.size_names[target.unit.size]
			end

			if s.size_scales then
				s.scale = s.size_scales[target.unit.size]
			end
		end
	end

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_damage_factors.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target and target.health and target.unit then
		if this.received_damage_factor then
			target.health.damage_factor = target.health.damage_factor / this.received_damage_factor
		end

		if this.inflicted_damage_factor then
			target.unit.damage_factor = target.unit.damage_factor / this.inflicted_damage_factor
		end
	end

	return true
end

scripts.mod_slow = {}

function scripts.mod_slow.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.motion or target.motion.invulnerable then
		return false
	end

	if this.modifier.excluded_templates and table.contains(this.modifier.excluded_templates, target.template_name) then
		log.paranoid("mod_slow.insert not inserted to %s because of excluded_templates", target.id)

		return false
	end

	log.paranoid("mod_slow.insert (%s)-%s for (%s)-%s", this.id, this.template_name, target.id, target.template_name)

	target.motion.max_speed = target.motion.max_speed * this.slow.factor
	this.modifier.ts = store.tick_ts

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_slow.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target and target.health and target.motion then
		target.motion.max_speed = target.motion.max_speed / this.slow.factor

		log.paranoid("mod_slow.remove (%s)-%s for (%s)-%s", this.id, this.template_name, target.id, target.template_name)
	else
		log.debug("mod_slow.remove target is nil for id %s", this.modifier.target_id)
	end

	return true
end

scripts.mod_tower_factors = {}

function scripts.mod_tower_factors.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.tower then
		if not target then
			log.error("cannot insert mod_tower_factors, target not found")
		elseif not target.tower then
			log.error("cannot insert mod_tower_factors to entity %s - ", target.id, target.template_name)
		end

		return false
	end

	if this.range_factor then
		if target.attacks then
			target.attacks.range = target.attacks.range * this.range_factor
		end

		if target.barrack then
			target.barrack.rally_range = target.barrack.rally_range * this.range_factor
		end
	end

	if this.damage_factor then
		target.tower.damage_factor = target.tower.damage_factor * this.damage_factor
	end

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_tower_factors.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.tower then
		log.error("error removing mod_tower_factors %s", this.id)

		return true
	end

	if this.range_factor then
		if target.attacks then
			target.attacks.range = target.attacks.range / this.range_factor
		end

		if target.barrack then
			target.barrack.rally_range = target.barrack.rally_range / this.range_factor
		end
	end

	if this.damage_factor then
		target.tower.damage_factor = target.tower.damage_factor / this.damage_factor
	end

	return true
end

function scripts.mod_tower_factors.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		this.pos = target.pos
	end

	m.ts = store.tick_ts

	if this.tween then
		this.tween.ts = store.tick_ts
	end

	while store.tick_ts - m.ts < m.duration do
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.mod_tower_block = {}

function scripts.mod_tower_block.update(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	m.ts = store.tick_ts

	SU.tower_block_inc(target)
	U.animation_start(this, "start", nil, store.tick_ts, false)
	U.y_wait(store, 0.1)

	if m.hide_tower then
		U.sprites_hide(target, nil, nil, true)
	end

	U.y_animation_wait(this)
	U.animation_start(this, "loop", nil, store.tick_ts, true)
	U.y_wait(store, m.duration - (store.tick_ts - m.ts))
	S:queue(this.sound_events.finish)
	U.animation_start(this, "end", nil, store.tick_ts, false)
	U.y_wait(store, 0.1)

	if m.hide_tower then
		U.sprites_show(target, nil, nil, true)
	end

	U.y_animation_wait(this)
	SU.tower_block_dec(target)
	queue_remove(store, this)
end

scripts.mod_tower_silence = {}

function scripts.mod_tower_silence.update(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.tower then
		queue_remove(store, this)

		return
	end

	m.ts = store.tick_ts

	if this.tween then
		this.tween.ts = store.tick_ts
	end

	if this.render and this.custom_offsets then
		local co = this.custom_offsets[target.template_name]

		if co then
			for _, s in pairs(this.render.sprites) do
				s.offset.x, s.offset.y = s.offset.x + co.x, s.offset.y + co.y
			end
		end
	end

	target.tower.can_do_magic = false

	while store.tick_ts - m.ts < m.duration do
		coroutine.yield()

		if not store.entities[m.target_id] then
			break
		end
	end

	target.tower.can_do_magic = true

	queue_remove(store, this)
end

scripts.mod_tower_remove = {}

function scripts.mod_tower_remove.update(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		m.ts = store.tick_ts
		this.pos = target.pos

		SU.tower_block_inc(target)
		U.animation_start(this, nil, nil, store.tick_ts, false)

		while store.tick_ts - m.ts < m.hide_time do
			coroutine.yield()
		end

		target.tower.destroy = true

		U.y_animation_wait(this)

		local mods = table.filter(store.entities, function(_, ee)
			return ee.modifier and ee.modifier.target_id == target.id
		end)

		for _, mod in pairs(mods) do
			queue_remove(store, mod)
		end
	end

	queue_remove(store, this)
end

scripts.mod_heal_on_damage = {}

function scripts.mod_heal_on_damage.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return false
	end

	if not target.track_damage then
		log.error("Entity %s has no track_damage component, so mod_heal_on_damage cannot be used", target.id)

		return false
	end

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_heal_on_damage.update(this, store)
	local m = this.modifier
	local hf = this.heal_factor or 1
	local target = store.entities[m.target_id]

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead then
			queue_remove(store, this)

			return
		end

		if this.render and m.use_mod_offset and target.unit.mod_offset then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		local has_damaged = false

		for _, v in pairs(target.track_damage.damaged) do
			local e_id, actual_damage = unpack(v)

			if actual_damage > 0 then
				target.health.hp = target.health.hp + hf * actual_damage
			end

			has_damaged = true
		end

		if has_damaged then
			target.track_damage.damaged = {}
			target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp)

			if this.heal_remove_modifiers then
				for _, n in pairs(this.heal_remove_modifiers) do
					SU.remove_modifiers(store, target, n)
				end
			end

			if this.render then
				this.render.sprites[1].ts = store.tick_ts
				this.render.sprites[1].hidden = false
			end
		end

		coroutine.yield()
	end
end

scripts.mod_heal_on_kill = {}

function scripts.mod_heal_on_kill.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return false
	end

	if not target.track_kills then
		log.error("Entity %s has no track_kills component, so mod_heal_on_kill cannot be used", target.id)

		return false
	end

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_heal_on_kill.update(this, store, script)
	local m = this.modifier
	local hok = this.heal_on_kill
	local target = store.entities[m.target_id]

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead then
			queue_remove(store, this)

			return
		end

		if this.render and m.use_mod_offset and target.unit.mod_offset then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		local has_kills = false

		for _, kid in pairs(target.track_kills.killed) do
			if hok.hp then
				target.health.hp = target.health.hp + hok.hp
			end

			has_kills = true
		end

		if has_kills then
			target.track_kills.killed = {}
			target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp)

			if this.render then
				this.render.sprites[1].ts = store.tick_ts
				this.render.sprites[1].hidden = false
			end
		end

		coroutine.yield()
	end
end

scripts.mod_simple_lifesteal = {}

function scripts.mod_simple_lifesteal.insert(this, store, script)
	local source = store.entities[this.modifier.source_id]

	if source and source.health then
		source.health.hp = km.clamp(0, source.health.hp_max, source.health.hp + this.heal_hp)
	end

	return false
end

scripts.mod_damage = {}

function scripts.mod_damage.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	local d = E:create_entity("damage")

	d.value = math.random(this.damage_min, this.damage_max)
	d.source_id = this.id
	d.target_id = target.id
	d.damage_type = this.damage_type

	queue_damage(store, d)

	return false
end

scripts.mod_teleport = {}

function scripts.mod_teleport.queue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		log.debug("%s (%s) queue/insertion", this.template_name, this.id)

		if U.flags_pass(target.vis, this.modifier) then
			this._pushed_bans = U.push_bans(target.vis, F_ALL)
		end
	else
		log.debug("%s (%s) queue/removal", this.template_name, this.id)

		if this._pushed_bans then
			U.pop_bans(target.vis, this._pushed_bans)

			this._pushed_bans = nil
		end
	end
end

function scripts.mod_teleport.dequeue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		log.debug("%s (%s) dequeue/insertion", this.template_name, this.id)

		if this._pushed_bans then
			U.pop_bans(target.vis, this._pushed_bans)

			this._pushed_bans = nil
		end
	end
end

function scripts.mod_teleport.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if target and target.enemy and target.health and not target.health.dead and this._pushed_bans ~= nil and (not this.max_times_applied or not target.enemy.counts.mod_teleport or target.enemy.counts.mod_teleport < this.max_times_applied) and (not this.jump_connection or P:get_next_pi(target.nav_path.pi)) then
		-- target.health.ignore_damage = true

		SU.stun_inc(target)

		return true
	else
		return false
	end
end

function scripts.mod_teleport.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		target.health.ignore_damage = false

		SU.stun_dec(target)
	end

	return true
end

function scripts.mod_teleport.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		queue_remove(store, this)

		return
	end

	if this.max_times_applied then
		if not target.enemy.counts.mod_teleport then
			target.enemy.counts.mod_teleport = 0
		end

		target.enemy.counts.mod_teleport = target.enemy.counts.mod_teleport + 1
	end

	local fx = E:create_entity(this.fx_start)

	if fx.render.sprites[1].size_names and target.unit then
		fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
	end

	if fx.render.sprites[1].size_scales then
		fx.render.sprites[1].scale = fx.render.sprites[1].size_scales[target.unit.size]
	end

	fx.pos.x, fx.pos.y = target.pos.x, target.pos.y

	if m.use_mod_offset then
		fx.pos.x, fx.pos.y = fx.pos.x + target.unit.mod_offset.x, fx.pos.y + target.unit.mod_offset.y
	end

	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	if this.delay_start then
		U.y_wait(store, this.delay_start)
	end

	local health_bar_hidden

	U.unblock_all(store, target)

	if target.ui then
		target.ui.can_click = false
	end

	if target.health_bar then
		health_bar_hidden = target.health_bar.hidden
		target.health_bar.hidden = true
	end

	U.sprites_hide(target, nil, nil, true)
	SU.hide_modifiers(store, target, true)
	SU.hide_auras(store, target, true)
	U.y_wait(store, this.hold_time)

	if target.motion then
		target.motion.forced_waypoint = nil
	end

	if this.jump_connection then
		target.nav_path.prev_pis = target.nav_path.prev_pis or {}

		table.insert(target.nav_path.prev_pis, target.nav_path.pi)

		local npi = P:get_next_pi(target.nav_path.pi)

		target.nav_path.pi = npi
		target.nav_path.ni = 1
	else
		local n_off

		if this.nodes_offset_min and this.nodes_offset_max then
			local omin, omax = this.nodes_offset_min, this.nodes_offset_max

			if this.nodes_offset_inc then
				omin = omin + this.nodes_offset_inc * m.level
				omax = omax + this.nodes_offset_inc * m.level
			end

			n_off = math.random(omin, omax)
		else
			n_off = U.flag_has(target.vis.flags, F_BOSS) and this.boss_nodes_offset or this.nodes_offset
		end

		local n_ni = target.nav_path.ni + n_off
		local n_limit = this.nodeslimit

		if n_ni < 1 and target.nav_path.prev_pis and #target.nav_path.prev_pis > 0 then
			target.nav_path.pi = table.remove(target.nav_path.prev_pis, #target.nav_path.prev_pis)
			target.nav_path.ni = P:get_end_node(target.nav_path.pi)
			n_ni = target.nav_path.ni + n_ni
		end

		if this.dest_valid_node then
			local dpi, dni = P:find_valid_node(target.nav_path.pi, n_ni, this.dest_node_valid_dir or 1, this.dest_node_valid_flags or NF_ALL)

			if dni then
				target.nav_path.ni = dni
			end
		else
			target.nav_path.ni = km.clamp(n_limit, P:get_end_node(target.nav_path.pi) - n_limit, n_ni)
		end
	end

	local npos = P:node_pos(target.nav_path)

	target.pos.x, target.pos.y = npos.x, npos.y

	local fx = E:create_entity(this.fx_end)

	if fx.render.sprites[1].size_names and target.unit then
		fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
	end

	fx.pos.x, fx.pos.y = target.pos.x, target.pos.y

	if m.use_mod_offset then
		fx.pos.x, fx.pos.y = fx.pos.x + target.unit.mod_offset.x, fx.pos.y + target.unit.mod_offset.y
	end

	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	if this.delay_end then
		U.y_wait(store, this.delay_end)
	end

	if target.ui then
		target.ui.can_click = true
	end

	if target.health_bar then
		target.health_bar.hidden = health_bar_hidden
	end

	U.sprites_show(target, nil, nil, true)
	SU.show_modifiers(store, target, true)
	SU.show_auras(store, target, true)

	local nn, new = P:next_entity_node(target, store.tick_length)

	if nn then
		local vx, vy = V.sub(nn.x, nn.y, target.pos.x, target.pos.y)
		local v_angle = V.angleTo(vx, vy)

		if target.heading then
			target.heading.angle = v_angle
		end
	end

	signal.emit("mod-applied", this, target)
	queue_remove(store, this)
end

scripts.mod_polymorph = {}

function scripts.mod_polymorph.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or band(target.vis.bans, F_POLYMORPH) ~= 0 then
		return false
	end

	local pm = this.polymorph
	local target_gold = 0

	if pm.transfer_gold_factor then
		target_gold = target.enemy.gold
		target.enemy.gold = 0
	end

	local d = E:create_entity("damage")

	d.damage_type = bor(DAMAGE_EAT, DAMAGE_NO_LIFESTEAL)
	d.source_id = this.id
	d.target_id = target.id
	d.pop = pm.pop

	queue_damage(store, d)

	target.vis.bans = F_ALL

	if pm.hit_fx_sizes then
		local fx = E:create_entity(pm.hit_fx_sizes[target.unit.size])

		fx.pos = V.vclone(target.pos)

		if m.use_mod_offset then
			fx.pos.x, fx.pos.y = fx.pos.x + target.unit.mod_offset.x, fx.pos.y + target.unit.mod_offset.y
		end

		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].draw_order = 2

		queue_insert(store, fx)
	end

	local e_name = pm.custom_entity_names[target.template_name]
	if not e_name then
		if band(target.vis.flags, F_FLYING) ~= 0 and pm.custom_entity_names.default_flying then
			e_name = pm.custom_entity_names.default_flying
		else
			e_name = pm.custom_entity_names.default
		end
	end
	local e = E:create_entity(e_name)

	e.pos = V.vclone(target.pos)
	e.nav_path = table.deepclone(target.nav_path)

	if pm.transfer_lives_cost_factor then
		e.enemy.lives_cost = math.floor(target.enemy.lives_cost * pm.transfer_lives_cost_factor)
	end

	if pm.transfer_gold_factor then
		e.enemy.gold = math.floor(target_gold * pm.transfer_gold_factor)
	end

	if pm.transfer_health_factor then
		e.health.hp_max = math.floor(target.health.hp_max * pm.transfer_health_factor)
		e.health.hp = math.floor(target.health.hp * pm.transfer_health_factor)
	end

	if pm.transfer_speed_factor then
		e.motion.max_speed = target.motion.max_speed * pm.transfer_speed_factor

		local has, mods = U.has_modifier_types(store, target, MOD_TYPE_FAST, MOD_TYPE_SLOW)

		if has then
			for _, m in pairs(mods) do
				if m.fast then
					e.motion.max_speed = e.motion.max_speed / m.fast.factor
				elseif m.slow then
					e.motion.max_speed = e.motion.max_speed / m.slow.factor
				end
			end
		end
	end

	e._original_unit_name = target.template_name
	queue_insert(store, e)
	m.target_id = e.id
	signal.emit("mod-applied", this, target)

	if m.duration then
		return true
	end
	queue_remove(store, this)
	return false
end

function scripts.mod_polymorph.update(this, store, script)
	local m = this.modifier
	m.ts = store.tick_ts
	local target = store.entities[m.target_id]
	while true do
		if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration then
			queue_remove(store, this)
			return
		end
		coroutine.yield()
	end
end

function scripts.mod_polymorph.remove(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if target and not target.health.dead and target._original_unit_name then
		local original_unit = E:create_entity(target._original_unit_name)
		original_unit.pos = V.vclone(target.pos)
		original_unit.nav_path = table.deepclone(target.nav_path)
		original_unit.health.hp = math.ceil(target.health.hp / target.health.hp_max * original_unit.health.hp_max)
		local pm = this.polymorph
		if pm.hit_fx_sizes then
			local fx = E:create_entity(pm.hit_fx_sizes[target.unit.size])
			fx.pos = V.vclone(target.pos)
			if m.use_mod_offset then
				fx.pos.x, fx.pos.y = fx.pos.x + target.unit.mod_offset.x, fx.pos.y + target.unit.mod_offset.y
			end
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].draw_order = 2
			queue_insert(store, fx)
		end
		queue_insert(store, original_unit)
		queue_remove(store, target)
	end
	return true
end

scripts.background_sounds = {}

function scripts.background_sounds.insert(this, store, script)
	return true
end

function scripts.background_sounds.update(this, store, script)
	while true do
		local delay = math.random(this.min_delay, this.max_delay)

		U.y_wait(store, delay)
		S:queue(this.sounds[math.random(#this.sounds)])
	end
end

scripts.decal_defend_point = {}

function scripts.decal_defend_point.insert(this, store)
	local nodes_list = P:nearest_nodes(this.pos.x, this.pos.y)

	for _, item in pairs(nodes_list) do
		local pi, spi, ni, dist = unpack(item, 1, 4)

		if dist < P:path_width(pi) / 2 then
			P:set_defend_point_node(pi, ni)
		end
	end

	this.render.sprites[1].ts = store.tick_ts

	if this.editor and this.editor.exit_id then
		if not store.level.locations.exits then
			store.level.locations.exits = {}
		end

		local exits = store.level.locations.exits
		local exit = {}

		exit.pos = this.pos
		exit.exit_id = this.editor.exit_id

		table.insert(exits, exit)
		table.sort(exits, function(a1, a2)
			return a1.exit_id < a2.exit_id
		end)
	end

	return true
end

scripts.editor_rally_point = {}

function scripts.editor_rally_point.remove(this, store)
	if store.entities[this.tower_id] then
		queue_remove(store, store.entities[this.tower_id])
	end

	return true
end

function scripts.editor_rally_point.update(this, store)
	local s = this.render.sprites[2]

	s.scale = V.v(1, 1)

	while true do
		local tower = store.entities[this.tower_id]

		if tower then
			s.hidden = false
			s.r = V.angleTo(tower.pos.x - this.pos.x, tower.pos.y - this.pos.y)
			s.scale.x = V.dist(tower.pos.x, tower.pos.y, this.pos.x, this.pos.y) / this.image_width
		else
			s.hidden = true
		end

		coroutine.yield()
	end
end

scripts.editor_tower = {}

function scripts.editor_tower.insert(this, store)
	if this.render and string.find(this.render.sprites[1].name, "%%") then
		this.render.sprites[1].name = string.format(this.render.sprites[1].name, store.level_terrain_type or 1)

		if IS_KR5 then
			this.render.sprites[2].name = string.format(this.render.sprites[2].name, store.level_terrain_type or 1)
		end
	end

	local r = E:create_entity("editor_rally_point")

	queue_insert(store, r)

	r.tower_id = this.id
	this.editor.rally_point_id = r.id

	if this.tower.default_rally_pos and this.tower.default_rally_pos.x ~= 0 and this.tower.default_rally_pos.y ~= 0 then
		r.pos = this.tower.default_rally_pos
	else
		r.pos = V.v(this.pos.x + 50, this.pos.y + 50)
		this.tower.default_rally_pos = r.pos
	end

	if not this.tower.holder_id then
		this.tower.holder_id = tostring(this.id)
	end

	if this.barrack then
		this.barrack.rally_pos = r.pos
	end

	if this.tower.flip_x then
		for _, s in pairs(this.render.sprites) do
			s.flip_x = true
		end
	end

	return true
end

function scripts.editor_tower.remove(this, store)
	local r = store.entities[this.editor.rally_point_id]

	if r then
		queue_remove(store, r)
	end

	return true
end

scripts.editor_wave_flag = {}

function scripts.editor_wave_flag.editor_update(this, store)
	local s = this.render.sprites[2]
	local s3 = this.render.sprites[3]

	s3.scale = V.v(1, 1)

	while true do
		local px, py = this.editor.len * math.cos(this.editor.r), this.editor.len * math.sin(this.editor.r)

		s.offset.x, s.offset.y = px, py
		s.r = this.editor.r
		s3.scale.x = this.editor.len / s3._width
		s3.r = this.editor.r

		coroutine.yield()
	end
end

function scripts.editor_wave_flag.insert(this, store)
	if not store.level.locations.entrances then
		store.level.locations.entrances = {}
	end

	local entrances = store.level.locations.entrances
	local entrance = {}

	entrance.pos = this.pos
	entrance.r = this.editor.r
	entrance.len = this.editor.len
	entrance.path_id = this.editor.path_id

	table.insert(entrances, entrance)
	table.sort(entrances, function(a1, a2)
		return a1.path_id < a2.path_id
	end)

	return false
end

scripts.mega_spawner = {}

function scripts.mega_spawner.insert(this, store)
	if this.load_file then
		local fn = KR_PATH_GAME .. "/data/levels/" .. this.load_file .. ".lua"

		if not love.filesystem.isFile(fn) then
			log.error("mega_spawner load_file does not exist: %s", this.load_file)

			return false
		end

		local f, err = love.filesystem.load(fn)

		if err then
			log.error("mega_spawner load error: %s, %s", fn, err)

			return false
		end

		local fd = f()

		this.spawner_points = fd.points
		this.spawner_groups = fd.groups
		this.spawner_packs = fd.packs
		this.spawner_waves = fd.waves[store.level_mode]
	end

	return true
end

function scripts.mega_spawner.update(this, store)
	if not this.spawner_points or not this.spawner_groups or not this.spawner_waves then
		log.error("points_spawner not initialized. points, grops or waves missing")
		queue_remove(store, this)

		return
	end

	local spawners = E:filter(store.entities, "spawner")
	local spawners_index = {}

	for _, s in pairs(spawners) do
		if s.spawner.name then
			spawners_index[s.spawner.name] = s
		end
	end

	while true do
		local wave_start_ts = store.tick_ts
		local current_wave = this.manual_wave or not store.waves_finished and store.wave_group_number or nil
		local spawn_queue = {}

		if current_wave then
			log.paranoid("+++++ mega_spawner running wave %s", current_wave)
		end

		if this.spawner_waves[current_wave] and not this.interrupt then
			for _, w in pairs(this.spawner_waves[current_wave]) do
				do
					local delay, delay_var, group, subpath, qty, force_all, sequence, int_min, int_max, template, custom_data = unpack(w, 1, 11)

					log.paranoid("SPAWN wave: del:%s gr:%s qty:%s spi:%s force:%s seq:%s int:%s,%s tpl:%s", delay, group, qty, subpath, force_all, sequence, int_min, int_max, template)

					local c_delay = delay

					if template == "CUSTOM" then
						for _, g in pairs(this.spawner_groups[group]) do
							local spawner = spawners_index[g]

							if not spawner then
								log.error("custom spawner %s not found in stage", g)

								break
							end

							table.insert(spawn_queue, {
								c_delay,
								template,
								[5] = {
									spawner = spawner,
									data = custom_data
								}
							})
						end
					else
						if template == "PACK" then
							local spack = this.spawner_packs[custom_data.spawnPackId]

							if not spack then
								log.error("pack spawner %s not found", custom_data.spawnPackId)
							else
								for _, wpack in pairs(spack) do
									local p_delay, p_delay_var, p_group, p_subpath, p_qty, p_force_all, p_sequence, p_int_min, p_int_max, p_template, p_custom_data = unpack(wpack, 1, 11)

									log.paranoid("  PACK del:%s delv:%s gr:%s spi:%s q:%s fo:%s seq:%s imin:%s imax:%s tpl:%s", p_delay, p_delay_var, p_group, p_subpath, p_qty, p_force_all, p_sequence, p_int_min, p_int_max, p_template)

									for i = 1, p_qty do
										local point = {
											path = custom_data.path
										}
										local spi = p_subpath and p_subpath > 0 and p_subpath or math.random(1, 3)

										table.insert(spawn_queue, {
											c_delay,
											p_template,
											point,
											spi,
											{
												pack = custom_data.spawnPackId
											}
										})

										c_delay = c_delay + U.frandom(p_int_min, p_int_max)
									end
								end
							end

							goto label_160_0
						end

						if qty < 1 then
							-- block empty
						else
							local point_ids = this.spawner_groups[group] or {
								group
							}

							if sequence and not force_all then
								c_delay = c_delay + U.frandom(0, delay_var)

								for i = 1, qty do
									local point_id = table.random(point_ids)
									local point = this.spawner_points[point_id]
									local spi = subpath and subpath > 0 and subpath or math.random(1, 3)

									table.insert(spawn_queue, {
										c_delay,
										template,
										point,
										spi,
										custom_data
									})

									c_delay = c_delay + U.frandom(int_min, int_max)
								end
							else
								local qty_per_point = {}

								if force_all then
									for _, point_id in pairs(point_ids) do
										qty_per_point[point_id] = qty
									end
								else
									for i = 1, qty do
										local point_id = table.random(point_ids)

										qty_per_point[point_id] = (qty_per_point[point_id] or 0) + 1
									end
								end

								for _, point_id in pairs(point_ids) do
									local point = this.spawner_points[point_id]
									local int_delay = 0

									for i = 1, qty_per_point[point_id] or 0 do
										local spi = subpath and subpath > 0 and subpath or math.random(1, 3)

										int_delay = int_delay + U.frandom(int_min, int_max)

										table.insert(spawn_queue, {
											c_delay + U.frandom(0, delay_var) + int_delay,
											template,
											point,
											spi,
											custom_data
										})
									end
								end
							end
						end
					end
				end

				::label_160_0::
			end

			table.sort(spawn_queue, function(e1, e2)
				return e1[1] < e2[1]
			end)

			local ptr = 1

			while this.manual_wave and current_wave == this.manual_wave or current_wave == store.wave_group_number do
				if this.interrupt then
					goto label_160_2
				end

				local wave_ts = store.tick_ts - wave_start_ts

				while ptr <= #spawn_queue and wave_ts >= spawn_queue[ptr][1] do
					local ts, template, p_point, p_spi, custom_data = unpack(spawn_queue[ptr], 1, 5)

					if template == "CUSTOM" then
						custom_data.spawner.spawner.spawn_data = custom_data.data

						-- log.paranoid("%06.2f : SPAWN (%06.2f) - %s spawner:%s, data:%s", store.tick_ts, ts, template, custom_data.spawner.id, getdump(custom_data.data))
					else
						local p_from, p_to, p_pi = p_point.from, p_point.to, p_point.path
						local raise = p_from ~= nil
						local node

						if p_from and p_to then
							local pis

							if p_pi then
								pis = {
									p_pi
								}

								local next_pi = p_pi

								repeat
									next_pi = P:get_next_pi(next_pi)

									if next_pi then
										table.insert(pis, next_pi)
									end
								until next_pi == nil
							end

							local nodes = P:nearest_nodes(p_to.x, p_to.y, pis, {
								p_spi
							})

							if #nodes == 0 then
								log.error("SPAWN (%06.2f) - Node not found near:%s,%s", ts, p_to.x, p_to.y)

								goto label_160_1
							end

							node = {
								pi = nodes[1][1],
								spi = nodes[1][2],
								ni = nodes[1][3]
							}
						elseif p_pi then
							local p_ni = P:get_start_node(p_pi)

							node = {
								pi = p_pi,
								spi = p_spi or 1,
								ni = p_ni
							}
							p_from = P:node_pos(node)
							p_to = P:node_pos(node)
						else
							log.error("SPAWN (%06.2f) - spawner_point path and to properties are both missing", ts)

							goto label_160_1
						end

						if not U.is_seen(store, template) then
							signal.emit("wave-notification", "icon", template)
							U.mark_seen(store, template)
						end

						local e = E:create_entity(template)

						e.nav_path.pi = node.pi
						e.nav_path.spi = node.spi
						e.nav_path.ni = node.ni
						e.pos = V.vclone(p_from)
						e.motion.forced_waypoint = P:node_pos(e.nav_path)

						if raise then
							e.render.sprites[1].name = "raise"
						end

						e.custom_spawn_data = custom_data

						queue_insert(store, e)

						log.paranoid("%06.2f : SPAWN (%06.2f) - %s from:%s,%s to:%s,%s pi:%s spi:%s", store.tick_ts, ts, template, p_from.x, p_from.y, p_to.x, p_to.y, p_pi, p_spi)

						if store.extra_enemies and store.extra_enemies > 0 then
							for i = 1, store.extra_enemies do
								e = E:create_entity(template)
								e.nav_path.pi = node.pi
								e.nav_path.spi = km.zmod(node.spi + i, 3)
								e.nav_path.ni = node.ni
								e.pos = V.vclone(p_from)
								e.motion.forced_waypoint = P:node_pos(e.nav_path)
								if raise then
									e.render.sprites[1].name = "raise"
								end
								e.custom_spawn_data = custom_data
								if e.health then
									e.health.hp_max = math.ceil(e.health.hp_max * (store.extra_enemies * 0.15 + 1))
								end
								if e.enemy then
									e.enemy.gold = km.round(e.enemy.gold * 0.6 * 0.85 ^ (store.extra_enemies - 1))
								end
								U.y_wait(store, fts(2))
								queue_insert(store, e)
							end
						end
					end

					::label_160_1::

					ptr = ptr + 1
				end

				coroutine.yield()
			end
		else
			while this.manual_wave and current_wave == this.manual_wave or not this.manual_wave and not store.waves_finished and current_wave == store.wave_group_number do
				if this.interrupt then
					goto label_160_2
				end

				coroutine.yield()
			end
		end

		coroutine.yield()
	end

	::label_160_2::

	log.debug("points_spawner interrupted")
	queue_remove(store, this)
end

scripts.editor_mega_spawner = {}

function scripts.editor_mega_spawner.insert(this, store)
	if not scripts.mega_spawner.insert(this, store) then
		return false
	end

	this._shapes = {}

	for _, p in pairs(this.spawner_points) do
		if p.from and p.to then
			local s = E:create_entity("editor_spawner_arrow")

			s.pos = p.from

			queue_insert(store, s)
			table.insert(this._shapes, s)

			s.render.sprites[2].r = V.angleTo(p.to.x - p.from.x, p.to.y - p.from.y)
			s.render.sprites[2].scale = V.v(1, 1)
			s.render.sprites[2].scale.x = V.dist(p.to.x, p.to.y, p.from.x, p.from.y) / s.line_image_width
			s.render.sprites[3].offset = V.v(p.to.x - p.from.x, p.to.y - p.from.y)
			s.render.sprites[3].r = V.angleTo(p.to.x - p.from.x, p.to.y - p.from.y)
		end
	end
end

function scripts.editor_mega_spawner.remove(this, store)
	for _, s in pairs(this._shapes) do
		queue_remove(store, s)
	end

	this._shapes = nil
end

scripts.taunts_controller = {}

function scripts.taunts_controller.insert(this, store)
	if this.load_file then
		local fn = KR_PATH_GAME .. "/data/levels/" .. this.load_file .. ".lua"
		local data, err = LU.eval_file(fn)

		if not data then
			log.error("taunts_controller failed loading file %s: %s", this.load_file, err)

			return false
		end

		this.sequence = data.sequence
	end

	return true
end

function scripts.taunts_controller.update(this, store)
	local sequence = this.sequence and this.sequence[store.level_mode]

	while not store.waves_finished do
		if this.interrupt then
			break
		end

		local start_ts, last_ts = store.tick_ts, store.tick_ts
		local wave_number = store.wave_group_number
		local groups = sequence[wave_number]

		if not groups then
			-- block empty
		else
			for _, group in pairs(groups) do
				local t_total, g_sets, g_idx, g_repeat = unpack(group, 1, 4)
				local t_elapsed = store.tick_ts - start_ts
				local t_actual = km.clamp(0, t_total, t_total - t_elapsed)

				::label_165_0::

				if U.y_wait(store, t_actual, function(store, time)
					return store.wave_group_number ~= wave_number or this.interrupt
				end) then
					goto label_165_1
				end

				if this.interrupt then
					goto label_165_2
				end

				local set = type(g_sets) == "table" and table.random(g_sets) or g_sets
				local idx = g_idx and g_idx > 0 and g_idx or nil

				SU.y_show_taunt_set(store, this.taunts, set, idx, nil, nil, true)

				if store.wave_group_number ~= wave_number then
					goto label_165_1
				elseif g_repeat then
					t_actual = U.frandom(this.taunts.delay_min, this.taunts.delay_max)

					goto label_165_0
				end
			end

			coroutine.yield()
		end

		::label_165_1::

		while store.wave_group_number == wave_number do
			coroutine.yield()
		end
	end

	::label_165_2::
end

scripts.power_fireball_control = {}

function scripts.power_fireball_control.can_select_point(this, x, y, store)
	return not GR:cell_is(x, y, TERRAIN_CLIFF) and (P:valid_node_nearby(x, y, 1.4285714285714286, NF_POWER_1) or store.level.fn_can_power and store.level:fn_can_power(store, GUI_MODE_POWER_1, V.v(x, y)) or GR:cell_is(x, y, TERRAIN_WATER))
end

function scripts.power_fireball_control.update(this, store, script)
	local start_y = store.visible_coords and store.visible_coords.top or REF_H
	local ts
	local burst_interval = 0.33

	for i = 1, math.max(this.fireball_count, this.cataclysm_count) do
		if i <= this.fireball_count then
			local e = E:create_entity("power_fireball")
			local p, found, tries = nil, nil, 0

			while not p and tries < 5 do
				p = V.v(this.pos.x + math.random(-this.max_spread, this.max_spread), this.pos.y + math.random(-this.max_spread, this.max_spread))

				local oy = GR.cell_size

				if band(GR:cell_type(p.x, p.y + oy), TERRAIN_CLIFF) ~= 0 or band(GR:cell_type(p.x, p.y - oy), TERRAIN_CLIFF) ~= 0 then
					p = nil
					tries = tries + 1
				end
			end

			if p then
				e.pos.x, e.pos.y = p.x, start_y
				e.bullet.from = V.vclone(e.pos)
				e.bullet.to = V.v(p.x, p.y)
				e.bullet.level = this.user_power.level

				queue_insert(store, e)
			end
		end

		if i <= this.cataclysm_count then
			local dest = P:get_random_position(10, bor(TERRAIN_LAND, TERRAIN_WATER))

			if dest then
				local e = E:create_entity("power_fireball")

				e.pos.x = dest.x
				e.pos.y = start_y
				e.bullet.from = V.vclone(e.pos)
				e.bullet.to = V.vclone(dest)
				e.bullet.level = this.user_power.level

				queue_insert(store, e)
			end
		end

		ts = store.tick_ts

		while burst_interval > store.tick_ts - ts do
			coroutine.yield()
		end
	end

	queue_remove(store, this)
end

scripts.power_fireball = {}

function scripts.power_fireball.update(this, store, script)
	local b = this.bullet
	local mspeed = 10 * FPS
	local particle = E:create_entity("ps_power_fireball")

	particle.particle_system.track_id = this.id

	queue_insert(store, particle)

	local shadow = E:create_entity("decal_fireball_shadow")

	shadow.pos.x, shadow.pos.y = b.to.x, b.to.y
	shadow.render.sprites[1].ts = store.tick_ts

	queue_insert(store, shadow)

	local shadow_tracks = b.from.x ~= b.to.x

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		if shadow_tracks then
			shadow.pos.x = this.pos.x
		end

		coroutine.yield()
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y
	particle.particle_system.source_lifetime = 0

	local enemies = table.filter(store.entities, function(k, v)
		return v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, b.damage_bans) == 0 and band(v.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(v.pos, b.to, b.damage_radius)
	end)
	local damage_value = math.ceil(b.damage_factor * math.random(b.damage_min, b.damage_max))

	for _, enemy in pairs(enemies) do
		local d = E:create_entity("damage")

		d.source_id = this.id
		d.target_id = enemy.id
		d.value = damage_value
		d.damage_type = b.damage_type

		queue_damage(store, d)
	end

	S:queue(this.sound_events.hit)

	local cell_type = GR:cell_type(b.to.x, b.to.y)

	if band(cell_type, TERRAIN_WATER) ~= 0 then
		local fx = E:create_entity("fx_explosion_water")

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)

		if this.scorch_earth then
			local scorched = E:create_entity("power_scorched_water")

			scorched.pos.x, scorched.pos.y = b.to.x, b.to.y

			for i = 1, #scorched.render.sprites do
				scorched.render.sprites[i].ts = store.tick_ts
			end

			queue_insert(store, scorched)
		end
	else
		if b.hit_decal then
			local decal = E:create_entity(b.hit_decal)

			decal.pos = V.vclone(b.to)
			decal.render.sprites[1].ts = store.tick_ts

			queue_insert(store, decal)
		end

		if b.hit_fx then
			local fx = E:create_entity(b.hit_fx)

			fx.pos.x, fx.pos.y = b.to.x, b.to.y
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)
		end

		if this.scorch_earth then
			local scorched = E:create_entity("power_scorched_earth")

			scorched.pos.x, scorched.pos.y = b.to.x, b.to.y

			for i = 1, #scorched.render.sprites do
				scorched.render.sprites[i].ts = store.tick_ts
			end

			queue_insert(store, scorched)
		end
	end

	queue_remove(store, shadow)
	queue_remove(store, this)
end

scripts.power_reinforcements_control = {}

function scripts.power_reinforcements_control.can_select_point(this, x, y)
	return P:valid_node_nearby(x, y, nil, NF_RALLY) and GR:cell_is_only(x, y, bor(TERRAIN_LAND, TERRAIN_ICE))
end

function scripts.power_reinforcements_control.insert(this, store, script)
	local x, y = this.pos.x, this.pos.y
	local i = math.random(1, 3)
	local e = E:create_entity("re_current_" .. i)

	e.pos.x = x + 10
	e.pos.y = y - 10
	e.nav_rally.center = V.v(x, y)
	e.nav_rally.pos = V.vclone(e.pos)

	queue_insert(store, e)

	i = math.random(1, 3)
	e = E:create_entity("re_current_" .. i)
	e.pos.x = x - 10
	e.pos.y = y + 10
	e.nav_rally.center = V.v(x, y)
	e.nav_rally.pos = V.vclone(e.pos)

	queue_insert(store, e)

	return true
end

if true then
	scripts.abomination_explosion_aura = {}

	function scripts.abomination_explosion_aura.update(this, store)
		U.y_wait(store, this.aura.hit_time)

		local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)

		if targets then
			for _, target in pairs(targets) do
				local d = E:create_entity("damage")

				d.damage_type = this.aura.damage_type
				d.value = this.aura.damage_max
				d.target_id = target.id
				d.source_id = this.id

				queue_damage(store, d)
			end
		end

		queue_remove(store, this)
	end

	scripts.werewolf_regen_aura = {}

	function scripts.werewolf_regen_aura.update(this, store)
		while true do
			local target = store.entities[this.aura.source_id]

			if not target or target.health.dead then
				queue_remove(store, this)

				return
			end

			if target.unit.is_stunned and U.has_modifier_types(store, target, MOD_TYPE_FREEZE) then
				-- block empty
			elseif target.regen and store.tick_ts - this.aura.ts >= target.regen.cooldown then
				this.aura.ts = store.tick_ts
				target.health.hp = target.health.hp + target.regen.health
				target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp)
			end

			coroutine.yield()
		end
	end

	scripts.mod_lycanthropy = {}

	function scripts.mod_lycanthropy.insert(this, store)
		local source = store.entities[this.modifier.source_id]
		local target = store.entities[this.modifier.target_id]

		if not target or target.health.dead then
			return false
		end

		if source and P:nodes_to_defend_point(source.nav_path) < this.nodeslimit then
			return false
		end

		if source and source.enemy and not source.enemy.can_do_magic then
			return false
		end

		if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
			return false
		end

		return true
	end

	function scripts.mod_lycanthropy.update(this, store)
		while true do
			if this.active or store.level.moon_controller and store.level.moon_controller.moon_active then
				local target = store.entities[this.modifier.target_id]

				if not target or target.health.dead then
					queue_remove(store, this)

					return
				end

				S:queue(this.sound_events.transform)

				local e = E:create_entity(this.moon.transform_name)

				e.pos.x, e.pos.y = target.pos.x, target.pos.y
				e.health.hp = this.spawn_hp or e.health.hp
				e.health.hp_max = this.spawn_hp_max or e.health.hp_max

				if target.nav_path then
					e.nav_path = table.deepclone(target.nav_path)
					e.nav_path.dir = 1
				else
					local nearest = P:nearest_nodes(e.pos.x, e.pos.y, nil, {
						1,
						2,
						3
					}, true, NF_RALLY)

					if nearest and nearest[1] then
						e.nav_path.pi, e.nav_path.spi, e.nav_path.ni = unpack(nearest[1])
					else
						log.error("Could not find path to transform creature: %s (%s,%s)", target.id, e.pos.x, e.pos.y)
						queue_remove(store, this)

						return
					end
				end

				e.enemy.gold = target.enemy and target.enemy.gold or 0
				e.render.sprites[1].name = "raise"
				if target.render then
					e.render.sprites[1].flip_x = target.render.sprites[1].flip_x
				end

				queue_insert(store, e)

				local d = E:create_entity("damage")

				d.damage_type = DAMAGE_EAT
				d.source_id = this.id
				d.target_id = target.id

				queue_damage(store, d)

				if target.enemy then
					target.enemy.gold = 0
					target.enemy.gold_bag = 0
				end

				queue_remove(store, this)

				return
			end

			coroutine.yield()
		end
	end

	scripts.enemy_lycan = {}

	function scripts.enemy_lycan.on_damage(this, store, damage)
		log.paranoid("  LYCAN DAMAGE: %s \n%s", damage.value, getfulldump(damage))

		if this.unit.is_stunned then
			return true
		end

		local h = this.health
		local predicted_damage = U.predict_damage(this, damage)
		local threshold = this.lycan_trigger_factor * h.hp_max

		if not h.dead and band(damage.damage_type, bor(DAMAGE_EAT, DAMAGE_DISINTEGRATE)) == 0 and threshold >= h.hp - predicted_damage then
			local m = E:create_entity("mod_lycanthropy")

			m.modifier.target_id = this.id
			m.spawn_hp = math.max(1, h.hp - predicted_damage) + m.extra_health
			m.spawn_hp_max = h.hp_max + m.extra_health
			m.active = true
			m.moon.transform_name = this.moon.transform_name

			queue_insert(store, m)

			h.on_damage = nil

			return false
		else
			return true
		end
	end

	scripts.user_item_atomic_bomb = {}

	function scripts.user_item_atomic_bomb.update(this, store, script)
		local plane = E:create_entity("decal_atomic_bomb_plane")

		plane.pos.x, plane.pos.y = this.pos.x, this.pos.y
		plane.motion.max_speed = (this.plane_dest.x - this.pos.x) / this.plane_transit_duration
		plane.bomb_dest = this.bomb_dest

		U.set_destination(plane, this.plane_dest)
		queue_insert(store, plane)
		queue_remove(store, this)
	end

	scripts.decal_atomic_bomb_plane = {}

	function scripts.decal_atomic_bomb_plane.insert(this, store, script)
		this.render.sprites[5].offset.y = this.bomb_dest.y - this.pos.y

		return true
	end

	function scripts.decal_atomic_bomb_plane.update(this, store, script)
		local initial_y = this.pos.y
		local s_bomb = this.render.sprites[3]
		local bomb = E:create_entity("atomic_bomb")
		local bomb_drop_x = this.bomb_dest.x - this.motion.max_speed * bomb.bullet.flight_time

		while not this.motion.arrived do
			U.walk(this, store.tick_length)

			if not s_bomb.hidden and bomb_drop_x <= this.pos.x then
				bomb.pos.x, bomb.pos.y = this.pos.x + s_bomb.offset.x, this.pos.y + s_bomb.offset.y
				bomb.bullet.from = V.vclone(bomb.pos)
				bomb.bullet.to = this.bomb_dest

				queue_insert(store, bomb)
				coroutine.yield()

				s_bomb.hidden = true
			end

			this.pos.y = initial_y + 2 * math.sin(2 * math.pi * store.ts / (12 / FPS))

			coroutine.yield()
		end

		queue_remove(store, this)
	end

	scripts.atomic_bomb = {}

	function scripts.atomic_bomb.insert(this, store)
		local b = this.bullet

		b.g = 2 * (b.to.y - b.from.y) / b.flight_time
		b.ts = store.tick_ts
		b.last_pos = V.vclone(b.from)
		b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
		b.speed.y = 0

		return true
	end

	function scripts.atomic_bomb.update(this, store)
		local b = this.bullet

		b.ts = store.tick_ts

		while store.tick_ts - b.ts + store.tick_length < b.flight_time do
			coroutine.yield()

			b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
			this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)
			this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
			this.render.sprites[2].offset.y = b.to.y - this.pos.y

			local fall_phase = math.abs((b.to.y - this.pos.y) / (b.to.y - b.from.y))

			this.render.sprites[2].alpha = 255 * (1 - fall_phase)
		end

		local fx = E:create_entity(b.hit_fx)

		fx.render.sprites[1].scale = V.v(2, 2)
		fx.render.sprites[1].ts = store.tick_ts
		fx.pos.x, fx.pos.y = b.to.x, b.to.y

		queue_insert(store, fx)

		fx = E:create_entity(b.hit_decal)
		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
		coroutine.yield()
		U.sprites_hide(this)
		signal.emit("atomic-bomb-starts")
		U.y_wait(store, 0.3)

		local targets = table.filter(store.entities, function(k, v)
			return v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, b.damage_bans) == 0 and band(v.vis.bans, b.damage_flags) == 0
		end)

		for _, target in pairs(targets) do
			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = target.id

			if U.flag_has(target.vis.flags, F_BOSS) then
				d.value = b.damage_max
			else
				d.value = target.health.hp * 1000
			end

			d.damage_type = b.damage_type

			queue_damage(store, d)
		end

		for i = 0, 16 do
			if i % 3 == 0 then
				S:queue("BombExplosionSound")
			end

			local x, y = math.random(50, 900), math.random(50, 700)
			local cell_type = GR:cell_type(x, y)
			local fx

			if band(cell_type, TERRAIN_WATER) ~= 0 then
				fx = E:create_entity("fx_explosion_water")
			else
				fx = E:create_entity("fx_explosion_small")
			end

			fx.pos.x, fx.pos.y = x, y
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)
			U.y_wait(store, fts(3))
		end

		queue_remove(store, this)
	end

	scripts.user_item_atomic_freeze = {}

	function scripts.user_item_atomic_freeze.insert(this, store, script)
		for _, e in pairs(store.entities) do
			if e.template_name == this.template_name then
				log.debug("atomic_freeze already exists, force silent removal")
				queue_remove(store, e)

				this.skip_ice_slabs = true
			end
		end

		return true
	end

	function scripts.user_item_atomic_freeze.update(this, store, script)
		this.ts = store.tick_ts

		signal.emit("atomic-freeze-starts")

		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, 9999, this.vis_flags, this.vis_bans, function(e)
			return not table.contains(this.excluded_templates, e.template_name)
		end)

		if targets then
			for _, target in pairs(targets) do
				local mod = E:create_entity(this.mod)

				mod.modifier.target_id = target.id
				mod.modifier.duration = this.duration

				if band(target.vis.flags, F_BOSS) ~= 0 then
					mod.modifier.duration = mod.modifier.duration * 0.5
				end

				queue_insert(store, mod)
			end
		end

		if this.skip_ice_slabs then
			for _, e in pairs(store.entities) do
				if e.template_name == "decal_user_item_atomic_freeze_slab" then
					e.render.sprites[1].ts = store.tick_ts
				end
			end
		else
			for i = 1, 10 do
				local rpos = P:get_random_position(20, bor(TERRAIN_LAND, TERRAIN_WATER))

				if not rpos then
					log.debug("user_item_atomic_freeze: could not find random position for slab decal. i:%s", i)
				else
					local e = E:create_entity("decal_user_item_atomic_freeze_slab")

					e.duration = this.duration
					e.pos = rpos
					e.render.sprites[1].ts = store.tick_ts
					e.render.sprites[1].name = string.format(e.render.sprites[1].name, math.random(1, e.decals_count))
					e.render.sprites[1].scale = V.v(U.random_sign(), 1)

					queue_insert(store, e)
				end
			end
		end

		U.y_wait(store, this.duration)
		signal.emit("atomic-freeze-ends")
		queue_remove(store, this)
	end

	scripts.user_item_freeze = {}

	function scripts.user_item_freeze.can_select_point(this, x, y)
		return P:valid_node_nearby(x, y, nil, NF_POWER_1)
	end

	function scripts.user_item_freeze.insert(this, store, script)
		local x, y = this.pos.x, this.pos.y
		local b = this.bullet

		b.from = V.v(x, y)
		b.to = V.v(x, y)

		return scripts.bomb.insert(this, store)
	end

	function scripts.user_item_freeze.update(this, store)
		local b = this.bullet

		while store.tick_ts - b.ts + store.tick_length < b.flight_time do
			coroutine.yield()

			b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
			this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length

			if b.hide_radius then
				this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
			end
		end

		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, b.damage_radius, b.vis_flags, b.vis_bans, function(e)
			return not table.contains(b.excluded_templates, e.template_name)
		end)

		if targets then
			for _, target in pairs(targets) do
				local mod = E:create_entity(b.mod)

				mod.modifier.target_id = target.id

				if band(target.vis.flags, F_BOSS) ~= 0 or table.contains(b.half_time_templates, target.template_name) then
					mod.modifier.duration = mod.modifier.duration * 0.5
				end

				queue_insert(store, mod)
			end
		end

		local fx = E:create_entity(b.hit_fx)

		fx.render.sprites[1].ts = store.tick_ts
		fx.pos = V.vclone(b.to)

		queue_insert(store, fx)

		local decal = E:create_entity(b.hit_decal)

		decal.render.sprites[1].ts = store.tick_ts
		decal.pos = V.vclone(b.to)

		queue_insert(store, decal)
		queue_remove(store, this)
	end

	scripts.user_item_dynamite = {}

	function scripts.user_item_dynamite.can_select_point(this, x, y)
		return P:valid_node_nearby(x, y, nil, NF_POWER_1)
	end

	function scripts.user_item_dynamite.insert(this, store, script)
		local x, y = this.pos.x, this.pos.y
		local b = this.bullet

		b.from = V.v(x, y)
		b.to = V.v(x, y)

		return scripts.bomb.insert(this, store)
	end
end

return scripts
