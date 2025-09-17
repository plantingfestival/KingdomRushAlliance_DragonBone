local log = require("klua.log"):new("custom_scripts_0")

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
local W = require("wave_db")
local F = require("klove.font_db")
local I = require("klove.image_db")
local G = love.graphics
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot

require("i18n")

local scripts = require("game_scripts")

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

local function v(v1, v2)
	return {
		x = v1,
		y = v2
	}
end

local function r(x, y, w, h)
	return {
		pos = v(x, y),
		size = v(w, h)
	}
end

local function y_show_taunt_set(store, taunts, set_name, index, wait)
	local set = taunts.sets[set_name]

	index = index or set.idxs and table.random(set.idxs) or math.random(set.start_idx, set.end_idx)

	local duration = taunts.duration
	local taunt_id = _(string.format(set.format, index))

	log.info("show taunt " .. taunt_id)
	signal.emit("show-balloon_tutorial", taunt_id, false)

	if wait then
		U.y_wait(store, duration)
	end
end

local function y_hero_melee_block_and_attacks(store, hero)
	local target = SU.soldier_pick_melee_target(store, hero)

	if not target then
		return false, A_NO_TARGET
	end

	if SU.soldier_move_to_slot_step(store, hero, target) then
		return true
	end

	local attack = SU.soldier_pick_melee_attack(store, hero, target)

	if not attack then
		return false, A_IN_COOLDOWN
	end

	local upg = UP:get_upgrade("heroes_lethal_focus")
	local triggered_lethal_focus = false
	local attack_pop = attack.pop
	local attack_pop_chance = attack.pop_chance

	if attack.basic_attack and upg then
		if not hero._lethal_focus_deck then
			hero._lethal_focus_deck = SU.deck_new(upg.trigger_cards, upg.total_cards)
		end

		triggered_lethal_focus = SU.deck_draw(hero._lethal_focus_deck)
	end

	if triggered_lethal_focus then
		hero.unit.damage_factor = hero.unit.damage_factor * upg.damage_factor
		attack.pop = {
			"pop_crit_heroes"
		}
		attack.pop_chance = 1
	end

	if attack.xp_from_skill then
		SU.hero_gain_xp_from_skill(hero, hero.hero.skills[attack.xp_from_skill])
	end

	local attack_done

	if attack.loops then
		attack_done = SU.y_soldier_do_loopable_melee_attack(store, hero, target, attack)
	elseif attack.type == "area" then
		attack_done = SU.y_soldier_do_single_area_attack(store, hero, target, attack)
	else
		attack_done = SU.y_soldier_do_single_melee_attack(store, hero, target, attack)
	end

	if triggered_lethal_focus then
		hero.unit.damage_factor = hero.unit.damage_factor / upg.damage_factor
		attack.pop = attack_pop
		attack.pop_chance = attack_pop_chance
	end

	if attack_done then
		return false, A_DONE
	else
		return true
	end
end

local function y_hero_ranged_attacks(store, hero)
	local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, hero)

	if not target then
		return false, A_NO_TARGET
	end

	if not attack then
		return false, A_IN_COOLDOWN
	end

	local upg = UP:get_upgrade("heroes_lethal_focus")
	local triggered_lethal_focus = false
	local bullet_t = E:get_template(attack.bullet)
	local bullet_use_unit_damage_factor = bullet_t.bullet.use_unit_damage_factor
	local bullet_pop = bullet_t.bullet.pop
	local bullet_pop_conds = bullet_t.bullet.pop_conds

	if attack.basic_attack and upg then
		if not hero._lethal_focus_deck then
			hero._lethal_focus_deck = SU.deck_new(upg.trigger_cards, upg.total_cards)
		end

		triggered_lethal_focus = SU.deck_draw(hero._lethal_focus_deck)
	end

	if triggered_lethal_focus then
		if bullet_t.bullet.damage_radius > 0 then
			hero.unit.damage_factor = hero.unit.damage_factor * upg.damage_factor_area
		else
			hero.unit.damage_factor = hero.unit.damage_factor * upg.damage_factor
		end

		bullet_t.bullet.use_unit_damage_factor = true
		bullet_t.bullet.pop = {
			"pop_crit"
		}
		bullet_t.bullet.pop_conds = DR_DAMAGE
	end

	local start_ts = store.tick_ts
	local attack_done

	U.set_destination(hero, hero.pos)

	if attack.loops then
		attack_done = SU.y_soldier_do_loopable_ranged_attack(store, hero, target, attack)
	else
		attack_done = SU.y_soldier_do_ranged_attack(store, hero, target, attack, pred_pos)
	end

	if attack_done then
		attack.ts = start_ts

		if attack.shared_cooldown then
			for _, aa in pairs(hero.ranged.attacks) do
				if aa ~= attack and aa.shared_cooldown then
					aa.ts = attack.ts
				end
			end
		end

		if hero.ranged.forced_cooldown then
			hero.ranged.forced_ts = start_ts
		end
	end

	if triggered_lethal_focus then
		if bullet_t.bullet.damage_radius > 0 then
			hero.unit.damage_factor = hero.unit.damage_factor / upg.damage_factor_area
		else
			hero.unit.damage_factor = hero.unit.damage_factor / upg.damage_factor
		end
		bullet_t.bullet.use_unit_damage_factor = bullet_use_unit_damage_factor
		bullet_t.bullet.pop = bullet_pop
		bullet_t.bullet.pop_conds = bullet_pop_conds
	end

	if attack_done then
		return false, A_DONE
	else
		return true
	end
end

scripts.entities_delay_controller = {}
function scripts.entities_delay_controller.update(this, store, script)
	if not this.delays or not this.entities or #this.delays ~= #this.entities then
		queue_remove(store, this)
		return
	end

	local start_ts = this.start_ts or store.tick_ts
	local function insert_entity()
		local delay = this.delays[1]
		if delay + start_ts <= store.tick_ts then
			local entity = this.entities[1]
			table.remove(this.delays, 1)
			table.remove(this.entities, 1)
			if entity.render then
				for i, s in pairs(entity.render.sprites) do
					s.ts = store.tick_ts
				end
			end
			if entity.tween and not entity.tween.disabled then
				entity.tween.ts = store.tick_ts
			end
			if entity.pos and entity.pos.x == 0 and entity.pos.y == 0 then
				entity.pos.x, entity.pos.y = this.pos.x, this.pos.y
			end
			queue_insert(store, entity)
			if #this.delays > 0 then
				this.delays[1] = delay + this.delays[1]
				insert_entity()
			end
		end
	end

	while #this.delays > 0 do
		insert_entity()
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.controller_bullet_hit_payload_delay = {}
function scripts.controller_bullet_hit_payload_delay.update(this, store, script)
	if not this.delays or not this.entities or #this.delays ~= #this.entities then
		queue_remove(store, this)
		return
	end

	local b = this.bullet
	local start_ts = this.start_ts or store.tick_ts
	local function insert_entity()
		local delay = this.delays[1]
		if delay + start_ts <= store.tick_ts then
			local entity = this.entities[1]
			table.remove(this.delays, 1)
			table.remove(this.entities, 1)
			if entity.render then
				for i, s in pairs(entity.render.sprites) do
					s.ts = store.tick_ts
				end
			end
			if entity.tween and not entity.tween.disabled then
				entity.tween.ts = store.tick_ts
			end
			if entity.pos and entity.pos.x == 0 and entity.pos.y == 0 then
				entity.pos.x, entity.pos.y = this.pos.x, this.pos.y
			end
			SU.set_entity_level(entity, b.level)
			if entity.aura then
				entity.aura.target_id = b.target_id
				entity.aura.source_id = b.source_id
			else
				entity.target_id = b.target_id
				entity.source_id = b.source_id
			end
			if entity.nav_rally and entity.pos then
				local npos = V.vclone(entity.pos)
				entity.nav_rally.center = npos
				entity.nav_rally.pos = npos
				entity.nav_rally.new = false
			end
			queue_insert(store, entity)
			if #this.delays > 0 then
				this.delays[1] = delay + this.delays[1]
				insert_entity()
			end
		end
	end

	while #this.delays > 0 do
		insert_entity()
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.controller_spawn_on_path = {}
function scripts.controller_spawn_on_path.update(this, store, script)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, { this.path_index })
	if #nodes < 1 then
		queue_remove(store, this)
		return
	end
	local pi, spi, ni = unpack(nodes[1])
	ni = ni + this.start_nodes_offset * this.direction
	local diff = this.nodes_between_objects
	local delay = 0
	for i = 1, this.max_entities do
		local entity = E:create_entity(this.entity_name)
		if i > 1 then
			if this.spawn_type == 1 then
				spi = 1
			elseif this.spawn_type == 2 then
				spi = km.clamp(2, 3, km.zmod(spi + 1, 3))
			else
				spi = km.zmod(spi + 1, 3)
			end
			ni = ni + diff * this.direction
			delay = this.delay_between_objects
		elseif this.exclude_first_position then
			ni = ni + diff * this.direction
		end
		entity.pos = P:node_pos(pi, spi, ni)
		table.insert(this.entities, entity)
		table.insert(this.delays, delay)
	end
	scripts.entities_delay_controller.update(this, store, script)
end

scripts.rain_controller = {}
function scripts.rain_controller.update(this, store, script)
	local delay = 0
	for i = 1, this.max_entities do
		local entity = E:create_entity(this.entity_name)
		if i > 1 then
			delay = this.delay_between_objects
		end
		entity.pos = U.random_point_in_ellipse(this.pos, this.radius)
		table.insert(this.entities, entity)
		table.insert(this.delays, delay)
	end
	scripts.entities_delay_controller.update(this, store, script)
end

scripts.custom_bolt = {}
function scripts.custom_bolt.update(this, store, script)
	local b = this.bullet
	local fm = this.force_motion
	local target = store.entities[b.target_id]
	local ps
	if b.particles_name then
		ps = {}
		if type(b.particles_name) == "table" then
			for i, value in ipairs(b.particles_name) do
				local p = E:create_entity(value)
				p.particle_system.emit = true
				p.particle_system.track_id = this.id
				queue_insert(store, p)
				table.insert(ps, p)
			end
		else
			local p = E:create_entity(b.particles_name)
			p.particle_system.emit = true
			p.particle_system.track_id = this.id
			queue_insert(store, p)
			table.insert(ps, p)
		end
	end

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local nx, ny = V.mul(fm.max_v, V.normalize(dx, dy))
		local stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)

		if dist <= 4 * fm.max_v * store.tick_length then
			stx, sty = V.mul(fm.max_a, V.normalize(stx, sty))
		end

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step, stx, sty)))
		fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = 0, 0

		return dist <= fm.max_v * store.tick_length
	end

	local pred_pos, is_flying
	if target then
		pred_pos = P:predict_enemy_pos(target, fts(5))
		if target.vis then
			is_flying = U.flag_has(target.vis.flags, F_FLYING)
			if is_flying and b.hit_fx_air then
				b.hit_fx = b.hit_fx_air
				b.ignore_hit_offset = false
			end
		end
	else
		pred_pos = b.to
	end

	local iix, iiy = V.normalize(pred_pos.x - this.pos.x, pred_pos.y - this.pos.y)
	local last_pos = V.vclone(this.pos)

	this.render.sprites[1].ts = store.tick_ts
	b.ts = store.tick_ts

	while true do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
			local tpx, tpy = target.pos.x, target.pos.y
			local flip_sign = target.render and target.render.sprites[1].flip_x and -1 or 1
			if not b.ignore_hit_offset and target.unit and target.unit.hit_offset then
				tpx, tpy = tpx + target.unit.hit_offset.x * flip_sign, tpy + target.unit.hit_offset.y
			end

			local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))
			if d > b.max_track_distance then
				target = nil
				b.target_id = nil
			else
				b.to.x, b.to.y = tpx, tpy
			end
		end

		if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
			local t = store.tick_ts - b.ts

			if this.initial_impulse_angle_abs then
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle_abs, 1, 0))
			else
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle * (b.shot_index % 2 == 0 and 1 or -1), iix, iiy))
			end
		end

		last_pos.x, last_pos.y = this.pos.x, this.pos.y

		if move_step(b.to) then
			break
		end

		local flip_x = nil
		if b.flip_x then
			flip_x = b.to.x < this.pos.x
			this.render.sprites[1].flip_x = flip_x
		end
		
		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y) - (flip_x and math.pi or 0)
		end

		if ps then
			for i, p in ipairs(ps) do
				p.particle_system.flip_x = flip_x
				p.particle_system.emit_direction = this.render.sprites[1].r
			end
		end

		coroutine.yield()
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y
	this.render.sprites[1].hidden = true

	SU.make_bullet_damage_targets(this, store, target)
	SU.create_bullet_hit_fx(this, store, target)

	if not is_flying then
		SU.create_bullet_hit_decal(this, store)
	end

	SU.create_bullet_hit_payload(this, store)

	local pop = SU.create_bullet_pop(store, this)
	if pop then
		queue_insert(store, pop)
	end

	if this.sound_events and this.sound_events.hit then
		S:queue(this.sound_events.hit)
	end

	if ps then
		for i, p in ipairs(ps) do
			p.particle_system.emit = false
		end
		U.y_wait(store, ps[1].particle_system.particle_lifetime[2])
	end
	queue_remove(store, this)
end

scripts.initial_bolt = {}
function scripts.initial_bolt.insert(this, store, script)
	local b = this.bullet
	if b.target_id then
		local target = store.entities[b.target_id]
		if not target then
			return false
		end
	end
	return true
end

function scripts.initial_bolt.update(this, store, script)
	local b = this.bullet
	local s = this.render.sprites[1]
	local mspeed = b.min_speed
	local target, ps
	local new_target = false
	local target_invalid = false
	local ps
	if b.particles_name then
		ps = {}
		if type(b.particles_name) == "table" then
			for i, value in ipairs(b.particles_name) do
				local p = E:create_entity(value)
				p.particle_system.emit = true
				p.particle_system.track_id = this.id
				queue_insert(store, p)
				table.insert(ps, p)
			end
		else
			local p = E:create_entity(b.particles_name)
			p.particle_system.emit = true
			p.particle_system.track_id = this.id
			queue_insert(store, p)
			table.insert(ps, p)
		end
	end

	this.render.sprites[1].ts = store.tick_ts

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		coroutine.yield()

		if not target_invalid then
			target = store.entities[b.target_id]
		end

		if target and not new_target then
			local tpx, tpy = target.pos.x, target.pos.y

			if not b.ignore_hit_offset and target.unit and target.unit.hit_offset then
				local flip_sign = target.render and target.render.sprites[1].flip_x and -1 or 1
				tpx, tpy = tpx + target.unit.hit_offset.x * flip_sign, tpy + target.unit.hit_offset.y
			end

			local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))
			if d > b.max_track_distance or band(target.vis.bans, F_RANGED) ~= 0 then
				target_invalid = true
				target = nil
			elseif target.health and not target.health.dead then
				b.to.x, b.to.y = tpx, tpy
			end
		end

		if target and target.health and not target.health.dead then
			new_target = false
		else
			new_target = true
			-- 此处原有重新索敌。
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		local flip_x = nil
		if b.flip_x then
			flip_x = b.to.x < this.pos.x
			this.render.sprites[1].flip_x = flip_x
		end
		
		if not b.ignore_rotation then
			s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y) - (flip_x and math.pi or 0)
		end

		if ps then
			for i, p in ipairs(ps) do
				p.particle_system.flip_x = flip_x
				p.particle_system.emit_direction = s.r
			end
		end
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y
	this.render.sprites[1].hidden = true

	SU.make_bullet_damage_targets(this, store, target)
	SU.create_bullet_hit_fx(this, store, target, b.flip_x)
	SU.create_bullet_hit_decal(this, store, b.flip_x)
	SU.create_bullet_hit_payload(this, store)

	if this.sound_events and this.sound_events.hit then
		S:queue(this.sound_events.hit)
	end

	if ps then
		for i, p in ipairs(ps) do
			p.particle_system.emit = false
		end
		U.y_wait(store, ps[1].particle_system.particle_lifetime[2])
	end
	queue_remove(store, this)
end

scripts.lightning_ray = {}
function scripts.lightning_ray.update(this, store, script)
	local bullet = this.bullet
	local target = store.entities[bullet.target_id]
	local damage_radius = bullet.damage_radius and bullet.damage_radius > 0 and bullet.damage_radius or nil
	local sprite1 = this.render.sprites[1]

	if not target and not damage_radius then
		queue_remove(store, this)
		return
	end

	if not bullet.ignore_hit_offset and target and target.render and target.unit and target.unit.hit_offset then
		local flip_sign = target.render.sprites[1].flip_x and -1 or 1
		sprite1.offset.x = target.unit.hit_offset.x * flip_sign + this.spawn_pos_offset.x
		sprite1.offset.y = target.unit.hit_offset.y + this.spawn_pos_offset.y
	else
		sprite1.offset.x = this.spawn_pos_offset.x
		sprite1.offset.y = this.spawn_pos_offset.y
	end

	sprite1.ts = store.tick_ts

	while store.tick_ts - sprite1.ts < bullet.hit_time do
		coroutine.yield()
		if target and target.health.dead then
			target = nil
		end
	end

	local pop = SU.create_bullet_pop(store, this)
	if pop then
		queue_insert(store, pop)
	end

	if damage_radius then
		local pos = target and target.pos or this.pos
		local enemies = U.find_enemies_in_range(store.entities, pos, 0, damage_radius, bullet.damage_flags, bullet.damage_bans)
		if enemies then
			for i, enemy in ipairs(enemies) do
				SU.make_bullet_damage_targets(this, store, enemy)
			end
		end
	elseif target then
		SU.make_bullet_damage_targets(this, store, target)
	end

	SU.create_bullet_hit_fx(this, store, target)
	SU.create_bullet_hit_decal(this, store)
	SU.create_bullet_hit_payload(this, store)

	while not U.animation_finished(this) do
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.mobile_tower_mage = {}
function scripts.mobile_tower_mage.insert(this, store, script)
	local pos = V.vclone(this.pos)
	this.nav_rally.pos, this.nav_rally.center = pos, pos
	this.nav_rally.new = false
	local available_paths = {}
	for k, v in pairs(P.paths) do
		table.insert(available_paths, k)
	end
	if store.level.ignore_walk_backwards_paths then
		available_paths = table.filter(available_paths, function(k, v)
			return not table.contains(store.level.ignore_walk_backwards_paths, v)
		end)
	end
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, available_paths, nil, nil, NF_RALLY)
	if #nodes < 1 then
		this.tower.default_rally_pos = V.vclone(this.pos)
	else
		local pi, spi, ni = unpack(nodes[1])
		this.tower.default_rally_pos = P:node_pos(pi, spi, ni)
	end
	return true
end

function scripts.mobile_tower_mage.update(this, store, script)
	local tower_sid = this.render.sid_tower
	local shooter_sid = this.render.sid_shooter
	local last_target_pos
	local a = this.attacks
	local aa = this.attacks.list[1]
	local shots = aa.loops or 1
	local ignore_out_of_range_check = aa.ignore_out_of_range_check or 1

	aa.ts = store.tick_ts

	while true do
		local skip
		local enemy, enemies

		local function tower_walk_waypoints(store, this, animation)
			local animation = animation or "walk"
			local r = this.nav_rally
			local n = this.nav_grid
			local dest = r.pos
		
			while not V.veq(this.pos, dest) do
				local w = table.remove(n.waypoints, 1) or dest
				local unsnap = #n.waypoints > 0
		
				U.set_destination(this, w)
		
				local an = U.animation_name_facing_point(this, animation, this.motion.dest, tower_sid)
				U.animation_start(this, an, nil, store.tick_ts, true, tower_sid)
				an = U.animation_name_facing_point(this, animation, this.motion.dest, shooter_sid)
				U.animation_start(this, an, nil, store.tick_ts, true, shooter_sid)

				while not this.motion.arrived do
					if r.new then
						return false
					end
		
					U.walk(this, store.tick_length, nil, unsnap)

					coroutine.yield()
		
					this.motion.speed.x, this.motion.speed.y = 0, 0
				end
			end
		end

		local function tower_new_rally(store, this)
			local r = this.nav_rally

			if r.new then
				r.new = false

				if this.sound_events and this.sound_events.change_rally_point then
					S:queue(this.sound_events.change_rally_point)
				end

				local vis_bans = this.vis.bans
				this.vis.bans = F_ALL

				local an = U.animation_name_facing_point(this, "idle", r.pos, shooter_sid)

				local out = tower_walk_waypoints(store, this, "walk")

				U.animation_start(this, "idle", nil, store.tick_ts, -1, tower_sid)
				U.animation_start(this, an, nil, store.tick_ts, -1, shooter_sid)

				this.vis.bans = vis_bans

				return out
			end
		end

		if this.tower.blocked then
			skip = true
		else
			while this.nav_rally.new do
				if tower_new_rally(store, this) then
					skip = true
				end
				local available_paths = {}
				for k, v in pairs(P.paths) do
					table.insert(available_paths, k)
				end
				if store.level.ignore_walk_backwards_paths then
					available_paths = table.filter(available_paths, function(k, v)
						return not table.contains(store.level.ignore_walk_backwards_paths, v)
					end)
				end
				local nodes = P:nearest_nodes(this.pos.x, this.pos.y, available_paths, nil, nil, NF_RALLY)
				if #nodes > 0 then
					local pi, spi, ni = unpack(nodes[1])
					this.tower.default_rally_pos = P:node_pos(pi, spi, ni)
				end
			end
		end

		if not skip and store.tick_ts - aa.ts > aa.cooldown then
			enemy, enemies = U.find_foremost_enemy(store.entities, SU.get_entity_range_origin(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)

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

					local in_range = ignore_out_of_range_check or U.is_inside_ellipse(SU.get_entity_range_origin(this), enemy.pos, a.range * 1.1)
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

scripts.kr4_soldier_barrack = {}
function scripts.kr4_soldier_barrack.update(this, store, script)
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

	if this.timed_attacks then
		this.timed_attacks.order = U.attack_order(this.timed_attacks.list)
		for i, a in ipairs(this.timed_attacks.list) do
			a.ts = store.tick_ts
		end
	end

	if this.render.sprites[1].name == "raise" then
		SU.hide_shadow(this, true)
		this.health_bar.hidden = true
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise, this.sound_events.raise_args)
		end
		U.animation_start(this, "raise", nil, store.tick_ts)
		while not U.animation_finished(this) and not this.health.dead do
			coroutine.yield()
		end
		if not this.health.dead then
			SU.hide_shadow(this, false)
			this.health_bar.hidden = nil
		end
	end

	while true do
		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					SU.soldier_power_upgrade(this, pn, store)
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
			SU.hide_shadow(this, true)
			SU.y_soldier_death(store, this)
			return
		end

		local brk, sta
		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			SU.soldier_courage_upgrade(store, this)

			if this.dodge and this.dodge.active then
				this.dodge.active = false

				if this.dodge.counter_attack and this.powers and this.powers[this.dodge.counter_attack.power_name].level > 0 then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					if this.dodge.hide_shadow then
						SU.hide_shadow(this, true)
					end
					U.animation_start(this, this.dodge.animation, nil, store.tick_ts, 1)

					while not U.animation_finished(this) do
						coroutine.yield()
					end
					SU.hide_shadow(this, false)
				end

				signal.emit("soldier-dodge", this)
			end

			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					brk = true
					break
				end
			end
			if brk then
				goto label_43_1
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
				if this.dodge and this.dodge.hide_shadow and this.dodge.counter_attack_pending then
					SU.hide_shadow(this, true)
				end
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
				if this.dodge and this.dodge.hide_shadow then
					SU.hide_shadow(this, false)
				end

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

			SU.entity_idle(store, this)

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

scripts.kr4_soldier_reinforcement = {}
function scripts.kr4_soldier_reinforcement.update(this, store, script)
	local brk, sta

	if this.timed_attacks then
		this.timed_attacks.order = U.attack_order(this.timed_attacks.list)
		for i, a in ipairs(this.timed_attacks.list) do
			a.ts = store.tick_ts
		end
	end

	if this.reinforcement then
		this.reinforcement.ts = store.tick_ts
	end

	if this.render then
		for _, s in pairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end

	if this.reinforcement and (this.reinforcement.fade or this.reinforcement.fade_in) then
		SU.y_reinforcement_fade_in(store, this)
	elseif this.render.sprites[1].name == "raise" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise, this.sound_events.raise_args)
		end

		this.health_bar.hidden = true

		U.y_animation_play(this, "raise", nil, store.tick_ts)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	while true do
		if this.cloak then
			this.vis.flags = band(this.vis.flags, bnot(this.cloak.flags))
			this.vis.bans = band(this.vis.bans, bnot(this.cloak.bans))
			this.render.sprites[1].alpha = 255
		end

		if this.health.dead then
			this.reinforcement.fade = false
			this.reinforcement.fade_out = false
			this.ui.can_click = false
			this.tween = nil

			SU.y_soldier_death(store, this)

			return
		end

		if this.reinforcement and this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			this.health.hp = 0
			this.ui.can_click = false

			SU.remove_modifiers(store, this)
			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			SU.soldier_courage_upgrade(store, this)

			if this.dodge and this.dodge.active then
				this.dodge.active = false

				if this.dodge.counter_attack and this.powers and this.powers[this.dodge.counter_attack.power_name].level > 0 then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					if this.dodge.hide_shadow then
						SU.hide_shadow(this, true)
					end
					U.animation_start(this, this.dodge.animation, nil, store.tick_ts)

					while not U.animation_finished(this) do
						coroutine.yield()
					end
					SU.hide_shadow(this, false)
				end

				signal.emit("soldier-dodge", this)
			end

			while this.nav_rally.new do
				if this.nav_rally.move_order then
					U.y_wait(store, this.nav_rally.move_order * math.random() * 0.3)
				end

				if SU.y_hero_new_rally(store, this) then
					goto label_481_1
				end
			end

			if this.timed_actions then
				brk, sta = SU.y_soldier_timed_actions(store, this)
				if brk then
					goto label_481_1
				end
			end

			if this.timed_attacks then
				brk, sta = SU.y_soldier_timed_attacks(store, this)
				if brk then
					goto label_481_1
				end
			end

			if this.ranged and this.ranged.range_while_blocking then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)
				if brk then
					goto label_481_1
				end
			end

			if this.melee then
				if this.dodge and this.dodge.hide_shadow and this.dodge.counter_attack_pending then
					SU.hide_shadow(this, true)
				end
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
				if this.dodge and this.dodge.hide_shadow then
					SU.hide_shadow(this, false)
				end

				if brk or sta ~= A_NO_TARGET then
					goto label_481_1
				end
			end

			if this.ranged and not this.ranged.range_while_blocking then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)
				if brk or sta == A_DONE then
					goto label_481_1
				elseif sta == A_IN_COOLDOWN and not this.ranged.go_back_during_cooldown then
					goto label_481_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_481_1
			end

			::label_481_0::

			SU.entity_idle(store, this)

			if this.cloak then
				this.vis.flags = bor(this.vis.flags, this.cloak.flags)
				this.vis.bans = bor(this.vis.bans, this.cloak.bans)

				if this.cloak.alpha then
					this.render.sprites[1].alpha = this.cloak.alpha
				end
			end

			SU.soldier_regen(store, this)
		end

		::label_481_1::

		coroutine.yield()
	end
end

scripts.tower_with_shooters = {}
function scripts.tower_with_shooters.get_info(this)
	local min, max, d_type, cooldown, range

	if this.attacks then
		range = this.attacks.range
	end
	if this.attacks and this.attacks.list[1] then
		cooldown = this.attacks.list[1].cooldown
		if this.attacks.list[1].damage_min then
			min, max = this.attacks.list[1].damage_min, this.attacks.list[1].damage_max
			d_type = this.attacks.list[1].damage_type or DAMAGE_PHYSICAL
		elseif this.attacks.list[1].bullet then
			local b = E:get_template(this.attacks.list[1].bullet)
			min, max = b.bullet.damage_min, b.bullet.damage_max
			d_type = b.bullet.damage_type
		end
	elseif this.shooters and this.shooters[1] then
		local shooter = this.shooters[1]
		if type(shooter) == "string" then
			shooter = E:get_template(shooter)
		end
		if shooter.attacks and shooter.attacks.list[1] then
			if not range then
				range = shooter.attacks.range
			end
			local a1 = shooter.attacks.list[1]
			cooldown = a1.cooldown
			if a1.damage_min then
				min, max = a1.damage_min, a1.damage_max
				d_type = a1.damage_type or DAMAGE_PHYSICAL
			elseif a1.bullet then
				local b = E:get_template(a1.bullet)
				min, max = b.bullet.damage_min, b.bullet.damage_max
				d_type = b.bullet.damage_type
			end
		end
	end
	if not min then
		if this.barrack then
			return scripts.tower_barrack.get_info(this)
		else
			min, max = 0, 0
		end
	end
	min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)

	return {
		type = d_type == DAMAGE_MAGICAL and STATS_TYPE_TOWER_MAGE or STATS_TYPE_TOWER,
		damage_min = min,
		damage_max = max,
		damage_type = d_type,
		range = range,
		cooldown = cooldown
	}
end

function scripts.tower_with_shooters.insert(this, store, script)
	if this.barrack and not this.barrack.rally_pos and this.tower.default_rally_pos then
		this.barrack.rally_pos = V.vclone(this.tower.default_rally_pos)
	end
	if this.shooters then
		for i, shooter_name in ipairs(this.shooters) do
			local shooter = E:create_entity(shooter_name)
			shooter.pos = this.pos
			shooter.owner = this
			queue_insert(store, shooter)
			this.shooters[i] = shooter
		end
	end
	return true
end

function scripts.tower_with_shooters.update(this, store, script)
	local barrack = this.barrack

	while true do
		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil
					if this.shooters then
						for i, shooter in ipairs(this.shooters) do
							if shooter.powers and shooter.powers[pn] then
								shooter.powers[pn].level = p.level
								shooter.powers[pn].changed = true
							end
						end
					end

					if barrack then
						for i, s in ipairs(barrack.soldiers) do
							if s and s.powers and s.powers[pn] then
								s.powers[pn].level = p.level
								s.powers[pn].changed = true
							end
						end
					end
				end
			end
		end

		if this.tower.blocked then
			goto label_continue
		end

		if barrack then
			for i = 1, barrack.max_soldiers do
				local s = barrack.soldiers[i]
				if not s or s.health.dead and not store.entities[s.id] then
					if not barrack.door_open then
						if this.sound_events.open_door then
							S:queue(this.sound_events.open_door)
						end
						if this.door_group then
							U.animation_start_group(this, "open", nil, store.tick_ts, nil, this.door_group)
							while not U.animation_finished_group(this, this.door_group) do
								coroutine.yield()
							end
						end
						barrack.door_open = true
						barrack.door_open_ts = store.tick_ts
					end

					if type(barrack.soldier_type) == "table" then
						s = E:create_entity(barrack.soldier_type[i])
					else
						s = E:create_entity(barrack.soldier_type)
					end
					s.soldier.tower_id = this.id
					s.soldier.tower_soldier_idx = i
					s.pos = V.v(V.add(this.pos.x, this.pos.y, barrack.respawn_offset.x, barrack.respawn_offset.y))
					s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, barrack, barrack.max_soldiers)
					s.nav_rally.new = true

					if this.powers and s.powers then
						for pn, p in pairs(this.powers) do
							if s.powers[pn] then
								s.powers[pn].level = p.level
							end
						end
					end

					queue_insert(store, s)
					barrack.soldiers[i] = s
					signal.emit("tower-spawn", this, s)
				end
			end
			if barrack.door_open and store.tick_ts - barrack.door_open_ts > barrack.door_hold_time then
				if this.door_group then
					U.animation_start_group(this, "close", nil, store.tick_ts, nil, this.door_group)
					while not U.animation_finished_group(this, this.door_group) do
						coroutine.yield()
					end
				end
				barrack.door_open = false
			end
			if barrack.rally_new then
				barrack.rally_new = false
				signal.emit("rally-point-changed", this)
				local all_dead = true
				for i, s in ipairs(barrack.soldiers) do
					s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, barrack, barrack.max_soldiers, barrack.rally_angle_offset)
					s.nav_rally.new = true
					all_dead = all_dead and s.health.dead
				end
				if not all_dead then
					S:queue(this.sound_events.change_rally_point)
				end
			end
		end

		::label_continue::
		coroutine.yield()
	end
end

function scripts.tower_with_shooters.remove(this, store, script)
	if this.barrack then
		for i, s in ipairs(this.barrack.soldiers) do
			if s.health then
				s.health.dead = true
			end
			queue_remove(store, s)
		end
	end
	if this.shooters and #this.shooters > 0 then
		for i, shooter in ipairs(this.shooters) do
			queue_remove(store, shooter)
		end
	end
	return true
end

scripts.tower_shooter = {}
function scripts.tower_shooter.insert(this, store, script)
	this.attacks.order = U.attack_order(this.attacks.list)
	for i, a in ipairs(this.attacks.list) do
		a.ts = store.tick_ts
	end
	if this.render then
		for _, s in pairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end
	return true
end

function scripts.tower_shooter.update(this, store, script)
	local tower = this.owner
	if this.idle_flip then
		U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
	end
	
	while true do
		this.pos = tower.pos
		if this.attacks.list[1] then
			this.attacks.list[1].max_range = this.attacks.range
		end
		for pn, p in pairs(this.powers) do
			if p.changed then
				p.changed = nil
				SU.shooter_power_upgrade(this, pn, store)
			end
		end
		
		local interrupted, status = nil, nil
		if tower.tower.blocked or tower.nav_rally and tower.nav_rally.new then
			SU.entity_idle(store, this)
			goto label_continue
		end

		interrupted, status = SU.shooter_attacks(store, this)
		if interrupted then
			goto label_continue
		end
		if status == A_NO_TARGET then
			SU.entity_idle(store, this)
		end

		::label_continue::
		coroutine.yield()
	end
end

scripts.follow_target = {}
function scripts.follow_target.update(this, store, script)
	local target = this.target_id and store.entities[this.target_id]
	if not target then
		queue_remove(store, this)
		return
	end

	local function fade_in()
		if this.fade_time <= 0 then
			return
		end
		this.tween.props[1].keys = {
			{
				0,
				0
			},
			{
				this.fade_time,
				255
			}
		}
		this.tween.disabled = nil
		this.tween.ts = store.tick_ts
		U.y_wait(store, this.fade_time)
	end

	local function fade_out()
		if this.fade_time <= 0 then
			return
		end
		this.tween.props[1].keys = {
			{
				0,
				255
			},
			{
				this.fade_time,
				0
			}
		}
		this.tween.disabled = nil
		this.tween.ts = store.tick_ts
		U.y_wait(store, this.fade_time)
	end

	this.pos = target.pos
	this.attacks.order = U.attack_order(this.attacks.list)
	for i, a in ipairs(this.attacks.list) do
		a.level = this.level
		if a.cooldowns then
			a.cooldown = a.cooldowns[this.level]
		end
		if a.ranges then
			a.max_range = a.ranges[this.level]
		end
		a.ts = store.tick_ts - a.cooldown
	end
	fade_in()
	U.animation_start(this, this.idle_animation, nil, store.tick_ts, true)
	this.reinforcement.ts = store.tick_ts

	local function find_target(a)
		local target, targets, pred_pos
		local origin = SU.get_entity_range_origin(this)
		local filter_fn = nil
		if a.allowed_templates then
			filter_fn = function(e)
				return table.contains(a.allowed_templates, e.template_name) and (not a.filter_fn or a.filter_fn and a.filter_fn(e))
			end
		elseif a.excluded_templates then
			filter_fn = function(e)
				return not table.contains(a.excluded_templates, e.template_name) and (not a.filter_fn or a.filter_fn and a.filter_fn(e))
			end
		else
			filter_fn = a.filter_fn
		end
		if a.vis_bans and band(a.vis_bans, F_ENEMY) ~= 0 then
			target, targets, pred_pos = U.find_soldier_with_search_type(store.entities, origin, a.min_range, a.max_range, 0, a.vis_flags, a.vis_bans, 
			filter_fn, a.search_type)
		elseif a.vis_bans and band(a.vis_bans, F_FRIEND) ~= 0 then
			target, targets, pred_pos = U.find_enemy_with_search_type(store.entities, origin, a.min_range, a.max_range, 0, 
			a.vis_flags, a.vis_bans, filter_fn, F_FLYING, a.search_type)
		else
			target, targets, pred_pos = U.find_enemy_with_search_type(store.entities, origin, a.min_range, a.max_range, 0, 
			a.vis_flags, a.vis_bans, filter_fn, F_FLYING, a.search_type)
			local soldier, soldiers, soldier_pos = U.find_soldier_with_search_type(store.entities, origin, a.min_range, a.max_range, 0, 
			a.vis_flags, a.vis_bans, filter_fn, a.search_type)
			if targets then
				if soldiers then
					table.merge(targets, soldiers)
				end
			else
				target, targets, pred_pos = soldier, soldiers, soldier_pos
			end
		end
		return target
	end

	while true do
		if store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			break
		end

		local interrupted, status = nil, nil
		local newTarget
		target = store.entities[this.target_id]
		if not target or target.health and target.health.dead then
			if not this.attacks.list[1] then
				break
			end
			target = find_target(this.attacks.list[1])
			if target then
				newTarget = true
				fade_out()
			end
		end
		if target then
			this.target_id = target.id
			this.pos = target.pos
			if newTarget then
				fade_in()
			end
		else
			U.y_wait(store, fts(10))
			goto label_continue
		end

		for _, i in ipairs(this.attacks.order) do
			local attack = this.attacks.list[i]
			attack.target_id = this.target_id
			if SU.check_entity_attack_available(store, this, attack) then
				interrupted, status = SU.entity_attacks(store, this, attack)
				if status == A_DONE then
					break
				end
			end
		end
		if status ~= A_DONE then
			U.animation_start(this, this.idle_animation, nil, store.tick_ts, true)
		end

		::label_continue::
		coroutine.yield()
	end
	fade_out()
	queue_remove(store, this)
end

scripts.controller_item_hero = {}
function scripts.controller_item_hero.insert(this, store)
	if not this.entity then
		return false
	end
	local entities = table.filter(store.entities, function(k, v)
		return v.template_name == this.entity
	end)
	if entities and #entities > 0 then
		return false
	end

	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {
		1
	}, true)

	if #nodes < 1 then
		return false
	end

	local pi, spi, ni = unpack(nodes[1])
	local npos = P:node_pos(pi, spi, ni)

	local entity = E:create_entity(this.entity)
	entity.pos = V.vclone(npos)
	entity.nav_rally.center = npos
	entity.nav_rally.pos = npos

	if band(entity.vis.flags, F_HERO) ~= 0 then
		entity.hero.level = 10
		if entity.hero.skills then
			for key, value in pairs(entity.hero.skills) do
				if key == "ultimate" and value.hr_cost and value.hr_cost[4] then
					value.level = 4
					local ultimate_controller = E:get_template(value.controller_name)
					value.ts = store.tick_ts - ultimate_controller.cooldown
				else
					value.level = 3
					if key == "ultimate" then
						local ultimate_controller = E:get_template(value.controller_name)
						value.ts = store.tick_ts - ultimate_controller.cooldown
					end
				end
			end
		end
	end

	queue_insert(store, entity)

	return false
end

scripts.controller_item_heroes = {}
function scripts.controller_item_heroes.insert(this, store)
	if not this.entities or #this.entities == 0 then
		return false
	end
	local entities = table.filter(store.entities, function(k, v)
		for i, name in ipairs(this.entities) do
			if v.template_name == name then
				return true
			end
		end
		return false
	end)
	if entities and #entities > 0 then
		return false
	end

	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {
		1
	}, true)
	if #nodes < 1 then
		return false
	end

	local pi, spi, ni = unpack(nodes[1])
	local npos = P:node_pos(pi, spi, ni)

	for i, name in ipairs(this.entities) do
		local entity = E:create_entity(name)
		local a = 2 * math.pi / #this.entities
		local pos = U.point_on_ellipse(npos, 25, (i - 1) * a - math.pi / 2)
		entity.pos = pos
		entity.nav_rally.center = npos
		entity.nav_rally.pos = V.vclone(pos)
		entity.reinforcement.squad_id = this.id
		if band(entity.vis.flags, F_HERO) ~= 0 then
			entity.hero.level = 10
			if entity.hero.skills then
				for key, value in pairs(entity.hero.skills) do
					if key == "ultimate" and value.hr_cost and value.hr_cost[4] then
						value.level = 4
						local ultimate_controller = E:get_template(value.controller_name)
						value.ts = store.tick_ts - ultimate_controller.cooldown
					else
						value.level = 3
						if key == "ultimate" then
							local ultimate_controller = E:get_template(value.controller_name)
							value.ts = store.tick_ts - ultimate_controller.cooldown
						end
					end
				end
			end
		end
		queue_insert(store, entity)
	end

	return false
end

scripts.mod_track_target_with_fade = {}
function scripts.mod_track_target_with_fade.update(this, store, script)
	local m = this.modifier
	m.ts = store.tick_ts

	local target = store.entities[m.target_id]
	if not target or not target.pos then
		queue_remove(store, this)
		return
	end
	this.pos = target.pos

	local fade_out = 0
	if this.tween then
		this.tween.props[1].sprite_id = {}
		for i, s in pairs(this.render.sprites) do
			table.insert(this.tween.props[1].sprite_id, i)
		end
		this.tween.remove = false
		if this.fade_out and this.fade_out > 0 then
			fade_out = this.fade_out
		end
		if this.fade_in and this.fade_in > 0 then
			this.tween.disabled = false
			this.tween.ts = store.tick_ts
			this.tween.props[1].keys = {
				{
					0,
					0
				},
				{
					this.fade_in,
					255
				}
			}
		elseif fade_out > 0 then
			this.tween.disabled = true
		else
			this.tween = nil
		end
	end

	local function loop(duration)
		while true do
			target = store.entities[m.target_id]
			if not target or target.health.dead or m.last_node and target.nav_path and target.nav_path.ni > m.last_node then
				queue_remove(store, this)
				return true
			end
	
			if store.tick_ts - m.ts > duration then
				break
			end
	
			this.pos = target.pos
			if this.render and target.unit then
				local s = this.render.sprites[1]
				local flip_sign = 1
	
				if not s._original_offset then
					s._original_offset = V.vclone(s.offset)
				end
				if target.render then
					flip_sign = target.render.sprites[1].flip_x and -1 or 1
				end
	
				if m.use_head_offset and target.unit.head_offset and (target.unit.head_offset.x ~= 0 or target.unit.head_offset.y ~= 0) then
					s.offset.x, s.offset.y = (s._original_offset.x + target.unit.head_offset.x) * flip_sign, target.unit.head_offset.y + s._original_offset.y
				elseif m.health_bar_offset and target.health_bar then
					local hb = target.health_bar.offset
					local hbo = m.health_bar_offset
					s.offset.x, s.offset.y = hb.x + (s._original_offset.x + hbo.x) * flip_sign, hb.y + hbo.y + s._original_offset.y
				elseif m.use_mod_offset and target.unit.mod_offset then
					s.offset.x, s.offset.y = (s._original_offset.x + target.unit.mod_offset.x) * flip_sign, target.unit.mod_offset.y + s._original_offset.y
				end
			end
	
			coroutine.yield()
		end
		return false
	end

	if loop(m.duration - fade_out) then
		return
	end

	if fade_out > 0 then
		this.tween.remove = true
		this.tween.reverse = true
		this.tween.disabled = false
		this.tween.ts = store.tick_ts
		this.tween.props[1].keys = {
			{
				0,
				0
			},
			{
				fade_out,
				255
			}
		}
	else
		queue_remove(store, this)
		return
	end

	loop(m.duration)
end

scripts.mod_hps_with_fade = {}
function scripts.mod_hps_with_fade.update(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if not target or not target.pos then
		queue_remove(store, this)
		return
	end

	this.pos = target.pos
	m.ts = store.tick_ts
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

	local fade_out = 0
	if this.tween then
		this.tween.props[1].sprite_id = {}
		for i, s in pairs(this.render.sprites) do
			table.insert(this.tween.props[1].sprite_id, i)
		end
		this.tween.remove = false
		if this.fade_out and this.fade_out > 0 then
			fade_out = this.fade_out
		end
		if this.fade_in and this.fade_in > 0 then
			this.tween.disabled = false
			this.tween.ts = store.tick_ts
			this.tween.props[1].keys = {
				{
					0,
					0
				},
				{
					this.fade_in,
					255
				}
			}
		elseif fade_out > 0 then
			this.tween.disabled = true
		else
			this.tween = nil
		end
	end

	local function loop(duration)
		while true do
			target = store.entities[m.target_id]
			if not target or target.health.dead then
				queue_remove(store, this)
				return true
			end
			this.pos = target.pos

			if duration < store.tick_ts - m.ts then
				break
			end

			if this.render and m.use_mod_offset and target.unit and target.unit.mod_offset then
				local flip_sign = target.render and target.render.sprites[1].flip_x and -1 or 1
				for _, s in pairs(this.render.sprites) do
					if not s.exclude_mod_offset then
						s.offset.x, s.offset.y = target.unit.mod_offset.x * flip_sign, target.unit.mod_offset.y
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
		return false
	end

	if loop(duration - fade_out) then
		return
	end

	if fade_out > 0 then
		this.tween.remove = true
		this.tween.reverse = true
		this.tween.disabled = false
		this.tween.ts = store.tick_ts
		this.tween.props[1].keys = {
			{
				0,
				0
			},
			{
				fade_out,
				255
			}
		}
	else
		queue_remove(store, this)
		return
	end

	loop(duration)
end

scripts.flame = {}
function scripts.flame.insert(this, store, script)
	local b = this.bullet
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, 0)
	b.ts = store.tick_ts

	if this.flame_bullet then
		this.flame_bullets = {}
		local flip_x = b.to.x < b.from.x
		b.r = V.angleTo(b.to.x - b.from.x, b.to.y - b.from.y) - (flip_x and math.pi or 0)
		for i = 1, this.flames_count do
			local flame_bullet = E:create_entity(this.flame_bullet)
			for _, s in pairs(flame_bullet.render.sprites) do
				s.r = b.r
			end
			flame_bullet.start_ts = b.ts + this.delay_betweeen_flames * (i - 1)
			flame_bullet.ts = nil
			flame_bullet.pos.x, flame_bullet.pos.y = b.from.x, b.from.y
			table.insert(this.flame_bullets, flame_bullet)
		end
	end

	return true
end

function scripts.flame.update(this, store, script)
	local b = this.bullet

	while true do
		for i, flame_bullet in ipairs(this.flame_bullets) do
			if flame_bullet.ts == false then
				if i == #this.flame_bullets then
					queue_remove(store, this)
					return
				end
			elseif flame_bullet.ts then
				if store.tick_ts - flame_bullet.ts <= b.flight_time then
					flame_bullet.pos.x, flame_bullet.pos.y = SU.position_in_parabola(store.tick_ts - flame_bullet.ts, b.from, b.speed, 0)
				else
					queue_remove(store, flame_bullet)
					flame_bullet.ts = false
					if i == 1 then
						SU.make_bullet_damage_targets(this, store, nil)
						SU.create_bullet_hit_payload(this, store)
					end
				end
			elseif flame_bullet.start_ts and store.tick_ts >= flame_bullet.start_ts then
				flame_bullet.ts = store.tick_ts
				flame_bullet.start_ts = nil
				for _, s in pairs(flame_bullet.render.sprites) do
					s.ts = store.tick_ts + store.tick_length
				end
				queue_insert(store, flame_bullet)
			end
		end

		coroutine.yield()
	end
end

scripts.fx_repeat_forever = {}
function scripts.fx_repeat_forever.update(this, store, script)
	if not this.render.sprites[1].animated then
		return
	end

	if this.random_shift then
		this.render.sprites[1].time_offset = math.random()
	end

	local start_ts = store.tick_ts
	U.y_animation_play(this, this.render.sprites[1].name, nil, store.tick_ts)
	if this.min_delay and this.max_delay then
		start_ts = store.tick_ts + U.frandom(this.min_delay, this.max_delay)
	end

	while true do
		if store.tick_ts >= start_ts then
			U.y_animation_play(this, this.render.sprites[1].name, nil, store.tick_ts)
		end
		if this.min_delay and this.max_delay then
			start_ts = store.tick_ts + U.frandom(this.min_delay, this.max_delay)
		end
		coroutine.yield()
	end
end

scripts.controller_teleport_enemies = {}
function scripts.controller_teleport_enemies.update(this, store, script)
	local teleport_entities = {}

	while true do
		for id, e in pairs(store.entities) do
			if not e.pending_removal and e.nav_path and e.health and not e.health.dead and e.nav_path.pi == this.path and 
			(e.nav_path.ni > this.start_ni and e.nav_path.ni < this.end_ni) then
				table.insert(teleport_entities, e)
				SU.remove_auras(store, e)
				SU.remove_modifiers(store, e)
				if e.ui and e.ui.can_click then
					e.ui._original_click = true
					e.ui.can_click = false
				end
				if e.count_group then
					e.count_group.in_limbo = true
				end
				e.main_script.co = nil
				e.main_script.runs = 0
				queue_remove(store, e)
				U.unblock_all(store, e)
				e.insert_ts = store.tick_ts + (this.duration or 0)
			end
		end

		for i = #teleport_entities, 1, -1 do
			local e = teleport_entities[i]
			if e.insert_ts <= store.tick_ts then
				if e.enemy then
					e.nav_path.ni = this.end_ni
				else
					e.nav_path.ni = this.start_ni
				end
				e.pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni)
				if e.ui and e.ui._original_click then
					e.ui.can_click = true
					e.ui._original_click = nil
				end
				e.main_script.runs = 1
				e.insert_ts = nil
				table.remove(teleport_entities, i)
				queue_insert(store, e)
			end
		end

		coroutine.yield()
	end
end

scripts.common_aura = {}
function scripts.common_aura.insert(this, store, script)
	this.aura.ts = store.tick_ts

	if this.render then
		for _, s in pairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
		if this.aura.source_id and this.aura.use_mod_offset then
			local source = store.entities[this.aura.source_id]
			if source and source.unit and source.unit.mod_offset then
				local flip_sign = source.render and source.render.sprites[1].flip_x and -1 or 1
				this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = source.unit.mod_offset.x * flip_sign, source.unit.mod_offset.y
			end
		end
	end

	this.actual_duration = this.aura.duration

	if this.aura.duration_inc then
		this.actual_duration = this.actual_duration + this.aura.level * this.aura.duration_inc
	end

	return true
end

scripts.aura_with_towers = {}
function scripts.aura_with_towers.update(this, store, script)
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	local victims_count = 0

	if this.aura.track_source and this.aura.source_id then
		local source = store.entities[this.aura.source_id]
		if source and source.pos then
			this.pos = source.pos
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

		if this.aura.source_id then
			local source = store.entities[this.aura.source_id]
			if this.aura.track_source then
				if not source or source.health and source.health.dead and not this.aura.track_dead then
					break
				end
				if this.aura.requires_alive_source then
					if source and source.health and source.health.dead then
						goto label_93_0
					end
				end
				if this.aura.requires_magic then
					if not source.enemy then
						goto label_93_0
					end
	
					if this.render then
						for _, s in pairs(this.render.sprites) do
							s.hidden = not source.enemy.can_do_magic
						end
					end
	
					if not source.enemy.can_do_magic then
						goto label_93_0
					end
				end
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

			local towers = U.find_towers_in_range(store.entities, this.pos, this.aura)
			if towers then
				local mods = this.aura.mods or {
					this.aura.mod
				}
				for i, tower in ipairs(towers) do
					if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
						break
					end
	
					if this.aura.max_count and victims_count >= this.aura.max_count then
						break
					end
	
					for i, mod_name in ipairs(mods) do
						local new_mod = E:create_entity(mod_name)
						new_mod.modifier.level = this.aura.level
						new_mod.modifier.target_id = tower.id
						new_mod.modifier.source_id = this.aura.source_id or this.id
						queue_insert(store, new_mod)
						victims_count = victims_count + 1
					end
				end
			end
		end

		::label_93_0::

		coroutine.yield()
	end

	signal.emit("aura-apply-mod-victims", this, victims_count)
	queue_remove(store, this)
end

scripts.continuous_ray = {}
function scripts.continuous_ray.update(this, store, script)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local dest = V.vclone(b.to)
	s.scale = s.scale or V.vv(1)

	if not b.ignore_hit_offset and target and target.unit and target.unit.hit_offset then
		local flip_sign = target.render and target.render.sprites[1].flip_x and -1 or 1
		b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x * flip_sign, target.pos.y + target.unit.hit_offset.y
	end

	local function update_sprite()
		if target then
			local tpx, tpy = target.pos.x, target.pos.y
			if not b.ignore_hit_offset and target.unit and target.unit.hit_offset then
				local flip_sign = target.render and target.render.sprites[1].flip_x and -1 or 1
				tpx, tpy = tpx + target.unit.hit_offset.x * flip_sign, tpy + target.unit.hit_offset.y
			end
			local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))
			if d > b.max_track_distance then
				target = nil
				this.force_stop_ray = true
			else
				b.to.x, b.to.y = tpx, tpy
				dest.x, dest.y = tpx, tpy
			end
		end

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)
		s.r = angle
		local dist_offset = 0
		if this.dist_offset then
			dist_offset = this.dist_offset
		end
		s.scale.x = (V.dist(dest.x, dest.y, this.pos.x, this.pos.y) + dist_offset) / this.image_width
	end

	U.animation_start(this, this.animation_start, nil, store.tick_ts)
	update_sprite()
	while not U.animation_finished(this) do
		if target and target.vis and (U.flag_has(target.vis.bans, this.bullet.vis_flags) or U.flag_has(this.bullet.vis_bans, target.vis.flags)) then
			target = nil
		end
		coroutine.yield()
		update_sprite()
	end
	
	U.animation_start(this, this.animation_travel, nil, store.tick_ts, true)
	local mods_added = {}
	if this.ray_duration then
		target = store.entities[b.target_id]
		local source = store.entities[b.source_id]
		local start_ts = store.tick_ts
		local last_hit_ts = store.tick_ts - this.bullet.tick_time
		while target and not target.health.dead and not this.force_stop_ray and source and store.tick_ts - start_ts <= this.ray_duration do
			if target and target.vis and (U.flag_has(target.vis.bans, this.bullet.vis_flags) or U.flag_has(this.bullet.vis_bans, target.vis.flags)) then
				this.force_stop_ray = true
				break
			end
			if store.tick_ts - last_hit_ts >= this.bullet.tick_time then
				last_hit_ts = store.tick_ts
				local d = SU.create_bullet_damage(b, target.id, b.source_id)
				queue_damage(store, d)
				if b.mod or b.mods then
					local mods = b.mods or {
						b.mod
					}
					for _, mod_name in pairs(mods) do
						local has_modifiers, modifiers = U.has_modifiers(store, this, mod_name)
						local m
						if has_modifiers then
							m = modifiers[1]
							m.modifier.ts = store.tick_ts
						else
							local m = E:create_entity(mod_name)
							m.modifier.target_id = b.target_id
							m.modifier.source_id = b.source_id
							m.modifier.level = b.level
							queue_insert(store, m)
						end
						table.insert(mods_added, m)
					end
				end
			end
			coroutine.yield()
			update_sprite()
			target = store.entities[b.target_id]
			source = store.entities[b.source_id]
		end
	end

	S:stop(this.sound_events.travel)
	S:queue(this.sound_events.out)

	for i, value in ipairs(mods_added) do
		queue_remove(store, value)
	end

	U.y_animation_play(this, this.animation_out, nil, store.tick_ts)
	queue_remove(store, this)
end

scripts.mod_continuous_ray = {}
function scripts.mod_continuous_ray.update(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if not target or target.health and target.health.dead then
		queue_remove(store, this)
		return
	end
	local s = this.render.sprites[1]
	if target.unit and target.unit.hit_offset then
		local flip_sign = target.render and target.render.sprites[1].flip_x and -1 or 1
		s.offset.x, s.offset.y = target.unit.hit_offset.x * flip_sign, target.unit.hit_offset.y
	end
	this.pos = target.pos
	U.y_animation_play(this, this.animation_start, nil, store.tick_ts)
	this.pos = target.pos
	m.ts = store.tick_ts
	U.animation_start(this, this.animation_loop, nil, store.tick_ts, true)
	while store.tick_ts - m.ts <= m.duration do
		this.pos = target.pos
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.kr4_enemy_mixed = {}
function scripts.kr4_enemy_mixed.update(this, store, script)
	local function check_unit_attack(store, this, a)
		if SU.check_unit_attack_available(store, this, a) then
			return SU.entity_attacks(store, this, a)
		end
		return false
	end

	local walk_break_fn = function(store, this)
		if this.timed_attacks then
			for i, a in ipairs(this.timed_attacks.list) do
				return check_unit_attack(store, this, a)
			end
		end
		return false
	end

	local melee_break_fn = function(store, this)
		if this.timed_attacks then
			for i, a in ipairs(this.timed_attacks.list) do
				if a.melee_break and check_unit_attack(store, this, a) then
					return true
				end
			end
		end
		return false
	end

	local ranged_break_fn = function(store, this)
		if this.timed_attacks then
			for i, a in ipairs(this.timed_attacks.list) do
				if a.ranged_break and check_unit_attack(store, this, a) then
					return true
				end
			end
		end
		return false
	end

	if this.timed_attacks then
		for i, a in ipairs(this.timed_attacks.list) do
			a.ts = store.tick_ts
		end
	end

	if this.render.sprites[1].name == "raise" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise, this.sound_events.raise_args)
		end
		this.health_bar.hidden = true
		local an, af = U.animation_name_facing_point(this, "raise", this.motion.dest)
		SU.hide_shadow(this, true)
		U.y_animation_play(this, an, af, store.tick_ts, 1)
		SU.hide_shadow(this, false)
		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	local ps
	if this.particle then
		ps = {}
		if type(this.particle) == "table" then
			for i, value in ipairs(this.particle) do
				local p = E:create_entity(value)
				p.particle_system.emit = true
				p.particle_system.track_id = this.id
				queue_insert(store, p)
				table.insert(ps, p)
			end
		else
			local p = E:create_entity(this.particle)
			p.particle_system.emit = true
			p.particle_system.track_id = this.id
			queue_insert(store, p)
			table.insert(ps, p)
		end
	end

	::label_29_0::

	while true do
		if this.health.dead then
			if ps then
				for i, p in ipairs(ps) do
					p.particle_system.emit = nil
				end
			end
			SU.hide_shadow(this, true)
			SU.y_enemy_death(store, this)
			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			SU.y_enemy_mixed_walk_melee_ranged(store, this, false, walk_break_fn, melee_break_fn, ranged_break_fn)
			if ps and this.render then
				for i, p in ipairs(ps) do
					p.particle_system.flip_x = this.render.sprites[1].flip_x
				end
			end
			coroutine.yield()
		end
	end
end

scripts.aura_wander = {}
function scripts.aura_wander.update(this, store, script)
	this.aura.ts = store.tick_ts
	local last_hit_ts = store.tick_ts - this.aura.cycle_time

	local fade_out = 0
	if this.tween then
		this.tween.props[1].sprite_id = {}
		for i, s in pairs(this.render.sprites) do
			table.insert(this.tween.props[1].sprite_id, i)
		end
		this.tween.remove = false
		if this.fade_out and this.fade_out > 0 then
			fade_out = this.fade_out
		end
		if this.fade_in and this.fade_in > 0 then
			this.tween.disabled = false
			this.tween.ts = store.tick_ts
			this.tween.props[1].keys = {
				{
					0,
					0
				},
				{
					this.fade_in,
					255
				}
			}
		elseif fade_out > 0 then
			this.tween.disabled = true
		else
			this.tween = nil
		end
	end

	if this.spawn_animation then
		U.y_animation_play(this, this.spawn_animation, nil, store.tick_ts)
	end

	local ps
	if this.particle then
		ps = {}
		if type(this.particle) == "table" then
			for i, value in ipairs(this.particle) do
				local p = E:create_entity(value)
				p.particle_system.emit = true
				p.particle_system.track_id = this.id
				queue_insert(store, p)
				table.insert(ps, p)
			end
		else
			local p = E:create_entity(this.particle)
			p.particle_system.emit = true
			p.particle_system.track_id = this.id
			queue_insert(store, p)
			table.insert(ps, p)
		end
	end

	local function wander()
		local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {
			this.nav_path.pi
		}, {
			this.nav_path.spi
		})
		if nearest and nearest[1] and nearest[1][3] < this.nav_path.ni then
			this.nav_path.ni = nearest[1][3]
		end
		local next_pos = P:next_entity_node(this, store.tick_length)
		if not next_pos or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or not GR:cell_is(next_pos.x, next_pos.y, TERRAIN_LAND) or 
		GR:cell_is(next_pos.x, next_pos.y, TERRAIN_NOWALK) then
			return true
		end
		U.set_destination(this, next_pos)
		local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)
		U.animation_start(this, an, af, store.tick_ts, true)
		if ps then
			for i, p in ipairs(ps) do
				p.particle_system.flip_x = af
			end
		end
		U.walk(this, store.tick_length)
		return false
	end

	while true do
		if this.aura.duration >= 0 and store.tick_ts - this.aura.ts >= this.aura.duration + this.aura.level * this.aura.duration_inc then
			break
		end

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			last_hit_ts = store.tick_ts

			local targets = table.filter(store.entities, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.excluded_entities or not table.contains(this.aura.excluded_entities, v.id))
			end)

			for _, target in pairs(targets) do
				local d = E:create_entity("damage")
				d.source_id = this.aura.source_id or this.id
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
					m.modifier.source_id = this.aura.source_id or this.id
					queue_insert(store, m)
				end

				if this.aura.hit_blood_fx then
					local hit_fx_pos = V.vclone(target.pos)
					local flip_x = nil
					if target.render and target.unit and target.unit.hit_offset then
						flip_x = target.render.sprites[1].flip_x
						local flip_sign = target.render.sprites[1].flip_x and -1 or 1
						hit_fx_pos.x = target.unit.hit_offset.x * flip_sign + hit_fx_pos.x
						hit_fx_pos.y = target.unit.hit_offset.y + hit_fx_pos.y
					end
					local hit_fx = SU.insert_sprite(store, this.aura.hit_blood_fx, hit_fx_pos, flip_x)
					if hit_fx.use_blood_color and target.unit and target.unit.blood_color then
						hit_fx.render.sprites[1].name = target.unit.blood_color
					end
				end
			end
		end

		if wander() then
			break
		end
		coroutine.yield()
	end

	S:queue(this.sound_events.death, this.sound_events.death_args)
	if ps then
		for i, p in ipairs(ps) do
			p.particle_system.emit = nil
		end
	end
	SU.hide_shadow(this, true)
	if this.death_animation then
		U.y_animation_play(this, this.death_animation, nil, store.tick_ts)
	end
	if this.dead_lifetime and this.dead_lifetime > 0 then
		if this.death_animation then
			U.y_wait(store, this.dead_lifetime)
		else
			U.y_wait(store, this.dead_lifetime, wander())
		end
	end
	if fade_out > 0 then
		this.tween.remove = true
		this.tween.reverse = true
		this.tween.disabled = false
		this.tween.ts = store.tick_ts
		this.tween.props[1].keys = {
			{
				0,
				0
			},
			{
				fade_out,
				255
			}
		}
		if not this.death_animation then
			while not wander() do
				coroutine.yield()
			end
		end
	else
		queue_remove(store, this)
	end
end

scripts.summoning_hero_ultimate = {}
function scripts.summoning_hero_ultimate.can_fire_fn(this, x, y, store)
	return GR:cell_is_only(x, y, TERRAIN_LAND) and P:valid_node_nearby(x, y, nil, NF_RALLY)
end

function scripts.summoning_hero_ultimate.update(this, store, script)
	local e = E:create_entity(this.entity)
	if this.use_center or e.nav_rally or e.nav_path or e.path_index then
		local pi, spi, ni
		spi = this.use_center and 1 or nil
		local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, { spi }, true)
		if #nodes < 1 then
			queue_remove(store, this)
			return
		end
		pi, spi, ni = unpack(nodes[1])
		local npos = P:node_pos(pi, spi, ni)
		e.pos = V.vclone(npos)
		if e.nav_rally then
			e.nav_rally.center = npos
			e.nav_rally.pos = npos
		end
		if e.nav_path then
			e.nav_path.pi = pi
			e.nav_path.spi = spi
			e.nav_path.ni = ni
		end
		if e.path_index then
			e.path_index = pi
		end
	else
		e.pos = this.pos
	end
	queue_insert(store, e)
	queue_remove(store, this)
end

scripts.mod_intimidation = {}
function scripts.mod_intimidation.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.unit then
		return false
	end
	
	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		return false
	end

	if this.speed_factor and target.motion then
		target.motion.max_speed = target.motion.max_speed * this.speed_factor
	end

	if target.nav_path and target.vis and target.vis.flags then
		if band(target.vis.flags, F_FRIEND) ~= 0 then
			target.nav_path.dir = 1
		else
			target.nav_path.dir = -1
		end
		if target.vis.bans then
			target.vis._original_bans = target.vis.bans
			target.vis.bans = U.flag_set(target.vis.bans, F_BLOCK)
		end
		U.unblock_all(store, target)
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

function scripts.mod_intimidation.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target then
		if this.speed_factor and target.motion then
			target.motion.max_speed = target.motion.max_speed / this.speed_factor
		end

		if target.nav_path and target.vis and target.vis.flags then
			if band(target.vis.flags, F_FRIEND) ~= 0 then
				target.nav_path.dir = -1
			else
				target.nav_path.dir = 1
			end
			if target.vis.bans then
				target.vis.bans = target.vis._original_bans
			end
		end
	end

	return true
end

scripts.soldier_wander = {}
function scripts.soldier_wander.update(this, store, script)
	local brk, sta

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	if this.render.sprites[1].name == "raise" then
		this.health_bar.hidden = true
		SU.hide_shadow(this, true)
		for i, sprite in ipairs(this.render.sprites) do
			sprite._original_sort_y_offset = sprite.sort_y_offset
			sprite.sort_y_offset = sprite.sort_y_offset - 10
		end
		U.animation_start(this, "raise", nil, store.tick_ts)
		while not U.animation_finished(this) and not this.health.dead do
			coroutine.yield()
		end
		if not this.health.dead then
			SU.hide_shadow(this, false)
			this.health_bar.hidden = nil
		end
		for i, sprite in ipairs(this.render.sprites) do
			sprite.sort_y_offset = sprite._original_sort_y_offset
			sprite._original_sort_y_offset = nil
		end
	end

	local available_paths = {}
	for k, v in pairs(P.paths) do
		table.insert(available_paths, k)
	end
	if store.level.ignore_walk_backwards_paths then
		available_paths = table.filter(available_paths, function(k, v)
			return not table.contains(store.level.ignore_walk_backwards_paths, v)
		end)
	end
	local nearest = P:nearest_nodes(this.default_rally_pos.x, this.default_rally_pos.y, available_paths)
	local pi, spi, ni
	if #nearest > 1 then
		local index = math.random(1, 2)
		pi, spi, ni = unpack(nearest[index])
		if index ~= 1 then
			local nodePos = P:node_pos(pi, spi, ni)
			local d2 = V.dist2(this.default_rally_pos.x, this.default_rally_pos.y, nodePos.x, nodePos.y)
			if d2 >= 120 * 120 then
				pi, spi, ni = unpack(nearest[1])
			end
		end
	end
	this.nav_path.pi, this.nav_path.ni = pi, ni
	this.nav_path.spi = math.random(1, 3)

	while true do
		if this.cloak then
			this.vis.flags = band(this.vis.flags, bnot(this.cloak.flags))
			this.vis.bans = band(this.vis.bans, bnot(this.cloak.bans))
			this.render.sprites[1].alpha = 255
		end

		if not this.health.dead or SU.y_soldier_revive(store, this) then
			-- block empty
		else
			U.unblock_target(store, this)
			SU.hide_shadow(this, true)
			U.animation_start(this, "death", nil, store.tick_ts, false, 1)
			if this.sound_events.death then
				S:queue(this.sound_events.death)
			end
			U.y_animation_wait(this, 1)
			queue_remove(store, this)
			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if this.dodge and this.dodge.active then
				this.dodge.active = false
				if this.dodge.counter_attack then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					if this.dodge.hide_shadow then
						SU.hide_shadow(this, true)
					end
					U.animation_start(this, this.dodge.animation, nil, store.tick_ts, 1)
					while not U.animation_finished(this) do
						coroutine.yield()
					end
					SU.hide_shadow(this, false)
				end
			end
			
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
				if this.dodge and this.dodge.hide_shadow and this.dodge.counter_attack_pending then
					SU.hide_shadow(this, true)
				end
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
				if this.dodge and this.dodge.hide_shadow then
					SU.hide_shadow(this, false)
				end
				if brk or sta ~= A_NO_TARGET then
					goto label_43_1
				end
			end

			if this.ranged and not this.ranged.range_while_blocking then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)
				if brk or sta == A_DONE then
					goto label_43_1
				elseif sta == A_IN_COOLDOWN then
					local flip_x = this.motion and this.motion.dest.x < this.pos.x or nil
					U.animation_start(this, "idle", flip_x, store.tick_ts, true)
					goto label_43_1
				end
			end

			if this.cloak then
				this.vis.flags = bor(this.vis.flags, this.cloak.flags)
				this.vis.bans = bor(this.vis.bans, this.cloak.bans)

				if this.cloak.alpha then
					this.render.sprites[1].alpha = this.cloak.alpha
				end
			end

			SU.soldier_regen(store, this)

			local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {
				this.nav_path.pi
			}, {
				this.nav_path.spi
			})

			if nearest and nearest[1] and nearest[1][3] < this.nav_path.ni then
				this.nav_path.ni = nearest[1][3]
			end

			local next_pos = P:next_entity_node(this, store.tick_length)
			if not next_pos or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or not GR:cell_is(next_pos.x, next_pos.y, TERRAIN_LAND) or 
			GR:cell_is(next_pos.x, next_pos.y, TERRAIN_NOWALK) then
				SU.hide_shadow(this, true)
				SU.y_soldier_death(store, this)
				queue_remove(store, this)
				return
			end
			U.set_destination(this, next_pos)
			local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)
			U.animation_start(this, an, af, store.tick_ts, -1)
			U.walk(this, store.tick_length)
		end

		::label_43_1::

		coroutine.yield()
	end
end

scripts.soldier_hover = {}
function scripts.soldier_hover.update(this, store, script)
	local brk, sta

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	this.hover.oni = this.nav_path.ni
	this.hover.ts = store.tick_ts
	this.hover.cooldown = U.frandom(this.hover.cooldown_min, this.hover.cooldown_max + 1e-9)
	if this.reinforcement then
		this.reinforcement.ts = store.tick_ts
	end
	U.set_destination(this, this.pos)

	local fade_out = 0
	if this.tween then
		this.tween.props[1].sprite_id = {}
		for i, s in pairs(this.render.sprites) do
			table.insert(this.tween.props[1].sprite_id, i)
		end
		this.tween.remove = false
		if this.fade_out and this.fade_out > 0 then
			fade_out = this.fade_out
		end
		if this.fade_in and this.fade_in > 0 then
			this.tween.disabled = false
			this.tween.ts = store.tick_ts
			this.tween.props[1].keys = {
				{
					0,
					0
				},
				{
					this.fade_in,
					255
				}
			}
		elseif fade_out > 0 then
			this.tween.disabled = true
		else
			this.tween = nil
		end
	end

	if this.render.sprites[1].name == "raise" then
		this.health_bar.hidden = true
		SU.hide_shadow(this, true)
		U.animation_start(this, "raise", nil, store.tick_ts)
		while not U.animation_finished(this) and not this.health.dead do
			coroutine.yield()
		end
		if not this.health.dead then
			SU.hide_shadow(this, false)
			this.health_bar.hidden = nil
		end
	end

	while true do
		if this.cloak then
			this.vis.flags = band(this.vis.flags, bnot(this.cloak.flags))
			this.vis.bans = band(this.vis.bans, bnot(this.cloak.bans))
			this.render.sprites[1].alpha = 255
		end

		if this.health.dead or this.reinforcement and this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			U.unblock_target(store, this)
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end
			this.health.hp = 0
			this.ui.can_click = false
			SU.remove_modifiers(store, this)
			S:queue(this.sound_events.death, this.sound_events.death_args)
			SU.hide_shadow(this, true)
			U.animation_start(this, "death", nil, store.tick_ts)
			U.y_animation_wait(this)
			if fade_out > 0 then
				this.tween.remove = true
				this.tween.reverse = true
				this.tween.disabled = false
				this.tween.ts = store.tick_ts
				this.tween.props[1].keys = {
					{
						0,
						0
					},
					{
						fade_out,
						255
					}
				}
			else
				queue_remove(store, this)
			end
			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if this.dodge and this.dodge.active then
				this.dodge.active = false
				if this.dodge.counter_attack then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					if this.dodge.hide_shadow then
						SU.hide_shadow(this, true)
					end
					U.animation_start(this, this.dodge.animation, nil, store.tick_ts, 1)
					while not U.animation_finished(this) do
						coroutine.yield()
					end
					SU.hide_shadow(this, false)
				end
			end
			
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
				if this.dodge and this.dodge.hide_shadow and this.dodge.counter_attack_pending then
					SU.hide_shadow(this, true)
				end
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
				if this.dodge and this.dodge.hide_shadow then
					SU.hide_shadow(this, false)
				end
				if brk or sta ~= A_NO_TARGET then
					goto label_43_1
				end
			end

			if this.ranged and not this.ranged.range_while_blocking then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)
				if brk or sta == A_DONE then
					goto label_43_1
				elseif sta == A_IN_COOLDOWN then
					local flip_x = this.motion and this.motion.dest.x < this.pos.x or nil
					U.animation_start(this, "idle", flip_x, store.tick_ts, true)
					goto label_43_1
				end
			end

			if this.cloak then
				this.vis.flags = bor(this.vis.flags, this.cloak.flags)
				this.vis.bans = bor(this.vis.bans, this.cloak.bans)

				if this.cloak.alpha then
					this.render.sprites[1].alpha = this.cloak.alpha
				end
			end

			if V.veq(this.pos, this.motion.dest) then
				this.motion.arrived = true
			elseif not U.walk(this, store.tick_length) then
				local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)
				U.animation_start(this, an, af, store.tick_ts, true)
			end
			if this.motion.arrived then
				U.animation_start(this, "idle", nil, store.tick_ts, true)
				SU.soldier_regen(store, this)
				if store.tick_ts - this.hover.ts >= this.hover.cooldown then
					this.hover.ts = store.tick_ts
					this.hover.cooldown = U.frandom(this.hover.cooldown_min, this.hover.cooldown_max + 1e-9)
					this.nav_path.spi = this.hover.random_subpath and math.random(1, 3) or this.nav_path.spi
					this.nav_path.ni = this.hover.oni + math.random(this.hover.random_ni * -1, this.hover.random_ni)
					local next_pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
					if next_pos and P:is_node_valid(this.nav_path.pi, this.nav_path.ni) and GR:cell_is(next_pos.x, next_pos.y, TERRAIN_LAND) and 
					not GR:cell_is(next_pos.x, next_pos.y, TERRAIN_NOWALK) then
						U.set_destination(this, next_pos)
					end
				end
			end
		end

		::label_43_1::

		coroutine.yield()
	end
end

scripts.KR5Bomb = {}
function scripts.KR5Bomb.insert(this, store, script)
	local b = this.bullet
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)

	if b.rotation_speed then
		b.rotation_speed = b.rotation_speed * (b.to.x > b.from.x and -1 or 1)
	end

	if b.hide_radius then
		this.render.sprites[1].hidden = true
	end

	local s = this.render.sprites[1]
	s.flip_x = b.to.x < b.from.x
	if s.animated then
		s.ts = store.tick_ts
	end

	return true
end

function scripts.KR5Bomb.update(this, store, script)
	local b = this.bullet
	local dradius = b.damage_radius

	if b.level and b.level > 0 then
		if b.damage_radii then
			b.damage_radius = b.damage_radii[b.level]
		elseif b.damage_radius_inc then
			dradius = dradius + b.level * b.damage_radius_inc
		end
	end

	local ps
	if b.particles_name then
		ps = {}
		if type(b.particles_name) == "table" then
			for i, value in ipairs(b.particles_name) do
				local p = E:create_entity(value)
				p.particle_system.emit = true
				p.particle_system.track_id = this.id
				queue_insert(store, p)
				table.insert(ps, p)
			end
		else
			local p = E:create_entity(b.particles_name)
			p.particle_system.emit = true
			p.particle_system.track_id = this.id
			queue_insert(store, p)
			table.insert(ps, p)
		end
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
		if ps then
			for i, p in ipairs(ps) do
				p.particle_system.flip_x = this.render.sprites[1].flip_x
				p.particle_system.emit_direction = this.render.sprites[1].r
			end
		end

		if b.hide_radius then
			this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
		end
	end

	b.use_dist_factor = nil
	if not b.damage_decay_random then
		local upg = UP:get_upgrade("towers_improved_formulas")
		local source = store.entities[b.source_id]
		if upg and (source and source.tower or this.from_tower) then
			b.damage_min = b.damage_max
			b.damages_min = b.damages_max
			b.damage_min_inc = b.damage_max_inc
		else
			b.use_dist_factor = true
		end
	end
	
	local targets = U.find_targets_in_range(store.entities, b.to, 0, b.damage_radius, b.vis_flags, b.vis_bans)
	if targets then
		for _, target in ipairs(targets) do
			local d = SU.create_bullet_damage(b, target.id, b.source_id, store)
			queue_damage(store, d)
	
			if this.up_shock_and_awe_chance and band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, bor(F_BOSS, F_CLIFF, F_FLYING)) == 0 and 
			math.random() < this.up_shock_and_awe_chance then
				local mod = E:create_entity("mod_shock_and_awe")
				mod.modifier.target_id = target.id
				queue_insert(store, mod)
			end
	
			if b.mod or b.mods then
				local mods = b.mods or {
					b.mod
				}
				for i, mod_name in ipairs(mods) do
					local mod = E:create_entity(mod_name)
					mod.modifier.target_id = target.id
					mod.modifier.source_id = b.source_id
					mod.modifier.level = b.level
					mod.modifier.source_damage = d
					queue_insert(store, mod)
				end
			end
		end
	end

	local p = SU.create_bullet_pop(store, this)
	if p then
		queue_insert(store, p)
	end

	local s = this.render.sprites[1]
	local cell_type = GR:cell_type(b.to.x, b.to.y)

	if b.hit_fx_water and band(cell_type, TERRAIN_WATER) ~= 0 then
		S:queue(this.sound_events.hit_water)
		local water_fx = E:create_entity(b.hit_fx_water)
		water_fx.pos.x, water_fx.pos.y = b.to.x, b.to.y
		water_fx.render.sprites[1].ts = store.tick_ts
		water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
		water_fx.render.sprites[1].flip_x = s.flip_x
		queue_insert(store, water_fx)
	elseif b.hit_fx then
		S:queue(this.sound_events.hit)
		local sfx = E:create_entity(b.hit_fx)
		sfx.pos = V.vclone(b.to)
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
		sfx.render.sprites[1].flip_x = s.flip_x
		queue_insert(store, sfx)
	end

	if b.hit_decal and band(cell_type, TERRAIN_WATER) == 0 then
		SU.create_bullet_hit_decal(this, store, s.flip_x)
	end

	SU.create_bullet_hit_payload(this, store, s.flip_x)

	if ps then
		for i, p in ipairs(ps) do
			p.particle_system.emit = false
		end
	end
	queue_remove(store, this)
end

scripts.bullet_without_trajectory = {}
function scripts.bullet_without_trajectory.update(this, store, script)
	local b = this.bullet
	b.ts = store.tick_ts
	local source = store.entities[b.source_id]
	
	if b.hit_time and b.hit_time > 0 then
		U.y_wait(store, b.hit_time)
	end

	local target = store.entities[b.target_id]
	if target then
		this.pos.x, this.pos.y = target.pos.x, target.pos.y
		local flip_sign = target.render and target.render.sprites[1].flip_x and -1 or 1
		if not b.ignore_hit_offset and target.unit and target.unit.hit_offset then
			this.pos.x, this.pos.y = this.pos.x + target.unit.hit_offset.x * flip_sign, this.pos.y + target.unit.hit_offset.y
		end
		b.to.x, b.to.y = this.pos.x, this.pos.y
	else
		this.pos.x, this.pos.y = b.to.x, b.to.y
	end

	SU.make_bullet_damage_targets(this, store, target)
	SU.create_bullet_hit_fx(this, store, target)
	SU.create_bullet_hit_decal(this, store)
	SU.create_bullet_hit_payload(this, store)
	local pop = SU.create_bullet_pop(store, this)
	if pop then
		queue_insert(store, pop)
	end

	queue_remove(store, this)
end

scripts.decal_fade = {}
function scripts.decal_fade.update(this, store, script)
	local start_ts = store.tick_ts
	for i, s in pairs(this.render.sprites) do
		s.ts = start_ts
	end

	local fade_out = 0
	if this.tween then
		this.tween.props[1].sprite_id = {}
		for i, s in pairs(this.render.sprites) do
			table.insert(this.tween.props[1].sprite_id, i)
		end
		this.tween.remove = false
		if this.fade_out and this.fade_out > 0 then
			fade_out = this.fade_out
		end
		if this.fade_in and this.fade_in > 0 then
			this.tween.disabled = false
			this.tween.ts = store.tick_ts
			this.tween.props[1].keys = {
				{
					0,
					0
				},
				{
					this.fade_in,
					255
				}
			}
		elseif fade_out > 0 then
			this.tween.disabled = true
		else
			this.tween = nil
		end
	end

	local function loop(duration)
		while store.tick_ts - start_ts <= duration do
			coroutine.yield()
		end
	end

	loop(this.duration - fade_out)

	if fade_out > 0 then
		this.tween.remove = true
		this.tween.reverse = true
		this.tween.disabled = false
		this.tween.ts = store.tick_ts
		this.tween.props[1].keys = {
			{
				0,
				0
			},
			{
				fade_out,
				255
			}
		}
	else
		queue_remove(store, this)
		return
	end

	loop(this.duration)
end

function scripts.hero_basic.get_info_timed(this)
	local attack
	local min, max = 0, 0
	local damage_type = DAMAGE_NONE
	for i, a in pairs(this.timed_attacks.list) do
		if a.basic_attack then
			attack = a
			break
		end
	end
	if attack then
		if attack.damage_min then
			min, max = attack.damage_min * this.unit.damage_factor, attack.damage_max * this.unit.damage_factor
		elseif attack.bullet then
			local b = E:get_template(attack.bullet)
			min, max = b.bullet.damage_min, b.bullet.damage_max
			if b.bullet.use_unit_damage_factor then
				min, max = min * this.unit.damage_factor, max * this.unit.damage_factor
			end
			damage_type = b.bullet.damage_type
		end
		if attack.damage_type then
			damage_type = attack.damage_type
		end
	end

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_type = damage_type,
		damage_icon = this.info.damage_icon,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		respawn = this.health.dead_lifetime
	}
end

return scripts