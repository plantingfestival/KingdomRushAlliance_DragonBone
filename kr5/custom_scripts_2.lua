local log = require("klua.log"):new("custom_scripts_2")

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

scripts.holder_roots_lands_blocked = {}
function scripts.holder_roots_lands_blocked.update(this, store, script)
	U.y_animation_play_group(this, "in", nil, store.tick_ts, nil, this.animation_group)
	U.animation_start_group(this, "idle", nil, store.tick_ts, true, this.animation_group)
end

scripts.holder_roots_lands_removed = {}
function scripts.holder_roots_lands_removed.update(this, store, script)
	U.y_animation_play_group(this, "out", nil, store.tick_ts, nil, this.animation_group)
	local controller = E:create_entity(this.controller)
	controller.holder_id = this.tower.holder_id
	controller.terrain_style = this.tower.terrain_style
	controller.default_rally_pos = this.tower.default_rally_pos
	controller.nav_mesh_id = this.ui.nav_mesh_id
	controller.pos.x, controller.pos.y = this.pos.x, this.pos.y
	queue_insert(store, controller)
	if this.upgrade_to then
		this.tower.upgrade_to = this.upgrade_to
		return
	end
	queue_remove(store, this)
end

scripts.tower_roots_lands_blocked = {}
function scripts.tower_roots_lands_blocked.update(this, store, script)
	local towers = table.filter(store.entities, function(k, v)
		return v.vis and v.tower and v.tower.holder_id == this.tower.holder_id and v.pos.x == this.pos.x and v.pos.y == this.pos.y
	end)
	if #towers > 0 then
		local tower = towers[1]
		tower.tower.blocked = nil
	end
	towers = nil
	U.y_animation_play_group(this, "in", nil, store.tick_ts, nil, this.animation_group)
	U.animation_start_group(this, "idle", nil, store.tick_ts, true, this.animation_group)
	local last_hit_ts = 0
	while true do
		if store.tick_ts - last_hit_ts >= this.cycle_time then
			last_hit_ts = store.tick_ts
			local targets = table.filter(store.entities, function(k, v)
				return v.vis and v.tower and v.tower.holder_id == this.tower.holder_id and v.pos.x == this.pos.x and v.pos.y == this.pos.y
			end)
			if targets then
				local target = targets[1]
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
		end
		coroutine.yield()
	end
end

scripts.controller_holder_roots_lands_blocked = {}
function scripts.controller_holder_roots_lands_blocked.update(this, store, script)
	local towers, tower
	local i = 0
	local spawn_ts = U.frandom(this.cooldown_min, this.cooldown_max + 1e-09) + store.tick_ts
	while spawn_ts > store.tick_ts do
		if i < 10 then
			i = i + 1
			towers = table.filter(store.entities, function(k, v)
				return v.tower and v.tower.holder_id == this.holder_id and v.pos.x == this.pos.x and v.pos.y == this.pos.y
			end)
			if #towers > 0 then
				tower = towers[1]
				tower.ui.clicked = nil
				tower.ui.can_select = true
				tower.ui.can_click = true
				tower = nil
				i = 10
			end
			towers = nil
		end
		coroutine.yield()
	end
	towers = table.filter(store.entities, function(k, v)
		return v.tower and v.tower.holder_id == this.holder_id and v.pos.x == this.pos.x and v.pos.y == this.pos.y
	end)
	local holder
	if #towers > 0 then
		tower = towers[1]
		tower.tower.blocked = true
		tower.ui.can_select = nil
		tower.ui.can_click = nil
		tower.ui.clicked = nil
		if tower.vis then
			holder = E:create_entity("tower_roots_lands_blocked")
			tower = nil
		else
			holder = E:create_entity("holder_roots_lands_blocked")
		end
	else
		holder = E:create_entity("holder_roots_lands_blocked")
	end
	holder.pos.x, holder.pos.y = this.pos.x, this.pos.y
	holder.tower.holder_id = this.holder_id
	holder.tower.terrain_style = this.terrain_style
	holder.tower.default_rally_pos = this.default_rally_pos
	holder.ui.nav_mesh_id = this.nav_mesh_id
	holder.render.sprites[1].name = string.format(holder.render.sprites[1].name, holder.tower.terrain_style)
	holder.render.sprites[2].name = string.format(holder.render.sprites[2].name, holder.tower.terrain_style)
	queue_insert(store, holder)
	if tower then
		queue_remove(store, tower)
	end
	queue_remove(store, this)
end

scripts.swamp_spawner = {}
function scripts.swamp_spawner.update(this, store, script)
	local sp = this.spawner

	while true do
		if sp.spawn_data then
			sp.spawn_data = nil
			S:queue(this.spawn_sound, this.spawn_sound_args)
			for _, s in pairs(this.render.sprites) do
				if s.group == this.animation_group then
					s.hidden = nil
				end
			end
			U.y_animation_play_group(this, this.spawn_animation, nil, store.tick_ts, nil, this.animation_group)
			for _, s in pairs(this.render.sprites) do
				if s.group == this.animation_group then
					s.hidden = true
				end
			end
		end
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.decal_spider_rotten_egg_shooter = {}
function scripts.decal_spider_rotten_egg_shooter.update(this, store, script)
	local sp = this.spawner
	local a = this.ranged.attacks[1]

	while true do
		local spawn_data = sp.spawn_data
		if spawn_data and type(spawn_data) == "table" then
			for i, data in ipairs(spawn_data) do
				local b = E:create_entity(a.bullet)
				b.pos.x, b.pos.y = this.pos.x, this.pos.y
				b.bullet.from = V.vclone(b.pos)
				b.bullet.to = P:node_pos(data[1], data[2], data[3])
				b.bullet.source_id = this.id
				local hp = E:create_entity(b.bullet.hit_payload)
				hp.spawner.pi, hp.spawner.spi, hp.spawner.ni = unpack(data)
				b.bullet.hit_payload = hp
				queue_insert(store, b)
				if i < #spawn_data then
					U.y_wait(store, a.cooldown)
				end
			end
			sp.spawn_data = nil
		end
		coroutine.yield()
	end

	queue_remove(store, this)
end

return scripts