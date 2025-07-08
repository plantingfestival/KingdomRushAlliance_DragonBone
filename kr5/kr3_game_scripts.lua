local log = require("klua.log"):new("game_scripts")

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
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot

require("i18n")

local scripts = require("scripts")

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

local function tpos(e)
	return e.tower and e.tower.range_offset and V.v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or e.pos
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

scripts.decal_bravebark_rootspike = {}

function scripts.decal_bravebark_rootspike.update(this, store)
	this.render.sprites[1].hidden = true
	this.render.sprites[1].flip_x = math.random() < 0.5

	U.y_wait(store, this.delay)

	local e = E:create_entity(this.hole_decal)

	e.pos.x, e.pos.y = this.pos.x, this.pos.y
	e.render.sprites[1].scale = V.vv(this.scale)

	queue_insert(store, e)

	this.render.sprites[1].hidden = false
	this.render.sprites[1].scale = V.vv(this.scale)

	U.y_animation_play(this, "in", nil, store.tick_ts)
	U.y_wait(store, this.hold_duration)

	e.tween.disabled = nil
	e.tween.ts = store.tick_ts

	U.y_animation_play(this, "out", nil, store.tick_ts)
	queue_remove(store, this)
end

scripts.decal_arachnomancer_mini_spider = {}

function scripts.decal_arachnomancer_mini_spider.update(this, store)
	local delta_y, dest_y = 0, 0
	local delta_speed = this.motion.max_speed * U.frandom(0.8, 1.2) * km.rand_sign()
	local state, last_state
	local ow = this.owner
	local oo = this.spider_offsets[this.spider_idx]
	local os = ow.render.sprites[1]

	while true do
		if ow.health.dead then
			U.y_animation_play(this, "death", nil, store.tick_ts)
			queue_remove(store, this)

			return
		end

		state = os.name

		if state ~= last_state then
			if string.starts(state, "walking") then
				U.animation_start(this, state, os.flip_x, store.tick_ts, true)
			else
				U.animation_start(this, "idle", os.flip_x, store.tick_ts, true)
			end

			last_state = state
		end

		this.render.sprites[1].hidden = os.hidden

		if string.starts(state, "walking") then
			if math.abs(delta_y) >= math.abs(dest_y) then
				delta_speed = -1 * delta_speed
				dest_y = math.random(0, this.max_delta_y)
			end

			delta_y = delta_y + delta_speed * store.tick_length
		end

		this.pos.x = ow.pos.x + oo.x
		this.pos.y = ow.pos.y + oo.y + delta_y

		coroutine.yield()
	end
end

scripts.decal_twilight_heretic_consume_ball = {}

function scripts.decal_twilight_heretic_consume_ball.update(this, store)
	local sp = this.render.sprites[1]
	local fm = this.force_motion
	local initial_pos = this.from
	local initial_h = this.from_h
	local dest_h = this.to_h
	local last_pos = V.v(0, 0)

	this.dest = this.to
	last_pos.x, last_pos.y = this.pos.x, this.pos.y + sp.offset.y
	sp.offset.y = initial_h

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local max_dist = V.len(dest.x - initial_pos.x, dest.y - initial_pos.y)
		local df = (not fm.ramp_radius or dist > fm.ramp_radius) and 1 or math.max(dist / fm.ramp_radius, 0.1)

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step * df, dx, dy)))
		fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
		fm.v.x, fm.v.y = V.trim(fm.max_v, fm.v.x, fm.v.y)

		local sx, sy = V.mul(store.tick_length, fm.v.x, fm.v.y)

		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
		fm.a.x, fm.a.y = V.mul(-0.05 / store.tick_length, fm.v.x, fm.v.y)
		sp.offset.y = SU.parabola_y(1 - dist / max_dist, initial_h, dest_h, fm.max_flight_height)
		sp.r = V.angleTo(this.pos.x - last_pos.x, this.pos.y + sp.offset.y - last_pos.y)
		last_pos.x, last_pos.y = this.pos.x, this.pos.y + sp.offset.y

		return dist < 2 * fm.max_v * store.tick_length
	end

	local ps = E:create_entity(this.particles_name)

	ps.particle_system.track_id = this.id
	ps.particle_system.track_offset = sp.offset

	queue_insert(store, ps)

	while not move_step(this.dest) do
		coroutine.yield()
	end

	this.arrived = true

	queue_remove(store, this)
end

scripts.decal_veznan_soulburn_ball = {}

function scripts.decal_veznan_soulburn_ball.update(this, store)
	local af = this.to.x > this.from.x

	this.pos.y = this.from.y + this.offset.y
	this.pos.x = this.from.x + (af and -1 or 1) * this.offset.x

	local dist = V.dist(this.pos.x, this.pos.y, this.to.x, this.to.y)
	local r = V.angleTo(this.to.x - this.pos.x, this.to.y - this.pos.y)
	local duration = dist / this.speed
	local fx = E:create_entity(this.spawn_fx)

	fx.pos.x, fx.pos.y = this.from.x, this.from.y
	fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.target.unit.size]
	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].flip_x = af

	queue_insert(store, fx)
	U.y_animation_wait(fx)

	local ps = E:create_entity(this.particles_name)

	ps.particle_system.track_id = this.id

	queue_insert(store, ps)

	this.render.sprites[1].hidden = nil
	this.render.sprites[1].r = r

	U.animation_start(this, "fly", nil, store.tick_ts, true)
	U.y_ease_keys(store, {
		this.pos,
		this.pos
	}, {
		"x",
		"y"
	}, {
		this.pos.x,
		this.pos.y
	}, {
		this.to.x,
		this.to.y
	}, duration, {
		"quad-out",
		"quad-out"
	})
	U.animation_start(this, "hit", nil, store.tick_ts, false)

	this.arrived = true

	U.y_animation_wait(this)
	queue_remove(store, this)
end

scripts.decal_eerie_root = {}

function scripts.decal_eerie_root.update(this, store)
	if this.delay then
		U.y_wait(store, this.delay)
	end

	local start_ts = store.tick_ts

	this.render.sprites[1].hidden = nil

	U.y_animation_play(this, "start", nil, store.tick_ts)

	while store.tick_ts - start_ts < this.duration do
		if U.find_first_target(store.entities, this.pos, 0, 25, this.vis_flags, this.vis_bans) then
			U.y_animation_play(this, "loop", nil, store.tick_ts, 1)
		end

		coroutine.yield()
	end

	U.y_animation_play(this, "end", nil, store.tick_ts)
	queue_remove(store, this)
end

scripts.tower_arcane = {}

function scripts.tower_arcane.get_info(this)
	local o = scripts.tower_common.get_info(this)

	o.damage_max = o.damage_max * 2
	o.damage_min = o.damage_min * 2

	return o
end

function scripts.tower_arcane.insert(this, store)
	return true
end

function scripts.tower_arcane.update(this, store)
	local shooter_sids = {
		3,
		4
	}
	local shooter_idx = 2
	local a = this.attacks
	local aa = this.attacks.list[1]
	local pow_slumber = this.powers.slumber

	local function shot_animation(attack, shooter_idx, enemy)
		local ssid = shooter_sids[shooter_idx]
		local soffset = this.render.sprites[ssid].offset
		local s = this.render.sprites[ssid]
		local an, af = U.animation_name_facing_point(this, attack.animation, enemy.pos, ssid, soffset)

		U.animation_start(this, an, af, store.tick_ts, 1, ssid)
	end

	local function shot_bullet(attack, shooter_idx, enemy, level)
		local ssid = shooter_sids[shooter_idx]
		local shooting_up = tpos(this).y < enemy.pos.y
		local shooting_right = tpos(this).x < enemy.pos.x
		local soffset = this.render.sprites[ssid].offset
		local boffset = attack.bullet_start_offset[shooting_up and 1 or 2]
		local b = E:create_entity(attack.bullet)

		b.pos.x = this.pos.x + soffset.x + boffset.x * (shooting_right and 1 or -1)
		b.pos.y = this.pos.y + soffset.y + boffset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
		b.bullet.target_id = enemy.id
		b.bullet.level = level
		b.bullet.damage_factor = this.tower.damage_factor

		local dist = V.dist(b.bullet.to.x, b.bullet.to.y, b.bullet.from.x, b.bullet.from.y)

		b.bullet.flight_time = b.bullet.flight_time_min + dist / a.range * b.bullet.flight_time_factor

		-- local u = UP:get_upgrade("archer_el_obsidian_heads")
		if enemy.health and enemy.health.magic_armor == 0 then
			b.bullet.damage_min = b.bullet.damage_max
		end

		queue_insert(store, b)
	end

	aa.ts = store.tick_ts

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			for k, pow in pairs(this.powers) do
				local sa = this.attacks.list[pow.attack_idx]

				if pow.changed then
					pow.changed = nil

					if not sa.ts and pow.level > 0 then
						sa.ts = store.tick_ts
					end
				end

				if pow.level < 1 or store.tick_ts - sa.ts < sa.cooldown + pow.level * sa.cooldown_inc or not this.tower.can_do_magic then
					-- block empty
				else
					local enemy
					if pow == pow_slumber then
						enemy = U.find_strongest_enemy_in_range(store.entities, tpos(this), 0, a.range, false, sa.vis_flags, sa.vis_bans, function(e)
							return not U.has_modifiers(store, e, "mod_arrow_arcane_slumber")
						end)
					else
						enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, sa.vis_flags, sa.vis_bans)
					end

					if not enemy then
						-- block empty
					else
						sa.ts = store.tick_ts
						shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

						shot_animation(sa, shooter_idx, enemy)

						while store.tick_ts - sa.ts < sa.shoot_time do
							coroutine.yield()
						end

						if V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <= a.range * 1.1 then
							shot_bullet(sa, shooter_idx, enemy, pow.level)
						end

						U.y_animation_wait(this, shooter_sids[shooter_idx])
					end
				end
			end

			if store.tick_ts - aa.ts > aa.cooldown then
				local enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)

				if not enemy then
					-- block empty
				else
					aa.ts = store.tick_ts

					for i = 1, #shooter_sids do
						shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)
						enemy = enemies[km.zmod(shooter_idx, #enemies)]

						shot_animation(aa, shooter_idx, enemy)

						if i == 1 then
							U.y_wait(store, aa.shooters_delay)
						end
					end

					while store.tick_ts - aa.ts < aa.shoot_time do
						coroutine.yield()
					end

					for i = 1, #shooter_sids do
						shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)
						enemy = enemies[km.zmod(shooter_idx, #enemies)]

						if V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <= a.range then
							shot_bullet(aa, shooter_idx, enemy, 0)
						end

						if i == 1 then
							U.y_wait(store, aa.shooters_delay)
						end
					end

					U.y_animation_wait(this, shooter_sids[shooter_idx])
				end
			end

			if store.tick_ts - aa.ts > this.tower.long_idle_cooldown then
				for _, sid in pairs(shooter_sids) do
					local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, sid)

					U.animation_start(this, an, af, store.tick_ts, -1, sid)
				end
			end

			coroutine.yield()
		end
	end
end

scripts.tower_silver = {}

function scripts.tower_silver.get_info(this)
	local o = scripts.tower_common.get_info(this)

	o.cooldown = 1.5

	return o
end

function scripts.tower_silver.update(this, store)
	local a = this.attacks
	local aa = this.attacks.list[1]
	local as = this.attacks.list[2]
	local am = this.attacks.list[3]
	local pow_s = this.powers.sentence
	local pow_m = this.powers.mark
	local sid = 3

	local function is_long(enemy)
		return V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) > a.short_range
	end

	local function y_do_shot(attack, enemy, level)
		S:queue(attack.sound, attack.sound_args)

		local lidx = is_long(enemy) and 2 or 1
		local soffset = this.render.sprites[sid].offset
		local an, af, ai = U.animation_name_facing_point(this, attack.animations[lidx], enemy.pos, sid, soffset)

		U.animation_start(this, an, af, store.tick_ts, false, sid)

		local shoot_time = attack.shoot_times[lidx]

		U.y_wait(store, shoot_time)

		if V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <= a.range then
			local boffset = attack.bullet_start_offsets[lidx][ai]
			local b = E:create_entity(attack.bullets[lidx])

			b.pos.x = this.pos.x + soffset.x + boffset.x * (af and -1 or 1)
			b.pos.y = this.pos.y + soffset.y + boffset.y
			b.bullet.from = V.vclone(b.pos)
			b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
			b.bullet.target_id = enemy.id
			b.bullet.level = level or 0
			b.bullet.damage_factor = this.tower.damage_factor

			if attack == am and level > 0 then
				if lidx == 1 then
					b.bullet.damage_min = pow_m.damage[level]
					b.bullet.damage_max = pow_m.damage[level]
				else
					b.bullet.damage_min = pow_m.damage_long[level]
					b.bullet.damage_max = pow_m.damage_long[level]
				end
			end

			local dist = V.dist(b.bullet.to.x, b.bullet.to.y, b.bullet.from.x, b.bullet.from.y)

			b.bullet.flight_time = b.bullet.flight_time_min + dist * b.bullet.flight_time_factor

			if attack.critical_chances and math.random() < attack.critical_chances[lidx] then
				b.bullet.damage_factor = 2 * b.bullet.damage_factor
				b.bullet.pop = {
					"pop_crit"
				}
				b.bullet.pop_conds = DR_DAMAGE
				b.bullet.damage_type = DAMAGE_TRUE
			end

			if attack.use_obsidian_upgrade then
				-- local u = UP:get_upgrade("archer_el_obsidian_heads")
				if enemy.health and enemy.health.armor == 0 then
					b.bullet.damage_min = b.bullet.damage_max
				end
			end

			queue_insert(store, b)

			if attack.shot_fx then
				local fx = E:create_entity(attack.shot_fx)

				fx.pos.x, fx.pos.y = b.bullet.from.x, b.bullet.from.y

				local bb = b.bullet

				fx.render.sprites[1].r = V.angleTo(bb.to.x - bb.from.x, bb.to.y - bb.from.y)
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)
			end
		end

		U.y_animation_wait(this, sid)

		an, af = U.animation_name_facing_point(this, "idle", enemy.pos, sid, soffset)

		U.animation_start(this, an, af, store.tick_ts, true, sid)
	end

	local function reset_cooldowns(long)
		aa.ts = store.tick_ts
		as.ts = store.tick_ts
		aa.cooldown = long and aa.cooldowns[2] or aa.cooldowns[1]
		as.cooldown = long and as.cooldowns[2] or as.cooldowns[1]
	end

	aa.ts = store.tick_ts

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					local pa = this.attacks.list[pow.attack_idx]
					if not pa.ts and pow.level > 0 then
						pa.ts = store.tick_ts
					end
				end
			end

			if pow_m.level > 0 and store.tick_ts - am.ts > am.cooldown and this.tower.can_do_magic then
				local enemy = U.find_strongest_enemy_in_range(store.entities, tpos(this), 0, a.range, false, am.vis_flags, am.vis_bans, function(e)
					return not U.has_modifiers(store, e, "mod_arrow_silver_mark")
				end)

				if enemy then
					am.ts = store.tick_ts

					reset_cooldowns(is_long(enemy))
					y_do_shot(am, enemy, pow_m.level)
				end
			end

			if pow_s.level > 0 and store.tick_ts - as.ts > as.cooldown and this.tower.can_do_magic then
				local enemy = U.find_strongest_enemy_in_range(store.entities, tpos(this), 0, a.range, false, as.vis_flags, as.vis_bans)

				if enemy then
					local long = is_long(enemy)
					local lidx = long and 2 or 1
					local chance = pow_s.chances[lidx][pow_s.level]

					as.ts = store.tick_ts

					if chance > math.random() then
						reset_cooldowns(long)
						y_do_shot(as, enemy, pow_s.level)
					end
				end
			end

			if store.tick_ts - aa.ts > aa.cooldown then
				local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)

				if enemy then
					reset_cooldowns(is_long(enemy))
					y_do_shot(aa, enemy)
				end
			end

			if store.tick_ts - aa.ts > this.tower.long_idle_cooldown then
				local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, sid)

				U.animation_start(this, an, af, store.tick_ts, true, sid)
			end

			coroutine.yield()
		end
	end
end

scripts.tower_wild_magus = {}

function scripts.tower_wild_magus.update(this, store)
	local shooter_sid = this.render.sid_shooter
	local rune_sid = this.render.sid_rune
	local a = this.attacks
	local ba = this.attacks.list[1]
	local ea = this.attacks.list[2]
	local wa = this.attacks.list[3]
	local aidx = 2
	local last_enemy_shots = 0
	local pow_e, pow_w = this.powers.eldritch, this.powers.ward

	ba.ts = store.tick_ts

	while true do
		local skip
		local function tower_walk_waypoints(store, this, animation)
			local animation = animation or "walk"
			local r = this.nav_rally
			local n = this.nav_grid
			local dest = r.pos
		
			while not V.veq(this.pos, dest) do
				local w = table.remove(n.waypoints, 1) or dest
				local unsnap = #n.waypoints > 0
		
				U.set_destination(this, w)
		
				local an = U.animation_name_facing_point(this, animation, this.motion.dest, shooter_sid)
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

		if not skip then
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if pow.level == 1 then
						local pa = this.attacks.list[pow.attack_idx]

						pa.ts = store.tick_ts
					end

					if pow.cooldowns then
						a.list[pow.attack_idx].cooldown = pow.cooldowns[pow.level]
					end
				end
			end

			SU.tower_update_silenced_powers(store, this)

			if pow_e.level > 0 and not ea.silence_ts and store.tick_ts - ea.ts > ea.cooldown then
				local enemy = U.find_strongest_enemy_in_range(store.entities, tpos(this), 0, a.range, false, ea.vis_flags, ea.vis_bans)

				if not enemy then
					-- block empty
				else
					ea.ts = store.tick_ts

					local so = this.render.sprites[shooter_sid].offset
					local an, af, ai = U.animation_name_facing_point(this, ea.animation, enemy.pos, shooter_sid, so)

					U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
					S:queue(ea.sound)
					U.y_wait(store, ea.shoot_time)

					if enemy.health.dead or not U.flags_pass(enemy.vis, ea) or not U.is_inside_ellipse(tpos(this), enemy.pos, a.range * 1.1) then
						enemy = U.find_strongest_enemy_in_range(store.entities, tpos(this), 0, a.range, false, ea.vis_flags, ea.vis_bans)
					end

					if enemy then
						local bo = ea.bullet_start_offset[ai]
						local b = E:create_entity(ea.bullet)

						b.pos.x = this.pos.x + so.x + bo.x * (af and -1 or 1)
						b.pos.y = this.pos.y + so.y + bo.y
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
						b.bullet.target_id = enemy.id
						b.bullet.level = pow_e.level
						b.bullet.damage_factor = this.tower.damage_factor

						queue_insert(store, b)
					end

					U.y_animation_wait(this, shooter_sid)
				end
			end

			if pow_w.level > 0 and not wa.silence_ts and store.tick_ts - wa.ts > wa.cooldown then
				local enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, wa.range, false, wa.vis_flags, wa.vis_bans, function(e)
					return band(e.vis.flags, F_SPELLCASTER) ~= 0 and e.enemy.can_do_magic
				end)

				if enemy then
					wa.ts = store.tick_ts

					local so = this.render.sprites[shooter_sid].offset
					local an, af, ai = U.animation_name_facing_point(this, wa.animation, enemy.pos, shooter_sid, so)

					U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
					S:queue(wa.sound)

					this.render.sprites[5].ts, this.render.sprites[5].hidden = store.tick_ts, false
					this.render.sprites[6].ts, this.render.sprites[6].hidden = store.tick_ts, false
					this.tween.props[6].ts = store.tick_ts
					this.tween.props[7].ts = store.tick_ts
					this.render.sprites[rune_sid].ts, this.render.sprites[rune_sid].hidden = store.tick_ts

					U.y_wait(store, wa.cast_time)

					if #enemies < pow_w.target_count[pow_w.level] then
						local d = pow_w.target_count[pow_w.level] - #enemies
						local _, spareEnemies = U.find_foremost_enemy(store.entities, tpos(this), 0, wa.range, false, wa.vis_flags, wa.vis_bans, function(e)
							return not table.contains(enemies, e)
						end)
						if spareEnemies then
							for i = 1, math.min(#spareEnemies, d) do
								table.insert(enemies, spareEnemies[i])
							end
						end
					end
					for i = 1, math.min(#enemies, pow_w.target_count[pow_w.level]) do
						local target = enemies[i]
						for j, mod_name in ipairs(wa.spell) do
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id = this.id
							mod.modifier.target_id = target.id
							mod.modifier.level = pow_w.level
							queue_insert(store, mod)
						end
					end

					wa.ts = store.tick_ts

					U.y_animation_wait(this, rune_sid)

					this.render.sprites[rune_sid].hidden = true

					U.y_animation_wait(this, shooter_sid)
				end
			end

			if store.tick_ts - ba.ts > ba.cooldown then
				local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, ba.vis_flags, ba.vis_bans)

				if enemy then
					ba.ts = store.tick_ts
					aidx = km.zmod(aidx + 1, 2)

					local so = this.render.sprites[shooter_sid].offset
					local fo = V.v(so.x, so.y + 22 + 8)
					local an, af, ai = U.animation_name_facing_point(this, ba.animations[aidx], enemy.pos, shooter_sid, fo)

					U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
					U.y_wait(store, ba.shoot_time)

					if U.is_inside_ellipse(tpos(this), enemy.pos, a.range * 1.1) then
						local bo = ba.bullet_start_offset[aidx][ai]
						local b = E:create_entity(ba.bullet)

						b.pos.x = this.pos.x + so.x + bo.x * (af and -1 or 1)
						b.pos.y = this.pos.y + so.y + bo.y
						b.tween.ts = store.tick_ts
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
						b.bullet.target_id = enemy.id
						b.bullet.damage_factor = this.tower.damage_factor

						if store.tick_ts - ba.ts <= ba.max_interval then
							last_enemy_shots = last_enemy_shots + 1

							local dmg_inc = km.clamp(0, b.bullet.damage_same_target_max, last_enemy_shots * b.bullet.damage_same_target_inc)

							b.bullet.damage_max = math.floor(b.bullet.damage_max + dmg_inc)
							b.bullet.damage_min = math.floor(b.bullet.damage_min + dmg_inc)
						else
							last_enemy_shots = 0
						end

						if math.random() < b.alter_reality_chance then
							b.bullet.mod = b.alter_reality_mod
						end

						queue_insert(store, b)
					end

					U.y_animation_wait(this, shooter_sid)

					an, af = U.animation_name_facing_point(this, "idle", enemy.pos, shooter_sid, so)

					U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
				end
			end

			if store.tick_ts - ba.ts > this.tower.long_idle_cooldown then
				local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

				U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
			end
		end

		coroutine.yield()
	end
end

scripts.tower_high_elven = {}

function scripts.tower_high_elven.get_info(this)
	local o = scripts.tower_common.get_info(this)

	o.type = STATS_TYPE_TOWER_MAGE

	local min, max = 0, 0

	if this.attacks and this.attacks.list[1].bullets then
		for _, bn in pairs(this.attacks.list[1].bullets) do
			local b = E:get_template(bn)

			min, max = min + b.bullet.damage_min, max + b.bullet.damage_max
		end
	end

	min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)
	o.damage_max = max
	o.damage_min = min

	return o
end

function scripts.tower_high_elven.remove(this, store)
	if this.sentinels then
		for _, s in pairs(this.sentinels) do
			s.owner = nil

			queue_remove(store, s)
		end
	end

	return true
end

function scripts.tower_high_elven.update(this, store)
	local shooter_sid = 3
	local a = this.attacks
	local ba = this.attacks.list[1]
	local ta = this.attacks.list[2]
	local sa = this.attacks.list[3]
	local pow_t, pow_s = this.powers.timelapse, this.powers.sentinel

	this.sentinels = {}
	ba.ts = store.tick_ts

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			if pow_t.changed then
				pow_t.changed = nil
				if not ta.ts and pow_t.level > 0 then
					ta.ts = store.tick_ts
				end
			end

			if pow_s.changed then
				pow_s.changed = nil
			end

			SU.tower_update_silenced_powers(store, this)

			if pow_s.level > 0 and not sa.silence_ts then
				for i = 1, pow_s.level - #this.sentinels do
					local s = E:create_entity("high_elven_sentinel")

					s.pos = V.vclone(this.pos)

					queue_insert(store, s)
					table.insert(this.sentinels, s)

					s.owner = this
					s.owner_idx = #this.sentinels
				end
			end

			if pow_t.level > 0 and not ta.silence_ts and store.tick_ts - ta.ts > ta.cooldown then
				local enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, ta.vis_flags, ta.vis_bans)

				if enemy and #enemies > pow_t.target_count[pow_t.level] + 1 then
					ta.ts = store.tick_ts

					local an, af = U.animation_name_facing_point(this, ta.animation, enemy.pos, shooter_sid)

					U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)

					this.tween.props[1].ts = store.tick_ts

					S:queue(ta.sound)
					U.y_wait(store, ta.cast_time)

					for i = 1, math.min(#enemies, pow_t.target_count[pow_t.level]) do
						local target = enemies[i]
						local mod = E:create_entity(ta.spell)

						mod.modifier.target_id = target.id
						mod.modifier.level = pow_t.level
						mod.modifier.duration = pow_t.duration[pow_t.level]
						mod.ranged.attacks[1].disabled = pow_s.level == 0

						queue_insert(store, mod)
					end

					U.y_animation_wait(this, shooter_sid)
				end
			end

			if store.tick_ts - ba.ts > ba.cooldown then
				local enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, ba.vis_flags, ba.vis_bans)

				if enemy then
					ba.ts = store.tick_ts

					local bo = ba.bullet_start_offset
					local an, af = U.animation_name_facing_point(this, ba.animation, enemy.pos, shooter_sid, bo)

					U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)

					this.tween.props[1].ts = store.tick_ts

					U.y_wait(store, ba.shoot_time)

					enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, ba.vis_flags, ba.vis_bans)

					if enemy then
						local eidx = 1

						for i, bn in ipairs(ba.bullets) do
							enemy = enemies[km.zmod(eidx, #enemies)]
							eidx = eidx + 1

							if V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <= a.range * 1.1 then
								local b = E:create_entity(bn)

								b.bullet.shot_index = i
								b.bullet.damage_factor = this.tower.damage_factor
								b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
								b.bullet.target_id = enemy.id
								b.bullet.from = V.v(this.pos.x + bo.x, this.pos.y + bo.y)
								b.pos = V.vclone(b.bullet.from)

								queue_insert(store, b)
							end

							if i == 1 then
								table.sort(enemies, function(e1, e2)
									return e1.health.hp < e2.health.hp
								end)

								eidx = 1
							end
						end
					end

					U.y_animation_wait(this, shooter_sid)
				end
			end

			if store.tick_ts - ba.ts > this.tower.long_idle_cooldown then
				local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

				U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
			end

			coroutine.yield()
		end
	end
end

scripts.high_elven_sentinel = {}

function scripts.high_elven_sentinel.update(this, store)
	local sb_sid, ss_sid = 1, 2
	local sb = this.render.sprites[sb_sid]
	local ss = this.render.sprites[ss_sid]
	local ra = this.ranged.attacks[1]
	local fm = this.force_motion

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local ramp_radius = fm.ramp_radius
		local df = (not ramp_radius or ramp_radius < dist) and 1 or math.max(dist / ramp_radius, 0.1)

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step * df, dx, dy)))
		fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
		fm.v.x, fm.v.y = V.trim(fm.max_v, fm.v.x, fm.v.y)
		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = V.mul(-1 * fm.fr / store.tick_length, fm.v.x, fm.v.y)
	end

	local function find_target(range)
		if this.owner.tower.blocked then
			return nil
		end

		local target, targets = U.find_foremost_enemy(store.entities, this.pos, 0, range, false, ra.vis_flags, ra.vis_bans)

		if target and #this.owner.sentinels > 1 then
			local other_target_id = this.owner.sentinels[this.owner_idx == 1 and 2 or 1].chasing_target_id

			if target.id == other_target_id and #targets > 1 then
				target = targets[2]
			end
		end

		return target
	end

	local charge_ts, wait_ts, shoot_ts, search_ts, shots = 0, 0, 0, 0, 0
	local target, targets, dist
	local dest = V.v(0, 0)
	local ps = E:create_entity(this.particles_name)

	ps.particle_system.track_id = this.id
	ps.particle_system.track_offset = V.v(0, this.flight_height)

	queue_insert(store, ps)

	while true do
		U.animation_start(this, "small", nil, store.tick_ts, true, sb_sid)

		ss.hidden = true
		sb.z = Z_OBJECTS
		sb.sort_y = this.owner.pos.y
		ps.particle_system.emit = true
		ps.particle_system.sort_y = this.owner.pos.y
		this.tween.reverse = false
		this.tween.ts = store.tick_ts
		shots = 0
		charge_ts = store.tick_ts

		while true do
			local p = V.v(this.tower_rotation_radius, 0)

			p.x, p.y = V.rotate(store.tick_ts * this.tower_rotation_speed + (this.owner_idx - 1) * math.pi, p.x, p.y)
			p.y = 0.5 * p.y
			this.pos.x = this.owner.pos.x + this.tower_rotation_offset.x + p.x
			this.pos.y = this.owner.pos.y + this.tower_rotation_offset.y + p.y

			if store.tick_ts - charge_ts > this.charge_time then
				if sb.name == "small" then
					U.animation_start(this, "big", nil, store.tick_ts, true, sb_sid)
				end

				target = find_target(ra.launch_range)

				if target then
					S:queue("TowerHighMageSentinelActivate")

					break
				end
			end

			coroutine.yield()
		end

		::label_29_0::

		sb.z = Z_BULLETS
		sb.sort_y_offset = 0
		ss.hidden = false
		ps.particle_system.emit = false
		this.chasing_target_id = target.id
		dest.x, dest.y = target.pos.x, target.pos.y

		repeat
			dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)

			move_step(dest)
			coroutine.yield()
		until dist < ra.shoot_range or target.health.dead or band(ra.vis_flags, target.vis.bans) ~= 0

		if shots < ra.max_shots and store.entities[target.id] and not target.health.dead and band(ra.vis_flags, target.vis.bans) == 0 then
			if store.tick_ts - shoot_ts > ra.cooldown then
				shoot_ts = store.tick_ts
				shots = shots + 1

				U.animation_start(this, "shoot", nil, store.tick_ts, false, sb_sid)
				U.y_wait(store, ra.shoot_time)

				local b = E:create_entity(ra.bullet)

				b.pos.x, b.pos.y = this.pos.x + sb.offset.x, this.pos.y + sb.offset.y
				b.bullet.from = V.vclone(b.pos)
				b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id

				queue_insert(store, b)
				U.y_animation_wait(this, sb_sid)
				U.animation_start(this, "big", nil, store.tick_ts, true, sb_sid)
			end

			goto label_29_0
		end

		wait_ts = store.tick_ts
		this.chasing_target_id = nil

		U.animation_start(this, "big", nil, store.tick_ts, true, sb_sid)

		local wait_time = shots < ra.max_shots and this.wait_time or this.wait_spent_time

		::label_29_1::

		search_ts = store.tick_ts

		if shots < ra.max_shots then
			target = find_target(ra.max_range)

			if target then
				goto label_29_0
			end
		end

		while store.tick_ts - search_ts < ra.search_cooldown do
			move_step(dest)
			coroutine.yield()
		end

		if wait_time > store.tick_ts - wait_ts then
			goto label_29_1
		end

		this.tween.ts = store.tick_ts
		this.tween.reverse = true

		U.y_wait(store, this.tween.props[1].keys[2][1])
	end
end

scripts.tower_rock_thrower = {}

function scripts.tower_rock_thrower.update(this, store)
	local a = this.attacks
	local ba = this.attacks.list[1]
	local last_target_pos = V.v(0, 0)
	local shooter_sid = 4
	local rocks_loading_sid = 3
	local rocks_loading_s = this.render.sprites[rocks_loading_sid]
	local start_offset = ba.bullet_start_offset
	local an, af, enemy, _, pred_pos
	local loaded = false

	rocks_loading_s.hidden = true
	ba.ts = store.tick_ts

	local function filter_faerie(e)
		local ppos = P:predict_enemy_pos(e, ba.node_prediction)

		return not GR:cell_is(ppos.x, ppos.y, TERRAIN_FAERIE)
	end

	while true do
		if this.tower.blocked then
			-- block empty
		else
			if not loaded then
				loaded = true
				an, af = U.animation_name_facing_point(this, "load", last_target_pos, shooter_sid, start_offset)

				U.animation_start_group(this, an, af, store.tick_ts, false, "shooters")
				U.y_wait(store, fts(8))

				if an == "loadDown" and not af or an == "loadUp" and af then
					rocks_loading_s.offset.x, rocks_loading_s.offset.y = rocks_loading_s.offsets[2].x, rocks_loading_s.offsets[2].y
				else
					rocks_loading_s.offset.x, rocks_loading_s.offset.y = rocks_loading_s.offsets[1].x, rocks_loading_s.offsets[1].y
				end

				rocks_loading_s.hidden = nil

				U.animation_start(this, "play", nil, store.tick_ts, false, rocks_loading_sid)
				S:queue("TowerStoneDruidBoulderSummon")
				U.y_animation_wait(this, shooter_sid)
			end

			if store.tick_ts - ba.ts < ba.cooldown then
				coroutine.yield()
			else
				enemy, _, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, ba.node_prediction, ba.vis_flags, ba.vis_bans, filter_faerie)

				if enemy then
					loaded = false
					ba.ts = store.tick_ts
					last_target_pos.x, last_target_pos.y = pred_pos.x, pred_pos.y

					local an, af = U.animation_name_facing_point(this, "shoot", pred_pos, shooter_sid, start_offset)

					U.animation_start_group(this, an, af, store.tick_ts, false, "shooters")
					U.y_wait(store, ba.shoot_time)

					local trigger_pos = pred_pos

					enemy, _, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, ba.node_prediction, ba.vis_flags, ba.vis_bans, filter_faerie)

					local b = E:create_entity(ba.bullet)

					b.bullet.damage_factor = this.tower.damage_factor
					b.pos.x, b.pos.y = this.pos.x + ba.bullet_start_offset.x, this.pos.y + ba.bullet_start_offset.y
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = enemy and pred_pos or trigger_pos
					b.bullet.source_id = this.id

					queue_insert(store, b)
					U.y_animation_wait(this, shooter_sid)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.tower_druid = {}

function scripts.tower_druid.remove(this, store)
	if this.loaded_bullets then
		for _, b in pairs(this.loaded_bullets) do
			queue_remove(store, b)
		end
	end

	if this.shooters then
		for _, s in pairs(this.shooters) do
			queue_remove(store, s)
		end
	end

	for _, s in pairs(this.barrack.soldiers) do
		if s.health then
			s.health.dead = true
		end

		queue_remove(store, s)
	end

	return true
end

function scripts.tower_druid.update(this, store)
	local shooter_sid = 3
	local a = this.attacks
	local ba = this.attacks.list[1]
	local sa = this.attacks.list[2]
	local pow_n = this.powers.nature
	local pow_s = this.powers.sylvan
	local target, _, pred_pos

	this.loaded_bullets = {}
	this.shooters = {}
	ba.ts = store.tick_ts

	local function load_bullet()
		local look_pos = target and target.pos or this.tower.long_idle_pos
		local an, af = U.animation_name_facing_point(this, "load", look_pos, shooter_sid)

		U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
		U.y_wait(store, fts(16))

		local idx = #this.loaded_bullets + 1
		local b = E:create_entity(ba.bullet)
		local bo = ba.storage_offsets[idx]

		b.pos = V.v(this.pos.x + bo.x, this.pos.y + bo.y)
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.vclone(b.pos)
		b.bullet.source_id = this.id
		b.bullet.target_id = nil
		b.bullet.damage_factor = this.tower.damage_factor
		b.render.sprites[1].prefix = string.format(b.render.sprites[1].prefix, idx)

		queue_insert(store, b)
		table.insert(this.loaded_bullets, b)
		U.y_animation_wait(this, shooter_sid)
	end

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if not table.contains(table.map(this.shooters, function(k, v)
						return v.template_name
					end), pow.entity) then
						local s = E:create_entity(pow.entity)

						s.pos = V.vclone(this.pos)
						s.owner = this

						queue_insert(store, s)
						table.insert(this.shooters, s)
					end

					if k == "nature" then
						this.barrack.max_soldiers = pow.level
					end

					if k == "sylvan" then
						for i, s in ipairs(this.barrack.soldiers) do
							s.melee.attacks[1].level = pow.level
							s.melee.attacks[1].mod = s.melee.attacks[1].mod_prefix
						end
						for _, shooter in ipairs(this.shooters) do
							if shooter.template_name == pow.entity then
								shooter.attacks.list[1].cooldown = pow.cooldown[pow.level]
								break
							end
						end 
						
					end
				end
			end

			if store.tick_ts - ba.ts > ba.cooldown then
				local function filter_faerie(e)
					local ppos = P:predict_enemy_pos(e, ba.node_prediction)

					return not GR:cell_is(ppos.x, ppos.y, TERRAIN_FAERIE)
				end

				target, _, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, ba.node_prediction, ba.vis_flags, ba.vis_bans, filter_faerie)

				if target then
					ba.ts = store.tick_ts

					if #this.loaded_bullets == 0 then
						load_bullet()
					end

					S:queue(ba.sound)

					local an, af = U.animation_name_facing_point(this, ba.animation, pred_pos, shooter_sid)

					U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
					U.y_wait(store, ba.shoot_time)

					local trigger_target, trigger_pos = target, pred_pos

					target, _, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, ba.node_prediction, ba.vis_flags, ba.vis_bans, filter_faerie)

					if not target then
						target = trigger_target
						pred_pos = P:predict_enemy_pos(target, ba.node_prediction)
					end

					local adv = P:predict_enemy_node_advance(target, ba.node_prediction)

					if U.is_inside_ellipse(tpos(this), pred_pos, a.range * 1.05) then
						for i, b in ipairs(this.loaded_bullets) do
							b.bullet.target_id = target.id

							if i > 1 then
								local ni_pred = target.nav_path.ni + adv

								if P:is_node_valid(target.nav_path.pi, ni_pred - (i - 2) * 5) then
									ni_pred = ni_pred - (i - 2) * 5
								end

								pred_pos = P:node_pos(target.nav_path.pi, 1, ni_pred)
							end

							b.bullet.to = V.v(pred_pos.x, pred_pos.y)
						end

						this.loaded_bullets = {}
					end

					U.y_animation_wait(this, shooter_sid)
				elseif #this.loaded_bullets < ba.max_loaded_bullets then
					load_bullet()
				end
			end

			if store.tick_ts - ba.ts > this.tower.long_idle_cooldown then
				local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

				U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
			end

			coroutine.yield()
		end
	end
end

scripts.druid_shooter_sylvan = {}

function scripts.druid_shooter_sylvan.update(this, store)
	local a = this.attacks.list[1]

	a.ts = store.tick_ts

	while true do
		if this.owner.tower.blocked or not this.owner.tower.can_do_magic then
			-- block empty
		elseif store.tick_ts - a.ts > a.cooldown then
			SU.delay_attack(store, a, 1)

			local targets = U.find_enemies_in_range(store.entities, this.owner.pos, 0, a.range, a.vis_flags, a.vis_bans, function(v)
				return not table.contains(a.excluded_templates, v.template_name) and not SU.has_modifiers(store, v, "mod_druid_sylvan")
			end)

			local amount = 0
			local crowdsTarget
			if targets then
				for _, e in ipairs(targets) do
					local crowds = U.find_enemies_in_range(store.entities, e.pos, 0, a.crowds_range, a.vis_flags, a.vis_bans)
					if crowds and #crowds >= a.min_targets and #crowds > amount then
						amount = #crowds
						crowdsTarget = crowds
					end
				end
			end

			local max_health = -1
			local enemy
			if crowdsTarget then
				for _, e in ipairs(crowdsTarget) do
					if max_health < e.health.hp then
						max_health = e.health.hp
						enemy = e
					end
				end
			end

			if enemy then
				S:queue(a.sound)
				U.animation_start(this, a.animation, nil, store.tick_ts)
				U.y_wait(store, a.cast_time)

				a.ts = store.tick_ts

				local mod = E:create_entity(a.spell)

				mod.modifier.target_id = enemy.id
				mod.modifier.level = this.owner.powers.sylvan.level

				queue_insert(store, mod)
			end
		end

		coroutine.yield()
	end
end

scripts.druid_shooter_nature = {}

function scripts.druid_shooter_nature.update(this, store)
	local b = this.owner.barrack
	local a = this.attacks.list[1]
	local formation_offset = U.frandom(math.pi / 4, 2 * math.pi / 5)

	a.ts = store.tick_ts

	while true do
		if this.owner.tower.blocked or not this.owner.tower.can_do_magic then
			-- block empty
		else
			for i = 1, b.max_soldiers do
				local s = b.soldiers[i]

				if not s or s.health.dead and not store.entities[s.id] then
					U.animation_start(this, a.animation, nil, store.tick_ts)
					U.y_wait(store, a.spawn_time)

					s = E:create_entity(b.soldier_type)
					s.soldier.tower_id = this.owner.id
					s.soldier.tower_soldier_idx = i
					s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, formation_offset)
					s.pos = V.vclone(s.nav_rally.pos)
					s.nav_rally.new = nil

					if this.owner.powers.sylvan.level > 0 then
						s.melee.attacks[1].level = this.owner.powers.sylvan.level
						s.melee.attacks[1].mod = s.melee.attacks[1].mod_prefix
					end

					queue_insert(store, s)

					b.soldiers[i] = s

					signal.emit("tower-spawn", this.owner, s)

				end
			end

			if b.rally_new then
				b.rally_new = false

				signal.emit("rally-point-changed", this)

				local all_dead = true

				for i, s in pairs(b.soldiers) do
					local s = b.soldiers[i]

					s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, formation_offset)
					s.nav_rally.new = true
					all_dead = all_dead and s.health.dead
				end

				if not all_dead then
					S:queue(this.owner.sound_events.change_rally_point)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.tower_entwood = {}

function scripts.tower_entwood.insert(this, store)
	local points = {}
	local inner_fx_radius = 100
	local outer_fx_radius = 115

	for i = 1, 12 do
		local r = outer_fx_radius

		if i % 2 == 0 then
			r = inner_fx_radius
		end

		local p = {}

		p.pos = U.point_on_ellipse(this.pos, r, 2 * math.pi * i / 12)
		p.terrain = GR:cell_type(p.pos.x, p.pos.y)

		if P:valid_node_nearby(p.pos.x, p.pos.y, 1) then
			table.insert(points, p)
		end
	end

	this.fx_points = points

	if this.barrack and not this.barrack.rally_pos and this.tower.default_rally_pos then
		this.barrack.rally_pos = V.vclone(this.tower.default_rally_pos)
	end

	return true
end

function scripts.tower_entwood.update(this, store)
	local a = this.attacks
	local aa = this.attacks.list[1]
	local fa = this.attacks.list[2]
	local ca = this.attacks.list[3]
	local pow_c = this.powers.clobber
	local pow_f = this.powers.fiery_nuts
	local pow_forest_keepers = this.powers.forest_keepers
	local blink_ts = store.tick_ts
	local blink_cooldown = 4
	local blink_sid = 11
	local loaded

	local function filter_faerie(e)
		local ppos = P:predict_enemy_pos(e, true)

		return not GR:cell_is(ppos.x, ppos.y, TERRAIN_FAERIE)
	end

	local function do_attack(at)
		SU.delay_attack(store, at, 0.25)

		local target, _, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, at.node_prediction, at.vis_flags, at.vis_bans, filter_faerie)

		if target then
			at.ts = store.tick_ts
			blink_ts = store.tick_ts
			loaded = nil

			U.animation_start_group(this, at.animation, nil, store.tick_ts, false, "layers")
			U.y_wait(store, at.shoot_time)

			local nt, _, nt_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, at.node_prediction, at.vis_flags, at.vis_bans, filter_faerie)

			if nt then
				target = nt
				pred_pos = nt_pos
			end

			local bo = at.bullet_start_offset
			local b = E:create_entity(at.bullet)

			b.pos = V.v(this.pos.x + bo.x, this.pos.y + bo.y)
			b.bullet.level = pow_f.level
			b.bullet.from = V.vclone(b.pos)
			b.bullet.to = V.vclone(pred_pos)
			b.bullet.source_id = this.id
			b.bullet.damage_factor = this.tower.damage_factor

			if b.bullet.hit_peyload then
				local pl = E:create_entity(b.bullet.hit_payload)

				pl.aura.level = pow_f.level
				b.bullet.hit_payload = pl
			end

			queue_insert(store, b)
			U.y_animation_wait_group(this, "layers")

			return true
		end

		return false
	end

	SU.towers_swaped(store, this, this.attacks.list)
	aa.ts = store.tick_ts
	this.render.sprites[blink_sid].hidden = true

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			local upgradeForestKeepers
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if pow == pow_forest_keepers then
						upgradeForestKeepers = true
						goto label_43_1
					elseif pow.level == 1 then
						local pa = this.attacks.list[pow.attack_idx]

						pa.ts = store.tick_ts
					end
				end
			end

			SU.tower_update_silenced_powers(store, this)

			if not loaded then
				if pow_c.level > 0 and not ca.silence_ts and store.tick_ts - ca.ts > ca.cooldown and this.tower.can_do_magic then
					loaded = "clobber"
				elseif pow_f.level > 0 and not fa.silence_ts and store.tick_ts - fa.ts > fa.cooldown - a.load_time and this.tower.can_do_magic then
					S:queue("TowerEntwoodLeaves")
					U.y_animation_play_group(this, "special1_charge", nil, store.tick_ts, 1, "layers")

					loaded = "fiery_nuts"
				elseif store.tick_ts - aa.ts > aa.cooldown - a.load_time then
					S:queue("TowerEntwoodLeaves")
					U.y_animation_play_group(this, "attack1_charge", nil, store.tick_ts, 1, "layers")

					loaded = "default"
				end

				if this.tower.blocked then
					goto label_43_0
				end
			end

			if loaded == "clobber" and store.tick_ts - ca.ts > ca.cooldown then
				loaded = nil

				SU.delay_attack(store, ca, 1)

				local triggers = U.find_enemies_in_range(store.entities, tpos(this), 0, ca.range, ca.vis_flags, ca.vis_bans)

				if triggers and #triggers > ca.min_count then
					ca.ts = store.tick_ts
					blink_ts = store.tick_ts

					S:queue(ca.sound)
					U.animation_start_group(this, ca.animation, nil, store.tick_ts, false, "layers")
					U.y_wait(store, ca.hit_time)

					for i = 1, #this.fx_points do
						local p = this.fx_points[i]
						local decal = E:create_entity(table.random({
							"decal_clobber_1",
							"decal_clobber_2"
						}))

						decal.pos.x, decal.pos.y = p.pos.x, p.pos.y
						decal.render.sprites[1].ts = store.tick_ts

						queue_insert(store, decal)

						local smoke = E:create_entity("fx_clobber_smoke")

						smoke.pos.x, smoke.pos.y = p.pos.x, p.pos.y
						smoke.render.sprites[1].ts = store.tick_ts

						queue_insert(store, smoke)
					end

					local fx = E:create_entity("fx_clobber_smoke_ring")

					fx.render.sprites[1].ts = store.tick_ts
					fx.pos.x, fx.pos.y = this.pos.x, this.pos.y

					queue_insert(store, fx)

					local targets = U.find_enemies_in_range(store.entities, tpos(this), 0, ca.damage_radius, ca.vis_flags, ca.vis_bans)
					local stun_count = 0

					if targets then
						for i, target in ipairs(targets) do
							local d = E:create_entity("damage")

							d.source_id = this.id
							d.target_id = target.id
							d.damage_type = ca.damage_type
							d.value = pow_c.damage_values[pow_c.level]

							queue_damage(store, d)

							local chance = ca.stun_chances[i] or ca.stun_chances[#ca.stun_chances]

							if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, bor(F_BOSS, F_FLYING)) == 0 and chance > math.random() then
								local mod = E:create_entity(ca.stun_mod)

								mod.modifier.target_id = target.id
								mod.modifier.duration = pow_c.stun_durations[pow_c.level]

								queue_insert(store, mod)

								if U.predict_damage(target, d) < target.health.hp then
									stun_count = stun_count + 1
								end
							end
						end
					end

					-- AC:high_check("HEAVY_WEIGHT", stun_count)
					U.y_animation_wait_group(this, "layers")

					goto label_43_0
				end
			end

			if loaded == "fiery_nuts" and store.tick_ts - fa.ts > fa.cooldown and do_attack(fa) then
				-- AC:inc_check("WILDFIRE_HARVEST")
			elseif loaded == "default" and store.tick_ts - aa.ts > aa.cooldown and do_attack(aa) then
				-- block empty
			elseif blink_cooldown < store.tick_ts - blink_ts then
				blink_ts = store.tick_ts
				this.render.sprites[blink_sid].hidden = false

				U.y_animation_play(this, "tower_entwood_blink", nil, store.tick_ts, 1, blink_sid)

				this.render.sprites[blink_sid].hidden = true
			end

			::label_43_1::
			local b = this.barrack

			if b then
				for i = 1, b.max_soldiers do
					local s = b.soldiers[i]

					if not s or s.health.dead and not store.entities[s.id] then
						s = E:create_entity(b.soldier_type)
						s.soldier.tower_id = this.id
						s.soldier.tower_soldier_idx = i
						s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
						s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers)
						s.nav_rally.new = true
						for key, value in pairs(s.powers) do
							value.level = pow_forest_keepers.level + 1
							value.changed = true
						end

						queue_insert(store, s)

						b.soldiers[i] = s

						signal.emit("tower-spawn", this, s)
					elseif upgradeForestKeepers then
						for key, value in pairs(s.powers) do
							value.level = pow_forest_keepers.level + 1
							value.changed = true
						end
					end
				end

				if b.rally_new then
					b.rally_new = false

					signal.emit("rally-point-changed", this)

					local all_dead = true

					for i, s in ipairs(b.soldiers) do
						s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers,
							b.rally_angle_offset)
						s.nav_rally.new = true
						all_dead = all_dead and s.health.dead
					end

					if not all_dead then
						S:queue(this.sound_events.change_rally_point)
					end
				end
			end
			upgradeForestKeepers = nil
		end

		::label_43_0::

		coroutine.yield()
	end
end

scripts.tower_bastion_holder = {}

function scripts.tower_bastion_holder.insert(this, store)
	if this.tower.flip_x then
		for _, s in pairs(this.render.sprites) do
			s.flip_x = true
		end
	end

	return true
end

scripts.tower_bastion = {}

function scripts.tower_bastion.get_info(this, store)
	local level = this.powers and this.powers.razor_edge.level or 0
	local au = E:get_template("aura_razor_edge")
	local a = au.aura
	local cycles = a.duration / a.cycle_time
	local min, max = math.ceil(a.damage_min * this.tower.damage_factor) + a.damage_inc * level, math.ceil(a.damage_max * this.tower.damage_factor) + a.damage_inc * level

	min, max = min * cycles, max * cycles

	return {
		type = STATS_TYPE_TOWER,
		damage_min = min,
		damage_max = max,
		cooldown = this.attacks.list[1].cooldown,
		range = this.attacks.range
	}
end

function scripts.tower_bastion.insert(this, store)
	if this.tower.flip_x then
		for _, s in pairs(this.render.sprites) do
			s.flip_x = true
		end
	end

	return true
end

function scripts.tower_bastion.update(this, store)
	local pow = this.powers.razor_edge
	local a = this.attacks
	local ra = a.list[1]

	ra.ts = store.tick_ts

	local animation_group = "animated"
	U.y_animation_play_group(this, "reload", nil, store.tick_ts, nil, animation_group)

	local function check_change_mode()
		if this.change_mode then
			this.ui.can_click = false
			this.ui.can_select = false
			this.change_mode = false
			if this.tower_upgrade_persistent_data.current_mode == 1 then
				this.tower_upgrade_persistent_data.current_mode = 0
			else
				this.tower_upgrade_persistent_data.current_mode = 1
			end
			if this.tower.flip_x then
				this.tower.flip_x = nil
			else
				this.tower.flip_x = true
			end
			local fx = E:create_entity(this.fx_out)
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].offset = this.fx_offset
			fx.pos = this.pos
			queue_insert(store, fx)
			S:queue(this.sound_events.change_flip_x)
			U.y_wait(store, this.hidden_delay)
			for i = 4, #this.render.sprites do
				local sprite = this.render.sprites[i]
				sprite.hidden = true
				sprite.flip_x = this.tower.flip_x
			end
			U.y_wait(store, this.fx_in_delay)
			fx = E:create_entity(this.fx_in)
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].offset = this.fx_offset
			fx.pos = this.pos
			queue_insert(store, fx)
			U.y_wait(store, this.show_delay)
			for i = 4, #this.render.sprites do
				local sprite = this.render.sprites[i]
				sprite.hidden = nil
			end
			U.y_wait(store, this.select_delay)
			this.ui.can_click = true
			this.ui.can_select = true
		end
	end

	while true do
		local skip
		local function tower_walk_waypoints(store, this, animation)
			local animation = animation or "walk"
			local r = this.nav_rally
			local n = this.nav_grid
			local dest = r.pos
		
			while not V.veq(this.pos, dest) do
				local w = table.remove(n.waypoints, 1) or dest
				local unsnap = #n.waypoints > 0
		
				U.set_destination(this, w)
				-- U.animation_start_group(this, animation, nil, store.tick_ts, true, animation_group)

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

				local out = tower_walk_waypoints(store, this, "idle")

				this.vis.bans = vis_bans

				return out
			end
		end

		check_change_mode()

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

		if not skip then
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil
				end
			end

			if store.tick_ts - ra.ts < ra.cooldown then
				-- block empty
			else
				local start_ts = store.tick_ts
				local target, targetNode = nil, nil
				local targets = U.find_enemies_in_range(store.entities, tpos(this), 0, 2 * a.range, ra.vis_flags, ra.vis_bans)
				if targets then
					for i = #targets, 1, -1 do
						local t = targets[i]
						local prediction_time = ra.shoot_time + fts(13)
						local node_offset = P:predict_enemy_node_advance(t, prediction_time)
						local t_ni = t.nav_path.ni + node_offset
						local t_pos = P:node_pos(t.nav_path.pi, t.nav_path.spi, t_ni)
						t.__ffe_ni = t_ni
						local bullet_start_x = this.pos.x + (this.tower.flip_x and -1 or 1) * ra.bullet_start_offset[1].x
						local bullet_start_y = this.pos.y + ra.bullet_start_offset[1].y
						local radian = V.angleTo(t_pos.x - bullet_start_x, t_pos.y - bullet_start_y)
						if not U.is_inside_ellipse(t_pos, tpos(this), a.range) or U.is_inside_ellipse(t_pos, tpos(this), ra.min_range) or 
						not this.tower.flip_x and (radian > 0 or radian < -math.pi / 2) or this.tower.flip_x and radian > -math.pi / 2 then
							table.remove(targets, i)
						end
					end
					if #targets > 0 then
						table.sort(targets, function(e1, e2)
							local p1 = e1.nav_path
							local p2 = e2.nav_path
							return P:nodes_to_goal(p1.pi, p1.spi, p1.ni) < P:nodes_to_goal(p2.pi, p2.spi, p2.ni)
						end)
						target = targets[1]
						targetNode = {}
						targetNode.pi, targetNode.spi, targetNode.ni = targets[1].nav_path.pi, targets[1].nav_path.spi, targets[1].__ffe_ni
					end
				end

				if not targetNode then
					-- block empty
				else
					U.animation_start_group(this, "shoot", nil, store.tick_ts, false, animation_group)
					U.y_wait(store, ra.shoot_time)
					S:queue(ra.sound_shoot)

					for i = 2, 3 do
						local dest
						if not target or target.motion.speed.x ~= 0 or target.motion.speed.y ~= 0 then
							dest = P:node_pos(targetNode.pi, i, targetNode.ni + 4)
						else
							dest = P:node_pos(targetNode.pi, i, targetNode.ni)
						end
						local b = E:create_entity(ra.bullet)

						b.pos.x = this.pos.x + (this.tower.flip_x and -1 or 1) * ra.bullet_start_offset[1].x
						b.pos.y = this.pos.y + ra.bullet_start_offset[1].y
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = dest
						b.bullet.level = pow.level
						b.render.sprites[1].flip_x = this.tower.flip_x

						local aura = E:create_entity(ra.payload_name)

						aura.aura.level = pow.level
						aura.render.sprites[1].flip_x = this.tower.flip_x
						aura.aura.damage_min = math.ceil(aura.aura.damage_min * this.tower.damage_factor)
						aura.aura.damage_max = math.ceil(aura.aura.damage_max * this.tower.damage_factor)
						b.bullet.payload = aura

						queue_insert(store, b)
					end

					U.y_animation_wait_group(this, animation_group)

					ra.ts = start_ts

					U.y_animation_play_group(this, "reload", nil, store.tick_ts, nil, animation_group)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.aura_razor_edge = {}

function scripts.aura_razor_edge.insert(this, store)
	this.tween.ts = store.tick_ts

	return true
end

scripts.soldier_blade = {}

function scripts.soldier_blade.on_damage(this, store, damage)
	log.debug(" SOLDIER_BLADE DAMAGE:%s type:%x", damage.value, damage.damage_type)

	local bda = this.timed_attacks.list[1]

	if not this.dodge or this.dodge.chance <= 0 or this.unit.is_stunned or this.health.dead or bda.in_progress or 
	band(damage.damage_type, DAMAGE_ALL_TYPES, bnot(bor(DAMAGE_PHYSICAL, DAMAGE_MAGICAL, DAMAGE_TRUE, DAMAGE_EXPLOSION, DAMAGE_ELECTRICAL))) ~= 0 or 
	band(damage.damage_type, DAMAGE_NO_DODGE) ~= 0 or this.powers[this.dodge.power_name].level < 1 or this.dodge.chance < math.random() then
		return true
	end

	log.debug("(%s)soldier_blade dodged damage %s of type %s", this.id, damage.value, damage.damage_type)

	this.dodge.active = true

	return false
end

function scripts.soldier_blade.insert(this, store)
	if scripts.soldier_barrack.insert(this, store) then
		if this.powers.blade_dance.level > 0 then
			local p = this.powers.blade_dance
			local bda = this.timed_attacks.list[1]

			bda.disabled = nil
			bda.ts = store.tick_ts
			bda.damage_min = p.damage_min[p.level]
			bda.damage_max = p.damage_max[p.level]
			bda.hits = p.hits[p.level]
		end

		return true
	end

	return false
end

function scripts.soldier_blade.update(this, store)
	local brk, sta
	local bda = this.timed_attacks.list[1]

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

	while true do
		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					SU.soldier_power_upgrade(this, pn)

					if pn == "blade_dance" then
						if p.level >= 1 then
							bda.disabled = nil
							bda.ts = store.tick_ts
						end

						bda.damage_min = p.damage_min[p.level]
						bda.damage_max = p.damage_max[p.level]
						bda.hits = p.hits[p.level]
					end
				end
			end
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
			if this.dodge and this.dodge.active and this.dodge.chance > 0 then
				local ca = this.dodge.counter_attack

				this.dodge.active = false

				if this.powers[this.dodge.power_name].level > 0 then
					local start_ts = store.tick_ts

					ca.ts = 0
					this.health.ignore_damage = true
					this.vis.bans = bor(this.vis.bans, F_NET)

					S:queue(ca.sound)
					U.animation_start(this, ca.animation, nil, store.tick_ts, true)
					U.y_wait(store, ca.hit_time)

					while store.tick_ts - start_ts < ca.duration do
						if store.tick_ts - ca.ts > ca.damage_every then
							ca.ts = store.tick_ts

							local targets = U.find_enemies_in_range(store.entities, this.pos, 0, ca.damage_radius, ca.damage_flags, ca.damage_bans)

							if targets then
								for _, target in pairs(targets) do
									local d = E:create_entity("damage")

									d.source_id = this.id
									d.target_id = target.id
									d.value = ca.damage_max
									d.damage_type = ca.damage_type

									queue_damage(store, d)
									-- AC:inc_check("PERFECT_PARRY", d.value)
								end
							end
						end

						coroutine.yield()
					end

					this.vis.bans = band(this.vis.bans, bnot(F_NET))
					this.health.ignore_damage = false

					SU.soldier_idle(store, this)
					signal.emit("soldier-dodge", this)
				end
			end

			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_53_2
				end
			end

			check_tower_damage_factor()

			if not bda.disabled and store.tick_ts - bda.ts > bda.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, bda.max_range, bda.vis_flags, bda.vis_bans)

				if not targets or #targets < bda.min_count then
					SU.delay_attack(store, bda, fts(6))

					goto label_53_1
				end

				bda.ts = store.tick_ts
				bda.in_progress = true
				this.health.ignore_damage = true
				this.vis._bans = this.vis.bans
				this.vis.bans = F_ALL

				local initial_pos = V.vclone(this.pos)
				local visited = {}

				U.y_animation_play(this, "dance_out", nil, store.tick_ts)

				for i = 1, bda.hits do
					::label_53_0::

					targets = U.find_enemies_in_range(store.entities, this.pos, 0, bda.max_range, bda.vis_flags, bda.vis_bans, function(v)
						return not table.contains(visited, v)
					end)

					if not targets then
						if #visited > 0 then
							visited = {}

							goto label_53_0
						else
							break
						end
					end

					local target = targets[km.zmod(i, #targets)]

					table.insert(visited, target)
					SU.stun_inc(target)

					local spos, sflip = U.melee_slot_position(this, target, 1)

					this.pos.x, this.pos.y = spos.x, spos.y

					S:queue(bda.sound)

					local an = table.random({
						"dance_hit1",
						"dance_hit2",
						"dance_hit3"
					})

					U.animation_start(this, an, sflip, store.tick_ts)
					U.y_wait(store, bda.hit_time)

					local d = E:create_entity("damage")

					d.source_id = this.id
					d.target_id = target.id
					d.value = math.ceil(U.frandom(bda.damage_min, bda.damage_max))
					d.damage_type = bda.damage_type

					queue_damage(store, d)
					U.y_animation_wait(this)
					SU.stun_dec(target)
				end

				this.pos.x, this.pos.y = initial_pos.x, initial_pos.y

				U.y_animation_play(this, "dance_in", nil, store.tick_ts)

				this.health.ignore_damage = false
				this.vis.bans = this.vis._bans
				this.vis._bans = nil

				-- AC:inc_check("BLADE_DANCE")

				bda.in_progress = nil

				goto label_53_2
			end

			::label_53_1::

			if this.melee then
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_53_2
				end
			end

			if SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_53_2::

		coroutine.yield()
	end
end

scripts.soldier_forest = {}

function scripts.soldier_forest.insert(this, store)
	if scripts.soldier_barrack.insert(this, store) then
		if this.powers.oak.level > 0 then
			this.ranged.attacks[1].disabled = true
			this.ranged.attacks[2].disabled = nil
			this.ranged.attacks[2].level = this.powers.oak.level
		end

		return true
	end

	return false
end

function scripts.soldier_forest.update(this, store)
	local brk, sta
	local tower = store.entities[this.soldier.tower_id]
	local ca = this.timed_attacks.list[1]
	local ea = this.timed_attacks.list[2]
	local pow_c = this.powers.circle
	local pow_e = this.powers.eerie

	local function check_tower_damage_factor()
		if store.entities[this.soldier.tower_id] then
			for _, a in ipairs(this.melee.attacks) do
				if not a._original_damage_min then
					a._original_damage_min = a.damage_min
				end

				if not a._original_damage_max then
					a._original_damage_max = a.damage_max
				end

				a.damage_min = a._original_damage_min * store.entities[this.soldier.tower_id].tower.damage_factor
				a.damage_max = a._original_damage_max * store.entities[this.soldier.tower_id].tower.damage_factor
			end
		end
	end

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	while true do
		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					SU.soldier_power_upgrade(this, pn)

					if pn == "oak" then
						if p.level >= 1 then
							this.ranged.attacks[1].disabled = true
							this.ranged.attacks[2].disabled = nil
						end

						this.ranged.attacks[2].level = p.level
					end

					if pn == "circle" then
						this.timed_attacks.list[1].ts = store.tick_ts
					end

					if pn == "eerie" then
						this.timed_attacks.list[2].ts = store.tick_ts
					end
				end
			end
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
			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_56_3
				end
			end

			check_tower_damage_factor()

			if pow_e.level > 0 and store.tick_ts - ea.ts > ea.cooldown then
				for _, s in pairs(tower.barrack.soldiers) do
					if s and not s.health.dead and s._casting_eerie then
						SU.delay_attack(store, ea, fts(6))

						goto label_56_0
					end
				end

				local max_range = ea.max_range + pow_e.level * ea.max_range_inc
				local target = U.find_random_enemy(store.entities, this.pos, 0, max_range, ea.vis_flags, ea.vis_bans, function(e)
					return U.get_blocker(store, e) == nil and not e.unit.is_stunned
				end)

				if not target then
					SU.delay_attack(store, ea, fts(6))
				else
					this._casting_eerie = true
					ea.ts = store.tick_ts

					for _, s in pairs(tower.barrack.soldiers) do
						if s and not s.health.dead then
							s.timed_attacks.list[2].ts = store.tick_ts
						end
					end

					U.animation_start(this, ea.animation, nil, store.tick_ts)
					U.y_wait(store, ea.cast_time)

					local a = E:create_entity(ea.bullet)

					a.aura.source_id = this.id
					a.aura.level = pow_e.level

					local ni = target.nav_path.ni + P:predict_enemy_node_advance(target, fts(10))

					a.pos = P:node_pos(target.nav_path.pi, 1, ni)
					a.pos_pi = target.nav_path.pi
					a.pos_ni = ni

					queue_insert(store, a)
					U.y_animation_wait(this)

					this._casting_eerie = nil

					-- AC:inc_check("EERIE_GARDENER")
				end
			end

			::label_56_0::

			if pow_c.level > 0 and store.tick_ts - ca.ts > ca.cooldown then
				if this.health.hp >= ca.trigger_hp_factor * this.health.hp_max then
					SU.delay_attack(store, ca, fts(6))
				else
					for _, s in pairs(tower.barrack.soldiers) do
						if s and not s.health.dead and s._casting_circle then
							SU.delay_attack(store, ca, fts(6))

							goto label_56_1
						end
					end

					this._casting_circle = true
					ca.ts = store.tick_ts

					for _, s in pairs(tower.barrack.soldiers) do
						if s and not s.health.dead then
							s.timed_attacks.list[1].ts = store.tick_ts
						end
					end

					S:queue(ca.sound)
					U.animation_start(this, ca.animation, nil, store.tick_ts)
					U.y_wait(store, ca.cast_time)

					local fx = E:create_entity("fx_forest_circle")

					fx.pos.x, fx.pos.y = this.pos.x + this.unit.mod_offset.x, this.pos.y + this.unit.mod_offset.y
					fx.tween.ts = store.tick_ts

					queue_insert(store, fx)

					local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, ca.max_range, ca.vis_flags, ca.vis_bans)

					if not targets then
						log.debug("Circle of Life has no targets for soldier id:%s", this.id)
					else
						for _, target in pairs(targets) do
							local mod = E:create_entity(ca.mod)

							mod.modifier.level = pow_c.level
							mod.modifier.source_id = this.id
							mod.modifier.target_id = target.id

							queue_insert(store, mod)
						end

						U.y_animation_wait(this)

						this._casting_circle = nil
					end
				end
			end

			::label_56_1::

			if this.melee then
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk then
					goto label_56_3
				end
			end

			if this.ranged then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk or sta == A_DONE then
					goto label_56_3
				elseif sta == A_IN_COOLDOWN then
					goto label_56_2
				end
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_56_3
			end

			::label_56_2::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_56_3::

		coroutine.yield()
	end
end

scripts.soldier_druid_bear = {}

function scripts.soldier_druid_bear.update(this, store)
	local brk, sta
	local effects = {
		"effect",
		"rune",
		"decal"
	}
	local standing = false

	local function do_effects(is_spawn)
		local prefix = is_spawn and "fx_druid_bear_spawn_" or "fx_druid_bear_death_"

		for _, n in pairs(effects) do
			local fx = E:create_entity(prefix .. n)

			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x
			fx.pos = V.vclone(this.pos)

			local ox = 0

			if is_spawn then
				ox = n == "decal" and -3 or -6
			else
				ox = n == "decal" and 3 or -6
			end

			fx.pos.x = fx.pos.x + ox * (fx.render.sprites[1].flip_x and -1 or 1)

			queue_insert(store, fx)
		end
	end

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	this.health_bar.hidden = true

	do_effects(true)
	U.y_animation_play(this, "spawn", nil, store.tick_ts)

	this.health_bar.hidden = nil

	while true do
		if this.health.dead then
			do_effects(false)
			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_58_0
				end
			end

			if this.melee then
				local target = SU.soldier_pick_melee_target(store, this)

				if not target then
					-- block empty
				else
					if standing then
						local slot_pos = U.melee_slot_position(this, target)

						if slot_pos and not V.veq(slot_pos, this.pos) then
							U.y_animation_play(this, "stance2idle", nil, store.tick_ts)

							this.health_bar.offset = this.health_bar.offsets.idle
							standing = false
						end
					end

					if SU.soldier_move_to_slot_step(store, this, target) then
						goto label_58_0
					end

					local attack = SU.soldier_pick_melee_attack(store, this, target)

					if not attack then
						goto label_58_0
					end

					if not standing then
						U.y_animation_play(this, "idle2stance", nil, store.tick_ts)

						this.health_bar.offset = this.health_bar.offsets.standing
						standing = true
					end

					local attack_done = SU.y_soldier_do_single_melee_attack(store, this, target, attack)

					if attack_done then
						goto label_58_0
					end
				end
			end

			if standing then
				U.y_animation_play(this, "stance2idle", nil, store.tick_ts)

				this.health_bar.offset = this.health_bar.offsets.idle
				standing = false
			end

			if SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_58_0::

		coroutine.yield()
	end
end

scripts.soldier_drow = {}

function scripts.soldier_drow.insert(this, store)
	if scripts.soldier_barrack.insert(this, store) then
		for pn, p in pairs(this.powers) do
			if pn == "double_dagger" and p.level > 0 then
				this.ranged.attacks[1].loops = 2
			end

			if pn == "blade_mail" and p.level > 0 then
				this.health.spiked_armor = p.spiked_armor[p.level]
				this.render.sprites[2].hidden = nil
			end
		end

		return true
	end

	return false
end

function scripts.soldier_drow.update(this, store)
	local brk, sta
	local tower = store.entities[this.soldier.tower_id]
	local aura = this.render.sprites[2]

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	while true do
		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					SU.soldier_power_upgrade(this, pn)

					if pn == "life_drain" and p.level == 1 then
						this.melee.attacks[2].ts = store.tick_ts
					end

					if pn == "double_dagger" then
						this.ranged.attacks[1].loops = 2
					end

					if pn == "blade_mail" then
						this.health.spiked_armor = p.spiked_armor[p.level]
						aura.hidden = nil
					end
				end
			end
		end

		if not this.health.dead or SU.y_soldier_revive(store, this) then
			-- block empty
		else
			aura.hidden = true

			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_61_1
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk or sta == A_DONE then
					goto label_61_1
				elseif sta == A_IN_COOLDOWN then
					goto label_61_0
				end

				if SU.soldier_go_back_step(store, this) then
					goto label_61_1
				end

				::label_61_0::

				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_61_1::

		coroutine.yield()
	end
end

scripts.soldier_xin_shadow = {}

function scripts.soldier_xin_shadow.insert(this, store, script)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.soldier_xin_shadow.update(this, store)
	local target_id = this.soldier.target_id or this.unblocked_target_id
	local target = store.entities[target_id]
	local attack_count = 0

	this.render.sprites[1].ts = store.tick_ts

	U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

	if not target then
		U.y_wait(store, U.frandom(this.min_wait, this.max_wait))
	else
		while target and not target.health.dead and not this.health.dead and (not this.max_attack_count or attack_count < this.max_attack_count) do
			local attack = SU.soldier_pick_melee_attack(store, this, target)

			if attack then
				local start_ts = store.tick_ts
				local an, af = U.animation_name_facing_point(this, attack.animation, target.pos)

				U.animation_start(this, an, af, store.tick_ts, 1)
				S:queue(attack.sound)
				U.y_wait(store, attack.hit_time)
				S:queue(attack.sound_hit)

				attack.ts = start_ts

				for _, aa in pairs(this.melee.attacks) do
					if aa ~= attack and aa.shared_cooldown then
						aa.ts = attack.ts
					end
				end

				if attack.damage_type ~= DAMAGE_NONE then
					local d = E:create_entity("damage")

					d.damage_type = attack.damage_type
					d.value = math.ceil(U.frandom(attack.damage_min, attack.damage_max))
					d.source_id = this.id
					d.target_id = target.id

					queue_damage(store, d)
				end

				U.y_animation_wait(this)

				attack_count = attack_count + 1
			end

			SU.soldier_idle(store, this)
			coroutine.yield()

			target = store.entities[target_id]
		end
	end

	S:queue(this.sound_events.death)
	U.y_animation_play(this, "death", nil, store.tick_ts)
	queue_remove(store, this)
end

scripts.hero_elves_denas = {}

function scripts.hero_elves_denas.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	local s

	s = this.hero.skills.sybarite

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local m = E:get_template("mod_elves_denas_sybarite")

		m.heal_hp = s.heal_hp[s.level]
	end

	s = this.hero.skills.celebrity

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.max_targets = s.max_targets[s.level]

		local m = E:get_template("mod_elves_denas_celebrity")

		m.modifier.duration = s.stun_duration[s.level]
	end

	s = this.hero.skills.mighty

	if initial and s.level > 0 then
		local a = this.melee.attacks[3]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end

	s = this.hero.skills.shield_strike

	if initial and s.level > 0 then
		local a = this.ranged.attacks[1]

		a.disabled = nil

		local b = E:get_template("shield_elves_denas")

		b.max_rebounds = s.rebounds[s.level]
		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end

	s = this.hero.skills.ultimate

	if initial and s.level > 0 then
		-- block empty
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_elves_denas.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.hero_elves_denas.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	local function shield_strike_filter_fn(e, origin)
		local a = this.ranged.attacks[1]
		local targets = U.find_enemies_in_range(store.entities, e.pos, 0, a.rebound_range, a.vis_flags, a.vis_bans)

		return targets and #targets > 1
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_66_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.celebrity

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_random_enemy(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans, function(e)
					return e.unit and not e.unit.is_stunned
				end)

				if not target then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
					U.animation_start(this, a.animation, nil, store.tick_ts)
					U.y_wait(store, fts(22))
					S:queue(a.sound)

					local total_time = fts(52)
					local flash_every = 1
					local stun_every = 9 / a.max_targets

					for i = 1, 9 do
						if this.health.dead then
							goto label_66_0
						end

						if i % flash_every == 0 then
							local sfx = E:create_entity("fx_elves_denas_flash")

							sfx.pos.x, sfx.pos.y = this.pos.x + math.random(-25, 25), this.pos.y + math.random(5, 40)
							sfx.render.sprites[1].ts = store.tick_ts
							sfx.render.sprites[1].flip_x = math.random() < 0.5

							queue_insert(store, sfx)
						end

						if i % stun_every == 0 then
							target = U.find_random_enemy(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans, function(e)
								return e.unit and not e.unit.is_stunned
							end)
							target = target or U.find_random_enemy(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

							if target then
								local mod = E:create_entity("mod_elves_denas_celebrity")

								mod.modifier.target_id = target.id

								queue_insert(store, mod)
							end
						end

						U.y_wait(store, total_time / 9)
					end

					U.y_animation_wait(this)
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.sybarite

			if not a.disabled and this.health.hp <= this.health.hp_max - a.lost_health and store.tick_ts - a.ts > a.cooldown then
				U.animation_start(this, a.animation, nil, store.tick_ts)

				if U.y_wait(store, a.hit_time, function()
					return this.health.dead or this.unit.is_stunned
				end) then
					goto label_66_0
				end

				a.ts = store.tick_ts

				S:queue(a.sound)

				local mod = E:create_entity(a.mod)

				mod.modifier.target_id = this.id
				mod.modifier.source_id = this.id

				queue_insert(store, mod)
				U.y_animation_wait(this)
			end

			a = this.ranged.attacks[1]
			skill = this.hero.skills.shield_strike

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target, _, pred_pos = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, shield_strike_filter_fn, F_FLYING)

				if target then
					local start_ts = store.tick_ts
					local attack_done = SU.y_soldier_do_ranged_attack(store, this, target, a, pred_pos)

					if attack_done then
						a.ts = start_ts
					else
						goto label_66_0
					end
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			elseif SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				a = this.wealthy

				if store.wave_group_number > a.last_wave then
					a.last_wave = store.wave_group_number

					S:queue(a.sound)

					store.player_gold = store.player_gold + a.gold

					U.animation_start(this, "coinThrow", nil, store.tick_ts)
					U.y_wait(store, a.hit_time)

					local fx = E:create_entity(a.fx)

					fx.render.sprites[1].ts = store.tick_ts
					fx.pos.x, fx.pos.y = this.pos.x + (this.render.sprites[1].flip_x and 1 or -1) * 20, this.pos.y
					fx.tween.props[2] = E:clone_c("tween_prop")
					fx.tween.props[2].name = "offset"
					fx.tween.props[2].keys = {
						{
							0,
							V.v(0, 40)
						},
						{
							0.5,
							V.v(0, 50)
						}
					}

					queue_insert(store, fx)
					U.y_animation_wait(this)
				end

				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_66_0::

		coroutine.yield()
	end
end

scripts.hero_elves_denas_ultimate = {}

function scripts.hero_elves_denas_ultimate.can_fire_fn(this, x, y)
	return P:valid_node_nearby(x, y, nil, NF_RALLY) and GR:cell_is_only(x, y, TERRAIN_LAND)
end

function scripts.hero_elves_denas_ultimate.update(this, store)
	local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

	if #nearest > 1 then
		local pi, spi, ni = unpack(nearest[1])
		local pos = P:node_pos(pi, 1, ni)
		local count = this.guards_count[this.level]

		for i = 1, count do
			local p = U.point_on_ellipse(pos, 25, i * 2 * math.pi / count)
			local e = E:create_entity(this.guards_template)

			e.pos = p
			e.nav_rally.center = V.vclone(e.pos)
			e.nav_rally.pos = V.vclone(e.pos)
			e.melee.attacks[1].xp_dest_id = this.owner.id
			e.melee.attacks[2].xp_dest_id = this.owner.id

			queue_insert(store, e)
		end
	end

	queue_remove(store, this)
end

scripts.mod_elves_denas_sybarite = {}

function scripts.mod_elves_denas_sybarite.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor
	target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp + this.heal_hp)
	this.render.sprites[1].ts = store.tick_ts

	return true
end

function scripts.mod_elves_denas_sybarite.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.unit.damage_factor = target.unit.damage_factor / this.inflicted_damage_factor
	end

	return true
end

scripts.shield_elves_denas = {}

function scripts.shield_elves_denas.update(this, store)
	local b = this.bullet
	local mspeed = b.max_speed
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local ps
	local bounce_count = 0
	local visited = {}

	U.animation_start(this, nil, nil, store.tick_ts, true)

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	::label_75_0::

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead then
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
		end

		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	if target and not target.health.dead then
		table.insert(visited, target.id)

		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)

		if b.hit_blood_fx and target.unit.blood_color ~= BLOOD_NONE then
			local sfx = E:create_entity(b.hit_blood_fx)

			sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
			sfx.render.sprites[1].ts = store.tick_ts

			if sfx.use_blood_color and target.unit.blood_color then
				sfx.render.sprites[1].name = target.unit.blood_color
				sfx.render.sprites[1].r = this.render.sprites[1].r
			end

			queue_insert(store, sfx)
		end
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		sfx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, sfx)
	end

	if bounce_count < this.max_rebounds then
		local last_target = target

		::label_75_1::

		target = U.find_random_enemy(store.entities, this.pos, 0, this.rebound_range, b.vis_flags, b.vis_bans, function(v)
			return not table.contains(visited, v.id)
		end)

		if not target and #visited > 1 then
			visited = {
				last_target.id
			}

			goto label_75_1
		end

		if target then
			S:queue(this.sound_events.bounce)

			bounce_count = bounce_count + 1
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			b.target_id = target.id

			goto label_75_0
		end
	end

	queue_remove(store, this)
end

scripts.hero_elves_archer = {}

function scripts.hero_elves_archer.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	local s

	s = this.hero.skills.multishot

	if initial and s.level > 0 then
		local a = this.ranged.attacks[2]

		a.disabled = nil
		a.max_loops = s.loops[s.level]
	end

	s = this.hero.skills.porcupine

	if initial and s.level > 0 then
		bt.bullet.damage_inc = s.damage_inc[s.level]
	end

	s = this.hero.skills.nimble_fencer

	if initial and s.level > 0 then
		this.dodge.disabled = nil
		this.dodge.chance = s.chance[s.level]
	end

	s = this.hero.skills.double_strike

	if initial and s.level > 0 then
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end

	s = this.hero.skills.ultimate

	if initial and s.level > 0 then
		-- block empty
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_elves_archer.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	local a = E:create_entity("aura_elves_archer_regen")

	a.aura.source_id = this.id
	a.aura.ts = store.tick_ts
	a.pos = this.pos

	queue_insert(store, a)

	return true
end

function scripts.hero_elves_archer.update(this, store)
	local h = this.health
	local he = this.hero
	local brk, sta, a, skill
	local is_sword = false
	local porcupine_target, porcupine_level = nil, 0
	local skill_ultimate = this.hero.skills.ultimate
	local ultimate_controller = E:get_template(skill_ultimate.controller_name)

	local function update_porcupine(attack, target)
		if porcupine_target == target then
			porcupine_level = math.min(porcupine_level + 1, 3)
			attack.level = porcupine_level
		else
			porcupine_level = 0
			attack.level = 0
		end

		porcupine_target = target
	end

	skill_ultimate.ts = store.tick_ts - ultimate_controller.cooldown

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		this.regen.is_idle = nil

		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if this.dodge and this.dodge.active then
				this.dodge.active = false
				this.dodge.counter_attack_pending = true
			end

			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_79_4
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if this.melee then
				local target = SU.soldier_pick_melee_target(store, this)

				if not target then
					-- block empty
				else
					if is_sword then
						local slot_pos = U.melee_slot_position(this, target)

						if slot_pos and not V.veq(slot_pos, this.pos) then
							U.y_animation_play(this, "sword2bow", nil, store.tick_ts)

							is_sword = false
						end
					end

					if SU.soldier_move_to_slot_step(store, this, target) then
						goto label_79_4
					end

					local attack = SU.soldier_pick_melee_attack(store, this, target)

					if not attack then
						goto label_79_4
					end

					local upg = UP:get_upgrade("heroes_lethal_focus")
					local triggered_lethal_focus = false
					local attack_pop = attack.pop
					local attack_pop_chance = attack.pop_chance
				
					if attack.basic_attack and upg then
						if not this._lethal_focus_deck then
							this._lethal_focus_deck = SU.deck_new(upg.trigger_cards, upg.total_cards)
						end
				
						triggered_lethal_focus = SU.deck_draw(this._lethal_focus_deck)
					end
				
					if triggered_lethal_focus then
						this.unit.damage_factor = this.unit.damage_factor * upg.damage_factor
						attack.pop = {
							"pop_crit_heroes"
						}
						attack.pop_chance = 1
					end

					if not is_sword then
						U.y_animation_play(this, "bow2sword", nil, store.tick_ts)

						is_sword = true
					end

					if attack.xp_from_skill then
						SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
					end

					local attack_done = SU.y_soldier_do_single_melee_attack(store, this, target, attack)

					if triggered_lethal_focus then
						this.unit.damage_factor = this.unit.damage_factor / upg.damage_factor
						attack.pop = attack_pop
						attack.pop_chance = attack_pop_chance
					end

					U.animation_start(this, "idle_sword", nil, store.tick_ts, true)

					goto label_79_4
				end
			end

			if is_sword then
				U.y_animation_play(this, "sword2bow", nil, store.tick_ts)

				is_sword = false
			end

			if store.tick_ts - skill_ultimate.ts >= ultimate_controller.cooldown then
				local target, ultimatePos, targets_info
				target = U.find_foremost_enemy(store.entities, this.pos, 0, skill_ultimate.max_range)
				if target then
					targets_info = U.find_enemies_in_paths(store.entities, target.pos, 0, skill_ultimate.range_nodes_max)
				end
				if targets_info and #targets_info >= skill_ultimate.min_targets then
					target = targets_info[1].enemy
					if not target.nav_path then
						target = nil
					else
						ultimatePos = V.vclone(target.pos)
						if not ultimate_controller.can_fire_fn(nil, ultimatePos.x, ultimatePos.y) then
							target = nil
							ultimatePos = nil
						end
					end
				end
				if not target or not ultimatePos then
					skill_ultimate.ts = store.tick_ts - ultimate_controller.cooldown + 0.1
				else
					U.animation_start(this, "levelup", nil, store.tick_ts, 1)
					local u = E:create_entity(ultimate_controller)
					u.pos = ultimatePos
					u.level = skill_ultimate.level
					queue_insert(store, u)
					skill_ultimate.ts = store.tick_ts
					while not U.animation_finished(this) do
						if SU.hero_interrupted(this) then
							goto label_79_3
						end
						coroutine.yield()
					end
				end
			end

			if this.ranged then
				local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)

				if not target then
					goto label_79_3
				end

				this.regen.is_idle = true

				if not attack then
					goto label_79_3
				end

				local upg = UP:get_upgrade("heroes_lethal_focus")
				local triggered_lethal_focus = false
				local bullet_t = E:get_template(attack.bullet)
				local bullet_use_unit_damage_factor = bullet_t.bullet.use_unit_damage_factor
				local bullet_pop = bullet_t.bullet.pop
				local bullet_pop_conds = bullet_t.bullet.pop_conds
			
				if attack.basic_attack and upg then
					if not this._lethal_focus_deck then
						this._lethal_focus_deck = SU.deck_new(upg.trigger_cards, upg.total_cards)
					end
			
					triggered_lethal_focus = SU.deck_draw(this._lethal_focus_deck)
				end
			
				if triggered_lethal_focus then
					if bullet_t.bullet.damage_radius > 0 then
						this.unit.damage_factor = this.unit.damage_factor * upg.damage_factor_area
					else
						this.unit.damage_factor = this.unit.damage_factor * upg.damage_factor
					end
			
					bullet_t.bullet.use_unit_damage_factor = true
					bullet_t.bullet.pop = {
						"pop_crit"
					}
					bullet_t.bullet.pop_conds = DR_DAMAGE
				end

				U.set_destination(this, this.pos)

				local attack_done
				local start_ts = store.tick_ts

				if attack.max_loops then
					local an, af, ai = U.animation_name_facing_point(this, attack.animations[1], target.pos)

					U.y_animation_play(this, an, af, store.tick_ts, 1)

					local retarget_flag
					local loops, loops_done = attack.max_loops, 0
					local pred_shots
					local b = E:create_entity(attack.bullet)
					local d = SU.create_bullet_damage(b.bullet)

					::label_79_0::

					if retarget_flag then
						retarget_flag = nil

						local n_target, _, n_pred_pos = U.find_foremost_enemy(store.entities, this.pos, attack.min_range, attack.max_range, attack.node_prediction, attack.vis_flags, attack.vis_bans, function(v)
							return v ~= target
						end, F_FLYING)

						if n_target then
							target = n_target
							pred_pos = n_pred_pos
						else
							goto label_79_1
						end
					end

					update_porcupine(attack, target)

					d.value = math.ceil((b.bullet.damage_min + b.bullet.damage_max + 2 * attack.level * (b.bullet.damage_inc or 0)) / 2)
					pred_shots = math.ceil(target.health.hp / U.predict_damage(target, d))

					log.paranoid("+++ pred_shots:%s d.value:%s target.hp:%s", pred_shots, d.value, target.health.hp)

					loops = math.min(attack.max_loops - loops_done, pred_shots)

					for i = 1, loops do
						an, af, ai = U.animation_name_facing_point(this, attack.animations[2], target.pos)

						U.animation_start(this, an, af, store.tick_ts, false)

						while store.tick_ts - this.render.sprites[1].ts < attack.shoot_times[1] do
							if SU.hero_interrupted(this) then
								goto label_79_2
							end

							coroutine.yield()
						end

						local b = E:create_entity(attack.bullet)

						b.pos = V.vclone(this.pos)

						if attack.bullet_start_offset then
							local offset = attack.bullet_start_offset[1]

							b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
						end

						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
						b.bullet.target_id = target.id
						b.bullet.source_id = this.id
						b.bullet.xp_dest_id = this.id
						b.bullet.level = attack.level

						queue_insert(store, b)

						if attack.xp_from_skill then
							SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
						end

						attack_done = true
						loops_done = loops_done + 1

						while not U.animation_finished(this) do
							if SU.hero_interrupted(this) then
								goto label_79_2
							end

							coroutine.yield()
						end

						if target.health.dead or band(F_RANGED, target.vis.bans) ~= 0 then
							retarget_flag = true

							goto label_79_0
						end

						update_porcupine(attack, target)
					end

					if loops_done < attack.max_loops then
						retarget_flag = true

						goto label_79_0
					end

					::label_79_1::

					an, af, ai = U.animation_name_facing_point(this, attack.animations[3], target.pos)

					U.animation_start(this, an, af, store.tick_ts, 1)

					while not U.animation_finished(this) do
						if SU.hero_interrupted(this) then
							break
						end

						coroutine.yield()
					end
				else
					update_porcupine(attack, target)

					attack_done = SU.y_soldier_do_ranged_attack(store, this, target, attack, pred_pos)
				end

				::label_79_2::

				if attack_done then
					attack.ts = start_ts
				end

				if triggered_lethal_focus then
					if bullet_t.bullet.damage_radius > 0 then
						this.unit.damage_factor = this.unit.damage_factor / upg.damage_factor_area
					else
						this.unit.damage_factor = this.unit.damage_factor / upg.damage_factor
					end
					bullet_t.bullet.use_unit_damage_factor = bullet_use_unit_damage_factor
					bullet_t.bullet.pop = bullet_pop
					bullet_t.bullet.pop_conds = bullet_pop_conds
				end

				goto label_79_4
			end

			::label_79_3::

			if SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)

				this.regen.is_idle = true
			end
		end

		::label_79_4::

		coroutine.yield()
	end
end

scripts.hero_elves_archer_ultimate = {}

function scripts.hero_elves_archer_ultimate.can_fire_fn(this, x, y)
	return not GR:cell_is(x, y, TERRAIN_FAERIE) and P:valid_node_nearby(x, y, 1.4285714285714286, NF_POWER_3)
end

function scripts.hero_elves_archer_ultimate.update(this, store)
	local function spawn_arrow(pi, spi, ni)
		spi = spi or math.random(1, 3)

		local pos = P:node_pos(pi, spi, ni)

		pos.x = pos.x + math.random(-4, 4)
		pos.y = pos.y + math.random(-5, 5)

		local b = E:create_entity(this.bullet)

		b.bullet.damage_max = this.damage[this.level]
		b.bullet.damage_min = this.damage[this.level]
		b.bullet.from = V.v(pos.x + math.random(-170, -140), pos.y + REF_H)
		b.bullet.to = pos
		b.pos = V.vclone(b.bullet.from)

		queue_insert(store, b)
	end

	local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

	if #nearest > 0 then
		local pi, spi, ni = unpack(nearest[1])

		spawn_arrow(pi, spi, ni)

		local count = this.spread[this.level]
		local sequence = {}

		for i = 1, count do
			sequence[i] = i
		end

		while #sequence > 0 do
			local i = table.remove(sequence, math.random(1, #sequence))
			local delay = U.frandom(0, 1 / count)

			U.y_wait(store, delay / 2)

			if P:is_node_valid(pi, ni + i) then
				spawn_arrow(pi, nil, ni + i)
			else
				spawn_arrow(pi, nil, ni - i)
			end

			U.y_wait(store, delay / 2)

			if P:is_node_valid(pi, ni - i) then
				spawn_arrow(pi, nil, ni - i)
			else
				spawn_arrow(pi, nil, ni + i)
			end
		end
	end

	queue_remove(store, this)
end

scripts.arrow_hero_elves_archer_ultimate = {}

function scripts.arrow_hero_elves_archer_ultimate.update(this, store)
	local b = this.bullet
	local speed = b.max_speed

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
		b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	local targets = U.find_targets_in_range(store.entities, b.to, 0, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in pairs(targets) do
			local d = E:create_entity("damage")

			d.damage_type = b.damage_type
			d.value = b.damage_max
			d.source_id = this.id
			d.target_id = target.id

			queue_damage(store, d)

			if b.mod then
				local mod = E:create_entity(b.mod)

				mod.modifier.target_id = target.id

				queue_insert(store, mod)
			end
		end
	end

	if b.hit_fx then
		SU.insert_sprite(store, b.hit_fx, this.pos)
	end

	if b.arrive_decal then
		local decal = E:create_entity(b.arrive_decal)

		decal.pos = V.vclone(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		queue_insert(store, decal)
	end

	queue_remove(store, this)
end

scripts.decal_hero_elves_archer_ultimate = {}

function scripts.decal_hero_elves_archer_ultimate.insert(this, store)
	this.render.sprites[1].ts = store.tick_ts
	this.render.sprites[1].r = U.frandom(-10, 5) * math.pi / 180
	this.render.sprites[2].ts = store.tick_ts

	return true
end

scripts.hero_arivan = {}

function scripts.hero_arivan.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	local s

	s = this.hero.skills.icy_prison

	if initial and s.level > 0 then
		local a = this.ranged.attacks[3]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.damage_min = s.damage[s.level]
		b.bullet.damage_max = s.damage[s.level]

		local m = E:get_template(b.bullet.mod)

		m.modifier.duration = s.duration[s.level]
	end

	s = this.hero.skills.lightning_rod

	if initial and s.level > 0 then
		local a = this.ranged.attacks[2]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end

	s = this.hero.skills.seal_of_fire

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.loops = s.count[s.level]
	end

	s = this.hero.skills.stone_dance

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.ts = -a.cooldown + 2

		local aura = E:get_template("aura_arivan_stone_dance")

		aura.max_stones = s.count[s.level]
	end

	s = this.hero.skills.ultimate

	if initial then
		local u = E:get_template("hero_arivan_ultimate")
		local tal = u.timed_attacks.list
		local mf = E:get_template("mod_arivan_ultimate_freeze")

		u.aura.duration = s.duration[s.level]
		tal[2].damage_max = s.damage[s.level]
		tal[2].damage_min = s.damage[s.level]
		mf.modifier.duration = s.freeze_duration[s.level]
		tal[3].chance = s.freeze_chance[s.level]
		tal[4].cooldown = s.lightning_cooldown[s.level]
		tal[4].chance = s.lightning_chance[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_arivan.on_damage(this, store, damage)
	log.debug(" ARIVAN DAMAGE: %s", damage.value)

	local at = this.timed_attacks.list[2]
	local a = at.aura

	if not a or #a.stones < 1 or band(damage.damage_type, DAMAGE_MODIFIER) ~= 0 then
		return true
	end

	local stone = a.stones[#a.stones]

	stone.hp = stone.hp - damage.value

	if stone.hp <= 0 then
		local fx = E:create_entity("fx_arivan_stone_explosion")

		fx.pos = stone.pos
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
		queue_remove(store, stone)
		table.remove(a.stones, #a.stones)
	end

	a.shield_active = true

	return false
end

function scripts.hero_arivan.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	if this.hero.skills.stone_dance.level > 0 then
		local a = E:create_entity("aura_arivan_stone_dance")

		a.aura.source_id = this.id
		a.aura.ts = store.tick_ts
		a.pos = this.pos
		this.timed_attacks.list[2].aura = a

		queue_insert(store, a)
	end

	return true
end

function scripts.hero_arivan.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta
	local skill_ultimate = this.hero.skills.ultimate
	local ultimate_controller = E:get_template(skill_ultimate.controller_name)

	skill_ultimate.ts = store.tick_ts - ultimate_controller.cooldown

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_90_0
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if store.tick_ts - skill_ultimate.ts >= ultimate_controller.cooldown then
				local target, ultimatePos, targets_info
				target = U.find_foremost_enemy(store.entities, this.pos, 0, skill_ultimate.max_range)
				if target then
					targets_info = U.find_enemies_in_paths(store.entities, target.pos, 0, skill_ultimate.range_nodes_max)
				end
				if targets_info and #targets_info >= skill_ultimate.min_targets then
					target = targets_info[1].enemy
					if not target.nav_path then
						target = nil
					else
						ultimatePos = V.vclone(target.pos)
						if not ultimate_controller.can_fire_fn(nil, ultimatePos.x, ultimatePos.y) then
							target = nil
							ultimatePos = nil
						end
					end
				end
				if not target or not ultimatePos then
					skill_ultimate.ts = store.tick_ts - ultimate_controller.cooldown + 0.1
				else
					U.animation_start(this, "levelup", nil, store.tick_ts, 1)
					local u = E:create_entity(ultimate_controller)
					u.pos = ultimatePos
					u.level = skill_ultimate.level
					queue_insert(store, u)
					skill_ultimate.ts = store.tick_ts
					while not U.animation_finished(this) do
						if SU.hero_interrupted(this) then
							goto label_90_0
						end
						coroutine.yield()
					end
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.stone_dance

			if not a.disabled and #a.aura.stones == a.aura.max_stones then
				a.ts = store.tick_ts
			end

			if not a.disabled and store.tick_ts - a.ts > a.cooldown and #a.aura.stones < a.aura.max_stones then
				S:queue(a.sound)
				U.animation_start(this, a.animation, nil, store.tick_ts)
				U.y_wait(store, a.hit_time)

				local aura = a.aura

				for i = #a.aura.stones + 1, aura.max_stones do
					local stone = E:create_entity("arivan_stone")
					local angle = i * 2 * math.pi / aura.max_stones % (2 * math.pi)

					stone.pos = U.point_on_ellipse(this.pos, aura.rot_radius, angle)
					stone.render.sprites[1].name = string.format(stone.render.sprites[1].name, i)
					stone.render.sprites[1].ts = store.tick_ts

					queue_insert(store, stone)
					table.insert(aura.stones, stone)
				end

				aura.aura.ts = store.tick_ts

				U.y_animation_wait(this)

				a.ts = store.tick_ts

				goto label_90_0
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.seal_of_fire

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_nearest_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					SU.delay_attack(store, a, 0.26666666666666666)
				else
					local pred_pos = target.pos
					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, a.animations[1], pred_pos)

					U.y_animation_play(this, an, af, store.tick_ts, 1)

					for i = 1, a.loops do
						an, af = U.animation_name_facing_point(this, a.animations[2], pred_pos)

						U.animation_start(this, an, af, store.tick_ts, false)

						for si, st in pairs(a.shoot_times) do
							while st > store.tick_ts - this.render.sprites[1].ts do
								if SU.hero_interrupted(this) then
									goto label_90_0
								end

								coroutine.yield()
							end

							local offset = a.bullet_start_offset[si]
							local b = E:create_entity(a.bullet)

							target = U.find_nearest_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

							if target then
								local dist = V.dist(this.pos.x, this.pos.y + offset.y, target.pos.x, target.pos.y)

								pred_pos = P:predict_enemy_pos(target, dist / b.bullet.min_speed)
							end

							a.ts = store.tick_ts
							b.pos = V.vclone(this.pos)
							b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = V.vclone(pred_pos)
							b.bullet.to.x, b.bullet.to.y = b.bullet.to.x + U.frandom(-1, 1), b.bullet.to.y + U.frandom(-1, 1)
							b.bullet.source_id = this.id
							b.bullet.xp_dest_id = this.id

							queue_insert(store, b)
						end

						while not U.animation_finished(this) do
							if SU.hero_interrupted(this) then
								goto label_90_0
							end

							coroutine.yield()
						end
					end

					SU.hero_gain_xp_from_skill(this, skill)
					U.animation_start(this, a.animations[3], nil, store.tick_ts, false)

					while not U.animation_finished(this) do
						if SU.hero_interrupted(this) then
							break
						end

						coroutine.yield()
					end

					goto label_90_0
				end
			end

			brk, sta = y_hero_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			else
				brk, sta = y_hero_ranged_attacks(store, this)

				if brk then
					-- block empty
				elseif SU.soldier_go_back_step(store, this) then
					-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_90_0::

		coroutine.yield()
	end
end

scripts.fireball_arivan = {}

function scripts.fireball_arivan.insert(this, store)
	local b = this.bullet
end

function scripts.fireball_arivan.update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local target, ps

	S:queue(this.sound_events.summon)
	U.animation_start(this, "idle", nil, store.tick_ts, false)
	U.y_wait(store, this.idle_time)

	ps = E:create_entity(b.particles_name)
	ps.particle_system.track_id = this.id

	queue_insert(store, ps)
	S:queue(this.sound_events.travel)

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > 2 * (mspeed * store.tick_length) do
		coroutine.yield()

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		if ps then
			ps.particle_system.emit_direction = this.render.sprites[1].r
		end
	end

	local targets = U.find_enemies_in_range(store.entities, b.to, 0, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in pairs(targets) do
			local d = E:create_entity("damage")

			d.damage_type = b.damage_type
			d.value = math.ceil(U.frandom(b.damage_min, b.damage_max))
			d.source_id = this.id
			d.target_id = target.id

			queue_damage(store, d)
		end
	end

	S:queue(this.sound_events.hit)

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)

		fx.pos = V.vclone(b.to)
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	coroutine.yield()
	queue_remove(store, this)
end

scripts.aura_arivan_stone_dance = {}

function scripts.aura_arivan_stone_dance.update(this, store)
	local rot_phase = 0
	local owner = store.entities[this.aura.source_id]

	if not owner then
		log.error("aura_arivan_stone_dance owner is missing.")
		queue_remove(store, this)

		return
	end

	while true do
		if owner.health.dead and #this.stones > 1 then
			for i = #this.stones, 1, -1 do
				local stone = this.stones[i]
				local fx = E:create_entity("fx_arivan_stone_explosion")

				fx.pos = stone.pos
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)
				queue_remove(store, stone)
				table.remove(this.stones, i)
			end
		end

		if this.shield_active then
			this.shield_active = false

			local s = this.render.sprites[1]

			s.hidden = false
			s.ts = store.tick_ts
			s.runs = 0
			s.flip_x = owner.render.sprites[1].flip_x
		end

		if store.tick_ts - this.aura.ts > fts(13) then
			rot_phase = rot_phase + this.rot_speed * store.tick_length
		end

		for i, t in ipairs(this.stones) do
			local a = (i * 2 * math.pi / this.max_stones + rot_phase) % (2 * math.pi)

			t.pos = U.point_on_ellipse(this.pos, this.rot_radius, a)
		end

		if #this.stones < 1 then
			owner.vis.bans = band(owner.vis.bans, bnot(this.owner_vis_bans))
		else
			owner.vis.bans = bor(owner.vis.bans, this.owner_vis_bans)
		end

		coroutine.yield()
	end
end

scripts.hero_arivan_ultimate = {}

function scripts.hero_arivan_ultimate.can_fire_fn(this, x, y)
	return P:valid_node_nearby(x, y, nil, NF_TWISTER) and GR:cell_is_only(x, y, TERRAIN_LAND)
end

function scripts.hero_arivan_ultimate.update(this, store)
	local np = this.nav_path
	local nodes_step = this.aura.nodes_step
	local last_freeze_target
	local targets = U.find_enemies_in_paths(store.entities, this.pos, 0, this.aura.range_nodes, nil, this.aura.vis_flags, this.aura.vis_bans, true)

	if targets then
		local o = targets[1].origin

		np.pi, np.spi, np.ni = o[1], 1, o[3] + 3
	else
		local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_TWISTER)

		if #nodes < 1 then
			coroutine.yield()

			goto label_95_1
		end

		local o = nodes[1]

		np.pi, np.spi, np.ni = o[1], 1, o[3]
	end

	this.pos = P:node_pos(np)

	U.y_animation_play(this, "start", nil, store.tick_ts)
	U.animation_start(this, "travel", nil, store.tick_ts, true)

	this.aura.ts = store.tick_ts

	while true do
		local next_pos = P:node_pos(np.pi, np.spi, np.ni + nodes_step)

		if P:is_node_valid(np.pi, np.ni + nodes_step, NF_TWISTER) and band(GR:cell_type(next_pos.x, next_pos.y), TERRAIN_CLIFF) == 0 then
			np.ni = np.ni + nodes_step
		end

		np.spi = np.spi == 2 and 3 or 2

		U.set_destination(this, P:node_pos(np.pi, np.spi, np.ni))

		while not this.motion.arrived do
			if store.tick_ts - this.aura.ts > this.aura.duration or band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_CLIFF) ~= 0 then
				goto label_95_0
			end

			U.walk(this, store.tick_length)

			for ai, a in ipairs(this.timed_attacks.list) do
				if store.tick_ts - a.ts < a.cooldown then
					-- block empty
				else
					a.ts = store.tick_ts

					if a.chance and (a.chance == 0 or math.random() >= a.chance) then
						-- block empty
					else
						local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

						if not targets then
							if ai == 3 then
								last_freeze_target = nil
							end
						elseif ai == 1 then
							for _, target in pairs(targets) do
								local mod = E:create_entity(a.mod)

								mod.modifier.target_id = target.id

								queue_insert(store, mod)
							end
						elseif ai == 2 then
							for _, target in pairs(targets) do
								local d = E:create_entity("damage")

								d.damage_type = a.damage_type
								d.value = a.damage_max
								d.source_id = this.id
								d.target_id = target.id

								queue_damage(store, d)
							end
						elseif ai == 3 then
							local mod = E:create_entity(a.mod)

							mod.modifier.target_id = targets[1].id

							queue_insert(store, mod)

							last_freeze_target = targets[1].id
						elseif a.type == "bullet" then
							if #targets > 1 and last_freeze_target then
								table.removeobject(targets, last_freeze_target)
							end

							local target = table.random(targets)
							local b = E:create_entity(a.bullet)

							b.pos = V.vclone(this.pos)
							b.pos.x = b.pos.x + (target.pos.x > this.pos.x and 1 or -1) * a.bullet_start_offset[1].x
							b.pos.y = b.pos.y + a.bullet_start_offset[1].y
							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
							b.bullet.target_id = target.id
							b.bullet.source_id = this.id

							queue_insert(store, b)
						end
					end
				end
			end

			coroutine.yield()
		end
	end

	::label_95_0::

	U.y_animation_play(this, "end", nil, store.tick_ts)

	::label_95_1::

	queue_remove(store, this)
end

scripts.hero_regson = {}

function scripts.hero_regson.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	for i = 1, 3 do
		this.melee.attacks[i].damage_min = ls.melee_damage_min[hl]
		this.melee.attacks[i].damage_max = ls.melee_damage_max[hl]
	end

	local s

	s = this.hero.skills.blade

	if initial and s.level > 0 then
		this.melee.attacks[4].damage_max = s.damage[s.level] / 2
		this.melee.attacks[4].damage_min = s.damage[s.level] / 2
		this.melee.attacks[5].chance = s.instakill_chance[s.level]
		this.melee.attacks[5].damage_max = s.damage[s.level] / 2
		this.melee.attacks[5].damage_min = s.damage[s.level] / 2
	end

	s = this.hero.skills.heal

	if initial and s.level > 0 then
		local hb = E:get_template("decal_regson_heal_ball")

		hb.hp_factor = s.heal_factor[s.level]
	end

	s = this.hero.skills.path

	if s.level > 0 then
		this.health.hp_max = this.health.hp_max + s.extra_hp[s.level]
	end

	s = this.hero.skills.slash

	if initial and s.level > 0 then
		local a = this.melee.attacks[6]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.damage_max = s.damage_max[s.level]
		m.damage_min = s.damage_min[s.level]
	end

	s = this.hero.skills.ultimate

	if initial then
		local u = E:get_template("hero_regson_ultimate")

		u.cooldown = s.cooldown[s.level]
		u.damage_boss = s.damage_boss[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_regson.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)

	if this.hero.skills.blade.level > 0 then
		local a = E:create_entity("aura_regson_blade")

		a.aura.source_id = this.id
		a.aura.ts = store.tick_ts
		a.pos = this.pos

		queue_insert(store, a)
	end

	if this.hero.skills.heal.level > 0 then
		local a = E:create_entity("aura_regson_heal")

		a.aura.source_id = this.id
		a.aura.ts = store.tick_ts
		a.pos = this.pos

		queue_insert(store, a)
	end

	return true
end

function scripts.hero_regson.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_98_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if this.blade_pending then
				this.blade_pending = nil

				S:queue("ElvesHeroEldritchBladeCharge")
				U.y_animation_play(this, "goBerserk", nil, store.tick_ts, 1)
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			elseif SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_98_0::

		coroutine.yield()
	end
end

scripts.aura_regson_blade = {}

function scripts.aura_regson_blade.update(this, store)
	local hero = store.entities[this.aura.source_id]

	if not hero then
		log.error("hero not found for aura_regson_blade")
		queue_remove(store, this)

		return
	end

	this.blade_ts = store.tick_ts

	while true do
		if this.blade_active and store.tick_ts - this.blade_active_ts > this.blade_duration then
			this.blade_active = false
			this.blade_ts = store.tick_ts

			for i = 1, 3 do
				hero.melee.attacks[i].disabled = nil
			end

			hero.melee.attacks[6].disabled = hero.hero.skills.slash.level < 1

			for i = 4, 5 do
				hero.melee.attacks[i].disabled = true
			end

			hero.idle_flip.animations[1] = "idle"
			hero.render.sprites[1].angles.walk[1] = "run"
		elseif not this.blade_active and U.is_blocked_valid(store, hero) and store.tick_ts - this.blade_ts > this.blade_cooldown then
			hero.blade_pending = true
			this.blade_active = true
			this.blade_active_ts = store.tick_ts

			for i = 1, 3 do
				hero.melee.attacks[i].disabled = true
			end

			hero.melee.attacks[6].disabled = true

			for i = 4, 5 do
				hero.melee.attacks[i].disabled = nil
			end

			hero.idle_flip.animations[1] = "berserk_idle"
			hero.render.sprites[1].angles.walk[1] = "berserk_run"
		end

		coroutine.yield()
	end
end

scripts.aura_regson_heal = {}

function scripts.aura_regson_heal.update(this, store)
	local a = this.aura
	local hero = store.entities[a.source_id]
	local last_ts = store.tick_ts

	if not hero then
		log.error("hero not found for aura_regson_heal")
		queue_remove(store, this)

		return
	end

	while true do
		if not hero.health.dead and store.tick_ts - last_ts >= a.cycle_time then
			last_ts = store.tick_ts

			local targets = U.find_enemies_in_range(store.entities, hero.pos, 0, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, target in pairs(targets) do
					local m = E:create_entity("mod_regson_heal")

					m.modifier.source_id = hero.id
					m.modifier.target_id = target.id

					queue_insert(store, m)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.mod_regson_heal = {}

function scripts.mod_regson_heal.update(this, store)
	this.modifier.ts = store.tick_ts

	while true do
		local target = store.entities[this.modifier.target_id]

		if not target or store.tick_ts - this.modifier.ts > this.modifier.duration then
			break
		end

		if target.health.dead and not U.flag_has(target.health.last_damage_types, DAMAGE_NO_LIFESTEAL) then
			local s = E:create_entity("decal_regson_heal_ball")

			s.target_id = this.modifier.source_id
			s.source_id = target.id
			s.source_hp = target.health.hp_max

			queue_insert(store, s)

			break
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.decal_regson_heal_ball = {}

function scripts.decal_regson_heal_ball.update(this, store)
	local sp = this.render.sprites[1]
	local fm = this.force_motion
	local source = store.entities[this.source_id]
	local hero = store.entities[this.target_id]
	local initial_pos, initial_dest
	local initial_h = 0
	local dest_h = hero.unit.hit_offset.y
	local max_dist
	local last_pos = V.v(0, 0)

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)

		max_dist = math.max(dist, max_dist)

		local phase = km.clamp(0, 1, 1 - dist / max_dist)
		local df = (not fm.ramp_radius or dist > fm.ramp_radius) and 1 or math.max(dist / fm.ramp_radius, 0.1)

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step * df, dx, dy)))
		fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
		fm.v.x, fm.v.y = V.trim(fm.max_v, fm.v.x, fm.v.y)

		local sx, sy = V.mul(store.tick_length, fm.v.x, fm.v.y)

		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
		fm.a.x, fm.a.y = V.mul(-0.05 / store.tick_length, fm.v.x, fm.v.y)
		sp.offset.y = SU.parabola_y(phase, initial_h, dest_h, fm.max_flight_height)
		sp.r = V.angleTo(this.pos.x - last_pos.x, this.pos.y + sp.offset.y - last_pos.y)
		last_pos.x, last_pos.y = this.pos.x, this.pos.y + sp.offset.y

		return dist < 2 * fm.max_v * store.tick_length
	end

	if not source or not hero then
		log.debug("source or hero entity not found for decal_regson_heal_ball")
	else
		sp.hidden = true
		this.pos.x, this.pos.y = source.pos.x, source.pos.y

		if source.unit and source.unit.hit_offset then
			initial_h = source.unit.hit_offset.y
		end

		do
			local fx = E:create_entity("fx_regson_heal_ball_spawn")

			fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
			fx.render.sprites[1].offset.y = initial_h
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)
		end

		U.y_wait(store, fts(10))

		sp.hidden = nil
		this.dest = hero.pos
		initial_pos = V.vclone(this.pos)
		initial_dest = V.vclone(hero.pos)
		initial_h = initial_h + 18
		fm.a.x, fm.a.y = 0, 2.5
		last_pos.x, last_pos.y = this.pos.x, this.pos.y + sp.offset.y
		max_dist = V.len(initial_dest.x - initial_pos.x, initial_dest.y - initial_pos.y)

		while not hero.health.dead and not move_step(this.dest) do
			coroutine.yield()
		end

		if not hero.health.dead then
			hero.health.hp = km.clamp(0, hero.health.hp_max, hero.health.hp + this.source_hp * this.hp_factor)

			local fx = E:create_entity("fx_regson_heal")

			fx.pos = hero.pos
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].offset = hero.unit.mod_offset

			queue_insert(store, fx)
		end
	end

	queue_remove(store, this)
end

scripts.mod_regson_slash = {}

function scripts.mod_regson_slash.update(this, store)
	local m = this.modifier
	local sp = this.render.sprites[1]
	local target = store.entities[m.target_id]

	if not target or not target.pos or target.health.dead then
		queue_remove(store, this)

		return
	end

	sp.hidden = true
	m.ts = store.tick_ts
	this.pos = target.pos

	if target.unit and target.unit.mod_offset then
		sp.offset.x, sp.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y + 5
		sp.flip_x = not target.render.sprites[1].flip_x
	end

	local delay = (m.target_idx or 0) * this.delay_per_idx

	U.y_wait(store, delay)

	sp.hidden = nil

	U.animation_start(this, this.name, nil, store.tick_ts)
	U.y_wait(store, this.hit_time)

	local d = E:create_entity("damage")

	d.source_id = this.id
	d.target_id = target.id
	d.damage_type = this.damage_type
	d.value = math.random(this.damage_min, this.damage_max)

	queue_damage(store, d)
	U.y_animation_wait(this)
	queue_remove(store, this)
end

scripts.hero_regson_ultimate = {}

function scripts.hero_regson_ultimate.can_fire_fn(this, x, y, store)
	for _, e in pairs(store.entities) do
		if e.pos and e.ui and e.ui.can_click and e.enemy and e.vis and e.nav_path and e.health and not e.health.dead and band(e.vis.flags, this.vis_bans) == 0 and band(e.vis.bans, this.vis_flags) == 0 and U.is_inside_ellipse(V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y), V.v(x, y), this.range) and P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_POWER_1) then
			return true
		end
	end

	return false
end

function scripts.hero_regson_ultimate.update(this, store)
	local is_boss
	local sp = this.render.sprites[1]
	local targets = table.filter(store.entities, function(_, e)
		return e.pos and e.ui and e.ui.can_click and e.enemy and e.vis and e.nav_path and e.health and not e.health.dead and band(e.vis.flags, this.vis_bans) == 0 and band(e.vis.bans, this.vis_flags) == 0 and U.is_inside_ellipse(V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y), V.v(this.pos.x, this.pos.y), this.range) and P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_POWER_1)
	end)

	table.sort(targets, function(e1, e2)
		return V.dist(e1.pos.x + e1.unit.hit_offset.x, e1.pos.y + e1.unit.hit_offset.y, this.pos.x, this.pos.y) < V.dist(e2.pos.x + e2.unit.hit_offset.x, e2.pos.y + e2.unit.hit_offset.y, this.pos.x, this.pos.y)
	end)

	local target = targets[1]

	if not target then
		-- block empty
	else
		is_boss = band(target.vis.flags, F_BOSS) ~= 0

		if not is_boss then
			this._target_prev_bans = target.vis.bans
			target.vis.bans = F_ALL
		end

		SU.stun_inc(target)

		this.pos = target.pos
		sp.offset.x, sp.offset.y = target.unit.hit_offset.x, target.unit.hit_offset.y

		U.animation_start(this, sp.name, nil, store.tick_ts)
		U.y_wait(store, this.hit_time)

		do
			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = target.id

			if is_boss then
				d.damage_type = DAMAGE_TRUE
				d.value = this.damage_boss
			else
				d.damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_FX_NOT_EXPLODE)
			end

			queue_damage(store, d)
		end

		U.y_animation_wait(this)
		SU.stun_dec(target)

		if not is_boss then
			target.vis.bans = this._target_prev_bans
		end
	end

	queue_remove(store, this)
end

scripts.hero_faustus = {}

function scripts.hero_faustus.get_info(this)
	local m = E:get_template("bolt_faustus")
	local min, max = 3 * m.bullet.damage_min, 3 * m.bullet.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_type = DAMAGE_MAGICAL,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_faustus.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	local s

	s = this.hero.skills.dragon_lance

	if initial and s.level > 0 then
		local a = this.ranged.attacks[2]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.damage_max = s.damage_max[s.level]
		b.bullet.damage_min = s.damage_min[s.level]
	end

	s = this.hero.skills.teleport_rune

	if initial and s.level > 0 then
		local a = this.ranged.attacks[3]

		a.disabled = nil

		local aura = E:get_template(a.bullet)

		aura.aura.targets_per_cycle = s.max_targets[s.level]
	end

	s = this.hero.skills.enervation

	if initial and s.level > 0 then
		local a = this.ranged.attacks[4]

		a.disabled = nil

		local aura = E:get_template(a.bullet)

		aura.aura.targets_per_cycle = s.max_targets[s.level]

		local mod = E:get_template(aura.aura.mod)

		mod.modifier.duration = s.duration[s.level]
	end

	s = this.hero.skills.liquid_fire

	if initial and s.level > 0 then
		local a = this.ranged.attacks[5]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.flames_count = s.flames_count[s.level]

		local m = E:get_template("mod_liquid_fire_faustus")

		m.dps.damage_max = s.mod_damage[s.level]
		m.dps.damage_min = s.mod_damage[s.level]
	end

	s = this.hero.skills.ultimate

	if initial then
		local m = E:get_template("mod_minidragon_faustus")

		m.dps.damage_max = s.mod_damage[s.level]
		m.dps.damage_min = s.mod_damage[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_faustus.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

function scripts.hero_faustus.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			-- block empty
		end

		for _, i in pairs(this.ranged.order) do
			local a = this.ranged.attacks[i]

			if a.disabled then
				-- block empty
			elseif a.sync_animation and not this.render.sprites[1].sync_flag then
				-- block empty
			elseif store.tick_ts - a.ts < a.cooldown then
				-- block empty
			else
				local bullet_t = E:get_template(a.bullet)
				local flight_time = a.estimated_flight_time or 1
				local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(e)
					if U.flag_has(a.vis_flags, F_SPELLCASTER) and (not U.flag_has(e.vis.flags, F_SPELLCASTER) or not e.enemy.can_do_magic) then
						log.debug("filtering (%s)%s", e.id, e.template_name)

						return false
					end

					if a.target_offset_rect then
						local node_offset = P:predict_enemy_node_advance(e, a.shoot_time + flight_time)
						local e_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni + node_offset)
						local is_inside = V.is_inside(V.v(math.abs(e_pos.x - this.pos.x), e_pos.y - this.pos.y), a.target_offset_rect)

						if not is_inside then
							return false
						end

						if a.max_count_range and a.min_count then
							local min_count_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni - a.min_count_nodes_offset)
							local nearby = U.find_enemies_in_range(store.entities, min_count_pos, 0, a.max_count_range, a.vis_flags, a.vis_bans)

							return nearby and #nearby >= a.min_count
						end

						return true
					else
						return true
					end
				end)

				if target then
					local start_ts = store.tick_ts
					local start_fx, b, targets
					local node_offset = P:predict_enemy_node_advance(target, flight_time)
					local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
					local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

					U.animation_start(this, an, af, store.tick_ts)
					S:queue(a.start_sound, a.start_sound_args)

					if a.start_fx then
						local fx = E:create_entity(a.start_fx)

						fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
						fx.render.sprites[1].ts = store.tick_ts
						fx.render.sprites[1].flip_x = af

						queue_insert(store, fx)

						start_fx = fx
					end

					while store.tick_ts - start_ts < a.shoot_time do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_112_0
						end

						coroutine.yield()
					end

					S:queue(a.sound)

					targets = {}

					if a.bullet_count then
						local extra_targets = U.find_enemies_in_range(store.entities, target.pos, 0, a.extra_range, a.vis_flags, a.vis_bans, function(e)
							return af and e.pos.x <= this.pos.x or e.pos.x >= this.pos.x
						end)

						if not extra_targets then
							goto label_112_0
						end

						for i = 1, a.bullet_count do
							table.insert(targets, extra_targets[km.zmod(i, #extra_targets)])
						end
					else
						targets = {
							target
						}
					end

					for i, t in ipairs(targets) do
						b = E:create_entity(a.bullet)

						if a.type == "aura" then
							b.pos.x, b.pos.y = target.pos.x, target.pos.y
							b.aura.ts = store.tick_ts
						else
							b.bullet.target_id = t.id
							b.bullet.source_id = this.id
							b.bullet.xp_dest_id = this.id
							b.pos = V.vclone(this.pos)
							b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
							b.pos.y = b.pos.y + a.bullet_start_offset[ai].y
							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = V.v(t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y)
							b.bullet.shot_index = i

							if i == 1 then
								b.initial_impulse = 0
							end
						end

						queue_insert(store, b)
					end

					if a.xp_from_skill then
						SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
					end

					a.ts = start_ts

					while not U.animation_finished(this) do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_112_0
						end

						coroutine.yield()
					end

					a.ts = start_ts

					U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

					::label_112_0::

					if start_fx then
						start_fx.render.sprites[1].hidden = true
					end

					goto label_112_1
				end
			end
		end

		SU.soldier_idle(store, this)
		SU.soldier_regen(store, this)

		::label_112_1::

		coroutine.yield()
	end
end

scripts.hero_faustus_ultimate = {}

function scripts.hero_faustus_ultimate.can_fire_fn(this, x, y, store)
	return not GR:cell_is(x, y, TERRAIN_FAERIE) and P:valid_node_nearby(x, y, 1.4285714285714286, NF_POWER_3)
end

function scripts.hero_faustus_ultimate.update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

	if #nodes < 1 then
		log.error("hero_faustus_ultimate: could not find valid node")
		queue_remove(store, this)

		return
	end

	local node = {
		spi = 1,
		pi = nodes[1][1],
		ni = nodes[1][3]
	}
	local node_offsets = {
		0,
		-this.separation_nodes,
		this.separation_nodes
	}
	local node_pos = P:node_pos(node.pi, node.spi, node.ni)
	local from_y = node_pos.y

	for i = 1, 3 do
		if P:is_node_valid(node.pi, node.ni + node_offsets[i]) then
			node_pos = P:node_pos(node.pi, node.spi, node.ni + node_offsets[i])
			from_y = node_pos.y
		end

		local e = E:create_entity("decal_minidragon_faustus")

		e.attack_pos = node_pos
		e.pos.x, e.pos.y = i % 2 == 0 and 2 * REF_W or -REF_W, from_y

		queue_insert(store, e)
		U.y_wait(store, this.show_delay)
	end

	queue_remove(store, this)
end

scripts.decal_minidragon_faustus = {}

function scripts.decal_minidragon_faustus.update(this, store)
	local a = this.attacks.list[1]
	local af = this.pos.x > this.attack_pos.x
	local emit_angle = math.pi / 8
	local loop_duration = fts(18)
	local vx = this.motion.max_speed
	local attack_w = loop_duration * vx
	local emit_x = this.attack_pos.x + (af and 1 or -1) * (attack_w / 2 + this.emit_ox)
	local cast_x = this.attack_pos.x + (af and 1 or -1) * (attack_w / 2 + this.cast_ox)
	local emit_ts, cast_ts, emitting, casting
	local dest = V.v(0, this.pos.y)

	if af then
		this.pos.x = emit_x + math.ceil((store.visible_coords.right - emit_x + this.image_w) / attack_w) * attack_w
		dest.x = store.visible_coords.left - this.image_w
	else
		this.pos.x = emit_x - math.ceil((emit_x - store.visible_coords.left + this.image_w) / attack_w) * attack_w
		dest.x = store.visible_coords.right + this.image_w
	end

	local ps = E:create_entity("ps_minidragon_faustus_fire")

	ps.particle_system.track_id = this.id
	ps.particle_system.emit_direction = af and math.pi + emit_angle or -emit_angle
	ps.particle_system.emit_offset = V.v(a.bullet_start_offset.x * (af and -1 or 1), a.bullet_start_offset.y)
	ps.particle_system.emit = false

	queue_insert(store, ps)
	U.set_destination(this, dest)
	U.animation_start(this, "idle", af, store.tick_ts, true, nil, true)

	while not this.motion.arrived do
		if not emit_ts and (af and emit_x >= this.pos.x or not af and emit_x <= this.pos.x) then
			S:queue(a.sound)
			U.animation_start(this, "fire", nil, store.tick_ts, false, 2)

			ps.particle_system.emit = true
			emit_ts = store.tick_ts
			emitting = true
		end

		if not cast_ts and (af and cast_x >= this.pos.x or not af and cast_x <= this.pos.x) then
			a.disabled = nil
			a.ts = store.tick_ts - a.cooldown
			cast_ts = store.tick_ts
			casting = true
		end

		if emitting and loop_duration < store.tick_ts - emit_ts then
			U.animation_start(this, "idle", nil, store.tick_ts, false, 2)

			ps.particle_system.emit = false
			emitting = false
		end

		if casting and loop_duration < store.tick_ts - cast_ts then
			a.disabled = true
			casting = false
		end

		if casting and store.tick_ts - a.ts > a.cooldown then
			local o_x = (af and -1 or 1) * this.cast_ox
			local o_y = table.random({
				-10,
				-5,
				5,
				10
			})
			local e = E:create_entity(a.bullet)

			e.pos.x, e.pos.y = this.pos.x + o_x, this.pos.y + o_y
			e.aura.ts = store.tick_ts

			queue_insert(store, e)

			a.ts = store.tick_ts
		end

		U.walk(this, store.tick_length)
		coroutine.yield()
	end

	queue_remove(store, ps)
	queue_remove(store, this)
end

scripts.hero_bravebark = {}

function scripts.hero_bravebark.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local s

	s = this.hero.skills.rootspikes

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.ts = store.tick_ts
		a.damage_max = s.damage_max[s.level]
		a.damage_min = s.damage_min[s.level]
	end

	s = this.hero.skills.oakseeds

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.ts = store.tick_ts

		local st = E:get_template(a.entity)

		st.health.hp_max = s.soldier_hp_max[s.level]
		st.melee.attacks[1].damage_max = s.soldier_damage_max[s.level]
		st.melee.attacks[1].damage_min = s.soldier_damage_min[s.level]
	end

	s = this.hero.skills.branchball

	if initial and s.level > 0 then
		local a = this.melee.attacks[2]

		a.hp_max = s.hp_max[s.level]
		a.disabled = nil
		a.ts = store.tick_ts
	end

	s = this.hero.skills.springsap

	if initial and s.level > 0 then
		local a = this.springsap

		a.disabled = nil
		a.ts = store.tick_ts

		local aura = E:get_template(a.aura)

		aura.aura.duration = s.duration[s.level]

		local mod = E:get_template(aura.aura.mod)

		mod.hps.heal_min = s.hp_per_cycle[s.level]
		mod.hps.heal_max = s.hp_per_cycle[s.level]
	end

	s = this.hero.skills.ultimate

	if initial then
		local u = E:get_template("hero_bravebark_ultimate")

		u.count = s.count[s.level]
		u.damage = s.damage[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_bravebark.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	local function spawn_spikes(count, center, radius, angle, delay, scale)
		for i = 1, count do
			local p = U.point_on_ellipse(center, radius - math.random(0, 5), angle + i * 2 * math.pi / count)
			local e = E:create_entity("decal_bravebark_rootspike")

			e.pos.x, e.pos.y = p.x, p.y
			e.delay = delay
			e.scale = scale

			queue_insert(store, e)
		end
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_119_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.springsap
			skill = this.hero.skills.springsap

			if not a.disabled and store.tick_ts - a.ts > a.cooldown and this.health.hp < this.health.hp_max * a.trigger_hp_factor then
				a.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, skill)
				S:queue(a.sound)
				U.y_animation_play(this, a.animations[1], nil, store.tick_ts)

				local aura = E:create_entity(a.aura)

				aura.pos.x, aura.pos.y = this.pos.x, this.pos.y
				aura.tween.ts = store.tick_ts

				queue_insert(store, aura)
				U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

				while store.tick_ts - a.ts <= aura.aura.duration do
					if SU.hero_interrupted(this) then
						queue_remove(store, aura)

						break
					end

					coroutine.yield()
				end

				U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

				a.ts = store.tick_ts

				goto label_119_0
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.oakseeds

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_foremost_enemy(store.entities, this.pos, 0, a.max_range, 0.5, a.vis_flags, a.vis_bans)

				if not target then
					SU.delay_attack(store, a, 0.3333333333333333)
				else
					local node_offset = P:predict_enemy_node_advance(target, 0.5)
					local ni = target.nav_path.ni + node_offset

					S:queue(a.sound)

					local af = target.pos.x < this.pos.x

					U.animation_start(this, a.animation, af, store.tick_ts)

					if U.y_wait(store, a.spawn_time, function()
						return SU.hero_interrupted(this)
					end) then
						-- block empty
					else
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						for i = 1, a.count do
							ni = ni + math.random(4, 6)

							if not P:is_node_valid(target.nav_path.pi, ni) then
								-- block empty
							else
								local e = E:create_entity(a.entity)

								e.pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, ni)
								e.nav_rally.center = V.vclone(e.pos)
								e.nav_rally.pos = V.vclone(e.pos)
								e.melee.attacks[1].xp_dest_id = this.id

								local b = E:create_entity(a.bullet)

								b.pos.x, b.pos.y = this.pos.x + (af and -1 or 1) * a.spawn_offset.x, this.pos.y + a.spawn_offset.y
								b.bullet.from = V.vclone(b.pos)
								b.bullet.to = V.vclone(e.pos)
								b.bullet.hit_payload = e

								queue_insert(store, b)
							end
						end

						SU.y_hero_animation_wait(this)

						goto label_119_0
					end
				end
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.rootspikes

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local triggers = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

				if not triggers or #triggers < a.trigger_count then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					S:queue(a.sound)

					local af = triggers[1].pos.x < this.pos.x

					U.animation_start(this, a.animation, af, store.tick_ts)

					if U.y_wait(store, a.hit_time, function()
						return SU.hero_interrupted(this)
					end) then
						-- block empty
					else
						local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius, a.vis_flags, a.vis_bans)

						if not targets then
							-- block empty
						else
							a.ts = store.tick_ts

							SU.hero_gain_xp_from_skill(this, skill)

							local tpos = V.vclone(targets[1].pos)
							local hit_center = V.v(this.pos.x + a.hit_offset.x * (af and -1 or 1), this.pos.y + a.hit_offset.y)
							local decal = E:create_entity(a.hit_decal)

							decal.pos.x, decal.pos.y = hit_center.x, hit_center.y
							decal.tween.ts = store.tick_ts

							queue_insert(store, decal)
							spawn_spikes(7, hit_center, a.decal_range / 2, 0, 0, 1)
							spawn_spikes(9, hit_center, a.decal_range / 1.25, 0, 0.07, 0.75)
							spawn_spikes(13, hit_center, a.decal_range, math.pi * 2 / 26, 0.17, 0.5)

							for _, target in pairs(targets) do
								local d = SU.create_attack_damage(a, target.id, this.id)

								queue_damage(store, d)
							end

							SU.y_hero_animation_wait(this)

							goto label_119_0
						end
					end
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			elseif SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_119_0::

		coroutine.yield()
	end
end

scripts.hero_bravebark_ultimate = {}

function scripts.hero_bravebark_ultimate.can_fire_fn(this, x, y, store)
	return not GR:cell_is(x, y, TERRAIN_FAERIE) and P:valid_node_nearby(x, y, 1.4285714285714286, NF_POWER_3)
end

function scripts.hero_bravebark_ultimate.update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

	if #nodes < 1 then
		log.error("hero_bravebark_ultimate: could not find valid node")
		queue_remove(store, this)

		return
	end

	local node_f = {
		pi = nodes[1][1],
		spi = math.random(1, 3),
		ni = nodes[1][3]
	}
	local node_b = {
		pi = nodes[1][1],
		spi = math.random(1, 3),
		ni = nodes[1][3]
	}
	local count = this.count
	local dir = 1
	local node

	for i = 1, 2 * count do
		node = dir == 1 and node_f or node_b

		local node_pos = P:node_pos(node.pi, node.spi, node.ni)

		if P:is_node_valid(node.pi, node.ni) and not GR:cell_is(node_pos.x, node_pos.y, TERRAIN_FAERIE) then
			local nni = node.ni + dir * math.random(this.sep_nodes_min, this.sep_nodes_max - 1)
			local nspi = km.zmod(node.spi + math.random(1, 2), 3)

			node.spi, node.ni = nspi, nni

			local e = E:create_entity(this.decal)

			e.render.sprites[1].prefix = e.render.sprites[1].prefix .. math.random(1, 3)
			e.pos = node_pos
			e.render.sprites[1].ts = store.tick_ts

			queue_insert(store, e)

			local targets = U.find_enemies_in_range(store.entities, e.pos, 0, this.damage_radius, this.vis_flags, this.vis_bans)

			if targets then
				for _, target in pairs(targets) do
					local m = E:create_entity(this.mod)

					m.modifier.target_id = target.id
					m.modifier.source_id = this.id

					queue_insert(store, m)

					local d = E:create_entity("damage")

					d.value = this.damage
					d.source_id = this.id
					d.target_id = target.id

					queue_damage(store, d)
				end
			end

			if count % 2 == 0 then
				U.y_wait(store, U.frandom(this.show_delay_min, this.show_delay_max))
			end

			count = count - 1
		end

		if count <= 0 then
			break
		end

		dir = -1 * dir
	end

	queue_remove(store, this)
end

scripts.hero_xin = {}

function scripts.hero_xin.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	local s

	s = this.hero.skills.daring_strike

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.ts = store.tick_ts
		a.damage_max = s.damage_max[s.level]
		a.damage_min = s.damage_min[s.level]
	end

	s = this.hero.skills.inspire

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.ts = store.tick_ts

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
	end

	s = this.hero.skills.mind_over_body

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.ts = store.tick_ts

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
		m.hps.heal_every = s.heal_every[s.level]
		m.hps.heal_min = s.heal_hp[s.level]
		m.hps.heal_max = s.heal_hp[s.level]
	end

	s = this.hero.skills.panda_style

	if initial and s.level > 0 then
		local a = this.melee.attacks[3]

		a.disabled = nil
		a.ts = store.tick_ts
		a.damage_max = s.damage_max[s.level]
		a.damage_min = s.damage_min[s.level]
	end

	s = this.hero.skills.ultimate

	if initial then
		local u = E:get_template("hero_xin_ultimate")

		u.count = s.count[s.level]

		local e = E:get_template(u.entity)

		for _, ma in pairs(e.melee.attacks) do
			ma.damage_max = s.damage[s.level]
			ma.damage_min = s.damage[s.level]
		end
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_xin.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_126_1
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.mind_over_body

			if not a.disabled and this.health.hp / this.health.hp_max <= a.min_health_factor and store.tick_ts - a.ts > a.cooldown then
				SU.hero_gain_xp_from_skill(this, skill)
				U.animation_start(this, a.animation, nil, store.tick_ts)
				U.y_wait(store, a.cast_time)
				S:queue(a.sound)
				SU.insert_sprite(store, "decal_xin_drink_circle", this.pos)

				local mod = E:create_entity(a.mod)

				mod.modifier.target_id = this.id
				mod.modifier.source_id = this.id

				queue_insert(store, mod)
				U.y_animation_wait(this)

				a.ts = store.tick_ts
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.inspire

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local soldiers = U.find_soldiers_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
					return e.id ~= this.id
				end)
				local enemies = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

				if not soldiers or #soldiers < a.min_count or not enemies then
					SU.delay_attack(store, a, 0.3333333333333333)
				else
					U.animation_start(this, a.animation, nil, store.tick_ts)
					U.y_wait(store, a.cast_time)
					S:queue(a.sound)
					SU.insert_sprite(store, "decal_xin_inspire", this.pos)

					for i = 1, math.min(#soldiers, a.max_count) do
						local soldier = soldiers[i]
						local m = E:create_entity(a.mod)

						m.modifier.target_id = soldier.id
						m.modifier.source_id = this.id
						m.modifier.ts = store.tick_ts

						queue_insert(store, m)
					end

					U.y_animation_wait(this)
					SU.hero_gain_xp_from_skill(this, skill)

					a.ts = store.tick_ts
				end
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.daring_strike

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local blocked_enemy = this.soldier.target_id and store.entities[this.soldier.target_id]

				if not blocked_enemy and SU.soldier_pick_melee_target(store, this) then
					SU.delay_attack(store, a, 0.3333333333333333)

					goto label_126_0
				end

				local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(e)
					local ni_s = P:get_visible_start_node(e.nav_path.pi)
					local ni_e = P:get_visible_end_node(e.nav_path.pi)

					return e ~= blocked_enemy and e.nav_path.ni > ni_s + a.node_margin and e.nav_path.ni < ni_e - a.node_margin
				end)

				if not targets then
					SU.delay_attack(store, a, 0.3333333333333333)

					goto label_126_0
				end

				table.sort(targets, function(e1, e2)
					return e1.health.hp > e2.health.hp
				end)

				local target = targets[1]
				local initial_pos = V.vclone(this.pos)
				local initial_flip = this.render.sprites[1].flip_x
				local _bans = this.vis.bans
				local shadow

				this.vis.bans = F_ALL
				this.health.ignore_damage = true

				S:queue(a.sounds[1])
				U.animation_start(this, a.animations[1], nil, store.tick_ts)
				SU.insert_sprite(store, "fx_xin_smoke_teleport_out", this.pos, initial_flip)
				U.y_wait(store, fts(14))

				this.health_bar.hidden = true

				U.y_wait(store, fts(3))

				if U.is_blocked_valid(store, this) then
					local blocked = store.entities[this.soldier.target_id]
					local m = E:create_entity("mod_xin_stun")

					m.modifier.target_id = blocked.id
					m.modifier.source_id = this.id

					queue_insert(store, m)

					shadow = E:create_entity("soldier_xin_shadow")
					shadow.pos.x, shadow.pos.y = this.pos.x, this.pos.y
					shadow.nav_rally.center = V.vclone(this.pos)
					shadow.nav_rally.pos = V.vclone(this.pos)
					shadow.render.sprites[1].flip_x = this.render.sprites[1].flip_x

					queue_insert(store, shadow)
					U.replace_blocker(store, this, shadow)
				end

				U.y_animation_wait(this)

				local m = E:create_entity("mod_xin_stun")

				m.modifier.target_id = target.id
				m.modifier.source_id = this.id

				queue_insert(store, m)

				local lpos, lflip = U.melee_slot_position(this, target, 2)

				this.pos.x, this.pos.y = lpos.x, lpos.y

				U.animation_start(this, a.animations[2], lflip, store.tick_ts)
				SU.insert_sprite(store, "fx_xin_smoke_teleport_hit", this.pos, lflip)
				U.y_wait(store, fts(5))
				S:queue(a.sounds[2])

				this.health_bar.hidden = nil

				queue_damage(store, SU.create_attack_damage(a, target.id, this.id))
				U.y_animation_wait(this)

				if target and not target.health.dead then
					U.animation_start(this, a.animations[3], lflip, store.tick_ts)
					queue_damage(store, SU.create_attack_damage(a, target.id, this.id))
					U.y_animation_wait(this)
				end

				this.health_bar.hidden = true

				U.animation_start(this, a.animations[4], lflip, store.tick_ts)
				SU.insert_sprite(store, "fx_xin_smoke_teleport_hit_out", this.pos, lflip)
				U.y_animation_wait(this)

				if this.nav_rally.new then
					this.nav_rally.new = false
					this.pos.x, this.pos.y = this.nav_rally.pos.x, this.nav_rally.pos.y
				else
					this.pos.x, this.pos.y = initial_pos.x, initial_pos.y
				end

				S:queue(a.sounds[5])
				U.animation_start(this, a.animations[5], initial_flip, store.tick_ts)
				SU.insert_sprite(store, "fx_xin_smoke_teleport_in", this.pos, initial_flip)

				if shadow then
					shadow.health.dead = true

					U.replace_blocker(store, shadow, this)
				end

				U.y_wait(store, fts(5))

				this.health_bar.hidden = nil
				this.vis.bans = _bans
				this.health.ignore_damage = nil

				U.y_animation_wait(this)
				SU.hero_gain_xp_from_skill(this, skill)

				a.ts = store.tick_ts
			end

			::label_126_0::

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			elseif SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_126_1::

		coroutine.yield()
	end
end

scripts.hero_xin_ultimate = {}

function scripts.hero_xin_ultimate.can_fire_fn(this, x, y, store)
	return not GR:cell_is(x, y, TERRAIN_FAERIE) and P:valid_node_nearby(x, y, 1, NF_POWER_3)
end

function scripts.hero_xin_ultimate.update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

	if #nodes < 1 then
		log.error("hero_xin_ultimate: could not find valid node")
		queue_remove(store, this)

		return
	end

	local node = {
		spi = 1,
		pi = nodes[1][1],
		ni = nodes[1][3]
	}
	local node_pos = P:node_pos(node)
	local count = this.count
	local target, targets = U.find_foremost_enemy(store.entities, this.pos, 0, this.range, fts(10), this.vis_flags, this.vis_bans)
	local idx = 1

	while count > 0 do
		local e = E:create_entity(this.entity)

		if targets then
			target = targets[km.zmod(idx, #targets)]
			idx = idx + 1

			if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, F_BOSS) == 0 then
				local m = E:create_entity("mod_xin_stun")

				m.modifier.target_id = target.id
				m.modifier.source_id = this.id

				queue_insert(store, m)
			end

			if band(target.vis.flags, F_BLOCK) ~= 0 then
				U.block_enemy(store, e, target)
			else
				e.unblocked_target_id = target.id
			end

			local lpos, lflip = U.melee_slot_position(e, target, 1)

			e.pos.x, e.pos.y = lpos.x, lpos.y
			e.render.sprites[1].flip_x = lflip
		else
			local nni = node.ni + math.random(-10, 10)
			local nspi = math.random(1, 3)
			local npos = P:node_pos(node.pi, nspi, nni)

			if not P:is_node_valid(node.pi, nni) or GR:cell_is(node_pos.x, node_pos.y, TERRAIN_FAERIE) then
				npos = node_pos
			end

			e.pos.x, e.pos.y = npos.x, npos.y
		end

		e.nav_rally.center = V.vclone(e.pos)
		e.nav_rally.pos = V.vclone(e.pos)

		queue_insert(store, e)

		count = count - 1

		U.y_wait(store, this.spawn_delay)
	end

	queue_remove(store, this)
end

scripts.hero_catha = {}

function scripts.hero_catha.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]
	bt = E:get_template("knife_soldier_catha")
	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	local s

	s = this.hero.skills.soul

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.hps.heal_min = s.heal_hp[s.level]
		m.hps.heal_max = s.heal_hp[s.level]
	end

	s = this.hero.skills.tale

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.max_count = s.max_count[s.level]

		local e = E:get_template(a.entity)

		e.health.hp_max = s.hp_max[s.level]
	end

	s = this.hero.skills.fury

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		local b = E:get_template("catha_fury")

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end

	s = this.hero.skills.curse

	if initial and s.level > 0 then
		local m = E:get_template("mod_catha_curse")

		m.chance = s.chance[s.level]
		m.modifier.duration = s.duration[s.level]
		this.melee.attacks[1].mod = "mod_catha_curse"

		local b = E:get_template("catha_fury")

		b.bullet.mod = "mod_catha_curse"

		local b = E:get_template("knife_catha")

		b.bullet.mod = "mod_catha_curse"

		local m = E:get_template("mod_soldier_catha_curse")

		m.chance = s.chance[s.level] * s.chance_factor_tale
		m.modifier.duration = s.duration[s.level]

		local b = E:get_template("knife_soldier_catha")

		b.bullet.mod = "mod_soldier_catha_curse"
	end

	s = this.hero.skills.ultimate

	if initial then
		local u = E:get_template("hero_catha_ultimate")

		u.duration = s.duration[s.level]
		u.duration_boss = s.duration_boss[s.level]
		u.range = s.range[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_catha.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_133_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.fury

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets then
					SU.delay_attack(store, a, 0.3333333333333333)
				else
					S:queue(a.sound)
					U.animation_start(this, a.animation, nil, store.tick_ts)

					if U.y_wait(store, a.shoot_time, function()
						return SU.hero_interrupted(this)
					end) then
						-- block empty
					else
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

						if targets then
							for i = 1, skill.count[skill.level] do
								local target = table.random(targets)
								local b = E:create_entity(a.bullet)

								b.pos.x, b.pos.y = this.pos.x, this.pos.y
								b.bullet.target_id = target.id
								b.bullet.source_id = this.id
								b.bullet.level = a.level

								queue_insert(store, b)
							end
						end

						SU.y_hero_animation_wait(this)

						a.ts = store.tick_ts

						goto label_133_0
					end
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.soul

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
					return e.health.hp / e.health.hp_max < a.max_hp_factor and not table.contains(a.excluded_templates, e.template_name)
				end)

				if not targets then
					SU.delay_attack(store, a, 0.3333333333333333)
				else
					S:queue(a.sound)
					U.animation_start(this, a.animation, nil, store.tick_ts)

					if U.y_wait(store, a.shoot_time, function()
						return SU.hero_interrupted(this)
					end) then
						-- block empty
					else
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
							return not table.contains(a.excluded_templates, e.template_name)
						end)

						if targets then
							table.sort(targets, function(e1, e2)
								return e1.health.hp < e2.health.hp
							end)

							for i = 1, math.min(#targets, a.max_count) do
								local target = targets[i]
								local m = E:create_entity(a.mod)

								m.modifier.source_id = this.id
								m.modifier.target_id = target.id

								queue_insert(store, m)
							end
						end

						local fx = E:create_entity(a.shoot_fx)

						fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
						fx.render.sprites[1].ts = store.tick_ts

						queue_insert(store, fx)
						SU.y_hero_animation_wait(this)

						a.ts = store.tick_ts

						goto label_133_0
					end
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.tale

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

				if not targets then
					SU.delay_attack(store, a, 0.3333333333333333)
				else
					S:queue(a.sound, a.sound_args)
					U.animation_start(this, a.animation, nil, store.tick_ts)

					if U.y_wait(store, a.spawn_time, function()
						return SU.hero_interrupted(this)
					end) then
						-- block empty
					else
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						for i = 1, a.max_count do
							local o = a.entity_offsets[i]
							local e = E:create_entity(a.entity)

							e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
							e.nav_rally.center = V.vclone(e.pos)
							e.nav_rally.pos = V.vclone(e.pos)
							e.tween.ts = store.tick_ts
							e.tween.props[1].keys[1][2].x = -o.x
							e.tween.props[1].keys[1][2].y = -o.y
							e.render.sprites[1].flip_x = this.render.sprites[1].flip_x
							e.owner = this

							queue_insert(store, e)
						end

						SU.y_hero_animation_wait(this)

						a.ts = store.tick_ts

						goto label_133_0
					end
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					-- block empty
				elseif SU.soldier_go_back_step(store, this) then
					-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_133_0::

		coroutine.yield()
	end
end

scripts.hero_catha_ultimate = {}

function scripts.hero_catha_ultimate.can_fire_fn(this, x, y, store)
	return not GR:cell_is(x, y, TERRAIN_FAERIE) and P:valid_node_nearby(x, y, 1.4285714285714286, NF_POWER_3)
end

function scripts.hero_catha_ultimate.update(this, store)
	U.animation_start(this, nil, nil, store.tick_ts, false)
	U.y_wait(store, this.hit_time)

	local fx = E:create_entity(this.hit_fx)

	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y

	U.animation_start(fx, nil, nil, store.tick_ts, false)
	queue_insert(store, fx)

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.range, this.vis_flags, this.vis_bans, function(e)
		return U.flag_has(e.vis.flags, F_BOSS) or not U.flag_has(e.vis.bans, F_STUN)
	end)

	if targets then
		for _, target in pairs(targets) do
			local m = E:create_entity(this.mod)

			m.modifier.source_id = this.id
			m.modifier.target_id = target.id

			if U.flag_has(target.vis.flags, F_BOSS) then
				m.modifier.duration = this.duration_boss
				m.modifier.vis_flags = U.flag_clear(m.modifier.vis_flags, F_STUN)
			else
				m.modifier.duration = this.duration
			end

			queue_insert(store, m)
		end
	end

	U.y_animation_wait(this)
	queue_remove(store, this)
end

scripts.hero_rag = {}

function scripts.hero_rag.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	local s

	s = this.hero.skills.raggified

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.max_target_hp = s.max_target_hp[s.level]

		local m = E:get_template("mod_rag_raggified")

		m.doll_duration = s.doll_duration[s.level]
	end

	s = this.hero.skills.kamihare

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.count = s.count[s.level]
	end

	s = this.hero.skills.angry_gnome

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		for _, n in pairs(a.things) do
			local b = E:get_template(a.bullet_prefix .. n)

			b.bullet.damage_max = s.damage_max[s.level]
			b.bullet.damage_min = s.damage_min[s.level]
		end
	end

	s = this.hero.skills.hammer_time

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.duration = s.duration[s.level]
	end

	s = this.hero.skills.ultimate

	if initial then
		local u = E:get_template(s.controller_name)

		u.max_count = s.max_count[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_rag.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta, ranged_done

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_144_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[4]
			skill = this.hero.skills.raggified

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(e)
					return e.health.hp < a.max_target_hp and GR:cell_is_only(e.pos.x, e.pos.y, TERRAIN_LAND)
				end)

				if not target then
					SU.delay_attack(store, a, 0.16666666666666666)
				else
					a.ts = store.tick_ts

					if not SU.y_soldier_do_ranged_attack(store, this, target, a) then
						goto label_144_0
					end
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.kamihare

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target_info = U.find_enemies_in_paths(store.entities, this.pos, a.range_nodes_min, a.range_nodes_max, nil, a.vis_flags, a.vis_bans, true, function(e)
					return not U.flag_has(P:path_terrain_props(e.nav_path.pi), TERRAIN_FAERIE)
				end)

				if not target_info then
					SU.delay_attack(store, a, 0.16666666666666666)
				else
					local target = target_info[1].enemy
					local origin = target_info[1].origin
					local start_ts = store.tick_ts
					local bullet_to_ni = origin[3] - 5
					local bullet_to = P:node_pos(origin[1], 1, bullet_to_ni)
					local flip = bullet_to.x < this.pos.x

					S:queue(a.sound, {
						delay = a.sound_delay
					})
					U.animation_start(this, a.animations[1], flip, store.tick_ts)

					if SU.y_hero_wait(store, this, a.spawn_time) then
						-- block empty
					else
						SU.hero_gain_xp_from_skill(this, skill)

						a.ts = store.tick_ts

						for i = 1, a.count do
							SU.y_hero_wait(store, this, fts(2))

							local pi, spi, ni = origin[1], km.zmod(i, 3), bullet_to_ni + math.random(-10, 0)

							if not P:is_node_valid(pi, ni) then
								log.debug("cannot spawn kamihare in invalid node: %s,%s,%s", pi, spi, ni)
							else
								local e = E:create_entity(a.entity)

								e.pos = P:node_pos(pi, spi, ni)
								e.nav_path.pi = pi
								e.nav_path.spi = spi
								e.nav_path.ni = ni

								local b = E:create_entity(a.bullet)

								b.pos.x = this.pos.x + math.random(-3, 3) + a.spawn_offset.x
								b.pos.y = this.pos.y + math.random(0, 3) + a.spawn_offset.y
								b.bullet.from = V.vclone(b.pos)
								b.bullet.to = V.vclone(e.pos)
								b.bullet.hit_payload = e
								b.render.sprites[1].flip_x = flip
								b.render.sprites[1].ts = store.tick_ts

								queue_insert(store, b)
							end
						end

						U.animation_start(this, a.animations[2], nil, store.tick_ts)
						SU.y_hero_animation_wait(this)

						a.ts = store.tick_ts
					end

					goto label_144_0
				end
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.angry_gnome

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					local pred_pos = P:predict_enemy_pos(target, fts(12))
					local thing = table.random(a.things)

					a.animation = "throw_" .. thing
					a.bullet = a.bullet_prefix .. thing
					a.ts = store.tick_ts

					if not SU.y_soldier_do_ranged_attack(store, this, target, a, pred_pos) then
						goto label_144_0
					end
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.hammer_time

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local nodes, start_node, end_node, next_node, damage_ts
				local target, targets = U.find_nearest_enemy(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)
				local total_hp = not targets and 0 or table.reduce(targets, function(e, hp_sum)
					return e.health.hp + hp_sum
				end)

				if not target or total_hp < a.trigger_hp then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					U.unblock_target(store, this)
					S:queue(a.sound_loop)
					U.y_animation_play(this, a.animations[1], nil, store.tick_ts)

					if SU.hero_interrupted(this) then
						-- block empty
					else
						SU.hero_gain_xp_from_skill(this, skill)

						a.ts = store.tick_ts
						nodes = P:nearest_nodes(this.pos.x, this.pos.y, {
							target.nav_path.pi
						}, nil, true)

						if #nodes == 0 then
							log.error("hammer_time could not find a valid node near %s,%s", this.pos.x, this.pos.y)

							goto label_144_0
						end

						start_node = {
							pi = nodes[1][1],
							spi = nodes[1][2],
							ni = nodes[1][3]
						}
						end_node = table.deepclone(target.nav_path)
						next_node = table.deepclone(start_node)
						next_node.dir = start_node.ni > end_node.ni and -1 or 1
						end_node.ni = next_node.dir * a.nodes_range + start_node.ni

						U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

						damage_ts = store.tick_ts - a.damage_every

						while store.tick_ts - a.ts < a.duration and not SU.hero_interrupted(this) do
							if U.walk(this, store.tick_length) then
								if math.abs(next_node.ni - start_node.ni) == a.nodes_range then
									next_node.dir = next_node.dir * -1
								end

								next_node.ni = next_node.ni + next_node.dir
								next_node.spi = next_node.spi == 3 and 2 or 3

								U.set_destination(this, P:node_pos(next_node))

								this.render.sprites[1].flip_x = this.motion.dest.x < this.pos.x
							end

							if store.tick_ts - damage_ts >= a.damage_every then
								damage_ts = store.tick_ts

								S:queue(a.sound_hit)

								local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius, a.vis_flags, a.vis_bans)

								if targets then
									for _, t in pairs(targets) do
										local d = SU.create_attack_damage(a, t.id, this.id)

										queue_damage(store, d)

										local m = E:create_entity(a.mod)

										m.modifier.source_id = this.id
										m.modifier.target_id = t.id

										queue_insert(store, m)
									end
								end
							end

							coroutine.yield()
						end
					end

					a.ts = store.tick_ts

					S:stop(a.sound_loop)
					U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

					goto label_144_0
				end
			end

			if not ranged_done then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					goto label_144_0
				end

				if sta == A_DONE then
					ranged_done = true
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta == A_DONE or sta == A_NO_TARGET then
				ranged_done = nil
			end

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			elseif SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_144_0::

		coroutine.yield()
	end
end

scripts.hero_rag_ultimate = {}

function scripts.hero_rag_ultimate.can_fire_fn(this, x, y, store)
	if not P:valid_node_nearby(x, y, nil, NF_RALLY) or not GR:cell_is_only(x, y, TERRAIN_LAND) then
		return false
	end

	local targets = U.find_enemies_in_range(store.entities, V.v(x, y), 0, this.range, this.vis_flags, this.vis_bans, function(e)
		return GR:cell_is_only(e.pos.x, e.pos.y, TERRAIN_LAND)
	end)

	return targets ~= nil
end

function scripts.hero_rag_ultimate.update(this, store)
	SU.insert_sprite(store, this.hit_fx, this.pos)
	SU.insert_sprite(store, this.hit_decal, this.pos)
	U.y_wait(store, this.hit_time)

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.range, this.vis_flags, this.vis_bans, function(e)
		return GR:cell_is_only(e.pos.x, e.pos.y, TERRAIN_LAND)
	end)

	if targets then
		for i, target in ipairs(targets) do
			if i > this.max_count then
				break
			end

			local m = E:create_entity(this.mod)

			m.modifier.source_id = this.id
			m.modifier.target_id = target.id
			m.doll_duration = this.doll_duration * U.frandom(0.97, 1.03)

			queue_insert(store, m)
		end
	end

	queue_remove(store, this)
end

scripts.rabbit_kamihare = {}

function scripts.rabbit_kamihare.update(this, store)
	local start_ts = store.tick_ts
	local a = this.custom_attack
	local s = this.render.sprites[1]

	s.ts = store.tick_ts + (s.random_ts and U.frandom(-s.random_ts, 0) or 0)

	while true do
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

		if targets or store.tick_ts - start_ts > this.duration or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or not SU.y_enemy_walk_step(store, this) then
			break
		end
	end

	local aura = E:create_entity(a.aura)

	aura.pos = V.vclone(this.pos)

	queue_insert(store, aura)

	if a.hit_fx then
		local fx = E:create_entity(a.hit_fx)

		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	U.y_animation_play(this, "death", nil, store.tick_ts)
	queue_remove(store, this)
end

scripts.hero_veznan = {}

function scripts.hero_veznan.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	local s

	s = this.hero.skills.soulburn

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.total_hp = s.total_hp[s.level]
	end

	s = this.hero.skills.shackles

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.max_count = s.max_count[s.level]
	end

	s = this.hero.skills.hermeticinsight

	if initial and s.level > 0 then
		local rf = s.range_factor[s.level]
		local a = this.ranged.attacks[1]

		a.max_range = a.max_range * rf

		local a = this.timed_attacks.list[1]

		a.range = a.range * rf
		a = this.timed_attacks.list[2]
		a.range = a.range * rf
		a = this.timed_attacks.list[3]
		a.max_range = a.max_range * rf
	end

	s = this.hero.skills.arcanenova

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.damage_max = s.damage_max[s.level]
		a.damage_min = s.damage_min[s.level]
	end

	s = this.hero.skills.ultimate

	if initial then
		local u = E:get_template(s.controller_name)
		local m = E:get_template(u.mod)

		m.modifier.duration = s.stun_duration[s.level]

		local e = E:get_template(u.entity)

		e.health.hp_max = s.soldier_hp_max[s.level]
		e.melee.attacks[1].damage_max = s.soldier_damage_max[s.level]
		e.melee.attacks[1].damage_min = s.soldier_damage_min[s.level]

		local b = E:get_template(e.ranged.attacks[1].bullet)

		b.bullet.damage_max = s.soldier_damage_max[s.level]
		b.bullet.damage_min = s.soldier_damage_min[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_veznan.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_154_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.arcanenova

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target, targets = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range, a.cast_time, a.vis_flags, a.vis_bans)

				if not target or #targets < 2 then
					SU.delay_attack(store, a, 0.3333333333333333)
				else
					local af = target.pos.x < this.pos.x

					U.animation_start(this, a.animation, af, store.tick_ts, false)
					U.y_wait(store, a.hit_time)

					local node = table.deepclone(target.nav_path)

					node.spi = 1

					local node_pos = P:node_pos(node)
					local targets = U.find_enemies_in_range(store.entities, node_pos, 0, a.damage_radius, a.vis_flags, a.vis_bans)

					if targets then
						SU.hero_gain_xp_from_skill(this, skill)

						for _, t in pairs(targets) do
							queue_damage(store, SU.create_attack_damage(a, t.id, this.id))

							local m = E:create_entity(a.mod)

							m.modifier.source_id = this.id
							m.modifier.target_id = t.id

							queue_insert(store, m)
						end
					end

					S:queue(a.cast_sound)

					local fx = E:create_entity(a.hit_fx)

					fx.pos.x, fx.pos.y = node_pos.x, node_pos.y

					U.animation_start(fx, nil, nil, store.tick_ts, false)
					queue_insert(store, fx)
					U.y_wait(store, fts(5))

					local decal = E:create_entity(a.hit_decal)

					decal.pos.x, decal.pos.y = node_pos.x, node_pos.y
					decal.tween.ts = store.tick_ts
					decal.render.sprites[2].ts = store.tick_ts

					queue_insert(store, decal)
					U.y_animation_wait(this)

					a.ts = store.tick_ts
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.shackles

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local triggers = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

				if not triggers then
					SU.delay_attack(store, a, 0.3333333333333333)
				else
					local first_target = table.random(triggers)
					local targets = U.find_enemies_in_range(store.entities, first_target.pos, 0, a.radius, a.vis_flags, a.vis_bans)
					local af = first_target.pos.x < this.pos.x

					U.animation_start(this, a.animation, af, store.tick_ts, false)
					U.y_wait(store, a.cast_time)
					S:queue(a.cast_sound)
					SU.hero_gain_xp_from_skill(this, skill)

					for i = 1, math.min(#targets, a.max_count) do
						local target = targets[i]

						for _, m_name in pairs(a.mods) do
							local m = E:create_entity(m_name)

							m.modifier.target_id = target.id
							m.modifier.source_id = this.id

							queue_insert(store, m)
						end
					end

					U.y_animation_wait(this)

					a.ts = store.tick_ts
				end
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.soulburn

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local triggers = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans, function(e)
					return skill.level == 3 or e.health.hp_max <= a.total_hp
				end)

				if not triggers then
					SU.delay_attack(store, a, 0.3333333333333333)
				else
					table.sort(triggers, function(e1, e2)
						return e1.health.hp > e2.health.hp
					end)

					local targets = {}
					local first_target = triggers[1]

					table.insert(targets, first_target)

					local hp_count = first_target.health.hp

					if hp_count < a.total_hp then
						for _, t in pairs(triggers) do
							if t ~= first_target and hp_count + t.health.hp_max <= a.total_hp and U.is_inside_ellipse(t.pos, first_target.pos, a.radius) then
								table.insert(targets, t)

								hp_count = hp_count + t.health.hp_max
							end
						end
					end

					S:queue(a.sound)

					local af = first_target.pos.x < this.pos.x

					U.animation_start(this, a.animations[1], af, store.tick_ts, false)
					U.y_wait(store, a.cast_time)

					local balls = {}
					local o = V.v(a.balls_dest_offset.x * (this.render.sprites[1].flip_x and -1 or 1), a.balls_dest_offset.y)

					for _, target in pairs(targets) do
						local d = E:create_entity("damage")

						d.damage_type = DAMAGE_EAT
						d.target_id = target.id
						d.source_id = this.id

						queue_damage(store, d)

						local fx = E:create_entity(a.hit_fx)

						fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
						fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
						fx.render.sprites[1].ts = store.tick_ts

						queue_insert(store, fx)

						local b = E:create_entity(a.ball)

						b.from = V.v(target.pos.x + target.unit.mod_offset.x, target.pos.y + target.unit.mod_offset.y)
						b.to = V.v(this.pos.x + o.x, this.pos.y + o.y)
						b.pos = V.vclone(b.from)
						b.target = target

						queue_insert(store, b)
						table.insert(balls, b)
					end

					U.y_animation_wait(this)
					U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

					while true do
						coroutine.yield()

						local arrived = true

						for _, ball in pairs(balls) do
							arrived = arrived and ball.arrived
						end

						if arrived then
							break
						end

						if h.dead then
							goto label_154_0
						end
					end

					SU.hero_gain_xp_from_skill(this, skill)
					U.animation_start(this, a.animations[3], nil, store.tick_ts, false)
					U.y_animation_wait(this)

					a.ts = store.tick_ts
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					-- block empty
				elseif SU.soldier_go_back_step(store, this) then
					-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_154_0::

		coroutine.yield()
	end
end

scripts.hero_veznan_ultimate = {}

function scripts.hero_veznan_ultimate.can_fire_fn(this, x, y, store)
	return GR:cell_is_only(x, y, TERRAIN_LAND) and P:valid_node_nearby(x, y, nil, NF_RALLY)
end

function scripts.hero_veznan_ultimate.update(this, store)
	local e = E:create_entity(this.entity)

	e.pos.x, e.pos.y = this.pos.x, this.pos.y
	e.nav_rally.pos = V.vclone(e.pos)
	e.nav_rally.center = V.vclone(e.pos)

	queue_insert(store, e)

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.range, this.vis_flags, this.vis_bans)

	if targets then
		for _, target in pairs(targets) do
			local m = E:create_entity(this.mod)

			m.modifier.source_id = this.id
			m.modifier.target_id = target.id

			queue_insert(store, m)
		end
	end

	queue_remove(store, this)
end

scripts.hero_durax = {}

function scripts.hero_durax.get_info(this)
	local info = scripts.hero_basic.get_info_melee(this)

	if this.clone then
		info.respawn = nil
	end

	return info
end

function scripts.hero_durax.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	local s

	s = this.hero.skills.crystallites

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil
	end

	s = this.hero.skills.armsword

	if initial and s.level > 0 then
		local a = this.melee.attacks[3]

		a.disabled = nil
		a.damage_min = s.damage[s.level]
		a.damage_max = s.damage[s.level]
	end

	s = this.hero.skills.lethal_prism

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.ray_count = s.ray_count[s.level]

		local b = E:get_template(a.bullet)

		b.bullet.damage_max = s.damage_max[s.level]
		b.bullet.damage_min = s.damage_min[s.level]
	end

	s = this.hero.skills.shardseed

	if initial and s.level > 0 then
		local a = this.ranged.attacks[1]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.damage_max = s.damage[s.level]
		b.bullet.damage_min = s.damage[s.level]
	end

	s = this.hero.skills.ultimate

	if initial then
		local u = E:get_template(s.controller_name)

		u.max_count = s.max_count[s.level]
		u.damage = s.damage[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_durax.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta, decal

	this.health_bar.hidden = false

	if not this.clone then
		U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

		decal = E:create_entity("decal_durax")
		decal.pos = this.pos

		queue_insert(store, decal)
	end

	while true do
		if h.dead or this.clone and store.tick_ts - this.clone.ts > this.clone.duration then
			if this.clone then
				this.ui.can_click = false
				this.health.hp = 0

				SU.y_soldier_death(store, this)

				this.tween.disabled = nil
				this.tween.ts = store.tick_ts

				return
			else
				decal.render.sprites[1].hidden = true

				SU.y_hero_death_and_respawn(store, this)

				decal.render.sprites[1].hidden = nil
			end
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_161_0
				end
			end

			if SU.hero_level_up(store, this) and not this.clone then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.lethal_prism

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local triggers = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

				if not triggers then
					SU.delay_attack(store, a, 0.3333333333333333)
				else
					SU.remove_modifiers(store, this)

					this.health_bar.hidden = true
					this.health.ignore_damage = true

					local vis_flags = this.vis.flags
					local vis_bans = this.vis.bans

					this.vis.flags = U.flag_clear(this.vis.flags, F_RANGED)
					this.vis.bans = F_ALL

					U.y_animation_play(this, a.animations[1], nil, store.tick_ts)
					U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

					for i = 1, a.ray_count do
						local target = U.find_random_enemy(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

						if target then
							local bo = a.bullet_start_offset[1]
							local b = E:create_entity(a.bullet)

							b.bullet.target_id = target.id
							b.bullet.source_id = this.id
							b.pos = V.v(this.pos.x + bo.x, this.pos.y + bo.y)
							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = V.vclone(target.pos)

							queue_insert(store, b)
						end

						U.y_wait(store, a.ray_cooldown)
					end

					U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

					this.vis.flags = vis_flags
					this.vis.bans = vis_bans
					this.health.ignore_damage = nil
					this.health_bar.hidden = nil
					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)

					goto label_161_0
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.crystallites

			if not this.clone and not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_RALLY)

				if #nearest < 1 then
					SU.delay_attack(store, a, 0.3333333333333333)
				else
					local ns = {}

					ns.pi = nearest[1][1]
					ns.spi = math.random(1, 3)
					ns.ni = nearest[1][3] - math.random(a.nodes_offset[1], a.nodes_offset[2])

					local node_pos = P:node_pos(ns)

					if not P:is_node_valid(ns.pi, ns.ni, NF_RALLY) or band(GR:cell_type(node_pos.x, node_pos.y), bor(TERRAIN_NOWALK, TERRAIN_FAERIE)) ~= 0 then
						SU.delay_attack(store, a, 0.3333333333333333)
					else
						S:queue(a.sound)
						U.animation_start(this, a.animation, nil, store.tick_ts, false)
						U.y_wait(store, a.spawn_time)

						local spawn_pos = V.v(this.pos.x + (this.render.sprites[1].flip_x and -1 or 1) * a.spawn_offset.x, this.pos.y + a.spawn_offset.y)
						local clone = E:create_entity(a.entity)

						clone.pos = spawn_pos
						clone.nav_rally.pos = node_pos
						clone.nav_rally.center = V.vclone(node_pos)
						clone.nav_rally.new = true
						clone.render.sprites[1].flip_x = this.render.sprites[1].flip_x
						clone.clone.ts = store.tick_ts
						clone.clone.duration = skill.duration[skill.level]
						clone.hero.level = this.hero.level
						clone.hero.xp = this.hero.xp

						for sn, s in pairs(this.hero.skills) do
							clone.hero.skills[sn].level = s.level
						end

						queue_insert(store, clone)
						SU.hero_gain_xp_from_skill(this, skill)
						U.y_animation_wait(this)

						a.ts = store.tick_ts
					end
				end
			end

			if not this.ranged.attacks[1].disabled then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					goto label_161_0
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			elseif SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_161_0::

		coroutine.yield()
	end
end

scripts.hero_durax_ultimate = {}

function scripts.hero_durax_ultimate.can_fire_fn(this, x, y, store)
	for _, e in pairs(store.entities) do
		if e.pos and e.ui and e.ui.can_click and e.enemy and e.vis and e.nav_path and e.health and not e.health.dead and band(e.vis.flags, this.vis_bans) == 0 and band(e.vis.bans, this.vis_flags) == 0 and U.is_inside_ellipse(V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y), V.v(x, y), this.range) and P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_POWER_1) then
			return true
		end
	end

	return false
end

function scripts.hero_durax_ultimate.update(this, store)
	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.range, this.vis_flags, this.vis_bans, function(e)
		return band(e.vis.flags, F_BOSS) ~= 0 or band(e.vis.bans, F_STUN) == 0
	end)

	if targets then
		local single = #targets == 1

		for i, target in pairs(targets) do
			if i > this.max_count then
				break
			end

			local d = E:create_entity("damage")

			d.value = math.ceil(this.damage / #targets)
			d.damage_type = this.damage_type
			d.target_id = target.id
			d.source_id = this.id

			queue_damage(store, d)

			if target.unit.blood_color ~= BLOOD_NONE then
				local sfx = E:create_entity(this.hit_blood_fx)

				sfx.pos.x, sfx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
				sfx.render.sprites[1].ts = store.tick_ts

				if sfx.use_blood_color and target.unit.blood_color then
					sfx.render.sprites[1].name = target.unit.blood_color
				end

				queue_insert(store, sfx)
			end

			local m = E:create_entity(band(target.vis.flags, F_BOSS) ~= 0 and this.mod_slow or this.mod_stun)

			m.modifier.target_id = target.id
			m.modifier.source_id = this.id

			queue_insert(store, m)

			local fx = SU.insert_sprite(store, "fx_durax_ultimate_fang_" .. (single and "1" or "2"), target.pos)

			fx.render.sprites[1].scale = fx.render.sprites[1].size_scales[target.unit.size]

			local spikes_count = single and 12 or 8
			local radius = single and 40 or 30
			local angle = U.frandom(0, math.pi)

			for j = 1, spikes_count do
				local p = U.point_on_ellipse(target.pos, U.frandom(0.5, 1) * radius, angle)

				angle = angle + math.pi / 4.2

				local fx = SU.insert_sprite(store, "fx_durax_ultimate_fang_extra_" .. math.random(1, 2), p, nil, U.frandom(0.1, 0.2))

				fx.render.sprites[1].scale = V.vv(U.frandom(0.8, 1.1))
			end
		end
	end

	queue_remove(store, this)
end

scripts.hero_lilith = {}

function scripts.hero_lilith.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	local s

	s = this.hero.skills.reapers_harvest

	if initial and s.level > 0 then
		local a = this.melee.attacks[3]

		a.disabled = nil
		a.damage_min = s.damage[s.level]
		a.damage_max = s.damage[s.level]
		a = this.melee.attacks[4]
		a.disabled = nil
		a.damage_min = s.damage[s.level]
		a.damage_max = s.damage[s.level]
		a.chance = s.instakill_chance[s.level]
	end

	s = this.hero.skills.soul_eater

	if initial and s.level > 0 then
		local m = E:get_template("mod_lilith_soul_eater_damage_factor")

		m.soul_eater_factor = s.damage_factor[s.level]
	end

	s = this.hero.skills.infernal_wheel

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		local au = E:get_template(a.bullet)
		local m = E:get_template(au.aura.mod)

		m.dps.damage_min = s.damage[s.level]
		m.dps.damage_max = s.damage[s.level]
	end

	s = this.hero.skills.resurrection

	if initial and s.level > 0 then
		local a = this.revive

		a.disabled = nil
		a.chance = s.chance[s.level]

		if store.selected_hero_status and store.selected_hero_status.resurrection_chance_base then
			a.chance_base = store.selected_hero_status.resurrection_chance_base[s.level]
			a.chance_max = store.selected_hero_status.resurrection_chance_max[s.level]
			a.chance_step = store.selected_hero_status.resurrection_chance_step[s.level]
		end
	end

	s = this.hero.skills.ultimate

	if initial then
		local u = E:get_template(s.controller_name)

		u.angel_count = s.angel_count[s.level]

		local e = E:get_template(u.angel_entity)

		e.melee.attacks[1].damage_max = s.angel_damage[s.level] * 2
		e.melee.attacks[1].damage_min = s.angel_damage[s.level] * 2

		local b = E:get_template(u.meteor_bullet)

		b.bullet.damage_max = s.meteor_damage[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_lilith.insert(this, store)
	scripts.hero_basic.insert(this, store)

	if this.hero.skills.soul_eater.level > 0 then
		local a = E:create_entity("aura_lilith_soul_eater")

		a.aura.source_id = this.id
		a.aura.ts = store.tick_ts
		a.pos = this.pos

		queue_insert(store, a)
	end

	return true
end

function scripts.hero_lilith.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	this.health_bar.hidden = false

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	while true do
		if h.dead then
			local r = this.revive
			local chance_pass

			if r.chance_base then
				local v = r.chance_base + 0.01 * (store.tick_ts - r.ts) / r.chance_step

				v = km.clamp(r.chance_base, r.chance_max, v)
				chance_pass = v > math.random()

				log.error("TESTING CUSTOM LILITH REVIVE / CHANCE: %s", v)
			else
				chance_pass = math.random() < this.revive.chance
			end

			if not this.revive.disabled and not U.flag_has(h.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE_BOSS)) and chance_pass then
				h.ignore_damage = true
				h.dead = false
				h.hp = h.hp_max

				for _, s in pairs(this.render.sprites) do
					s.hidden = false
				end

				S:queue(this.revive.sound)
				U.y_animation_play(this, this.revive.animation, nil, store.tick_ts, 1)

				this.health_bar.hidden = false
				this.ui.can_click = true
				h.ignore_damage = nil
			else
				SU.y_hero_death_and_respawn(store, this)
			end

			this.revive.ts = store.tick_ts
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_167_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.infernal_wheel

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_random_enemy(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

				if not target then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					S:queue(a.sound)
					U.animation_start(this, a.animation, nil, store.tick_ts)

					if SU.y_hero_wait(store, this, a.shoot_time) then
						goto label_167_0
					end

					SU.hero_gain_xp_from_skill(this, skill)

					a.ts = store.tick_ts

					local pos
					local nodes = P:nearest_nodes(target.pos.x, target.pos.y, nil, nil, true)

					if #nodes == 0 then
						pos = V.vclone(this.pos)
					else
						pos = P:node_pos(nodes[1][1], 1, nodes[1][3])
					end

					local b = E:create_entity(a.bullet)

					b.pos.x, b.pos.y = pos.x, pos.y
					b.aura.ts = store.tick_ts

					queue_insert(store, b)
					SU.y_hero_animation_wait(this)

					goto label_167_0
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					-- block empty
				elseif SU.soldier_go_back_step(store, this) then
					-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_167_0::

		coroutine.yield()
	end
end

scripts.hero_lilith_ultimate = {}

function scripts.hero_lilith_ultimate.can_fire_fn(this, x, y, store)
	return not GR:cell_is(x, y, TERRAIN_FAERIE) and P:valid_node_nearby(x, y, 1.4285714285714286, NF_POWER_3)
end

function scripts.hero_lilith_ultimate.update(this, store)
	local function spawn_meteor(pi, spi, ni)
		spi = spi or math.random(1, 3)

		local pos = P:node_pos(pi, spi, ni)

		pos.x = pos.x + math.random(-4, 4)
		pos.y = pos.y + math.random(-5, 5)

		local b = E:create_entity(this.meteor_bullet)

		b.bullet.from = V.v(pos.x + math.random(140, 170), pos.y + REF_H)
		b.bullet.to = pos
		b.pos = V.vclone(b.bullet.from)

		queue_insert(store, b)
	end

	local pi, spi, ni
	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

	if #nearest < 1 then
		log.error("could not find node to fire lilith ultimate")
	else
		pi, spi, ni = unpack(nearest[1])

		if this.meteor_chance < math.random() then
			local seq = {}

			for i = 1, this.meteor_node_spread do
				seq[i] = i
			end

			spawn_meteor(pi, spi, ni)

			while #seq > 0 do
				local delay = U.frandom(0.15, 0.3)
				local i = table.remove(seq, math.random(1, #seq))
				local can_up, can_down = P:is_node_valid(pi, ni + i), P:is_node_valid(pi, ni - i)

				U.y_wait(store, delay / 2)

				if can_up then
					spawn_meteor(pi, nil, ni + i)
				elseif can_down then
					spawn_meteor(pi, nil, ni - i)
				end

				U.y_wait(store, delay / 2)

				if can_down then
					spawn_meteor(pi, nil, ni - i)
				elseif can_up then
					spawn_meteor(pi, nil, ni + i)
				end
			end
		else
			local node = {
				spi = 1,
				pi = nearest[1][1],
				ni = nearest[1][3]
			}
			local node_pos = P:node_pos(node)
			local target, targets = U.find_foremost_enemy(store.entities, this.pos, 0, this.angel_range, fts(10), this.angel_vis_flags, this.angel_vis_bans)
			local idx = 1

			for i = 1, this.angel_count do
				local e = E:create_entity(this.angel_entity)

				if targets then
					target = targets[km.zmod(idx, #targets)]
					idx = idx + 1

					if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, F_BOSS) == 0 then
						local m = E:create_entity(this.angel_mod)

						m.modifier.target_id = target.id
						m.modifier.source_id = this.id

						queue_insert(store, m)
					end

					if band(target.vis.flags, F_BLOCK) ~= 0 then
						U.block_enemy(store, e, target)
					else
						e.unblocked_target_id = target.id
					end

					local lpos, lflip = U.melee_slot_position(e, target, 1, math.random() < 0.5)

					e.pos.x, e.pos.y = lpos.x, lpos.y
					e.render.sprites[1].flip_x = lflip
				else
					local nni = node.ni + math.random(-10, 10)
					local nspi = math.random(1, 3)
					local npos = P:node_pos(node.pi, nspi, nni)

					if not P:is_node_valid(node.pi, nni) or GR:cell_is(node_pos.x, node_pos.y, TERRAIN_FAERIE) then
						npos = node_pos
					end

					e.pos.x, e.pos.y = npos.x, npos.y
				end

				e.nav_rally.center = V.vclone(e.pos)
				e.nav_rally.pos = V.vclone(e.pos)

				queue_insert(store, e)
				U.y_wait(store, this.angel_delay)
			end
		end
	end

	queue_remove(store, this)
end

scripts.hero_bruce = {}

function scripts.hero_bruce.fn_chance_sharp_claws(this, store, attack, target)
	return U.has_modifier_types(store, target, MOD_TYPE_BLEED) or math.random() < attack.chance
end

function scripts.hero_bruce.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[3].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[3].damage_max = ls.melee_damage_max[hl]

	local s

	s = this.hero.skills.sharp_claws

	if initial and s.level > 0 then
		local a = this.melee.attacks[3]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.dps.damage_min = s.damage[s.level]
		m.dps.damage_max = s.damage[s.level]
		m.extra_bleeding_damage = s.extra_damage[s.level]
	end

	s = this.hero.skills.kings_roar

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.modifier.duration = s.stun_duration[s.level]
	end

	s = this.hero.skills.lions_fur

	if s.level > 0 then
		this.health.hp_max = this.health.hp_max + s.extra_hp[s.level]
	end

	s = this.hero.skills.grievous_bites

	if initial and s.level > 0 then
		local a = this.melee.attacks[4]

		a.disabled = nil
		a.damage_max = s.damage[s.level]
		a.damage_min = s.damage[s.level]
	end

	s = this.hero.skills.ultimate

	if initial then
		local u = E:get_template(s.controller_name)

		u.count = s.count[s.level]

		local e = E:get_template(u.entity)

		e.custom_attack.damage_boss = s.damage_boss[s.level]

		local m = E:get_template("mod_lion_bruce_damage")

		m.dps.damage_max = s.damage_per_tick[s.level]
		m.dps.damage_min = s.damage_per_tick[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_bruce.insert(this, store)
	if not scripts.hero_basic.insert(this, store) then
		return false
	end

	local a = E:create_entity("aura_bruce_hps")

	a.aura.source_id = this.id
	a.aura.ts = store.tick_ts
	a.pos = this.pos

	queue_insert(store, a)

	return true
end

function scripts.hero_bruce.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	this.health_bar.hidden = false

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_174_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.kings_roar

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_count then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					S:queue(a.sound, a.sound_args)
					U.animation_start(this, a.animation, nil, store.tick_ts)

					if SU.y_hero_wait(store, this, a.hit_time) then
						-- block empty
					else
						SU.hero_gain_xp_from_skill(this, skill)

						a.ts = store.tick_ts
						targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

						if targets then
							for i, target in ipairs(targets) do
								if i > a.max_count then
									break
								end

								local m = E:create_entity(a.mod)

								m.modifier.source_id = this.id
								m.modifier.target_id = target.id

								queue_insert(store, m)
							end
						end

						SU.y_hero_animation_wait(this)
					end

					goto label_174_0
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			elseif SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_174_0::

		coroutine.yield()
	end
end

scripts.hero_bruce_ultimate = {}

function scripts.hero_bruce_ultimate.can_fire_fn(this, x, y, store)
	return GR:cell_is_only(x, y, TERRAIN_LAND) and P:valid_node_nearby(x, y, nil, NF_RALLY)
end

function scripts.hero_bruce_ultimate.update(this, store)
	local pi, spi, ni
	local target_info = U.find_enemies_in_paths(store.entities, this.pos, this.range_nodes_min, this.range_nodes_max, nil, this.vis_flags, this.vis_bans, true, function(e)
		return not U.flag_has(P:path_terrain_props(e.nav_path.pi), TERRAIN_FAERIE)
	end)

	if target_info then
		local o = target_info[1].origin

		pi, spi, ni = o[1], o[2], o[3]
	else
		local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

		if #nearest > 0 then
			for _, n in pairs(nearest) do
				if band(P:path_terrain_props(n[1]), TERRAIN_FAERIE) == 0 then
					pi, spi, ni = n[1], n[2], n[3]

					break
				end
			end
		end
	end

	if pi then
		for i = 1, this.count do
			local e = E:create_entity(this.entity)

			e.nav_path.pi = pi
			e.nav_path.spi = spi
			e.nav_path.ni = ni

			queue_insert(store, e)

			spi = km.zmod(spi + 1, 3)
			ni = ni - 2
		end
	end

	queue_remove(store, this)
end

scripts.lion_bruce = {}

function scripts.lion_bruce.insert(this, store)
	this.pos = P:node_pos(this.nav_path)

	if not this.pos then
		return false
	end

	return true
end

function scripts.lion_bruce.update(this, store)
	local attack = this.custom_attack
	local start_ts = store.tick_ts
	local fading

	this.tween.ts = store.tick_ts

	while true do
		local next, new = P:next_entity_node(this, store.tick_length)

		if not fading and (not next or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or store.tick_ts - start_ts >= this.duration) then
			fading = true
			this.tween.remove = true
			this.tween.reverse = true
			this.tween.ts = store.tick_ts

			S:queue(this.sound_events.custom_loop_end)
		end

		if next then
			U.set_destination(this, next)
		end

		local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

		U.animation_start(this, an, af, store.tick_ts)
		U.walk(this, store.tick_length)

		if not fading and store.tick_ts - attack.ts > attack.cooldown then
			attack.ts = store.tick_ts

			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, attack.range, attack.vis_flags, attack.vis_bans)

			if targets then
				for _, e in pairs(targets) do
					if U.flag_has(e.vis.flags, F_BOSS) then
						local d = E:create_entity("damage")

						d.value = attack.damage_boss
						d.source_id = this.id
						d.target_id = e.id
						d.damage_type = attack.damage_type

						queue_damage(store, d)

						this.render.sprites[1].loop_forced = false

						U.y_animation_play(this, "boom", nil, store.tick_ts)

						goto label_179_0
					elseif U.flags_pass(e.vis, attack) then
						for _, mn in pairs(attack.mods) do
							local m = E:create_entity(mn)

							m.modifier.target_id = e.id
							m.modifier.source_id = this.id

							queue_insert(store, m)
						end

						goto label_179_0
					end
				end
			end
		end

		coroutine.yield()
	end

	::label_179_0::

	queue_remove(store, this)
end

scripts.hero_lynn = {}

function scripts.hero_lynn.fn_damage_melee(this, store, attack, target)
	local skill = this.hero.skills.hexfury
	local value = math.ceil(this.unit.damage_factor * math.random(attack.damage_min, attack.damage_max))
	local mods = {
		"mod_lynn_curse",
		"mod_lynn_despair",
		"mod_lynn_ultimate",
		"mod_lynn_weakening"
	}

	if skill.level > 0 and U.has_modifier_in_list(store, target, mods) then
		value = value + math.ceil(this.unit.damage_factor * skill.extra_damage)

		log.debug(" fn_damage_melee LYNN: +++ adding extra damage %s", skill.extra_damage)
	end

	return value
end

function scripts.hero_lynn.on_damage(this, store, damage)
	local s = this.hero.skills.charm_of_unluck
	local dodge = this.dodge

	if dodge.last_check_ts == store.tick_ts then
		log.debug(" LYNN DAMAGE NOT dodged, already checked for dodge and passed", damage.value)

		return true
	elseif s.level > 0 and math.random() < s.chance[s.level] then
		log.debug(" LYNN DAMAGE dodged", damage.value)
		SU.hero_gain_xp_from_skill(this, s)

		return false
	else
		return true
	end
end

function scripts.hero_lynn.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	local s

	s = this.hero.skills.hexfury

	if initial and s.level > 0 then
		this.melee.attacks[1].mod = "mod_lynn_curse"
		this.melee.attacks[2].mod = "mod_lynn_curse"
		this.melee.attacks[3].mod = "mod_lynn_curse"
		this.melee.attacks[3].loops = s.loops[s.level]
		this.melee.attacks[3].disabled = nil
	end

	s = this.hero.skills.despair

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
		m.speed_factor = s.speed_factor[s.level]
		m.inflicted_damage_factor = s.damage_factor[s.level]
	end

	s = this.hero.skills.weakening

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
		m.armor_reduction = s.armor_reduction[s.level]
		m.magic_armor_reduction = s.magic_armor_reduction[s.level]
	end

	s = this.hero.skills.charm_of_unluck

	if initial and s.level > 0 then
		this.dodge.chance = s.chance[s.level]
	end

	s = this.hero.skills.ultimate

	if initial then
		local m = E:get_template("mod_lynn_ultimate")

		m.dps.damage_max = s.damage[s.level]
		m.dps.damage_min = s.damage[s.level]
		m.explode_damage = s.explode_damage[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_lynn.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	this.health_bar.hidden = false

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if this.dodge and this.dodge.active and this.dodge.last_check_ts ~= store.tick_ts then
				this.dodge.active = nil
			end

			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_183_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.despair

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_count then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					S:queue(a.sound, a.sound_args)
					U.animation_start(this, a.animation, nil, store.tick_ts)

					if SU.y_hero_wait(store, this, a.hit_time) then
						-- block empty
					else
						SU.hero_gain_xp_from_skill(this, skill)

						a.ts = store.tick_ts
						targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

						if targets then
							for i, target in ipairs(targets) do
								if i > a.max_count then
									break
								end

								local m = E:create_entity(a.mod)

								m.modifier.source_id = this.id
								m.modifier.target_id = target.id

								queue_insert(store, m)
							end
						end

						SU.y_hero_animation_wait(this)
					end

					goto label_183_0
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.weakening

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local blocked = U.get_blocked(store, this)

				if not blocked or blocked.health.armor == 0 and blocked.health.magic_armor == 0 or not U.is_blocked_valid(store, this) then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					S:queue(a.sound, a.sound_args)
					U.animation_start(this, a.animation, nil, store.tick_ts)

					if SU.y_hero_wait(store, this, a.hit_time) then
						-- block empty
					else
						a.ts = store.tick_ts
						blocked = U.get_blocked(store, this)

						if blocked and U.is_blocked_valid(store, this) then
							SU.hero_gain_xp_from_skill(this, skill)

							local m = E:create_entity(a.mod)

							m.modifier.source_id = this.id
							m.modifier.target_id = blocked.id

							queue_insert(store, m)
						end

						SU.y_hero_animation_wait(this)
					end

					goto label_183_0
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			elseif SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_183_0::

		coroutine.yield()
	end
end

scripts.hero_lynn_ultimate = {}

function scripts.hero_lynn_ultimate.update(this, store)
	local targets = table.filter(store.entities, function(_, e)
		return e.pos and e.ui and e.ui.can_click and e.enemy and e.vis and e.nav_path and e.health and not e.health.dead and band(e.vis.flags, this.vis_bans) == 0 and band(e.vis.bans, this.vis_flags) == 0 and U.is_inside_ellipse(V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y), V.v(this.pos.x, this.pos.y), this.range) and P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_POWER_1)
	end)

	table.sort(targets, function(e1, e2)
		return V.dist(e1.pos.x + e1.unit.hit_offset.x, e1.pos.y + e1.unit.hit_offset.y, this.pos.x, this.pos.y) < V.dist(e2.pos.x + e2.unit.hit_offset.x, e2.pos.y + e2.unit.hit_offset.y, this.pos.x, this.pos.y)
	end)

	local target = targets[1]

	if target then
		local m = E:create_entity(this.mod)

		m.modifier.source_id = this.id
		m.modifier.target_id = target.id

		queue_insert(store, m)
	end

	queue_remove(store, this)
end

scripts.hero_phoenix = {}

function scripts.hero_phoenix.get_info(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)
	local ba = E:get_template(b.bullet.hit_payload)
	local min, max = ba.aura.damage_min, ba.aura.damage_max

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

function scripts.hero_phoenix.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	local b = E:get_template(this.ranged.attacks[1].bullet)
	local ba = E:get_template(b.bullet.hit_payload)

	ba.aura.damage_max = ls.ranged_damage_max[hl]
	ba.aura.damage_min = ls.ranged_damage_min[hl]

	local a = E:get_template("aura_phoenix_egg")

	a.custom_attack.damage_max = ls.egg_explosion_damage_max[hl]
	a.custom_attack.damage_min = ls.egg_explosion_damage_min[hl]

	local m = E:get_template(a.aura.mod)

	m.dps.damage_min = ls.egg_damage[hl]
	m.dps.damage_max = ls.egg_damage[hl]

	local s

	s = this.hero.skills.inmolate

	if initial and s.level > 0 then
		local sd = this.selfdestruct

		sd.disabled = nil
		sd.damage_min = s.damage_min[s.level]
		sd.damage_max = s.damage_max[s.level]

		local a = this.timed_attacks.list[1]

		a.disabled = nil
	end

	s = this.hero.skills.purification

	if initial and s.level > 0 then
		local au = E:get_template("aura_phoenix_purification")

		au.aura.targets_per_cycle = s.max_targets[s.evel]

		local b = E:get_template("missile_phoenix_small")

		b.bullet.damage_max = s.damage_max[s.level]
		b.bullet.damage_min = s.damage_min[s.level]
	end

	s = this.hero.skills.blazing_offspring

	if initial and s.level > 0 then
		local a = this.ranged.attacks[2]

		a.disabled = nil
		a.shoot_times = {}

		for i = 1, s.count[s.level] do
			table.insert(a.shoot_times, fts(4))
		end

		local b = E:get_template(a.bullet)

		b.bullet.damage_max = s.damage_max[s.level]
		b.bullet.damage_min = s.damage_min[s.level]
	end

	s = this.hero.skills.flaming_path

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.custom_attack.damage = s.damage[s.level]
	end

	s = this.hero.skills.ultimate

	if initial then
		local au = E:get_template(s.controller_name)

		au.aura.damage_max = s.damage_max[s.level]
		au.aura.damage_min = s.damage_min[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_phoenix.insert(this, store)
	if not scripts.hero_basic.insert(this, store) then
		return false
	end

	if this.hero.skills.purification.level > 0 then
		local a = E:create_entity("aura_phoenix_purification")

		a.aura.source_id = this.id
		a.aura.ts = store.tick_ts
		a.pos = this.pos

		queue_insert(store, a)
	end

	return true
end

function scripts.hero_phoenix.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

	while true do
		if h.dead then
			local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)
			local respawn_point

			if #nodes < 1 then
				log.debug("hero_phoenix: could not find nearest node to place egg")

				respawn_point = store.level.custom_spawn_pos or store.level.locations.exits[1].pos
				this.selfdestruct.disabled = true
			else
				local pi, spi, ni, dist = unpack(nodes[1])

				respawn_point = P:node_pos(pi, spi, ni)

				if dist > 30 then
					log.debug("hero_phoenix: too far from nearest path for inmolate")

					this.selfdestruct.disabled = true
				end
			end

			local egg = E:create_entity("aura_phoenix_egg")

			if this.selfdestruct.disabled then
				this.hero.respawn_point = respawn_point
				egg.pos = V.vclone(respawn_point)
				egg.show_delay = fts(15)
			else
				egg.pos = V.vclone(this.pos)
				egg.show_delay = fts(28)
			end

			queue_insert(store, egg)
			U.sprites_hide(this, 2, 2)
			SU.y_hero_death_and_respawn(store, this)

			this.selfdestruct.disabled = this.hero.skills.inmolate.level < 1

			U.sprites_show(this, 2, 2)

			this.hero.respawn_point = nil

			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			-- block empty
		end

		a = this.timed_attacks.list[1]
		skill = this.hero.skills.inmolate

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

			if not targets or #targets < a.min_count then
				SU.delay_attack(store, a, 0.16666666666666666)
			else
				a.ts = store.tick_ts
				h.dead = true
				h.hp = 0
				this.health_bar.hidden = true

				goto label_190_0
			end
		end

		a = this.timed_attacks.list[2]
		skill = this.hero.skills.flaming_path

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local targets = U.find_towers_in_range(store.entities, this.pos, a, function(e, o)
				local enemies = U.find_enemies_in_range(store.entities, e.pos, 0, a.enemies_range, a.enemies_vis_flags, a.enemies_vis_bans)

				return (e.template_name == "tower_druid" or not e.barrack) and e.tower.can_be_mod and enemies and #enemies >= a.enemies_min_count
			end)

			if not targets then
				SU.delay_attack(store, a, 0.16666666666666666)
			else
				S:queue(a.sound, a.sound_args)
				U.animation_start(this, a.animation, nil, store.tick_ts)

				if SU.y_hero_wait(store, this, a.hit_time) then
					-- block empty
				else
					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
					table.sort(targets, function(e1, e2)
						return V.dist(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) < V.dist(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
					end)

					for i, target in ipairs(targets) do
						if i > a.max_count then
							break
						end

						local mod = E:create_entity(a.mod)

						mod.modifier.target_id = target.id
						mod.modifier.source_id = this.id
						mod.pos.x, mod.pos.y = target.pos.x, target.pos.y

						queue_insert(store, mod)
					end

					SU.y_hero_animation_wait(this)
				end

				goto label_190_0
			end
		end

		brk, sta = SU.y_soldier_ranged_attacks(store, this)

		if brk then
			-- block empty
		else
			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_190_0::

		coroutine.yield()
	end
end

scripts.hero_phoenix_ultimate = {}

function scripts.hero_phoenix_ultimate.can_fire_fn(this, x, y, store)
	return not GR:cell_is(x, y, TERRAIN_FAERIE) and P:valid_node_nearby(x, y, 1.4285714285714286, NF_POWER_3)
end

function scripts.hero_phoenix_ultimate.update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {
		1,
		2,
		3
	}, true, NF_POWER_3)

	if #nodes < 1 then
		log.error("hero_phoenix_ultimate: could not find valid node")
		queue_remove(store, this)

		return
	end

	local node = {
		pi = nodes[1][1],
		spi = nodes[1][2],
		ni = nodes[1][3]
	}

	this.pos = P:node_pos(node.pi, node.spi, node.ni)

	U.y_animation_play(this, "place", nil, store.tick_ts)
	U.y_wait(store, this.activate_delay)
	S:queue(this.sound_events.activate)
	U.y_animation_play(this, "activate", nil, store.tick_ts)

	this.tween.disabled = nil

	local targets

	while store.tick_ts - a.ts < a.duration and not targets do
		U.y_wait(store, 0.2)
		coroutine.yield()

		targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)
	end

	this.tween.disabled = true

	U.y_ease_key(store, this.render.sprites[2], "alpha", this.render.sprites[2].alpha, 255, 0.2)
	SU.insert_sprite(store, a.hit_fx, this.pos)
	SU.insert_sprite(store, a.hit_decal, this.pos)

	targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.damage_vis_bans)

	if targets then
		for _, t in pairs(targets) do
			local d = E:create_entity("damage")

			d.value = math.random(a.damage_min, a.damage_max)
			d.damage_type = a.damage_type
			d.target_id = t.id
			d.source_id = this.id

			queue_damage(store, d)
		end
	end

	S:queue(this.sound_events.explode)
	queue_remove(store, this)
end

scripts.hero_wilbur = {}

function scripts.hero_wilbur.get_info(this)
	local m = E:get_template("shot_wilbur")
	local min, max = 3 * m.bullet.damage_min, 3 * m.bullet.damage_max

	min, max = min * this.unit.damage_factor, max * this.unit.damage_factor
	min, max = math.ceil(min), math.ceil(max)

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_type = m.bullet.damage_type,
		damage_icon = this.info.damage_icon,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_wilbur.missile_filter_fn(e, origin)
	local pp = P:predict_enemy_pos(e, 2)
	local allow = math.abs(pp.y - origin.y) < 80

	return allow
end

function scripts.hero_wilbur.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	local s

	s = this.hero.skills.missile

	if initial and s.level > 0 then
		local a = this.ranged.attacks[2]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.damage_max = s.damage_max[s.level]
		b.bullet.damage_min = s.damage_min[s.level]
	end

	s = this.hero.skills.smoke

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		local au = E:get_template(a.bullet)

		au.aura.duration = s.duration[s.level]

		local m = E:get_template(au.aura.mod)

		m.slow.factor = s.slow_factor[s.level]
	end

	s = this.hero.skills.box

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local pl = E:get_template(a.payload)

		pl.spawner.count = s.count[s.level]
	end

	s = this.hero.skills.engine
	this.max_chomp_bots = nil
	if initial and s.level > 0 then
		local chomp_bot = E:get_template("soldier_chomp_bot")
		chomp_bot.health.hp_max = s.chomp_bot_hp[s.level]
		this.max_chomp_bots = s.max_chomp_bots[s.level]
	end

	s = this.hero.skills.ultimate

	if initial and s.level > 0 then
		local u = E:get_template(s.controller_name)
		u.cooldown = s.cooldown[s.level]

		local m = E:get_template("drone_wilbur")

		m.custom_attack.damage_max = s.damage[s.level]
		m.custom_attack.damage_min = s.damage[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_wilbur.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.ranged.order = U.attack_order(this.ranged.attacks)

	local a = E:create_entity("aura_bobbing_wilbur")

	a.aura.source_id = this.id
	a.aura.ts = store.tick_ts
	a.pos = this.pos

	queue_insert(store, a)

	if this.auras then
		for _, a in pairs(this.auras.list) do
			if a.cooldown == 0 then
				local e = E:create_entity(a.name)

				e.pos = V.vclone(this.pos)
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts

				queue_insert(store, e)
			end
		end
	end

	return true
end

function scripts.hero_wilbur.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn_kr5(store, this)
			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		SU.heroes_visual_learning_upgrade(store, this)
		SU.heroes_lone_wolves_upgrade(store, this)
		SU.alliance_merciless_upgrade(store, this)
		SU.alliance_corageous_upgrade(store, this)

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			-- block empty
		end

		a = this.timed_attacks.list[1]
		skill = this.hero.skills.smoke

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local target = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)

			if not target then
				SU.delay_attack(store, a, 0.06666666666666667)
			else
				S:queue(a.sound, a.sound_args)
				U.y_animation_play(this, a.animations[1], nil, store.tick_ts)
				SU.hero_gain_xp_from_skill(this, skill)

				local au = E:create_entity(a.bullet)

				au.pos.x, au.pos.y = this.pos.x, this.pos.y

				queue_insert(store, au)
				U.y_animation_play(this, a.animations[2], nil, store.tick_ts)
				U.animation_start(this, a.animations[3], nil, store.tick_ts, false)
				SU.y_hero_animation_wait(this)

				a.ts = store.tick_ts

				goto label_199_0
			end
		end

		a = this.timed_attacks.list[2]
		skill = this.hero.skills.box

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local target_info = U.find_enemies_in_paths(store.entities, this.pos, a.range_nodes_min, a.range_nodes_max, a.max_path_dist, a.vis_flags, a.vis_bans, true, function(e)
				return not U.flag_has(P:path_terrain_props(e.nav_path.pi), TERRAIN_FAERIE)
			end)

			if not target_info then
				SU.delay_attack(store, a, 0.16666666666666666)
			else
				local target = target_info[1].enemy
				local origin = target_info[1].origin
				local start_ts = store.tick_ts
				local bullet_to_ni = origin[3] - math.random(8, 13)

				bullet_to_ni = km.clamp(5, P:get_end_node(origin[1]), bullet_to_ni)

				local bullet_to = P:node_pos(origin[1], 1, bullet_to_ni)
				local flip = bullet_to.x < this.pos.x

				S:queue(a.sound)
				U.animation_start(this, a.animation, flip, store.tick_ts)

				if SU.y_hero_wait(store, this, a.shoot_time) then
					goto label_199_0
				end

				SU.hero_gain_xp_from_skill(this, skill)

				a.ts = store.tick_ts

				local e = E:create_entity(a.payload)

				e.spawner.pi = origin[1]
				e.spawner.ni = bullet_to_ni
				e.pos = bullet_to

				local b = E:create_entity(a.bullet)

				b.pos.x = this.pos.x + (flip and -1 or 1) * a.bullet_start_offset.x
				b.pos.y = this.pos.y + a.bullet_start_offset.y
				b.bullet.from = V.vclone(b.pos)
				b.bullet.to = V.vclone(e.pos)
				b.bullet.hit_payload = e

				queue_insert(store, b)
				SU.y_hero_animation_wait(this)

				a.ts = store.tick_ts

				goto label_199_0
			end
		end

		
		brk, sta = y_hero_ranged_attacks(store, this)

		if brk then
			-- block empty
		else
			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_199_0::

		coroutine.yield()
	end
end

scripts.hero_wilbur_ultimate = {}

function scripts.hero_wilbur_ultimate.can_fire_fn(this, x, y, store)
	return true
end

function scripts.hero_wilbur_ultimate.update(this, store)
	for i, o in ipairs(this.spawn_offsets) do
		local e = E:create_entity(this.entity)

		e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
		e.spawn_index = i

		queue_insert(store, e)
	end

	queue_remove(store, this)
end

scripts.aura_wilbur_bobbing = {}

function scripts.aura_wilbur_bobbing.update(this, store)
	local hero = store.entities[this.aura.source_id]
	local s3 = hero.render.sprites[3]
	local nr = hero.nav_rally
	local layers = {
		hero.render.sprites[3],
		hero.render.sprites[4]
	}
	local r_names = {
		"r",
		"r"
	}
	local dist_th = 40
	local max_angle = km.deg2rad(5)
	local angle_step = km.deg2rad(20) * store.tick_length
	local h_max = 4
	local h_step = 20 * store.tick_length
	local h_ts = store.tick_ts

	while true do
		local dx = this.pos.x - nr.center.x
		local sign = dx < 0 and -1 or 1
		local dest_angle = km.clamp(-max_angle, max_angle, max_angle * dx / dist_th)

		for _, s in pairs(layers) do
			local da = km.clamp(-angle_step, angle_step, dest_angle - s.r)

			s.r = s.r + da
		end

		for _, s in pairs(layers) do
			local o = s.offset

			if s3.name == "idle" then
				o.y = h_max * math.sin(2 * math.pi * (store.tick_ts - h_ts))
			else
				local dy = km.clamp(-h_step, h_step, -o.y)

				o.y = o.y + dy
				h_ts = store.tick_ts
			end
		end

		coroutine.yield()
	end
end

scripts.drone_wilbur = {}

function scripts.drone_wilbur.update(this, store)
	local sd = this.render.sprites[1]
	local ss = this.render.sprites[2]
	local ca = this.custom_attack
	local fm = this.force_motion

	local function find_target(range)
		local target, targets

		for _, set in pairs(ca.range_sets) do
			local min_range, max_range = unpack(set)

			target, targets = U.find_nearest_enemy(store.entities, this.pos, min_range, max_range, ca.vis_flags, ca.vis_bans)

			if target then
				break
			end
		end

		if not target then
			return nil
		end

		local drones = LU.list_entities(store.entities, this.template_name)
		local drone_target_ids = table.map(drones, function(k, v)
			return v._chasing_target_id or 0
		end)
		local untargeted = table.filter(targets, function(k, v)
			return not table.contains(drone_target_ids, v.id)
		end)

		for _, nt in ipairs(targets) do
			if table.contains(untargeted, nt) then
				return nt
			end
		end

		return target
	end

	local shoot_ts, search_ts, shots = 0, 0, 0
	local target, targets, dist
	local dest = V.v(this.pos.x, this.pos.y)

	this.start_ts = store.tick_ts
	fm.a_step = fm.a_step + math.random(-3, 3)
	this.tween.ts = U.frandom(0, 1)

	local oos = {
		V.v(-6, 0),
		V.v(6, 2),
		V.v(2, 6),
		V.v(0, -6)
	}
	local oo = oos[this.spawn_index]

	U.animation_start(this, "idle", nil, store.tick_ts, true)

	while store.tick_ts - this.start_ts <= this.duration do
		search_ts = store.tick_ts

		if shots < ca.max_shots then
			target = find_target(ca.max_range)
		else
			target = nil
		end

		this._chasing_target_id = target and target.id or nil

		if target then
			repeat
				dest.x, dest.y = target.pos.x + oo.x, target.pos.y + oo.y
				sd.flip_x = this.pos.x < dest.x

				U.force_motion_step(this, store.tick_length, dest)
				coroutine.yield()

				dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
			until dist < ca.shoot_range or target.health.dead or band(ca.vis_flags, target.vis.bans) ~= 0

			if shots < ca.max_shots and store.entities[target.id] and not target.health.dead and band(ca.vis_flags, target.vis.bans) == 0 and store.tick_ts - shoot_ts > ca.cooldown then
				shots = shots + 1

				if math.random() < ca.sound_chance then
					S:queue(ca.sound)
				end

				U.animation_start(this, "shoot", this.pos.x < target.pos.x, store.tick_ts, false)

				for i = 1, ca.hit_cycles do
					local hit_ts = store.tick_ts

					while store.tick_ts - hit_ts < ca.hit_time do
						U.force_motion_step(this, store.tick_length, dest)

						sd.flip_x = this.pos.x < target.pos.x

						coroutine.yield()
					end

					local d = SU.create_attack_damage(ca, target.id, this.id)

					queue_damage(store, d)
				end

				while not U.animation_finished(this) do
					U.force_motion_step(this, store.tick_length, dest)

					sd.flip_x = this.pos.x < target.pos.x

					coroutine.yield()
				end

				U.animation_start(this, "idle", nil, store.tick_ts, true)

				shoot_ts = store.tick_ts
			end

			U.animation_start(this, "idle", nil, store.tick_ts, true)
		end

		while store.tick_ts - search_ts < ca.search_cooldown do
			U.force_motion_step(this, store.tick_length, dest)
			coroutine.yield()
		end
	end

	U.y_ease_keys(store, {
		sd,
		sd.offset,
		ss
	}, {
		"alpha",
		"y",
		"alpha"
	}, {
		255,
		50,
		255
	}, {
		0,
		85,
		0
	}, 0.4)
	queue_remove(store, this)
end

scripts.aura_box_wilbur = {}

function scripts.aura_box_wilbur.update(this, store)
	local sp = this.spawner

	this.render.sprites[1].ts = store.tick_ts

	SU.insert_sprite(store, "decal_rock_crater", this.pos)
	U.y_wait(store, sp.spawn_time)

	this.render.sprites[1].z = Z_DECALS

	S:queue(sp.sound)

	for i = 1, sp.count do
		local e = E:create_entity(sp.entity)

		e.pos.x, e.pos.y = this.pos.x, this.pos.y
		e.nav_path.pi = sp.pi
		e.nav_path.spi = km.zmod(i, 3)
		e.nav_path.ni = sp.ni

		queue_insert(store, e)
	end

	SU.insert_sprite(store, "fx_box_wilbur_smoke_b", V.v(this.pos.x + 33 - 40, this.pos.y + 32 - 20))
	SU.insert_sprite(store, "fx_box_wilbur_smoke_a", V.v(this.pos.x + 60 - 40, this.pos.y + 32 - 22))
	SU.insert_sprite(store, "fx_box_wilbur_smoke_a", V.v(this.pos.x + 10 - 40, this.pos.y + 32 - 22), true)
	U.y_wait(store, fts(10))
	U.y_ease_key(store, this.render.sprites[1], "alpha", 255, 0, 1)
	queue_remove(store, this)
end

scripts.shot_wilbur = {}

function scripts.shot_wilbur.update(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	local source = store.entities[b.source_id]

	if b.shot_index < 3 then
		local flip_x = b.to.x < source.pos.x
		local sfx = E:create_entity(b.shoot_fx)

		sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
		sfx.render.sprites[1].flip_x = flip_x
		sfx.render.sprites[1].r = (flip_x and -1 or 1) * km.deg2rad(-30)
		sfx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, sfx)
	end

	if b.shot_index == 1 and target and not U.flag_has(target.vis.flags, F_FLYING) then
		local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni

		ni = ni + 6

		for i = 1, 6 do
			local sign = i % 2 == 0 and 1 or -1
			local p = P:node_offset_pos(10 * sign, pi, spi, ni - i)
			local fx = E:create_entity(b.hit_fx)

			fx.pos.x, fx.pos.y = p.x, p.y
			fx.render.sprites[1].ts = store.tick_ts + fts(2 * i)

			queue_insert(store, fx)
		end
	end

	U.y_wait(store, b.flight_time)

	if target then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)
	end

	queue_remove(store, this)
end

scripts.soldier_chomp_bot = {}

function scripts.soldier_chomp_bot.insert(this, store, script)
	this.render.sprites[1].hidden = true
	this.render.sprites[2].hidden = true
	this.health.dead = true

	return scripts.soldier_reinforcement.insert(this, store, script)
end

function scripts.soldier_chomp_bot.update(this, store, script)
	local path_ni = 1
	local path_spi = 1
	local path_pi = 1
	local node_pos
	local available_paths = {}

	for k, v in pairs(P.paths) do
		table.insert(available_paths, k)
	end

	if store.level.ignore_walk_backwards_paths then
		available_paths = table.filter(available_paths, function(k, v)
			return not table.contains(store.level.ignore_walk_backwards_paths, v)
		end)
	end

	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths)

	if #nearest > 0 then
		path_pi, path_spi, path_ni = unpack(nearest[1])
	end

	path_spi = 1
	path_ni = path_ni - 2

	U.y_wait(store, 1.5)
	local spawner = this.spawner
	if spawner and spawner.health and not spawner.health.dead then
		local bullet = E:create_entity(this.spawn_bullet)
		bullet.pos = V.vclone(spawner.pos)
		bullet.pos.y = bullet.pos.y + 55
		bullet.bullet.from = V.vclone(bullet.pos)
		bullet.bullet.to = V.vclone(this.pos)
		bullet.bullet.target_id = this.id
		bullet.bullet.source_id = spawner.id
		queue_insert(store, bullet)
	end

	U.y_wait(store, 0.5)
	this.health.dead = nil
	this.render.sprites[1].hidden = nil
	this.render.sprites[2].hidden = nil

	local brk, stam

	this.reinforcement.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts
	this.nav_rally.center = nil
	this.nav_rally.pos = V.vclone(this.pos)

	if this.sound_events and this.sound_events.raise then
		S:queue(this.sound_events.raise)
	end
	
	U.y_animation_play(this, "raise", this.render.sprites[1].flip_x, store.tick_ts, 1)

	if not this.health.dead then
		this.health_bar.hidden = nil
	end

	local distance = 0

	while true do
		if this.health.dead then
			this.ui.can_click = false
			this.ui.can_select = false
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			this.health.hp = 0
			this.render.sprites[2].hidden = true

			U.animation_start(this, "death", nil, store.tick_ts, false, 1)
			S:queue(this.sound_events.death)
			U.y_animation_wait(this, 1)
			queue_remove(store, this)

			return
		end

		if path_ni <= 0 or not P:is_node_valid(path_pi, path_ni) or GR:cell_is(this.nav_rally.pos.x, this.nav_rally.pos.y, bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) then
			this.ui.can_click = false
			this.ui.can_select = false
			this.tween.ts = store.tick_ts
			this.death_transformation_entity_name = nil
			SU.y_soldier_death(store, this)
			queue_remove(store, this)
			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if this.melee then
				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
					goto label_497_0
				end
			end

			node_pos = this.nav_rally.pos
			distance = V.dist2(node_pos.x, node_pos.y, this.pos.x, this.pos.y)

			if distance < 4 then
				path_ni = path_ni - 1
				this.nav_rally.pos = P:node_pos(path_pi, path_spi, path_ni)
			end

			if SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_regen(store, this)
			end
		end

		::label_497_0::

		coroutine.yield()
	end
end

scripts.mod_chomp_bot_transformation = {}

function scripts.mod_chomp_bot_transformation.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]
	local aura = store.entities[m.source_id]
	local source
	if aura then
		source = store.entities[aura.aura.source_id]
	end

	if not target or not target.health or target.health.dead then
		return false
	end

	if not source or not source.health or source.health.dead then
		return false
	end

	local entity_name = this.entity

	target.death_transformation_entity_name = entity_name
	target.old_death_spawns = target.death_spawns

	if not target.death_spawns or target.death_spawns.name ~= entity_name then
		target.death_spawns = nil
	end

	return true
end

function scripts.mod_chomp_bot_transformation.remove(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]
	local aura = store.entities[m.source_id]
	local source = nil
	if aura then
		aura = aura.aura
		source = store.entities[aura.source_id]
	end

	if target and source then
		local can_spawn = target.health.dead and target.death_transformation_entity_name and not source.health.dead and source.max_chomp_bots and not target._necromancer_entity_name and 
		band(target.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_NO_SPAWNS)) == 0

		if can_spawn then
			local chomp_bots = table.filter(store.entities, function(k, v)
				return v.template_name == target.death_transformation_entity_name and not v.health.dead and not v.pending_removal and v.soldier
			end)

			if chomp_bots and #chomp_bots >= source.max_chomp_bots then
				can_spawn = false
			end
		end

		local isChompBot = target.template_name == target.death_transformation_entity_name
		if isChompBot and target.health.hp_max < 50 then
			can_spawn = false
		end
		
		if can_spawn then
			target.death_spawns = nil

			local s = E:create_entity(target.death_transformation_entity_name)

			s.pos = V.vclone(target.pos)
			s.spawner = source
			s.source = target

			if s.nav_path then
				s.nav_path.pi = this.nav_path.pi
				s.nav_path.spi = this.nav_path.spi
				s.nav_path.ni = this.nav_path.ni + 2
			end

			if isChompBot then
				s.health.hp_max = math.ceil(target.health.hp_max * 0.8)
			end

			queue_insert(store, s)
		else
			target._necromancer_entity_name = nil
			target.death_spawns = target.old_death_spawns
		end
	end

	return true
end

scripts.smokebeard_engineer_ray = {}

function scripts.smokebeard_engineer_ray.update(this, store, script)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local source = store.entities[b.source_id]

	if not source then
		queue_remove(store, this)

		return
	end

	local dest = b.to and V.vclone(b.to) or V.vclone(target.pos)

	s.scale = V.v(1, 1)

	local function update_sprite()
		this.pos.x = source.pos.x
		this.pos.y = source.pos.y + 55
		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
	end

	s.ts = store.tick_ts

	if b.hit_fx then
		SU.insert_sprite(store, b.hit_fx, b.to)
	end

	while not U.animation_finished(this) do
		update_sprite()
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.hero_alleria = {}

function scripts.hero_alleria.fixed_ranged_filter_fn(e, origin)
	return U.is_inside_ellipse(e.pos, V.v(838, 491), 125, 1.368) or U.is_inside_ellipse(e.pos, V.v(540, 357), 75, 1)
end

function scripts.hero_alleria.insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

function scripts.hero_alleria.update(this, store)
	local h = this.health
	local he = this.hero
	local brk, sta, a, skill

	local function find_cat_pos(pos)
		local nodes = P:nearest_nodes(pos.x, pos.y, nil, nil, true, NF_RALLY)

		if #nodes < 1 then
			log.error("cannot insert alleria cat. no valid nodes near %s,%s", pos.x, pos.y)

			return nil
		end

		local n = nodes[1]

		if not P:is_node_valid(n[1], n[3] - 5) then
			return nil
		end

		local npos = P:node_pos(n[1], n[2], n[3] - 5)

		if band(GR:cell_type(npos.x, npos.y), bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) ~= 0 then
			return nil
		end

		return npos
	end

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	local cat = E:create_entity("alleria_cat")

	cat.owner = this

	if this.fixed_mode then
		cat.pos = this.cat_pos
		cat.fixed_mode = true
	else
		cat.pos = find_cat_pos(this.pos)
	end

	cat.nav_rally.center = pos
	cat.nav_rally.pos = pos
	cat.render.sprites[1].z = this.render.sprites[1].z

	queue_insert(store, cat)

	while true do
		if this.fixed_mode then
			brk, sta = SU.y_soldier_ranged_attacks(store, this)

			if brk then
				-- block empty
			else
				SU.soldier_idle(store, this)
			end
		else
			if h.dead then
				SU.y_hero_death_and_respawn(store, this)
			end

			if this.unit.is_stunned then
				SU.soldier_idle(store, this)
			else
				while this.nav_rally.new do
					local cat_pos = find_cat_pos(this.nav_rally.pos)

					if cat_pos then
						cat.nav_rally.center = cat_pos
						cat.nav_rally.pos = cat_pos
						cat.nav_rally.new = true
					end

					if SU.y_hero_new_rally(store, this) then
						goto label_212_0
					end
				end

				if this.melee then
					brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

					if brk or sta ~= A_NO_TARGET then
						goto label_212_0
					end
				end

				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					-- block empty
				elseif SU.soldier_go_back_step(store, this) then
					-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_212_0::

		coroutine.yield()
	end
end

scripts.arrow_multishot_hero_alleria = {}

function scripts.arrow_multishot_hero_alleria.insert(this, store)
	if this.extra_arrows > 0 then
		local targets = U.find_enemies_in_range(store.entities, this.bullet.to, 0, this.extra_arrows_range, F_RANGED, F_NONE, function(e)
			return e.id ~= this.bullet.target_id
		end)

		for i = 1, this.extra_arrows do
			local b = E:clone_entity(this)

			b.extra_arrows = 0

			if targets and targets[i] then
				local t = targets[i]

				b.bullet.target_id = t.id
				b.bullet.to = V.vclone(t.pos)
			end

			queue_insert(store, b)
		end
	end

	return scripts.arrow.insert(this, store)
end

scripts.alleria_cat = {}

function scripts.alleria_cat.update(this, store)
	local h = this.owner
	local ht
	local ba = this.behaviour_attack
	local bs = this.behaviour_scared

	ba.ts = store.tick_ts
	bs.ts = store.tick_ts

	U.y_animation_play(this, "toStand", nil, store.tick_ts)

	while true do
		while this.nav_rally.new do
			this.nav_grid.waypoints = GR:find_waypoints(this.pos, nil, this.nav_rally.pos, this.nav_grid.valid_terrains)

			if SU.y_hero_new_rally(store, this) then
				goto label_216_0
			end
		end

		if h and h.health.dead then
			U.y_animation_play(this, "toSad", nil, store.tick_ts)

			while h.health.dead do
				U.y_animation_play(this, "sadSigh", nil, store.tick_ts)
				U.y_wait(store, U.frandom(1.5, 3))
			end

			U.y_animation_play(this, "toStand", nil, store.tick_ts)
		else
			ht = h and h.soldier.target_id and store.entities[h.soldier.target_id]

			if h and not h.health.dead and ht then
				if store.tick_ts - ba.ts > ba.cooldown then
					local ht_dist = V.dist(ht.pos.x, ht.pos.y, this.pos.x, this.pos.y)

					if ht_dist > ba.min_distance and ht_dist < ba.max_distance then
						U.set_destination(this, V.v(ht.pos.x, ht.pos.y + ba.y_offset))
						U.animation_start(this, "walk", ht.pos.x < this.pos.x, store.tick_ts, true)

						while not U.walk(this, store.tick_length) do
							coroutine.yield()
						end
					end

					U.animation_start(this, ba.animation, nil, store.tick_ts)
					U.y_wait(store, ba.hit_time)
					S:queue(ba.sound)
					U.y_animation_wait(this)

					ba.cooldown = U.frandom(ba.min_cooldown, ba.max_cooldown)
					ba.ts = store.tick_ts

					goto label_216_0
				elseif store.tick_ts - bs.ts > bs.cooldown then
					U.y_animation_play(this, bs.animation, nil, store.tick_ts, 2)

					bs.cooldown = U.frandom(bs.min_cooldown, bs.max_cooldown)
					bs.ts = store.tick_ts

					goto label_216_0
				end
			end

			SU.soldier_idle(store, this)
		end

		::label_216_0::

		coroutine.yield()
	end
end

scripts.hero_baby_malik = {}

function scripts.hero_baby_malik.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	local s

	s = this.hero.skills.smash

	for si, sl in ipairs(s.skill_upgrade_levels) do
		if sl <= hl then
			s.level = si
		end
	end

	if s.level > 0 then
		local a = this.melee.attacks[3]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end

	s = this.hero.skills.fissure

	for si, sl in ipairs(s.skill_upgrade_levels) do
		if sl <= hl then
			s.level = si
		end
	end

	if s.level > 0 then
		local a = this.melee.attacks[4]

		a.disabled = nil
		a.damage_radius = s.damage_radius[s.level]
		a.damage_max = s.damage_max[s.level]
		a.damage_min = s.damage_min[s.level]

		local au = E:get_template(a.hit_aura)

		au.aura.damage_radius = s.damage_radius[s.level]
		au.aura.damage_min = s.damage_min[s.level]
		au.aura.damage_max = s.damage_max[s.level]
		au.aura.level = s.level
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_baby_malik.update(this, store)
	local h = this.health
	local he = this.hero
	local brk, sta, a, skill

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_218_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			elseif SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_218_0::

		coroutine.yield()
	end
end

scripts.aura_baby_malik_fissure = {}

function scripts.aura_baby_malik_fissure.update(this, store)
	local a = this.aura

	local function do_attack(pos)
		local fx = E:create_entity(a.fx)

		fx.pos.x, fx.pos.y = pos.x, pos.y
		fx.render.sprites[2].ts = store.tick_ts
		fx.tween.ts = store.tick_ts

		queue_insert(store, fx)

		local targets = U.find_enemies_in_range(store.entities, pos, 0, a.damage_radius, a.vis_flags, a.vis_bans)

		if targets then
			for _, t in pairs(targets) do
				local d = E:create_entity("damage")

				d.value = math.random(a.damage_min, a.damage_max)
				d.damage_type = a.damage_type
				d.source_id = this.id
				d.target_id = t.id

				queue_damage(store, d)

				if U.flags_pass(t.vis, this.stun) then
					local m = E:create_entity(this.stun.mod)

					m.modifier.source_id = this.id
					m.modifier.target_id = t.id

					queue_insert(store, m)
				end
			end

			log.paranoid(">>>> aura_baby_malik_fissure POS:%s,%s  damaged:%s", pos.x, pos.y, table.concat(table.map(targets, function(k, v)
				return v.id
			end), ","))
		end
	end

	do_attack(this.pos)

	local pi, spi, ni

	if a.target_id and store.entities[a.target_id] then
		local np = store.entities[a.target_id].nav_path

		pi, spi, ni = np.pi, np.spi, np.ni
	else
		local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

		if #nodes < 1 then
			log.error("aura_baby_malik_fissure could not find valid nodes near %s,%s", this.pos.x, this.pos.y)

			goto label_219_0
		end

		pi, spi, ni = unpack(nodes[1])
	end

	for i = 1, a.level do
		spi = (spi == 2 or spi == 3) and 1 or math.random() < 0.5 and 2 or 3

		U.y_wait(store, a.spread_delay)

		local nni = ni + i * a.spread_nodes
		local spos = P:node_pos(pi, spi, nni)

		do_attack(spos)

		nni = ni - i * a.spread_nodes
		spos = P:node_pos(pi, spi, nni)

		do_attack(spos)
	end

	::label_219_0::

	queue_remove(store, this)
end

scripts.hero_bolverk = {}

function scripts.hero_bolverk.insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.hero_bolverk.update(this, store)
	local h = this.health
	local he = this.hero
	local brk, sta, a, skill

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_223_0
				end
			end

			a = this.timed_attacks.list[1]

			if store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_count then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					S:queue(a.sound, a.sound_args)
					U.animation_start(this, a.animation, nil, store.tick_ts)

					if SU.y_hero_wait(store, this, a.hit_time) then
						-- block empty
					else
						targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

						if targets then
							for _, target in pairs(targets) do
								local m = E:create_entity(a.mod)

								m.modifier.target_id = target.id
								m.modifier.source_id = this.id

								queue_insert(store, m)
							end
						end

						SU.y_hero_animation_wait(this)

						a.ts = store.tick_ts
					end

					goto label_223_0
				end
			end

			if this.melee then
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_223_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_223_0::

		coroutine.yield()
	end
end

scripts.enemy_gnoll_blighter = {}

function scripts.enemy_gnoll_blighter.update(this, store, script)
	local ta = this.timed_attacks.list[1]

	local function ready_to_wither()
		if store.tick_ts - ta.ts < ta.cooldown then
			return false
		end

		if not this.enemy.can_do_magic then
			return false
		end

		local plants = table.filter(store.entities, function(_, e)
			return e.plant and not e.plant.blocked and U.is_inside_ellipse(e.pos, this.pos, ta.range)
		end)

		return #plants > 0, plants
	end

	::label_224_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local ready, plants = ready_to_wither()

			if ready then
				ta.ts = store.tick_ts

				U.animation_start(this, ta.animation, nil, store.tick_ts, false)

				if SU.y_enemy_wait(store, this, ta.cast_time) then
					goto label_224_0
				end

				local target = plants[1]
				local m = E:create_entity(ta.mod)

				m.modifier.target_id = target.id
				m.modifier.source_id = this.id

				queue_insert(store, m)
				U.y_animation_wait(this)

				goto label_224_0
			end

			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_wither()
			end)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_224_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_224_0
						end

						coroutine.yield()
					end
				elseif ranged then
					while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							goto label_224_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_hyena = {}

function scripts.enemy_hyena.update(this, store)
	local coward = false
	local coward_ts = 0

	::label_228_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if not coward then
				local blocker = #this.enemy.blockers > 0 and store.entities[this.enemy.blockers[1]] or nil

				if blocker then
					U.unblock_all(store, this)

					coward_ts = store.tick_ts
					coward = true
					this.vis.bans = F_BLOCK
					this.motion.max_speed = this.motion.max_speed * this.coward_speed_factor

					-- AC:inc("SHEZI_BANZAI_ED")

					goto label_228_0
				end
			elseif store.tick_ts - coward_ts > this.coward_duration then
				coward = false
				this.vis.bans = 0
				this.motion.max_speed = this.motion.max_speed / this.coward_speed_factor

				goto label_228_0
			end

			SU.y_enemy_walk_step(store, this, coward and "run" or "walk")
		end
	end
end

scripts.enemy_ettin = {}

function scripts.enemy_ettin.update(this, store)
	this.insane.cooldown = math.random(this.insane.cooldown_min, this.insane.cooldown_max)
	this.insane.ts = store.tick_ts

	local function ready_to_insane()
		return store.tick_ts - this.insane.ts > this.insane.cooldown and not this.__mod_ogre_magi_shield_mod
	end

	::label_229_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_insane() then
				this.insane.ts = store.tick_ts

				U.animation_start(this, "insaneStart", nil, store.tick_ts, false)

				if SU.y_enemy_wait(store, this, this.insane.hit_time) then
					goto label_229_0
				end

				local damage_value = math.random(this.insane.damage_min, this.insane.damage_max)

				damage_value = km.clamp(0, this.health.hp - 1, damage_value)

				local d = E:create_entity("damage")

				d.damage_type = this.insane.damage_type
				d.value = damage_value
				d.target_id = this.id
				d.source_id = this.id

				queue_damage(store, d)
				U.y_animation_wait(this)
				U.animation_start(this, "insaneLoop", nil, store.tick_ts, true)

				if SU.y_enemy_wait(store, this, this.insane.stun_duration) then
					goto label_229_0
				end

				U.animation_start(this, "idle", nil, store.tick_ts, true)
			end

			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_insane()
			end)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_229_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_229_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_perython_carrier = {}

function scripts.enemy_perython_carrier.update(this, store)
	local carrying = true
	local drop_delay = this.drop_delay and U.frandom(this.drop_delay[1], this.drop_delay[2]) or 0
	local drop_delay_ts = store.tick_ts

	local function ready_to_drop(check_delay)
		if not carrying then
			return false
		end

		if check_delay and store.tick_ts - drop_delay_ts < drop_delay then
			return false
		end

		drop_delay_ts = store.tick_ts

		local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, this.spawn_trigger_range, 0, F_FLYING)

		return targets ~= nil
	end

	local function drop_payload()
		SU.do_death_spawns(store, this)

		carrying = false
		this.death_spawns.quantity = 0

		coroutine.yield()

		this.render.sprites[3].hidden = true
	end

	while true do
		if this.health.dead then
			if this.death_spawns.concurrent_with_death then
				this.render.sprites[3].hidden = true
			end

			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			if carrying and not U.has_modifier_types(store, this, MOD_TYPE_TELEPORT, MOD_TYPE_TIMELAPSE) then
				drop_payload()
			end

			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_drop() then
				drop_payload()
			end

			SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_drop(true)
			end)
		end
	end
end

scripts.enemy_twilight_elf_harasser = {}

function scripts.enemy_twilight_elf_harasser.update(this, store)
	::label_236_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if this.dodge.active and this.vis.bans ~= F_ALL then
				this.dodge.active = false
				this.dodge.ts = store.tick_ts

				local dn = math.random(this.dodge.min_nodes, this.dodge.max_nodes)
				local nni = km.clamp(this.dodge.nodeslimit, P:get_end_node(this.nav_path.pi) - this.dodge.nodeslimit, this.nav_path.ni + dn)

				if not P:is_node_valid(this.nav_path.pi, nni) then
					goto label_236_0
				end

				local cpos = P:node_pos(this.nav_path.pi, 1, nni)

				if GR:cell_is(cpos.x, cpos.y, TERRAIN_FAERIE) then
					goto label_236_0
				end

				U.unblock_all(store, this)

				local bans = this.vis.bans

				this.vis.bans = F_ALL

				SU.hide_modifiers(store, this, true)
				SU.hide_auras(store, this, true)
				U.y_animation_play(this, "jumpOut", nil, store.tick_ts)

				this.nav_path.ni = nni

				local npos = P:node_pos(this.nav_path)

				this.pos.x, this.pos.y = npos.x, npos.y

				U.y_animation_play(this, "jumpIn", nil, store.tick_ts)

				this.vis.bans = bans
				this.vis._bans = nil

				SU.show_modifiers(store, this, true)
				SU.show_auras(store, this, true)

				local sa = this.shadow_shot
				local target = U.find_nearest_soldier(store.entities, this.pos, sa.min_range, sa.max_range, sa.vis_flags, sa.vis_bans)

				if target then
					local shot_ts = store.tick_ts
					local an, af, ai = U.animation_name_facing_point(this, sa.animation, target.pos)

					U.animation_start(this, an, af, store.tick_ts, false)

					while store.tick_ts - shot_ts < sa.shoot_time do
						if this.health.dead or this.unit.is_stunned then
							goto label_236_0
						end

						coroutine.yield()
					end

					local bo = sa.bullet_start_offset[ai]
					local b = E:create_entity(sa.bullet)

					b.pos = V.vclone(this.pos)
					b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * bo.x, b.pos.y + bo.y
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
					b.bullet.target_id = target.id

					queue_insert(store, b)

					while not U.animation_finished(this) do
						if this.health.dead or this.unit.is_stunned then
							goto label_236_0
						end

						coroutine.yield()
					end

					U.animation_start(this, "idle", nil, store.tick_ts, true)
				end

				goto label_236_0
			end

			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, function(store, this)
				return this.dodge.active
			end)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_236_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not this.dodge.active do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_236_0
						end

						coroutine.yield()
					end
				elseif ranged then
					local a = this.ranged.attacks[1]

					if this.unit.is_stunned or this.dodge.active or #this.enemy.blockers ~= 0 then
						goto label_236_0
					end

					local m = E:create_entity("mod_twilight_elf_harasser")

					m.modifier.source_id = this.id
					m.modifier.target_id = ranged.id

					queue_insert(store, m)

					a.ts = store.tick_ts

					SU.y_enemy_do_loopable_ranged_attack(store, this, ranged, a)
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_catapult = {}

function scripts.enemy_catapult.update(this, store)
	local phase = 1
	local start_ts
	local a = this.ranged.attacks[1]

	::label_238_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if phase == 2 then
			if not start_ts then
				start_ts = store.tick_ts
				a.ts = store.tick_ts
			end

			if store.tick_ts - start_ts > this.duration then
				phase = phase + 1

				goto label_238_0
			end

			if store.tick_ts - a.ts > a.cooldown then
				local targets = table.filter(store.entities, function(k, v)
					return not v.pending_removal and v.health and not v.health.dead and v.vis and band(v.vis.flags, a.vis_bans) == 0 and band(v.vis.bans, a.vis_flags) == 0 and v.pos.x < a.max_x and v.pos.y > a.min_x
				end)

				if #targets > 0 then
					SU.y_enemy_range_attacks(store, this, table.random(targets))
				end
			end
		end

		if phase == 1 or phase == 3 then
			U.unblock_all(store, this)

			local bans = this.vis.bans

			this.health_bar.hidden = true
			this.vis.bans = F_ALL
			this.nav_path.dir = phase == 1 and 1 or -1

			local stop_ni = phase == 1 and this.stop_ni or nil

			while SU.y_enemy_walk_step(store, this) do
				if this.health.dead then
					goto label_238_0
				end

				if stop_ni and this.nav_path.ni == stop_ni then
					break
				end

				coroutine.yield()
			end

			U.animation_start(this, "idle", this.render.sprites[1].flip_x, store.tick_ts, true)

			if phase == 3 then
				queue_remove(store, this)

				return
			end

			this.health_bar.hidden = false
			this.vis.bans = bans
			phase = phase + 1
		end

		coroutine.yield()
	end
end

scripts.enemy_bandersnatch = {}

function scripts.enemy_bandersnatch.fn_filter_melee(this, store, attack, target)
	local flip_x = this.render.sprites[1].flip_x

	return table.contains(this.enemy.blockers, target.id) and target.pos.x >= this.pos.x and not flip_x or target.pos.x < this.pos.x and flip_x
end

function scripts.enemy_bandersnatch.update(this, store)
	local rolling = true
	local ta = this.timed_attacks.list[1]

	ta.ts = store.tick_ts
	this.vis.bans = this.vis.bans_rolling

	local function ready_to_spines()
		return store.tick_ts - ta.ts > ta.cooldown
	end

	local function do_spines()
		ta.ts = store.tick_ts

		U.animation_start(this, ta.animation, nil, store.tick_ts)

		while store.tick_ts - ta.ts < ta.shoot_time do
			if this.health.dead or this.unit.is_stunned then
				return true
			end

			coroutine.yield()
		end

		local a = E:create_entity(ta.bullet)

		a.pos.x, a.pos.y = this.pos.x + (this.render.sprites[1].flip_x and -5 or 7), this.pos.y + 18
		a.source_id = this.id
		a.ts = store.tick_ts

		queue_insert(store, a)

		while not U.animation_finished(this) do
			coroutine.yield()
		end

		ta.ts = store.tick_ts
	end

	::label_241_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			U.cleanup_blockers(store, this)

			if not rolling and not U.get_blocker(store, this) then
				this.vis.bans = this.vis.bans_rolling

				SU.remove_modifiers(store, this)
				U.y_animation_play(this, "idle2ball", nil, store.tick_ts)

				rolling = true
				this.motion.max_speed = this.motion.min_speed
			end

			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this)

			if not cont then
				-- block empty
			else
				if blocker then
					if rolling then
						local an, af = U.animation_name_facing_point(this, "ball2idle", blocker.pos)

						U.y_animation_play(this, an, af, store.tick_ts)

						this.vis.bans = this.vis.bans_standing
						rolling = false
					end

					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_241_0
					end

					ta.ts = store.tick_ts

					while SU.can_melee_blocker(store, this, blocker) do
						if ready_to_spines() and not do_spines() then
							goto label_241_0
						end

						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_241_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_boomshrooms = {}

function scripts.enemy_boomshrooms.update(this, store)
	if this.render.sprites[1].name == "raise" then
		local next_pos = this.motion.forced_waypoint or P:next_entity_node(this, store.tick_length)
		local an, af = U.animation_name_facing_point(this, "raise", next_pos)

		U.y_animation_play(this, an, af, store.tick_ts, 1)
	end

	::label_244_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_244_0
					end

					if SU.can_melee_blocker(store, this, blocker) then
						this.health.hp = 0

						coroutine.yield()

						goto label_244_0
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_shroom_breeder = {}

function scripts.enemy_shroom_breeder.update(this, store)
	local a = this.timed_attacks.list[1]

	a.ts = store.tick_ts

	local function ready_to_transform()
		return this.enemy.can_do_magic and store.tick_ts - a.ts > a.cooldown
	end

	::label_245_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_transform() then
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
					return table.contains(a.allowed_templates, e.template_name)
				end)

				if not targets then
					SU.delay_attack(store, a, 0.5)
				else
					a.ts = store.tick_ts

					U.animation_start(this, a.animation, nil, store.tick_ts, false)

					while store.tick_ts - a.ts < a.cast_time do
						if this.health.dead or this.unit.is_stunned then
							goto label_245_0
						end

						coroutine.yield()
					end

					for i, target in ipairs(targets) do
						if i > a.max_count then
							break
						end

						if not U.flags_pass(target.vis, a) then
							-- block empty
						else
							local d = E:create_entity("damage")

							d.damage_type = DAMAGE_EAT
							d.source_id = this.id
							d.target_id = target.id

							queue_damage(store, d)

							local e = E:create_entity(a.spawn_name)

							e.pos.x, e.pos.y = target.pos.x, target.pos.y

							if not target.nav_path then
								log.error("Could not find nav_path to transform creature: %s (%s,%s)", target.id, e.pos.x, e.pos.y)
							else
								e.nav_path = table.deepclone(target.nav_path)
								e.render.sprites[1].flip_x = target.render.sprites[1].flip_x

								queue_insert(store, e)
							end
						end
					end

					SU.y_enemy_animation_wait(this)

					goto label_245_0
				end
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, function(store, this)
				return ready_to_transform()
			end) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_gloomy = {}

function scripts.enemy_gloomy.update(this, store)
	local a = this.timed_attacks.list[1]
	local cg = store.count_groups[this.count_group.type]

	this._clones_count = 0
	a.ts = store.tick_ts

	local function ready_to_clone()
		return store.tick_ts - a.ts > a.cooldown and this._clones_count < a.max_clones and (not cg[this.template_name] or cg[this.template_name] < a.count_group_max) and P:nodes_to_defend_point(this.nav_path) > a.nodes_limit
	end

	if this.render.sprites[1].name == "spawnClone" then
		local next_pos = this.motion.forced_waypoint or P:next_entity_node(this, store.tick_length)
		local an, af = U.animation_name_facing_point(this, "spawnClone", next_pos)

		U.y_animation_play(this, an, af, store.tick_ts, 1)
	end

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_clone() then
				local initial_hp = this.health.hp

				U.animation_start(this, a.animation, nil, store.tick_ts, false)
				U.y_wait(store, a.cast_time)

				local e = E:create_entity(a.spawn_name)

				e.render.sprites[1].name = "spawnClone"
				e.timed_attacks.list[1].max_clones = a.max_clones - 1
				e.enemy.gold = 0
				e.health.hp = initial_hp
				e.nav_path.pi = this.nav_path.pi
				e.nav_path.spi = math.random(1, 3)
				e.nav_path.ni = this.nav_path.ni + math.random(5, 10)

				if not P:is_node_valid(e.nav_path.pi, e.nav_path.ni) then
					e.nav_path.ni = this.nav_path.ni
				end

				queue_insert(store, e)
				U.y_animation_wait(this)

				this._clones_count = this._clones_count + 1
				a.ts = store.tick_ts
				a.cooldown = a.cooldown_after
			end

			SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_clone()
			end)
		end
	end
end

scripts.enemy_satyr_hoplite = {}

function scripts.enemy_satyr_hoplite.update(this, store, script)
	local a = this.timed_attacks.list[1]
	local cg = store.count_groups[COUNT_GROUP_CONCURRENT]
	local spread_seed = math.random(1, 10)

	a.ts = store.tick_ts

	local function ready_to_summon(spread)
		return store.tick_ts - a.ts > a.cooldown and this.enemy.can_do_magic and (not cg[a.count_group_name] or cg[a.count_group_name] < a.count_group_max) and P:nodes_to_defend_point(this.nav_path) > a.nodes_limit and (not spread or math.floor(store.tick_ts * 10) % spread_seed == 0)
	end

	::label_252_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_summon(false) then
				U.animation_start(this, a.animation, nil, store.tick_ts, false)

				if SU.y_enemy_wait(store, this, a.spawn_time) then
					goto label_252_0
				end

				a.ts = store.tick_ts

				S:queue(a.sound)

				local e = E:create_entity(a.entity)

				e.spawner.pi = this.nav_path.pi
				e.spawner.spi = this.nav_path.spi
				e.spawner.ni = this.nav_path.ni
				e.spawner.count_group_name = a.count_group_name
				e.spawner.count_group_type = a.count_group_type
				e.spawner.count_group_max = a.count_group_max

				queue_insert(store, e)

				if SU.y_enemy_animation_wait(this) then
					e.spawner.interrupt = true
				else
					a.ts = store.tick_ts
				end

				goto label_252_0
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, function(store, this)
				return ready_to_summon(true)
			end, function(store, this)
				return ready_to_summon(true)
			end) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_twilight_avenger = {}

function scripts.enemy_twilight_avenger.update(this, store, script)
	local a = this.timed_attacks.list[1]

	a.ts = store.tick_ts

	local shield = false

	local function ready_to_cast()
		return store.tick_ts - a.ts > a.cooldown and this.enemy.can_do_magic
	end

	local function enable_shield()
		if not shield then
			shield = true

			SU.armor_inc(this, this.shield_extra_armor)
		end
	end

	local function disable_shield()
		if shield then
			shield = false

			SU.armor_dec(this, this.shield_extra_armor)
		end
	end

	::label_256_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			disable_shield()
			SU.y_enemy_stun(store, this)
		else
			enable_shield()

			if ready_to_cast() then
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

				if targets then
					local target = targets[1]

					target.vis.flags = bor(target.vis.flags, F_DARK_ELF)
					a.ts = store.tick_ts

					U.animation_start(this, a.animation, nil, store.tick_ts, false)

					if SU.y_enemy_wait(store, this, a.cast_time) then
						goto label_256_0
					end

					S:queue(a.sound)

					local m = E:create_entity(a.mod)

					m.modifier.source_id = this.id
					m.modifier.target_id = target.id

					queue_insert(store, m)
					U.y_animation_wait(this)

					a.ts = store.tick_ts

					goto label_256_0
				end

				SU.delay_attack(store, a, fts(10))
			end

			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_cast()
			end)

			if not cont then
				-- block empty
			else
				if blocker then
					disable_shield()

					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_256_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_256_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_twilight_scourger = {}

function scripts.enemy_twilight_scourger.update(this, store, script)
	local a = this.timed_attacks.list[1]

	a.ts = store.tick_ts

	local a_count = 0

	local function ready_to_lash()
		return store.tick_ts - a.ts > a.cooldown and this.enemy.can_do_magic and not U.get_blocker(store, this)
	end

	::label_261_0::

	while true do
		if this.health.dead then
			if not this.enemy.can_do_magic then
				this.death_spawns = nil
			end

			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_lash() then
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_cast_range, a.vis_flags, a.vis_bans, function(e)
					return not table.contains(a.excluded_templates, e.template_name)
				end)

				if not targets or #targets < a.min_count then
					SU.delay_attack(store, a, fts(10))
				else
					for i = 1, a.loops do
						U.animation_start(this, a.animation, nil, store.tick_ts, false)

						local start_ts = store.tick_ts

						for i, event_ts in ipairs(a.event_times) do
							if SU.y_enemy_wait(store, this, event_ts - (store.tick_ts - start_ts)) then
								goto label_261_0
							end

							if i == 2 then
								local decal = E:create_entity(a.cast_decal)

								decal.tween.ts = store.tick_ts
								decal.pos.x, decal.pos.y = this.pos.x, this.pos.y

								queue_insert(store, decal)

								local fx = E:create_entity(a.cast_fx)

								fx.render.sprites[1].ts = store.tick_ts
								fx.pos.x, fx.pos.y = this.pos.x, this.pos.y

								queue_insert(store, fx)
							else
								targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
									return not table.contains(a.excluded_templates, e.template_name)
								end)

								if targets then
									for _, target in pairs(targets) do
										local d = E:create_entity("damage")

										d.damage_type = a.damage_type
										d.value = math.ceil(U.frandom(a.damage_min, a.damage_max))
										d.target_id = target.id
										d.source_id = this.id

										local pd = U.predict_damage(target, d)

										d.value = math.min(pd, target.health.hp - 1)

										queue_damage(store, d)

										local m = E:create_entity(a.mod)

										m.modifier.target_id = target.id
										m.modifier.source_id = this.id

										queue_insert(store, m)
									end
								end
							end
						end

						if SU.y_enemy_animation_wait(this) then
							goto label_261_0
						end
					end

					a.ts = store.tick_ts

					goto label_261_0
				end
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, function(store, this)
				return ready_to_lash()
			end) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_twilight_scourger_banshee = {}

function scripts.enemy_twilight_scourger_banshee.update(this, store, script)
	local kamikaze_target, fading
	local a = this.mod_attack

	a.ts = store.tick_ts

	local ps = E:create_entity(this.particles_name)

	ps.particle_system.track_id = this.id

	queue_insert(store, ps)

	while true do
		if not fading and not kamikaze_target and store.tick_ts - a.ts > a.cooldown then
			local towers = table.filter(store.entities, function(_, e)
				return e.tower and not e.tower_holder and not e.tower.blocked and e.tower.can_be_mod and not e._is_banshee_target and U.is_inside_ellipse(e.pos, this.pos, a.max_range) and not table.contains(a.excluded_templates, e.template_name)
			end)

			if #towers > 0 then
				local target = towers[1]

				target._is_banshee_target = true
				kamikaze_target = target
				this.motion.max_speed = a.max_speed
				this.motion.forced_waypoint = V.vclone(target.pos)
			end
		end

		if not fading and not kamikaze_target and P:nodes_to_defend_point(this.nav_path) < this.fade_nodes_to_defend_point then
			this.tween.disabled = nil
			this.tween.ts = store.tick_ts
			fading = true
		end

		if fading then
			ps.particle_system.alphas[1] = this.render.sprites[1].alpha
		end

		if not SU.y_enemy_walk_step(store, this) and kamikaze_target then
			if kamikaze_target.tower and kamikaze_target.tower.upgrade_to then
				for _, e in pairs(store.entities) do
					if e.tower and e.tower.holder_id == kamikaze_target.tower.holder_id and V.veq(e.pos, kamikaze_target.pos) then
						log.debug("banshee target %s changed for %s", kamikaze_target.id, e.id)

						kamikaze_target = e

						break
					end
				end
			end

			local m = E:create_entity(a.mod)

			m.modifier.target_id = kamikaze_target.id
			m.modifier.source_id = this.id
			m.pos.x, m.pos.y = kamikaze_target.pos.x, kamikaze_target.pos.y
			m.render.sprites[4].hidden = kamikaze_target.tower.size ~= TOWER_SIZE_LARGE
			m.render.sprites[5].hidden = kamikaze_target.tower.size ~= TOWER_SIZE_LARGE

			queue_insert(store, m)

			this.health.hp = 0

			SU.y_enemy_death(store, this)
			queue_remove(store, this)

			return
		end

		coroutine.yield()
	end
end

scripts.enemy_webspitting_spider = {}

function scripts.enemy_webspitting_spider.update(this, store, script)
	local a = this.timed_attacks.list[1]

	a.ts = store.tick_ts

	local function ready_to_cast()
		if store.tick_ts - a.ts <= a.cooldown then
			return false
		end

		for _, id in pairs(this.enemy.blockers) do
			local target = store.entities[id]

			if target and U.flags_pass(target.vis, a) and not target.unit.is_stunned then
				return true
			end
		end

		return false
	end

	::label_268_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_268_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_268_0
						end

						if ready_to_cast() then
							a.ts = store.tick_ts

							U.animation_start(this, a.animation, nil, store.tick_ts, false)

							if SU.y_enemy_wait(store, this, a.cast_time) then
								goto label_268_0
							end

							local targets_hit = {}

							for _, id in pairs(this.enemy.blockers) do
								local target = store.entities[id]

								if target and U.flags_pass(target.vis, a) and not target.unit.is_stunned and (not target.dodge or not SU.unit_dodges(store, target, false, a, this)) then
									local m = E:create_entity(a.mod)

									m.modifier.source_id = this.id
									m.modifier.target_id = target.id

									queue_insert(store, m)
									table.insert(targets_hit, target)
								end
							end

							U.y_animation_wait(this)

							a.ts = store.tick_ts

							for _, e in pairs(targets_hit) do
								U.unblock_target(store, e)
							end

							goto label_268_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_zealot = {}

function scripts.enemy_zealot.update(this, store)
	local function ready_to_summon()
		return this.pos.x <= this.rune.pos.x
	end

	while true do
		if this.health.dead then
			this.tween.disabled = nil
			this.tween.ts = store.tick_ts

			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		elseif ready_to_summon() then
			this.is_summoning = true
			this.vis.bans = bor(this.vis.bans, F_STUN, F_FREEZE, F_TELEPORT)
			this.rune.tween.disabled = nil
			this.rune.tween.reverse = false
			this.rune.tween.ts = store.tick_ts

			S:queue("ElvesMaliciaCastSummon")
			U.y_animation_play(this, "cast_start", nil, store.tick_ts)

			this.portal.pack = this.portal_pack
			this.portal.pack_finished = nil

			while not this.health.dead and not this.portal.pack_finished do
				U.y_animation_play(this, "cast_loop", nil, store.tick_ts, 1)
			end

			this.portal.pack = nil
			this.rune.tween.reverse = true
			this.rune.tween.ts = store.tick_ts

			U.y_animation_play(this, "cast_end", nil, store.tick_ts, 1)
			U.animation_start(this, "idle", nil, store.tick_ts, true)

			this.health.hp = 0

			coroutine.yield()
		elseif not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, function(store, this)
			return ready_to_summon()
		end) then
			-- block empty
		else
			coroutine.yield()
		end
	end
end

scripts.enemy_twilight_evoker = {}

function scripts.enemy_twilight_evoker.update(this, store, script)
	local a
	local as = this.timed_attacks.list[1]
	local ah = this.timed_attacks.list[2]

	local function ready_to_spellwrack()
		return store.tick_ts - as.ts > as.cooldown and this.enemy.can_do_magic
	end

	local function ready_to_heal()
		return store.tick_ts - ah.ts > ah.cooldown and this.enemy.can_do_magic
	end

	local function break_fn()
		return ready_to_heal() or ready_to_spellwrack()
	end

	::label_273_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_heal() then
				a = ah

				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans, function(e)
					return e ~= this and e.health.hp < e.health.hp_max * a.hp_trigger_factor
				end)

				if not targets then
					SU.delay_attack(store, a, 1)
				else
					table.sort(targets, function(e1, e2)
						return e1.health.hp < e2.health.hp
					end)
					S:queue(a.sound)

					a.ts = store.tick_ts

					U.animation_start(this, a.animation, nil, store.tick_ts, false)

					if SU.y_enemy_wait(store, this, a.cast_time) then
						goto label_273_0
					end

					for i = 1, math.min(a.max_count, #targets) do
						local target = targets[i]
						local m = E:create_entity(a.mod)

						m.modifier.target_id = target.id

						queue_insert(store, m)
					end

					U.y_animation_wait(this)

					a.ts = store.tick_ts
				end
			end

			if ready_to_spellwrack() then
				a = as

				local towers = table.filter(store.entities, function(_, e)
					return e.tower and e.tower.can_be_mod and e.tower.can_do_magic and band(a.vis_flags, e.vis.bans) == 0 and table.contains(a.included_templates, e.template_name) and U.is_inside_ellipse(e.pos, this.pos, a.range)
				end)
				local tower = table.random(towers)

				if not tower then
					SU.delay_attack(store, a, 1)
				else
					local an, af, ai = U.animation_name_facing_point(this, a.animation, tower.pos)

					U.animation_start(this, an, af, store.tick_ts, false)
					S:queue(a.sound)

					a.ts = store.tick_ts

					if SU.y_enemy_wait(store, this, a.cast_time) then
						goto label_273_0
					end

					local m = E:create_entity(a.mod)

					m.modifier.target_id = tower.id
					m.pos = tower.pos

					queue_insert(store, m)
					U.y_animation_wait(this)

					a.ts = store.tick_ts
				end
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, break_fn, break_fn) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_twilight_golem = {}

function scripts.enemy_twilight_golem.on_damage(this, store, damage)
	local m = this.motion

	if not m.max_speed_initial then
		m.max_speed_initial = m.max_speed
		m.max_speed_factor = 1
	end

	local unaffected_speed = m.max_speed / m.max_speed_factor
	local sub_factor = (this.health.hp_max - this.health.hp) / 100 * 0.05

	m.max_speed_factor = 1 - math.min(sub_factor, m.min_speed_sub_factor)
	m.max_speed = unaffected_speed * m.max_speed_factor

	return true
end

scripts.enemy_twilight_heretic = {}

function scripts.enemy_twilight_heretic.update(this, store)
	local a
	local ac = this.timed_attacks.list[1]
	local as = this.timed_attacks.list[2]

	local function ready_to_servant()
		return store.tick_ts - as.ts > as.cooldown and this.enemy.can_do_magic
	end

	local function ready_to_consume()
		return store.tick_ts - ac.ts > ac.cooldown and this.enemy.can_do_magic and P:nodes_to_goal(this.nav_path) > ac.nodes_limit
	end

	::label_281_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_consume() then
				a = ac

				local target = U.find_random_target(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

				if not target then
					SU.delay_attack(store, a, fts(10))
				else
					a.ts = store.tick_ts

					S:queue(a.sound)
					U.animation_start(this, a.animations[1], nil, store.tick_ts, false)

					if SU.y_enemy_wait(store, this, a.cast_time) then
						goto label_281_0
					end

					if target.health.dead then
						target = U.find_random_target(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)
					end

					if not target then
						a.ts = store.tick_ts
					else
						local d = E:create_entity("damage")

						d.damage_type = DAMAGE_INSTAKILL
						d.target_id = target.id
						d.source_id = this.id

						queue_damage(store, d)
						coroutine.yield()

						if not target.health.dead then
							a.ts = store.tick_ts

							U.animation_start(this, a.animations[3], nil, store.tick_ts, false)
							U.y_animation_wait(this)
						else
							local fx = E:create_entity(a.hit_fx)

							fx.pos.x, fx.pos.y = target.pos.x + target.unit.mod_offset.x, target.pos.y + target.unit.mod_offset.y
							fx.render.sprites[1].ts = store.tick_ts

							queue_insert(store, fx)
							U.y_wait(store, fts(3))

							local balls = {}
							local o = V.v(a.balls_dest_offset.x * (this.render.sprites[1].flip_x and -1 or 1), a.balls_dest_offset.y)

							for i = 1, a.balls_count do
								local b = E:create_entity(a.ball)

								b.from = V.v(target.pos.x + target.unit.mod_offset.x, fx.pos.y)
								b.to = V.v(this.pos.x + o.x, this.pos.y)
								b.pos = V.vclone(b.from)
								b.from_h = target.unit.mod_offset.y
								b.to_h = a.balls_dest_offset.y
								b.force_motion.max_flight_height = b.to_h + i * 10
								b.force_motion.max_v = (2 + i) * 30

								queue_insert(store, b)
								table.insert(balls, b)
							end

							U.y_animation_wait(this)
							U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

							while true do
								coroutine.yield()

								if this.health.dead or this.unit.is_stunned then
									goto label_281_0
								end

								local arrived = true

								for _, ball in pairs(balls) do
									arrived = arrived and ball.arrived
								end

								if arrived then
									break
								end
							end

							U.animation_start(this, a.animations[3], nil, store.tick_ts, false)
							U.y_animation_wait(this)

							local m = E:create_entity(a.mod)

							m.modifier.target_id = this.id
							m.modifier.ts = store.tick_ts
							m.pos.x, m.pos.y = this.pos.x, this.pos.y

							queue_insert(store, m)

							a.ts = store.tick_ts
						end
					end
				end
			end

			if ready_to_servant() then
				a = as

				local target = U.find_random_target(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

				if not target then
					SU.delay_attack(store, a, fts(10))

					goto label_281_1
				end

				a.ts = store.tick_ts

				S:queue(a.sound)
				U.animation_start(this, a.animation, nil, store.tick_ts, false)

				if SU.y_enemy_wait(store, this, a.cast_time) then
					goto label_281_0
				end

				if target.health.dead then
					target = U.find_random_target(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)
				end

				if not target then
					a.ts = store.tick_ts

					goto label_281_1
				end

				local targets = {
					target
				}
				local extra_targets = U.find_soldiers_in_range(store.entities, target.pos, 0, a.radius, a.vis_flags, a.vis_bans, function(e)
					return e ~= target
				end)

				if extra_targets then
					table.insert(targets, extra_targets[1])
				end

				for _, t in pairs(targets) do
					local m = E:create_entity(a.mod)

					m.modifier.target_id = t.id
					m.pos = t.pos

					queue_insert(store, m)
					U.y_wait(store, 0.1)
				end

				U.y_animation_wait(this)

				a.ts = store.tick_ts
			end

			::label_281_1::

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, function(store, this)
				return ready_to_servant() or ready_to_consume()
			end) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_mantaray = {}

function scripts.enemy_mantaray.update(this, store)
	this._hugging = nil

	local dead_when_hugging = false

	if this.render.sprites[1].name == "raise" then
		this.render.sprites[2].hidden = true
		this.health_bar.hidden = true

		local af = this.motion.forced_waypoint and this.motion.forced_waypoint.x < this.pos.x

		U.animation_start(this, "raise", af, store.tick_ts, true)

		this.tween.props[1].keys = {
			{
				0,
				V.v(0, -40)
			},
			{
				0.3,
				V.v(0, 0)
			}
		}
		this.tween.ts = store.tick_ts
		this.tween.disabled = nil

		U.y_wait(store, 0.3)

		this.tween.disabled = true

		U.y_animation_play(this, "spawnToWalking", af, store.tick_ts)

		this.render.sprites[2].hidden = false
		this.health_bar.hidden = false
	end

	::label_286_0::

	while true do
		if this.health.dead then
			if dead_when_hugging then
				this.unit.death_animation = "explode"
			end

			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local ok, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_286_0
					end

					this.unit.ignore_stun = true
					this.vis.bans = U.flag_set(this.vis.bans, bor(F_BLOCK, F_TELEPORT))
					this.vis.flags = U.flag_clear(this.vis.flags, F_FLYING)

					SU.stun_inc(blocker)

					this.health_bar.hidden = true
					this._hugging = blocker

					local fh_offset = this.facehug_offsets[blocker.template_name]

					fh_offset = fh_offset or blocker.hero and this.facehug_offsets.hero_default or this.facehug_offsets.soldier_default

					local x_offset = (fh_offset.x + 0) * (this.pos.x < blocker.pos.x and -1 or 1)
					local y_offset = fh_offset.y + 1
					local dest = V.v(blocker.pos.x, blocker.pos.y - 1)
					local dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
					local eta = dist / this.motion.max_speed

					this.tween.props[1].keys = {
						{
							0,
							V.v(0, 0)
						},
						{
							eta,
							V.v(x_offset, y_offset)
						}
					}
					this.tween.disabled = false
					this.tween.ts = store.tick_ts

					U.set_destination(this, dest)
					U.animation_start(this, "jump", nil, store.tick_ts)

					while not this.motion.arrived do
						if this.health.dead then
							SU.stun_dec(blocker)

							this._hugging = nil

							goto label_286_0
						end

						U.walk(this, store.tick_length)
						coroutine.yield()
					end

					this.tween.disabled = true
					this.unit.mod_offset = this.unit.mod_offset_facehug
					this.unit.hit_offset = this.unit.hit_offset_facehug

					U.animation_start(this, "bite", nil, store.tick_ts, true)

					while not blocker.health.dead do
						if this.health.dead then
							SU.stun_dec(blocker)

							this._hugging = nil
							dead_when_hugging = true

							goto label_286_0
						end

						local damage_value

						if blocker.hero then
							damage_value = math.random(this.facehug_damage_hero_min, this.facehug_damage_hero_max)
						else
							damage_value = math.random(this.facehug_damage_soldier_min, this.facehug_damage_soldier_max)
						end

						local d = E:create_entity("damage")

						d.value = damage_value
						d.source_id = this.id
						d.target_id = blocker.id
						d.damage_type = bor(DAMAGE_HOST, DAMAGE_TRUE)
						d.track_kills = this.track_kills ~= nil

						queue_damage(store, d)

						local ts = store.tick_ts

						while store.tick_ts - ts < this.facehug_damage_cooldown and not blocker.health.dead and not this.health.dead do
							coroutine.yield()
						end
					end

					SU.stun_dec(blocker)

					this._hugging = nil

					if #this.track_kills.killed > 0 and this.track_kills.killed[1] == blocker.id then
						if not table.contains(this.facehug_spawn_bans, blocker.template_name) then
							U.animation_start(this, "explode", nil, store.tick_ts, false)

							local fx = E:create_entity("fx")

							fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
							fx.render.sprites[1].name = "fx_mantaray_spawn"
							fx.render.sprites[1].ts = store.tick_ts

							queue_insert(store, fx)
							U.y_wait(store, fts(4))

							for i = 1, 2 do
								local e = E:create_entity("enemy_mantaray")

								e.pos.x = this.pos.x
								e.nav_path.pi = this.nav_path.pi
								e.nav_path.ni = km.clamp(1, P:get_end_node(this.nav_path.pi) - 1, this.nav_path.ni + 5)
								e.render.sprites[1].flip_x = this.render.sprites[1].flip_x

								if i == 1 then
									e.enemy.gold = this.enemy.gold
									e.enemy.gems = this.enemy.gems
									e.pos.y = this.pos.y
									e.nav_path.spi = this.nav_path.spi
								else
									e.enemy.gold = 0
									e.enemy.gems = 0
									e.pos.y = this.pos.y
									e.nav_path.spi = km.zmod(this.nav_path.spi + math.random(1, 2), 3)
								end

								queue_insert(store, e)
							end
						end

						U.y_animation_wait(this)
						queue_remove(store, this)

						return
					end

					this.unit.ignore_stun = nil
					this.vis.bans = U.flag_clear(this.vis.bans, bor(F_BLOCK, F_TELEPORT))
					this.vis.flags = U.flag_set(this.vis.flags, F_FLYING)
					this.health_bar.hidden = false
					this.unit.mod_offset = this.unit.mod_offset_fly
					this.unit.hit_offset = this.unit.hit_offset_fly
				end

				coroutine.yield()
			end
		end
	end
end

function scripts.enemy_mantaray.remove(this, store)
	if this._hugging then
		SU.stun_dec(this._hugging)

		this._hugging = nil
		this.vis.bans = U.flag_clear(this.vis.bans, bor(F_STUN, F_BLOCK, F_TELEPORT))
		this.vis.flags = U.flag_set(this.vis.flags, F_FLYING)
		this.health_bar.hidden = false
		this.unit.mod_offset = this.unit.mod_offset_fly
		this.unit.hit_offset = this.unit.hit_offset_fly
	end

	return true
end

scripts.enemy_razorboar = {}

function scripts.enemy_razorboar.update(this, store)
	local a = this.timed_attacks.list[1]

	a.ts = store.tick_ts
	a.hit_targets = {}

	local ps = E:create_entity(a.particles_name)

	ps.particle_system.track_id = this.id
	ps.particle_system.emit = false

	queue_insert(store, ps)

	local function ready_to_rampage()
		return store.tick_ts - a.ts > a.cooldown and not U.get_blocker(store, this) and this.enemy.can_do_magic and P:nodes_to_defend_point(this.nav_path) > a.nodes_limit
	end

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_rampage() then
				local ni = this.nav_path.ni + 10

				if not P:is_node_valid(this.nav_path.pi, ni) then
					log.debug("razorboar path node invalid: %s,%s", this.nav_path.pi, ni)
					SU.delay_attack(store, a, 2)
				else
					local npos = P:node_pos(this.nav_path.pi, this.nav_path.spi, ni)
					local enemies = U.find_enemies_in_range(store.entities, npos, 0, a.trigger_range, a.vis_flags_enemies, F_BOSS, function(e)
						return band(e.vis.flags, F_FLYING) ~= 0
					end)
					local soldiers = U.find_soldiers_in_range(store.entities, npos, 0, a.trigger_range, a.vis_flags_soldiers, a.vis_bans_soldiers)

					if not enemies and not soldiers then
						SU.delay_attack(store, a, 1)
					else
						a.ts = store.tick_ts

						local ms = E:create_entity(a.mod_self)

						ms.modifier.target_id = this.id
						ms.modifier.source_id = this.id
						ms.modifier.ts = store.tick_ts

						queue_insert(store, ms)

						this.vis.bans = U.flag_set(this.vis.bans, F_BLOCK)

						S:queue(a.sound)

						while store.tick_ts - a.ts < a.duration and not this.health.dead and this.enemy.can_do_magic do
							ps.particle_system.emit = true

							local enemies = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags_enemies, a.vis_bans_enemies, function(e)
								return e.id ~= this.id and not table.contains(a.hit_targets, e.id)
							end)

							if enemies then
								for _, e in pairs(enemies) do
									table.insert(a.hit_targets, e.id)

									local m = E:create_entity(a.mod_enemy)

									m.modifier.target_id = e.id
									m.modifier.source_id = this.id
									m.modifier.ts = store.tick_ts

									queue_insert(store, m)
								end
							end

							local soldiers = U.find_soldiers_in_range(store.entities, this.pos, 0, a.range, a.vis_flags_soldiers, a.vis_bans_soldiers, function(e)
								return not table.contains(a.hit_targets, e.id)
							end)

							if soldiers then
								for _, e in pairs(soldiers) do
									table.insert(a.hit_targets, e.id)

									local m = E:create_entity(a.mod_soldier)

									m.modifier.target_id = e.id
									m.modifier.source_id = this.id
									m.modifier.ts = store.tick_ts

									queue_insert(store, m)
								end
							end

							SU.y_enemy_walk_step(store, this, "run")

							while this.unit.is_stunned do
								ps.particle_system.emit = false

								SU.y_enemy_stun(store, this)

								a.ts = a.ts - a.duration
							end
						end

						ps.particle_system.emit = false
						this.vis.bans = U.flag_clear(this.vis.bans, F_BLOCK)
					end
				end
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, function(store, this)
				return ready_to_rampage()
			end) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_arachnomancer = {}

function scripts.enemy_arachnomancer.update(this, store, script)
	local a = this.timed_attacks.list[1]

	a.ts = store.tick_ts

	local function ready_to_summon()
		return store.tick_ts - a.ts > a.cooldown and this.enemy.can_do_magic and not U.get_blocker(store, this) and P:nodes_to_defend_point(this.nav_path) > a.nodes_limit
	end

	for i = 1, 3 do
		local e = E:create_entity("decal_arachnomancer_mini_spider")

		e.owner = this
		e.spider_idx = i

		queue_insert(store, e)
	end

	::label_294_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_summon() then
				a.ts = store.tick_ts

				U.animation_start(this, a.animation, nil, store.tick_ts, false)

				if SU.y_enemy_wait(store, this, a.spawn_time) then
					goto label_294_0
				end

				local set = table.random(a.spawn_sets)
				local e = E:create_entity(a.entity)

				e.spawner.pi = this.nav_path.pi
				e.spawner.spi = this.nav_path.spi
				e.spawner.ni = this.nav_path.ni
				e.spawner.count = set[1]
				e.spawner.entity = set[2]

				queue_insert(store, e)
				U.y_animation_wait(this)

				a.ts = store.tick_ts

				goto label_294_0
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, function(store, this)
				return ready_to_summon()
			end) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.spider_arachnomancer_egg_spawner = {}

function scripts.spider_arachnomancer_egg_spawner.update(this, store)
	local sp = this.spawner
	local s = this.render.sprites[1]
	local idle_ts = math.random(this.idle_range[1], this.idle_range[2])

	if this.spawn_once then
		U.y_animation_play(this, "spawn", nil, store.tick_ts)
	end

	while true do
		if sp.interrupt then
			-- block empty
		else
			if sp.spawn_data then
				local data = sp.spawn_data

				sp.spawn_data = nil
				sp.count = data.cantSpiders or sp.count

				S:queue(this.sound_events.open)
				U.animation_start(this, "open", nil, store.tick_ts, false)
				U.y_wait(store, this.spawn_time)

				if SU.y_spawner_spawn(store, this) then
					goto label_297_0
				end

				U.y_animation_wait(this)

				if this.spawn_once then
					this.tween.disabled = nil
					this.tween.ts = store.tick_ts

					U.y_wait(store, this.tween.props[1].keys[2][1])

					break
				else
					U.y_animation_play(this, "spawn", nil, store.tick_ts)
				end
			end

			if idle_ts < store.tick_ts then
				U.y_animation_play(this, "idle", nil, store.tick_ts)

				idle_ts = store.tick_ts + math.random(this.idle_range[1], this.idle_range[2])
			end
		end

		::label_297_0::

		sp.interrupt = nil
		sp.spawn_data = nil

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.spider_son_of_mactans_drop_spawner = {}

function scripts.spider_son_of_mactans_drop_spawner.update(this, store)
	local dest = V.vclone(this.pos)

	this.pos.x, this.pos.y = dest.x, REF_H
	this.render.sprites[1].name = "netDescend"
	this.render.sprites[1].ts = store.tick_ts

	local shadow = E:create_entity("decal_shadow_spider_son_of_mactans")

	shadow.pos.x, shadow.pos.y = dest.x, dest.y
	shadow.tween.ts = store.tick_ts

	queue_insert(store, shadow)
	U.y_ease_key(store, this.pos, "y", REF_H, dest.y, 2, "quad-in")

	local e = E:create_entity(this.spawn)

	e.pos.x, e.pos.y = this.pos.x, this.pos.y
	e.nav_path = table.deepclone(this.nav_path)
	e.nav_path.ni = e.nav_path.ni + 2
	e.render.sprites[1].name = "raise"

	queue_insert(store, e)
	coroutine.yield()

	if this.spawner.interrupt then
		e.health.hp = 0
	end

	this.render.sprites[1].hidden = true

	for i = 2, #this.render.sprites do
		local s = this.render.sprites[i]

		s.name = "dissolve"
		s.ts = store.tick_ts

		U.y_wait(store, 2 * store.tick_length)
	end

	U.y_wait(store, fts(10))
	queue_remove(store, this)
end

scripts.enemy_mactans = {}

function scripts.enemy_mactans.update(this, store)
	local idle_pos = V.vclone(this.idle_pos)

	this.pos = V.vclone(idle_pos)

	local thread = E:create_entity("decal_mactans_thread")

	queue_insert(store, thread)

	thread.pos = this.pos

	U.sprites_hide(thread)

	local shadow = E:create_entity("decal_mactans_shadow")

	queue_insert(store, shadow)

	shadow.tween.reverse = true
	shadow.tween.ts = 4

	local webbing = E:create_entity("decal_mactans_webbing")

	queue_insert(store, webbing)
	U.sprites_hide(webbing)

	while true do
		if this.phase_signal == "tower_block" or this.phase_signal == "path_web" then
			local pp = this.phase_params
			local is_tb = this.phase_signal == "tower_block"
			local tower, aura, dest, dest_node
			local touch_duration = pp.touch_duration

			if is_tb then
				local towers = table.filter(store.entities, function(_, e)
					return e.tower and not e.tower_holder and table.contains(pp.holder_ids, e.tower.holder_id)
				end)

				if #towers < 1 then
					goto label_299_0
				end

				tower = table.random(towers)
				dest = V.vclone(tower.pos)
			else
				local pis = P:get_connected_paths(pp.path_id)
				local nodes = P:nearest_nodes(pp.near_pos.x, pp.near_pos.y, pis, nil, true)

				log.debug(">>>>>>>>>>>>>>. pp:%s\npis:%s\nnodes:%s", getfulldump(pp), getdump(pis), getfulldump(nodes))

				if #nodes < 1 then
					log.error("cannot do mactans path_web. no valid nodes near %s,%s", pp.near_pos.x, pp.near_pos.y)

					goto label_299_0
				end

				dest_node = {
					pi = nodes[1][1],
					nodes[1][2],
					ni = nodes[1][3]
				}
				dest = P:node_pos(dest_node.pi, 1, dest_node.ni)
			end

			this.pos.x = dest.x
			this.pos.y = REF_H

			if this.mactans_deco then
				this.mactans_deco.phase_signal = "jump_out"

				U.y_wait(store, fts(38))
			end

			U.sprites_show(thread)

			shadow.pos.x, shadow.pos.y = dest.x, dest.y + 16
			shadow.tween.reverse = false
			shadow.tween.ts = store.tick_ts

			U.animation_start(this, "falling", nil, store.tick_ts, true)
			S:queue("ElvesFinalBossSpiderIn", {
				Delay = this.drop_duration - fts(25)
			})
			U.y_ease_key(store, this.pos, "y", this.pos.y, dest.y, this.drop_duration, "quad-in")

			this.ui.clicked = nil

			S:queue("ElvesFinalBossWebspin")
			U.y_animation_play(this, "startingWeb", nil, store.tick_ts)
			U.animation_start(this, "web", nil, store.tick_ts, true)

			webbing.pos = V.v(this.pos.x, this.pos.y + 40)

			for i, sprite in ipairs(webbing.render.sprites) do
				sprite.ts = store.tick_ts + (i - 1) * fts(5)
			end

			U.sprites_show(webbing)

			if not is_tb then
				S:queue("ElvesFinalBossWebground")

				aura = E:create_entity("aura_mactans_path_web")
				aura.pos.x, aura.pos.y = dest.x, dest.y
				aura.aura.ts = store.tick_ts
				aura.aura.duration = pp.web_duration
				aura.eggs = store.level.mactans_eggs
				aura.qty_per_egg = pp.qty_per_egg
				aura.pi = dest_node.pi
				aura.ni = dest_node.ni

				queue_insert(store, aura)

				touch_duration = aura.step_nodes * aura.step_delay
			end

			if U.y_wait(store, touch_duration, function(store, time)
				return this.ui.clicked or is_tb and not store.entities[tower.id]
			end) then
				queue_remove(store, webbing)

				if is_tb and not store.entities[tower.id] then
					-- block empty
				else
					if not is_tb then
						aura.interrupt = true

						S:stop("ElvesFinalBossWebground")
					end

					if is_tb then
						-- AC:inc_check("ITS_A_TRAP")
					end

					S:stop("ElvesFinalBossWebspin")
					S:queue("ElvesFinalBossMactansTouch")

					local pop = SU.create_pop(store, V.v(this.pos.x, this.pos.y + 110), {
						"pop_mactans"
					})

					queue_insert(store, pop)
					U.animation_start(this, "bounce", nil, store.tick_ts, true)

					this.tween.disabled = nil
					this.tween.ts = store.tick_ts

					local k = this.tween.props[1].keys

					U.y_wait(store, k[#k][1])

					this.tween.disabled = true

					U.y_animation_play(this, "startRetreat2", nil, store.tick_ts)
				end
			else
				if is_tb then
					local m = E:create_entity("mod_mactans_tower_block")

					m.pos = V.vclone(tower.pos)
					m.modifier.target_id = tower.id
					m.modifier.source_id = this.id
					m.modifier.duration = pp.block_duration

					queue_insert(store, m)
					U.y_wait(store, this.netting_duration)
				end

				queue_remove(store, webbing)
				U.y_animation_play(this, "startRetreat", nil, store.tick_ts)
			end

			U.animation_start(this, "retreat", nil, store.tick_ts, true)
			S:queue("ElvesFinalBossSpiderOut")

			shadow.tween.reverse = true
			shadow.tween.ts = store.tick_ts

			U.y_ease_key(store, this.pos, "y", this.pos.y, REF_H, this.retreat_duration, "quad-out")
			U.sprites_hide(thread)

			if this.mactans_deco then
				this.mactans_deco.phase_signal = "jump_in"
			end
		end

		::label_299_0::

		this.phase_signal = nil

		coroutine.yield()
	end
end

scripts.enemy_bloodsydian_warlock = {}

function scripts.enemy_bloodsydian_warlock.update(this, store)
	local a = this.timed_attacks.list[1]

	a.ts = store.tick_ts

	local function ready_to_cast()
		return this.enemy.can_do_magic and store.tick_ts - a.ts > a.cooldown and this.nav_path.ni > a.nodes_min and P:nodes_to_defend_point(this.nav_path) > a.nodes_limit
	end

	::label_302_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_cast() then
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
					return table.contains(a.allowed_templates, e.template_name)
				end)

				if not targets or #targets < a.min_count then
					SU.delay_attack(store, a, 0.5)
				else
					a.ts = store.tick_ts

					U.animation_start(this, a.animation, nil, store.tick_ts, false)

					while store.tick_ts - a.ts < a.cast_time do
						if this.health.dead or this.unit.is_stunned then
							goto label_302_0
						end

						coroutine.yield()
					end

					local decal = E:create_entity(a.hit_decal)

					decal.pos.x, decal.pos.y = this.pos.x, this.pos.y
					decal.tween.ts = store.tick_ts

					queue_insert(store, decal)

					for i, target in ipairs(targets) do
						if i > a.max_count then
							break
						end

						local e = E:create_entity(a.mod)

						e.modifier.target_id = target.id

						queue_insert(store, e)
					end

					SU.y_enemy_animation_wait(this)

					goto label_302_0
				end
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, function(store, this)
				return ready_to_cast()
			end) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_ogre_magi = {}

function scripts.enemy_ogre_magi.update(this, store)
	local a = this.ranged.attacks[1]
	local cont, blocker, ranged

	::label_306_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, SU.enemy_interrupted(this))

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_306_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not SU.enemy_interrupted(this) do
						if not SU.y_enemy_range_attacks(store, this, blocker) then
							goto label_306_0
						end

						coroutine.yield()
					end
				elseif ranged then
					SU.y_enemy_range_attacks(store, this, ranged)
				end

				coroutine.yield()
			end
		end
	end
end

scripts.mod_ogre_magi_shield = {}

function scripts.mod_ogre_magi_shield.on_damage(this, store, damage)
	local defl_target = this.__mod_ogre_magi_shield_deflect_target
	local defl_aura = this.__mod_ogre_magi_shield_deflect_aura
	local mod = this.__mod_ogre_magi_shield_mod

	if not defl_target or defl_target.health.dead then
		return true
	end

	local v = damage.value or 0

	damage.value = km.round(v * (1 - mod.modifier.deflect_factor))

	local filtered_damage_type = band(damage.damage_type, DAMAGE_BASE_TYPES)

	if filtered_damage_type ~= 0 then
		local d = E:create_entity("damage")

		d.value = math.floor(v * mod.modifier.deflect_factor)
		d.damage_type = filtered_damage_type
		d.target_id = defl_target.id
		d.source_id = damage.source_id

		queue_damage(store, d)
	end

	if store.tick_ts - mod.last_fx_ts > mod.fx_cooldown then
		mod.render.sprites[1].ts = store.tick_ts
		mod.last_fx_ts = store.tick_ts
	end

	if store.tick_ts - defl_aura.last_fx_ts > defl_aura.fx_cooldown then
		defl_aura.render.sprites[1].ts = store.tick_ts
		defl_aura.last_fx_ts = store.tick_ts
	end

	if this.__mod_ogre_magi_shield_on_damage then
		return this.__mod_ogre_magi_shield_on_damage(this, store, damage)
	else
		return true
	end
end

function scripts.mod_ogre_magi_shield.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or target.health.dead then
		log.debug("cannot insert mod_ogre_magi_shield: missing or dead target %s", m.target_id)

		return false
	end

	local source_aura = store.entities[m.source_id]

	if not source_aura then
		log.debug("cannot insert mod_ogre_magi_shield: missing source_aura %s", m.source_id)

		return false
	end

	local source_ogre = store.entities[source_aura.aura.source_id]

	if not source_ogre then
		log.debug("cannot insert mod_ogre_magi_shield: missing source_ogre %s", source_aura.aura.source_id)

		return false
	end

	target.__mod_ogre_magi_shield_deflect_aura = source_aura
	target.__mod_ogre_magi_shield_deflect_target = source_ogre
	target.__mod_ogre_magi_shield_mod = this
	target.__mod_ogre_magi_shield_on_damage = target.health.on_damage
	target.health.on_damage = scripts.mod_ogre_magi_shield.on_damage

	local s = this.render.sprites[1]

	s.scale = s.size_scales[target.unit.size]

	return true
end

function scripts.mod_ogre_magi_shield.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.health.on_damage = target.__mod_ogre_magi_shield_on_damage
		target.__mod_ogre_magi_shield_deflect_aura = nil
		target.__mod_ogre_magi_shield_deflect_target = nil
		target.__mod_ogre_magi_shield_mod = nil
	end

	return true
end

function scripts.mod_ogre_magi_shield.update(this, store)
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

		if not target or target.health.dead then
			break
		end

		local source_ogre = target.__mod_ogre_magi_shield_deflect_target
		local source_aura = store.entities[m.source_id]

		if not source_aura or not source_ogre or source_ogre.health.dead or not source_ogre.enemy.can_do_magic or band(source_ogre.vis.bans, this.source_vis_flags) ~= 0 or m.duration >= 0 and store.tick_ts - m.ts > m.duration then
			break
		end

		if this.render and m.use_mod_offset and target.unit and target.unit.mod_offset then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.enemy_screecher_bat = {}

function scripts.enemy_screecher_bat.update(this, store, script)
	local a = this.timed_attacks.list[1]

	a.ts = store.tick_ts

	local function ready_to_attack()
		return store.tick_ts - a.ts > a.cooldown
	end

	::label_311_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, true)
			coroutine.yield()
		else
			if ready_to_attack() then
				local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
					return not e.unit.is_stunned
				end)

				if not targets then
					SU.delay_attack(store, a, 0.25)
				else
					a.ts = store.tick_ts

					S:queue(a.sound)
					U.animation_start(this, a.animation, targets[1].pos.x < this.pos.x, store.tick_ts)

					while store.tick_ts - a.ts < a.attack_time do
						if this.health.dead or this.unit.is_stunned then
							goto label_311_0
						end

						coroutine.yield()
					end

					targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
						return not e.unit.is_stunned
					end)

					if targets then
						for _, t in pairs(targets) do
							local m = E:create_entity(a.mod)

							m.modifier.source_id = this.id
							m.modifier.target_id = t.id

							queue_insert(store, m)
						end
					end

					U.y_animation_wait(this)

					a.ts = store.tick_ts
				end
			end

			if not SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_attack()
			end) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_grim_devourers = {}

function scripts.enemy_grim_devourers.update(this, store, script)
	::label_316_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local ok, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_316_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_316_0
						end

						coroutine.yield()
					end
				end

				if blocker and blocker.health.dead then
					coroutine.yield()

					if not blocker.health.dead then
						goto label_316_0
					end

					local target = blocker

					if band(target.vis.bans, F_CANNIBALIZE) ~= 0 then
						coroutine.yield()

						goto label_316_0
					end

					U.unblock_all(store, this)
					U.animation_start(this, "cannibal", nil, store.tick_ts, false)
					S:queue(this.sound_events.cannibalize)

					for i = 1, this.cannibalize.cycles do
						if this.health.dead or not store.entities[target.id] then
							goto label_316_1
						end

						this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + this.cannibalize.hp_per_cycle)

						U.y_wait(store, 0.03333333333333333)
					end

					U.y_animation_wait(this)
				end

				::label_316_1::

				coroutine.yield()
			end
		end
	end
end

scripts.aura_shadow_champion_death = {}

function scripts.aura_shadow_champion_death.update(this, store)
	local a = this.aura
	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans, function(e)
		return table.contains(a.include_enemies, e.template_name)
	end)

	if targets then
		for _, t in pairs(targets) do
			local m = E:create_entity(a.enemy_mod)

			m.modifier.source_id = this.id
			m.modifier.target_id = t.id

			queue_insert(store, m)
		end
	end

	targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

	if targets then
		for _, t in pairs(targets) do
			local m = E:create_entity(a.soldier_mod)

			m.modifier.source_id = this.id
			m.modifier.target_id = t.id

			queue_insert(store, m)
		end
	end

	queue_remove(store, this)
end

scripts.mod_shadow_champion = {}

function scripts.mod_shadow_champion.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead or not target.unit then
		return false
	end

	target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp + target.health.hp_max * this.heal_factor)
	target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor

	return true
end

function scripts.mod_shadow_champion.remove(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.unit.damage_factor = math.ceil(target.unit.damage_factor / this.inflicted_damage_factor)
	end

	return true
end

scripts.eb_gnoll = {}

function scripts.eb_gnoll.update(this, store, script)
	local fa = this.timed_attacks.list[1]
	local ha = this.timed_attacks.list[2]

	fa.ts = store.tick_ts

	local function ready_to_howl()
		if (not ha._last_ni or this.nav_path.ni > ha._last_ni) and table.contains(ha.nis, this.nav_path.ni) then
			return true
		end
	end

	local function ready_to_flail()
		return store.tick_ts - fa.ts > fa.cooldown and not this.health.dead and P:nodes_to_defend_point(this.nav_path) > 0
	end

	local function y_do_howl()
		S:queue(ha.sound)
		U.animation_start(this, ha.animation, nil, store.tick_ts)
		U.y_wait(store, ha.hit_time)

		ha.wave_idx = km.zmod((ha.wave_idx or 0) + 1, #ha.wave_names)
		this.mega_spawner.manual_wave = ha.wave_names[ha.wave_idx]

		U.y_animation_wait(this)
	end

	this.phase = "intro"
	this.health_bar.hidden = true

	y_do_howl()

	this.phase = "loop"
	this.health_bar.hidden = nil

	::label_321_0::

	while true do
		if this.health.dead then
			this.phase = "dead"
			this.mega_spawner.interrupt = true

			LU.kill_all_enemies(store, true)
			S:stop_all()
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			LU.kill_all_enemies(store, true)

			this.phase = "death-complete"

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_howl() then
				log.debug("+++++++++++ howling")
				y_do_howl()

				ha._last_ni = this.nav_path.ni
			end

			if ready_to_flail() then
				U.animation_start(this, fa.animation, nil, store.tick_ts)
				U.y_wait(store, fa.hit_time)
				S:queue(fa.sound)

				local targets = U.find_soldiers_in_range(store.entities, this.pos, fa.min_range, fa.max_range, fa.vis_flags, fa.vis_bans)

				if targets then
					for _, target in pairs(targets) do
						local d = E:create_entity("damage")

						d.damage_type = fa.damage_type

						if bit.band(target.vis.flags, F_HERO) ~= 0 then
							d.value = math.random(fa.damage_min_hero, fa.damage_max_hero)
						else
							d.value = math.random(fa.damage_min, fa.damage_max)
						end

						d.target_id = target.id
						d.source_id = this.id

						queue_damage(store, d)
					end
				end

				local a = E:create_entity("aura_screen_shake")

				queue_insert(store, a)
				U.y_animation_wait(this)

				fa.ts = store.tick_ts

				goto label_321_0
			end

			local ok, blocker = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_flail() or ready_to_howl()
			end)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_321_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_flail() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_321_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.mod_gnoll_boss = {}

function scripts.mod_gnoll_boss.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead or not target.unit then
		return false
	end

	this._hp_bonus = math.floor(target.health.hp_max * this.extra_health_factor)
	target.health.hp_max = target.health.hp_max + this._hp_bonus
	target.health.hp = target.health.hp + this._hp_bonus
	target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor

	return true
end

function scripts.mod_gnoll_boss.remove(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.health.hp_max = target.health.hp_max - this._hp_bonus
		target.health.hp = target.health.hp - this._hp_bonus
		target.unit.damage_factor = math.ceil(target.unit.damage_factor / this.inflicted_damage_factor)
	end

	return true
end

scripts.eb_drow_queen = {}

function scripts.eb_drow_queen.on_damage(this, store, damage)
	if this.phase == "fighting" then
		return true
	elseif this.phase == "casting" then
		log.debug("eb_drow_queen shield takes damage: %s", damage.value)

		this.shield.health.hp = this.shield.health.hp - damage.value

		return false
	end

	return false
end

function scripts.eb_drow_queen.update(this, store)
	local sid_body, sid_fly = 1, 4
	local s_body = this.render.sprites[sid_body]
	local d_shield = E:create_entity("decal_drow_queen_shield")

	d_shield.pos = this.pos

	queue_insert(store, d_shield)

	this.shield = d_shield

	local d_flying = E:create_entity("decal_drow_queen_flying")
	local s_flying = d_flying.render.sprites[1]

	queue_insert(store, d_flying)

	local ps = E:create_entity("ps_drow_queen_trail")

	queue_insert(store, ps)

	ps.particle_system.track_id = d_flying.id

	local function block_tower_ids(holder_ids, duration)
		for _, e in E:filter_iter(store.entities, "tower") do
			if e.tower.can_be_mod and table.contains(holder_ids, e.tower.holder_id) then
				local m = E:create_entity("mod_drow_queen_tower_block")

				m.modifier.source_id = this.id
				m.modifier.target_id = e.id
				m.pos.x, m.pos.y = e.pos.x, e.pos.y

				if duration then
					m.modifier.duration = duration
				end

				queue_insert(store, m)
			end
		end
	end

	local function block_random_tower()
		local towers = table.filter(store.entities, function(_, e)
			return e.tower and e.tower.can_be_mod and not e.tower.blocked
		end)
		local tower = table.random(towers)

		if tower then
			block_tower_ids({
				tower.tower.holder_id
			})
		end
	end

	local function block_all_towers()
		local towers = table.filter(store.entities, function(_, e)
			return e.tower and e.tower.can_be_mod and not e.tower.blocked
		end)
		local holder_ids = table.map(towers, function(k, v)
			return v.tower.holder_id
		end)

		block_tower_ids(holder_ids, 1000000000)
	end

	local function y_fly(from, to, speed, dest_pi)
		SU.remove_modifiers(store, this)

		local af = to.x < from.x

		s_flying.r = V.angleTo(to.x - from.x, to.y - from.y)
		s_flying.flip_y = math.abs(s_flying.r) > math.pi / 2

		S:queue("ElvesMaliciaTransformIn")
		U.y_animation_play(this, "teleportStart", af, store.tick_ts, 1, sid_body)

		s_body.hidden = true
		s_flying.hidden = false

		local fly_dist = V.dist(to.x, to.y, from.x, from.y)
		local fly_time = this.fly_loop_time * math.ceil(fly_dist / speed / this.fly_loop_time)
		local particles_dist = 10
		local emission_rate = fly_dist / particles_dist / fly_time

		ps.particle_system.emission_rate = emission_rate
		ps.particle_system.emit = true

		local start_ts = store.tick_ts
		local phase

		repeat
			phase = (store.tick_ts - start_ts) / fly_time
			d_flying.pos.x = U.ease_value(from.x, to.x, phase, "sine-outin")
			d_flying.pos.y = U.ease_value(from.y, to.y, phase, "sine-outin") + this.fly_offset_y

			coroutine.yield()
		until phase >= 1

		ps.particle_system.emit = false
		this.pos.x, this.pos.y = to.x, to.y
		s_flying.hidden = true
		s_body.hidden = false

		S:queue("ElvesMaliciaTransformOut")
		U.y_animation_play(this, "teleportEnd", af, store.tick_ts, 1, sid_body)

		this.nav_path.pi = dest_pi
		this.nav_path.ni = P:nearest_nodes(this.pos.x, this.pos.y, {
			dest_pi
		})[1][3]
	end

	local function y_power(shield_hp, shield_duration, pow_cooldown_min, pow_chances)
		this.vis.bans = U.flag_clear(this.vis.bans, bor(F_RANGED, F_MOD))
		this.health_bar.hidden = false
		this.shield.health.hp = shield_hp
		this.shield.health.hp_max = shield_hp
		this.shield.shield_dps = shield_hp / shield_duration

		local pow_cooldown = pow_cooldown_min
		local cast_ts = store.tick_ts
		local fx

		SU.y_show_taunt_set(store, this.taunts, this.phase)

		::label_337_0::

		U.y_animation_play(this, "shoutStart", true, store.tick_ts, 1, sid_body)
		U.animation_start(this, "shoutLoop", true, store.tick_ts, true, sid_body)

		while pow_cooldown > store.tick_ts - cast_ts and this.shield.health.hp > 0 do
			coroutine.yield()
		end

		U.y_animation_play(this, "shoutEnd", true, store.tick_ts, 1, sid_body)

		if this.shield.health.hp <= 0 then
			-- block empty
		else
			S:queue("ElvesMaliciaSpellCast")
			U.animation_start(this, "cast", true, store.tick_ts, false, sid_body)

			fx = E:create_entity("fx_drow_queen_cast")
			fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = s_body.flip_x

			queue_insert(store, fx)
			U.y_wait(store, fts(13))

			if U.random_table_idx(pow_chances) == 2 then
				block_random_tower()
			else
				signal.emit("block-random-power", this.power_block_duration, "drow_queen")
			end

			U.y_animation_wait(this)

			pow_cooldown = pow_cooldown_min
			cast_ts = store.tick_ts

			if this.shield.health.hp > 0 then
				goto label_337_0
			end
		end

		U.y_wait(store, fts(12))

		this.health_bar.hidden = true
		this.vis.bans = U.flag_set(this.vis.bans, bor(F_RANGED, F_MOD))
	end

	local function y_fight()
		this.health_bar.hidden = false
		this.vis.bans = U.flag_clear(this.vis.bans, bor(F_BLOCK, F_RANGED, F_MOD, F_TELEPORT))
		this.tween.disabled = false
		this.tween.reverse = true
		this.tween.ts = store.tick_ts

		while true do
			if this.health.hp <= this.hp_threshold then
				break
			end

			if this.unit.is_stunned then
				U.animation_start(this, "idle", nil, store.tick_ts, -1)
				coroutine.yield()
			else
				local function break_fn(store, this)
					return this.health.hp <= this.hp_threshold
				end

				if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, break_fn, break_fn) then
					-- block empty
				else
					coroutine.yield()
				end
			end
		end

		U.unblock_all(store, this)
		SU.remove_modifiers(store, this)

		this.tween.reverse = false
		this.tween.ts = store.tick_ts
		this.health_bar.hidden = true
		this.vis.bans = U.flag_set(this.vis.bans, bor(F_BLOCK, F_RANGED, F_MOD, F_TELEPORT))
	end

	local function y_death()
		this.ui.can_select = false

		S:queue(this.sound_events.death)
		U.y_animation_play(this, "death", true, store.tick_ts)
		U.y_wait(store, 0.5)
		U.y_animation_play(this, "deathEnd", true, store.tick_ts)

		local spider = E:create_entity("decal_s11_mactans")

		spider.pos_drop = V.v(this.pos.x + 8, this.pos.y - 15)
		spider.pos_start = V.v(spider.pos_drop.x, 1100)
		spider.pos.x, spider.pos.y = spider.pos_start.x, spider.pos_start.y

		queue_insert(store, spider)

		local shadow = E:create_entity("decal_mactans_shadow")

		shadow.pos.x, shadow.pos.y = spider.pos_drop.x, spider.pos_drop.y + 16

		queue_insert(store, shadow)

		shadow.tween.ts = store.tick_ts

		local thread = E:create_entity("decal_mactans_thread")

		thread.pos = spider.pos

		queue_insert(store, thread)
		U.animation_start(spider, "falling", nil, store.tick_ts, true)
		S:queue("ElvesFinalBossSpiderIn", {
			delay = spider.drop_duration - fts(25)
		})
		U.y_ease_key(store, spider.pos, "y", spider.pos_start.y, spider.pos_drop.y, spider.drop_duration, "quad-in")
		S:queue("ElvesFinalBossWebspin")
		U.y_animation_play(spider, "startingWeb", nil, store.tick_ts)
		U.animation_start(spider, "web", nil, store.tick_ts, true)

		local webbing = E:create_entity("decal_mactans_webbing")

		webbing.pos = V.v(spider.pos.x, spider.pos.y + 40)

		for i, sprite in ipairs(webbing.render.sprites) do
			sprite.ts = store.tick_ts + (i - 1) * fts(5)
		end

		queue_insert(store, webbing)
		U.y_wait(store, fts(13))

		local cocoon = E:create_entity("decal_s11_drow_queen_cocoon")

		cocoon.pos = spider.pos
		cocoon.render.sprites[1].ts = store.tick_ts

		queue_insert(store, cocoon)
		U.y_wait(store, fts(25))

		this.tween.ts = store.tick_ts
		this.tween.disabled = nil
		this.tween.props[1].disabled = nil
		this.tween.props[2].disabled = true
		this.tween.props[3].disabled = true

		U.y_wait(store, fts(41))
		queue_remove(store, webbing)
		U.animation_start(spider, "malicia_grab", nil, store.tick_ts, false)
		U.y_wait(store, fts(13))
		U.y_ease_key(store, cocoon.render.sprites[1].offset, "y", 15, 8, fts(5), "quad-in")
		U.y_animation_wait(spider)
		U.animation_start(cocoon, "netAnim", nil, store.tick_ts, true)

		cocoon.render.sprites[1].offset.y = -4
		shadow.tween.ts = store.tick_ts
		shadow.tween.reverse = true

		S:queue("ElvesFinalBossSpiderOut")
		U.animation_start(spider, "malicia_climbUp", nil, store.tick_ts, true)
		U.y_ease_key(store, spider.pos, "y", spider.pos_drop.y, spider.pos_start.y, spider.drop_duration)
	end

	this.health.hp_max = this.health.hp_max_rounds[store.level_difficulty][1]
	this.health.hp = this.health.hp_max
	this.pos.x, this.pos.y = this.pos_sitting.x, this.pos_sitting.y
	this.nav_path.pi = this.cast_pi
	this.nav_path.ni = P:nearest_nodes(this.pos.x, this.pos.y, {
		this.cast_pi
	})[1][3]
	this.ui.click_rect = this.ui.click_rect_sitting
	this.ui.can_select = false

	U.animation_start(this, "sittingIdle", false, store.tick_ts, true)

	this.phase_signal = nil

	while not this.phase_signal do
		coroutine.yield()
	end

	this.phase = "welcome"

	U.y_wait(store, 1.5)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 1, nil, 3, true)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 2, nil, 3, true)

	this.phase = "prebattle"
	this.phase_signal = nil

	while not this.phase_signal do
		local delay = math.random(this.taunts.delay_min, this.taunts.delay_max)

		if U.y_wait(store, delay, function()
			return this.phase_signal ~= nil
		end) then
			break
		end

		SU.y_show_taunt_set(store, this.taunts, this.phase, nil, nil, nil, true)
	end

	this.phase_signal = nil
	this.phase = "sitting"

	while true do
		if this.phase_signal == "summoner" then
			this.phase_signal = nil

			U.y_animation_play(this, "throneCast", false, store.tick_ts, 1, sid_body)
		elseif this.phase_signal == "taunt" then
			this.phase_signal = nil

			SU.y_show_taunt_set(store, this.taunts, this.phase)
		elseif this.phase_signal == "powers" then
			this.phase_signal = nil

			U.y_animation_play(this, "standUp", false, store.tick_ts, 1, sid_body)

			this.ui.click_rect = this.ui.click_rect_default
			this.phase = "flying"

			y_fly(this.pos, this.pos_casting, this.fly_speed_normal, this.cast_pi)

			this.phase = "casting"
			this.ui.can_select = true

			local __, __, shield_hp, pow_cooldown_min, pow_cooldown_max, pow_chances, shield_duration = unpack(this.phase_params, 1, 7)

			y_power(shield_hp, shield_duration, pow_cooldown_min, pow_chances)

			this.phase = "flying"
			this.ui.can_select = false

			y_fly(this.pos, this.pos_sitting, this.fly_speed_return, this.cast_pi)
			U.y_animation_play(this, "sitDown", false, store.tick_ts)

			this.phase = "sitting"
			this.ui.click_rect = this.ui.click_rect_sitting
		elseif this.phase_signal == "fight" then
			this.ui.click_rect = this.ui.click_rect_default
			this.phase = "flying"

			y_fly(this.pos, this.pos_casting, this.fly_speed_normal, this.cast_pi)

			this.phase = "casting"
			this.ui.can_select = true

			for i, fight_round in ipairs(this.fight_rounds) do
				local shield_hp, pow_cooldown_min, pow_cooldown_max, pow_chances, shield_duration, packs, pack_pis, fight_pi, tower_set = unpack(fight_round, 1, 9)

				y_power(shield_hp, shield_duration, pow_cooldown_min, pow_chances)

				this.hp = this.health.hp_max_rounds[store.level_difficulty][i]
				this.hp_threshold = this.health.hp_max_rounds[store.level_difficulty][i + 1] or 0

				block_tower_ids(this.tower_block_sets[tower_set])

				this.megaspawner.manual_wave = "BOSSFIGHT0"

				for i, pack_id in ipairs(packs) do
					this.portals[i].pack = {
						pi = pack_pis[i],
						waves = this.portal_packs[pack_id]
					}
					this.portals[i].pack_finished = nil
				end

				this.phase = "flying"
				this.ui.can_select = false

				y_fly(this.pos, this.pos_fighting, this.fly_speed_fight, fight_pi)

				this.ui.can_select = true
				this.phase = "fighting"
				this.health_bar.hidden = nil

				y_fight()

				this.health.hp = this.hp_threshold
				this.health_bar.hidden = true

				if this.health.hp > 0 then
					this.megaspawner.manual_wave = "BOSSRETURN0"
					this.health.dead = false
				else
					block_all_towers()

					this.megaspawner.interrupt = true

					for _, portal in pairs(this.portals) do
						portal.pack = nil
					end

					store.wave_spawn_thread = nil
					store.waves_finished = true
					store.waves_active = {}

					LU.kill_all_enemies(store, true)
				end

				this.phase = "flying"
				this.ui.can_select = false

				y_fly(this.pos, this.pos_casting, this.hp == 0 and this.fly_speed_return_die or this.fly_speed_return, this.cast_pi)

				this.phase = "casting"
				this.ui.can_select = true
			end

			this.phase = "mactans"

			S:stop_all()
			y_death()

			this.phase = "dead"

			signal.emit("boss-killed", this)

			return
		end

		coroutine.yield()
	end
end

scripts.decal_drow_queen_shield = {}

function scripts.decal_drow_queen_shield.update(this, store)
	while true do
		while this.health.hp <= 0 do
			coroutine.yield()
		end

		this.tween.reverse = false
		this.tween.ts = store.tick_ts
		this.tween.disabled = nil
		this.health_bar.hidden = false

		while this.health.hp > 0 do
			coroutine.yield()

			this.health.hp = this.health.hp - this.shield_dps * store.tick_length
		end

		this.health_bar.hidden = true
		this.tween.reverse = true
		this.tween.ts = store.tick_ts

		local fx = E:create_entity("fx_drow_queen_shield_break")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end
end

scripts.eb_spider = {}

function scripts.eb_spider.get_info(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = b.bullet.damage_min,
		damage_max = b.bullet.damage_max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_spider.update(this, store, script)
	local boss_rounds = store.level.boss_rounds
	local round_idx = 1
	local hp_max_rounds = this.health.hp_max_rounds[store.level_difficulty]

	this.health.hp_max = hp_max_rounds[round_idx]
	this.health.hp = this.health.hp_max

	local shadow = E:create_entity("decal_shadow_eb_spider")

	queue_insert(store, shadow)

	local function y_jump_out()
		U.unblock_all(store, this)
		SU.remove_modifiers(store, this)

		this.vis.bans = U.flag_set(this.vis.bans, bor(F_BLOCK, F_RANGED, F_MOD, F_TELEPORT))
		this.health_bar.hidden = true
		shadow.pos = V.v(this.pos.x, this.pos.y)

		U.animation_start(this, "jump", nil, store.tick_ts, false)
		U.y_wait(store, fts(10))

		shadow.tween.reverse = true
		shadow.tween.ts = store.tick_ts

		U.y_animation_wait(this)
		S:queue("ElvesFinalBossJump")

		local smoke = E:create_entity("fx_eb_spider_jump_smoke")

		smoke.pos.x, smoke.pos.y = this.pos.x, this.pos.y
		smoke.render.sprites[1].ts = store.tick_ts

		queue_insert(store, smoke)
		U.animation_start(this, "flyingUp", nil, store.tick_ts, false)

		for _, s in pairs(this.render.sprites) do
			s.sort_y = this.pos.y
		end

		U.y_ease_key(store, this.pos, "y", this.pos.y, this.pos.y + REF_H, 1, "quad-in")
	end

	local function y_jump_in(round_idx)
		this.megaspawner.manual_wave = string.format("BOSS%i", round_idx - 1)
		this.hp_threshold = hp_max_rounds[round_idx + 1] or 0

		local round = boss_rounds[round_idx]
		local pis = P:get_connected_paths(round.pi)
		local nodes = P:nearest_nodes(round.pos.x, round.pos.y, pis, nil, true)
		local dest, dest_node

		if #nodes < 0 then
			log.error("eb_spider: could not find node near %s,%s in paths:%s", round.pos.x, round.pos.y, getdump(pis))

			return
		else
			dest_node = {
				spi = 1,
				dir = 1,
				pi = nodes[1][1],
				ni = nodes[1][3]
			}
		end

		local dest = P:node_pos(dest_node)

		this.nav_path.pi = dest_node.pi
		this.nav_path.ni = dest_node.ni + 1
		this.pos.x, this.pos.y = dest.x, REF_H + 20

		for _, s in pairs(this.render.sprites) do
			s.sort_y = dest.y
		end

		shadow.tween.reverse = nil
		shadow.tween.ts = store.tick_ts
		shadow.pos.x, shadow.pos.y = dest.x, dest.y

		U.animation_start(this, "flyingDown", nil, store.tick_ts, false)

		local landing = false

		U.y_ease_key(store, this.pos, "y", this.pos.y, dest.y, 0.6, "quad-out", function(dt, ph)
			if dt >= 0.5 and not landing then
				landing = true

				S:queue("ElvesFinalBossSpiderGoddessFall")
				U.animation_start(this, "land", nil, store.tick_ts, false)
			end
		end)

		for _, s in pairs(this.render.sprites) do
			s.sort_y = nil
		end

		U.y_animation_wait(this)

		shadow.pos = this.pos
		this.health_bar.hidden = nil
		this.vis.bans = U.flag_clear(this.vis.bans, bor(F_BLOCK, F_RANGED, F_MOD, F_TELEPORT))

		local aura = E:create_entity("aura_eb_spider_path_web")

		aura.pos.x, aura.pos.y = dest.x, dest.y
		aura.aura.ts = store.tick_ts
		aura.eggs = store.level.mactans_eggs
		aura.qty_per_egg = round.qty_per_egg
		aura.pi = dest_node.pi
		aura.ni = dest_node.ni

		queue_insert(store, aura)
	end

	local function y_death()
		this.health_bar.hidden = true

		S:queue(this.sound_events.death)
		U.y_animation_play(this, "death_first_start", nil, store.tick_ts)
		SU.y_show_taunt_set(store, this.taunts, "death", 1, this.pos, 2, false)
		U.y_animation_play(this, "death_first_loop", nil, store.tick_ts, 10)
		U.animation_start(this, "death_second_start", nil, store.tick_ts, false)
		U.y_wait(store, fts(6))

		local rays = E:create_entity("decal_eb_spider_death_second_rays")

		rays.pos.x, rays.pos.y = this.pos.x, this.pos.y + 68
		rays.tween.ts = store.tick_ts

		queue_insert(store, rays)
		U.y_animation_wait(this)
		U.animation_start(this, "death_second_loop", nil, store.tick_ts, true)
		U.y_wait(store, fts(7) + 2)

		local circle = E:create_entity("decal_eb_spider_death_white_circle")

		circle.pos.x, circle.pos.y = rays.pos.x, rays.pos.y
		circle.tween.ts = store.tick_ts

		queue_insert(store, circle)
		U.y_wait(store, 0.5)
	end

	local function y_destroy_tower()
		local a = this.timed_attacks.list[3]
		local towers = table.filter(store.entities, function(_, e)
			return e.tower and e.tower.can_be_mod and not e.tower.blocked and not table.contains(a.excluded_templates, e.template_name) and math.abs(e.pos.x - this.pos.x) > 45 and U.is_inside_ellipse(e.pos, this.pos, a.max_range)
		end)

		if #towers < 1 then
			return
		end

		local tower = table.random(towers)

		S:queue(a.sound)

		local af = tower.pos.x < this.pos.x

		U.y_animation_play(this, a.animations[1], af, store.tick_ts)
		U.y_animation_play(this, a.animations[2], af, store.tick_ts, 2)
		U.animation_start(this, a.animations[3], af, store.tick_ts, false)
		U.y_wait(store, a.shoot_time)

		local o = a.bullet_start_offset[1]
		local b = E:create_entity(a.bullet)

		b.bullet.from = V.v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
		b.bullet.to = V.v(tower.pos.x, tower.pos.y + 8)
		b.bullet.source_id = this.id
		b.bullet.target_id = tower.id
		b.pos = V.vclone(b.bullet.from)

		queue_insert(store, b)
		U.y_animation_wait(this)
	end

	local function reset_cooldowns()
		this.ranged.attacks[1].ts = store.tick_ts
		this.timed_attacks.list[1].ts = store.tick_ts
		this.timed_attacks.list[2].ts = store.tick_ts
	end

	local function ready_to_jump()
		return this.health.hp > 0 and this.health.hp <= this.hp_threshold
	end

	local function ready_to_long_range()
		local a = this.timed_attacks.list[1]

		return store.tick_ts - a.ts > a.cooldown
	end

	local function ready_to_block()
		local a = this.timed_attacks.list[2]

		return store.tick_ts - a.ts > a.cooldown
	end

	local function break_fn()
		return ready_to_jump() or ready_to_long_range() or ready_to_block() or this.unit.is_stunned
	end

	this.health_bar.hidden = true
	shadow.pos = this.pos
	shadow.tween.reverse = nil
	shadow.tween.ts = 0

	local fx = E:create_entity("fx_eb_spider_spawn")

	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y - 1

	queue_insert(store, fx)
	U.y_wait(store, fts(45))

	fx.tween.disabled = nil
	fx.tween.ts = store.tick_ts

	U.animation_start(this, "shoutOurs", nil, store.tick_ts, false)
	U.y_wait(store, fts(6))
	SU.y_show_taunt_set(store, this.taunts, "intro", 1, V.v(this.pos.x, this.pos.y - 30), fts(48), true)
	y_jump_out()
	U.y_wait(store, 1)
	y_jump_in(round_idx)
	reset_cooldowns()

	this.phase = "fight"

	local cont, blocker, ranged

	::label_344_0::

	while true do
		if this.health.dead then
			this.phase = "death-animation"
			this.megaspawner.interrupt = true

			LU.kill_all_enemies(store, true)
			S:stop_all()
			y_death()
			signal.emit("boss-killed", this)

			this.phase = "dead"

			LU.kill_all_enemies(store, true)

			return
		end

		if ready_to_jump() then
			y_destroy_tower()

			round_idx = round_idx + 1

			y_jump_out()
			U.y_wait(store, 1)
			y_jump_in(round_idx)
		elseif this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, true)
			coroutine.yield()
		else
			if ready_to_long_range() then
				local a = this.timed_attacks.list[1]
				local targets = U.find_soldiers_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets then
					SU.delay_attack(store, a, 1)
				else
					local target = table.random(targets)

					a.ts = store.tick_ts

					SU.y_enemy_do_ranged_attack(store, this, target, a)

					a.ts = store.tick_ts
				end
			end

			if ready_to_block() then
				local a = this.timed_attacks.list[2]

				U.animation_start(this, "blockTower", nil, store.tick_ts, false)
				U.y_wait(store, a.hit_time)
				S:queue(a.hit_sound)

				local towers = table.filter(store.entities, function(_, e)
					return e.tower and e.tower.can_be_mod and not e.tower.blocked
				end)
				local sel_towers = {}

				while #towers > 0 and #sel_towers < a.tower_count[round_idx] do
					local t, i = table.random(towers)

					table.insert(sel_towers, t)
					table.remove(towers, i)
				end

				for _, e in pairs(sel_towers) do
					local m = E:create_entity(a.mod)

					m.modifier.source_id = this.id
					m.modifier.target_id = e.id
					m.pos.x, m.pos.y = e.pos.x, e.pos.y

					if duration then
						m.modifier.duration = duration
					end

					queue_insert(store, m)
				end

				signal.emit("block-random-power", a.power_block_duration, "eb_spider")
				U.y_animation_wait(this)

				a.ts = store.tick_ts

				goto label_344_0
			end

			cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, break_fn)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_344_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not break_fn() do
						if not SU.y_enemy_range_attacks(store, this, blocker) then
							goto label_344_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_bram = {}

function scripts.eb_bram.get_info(this)
	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = this.melee.attacks[1].damage_min,
		damage_max = this.melee.attacks[1].damage_max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_bram.update(this, store)
	local ac = this.timed_attacks.list[1]

	local function ready_to_convert()
		return store.tick_ts - ac.ts > ac.cooldown and P:nodes_to_defend_point(this.nav_path) > ac.nodes_limit
	end

	this.phase_signal = nil

	while not this.phase_signal do
		coroutine.yield()
	end

	this.phase = "welcome"

	U.y_wait(store, 1.5)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 1, nil, 3, true)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 2, nil, 3, true)

	this.phase = "sitting"
	this.phase_signal = nil

	while not this.phase_signal do
		local delay = math.random(this.taunts.delay_min, this.taunts.delay_max)

		if U.y_wait(store, delay, function()
			return this.phase_signal ~= nil
		end) then
			break
		end

		SU.y_show_taunt_set(store, this.taunts, this.phase, nil, nil, nil, true)
	end

	this.phase = "prebattle"

	U.y_wait(store, 1.5)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 1, nil, 3, true)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 2, nil, 3, true)

	this.phase = "battle"
	this.health_bar.hidden = nil

	U.y_animation_play(this, "raise", nil, store.tick_ts)

	::label_358_0::

	while true do
		if this.health.dead then
			this.phase = "dead"

			LU.kill_all_enemies(store, true)
			S:stop_all()
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			LU.kill_all_enemies(store, true)

			this.phase = "death-complete"

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_convert() then
				local a = ac
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
					return table.contains(a.allowed_templates, e.template_name)
				end)

				if not targets or #targets < a.min_count then
					SU.delay_attack(store, a, 0.5)
				else
					a.ts = store.tick_ts

					U.animation_start(this, a.animation, nil, store.tick_ts, false)

					while store.tick_ts - a.ts < a.cast_time do
						if this.health.dead or this.unit.is_stunned then
							goto label_358_0
						end

						coroutine.yield()
					end

					local decal = E:create_entity(a.hit_decal)

					decal.pos.x, decal.pos.y = this.pos.x, this.pos.y
					decal.tween.ts = store.tick_ts

					queue_insert(store, decal)

					for i, target in ipairs(targets) do
						if i > a.max_count then
							break
						end

						local e = E:create_entity(a.mod)

						e.modifier.target_id = target.id

						queue_insert(store, e)
					end

					SU.y_enemy_animation_wait(this)

					goto label_358_0
				end
			end

			local ok, blocker = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_convert()
			end)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_358_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_convert() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_358_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.mod_bram_slap = {}

function scripts.mod_bram_slap.queue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		target.vis.bans = F_ALL

		SU.stun_inc(target)
	end
end

function scripts.mod_bram_slap.update(this, store)
	local target = store.entities[this.modifier.target_id]
	local source = store.entities[this.modifier.source_id]

	if not target or not source then
		queue_remove(store, this)

		return
	end

	local af = source.pos.x > target.pos.x

	this.pos.x, this.pos.y = target.pos.x, target.pos.y

	local d = E:create_entity("damage")

	d.damage_type = DAMAGE_EAT
	d.source_id = this.id
	d.target_id = target.id

	queue_damage(store, d)

	local es = E:create_entity("decal_bram_enemy_clone")

	es.pos.x, es.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
	es.render = table.deepclone(target.render)
	es.render.sprites[1].anchor = this.custom_anchors[target.template_name] or this.custom_anchors.default
	es.tween.disabled = nil
	es.tween.ts = store.tick_ts

	local dx, dy = V.rotate(math.random(20, 45) * math.pi / 180, math.random(180, 240), 0)

	dx = (af and -1 or 1) * dx
	es.tween.props[2].keys[2][2].x, es.tween.props[2].keys[2][2].y = dx, dy
	es.tween.props[3].keys[2][2] = (af and -1 or 1) * math.random(300, 400) * math.pi / 180

	queue_insert(store, es)
	queue_remove(store, this)
end

scripts.eb_bajnimen = {}

function scripts.eb_bajnimen.on_damage(this, store, damage)
	log.debug("  EB_BAJNIMEN ON_DAMAGE: %s", damage.value)

	local ar = this.timed_attacks.list[2]

	if this.health.dead or ar.current_step > #ar.steps then
		return true
	end

	if ar.active then
		return false
	end

	local pd = U.predict_damage(this, damage)

	if ar.steps[ar.current_step].hp_threshold > (this.health.hp - pd) / this.health.hp_max then
		ar.active = true
	end

	return true
end

function scripts.eb_bajnimen.update(this, store)
	local as = this.timed_attacks.list[1]
	local ar = this.timed_attacks.list[2]
	local cont, blocker, ranged

	local function spawn_meteor(pi, spi, ni)
		spi = spi or math.random(1, 3)

		local pos = P:node_pos(pi, spi, ni)

		pos.x = pos.x + math.random(-4, 4)
		pos.y = pos.y + math.random(-5, 5)

		local b = E:create_entity(as.bullet)

		b.bullet.from = V.v(pos.x + math.random(190, 160), pos.y + REF_H)
		b.bullet.to = pos
		b.pos = V.vclone(b.bullet.from)

		queue_insert(store, b)
	end

	local function ready_to_storm()
		return store.tick_ts - as.ts > as.cooldown
	end

	local function ready_to_regen()
		return ar.active
	end

	local function break_fn()
		return ready_to_storm() or ready_to_regen() or this.unit.is_stunned
	end

	as.ts = store.tick_ts
	ar.ts = store.tick_ts

	::label_366_0::

	while true do
		if this.health.dead then
			this.phase = "dead"

			LU.kill_all_enemies(store, true)
			S:stop_all()
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			LU.kill_all_enemies(store, true)

			this.phase = "death-complete"

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_storm() then
				local a = as
				local hero = store.main_hero
				local target

				if hero and not hero.health.dead and band(hero.vis.bans, F_RANGED) == 0 then
					target = hero
				else
					target = U.find_random_target(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)
				end

				if not target then
					SU.delay_attack(store, a, 0.2)
				else
					a.ts = store.tick_ts

					S:queue(a.sound)
					U.y_animation_play(this, a.animations[1], nil, store.tick_ts)
					U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

					local nearest = P:nearest_nodes(target.pos.x, target.pos.y)

					if #nearest > 0 then
						local pi, spi, ni = unpack(nearest[1])

						spawn_meteor(pi, spi, ni)

						local count = a.spread
						local sequence = {}

						for i = 1, count do
							sequence[i] = i
						end

						while #sequence > 0 do
							local i = table.remove(sequence, math.random(1, #sequence))
							local delay = U.frandom(0, 1 / count)

							U.y_wait(store, delay / 2)

							if P:is_node_valid(pi, ni + i) then
								spawn_meteor(pi, nil, ni + i)
							else
								spawn_meteor(pi, nil, ni - i)
							end

							U.y_wait(store, delay / 2)

							if P:is_node_valid(pi, ni - i) then
								spawn_meteor(pi, nil, ni - i)
							else
								spawn_meteor(pi, nil, ni + i)
							end
						end
					end

					if SU.y_enemy_wait(store, this, 1) then
						-- block empty
					else
						U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

						a.ts = store.tick_ts
					end

					goto label_366_0
				end
			end

			if ready_to_regen() then
				local a = ar
				local hp_heal = a.steps[a.current_step].hp_heal

				S:queue(a.sound)
				U.y_animation_play(this, a.animations[1], nil, store.tick_ts)

				local prev_hit_offset = this.unit.hit_offset
				local prev_mod_offset = this.unit.mod_offset

				this.unit.hit_offset = a.hit_offset
				this.unit.mod_offset = a.mod_offset

				U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

				local start_ts, tick_ts = store.tick_ts, store.tick_ts - a.heal_every

				while store.tick_ts - start_ts <= a.duration do
					if store.tick_ts - tick_ts >= a.heal_every then
						tick_ts = tick_ts + a.heal_every
						this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + hp_heal)
					end

					coroutine.yield()
				end

				U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

				this.unit.hit_offset = prev_hit_offset
				this.unit.mod_offset = prev_mod_offset
				a.current_step = a.current_step + 1
				a.active = false

				goto label_366_0
			end

			cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, break_fn)

			if not cont then
				-- block empty
			else
				if ranged then
					if not SU.can_range_soldier(store, this, ranged) then
						goto label_366_0
					end

					if not SU.y_enemy_range_attacks(store, this, ranged) then
						goto label_366_0
					end
				elseif blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_366_0
					end

					if not SU.can_melee_blocker(store, this, blocker) then
						coroutine.yield()

						goto label_366_0
					end

					if not SU.y_enemy_melee_attacks(store, this, blocker) then
						goto label_366_0
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_balrog = {}

function scripts.eb_balrog.update(this, store)
	local at = this.timed_attacks.list[1]
	local cont, blocker, ranged
	local stage_hero = LU.list_entities(store.entities, "hero_bolverk")[1]

	local function ready_to_taint()
		return store.tick_ts - at.ts > at.cooldown
	end

	at.ts = store.tick_ts

	::label_371_0::

	while true do
		if this.health.dead then
			this.phase = "dead"

			LU.kill_all_enemies(store, true)
			S:stop_all()
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			LU.kill_all_enemies(store, true)

			this.phase = "death-complete"

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_taint() then
				local a = at
				local hero = store.main_hero
				local target

				if hero and not hero.health.dead and U.flags_pass(hero.vis, at) then
					target = hero
				elseif stage_hero and not stage_hero.health.dead and U.flags_pass(stage_hero.vis, at) then
					target = stage_hero
				else
					target = U.find_random_target(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)
				end

				if not target then
					SU.delay_attack(store, at, 0.2)
				else
					local nearest = P:nearest_nodes(target.pos.x, target.pos.y)

					if #nearest < 1 then
						SU.delay_attack(store, at, 0.2)
					else
						local pi, spi, ni = unpack(nearest[1])
						local shoot_dest = P:node_pos(pi, 1, ni)

						S:queue(a.sound)

						local an, af, ai = U.animation_name_facing_point(this, a.animation, shoot_dest)

						U.animation_start(this, a.animation, af, store.tick_ts, false)
						U.y_wait(store, a.shoot_time)

						local o = a.bullet_start_offset[1]
						local b = E:create_entity(a.bullet)

						b.bullet.to = shoot_dest
						b.bullet.from = V.v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
						b.bullet.source_id = this.id
						b.pos = V.vclone(b.bullet.from)

						queue_insert(store, b)

						a.ts = store.tick_ts

						U.y_animation_wait(this)

						goto label_371_0
					end
				end
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_taint)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_371_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_taint() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_371_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_hee_haw = {}

function scripts.eb_hee_haw.update(this, store)
	local catapults = LU.list_entities(store.entities, "decal_catapult_endless")

	this.phase_signal = nil
	this.phase = "welcome"

	U.y_wait(store, 1.5)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 1, nil, 3, true)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 2, nil, 3, true)

	this.phase = "prebattle"

	while not this.phase_signal do
		local delay = math.random(this.taunts.delay_min, this.taunts.delay_max)

		if U.y_wait(store, delay, function()
			return this.phase_signal ~= nil
		end) then
			break
		end

		SU.y_show_taunt_set(store, this.taunts, this.phase, nil, nil, nil, true)
		coroutine.yield()
	end

	local last_wave_number
	local a = this.attacks
	local wave_config

	this.phase = "battle"
	this.taunts.next_ts = store.tick_ts + math.random(this.taunts.delay_min, this.taunts.delay_max)

	while true do
		if store.tick_ts > this.taunts.next_ts then
			SU.y_show_taunt_set(store, this.taunts, this.phase, nil, nil, nil, true)

			this.taunts.next_ts = store.tick_ts + math.random(this.taunts.delay_min, this.taunts.delay_max)
		end

		if store.wave_group_number ~= last_wave_number then
			last_wave_number = store.wave_group_number
			wave_config = W:get_endless_boss_config(store.wave_group_number)
			a.chance = wave_config.chance
			a.cooldown = wave_config.cooldown
			a.multiple_attacks_chance = wave_config.multiple_attacks_chance
			a.power_chances = wave_config.power_chances

			log.debug("EB_HEE_HAW: setting wave config for wave %s - chance:%s cooldown:%s multi:%s", store.wave_group_number, a.chance, a.cooldown, a.multiple_attacks_chance)

			a.ts = store.tick_ts
		end

		if store.tick_ts - a.ts > a.cooldown then
			a.ts = store.tick_ts

			while math.random() < a.chance do
				local delay_to_power = U.frandom(0.6, 0.9)
				local a_idx = U.random_table_idx(a.power_chances)
				local aa = this.attacks.list[a_idx]
				local plevel = km.clamp(0, 9000000000, store.wave_group_number - wave_config.powers_config.powerProgressionWaveStart)

				log.debug("EB_HEE_HAW | ts:%s wave:%s attack idx:%s, plevel:%s", store.tick_ts, store.wave_group_number, a_idx, plevel)

				if a_idx == 1 or a_idx == 2 then
					local catapult = table.random(table.filter(catapults, function(k, c)
						return c.phase == "out"
					end))

					if not catapult then
						log.debug("eb_hee_haw: skipping catapult attack. both catapults busy.")

						goto label_373_0
					end

					U.y_wait(store, delay_to_power)
					S:queue(aa.sound)
					U.y_animation_play(this, aa.animation, nil, store.tick_ts)

					local pconf = a_idx == 1 and wave_config.powers_config.barrel or wave_config.powers_config.catapult
					local dconf = wave_config.boss_config_dif

					catapult.duration = km.clamp(0, pconf.durationMax, pconf.duration + plevel * pconf.durationIncrement)

					local ca = catapult.ranged.attacks[1]

					ca.cooldown = pconf.reload or pconf.munitionReload

					local multi_chance = pconf.multishotChance + plevel * pconf.multishotChanceIncrement

					if multi_chance > math.random() then
						local m_idx = U.random_table_idx(a_idx == 1 and dconf.barrelAmountDistribution or dconf.catapultAmountDistribution)

						ca.count = aa.multishot_counts[m_idx]
					else
						ca.count = 1
					end

					if a_idx == 1 then
						ca.munition_type = aa.munition_type
						ca.barrel_payload_idx = U.random_table_idx(dconf.barrelTypeDistribution)
					else
						ca.munition_type = U.random_table_idx(dconf.catapultMunitionTypeDistribution)
						ca.min_x = pconf.minRange
						ca.max_range = pconf.maxRange
					end

					catapult.phase_signal = "enter"
				elseif a_idx == 3 then
					local target
					local h = store.main_hero

					if h and not h.health.dead and not h.unit.is_stunned and not U.flag_has(h.vis.flags, F_FLYING) then
						target = h
					else
						target = U.find_random_target(store.entities, V.v(0, 0), 0, 1e+99, F_RANGED, bor(F_ENEMY, F_FLYING), function(e)
							return not e.unit.is_stunned
						end)
					end

					if not target then
						log.debug("eb_hee_haw: skipping snare attack. both catapults busy.")

						goto label_373_0
					end

					U.y_wait(store, delay_to_power)
					U.animation_start(this, aa.animation, nil, store.tick_ts)
					U.y_wait(store, aa.shoot_time)

					local pconf = wave_config.powers_config.snare
					local b = E:create_entity(aa.bullet)

					b.pos = V.v(this.pos.x + aa.bullet_start_offset.x, this.pos.y + aa.bullet_start_offset.y)
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = V.vclone(target.pos)
					b.bullet.target_id = target.id
					b.bullet.mod_duration = km.clamp(pconf.duration, pconf.durationMax, pconf.duration + plevel * pconf.durationIncrement)

					queue_insert(store, b)
					U.y_animation_wait(this)
				end

				U.animation_start(this, "idle", nil, store.tick_ts)

				::label_373_0::

				if math.random() >= a.multiple_attacks_chance then
					break
				end
			end
		end

		coroutine.yield()
	end
end

scripts.snare_hee_haw = {}

function scripts.snare_hee_haw.update(this, store)
	local b = this.bullet

	this.render.sprites[1].flip_y = true

	U.y_ease_key(store, this.pos, "y", this.pos.y, this.pos.y + 1000, 0.5)
	SU.insert_sprite(store, "decal_snare_hee_haw", b.to)
	S:queue(this.sound_events.falling)

	this.render.sprites[1].flip_y = nil
	this.pos.x, this.pos.y = b.to.x, b.to.y + 1600

	U.y_ease_keys(store, {
		this.pos,
		this.pos
	}, {
		"x",
		"y"
	}, {
		this.pos.x,
		this.pos.y
	}, {
		b.to.x,
		b.to.y
	}, 2)
	S:queue(this.sound_events.hit)

	local target = store.entities[b.target_id]

	if target and not target.health.dead and U.flags_pass(target.vis, b) and U.is_inside_ellipse(target.pos, b.to, b.mod_radius) then
		local m = E:create_entity(b.mod)

		m.modifier.target_id = target.id
		m.modifier.source_id = this.id
		m.modifier.duration = b.mod_duration
		m.modifier.duration_heroes = b.mod_duration

		queue_insert(store, m)
	else
		this.pos.y = b.to.y
		this.render.sprites[1].z = Z_OBJECTS
		this.render.sprites[1].sort_y_offset = -2

		U.y_animation_play(this, "miss", nil, store.tick_ts)
		U.y_ease_key(store, this.render.sprites[1], "alpha", 255, 0, fts(10))
	end

	queue_remove(store, this)
end

scripts.eb_ainyl = {}

function scripts.eb_ainyl.update(this, store)
	this.phase_signal = nil
	this.phase = "welcome"

	U.y_wait(store, 1.5)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 1, nil, 3, true)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 2, nil, 3, true)

	this.phase = "prebattle"

	while not this.phase_signal do
		local delay = math.random(this.taunts.delay_min, this.taunts.delay_max)

		if U.y_wait(store, delay, function()
			return this.phase_signal ~= nil
		end) then
			break
		end

		SU.y_show_taunt_set(store, this.taunts, this.phase, nil, nil, nil, true)
		coroutine.yield()
	end

	local last_wave_number
	local a = this.attacks
	local wave_config

	this.phase = "battle"
	this.taunts.next_ts = store.tick_ts + math.random(this.taunts.delay_min, this.taunts.delay_max)

	while true do
		if store.tick_ts > this.taunts.next_ts then
			SU.y_show_taunt_set(store, this.taunts, this.phase, nil, nil, nil, true)

			this.taunts.next_ts = store.tick_ts + math.random(this.taunts.delay_min, this.taunts.delay_max)
		end

		if store.wave_group_number ~= last_wave_number then
			last_wave_number = store.wave_group_number
			wave_config = W:get_endless_boss_config(store.wave_group_number)
			a.chance = wave_config.chance
			a.cooldown = wave_config.cooldown
			a.multiple_attacks_chance = wave_config.multiple_attacks_chance
			a.power_chances = wave_config.power_chances

			log.debug("EB_AINYL: setting wave config for wave %s - chance:%s cooldown:%s multi:%s", store.wave_group_number, a.chance, a.cooldown, a.multiple_attacks_chance)

			a.ts = store.tick_ts
		end

		if store.tick_ts - a.ts > a.cooldown then
			a.ts = store.tick_ts

			while math.random() < a.chance do
				local a_idx = U.random_table_idx(a.power_chances)
				local aa = this.attacks.list[a_idx]
				local plevel = km.clamp(0, 9000000000, store.wave_group_number - wave_config.powers_config.powerProgressionWaveStart)

				log.debug("EB_AINYL | ts:%s wave:%s attack idx:%s, plevel:%s", store.tick_ts, store.wave_group_number, a_idx, plevel)

				if a_idx == 1 then
					local pconf = wave_config.powers_config.teleport
					local best_set = {}
					local target

					for _, ce in pairs(store.entities) do
						if not ce.pending_removal and ce.enemy and ce.vis and ce.nav_path and not ce.health.dead and band(ce.vis.flags, aa.vis_bans) == 0 and band(ce.vis.bans, aa.vis_flags) == 0 and P:is_node_valid(ce.nav_path.pi, ce.nav_path.ni) and P:nodes_to_defend_point(ce.nav_path) > aa.nodes_limit then
							local nearby = table.filter(store.entities, function(k, v)
								return v ~= ce and not v.pending_removal and v.enemy and v.vis and v.nav_path and v.health and not v.health.dead and band(v.vis.flags, aa.vis_bans) == 0 and band(v.vis.bans, aa.vis_flags) == 0 and P:is_node_valid(v.nav_path.pi, v.nav_path.ni) and v.nav_path.pi == ce.nav_path.pi and math.abs(v.nav_path.ni - ce.nav_path.ni) < pconf.nodesRange and P:nodes_to_defend_point(v.nav_path) > aa.nodes_limit
							end)

							if #nearby > #best_set then
								target = ce
								best_set = nearby
							end
						end
					end

					if not target or not best_set then
						log.debug("eb_ainyl: skipping teleport. target:%s, best_set:%s", target, best_set)

						goto label_378_0
					end

					local targets = table.append({
						target
					}, best_set)

					if #targets < pconf.minEnemies then
						log.debug("eb_ainyl: skipping teleport. not enough #targets:%s", #targets)

						goto label_378_0
					end

					S:queue(aa.sound)
					U.animation_start(this, aa.animation, nil, store.tick_ts)
					U.y_wait(store, aa.shoot_time)

					for i = 1, math.min(#targets, pconf.maxEnemies) do
						local e = targets[i]
						local m = E:create_entity(aa.mod)

						m.nodes_offset = math.random(pconf.minNodes, pconf.maxNodes)
						m.modifier.target_id = e.id
						m.modifier.source_id = this.id

						queue_insert(store, m)
					end

					U.y_animation_wait(this)
				elseif a_idx == 2 then
					local pconf = wave_config.powers_config.blockTower
					local targets = U.find_towers_in_range(store.entities, this.pos, aa, function(t)
						return t.tower.can_be_mod
					end)

					if not targets then
						log.debug("eb_ainyl: skipping block_tower. target not found")

						goto label_378_0
					end

					S:queue(aa.sound)
					U.animation_start(this, aa.animation, nil, store.tick_ts)
					U.y_wait(store, aa.shoot_time)

					targets = U.find_towers_in_range(store.entities, this.pos, aa, function(t)
						return t.tower.can_be_mod
					end)

					if not targets then
						log.debug("eb_ainyl: skipping block_tower. target not found in second search")
					else
						local target = table.random(targets)
						local m = E:create_entity(aa.mod)

						m.modifier.target_id = target.id
						m.modifier.source_id = this.id
						m.modifier.duration = km.clamp(0, pconf.durationMax, pconf.duration + plevel * pconf.durationIncrement)

						queue_insert(store, m)
					end

					U.y_animation_wait(this)
				elseif a_idx == 3 then
					local pconf = wave_config.powers_config.shield
					local targets = U.find_enemies_in_range(store.entities, this.pos, 0, 1e+99, aa.vis_flags, aa.vis_bans, function(e)
						return e and e.health and e.health.hp < e.health.hp_max
					end)

					if not targets then
						log.debug("eb_ainyl: skipping shield. target not found")

						goto label_378_0
					end

					S:queue(aa.sound)
					U.animation_start(this, aa.animation, nil, store.tick_ts)
					U.y_wait(store, aa.shoot_time)

					targets = U.find_enemies_in_range(store.entities, this.pos, 0, 1e+99, aa.vis_flags, aa.vis_bans, function(e)
						return e and e.health and e.health.hp < e.health.hp_max
					end)

					if not targets then
						log.debug("eb_ainyl: skipping shield. target not found in second search")
					else
						table.sort(targets, function(e1, e2)
							return e1.health.hp < e2.health.hp
						end)

						local target = targets[1]

						SU.remove_modifiers(store, target)

						local m = E:create_entity(aa.mod)

						m.modifier.target_id = target.id
						m.modifier.source_id = this.id
						m.modifier.duration = km.clamp(0, pconf.durationMax, pconf.duration + plevel * pconf.durationIncrement)

						queue_insert(store, m)
					end

					U.y_animation_wait(this)
				end

				U.animation_start(this, "idle", nil, store.tick_ts)

				::label_378_0::

				if math.random() >= a.multiple_attacks_chance then
					break
				end
			end
		end

		coroutine.yield()
	end
end

scripts.mod_block_tower_ainyl = {}

function scripts.mod_block_tower_ainyl.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	SU.tower_block_inc(target)

	this.pos.x, this.pos.y = target.pos.x, target.pos.y
	m.ts = store.tick_ts
	this.tween.ts = store.tick_ts

	if target.tower.size == TOWER_SIZE_LARGE then
		this.render.sprites[4].hidden = nil
		this.render.sprites[5].hidden = nil
	end

	U.y_wait(store, m.duration - 0.2)

	local fx = E:create_entity("fx_block_tower_ainyl_end")

	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)
	SU.tower_block_dec(target)
	queue_remove(store, this)
end

scripts.plant_magic_blossom = {}

function scripts.plant_magic_blossom.update(this, store)
	local ca = this.custom_attack
	local fx_loading = E:create_entity("fx_plant_magic_blossom_loading")
	local fx_idle1 = E:create_entity("fx_plant_magic_blossom_idle1")
	local fx_idle2 = E:create_entity("fx_plant_magic_blossom_idle2")

	fx_loading.pos.x, fx_loading.pos.y = this.pos.x, this.pos.y
	fx_idle1.pos.x, fx_idle1.pos.y = this.pos.x, this.pos.y
	fx_idle2.pos.x, fx_idle2.pos.y = this.pos.x, this.pos.y

	queue_insert(store, fx_loading)
	queue_insert(store, fx_idle1)
	queue_insert(store, fx_idle2)

	::label_387_0::

	fx_loading.render.sprites[1].hidden = true
	fx_idle1.render.sprites[1].hidden = true
	fx_idle2.render.sprites[1].hidden = true

	U.animation_start(this, "loading", nil, store.tick_ts, true)

	while (this.plant.blocked or store.wave_group_number < 1) and not this.force_ready do
		coroutine.yield()
	end

	::label_387_1::

	fx_loading.render.sprites[1].hidden = false
	fx_idle1.render.sprites[1].hidden = true
	fx_idle2.render.sprites[1].hidden = true

	U.animation_start(this, "loading", nil, store.tick_ts, true)

	ca.ts = store.tick_ts

	while store.tick_ts - ca.ts < ca.cooldown and not this.force_ready do
		if this.is_removed then
			break
		end
		if this.plant.blocked then
			goto label_387_0
		end

		coroutine.yield()
	end

	fx_loading.render.sprites[1].hidden = true

	U.y_animation_play(this, "ready", nil, store.tick_ts)

	fx_idle1.render.sprites[1].hidden = false
	fx_idle2.render.sprites[1].hidden = false

	-- signal.emit("wave-notification", "icon", "PLANT_MAGIC_BLOSSOM")

	this.force_ready = nil

	U.animation_start(this, "idle", nil, store.tick_ts, true)

	this.ui.clicked = nil

	while true do
		if this.is_removed then
			break
		end
		if this.plant.blocked then
			goto label_387_0
		end

		if this.ui.clicked then
			this.ui.clicked = nil

			-- AC:inc_check("GARDEN_SONG")
			S:queue(ca.sound)
			U.animation_start(this, "shoot", nil, store.tick_ts, false)
			U.y_wait(store, ca.shoot_time)

			local first, targets = U.find_foremost_enemy(store.entities, this.pos, 0, ca.range, true, ca.vis_flags, ca.vis_bans)

			for i = 1, ca.bullet_count do
				local b = E:create_entity(ca.bullet)

				b.bullet.shot_index = i
				b.bullet.source_id = this.id
				b.pos.x, b.pos.y = this.pos.x + ca.bullet_start_offset.x, this.pos.y + ca.bullet_start_offset.y
				b.bullet.from = V.vclone(b.pos)

				if targets and #targets > 0 then
					local target

					if i <= #targets then
						target = targets[i]
					else
						target = first
					end

					b.bullet.target_id = target.id
					b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
				else
					b.bullet.to = V.v(this.pos.x + ca.bullet_start_offset.x + math.random(-50, 50), this.pos.y + ca.bullet_start_offset.y + math.random(30, 100))
				end

				b.initial_impulse_angle_abs = math.pi / 2 + U.frandom(-math.pi / 2, math.pi / 2)
				b.initial_impulse = U.frandom(0.3, 1) * b.initial_impulse

				queue_insert(store, b)
			end

			U.y_animation_wait(this)

			goto label_387_1
		end

		coroutine.yield()
	end

	queue_remove(store, fx_loading)
	queue_remove(store, fx_idle1)
	queue_remove(store, fx_idle2)
	queue_remove(store, this)
end

scripts.plant_poison_pumpkin = {}

function scripts.plant_poison_pumpkin.update(this, store)
	local smokes1 = {
		{
			"left",
			-74,
			21,
			false,
			false
		},
		{
			"left",
			75,
			20,
			true,
			false
		},
		{
			"down",
			-4,
			-18,
			false,
			false
		},
		{
			"down",
			-4,
			62,
			false,
			true
		}
	}
	local smokes2 = {
		{
			"fill",
			24,
			0,
			false,
			false
		},
		{
			"fill",
			29,
			42,
			false,
			false
		},
		{
			"fill",
			-34,
			43,
			true,
			false
		},
		{
			"fill",
			-34,
			0,
			true,
			false
		}
	}
	local smokes3 = {
		{
			"fill",
			48,
			-4,
			false,
			false
		},
		{
			"fill",
			45,
			52,
			false,
			false
		},
		{
			"fill",
			-43,
			-3,
			true,
			false
		},
		{
			"fill",
			-45,
			56,
			true,
			false
		}
	}

	local function add_smokes(t)
		for _, item in pairs(t) do
			local name, x, y, flip_x, flip_y = unpack(item)
			local fx = E:create_entity("fx_plant_poison_pumpkin_smoke_" .. name)

			fx.pos.x, fx.pos.y = this.pos.x + x, this.pos.y + y
			fx.render.sprites[1].flip_x = flip_x
			fx.render.sprites[1].flip_y = flip_y
			fx.render.sprites[1].ts = store.tick_ts

			if name == "fill" and flip_x then
				fx.tween.props[3].keys[2][2].x = -1 * fx.tween.props[3].keys[2][2].x
				fx.tween.props[3].keys[3][2].x = -1 * fx.tween.props[3].keys[3][2].x
			end

			queue_insert(store, fx)
		end
	end

	local ca = this.custom_attack
	local fx_idle_l = E:create_entity("fx_plant_poison_pumpkin_idle")
	local fx_idle_c = E:create_entity("fx_plant_poison_pumpkin_idle")
	local fx_idle_r = E:create_entity("fx_plant_poison_pumpkin_idle")

	fx_idle_l.pos.x, fx_idle_l.pos.y = this.pos.x, this.pos.y
	fx_idle_c.pos.x, fx_idle_c.pos.y = this.pos.x, this.pos.y
	fx_idle_r.pos.x, fx_idle_r.pos.y = this.pos.x, this.pos.y
	fx_idle_l.render.sprites[1].offset = V.v(-30, 30)
	fx_idle_c.render.sprites[1].offset = V.v(-5, 28)
	fx_idle_r.render.sprites[1].offset = V.v(32, 30)
	fx_idle_l.render.sprites[1].flip_x = true
	fx_idle_c.render.sprites[1].flip_x = true

	queue_insert(store, fx_idle_l)
	queue_insert(store, fx_idle_c)
	queue_insert(store, fx_idle_r)

	this.fxs_idle = {
		fx_idle_l,
		fx_idle_c,
		fx_idle_r
	}
	local fxs_idle = this.fxs_idle

	::label_388_0::

	for _, fx in pairs(fxs_idle) do
		fx.render.sprites[1].hidden = true
	end

	U.animation_start(this, "loading", nil, store.tick_ts, true)

	while this.plant.blocked and not this.force_ready do
		coroutine.yield()
	end

	::label_388_1::

	for _, fx in pairs(fxs_idle) do
		fx.render.sprites[1].hidden = true
	end

	U.animation_start(this, "loading", nil, store.tick_ts, true)

	ca.ts = store.tick_ts

	while store.tick_ts - ca.ts < ca.cooldown and not this.force_ready do
		if this.plant.blocked then
			goto label_388_0
		end

		coroutine.yield()
	end

	-- signal.emit("wave-notification", "icon", "PLANT_VENOM")
	S:queue("VenomPlantReady")
	U.y_animation_play(this, "ready", nil, store.tick_ts)

	for _, fx in pairs(fxs_idle) do
		fx.render.sprites[1].hidden = nil
	end

	this.force_ready = nil

	U.animation_start(this, "idle", nil, store.tick_ts, true)

	this.ui.clicked = nil

	while true do
		if this.plant.blocked then
			goto label_388_0
		end

		if this.ui.clicked then
			this.ui.clicked = nil

			-- AC:inc_check("GARDEN_SONG")
			S:queue(ca.sound)
			U.animation_start(this, "shoot", nil, store.tick_ts, false)

			for _, fx in pairs(fxs_idle) do
				fx.render.sprites[1].hidden = true
			end

			U.y_wait(store, fts(9))
			add_smokes(smokes1)
			U.y_wait(store, fts(6))
			add_smokes(smokes2)
			U.y_wait(store, fts(2))
			add_smokes(smokes3)

			local first, targets = U.find_foremost_enemy(store.entities, this.pos, 0, ca.range, false, ca.vis_flags, ca.vis_bans)

			if first then
				for _, target in pairs(targets) do
					for _, mod_name in pairs(ca.mods) do
						local m = E:create_entity(mod_name)

						m.modifier.target_id = target.id
						m.modifier.source_id = this.id

						queue_insert(store, m)
					end
				end
			end

			U.y_animation_wait(this)

			goto label_388_1
		end

		coroutine.yield()
	end

	for _, fx in pairs(fxs_idle) do
		queue_remove(store, fx)
	end

	queue_remove(store, this)
end

scripts.crystal_arcane = {}

function scripts.crystal_arcane.update(this, store)
	local a = this.attacks
	local glow = this.render.sprites[2]
	local glow_tween = this.tween.props[1]
	local chances_list = {
		a.list[1].chance,
		a.list[2].chance,
		a.list[3].chance
	}
	local random_points = {
		V.v(this.pos.x - 50, this.pos.y - 50),
		V.v(this.pos.x + 50, this.pos.y + 50),
		V.v(this.pos.x - 50, this.pos.y + 50),
		V.v(this.pos.x + 50, this.pos.y - 50)
	}
	local freeze_points = {}
	local inner_fx_radius = 100
	local outer_fx_radius = 150

	for i = 1, 12 do
		local r = i % 2 == 0 and inner_fx_radius or outer_fx_radius
		local p = {}

		p.pos = U.point_on_ellipse(this.pos, r, 2 * math.pi * i / 12)
		p.terrain = GR:cell_type(p.pos.x, p.pos.y)

		log.debug("crystal_arcane.freeze_points - i:%i pos:%f,%f type:%i", i, p.pos.x, p.pos.y, p.terrain)

		if P:valid_node_nearby(p.pos.x, p.pos.y, 0.9) then
			table.insert(freeze_points, p.pos)
		end
	end

	while store.wave_group_number < 1 and not this.force_ready do
		coroutine.yield()
	end

	::label_390_0::

	a.ts = store.tick_ts
	glow.hidden = false
	glow_tween.keys = glow_tween.keys_loading
	glow_tween.ts = store.tick_ts
	glow_tween.loop = true

	U.animation_start(this, "loading", nil, store.tick_ts, true)

	while store.tick_ts - a.ts < a.cooldown and not this.force_ready do
		coroutine.yield()
	end

	this.ui.clicked = nil
	glow_tween.keys = glow_tween.keys_ready
	glow_tween.ts = store.tick_ts
	glow_tween.loop = false

	U.y_animation_play(this, "ready", nil, store.tick_ts)
	signal.emit("wave-notification", "icon", "ARCANE_CRYSTAL")

	this.force_ready = nil

	U.animation_start(this, "idle", nil, store.tick_ts, true)

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil

			local idx = U.random_table_idx(chances_list)
			local aa = a.list[idx]

			if idx == 1 then
				glow_tween.keys = glow_tween.keys_lightning
				glow_tween.ts = store.tick_ts
				glow.hidden = false

				S:queue(aa.sound)
				U.animation_start(this, aa.animation, nil, store.tick_ts, true)

				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, aa.range, aa.vis_flags, aa.vis_bans)

				for i = 1, aa.bullet_count do
					U.y_wait(store, fts(3))

					local target

					if targets then
						local tidx = math.random(1, #targets)

						target = table.remove(targets, tidx)
					end

					local b = E:create_entity(aa.bullet)

					b.bullet.from = V.v(this.pos.x + aa.bullet_start_offset.x, this.pos.y + aa.bullet_start_offset.y)
					b.bullet.to = target and V.vclone(target.pos) or V.vclone(table.random(random_points))
					b.bullet.target_id = target and target.id
					b.pos = V.vclone(b.bullet.from)

					queue_insert(store, b)
				end

				U.y_animation_wait(this)
			elseif idx == 2 then
				glow_tween.keys = glow_tween.keys_freeze
				glow_tween.ts = store.tick_ts
				glow.hidden = false

				U.animation_start(this, aa.animations[1], nil, store.tick_ts, false)
				U.y_wait(store, aa.hit_time)
				S:queue(aa.sound)

				local aura = E:create_entity(aa.aura)

				aura.pos.x, aura.pos.y = this.pos.x, this.pos.y
				aura.aura.ts = store.tick_ts

				queue_insert(store, aura)

				local d_center = E:create_entity(aa.fx_center)

				d_center.pos.x, d_center.pos.y = this.pos.x, this.pos.y
				d_center.render.sprites[1].ts = store.tick_ts
				d_center.duration = aa.duration

				queue_insert(store, d_center)

				for _, p in pairs(freeze_points) do
					local d = E:create_entity(table.random(aa.fxs))

					d.pos.x, d.pos.y = p.x, p.y
					d.render.sprites[1].ts = store.tick_ts
					d.render.sprites[1].flip_x = math.random() < 0.5
					d.duration = aa.duration + U.frandom(0, 0.2)

					queue_insert(store, d)
				end

				U.y_animation_wait(this)
				U.animation_start(this, aa.animations[2], nil, store.tick_ts, true)
				U.y_wait(store, aa.duration - 0.3)
				U.y_animation_play(this, aa.animations[3], nil, store.tick_ts)
			else
				glow_tween.keys = glow_tween.keys_buff
				glow_tween.ts = store.tick_ts
				glow.hidden = false

				S:queue(aa.sound)
				U.animation_start(this, aa.animation, nil, store.tick_ts, false)
				U.y_wait(store, aa.hit_time)

				local towers = table.filter(store.entities, function(_, e)
					return e.tower and not e.tower.blocked and not table.contains(aa.excluded_templates, e.template_name) and U.is_inside_ellipse(e.pos, this.pos, aa.range)
				end)

				for _, e in pairs(towers) do
					local fx = E:create_entity(aa.fx_base)

					fx.pos.x, fx.pos.y = e.pos.x, e.pos.y
					fx.tween.ts = store.tick_ts

					queue_insert(store, fx)

					if e.tower.can_be_mod then
						local mod = E:create_entity(aa.mod)

						mod.modifier.target_id = e.id
						mod.modifier.source_id = this.id
						mod.pos.x, mod.pos.y = e.pos.x, e.pos.y

						queue_insert(store, mod)

						if e.barrack then
							for _, soldier in pairs(e.barrack.soldiers) do
								if soldier and not soldier.health.dead then
									local m = E:create_entity(aa.mod_soldier)

									m.pos.x, m.pos.y = soldier.pos.x, soldier.pos.y
									m.modifier.target_id = soldier.id

									queue_insert(store, m)
								end
							end
						end
					end
				end

				U.y_animation_wait(this)
			end

			goto label_390_0
		end

		coroutine.yield()
	end
end

scripts.crystal_unstable = {}

function scripts.crystal_unstable.update(this, store)
	local a = this.attacks
	local idle_ts = 0
	local chances_list = {
		a.list[1].chance,
		a.list[2].chance,
		a.list[3].chance
	}

	local function add_fxs()
		for _, n in pairs({
			"fx_crystal_unstable_ring",
			"fx_crystal_unstable_glow"
		}) do
			local fx = E:create_entity(n)

			fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)
		end
	end

	local function y_play_idle()
		U.y_animation_play(this, math.random() < 0.5 and "loading" or "loading2", nil, store.tick_ts)
	end

	while store.wave_group_number < 1 and not this.force_ready do
		y_play_idle()
	end

	::label_392_0::

	a.ts = store.tick_ts

	while store.tick_ts - a.ts < a.cooldown and not this.force_ready do
		y_play_idle()
	end

	S:queue("ElvesUnstableCrystalReady")
	U.y_animation_play(this, "ready", nil, store.tick_ts)

	this.force_ready = nil

	while true do
		if idle_ts < store.tick_ts then
			U.animation_start(this, math.random() < 0.5 and "idle" or "idle2", nil, store.tick_ts, false, nil, true)

			idle_ts = store.tick_ts + fts(25) + U.frandom(5, 10)
		end

		local idx = U.random_table_idx(chances_list)
		local aa = a.list[idx]
		local casted = false

		if idx == 1 then
			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, aa.range, aa.vis_flags, aa.vis_bans)

			if not targets or #targets < aa.min_count then
				goto label_392_1
			end

			casted = true

			U.animation_start(this, aa.animation, nil, store.tick_ts)
			U.y_wait(store, aa.cast_time)

			local nodes_offset = (math.random() < aa.good_chance and -1 or 1) * math.random(aa.min_nodes, aa.max_nodes)

			for i = 1, math.min(#targets, aa.max_count) do
				if U.flags_pass(targets[i].vis, aa) then
					local m = E:create_entity(aa.mod)

					m.nodes_offset = nodes_offset
					m.modifier.target_id = targets[i].id
					m.modifier.source_id = this.id

					queue_insert(store, m)
				end
			end
		elseif idx == 2 then
			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, aa.range, aa.vis_flags, aa.vis_bans, function(e)
				return table.contains(aa.allowed_templates, e.template_name)
			end)

			if not targets or #targets < aa.min_count then
				goto label_392_1
			end

			casted = true

			U.animation_start(this, aa.animation, nil, store.tick_ts)
			U.y_wait(store, aa.cast_time)

			local do_kill = math.random() < aa.good_chance

			for i = 1, math.min(#targets, aa.max_count) do
				if U.flags_pass(targets[i].vis, aa) then
					local m = E:create_entity(aa.mod)

					m.modifier.target_id = targets[i].id
					m.modifier.source_id = this.id
					m.modifier.kill = do_kill

					queue_insert(store, m)
				end
			end
		else
			local targets = U.find_targets_in_range(store.entities, this.pos, 0, aa.range, aa.vis_flags, aa.vis_bans, function(e)
				return e.health and e.health.hp / e.health.hp_max < aa.trigger_hp_factor
			end)

			if not targets or #targets < aa.min_count then
				goto label_392_1
			end

			local best_count = -1
			local best_target

			for _, target in pairs(targets) do
				local nearby = U.find_targets_in_range(targets, target.pos, 0, aa.aura_range, aa.vis_flags, aa.vis_bans, function(e)
					return e.health and e.health.hp / e.health.hp_max < aa.trigger_hp_factor
				end)

				if nearby and best_count < #nearby then
					best_target = target
					best_count = #nearby
				end
			end

			if not best_target or best_count < aa.min_count then
				log.debug("(%s) crystal_unstable: skipping heal / best pack min count ", this.id)

				goto label_392_1
			end

			casted = true

			local pred_pos = V.vclone(best_target.pos)

			if best_target.nav_path then
				local n_off = P:predict_enemy_node_advance(best_target, aa.cast_time)

				pred_pos = P:node_pos(best_target.nav_path.pi, best_target.nav_path.spi, best_target.nav_path.ni + n_off)
			end

			S:queue(aa.sound)
			U.animation_start(this, aa.animation, nil, store.tick_ts)
			U.y_wait(store, aa.cast_time)

			local bc
			local nearby = U.find_targets_in_range(store.entities, pred_pos, 0, aa.aura_range, aa.vis_flags, aa.vis_bans)

			if nearby and #nearby > 0 then
				for i = 1, math.min(#nearby, aa.max_count) do
					local target = nearby[i]
					local m = E:create_entity(aa.mod)

					m.modifier.target_id = target.id
					m.modifier.source_id = this.id

					queue_insert(store, m)

					if not bc then
						bc = V.vclone(target.pos)
					else
						bc.x, bc.y = V.add(bc.x, bc.y, target.pos.x, target.pos.y)
					end
				end

				local fx = E:create_entity("fx_crystal_unstable_heal")

				fx.pos.x, fx.pos.y = V.mul(1 / #nearby, bc.x, bc.y)
				fx.tween.ts = store.tick_ts

				U.animation_start(fx, nil, nil, store.tick_ts)
				queue_insert(store, fx)
			end
		end

		if casted then
			add_fxs()
			U.y_animation_wait(this)

			goto label_392_0
		end

		::label_392_1::

		U.y_wait(store, fts(5))
	end
end

scripts.paralyzing_tree = {}

function scripts.paralyzing_tree.update(this, store)
	local ca = this.custom_attack

	local function add_fx(count, radius, offset, angle_start, angle)
		for i = 1, count do
			local a = km.deg2rad(angle_start + angle * (i - 1))
			local pos = U.point_on_ellipse(this.pos, radius, a)
			local fx = SU.insert_sprite(store, "fx_paralyzing_tree_" .. math.random(1, 3), pos)

			fx.render.sprites[1].r = U.frandom(0, km.pi)

			queue_insert(store, fx)
		end
	end

	U.animation_start(this, "loading", nil, store.tick_ts, true)

	while (this.plant.blocked or store.wave_group_number < 1) and not this.force_ready do
		coroutine.yield()
	end

	::label_398_0::

	U.animation_start(this, "loading", nil, store.tick_ts, true)

	ca.ts = store.tick_ts

	while store.tick_ts - ca.ts < ca.cooldown and not this.force_ready do
		coroutine.yield()
	end

	signal.emit("wave-notification", "icon", "PARALYZING_TREE")
	S:queue("ElvesWhiteTreeActivate")
	U.animation_start(this, "ready", nil, store.tick_ts, true)

	this.ui.clicked = nil
	this.force_ready = nil

	while not this.ui.clicked do
		coroutine.yield()
	end

	S:queue("ElvesWhiteTreeTap")
	U.animation_start(this, ca.animation, nil, store.tick_ts)
	add_fx(6, 70, 20, -110, 45)
	U.y_wait(store, fts(2))
	add_fx(13, 111, 30, -125, 30)
	U.y_wait(store, fts(2))
	add_fx(17, 142.5, 30, -170, 30)
	U.y_wait(store, fts(4))

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, ca.range, ca.vis_flags, ca.vis_bans)

	if targets then
		for _, t in pairs(targets) do
			local m = E:create_entity(ca.mod)

			m.modifier.source_id = this.id
			m.modifier.target_id = t.id

			queue_insert(store, m)
		end
	end

	U.y_animation_wait(this)

	goto label_398_0
end

scripts.bolt_elves = {}

function scripts.bolt_elves.insert(this, store)
	return true
end

function scripts.bolt_elves.update(this, store)
	local b = this.bullet
	local fm = this.force_motion
	local target = store.entities[b.target_id]
	local ps

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

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.emit = true
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	local pred_pos

	if target then
		pred_pos = P:predict_enemy_pos(target, fts(5))
	else
		pred_pos = b.to
	end

	local iix, iiy = V.normalize(pred_pos.x - this.pos.x, pred_pos.y - this.pos.y)
	local last_pos = V.vclone(this.pos)

	b.ts = store.tick_ts

	while true do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
			local d = math.max(math.abs(target.pos.x + target.unit.hit_offset.x - b.to.x), math.abs(target.pos.y + target.unit.hit_offset.y - b.to.y))

			if d > b.max_track_distance then
				log.debug("BOLT MAX DISTANCE FAIL. (%s) %s / dist:%s target.pos:%s,%s b.to:%s,%s", this.id, this.template_name, d, target.pos.x, target.pos.y, b.to.x, b.to.y)

				target = nil
				b.target_id = nil
			else
				b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
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

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
		end

		coroutine.yield()
	end

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)
		local u = UP:get_upgrade("mage_el_empowerment")

		if u and not this.upgrades_disabled and math.random() < u.chance then
			d.value = km.round(d.value * u.damage_factor)

			if b.pop_mage_el_empowerment then
				d.pop = b.pop_mage_el_empowerment
				d.pop_conds = DR_DAMAGE
			end
		end

		queue_damage(store, d)

		if this.alter_reality_chance and math.random() < this.alter_reality_chance then
			local mod = E:create_entity(this.alter_reality_mod)

			mod.modifier.target_id = target.id

			queue_insert(store, mod)
		end
	elseif b.damage_radius and b.damage_radius > 0 then
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, b.damage_radius, b.vis_flags, b.vis_bans)

		if targets then
			for _, target in pairs(targets) do
				local d = SU.create_bullet_damage(b, target.id, this.id)

				queue_damage(store, d)
			end
		end
	end

	this.render.sprites[1].hidden = true
	this.render.sprites[2].hidden = true

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].runs = 0

		queue_insert(store, fx)
	end

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)

		decal.pos = V.vclone(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		queue_insert(store, decal)
	end

	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false

		U.y_wait(store, ps.particle_system.particle_lifetime[2])
	end

	queue_remove(store, this)
end

scripts.rock_druid = {}

function scripts.rock_druid.update(this, store)
	local b = this.bullet

	this.render.sprites[1].z = Z_OBJECTS

	S:queue(this.sound_events.load, {
		delay = fts(4)
	})
	U.y_animation_play(this, "load", nil, store.tick_ts)
	U.y_animation_play(this, "travel", nil, store.tick_ts)

	this.tween.disabled = false

	while not b.target_id do
		coroutine.yield()
	end

	local fx = E:create_entity("fx_rock_druid_launch")

	fx.pos.x, fx.pos.y = b.from.x, b.from.y
	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].flip_x = b.to.x < fx.pos.x

	queue_insert(store, fx)

	this.render.sprites[1].sort_y_offset = nil
	this.render.sprites[1].z = Z_BULLETS
	this.tween.disabled = true
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)
	b.rotation_speed = b.rotation_speed * (b.to.x > b.from.x and -1 or 1)

	scripts.bomb.update(this, store)
end

scripts.dagger_drow = {}

function scripts.dagger_drow.insert(this, store)
	this.bullet.flight_time = U.frandom(this.flight_time_range[1], this.flight_time_range[2])

	return scripts.arrow.insert(this, store)
end

scripts.bullet_liquid_fire_faustus = {}

function scripts.bullet_liquid_fire_faustus.update(this, store)
	local b = this.bullet
	local tl = store.tick_length
	local insert_ts = store.tick_ts
	local node
	local target = store.entities[b.target_id]
	local mspeed = V.dist(b.to.x, b.to.y, b.from.x, b.from.y) / b.flight_time

	if not target then
		queue_remove(store, this)

		return
	end

	local nodes = P:nearest_nodes(b.to.x, b.to.y, {
		target.nav_path.pi
	}, {
		target.nav_path.spi
	}, true)

	if #nodes > 0 then
		node = {
			pi = nodes[1][1],
			spi = nodes[1][2],
			ni = nodes[1][3]
		}
	end

	if not node then
		log.debug("cannot deploy bullet_liquid_fire_faustus: no destination node")
		queue_remove(store, this)

		return
	end

	local node_pos = P:node_pos(node)
	local dist = V.dist(node_pos.x, node_pos.y, b.from.x, b.from.y)
	local ps = E:create_entity(b.particles_name)

	ps.pos.x, ps.pos.y = b.from.x, b.from.y
	ps.particle_system.emit_direction = V.angleTo(node_pos.x - b.from.x, node_pos.y - b.from.y)
	ps.particle_system.emit_rotation = ps.particle_system.emit_direction
	ps.particle_system.emit_speed = {
		dist / fts(10),
		dist / fts(10)
	}

	queue_insert(store, ps)

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * tl do
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl

		coroutine.yield()
	end

	local fx = E:create_entity("fx_bullet_liquid_fire_faustus_hit")

	fx.pos.x, fx.pos.y = node_pos.x, node_pos.y
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	for i = 1, this.flames_count do
		local nn = {
			pi = node.pi,
			spi = km.zmod(node.spi + 2 * (i - 1), 3),
			ni = node.ni + (i - 1) * 2
		}

		if not P:is_node_valid(nn.pi, nn.ni) then
			break
		end

		local a = E:create_entity("aura_liquid_fire_flame_faustus")

		a.pos = P:node_pos(nn)
		a.pos.x = a.pos.x + math.random(-8, 8)
		a.aura.ts = store.tick_ts

		queue_insert(store, a)
		U.y_wait(store, 0.25)
	end

	queue_remove(store, this)
end

scripts.meteor_lilith = {}

function scripts.meteor_lilith.update(this, store)
	local b = this.bullet
	local speed = b.max_speed

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
		b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	local targets = U.find_enemies_in_range(store.entities, b.to, 0, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in pairs(targets) do
			local d = E:create_entity("damage")

			d.damage_type = b.damage_type
			d.value = b.damage_max
			d.source_id = this.id
			d.target_id = target.id

			queue_damage(store, d)
		end
	end

	S:queue(this.sound_events.hit)
	SU.insert_sprite(store, b.arrive_fx, b.to)
	SU.insert_sprite(store, b.arrive_decal, b.to)
	queue_remove(store, this)
end

scripts.decal_lilith_soul_eater_ball = {}

function scripts.decal_lilith_soul_eater_ball.update(this, store)
	local sp = this.render.sprites[1]
	local fm = this.force_motion
	local source = store.entities[this.source_id]
	local hero = store.entities[this.target_id]
	local initial_pos, initial_dest
	local initial_h = 0
	local dest_h = hero.unit.hit_offset.y
	local max_dist
	local last_pos = V.v(0, 0)

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)

		max_dist = math.max(dist, max_dist)

		local phase = km.clamp(0, 1, 1 - dist / max_dist)
		local df = (not fm.ramp_radius or dist > fm.ramp_radius) and 1 or math.max(dist / fm.ramp_radius, 0.1)

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step * df, dx, dy)))
		fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
		fm.v.x, fm.v.y = V.trim(fm.max_v, fm.v.x, fm.v.y)

		local sx, sy = V.mul(store.tick_length, fm.v.x, fm.v.y)

		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
		fm.a.x, fm.a.y = V.mul(-0.05 / store.tick_length, fm.v.x, fm.v.y)
		sp.offset.y = SU.parabola_y(phase, initial_h, dest_h, fm.max_flight_height)
		sp.r = V.angleTo(this.pos.x - last_pos.x, this.pos.y + sp.offset.y - last_pos.y)
		last_pos.x, last_pos.y = this.pos.x, this.pos.y + sp.offset.y

		return dist < 2 * fm.max_v * store.tick_length
	end

	if not source or not hero then
		log.debug("source or hero entity not found for decal_lilith_soul_eater_ball")
	else
		this.pos.x, this.pos.y = source.pos.x, source.pos.y

		if source.unit and source.unit.hit_offset then
			initial_h = source.unit.hit_offset.y
		end

		this.dest = hero.pos
		initial_pos = V.vclone(this.pos)
		initial_dest = V.vclone(hero.pos)
		initial_h = initial_h + 18
		fm.a.x, fm.a.y = 0, 3.5
		last_pos.x, last_pos.y = this.pos.x, this.pos.y + sp.offset.y
		max_dist = V.len(initial_dest.x - initial_pos.x, initial_dest.y - initial_pos.y)

		while not hero.health.dead and not move_step(this.dest) do
			coroutine.yield()
		end

		if not hero.health.dead then
			local ma = hero.melee.attacks[1]
			local hero_damage_avg = (ma.damage_min + ma.damage_max) / 2
			local m = E:create_entity(this.hit_mod)

			m.pos = hero.pos
			m.modifier.source_id = this.id
			m.modifier.target_id = hero.id
			m.inflicted_damage_factor = 1 + this.stolen_damage * m.soul_eater_factor / hero_damage_avg
			m.tween.ts = store.tick_ts

			queue_insert(store, m)

			local fx = E:create_entity(this.hit_fx)

			fx.pos = hero.pos
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].offset = hero.unit.mod_offset

			queue_insert(store, fx)
			SU.hero_gain_xp_from_skill(hero, hero.hero.skills.soul_eater)
		end
	end

	queue_remove(store, this)
end

scripts.missile_phoenix = {}

function scripts.missile_phoenix.insert(this, store, script)
	local b = this.bullet
	local flip = this.pos.x > b.to.x and -1 or 1
	local shot_index = b.shot_index or 0

	b.max_speed = U.frandom(b.max_speed - b.speed_var, b.max_speed + b.speed_var)
	b.min_speed = U.frandom(b.min_speed - b.speed_var, b.min_speed + b.speed_var)

	if shot_index > 0 then
		b.to = V.v(this.pos.x + 30 * flip + shot_index * 5, this.pos.y - 70 + shot_index * 5)
	end

	if shot_index > 1 then
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, b.first_retarget_range, b.vis_flags, b.vis_bans)

		if targets then
			local target = table.random(targets)

			b.target_id = target.id
		end
	end

	return scripts.missile.insert(this, store, script)
end

scripts.missile_wilbur = {}

function scripts.missile_wilbur.insert(this, store, script)
	local b = this.bullet

	b.to.x = this.pos.x
	b.to.y = this.pos.y + math.random(70, 110)

	if b.shot_index ~= 1 then
		local o_target = store.entities[b.target_id]
		local o = o_target and o_target.pos or this.pos
		local target, targets = U.find_foremost_enemy(store.entities, o, 0, b.first_retarget_range, false, b.vis_flags, b.vis_bans, function(e)
			return e.id ~= b.target_id
		end)

		if targets then
			local target = targets[b.shot_index - 1] or table.random(targets)

			b.target_id = target.id
		end
	end

	return scripts.missile.insert(this, store, script)
end

scripts.bullet_gnoll_blighter = {}

function scripts.bullet_gnoll_blighter.update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local target, an, af

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		if b.target_id then
			target = store.entities[b.target_id]
		end

		if target then
			if U.flag_has(target.vis.bans, F_RANGED) or target.health.dead then
				b.target_id = nil
				target = nil
			else
				b.to.x, b.to.y = target.pos.x, target.pos.y
			end
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		an, af = U.animation_name_facing_point(this, "travel", b.to)

		U.animation_start(this, an, af, store.tick_ts, true)
		coroutine.yield()
	end

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)
	end

	an, af = U.animation_name_facing_point(this, "hitUpDown", b.to)
	this.pos.x, this.pos.y = b.to.x, b.to.y - 1

	U.y_animation_play(this, an, af, store.tick_ts)
	queue_remove(store, this)
end

scripts.arrow_twilight_elf_harasser = {}

function scripts.arrow_twilight_elf_harasser.insert(this, store)
	this.bullet.flight_time = U.frandom(this.flight_time_range[1], this.flight_time_range[2])

	return scripts.arrow.insert(this, store)
end

scripts.bullet_arachnomancer_spawn = {}

function scripts.bullet_arachnomancer_spawn.insert(this, store)
	local b = this.bullet

	b.to = P:node_pos(this.nav_path)
	b.from = V.vclone(this.pos)

	local e = E:create_entity(this.payload_entity)

	e.render.sprites[1].name = "raise"
	e.nav_path = table.deepclone(this.nav_path)
	e.pos = V.vclone(b.to)
	e.enemy.gold = 0
	b.hit_payload = e

	if scripts.bomb.insert(this, store) then
		this.render.sprites[1].flip_x = b.to.x < b.from.x
		this.render.sprites[1].r = 0

		return true
	end

	return false
end

scripts.rock_perython = {}

function scripts.rock_perython.update(this, store)
	local b = this.bullet

	U.y_animation_play(this, "drop", nil, store.tick_ts)

	local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, b.damage_radius, b.vis_flags, b.vis_bans)

	if targets then
		for _, target in pairs(targets) do
			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = target.id
			d.value = math.random(b.damage_min, b.damage_max)
			d.damage_type = b.damage_type

			queue_damage(store, d)
		end
	end

	S:queue(this.sound_events.hit)

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)

		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)

		decal.pos = V.vclone(this.pos)
		decal.render.sprites[1].ts = store.tick_ts

		queue_insert(store, decal)
	end

	queue_remove(store, this)
end

scripts.aura_arcane_burst = {}

function scripts.aura_arcane_burst.update(this, store)
	local a = this.aura
	local source = store.entities[this.source_id]

	if source and source.bullet then
		a.level = source.bullet.level
	end

	local target = this.target_id and store.entities[this.target_id]
	local hit_pos = V.vclone(this.pos)

	if target then
		hit_pos.x, hit_pos.y = target.pos.x, target.pos.y
	end

	local targets = U.find_enemies_in_range(store.entities, hit_pos, 0, a.radius, a.vis_flags, a.vis_bans)

	if targets then
		for _, target in pairs(targets) do
			local d = E:create_entity("damage")

			d.damage_type = a.damage_type
			d.value = a.level * a.damage_inc
			d.target_id = target.id
			d.source_id = this.id

			queue_damage(store, d)
		end
	end

	if target and not target.health.dead and band(target.vis.flags, F_FLYING) == 0 then
		local decal = E:create_entity("decal_arcane_burst_ground")

		decal.pos.x, decal.pos.y = target.pos.x, target.pos.y
		decal.tween.ts = store.tick_ts

		queue_insert(store, decal)
	end

	U.y_animation_play(this, nil, nil, store.tick_ts, 1)
	queue_remove(store, this)
end

scripts.aura_forest_eerie = {}

function scripts.aura_forest_eerie.insert(this, store)
	local function insert_root(pos, duration)
		local fx = E:create_entity("decal_eerie_root_" .. math.random(1, 2))

		fx.render.sprites[1].flip_x = math.random() < 0.5
		fx.delay = U.frandom(0, 0.3)
		fx.pos = pos
		fx.duration = duration

		queue_insert(store, fx)
	end

	this.aura.ts = store.tick_ts
	this.actual_duration = this.aura.duration + this.aura.level * this.aura.duration_inc

	local roots_count = this.roots_count + this.aura.level * this.roots_count_inc
	local root_rows = math.floor(roots_count / 3)
	local ni_inc = 2
	local pi = this.pos_pi
	local ni = this.pos_ni + math.floor((ni_inc + 2.5) * root_rows / 2)

	for i = 1, roots_count do
		local spi = km.zmod(i, 3)

		if P:is_node_valid(pi, ni) then
			local pos = P:node_pos(pi, spi, ni)

			pos.x, pos.y = pos.x + math.random(0, 8), pos.y + math.random(0, 8)

			insert_root(pos, this.actual_duration)
		end

		if i % 3 == 0 then
			ni = ni - ni_inc - math.random(2, 3)
		end
	end

	return true
end

scripts.aura_lilith_soul_eater = {}

function scripts.aura_lilith_soul_eater.update(this, store)
	local a = this.aura
	local hero = store.entities[a.source_id]
	local last_ts = store.tick_ts

	if not hero then
		log.error("hero not found for aura_lilith_soul_eater")
		queue_remove(store, this)

		return
	end

	while true do
		hero.soul_eater.active = store.tick_ts - hero.soul_eater.last_ts >= a.cooldown

		if not hero.health.dead and hero.soul_eater.active and store.tick_ts - last_ts >= a.cycle_time then
			last_ts = store.tick_ts

			local targets = U.find_enemies_in_range(store.entities, hero.pos, 0, a.radius, a.vis_flags, a.vis_bans, function(e)
				return not table.contains(a.excluded_templates, e.template_name)
			end)

			if targets then
				for _, target in pairs(targets) do
					local m = E:create_entity(a.mod)

					m.modifier.source_id = hero.id
					m.modifier.target_id = target.id

					queue_insert(store, m)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.aura_bruce_hps = {}

function scripts.aura_bruce_hps.update(this, store)
	local owner = store.entities[this.aura.source_id]
	local hps = this.hps

	while true do
		if store.tick_ts - hps.ts > hps.heal_every then
			hps.ts = store.tick_ts
			owner.health.hp = km.clamp(0, owner.health.hp_max, owner.health.hp + hps.heal_max)
		end

		coroutine.yield()
	end
end

scripts.aura_ray_phoenix = {}

function scripts.aura_ray_phoenix.insert(this, store)
	local bullet = store.entities[this.aura.source_id]

	this.aura.xp_dest_id = bullet and bullet.bullet.source_id or nil

	return true
end

scripts.aura_phoenix_egg = {}

function scripts.aura_phoenix_egg.update(this, store)
	local ca = this.custom_attack
	local a = this.aura

	a.ts = store.tick_ts

	local last_hit_ts = store.tick_ts

	U.y_wait(store, this.show_delay)
	U.sprites_show(this)
	U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
	U.animation_start(this, "idle", nil, store.tick_ts, true)

	while true do
		if store.tick_ts - a.ts > a.duration then
			break
		end

		if store.tick_ts - last_hit_ts >= a.cycle_time then
			last_hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, t in pairs(targets) do
					local m = E:create_entity(a.mod)

					m.modifier.target_id = t.id
					m.modifier.source_id = this.id

					queue_insert(store, m)
				end
			end
		end

		coroutine.yield()
	end

	SU.insert_sprite(store, ca.hit_fx, this.pos)

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, ca.radius, ca.vis_flags, ca.vis_bans)

	if targets then
		for _, t in pairs(targets) do
			local d = E:create_entity("damage")

			d.value = math.random(ca.damage_min, ca.damage_max)
			d.damage_type = ca.damage_type
			d.target_id = t.id
			d.source_id = this.id

			queue_damage(store, d)
		end
	end

	queue_remove(store, this)
end

scripts.aura_gnoll_gnawer = {}

function scripts.aura_gnoll_gnawer.update(this, store)
	local a = this.aura
	local last_hit_ts = 0
	local te = store.entities[a.source_id]

	if not te then
		-- block empty
	else
		this.pos = te.pos

		while true do
			te = store.entities[a.source_id]

			if not te or te.health and te.health.dead and not a.track_dead then
				break
			end

			if store.tick_ts - last_hit_ts >= a.cycle_time then
				last_hit_ts = store.tick_ts

				local friends = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

				if friends and #friends >= this.min_count then
					local m = E:create_entity(this.aura.mod)

					m.modifier.target_id = te.id
					m.modifier.source_id = this.id

					queue_insert(store, m)
				end
			end

			coroutine.yield()
		end
	end

	queue_remove(store, this)
end

scripts.aura_bandersnatch_spines = {}

function scripts.aura_bandersnatch_spines.update(this, store)
	local a = this.aura

	for i = 1, this.spines_count do
		local r = math.random(45, 55) + (math.random() < 0.75 and math.random(-6, 15) or 0)
		local angle = U.frandom(0, 2) * math.pi
		local fx = E:create_entity("fx_bandersnatch_spine")

		fx.pos = U.point_on_ellipse(this.pos, r, angle)
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].flip_x = math.random() < 0.5

		queue_insert(store, fx)
	end

	local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

	if targets then
		for _, target in pairs(targets) do
			local d = E:create_entity("damage")

			d.damage_type = a.damage_type
			d.value = math.ceil(U.frandom(a.damage_min, a.damage_max))
			d.target_id = target.id
			d.source_id = this.id

			queue_damage(store, d)

			local fx = E:create_entity(a.hit_fx)

			fx.pos.x, fx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)
		end
	end
end

scripts.aura_razorboar_rage = {}

function scripts.aura_razorboar_rage.insert(this, store)
	local source = store.entities[this.aura.source_id]

	if not source then
		return false
	end

	local ma = source.melee.attacks[1]

	this._ini_damage_max = ma.damage_max
	this._ini_damage_min = ma.damage_min

	return true
end

function scripts.aura_razorboar_rage.remove(this, store)
	local source = store.entities[this.aura.source_id]

	if source then
		local ma = source.melee.attacks[1]

		ma.damage_max = this._ini_damage_max
		ma.damage_min = this._ini_damage_min
	end

	return true
end

function scripts.aura_razorboar_rage.update(this, store)
	local a = this.aura
	local te = store.entities[a.source_id]

	if not te then
		queue_remove(store, this)
	end

	local ma = te.melee.attacks[1]
	local ini_damage_max = ma.damage_max
	local ini_damage_min = ma.damage_min

	this.pos = te.pos

	while true do
		te = store.entities[a.source_id]

		if not te or te.health and te.health.dead and not a.track_dead then
			break
		end

		local h = te.health
		local hp_lost_factor = (h.hp_max - h.hp) / h.hp_max * this.damage_hp_factor

		ma.damage_min = math.floor(ini_damage_min * (1 + hp_lost_factor))
		ma.damage_max = math.floor(ini_damage_max * (1 + hp_lost_factor))

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.editor_aura_spider_sprint = {}

function scripts.editor_aura_spider_sprint.update(this, store)
	while true do
		this.render.sprites[1].scale = V.vv(this.aura.radius / 50)

		coroutine.yield()
	end
end

scripts.aura_mactans_path_web = {}

function scripts.aura_mactans_path_web.update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local remaining_time = this.aura.duration
	local used_eggs = {}

	local function insert_webs(off_idx)
		local npos = {
			P:node_pos(this.pi, 1, this.ni + off_idx * this.step_nodes),
			P:node_pos(this.pi, 2, this.ni + off_idx * this.step_nodes),
			P:node_pos(this.pi, 3, this.ni + off_idx * this.step_nodes)
		}
		local rot = -V.angleTo(npos[2].x - npos[1].x, npos[2].y - npos[1].y)

		for spi = 1, 3 do
			local pos = npos[spi]

			if spi == 1 and off_idx <= this.steps_count_auras then
				local e = E:create_entity("aura_spider_sprint")

				e.aura.duration = remaining_time
				e.aura.radius = a.radius
				e.pos.x, e.pos.y = pos.x, pos.y

				queue_insert(store, e)

				local targets = U.find_soldiers_in_range(store.entities, pos, 0, a.radius, a.vis_flags, a.vis_bans)

				if targets then
					for _, target in pairs(targets) do
						local m = E:create_entity("mod_mactans_spider_web")

						m.pos.x, m.pos.y = target.pos.x, target.pos.y
						m.modifier.source_id = this.id
						m.modifier.target_id = target.id

						queue_insert(store, m)
					end
				end

				local sel_eggs = table.filter(this.eggs, function(_, e)
					return not table.contains(used_eggs, e) and V.dist(e.pos.x, e.pos.y, pos.x, pos.y) < a.radius
				end)

				for _, egg in pairs(sel_eggs) do
					log.debug("----- EGG:%s", getfulldump(egg))
					table.insert(used_eggs, egg)

					local e = E:create_entity("spider_arachnomancer_egg_spawner")

					e.pos.x, e.pos.y = egg.pos.x, egg.pos.y
					e.spawn_once = true
					e.spawner.spawn_data = {}
					e.spawner.count = this.qty_per_egg
					e.spawner.pi = egg.node_pi
					e.spawner.spi = egg.node_spi
					e.spawner.ni = egg.node_ni

					queue_insert(store, e)
				end
			end

			local d = E:create_entity("decal_mactans_path_web_" .. math.random(1, 3))

			d.pos.x, d.pos.y = pos.x + math.random(-15, 15), pos.y + math.random(-15, 15)
			d.tween.ts = store.tick_ts + U.frandom(0, this.step_delay * 0.6)
			d.duration = remaining_time
			d.fade_duration = this.fade_duration + U.frandom(fts(5), fts(15))

			local scale_factor = U.frandom(0.8, 1.3)

			d.render.sprites[1].scale = V.v(U.random_sign() * scale_factor, U.random_sign() * scale_factor)

			queue_insert(store, d)
		end
	end

	for i = 0, this.steps_count do
		remaining_time = this.aura.duration - (store.tick_ts - a.ts)

		insert_webs(i)

		if i > 0 then
			insert_webs(-i)
		end

		U.y_wait(store, this.step_delay)

		if this.interrupt then
			break
		end
	end

	U.y_wait(store, remaining_time)
	queue_remove(store, this)
end

scripts.mod_blood_elves = {}

function scripts.mod_blood_elves.insert(this, store)
	if math.random() >= this.chance or not scripts.mod_dps.insert(this, store) then
		return false
	end

	local target = store.entities[this.modifier.target_id]

	if not target then
		log.debug("mod_blood_elves:%s cannot find target with id:%s", this.id, this.modifier.target_id)

		return false
	end

	local _, modifiers = U.has_modifier_types(store, target, this.modifier.type)

	if #modifiers >= this.modifier.max_of_same then
		log.debug("%s: cannot add to id %s because exceeds maximum", this.template_name, this.modifier.target_id)

		return false
	end

	for _, m in pairs(modifiers) do
		if m.dps then
			m.dps.fx = nil
		end
	end

	local source_damage = this.modifier.source_damage

	if not source_damage then
		if DEBUG then
			log.debug("mod_blood_elves: no modifier.source_damage. Using debug value")

			local d = E:create_entity("damage")

			d.value = 50
			d.target_id = target.id
			d.source_id = this.id
			source_damage = d
		else
			log.error("mod_blood_elves: cannot create without modifier.source_damage", this.id)

			return false
		end
	end

	local pred_damage = U.predict_damage(target, source_damage)
	local actual_damage = math.ceil(this.damage_factor * pred_damage)

	this.dps.damage_min = actual_damage
	this.dps.damage_max = actual_damage

	log.debug("mod_blood_elves:%s source_damage:%s actual_damage:%s", this.id, source_damage.value, actual_damage)

	return true
end

scripts.mod_timelapse = {}

function scripts.mod_timelapse.queue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		log.debug("%s (%s) queue/insertion", this.template_name, this.id)

		if U.flags_pass(target.vis, this.modifier) then
			this._target_prev_bans = target.vis.bans
			target.vis.bans = F_ALL
			target.health.ignore_damage = true
		end
	else
		log.debug("%s (%s) queue/removal", this.template_name, this.id)

		if this._target_prev_bans then
			target.vis.bans = this._target_prev_bans
			target.health.ignore_damage = false
		end

		if this._decal_timelapse then
			queue_remove(store, this._decal_timelapse)

			if target.ui then
				target.ui.can_click = true
			end

			if target.health_bar then
				target.health_bar.hidden = nil
			end

			U.sprites_show(target, nil, nil, true)
			SU.show_modifiers(store, target, true, this)
			SU.show_auras(store, target, true)
		end
	end
end

function scripts.mod_timelapse.dequeue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		log.debug("%s (%s) dequeue/insertion", this.template_name, this.id)

		if this._target_prev_bans then
			target.vis.bans = this._target_prev_bans
			target.health.ignore_damage = false
		end
	end
end

function scripts.mod_timelapse.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if target and target.health and not target.health.dead and this._target_prev_bans ~= nil then
		SU.stun_inc(target)

		return true
	else
		return false
	end
end

function scripts.mod_timelapse.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		SU.stun_dec(target)
	end

	return true
end

function scripts.mod_timelapse.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		queue_remove(store, this)

		return
	end

	m.ts = store.tick_ts
	this.pos.x, this.pos.y = target.pos.x, target.pos.y
	this.render.sprites[1].offset.y = target.unit.hit_offset.y

	local es = E:create_entity("timelapse_enemy_decal")

	this._decal_timelapse = es
	es.pos.x, es.pos.y = target.pos.x, target.pos.y
	es.render.sprites[1] = table.deepclone(target.render.sprites[1])
	es.render.sprites[1].name = "idle"

	local tween_keys = es.tween.props[1].keys

	for i, s in ipairs(es.render.sprites) do
		es.tween.props[i] = E:clone_c("tween_prop")
		es.tween.props[i].keys = tween_keys
		es.tween.props[i].sprite_id = i
	end

	queue_insert(store, es)
	U.unblock_all(store, target)

	if target.ui then
		target.ui.can_click = false
	end

	if target.health_bar then
		target.health_bar.hidden = true
	end

	U.sprites_hide(target, nil, nil, true)
	SU.hide_modifiers(store, target, true, this)
	SU.hide_auras(store, target, true)
	U.animation_start(this, "start", nil, store.tick_ts, false, 1)

	this.tween.ts = store.tick_ts

	U.y_wait(store, fts(10))

	es.tween.ts = store.tick_ts
	es.tween.disabled = false

	U.y_animation_wait(this)
	U.animation_start(this, "loop", nil, store.tick_ts, true, 1)

	local a1 = this.ranged.attacks[1]
	a1.ts = store.tick_ts - a1.cooldown
	while m.duration >= (store.tick_ts - m.ts) + fts(10) and not this.interrupt do
		if not a1.disabled and store.tick_ts - a1.ts >= a1.cooldown then
			local target = U.find_random_enemy(store.entities, this.pos, a1.min_range, a1.max_range, a1.vis_flags, a1.vis_bans)
			if target then
				local b = E:create_entity(a1.bullet)
				b.pos.x, b.pos.y = this.pos.x + a1.bullet_start_offset.x, this.pos.y + a1.bullet_start_offset.y
				b.bullet.from = V.vclone(b.pos)
				b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id
				queue_insert(store, b)
				a1.ts = store.tick_ts
			else
				SU.delay_attack(store, a1, fts(1))
			end
		end
		coroutine.yield()
	end
	
	S:queue("TowerHighMageTimeCastEnd")
	U.animation_start(this, "end", nil, store.tick_ts, false, 1)

	this.tween.ts = store.tick_ts
	this.tween.reverse = true

	U.y_wait(store, fts(5))

	es.tween.reverse = true
	es.tween.ts = store.tick_ts

	U.y_animation_wait(this)
	queue_remove(store, es)

	this._decal_timelapse = nil

	if target.ui then
		target.ui.can_click = true
	end

	if target.health_bar then
		target.health_bar.hidden = nil
	end

	U.sprites_show(target, nil, nil, true)
	SU.show_modifiers(store, target, true, this)
	SU.show_auras(store, target, true)
	queue_remove(store, this)

	if this.interrupt then
		target.health.hp = 0

		if target.death_spawns then
			target.health.last_damage_types = DAMAGE_NO_SPAWNS
		end
	else
		local d = E:create_entity("damage")

		d.damage_type = this.damage_type
		d.value = this.damage_levels[m.level]
		d.source_id = this.id
		d.target_id = target.id

		queue_damage(store, d)
	end

	signal.emit("mod-applied", this, target)
end

scripts.mod_arrow_arcane_slumber = {}

function scripts.mod_arrow_arcane_slumber.insert(this, store)
	if scripts.mod_stun.insert(this, store) then
		local e = E:create_entity("mod_arrow_arcane")

		e.modifier.target_id = this.modifier.target_id

		queue_insert(store, e)

		this.render.sprites[2].flip_x = false

		log.debug("          pATCHING FLIP: %s", this.render.sprites[2].flip_x)

		return true
	end

	return false
end

scripts.mod_arrow_silver_mark = {}

function scripts.mod_arrow_silver_mark.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.unit then
		return false
	end

	target.health.damage_factor = target.health.damage_factor * this.received_damage_factor

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_arrow_silver_mark.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.pos then
		queue_remove(store, this)

		return
	end

	this.pos = target.pos
	m.duration = m.durations[m.level]
	m.ts = store.tick_ts

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or store.tick_ts - m.ts > m.duration then
			this.tween.props[3].disabled = nil
			this.tween.props[4].disabled = nil
			this.tween.props[3].ts = store.tick_ts
			this.tween.props[4].ts = store.tick_ts

			U.y_wait(store, this.tween.props[3].keys[2][1])
			queue_remove(store, this)

			return
		end

		coroutine.yield()
	end
end

function scripts.mod_arrow_silver_mark.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target and target.health and target.unit then
		target.health.damage_factor = target.health.damage_factor / this.received_damage_factor
	end

	return true
end

scripts.mod_eldritch = {}

function scripts.mod_eldritch.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead or not U.flags_pass(target.vis, this.modifier) then
		queue_remove(store, this)

		return
	end

	local es = E:create_entity("eldritch_enemy_decal")

	es.pos.x, es.pos.y = target.pos.x, target.pos.y
	es.render.sprites[1] = table.deepclone(target.render.sprites[1])
	es.render.sprites[1].name = "idle"

	queue_insert(store, es)

	local show_blood_pool = target.unit.show_blood_pool
	local d = E:create_entity("damage")

	d.damage_type = DAMAGE_EAT
	d.source_id = this.id
	d.target_id = target.id

	queue_damage(store, d)

	local s = this.render.sprites[1]

	s.ts = store.tick_ts
	this.pos = V.vclone(target.pos)
	s.offset.x = target.unit.mod_offset.x
	s.offset.y = target.unit.mod_offset.y

	S:queue(this.sound_events.loop)

	es.tween.disabled = nil
	es.tween.ts = store.tick_ts

	U.y_wait(store, es.tween.props[1].keys[#es.tween.props[1].keys][1])
	S:stop(this.sound_events.loop)

	local fx = E:create_entity("fx_eldritch_explosion")

	fx.pos.x, fx.pos.y = target.pos.x + target.unit.mod_offset.x, target.pos.y + target.unit.mod_offset.y
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	local terrain_type = band(GR:cell_type(target.pos.x, target.pos.y), TERRAIN_TYPES_MASK)

	if target.unit and target.unit.can_explode and target.unit.explode_fx and band(terrain_type, TERRAIN_WATER) == 0 then
		S:queue(target.sound_events.death_by_explosion)

		local fx = E:create_entity(target.unit.explode_fx)

		fx.pos = V.vclone(target.pos)
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]

		queue_insert(store, fx)
	end

	if target.unit and show_blood_pool and target.unit.blood_color ~= BLOOD_NONE and band(terrain_type, TERRAIN_WATER) == 0 then
		local decal = E:create_entity("decal_blood_pool")

		decal.pos = V.vclone(target.pos)
		decal.render.sprites[1].ts = store.tick_ts
		decal.render.sprites[1].name = target.unit.blood_color
		decal.render.sprites[1].z = target.render.sprites[1].z
		decal.render.sprites[1].sort_y_offset = 1

		queue_insert(store, decal)
	end

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.damage_radius, this.damage_flags, this.damage_bans)

	if targets then
		for _, t in pairs(targets) do
			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = t.id
			d.value = this.damage_levels[m.level]
			d.damage_type = this.damage_type

			queue_damage(store, d)
		end
	end

	signal.emit("mod-applied", this, target)
	queue_remove(store, this)
end

scripts.mod_druid_sylvan = {}

function scripts.mod_druid_sylvan.update(this, store)
	local m = this.modifier
	local a = this.attack
	local s = this.render.sprites[2]
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		queue_remove(store, this)

		return
	end

	if s.size_names then
		s.name = s.size_names[target.unit.size]
	end

	local last_hp = target.health.hp
	local ray_ts = store.tick_ts - this.ray_cooldown

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or store.tick_ts - m.ts > m.duration or m.level <= 0 then
			queue_remove(store, this)

			return
		end

		if target and target.unit and target.unit.mod_offset then
			s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		if store.tick_ts - ray_ts >= this.ray_cooldown then
			local dhp = target.health.hp - last_hp

			if dhp < 0 then
				last_hp = target.health.hp

				local targets = U.find_enemies_in_range(store.entities, target.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

				if targets and #targets > 1 then
					for _, t in ipairs(targets) do
						if t ~= target then
							local b = E:create_entity(a.bullet)
							b.bullet.damage_max = -1 * dhp * a.damage_factor[m.level]
							b.bullet.damage_min = b.bullet.damage_max
							b.bullet.target_id = t.id
							b.bullet.source_id = this.id
							b.bullet.from = V.v(target.pos.x + target.unit.mod_offset.x,
								target.pos.y + target.unit.mod_offset.y)
							b.bullet.to = V.v(t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y)
							b.pos = V.vclone(b.bullet.from)

							queue_insert(store, b)
						end
					end
					ray_ts = store.tick_ts
				end
			end
		end

		coroutine.yield()
	end
end

scripts.mod_pixie_pickpocket = {}

function scripts.mod_pixie_pickpocket.insert(this, store)
	local m, pp = this.modifier, this.pickpocket
	local target = store.entities[m.target_id]

	if not target or not target.enemy or target.enemy.gold_bag <= 0 then
		return false
	end

	local q = km.clamp(0, target.enemy.gold_bag, math.random(pp.steal_min[m.level], pp.steal_max[m.level]))

	if q > 0 then
		target.enemy.gold_bag = target.enemy.gold_bag - q
		store.player_gold = store.player_gold + q
	end

	local pop = SU.create_pop(store, target.pos, pp.pop)

	queue_insert(store, pop)

	local fx = E:create_entity(pp.fx)

	fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)
	queue_remove(store, this)

	return true
end

scripts.mod_bravebark_branchball = {}

function scripts.mod_bravebark_branchball.queue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		target.vis.bans = F_ALL

		SU.stun_inc(target)
	end
end

function scripts.mod_bravebark_branchball.update(this, store)
	local target = store.entities[this.modifier.target_id]
	local source = store.entities[this.modifier.source_id]

	if not target or not source then
		queue_remove(store, this)

		return
	end

	local af = source.pos.x > target.pos.x

	this.pos.x, this.pos.y = target.pos.x, target.pos.y

	U.y_wait(store, fts(7))
	S:queue("ElvesHeroForestElementalHomerun")
	U.y_wait(store, fts(10))

	this.render.sprites[1].hidden = false
	this.render.sprites[1].ts = store.tick_ts

	local decal = E:create_entity("decal_bravebark_rootspikes_hit")

	decal.pos.x, decal.pos.y = this.pos.x, this.pos.y
	decal.tween.ts = store.tick_ts

	queue_insert(store, decal)
	U.y_wait(store, fts(16))

	local fx = E:create_entity("fx_bravebark_branchball_hit")

	fx.pos.x, fx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	local d = E:create_entity("damage")

	d.damage_type = DAMAGE_EAT
	d.source_id = this.id
	d.target_id = target.id

	queue_damage(store, d)

	local es = E:create_entity("decal_bravebark_branchball_enemy_clone")

	es.pos.x, es.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
	es.render = table.deepclone(target.render)
	es.render.sprites[1].anchor = this.custom_anchors[target.template_name] or this.custom_anchors.default
	es.tween.disabled = nil
	es.tween.ts = store.tick_ts

	local dx, dy = V.rotate(math.random(20, 45) * math.pi / 180, math.random(240, 300), 0)

	dx = (af and -1 or 1) * dx
	es.tween.props[2].keys[2][2].x, es.tween.props[2].keys[2][2].y = dx, dy
	es.tween.props[3].keys[2][2] = (af and -1 or 1) * math.random(300, 400) * math.pi / 180

	queue_insert(store, es)
	U.y_animation_wait(this)
	queue_remove(store, this)
end

scripts.mod_bravebark_springsap = {}

function scripts.mod_bravebark_springsap.insert(this, store)
	if not scripts.mod_hps.insert(this, store) then
		return false
	end

	local target = store.entities[this.modifier.target_id]

	if target.template_name == "hero_bravebark" then
		this.render.sprites[1].hidden = true
	else
		this.render.sprites[1].ts = store.tick_ts
	end

	return true
end

scripts.mod_catha_curse = {}

function scripts.mod_catha_curse.insert(this, store)
	if math.random() < this.chance and scripts.mod_stun.insert(this, store) then
		if this.xp_from_skill then
			local ref = store.entities[this.modifier.source_id]

			if ref and ref.bullet then
				ref = store.entities[ref.bullet.source_id]
			end

			if ref and ref.hero then
				SU.hero_gain_xp_from_skill(ref, ref.hero.skills[this.xp_from_skill])
			else
				log.error("mod_catha_curse: could not find source hero for %s", this.id)
			end
		end

		return true
	else
		return false
	end
end

scripts.mod_rag_raggified = {}

function scripts.mod_rag_raggified.update(this, store)
	local function add_fx(target, pos)
		local fx = E:create_entity(this.fx)
		local s = fx.render.sprites[1]

		s.ts = store.tick_ts

		if s.size_scales then
			s.scale = s.size_scales[target.unit.size]
		end

		fx.pos = V.vclone(pos)

		if target.unit.hit_offset then
			fx.pos.x, fx.pos.y = fx.pos.x + target.unit.hit_offset.x, fx.pos.y + target.unit.hit_offset.y
		end

		queue_insert(store, fx)
	end

	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or target.health.dead or band(target.vis.bans, F_RAGGIFY) ~= 0 then
		queue_remove(store, this)

		return
	end

	target.vis.bans = U.flag_set(target.vis.bans, F_RAGGIFY)

	add_fx(target, target.pos)
	SU.remove_modifiers(store, target, nil, "mod_rag_raggified")
	SU.remove_auras(store, target)
	queue_remove(store, target)

	target.health.dead = true
	target.main_script.co = nil
	target.main_script.runs = 0

	U.unblock_all(store, target)

	if target.ui then
		target.ui.can_click = false
	end

	if target.count_group then
		target.count_group.in_limbo = true
	end

	local e = E:create_entity(this.entity_name)

	e.pos = V.vclone(target.pos)
	e.health.hp_max = target.health.hp
	e.health.hp = target.health.hp
	e.nav_rally.center = V.vclone(target.pos)
	e.nav_rally.pos = V.vclone(target.pos)
	e.reinforcement.duration = this.doll_duration
	e.render.sprites[1].flip_x = target.render.sprites[1].flip_x
	e.render.sprites[1].scale = target.unit.size == UNIT_SIZE_SMALL and V.vv(0.75) or V.vv(1)

	queue_insert(store, e)

	local start_ts = store.tick_ts

	while not e.health.dead do
		coroutine.yield()
	end

	if e.reinforcement.hp_before_timeout then
		local nodes = P:nearest_nodes(e.pos.x, e.pos.y, {
			target.nav_path.pi
		}, nil)

		if #nodes > 0 then
			target.nav_path.ni = nodes[1][3] + 1
		end

		target.pos = V.vclone(e.pos)
		target.main_script.runs = 1
		target.health.dead = false
		target.health.hp = e.reinforcement.hp_before_timeout

		if target.ui then
			target.ui.can_click = true
		end

		if target.count_group then
			target.count_group.in_limbo = nil
		end

		target.vis.bans = U.flag_clear(target.vis.bans, F_RAGGIFY)

		queue_insert(store, target)
	else
		store.player_gold = store.player_gold + target.enemy.gold

		signal.emit("got-enemy-gold", target, target.enemy.gold)
	end

	add_fx(target, e.pos)
	queue_remove(store, this)
end

scripts.mod_lilith_soul_eater_track = {}

function scripts.mod_lilith_soul_eater_track.update(this, store)
	local hero = store.entities[this.modifier.source_id]

	if not hero then
		log.error("hero not found for mod_lilith_soul_eater")
	else
		this.modifier.ts = store.tick_ts

		while true do
			local target = store.entities[this.modifier.target_id]

			if not target or store.tick_ts - this.modifier.ts > this.modifier.duration then
				break
			end

			if target.health.dead and hero.soul_eater.active and target.melee and target.melee.attacks and not U.flag_has(target.health.last_damage_types, DAMAGE_NO_LIFESTEAL) then
				local ma = target.melee.attacks[1]
				local stolen_damage = (ma.damage_min + ma.damage_max) / 2
				local s = E:create_entity("decal_lilith_soul_eater_ball")

				s.target_id = hero.id
				s.source_id = target.id
				s.stolen_damage = stolen_damage

				queue_insert(store, s)

				hero.soul_eater.last_ts = store.tick_ts

				break
			end

			coroutine.yield()
		end
	end

	queue_remove(store, this)
end

scripts.mod_bruce_sharp_claws = {}

function scripts.mod_bruce_sharp_claws.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		log.debug("mod_bruce_sharp_claws:%s cannot find target with id:%s", this.id, this.modifier.target_id)

		return false
	end

	local has_mods, mods = U.has_modifier_types(store, target, this.modifier.type)

	if has_mods then
		local d = E:create_entity("damage")

		d.value = this.extra_bleeding_damage
		d.target_id = target.id
		d.source_id = this.id

		queue_damage(store, d)

		return false
	else
		if not scripts.mod_dps.insert(this, store) then
			return false
		end

		local ref = store.entities[this.modifier.source_id]

		if ref then
			SU.hero_gain_xp_from_skill(ref, ref.hero.skills[this.xp_from_skill])
		end

		return true
	end
end

scripts.mod_lynn_ultimate = {}

function scripts.mod_lynn_ultimate.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	if not U.flags_pass(target.vis, this.modifier) then
		return false
	end

	this.dps.ts = store.tick_ts - this.dps.damage_every
	this.modifier.ts = store.tick_ts
	this.tween.ts = store.tick_ts
	this.pos = target.pos

	local mods = U.get_modifiers(store, target, {
		"mod_lynn_despair",
		"mod_lynn_weakening",
		"mod_lynn_ultimate"
	})

	for _, m in pairs(mods) do
		if m ~= this then
			U.sprites_hide(m, nil, nil, true)
		end
	end

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_lynn_ultimate.update(this, store, script)
	local target
	local m = this.modifier
	local dps = this.dps
	local s_top, s_over = this.render.sprites[1], this.render.sprites[3]

	while store.tick_ts - m.ts < m.duration do
		target = store.entities[m.target_id]

		if not target then
			break
		end

		if target.health.dead then
			local p

			if U.flag_has(target.vis.flags, F_FLYING) then
				p = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
			else
				p = V.v(target.pos.x, target.pos.y)
			end

			SU.insert_sprite(store, this.explode_fx, p)

			local targets = U.find_enemies_in_range(store.entities, target.pos, 0, this.explode_range, this.explode_vis_flags, this.explode_vis_bans)

			if targets then
				for _, t in pairs(targets) do
					local d = E:create_entity("damage")

					d.damage_type = this.explode_damage_type
					d.value = this.explode_damage
					d.target_id = t.id
					d.source_id = this.id

					queue_damage(store, d)
				end
			end

			break
		end

		s_top.offset.x = target.health_bar.offset.x + m.health_bar_offset.x
		s_top.offset.y = target.health_bar.offset.y + m.health_bar_offset.y
		s_over.offset.x = target.unit.mod_offset.x
		s_over.offset.y = target.unit.mod_offset.y

		if dps.damage_every and store.tick_ts - dps.ts >= dps.damage_every then
			dps.ts = dps.ts + dps.damage_every

			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = target.id
			d.value = dps.damage_max
			d.damage_type = dps.damage_type

			queue_damage(store, d)
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.mod_lynn_weakening = {}

function scripts.mod_lynn_weakening.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or target.enemy and not target.enemy.can_accept_magic then
		return false
	end

	SU.armor_dec(target, this.magic_armor_reduction)
	SU.magic_armor_dec(target, this.armor_reduction)

	local mods = U.get_modifiers(store, target, {
		"mod_lynn_despair",
		"mod_lynn_ultimate"
	})

	for _, m in pairs(mods) do
		if m ~= this then
			U.sprites_hide(m, nil, nil, true)
		end
	end

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_lynn_weakening.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target then
		SU.armor_inc(target, this.magic_armor_reduction)
		SU.magic_armor_inc(target, this.armor_reduction)
	end

	return true
end

scripts.mod_lynn_despair = {}

function scripts.mod_lynn_despair.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.unit or not target.motion then
		return false
	end

	target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor

	if not target.motion.invulnerable then
		target.motion.max_speed = target.motion.max_speed * this.speed_factor
	end

	this.modifier.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts

	local mods = U.get_modifiers(store, target, {
		"mod_lynn_ultimate",
		"mod_lynn_weakening"
	})

	for _, m in pairs(mods) do
		if m ~= this then
			U.sprites_hide(m, nil, nil, true)
		end
	end

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_lynn_despair.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target and target.health and target.unit and target.motion then
		target.unit.damage_factor = target.unit.damage_factor / this.inflicted_damage_factor

		if not target.motion.invulnerable then
			target.motion.max_speed = target.motion.max_speed / this.speed_factor
		end
	end

	return true
end

scripts.mod_lynn_curse = {}

function scripts.mod_lynn_curse.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or math.random() >= this.modifier.chance or not U.flags_pass(target.vis, this.modifier) then
		log.debug("mod_lynn_curse chance miss")

		return false
	end

	log.debug("mod_lynn_curse chance hit")

	return true
end

function scripts.mod_lynn_curse.update(this, store)
	this.modifier.ts = store.tick_ts

	local target

	repeat
		coroutine.yield()

		target = store.entities[this.modifier.target_id]
	until store.tick_ts - this.modifier.ts >= this.modifier.duration or not target or target.health.dead

	queue_remove(store, this)
end

scripts.mod_phoenix_flaming_path = {}

function scripts.mod_phoenix_flaming_path.update(this, store, script)
	local m = this.modifier
	local ca = this.custom_attack
	local target = store.entities[m.target_id]
	local ending, fx_pos

	if not target or not target.tower then
		-- block empty
	else
		m.ts = store.tick_ts
		ca.ts = store.tick_ts
		fx_pos = V.vclone(target.pos)

		if this.custom_offsets and this.custom_offsets[target.template_name] then
			local o = this.custom_offsets[target.template_name]

			for _, s in pairs(this.render.sprites) do
				s.offset.x = s.offset.x + o.x
				s.offset.y = s.offset.y + o.y
			end

			fx_pos.x, fx_pos.y = fx_pos.x + o.x, fx_pos.y + o.y
		end

		SU.insert_sprite(store, ca.fx_start, fx_pos)

		while true do
			target = store.entities[m.target_id]

			if not target or store.tick_ts - m.ts > m.duration then
				break
			end

			if target and not ending and store.tick_ts - m.ts >= m.duration - 0.3 then
				ending = true

				SU.insert_sprite(store, ca.fx_end, fx_pos)
			end

			if store.tick_ts - ca.ts > ca.cooldown then
				ca.ts = store.tick_ts

				S:queue(sound)
				SU.insert_sprite(store, ca.fx, fx_pos)
				U.y_wait(store, ca.hit_time)

				local targets = U.find_enemies_in_range(store.entities, target.pos, 0, ca.radius, ca.vis_flags, ca.vis_bans)

				if targets then
					for _, t in pairs(targets) do
						local d = E:create_entity("damage")

						d.value = ca.damage
						d.damage_type = ca.damage_type
						d.target_id = t.id
						d.source_id = this.id

						queue_damage(store, d)

						local m = E:create_entity(ca.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = t.id

						queue_insert(store, m)
					end
				end
			end

			coroutine.yield()
		end
	end

	queue_remove(store, this)
end

scripts.mod_phoenix_purification = {}

function scripts.mod_phoenix_purification.update(this, store, script)
	local m = this.modifier
	local target

	m.ts = store.tick_ts

	while true do
		target = store.entities[m.target_id]

		if not target or store.tick_ts - m.ts > m.duration then
			break
		end

		if target.health.dead then
			SU.insert_sprite(store, this.fx, target.pos)
			U.y_wait(store, fts(2))

			local e = E:create_entity(this.entity)

			e.pos = V.vclone(target.pos)
			e.bullet.from = V.vclone(e.pos)
			e.bullet.to = V.v(target.pos.x, target.pos.y + 100)

			local aura = store.entities[m.source_id]

			e.bullet.source_id = this.id
			e.bullet.xp_dest_id = aura and aura.aura.source_id or nil
			e.bullet.shot_index = 0

			queue_insert(store, e)

			break
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.mod_gnoll_blighter = {}

function scripts.mod_gnoll_blighter.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.plant then
		queue_remove(store, this)

		return
	end

	local p = target.plant

	m.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts
	this.pos.x, this.pos.y = target.pos.x, target.pos.y
	p.block_count = p.block_count + 1

	if p.block_count > 0 then
		p.blocked = true

		if this.ui then
			this.ui.can_click = false
		end
	end

	SU.tower_block_inc(target)
	U.y_wait(store, m.duration)

	p.block_count = p.block_count - 1

	if p.block_count < 1 then
		p.blocked = nil
		p.block_count = 0

		if this.ui then
			this.ui.can_click = true
		end
	end

	queue_remove(store, this)
end

scripts.mod_redcap_heal = {}

function scripts.mod_redcap_heal.insert(this, store)
	local target = store.entities[this.modifier.target_id]
	local source = store.entities[this.modifier.source_id]

	if target and source then
		local fx = E:create_entity(this.hit_fx)

		fx.pos = V.vclone(target.pos)
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].flip_x = target.pos.x < source.pos.x

		queue_insert(store, fx)
	end

	this.modifier.target_id = this.modifier.source_id

	return scripts.mod_hps.insert(this, store)
end

scripts.mod_twilight_avenger_last_service = {}

function scripts.mod_twilight_avenger_last_service.remove(this, store)
	local count_soldiers, count_enemies = 0, 0
	local target = store.entities[this.modifier.target_id]

	if this.modifier.removed_by_ban then
		return true
	end

	if not target then
		return true
	end

	if not target.health.dead then
		target.vis.flags = band(target.vis.flags, bnot(F_DARK_ELF))
	else
		local targets = table.filter(store.entities, function(k, v)
			return not v.pending_removal and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.explode_vis_bans) == 0 and band(v.vis.bans, this.explode_vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.explode_range) and not table.contains(this.explode_excluded_templates, v.template_name)
		end)

		if targets and #targets > 0 then
			for _, target in pairs(targets) do
				local is_enemy = band(target.vis.flags, F_ENEMY) ~= 0
				local d = E:create_entity("damage")

				d.damage_type = is_enemy and DAMAGE_MAGICAL or DAMAGE_TRUE
				d.value = this.explode_damage
				d.source_id = this.id
				d.target_id = target.id

				queue_damage(store, d)

				if is_enemy then
					count_enemies = count_enemies + 1
				else
					count_soldiers = count_soldiers + 1
				end
			end
		end

		if count_enemies > 0 and count_soldiers == 0 then
			-- AC:inc_check("LAST_SERVICE")
		end

		local p

		if U.flag_has(target.vis.flags, F_FLYING) then
			p = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
		else
			p = V.v(target.pos.x, target.pos.y)
		end

		SU.insert_sprite(store, this.explode_fx, p)
	end

	return true
end

scripts.mod_twilight_scourger_lash = {}

function scripts.mod_twilight_scourger_lash.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	m.ts = store.tick_ts
	target.motion.max_speed = target.motion.max_speed * this.speed_factor
	target.unit.damage_factor = target.unit.damage_factor * this.damage_factor

	local s1, s2 = this.render.sprites[1], this.render.sprites[2]

	s1.ts, s2.ts = store.tick_ts, store.tick_ts
	s1.name = s1.size_names[target.unit.size]
	s2.scale = target.template_name == "enemy_twilight_avenger" and V.v(1, 1) or V.v(0.7, 0.7)
	s2.offset = s1.offset

	return true
end

function scripts.mod_twilight_scourger_lash.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.motion.max_speed = target.motion.max_speed / this.speed_factor
		target.unit.damage_factor = target.unit.damage_factor / this.damage_factor
	end

	return true
end

scripts.mod_twilight_scourger_banshee = {}

function scripts.mod_twilight_scourger_banshee.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	target._is_banshee_target = nil
	m.ts = store.tick_ts

	SU.tower_block_inc(target)

	this.tween.ts = store.tick_ts

	U.y_wait(store, m.duration - 0.2)

	local fx = E:create_entity("fx_twilight_scourger_banshee_end")

	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)
	SU.tower_block_dec(target)
	queue_remove(store, this)
end

scripts.mod_spider_web = {}

function scripts.mod_spider_web.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	if target.template_name == "soldier_blade" and target.dodge and target.dodge.chance > 0 and not target.unit.is_stunned and not target.timed_attacks.list[1].in_progress and target.powers[target.dodge.power_name].level > 0 and target.dodge.chance >= math.random() then
		log.debug("(%s)mod_spider_web blocked by (%s)soldier_blade perfect parry", this.id, target.id)

		target.dodge.active = true

		return false
	else
		return scripts.mod_stun.insert(this, store, script)
	end
end

scripts.mod_twilight_heretic_consume = {}

function scripts.mod_twilight_heretic_consume.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		return false
	end

	m.ts = store.tick_ts
	this._angles_walk = target.render.sprites[1].angles.walk
	this._health_bar_offset_y = target.health_bar.offset.y
	target.render.sprites[1].angles.walk = this.angles_walk
	target.motion.max_speed = target.motion.max_speed * this.speed_factor
	target.ranged.attacks[1].disabled = true

	return true
end

function scripts.mod_twilight_heretic_consume.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.render.sprites[1].angles.walk = this._angles_walk
		target.health_bar.offset.y = this._health_bar_offset_y
		target.motion.max_speed = target.motion.max_speed / this.speed_factor
		target.ranged.attacks[1].disabled = false
	end

	return true
end

function scripts.mod_twilight_heretic_consume.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.pos then
		queue_remove(store, this)

		return
	end

	local st = target.render.sprites[1]
	local hboy = target.health_bar.offset.y

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or P:nodes_to_goal(target.nav_path) < this.nodes_limit then
			queue_remove(store, this)

			return
		end

		local oy, hoy = 0, 0

		if string.starts(st.name, "flying") then
			oy = this.mod_offset_y
			hoy = this.health_bar_offset_y
		end

		this.render.sprites[1].offset.y = oy
		target.health_bar.offset.y = hboy + hoy

		coroutine.yield()
	end
end

scripts.mod_twilight_heretic_servant = {}

function scripts.mod_twilight_heretic_servant.update(this, store)
	local m = this.modifier
	local dps = this.dps
	local target = store.entities[m.target_id]
	local looping = false

	if not target then
		queue_remove(store, this)

		return
	end

	m.ts = store.tick_ts
	dps.ts = store.tick_ts - dps.damage_every
	target.vis.flags = U.flag_set(target.vis.flags, F_SERVANT)

	U.animation_start(this, "start", nil, store.tick_ts, false)

	while store.tick_ts - m.ts < m.duration do
		target = store.entities[m.target_id]

		if not target or target.health.dead then
			break
		end

		if not looping and U.animation_finished(this) then
			looping = true

			U.animation_start(this, "loop", nil, store.tick_ts, true)
		end

		if store.tick_ts - dps.ts >= dps.damage_every then
			dps.ts = store.tick_ts

			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = target.id
			d.value = math.random(dps.damage_min, dps.damage_max)
			d.damage_type = dps.damage_type

			queue_damage(store, d)
		end

		coroutine.yield()
	end

	if target then
		target.vis.flags = U.flag_clear(target.vis.flags, F_SERVANT)
	end

	this.tween.disabled = nil
	this.tween.ts = store.tick_ts
end

scripts.mod_drider_poison = {}

function scripts.mod_drider_poison.update(this, store)
	local m = this.modifier
	local dps = this.dps
	local target
	local source = store.entities[m.source_id]
	local generation = source and source.generation + 1 or 1

	while store.tick_ts - m.ts < m.duration do
		target = store.entities[m.target_id]

		if not target then
			break
		end

		this.pos = target.pos

		if this.render and m.use_mod_offset and target.unit.mod_offset then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		if target.health.dead then
			coroutine.yield()
			coroutine.yield()

			if target.hero or not target.health.dead or target.reinforcement and target.reinforcement.hp_before_timeout then
				break
			end

			local ec = E:create_entity("decal_drider_clone")

			ec.render = table.deepclone(target.render)
			ec.pos.x, ec.pos.y = target.pos.x, target.pos.y

			queue_insert(store, ec)
			coroutine.yield()
			U.sprites_hide(target)

			local e = E:create_entity("decal_drider_cocoon")
			local se = e.render.sprites[1]

			e.pos.x, e.pos.y = target.pos.x, target.pos.y - 1
			se.flip_x = ec.render.sprites[1].flip_x
			se.scale = se.size_scales[target.unit.size]
			e.generation = generation

			queue_insert(store, e)

			break
		end

		if store.tick_ts - dps.ts >= dps.damage_every then
			dps.ts = store.tick_ts

			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = target.id
			d.value = dps.damage_max
			d.damage_type = dps.damage_type

			queue_damage(store, d)
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.decal_drider_cocoon = {}

function scripts.decal_drider_cocoon.update(this, store)
	U.y_animation_play(this, "start", nil, store.tick_ts)
	U.y_wait(store, this.duration)
	U.y_animation_play(this, "end", nil, store.tick_ts)

	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_RALLY)

	if #nodes < 1 then
		log.error("(%s) decal_drider_cocoon: could not find valid node to spawn enemy. %s,%s", this.id, this.pos.x, this.pos.y)
		queue_remove(store, this)

		return
	end

	local e = E:create_entity("enemy_drider")
	local n = e.nav_path

	e.pos.x, e.pos.y = this.pos.x, this.pos.y
	n.pi, n.spi, n.ni = nodes[1][1], nodes[1][2], nodes[1][3] + 2
	e.render.sprites[1].name = "raise"
	e.generation = this.generation
	e.melee.attacks[2].cooldown = e.melee.attacks[2].cooldown + e.generation * e.melee.attacks[2].cooldown_inc
	e.melee.attacks[2].ts = store.tick_ts

	queue_insert(store, e)
	queue_remove(store, this)
end

scripts.mod_razorboar_rampage_speed = {}

function scripts.mod_razorboar_rampage_speed.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		return false
	end

	this._initial_max_speed = target.motion.max_speed
	target.motion.max_speed = target.motion.max_speed * this.speed_factor

	return true
end

function scripts.mod_razorboar_rampage_speed.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.motion.max_speed = target.motion.max_speed / this.speed_factor
	end

	return true
end

function scripts.mod_razorboar_rampage_speed.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return false
	end

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or not target.enemy.can_do_magic or store.tick_ts - m.ts >= m.duration then
			queue_remove(store, this)

			return
		end

		coroutine.yield()
	end
end

scripts.mod_mactans_tower_block = {}

function scripts.mod_mactans_tower_block.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	SU.tower_block_inc(target)

	m.ts = store.tick_ts
	this.tween.ts = store.tick_ts

	U.y_wait(store, m.duration + 4 * fts(17))
	U.sprites_hide(this, 1, 4)
	U.sprites_show(this, 5, 5)
	U.y_animation_play(this, "end", nil, store.tick_ts, 1, 5)
	SU.tower_block_dec(target)
	queue_remove(store, this)
end

scripts.mod_bloodsydian_warlock = {}

function scripts.mod_bloodsydian_warlock.update(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not U.flags_pass(target.vis, this.modifier) then
		queue_remove(store, this)

		return
	end

	SU.stun_inc(target)

	target.vis.bans = bor(F_MOD, F_TELEPORT, F_RANGED)
	target.health.ignore_damage = true
	target.ui.can_select = false

	U.sprites_hide(target, nil, nil, true)

	this.pos.x, this.pos.y = target.pos.x, target.pos.y

	U.animation_start(this, "start", target.render.sprites[1].flip_x, store.tick_ts)

	this.incubation_time = this.incubation_time + U.frandom(-this.incubation_time_variance, this.incubation_time_variance)

	U.y_wait(store, this.incubation_time, function()
		return target.health.dead
	end)
	U.sprites_show(target, nil, nil, true)

	target.health.ignore_damage = false

	if this.modifier.kill then
		local d = E:create_entity("damage")

		d.source_id = this.id
		d.target_id = target.id
		d.value = target.health.hp

		queue_damage(store, d)
	elseif not target.health.dead and target.health.hp > 0 then
		local d = E:create_entity("damage")

		d.damage_type = DAMAGE_EAT
		d.source_id = this.id
		d.target_id = target.id

		queue_damage(store, d)

		local e = E:create_entity(this.spawn_name)

		e.pos.x, e.pos.y = target.pos.x, target.pos.y
		e.nav_path = table.deepclone(target.nav_path)
		e.render.sprites[1].flip_x = target.render.sprites[1].flip_x
		e.enemy.gold = target.enemy.gold
		e.enemy.gold_bag = target.enemy.gold_bag
		e.enemy.gems = target.enemy.gems

		queue_insert(store, e)

		target.enemy.gold = 0
		target.enemy.gold_bag = 0
		target.enemy.gems = 0
	end

	S:queue("ElvesCrystallizedGnoll")
	U.y_animation_play(this, "end", nil, store.tick_ts)
	queue_remove(store, this)
end

scripts.mod_dark_spitters = {}

function scripts.mod_dark_spitters.update(this, store)
	local m = this.modifier
	local dps = this.dps
	local target, generation

	while store.tick_ts - m.ts < m.duration do
		target = store.entities[m.target_id]

		if not target then
			break
		end

		this.pos = target.pos

		if this.render and m.use_mod_offset and target.unit.mod_offset then
			local flip_sign = target.render.sprites[1].flip_x and -1 or 1

			this.render.sprites[1].offset.x = target.unit.mod_offset.x * flip_sign
			this.render.sprites[1].offset.y = target.unit.mod_offset.y
		end

		if target.health.dead then
			coroutine.yield()
			coroutine.yield()

			if target.hero or not target.health.dead or target.reinforcement and target.reinforcement.hp_before_timeout then
				break
			end

			U.sprites_hide(target)
			SU.insert_sprite(store, this.explode_fx, target.pos)

			local nodes = P:nearest_nodes(target.pos.x, target.pos.y, nil, nil, true, NF_RALLY)

			if #nodes < 1 then
				log.error("(%s) mod_dark_spitters: could not find valid node nearby to spawn enemy. %s,%s", this.id, target.pos.x, target.pos.y)

				break
			end

			local pi, spi, ni = nodes[1][1], nodes[1][2], nodes[1][3]

			if P:nodes_to_defend_point(pi, spi, ni) < this.nodes_limit then
				break
			end

			local e = E:create_entity(this.spawn_entity)
			local n = e.nav_path

			e.pos.x, e.pos.y = target.pos.x, target.pos.y
			n.pi, n.spi, n.ni = pi, spi, ni + 2
			e.render.sprites[1].name = "raise"
			e.enemy.gold = 0
			e.enemy.gold_bag = 0
			e.enemy.gems = 0

			queue_insert(store, e)

			break
		end

		if store.tick_ts - dps.ts >= dps.damage_every then
			dps.ts = store.tick_ts

			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = target.id
			d.value = dps.damage_max
			d.damage_type = dps.damage_type

			queue_damage(store, d)
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.mactans_controller = {}

function scripts.mactans_controller.insert(this, store)
	if this.load_file then
		local fn = KR_PATH_GAME .. "/data/levels/" .. this.load_file .. ".lua"
		local data, err = LU.eval_file(fn)

		if not data then
			log.error("mactans_controller failed loading file %s: %s", this.load_file, err)

			return false
		end

		this.sequence = data.sequence
		this.sequence_groups = data.sequence_groups
	end

	return true
end

function scripts.mactans_controller.update(this, store)
	local mactans = LU.list_entities(store.entities, "enemy_mactans")[1]
	local sequence = this.sequence and this.sequence[store.level_mode]

	if not this.sequence then
		log.error("mactans_controller not initialized. sequence is missing")
	elseif not sequence then
		log.debug("mactans_controller has no configuration for this game mode")
	elseif not mactans then
		log.error("enemy_mactans could not be found")
	else
		while not store.waves_finished do
			local start_ts, last_ts = store.tick_ts, store.tick_ts
			local wave_number = store.wave_group_number
			local groups = sequence[wave_number]

			if not groups then
				-- block empty
			else
				for _, group in pairs(groups) do
					local t_elapsed = store.tick_ts - start_ts
					local t_total = group[1]
					local t_actual = km.clamp(0, t_total, t_total - t_elapsed)

					log.debug("mactans_controller wave_number:%s delay:%s waiting:%s type:%s", wave_number, t_total, t_actual, group[2])

					if U.y_wait(store, t_actual, function(store, time)
						return store.wave_group_number ~= wave_number or store.waves_finished
					end) then
						goto label_487_0
					end

					if group[2] == "tower_block" then
						local holder_ids = this.sequence_groups.towers[group[3]]

						if holder_ids and #holder_ids > 0 then
							mactans.phase_signal = group[2]
							mactans.phase_params = {
								holder_ids = holder_ids,
								block_duration = group[4],
								touch_duration = group[5]
							}
						else
							log.info("mactans wave:%s tower_block for group:%s has no holder_ids defined", wave_number, group[3])
						end
					elseif group[2] == "path_web" then
						local path_data = table.random(this.sequence_groups.paths[group[3]])

						mactans.phase_signal = group[2]
						mactans.phase_params = {
							path_id = path_data.path_id,
							near_pos = path_data.pos,
							web_duration = group[4],
							touch_duration = group[6],
							qty_per_egg = group[5]
						}
					end

					if store.wave_group_number ~= wave_number then
						goto label_487_0
					end
				end

				coroutine.yield()
			end

			::label_487_0::

			while store.wave_group_number == wave_number and not store.waves_finished do
				coroutine.yield()
			end
		end
	end

	queue_remove(store, this)
end

scripts.power_thunder_control = {}

function scripts.power_thunder_control.can_select_point(this, x, y, store)
	return not GR:cell_is(x, y, TERRAIN_CLIFF) and not GR:cell_is(x, y, TERRAIN_FAERIE) and (P:valid_node_nearby(x, y, 1.4285714285714286, NF_POWER_1) or store.level.fn_can_power and store.level:fn_can_power(store, GUI_MODE_POWER_1, V.v(x, y)) or GR:cell_is(x, y, TERRAIN_WATER))
end

function scripts.power_thunder_control.update(this, store)
	local function create_thunder(thunder, pos)
		local e = E:create_entity("fx_power_thunder_" .. math.random(1, 2))

		e.pos.x, e.pos.y = pos.x, pos.y
		e.render.sprites[1].flip_x = math.random() < 0.5
		e.render.sprites[1].ts = store.tick_ts

		if REF_H - pos.y > e.image_h then
			e.render.sprites[1].scale = V.v(1, (REF_H - pos.y) / e.image_h)
		end

		queue_insert(store, e)

		e = E:create_entity("fx_power_thunder_explosion")
		e.pos.x, e.pos.y = pos.x, pos.y
		e.render.sprites[1].ts = store.tick_ts
		e.render.sprites[2].ts = store.tick_ts

		queue_insert(store, e)

		e = E:create_entity("fx_power_thunder_explosion_decal")
		e.pos.x, e.pos.y = pos.x, pos.y
		e.render.sprites[1].ts = store.tick_ts

		queue_insert(store, e)

		if thunder.pop and math.random() < thunder.pop_chance then
			local e = SU.create_pop(store, this.pos, thunder.pop)

			queue_insert(store, e)
		end

		local targets = U.find_enemies_in_range(store.entities, pos, 0, thunder.damage_radius, this.vis_flags, this.vis_bans)

		if targets then
			for _, target in pairs(targets) do
				local d = E:create_entity("damage")

				d.damage_type = thunder.damage_type
				d.value = math.random(thunder.damage_min, thunder.damage_max)
				d.target_id = target.id
				d.source_id = this.id

				queue_damage(store, d)
			end
		end

		-- AC:inc_check("LIGHTNING_CAST")
	end

	local function flash_screen(fx)
		if store.tick_ts - fx.ts > fx.cooldown then
			local duration = U.frandom(this.flash_duration_min, this.flash_duration_max)
			local delay = U.frandom(this.flash_delay_min, this.flash_delay_max)
			local a1 = math.random(this.flash_l1_max_alphas[1], this.flash_l1_max_alphas[2])
			local a2 = this.flash_l2_max_alpha
			local a22 = this.flash_l2_min_alpha
			local delta = this.flash_delta
			local t1, t2, t3 = 0, delta, delta + duration

			fx.tween.props[1].keys = {
				{
					t1,
					0
				},
				{
					t2,
					a1
				},
				{
					t3,
					0
				}
			}
			fx.tween.ts = store.tick_ts
			fx.ts = store.tick_ts
			fx.cooldown = duration + U.frandom(0, 0.4)
		end
	end

	local overlay = E:create_entity("overlay_power_thunder_flash")

	overlay.pos.x, overlay.pos.y = REF_W / 2, REF_H / 2
	overlay.tween.props[2].keys = {
		{
			0,
			0
		},
		{
			0.5,
			this.flash_l2_max_alpha
		}
	}
	overlay.tween.props[2].ts = store.tick_ts

	queue_insert(store, overlay)
	flash_screen(overlay)

	local visited = {}
	local t1, t2 = this.thunders[1], this.thunders[2]

	t1.created, t2.created = 0, 0

	if t2.count > 0 then
		t2.cooldown = U.frandom(t2.delay_min, t2.delay_max)
		t2.ts = store.tick_ts
	end

	while t1.created < t1.count or t2.created < t2.count do
		for _, thunder in pairs(this.thunders) do
			if thunder.created < thunder.count and store.tick_ts - thunder.ts > thunder.cooldown then
				local pos

				if thunder.targeting == "nearest" then
					if thunder.created == 0 then
						pos = this.pos
					else
						local target = U.find_nearest_enemy(store.entities, this.pos, 0, thunder.range, this.vis_flags, this.vis_bans, function(v)
							return not table.contains(visited, v)
						end)

						if target then
							table.insert(visited, target)

							pos = target.pos
						else
							local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

							if #nearest > 0 then
								local pi, spi, ni = unpack(nearest[1])
								local no = math.random(-this.nodes_spread, this.nodes_spread)

								if not P:is_node_valid(pi, ni + no) then
									no = 0
								end

								pos = P:node_pos(pi, math.random(1, 3), ni + no)
							end
						end
					end
				else
					local target = U.find_random_enemy(store.entities, this.pos, 0, thunder.range, this.vis_flags, this.vis_bans)

					if target then
						pos = target.pos
					else
						pos = P:get_random_position(10, bor(TERRAIN_LAND, TERRAIN_WATER)) or this.pos
					end
				end

				if pos then
					create_thunder(thunder, pos)
					flash_screen(overlay)
				end

				thunder.ts = store.tick_ts
				thunder.cooldown = U.frandom(thunder.delay_min, thunder.delay_max)
				thunder.created = thunder.created + 1
			end
		end

		if not this.slow.disabled and store.tick_ts - this.slow.ts > this.slow.cooldown then
			this.slow.ts = store.tick_ts

			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.slow.range, this.vis_flags, this.vis_bans)

			if targets then
				for _, target in pairs(targets) do
					local mod = E:create_entity(this.slow.mod)

					mod.modifier.target_id = target.id
					mod.modifier.source_id = this.id

					queue_insert(store, mod)
				end
			end
		end

		if not this.rain.disabled and store.tick_ts - this.rain.ts > this.rain.cooldown then
			local r = this.rain

			r.ts = store.tick_ts

			local angle = U.frandom(r.angle_min, r.angle_max)

			for i = 1, r.count do
				angle = angle + U.frandom(-r.angle_between, r.angle_between)

				local dist = math.random(r.distance_min, r.distance_max)
				local ox, oy = V.rotate(angle, dist, 0)
				local delay = U.frandom(0.001, r.delay_max)
				local pos = V.v(math.random(-REF_OX, REF_W + REF_OX), math.random(0, REF_H))
				local e = E:create_entity("fx_power_thunder_drop")

				e.pos.x, e.pos.y = pos.x, pos.y
				e.render.sprites[1].offset = V.v(-ox, -oy)
				e.render.sprites[1].r = angle
				e.render.sprites[1].alpha = math.random(r.alpha_min, r.alpha_max)
				e.tween.props[1].keys = {
					{
						0,
						0
					},
					{
						0.001,
						255
					}
				}
				e.tween.props[2] = E:clone_c("tween_prop")
				e.tween.props[2].keys = {
					{
						0,
						V.v(-ox, -oy)
					},
					{
						0.001,
						V.v(-ox, -oy)
					},
					{
						r.duration,
						V.v(0, 0)
					}
				}
				e.tween.props[2].name = "offset"
				e.tween.ts = store.tick_ts + delay

				queue_insert(store, e)

				local e = E:create_entity("fx_power_thunder_rain_splash")

				e.pos.x, e.pos.y = pos.x, pos.y
				e.render.sprites[1].ts = store.tick_ts + delay + r.duration

				queue_insert(store, e)
			end
		end

		coroutine.yield()
	end

	U.y_wait(store, overlay.cooldown)

	overlay.tween.remove = true
	overlay.tween.props[1].keys = {
		{
			0,
			overlay.render.sprites[1].alpha
		},
		{
			0.5,
			0
		}
	}
	overlay.tween.props[2].keys = {
		{
			0,
			overlay.render.sprites[2].alpha
		},
		{
			0.5,
			0
		}
	}
	overlay.tween.ts = store.tick_ts
	overlay.tween.props[2].ts = nil

	queue_remove(store, this)
end

scripts.power_hero_control = {}

function scripts.power_hero_control.can_select_point(this, x, y, store)
	if store.main_hero then
		local ut = E:get_template(store.main_hero.hero.skills.ultimate.controller_name)

		if not ut.can_fire_fn or ut.can_fire_fn(ut, x, y, store) then
			return true
		end
	end

	return false
end

function scripts.power_hero_control.insert(this, store)
	if store.main_hero then
		local u = store.main_hero.hero.skills.ultimate
		local e = E:create_entity(u.controller_name)

		e.pos.x, e.pos.y = this.pos.x, this.pos.y
		e.owner = store.main_hero
		e.level = u.level

		queue_insert(store, e)
	end

	return false
end

scripts.user_item_gem_timewarp = {}

function scripts.user_item_gem_timewarp.update(this, store)
	local a = this.aura

	signal.emit("gem-timewarp-starts")

	for i = 1, 10 do
		local pos = P:get_random_position(10, bor(TERRAIN_LAND), NF_RALLY) or this.pos

		SU.insert_sprite(store, a.custom_fx, pos)
	end

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

	if targets then
		for _, e in pairs(targets) do
			local m = E:create_entity(a.mod_teleport)

			m.modifier.target_id = e.id
			m.modifier.source_id = this.id

			queue_insert(store, m)

			local teleport_nodes = math.abs(U.flag_has(e.vis.flags, F_BOSS) and m.boss_nodes_offset or m.nodes_offset)
			local extra_time = U.frandom(a.extra_slow_duration_random[1], a.extra_slow_duration_random[2])

			if teleport_nodes > e.nav_path.ni then
				extra_time = extra_time + (teleport_nodes - e.nav_path.ni) * a.extra_slow_duration_per_clamped_node
			end

			m = E:create_entity(a.mod_slow)
			m.modifier.target_id = e.id
			m.modifier.source_id = this.id
			m.modifier.duration = m.modifier.duration + extra_time

			queue_insert(store, m)
		end
	end

	queue_remove(store, this)
end

scripts.user_item_wrath_of_elynia = {}

function scripts.user_item_wrath_of_elynia.update(this, store)
	local a = this.aura
	local shake, targets

	signal.emit("wrath-of-elynia-starts")
	U.y_wait(store, fts(5))

	shake = E:create_entity("aura_screen_shake")
	shake.aura.amplitude = 0.2
	shake.aura.duration = 1
	shake.aura.freq_factor = 2

	queue_insert(store, shake)

	local ray = SU.insert_sprite(store, "decal_elynia_ray", this.pos)

	targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

	if targets then
		for _, e in pairs(targets) do
			local m = E:create_entity(a.mod_slow)

			m.modifier.target_id = e.id
			m.modifier.source_id = this.id

			queue_insert(store, m)
		end
	end

	U.y_wait(store, 1)

	shake = E:create_entity("aura_screen_shake")
	shake.aura.amplitude = 1
	shake.aura.duration = 1.5
	shake.aura.freq_factor = 3

	queue_insert(store, shake)

	local explosion = SU.insert_sprite(store, "decal_elynia_big_explosion", this.pos)

	ray.tween.reverse = true
	ray.tween.ts = store.tick_ts
	ray.render.sprites[2].hidden = true

	U.y_wait(store, fts(4))
	queue_remove(store, ray)

	local r = 0
	local start_ts = store.tick_ts
	local seen_bosses = {}

	while r < a.radius do
		r = (store.tick_ts - start_ts) * a.spread_speed
		targets = U.find_enemies_in_range(store.entities, this.pos, 0, r, a.vis_flags, a.vis_bans)

		if targets then
			for _, e in pairs(targets) do
				do
					local m

					if e.vis and band(e.vis.flags, F_BOSS) ~= 0 then
						if seen_bosses[e.id] then
							goto label_497_0
						else
							seen_bosses[e.id] = true
						end
					end

					m = E:create_entity(a.mod_kill)
					m.modifier.target_id = e.id
					m.modifier.source_id = this.id
					m.modifier.delay = 0

					queue_insert(store, m)
				end

				::label_497_0::
			end
		end

		U.y_wait(store, fts(2))
	end

	U.y_wait(store, 0.5)
	signal.emit("wrath-of-elynia-ends")
	queue_remove(store, this)
end

scripts.mod_kill_elynia = {}

function scripts.mod_kill_elynia.queue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion and not U.flag_has(target.vis.flags, F_BOSS) then
		target.vis.bans = F_ALL

		SU.stun_inc(target)
	end
end

function scripts.mod_kill_elynia.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		U.y_wait(store, m.delay)
		SU.insert_sprite(store, "fx_elynia_creep_explosion", target.pos)

		if U.flag_has(target.vis.flags, F_BOSS) then
			local d = E:create_entity("damage")

			d.damage_type = DAMAGE_TRUE
			d.value = m.damage_boss
			d.source_id = this.id
			d.target_id = target.id

			queue_damage(store, d)
		else
			local ash = SU.insert_sprite(store, "fx_elynia_creep_ashes", target.pos)
			local ash_hold = U.frandom(0, 1)

			ash.tween.props[1].keys[2][1] = ash.tween.props[1].keys[2][1] + ash_hold
			ash.tween.props[1].keys[3][1] = ash.tween.props[1].keys[3][1] + ash_hold

			local d = E:create_entity("damage")

			d.damage_type = DAMAGE_EAT
			d.source_id = this.id
			d.target_id = target.id

			queue_damage(store, d)
		end
	end

	queue_remove(store, this)
end

scripts.user_item_horn_heroism = {}

function scripts.user_item_horn_heroism.update(this, store)
	local a = this.aura
	local at = this.mod_attack

	this.render.sprites[2].ts = store.tick_ts
	this.render.sprites[3].ts = store.tick_ts
	this.tween.ts = store.tick_ts

	U.y_wait(store, fts(17))

	local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

	if targets then
		for i = 1, math.min(#targets, a.max_soldiers) do
			local e = targets[i]
			local m = E:create_entity(a.mod)

			m.modifier.target_id = e.id
			m.modifier.source_id = this.id

			queue_insert(store, m)
		end
	end

	local targets = U.find_towers_in_range(store.entities, this.pos, at, function(e, o)
		return not e.barrack and e.tower.can_be_mod
	end)

	if targets then
		for i = 1, math.min(#targets, at.max_towers) do
			local e = targets[i]
			local m = E:create_entity(at.mod)

			m.modifier.target_id = e.id
			m.modifier.source_id = this.id

			queue_insert(store, m)
		end
	end

	U.y_animation_wait(this, 2)
	queue_remove(store, this)
end

scripts.mod_horn_heroism_soldier = {}

function scripts.mod_horn_heroism_soldier.insert(this, store)
	if scripts.mod_damage_factors.insert(this, store) then
		local target = store.entities[this.modifier.target_id]

		if target then
			target.health.immune_to = this.immune_to
		end

		return true
	else
		return false
	end
end

function scripts.mod_horn_heroism_soldier.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		target.health.immune_to = DAMAGE_NONE
	end

	scripts.mod_damage_factors.remove(this, store)

	return true
end

scripts.user_item_rod_dragon_fire = {}

function scripts.user_item_rod_dragon_fire.can_select_point(this, x, y, store)
	return scripts.power_reinforcements_control.can_select_point(this, x, y)
end

function scripts.user_item_rod_dragon_fire.update(this, store)
	local au = this.aura
	local at = this.attacks.list[1]

	au.ts = store.tick_ts
	at.ts = store.tick_ts

	U.y_animation_play(this, "start", nil, store.tick_ts, 1, 1)

	this.render.sprites[2].hidden = nil

	while true do
		if store.tick_ts - au.ts >= au.duration then
			break
		end

		if store.tick_ts - at.ts > at.cooldown then
			local target, _, pred_pos = U.find_foremost_enemy(store.entities, this.pos, 0, at.range, at.node_prediction, at.vis_flags, at.vis_bans)

			if not target then
				SU.delay_attack(store, at, 0.2)
			else
				at.ts = store.tick_ts

				local bullet = E:create_entity(at.bullet)

				bullet.pos.x, bullet.pos.y = this.pos.x + at.bullet_start_offset.x, this.pos.y + at.bullet_start_offset.y
				bullet.bullet.from = V.vclone(bullet.pos)
				bullet.bullet.to = V.v(pred_pos.x + target.unit.hit_offset.x, pred_pos.y + target.unit.hit_offset.y)
				bullet.bullet.target_id = target.id

				queue_insert(store, bullet)
			end
		end

		coroutine.yield()
	end

	this.render.sprites[2].hidden = true

	U.y_animation_play(this, "end", nil, store.tick_ts, 1, 1)
	queue_remove(store, this)
end

scripts.user_item_hand_midas = {}

function scripts.user_item_hand_midas.can_select_point(this, x, y, store)
	local u = LU.list_entities(store.entities, this.template_name)[1]

	if u and not u.pending_removal then
		return false
	else
		return true
	end
end

function scripts.user_item_hand_midas.update(this, store)
	this.ts = store.tick_ts
	store.hand_of_midas_factor = this.gold_bonus_factor

	signal.emit("hand-midas-starts")

	while store.tick_ts - this.ts < this.duration do
		coroutine.yield()
	end

	store.hand_of_midas_factor = nil

	signal.emit("hand-midas-ends")
	queue_remove(store, this)
end

scripts.birds_controller = {}

function scripts.birds_controller.update(this, store)
	local ts = store.tick_ts
	local i = 1

	while true do
		local delay = U.frandom(this.delay[1], this.delay[2])

		U.y_wait(store, delay)

		for j = 1, this.batch_count do
			local batch_delay = U.frandom(this.batch_delay[1], this.batch_delay[2])

			U.y_wait(store, batch_delay)

			local e = E:create_entity(table.random(this.bird_templates))
			local o, d = this.origins[km.zmod(i, #this.origins)], this.destinations[km.zmod(i, #this.destinations)]
			local fly_time = V.dist(o.x, o.y, d.x, d.y) / this.fly_speed

			e.pos = V.v(o.x, o.y)
			e.tween.props[1].keys = {
				{
					0,
					V.v(0, 0)
				},
				{
					fly_time,
					V.v(d.x, d.y)
				}
			}
			e.render.sprites[1].ts = store.tick_ts
			e.render.sprites[1].flip_x = o.x > d.x

			queue_insert(store, e)

			i = i + 1
		end
	end
end

scripts.decal_bambi = {}

function scripts.decal_bambi.update(this, store)
	local clicks = 0
	local max_clicks = math.random(3, 6)
	local idle_ts, idle_time = store.tick_ts, 1
	local pos1, pos2

	if this.run_offset then
		pos1 = V.vclone(this.pos)
		pos2 = V.v(this.pos.x + this.run_offset.x, this.pos.y + this.run_offset.y)
	end

	while true do
		if this.ui.clicked then
			clicks = clicks + 1

			if max_clicks < clicks then
				S:queue("DeathEplosion")

				local fx = E:create_entity("fx_unit_explode")

				fx.pos = V.vclone(this.pos)
				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[1].name = "small"

				queue_insert(store, fx)

				local blood = E:create_entity("decal_blood_pool")

				blood.render.sprites[1].ts = store.tick_ts
				blood.pos = V.vclone(this.pos)

				queue_insert(store, blood)
				queue_remove(store, this)

				return
			else
				U.y_animation_play(this, "touch", nil, store.tick_ts)
			end

			this.ui.clicked = nil
		end

		if idle_time < store.tick_ts - idle_ts then
			idle_ts = store.tick_ts
			idle_time = U.frandom(1, 3)

			if math.random() < 0.8 then
				U.animation_start(this, "eat", nil, store.tick_ts)
			elseif pos1 and pos2 then
				local dest = V.veq(this.pos, pos1) and pos2 or pos1
				local af = dest.x < this.pos.x

				U.animation_start(this, "run", af, store.tick_ts, true)
				U.set_destination(this, dest)

				while not this.motion.arrived do
					U.walk(this, store.tick_length)
					coroutine.yield()
				end

				U.animation_start(this, "idle", nil, store.tick_ts)

				this.ui.clicked = nil
			end
		end

		coroutine.yield()
	end
end

scripts.decal_rabbit = {}

function scripts.decal_rabbit.update(this, store)
	local clicks = 0

	local function clicked()
		if this.ui.clicked then
			this.ui.clicked = nil

			return true
		end
	end

	local ani, tmin, tmax, hide_ani

	::label_510_0::

	while true do
		for _, s in pairs(this.ani_sequence) do
			ani, tmin, tmax, hide_ani = unpack(s, 1, 4)

			if ani then
				if this.tween.reverse then
					this.tween.reverse = nil
					this.tween.ts = 0
				end

				U.animation_start(this, ani, nil, store.tick_ts)
			else
				this.tween.reverse = true
				this.tween.ts = store.tick_ts
			end

			if tmin and tmax then
				this.ui.clicked = nil

				if U.y_wait(store, math.random(tmin, tmax), hide_ani and clicked or nil) then
					goto label_510_1
				end
			else
				U.y_animation_wait(this)
			end
		end
	end

	::label_510_1::

	U.y_animation_play(this, hide_ani, nil, store.tick_ts)

	this.tween.reverse = true
	this.tween.ts = store.tick_ts

	-- AC:inc_check("FOLLOW_RABBIT")
	U.y_wait(store, math.random(tmin, tmax))

	goto label_510_0
end

scripts.decal_crane = {}

function scripts.decal_crane.update(this, store)
	local clicks = 0
	local max_clicks = math.random(this.final_clicks[1], this.final_clicks[2])
	local play_ts = store.tick_ts
	local play_time = U.frandom(this.play_time[1], this.play_time[2])

	while true do
		if this.ui.clicked then
			clicks = clicks + 1

			if max_clicks <= clicks then
				this.render.sprites[2].hidden = true

				U.y_animation_play(this, this.final_click_animation, nil, store.tick_ts, 1, 1)
				queue_remove(store, this)

				return
			else
				U.y_animation_play(this, this.click_animation, nil, store.tick_ts, 1, 1)
				U.animation_start(this, "idle", nil, store.tick_ts, true, 1)
			end

			this.ui.clicked = nil
			play_ts = store.tick_ts
		end

		if play_time < store.tick_ts - play_ts then
			play_ts = store.tick_ts
			play_time = U.frandom(this.play_time[1], this.play_time[2])

			U.y_animation_play(this, this.play_animation, nil, store.tick_ts, 1, 1)
			U.animation_start(this, "idle", nil, store.tick_ts, true, 1)

			this.ui.clicked = nil
		end

		coroutine.yield()
	end
end

scripts.river_object_controller = {}

function scripts.river_object_controller.update(this, store)
	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	local spawn_ts = store.tick_ts
	local spawn_time = U.frandom(this.min_time, this.max_time)
	local chests = 0
	local name = "hobbit"

	while true do
		if spawn_time < store.tick_ts - spawn_ts then
			spawn_time = U.frandom(this.min_time, this.max_time)
			spawn_ts = store.tick_ts

			if name ~= "hobbit" then
				name = "hobbit"
			else
				name = table.random(this.river_objects)

				if name == "chest" then
					chests = chests + 1

					if chests >= this.max_chests then
						table.removeobject(this.river_objects, "chest")
					end
				end
			end

			local e = E:create_entity("decal_river_object_" .. name)

			queue_insert(store, e)
		end

		coroutine.yield()
	end
end

scripts.decal_river_object = {}

function scripts.decal_river_object.update(this, store)
	local next, new
	local fall_count = 0

	local function check_clicked()
		if this.ui.clicked then
			if this.gold then
				store.player_gold = store.player_gold + this.gold
			end

			S:queue(this.sound_events.save)
			U.y_animation_play(this, "save", nil, store.tick_ts)
			queue_remove(store, this)

			if this.achievement then
				-- AC:got(this.achievement)
			end

			if this.achievement_inc then
				-- AC:inc_check(this.achievement_inc)
			end

			return
		end
	end

	::label_514_0::

	this.ui.clicked = nil
	this.pos = P:node_pos(this.nav_path)

	U.animation_start(this, "travel", nil, store.tick_ts, true)

	while true do
		check_clicked()

		next, new = P:next_entity_node(this, store.tick_length)

		if next == nil then
			break
		end

		local remaining_nodes = P:get_end_node(this.nav_path.pi) - this.nav_path.ni

		if fall_count == 1 and this.sink_nodes and remaining_nodes <= this.sink_nodes then
			break
		end

		U.set_destination(this, next)
		U.walk(this, store.tick_length)
		coroutine.yield()
	end

	if fall_count < this.falls then
		fall_count = fall_count + 1

		U.animation_start(this, "fall", nil, store.tick_ts, true)

		if fall_count == 1 then
			this.tween.ts = store.tick_ts
			this.tween.disabled = nil
			this.tween.props[1].keys = this.fall_1_tween
		end

		this.nav_path.pi = this.nav_path.pi + 1
		this.nav_path.ni = 1

		local normal_speed = this.motion.max_speed
		local fall_dest = P:node_pos(this.nav_path)

		this.motion.max_speed = V.dist(fall_dest.x, fall_dest.y, this.pos.x, this.pos.y) / this.fall_time

		U.set_destination(this, fall_dest)

		while not U.walk(this, store.tick_length) do
			coroutine.yield()
		end

		this.motion.max_speed = normal_speed

		if fall_count == 1 then
			S:queue(this.sound_events.fall)
			U.y_wait(store, this.fall_wait)

			this.tween.ts = store.tick_ts
			this.tween.disabled = nil
			this.tween.props[1].keys = this.travel_2_tween

			goto label_514_0
		else
			S:queue(this.sound_events.crash)
			U.y_animation_play(this, "crash", nil, store.tick_ts)
			queue_remove(store, this)
		end
	else
		S:queue(this.sound_events.sink)
		U.y_animation_play(this, "sink", nil, store.tick_ts)
		queue_remove(store, this)
	end
end

scripts.decal_george_jungle = {}

function scripts.decal_george_jungle.update(this, store)
	local clicks = 0
	local max_clicks = math.random(this.final_clicks[1], this.final_clicks[2])
	local play_ts = store.tick_ts
	local play_time = U.frandom(this.play_time[1], this.play_time[2])
	local sid_liana, sid_fall, sid_bush = 1, 2, 3
	local s_liana, s_fall, s_bush = this.render.sprites[1], this.render.sprites[2], this.render.sprites[3]
	local dx = store.visible_coords.right - REF_W
	local ox, oy = s_liana.offset.x, s_liana.offset.y

	this.tween.props[2].keys[1][2] = V.v(ox + dx, oy)
	this.tween.props[2].keys[2][2] = V.v(ox, oy)
	s_liana.offset.x, s_liana.offset.y = ox + dx, oy

	local rect = this.ui.click_rect

	rect.pos.x = ox + dx + 60
	rect.pos.y = REF_H - rect.size.y

	while true do
		if this.ui.clicked then
			clicks = clicks + 1

			if max_clicks <= clicks then
				S:queue("ElvesSpecialGeorgeFall")

				this.tween.ts = store.tick_ts
				this.tween.disabled = nil

				U.y_wait(store, this.tween.props[1].keys[2][1])
				U.y_animation_play(this, "start", nil, store.tick_ts, 1, sid_liana)
				U.animation_start(this, "release", nil, store.tick_ts, false, sid_liana)

				s_fall.hidden = nil

				U.animation_start(this, "fall", nil, store.tick_ts, false, sid_fall)
				U.y_animation_wait(this, sid_liana)

				s_liana.hidden = true

				U.y_animation_wait(this, sid_fall)

				s_fall.hidden = true

				U.y_animation_play(this, "play", nil, store.tick_ts, 1, sid_bush)
				U.animation_start(this, "idle", nil, store.tick_ts, true, sid_bush)
				-- AC:got(this.achievement)

				break
			else
				U.y_animation_play(this, "click", nil, store.tick_ts, 1, sid_liana)
				U.animation_start(this, "idle", nil, store.tick_ts, true, sid_liana)
			end

			this.ui.clicked = nil
			play_ts = store.tick_ts
		end

		if play_time < store.tick_ts - play_ts then
			play_ts = store.tick_ts
			play_time = U.frandom(this.play_time[1], this.play_time[2])

			U.y_animation_play(this, "click", nil, store.tick_ts, 1, sid_liana)
			U.animation_start(this, "idle", nil, store.tick_ts, true, sid_liana)

			this.ui.clicked = nil
		end

		coroutine.yield()
	end
end

scripts.decal_tree_ewok = {}

function scripts.decal_tree_ewok.update(this, store)
	local a = this.ranged.attacks[1]

	a.ts = store.tick_ts

	local wait_ts = -this.wait_time

	this.nav_path.pi = this.path_id
	this.nav_path.spi = 1
	this.nav_path.ni = 1
	this.pos = P:node_pos(this.nav_path)

	while true do
		if store.tick_ts - a.ts > a.cooldown then
			local target = U.find_random_enemy(store.entities, this.ranged_center, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if target then
				a.ts = store.tick_ts

				local node_offset = P:predict_enemy_node_advance(target, prediction_time)
				local pred_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
				local start_ts = store.tick_ts
				local an, af, ai = U.animation_name_facing_point(this, a.animation, pred_pos)

				U.animation_start(this, an, af, store.tick_ts, false)
				S:queue(a.sound)
				U.y_wait(store, a.shoot_time)

				local bo = a.bullet_start_offset[ai]
				local b = E:create_entity(a.bullet)

				b.pos = V.v(this.pos.x + bo.x, this.pos.y + bo.y)
				b.bullet.to = V.v(pred_pos.x + target.unit.hit_offset.x, pred_pos.y + target.unit.hit_offset.y)
				b.bullet.from = V.vclone(b.pos)
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id

				queue_insert(store, b)
				U.y_animation_wait(this)
			end
		end

		if store.tick_ts - wait_ts > this.wait_time then
			U.y_animation_play(this, table.random(this.dance_animations), nil, store.tick_ts, 2)

			while SU.y_enemy_walk_step(store, this) do
				coroutine.yield()
			end

			this.nav_path.dir = -1 * this.nav_path.dir
			wait_ts = store.tick_ts
		end

		U.animation_start(this, "idle", false, store.tick_ts, true)
		coroutine.yield()
	end
end

scripts.tower_ewok_holder = {}

function scripts.tower_ewok_holder.get_info()
	local tpl = E:get_template("tower_ewok")
	local o = scripts.tower_barrack.get_info(tpl)

	o.respawn = nil

	return o
end

scripts.soldier_ewok = {}

function scripts.soldier_ewok.update(this, store)
	local brk, sta

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	while true do
		if this.health.dead then
			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if this.dodge and this.dodge.active then
				local start_ts = store.tick_ts

				U.y_animation_play(this, this.dodge.animation_start, nil, store.tick_ts, 1)

				this.dodge.last_hit_ts = nil

				while store.tick_ts - start_ts < this.dodge.duration and not this.health.dead and not this.unit.is_stunned do
					SU.soldier_regen(store, this)

					if this.dodge.last_hit_ts then
						U.y_animation_play(this, this.dodge.animation_hit, nil, store.tick_ts, 1)

						this.dodge.last_hit_ts = nil
					end

					coroutine.yield()
				end

				U.y_animation_play(this, this.dodge.animation_end, nil, store.tick_ts, 1)

				this.dodge.active = false
				this.dodge.ts = store.tick_ts

				goto label_519_1
			end

			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_519_1
				end
			end

			if this.melee then
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_519_1
				end
			end

			if this.ranged then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk or sta == A_DONE then
					goto label_519_1
				elseif sta == A_IN_COOLDOWN then
					goto label_519_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_519_1
			end

			::label_519_0::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_519_1::

		coroutine.yield()
	end
end

scripts.decal_bush_statue = {}

function scripts.decal_bush_statue.insert(this, store)
	local d = store.ephemeral

	if not d.bush_indexes then
		local indexes = {}

		for i = 1, #this.bush_frames do
			table.insert(indexes, i)
		end

		local match_idx = math.random(1, #indexes)

		table.remove(indexes, match_idx)

		d.bush_match_idx = match_idx
		d.bush_indexes = indexes
		d.bush_start_idx = math.random(1, 3)
	end

	this.bush_indexes = {
		d.bush_match_idx,
		table.remove(d.bush_indexes, math.random(1, #d.bush_indexes)),
		table.remove(d.bush_indexes, math.random(1, #d.bush_indexes))
	}
	this.bush_match_idx = 1
	this.bush_idx = d.bush_start_idx
	d.bush_start_idx = km.zmod(d.bush_start_idx + 1, #this.bush_indexes)
	this.render.sprites[1].name = this.bush_frame_prefix .. this.bush_frames[this.bush_indexes[this.bush_idx]]

	return true
end

function scripts.decal_bush_statue.update(this, store)
	while true do
		if this.ui.clicked then
			local fx = E:create_entity("fx_bush_statue_click")

			fx.pos = this.pos
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)
			U.y_wait(store, fts(5))

			this.bush_idx = km.zmod(this.bush_idx + 1, #this.bush_indexes)

			local frame = this.bush_frame_prefix .. this.bush_frames[this.bush_indexes[this.bush_idx]]

			this.render.sprites[1].name = frame

			if this.bush_idx == this.bush_match_idx then
				local all_bushes = table.filter(store.entities, function(k, v)
					return v.template_name == this.template_name
				end)

				for _, e in pairs(all_bushes) do
					if e.bush_idx ~= e.bush_match_idx then
						goto label_521_0
					end
				end

				-- AC:got("SCISSOR_FINGER")
			end

			::label_521_0::

			this.ui.clicked = nil
		end

		coroutine.yield()
	end
end

scripts.soldier_gryphon_guard = {}

function scripts.soldier_gryphon_guard.upper_ranged_filter_fn(e, origin)
	return U.is_inside_ellipse(e.pos, V.v(300, 627), 125, 0.64) or U.is_inside_ellipse(e.pos, V.v(560, 382), 95, 0.5263157894736842)
end

function scripts.soldier_gryphon_guard.lower_ranged_filter_fn(e, origin)
	return U.is_inside_ellipse(e.pos, V.v(275, 454), 175, 0.7714285714285715) or U.is_inside_ellipse(e.pos, V.v(530, 376), 150, 0.36666666666666664)
end

scripts.aura_soldier_gryphon_guard_upper = {}

function scripts.aura_soldier_gryphon_guard_upper.update(this, store)
	while true do
		local target = store.entities[this.aura.source_id]

		if not target then
			queue_remove(store, this)

			return
		end

		local attack = target.ranged.attacks[1]
		local cooldown = U.frandom(this.patch_cooldown_min, this.patch_cooldown_max)

		attack.cooldown = cooldown

		U.y_wait(store, cooldown + fts(1))
	end
end

scripts.aura_soldier_gryphon_guard_lower = {}

function scripts.aura_soldier_gryphon_guard_lower.update(this, store)
	local target = store.entities[this.aura.source_id]

	if not target then
		queue_remove(store, this)

		return
	end

	local attack = target.ranged.attacks[1]
	local hidden = true
	local last_show_ts = 0

	target.pos.x, target.pos.y = this.hide_pos.x, this.hide_pos.y
	target.nav_rally.pos = this.hide_pos
	target.nav_rally.center = this.hide_pos
	target.tween.reverse = true
	target.tween.ts = -1

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	while true do
		if hidden then
			U.y_wait(store, U.frandom(this.hidden_min, this.hidden_max))

			target.tween.reverse = false
			target.tween.ts = store.tick_ts
			target.nav_rally.pos = this.show_pos
			target.nav_rally.center = this.show
			target.nav_rally.new = true

			coroutine.yield()

			while not target.motion.arrived do
				coroutine.yield()
			end

			hidden = false
			last_show_ts = store.tick_ts
			attack.disabled = nil
		elseif store.tick_ts - math.max(attack.ts, last_show_ts) > this.idle_time_to_hide then
			attack.disabled = true
			target.tween.reverse = true
			target.tween.ts = store.tick_ts
			target.nav_rally.pos = this.hide_pos
			target.nav_rally.center = this.hide_pos
			target.nav_rally.new = true

			coroutine.yield()

			while not target.motion.arrived do
				coroutine.yield()
			end

			hidden = true
		end

		coroutine.yield()
	end
end

scripts.decal_gryphon = {}

function scripts.decal_gryphon.update(this, store)
	local flip_x = this.side == "right"
	local flip_sign = flip_x and -1 or 1
	local at = this.attacks.list[1]
	local bso = V.v(at.bullet_start_offset.x * flip_sign, at.bullet_start_offset.y)
	local beo = V.v(bso.x + 100 * flip_sign, bso.y - 140)
	local c = this.custom[this.side]
	local initial_curve = P:nodes_as_list(c.initial_curve_id)
	local default_curve = P:nodes_as_list(c.default_curve_id)
	local approach_curve = P:nodes_as_list(c.land_curve_id)
	local idle_pos = V.v(default_curve[1], default_curve[2])
	local approach_offset = V.v(-152 * flip_sign, 15)
	local default_offset = V.v(0, 0)
	local shadow_default_offset = V.v(94 * flip_sign, 0)
	local shadow_approach_offset = V.v(-28 - 30 * flip_sign, 60)
	local flash_offset = V.v(104 * flip_sign, -23)
	local sign_hidden_time = 5
	local sign_shown_time = 1
	local sign = E:create_entity("decal_gryphon_sign")

	sign.pos.x, sign.pos.y = idle_pos.x + flip_sign * 64, idle_pos.y + 5
	sign.render.sprites[1].flip_x = flip_x
	sign.tween.reverse = true
	sign.tween.ts = -1

	queue_insert(store, sign)

	this.render.sprites[4].offset = flash_offset

	local first_pass = true

	while true do
		this.render.sprites[3].offset = shadow_default_offset
		this.render.sprites[3].hidden = false

		U.animation_start_group(this, "fly", flip_x, store.tick_ts, true, "layers")

		local bez = love.math.newBezierCurve(first_pass and initial_curve or default_curve)
		local start_ts = store.tick_ts
		local t = 0
		local ari, ar = next(c.attack_ranges)
		local phase = 1

		while t <= 1 do
			this.pos.x, this.pos.y = bez:evaluate(t)
			t = (store.tick_ts - start_ts) / (first_pass and c.initial_duration or c.default_duration)

			if phase == 1 and flip_sign * this.pos.x > flip_sign * ar[1] then
				phase = phase + 1

				S:queue("ElvesGryphonsShoot")
				U.animation_start_group(this, "attack_start", flip_x, store.tick_ts, false, "layers")
			elseif phase == 2 and U.animation_finished(this) then
				phase = phase + 1

				U.animation_start_group(this, "attack_loop", flip_x, store.tick_ts, true, "layers")
			elseif phase == 3 then
				if flip_sign * this.pos.x > flip_sign * ar[2] then
					this.render.sprites[4].hidden = true
					ari, ar = next(c.attack_ranges, ari)
					phase = ar and 1 or phase + 1

					U.animation_start_group(this, "attack_end", flip_x, store.tick_ts, false, "layers")
					S:queue("ElvesGryphonsShootEnd")
				elseif flip_sign * this.pos.x > flip_sign * ar[1] and store.tick_ts - at.ts >= at.cooldown then
					at.ts = store.tick_ts
					this.render.sprites[4].hidden = nil
					this.render.sprites[4].ts = store.tick_ts

					for i = 1, at.loops do
						local b = E:create_entity(at.bullet)

						b.pos.x, b.pos.y = this.pos.x + bso.x, this.pos.y + bso.y
						b.bullet.from = V.v(b.pos.x, b.pos.y)
						b.bullet.to = V.v(this.pos.x + beo.x + U.frandom(-20, 20), this.pos.y + beo.y + U.frandom(-30, 30))
						b.initial_impulse = U.frandom(0, 1000) * 30

						queue_insert(store, b)
					end
				end
			elseif phase == 4 and U.animation_finished(this) then
				phase = phase + 1

				U.animation_start_group(this, "fly", flip_x, store.tick_ts, true, "layers")
			end

			coroutine.yield()
		end

		U.y_wait(store, first_pass and 0 or this.cooldown)

		first_pass = false
		this.render.sprites[1].offset = approach_offset
		this.render.sprites[2].offset = approach_offset
		this.render.sprites[3].offset = shadow_approach_offset

		local bez = love.math.newBezierCurve(approach_curve)
		local start_ts = store.tick_ts
		local t = 0

		while t <= 1 do
			this.pos.x, this.pos.y = bez:evaluate(t)
			t = (store.tick_ts - start_ts) / c.approach_duration

			coroutine.yield()
		end

		this.render.sprites[1].offset = default_offset
		this.render.sprites[2].offset = default_offset
		this.render.sprites[3].hidden = true

		S:queue("ElvesGryphonsLand")

		this.pos.x, this.pos.y = idle_pos.x, idle_pos.y

		U.y_animation_play_group(this, "land", flip_x, store.tick_ts, 1, "layers")
		U.animation_start_group(this, "idle", flip_x, store.tick_ts, true, "layers")

		this.ui.clicked = nil

		while not this.ui.clicked do
			local sign_cooldown = sign.tween.reverse and sign_hidden_time or sign_shown_time

			if sign_cooldown < store.tick_ts - sign.tween.ts then
				sign.tween.reverse = not sign.tween.reverse
				sign.tween.ts = store.tick_ts
			end

			coroutine.yield()
		end

		sign.tween.reverse = true
		sign.tween.ts = -1

		S:queue("ElvesGryphonsTakeOff")
		U.y_animation_play_group(this, "takeoff", flip_x, store.tick_ts, 1, "layers")
	end
end

scripts.bullet_gryphon = {}

function scripts.bullet_gryphon.update(this, store)
	local b = this.bullet
	local speed = b.max_speed

	this.render.sprites[1].ts = store.tick_ts

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
		coroutine.yield()

		b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
	end

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, b.damage_radius, b.vis_flags, b.vis_bans)

	if targets then
		for _, target in pairs(targets) do
			local d = SU.create_bullet_damage(b, target.id, this.id)

			queue_damage(store, d)
		end
	end

	this.render.sprites[1].hidden = true

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].runs = 0

		queue_insert(store, fx)
	end

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)

		decal.pos = V.vclone(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		queue_insert(store, decal)
	end

	queue_remove(store, this)
end

scripts.gryphon_controller = {}

function scripts.gryphon_controller.update(this, store)
	local cwi, cw = 0
	local wts = store.tick_ts

	::label_529_0::

	while true do
		cwi, cw = next(this.gryphon_waves, cwi)

		if not cw then
			break
		end

		while store.wave_group_number < cw.wave do
			coroutine.yield()

			wts = store.tick_ts
		end

		while store.tick_ts - wts < cw.delay do
			if store.wave_group_number ~= cw.wave then
				goto label_529_0
			end

			coroutine.yield()
		end

		local e = E:create_entity("decal_gryphon")

		e.cooldown = cw.cooldown
		e.side = cw.side

		LU.queue_insert(store, e)
	end

	queue_remove(store, this)
end

scripts.decal_s08_magic_bean = {}

function scripts.decal_s08_magic_bean.update(this, store)
	local delay = U.frandom(5, 10)
	local step = 1
	local start_ts

	::label_530_0::

	start_ts = store.tick_ts

	if step == 4 then
		S:queue("ElvesBeanGrowLoop")
	elseif step > 1 then
		S:queue("ElvesBeanGrow")
	end

	U.animation_start(this, "step" .. step, nil, store.tick_ts, false)

	while not U.animation_finished(this) do
		if step == 4 and store.tick_ts - start_ts >= fts(60) then
			S:stop("ElvesBeanGrowLoop")

			goto label_530_1
		end

		coroutine.yield()
	end

	this.ui.clicked = nil

	while not this.ui.clicked do
		if step == 1 and delay < store.tick_ts - start_ts then
			start_ts = store.tick_ts
			delay = U.frandom(5, 10)

			U.animation_start(this, "step" .. step, nil, store.tick_ts, false)
		end

		coroutine.yield()
	end

	step = step + 1

	goto label_530_0

	::label_530_1::

	U.y_wait(store, 4)

	store.player_gold = store.player_gold + this.reward_gold

	local fx = E:create_entity(this.reward_fx)

	fx.render.sprites[1].ts = store.tick_ts
	fx.pos.x, fx.pos.y = this.pos.x + 38, this.pos.y

	queue_insert(store, fx)
	-- AC:got(this.achievement_id)

	while true do
		coroutine.yield()
	end
end

scripts.decal_s08_peakaboo = {}

function scripts.decal_s08_peakaboo.update(this, store)
	local s = this.render.sprites[1]

	::label_531_0::

	s.hidden = true

	U.y_wait(store, U.frandom(30, 40))

	s.hidden = false

	if this.pos_list then
		this.pos = table.random(this.pos_list)
	end

	U.y_animation_play(this, "in", nil, store.tick_ts)

	this.ui.clicked = nil

	if U.y_wait(store, U.frandom(2, 4), function(store, time)
		return this.ui.clicked
	end) then
		-- block empty
	else
		U.y_animation_play(this, "out", nil, store.tick_ts)

		goto label_531_0
	end

	S:queue(this.sound)
	U.y_animation_play(this, "action", nil, store.tick_ts)
	-- AC:flag_check(unpack(this.achievement_flag))
	queue_remove(store, this)
end

scripts.decal_s08_hansel_gretel = {}

function scripts.decal_s08_hansel_gretel.update(this, store)
	local witch_clicks = 0
	local door_sid = 2
	local start_ts
	local witch = E:create_entity("decal_s08_witch")

	witch.inside_pos = V.v(this.pos.x + 37, this.pos.y - 45)
	witch.outside_pos = V.v(this.pos.x + 70, this.pos.y - 76)
	witch.pos.x, witch.pos.y = witch.inside_pos.x, witch.inside_pos.y
	witch.render.sprites[1].hidden = true
	witch.ui.can_click = false

	queue_insert(store, witch)

	::label_533_0::

	this.ui.clicked = nil

	while not this.ui.clicked do
		coroutine.yield()
	end

	S:queue("GUITowerOpenDoor")
	U.animation_start(this, "open", nil, store.tick_ts, false, door_sid)
	U.y_wait(store, 0.8)

	witch.render.sprites[1].hidden = nil
	witch.ui.can_click = true

	U.animation_start(witch, "walk", false, store.tick_ts, true)
	U.set_destination(witch, witch.outside_pos)

	while not witch.motion.arrived do
		U.walk(witch, store.tick_length)
		coroutine.yield()
	end

	S:queue("ElvesWitchOutside")
	U.y_animation_play(witch, "angry", nil, store.tick_ts)

	start_ts = store.tick_ts
	witch.ui.clicked = nil

	while store.tick_ts - start_ts < 3 do
		if witch.ui.clicked then
			S:queue("ElvesWitchTouch")

			witch.ui.clicked = nil
			witch_clicks = witch_clicks + 1

			if witch_clicks >= 10 then
				goto label_533_1
			else
				U.y_animation_play(witch, "click", nil, store.tick_ts)
			end
		end

		coroutine.yield()
	end

	U.animation_start(witch, "walk", true, store.tick_ts, true)
	U.set_destination(witch, witch.inside_pos)

	while not witch.motion.arrived do
		U.walk(witch, store.tick_length)
		coroutine.yield()
	end

	witch.render.sprites[1].hidden = true
	witch.ui.can_click = false

	S:queue("GUITowerOpenDoor")
	U.animation_start(this, "close", nil, store.tick_ts, false, door_sid)
	U.y_wait(store, 0.8)

	goto label_533_0

	::label_533_1::

	S:queue("ElvesWitchDeath")
	U.y_animation_play(witch, "die", nil, store.tick_ts)
	S:queue("ElvesHanselAndGretelEscape")

	for _, n in pairs({
		"hansel",
		"gretel"
	}) do
		local e = E:create_entity("decal_s08_" .. n)

		e.pos.x, e.pos.y = this.pos.x, this.pos.y
		e.tween.ts = store.tick_ts

		queue_insert(store, e)
	end

	-- AC:got("CANDY_RUSH")
end

scripts.aura_waterfall_entrance = {}

function scripts.aura_waterfall_entrance.update(this, store)
	local show_queue = {}

	while true do
		for _, e in pairs(store.entities) do
			if e.enemy and e.nav_path and e._waterfall_entrance_done ~= true then
				for _, item in pairs(this.waterfall_nodes) do
					local pi, nin, nout = item.path_id, item.from, item.to

					if pi ~= e.nav_path.pi then
						-- block empty
					elseif e.nav_path.ni == nin and e._waterfall_entrance_done == nil then
						e._waterfall_entrance_done = false

						U.sprites_hide(e)

						if e.health_bar then
							e.health_bar.hidden = true
						end
					elseif e.nav_path.ni == nout and e._waterfall_entrance_done == false then
						e._waterfall_entrance_done = true

						local fx = E:create_entity(this.show_fx)

						fx.pos.x, fx.pos.y = e.pos.x, e.pos.y - 3
						fx.render.sprites[1].ts = store.tick_ts

						queue_insert(store, fx)
						table.insert(show_queue, e)
					end
				end
			end
		end

		coroutine.yield()

		for i = #show_queue, 1, -1 do
			local e = show_queue[i]

			U.sprites_show(e)

			if e.health_bar then
				e.health_bar.hidden = nil
			end

			table.remove(show_queue, i)
		end
	end
end

scripts.decal_s09_crystal_serpent_attack = {}

function scripts.decal_s09_crystal_serpent_attack.update(this, store)
	local hids = this.holder_ids
	local towers_by_idx = {}

	for _, e in E:filter_iter(store.entities, "tower") do
		for i, hid in ipairs(hids) do
			if e.tower.holder_id == hid then
				towers_by_idx[i] = e

				log.debug(" tower %s holder:%s pos_y:%s", i, e.tower.holder_id, e.pos.y)
			end
		end
	end

	S:queue("ElvesCrystalSerpentEmerge")
	U.animation_start(this, "spawn", this.flip_x, store.tick_ts, false)
	U.y_animation_wait(this)
	S:queue("ElvesCrystalSerpentAttack", {
		delay = fts(5)
	})
	U.animation_start(this, "shootSmoke", this.flip_x, store.tick_ts, false)
	U.y_wait(store, fts(13))

	local first_dest = towers_by_idx[1].pos

	for i = 1, 3 do
		local target = towers_by_idx[i]
		local b = E:create_entity("bullet_crystal_serpent")

		b.bullet.target_id = target.id
		b.pos = this.flip_x and V.v(this.pos.x - 30, this.pos.y - 17) or V.v(this.pos.x + 33, this.pos.y - 13)
		b.bullet.from = V.vclone(b.pos)

		if i == 1 then
			b.bullet.to = V.v(first_dest.x, first_dest.y)
		else
			b.bullet.to = V.v((first_dest.x + target.pos.x) / 2, (first_dest.y + target.pos.y) / 2)
		end

		queue_insert(store, b)

		if i == 1 then
			U.y_wait(store, fts(3))
		end
	end

	U.y_animation_wait(this)
	S:queue("ElvesCrystalSerpentSubmerge", {
		delay = fts(8)
	})
	U.y_animation_play(this, "dive", this.flip_x, store.tick_ts)
	queue_remove(store, this)
end

scripts.decal_s09_crystal_serpent_scream = {}

function scripts.decal_s09_crystal_serpent_scream.update(this, store)
	S:queue("ElvesCrystalSerpentEmerge")
	U.animation_start(this, "spawn", this.flip_x, store.tick_ts, false, 1)

	this.render.sprites[3].hidden = false

	U.animation_start(this, "waterWaves", this.flip_x, store.tick_ts, true, 3)
	U.y_animation_wait(this)
	S:queue("ElvesCrystalSerpentScream")

	this.render.sprites[2].hidden = false

	U.animation_start(this, "superScream", this.flip_x, store.tick_ts, false, 1)
	U.animation_start(this, "superScreamRays", this.flip_x, store.tick_ts, false, 2)
	U.y_animation_wait(this)

	this.render.sprites[2].hidden = true

	S:queue("ElvesCrystalSerpentSubmerge", {
		delay = fts(8)
	})
	U.animation_start(this, "dive", this.flip_x, store.tick_ts, false, 1)
	U.y_wait(store, fts(19))

	this.render.sprites[3].hidden = true

	U.y_animation_wait(this)
	queue_remove(store, this)
end

scripts.bullet_crystal_serpent = {}

function scripts.bullet_crystal_serpent.update(this, store)
	local b = this.bullet

	b.ts = store.tick_ts

	local psf = E:create_entity(b.particles_name)

	psf.particle_system.track_id = this.id

	queue_insert(store, psf)

	while store.tick_ts - b.ts + store.tick_length <= b.flight_time do
		coroutine.yield()

		local phase = km.clamp(0, 1, (store.tick_ts - b.ts) / b.flight_time)

		this.pos.x = b.from.x + (b.to.x - b.from.x) * phase
		this.pos.y = b.from.y + (b.to.y - b.from.y) * phase
	end

	psf.particle_system.emit = false

	local target = store.entities[b.target_id]

	if target then
		local psh = E:create_entity("ps_bullet_crystal_serpent_hit")

		psh.pos.x, psh.pos.y = target.pos.x, target.pos.y + 20
		psh.particle_system.emit = true

		queue_insert(store, psh)
		U.y_wait(store, fts(7))

		psh.particle_system.emit = false
	end

	local wait_time

	if target and target.tower and target.tower.can_be_mod and not target.tower.blocked then
		local m = E:create_entity(b.mod)

		m.modifier.target_id = b.target_id
		m.pos.x, m.pos.y = target.pos.x, target.pos.y
		wait_time = m.modifier.duration

		queue_insert(store, m)
	end

	if wait_time then
		U.y_wait(store, wait_time)
		S:queue("ElvesCrystalSerpentBreakingCrystal")

		local s = E:create_entity("decal_s09_crystal_debris_mod")

		s.pos.x, s.pos.y = target.pos.x, target.pos.y

		U.animation_start(s, nil, nil, store.tick_ts)

		s.tween.ts = store.tick_ts

		queue_insert(store, s)
	end

	queue_remove(store, this)
end

scripts.tower_faerie_dragon = {}

function scripts.tower_faerie_dragon.get_info(this)
	return {
		desc = "ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_DESCRIPTION",
		type = STATS_TYPE_TEXT
	}
end

function scripts.tower_faerie_dragon.update(this, store)
	local a = this.attacks.list[1]
	local pow_m = this.powers.more_dragons
	local pow_i = this.powers.improve_shot
	local dragons = {}
	local egg_sids = {
		3,
		4
	}

	while true do
		if this.tower.blocked then
			-- block empty
		else
			if pow_m.changed and #dragons < 2 then
				pow_m.changed = nil

				log.debug("pow_m:%s", getdump(pow_m))

				local start = 1
				if #dragons > 0 then
					start = pow_m.level
				end
				for i = start, pow_m.level do
					local egg_sid = egg_sids[i]
					local egg_s = this.render.sprites[egg_sid]
					U.animation_start(this, "open", nil, store.tick_ts, false, egg_sid)
					U.y_wait(store, fts(5))
					local o = pow_m.idle_offsets[i]
					local e = E:create_entity("faerie_dragon")
					e.idle_pos = 0
					e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
					e.owner = this
					e.idle_pos = V.vclone(e.pos)
					queue_insert(store, e)
					table.insert(dragons, e)
				end
			end

			if pow_i.changed then
				pow_i.changed = nil
			end

			if #dragons > 0 and store.tick - a.ts > a.cooldown then
				a.ts = store.tick_ts

				local assigned_target_ids = {}

				for _, dragon in pairs(dragons) do
					if dragon.custom_attack.target_id then
						table.insert(assigned_target_ids, dragon.custom_attack.target_id)
					end
				end

				for _, dragon in pairs(dragons) do
					if dragon.custom_attack.target_id then
						-- block empty
					else
						local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.attacks.range, a.vis_flags, a.vis_bans, function(e)
							return not table.contains(assigned_target_ids, e.id)
						end)

						if not targets then
							goto label_539_0
						end

						table.sort(targets, function(e1, e2)
							local f1 = e1.unit.is_stunned
							local f2 = e2.unit.is_stunned

							if f1 then
								return false
							end

							if f2 then
								return true
							end

							return V.dist(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) < V.dist(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
						end)

						dragon.custom_attack.target_id = targets[1].id

						table.insert(assigned_target_ids, targets[1].id)
					end
				end
			end
		end

		::label_539_0::

		coroutine.yield()
	end
end

scripts.faerie_dragon = {}

function scripts.faerie_dragon.update(this, store)
	local sp = this.render.sprites[1]
	local fm = this.force_motion
	local ca = this.custom_attack
	local dest = V.vclone(this.idle_pos)
	local pred_pos, dist

	local function force_move_step(dest, max_speed, ramp_radius)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local df = (not ramp_radius or ramp_radius < dist) and 1 or math.max(dist / ramp_radius, 0.1)

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(495, V.mul(10 * df, dx, dy)))
		fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
		fm.v.x, fm.v.y = V.trim(max_speed, fm.v.x, fm.v.y)
		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = V.mul(-0.05 / store.tick_length, fm.v.x, fm.v.y)
		sp.flip_x = this.pos.x > dest.x
	end

	ca.ts = store.tick_ts
	sp.offset.y = this.flight_height

	log.debug(">>>>>>>>> START")
	U.y_animation_play(this, "rise", nil, store.tick_ts)
	log.debug(">>>>>>>>> DONE")

	while true do
		if not this.owner or not store.entities[this.owner.id] then
			queue_remove(store, this)
			return
		end

		if ca.target_id ~= nil and store.tick_ts - ca.ts > ca.cooldown then
			ca.ts = store.tick_ts

			local an, af, ai, fx
			local target = store.entities[ca.target_id]

			if not target or target.health.dead then
				-- block empty
			else
				an, af, ai = U.animation_name_facing_point(this, "fly", target.pos)

				U.animation_start(this, an, af, store.tick_ts, true)

				repeat
					target = store.entities[ca.target_id]

					if not target or target.health.dead then
						goto label_542_0
					end

					dist = V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y)
					pred_pos = P:predict_enemy_pos(target, dist / this.flight_speed_busy)
					dest.x, dest.y = pred_pos.x, pred_pos.y

					force_move_step(dest, this.flight_speed_busy)
					coroutine.yield()
				until dist < 30 or ca.target_id == nil

				if not sp.sync_flag then
					coroutine.yield()
				end

				S:queue(ca.sound)

				an, af, ai = U.animation_name_facing_point(this, ca.animation, pred_pos)

				U.animation_start(this, an, af, store.tick_ts, false)

				fx = E:create_entity("fx_faerie_dragon_shoot")
				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[1].flip_x = af
				fx.render.sprites[1].offset.y = sp.offset.y

				queue_insert(store, fx)
				U.y_wait(store, ca.shoot_time)

				do
					local so = ca.bullet_start_offset[ai]
					local b = E:create_entity(ca.bullet)

					b.pos.x, b.pos.y = this.pos.x + (af and -1 or 1) * so.x, this.pos.y + this.flight_height + so.y
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = pred_pos
					b.bullet.target_id = target.id
					b.bullet.source_id = this.id
					b.bullet.mod = b.bullet.mod .. "_l" .. this.owner.powers.improve_shot.level
					b.bullet.damage_factor = this.owner.tower.damage_factor
					if this.owner.powers.improve_shot.level > 0 then
						b.bullet.damage_min = this.owner.powers.improve_shot.damage[this.owner.powers.improve_shot.level]
						b.bullet.damage_max = this.owner.powers.improve_shot.damage[this.owner.powers.improve_shot.level]
					end

					queue_insert(store, b)
				end

				U.y_animation_wait(this)
			end

			::label_542_0::

			ca.target_id = nil
			dest.x, dest.y = this.idle_pos.x, this.idle_pos.y
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true)

		if V.dist(dest.x, dest.y, this.idle_pos.x, this.idle_pos.y) > 43 or V.dist(dest.x, dest.y, this.pos.x, this.pos.y) < 10 then
			dest = U.point_on_ellipse(this.idle_pos, 30, U.frandom(0, 2 * math.pi))
		end

		force_move_step(dest, this.flight_speed_idle, this.ramp_dist_idle)
		coroutine.yield()
	end
end

scripts.simon_controller = {}

function scripts.simon_controller.update(this, store)
	local sign_cooldown, sign_ts, sign_step, touch_count, touch_ts
	local m1 = LU.list_entities(store.entities, "simon_mushroom_1")[1]
	local m2 = LU.list_entities(store.entities, "simon_mushroom_2")[1]
	local m3 = LU.list_entities(store.entities, "simon_mushroom_3")[1]
	local m4 = LU.list_entities(store.entities, "simon_mushroom_4")[1]
	local m0 = LU.list_entities(store.entities, "simon_gnome_mushrooom_glow")[1]
	local gnome = LU.list_entities(store.entities, "simon_gnome")[1]
	local ms = {
		[0] = m0,
		m1,
		m2,
		m3,
		m4
	}
	local glow_data = {
		gnome = {
			false,
			1,
			{
				{
					0,
					0
				},
				{
					fts(9),
					255
				},
				{
					fts(18),
					0
				}
			}
		},
		hint = {
			false,
			1,
			{
				{
					0,
					0
				},
				{
					fts(9),
					128
				},
				{
					fts(18),
					0
				}
			}
		},
		start = {
			false,
			1,
			{
				{
					0,
					0
				},
				{
					fts(5),
					255
				},
				{
					fts(15),
					255
				},
				{
					fts(24),
					0
				}
			}
		},
		touch = {
			true,
			1,
			{
				{
					0,
					0
				},
				{
					fts(5),
					255
				},
				{
					fts(15),
					255
				},
				{
					fts(24),
					0
				}
			}
		},
		seq = {
			true,
			1,
			{
				{
					0,
					0
				},
				{
					fts(5),
					255
				},
				{
					fts(18),
					255
				},
				{
					fts(27),
					0
				}
			}
		},
		win = {
			false,
			1,
			{
				{
					fts(20),
					0
				},
				{
					fts(22),
					255
				},
				{
					fts(24),
					170
				},
				{
					fts(26),
					255
				},
				{
					fts(28),
					170
				},
				{
					fts(30),
					255
				},
				{
					fts(32),
					170
				},
				{
					fts(34),
					255
				},
				{
					fts(36),
					170
				},
				{
					fts(38),
					255
				},
				{
					fts(40),
					0
				}
			}
		},
		fail = {
			false,
			2,
			{
				{
					fts(3),
					0
				},
				{
					fts(8),
					255
				},
				{
					fts(13),
					255
				},
				{
					fts(20),
					0
				}
			}
		}
	}

	local function show_fx(name, delay)
		local fx = E:create_entity(name)

		fx.pos.x, fx.pos.y = gnome.pos.x, gnome.pos.y
		fx.render.sprites[1].ts = store.tick_ts + (delay or 0)

		queue_insert(store, fx)
	end

	local function glow(mi, id, overlap)
		for _, prop in pairs(ms[mi].tween.props) do
			prop.disabled = true
		end

		local has_sound, tween_id, keys = unpack(glow_data[id])
		local prop = ms[mi].tween.props[tween_id]

		prop.keys = keys
		prop.disabled = nil
		ms[mi].tween.ts = store.tick_ts

		if has_sound then
			S:queue(ms[mi].sound_events.touch)
		end

		if overlap then
			return keys[#keys][1] - fts(6)
		else
			return keys[#keys][1]
		end
	end

	local function glow_all(id)
		local delay

		for i = 1, #ms do
			delay = glow(i, id)
		end

		return delay
	end

	local function clear_touches()
		for i = 0, #ms do
			ms[i].ui.clicked = nil
		end
	end

	local function get_touched()
		for i = 0, #ms do
			if ms[i].ui.clicked then
				clear_touches()

				touch_ts = store.tick_ts

				return i
			end
		end
	end

	local function extend_seq()
		local seq = this.seq

		::label_550_0::

		local r = math.random(1, 4)

		if #seq > 0 and seq[#seq] == r then
			goto label_550_0
		end

		table.insert(seq, r)
	end

	local function reset_seq()
		this.seq = {}

		for i = 1, this.initial_sequence_length do
			extend_seq()
		end
	end

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	::label_544_0::

	reset_seq()

	::label_544_1::

	sign_ts = store.tick_ts
	sign_cooldown = U.frandom(3, 5)

	clear_touches()

	while get_touched() ~= 0 do
		if sign_cooldown < store.tick_ts - sign_ts then
			sign_ts = store.tick_ts
			sign_step = km.zmod((sign_step or 0) + 1, 3)

			if sign_step == 3 then
				show_fx("simon_gnome_sign")
			else
				glow(0, "hint")
			end
		end

		coroutine.yield()
	end

	glow(0, "gnome")
	S:queue("ElvesSimonActivate", {
		delay = fts(10)
	})
	show_fx("simon_gnome_fx", fts(29))
	U.animation_start(gnome, "play", nil, store.tick_ts, false)
	U.y_wait(store, fts(40))
	U.y_wait(store, glow_all("start") + 0.5)

	for _, id in pairs(this.seq) do
		U.y_wait(store, glow(id, "seq", true))
	end

	clear_touches()

	touch_count = 0

	while true do
		local id = get_touched()

		if id then
			if id == 0 then
				goto label_544_1
			end

			local delay = glow(id, "touch")

			U.y_wait(store, delay / 2)

			touch_count = touch_count + 1

			if id == this.seq[touch_count] then
				if touch_count == #this.seq then
					U.y_wait(store, delay / 2)
					glow_all("win")
					S:queue("ElvesSimonActivate", {
						delay = fts(10)
					})
					U.animation_start(gnome, "play", nil, store.tick_ts, false)
					U.y_wait(store, fts(27))

					local fx = E:create_entity("fx_coin_shower")

					fx.coin_count = 5
					fx.pos.x, fx.pos.y = gnome.pos.x - 4, gnome.pos.y + 10

					queue_insert(store, fx)

					store.player_gold = store.player_gold + this.reward_base + this.reward_inc * (#this.seq - this.initial_sequence_length)

					U.y_animation_wait(gnome)

					if #this.seq == this.achievement_count then
						-- AC:got(this.achievement_id)
					end

					extend_seq()

					goto label_544_1
				end
			else
				U.y_wait(store, delay / 2)
				S:queue("ElvesSimonWrong")
				U.y_wait(store, glow_all("fail"))

				goto label_544_0
			end
		end

		coroutine.yield()
	end
end

scripts.decal_s10_gnome = {}

function scripts.decal_s10_gnome.update(this, store)
	local s = this.render.sprites[1]
	local action, delay

	local function y_play(name, loops)
		loops = loops or 1

		U.animation_start(this, name, nil, store.tick_ts, loops > 1)

		while not U.animation_finished(this, nil, loops) do
			if this.ui.clicked then
				return true
			end

			coroutine.yield()
		end
	end

	local function y_walk(from, to, time)
		local an, af, ai = U.animation_name_facing_point(this, "walk", to)

		U.animation_start(this, an, af, store.tick_ts, true)

		local start_ts = store.tick_ts
		local phase = 0

		while phase < 1 do
			if this.ui.clicked then
				return true
			end

			phase = km.clamp(0, 1, (store.tick_ts - start_ts) / time)
			this.pos.x = from.x + phase * (to.x - from.x)
			this.pos.y = from.y + phase * (to.y - from.y)

			coroutine.yield()
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true)
	end

	s.flip_x = math.random() < 0.5

	::label_552_0::

	this.ui.clicked = nil
	delay = U.frandom(this.min_delay, this.max_delay)

	if U.y_wait(store, delay, function()
		return this.ui.clicked
	end) then
		-- block empty
	else
		action = table.random(this.gnome_actions)

		if action == "guitar" then
			if y_play("guitarBegin") or y_play("guitarLoop", math.random(5, 10)) or y_play("guitarEnd") then
				goto label_552_1
			end
		elseif action == "diamond" then
			if y_play("diamond") then
				goto label_552_1
			end
		elseif action == "sleep" then
			if y_play("sleepBegin") or y_play("sleepLoop", math.random(5, 10)) or y_play("sleepEnd") then
				goto label_552_1
			end
		elseif action == "teleport" then
			U.y_animation_play(this, "teleportOut", nil, store.tick_ts, false)
			U.y_wait(store, U.frandom(5, 10))
			U.y_animation_play(this, "teleportIn", nil, store.tick_ts, false)
		elseif action == "flip" then
			s.flip_x = not s.flip_x
		elseif action == "walk" then
			local from, to = unpack(this.walk_points)

			if y_walk(from, to, this.walk_time) or U.y_wait(store, U.frandom(10, 15), function()
				return this.ui.clicked
			end) or y_walk(to, from, this.walk_time) then
				goto label_552_1
			end
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true)

		goto label_552_0
	end

	::label_552_1::

	S:queue("ElvesGnomeDeathTaunt")
	U.y_animation_play(this, "explode", nil, store.tick_ts)
	-- AC:inc_check("GARGAMEL")
	U.y_wait(store, 25)

	if this.walk_points then
		this.pos.x, this.pos.y = this.walk_points[1].x, this.walk_points[1].y
	end

	U.y_animation_play(this, "teleportIn", nil, store.tick_ts, false)

	goto label_552_0
end

scripts.decal_faerie_crystal = {}

function scripts.decal_faerie_crystal.update(this, store)
	local current_color = "yellow"

	while true do
		if this.faerie_color and this.faerie_color ~= current_color then
			current_color = this.faerie_color

			U.y_wait(store, this.delay)

			this.tween.disabled = nil
			this.tween.ts = store.tick_ts
			this.tween.reverse = this.faerie_color ~= "red"
			this.render.sprites[3].name = this.faerie_color
			this.render.sprites[3].hidden = nil
			this.render.sprites[3].ts = store.tick_ts
		end

		coroutine.yield()
	end
end

scripts.faerie_trails = {}

function scripts.faerie_trails.insert(this, store)
	this.path_colors = {}
	this.sections = {}

	for pi = 1, #P.paths do
		this.path_colors[pi] = "none"

		local node_in
		local nodes = P.paths[pi][1]

		for ni = 1, #nodes do
			local npos = nodes[ni]

			if not node_in and GR:cell_is(npos.x, npos.y, TERRAIN_FAERIE) then
				node_in = ni
			elseif node_in and not GR:cell_is(npos.x, npos.y, TERRAIN_FAERIE) then
				table.insert(this.sections, {
					pi,
					node_in,
					ni
				})

				node_in = nil
			end
		end

		if node_in then
			table.insert(this.sections, {
				pi,
				node_in,
				ni
			})
		end
	end

	return true
end

function scripts.faerie_trails.update(this, store)
	local sections = this.sections

	local function is_inside_section(pi, ni)
		for _, s in pairs(sections) do
			if pi == s[1] and ni >= s[2] and ni < s[3] then
				return true
			end
		end

		return false
	end

	local function get_speed(pi)
		local path_speeds = this.path_speed_per_wave and this.path_speed_per_wave[pi]
		local speed_idx = path_speeds and path_speeds[store.wave_group_number] or 0
		local speed = this.path_speeds[speed_idx]

		return speed, speed_idx == 0 and "yellow" or "red"
	end

	while true do
		for pi = 1, #this.path_colors do
			local _, color = get_speed(pi)

			if this.path_colors[pi] ~= color then
				this.path_colors[pi] = color

				local crystals = table.filter(store.entities, function(_, e)
					return e.template_name == "decal_faerie_crystal" and e.path_id == pi
				end)

				for _, c in pairs(crystals) do
					c.faerie_color = color
					c.faerie_color_ts = store.tick_ts
				end
			end
		end

		local enemies = table.filter(store.entities, function(_, e)
			return e and e.enemy and not e.health.dead and e.main_script and e.main_script.co ~= nil and e.nav_path and is_inside_section(e.nav_path.pi, e.nav_path.ni)
		end)

		for _, enemy in pairs(enemies) do
			local speed, color = get_speed(enemy.nav_path.pi)
			local fx = E:create_entity("fx_faerie_smoke")

			fx.pos.x, fx.pos.y = enemy.pos.x, enemy.pos.y
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].scale = enemy.unit.size == UNIT_SIZE_SMALL and V.vv(0.83) or V.vv(1)
			fx.render.sprites[1].name = color

			queue_insert(store, fx)

			local f = E:create_entity("nav_faerie")

			f.pos.x, f.pos.y = enemy.pos.x, enemy.pos.y
			f.nav_path.pi, f.nav_path.spi, f.nav_path.ni = enemy.nav_path.pi, enemy.nav_path.spi, enemy.nav_path.ni
			f.motion.max_speed = speed
			f.enemy_size = enemy.unit.size
			f.enemy_offset = V.vclone(enemy.unit.mod_offset)
			f.faerie_color = color
			f.faerie_enemy = enemy

			queue_insert(store, f)
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

		local faeries = table.filter(store.entities, function(_, e)
			return e.template_name == "nav_faerie"
		end)

		for _, f in pairs(faeries) do
			local speed, color = get_speed(f.nav_path.pi)

			if is_inside_section(f.nav_path.pi, f.nav_path.ni) then
				if color ~= f.faerie_color then
					f.motion.max_speed = speed
					f.faerie_color = color
				end
			else
				queue_remove(store, f)

				local enemy = f.faerie_enemy

				enemy.pos.x, enemy.pos.y = f.pos.x, f.pos.y
				enemy.nav_path.pi, enemy.nav_path.spi, enemy.nav_path.ni = f.nav_path.pi, f.nav_path.spi, f.nav_path.ni
				enemy.main_script.runs = 1

				if enemy.ui then
					enemy.ui.can_click = true
				end

				if enemy.health_bar then
					enemy.health_bar.hidden = nil
				end

				enemy.health.ignore_damage = false

				U.sprites_show(enemy)
				SU.stun_dec(enemy, true)
				queue_insert(store, enemy)

				local fx = E:create_entity("fx_faerie_smoke")

				fx.pos.x, fx.pos.y = enemy.pos.x, enemy.pos.y
				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[1].scale = enemy.unit.size == UNIT_SIZE_SMALL and V.vv(0.83) or V.vv(1)
				fx.render.sprites[1].name = color

				queue_insert(store, fx)
			end
		end

		coroutine.yield()
	end
end

scripts.nav_faerie = {}

function scripts.nav_faerie.update(this, store)
	local enemy_is_small = this.enemy_size == UNIT_SIZE_SMALL
	local next, new, current_color
	local pss = {}

	pss.red = E:create_entity("ps_nav_faerie_red")
	pss.yellow = E:create_entity("ps_nav_faerie_yellow")
	pss.red.particle_system.emit = false
	pss.red.particle_system.track_id = this.id
	pss.yellow.particle_system.emit = false
	pss.yellow.particle_system.track_id = this.id

	queue_insert(store, pss.red)
	queue_insert(store, pss.yellow)

	for _, ps in pairs(pss) do
		ps.particle_system.scale_var = enemy_is_small and {
			0.5,
			0.5
		}
		ps.particle_system.track_offset = this.enemy_offset
	end

	for i = 1, 4 do
		this.render.sprites[i].offset = this.enemy_offset
		this.render.sprites[i].scale = enemy_is_small and V.vv(0.5) or V.vv(1)
	end

	for i = 1, 2 do
		for _, v in pairs(this.tween.props[i].keys) do
			v[2].x = v[2].x * (enemy_is_small and 0.5 or 1)
			v[2].y = v[2].y * (enemy_is_small and 0.5 or 1)
		end
	end

	while true do
		if this.faerie_color ~= current_color then
			current_color = this.faerie_color
			pss.red.particle_system.emit = current_color == "red"
			pss.yellow.particle_system.emit = current_color == "yellow"
			this.render.sprites[1].hidden = current_color ~= "red"
			this.render.sprites[3].hidden = current_color ~= "red"
			this.render.sprites[2].hidden = current_color ~= "yellow"
			this.render.sprites[4].hidden = current_color ~= "yellow"
		end

		next, new = P:next_entity_node(this, store.tick_length)

		if not next then
			log.error("(%s)nav_faerie reached goal", this.id)

			break
		end

		U.set_destination(this, next)
		U.walk(this, store.tick_length)
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.tower_pixie = {}

function scripts.tower_pixie.get_info(this)
	return {
		desc = "ELVES_TOWER_PIXIE_DESCRIPTION",
		type = STATS_TYPE_TEXT
	}
end

function scripts.tower_pixie.update(this, store)
	local a = this.attacks

	a.ts = store.tick_ts

	local pow_c = this.powers.cream
	local pow_t = this.powers.total
	local pow_plant = this.powers.plant_poison
	this.pixies = {}
	local pixies = this.pixies
	local enemy_cooldowns = {}

	local plants = pow_plant.plants
	local available_paths = {}
	for k, v in pairs(P.paths) do
		table.insert(available_paths, k)
	end
	if store.level.ignore_walk_backwards_paths then
		available_paths = table.filter(available_paths, function(k, v)
			return not table.contains(store.level.ignore_walk_backwards_paths, v)
		end)
	end
	local posAndDist2 = {}
	for i, pos in ipairs(pow_plant.pos) do
		pos.x = pos.x + this.pos.x
		pos.y = pos.y + this.pos.y
		local nearest = P:nearest_nodes(pos.x, pos.y, available_paths, nil, true)
		local pi, spi, ni = unpack(nearest[1])
		spi = 1
		local nodePos = P:node_pos(pi, spi, ni)
		local d2 = V.dist2(pos.x, pos.y, nodePos.x, nodePos.y)
		local e = {}
		e.pos = pos
		e.d2 = d2
		table.insert(posAndDist2, e)
	end
	table.sort(posAndDist2, function(e1, e2)
		return e1.d2 < e2.d2
	end)
	for i = 1, #posAndDist2 do
		pow_plant.pos[i] = posAndDist2[i].pos
	end

	local function spawn_pixie()
		local e = E:create_entity("decal_pixie")
		local po = pow_c.idle_offsets[#pixies + 1]

		e.idle_pos = po
		e.pos.x, e.pos.y = this.pos.x + po.x, this.pos.y + po.y
		e.owner = this

		table.insert(pixies, e)
		queue_insert(store, e)
	end

	spawn_pixie()

	while true do
		if this.tower.blocked then
			-- block empty
		else
			if pow_c.changed and #pixies < 3 then
				pow_c.changed = nil
				local loop = pow_c.level + 1 - #pixies
				for i = 1, loop do
					spawn_pixie()
				end
			end

			if pow_t.changed then
				pow_t.changed = nil

				for i, ch in ipairs(pow_t.chances) do
					a.list[i].chance = ch[pow_t.level]
				end
			end

			if pow_plant.changed then
				pow_plant.changed = nil
				for i = 1, pow_plant.level do
					if not plants[i] then
						local plant = E:create_entity(pow_plant.template)
						plant.pos = V.vclone(pow_plant.pos[i])
						plant.force_ready = true
						plants[i] = plant
						queue_insert(store, plant)
					end
				end
			end

			for k, v in pairs(enemy_cooldowns) do
				if v <= store.tick_ts then
					enemy_cooldowns[k] = nil
				end
			end

			if store.tick_ts - a.ts > a.cooldown then
				for _, pixie in pairs(pixies) do
					local target, attack
					local rnd, acc = math.random(), 0

					if pixie.target or store.tick_ts - pixie.attack_ts <= a.pixie_cooldown then
						-- block empty
					else
						for ii, aa in ipairs(a.list) do
							if aa.chance > 0 and rnd <= aa.chance + acc then
								attack = aa

								break
							else
								acc = acc + aa.chance
							end
						end

						if not attack then
							-- block empty
						else
							target = U.find_random_enemy(store.entities, this.pos, 0, a.range, attack.vis_flags, attack.vis_bans, function(e)
								return not table.contains(a.excluded_templates, e.template_name) and not enemy_cooldowns[e.id] and (not attack.check_gold_bag or e.enemy.gold_bag > 0)
							end)

							if not target then
								-- block empty
							else
								enemy_cooldowns[target.id] = store.tick_ts + a.enemy_cooldown
								pixie.attack_ts = store.tick_ts
								pixie.target_id = target.id
								pixie.attack = attack
								pixie.attack_level = pow_t.level
								a.ts = store.tick_ts

								break
							end
						end
					end
				end
			end
		end

		coroutine.yield()
	end
end

function scripts.tower_pixie.remove(this, store)
	local pow_plant = this.powers.plant_poison
	for i, p in ipairs(pow_plant.plants) do
		queue_remove(store, p)
		for _, f in ipairs(p.fxs_idle) do
			queue_remove(store, f)
		end
	end
	for i, p in ipairs(this.pixies) do
		queue_remove(store, p)
	end
	return true
end

scripts.decal_pixie = {}

function scripts.decal_pixie.update(this, store)
	local iflip = this.idle_flip
	local a, o, e, slot_pos, slot_flip, enemy_flip

	U.y_animation_play(this, "teleportIn", slot_flip, store.tick_ts)

	while true do
		if this.target_id ~= nil then
			local target = store.entities[this.target_id]

			if not target or target.health.dead then
				-- block empty
			else
				a = this.attack

				U.y_animation_play(this, "teleportOut", nil, store.tick_ts)
				U.y_wait(store, 0.5)
				SU.stun_inc(target)

				slot_pos, slot_flip, enemy_flip = U.melee_slot_position(this, target, 1)
				this.pos.x, this.pos.y = slot_pos.x, slot_pos.y

				U.y_animation_play(this, "teleportIn", slot_flip, store.tick_ts)
				U.animation_start(this, a.animation, nil, store.tick_ts, false)
				U.y_wait(store, 0.3)

				if a.type == "mod" then
					e = E:create_entity(a.mod)
					e.modifier.source_id = this.id
					e.modifier.target_id = target.id
					e.modifier.level = this.attack_level
				else
					e = E:create_entity(a.bullet)
					e.bullet.source_id = this.id
					e.bullet.target_id = target.id
					e.bullet.from = V.v(this.pos.x + a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y)
					e.bullet.to = V.v(target.pos.x, target.pos.y)
					e.bullet.hit_fx = e.bullet.hit_fx .. (target.unit.size >= UNIT_SIZE_MEDIUM and "big" or "small")
					e.pos = V.vclone(e.bullet.from)
				end

				queue_insert(store, e)
				U.y_animation_wait(this)
				U.y_animation_play(this, "teleportOut", nil, store.tick_ts)
				SU.stun_dec(target)

				o = this.idle_pos
				this.pos.x, this.pos.y = this.owner.pos.x + o.x, this.owner.pos.y + o.y

				U.y_animation_play(this, "teleportIn", slot_flip, store.tick_ts)
			end

			this.target_id = nil
		elseif store.tick_ts - iflip.ts > iflip.cooldown then
			U.animation_start(this, table.random(iflip.animations), math.random() < 0.5, store.tick_ts, iflip.loop)

			iflip.ts = store.tick_ts
		end

		coroutine.yield()
	end
end

scripts.decal_drow_queen_portal = {}

function scripts.decal_drow_queen_portal.update(this, store)
	local current_pack
	local pack_idx = 1
	local pi_nodes = {}
	local nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y, this.path_ids)

	for _, item in pairs(nearest_nodes) do
		pi_nodes[item[1]] = item[3] + 2
	end

	while true do
		while not this.pack do
			coroutine.yield()
		end

		current_pack = this.pack
		this.pack_finished = nil
		this.tween.ts = store.tick_ts
		this.tween.reverse = nil
		this.tween.disabled = nil

		for _, row in pairs(current_pack.waves) do
			local tn, interval, qty, sub0 = unpack(row, 1, 4)

			for i = 1, qty do
				log.debug("(%s)decal_drow_queen_portal spawning:%s", this.id, tn)

				local o = this.spawn_offsets[sub0 + 1]
				local e = E:create_entity(tn)

				e.nav_path.pi = current_pack.pi
				e.nav_path.spi = sub0 + 1
				e.nav_path.ni = pi_nodes[current_pack.pi]
				e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
				e.enemy.gold = 0

				queue_insert(store, e)

				local fx = E:create_entity("fx_drow_queen_portal")

				fx.render.sprites[1].ts = store.tick_ts
				fx.pos.x, fx.pos.y = e.pos.x, e.pos.y - 1

				queue_insert(store, fx)
				coroutine.yield()

				if interval > 0 and U.y_wait(store, fts(interval), function()
					return this.pack == nil
				end) then
					log.debug("(%s)decal_drow_queen_portal interrupted", this.id)

					goto label_571_0
				end
			end
		end

		log.debug("(%s)decal_drow_queen_portal finished", this.id)

		::label_571_0::

		this.pack = nil
		this.pack_finished = true
		this.tween.ts = store.tick_ts
		this.tween.reverse = true
		this.tween.disabled = nil
		current_pack = nil
	end
end

scripts.decal_s12_lemur = {}

function scripts.decal_s12_lemur.update(this, store)
	local clicked = false

	::label_573_0::

	this.nav_path.ni = 1
	this.pos = P:node_pos(this.nav_path)

	U.y_wait(store, U.frandom(this.wait_time[1], this.wait_time[2]))

	this.tween.ts = store.tick_ts
	this.tween.reverse = false

	while this.nav_path.ni < this.action_ni do
		SU.y_enemy_walk_step(store, this, "running", 1)
	end

	U.animation_start(this, "idle", nil, store.tick_ts, true)

	this.ui.clicked = nil

	local show_time = U.frandom(this.show_time[1], this.show_time[2])

	if U.y_wait(store, show_time, function()
		return this.ui.clicked == true
	end) then
		U.y_animation_play(this, "action", nil, store.tick_ts)
		-- AC:got(this.achievement)

		clicked = true
	end

	while SU.y_enemy_walk_step(store, this, "running", 1) do
		if not this.tween.reverse and this.nav_path.ni > this.fade_ni then
			this.tween.reverse = true
			this.tween.ts = store.tick_ts
		end
	end

	if not clicked then
		goto label_573_0
	end

	queue_remove(store, this)
end

scripts.birds_formation_controller = {}

function scripts.birds_formation_controller.update(this, store)
	while true do
		U.y_wait(store, U.frandom(this.wait_time[1], this.wait_time[2]))

		for ii, n in ipairs(this.names) do
			local o = this.offsets and this.offsets[ii] or V.v(0, 0)
			local from = V.v(this.from.x + o.x, this.from.y + o.y)
			local to = V.v(this.to.x + o.x, this.to.y + o.y)
			local e = E:create_entity(this.bird_template)

			e.render.sprites[1].name = n
			e.render.sprites[1].ts = U.frandom(0, 1)
			e.render.sprites[1].flip_x = from.x > to.x
			e.tween.props[1].keys = {
				{
					0,
					from
				},
				{
					this.time,
					to
				}
			}
			e.tween.ts = store.tick_ts

			queue_insert(store, e)
		end
	end
end

scripts.decal_metropolis_portal = {}

function scripts.decal_metropolis_portal.update(this, store)
	local function should_activate()
		local enemies = table.filter(store.entities, function(k, v)
			if v.pending_removal or not v.enemy or not v.vis or not v.nav_path or not v.health or v.health.dead or band(v.vis.flags, this.vis_bans) ~= 0 or band(v.vis.bans, this.vis_flags) ~= 0 or not P:is_node_valid(v.nav_path.pi, v.nav_path.ni) then
				return false
			end

			if this.detection_paths and not table.contains(this.detection_paths, v.nav_path.pi) then
				return false
			end

			for _, r in pairs(this.detection_rects) do
				if V.is_inside(v.pos, r) then
					return true
				end
			end

			return false
		end)

		return #enemies > 0
	end

	if this.detection_tags then
		this.detection_rects = {}

		for _, tag in pairs(this.detection_tags) do
			local es = LU.list_entities(store.entities, this.template_name, tag)

			if #es == 1 then
				local e = es[1]
				local rect = table.deepclone(e.detection_rect)

				rect.pos.x, rect.pos.y = rect.pos.x + e.pos.x, rect.pos.y + e.pos.y

				table.insert(this.detection_rects, rect)
			end
		end
	end

	while true do
		this.render.sprites[1].hidden = true

		while not should_activate() do
			coroutine.yield()
		end

		this.active = true
		this.tween.reverse = false
		this.tween.ts = store.tick_ts
		this.render.sprites[1].hidden = false

		U.y_animation_play(this, "start", nil, store.tick_ts, 1, 1)
		U.animation_start(this, "loop", nil, store.tick_ts, true, 1)

		while should_activate() or not this.render.sprites[1].sync_flag do
			coroutine.yield()
		end

		this.active = false
		this.tween.reverse = true
		this.tween.ts = store.tick_ts

		U.y_animation_play(this, "end", nil, store.tick_ts, 1, 1)
	end
end

scripts.tower_black_baby_dragon = {}

function scripts.tower_black_baby_dragon.get_info(this)
	return {
		desc = "ELVES_BABY_BERESAD_DESCRIPTION",
		type = STATS_TYPE_TEXT
	}
end

function scripts.tower_black_baby_dragon.update(this, store)
	local e = E:create_entity("decal_black_baby_dragon")

	e.pos.x, e.pos.y = this.pos.x, this.pos.y
	e.sleep_pos = V.vclone(e.pos)

	queue_insert(store, e)

	while true do
		this.ui.can_select = not e.attack_requested

		if this.user_selection.arg and not e.attack_requested then
			this.user_selection.arg = nil

			local attack = this.attacks.list[1]

			store.player_gold = store.player_gold - attack.price
			e.attack_requested = true
		end

		coroutine.yield()
	end
end

scripts.decal_black_baby_dragon = {}

function scripts.decal_black_baby_dragon.update(this, store)
	local image_x = 128
	local shadow_ref_height = 150
	local shadow_offset = 0
	local dragon_offset = V.v(-75, 40)
	local dragon_sort_offset = -80
	local ps_flame_offset = V.v(-37, 66)
	local s = this.render.sprites[1]
	local zzz = this.render.sprites[2]
	local shadow = this.render.sprites[3]
	local hit_fire = this.render.sprites[4]

	shadow.scale = V.v(1, 1)

	local wakeup_ts = 0
	local wakeup_cooldown = math.random(this.wakeup_cooldown_min, this.wakeup_cooldown_max)
	local ps_flame = E:create_entity("ps_baby_black_dragon_flame")

	ps_flame.particle_system.track_id = this.id
	ps_flame.particle_system.emit = false
	ps_flame.particle_system.track_offset = V.vclone(ps_flame_offset)
	ps_flame.particle_system.sort_y_offset = -20

	queue_insert(store, ps_flame)

	local function update_shadow()
		local dy = this.pos.y - this.sleep_pos.y
		local scale = km.clamp(0, 1, 1 - dy / shadow_ref_height)

		shadow.scale.x, shadow.scale.y = scale, scale
		shadow.offset.y = shadow_offset - dy
	end

	::label_581_0::

	while true do
		if this.attack_requested then
			shadow.hidden = true

			S:queue(this.sound_events.wakeup, {
				delay = fts(13)
			})
			U.y_animation_play(this, "wakeUp", false, store.tick_ts, 1, 1)

			s.z = Z_OBJECTS_SKY

			U.animation_start(this, "fly", true, store.tick_ts, true, 1)

			local takeoff_dest = V.v(store.visible_coords.right + image_x / 2, this.pos.y + 200)
			local takeoff_duration = 2

			U.y_ease_keys(store, {
				this.pos,
				this.pos
			}, {
				"x",
				"y"
			}, {
				this.pos.x,
				this.pos.y
			}, {
				takeoff_dest.x,
				takeoff_dest.y
			}, takeoff_duration, {
				"quad-out",
				"linear"
			})

			s.loop_forced = true

			for _, pass in pairs(this.dragon_passes) do
				this.nav_path.pi = pass.path_id
				this.nav_path.ni = 1
				this.pos = P:node_pos(this.nav_path)

				local nex, new = P:next_entity_node(this, store.tick_length)
				local flip = nex.x < this.pos.x
				local flip_sign = flip and -1 or 1
				local flame_i, flame_range = next(pass.ranges)
				local flame_on = false
				local fire_on = false
				local flame_ni_offset = 0
				local last_decal_ni, decal_ni_dist, decal_ni_offset = 0, 8, 0

				s.offset = V.v(dragon_offset.x * flip_sign, dragon_offset.y)
				s.sort_y_offset = dragon_sort_offset
				this.render.sprites[1].flip_x = not flip
				ps_flame.particle_system.track_offset.x = ps_flame_offset.x * flip_sign
				ps_flame.particle_system.emit_direction = (flip and -5 or -1) * math.pi / 6
				ps_flame.particle_system.scales_x = {
					flip_sign,
					flip_sign
				}
				hit_fire.flip_x = flip

				while nex do
					local flame_ni = this.nav_path.ni + flame_ni_offset

					if not flame_on and flame_range and flame_ni >= flame_range[1] and flame_ni <= flame_range[2] then
						S:queue(this.sound_events.fire_loop)
						S:queue(this.sound_events.fire_start)

						ps_flame.particle_system.emit = true

						U.animation_start(this, "attack", nil, store.tick_ts, true, 1)

						flame_on = true
						last_decal_ni = this.nav_path.ni - decal_ni_dist / 2
					elseif flame_on and flame_range and (flame_ni < flame_range[1] or flame_ni > flame_range[2]) then
						S:stop(this.sound_events.fire_loop)
						S:queue(this.sound_events.fire_stop)

						ps_flame.particle_system.emit = false

						U.animation_start(this, "fly", nil, store.tick_ts, true, 1)

						flame_on = false

						local fx = E:create_entity("fx_baby_black_dragon_flame_hit")

						fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
						fx.tween.ts = store.tick_ts

						queue_insert(store, fx)

						hit_fire.hidden = true
						flame_i, flame_range = next(pass.ranges, flame_i)
					end

					if flame_on and decal_ni_dist < this.nav_path.ni - last_decal_ni then
						local aura = E:create_entity(this.attacks.list[1].aura)

						aura.pos = P:node_pos(this.nav_path.pi, 1, this.nav_path.ni + decal_ni_offset)
						aura.aura.duration = U.frandom(0.8, 1.2) * aura.aura.duration
						aura.render.sprites[2].flip_x = math.random() < 0.5

						queue_insert(store, aura)

						last_decal_ni = this.nav_path.ni
						hit_fire.hidden = false
					end

					U.set_destination(this, nex)
					U.walk(this, store.tick_length)

					nex, new = P:next_entity_node(this, store.tick_length)

					coroutine.yield()
				end
			end

			s.loop_forced = false
			s.offset = V.v(0, 0)
			s.sort_y_offset = 0
			shadow.hidden = false

			update_shadow()
			U.animation_start(this, "fly", true, store.tick_ts, true, 1, true)

			this.pos.x, this.pos.y = this.sleep_pos.x, REF_H

			local a_from, a_to = this.pos.y, this.sleep_pos.y
			local approach_duration = math.floor(2.5 / fts(18)) * fts(18) + fts(10)
			local start_ts = store.tick_ts
			local phase

			repeat
				phase = (store.tick_ts - start_ts) / approach_duration
				this.pos.y = U.ease_value(a_from, a_to, phase, "quad-in")

				update_shadow()
				coroutine.yield()
			until phase >= 1

			U.y_animation_play(this, "land", false, store.tick_ts, 1, 1)
			U.animation_start(this, "idle", nil, store.tick_ts, true, 1)

			shadow.hidden = true
			s.sort_y_offset = 0
			s.z = Z_OBJECTS
			this.attack_requested = nil
		elseif wakeup_cooldown < store.tick_ts - wakeup_ts then
			S:queue(this.sound_events.wakeup, {
				delay = fts(13)
			})
			U.y_animation_play(this, "sneeze", nil, store.tick_ts, 1, 1)

			wakeup_cooldown = math.random(this.wakeup_cooldown_min, this.wakeup_cooldown_max)
			wakeup_ts = store.tick_ts
		else
			zzz.hidden = false
			zzz.alpha = 255

			U.animation_start(this, "zzz", nil, store.tick_ts, false, 2)

			while not U.animation_finished(this, 2) do
				if this.attack_requested then
					this.tween.disabled = false
					this.tween.props[1].time_offset = zzz.ts - store.tick_ts

					U.y_wait(store, this.tween.props[1].keys[2][1])

					this.tween.disabled = true

					goto label_581_0
				end

				coroutine.yield()
			end

			zzz.hidden = true
		end

		coroutine.yield()
	end
end

scripts.mod_black_baby_dragon = {}

function scripts.mod_black_baby_dragon.insert(this, store)
	if scripts.mod_dps.insert(this, store, script) then
		local target = store.entities[this.modifier.target_id]
		local d = E:create_entity("damage")

		d.source_id = this.id
		d.target_id = target.id
		d.value = this.insert_damage
		d.damage_type = this.dps.damage_type

		queue_damage(store, d)

		return true
	else
		return false
	end
end

scripts.tower_baby_ashbite = {}

function scripts.tower_baby_ashbite.get_info(this)
	local e = E:get_template("soldier_baby_ashbite")
	local b = E:get_template(e.ranged.attacks[1].bullet)
	local min, max = b.bullet.damage_min, b.bullet.damage_max

	return {
		type = STATS_TYPE_TOWER_BARRACK,
		hp_max = e.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_icon = this.info.damage_icon,
		armor = e.health.armor,
		respawn = e.health.dead_lifetime
	}
end

function scripts.tower_baby_ashbite.update(this, store)
	local b = this.barrack

	this.barrack.rally_pos = V.v(this.pos.x + b.respawn_offset.x, this.pos.y + b.respawn_offset.y)

	local s = E:create_entity(b.soldier_type)

	s.soldier.tower_id = this.id
	s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
	s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(1, b, b.max_soldiers)
	s.nav_rally.new = true

	if this.powers then
		for pn, p in pairs(this.powers) do
			s.powers[pn].level = p.level
		end
	end

	queue_insert(store, s)
	table.insert(b.soldiers, s)
	signal.emit("tower-spawn", this, s)

	while true do
		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					for _, s in pairs(b.soldiers) do
						s.powers[pn].level = p.level
						s.powers[pn].changed = true
					end
				end
			end
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

scripts.soldier_baby_ashbite = {}

function scripts.soldier_baby_ashbite.ranged_filter_fn(e, origin)
	local pp = P:predict_enemy_pos(e, fts(12))
	local allow = math.abs(pp.x - origin.x) > 30

	return allow
end

function scripts.soldier_baby_ashbite.blazing_breath_filter_fn(e, origin)
	local pp = P:predict_enemy_pos(e, 0.33 + fts(9))
	local allow = math.abs(pp.x - origin.x) > 30 and math.abs(pp.x - origin.x) < 150 and math.abs(pp.y - origin.y) < 120

	return allow
end

function scripts.soldier_baby_ashbite.get_info(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)
	local min, max = b.bullet.damage_min, b.bullet.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_icon = this.info.damage_icon,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.soldier_baby_ashbite.insert(this, store)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	if this.powers then
		for pn, p in pairs(this.powers) do
			for i = 1, p.level do
				SU.soldier_power_upgrade(this, pn)
			end
		end
	end

	this.vis._bans = this.vis.bans
	this.vis.bans = F_ALL

	return true
end

function scripts.soldier_baby_ashbite.update(this, store)
	local brk, sta

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	this.render.sprites[1].z = Z_BULLETS

	U.y_animation_play(this, "hatch", nil, store.tick_ts)

	this.render.sprites[1].z = Z_OBJECTS
	this.render.sprites[1].ts = store.tick_ts

	while true do
		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					SU.soldier_power_upgrade(this, pn)
				end
			end
		end

		if this.health.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		while this.nav_rally.new do
			if SU.y_soldier_new_rally(store, this) then
				goto label_590_0
			end
		end

		if this.ranged then
			brk, sta = SU.y_soldier_ranged_attacks(store, this)

			if brk then
				goto label_590_0
			elseif sta == A_DONE then
				SU.soldier_idle(store, this, true)
			end
		end

		if SU.soldier_go_back_step(store, this) then
			-- block empty
		else
			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_590_0::

		coroutine.yield()
	end
end

scripts.decal_emit_breath_baby_ashbite = {}

function scripts.decal_emit_breath_baby_ashbite.update(this, store)
	local start_ts = store.tick_ts
	local soldier = store.entities[this.source_id]
	local direction = V.angleTo(this.to.x - this.pos.x, this.to.y - this.pos.y)

	this.render.sprites[1].r = direction

	local emit_ps = E:create_entity(this.emit_ps)
	local mspeed = V.dist(this.to.x, this.to.y, this.pos.x, this.pos.y) / this.flight_time

	emit_ps.particle_system.emit_direction = direction
	emit_ps.particle_system.emit_speed = {
		mspeed,
		mspeed
	}
	emit_ps.particle_system.flip_x = this.to.x < this.pos.x
	emit_ps.particle_system.particle_lifetime = {
		this.flight_time,
		this.flight_time
	}
	emit_ps.particle_system.source_lifetime = this.duration
	emit_ps.pos.x, emit_ps.pos.y = this.pos.x, this.pos.y

	queue_insert(store, emit_ps)
	U.y_wait(store, this.duration, function()
		return soldier.health.dead or soldier.nav_rally.new
	end)

	emit_ps.particle_system.emit = false
	emit_ps.particle_system.source_lifetime = 0

	queue_remove(store, this)
end

scripts.aura_fiery_mist_baby_ashbite = {}

function scripts.aura_fiery_mist_baby_ashbite.update(this, store)
	local a = this.aura
	local node, spi

	a.ts = store.tick_ts

	local last_cycle_ts = store.tick_ts - a.cycle_time
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

	if #nodes < 1 then
		log.error("aura_fiery_mist_baby_ashbite: could not find node for aura")
	else
		node = {
			pi = nodes[1][1],
			spi = nodes[1][2],
			ni = nodes[1][3]
		}
		this.pos = P:node_pos(node.pi, 1, node.ni)
		spi = 1

		for i = 1, 8 do
			local ni = node.ni - 3 + i

			if P:is_node_valid(node.pi, ni) then
				local fx = E:create_entity(this.fx)

				fx.pos = P:node_pos(node.pi, spi, ni)
				fx.pos.x, fx.pos.y = fx.pos.x + math.random(-4, 4), fx.pos.y + math.random(-4, 4)

				local scale = U.frandom(0.9, 1.1)

				fx.render.sprites[1].scale = V.v(scale, scale)
				fx.render.sprites[1].time_offset = fts(i * 2)
				fx.duration = U.frandom(0.95, 1.05) * a.duration
				fx.tween.ts = store.tick_ts

				queue_insert(store, fx)
			else
				log.debug("aura_fiery_mist_baby_ashbite: path %s,%s,%s is not valid", pi, spi, ni)
			end

			spi = km.zmod(spi + 2, 3)
		end

		while true do
			if store.tick_ts - a.ts > a.duration then
				break
			end

			if store.tick_ts - last_cycle_ts > a.cycle_time then
				last_cycle_ts = store.tick_ts

				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

				if targets then
					for _, target in pairs(targets) do
						local m = E:create_entity(a.mod)

						m.modifier.target_id = target.id
						m.modifier.source_id = this.id
						m.modifier.level = a.level
						m.slow.factor = m.slow.factor + m.slow.factor_inc * a.level

						queue_insert(store, m)

						local d = E:create_entity("damage")

						d.source_id = this.id
						d.target_id = target.id

						local dmin, dmax = a.damage_min, a.damage_max

						if a.damage_inc then
							dmin = dmin + a.damage_inc * a.level
							dmax = dmax + a.damage_inc * a.level
						end

						d.value = math.random(dmin, dmax)
						d.damage_type = a.damage_type

						queue_damage(store, d)
					end
				end
			end

			coroutine.yield()
		end
	end

	queue_remove(store, this)
end

scripts.decal_s14_break_spider = {}

function scripts.decal_s14_break_spider.update(this, store)
	local c = this.click_play
	local s = this.render.sprites[1]
	local clicks = 0

	if s.scale then
		for _, p in pairs(this.tween.props[1].keys) do
			p[2].x = p[2].x * s.scale.x
			p[2].y = p[2].y * s.scale.y
		end
	end

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			clicks = clicks + 1
			this.tween.ts = store.tick_ts
		end

		if clicks > c.required_clicks then
			this.ui.can_click = false
			clicks = 0

			U.animation_start(this, "open", nil, store.tick_ts, false)
			U.y_wait(store, fts(4))

			local pis = {
				this.pi
			}
			local nodes = P:nearest_nodes(this.pos.x, this.pos.y, pis)

			for i = 1, 3 do
				local npos = P:node_pos(nodes[1][1], nodes[1][2], nodes[1][3] + 6 * (i - 2))
				local e = E:create_entity("decal_s14_break_spider")

				e.pos.x, e.pos.y = this.pos.x, this.pos.y
				e.tween.ts = store.tick_ts
				e.tween.props[2].keys[2][2] = V.v(npos.x - this.pos.x, npos.y - this.pos.y)

				queue_insert(store, e)
			end
		end

		coroutine.yield()
	end
end

scripts.decal_s15_mactans = {}

function scripts.decal_s15_mactans.update(this, store)
	local attack_ts, cooldown = 0, 0
	local attack_pending, attack_loop

	this.phase_signal = "attack"

	while true do
		if this.phase_signal == "attack" then
			this.phase_signal = nil
			attack_loop = true
			attack_pending = true
			attack_ts = store.tick_ts
		elseif this.phase_signal == "single_attack" then
			this.phase_signal = nil
			attack_ts = store.tick_ts - cooldown - 1
			attack_loop = false
			attack_pending = true
		elseif this.phase_signal == "stop" then
			this.phase_signal = nil
			attack_loop = false
			attack_pending = false
		elseif this.phase_signal == "jump_out" then
			this.phase_signal = nil

			U.y_animation_play(this, "jumpOut", nil, store.tick_ts)
			U.sprites_hide(this)

			this.phase = "out"

			while this.phase_signal ~= "jump_in" do
				coroutine.yield()
			end

			this.phase_signal = nil

			U.sprites_show(this)
			U.y_animation_play(this, "jumpIn", nil, store.tick_ts)
		elseif this.phase_signal == "jump" then
			U.y_animation_play(this, "jumpToCrystal", nil, store.tick_ts, 1)
			queue_remove(store, this)

			return
		end

		if attack_pending and cooldown < store.tick_ts - attack_ts then
			this.phase = "attack"

			S:queue("ElvesFinalBossGemattackSpider")
			U.animation_start(this, "attack", nil, store.tick_ts, false)
			U.y_wait(store, fts(11))

			this.decal_statue.phase_signal = "hit"

			U.y_animation_wait(this)

			attack_ts = store.tick_ts
			cooldown = U.frandom(4, 6)
			attack_pending = attack_loop
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true)

		this.phase = "idle"

		coroutine.yield()
	end
end

scripts.decal_s15_malicia = {}

function scripts.decal_s15_malicia.update(this, store)
	local ray = this.render.sprites[2]
	local ray_duration = U.frandom(4, 6)
	local attack_ts, cooldown = 0, 0
	local attack_pending, attack_loop

	this.phase_signal = "attack"

	while true do
		if this.phase_signal == "attack" then
			this.phase_signal = nil
			attack_loop = true
			attack_pending = true
			attack_ts = store.tick_ts
		elseif this.phase_signal == "single_attack" then
			this.phase_signal = nil
			attack_ts = store.tick_ts - cooldown - 1
			ray_duration = 2
			attack_loop = false
			attack_pending = true
		elseif this.phase_signal == "stop" then
			this.phase_signal = nil
			attack_loop = false
			attack_pending = false
		elseif this.phase_signal == "jump" then
			U.y_animation_play(this, "jumpToCrystal", nil, store.tick_ts, 1, 1)
			queue_remove(store, this)

			return
		end

		if attack_pending and cooldown < store.tick_ts - attack_ts then
			this.phase = "attack"

			S:queue("ElvesFinalBossGemattackMalicia")

			ray.hidden = false

			U.animation_start(this, "attack", nil, store.tick_ts, true, 1)
			U.y_wait(store, ray_duration, function()
				return this.phase_signal == "stop"
			end)

			ray.hidden = true
			attack_ts = store.tick_ts
			cooldown = U.frandom(5, 10)
			ray_duration = U.frandom(4, 6)
			attack_pending = attack_loop
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true, 1)

		this.phase = "idle"

		coroutine.yield()
	end
end

scripts.decal_s15_statue = {}

function scripts.decal_s15_statue.update(this, store)
	local crystal = this.render.sprites[1]

	while true do
		if this.phase_signal == "break" then
			S:queue("ElvesFinalBossGemCrystalBreak")
			U.y_animation_play(this, "break", nil, store.tick_ts)

			this.render.sprites[1].z = Z_DECALS
			this.phase = "broken"

			return
		elseif this.phase_signal == "hit" then
			this.phase_signal = nil

			U.y_animation_play(this, "hit", nil, store.tick_ts)
			U.animation_start(this, "idle", nil, store.tick_ts, true)
		end

		coroutine.yield()
	end
end

scripts.gnoll_bush_spawner = {}

function scripts.gnoll_bush_spawner.update(this, store)
	local sp = this.spawner

	while true do
		if sp.interrupt then
			-- block empty
		elseif sp.spawn_data then
			local gnoll_type = sp.spawn_data.gnollType

			sp.spawn_data = nil
			sp.count = 1

			local brk, spawns = SU.y_spawner_spawn(store, this)

			if brk then
				-- block empty
			elseif spawns and #spawns > 0 then
				spawns[1].spawner.entity = gnoll_type
				spawns[1].spawner.node_offset = this.spawn_node_offset
			end
		end

		sp.interrupt = nil
		sp.spawn_data = nil

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.gnoll_bush = {}

function scripts.gnoll_bush.update(this, store)
	local sp = this.spawner
	local original_pi = this.nav_path.pi
	local sit_node = math.random(unpack(this.walk_nodes_range))

	if this.spawner.entity ~= "enemy_gnoll_gnawer" then
		this.render.sprites[1].scale = V.v(0.8, 0.8)
	end

	while true do
		SU.y_enemy_walk_step(store, this, "walk")

		if sp.interrupt then
			sp.count = 0

			break
		elseif original_pi ~= this.nav_path.pi then
			this.spawner.pi = this.nav_path.pi
			this.spawner.ni = this.nav_path.ni

			break
		elseif sit_node <= this.nav_path.ni then
			sit_node = this.nav_path.ni + math.random(unpack(this.walk_nodes_range))

			U.y_animation_play(this, "sitDown", nil, store.tick_ts)
			U.y_wait(store, this.walk_wait)
			U.y_animation_play(this, "standUp", nil, store.tick_ts)
		end

		coroutine.yield()
	end

	U.animation_start(this, "explode", nil, store.tick_ts)
	U.y_wait(store, fts(3))

	if sp.count > 0 then
		SU.y_spawner_spawn(store, this)
	end

	S:queue("ElvesGnollTrailOut")
	U.y_animation_wait(this)
	queue_remove(store, this)
end

scripts.malik_slave_controller = {}

function scripts.malik_slave_controller.fn_can_power(this, store, power_id, pos)
	if this.ready_to_free and power_id == GUI_MODE_POWER_1 and V.is_inside(pos, this.thunder_rect) then
		this.got_thunder = true

		return true
	else
		return false
	end
end

function scripts.malik_slave_controller.update(this, store)
	local function do_thunder_fx(pos)
		local e = E:create_entity("fx_power_thunder_explosion")

		e.pos.x, e.pos.y = pos.x, pos.y
		e.render.sprites[1].ts = store.tick_ts
		e.render.sprites[2].ts = store.tick_ts

		queue_insert(store, e)

		e = E:create_entity("fx_power_thunder_explosion_decal")
		e.pos.x, e.pos.y = pos.x, pos.y
		e.render.sprites[1].ts = store.tick_ts

		queue_insert(store, e)
	end

	local function y_await_arrival(entities)
		coroutine.yield()

		for _, e in pairs(entities) do
			while not e.motion.arrived do
				coroutine.yield()
			end
		end
	end

	local function is_free()
		return this.got_thunder
	end

	while store.wave_group_number < this.starting_wave do
		coroutine.yield()
	end

	local wp = this.walk_points
	local g1 = E:create_entity("decal_gnoll_gnawer")
	local g2 = E:create_entity("decal_gnoll_gnawer")
	local m1 = E:create_entity("decal_baby_malik_slave")
	local sign = E:create_entity("decal_baby_malik_slave_banner")
	local free_seq = E:create_entity("decal_baby_malik_slave_free")
	local decals = {
		g1,
		g2,
		m1
	}

	g1.walk_points = this.walk_points.gnoll_left
	g2.walk_points = this.walk_points.gnoll_right
	m1.walk_points = this.walk_points.malik
	g1.pos = V.vclone(g1.walk_points[1])
	g2.pos = V.vclone(g2.walk_points[1])
	m1.pos = V.vclone(m1.walk_points[1])
	sign.pos = m1.pos

	queue_insert(store, g1)
	queue_insert(store, g2)
	queue_insert(store, m1)
	queue_insert(store, sign)
	queue_insert(store, free_seq)

	while true do
		for _, e in pairs(decals) do
			e.motion.arrived = false
			e.nav_grid.waypoints = table.deepclone(e.walk_points)
		end

		y_await_arrival(decals)

		this.ready_to_free = true

		U.animation_start(g1, "idle", false, store.tick_ts, true)
		U.animation_start(g2, "idle", true, store.tick_ts, true)
		U.animation_start(m1, "work", true, store.tick_ts, true)

		local t1 = U.frandom(1, 2)

		if U.y_wait(store, t1, is_free) then
			break
		end

		sign.tween.ts = store.tick_ts

		if U.y_wait(store, this.wait_time - t1, is_free) then
			break
		end

		this.ready_to_free = false

		for _, e in pairs(decals) do
			e.motion.arrived = false
			e.nav_grid.waypoints = table.reverse(e.walk_points, true)
		end

		y_await_arrival(decals)
		U.animation_start(g1, "idle", false, store.tick_ts, true)
		U.animation_start(g2, "idle", true, store.tick_ts, true)
		U.animation_start(m1, "idle", true, store.tick_ts, true)
		U.y_wait(store, this.wait_time)
		coroutine.yield()
	end

	this.ready_to_free = false

	do_thunder_fx(g1.pos)
	do_thunder_fx(g2.pos)
	U.animation_start(g1, "death", nil, store.tick_ts, false)
	U.animation_start(g2, "death", nil, store.tick_ts, false)
	U.animation_start(m1, "idle", true, store.tick_ts, true)
	U.y_wait(store, 4)

	g1.tween.ts = store.tick_ts
	g2.tween.ts = store.tick_ts
	g1.tween.disabled = nil
	g2.tween.disabled = nil
	m1.render.sprites[1].hidden = true
	free_seq.render.sprites[1].hidden = false
	free_seq.pos = m1.pos

	S:queue("ElvesMalikHammer")
	U.y_animation_play(free_seq, nil, nil, store.tick_ts)

	local hero = LU.insert_hero(store, "hero_baby_malik", this.hero_spawn_pos)

	hero.nav_grid.ignore_waypoints = true
	hero.nav_rally.new = true
	hero.nav_rally.pos = V.v(575, 557)
	hero.nav_rally.center = V.v(575, 557)

	coroutine.yield()

	free_seq.render.sprites[1].hidden = true

	-- AC:got(this.achievement_id)
	queue_remove(store, g1)
	queue_remove(store, g2)
	queue_remove(store, m1)
	queue_remove(store, sign)
	queue_remove(store, free_seq)
	queue_remove(store, this)
end

scripts.decal_walking = {}

function scripts.decal_walking.update(this, store)
	local n = this.nav_grid

	while true do
		if n.waypoints and #n.waypoints > 1 then
			local dest = n.waypoints[#n.waypoints]
			local orig = table.remove(n.waypoints, 1)

			this.pos.x, this.pos.y = orig.x, orig.y

			while not V.veq(this.pos, dest) do
				local w = table.remove(n.waypoints, 1) or dest

				U.set_destination(this, w)

				local an, af = U.animation_name_facing_point(this, "walkingRightLeft", this.motion.dest)

				U.animation_start(this, an, af, store.tick_ts, true)

				while not this.motion.arrived do
					U.walk(this, store.tick_length)
					coroutine.yield()

					this.motion.speed.x, this.motion.speed.y = 0, 0
				end
			end
		end

		coroutine.yield()
	end
end

scripts.decal_s18_roadrunner_bush = {}

function scripts.decal_s18_roadrunner_bush.update(this, store)
	local clicks = 0
	local required_clicks = math.random(this.required_clicks[1], this.required_clicks[2])
	local shake_cooldown = math.random(this.shake_cooldown[1], this.shake_cooldown[2])
	local shake_ts = store.tick_ts

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			clicks = clicks + 1

			if required_clicks <= clicks then
				local fx = E:create_entity("fx_roadruner_bush_explode")

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)

				local rr = E:create_entity("decal_s18_roadrunner")

				rr.render.sprites[1].ts = store.tick_ts

				queue_insert(store, rr)

				local coyo = E:create_entity("decal_s18_coyote")

				coyo.render.sprites[1].ts = store.tick_ts

				queue_insert(store, coyo)
				U.animation_start(coyo, "pull", nil, store.tick_ts)
				U.y_wait(store, 1.9)
				S:queue(coyo.sound_events.push)
				U.y_animation_play(coyo, "push", nil, store.tick_ts)
				-- AC:got("WILE")
				U.y_ease_key(store, coyo.render.sprites[1], "alpha", 255, 0, 0.5)
				queue_remove(store, coyo)

				return
			else
				shake_ts = -99

				S:queue(this.sound_clicked)
			end
		end

		if shake_cooldown < store.tick_ts - shake_ts then
			this.render.sprites[1].ts = store.tick_ts
			shake_ts = store.tick_ts
		end

		coroutine.yield()
	end
end

scripts.decal_s19_drizzt = {}

function scripts.decal_s19_drizzt.update(this, store)
	local idle_ts = 0
	local idle_cooldown = math.random(this.idle_cooldown[1], this.idle_cooldown[2])
	local gnoll

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil

			if gnoll and gnoll.phase == "joke" then
				gnoll.set_phase = "scared"

				S:queue(this.sound_chase, this.sound_chase_params)
				U.y_animation_play(this, "alert", nil, store.tick_ts)
				U.y_animation_play(this, "run", nil, store.tick_ts)

				break
			else
				S:queue(this.sound_clicked)
				U.y_animation_play(this, "alert", nil, store.tick_ts)
			end
		end

		if idle_cooldown < store.tick_ts - idle_ts then
			idle_ts = store.tick_ts
			this.render.sprites[1].ts = store.tick_ts

			if math.random() < 0.5 then
				idle_cooldown = math.random(this.idle_cooldown[1], this.idle_cooldown[2])
			else
				idle_cooldown = math.random(this.spawn_cooldown[1], this.spawn_cooldown[2])
				gnoll = E:create_entity("decal_s19_drizzt_gnoll")
				gnoll.pos.x, gnoll.pos.y = this.pos.x - 70, this.pos.y - 10

				queue_insert(store, gnoll)
			end
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.decal_s19_drizzt_gnoll = {}

function scripts.decal_s19_drizzt_gnoll.update(this, store)
	local out_x = this.pos.x
	local in_x = this.pos.x + 60
	local walk_time = 2
	local run_time = 0.6

	this.phase = "enter"

	U.animation_start(this, "walk", nil, store.tick_ts, true)
	U.y_ease_key(store, this.pos, "x", out_x, in_x, walk_time)

	this.phase = "joke"

	U.animation_start(this, "joke", nil, store.tick_ts, true)

	if U.y_wait(store, 2, function()
		return this.set_phase == "scared"
	end) then
		this.phase = "scared"

		U.y_animation_play(this, "scared", nil, store.tick_ts)
		U.animation_start(this, "walk", true, store.tick_ts, true)
		U.y_ease_key(store, this.pos, "x", in_x, out_x, run_time)
	else
		this.phase = "exit"

		U.animation_start(this, "idle", nil, store.tick_ts, false)
		U.y_wait(store, 1)
		U.animation_start(this, "walk", true, store.tick_ts, true)
		U.y_ease_key(store, this.pos, "x", in_x, out_x, walk_time)
	end

	queue_remove(store, this)
end

scripts.lava_fireball_controller = {}

function scripts.lava_fireball_controller.update(this, store)
	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	while not store.waves_finished do
		local start_ts, last_ts
		local wave_number = store.wave_group_number
		local active = this.launch_active[store.level_mode][wave_number]
		local cooldown_normal = this.launch_cooldown[store.level_mode]
		local cooldown_boss = this.launch_cooldown_boss
		local duration = this.duration[store.level_mode]

		log.debug("lava_fireball_controller - running wave_number:%s active:%s waves_finished:%s", wave_number, active, store.waves_finished)

		if not active then
			-- block empty
		else
			start_ts = store.tick_ts

			while duration > store.tick_ts - start_ts do
				local boss = LU.list_entities(store.entities, "eb_balrog")[1]
				local cooldown = boss and cooldown_boss or cooldown_normal

				U.y_wait(store, cooldown)

				local target = U.find_random_target(store.entities, V.v(0, 0), 0, 1e+99, F_RANGED, bor(F_ENEMY, F_FLYING))

				if target then
					local launch_pos = table.random(this.launch_points)

					SU.insert_sprite(store, this.launch_fx, launch_pos)

					local b = E:create_entity(this.bullet)

					b.pos = V.vclone(launch_pos)
					b.bullet.from = V.vclone(launch_pos)
					b.bullet.to = V.vclone(target.pos)

					queue_insert(store, b)
				end
			end
		end

		while store.wave_group_number == wave_number and not store.waves_finished do
			coroutine.yield()
		end
	end

	queue_remove(store, this)
end

scripts.decal_catapult_endless = {}

function scripts.decal_catapult_endless.update(this, store)
	local start_ts
	local a = this.ranged.attacks[1]
	local s2 = this.render.sprites[2]

	this.x_outside = this.pos.x

	while true do
		this.phase_signal = nil
		this.phase = "out"

		while this.phase_signal == nil do
			coroutine.yield()
		end

		local ms = a.munition_settings[a.munition_type]

		s2.prefix = ms[a.count == 1 and 0 or 1]
		a.bullet = ms.bullet
		this.phase = "enter"

		U.animation_start(this, "running", true, store.tick_ts, true)
		U.y_ease_key(store, this.pos, "x", this.x_outside, this.x_inside, this.transit_time)

		this.phase = "in"
		start_ts = store.tick_ts

		U.animation_start(this, "idle", true, store.tick_ts, true)

		while store.tick_ts - start_ts < this.duration do
			if store.tick_ts - a.ts > a.cooldown then
				local dest, d_pi, d_spi, d_ni, target

				if a.munition_type == 3 then
					dest, d_pi, d_spi, d_ni = P:get_random_position(a.path_margins, TERRAIN_LAND, nil, true)
				else
					local targets = table.filter(store.entities, function(k, v)
						return not v.pending_removal and v.health and not v.health.dead and v.vis and band(v.vis.flags, a.vis_bans) == 0 and band(v.vis.bans, a.vis_flags) == 0 and v.pos.x < a.max_x and v.pos.y > a.min_x
					end)

					if #targets > 0 then
						local stunned = table.filter(targets, function(k, v)
							return v.unit.is_stunned
						end)

						target = table.random(#stunned > 0 and stunned or targets)
						dest = target.pos

						local nodes = P:nearest_nodes(dest.x, dest.y)

						if #nodes > 0 then
							d_pi, d_spi, d_ni = unpack(nodes[1])
						end
					end
				end

				if not d_pi then
					log.warning("%s: node for shooting not found", this.template_name)
				else
					local an, af, ai = U.animation_name_facing_point(this, a.animation, dest)

					U.animation_start(this, an, af, store.tick_ts, false)
					U.y_wait(store, a.shoot_time)

					local n_offsets = {
						0,
						-5,
						5,
						-10,
						10
					}

					for i = 1, a.count do
						local d = P:node_pos(d_pi, d_spi, d_ni + n_offsets[i])
						local b = E:create_entity(a.bullet)

						b.pos = V.vclone(this.pos)

						local offset = a.bullet_start_offset[ai]

						b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = V.vclone(d)

						if a.munition_type == 3 then
							local e = E:create_entity(a.barrel_payloads[a.barrel_payload_idx])

							e.nav_path.pi = d_pi
							e.nav_path.spi = d_spi
							e.nav_path.ni = d_ni + 3
							b.bullet.hit_payload = e
						end

						queue_insert(store, b)
					end

					U.y_animation_wait(this)
					U.animation_start(this, "idle", nil, store.tick_ts)

					a.ts = store.tick_ts
				end
			end

			coroutine.yield()
		end

		this.phase = "exit"

		U.animation_start(this, "running", false, store.tick_ts, true)
		U.y_ease_key(store, this.pos, "x", this.x_inside, this.x_outside, this.transit_time)
	end
end

return scripts
