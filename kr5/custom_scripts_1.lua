local log = require("klua.log"):new("custom_scripts_1")

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
local SH = require("klove.shader_db")
local G = love.graphics
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot

require("i18n")

local scripts = require("custom_scripts_0")

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

local function tpos(e)
	return e.tower and e.tower.range_offset and V.v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or e.pos
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

scripts.elves_soldier_harasser_lvl4 = {}
function scripts.elves_soldier_harasser_lvl4.update(this, store, script)
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

	local function hide_shadow(isHidden)
		for i, sprite in ipairs(this.render.sprites) do
			if sprite.is_shadow then
				sprite.hidden = isHidden
			end
		end
	end

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	if this.render.sprites[1].name == "raise" then
		hide_shadow(true)
		this.health_bar.hidden = true
		U.animation_start(this, "raise", nil, store.tick_ts, 1)
		while not U.animation_finished(this) and not this.health.dead do
			coroutine.yield()
		end
		if not this.health.dead then
			hide_shadow(false)
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

		if not this.health.dead or SU.y_soldier_revive(store, this) then
			-- block empty
		else
			hide_shadow(true)
			SU.remove_modifiers(store, this)
			local tower = store.entities[this.soldier.tower_id]
			if this.powers.last_breath.level > 0 and tower and this.death_spawns.quantity > 0 then
				local unit = E:create_entity(this.death_spawns.name)
				unit.soldier.tower_id = this.soldier.tower_id
				unit.soldier.tower_soldier_idx = this.soldier.tower_soldier_idx
				unit.pos = V.v(V.add(this.pos.x, this.pos.y, tower.barrack.respawn_offset.x, tower.barrack.respawn_offset.y))
				unit.nav_rally.pos, unit.nav_rally.center = U.rally_formation_position(this.soldier.tower_soldier_idx, tower.barrack, tower.barrack.max_soldiers, 
				tower.barrack.rally_angle_offset)
				unit.nav_rally.new = true
				queue_insert(store, unit)
				tower.barrack.soldiers[this.soldier.tower_soldier_idx] = unit
				queue_remove(store, this)
			else
				SU.y_soldier_death(store, this)
			end
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
					if this.dodge.hide_shadow then
						hide_shadow(true)
					end
					U.animation_start(this, this.dodge.animation, nil, store.tick_ts, 1)

					while not U.animation_finished(this) do
						coroutine.yield()
					end
					hide_shadow(false)
				end

				signal.emit("soldier-dodge", this)
			end

			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_44_1
				end
			end

			check_tower_damage_factor()

			if this.ranged and this.ranged.range_while_blocking then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					goto label_44_1
				end
			end

			if this.melee then
				if this.dodge and this.dodge.hide_shadow and this.dodge.counter_attack_pending then
					hide_shadow(true)
				end
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
				if this.dodge and this.dodge.hide_shadow then
					hide_shadow(false)
				end

				if brk or sta ~= A_NO_TARGET then
					goto label_44_1
				end
			end

			if this.ranged and not this.ranged.range_while_blocking then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk or sta == A_DONE then
					goto label_44_1
				elseif sta == A_IN_COOLDOWN and not this.ranged.go_back_during_cooldown then
					goto label_44_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_44_1
			end

			::label_44_0::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_44_1::

		coroutine.yield()
	end
end

scripts.elves_soldier_espectral_harasser = {}
function scripts.elves_soldier_espectral_harasser.update(this, store, script)
	local brk, stam, star
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

	local function hide_shadow(isHidden)
		for i, sprite in ipairs(this.render.sprites) do
			if sprite.is_shadow then
				sprite.hidden = isHidden
			end
		end
	end

	this.reinforcement.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts

	if this.reinforcement.fade or this.reinforcement.fade_in then
		SU.y_reinforcement_fade_in(store, this)
	elseif this.render.sprites[1].name == "raise" then
		this.health.ignore_damage = true
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise, this.sound_events.raise_args)
		end
		this.health_bar.hidden = true
		hide_shadow(true)
		U.y_animation_play(this, "raise", nil, store.tick_ts, 1)
		this.health.ignore_damage = false
		if not this.health.dead then
			hide_shadow(false)
			this.health_bar.hidden = nil
		end
	end

	local ps = E:create_entity(this.particle)
	ps.particle_system.emit = this.nav_rally.new
	ps.particle_system.track_id = this.id
	queue_insert(store, ps)

	while true do
		if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			ps.particle_system.emit = nil
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end
			this.health.hp = 0
			hide_shadow(true)
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
				ps.particle_system.emit = true
				if SU.y_hero_new_rally(store, this) then
					goto label_38_1
				end
			end
			ps.particle_system.emit = nil

			check_tower_damage_factor()

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

scripts.tower_special_mercenaries = {}
function scripts.tower_special_mercenaries.update(this, store, script)
	local b = this.barrack
	local door_sid = this.render.door_sid or 2
	if this.tower_upgrade_persistent_data.max_soldiers then
		b.max_soldiers = this.tower_upgrade_persistent_data.max_soldiers
	end

	while true do
		local old_count = #b.soldiers

		b.soldiers = table.filter(b.soldiers, function(_, s)
			return store.entities[s.id] ~= nil
		end)

		if #b.soldiers > 0 and #b.soldiers ~= old_count then
			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
			end
		end

		if b.unit_bought then
			b.max_soldiers = b.max_soldiers + 1
			this.tower_upgrade_persistent_data.max_soldiers = b.max_soldiers

			for i, ss in ipairs(b.soldiers) do
				ss.nav_rally.pos, ss.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
			end

			b.unit_bought = nil

			local price = E:get_template(b.soldier_type).unit.price[this.barrack.max_soldiers]

			store.player_gold = store.player_gold - price
		end

		if b.rally_new then
			b.rally_new = false

			signal.emit("rally-point-changed", this)

			local sounds = {}
			local all_dead = true

			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
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

		if not this.tower.blocked then
			for i = 1, this.barrack.max_soldiers do
				local s = b.soldiers[i]

				if not s or s.health.dead and not store.entities[s.id] then
					if b.has_door and not b.door_open then
						U.animation_start(this, "open", nil, store.tick_ts, false, door_sid)
						U.y_animation_wait(this, door_sid)

						b.door_open = true
						b.door_open_ts = store.tick_ts
					end

					S:queue(this.spawn_sound)

					s = E:create_entity(b.soldier_type)
					s.soldier.tower_id = this.id
					s.soldier.tower_soldier_idx = i
					s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
					s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
					s.nav_rally.new = true
					s.render.sprites[1].flip_x = true

					if this.powers then
						for pn, p in pairs(this.powers) do
							s.powers[pn].level = p.level
						end
					end

					s.spawned_from_tower = true

					queue_insert(store, s)

					b.soldiers[i] = s
				end
			end
		end

		if b.has_door and b.door_open and store.tick_ts - b.door_open_ts > b.door_hold_time then
			U.animation_start(this, "close", nil, store.tick_ts, false, door_sid)
			U.y_animation_wait(this, door_sid)

			b.door_open = false
		end

		coroutine.yield()
	end
end

scripts.kr4_elven_warrior = {}
function scripts.kr4_elven_warrior.on_damage(this, store, damage)
	if not this.dodge or this.dodge.chance <= 0 or this.unit.is_stunned or this.health.dead or 
	band(damage.damage_type, DAMAGE_ALL_TYPES, bnot(bor(DAMAGE_PHYSICAL, DAMAGE_MAGICAL, DAMAGE_TRUE, DAMAGE_EXPLOSION, DAMAGE_ELECTRICAL))) ~= 0 or 
	band(damage.damage_type, DAMAGE_NO_DODGE) ~= 0 or this.dodge.chance < math.random() then
		return true
	end

	local e = E:create_entity("pop_miss")
	e.pos = V.v(this.pos.x, this.pos.y)
	if this.unit and this.unit.pop_offset then
		e.pos.y = e.pos.y + this.unit.pop_offset.y
	end
	e.pos.y = e.pos.y + e.pop_y_offset
	e.render.sprites[1].r = math.random(-21, 21) * math.pi / 180
	e.render.sprites[1].ts = store.tick_ts
	simulation:queue_insert_entity(e)
	this.dodge.active = true

	return false
end

scripts.hero_dianyun = {}

function scripts.hero_dianyun.get_info(this)
	local level = this.hero.level
	local min = this.hero.level_stats.ranged_damage_min[level]
	local max = this.hero.level_stats.ranged_damage_max[level]

	min, max = min * this.unit.damage_factor, max * this.unit.damage_factor
	min, max = math.ceil(min), math.ceil(max)

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_type = DAMAGE_MAGICAL,
		damage_icon = this.info.damage_icon,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_dianyun.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	local s

	s = this.hero.skills.ricochet

	if initial and s.level > 0 then
		local a = this.ranged.attacks[2]
		a.cooldown = s.cooldown[s.level]
		local b = E:get_template(a.bullet)
		local bullet = b.bullet
		bullet.damage_min = s.damage_min[s.level]
		bullet.damage_max = s.damage_max[s.level]
		b.bounce = s.bounce[s.level]
		local bounce_bullet = E:get_template(b.bounce_bullet).bullet
		bounce_bullet.damage_min = s.damage_min[s.level]
		bounce_bullet.damage_max = s.damage_max[s.level]
		a.disabled = nil
	end

	s = this.hero.skills.lord_storm

	if initial and s.level > 0 then
		local a = this.ranged.attacks[1]
		local controller = E:get_template(a.entity)
		controller.max_targets = s.max_targets[s.level]
	end

	s = this.hero.skills.divine_rain

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]
		a.cooldown = s.cooldown[s.level]
		local aura = E:get_template(a.aura).aura
		aura.duration = s.duration[s.level]
		local mod = E:get_template(aura.mods[1])
		mod.hps.heal_min = s.healing_points_tick[s.level]
		mod.hps.heal_max = s.healing_points_tick[s.level]
		a.disabled = nil
	end

	s = this.hero.skills.supreme_wave

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]
		a.cooldown = s.cooldown[s.level]
		local aura = E:get_template(a.entity).aura
		local mod = E:get_template(aura.mods[1]).modifier
		mod.duration = s.stun[s.level]
		a.disabled = nil
	end

	s = this.hero.skills.ultimate

	if initial and s.level > 0 then
		local u = E:get_template(s.controller_name)
		u.cooldown = s.cooldown[s.level]

		local entity = E:get_template(u.entity)
		entity.bullets_to_death = s.bullets_to_death[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_dianyun.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.ranged.order = U.attack_order(this.ranged.attacks)

	if this.auras then
		for _, a in ipairs(this.auras.list) do
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

	return true
end

function scripts.hero_dianyun.update(this, store)
	local h = this.health
	local shadow_sprite = this.render.sprites[2]
	local lord_storm_attack = this.ranged.attacks[1]
	local ricochet_attack = this.ranged.attacks[2]
	local divine_rain_attack = this.timed_attacks.list[1]
	local supreme_wave_attack = this.timed_attacks.list[2]
	local attack, skill

	local function hero_death_and_respawn()
		local h = this.health
		local he = this.hero
	
		this.ui.can_click = false
	
		local death_ts = store.tick_ts
		local dead_lifetime = h.dead_lifetime
	
		U.unblock_target(store, this)

		S:queue(this.sound_events.death, this.sound_events.death_args)

		if this.unit.death_animation then
			U.animation_start(this, this.unit.death_animation, nil, store.tick_ts, false, 1)
		else
			U.animation_start(this, "death", nil, store.tick_ts, false, 1)
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
			s.hidden = false
		end
	
		h.ignore_damage = true
	
		S:queue(this.sound_events.respawn)
	
		if he.respawn_animation then
			U.y_animation_play(this, he.respawn_animation, nil, store.tick_ts, 1, 1)
		else
			U.y_animation_play(this, "respawn", nil, store.tick_ts, 1, 1)
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

	local function hideSprites(isHidden)
		for i = 2, #this.render.sprites, 1 do
			if i ~= 3 then
				this.render.sprites[i].hidden = isHidden
			end
		end
	end

	local function changeOffsetX(flipX)
		local flipSign = flipX and -1 or 1
		for i = 3, #this.render.sprites, 1 do
			if not this.render.sprites[i]._original_offset then
				this.render.sprites[i]._original_offset = V.vclone(this.render.sprites[i].offset)
			end
			this.render.sprites[i].offset.x = flipSign * this.render.sprites[i]._original_offset.x
		end
	end

	if not ricochet_attack.disabled then
		ricochet_attack.ts = store.tick_ts - ricochet_attack.cooldown
	end
	if not divine_rain_attack.disabled then
		divine_rain_attack.ts = store.tick_ts - divine_rain_attack.cooldown
	end
	if not supreme_wave_attack.disabled then
		supreme_wave_attack.ts = store.tick_ts - supreme_wave_attack.cooldown
	end

	this.health_bar.hidden = false
	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

	while true do
		if h.dead then
			hideSprites(true)
			hero_death_and_respawn()
			hideSprites(nil)
			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		SU.heroes_visual_learning_upgrade(store, this)
		SU.heroes_lone_wolves_upgrade(store, this)
		SU.alliance_merciless_upgrade(store, this)
		SU.alliance_corageous_upgrade(store, this)

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "lvlUp", nil, store.tick_ts, 1, 1)
		end

		local skip
		local function ranged_attacks()
			if skip then
				return
			end
			for _, i in ipairs(this.ranged.order) do
				attack = this.ranged.attacks[i]
				if attack.disabled or (attack.sync_animation and not this.render.sprites[1].sync_flag) or (store.tick_ts - attack.ts < attack.cooldown) then
					-- block empty
				else
					if i == 2 then
						if store.tick_ts - lord_storm_attack.ts >= attack.min_cooldown then
							local targets = U.find_enemies_in_range(store.entities, this.pos, attack.min_range, attack.max_range, attack.vis_flags, attack.vis_bans)
							local amount = 0
							local crowdsTarget
							if targets and #targets >= attack.min_targets then
								for _, t in ipairs(targets) do
									local enemy, crowds = U.find_foremost_enemy(store.entities, t.pos, 0, attack.crowds_range, nil, attack.vis_flags, attack.vis_bans)
									if crowds and #crowds >= attack.min_targets and #crowds > amount then
										amount = #crowds
										crowdsTarget = crowds
									end
								end
							end
							if crowdsTarget then
								local fx = E:create_entity(attack.start_fx)
								fx.pos = this.pos
								for _, sprite in ipairs(fx.render.sprites) do
									sprite.ts = store.tick_ts
									sprite.flip_x = this.render.sprites[1].flip_x
									sprite.offset = V.vclone(attack.start_offset)
								end
								queue_insert(store, fx)

								local target = crowdsTarget[1]
								local bullet = E:create_entity(attack.bullet)
								bullet.pos = target.pos
								bullet.spawn_pos_offset = attack.spawn_pos_offset
								bullet.bullet.source_id = this.id
								bullet.bullet.target_id = target.id
								if bullet.bullet.use_unit_damage_factor then
									bullet.bullet.damage_factor = this.source.unit.damage_factor
								end
								queue_insert(store, bullet)
								attack.ts = store.tick_ts
								if attack.xp_from_skill then
									SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
								end
								break
							else
								SU.delay_attack(store, attack, fts(10))
							end
						else
							SU.delay_attack(store, attack, fts(10))
						end
					else
						local targets = U.find_enemies_in_range(store.entities, this.pos, attack.min_range, attack.max_range, attack.vis_flags, attack.vis_bans, function(e)
							return not e._lord_storm_ts or store.tick_ts - e._lord_storm_ts >= attack.cooldown
						end)
						if targets then
							local controller = E:create_entity(attack.entity)
							controller.pos = this.pos
							controller.source = this
							controller.xp_gain_factor = attack.xp_gain_factor
							controller.min_range = attack.min_range
							controller.max_range = attack.max_range
							controller.vis_flags = attack.vis_flags
							controller.vis_bans = attack.vis_bans
							controller.cooldown = attack.cooldown
							controller.basic_attack = attack.basic_attack
							queue_insert(store, controller)
							attack.ts = store.tick_ts
							break
						end
					end
				end
			end
		end

		local function hero_walk_waypoints(store, this, animation)
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
		
				changeOffsetX(new_af)
				U.animation_start(this, an, new_af, store.tick_ts, true, nil)
				last_af = new_af
				ranged_attacks()

				while not this.motion.arrived do
					if this.health.dead and not this.health.ignore_damage then
						return true
					end
		
					if r.new then
						return false
					end
		
					U.walk(this, store.tick_length, nil, unsnap)

					ranged_attacks()
					coroutine.yield()
		
					this.motion.speed.x, this.motion.speed.y = 0, 0
				end
			end
		end

		local function hero_new_rally(store, this)
			local r = this.nav_rally

			if r.new then
				r.new = false

				U.unblock_target(store, this)

				if this.sound_events then
					S:queue(this.sound_events.change_rally_point)
				end

				local vis_bans = this.vis.bans
				local prev_immune = this.health.immune_to

				this.vis.bans = F_ALL
				this.health.immune_to = r.immune_to

				local out = hero_walk_waypoints(store, this)

				U.animation_start(this, "idle", nil, store.tick_ts, true, nil)

				this.vis.bans = vis_bans
				this.health.immune_to = prev_immune

				return out
			end
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
			skip = true
		else
			while this.nav_rally.new do
				if hero_new_rally(store, this) then
					skip = true
				end
				ranged_attacks()
			end
		end

		ranged_attacks()

		if not skip then
			attack = divine_rain_attack
			if not divine_rain_attack.disabled and store.tick_ts - divine_rain_attack.ts > divine_rain_attack.cooldown then
				local pos = U.find_soldier_crowd_position(store.entities, this.pos, attack.min_range, attack.max_range, attack.vis_flags, attack.vis_bans, function(e)
					return e.id ~= this.id and e.health.hp <= e.health.hp_max * attack.health_trigger_factor
				end, attack.crowds_range, attack.min_targets, true, U.position_type.average)
				if pos then
					local aura = E:create_entity(attack.aura)
					aura.pos = pos
					local start_ts = store.tick_ts
					local an, af, ai = U.animation_name_facing_point(this, attack.animation, aura.pos)
					U.animation_start(this, an, af, store.tick_ts, nil, 1)
					changeOffsetX(af)
					U.y_wait(store, attack.cast_time)
					queue_insert(store, aura)
					U.y_animation_wait(this)
					attack.ts = start_ts
					if attack.xp_from_skill then
						SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
					end
					skip = true
				else
					SU.delay_attack(store, attack, 0.1)
				end
			end
		end

		if not skip then
			attack = supreme_wave_attack
			if not supreme_wave_attack.disabled and store.tick_ts - supreme_wave_attack.ts > supreme_wave_attack.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, attack.min_range, attack.max_range, attack.vis_flags, attack.vis_bans)
				local target, nodes
				if targets and #targets >= attack.min_targets then
					for _, t in ipairs(targets) do
						if GR:cell_is(t.pos.x, t.pos.y, TERRAIN_LAND) then
							local crowds = U.find_enemies_in_range(store.entities, t.pos, 0, attack.crowds_range, attack.vis_flags, attack.vis_bans)
							if crowds and #crowds >= attack.min_targets then
								target = crowds[1]
								break
							end
						end
					end
				end
				if target then
					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local available_paths = {}
					for k, v in pairs(P.paths) do
						table.insert(available_paths, k)
					end
					if store.level.ignore_walk_backwards_paths then
						available_paths = table.filter(available_paths, function(k, v)
							return not table.contains(store.level.ignore_walk_backwards_paths, v)
						end)
					end
					nodes = P:nearest_nodes(this.pos.x, this.pos.y, available_paths, nil, nil, NF_RALLY)
					if #nodes < 1 then
						target = nil
					else
						local pi, spi, ni = unpack(nodes[1])
						local nodepos = P:node_pos(pi, spi, ni)
						local dist = V.dist(this.pos.x, this.pos.y, nodepos.x, nodepos.y)
						if dist > attack.distance_to_start_node then
							target = nil
						end
					end
				end

				if target then
					local start_ts = store.tick_ts
					local an, af, ai = U.animation_name_facing_point(this, attack.animation, target.pos)
					U.animation_start(this, an, af, store.tick_ts, nil, 1)
					changeOffsetX(af)
					U.y_wait(store, attack.cast_time)
					
					local positions = {}
					local function positions_too_close(new_pos)
						for _, p in ipairs(positions) do
							local dist = V.dist(new_pos.x, new_pos.y, p.x, p.y)
							if dist < 10 then
								return true
							end
						end
						return false
					end

					for i = 1, #nodes do
						local pi, spi, ni = unpack(nodes[i])
						local nodepos = P:node_pos(pi, spi, ni)
						local dist = V.dist(this.pos.x, this.pos.y, nodepos.x, nodepos.y)
						if dist < attack.distance_to_start_node then
							local ni_backwards = ni - attack.start_nodes_offset
							local ni_forward = ni + attack.start_nodes_offset
							local controller1 = E:create_entity(attack.controller)
							controller1.subpaths = {}
							controller1.pos = V.vclone(this.pos)
							controller1.entity = attack.entity
							controller1.floor_decal = attack.floor_decal
							controller1.delay_between_objects = attack.delay_between_objects
							local controller2 = E:create_entity(attack.controller)
							controller2.subpaths = {}
							controller2.pos = V.vclone(this.pos)
							controller2.entity = attack.entity
							controller2.floor_decal = attack.floor_decal
							controller2.delay_between_objects = attack.delay_between_objects
							local ni_aux
							for j = 1, attack.max_objects do
								local new_pos
								ni_aux = ni_backwards - (j - 1) * attack.nodes_between_objects
								for subpath = 1, 3, 1 do
									new_pos = nil
									if not controller1.subpaths[subpath] then
										controller1.subpaths[subpath] = {}
									end
									if P:is_node_valid(pi, ni_aux) then
										new_pos = P:node_pos(pi, subpath, ni_aux)
										if positions_too_close(new_pos) then
											new_pos = nil
										else
											table.insert(positions, new_pos)
										end
									end
									table.insert(controller1.subpaths[subpath], new_pos)
								end

								ni_aux = ni_forward + (j - 1) * attack.nodes_between_objects
								for subpath = 1, 3, 1 do
									new_pos = nil
									if not controller2.subpaths[subpath] then
										controller2.subpaths[subpath] = {}
									end
									if P:is_node_valid(pi, ni_aux) then
										new_pos = P:node_pos(pi, subpath, ni_aux)
										if positions_too_close(new_pos) then
											new_pos = nil
										else
											table.insert(positions, new_pos)
										end
									end
									table.insert(controller2.subpaths[subpath], new_pos)
								end
							end
							queue_insert(store, controller1)
							queue_insert(store, controller2)
						end
					end
					U.y_animation_wait(this)
					attack.ts = start_ts
					if attack.xp_from_skill then
						SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
					end
					skip = true
				else
					SU.delay_attack(store, attack, fts(10))
				end
			end
		end

		if not skip then
			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		coroutine.yield()
	end
end

scripts.hero_dianyun_ultimate = {}

function scripts.hero_dianyun_ultimate.can_fire_fn(this, x, y, store)
	return GR:cell_is_only(x, y, TERRAIN_LAND) and P:valid_node_nearby(x, y, nil, NF_RALLY)
end

function scripts.hero_dianyun_ultimate.update(this, store)
	local e = E:create_entity(this.entity)
	e.pos = V.vclone(this.pos)
	queue_insert(store, e)
	queue_remove(store, this)
end

scripts.controller_lord_storm = {}

function scripts.controller_lord_storm.update(this, store)
	local upg_lf = UP:get_upgrade("heroes_lethal_focus")

	for i = 1, this.max_targets, 1 do
		local _, targets = U.find_foremost_enemy(store.entities, this.pos, this.min_range, this.max_range, nil, 
		this.vis_flags, this.vis_bans, function(e)
			return not e._lord_storm_ts or store.tick_ts - e._lord_storm_ts >= this.cooldown
		end)
	
		if targets and targets[1] then
			local target = targets[1]
			local bullet = E:create_entity(this.bullet)
			bullet.pos = target.pos
			bullet.spawn_pos_offset = this.spawn_pos_offset
			bullet.bullet.source_id = this.source.id
			bullet.bullet.target_id = target.id
			bullet.bullet.xp_dest_id = this.source.id
			bullet.bullet.xp_gain_factor = this.xp_gain_factor
			if bullet.bullet.use_unit_damage_factor then
				bullet.bullet.damage_factor = this.source.unit.damage_factor
			end
			if upg_lf and this.basic_attack then
				if not this._lethal_focus_deck then
					this._lethal_focus_deck = SU.deck_new(upg_lf.trigger_cards, upg_lf.total_cards)
				end
				local triggered_lethal_focus = SU.deck_draw(this._lethal_focus_deck)
				if triggered_lethal_focus then
					bullet.bullet.damage_factor = bullet.bullet.damage_factor * upg_lf.damage_factor
					bullet.bullet.pop = {
						"pop_crit"
					}
					bullet.bullet.pop_chance = 1
					bullet.bullet.pop_conds = DR_DAMAGE
				end
			end
			queue_insert(store, bullet)
			target._lord_storm_ts = store.tick_ts
			if i == this.max_targets then
				break
			else
				U.y_wait(store, this.delay_between_rays)
			end
		else
			break
		end
	end
	queue_remove(store, this)
end

scripts.hero_dianyun_lightning = {}

function scripts.hero_dianyun_lightning.update(this, store, script)
	local bullet = this.bullet
	local sprite = this.render.sprites[1]
	local target = store.entities[bullet.target_id]

	if not target then
		queue_remove(store, this)
		return
	end

	if target.render and target.unit and target.unit.hit_offset then
		local flip_sign = target.render.sprites[1].flip_x and -1 or 1
		sprite.offset.x = target.unit.hit_offset.x * flip_sign + this.spawn_pos_offset.x
		sprite.offset.y = target.unit.hit_offset.y + this.spawn_pos_offset.y
	else
		sprite.offset.x = this.spawn_pos_offset.x
		sprite.offset.y = this.spawn_pos_offset.y
	end

	sprite.ts = store.tick_ts

	while store.tick_ts - sprite.ts < bullet.hit_time do
		coroutine.yield()
		if target and target.health.dead then
			target = nil
		end
	end

	local pop = SU.create_bullet_pop(store, this)
	if pop then
		queue_insert(store, pop)
	end

	if target then
		local damage = E:create_entity("damage")
		damage.source_id = this.id
		damage.target_id = target.id
		local damage_min = math.ceil(bullet.damage_min * bullet.damage_factor)
		local damage_max = math.ceil(bullet.damage_max * bullet.damage_factor)
		damage.value = math.random(damage_min, damage_max)
		damage.damage_type = bullet.damage_type
		damage.xp_gain_factor = bullet.xp_gain_factor
		damage.xp_dest_id = bullet.xp_dest_id
		queue_damage(store, damage)

		if bullet.mod then
			local mod = E:create_entity(bullet.mod)
			mod.modifier.target_id = target.id
			queue_insert(store, mod)
		end
	end

	if bullet.hit_fx then
		local hit_fx_pos = V.vclone(this.pos)
		if target and target.render and target.unit and target.unit.hit_offset then
			local flip_sign = target.render.sprites[1].flip_x and -1 or 1
			hit_fx_pos.x = target.unit.hit_offset.x * flip_sign + hit_fx_pos.x
			hit_fx_pos.y = target.unit.hit_offset.y + hit_fx_pos.y
		end
		SU.insert_sprite(store, bullet.hit_fx, hit_fx_pos)
	end

	while not U.animation_finished(this) do
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.hero_dianyun_lightning_ricochet_cloud = {}

function scripts.hero_dianyun_lightning_ricochet_cloud.update(this, store, script)
	local bullet = this.bullet
	local sprite = this.render.sprites[1]
	local target = store.entities[bullet.target_id]

	if not target then
		queue_remove(store, this)
		return
	end

	if target.render and target.unit and target.unit.hit_offset then
		local flip_sign = target.render.sprites[1].flip_x and -1 or 1
		sprite.offset.x = target.unit.hit_offset.x * flip_sign + this.spawn_pos_offset.x
		sprite.offset.y = target.unit.hit_offset.y + this.spawn_pos_offset.y
	else
		sprite.offset.x = this.spawn_pos_offset.x
		sprite.offset.y = this.spawn_pos_offset.y
	end

	sprite.ts = store.tick_ts

	while store.tick_ts - sprite.ts < bullet.hit_time do
		coroutine.yield()
		if target and target.health.dead then
			target = nil
		end
	end

	if target then
		local damage = E:create_entity("damage")
		damage.source_id = this.id
		damage.target_id = target.id
		local damage_min = math.ceil(bullet.damage_min * bullet.damage_factor)
		local damage_max = math.ceil(bullet.damage_max * bullet.damage_factor)
		damage.value = math.random(damage_min, damage_max)
		damage.damage_type = bullet.damage_type
		queue_damage(store, damage)

		if bullet.mod then
			local mod = E:create_entity(bullet.mod)
			mod.modifier.target_id = target.id
			queue_insert(store, mod)
		end
	end

	if bullet.hit_fx then
		local hit_fx_pos = V.vclone(this.pos)
		if target and target.render and target.unit and target.unit.hit_offset then
			local flip_sign = target.render.sprites[1].flip_x and -1 or 1
			hit_fx_pos.x = target.unit.hit_offset.x * flip_sign + hit_fx_pos.x
			hit_fx_pos.y = target.unit.hit_offset.y + hit_fx_pos.y
		end
		SU.insert_sprite(store, bullet.hit_fx, hit_fx_pos)
	end

	while store.tick_ts - sprite.ts < this.bounce_delay do
		coroutine.yield()
	end

	if this.bounce and this.bounce > 0 then
		local seen_targets = target and { target.id } or {}
		local bounce_target = U.find_nearest_enemy(store.entities, this.pos, 0, this.bounce_range, this.bounce_vis_flags,
		this.bounce_vis_bans, function(v)
			return not table.contains(seen_targets, v.id)
		end)
		if bounce_target then
			local bounceBullet = E:create_entity(this.bounce_bullet)
			bounceBullet.bullet.damage_factor = bullet.damage_factor
			bounceBullet.pos.x, bounceBullet.pos.y = this.pos.x, this.pos.y
			if target and target.render and target.unit and target.unit.hit_offset then
				local flip_sign = target.render.sprites[1].flip_x and -1 or 1
				bounceBullet.pos.x = target.unit.hit_offset.x * flip_sign + bounceBullet.pos.x
				bounceBullet.pos.y = target.unit.hit_offset.y + bounceBullet.pos.y
			end
			bounceBullet.bullet.from = V.vclone(bounceBullet.pos)
			bounceBullet.bullet.to = V.vclone(bounce_target.pos)
			if target then
				bounceBullet.bullet.source_id = target.id
			end
			bounceBullet.bullet.target_id = bounce_target.id
			bounceBullet.bounce_bullet = this.bounce_bullet
			bounceBullet.bounce_range = this.bounce_range
			bounceBullet.bounce_vis_flags = this.bounce_vis_flags
			bounceBullet.bounce_vis_bans = this.bounce_vis_bans
			bounceBullet.bounce_delay = this.bounce_delay
			bounceBullet.bounce = this.bounce - 1
			bounceBullet.seen_targets = seen_targets
			queue_insert(store, bounceBullet)
		end
	end

	while not U.animation_finished(this) do
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.hero_dianyun_lightning_ricochet = {}

function scripts.hero_dianyun_lightning_ricochet.update(this, store, script)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local source = store.entities[b.source_id]
	local dest = b.to
	s.scale = V.v(1, 1)
	
	if not target then
		queue_remove(store, this)
		return
	end

	local function update_sprite()
		if target then
			dest.x, dest.y = target.pos.x, target.pos.y
			if target.render and target.unit and target.unit.hit_offset then
				local flip_sign = target.render.sprites[1].flip_x and -1 or 1
				dest.x = target.unit.hit_offset.x * flip_sign + dest.x
				dest.y = target.unit.hit_offset.y + dest.y
			end
		end

		if source then
			this.pos.x, this.pos.y = source.pos.x, source.pos.y
			if source.render and source.unit and source.unit.hit_offset then
				local flip_sign = source.render.sprites[1].flip_x and -1 or 1
				this.pos.x = source.unit.hit_offset.x * flip_sign + this.pos.x
				this.pos.y = source.unit.hit_offset.y + this.pos.y
			end
		end

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
	end

	s.ts = store.tick_ts
	update_sprite()
	while store.tick_ts - s.ts < b.hit_time do
		coroutine.yield()
		update_sprite()
		if target and target.health.dead then
			target = nil
		end
	end

	if target then
		local damage = E:create_entity("damage")
		damage.source_id = this.id
		damage.target_id = target.id
		local damage_min = math.ceil(b.damage_min * b.damage_factor)
		local damage_max = math.ceil(b.damage_max * b.damage_factor)
		damage.value = math.random(damage_min, damage_max)
		damage.damage_type = b.damage_type
		queue_damage(store, damage)

		if b.mod then
			local mod = E:create_entity(b.mod)
			mod.modifier.target_id = target.id
			queue_insert(store, mod)
		end
	end

	if b.hit_fx then
		local hit_fx_pos = V.vclone(dest)
		if target and target.render and target.unit and target.unit.hit_offset then
			local flip_sign = target.render.sprites[1].flip_x and -1 or 1
			hit_fx_pos.x = target.unit.hit_offset.x * flip_sign + hit_fx_pos.x
			hit_fx_pos.y = target.unit.hit_offset.y + hit_fx_pos.y
		end
		SU.insert_sprite(store, b.hit_fx, hit_fx_pos)
	end

	while store.tick_ts - s.ts < this.bounce_delay do
		coroutine.yield()
		update_sprite()
		if target and target.health.dead then
			target = nil
		end
	end

	if target then
		table.insert(this.seen_targets, target.id)		
	end

	if this.bounce and this.bounce > 0 then
		local bounce_target = U.find_nearest_enemy(store.entities, dest, 0, this.bounce_range, this.bounce_vis_flags,
			this.bounce_vis_bans, function(v)
			return not table.contains(this.seen_targets, v.id)
		end)
		if bounce_target then
			local bounceBullet = E:create_entity(this.bounce_bullet)
			bounceBullet.bullet.damage_factor = b.damage_factor
			bounceBullet.pos = V.vclone(dest)
			bounceBullet.bullet.from = V.vclone(bounceBullet.pos)
			bounceBullet.bullet.to = V.vclone(bounce_target.pos)
			if target then
				bounceBullet.bullet.source_id = target.id
			end
			bounceBullet.bullet.target_id = bounce_target.id
			bounceBullet.bounce_bullet = this.bounce_bullet
			bounceBullet.bounce_range = this.bounce_range
			bounceBullet.bounce_vis_flags = this.bounce_vis_flags
			bounceBullet.bounce_vis_bans = this.bounce_vis_bans
			bounceBullet.bounce_delay = this.bounce_delay
			bounceBullet.bounce = this.bounce - 1
			bounceBullet.seen_targets = this.seen_targets
			queue_insert(store, bounceBullet)
		end
	end

	while not U.animation_finished(this) do
		coroutine.yield()
		update_sprite()
	end

	queue_remove(store, this)	
end

scripts.controller_decal_hero_dianyun_supreme_wave_spawner = {}

function scripts.controller_decal_hero_dianyun_supreme_wave_spawner.update(this, store, script)
	local function spawn_objects(pos)
		if not pos then
			return
		end
		pos = V.v(pos.x + math.random(-4, 4), pos.y + math.random(-3, 3))
		local aura = E:create_entity(this.entity)
		aura.pos = pos
		queue_insert(store, aura)
		local decal = E:create_entity(this.floor_decal)
		decal.pos = pos
		decal.tween.disabled = false
		decal.tween.ts = store.tick_ts
		queue_insert(store, decal)
	end

	for i = 1, #this.subpaths[1] do
		spawn_objects(this.subpaths[1][i])
		U.y_wait(store, this.delay_between_objects)
		spawn_objects(this.subpaths[2][i])
		spawn_objects(this.subpaths[3][i])
		U.y_wait(store, this.delay_between_objects)
	end

	queue_remove(store, this)
end

scripts.mod_dianyun_passive = {}

function scripts.mod_dianyun_passive.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if not target or not target.health or target.health.dead or not target.enemy then
		return false
	end
	return true
end

function scripts.mod_dianyun_passive.remove(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]
	local aura = store.entities[m.source_id]
	local source
	if aura then
		source = store.entities[aura.aura.source_id]
	end
	if target and target.health and target.health.dead and target.pos and source and source.health and not source.health.dead then
		local fx = E:create_entity(this.fx)
		fx.pos = V.vclone(target.pos)
		fx.render.sprites[1].ts = store.tick_ts
		queue_insert(store, fx)
		store.player_gold = store.player_gold + this.gold_reward
	end
	return true
end

scripts.hero_dianyun_electric_son = {}
function scripts.hero_dianyun_electric_son.update(this, store, script)
	local attack = this.ranged.attacks[1]

	local function idle()
		U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, 1)
	
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

	U.y_animation_play(this, "spawn", nil, store.tick_ts)

	attack.ts = store.tick_ts - attack.cooldown
	local start_ts = store.tick_ts
	local bullets_shot = 0

	while true do
		if store.tick_ts - start_ts > this.duration or bullets_shot >= this.bullets_to_death then
			U.y_animation_play(this, "death", nil, store.tick_ts)
			break
		end

		if store.tick_ts - attack.ts >= attack.cooldown then
			local target = U.find_foremost_enemy(store.entities, this.pos, attack.min_range, attack.max_range, nil, 
			attack.vis_flags, attack.vis_bans)

			if target and target.health and not target.health.dead and target.pos then
				local ts = store.tick_ts
				local an, af, ai = U.animation_name_facing_point(this, attack.animation, target.pos)
				U.animation_start(this, an, af, store.tick_ts, false, 1)
				U.y_wait(store, attack.shoot_time)
				local b = E:create_entity(attack.bullet)
				local flipSign = af and -1 or 1
				b.bullet.from = V.v(this.pos.x + attack.bullet_start_offset.x * flipSign, this.pos.y + attack.bullet_start_offset.y)
				b.bullet.to = V.v(target.pos.x, target.pos.y)
				if target.unit and target.unit.hit_offset then
					b.bullet.to.x = target.pos.x + target.unit.hit_offset.x
					b.bullet.to.y = target.pos.y + target.unit.hit_offset.y
				end
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id
				b.pos = V.vclone(b.bullet.from)
				queue_insert(store, b)
				bullets_shot = bullets_shot + 1
				attack.ts = ts
				U.y_animation_wait(this)
			else
				SU.delay_attack(store, attack, 0.2)
			end
		end

		idle()

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.controller_item_hero_elves_archer = {}
function scripts.controller_item_hero_elves_archer.insert(this, store)
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
					value.level = 3
				end
			end
		end
		queue_insert(store, entity)
	end

	return false
end

scripts.tower_spirit_mausoleum_bolt = {}
function scripts.tower_spirit_mausoleum_bolt.update(this, store, script)
	local b = this.bullet
	local fm = this.force_motion
	local target
	if b.target_id then
		target = store.entities[b.target_id]
	end
	local ps
	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id
		queue_insert(store, ps)
	end

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local nx, ny, stx, sty
		
		if not target then
			nx, ny = V.mul(b.max_speed, V.normalize(dx, dy))
			stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)
			if dist <= 4 * b.max_speed * store.tick_length then
				stx, sty = V.mul(this.max_acceleration, V.normalize(stx, sty))
			end
			fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(this.max_acceleration, V.mul(this.travel_step, stx, sty)))
			fm.v.x, fm.v.y = V.trim(b.max_speed, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
			this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
			fm.a.x, fm.a.y = 0, 0
			return dist < b.max_speed * store.tick_length
		else
			nx, ny = V.mul(fm.max_v, V.normalize(dx, dy))
			stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)
			if dist <= 4 * fm.max_v * store.tick_length then
				stx, sty = V.mul(fm.max_a, V.normalize(stx, sty))
			end
			fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step, stx, sty)))
			fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
			this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
			fm.a.x, fm.a.y = 0, 0
			return dist <= fm.max_v * store.tick_length
		end
	end

	local pred_pos
	if target then
		pred_pos = P:predict_enemy_pos(target, fts(5))
	else
		pred_pos = b.to
	end
	
	local iix, iiy = V.normalize(pred_pos.x - this.pos.x, pred_pos.y - this.pos.y)
	local last_pos = V.vclone(this.pos)
	
	this.render.sprites[1].ts = store.tick_ts
	b.ts = store.tick_ts
	this.travel_ts = store.tick_ts

	while true do
		if b.target_id then
			target = store.entities[b.target_id]
			if this.target_found then
				this.target_found = nil
				iix, iiy = V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y)
			end
		end

		if target and target.health and not target.health.dead then
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
		end

		if not target and store.tick_ts - this.travel_ts < this.travel_impulse_duration then
			local t = store.tick_ts - this.travel_ts
			fm.a.x, fm.a.y = V.mul((this.travel_peak - t) * this.travel_impulse, V.rotate(this.initial_angle * (b.shot_index % 2 == 0 and 1 or -1), iix, iiy))
		elseif this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
			local t = store.tick_ts - b.ts

			if this.initial_impulse_angle_abs then
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle_abs, 1, 0))
			else
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle * (b.shot_index % 2 == 0 and 1 or -1), iix, iiy))
			end
		end

		last_pos.x, last_pos.y = this.pos.x, this.pos.y

		if move_step(b.to) then
			if not target then
				this.pos.x, this.pos.y = b.to.x, b.to.y
				this.travel_ts = store.tick_ts + store.tick_length
				if b.to.x == b.from.x and b.to.y == b.from.y then
					b.shot_index = b.shot_index % #b.destination_offsets + 1
					b.destination_index = b.destination_index % #b.destination_offsets + 1
					local offset = b.destination_offsets[b.destination_index]
					b.to.x, b.to.y = b.from.x + offset.x, b.from.y + offset.y
				else
					if this.step_times > 0 then
						if not this._step_times then
							this._step_times = 0
						end
						if this._step_times < this.step_times then
							b.from.y = b.from.y + this.step_y
							this._step_times = this._step_times + 1
						end
					end
					b.to.x, b.to.y = b.from.x, b.from.y
				end
				iix, iiy = V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y)
			else
				break
			end
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
			ps.particle_system.flip_x = flip_x
			ps.particle_system.emit_direction = this.render.sprites[1].r
		end

		coroutine.yield()
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y

	if b.damage_radius and b.damage_radius > 0 then
		local targetPos = target and target.pos or b.to
		local targets = U.find_enemies_in_range(store.entities, targetPos, 0, b.damage_radius, b.vis_flags, b.vis_bans)
		if targets then
			for _, target in ipairs(targets) do
				local d = SU.create_bullet_damage(b, target.id, this.id)
				queue_damage(store, d)
				if b.mod or b.mods then
					local mods = b.mods or {
						b.mod
					}
					for _, mod_name in ipairs(mods) do
						local m = E:create_entity(mod_name)
						m.modifier.target_id = target.id
						m.modifier.level = b.level
						queue_insert(store, m)
					end
				end
			end
		end
	elseif target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)
		queue_damage(store, d)
		if b.mod or b.mods then
			local mods = b.mods or {
				b.mod
			}
			for _, mod_name in ipairs(mods) do
				local m = E:create_entity(mod_name)
				m.modifier.target_id = b.target_id
				m.modifier.level = b.level
				queue_insert(store, m)
			end
		end
	end
	
	this.render.sprites[1].hidden = true

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)
		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].runs = 0
		if target and fx.render.sprites[1].size_names then
			fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
		end
		queue_insert(store, fx)
	end

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)

		decal.pos = V.vclone(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		queue_insert(store, decal)
	end

	SU.create_bullet_hit_payload(this, store)

	if this.sound_events and this.sound_events.hit then
		S:queue(this.sound_events.hit)
	end
	
	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false
		U.y_wait(store, ps.particle_system.particle_lifetime[2])
	end

	queue_remove(store, this)
end

scripts.soldier_from_enemy = {}
function scripts.soldier_from_enemy.update(this, store, script)
	local brk, sta

	local function hide_shadow(isHidden)
		for i, sprite in ipairs(this.render.sprites) do
			if sprite.is_shadow then
				sprite.hidden = isHidden
			end
		end
	end

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	if this.ranged and this.ranged.order then
		for _, i in ipairs(this.ranged.order) do
			local ar = this.ranged.attacks[i]
			ar.ts = store.tick_ts
			if this.ranged.cooldown and ar.shared_cooldown then
				ar.cooldown = this.ranged.cooldown
			end
		end
	end

	while true do
		if this.cloak then
			this.vis.flags = band(this.vis.flags, bnot(this.cloak.flags))
			this.vis.bans = band(this.vis.bans, bnot(this.cloak.bans))
			this.render.sprites[1].alpha = 255
		end

		if this.health.dead then
			SU.remove_modifiers(store, this)
			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if this.dodge and this.dodge.active then
				this.dodge.active = false
				if this.dodge.counter_attack then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					if this.dodge.hide_shadow then
						hide_shadow(true)
					end
					U.animation_start(this, this.dodge.animation, nil, store.tick_ts, 1)
					while not U.animation_finished(this) do
						coroutine.yield()
					end
					hide_shadow(false)
				end
			end
			
			if this.timed_actions then
				brk, sta = SU.y_soldier_timed_actions(store, this)
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
					hide_shadow(true)
				end
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
				if this.dodge and this.dodge.hide_shadow then
					hide_shadow(false)
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
					local a = this.ranged.attacks[1]
					local cd = a.cooldown - store.tick_ts + a.ts
					if cd <= 1.5 then
						local flip_x = this.motion and this.motion.dest.x < this.pos.x or nil
						U.animation_start(this, "idle", flip_x, store.tick_ts, true)
						goto label_43_1
					end
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
			if not next_pos or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or GR:cell_is(next_pos.x, next_pos.y, bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) then
				SU.remove_modifiers(store, this)
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

scripts.soldier_wander = {}
function scripts.soldier_wander.update(this, store, script)
	local brk, sta

	local function hide_shadow(isHidden)
		for i, sprite in ipairs(this.render.sprites) do
			if sprite.is_shadow then
				sprite.hidden = isHidden
			end
		end
	end

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	if this.render.sprites[1].name == "raise" then
		this.health_bar.hidden = true
		hide_shadow(true)
		for i, sprite in ipairs(this.render.sprites) do
			sprite._original_sort_y_offset = sprite.sort_y_offset
			sprite.sort_y_offset = sprite.sort_y_offset - 10
		end
		U.animation_start(this, "raise", nil, store.tick_ts, 1)
		while not U.animation_finished(this) and not this.health.dead do
			coroutine.yield()
		end
		if not this.health.dead then
			hide_shadow(false)
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
			hide_shadow(true)
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
						hide_shadow(true)
					end
					U.animation_start(this, this.dodge.animation, nil, store.tick_ts, 1)
					while not U.animation_finished(this) do
						coroutine.yield()
					end
					hide_shadow(false)
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
					hide_shadow(true)
				end
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
				if this.dodge and this.dodge.hide_shadow then
					hide_shadow(false)
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
			if not next_pos or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or GR:cell_is(next_pos.x, next_pos.y, bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) then
				hide_shadow(true)
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

scripts.mod_possession = {}
function scripts.mod_possession.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	if target and target.unit and this.render then
		for i = 1, #this.render.sprites do
			local s = this.render.sprites[i]
			s.ts = store.tick_ts
			if s.size_scales then
				s.scale = s.size_scales[target.unit.size]
			end
		end
	end

	this.modifier.duration = this.possession_duration[this.modifier.level]
	this.modifier.ts = store.tick_ts
	signal.emit("mod-applied", this, target)
	return true
end

function scripts.mod_possession.update(this, store, script)
	local m = this.modifier
	local duration = m.duration
	local target = store.entities[m.target_id]
	if not target then
		queue_remove(store, this)
		return
	end
	this.pos = target.pos
	U.animation_start(this, "start", nil, store.tick_ts, false)
	SU.remove_modifiers(store, target, nil, this.template_name)
	U.unblock_all(store, target)
	target.nav_path.dir = -1
	target.vis._original_flags = target.vis.flags
	target.vis.flags = bor(U.flag_clear(target.vis.flags, F_ENEMY), F_FRIEND)
	target.soldier = {}
	target.soldier.melee_slot_offset = V.v(target.enemy.melee_slot.x / 2, target.enemy.melee_slot.y)
	target.nav_rally = {}
	target.nav_rally.new = false
	target._original_enemy = target.enemy
	target.enemy = nil
	if target.melee and target.melee.attacks then
		target.melee.range = 60
		for _, a in pairs(target.melee.attacks) do
			a._original_vis_bans = a.vis_bans
			a.vis_bans = bor(U.flag_clear(a.vis_bans, F_ENEMY), F_FRIEND)
			if a.hit_times and not a.animations then
				a.animations = {
					nil,
					a.animation,
					nil
				}
				a.loops = 1
			end
		end
	end
	if target.ranged and target.ranged.attacks then
		for _, a in pairs(target.ranged.attacks) do
			a._original_vis_bans = a.vis_bans
			a.vis_bans = bor(U.flag_clear(a.vis_bans, F_ENEMY), F_FRIEND, F_NIGHTMARE)
			if a.animations and not a.shoot_times then
				a.shoot_times = {
					a.shoot_time
				}
				a.loops = 1
			end
		end
	end
	target.main_script._original_update = target.main_script.update
	target.main_script.update = scripts.soldier_from_enemy.update
	target.main_script.co = nil
	target.main_script.runs = 1

	while true do
		if U.animation_finished(this) then
			U.animation_start(this, "loop", nil, store.tick_ts, true)
		end

		target = store.entities[m.target_id]
		if not target or target.health.dead or duration < store.tick_ts - m.ts then
			U.y_animation_play(this, "end", nil, store.tick_ts, false)
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

		coroutine.yield()
	end
end

function scripts.mod_possession.remove(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if not target then
		return true
	end
	U.unblock_target(store, target)
	target.nav_path.dir = 1
	target.vis.flags = target.vis._original_flags
	target.soldier = nil
	target.enemy = target._original_enemy
	if target.melee and target.melee.attacks then
		for _, a in pairs(target.melee.attacks) do
			a.vis_bans = a._original_vis_bans
		end
	end
	if target.ranged and target.ranged.attacks then
		for _, a in pairs(target.ranged.attacks) do
			a.vis_bans = a._original_vis_bans
		end
	end
	target.main_script.update = target.main_script._original_update
	target.main_script._original_update = nil
	target.main_script.co = nil
	target.main_script.runs = 1

	return true
end

scripts.tower_spirit_mausoleum = {}
function scripts.tower_spirit_mausoleum.remove(this, store, script)
	for i, b in ipairs(this.attacks.list[1].stored_bullets) do
		queue_remove(store, b)
	end
	if this.barrack and this.barrack.soldiers then
		for i, s in ipairs(this.barrack.soldiers) do
			if s.health then
				s.health.dead = true
			end
			queue_remove(store, s)
		end
	end
	return true
end

function scripts.tower_spirit_mausoleum.update(this, store, script)
	local spritesGroup = "layers"
	local a = this.attacks
	local a1 = this.attacks.list[1]
	local a2 = this.attacks.list[2]
	local a3 = this.attacks.list[3]
	local barrack = this.barrack
	local pow_g, pow_p, pow_s
	if this.powers then
		pow_g = this.powers.gargoyles
		pow_p = this.powers.possession
		pow_s = this.powers.spectral_communion
	end
	a1.ts = store.tick_ts
	if a2 then
		a2.ts = store.tick_ts
	end
	if a3 then
		a3.ts = store.tick_ts
	end

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			if pow_s and pow_s.changed then
				pow_s.changed = nil
				a1.max_charges = pow_s.max_charges[pow_s.level]
				a3.cooldown = pow_s.cooldown[pow_s.level]
				a3.entity = pow_s.unit_type[pow_s.level]
			end
			if pow_p and pow_p.changed then
				pow_p.changed = nil
				a2.cooldown = pow_p.cooldown[pow_p.level]
			end
			if pow_g and pow_g.changed then
				pow_g.changed = nil
				local level = pow_g.level
				barrack.max_soldiers = level
				local offset, left_gargoyle, right_gargoyle
				if level == 1 then
					if not this.render.sprites[5].hidden then
						local fx = E:create_entity(pow_g.spawn_fx)
						offset = pow_g.spawn_positions[1]
						fx.pos = V.v(this.pos.x + offset.x, this.pos.y + offset.y)
						fx.render.sprites[1].ts = store.tick_ts
						queue_insert(store, fx)
						left_gargoyle = E:create_entity(barrack.soldier_type)
						left_gargoyle.soldier.tower_id = this.id
						left_gargoyle.soldier.tower_soldier_idx = 1
						left_gargoyle.nav_rally.pos, left_gargoyle.nav_rally.center = U.rally_formation_position(1,
							barrack, barrack.max_soldiers, barrack.rally_angle_offset)
						left_gargoyle.pos = V.vclone(fx.pos)
						left_gargoyle.nav_rally.new = true
						barrack.soldiers[1] = left_gargoyle
						signal.emit("tower-spawn", this, left_gargoyle)
					end
				elseif level == 2 then
					if not this.render.sprites[5].hidden then
						local fx = E:create_entity(pow_g.spawn_fx)
						offset = pow_g.spawn_positions[1]
						fx.pos = V.v(this.pos.x + offset.x, this.pos.y + offset.y)
						fx.render.sprites[1].ts = store.tick_ts
						queue_insert(store, fx)
						left_gargoyle = E:create_entity(barrack.soldier_type)
						left_gargoyle.soldier.tower_id = this.id
						left_gargoyle.soldier.tower_soldier_idx = 1
						left_gargoyle.nav_rally.pos, left_gargoyle.nav_rally.center = U.rally_formation_position(1,
							barrack, barrack.max_soldiers, barrack.rally_angle_offset)
						left_gargoyle.pos = V.vclone(fx.pos)
						left_gargoyle.nav_rally.new = true
						barrack.soldiers[1] = left_gargoyle
						signal.emit("tower-spawn", this, left_gargoyle)
					end
					if not this.render.sprites[6].hidden then
						local fx = E:create_entity(pow_g.spawn_fx)
						offset = pow_g.spawn_positions[2]
						fx.pos = V.v(this.pos.x + offset.x, this.pos.y + offset.y)
						fx.render.sprites[1].ts = store.tick_ts
						queue_insert(store, fx)
						right_gargoyle = E:create_entity(barrack.soldier_type)
						right_gargoyle.soldier.tower_id = this.id
						right_gargoyle.soldier.tower_soldier_idx = 2
						right_gargoyle.nav_rally.pos, right_gargoyle.nav_rally.center = U.rally_formation_position(2,
							barrack, barrack.max_soldiers, barrack.rally_angle_offset)
						right_gargoyle.pos = V.vclone(fx.pos)
						right_gargoyle.nav_rally.new = true
						barrack.soldiers[2] = right_gargoyle
						local gargoyle1 = barrack.soldiers[1]
						gargoyle1.nav_rally.pos, gargoyle1.nav_rally.center = U.rally_formation_position(1, barrack,
							barrack.max_soldiers, barrack.rally_angle_offset)
						signal.emit("tower-spawn", this, right_gargoyle)
					end
				end
				U.y_wait(store, pow_g.spawn_time)
				if left_gargoyle then
					queue_insert(store, left_gargoyle)
					this.render.sprites[5].hidden = true
				end
				if right_gargoyle then
					queue_insert(store, right_gargoyle)
					this.render.sprites[6].hidden = true
				end
			end

			if barrack then
				for i = 1, barrack.max_soldiers do
					local s = barrack.soldiers[i]
					if not s or s.health.dead and not store.entities[s.id] then
						local respawnPos = nil
						if s then
							respawnPos = V.vclone(s.pos)
						end
						s = E:create_entity(barrack.soldier_type)
						s.soldier.tower_id = this.id
						s.soldier.tower_soldier_idx = i
						s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, barrack, barrack
						.max_soldiers, barrack.rally_angle_offset)
						if respawnPos then
							s.pos = respawnPos
							s.nav_rally.new = true
						else
							s.pos = V.vclone(s.nav_rally.pos)
							s.nav_rally.new = false
						end
						s.render.sprites[1].name = "raise"
						queue_insert(store, s)
						barrack.soldiers[i] = s
						signal.emit("tower-spawn", this, s)
					end
				end

				if barrack.rally_new then
					barrack.rally_new = false
					signal.emit("rally-point-changed", this)
					local all_dead = true
					for i, s in ipairs(barrack.soldiers) do
						s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, barrack, barrack
						.max_soldiers, barrack.rally_angle_offset)
						s.nav_rally.new = true
						all_dead = all_dead and s.health.dead
					end
					if not all_dead and this.sound_events.change_rally_point then
						S:queue(this.sound_events.change_rally_point)
					end
				end
			end

			if pow_p and pow_p.level > 0 and this.tower.can_do_magic and store.tick_ts - a2.ts >= a2.cooldown then
				local target = U.find_strongest_enemy_in_range(store.entities, tpos(this), 0, a.range, a2.node_prediction, a2.vis_flags, a2.vis_bans, function(e)
					return e.nav_path and e.melee and e.health.hp >= a2.hp_min and not U.has_modifiers(store, e, "mod_possession") and (not a2.excluded_templates or not table.contains(a2.excluded_templates, e.template_name))
				end)
				if not target then
					SU.delay_attack(store, a2, 0.1)
				else
					local start_ts = store.tick_ts
					local targetPos = V.vclone(target.pos)
					U.animation_start_group(this, a2.animation, nil, store.tick_ts, false, spritesGroup)
					local start_offset = a2.bullet_start_offset[1]
					local fx = E:create_entity(a2.bullet[1])
					fx.pos = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
					fx.render.sprites[1].ts = store.tick_ts
					queue_insert(store, fx)
					U.y_wait(store, a2.shoot_time)
					if target.health.dead then
						local newTarget = U.find_strongest_enemy_in_range(store.entities, tpos(this), 0, a.range, a2.node_prediction, a2.vis_flags, a2.vis_bans, function(e)
							return e.nav_path and e.melee and not U.has_modifiers(store, e, "mod_possession") and (not a2.excluded_templates or not table.contains(a2.excluded_templates, e.template_name))
						end)
						if newTarget then
							targetPos = V.vclone(newTarget.pos)
						end
						target = newTarget
					end
					start_offset = a2.bullet_start_offset[2]
					local b = E:create_entity(a2.bullet[2])
					b.pos = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
					b.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
					b.bullet.to = V.v(targetPos.x, targetPos.y)
					b.bullet.level = pow_p.level
					if target then
						b.bullet.target_id = target.id
					end
					queue_insert(store, b)
					a2.ts = start_ts
				end
			end

			if pow_s and pow_s.level > 0 and this.tower.can_do_magic and store.tick_ts - a3.ts >= a3.cooldown then
				local start_ts = store.tick_ts
				U.animation_start_group(this, a3.animation, nil, store.tick_ts, false, spritesGroup)
				local entity = E:create_entity(a3.entity)
				entity.pos = V.v(this.pos.x + a3.spawn_offset.x, this.pos.y + a3.spawn_offset.y)
				entity.health.hp_max = pow_s.hp[pow_s.level]
				local enemy = U.find_random_enemy(store.entities, entity.pos, 0, a3.range, 0, 0, function(e)
					return e.nav_path
				end)
				if enemy then
					local pred_pos = P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi, enemy.nav_path.ni)
					entity.default_rally_pos = pred_pos
				elseif V.dist(entity.pos.x, entity.pos.y, this.barrack.rally_pos.x, this.barrack.rally_pos.y) < a3.range then
					entity.default_rally_pos = V.vclone(this.barrack.rally_pos)
				else
					entity.default_rally_pos = V.vclone(this.tower.default_rally_pos)
				end
				queue_insert(store, entity)
				U.y_wait(store, a3.cast_time)
				a3.ts = start_ts
			end

			if store.tick_ts - a1.ts >= a1.cooldown then
				local target, _, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, a1.node_prediction, a1.vis_flags, a1.vis_bans)
				if not target and (a1.max_charges <= 0 or #a1.stored_bullets >= a1.max_charges) then
					SU.delay_attack(store, a1, 0.1)
				else
					local start_ts = store.tick_ts
					if #a1.stored_bullets < a1.max_charges then
						S:queue(a1.sound)
						U.animation_start_group(this, a1.charge_animation, nil, store.tick_ts, false, spritesGroup)
						U.y_wait(store, a1.shoot_time)
						local start_offset = a1.bullet_start_offset
						local b = E:create_entity(a1.bullet)
						b.bullet.damage_factor = this.tower.damage_factor
						b.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
						b.pos = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
						table.insert(a1.stored_bullets, b)
						b.bullet.shot_index = 1
						b.bullet.destination_index = math.floor(#a1.stored_bullets / #b.bullet.destination_offsets) + 1
						local offset = b.bullet.destination_offsets[b.bullet.destination_index]
						b.bullet.to = V.v(b.pos.x + offset.x, b.pos.y + offset.y)
						queue_insert(store, b)
						target, _, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, a1.node_prediction, a1.vis_flags, a1.vis_bans)
					end
					if target then
						for i = #a1.stored_bullets, 1, -1 do
							local b = a1.stored_bullets[i]
							b.bullet.shot_index = 2
							b.bullet.target_id = target.id
							b.bullet.to = V.v(pred_pos.x + target.unit.hit_offset.x, pred_pos.y + target.unit.hit_offset.y)
							b.target_found = true
							table.remove(a1.stored_bullets, i)
						end
						S:queue(a1.release_sound)
						U.animation_start_group(this, a1.animation, nil, store.tick_ts, false, spritesGroup)
						U.y_wait(store, a1.shoot_time)
					end
					a1.ts = start_ts
				end
			end

			U.animation_start_group(this, "idle", nil, store.tick_ts, false, spritesGroup)
			coroutine.yield()
		end
	end
end

scripts.mod_promotion = {}
function scripts.mod_promotion.update(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if not target or not target.pos then
		queue_remove(store, this)
		return
	end
	if this.render then
		for _, s in ipairs(this.render.sprites) do
			s.ts = store.tick_ts
			if s.size_names then
				s.name = s.size_names[target.unit.size]
			end
			if s.size_scales then
				s.scale = s.size_scales[target.unit.size]
			end
		end
	end
	m.ts = store.tick_ts
	this.pos = target.pos
	if target.melee then
		target.melee.attacks[1]._original_mod = target.melee.attacks[1].mod
		target.melee.attacks[1].mod = this.mod
	end
	if target.ranged then
		local b = E:get_template(target.ranged.attacks[1].bullet).bullet
		local mods = b.mod and (type(b.mod) == "table" and b.mod or { b.mod }) or {}
		table.insert(mods, this.mod)
		b.mod = mods
	end
	while true do
		target = store.entities[m.target_id]
		if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and target.nav_path.ni > m.last_node then
			if target then
				if target.melee and target.melee.attacks[1].mod == this.mod then
					target.melee.attacks[1].mod = target.melee.attacks[1]._original_mod
				end
				if target.ranged then
					local b = E:get_template(target.ranged.attacks[1].bullet).bullet
					local mods = b.mod
					if mods and type(mods) == "table" then
						for i = #mods, 1, -1 do
							if mods[i] == this.mod then
								table.remove(mods, i)
							end
						end
						if #mods == 0 then
							mods = nil
						end
					end
				end
			end
			queue_remove(store, this)
			return
		end

		if this.render and target.unit then
			local s = this.render.sprites[1]
			local flip_sign = 1

			if target.render then
				flip_sign = target.render.sprites[1].flip_x and -1 or 1
			end

			if m.health_bar_offset and target.health_bar then
				local hb = target.health_bar.offset
				local hbo = m.health_bar_offset

				s.offset.x, s.offset.y = hb.x + hbo.x * flip_sign, hb.y + hbo.y
			elseif m.use_mod_offset and target.unit.mod_offset then
				s.offset.x, s.offset.y = target.unit.mod_offset.x * flip_sign, target.unit.mod_offset.y
			end
		end

		coroutine.yield()
	end
end

scripts.warmongers_soldier_orc_captain = {}
function scripts.warmongers_soldier_orc_captain.update(this, store, script)
	local pow_s = this.powers.seal_of_blood
	local pow_b = this.powers.battlewits
	local ta1 = this.timed_attacks and this.timed_attacks.list[1] or nil
	if ta1 then
		ta1.ts = store.tick_ts - ta1.cooldown
	end
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
	
	local function hide_shadow(isHidden)
		for i, sprite in ipairs(this.render.sprites) do
			if sprite.is_shadow then
				sprite.hidden = isHidden
			end
		end
	end
	
	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end
	
	if this.render.sprites[1].name == "raise" then
		hide_shadow(true)
		this.health_bar.hidden = true
		U.animation_start(this, "raise", nil, store.tick_ts, 1)
		while not U.animation_finished(this) and not this.health.dead do
			coroutine.yield()
		end
		if not this.health.dead then
			hide_shadow(false)
			this.health_bar.hidden = nil
		end
	end
	
	while true do
		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil
					SU.soldier_power_upgrade(this, pn)
					if p == pow_s then
						pow_s.ts = store.tick_ts
					end
				end
			end
		end
		
		if not this.health.dead or SU.y_soldier_revive(store, this) then
			-- block empty
		else
			hide_shadow(true)
			SU.y_soldier_death(store, this)
			return
		end
		
		if pow_s.level > 0 and pow_s.ts and store.tick_ts - pow_s.ts >= 1 then
			pow_s.ts = store.tick_ts
			this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + pow_s.healing_points[pow_s.level])
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
					if this.dodge.hide_shadow then
						hide_shadow(true)
					end
					U.animation_start(this, this.dodge.animation, nil, store.tick_ts, 1)
					
					while not U.animation_finished(this) do
						coroutine.yield()
					end
					hide_shadow(false)
				end
				
				signal.emit("soldier-dodge", this)
			end
			
			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_43_1
				end
			end
			
			check_tower_damage_factor()
			
			if ta1 and ta1.ts and store.tick_ts - ta1.ts >= ta1.cooldown then
				local enemies = U.find_enemies_in_range(store.entities, this.pos, 0, ta1.range, 0, 0)
				if not enemies or #enemies < ta1.min_count then
					SU.delay_attack(store, ta1, 0.1)
				else
					local start_ts = store.tick_ts
					S:queue(ta1.sound)
					U.animation_start(this, ta1.animation, nil, store.tick_ts)
					if SU.y_soldier_wait(store, this, ta1.cast_time) then
						-- block empty
					else
						local soldiers = U.find_soldiers_in_range(store.entities, this.pos, 0, ta1.range, ta1.vis_flags, ta1.vis_bans, function(e)
							return table.contains(ta1.allowed_templates, e.template_name)
						end)
						if not soldiers then
							-- block empty
						else
							for _, s in ipairs(soldiers) do
								local mod = E:create_entity(ta1.mod)
								mod.modifier.target_id = s.id
								mod.modifier.source_id = this.id
								queue_insert(store, mod)
							end
							ta1.ts = start_ts
							SU.y_soldier_animation_wait(this)
						end
					end
				end
			end

			if this.melee then
				local target = SU.soldier_pick_melee_target(store, this)
				if target then
					if pow_b.level > 0 then
						local mod = E:create_entity(pow_b.modifier_on_melee)
						mod.modifier.source_id = this.id
						mod.modifier.target_id = this.id
						mod.modifier.level = pow_b.level
						mod.inflicted_damage_factor = pow_b.damage_multiplier[pow_b.level]
						queue_insert(store, mod)
					end
					if this.dodge and this.dodge.hide_shadow and this.dodge.counter_attack_pending then
						hide_shadow(true)
					end
					brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
					if this.dodge and this.dodge.hide_shadow then
						hide_shadow(false)
					end
					if brk or sta ~= A_NO_TARGET then
						goto label_43_1
					end
				end
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_43_1
			end
			
			::label_43_0::
			
			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end
		
		::label_43_1::
		
		coroutine.yield()
	end
end

scripts.tower_warmongers_barrack = {}
function scripts.tower_warmongers_barrack.update(this, store, script)
	local tower_sid = 2
	local door_sid = 3
	local pow_p = this.powers.promotion
	local b = this.barrack

	while true do
		for pn, p in pairs(this.powers) do
			if p.changed then
				p.changed = nil
				if p == pow_p then
					local captainIndex = p.promotion_index[p.level]
					local soldier = b.soldiers[captainIndex]
					if soldier then
						local captain = E:create_entity(p.unit_type)
						captain.soldier.tower_id = this.id
						captain.soldier.tower_soldier_idx = captainIndex
						captain.nav_rally.pos, captain.nav_rally.center = U.rally_formation_position(captainIndex, b, b.max_soldiers)
						for _pn, _p in pairs(this.powers) do
							if _p ~= p then
								captain.powers[_pn].level = _p.level
								captain.powers[_pn].changed = true
							end
						end
						if soldier.health.dead then
							captain.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
							captain.nav_rally.new = true
						else
							captain.pos = V.vclone(soldier.pos)
							captain.render.sprites[1].flip_x = soldier.render.sprites[1].flip_x 
							captain.nav_rally.new = false
						end
						queue_remove(store, soldier)
						queue_insert(store, captain)
						b.soldiers[captainIndex] = captain
						signal.emit("tower-spawn", this, captain)
					end
				else
					for i, s in ipairs(b.soldiers) do
						s.powers[pn].level = p.level
						s.powers[pn].changed = true
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

					local captain = nil
					if pow_p.level > 0 then
						for j = 1, pow_p.level do
							if i == pow_p.promotion_index[j] then
								captain = E:create_entity(pow_p.unit_type)
								s = captain
								break
							end
						end
					end
					if not captain then
						s = E:create_entity(b.soldier_type)
					end
					s.soldier.tower_id = this.id
					s.soldier.tower_soldier_idx = i
					s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
					s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers)
					s.nav_rally.new = true

					for pn, p in pairs(this.powers) do
						if p ~= pow_p then
							s.powers[pn].level = p.level
							s.powers[pn].changed = true
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

scripts.tower_hammerhold_archer = {}
function scripts.tower_hammerhold_archer.update(this, store, script)
	local a = this.attacks
	local a1 = this.attacks.list[1]
	local b = this.barrack
	this.idle_ts = store.tick_ts
	a1.ts = store.tick_ts - a1.cooldown
	b._original_max_soldiers = b.max_soldiers

	local function shot_bullet(attack, enemy)
		local start_ts = store.tick_ts
		local soffset = this.render.sprites[this.shooter_sid].offset
		local an, af, an_idx = U.animation_name_facing_point(this, attack.animation, enemy.pos, this.shooter_sid, soffset)
		U.animation_start(this, an, af, store.tick_ts, false, this.shooter_sid)
		local boffset = attack.bullet_start_offset[an_idx]
		local b = E:create_entity(attack.bullet)
		b.pos.x = this.pos.x + soffset.x + boffset.x * (af and -1 or 1)
		b.pos.y = this.pos.y + soffset.y + boffset.y
		b.bullet.from = V.vclone(b.pos)
		if enemy.unit and enemy.unit.hit_offset then
			b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
		else
			b.bullet.to = V.v(enemy.pos.x, enemy.pos.y)
		end
		b.bullet.target_id = enemy.id
		b.bullet.source_id = this.id
		b.bullet.damage_factor = this.tower.damage_factor
		b.bullet.flight_time = 2 * (math.sqrt(2 * b.bullet.fixed_height * b.bullet.g * -1) / b.bullet.g * -1)
		while store.tick_ts - start_ts < attack.shoot_time do
			coroutine.yield()
		end
		if not enemy or enemy.health.dead then
			enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, attack.vis_flags, attack.vis_bans)
			if enemy then
				local _an, _af = U.animation_name_facing_point(this, attack.animation, enemy.pos, this.shooter_sid, soffset)
				if an == _an and af == _af then
					if enemy.unit and enemy.unit.hit_offset then
						b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
					else
						b.bullet.to = V.v(enemy.pos.x, enemy.pos.y)
					end
					b.bullet.target_id = enemy.id
				end
			end
		end
		queue_insert(store, b)
		U.y_animation_wait(this, this.shooter_sid)
		attack.ts = start_ts
	end

	while true do
		if not this.tower.blocked then
			for _, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil
					if pow == this.powers.formation then
						b.max_soldiers = pow.level + b._original_max_soldiers
						for i, s in ipairs(b.soldiers) do
							s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
						end
					elseif pow == this.powers.war_elephants then
						b.rally_radius = b.rally_radius * 2
						local half = (b.max_soldiers + 1) / 2
						local number = math.ceil(half)
						for i = 1, number do
							local e
							if i == 1 and number > half then
								e = E:create_entity(pow.unit_type[2])
							else
								e = E:create_entity(pow.unit_type[1])
							end
							e.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
							e.nav_rally.pos, e.nav_rally.center = U.rally_formation_position(i, b, number, math.pi / 4)
							e.nav_rally.first = true
							e.nav_rally.new = true
							e.reinforcement.squad_id = this.id
							queue_insert(store, e)
						end
						this.tower.spent = 0
						this.tower.sell = true
						return
					end
				end
			end
			SU.towers_swaped(store, this, this.attacks.list)

			for i = 1, b.max_soldiers do
				local s = b.soldiers[i]
				if not s or s.health.dead and not store.entities[s.id] then
					s = E:create_entity(b.soldier_type)
					s.soldier.tower_id = this.id
					s.soldier.tower_soldier_idx = i
					s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
					s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
					s.nav_rally.new = true
					queue_insert(store, s)
					b.soldiers[i] = s
					signal.emit("tower-spawn", this, s)
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

			if store.tick_ts - a1.ts >= a1.cooldown then
				local trigger_enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, a1.vis_flags, a1.vis_bans)
				if not trigger_enemy then
					SU.delay_attack(store, a1, 0.1)
				else
					shot_bullet(a1, trigger_enemy)
				end
			end

			if store.tick_ts - this.idle_ts >= this.tower.long_idle_cooldown then
				this.idle_ts = store.tick_ts
				local soffset = this.render.sprites[this.shooter_sid].offset
				local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, this.shooter_sid, soffset)
				U.animation_start(this, an, af, store.tick_ts, -1, this.shooter_sid)
			end
		end
		coroutine.yield()
	end
end

scripts.elephant_lancer = {}
function scripts.elephant_lancer.insert(this, store, script)
	for i, a in ipairs(this.ranged.attacks) do
		local c = E:create_entity(a.controller)
		c.pos = this.pos
		c.owner = this
		c.shot_index = i
		a.controller = c
		queue_insert(store, c)
	end
	local aura = E:create_entity(this.aura)
	aura.pos = V.vclone(this.pos)
	aura.aura.source_id = this.id
	aura.interrupt = true
	this.aura = aura
	queue_insert(store, aura)
	return true
end

function scripts.elephant_lancer.update(this, store, script)
	local a1 = this.ranged.attacks[1]
	local a2 = this.ranged.attacks[2]

	local function hide_shadow(isHidden)
		for i, sprite in ipairs(this.render.sprites) do
			if sprite.is_shadow then
				sprite.hidden = isHidden
			end
		end
	end

	local function change_flip_x(flip_x)
		for i = 3, 5 do
			local s = this.render.sprites[i]
			if not s._original_offset then
				s._original_offset = V.vclone(s.offset)
			end
			s.flip_x = flip_x
			if flip_x then
				s.offset.x = s._original_offset.x * -1
			else
				s.offset.x = s._original_offset.x
			end
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
			this.aura.interrupt = false
			r.new = false
			U.unblock_target(store, this)
			local n = this.nav_grid
			local dest = r.pos
			while not V.veq(this.pos, dest) do
				local breakout = false
				local w = table.remove(n.waypoints, 1) or dest
				local unsnap = #n.waypoints > 0
				U.set_destination(this, w)
				local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest, 1)
				if af ~= this.render.sprites[1].flip_x then
					U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, true, 1)
					while a1.is_shooting or a2.is_shooting do
						SU.delay_attack(store, a1, a1.cooldown)
						SU.delay_attack(store, a2, a2.cooldown)
						coroutine.yield()
					end
					change_flip_x(af)
				end
				U.animation_start(this, an, af, store.tick_ts, -1, 1)
				while not this.motion.arrived do
					if this.health.dead or this.unit.is_stunned then
						out = true
						breakout = true
						break
					end
					if r.new then
						out = false
						breakout = true
						break
					end
					U.walk(this, store.tick_length, nil, unsnap)
					coroutine.yield()
					this.motion.speed.x, this.motion.speed.y = 0, 0
				end
				if breakout then
					break
				end
			end
		end

		this.aura.interrupt = true
		this.vis.bans = vis_bans
		this.health.immune_to = prev_immune
		return out
	end

	local function soldier_idle(store, this, force_ts)
		U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, 1, force_ts)
		if this.unit.is_stunned then
			return
		end
		if store.tick_ts - this.idle_flip.ts > 2 * store.tick_length then
			this.idle_flip.ts_counter = 0
		end
		this.idle_flip.ts = store.tick_ts
		this.idle_flip.ts_counter = this.idle_flip.ts_counter + store.tick_length
		if this.idle_flip.ts_counter > this.idle_flip.cooldown and not a1.is_shooting and not a2.is_shooting then
			this.idle_flip.ts_counter = 0
			if math.random() < this.idle_flip.chance then
				this.render.sprites[1].flip_x = not this.render.sprites[1].flip_x
				change_flip_x(this.render.sprites[1].flip_x)
			end
			if this.idle_flip.animations then
				this.idle_flip.last_animation = table.random(this.idle_flip.animations)
			end
		end
	end

	this.render.sprites[1].ts = store.tick_ts
	if this.render.sprites[1].name == "raise" then
		hide_shadow(true)
		this.health_bar.hidden = true
		U.animation_start(this, "raise", nil, store.tick_ts, false, 1)
		while not U.animation_finished(this, 1) and not this.health.dead do
			coroutine.yield()
		end
		if not this.health.dead then
			this.tween.disabled = true
			for i = 2, 5 do
				this.render.sprites[i].hidden = nil
			end
			U.y_animation_play(this, "afterRaising", nil, store.tick_ts, false, 1)
			this.health_bar.hidden = nil
		end
	end

	while true do
		if this.health.dead then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end
			this.health.hp = 0
			this.aura = this.aura.template_name
			SU.remove_modifiers(store, this)
			for i = 2, 5 do
				this.render.sprites[i].hidden = true
			end
			U.animation_start(this, "death", nil, store.tick_ts, false, 1)
			if this.sound_events.death then
				S:queue(this.sound_events.death)
			end
			U.y_animation_wait(this, 1)
			if U.y_wait(store, this.health.dead_lifetime, function(store, time)
				return this.health.hp == this.health.hp_max
			end) then
				this.health.dead = nil
				this.health.death_ts = nil
				this.health.delete_after = nil
				local aura = E:create_entity(this.aura)
				aura.pos = V.vclone(this.pos)
				aura.aura.source_id = this.id
				aura.interrupt = true
				this.aura = aura
				queue_insert(store, aura)
				this.health_bar.hidden = true
				this.tween.disabled = nil
				this.tween.ts = store.tick_ts
				U.animation_start(this, "raise", nil, store.tick_ts, false, 1)
				while not U.animation_finished(this, 1) do
					coroutine.yield()
				end
				this.tween.disabled = true
				for i = 2, 5 do
					this.render.sprites[i].ts = store.tick_ts
					this.render.sprites[i].hidden = nil
				end
				U.y_animation_play(this, "afterRaising", nil, store.tick_ts, false, 1)
				this.health_bar.hidden = nil
			else
				this.tween.reverse = true
				this.tween.remove = true
				this.tween.disabled = nil
				this.tween.ts = store.tick_ts
				return
			end
		end

		if this.unit.is_stunned then
			soldier_idle(store, this)
		else
			SU.soldier_courage_upgrade(store, this)

			while this.nav_rally.new do
				if not this.nav_rally.first and this.sound_events.change_rally_point and (#S.request_queue == 0 or 
				this.sound_events.change_rally_point ~= S.request_queue[#S.request_queue].id) then
					S:queue(this.sound_events.change_rally_point)
				end
				this.nav_rally.first = nil
				if y_soldier_new_rally(store, this) then
					goto label_43_1
				end
			end

			soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_43_1::

		coroutine.yield()
	end
end

function scripts.elephant_lancer.remove(this, store, script)
	for i, a in ipairs(this.ranged.attacks) do
		queue_remove(store, a.controller)
	end
	return true
end

scripts.controller_war_elephant_archer = {}
function scripts.controller_war_elephant_archer.update(this, store, script)
	local sid = this.owner.shooter_sid[this.shot_index]
	local a = this.owner.ranged.attacks[this.shot_index]
	a.ts = store.tick_ts

	local function soldier_idle(store, this, force_ts)
		U.animation_start(this.owner, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, sid, force_ts)
		if this.owner.unit.is_stunned then
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
				this.owner.render.sprites[sid].flip_x = not this.owner.render.sprites[sid].flip_x
			end
			if this.idle_flip.animations then
				this.idle_flip.last_animation = table.random(this.idle_flip.animations)
			end
		end
	end

	local function getPos(this)
		local offset = this.owner.render.sprites[sid].offset
		local pos = V.v(offset.x + this.pos.x, offset.y + this.pos.y)
		return pos
	end

	while true do
		if not this.owner.health.dead then
			if not this.owner.unit.is_stunned then
				if store.tick_ts - a.ts >= a.cooldown then
					local enemy = U.find_foremost_enemy(store.entities, getPos(this), a.min_range, a.max_range, false, a.vis_flags, a.vis_bans)
					if enemy then
						local start_ts = store.tick_ts
						a.ts = start_ts
						a.is_shooting = true
						local soffset = this.owner.render.sprites[sid].offset
						local an, af = U.animation_name_facing_point(this.owner, a.animation, enemy.pos, sid, soffset)
						U.animation_start(this.owner, an, af, store.tick_ts, false, sid)
						local boffset = a.bullet_start_offset[1]
						local b = E:create_entity(a.bullet)
						b.pos.x = this.pos.x + soffset.x + boffset.x * (af and -1 or 1)
						b.pos.y = this.pos.y + soffset.y + boffset.y
						b.bullet.from = V.vclone(b.pos)
						if enemy.unit and enemy.unit.hit_offset then
							b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
						else
							b.bullet.to = V.v(enemy.pos.x, enemy.pos.y)
						end
						b.bullet.target_id = enemy.id
						b.bullet.source_id = this.id
						if b.bullet.use_unit_damage_factor then
							b.bullet.damage_factor = this.owner.unit.damage_factor
						end
						while store.tick_ts - start_ts < a.shoot_time do
							coroutine.yield()
						end
						if not enemy or enemy.health.dead then
							enemy = U.find_foremost_enemy(store.entities, getPos(this), a.min_range, a.max_range, false, a.vis_flags, a.vis_bans)
							if enemy then
								local _an, _af = U.animation_name_facing_point(this.owner, a.animation, enemy.pos, sid, soffset)
								if an == _an and af == _af then
									if enemy.unit and enemy.unit.hit_offset then
										b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
									else
										b.bullet.to = V.v(enemy.pos.x, enemy.pos.y)
									end
									b.bullet.target_id = enemy.id
								end
							end
						end
						queue_insert(store, b)
						U.y_animation_wait(this.owner, sid)
						a.is_shooting = false
					end
				end
	
				soldier_idle(store, this)
			else
				soldier_idle(store, this)
			end
		end
		coroutine.yield()
	end
end

scripts.war_elephant = {}
function scripts.war_elephant.get_info(this)
	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = nil,
		damage_max = nil,
		damage_icon = nil,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor
	}
end

function scripts.war_elephant.insert(this, store, script)
	local a = this.timed_attacks.list[1]
	local c = E:create_entity(a.controller)
	c.pos = this.pos
	c.owner = this
	a.controller = c
	queue_insert(store, c)
	local aura = E:create_entity(this.aura)
	aura.pos = V.vclone(this.pos)
	aura.aura.source_id = this.id
	aura.interrupt = true
	this.aura = aura
	queue_insert(store, aura)
	return true
end

function scripts.war_elephant.update(this, store, script)
	local a = this.timed_attacks.list[1]

	local function hide_shadow(isHidden)
		for i, sprite in ipairs(this.render.sprites) do
			if sprite.is_shadow then
				sprite.hidden = isHidden
			end
		end
	end

	local function change_flip_x(flip_x)
		local s = this.render.sprites[3]
		if not s._original_offset then
			s._original_offset = V.vclone(s.offset)
		end
		s.flip_x = flip_x
		if flip_x then
			s.offset.x = s._original_offset.x * -1
		else
			s.offset.x = s._original_offset.x
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
			this.aura.interrupt = false
			r.new = false
			U.unblock_target(store, this)
			local n = this.nav_grid
			local dest = r.pos
			while not V.veq(this.pos, dest) do
				local breakout = false
				local w = table.remove(n.waypoints, 1) or dest
				local unsnap = #n.waypoints > 0
				U.set_destination(this, w)
				local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest, 1)
				if af ~= this.render.sprites[1].flip_x then
					change_flip_x(af)
				end
				U.animation_start(this, an, af, store.tick_ts, -1, 1)
				while not this.motion.arrived do
					if this.health.dead or this.unit.is_stunned then
						out = true
						breakout = true
						break
					end
					if r.new then
						out = false
						breakout = true
						break
					end
					U.walk(this, store.tick_length, nil, unsnap)
					coroutine.yield()
					this.motion.speed.x, this.motion.speed.y = 0, 0
				end
				if breakout then
					break
				end
			end
		end

		this.aura.interrupt = true
		this.vis.bans = vis_bans
		this.health.immune_to = prev_immune
		return out
	end

	local function soldier_idle(store, this, force_ts)
		U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, 1, force_ts)
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
				change_flip_x(this.render.sprites[1].flip_x)
			end
			if this.idle_flip.animations then
				this.idle_flip.last_animation = table.random(this.idle_flip.animations)
			end
		end
	end

	this.render.sprites[1].ts = store.tick_ts
	if this.render.sprites[1].name == "raise" then
		hide_shadow(true)
		this.health_bar.hidden = true
		U.animation_start(this, "raise", nil, store.tick_ts, false, 1)
		while not U.animation_finished(this, 1) and not this.health.dead do
			coroutine.yield()
		end
		if not this.health.dead then
			this.tween.disabled = true
			for i = 2, 3 do
				this.render.sprites[i].hidden = nil
			end
			U.y_animation_play(this, "afterRaising", nil, store.tick_ts, false, 1)
			this.health_bar.hidden = nil
		end
	end

	while true do
		if this.health.dead then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end
			this.health.hp = 0
			this.aura = this.aura.template_name
			SU.remove_modifiers(store, this)
			for i = 2, 3 do
				this.render.sprites[i].hidden = true
			end
			U.animation_start(this, "death", nil, store.tick_ts, false, 1)
			S:stop(a.sound)
			if this.sound_events.death then
				S:queue(this.sound_events.death)
			end
			U.y_animation_wait(this, 1)
			if U.y_wait(store, this.health.dead_lifetime, function(store, time)
				return this.health.hp == this.health.hp_max
			end) then
				this.health.dead = nil
				this.health.death_ts = nil
				this.health.delete_after = nil
				local aura = E:create_entity(this.aura)
				aura.pos = V.vclone(this.pos)
				aura.aura.source_id = this.id
				aura.interrupt = true
				this.aura = aura
				queue_insert(store, aura)
				this.health_bar.hidden = true
				this.tween.disabled = nil
				this.tween.ts = store.tick_ts
				U.animation_start(this, "raise", nil, store.tick_ts, false, 1)
				while not U.animation_finished(this, 1) do
					coroutine.yield()
				end
				this.tween.disabled = true
				for i = 2, 3 do
					this.render.sprites[i].ts = store.tick_ts
					this.render.sprites[i].hidden = nil
				end
				U.y_animation_play(this, "afterRaising", nil, store.tick_ts, false, 1)
				this.health_bar.hidden = nil
			else
				this.tween.reverse = true
				this.tween.remove = true
				this.tween.disabled = nil
				this.tween.ts = store.tick_ts
				return
			end
		end

		if this.unit.is_stunned then
			soldier_idle(store, this)
		else
			SU.soldier_courage_upgrade(store, this)

			while this.nav_rally.new do
				if not this.nav_rally.first and this.sound_events.change_rally_point and (#S.request_queue == 0 or 
				this.sound_events.change_rally_point ~= S.request_queue[#S.request_queue].id) then
					S:queue(this.sound_events.change_rally_point)
				end
				this.nav_rally.first = nil
				if y_soldier_new_rally(store, this) then
					goto label_43_1
				end
			end

			soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_43_1::

		coroutine.yield()
	end
end

function scripts.war_elephant.remove(this, store, script)
	local a = this.timed_attacks.list[1]
	queue_remove(store, a.controller)
	return true
end

scripts.controller_war_elephant_drummer = {}
function scripts.controller_war_elephant_drummer.update(this, store, script)
	local sid = this.owner.drummer_sid
	local a = this.owner.timed_attacks.list[1]
	a.ts = store.tick_ts

	local function idle(store, this)
		U.animation_start(this.owner, "idle", nil, store.tick_ts, true, sid)
	end

	while true do
		if not this.owner.health.dead then
			if not this.owner.unit.is_stunned and store.tick_ts - a.ts >= a.cooldown then
				local soldiers = U.find_soldiers_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)
				if soldiers then
					local start_ts = store.tick_ts
					a.ts = start_ts
					S:queue(a.sound)
					U.animation_start(this.owner, a.animation_start, nil, store.tick_ts, nil, sid)
					local interrupted = nil
					while store.tick_ts - start_ts < a.cast_time do
						if SU.soldier_interrupted(this.owner) then
							interrupted = true
							break
						end
						coroutine.yield()
					end
					if not interrupted then
						soldiers = U.find_soldiers_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans, function(e)
							for i, name in ipairs(a.elephant_templates) do
								if e.template_name == name and not e.render.sprites[1].hidden then
									return true
								end
							end
							return false
						end)
						local max_targets = a.max_targets
						if soldiers then
							soldiers = table.slice(soldiers, 1, max_targets)
							for _, s in ipairs(soldiers) do
								for _, mod_name in ipairs(a.mods_on_elephant) do
									local mod = E:create_entity(mod_name)
									mod.modifier.source_id = this.id
									mod.modifier.target_id = s.id
									queue_insert(store, mod)
								end
							end
							max_targets = max_targets - #soldiers
						end
						if max_targets > 0 then
							soldiers = U.find_soldiers_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans, function(e)
								for i, name in ipairs(a.elephant_templates) do
									if e.template_name ~= name and not e.render.sprites[1].hidden then
										return true
									end
								end
								return false
							end)
							if soldiers then
								soldiers = table.slice(soldiers, 1, max_targets)
								for _, s in ipairs(soldiers) do
									for _, mod_name in ipairs(a.mods) do
										local mod = E:create_entity(mod_name)
										mod.modifier.source_id = this.id
										mod.modifier.target_id = s.id
										queue_insert(store, mod)
									end
								end
							end
						end
					end
					while not interrupted and not U.animation_finished(this.owner, sid) do
						if SU.soldier_interrupted(this.owner) then
							interrupted = true
							break
						end
						coroutine.yield()
					end
					for i = 1, a.loop_times do
						if not interrupted then
							U.animation_start(this.owner, a.animation_loop, nil, store.tick_ts, nil, sid)
							while not U.animation_finished(this.owner, sid) do
								if SU.soldier_interrupted(this.owner) then
									interrupted = true
									break
								end
								coroutine.yield()
							end
						end
					end
					if not interrupted then
						U.animation_start(this.owner, a.animation_end, nil, store.tick_ts, nil, sid)
						while not U.animation_finished(this.owner, sid) do
							if SU.soldier_interrupted(this.owner) then
								interrupted = true
								break
							end
							coroutine.yield()
						end
					end
					S:stop(a.sound)
				end
			end
			idle(store, this)
		end
		coroutine.yield()
	end
end

scripts.tower_random = {}
function scripts.tower_random.get_info(this)
	return {
		type = STATS_TYPE_TOWER,
		damage_min = nil,
		damage_max = nil,
		damage_type = DAMAGE_PHYSICAL,
		range = nil,
		cooldown = nil
	}
end

function scripts.tower_random.insert(this, store, script)
	local random = math.random()
	local mobile_towers = {
		"tower_mage_1",
		"tower_mage_2",
		"tower_mage_3",
		"tower_wild_magus",
		"tower_bastion"
	}
	for i, name in ipairs(this.allowed_templates) do
		if random <= i / #this.allowed_templates then
			local t = E:create_entity(name)
			t.pos = V.vclone(this.pos)
			t.tower.flip_x = this.tower.flip_x
			if table.contains(mobile_towers, name) then
				local th = E:create_entity("tower_holder")
				th.pos = V.vclone(this.pos)
				th.tower.holder_id = this.tower.holder_id
				th.tower.flip_x = this.tower.flip_x
				if this.tower.default_rally_pos then
					th.tower.default_rally_pos = this.tower.default_rally_pos
				end
				if this.tower.terrain_style then
					th.tower.terrain_style = this.tower.terrain_style
					th.render.sprites[1].name = string.format(th.render.sprites[1].name, this.tower.terrain_style)
					th.render.sprites[2].name = string.format(th.render.sprites[2].name, this.tower.terrain_style)
				end
				if th.ui and this.ui then
					th.ui.nav_mesh_id = this.ui.nav_mesh_id
				end
				queue_insert(store, th)
			else
				t.tower.holder_id = this.tower.holder_id
				if this.tower.default_rally_pos then
					t.tower.default_rally_pos = this.tower.default_rally_pos
				end
				if this.tower.terrain_style then
					t.tower.terrain_style = this.tower.terrain_style
					t.render.sprites[1].name = string.format(t.render.sprites[1].name, this.tower.terrain_style)
					t.render.sprites[2].name = string.format(t.render.sprites[2].name, this.tower.terrain_style)
				end
				if t.ui and this.ui then
					t.ui.nav_mesh_id = this.ui.nav_mesh_id
				end
			end
			queue_insert(store, t)
			break
		end
	end
	
	return false
end

scripts.tower_barrack_amazonas = {}
function scripts.tower_barrack_amazonas.update(this, store, script)
	local b = this.barrack
	local door_sid = this.render.door_sid or 2
	if this.tower_upgrade_persistent_data.max_soldiers then
		b.max_soldiers = this.tower_upgrade_persistent_data.max_soldiers
	end
	local pow_plant = this.powers.carnivorous_plant
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

	while true do
		if pow_plant.changed then
			pow_plant.changed = nil
			for i = 1, pow_plant.level do
				if not plants[i] then
					local plant = E:create_entity(pow_plant.template)
					plant.pos = V.vclone(pow_plant.pos[i])
					plant.owner = this
					plants[i] = plant
					queue_insert(store, plant)
				end
			end
		end

		local old_count = #b.soldiers
		b.soldiers = table.filter(b.soldiers, function(_, s)
			return store.entities[s.id] ~= nil
		end)

		if #b.soldiers > 0 and #b.soldiers ~= old_count then
			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
			end
		end

		if b.unit_bought then
			b.max_soldiers = b.max_soldiers + 1
			this.tower_upgrade_persistent_data.max_soldiers = b.max_soldiers

			for i, ss in ipairs(b.soldiers) do
				ss.nav_rally.pos, ss.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
			end

			b.unit_bought = nil

			local price = E:get_template(b.soldier_type).unit.price[this.barrack.max_soldiers]

			store.player_gold = store.player_gold - price
		end

		if b.rally_new then
			b.rally_new = false

			signal.emit("rally-point-changed", this)

			local sounds = {}
			local all_dead = true

			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
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

		if not this.tower.blocked then
			for i = 1, this.barrack.max_soldiers do
				local s = b.soldiers[i]

				if not s or s.health.dead and not store.entities[s.id] then
					if b.has_door and not b.door_open then
						U.animation_start(this, "open", nil, store.tick_ts, false, door_sid)
						U.y_animation_wait(this, door_sid)

						b.door_open = true
						b.door_open_ts = store.tick_ts
					end

					S:queue(this.spawn_sound)

					s = E:create_entity(b.soldier_type)
					s.soldier.tower_id = this.id
					s.soldier.tower_soldier_idx = i
					s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
					s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
					s.nav_rally.new = true
					s.render.sprites[1].flip_x = true

					s.spawned_from_tower = true

					queue_insert(store, s)

					b.soldiers[i] = s
				end
			end
		end

		if b.has_door and b.door_open and store.tick_ts - b.door_open_ts > b.door_hold_time then
			U.animation_start(this, "close", nil, store.tick_ts, false, door_sid)
			U.y_animation_wait(this, door_sid)

			b.door_open = false
		end

		coroutine.yield()
	end
end

scripts.amazon_carnivorous_plant = {}
function scripts.amazon_carnivorous_plant.insert(this, store, script)
	for i, pos in ipairs(this.attack_pos) do
		this.attack_pos[i].x = pos.x + this.pos.x
		this.attack_pos[i].y = pos.y + this.pos.y
	end
	return true
end

function scripts.amazon_carnivorous_plant.update(this, store, script)
	local a = this.area_attack
	local isIdle = false
	U.animation_start(this, "inactive", nil, store.tick_ts, true)
	local attack_ts = store.tick_ts- a.cooldown

	while true do
		if not this.owner or not store.entities[this.owner.id] then
			queue_remove(store, this)
			return
		end
		while store.tick_ts - attack_ts < a.cooldown do
			if not this.owner or not store.entities[this.owner.id] then
				queue_remove(store, this)
				return
			end
			coroutine.yield()
		end
		if not isIdle then
			U.y_animation_play(this, "activate", nil, store.tick_ts)
			isIdle = true
			U.animation_start(this, "idle", nil, store.tick_ts, true)
		end

		local attackPos = nil
		for _, e in pairs(store.entities) do
			for i, pos in ipairs(this.attack_pos) do
				if (e.enemy) and e.health and not e.health.dead and band(e.vis.bans, a.vis_flags) == 0 and band(e.vis.flags, a.vis_bans) == 0 and U.is_inside_ellipse(e.pos, pos, a.damage_radius) then
					attackPos = V.vclone(pos)
					break
				end
			end
			if attackPos then
				break
			end
		end

		if not attackPos then
			attack_ts = store.tick_ts - a.cooldown + 0.2
		else
			local start_ts = store.tick_ts

			local attack_animation = attackPos.y > this.pos.y and "attack_up" or "attack_down"
			local flipX = attackPos.x < this.pos.x

			U.animation_start(this, attack_animation, flipX, store.tick_ts)
			U.y_wait(store, a.hit_time)
			S:queue("SpecialCarnivorePlant")

			local e = E:create_entity("pop_slurp")
			local x_off = this.render.sprites[1].flip_x and -40 or 40
			local y_off = attackPos.y > this.pos.y and 40 or -50

			e.pos = V.v(this.pos.x + x_off, this.pos.y + e.pop_y_offset + y_off)
			e.render.sprites[1].r = math.random(-21, 21) * math.pi / 180
			e.render.sprites[1].ts = store.tick_ts

			queue_insert(store, e)

			local targets = table.filter(store.entities, function(_, e)
				return (e.enemy or e.soldier) and e.health and not e.health.dead and e.vis and band(e.vis.bans, a.vis_flags) == 0 and band(e.vis.flags, a.vis_bans) == 0 and U.is_inside_ellipse(e.pos, attackPos, a.damage_radius)
			end)

			if #targets > 0 then
				attack_ts = start_ts
				for _, target in pairs(targets) do
					local d = E:create_entity("damage")

					d.damage_type = a.damage_type
					d.source_id = this.id
					d.target_id = target.id

					queue_damage(store, d)
				end
			end

			U.y_animation_wait(this)
			if #targets > 0 then
				U.y_animation_play(this, "toBeInactive", nil, store.tick_ts)
				isIdle = false
				U.animation_start(this, "inactive", nil, store.tick_ts, true)
			else
				isIdle = true
				U.animation_start(this, "idle", nil, store.tick_ts, true)
			end
		end
	end
end

scripts.tower_ewok = {}
function scripts.tower_ewok.update(this, store, script)
	local b = this.barrack
	local door_sid = this.render.door_sid or 2
	if this.tower_upgrade_persistent_data.max_soldiers then
		b.max_soldiers = this.tower_upgrade_persistent_data.max_soldiers
	end
	local pow_plant = this.powers.plant_magic_blossom
	local plants = pow_plant.plants
	for i, pos in ipairs(pow_plant.pos) do
		pos.x = pos.x + this.pos.x
		pos.y = pos.y + this.pos.y
	end

	while true do
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

		local old_count = #b.soldiers
		b.soldiers = table.filter(b.soldiers, function(_, s)
			return store.entities[s.id] ~= nil
		end)

		if #b.soldiers > 0 and #b.soldiers ~= old_count then
			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
			end
		end

		if b.unit_bought then
			b.max_soldiers = b.max_soldiers + 1
			this.tower_upgrade_persistent_data.max_soldiers = b.max_soldiers

			for i, ss in ipairs(b.soldiers) do
				ss.nav_rally.pos, ss.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
			end

			b.unit_bought = nil

			local price = E:get_template(b.soldier_type).unit.price[this.barrack.max_soldiers]

			store.player_gold = store.player_gold - price
		end

		if b.rally_new then
			b.rally_new = false

			signal.emit("rally-point-changed", this)

			local sounds = {}
			local all_dead = true

			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
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

		if not this.tower.blocked then
			for i = 1, this.barrack.max_soldiers do
				local s = b.soldiers[i]

				if not s or s.health.dead and not store.entities[s.id] then
					if b.has_door and not b.door_open then
						U.animation_start(this, "open", nil, store.tick_ts, false, door_sid)
						U.y_animation_wait(this, door_sid)

						b.door_open = true
						b.door_open_ts = store.tick_ts
					end

					S:queue(this.spawn_sound)

					s = E:create_entity(b.soldier_type)
					s.soldier.tower_id = this.id
					s.soldier.tower_soldier_idx = i
					s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
					s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
					s.nav_rally.new = true
					s.render.sprites[1].flip_x = true

					s.spawned_from_tower = true

					queue_insert(store, s)

					b.soldiers[i] = s
				end
			end
		end

		if b.has_door and b.door_open and store.tick_ts - b.door_open_ts > b.door_hold_time then
			U.animation_start(this, "close", nil, store.tick_ts, false, door_sid)
			U.y_animation_wait(this, door_sid)

			b.door_open = false
		end

		coroutine.yield()
	end
end

function scripts.tower_ewok.remove(this, store, script)
	local pow_plant = this.powers.plant_magic_blossom
	local plants = pow_plant.plants
	for i, p in ipairs(plants) do
		p.is_removed = true
	end
	return scripts.tower_barrack.remove(this, store, script)
end

scripts.tower_ignis_altar = {}
function scripts.tower_ignis_altar.get_info(this)
	local mod = E:get_template("mod_ignis_altar_damage")
	local o = scripts.tower_common.get_info(this)
	local damage = math.ceil(mod.damages[this.tower.level] * this.tower.damage_factor)
	o.damage_min = damage
	o.damage_max = damage
	return o
end

function scripts.tower_ignis_altar.update(this, store, script)
	if this.shooter then
		this.shooter = E:create_entity(this.shooter)
		this.shooter.pos = V.vclone(this.pos)
		this.shooter.owner = this
		queue_insert(store, this.shooter)
	end

	local tower_sid = 2
	local barrack = this.barrack
	local range = this.attacks.range
	local pow_elemental = this.powers and this.powers.burning_elemental or nil
	local pow_extinction = this.powers and this.powers.single_extinction or nil
	local pow_fire = this.powers and this.powers.true_fire or nil
	local a1 = this.attacks.list[1]
	a1.ts = store.tick_ts

	U.y_animation_play(this, a1.charge_animation, nil, store.tick_ts, nil, tower_sid)
	U.animation_start(this, "idle", nil, store.tick_ts, true, tower_sid)

	while true do
		if not this.tower.blocked then
			if pow_elemental and pow_elemental.changed then
				pow_elemental.changed = nil
				local level = pow_elemental.level
				barrack.max_soldiers = level
				local soldier = E:create_entity(barrack.soldier_type)
				soldier.soldier.tower_id = this.id
				soldier.soldier.tower_soldier_idx = level
				soldier.nav_rally.pos, soldier.nav_rally.center = U.rally_formation_position(1, barrack, barrack.max_soldiers, barrack.rally_angle_offset)
				soldier.pos = V.vclone(soldier.nav_rally.pos)
				soldier.nav_rally.new = false
				soldier.render.sprites[1].name = soldier.raise_animation
				if pow_extinction.level > 0 then
					soldier.melee.attacks[1].mod = soldier.melee.attacks[1].mod_prefix .. tostring(pow_extinction.level)
				end
				S:queue(pow_elemental.sound, pow_elemental.sound_args)
				queue_insert(store, soldier)
				barrack.soldiers[level] = soldier
				signal.emit("tower-spawn", this, soldier)
			end
			if pow_extinction and pow_extinction.changed then
				pow_extinction.changed = nil
				local attack = this.shooter.attacks.list[1]
				attack.ts = store.tick_ts
				attack.disabled = nil
				attack.spell = attack.spell_prefix .. tostring(pow_extinction.level)
				attack.cooldown = pow_extinction.cooldown[pow_extinction.level]
				for i = 1, barrack.max_soldiers do
					local soldier = barrack.soldiers[i]
					if soldier then
						soldier.melee.attacks[1].mod = soldier.melee.attacks[1].mod_prefix .. tostring(pow_extinction.level)
					end
				end
			end
			if pow_fire and pow_fire.changed then
				pow_fire.changed = nil
			end

			if barrack then
				for i = 1, barrack.max_soldiers do
					local s = barrack.soldiers[i]
					if not s or s.health.dead and store.tick_ts - s.health.death_ts + 1 * store.tick_length >= s.health.dead_lifetime then
						local respawnPos = nil
						local old = s
						if s then
							respawnPos = V.vclone(s.pos)
						end
						s = E:create_entity(barrack.soldier_type)
						for i, sprite in ipairs(s.render.sprites) do
							sprite.flip_x = old and old.render.sprites[i].flip_x or nil
						end
						s.soldier.tower_id = this.id
						s.soldier.tower_soldier_idx = i
						s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, barrack, barrack.max_soldiers, barrack.rally_angle_offset)
						if respawnPos then
							s.pos = respawnPos
							s.nav_rally.new = true
						else
							s.pos = V.vclone(s.nav_rally.pos)
							s.nav_rally.new = false
						end
						s.render.sprites[1].name = s.respawn_animation
						if pow_extinction.level > 0 then
							s.melee.attacks[1].mod = s.melee.attacks[1].mod_prefix .. tostring(pow_extinction.level)
						end
						queue_insert(store, s)
						barrack.soldiers[i] = s
						signal.emit("tower-spawn", this, s)
					end
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
					if not all_dead and this.sound_events.change_rally_point then
						S:queue(this.sound_events.change_rally_point)
					end
				end
			end

			if store.tick_ts - a1.ts >= a1.cooldown then
				local oldTargetPos = U.find_enemy_crowd_position(store.entities, tpos(this), 0, range, a1.vis_flags, a1.vis_bans, nil, 50, 1, nil, U.position_type.node_floor_center, true)
				if not oldTargetPos then
					SU.delay_attack(store, a1, 0.1)
				else
					local start_ts = store.tick_ts
					U.animation_start(this, a1.animation, nil, store.tick_ts, nil, tower_sid)
					S:queue(a1.sound, a1.sound_args)
					U.y_wait(store, a1.shoot_time)
					local newTargetPos
					local crowd_data = U.find_enemy_crowd(store.entities, tpos(this), 0, range, a1.vis_flags, a1.vis_bans, nil, 50, 1)
					if not crowd_data then
						newTargetPos = oldTargetPos
					else
						local p = crowd_data.center_unit.nav_path
						local offset = U.get_prediction_offset(crowd_data.center_unit, a1.node_prediction)
						newTargetPos = P:node_pos(p.pi, 1, p.ni + offset.node)
					end
					local bullet = E:create_entity(a1.bullet)
					local offset_x, offset_y = a1.bullet_start_offset.x, a1.bullet_start_offset.y
					bullet.pos = V.v(this.pos.x + offset_x, this.pos.y + offset_y)
					bullet.bullet.from = V.vclone(bullet.pos)
					bullet.bullet.to = newTargetPos
					bullet.bullet.source_id = this.id
					bullet.bullet.damage_factor = this.tower.damage_factor
					bullet.bullet.level = this.tower.level + (pow_fire and pow_fire.level or 0)
					queue_insert(store, bullet)
					a1.ts = start_ts
					while not U.animation_finished(this, tower_sid) do
						coroutine.yield()
					end
					U.y_animation_play(this, a1.charge_animation, nil, store.tick_ts, nil, tower_sid)
					U.animation_start(this, "idle", nil, store.tick_ts, true, tower_sid)
				end

			end
		end
		coroutine.yield()
	end
end

function scripts.tower_ignis_altar.remove(this, store, script)
	if this.shooter then
		queue_remove(store, this.shooter)
	end
	if this.barrack and this.barrack.soldiers then
		for i, s in ipairs(this.barrack.soldiers) do
			if s.health then
				s.health.dead = true
			end
			queue_remove(store, s)
		end
	end
	return true
end

scripts.ignis_altar_lvl4_subunit = {}
function scripts.ignis_altar_lvl4_subunit.update(this, store, script)
	local a1 = this.attacks.list[1]
	U.animation_start(this, "idleDown", nil, store.tick_ts, true, 1)

	while true do
		if this.owner and not this.owner.tower.blocked and this.owner.tower.can_do_magic and not a1.disabled and store.tick_ts - a1.ts >= a1.cooldown then
			local mod_list = {
				"mod_ignis_altar_single_extinction_1",
				"mod_ignis_altar_single_extinction_2",
				"mod_ignis_altar_single_extinction_3",
				"mod_ignis_altar_burning_elemental_1",
				"mod_ignis_altar_burning_elemental_2",
				"mod_ignis_altar_burning_elemental_3"
			}
			local enemy = U.find_strongest_enemy_in_range(store.entities, tpos(this.owner), 0, a1.range, nil, a1.vis_flags, a1.vis_bans, function(e)
				return not U.has_modifier_in_list(store, e, mod_list) and (not a1.excluded_templates or not table.contains(a1.excluded_templates, e.template_name))
			end)
			local start_ts
			if enemy then
				start_ts = store.tick_ts
				U.animation_start(this, a1.animation, nil, store.tick_ts, nil, 1)
				S:queue(a1.sound, a1.sound_args)
				U.y_wait(store, a1.cast_time)
				enemy = store.entities[enemy.id]
				if not enemy or enemy.health.dead then
					enemy = U.find_strongest_enemy_in_range(store.entities, tpos(this.owner), 0, a1.range, nil, a1.vis_flags, a1.vis_bans, function(e)
						return not U.has_modifier_in_list(store, e, mod_list) and (not a1.excluded_templates or not table.contains(a1.excluded_templates, e.template_name))
					end)
				end
			end
			if enemy then
				local mod = E:create_entity(a1.spell)
				mod.modifier.target_id = enemy.id
				mod.modifier.source_id = this.id
				queue_insert(store, mod)
				a1.ts = start_ts
			else
				SU.delay_attack(store, a1, 0.1)
			end
			if start_ts then
				while not U.animation_finished(this, 1) do
					coroutine.yield()
				end
				U.animation_start(this, "idleDown", nil, store.tick_ts, true, 1)
			end
		end
		coroutine.yield()
	end
end

scripts.mod_ignis_altar_single_extinction = {}
function scripts.mod_ignis_altar_single_extinction.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]
	if target and target.health and target.unit then
		if this.received_damage_factor then
			target.health.damage_factor = target.health.damage_factor / this.received_damage_factor
		end
		if this.explosion_damage and target.health.dead then
			target.unit.hide_during_death = true
			S:queue(this.explosion_sound)
			if band(target.health.last_damage_types, bor(DAMAGE_EXPLOSION, DAMAGE_INSTAKILL, DAMAGE_FX_EXPLODE, DAMAGE_DISINTEGRATE, DAMAGE_EAT)) == 0 and target.unit.can_explode and target.unit.explode_fx then
				fx = E:create_entity(target.unit.explode_fx)
				fx.pos = V.vclone(target.pos)
				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
				queue_insert(store, fx)
			end
			local fx = E:create_entity(this.explosion_fx)
			fx.pos = V.vclone(target.pos)
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].offset = V.v(0, 0)
			queue_insert(store, fx)
			local enemies = U.find_enemies_in_range(store.entities, target.pos, 0, this.explosion_range, this.explosion_vis_flags, this.explosion_vis_bans)
			if enemies then
				for i, e in ipairs(enemies) do
					local d = E:create_entity("damage")
					d.source_id = this.id
					d.target_id = e.id
					d.value = this.explosion_damage
					d.damage_type = this.explosion_damage_type
					queue_damage(store, d)
				end
			end
		end
	end
	return true
end

scripts.aura_bullet_ignis_altar = {}
function scripts.aura_bullet_ignis_altar.update(this, store, script)
	local source = store.entities[this.source_id]
	local damage_factor = source and source.tower.damage_factor or 1
	this.aura.cycle_time = this.cycle_times[math.min(#this.cycle_times, this.aura.level)]
	if this.aura.level == 5 then
		this.aura.mods = this.mods_upgraded
		this.render.sprites[1].prefix = this.render.sprites[1].prefix_upgraded
	end
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	last_hit_ts = store.tick_ts - this.aura.cycle_time
	local isLoop = nil
	U.animation_start(this, "start", nil, store.tick_ts, nil, 1)

	if this.aura.apply_delay then
		last_hit_ts = last_hit_ts + this.aura.apply_delay
	end

	while true do
		if not isLoop and U.animation_finished(this, 1) then
			U.animation_start(this, "run", nil, store.tick_ts, true, 1)
			isLoop = true
		end

		if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration then
			break
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

				local mods = this.aura.mods or {
					this.aura.mod
				}

				for _, mod_name in pairs(mods) do
					local new_mod = E:create_entity(mod_name)

					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id
					
					if mod_name == "mod_ignis_altar_damage" then
						new_mod.modifier.level = math.min(#new_mod.damages, this.aura.level)
						new_mod.damage_min = math.ceil(new_mod.damages[new_mod.modifier.level] * damage_factor)
						new_mod.damage_max = new_mod.damage_min
					end

					queue_insert(store, new_mod)
				end
			end
		end

		::label_93_0::

		coroutine.yield()
	end

	this.tween.ts = store.tick_ts
	this.tween.disabled = nil
end

scripts.tower_ignis_altar_ablaze_elemental = {}
function scripts.tower_ignis_altar_ablaze_elemental.update(this, store, script)
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

	local function hide_shadow(isHidden)
		for i, sprite in ipairs(this.render.sprites) do
			if sprite.is_shadow then
				sprite.hidden = isHidden
			end
		end
	end

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	hide_shadow(true)
	this.health_bar.hidden = true
	U.animation_start(this, this.render.sprites[1].name, nil, store.tick_ts, nil, 1)
	while not U.animation_finished(this, 1) and not this.health.dead do
		coroutine.yield()
	end
	if not this.health.dead then
		hide_shadow(false)
		this.health_bar.hidden = nil
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
			hide_shadow(true)
			SU.y_soldier_death(store, this)
			U.animation_start(this, "deathIdle", nil, store.tick_ts, true, 1)
			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			SU.soldier_courage_upgrade(store, this)

			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_43_1
				end
			end

			check_tower_damage_factor()

			if this.melee then
				if this.dodge and this.dodge.hide_shadow and this.dodge.counter_attack_pending then
					hide_shadow(true)
				end
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
				if this.dodge and this.dodge.hide_shadow then
					hide_shadow(false)
				end

				if brk or sta ~= A_NO_TARGET then
					goto label_43_1
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

scripts.tower_royal_archer_and_musketeer = {}
function scripts.tower_royal_archer_and_musketeer.insert(this, store, script)
	for i, s in ipairs(this.shooters) do
		local shooter = E:create_entity(s)
		shooter.owner = this
		shooter.pos = this.pos
		local spent = this.tower_upgrade_persistent_data.combination_tower_spent
		for k, v in pairs(shooter.powers) do
			if spent >= 1880 then
				v.level = 3
				v.changed = true
			elseif spent >= 1330 then
				v.level = 2
				v.changed = true
			elseif spent >= 780 then
				v.level = 1
				v.changed = true
			end
		end
		this.shooters[i] = shooter
		queue_insert(store, shooter)
	end
	return true
end

function scripts.tower_royal_archer_and_musketeer.update(this, store, script)
	local shooter_sids = {
		3
	}
	local shooter_idx = 1
	local a = this.attacks
	local aa = this.attacks.list[1]
	local ap = this.attacks.list[2]

	if not a._last_target_pos then
		a._last_target_pos = {}

		for i = 1, #shooter_sids do
			a._last_target_pos[i] = v(REF_W, 0)
		end
	end

	this.rapacious_hunter_tamer = nil

	local function shot_animation(attack, shooter_idx, pos)
		local ssid = shooter_sids[shooter_idx]
		local soffset = this.render.sprites[ssid].offset
		local s = this.render.sprites[ssid]
		local an, af = U.animation_name_facing_point(this, attack.animation, pos, ssid, soffset)

		U.animation_start(this, an, af, store.tick_ts, 1, ssid)
	end

	local function shot_bullet(attack, shooter_idx, enemy, level)
		local ssid = shooter_sids[shooter_idx]
		local shooting_up = tpos(this).y < enemy.pos.y
		local shooting_right = not this.render.sprites[ssid].flip_x
		local soffset = this.render.sprites[ssid].offset
		local boffset = attack.bullet_start_offset[shooting_up and 1 or 2]
		local b = E:create_entity(attack.bullet)

		b.pos.x = this.pos.x + soffset.x + boffset.x * (shooting_right and 1 or -1)
		b.pos.y = this.pos.y + soffset.y + boffset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
		b.bullet.target_id = enemy.id
		b.bullet.source_id = this.id
		b.bullet.level = level
		b.bullet.damage_factor = this.tower.damage_factor
		b.bullet.flight_time = 2 * (math.sqrt(2 * b.bullet.fixed_height * b.bullet.g * -1) / b.bullet.g * -1)

		queue_insert(store, b)
	end

	local function shot_bullet_armor_piercer(attack, shooter_idx, enemy, level, index)
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
		b.bullet.source_id = this.id
		b.bullet.level = level
		b.bullet.damage_factor = this.tower.damage_factor
		b.bullet.damage_max = b.bullet.damage_max_config[b.bullet.level]
		b.bullet.damage_min = b.bullet.damage_min_config[b.bullet.level]
		b.bullet.reduce_armor = b.bullet.reduce_armor[b.bullet.level]

		if b.bullet.fixed_height then
			local height = b.bullet.fixed_height + (index - 1) * 15

			b.bullet.fixed_height = height
		end

		b.bullet.flight_time = b.bullet.flight_time + index * fts(6)

		queue_insert(store, b)
	end

	local function prepare_targets_armor_piercer(enemy, enemies)
		local reload_enemy, reload_enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, ap.range_effect, false, ap.vis_flags, ap.vis_bans)

		if reload_enemy and #reload_enemies > 0 then
			enemy = reload_enemy
			enemies = reload_enemies
		end

		local targets = {}
		local first_target_on_left = enemy.pos.x < this.pos.x

		for i = 1, 3 do
			local enemy_index = km.zmod(i, #enemies)
			local e = enemies[enemy_index]

			if first_target_on_left and e.pos.x < this.pos.x then
				table.insert(targets, e)
			elseif not first_target_on_left and e.pos.x > this.pos.x then
				table.insert(targets, e)
			elseif i > 1 then
				table.insert(targets, targets[i - 1])
			end
		end

		table.sort(targets, function(e1, e2)
			return V.dist(this.pos.x, this.pos.y, e1.pos.x, e1.pos.y) > V.dist(this.pos.x, this.pos.y, e2.pos.x, e2.pos.y)
		end)

		return targets
	end

	local function check_upgrades_purchase()
		if this.powers then
			for _, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if pow == this.powers.rapacious_hunter then
						this.render.sprites[this.sid_rapacious_hunter].hidden = false

						if not this.rapacious_hunter_tamer then
							local s = E:create_entity(pow.entity)

							s.pos.x, s.pos.y = V.add(this.pos.x, this.pos.y, pow.entity_offset.x, pow.entity_offset.y)
							s.owner = this
							s.level = pow.level
							this.rapacious_hunter_tamer = s

							queue_insert(store, s)

							local fx = E:create_entity(pow.purchase_fx)

							fx.pos = s.pos
							fx.render.sprites[1].ts = store.tick_ts

							queue_insert(store, fx)
						else
							this.rapacious_hunter_tamer.level = pow.level
						end
					else
						local pa = this.attacks.list[pow.attack_idx]

						pa.cooldown = pow.cooldown[pow.level]

						if pow.level == 1 then
							pa.ts = store.tick_ts - pa.cooldown
						end
					end
				end
			end
		end
	end

	local function shooters_idle()
		for idx, ssid in ipairs(shooter_sids) do
			local soffset = this.render.sprites[ssid].offset
			local s = this.render.sprites[ssid]
			local an, af = U.animation_name_facing_point(this, "idle", a._last_target_pos[idx], ssid, soffset)
			U.animation_start(this, an, af, store.tick_ts, 1, ssid)
		end
	end

	shooters_idle()
	SU.towers_swaped(store, this, this.attacks.list)
	aa.ts = store.tick_ts - aa.cooldown + a.attack_delay_on_spawn

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			check_upgrades_purchase()

			if this.powers and this.powers.armor_piercer then
				local pow_p = this.powers.armor_piercer

				if pow_p.level > 0 and store.tick_ts - ap.ts > ap.cooldown and this.tower.can_do_magic then
					local enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, ap.range_trigger, false, ap.vis_flags, ap.vis_bans)

					if not enemy then
						SU.delay_attack(store, ap, fts(10))
					else
						local start_ts = store.tick_ts

						shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

						shot_animation(ap, shooter_idx, enemy.pos)
						S:queue(ap.sound)

						while store.tick_ts - start_ts < ap.shoot_time do
							check_upgrades_purchase()
							coroutine.yield()
						end

						local targets = prepare_targets_armor_piercer(enemy, enemies)
						local arrow_number = 1

						if targets[1].pos.x < this.pos.x then
							local ssid = shooter_sids[shooter_idx]

							this.render.sprites[ssid].flip_x = true
						end

						for _, enemy in pairs(targets) do
							shot_bullet_armor_piercer(ap, shooter_idx, enemy, pow_p.level, arrow_number)
							U.y_wait(store, ap.time_between_arrows)

							arrow_number = arrow_number + 1
						end

						U.y_animation_wait(this, shooter_sids[shooter_idx])

						ap.ts = start_ts
						aa.ts = start_ts
					end
				end
			end

			if store.tick_ts - aa.ts > aa.cooldown then
				local trigger_enemy, _ = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)

				if not trigger_enemy then
					SU.delay_attack(store, aa, fts(10))
				else
					aa.ts = store.tick_ts
					shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

					shot_animation(aa, shooter_idx, trigger_enemy.pos)

					while store.tick_ts - aa.ts < aa.shoot_time do
						check_upgrades_purchase()
						coroutine.yield()
					end

					local enemy, _ = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)

					enemy = enemy or trigger_enemy

					shot_bullet(aa, shooter_idx, enemy, 0)

					a._last_target_pos[shooter_idx].x, a._last_target_pos[shooter_idx].y = enemy.pos.x, enemy.pos.y

					U.y_animation_wait(this, shooter_sids[shooter_idx])
				end
			end

			shooters_idle()

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

function scripts.tower_royal_archer_and_musketeer.remove(this, store, script)
	for i, s in ipairs(this.shooters) do
		queue_remove(store, s)
	end
	if this.rapacious_hunter_tamer then
		local eagle = this.rapacious_hunter_tamer.entity_spawned
		if eagle then
			queue_remove(store, eagle)
		end
		queue_remove(store, this.rapacious_hunter_tamer)
	end
	return true
end

scripts.shooter_musketeer = {}
function scripts.shooter_musketeer.update(this, store, script)
	local shooter_sids = {
		1
	}
	local shooter_idx = 1
	local a = this.attacks
	local aa = this.attacks.list[1]
	local asn = this.attacks.list[2]
	local asi = this.attacks.list[3]
	local ash = this.attacks.list[4]
	local pow_sn = this.powers.sniper
	local pow_sh = this.powers.shrapnel

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
		local shooting_right = tpos(this.owner).x < enemy.pos.x
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
		b.bullet.damage_factor = this.owner.tower.damage_factor

		if attack == asn then
			local extra_damage = pow_sn.damage_factor_inc * pow_sn.level * enemy.health.hp_max

			b.bullet.damage_max = b.bullet.damage_max + extra_damage
			b.bullet.damage_min = b.bullet.damage_min + extra_damage
		end

		queue_insert(store, b)

		return b
	end

	while true do
		if this.owner.tower.blocked then
			coroutine.yield()
		else
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if pow.level >= 1 then
						for _, ax in pairs(a.list) do
							if ax.power_name and this.powers[ax.power_name] == pow and not ax.ts then
								ax.ts = store.tick_ts
							end
						end
					end

					if pow == pow_sn then
						asi.chance = pow_sn.instakill_chance_inc * pow_sn.level
					end
				end
			end

			if this.owner.tower.can_do_magic and pow_sn.level > 0 then
				for _, ax in pairs({
					asi,
					asn
				}) do
					if (ax.chance == 1 or math.random() < ax.chance) and store.tick_ts - ax.ts > ax.cooldown then
						local enemy = U.find_strongest_enemy_in_range(store.entities, tpos(this.owner), 0, ax.range, false, ax.vis_flags, ax.vis_bans)

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

						-- local seeker_idx = km.zmod(shooter_idx + 1, #shooter_sids)
						local an, af, ai = shot_animation(ax, shooter_idx, enemy)

						-- shot_animation(ax, seeker_idx, enemy, ax.animation_seeker)
						U.y_wait(store, ax.shoot_time)

						if V.dist(tpos(this.owner).x, tpos(this.owner).y, enemy.pos.x, enemy.pos.y) <= ax.range then
							shot_bullet(ax, shooter_idx, ai, enemy, pow_sn.level)
						end

						U.y_animation_wait(this, shooter_sids[shooter_idx])
					end
				end
			end

			if this.owner.tower.can_do_magic and pow_sh.level > 0 and store.tick_ts - ash.ts > ash.cooldown then
				local enemy = U.find_foremost_enemy(store.entities, tpos(this.owner), 0, ash.range, false, ash.vis_flags, ash.vis_bans)

				if not enemy then
					-- block empty
				else
					ash.ts = store.tick_ts
					aa.ts = store.tick_ts
					shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

					-- local fuse_idx = km.zmod(shooter_idx + 1, #shooter_sids)
					local ssid = shooter_sids[shooter_idx]
					-- local fsid = shooter_sids[fuse_idx]
					local an, af, ai = shot_animation(ash, shooter_idx, enemy)

					-- shot_animation(ash, fuse_idx, enemy, ash.animation_seeker)

					-- this.render.sprites[fsid].flip_x = fuse_idx < shooter_idx
					this.render.sprites[ssid].draw_order = 5

					U.y_wait(store, ash.shoot_time)

					local shooting_right = tpos(this.owner).x < enemy.pos.x
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
				local enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this.owner), 0, a.range, false, aa.vis_flags, aa.vis_bans)

				if not enemy then
					-- block empty
				else
					aa.ts = store.tick_ts
					shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

					local an, af, ai = shot_animation(aa, shooter_idx, enemy)

					U.y_wait(store, aa.shoot_time)

					if V.dist(tpos(this.owner).x, tpos(this.owner).y, enemy.pos.x, enemy.pos.y) <= a.range then
						shot_bullet(aa, shooter_idx, ai, enemy, 0)
					end

					U.y_animation_wait(this, shooter_sids[shooter_idx])
				end
			end

			coroutine.yield()
		end
	end
end

scripts.tower_royal_archer_and_ranger = {}
function scripts.tower_royal_archer_and_ranger.insert(this, store, script)
	for i, s in ipairs(this.shooters) do
		local shooter = E:create_entity(s)
		shooter.owner = this
		shooter.pos = this.pos
		local spent = this.tower_upgrade_persistent_data.combination_tower_spent
		for k, v in pairs(shooter.powers) do
			if spent >= 1580 then
				v.level = 3
				v.changed = true
			elseif spent >= 1130 then
				v.level = 2
				v.changed = true
			elseif spent >= 680 then
				v.level = 1
				v.changed = true
			end
		end
		this.shooters[i] = shooter
		queue_insert(store, shooter)
	end
	return true
end

scripts.shooter_ranger = {}
function scripts.shooter_ranger.update(this, store, script)
	local shooter_sids = {
		1
	}
	local shooter_idx = 1
	local druid_sid = 3
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
		local shooting_up = tpos(this.owner).y < enemy.pos.y
		local shooting_right = tpos(this.owner).x < enemy.pos.x
		local soffset = this.render.sprites[ssid].offset
		local boffset = attack.bullet_start_offset[shooting_up and 1 or 2]
		local b = E:create_entity(attack.bullet)

		b.pos.x = this.pos.x + soffset.x + boffset.x * (shooting_right and 1 or -1)
		b.pos.y = this.pos.y + soffset.y + boffset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
		b.bullet.target_id = enemy.id
		b.bullet.level = level
		b.bullet.damage_factor = this.owner.tower.damage_factor
		b.bullet.mod = pow_p.level > 0 and pow_p.mod

		if math.random() <= 0.1 then
			b.bullet.damage_min = b.bullet.damage_min * 2
			b.bullet.damage_max = b.bullet.damage_max * 2
			b.bullet.pop = {
				"pop_crit"
			}
			b.bullet.pop_conds = DR_DAMAGE
		end

		queue_insert(store, b)
	end

	while true do
		if this.owner.tower.blocked then
			coroutine.yield()
		else
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if pow == pow_t and this.render.sprites[druid_sid].hidden then
						this.render.sprites[druid_sid].hidden = false

						local ta = E:create_entity(pow_t.aura)

						ta.aura.source_id = this.id
						ta.pos = tpos(this.owner)

						queue_insert(store, ta)
					end
				end
			end

			if store.tick_ts - aa.ts > aa.cooldown then
				local enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this.owner), 0, a.range, false, aa.vis_flags, aa.vis_bans)

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

					if V.dist(tpos(this.owner).x, tpos(this.owner).y, enemy.pos.x, enemy.pos.y) <= a.range then
						shot_bullet(aa, shooter_idx, enemy, pow_p.level)
					end

					U.y_animation_wait(this, shooter_sids[shooter_idx])
					U.animation_start(this, idle_an, idle_af, store.tick_ts, false, shooter_sids[shooter_idx])
				end
			end

			coroutine.yield()
		end
	end
end

scripts.tower_royal_archer_and_longbow = {}
function scripts.tower_royal_archer_and_longbow.insert(this, store, script)
	for i, s in ipairs(this.shooters) do
		local shooter = E:create_entity(s)
		shooter.owner = this
		shooter.pos = this.pos
		local spent = this.tower_upgrade_persistent_data.combination_tower_spent
		for k, v in pairs(shooter.powers) do
			if spent >= 1625 then
				v.level = 3
				v.changed = true
			elseif spent >= 1175 then
				v.level = 2
				v.changed = true
			elseif spent >= 725 then
				v.level = 1
				v.changed = true
			end
		end
		this.shooters[i] = shooter
		queue_insert(store, shooter)
	end
	return true
end

scripts.shooter_longbow = {}
function scripts.shooter_longbow.update(this, store, script)
	local a = this.attacks
	local aa = this.attacks.list[1]
	local as = this.attacks.list[2]
	local am = this.attacks.list[3]
	local pow_s = this.powers.sentence
	local pow_m = this.powers.mark
	local sid = 1

	local function is_long(enemy)
		return V.dist(tpos(this.owner).x, tpos(this.owner).y, enemy.pos.x, enemy.pos.y) > a.short_range
	end

	local function y_do_shot(attack, enemy, level)
		S:queue(attack.sound, attack.sound_args)

		local lidx = is_long(enemy) and 2 or 1
		local soffset = this.render.sprites[sid].offset
		local an, af, ai = U.animation_name_facing_point(this, attack.animations[lidx], enemy.pos, sid, soffset)

		U.animation_start(this, an, af, store.tick_ts, false, sid)

		local shoot_time = attack.shoot_times[lidx]

		U.y_wait(store, shoot_time)

		if V.dist(tpos(this.owner).x, tpos(this.owner).y, enemy.pos.x, enemy.pos.y) <= a.range then
			local boffset = attack.bullet_start_offsets[lidx][ai]
			local b = E:create_entity(attack.bullets[lidx])

			b.pos.x = this.pos.x + soffset.x + boffset.x * (af and -1 or 1)
			b.pos.y = this.pos.y + soffset.y + boffset.y
			b.bullet.from = V.vclone(b.pos)
			b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
			b.bullet.target_id = enemy.id
			b.bullet.level = level or 0
			b.bullet.damage_factor = this.owner.tower.damage_factor

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
		if this.owner.tower.blocked then
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

			if pow_m.level > 0 and store.tick_ts - am.ts > am.cooldown and this.owner.tower.can_do_magic then
				local enemy = U.find_strongest_enemy_in_range(store.entities, tpos(this.owner), 0, a.range, false, am.vis_flags, am.vis_bans, function(e)
					return not U.has_modifiers(store, e, "mod_arrow_silver_mark")
				end)

				if enemy then
					am.ts = store.tick_ts

					reset_cooldowns(is_long(enemy))
					y_do_shot(am, enemy, pow_m.level)
				end
			end

			if pow_s.level > 0 and store.tick_ts - as.ts > as.cooldown and this.owner.tower.can_do_magic then
				local enemy = U.find_strongest_enemy_in_range(store.entities, tpos(this.owner), 0, a.range, false, as.vis_flags, as.vis_bans)

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
				local enemy = U.find_foremost_enemy(store.entities, tpos(this.owner), 0, a.range, false, aa.vis_flags, aa.vis_bans)

				if enemy then
					reset_cooldowns(is_long(enemy))
					y_do_shot(aa, enemy)
				end
			end

			coroutine.yield()
		end
	end
end

scripts.royal_archers_decal_preview_controller = {}
function scripts.royal_archers_decal_preview_controller.insert(this, store, script)
	this.hovers = {}
	for _, v in pairs(store.entities) do
		if v.tower and v.ui and v.ui.can_click and this:filter_func(v) then
			local h = E:create_entity(this.template_hover)
			h.pos = v.pos
			queue_insert(store, h)
			table.insert(this.hovers, h)
		end
	end
	return true
end

function scripts.royal_archers_decal_preview_controller.remove(this, store, script)
	if this.hovers then
		for _, v in pairs(this.hovers) do
			queue_remove(store, v)
		end
		this.hovers = nil
	end
	return true
end

scripts.royal_archers_tower_combination_controller = {}
function scripts.royal_archers_tower_combination_controller.update(this, store, script)
	local t1 = this.tower_1
	local t2 = this.tower_2

	if t1 and t2 and t1.tower and t2.tower then
		if this.sound then
			S:queue(this.sound, this.sound_args)
		end
		t1.ui.can_click = false
		t2.ui.can_click = false

		U.y_wait(store, this.delay)
		local name = this.towers[t2.tower.kind]
		if name then
			local new_tower = E:create_entity(name)
			new_tower.pos = V.vclone(t1.pos)
			new_tower.tower.holder_id = t1.tower.holder_id
			new_tower.tower.flip_x = t1.tower.flip_x
			new_tower.tower.spent = t1.tower.spent
			if t1.tower.default_rally_pos then
				new_tower.tower.default_rally_pos = V.vclone(t1.tower.default_rally_pos)
			end
			if t1.tower.terrain_style then
				new_tower.tower.terrain_style = t1.tower.terrain_style
				if new_tower.render.sprites[1].name == "terrains_%04i" then
					new_tower.render.sprites[1].name = string.format(new_tower.render.sprites[1].name, new_tower.tower.terrain_style)
				end
			end
			if new_tower.ui and t1.ui then
				new_tower.ui.nav_mesh_id = t1.ui.nav_mesh_id
			end
			new_tower.tower_upgrade_persistent_data.combination_tower_spent = t2.tower.spent
			if new_tower.powers then
				for k, pow in pairs(new_tower.powers) do
					pow.level = t1.powers[k].level
					pow.changed = pow.level > 0
				end
			end
			queue_remove(store, t1)
			queue_insert(store, new_tower)
		end

		t2.tower.spent = 0
		t2.tower.sell = true
	end

	queue_remove(store, this)
end

scripts.kr4_hero_malik = {}
function scripts.kr4_hero_malik.update(this, store, script)
	local h = this.health
	local hero = this.hero
	local a1 = this.timed_attacks.list[1]
	local a2 = this.timed_attacks.list[2]
	local brk, sta
	a1.ts, a2.ts = store.tick_ts, store.tick_ts

	local function hide_shadow(isHidden)
		for i, sprite in ipairs(this.render.sprites) do
			if sprite.is_shadow then
				sprite.hidden = isHidden
			end
		end
	end

	local function y_hero_death_and_respawn(store, this)
		this.ui.can_click = false
		local death_ts = store.tick_ts
		local dead_lifetime = h.dead_lifetime
	
		U.unblock_target(store, this)
		S:queue(this.sound_events.death, this.sound_events.death_args)
		for i, sound in ipairs(this.sound_events.after_death) do
			S:queue(sound, this.sound_events.after_death_args[i])
		end
		hide_shadow(true)
		if this.unit.death_animation then
			U.y_animation_play(this, this.unit.death_animation, nil, store.tick_ts, 1, 1)
		else
			U.y_animation_play(this, "death", nil, store.tick_ts, 1, 1)
		end
		U.animation_start(this, this.hero.death_loop_animation, nil, store.tick_ts, true, 1)

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
	
		if hero and hero.respawn_point then
			local p = he.respawn_point
			this.pos.x, this.pos.y = p.x, p.y
			this.nav_rally.pos.x, this.nav_rally.pos.y = p.x, p.y
			this.nav_rally.center.x, this.nav_rally.center.y = p.x, p.y
			this.nav_rally.new = false
		end
	
		h.ignore_damage = true
		S:queue(this.sound_events.respawn)
		hide_shadow(false)
		if hero.respawn_animation then
			U.y_animation_play(this, hero.respawn_animation, nil, store.tick_ts, 1, 1)
		else
			U.y_animation_play(this, "respawn", nil, store.tick_ts, 1, 1)
		end
	
		this.health_bar.hidden = false
		this.ui.can_click = true
		h.dead = false
		this.force_respawn = nil
		h.hp = h.hp_max
		h.ignore_damage = false
	end

	this.health_bar.hidden = true
	U.y_animation_play(this, hero.respawn_animation, nil, store.tick_ts, 1, 1)
	this.health_bar.hidden = nil

	while true do
		if h.dead then
			y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				local rally = SU.y_hero_new_rally(store, this)
				if rally then
					goto label_90_1
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if SU.check_unit_attack_available(store, this, a1) then
				local target = U.find_enemy_with_search_type(store.entities, this.pos, a1.min_range, a1.max_range, nil, a1.vis_flags, a1.vis_bans, nil, nil, a1.search_type)
				if target then
					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, a1.animation, target.pos)
					U.animation_start(this, an, af, store.tick_ts, nil, 1)
					if SU.y_hero_wait(store, this, a1.shoot_time) then
						goto label_90_1
					end
					target = store.entities[target.id]
					if not target or target.health.dead then
						target = U.find_enemy_with_search_type(store.entities, this.pos, a1.min_range, a1.max_range, nil, a1.vis_flags, a1.vis_bans, nil, nil, a1.search_type)
					end
					if target then
						local bullet = E:create_entity(a1.bullet)
						bullet.pos = target.pos
						bullet.bullet.source_id = this.id
						bullet.bullet.target_id = target.id
						if bullet.bullet.use_unit_damage_factor then
							bullet.bullet.damage_factor = this.unit.damage_factor
						end
						queue_insert(store, bullet)
						a1.ts = start_ts
					else
						SU.delay_attack(store, a1, 0.1)
					end
					SU.y_hero_animation_wait(this)
					goto label_90_1
				else
					SU.delay_attack(store, a1, 0.1)
				end
			end

			if this.motion.arrived and this.soldier.target_id then
				local target = store.entities[this.soldier.target_id]
				if not target or target.health.dead then
					goto label_90_0
				end
				if SU.check_unit_attack_available(store, this, a2) then
					local start_ts = store.tick_ts
					local an, af = U.animation_name_facing_point(this, a2.animation, target.pos)
					U.animation_start(this, an, af, store.tick_ts, nil, 1)
					if SU.y_hero_wait(store, this, a2.shoot_time) then
						goto label_90_1
					end
					target = store.entities[target.id]
					if target and not target.health.dead then
						local bullet = E:create_entity(a2.bullet)
						bullet.pos = target.pos
						bullet.bullet.source_id = this.id
						bullet.bullet.target_id = target.id
						if bullet.bullet.use_unit_damage_factor then
							bullet.bullet.damage_factor = this.unit.damage_factor
						end
						queue_insert(store, bullet)
						a2.ts = start_ts
					end
					if SU.y_hero_animation_wait(this) then
						goto label_90_1
					end
				end
			end

			::label_90_0::

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

		::label_90_1::

		coroutine.yield()
	end
end

scripts.mod_eiskalt_frozen_throat_slow = {}
function scripts.mod_eiskalt_frozen_throat_slow.update(this, store, script)
	local m = this.modifier
	if not m.ts then
		m.ts = store.tick_ts
	end

	local target = store.entities[m.target_id]
	if not target or not target.pos or not target.render then
		queue_remove(store, this)
		return
	end

	local shader = SH:get(this.shader)
	local function addShader(isAdd, target)
		if isAdd then
			if target and target.render then
				for i, s in pairs(target.render.sprites) do
					local f = target.render.frames[i]
					if not s.is_shadow and not f.shader then
						f.shader = shader
						f.shader_args = this.shader_args
					end
				end
			end
		elseif target and target.render then
			for i, f in pairs(target.render.frames) do
				f.shader = nil
				f.shader_args = nil
			end
		end
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]
		if target and target.health and not target.health.dead and store.tick_ts - m.ts <= m.duration then
			addShader(true, target)
		else
			queue_remove(store, this)
			return
		end
		coroutine.yield()
	end
end

function scripts.mod_eiskalt_frozen_throat_slow.remove(this, store, script)
	local shader = SH:get(this.shader)
	local function addShader(isAdd, target)
		if isAdd then
			if target and target.render then
				for i, s in pairs(target.render.sprites) do
					local f = target.render.frames[i]
					if not s.is_shadow and not f.shader then
						f.shader = shader
						f.shader_args = this.shader_args
					end
				end
			end
		elseif target and target.render then
			for i, f in pairs(target.render.frames) do
				f.shader = nil
				f.shader_args = nil
			end
		end
	end

	local target = store.entities[this.modifier.target_id]
	addShader(false, target)

	if target and target.motion then
		target.motion.max_speed = target.motion.max_speed / this.slow.factor
	end

	return true
end

scripts.hero_eiskalt_frosty = {}
function scripts.hero_eiskalt_frosty.update(this, store, script)
	this.aura.ts = store.tick_ts
	local last_hit_ts = 0

	local function hide_shadow(isHidden)
		for i, sprite in ipairs(this.render.sprites) do
			if sprite.is_shadow then
				sprite.hidden = isHidden
			end
		end
	end

	U.y_animation_play(this, "spawn", nil, store.tick_ts, nil, 1)

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

		local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {
			this.nav_path.pi
		}, {
			this.nav_path.spi
		})
		if nearest and nearest[1] and nearest[1][3] < this.nav_path.ni then
			this.nav_path.ni = nearest[1][3]
		end
		local next_pos = P:next_entity_node(this, store.tick_length)
		if not next_pos or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or GR:cell_is(next_pos.x, next_pos.y, bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) then
			break
		end
		U.set_destination(this, next_pos)
		local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)
		U.animation_start(this, an, af, store.tick_ts, -1)
		U.walk(this, store.tick_length)

		coroutine.yield()
	end

	S:queue(this.sound_events.death)
	hide_shadow(true)
	U.y_animation_play(this, "death", nil, store.tick_ts, nil, 1)
	U.y_wait(store, this.dead_lifetime)
	queue_remove(store, this)
end

scripts.aura_ice_peak = {}
function scripts.aura_ice_peak.update(this, store, script)
	if this.random_scale and this.random_scale ~= 1 then
		local scale
		if this.random_scale < 1 then
			scale = U.frandom(this.random_scale, 1 + 1e-09)
		else
			scale = U.frandom(1, this.random_scale + 1e-09)
		end
		this.render.sprites[1].scale = V.v(scale, scale)
	end
	if this.random_flip_x and math.random() < 0.5 then
		this.render.sprites[1].flip_x = true
	end

	U.y_animation_play(this, "in", nil, store.tick_ts, nil, 1)
	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)
	if targets then
		for i, target in ipairs(targets) do
			local d = E:create_entity("damage")
			d.source_id = this.id
			d.target_id = target.id
			if U.flag_has(target.vis.flags, bor(F_MINIBOSS, F_BOSS)) then
				d.value = this.damage_boss
			else
				d.value = math.floor(target.health.hp_max * this.hp_damage_factor)
			end
			d.damage_type = this.aura.damage_type
			d.track_damage = this.aura.track_damage
			queue_damage(store, d)
	
			local mods = this.aura.mods or {
				this.aura.mod
			}
			for _, mod_name in pairs(mods) do
				local m = E:create_entity(mod_name)
				m.modifier.level = this.aura.level
				m.modifier.target_id = target.id
				m.modifier.source_id = this.id
				queue_insert(store, m)
			end
		end
	end

	U.animation_start(this, "run", nil, store.tick_ts, true)
	this.aura.ts = store.tick_ts
	local last_hit_ts = 0
	while true do
		if this.aura.duration >= 0 and store.tick_ts - this.aura.ts >= this.aura.duration + this.aura.level * this.aura.duration_inc then
			break
		end

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			last_hit_ts = store.tick_ts
			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)
			if targets then
				for _, target in pairs(targets) do
					local mods = this.aura.mods or {
						this.aura.mod
					}
					for _, mod_name in pairs(mods) do
						local m = E:create_entity(mod_name)
						m.modifier.level = this.aura.level
						m.modifier.target_id = target.id
						m.modifier.source_id = this.id
						queue_insert(store, m)
					end
				end
			end
		end

		coroutine.yield()
	end

	U.y_animation_play(this, "out", nil, store.tick_ts, nil, 1)
	queue_remove(store, this)
end

scripts.rain_controller_fx_hero_eiskalt_explosion = {}
function scripts.rain_controller_fx_hero_eiskalt_explosion.update(this, store, script)
	local delay = 0
	for i = 1, this.max_entities do
		local entity = E:create_entity(this.entity_name)
		if i > 2 then
			delay = this.delay_between_objects
		end
		if i > 1 then
			entity.pos = U.random_point_in_ellipse(this.pos, this.radius)
		else
			entity.pos = this.pos
		end
		table.insert(this.entities, entity)
		table.insert(this.delays, delay)
	end
	scripts.entities_delay_controller.update(this, store, script)
end

scripts.hero_eiskalt = {}
function scripts.hero_eiskalt.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	local s

	s = this.hero.skills.fierce_breath

	if initial and s.level > 0 then
		b.bullet.damage_radius = s.damage_area[s.level]
		local fx = E:get_template(b.bullet.hit_fx)
		fx.max_entities = s.max_effects[s.level]
		fx.radius = s.effect_range[s.level]
		fx = E:get_template(b.bullet.hit_fx_air)
		fx.max_entities = s.max_air_effects[s.level]
		fx.radius = s.air_effect_range[s.level]
	end

	s = this.hero.skills.cold_fury

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]
		a.cooldown = s.cooldown[s.level]
		a.disabled = nil
	end

	s = this.hero.skills.ice_ball

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]
		local b = E:get_template(a.bullet)
		local hp = E:get_template(b.bullet.hit_payload)
		hp.aura.duration = s.duration[s.level]
		hp.aura.damage_min = s.damage_over_time[s.level]
		hp.aura.damage_max = s.damage_over_time[s.level]
		a.disabled = nil
	end

	s = this.hero.skills.ice_peaks

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[3]
		local controller = E:get_template(a.entity)
		local aura = E:get_template(controller.entity_name)
		aura.hp_damage_factor = s.hp_damage_factor[s.level]
		aura.damage_boss = s.damage_boss[s.level]
		a.disabled = nil
	end

	s = this.hero.skills.ultimate

	if initial and s.level > 0 then
		local u = E:get_template(s.controller_name)
		u.cooldown = s.cooldown[s.level]
		u.duration = s.duration[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_eiskalt.update(this, store, script)
	local h = this.health
	local ranged = this.ranged.attacks[1]
	local cold_fury_attack = this.timed_attacks.list[1]
	local ice_ball_attack = this.timed_attacks.list[2]
	local ice_peaks_attack = this.timed_attacks.list[3]
	local attack, skill

	ranged.ts = store.tick_ts
	cold_fury_attack.ts = store.tick_ts
	ice_ball_attack.ts = store.tick_ts
	ice_peaks_attack.ts = store.tick_ts

	this.health_bar.hidden = false
	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

	while true do
		if h.dead then
			SU.hide_shadow(this, true)
			this.render.sprites[1].z = Z_OBJECTS
			SU.y_hero_death_and_respawn_kr5(store, this)
			this.render.sprites[1].z = Z_FLYING_HEROES
			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		SU.heroes_visual_learning_upgrade(store, this)
		SU.heroes_lone_wolves_upgrade(store, this)
		SU.alliance_merciless_upgrade(store, this)
		SU.alliance_corageous_upgrade(store, this)

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelUp", nil, store.tick_ts, nil, 1)
		end

		local skip
		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
			skip = true
		else
			while this.nav_rally.new do
				local rally = SU.y_hero_new_rally(store, this)
				if rally then
					skip = true
				end
			end
		end

		if not skip then
			attack = ice_peaks_attack
			if SU.check_unit_attack_available(store, this, attack) then
				local target, _, pred_pos = U.find_enemy_with_search_type(store.entities, this.pos, attack.min_range, attack.max_range, attack.cast_time, attack.vis_flags, 
				attack.vis_bans, function(e)
					return e.nav_path
				end)
				if target then
					S:queue(attack.sound)
					local start_ts = store.tick_ts
					local an, af, ai = U.animation_name_facing_point(this, attack.animation, pred_pos)
					U.animation_start(this, an, af, store.tick_ts, nil, 1)
					local interrupted = SU.y_hero_wait(store, this, attack.cast_time)
					if not interrupted then
						local direction = -1
						local nodes = P:nearest_nodes(this.pos.x, this.pos.y, { target.nav_path.pi }, { target.nav_path.spi })
						if #nodes >= 1 then
							local _, _, ni = unpack(nodes[1])
							if ni < target.nav_path.ni then
								direction = 1
							end
						end
						local controller = E:create_entity(attack.entity)
						controller.pos.x, controller.pos.y = this.pos.x, this.pos.y
						controller.path_index = target.nav_path.pi
						controller.direction = direction
						queue_insert(store, controller)
						attack.ts = start_ts
						if attack.xp_from_skill then
							SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
						end
						SU.y_hero_animation_wait(this)
					end
					skip = true
				else
					SU.delay_attack(store, attack, 0.1)
				end
			end
		end

		if not skip then
			attack = ice_ball_attack
			if SU.check_unit_attack_available(store, this, attack) then
				local flight_time = fts(41)
				local target, _, pred_pos = U.find_enemy_with_search_type(store.entities, this.pos, attack.min_range, attack.max_range, attack.cast_time + flight_time, 
				attack.vis_flags, attack.vis_bans, function(e)
					return e.nav_path
				end, nil, attack.search_type, attack.crowd_range, attack.min_targets)
				if target then
					S:queue(attack.sound, attack.sound_args)
					local start_ts = store.tick_ts
					local an, af, ai = U.animation_name_facing_point(this, attack.animation, pred_pos)
					U.animation_start(this, an, af, store.tick_ts, nil, 1)
					local interrupted = SU.y_hero_wait(store, this, attack.cast_time)
					if not interrupted then
						local oldTarget = target
						target = store.entities[target.id]
						if not target or target.health.dead then
							local newTarget = U.find_enemy_with_search_type(store.entities, this.pos, attack.min_range, attack.max_range, flight_time, 
							attack.vis_flags, attack.vis_bans, function(e)
								return e.nav_path
							end, nil, attack.search_type, attack.crowd_range, attack.min_targets)
							if newTarget then
								target = newTarget
							else
								target = oldTarget
							end
						end
						local offset = U.get_prediction_offset(target, flight_time)
						local ni = target.nav_path.ni + offset.node
						pred_pos = P:node_pos(target.nav_path.pi, 1, ni)
						local bullet = E:create_entity(attack.bullet)
						bullet.bullet.source_id = this.id
						bullet.bullet.target_id = nil
						bullet.bullet.to = pred_pos
						local start_offset = attack.bullet_start_offset[ai]
						local flipSign = af and -1 or 1
						bullet.bullet.from = V.v(this.pos.x + start_offset.x * flipSign, this.pos.y + start_offset.y)
						bullet.pos = V.vclone(bullet.bullet.from)
						local hp = E:create_entity(bullet.bullet.hit_payload)
						hp.nav_path.pi = target.nav_path.pi
						hp.nav_path.ni = ni
						bullet.bullet.hit_payload = hp
						queue_insert(store, bullet)
						attack.ts = start_ts
						if attack.xp_from_skill then
							SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
						end
						SU.y_hero_animation_wait(this)
					end
					skip = true
				else
					SU.delay_attack(store, attack, 0.1)
				end
			end
		end

		if not skip then
			attack = cold_fury_attack
			if SU.check_unit_attack_available(store, this, attack) then
				local flight_time = fts(17)
				local target, _, pred_pos = U.find_enemy_with_search_type(store.entities, this.pos, attack.min_range, attack.max_range, attack.cast_time + flight_time, 
				attack.vis_flags, attack.vis_bans, function(e)
					return e.nav_path
				end)
				if target then
					S:queue(attack.sound)
					local start_ts = store.tick_ts
					local an, af, ai = U.animation_name_facing_point(this, attack.animation, pred_pos)
					U.animation_start(this, an, af, store.tick_ts, nil, 1)
					local interrupted = SU.y_hero_wait(store, this, attack.cast_time)
					if not interrupted then
						local oldTarget = target
						target = store.entities[target.id]
						if not target or target.health.dead then
							newTarget, _, new_pred_pos = U.find_enemy_with_search_type(store.entities, this.pos, attack.min_range, attack.max_range, flight_time, 
							attack.vis_flags, attack.vis_bans, function(e)
								return e.nav_path
							end)
							if newTarget then
								target = newTarget
								pred_pos = new_pred_pos
							else
								target = oldTarget
							end
						end
						local bullet = E:create_entity(attack.bullet)
						bullet.bullet.source_id = this.id
						bullet.bullet.target_id = nil
						bullet.bullet.to = pred_pos
						local start_offset = attack.bullet_start_offset[ai]
						local flipSign = af and -1 or 1
						bullet.bullet.from = V.v(this.pos.x + start_offset.x * flipSign, this.pos.y + start_offset.y)
						bullet.pos = V.vclone(bullet.bullet.from)
						local hit_payload = {}
						for i, hp_name in ipairs(bullet.bullet.hit_payload) do
							local hp = E:create_entity(hp_name)
							hp.path_index = target.nav_path.pi
							table.insert(hit_payload, hp)
						end
						bullet.bullet.hit_payload = hit_payload
						queue_insert(store, bullet)
						attack.ts = start_ts
						if attack.xp_from_skill then
							SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
						end
						SU.y_hero_animation_wait(this)
					end
					skip = true
				else
					SU.delay_attack(store, attack, 0.1)
				end
			end
		end

		if not skip then
			local brk, sta = y_hero_ranged_attacks(store, this)
			if not brk and sta ~= A_DONE then
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		coroutine.yield()
	end
end

scripts.hero_eiskalt_ultimate = {}
function scripts.hero_eiskalt_ultimate.update(this, store, script)
	this.pos = V.v(512, 384)
	local start_ts = store.tick_ts
	local last_hit_ts = start_ts
	local sprite1 = this.render.sprites[1]
	local targets = table.filter(store.entities, function(k, v)
		return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.vis_bans) == 0 and band(v.vis.bans, this.vis_flags) == 0 and (not this.excluded_templates or not table.contains(this.excluded_templates, v.template_name)) and (not this.excluded_entities or not table.contains(this.excluded_entities, v.id))
	end)
	for _, target in ipairs(targets) do
		target.freeze_ts = start_ts
		local mods = this.mods or {
			this.mod
		}
		for _, mod_name in pairs(mods) do
			local m = E:create_entity(mod_name)
			m.modifier.target_id = target.id
			m.modifier.source_id = this.id
			queue_insert(store, m)
		end
	end
	
	local function resetParticle(p)
		local radian = this.radian + U.frandom(0, this.radian_var + 1e-09)
		p.speed.x, p.speed.y = math.cos(radian) * this.speed, math.sin(radian) * this.speed
		p.pos.x = this.position.x + U.frandom(0, this.position_var_x)
		p.pos.y = this.position.y
		local scale = p.render.sprites[1].scale
		local scale_var = U.frandom(0, p.scale_var + 1e-09) + p.scale
		scale.x, scale.y = scale_var, scale_var
		p.start_ts = store.tick_ts
		p.end_ts = this.life + U.frandom(0, this.life_var) + p.start_ts
	end

	while true do
		local duration = store.tick_ts - start_ts
		if this.duration >= 0 and duration > this.duration then
			break
		end

		if store.tick_ts - last_hit_ts >= this.cycle_time then
			last_hit_ts = store.tick_ts

			targets = table.filter(store.entities, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.vis_bans) == 0 and band(v.vis.bans, this.vis_flags) == 0 and (not this.excluded_templates or not table.contains(this.excluded_templates, v.template_name)) and (not this.excluded_entities or not table.contains(this.excluded_entities, v.id))
			end)

			for _, target in ipairs(targets) do
				if target.freeze_ts and target.freeze_ts <= last_hit_ts then
					local mods = this.mods or {
						this.mod
					}
					for _, mod_name in pairs(mods) do
						local m = E:create_entity(mod_name)
						m.modifier.target_id = target.id
						m.modifier.source_id = this.id
						queue_insert(store, m)
					end
				elseif not target.freeze_ts then
					target.freeze_ts = last_hit_ts + U.frandom(this.freeze_delay_min, this.freeze_delay_max)
				end
			end
		end

		local count = 0
		for i = 1, this.max_particles do
			if not this.particles[i] then
				if count < this.emission then
					local p = E:create_entity(this.particle_name)
					table.insert(this.particles, p)
					resetParticle(p)
					count = count + 1
					queue_insert(store, p)
				else
					break
				end
			elseif this.particles[i].end_ts <= store.tick_ts then
				if count < this.emission then
					resetParticle(this.particles[i])
					count = count + 1
				end
			else
				local p = this.particles[i]
				p.pos.x = p.pos.x + p.speed.x * store.tick_length
				p.pos.y = p.pos.y + p.speed.y * store.tick_length
			end
		end

		if duration < this.period then
			sprite1.alpha = this.alpha_max * duration
		else
			local diff = this.alpha_max - this.alpha_min
			local phase = duration % this.period
			if phase < this.period / 2 then
				sprite1.alpha = km.round(this.alpha_max - 2 * diff * phase / this.period)
			else
				sprite1.alpha = km.round(this.alpha_min + 2 * diff * (phase - this.period / 2) / this.period)
			end
		end

		coroutine.yield()
	end

	for	i, p in ipairs(this.particles) do
		queue_remove(store, p)
	end

	for _, target in pairs(store.entities) do
		target.freeze_ts = nil
	end

	local endTs = store.tick_ts
	local alpha = sprite1.alpha
	while true do
		if sprite1.alpha > 0 then
			local endDuration = store.tick_ts - endTs
			sprite1.alpha = km.clamp(0, alpha, km.round(alpha - this.alpha_max * endDuration))
		else
			break
		end
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.veznan_crystal = {}
function scripts.veznan_crystal.update(this, store, script)
	local a1 = this.attacks.list[1]
	local bullets = {}
	a1.ts = store.tick_ts
	this.ui.clicked = nil
	this.ui.can_click = nil
	U.animation_start_group(this, "cooldown", nil, store.tick_ts, true, this.animation_group1)
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = nil
			local _, targets = U.find_enemy_with_search_type(store.entities, this.pos, 0, a1.range, nil, a1.vis_flags, a1.vis_bans)
			if targets then
				S:queue(a1.sound, a1.sound_args)
				U.animation_start_group(this, a1.animation, nil, store.tick_ts, true, this.animation_group1)
				for i, target in ipairs(targets) do
					if i > a1.max_targets then
						break
					end
					local bullet = E:create_entity(a1.bullet)
					bullet.bullet.source_id = this.id
					bullet.bullet.target_id = target.id
					local start_offset = a1.bullet_start_offset[1]
					bullet.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
					bullet.pos = V.vclone(bullet.bullet.from)
					bullet.bullet.to = V.vclone(target.pos)
					if target.unit and target.unit.hit_offset then
						local flipSign = 1
						if target.render and target.render.sprites[1].flip_x then
							flipSign = -1
						end
						bullet.bullet.to.x, bullet.bullet.to.y = bullet.bullet.to.x + target.unit.hit_offset.x * flipSign, bullet.bullet.to.y + target.unit.hit_offset.y 
					end
					table.insert(bullets, bullet)
					queue_insert(store, bullet)
					a1.ts = store.tick_ts
				end
				while true do
					for i = #bullets, 1, -1 do
						local bullet = store.entities[bullets[i].id]
						if not bullet then
							table.remove(bullets, i)
						end
					end
					if #bullets <= 0 then
						break
					end
					coroutine.yield()
				end
				U.animation_start_group(this, "cooldown", nil, store.tick_ts, true, this.animation_group1)
			else
				U.animation_start_group(this, "ready", nil, store.tick_ts, true, this.animation_group1)
				for _, s in pairs(this.render.sprites) do
					if s.group == this.animation_group2 then
						s.hidden = nil
					end
				end
				this.tween.reverse = nil
				this.tween.disabled = nil
				this.tween.ts = store.tick_ts
				U.y_wait(store, this.tween_duration)
				this.tween.reverse = true
				this.tween.ts = store.tick_ts
				U.y_wait(store, this.tween_duration)
				for _, s in pairs(this.render.sprites) do
					if s.group == this.animation_group2 then
						s.hidden = true
					end
				end
				this.tween.disabled = true
				this.ui.can_click = true
			end
		end
		
		if store.tick_ts - a1.ts >= a1.cooldown then
			U.animation_start_group(this, "ready", nil, store.tick_ts, true, this.animation_group1)
			this.ui.can_click = true
		end

		coroutine.yield()
	end	
end

return scripts