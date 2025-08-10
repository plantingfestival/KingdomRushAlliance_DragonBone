local log = require("klua.log"):new("script_utils")
local log_xp = log.xp or log:new("xp")

require("klua.table")

local km = require("klua.macros")
local signal = require("hump.signal")
local AC = require("achievements")
local E = require("entity_db")
local GR = require("grid_db")
local GS = require("game_settings")
local P = require("path_db")
local S = require("sound_db")
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

local function ui_click_proxy_add(proxy, dest)
	if not proxy.ui then
		log.error("cannot proxy. entity has no ui component: (%s)%s", proxy.id, proxy.template_name)

		return
	end

	proxy.ui.click_proxies = proxy.ui.click_proxies or {}

	table.insert(proxy.ui.click_proxies, dest)
end

local function ui_click_proxy_remove(proxy, dest)
	if proxy.ui and proxy.ui.click_proxies then
		table.removeobject(proxy.ui.click_proxies, dest)
	end
end

local function remove_modifiers(store, entity, mod_name, exclude_name)
	local mods = table.filter(store.entities, function(k, v)
		return v.modifier and v.modifier.target_id == entity.id and (not mod_name or mod_name == v.template_name) and (not exclude_name or exclude_name ~= v.template_name)
	end)

	for _, m in pairs(mods) do
		queue_remove(store, m)
	end
end

local function remove_modifiers_by_type(store, entity, mod_type, exclude_name)
	local mods = table.filter(store.entities, function(k, v)
		return v.modifier and v.modifier.target_id == entity.id and v.modifier.mod_type == mod_type and (not exclude_name or exclude_name ~= v.template_name)
	end)

	for _, m in pairs(mods) do
		queue_remove(store, m)
	end
end

local function remove_auras(store, entity)
	local auras = table.filter(store.entities, function(k, v)
		return v.aura and v.aura.track_source and v.aura.source_id == entity.id
	end)

	for _, a in pairs(auras) do
		queue_remove(store, a)
	end
end

local function hide_modifiers(store, entity, keep, exclude_mod)
	local mods = table.filter(store.entities, function(k, v)
		return v.modifier and v.modifier.target_id == entity.id and v ~= exclude_mod
	end)

	for _, m in pairs(mods) do
		U.sprites_hide(m, nil, nil, keep)
	end
end

local function show_modifiers(store, entity, restore, exclude_mod)
	local mods = table.filter(store.entities, function(k, v)
		return v.modifier and v.modifier.target_id == entity.id and v ~= exclude_mod
	end)

	for _, m in pairs(mods) do
		U.sprites_show(m, nil, nil, restore)
	end
end

local function hide_auras(store, entity, keep)
	local auras = table.filter(store.entities, function(k, v)
		return v.aura and v.aura.track_source and v.aura.source_id == entity.id
	end)

	for _, a in pairs(auras) do
		U.sprites_hide(a, nil, nil, keep)
	end
end

local function show_auras(store, entity, restore)
	local auras = table.filter(store.entities, function(k, v)
		return v.aura and v.aura.track_source and v.aura.source_id == entity.id
	end)

	for _, a in pairs(auras) do
		U.sprites_show(a, nil, nil, restore)
	end
end

local function unit_dodges(store, this, ranged_attack, attack, source)
	if not this.dodge then
		return false
	end

	this.dodge.last_check_ts = store.tick_ts

	if not this.unit.is_stunned and (not this.dodge.requires_magic or this.enemy and this.enemy.can_do_magic) and (not ranged_attack or this.dodge.ranged) and (not this.dodge.cooldown or store.tick_ts - this.dodge.ts > this.dodge.cooldown) and (not attack or not attack.damage_type or band(attack.damage_type, DAMAGE_NO_DODGE) == 0) and math.random() <= this.dodge.chance and (not this.dodge.can_dodge or this.dodge.can_dodge(store, this, ranged_attack, attack, source)) then
		this.dodge.last_doge_ts = store.tick_ts
		this.dodge.last_attack = attack
		this.dodge.active = true

		return true
	end

	return false
end

local function stun_inc(this)
	if this and this.unit and not this.unit.ignore_stun then
		local u = this.unit

		u.stun_count = u.stun_count + 1

		if u.stun_count > 0 then
			u.is_stunned = true
		end
	end
end

local function stun_dec(this, remove_all)
	if this and this.unit and not this.unit.ignore_stun then
		local u = this.unit

		u.stun_count = remove_all and 0 or u.stun_count - 1

		if u.stun_count < 1 then
			u.is_stunned = nil
			u.stun_count = 0
		end
	end
end

local function armor_inc(this, value)
	if not this.health.raw_armor then
		this.health.raw_armor = this.health.armor
	end

	this.health.raw_armor = this.health.raw_armor + value
	this.health.armor = km.clamp(0, 1, this.health.raw_armor)
end

local function armor_dec(this, value)
	armor_inc(this, -1 * value)
end

local function magic_armor_inc(this, value)
	if not this.health.raw_magic_armor then
		this.health.raw_magic_armor = this.health.magic_armor
	end

	this.health.raw_magic_armor = this.health.raw_magic_armor + value
	this.health.magic_armor = km.clamp(0, 1, this.health.raw_magic_armor)
end

local function magic_armor_dec(this, value)
	magic_armor_inc(this, -1 * value)
end

local function spiked_armor_inc(this, value)
	if not this.health.raw_spiked_armor then
		this.health.raw_spiked_armor = this.health.spiked_armor
	end

	this.health.raw_spiked_armor = this.health.raw_spiked_armor + value
	this.health.spiked_armor = km.clamp(0, 1, this.health.raw_spiked_armor)
end

local function spiked_armor_dec(this, value)
	spiked_armor_inc(this, -1 * value)
end

local function tower_block_inc(this)
	if this and this.tower and not this.tower_holder then
		local t = this.tower

		t.block_count = t.block_count + 1

		if t.block_count > 0 then
			t.blocked = true

			if this.ui then
				this.ui.can_click = false
			end
		end
	end
end

local function tower_block_dec(this, remove_all)
	if this and this.tower and not this.tower_holder then
		local t = this.tower

		t.block_count = remove_all and 0 or t.block_count - 1

		if t.block_count < 1 then
			t.blocked = nil
			t.block_count = 0

			if this.ui then
				this.ui.can_click = true
			end
		end
	end
end

local function tower_update_silenced_powers(store, this)
	for k, pow in pairs(this.powers) do
		local pa = this.attacks.list[pow.attack_idx]

		if pa then
			if not this.tower.can_do_magic and not pa.silence_ts then
				pa.silence_ts = store.tick_ts
			elseif this.tower.can_do_magic and pa.silence_ts then
				pa.ts = store.tick_ts - (pa.silence_ts - pa.ts)
				pa.silence_ts = nil
			end
		end
	end
end

local function do_death_spawns(store, this)
	if this.death_spawns.fx then
		local fx = E:create_entity(this.death_spawns.fx)

		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts

		if this.death_spawns.fx_flip_to_source and this.render and this.render.sprites[1] then
			fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x
		end

		queue_insert(store, fx)
	end

	for i = 1, this.death_spawns.quantity do
		local s = E:create_entity(this.death_spawns.name)

		s.pos = V.vclone(this.pos)

		if this.death_spawns.spawn_animation and s.render then
			s.render.sprites[1].name = this.death_spawns.spawn_animation
		end

		if s.render and s.render.sprites[1] and this.render and this.render.sprites[1] then
			s.render.sprites[1].flip_x = this.render.sprites[1].flip_x
		end

		if s.nav_path then
			s.nav_path.pi = this.nav_path.pi

			local spread_nodes = this.death_spawns.spread_nodes

			if spread_nodes > 0 then
				s.nav_path.spi = km.zmod(this.nav_path.spi + i, 3)

				local node_offset = spread_nodes * -2 * math.floor(i / 3)

				s.nav_path.ni = this.nav_path.ni + node_offset + spread_nodes
			else
				s.nav_path.spi = this.nav_path.spi
				s.nav_path.ni = this.nav_path.ni + 2
			end
		end

		if this.death_spawns.offset then
			s.pos.x = s.pos.x + this.death_spawns.offset.x
			s.pos.y = s.pos.y + this.death_spawns.offset.y
		end

		queue_insert(store, s)
	end
end

local function delay_attack(store, attack, time)
	attack.ts = store.tick_ts - attack.cooldown + time - 1e-06
end

local function insert_sprite(store, name, pos, flip_x, ts_offset)
	local e = E:create_entity(name)

	e.pos.x, e.pos.y = pos.x, pos.y

	if e.render then
		for _, s in pairs(e.render.sprites) do
			s.ts = store.tick_ts + (ts_offset or 0)
			s.flip_x = flip_x
		end
	end

	queue_insert(store, e)

	return e
end

local function fade_out_entity(store, entity, delay, duration, delete_after)
	duration = duration or 2

	if entity.tween then
		entity.tween.disabled = true
		entity.tween = nil
		-- log.error("entity %s already has tween, cannot be faded out.", entity.template_name)
	end

	entity.tween = E:clone_c("tween")
	entity.tween.ts = store.tick_ts

	if delete_after and entity.health then
		entity.health.ignore_delete_after = true
		entity.tween.remove = true
	end

	local p = E:clone_c("tween_prop")

	p.keys = {
		{
			0,
			255
		},
		{
			delay,
			255
		},
		{
			delay + duration,
			0
		}
	}

	for i, s in ipairs(entity.render.sprites) do
		local pp = table.deepclone(p)

		pp.sprite_id = i
		entity.tween.props[i] = pp
	end
end

local function create_pop(store, pos, pop)
	local name = pop[math.random(1, #pop)]
	local e = E:create_entity(name)

	e.pos = V.v(pos.x, pos.y + e.pop_y_offset)
	e.render.sprites[1].r = math.random(-21, 21) * math.pi / 180
	e.render.sprites[1].ts = store.tick_ts

	return e
end

local function create_bullet_pop(store, this)
	local b = this.bullet

	if b.pop and (not b.pop_chance or math.random() < b.pop_chance) then
		return create_pop(store, this.pos, b.pop)
	end

	return nil
end

local function create_bullet_damage(bullet, target_id, source_id)
	local d = E:create_entity("damage")

	d.damage_type = bullet.damage_type
	d.reduce_armor = bullet.reduce_armor
	d.reduce_magic_armor = bullet.reduce_magic_armor

	local vmin, vmax = bullet.damage_min, bullet.damage_max

	if bullet.level and bullet.level > 0 then
		if type(vmin) == "table" then
			vmin = table.safe_index(vmin, bullet.level)
			vmax = table.safe_index(vmax, bullet.level)
		else
			if bullet.damage_min_inc then
				vmin = vmin + bullet.damage_min_inc * bullet.level
			end

			if bullet.damage_max_inc then
				vmax = vmax + bullet.damage_max_inc * bullet.level
			end

			if bullet.damage_inc then
				vmax = vmax + bullet.damage_inc * bullet.level
				vmin = vmin + bullet.damage_inc * bullet.level
			end
		end
	end

	local value = math.ceil(U.frandom(vmin, vmax))

	d.value = math.max(1, math.ceil(bullet.damage_factor * value))
	d.target_id = target_id
	d.source_id = source_id
	d.xp_gain_factor = bullet.xp_gain_factor
	d.xp_dest_id = bullet.xp_dest_id
	d.pop = bullet.pop
	d.pop_chance = bullet.pop_chance
	d.pop_conds = bullet.pop_conds
	d.track_damage = bullet.track_damage

	return d
end

local function create_attack_damage(a, target_id, source_id)
	local vmax, vmin = a.damage_max, a.damage_min

	if a.level and a.level > 0 then
		if a.damage_max_inc then
			vmax = vmax + a.damage_max_inc * a.level
		end

		if a.damage_min_inc then
			vmin = vmin + a.damage_min_inc * a.level
		end

		if a.damage_inc then
			vmax = vmax + a.damage_inc * a.level
			vmin = vmin + a.damage_inc * a.level
		end
	end

	local d = E:create_entity("damage")

	d.value = math.ceil(U.frandom(vmin, vmax))
	d.damage_type = a.damage_type
	d.target_id = target_id
	d.source_id = source_id

	return d
end

local function initial_parabola_speed(from, to, time, g)
	return V.v((to.x - from.x) / time, (to.y - from.y - 0.5 * g * time * time) / time)
end

local function position_in_parabola(t, from, speed, g)
	local x = speed.x * t + from.x
	local y = g * t * t / 2 + speed.y * t + from.y

	return x, y
end

local function parabola_y(phase, from_y, to_y, max_y)
	local max_y = math.max(max_y, from_y, to_y)
	local reverse = to_y < from_y
	local offset = reverse and to_y or from_y
	local xc = (reverse and from_y or to_y) - offset
	local M = reverse and max_y - to_y or max_y - from_y
	local C = (reverse and from_y or to_y) - offset
	local x = reverse and 1 - phase or phase
	local b

	b = (M < C or C < 0.0001) and 1 or 2 / C * (M - math.sqrt(M * M - M * C))

	local y = M * 4 / (b * b) * x * (b - x)

	return y + offset
end

local function soldier_interrupted(this)
	return this.nav_rally.new or this.health.dead or this.unit.is_stunned
end

local function y_soldier_wait(store, this, time)
	return U.y_wait(store, time, function(store, time)
		return soldier_interrupted(this)
	end)
end

local function y_soldier_animation_wait(this)
	while not U.animation_finished(this) do
		if soldier_interrupted(this) then
			return true
		end

		coroutine.yield()
	end

	return false
end

local function hero_will_teleport(this, new_rally_pos)
	local tp = this.teleport
	local r = new_rally_pos

	return tp and not tp.disabled and V.dist(r.x, r.y, this.pos.x, this.pos.y) > tp.min_distance
end

local function hero_will_launch_move(this, new_rally_pos)
	local lm = this.launch_movement
	local r = new_rally_pos

	return lm and not lm.disabled and V.dist(r.x, r.y, this.pos.x, this.pos.y) > lm.min_distance
end

local function hero_will_transfer(this, new_rally_pos)
	local tr = this.transfer
	local r = new_rally_pos

	return tr and not tr.disabled and V.dist(r.x, r.y, this.pos.x, this.pos.y) > tr.min_distance
end

local function y_hero_walk_waypoints(store, this, animation)
	local animation = animation or "walk"
	local r = this.nav_rally
	local n = this.nav_grid
	local dest = r.pos
	local x_to_flip = KR_GAME == "kr5" and 2 or 0
	local last_af

	while not V.veq(this.pos, dest) do
		local w = table.remove(n.waypoints, 1) or dest
		local unsnap = #n.waypoints > 0

		U.set_destination(this, w)

		local an, af = U.animation_name_facing_point(this, animation, this.motion.dest)
		local new_af = af

		if x_to_flip > math.abs(this.pos.x - this.motion.dest.x) then
			new_af = last_af
		end

		U.animation_start(this, an, new_af, store.tick_ts, true)

		last_af = new_af

		while not this.motion.arrived do
			if this.health.dead and not this.health.ignore_damage then
				return true
			end

			if r.new then
				return false
			end

			U.walk(this, store.tick_length, nil, unsnap)
			coroutine.yield()

			this.motion.speed.x, this.motion.speed.y = 0, 0
		end
	end
end

local function y_hero_new_rally(store, this)
	local r = this.nav_rally

	if r.new then
		r.new = false

		U.unblock_target(store, this)

		if this.sound_events then
			S:queue(this.sound_events.change_rally_point)
		end

		if hero_will_teleport(this, r.pos) then
			local rp = V.vclone(r.pos)
			local tp = this.teleport
			local vis_bans = this.vis.bans

			this.vis.bans = F_ALL
			this.health.ignore_damage = true
			this.health_bar.hidden = true

			S:queue(tp.sound)

			if tp.fx_out then
				local fx = E:create_entity(tp.fx_out)

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts

				if fx.tween then
					fx.tween.ts = store.tick_ts
				end

				queue_insert(store, fx)
			end

			U.y_animation_play(this, tp.animations[1], nil, store.tick_ts)

			if tp.delay > 0 then
				U.sprites_hide(this, nil, nil, true)
				U.y_wait(store, tp.delay)
				U.sprites_show(this, nil, nil, true)
			end

			this.pos.x, this.pos.y = rp.x, rp.y

			U.set_destination(this, this.pos)

			this.motion.speed.x, this.motion.speed.y = 0, 0

			if tp.fx_in then
				local fx = E:create_entity(tp.fx_in)

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts

				if fx.tween then
					fx.tween.ts = store.tick_ts
				end

				queue_insert(store, fx)
			end

			U.y_animation_play(this, tp.animations[2], nil, store.tick_ts)

			this.health_bar.hidden = false
			this.vis.bans = vis_bans
			this.health.ignore_damage = false

			r.pos.x, r.pos.y = rp.x, rp.y
			r.center.x, r.center.y = rp.x, rp.y
			r.new = false
			return false
		elseif hero_will_launch_move(this, r.pos) then
			local rp = V.vclone(r.pos)
			local lm = this.launch_movement
			local vis_bans = this.vis.bans
			this.vis.bans = F_ALL
			this.health.ignore_damage = true
			this.health_bar.hidden = true
			if lm.launch_sound then
				S:queue(lm.launch_sound, lm.launch_args)
			end
			local an, af = U.animation_name_facing_point(this, lm.animations[1], rp)
			U.y_animation_play(this, an, af, store.tick_ts)
			if lm.launch_entity then
				local entity = E:create_entity(lm.launch_entity)
				if lm.launch_entity_offset then
					entity.pos.x, entity.pos.y = this.pos.x + (af and -1 or 1) * lm.launch_entity_offset.x, this.pos.y + lm.launch_entity_offset.y
				else
					entity.pos.x, entity.pos.y = this.pos.x, this.pos.y
				end
				if lm.launch_entity_delay then
					local controller = E:create_entity("entities_delay_controller")
					controller.start_ts = store.tick_ts
					controller.delays = { lm.launch_entity_delay }
					controller.entities = { entity }
					queue_insert(store, controller)
				else
					entity.render.sprites[1].ts = store.tick_ts
					if entity.tween then
						entity.tween.ts = store.tick_ts
					end
					queue_insert(store, entity)
				end
			end
			local ps
			if lm.particles_name then
				ps = E:create_entity(lm.particles_name)
				ps.particle_system.track_id = this.id
				queue_insert(store, ps)
			end
			for i, sprite in ipairs(this.render.sprites) do
				if sprite.is_shadow then
					sprite.hidden = true
				else
					sprite._orignial_z = sprite.z
					sprite.z = Z_FLYING_HEROES
				end
			end
			an, af = U.animation_name_facing_point(this, lm.animations[2], rp)
			U.animation_start(this, an, af, store.tick_ts, lm.loop_on_the_way)
			local from = V.vclone(this.pos)
			local speed = initial_parabola_speed(from, rp, lm.flight_time, lm.g)
			local flight_ts = store.tick_ts
			while store.tick_ts - flight_ts + store.tick_length < lm.flight_time do
				coroutine.yield()
				this.pos.x, this.pos.y = position_in_parabola(store.tick_ts - flight_ts, from, speed, lm.g)
			end
			if ps then
				queue_remove(store, ps)
			end
			this.pos.x, this.pos.y = rp.x, rp.y
			U.set_destination(this, this.pos)
			this.motion.speed.x, this.motion.speed.y = 0, 0
			if lm.land_sound then
				S:queue(lm.land_sound, lm.land_args)
			end
			if lm.land_entity then
				local entity = E:create_entity(lm.land_entity)
				if lm.land_entity_offset then
					entity.pos.x, entity.pos.y = this.pos.x + (af and -1 or 1) * lm.land_entity_offset.x, this.pos.y + lm.land_entity_offset.y
				else
					entity.pos.x, entity.pos.y = this.pos.x, this.pos.y
				end
				if lm.land_entity_delay then
					local controller = E:create_entity("entities_delay_controller")
					controller.start_ts = store.tick_ts
					controller.delays = { lm.land_entity_delay }
					controller.entities = { entity }
					queue_insert(store, controller)
				else
					entity.render.sprites[1].ts = store.tick_ts
					if entity.tween then
						entity.tween.ts = store.tick_ts
					end
					queue_insert(store, entity)
				end
			end
			for i, sprite in ipairs(this.render.sprites) do
				if sprite.is_shadow then
					sprite.hidden = nil
				else
					sprite.z = sprite._orignial_z
					sprite._orignial_z = nil
				end
			end
			U.y_animation_play(this, lm.animations[3], nil, store.tick_ts)
			this.health_bar.hidden = false
			this.vis.bans = vis_bans
			this.health.ignore_damage = false
			r.pos.x, r.pos.y = rp.x, rp.y
			r.center.x, r.center.y = rp.x, rp.y
			r.new = false
			return false
		elseif hero_will_transfer(this, r.pos) then
			local tr = this.transfer
			local interrupt = false
			local ps
			local vis_bans = this.vis.bans

			this.vis.bans = F_ALL
			this.health.ignore_damage = true
			this.health_bar.hidden = true

			S:queue(tr.sound_loop)
			U.y_animation_play(this, tr.animations[1], nil, store.tick_ts)

			this.motion.max_speed = this.motion.max_speed * tr.speed_factor

			if tr.particles_name then
				ps = E:create_entity(tr.particles_name)
				ps.particle_system.track_id = this.id

				queue_insert(store, ps)
			end

			repeat
				r.new = false

				if y_hero_walk_waypoints(store, this, tr.animations[2]) then
					interrupt = true

					break
				end
			until this.motion.arrived

			if tr.particles_name then
				ps.particle_system.emit = false
				ps.particle_system.source_lifetime = 1
			end

			this.motion.max_speed = this.motion.max_speed / tr.speed_factor

			S:stop(tr.sound_loop)
			U.y_animation_play(this, tr.animations[3], nil, store.tick_ts)

			this.health_bar.hidden = false
			this.vis.bans = vis_bans
			this.health.ignore_damage = false

			return interrupt
		else
			local vis_bans = this.vis.bans
			local prev_immune = this.health.immune_to

			this.vis.bans = F_ALL
			this.health.immune_to = r.immune_to

			local out = y_hero_walk_waypoints(store, this)

			U.animation_start(this, "idle", nil, store.tick_ts, true)

			this.vis.bans = vis_bans
			this.health.immune_to = prev_immune

			return out
		end
	end
end

local function hero_gain_xp_from_skill(this, skill)
	if skill.level then
		local amount

		if skill.xp_gain then
			amount = skill.xp_gain[skill.level]
		else
			amount = skill.level * skill.xp_gain_factor
		end

		this.hero.xp_queued = this.hero.xp_queued + amount

		if log_xp.level >= log_xp.DEBUG_LEVEL then
			local skill_name

			for k, v in pairs(this.hero.skills) do
				if v == skill then
					skill_name = k

					break
				end
			end

			log_xp.debug("XP QUEUE SKILL: (%s)%s xp:%.2f skill:%s level:%s factor:%.2f", this.id, this.template_name, amount, skill_name, skill.level, skill.xp_gain_factor)
		end
	end
end

local function hero_gain_xp(this, value, desc)
	this.hero.xp_queued = this.hero.xp_queued + value

	log_xp.debug("XP QUEUE MANUAL: (%s)%s xp:%.2f from:%s", this.id, this.template_name, value, desc)
end

local function hero_level_up(store, this)
	local h = this.hero

	if h.xp_queued == 0 then
		return false
	end

	local expected_level_multiplier = 1
	local expected_level = GS.hero_level_expected[store.level_idx]

	if expected_level then
		local level_diff = h.level - expected_level

		if level_diff < 0 then
			expected_level_multiplier = GS.hero_level_expected_multipliers_below[km.clamp(1, 2, -level_diff)]
		elseif level_diff > 0 then
			expected_level_multiplier = GS.hero_level_expected_multipliers_above[km.clamp(1, 2, level_diff)]
		end
	end

	local difficulty_multiplier = GS.hero_xp_gain_per_difficulty_mode[store.level_difficulty]
	local net_xp = h.xp_queued * expected_level_multiplier * difficulty_multiplier

	log_xp.debug("XP+: (%s)%s xp:%07.2f + net_xp:%6.2f = %8.2f | net_xp = xp_queued:%s * exp_lvl_mul:%s * diff_mul:%s", this.id, this.template_name, h.xp, km.round(net_xp), h.xp + km.round(net_xp), h.xp_queued, expected_level_multiplier, difficulty_multiplier)

	h.xp = h.xp + km.round(net_xp)
	h.xp_queued = 0

	if h.level >= 10 or h.xp < GS.hero_xp_thresholds[h.level] then
		return false
	end

	this.hero.level = this.hero.level + 1

	this.hero.fn_level_up(this, store)
	signal.emit("hero-level-increased", this)
	S:queue("HeroLevelUp")

	return true
end

local function y_hero_death_and_respawn(store, this)
	local h = this.health
	local he = this.hero

	this.ui.can_click = false

	local death_ts = store.tick_ts
	local dead_lifetime = h.dead_lifetime

	U.unblock_target(store, this)

	if this.selfdestruct and not this.selfdestruct.disabled and band(h.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE_BOSS)) == 0 then
		local sd = this.selfdestruct

		this.unit.hide_after_death = true
		this.health_bar.hidden = true
		dead_lifetime = sd.dead_lifetime or dead_lifetime

		U.animation_start(this, sd.animation, nil, store.tick_ts)
		S:queue(this.sound_events.death, this.sound_events.death_args)
		S:queue(sd.sound, sd.sound_args)
		U.y_wait(store, sd.hit_time)
		S:queue(sd.sound_hit)

		if sd.hit_fx then
			insert_sprite(store, sd.hit_fx, this.pos)
		end

		if sd.xp_from_skill then
			hero_gain_xp_from_skill(this, this.hero.skills[sd.xp_from_skill])
		end

		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, sd.damage_radius, sd.vis_flags, sd.vis_bans)

		if targets then
			for _, t in pairs(targets) do
				local d = E:create_entity("damage")

				d.damage_type = sd.damage_type
				d.value = sd.damage and sd.damage or math.random(sd.damage_min, sd.damage_max)
				d.source_id = this.id
				d.target_id = t.id

				queue_damage(store, d)
			end
		end

		U.y_animation_wait(this)
	elseif band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE_BOSS)) ~= 0 then
		this.unit.hide_after_death = true

		local fx = E:create_entity("fx_soldier_desintegrate")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	elseif band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
		this.unit.hide_after_death = true
	elseif band(h.last_damage_types, bor(DAMAGE_HOST)) ~= 0 then
		this.unit.hide_after_death = true

		S:queue("DeathEplosion")

		local fx = E:create_entity("fx_unit_explode")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]

		queue_insert(store, fx)

		if this.unit.show_blood_pool and this.unit.blood_color ~= BLOOD_NONE then
			local decal = E:create_entity("decal_blood_pool")

			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			decal.render.sprites[1].name = this.unit.blood_color

			queue_insert(store, decal)
		end
	else
		S:queue(this.sound_events.death, this.sound_events.death_args)
		U.y_animation_play(this, "death", nil, store.tick_ts, 1)
	end

	this.health.death_finished_ts = store.tick_ts

	if this.unit.hide_after_death then
		for _, s in pairs(this.render.sprites) do
			s.hidden = true
		end
	end

	local tombstone

	if he and he.tombstone_show_time then
		while store.tick_ts - death_ts < he.tombstone_show_time do
			coroutine.yield()
		end

		tombstone = E:create_entity(he.tombstone_decal)
		tombstone.pos = this.pos

		queue_insert(store, tombstone)

		for _, s in pairs(this.render.sprites) do
			s.hidden = true
		end
	end

	while dead_lifetime > store.tick_ts - death_ts do
		coroutine.yield()
	end

	this.health.death_finished_ts = nil

	if tombstone then
		queue_remove(store, tombstone)
	end

	if he and he.respawn_point then
		local p = he.respawn_point

		this.pos.x, this.pos.y = p.x, p.y
		this.nav_rally.pos.x, this.nav_rally.pos.y = p.x, p.y
		this.nav_rally.center.x, this.nav_rally.center.y = p.x, p.y
		this.nav_rally.new = false
	end

	for _, s in pairs(this.render.sprites) do
		s.hidden = false
	end

	h.ignore_damage = true

	S:queue(this.sound_events.respawn)
	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	this.ui.can_click = true
	h.dead = false
	h.hp = h.hp_max
	h.ignore_damage = false
end

local function y_hero_death_and_respawn_kr5(store, this)
	local h = this.health
	local he = this.hero

	this.ui.can_click = false

	local death_ts = store.tick_ts
	local dead_lifetime = h.dead_lifetime

	U.unblock_target(store, this)

	if this.selfdestruct and not this.selfdestruct.disabled and band(h.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE_BOSS)) == 0 then
		local sd = this.selfdestruct

		this.unit.hide_after_death = true
		this.health_bar.hidden = true
		dead_lifetime = sd.dead_lifetime or dead_lifetime

		U.animation_start(this, sd.animation, nil, store.tick_ts)
		S:queue(this.sound_events.death, this.sound_events.death_args)
		S:queue(sd.sound, sd.sound_args)
		U.y_wait(store, sd.hit_time)
		S:queue(sd.sound_hit)

		if sd.hit_fx then
			insert_sprite(store, sd.hit_fx, this.pos)
		end

		if sd.xp_from_skill then
			hero_gain_xp_from_skill(this, this.hero.skills[sd.xp_from_skill])
		end

		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, sd.damage_radius, sd.vis_flags, sd.vis_bans)

		if targets then
			for _, t in pairs(targets) do
				local d = E:create_entity("damage")

				d.damage_type = sd.damage_type
				d.value = sd.damage and sd.damage or math.random(sd.damage_min, sd.damage_max)
				d.source_id = this.id
				d.target_id = t.id

				queue_damage(store, d)
			end
		end

		U.y_animation_wait(this)
	elseif band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE_BOSS)) ~= 0 then
		this.unit.hide_after_death = true

		local fx = E:create_entity("fx_soldier_desintegrate")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	elseif band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
		this.unit.hide_after_death = true
	elseif band(h.last_damage_types, bor(DAMAGE_HOST)) ~= 0 then
		this.unit.hide_after_death = true

		S:queue("DeathEplosion")

		local fx = E:create_entity("fx_unit_explode")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]

		queue_insert(store, fx)

		if this.unit.show_blood_pool and this.unit.blood_color ~= BLOOD_NONE then
			local decal = E:create_entity("decal_blood_pool")

			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			decal.render.sprites[1].name = this.unit.blood_color

			queue_insert(store, decal)
		end
	else
		S:queue(this.sound_events.death, this.sound_events.death_args)

		if this.unit.death_animation then
			U.animation_start(this, this.unit.death_animation, nil, store.tick_ts, false)
		else
			U.animation_start(this, "death", nil, store.tick_ts, false)
		end
	end

	if not he.tombstone_concurrent_with_death then
		U.y_animation_wait(this)

		this.health.death_finished_ts = store.tick_ts

		if this.unit.hide_after_death then
			for _, s in pairs(this.render.sprites) do
				s.hidden = true
			end
		end
	end

	local tombstone

	if he and he.tombstone_show_time then
		while store.tick_ts - death_ts < he.tombstone_show_time do
			coroutine.yield()
		end

		tombstone = E:create_entity(he.tombstone_decal)

		if he.tombstone_force_over_path then
			local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {
				1,
				2,
				3
			}, true)
			local pi, spi, ni = unpack(nodes[1])
			local npos = P:node_pos(pi, spi, ni)

			tombstone.pos = npos
		else
			tombstone.pos = this.pos
		end

		for _, s in pairs(tombstone.render.sprites) do
			s.ts = store.tick_ts
		end

		queue_insert(store, tombstone)
	end

	if he.tombstone_concurrent_with_death then
		U.y_animation_wait(this)

		this.health.death_finished_ts = store.tick_ts
	end

	if this.unit.hide_after_death then
		for _, s in pairs(this.render.sprites) do
			s.hidden = true
		end
	end

	while dead_lifetime > store.tick_ts - death_ts do
		if this.force_respawn then
			this.force_respawn = nil

			break
		end

		coroutine.yield()
	end

	this.health.death_finished_ts = nil

	if he and he.tombstone_force_over_path then
		he.respawn_point = tombstone.pos
	end

	if tombstone and tombstone.tween then
		tombstone.tween.disabled = false
		tombstone.tween.ts = store.tick_ts
	end

	if he and he.tombstone_respawn_animation then
		U.animation_start(tombstone, he.tombstone_respawn_animation, nil, store.tick_ts)
	end

	if he and he.respawn_point then
		local p = he.respawn_point

		this.pos.x, this.pos.y = p.x, p.y
		this.nav_rally.pos.x, this.nav_rally.pos.y = p.x, p.y
		this.nav_rally.center.x, this.nav_rally.center.y = p.x, p.y
		this.nav_rally.new = false
	end

	for _, s in pairs(this.render.sprites) do
		if this.use_hidden_count_on_respawn and s.hidden_count then
			s.hidden = s.hidden_count > 0
		else
			s.hidden = false
		end
	end

	h.ignore_damage = true

	S:queue(this.sound_events.respawn)

	if he.respawn_animation then
		U.y_animation_play(this, he.respawn_animation, nil, store.tick_ts, 1)
	else
		U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)
	end

	if tombstone then
		queue_remove(store, tombstone)
	end

	this.health_bar.hidden = false
	this.ui.can_click = true
	h.dead = false
	this.force_respawn = nil
	h.hp = h.hp_max
	h.ignore_damage = false
end

local function y_reinforcement_fade_in(store, this)
	U.y_wait(store, fts(10))

	this.tween.disabled = true
end

local function y_reinforcement_fade_out(store, this)
	this.render.sprites[1].ts = store.tick_ts

	local offset = 50

	if this.render.sprites[1].flip_x then
		offset = -1 * offset
	end

	local o = V.v(this.pos.x + offset, this.pos.y)

	U.set_destination(this, o)

	local t_angle = offset > 0 and 0 or math.pi
	local an, af, ai = U.animation_name_for_angle(this, "walk", t_angle)

	U.animation_start(this, an, af, store.tick_ts, -1)

	this.tween.reverse = true
	this.tween.disabled = nil
	this.health.hp = 0

	while not this.motion.arrived do
		U.walk(this, store.tick_length)
		coroutine.yield()
	end
end

local function y_soldier_new_rally(store, this)
	local r = this.nav_rally
	local out = false
	local vis_bans = this.vis.bans
	local prev_immune = this.health.immune_to

	this.health.immune_to = r.immune_to
	this.vis.bans = F_ALL

	if r.new then
		r.new = false

		U.unblock_target(store, this)
		U.set_destination(this, r.pos)

		if r.delay_max then
			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop)

			if y_soldier_wait(store, this, math.random() * r.delay_max) then
				goto label_59_0
			end
		end

		local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

		U.animation_start(this, an, af, store.tick_ts, -1)

		while not this.motion.arrived do
			if this.health.dead or this.unit.is_stunned then
				out = true

				break
			end

			if r.new then
				out = false

				break
			end

			U.walk(this, store.tick_length)
			coroutine.yield()

			this.motion.speed.x, this.motion.speed.y = 0, 0
		end
	end

	::label_59_0::

	this.vis.bans = vis_bans
	this.health.immune_to = prev_immune

	return out
end

local function y_soldier_revive(store, this)
	if not this.revive or this.revive.disabled or this.unit.is_stunned or band(this.health.last_damage_types, bor(DAMAGE_DISINTEGRATE, DAMAGE_EAT, DAMAGE_DISINTEGRATE_BOSS)) ~= 0 then
		return false
	end

	local r = this.revive

	if math.random() < r.chance then
		local r = this.revive

		if r.remove_modifiers then
			remove_modifiers(store, this)
		end

		this.health.ignore_damage = true
		this.health.dead = false
		this.health_bar.hidden = false

		if this.soldier.target_id then
			local enemy = store.entities[this.soldier.target_id]

			if enemy then
				U.block_enemy(store, this, enemy)
			end
		end

		if r.fx then
			local fx = E:create_entity(r.fx)

			fx.pos = this.pos
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)
		end

		if r.animation then
			S:queue(r.sound)
			U.animation_start(this, r.animation, nil, store.tick_ts, false)

			r.ts = store.tick_ts

			while store.tick_ts - r.ts < r.hit_time do
				coroutine.yield()
			end
		end

		r.revive_count = (r.revive_count or 0) + 1

		signal.emit("entity-revived", this, r.revive_count)

		this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + this.health.hp_max * r.health_recover)

		if r.animation then
			while not U.animation_finished(this) do
				coroutine.yield()
			end
		end

		this.health.ignore_damage = false

		return true
	end

	return false
end

local function y_soldier_death(store, this)
	U.unblock_target(store, this)

	local h = this.health

	if band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE, DAMAGE_DISINTEGRATE_BOSS)) ~= 0 then
		this.unit.hide_during_death = true

		local fx = E:create_entity("fx_soldier_desintegrate")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	elseif band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
		this.unit.hide_during_death = true
	elseif band(h.last_damage_types, bor(DAMAGE_HOST)) ~= 0 then
		S:queue(this.sound_events.death_by_explosion)

		this.unit.hide_during_death = true

		local fx = E:create_entity("fx_unit_explode")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]

		queue_insert(store, fx)

		if this.unit.show_blood_pool and this.unit.blood_color ~= BLOOD_NONE then
			local decal = E:create_entity("decal_blood_pool")

			decal.pos = V.vclone(this.pos)
			decal.render.sprites[1].ts = store.tick_ts
			decal.render.sprites[1].name = this.unit.blood_color

			queue_insert(store, decal)
		end
	elseif this.reinforcement and (this.reinforcement.fade or this.reinforcement.fade_out) then
		y_reinforcement_fade_out(store, this)

		return
	else
		S:queue(this.sound_events.death, this.sound_events.death_args)
		U.y_animation_play(this, "death", nil, store.tick_ts, 1)

		this.ui.can_select = false
	end

	this.health.death_finished_ts = store.tick_ts

	if this.ui then
		if IS_TRILOGY then
			this.ui.can_click = not this.unit.hide_after_death
		else
			this.ui.can_click = this.ui.can_click and not this.unit.hide_after_death
		end

		this.ui.z = -1
	end

	if this.unit.hide_during_death or this.unit.hide_after_death then
		U.sprites_hide(this, nil, nil, true)
	end

	if this.unit.fade_time_after_death then
		local delay = this.unit.fade_time_after_death
		local duration = this.unit.fade_duration_after_death

		if this.health and this.health.delete_after and duration then
			delay = this.health.delete_after - store.tick_ts - duration
		end

		fade_out_entity(store, this, delay, duration)
	end
end

local function y_soldier_do_loopable_ranged_attack(store, this, target, attack)
	local attack_done = false
	local start_ts = store.tick_ts
	local b, an, af, ai, final_target
	final_target = target

	S:queue(attack.sound, attack.sound_args)

	if attack.animations[1] then
		an, af, ai = U.animation_name_facing_point(this, attack.animations[1], final_target.pos)

		U.y_animation_play_group(this, an, af, store.tick_ts, 1, attack.sprite_group)
	end

	for i = 1, attack.loops do
		an, af, ai = U.animation_name_facing_point(this, attack.animations[2], final_target.pos)

		U.animation_start_group(this, an, af, store.tick_ts, false, attack.sprite_group)

		for si, st in pairs(attack.shoot_times) do
			while st > store.tick_ts - U.get_animation_ts(this, attack.sprite_group) do
				if this.unit.is_stunned then
					goto label_62_0
				end

				if this.health.dead or this.nav_rally and this.nav_rally.new then
					goto label_62_1
				end

				coroutine.yield()
			end

			if final_target.health.dead then
				local tmp_target = U.find_foremost_enemy(store.entities, this.pos, attack.min_range, attack.max_range, attack.node_prediction, attack.vis_flags, attack.vis_bans, attack.filter_fn, F_FLYING)
				if tmp_target then
					local tmp_name, tmp_flip
					tmp_name, tmp_flip = U.animation_name_facing_point(this, attack.animations[2], tmp_target.pos)
					if tmp_name == an and tmp_flip == af then
						final_target = tmp_target
					end
				end
			end

			b = E:create_entity(attack.bullet)
			b.pos = V.vclone(this.pos)

			if attack.bullet_start_offset then
				local offset = attack.bullet_start_offset[ai]

				b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
			end

			if attack.bullet_shot_start_offset then
				local offset = attack.bullet_shot_start_offset[si]

				b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
			end

			b.bullet.from = V.vclone(b.pos)
			b.bullet.to = V.v(final_target.pos.x + final_target.unit.hit_offset.x, final_target.pos.y + final_target.unit.hit_offset.y)
			b.bullet.target_id = final_target.id
			b.bullet.shot_index = si
			b.bullet.loop_index = i
			b.bullet.source_id = this.id
			b.bullet.xp_dest_id = this.id

			if IS_KR5 and attack.level then
				b.bullet.level = attack.level
			end

			queue_insert(store, b)

			if attack.xp_from_skill then
				hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
			end

			attack_done = true
		end

		while not U.animation_finished_group(this, attack.sprite_group) do
			if this.unit.is_stunned then
				goto label_62_0
			end

			if this.health.dead or this.nav_rally and this.nav_rally.new then
				goto label_62_1
			end

			coroutine.yield()
		end
	end

	::label_62_0::

	if attack.animations[3] then
		an, af, ai = U.animation_name_facing_point(this, attack.animations[3], final_target.pos)

		U.animation_start_group(this, an, af, store.tick_ts, false, attack.sprite_group)

		while not U.animation_finished_group(this, attack.sprite_group) do
			if this.health.dead or this.nav_rally and this.nav_rally.new then
				break
			end

			coroutine.yield()
		end
	end

	::label_62_1::

	if attack_done and attack.xp_from_skill_once then
		hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill_once])
	end

	return attack_done
end

local function y_soldier_do_ranged_attack(store, this, target, attack, pred_pos)
	local attack_done = false
	local start_ts = store.tick_ts
	local bullet
	local bullet_to = pred_pos or target.pos
	local bullet_to_start = V.vclone(bullet_to)
	local an, af, ai = U.animation_name_facing_point(this, attack.animation, bullet_to)

	U.animation_start(this, an, af, store.tick_ts, false)
	S:queue(attack.sound, attack.sound_args)

	while store.tick_ts - start_ts < attack.shoot_time do
		if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
			goto label_63_0
		end

		coroutine.yield()
	end

	if attack.check_target_before_shot and (target.health.dead or not store.entities[target.id]) then
		log.debug("target (%s) is dead or removed from store", target.id)
	elseif attack.max_track_distance and V.dist(target.pos.x, target.pos.y, bullet_to_start.x, bullet_to_start.y) > attack.max_track_distance then
		log.debug("target (%s) at %s,%s  exceeds attack.max_track_distance %s to %s,%s", target.id, target.pos.x, target.pos.y, attack.max_track_distance, bullet_to_start.x, bullet_to_start.y)
	else
		S:queue(attack.sound_shoot)

		bullet = E:create_entity(attack.bullet)
		bullet.pos = V.vclone(this.pos)

		if attack.bullet_start_offset then
			local offset = attack.bullet_start_offset[ai]

			bullet.pos.x, bullet.pos.y = bullet.pos.x + (af and -1 or 1) * offset.x, bullet.pos.y + offset.y
		end

		bullet.bullet.from = V.vclone(bullet.pos)
		bullet.bullet.to = V.vclone(bullet_to)

		if not attack.ignore_hit_offset then
			bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
			bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
		end

		bullet.bullet.target_id = target.id
		bullet.bullet.source_id = this.id
		bullet.bullet.xp_dest_id = this.id
		bullet.bullet.level = attack.level

		if bullet.bullet.use_unit_damage_factor then
			bullet.bullet.damage_factor = this.unit.damage_factor
		end

		queue_insert(store, bullet)

		if attack.xp_from_skill then
			hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
		end

		attack_done = true

		while not U.animation_finished(this) do
			if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
				break
			end

			coroutine.yield()
		end
	end

	::label_63_0::

	return attack_done
end

local function soldier_pick_ranged_target_and_attack(store, this)
	local in_range = false
	local awaiting_target

	for _, i in pairs(this.ranged.order) do
		local a = this.ranged.attacks[i]

		if a.disabled then
			-- block empty
		elseif a.sync_animation and not this.render.sprites[1].sync_flag then
			-- block empty
		else
			local ready = store.tick_ts - a.ts >= a.cooldown
			if this.ranged.forced_cooldown then
				ready = ready and store.tick_ts - this.ranged.forced_ts >= this.ranged.forced_cooldown
			end
			
			if ready then
				if math.random() <= a.chance then
					local target, _, pred_pos = U.find_enemy_with_search_type(store.entities, this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, a.filter_fn, F_FLYING, a.search_type)
					return target, a, pred_pos
				end
				a.ts = store.tick_ts
			else
				local target, _, pred_pos = U.find_enemy_with_search_type(store.entities, this.pos, a.min_range, a.max_range, nil, a.vis_flags, a.vis_bans, a.filter_fn, F_FLYING, a.search_type)
				awaiting_target = target
			end
		end
	end

	return awaiting_target, nil
end

local function y_soldier_ranged_attacks(store, this)
	local target, attack, pred_pos = soldier_pick_ranged_target_and_attack(store, this)

	if not target then
		return false, A_NO_TARGET
	end

	if not attack then
		return false, A_IN_COOLDOWN
	end

	local start_ts = store.tick_ts
	local attack_done

	U.set_destination(this, this.pos)

	if attack.loops then
		attack_done = y_soldier_do_loopable_ranged_attack(store, this, target, attack)
	else
		attack_done = y_soldier_do_ranged_attack(store, this, target, attack, pred_pos)
	end

	if attack_done then
		attack.ts = start_ts

		if attack.shared_cooldown then
			for _, aa in pairs(this.ranged.attacks) do
				if aa ~= attack and aa.shared_cooldown then
					aa.ts = attack.ts
				end
			end
		end

		if this.ranged.forced_cooldown then
			this.ranged.forced_ts = start_ts
		end
	end

	if attack_done then
		return false, A_DONE
	else
		return true
	end
end

local function y_soldier_do_timed_action(store, this, action)
	local action_done = false
	local start_ts = store.tick_ts

	U.animation_start(this, action.animation, nil, store.tick_ts)
	S:queue(action.sound, action.sound_args)

	if action.cast_time and y_soldier_wait(store, this, action.cast_time) then
		-- block empty
	else
		action.ts = start_ts
		action_done = true

		if action.mod or action.mods then
			local mods = action.mods or {
				action.mod
			}

			for _, mod_name in pairs(mods) do
				local m = E:create_entity(mod_name)

				m.modifier.target_id = this.id
				m.modifier.source_id = this.id
				m.modifier.level = action.level

				queue_insert(store, m)
			end
		elseif action.aura then
			local e = E:create_entity(action.aura)

			e.aura.source_id = this.id
			e.aura.level = action.level
			e.pos = V.vclone(this.pos)

			queue_insert(store, e)
		end

		y_soldier_animation_wait(this)
	end

	return action_done
end

local function y_soldier_timed_actions(store, this)
	for _, a in pairs(this.timed_actions.list) do
		if a.disabled or store.tick_ts - a.ts < a.cooldown then
			-- block empty
		elseif a.fn_can and not a.fn_can(this, store, a) then
			return false, A_NO_TARGET
		elseif not a.chance or math.random() < a.chance then
			local attack_done = y_soldier_do_timed_action(store, this, a)

			if attack_done then
				return false, A_DONE
			else
				return true
			end
		else
			a.ts = store.tick_ts
		end
	end

	return false, A_IN_COOLDOWN
end

local function y_soldier_do_timed_attack(store, this, target, attack)
	local attack_done = false
	local start_ts = store.tick_ts
	local spell
	local an, af = U.animation_name_facing_point(this, attack.animation, target.pos)

	U.animation_start(this, an, af, store.tick_ts)
	S:queue(attack.sound)

	while store.tick_ts - start_ts < attack.cast_time do
		if this.health.dead or this.unit.is_stunned or this.nav_rally and this.nav_rally.new then
			goto label_68_0
		end

		coroutine.yield()
	end

	attack.ts = start_ts
	spell = E:create_entity(attack.spell)
	spell.spell.source_id = this.id
	spell.spell.target_id = target.id

	queue_insert(store, spell)

	attack_done = true

	while not U.animation_finished(this) do
		if this.health.dead or this.nav_rally and this.nav_rally.new then
			break
		end

		coroutine.yield()
	end

	::label_68_0::

	S:stop(attack.sound)

	return attack_done
end

local function y_soldier_do_single_area_attack(store, this, target, attack)
	local attack_done = false
	local start_ts = store.tick_ts
	local targets, hit_pos
	local an, af = U.animation_name_facing_point(this, attack.animation, target.pos)

	U.animation_start(this, an, af, store.tick_ts, 1)
	S:queue(attack.sound, attack.sound_args)

	while store.tick_ts - start_ts < attack.hit_time do
		if this.health.dead or this.unit.is_stunned or this.dodge and this.dodge.active and not this.dodge.silent or this.nav_rally and this.nav_rally.new then
			goto label_70_0
		end

		coroutine.yield()
	end

	S:queue(attack.sound_hit, attack.sound_hit_args)

	attack.ts = start_ts

	if attack.shared_cooldown then
		for _, aa in pairs(this.melee.attacks) do
			if aa ~= attack and aa.shared_cooldown then
				aa.ts = attack.ts
			end
		end
	end

	if attack.forced_cooldown then
		this.melee.forced_ts = attack.ts
	end

	if attack.cooldown_group then
		for _, aa in pairs(this.melee.attacks) do
			if aa ~= attack and aa.cooldown_group == attack.cooldown_group then
				aa.ts = attack.ts
			end
		end
	end

	if attack.signal then
		signal.emit("soldier-attack", this, attack, attack.signal)
	end

	hit_pos = V.vclone(this.pos)

	if attack.hit_offset then
		hit_pos.x = hit_pos.x + (af and -1 or 1) * attack.hit_offset.x
		hit_pos.y = hit_pos.y + attack.hit_offset.y
	end

	targets = table.filter(store.entities, function(k, v)
		return v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, attack.damage_bans) == 0 and band(v.vis.bans, attack.damage_flags) == 0 and U.is_inside_ellipse(v.pos, hit_pos, attack.damage_radius)
	end)

	if attack.count then
		table.sort(targets, function(e1, e2)
			return V.dist(e1.pos.x, e1.pos.y, hit_pos.x, hit_pos.y) < V.dist(e2.pos.x, e2.pos.y, hit_pos.x, hit_pos.y)
		end)
	end

	for i = 1, math.min(attack.count or #targets, #targets) do
		local e = targets[i]
		local d = E:create_entity("damage")

		d.source_id = this.id
		d.target_id = e.id
		d.damage_type = attack.damage_type
		d.value = math.random(attack.damage_min, attack.damage_max)
		d.track_kills = this.track_kills ~= nil
		d.track_damage = attack.track_damage
		d.xp_gain_factor = attack.xp_gain_factor
		d.xp_dest_id = attack.xp_dest_id
		d.pop = attack.pop
		d.pop_chance = attack.pop_chance
		d.pop_conds = attack.pop_conds

		if IS_KR5 then
			d.reduce_armor = attack.reduce_armor
			d.reduce_magic_armor = attack.reduce_magic_armor
		end

		queue_damage(store, d)

		if attack.mod or attack.mods then
			local mods = attack.mods or {
				attack.mod
			}

			for _, mod_name in pairs(mods) do
				local m = E:create_entity(mod_name)

				m.modifier.ts = store.tick_ts
				m.modifier.target_id = e.id
				m.modifier.source_id = this.id
				m.modifier.level = attack.level
				m.modifier.target_idx = i

				queue_insert(store, m)
			end
		end
	end

	if attack.hit_aura then
		local a = E:create_entity(attack.hit_aura)

		a.pos = V.vclone(hit_pos)
		a.aura.target_id = target.id
		a.aura.source_id = this.id

		queue_insert(store, a)
	end

	if attack.hit_fx then
		local fx = E:create_entity(attack.hit_fx)

		fx.pos = V.vclone(hit_pos)

		for i = 1, #fx.render.sprites do
			fx.render.sprites[i].ts = store.tick_ts
		end

		queue_insert(store, fx)
	end

	if attack.hit_decal then
		local fx = E:create_entity(attack.hit_decal)

		fx.pos = V.vclone(hit_pos)

		for i = 1, #fx.render.sprites do
			fx.render.sprites[i].ts = store.tick_ts
		end

		queue_insert(store, fx)
	end

	attack_done = true

	while not U.animation_finished(this) do
		if this.health.dead or this.unit.is_stunned or this.dodge and this.dodge.active and not this.dodge.silent or this.nav_rally and this.nav_rally.new then
			break
		end

		coroutine.yield()
	end

	::label_70_0::

	S:stop(attack.sound)

	return attack_done
end

local function y_soldier_do_loopable_melee_attack(store, this, target, attack)
	local attack_done = false
	local start_ts = store.tick_ts
	local an, af

	S:queue(attack.sound, attack.sound_args)

	if attack.animations[1] then
		an, af = U.animation_name_facing_point(this, attack.animations[1], target.pos)

		U.y_animation_play(this, an, af, store.tick_ts, 1)
	end

	for i = 1, attack.loops do
		if attack.interrupt_loop_on_dead_target and target.health.dead then
			log.debug("interrupt_loop_on_dead_target")

			goto label_73_1
		end

		local loop_ts = store.tick_ts

		S:queue(attack.sound_loop, attack.sound_loop_args)

		an, af = U.animation_name_facing_point(this, attack.animations[2], target.pos)

		U.animation_start(this, an, af, store.tick_ts, 1)

		local hit_times = attack.hit_times and attack.hit_times or {
			attack.hit_time
		}

		for _, ht in pairs(hit_times) do
			while ht > store.tick_ts - loop_ts do
				if this.unit.is_stunned then
					goto label_73_0
				end

				if attack.interrupt_on_dead_target and target.health.dead then
					log.debug("interrupt_on_dead_target")

					goto label_73_1
				end

				if this.health.dead or this.nav_rally and this.nav_rally.new then
					goto label_73_1
				end

				coroutine.yield()
			end

			S:queue(attack.sound_hit, attack.sound_hit_args)

			attack.ts = start_ts

			if attack.shared_cooldown then
				for _, aa in pairs(this.melee.attacks) do
					if aa ~= attack and aa.shared_cooldown then
						aa.ts = attack.ts
					end
				end
			end

			if attack.forced_cooldown then
				this.melee.forced_ts = attack.ts
			end

			if attack.cooldown_group then
				for _, aa in pairs(this.melee.attacks) do
					if aa ~= attack and aa.cooldown_group == attack.cooldown_group then
						aa.ts = attack.ts
					end
				end
			end

			if attack.type == "area" then
				local hit_pos = V.vclone(this.pos)

				if attack.hit_offset then
					hit_pos.x = hit_pos.x + (af and -1 or 1) * attack.hit_offset.x
					hit_pos.y = hit_pos.y + attack.hit_offset.y
				end

				local targets = table.filter(store.entities, function(k, v)
					return v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, attack.damage_bans) == 0 and band(v.vis.bans, attack.damage_flags) == 0 and U.is_inside_ellipse(v.pos, hit_pos, attack.damage_radius)
				end)

				if attack.include_blocked and target and this.soldier and this.soldier.target_id == target.id and not table.contains(targets, target) then
					table.insert(targets, target)
				end

				for _, e in pairs(targets) do
					local d = E:create_entity("damage")

					d.source_id = this.id
					d.target_id = e.id
					d.damage_type = attack.damage_type
					d.value = math.random(attack.damage_min, attack.damage_max)
					d.track_kills = this.track_kills ~= nil
					d.track_damage = attack.track_damage
					d.xp_gain_factor = attack.xp_gain_factor
					d.xp_dest_id = attack.xp_dest_id
					d.pop = attack.pop
					d.pop_chance = attack.pop_chance
					d.pop_conds = attack.pop_conds

					if IS_KR5 then
						d.reduce_armor = attack.reduce_armor
						d.reduce_magic_armor = attack.reduce_magic_armor
					end

					queue_damage(store, d)

					if attack.mod or attack.mods then
						local mods = attack.mods or {
							attack.mod
						}
			
						for _, mod_name in pairs(mods) do
							local m = E:create_entity(mod_name)
			
							m.modifier.ts = store.tick_ts
							m.modifier.target_id = e.id
							m.modifier.source_id = this.id
							m.modifier.level = attack.level
			
							queue_insert(store, m)
						end
					end
				end

				if attack.hit_fx then
					local fx = E:create_entity(attack.hit_fx)

					fx.pos = V.vclone(hit_pos)

					for i = 1, #fx.render.sprites do
						fx.render.sprites[i].ts = store.tick_ts
					end

					queue_insert(store, fx)
				end

				if attack.hit_decal then
					local fx = E:create_entity(attack.hit_decal)

					fx.pos = V.vclone(hit_pos)

					for i = 1, #fx.render.sprites do
						fx.render.sprites[i].ts = store.tick_ts
					end

					queue_insert(store, fx)
				end
			elseif this.soldier and this.soldier.target_id == target.id then
				local d = E:create_entity("damage")

				if attack.instakill then
					d.damage_type = DAMAGE_INSTAKILL
				elseif attack.fn_damage then
					d.damage_type = attack.damage_type
					d.value = attack.fn_damage(this, store, attack, target)
				else
					d.damage_type = attack.damage_type
					d.value = math.ceil(this.unit.damage_factor * math.random(attack.damage_min, attack.damage_max))
				end

				d.source_id = this.id
				d.target_id = target.id
				d.xp_gain_factor = attack.xp_gain_factor
				d.xp_dest_id = attack.xp_dest_id
				d.pop = attack.pop
				d.pop_chance = attack.pop_chance
				d.pop_conds = attack.pop_conds

				queue_damage(store, d)

				if attack.mod or attack.mods then
					local mods = attack.mods or {
						attack.mod
					}
		
					for _, mod_name in pairs(mods) do
						local m = E:create_entity(mod_name)
		
						m.modifier.ts = store.tick_ts
						m.modifier.target_id = target.id
						m.modifier.source_id = this.id
						m.modifier.level = attack.level

						queue_insert(store, m)
					end
				end
			end

			attack_done = true
		end

		while not U.animation_finished(this) do
			if this.unit.is_stunned then
				goto label_73_0
			end

			if this.health.dead or this.nav_rally and this.nav_rally.new then
				goto label_73_1
			end

			coroutine.yield()
		end
	end

	if attack.signal then
		signal.emit("soldier-attack", this, attack, attack.signal)
	end

	::label_73_0::

	S:queue(attack.sound_end)

	if attack.animations[3] then
		an, af = U.animation_name_facing_point(this, attack.animations[3], target.pos)

		U.animation_start(this, an, af, store.tick_ts, 1)

		while not U.animation_finished(this) do
			if this.health.dead or this.nav_rally and this.nav_rally.new then
				break
			end

			coroutine.yield()
		end
	end

	::label_73_1::

	S:stop(attack.sound)

	return attack_done
end

local function y_soldier_do_single_melee_attack(store, this, target, attack)
	local attack_done = false
	local start_ts = store.tick_ts
	local an, af = U.animation_name_facing_point(this, attack.animation, target.pos)

	U.animation_start(this, an, af, store.tick_ts, 1)
	S:queue(attack.sound, attack.sound_args)

	while store.tick_ts - start_ts < attack.hit_time do
		if this.health.dead or this.unit.is_stunned or this.dodge and this.dodge.active and not this.dodge.silent or not attack.ignore_rally_change and this.nav_rally and this.nav_rally.new then
			goto label_75_0
		end

		coroutine.yield()
	end

	S:queue(attack.sound_hit, attack.sound_hit_args)

	attack.ts = start_ts

	if attack.shared_cooldown then
		for _, aa in pairs(this.melee.attacks) do
			if aa ~= attack and aa.shared_cooldown then
				aa.ts = attack.ts
			end
		end
	end

	if attack.forced_cooldown then
		this.melee.forced_ts = attack.ts
	end

	if attack.cooldown_group then
		for _, aa in pairs(this.melee.attacks) do
			if aa ~= attack and aa.cooldown_group == attack.cooldown_group then
				aa.ts = attack.ts
			end
		end
	end

	if attack.signal then
		signal.emit("soldier-attack", this, attack, attack.signal)
	end

	if target.enemy and not unit_dodges(store, target, false, attack, this) and table.contains(target.enemy.blockers, this.id) then
		if attack.damage_type ~= DAMAGE_NONE then
			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = target.id
			d.xp_gain_factor = attack.xp_gain_factor
			d.xp_dest_id = attack.xp_dest_id
			d.track_kills = this.track_kills ~= nil
			d.track_damage = attack.track_damage
			d.pop = attack.pop
			d.pop_chance = attack.pop_chance
			d.pop_conds = attack.pop_conds

			if IS_KR5 then
				d.reduce_armor = attack.reduce_armor
				d.reduce_magic_armor = attack.reduce_magic_armor
			end

			if attack.instakill then
				d.damage_type = DAMAGE_INSTAKILL
			elseif attack.fn_damage then
				d.damage_type = attack.damage_type
				d.value = attack.fn_damage(this, store, attack, target)
			elseif attack.damage_min then
				d.damage_type = attack.damage_type
				d.value = math.ceil(this.unit.damage_factor * math.random(attack.damage_min, attack.damage_max))
			end

			queue_damage(store, d)
		end

		if attack.mod or attack.mods then
			local mods = attack.mods or {
				attack.mod
			}

			for _, mod_name in pairs(mods) do
				local m = E:create_entity(mod_name)

				m.modifier.ts = store.tick_ts
				m.modifier.target_id = target.id
				m.modifier.source_id = this.id
				m.modifier.level = attack.level

				queue_insert(store, m)
			end
		end

		local hit_pos = V.vclone(this.pos)

		if attack.hit_offset then
			hit_pos.x = hit_pos.x + (af and -1 or 1) * attack.hit_offset.x
			hit_pos.y = hit_pos.y + attack.hit_offset.y
		end

		if attack.hit_aura then
			local a = E:create_entity(attack.hit_aura)

			a.pos = V.vclone(hit_pos)
			a.aura.target_id = target.id
			a.aura.source_id = this.id

			queue_insert(store, a)
		end

		if attack.hit_fx then
			local fx = E:create_entity(attack.hit_fx)

			fx.pos = V.vclone(hit_pos)

			for i = 1, #fx.render.sprites do
				fx.render.sprites[i].ts = store.tick_ts
			end

			queue_insert(store, fx)
		end

		if attack.hit_decal then
			local fx = E:create_entity(attack.hit_decal)

			fx.pos = V.vclone(hit_pos)

			for i = 1, #fx.render.sprites do
				fx.render.sprites[i].ts = store.tick_ts
			end

			queue_insert(store, fx)
		end
	end

	if this.pickpocket and (not this.pickpocket.power_name or this.powers and this.powers[this.pickpocket.power_name].level > 0) and math.random() < this.pickpocket.chance then
		local pi = this.pickpocket

		if target.enemy and target.enemy.gold_bag > 0 then
			local q = km.clamp(0, target.enemy.gold_bag, math.floor(0.5 + U.frandom(pi.steal_min, pi.steal_max)))

			if q > 0 then
				S:queue(this.pickpocket.sound)
				signal.emit("soldier-pickpocket", this, q)
			end

			target.enemy.gold_bag = target.enemy.gold_bag - q
			store.player_gold = store.player_gold + q

			if pi.fx then
				local fx = E:create_entity(pi.fx)

				fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)
			end
		end
	end

	attack_done = true

	while not U.animation_finished(this) do
		if this.health.dead or this.unit.is_stunned or this.dodge and this.dodge.active and not this.dodge.silent or not attack.ignore_rally_change and this.nav_rally and this.nav_rally.new then
			break
		end

		coroutine.yield()
	end

	::label_75_0::

	S:stop(attack.sound)

	return attack_done
end

local function soldier_pick_melee_target(store, this)
	local target

	if U.blocker_rank(store, this) ~= nil then
		if not U.is_blocked_valid(store, this) then
			U.unblock_target(store, this)
		else
			target = store.entities[this.soldier.target_id]
		end
	end

	local center = this.nav_rally and this.nav_rally.center or this.pos

	if not target then
		if this.hero then
			target = U.find_nearest_enemy(store.entities, center, 0, this.melee.range, F_BLOCK, bit.bor(F_CLIFF), function(e)
				return (not e.enemy.max_blockers or #e.enemy.blockers == 0) and band(GR:cell_type(e.pos.x, e.pos.y), TERRAIN_NOWALK) == 0 and (not this.melee.fn_can_pick or this.melee.fn_can_pick(this, e))
			end)
		else
			target = U.find_foremost_enemy(store.entities, center, 0, this.melee.range, false, F_BLOCK, bit.bor(F_CLIFF), function(e)
				return (not e.enemy.max_blockers or #e.enemy.blockers == 0) and band(GR:cell_type(e.pos.x, e.pos.y), TERRAIN_NOWALK) == 0 and (not this.melee.fn_can_pick or this.melee.fn_can_pick(this, e))
			end)
		end
	elseif U.blocker_rank(store, this) ~= 1 then
		local alt_target = U.find_foremost_enemy(store.entities, center, 0, this.melee.range, false, F_BLOCK, bit.bor(F_FLYING, F_CLIFF), function(e)
			return #e.enemy.blockers == 0 and band(GR:cell_type(e.pos.x, e.pos.y), TERRAIN_NOWALK) == 0
		end)

		if alt_target then
			target = alt_target
		end
	end

	return target
end

local function soldier_move_to_slot_step(store, this, target)
	U.block_enemy(store, this, target)

	local slot_pos, slot_flip, enemy_flip = U.melee_slot_position(this, target)

	if not slot_pos then
		return true
	end

	if V.veq(slot_pos, this.pos) then
		this.motion.arrived = true

		return false
	else
		U.set_destination(this, slot_pos)

		local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

		U.animation_start(this, an, af, store.tick_ts, -1)

		if U.walk(this, store.tick_length) then
			local ani = this.melee and this.melee.arrived_slot_animation or "idle"

			an, af = U.animation_name_facing_point(this, ani, target.pos)

			U.animation_start(this, an, af, store.tick_ts, -1)
		end

		return true
	end
end

local function soldier_pick_melee_attack(store, this, target)
	if this.dodge and this.dodge.counter_attack_pending then
		this.dodge.counter_attack_pending = false
		this.melee.last_attack = {
			target_id = target.id,
			attack = this.dodge.counter_attack
		}

		return this.dodge.counter_attack
	else
		for _, i in pairs(this.melee.order) do
			do
				local a = this.melee.attacks[i]
				local cooldown = a.cooldown

				if this.melee.cooldown and a.shared_cooldown then
					cooldown = this.melee.cooldown
				end

				local forced_cooldown_ok = true

				if this.melee.forced_cooldown and a.forced_cooldown then
					forced_cooldown_ok = store.tick_ts - this.melee.forced_ts > this.melee.forced_cooldown
				end

				if not a.disabled and cooldown < store.tick_ts - a.ts and forced_cooldown_ok and band(a.vis_flags, target.vis.bans) == 0 and band(a.vis_bans, target.vis.flags) == 0 and (not a.fn_can or a.fn_can(this, store, a, target)) and (not a.not_first or this.melee.last_attack and this.melee.last_attack.target_id == target.id) then
					if not a.fn_chance and math.random() >= a.chance or a.fn_chance and not a.fn_chance(this, store, a, target) then
						a.ts = store.tick_ts
					else
						if a.min_count and a.type == "area" and a.damage_radius then
							local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius, a.vis_flags, a.vis_bans)

							if not targets or #targets < a.min_count then
								goto label_81_0
							end
						end

						this.melee.last_attack = {
							target_id = target.id,
							attack = a
						}

						return a
					end
				end
			end

			::label_81_0::
		end
	end

	return nil
end

local function y_soldier_melee_block_and_attacks(store, this)
	local target = soldier_pick_melee_target(store, this)

	if not target then
		return false, A_NO_TARGET
	end

	if soldier_move_to_slot_step(store, this, target) then
		return true
	end

	local attack = soldier_pick_melee_attack(store, this, target)

	if not attack then
		return false, A_IN_COOLDOWN
	end

	if attack.xp_from_skill then
		hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
	end

	local attack_done

	if attack.loops then
		attack_done = y_soldier_do_loopable_melee_attack(store, this, target, attack)
	elseif attack.type == "area" then
		attack_done = y_soldier_do_single_area_attack(store, this, target, attack)
	else
		attack_done = y_soldier_do_single_melee_attack(store, this, target, attack)
	end

	if attack_done then
		return false, A_DONE
	else
		return true
	end
end

local function soldier_go_back_step(store, this)
	local dest = this.nav_rally.pos

	if V.veq(this.pos, dest) then
		this.motion.arrived = true

		return false
	else
		U.set_destination(this, dest)

		if U.walk(this, store.tick_length) then
			return false
		else
			local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

			U.animation_start(this, an, af, store.tick_ts, -1)

			return true
		end
	end
end

local function soldier_idle(store, this, force_ts)
	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, force_ts)

	if this.unit.is_stunned then
		return
	end

	if store.tick_ts - this.idle_flip.ts > 2 * store.tick_length then
		this.idle_flip.ts_counter = 0
	end

	this.idle_flip.ts = store.tick_ts
	this.idle_flip.ts_counter = this.idle_flip.ts_counter + store.tick_length

	if this.idle_flip.ts_counter > this.idle_flip.cooldown then
		this.idle_flip.ts_counter = 0

		if math.random() < this.idle_flip.chance then
			this.render.sprites[1].flip_x = not this.render.sprites[1].flip_x
		end

		if this.idle_flip.animations then
			this.idle_flip.last_animation = table.random(this.idle_flip.animations)
		end
	end
end

local function soldier_regen(store, this)
	if this.regen and store.tick_ts - this.regen.last_hit_ts > this.regen.last_hit_standoff_time then
		this.regen.ts_counter = this.regen.ts_counter + store.tick_length

		if this.regen.ts_counter > this.regen.cooldown then
			if this.health.hp < this.health.hp_max then
				this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + this.regen.health)

				signal.emit("health-regen", this, this.regen.health)
			end

			this.regen.ts_counter = 0
		end
	end
end

local function soldier_power_upgrade(this, power_name)
	local pn = power_name
	local pow = this.powers and this.powers[pn]

	if this.health.power_name == pn and this.health.hp_inc then
		this.health.hp_max = this.health.hp_max + this.health.hp_inc
		this.health.hp = this.health.hp_max
	end

	if this.health.armor_power_name == pn and this.health.armor_inc then
		armor_inc(this, this.health.armor_inc)
	end

	if this.ranged then
		for _, a in pairs(this.ranged.attacks) do
			if a.power_name == pn then
				a.level = a.level + 1

				if a.disabled then
					a.disabled = nil
				end

				if a.cooldown_inc then
					a.cooldown = a.cooldown + a.cooldown_inc
				end

				if a.range_inc then
					a.max_range = a.max_range + a.range_inc
				end
			end
		end
	end

	if this.melee then
		local min_cooldown = 1e+99
		local cooldown_changed = false

		for _, a in pairs(this.melee.attacks) do
			if a.power_name == pn then
				a.level = a.level + 1

				if a.disabled then
					a.disabled = nil
				end

				if a.chance_inc then
					a.chance = a.chance + a.chance_inc
					this.melee.order = U.attack_order(this.melee.attacks)
				end

				if a.damage_inc then
					if a._original_damage_min then
						a._original_damage_min = a._original_damage_min + a.damage_inc
					else
						a.damage_min = a.damage_min + a.damage_inc
					end
					if a._original_damage_max then
						a._original_damage_max = a._original_damage_max + a.damage_inc
					else
						a.damage_max = a.damage_max + a.damage_inc
					end
				end

				if a.damage_min_inc and a.damage_max_inc then
					if a._original_damage_min then
						a._original_damage_min = a._original_damage_min + a.damage_min_inc
					else
						a.damage_min = a.damage_min + a.damage_min_inc
					end
					if a._original_damage_max then
						a._original_damage_max = a._original_damage_max + a.damage_max_inc
					else
						a.damage_max = a.damage_max + a.damage_max_inc
					end
				end

				if a.cooldown_inc then
					a.cooldown = a.cooldown + a.cooldown_inc
					cooldown_changed = true
				end
			end

			if a.cooldown then
				min_cooldown = math.min(a.cooldown, min_cooldown)
			end
		end

		if cooldown_changed and this.melee.forced_cooldown and min_cooldown < this.melee.forced_cooldown then
			this.melee.forced_cooldown = min_cooldown
		end
	end

	if this.timed_actions then
		for _, a in pairs(this.timed_actions.list) do
			if a.power_name == pn then
				if a.level then
					a.level = a.level + 1
				end

				if a.disabled then
					a.disabled = nil
				end
			end
		end
	end

	if this.revive and this.revive.power_name == pn then
		this.revive.disabled = nil

		if this.revive.chance_inc then
			this.revive.chance = this.revive.chance + this.revive.chance_inc
		end

		if this.revive.health_recover then
			this.revive.health_recover = this.revive.health_recover + this.revive.health_recover_inc
		end
	end

	if this.dodge and this.dodge.power_name == pn then
		local d = this.dodge

		if d.chance_inc then
			d.chance = d.chance + d.chance_inc
		end
	end

	if this.dodge and this.dodge.counter_attack and this.dodge.counter_attack.power_name == pn then
		local d = this.dodge

		if d.counter_attack.damage_inc then
			d.counter_attack.damage_min = d.counter_attack.damage_min + d.counter_attack.damage_inc
			d.counter_attack.damage_max = d.counter_attack.damage_max + d.counter_attack.damage_inc
		elseif d.counter_attack.damage_min_config and d.counter_attack.damage_max_config then
			d.counter_attack.damage_min = d.counter_attack.damage_min_config[pow.level]
			d.counter_attack.damage_max = d.counter_attack.damage_max_config[pow.level]
		end
	end

	if this.pickpocket and this.pickpocket.power_name == pn then
		local pi = this.pickpocket

		if pi.chance_inc then
			pi.chance = pi.chance + pi.chance_inc
		end
	end

	local fn = pow and pow.on_power_upgrade

	if fn then
		fn(this, power_name, pow)
	end
end

local function soldier_courage_upgrade(store, this)
	local upg = UP:get_upgrade("barrack_courage")

	if upg and this.soldier and this.health and store.tick_ts - this.soldier.courage_ts > upg.regen_cooldown then
		this.soldier.courage_ts = store.tick_ts
		this.health.hp = km.clamp(0, this.health.hp_max, km.round(this.health.hp + this.health.hp_max * upg.regen_factor))
	end
end

local function heroes_desperate_effort_upgrade(store, this)
	local upg = UP:get_upgrade("heroes_desperate_effort")

	if upg and this.hero and this.health and this.health.hp < this.health.hp_max * upg.health_trigger and not U.has_modifiers(store, this, upg.modifier) then
		local m = E:create_entity(upg.modifier)

		m.modifier.source_id = this.id
		m.modifier.target_id = this.id

		queue_insert(store, m)
	end
end

local function heroes_visual_learning_upgrade(store, this)
	local upg = UP:get_upgrade("heroes_visual_learning")

	if upg and this.hero then
		if not this._upgrade_data then
			this._upgrade_data = {}
		end

		if not this._upgrade_data.heroes_visual_learning then
			this._upgrade_data.heroes_visual_learning = {}
		end

		if not this._upgrade_data.heroes_visual_learning.other_hero then
			local other_hero = table.filter(store.entities, function(k, e)
				return e.hero and e.template_name ~= this.template_name
			end)

			if other_hero and #other_hero > 0 then
				other_hero = other_hero[1]
			end

			this._upgrade_data.heroes_visual_learning.other_hero = other_hero
		end

		if not this._upgrade_data.heroes_visual_learning.ts or store.tick_ts - this._upgrade_data.heroes_visual_learning.ts >= upg.check_cooldown then
			local other_hero = this._upgrade_data.heroes_visual_learning.other_hero

			if V.dist(other_hero.pos.x, other_hero.pos.y, this.pos.x, this.pos.y) < upg.distance_to_trigger then
				local m = E:create_entity(upg.modifier)

				m.modifier.source_id = this.id
				m.modifier.target_id = this.id

				queue_insert(store, m)
			end

			this._upgrade_data.heroes_visual_learning.ts = store.tick_ts
		end
	end
end

local function heroes_lone_wolves_upgrade(store, this)
	local upg = UP:get_upgrade("heroes_lone_wolves")

	if upg and this.hero then
		if not this._upgrade_data then
			this._upgrade_data = {}
		end

		if not this._upgrade_data.heroes_lone_wolves then
			this._upgrade_data.heroes_lone_wolves = {}
		end

		if not this._upgrade_data.heroes_lone_wolves.other_hero then
			local other_hero = table.filter(store.entities, function(k, e)
				return e.hero and e.template_name ~= this.template_name
			end)

			if other_hero and #other_hero > 0 then
				other_hero = other_hero[1]
			end

			this._upgrade_data.heroes_lone_wolves.other_hero = other_hero
		end

		if not this._upgrade_data.heroes_lone_wolves.ts or store.tick_ts - this._upgrade_data.heroes_lone_wolves.ts >= upg.check_cooldown then
			local other_hero = this._upgrade_data.heroes_lone_wolves.other_hero

			if V.dist(other_hero.pos.x, other_hero.pos.y, this.pos.x, this.pos.y) > upg.distance_to_trigger and not U.has_modifiers(store, this, upg.modifier) then
				local m = E:create_entity(upg.modifier)

				m.modifier.source_id = this.id
				m.modifier.target_id = this.id

				queue_insert(store, m)
			end

			this._upgrade_data.heroes_lone_wolves.ts = store.tick_ts
		end
	end
end

local function alliance_merciless_upgrade(store, this)
	local upg = UP:get_upgrade("alliance_merciless")

	if upg and this.hero then
		if not this._upgrade_data then
			this._upgrade_data = {}
		end

		if not this._upgrade_data.alliance_merciless then
			this._upgrade_data.alliance_merciless = {}
		end

		if not this._upgrade_data.alliance_merciless.ts or store.tick_ts - this._upgrade_data.alliance_merciless.ts >= upg.check_cooldown then
			local towers_dark_army = table.filter(store.entities, function(k, e)
				return e.tower and not e.tower_holder and e.tower.team == TEAM_DARK_ARMY
			end)

			if not this._merciless_factor then
				this._merciless_factor = 0
			end

			local merciless_factor = #towers_dark_army * upg.damage_factor_per_tower
			local merciless_dif = merciless_factor - this._merciless_factor

			this.unit.damage_factor = this.unit.damage_factor + merciless_dif
			this._merciless_factor = merciless_factor
			this._upgrade_data.alliance_merciless.ts = store.tick_ts
		end
	end
end

local function alliance_corageous_upgrade(store, this)
	local upg = UP:get_upgrade("alliance_corageous_stand")

	if upg and this.hero and this.health then
		if not this._upgrade_data then
			this._upgrade_data = {}
		end

		if not this._upgrade_data.alliance_corageous_stand then
			this._upgrade_data.alliance_corageous_stand = {}
		end

		if not this._upgrade_data.alliance_corageous_stand.ts or store.tick_ts - this._upgrade_data.alliance_corageous_stand.ts >= upg.check_cooldown then
			local towers_linirea = table.filter(store.entities, function(k, e)
				return e.tower and not e.tower_holder and e.tower.team == TEAM_LINIREA
			end)

			if not this._base_hp_max then
				this._base_hp_max = this.health.hp_max
			end

			local corageous_hp_factor = 1 + #towers_linirea * upg.hp_factor_per_tower
			local old_hp_max = this.health.hp_max

			this.health.hp_max = this._base_hp_max * corageous_hp_factor

			if old_hp_max < this.health.hp_max then
				this.health.hp = this.health.hp + (this.health.hp_max - old_hp_max)
			end

			this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp)
			this._upgrade_data.alliance_corageous_stand.ts = store.tick_ts
		end
	end
end

local function can_melee_blocker(store, this, blocker)
	return not this.health.dead and not this.unit.is_stunned and blocker and not blocker.health.dead and this.enemy and table.contains(this.enemy.blockers, blocker.id) and store.entities[blocker.id]
end

local function can_range_soldier(store, this, soldier)
	for _, ar in pairs(this.ranged.attacks) do
		if (ar.hold_advance or store.tick_ts - ar.ts > ar.cooldown) and not this.health.dead and not this.unit.is_stunned and not soldier.health.dead and store.entities[soldier.id] and band(soldier.vis.bans, ar.vis_flags) == 0 and band(soldier.vis.flags, ar.vis_bans) == 0 and U.is_inside_ellipse(soldier.pos, this.pos, ar.max_range) and (ar.min_range == 0 or not U.is_inside_ellipse(soldier.pos, this.pos, ar.min_range)) then
			return true
		end
	end

	return false
end

local function enemy_interrupted(this)
	return this.health.dead or this.unit.is_stunned
end

local function y_enemy_wait(store, this, time)
	return U.y_wait(store, time, function(store, time)
		return enemy_interrupted(this)
	end)
end

local function y_enemy_animation_wait(this)
	while not U.animation_finished(this) do
		if enemy_interrupted(this) then
			return true
		end

		coroutine.yield()
	end

	return false
end

local function enemy_water_change(store, this)
	local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK)
	local w = this.water

	if terrain_type ~= w.last_terrain_type then
		log.paranoid("terrain changed from %s to %s", w.last_terrain_type, terrain_type)

		if w.ignore_pi == this.nav_path.pi then
			log.debug("Enemy %s ignored path %s for water change", this.id, w.ignore_pi)

			w.last_terrain_type = terrain_type

			return
		end

		if w.last_terrain_type and bor(w.last_terrain_type, terrain_type) == bor(TERRAIN_WATER, TERRAIN_LAND) then
			local fx = E:create_entity(w.splash_fx)

			fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
			fx.render.sprites[1].ts = store.tick_ts
			fx.pos = V.vclone(this.pos)

			queue_insert(store, fx)

			if this.sound_events and this.sound_events.water_splash then
				S:queue(this.sound_events.water_splash)
			end
		end

		if terrain_type == TERRAIN_WATER then
			this.vis.flags = bor(this.vis.flags, F_WATER)
			w._pushed_bans = U.push_bans(this.vis, this.water.vis_bans)
			this.motion.max_speed = this.motion.max_speed * this.water.speed_factor

			if this.health_bar then
				if this.water.health_bar_offset then
					this.health_bar._orig_offset = this.health_bar.offset
					this.health_bar.offset = this.water.health_bar_offset
				end

				if this.water.health_bar_hidden then
					this.health_bar.hidden = true
				end
			end
			
			if this.water.remove_modifiers then
				remove_modifiers(store, this)
			end

			if this.water.remove_modifier_templates then
				for _, n in pairs(this.water.remove_modifier_templates) do
					remove_modifiers(store, this, n)
				end
			end

			if this.water.hit_offset then
				this.unit._orig_hit_offset = this.unit.hit_offset
				this.unit.hit_offset = this.water.hit_offset
			end

			if this.water.mod_offset then
				this.unit._orig_mod_offset = this.unit.mod_offset
				this.unit.mod_offset = this.water.mod_offset
			end

			this.unit._orig_can_explode = this.unit.can_explode
			this.unit._orig_show_blood_pool = this.unit.show_blood_pool
			this.unit.can_explode = false
			this.unit.show_blood_pool = false

			for i = 1, #this.render.sprites do
				local s = this.render.sprites[i]

				if not string.match(s.prefix, this.water.sprite_suffix .. "$") then
					s.prefix = s.prefix .. this.water.sprite_suffix
				end

				s._orig_angles_flip_vertical = s.angles_flip_vertical
				s.angles_flip_vertical = this.water.angles_flip_vertical
			end

			if w.hide_sprites_range then
				local r = w.hide_sprites_range
				local f = r and r[1]
				local f, t = f, r and r[2]

				U.sprites_hide(this, f, t, true)
			end
		elseif w.last_terrain_type == TERRAIN_WATER and terrain_type == TERRAIN_LAND then
			this.vis.flags = band(this.vis.flags, bnot(F_WATER))

			if w._pushed_bans then
				U.pop_bans(this.vis, w._pushed_bans)

				w._pushed_bans = nil
			end

			this.motion.max_speed = this.motion.max_speed / this.water.speed_factor

			if this.water.health_bar_offset then
				this.health_bar.offset = this.health_bar._orig_offset
			end

			if this.water.health_bar_hidden then
				this.health_bar.hidden = false
			end

			if this.water.hit_offset then
				this.unit.hit_offset = this.unit._orig_hit_offset
			end

			if this.water.mod_offset then
				this.unit.mod_offset = this.unit._orig_mod_offset
			end

			this.unit.can_explode = this.unit._orig_can_explode
			this.unit.show_blood_pool = this.unit._orig_show_blood_pool

			for i = 1, #this.render.sprites do
				local s = this.render.sprites[i]

				if string.match(s.prefix, this.water.sprite_suffix .. "$") then
					s.prefix = string.gsub(s.prefix, this.water.sprite_suffix .. "$", "")
				end

				s.angles_flip_vertical = s._orig_angles_flip_vertical
			end

			if w.hide_sprites_range then
				local r = w.hide_sprites_range
				local f = r and r[1]
				local f, t = f, r and r[2]

				U.sprites_show(this, f, t, true)
			end
		end

		w.last_terrain_type = terrain_type
	end

	return terrain_type
end

local function enemy_cliff_change(store, this)
	local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK)
	local c = this.cliff

	if terrain_type ~= c.last_terrain_type then
		if terrain_type == TERRAIN_CLIFF then
			local next_pos = P:next_entity_node(this, store.tick_length)

			if next_pos and next_pos.y < this.pos.y then
				local i, j = GR:get_coords(this.pos.x, this.pos.y)

				while j > 1 and bit.band(GR:get_cell(i, j), TERRAIN_CLIFF) ~= 0 do
					j = j - 1
				end

				c.fall_to_pos = V.v(GR:cell_pos(i, j))
			else
				c.fall_to_pos = V.v(this.pos.x, this.pos.y)
			end

			this.vis.flags = bor(this.vis.flags, F_CLIFF)
			c._pushed_bans = U.push_bans(this.vis, c.vis_bans)
			this.motion.max_speed = this.motion.max_speed * c.speed_factor
			this.health.dead_lifetime = 3

			for i = 1, #this.render.sprites do
				local s = this.render.sprites[i]

				if c.hide_sprite_ids and table.contains(c.hide_sprite_ids, i) then
					s.hidden = true
				else
					s.z = Z_BACKGROUND_BETWEEN

					if not string.match(s.prefix, c.sprite_suffix .. "$") then
						s.prefix = s.prefix .. c.sprite_suffix
					end
				end
			end

			this.health_bar.z = Z_BACKGROUND_BETWEEN + 1
		elseif c.last_terrain_type == TERRAIN_CLIFF and terrain_type == TERRAIN_LAND then
			this.vis.flags = band(this.vis.flags, bnot(F_CLIFF))

			if c._pushed_bans then
				U.pop_bans(this.vis, c._pushed_bans)

				c._pushed_bans = nil
			end

			this.motion.max_speed = this.motion.max_speed / c.speed_factor
			this.health.dead_lifetime = 2

			for i = 1, #this.render.sprites do
				local s = this.render.sprites[i]

				if c.hide_sprite_ids and table.contains(c.hide_sprite_ids, i) then
					s.hidden = false
				else
					s.z = Z_OBJECTS

					if string.match(s.prefix, c.sprite_suffix .. "$") then
						s.prefix = string.gsub(s.prefix, c.sprite_suffix .. "$", "")
					end
				end
			end

			this.health_bar.z = Z_OBJECTS
		end

		c.last_terrain_type = terrain_type
	end

	return terrain_type
end

local function y_enemy_death(store, this)
	local function show_blood_pool(e, terrain_type)
		if e.unit.show_blood_pool and e.unit.blood_color ~= BLOOD_NONE and band(terrain_type, TERRAIN_WATER) == 0 then
			local decal = E:create_entity("decal_blood_pool")

			decal.pos = V.vclone(e.pos)
			decal.render.sprites[1].ts = store.tick_ts
			decal.render.sprites[1].name = e.unit.blood_color
			decal.render.sprites[1].z = e.render.sprites[1].z
			decal.render.sprites[1].sort_y_offset = 1

			queue_insert(store, decal)
		end
	end

	local can_spawn = this.death_spawns and band(this.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_NO_SPAWNS, this.death_spawns.no_spawn_damage_types or 0)) == 0

	if can_spawn and this.death_spawns.concurrent_with_death then
		do_death_spawns(store, this)
		coroutine.yield()

		can_spawn = false
	end

	local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK)

	if band(this.health.last_damage_types, bor(DAMAGE_EXPLOSION, DAMAGE_INSTAKILL, DAMAGE_FX_EXPLODE)) ~= 0 and band(this.health.last_damage_types, bor(DAMAGE_FX_NOT_EXPLODE, DAMAGE_DISINTEGRATE)) == 0 and this.unit.can_explode and this.unit.explode_fx and band(terrain_type, TERRAIN_WATER) == 0 then
		S:queue(this.sound_events.death_by_explosion)

		local fx = E:create_entity(this.unit.explode_fx)

		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]

		queue_insert(store, fx)
		show_blood_pool(this, terrain_type)

		this.unit.hide_during_death = true
	elseif band(this.health.last_damage_types, bor(DAMAGE_DISINTEGRATE)) ~= 0 and this.unit.can_disintegrate and this.unit.disintegrate_fx then
		local fx = E:create_entity(this.unit.disintegrate_fx)

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts

		if fx.render.sprites[1].size_names then
			fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
		end

		if band(this.vis.flags, F_FLYING) ~= 0 and this.unit.hit_offset then
			fx.render.sprites[1].offset.y = this.unit.hit_offset.y
		end

		queue_insert(store, fx)

		this.unit.hide_during_death = true
		this.unit.show_blood_pool = false
	elseif band(this.health.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
		this.unit.hide_during_death = true
		this.unit.show_blood_pool = false
	elseif band(terrain_type, TERRAIN_CLIFF) ~= 0 and band(this.vis.flags, F_FLYING) == 0 then
		if IS_TRILOGY then
			S:queue("WilhemScream")
		end

		S:queue(this.sound_events.death, this.sound_events.death_args)
		U.animation_start(this, "fall", nil, store.tick_ts, true)
		U.set_destination(this, this.cliff.fall_to_pos)

		while not U.walk(this, store.tick_length, this.cliff.fall_accel) do
			coroutine.yield()
		end

		show_blood_pool(this, terrain_type)
		U.y_animation_play(this, "death", nil, store.tick_ts, 1)
	elseif band(terrain_type, TERRAIN_WATER) ~= 0 and band(this.vis.flags, F_FLYING) == 0 then
		S:queue(this.sound_events.death_water, this.sound_events.death_water_args)
		U.y_animation_play(this, this.unit.death_animation, nil, store.tick_ts, 1)
	elseif this.unit.death_animation then
		S:queue(this.sound_events.death, this.sound_events.death_args)
		show_blood_pool(this, terrain_type)

		local an, af = this.unit.death_animation

		if this.heading and this.heading.angle then
			an, af = U.animation_name_for_angle(this, this.unit.death_animation, this.heading.angle)
		end

		U.animation_start(this, an, af, store.tick_ts, false)

		if can_spawn and this.death_spawns.delay then
			U.y_wait(store, this.death_spawns.delay)
			do_death_spawns(store, this)

			can_spawn = false
		end

		while not U.animation_finished(this) do
			coroutine.yield()
		end
	end

	this.health.death_finished_ts = store.tick_ts

	if can_spawn then
		do_death_spawns(store, this)
		coroutine.yield()

		can_spawn = false
	end

	if this.unit.hide_during_death or this.unit.hide_after_death then
		U.sprites_hide(this, nil, nil, true)
	end

	if this.ui then
		this.ui.can_click = not this.unit.hide_after_death and not this.unit.hide_during_death
		this.ui.z = -1
	end

	if this.unit.fade_time_after_death then
		fade_out_entity(store, this, this.unit.fade_time_after_death, this.unit.fade_duration_after_death, true)
	end
end

local function y_enemy_walk_step(store, this, animation_name, sprite_id)
	animation_name = animation_name or "walk"

	local next, new, use_path

	if this.motion.forced_waypoint then
		local w = this.motion.forced_waypoint

		next = w

		if V.dist(w.x, w.y, this.pos.x, this.pos.y) < 2 * this.motion.max_speed * store.tick_length then
			this.pos.x, this.pos.y = w.x, w.y
			this.motion.forced_waypoint = nil

			return false
		end
	else
		use_path = true
		next, new = P:next_entity_node(this, store.tick_length)

		if not next then
			log.debug("enemy %s ran out of nodes to walk", this.id)
			coroutine.yield()

			return false
		end
	end

	U.set_destination(this, next)

	local an, af = U.animation_name_facing_point(this, animation_name, this.motion.dest, sprite_id, nil, use_path)

	if this.sound_events and new then
		S:queue(this.sound_events.new_node, this.sound_events.new_node_args)
	end

	U.animation_start(this, an, af, store.tick_ts, true, sprite_id)
	U.walk(this, store.tick_length)
	coroutine.yield()

	this.motion.speed.x, this.motion.speed.y = 0, 0

	return true
end

local function y_enemy_walk_until_blocked(store, this, ignore_soldiers, func)
	local ranged, blocker
	local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND))

	while ignore_soldiers or not blocker and not ranged do
		if this.unit.is_stunned then
			return false
		end

		if func and func(store, this) then
			return false, nil, nil
		end

		if this.health.dead then
			return false
		end

		local node_valid = P:is_node_valid(this.nav_path.pi, this.nav_path.ni)

		if node_valid and not ignore_soldiers and this.ranged then
			for _, a in pairs(this.ranged.attacks) do
				if not a.disabled and (not a.requires_magic or this.enemy and this.enemy.can_do_magic) and (a.hold_advance or store.tick_ts - a.ts > a.cooldown) then
					ranged = U.find_nearest_soldier(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

					if ranged ~= nil then
						break
					end
				end
			end
		end

		if node_valid and not ignore_soldiers and this.enemy and #this.enemy.blockers > 0 then
			U.cleanup_blockers(store, this)

			blocker = store.entities[this.enemy.blockers[1]]
		end

		if ignore_soldiers or not blocker and not ranged then
			y_enemy_walk_step(store, this)
		else
			U.animation_start(this, "idle", nil, store.tick_ts, true)
		end

		if terrain_type ~= band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND)) then
			return false, nil, nil
		end
	end

	return true, blocker, ranged
end

local function y_wait_for_blocker(store, this, blocker)
	local pos = blocker.motion.arrived and blocker.pos or blocker.motion.dest
	local an, af = U.animation_name_facing_point(this, "idle", pos)

	U.animation_start(this, an, af, store.tick_ts, true)

	while not blocker.motion.arrived do
		coroutine.yield()

		if this.health.dead or this.unit.is_stunned or this.enemy and not table.contains(this.enemy.blockers, blocker.id) or blocker.health.dead or not store.entities[blocker.id] then
			return false
		end

		if blocker.unit.is_stunned then
			U.unblock_target(store, blocker)

			return false
		end
	end

	return true
end

local function y_enemy_do_ranged_attack(store, this, target, attack)
	local an, af, ai = U.animation_name_facing_point(this, attack.animation, target.pos)

	U.animation_start(this, an, af, store.tick_ts, false)

	while store.tick_ts - attack.ts < attack.shoot_time do
		if this.health.dead or this.unit.is_stunned and not attack.ignore_stun then
			return false
		end

		coroutine.yield()
	end

	if band(target.vis.bans, attack.vis_flags) == 0 and band(target.vis.flags, attack.vis_bans) == 0 then
		local bullet = E:create_entity(attack.bullet)

		bullet.pos = V.vclone(this.pos)

		if attack.bullet_start_offset then
			local offset = attack.bullet_start_offset[ai]

			bullet.pos.x, bullet.pos.y = bullet.pos.x + (af and -1 or 1) * offset.x, bullet.pos.y + offset.y
		end

		bullet.bullet.from = V.vclone(bullet.pos)
		bullet.bullet.to = V.vclone(target.pos)

		if not attack.ignore_hit_offset then
			bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
			bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
		end

		bullet.bullet.target_id = target.id
		bullet.bullet.source_id = this.id

		if attack.damage_factor then
			bullet.bullet.damage_factor = attack.damage_factor
		end

		queue_insert(store, bullet)
	end

	while not U.animation_finished(this) do
		if this.health.dead or this.unit.is_stunned and not attack.ignore_stun then
			return false
		end

		coroutine.yield()
	end

	U.animation_start(this, "idle", nil, store.tick_ts, true)

	return true
end

local function y_enemy_do_loopable_ranged_attack(store, this, target, attack)
	local attack_done = false
	local b

	S:queue(attack.sound)

	local an, af, ai = U.animation_name_facing_point(this, attack.animations[1], target.pos)

	U.y_animation_play(this, an, af, store.tick_ts, 1)

	for i = 1, attack.loops do
		an, af, ai = U.animation_name_facing_point(this, attack.animations[2], target.pos)

		U.animation_start(this, an, af, store.tick_ts, false)

		local shoot_times = attack.shoot_times or {
			attack.shoot_time
		}

		for si, st in pairs(shoot_times) do
			while st > store.tick_ts - this.render.sprites[1].ts do
				if this.unit.is_stunned and not attack.ignore_stun then
					goto label_111_0
				end

				if this.health.dead then
					goto label_111_1
				end

				coroutine.yield()
			end

			b = E:create_entity(attack.bullet)
			b.pos = V.vclone(this.pos)

			if attack.bullet_start_offset then
				local offset = attack.bullet_start_offset[ai]

				b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
			end

			b.bullet.from = V.vclone(b.pos)
			b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
			b.bullet.target_id = target.id
			b.bullet.source_id = this.id

			if attack.damage_factor then
				b.bullet.damage_factor = attack.damage_factor
			end

			queue_insert(store, b)

			attack_done = true
		end

		while not U.animation_finished(this) do
			if this.unit.is_stunned and not attack.ignore_stun then
				goto label_111_0
			end

			if this.health.dead then
				goto label_111_1
			end

			coroutine.yield()
		end
	end

	::label_111_0::

	an, af, ai = U.animation_name_facing_point(this, attack.animations[3], target.pos)

	U.animation_start(this, an, af, store.tick_ts, 1)

	while not U.animation_finished(this) do
		if this.health.dead then
			break
		end

		coroutine.yield()
	end

	::label_111_1::

	return attack_done
end

local function y_enemy_range_attacks(store, this, target)
	for _, i in ipairs(this.ranged.order) do
		local ar = this.ranged.attacks[i]
		local cooldown = ar.cooldown

		if this.ranged.cooldown and ar.shared_cooldown then
			cooldown = this.ranged.cooldown
		end

		if not ar.disabled and cooldown <= store.tick_ts - ar.ts and band(ar.vis_flags, target.vis.bans) == 0 and band(ar.vis_bans, target.vis.flags) == 0 and (not ar.sync_animation or this.render.sprites[1].sync_flag) then
			ar.ts = store.tick_ts

			if math.random() >= ar.chance then
				-- block empty
			else
				for _, aa in pairs(this.ranged.attacks) do
					if aa ~= ar and aa.shared_cooldown then
						aa.ts = ar.ts
					end
				end

				local attack_done

				if ar.loops then
					attack_done = y_enemy_do_loopable_ranged_attack(store, this, target, ar)
				else
					attack_done = y_enemy_do_ranged_attack(store, this, target, ar)
				end

				return attack_done
			end
		end
	end

	return true
end

local function y_enemy_melee_attacks(store, this, target)
	for _, i in ipairs(this.melee.order) do
		local ma = this.melee.attacks[i]
		local cooldown = ma.cooldown

		if ma.shared_cooldown then
			cooldown = this.melee.cooldown
		end

		if not ma.disabled and cooldown <= store.tick_ts - ma.ts and band(ma.vis_flags, target.vis.bans) == 0 and band(ma.vis_bans, target.vis.flags) == 0 and (not ma.fn_can or ma.fn_can(this, store, ma, target)) then
			ma.ts = store.tick_ts

			if math.random() >= ma.chance then
				-- block empty
			else
				log.paranoid("attack %i selected for entity %s", i, this.template_name)

				for _, aa in pairs(this.melee.attacks) do
					if aa ~= ma and aa.shared_cooldown then
						aa.ts = ma.ts
					end
				end

				ma.ts = store.tick_ts

				S:queue(ma.sound, ma.sound_args)

				local an, af = U.animation_name_facing_point(this, ma.animation, target.pos)

				for i = 1, #this.render.sprites do
					if this.render.sprites[i].animated then
						U.animation_start(this, an, af, store.tick_ts, 1, i)
					end
				end

				local hit_pos = V.vclone(this.pos)

				if ma.hit_offset then
					hit_pos.x = hit_pos.x + (af and -1 or 1) * ma.hit_offset.x
					hit_pos.y = hit_pos.y + ma.hit_offset.y
				end

				local hit_times = ma.hit_times and ma.hit_times or {
					ma.hit_time
				}

				for i = 1, #hit_times do
					local hit_time = hit_times[i]
					local dodged = false

					if ma.dodge_time and target.dodge then
						local dodge_time = ma.dodge_time

						if target.dodge and target.dodge.time_before_hit then
							dodge_time = hit_time - target.dodge.time_before_hit
						end

						while dodge_time > store.tick_ts - ma.ts do
							if this.health.dead or this.unit.is_stunned and not ma.ignore_stun or this.dodge and this.dodge.active and not this.dodge.silent then
								return false
							end

							coroutine.yield()
						end

						dodged = unit_dodges(store, target, false, ma, this)
					end

					while hit_time > store.tick_ts - ma.ts do
						if this.health.dead or this.unit.is_stunned and not ma.ignore_stun or this.dodge and this.dodge.active and not this.dodge.silent then
							return false
						end

						coroutine.yield()
					end

					S:queue(ma.sound_hit, ma.sound_hit_args)

					if ma.type == "melee" and not dodged and this.enemy and table.contains(this.enemy.blockers, target.id) then
						local d = E:create_entity("damage")

						d.source_id = this.id
						d.target_id = target.id
						d.track_kills = this.track_kills ~= nil
						d.track_damage = ma.track_damage
						d.pop = ma.pop
						d.pop_chance = ma.pop_chance
						d.pop_conds = ma.pop_conds

						if ma.instakill then
							d.damage_type = DAMAGE_INSTAKILL

							queue_damage(store, d)
						elseif ma.damage_min then
							d.damage_type = ma.damage_type
							d.value = math.ceil(this.unit.damage_factor * math.random(ma.damage_min, ma.damage_max))

							queue_damage(store, d)
						end

						if ma.mod or ma.mods then
							local mods = ma.mods or {
								ma.mod
							}
				
							for _, mod_name in pairs(mods) do
								local m = E:create_entity(mod_name)
				
								m.modifier.target_id = target.id
								m.modifier.source_id = this.id
				
								queue_insert(store, m)
							end
						end
					elseif ma.type == "area" then
						local targets = table.filter(store.entities, function(_, e)
							return e.soldier and e.vis and e.health and not e.health.dead and band(e.vis.flags, ma.vis_bans) == 0 and band(e.vis.bans, ma.vis_flags) == 0 and U.is_inside_ellipse(e.pos, hit_pos, ma.damage_radius) and (not ma.fn_filter or ma.fn_filter(this, store, ma, e))
						end)

						for i, e in ipairs(targets) do
							if e == target and dodged then
								-- block empty
							else
								if ma.count and i > ma.count then
									break
								end

								local d = E:create_entity("damage")

								d.source_id = this.id
								d.target_id = e.id
								d.damage_type = ma.damage_type
								d.value = math.ceil(this.unit.damage_factor * math.random(ma.damage_min, ma.damage_max))
								d.pop = ma.pop
								d.pop_chance = ma.pop_chance
								d.pop_conds = ma.pop_conds

								queue_damage(store, d)

								if ma.mod or ma.mods then
									local mods = ma.mods or {
										ma.mod
									}
						
									for _, mod_name in pairs(mods) do
										local m = E:create_entity(mod_name)
						
										m.modifier.target_id = e.id
										m.modifier.source_id = this.id
						
										queue_insert(store, m)
									end
								end
							end
						end
					end

					if ma.hit_fx and (not ma.hit_fx_once or i == 1) then
						local fx = E:create_entity(ma.hit_fx)

						fx.pos = V.vclone(hit_pos)

						if ma.hit_fx_offset then
							fx.pos.x = fx.pos.x + (af and -1 or 1) * ma.hit_fx_offset.x
							fx.pos.y = fx.pos.y + ma.hit_fx_offset.y
						end

						for i = 1, #fx.render.sprites do
							if ma.hit_fx_flip then
								fx.render.sprites[i].flip_x = af
							end

							fx.render.sprites[i].ts = store.tick_ts
						end

						queue_insert(store, fx)
					end

					if ma.hit_decal then
						local fx = E:create_entity(ma.hit_decal)

						fx.pos = V.vclone(hit_pos)

						for i = 1, #fx.render.sprites do
							fx.render.sprites[i].ts = store.tick_ts
						end

						queue_insert(store, fx)
					end
				end

				while not U.animation_finished(this) do
					if this.health.dead or ma.ignore_stun and this.unit.is_stunned or this.dodge and this.dodge.active and not this.dodge.silent then
						return false
					end

					coroutine.yield()
				end

				U.animation_start(this, "idle", nil, store.tick_ts, true)

				return true
			end
		end
	end

	return true
end

local function y_enemy_stun(store, this)
	local flip_x = this.motion and this.motion.dest.x < this.pos.x or nil

	U.animation_start(this, "idle", flip_x, store.tick_ts, true)
	coroutine.yield()
end

local function y_enemy_mixed_walk_melee_ranged(store, this, ignore_soldiers, walk_break_fn, melee_break_fn, ranged_break_fn)
	ranged_break_fn = ranged_break_fn or melee_break_fn

	local cont, blocker, ranged = y_enemy_walk_until_blocked(store, this, ignore_soldiers, walk_break_fn)

	if not cont then
		return false
	end

	if blocker then
		if not y_wait_for_blocker(store, this, blocker) then
			return false
		end

		while can_melee_blocker(store, this, blocker) and (not melee_break_fn or not melee_break_fn(store, this)) do
			if not y_enemy_melee_attacks(store, this, blocker) then
				return false
			end

			coroutine.yield()
		end
	elseif ranged then
		while can_range_soldier(store, this, ranged) and this.enemy and #this.enemy.blockers == 0 and (not ranged_break_fn or not ranged_break_fn(store, this)) do
			if not y_enemy_range_attacks(store, this, ranged) then
				return false
			end

			coroutine.yield()
		end
	end

	return true
end

local function y_show_taunt_set(store, taunts, set_name, index, pos, duration, wait, decal)
	local set = taunts.sets[set_name]

	index = index or set.idxs and table.random(set.idxs) or math.random(set.start_idx, set.end_idx)
	duration = duration or taunts.duration
	pos = pos or set.pos or taunts.pos

	local offset = set.offset or taunts.offset or v(0, 0)
	local t = E:create_entity(decal or set.decal_name or taunts.decal_name)

	t.texts.list[1].text = _(string.format(set.format, index))
	t.pos.x, t.pos.y = pos.x + offset.x, pos.y + offset.y
	t.tween.ts = store.tick_ts
	t.duration = duration
	t.start_ts = store.tick_ts

	queue_insert(store, t)

	if wait then
		U.y_wait(store, duration)
	end

	return t
end

local function y_spawner_spawn(store, this)
	local sp = this.spawner

	sp._last_subpath = sp._last_subpath or math.random(1, 3)

	local spawns = {}

	for i = 1, sp.count do
		if sp.interrupt then
			return true, spawns
		end

		local spawn = E:create_entity(sp.entity)

		spawn.nav_path.pi = sp.pi

		if sp.random_subpath then
			spawn.nav_path.spi = sp.allowed_subpaths[math.random(1, #sp.allowed_subpaths)]
		else
			sp._last_subpath = km.zmod(sp._last_subpath + 1, #sp.allowed_subpaths)
			spawn.nav_path.spi = sp.allowed_subpaths[sp._last_subpath]
		end

		if sp.forced_waypoint_offset then
			spawn.motion.forced_waypoint = V.v(this.pos.x + sp.forced_waypoint_offset.x, this.pos.y + sp.forced_waypoint_offset.y)
		elseif sp.forced_waypoint then
			spawn.motion.forced_waypoint = V.v(sp.forced_waypoint.x, sp.forced_waypoint.y)
		end

		if spawn.motion.forced_waypoint then
			local fw = spawn.motion.forced_waypoint
			local pis = P:get_connected_paths(sp.pi)
			local nodes = P:nearest_nodes(fw.x, fw.y, pis, {
				spawn.nav_path.spi
			}, true)

			if #nodes < 1 then
				log.error("(%s) could not find point to spawn near %s,%s", this.id, fw.x, fw.y)
			else
				spawn.nav_path.pi = nodes[1][1]
				spawn.nav_path.ni = nodes[1][3] + sp.node_offset
			end
		else
			spawn.nav_path.ni = sp.ni + sp.node_offset
			spawn.motion.forced_waypoint = P:node_pos(spawn.nav_path)
		end

		spawn.pos.x, spawn.pos.y = this.pos.x + sp.pos_offset.x, this.pos.y + sp.pos_offset.y
		spawn.render.sprites[1].name = sp.initial_spawn_animation
		spawn.unit.spawner_id = this.id

		if sp.patch_props then
			spawn = table.deepmerge(spawn, sp.patch_props)
		end

		queue_insert(store, spawn)
		table.insert(spawns, spawn)

		local spawn_ts = store.tick_ts

		while store.tick_ts - spawn_ts < sp.cycle_time do
			if sp.interrupt then
				return true, spawns
			end

			coroutine.yield()
		end
	end

	return false, spawns
end

local function deck_shuffle(deck)
	deck.trigger_list = table.random_order(deck.trigger_list)

	local trigger_indexes = {}

	for i = #deck.trigger_list - deck.trigger_cards + 1, #deck.trigger_list do
		table.insert(trigger_indexes, deck.trigger_list[i])
	end

	deck.trigger_indexes = trigger_indexes
end

local function deck_new(trigger_cards, total_cards, dont_shuffle)
	if total_cards <= trigger_cards then
		log.error("Deck cant have more or equal trigger cards than total cards")

		return nil
	end

	local trigger_list = {}

	for i = 1, total_cards do
		table.insert(trigger_list, i)
	end

	local deck = {
		dont_shuffle = false,
		index = 1,
		trigger_cards = trigger_cards,
		total_cards = total_cards,
		trigger_indexes = {},
		trigger_list = trigger_list
	}

	if dont_shuffle then
		deck.dont_shuffle = true

		for i = #deck.trigger_list - deck.trigger_cards + 1, #deck.trigger_list do
			table.insert(deck.trigger_indexes, deck.trigger_list[i])
		end

		return deck
	end

	deck_shuffle(deck)

	return deck
end

local function deck_draw(deck)
	local is_trigger = false

	if deck.index and deck.trigger_indexes and table.contains(deck.trigger_indexes, deck.index) then
		is_trigger = true
	end

	deck.index = km.zmod(deck.index + 1, deck.total_cards)

	if deck.index == 1 and not deck.dont_shuffle then
		deck_shuffle(deck)
	end

	return is_trigger
end

local function towers_keen_accuracy_upgrade(store, this, damaging_obj)
	local upg = UP:get_upgrade("towers_keen_accuracy")

	if upg and this.tower then
		if not this._keen_accuracy_deck then
			this._keen_accuracy_deck = deck_new(upg.trigger_cards, upg.total_cards)
		end

		local is_trigger = deck_draw(this._keen_accuracy_deck)

		if is_trigger then
			if damaging_obj.bullet then
				damaging_obj.bullet.pop = {
					"pop_crit"
				}
				damaging_obj.bullet.pop_conds = DR_DAMAGE
				damaging_obj.bullet.damage_min = damaging_obj.bullet.damage_min * upg.damage_factor
				damaging_obj.bullet.damage_max = damaging_obj.bullet.damage_max * upg.damage_factor
			elseif damaging_obj.template_name == "damage" then
				damaging_obj.value = damaging_obj.value * upg.damage_factor
			end
		end
	end
end

local function towers_swaped(store, this, attacks)
	if this.tower_upgrade_persistent_data.swaped then
		for _, a in pairs(attacks) do
			a.ts = store.tick_ts
		end

		if this.powers then
			for _, pow in pairs(this.powers) do
				if pow.level > 0 and pow.show_rally then
					this.tower.show_rally = true
				end
			end
		end

		this.tower_upgrade_persistent_data.swaped = nil
	end
end

-- customization
local function check_tower_attack_available(store, tower, attack)
	if not tower or not tower.tower then
		log.error("%s is not a tower.", tower and tower.template_name or "Nil")
		return false
	end
	if not attack.disabled and attack.ts and attack.ts ~= 0 and (not attack.can_be_silenced or tower.tower.can_do_magic) and store.tick_ts - attack.ts >= attack.cooldown then
		return true
	end
	return false
end

local function check_unit_attack_available(store, unit, attack)
	if not unit or not unit.unit then
		log.error("%s is not a unit.", unit and unit.template_name or "Nil")
		return false
	end
	if not attack.disabled and attack.ts and attack.ts ~= 0 and (not attack.can_be_silenced or not unit.enemy or unit.enemy and unit.enemy.can_do_magic) and 
	store.tick_ts - attack.ts >= attack.cooldown and (not attack.sync_animation or unit.render.sprites[1].sync_flag) then
		return true
	end
	return false
end

local function make_bullet_damage_targets(this, store, target)
	local b = this.bullet
	if b.damage_radius and b.damage_radius > 0 then
		local targetPos = V.vclone(b.to)
		if not b.ignore_hit_offset and target and target.unit and target.unit.hit_offset then
			local flip_sign = target.render and target.render.sprites[1].flip_x and -1 or 1
			targetPos.x, targetPos.y = targetPos.x - target.unit.hit_offset.x * flip_sign, targetPos.y - target.unit.hit_offset.y
		end
		local targets = U.find_enemies_in_range(store.entities, targetPos, 0, b.damage_radius, b.vis_flags, b.vis_bans)
		if targets then
			for _, target in ipairs(targets) do
				local d = create_bullet_damage(b, target.id, this.id)
				queue_damage(store, d)
				if b.mod or b.mods then
					local mods = b.mods or {
						b.mod
					}
					for _, mod_name in ipairs(mods) do
						local m = E:create_entity(mod_name)
						m.modifier.source_id = this.id
						m.modifier.target_id = target.id
						m.modifier.level = b.level
						m.modifier.source_damage = d
						queue_insert(store, m)
					end
				end
			end
		end
	elseif target and target.health and not target.health.dead then
		local d = create_bullet_damage(b, target.id, this.id)
		queue_damage(store, d)
		if b.mod or b.mods then
			local mods = b.mods or {
				b.mod
			}
			for _, mod_name in ipairs(mods) do
				local m = E:create_entity(mod_name)
				m.modifier.source_id = this.id
				m.modifier.target_id = target.id
				m.modifier.level = b.level
				m.modifier.source_damage = d
				queue_insert(store, m)
			end
		end
	end
end

local function create_bullet_hit_payload(this, store, flip_x)
	local b = this.bullet
	if b.hit_payload then
		local function insert_payload(hp)
			if hp.pos.x == 0 and hp.pos.y == 0 then
				hp.pos.x, hp.pos.y = b.to.x, b.to.y
			end
			if hp.render then
				for _, s in pairs(hp.render.sprites) do
					s.ts = store.tick_ts
					s.flip_x = flip_x
				end
			end
			if hp.aura then
				hp.aura.level = b.level
			end
			queue_insert(store, hp)
		end

		local payloadType = type(b.hit_payload)
		local hp
		if payloadType == "string" then
			hp = E:create_entity(b.hit_payload)
			insert_payload(hp)
		elseif payloadType == "table" then
			for i, v in ipairs(b.hit_payload) do
				if type(v) == "string" then
					hp = E:create_entity(v)
				else
					hp = v
				end
				insert_payload(hp)
			end
		else
			hp = b.hit_payload
			insert_payload(hp)
		end
	end
end

local function create_bullet_hit_fx(this, store, target, flip_x)
	local b = this.bullet
	if b.hit_fx then
		local hit_fx_pos = V.vclone(b.to)
		if b.hit_fx_ignore_hit_offset and target and target.pos then
			hit_fx_pos.x, hit_fx_pos.y = target.pos.x, target.pos.y
		end
		local hit_fx = insert_sprite(store, b.hit_fx, hit_fx_pos, flip_x)
		if hit_fx and hit_fx.render and target and target.unit then
			for _, s in pairs(hit_fx.render.sprites) do
				if s.size_names then
					s.name = s.size_names[target.unit.size]
				end
				if s.size_scales then
					s.scale = s.size_scales[target.unit.size]
				end
			end
		end
	end
end

local function create_bullet_hit_decal(this, store, flip_x)
	local b = this.bullet
	if b.hit_decal then
		insert_sprite(store, b.hit_decal, b.to, flip_x)
	end
end

local function hide_shadow(this, isHidden)
	for _, sprite in pairs(this.render.sprites) do
		if sprite.is_shadow then
			sprite.hidden = isHidden
		end
	end
end

local function entity_interrupted(this)
	return this.nav_rally and this.nav_rally.new or this.health and this.health.dead or this.unit and this.unit.is_stunned or this.tower and this.tower.blocked 
	or this.owner and entity_interrupted(this.owner)
end

local function y_entity_wait(store, this, time)
	return U.y_wait(store, time, function(store, time)
		return entity_interrupted(this)
	end)
end

local function y_entity_animation_wait(this)
	while not U.animation_finished(this) do
		if entity_interrupted(this) then
			return true
		end
		coroutine.yield()
	end
	return false
end

local function entity_casts_spawner(store, this, a)
	local min_targets = a.min_targets or 1
	if a.range_nodes and a.range_nodes > 0 and a.vis_bans and band(a.vis_bans, F_FRIEND) ~= 0 then
		local targets = U.find_enemies_in_paths(store.entities, this.pos, 0, a.range_nodes, nil, 0, a.vis_bans, true, a.filter_fn)
		if not targets or #targets < min_targets then
			return false
		end
	elseif a.range and a.range > 0 then
		local targets = nil
		if a.vis_bans and band(a.vis_bans, F_ENEMY) ~= 0 then
			targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.range, 0, a.vis_bans, a.filter_fn)
		elseif a.vis_bans and band(a.vis_bans, F_FRIEND) ~= 0 then
			targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, 0, a.vis_bans, a.filter_fn)
		else
			local vis_bans = a.vis_bans or 0
			targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, 0, vis_bans, a.filter_fn)
			local soldiers = U.find_soldiers_in_range(store.entities, this.pos, 0, a.range, 0, vis_bans, a.filter_fn)
			if targets then
				if soldiers then
					table.merge(targets, soldiers)
				end
			else
				targets = soldiers
			end
		end
		if not targets or #targets < min_targets then
			return false
		end
	end

	if a.custom_spawn_points and type(a.custom_spawn_points) == "table" then
		local start_ts = store.tick_ts
		S:queue(a.sound, a.sound_args)
		U.animation_start(this, a.animation, nil, store.tick_ts)
		if y_entity_wait(store, this, a.spawn_time) then
			return true
		end
		local max_count = math.min(a.max_count or 1, #a.custom_spawn_points)
		for i = 1, max_count do
			if y_entity_wait(store, this, a.spawn_delay) then
				return true
			end
			local e_name = a.entity_names[U.random_table_idx(a.entity_chances)]
			local e = E:create_entity(e_name)
			if e.enemy then
				e.enemy.gold = 0
			end
			if e.render then
				e.render.sprites[1].name = "raise"
			end
			e.pos = a.custom_spawn_points[i]
			queue_insert(store, e)
		end
		a.ts = start_ts
		if a.xp_from_skill then
			hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
		end
		y_entity_animation_wait(this)
		return true
	elseif this.nav_path then
		local nodes_to_entrance = a.nodes_to_entrance or 0
		local nodes_to_exit = a.nodes_to_exit or 0
		local skip = this.nav_path.ni <= nodes_to_entrance or P:nodes_to_defend_point(this.nav_path) <= nodes_to_exit
		if not skip then
			local start_ts = store.tick_ts
			S:queue(a.sound, a.sound_args)
			U.animation_start(this, a.animation, nil, store.tick_ts)
			if y_entity_wait(store, this, a.spawn_time) then
				return true
			end
			local max_count = a.max_count or 1
			local min_nodes = a.min_nodes or 0
			local max_nodes = a.max_nodes or 0
			for i = 1, max_count do
				if y_entity_wait(store, this, a.spawn_delay) then
					return true
				end
				local e_name = a.entity_names[U.random_table_idx(a.entity_chances)]
				local e = E:create_entity(e_name)
				if e.nav_path then
					e.nav_path.pi = this.nav_path.pi
					if a.use_center then
						e.nav_path.spi = 1
					elseif a.random_subpath then
						e.nav_path.spi = math.random(1, 3)
					else
						e.nav_path.spi = this.nav_path.spi
					end
					e.nav_path.ni = km.clamp(1, P:get_end_node(this.nav_path.pi), this.nav_path.ni + math.random(min_nodes, max_nodes))
				end
				if P:is_node_valid(e.nav_path.pi, e.nav_path.ni) then
					if e.enemy then
						e.enemy.gold = 0
					end
					if e.render then
						e.render.sprites[1].name = "raise"
					end
					e.pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni)
					queue_insert(store, e)
				end
			end
			a.ts = start_ts
			if a.xp_from_skill then
				hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
			end
			y_entity_animation_wait(this)
			return true
		end
	end
	return false
end

local function entity_casts_range_unit(store, this, a)
	local target, targets, pred_pos
	local prediction_time = a.node_prediction or 0
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

	local function get_target(prediction_time)
		local target, targets, pred_pos
		if a.vis_bans and band(a.vis_bans, F_ENEMY) ~= 0 then
			target, targets, pred_pos = U.find_soldier_with_search_type(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, 
			filter_fn, a.search_type, a.crowd_range, a.min_targets)
		elseif a.vis_bans and band(a.vis_bans, F_FRIEND) ~= 0 then
			target, targets, pred_pos = U.find_enemy_with_search_type(store.entities, this.pos, a.min_range, a.max_range, prediction_time, 
			a.vis_flags, a.vis_bans, filter_fn, F_FLYING, a.search_type, a.crowd_range, a.min_targets)
		else
			target, targets, pred_pos = U.find_enemy_with_search_type(store.entities, this.pos, a.min_range, a.max_range, prediction_time, 
			a.vis_flags, a.vis_bans, filter_fn, F_FLYING, a.search_type, a.crowd_range, a.min_targets)
			local soldier, soldiers, soldier_pos = U.find_soldier_with_search_type(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, 
			filter_fn, a.search_type, a.crowd_range, a.min_targets)
			if targets then
				if soldiers then
					table.merge(targets, soldiers)
				end
			else
				target, targets, pred_pos = soldier, soldiers, soldier_pos
			end
		end
		return target, targets, pred_pos
	end

	target, targets, pred_pos = get_target(a.cast_time + prediction_time)
	if target then
		S:queue(a.sound, a.sound_args)
		local start_ts = store.tick_ts
		local an, af, ai = U.animation_name_facing_point(this, a.animation, pred_pos)
		U.animation_start(this, an, af, store.tick_ts)
		if not y_entity_wait(store, this, a.cast_time) then
			local oldTarget = target
			target = store.entities[target.id]
			if not target or target.health.dead then
				local newTarget, newTargets, newPredPos = get_target(prediction_time)
				if newTarget then
					target = newTarget
					targets = newTargets
					pred_pos = newPredPos
				else
					target = oldTarget
				end
			end
			local max_bullets = a.max_bullets or 1
			for i = 1, max_bullets do
				if not a.same_target then
					target = targets[km.zmod(i, #targets)]
				end
				local tpi, tspi, tni
				if target.nav_path then
					tpi, tspi, tni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
				else
					local nodes
					if this.nav_path then
						tpi, tspi = this.nav_path.pi, this.nav_path.spi
						nodes = P:nearest_nodes(target.pos.x, target.pos.y, { tpi }, { tspi })
					else
						nodes = P:nearest_nodes(target.pos.x, target.pos.y)
					end
					if #nodes >= 1 then
						tpi, tspi, tni = unpack(nodes[1])
					end
				end
				local bullet = E:create_entity(a.bullet)
				bullet.bullet.source_id = this.id
				bullet.bullet.shot_index = i
				if a.use_center then
					tspi = 1
					if tni then
						local offset = U.get_prediction_offset(target, prediction_time)
						tni = tni + offset.node
						pred_pos = P:node_pos(tpi, tspi, tni)
						bullet.bullet.target_id = nil
					end
				else
					bullet.bullet.target_id = target.id
				end
				if bullet.spawn_pos_offset then
					bullet.pos = target.pos
				else
					bullet.bullet.to = pred_pos
					local start_offset = a.bullet_start_offset[ai]
					local flipSign = af and -1 or 1
					bullet.bullet.from = V.v(this.pos.x + start_offset.x * flipSign, this.pos.y + start_offset.y)
					bullet.pos = V.vclone(bullet.bullet.from)
				end
				if bullet.bullet.hit_payload then
					local hit_payload = {}
					local function create_hit_payload(hp_name)
						local hp = E:create_entity(hp_name)
						if hp.path_index then
							hp.path_index = tpi
						end
						if hp.nav_path and tni then
							hp.nav_path.pi = tpi
							hp.nav_path.spi = tspi
							hp.nav_path.ni = tni
						end
						if hp.insert_delay then
							controller = E:create_entity("entities_delay_controller")
							controller.delays = { hp.insert_delay }
							controller.entities = { hp }
							table.insert(hit_payload, controller)
						else
							table.insert(hit_payload, hp)
						end
					end
					if type(bullet.bullet.hit_payload) == "table" then
						for i, hp_name in ipairs(bullet.bullet.hit_payload) do
							create_hit_payload(hp_name)
						end
					else
						create_hit_payload(bullet.bullet.hit_payload)
					end
					bullet.bullet.hit_payload = hit_payload
				end
				if bullet.bullet.use_unit_damage_factor and this.unit then
					bullet.bullet.damage_factor = this.unit.damage_factor
				end
				queue_insert(store, bullet)
			end
			a.ts = start_ts
			if a.xp_from_skill then
				hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
			end
			y_entity_animation_wait(this)
		end
		return true
	end
	return false
end

local function entity_casts_range_at_path(store, this, a)
	local min_targets = a.min_targets or 1
	if a.range_nodes and a.range_nodes > 0 and a.vis_bans and band(a.vis_bans, F_FRIEND) ~= 0 then
		local targets = U.find_enemies_in_paths(store.entities, this.pos, 0, a.range_nodes, nil, 0, a.vis_bans, true, a.filter_fn)
		if not targets or #targets < min_targets then
			return false
		end
	elseif a.range and a.range > 0 then
		local targets = nil
		if a.vis_bans and band(a.vis_bans, F_ENEMY) ~= 0 then
			targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.range, 0, a.vis_bans, a.filter_fn)
		elseif a.vis_bans and band(a.vis_bans, F_FRIEND) ~= 0 then
			targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, 0, a.vis_bans, a.filter_fn)
		else
			local vis_bans = a.vis_bans or 0
			targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, 0, vis_bans, a.filter_fn)
			local soldiers = U.find_soldiers_in_range(store.entities, this.pos, 0, a.range, 0, vis_bans, a.filter_fn)
			if targets then
				if soldiers then
					table.merge(targets, soldiers)
				end
			else
				targets = soldiers
			end
		end
		if not targets or #targets < min_targets then
			return false
		end
	end
	local tpi, tspi, tni
	if this.nav_path then
		local tpi, tspi, tni = this.nav_path.pi, this.nav_path.spi, this.nav_path.ni
	else
		local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)
		if #nodes >= 1 then
			tpi, tspi, tni = unpack(nodes[1])
		else
			return false
		end
	end

	local function new_bullet_to(i)
		local sign = (i % 2 == 1) and 1 or -1
		local node = km.clamp(1, P:get_end_node(tpi), math.random(a.min_nodes, a.max_nodes) * sign + tni)
		local subpath = a.use_center and 1 or math.random(1, 3)
		local pos = P:node_pos(tpi, subpath, node)
		return pos, subpath, node
	end

	local start_ts = store.tick_ts
	S:queue(a.sound, a.sound_args)
	local first_pos, first_subpath, first_node = new_bullet_to(1)
	local an, af, ai = U.animation_name_facing_point(this, a.animation, first_pos)
	U.animation_start(this, an, af, store.tick_ts)
	if not y_entity_wait(store, this, a.cast_time) then
		local max_bullets = a.max_bullets or 1
		for i = 1, max_bullets do
			local bullet = E:create_entity(a.bullet)
			bullet.bullet.source_id = this.id
			bullet.bullet.shot_index = i
			bullet.bullet.target_id = nil
			local subpath, node
			if i == 1 then
				bullet.bullet.to, subpath, node = first_pos, first_subpath, first_node
			else
				bullet.bullet.to, subpath, node = new_bullet_to(i)
			end
			if bullet.spawn_pos_offset then
				bullet.pos = bullet.bullet.to
			else
				local start_offset = a.bullet_start_offset[ai]
				local flipSign = af and -1 or 1
				bullet.bullet.from = V.v(this.pos.x + start_offset.x * flipSign, this.pos.y + start_offset.y)
				bullet.pos = V.vclone(bullet.bullet.from)
			end
			if bullet.bullet.hit_payload then
				local hit_payload = {}
				local function create_hit_payload(hp_name)
					local hp = E:create_entity(hp_name)
					if hp.path_index then
						hp.path_index = tpi
					end
					if hp.nav_path then
						hp.nav_path.pi = tpi
						hp.nav_path.spi = subpath
						hp.nav_path.ni = node
					end
					if hp.insert_delay then
						controller = E:create_entity("entities_delay_controller")
						controller.delays = { hp.insert_delay }
						controller.entities = { hp }
						table.insert(hit_payload, controller)
					else
						table.insert(hit_payload, hp)
					end
				end
				if type(bullet.bullet.hit_payload) == "table" then
					for i, hp_name in ipairs(bullet.bullet.hit_payload) do
						create_hit_payload(hp_name)
					end
				else
					create_hit_payload(bullet.bullet.hit_payload)
				end
				bullet.bullet.hit_payload = hit_payload
			end
			if bullet.bullet.use_unit_damage_factor and this.unit then
				bullet.bullet.damage_factor = this.unit.damage_factor
			end
			queue_insert(store, bullet)
		end
		a.ts = start_ts
		if a.xp_from_skill then
			hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
		end
		y_entity_animation_wait(this)
	end
	return true
end

local function entity_casts_object_on_target(store, this, a)
	local target, targets, pred_pos
	local prediction_time = a.node_prediction or 0
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
		target, targets, pred_pos = U.find_soldier_with_search_type(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, 
		filter_fn, a.search_type, a.crowd_range, a.min_targets)
	elseif a.vis_bans and band(a.vis_bans, F_FRIEND) ~= 0 then
		target, targets, pred_pos = U.find_enemy_with_search_type(store.entities, this.pos, a.min_range, a.max_range, a.cast_time + prediction_time, 
		a.vis_flags, a.vis_bans, filter_fn, F_FLYING, a.search_type, a.crowd_range, a.min_targets)
	else
		target, targets, pred_pos = U.find_enemy_with_search_type(store.entities, this.pos, a.min_range, a.max_range, a.cast_time + prediction_time, 
		a.vis_flags, a.vis_bans, filter_fn, F_FLYING, a.search_type, a.crowd_range, a.min_targets)
		local soldier, soldiers, soldier_pos = U.find_soldier_with_search_type(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, 
		filter_fn, a.search_type, a.crowd_range, a.min_targets)
		if targets then
			if soldiers then
				table.merge(targets, soldiers)
			end
		else
			target, targets, pred_pos = soldier, soldiers, soldier_pos
		end
	end

	if target then
		S:queue(a.sound, a.sound_args)
		local start_ts = store.tick_ts
		local an, af, ai = U.animation_name_facing_point(this, a.animation, pred_pos)
		U.animation_start(this, an, af, store.tick_ts)
		if not y_entity_wait(store, this, a.cast_time) then
			local tpi, tspi, tni
			if target.nav_path then
				tpi, tspi, tni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
			else
				local nodes
				if this.nav_path then
					tpi, tspi = this.nav_path.pi, this.nav_path.spi
					nodes = P:nearest_nodes(target.pos.x, target.pos.y, { tpi }, { tspi })
				else
					nodes = P:nearest_nodes(target.pos.x, target.pos.y)
				end
				if #nodes >= 1 then
					tpi, tspi, tni = unpack(nodes[1])
				else
					return false
				end
			end
			local e = E:create_entity(a.entity)
			local function set_entity_pos(t)
				e.pos.x, e.pos.y = t.pos.x, t.pos.y
				if a.use_center then
					if t.nav_path then
						e.pos = P:node_pos(t.nav_path.pi, 1, t.nav_path.ni)
					else
						local nodes = P:nearest_nodes(t.pos.x, t.pos.y, { tpi }, { 1 })
						if #nodes >= 1 then
							local _, _, ni = unpack(nodes[1])
							e.pos = P:node_pos(tpi, 1, ni)
						end
					end
				end
			end
			if a.use_caster_position then
				set_entity_pos(this)
			else
				set_entity_pos(target)
			end
			if e.path_index then
				e.path_index = tpi
			end
			if e.direction == 0 then
				local direction = -1
				if this.nav_path then
					if this.nav_path.ni < tni then
						direction = 1
					end
				else
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, { tpi }, { tspi })
					if #nodes >= 1 then
						local _, _, ni = unpack(nodes[1])
						if ni < tni then
							direction = 1
						end
					end
				end
				e.direction = direction
			end
			queue_insert(store, e)
			a.ts = start_ts
			if a.xp_from_skill then
				hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
			end
			y_entity_animation_wait(this)
		end
		return true
	end
	return false
end

-- true代表打断entity现有的动作
local function entity_attacks(store, this, a)
	if a.skill == "range_unit" then
		return entity_casts_range_unit(store, this, a)
	end
	if a.skill == "range_at_path" then
		return entity_casts_range_at_path(store, this, a)
	end
	if a.skill == "object_on_target" then
		return entity_casts_object_on_target(store, this, a)
	end
	if a.skill == "spawner" then
		return entity_casts_spawner(store, this, a)
	end
end

local function y_soldier_timed_attacks(store, this)
	for _, a in pairs(this.timed_attacks.list) do
		if a.spell then
			if store.tick_ts - a.ts < a.cooldown then
				-- block empty
			else
				local target = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range, false, a.vis_flags, a.vis_bans)
	
				if not target then
					return false, A_NO_TARGET
				elseif math.random() < a.chance then
					local attack_done = y_soldier_do_timed_attack(store, this, target, a)
	
					if attack_done then
						return false, A_DONE
					else
						return true
					end
				else
					a.ts = store.tick_ts
				end
			end
		else
			return entity_attacks(store, this, a)
		end
	end

	return false, A_IN_COOLDOWN
end
-- customization

local SU = {
	has_modifiers = U.has_modifiers,
	ui_click_proxy_add = ui_click_proxy_add,
	ui_click_proxy_remove = ui_click_proxy_remove,
	remove_modifiers = remove_modifiers,
	remove_modifiers_by_type = remove_modifiers_by_type,
	remove_auras = remove_auras,
	hide_modifiers = hide_modifiers,
	show_modifiers = show_modifiers,
	hide_auras = hide_auras,
	show_auras = show_auras,
	unit_dodges = unit_dodges,
	stun_inc = stun_inc,
	stun_dec = stun_dec,
	armor_inc = armor_inc,
	armor_dec = armor_dec,
	magic_armor_inc = magic_armor_inc,
	magic_armor_dec = magic_armor_dec,
	spiked_armor_inc = spiked_armor_inc,
	spiked_armor_dec = spiked_armor_dec,
	tower_block_inc = tower_block_inc,
	tower_block_dec = tower_block_dec,
	tower_update_silenced_powers = tower_update_silenced_powers,
	do_death_spawns = do_death_spawns,
	delay_attack = delay_attack,
	insert_sprite = insert_sprite,
	fade_out_entity = fade_out_entity,
	create_pop = create_pop,
	create_bullet_pop = create_bullet_pop,
	create_bullet_damage = create_bullet_damage,
	create_attack_damage = create_attack_damage,
	initial_parabola_speed = initial_parabola_speed,
	position_in_parabola = position_in_parabola,
	parabola_y = parabola_y,
	y_hero_wait = y_soldier_wait,
	y_soldier_wait = y_soldier_wait,
	y_hero_animation_wait = y_soldier_animation_wait,
	y_soldier_animation_wait = y_soldier_animation_wait,
	hero_interrupted = soldier_interrupted,
	soldier_interrupted = soldier_interrupted,
	y_hero_walk_waypoints = y_hero_walk_waypoints,
	y_hero_new_rally = y_hero_new_rally,
	hero_gain_xp_from_skill = hero_gain_xp_from_skill,
	hero_gain_xp = hero_gain_xp,
	hero_level_up = hero_level_up,
	y_hero_death_and_respawn = y_hero_death_and_respawn,
	y_hero_death_and_respawn_kr5 = y_hero_death_and_respawn_kr5,
	y_reinforcement_fade_in = y_reinforcement_fade_in,
	y_reinforcement_fade_out = y_reinforcement_fade_out,
	y_soldier_new_rally = y_soldier_new_rally,
	y_soldier_revive = y_soldier_revive,
	y_soldier_death = y_soldier_death,
	y_soldier_do_loopable_ranged_attack = y_soldier_do_loopable_ranged_attack,
	y_soldier_do_ranged_attack = y_soldier_do_ranged_attack,
	soldier_pick_ranged_target_and_attack = soldier_pick_ranged_target_and_attack,
	y_soldier_ranged_attacks = y_soldier_ranged_attacks,
	y_soldier_do_timed_action = y_soldier_do_timed_action,
	y_soldier_timed_actions = y_soldier_timed_actions,
	y_soldier_do_timed_attack = y_soldier_do_timed_attack,
	y_soldier_timed_attacks = y_soldier_timed_attacks,
	y_soldier_do_single_area_attack = y_soldier_do_single_area_attack,
	y_soldier_do_loopable_melee_attack = y_soldier_do_loopable_melee_attack,
	y_soldier_do_single_melee_attack = y_soldier_do_single_melee_attack,
	soldier_pick_melee_target = soldier_pick_melee_target,
	soldier_move_to_slot_step = soldier_move_to_slot_step,
	soldier_pick_melee_attack = soldier_pick_melee_attack,
	y_soldier_melee_block_and_attacks = y_soldier_melee_block_and_attacks,
	soldier_go_back_step = soldier_go_back_step,
	soldier_idle = soldier_idle,
	soldier_regen = soldier_regen,
	soldier_power_upgrade = soldier_power_upgrade,
	soldier_courage_upgrade = soldier_courage_upgrade,
	can_melee_blocker = can_melee_blocker,
	can_range_soldier = can_range_soldier,
	enemy_interrupted = enemy_interrupted,
	y_enemy_wait = y_enemy_wait,
	y_enemy_animation_wait = y_enemy_animation_wait,
	enemy_water_change = enemy_water_change,
	enemy_cliff_change = enemy_cliff_change,
	y_enemy_death = y_enemy_death,
	y_enemy_walk_step = y_enemy_walk_step,
	y_enemy_walk_until_blocked = y_enemy_walk_until_blocked,
	y_wait_for_blocker = y_wait_for_blocker,
	y_enemy_do_ranged_attack = y_enemy_do_ranged_attack,
	y_enemy_do_loopable_ranged_attack = y_enemy_do_loopable_ranged_attack,
	y_enemy_range_attacks = y_enemy_range_attacks,
	y_enemy_melee_attacks = y_enemy_melee_attacks,
	y_enemy_stun = y_enemy_stun,
	y_enemy_mixed_walk_melee_ranged = y_enemy_mixed_walk_melee_ranged,
	y_show_taunt_set = y_show_taunt_set,
	y_spawner_spawn = y_spawner_spawn,
	hero_will_transfer = hero_will_transfer,
	hero_will_teleport = hero_will_teleport,
	hero_will_launch_move = hero_will_launch_move,
	heroes_desperate_effort_upgrade = heroes_desperate_effort_upgrade,
	heroes_visual_learning_upgrade = heroes_visual_learning_upgrade,
	heroes_lone_wolves_upgrade = heroes_lone_wolves_upgrade,
	alliance_merciless_upgrade = alliance_merciless_upgrade,
	alliance_corageous_upgrade = alliance_corageous_upgrade,
	towers_keen_accuracy_upgrade = towers_keen_accuracy_upgrade,
	towers_swaped = towers_swaped,
	deck_new = deck_new,
	deck_draw = deck_draw,
	-- customization
	check_tower_attack_available = check_tower_attack_available,
	check_unit_attack_available = check_unit_attack_available,
	make_bullet_damage_targets = make_bullet_damage_targets,
	create_bullet_hit_payload = create_bullet_hit_payload,
	create_bullet_hit_fx = create_bullet_hit_fx,
	create_bullet_hit_decal = create_bullet_hit_decal,
	hide_shadow = hide_shadow,
	entity_interrupted = entity_interrupted,
	y_entity_wait = y_entity_wait,
	y_entity_animation_wait = y_entity_animation_wait,
	entity_casts_spawner = entity_casts_spawner,
	entity_attacks = entity_attacks,
}

return SU