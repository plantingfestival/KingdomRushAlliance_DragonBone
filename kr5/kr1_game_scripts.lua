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

local function v(v1, v2)
	return {
		x = v1,
		y = v2
	}
end

local IS_PHONE = KR_TARGET == "phone"
local IS_CONSOLE = KR_TARGET == "console"

local function tpos(e)
	return e.tower and e.tower.range_offset and V.v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or e.pos
end

local SU5 = {}

function SU5.hero_get_relic(store, hero)
	if hero.relic_slot and hero.relic_slot.relic_id then
		local relic = store.entities[hero.relic_slot.relic_id]

		if relic then
			return relic
		end
	end

	return nil
end

function SU5.relic_hero_leveled(store, hero)
	local relic = SU5.hero_get_relic(store, hero)

	if relic and relic.relic.fn_level_up then
		relic.relic.fn_level_up(relic, store, hero)
	end
end

function SU5.find_towers_in_range_vis(entities, origin, attack, filter_func)
	local bans = attack.vis_bans or 0
	local flags = attack.vis_flags or 0
	local towers = table.filter(entities, function(k, v)
		return not v.pending_removal and v.tower and (not v.vis or band(v.vis.flags, bans) == 0 and band(v.vis.bans, flags) == 0) and (not attack.excluded_templates or not table.contains(attack.excluded_templates, v.template_name)) and U.is_inside_ellipse(v.pos, origin, attack.max_range) and (attack.min_range == 0 or not U.is_inside_ellipse(v.pos, origin, attack.min_range)) and (not filter_func or filter_func(v, origin, attack))
	end)

	if not towers or #towers == 0 then
		return nil
	else
		return towers
	end
end

function SU5.valid_node_interval(x, y, offset_back, offset_forward, path_width_factor, flags)
	offset_back = offset_back or 0
	offset_forward = offset_forward or 0
	path_width_factor = path_width_factor or 1

	local nodes = P:nearest_nodes(x, y, nil, nil, true, flags)

	for _, n in pairs(nodes) do
		do
			local pi, spi, ni, dist = unpack(n)

			if dist < path_width_factor * P:path_width(pi, spi, ni) then
				for off = -1, offset_back, -1 do
					if not P:is_node_valid(pi, ni + off, flags) then
						goto label_13_0
					end
				end

				for off = 1, offset_forward do
					if not P:is_node_valid(pi, ni + off, flags) then
						goto label_13_0
					end
				end

				return true
			end
		end

		::label_13_0::
	end

	return false
end

function SU5.go_to_forced_waypoint(this, store)
	if this.motion.forced_waypoint then
		local w = this.motion.forced_waypoint

		if V.dist(w.x, w.y, this.pos.x, this.pos.y) < 2 * this.motion.max_speed * store.tick_length then
			this.pos.x, this.pos.y = w.x, w.y
			this.motion.forced_waypoint = nil

			return false
		end

		U.set_destination(this, this.motion.forced_waypoint)

		local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

		U.animation_start(this, an, af, store.tick_ts, true)
		U.walk(this, store.tick_length)

		return true
	end

	return false
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

scripts.tower_ranger = {}

function scripts.tower_ranger.update(this, store)
	local shooter_sids = {
		3,
		4
	}
	local shooter_idx = 2
	local druid_sid = 5
	local a = this.attacks
	local aa = this.attacks.list[1]
	local pow_p = this.powers.poison
	local pow_t = this.powers.thorn

	aa.ts = store.tick_ts

	local function shot_animation(attack, shooter_idx, enemy)
		local ssid = shooter_sids[shooter_idx]
		local soffset = this.render.sprites[ssid].offset
		local s = this.render.sprites[ssid]
		local an, af = U.animation_name_facing_point(this, attack.animation, enemy.pos, ssid, soffset)

		U.animation_start(this, an, af, store.tick_ts, 1, ssid)

		return U.animation_name_facing_point(this, "idle", enemy.pos, ssid, soffset)
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
		b.bullet.mod = pow_p.level > 0 and pow_p.mod

		local u = UP:get_upgrade("archer_precision")

		if u and math.random() < u.chance then
			b.bullet.damage_min = b.bullet.damage_min * u.damage_factor
			b.bullet.damage_max = b.bullet.damage_max * u.damage_factor
			b.bullet.pop = {
				"pop_crit"
			}
			b.bullet.pop_conds = DR_DAMAGE
		end

		queue_insert(store, b)
	end

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if pow == pow_t and this.render.sprites[druid_sid].hidden then
						this.render.sprites[druid_sid].hidden = false

						local ta = E:create_entity(pow_t.aura)

						ta.aura.source_id = this.id
						ta.pos = tpos(this)

						queue_insert(store, ta)
					end
				end
			end

			if store.tick_ts - aa.ts > aa.cooldown then
				local enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)

				if not enemy then
					-- block empty
				else
					if pow_p.level > 0 then
						local poisonable = table.filter(enemies, function(_, e)
							return not U.flag_has(e.vis.bans, F_POISON) and not U.has_modifiers(store, e, pow_p.mod)
						end)

						if #poisonable > 0 then
							enemy = poisonable[1]
						end
					end

					aa.ts = store.tick_ts
					shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

					local idle_an, idle_af = shot_animation(aa, shooter_idx, enemy)

					U.y_wait(store, aa.shoot_time)

					if V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <= a.range then
						shot_bullet(aa, shooter_idx, enemy, pow_p.level)
					end

					U.y_animation_wait(this, shooter_sids[shooter_idx])
					U.animation_start(this, idle_an, idle_af, store.tick_ts, false, shooter_sids[shooter_idx])
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

scripts.tower_musketeer = {}

function scripts.tower_musketeer.update(this, store)
	local shooter_sids = {
		3,
		4
	}
	local shooter_idx = 2
	local a = this.attacks
	local aa = this.attacks.list[1]
	local asn = this.attacks.list[2]
	local asi = this.attacks.list[3]
	local ash = this.attacks.list[4]
	local pow_sn = this.powers.sniper
	local pow_sh = this.powers.shrapnel

	SU.towers_swaped(store, this, this.attacks.list)
	aa.ts = store.tick_ts

	local function shot_animation(attack, shooter_idx, enemy, animation)
		local ssid = shooter_sids[shooter_idx]
		local soffset = this.render.sprites[ssid].offset
		local s = this.render.sprites[ssid]
		local an, af, ai = U.animation_name_facing_point(this, animation or attack.animation, enemy.pos, ssid, soffset)

		U.animation_start(this, an, af, store.tick_ts, 1, ssid)

		return an, af, ai
	end

	local function shot_bullet(attack, shooter_idx, ani_idx, enemy, level)
		local ssid = shooter_sids[shooter_idx]
		local shooting_right = tpos(this).x < enemy.pos.x
		local soffset = this.render.sprites[ssid].offset
		local boffset = attack.bullet_start_offset[ani_idx]
		local b = E:create_entity(attack.bullet)

		b.pos.x = this.pos.x + soffset.x + boffset.x * (shooting_right and 1 or -1)
		b.pos.y = this.pos.y + soffset.y + boffset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
		b.bullet.target_id = enemy.id
		b.bullet.source_id = this.id
		b.bullet.level = level
		b.bullet.damage_factor = this.tower.damage_factor

		if attack == asn then
			local extra_damage = pow_sn.damage_factor_inc * pow_sn.level * enemy.health.hp_max

			b.bullet.damage_max = b.bullet.damage_max + extra_damage
			b.bullet.damage_min = b.bullet.damage_min + extra_damage
		end

		queue_insert(store, b)

		return b
	end

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if pow.level == 1 then
						for _, ax in pairs(a.list) do
							if ax.power_name and this.powers[ax.power_name] == pow then
								ax.ts = store.tick_ts
							end
						end
					end

					if pow == pow_sn then
						asi.chance = pow_sn.instakill_chance_inc * pow_sn.level
					end
				end
			end

			if this.tower.can_do_magic and pow_sn.level > 0 then
				for _, ax in pairs({
					asi,
					asn
				}) do
					if (ax.chance == 1 or math.random() < ax.chance) and store.tick_ts - ax.ts > ax.cooldown then
						local enemy = U.find_strongest_enemy_in_range(store.entities, tpos(this), 0, ax.range, false, ax.vis_flags, ax.vis_bans)

						if not enemy then
							break
						end

						for _, axx in pairs({
							aa,
							asi,
							asn
						}) do
							axx.ts = store.tick_ts
						end

						shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

						local seeker_idx = km.zmod(shooter_idx + 1, #shooter_sids)
						local an, af, ai = shot_animation(ax, shooter_idx, enemy)

						shot_animation(ax, seeker_idx, enemy, ax.animation_seeker)
						U.y_wait(store, ax.shoot_time)

						if V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <= ax.range then
							shot_bullet(ax, shooter_idx, ai, enemy, pow_sn.level)
						end

						U.y_animation_wait(this, shooter_sids[shooter_idx])
					end
				end
			end

			if this.tower.can_do_magic and pow_sh.level > 0 and store.tick_ts - ash.ts > ash.cooldown then
				local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, ash.range, false, ash.vis_flags, ash.vis_bans)

				if not enemy then
					-- block empty
				else
					ash.ts = store.tick_ts
					aa.ts = store.tick_ts
					shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

					local fuse_idx = km.zmod(shooter_idx + 1, #shooter_sids)
					local ssid = shooter_sids[shooter_idx]
					local fsid = shooter_sids[fuse_idx]
					local an, af, ai = shot_animation(ash, shooter_idx, enemy)

					shot_animation(ash, fuse_idx, enemy, ash.animation_seeker)

					this.render.sprites[fsid].flip_x = fuse_idx < shooter_idx
					this.render.sprites[ssid].draw_order = 5

					U.y_wait(store, ash.shoot_time)

					local shooting_right = tpos(this).x < enemy.pos.x
					local soffset = this.render.sprites[ssid].offset
					local boffset = ash.bullet_start_offset[ai]
					local dest_pos = P:predict_enemy_pos(enemy, ash.node_prediction)
					local src_pos = V.v(this.pos.x + soffset.x + boffset.x * (shooting_right and 1 or -1), this.pos.y + soffset.y + boffset.y)
					local fx = SU.insert_sprite(store, ash.shoot_fx, src_pos)

					fx.render.sprites[1].r = V.angleTo(dest_pos.x - src_pos.x, dest_pos.y - src_pos.y)

					for i = 1, ash.loops do
						local b = E:create_entity(ash.bullet)

						b.bullet.flight_time = U.frandom(b.bullet.flight_time_min, b.bullet.flight_time_max)
						b.pos = V.vclone(src_pos)
						b.bullet.from = V.vclone(src_pos)
						b.bullet.to = U.point_on_ellipse(dest_pos, U.frandom(ash.min_spread, ash.max_spread), (i - 1) * 2 * math.pi / ash.loops)
						b.bullet.level = pow_sh.level
						b.bullet.source_id = this.id

						queue_insert(store, b)
					end

					U.y_animation_wait(this, shooter_sids[shooter_idx])

					this.render.sprites[ssid].draw_order = nil
				end
			end

			if store.tick_ts - aa.ts > aa.cooldown then
				local enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)

				if not enemy then
					-- block empty
				else
					aa.ts = store.tick_ts
					shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

					local an, af, ai = shot_animation(aa, shooter_idx, enemy)

					U.y_wait(store, aa.shoot_time)

					if V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <= a.range then
						shot_bullet(aa, shooter_idx, ai, enemy, 0)
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

scripts.tower_arcane_wizard = {}

function scripts.tower_arcane_wizard.get_info(this)
	local m = E:get_template("mod_ray_arcane")
	local o = scripts.tower_common.get_info(this)

	o.type = STATS_TYPE_TOWER_MAGE
	o.damage_min = m.dps.damage_min
	o.damage_max = m.dps.damage_max
	o.damage_type = m.dps.damage_type

	return o
end

function scripts.tower_arcane_wizard.update(this, store)
	local tower_sid = 2
	local shooter_sid = 3
	local teleport_sid = 4
	local a = this.attacks
	local ar = this.attacks.list[1]
	local ad = this.attacks.list[2]
	local at = this.attacks.list[3]
	local pow_d = this.powers.disintegrate
	local pow_t = this.powers.teleport
	local last_ts = store.tick_ts

	ar.ts = store.tick_ts

	local aura = E:get_template(at.aura)
	local max_times_applied = E:get_template(aura.aura.mod).max_times_applied
	local aa, pow
	local attacks = {
		ad,
		at,
		ar
	}
	local pows = {
		pow_d,
		pow_t
	}

	local function find_target(aa)
		local target, __, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, aa.node_prediction, aa.vis_flags, aa.vis_bans, function(e)
			if aa == at then
				return e.nav_path.ni >= aa.min_nodes and (not e.enemy.counts.mod_teleport or e.enemy.counts.mod_teleport < max_times_applied)
			else
				return true
			end
		end)

		return target, pred_pos
	end

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if pow == pow_d then
						if pow.level == 1 then
							ad.ts = store.tick_ts
						end

						ad.cooldown = pow.cooldown_base + pow.cooldown_inc * pow.level
					end

					if pow == pow_t and pow.level == 1 then
						at.ts = store.tick_ts
					end
				end
			end

			for i, aa in pairs(attacks) do
				pow = pows[i]

				if (not pow or pow.level > 0) and store.tick_ts - aa.ts > aa.cooldown and store.tick_ts - last_ts > a.min_cooldown then
					local enemy, pred_pos = find_target(aa)

					if not enemy then
						-- block empty
					else
						last_ts = store.tick_ts

						local soffset = this.render.sprites[shooter_sid].offset
						local an, af, ai = U.animation_name_facing_point(this, aa.animation, enemy.pos, shooter_sid, soffset)

						U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
						U.animation_start(this, aa.animation, nil, store.tick_ts, false, tower_sid)

						if aa == at then
							this.render.sprites[teleport_sid].ts = last_ts
						end

						U.y_wait(store, aa.shoot_time)

						enemy, pred_pos = find_target(aa)

						if not enemy then
							-- block empty
						else
							aa.ts = last_ts

							local b

							if aa == at then
								b = E:create_entity(aa.aura)
								b.pos.x, b.pos.y = pred_pos.x, pred_pos.y
								b.aura.target_id = enemy.id
								b.aura.source_id = this.id
								b.aura.max_count = pow_t.max_count_base + pow_t.max_count_inc * pow_t.level
								b.aura.level = pow_t.level
							else
								b = E:create_entity(aa.bullet)
								b.pos.x, b.pos.y = this.pos.x + aa.bullet_start_offset.x, this.pos.y + aa.bullet_start_offset.y
								b.bullet.from = V.vclone(b.pos)
								b.bullet.to = V.vclone(enemy.pos)
								b.bullet.target_id = enemy.id
								b.bullet.source_id = this.id
							end

							queue_insert(store, b)
							U.y_animation_wait(this, tower_sid)
						end
					end
				end
			end

			if store.tick_ts - ar.ts > this.tower.long_idle_cooldown then
				local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

				U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
			end

			coroutine.yield()
		end
	end
end

scripts.tower_sorcerer = {}

function scripts.tower_sorcerer.update(this, store)
	local tower_sid = 2
	local shooter_sid = 3
	local polymorph_sid = 4
	local a = this.attacks
	local ab = this.attacks.list[1]
	local ap = this.attacks.list[2]
	local ab_mod = E:get_template(ab.bullet).mod
	local pow_p = this.powers.polymorph
	local pow_e = this.powers.elemental
	local ba = this.barrack
	local last_ts = store.tick_ts
	local last_soldier_pos

	SU.towers_swaped(store, this, this.attacks.list)
	ab.ts = store.tick_ts

	local aa, pow
	local attacks = {
		ap,
		ab
	}
	local pows = {
		pow_p
	}

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			if pow_p.level > 0 and pow_p.changed then
				pow_p.changed = nil

				if pow_p.level == 1 then
					ap.ts = store.tick_ts
				end

				ap.cooldown = pow_p.cooldown_base + pow_p.cooldown_inc * pow_p.level
			end

			if pow_e.level > 0 then
				if pow_e.changed then
					pow_e.changed = nil

					local s = ba.soldiers[1]

					if s and store.entities[s.id] then
						s.unit.level = pow_e.level
						s.health.armor = s.health.armor + s.health.armor_inc
						s.health.hp_max = s.health.hp_max + s.health.hp_inc
						s.health.hp = s.health.hp_max

						local ma = s.melee.attacks[1]

						ma.damage_min = ma.damage_min + ma.damage_inc
						ma.damage_max = ma.damage_max + ma.damage_inc
					end
				end

				local s = ba.soldiers[1]

				if s and s.health.dead then
					last_soldier_pos = s.pos
				end

				if not s or s.health.dead and store.tick_ts - s.health.death_ts > s.health.dead_lifetime then
					local ns = E:create_entity(ba.soldier_type)

					ns.soldier.tower_id = this.id
					ns.pos = last_soldier_pos or V.v(ba.rally_pos.x, ba.rally_pos.y)
					ns.nav_rally.pos = V.vclone(ba.rally_pos)
					ns.nav_rally.center = V.vclone(ba.rally_pos)
					ns.nav_rally.new = true
					ns.unit.level = pow_e.level
					ns.health.armor = ns.health.armor + ns.health.armor_inc * ns.unit.level
					ns.health.hp_max = ns.health.hp_max + ns.health.hp_inc * ns.unit.level

					local ma = ns.melee.attacks[1]

					ma.damage_min = ma.damage_min + ma.damage_inc * ns.unit.level
					ma.damage_max = ma.damage_max + ma.damage_inc * ns.unit.level

					queue_insert(store, ns)

					ba.soldiers[1] = ns
					s = ns
				end

				if ba.rally_new then
					ba.rally_new = false

					signal.emit("rally-point-changed", this)

					if s then
						s.nav_rally.pos = V.vclone(ba.rally_pos)
						s.nav_rally.center = V.vclone(ba.rally_pos)
						s.nav_rally.new = true

						if not s.health.dead then
							S:queue(this.sound_events.change_rally_point)
						end
					end
				end
			end

			for i, aa in pairs(attacks) do
				pow = pows[i]

				if (not pow or pow.level > 0) and store.tick_ts - aa.ts > aa.cooldown and store.tick_ts - last_ts > a.min_cooldown then
					local enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)

					if not enemy then
						-- block empty
					else
						if aa == ab then
							for _, e in pairs(enemies) do
								if not U.has_modifiers(store, e, ab_mod) then
									enemy = e

									break
								end
							end
						end

						last_ts = store.tick_ts
						aa.ts = last_ts

						local soffset = this.render.sprites[shooter_sid].offset
						local an, af, ai = U.animation_name_facing_point(this, aa.animation, enemy.pos, shooter_sid, soffset)

						U.animation_start(this, an, nil, store.tick_ts, false, shooter_sid)
						U.animation_start(this, aa.animation, nil, store.tick_ts, false, tower_sid)

						if aa == ap then
							local s_poly = this.render.sprites[polymorph_sid]

							s_poly.hidden = false
							s_poly.ts = last_ts
						end

						U.y_wait(store, aa.shoot_time)

						if aa == ap and not store.entities[enemy.id] or enemy.health.dead then
							enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)

							if not enemy or enemy.health.dead then
								goto label_18_0
							end
						end

						if V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <= a.range then
							local b
							local boffset = aa.bullet_start_offset[ai]

							b = E:create_entity(aa.bullet)
							b.pos.x, b.pos.y = this.pos.x + boffset.x, this.pos.y + boffset.y
							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = V.vclone(enemy.pos)
							b.bullet.target_id = enemy.id
							b.bullet.source_id = this.id

							queue_insert(store, b)
						end

						::label_18_0::

						U.y_animation_wait(this, tower_sid)
					end
				end
			end

			if store.tick_ts - ab.ts > this.tower.long_idle_cooldown then
				local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

				U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
			end

			coroutine.yield()
		end
	end
end

scripts.tower_bfg = {}

function scripts.tower_bfg.update(this, store, script)
	local tower_sid = 2
	local a = this.attacks
	local ab = this.attacks.list[1]
	local am = this.attacks.list[2]
	local ac = this.attacks.list[3]
	local pow_m = this.powers.missile
	local pow_c = this.powers.cluster
	local last_ts = store.tick_ts

	SU.towers_swaped(store, this, this.attacks.list)
	ab.ts = store.tick_ts

	local aa, pow
	local attacks = {
		am,
		ac,
		ab
	}
	local pows = {
		pow_m,
		pow_c
	}

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if pow == pow_m then
						am.range = am.range_base * (1 + pow_m.range_inc_factor * pow_m.level)

						if pow.level == 1 then
							am.ts = store.tick_ts
						end
					elseif pow == pow_c and pow.level == 1 then
						ac.ts = store.tick_ts
					end
				end
			end

			for i, aa in pairs(attacks) do
				pow = pows[i]

				if (not pow or pow.level > 0 and this.tower.can_do_magic) and store.tick_ts - aa.ts > aa.cooldown and (pow == pow_m or store.tick_ts - last_ts > a.min_cooldown) then
					local trigger, enemies, trigger_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, aa.range, aa.node_prediction, aa.vis_flags, aa.vis_bans)

					-- if aa == ac or aa == ab then
					-- 	if trigger then
					-- 		am.cooldown = am.cooldown_mixed
					-- 	else
					-- 		am.cooldown = am.cooldown_flying
					-- 	end
					-- end

					if not trigger then
						-- block empty
					else
						aa.ts = store.tick_ts

						if pow ~= pow_m then
							last_ts = aa.ts
						end

						U.animation_start(this, aa.animation, nil, store.tick_ts, false, tower_sid)
						U.y_wait(store, aa.shoot_time)

						local enemy, __, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, aa.range, aa.node_prediction, aa.vis_flags, aa.vis_bans)
						local dest = enemy and pred_pos or trigger_pos

						if V.dist(tpos(this).x, tpos(this).y, dest.x, dest.y) <= aa.range then
							local b = E:create_entity(aa.bullet)

							b.pos.x, b.pos.y = this.pos.x + aa.bullet_start_offset.x, this.pos.y + aa.bullet_start_offset.y
							b.bullet.damage_factor = this.tower.damage_factor
							b.bullet.from = V.vclone(b.pos)

							if aa == am then
								b.bullet.to = V.v(b.pos.x + am.launch_vector.x, b.pos.y + am.launch_vector.y)
								b.bullet.damage_max = b.bullet.damage_max + pow_m.damage_inc * pow_m.level
								b.bullet.damage_min = b.bullet.damage_min + pow_m.damage_inc * pow_m.level
							else
								b.bullet.to = dest

								if aa == ac then
									b.bullet.fragment_count = pow_c.fragment_count_base + pow_c.fragment_count_inc * pow_c.level
								end
							end

							b.bullet.target_id = enemy and enemy.id or trigger.id
							b.bullet.source_id = this.id

							queue_insert(store, b)
						end

						U.y_animation_wait(this, tower_sid)
					end
				end
			end

			U.animation_start(this, "idle", nil, store.tick_ts)
			coroutine.yield()
		end
	end
end

scripts.tower_tesla = {}

function scripts.tower_tesla.get_info(this)
	local min, max, d_type
	local b = E:get_template(this.attacks.list[1].bullet)
	local m = E:get_template(b.bullet.mod)

	d_type = m.dps.damage_type

	local bounce_factor = b.bounce_damage_factor

	min, max = b.bounce_damage_min, b.bounce_damage_max
	min, max = math.ceil(min * bounce_factor * this.tower.damage_factor), math.ceil(max * bounce_factor * this.tower.damage_factor)

	return {
		type = STATS_TYPE_TOWER,
		damage_min = min,
		damage_max = max,
		damage_type = d_type,
		range = this.attacks.range,
		cooldown = this.attacks.list[1].cooldown
	}
end

function scripts.tower_tesla.update(this, store, script)
	local tower_sid = 2
	local a = this.attacks
	local ar = this.attacks.list[1]
	local ao = this.attacks.list[2]
	local pow_b = this.powers.bolt
	local pow_o = this.powers.overcharge
	local last_ts = store.tick_ts

	ar.ts = store.tick_ts

	local aa, pow

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if pow == pow_b then
						-- block empty
					elseif pow == pow_o then
						-- block empty
					end
				end
			end

			if store.tick_ts - ar.ts > ar.cooldown then
				local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, ar.range, ar.node_prediction, ar.vis_flags, ar.vis_bans)

				if not enemy then
					-- block empty
				else
					ar.ts = store.tick_ts

					U.animation_start(this, ar.animation, nil, store.tick_ts, false, tower_sid)
					U.y_wait(store, ar.shoot_time)

					if enemy.health.dead or not store.entities[enemy.id] or not U.is_inside_ellipse(tpos(this), enemy.pos, ar.range * a.range_check_factor) then
						enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, ar.range, false, ar.vis_flags, ar.vis_bans)
					end

					if enemy then
						S:queue(ar.sound_shoot)

						local b = E:create_entity(ar.bullet)

						b.pos.x, b.pos.y = this.pos.x + ar.bullet_start_offset.x, this.pos.y + ar.bullet_start_offset.y
						b.bullet.damage_factor = this.tower.damage_factor
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
						b.bullet.target_id = enemy.id
						b.bullet.source_id = this.id
						b.bullet.level = pow_b.level

						queue_insert(store, b)
					end

					if pow_o.level > 0 then
						local b = E:create_entity(ao.aura)

						b.pos.x, b.pos.y = this.pos.x + ao.bullet_start_offset.x, this.pos.y + ao.bullet_start_offset.y
						b.aura.source_id = this.id
						b.aura.level = pow_o.level

						queue_insert(store, b)
					end

					U.y_animation_wait(this, tower_sid)
				end
			end

			U.animation_start(this, "idle", nil, store.tick_ts)
			coroutine.yield()
		end
	end
end

scripts.tower_elf_holder = {}

function scripts.tower_elf_holder.get_info()
	local tpl = E:get_template("tower_elf")
	local o = scripts.tower_barrack.get_info(tpl)

	o.respawn = nil

	return o
end

scripts.tower_sasquash_holder = {}

function scripts.tower_sasquash_holder.get_info()
	local tpl = E:get_template("tower_sasquash")
	local o = scripts.tower_barrack.get_info(tpl)

	o.respawn = nil

	return o
end

function scripts.tower_sasquash_holder.update(this, store)
	while true do
		local items = LU.list_entities(store.entities, "fx_fireball_explosion")

		if #items > 0 then
			for _, e in pairs(items) do
				if U.is_inside_ellipse(tpos(this), e.pos, this.unfreeze_radius) then
					this.tower.upgrade_to = this.unfreeze_upgrade_to

					SU.insert_sprite(store, this.unfreeze_fx, this.pos)
					queue_remove(store, this)

					return
				end
			end
		end

		coroutine.yield()
	end
end

scripts.tower_sunray = {}

function scripts.tower_sunray.get_info(this)
	local pow = this.powers.ray

	if pow.level == 0 then
		return {
			type = STATS_TYPE_TEXT,
			desc = _((this.info.i18n_key or string.upper(this.template_name)) .. "_DESCRIPTION")
		}
	else
		local a = this.attacks.list[1]
		local b = E:get_template(a.bullet).bullet
		local p = this.powers.ray
		local max = b.damage_max + b.damage_inc * math.max(1, p.level)
		local min = b.damage_min + b.damage_inc * math.max(1, p.level)
		local d_type = b.damage_type

		return {
			type = STATS_TYPE_TOWER,
			damage_min = math.ceil(min * this.tower.damage_factor),
			damage_max = math.ceil(max * this.tower.damage_factor),
			damage_type = d_type,
			range = a.range,
			cooldown = a.cooldown
		}
	end
end

function scripts.tower_sunray.can_select_point(this, x, y, store)
	return U.find_entity_at_pos(store.entities, x, y, function(e)
		return e.enemy and not e.health.dead and not U.flag_has(e.vis.bans, F_RANGED)
	end)
end

function scripts.tower_sunray.update(this, store)
	local pow = this.powers.ray
	local a = this.attacks.list[1]
	local charging = false
	local sid_shooters = {
		7,
		8,
		9,
		10
	}
	local group_tower = "tower"
	SU.towers_swaped(store, this, this.attacks.list)

	while true do
		if pow.level == 0 or this.tower.blocked then
			-- block empty
		else
			if pow.changed then
				pow.changed = nil
				a.cooldown = a.cooldown_base + a.cooldown_inc * pow.level
				a.ts = store.tick_ts - a.cooldown

				for i = 1, pow.level do
					this.render.sprites[sid_shooters[i]].hidden = false
				end

				charging = true
			end

			if store.tick_ts - a.ts < a.cooldown and not charging then
				-- this.user_selection.allowed = false
				charging = true

				U.animation_start_group(this, "charging", nil, store.tick_ts, true, group_tower)

				for i = 1, pow.level do
					this.render.sprites[sid_shooters[i]].name = "charge"
				end
			end

			if store.tick_ts - a.ts > a.cooldown then
				if charging then
					charging = false

					for i = 1, pow.level do
						this.render.sprites[sid_shooters[i]].name = "idle"
					end

					U.y_animation_play_group(this, "ready_start", nil, store.tick_ts, 1, group_tower)
					U.animation_start_group(this, "ready_idle", nil, store.tick_ts, true, group_tower)

					-- this.user_selection.allowed = true
				end

				if not charging then
					local target = U.find_strongest_enemy_in_range(store.entities, tpos(this), 0, a.range, false, a.vis_flags, a.vis_bans)
					if target then
						local start_ts = store.tick_ts
						U.animation_start_group(this, "shoot", nil, store.tick_ts, false, group_tower)
						U.y_wait(store, a.shoot_time)
						if target then
							local b = E:create_entity(a.bullet)
							b.pos.x, b.pos.y = this.pos.x + a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y
							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = V.vclone(target.pos)
							b.bullet.target_id = target.id
							b.bullet.level = pow.level
							b.bullet.damage_factor = this.tower.damage_factor
							b.render.sprites[1].scale = V.v(1, b.ray_y_scales[pow.level])
							queue_insert(store, b)
							a.ts = start_ts
						end
						U.y_animation_wait_group(this, group_tower)
					end
				end

				-- if this.user_selection.new_pos then
				-- 	local pos = this.user_selection.new_pos
				-- 	this.user_selection.new_pos = nil
				-- 	AC:inc_check("SUN_BURNER")
				-- end
			end
		end

		coroutine.yield()
	end
end

scripts.soldier_barbarian = {}

function scripts.soldier_barbarian.on_power_upgrade(this, power_name, power)
	if not this._on_power_upgrade_called then
		this._on_power_upgrade_called = true
		this.ranged.attacks[1].animation = this.ranged.attacks[1].animation .. "2"
		this.melee.attacks[1].animation = this.melee.attacks[1].animation .. "2"
		this.melee.attacks[2].animation = this.melee.attacks[2].animation .. "2"
		this.render.sprites[1].angles.walk[1] = this.render.sprites[1].angles.walk[1] .. "2"
		this.idle_flip.last_animation = this.idle_flip.last_animation .. "2"
		this.soldier.melee_slot_offset = V.v(7, 0)
	end
end

scripts.soldier_sasquash = {}

function scripts.soldier_sasquash.insert(this, store)
	if not scripts.soldier_barrack.insert(this, store) then
		return false
	end

	AC:got("HENDERSON")

	return true
end

scripts.soldier_alleria_wildcat = {}

function scripts.soldier_alleria_wildcat.level_up(this, store, skill)
	local hp_factor = GS.difficulty_soldier_hp_max_factor[store.level_difficulty]

	this.health.hp_max = skill.hp_base + skill.hp_inc * skill.level * hp_factor
	this.health.hp = this.health.hp_max

	local at = this.melee.attacks[1]

	at.damage_max = skill.damage_max_base + skill.damage_inc * skill.level
	at.damage_min = skill.damage_min_base + skill.damage_inc * skill.level
end

function scripts.soldier_alleria_wildcat.get_info(this)
	local min, max = this.melee.attacks[1].damage_min, this.melee.attacks[1].damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.owner.timed_attacks.list[1].cooldown
	}
end

function scripts.soldier_alleria_wildcat.insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.soldier_alleria_wildcat.update(this, store)
	local brk, sta

	U.y_animation_play(this, "spawn", nil, store.tick_ts)

	while true do
		if this.health.dead then
			this.owner.timed_attacks.list[1].pet = nil
			this.owner.timed_attacks.list[1].ts = store.tick_ts

			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				this.nav_grid.waypoints = GR:find_waypoints(this.pos, nil, this.nav_rally.pos, this.nav_grid.valid_terrains)

				if SU.y_hero_new_rally(store, this) then
					goto label_35_0
				end
			end

			if this.melee then
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_35_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_35_0::

		coroutine.yield()
	end
end

scripts.soldier_magnus_illusion = {}

function scripts.soldier_magnus_illusion.get_info(this)
	local a = this.ranged.attacks[1]
	local b = E:get_template(a.bullet)
	local min, max = b.bullet.damage_min, b.bullet.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_type = b.bullet.damage_type,
		damage_icon = this.info.damage_icon,
		armor = this.health.armor
	}
end

scripts.hero_gerald = {}

function scripts.hero_gerald.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	local s, sl

	s = this.hero.skills.block_counter
	sl = s.level

	if initial and s.level > 0 then
		s.level = sl
		this.dodge.chance = this.dodge.chance_base + this.dodge.chance_inc * sl
	end

	s = this.hero.skills.courage
	sl = s.level

	if initial and s.level > 0 then
		s.level = sl

		local a = this.timed_attacks.list[1]

		a.disabled = nil
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_gerald.fn_can_dodge(store, this, ranged_attack, attack, source)
	if (attack and attack.type == "area" or source and source.vis and band(source.vis.flags, F_BOSS) ~= 0) and math.random() > this.dodge.low_chance_factor then
		return false
	end

	return true
end

function scripts.hero_gerald.update(this, store)
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
			skill = this.hero.skills.block_counter

			if skill.level > 0 and this.dodge and this.dodge.active then
				this.dodge.active = false
				this.dodge.counter_attack_pending = true

				local la = this.dodge.last_attack
				local ca = this.dodge.counter_attack

				if la then
					ca.damage_max = la.damage_max * (ca.reflected_damage_factor + ca.reflected_damage_factor_inc * skill.level)
					ca.damage_min = la.damage_min * (ca.reflected_damage_factor + ca.reflected_damage_factor_inc * skill.level)
				end

				SU.hero_gain_xp_from_skill(this, skill)

				goto label_39_0
			end

			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_39_1
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.courage

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local triggers = U.find_soldiers_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans, function(e)
					return e.soldier and e.soldier.target_id
				end)

				if not triggers or #triggers < a.min_count then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					local start_ts = store.tick_ts

					S:queue(a.sound)
					U.animation_start(this, a.animation, nil, store.tick_ts)

					if SU.y_hero_wait(store, this, a.shoot_time) then
						-- block empty
					else
						local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans, function(e)
							return e.soldier
						end)

						if not targets then
							-- block empty
						else
							a.ts = start_ts

							SU.hero_gain_xp_from_skill(this, skill)

							for _, e in pairs(targets) do
								local mod = E:create_entity(a.mod)

								mod.modifier.target_id = e.id
								mod.modifier.source_id = this.id
								mod.modifier.level = skill.level

								queue_insert(store, mod)
							end

							SU.y_hero_animation_wait(this)

							goto label_39_1
						end
					end
				end
			end

			::label_39_0::

			brk, sta = y_hero_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			elseif SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_39_1::

		coroutine.yield()
	end
end

scripts.hero_alleria = {}

function scripts.hero_alleria.level_up(this, store, initial)
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

	local s, sl

	s = this.hero.skills.multishot
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.ranged.attacks[2]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.extra_arrows = s.count_base + s.count_inc * sl
	end

	s = this.hero.skills.callofwild
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.timed_attacks.list[1]

		a.disabled = nil

		if a.pet then
			a.pet.level = s.level

			a.pet.fn_level_up(a.pet, store, s)
		end
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_alleria.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	local function get_wildcat_pos()
		local positions = P:get_all_valid_pos(this.nav_rally.pos.x, this.nav_rally.pos.y, a.min_range, a.max_range, TERRAIN_LAND, nil, NF_RALLY)

		return positions[1]
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
				a = this.timed_attacks.list[1]

				if a.pet then
					local pos = get_wildcat_pos()

					if pos then
						a.pet.nav_rally.center = pos
						a.pet.nav_rally.pos = pos
						a.pet.nav_rally.new = true
					end
				end

				if SU.y_hero_new_rally(store, this) then
					goto label_43_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.callofwild

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				if a.pet then
					SU.delay_attack(store, a, 0.25)
				else
					local spawn_pos = get_wildcat_pos()

					if not spawn_pos then
						SU.delay_attack(store, a, 0.25)
					else
						S:queue(a.sound)
						U.animation_start(this, a.animation, nil, store.tick_ts)
						U.y_wait(store, a.spawn_time)

						local e = E:create_entity(a.entity)

						e.pos = V.vclone(spawn_pos)
						e.nav_rally.pos = V.vclone(spawn_pos)
						e.nav_rally.center = V.vclone(spawn_pos)
						e.render.sprites[1].flip_x = math.random() < 0.5
						e.owner = this

						e.fn_level_up(e, store, skill)
						queue_insert(store, e)

						a.pet = e

						U.y_animation_wait(this)

						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						goto label_43_0
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

		::label_43_0::

		coroutine.yield()
	end
end

scripts.hero_bolin = {}

function scripts.hero_bolin.get_info(this)
	local a = this.timed_attacks.list[1]
	local b = E:get_template(a.bullet)
	local min, max = b.bullet.damage_min, b.bullet.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = math.ceil(this.unit.damage_factor * min),
		damage_max = math.ceil(this.unit.damage_factor * max),
		damage_type = b.bullet.damage_type,
		damage_icon = this.info.damage_icon,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_bolin.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local rf = this.timed_attacks.list[1]
	local b = E:get_template(rf.bullet)

	b.bullet.damage_min = ls.ranged_damage_min[hl]
	b.bullet.damage_max = ls.ranged_damage_max[hl]

	local s, sl

	s = this.hero.skills.tar
	sl = s.level

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local tar = E:get_template("aura_bolin_tar")

		tar.duration = s.duration[sl]
	end

	s = this.hero.skills.mines
	sl = s.level

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[3]

		a.disabled = nil

		local m = E:get_template("decal_bolin_mine")

		m.damage_min = s.damage_min[sl]
		m.damage_max = s.damage_max[sl]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_bolin.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta
	local shoot_count = 0

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

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
					goto label_47_0
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.tar

			if not a.disabled and store.tick_ts - a.ts >= a.cooldown then
				local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					SU.delay_attack(store, a, 0.5)
				else
					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + 5

					if not P:is_node_valid(pi, ni) then
						ni = target.nav_path.ni
					end

					if not P:is_node_valid(pi, ni) then
						SU.delay_attack(store, a, 0.5)
					else
						local start_ts = store.tick_ts
						local flip = target.pos.x < this.pos.x

						U.animation_start(this, "tar", flip, store.tick_ts)
						SU.hero_gain_xp_from_skill(this, skill)

						if U.y_wait(store, a.shoot_time, function()
							return SU.hero_interrupted(this)
						end) then
							-- block empty
						else
							a.ts = start_ts

							local af = this.render.sprites[1].flip_x
							local b = E:create_entity(a.bullet)
							local o = a.bullet_start_offset

							b.bullet.from = V.v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
							b.bullet.to = P:node_pos(pi, spi, ni)
							b.pos = V.vclone(b.bullet.from)
							b.bullet.source_id = this.id

							queue_insert(store, b)

							if not U.y_animation_wait(this) then
								goto label_47_0
							end
						end
					end
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.mines

			if not a.disabled and store.tick_ts - a.ts >= a.cooldown then
				local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

				if not nearest or #nearest < 1 then
					SU.delay_attack(store, a, 0.5)
				else
					local pi, spi, ni = unpack(nearest[1])

					spi = math.random(1, 3)

					local no = math.random(a.node_offset[1], a.node_offset[2])

					ni = ni + no

					if not P:is_node_valid(pi, ni) then
						ni = ni - no
					end

					local start_ts = store.tick_ts
					local mine_pos = P:node_pos(pi, spi, ni)
					local flip = mine_pos.x < this.pos.x

					U.animation_start(this, "mine", flip, store.tick_ts)
					SU.hero_gain_xp_from_skill(this, skill)

					if U.y_wait(store, a.shoot_time, function()
						return SU.hero_interrupted(this)
					end) then
						-- block empty
					else
						a.ts = start_ts

						local af = this.render.sprites[1].flip_x
						local b = E:create_entity(a.bullet)
						local o = a.bullet_start_offset

						b.bullet.from = V.v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
						b.bullet.to = mine_pos
						b.pos = V.vclone(b.bullet.from)
						b.bullet.source_id = this.id

						queue_insert(store, b)

						if not U.y_animation_wait(this) then
							goto label_47_0
						end
					end
				end
			end
			
			brk, sta = y_hero_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			else
				a = this.timed_attacks.list[1]

				if store.tick_ts - a.ts >= a.cooldown then
					local target, _, pred_pos = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, a.filter_fn, F_FLYING)

					if not target then
						-- block empty
					else
						local flip = target.pos.x < this.pos.x
						local b, an, af, ai

						an, af, ai = U.animation_name_facing_point(this, a.aim_animation, target.pos)

						U.animation_start(this, an, af, store.tick_ts, 1)
						U.set_destination(this, this.pos)

						for si, st in pairs(a.shoot_times) do
							if U.y_wait(store, a.shoot_times[si], function()
								return SU.hero_interrupted(this)
							end) then
								goto label_47_0
							end

							if not target then
								-- block empty
							end

							local target_dist = V.dist(target.pos.x, target.pos.y, this.pos.x, this.pos.y)

							if si > 1 and (not target or target.health.death or not target_dist or not (target_dist >= a.min_range) or target_dist <= a.max_range or true) then
								target, _, pred_pos = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, a.filter_fn, F_FLYING)

								if not target then
									break
								end
							end

							an, af, ai = U.animation_name_facing_point(this, a.shoot_animation, target.pos)

							U.animation_start(this, an, af, store.tick_ts, 1)

							if U.y_wait(store, a.shoot_time, function()
								return SU.hero_interrupted(this)
							end) then
								goto label_47_0
							end

							b = E:create_entity(a.bullet)
							b.pos = V.vclone(this.pos)

							if a.bullet_start_offset then
								local offset = a.bullet_start_offset[ai]

								b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
							end

							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
							b.bullet.target_id = target.id
							b.bullet.shot_index = si
							b.bullet.source_id = this.id
							b.bullet.xp_dest_id = this.id
							b.bullet.damage_factor = this.unit.damage_factor

							queue_insert(store, b)
						end

						U.y_animation_wait(this)

						a.ts = store.tick_ts

						U.animation_start(this, "reload", nil, store.tick_ts)

						if U.y_animation_wait(this) then
							goto label_47_0
						end
					end
				end

				if SU.soldier_go_back_step(store, this) then
					-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_47_0::

		coroutine.yield()
	end
end

scripts.decal_bolin_mine = {}

function scripts.decal_bolin_mine.update(this, store)
	local ts = store.tick_ts

	while true do
		if store.tick_ts - ts >= this.duration then
			break
		end

		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.trigger_radius, this.vis_flags, this.vis_bans)

		if targets and #targets > 0 then
			local dec = E:create_entity(this.hit_decal)

			dec.pos = V.vclone(this.pos)
			dec.render.sprites[1].ts = store.tick_ts

			queue_insert(store, dec)
			S:queue(this.sound)

			local fx = E:create_entity(this.hit_fx)

			fx.pos = V.vclone(this.pos)
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)

			targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.explosion_radius, this.vis_flags, this.vis_bans)
			for _, t in ipairs(targets) do
				local d = E:create_entity("damage")

				d.damage_type = this.damage_type
				d.source_id = this.id
				d.target_id = t.id
				d.value = math.random(this.damage_min, this.damage_max)

				queue_damage(store, d)
			end

			break
		end

		U.y_wait(store, this.check_interval)
	end

	queue_remove(store, this)
end

scripts.hero_denas = {}

function scripts.hero_denas.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	for _, b in pairs(this.timed_attacks.list[1].bullets) do
		local bt = E:get_template(b)

		bt.bullet.damage_min = ls.ranged_damage_min[hl]
		bt.bullet.damage_max = ls.ranged_damage_max[hl]
	end

	for _, b in pairs(this.ranged.attacks[1].bullets) do
		local bt = E:get_template(b)

		bt.bullet.damage_min = ls.ranged_damage_min[hl]
		bt.bullet.damage_max = ls.ranged_damage_max[hl]
	end

	s = this.hero.skills.tower_buff
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[sl]
	end

	s = this.hero.skills.catapult
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.timed_attacks.list[3]

		a.disabled = nil

		local c = E:get_template(a.entity)

		c.count = s.count[sl]

		local r = E:get_template(c.bullet)

		r.bullet.damage_min = s.damage_min[sl]
		r.bullet.damage_max = s.damage_max[sl]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_denas.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta, target, pred_pos
	local rock_flight_time = E:get_template("denas_catapult_rock").bullet.flight_time

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	local function do_denas_attack(target, attack, pred_pos)
		local bullet
		local bullet_to = pred_pos or target.pos
		local bullet_to_start = V.vclone(bullet_to)
		local bidx = math.random(1, #a.animations)
		local animation = attack.animations[bidx]
		local bullet_name = attack.bullets[bidx]
		local an, af, ai = U.animation_name_facing_point(this, animation, bullet_to)

		local upg = UP:get_upgrade("heroes_lethal_focus")
		local triggered_lethal_focus = false

		if attack.basic_attack and upg then
			if not this._lethal_focus_deck then
				this._lethal_focus_deck = SU.deck_new(upg.trigger_cards, upg.total_cards)
			end
	
			triggered_lethal_focus = SU.deck_draw(this._lethal_focus_deck)
		end

		U.animation_start(this, an, af, store.tick_ts, false)

		if SU.y_hero_wait(store, this, a.shoot_time) then
			return false
		end

		bullet = E:create_entity(bullet_name)
		bullet.pos = V.vclone(this.pos)

		if triggered_lethal_focus then
			if bullet.bullet.damage_radius > 0 then
				bullet.bullet.damage_factor = this.unit.damage_factor * upg.damage_factor_area
			else
				bullet.bullet.damage_factor = this.unit.damage_factor * upg.damage_factor
			end
	
			bullet.bullet.pop = {
				"pop_crit"
			}
			bullet.bullet.pop_conds = DR_DAMAGE
		elseif bullet.bullet.use_unit_damage_factor then
			bullet.bullet.damage_factor = this.unit.damage_factor
		end

		if attack.bullet_start_offset then
			local offset = attack.bullet_start_offset[ai]

			bullet.pos.x, bullet.pos.y = bullet.pos.x + (af and -1 or 1) * offset.x, bullet.pos.y + offset.y
		end

		bullet.bullet.from = V.vclone(bullet.pos)
		bullet.bullet.to = V.vclone(bullet_to)
		bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
		bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
		bullet.bullet.target_id = target.id
		bullet.bullet.source_id = this.id
		bullet.bullet.xp_dest_id = this.id
		bullet.bullet.level = attack.level

		queue_insert(store, bullet)

		if U.y_animation_wait(this) then
			return false
		end

		return true
	end

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_54_0
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.tower_buff

			if not a.disabled and store.tick_ts - a.ts >= a.cooldown then
				local towers = U.find_towers_in_range(store.entities, this.pos, a, function(t)
					return t.tower.can_be_mod and not U.has_modifiers(store, t, a.mod) and t.attacks and t.attacks.list[1] and t.attacks.list[1].cooldown and 
					t.tower.kind ~= TOWER_KIND_BARRACK
				end)

				if not towers or #towers <= 0 then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					local start_ts = store.tick_ts

					S:queue(a.sound)
					U.animation_start(this, a.animation, nil, store.tick_ts, 1)

					if SU.y_hero_wait(store, this, a.curse_time) then
						goto label_54_0
					end

					local curse = E:create_entity("denas_cursing")

					curse.source_id = this.id

					queue_insert(store, curse)

					if SU.y_hero_wait(store, this, a.cast_time - a.curse_time) then
						goto label_54_0
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local au = E:create_entity(a.aura)

					au.aura.target_id = this.id
					au.aura.source_id = this.id

					queue_insert(store, au)

					for _, t in ipairs(towers) do
						local m = E:create_entity(a.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = t.id

						queue_insert(store, m)
					end

					SU.y_hero_animation_wait(this)

					goto label_54_0
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.catapult

			if not a.disabled and store.tick_ts - a.ts >= a.cooldown then
				local target = U.find_enemy_with_search_type(store.entities, this.pos, a.min_range, a.max_range, nil, a.vis_flags, a.vis_bans, nil, nil, a.search_type, a.crowd_range, a.min_targets)

				if not target then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					local start_ts = store.tick_ts
					local flip = target.pos.x < this.pos.x

					S:queue(a.sound)
					U.animation_start(this, a.animation, flip, store.tick_ts)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto label_54_0
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local n_off = P:predict_enemy_node_advance(target, rock_flight_time + a.cast_time)

					if P:is_node_valid(pi, ni + n_off) then
						ni = ni + n_off
					end

					local pos = P:node_pos(pi, 1, ni)
					local e = E:create_entity(a.entity)

					e.pos = pos

					queue_insert(store, e)
					SU.y_hero_animation_wait(this)

					goto label_54_0
				end
			end

			a = this.timed_attacks.list[1]
			target = SU.soldier_pick_melee_target(store, this)

			if target then
				if SU.soldier_move_to_slot_step(store, this, target) then
					-- block empty
				elseif store.tick_ts - a.ts < a.cooldown then
					-- block empty
				else
					a.ts = store.tick_ts

					do_denas_attack(target, a)
				end
			else
				target, a, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)

				if target and a then
					U.set_destination(this, this.pos)

					a.ts = store.tick_ts

					if not do_denas_attack(target, a, pred_pos) then
						goto label_54_0
					end
				end

				if SU.soldier_go_back_step(store, this) then
					-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_54_0::

		coroutine.yield()
	end
end

scripts.denas_catapult_controller = {}

function scripts.denas_catapult_controller.update(this, store)
	local w = store.visible_coords.right - store.visible_coords.left
	local rock_x = this.pos.x > w / 2 and store.visible_coords.right + this.rock_offset.x or store.visible_coords.left - this.rock_offset.x
	local rock_y = this.pos.y + this.rock_offset.y
	local a = this.initial_angle

	U.y_wait(store, this.initial_delay)

	local delay = 0

	for i = 1, math.random(2, 4) do
		S:queue(this.sound_events.shoot, {
			delay = delay
		})

		delay = delay + U.frandom(0.1, 0.3)
	end

	for i = 1, this.count do
		U.y_wait(store, U.frandom(unpack(this.rock_delay)))

		local r = U.frandom(0, 1) * 40 + 20
		local bullet = E:create_entity(this.bullet)

		bullet.pos = V.v(rock_x, rock_y)
		bullet.bullet.from = V.vclone(bullet.pos)
		bullet.bullet.to = U.point_on_ellipse(this.pos, r, a)
		bullet.bullet.target_id = nil
		bullet.bullet.source_id = this.id

		queue_insert(store, bullet)

		a = a + this.angle_increment
	end

	U.y_wait(store, this.exit_time)

	this.tween.reverse = true
	this.tween.remove = true
	this.tween.ts = store.tick_ts
end

scripts.denas_cursing = {}

function scripts.denas_cursing.update(this, store)
	this.render.sprites[1].ts = store.tick_ts

	local source = store.entities[this.source_id]
	local source_pos = source and V.vclone(source.pos) or nil
	local ts = store.tick_ts

	if not source or not source.health or source.health.dead then
		-- block empty
	else
		this.pos = V.vclone(source.pos)
		this.pos.x = this.pos.x + this.offset.x
		this.pos.y = this.pos.y + this.offset.y
		this.render.sprites[1].flip_x = source.render.sprites[1].flip_x

		while store.tick_ts - ts < this.duration do
			if source.pos.x ~= source_pos.x or source.pos.y ~= source_pos.y or source.health.death then
				break
			end

			coroutine.yield()
		end
	end

	queue_remove(store, this)
end

scripts.hero_elora = {}

function scripts.hero_elora.freeze_filter_fn(e, origin)
	return e.template_name ~= "enemy_demon_cerberus"
end

function scripts.hero_elora.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	for i = 1, 2 do
		local bt = E:get_template(this.ranged.attacks[i].bullet)

		bt.bullet.damage_min = ls.ranged_damage_min[hl]
		bt.bullet.damage_max = ls.ranged_damage_max[hl]
	end

	local s, sl

	s = this.hero.skills.chill
	sl = s.level

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.max_range = s.max_range[sl]
		a.count = s.count[sl]

		local b = E:get_template(a.bullet)

		b.aura.level = sl

		local m = E:get_template("mod_elora_chill")

		m.slow.factor = s.slow_factor[sl]
	end

	s = this.hero.skills.ice_storm
	sl = s.level

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.count = s.count[sl]
		a.max_range = s.max_range[sl]

		local b = E:get_template(a.bullet)

		b.bullet.damage_max = s.damage_max[sl]
		b.bullet.damage_min = s.damage_min[sl]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_elora.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta
	local fe = this.render.sprites[2]
	local ps = E:create_entity(this.run_particles_name)

	ps.particle_system.track_id = this.id
	ps.particle_system.emit = false

	queue_insert(store, ps)
	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	fe.hidden = true

	while true do
		ps.particle_system.emit = false

		if h.dead then
			fe.hidden = true

			SU.y_hero_death_and_respawn(store, this)
		end

		fe.hidden = false

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				ps.particle_system.emit = true

				if SU.y_hero_new_rally(store, this) then
					goto label_61_0
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.ice_storm

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {
						pi
					}, nil, nil, NF_RALLY)

					if #nodes < 1 then
						SU.delay_attack(store, a, 0.4)
					else
						local s_pi, s_spi, s_ni = unpack(nodes[1])
						local flip = target.pos.x < this.pos.x
						local start_ts = store.tick_ts

						U.animation_start(this, "iceStorm", flip, store.tick_ts)
						S:queue(a.sound)

						if SU.y_hero_wait(store, this, a.cast_time) then
							goto label_61_0
						end

						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local delay = 0
						local n_step = ni < s_ni and -2 or 2

						local nodes_offset = P:predict_enemy_node_advance(target, a.node_prediction)
						ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + nodes_offset or ni)

						for i = 1, skill.count[skill.level] do
							local b = E:create_entity(a.bullet)

							b.pos = P:node_pos(pi, spi, ni)
							b.spike_idx = math.random(1, 2)
							b.render.sprites[1].prefix = b.render.sprites[1].prefix .. b.spike_idx
							b.render.sprites[1].flip_x = not flip
							b.render.sprites[2].name = b.render.sprites[2].name .. b.spike_idx
							b.delay = delay
							b.bullet.source_id = this.id

							queue_insert(store, b)

							delay = delay + U.frandom(0.05, 0.1)
							ni = ni + n_step
							spi = km.zmod(spi + 1, 3)
						end

						SU.y_hero_animation_wait(this)

						goto label_61_0
					end
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.chill

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {
						pi
					}, nil, nil, NF_RALLY)

					if #nodes < 1 then
						SU.delay_attack(store, a, 0.4)
					else
						local s_pi, s_spi, s_ni = unpack(nodes[1])
						local flip = target.pos.x < this.pos.x
						local start_ts = store.tick_ts

						U.animation_start(this, "chill", flip, store.tick_ts)
						S:queue(a.sound)

						if SU.y_hero_wait(store, this, a.cast_time) then
							goto label_61_0
						end

						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local delay = 0
						local n_step = ni < s_ni and -a.step or a.step

						ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + a.nodes_offset or ni)

						for i = 1, skill.count[skill.level] do
							local b = E:create_entity(a.bullet)

							b.pos = P:node_pos(pi, spi, ni)
							b.render.sprites[1].prefix = b.render.sprites[1].prefix .. math.random(1, 3)
							b.render.sprites[1].flip_x = not flip
							b.delay = delay

							queue_insert(store, b)

							delay = delay + 0.05
							ni = ni + n_step
							spi = km.zmod(spi + 1, 3)
						end

						SU.y_hero_animation_wait(this)

						goto label_61_0
					end
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

		::label_61_0::

		coroutine.yield()
	end
end

scripts.elora_ice_spike = {}

function scripts.elora_ice_spike.update(this, store)
	local b = this.bullet

	U.sprites_hide(this)

	if this.sprite_idx == 1 then
		this.render.sprites[1].anchor.y = this.spike_1_anchor_y
		this.render.sprites[2].anchor.y = this.spike_1_anchor_y
	end

	if this.delay then
		U.y_wait(store, this.delay)
	end

	this.render.sprites[1].hidden = false

	local start_ts = store.tick_ts

	this.pos.x = this.pos.x + math.random(-4, 4)
	this.pos.y = this.pos.y + math.random(-5, 5)

	S:queue(this.sound_events.delayed_insert)
	U.animation_start(this, "start", nil, store.tick_ts, false, 1)
	U.y_wait(store, b.hit_time)

	this.render.sprites[2].hidden = false

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in pairs(targets) do
			local d = E:create_entity("damage")

			d.damage_type = b.damage_type
			d.source_id = this.id
			d.target_id = target.id
			d.value = math.random(b.damage_min, b.damage_max)

			queue_damage(store, d)
		end
	end

	U.y_wait(store, 1)
	S:queue(this.sound_events.ice_break)
	U.y_wait(store, b.duration - (store.tick_ts - start_ts))
	queue_remove(store, this)
end

scripts.hero_hacksaw = {}

function scripts.hero_hacksaw.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local s, sl

	s = this.hero.skills.sawblade
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.ranged.attacks[1]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bounces_max = s.bounces[sl]
	end

	s = this.hero.skills.timber
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.melee.attacks[2]

		a.disabled = nil
		a.cooldown = s.cooldown[sl]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_hacksaw.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			S:queue(this.sound_events.death2)
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_64_0
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
			end

			brk, sta = y_hero_ranged_attacks(store, this)

			if brk then
				-- block empty
			else
				brk, sta = y_hero_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					-- block empty
				elseif SU.soldier_go_back_step(store, this) then
					-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_64_0::

		coroutine.yield()
	end
end

scripts.hero_ingvar = {}

function scripts.hero_ingvar.get_info(this)
	local a = this.is_bear and this.melee.attacks[3] or this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

	min, max = min * this.unit.damage_factor, max * this.unit.damage_factor

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

function scripts.hero_ingvar.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	local s, sl

	s = this.hero.skills.ancestors_call
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.count = s.count[sl]

		local e = E:get_template(a.entity)

		e.health.hp_max = s.hp_max[sl]
		a = e.melee.attacks[1]
		a.damage_min = s.damage_min[sl]
		a.damage_max = s.damage_max[sl]
	end

	s = this.hero.skills.bear
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.timed_attacks.list[2]

		a.duration = s.duration[sl]
		a.disabled = nil

		local a = this.melee.attacks[3]

		a.damage_min = s.damage_min[sl]
		a.damage_max = s.damage_max[sl]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_ingvar.update(this, store)
	local h = this.health
	local he = this.hero
	local ba = this.timed_attacks.list[2]
	local a, skill, brk, sta

	local function go_bear()
		this.sound_events.change_rally_point = this.sound_events.change_rally_point_bear

		for i = 1, 2 do
			this.melee.attacks[i].disabled = true
		end

		this.melee.attacks[3].disabled = false
		this.health.immune_to = ba.immune_to

		S:queue(ba.sound)
		U.y_animation_play(this, "toBear", nil, store.tick_ts, 1)

		this.render.sprites[1].prefix = "hero_ingvar_bear"
		ba.ts = store.tick_ts
		this.is_bear = true
	end

	local function go_viking()
		this.sound_events.change_rally_point = this.sound_events.change_rally_point_viking

		for i = 1, 2 do
			this.melee.attacks[i].disabled = false
		end

		this.melee.attacks[3].disabled = true
		this.health.immune_to = DAMAGE_NONE
		this.is_bear = false

		U.y_animation_play(this, "toViking", nil, store.tick_ts, 1)

		this.render.sprites[1].prefix = "hero_ingvar"
		ba.ts = store.tick_ts
	end

	for _, an in pairs(this.auras.list) do
		local aura = E:create_entity(an.name)

		aura.aura.source_id = this.id

		queue_insert(store, aura)
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			if this.is_bear then
				go_viking()
			end

			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_67_0
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if SU.hero_level_up(store, this) and not this.is_bear then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = ba
			skill = this.hero.skills.bear

			if not this.is_bear and not a.disabled and store.tick_ts - a.ts >= a.cooldown and this.health.hp < this.health.hp_max * a.transform_health_factor then
				SU.hero_gain_xp_from_skill(this, skill)
				go_bear()
			elseif this.is_bear and store.tick_ts - a.ts >= a.duration then
				go_viking()
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.ancestors_call

			if not this.is_bear and not a.disabled and store.tick_ts - a.ts >= a.cooldown then
				local target = U.find_foremost_enemy(store.entities, this.pos, 0, a.max_range)
				if target then
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, nil, NF_RALLY)
					if #nodes < 1 then
						SU.delay_attack(store, a, 0.1)
					else
						U.animation_start(this, a.animation, nil, store.tick_ts, 1)
						S:queue(a.sound, a.sound_args)
	
						if SU.y_hero_wait(store, this, a.cast_time) then
							goto label_67_0
						end
	
						SU.hero_gain_xp_from_skill(this, skill)
	
						a.ts = store.tick_ts
	
						local pi, spi, ni = unpack(nodes[1])
						local no_min, no_max = unpack(a.nodes_offset)
						local no
	
						for i = 1, a.count do
							local e = E:create_entity(a.entity)
							local e_spi, e_ni = math.random(1, 3), ni
	
							no = math.random(no_min, no_max) * U.random_sign()
	
							if P:is_node_valid(pi, e_ni + no) then
								e_ni = e_ni + no
							end
	
							e.nav_rally.center = P:node_pos(pi, e_spi, e_ni)
							e.nav_rally.pos = V.vclone(e.nav_rally.center)
							e.pos = V.vclone(e.nav_rally.center)
							e.render.sprites[1].name = "raise"
							e.owner = this
	
							queue_insert(store, e)
						end
	
						SU.y_hero_animation_wait(this)
	
						goto label_67_0
					end
				else
					SU.delay_attack(store, a, 0.1)
				end
			end

			brk, sta = y_hero_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			elseif SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_67_0::

		coroutine.yield()
	end
end

scripts.hero_ignus = {}

function scripts.hero_ignus.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local s, sl

	s = this.hero.skills.flaming_frenzy
	sl = s.level

	local a = this.timed_attacks.list[1]

	if initial and s.level > 0 then
		a.disabled = nil
		a.damage_min = s.damage_min[sl]
		a.damage_max = s.damage_max[sl]
	end

	s = this.hero.skills.surge_of_flame
	sl = s.level

	local a = this.timed_attacks.list[2]

	if initial and s.level > 0 then
		a.disabled = nil

		local aura = E:get_template("aura_ignus_surge_of_flame")

		aura.aura.damage_min = s.damage_min[sl]
		aura.aura.damage_max = s.damage_max[sl]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_ignus.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta, target, attack_done

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	local aura = E:create_entity(this.particles_aura)

	aura.aura.source_id = this.id

	queue_insert(store, aura)

	local ps = E:create_entity(this.run_particles_name)

	ps.particle_system.track_id = this.id
	ps.particle_system.emit = false

	queue_insert(store, ps)

	while true do
		ps.particle_system.emit = false

		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				ps.particle_system.emit = true

				if SU.y_hero_new_rally(store, this) then
					goto label_71_0
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
			end

			brk, sta = y_hero_melee_block_and_attacks(store, this)

			if brk or h.dead then
				-- block empty
			else
				a = this.timed_attacks.list[2]
				skill = this.hero.skills.surge_of_flame

				if sta ~= A_NO_TARGET and not a.disabled and store.tick_ts - a.ts >= a.cooldown then
					local target = U.find_first_target(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(e)
						if not e.enemy or not e.nav_path or not e.nav_path.pi then
							return false
						end

						local ps, pe = P:get_visible_start_node(e.nav_path.pi), P:get_visible_end_node(e.nav_path.pi)

						return (#e.enemy.blockers or 0) == 0 and e.nav_path.ni > ps + a.nodes_margin and e.nav_path.ni < pe - a.nodes_margin
					end)

					if not target then
						-- block empty
					else
						U.unblock_target(store, this)
						U.block_enemy(store, this, target)
						SU.hero_gain_xp_from_skill(this, skill)

						local slot_pos, slot_flip = U.melee_slot_position(this, target, 1)
						local vis_bans = this.vis.bans

						this.vis.bans = F_ALL
						this.health.ignore_damage = true
						this.motion.max_speed = this.motion.max_speed * a.speed_factor

						U.set_destination(this, slot_pos)
						S:queue(a.sound)
						U.y_animation_play(this, a.animations[1], nil, store.tick_ts)

						local aura = E:create_entity(a.aura)

						aura.aura.source_id = this.id

						queue_insert(store, aura)

						while not this.motion.arrived do
							U.walk(this, store.tick_length, nil, true)
							coroutine.yield()
						end

						this.nav_rally.center = V.vclone(this.pos)
						this.nav_rally.pos = V.vclone(this.pos)

						S:queue(a.sound_end)
						U.y_animation_play(this, a.animations[2], nil, store.tick_ts)

						a.ts = store.tick_ts
						this.vis.bans = vis_bans
						this.health.ignore_damage = nil
						this.motion.max_speed = this.motion.max_speed / a.speed_factor

						goto label_71_0
					end
				end

				a = this.timed_attacks.list[1]
				skill = this.hero.skills.flaming_frenzy

				if sta ~= A_NO_TARGET and not a.disabled and store.tick_ts - a.ts >= a.cooldown then
					if U.frandom(0, 1) >= a.chance then
						goto label_71_0
					end

					local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

					if not targets then
						-- block empty
					else
						local start_ts = store.tick_ts
						local flip = targets[1].pos.x < this.pos.x

						U.animation_start(this, a.animation, flip, store.tick_ts)
						S:queue(a.sound)

						if U.y_wait(store, a.cast_time, function()
							return SU.hero_interrupted(this)
						end) then
							goto label_71_0
						end

						SU.hero_gain_xp_from_skill(this, skill)

						a.ts = start_ts
						targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

						if targets then
							for _, t in pairs(targets) do
								local fx = E:create_entity(a.hit_fx)

								fx.pos = V.vclone(t.pos)

								if t.unit and t.unit.mod_offset then
									fx.pos.x, fx.pos.y = fx.pos.x + t.unit.mod_offset.x, fx.pos.y + t.unit.mod_offset.y
								end

								for i = 1, #fx.render.sprites do
									fx.render.sprites[i].ts = store.tick_ts
								end

								queue_insert(store, fx)

								local d = E:create_entity("damage")

								d.damage_type = a.damage_type
								d.source_id = this.id
								d.target_id = t.id
								d.value = math.random(a.damage_min, a.damage_max)

								queue_damage(store, d)
							end
						end

						this.health.hp = this.health.hp + this.health.hp_max * a.heal_factor
						this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp)

						local e = E:create_entity(a.decal)

						e.pos = V.vclone(this.pos)
						e.render.sprites[1].ts = store.tick_ts

						queue_insert(store, e)

						if not U.y_animation_wait(this) then
							-- block empty
						end

						if false then
							-- block empty
						end

						goto label_71_0
					end
				end

				if sta ~= A_NO_TARGET then
					-- block empty
				elseif SU.soldier_go_back_step(store, this) then
					-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_71_0::

		coroutine.yield()
	end
end

scripts.hero_magnus = {}

function scripts.hero_magnus.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local ra = this.ranged.attacks[1]
	local b = E:get_template(ra.bullet)

	b.bullet.damage_min = ls.ranged_damage_min[hl]
	b.bullet.damage_max = ls.ranged_damage_max[hl]

	local s, sl

	s = this.hero.skills.mirage
	sl = s.xp_level_steps[hl]

	local a = this.timed_attacks.list[1]

	if sl then
		s.level = sl
		a.disabled = nil
		a.count = s.count[sl]

		local il = E:get_template(a.entity)

		il.level = hl
		il.health.hp_max = math.ceil(ls.hp_max[hl] * s.health_factor)
		il.melee.attacks[1].damage_min = math.ceil(ls.melee_damage_min[hl] * s.damage_factor)
		il.melee.attacks[1].damage_max = math.ceil(ls.melee_damage_max[hl] * s.damage_factor)

		local ira = il.ranged.attacks[1]
		local ib = E:get_template(ira.bullet)

		ib.bullet.damage_min = math.ceil(ls.ranged_damage_min[hl] * s.damage_factor)
		ib.bullet.damage_max = math.ceil(ls.ranged_damage_max[hl] * s.damage_factor)
	end

	s = this.hero.skills.arcane_rain
	sl = s.xp_level_steps[hl]

	local a = this.timed_attacks.list[2]

	if sl then
		s.level = sl
		a.disabled = nil

		local c = E:get_template(a.entity)

		c.count = s.count[sl]

		local r = E:get_template(c.entity)

		r.damage_min = s.damage[sl]
		r.damage_max = s.damage[sl]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_magnus.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

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
					goto label_75_0
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			skill = this.hero.skills.mirage
			a = this.timed_attacks.list[1]

			if not a.disabled and store.tick_ts - a.ts >= a.cooldown then
				local target = U.find_foremost_enemy(store.entities, this.pos, 0, a.max_range)
				if target then
					S:queue(a.sound)
					U.animation_start(this, a.animation, nil, store.tick_ts)
	
					if U.y_wait(store, a.cast_time, function()
						return SU.hero_interrupted(this)
					end) then
						goto label_75_0
					end
	
					SU.hero_gain_xp_from_skill(this, skill)
	
					a.ts = store.tick_ts
	
					local rotations = a.entity_rotations[a.count]
	
					for i = 1, a.count do
						local angle = rotations[i]
						local o = V.v(V.rotate(angle, a.initial_pos.x, a.initial_pos.y))
						local r = V.v(V.rotate(angle, a.initial_rally.x, a.initial_rally.y))
						local e = E:create_entity(a.entity)
						local rx, ry = this.pos.x + r.x, this.pos.y + r.y
	
						e.nav_rally.center = V.v(rx, ry)
						e.nav_rally.pos = V.v(rx, ry)
						e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
						e.tween.ts = store.tick_ts
						e.tween.props[1].keys[1][2].x = -o.x
						e.tween.props[1].keys[1][2].y = -o.y
						e.render.sprites[1].flip_x = this.render.sprites[1].flip_x
						e.owner = this
	
						queue_insert(store, e)
					end
	
					if not U.y_animation_wait(this) then
						goto label_75_0
					end
				else
					SU.delay_attack(store, a, 0.1)
				end
			end

			skill = this.hero.skills.arcane_rain
			a = this.timed_attacks.list[2]

			if not a.disabled and store.tick_ts - a.ts >= a.cooldown then
				local pos, crowd = U.find_enemy_crowd_position(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, nil, 
				a.crowd_range, a.min_targets, true, U.position_type.node_floor_center, true)
				if not pos then
					SU.delay_attack(store, a, 0.1)
				else
					S:queue(a.sound)
					local target = crowd.center_unit
					local flip = target.pos.x < this.pos.x
					local start_ts = store.tick_ts
					U.animation_start(this, a.animation, flip, store.tick_ts)
					if U.y_wait(store, a.cast_time, function()
						return SU.hero_interrupted(this)
					end) then
						goto label_75_0
					end
					SU.hero_gain_xp_from_skill(this, skill)
					if target and store.entities[target.id] and not target.health.dead then
						local offset = U.get_prediction_offset(target, a.node_prediction)
						pos.x, pos.y = pos.x + offset.x, pos.y + offset.y
					end
					local e = E:create_entity(a.entity)
					e.pos = pos
					queue_insert(store, e)
					a.ts = start_ts
					if not U.y_animation_wait(this) then
						goto label_75_0
					end
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
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

		::label_75_0::

		coroutine.yield()
	end
end

scripts.magnus_arcane_rain_controller = {}

function scripts.magnus_arcane_rain_controller.update(this, store)
	this.tween.disabled = false
	this.tween.ts = store.tick_ts

	local a = this.initial_angle

	for i = 1, this.count do
		U.y_wait(store, this.spawn_time)

		local r = U.frandom(0, 1) * 40 + 15
		local pos = U.point_on_ellipse(this.pos, r, a)
		local e = E:create_entity(this.entity)

		e.pos = V.vclone(pos)

		queue_insert(store, e)

		a = a + this.angle_increment

		if a > 2 * math.pi then
			a = a - 2 * math.pi
		end
	end

	U.y_wait(store, 0.5)

	this.tween.reverse = true
	this.tween.remove = true
	this.tween.ts = store.tick_ts
end

scripts.magnus_arcane_rain = {}

function scripts.magnus_arcane_rain.update(this, store)
	this.render.sprites[1].ts = store.tick_ts

	U.animation_start(this, "drop", nil, store.tick_ts, 1)
	S:queue(this.sound)
	U.y_wait(store, this.hit_time)

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.damage_radius, this.damage_flags, this.damage_bans or 0)

	if targets then
		for _, target in pairs(targets) do
			local d = E:create_entity("damage")

			d.damage_type = this.damage_type
			d.source_id = this.id
			d.target_id = target.id
			d.value = math.random(this.damage_min, this.damage_max)

			queue_damage(store, d)
		end
	end

	U.y_animation_wait(this)
	queue_remove(store, this)
end

scripts.hero_malik = {}

function scripts.hero_malik.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	local s, sl

	s = this.hero.skills.smash
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.melee.attacks[3]

		a.disabled = nil
		a.damage_min = s.damage_min[sl]
		a.damage_max = s.damage_max[sl]
	end

	s = this.hero.skills.fissure
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.melee.attacks[4]

		a.disabled = nil

		local au = E:get_template(a.hit_aura)

		au.aura.level = sl
		au.aura.damage_min = s.damage_min[sl]
		au.aura.damage_max = s.damage_max[sl]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_malik.update(this, store)
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
					goto label_81_0
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

		::label_81_0::

		coroutine.yield()
	end
end

scripts.hero_oni = {}

function scripts.hero_oni.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local s, sl

	s = this.hero.skills.death_strike
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.melee.attacks[2]

		a.disabled = nil
		a.chance = s.chance[sl]
		a = this.melee.attacks[3]
		a.disabled = nil
		a.damage_min = s.damage[sl]
		a.damage_max = s.damage[sl]
	end

	s = this.hero.skills.torment
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage_min = s.min_damage[sl]
		a.damage_max = s.max_damage[sl]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_oni.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	local function spawn_swords(count, center, radius, angle, delay)
		for i = 1, count do
			local p = U.point_on_ellipse(center, radius - math.random(0, 5), angle + i * 2 * math.pi / count)
			local e = E:create_entity("decal_oni_torment_sword")

			e.pos.x, e.pos.y = p.x, p.y
			e.delay = delay

			queue_insert(store, e)
		end
	end

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

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
					goto label_83_0
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.torment

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local triggers = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

				if not triggers or #triggers < a.min_count then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					local start_ts = store.tick_ts
					local af = triggers[1].pos.x < this.pos.x

					U.animation_start(this, a.animation, af, store.tick_ts)

					if SU.y_hero_wait(store, this, a.hit_time) then
						goto label_83_0
					end

					S:queue(a.sound_hit)

					a.ts = start_ts

					local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius, a.vis_flags, a.vis_bans)

					if not targets then
						SU.delay_attack(store, a, 0.13333333333333333)
					else
						SU.hero_gain_xp_from_skill(this, skill)

						local hit_center = V.vclone(this.pos)

						for _, s in pairs(a.torment_swords) do
							local d, r, c = unpack(s)

							spawn_swords(c, hit_center, r, math.random(0, 2) * math.pi, d)
						end

						U.y_wait(store, a.damage_delay)

						for _, target in pairs(targets) do
							local d = SU.create_attack_damage(a, target.id, this.id)

							queue_damage(store, d)
						end

						SU.y_hero_animation_wait(this)

						goto label_83_0
					end
				end
			end

			brk, sta = y_hero_melee_block_and_attacks(store, this)

			if sta == A_IN_COOLDOWN then
				U.animation_start(this, "idle", nil, store.tick_ts, true)
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

		::label_83_0::

		coroutine.yield()
	end
end

scripts.decal_oni_torment_sword = {}

function scripts.decal_oni_torment_sword.update(this, store)
	local sword_name = table.random(this.sword_names)

	this.render.sprites[1].prefix = sword_name
	this.render.sprites[1].hidden = true

	U.y_wait(store, this.delay)

	this.render.sprites[1].hidden = false

	U.y_animation_play(this, "in", nil, store.tick_ts)
	U.y_wait(store, this.duration)
	U.y_animation_play(this, "out", nil, store.tick_ts)
	queue_remove(store, this)
end

scripts.hero_thor = {}

function scripts.hero_thor.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local s, sl

	s = this.hero.skills.chainlightning
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.melee.attacks[2]

		a.disabled = nil
		a.level = sl

		local mod = E:get_template(a.mod)

		mod.chainlightning.count = s.count[sl]
		mod.chainlightning.damage = s.damage_max[sl]
	end

	s = this.hero.skills.thunderclap
	sl = s.xp_level_steps[hl]

	if sl then
		s.level = sl

		local a = this.ranged.attacks[1]

		a.disabled = nil
		a.level = sl

		local b = E:get_template(a.bullet)
		local mod = E:get_template(b.bullet.mod)

		mod.thunderclap.damage = s.damage_max[sl]
		mod.thunderclap.secondary_damage = s.secondary_damage_max[sl]
		mod.thunderclap.stun_duration_max = s.stun_duration[sl]
		mod.thunderclap.max_range = s.max_range[sl]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_thor.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

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
					goto label_87_0
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
			end

			brk, sta = SU.y_soldier_ranged_attacks(store, this)

			if brk then
				-- block empty
			else
				brk, sta = y_hero_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					-- block empty
				elseif SU.soldier_go_back_step(store, this) then
					-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_87_0::

		coroutine.yield()
	end
end

scripts.hero_10yr = {}

function scripts.hero_10yr.get_info(this)
	local a = this.is_buffed and this.melee.attacks[3] or this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

	min, max = min * this.unit.damage_factor, max * this.unit.damage_factor
	min, max = math.ceil(min), math.ceil(max)

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

function scripts.hero_10yr.level_up(this, store, initial)
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
	s = this.hero.skills.rain
	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]
		a.disabled = nil

		local au = E:get_template(a.entity)
		au.aura.loops = s.loops[s.level]

		local bt = E:get_template(au.aura.entity)
		bt.bullet.damage_min = s.damage_min[s.level]
		bt.bullet.damage_max = s.damage_max[s.level]
		if s.level == 3 then
			bt.scorch_earth = true
		end
	end

	s = this.hero.skills.waterball
	if initial and s.level > 0 then
		local a = this.ranged.attacks[1]
		a.disabled = nil

		local b = E:get_template(a.bullet)
		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end

	s = this.hero.skills.buffed
	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]
		a.duration = s.duration[s.level]
		a.disabled = nil

		local a = this.melee.attacks[3]
		a.damage_min = s.spin_damage_min[s.level]
		a.damage_max = s.spin_damage_max[s.level]
	end

	s = this.hero.skills.bomb
	if initial and s.level > 0 then
		local a = this.timed_attacks.list[3]
		a.damage_min = s.bomb_damage_min[s.level]
		a.damage_max = s.bomb_damage_max[s.level]
		if s.level == 3 then
			a.sound = a.sound_long
		end
		local au = E:get_template(a.hit_aura)
		au.aura.steps = s.bomb_steps[s.level]
		au.aura.damage_min = s.bomb_step_damage_min[s.level]
		au.aura.damage_max = s.bomb_step_damage_max[s.level]
		a.disabled = nil

		local e = E:get_template(this.land_entity)
		e.aura.damage_min = s.bomb_step_damage_min[s.level]
		e.aura.damage_max = s.bomb_step_damage_max[s.level]
	end

	s = this.hero.skills.ultimate
	if initial and s.level > 0 then
		local u = E:get_template(s.controller_name)
		u.cooldown = s.cooldown[s.level]

		local entity = E:get_template(u.entity)
		entity.bullet.damage_min = s.damage_min[s.level]
		entity.bullet.damage_max = s.damage_max[s.level]
		entity.bullet.damage_radius = 75
		if s.level >= 3 then
			entity.scorch_earth = true
		end
		if s.level >= 4 then
			u.cataclysm_count = 5
		end
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_10yr.update(this, store)
	local h = this.health
	local he = this.hero
	local ra = this.timed_attacks.list[1]
	local ba = this.timed_attacks.list[2]
	local bma = this.timed_attacks.list[3]
	local a, skill, brk, sta

	local function go_buffed()
		this.sound_events.change_rally_point = this.sound_events.change_rally_point_buffed

		this.melee.attacks[1].disabled = true
		this.ranged.attacks[1].disabled = true
		this.melee.attacks[3].disabled = nil
		this.soldier.melee_slot_offset = this.buffed_melee_slot_offset
		this.unit.mod_offset.x, this.unit.mod_offset.y = this.buffed_mod_offset.x, this.buffed_mod_offset.y
		this.unit.hit_offset.x, this.unit.hit_offset.y = this.buffed_hit_offset.x, this.buffed_hit_offset.y

		this.health.immune_to = ba.immune_to

		for _, v in pairs(ba.sounds_buffed) do
			S:queue(v)
		end

		U.y_animation_play(this, "normal_to_buffed", nil, store.tick_ts, 1)

		this.render.sprites[1].prefix = "hero_10yr_buffed"
		ba.ts = store.tick_ts
		this.teleport.disabled = true
		this.launch_movement.disabled = nil
		this.is_buffed = true
		this.health_bar.offset = this.health_bar.offset_buffed
		this.hero.level_stats.regen_health = this.hero.level_stats.regen_health_buffed
		this.motion.max_speed = this.motion.max_speed_buffed
		this.melee.range = this.melee.range_buffed
	end

	local function go_normal()
		this.sound_events.change_rally_point = this.sound_events.change_rally_point_normal

		this.melee.attacks[1].disabled = nil
		if this.hero.skills.waterball.level > 0 then
			this.ranged.attacks[1].disabled = nil
		end
		this.melee.attacks[3].disabled = true
		this.soldier.melee_slot_offset = this.normal_melee_slot_offset
		this.unit.mod_offset.x, this.unit.mod_offset.y = this.normal_mod_offset.x, this.normal_mod_offset.y
		this.unit.hit_offset.x, this.unit.hit_offset.y = this.normal_hit_offset.x, this.normal_hit_offset.y

		this.health.immune_to = DAMAGE_NONE
		this.is_buffed = false

		for _, v in pairs(ba.sounds_normal) do
			S:queue(v)
		end

		U.y_animation_play(this, "to_normal", nil, store.tick_ts, 1)

		this.render.sprites[1].prefix = "hero_10yr"
		this.teleport.disabled = nil
		this.launch_movement.disabled = true
		this.health_bar.offset = this.health_bar.offset_normal
		this.hero.level_stats.regen_health = this.hero.level_stats.regen_health_normal
		this.motion.max_speed = this.motion.max_speed_normal
		this.melee.range = this.melee.range_normal
		ba.ts = store.tick_ts
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	local aura = E:create_entity(this.particles_aura)

	aura.aura.source_id = this.id

	queue_insert(store, aura)

	while true do
		if h.dead then
			if this.is_buffed then
				go_normal()
			end

			SU.y_hero_death_and_respawn_kr5(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				local launch_move = SU.hero_will_launch_move(this, this.nav_rally.pos)
				local rally = SU.y_hero_new_rally(store, this)
				if launch_move and this.hero.skills.bomb.level > 0 then
					local e = E:create_entity(this.land_entity)
					e.pos = V.vclone(this.pos)
					e.aura.source_id = this.id
					queue_insert(store, e)
				end
				if rally then
					goto label_90_1
				end
			end

			SU.heroes_visual_learning_upgrade(store, this)
			SU.heroes_lone_wolves_upgrade(store, this)
			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if SU.hero_level_up(store, this) and not this.is_buffed then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = ra
			if not this.is_buffed and not a.disabled and store.tick_ts - a.ts >= a.cooldown then
				local start_ts, bdy, bdt, au
				local fired_aura = false
				local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.trigger_range, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_count then
					SU.delay_attack(store, a, 0.2)
				else
					S:queue(a.sound_start)
					U.animation_start(this, a.animations[1], nil, store.tick_ts, false)

					while not U.animation_finished(this) do
						if SU.hero_interrupted(this) then
							goto label_90_0
						end

						coroutine.yield()
					end

					start_ts = store.tick_ts

					U.animation_start(this, a.animations[2], nil, store.tick_ts, false)

					while not U.animation_finished(this) do
						if SU.hero_interrupted(this) then
							goto label_90_0
						end

						coroutine.yield()
					end

					au = E:create_entity(a.entity)
					au.aura.source_id = this.id

					queue_insert(store, au)

					fired_aura = true

					::label_90_0::

					if fired_aura then
						a.ts = start_ts

						if a.xp_from_skill then
							SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
						end
					end

					S:queue(a.sound_end)
					U.y_animation_play(this, a.animations[3], nil, store.tick_ts, 1)
				end
			end

			a = ba
			if not this.is_buffed and not a.disabled and store.tick_ts - a.ts >= a.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

				if targets and #targets >= a.min_count then
					if a.xp_from_skill then
						SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
					end
					go_buffed()
				end
			elseif this.is_buffed and store.tick_ts - a.ts >= a.duration then
				go_normal()
			end

			a = bma
			if this.is_buffed and not a.disabled and store.tick_ts - a.ts >= a.cooldown then
				local target_info = U.find_enemies_in_paths(store.entities, this.pos, a.min_nodes, a.max_nodes, nil, a.vis_flags, a.vis_bans)

				if not target_info or #target_info < a.min_count then
					SU.delay_attack(store, a, 0.2)
				else
					local target = target_info[1].enemy
					if a.xp_from_skill then
						SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
					end
					if not SU.y_soldier_do_single_area_attack(store, this, target, a) then
						goto label_90_1
					end
				end
			end

			brk, sta = y_hero_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			elseif SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				brk, sta = y_hero_ranged_attacks(store, this)
				if brk then
					-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_90_1::

		coroutine.yield()
	end
end

scripts.hero_10yr_ultimate = {}
function scripts.hero_10yr_ultimate.can_fire_fn(this, x, y, store)
	return (GR:cell_is(x, y, TERRAIN_LAND) or GR:cell_is(x, y, TERRAIN_WATER)) and SU5.valid_node_interval(x, y, this.offset_back, 0, 1, NF_RALLY)
end

scripts.enemy_sheep = {}

function scripts.enemy_sheep.update(this, store)
	local clicks = 0

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.ui.clicked then
			this.ui.clicked = nil
			clicks = clicks + 1
		end

		if clicks >= this.clicks_to_destroy then
			this.health.hp = 0

			coroutine.yield()
			-- AC:inc_check("SHEEP_KILLER")
		elseif this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local next_pos = P:next_entity_node(this, store.tick_length)
            if next_pos and GR:cell_is(next_pos.x, next_pos.y, bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) then
				SU.remove_modifiers(store, this)
				coroutine.yield()
            end
			SU.y_enemy_walk_until_blocked(store, this, true, function(store, this)
				return this.ui.clicked
			end)
		end
	end
end

scripts.enemy_shaman = {}

function scripts.enemy_shaman.update(this, store)
	local a = this.timed_attacks.list[1]

	a.ts = store.tick_ts

	local function ready_to_heal()
		return this.enemy.can_do_magic and store.tick_ts - a.ts > a.cooldown
	end

	::label_95_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_heal() then
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
					return e.health.hp < e.health.hp_max
				end)

				if not targets then
					SU.delay_attack(store, a, 0.5)
				else
					a.ts = store.tick_ts

					U.animation_start(this, a.animation, nil, store.tick_ts, false)
					S:queue(a.sound)

					if SU.y_enemy_wait(store, this, a.cast_time) then
						goto label_95_0
					end

					targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
						return e.health.hp < e.health.hp_max
					end)

					if targets then
						local healed_count = 0

						for _, target in ipairs(targets) do
							if healed_count >= a.max_count then
								break
							end

							local m = E:create_entity(a.mod)

							m.modifier.source_id = this.id
							m.modifier.target_id = target.id

							queue_insert(store, m)

							healed_count = healed_count + 1
						end
					end

					U.y_animation_wait(this)
				end
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, ready_to_heal, ready_to_heal) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_spider_big = {}

function scripts.enemy_spider_big.update(this, store, script)
	local ma = this.melee.attacks[1]
	local ta = this.timed_attacks.list[1]

	ta.ts = store.tick_ts
	ta.cooldown = U.frandom(ta.min_cooldown, ta.max_cooldown)

	local eggs_count = 0

	local function ready_to_lay()
		return store.tick_ts - ta.ts > ta.cooldown and eggs_count < ta.max_count and not U.get_blocker(store, this)
	end

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_lay() then
				ta.ts = store.tick_ts
				eggs_count = eggs_count + 1

				local pi, spi, ni = this.nav_path.pi, this.nav_path.spi, this.nav_path.ni
				local e = E:create_entity(ta.bullet)

				e.pos.x, e.pos.y = this.pos.x, this.pos.y
				e.spawner.pi = pi
				e.spawner.spi = spi
				e.spawner.ni = ni

				queue_insert(store, e)
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, ready_to_lay, nil, nil) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_rocketeer = {}

function scripts.enemy_rocketeer.on_damage(this, store, damage)
	if not this.health.dead and not U.has_modifier_types(store, this, MOD_TYPE_FREEZE) and not this.already_speed_up then
		local speed_buff = E:create_entity("mod_rocketeer_speed_buff")

		speed_buff.modifier.source_id = this.id
		speed_buff.modifier.target_id = this.id

		queue_insert(store, speed_buff)
	end

	return true
end

scripts.enemy_troll_chieftain = {}

function scripts.enemy_troll_chieftain.update(this, store)
	local a = this.timed_attacks.list[1]

	a.ts = store.tick_ts

	local function ready_to_rage()
		if U.get_blocker(store, this) then
			a.ts = store.tick_ts

			return false
		else
			return this.enemy.can_do_magic and store.tick_ts - a.ts > a.cooldown
		end
	end

	local function get_rage_targets()
		return U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
			return table.contains(a.allowed_templates, e.template_name) and not U.has_modifier_in_list(store, e, a.exclude_with_mods) and not U.has_modifier_types(store, e, MOD_TYPE_SLOW)
		end)
	end

	local function rage_targets()
		local targets = get_rage_targets()

		if targets then
			local raged_count = 0

			for _, target in ipairs(targets) do
				if raged_count >= a.max_count then
					break
				end

				raged_count = raged_count + 1

				for _, name in pairs(a.mods) do
					local m = E:create_entity(name)

					m.modifier.source_id = this.id
					m.modifier.target_id = target.id

					queue_insert(store, m)
				end
			end
		end
	end

	::label_102_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_rage() then
				local targets = get_rage_targets()

				if not targets then
					SU.delay_attack(store, a, 0.5)
				else
					a.ts = store.tick_ts

					for i = 1, a.loops do
						U.animation_start(this, a.animation, nil, store.tick_ts, false)

						if SU.y_enemy_wait(store, this, a.cast_time) then
							goto label_102_0
						end

						S:queue(a.cast_sound)
						rage_targets()
						U.y_animation_wait(this)
					end
				end
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, ready_to_rage, nil) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_demon_mage = {}

function scripts.enemy_demon_mage.update(this, store)
	local a = this.timed_attacks.list[1]

	a.ts = store.tick_ts

	local function ready_to_shield()
		return this.enemy.can_do_magic and store.tick_ts - a.ts > a.cooldown
	end

	local function get_shield_targets()
		return U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
			return (table.contains(a.allowed_templates, e.template_name))
		end)
	end

	::label_107_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_shield() then
				local targets = get_shield_targets()

				if not targets then
					SU.delay_attack(store, a, 0.5)
				else
					a.ts = store.tick_ts

					U.animation_start(this, a.animation, nil, store.tick_ts, false)
					S:queue(a.sound)

					if SU.y_enemy_wait(store, this, a.cast_time) then
						goto label_107_0
					end

					targets = get_shield_targets()

					if targets then
						local shielded_count = 0

						for _, target in ipairs(targets) do
							if shielded_count >= a.max_count then
								break
							end

							shielded_count = shielded_count + 1

							local m = E:create_entity(a.mod)

							m.modifier.source_id = this.id
							m.modifier.target_id = target.id

							queue_insert(store, m)
						end
					end

					if SU.y_enemy_animation_wait(this) then
						goto label_107_0
					end
				end
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, ready_to_shield, ready_to_shield) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_demon_legion = {}

function scripts.enemy_demon_legion.update(this, store)
	local a = this.timed_attacks.list[1]

	local function ready_to_clone()
		return a.count > 0 and store.tick_ts - a.ts >= a.cooldown and P:nodes_to_defend_point(this.nav_path) > a.nodes_limit
	end

	if this.render.sprites[1].name == "raise" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise, this.sound_events.raise_args)
		end

		local an, af = U.animation_name_facing_point(this, "raise", this.motion.dest)

		U.y_animation_play(this, an, af, store.tick_ts)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end

		if this._raise_vis_bans then
			this.vis.bans = this._raise_vis_bans
			this.health.ignore_damage = this._raise_ignore_damage
		end

		U.animation_start(this, "idle", af, store.tick_ts, true)
	end

	a.count = a.generation
	a.ts = store.tick_ts

	::label_111_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_clone() then
				U.animation_start(this, a.animation, nil, store.tick_ts)

				if SU.y_enemy_wait(store, this, a.spawn_time) then
					goto label_111_0
				end

				local e = E:create_entity(a.entity)

				e._summoned = true
				e.health.hp = this.health.hp
				e.enemy.gold = 0
				e.render.sprites[1].name = "raise"
				e.timed_attacks.list[1].generation = a.generation - 1
				e.nav_path.pi = this.nav_path.pi
				e.nav_path.spi = math.random(1, 3)
				e.nav_path.ni = this.nav_path.ni + math.random(a.spawn_offset_nodes[1], a.spawn_offset_nodes[2])

				if not P:is_node_valid(e.nav_path.pi, e.nav_path.ni) then
					e.nav_path.ni = this.nav_path.ni
				end

				queue_insert(store, e)
				SU.y_enemy_animation_wait(this)

				a.ts = store.tick_ts
				a.count = a.count - 1
				a.cooldown = a.cooldown_after
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, ready_to_clone, ready_to_clone) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_demon_gulaemon = {}

function scripts.enemy_demon_gulaemon.update(this, store)
	local cont, blocker, is_flying
	local a = this.timed_actions.list[1]
	local sp = this.render.sprites[1]

	this.is_flying = false
	a.ts = store.tick_ts

	local function ready_for_takeoff()
		return not is_flying and store.tick_ts - a.ts >= a.cooldown and P:nodes_to_defend_point(this.nav_path) > a.nodes_limit_start
	end

	local function ready_to_land()
		return this._should_land
	end

	local function patch_offsets(factor)
		this.health_bar.offset.y = this.health_bar.offset.y + factor * a.off_health_bar_y
		this.ui.click_rect.pos.y = this.ui.click_rect.pos.y + factor * a.off_click_rect_y
		this.unit.mod_offset.y = this.unit.mod_offset.y + factor * a.off_mod_offset_y
		this.unit.hit_offset.y = this.unit.hit_offset.y + factor * a.off_hit_offset_y
	end

	::label_113_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_land() and not this.health.dead then
				this._should_land = nil
				this.health_bar.hidden = true

				local an, af = U.animation_name_facing_point(this, "land", this.motion.dest)

				U.animation_start(this, an, af, store.tick_ts)

				while not U.animation_finished(this) and not this.health.dead do
					coroutine.yield()
				end

				this.health_bar.hidden = this.health.dead
				is_flying = false

				patch_offsets(-1)

				sp.prefix = sp.prefix_ground
				sp.name = "idle"
				this.vis.bans = U.flag_clear(this.vis.bans, a.bans_air)
				this.vis.flags = U.flag_clear(this.vis.flags, a.flags_air)
				this.unit.disintegrate_fx = "fx_enemy_desintegrate"
				a.ts = store.tick_ts

				goto label_113_0
			end

			cont, blocker = SU.y_enemy_walk_until_blocked(store, this, is_flying, ready_to_land)

			if not cont then
				-- block empty
			else
				if blocker and not is_flying then
					if ready_for_takeoff() then
						is_flying = true

						U.cleanup_blockers(store, this)
						SU.remove_modifiers_by_type(store, this, MOD_TYPE_SLOW)
						patch_offsets(1)

						sp.prefix = sp.prefix_air
						this.vis.bans = U.flag_set(this.vis.bans, a.bans_air)
						this.vis.flags = U.flag_set(this.vis.flags, a.flags_air)
						this.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
						this.health_bar.hidden = true

						local an, af = U.animation_name_facing_point(this, "takeoff", this.motion.dest)

						U.y_animation_play(this, an, af, store.tick_ts)

						this.health_bar.hidden = nil

						local m = E:create_entity(a.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = this.id

						queue_insert(store, m)

						goto label_113_0
					else
						if not SU.y_wait_for_blocker(store, this, blocker) then
							goto label_113_0
						end

						while SU.can_melee_blocker(store, this, blocker) do
							if not SU.y_enemy_melee_attacks(store, this, blocker) then
								goto label_113_0
							end

							coroutine.yield()
						end
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_necromancer = {}

function scripts.enemy_necromancer.update(this, store)
	local a = this.timed_actions.list[1]
	local cg = store.count_groups[a.count_group_type]

	a.ts = store.tick_ts

	local function summon_count_exceeded()
		return cg[a.count_group_name] and cg[a.count_group_name] >= a.count_group_max
	end

	local function ready_to_summon()
		if U.get_blocker(store, this) then
			a.ts = store.tick_ts

			return false
		else
			return store.tick_ts - a.ts >= a.cooldown and not summon_count_exceeded() and this.enemy.can_do_magic
		end
	end

	::label_117_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_summon() then
				U.animation_start(this, a.animation, nil, store.tick_ts, false)

				if SU.y_enemy_wait(store, this, a.spawn_time) then
					goto label_117_0
				end

				for i = 1, a.max_count do
					if SU.y_enemy_wait(store, this, a.spawn_delay) then
						goto label_117_0
					end

					if i ~= 1 and summon_count_exceeded() then
						break
					end

					local e_name = a.entity_names[U.random_table_idx(a.entity_chances)]
					local e = E:create_entity(e_name)
					local noff = a.summon_offsets[i] or a.summon_offsets[1]

					e.nav_path.pi = this.nav_path.pi
					e.nav_path.spi = noff[1]
					e.nav_path.ni = this.nav_path.ni + math.random(noff[2], noff[3])
					e.render.sprites[1].name = a.spawn_animation
					e.enemy.gold = 0

					E:add_comps(e, "count_group")

					e.count_group.name = a.count_group_name
					e.count_group.type = a.count_group_type

					if P:is_node_valid(e.nav_path.pi, e.nav_path.ni) then
						queue_insert(store, e)
					end

					coroutine.yield()
				end

				U.y_animation_wait(this)

				a.ts = store.tick_ts
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, ready_to_summon, ready_to_summon) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_demon_cerberus = {}

function scripts.enemy_demon_cerberus.update(this, store)
	if this.sleeping then
		local original_bans = this.vis.bans

		this.health_bar.hidden = true
		this.health.immune_to = DAMAGE_ALL
		this.ui.can_select = false
		this.vis.bans = F_ALL

		U.animation_start(this, "sleeping", nil, store.tick_ts, true)

		while this.sleeping do
			coroutine.yield()
		end

		this.health_bar.hidden = false
		this.health.immune_to = 0
		this.ui.can_select = true
		this.vis.bans = original_bans
		this.render.sprites[1].name = "raise"
	end

	return scripts.enemy_mixed.update(this, store)
end

scripts.enemy_troll_skater = {}

function scripts.enemy_troll_skater.update(this, store)
	local walking_angles = this.render.sprites[1].angles.walk

	this._last_on_ice = false

	local function on_ice()
		return band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_ICE) ~= 0
	end

	local function ice_changed()
		return this._last_on_ice ~= on_ice()
	end

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ice_changed() then
				if on_ice() then
					this._last_on_ice = true
					this.vis.bans = U.flag_set(this.vis.bans, this.skate.vis_bans_extra)
					this.render.sprites[1].angles.walk = this.skate.walk_angles

					local m = E:create_entity(this.skate.mod)

					m.modifier.source_id = this.id
					m.modifier.target_id = this.id

					queue_insert(store, m)

					this.skate._mod = m
				else
					this._last_on_ice = false
					this.vis.bans = U.flag_clear(this.vis.bans, this.skate.vis_bans_extra)
					this.render.sprites[1].angles.walk = walking_angles

					if this.skate._mod then
						queue_remove(store, this.skate._mod)

						this.skate._mod = nil
					end
				end
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, skating, ice_changed) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.enemy_witch = {}

function scripts.enemy_witch.get_info(this)
	local out = scripts.enemy_basic.get_info(this)
	local mod = E:get_template("mod_witch_frog")

	out.damage_min = mod.modifier.damage_min
	out.damage_max = mod.modifier.damage_max

	return out
end

scripts.enemy_spectral_knight = {}

function scripts.enemy_spectral_knight.insert(this, store)
	if not scripts.enemy_basic.insert(this, store) then
		return false
	end

	if this.render.sprites[1].name == "raise" then
		this._raise_vis_bans = this.vis.bans
		this._raise_ignore_damage = this.health.ignore_damage
		this.vis.bans = bor(F_ALL)
		this.health.ignore_damage = true
		this.health_bar.hidden = true
	end

	return true
end

function scripts.enemy_spectral_knight.update(this, store)
	if this.render.sprites[1].name == "raise" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise, this.sound_events.raise_args)
		end

		local an, af = U.animation_name_facing_point(this, "raise", this.motion.dest)

		U.y_animation_play(this, an, af, store.tick_ts, 1)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end

		if this._raise_vis_bans then
			this.vis.bans = this._raise_vis_bans
			this.health.ignore_damage = this._raise_ignore_damage
		end

		U.animation_start(this, "idle", af, store.tick_ts, true)
	end

	return scripts.enemy_mixed.update(this, store)
end

scripts.eb_juggernaut = {}

function scripts.eb_juggernaut.get_info(this)
	local ma = this.melee.attacks[1]
	local min, max = ma.damage_min, ma.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_juggernaut.insert(this, store, script)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.eb_juggernaut.update(this, store, script)
	local ma = this.timed_attacks.list[1]
	local ba = this.timed_attacks.list[2]

	local function ready_to_shoot()
		for _, a in pairs(this.timed_attacks.list) do
			if store.tick_ts - a.ts > a.cooldown then
				return true
			end
		end

		return false
	end

	ma.ts = store.tick_ts
	ba.ts = store.tick_ts

	::label_129_0::

	while true do
		if this.health.dead then
			LU.kill_all_enemies(store, true)
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			for _, a in pairs(this.timed_attacks.list) do
				if store.tick_ts - a.ts < a.cooldown then
					-- block empty
				else
					local target

					if a == ma then
						local targets = U.find_soldiers_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

						if not targets then
							SU.delay_attack(store, a, 0.5)

							goto label_129_1
						end

						target = targets[1]
					end

					U.animation_start(this, a.animation, nil, store.tick_ts, false)
					U.y_wait(store, a.shoot_time)

					local af = this.render.sprites[1].flip_x
					local o = a.bullet_start_offset
					local b = E:create_entity(a.bullet)

					b.bullet.source_id = this.id
					b.bullet.target_id = target and target.id
					b.bullet.from = V.v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
					b.pos = V.vclone(b.bullet.from)

					if a == ma then
						b.bullet.to = V.v(b.pos.x + a.launch_vector.x, b.pos.y + a.launch_vector.y)
					else
						b.bullet.to = P:get_random_position(20, TERRAIN_LAND, NF_RANGE, 30)
						b.bullet.hit_payload = E:create_entity(b.bullet.hit_payload)
						b.bullet.hit_payload.spawner.owner_id = this.id
					end

					if b.bullet.to then
						queue_insert(store, b)
					else
						log.debug("could not find random position to shoot juggernaut bomb. skipping...")
					end

					U.y_animation_wait(this)

					a.ts = store.tick_ts
				end

				::label_129_1::
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_shoot)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_129_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_shoot() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_129_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_jt = {}

function scripts.eb_jt.get_info(this)
	local ma = this.melee.attacks[1]
	local min, max = ma.damage_min, ma.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_jt.on_damage(this, store, damage)
	local pd = U.predict_damage(this, damage)

	if pd >= this.health.hp then
		this.dying = true
		this.health_bar.hidden = true
		this.health.ignore_damage = true
		this.ui.can_select = false
		this.vis.bans = F_ALL

		SU.remove_modifiers(store, this)
		SU.stun_inc(this)

		return false
	end

	return true
end

function scripts.eb_jt.update(this, store)
	local fa = this.timed_attacks.list[1]

	local function ready_to_freeze()
		return store.tick_ts - fa.ts > fa.cooldown
	end

	fa.ts = store.tick_ts

	::label_133_0::

	while true do
		if this.dying then
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)

			if IS_CONSOLE then
				U.y_wait(store, this.tap_timeout)
			else
				local tap = SU.insert_sprite(store, this.tap_decal, this.pos)

				this.ui.clicked = nil

				while not this.ui.clicked do
					coroutine.yield()
				end

				queue_remove(store, tap)
			end

			S:stop_all()
			S:queue(this.sound_events.death_explode)
			U.y_animation_play(this, "death_end", nil, store.tick_ts)

			this.health.ignore_damage = false
			this.health.hp = 0

			coroutine.yield()
			LU.kill_all_enemies(store, true)
			signal.emit("boss-killed", this)

			return
		end

		if this.unit.is_stunned and not this.dying then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_freeze() then
				local towers = U.find_towers_in_range(store.entities, this.pos, fa, function(t)
					return t.tower.can_be_mod
				end)

				if not towers then
					SU.delay_attack(store, fa, 0.5)
				else
					SU.hide_modifiers(store, this, true)
					U.animation_start(this, "freeze", nil, store.tick_ts, 1)
					S:queue(fa.sound, fa.sound_args)
					U.y_wait(store, fa.hit_time)

					local hit_pos = V.vclone(this.pos)
					local af = this.render.sprites[1].flip_x

					if fa.hit_offset then
						hit_pos.x = hit_pos.x + (af and -1 or 1) * fa.hit_offset.x
						hit_pos.y = hit_pos.y + fa.hit_offset.y
					end

					SU.insert_sprite(store, fa.hit_decal, hit_pos)

					for i, t in ipairs(towers) do
						if i >= fa.count then
							break
						end

						local m = E:create_entity(fa.mod)

						m.modifier.target_id = t.id
						m.modifier.source_id = this.id

						queue_insert(store, m)
					end

					U.y_animation_wait(this)
					SU.show_modifiers(store, this, true)

					fa.ts = store.tick_ts

					U.animation_start(this, "breath", nil, store.tick_ts, -1)
					S:queue(fa.exhausted_sound, fa.exhausted_sound_args)

					if SU.y_enemy_wait(store, this, fa.exhausted_duration) then
						goto label_133_0
					end
				end
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_freeze)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_133_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_freeze() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_133_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.jt_spawner_aura = {}

function scripts.jt_spawner_aura.update(this, store)
	local spawn_ts = {}

	for i = 1, #this.spawn_data do
		spawn_ts[i] = store.tick_ts
	end

	local owner = store.entities[this.aura.source_id]

	if not owner then
		log.error("owner %s was not found. baling out", this.aura.source_id)
	else
		while not owner.dying do
			for i, v in ipairs(this.spawn_data) do
				local template, cooldown, delay, pi, spi = unpack(v)

				if store.tick_ts - spawn_ts[i] >= cooldown + delay then
					local e = E:create_entity(template)

					e.nav_path.pi = pi
					e.nav_path.spi = spi
					e.nav_path.ni = P:get_start_node(pi)

					queue_insert(store, e)

					spawn_ts[i] = store.tick_ts - delay
				end
			end

			coroutine.yield()
		end
	end

	queue_remove(store, this)
end

scripts.mod_jt_tower = {}

function scripts.mod_jt_tower.update(this, store)
	local clicks = 0
	local s_tap = this.render.sprites[2]
	local target = store.entities[this.modifier.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	SU.tower_block_inc(target)

	this.pos.x, this.pos.y = target.pos.x, target.pos.y

	U.y_animation_play(this, "start", nil, store.tick_ts, 1, 1)

	s_tap.hidden = nil

	SU.ui_click_proxy_add(target, this)

	while clicks < this.required_clicks do
		if IS_CONSOLE then
			if target.ui.hover_controller_active then
				s_tap.alpha = s_tap.alpha_focused
				s_tap.name = s_tap.name_focused
			else
				s_tap.alpha = s_tap.alpha_unfocused
				s_tap.name = s_tap.name_unfocused
			end
		end

		if this.ui.clicked then
			S:queue(this.sound_events.click)
			SU.insert_sprite(store, this.ui.click_fx, target.pos)

			this.ui.clicked = nil
			clicks = clicks + 1
		end

		coroutine.yield()
	end

	SU.ui_click_proxy_remove(target, this)

	this.ui.can_click = false
	s_tap.hidden = true

	U.animation_start(this, "end", nil, store.tick_ts, false, 1)
	U.y_wait(store, this.end_delay)
	SU.tower_block_dec(target)
	U.y_animation_wait(this)

	if this.tween then
		this.tween.ts = store.tick_ts
		this.tween.props[1].disabled = nil

		U.y_wait(store, 2)
	end

	queue_remove(store, this)
end

scripts.eb_veznan = {}

function scripts.eb_veznan.get_info(this)
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

function scripts.eb_veznan.on_damage(this, store, damage)
	if this.phase == "battle" then
		local pd = U.predict_damage(this, damage)

		if pd >= this.health.hp then
			this.phase_signal = true

			return false
		end
	elseif this.phase == "demon" then
		local pd = U.predict_damage(this, damage)

		if pd >= this.health.hp then
			this.phase_signal = true

			return false
		end
	end

	return true
end

function scripts.eb_veznan.update(this, store)
	local ba = this.timed_attacks.list[1]
	local pa = this.timed_attacks.list[2]
	local taunt_ts
	local portals = LU.list_entities(store.entities, pa.portal_name)
	local initial_hp = this.health.hp_max

	local function y_taunt(idx, set)
		U.animation_start(this, "laugh", nil, store.tick_ts, true)
		SU.y_show_taunt_set(store, this.taunts, set or this.phase, idx, nil, nil, true)
		U.y_animation_wait(this)
		U.animation_start(this, "idleDown", nil, store.tick_ts, true)
	end

	local function y_block_towers()
		local towers = table.filter(store.entities, function(_, e)
			return e.tower and e.tower.can_be_mod and not U.has_modifiers(store, e, ba.mod)
		end)

		if not towers or #towers == 0 then
			SU.delay_attack(store, ba, 0.5)

			return
		end

		local start_ts = store.tick_ts

		U.animation_start(this, ba.animation, nil, store.tick_ts)
		U.y_wait(store, ba.hit_time)
		S:queue(ba.sound)

		local random_towers = table.random_order(towers)

		for i, t in ipairs(random_towers) do
			if i > ba.count then
				break
			end

			local m = E:create_entity(ba.mod)

			m.modifier.target_id = t.id
			m.modifier.source_id = this.id

			queue_insert(store, m)
		end

		U.y_animation_wait(this)
		U.y_wait(store, ba.attack_duration - (store.tick_ts - start_ts))

		ba.ts = store.tick_ts

		if this.phase == "castle" then
			U.animation_start(this, "idleDown", nil, store.tick_ts, true)
		end
	end

	local function y_portal()
		local start_ts = store.tick_ts

		U.animation_start(this, pa.animation, nil, store.tick_ts)
		U.y_wait(store, pa.hit_time)
		S:queue(pa.sound)

		pa.count = pa.count + 1

		for _, p in pairs(portals) do
			if pa.portals[p.portal_idx] ~= 1 then
				-- block empty
			else
				p.spawn_signal = true
			end
		end

		U.y_animation_wait(this)
		U.y_wait(store, pa.attack_duration - (store.tick_ts - start_ts))

		pa.ts = store.tick_ts

		if this.phase == "castle" then
			U.animation_start(this, "idleDown", nil, store.tick_ts, true)
		end
	end

	local function signal_ready()
		return this.phase_signal
	end

	local function battle_started()
		return store.wave_group_number >= 1
	end

	local function ready_to_block()
		return not ba.disabled and store.tick_ts - ba.ts >= ba.cooldown
	end

	local function ready_to_portal()
		return not pa.disabled and store.tick_ts - pa.ts >= pa.cooldown and pa.count < pa.max_count
	end

	local function can_break_battle_walk()
		return ready_to_block() or ready_to_portal() or this.phase_signal
	end

	this.phase_signal = nil
	this.phase_signal = nil

	while not this.phase_signal do
		coroutine.yield()
	end

	this.phase = "welcome"

	for i, d in ipairs(this.taunts.sets.welcome.delays) do
		if U.y_wait(store, d, battle_started) then
			break
		end

		y_taunt(i)
	end

	while not battle_started() do
		coroutine.yield()
	end

	y_taunt(5)

	this.phase = "castle"

	local last_lives = store.lives
	local last_wave
	local taunt_cooldown = math.random(this.taunts.delay_min, this.taunts.delay_max)

	ba.ts = store.tick_ts
	pa.ts = store.tick_ts
	taunt_ts = store.tick_ts
	this.phase_signal = nil

	while not this.phase_signal do
		if store.wave_group_number ~= last_wave and not this.phase_signal then
			local ba_wave_data = ba.data[store.wave_group_number]

			ba.disabled = not ba_wave_data

			if not ba.disabled then
				ba.cooldown = ba_wave_data and ba_wave_data[1] or 0
				ba.count = ba_wave_data and ba_wave_data[2] or 0
			end

			local pa_wave_data = pa.data[store.wave_group_number]

			pa.disabled = not pa_wave_data

			if not pa.disabled then
				pa.cooldown, pa.max_count, pa.portals = unpack(pa_wave_data)
				pa.count = 0
			end

			last_wave = store.wave_group_number
		end

		if taunt_cooldown <= store.tick_ts - taunt_ts and not this.phase_signal then
			y_taunt(nil, last_lives > store.lives and "damage" or nil)

			last_lives = store.lives
			taunt_ts = store.tick_ts
			taunt_cooldown = math.random(this.taunts.delay_min, this.taunts.delay_max)
		end

		if ready_to_block() and not this.phase_signal then
			y_block_towers()
		end

		if ready_to_portal() and not this.phase_signal then
			y_portal()
		end

		coroutine.yield()
	end

	this.phase = "pre_battle"

	local battle_ts = store.tick_ts

	pa.cooldown = this.battle.pa_cooldown
	pa.max_count = this.battle.pa_max_count
	pa.animation = this.battle.pa_animation
	ba.animation = this.battle.ba_animation

	U.y_wait(store, fts(24))
	y_taunt()
	U.y_wait(store, battle_ts + fts(115) - store.tick_ts)
	U.y_animation_play(this, "walkAway", nil, store.tick_ts)

	this.nav_path.pi, this.nav_path.spi, this.nav_path.ni = 1, 1, 1
	this.pos = P:node_pos(this.nav_path)
	pa.ts = store.tick_ts
	ba.ts = store.tick_ts
	this.vis.bans = U.flag_clear(this.vis.bans, F_ALL)
	this.health.ignore_damage = false
	this.health_bar.hidden = nil
	this.phase_signal = nil
	this.phase = "battle"

	while not this.phase_signal do
		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_block() and not this.phase_signal then
				y_block_towers()
			end

			if ready_to_portal() and not this.phase_signal then
				y_portal()
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, can_break_battle_walk, can_break_battle_walk) then
				-- block empty
			else
				coroutine.yield()
			end
		end
	end

	this.health_bar.hidden = true
	this.vis.bans = U.flag_set(this.vis.bans, F_ALL)

	SU.remove_modifiers(store, this)
	S:queue(this.demon.transform_sound)
	U.y_animation_play(this, "demonTransform", nil, store.tick_ts, 1)

	this.enemy.melee_slot = this.demon.melee_slot
	this.health.hp = initial_hp
	this.health.hp_max = initial_hp
	this.health_bar.offset = this.demon.health_bar_offset
	this.health_bar.frames[1].bar_width = this.health_bar.frames[1].bar_width * this.demon.health_bar_scale
	this.health_bar.frames[2].bar_width = this.health_bar.frames[2].bar_width * this.demon.health_bar_scale
	this.health_bar.frames[1].scale.x = this.health_bar.frames[1].scale.x * this.demon.health_bar_scale
	this.health_bar.frames[2].scale.x = this.health_bar.frames[2].scale.x * this.demon.health_bar_scale
	this.melee.attacks[1].disabled = true
	this.melee.attacks[2].disabled = false
	this.motion.max_speed = this.demon.speed
	this.render.sprites[1].prefix = this.demon.sprites_prefix
	this.ui.click_rect = this.demon.ui_click_rect
	this.unit.hit_offset = this.demon.unit_hit_offset
	this.unit.mod_offset = this.demon.unit_mod_offset
	this.unit.size = this.demon.unit_size
	this.info.portrait = this.demon.info_portrait
	this.health_bar.hidden = nil
	this.vis.bans = U.flag_clear(this.vis.bans, F_ALL)
	this.phase_signal = nil
	this.phase = "demon"

	while not this.phase_signal do
		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		elseif not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, signal_ready, signal_ready) then
			-- block empty
		else
			coroutine.yield()
		end
	end

	this.phase = "death"
	this.health_bar.hidden = true
	this.health.ignore_damage = true
	this.ui.can_click = false
	this.vis.bans = U.flag_set(this.vis.bans, F_ALL)

	SU.remove_modifiers(store, this)
	LU.kill_all_enemies(store, true)
	S:stop_all()
	S:queue(this.sound_events.death)
	signal.emit("boss-killed", this)
	U.animation_start(this, "death", nil, store.tick_ts, 1)
	signal.emit("hide-gui")
	U.y_wait(store, fts(110))
	LU.kill_all_enemies(store, true)

	local sc = E:create_entity(this.souls_aura)

	sc.pos = V.vclone(this.pos)
	sc.pos.y = sc.pos.y + 14

	queue_insert(store, sc)
	U.y_animation_wait(this)
	U.animation_start(this, "deathLoop", nil, store.tick_ts, true)
	U.y_wait(store, fts(90))

	sc.interrupt = true

	LU.kill_all_enemies(store, true)
	U.animation_start(this, "deathEnd", nil, store.tick_ts, true)

	local circle = E:create_entity(this.white_circle)

	circle.pos.x, circle.pos.y = this.pos.x + 6, this.pos.y + 12
	circle.tween.ts = store.tick_ts
	circle.render.sprites[1].ts = store.tick_ts

	queue_insert(store, circle)
	U.y_wait(store, fts(65) + 2)

	this.phase = "death-end"

	queue_remove(store, this)
end

scripts.veznan_portal = {}

function scripts.veznan_portal.update(this, store)
	local spawns = this.spawn_groups[this.portal_idx]
	local ni = this.out_nodes[this.pi]

	while true do
		while not this.spawn_signal do
			coroutine.yield()
		end

		U.y_animation_play(this, "start", nil, store.tick_ts)

		local roll = math.random()
		local entity_data

		for _, s in pairs(spawns) do
			if roll <= s[1] then
				entity_data = s[2]

				break
			end
		end

		U.animation_start(this, "active", nil, store.tick_ts, true)

		for _, d in pairs(entity_data) do
			local min, max, template = unpack(d)
			local count = min ~= max and math.random(min, max) or min

			for i = 1, count do
				local e = E:create_entity(template)

				e.nav_path.pi = this.pi
				e.nav_path.spi = math.random(1, 3)
				e.nav_path.ni = ni
				e.pos = V.vclone(this.pos)

				queue_insert(store, e)
				U.y_wait(store, this.spawn_interval)
			end
		end

		U.y_animation_wait(this)
		U.y_animation_play(this, "end", nil, store.tick_ts)

		this.spawn_signal = nil

		coroutine.yield()
	end
end

scripts.mod_veznan_tower = {}

function scripts.mod_veznan_tower.update(this, store)
	local clicks = 0
	local s_tap = this.render.sprites[2]
	local target = store.entities[this.modifier.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	this.pos.x, this.pos.y = target.pos.x, target.pos.y

	U.y_animation_play(this, "start", nil, store.tick_ts, 1, 1)

	s_tap.hidden = nil

	U.animation_start(this, "preHold", nil, store.tick_ts, true, 1)
	SU.tower_block_inc(target)

	local hold_ts = store.tick_ts

	SU.ui_click_proxy_add(target, this)

	while clicks < this.required_clicks and store.tick_ts - hold_ts < this.click_time do
		if IS_CONSOLE then
			if target.ui.hover_controller_active then
				s_tap.alpha = s_tap.alpha_focused
				s_tap.name = s_tap.name_focused
			else
				s_tap.alpha = s_tap.alpha_unfocused
				s_tap.name = s_tap.name_unfocused
			end
		end

		if this.ui.clicked then
			S:queue(this.sound_click)

			this.ui.clicked = nil
			clicks = clicks + 1

			if clicks >= this.required_clicks then
				goto label_151_0
			end
		end

		coroutine.yield()
	end

	s_tap.hidden = true

	S:queue(this.sound_blocked)
	U.animation_start(this, "hold", nil, store.tick_ts, 1, 1)
	U.y_wait(store, this.duration)

	::label_151_0::

	SU.ui_click_proxy_remove(target, this)

	s_tap.hidden = true

	S:queue(this.sound_released)
	U.y_animation_play(this, "remove", nil, store.tick_ts, 1, 1)
	SU.tower_block_dec(target)
	queue_remove(store, this)
end

scripts.veznan_souls_aura = {}

function scripts.veznan_souls_aura.update(this, store)
	local count = 0

	for i = 1, this.souls.count do
		if this.interrupt then
			break
		end

		local e = E:create_entity(this.souls.entity)

		e.angle = U.frandom(this.souls.angles[1], this.souls.angles[2])
		e.pos = V.vclone(this.pos)
		e.soul_phase = 1 - i / this.souls.count

		queue_insert(store, e)

		if this.souls.delay_frames >= 2 then
			this.souls.delay_frames = this.souls.delay_frames - 1
		end

		U.y_wait(store, fts(this.souls.delay_frames))
	end

	queue_remove(store, this)
end

scripts.veznan_soul = {}

function scripts.veznan_soul.update(this, store)
	local speed = math.random(this.speed[1], this.speed[2])
	local inc = math.random() > 0.5 and this.angle_variation or -this.angle_variation
	local angle_var = 0
	local start_ts = store.tick_ts
	local last_ts = store.tick_ts
	local ps = E:create_entity(this.particles_name)

	ps.particle_system.track_id = this.id

	local pl = ps.particle_system.particle_lifetime

	pl[1], pl[2] = pl[1] * this.soul_phase, pl[2] * this.soul_phase

	queue_insert(store, ps)

	while store.tick_ts - start_ts < this.duration do
		local dt = store.tick_ts - last_ts
		local a = this.angle + angle_var
		local x_step, y_step = V.rotate(a, speed * dt, 0)

		this.render.sprites[1].r = a
		this.pos.x = this.pos.x + x_step
		this.pos.y = this.pos.y + y_step
		angle_var = angle_var + inc

		if angle_var >= this.max_angle then
			inc = -this.angle_variation
		elseif angle_var <= this.min_angle then
			inc = this.angle_variation
		end

		last_ts = store.tick_ts

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.eb_greenmuck = {}

function scripts.eb_greenmuck.get_info(this)
	local ma = this.melee.attacks[1]
	local min, max = ma.damage_min, ma.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_greenmuck.update(this, store)
	local ba = this.timed_attacks.list[1]

	local function ready_to_shoot()
		return store.tick_ts - ba.ts > ba.cooldown
	end

	ba.ts = store.tick_ts

	::label_155_0::

	while true do
		if this.health.dead then
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			SU.fade_out_entity(store, this, this.unit.fade_time_after_death)

			local spawner = LU.list_entities(store.entities, "s15_rotten_spawner")[1]

			if spawner then
				spawner.interrupt = true
			end

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_shoot() then
				local targets = table.filter(store.entities, function(_, e)
					return not e.pending_removal and e.soldier and e.vis and e.health and not e.health.dead and band(e.vis.flags, ba.vis_bans) == 0 and band(e.vis.bans, ba.vis_flags) == 0
				end)

				if #targets < 1 then
					SU.delay_attack(store, ba, 0.5)
				else
					U.animation_start(this, ba.animation, nil, store.tick_ts, false)
					U.y_wait(store, ba.shoot_time)

					local af = this.render.sprites[1].flip_x
					local o = ba.bullet_start_offset
					local random_targets = table.random_order(targets)

					for i, t in ipairs(random_targets) do
						if i > ba.count then
							break
						end

						local b = E:create_entity(ba.bullet)

						b.bullet.source_id = this.id
						b.bullet.target_id = t
						b.bullet.from = V.v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
						b.bullet.to = V.vclone(t.pos)
						b.pos = V.vclone(b.bullet.from)

						queue_insert(store, b)
					end

					U.y_animation_wait(this)

					ba.ts = store.tick_ts
				end
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_shoot)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_155_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_shoot() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_155_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_greenmuck = {}
function scripts.enemy_greenmuck.update(this, store)
	local ba = this.timed_attacks.list[1]

	local function ready_to_shoot()
		return store.tick_ts - ba.ts > ba.cooldown
	end

	ba.ts = store.tick_ts

	::label_155_0::

	while true do
		if this.health.dead then
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			SU.fade_out_entity(store, this, this.unit.fade_time_after_death)
			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_shoot() then
				local targets = table.filter(store.entities, function(_, e)
					return not e.pending_removal and e.soldier and e.vis and e.health and not e.health.dead and band(e.vis.flags, ba.vis_bans) == 0 and band(e.vis.bans, ba.vis_flags) == 0
				end)

				if #targets < 1 then
					SU.delay_attack(store, ba, 0.5)
				else
					U.animation_start(this, ba.animation, nil, store.tick_ts, false)
					U.y_wait(store, ba.shoot_time)

					local af = this.render.sprites[1].flip_x
					local o = ba.bullet_start_offset
					local random_targets = table.random_order(targets)

					for i, t in ipairs(random_targets) do
						if i > ba.count then
							break
						end

						local b = E:create_entity(ba.bullet)

						b.bullet.source_id = this.id
						b.bullet.target_id = t
						b.bullet.from = V.v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
						b.bullet.to = V.vclone(t.pos)
						b.pos = V.vclone(b.bullet.from)

						queue_insert(store, b)
					end

					U.y_animation_wait(this)

					ba.ts = store.tick_ts
				end
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_shoot)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_155_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_shoot() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_155_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_kingpin = {}

function scripts.eb_kingpin.get_info(this)
	local ma = this.melee.attacks[1]
	local min, max = ma.damage_min, ma.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_kingpin.update(this, store)
	local hs = this.timed_attacks.list[1]
	local ho = this.timed_attacks.list[2]
	local stop_ts

	local function ready_to_stop()
		return store.tick_ts - stop_ts > this.stop_cooldown
	end

	stop_ts = store.tick_ts

	::label_159_0::

	while true do
		if this.health.dead then
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			SU.fade_out_entity(store, this, this.unit.fade_time_after_death)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_stop() then
				local stop_start = store.tick_ts
				local a = table.random(this.timed_attacks.list)

				U.animation_start(this, a.animation, nil, store.tick_ts, false)

				if SU.y_enemy_wait(store, this, this.stop_wait) then
					goto label_159_0
				end

				local targets

				if a == hs and this.health.hp < this.health.hp_max then
					targets = {
						this
					}
				elseif a == ho then
					targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
						return e.health.hp < e.health.hp_max and e ~= this
					end)
				end

				if targets then
					for _, target in pairs(targets) do
						local m = E:create_entity(a.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = target.id

						queue_insert(store, m)
					end
				end

				if SU.y_enemy_animation_wait(this) then
					goto label_159_0
				end

				U.animation_start(this, a.animation, nil, store.tick_ts, false)

				if SU.y_enemy_animation_wait(this) then
					goto label_159_0
				end

				if SU.y_enemy_wait(store, this, this.stop_time - (store.tick_ts - stop_start)) then
					goto label_159_0
				end

				stop_ts = store.tick_ts
			end

			SU.y_enemy_walk_until_blocked(store, this, false, ready_to_stop)
		end
	end
end

scripts.eb_ulgukhai = {}

function scripts.eb_ulgukhai.get_info(this)
	local ma = this.melee.attacks[1]
	local min, max = ma.damage_min, ma.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_ulgukhai.update(this, store)
	::label_163_0::

	while true do
		if this.health.dead then
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			SU.fade_out_entity(store, this, this.unit.fade_time_after_death)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			this.health.ignore_damage = true
			this.unit.blood_color = BLOOD_NONE
			this.vis.bans = U.flag_set(this.vis.bans, this.shielded_extra_vis_bans)

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false)

			if not cont then
				-- block empty
			else
				if blocker then
					this.health.ignore_damage = nil
					this.unit.blood_color = BLOOD_RED
					this.vis.bans = U.flag_clear(this.vis.bans, this.shielded_extra_vis_bans)

					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_163_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_163_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_moloch = {}

function scripts.eb_moloch.get_info(this)
	local ma = this.melee.attacks[1]
	local min, max = ma.damage_min, ma.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_moloch.update(this, store)
	local ha = this.timed_attacks.list[1]

	local function ready_to_horn()
		return store.tick_ts - ha.ts > ha.cooldown
	end

	U.animation_start(this, "sitting", nil, store.tick_ts, true)

	this.phase = "sitting"
	this.phase_signal = nil
	this.health_bar.hidden = true

	while not this.phase_signal do
		coroutine.yield()
	end

	U.y_wait(store, this.stand_up_wait_time)
	S:queue(this.stand_up_sound)
	U.y_animation_play(this, "raise", nil, store.tick_ts)

	this.health_bar.hidden = nil
	this.health.ignore_damage = nil
	this.vis.bans = this.active_vis_bans
	ha.ts = store.tick_ts

	::label_165_0::

	while true do
		if this.health.dead then
			game.store.force_next_wave = true
			this.phase = "dead"

			LU.kill_all_enemies(store, true)
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
			if ready_to_horn() then
				local dest = V.vclone(this.pos)
				local af = this.render.sprites[1].flip_x and -1 or 1

				if ha.hit_offset then
					dest.x = dest.x + af * ha.hit_offset.x
					dest.y = dest.y + ha.hit_offset.y
				end

				local targets = U.find_soldiers_in_range(store.entities, dest, 0, ha.damage_radius, ha.vis_flags or 0, ha.vis_bans or 0)

				if not targets or #targets < ha.min_targets then
					SU.delay_attack(store, ha, 0.5)
				else
					SU.hide_modifiers(store, this, true)
					S:queue(ha.sound, ha.sound_args)
					U.animation_start(this, ha.animation, nil, store.tick_ts, false)

					if SU.y_enemy_wait(store, this, ha.hit_time) then
						goto label_165_0
					end

					targets = U.find_soldiers_in_range(store.entities, dest, 0, ha.damage_radius, ha.vis_flags or 0, ha.vis_bans or 0)

					if targets then
						for _, t in pairs(targets) do
							local d = SU.create_attack_damage(ha, t.id, this.id)

							queue_damage(store, d)
						end
					end

					for _, f in pairs(ha.fx_list) do
						local fx_name, positions = unpack(f)

						for _, p in pairs(positions) do
							local xo, yo = unpack(p)
							local fx = E:create_entity(fx_name)

							fx.render.sprites[1].ts = store.tick_ts
							fx.pos.x = this.pos.x + xo * af
							fx.pos.y = this.pos.y + yo

							queue_insert(store, fx)
						end
					end

					U.y_wait(store, fts(12))
					SU.show_modifiers(store, this, true)
					U.y_animation_wait(this)

					ha.ts = store.tick_ts
				end
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_horn)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_165_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_horn() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_165_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_myconid = {}

function scripts.eb_myconid.get_info(this)
	local ma = this.melee.attacks[1]
	local min, max = ma.damage_min, ma.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_myconid.update(this, store)
	local sa = this.timed_attacks.list[1]
	local si = 1

	local function ready_to_spore()
		return store.tick_ts - sa.ts > sa.cooldown and this.nav_path.ni > sa.min_nodes
	end

	local function spawn_mushrooms(count, owner)
		local sp = E:create_entity(this.spawner_entity)

		sp.spawner.pi = this.nav_path.pi
		sp.spawner.spi = this.nav_path.spi
		sp.spawner.ni = this.nav_path.ni
		sp.spawner.random_cycle = {
			0,
			1 / count
		}
		sp.spawner.count = count
		sp.spawner.owner_id = owner

		queue_insert(store, sp)
	end

	sa.ts = store.tick_ts

	::label_168_0::

	while true do
		if this.health.dead then
			S:queue(this.sound_events.death)
			U.animation_start(this, "death", nil, store.tick_ts, false)
			U.y_wait(store, this.on_death_spawn_wait)
			spawn_mushrooms(this.on_death_spawn_count, nil)
			signal.emit("boss-killed", this)
			SU.fade_out_entity(store, this, this.unit.fade_time_after_death)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_spore() then
				local fx_wait, mod_wait, spawner_wait = unpack(sa.wait_times)

				S:queue(sa.sound)
				U.animation_start(this, "spores", nil, store.tick_ts, false)

				if SU.y_enemy_wait(store, this, fx_wait) then
					goto label_168_0
				end

				local fx = E:create_entity(sa.fx)

				fx.render.sprites[1].ts = store.tick_ts
				fx.pos = V.vclone(this.pos)

				if sa.fx_offset then
					fx.pos.x = fx.pos.x + sa.fx_offset.x
					fx.pos.y = fx.pos.y + sa.fx_offset.y
				end

				queue_insert(store, fx)

				if SU.y_enemy_wait(store, this, mod_wait) then
					goto label_168_0
				end

				local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, sa.radius, sa.vis_flags, sa.vis_bans)

				if targets then
					for _, target in pairs(targets) do
						local m = E:create_entity(sa.mod)

						m.modifier.target_id = target.id
						m.modifier.source_id = this.id

						queue_insert(store, m)
					end
				end

				if SU.y_enemy_wait(store, this, spawner_wait) then
					goto label_168_0
				end

				spawn_mushrooms(sa.summon_counts[si] or sa.summon_counts[#sa.summon_counts], this.id)

				si = si + 1

				if SU.y_enemy_wait(store, this, sa.final_wait) then
					if sp then
						sp.spawner.interrupt = true
					end

					goto label_168_0
				end

				sa.ts = store.tick_ts
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_spore)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_168_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_spore() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_168_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_blackburn = {}

function scripts.eb_blackburn.get_info(this)
	local ma = this.melee.attacks[1]
	local min, max = ma.damage_min, ma.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_blackburn.on_damage(this, store, damage)
	if not this.second_life then
		local pd = U.predict_damage(this, damage)
		if this.health.hp - pd <= 0 then
			this.ui.can_click = false
			this.first_death = true
			this.vis._original_bans = this.vis.bans
			this.vis.bans = F_ALL
			this.health.ignore_damage = true
			this.health.hp = 1
			this.unit.is_stunned = true
			U.unblock_all(store, this)
			return false
		end
		return true
	end
	return true
end

function scripts.eb_blackburn.update(this, store)
	local sa = this.timed_attacks.list[1]

	local function ready_to_smash()
		return store.tick_ts - sa.ts > sa.cooldown
	end

	sa.ts = store.tick_ts

	::label_172_0::

	while true do
		if this.first_death then
			this.second_life = true
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			U.animation_start(this, "death_end", nil, store.tick_ts, true)
			U.y_wait(store, this.first_death_duration)
			U.animation_start(this, "raise", nil, store.tick_ts)
			S:queue(this.sound_events.death)
			U.y_animation_wait(this)
			this.health.hp_max = math.ceil(this.health.hp_max * this.second_life_hp_factor)
			this.health.hp = this.health.hp_max
			this.health.armor = this.second_life_armor
			this.health.magic_armor = this.second_life_magic_armor
			this.health.ignore_damage = nil
			this.vis.bans = this.vis._original_bans
			this.vis._original_bans = nil
			sa.damage_max = sa.second_life_damage_max
			sa.damage_min = sa.second_life_damage_min
			this.ui.can_click = true
			this.unit.is_stunned = nil
			this.first_death = false
		end

		if this.health.dead then
			LU.kill_all_enemies(store, true)
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)

			this.ui.can_click = false

			local megaspawner = LU.list_entities(store.entities, "mega_spawner")[1]

			if megaspawner then
				megaspawner.interrupt = true
			end

			store.force_next_wave = true

			U.animation_start(this, "death_end", nil, store.tick_ts, true)
			signal.emit("boss-killed", this)
			LU.kill_all_enemies(store, true)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_smash() then
				U.animation_start(this, sa.animation, nil, store.tick_ts, false)
				S:queue(sa.sound, sa.sound_args)

				if SU.y_enemy_wait(store, this, sa.hit_time) then
					goto label_172_0
				end

				local a = E:create_entity(sa.aura_shake)

				queue_insert(store, a)

				local af = this.render.sprites[1].flip_x
				local fx = E:create_entity(sa.fx)

				fx.pos = V.vclone(this.pos)
				fx.render.sprites[1].ts = store.tick_ts
				fx.pos.x = fx.pos.x + (af and -1 or 1) * sa.fx_offset.x
				fx.pos.y = fx.pos.y + (af and -1 or 1) * sa.fx_offset.y

				queue_insert(store, fx)
				SU.insert_sprite(store, sa.hit_decal, fx.pos, af, fts(2))

				if this.second_life then
					local e = E:create_entity(sa.second_life_entity)
					for i, s in ipairs(e.render.sprites) do
						s.flip_x = true
					end
					local spi = math.random(1, 3)
					e.pos = P:node_pos(this.nav_path.pi, spi, km.clamp(1, #P:path(this.nav_path.pi), this.nav_path.ni + sa.entity_node_offset))
					e.nav_path.pi = this.nav_path.pi
					e.nav_path.spi = spi
					e.nav_path.ni = this.nav_path.ni + sa.entity_node_offset + 1
					e.render.sprites[1].name = "raise"
					queue_insert(store, e)
				end

				local towers = U.find_towers_in_range(store.entities, this.pos, sa, function(t)
					return t.tower.can_be_mod
				end)

				if towers then
					for _, tt in pairs(towers) do
						local tm = E:create_entity(sa.mod_towers)

						tm.modifier.source_id = this.id
						tm.modifier.target_id = tt.id

						queue_insert(store, tm)
					end
				end

				local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, sa.damage_radius, sa.vis_flags or 0, sa.vis_bans or 0)

				if targets then
					for _, t in pairs(targets) do
						local d = E:create_entity("damage")

						d.damage_type = sa.damage_type
						d.value = math.random(sa.damage_min, sa.damage_max)
						d.source_id = this.id
						d.target_id = t.id

						queue_damage(store, d)

						local tm = E:create_entity(sa.mod)

						tm.modifier.source_id = this.id
						tm.modifier.target_id = t.id

						queue_insert(store, tm)
					end
				end

				U.y_animation_wait(this)

				if SU.y_enemy_wait(store, this, sa.after_hit_wait) then
					goto label_172_0
				end

				sa.cooldown = sa.after_cooldown
				sa.ts = store.tick_ts
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_smash)

			if not cont then
				-- block empty
			else
				if blocker and blocker.unit and not blocker.unit.is_stunned then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_172_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_smash() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_172_0
						end

						coroutine.yield()
					end
				else
					U.unblock_target(store, blocker)
				end

				coroutine.yield()
			end
		end
	end
end

scripts.mod_blackburn_tower = {}

function scripts.mod_blackburn_tower.update(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	m.ts = store.tick_ts

	SU.tower_block_inc(target)

	this.pos.x, this.pos.y = target.pos.x, target.pos.y

	if this.tween then
		this.tween.disabled = false
		this.tween.reverse = false
		this.tween.ts = store.tick_ts
	end

	U.y_wait(store, m.duration)

	if this.tween then
		this.tween.ts = store.tick_ts
		this.tween.reverse = true
	end

	SU.tower_block_dec(target)
	U.y_wait(store, this.tween.props[1].keys[2][1])
	queue_remove(store, this)
end

scripts.blackburn_aura = {}

function scripts.blackburn_aura.update(this, store)
	local last_ts = store.tick_ts
	local cg = store.count_groups[this.count_group_type]

	while true do
		local source = store.entities[this.aura.source_id]

		if not source or source.health.dead then
			queue_remove(store, this)

			return
		end

		this.pos = source.pos

		if store.tick_ts - last_ts >= this.aura.cycle_time then
			last_ts = store.tick_ts

			for _, e in pairs(store.entities) do
				if e and e.health and not e.health.dead and e.soldier and e.soldier.tower_id == source.id then
					tower_skeletons_count = tower_skeletons_count + 1
				end
			end

			local max_spawns = this.count_group_max - (cg[this.count_group_name] or 0)

			if max_spawns < 1 then
				-- block empty
			else
				local dead_soldiers = table.filter(store.entities, function(k, v)
					return v.soldier and v.health and v.health.dead and band(v.vis.bans or 0, F_SKELETON) == 0 and store.tick_ts - v.health.death_ts >= this.aura.cycle_time and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)
				end)

				dead_soldiers = table.slice(dead_soldiers, 1, max_spawns)

				local spii = math.random(1, 3)

				for _, dead in pairs(dead_soldiers) do
					local nearest_nodes = P:nearest_nodes(dead.pos.x, dead.pos.y, {
						source.nav_path.pi
					})

					if #nearest_nodes < 1 then
						-- block empty
					else
						local pi, spi, ni = unpack(nearest_nodes[1])

						if not P:is_node_valid(pi, ni) then
							-- block empty
						else
							U.sprites_hide(dead)

							dead.vis.bans = bor(dead.vis.bans, F_SKELETON)

							local e = E:create_entity(this.aura.raise_entity)

							spii = km.zmod(spii + 1, 3)
							e.nav_path.pi, e.nav_path.spi, e.nav_path.ni = pi, spii, ni
							e.enemy.gold = 0
							e.pos = V.vclone(dead.pos)
							e.render.sprites[1].name = "raise"

							E:add_comps(e, "count_group")

							e.count_group.name = this.count_group_name
							e.count_group.type = this.count_group_type

							queue_insert(store, e)
						end
					end
				end
			end
		end

		coroutine.yield()
	end
end

scripts.eb_elder_shaman = {}

function scripts.eb_elder_shaman.update(this, store)
	local taunt = this.taunt

	local function y_show_taunt(set, index, duration)
		index = index or math.random(taunt.sets[set].start_idx, taunt.sets[set].end_idx)
		duration = duration or taunt.duration
		taunt.ts = store.tick_ts
		taunt.next_ts = store.tick_ts + math.random(taunt.delay_min, taunt.delay_max)

		local t = E:create_entity("decal_elder_shaman_shoutbox")

		t.texts.list[1].text = _(string.format(taunt.sets[set].format, index))
		t.pos.x, t.pos.y = this.pos.x + taunt.offset.x, this.pos.y + taunt.offset.y
		t.render.sprites[1].ts = store.tick_ts
		t.render.sprites[2].ts = store.tick_ts

		queue_insert(store, t)
		U.y_wait(store, duration)

		t.tween.props[1].disabled = true
		t.tween.props[2].disabled = true
		t.tween.ts = store.tick_ts
		t.tween.reverse = true
		t.tween.remove = true

		return t
	end

	local function find_target(at)
		local targets = table.filter(store.entities, function(_, e)
			return not e.pending_removal and e.health and not e.health.dead and e.vis and band(e.vis.flags, at.vis_bans) == 0 and band(e.vis.bans, at.vis_flags) == 0 and (not at.path_margins or P:is_node_valid(e.nav_path.pi, e.nav_path.ni) and e.nav_path.ni > P:get_visible_start_node(e.nav_path.pi) + at.path_margins[1] and e.nav_path.ni < P:get_defend_point_node(e.nav_path.pi) - at.path_margins[2])
		end)

		if at.power_name == "damage" then
			local pis = U.find_paths_with_enemies(store.entities, at.enemy_vis_flags, at.enemy_vis_bans)

			if not pis then
				return nil
			end

			targets = table.filter(targets, function(_, e)
				local nodes = P:nearest_nodes(e.pos.x, e.pos.y, pis, nil, true)

				return #nodes > 0
			end)
		end

		if #targets < 1 then
			return nil
		else
			local target = table.random(targets)

			if target.nav_path then
				return target, target.nav_path.pi, target.nav_path.ni
			else
				local nodes = P:nearest_nodes(target.pos.x, target.pos.y)

				if #nodes < 1 then
					return nil
				else
					return target, nodes[1][1], nodes[1][3]
				end
			end
		end
	end

	this.percussionist = LU.list_entities(store.entities, "decal_s81_percussionist")[1]
	this.phase = "welcome"

	U.y_wait(store, 1.5)
	y_show_taunt("welcome", 1)
	y_show_taunt("welcome", 2)

	this.phase = "prebattle"

	while this.phase == "prebattle" do
		if store.tick_ts > taunt.next_ts then
			y_show_taunt(this.phase)
		end

		if store.wave_group_number > 0 then
			this.phase = "battle"
		end

		coroutine.yield()
	end

	local last_wave_number = 0
	local a = this.attacks
	local ah = this.attacks.list[1]
	local ad = this.attacks.list[2]
	local as = this.attacks.list[3]
	local wave_config

	while true do
		if store.tick_ts > taunt.next_ts then
			y_show_taunt(this.phase)
		end

		if store.wave_group_number ~= last_wave_number then
			log.debug("EB_ELDER_SHAMAN: setting wave config for %s", store.wave_group_number)

			last_wave_number = store.wave_group_number
			wave_config = W:get_endless_boss_config(store.wave_group_number)
			a.chance = wave_config.chance
			a.cooldown = wave_config.cooldown
			a.multiple_attacks_chance = wave_config.multiple_attacks_chance
			a.power_chances = wave_config.power_chances
			a.ts = store.tick_ts
		end

		if store.tick_ts - a.ts > a.cooldown then
			log.debug("EB_ELDER_SHAMAN: power cooldown complete")

			a.ts = store.tick_ts
			this.percussionist.play_loops = 3

			while math.random() < a.chance do
				local pconf, e, api, aspi, ani
				local a_idx = U.random_table_idx(a.power_chances)
				local aa = this.attacks.list[a_idx]
				local plevel = km.clamp(0, 9000000000, store.wave_group_number - wave_config.powers_config.powerProgressionWaveStart)
				local target, tpi, tni = find_target(aa)

				if not target then
					log.debug("EB_ELDER_SHAMAN: no enemies found for attack %s", aa.aura)
				else
					this.percussionist.play_loops = 9

					U.animation_start(this, a.animation, nil, store.tick_ts, false)
					U.y_wait(store, U.frandom(a.delay[1], a.delay[2]))

					pconf = wave_config.powers_config[aa.power_name]
					e = E:create_entity(aa.aura)
					e.aura.duration = pconf.duration + plevel * pconf.durationIncrement
					e.aura.radius = pconf.range / 2
					api, aspi, ani = tpi, 1, tni

					if aa.node_offset then
						ani = tni + math.random(aa.node_offset[1], aa.node_offset[2])
					end

					if aa.path_margins then
						ani = km.clamp(P:get_visible_start_node(api) + aa.path_margins[1], P:get_defend_point_node(api) - aa.path_margins[2], ani)
					end

					log.debug("EB_ELDER_SHAMAN enemy aura insertion node: %s,%s,%s target ni:%s defend ni:%s", api, aspi, ani, tni, P:get_defend_point_node(api))

					e.pos = P:node_pos(api, aspi, ani)

					if aa == ah then
						e.aura.mod_args = {
							["hps.heal_min"] = math.floor(pconf.healthPerTick + plevel * pconf.healthPerTickIncrement),
							["hps.heal_max"] = math.floor(pconf.healthPerTick + plevel * pconf.healthPerTickIncrement)
						}
					elseif aa == ad then
						e.aura.mod_args = {
							["dps.damage_min"] = math.floor(pconf.damagePerTick + plevel * pconf.damagePerTickIncrement),
							["dps.damage_max"] = math.floor(pconf.damagePerTick + plevel * pconf.damagePerTickIncrement)
						}
					elseif aa == as then
						e.aura.mod_args = {
							["slow.factor"] = pconf.speedModifier + plevel * pconf.speedModifierIncrement
						}
					end

					queue_insert(store, e)
					U.y_animation_wait(this)
					U.animation_start(this, "idle", nil, store.tick_ts)
				end

				if math.random() >= a.multiple_attacks_chance then
					break
				end
			end
		end

		coroutine.yield()
	end
end

scripts.decal_s81_percussionist = {}

function scripts.decal_s81_percussionist.update(this, store)
	while true do
		while this.play_loops > 0 do
			local loops = this.play_loops

			this.play_loops = 0

			U.y_animation_play(this, "play", nil, store.tick_ts, loops)
			U.animation_start(this, "idle", nil, store.tick_ts)
		end

		coroutine.yield()
	end
end

scripts.aura_elder_shaman = {}

function scripts.aura_elder_shaman.update(this, store)
	local a = this.aura
	local s = this.render.sprites
	local ring_sid = 1
	local ground_sid = 2
	local totem_sid = 3
	local fx_sid = 4

	s[ring_sid].ts = store.tick_ts

	U.y_animation_play(this, "start", nil, store.tick_ts, 1, totem_sid)

	s[fx_sid].hidden = false
	this.aura.ts = store.tick_ts

	while store.tick_ts - this.aura.ts < a.duration do
		local targets = U.find_targets_in_range(store.entities, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)

		if targets then
			for _, target in pairs(targets) do
				local e = E:create_entity(this.aura.mod)

				e.modifier.target_id = target.id
				e.modifier.source_id = this.id

				for k, v in pairs(a.mod_args) do
					LU.eval_set_prop(e, k, v)
				end

				queue_insert(store, e)
			end
		end

		U.y_wait(store, a.cycle_time)
	end

	s[ground_sid].hidden = true
	s[ring_sid].hidden = true
	s[fx_sid].hidden = true

	U.y_animation_play(this, "end", nil, store.tick_ts, 1, totem_sid)
	queue_remove(store, this)
end

scripts.axe_barbarian = {}

function scripts.axe_barbarian.insert(this, store, script)
	if scripts.arrow.insert(this, store, script) then
		AC:inc_check("AXE_RAINER")

		return true
	else
		return false
	end
end

scripts.bomb_cluster = {}

function scripts.bomb_cluster.insert(this, store)
	local b = this.bullet
	local dest = V.vclone(b.to)
	local target = store.entities[b.target_id]
	local nearest_nodes = P:nearest_nodes(b.to.x, b.to.y, target and {
		target.nav_path.pi
	} or nil)

	if #nearest_nodes > 0 then
		local pi, spi, ni = unpack(nearest_nodes[1])

		this._pred_pi, this._pred_ni = pi, ni
		dest = P:node_pos(pi, 1, ni)
	end

	b.to.x, b.to.y = dest.x + b.dest_pos_offset.x, dest.y + b.dest_pos_offset.y

	return scripts.bomb.insert(this, store)
end

function scripts.bomb_cluster.update(this, store)
	local b = this.bullet

	this.render.sprites[1].r = 20 * math.pi / 180 * (b.to.x > b.from.x and 1 or -1)

	while store.tick_ts - b.ts < b.flight_time do
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

		coroutine.yield()
	end

	if b.hit_fx then
		S:queue(this.sound_events.hit)

		local sfx = E:create_entity(b.hit_fx)

		sfx.pos = V.vclone(b.to)
		sfx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, sfx)
	end

	local pi, ni = this._pred_pi, this._pred_ni
	local ni_offset = b.fragment_node_spread * math.floor(b.fragment_count / 2)
	local dest = b.to

	for i = 1, b.fragment_count do
		local bf_dest

		if pi and ni then
			bf_dest = P:node_pos(pi, 1, ni + ni_offset - i * b.fragment_node_spread)
		else
			bf_dest = U.point_on_ellipse(dest, (50 * math.random() + 45) / 2, 2 * math.pi * i / b.fragment_count)
		end

		bf_dest.x = bf_dest.x + U.frandom(-b.fragment_pos_spread.x, b.fragment_pos_spread.x)
		bf_dest.y = bf_dest.y + U.frandom(-b.fragment_pos_spread.y, b.fragment_pos_spread.y)

		local bf = E:create_entity(b.fragment_name)

		bf.bullet.from = V.vclone(this.pos)
		bf.bullet.to = bf_dest
		bf.bullet.flight_time = bf.bullet.flight_time + fts(i) * math.random(1, 2)
		bf.render.sprites[1].r = 100 * math.random() * (math.pi / 180)

		queue_insert(store, bf)
		-- AC:inc_check("CLUSTERED")
	end

	queue_remove(store, this)
end

scripts.ray_tesla = {}

function scripts.ray_tesla.update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local source = store.entities[b.source_id]
	local dest = b.to
	local l_src, l_dst = V.vclone(this.pos), V.vclone(b.to)

	s.scale = V.v(1, 1)

	local function update_sprite()
		if target and target.motion then
			dest.x, dest.y = target.pos.x, target.pos.y

			if target.unit and target.unit.hit_offset then
				dest.x, dest.y = dest.x + target.unit.hit_offset.x, dest.y + target.unit.hit_offset.y
			end
		end

		if source and source.motion then
			this.pos.x, this.pos.y = source.pos.x, source.pos.y

			if source.unit and source.unit.hit_offset then
				this.pos.x, this.pos.y = this.pos.x + source.unit.hit_offset.x, this.pos.y + source.unit.hit_offset.y
			end
		end

		local dsrc = math.max(math.abs(this.pos.x - l_src.x), math.abs(this.pos.y - l_src.y))
		local ddst = math.max(math.abs(dest.x - l_dst.x), math.abs(dest.y - l_dst.y))

		if dsrc > b.max_track_distance or ddst > b.max_track_distance then
			log.paranoid("(%s) ray_tesla jumped out of max_track_distance", this.id)

			s.hidden = true
			target = nil

			return false
		end

		l_src.x, l_src.y = this.pos.x, this.pos.y
		l_dst.x, l_dst.y = dest.x, dest.y

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
		s.scale.y = 0.4 + km.clamp(0, 0.6, s.scale.x * 0.6)
		s.scale.y = s.scale.y * this.bounce_scale_y

		return true
	end

	if target then
		s.ts = store.tick_ts

		if not update_sprite() then
			-- block empty
		else
			if not this.excluded_templates or not table.contains(this.excluded_templates, target.template_name) then
				local mod = E:create_entity(b.mod)
				local bounce_factor = this.bounce_damage_factor * this.bullet.damage_factor
				local total_damage = math.ceil(math.random(this.bounce_damage_min, this.bounce_damage_max) * bounce_factor)
				local dps_hits = math.floor(mod.modifier.duration / mod.dps.damage_every)
				local dps_damage = math.floor(total_damage / dps_hits)
				local first_damage = total_damage - dps_damage * dps_hits + dps_damage
				
				mod.modifier.level = b.level
				mod.modifier.source_id = b.source_id
				mod.modifier.target_id = target.id
				mod.dps.damage_max = dps_damage
				mod.dps.damage_min = dps_damage
				mod.dps.damage_first = first_damage

				queue_insert(store, mod)
			end

			table.insert(this.seen_targets, target.id)

			if not this.bounces then
				this.bounces = this.bounces_lvl[b.level]
			end

			if this.bounces > 0 then
				U.y_wait(store, this.bounce_delay)

				local bounce_target = U.find_nearest_enemy(store.entities, dest, 0, this.bounce_range, this.bounce_vis_flags, this.bounce_vis_bans, function(v)
					return not table.contains(this.seen_targets, v.id)
				end)

				if bounce_target then
					log.paranoid("ray_tesla bounce from %s to %s dist:%s", target.id, bounce_target.id, V.dist(dest.x, dest.y, bounce_target.pos.x, bounce_target.pos.y))

					local r = E:create_entity(this.template_name)

					r.pos = V.vclone(dest)
					r.bullet.to = V.vclone(bounce_target.pos)
					r.bullet.target_id = bounce_target.id
					r.bullet.source_id = target.id
					r.bounces = this.bounces - 1
					r.bounce_scale_y = r.bounce_scale_y * r.bounce_scale_y_factor
					r.seen_targets = this.seen_targets
					r.bounce_damage_factor = math.max(this.bounce_damage_factor + this.bounce_damage_factor_inc, this.bounce_damage_factor_min)

					queue_insert(store, r)
				end
			end

			while not U.animation_finished(this) do
				if target then
					update_sprite()
				end

				coroutine.yield()
			end
		end
	end

	queue_remove(store, this)
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
				b.bullet.to = V.v(t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y)
				b.bullet.flight_time = U.frandom(fts(15), fts(25))
			end

			queue_insert(store, b)
		end
	end

	return scripts.arrow.insert(this, store)
end

scripts.hacksaw_sawblade = {}

function scripts.hacksaw_sawblade.update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local target, ps
	local bounce_count = 0

	U.animation_start(this, "flying", nil, store.tick_ts, true)

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	::label_193_0::

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead then
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		coroutine.yield()
	end

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].runs = 0

		queue_insert(store, sfx)
	end

	if b.hit_blood_fx and target.unit.blood_color ~= BLOOD_NONE then
		local sfx = E:create_entity(b.hit_blood_fx)

		sfx.pos = V.vclone(b.to)
		sfx.render.sprites[1].ts = store.tick_ts

		if sfx.use_blood_color and target.unit.blood_color then
			sfx.render.sprites[1].name = target.unit.blood_color
			sfx.render.sprites[1].r = this.render.sprites[1].r
		end

		queue_insert(store, sfx)
	end

	if bounce_count < this.bounces_max then
		local target = U.find_random_enemy(store.entities, this.pos, 0, this.bounce_range, b.vis_flags, b.vis_bans, function(v)
			return v ~= target
		end)

		if target then
			S:queue(this.sound_events.bounce)

			bounce_count = bounce_count + 1
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			b.target_id = target.id

			goto label_193_0
		end
	end

	queue_remove(store, this)
end

scripts.ray_thor = {}

function scripts.ray_thor.update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local source = store.entities[b.source_id]
	local dest = b.to

	s.scale = V.v(1, 1)

	local function update_sprite()
		if target and target.motion then
			dest.x, dest.y = target.pos.x, target.pos.y

			if target.unit and target.unit.hit_offset then
				dest.x, dest.y = dest.x + target.unit.hit_offset.x, dest.y + target.unit.hit_offset.y
			end
		end

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
		s.scale.y = 0.4 + km.clamp(0, 0.6, s.scale.x * 0.6)
		s.scale.y = s.scale.y * this.bounce_scale_y
	end

	if target then
		s.ts = store.tick_ts

		update_sprite()

		local mod = E:create_entity(b.mod)

		mod.modifier.source_id = b.source_id
		mod.modifier.target_id = target.id

		queue_insert(store, mod)

		while not U.animation_finished(this) do
			update_sprite()
			coroutine.yield()
		end
	end

	queue_remove(store, this)
end

scripts.aura_ranger_thorn = {}

function scripts.aura_ranger_thorn.update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local function find_targets()
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans, function(e)
			return true
			-- return not e.enemy.counts[a.mod] or e.enemy.counts[a.mod] < a.max_times
		end)

		return targets
	end

	while true do
		local owner = store.entities[a.source_id]

		if not owner then
			-- log.error("aura_ranger_thorn has no parent tower. removing")
			break
		end

		if owner.owner.tower.blocked or not owner.owner.tower.can_do_magic then
			-- block empty
		elseif store.tick_ts - a.ts >= a.cooldown then
			local targets = find_targets()

			if not targets or #targets < a.min_count then
				-- block empty
			else
				a.ts = store.tick_ts

				U.animation_start(owner, a.owner_animation, nil, store.tick_ts, false, a.owner_sid)
				U.y_wait(store, a.hit_time)

				targets = find_targets()

				if not targets or #targets < a.min_count then
					-- block empty
				else
					S:queue(a.hit_sound)

					for i = 1, math.min(#targets, a.max_count + a.max_count_inc * owner.powers.thorn.level) do
						local e = targets[i]
						for j, name in ipairs(a.mods) do
							local m = E:create_entity(name)
							m.modifier.source_id = this.id
							m.modifier.target_id = e.id
							m.modifier.level = owner.powers.thorn.level
							m.modifier.duration = m.modifier.duration + m.modifier.duration_inc * owner.powers.thorn.level
							queue_insert(store, m)
						end
					end

					U.y_animation_wait(owner, a.owner_sid)
				end
			end
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.aura_tesla_overcharge = {}

function scripts.aura_tesla_overcharge.update(this, store)
	local a = this.aura
	local ps = E:create_entity(this.particles_name)

	ps.pos = V.vclone(this.pos)

	queue_insert(store, ps)
	U.y_wait(store, a.duration)

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

	if targets then
		for _, e in pairs(targets) do
			local d = SU.create_attack_damage(a, e.id, this.id)

			queue_damage(store, d)

			if not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, e.template_name) then
				local m = E:create_entity(a.mod)

				m.modifier.target_id = e.id
				m.modifier.source_id = this.id

				queue_insert(store, m)
			end
		end
	end

	queue_remove(store, this)
end

scripts.aura_malik_fissure = {}

function scripts.aura_malik_fissure.update(this, store)
	local a = this.aura

	local function do_attack(pos, first_hit)
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
				d.damage_type = a.damage_types[first_hit and 1 or 2]
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

			log.paranoid(">>>> aura_malik_fissure POS:%s,%s  damaged:%s", pos.x, pos.y, table.concat(table.map(targets, function(k, v)
				return v.id
			end), ","))
		end
	end

	do_attack(this.pos, true)

	local pi, spi, ni

	if a.target_id and store.entities[a.target_id] then
		local np = store.entities[a.target_id].nav_path

		pi, spi, ni = np.pi, np.spi, np.ni
	else
		local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

		if #nodes < 1 then
			log.error("aura_malik_fissure could not find valid nodes near %s,%s", this.pos.x, this.pos.y)

			goto label_201_0
		end

		pi, spi, ni = unpack(nodes[1])
	end

	for i = 1, a.level do
		spi = not (spi ~= 2 and spi ~= 3) and 1 or math.random() < 0.5 and 2 or 3

		U.y_wait(store, a.spread_delay)

		local nni = ni + i * a.spread_nodes
		local spos = P:node_pos(pi, spi, nni)

		do_attack(spos)

		nni = ni - i * a.spread_nodes
		spos = P:node_pos(pi, spi, nni)

		do_attack(spos)
	end

	::label_201_0::

	queue_remove(store, this)
end

scripts.aura_chill_elora = {}

function scripts.aura_chill_elora.update(this, store)
	local last_hit_ts = 0

	U.sprites_hide(this)

	if this.delay then
		U.y_wait(store, this.delay)
	end

	for _, s in pairs(this.render.sprites) do
		s.ts = store.tick_ts
	end

	U.sprites_show(this)

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.aura.duration then
			this.tween.disabled = false
			this.tween.ts = store.tick_ts

			return
		end

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			last_hit_ts = store.tick_ts

			local targets = table.filter(store.entities, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and not v._last_on_ice and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
			end)

			for i, target in ipairs(targets) do
				if not U.has_modifiers(store, target, this.aura.mod) then
					SU.remove_modifiers_by_type(store, target, MOD_TYPE_SLOW, this.aura.mod)
				end

				local new_mod = E:create_entity(this.aura.mod)

				new_mod.modifier.level = this.aura.level
				new_mod.modifier.target_id = target.id
				new_mod.modifier.source_id = this.id

				queue_insert(store, new_mod)
			end
		end

		coroutine.yield()
	end
end

scripts.aura_slow_bolin = {}

function scripts.aura_slow_bolin.update(this, store)
	last_hit_ts = store.tick_ts - this.aura.cycle_time

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.aura.duration then
			U.animation_start(this, "end", nil, store.tick_ts)

			this.tween.disabled = false
			this.tween.ts = store.tick_ts

			return
		end

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			last_hit_ts = store.tick_ts

			local targets = table.filter(store.entities, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
			end)

			for i, target in ipairs(targets) do
				local new_mod = E:create_entity(this.aura.mod)

				new_mod.modifier.level = this.aura.level
				new_mod.modifier.target_id = target.id
				new_mod.modifier.source_id = this.id

				queue_insert(store, new_mod)
			end
		end

		coroutine.yield()
	end
end

scripts.denas_buff_aura = {}

function scripts.denas_buff_aura.update(this, store)
	local target = store.entities[this.aura.target_id]
	local ts = store.tick_ts - this.aura.cycle_time
	local start_ts = store.tick_ts
	local inserted_entities = {}
	local force_remove = false

	if not target then
		-- block empty
	else
		this.pos = V.vclone(target.pos)
		this.tween.disabled = false
		this.tween.props[1].ts = store.tick_ts

		while true do
			if store.tick_ts - start_ts >= this.aura.duration then
				break
			end

			if target.pos.x ~= this.pos.x or target.pos.y ~= this.pos.y or target.health.death then
				force_remove = true

				break
			end

			if store.tick_ts - ts >= this.aura.cycle_time then
				ts = store.tick_ts

				local e = E:create_entity(this.entity)

				e.pos = V.vclone(this.pos)
				e.tween.disabled = false

				for i, t in ipairs(e.tween.props) do
					e.tween.props[i].ts = store.tick_ts
				end

				table.insert(inserted_entities, e)
				queue_insert(store, e)
			end

			coroutine.yield()
		end
	end

	if force_remove then
		for _, e in pairs(inserted_entities) do
			queue_remove(store, e)
		end
	end

	queue_remove(store, this)
end

scripts.aura_ignus_particles = {}

function scripts.aura_ignus_particles.update(this, store)
	local source = store.entities[this.aura.source_id]

	if not source then
		queue_remove(store, this)

		return
	end

	this.pos = source.pos

	local particles = {}
	local s = source.render.sprites[1]
	local h = source.health
	local flip = s.flip_x

	for i, o in ipairs(this.particle_offsets) do
		local ps = E:create_entity(this.particles_name)

		ps.particle_system.track_id = source.id
		ps.particle_system.track_offset = o
		ps.particle_system.ts_offset = fts(2 * i)

		queue_insert(store, ps)
		table.insert(particles, ps)
	end

	::label_209_0::

	while h.dead or not table.contains(this.emit_states, s.name) do
		coroutine.yield()
	end

	for i, p in pairs(particles) do
		p.particle_system.emit = true
	end

	while table.contains(this.emit_states, s.name) and not h.dead do
		if s.flip_x ~= flip then
			flip = s.flip_x

			for i, p in pairs(particles) do
				p.particle_system.emit_offset = s.flip_x and this.flip_offset or nil
			end
		end

		coroutine.yield()
	end

	for _, p in pairs(particles) do
		p.particle_system.emit = false
	end

	goto label_209_0
end

scripts.aura_ignus_surge_of_flame = {}

function scripts.aura_ignus_surge_of_flame.update(this, store)
	local source = store.entities[this.aura.source_id]

	if not source then
		queue_remove(store, this)

		return
	end

	this.pos = source.pos

	local s = source.render.sprites[1]
	local ps = E:create_entity(this.particles_name)

	ps.particle_system.track_id = source.id
	ps.particle_system.emit = true

	queue_insert(store, ps)

	local a = this.aura
	local ts = 0
	local targets

	while s.name == this.damage_state do
		if store.tick_ts - ts + 1e-09 <= a.cycle_time then
			-- block empty
		else
			targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius, a.damage_flags or 0, a.damage_bans or 0) or {}
			ts = store.tick_ts

			for _, t in pairs(targets) do
				local d = E:create_entity("damage")

				d.damage_type = a.damage_type
				d.source_id = this.id
				d.target_id = t.id
				d.value = math.random(a.damage_min, a.damage_max)

				queue_damage(store, d)

				local fx = E:create_entity(a.hit_fx)

				fx.pos = V.vclone(t.pos)

				if t.unit and t.unit.mod_offset then
					fx.pos.x, fx.pos.y = fx.pos.x + t.unit.mod_offset.x, fx.pos.y + t.unit.mod_offset.y
				end

				for i = 1, #fx.render.sprites do
					fx.render.sprites[i].ts = store.tick_ts
				end

				queue_insert(store, fx)
			end
		end

		coroutine.yield()
	end

	ps.particle_system.emit = false

	queue_remove(store, this)
end

scripts.aura_ingvar_bear_regenerate = {}

function scripts.aura_ingvar_bear_regenerate.update(this, store)
	local hero = store.entities[this.aura.source_id]

	if not hero then
		log.error("hero not found for aura_ingvar_bear_regenerate")
		queue_remove(store, this)

		return
	end

	this.aura.ts = store.tick_ts

	while true do
		if not hero.is_bear or hero.health.dead then
			-- block empty
		elseif store.tick_ts - this.aura.ts >= this.regen.cooldown then
			this.aura.ts = store.tick_ts
			hero.health.hp = hero.health.hp + this.regen.health
			hero.health.hp = km.clamp(0, hero.health.hp_max, hero.health.hp)
		end

		coroutine.yield()
	end
end

scripts.aura_10yr_particles = {}

function scripts.aura_10yr_particles.update(this, store)
	local source = store.entities[this.aura.source_id]

	if not source then
		queue_remove(store, this)

		return
	end

	this.pos = source.pos

	local particles = {}
	local s = source.render.sprites[1]
	local h = source.health
	local flip = s.flip_x

	for i, o in ipairs(this.particle_offsets) do
		local ps = E:create_entity(this.particles_name)

		ps.particle_system.track_id = source.id
		ps.particle_system.track_offset = o
		ps.particle_system.ts_offset = fts(2 * i)

		queue_insert(store, ps)
		table.insert(particles, ps)
	end

	for i, p in pairs(particles) do
		p.particle_system.emit = false
	end

	::label_212_0::

	while h.dead or not source.is_buffed or not table.contains(this.emit_states, s.name) do
		coroutine.yield()
	end

	for i, p in pairs(particles) do
		p.particle_system.emit = true
	end

	while table.contains(this.emit_states, s.name) and not h.dead and source.is_buffed do
		if s.flip_x ~= flip then
			flip = s.flip_x

			for i, p in pairs(particles) do
				p.particle_system.emit_offset = s.flip_x and this.flip_offset or nil
			end
		end

		coroutine.yield()
	end

	for _, p in pairs(particles) do
		p.particle_system.emit = false
	end

	goto label_212_0
end

scripts.aura_10yr_fireball = {}

function scripts.aura_10yr_fireball.update(this, store)
	local start_y = store.visible_coords and store.visible_coords.top or REF_H
	local a = this.aura
	local owner = store.entities[a.source_id]

	local function getPredictionTime(entity)
		local bdy = math.abs(entity.pos.y - start_y)
		local tpl = E:get_template(a.entity)
		local bdt = bdy / tpl.bullet.max_speed
		return bdt + 0.2
	end

	if not owner then
		log.error("owner %s was not found. bailing out", a.source_od)
	else
		-- do
		-- 	local bdy = math.abs(owner.pos.y - start_y)
		-- 	local tpl = E:get_template(a.entity)

		-- 	bdt = bdy / tpl.bullet.max_speed
		-- end
		for i = 1, a.loops do
			local target, __, pred_pos = U.find_foremost_enemy(store.entities, owner.pos, a.min_range, a.max_range, nil, a.vis_flags, a.vis_ban)
			local b = E:create_entity(a.entity)
			if target then
				local offset = U.get_prediction_offset(target, getPredictionTime(target))
				pred_pos.x, pred_pos.y = pred_pos.x + offset.x, pred_pos.y + offset.y
				local dh = start_y - pred_pos.y
				local dx = dh * 0.4

				b.pos.x, b.pos.y = pred_pos.x + dx, start_y
				b.bullet.to = V.v(pred_pos.x, pred_pos.y)
			else
				local tx = owner.pos.x + math.random(-20, 20)
				local ty = owner.pos.y + math.random(-20, 20)
				local dh = start_y - ty
				local dx = dh * 0.4

				b.pos.x, b.pos.y = tx + dx, start_y
				b.bullet.to = V.v(tx, ty)
			end

			b.bullet.from = V.vclone(b.pos)

			queue_insert(store, b)
			U.y_wait(store, a.delay)
		end
	end

	queue_remove(store, this)
end

scripts.aura_10yr_bomb = {}

function scripts.aura_10yr_bomb.update(this, store)
	local a = this.aura

	local function do_attack(pos, last_attack)
		local fx = E:create_entity(a.fx)

		fx.pos.x, fx.pos.y = pos.x, pos.y

		if not last_attack then
			fx.render.sprites[2].scale = V.v(0.8, 0.8)
		end

		fx.render.sprites[2].ts = store.tick_ts
		fx.tween.ts = store.tick_ts

		queue_insert(store, fx)

		local radius = last_attack and a.last_attack_damage_radius or a.damage_radius
		local targets = U.find_enemies_in_range(store.entities, pos, 0, radius, a.vis_flags, a.vis_bans)

		if targets then
			for _, t in pairs(targets) do
				local d = E:create_entity("damage")

				d.value = math.random(a.damage_min, a.damage_max)
				d.damage_type = a.damage_type
				d.source_id = this.id
				d.target_id = t.id

				queue_damage(store, d)

				if (last_attack or math.random() < a.stun_chance) and U.flags_pass(t.vis, this.stun) then
					local m = E:create_entity(this.stun.mod)

					m.modifier.source_id = this.id
					m.modifier.target_id = t.id

					queue_insert(store, m)
				end
			end

			log.paranoid(">>>> aura_10yr_bomb POS:%s,%s  damaged:%s", pos.x, pos.y, table.concat(table.map(targets, function(k, v)
				return v.id
			end), ","))
		end
	end

	local pi, spi, ni, tni, target, origin
	local target_info = U.find_enemies_in_paths(store.entities, this.pos, a.min_nodes, a.max_nodes, nil, a.vis_flags, a.vis_bans)

	if not target_info or #target_info < a.min_count then
		log.error("aura_10yr_bomb could not find valid enemies in the hero paths")
	else
		target = target_info[1].enemy
		origin = target_info[1].origin
		pi, spi, ni = unpack(origin)
		tni = target.nav_path.ni

		for i = 1, a.steps do
			local nni = ni + i * a.step_nodes * km.sign(tni - ni)
			local oni = ni + i * a.step_nodes * km.sign(tni - ni) * -1

			spi = i == a.steps and 1 or not (spi ~= 2 and spi ~= 3) and 1 or math.random() < 0.5 and 2 or 3

			U.y_wait(store, a.step_delay)

			local spos = P:node_pos(pi, spi, nni)

			do_attack(spos, i == a.steps)

			if i == 1 then
				local opos = P:node_pos(pi, spi, oni)

				do_attack(opos, false)
			end
		end
	end

	queue_remove(store, this)
end

scripts.aura_10yr_land = {}
function scripts.aura_10yr_land.update(this, store)
	local a = this.aura
	local fx = E:create_entity(a.fx)
	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
	fx.render.sprites[2].ts = store.tick_ts
	fx.tween.ts = store.tick_ts
	queue_insert(store, fx)

	local radius = a.damage_radius
	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, radius, a.vis_flags, a.vis_bans)

	if targets then
		for _, t in ipairs(targets) do
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
				m.modifier.duration = this.stun.duration
				queue_insert(store, m)
			end
		end
	end

	queue_remove(store, this)
end

scripts.aura_spectral_knight = {}

function scripts.aura_spectral_knight.update(this, store)
	U.y_wait(store, this.aura.delay)

	this.tween.disabled = false
	this.tween.ts = store.tick_ts

	return scripts.aura_apply_mod.update(this, store)
end

scripts.mod_slow_curse = {}

function scripts.mod_slow_curse.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if U.has_modifier_types(store, target, MOD_TYPE_SLOW, MOD_TYPE_RAGE) then
		return false
	end

	return scripts.mod_slow.insert(this, store)
end

scripts.mod_thorn = {}

function scripts.mod_thorn.queue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		log.debug("%s (%s) queue/insertion", this.template_name, this.id)

		if U.flags_pass(target.vis, this.modifier) then
			this._target_prev_bans = target.vis.bans
			target.vis.bans = U.flag_set(target.vis.bans, F_THORN)
		end
	else
		log.debug("%s (%s) queue/removal", this.template_name, this.id)

		if this._target_prev_bans then
			target.vis.bans = this._target_prev_bans
		end
	end
end

function scripts.mod_thorn.dequeue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		log.debug("%s (%s) dequeue/insertion", this.template_name, this.id)

		if this._target_prev_bans then
			target.vis.bans = this._target_prev_bans
		end
	end
end

function scripts.mod_thorn.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	local s = this.render.sprites[1]

	s.ts = store.tick_ts

	if target and target.health and not target.health.dead and this._target_prev_bans ~= nil and (not target.enemy.counts.mod_thorn or target.enemy.counts.mod_thorn < this.max_times_applied) then
		SU.stun_inc(target)

		s.prefix = s.size_prefixes[target.unit.size]
		s.scale = s.size_scales[target.unit.size]

		return true
	else
		return false
	end
end

function scripts.mod_thorn.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		target.health.ignore_damage = false

		SU.stun_dec(target)
	end

	return true
end

function scripts.mod_thorn.update(this, store)
	local hit_ts
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		queue_remove(store, this)

		return
	end

	if this.max_times_applied then
		if not target.enemy.counts.mod_thorn then
			target.enemy.counts.mod_thorn = 0
		end

		target.enemy.counts.mod_thorn = target.enemy.counts.mod_thorn + 1
	end

	this.pos = target.pos

	local target_flip = target.render.sprites[1].flip_x

	U.animation_start(this, "start", target_flip, store.tick_ts, false)

	while not U.animation_finished(this) do
		if target.health.dead then
			goto label_223_0
		end

		coroutine.yield()
	end

	m.ts = store.tick_ts
	hit_ts = store.tick_ts

	U.animation_start(this, "loop", target_flip, store.tick_ts, true)

	while store.tick_ts - m.ts <= m.duration + 1e-09 do
		if this.interrupt or target.health.dead then
			break
		end

		if store.tick_ts - hit_ts >= this.damage_every then
			hit_ts = store.tick_ts

			local d = SU.create_attack_damage(this, target.id, this.id)

			queue_damage(store, d)
		end

		coroutine.yield()
	end

	::label_223_0::

	U.y_animation_play(this, "end", target_flip, store.tick_ts, false)
	queue_remove(store, this)
	signal.emit("mod-applied", this, target)
end

scripts.mod_ray_arcane = {}

function scripts.mod_ray_arcane.update(this, store)
	local cycles, total_damage = 0, 0
	local m = this.modifier
	local dps = this.dps
	local target = store.entities[m.target_id]

	if not target or target.health.dead then
		queue_remove(store, this)

		return
	end

	local function apply_damage(value)
		local d = E:create_entity("damage")

		d.source_id = this.id
		d.target_id = target.id
		d.value = value
		d.damage_type = dps.damage_type
		d.pop = dps.pop
		d.pop_chance = dps.pop_chance
		d.pop_conds = dps.pop_conds

		queue_damage(store, d)

		total_damage = total_damage + value
	end

	local raw_damage = math.random(dps.damage_min, dps.damage_max)
	local extra_damage = math.max(0, raw_damage - target.health.hp)
	local total_cycles = m.duration / dps.damage_every
	local dps_damage = math.floor((raw_damage - extra_damage) / total_cycles)
	local first_damage = raw_damage - extra_damage - dps_damage * total_cycles

	this.pos = target.pos
	dps.ts = store.tick_ts
	m.ts = store.tick_ts

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead then
			break
		end

		if total_cycles <= cycles then
			log.paranoid(">>>>> id:%s - mod_ray_arcane cycles:%s raw_damage:%s dps_damage:%s first_damage:%s total_damage:%s", this.id, cycles, raw_damage, dps_damage, first_damage, total_damage)
			apply_damage(extra_damage)

			break
		end

		if this.render and m.use_mod_offset and target.unit.hit_offset then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.hit_offset.x, target.unit.hit_offset.y
		end

		if dps.damage_every and store.tick_ts - dps.ts >= dps.damage_every then
			cycles = cycles + 1
			dps.ts = dps.ts + dps.damage_every

			apply_damage(dps_damage + (cycles == 1 and first_damage or 0))
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.mod_ray_arcane_disintegrate = {}

function scripts.mod_ray_arcane_disintegrate.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or target.health.dead then
		return
	end

	this.pos = target.pos
	m.ts = store.tick_ts

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead then
			break
		end

		if store.tick_ts - m.ts >= m.duration then
			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = target.id
			d.damage_type = m.damage_type
			d.value = m.damage
			d.pop = m.pop
			d.pop_chance = m.pop_chance
			d.pop_conds = m.pop_conds

			queue_damage(store, d)

			break
		end

		if this.render and m.use_mod_offset and target.unit.hit_offset then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.hit_offset.x, target.unit.hit_offset.y
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.mod_rocketeer_speed_buff = {}

function scripts.mod_rocketeer_speed_buff.insert(this, store)
	local m = this.modifier
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	m.ts = store.tick_ts
	target._angles_walk = target.render.sprites[1].angles.walk
	target.already_speed_up = true
	target.render.sprites[1].angles.walk = this.walk_angles
	target.motion.max_speed = target.motion.max_speed * this.fast.factor

	return true
end

function scripts.mod_rocketeer_speed_buff.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.render.sprites[1].angles.walk = target._angles_walk
		target.motion.max_speed = target.motion.max_speed / this.fast.factor

		return true
	end

	return false
end

scripts.mod_troll_rage = {}

function scripts.mod_troll_rage.insert(this, store)
	local m = this.modifier
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	m.ts = store.tick_ts
	this._speed_factor = (target.motion.max_speed + this.extra_speed) / target.motion.max_speed
	target.motion.max_speed = target.motion.max_speed * this._speed_factor

	SU.armor_inc(target, this.extra_armor)

	local ma = target.melee.attacks[1]

	if ma then
		ma.damage_min = ma.damage_min + this.extra_damage_min
		ma.damage_max = ma.damage_max + this.extra_damage_max
	end

	return true
end

function scripts.mod_troll_rage.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.motion.max_speed = target.motion.max_speed / this._speed_factor

		SU.armor_dec(target, this.extra_armor)

		local ma = target.melee.attacks[1]

		if ma then
			ma.damage_min = ma.damage_min - this.extra_damage_min
			ma.damage_max = ma.damage_max - this.extra_damage_max
		end
	end

	return true
end

scripts.mod_demon_shield = {}

function scripts.mod_demon_shield.insert(this, store)
	local m = this.modifier
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	m.ts = store.tick_ts
	target.health.on_damage = scripts.mod_demon_shield.on_damage
	this._hits = 0
	this._hit_sources = {}
	this._blood_color = target.unit.blood_color
	target.unit.blood_color = BLOOD_NONE
	target._shield_mod = this

	return true
end

function scripts.mod_demon_shield.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.health.on_damage = nil
		target._shield_mod = nil
		target.unit.blood_color = this._blood_color
	end

	return true
end

function scripts.mod_demon_shield.on_damage(this, store, damage)
	local mod = this._shield_mod

	if not mod then
		log.error("mod_demon_shield.on_damage for enemy %s has no mod pointer", this.id)

		return true
	end

	if U.flag_has(damage.damage_type, bor(DAMAGE_INSTAKILL, DAMAGE_DISINTEGRATE, DAMAGE_EAT, DAMAGE_IGNORE_SHIELD)) then
		queue_remove(store, mod)

		return true
	end

	if U.flag_has(damage.damage_type, DAMAGE_ONE_SHIELD_HIT) then
		if not mod._hit_sources[damage.source_id] then
			mod._hit_sources[damage.source_id] = true
			mod._hits = mod._hits + 1
		end
	elseif not U.flag_has(damage.damage_type, DAMAGE_NO_SHIELD_HIT) then
		mod._hits = mod._hits + 1
	end

	if mod._hits >= mod.shield_ignore_hits then
		queue_remove(store, mod)
	end

	return false
end

scripts.mod_giant_rat_poison = {}

function scripts.mod_giant_rat_poison.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or not scripts.mod_dps.insert(this, store) then
		return false
	end

	target.unit.damage_factor = target.unit.damage_factor * this.reduced_damage_factor

	return true
end

function scripts.mod_giant_rat_poison.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target and target.unit then
		target.unit.damage_factor = target.unit.damage_factor / this.reduced_damage_factor
	end

	return true
end

scripts.mod_gerald_courage = {}

function scripts.mod_gerald_courage.insert(this, store)
	local m = this.modifier
	local buff = this.courage
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.unit then
		return false
	end

	if target.melee then
		for _, a in pairs(target.melee.attacks) do
			if a._original_damage_min then
				a._original_damage_min = a._original_damage_min + buff.damage_min_inc * m.level
			else
				a.damage_min = a.damage_min + buff.damage_min_inc * m.level
			end
			if a._original_damage_max then
				a._original_damage_max = a._original_damage_max + buff.damage_max_inc * m.level
			else
				a.damage_max = a.damage_max + buff.damage_max_inc * m.level
			end
		end
	end

	SU.magic_armor_inc(target, buff.magic_armor_inc * m.level)
	SU.armor_inc(target, buff.armor_inc * m.level)

	local heal = buff.heal_once_factor * target.health.hp_max

	target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp + heal)

	if this.render then
		for _, s in pairs(this.render.sprites) do
			s.ts = store.tick_ts

			if s.size_names then
				s.name = s.size_names[target.unit.size]
			end
		end
	end

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_gerald_courage.remove(this, store)
	local m = this.modifier
	local buff = this.courage
	local target = store.entities[this.modifier.target_id]

	if target then
		if target.melee then
			for _, a in pairs(target.melee.attacks) do
				if a._original_damage_min then
					a._original_damage_min = a._original_damage_min - buff.damage_min_inc * m.level
				else
					a.damage_min = a.damage_min - buff.damage_min_inc * m.level
				end
				if a._original_damage_max then
					a._original_damage_max = a._original_damage_max - buff.damage_max_inc * m.level
				else
					a.damage_max = a.damage_max - buff.damage_max_inc * m.level
				end
			end
		end

		SU.magic_armor_dec(target, buff.magic_armor_inc * m.level)
		SU.armor_dec(target, buff.armor_inc * m.level)
	end

	return true
end

scripts.mod_hero_thor_chainlightning = {}

function scripts.mod_hero_thor_chainlightning.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	local source = store.entities[m.source_id]
	local cl = this.chainlightning

	if target and target.health and not target.health.dead then
		local d = E:create_entity("damage")

		d.source_id = m.source_id
		d.target_id = m.target_id
		d.damage_type = cl.damage_type
		d.value = cl.damage

		queue_damage(store, d)

		local mod = E:create_entity(cl.mod)

		mod.modifier.ts = store.tick_ts
		mod.modifier.source_id = m.source_id
		mod.modifier.target_id = target.id

		queue_insert(store, mod)
	end

	U.y_wait(store, cl.chain_delay)

	local chain_pos = V.vclone(source.pos)
	local af = source.render.sprites[1].flip_x

	chain_pos.x = chain_pos.x + cl.offset.x * (af and -1 or 1)
	chain_pos.y = chain_pos.y + cl.offset.y

	local targets = U.find_enemies_in_range(store.entities, chain_pos, cl.min_range, cl.max_range, cl.vis_flags or 0, cl.vis_bans or 0)

	if targets then
		local random_targets = table.random_order(targets)
		local count = 0

		for _, t in pairs(random_targets) do
			if count >= cl.count then
				break
			end

			local dest = V.vclone(t.pos)
			local b = E:create_entity(cl.bullet)

			b.pos = V.vclone(chain_pos)
			b.bullet.from = V.vclone(b.pos)
			b.bullet.to = dest
			b.bullet.target_id = t.id
			b.bullet.source_id = m.source_id
			b.bullet.level = m.level

			queue_insert(store, b)

			count = count + 1
		end
	end

	queue_remove(store, this)
end

scripts.mod_hero_thor_thunderclap = {}

function scripts.mod_hero_thor_thunderclap.update(this, store)
	local tc = this.thunderclap
	local m = this.modifier
	local target = store.entities[m.target_id]
	local mods = {
		tc.mod_stun,
		tc.mod_fx
	}

	if not target then
		queue_remove(store, this)

		return
	end

	this.pos = V.vclone(target.pos)

	if target.health and not target.health.dead then
		local d = E:create_entity("damage")

		d.source_id = m.source_id
		d.target_id = m.target_id
		d.damage_type = tc.damage_type
		d.value = tc.damage

		queue_damage(store, d)

		local mod = E:create_entity(tc.mod_stun)

		mod.modifier.ts = store.tick_ts
		mod.modifier.source_id = m.source_id
		mod.modifier.target_id = m.target_id

		queue_insert(store, mod)
	end

	S:queue(tc.sound)
	U.y_wait(store, tc.explosion_delay)

	local targets = U.find_enemies_in_range(store.entities, target.pos, 0, tc.max_range, tc.vis_flags or 0, tc.vis_bans or 0, function(e)
		return e.id ~= m.target_id and e.health and not e.health.dead
	end)

	if targets then
		for _, t in ipairs(targets) do
			d = E:create_entity("damage")
			d.damage_type = tc.secondary_damage_type
			d.value = tc.secondary_damage
			d.source_id = m.source_id
			d.target_id = t.id

			queue_damage(store, d)

			for _, tm in ipairs(mods) do
				local mod = E:create_entity(tm)

				mod.modifier.ts = store.tick_ts
				mod.modifier.source_id = m.source_id

				if mod == tc.mod_stun then
					mod.modifier.duration = U.frandom(tc.stun_duration_min, tc.stun_duration_max)
				end

				mod.modifier.target_id = t.id
				mod.modifier.level = m.level

				queue_insert(store, mod)
			end
		end
	end

	local fx = E:create_entity(tc.fx)

	fx.pos = V.vclone(this.pos)
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)
	U.y_wait(store, fts(24))
	queue_remove(store, this)
end

scripts.mod_denas_tower = {}

function scripts.mod_denas_tower.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.tower then
		log.error("error inserting mod_denas_tower %s", this.id)

		return true
	end

	if this.range_factor then
		target.attacks.range = target.attacks.range * this.range_factor
	end

	if this.cooldown_factor and target.attacks.list[1] and target.attacks.list[1].cooldown then
		target.attacks.list[1].cooldown = target.attacks.list[1].cooldown * this.cooldown_factor

		if target.attacks.min_cooldown then
			target.attacks.min_cooldown = target.attacks.min_cooldown * this.cooldown_factor
		end
	end

	if this.render then
		for i = 1, #this.render.sprites do
			local s = this.render.sprites[i]

			s.ts = store.tick_ts
		end
	end

	return true
end

function scripts.mod_denas_tower.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		this.pos = target.pos
	end

	m.ts = store.tick_ts
	this.tween.ts = store.tick_ts

	while store.tick_ts - m.ts < m.duration - 0.5 do
		coroutine.yield()
	end

	this.tween.reverse = true
	this.tween.ts = store.tick_ts

	U.y_wait(store, 0.5)
	queue_remove(store, this)
end

function scripts.mod_denas_tower.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.tower then
		log.error("error removing mod_denas_tower %s", this.id)

		return false
	end

	if this.range_factor then
		target.attacks.range = target.attacks.range / this.range_factor
	end

	if this.cooldown_factor and target.attacks.list[1] then
		target.attacks.list[1].cooldown = target.attacks.list[1].cooldown / this.cooldown_factor

		if target.attacks.min_cooldown then
			target.attacks.min_cooldown = target.attacks.min_cooldown / this.cooldown_factor
		end
	end

	return true
end

scripts.mod_witch_frog = {}

function scripts.mod_witch_frog.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	m.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts
	this.render.sprites[1].z = target.render.sprites[1].z
	this.pos = target.pos

	return true
end

function scripts.mod_witch_frog.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		queue_remove(store, this)

		return
	end

	local damage_type = target.hero and m.hero_damage_type or m.damage_type

	if band(target.health.immune_to, damage_type) ~= 0 or target.health.ignore_damage then
		queue_remove(store, this)

		return
	end

	local d = E:create_entity("damage")

	d.damage_type = target.hero and m.hero_damage_type or m.damage_type
	d.value = math.random(m.damage_min, m.damage_max)
	d.source_id = m.source_id
	d.target_id = target.id

	queue_damage(store, d)

	if target.hero then
		queue_remove(store, this)

		return
	end

	U.y_wait(store, this.frog_delay)

	local af = target.render.sprites[1].flip_x
	local t = this.tween
	local t_end = t.props[1].keys[2]

	this.render.sprites[1].flip_x = af
	this.render.sprites[1].hidden = false

	U.y_wait(store, this.fx_delay + this.animation_delay - this.frog_delay)
	U.animation_start(this, "jump", nil, store.tick_ts, true)

	t_end[2].x = t_end[2].x * (af and -1 or 1)
	t.disabled = false
	t.ts = store.tick_ts

	U.y_wait(store, t_end[1])
	U.y_animation_wait(this)
	U.animation_start(this, "idle", nil, store.tick_ts, true)
	U.y_wait(store, this.animation_delay)
	U.y_animation_play(this, "puff", nil, store.tick_ts, 1)
	queue_remove(store, this)
end

scripts.mod_spectral_knight = {}

function scripts.mod_spectral_knight.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	for _, s in pairs(this.render.sprites) do
		s.ts = store.tick_ts
	end

	this.pos = target.pos
	m.ts = store.tick_ts
	target.unit.damage_factor = target.unit.damage_factor * this.damage_factor_increase
	target.health.armor = km.clamp(0, 1, target.health.armor + this.armor_increase)
	if target.motion then
		target.motion.max_speed = target.motion.max_speed * this.speed_factor
	end

	return true
end

function scripts.mod_spectral_knight.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.unit.damage_factor = target.unit.damage_factor / this.damage_factor_increase
		target.health.armor = km.clamp(0, 1, target.health.armor - this.armor_increase)
		if target.motion then
			target.motion.max_speed = target.motion.max_speed / this.speed_factor
		end
	end

	return true
end

scripts.mod_gulaemon_fly = {}

function scripts.mod_gulaemon_fly.queue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		log.debug("%s (%s) queue/insertion", this.template_name, this.id)

		target.motion.max_speed = target.motion.max_speed * this.speed_factor
	else
		log.debug("%s (%s) queue/removal", this.template_name, this.id)

		target.motion.max_speed = target.motion.max_speed / this.speed_factor
	end
end

function scripts.mod_gulaemon_fly.dequeue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		log.debug("%s (%s) dequeue/insertion", this.template_name, this.id)

		target.motion.max_speed = target.motion.max_speed / this.speed_factor
	end
end

function scripts.mod_gulaemon_fly.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	m.ts = store.tick_ts

	return true
end

function scripts.mod_gulaemon_fly.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target._should_land = true
	end

	return true
end

function scripts.mod_gulaemon_fly.update(this, store)
	local target
	local m = this.modifier

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or store.tick_ts - m.ts > m.duration or P:nodes_to_defend_point(target.nav_path) < this.nodes_limit then
			queue_remove(store, this)

			return
		end

		coroutine.yield()
	end
end

scripts.decal_sheep_big = {}

function scripts.decal_sheep_big.insert(this, store)
	if math.random() < this.delayed_play.required_clicks_fx_alt_chance then
		local d = this.delayed_play

		d.required_clicks_fx = d.required_clicks_fx_alt
		d.clicked_sound = d.clicked_sound_alt
	end

	return true
end

scripts.decal_fish = {}

function scripts.decal_fish.update(this, store, script)
	while true do
		this.render.sprites[1].hidden = true

		U.y_wait(store, math.random(5, 10))

		this.render.sprites[1].hidden = false

		U.animation_start(this, "jump", nil, store.tick_ts, false)

		this.ui.clicked = nil

		while not U.animation_finished(this) do
			if this.ui.clicked then
				AC:got(this.achievement_id)

				this.ui.clicked = nil
			end

			coroutine.yield()
		end
	end
end

scripts.graveyard_controller = {}

function scripts.graveyard_controller.update(this, store)
	local g = this.graveyard

	while not this.interrupt do
		local targets = table.filter(store.entities, function(k, v)
			return not v._in_graveyard and v.soldier and v.vis and v.health and v.health.dead and band(v.vis.flags, g.vis_has) ~= 0 and band(v.vis.flags, g.vis_bans) == 0 and band(v.vis.bans, g.vis_flags) == 0 and store.tick_ts - v.health.death_ts >= g.dead_time and (not v.reinforcement or not v.reinforcement.hp_before_timeout) and (not g.excluded_templates or not table.contains(g.excluded_templates, v.template_name))
		end)

		if #targets == 0 then
			U.y_wait(store, g.check_interval)
		else
			for _, t in ipairs(targets) do
				if this.interrupt then
					return
				end

				t._in_graveyard = true

				for _, s in ipairs(g.spawns_by_health) do
					local e, s_pos, pi, spi, ni

					if t.health.hp_max > s[2] then
						-- block empty
					else
						s_pos = table.random(g.spawn_pos)

						local nearest_nodes = P:nearest_nodes(s_pos.x, s_pos.y, g.pi and {
							g.pi
						} or nil)

						if #nearest_nodes < 1 then
							log.error("graveyard controller %s could not spawn enemy. node not found near %s,%s", this.id, s_pos.x, s_pos.y)
						else
							pi, spi, ni = unpack(nearest_nodes[1])
							e = E:create_entity(s[1])
							e.nav_path.pi, e.nav_path.spi, e.nav_path.ni = pi, math.random(1, 3), ni
							e.pos = V.vclone(s_pos)
							e.render.sprites[1].name = "raise"
							e.motion.forced_waypoint = P:node_pos(e.nav_path)

							if not g.keep_gold and e.enemy then
								e.enemy.gold = 0
							end

							queue_insert(store, e)

							break
						end
					end
				end

				U.y_wait(store, g.spawn_interval)
			end
		end
	end

	queue_remove(store, this)
end

scripts.s11_lava_spawner = {}

function scripts.s11_lava_spawner.update(this, store)
	local cooldown = this.cooldown

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	while true do
		U.y_wait(store, cooldown)
		S:queue(this.sound)

		local e = E:create_entity(this.entity)

		e.pos = V.vclone(this.pos)
		e.nav_path.pi, e.nav_path.spi, e.nav_path.ni = this.pi, 1, 1
		e.render.sprites[1].name = "raise"

		queue_insert(store, e)

		cooldown = this.cooldown_after

		if not U.is_seen(store, this.entity) then
			signal.emit("wave-notification", "icon", this.entity)
			U.mark_seen(store, this.entity)
		end
	end
end

scripts.decal_fredo = {}

function scripts.decal_fredo.update(this, store, script)
	local clicks = 0
	local s = this.render.sprites[1]

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			clicks = clicks + 1

			U.animation_start(this, "clicked", nil, store.tick_ts, false)
		end

		if clicks >= 8 then
			this.ui.can_click = false

			U.animation_start(this, "release", nil, store.tick_ts, false)
			U.y_animation_wait(this)
			AC:got("FREE_FREDO")
			queue_remove(store, this)
		end

		coroutine.yield()
	end
end

scripts.enemy_base_portal = {}

function scripts.enemy_base_portal.insert(this, store)
	if not scripts.enemy_basic.insert(this, store) then
		return false
	end

	local portal_templates = {
		"decal_demon_portal_big",
		"decal_inferno_portal",
		"decal_inferno_ground_portal",
		"veznan_portal"
	}
	local portal = table.filter(store.entities, function(_, e)
		return table.contains(portal_templates, e.template_name) and e.out_nodes and e.out_nodes[this.nav_path.pi]
	end)[1]

	if portal and portal.out_nodes[this.nav_path.pi] - this.nav_path.ni < 8 then
		local fx = E:create_entity(portal.fx_out)

		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts

		if this.unit and this.unit.mod_offset then
			fx.pos.x, fx.pos.y = fx.pos.x + this.unit.mod_offset.x, fx.pos.y + this.unit.mod_offset.y
		end

		queue_insert(store, fx)
	end

	if this.render.sprites[1].name == "raise" and this.template_name == "enemy_demon_legion" then
		this._raise_vis_bans = this.vis.bans
		this._raise_ignore_damage = this.health.ignore_damage
		this.vis.bans = bor(F_ALL)
		this.health.ignore_damage = true
		this.health_bar.hidden = true
	end

	return true
end

scripts.decal_demon_portal_big = {}

function scripts.decal_demon_portal_big.update(this, store)
	local function has_enemies_in_paths(group)
		if group and group.waves then
			for _, w in pairs(group.waves) do
				if w.path_index and this.out_nodes[w.path_index] then
					return true
				end
			end
		end

		return false
	end

	while true do
		while not has_enemies_in_paths(store.current_wave_group) and not has_enemies_in_paths(store.next_wave_group_ready) do
			coroutine.yield()
		end

		this.tween.ts = store.tick_ts
		this.tween.reverse = false

		::label_261_0::

		local current_wave = store.wave_group_number

		while current_wave == store.wave_group_number and not store.waves_finished do
			coroutine.yield()
		end

		if has_enemies_in_paths(store.current_wave_group) then
			goto label_261_0
		end

		this.tween.ts = store.tick_ts
		this.tween.reverse = true
	end
end

scripts.s15_rotten_spawner = {}

function scripts.s15_rotten_spawner.update(this, store)
	local cooldown, max_count, ts, last_wave

	while true do
		::label_263_0::

		while (not max_count or max_count == 0) and store.wave_group_number == last_wave do
			coroutine.yield()
		end

		if this.interrupt then
			break
		end

		if store.wave_group_number ~= last_wave then
			local wave_timers = this.spawn_timers[store.wave_group_number]

			cooldown, max_count = unpack(wave_timers or {
				cooldown,
				max_count
			})
			last_wave = store.wave_group_number
			ts = store.tick_ts
		end

		if not max_count or max_count == 0 then
			goto label_263_0
		end

		if cooldown < store.tick_ts - ts and max_count > 0 then
			for i = 1, max_count do
				do
					local e = E:create_entity(this.entity)
					local pos, pi, spi, ni = P:get_random_position(this.spawn_margin, bor(TERRAIN_LAND), nil, true)

					if not pos then
						local valid_nodes = P:get_valid_nodes(1)

						pi, spi, ni = math.random(1, 3), math.random(1, 3), math.random(30, P:get_defend_point_node(1) - 60)

						if not P:is_node_valid(pi, ni) then
							log.debug("s15_rotten_spawner: could not find random node")

							goto label_263_1
						end

						pos = P:node_pos(pi, spi, ni)
					end

					e.pos, e.nav_path.pi, e.nav_path.spi, e.nav_path.ni = pos, pi, spi, ni
					e.render.sprites[1].name = "raise"
					e.enemy.gold = 0

					queue_insert(store, e)
				end

				::label_263_1::
			end

			ts = store.tick_ts
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.decal_s17_barricade = {}

function scripts.decal_s17_barricade.update(this, store, script)
	local boss

	while not boss do
		boss = LU.list_entities(store.entities, this.boss_name)[1]

		if not boss then
			U.y_wait(store, 5)
		end
	end

	while boss and boss.nav_path and boss.nav_path.ni < this.destroy_node do
		coroutine.yield()
	end

	U.animation_start(this, "destroy", nil, store.tick_ts, false)
end

scripts.decal_scrat = {}

function scripts.decal_scrat.update(this, store, script)
	local clicks = 0

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil

			local fx = E:create_entity(this.touch_fx)

			fx.pos = V.vclone(this.pos)
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)

			clicks = clicks + 1

			if clicks >= 10 then
				break
			end
		end

		coroutine.yield()
	end

	this.ui.can_click = false

	U.animation_start(this, "play", nil, store.tick_ts, false)
	U.y_animation_wait(this)

	this.render.sprites[1].hidden = true

	U.animation_start(this, "end", nil, store.tick_ts, false, 2)
	AC:got("DEFEAT_ACORN")
end

scripts.burning_floor_controller = {}

function scripts.burning_floor_controller.update(this, store, script)
	local auras = LU.list_entities(store.entities, "aura_burning_floor")
	local data = this.cooldowns[store.level_mode]
	local wdata, current_wave

	local function wave_changed()
		return current_wave ~= store.wave_group_number or store.waves_finished
	end

	if not auras or not data then
		-- block empty
	else
		while true do
			repeat
				coroutine.yield()

				wdata = data[store.wave_group_number]
			until wdata

			current_wave = store.wave_group_number

			local delay, duration = unpack(wdata)

			if U.y_wait(store, delay, wave_changed) then
				-- block empty
			else
				for _, a in pairs(auras) do
					a.aura.active = true
				end

				U.y_wait(store, duration, wave_changed)

				for _, a in pairs(auras) do
					a.aura.active = false
				end

				while not wave_changed() do
					coroutine.yield()
				end
			end
		end
	end

	if not auras then
		log.error("no aura_burning_floor entities available in this level, removing controller")
	elseif not data then
		log.error("no cooldowns table defined, removing controller")
	end

	queue_remove(store, this)
end

scripts.aura_burning_floor = {}

function scripts.aura_burning_floor.update(this, store, script)
	local a = this.aura

	while true do
		while not a.active do
			coroutine.yield()
		end

		this.tween.reverse = false
		this.tween.ts = store.tick_ts

		while not U.y_wait(store, a.cycle_time, function()
			return not a.active
		end) do
			local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, target in pairs(targets) do
					local m = E:create_entity(this.aura.mod)

					m.modifier.target_id = target.id
					m.modifier.source_id = this.id

					queue_insert(store, m)
				end
			end
		end

		this.tween.reverse = true
		this.tween.ts = store.tick_ts
	end
end

scripts.decal_s23_splinter_pizza = {}

function scripts.decal_s23_splinter_pizza.update(this, store, script)
	while not this.ui.clicked do
		coroutine.yield()
	end

	this.ui.clicked = nil

	U.animation_start(this, "clicked", nil, store.tick_ts, false)
	U.y_animation_wait(this)
	AC:got("SPLINTER")

	this.render.sprites[1].prefix = "decal_s23_splinter"

	return scripts.click_play.update(this, store, script)
end

scripts.decal_bat_flying = {}

function scripts.decal_bat_flying.insert(this, store, script)
	if this.snapping then
		local v_left = store.visible_coords.left
		local v_right = store.visible_coords.right
		local positions = {
			["top left"] = v(v_left, 0),
			top = v(0, 0),
			["top right"] = v(v_right - REF_W, 0),
			["bottom right"] = v(v_right - REF_W, 0),
			bottom = v(0, 0),
			["bottom left"] = v(v_left, 0)
		}

		this.pos = positions[this.snapping]
	end

	return true
end

scripts.decal_s24_nevermore = {}

function scripts.decal_s24_nevermore.update(this, store, script)
	while not this.ui.clicked do
		coroutine.yield()
	end

	this.ui.clicked = nil

	U.animation_start(this, "clicked", nil, store.tick_ts, false)
	U.y_animation_wait(this)
	U.animation_start(this, "fly", nil, store.tick_ts, true)

	this.tween.reverse = false
	this.tween.ts = store.tick_ts

	U.y_wait(store, this.leave_time)
	AC:got("NEVERMORE")
	queue_remove(store, this)
end

scripts.decal_s25_nessie = {}

function scripts.decal_s25_nessie.update(this, store, script)
	local pause_min, pause_max = unpack(this.pause_duration)
	local animation_min, animation_max = unpack(this.animation_duration)
	local pause_ts = 0
	local animation_ts = 0
	local current_pause, current_animation

	while true do
		::label_273_0::

		U.sprites_hide(this)

		this.ui.can_click = false
		pause_ts = store.tick_ts
		current_pause = U.frandom(pause_min, pause_max)

		while current_pause > store.tick_ts - pause_ts do
			coroutine.yield()
		end

		this.pos = this.out_pos[math.random(1, #this.out_pos)]

		U.sprites_show(this)

		this.ui.can_click = true

		U.animation_start(this, "bubble_in", nil, store.tick_ts, false)
		U.y_animation_wait(this)

		while this.render.sprites[1].runs < 1 do
			if this.ui.clicked then
				goto label_273_1
			end

			coroutine.yield()
		end

		animation_ts = U.frandom(animation_min, animation_max)

		U.animation_start(this, "bubble_play", nil, store.tick_ts, true)

		while animation_ts > this.render.sprites[1].runs * fts(22) do
			if this.ui.clicked then
				goto label_273_1
			end

			coroutine.yield()
		end

		U.sprites_hide(this)

		this.ui.can_click = false

		U.animation_start(this, "bubble_out", nil, store.tick_ts, false)
		U.y_animation_wait(this)

		goto label_273_0

		::label_273_1::

		this.ui.clicked = nil

		S:queue(this.sound)
		U.animation_start(this, "clicked", nil, store.tick_ts, false)
		U.y_wait(store, fts(90))
		S:queue(this.sound)
		U.y_animation_wait(this)
		AC:got("NESSIE")
		U.sprites_hide(this)
		coroutine.yield()
	end
end

return scripts
