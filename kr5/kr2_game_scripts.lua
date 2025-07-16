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

local scripts = require("scripts")

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

scripts.enemy_tremor = {}

function scripts.enemy_tremor.update(this, store, script)
	local burrowed = true

	::label_6_0::

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

			if not burrowed and not U.get_blocker(store, this) then
				this.vis.bans = this.vis.bans_below_surface

				SU.remove_modifiers(store, this)
				U.animation_start(this, "burrow", nil, store.tick_ts, 1)

				while not U.animation_finished(this) do
					coroutine.yield()
				end

				burrowed = true
			end

			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this)

			if not cont then
				-- block empty
			else
				if blocker then
					if burrowed then
						local an, af = U.animation_name_facing_point(this, "raise", blocker.pos)

						U.animation_start(this, an, af, store.tick_ts, 1)

						while not U.animation_finished(this) do
							coroutine.yield()
						end

						this.vis.bans = this.vis.bans_above_surface
						burrowed = false
					end

					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_6_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_6_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_munra = {}

function scripts.enemy_munra.update(this, store, script)
	local sa = this.timed_attacks.list[1]
	local ha = this.timed_attacks.list[2]
	local ok, blocker, ranged, heal_targets
	local cg = store.count_groups[sa.count_group_type]

	sa.ts = store.tick_ts
	ha.ts = store.tick_ts

	local function ready_to_sarcophagus()
		return store.tick_ts - sa.ts > sa.cooldown and not this.health.dead and this.enemy.can_do_magic and this.nav_path.ni < P:get_defend_point_node(this.nav_path.pi) and (not cg[sa.count_group_name] or cg[sa.count_group_name] < sa.count_group_max)
	end

	local function ready_to_heal()
		if not (store.tick_ts - ha.ts > ha.cooldown) or this.health.dead or not this.enemy.can_do_magic then
			return false
		end

		local targets = table.filter(store.entities, function(k, v)
			return v.enemy and v.enemy.can_accept_magic and v.id ~= this.id and v.health and not v.health.dead and v.health.hp < v.health.hp_max and U.is_inside_ellipse(v.pos, this.pos, ha.range)
		end)

		if #targets > 0 then
			return true, targets
		else
			return false
		end
	end

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			if not this.did_sarcophagus then
				AC:got("MUMMYATTHEGATES")
			end

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
		else
			if ready_to_sarcophagus() then
				local pi, spi, ni = this.nav_path.pi, this.nav_path.spi, this.nav_path.ni
				local path = P:path(pi, 1)

				ni = km.clamp(1, P:get_defend_point_node(pi) - sa.nodes_limit, ni + math.random(sa.node_random_min, sa.node_random_max))

				if not P:is_node_valid(pi, ni) then
					log.debug("munra %s - cannot summon sarcophagus: node %i,%i is not valid", this.id, pi, ni)

					sa.ts = sa.ts + 1
				else
					local npos = P:node_pos(pi, 2, ni)

					sa.ts = store.tick_ts

					S:queue(sa.sound)
					U.animation_start(this, sa.animation, nil, store.tick_ts, 1)

					while store.tick_ts - sa.ts < sa.spawn_time do
						if this.health.dead then
							goto label_7_0
						end

						coroutine.yield()
					end

					local spawn = E:create_entity(sa.entity)

					spawn.pos.x, spawn.pos.y = npos.x, npos.y
					spawn.spawner.pi = pi
					spawn.spawner.ni = ni
					spawn.spawner.count_group_name = sa.count_group_name
					spawn.spawner.count_group_type = sa.count_group_type
					spawn.spawner.count_group_max = sa.count_group_max

					queue_insert(store, spawn)

					this.did_sarcophagus = true

					while not U.animation_finished(this) do
						if this.health.dead then
							goto label_7_0
						end

						coroutine.yield()
					end
				end
			end

			ok, heal_targets = ready_to_heal()

			if heal_targets then
				ha.ts = store.tick_ts

				S:queue(ha.sound)
				U.animation_start(this, ha.animation, nil, store.tick_ts, 1)

				while store.tick_ts - ha.ts < ha.shoot_time do
					if this.health.dead then
						goto label_7_0
					end

					coroutine.yield()
				end

				for i, target in ipairs(heal_targets) do
					if i > ha.max_per_cast then
						break
					end

					local new_mod = E:create_entity(ha.mod)

					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id

					queue_insert(store, new_mod)
				end

				while not U.animation_finished(this) do
					if this.health.dead then
						goto label_7_0
					end

					coroutine.yield()
				end
			end

			ok, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_sarcophagus() or ready_to_heal()
			end)

			if not ok then
				-- block empty
			elseif blocker then
				if not SU.y_wait_for_blocker(store, this, blocker) then
					-- block empty
				else
					while SU.can_melee_blocker(store, this, blocker) and not ready_to_heal() do
						sa.ts = store.tick_ts

						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							break
						end

						coroutine.yield()
					end
				end
			elseif ranged then
				while SU.can_range_soldier(store, this, ranged) and not ready_to_heal() and #this.enemy.blockers == 0 do
					if not SU.y_enemy_range_attacks(store, this, ranged) then
						break
					end

					coroutine.yield()
				end
			end
		end

		::label_7_0::

		coroutine.yield()
	end
end

scripts.enemy_cannibal = {}

function scripts.enemy_cannibal.update(this, store, script)
	local terrain_type

	this.vis.bans = band(this.vis.bans, bnot(F_BLOCK))

	if this.render.sprites[1].name == "raise" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise)
		end

		this.health_bar.hidden = true

		U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	local water_trail = E:create_entity("ps_water_trail")

	water_trail.particle_system.track_id = this.id

	queue_insert(store, water_trail)

	::label_12_0::

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
			local in_water = terrain_type == TERRAIN_WATER

			water_trail.particle_system.emit = in_water

			local ok, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, in_water)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_12_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_12_0
						end

						coroutine.yield()
					end
				end

				if blocker and blocker.health.dead and not in_water and band(blocker.health.last_damage_types, bor(DAMAGE_DISINTEGRATE_BOSS, DAMAGE_DISINTEGRATE, DAMAGE_HOST, DAMAGE_EAT)) == 0 then
					local target = blocker

					if band(target.vis.bans, F_CANNIBALIZE) ~= 0 then
						coroutine.yield()

						goto label_12_0
					end

					U.unblock_all(store, this)

					this.vis.bans = bor(this.vis.bans, F_BLOCK)
					this.motion.forced_waypoint = V.v(target.pos.x, target.pos.y)

					while SU.y_enemy_walk_step(store, this) do
						if this.health.dead then
							goto label_12_0
						end

						if not store.entities[target.id] then
							goto label_12_1
						end
					end

					this.vis.bans = band(this.vis.bans, bnot(F_BLOCK))

					U.animation_start(this, "cannibalize", nil, store.tick_ts, false)
					S:queue(this.sound_events.cannibalize)

					if this.health.hp_max < this.cannibalize.max_hp then
						this.health.hp_max = this.health.hp_max + this.cannibalize.extra_hp
					end

					while not U.animation_finished(this) do
						if not store.entities[target.id] then
							break
						end

						this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + math.ceil(this.cannibalize.hps * store.tick_length))

						coroutine.yield()
					end

					::label_12_1::

					this.vis.bans = band(this.vis.bans, bnot(F_BLOCK))
					this.motion.forced_waypoint = nil

					local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {
						this.nav_path.pi
					}, {
						this.nav_path.spi
					})

					if nearest and nearest[1] and nearest[1][3] > this.nav_path.ni then
						this.nav_path.ni = nearest[1][3]
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_hunter = {}

function scripts.enemy_hunter.insert(this, store, script)
	if not scripts.enemy_basic.insert(this, store, script) then
		return false
	end

	this.ranged.attacks[1].max_range = this.ranged.attacks[1].max_range + math.random(-70, 30) / 2

	return true
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

scripts.alien_egg = {}

function scripts.alien_egg.update(this, store, script)
	local sp = this.spawner
	local s = this.render.sprites[1]
	local last_subpath = 0

	while true do
		if this.do_destroy then
			S:queue(this.sound_events.destroy)
			U.y_animation_play(this, "destroy", nil, store.tick_ts)

			return
		end

		if this.do_spawn then
			this.do_spawn = nil

			if sp.interrupt then
				goto label_16_1
			end

			S:queue(this.sound_events.open)
			U.y_animation_play(this, "open", nil, store.tick_ts)

			for i = 1, sp.count do
				if sp.interrupt then
					break
				end

				if this.do_destroy then
					goto label_16_1
				end

				local spawn = E:create_entity(sp.entity)

				spawn.nav_path.pi = sp.pi

				if sp.random_subpath then
					spawn.nav_path.spi = sp.allowed_subpaths[math.random(1, #sp.allowed_subpaths)]
				else
					last_subpath = km.zmod(last_subpath + 1, #sp.allowed_subpaths)
					spawn.nav_path.spi = sp.allowed_subpaths[last_subpath]
				end

				spawn.nav_path.ni = sp.ni + sp.node_offset
				spawn.pos.x, spawn.pos.y = this.pos.x, this.pos.y + sp.pos_offset.y

				if sp.forced_waypoint_offset then
					spawn.motion.forced_waypoint = V.v(this.pos.x + sp.forced_waypoint_offset.x, this.pos.y + sp.forced_waypoint_offset.y)
				end

				spawn.render.sprites[1].name = "idle"
				spawn.unit.spawner_id = this.id

				queue_insert(store, spawn)

				local spawn_ts = store.tick_ts

				while store.tick_ts - spawn_ts < sp.cycle_time do
					if sp.interrupt then
						goto label_16_0
					end

					coroutine.yield()
				end
			end

			::label_16_0::

			U.y_wait(store, 1)
			U.y_animation_play(this, "close", nil, store.tick_ts)
		end

		coroutine.yield()

		::label_16_1::

		sp.interrupt = nil
	end
end

scripts.enemy_alien_breeder = {}

function scripts.enemy_alien_breeder.get_info(this)
	local min, max = 10, 20

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

function scripts.enemy_alien_breeder.insert(this, store, script)
	if not scripts.enemy_basic.insert(this, store, script) then
		return false
	end

	signal.emit("wave-notification", "icon", "enemy_alien_breeder")

	return true
end

function scripts.enemy_alien_breeder.update(this, store, script)
	local hugging = false
	local dead_when_hugging = false

	::label_19_0::

	while true do
		if this.health.dead then
			if dead_when_hugging then
				this.unit.death_animation = "death_hugging"
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
						goto label_19_0
					end

					this.vis.bans = bor(this.vis.bans, F_TWISTER, F_BLOCK)

					SU.stun_inc(blocker)

					this.health_bar.hidden = true
					hugging = true

					local damage_value = blocker.health.hp / (blocker.hero and 5 or 2.5)

					damage_value = km.clamp(1, blocker.health.hp_max, damage_value)

					local fh_offset = this.facehug_offsets[blocker.template_name]

					if not fh_offset and blocker.hero then
						fh_offset = this.facehug_offsets.hero_default
					end

					fh_offset = fh_offset or this.facehug_offsets.soldier_default

					local x_offset = (fh_offset.x + 3) * (this.pos.x < blocker.pos.x and -1 or 1)
					local y_offset = 3 + fh_offset.y
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

					U.set_destination(this, dest)
					U.animation_start(this, "jump", nil, store.tick_ts)

					while not this.motion.arrived do
						if this.health.dead then
							SU.stun_dec(blocker)

							goto label_19_0
						end

						U.walk(this, store.tick_length)
						coroutine.yield()
					end

					this.tween.disabled = true

					U.animation_start(this, "face_hug", nil, store.tick_ts, true)

					while not blocker.health.dead do
						if this.health.dead then
							SU.stun_dec(blocker)

							dead_when_hugging = true

							goto label_19_0
						end

						local d = E:create_entity("damage")

						d.value = damage_value
						d.source_id = this.id
						d.target_id = blocker.id
						d.damage_type = bor(DAMAGE_HOST, DAMAGE_TRUE)
						d.track_kills = this.track_kills ~= nil

						queue_damage(store, d)

						local ts = store.tick_ts

						while store.tick_ts - ts < 1 and not blocker.health.dead and not this.health.dead do
							coroutine.yield()
						end
					end

					SU.stun_dec(blocker)

					if #this.track_kills.killed > 0 and this.track_kills.killed[1] == blocker.id then
						queue_remove(store, this)

						if not table.contains(this.spawn_bans, blocker.template_name) then
							signal.emit("wave-notification", "icon", "enemy_alien_reaper")

							local e = E:create_entity("enemy_alien_reaper")

							e.nav_path.pi, e.nav_path.spi = this.nav_path.pi, this.nav_path.spi
							e.nav_path.ni = this.nav_path.ni + 2
							e.render.sprites[1].flip_x = this.render.sprites[1].flip_x
							e.enemy.gold = 0

							queue_insert(store, e)
						end

						return
					end

					this.vis.bans = band(this.vis.bans, bnot(F_TWISTER))
					this.vis.bans = band(this.vis.bans, bnot(F_BLOCK))
					this.health_bar.hidden = true
					hugging = false
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_shaman_necro = {}

function scripts.enemy_shaman_necro.update(this, store, script)
	local na = this.timed_attacks.list[1]
	local ok, blocker, ranged

	na.ts = store.tick_ts

	local function ready_to_cast()
		return store.tick_ts - na.ts > na.cooldown and this.enemy.can_do_magic
	end

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, true)
		else
			if ready_to_cast() then
				na.ts = store.tick_ts

				local dead_enemies = table.filter(store.entities, function(_, e)
					return e.enemy and e.health and e.health.dead and e.unit and not e.unit.hide_after_death and band(e.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_INSTAKILL, DAMAGE_DISINTEGRATE, DAMAGE_EXPLOSION, DAMAGE_FX_EXPLODE)) == 0 and band(e.vis.bans, F_ZOMBIE) == 0 and table.contains(na.allowed_templates, e.template_name) and U.is_inside_ellipse(e.pos, this.pos, na.max_range)
				end)

				if #dead_enemies == 0 then
					-- block empty
				else
					for _, dead in pairs(dead_enemies) do
						dead.vis.bans = bor(dead.vis.bans, F_ZOMBIE)
					end

					S:queue("EnemyHealing", {
						delay = fts(9)
					})
					U.animation_start(this, na.animation, nil, store.tick_ts, false)

					while store.tick_ts - na.ts < na.cast_time do
						if this.health.dead then
							goto label_20_0
						end

						coroutine.yield()
					end

					S:queue(na.sound)

					for _, dead in pairs(dead_enemies) do
						dead.health.delete_after = 0

						local e = E:create_entity("enemy_cannibal_zombie")

						e.nav_path.pi, e.nav_path.spi, e.nav_path.ni = dead.nav_path.pi, dead.nav_path.spi, dead.nav_path.ni
						e.render.sprites[1].name = "raise"
						e.render.sprites[1].flip_x = dead.render.sprites[1].flip_x

						queue_insert(store, e)
					end

					U.y_animation_wait(this)
				end
			end

			ok, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_cast()
			end)

			if not ok then
				-- block empty
			elseif blocker then
				if not SU.y_wait_for_blocker(store, this, blocker) then
					-- block empty
				else
					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							break
						end

						coroutine.yield()
					end
				end
			elseif ranged then
				while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 and not ready_to_cast() do
					if not SU.y_enemy_range_attacks(store, this, ranged) then
						break
					end

					coroutine.yield()
				end
			end
		end

		::label_20_0::

		coroutine.yield()
	end
end

scripts.enemy_cannibal_volcano = {}

function scripts.enemy_cannibal_volcano.update(this, store, script)
	local ok, blocker, ranged, action
	local cheer_count = 0
	local action_nodes = {
		[56] = "throw",
		[5] = "cheer",
		[43] = "cheer",
		[28] = "cheer"
	}

	local function ready_for_action()
		return action_nodes[this.nav_path.ni]
	end

	local function show_help_banner()
		local help = E:create_entity("fx")

		help.render.sprites[1].name = "volcano_help_banner"
		help.render.sprites[1].ts = store.tick_ts
		help.pos = V.v(this.pos.x, this.pos.y + 70)

		queue_insert(store, help)

		return help
	end

	local function show_throw_virgin()
		local e = E:create_entity("fx")

		e.render.sprites[1].name = "volcano_virgin_death"
		e.render.sprites[1].ts = store.tick_ts
		e.render.sprites[1].anchor.y = 0.15
		e.pos = V.vclone(this.pos)

		queue_insert(store, e)
	end

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			local e = E:create_entity("decal_volcano_virgin")

			e.pos = V.vclone(this.pos)
			this.phase = "princess_saved"

			queue_insert(store, e)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, true)
		else
			action = ready_for_action()

			if action == "cheer" then
				this.nav_path.ni = this.nav_path.ni + 1
				cheer_count = cheer_count + 1

				local cheer_cycles = 16
				local cheer_duration = fts(9)
				local scream_every = 6 * cheer_duration

				U.animation_start(this, "cheers", nil, store.tick_ts, true)
				U.y_wait(store, cheer_duration)

				for i = 1, cheer_count do
					S:queue(this.sound_events.scream)

					local help_banner = show_help_banner()

					if U.y_wait(store, scream_every, function()
						return this.health.dead or #this.enemy.blockers > 0
					end) then
						queue_remove(store, help_banner)

						goto label_24_0
					end
				end

				while cheer_cycles > this.render.sprites[1].runs do
					if this.health.dead or #this.enemy.blockers > 0 then
						break
					end

					coroutine.yield()
				end
			elseif action == "throw" then
				this.nav_path.ni = this.nav_path.ni + 1

				U.animation_start(this, "throw", nil, store.tick_ts, false)
				S:queue(this.sound_events.throw, {
					delay = fts(39)
				})
				U.y_wait(store, fts(9))
				show_help_banner()
				S:queue(this.sound_events.scream)
				U.y_wait(store, fts(33))
				show_throw_virgin()
				U.y_animation_wait(this)

				this.phase = "princess_thrown"

				U.y_animation_play(this, "lol", nil, store.tick_ts, 8)

				local dist = 25
				local eta = dist / this.motion.max_speed
				local fade_step = 255 / (eta / store.tick_length)

				U.animation_start(this, "away", false, store.tick_ts, true)
				U.set_destination(this, V.v(this.pos.x + dist, this.pos.y))

				this.health.hp = 0

				while not this.motion.arrived do
					U.walk(this, store.tick_length)

					this.render.sprites[1].alpha = km.clamp(0, 255, this.render.sprites[1].alpha - fade_step)

					coroutine.yield()
				end

				queue_remove(store, this)

				return
			end

			::label_24_0::

			ok, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_for_action()
			end)

			if not ok then
				-- block empty
			elseif not blocker or not SU.y_wait_for_blocker(store, this, blocker) then
				-- block empty
			else
				while SU.can_melee_blocker(store, this, blocker) do
					if not SU.y_enemy_melee_attacks(store, this, blocker) then
						break
					end

					coroutine.yield()
				end
			end
		end

		coroutine.yield()
	end
end

scripts.enemy_nightscale = {}

function scripts.enemy_nightscale.update(this, store, script)
	local terrain_type
	local h = this.hidden
	local hide_times = 0

	local function ready_to_hide()
		return hide_times < h.max_times and this.enemy.can_do_magic and not this.unit.is_stunned and terrain_type == TERRAIN_LAND and this.health.hp / this.health.hp_max <= h.trigger_health_factor and P:nodes_to_defend_point(this.nav_path) > h.nodeslimit
	end

	::label_30_0::

	while true do
		if this.cliff then
			terrain_type = SU.enemy_cliff_change(store, this)
		end

		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, true)
			coroutine.yield()
		else
			if ready_to_hide() then
				hide_times = hide_times + 1

				U.unblock_all(store, this)

				this.vis.bans = bor(F_BLOCK, F_RANGED, F_BLOOD, F_TWISTER)

				S:queue(this.sound_events.hide)
				U.y_animation_play(this, "hide", nil, store.tick_ts)

				this.render.sprites[1].alpha = 40
				h.ts = store.tick_ts

				while store.tick_ts - h.ts < h.duration and not this.health.dead and this.enemy.can_do_magic and P:nodes_to_defend_point(this.nav_path) > h.nodeslimit do
					if this.unit.is_stunned then
						U.animation_start(this, "idle", nil, store.tick_ts, true)
						coroutine.yield()
					else
						SU.y_enemy_walk_step(store, this)
					end
				end

				this.render.sprites[1].alpha = 255
				this.vis.bans = 0
			end

			local ignore_soldiers = terrain_type == TERRAIN_CLIFF
			local ok, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, ignore_soldiers, function(store, this)
				return ready_to_hide()
			end)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_30_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_hide() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
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

scripts.enemy_darter = {}

function scripts.enemy_darter.update(this, store, script)
	local terrain_type
	local b = this.blink

	b.ts = store.tick_ts

	local last_blink_hp = this.health.hp

	local function ready_to_blink()
		if this.enemy.can_do_magic and terrain_type == TERRAIN_LAND and last_blink_hp ~= this.health.hp and store.tick_ts - b.ts > b.cooldown and P:nodes_to_defend_point(this.nav_path) > b.nodeslimit and P:get_end_node(this.nav_path.pi) - this.nav_path.ni > b.nodeslimit_conn then
			return true
		else
			last_blink_hp = this.health.hp

			return false
		end
	end

	::label_33_0::

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
			if ready_to_blink() then
				b.ts = store.tick_ts

				U.unblock_all(store, this)

				this.vis.bans = bor(F_ALL)
				this.render.sprites[1].hidden = true
				this.health_bar.hidden = true

				SU.hide_modifiers(store, this, true)
				SU.hide_auras(store, this, true)
				S:queue(this.sound_events.blink)

				local fx = E:create_entity(b.fx)

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)

				this.nav_path.ni = this.nav_path.ni + math.random(b.nodes_offset_min, b.nodes_offset_max)
				this.nav_path.ni = math.min(this.nav_path.ni, P:get_end_node(this.nav_path.pi) - b.nodeslimit_conn)

				local npos = P:node_pos(this.nav_path)

				this.pos.x, this.pos.y = npos.x, npos.y

				U.y_wait(store, b.travel_time)
				S:queue(this.sound_events.blink)

				local fx = E:create_entity(b.fx)

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y - 1
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)

				this.render.sprites[1].hidden = false
				this.health_bar.hidden = false
				this.vis.bans = 0

				SU.show_modifiers(store, this, true)
				SU.show_auras(store, this, true)
			end

			local ignore_soldiers = terrain_type == TERRAIN_CLIFF
			local ok, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, ignore_soldiers, function(store, this)
				return ready_to_blink()
			end)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_33_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_blink() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_33_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_savant = {}

function scripts.enemy_savant.update(this, store, script)
	local pa = this.timed_attacks.list[1]

	pa.cooldown = math.random(pa.min_cooldown, pa.max_cooldown)

	local ok, blocker, ranged
	local cg = store.count_groups[pa.count_group_type]

	pa.ts = store.tick_ts

	local function ready_to_portal()
		return store.tick_ts - pa.ts > pa.cooldown and this.enemy.can_do_magic and (not cg[pa.count_group_name] or cg[pa.count_group_name] < pa.count_group_max) and P:nodes_to_defend_point(this.nav_path) > pa.nodes_limit and P:is_node_valid(this.nav_path.pi, this.nav_path.ni + pa.node_offset + 1)
	end

	::label_36_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_portal() then
				local pi, spi, ni = this.nav_path.pi, this.nav_path.spi, this.nav_path.ni
				local path = P:path(pi, 1)

				ni = ni + pa.node_offset

				local npos = P:node_pos(pi, 1, ni)

				S:queue(pa.sound)
				U.y_animation_play(this, pa.animations[1], nil, store.tick_ts)

				local portal = E:create_entity(pa.entity)

				portal.pos.x, portal.pos.y = npos.x, npos.y
				portal.portal.spawner_id = this.id
				portal.portal.pi = pi
				portal.portal.spi = 1
				portal.portal.ni = ni
				portal.portal.count_group_name = pa.count_group_name
				portal.portal.count_group_type = pa.count_group_type
				portal.portal.count_group_max = pa.count_group_max
				portal.portal.finished = false

				queue_insert(store, portal)
				U.animation_start(this, pa.animations[2], npos.x < this.pos.x, store.tick_ts, true)

				while not portal.portal.finished and #this.enemy.blockers == 0 and this.enemy.can_do_magic and not this.health.dead do
					coroutine.yield()
				end

				portal.portal.finished = true

				U.y_animation_play(this, pa.animations[3], nil, store.tick_ts)

				pa.ts = store.tick_ts
			end

			ok, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_portal()
			end)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_36_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_36_0
						end

						coroutine.yield()
					end
				elseif ranged then
					while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							goto label_36_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.savant_portal = {}

function scripts.savant_portal.update(this, store, script)
	local p = this.portal
	local pi = p.pi
	local spi = 1
	local ni, spawn_ts
	local cg = store.count_groups[p.count_group_type]
	local count = 0
	local spawner = store.entities[p.spawner_id]
	local spawn_name, spawn, fx

	p.ts = store.tick_ts

	U.y_animation_play(this, "start", nil, store.tick_ts, 1)
	S:queue(this.sound_events.loop)
	U.animation_start(this, "loop", nil, store.tick_ts, true)

	while store.tick_ts - p.ts < p.duration and count < p.max_count and not p.finished and spawner and not spawner.health.dead do
		if cg[p.count_group_name] and cg[p.count_group_name] >= p.count_group_max then
			coroutine.yield()
		else
			for _, ep in ipairs(p.entities) do
				if math.random() <= ep[1] then
					spawn_name = ep[2]

					break
				end
			end

			spawn = E:create_entity(spawn_name)
			spi = km.zmod(spi + 1, 3)
			ni = p.ni + math.random(p.node_var[1], p.node_var[2])
			spawn.nav_path.pi, spawn.nav_path.spi, spawn.nav_path.ni = pi, spi, ni
			spawn.pos = P:node_pos(spawn.nav_path)
			spawn.enemy.gold = 0
			spawn.unit.spawner_id = this.id

			E:add_comps(spawn, "count_group")

			spawn.count_group.name = p.count_group_name
			spawn.count_group.type = p.count_group_type

			queue_insert(store, spawn)
			S:queue(this.sound_events.spawn)

			fx = E:create_entity(p.spawn_fx)
			fx.pos.x, fx.pos.y = spawn.pos.x, spawn.pos.y - 1
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)

			spawn_ts = store.tick_ts

			while store.tick_ts - spawn_ts < p.cycle_time and not p.finished do
				coroutine.yield()
			end
		end

		spawner = store.entities[p.spawner_id]
	end

	S:stop(this.sound_events.loop)

	p.finished = true

	U.y_animation_play(this, "end", nil, store.tick_ts, 1)
	queue_remove(store, this)
end

scripts.enemy_quetzal = {}

function scripts.enemy_quetzal.update(this, store, script)
	local ta = this.timed_attacks.list[1]

	ta.ts = store.tick_ts
	ta.cooldown = U.frandom(ta.min_cooldown, ta.max_cooldown)

	local eggs_count = 0

	local function ready_to_lay()
		return store.tick_ts - ta.ts > ta.cooldown and eggs_count < ta.max_count
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

			SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_lay()
			end)
		end
	end
end

scripts.enemy_sniper = {}

function scripts.enemy_sniper.insert(this, store)
	local result = scripts.enemy_basic.insert(this, store)

	if result then
		local a = this.ranged.attacks[1]

		a.max_range = a.max_range + math.random(-a.range_var, a.range_var)
	end

	return result
end

function scripts.enemy_sniper.update(this, store)
	::label_44_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_44_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_44_0
						end

						coroutine.yield()
					end
				elseif ranged then
					local b
					local ra = this.ranged.attacks[1]
					local an, af, aidx = U.animation_name_facing_point(this, ra.animations[1], ranged.pos)

					U.y_animation_play(this, an, af, store.tick_ts, 1)

					::label_44_1::

					if ranged and ranged._sniper_id == this.id then
						ranged._sniper_id = nil
					end

					targets = U.find_soldiers_in_range(store.entities, this.pos, ra.min_range, ra.max_range, ra.vis_flags, ra.vis_bans)

					if not targets then
						-- block empty
					else
						table.sort(targets, function(e1, e2)
							return not e1._sniper_id and e2._sniper_id
						end)

						ranged = targets[1]

						if not ranged._sniper_id then
							ranged._sniper_id = this.id
						end

						while store.tick_ts - ra.ts <= ra.cooldown do
							coroutine.yield()

							if this.health.dead or #this.enemy.blockers ~= 0 then
								goto label_44_2
							end

							if not SU.can_range_soldier(store, this, ranged) then
								goto label_44_1
							end
						end

						an, af, aidx = U.animation_name_facing_point(this, ra.animations[2], ranged.pos)

						U.animation_start(this, an, af, store.tick_ts, false)
						U.y_wait(store, ra.shoot_time)

						b = E:create_entity(ra.bullet)
						b.pos.x = this.pos.x + (af and -1 or 1) * ra.bullet_start_offset[aidx].x
						b.pos.y = this.pos.y + ra.bullet_start_offset[aidx].y
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = V.v(ranged.pos.x + ranged.unit.hit_offset.x, ranged.pos.y + ranged.unit.hit_offset.y)
						b.bullet.source_id = this.id
						b.bullet.target_id = ranged.id

						queue_insert(store, b)

						ra.ts = store.tick_ts

						while not U.animation_finished(this) do
							coroutine.yield()
						end

						goto label_44_1
					end

					::label_44_2::

					if ranged and ranged._sniper_id == this.id then
						ranged._sniper_id = nil
					end

					an, af = U.animation_name_facing_point(this, ra.animations[3], ranged.pos)

					U.y_animation_play(this, an, af, store.tick_ts, 1)
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_blacksurge = {}

function scripts.enemy_blacksurge.update(this, store, script)
	local terrain_type
	local ta = this.timed_attacks.list[1]
	local h = this.hidden

	h.ts = -h.cooldown

	local function ready_to_hide()
		return store.tick_ts - h.ts > h.cooldown and terrain_type == TERRAIN_LAND and this.health.hp > 0 and this.health.hp / this.health.hp_max <= h.trigger_health_factor and P:nodes_to_defend_point(this.nav_path) > h.nodeslimit
	end

	local function ready_to_curse()
		if not (store.tick_ts - ta.ts > ta.cooldown) or terrain_type ~= TERRAIN_LAND or not this.enemy.can_do_magic then
			return false
		end

		local towers = table.filter(store.entities, function(_, e)
			return not e.tower_holder and e.tower and e.tower.can_be_mod and not e.tower.blocked and 
			(not e.vis or band(e.vis.flags, ta.vis_bans) == 0 and band(e.vis.bans, ta.vis_flags) == 0) and U.is_inside_ellipse(e.pos, this.pos, ta.range)
		end)

		return #towers > 0
	end

	local water_trail = E:create_entity("ps_water_trail")

	water_trail.particle_system.track_id = this.id

	queue_insert(store, water_trail)

	::label_46_0::
	if this._placed_from_tunnel then
		this._placed_from_tunnel = nil
		local start = string.find(this.render.sprites[1].prefix, h.sprite_suffix, 1, true)
		if start then
			local orig_prefix = string.sub(this.render.sprites[1].prefix, 1 , start - 1)
			U.animation_start(this, "show", nil, store.tick_ts, 1)
			while not U.animation_finished(this) do
				coroutine.yield()
			end
			this.vis.bans = 0
			this.health.immune_to = DAMAGE_NONE
			this.render.sprites[1].prefix = orig_prefix
		end
	end

	while true do
		if this.water then
			terrain_type = SU.enemy_water_change(store, this)
			water_trail.particle_system.emit = terrain_type == TERRAIN_WATER
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
			if ready_to_curse() then
				ta.ts = store.tick_ts

				U.animation_start(this, ta.animation, nil, store.tick_ts, 1)

				while store.tick_ts - ta.ts < ta.shoot_time do
					if this.health.dead then
						goto label_46_0
					end

					if this.unit.is_stunned then
						goto label_46_0
					end

					coroutine.yield()
				end

				local towers = table.filter(store.entities, function(_, e)
					return not e.tower_holder and e.tower and e.tower.can_be_mod and not e.tower.blocked and 
					(not e.vis or band(e.vis.flags, ta.vis_bans) == 0 and band(e.vis.bans, ta.vis_flags) == 0) and U.is_inside_ellipse(e.pos, this.pos, ta.range)
				end)

				for i, tower in ipairs(towers) do
					if i > ta.max_count then
						break
					end

					local m = E:create_entity(ta.mod)

					m.modifier.target_id = tower.id
					m.modifier.source_id = this.id
					m.pos = tower.pos

					queue_insert(store, m)
				end

				if #towers > 0 then
					S:queue(ta.sound)
				end

				while not U.animation_finished(this) do
					coroutine.yield()
				end
			end

			if ready_to_hide() then
				SU.remove_modifiers(store, this)
				U.unblock_all(store, this)

				this.vis.bans = h.vis_bans
				this.health.immune_to = bnot(bor(DAMAGE_INSTAKILL, DAMAGE_EAT))

				local orig_prefix = this.render.sprites[1].prefix

				this.render.sprites[1].prefix = this.render.sprites[1].prefix .. h.sprite_suffix

				U.animation_start(this, "hide", nil, store.tick_ts, 1)

				while not U.animation_finished(this) do
					if this.health.dead then
						goto label_46_1
					end

					coroutine.yield()
				end

				h.ts = store.tick_ts

				while store.tick_ts - h.ts < h.duration and P:nodes_to_defend_point(this.nav_path) > h.nodeslimit do
					if band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK) ~= TERRAIN_LAND then
						goto label_46_1
					end

					if this.health.dead or this.health.hp <= 0 then
						goto label_46_1
					end

					if this.unit.is_stunned then
						coroutine.yield()
					else
						if store.tick_ts - h.ts < this.regen.duration and store.tick_ts - this.regen.ts > this.regen.cooldown then
							this.regen.ts = store.tick_ts
							this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + this.regen.health)
						end

						SU.y_enemy_walk_step(store, this)
					end
				end

				U.animation_start(this, "show", nil, store.tick_ts, 1)

				while not U.animation_finished(this) do
					coroutine.yield()
				end

				::label_46_1::

				this.vis.bans = 0
				this.health.immune_to = DAMAGE_NONE
				this.render.sprites[1].prefix = orig_prefix

				goto label_46_0
			end

			local ignore_soldiers = terrain_type == TERRAIN_WATER
			local ok, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, ignore_soldiers, function(store, this)
				return ready_to_hide() or ready_to_curse()
			end)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_46_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_hide() and not ready_to_curse() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_46_0
						end

						coroutine.yield()
					end
				elseif ranged then
					while SU.can_range_soldier(store, this, ranged) and not ready_to_hide() and not ready_to_curse() do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							goto label_46_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.enemy_bluegale = {}

function scripts.enemy_bluegale.update(this, store, script)
	local terrain_type
	local sa = this.timed_attacks.list[1]
	local ok, blocker, ranged, ignore_soldiers

	local function ready_to_cast()
		return store.tick_ts - sa.ts > sa.cooldown and this.enemy.can_do_magic and terrain_type == TERRAIN_LAND
	end

	sa.ts = store.tick_ts

	local water_trail = E:create_entity("ps_water_trail")

	water_trail.particle_system.track_id = this.id

	queue_insert(store, water_trail)

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
			if ready_to_cast() then
				sa.ts = store.tick_ts - sa.cooldown + 0.5

				local pi, spi, ni = this.nav_path.pi, this.nav_path.spi, this.nav_path.ni
				local path = P:path(pi, 1)

				ni = ni + math.random(sa.node_random_min, sa.node_random_max)

				local npos = P:node_pos(pi, 1, ni)

				if not P:is_node_valid(pi, ni) or GR:cell_is(npos.x, npos.y, TERRAIN_WATER) or ni + sa.nodes_limit >= #path then
					log.paranoid("bluegale - cannot cast: node is not valid")
				else
					npos.x = npos.x + math.random(-30, 30)
					npos.y = npos.y + math.random(-50, 80)
					sa.ts = store.tick_ts

					S:queue(sa.sound)
					U.animation_start(this, sa.animation, nil, store.tick_ts, false)

					while store.tick_ts - sa.ts < sa.shoot_time do
						if this.health.dead then
							goto label_52_0
						end

						coroutine.yield()
					end

					local e = E:create_entity(sa.bullet)

					e.aura.source_id = this.id
					e.pos = npos

					queue_insert(store, e)
					U.y_animation_wait(this)
				end
			end

			ignore_soldiers = terrain_type == TERRAIN_WATER
			water_trail.particle_system.emit = ignore_soldiers
			ok, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, ignore_soldiers, function(this, store)
				return ready_to_cast()
			end)

			if not ok then
				-- block empty
			elseif blocker then
				if not SU.y_wait_for_blocker(store, this, blocker) then
					-- block empty
				else
					while SU.can_melee_blocker(store, this, blocker) and not ready_to_cast() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							break
						end

						coroutine.yield()
					end
				end
			elseif ranged then
				while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 and not ready_to_cast() do
					if not SU.y_enemy_range_attacks(store, this, ranged) then
						break
					end

					coroutine.yield()
				end
			end
		end

		::label_52_0::

		coroutine.yield()
	end
end

scripts.enemy_deviltide_shark = {}

function scripts.enemy_deviltide_shark.get_info(this)
	local t = E:get_template("enemy_deviltide")

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = t.melee.attacks[1].damage_min,
		damage_max = t.melee.attacks[1].damage_max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.enemy_deviltide_shark.update(this, store, script)
	local n = this.nav_path
	local water_trail = E:create_entity("ps_water_trail")

	water_trail.particle_system.track_id = this.id

	queue_insert(store, water_trail)

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			water_trail.particle_system.emit = false

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local next, new = P:next_entity_node(this, store.tick_length)

			if not next then
				log.warning("enemy %s ran out of nodes to walk", this.id)
				coroutine.yield()

				return
			end

			U.set_destination(this, next)

			local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

			U.animation_start(this, an, af, store.tick_ts, -1)
			U.walk(this, store.tick_length)
			coroutine.yield()

			this.motion.speed.x, this.motion.speed.y = 0, 0

			local npos = P:node_pos(n.pi, n.spi, n.ni + 6)

			if band(GR:cell_type(npos.x, npos.y), TERRAIN_LAND) ~= 0 then
				this.vis.flags = F_NONE
				this.vis.bans = F_ALL
				this.health.immune_to = DAMAGE_ALL

				SU.remove_modifiers(store, this)

				this.health_bar.hidden = true
				this.ui.can_click = false
				this.ui.can_select = false
				water_trail.particle_system.emit = false

				S:queue(this.sound_events.deploy)
				U.animation_start(this, "deploy", nil, store.tick_ts, 1)

				while store.tick_ts - this.render.sprites[1].ts < this.payload_time do
					coroutine.yield()
				end

				local e = E:create_entity(this.payload)

				e.pos.x, e.pos.y = V.add(this.pos.x, this.pos.y, 71, 4)
				e.nav_path.pi = this.nav_path.pi
				e.nav_path.spi = this.nav_path.spi
				e.nav_path.ni = this.nav_path.ni + 11
				e.health.hp = this.health.hp

				queue_insert(store, e)

				while not U.animation_finished(this) do
					coroutine.yield()
				end

				queue_remove(store, this)

				return
			end
		end
	end
end

scripts.phantom_warrior_aura = {}

function scripts.phantom_warrior_aura.update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local last_ts = store.tick_ts
	local source = store.entities[a.source_id]

	if not source then
		queue_remove(store, this)

		return
	end

	this.pos = source.pos

	while true do
		source = store.entities[a.source_id]

		if not source or source.health.dead then
			queue_remove(store, this)

			return
		end

		if not source.enemy.can_do_magic then
			-- block empty
		elseif store.tick_ts - last_ts >= a.cycle_time then
			last_ts = store.tick_ts

			local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans, function(e)
				return not table.contains(a.banned_templates, e.template_name)
			end)

			if targets then
				for _, target in pairs(targets) do
					local d = E:create_entity("damage")

					d.damage_type = a.damage_type
					d.value = a.damage_max * (target.hero and a.hero_damage_factor or 1)
					d.target_id = target.id
					d.source_id = this.id

					queue_damage(store, d)

					source.aura_applied = true
				end
			end
		end

		coroutine.yield()
	end
end

scripts.enemy_headless_horseman = {}

function scripts.enemy_headless_horseman.update(this, store)
	this.lifespan.ts = store.tick_ts

	local ra = this.ranged.attacks[1]
	local flip = this.idle_flip
	local bans = this.vis.bans

	if this.custom_spawn_data and this.custom_spawn_data.lifespan then
		this.lifespan.duration = this.custom_spawn_data.lifespan
	end

	this.health_bar.hidden = true
	this.vis.bans = F_ALL

	U.y_animation_play(this, "rise", this.pos.x > this.motion.forced_waypoint.x, store.tick_ts, 1)

	while SU.y_enemy_walk_step(store, this) do
		-- block empty
	end

	this.vis.bans = bans
	this.health_bar.hidden = nil

	::label_59_0::

	while true do
		if this.health.dead then
			local delay = fts(4)
			local off_x = 25

			for i = 1, 3 do
				local e = E:create_entity("fx_coin_jump")

				e.render.sprites[1].ts = store.tick_ts + delay * (i - 1)
				e.pos.x = this.pos.x + (i - 1) * off_x * (this.render.sprites[1].flip_x and -1 or 1)
				e.pos.y = this.pos.y
				e.sound_events.insert_args = {
					delay = delay * (i - 1)
				}

				queue_insert(store, e)
			end

			SU.y_enemy_death(store, this)

			return
		end

		if store.tick_ts - this.lifespan.ts > this.lifespan.duration then
			this.health_bar.hidden = true
			this.vis.bans = F_ALL
			this.vis.flags = F_NONE

			U.unblock_all(store, this)
			SU.remove_modifiers(store, this)
			U.y_animation_play(this, "death", nil, store.tick_ts, 1)
			queue_remove(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local blocker = U.get_blocker(store, this)

			if blocker then
				if not SU.y_wait_for_blocker(store, this, blocker) then
					goto label_59_0
				end

				while SU.can_melee_blocker(store, this, blocker) do
					if not SU.y_enemy_melee_attacks(store, this, blocker) then
						goto label_59_0
					end

					coroutine.yield()
				end
			else
				local ranged = U.find_nearest_soldier(store.entities, this.pos, ra.min_range, ra.max_range, ra.vis_flags, ra.vis_bans)

				if ranged then
					while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							goto label_59_0
						end

						coroutine.yield()
					end
				end
			end

			if store.tick_ts - flip.ts > flip.cooldown then
				flip.ts = store.tick_ts

				local new_pos = V.vclone(this.pos)

				flip.last_dir = -1 * flip.last_dir
				new_pos.x = new_pos.x + flip.last_dir * flip.walk_dist
				this.motion.forced_waypoint = new_pos

				local bans = this.vis.bans

				this.vis.bans = F_ALL

				while SU.y_enemy_walk_step(store, this) do
					-- block empty
				end

				this.vis.bans = bans
			end

			U.animation_start(this, "idle", nil, store.tick_ts, true)
			coroutine.yield()
		end
	end
end

scripts.headless_horseman_spawner_aura = {}

function scripts.headless_horseman_spawner_aura.update(this, store)
	local source, sd, pi_idx

	source = store.entities[this.aura.source_id]

	if not source or source.health.dead then
		-- block empty
	else
		sd = source.custom_spawn_data

		if not sd or not sd.s_paths or not sd.s_list then
			log.debug("headless horseman spawner aura data not found or has errors for id:%s. removing spawner aura...", source.id)
		else
			this.aura.ts = store.tick_ts
			pi_idx = 1

			U.y_wait(store, 2)

			while true do
				source = store.entities[this.aura.source_id]

				if not source or source.health.dead then
					break
				end

				local pi = sd.s_paths[pi_idx]

				pi_idx = km.zmod(pi_idx + 1, #sd.s_paths)

				local spawn_pos = P:node_pos(source.nav_path)
				local nodes = P:nearest_nodes(spawn_pos.x, spawn_pos.y, {
					pi
				})
				local ni = nodes[1][3]
				local spawn_queue = {}

				for _, item in pairs(sd.s_list) do
					local qty, name = unpack(item)

					for i = 1, qty do
						table.insert(spawn_queue, {
							U.frandom(0, sd.s_delay),
							name,
							pi,
							math.random(1, 3),
							ni
						})
					end
				end

				table.sort(spawn_queue, function(e1, e2)
					return e1[1] < e2[1]
				end)

				local start_ts = store.tick_ts

				for i = 1, #spawn_queue do
					local delay, name, pi, spi, ni = unpack(spawn_queue[i])
					local ts = store.tick_ts - start_ts

					if ts < delay then
						U.y_wait(store, delay - ts)
					end

					local e = E:create_entity(name)

					e.nav_path.pi = pi
					e.nav_path.spi = spi
					e.nav_path.ni = ni
					e.render.sprites[1].name = "raise"
					e.enemy.gold = 0

					queue_insert(store, e)
				end

				U.y_wait(store, this.spawner.cycle_time - (store.tick_ts - start_ts))
			end
		end
	end

	queue_remove(store, this)
end

scripts.soldier_mecha = {}

function scripts.soldier_mecha.insert(this, store, script)
	this.attacks.order = U.attack_order(this.attacks.list)
	this.idle_flip.ts = store.tick_ts

	return true
end

function scripts.soldier_mecha.remove(this, store, script)
	S:stop("MechWalk")
	S:stop("MechSteam")

	return true
end

function scripts.soldier_mecha.update(this, store, script)
	local ab = this.attacks.list[1]
	local am = this.attacks.list[2]
	local ao = this.attacks.list[3]
	local pow_m = this.powers.missile
	local pow_o = this.powers.oil
	local ab_side = 1

	::label_64_0::

	while true do
		local r = this.nav_rally

		while r.new do
			r.new = false

			U.set_destination(this, r.pos)

			local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

			U.animation_start(this, an, af, store.tick_ts, true, 1)
			S:queue("MechWalk")

			local ts = store.tick_ts

			while not this.motion.arrived and not r.new do
				if store.tick_ts - ts > 1 then
					ts = store.tick_ts

					S:queue("MechSteam")
				end

				U.walk(this, store.tick_length)
				coroutine.yield()

				this.motion.speed.x, this.motion.speed.y = 0, 0
			end

			S:stop("MechWalk")
			coroutine.yield()
		end

		if this.owner.tower.can_do_magic and pow_o.level > 0 then
			if pow_o.changed then
				pow_o.changed = nil

				if not ao.ts then
					ao.ts = store.tick_ts
				end
			end

			if store.tick_ts - ao.ts > ao.cooldown then
				local _, targets = U.find_foremost_enemy(store.entities, this.pos, ao.min_range, ao.max_range, true, ao.vis_flags, ao.vis_bans)

				if not targets then
					-- block empty
				else
					local target = table.random(targets)

					ao.ts = store.tick_ts

					local an, af = U.animation_name_facing_point(this, ao.animation, target.pos)

					U.animation_start(this, an, af, store.tick_ts, false)
					U.y_wait(store, ao.hit_time)

					local b = E:create_entity(ao.bullet)

					b.pos.x = this.pos.x + (af and -1 or 1) * ao.start_offset.x
					b.pos.y = this.pos.y + ao.start_offset.y
					b.aura.level = pow_o.level
					b.aura.ts = store.tick_ts
					b.aura.source_id = this.id
					b.render.sprites[1].ts = store.tick_ts

					queue_insert(store, b)

					while not U.animation_finished(this) do
						coroutine.yield()
					end

					goto label_64_0
				end
			end
		end

		if this.owner.tower.can_do_magic and pow_m.level > 0 then
			if pow_m.changed then
				pow_m.changed = nil

				if not am.ts then
					am.ts = store.tick_ts
				end
			end

			if store.tick_ts - am.ts > am.cooldown then
				local _, targets = U.find_foremost_enemy(store.entities, this.pos, am.min_range, am.max_range, false, am.vis_flags, am.vis_bans)

				if not targets then
					-- block empty
				else
					local target = table.random(targets)

					am.ts = store.tick_ts

					local an, af = U.animation_name_facing_point(this, am.animation_pre, target.pos)

					U.animation_start(this, an, af, store.tick_ts, false, 1)

					while not U.animation_finished(this) do
						coroutine.yield()
					end

					local burst_count = am.burst + pow_m.level * am.burst_inc
					local fire_loops = burst_count / #am.hit_times

					for i = 1, fire_loops do
						local an, af = U.animation_name_facing_point(this, am.animation, target.pos)

						U.animation_start(this, an, af, store.tick_ts, false, 1)

						for hi, ht in ipairs(am.hit_times) do
							while ht > store.tick_ts - this.render.sprites[1].ts do
								if this.nav_rally.new then
									goto label_64_1
								end

								coroutine.yield()
							end

							local b = E:create_entity(am.bullet)

							b.pos.x = this.pos.x + (af and -1 or 1) * am.start_offsets[km.zmod(hi, #am.start_offsets)].x
							b.pos.y = this.pos.y + am.start_offsets[hi].y
							b.bullet.level = pow_m.level
							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = V.v(b.pos.x + (af and -1 or 1) * am.launch_vector.x, b.pos.y + am.launch_vector.y)
							b.bullet.target_id = target.id

							queue_insert(store, b)

							_, targets = U.find_foremost_enemy(store.entities, this.pos, am.min_range, am.max_range, false, am.vis_flags, am.vis_bans)

							if not targets then
								goto label_64_1
							end

							target = table.random(targets)
						end

						while not U.animation_finished(this) do
							coroutine.yield()
						end
					end

					::label_64_1::

					U.animation_start(this, am.animation_post, nil, store.tick_ts, false, 1)

					while not U.animation_finished(this) do
						coroutine.yield()
					end

					am.ts = store.tick_ts

					goto label_64_0
				end
			end
		end

		if store.tick_ts - ab.ts > ab.cooldown then
			local _, targets = U.find_foremost_enemy(store.entities, this.pos, ab.min_range, ab.max_range, ab.node_prediction, ab.vis_flags, ab.vis_bans)

			if not targets then
				-- block empty
			else
				local target = table.random(targets)
				local pred_pos = P:predict_enemy_pos(target, ab.node_prediction)

				ab.ts = store.tick_ts
				ab_side = km.zmod(ab_side + 1, 2)

				local an, af = U.animation_name_facing_point(this, ab.animations[ab_side], target.pos)

				U.animation_start(this, an, af, store.tick_ts, false, 1)
				U.y_wait(store, ab.hit_times[ab_side])

				local b = E:create_entity(ab.bullet)

				b.bullet.damage_factor = this.owner.tower.damage_factor
				b.pos.x = this.pos.x + (af and -1 or 1) * ab.start_offsets[ab_side].x
				b.pos.y = this.pos.y + ab.start_offsets[ab_side].y
				b.bullet.from = V.vclone(b.pos)
				b.bullet.to = pred_pos
				b.bullet.source_id = this.id

				queue_insert(store, b)

				while not U.animation_finished(this) do
					if this.nav_rally.new then
						break
					end

					coroutine.yield()
				end

				goto label_64_0
			end
		end

		if store.tick_ts - this.idle_flip.ts > this.idle_flip.cooldown then
			this.idle_flip.ts = store.tick_ts

			local new_pos = V.vclone(this.pos)

			this.idle_flip.last_dir = -1 * this.idle_flip.last_dir
			new_pos.x = new_pos.x + this.idle_flip.last_dir * this.idle_flip.walk_dist

			if not GR:cell_is(new_pos.x, new_pos.y, TERRAIN_WATER) then
				r.new = true
				r.pos = new_pos

				goto label_64_0
			end
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true, 1)
		coroutine.yield()
	end
end

scripts.tower_totem = {}

function scripts.tower_totem.insert(this, store, script)
	return true
end

function scripts.tower_totem.remove(this, store, script)
	return true
end

function scripts.tower_totem.update(this, store, script)
	local last_target_pos = V.v(0, 0)
	local shots_count = 0
	local shooter_sprite_ids = {
		3,
		4
	}
	local a = this.attacks
	local aa = this.attacks.list[1]
	local eyes_sids = {
		8,
		7
	}
	local attack_ids = {
		2,
		3
	}
	local pow_p = this.powers.poison

	SU.towers_swaped(store, this, this.attacks.list)
	aa.ts = store.tick_ts

	while true do
		if this.tower.blocked then
			-- block empty
		else
			for i, name in ipairs({
				"weakness",
				"silence"
			}) do
				local pow = this.powers[name]
				local ta = this.attacks.list[attack_ids[i]]

				if pow.changed then
					pow.changed = nil
					this.render.sprites[eyes_sids[i]].hidden = false

					if pow.level == 1 then
						this.render.sprites[eyes_sids[i]].ts = store.tick_ts
						ta.ts = store.tick_ts
					end
				end

				if pow.level < 1 or store.tick_ts - ta.ts < ta.cooldown or not this.tower.can_do_magic then
					-- block empty
				else
					local enemy, enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, ta.vis_flags, ta.vis_bans)
					if enemy then
						local totems = table.filter(store.entities, function(_, e)
							return e.template_name == this.attacks.list[i + 1].bullet
						end)
						if totems and #totems > 0 then
							for j = #enemies, 1, -1 do
								local e = enemies[j]
								for _, t in ipairs(totems) do
									if V.dist(e.pos.x, e.pos.y, t.pos.x, t.pos.y) <= 125 then
										table.remove(enemies, j)
										break
									end
								end
							end
						end
						if #enemies > 0 then
							enemy = enemies[1]
						else
							enemy = nil
						end
					end

					if not enemy then
						-- block empty
					else
						ta.ts = store.tick_ts
						this.render.sprites[eyes_sids[i]].ts = store.tick_ts

						local node_offset = math.random(-4, 8)
						local totem_node = enemy.nav_path.ni

						if P:is_node_valid(enemy.nav_path.pi, enemy.nav_path.ni + node_offset) then
							totem_node = totem_node + node_offset
						end

						local totem_pos = P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi, totem_node)
						local b = E:create_entity(ta.bullet)

						b.pos.x, b.pos.y = totem_pos.x, totem_pos.y
						b.aura.level = pow.level
						b.aura.ts = store.tick_ts
						b.aura.source_id = this.id
						b.render.sprites[1].ts = store.tick_ts
						b.render.sprites[2].ts = store.tick_ts
						b.render.sprites[3].ts = store.tick_ts

						queue_insert(store, b)
					end
				end
			end

			if pow_p.changed then
				pow_p.changed = nil
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
					shots_count = shots_count + 1
					last_target_pos.x, last_target_pos.y = enemy.pos.x, enemy.pos.y

					local shooter_idx = shots_count % 2 + 1
					local shooter_sid = shooter_sprite_ids[shooter_idx]
					local start_offset = aa.bullet_start_offset[shooter_idx]
					local an, af = U.animation_name_facing_point(this, aa.animation, enemy.pos, shooter_sid, start_offset)

					U.animation_start(this, an, af, store.tick_ts, 1, shooter_sid)

					while store.tick_ts - aa.ts < aa.shoot_time do
						coroutine.yield()
					end

					local b1 = E:create_entity(aa.bullet)

					b1.pos.x, b1.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
					b1.bullet.damage_factor = this.tower.damage_factor
					b1.bullet.from = V.vclone(b1.pos)
					b1.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
					b1.bullet.target_id = enemy.id
					if pow_p.level > 0 then
						b1.bullet.mod = pow_p.mod
						b1.bullet.level = pow_p.level
					end

					queue_insert(store, b1)

					local u = UP:get_upgrade("archer_twin_shot")

					if u and math.random() < u.chance then
						b2 = E:clone_entity(b1)
						b2.bullet.flight_time = b2.bullet.flight_time - 1 / FPS

						queue_insert(store, b2)

						b1.bullet.flight_time = b1.bullet.flight_time + 1 / FPS
					end

					while not U.animation_finished(this, shooter_sid) do
						coroutine.yield()
					end

					an, af = U.animation_name_facing_point(this, "idle", last_target_pos, shooter_sid, start_offset)

					U.animation_start(this, an, af, store.tick_ts, -1, shooter_sid)
				end
			end

			if store.tick_ts - aa.ts > this.tower.long_idle_cooldown then
				for _, sid in pairs(shooter_sprite_ids) do
					local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, sid)

					U.animation_start(this, an, af, store.tick_ts, -1, sid)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.tower_crossbow = {}

function scripts.tower_crossbow.insert(this, store, script)
	return true
end

function scripts.tower_crossbow.remove(this, store, script)
	local mods = table.filter(store.entities, function(_, e)
		return e.modifier and e.modifier.source_id == this.id
	end)

	for _, m in pairs(mods) do
		queue_remove(store, m)
	end

	if this.eagle_previews then
		for _, decal in pairs(this.eagle_previews) do
			queue_remove(store, decal)
		end

		this.eagle_previews = nil
	end

	return true
end

function scripts.tower_crossbow.update(this, store, script)
	local shooter_sprite_ids = {
		3,
		4
	}
	local a = this.attacks
	local aa = this.attacks.list[1]
	local ma = this.attacks.list[2]
	local ea = this.attacks.list[3]
	local last_target_pos = V.v(0, 0)
	local shots_count = 0
	local pow_m = this.powers.multishot
	local pow_e = this.powers.eagle
	local eagle_ts = 0
	local eagle_sid = 5

	this.eagle_previews = nil

	local eagle_previews_level

	SU.towers_swaped(store, this, this.attacks.list)
	aa.ts = store.tick_ts

	while true do
		if this.tower.blocked then
			if this.eagle_previews then
				for _, decal in pairs(this.eagle_previews) do
					queue_remove(store, decal)
				end

				this.eagle_previews = nil
			end
		else
			if this.ui.hover_active and this.ui.args == "eagle" and (not this.eagle_previews or eagle_previews_level ~= pow_e.level) then
				if this.eagle_previews then
					for _, decal in pairs(this.eagle_previews) do
						queue_remove(store, decal)
					end
				end

				this.eagle_previews = {}
				eagle_previews_level = pow_e.level

				local mods = table.filter(store.entities, function(_, e)
					return e.modifier and e.modifier.source_id == this.id
				end)
				local modded_ids = {}

				for _, m in pairs(mods) do
					table.insert(modded_ids, m.modifier.target_id)
				end

				local range = ea.range + km.clamp(1, 3, pow_e.level + 1) * ea.range_inc
				local targets = table.filter(store.entities, function(_, e)
					return e ~= this and e.tower and not table.contains(ea.excluded_templates, e.template_name) and not table.contains(modded_ids, e.id) and U.is_inside_ellipse(e.pos, this.pos, range)
				end)

				for _, target in pairs(targets) do
					local decal = E:create_entity("decal_crossbow_eagle_preview")

					decal.pos = target.pos
					decal.render.sprites[1].ts = store.tick_ts

					queue_insert(store, decal)
					table.insert(this.eagle_previews, decal)
				end
			elseif this.eagle_previews and (not this.ui.hover_active or this.ui.args ~= "eagle") then
				for _, decal in pairs(this.eagle_previews) do
					queue_remove(store, decal)
				end

				this.eagle_previews = nil
			end

			if pow_m.changed then
				pow_m.changed = nil

				if pow_m.level == 1 then
					ma.ts = store.tick_ts
				end
			end

			if pow_e.changed then
				pow_e.changed = nil

				if pow_e.level == 1 then
					ea.ts = store.tick_ts
				end
			end

			if pow_e.level > 0 then
				if store.tick_ts - ea.ts > ea.cooldown then
					ea.ts = store.tick_ts

					local eagle_range = ea.range + ea.range_inc * pow_e.level
					local existing_mods = {}
					local removed_mods = {}
					for k, e in pairs(store.entities) do
						if e.modifier and e.template_name == ea.mod then
							if not store.entities[e.modifier.target_id] then
								table.insert(removed_mods, e)
							elseif e.modifier.level >= pow_e.level then
								table.insert(existing_mods, e)
							end
						end
					end
					for i, m in ipairs(removed_mods) do
						queue_remove(store, m)
					end
					local busy_ids = table.map(existing_mods, function(k, v)
						return v.modifier.target_id
					end)
					local towers = table.filter(store.entities, function(_, e)
						return e.tower and e.tower.can_be_mod and not table.contains(busy_ids, e.id) and not table.contains(ea.excluded_templates, e.template_name) and U.is_inside_ellipse(e.pos, this.pos, eagle_range)
					end)

					for _, tower in pairs(towers) do
						local new_mod = E:create_entity(ea.mod)

						new_mod.modifier.level = pow_e.level
						new_mod.modifier.target_id = tower.id
						new_mod.modifier.source_id = this.id
						new_mod.pos = tower.pos

						queue_insert(store, new_mod)
					end
				end

				if store.tick_ts - eagle_ts > ea.fly_cooldown then
					this.render.sprites[eagle_sid].hidden = false
					eagle_ts = store.tick_ts

					U.animation_start(this, "fly", nil, store.tick_ts, 1, eagle_sid)
					S:queue("CrossbowEagle")
				end
			end

			if pow_m.level > 0 and store.tick_ts - ma.ts > ma.cooldown and this.tower.can_do_magic then
				local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, ma.vis_flags, ma.vis_bans)

				if not enemy then
					-- block empty
				else
					ma.ts = store.tick_ts
					shots_count = shots_count + 1
					last_target_pos.x, last_target_pos.y = enemy.pos.x, enemy.pos.y

					local shooter_idx = shots_count % 2 + 1
					local shooter_sid = shooter_sprite_ids[shooter_idx]
					local start_offset = ma.bullet_start_offset[shooter_idx]

					this.render.sprites[shooter_sid].draw_order = 5

					local an, af = U.animation_name_facing_point(this, "multishot_start", enemy.pos, shooter_sid, start_offset)

					U.animation_start(this, an, af, store.tick_ts, 1, shooter_sid)

					while not U.animation_finished(this, shooter_sid) do
						coroutine.yield()
					end

					an, af = U.animation_name_facing_point(this, "multishot_loop", enemy.pos, shooter_sid, start_offset)

					U.animation_start(this, an, af, store.tick_ts, -1, shooter_sid)

					local last_enemy = enemy
					local loop_ts = store.tick_ts
					local torigin = tpos(this)

					for i = 1, ma.shots + pow_m.level * ma.shots_inc do
						local origin = last_enemy.pos
						local range = ma.near_range

						while store.tick_ts - loop_ts < ma.shoot_time do
							coroutine.yield()
						end

						enemy = U.find_foremost_enemy(store.entities, origin, 0, range, false, ma.vis_flags, ma.vis_bans)

						local shoot_pos, target_id

						if enemy then
							last_enemy = enemy
							enemy_id = enemy.id
							shoot_pos = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
						else
							enemy_id = nil
							shoot_pos = V.v(last_enemy.pos.x, last_enemy.pos.y)
						end

						local b = E:create_entity(ma.bullet)

						b.bullet.damage_factor = 1
						b.bullet.target_id = enemy_id
						b.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
						b.bullet.to = shoot_pos
						b.pos = V.vclone(b.bullet.from)

						queue_insert(store, b)

						while store.tick_ts - loop_ts < ma.cycle_time do
							coroutine.yield()
						end

						loop_ts = 2 * store.tick_ts - (loop_ts + ma.cycle_time)
					end

					ma.ts = store.tick_ts

					local an, af = U.animation_name_facing_point(this, "multishot_end", last_enemy.pos, shooter_sid, start_offset)

					U.animation_start(this, an, af, store.tick_ts, 1, shooter_sid)

					this.render.sprites[shooter_sid].draw_order = nil

					while not U.animation_finished(this, shooter_sid) do
						coroutine.yield()
					end
				end
			end

			if store.tick_ts - aa.ts > aa.cooldown then
				local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)

				if not enemy then
					-- block empty
				else
					aa.ts = store.tick_ts
					shots_count = shots_count + 1
					last_target_pos.x, last_target_pos.y = enemy.pos.x, enemy.pos.y

					local shooter_idx = shots_count % 2 + 1
					local shooter_sid = shooter_sprite_ids[shooter_idx]
					local start_offset = aa.bullet_start_offset[shooter_idx]

					this.render.sprites[shooter_sid].draw_order = 5

					local an, af = U.animation_name_facing_point(this, "shoot", enemy.pos, shooter_sid, start_offset)

					U.animation_start(this, an, af, store.tick_ts, 1, shooter_sid)

					while store.tick_ts - aa.ts < aa.shoot_time do
						coroutine.yield()
					end

					local torigin = tpos(this)

					if V.dist(torigin.x, torigin.y, enemy.pos.x, enemy.pos.y) <= a.range then
						local b1 = E:create_entity(aa.bullet)

						b1.pos.x, b1.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
						b1.bullet.from = V.vclone(b1.pos)
						b1.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
						b1.bullet.target_id = enemy.id

						if pow_e.level > 0 then
							local crit_chance = aa.critical_chance + pow_e.level * aa.critical_chance_inc

							if crit_chance > math.random() then
								b1.bullet.damage_factor = 2
								b1.bullet.pop = {
									"pop_crit"
								}
								b1.bullet.pop_conds = DR_DAMAGE
							end
						end

						queue_insert(store, b1)

						local u = UP:get_upgrade("archer_twin_shot")

						if u and math.random() < u.chance then
							b2 = E:clone_entity(b1)
							b2.bullet.flight_time = b2.bullet.flight_time - 1 / FPS

							queue_insert(store, b2)

							b1.bullet.flight_time = b1.bullet.flight_time + 1 / FPS
						end
					end

					while not U.animation_finished(this, shooter_sid) do
						coroutine.yield()
					end

					an, af = U.animation_name_facing_point(this, "idle", last_target_pos, shooter_sid, start_offset)

					U.animation_start(this, an, af, store.tick_ts, -1, shooter_sid)

					this.render.sprites[shooter_sid].draw_order = nil
				end
			end

			if store.tick_ts - math.max(aa.ts, ma.ts) > this.tower.long_idle_cooldown then
				for _, sid in pairs(shooter_sprite_ids) do
					local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, sid)

					U.animation_start(this, an, af, store.tick_ts, -1, sid)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.tower_necromancer = {}

function scripts.tower_necromancer.insert(this, store, script)
	if not store.skeletons_count then
		store.skeletons_count = 0
	end

	if this.auras then
		for _, a in pairs(this.auras.list) do
			if a.cooldown == 0 then
				local e = E:create_entity(a.name)

				e.pos = V.vclone(this.pos)
				e.aura.level = this.tower.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts

				queue_insert(store, e)
			end
		end
	end

	return true
end

function scripts.tower_necromancer.remove(this, store, script)
	return true
end

function scripts.tower_necromancer.update(this, store, script)
	local shooter_sid = 3
	local skull_glow_sid = 4
	local skull_fx_sid = 5
	local b = this.barrack
	local a = this.attacks
	local ba = this.attacks.list[1]
	local pa = this.attacks.list[2]
	local pow_r = this.powers.rider
	local pow_p = this.powers.pestilence
	local t_angle = math.pi * 3 / 2
	local hands_raised = false

	ba.ts = store.tick_ts

	while true do
		if this.tower.blocked then
			if hands_raised then
				this.render.sprites[skull_fx_sid].hidden = true
				this.render.sprites[skull_glow_sid].ts = store.tick_ts
				this.tween.reverse = true

				local an, _, ai = U.animation_name_for_angle(this, "shoot_end", t_angle, shooter_sid)

				U.y_animation_play(this, an, nil, store.tick_ts, 1, shooter_sid)

				hands_raised = false

				local an = U.animation_name_for_angle(this, "idle", t_angle, shooter_sid)

				U.animation_start(this, an, nil, store.tick_ts, true, shooter_sid)
			end

			coroutine.yield()
		else
			if pow_r.level > 0 then
				if pow_r.changed then
					pow_r.changed = nil
					s = b.soldiers[1]

					if s and store.entities[s.id] then
						s.unit.level = pow_r.level
						s.health.hp_max = s.health.hp_max + s.health.hp_inc
						s.health.armor = s.health.armor + s.health.armor_inc
						s.melee.attacks[1].damage_min = s.melee.attacks[1].damage_min + s.melee.attacks[1].damage_inc
						s.melee.attacks[1].damage_max = s.melee.attacks[1].damage_max + s.melee.attacks[1].damage_inc
						s.health.hp = s.health.hp_max

						local auras = table.filter(store.entities, function(k, v)
							return v.aura and v.aura.source_id == s.id
						end)

						for _, aura in pairs(auras) do
							aura.aura.level = pow_r.level
						end
					end
				end

				local s = b.soldiers[1]

				if not s or s.health.dead and store.tick_ts - s.health.death_ts > s.health.dead_lifetime then
					s = E:create_entity(b.soldier_type)
					s.soldier.tower_id = this.id
					s.pos = V.v(b.rally_pos.x, b.rally_pos.y)
					s.nav_rally.pos = V.v(b.rally_pos.x, b.rally_pos.y)
					s.nav_rally.center = V.vclone(b.rally_pos)
					s.nav_rally.new = true
					s.unit.level = pow_r.level
					s.health.hp_max = s.health.hp_max + s.health.hp_inc * s.unit.level
					s.health.armor = s.health.armor + s.health.armor_inc * s.unit.level
					s.melee.attacks[1].damage_min = s.melee.attacks[1].damage_min + s.melee.attacks[1].damage_inc * s.unit.level
					s.melee.attacks[1].damage_max = s.melee.attacks[1].damage_max + s.melee.attacks[1].damage_inc * s.unit.level

					queue_insert(store, s)

					b.soldiers[1] = s
				end

				if b.rally_new then
					b.rally_new = false

					signal.emit("rally-point-changed", this)

					if s then
						s.nav_rally.pos = V.vclone(b.rally_pos)
						s.nav_rally.center = V.vclone(b.rally_pos)
						s.nav_rally.new = true

						if not s.health.dead then
							S:queue(this.sound_events.change_rally_point)
						end
					end
				end
			end

			if pow_p.changed then
				pow_p.changed = nil

				if pow_p.level == 1 then
					pa.ts = store.tick_ts
				end
			end

			if pow_p.level > 0 and store.tick_ts - pa.ts > pa.cooldown then
				local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, pa.vis_flags, pa.vis_bans)

				if enemy then
					pa.ts = store.tick_ts

					local tx, ty = V.sub(enemy.pos.x, enemy.pos.y, this.pos.x, this.pos.y)

					t_angle = km.unroll(V.angleTo(tx, ty))

					local shooter = this.render.sprites[shooter_sid]
					local an, _, ai = U.animation_name_for_angle(this, "pestilence", t_angle, shooter_sid)

					U.animation_start(this, an, nil, store.tick_ts, 1, shooter_sid)

					while store.tick_ts - pa.ts < pa.shoot_time do
						coroutine.yield()
					end

					local path = P:path(enemy.nav_path.pi, enemy.nav_path.spi)
					local ni = enemy.nav_path.ni + 3

					ni = km.clamp(1, #path, ni)

					local dest = P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi, ni)
					local b = E:create_entity(pa.bullet)

					b.aura.source_id = this.id
					b.aura.ts = store.tick_ts
					b.aura.level = pow_p.level
					b.pos = V.vclone(dest)

					queue_insert(store, b)

					while not U.animation_finished(this, shooter_sid) do
						coroutine.yield()
					end
				end
			end

			if store.tick_ts - ba.ts > ba.cooldown then
				local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, ba.vis_flags, ba.vis_bans)

				if enemy then
					local shooter_offset_y = ba.bullet_start_offset[1].y
					local tx, ty = V.sub(enemy.pos.x, enemy.pos.y, this.pos.x, this.pos.y + shooter_offset_y)

					t_angle = km.unroll(V.angleTo(tx, ty))

					local shooter = this.render.sprites[shooter_sid]

					if not hands_raised then
						this.render.sprites[skull_fx_sid].hidden = false
						this.render.sprites[skull_glow_sid].hidden = false
						this.render.sprites[skull_glow_sid].ts = store.tick_ts
						this.tween.reverse = false

						local an, _, ai = U.animation_name_for_angle(this, "shoot_start", t_angle, shooter_sid)

						U.animation_start(this, an, nil, store.tick_ts, 1, shooter_sid)

						while not U.animation_finished(this, shooter_sid) do
							coroutine.yield()
						end

						hands_raised = true
					end

					local an, _, ai = U.animation_name_for_angle(this, "shoot_loop", t_angle, shooter_sid)

					U.animation_start(this, an, nil, store.tick_ts, -1, shooter_sid)

					ba.ts = store.tick_ts

					while store.tick_ts - ba.ts < ba.shoot_time do
						coroutine.yield()
					end

					local bullet = E:create_entity(ba.bullet)

					bullet.bullet.damage_factor = this.tower.damage_factor
					bullet.bullet.to = V.vclone(enemy.pos)
					bullet.bullet.target_id = enemy.id

					local start_offset = ba.bullet_start_offset[ai]

					bullet.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
					bullet.pos = V.vclone(bullet.bullet.from)

					queue_insert(store, bullet)
				elseif hands_raised then
					this.render.sprites[skull_fx_sid].hidden = true
					this.render.sprites[skull_glow_sid].ts = store.tick_ts
					this.tween.reverse = true

					local an, _, ai = U.animation_name_for_angle(this, "shoot_end", t_angle, shooter_sid)

					U.animation_start(this, an, nil, store.tick_ts, 1, shooter_sid)

					while not U.animation_finished(this, shooter_sid) do
						coroutine.yield()
					end

					hands_raised = false
				end
			end

			if not hands_raised then
				local an = U.animation_name_for_angle(this, "idle", t_angle, shooter_sid)

				U.animation_start(this, an, nil, store.tick_ts, -1, shooter_sid)
			end

			if store.tick_ts - math.max(ba.ts, pa.ts) > this.tower.long_idle_cooldown then
				local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

				U.animation_start(this, an, af, store.tick_ts, -1, shooter_sid)
			end

			coroutine.yield()
		end
	end
end

scripts.tower_archmage = {}

function scripts.tower_archmage.insert(this, store, script)
	this._last_t_angle = math.pi * 3 / 2
	this._stored_bullets = {}

	return true
end

function scripts.tower_archmage.remove(this, store, script)
	for _, b in pairs(this._stored_bullets) do
		queue_remove(store, b)
	end

	return true
end

function scripts.tower_archmage.update(this, store, script)
	local tower_sid = 2
	local shooter_sid = 3
	local s_tower = this.render.sprites[tower_sid]
	local s_shooter = this.render.sprites[shooter_sid]
	local a = this.attacks
	local ba = this.attacks.list[1]
	local ta = this.attacks.list[2]
	local pow_b = this.powers.blast
	local pow_t = this.powers.twister

	SU.towers_swaped(store, this, this.attacks.list)
	ba.ts = store.tick_ts

	while true do
		if this.tower.blocked then
			if #this._stored_bullets then
				for _, b in pairs(this._stored_bullets) do
					queue_remove(store, b)
				end

				this._stored_bullets = {}
			end

			coroutine.yield()
		else
			if pow_t.changed then
				pow_t.changed = nil

				if pow_t.level == 1 then
					ta.ts = store.tick_ts
				end
			end

			if pow_t.level > 0 and store.tick_ts - ta.ts > ta.cooldown and this.tower.can_do_magic then
				local target = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, ta.vis_flags, ta.vis_bans, function(e)
					return P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_TWISTER) and e.nav_path.ni > P:get_start_node(e.nav_path.pi) + ta.nodes_limit and e.nav_path.ni < P:get_end_node(e.nav_path.pi) - ta.nodes_limit
				end)

				if not target then
					-- block empty
				else
					ta.ts = store.tick_ts

					local tx, ty = V.sub(target.pos.x, target.pos.y, this.pos.x, this.pos.y + s_tower.offset.y)

					t_angle = km.unroll(V.angleTo(tx, ty))
					this._last_t_angle = t_angle

					local an, _, ai = U.animation_name_for_angle(this, ta.animation, t_angle, shooter_sid)

					U.animation_start(this, an, nil, store.tick_ts, 1, shooter_sid)

					while store.tick_ts - ta.ts < ta.shoot_time do
						coroutine.yield()
					end

					local twister = E:create_entity(ta.bullet)
					local np = twister.nav_path

					np.pi = target.nav_path.pi
					np.spi = target.nav_path.spi
					np.ni = target.nav_path.ni + P:predict_enemy_node_advance(target, true)
					twister.pos = P:node_pos(np.pi, np.spi, np.ni)
					twister.aura.level = pow_t.level

					queue_insert(store, twister)

					while not U.animation_finished(this, shooter_sid) do
						coroutine.yield()
					end

					ba.ts = store.tick_ts
				end
			end

			if store.tick_ts - ba.ts > ba.cooldown then
				local target

				target = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, ba.vis_flags, ba.vis_bans)

				if not target and (not ba.max_stored_bullets or ba.max_stored_bullets == #this._stored_bullets) then
					-- block empty
				else
					ba.ts = store.tick_ts

					local t_angle

					if target then
						local tx, ty = V.sub(target.pos.x, target.pos.y, this.pos.x, this.pos.y + s_tower.offset.y)

						t_angle = km.unroll(V.angleTo(tx, ty))
						this._last_t_angle = t_angle
					else
						t_angle = this._last_t_angle
					end

					local an, _, ai = U.animation_name_for_angle(this, ba.animation, t_angle, shooter_sid)

					U.animation_start(this, an, nil, store.tick_ts, 1, shooter_sid)

					while store.tick_ts - ba.ts < ba.shoot_time do
						coroutine.yield()
					end

					if target and #this._stored_bullets > 0 then
						for _, b in pairs(this._stored_bullets) do
							b.bullet.target_id = target.id
							b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
						end

						this._stored_bullets = {}
					else
						local start_offset = ba.bullet_start_offset[ai]
						local b = E:create_entity(ba.bullet)

						b.bullet.damage_factor = this.tower.damage_factor
						b.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
						b.pos = V.vclone(b.bullet.from)

						if target then
							b.bullet.target_id = target.id
							b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
						else
							b.bullet.target_id = nil
							b.bullet.store = true

							local off = ba.storage_offsets[#this._stored_bullets + 1]

							b.bullet.to = V.v(this.pos.x + off.x, this.pos.y + off.y)

							table.insert(this._stored_bullets, b)
						end

						queue_insert(store, b)

						if pow_b.level > 0 and math.random() < ba.payload_chance then
							local blast = E:create_entity(ba.payload_bullet)

							blast.bullet.level = pow_b.level
							b.bullet.hit_payload = blast
						end
					end

					while not U.animation_finished(this, shooter_sid) do
						coroutine.yield()
					end
				end
			end

			local an = U.animation_name_for_angle(this, "idle", this._last_t_angle, shooter_sid)

			U.animation_start(this, an, nil, store.tick_ts, -1, shooter_sid)

			if store.tick_ts - math.max(ba.ts, ta.ts) > this.tower.long_idle_cooldown then
				local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

				U.animation_start(this, an, af, store.tick_ts, -1, shooter_sid)
			end

			coroutine.yield()
		end
	end
end

scripts.tower_dwaarp = {}

function scripts.tower_dwaarp.insert(this, store, script)
	local points = {}
	local inner_fx_radius = 100
	local outer_fx_radius = 115
	local aspect = 0.7

	for i = 1, 12 do
		local r = outer_fx_radius

		if i % 2 == 0 then
			r = inner_fx_radius
		end

		local p = {}

		p.pos = U.point_on_ellipse(this.pos, r, 2 * math.pi * i / 12)
		p.terrain = GR:cell_type(p.pos.x, p.pos.y)

		log.debug("i:%i pos:%f,%f type:%i", i, p.pos.x, p.pos.y, p.terrain)

		if GR:cell_is(p.pos.x, p.pos.y, TERRAIN_WATER) or P:valid_node_nearby(p.pos.x, p.pos.y, 1) and not GR:cell_is(p.pos.x, p.pos.y, TERRAIN_CLIFF) then
			table.insert(points, p)
		end
	end

	this.fx_points = points

	return true
end

function scripts.tower_dwaarp.update(this, store, script)
	local a = this.attacks
	local aa = this.attacks.list[1]
	local la = this.attacks.list[2]
	local da = this.attacks.list[3]
	local a4 = this.attacks.list[4]
	local pow_d = this.powers.drill
	local pow_l = this.powers.lava
	local pow_b = this.powers.batteries
	local lava_ready = false
	local drill_ready = false
	local std_ready = false
	local anim_id = 3

	aa.ts = store.tick_ts

	::label_86_0::

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			if pow_d.changed then
				pow_d.changed = nil
				if not da.ts and pow_d.level > 0 then
					da.ts = store.tick_ts
				end
			end

			if pow_l.changed then
				pow_l.changed = nil
				if not la.ts and pow_l.level > 0 then
					la.ts = store.tick_ts
				end
			end

			if pow_b.changed then
				pow_b.changed = nil
				if not a4.ts and pow_b.level > 0 then
					a4.ts = store.tick_ts - a4.cooldown
				end
			end

			if SU.check_tower_attack_available(store, this, a4) then
				local targets = U.find_enemies_in_range(store.entities, tpos(this), 0, a.range, a4.vis_flags, a4.vis_bans)
				if targets and #targets >= a4.min_targets then
					a4.ts = store.tick_ts
					this.render.sprites[anim_id].fps = a4.fps
					for i = 1, a4.loops do
						local start_ts = store.tick_ts
						U.animation_start(this, "shoot", nil, store.tick_ts, nil, anim_id)
						while store.tick_ts - start_ts < a4.hit_time do
							coroutine.yield()
						end
						local enemies = table.filter(store.entities, function(k, v)
							return v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, a4.damage_bans) == 0 and band(v.vis.bans, a4.damage_flags) == 0 and U.is_inside_ellipse(v.pos, tpos(this), a.range)
						end)
						for _, enemy in pairs(enemies) do
							local d = E:create_entity("damage")
							d.source_id = this.id
							d.target_id = enemy.id
							d.damage_type = a4.damage_type
							d.value = a4.damage_max
							d.value = math.ceil(this.tower.damage_factor * d.value)
							queue_damage(store, d)
							if a4.mod then
								local mod = E:create_entity(a4.mod)
								mod.modifier.target_id = enemy.id
								queue_insert(store, mod)
							end
							if band(enemy.vis.bans, F_STUN) == 0 and band(enemy.vis.flags, bor(F_BOSS, F_CLIFF, F_FLYING)) == 0 and math.random() < 0.2 then
								local mod = E:create_entity("mod_shock_and_awe")
								mod.modifier.target_id = enemy.id
								queue_insert(store, mod)
							end
						end
						for i = 1, #this.fx_points do
							local p = this.fx_points[i]
							if band(p.terrain, TERRAIN_WATER) ~= 0 then
								local smoke = E:create_entity("decal_dwaarp_smoke_water")
	
								smoke.pos.x, smoke.pos.y = p.pos.x, p.pos.y
								smoke.render.sprites[1].ts = store.tick_ts + math.random() * 5 / FPS
	
								queue_insert(store, smoke)
							else
								local decal = E:create_entity("decal_tween")
	
								decal.pos.x, decal.pos.y = p.pos.x, p.pos.y
								decal.tween.props[1].keys = {
									{
										0,
										255
									},
									{
										1,
										255
									},
									{
										2.5,
										0
									}
								}
								decal.tween.props[1].name = "alpha"
	
								if math.random() < 0.5 then
									decal.render.sprites[1].name = "EarthquakeTower_HitDecal1"
								else
									decal.render.sprites[1].name = "EarthquakeTower_HitDecal2"
								end
	
								decal.render.sprites[1].animated = false
								decal.render.sprites[1].z = Z_DECALS
								decal.render.sprites[1].ts = store.tick_ts
	
								queue_insert(store, decal)
	
								local smoke = E:create_entity("decal_dwaarp_smoke")
	
								smoke.pos.x, smoke.pos.y = p.pos.x, p.pos.y
								smoke.render.sprites[1].ts = store.tick_ts + math.random() * 5 / FPS
	
								queue_insert(store, smoke)
							end
						end
						local pulse = E:create_entity("decal_dwaarp_pulse")
						pulse.pos.x, pulse.pos.y = this.pos.x, this.pos.y + 16
						pulse.render.sprites[1].ts = store.tick_ts
						queue_insert(store, pulse)
						S:queue(a4.sound)
						while not U.animation_finished(this, anim_id) do
							coroutine.yield()
						end
					end
					this.render.sprites[anim_id].fps = 30
					U.animation_start(this, "idle", nil, store.tick_ts, true, anim_id)
				else
					SU.delay_attack(store, a4, 0.1)
				end
			end

			if this.tower.can_do_magic and pow_d.level > 0 and store.tick_ts - da.ts > da.cooldown + pow_d.level * da.cooldown_inc then
				drill_ready = true
			end

			if store.tick_ts - aa.ts > aa.cooldown then
				if this.tower.can_do_magic and pow_l.level > 0 and store.tick_ts - la.ts > la.cooldown then
					lava_ready = true
					this.render.sprites[4].hidden = false
					this.render.sprites[5].hidden = false
				end

				std_ready = true
			end

			if not drill_ready and not lava_ready and not std_ready then
				coroutine.yield()
			else
				if drill_ready then
					local trigger_enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, true, da.vis_flags, da.vis_bans)

					if not trigger_enemy then
						-- block empty
					else
						drill_ready = false
						da.ts = store.tick_ts

						S:queue(da.sound)
						U.animation_start(this, "drill", nil, store.tick_ts, 1, anim_id)

						while store.tick_ts - da.ts < da.hit_time do
							coroutine.yield()
						end

						local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, true, da.vis_flags, da.vis_bans)

						if enemy then
							local drill = E:create_entity(da.bullet)

							drill.bullet.target_id = enemy.id
							drill.pos.x, drill.pos.y = enemy.pos.x, enemy.pos.y

							queue_insert(store, drill)
						end

						while not U.animation_finished(this, anim_id) do
							coroutine.yield()
						end

						goto label_86_0
					end
				end

				local trigger_range = lava_ready and 162 or a.range
				local trigger_enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, trigger_range, false, aa.vis_flags, aa.vis_bans)

				if std_ready and trigger_enemy then
					aa.ts = store.tick_ts

					if lava_ready then
						la.ts = store.tick_ts
					end

					U.animation_start(this, "shoot", nil, store.tick_ts, 1, anim_id)

					while store.tick_ts - aa.ts < aa.hit_time do
						coroutine.yield()
					end

					local enemies = table.filter(store.entities, function(k, v)
						return v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, aa.damage_bans) == 0 and band(v.vis.bans, aa.damage_flags) == 0 and U.is_inside_ellipse(v.pos, tpos(this), a.range)
					end)
					local alchemical_powder_on = true

					for _, enemy in pairs(enemies) do
						local d = E:create_entity("damage")

						d.source_id = this.id
						d.target_id = enemy.id
						d.damage_type = aa.damage_type

						if alchemical_powder_on then
							d.value = aa.damage_max
						else
							d.value = math.random(aa.damage_min, aa.damage_max)
						end

						d.value = math.ceil(this.tower.damage_factor * d.value)

						queue_damage(store, d)

						if aa.mod then
							local mod = E:create_entity(aa.mod)

							mod.modifier.target_id = enemy.id

							queue_insert(store, mod)
						end

						if band(enemy.vis.bans, F_STUN) == 0 and band(enemy.vis.flags, bor(F_BOSS, F_CLIFF, F_FLYING)) == 0 and math.random() < 0.2 then
							local mod = E:create_entity("mod_shock_and_awe")

							mod.modifier.target_id = enemy.id

							queue_insert(store, mod)
						end
					end

					for i = 1, #this.fx_points do
						local p = this.fx_points[i]

						if lava_ready then
							local lava = E:create_entity(la.bullet)

							lava.pos.x, lava.pos.y = p.pos.x, p.pos.y
							lava.aura.ts = store.tick_ts
							lava.aura.source_id = this.id
							lava.aura.level = pow_l.level

							queue_insert(store, lava)
						end

						if band(p.terrain, TERRAIN_WATER) ~= 0 then
							local smoke = E:create_entity("decal_dwaarp_smoke_water")

							smoke.pos.x, smoke.pos.y = p.pos.x, p.pos.y
							smoke.render.sprites[1].ts = store.tick_ts + math.random() * 5 / FPS

							queue_insert(store, smoke)

							if lava_ready then
								local vapor = E:create_entity("decal_dwaarp_scorched_water")

								vapor.render.sprites[1].ts = store.tick_ts + U.frandom(0, 0.5)
								vapor.pos.x, vapor.pos.y = p.pos.x + U.frandom(-5, 5), p.pos.y + U.frandom(-5, 5)

								if math.random() < 0.5 then
									vapor.render.sprites[1].flip_x = true
								end

								queue_insert(store, vapor)
							end
						else
							local decal = E:create_entity("decal_tween")

							decal.pos.x, decal.pos.y = p.pos.x, p.pos.y
							decal.tween.props[1].keys = {
								{
									0,
									255
								},
								{
									1,
									255
								},
								{
									2.5,
									0
								}
							}
							decal.tween.props[1].name = "alpha"

							if math.random() < 0.5 then
								decal.render.sprites[1].name = "EarthquakeTower_HitDecal1"
							else
								decal.render.sprites[1].name = "EarthquakeTower_HitDecal2"
							end

							decal.render.sprites[1].animated = false
							decal.render.sprites[1].z = Z_DECALS
							decal.render.sprites[1].ts = store.tick_ts

							queue_insert(store, decal)

							local smoke = E:create_entity("decal_dwaarp_smoke")

							smoke.pos.x, smoke.pos.y = p.pos.x, p.pos.y
							smoke.render.sprites[1].ts = store.tick_ts + math.random() * 5 / FPS

							queue_insert(store, smoke)

							if lava_ready then
								local scorch = E:create_entity("decal_dwaarp_scorched")

								if math.random() < 0.5 then
									scorch.render.sprites[1].name = "EarthquakeTower_Lava2"
								end

								scorch.pos.x, scorch.pos.y = p.pos.x, p.pos.y
								scorch.render.sprites[1].ts = store.tick_ts

								queue_insert(store, scorch)
							end
						end
					end

					if lava_ready then
						local tower_scorch = E:create_entity("decal_dwaarp_tower_scorched")

						tower_scorch.pos.x, tower_scorch.pos.y = this.pos.x, this.pos.y + 10
						tower_scorch.render.sprites[1].ts = store.tick_ts

						queue_insert(store, tower_scorch)
					end

					local pulse = E:create_entity("decal_dwaarp_pulse")

					pulse.pos.x, pulse.pos.y = this.pos.x, this.pos.y + 16
					pulse.render.sprites[1].ts = store.tick_ts

					queue_insert(store, pulse)

					if lava_ready then
						S:queue(la.sound)
					end

					S:queue(aa.sound)

					while not U.animation_finished(this, anim_id) do
						coroutine.yield()
					end

					std_ready = false
					lava_ready = false
					this.render.sprites[4].hidden = true
					this.render.sprites[5].hidden = true
				end

				U.animation_start(this, "idle", nil, store.tick_ts, -1, anim_id)
				coroutine.yield()
			end
		end
	end
end

scripts.tower_mech = {}

function scripts.tower_mech.get_info(this)
	local sm = E:get_template(this.barrack.soldier_type)
	local b = E:get_template(sm.attacks.list[1].bullet)
	local min, max = b.bullet.damage_min, b.bullet.damage_max

	min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)

	local cooldown = sm.attacks.list[1].cooldown
	local range = sm.attacks.list[1].max_range

	return {
		type = STATS_TYPE_TOWER,
		damage_min = min,
		damage_max = max,
		range = range,
		cooldown = cooldown
	}
end

function scripts.tower_mech.insert(this, store, script)
	return true
end

function scripts.tower_mech.update(this, store, script)
	local tower_sid = 2
	local wts
	local is_open = false

	for i = 2, 10 do
		U.animation_start(this, "open", nil, store.tick_ts, 1, i)
	end

	while not U.animation_finished(this, tower_sid) do
		coroutine.yield()
	end

	local mecha = E:create_entity("soldier_mecha")

	mecha.pos.x, mecha.pos.y = this.pos.x, this.pos.y + 16
	mecha.nav_rally.pos.x, mecha.nav_rally.pos.y = this.tower.default_rally_pos.x, this.tower.default_rally_pos.y
	mecha.nav_rally.new = true
	mecha.owner = this

	queue_insert(store, mecha)
	table.insert(this.barrack.soldiers, mecha)
	coroutine.yield()

	for i = 2, 10 do
		U.animation_start(this, "hold", nil, store.tick_ts, 1, i)
	end

	wts = store.tick_ts
	is_open = true

	local b = this.barrack

	while true do
		if is_open and store.tick_ts - wts >= 1.8 then
			is_open = false

			for i = 2, 10 do
				U.animation_start(this, "close", nil, store.tick_ts, 1, i)
			end
		end

		if b.rally_new then
			b.rally_new = false

			signal.emit("rally-point-changed", this)
			S:queue(this.sound_events.change_rally_point)

			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos = V.vclone(b.rally_pos)
				s.nav_rally.center = V.vclone(b.rally_pos)
				s.nav_rally.new = true
			end
		end

		if this.powers.missile.changed then
			this.powers.missile.changed = nil

			for i, s in ipairs(b.soldiers) do
				s.powers.missile.changed = true
				s.powers.missile.level = this.powers.missile.level
			end
		end

		if this.powers.oil.changed then
			this.powers.oil.changed = nil

			for i, s in ipairs(b.soldiers) do
				s.powers.oil.changed = true
				s.powers.oil.level = this.powers.oil.level
			end
		end

		coroutine.yield()
	end
end

scripts.tower_neptune_holder = {}

function scripts.tower_neptune_holder.get_info(this)
	local t = E:get_template("tower_neptune")
	local b = E:get_template(t.attacks.list[1].bullet)
	local min, max = b.bullet.damage_min_levels[1], b.bullet.damage_max_levels[1]
	local range = 2000
	local cooldown = t.attacks.list[1].cooldown

	return {
		type = STATS_TYPE_TOWER,
		damage_min = min,
		damage_max = max,
		range = range,
		cooldown = cooldown
	}
end

scripts.tower_neptune = {}

function scripts.tower_neptune.get_info(this)
	local level = this.powers.ray.level
	local b = E:get_template(this.attacks.list[1].bullet)
	local min, max = b.bullet.damage_min_levels[level], b.bullet.damage_max_levels[level]
	local range = 2000
	local cooldown = this.attacks.list[1].cooldown

	return {
		type = STATS_TYPE_TOWER,
		damage_min = min,
		damage_max = max,
		range = range,
		cooldown = cooldown
	}
end

function scripts.tower_neptune.insert(this, store, script)
	return true
end

function scripts.tower_neptune.update(this, store, script)
	local pow = this.powers.ray
	local a = this.attacks.list[1]

	a.ts = store.tick_ts - a.cooldown + 0.03333333333333333

	local charging = false
	local sid_charging = 4
	local sid_gem_1 = 5
	local sid_gem_2 = 6
	local sid_gem_3 = 7
	local sid_eyes = 8
	local sid_trident_glow = 2
	local sid_trident = 9
	local sid_tip = 10
	local sid_gems = {
		sid_gem_1,
		sid_gem_2,
		sid_gem_3
	}
	local s = this.render.sprites

	while true do
		if pow.changed then
			pow.changed = nil

			if pow.level == 2 then
				s[sid_gem_2].hidden = false
			end

			if pow.level == 3 then
				s[sid_gem_3].hidden = false
			end

			a.ts = store.tick_ts - a.cooldown
			charging = true
		end

		if store.tick_ts - a.ts < a.cooldown and not charging then
			this.user_selection.allowed = false
			charging = true
			s[sid_charging].hidden = false
			s[sid_charging].name = "charging"
			s[sid_tip].hidden = true

			for _, gsid in pairs(sid_gems) do
				s[gsid].name = "empty"
				s[gsid].loop = true
			end

			s[sid_eyes].name = "empty"
			s[sid_trident].name = "empty"
			s[sid_trident_glow].hidden = true
		end

		if store.tick_ts - a.ts > a.cooldown then
			if charging then
				this.user_selection.allowed = true
				this.user_selection.new_pos = nil
				charging = false
				s[sid_charging].name = "charged"

				for _, gsid in pairs(sid_gems) do
					s[gsid].name = "ready"
					s[gsid].loop = true
					s[gsid].fps = 15
				end

				s[sid_trident_glow].hidden = false
			end

			if this.user_selection.in_progress then
				s[sid_tip].hidden = false
				s[sid_tip].loop = true
				s[sid_tip].name = "pick"
			else
				s[sid_tip].hidden = true
			end

			if this.user_selection.new_pos then
				local pos = this.user_selection.new_pos

				this.user_selection.new_pos = nil
				a.ts = store.tick_ts
				s[sid_charging].hidden = true
				s[sid_trident_glow].hidden = true

				for _, gsid in pairs(sid_gems) do
					s[gsid].fps = 30

					U.animation_start(this, "shoot", nil, store.tick_ts, 1, gsid)
				end

				U.animation_start(this, "shoot", nil, store.tick_ts, 1, sid_tip)
				U.animation_start(this, "shoot", nil, store.tick_ts, 1, sid_eyes)
				U.animation_start(this, "shoot", nil, store.tick_ts, 1, sid_trident)

				local b = E:create_entity(a.bullet)

				b.bullet.to = V.vclone(pos)
				b.bullet.level = pow.level
				b.pos.x, b.pos.y = this.pos.x + a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y

				queue_insert(store, b)

				while not U.animation_finished(this, sid_eyes) do
					coroutine.yield()
				end
			end
		end

		coroutine.yield()
	end
end

scripts.ray_neptune = {}

function scripts.ray_neptune.update(this, store, script)
	local b = this.bullet
	local s = this.render.sprites[1]
	local damage_min = this.bullet.damage_min_levels[this.bullet.level]
	local damage_max = this.bullet.damage_max_levels[this.bullet.level]
	local angle = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

	s.r = angle
	s.scale = V.v(1, 1)
	s.scale.x = V.dist(b.to.x, b.to.y, this.pos.x, this.pos.y) / this.image_width
	s.ts = store.tick_ts

	local fx = E:create_entity(b.hit_fx)

	fx.pos.x, fx.pos.y = b.to.x, b.to.y
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	local enemies = table.filter(store.entities, function(k, v)
		if v.enemy and v.health and not v.health.dead then
			if U.is_inside_ellipse(v.pos, b.to, b.damage_radius) then
				return true
			end

			if v.unit.hit_offset and U.is_inside_ellipse(V.v(v.pos.x, v.pos.y + v.unit.hit_offset.y), b.to, b.damage_radius) then
				return true
			end

			if v.unit.hit_rect and b.damage_rect then
				local dr = b.damage_rect
				local hr = v.unit.hit_rect
				local r1 = V.r(hr.pos.x + v.pos.x, hr.pos.y + v.pos.y, hr.size.x, hr.size.y)
				local r2 = V.r(dr.pos.x + b.to.x, dr.pos.y + b.to.y, dr.size.x, dr.size.y)

				return V.overlap(r1, r2)
			end
		end

		return false
	end)

	for _, enemy in pairs(enemies) do
		local d = E:create_entity("damage")

		d.source_id = this.id
		d.target_id = enemy.id
		d.value = math.random(damage_min, damage_max)
		d.damage_type = b.damage_type

		queue_damage(store, d)
	end

	while not U.animation_finished(this) do
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.blazefang_explosion = {}

function scripts.blazefang_explosion.update(this, store, script)
	local b = this.bullet
	local targets = table.filter(store.entities, function(k, v)
		return v.soldier and v.health and not v.health.dead and U.is_inside_ellipse(v.pos, this.pos, b.damage_radius)
	end)

	for _, target in pairs(targets) do
		local d = E:create_entity("damage")

		d.source_id = this.id
		d.target_id = target.id
		d.value = b.damage_min + math.ceil(U.frandom(b.damage_min, b.damage_max))
		d.damage_type = b.damage_type

		queue_damage(store, d)
	end

	queue_remove(store, this)
end

scripts.drill = {}

function scripts.drill.update(this, store, script)
	local b = this.bullet
	local target = store.entities[b.target_id]

	if not target or target.health.dead then
		queue_remove(store, this)

		return
	end

	local no = P:predict_enemy_node_advance(target, b.flight_time)
	local pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + no)

	if GR:cell_is(pos.x, pos.y, TERRAIN_WATER) then
		U.animation_start(this, "water", nil, store.tick_ts, 1)
	else
		U.animation_start(this, "ground", nil, store.tick_ts, 1)
	end

	while store.tick_ts - this.render.sprites[1].ts < this.hit_time do
		coroutine.yield()
	end

	local d = E:create_entity("damage")

	d.damage_type = DAMAGE_INSTAKILL
	d.source_id = this.id
	d.target_id = target.id
	d.pop = b.pop
	d.pop_conds = b.pop_conds
	d.pop_chance = b.pop_chance

	queue_damage(store, d)

	while not U.animation_finished(this) do
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.spell_djinn = {}

function scripts.spell_djinn.insert(this, store, script)
	local target = store.entities[this.spell.target_id]

	if not target or band(target.vis.bans, F_POLYMORPH) ~= 0 then
		return false
	end

	local d = E:create_entity("damage")

	d.damage_type = DAMAGE_EAT
	d.source_id = this.id
	d.target_id = target.id

	queue_damage(store, d)

	target.vis.bans = F_POLYMORPH

	local fx = E:create_entity(this.fx_options[math.random(1, #this.fx_options)])

	fx.pos = V.vclone(target.pos)
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	fx = E:create_entity("fx")
	fx.pos = V.vclone(target.pos)
	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].draw_order = 2
	fx.render.sprites[1].name = "fx_djinn_smoke"

	queue_insert(store, fx)
	-- AC:inc_check("STUFFOMAKER", 1)
	queue_remove(store, this)

	return true
end

scripts.twister = {}

function scripts.twister.insert(this, store, script)
	return true
end

function scripts.twister.update(this, store, script)
	local dmax = this.damage_max + this.aura.level * this.damage_inc
	local dmin = this.damage_min + this.aura.level * this.damage_inc
	local enemies_max = this.enemies_max + this.aura.level * this.enemies_inc

	U.animation_start(this, "start", nil, store.tick_ts, 1)

	while not U.animation_finished(this) do
		coroutine.yield()
	end

	S:queue("ArchmageTwisterTravel")
	U.animation_start(this, "travel", nil, store.tick_ts, -1)

	local np = this.nav_path

	np.ni = km.clamp(P:get_start_node(np.pi), P:get_end_node(np.pi), np.ni)

	local walk_nodes = this.nodes + this.aura.level * this.nodes_inc
	local nodes_step = -5
	local picked_enemies = this.picked_enemies
	local terrains = P:path_terrain_types(np.pi)

	terrains = band(terrains, bnot(TERRAIN_CLIFF))

	local last_node = P:get_start_node(np.pi) + this.nodes_limit

	for i = 1, math.ceil(walk_nodes / math.abs(nodes_step)) do
		if last_node >= np.ni and band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_CLIFF) == 0 then
			coroutine.yield()

			break
		end

		local next_pos = P:node_pos(np.pi, np.spi, np.ni + nodes_step)

		if P:is_node_valid(np.pi, np.ni + nodes_step, NF_TWISTER) and band(GR:cell_type(next_pos.x, next_pos.y), TERRAIN_CLIFF) == 0 then
			np.ni = np.ni + nodes_step
		end

		np.spi = np.spi == 2 and 3 or 2

		U.set_destination(this, P:node_pos(np.pi, np.spi, np.ni))

		while not this.motion.arrived do
			U.walk(this, store.tick_length)
			coroutine.yield()

			if this.interrupt then
				goto label_102_0
			end

			if enemies_max > #picked_enemies then
				local _, enemies = U.find_foremost_enemy(store.entities, this.pos, 0, this.pickup_range, false, this.aura.vis_flags, this.aura.vis_bans, function(e)
					return band(bnot(e.enemy.valid_terrains), terrains) == 0
				end)

				if enemies then
					for _, enemy in ipairs(enemies) do
						if enemies_max > #picked_enemies then
							log.debug("^ twister %s picked up (%s)-%s", this.id, enemy.id, enemy.template_name)
							-- AC:inc_check("FUJITA5", 1)
							table.insert(picked_enemies, enemy)
							SU.remove_modifiers(store, enemy)
							SU.remove_auras(store, enemy)
							queue_remove(store, enemy)

							enemy.health.dead = true
							enemy.health.last_damage_types = DAMAGE_EAT
							enemy.main_script.co = nil
							enemy.main_script.runs = 0

							U.unblock_all(store, enemy)

							if enemy.ui then
								enemy.ui.can_click = false
							end

							if enemy.count_group then
								enemy.count_group.in_limbo = true
							end
						end
					end
				end
			end
		end
	end

	for _, enemy in pairs(picked_enemies) do
		if not enemy.enemy.counts.twister then
			enemy.enemy.counts.twister = 1
		else
			enemy.enemy.counts.twister = enemy.enemy.counts.twister + 1
		end

		log.debug("v twister %s dropped (%s)-%s", this.id, enemy.id, enemy.template_name)

		enemy.nav_path.pi = np.pi
		enemy.nav_path.ni = km.clamp(1, #P:path(np.pi) - 1, math.random(-3, 3) + np.ni)
		enemy.pos = P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi, enemy.nav_path.ni)
		enemy.main_script.runs = 1
		enemy.health.dead = false

		if enemy.ui then
			enemy.ui.can_click = true
		end

		enemy.motion.forced_waypoint = nil

		queue_insert(store, enemy)
	end

	coroutine.yield()

	for _, enemy in pairs(picked_enemies) do
		local d = E:create_entity("damage")

		d.source_id = this.id
		d.target_id = enemy.id
		d.value = math.random(dmin, dmax)
		d.damage_type = this.damage_type

		queue_damage(store, d)
	end

	::label_102_0::

	this.picked_enemies = {}

	S:stop("ArchmageTwisterTravel")
	U.animation_start(this, "end", nil, store.tick_ts, 1)

	while not U.animation_finished(this) do
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.pestilence = {}

function scripts.pestilence.insert(this, store, script)
	local duration = this.aura.duration + this.aura.level * this.aura.duration_inc

	this.actual_duration = duration

	local count = 2 + this.aura.level
	local points = {}

	this.aura.ts = store.tick_ts

	for i = 1, count do
		points[i] = V.v(this.pos.x + math.random(-42, 42), this.pos.y + math.random(-42, 42))
	end

	for _, dest in pairs(points) do
		local decal = E:create_entity("decal_tween")

		decal.pos.x, decal.pos.y = dest.x, dest.y
		decal.tween.props[1].keys = {
			{
				0,
				0
			},
			{
				0.1,
				255
			},
			{
				duration,
				255
			},
			{
				duration + 1.2,
				0
			}
		}
		decal.tween.props[1].name = "alpha"
		decal.render.sprites[1].name = "NecroPestilenceDecal"
		decal.render.sprites[1].animated = false
		decal.render.sprites[1].z = Z_DECALS
		decal.render.sprites[1].ts = store.tick_ts

		queue_insert(store, decal)
	end

	local smoke_offsets = {
		V.v(-17, 5),
		V.v(6, 13),
		V.v(3, -5),
		V.v(23, 3)
	}

	for _, dest in pairs(points) do
		for i, off in ipairs(smoke_offsets) do
			local sm = E:create_entity("decal_tween")

			sm.pos.x, sm.pos.y = dest.x + off.x, dest.y + off.y
			sm.tween.props[1].keys = {
				{
					0,
					0
				},
				{
					0.1,
					255
				},
				{
					duration,
					255
				},
				{
					duration + 1.2,
					0
				}
			}
			sm.tween.props[1].name = "alpha"
			sm.render.sprites[1].name = "pestilence_fx_decal_smoke"
			sm.render.sprites[1].z = Z_OBJECTS
			sm.render.sprites[1].ts = store.tick_ts
			sm.render.sprites[1].time_offset = i * 6 / FPS

			queue_insert(store, sm)
		end
	end

	for _, dest in pairs(points) do
		local s = E:create_entity("decal_timed")

		s.pos.x, s.pos.y = dest.x, dest.y
		s.render.sprites[1].name = "pestilence_fx_start_smoke"
		s.render.sprites[1].ts = store.tick_ts
		s.render.sprites[1].time_offset = math.random(0, 3) / 30

		queue_insert(store, s)
	end

	return true
end

scripts.necromancer_aura = {}

function scripts.necromancer_aura.update(this, store, script)
	local last_ts = store.tick_ts
	local tower_skeletons_count = 0
	local cg = store.count_groups[this.count_group_type]

	while true do
		local source = store.entities[this.aura.source_id]

		if not source then
			queue_remove(store, this)

			return
		end

		if store.tick_ts - last_ts >= this.aura.cycle_time then
			last_ts = store.tick_ts
			tower_skeletons_count = 0

			for _, e in pairs(store.entities) do
				if e and e.health and not e.health.dead and e.soldier and e.soldier.tower_id == source.id and e.template_name ~= "soldier_death_rider" then
					tower_skeletons_count = tower_skeletons_count + 1
				end
			end

			local max_spawns = math.min(this.max_skeletons_tower - tower_skeletons_count, this.count_group_max - (cg[this.count_group_name] or 0))

			if max_spawns < 1 then
				-- block empty
			else
				local dead_enemies = table.filter(store.entities, function(k, v)
					return v.enemy and v.vis and v.health and v.health.dead and band(v.health.last_damage_types, bor(DAMAGE_EAT)) == 0 and band(v.vis.bans, F_SKELETON) == 0 and store.tick_ts - v.health.death_ts >= v.health.dead_lifetime - this.aura.cycle_time and U.is_inside_ellipse(v.pos, this.pos, source.attacks.range)
				end)

				dead_enemies = table.slice(dead_enemies, 1, max_spawns)

				for _, dead in pairs(dead_enemies) do
					dead.vis.bans = bor(dead.vis.bans, F_SKELETON)
					dead.health.delete_after = 0

					local e

					if dead.health.hp_max > this.min_health_for_knight then
						e = E:create_entity("soldier_skeleton_knight")
					else
						e = E:create_entity("soldier_skeleton")
					end

					e.pos = V.vclone(dead.pos)

					if dead.enemy.necromancer_offset then
						e.pos.x = e.pos.x + dead.enemy.necromancer_offset.x * (dead.render.sprites[1].flip_x and -1 or 1)
						e.pos.y = e.pos.y + dead.enemy.necromancer_offset.y
					end

					e.nav_rally.center = V.vclone(e.pos)
					e.nav_rally.pos = V.vclone(e.pos)
					e.soldier.tower_id = source.id

					queue_insert(store, e)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.aura_totem = {}

function scripts.aura_totem.update(this, store, script)
	local last_hit_ts = 0
	local a = this.aura
	local ring_sid = 1
	local ground_sid = 2
	local totem_sid = 3

	if GR:cell_is(this.pos.x, this.pos.y, TERRAIN_WATER) then
		local fx = E:create_entity("fx")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].name = "totem_water_fx_enter"
		fx.render.sprites[1].anchor.y = 0.09
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	this.render.sprites[ring_sid].ts = store.tick_ts

	U.animation_start(this, "start", nil, store.tick_ts, 1, totem_sid)

	while not U.animation_finished(this, totem_sid) do
		coroutine.yield()
	end

	while store.tick_ts - this.aura.ts < a.duration + a.duration_inc * a.level do
		local enemies = table.filter(store.entities, function(k, e)
			return e.enemy and e.vis and e.health and not e.health.dead and band(e.vis.flags, this.aura.vis_bans) == 0 and band(e.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(e.pos, this.pos, this.aura.radius)
		end)

		for _, enemy in pairs(enemies) do
			local new_mod = E:create_entity(this.aura.mod)

			new_mod.modifier.level = this.aura.level
			new_mod.modifier.target_id = enemy.id
			new_mod.modifier.source_id = this.id

			queue_insert(store, new_mod)
		end

		last_hit_ts = store.tick_ts

		while store.tick_ts - last_hit_ts < this.aura.cycle_time do
			coroutine.yield()
		end
	end

	if GR:cell_is(this.pos.x, this.pos.y, TERRAIN_WATER) then
		local fx = E:create_entity("fx")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].name = "totem_water_fx_exit"
		fx.render.sprites[1].anchor.y = 0.09
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	this.render.sprites[ground_sid].hidden = true
	this.render.sprites[ring_sid].hidden = true

	S:queue("TotemVanish")
	U.animation_start(this, "end", nil, store.tick_ts, 1, totem_sid)

	while not U.animation_finished(this, totem_sid) do
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.aura_damage_sprint = {}

function scripts.aura_damage_sprint.insert(this, store, script)
	local target = store.entities[this.aura.source_id]

	if not target or target.health.dead or not target.motion then
		return false
	end

	if not target.damage_sprint_factor then
		log.error("Target %s has no damage_sprint_factor property. Aura discarded.", this.aura.source_id)

		return false
	end

	this.last_sprint_factor = 1
	this.aura.ts = store.tick_ts

	return true
end

function scripts.aura_damage_sprint.remove(this, store, script)
	local target = store.entities[this.aura.source_id]

	if target and target.health and target.motion then
		log.paranoid("aura_damage_sprint.remove: current max_speed: %s / prev: %s", target.motion.max_speed, this.last_sprint_factor)

		target.motion.max_speed = target.motion.max_speed / this.last_sprint_factor
	end

	return true
end

function scripts.aura_damage_sprint.update(this, store, script)
	while true do
		local target = store.entities[this.aura.source_id]

		if not target or target.health.dead or not target.motion then
			queue_remove(store, this)

			return
		end

		if this.last_sprint_hp ~= target.health.hp then
			local hp, hp_max = target.health.hp, target.health.hp_max
			local sprint_factor = 1 + (hp_max - hp) / hp_max * target.damage_sprint_factor

			log.paranoid("aura_damage_sprint.update: current max_speed: %s / %s * %s", target.motion.max_speed, this.last_sprint_factor, sprint_factor)

			target.motion.max_speed = target.motion.max_speed / this.last_sprint_factor * sprint_factor
			this.last_sprint_hp = target.health.hp
			this.last_sprint_factor = sprint_factor
		end

		coroutine.yield()
	end
end

scripts.bluegale_clouds = {}

function scripts.bluegale_clouds.insert(this, store, script)
	this.aura.ts = store.tick_ts

	if this.spawn_on_insert then
		for _, n in pairs(this.spawn_on_insert) do
			local e = E:create_entity(n)

			e.pos = V.vclone(this.pos)

			queue_insert(store, e)
		end
	end

	return true
end

function scripts.bluegale_clouds.update(this, store, script)
	local start_ts = store.tick_ts
	local points = {}
	local ang = U.frandom(math.pi / 3, 2 * math.pi / 3)
	local dist = U.frandom(this.clouds_min_radius, this.clouds_max_radius)

	points[1] = V.vclone(this.pos)

	for i = 2, this.clouds_count do
		local ox, oy = V.rotate(ang, dist, 0)

		oy = oy * ASPECT
		points[i] = V.v(this.pos.x + ox, this.pos.y + oy)
		ang = ang + U.frandom(math.pi / 3, 2 * math.pi / 3)

		if ang > 2 * math.pi then
			ang = 0
			dist = dist + U.frandom(this.clouds_min_radius, this.clouds_max_radius)
		end
	end

	for i, dest in ipairs(points) do
		local ah = E:create_entity("bluegale_heal_aura")

		ah.pos = V.v(dest.x, dest.y - 30)
		ah.aura.source_id = this.source_id

		queue_insert(store, ah)

		local ad = E:create_entity("bluegale_damage_aura")

		ad.pos = V.v(dest.x, dest.y - 30)
		ad.aura.source_id = this.source_id

		queue_insert(store, ad)
	end

	local duration = this.aura.duration

	for i, dest in ipairs(points) do
		local delay = i * 0.15
		local max_alpha = 255
		local c_dark = E:create_entity("decal_bluegale_cloud_dark")

		c_dark.pos.x, c_dark.pos.y = dest.x, dest.y
		c_dark.tween.props[1].keys = {
			{
				0,
				0
			},
			{
				0.1,
				max_alpha
			},
			{
				duration,
				max_alpha
			},
			{
				duration + 0.5,
				0
			}
		}
		c_dark.render.sprites[1].ts = store.tick_ts + delay

		queue_insert(store, c_dark)

		local c_light = E:create_entity("decal_bluegale_cloud_bright")

		c_light.pos.x, c_light.pos.y = dest.x, dest.y
		c_light.tween.props[1].keys = {
			{
				0,
				0
			},
			{
				0.1,
				max_alpha
			},
			{
				0.2,
				0
			},
			{
				1,
				0
			}
		}
		c_light.tween.props[3].keys = {
			{
				0,
				false
			},
			{
				duration + 0.5,
				true
			}
		}
		c_light.render.sprites[1].ts = store.tick_ts + delay

		queue_insert(store, c_light)

		local c_shadow = E:create_entity("decal_bluegale_cloud_shadow")

		c_shadow.pos.x, c_shadow.pos.y = dest.x, dest.y - 40
		c_shadow.tween.props[1].keys = {
			{
				0,
				0
			},
			{
				0.1,
				255
			},
			{
				duration,
				255
			},
			{
				duration + 0.5,
				0
			}
		}
		c_shadow.render.sprites[1].ts = store.tick_ts + delay

		queue_insert(store, c_shadow)
	end

	U.y_wait(store, 1)

	while store.tick_ts - start_ts < this.aura.duration do
		S:queue("RTBluegaleStormAmbience")
		U.y_wait(store, U.frandom(1, 4))
	end

	queue_remove(store, this)
end

scripts.mod_crossbow_eagle = {}

function scripts.mod_crossbow_eagle.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.tower then
		log.error("cannot insert mod_crossbow_eagle to entity %s - ", target.id, target.template_name)

		return false
	end

	if target.attacks then
		target.attacks.range = target.attacks.range * (this.range_factor + m.level * this.range_factor_inc)
	end

	if target.barrack then
		target.barrack.rally_range = target.barrack.rally_range * (this.range_factor + m.level * this.range_factor_inc)
	end

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_crossbow_eagle.remove(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target and target.attacks then
		target.attacks.range = target.attacks.range / (this.range_factor + m.level * this.range_factor_inc)
	end

	if target and target.barrack then
		target.barrack.rally_range = target.barrack.rally_range / (this.range_factor + m.level * this.range_factor_inc)
	end

	return true
end

scripts.mod_death_rider = {}

function scripts.mod_death_rider.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	target.health.armor = target.health.armor + this.extra_armor
	target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor

	return true
end

function scripts.mod_death_rider.remove(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.health.armor = target.health.armor - this.extra_armor
		target.unit.damage_factor = target.unit.damage_factor / this.inflicted_damage_factor
	end

	return true
end

scripts.decal_frog = {}

function scripts.decal_frog.update(this, store, script)
	while true do
		this.render.sprites[1].hidden = true

		U.y_wait(store, 60)

		this.render.sprites[1].hidden = false

		U.y_animation_play(this, "enter", nil, store.tick_ts, 1)

		this.ui.clicked = nil

		local idle_ts = store.tick_ts

		while store.tick_ts < idle_ts + 5 do
			if this.ui.clicked then
				S:queue("SpecialFrog")
				U.y_animation_play(this, "dance", nil, store.tick_ts, 1)
				AC:got("ONEFROGGYEVENING")
				queue_remove(store, this)

				return
			end

			coroutine.yield()
		end

		U.y_animation_play(this, "exit", nil, store.tick_ts, 1)
	end
end

scripts.decal_bantha = {}

function scripts.decal_bantha.update(this, store, script)
	local clicks = 0
	local s = this.render.sprites[1]
	local eat_delay = fts(260)
	local eat_ts = store.tick_ts + U.frandom(0, eat_delay)

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			clicks = clicks + 1

			U.animation_start(this, "clicked", nil, store.tick_ts, false)
			S:queue("SpecialBanthaRoar")
		end

		if clicks > 10 then
			S:queue("SpecialBanthaFart", {
				delay = 1
			})
			U.animation_start(this, "shit", nil, store.tick_ts, false)

			while store.tick_ts < s.ts + fts(46) do
				coroutine.yield()
			end

			local ts = store.tick_ts
			local start_x = this.pos.x
			local offset = (s.flip_x and 1 or -1) * 100
			local travel_duration = fts(57)

			while store.tick_ts < ts + travel_duration do
				local phase = (store.tick_ts - ts) / travel_duration

				this.pos.x = start_x + (1 - math.pow(phase - 1, 4)) * offset

				coroutine.yield()
			end

			U.y_animation_wait(this)
			U.y_wait(store, 1)

			s.flip_x = not s.flip_x
			this.ui.clicked = nil
			clicks = 0

			U.animation_start(this, "idle", nil, store.tick_ts)
			AC:got("ORGANICPROPULSION")
		end

		if store.tick_ts > eat_ts + eat_delay then
			U.animation_start(this, "eat", nil, store.tick_ts, false)

			eat_ts = store.tick_ts
		end

		coroutine.yield()
	end
end

scripts.decal_tusken = {}

function scripts.decal_tusken.update(this, store, script)
	local a = this.bullet_attack

	a.cooldown = U.frandom(a.cooldown_min, a.cooldown_max)

	while true do
		U.animation_start(this, "idle", nil, store.tick_ts)

		local targets = table.filter(store.entities, function(_, e)
			return e.soldier and e.soldier.target_id and e.health and not e.health.dead and U.is_inside_ellipse(e.pos, this.target_center, a.max_range)
		end)

		if #targets == 0 then
			U.y_wait(store, 1)
		else
			local attack_ts = store.tick_ts
			local target = targets[1]

			if math.random() < 0.7 then
				target = store.entities[target.soldier.target_id]
			end

			if target and target.health and not target.health.dead then
				local b = E:create_entity(a.bullet)

				b.bullet.from = V.v(this.pos.x + a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y)
				b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id
				b.pos = V.vclone(b.bullet.from)

				U.animation_start(this, a.animation, nil, store.tick_ts)
				S:queue("SpecialTusken", {
					delay = fts(19)
				})
				U.y_wait(store, a.shoot_time)
				queue_insert(store, b)
				S:queue("ShotgunSound")
				U.y_animation_wait(this)
				U.y_wait(store, a.cooldown - (store.tick_ts - attack_ts))
			end
		end
	end
end

scripts.sand_worm = {}

function scripts.sand_worm.update(this, store, script)
	local s = this.render.sprites[1]
	local a = this.area_attack

	s.hidden = true

	while true do
		U.y_wait(store, a.cooldown / 2)

		::label_122_0::

		U.y_wait(store, a.cooldown / 2)

		local best_count = -1
		local target

		for _, ce in pairs(store.entities) do
			if ce.soldier and ce.soldier.target_id and not ce.health.dead and band(ce.vis.flags, a.vis_bans) == 0 and band(ce.vis.bans, a.vis_flags) == 0 and P:valid_node_nearby(ce.pos.x, ce.pos.y) then
				local nearby = table.filter(store.entities, function(_, e)
					return e.soldier and e.soldier.target_id and e ~= ce and e.health and not e.health.dead and e.vis and band(e.vis.flags, a.vis_bans) == 0 and band(e.vis.bans, a.vis_flags) == 0 and U.is_inside_ellipse(e.pos, ce.pos, a.max_range)
				end)

				if best_count < #nearby then
					target = ce
				end
			end
		end

		if not target then
			local targets = table.filter(store.entities, function(k, v)
				return v.soldier and v.health and not v.health.dead and v.vis and band(v.vis.flags, a.vis_bans) == 0 and band(v.vis.bans, a.vis_flags) == 0 and v.template_name ~= "soldier_djinn" and v.template_name ~= "soldier_legionnaire" and P:valid_node_nearby(v.pos.x, v.pos.y)
			end)

			if #targets > 0 then
				target = table.random(targets)
			end
		end

		if not target then
			goto label_122_0
		end

		local nodes = P:nearest_nodes(target.pos.x, target.pos.y)

		if #nodes < 1 then
			goto label_122_0
		end

		local attack_pos = P:node_pos(nodes[1][1], 1, nodes[1][3])
		local fx = E:create_entity("fx_sand_worm_incoming")

		fx.pos = attack_pos
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
		S:queue("SpecialWormDirtSound")
		U.y_wait(store, a.hit_time)
		S:stop("SpecialWormDirtSound")
		queue_remove(store, fx)

		this.pos = attack_pos
		s.hidden = false

		U.animation_start(this, a.animation, nil, store.tick_ts, false)
		S:queue("SpecialWormBite")

		local victims = table.filter(store.entities, function(_, e)
			return (e.soldier or e.enemy) and e.vis and band(e.vis.flags, a.vis_bans) == 0 and band(e.vis.bans, a.vis_flags) == 0 and U.is_inside_ellipse(e.pos, attack_pos, a.max_range)
		end)

		for _, v in pairs(victims) do
			if v.health.dead then
				v.render.sprites[1].hidden = true
			else
				local d = E:create_entity("damage")

				d.source_id = this.id
				d.target_id = v.id
				d.damage_type = a.damage_type

				queue_damage(store, d)
			end
		end

		local decal = E:create_entity("fx_sand_worm_out")

		decal.pos = attack_pos
		decal.render.sprites[1].ts = store.tick_ts

		queue_insert(store, decal)
		U.y_animation_wait(this)

		s.hidden = true
	end
end

scripts.decal_mermaid = {}

function scripts.decal_mermaid.update(this, store, script)
	while true do
		this.render.sprites[1].hidden = true

		U.y_wait(store, math.random(60, 150))

		this.render.sprites[1].hidden = false

		U.animation_start(this, "enter", nil, store.tick_ts, 1)
		S:queue("SpecialMermaid", {
			delay = fts(85)
		})

		this.ui.clicked = nil

		while not U.animation_finished(this) do
			if this.ui.clicked then
				AC:got("SPLASH")

				this.ui.clicked = nil
			end

			coroutine.yield()
		end
	end
end

scripts.pirate_cannons = {}

function scripts.pirate_cannons.update(this, store, script)
	local cooldown, decal
	local a = this.attacks.list[1]

	a.ts = store.tick_ts

	while true do
		a.cooldown = U.frandom(a.min_cooldown, a.max_cooldown)

		if store.tick_ts - a.ts > a.cooldown then
			local targets = table.filter(store.entities, function(_, e)
				return e and e.soldier and e.health and not e.health.dead and e.soldier.target_id ~= nil and e.motion and V.veq(e.motion.speed, V.v(0, 0)) and e.vis and band(e.vis.flags, a.vis_bans) == 0 and band(e.vis.bans, a.vis_flags) == 0 and U.is_inside_ellipse(e.pos, this.pos, a.max_range) and not U.is_inside_ellipse(e.pos, this.pos, a.min_range)
			end)
			local target = targets[math.random(1, #targets)]

			if not target then
				-- block empty
			else
				decal = E:create_entity("decal_pirate_cannon_target")
				decal.pos = V.vclone(target.pos)
				decal.render.sprites[1].ts = store.tick_ts

				queue_insert(store, decal)
				U.animation_start(this, "fire", nil, store.tick_ts, false)
				U.y_wait(store, a.shoot_time)
				S:queue("PirateBombShootSound")

				local dest = V.vclone(target.pos)

				U.y_wait(store, fts(28))

				local b1 = E:create_entity("bomb_pirate_cannon")
				local b2 = E:create_entity("bomb_pirate_cannon")

				b1.bullet.to = V.v(dest.x + U.random_sign() * math.random(a.min_error, a.max_error), dest.y + U.random_sign() * math.random(a.min_error, a.max_error))
				b2.bullet.to = V.v(dest.x + U.random_sign() * math.random(a.min_error, a.max_error), dest.y + U.random_sign() * math.random(a.min_error, a.max_error))
				b1.pos = b1.bullet.to
				b2.pos = b2.bullet.to

				queue_insert(store, b1)
				U.y_wait(store, fts(4))
				queue_insert(store, b2)
				U.y_animation_wait(this)

				a.ts = store.tick_ts
			end
		end

		coroutine.yield()
	end
end

scripts.bomb_pirate_cannon = {}

function scripts.bomb_pirate_cannon.update(this, store, script)
	local b = this.bullet

	S:queue(this.sound_events.hit)

	local targets = table.filter(store.entities, function(_, e)
		return e and e.health and not e.health.dead and e.vis and band(e.vis.flags, b.damage_bans) == 0 and band(e.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(e.pos, b.to, b.damage_radius)
	end)

	for _, target in pairs(targets) do
		local d = E:create_entity("damage")

		d.damage_type = b.damage_type
		d.value = b.damage_min + math.ceil(U.frandom(0, b.damage_max - b.damage_min))
		d.source_id = this.id
		d.target_id = target.id

		queue_damage(store, d)
	end

	local p = SU.create_bullet_pop(store, this)

	queue_insert(store, p)

	local sfx = E:create_entity(b.hit_fx)

	sfx.pos = V.vclone(b.to)
	sfx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, sfx)

	local decal = E:create_entity(b.hit_decal)

	decal.pos = V.vclone(b.to)
	decal.render.sprites[1].ts = store.tick_ts

	queue_insert(store, decal)
	queue_remove(store, this)
end

scripts.tower_pirate_camp = {}

function scripts.tower_pirate_camp.get_info(this)
	return {
		desc = "TOWER_PIRATE_CAMP_DESCRIPTION",
		type = STATS_TYPE_TEXT
	}
end

function scripts.tower_pirate_camp.can_select_point(this, x, y)
	return P:valid_node_nearby(x, y)
end

function scripts.tower_pirate_camp.update(this, store, script)
	local cannon_sids = {
		5,
		6,
		7
	}
	local sign_cannon = this.render.sprites[3]
	local sign_tap_the_road = this.render.sprites[4]
	local sign_cannon_last_ts = store.tick_ts
	local pirate_drink_ts = store.tick_ts
	local pirate_drink_time = math.random(fts(100), fts(300))

	local function fire_animation(id)
		U.animation_start(this, "fire", nil, store.tick_ts, false, cannon_sids[id])
	end

	local function add_smoke(id)
		local s = this.render.sprites[cannon_sids[id]]
		local smoke = E:create_entity("fx_tower_pirate_camp_cannon_smoke")

		smoke.render.sprites[1].ts = store.tick_ts
		smoke.pos = V.v(s.pos.x + 16, s.pos.y + 9)

		queue_insert(store, smoke)
	end

	local function add_bullet(id, dest)
		local a = this.attacks.list[1]
		local b = E:create_entity("bomb_pirate_camp")

		b.pos = V.v(dest.x + U.random_sign() * math.random(a.min_error, a.max_error), dest.y + U.random_sign() * math.random(a.min_error, a.max_error))
		b.bullet.to = b.pos

		queue_insert(store, b)
	end

	while true do
		if pirate_drink_time < store.tick_ts - pirate_drink_ts then
			U.animation_start(this, "drink", nil, store.tick_ts, false, 8)

			pirate_drink_ts = store.tick_ts
		end

		if store.tick_ts - sign_cannon_last_ts > 10 then
			sign_cannon_last_ts = store.tick_ts
			sign_cannon.ts = store.tick_ts
			sign_cannon.hidden = false
		end

		if this.user_selection.menu_shown or this.user_selection.in_progress then
			sign_cannon_last_ts = store.tick_ts + 10
			sign_cannon.hidden = true
		end

		if this.user_selection.new_pos then
			local shots = this.user_selection.arg
			local dest = this.user_selection.new_pos

			this.user_selection.new_pos = nil

			local attack = this.attacks.list[shots]

			store.player_gold = store.player_gold - attack.price

			local decal = E:create_entity("decal_tower_pirate_camp_target")

			decal.pos = V.vclone(dest)
			decal.render.sprites[1].ts = store.tick_ts

			queue_insert(store, decal)

			local start_ts = store.tick_ts

			for i = 1, 3 do
				if i <= shots then
					fire_animation(i)
					U.y_wait(store, fts(5))
					S:queue("PirateBombShootSound")
					add_smoke(i)
				end
			end

			U.y_wait(store, fts(30) - (store.tick_ts - start_ts))

			for i = 1, 3 do
				if i <= shots then
					add_bullet(i, dest)
				end

				U.y_wait(store, fts(6))
			end

			U.y_animation_wait(this, cannon_sids[1])
		end

		coroutine.yield()
	end
end

scripts.decal_camel = {}

function scripts.decal_camel.update(this, store, script)
	local clicks = 0
	local eat_delay = U.frandom(fts(30), fts(150)) + fts(30)
	local eat_ts = store.tick_ts + U.frandom(0, eat_delay)
	local s = this.render.sprites[1]

	if math.random() < 0.5 then
		s.flip_x = true
	end

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			clicks = clicks + 1

			U.animation_start(this, "idle", nil, store.tick_ts, false)

			s.ts = store.tick_ts
			this.tween.props[1].ts = store.tick_ts
			this.tween.disabled = false
		end

		if clicks > 8 then
			S:queue("DeathEplosion")

			local fx = E:create_entity("fx_unit_explode")

			fx.pos = V.vclone(this.pos)
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].name = "small"

			queue_insert(store, fx)
			queue_remove(store, this)

			return
		end

		if store.tick_ts > eat_ts + eat_delay then
			U.animation_start(this, "eat", nil, store.tick_ts, false)

			eat_ts = store.tick_ts
		end

		coroutine.yield()
	end
end

scripts.decal_efreeti_door = {}

function scripts.decal_efreeti_door.update(this, store, script)
	local floor_sid, door_sid, statue_left_sid, statue_right_sid, eyes_sid, eyes_fx_sid = 1, 2, 4, 5, 6, 7

	while true do
		while this.phase ~= "eyes" do
			coroutine.yield()
		end

		local eyes, eyesfx = this.render.sprites[eyes_sid], this.render.sprites[eyes_fx_sid]

		eyes.ts = store.tick_ts
		eyes.hidden = false

		S:queue("BossEfreetiSpawnBoss")
		U.y_wait(store, 1.5)

		this.phase = "show_boss"
		eyesfx.ts = store.tick_ts
		eyesfx.hidden = false

		U.y_animation_wait(this, eyes_sid)

		eyes.hidden = true
		eyesfx.hidden = true

		while this.phase ~= "destruction" do
			coroutine.yield()
		end

		U.animation_start(this, "destruction", nil, store.tick_ts, false, door_sid)
		U.animation_start(this, "destruction", nil, store.tick_ts, false, floor_sid)
		S:queue("BossEfreetiDoors")
		U.y_wait(store, 0.9)

		for _, p in pairs(this.smoke_positions) do
			local fx = E:create_entity("fx")

			fx.pos.x, fx.pos.y = p.x, p.y
			fx.render.sprites[1].name = "efreeti_door_smoke"
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)
		end

		for _, p in pairs(this.stone_positions) do
			local fx = E:create_entity("fx")

			fx.pos.x, fx.pos.y = p[1].x, p[1].y
			fx.render.sprites[1].name = "efreeti_door_stone"
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].scale = V.v(p[2], p[2])
			fx.render.sprites[1].flip_x = p[3]

			queue_insert(store, fx)
		end

		this.render.sprites[statue_left_sid].name = "left"
		this.render.sprites[statue_right_sid].name = "right"

		U.y_animation_wait(this, floor_sid)

		this.render.sprites[floor_sid].hidden = true

		U.y_wait(store, 3)

		this.phase = "finished"
	end
end

scripts.decal_monkey_banana = {}

function scripts.decal_monkey_banana.update(this, store, script)
	this.render.sprites[1].hidden = true

	local a = this.bullet_attack

	a.cooldown = U.frandom(a.cooldown_min, a.cooldown_max)

	while true do
		local targets = table.filter(store.entities, function(_, e)
			return e.enemy and e.health and not e.health.dead and U.is_inside_ellipse(e.pos, this.pos, a.max_range)
		end)

		if #targets == 0 then
			U.y_wait(store, 1)
		else
			local attack_ts = store.tick_ts
			local target = targets[1]

			this.render.sprites[1].hidden = false

			local flip = false

			if target.pos.x < this.pos.x then
				flip = true
			end

			U.animation_start(this, a.animation, flip, store.tick_ts)
			U.y_wait(store, a.shoot_time)

			local b = E:create_entity(a.bullet)

			b.bullet.from = V.v(this.pos.x + a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y)
			b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
			b.bullet.target_id = target.id
			b.bullet.source_id = this.id
			b.pos = V.vclone(b.bullet.from)

			queue_insert(store, b)
			U.y_animation_wait(this)

			this.render.sprites[1].hidden = true

			U.y_wait(store, a.cooldown - (store.tick_ts - attack_ts))
		end
	end
end

scripts.decal_bouncing_bridge = {}

function scripts.decal_bouncing_bridge.update(this, store, script)
	local last_loaded = false

	while true do
		local loaded = false

		for _, e in pairs(store.entities) do
			if (e.enemy or e.soldier) and not e.health.dead and e.vis and not U.flag_has(e.vis.flags, F_FLYING) and U.is_inside_ellipse(e.pos, this.pos, this.bridge_width / 2) then
				loaded = true

				break
			end
		end

		if loaded ~= last_loaded then
			if loaded then
				U.animation_start(this, "bounce", nil, store.tick_ts, true)
			else
				U.animation_start(this, "idle", nil, store.tick_ts)
			end

			last_loaded = loaded
		end

		U.y_wait(store, fts(10))
	end
end

scripts.decal_water_bottle = {}

function scripts.decal_water_bottle.update(this, store, script)
	local start_pi, start_spi, start_ni = this.nav_path.pi, this.nav_path.spi, this.nav_path.ni

	while true do
		this.pos = P:node_pos(start_pi, start_spi, start_ni)
		this.nav_path.pi, this.nav_path.spi, this.nav_path.ni = start_pi, start_spi, start_ni

		U.animation_start(this, "idle", nil, store.tick_ts, true)

		local next, new

		while true do
			next, new = P:next_entity_node(this, store.tick_length)

			if next == nil or this.ui.clicked then
				break
			end

			U.set_destination(this, next)
			U.walk(this, store.tick_length)
			coroutine.yield()
		end

		if this.ui.clicked then
			this.ui.clicked = nil

			AC:got("SOSTOTHEWORLD")
		end

		U.y_animation_play(this, "sink", nil, store.tick_ts)
		U.y_wait(store, this.delay)
	end
end

scripts.carnivorous_plant = {}

function scripts.carnivorous_plant.update(this, store, script)
	local a = this.area_attack

	U.animation_start(this, "inactive", nil, store.tick_ts, true)

	while store.wave_group_number < this.activates_on_wave do
		coroutine.yield()
	end

	U.y_animation_play(this, "activate", nil, store.tick_ts)
	U.animation_start(this, "idle", nil, store.tick_ts, true)

	local attack_ts = store.tick_ts

	while true do
		while store.tick_ts - attack_ts < a.cooldown do
			coroutine.yield()
		end

		local trigger

		for _, e in pairs(store.entities) do
			if (e.enemy or e.soldier) and e.health and not e.health.dead and band(e.vis.bans, a.vis_flags) == 0 and band(e.vis.flags, a.vis_bans) == 0 and U.is_inside_ellipse(e.pos, this.attack_pos, a.damage_radius) then
				trigger = e

				break
			end
		end

		if not trigger then
			attack_ts = store.tick_ts - a.cooldown + 1
		else
			attack_ts = store.tick_ts

			local attack_animation = this.attack_pos.y > this.pos.y and "attack_up" or "attack_down"

			U.animation_start(this, attack_animation, nil, store.tick_ts)
			U.y_wait(store, a.hit_time)
			S:queue("SpecialCarnivorePlant")

			local e = E:create_entity("pop_slurp")
			local x_off = this.render.sprites[1].flip_x and -40 or 40
			local y_off = this.attack_pos.y > this.pos.y and 40 or -50

			e.pos = V.v(this.pos.x + x_off, this.pos.y + e.pop_y_offset + y_off)
			e.render.sprites[1].r = math.random(-21, 21) * math.pi / 180
			e.render.sprites[1].ts = store.tick_ts

			queue_insert(store, e)

			local targets = table.filter(store.entities, function(_, e)
				return (e.enemy or e.soldier) and e.health and not e.health.dead and e.vis and band(e.vis.bans, a.vis_flags) == 0 and band(e.vis.flags, a.vis_bans) == 0 and U.is_inside_ellipse(e.pos, this.attack_pos, a.damage_radius)
			end)

			if #targets > 0 then
				for _, target in pairs(targets) do
					local d = E:create_entity("damage")

					d.damage_type = a.damage_type
					d.source_id = this.id
					d.target_id = target.id

					queue_damage(store, d)
				end
			end

			U.y_animation_wait(this)
			U.animation_start(this, "idle", nil, store.tick_ts, true)
		end
	end
end

scripts.decal_volcano_virgin = {}

function scripts.decal_volcano_virgin.update(this, store, script)
	U.y_animation_play(this, "heart", nil, store.tick_ts, 1)
	U.y_wait(store, 1)

	local dist = 25
	local eta = dist / this.motion.max_speed
	local fade_step = 255 / (eta / store.tick_length)

	U.animation_start(this, "walk", false, store.tick_ts, true)
	U.set_destination(this, V.v(this.pos.x + dist, this.pos.y))

	while not this.motion.arrived do
		U.walk(this, store.tick_length)

		this.render.sprites[1].alpha = km.clamp(0, 255, this.render.sprites[1].alpha - fade_step)

		coroutine.yield()
	end

	AC:got("SAVETHEPRINCESS")
	queue_remove(store, this)
end

scripts.decal_indiana_boulder = {}

function scripts.decal_indiana_boulder.update(this, store, script)
	while not U.walk(this, store.tick_length) do
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.enemy_gorilla_small = {}

function scripts.enemy_gorilla_small.insert(this, store, script)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y)

	if #nodes < 1 then
		log.error("could not insert enemy_gorilla_small: no nodes near %s,%s", this.pos.x, this.pos.y)

		return false
	end

	this.nav_path.pi = nodes[1][1]
	this.nav_path.spi = nodes[1][2]
	this.nav_path.ni = nodes[1][3] + 3

	return scripts.enemy_basic.insert(this, store, script)
end

scripts.gorilla_small_liana = {}

function scripts.gorilla_small_liana.update(this, store, script)
	this.render.sprites[1].hidden = true

	U.y_wait(store, this.delay)

	this.render.sprites[1].hidden = false
	this.render.sprites[1].ts = store.tick_ts

	local right_side = this.render.sprites[1].flip_x

	U.y_wait(store, this.spawn_time - store.tick_length)

	local spawn = E:create_entity(this.spawn_name)
	local o = right_side and this.spawn_offset[1] or this.spawn_offset[2]

	spawn.pos.x, spawn.pos.y = this.pos.x + o.x, this.pos.y + o.y
	spawn.bullet.from = V.vclone(spawn.pos)
	spawn.bullet.to = V.vclone(this.spawn_dest)
	spawn.render.sprites[1].flip_x = right_side

	queue_insert(store, spawn)
	U.y_animation_wait(this)
	queue_remove(store, this)
end

scripts.decal_black_dragon = {}

function scripts.decal_black_dragon.update(this, store, script)
	local image_x = 192
	local start_x = store.visible_coords.left - image_x / 2
	local end_x = store.visible_coords.right + image_x / 2
	local wakeup_ts = 0
	local wakeup_cooldown = math.random(this.wakeup_cooldown_min, this.wakeup_cooldown_max)
	local force_wakeup = false
	local flame_comp_x = 180
	local fire_comp_x = 120
	local ps_flame_offset = V.v(-60, 88)
	local ps_fire_offset = V.v(-115, 0)
	local ps_flame = E:create_entity("ps_black_dragon_flame")

	ps_flame.particle_system.track_id = this.id
	ps_flame.particle_system.emit = false
	ps_flame.particle_system.track_offset = V.vclone(ps_flame_offset)

	queue_insert(store, ps_flame)

	local ps_fire = E:create_entity("ps_black_dragon_fire")

	ps_fire.particle_system.track_id = this.id
	ps_fire.particle_system.emit = false
	ps_fire.particle_system.track_offset = V.vclone(ps_fire_offset)

	queue_insert(store, ps_fire)

	local s = this.render.sprites[1]
	local zzz = this.render.sprites[2]
	local shadow = this.render.sprites[3]
	local flame_hit = this.render.sprites[4]
	local ma = this.attacks.list[1]
	local shadow_offset = 49
	local shadow_ref_height = 50

	shadow.scale = V.v(1, 1)

	local function update_shadow()
		local dy = this.pos.y - this.sleep_pos.y
		local scale = km.clamp(0, 1, 1 - dy / shadow_ref_height)

		shadow.scale.x, shadow.scale.y = scale, scale
		shadow.offset.y = shadow_offset - dy
	end

	::label_149_0::

	while true do
		if this.attack_requested then
			local ar = this.attack_requested
			local ap = this.dragon_paths[ar.path]

			this.attack_requested = nil
			shadow.hidden = false

			update_shadow()
			S:queue(this.sound_events.wakeup, {
				delay = fts(13)
			})
			U.y_animation_play(this, "takeoff", nil, store.tick_ts, 1, 1)

			this.can_steal_gold = true

			U.animation_start(this, "flying", nil, store.tick_ts, true, 1)

			this.render.sprites[1].sort_y_offset = -200
			this.motion.max_speed = this.speed_takeoff

			U.set_destination(this, V.v(150, REF_H + 100))

			while not this.motion.arrived do
				U.walk(this, store.tick_length)
				update_shadow()
				coroutine.yield()
			end

			shadow.hidden = true

			local flip = start_x < end_x

			ps_flame.particle_system.track_offset.x = ps_flame_offset.x * (flip and -1 or 1)
			ps_fire.particle_system.track_offset.x = ps_fire_offset.x * (flip and -1 or 1)
			flame_hit.flip_x = flip
			s.flip_x = flip
			this.pos.x, this.pos.y = start_x, ap.y
			this.motion.max_speed = this.speed_fly

			U.set_destination(this, V.v(end_x, ap.y))

			local flame_on, fire_on = false, false
			local flame_i, flame_x = next(ap.x_ranges)
			local fire_i, fire_x = next(ap.x_ranges)

			s.loop_forced = true

			while not this.motion.arrived do
				if flame_x and flame_x < this.pos.x + flame_comp_x then
					flame_i, flame_x = next(ap.x_ranges, flame_i)
					flame_on = not flame_on

					if flame_on then
						S:queue(this.sound_events.fire)

						ps_flame.particle_system.emit = true

						U.animation_start(this, "firing", nil, store.tick_ts, true, 1)
					else
						ps_flame.particle_system.emit = false

						U.animation_start(this, "flying", nil, store.tick_ts, true, 1)
					end
				end

				if fire_x and fire_x < this.pos.x + fire_comp_x then
					fire_i, fire_x = next(ap.x_ranges, fire_i)
					fire_on = not fire_on
					ps_fire.particle_system.emit = fire_on
					flame_hit.hidden = not fire_on

					if not fire_on then
						local fx = E:create_entity("fx_black_dragon_flame_hit")

						fx.pos.x, fx.pos.y = this.pos.x + (flip and 1 or -1) * flame_hit.offset.x, this.pos.y + flame_hit.offset.y
						fx.render.sprites[1].ts = store.tick_ts

						queue_insert(store, fx)
					end
				end

				if fire_on then
					local towers = table.filter(store.entities, function(_, e)
						return e.tower and not e.tower_holder and V.dist(e.pos.x, e.pos.y, this.pos.x + fire_comp_x, this.pos.y) < ma.range and not e.tower.blocked
					end)

					for i, tower in ipairs(towers) do
						local m = E:create_entity(ma.mod)

						m.pos = tower.pos
						m.modifier.target_id = tower.id
						m.modifier.source_id = this.id
						m.modifier.duration = math.random(ar.min_time, ar.max_time)

						queue_insert(store, m)
					end
				end

				U.walk(this, store.tick_length)
				coroutine.yield()
			end

			s.loop_forced = false

			U.y_wait(store, 2)

			this.can_steal_gold = false
			shadow.hidden = false

			update_shadow()
			U.animation_start(this, "flying", false, store.tick_ts, true, 1)

			this.pos.x, this.pos.y = this.sleep_pos.x - 5, this.sleep_pos.y + 116
			this.motion.max_speed = this.speed_takeoff

			U.set_destination(this, this.sleep_pos)

			while not this.motion.arrived do
				U.walk(this, store.tick_length)
				update_shadow()
				coroutine.yield()
			end

			U.y_animation_play(this, "land", nil, store.tick_ts, 1, 1)
			U.animation_start(this, "idle", nil, store.tick_ts, true, 1)

			shadow.hidden = false
			this.render.sprites[1].sort_y_offset = 0
		elseif force_wakeup or wakeup_cooldown < store.tick_ts - wakeup_ts then
			force_wakeup = nil
			wakeup_ts = store.tick_ts

			S:queue(this.sound_events.wakeup, {
				delay = fts(13)
			})
			U.y_animation_play(this, "wakeup", nil, store.tick_ts, 1, 1)

			wakeup_cooldown = math.random(this.wakeup_cooldown_min, this.wakeup_cooldown_max)
		else
			this.ui.clicked = nil
			zzz.hidden = false
			zzz.alpha = 255

			U.animation_start(this, "zzz", nil, store.tick_ts, false, 2)

			while not U.animation_finished(this, 2) do
				if this.ui.clicked then
					this.ui.clicked = nil
					this.tween.disabled = false
					this.tween.props[1].time_offset = zzz.ts - store.tick_ts

					U.y_wait(store, this.tween.props[1].keys[2][1])

					this.tween.disabled = true
					force_wakeup = true

					goto label_149_0
				end

				coroutine.yield()
			end

			zzz.hidden = true
		end

		coroutine.yield()
	end
end

scripts.button_steal_dragon_gold = {}

function scripts.button_steal_dragon_gold.update(this, store, script)
	this.already_stolen = false

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil

			if this.dragon.can_steal_gold and not this.already_stolen then
				this.already_stolen = true

				local gold_inc = math.floor(this.gold_to_steal / 10)

				for i = 1, 10 do
					local fx = E:create_entity(this.fx)

					fx.pos.x, fx.pos.y = this.pos.x + this.ui.click_rect.size.x / 2, this.pos.y + this.ui.click_rect.size.y / 2
					fx.render.sprites[1].ts = store.tick_ts
					fx.tween.props[2] = E:clone_c("tween_prop")
					fx.tween.props[2].name = "offset"
					fx.tween.props[2].keys = {
						{
							0,
							V.v(0, 0)
						},
						{
							0.8,
							V.v(10, 0)
						}
					}

					queue_insert(store, fx)

					store.player_gold = store.player_gold + gold_inc

					U.y_wait(store, fts(5))
				end
			end
		end

		coroutine.yield()
	end
end

scripts.tower_archer_dwarf = {}

function scripts.tower_archer_dwarf.get_info(this)
	local pow = this.powers.extra_damage
	local a = this.attacks.list[1]
	local b = E:get_template(a.bullet)
	local min, max = b.bullet.damage_min, b.bullet.damage_max

	if pow.level > 0 then
		min = min + math.floor(b.bullet.damage_inc * pow.level)
		max = max + math.floor(b.bullet.damage_inc * pow.level)
	end

	min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)

	local cooldown = a.cooldown

	return {
		type = STATS_TYPE_TOWER,
		damage_min = min,
		damage_max = max,
		range = this.attacks.range,
		cooldown = cooldown
	}
end

function scripts.tower_archer_dwarf.insert(this, store, script)
	return true
end

function scripts.tower_archer_dwarf.update(this, store, script)
	local at = this.attacks
	local as = this.attacks.list[1]
	local ab = this.attacks.list[2]
	local pow_b = this.powers.barrel
	local pow_e = this.powers.extra_damage
	local shooter_sprite_ids = {
		3,
		4
	}
	local shots_count = 1
	local last_target_pos = V.v(0, 0)
	local a, pow, enemy, _, pred_pos

	SU.towers_swaped(store, this, this.attacks.list)
	while true do
		if this.tower.blocked then
			-- block empty
		else
			if pow_b.changed then
				pow_b.changed = nil

				if pow_b.level == 1 then
					ab.ts = store.tick_ts
				end
			end

			a, pow = nil

			if pow_b.level > 0 and store.tick_ts - ab.ts > ab.cooldown and this.tower.can_do_magic then
				enemy, _, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, at.range, ab.node_prediction, ab.vis_flags, ab.vis_bans)

				if enemy then
					a = ab
					pow = pow_b
				end
			end

			if not a and store.tick_ts - as.ts > as.cooldown then
				enemy, _, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, at.range, as.node_prediction, as.vis_flags, as.vis_bans)

				if enemy then
					a = as
					pow = pow_e
				end
			end

			if a then
				last_target_pos.x, last_target_pos.y = enemy.pos.x, enemy.pos.y
				a.ts = store.tick_ts
				shots_count = shots_count + 1

				local shooter_idx = shots_count % 2 + 1
				local shooter_sid = shooter_sprite_ids[shooter_idx]
				local start_offset = a.bullet_start_offset[shooter_idx]
				local an, af = U.animation_name_facing_point(this, a.animation, enemy.pos, shooter_sid, start_offset)

				U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)

				while store.tick_ts - a.ts < a.shoot_time do
					coroutine.yield()
				end

				local b1 = E:create_entity(a.bullet)

				b1.pos.x, b1.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
				b1.bullet.damage_factor = this.tower.damage_factor
				b1.bullet.from = V.vclone(b1.pos)
				b1.bullet.to = pred_pos
				b1.bullet.target_id = enemy.id
				b1.bullet.source_id = this.id
				b1.bullet.level = pow.level

				queue_insert(store, b1)

				while not U.animation_finished(this, shooter_sid) do
					coroutine.yield()
				end

				an, af = U.animation_name_facing_point(this, "idle", last_target_pos, shooter_sid, start_offset)

				U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
			end
		end

		coroutine.yield()
	end
end

scripts.soldier_dwarf = {}

function scripts.soldier_dwarf.update(this, store, script)
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
			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			SU.soldier_courage_upgrade(store, this)

			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_156_0
				end
			end

			check_tower_damage_factor()

			if this.beer and this.powers.beer.level > 0 and this.health.hp > 0 and this.health.hp < this.beer.hp_trigger_factor * this.health.hp_max and store.tick_ts - this.beer.ts > this.beer.cooldown then
				this.beer.ts = store.tick_ts
				this.health.immune_to = DAMAGE_ALL

				U.y_animation_play(this, this.beer.animation, nil, store.tick_ts, 1)

				this.health.immune_to = 0

				local m = E:create_entity(this.beer.mod)

				m.pos = this.pos
				m.modifier.level = this.powers.beer.level
				m.modifier.target_id = this.id
				m.modifier.source_id = this.id

				queue_insert(store, m)

				goto label_156_0
			end

			if this.melee then
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_156_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_156_0::

		coroutine.yield()
	end
end

scripts.decal_umbra_crystals = {}

function scripts.decal_umbra_crystals.update(this, store, script)
	while this.phase ~= "crack" do
		coroutine.yield()
	end

	S:queue("FrontiersFinalBossSpawnCrack")

	this.render.sprites[2].ts = store.tick_ts + 0.19
	this.render.sprites[3].ts = store.tick_ts + 0.73
	this.render.sprites[4].ts = store.tick_ts + 1.2
	this.render.sprites[2].hidden = false
	this.render.sprites[3].hidden = false
	this.render.sprites[4].hidden = false

	U.y_wait(store, 2)
	U.animation_start(this, "spawn", nil, store.tick_ts, false, 1)
	U.y_wait(store, 2.05)

	this.render.sprites[2].hidden = true
	this.render.sprites[3].hidden = true
	this.render.sprites[4].hidden = true

	U.y_wait(store, 0.05)
	S:queue("FrontiersFinalBossSpawnExplode")

	local fx_ice_pieces = {
		{
			V.v(-1, 0),
			false,
			0
		},
		{
			V.v(-9, 25),
			false,
			0.06
		},
		{
			V.v(4, -14),
			false,
			0.13
		},
		{
			V.v(-1, 0),
			true,
			0
		},
		{
			V.v(-9, 25),
			true,
			0.06
		},
		{
			V.v(4, -14),
			true,
			0.13
		}
	}

	for _, p in pairs(fx_ice_pieces) do
		local off, flip, delay = unpack(p)
		local fx = E:create_entity("umbra_crystals_piece")

		fx.pos.x, fx.pos.y = this.pos.x + off.x, this.pos.y + off.y
		fx.render.sprites[1].flip_x = flip
		fx.render.sprites[1].ts = store.tick_ts + delay

		queue_insert(store, fx)
	end
end

scripts.tower_pirate_watchtower = {}

function scripts.tower_pirate_watchtower.get_info(this)
	local a = this.attacks.list[1]
	local b = E:get_template(a.bullet)
	local min, max = b.bullet.damage_min, b.bullet.damage_max

	min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)

	local cooldown = a.cooldown

	return {
		type = STATS_TYPE_TOWER,
		damage_min = min,
		damage_max = max,
		range = this.attacks.range,
		cooldown = cooldown
	}
end

function scripts.tower_pirate_watchtower.insert(this, store)
	return true
end

function scripts.tower_pirate_watchtower.update(this, store)
	local at = this.attacks
	local a = this.attacks.list[1]
	local pow_c = this.powers.reduce_cooldown
	local pow_p = this.powers.parrot
	local shooter_sid = 3
	local last_target_pos = V.v(0, 0)
	local parrots = {}

	while true do
		if this.tower.blocked then
			-- block empty
		else
			if pow_c.changed then
				pow_c.changed = nil
				a.cooldown = pow_c.values[pow_c.level]
			end

			if pow_p.changed and #parrots < 2 then
				pow_p.changed = nil
				for i = #parrots + 1, pow_p.level do
					local e = E:create_entity("pirate_watchtower_parrot")
					e.bombs_pos = V.v(this.pos.x + 12, this.pos.y + 6)
					e.idle_pos = V.v(this.pos.x + (#parrots == 0 and -20 or 20), this.pos.y)
					e.pos = V.vclone(e.idle_pos)
					e.owner = this
					queue_insert(store, e)
					table.insert(parrots, e)
				end
			end

			if store.tick_ts - a.ts > a.cooldown then
				local enemy, _, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, at.range, a.node_prediction, a.vis_flags, a.vis_bans)

				if not enemy then
					-- block empty
				else
					last_target_pos.x, last_target_pos.y = enemy.pos.x, enemy.pos.y
					a.ts = store.tick_ts

					local start_offset = a.bullet_start_offset[1]
					local an, af = U.animation_name_facing_point(this, a.animation, enemy.pos, shooter_sid, start_offset)

					U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)

					while store.tick_ts - a.ts < a.shoot_time do
						coroutine.yield()
					end

					local b1 = E:create_entity(a.bullet)

					b1.pos.x, b1.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
					b1.bullet.damage_factor = this.tower.damage_factor
					b1.bullet.from = V.vclone(b1.pos)
					b1.bullet.to = pred_pos
					b1.bullet.target_id = enemy.id
					b1.bullet.source_id = this.id

					queue_insert(store, b1)

					while not U.animation_finished(this, shooter_sid) do
						coroutine.yield()
					end

					an, af = U.animation_name_facing_point(this, "idle", last_target_pos, shooter_sid, start_offset)

					U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.pirate_watchtower_parrot = {}

function scripts.pirate_watchtower_parrot.update(this, store)
	local sp = this.render.sprites[1]
	local fm = this.force_motion
	local ca = this.custom_attack
	local dest = V.vclone(this.idle_pos)

	local function force_move_step(dest, max_speed, ramp_radius)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local df = (not ramp_radius or ramp_radius < dist) and 1 or math.max(dist / ramp_radius, 0.1)

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(495, V.mul(10 * df, dx, dy)))
		fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
		fm.v.x, fm.v.y = V.trim(max_speed, fm.v.x, fm.v.y)
		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = V.mul(-0.05 / store.tick_length, fm.v.x, fm.v.y)
		sp.flip_x = this.pos.x < dest.x
	end

	sp.offset.y = this.flight_height

	while true do
		if not this.owner or not store.entities[this.owner.id] then
			queue_remove(store, this)
			return
		end
		if store.tick_ts - ca.ts > ca.cooldown and not this.owner.tower.blocked then
			local target = U.find_nearest_enemy(store.entities, tpos(this.owner), 0, this.owner.attacks.range, ca.vis_flags, ca.vis_bans)

			if not target then
				SU.delay_attack(store, ca, 0.13333333333333333)
			else
				log.debug("fly to get bomb")
				U.animation_start(this, "fly", nil, store.tick_ts, true)

				dest.x, dest.y = this.bombs_pos.x, this.bombs_pos.y

				local dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)

				while dist > 10 do
					force_move_step(dest, this.flight_speed_busy, this.ramp_dist_busy)
					coroutine.yield()

					target = store.entities[target.id]

					if not target or target.health.dead then
						ca.ts = store.tick_ts

						goto label_161_0
					end

					dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
				end

				log.debug("carry bomb")
				U.animation_start(this, "carry", nil, store.tick_ts, true)

				dest.x, dest.y = target.pos.x, target.pos.y
				dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)

				while dist > 40 do
					force_move_step(dest, this.flight_speed_busy)
					coroutine.yield()

					dest.x, dest.y = target.pos.x, target.pos.y
					dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
				end

				log.debug("drop bomb")

				local e = E:create_entity(ca.bullet)

				e.pos.x, e.pos.y = this.pos.x, this.pos.y + this.flight_height - 8
				e.bullet.from = V.vclone(e.pos)
				e.bullet.source_id = this.id

				queue_insert(store, e)

				local t_off = P:predict_enemy_node_advance(target, e.bullet.flight_time)
				local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + t_off)

				e.bullet.to = V.vclone(t_pos)
				ca.ts = store.tick_ts
				dest.x, dest.y = this.idle_pos.x, this.idle_pos.y
			end
		end

		::label_161_0::

		U.animation_start(this, "idle", nil, store.tick_ts, true)

		if V.dist(dest.x, dest.y, this.idle_pos.x, this.idle_pos.y) > 43 or V.dist(dest.x, dest.y, this.pos.x, this.pos.y) < 10 then
			dest = U.point_on_ellipse(this.idle_pos, 30, U.frandom(0, 2 * math.pi))
		end

		force_move_step(dest, this.flight_speed_idle, this.ramp_dist_idle)
		coroutine.yield()
	end
end

scripts.enemy_gunboat = {}

function scripts.enemy_gunboat.get_info(this)
	local b = E:get_template(this.attacks.list[1].bullet)
	local min, max = b.bullet.damage_min, b.bullet.damage_max

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

function scripts.enemy_gunboat.update(this, store)
	local ba = this.attacks.list[1]

	ba.ts = store.tick_ts

	if not ba.stop_at_nodes then
		log.warning("Loading default shots for gunboat")

		ba.stop_at_nodes = {
			32,
			52,
			72
		}
		ba.shots_at_node = {
			2,
			2,
			2
		}
	end

	::label_164_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, true)
			coroutine.yield()
		else
			local idx = table.find(ba.stop_at_nodes, this.nav_path.ni)

			if idx then
				this.nav_path.ni = this.nav_path.ni + 1

				local shots = ba.shots_at_node[idx]

				if shots <= 0 then
					-- block empty
				else
					U.y_animation_play(this, ba.animations[1], nil, store.tick_ts, 1)

					for i = 1, shots do
						if this.health.dead then
							goto label_164_0
						end

						U.animation_start(this, ba.animations[2], nil, store.tick_ts)
						U.y_wait(store, ba.shoot_time)

						while this.unit.is_stunned do
							if this.health.dead then
								goto label_164_0
							end

							coroutine.yield()
						end

						local shoot_pos
						local target = U.find_random_target(store.entities, this.pos, ba.min_range, ba.max_range, ba.vis_flags, ba.vis_bans)

						log.debug("GUNBOAT TARGET: %s", target and target.id or "nil")

						if target then
							shoot_pos = target.pos
						else
							shoot_pos = P:get_random_position(10, bor(TERRAIN_LAND))
						end

						if shoot_pos then
							local b = E:create_entity(ba.bullet)

							b.pos.x, b.pos.y = this.pos.x + ba.bullet_start_offset.x, this.pos.y + ba.bullet_start_offset.y
							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = V.vclone(shoot_pos)
							b.bullet.source_id = this.id

							queue_insert(store, b)
						end

						while not U.animation_finished(this) or this.unit.is_stunned do
							if this.health.dead then
								goto label_164_0
							end

							coroutine.yield()
						end
					end

					U.y_animation_play(this, ba.animations[3], nil, store.tick_ts, 1)
				end

				goto label_164_0
			end

			SU.y_enemy_walk_step(store, this)
		end
	end
end

scripts.decal_whale = {}

function scripts.decal_whale.insert(this, store, script)
	this.pos = P:node_pos(this.nav_path.pi, 1, 1)
	this.pos.x = this.pos.x + this.path_origin_offset.x
	this.pos.y = this.pos.y + this.path_origin_offset.y

	if not this.spawn_data then
		log.error("spawn_data required for decal_whale")

		return false
	end

	return true
end

function scripts.decal_whale.update(this, store, script)
	log.debug("whale starting")

	local cover_s = this.render.sprites[4]
	local eye_s = this.render.sprites[5]
	local blink_cooldown = math.random(2, 4)
	local fx = E:create_entity("fx_whale_incoming")

	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	local wait_ts = store.tick_ts + 3.5

	while wait_ts > store.tick_ts do
		coroutine.yield()
	end

	S:queue("RTWhaleSpawn")

	for i = 1, 3 do
		this.render.sprites[i].hidden = false

		U.animation_start(this, "show", nil, store.tick_ts, 1, i)
	end

	while not U.animation_finished(this) do
		coroutine.yield()
	end

	for i = 1, 3 do
		this.render.sprites[i].hidden = false

		U.animation_start(this, "idle", nil, store.tick_ts, -1, i)
	end

	cover_s.hidden = false
	eye_s.hidden = false

	while not store.wave_signals[this.spawn_data.whale_hide_signal] do
		if blink_cooldown < store.tick_ts - eye_s.ts then
			blink_cooldown = math.random(2, 4)

			U.animation_start(this, "blink", nil, store.tick_ts, 1, 5)
		end

		coroutine.yield()
	end

	cover_s.hidden = true
	eye_s.hidden = true

	for i = 1, 3 do
		this.render.sprites[i].hidden = false

		U.animation_start(this, "hide", nil, store.tick_ts, 1, i)
	end

	while not U.animation_finished(this) do
		coroutine.yield()
	end

	queue_remove(store, this)
	log.debug("whale ended")
end

scripts.points_spawner = {}

function scripts.points_spawner.update(this, store)
	if not this.spawner_points or not this.spawner_groups or not this.spawner_waves then
		log.error("points_spawner not initialized. points, grops or waves missing")
		queue_remove(store, this)

		return
	end

	while true do
		local wave_start_ts = store.tick_ts
		local current_wave = this.manual_wave or not store.waves_finished and store.wave_group_number or nil
		local spawn_queue = {}

		if this.spawner_waves[current_wave] and not this.interrupt then
			for _, w in pairs(this.spawner_waves[current_wave]) do
				local delay, delay_var, group, subpath, qty, force_all, int_min, int_max, template, custom_data = unpack(w)

				log.paranoid("points_spawner %s wave: %s,%s,%s,%s,%s,%s,%s", current_wave, delay, group, qty, subpath, force_all, int_min, int_max, template)

				local c_delay = delay
				local point_ids = this.spawner_groups[group] or {
					group
				}

				for i = 1, qty do
					if force_all then
						for _, point_id in pairs(point_ids) do
							local point = this.spawner_points[point_id]
							local spi = subpath > 0 and subpath or math.random(1, 3)

							table.insert(spawn_queue, {
								c_delay + U.frandom(0, delay_var),
								template,
								point.from,
								point.to,
								point.path,
								spi,
								custom_data
							})
						end
					else
						if i == 1 then
							c_delay = c_delay + U.frandom(0, delay_var)
						end

						local point_id = table.random(point_ids)
						local point = this.spawner_points[point_id]
						local spi = subpath > 0 and subpath or math.random(1, 3)

						table.insert(spawn_queue, {
							c_delay,
							template,
							point.from,
							point.to,
							point.path,
							spi,
							custom_data
						})
					end

					c_delay = c_delay + U.frandom(int_min, int_max)
				end
			end

			table.sort(spawn_queue, function(e1, e2)
				return e1[1] < e2[1]
			end)

			local ptr = 1

			while this.manual_wave and current_wave == this.manual_wave or not this.manual_wave and current_wave == store.wave_group_number do
				if this.interrupt then
					goto label_167_0
				end

				local wave_ts = store.tick_ts - wave_start_ts

				while ptr <= #spawn_queue and wave_ts >= spawn_queue[ptr][1] do
					local ts, template, p_from, p_to, p_pi, p_spi, custom_data = unpack(spawn_queue[ptr])
					local pis = p_pi and {
						p_pi
					} or nil
					local nodes = P:nearest_nodes(p_to.x, p_to.y, pis, {
						p_spi
					})

					if #nodes == 0 then
						log.error("points_spawner (%06.2f) %s - Node not found near:%s,%s", ts, current_wave, p_to.x, p_to.y)
					else
						local e = E:create_entity(template)

						e.nav_path.pi = p_pi or nodes[1][1]
						e.nav_path.spi = nodes[1][2]
						e.nav_path.ni = nodes[1][3]
						e.pos = V.vclone(p_from)
						e.motion.forced_waypoint = P:node_pos(e.nav_path)
						e.render.sprites[1].name = "raise"
						e.custom_spawn_data = custom_data

						queue_insert(store, e)
						log.paranoid("%06.2f : points_spawner (%06.2f) %s - %s from:%s,%s to:%s,%s pi:%s spi:%s", store.tick_ts, ts, current_wave, template, p_from.x, p_from.y, p_to.x, p_to.y, p_pi, p_spi)
					end

					ptr = ptr + 1
				end

				coroutine.yield()
			end
		else
			while this.manual_wave and current_wave == this.manual_wave or not store.waves_finished and current_wave == store.wave_group_number do
				if this.interrupt then
					goto label_167_0
				end

				coroutine.yield()
			end
		end

		coroutine.yield()
	end

	::label_167_0::

	log.debug("points_spawner interrupted")
	queue_remove(store, this)
end

scripts.moon_controller = {}

function scripts.moon_controller.update(this, store)
	local glow_sid, eyes_sid = 1, 4
	local glow_s = this.render.sprites[glow_sid]
	local eyes_s = this.render.sprites[eyes_sid]
	local moon = this.decal_moon_dark
	local moon_s = moon.render.sprites[1]
	local moon_light = this.decal_moon_light
	local overlay = this.moon_overlay
	local fade_time = overlay.tween.props[1].keys[2][1]
	local ptr = 1

	while true do
		local hold_start_ts
		local wave_start_ts = store.tick_ts
		local wave_number = store.wave_group_number

		local function fn_new_wave(store, time)
			return store.wave_group_number ~= wave_number
		end

		while this.waves[ptr] and this.waves[ptr][1] == wave_number and wave_number == store.wave_group_number do
			local d_wave, d_delay, d_duration = unpack(this.waves[ptr])
			local delay = d_delay - (store.tick_ts - wave_start_ts)
			local transit_time = this.transit_time

			if U.y_wait(store, delay - transit_time, fn_new_wave) then
				-- block empty
			else
				moon.tween.props[1].keys = {
					{
						0,
						math.pi / 5
					},
					{
						transit_time,
						math.pi / 2
					}
				}
				moon.tween.disabled = nil
				moon.tween.ts = store.tick_ts

				if U.y_wait(store, 0.15 * transit_time, fn_new_wave) then
					-- block empty
				elseif U.y_wait(store, 0.85 * transit_time, fn_new_wave) then
					-- block empty
				else
					moon_light.tween.ts = store.tick_ts
					moon_light.tween.reverse = false
					this.tween.ts = store.tick_ts
					this.tween.reverse = false
					overlay.tween.ts = store.tick_ts
					overlay.tween.reverse = false

					S:queue("MusicHalloweenMoon")

					hold_start_ts = store.tick_ts
					this.moon_active = true

					signal.emit("moon-changed", true, store)

					while d_duration > store.tick_ts - hold_start_ts do
						if fn_new_wave(store) then
							break
						end

						coroutine.yield()
					end
				end

				log.debug("MOON: finishing for wave %s", wave_number)
				signal.emit("moon-changed", false, store)

				this.moon_active = false

				if store.wave_group_number ~= wave_number then
					transit_time = transit_time / 4
				end

				if not this.tween.reverse then
					this.tween.ts = store.tick_ts
					this.tween.reverse = true
				end

				if not overlay.tween.reverse then
					overlay.tween.ts = store.tick_ts
					overlay.tween.reverse = true
				end

				if not moon_light.tween.reverse then
					moon_light.tween.ts = store.tick_ts
					moon_light.tween.reverse = true

					U.y_wait(store, fade_time)
				end

				S:queue(string.format("MusicBattle_%02d", store.level_idx), {
					seek = 19.774
				})

				moon.tween.props[1].keys = {
					{
						0,
						moon_s.r
					},
					{
						transit_time,
						4 * math.pi / 5
					}
				}
				moon.tween.ts = store.tick_ts

				if U.y_wait(store, transit_time, fn_new_wave) then
					transit_time = (transit_time - (store.tick_ts - moon.tween.ts)) / 4
					moon.tween.props[1].keys = {
						{
							0,
							moon_s.r
						},
						{
							transit_time,
							4 * math.pi / 5
						}
					}
					moon.tween.ts = store.tick_ts

					U.y_wait(store, transit_time)
				end
			end

			log.debug("MOON: skipping for wave %s", wave_number)

			ptr = ptr + 1
		end

		while wave_number == store.wave_group_number do
			coroutine.yield()
		end
	end
end

scripts.moon_enemy_aura = {}

function scripts.moon_enemy_aura.update(this, store)
	while true do
		local source = store.entities[this.aura.source_id]

		if not source or not source.health or source.health.dead or not store.level or not store.level.moon_controller then
			log.paranoid("X removing moon_enemy_aura for source id:%s", this.aura.source_id)
			queue_remove(store, this)

			return
		end

		if store.level.moon_controller.moon_active and not source.moon.active then
			log.debug("MOON: + activating for (%s) %s", source.id, source.template_name)

			source.moon.active = true

			if source.moon.speed_factor and source.motion then
				source.motion.max_speed = source.motion.max_speed * source.moon.speed_factor
			end

			if source.moon.damage_factor and source.melee then
				source.unit.damage_factor = source.unit.damage_factor * source.moon.damage_factor
			end

			if source.moon.regen_hp and source.regen then
				source.regen.health = source.regen.health + source.moon.regen_hp
			end

			if source.moon.transform_name then
				local m = E:create_entity("mod_lycanthropy")

				m.modifier.target_id = source.id
				m.active = true
				m.moon.transform_name = source.moon.transform_name

				queue_insert(store, m)
			end
		elseif not store.level.moon_controller.moon_active and source.moon.active then
			log.debug("MOON: - deactivating for (%s) %s", source.id, source.template_name)

			source.moon.active = nil

			if source.moon.speed_factor and source.motion then
				source.motion.max_speed = source.motion.max_speed / source.moon.speed_factor
			end

			if source.moon.damage_factor and source.melee then
				source.unit.damage_factor = source.unit.damage_factor / source.moon.damage_factor
			end

			if source.moon.regen_hp and source.regen then
				source.regen.health = source.regen.health - source.moon.regen_hp
			end
		end

		coroutine.yield()
	end
end

scripts.tower_frankenstein = {}

function scripts.tower_frankenstein.get_info(this)
	local l = this.powers.lightning.level
	local m = E:get_template("mod_ray_frankenstein")
	local min, max = m.dps.damage_min + l * m.dps.damage_inc, m.dps.damage_max + l * m.dps.damage_inc

	min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)

	local cooldown

	if this.attacks and this.attacks.list[1].cooldown then
		cooldown = this.attacks.list[1].cooldown
	end

	return {
		type = STATS_TYPE_TOWER,
		damage_min = min,
		damage_max = max,
		range = this.attacks.range,
		cooldown = cooldown
	}
end

function scripts.tower_frankenstein.insert(this, store, script)
	return scripts.tower_barrack.insert(this, store, script)
end

function scripts.tower_frankenstein.update(this, store, script)
	local charges_sids = {
		7,
		8
	}
	local charges_ts = store.tick_ts
	local charges_cooldown = math.random(fts(71), fts(116))
	local drcrazy_sid = 9
	local drcrazy_ts = store.tick_ts
	local drcrazy_cooldown = math.random(fts(86), fts(146))
	local fake_frankie_sid = 10
	local at = this.attacks
	local ra = this.attacks.list[1]
	local rb = E:get_template(ra.bullet)
	local b = this.barrack
	local pow_l = this.powers.lightning
	local pow_f = this.powers.frankie
	local a, pow, bu

	ra.ts = store.tick_ts

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			if drcrazy_cooldown < store.tick_ts - drcrazy_ts then
				U.animation_start(this, "idle", nil, store.tick_ts, false, drcrazy_sid)

				drcrazy_ts = store.tick_ts
			end

			if charges_cooldown < store.tick_ts - charges_ts then
				for _, sid in pairs(charges_sids) do
					U.animation_start(this, "idle", nil, store.tick_ts, false, sid)
				end

				charges_ts = store.tick_ts
			end

			if pow_l.changed then
				pow_l.changed = nil
			end

			if pow_f.level > 0 then
				if pow_f.changed then
					pow_f.changed = nil

					if not b.soldiers[1] then
						for i = 1, 2 do
							U.animation_start(this, "release", nil, store.tick_ts, false, 10 + i)
						end

						U.animation_start(this, "idle", nil, store.tick_ts, false, drcrazy_sid)

						drcrazy_ts = store.tick_ts

						U.y_wait(store, 2)

						this.render.sprites[fake_frankie_sid].hidden = true

						local l = pow_f.level
						local s = E:create_entity(b.soldier_type)

						s.soldier.tower_id = this.id
						s.pos = V.v(this.pos.x + 2, this.pos.y - 10)
						s.nav_rally.pos = V.v(b.rally_pos.x, b.rally_pos.y)
						s.nav_rally.center = V.vclone(b.rally_pos)
						s.nav_rally.new = true
						s.unit.level = l
						s.health.armor = s.health.armor_lvls[l]
						s.melee.attacks[1].damage_min = s.melee.attacks[1].damage_min_lvls[l]
						s.melee.attacks[1].damage_max = s.melee.attacks[1].damage_max_lvls[l]
						s.melee.attacks[1].cooldown = s.melee.attacks[1].cooldown_lvls[l]
						s.render.sprites[1].prefix = s.render.sprites[1].prefix_lvls[l]
						s.render.sprites[1].name = "idle"
						s.render.sprites[1].flip_x = true

						if l == 3 then
							s.melee.attacks[2].disabled = nil
						end

						queue_insert(store, s)

						b.soldiers[1] = s
					end

					if pow_f.level > 1 then
						local s = b.soldiers[1]

						if s and store.entities[s.id] and not s.health.dead then
							local l = pow_f.level

							s.unit.level = l
							s.health.armor = s.health.armor_lvls[l]
							s.health.hp = s.health.hp_max
							s.melee.attacks[1].damage_min = s.melee.attacks[1].damage_min_lvls[l]
							s.melee.attacks[1]._original_damage_min = s.melee.attacks[1].damage_min_lvls[l]
							s.melee.attacks[1].damage_max = s.melee.attacks[1].damage_max_lvls[l]
							s.melee.attacks[1]._original_damage_max = s.melee.attacks[1].damage_max_lvls[l]
							s.melee.attacks[1].cooldown = s.melee.attacks[1].cooldown_lvls[l]
							s.render.sprites[1].prefix = s.render.sprites[1].prefix_lvls[l]

							if l == 3 then
								s.melee.attacks[2].disabled = nil
							end
						end
					end
				end

				local s = b.soldiers[1]

				if s and s.health.dead and store.tick_ts - s.health.death_ts > s.health.dead_lifetime then
					local orig_s = s

					queue_remove(store, orig_s)

					local l = pow_f.level

					s = E:create_entity(b.soldier_type)
					s.soldier.tower_id = this.id
					s.pos = orig_s.pos
					s.nav_rally.pos = V.v(b.rally_pos.x, b.rally_pos.y)
					s.nav_rally.center = V.vclone(b.rally_pos)
					s.nav_rally.new = true
					s.unit.level = l
					s.health.armor = s.health.armor_lvls[l]
					s.melee.attacks[1].damage_min = s.melee.attacks[1].damage_min_lvls[l]
					s.melee.attacks[1].damage_max = s.melee.attacks[1].damage_max_lvls[l]
					s.melee.attacks[1].cooldown = s.melee.attacks[1].cooldown_lvls[l]
					s.render.sprites[1].prefix = s.render.sprites[1].prefix_lvls[l]
					s.render.sprites[1].flip_x = orig_s.render.sprites[1].flip_x

					if l == 3 then
						s.melee.attacks[2].disabled = nil
					end

					queue_insert(store, s)

					b.soldiers[1] = s
				end

				if b.rally_new then
					b.rally_new = false

					signal.emit("rally-point-changed", this)

					if s then
						s.nav_rally.pos = V.vclone(b.rally_pos)
						s.nav_rally.center = V.vclone(b.rally_pos)
						s.nav_rally.new = true

						if not s.health.dead then
							S:queue(this.sound_events.change_rally_point)
						end
					end
				end
			end

			if store.tick_ts - ra.ts > ra.cooldown then
				local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, at.range, ra.node_prediction, ra.vis_flags, ra.vis_bans)

				if not enemy or enemy.health.dead then
					local frankie = b.soldiers[1]

					if frankie and not frankie.health.dead then
						enemy = U.find_foremost_enemy(store.entities, frankie.pos, 0, rb.bounce_range, false, ra.vis_flags, ra.vis_bans)
						enemy = enemy and frankie
					end
				end

				if not enemy then
					-- block empty
				else
					ra.ts = store.tick_ts

					S:queue("HWFrankensteinChargeLightning", {
						delay = fts(16)
					})

					for i = 3, 6 do
						U.animation_start(this, "shoot", nil, store.tick_ts, 1, i)
					end

					while store.tick_ts - ra.ts < ra.shoot_time do
						coroutine.yield()
					end

					enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, at.range, ra.node_prediction, ra.vis_flags, ra.vis_bans)

					if not enemy or enemy.health.dead then
						local frankie = b.soldiers[1]

						if frankie and not frankie.health.dead then
							enemy = U.find_foremost_enemy(store.entities, frankie.pos, 0, rb.bounce_range, false, ra.vis_flags, ra.vis_bans)
							enemy = enemy and frankie
						end
					end

					if not enemy or enemy.health.dead then
						-- block empty
					else
						S:queue(ra.sound)

						bu = E:create_entity(ra.bullet)
						bu.bullet.damage_factor = this.tower.damage_factor
						bu.pos.x, bu.pos.y = this.pos.x + ra.bullet_start_offset.x, this.pos.y + ra.bullet_start_offset.y
						bu.bullet.from = V.vclone(bu.pos)
						bu.bullet.to = V.vclone(enemy.pos)
						bu.bullet.source_id = this.id
						bu.bullet.target_id = enemy.id
						bu.bullet.level = pow_l.level

						queue_insert(store, bu)
					end

					while not U.animation_finished(this, 3) do
						coroutine.yield()
					end
				end
			end

			for i = 2, 5 do
				U.animation_start(this, "idle", nil, store.tick_ts, 1, i)
			end

			coroutine.yield()
		end
	end
end

scripts.ray_frankenstein = {}

function scripts.ray_frankenstein.insert(this, store)
	if not store.entities[this.bullet.target_id] then
		return false
	end

	return true
end

function scripts.ray_frankenstein.update(this, store)
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

		if source and source.motion then
			this.pos.x, this.pos.y = source.pos.x, source.pos.y

			if source.unit and source.unit.hit_offset then
				this.pos.x, this.pos.y = this.pos.x + source.unit.hit_offset.x, this.pos.y + source.unit.hit_offset.y
			end
		end

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
		s.scale.y = 0.4 + km.clamp(0, 0.6, s.scale.x * 0.6)
	end

	if target then
		s.ts = store.tick_ts

		update_sprite()

		if target.template_name == "soldier_frankenstein" and not target.health.dead then
			target.health.hp = math.min(target.health.hp + this.frankie_heal_hp, target.health.hp_max)
		else
			local mod = E:create_entity(b.mod)

			mod.modifier.level = b.level
			mod.modifier.source_id = b.source_id
			mod.modifier.target_id = target.id
			mod.dps.damage_max = mod.dps.damage_max * this.bounce_damage_factor * b.damage_factor
			mod.dps.damage_min = mod.dps.damage_min * this.bounce_damage_factor * b.damage_factor
			mod.dps.damage_inc = mod.dps.damage_inc * this.bounce_damage_factor * b.damage_factor

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

			bounce_target = bounce_target or U.find_nearest_soldier(store.entities, dest, 0, this.bounce_range, this.bounce_vis_flags, this.bounce_vis_bans, function(v)
				return v.template_name == "soldier_frankenstein" and not v.health.dead and not table.contains(this.seen_targets, v.id)
			end)

			if bounce_target then
				log.paranoid("bounce from %s to %s dist:%s", target.id, bounce_target.id, V.dist(dest.x, dest.y, bounce_target.pos.x, bounce_target.pos.y))

				local r = E:create_entity(this.template_name)

				r.pos = V.vclone(dest)
				r.bullet.level = b.level
				r.bullet.to = V.vclone(target.pos)
				r.bullet.target_id = bounce_target.id
				r.bullet.source_id = target.id
				r.bounces = this.bounces - 1
				r.seen_targets = this.seen_targets
				r.bounce_damage_factor = math.max(this.bounce_damage_factor + this.bounce_damage_factor_inc, this.bounce_damage_factor_min)

				queue_insert(store, r)
			end
		end

		while not U.animation_finished(this) do
			update_sprite()
			coroutine.yield()
		end
	end

	queue_remove(store, this)
end

scripts.fx_frankenstein_pound = {}

function scripts.fx_frankenstein_pound.insert(this, store)
	for i = 1, 5 do
		local p1 = V.v(math.random(8, 12), 0)
		local p2 = V.v(p1.x + math.random(34, 39), 0)
		local p3 = V.v(p2.x + math.random(4, 8), 0)
		local angle = (i - 1) * 2 * math.pi / 5 + math.random(-5, 5) / 180

		p1 = V.v(V.rotate(angle, p1.x, p1.y))
		p2 = V.v(V.rotate(angle, p2.x, p2.y))
		p3 = V.v(V.rotate(angle, p3.x, p3.y))
		p1.y = p1.y * ASPECT
		p2.y = p2.y * ASPECT
		p3.y = p3.y * ASPECT
		this.tween.props[2 * i].keys = {
			{
				0,
				p1
			},
			{
				fts(10),
				p2
			},
			{
				fts(16),
				p3
			}
		}
	end

	this.render.sprites[1].ts = store.tick_ts + fts(3)
	this.tween.ts = store.tick_ts

	return true
end

scripts.decal_moon_activated = {}

function scripts.decal_moon_activated.update(this, store)
	local last_state = false

	while true do
		if store.level and store.level.moon_controller then
			local state = store.level.moon_controller.moon_active

			if last_state ~= state then
				this.tween.reverse = not state
				this.tween.ts = store.tick_ts
				last_state = state
			end
		end

		coroutine.yield()
	end
end

scripts.elvira_bat = {}

function scripts.elvira_bat.update(this, store)
	signal.emit("wave-notification", "icon", "enemy_elvira")
	U.animation_start(this, "fly", nil, store.tick_ts, true)
	U.set_destination(this, this.motion.forced_waypoint)

	while not this.motion.arrived and not this.spawner.interrupt do
		U.walk(this, store.tick_length)
		coroutine.yield()
	end

	if this.spawner.interrupt then
		U.y_animation_play(this, "death", nil, store.tick_ts)
		queue_remove(store, this)

		return
	end

	if this.payload then
		local e = E:create_entity(this.payload)

		e.pos.x, e.pos.y = this.pos.x, this.pos.y
		e.nav_path.pi = this.nav_path.pi
		e.nav_path.spi = this.nav_path.spi
		e.nav_path.ni = this.nav_path.ni
		e.render.sprites[1].name = "raise"

		queue_insert(store, e)
	end

	queue_remove(store, this)
end

scripts.enemy_elvira = {}

function scripts.enemy_elvira.can_lifesteal(this, store, attack, target)
	return target.template_name ~= "soldier_death_rider" and target.template_name ~= "soldier_skeleton" and target.template_name ~= "soldier_skeleton_knight" and this.enemy.can_do_magic and this.health.hp / this.health.hp_max < attack.health_trigger_factor
end

scripts.mod_elvira_lifesteal = {}

function scripts.mod_elvira_lifesteal.insert(this, store)
	local source = store.entities[this.modifier.source_id]
	local target = store.entities[this.modifier.target_id]
	local moon_active = store.level.moon_controller and store.level.moon_controller.moon_active

	if source and source.health then
		local heal_hp = this.heal_hp

		if moon_active then
			heal_hp = heal_hp * this.moon.heal_hp_factor
		end

		source.health.hp = km.clamp(0, source.health.hp_max, source.health.hp + heal_hp)
	end

	if target and target.health then
		local value = this.damage

		if moon_active then
			value = value * this.moon.damage_factor
		end

		local d = E:create_entity("damage")

		d.value = value
		d.source_id = this.id
		d.target_id = target.id
		d.damage_type = bor(DAMAGE_TRUE)

		queue_damage(store, d)
	end

	return false
end

scripts.decal_taunting_dracula = {}

function scripts.decal_taunting_dracula.update(this, store)
	local taunt = this.taunt
	local pos_idx = math.random(1, 2)
	local s = this.render.sprites[1]
	local cooldown = math.random(taunt.cooldown[1], taunt.cooldown[2])
	local last_ts
	local moon = store.level and store.level.moon_controller
	local last_was_moon = false
	local last_wave

	local function show_taunt(pos_idx, fmt, idx, duration)
		local t = E:create_entity("decal_dracula_shoutbox")

		t.texts.list[1].text = _(string.format(fmt, idx))
		t.pos = taunt.taunt_positions[pos_idx]
		t.timed.duration = duration
		t.render.sprites[1].ts = store.tick_ts
		t.render.sprites[2].ts = store.tick_ts

		queue_insert(store, t)

		return t
	end

	this.showing = true
	this.pos = taunt.dracula_positions[pos_idx]
	s.hidden = false

	U.y_animation_play(this, "show", nil, store.tick_ts, 1)
	show_taunt(pos_idx, taunt.format_welcome, 1, taunt.duration)
	U.y_wait(store, taunt.duration)
	show_taunt(pos_idx, taunt.format_welcome, 2, taunt.duration)
	U.y_wait(store, taunt.duration)
	U.y_animation_play(this, "hide", nil, store.tick_ts, 1)

	s.hidden = true
	last_ts = store.tick_ts
	this.showing = false

	while true do
		if moon and moon.moon_active and not last_was_moon and store.tick_ts - last_ts > taunt.min_cooldown then
			last_was_moon = true
			this.showing = true
			this.pos = taunt.dracula_positions[pos_idx]
			s.hidden = false

			U.y_animation_play(this, "show", nil, store.tick_ts, 1)

			local taunt_idx = math.random(taunt.idx_moon[1], taunt.idx_moon[2])

			show_taunt(pos_idx, taunt.format_moon, taunt_idx, taunt.duration)
			U.y_wait(store, taunt.duration)
			U.y_animation_play(this, "hide", nil, store.tick_ts, 1)

			s.hidden = true
			last_ts = store.tick_ts
			pos_idx = math.random(1, 2)
			this.showing = false
		elseif cooldown < store.tick_ts - last_ts or last_wave ~= store.wave_group_number and store.tick_ts - last_ts > taunt.min_cooldown then
			last_was_moon = false
			this.showing = true
			this.pos = taunt.dracula_positions[pos_idx]
			s.hidden = false

			U.y_animation_play(this, "show", nil, store.tick_ts, 1)

			local taunt_idx = math.random(taunt.idx_generic[1], taunt.idx_generic[2])

			show_taunt(pos_idx, taunt.format_generic, taunt_idx, taunt.duration)
			U.y_wait(store, taunt.duration)
			U.y_animation_play(this, "hide", nil, store.tick_ts, 1)

			s.hidden = true
			last_ts = store.tick_ts
			pos_idx = math.random(1, 2)
			this.showing = false
		end

		last_wave = store.wave_group_number

		coroutine.yield()
	end
end

scripts.decal_stage22_reptile = {}

function scripts.decal_stage22_reptile.update(this, store)
	while true do
		if this.ui.clicked then
			U.y_animation_play(this, "clicked", nil, store.tick_ts)
			U.animation_start(this, "climb", nil, store.tick_ts, true)
			U.set_destination(this, V.v(this.pos.x, this.pos.y + this.climb_distance))

			while not U.walk(this, store.tick_length) do
				coroutine.yield()
			end

			AC:got("FOUND_ME")
			queue_remove(store, this)

			return
		end

		coroutine.yield()
	end
end

scripts.decal_stage81_stargate = {}

function scripts.decal_stage81_stargate.update(this, store)
	local last_group_ready, last_group
	local sid_portal, sid_lights = 2, 3
	local s_portal = this.render.sprites[sid_portal]
	local s_lights = this.render.sprites[sid_lights]
	local shutdown_ts = store.tick_ts

	while true do
		if s_lights.hidden and store.next_wave_group_ready and store.next_wave_group_ready ~= last_group_ready then
			last_group_ready = store.next_wave_group_ready

			for _, w in pairs(store.next_wave_group_ready.waves) do
				if this.out_nodes[w.path_index] then
					s_lights.hidden = false
					s_lights.ts = store.tick_ts

					break
				end
			end
		end

		if s_portal.hidden and store.current_wave_group and store.current_wave_group ~= last_group then
			last_group = store.current_wave_group

			for _, w in pairs(store.current_wave_group.waves) do
				if this.out_nodes[w.path_index] then
					shutdown_ts = store.tick_ts
					s_portal.hidden = false

					U.y_animation_play(this, "start", nil, store.tick_ts, 1, sid_portal)
					U.animation_start(this, "loop", nil, store.tick_ts, true, sid_portal)

					break
				end
			end
		elseif not s_portal.hidden and store.tick_ts - shutdown_ts > this.shutdown_timeout then
			s_lights.hidden = true

			U.y_animation_play(this, "end", nil, store.tick_ts, 1, sid_portal)

			s_portal.hidden = true
		end

		local enemies_before_portal = table.filter(store.entities, function(k, e)
			return e and e.enemy and e.nav_path and this.out_nodes[e.nav_path.pi] and e.nav_path.ni < this.out_nodes[e.nav_path.pi]
		end)

		if #enemies_before_portal > 0 then
			shutdown_ts = store.tick_ts
		end

		coroutine.yield()

		for _, e in pairs(enemies_before_portal) do
			if e.nav_path.ni >= this.out_nodes[e.nav_path.pi] then
				local fx = E:create_entity(this.fx_out)

				fx.pos.x, fx.pos.y = e.pos.x, e.pos.y

				if e.unit and e.unit.mod_offset then
					fx.pos.x, fx.pos.y = fx.pos.x + e.unit.mod_offset.x, fx.pos.y + e.unit.mod_offset.y
				end

				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)
			end
		end
	end
end

scripts.eb_xerxes = {}

function scripts.eb_xerxes.update(this, store)
	local taunt = this.taunt

	local function y_show_taunt(set, index, duration)
		index = index or math.random(taunt.sets[set].start_idx, taunt.sets[set].end_idx)
		duration = duration or taunt.duration
		taunt.ts = store.tick_ts
		taunt.next_ts = store.tick_ts + math.random(taunt.delay_min, taunt.delay_max)

		local t = E:create_entity("decal_xerxes_shoutbox")

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
	local at = this.attacks.list[1]
	local ao = this.attacks.list[2]
	local ai = this.attacks.list[3]
	local wave_config

	while true do
		if store.tick_ts > taunt.next_ts then
			y_show_taunt(this.phase)
		end

		if store.wave_group_number ~= last_wave_number then
			log.debug("EB_XERXES: setting wave config for %s", store.wave_group_number)

			last_wave_number = store.wave_group_number
			wave_config = W:get_endless_boss_config(store.wave_group_number)
			a.chance = wave_config.chance
			a.cooldown = wave_config.cooldown
			a.multiple_attacks_chance = wave_config.multiple_attacks_chance
			a.power_chances = wave_config.power_chances
			a.ts = store.tick_ts
		end

		if store.tick_ts - a.ts > a.cooldown then
			log.debug("EB_XERXES: power cooldown complete")

			a.ts = store.tick_ts

			while math.random() < a.chance do
				local animation = table.random(a.animations)
				local a_idx = U.random_table_idx(a.power_chances)
				local aa = this.attacks.list[a_idx]
				local plevel = km.clamp(0, 9000000000, store.wave_group_number - wave_config.powers_config.powerProgressionWaveStart)

				if aa == at then
					log.debug("EB_XERXES: power teleport starts")

					local targets = table.filter(store.entities, function(_, e)
						return not e.pending_removal and e.enemy and e.vis and e.nav_path and e.health and not e.health.dead and band(e.vis.flags, at.vis_bans) == 0 and band(e.vis.bans, at.vis_flags) == 0 and P:is_node_valid(e.nav_path.pi, e.nav_path.ni) and e.nav_path.ni > P:get_visible_start_node(e.nav_path.pi) + at.path_margins[1] and e.nav_path.ni < P:get_defend_point_node(e.nav_path.pi) - at.path_margins[2]
					end)

					if #targets < 1 then
						log.debug("EB_XERXES: no enemies found for teleport")

						goto label_190_0
					end

					U.animation_start(this, animation, nil, store.tick_ts, false)

					local target = table.random(targets)
					local pconf = wave_config.powers_config.teleport
					local e = E:create_entity(at.aura)

					e.aura.duration = pconf.duration + plevel * pconf.durationIncrement
					e.aura.radius = pconf.range / 2
					e.aura.targets_count = math.floor(pconf.maxTeleports + plevel * pconf.maxTeleportsIncrement)
					e.aura.min_jump = pconf.minNodesToTeleport
					e.aura.max_jump = pconf.maxNodesToTeleport

					local api, aspi = target.nav_path.pi, 1
					local ani = target.nav_path.ni + math.random(at.node_offset[1], at.node_offset[2])

					ani = km.clamp(P:get_visible_start_node(api) + at.path_margins[1], P:get_defend_point_node(api) - at.path_margins[2], ani)

					log.debug("EB_XERXES/teleport aura insertion node: %s,%s,%s target ni:%s defend ni:%s", api, aspi, ani, target.nav_path.ni, P:get_defend_point_node(api))

					e.pos = P:node_pos(api, aspi, ani)

					queue_insert(store, e)
					U.y_animation_wait(this)
				elseif aa == ao then
					log.debug("EB_XERXES: power obelisk starts")

					local cg = store.count_groups[ao.count_group_type]

					if cg[ao.count_group_name] and cg[ao.count_group_name] >= 0.66 * ao.count_group_max and cg.enemy_munra and cg.enemy_munra > 0 then
						goto label_190_0
					end

					U.y_animation_play(this, animation, nil, store.tick_ts, 1)

					local pconf = wave_config.powers_config.obelysk
					local pos, pi, spi, ni = P:get_random_position(ao.path_margins, TERRAIN_LAND, nil, true)

					if not pos then
						log.warning("EB_XERXES: pos for obelisk could not be found")

						goto label_190_0
					end

					local e = E:create_entity(ao.entity)

					e.pos = pos
					e.spawner.pi = pi
					e.spawner.ni = ni
					e.spawner.count_group_type = ao.count_group_type
					e.spawner.count_group_name = ao.count_group_name
					e.spawner.count_group_max = ao.count_group_max
					e.spawner.duration = pconf.duration + plevel * pconf.durationIncrement
					e.spawner.cycle_time_min = pconf.autoSpawnMinInterval
					e.spawner.cycle_time_max = pconf.autoSpawnMaxInterval
					e.spawner.node_range = pconf.range

					queue_insert(store, e)
				elseif aa == ai then
					log.debug("EB_XERXES: power invisibility starts")

					local pconf = wave_config.powers_config.invisibility
					local radius = pconf.range / 2
					local duration = pconf.duration + plevel * pconf.durationIncrement
					local targets = table.filter(store.entities, function(k, e)
						return not e.pending_removal and e.enemy and e.vis and e.nav_path and e.health and not e.health.dead and band(e.vis.flags, ai.vis_bans) == 0 and band(e.vis.bans, ai.vis_flags) == 0 and e.enemy.can_accept_magic and not table.contains(ai.excluded_templates, e.template_name) and P:is_node_valid(e.nav_path.pi, e.nav_path.ni) and e.nav_path.ni > P:get_visible_start_node(e.nav_path.pi) + ai.path_margins[1] and e.nav_path.ni < P:get_defend_point_node(e.nav_path.pi) - ai.path_margins[2]
					end)

					if #targets < 1 then
						log.debug("EB_XERXES: no enemies found for invisibility")

						goto label_190_0
					end

					local best_count = -1
					local best_targets, target

					for _, t in pairs(targets) do
						local nearby = table.filter(targets, function(_, e)
							return U.is_inside_ellipse(e.pos, t.pos, radius)
						end)

						if best_count < #nearby then
							best_targets = nearby
							best_count = #nearby
							target = t
						end
					end

					U.animation_start(this, animation, nil, store.tick_ts, false)

					local fx = E:create_entity(ai.fx)

					fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
					fx.render.sprites[1].ts = store.tick_ts
					fx.render.sprites[2].ts = store.tick_ts

					queue_insert(store, fx)
					S:queue(ai.sound)

					for _, t in pairs(best_targets) do
						last_node = P:get_defend_point_node(t.nav_path.pi) - pconf.reapearBeforeEndNodes
						last_node_eta = P:predict_enemy_time(t, last_node - t.nav_path.ni)

						if last_node_eta > 0 then
							local m = E:create_entity(ai.mod)

							m.modifier.target_id = t.id
							m.modifier.source_id = this.id
							m.modifier.duration = math.min(duration, last_node_eta)
							m.modifier.last_node = last_node

							queue_insert(store, m)
						end
					end

					U.y_animation_wait(this)
				end

				U.animation_start(this, "idle", nil, store.tick_ts)

				::label_190_0::

				if math.random() >= a.multiple_attacks_chance then
					break
				end
			end
		end

		coroutine.yield()
	end
end

scripts.xerxes_teleport_aura = {}

function scripts.xerxes_teleport_aura.update(this, store)
	local start_ts = store.tick_ts
	local a = this.aura
	local count = 0

	U.y_animation_play(this, "start", nil, store.tick_ts, 1)
	U.animation_start(this, "loop", nil, store.tick_ts, true)

	while store.tick_ts - start_ts < a.duration do
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

		if targets then
			for _, target in pairs(targets) do
				local m = E:create_entity(a.mod)

				m.modifier.source_id = this.id
				m.modifier.target_id = target.id
				m.nodes_offset = math.random(a.min_jump, a.max_jump)

				queue_insert(store, m)

				count = count + 1

				if count > a.targets_count then
					goto label_195_0
				end
			end
		end

		coroutine.yield()
	end

	::label_195_0::

	U.y_animation_play(this, "end", nil, store.tick_ts, 1)
	queue_remove(store, this)
end

scripts.xerxes_obelisk = {}

function scripts.xerxes_obelisk.update(this, store)
	local sp = this.spawner
	local start_ts = store.tick_ts
	local spawn_count = 0
	local cg = store.count_groups[sp.count_group_type]
	local sid = 1

	this.tween.ts = store.tick_ts

	U.y_animation_play(this, "start", nil, store.tick_ts, 1, sid)
	U.animation_start(this, "loop", nil, store.tick_ts, true, sid)

	while store.tick_ts - start_ts < sp.duration and (not cg[sp.count_group_name] or cg[sp.count_group_name] < sp.count_group_max) do
		spawn_count = spawn_count + 1

		local e = E:create_entity(sp.entity)

		e.nav_path.pi = sp.pi
		e.nav_path.spi = math.random(1, 3)
		e.nav_path.ni = math.random(sp.ni - sp.node_range, sp.ni + sp.node_range)
		e.unit.spawner_id = this.id
		e.pos = P:node_pos(e.nav_path)
		e.render.sprites[1].name = "raise"

		E:add_comps(e, "count_group")

		e.count_group.name = sp.count_group_name
		e.count_group.type = sp.count_group_type

		queue_insert(store, e)
		U.y_wait(store, U.frandom(sp.cycle_time_min, sp.cycle_time_max))
	end

	U.animation_start(this, "end", nil, store.tick_ts, false, sid)

	this.tween.ts = store.tick_ts
	this.tween.reverse = true
	this.tween.remove = true
end

scripts.mod_xerxes_invisibility = {}

function scripts.mod_xerxes_invisibility.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or target.health.dead then
		return false
	end

	if band(m.vis_bans, target.vis.flags) ~= 0 or band(m.vis_flags, target.vis.bans) ~= 0 then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)

		return false
	end

	if target.unit then
		local s = this.render.sprites[1]

		s.ts = U.frandom(0, 1)
		s.name = s.size_names[target.unit.size]
	end

	if target.enemy then
		U.unblock_all(store, target)
	end

	this.modifier.ts = store.tick_ts

	for _, s in pairs(target.render.sprites) do
		s.alpha = 70
	end

	this._vis_bans = target.vis.bans
	target.vis.bans = bor(F_RANGED, F_SKELETON, F_POLYMORPH, F_TWISTER, F_BLOOD)

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_xerxes_invisibility.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		for _, s in pairs(target.render.sprites) do
			s.alpha = 255
		end

		target.vis.bans = this._vis_bans
	end

	return true
end

scripts.eb_alien = {}

function scripts.eb_alien.update(this, store)
	local function is_spit_target(e, attack, max_x)
		return e and e.soldier and not e.pending_removal and e.health and not e.health.dead and e.vis and band(e.vis.flags, attack.vis_bans) == 0 and band(e.vis.bans, attack.vis_flags) == 0 and max_x > e.pos.x
	end

	local function find_screech_targets(flags, bans)
		return table.filter(store.entities, function(k, v)
			return not v.pending_removal and v.enemy and v.nav_path and v.health and not v.health.dead and v.vis and band(v.vis.flags, bans) == 0 and band(v.vis.bans, flags) == 0 and (v.template_name == "enemy_alien_reaper" or v.template_name == "enemy_alien_breeder") and P:is_node_valid(v.nav_path.pi, v.nav_path.ni)
		end)
	end

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	local last_wave_number = 0
	local wave_config
	local a = this.attacks

	while true do
		if store.wave_group_number ~= last_wave_number then
			last_wave_number = store.wave_group_number
			wave_config = W:get_endless_boss_config(store.wave_group_number)
			a.chance = wave_config.chance
			a.cooldown = wave_config.cooldown
			a.multiple_attacks_chance = wave_config.multiple_attacks_chance
			a.power_chances = wave_config.power_chances
			a.ts = store.tick_ts
		end

		if store.tick_ts - a.ts > a.cooldown then
			a.ts = store.tick_ts

			while math.random() < a.chance do
				local a_idx = U.random_table_idx(a.power_chances)
				local aa = this.attacks.list[a_idx]
				local plevel = km.clamp(0, 9000000000, store.wave_group_number - wave_config.powers_config.powerProgressionWaveStart)

				log.debug("EB_ALIEN | ts:%s wave:%s attack idx:%s, plevel:%s", store.tick_ts, store.wave_group_number, a_idx, plevel)

				if a_idx == 1 then
					local pconf = wave_config.powers_config.spit
					local target

					if store.main_hero and is_spit_target(store.main_hero, aa, pconf.spitMaxX) then
						target = store.main_hero
					else
						for _, e in pairs(store.entities) do
							if is_spit_target(e, aa, pconf.spitMaxX) then
								target = e

								break
							end
						end
					end

					if target then
						U.animation_start_group(this, aa.animation, nil, store.tick_ts, false, 1)
						S:queue(aa.sound)
						U.y_wait(store, aa.hit_time)

						local b = E:create_entity(aa.bullet)

						b.pos.x, b.pos.y = this.pos.x + aa.bullet_start_offset.x, this.pos.y + aa.bullet_start_offset.y
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = V.v(target.pos.x, target.pos.y)
						b.bullet.target_id = target.id
						b.bullet.damage_max = pconf.spitMaxDamage
						b.bullet.damage_min = pconf.spitMinDamage
						b.bullet.damage_radius = pconf.spitRange / 2

						queue_insert(store, b)
						U.y_animation_wait_group(this, 1)
					end
				elseif a_idx == 2 then
					local targets = find_screech_targets(aa.vis_flags, aa.vis_bans)

					if #targets < 1 then
						goto label_199_0
					end

					S:queue(aa.sound)
					U.animation_start_group(this, aa.animation, nil, store.tick_ts, false, 1)
					U.y_wait(store, fts(9))

					targets = find_screech_targets(aa.vis_flags, aa.vis_bans)

					for _, t in pairs(targets) do
						local pconf = wave_config.powers_config.screech
						local mod = E:create_entity(aa.mod)

						mod.modifier.target_id = t.id
						mod.modifier.source_id = this.id
						mod.modifier.duration = pconf.durationModifier + plevel * pconf.durationModifierIncrement
						mod.speed_factor = pconf.speedModifierFactor
						mod.damage_factor = pconf.damageModifierBonus + 1

						queue_insert(store, mod)
						log.debug("EB_ALIEN: apply screech to %s", t.id)
					end

					U.y_animation_wait_group(this, 1)
				elseif a_idx == 3 then
					S:queue(aa.sound)
					U.y_animation_play_group(this, aa.animation, nil, store.tick_ts, 1, 1)
					U.y_wait(store, 1.5)

					local e = E:create_entity(aa.entity)

					e.enemy.gold = 0
					e.nav_path.pi = table.random(aa.pis)
					e.nav_path.spi = math.random(1, 3)
					e.nav_path.ni = 1

					queue_insert(store, e)
					log.debug("EB_ALIEN: lay egg %s", e.id)
				elseif a_idx == 4 then
					local pcd = wave_config.powers_config_dif.spawnLevelEggs
					local count = 0
					local sources = table.random_order(aa.spawn_sources)

					for _, source in pairs(sources) do
						for i, p in ipairs(source.points) do
							local e = E:create_entity(aa.entity)

							e.pos = V.vclone(p)
							e.spawner.pi = source.pi
							e.spawner.spi = i
							e.spawner.count = math.random(pcd.minEnemiesPerEgg, pcd.maxEnemiesPerEgg)

							queue_insert(store, e)
						end

						if math.random() >= pcd.multiPathChance then
							break
						end
					end
				end

				U.animation_start_group(this, "idle", nil, store.tick_ts, true, 1)

				::label_199_0::

				if math.random() >= a.multiple_attacks_chance then
					break
				end
			end
		end

		coroutine.yield()
	end
end

scripts.alien_spit_aura = {}

function scripts.alien_spit_aura.insert(this, store)
	local wave_config = W:get_endless_boss_config(store.wave_group_number)

	if not wave_config then
		log.error("get_endless_boss_config failed for %s", this.template_name)

		return false
	end

	local pconf = wave_config.powers_config.spit
	local plevel = km.clamp(0, 9000000000, store.wave_group_number - wave_config.powers_config.powerProgressionWaveStart)

	this.aura.duration = pconf.duration + plevel * pconf.durationIncrement
	this.aura.radius = pconf.poisonRange / 2

	if not scripts.aura_apply_mod.insert(this, store) then
		return false
	end

	local e = E:create_entity("alien_spit_aura_bubbles")

	e.pos.x, e.pos.y = this.pos.x, this.pos.y
	e.duration = 0.8 * this.aura.duration

	queue_insert(store, e)

	return true
end

scripts.alien_spit_aura_bubbles = {}

function scripts.alien_spit_aura_bubbles.update(this, store)
	local start_ts = store.tick_ts

	while true do
		U.y_wait(store, U.frandom(2, 3.25))

		if store.tick_ts - start_ts > this.duration then
			break
		end

		local bubble = E:create_entity(this.fx)
		local o = table.random(this.random_offsets)

		bubble.pos = V.v(this.pos.x + o.x, this.pos.y + o.y)
		bubble.render.sprites[1].ts = store.tick_ts

		queue_insert(store, bubble)
	end

	queue_remove(store, this)
end

scripts.mod_alien_spit = {}

function scripts.mod_alien_spit.insert(this, store)
	local wave_config = W:get_endless_boss_config(store.wave_group_number)

	if not wave_config then
		log.error("get_endless_boss_config failed for %s", this.template_name)

		return false
	end

	local pconf = wave_config.powers_config.spit
	local plevel = km.clamp(0, 9000000000, store.wave_group_number - wave_config.powers_config.powerProgressionWaveStart)

	this.dps.damage_min = pconf.poisonDamage
	this.dps.damage_max = pconf.poisonDamage
	this.dps.damage_every = fts(pconf.poisonDamageFreq)
	this.modifier.duration = pconf.poisonDuration

	if not scripts.mod_dps.insert(this, store) then
		return false
	end

	return true
end

scripts.alien_breeder_spawner = {}

function scripts.alien_breeder_spawner.update(this, store)
	local s = this.render.sprites[1]
	local sp = this.spawner

	for i = 1, sp.count do
		U.y_wait(store, U.frandom(0.3, 0.75))

		s.hidden = false

		U.animation_start(this, "spawn", nil, store.tick_ts, false)
		U.y_wait(store, fts(4))

		local e = E:create_entity(sp.entity)

		e.pos.x, e.pos.y = this.pos.x, this.pos.y
		e.nav_path.pi = sp.pi
		e.nav_path.spi = sp.spi
		e.render.sprites[1].name = "idle"
		e.unit.spawner_id = this.id

		queue_insert(store, e)
		U.y_animation_wait(this)
	end

	queue_remove(store, this)
end

scripts.mod_alien_screech = {}

function scripts.mod_alien_screech.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.motion or not target.unit then
		log.debug("mod_alien_screech was not inserted to %", this.modifier.target_id)

		return false
	end

	target.motion.max_speed = target.motion.max_speed * this.speed_factor
	target.unit.damage_factor = target.unit.damage_factor * this.damage_factor
	this.modifier.ts = store.tick_ts

	local s = this.render.sprites[1]

	s.flip_x = target.render.sprites[1].flip_x

	if target.template_name == "enemy_alien_breeder" then
		s.scale = V.v(0.75, 0.75)
		s.anchor.y = 0.35
	end

	return true
end

function scripts.mod_alien_screech.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.motion or not target.unit then
		return true
	end

	target.motion.max_speed = target.motion.max_speed / this.speed_factor
	target.unit.damage_factor = target.unit.damage_factor / this.damage_factor

	return true
end

scripts.eb_efreeti = {}

function scripts.eb_efreeti.get_info(this)
	return {
		damage_min = 500,
		damage_max = 800,
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_efreeti.insert(this, store, script)
	local next, new = P:next_entity_node(this, store.tick_length)

	if not next then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)

		return false
	end

	U.set_destination(this, next)

	if not this.pos or this.pos.x == 0 and this.pos.y == 0 then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end

	return true
end

function scripts.eb_efreeti.update(this, store, script)
	local a_poly = this.attacks.list[1]
	local a_des = this.attacks.list[2]
	local a_sand = this.attacks.list[3]
	local a_spawn = this.attacks.list[4]
	local powers_ts = store.tick_ts
	local blocker

	local function do_death()
		local death_start_ts = store.tick_ts

		S:queue(this.sound_events.death)
		U.animation_start(this, "death", nil, store.tick_ts, false, 2)

		local image_x, image_y = 206, 198
		local anchor_x, anchor_y = 0.5, 0.1
		local fx_offsets_and_delays = {
			{
				V.v(127, 74),
				1.1
			},
			{
				V.v(78, 93),
				1.2
			},
			{
				V.v(108, 133),
				1.3
			},
			{
				V.v(96, 47),
				1.4
			},
			{
				V.v(76, 106),
				1.5
			},
			{
				V.v(129, 101),
				1.6
			},
			{
				V.v(136, 82),
				1.7
			},
			{
				V.v(101, 140),
				1.8
			},
			{
				V.v(79, 64),
				1.9
			}
		}

		for _, p in pairs(fx_offsets_and_delays) do
			local pos, delay = unpack(p)
			local fx = E:create_entity("fx")

			fx.pos.x = this.pos.x + pos.x - image_x * anchor_x
			fx.pos.y = this.pos.y + pos.y - image_y * anchor_y
			fx.render.sprites[1].name = "efreeti_explosion"
			fx.render.sprites[1].ts = store.tick_ts + delay

			queue_insert(store, fx)
		end

		while store.tick_ts - death_start_ts < 1.9 do
			coroutine.yield()
		end

		this.render.sprites[1].hidden = true

		while store.tick_ts - death_start_ts < 2.2 do
			coroutine.yield()
		end

		local lamp = E:create_entity("decal")

		lamp.render.sprites[1].loop = false
		lamp.render.sprites[1].anchor.y = 0.09
		lamp.render.sprites[1].name = "efreeti_lamp_fall"
		lamp.render.sprites[1].ts = store.tick_ts
		lamp.render.sprites[1].z = Z_EFFECTS
		lamp.pos.x, lamp.pos.y = this.pos.x, this.pos.y

		queue_insert(store, lamp)

		while not U.animation_finished(this, 2) do
			coroutine.yield()
		end
	end

	local function spawn_efreeti_small(pos, subpath)
		local nodes = P:nearest_nodes(pos.x, pos.y)

		if #nodes > 0 then
			local pi, spi, ni = unpack(nodes[1])

			if subpath then
				spi = subpath
			end

			local e = E:create_entity("enemy_efreeti_small")

			e.nav_path.pi, e.nav_path.spi, e.nav_path.ni = pi, spi, ni

			queue_insert(store, e)

			local fx = E:create_entity("fx")

			fx.pos.x, fx.pos.y = pos.x, pos.y
			fx.render.sprites[1].name = "enemy_efreeti_small_raise"
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].anchor.y = e.render.sprites[1].anchor.y
			fx.render.sprites[1].z = Z_OBJECTS
			fx.render.sprites[1].draw_order = 2

			queue_insert(store, fx)
		else
			log.debug("no nodes nearby %s,%s to spanw enemy_efreeti_small", pos.x, pos.y)
		end
	end

	local function can_polymorph()
		for _, e in pairs(store.entities) do
			if e.soldier and not e.health.dead and band(e.vis.bans, F_POLYMORPH) == 0 and U.is_inside_ellipse(e.pos, this.pos, a_poly.max_range) and not U.is_inside_ellipse(e.pos, this.pos, a_poly.min_range) then
				return true
			end
		end

		return false
	end

	local function do_polymorph()
		local targets = table.filter(store.entities, function(_, e)
			return e.soldier and e.health and not e.health.dead and e.vis and band(e.vis.bans, F_POLYMORPH) == 0 and U.is_inside_ellipse(e.pos, this.pos, a_poly.max_range) and not U.is_inside_ellipse(e.pos, this.pos, a_poly.min_range)
		end)

		for i = 1, math.min(#targets, a_poly.max_count) do
			local target = targets[i]
			local d = E:create_entity("damage")

			d.damage_type = DAMAGE_EAT
			d.source_id = this.id
			d.target_id = target.id

			queue_damage(store, d)
			spawn_efreeti_small(target.pos)
		end
	end

	local function do_desintegrate()
		local targets = table.filter(store.entities, function(_, e)
			return e.soldier and e.health and not e.health.dead and U.is_inside_ellipse(e.pos, this.pos, a_des.max_range)
		end)

		for i = 1, math.min(#targets, a_des.max_count) do
			local target = targets[i]
			local d = E:create_entity("damage")

			d.damage_type = bor(DAMAGE_DISINTEGRATE_BOSS, DAMAGE_INSTAKILL)
			d.source_id = this.id
			d.target_id = target.id

			queue_damage(store, d)
		end
	end

	local function can_sand()
		for _, e in pairs(store.entities) do
			if e.tower and not e.tower_holder and not e.tower.blocked and V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < a_sand.max_range then
				return true
			end
		end

		return false
	end

	local function do_sand()
		local towers = table.filter(store.entities, function(_, e)
			return e.tower and not e.tower_holder and not e.tower.blocked and V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < a_sand.max_range
		end)

		for i = 1, math.min(#towers, a_sand.max_count) do
			local t = towers[i]
			local m = E:create_entity(a_sand.mod)

			m.modifier.target_id = t.id
			m.modifier.source_id = this.id
			m.pos = t.pos

			queue_insert(store, m)
		end
	end

	local function do_spawn(spawn_cycle)
		local places = this.health.hp < a_spawn.health_threshold and math.random(3, 4) or 2

		for i = 1, places do
			spawn_efreeti_small(a_spawn.coords[i], km.zmod(spawn_cycle, 3))
		end
	end

	this.phase = "spawn"
	this.health_bar.hidden = true

	local an, af = U.animation_name_facing_point(this, "idle", this.motion.dest)

	U.animation_start(this, an, af, store.tick_ts)

	this.render.sprites[1].ts = store.tick_ts
	this.render.sprites[3].ts = store.tick_ts

	U.y_wait(store, 1.5)
	S:queue(this.sound_events.laugh)

	this.tween.disabled = true

	U.y_animation_play(this, "laugh", nil, store.tick_ts, 6)

	this.health_bar.hidden = false
	this.vis.bans = this.vis.bans_in_battlefield
	this.phase = "loop"

	::label_211_0::

	while true do
		if this.health.dead then
			this.phase = "dead"

			LU.kill_all_enemies(store, true)
			do_death()
			queue_remove(store, this)
			signal.emit("boss-killed", this)

			return
		end

		if this.unit.is_stunned then
			coroutine.yield()

			powers_ts = store.tick_ts
		else
			if store.tick_ts - powers_ts > this.attacks.cooldown then
				if math.random() < a_sand.chance then
					if can_sand() then
						S:queue(this.sound_events.sand)
						U.animation_start(this, a_sand.animation, nil, store.tick_ts)
						U.y_wait(store, a_sand.shoot_time)

						if this.unit.is_stunned then
							goto label_211_0
						end

						do_sand()
						U.y_animation_wait(this, 2)
						S:queue(this.sound_events.laugh)
						U.y_animation_play(this, "laugh", nil, store.tick_ts, 6)

						goto label_211_1
					end
				elseif math.random() < a_poly.chance and can_polymorph() then
					S:queue(this.sound_events.polymorph, {
						delay = fts(15)
					})
					U.animation_start(this, a_poly.animation, nil, store.tick_ts, 1)
					U.y_wait(store, a_poly.hit_time)

					if this.unit.is_stunned then
						goto label_211_0
					end

					do_polymorph()
					U.y_animation_wait(this, 2)

					goto label_211_1
				end

				S:queue(this.sound_events.spawn, {
					delay = fts(15)
				})
				U.animation_start(this, a_spawn.animation, nil, store.tick_ts, 1)

				for i = 1, a_spawn.max_count do
					U.y_wait(store, a_spawn.spawn_time)

					if this.unit.is_stunned then
						goto label_211_0
					end

					do_spawn(i)
				end

				U.y_animation_wait(this, 2)

				::label_211_1::

				powers_ts = store.tick_ts
			end

			blocker = U.get_blocker(store, this)

			if blocker and SU.y_wait_for_blocker(store, this, blocker) then
				S:queue(this.sound_events.desintegrate, {
					delay = fts(15)
				})
				U.animation_start(this, "attack", nil, store.tick_ts, 1)
				U.y_wait(store, a_des.hit_time)

				if this.unit.is_stunned then
					goto label_211_0
				end

				do_desintegrate()
				U.y_animation_wait(this, 2)
			end

			if not U.get_blocker(store, this) then
				if not SU.y_enemy_walk_step(store, this) then
					return
				end
			else
				coroutine.yield()
			end
		end
	end
end

scripts.eb_gorilla = {}

function scripts.eb_gorilla.get_info(this)
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

function scripts.eb_gorilla.insert(this, store, script)
	if this.melee then
		this.melee.order = U.attack_order(this.melee.attacks)
	end

	return true
end

function scripts.eb_gorilla.update(this, store, script)
	local a_spawn = this.attacks.list[1]
	local a_heal = this.attacks.list[2]
	local a_ranged = this.attacks.list[3]
	local on_tower = false
	local on_tower_ts, blocker

	local function y_jump(from, to, flight_time)
		local from = V.vclone(from)
		local g = -0.9 / (fts(1) * fts(1))

		if not flight_time then
			local dist = V.dist(to.x, to.y, from.x, from.y)

			flight_time = fts(23 + math.floor(dist * 1 / 60))
		end

		local speed = SU.initial_parabola_speed(from, to, flight_time, g)
		local ts = store.tick_ts
		local warped_time = (store.tick_ts - ts) * 2

		while warped_time <= flight_time do
			this.pos.x, this.pos.y = SU.position_in_parabola(warped_time, from, speed, g)

			coroutine.yield()

			warped_time = (store.tick_ts - ts) * 2
		end

		this.pos.x, this.pos.y = to.x, to.y

		coroutine.yield()
	end

	local enter_from = V.vclone(this.pos)
	local enter_to = P:node_pos(this.nav_path)

	U.animation_start(this, "fly", nil, store.tick_ts, true)

	this.render.sprites[1].z = Z_OBJECTS_SKY

	y_jump(enter_from, enter_to, 1)

	this.render.sprites[1].z = Z_OBJECTS

	S:queue(this.sound_events.drop_from_sky)
	U.y_animation_play(this, "jump_down_end", nil, store.tick_ts)
	S:queue(a_spawn.sound)
	U.y_animation_play(this, "call", nil, store.tick_ts)

	a_spawn.ts = store.tick_ts
	a_heal.ts = store.tick_ts
	a_ranged.ts = store.tick_ts
	on_tower_ts = store.tick_ts

	::label_225_0::

	while true do
		if this.health.dead then
			S:queue(this.sound_events.death)
			LU.kill_all_enemies(store, true)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)

			return
		end

		if this.unit.is_stunned then
			coroutine.yield()
		else
			if on_tower then
				if store.tick_ts - on_tower_ts > this.on_tower_time then
					local left_side = this.nav_path.pi == 1

					if not left_side then
						this.nav_path.ni = this.nav_path.ni + this.jump_down_advance_nodes
					end

					this.vis.bans = bor(this.vis.bans, F_FREEZE)

					U.y_animation_play(this, "jump_down_start", nil, store.tick_ts)
					U.animation_start(this, "fly", left_side, store.tick_ts, true)

					this.render.sprites[1].z = Z_OBJECTS_SKY

					y_jump(this.pos, P:node_pos(this.nav_path))

					this.render.sprites[1].z = Z_OBJECTS
					this.render.sprites[1].sort_y_offset = nil

					S:queue(this.sound_events.drop_from_sky)
					U.y_animation_play(this, "jump_down_end", nil, store.tick_ts)

					on_tower = false
					this.vis.bans = band(this.vis.bans, bnot(F_BLOCK))
					this.vis.bans = band(this.vis.bans, bnot(F_FREEZE))
					a_spawn.ts = store.tick_ts

					goto label_225_0
				end

				if store.tick_ts - this.idle_flip.ts > this.idle_flip.cooldown then
					this.idle_flip.ts = store.tick_ts
					this.vis.bans = bor(this.vis.bans, F_FREEZE)

					U.y_animation_play(this, "tower_flip_start", nil, store.tick_ts)

					local left_side = this.nav_path.pi == 1

					if left_side then
						this.pos.x, this.pos.y = this.tower_pos_right.x, this.tower_pos_right.y
						this.nav_path.pi = 2
					else
						this.pos.x, this.pos.y = this.tower_pos_left.x, this.tower_pos_left.y
						this.nav_path.pi = 1
					end

					this.render.sprites[1].flip_x = left_side

					U.y_animation_play(this, "tower_flip_end", nil, store.tick_ts)

					this.vis.bans = band(this.vis.bans, bnot(F_FREEZE))
				end

				if store.tick_ts - a_ranged.ts > a_ranged.cooldown then
					local left_side = this.nav_path.pi == 1
					local target = U.find_random_target(store.entities, this.pos, a_ranged.min_range, a_ranged.max_range, a_ranged.vis_flags, a_ranged.vis_bans, function(e)
						return e and e.pos and (left_side and e.pos.x < this.pos.x or not left_side and e.pos.x > this.pos.x)
					end)

					if target then
						a_ranged.ts = store.tick_ts

						U.animation_start(this, "throw_barrel", nil, store.tick_ts)
						U.y_wait(store, a_ranged.shoot_time)

						if this.unit.is_stunned then
							goto label_225_0
						end

						local bullet = E:create_entity(a_ranged.bullet)
						local offset = a_ranged.bullet_start_offset[1]

						bullet.pos.x, bullet.pos.y = this.pos.x + (left_side and -1 or 1) * offset.x, this.pos.y + offset.y
						bullet.bullet.from = V.vclone(bullet.pos)
						bullet.bullet.to = V.v(target.pos.x, target.pos.y)
						bullet.bullet.target_id = target.id
						bullet.bullet.rotation_speed = bullet.bullet.rotation_speed * (left_side and 1 or -1)

						queue_insert(store, bullet)
						U.y_animation_wait(this)
					end
				end
			else
				if store.tick_ts - a_spawn.ts > a_spawn.cooldown then
					a_spawn.ts = store.tick_ts

					S:queue(a_spawn.sound)
					U.y_animation_play(this, "call", nil, store.tick_ts)

					if this.unit.is_stunned then
						goto label_225_0
					end

					for i = 1, a_spawn.max_count do
						local pi = math.random() < 0.5 and 1 or 2
						local area = math.random() < 0.7 and 1 or 2
						local right_side = pi == 2
						local node_min, node_max = unpack(a_spawn.spawn_node_ranges[pi][area])
						local ni = math.random(node_min, node_max)
						local spi = math.random(1, 3)
						local dest = P:node_pos(pi, spi, ni)
						local e = E:create_entity(a_spawn.entity)

						e.pos = right_side and V.v(store.visible_coords.right, dest.y) or V.v(store.visible_coords.left, dest.y)
						e.render.sprites[1].flip_x = right_side
						e.spawn_dest = dest
						e.delay = 0.3 * (i - 1)

						queue_insert(store, e)
					end

					a_spawn.ts = store.tick_ts

					coroutine.yield()

					if this.unit.is_stunned then
						goto label_225_0
					end

					if this.health.dead then
						goto label_225_0
					end

					local other_pi = this.nav_path.pi == 1 and 2 or 1

					if #P:path(other_pi, 1) - this.nav_path.ni > this.nodes_limit then
						U.unblock_all(store, this)

						this.vis.bans = bor(this.vis.bans, F_BLOCK)
						this.vis.bans = bor(this.vis.bans, F_FREEZE)

						local fx = E:create_entity("fx_gorilla_boss_jump_smoke")

						fx.pos = V.vclone(this.pos)
						fx.render.sprites[1].ts = store.tick_ts + 0.45

						queue_insert(store, fx)

						local right_side = this.nav_path.pi == 2

						U.y_animation_play(this, "jump", right_side, store.tick_ts, 1)
						S:queue(this.sound_events.jump_to_tower)
						U.animation_start(this, "fly", right_side, store.tick_ts, true)

						this.render.sprites[1].z = Z_OBJECTS_SKY

						if right_side then
							y_jump(this.pos, this.tower_pos_right)
						else
							y_jump(this.pos, this.tower_pos_left)
						end

						this.render.sprites[1].z = Z_OBJECTS
						this.render.sprites[1].sort_y_offset = -35

						U.y_animation_play(this, "jump_reach", right_side, store.tick_ts, 1)

						on_tower = true
						on_tower_ts = store.tick_ts
						this.idle_flip.ts = store.tick_ts
						this.vis.bans = band(this.vis.bans, bnot(F_FREEZE))

						goto label_225_0
					end
				end

				if store.tick_ts - a_heal.ts > a_heal.cooldown and this.health.hp / this.health.hp_max < 0.9 then
					a_heal.ts = store.tick_ts
					this.health.hp = this.health.hp + km.clamp(0, this.health.hp_max, a_heal.points)

					S:queue(a_heal.sound)

					local fx = E:create_entity("fx_gorilla_boss_heal")

					fx.pos = this.pos
					fx.render.sprites[1].ts = store.tick_ts
					fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

					queue_insert(store, fx)
					U.y_animation_play(this, "heal", nil, store.tick_ts)

					goto label_225_0
				end

				blocker = U.get_blocker(store, this)

				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_225_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_225_0
						end

						coroutine.yield()
					end
				end

				if not U.get_blocker(store, this) then
					if not SU.y_enemy_walk_step(store, this) then
						return
					end

					goto label_225_0
				end
			end

			coroutine.yield()
		end
	end
end

scripts.eb_umbra = {}

function scripts.eb_umbra.get_info(this)
	local b = E:get_template("ray_umbra")
	local min, max = b.bullet.damage_min, b.bullet.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = 2 * min,
		damage_max = 2 * max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_umbra.insert(this, store, script)
	this.health_bar.black_bar_hp = this.health.hp_max

	return true
end

function scripts.eb_umbra.update(this, store, script)
	local as = this.attacks.list[1]
	local at = this.attacks.list[2]
	local ars = this.attacks.list[3]
	local art = this.attacks.list[4]
	local ap = this.attacks.list[5]
	local taunt = this.taunt
	local is_in_pieces = false
	local is_at_home = true
	local pieces = {}
	local max_pieces = 10
	local pieces_alive = max_pieces
	local death_cycles = 0
	local teleport_jumps = 0
	local last_jump_center = false
	local last_ray_towers_inner = false
	local piece_arrival_node = 4
	local hp_per_piece = this.health.hp_max / max_pieces
	local body_sid = 1
	local eyes_sid = 2
	local home_node = this.home_node

	local function update_cooldowns()
		if is_at_home then
			as.cooldown = as.cooldowns.at_home[pieces_alive]
			at.cooldown = at.cooldowns.at_home[pieces_alive]
			art.cooldown = art.cooldowns.at_home[pieces_alive]
		else
			as.cooldown = as.cooldowns.on_battlefield[pieces_alive]
			at.cooldown = at.cooldowns.on_battlefield[pieces_alive]
			art.cooldown = art.cooldowns.on_battlefield[pieces_alive]
		end

		as.ts = store.tick_ts
		at.ts = store.tick_ts
		art.ts = store.tick_ts
	end

	local function y_shoot_rays(attack, target, to_offset_y, fake_shot)
		to_offset_y = to_offset_y or 0
		this.render.sprites[eyes_sid].hidden = false

		local start_ts = store.tick_ts

		S:queue(attack.sound)
		U.animation_start(this, attack.animation, nil, store.tick_ts, false, eyes_sid)

		while store.tick_ts - start_ts < attack.shoot_time do
			coroutine.yield()
		end

		for _, o in pairs(attack.bullet_start_offset) do
			local r = E:create_entity(attack.bullet)

			r.bullet.from = V.v(this.pos.x + o.x, this.pos.y + o.y)
			r.bullet.to = V.v(target.pos.x, target.pos.y + to_offset_y)
			r.bullet.source_id = this.id
			r.bullet.target_id = target.id
			r.pos = V.vclone(r.bullet.from)

			if fake_shot then
				r.bullet.hit_fx = "fx_ray_umbra_explosion_smoke"
				r.bullet.damage_type = DAMAGE_NONE
			end

			queue_insert(store, r)
		end

		while not U.animation_finished(this, eyes_sid) do
			coroutine.yield()
		end

		this.render.sprites[eyes_sid].hidden = true
	end

	local function show_taunt(idx, duration, flip_x)
		local t = E:create_entity("decal_umbra_shoutbox")

		t.texts.list[1].text = _(string.format(taunt.format, idx))

		if flip_x then
			t.render.sprites[1].flip_x = true
			t.render.sprites[2].offset.x = -1 * t.render.sprites[2].offset.x
			t.pos = taunt.left_pos
		else
			t.pos = taunt.right_pos
		end

		t.timed.duration = duration
		t.render.sprites[1].ts = store.tick_ts
		t.render.sprites[2].ts = store.tick_ts

		local font_sizes = t.texts.list[1].font_sizes

		if idx == 1 then
			t.texts.list[1].font_size = font_sizes[1]
		elseif idx == 2 then
			t.texts.list[1].font_size = font_sizes[2]
		else
			t.texts.list[1].font_size = font_sizes[3]
		end

		queue_insert(store, t)

		return t
	end

	update_cooldowns()

	this.nav_path = home_node
	this.pos = P:node_pos(this.nav_path)
	this.phase = "intro"

	U.animation_start(this, "idle", nil, store.tick_ts, true, body_sid)
	U.y_wait(store, fts(113))

	local off = V.v(90, 8)
	local fake_target = {}
	local guy = store.level.guy

	fake_target.id = guy.id
	fake_target.pos = V.v(guy.pos.x + off.x, guy.pos.y + off.y)

	y_shoot_rays(ars, fake_target, nil, true)
	U.y_wait(store, 0.6)
	show_taunt(1, 2)
	U.y_wait(store, 2)
	show_taunt(2, 2)
	U.y_wait(store, 2)
	show_taunt(3, 2)
	U.y_wait(store, 2)

	this.health_bar.hidden = false
	this.phase = "loop"

	update_cooldowns()

	while true do
		if is_in_pieces then
			local callback_pieces = ap.callback_pieces[km.clamp(1, 3, death_cycles)]

			while store.tick_ts - ap.ts < ap.cooldown do
				coroutine.yield()

				for i = #pieces, 1, -1 do
					local p = pieces[i]

					if pieces_alive <= callback_pieces then
						goto label_230_0
					elseif piece_arrival_node > P:nodes_to_goal(p.nav_path) then
						goto label_230_0
					elseif p.health.dead then
						pieces_alive = pieces_alive - 1

						table.remove(pieces, i)
						log.debug("died %s,  alive:%s, pieces:%s", p.id, pieces_alive, #pieces)
					end
				end
			end

			::label_230_0::

			log.debug("callback_pieces:%s, pieces:%s, pieces_alive:%s", callback_pieces, #pieces, pieces_alive)

			for i = 1, #pieces do
				local p = pieces[i]

				U.unblock_all(store, p)
				SU.remove_modifiers(store, p)

				p.motion.max_speed = p.motion.max_speed_called

				SU.stun_dec(p, true)

				p.vis.bans = F_ALL
				p.health.immune_to = DAMAGE_ALL
				p.health_bar.hidden = true
				p.health.dead = false
				p.health.hp = p.health.hp_max
				p.render.sprites[1].hidden = false
				p.call_back = true

				if not p.main_script.co then
					log.debug("rebooting umbra_piece coroutine")

					p.main_script.runs = 1
				end
			end

			local recovered_hp = 0
			local pieces_returned = {}
			local recover_pos = P:node_pos(home_node.pi, 1, P:get_end_node(home_node.pi) - piece_arrival_node)

			while #pieces > 0 do
				for i = #pieces, 1, -1 do
					local p = pieces[i]

					if piece_arrival_node > P:nodes_to_goal(p.nav_path) then
						table.remove(pieces, i)
						table.insert(pieces_returned, p)

						recovered_hp = recovered_hp + hp_per_piece
						p.motion.max_speed = 0

						S:queue("FrontiersFinalBossPiecesRegroup")

						if this.render.sprites[1].hidden and #pieces_returned == 2 then
							for _, pr in pairs(pieces_returned) do
								pr.recovered = true
								pr.health.dead = true
								pr.pos = V.vclone(recover_pos)
							end

							this.render.sprites[1].hidden = false
							this.render.sprites[1].scale = V.v(0.5, 0.5)

							U.animation_start(this, "ball_idle", nil, store.tick_ts, true)
						elseif #pieces_returned > 2 then
							local scale = this.render.sprites[1].scale.x

							scale = km.clamp(0.5, 1, scale + 0.1)
							this.render.sprites[1].scale.x = scale
							this.render.sprites[1].scale.y = scale
							p.recovered = true
							p.health.dead = true
							p.pos = V.vclone(recover_pos)
						end
					end
				end

				coroutine.yield()
			end

			log.debug("waiting for fuse")
			U.y_wait(store, 0.5)
			log.debug("transform")
			S:queue("FrontiersFinalBossRespawn")

			this.render.sprites[1].scale.x = 1
			this.render.sprites[1].scale.y = 1

			U.y_animation_play(this, "transform", nil, store.tick_ts, 1)

			pieces_alive = #pieces_returned
			this.health.hp = recovered_hp
			this.health.hp_max = recovered_hp
			this.health.dead = false
			this.health.immune_to = DAMAGE_NONE
			this.health_bar.hidden = false
			this.vis.bans = this.vis.bans_at_home
			is_in_pieces = false

			update_cooldowns()

			force_taunt = true

			U.animation_start(this, "idle", nil, store.tick_ts, true, body_sid)
		else
			if this.health.dead then
				LU.kill_all_enemies(store, true)
				SU.remove_modifiers(store, this)
				U.unblock_all(store, this)

				if pieces_alive < ap.min_pieces_to_respawn then
					this.phase = "death-animation"

					S:stop_all()
					S:queue("FrontiersFinalBossDeath")

					local fx_explosions = {
						{
							V.v(99, 103),
							0
						},
						{
							V.v(99, 103),
							0.9
						},
						{
							V.v(99, 103),
							1.8
						},
						{
							V.v(99, 103),
							2.7
						},
						{
							V.v(134, 54),
							0.13
						},
						{
							V.v(134, 54),
							1.03
						},
						{
							V.v(134, 54),
							1.93
						},
						{
							V.v(134, 54),
							2.83
						},
						{
							V.v(147, 104),
							0.26
						},
						{
							V.v(147, 104),
							1.16
						},
						{
							V.v(147, 104),
							2.06
						},
						{
							V.v(147, 104),
							2.96
						},
						{
							V.v(68, 78),
							0.4
						},
						{
							V.v(68, 78),
							1.3
						},
						{
							V.v(68, 78),
							2.2
						},
						{
							V.v(68, 78),
							3.1
						},
						{
							V.v(169, 76),
							0.56
						},
						{
							V.v(169, 76),
							1.46
						},
						{
							V.v(169, 76),
							2.33
						},
						{
							V.v(118, 89),
							0.73
						},
						{
							V.v(118, 89),
							1.63
						},
						{
							V.v(118, 89),
							2.5
						}
					}
					local fx_rays = {
						{
							V.v(119, 88),
							0.96
						},
						{
							V.v(119, 88),
							1.2
						},
						{
							V.v(119, 88),
							1.43
						},
						{
							V.v(119, 88),
							1.63
						},
						{
							V.v(119, 88),
							1.86
						}
					}

					U.animation_start(this, "death", nil, store.tick_ts, true)
					U.y_wait(store, 3)

					local image_x, image_y = 238, 176
					local anchor_x, anchor_y = 0.5, 0.18

					for _, p in pairs(fx_explosions) do
						local pos, delay = unpack(p)
						local fx = E:create_entity("fx")

						fx.pos.x = this.pos.x + pos.x - image_x * anchor_x
						fx.pos.y = this.pos.y + pos.y - image_y * anchor_y
						fx.render.sprites[1].name = "umbra_death_explosion"
						fx.render.sprites[1].ts = store.tick_ts + delay

						queue_insert(store, fx)
					end

					for _, p in pairs(fx_rays) do
						local pos, delay = unpack(p)
						local fx = E:create_entity("fx")

						fx.pos.x = this.pos.x + pos.x - image_x * anchor_x
						fx.pos.y = this.pos.y + pos.y - image_y * anchor_y
						fx.render.sprites[1].name = "umbra_death_rays"
						fx.render.sprites[1].ts = store.tick_ts + delay

						queue_insert(store, fx)
					end

					local pos, delay = V.v(119, 85), 2.3
					local fx = E:create_entity("fx")

					fx.pos.x = this.pos.x + pos.x - image_x * anchor_x
					fx.pos.y = this.pos.y + pos.y - image_y * anchor_y
					fx.render.sprites[1].name = "umbra_death_blast_long"
					fx.render.sprites[1].ts = store.tick_ts + delay

					queue_insert(store, fx)
					U.y_wait(store, 2.5)

					local pos = V.v(119, 80)
					local fx = E:create_entity("fx_umbra_white_circle")

					fx.pos.x = this.pos.x + pos.x - image_x * anchor_x
					fx.pos.y = this.pos.y + pos.y - image_y * anchor_y
					fx.render.sprites[1].ts = store.tick_ts

					queue_insert(store, fx)
					U.y_wait(store, 1)

					this.phase = "dead"

					queue_remove(store, this)
					signal.emit("boss-killed", this)

					return
				else
					S:queue("FrontiersFinalBossExplode")

					this.health_bar.hidden = true
					this.health.immune_to = DAMAGE_ALL
					ap.ts = store.tick_ts

					local fx = E:create_entity("fx_umbra_death_blast")

					fx.render.sprites[1].name = "short"
					fx.render.sprites[1].ts = store.tick_ts
					fx.pos.x, fx.pos.y = this.pos.x, this.pos.y

					queue_insert(store, fx)

					pieces = {}

					for i = 1, pieces_alive do
						local p = E:create_entity(ap.payload_entity)

						p.nav_path.pi = table.random(ap.dest_pi)
						p.nav_path.spi = math.random(1, 3)
						p.nav_path.ni = math.random(P:get_start_node(p.nav_path.pi) + ap.initial_ni, P:get_end_node(p.nav_path.pi) - ap.limit_ni)
						p.pos = P:node_pos(p.nav_path)

						if death_cycles > 0 then
							p.piece_respawn_delay = p.piece_respawn_delay_repeating
						end

						table.insert(pieces, p)

						local s = E:create_entity(ap.entity)

						s.pos.x, s.pos.y = this.pos.x, this.pos.y
						s.pos.x = s.pos.x + math.random(ap.start_offset_x[1], ap.start_offset_x[2])
						s.pos.y = s.pos.y + math.random(ap.start_offset_y[1], ap.start_offset_y[2])
						s.bullet.from = V.vclone(s.pos)
						s.bullet.to = V.vclone(p.pos)

						local dist = V.dist(s.bullet.from.x, s.bullet.from.y, s.bullet.to.x, s.bullet.to.y)

						s.bullet.flight_time = s.bullet.flight_time + fts(dist / 30)
						s.bullet.hit_payload = p
						s.render.sprites[1].ts = store.tick_ts

						queue_insert(store, s)
					end

					U.y_animation_play(this, "explode", nil, store.tick_ts, 1)

					this.render.sprites[1].hidden = true
					this.nav_path = home_node
					this.pos = P:node_pos(this.nav_path)
					this.vis.bans = this.vis.bans_in_pieces
					is_at_home = true
					is_in_pieces = true
					death_cycles = death_cycles + 1

					goto label_230_2
				end
			end

			if is_at_home and (force_taunt or store.tick_ts - taunt.ts > taunt.cooldown) and store.tick_ts - at.ts < at.cooldown - 2 then
				force_taunt = nil

				local i = math.random(taunt.start_idx, taunt.end_idx)
				local t = show_taunt(i, taunt.duration, math.random() < 0.5)

				taunt.ts = store.tick_ts + taunt.duration
				taunt.last_id = t.id
			end

			if not this.render.sprites[1].sync_flag or this.render.sprites[1].runs == 0 then
				-- block empty
			else
				if as.cooldown > 0 and store.tick_ts - as.ts > as.cooldown then
					S:queue("FrontiersFinalBossPortal")
					U.animation_start(this, as.animation, nil, store.tick_ts, false, body_sid)

					local nleft = table.random(as.nodes_left)
					local nright = table.random(as.nodes_right)
					local nodes = {
						nleft,
						nright
					}

					for _, n in pairs(nodes) do
						local s = E:create_entity(as.entity)

						s.pos = P:node_pos(n[1])
						s.spawner.allowed_nodes = n
						s.spawner.count = as.count_min + math.floor((max_pieces - pieces_alive) * as.add_per_missing_piece)

						queue_insert(store, s)
					end

					while not U.animation_finished(this, body_sid) and not this.health.dead do
						coroutine.yield()
					end

					as.ts = store.tick_ts

					goto label_230_1
				end

				if store.tick_ts - at.ts > at.cooldown then
					this.health_bar.hidden = true
					this.health.ignore_damage = true

					S:queue("FrontiersFinalBossTeleport")
					U.y_animation_play(this, "teleport_out", nil, store.tick_ts, 1, body_sid)
					U.unblock_all(store, this)

					local jump_node

					if is_at_home then
						teleport_jumps = teleport_jumps + 1

						local idx

						if last_jump_center and teleport_jumps <= at.max_side_jumps then
							idx = math.random(2, 3)
							last_jump_center = false
						else
							idx = 1
							last_jump_center = true
						end

						jump_node = at.nodes_battlefield[idx]
						is_at_home = false

						if taunt.last_id and store.entities[last_id] then
							queue_remove(store, store.entities[last_id])

							taunt.last_id = nil
						end
					else
						jump_node = home_node
						is_at_home = true
						force_taunt = true
					end

					this.nav_path = jump_node

					local new_pos = P:node_pos(this.nav_path)

					this.pos.x, this.pos.y = new_pos.x, new_pos.y
					this.vis.bans = is_at_home and this.vis.bans_at_home or this.vis.bans_in_battlefield

					U.y_animation_play(this, "teleport_in", nil, store.tick_ts, 1, body_sid)

					this.health_bar.hidden = false
					this.health.ignore_damage = is_at_home

					update_cooldowns()

					at.ts = store.tick_ts

					goto label_230_1
				end

				if art.cooldown > 0 and store.tick_ts - art.ts > art.cooldown then
					local start_ts = store.tick_ts
					local inner, outer = {}, {}

					for _, e in pairs(store.entities) do
						if e.tower and not e.tower_holder and not e.tower.blocked and (not is_at_home or not table.contains(art.lower_towers, e.tower.holder_id)) and e.pos.y < this.pos.y then
							if table.contains(art.inner_towers, e.tower.holder_id) then
								table.insert(inner, e)
							else
								table.insert(outer, e)
							end
						end
					end

					local set

					if last_ray_towers_inner then
						set = #outer > 0 and outer or inner
					else
						set = #inner > 0 and inner or outer
					end

					last_ray_towers_inner = set == inner

					if #set > 0 then
						log.debug("Umbra ray set: %s\n outer:%s\n inner:%s", getdump(table.map(set, function(k, v)
							return v.tower.holder_id
						end)), getdump(table.map(outer, function(k, v)
							return v.tower.holder_id
						end)), getdump(table.map(inner, function(k, v)
							return v.tower.holder_id
						end)))

						local target = set[math.random(1, #set)]

						S:queue("VeznanHoldCast")
						y_shoot_rays(art, target, 20)

						art.ts = start_ts + 2
					else
						art.ts = store.tick_ts - art.cooldown + 1
					end

					goto label_230_1
				end

				if store.tick_ts - ars.ts > ars.cooldown then
					local target = U.find_nearest_soldier(store.entities, this.pos, ars.min_range, ars.max_range, ars.vis_flags, ars.vis_bans, function(t)
						return t.pos.y - 10 < this.pos.y
					end)

					if target then
						y_shoot_rays(ars, target)

						ars.ts = store.tick_ts
					else
						ars.ts = store.tick_ts - ars.cooldown + 0.5
					end
				end

				::label_230_1::

				U.animation_start(this, "idle", nil, store.tick_ts, true, body_sid)
			end
		end

		::label_230_2::

		coroutine.yield()
	end
end

scripts.umbra_portal = {}

function scripts.umbra_portal.update(this, store, script)
	local sp = this.spawner
	local s = this.render.sprites[1]
	local spawn_ts

	if sp.animation_start then
		U.y_animation_play(this, sp.animation_start, nil, store.tick_ts, 1)
	end

	if sp.animation_loop then
		U.animation_start(this, sp.animation_loop, nil, store.tick_ts, true)
	end

	for i = 1, sp.count do
		if sp.interrupt then
			break
		end

		local no = table.random(sp.allowed_nodes)
		local spawn = E:create_entity(sp.entity)

		spawn.nav_path.pi = no.pi
		spawn.nav_path.spi = km.zmod(i, 3)
		spawn.nav_path.ni = no.ni + math.random(-sp.ni_var, sp.ni_var)
		spawn.unit.spawner_id = this.id
		spawn.pos = P:node_pos(spawn.nav_path)

		queue_insert(store, spawn)

		if sp.spawn_fx then
			fx = E:create_entity(sp.spawn_fx)
			fx.pos.x, fx.pos.y = spawn.pos.x, spawn.pos.y - 1
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)
		end

		spawn_ts = store.tick_ts

		while store.tick_ts - spawn_ts < sp.cycle_time do
			if sp.interrupt then
				goto label_238_0
			end

			coroutine.yield()
		end
	end

	::label_238_0::

	if sp.animation_end then
		U.y_animation_play(this, sp.animation_end, nil, store.tick_ts, 1)
	end

	queue_remove(store, this)
end

scripts.enemy_umbra_piece = {}

function scripts.enemy_umbra_piece.update(this, store, script)
	this.health_bar.hidden = true

	U.y_animation_play(this, "fall", nil, store.tick_ts, 1)
	U.y_wait(store, this.piece_respawn_delay)
	S:queue(this.sound_events.raise)
	U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

	this.vis.bans = this.vis.bans_walking
	this.health_bar.hidden = false

	::label_239_0::

	this.call_back = false

	U.animation_start(this, "idle", nil, store.tick_ts, true)

	::label_239_1::

	while true do
		if this.recovered then
			U.y_animation_play(this, "fuse", nil, store.tick_ts, 1)
			queue_remove(store, this)

			return
		end

		if this.health.dead then
			coroutine.yield()

			if this.call_back then
				goto label_239_0
			end

			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this)

			if not cont then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_239_1
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_239_1
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.umbra_guy = {}

function scripts.umbra_guy.update(this, store, script)
	local at = this.attacks.list[1]
	local taunt = this.taunt
	local last_lives = store.lives

	local function show_taunt(idx, duration)
		local t = E:create_entity("decal_umbra_guy_shoutbox")

		t.texts.list[1].text = _(string.format(taunt.format, idx))
		t.pos = taunt.normal_pos
		t.timed.duration = duration
		t.render.sprites[1].ts = store.tick_ts
		t.render.sprites[2].ts = store.tick_ts

		if #t.texts.list[1].text > 40 then
			t.texts.list[1].line_height = t.texts.list[1].line_heights[2]
		else
			t.texts.list[1].line_height = t.texts.list[1].line_heights[1]
		end

		queue_insert(store, t)

		return t
	end

	U.animation_start(this, "taunt", nil, store.tick_ts, true)

	while this.phase ~= "intro" do
		coroutine.yield()
	end

	show_taunt(1, 4)
	U.y_wait(store, 4)
	show_taunt(2, 4)
	U.y_wait(store, 4)

	at.ts = store.tick_ts
	taunt.ts = store.tick_ts
	this.phase = "intro-finished"

	while true do
		if this.phase == "death" then
			this.phase = "death-started"

			show_taunt(50, 3)
			U.animation_start(this, "idle", nil, store.tick_ts, true)
			U.y_wait(store, 4.1)
			U.animation_start(this, "death", nil, store.tick_ts, false)
			U.y_wait(store, fts(49))

			local t = show_taunt(0, fts(58))

			t.pos.x, t.pos.y = taunt.death_pos.x, taunt.death_pos.y

			U.y_animation_wait(this)
			queue_remove(store, this)

			return
		end

		if last_lives ~= store.lives and store.tick_ts - taunt.ts > taunt.cooldown / 2 then
			last_lives = store.lives

			local i = math.random(taunt.lost_life_idx[1], taunt.lost_life_idx[2])
			local t = show_taunt(i, taunt.duration)

			U.animation_start(this, "taunt", nil, store.tick_ts, true)
			U.y_wait(store, taunt.duration)

			taunt.ts = store.tick_ts

			if store.tick_ts - at.ts + 2 > at.cooldown then
				at.ts = at.ts + 2
			end

			goto label_240_0
		end

		if store.tick_ts - taunt.ts > taunt.cooldown then
			local i = math.random(taunt.normal_idx[1], taunt.normal_idx[2])
			local t = show_taunt(i, taunt.duration)

			U.animation_start(this, "taunt", nil, store.tick_ts, true)
			U.y_wait(store, taunt.duration)

			taunt.ts = store.tick_ts

			if store.tick_ts - at.ts + 2 > at.cooldown then
				at.ts = at.ts + 2
			end

			goto label_240_0
		end

		if store.wave_group_number > 0 and store.tick_ts - at.ts > at.cooldown then
			local target = U.find_random_target(store.entities, this.pos, 0, at.max_range, at.vis_flags, at.vis_bans)

			if not target then
				-- block empty
			else
				local start_ts = store.tick_ts

				log.debug(">>> %s: umbra_guy firing at (%s) %s", store.tick_ts, target.id, target.template_name)

				local i = math.random(taunt.attack_idx[1], taunt.attack_idx[2])

				show_taunt(i, taunt.attack_duration)

				taunt.ts = store.tick_ts + taunt.attack_duration

				U.animation_start(this, at.animation, ni, store.tick_ts, false)
				U.y_wait(store, at.shoot_time)

				local off = at.bullet_start_offset
				local toff = V.v(0, 0)

				if target.unit and target.unit.hit_offset then
					toff.x, toff.y = target.unit.hit_offset.x, target.unit.hit_offset.y
				end

				local r = E:create_entity(at.bullet)

				r.bullet.from = V.v(this.pos.x + off.x, this.pos.y + off.y)
				r.bullet.to = V.v(target.pos.x + toff.x, target.pos.y + toff.y)
				r.bullet.source_id = this.id
				r.bullet.target_id = target.id
				r.pos = V.vclone(r.bullet.from)

				queue_insert(store, r)
				U.y_animation_wait(this)

				at.ts = store.tick_ts

				if store.tick_ts - taunt.ts + 2 > taunt.cooldown then
					taunt.ts = taunt.ts + 2
				end
			end
		end

		::label_240_0::

		U.animation_start(this, "idle", nil, store.tick_ts, true)
		coroutine.yield()
	end
end

scripts.eb_leviathan = {}

function scripts.eb_leviathan.get_info(this)
	return {
		damage_min = 500,
		damage_max = 800,
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_leviathan.insert(this, store, script)
	local next, new = P:next_entity_node(this, store.tick_length)

	if not next then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)

		return false
	end

	U.set_destination(this, next)

	if not this.pos or this.pos.x == 0 and this.pos.y == 0 then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end

	return true
end

function scripts.eb_leviathan.update(this, store, script)
	local sid = 2
	local a_t = this.attacks.list[1]
	local tentacles = {}
	local tentacle_seq_idx = 1
	local tentacle_seq = this.tentacle_seq
	local tentacle_pos = this.tentacle_pos

	local function do_death()
		S:queue(this.sound_events.death)
		U.animation_start(this, "death", nil, store.tick_ts, false)

		this.render.sprites[1].hidden = true

		local fxs = {
			{
				V.v(-50, 35),
				fts(20)
			},
			{
				V.v(-22, 49),
				fts(22)
			},
			{
				V.v(-15, 16),
				fts(22)
			},
			{
				V.v(30, 47),
				fts(24)
			},
			{
				V.v(26, 10),
				fts(24)
			},
			{
				V.v(3, 64),
				fts(26)
			},
			{
				V.v(-33, 31),
				fts(27)
			},
			{
				V.v(49, 53),
				fts(29)
			},
			{
				V.v(48, 31),
				fts(31)
			},
			{
				V.v(-38, 55),
				fts(33)
			},
			{
				V.v(-14, 59),
				fts(36)
			},
			{
				V.v(-3, 41),
				fts(36)
			},
			{
				V.v(28, 48),
				fts(36)
			},
			{
				V.v(-2, 37),
				fts(39)
			},
			{
				V.v(4, 66),
				fts(39)
			},
			{
				V.v(19, 53),
				fts(39)
			},
			{
				V.v(3, 63),
				fts(45)
			},
			{
				V.v(-25, 50),
				fts(45)
			},
			{
				V.v(-18, 74),
				fts(45)
			},
			{
				V.v(12, 38),
				fts(45)
			},
			{
				V.v(47, 41),
				fts(45)
			},
			{
				V.v(3, 44),
				fts(50)
			},
			{
				V.v(-6, 59),
				fts(50)
			},
			{
				V.v(12, 59),
				fts(50)
			},
			{
				V.v(-4, 64),
				fts(58)
			},
			{
				V.v(16, 59),
				fts(58)
			},
			{
				V.v(3, 42),
				fts(58)
			}
		}
		local fx_scale = 1

		for i, p in ipairs(fxs) do
			fx_scale = fx_scale - (i % 5 == 0 and 0.1 or 0)

			local offset, delay = unpack(p)
			local fx = E:create_entity("fx_explosion_water")

			fx.pos.x = this.pos.x + offset.x
			fx.pos.y = this.pos.y + offset.y - 15
			fx.render.sprites[1].ts = store.tick_ts + delay
			fx.render.sprites[1].scale = V.v(fx_scale, fx_scale)

			queue_insert(store, fx)
		end

		U.y_animation_wait(this, sid)
	end

	this.phase = "spawn"

	U.sprites_hide(this)

	this.health_bar.hidden = true

	local fx = E:create_entity("fx_leviathan_incoming")

	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)
	U.y_wait(store, 3)
	S:queue("RTBossSpawn")

	this.render.sprites[sid].hidden = nil

	local an, af = U.animation_name_facing_point(this, "spawn", this.motion.dest)

	U.y_animation_play(this, an, af, store.tick_ts, 1, sid)

	local an, af = U.animation_name_facing_point(this, "idle", this.motion.dest)

	U.animation_start(this, an, af, store.tick_ts, true, sid)

	this.render.sprites[1].hidden = nil
	this.health_bar.hidden = nil
	this.phase = "loop"
	this.vis.bans = this.vis.bans_in_battlefield
	a_t.ts = store.tick_ts

	::label_244_0::

	while true do
		if this.health.dead then
			this.phase = "dead"

			LU.kill_all_enemies(store, true)

			for _, t in pairs(tentacles) do
				t.interrupt = true
			end

			do_death()
			queue_remove(store, this)
			signal.emit("boss-killed", this)

			return
		end

		if this.unit.is_stunned then
			coroutine.yield()
		else
			if store.tick_ts - a_t.ts > a_t.cooldown then
				local seq = tentacle_seq[tentacle_seq_idx]

				tentacle_seq_idx = km.zmod(tentacle_seq_idx + 1, #tentacle_seq)

				for _, idx in pairs(seq) do
					local tp = tentacle_pos[idx]
					local e = E:create_entity("leviathan_tentacle")

					e.pos.x, e.pos.y = tp[1], tp[2]
					e.flip = tp[3]

					LU.queue_insert(store, e)
					table.insert(tentacles, e)
					U.y_wait(store, U.frandom(0.1, 0.2))
				end

				while #tentacles > 0 do
					U.y_wait(store, 0.25)

					if this.health.dead then
						goto label_244_0
					end

					for i = #tentacles, 1, -1 do
						local t = tentacles[i]

						if not store.entities[t.id] then
							table.remove(tentacles, i)
						end
					end
				end

				a_t.ts = store.tick_ts
			end

			if not SU.y_enemy_walk_step(store, this) then
				return
			end
		end

		if false then
			coroutine.yield()
		end
	end
end

scripts.leviathan_tentacle = {}

function scripts.leviathan_tentacle.update(this, store)
	local s = this.render.sprites[1]

	s.flip_x = this.flip

	local search_pos = V.v(this.pos.x + (this.flip and -1 or 1) * this.search_off_x, this.pos.y)

	S:queue("RTBossTentacle")
	U.y_animation_play(this, "show", nil, store.tick_ts)
	U.animation_start(this, "wiggle", nil, store.tick_ts, true)

	local start_ts = store.tick_ts

	while not this.interrupt and store.tick_ts - start_ts < this.duration do
		U.y_wait(store, 2)

		local targets = table.filter(store.entities, function(k, e)
			return e and e.tower and not e.tower_holder and e.tower.type ~= "build_animation" and not e.tower.blocked and not table.contains(this.tower_bans, e.template_name) and U.is_inside_ellipse(e.pos, search_pos, this.range)
		end)

		if #targets > 0 then
			local target = targets[1]

			SU.tower_block_inc(target)
			S:queue("RTBossTentacleAttack")
			U.y_animation_play(this, "attack", nil, store.tick_ts)
			U.animation_start(this, "hold", nil, store.tick_ts, true)

			start_ts = store.tick_ts

			while not this.interrupt and store.tick_ts - start_ts < this.duration do
				coroutine.yield()
			end

			SU.tower_block_dec(target)
			U.y_animation_play(this, "release", nil, store.tick_ts)

			break
		end
	end

	U.y_animation_play(this, "hide", nil, store.tick_ts)
	queue_remove(store, this)
end

scripts.eb_dracula = {}

function scripts.eb_dracula.get_info(this)
	return {
		damage_min = 150,
		damage_max = 200,
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_dracula.insert(this, store, script)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.eb_dracula.can_lifesteal(this, store, attack, target)
	return target.template_name ~= "soldier_death_rider" and target.template_name ~= "soldier_skeleton" and target.template_name ~= "soldier_skeleton_knight"
end

function scripts.eb_dracula.update(this, store, script)
	local function y_fly_to(pos)
		U.animation_start(this, "bat_fly", nil, store.tick_ts, true)
		U.set_destination(this, pos)

		this.motion.max_speed = this.motion.max_speed_bat

		while not this.motion.arrived do
			U.walk(this, store.tick_length)
			coroutine.yield()
		end

		local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {
			this.nav_path.pi
		})

		this.nav_path.ni = nodes[1][3]
		this.motion.max_speed = this.motion.max_speed_default
	end

	this.phase = "intro"

	y_fly_to(V.v(520, 590))
	U.y_animation_play(this, "bat_exit", nil, store.tick_ts)
	U.animation_start(this, "idle", nil, store.tick_ts, true)

	local t = E:create_entity("decal_dracula_shoutbox")

	t.texts.list[1].text = _("DRACULA_TAUNT_FIGHT_0001")
	t.pos.x, t.pos.y = this.pos.x - 1, this.pos.y - 57
	t.timed.duration = 4.7
	t.render.sprites[1].ts = store.tick_ts
	t.render.sprites[2].ts = store.tick_ts

	queue_insert(store, t)
	U.y_wait(store, t.timed.duration + 1)

	this.phase = "fight"

	::label_251_0::

	while true do
		if this.health.dead then
			U.unblock_all(store, this)

			if this.phase == "fight" then
				this.nav_path.pi = 3
				this.nav_path.ni = 1
				this.health_bar.hidden = true

				local _vis_bans = this.vis.bans

				this.vis.bans = bor(this.vis.bans, F_ALL)

				y_fly_to(V.v(525, 540))
				y_fly_to(V.v(525, 790))

				this.vis.bans = _vis_bans
				this.phase = "angry"
				this.health_bar.hidden = nil
				this.health.hp = this.health.hp_max
				this.health.dead = false
				this.motion.max_speed = this.motion.max_speed_angry

				local e = E:create_entity("dracula_damage_aura")

				e.aura.source_id = this.id

				queue_insert(store, e)
			else
				this.phase = "dead"

				LU.kill_all_enemies(store, true)
				S:stop_all()
				S:queue(this.sound_events.death)
				U.y_animation_play(this, "death", nil, store.tick_ts)
				signal.emit("boss-killed", this)

				return
			end
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local ok, blocker = SU.y_enemy_walk_until_blocked(store, this)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_251_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_251_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.dracula_damage_aura = {}

function scripts.dracula_damage_aura.update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local last_ts = store.tick_ts
	local source = store.entities[a.source_id]

	if not source then
		queue_remove(store, this)

		return
	end

	this.pos = source.pos

	while not source.health.dead do
		if store.tick_ts - last_ts >= a.cycle_time then
			local dt = store.tick_ts - last_ts

			last_ts = store.tick_ts

			local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, target in pairs(targets) do
					local value = math.random(a.dps_min, a.dps_max)

					value = value * dt * (target.hero and a.hero_damage_factor or 1)

					if a.dist_factor_min_radius then
						local dist_factor = U.dist_factor_inside_ellipse(target.pos, this.pos, a.radius, a.dist_factor_min_radius)

						value = math.ceil(value * (1 - dist_factor))
					end

					local d = E:create_entity("damage")

					d.damage_type = a.damage_type
					d.value = value
					d.target_id = target.id
					d.source_id = this.id

					queue_damage(store, d)
				end
			end
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.mod_dracula_lifesteal = {}

function scripts.mod_dracula_lifesteal.update(this, store)
	local m = this.modifier
	local source = store.entities[m.source_id]
	local target = store.entities[m.target_id]

	m.ts = store.tick_ts

	local last_ts = store.tick_ts

	SU.stun_inc(target)

	while not source.health.dead and store.tick_ts - m.ts < m.duration do
		if store.tick_ts - last_ts > this.cycle_time then
			last_ts = store.tick_ts
			source.health.hp = km.clamp(0, source.health.hp_max, source.health.hp + this.heal_hp)
		end

		coroutine.yield()
	end

	SU.stun_dec(target)

	local d = E:create_entity("damage")

	d.value = this.damage
	d.source_id = this.id
	d.target_id = target.id
	d.damage_type = target.hero and DAMAGE_TRUE or DAMAGE_INSTAKILL

	queue_damage(store, d)
	queue_remove(store, this)
end

scripts.eb_saurian_king = {}

function scripts.eb_saurian_king.get_info(this)
	local m = E:get_template("mod_saurian_king_tongue")
	local min, max = m.modifier.damage_min, m.modifier.damage_max

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

function scripts.eb_saurian_king.insert(this, store, script)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.eb_saurian_king.update(this, store, script)
	local ha = this.timed_attacks.list[1]

	local function ready_to_hammer()
		return store.tick_ts - ha.ts > ha.cooldown
	end

	local function hammer_hit(idx)
		S:queue("SaurianKingBossQuake", {
			delay = fts(4)
		})

		local a = E:create_entity("aura_screen_shake")

		a.aura.amplitude = idx / #ha.max_damages

		queue_insert(store, a)

		local dmin, dmax = ha.min_damages[idx], ha.max_damages[idx]
		local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, ha.damage_radius, ha.vis_flags, ha.vis_bans)

		if targets then
			for _, target in pairs(targets) do
				local dist_factor = U.dist_factor_inside_ellipse(target.pos, this.pos, ha.damage_radius, ha.max_damage_radius)
				local d = E:create_entity("damage")

				d.damage_type = ha.damage_type
				d.value = math.ceil(dmax - (dmax - dmin) * dist_factor)
				d.target_id = target.id
				d.source_id = this.id

				queue_damage(store, d)
			end
		end

		local fx = E:create_entity("decal_saurian_king_hammer")
		local o = ha.fx_offsets[km.zmod(idx, 2)]

		fx.pos = V.v(this.pos.x + o.x * (this.render.sprites[1].flip_x and -1 or 1), o.y + this.pos.y)
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	ha.ts = store.tick_ts

	::label_257_0::

	while true do
		if this.health.dead then
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)

			ha.ts = store.tick_ts

			coroutine.yield()
		else
			if ready_to_hammer() then
				U.y_animation_play(this, ha.animations[1], nil, store.tick_ts)

				for i = 1, #ha.max_damages / 2 do
					if this.health.dead then
						goto label_257_1
					end

					if this.unit.is_stunned then
						goto label_257_1
					end

					U.animation_start(this, ha.animations[2], nil, store.tick_ts)
					S:queue(ha.sound, {
						delay = fts(3)
					})
					U.y_wait(store, ha.hit_times[1])

					if this.unit.is_stunned then
						goto label_257_1
					end

					hammer_hit(2 * i - 1)
					S:queue(ha.sound, {
						delay = fts(10)
					})
					U.y_wait(store, ha.hit_times[2])

					if this.unit.is_stunned then
						goto label_257_1
					end

					hammer_hit(2 * i)
					U.y_animation_wait(this)
				end

				ha.ts = store.tick_ts
			end

			::label_257_1::

			local ok, blocker = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_hammer()
			end)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_257_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_hammer() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_257_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.mod_saurian_king_tongue = {}

function scripts.mod_saurian_king_tongue.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		return false
	end

	local d = E:create_entity("damage")

	d.damage_type = DAMAGE_TRUE
	d.value = math.random(m.damage_min, m.damage_max)
	d.target_id = target.id
	d.source_id = this.id

	queue_damage(store, d)

	return false
end

scripts.enemy_saurian_king = {}
function scripts.enemy_saurian_king.update(this, store, script)
	local ha = this.timed_attacks.list[1]

	local function ready_to_hammer()
		return store.tick_ts - ha.ts > ha.cooldown
	end

	local function hammer_hit(idx)
		S:queue("SaurianKingBossQuake", {
			delay = fts(4)
		})

		local a = E:create_entity("aura_screen_shake")

		a.aura.amplitude = idx / #ha.max_damages

		queue_insert(store, a)

		local dmin, dmax = ha.min_damages[idx], ha.max_damages[idx]
		local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, ha.damage_radius, ha.vis_flags, ha.vis_bans)

		if targets then
			for _, target in pairs(targets) do
				local dist_factor = U.dist_factor_inside_ellipse(target.pos, this.pos, ha.damage_radius, ha.max_damage_radius)
				local d = E:create_entity("damage")

				d.damage_type = ha.damage_type
				d.value = math.ceil(dmax - (dmax - dmin) * dist_factor)
				d.target_id = target.id
				d.source_id = this.id

				queue_damage(store, d)
			end
		end

		local fx = E:create_entity("decal_enemy_saurian_king_hammer")
		local o = ha.fx_offsets[km.zmod(idx, 2)]

		fx.pos = V.v(this.pos.x + o.x * (this.render.sprites[1].flip_x and -1 or 1), o.y + this.pos.y)
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	ha.ts = store.tick_ts

	::label_257_0::

	while true do
		if this.health.dead then
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)

			ha.ts = store.tick_ts

			coroutine.yield()
		else
			if ready_to_hammer() then
				U.y_animation_play(this, ha.animations[1], nil, store.tick_ts)

				for i = 1, #ha.max_damages / 2 do
					if this.health.dead then
						goto label_257_1
					end

					if this.unit.is_stunned then
						goto label_257_1
					end

					U.animation_start(this, ha.animations[2], nil, store.tick_ts)
					S:queue(ha.sound, {
						delay = fts(3)
					})
					U.y_wait(store, ha.hit_times[1])

					if this.unit.is_stunned then
						goto label_257_1
					end

					hammer_hit(2 * i - 1)
					S:queue(ha.sound, {
						delay = fts(10)
					})
					U.y_wait(store, ha.hit_times[2])

					if this.unit.is_stunned then
						goto label_257_1
					end

					hammer_hit(2 * i)
					U.y_animation_wait(this)
				end

				ha.ts = store.tick_ts
			end

			::label_257_1::

			local ok, blocker = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_hammer()
			end)

			if not ok then
				-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_257_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_hammer() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_257_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.hero_alric = {}

function scripts.hero_alric.get_info(this)
	local a = this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_alric.level_up(this, store, initial)
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

	s = this.hero.skills.swordsmanship

	if s.level > 0 then
		for i = 1, 3 do
			this.melee.attacks[i].damage_min = this.melee.attacks[i].damage_min + s.extra_damage[s.level]
			this.melee.attacks[i].damage_max = this.melee.attacks[i].damage_max + s.extra_damage[s.level]
		end
	end

	s = this.hero.skills.spikedarmor

	if initial and s.level > 0 then
		this.health.spiked_armor = s.values[s.level]
	end

	s = this.hero.skills.toughness

	if s.level > 0 then
		this.health.hp_max = this.health.hp_max + s.hp_max[s.level]
		this.regen.health = this.regen.health + s.regen[s.level]
	end

	s = this.hero.skills.flurry

	if initial and s.level > 0 then
		this.melee.attacks[3].disabled = nil
		this.melee.attacks[3].cooldown = s.cooldown[s.level]
		this.melee.attacks[3].loops = s.loops[s.level]
	end

	s = this.hero.skills.sandwarriors

	if initial and s.level > 0 then
		this.timed_attacks.list[1].disabled = nil

		local e = E:get_template(this.timed_attacks.list[1].entity)

		e.lifespan.duration = s.lifespan[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_alric.insert(this, store, script)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.hero_alric.update(this, store, script)
	local h = this.health
	local he = this.hero
	local swa = this.timed_attacks.list[1]
	local sws = this.hero.skills.sandwarriors
	local brk, sta

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
					goto label_265_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if not swa.disabled and store.tick_ts - swa.ts > swa.cooldown then
				local target_info = U.find_enemies_in_paths(store.entities, this.pos, 0, swa.range_nodes, nil, swa.vis_flags, swa.vis_bans, true)

				if target_info then
					local target = target_info[1].target
					local origin = target_info[1].origin
					local start_ts = store.tick_ts

					S:queue(swa.sound)
					U.animation_start(this, swa.animation, nil, store.tick_ts, 1)

					while store.tick_ts - start_ts < swa.spawn_time do
						if this.nav_rally.new then
							goto label_265_0
						end

						if this.health.dead then
							goto label_265_0
						end

						if this.unit.is_stunned then
							goto label_265_0
						end

						coroutine.yield()
					end

					swa.ts = start_ts

					SU.hero_gain_xp_from_skill(this, sws)

					for i = 1, sws.count[sws.level] do
						local spawn = E:create_entity(swa.entity)

						spawn.nav_path.pi = origin[1]
						spawn.nav_path.spi = km.zmod(i, 3)
						spawn.nav_path.ni = origin[3]
						spawn.unit.level = sws.level

						queue_insert(store, spawn)
					end

					while not U.animation_finished(this) do
						if this.nav_rally.new then
							goto label_265_0
						end

						if this.health.dead then
							goto label_265_0
						end

						if this.unit.is_stunned then
							goto label_265_0
						end

						coroutine.yield()
					end
				else
					swa.ts = store.tick_ts + 0.2
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

		::label_265_0::

		coroutine.yield()
	end
end

scripts.soldier_sand_warrior = {}

function scripts.soldier_sand_warrior.get_info(this)
	local t = scripts.soldier_barrack.get_info(this)

	t.respawn = nil

	return t
end

function scripts.soldier_sand_warrior.insert(this, store, script)
	this.melee.order = U.attack_order(this.melee.attacks)
	this.health.hp_max = this.health.hp_max + this.health.hp_inc * this.unit.level

	local node_offset = math.random(3, 6)

	this.nav_path.ni = this.nav_path.ni + node_offset
	this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)

	if not this.pos then
		return false
	end

	return true
end

function scripts.soldier_sand_warrior.update(this, store, script)
	local attack = this.melee.attacks[1]
	local target
	local expired = false
	local next_pos = V.vclone(this.pos)
	local brk, sta, nearest

	this.lifespan.ts = store.tick_ts

	U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

	while true do
		if this.health.dead or store.tick_ts - this.lifespan.ts > this.lifespan.duration then
			this.health.hp = 0

			SU.y_soldier_death(store, this)
			queue_remove(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
		else
			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			else
				nearest = P:nearest_nodes(this.pos.x, this.pos.y, {
					this.nav_path.pi
				}, {
					this.nav_path.spi
				})

				if nearest and nearest[1] and nearest[1][3] < this.nav_path.ni then
					this.nav_path.ni = nearest[1][3]
				end

				U.y_animation_play(this, "start_walk", nil, store.tick_ts, 1)

				while next_pos and not target and not this.health.dead and not expired and not this.unit.is_stunned do
					U.set_destination(this, next_pos)

					local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

					U.animation_start(this, an, af, store.tick_ts, -1)
					U.walk(this, store.tick_length)
					coroutine.yield()

					target = U.find_foremost_enemy(store.entities, this.pos, 0, this.melee.range, false, attack.vis_flags, attack.vis_bans)
					expired = store.tick_ts - this.lifespan.ts > this.lifespan.duration
					next_pos = P:next_entity_node(this, store.tick_length)

					if not next_pos or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or GR:cell_is(next_pos.x, next_pos.y, bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) then
						next_pos = nil
					end
				end

				target = nil

				if expired or this.health.dead or not next_pos then
					this.health.hp = 0

					U.y_animation_play(this, "death_travel", nil, store.tick_ts, 1)
					queue_remove(store, this)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.hero_mirage = {}

function scripts.hero_mirage.get_info(this)
	local a = this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_mirage.level_up(this, store, initial)
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

	s = this.hero.skills.precision

	if initial and s.level > 0 then
		this.ranged.attacks[1].max_range = this.ranged.attacks[1].max_range + s.extra_range[s.level]
	end

	s = this.hero.skills.shadowdodge

	if initial and s.level > 0 then
		this.dodge.chance = s.dodge_chance[s.level]
	end

	s = this.hero.skills.swiftness

	if initial and s.level > 0 then
		this.motion.max_speed = this.motion.max_speed * s.max_speed_factor[s.level]
	end

	s = this.hero.skills.shadowdance

	if initial and s.level > 0 then
		this.timed_attacks.list[1].disabled = nil
		this.timed_attacks.list[1].burst = s.copies[s.level]
	end

	s = this.hero.skills.lethalstrike

	if initial and s.level > 0 then
		local la = this.timed_attacks.list[2]

		la.disabled = nil
		la.instakill_chance = s.instakill_chance[s.level]
		la.damage_min = s.level * la.damage_min
		la.damage_max = s.level * la.damage_max
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_mirage.insert(this, store, script)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

function scripts.hero_mirage.update(this, store, script)
	local h = this.health
	local he = this.hero
	local a_sd = this.timed_attacks.list[1]
	local s_sd = this.hero.skills.shadowdance
	local a_l = this.timed_attacks.list[2]
	local s_l = this.hero.skills.lethalstrike
	local brk, sta

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if this.dodge and this.dodge.chance > 0 and this.dodge.active then
				this.dodge.active = false

				S:queue("HeroMirageShadowDodge")
				U.animation_start(this, "disappear", nil, store.tick_ts, false)
				U.y_wait(store, fts(3))

				local smoke = E:create_entity("fx_mirage_smoke")

				smoke.pos = V.vclone(this.pos)
				smoke.render.sprites[1].ts = store.tick_ts

				queue_insert(store, smoke)
				U.y_animation_wait(this)

				local enemy = store.entities[this.soldier.target_id]

				if enemy and not enemy.health.dead then
					local illu = E:create_entity("soldier_mirage_illusion")

					illu.pos = V.vclone(this.pos)

					queue_insert(store, illu)
					U.replace_blocker(store, this, illu)

					local enp = enemy.nav_path
					local new_ni = enp.ni
					local node_limit = 20
					local node_jump = 12
					local range

					if node_jump < P:nodes_to_goal(enp) - node_limit then
						range = {
							new_ni + node_jump,
							new_ni,
							-1
						}
					elseif node_jump < P:nodes_from_start(enp) - node_limit then
						range = {
							new_ni - node_jump,
							new_ni,
							1
						}
					else
						goto label_272_0
					end

					for i = range[1], range[2], range[3] do
						local n_pos = P:node_pos(enp.pi, enp.spi, i)

						if P:is_node_valid(enp.pi, i) and GR:cell_is_only(n_pos.x, n_pos.y, TERRAIN_LAND) then
							new_ni = i

							break
						end
					end

					::label_272_0::

					local new_pos = P:node_pos(enp.pi, enp.spi, new_ni)

					this.pos.x, this.pos.y = new_pos.x, new_pos.y
					this.nav_rally.center = V.vclone(this.pos)
					this.nav_rally.pos = V.vclone(this.pos)
				end

				U.y_animation_play(this, "appear", nil, store.tick_ts)

				goto label_272_1
			end

			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_272_1
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if not a_l.disabled and store.tick_ts - a_l.ts > a_l.cooldown then
				local target

				if U.blocker_rank(store, this) ~= nil and U.is_blocked_valid(store, this) and band(store.entities[this.soldier.target_id].vis.bans, a_l.vis_flags) == 0 then
					target = store.entities[this.soldier.target_id]
				else
					target = U.find_random_enemy(store.entities, this.pos, 0, a_l.range, a_l.vis_flags, a_l.vis_bans)
				end

				if not target or target.health.dead then
					SU.delay_attack(store, a_l, 0.13333333333333333)
				else
					SU.hero_gain_xp_from_skill(this, s_l)
					SU.stun_inc(target)
					S:queue(this.sound_events.lethal_vanish)

					this.health.immune_to = F_ALL

					U.y_animation_play(this, "lethal_out", nil, store.tick_ts)

					local initial_pos = V.vclone(this.pos)
					local lpos, lflip = U.melee_slot_position(this, target, 1, true)

					this.pos.x, this.pos.y = lpos.x, lpos.y

					S:queue(a_l.sound)
					U.animation_start(this, "lethal_attack", not lflip, store.tick_ts)
					U.y_wait(store, a_l.hit_time)

					if target and not target.health.dead then
						local d = E:create_entity("damage")

						d.source_id = this.id
						d.target_id = target.id

						if band(target.vis.flags, F_BOSS) == 0 and math.random() < a_l.instakill_chance then
							d.pop = {
								"pop_instakill"
							}
							d.damage_type = DAMAGE_INSTAKILL
						else
							d.damage_type = a_l.damage_type
							d.value = a_l.damage_max
						end

						queue_damage(store, d)

						if d.damage_type ~= DAMAGE_INSTAKILL and a_l.hit_fx and target.unit.blood_color then
							local fx = E:create_entity(a_l.hit_fx)

							fx.pos = V.vclone(target.pos)

							if target.unit.hit_offset then
								fx.pos.x = fx.pos.x + target.unit.hit_offset.x
								fx.pos.y = fx.pos.y + target.unit.hit_offset.y
							end

							fx.render.sprites[1].ts = store.tick_ts
							fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

							if fx.use_blood_color then
								fx.render.sprites[1].name = target.unit.blood_color
							end

							queue_insert(store, fx)
						end
					end

					U.y_animation_wait(this)
					SU.stun_dec(target)
					S:queue(this.sound_events.lethal_vanish)

					this.pos.x, this.pos.y = initial_pos.x, initial_pos.y

					U.y_animation_play(this, "lethal_in", lflip, store.tick_ts)

					this.health.immune_to = 0
					a_l.ts = store.tick_ts

					goto label_272_1
				end
			end

			if not a_sd.disabled and store.tick_ts - a_sd.ts > a_sd.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, a_sd.min_range, a_sd.max_range, a_sd.vis_flags, a_sd.vis_bans, function(v)
					return not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_WATER)
				end)

				if targets then
					a_sd.ts = store.tick_ts

					S:queue(a_sd.sound)
					U.animation_start(this, a_sd.animation, nil, store.tick_ts)

					while store.tick_ts - a_sd.ts < a_sd.shoot_time do
						if this.nav_rally.new then
							goto label_272_1
						end

						if this.health.dead then
							goto label_272_1
						end

						if this.unit.is_stunned then
							goto label_272_1
						end

						coroutine.yield()
					end

					SU.hero_gain_xp_from_skill(this, s_sd)

					local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a_sd.max_range * 1.5, a_sd.vis_flags, a_sd.vis_bans, function(v)
						return not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_WATER)
					end)

					if targets then
						for i = 1, a_sd.burst do
							local target = table.random(targets)
							local b = E:create_entity(a_sd.bullet)

							b.pos.x, b.pos.y = this.pos.x, this.pos.y
							b.bullet.target_id = target.id
							b.bullet.source_id = this.id
							b.bullet.level = s_sd.level

							queue_insert(store, b)
						end
					end

					while not U.animation_finished(this) do
						if this.nav_rally.new then
							goto label_272_1
						end

						if this.health.dead then
							goto label_272_1
						end

						if this.unit.is_stunned then
							goto label_272_1
						end

						coroutine.yield()
					end

					a_sd.ts = store.tick_ts

					goto label_272_1
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

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

		::label_272_1::

		coroutine.yield()
	end
end

scripts.soldier_mirage_illusion = {}

function scripts.soldier_mirage_illusion.insert(this, store, script)
	this.lifespan.ts = store.tick_ts
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.soldier_mirage_illusion.update(this, store, script)
	local attack = this.melee.attacks[1]

	U.y_wait(store, attack.cooldown - fts(23))

	while true do
		if this.health.dead or store.tick_ts - this.lifespan.ts > this.lifespan.duration then
			this.health.hp = 0

			U.unblock_target(store, this)
			U.animation_start(this, "idle", nil, store.tick_ts)
			S:queue(this.sound_events.death)

			local smoke = E:create_entity("fx_mirage_smoke")

			smoke.pos = V.vclone(this.pos)
			smoke.render.sprites[1].ts = store.tick_ts

			queue_insert(store, smoke)
			U.y_wait(store, fts(4))
			queue_remove(store, this)

			return
		end

		SU.y_soldier_melee_block_and_attacks(store, this)
		coroutine.yield()
	end
end

scripts.mirage_shadow = {}

function scripts.mirage_shadow.insert(this, store, script)
	local b = this.bullet
	local target = store.entities[b.target_id]

	if not target then
		return false
	end

	b.to = V.vclone(target.pos)

	return true
end

function scripts.mirage_shadow.update(this, store, script)
	local b = this.bullet
	local target = store.entities[b.target_id]
	local start_ts = store.tick_ts
	local mspeed = U.frandom(b.min_speed, b.max_speed)

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		target = store.entities[b.target_id]

		if not target or target.health.dead then
			U.animation_start(this, "death", nil, store.tick_ts)
			S:queue(this.sound_events.death)

			local smoke = E:create_entity("fx_mirage_smoke")

			smoke.pos = V.vclone(this.pos)
			smoke.render.sprites[1].ts = store.tick_ts

			queue_insert(store, smoke)
			U.y_animation_wait(this)
			queue_remove(store, this)

			return
		end

		b.to.x, b.to.y = target.pos.x, target.pos.y
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		if V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < mspeed * fts(8) then
			if this.render.sprites[1].name ~= "attack" then
				local an, af = U.animation_name_facing_point(this, "attack", b.to)

				U.animation_start(this, an, af, store.tick_ts, false)
			end
		else
			local an, af = U.animation_name_facing_point(this, "running", b.to)

			U.animation_start(this, an, af, store.tick_ts, true)
		end

		coroutine.yield()
	end

	S:queue(this.sound_events.hit)

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)
	end

	if b.hit_fx and target.unit.blood_color then
		local fx = E:create_entity(b.hit_fx)

		fx.pos = V.vclone(target.pos)

		if target.unit.hit_offset then
			fx.pos.x, fx.pos.y = fx.pos.x + target.unit.hit_offset.x, fx.pos.y + target.unit.hit_offset.y
		end

		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

		if fx.use_blood_color then
			fx.render.sprites[1].name = target.unit.blood_color
		end

		queue_insert(store, fx)
	end

	queue_remove(store, this)
end

scripts.hero_giant = {}

function scripts.hero_giant.get_info(this)
	local a = this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_giant.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local s

	s = this.hero.skills.boulderthrow

	if initial and s.level > 0 then
		this.ranged.attacks[1].disabled = nil

		local b = E:get_template(this.ranged.attacks[1].bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end

	s = this.hero.skills.stomp

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage = s.damage[s.level]
		a.loops = s.loops[s.level]

		local stun = E:get_template("mod_giant_stun")

		stun.modifier.duration = s.stun_duration[s.level]
	end

	s = this.hero.skills.bastion

	if initial and s.level > 0 then
		this.auras.list[1].disabled = false

		local a = E:get_template(this.auras.list[1].name)

		a.damage_per_tick = s.damage_per_tick[s.level]
		a.max_damage = s.max_damage[s.level]
	end

	s = this.hero.skills.massivedamage

	if s.level > 0 then
		this.melee.attacks[2].disabled = nil

		local mod = E:get_template(this.melee.attacks[2].mod)

		mod.instakill_chance = s.chance[s.level]
		mod.instakill_min_hp = this.health.hp_max / s.health_factor
		mod.damage_min = ls.melee_damage_min[hl] + s.extra_damage[s.level]
		mod.damage_max = ls.melee_damage_max[hl] + s.extra_damage[s.level]
	end

	s = this.hero.skills.hardrock

	if s.level > 0 then
		this.health.hp_max = this.health.hp_max + s.extra_hp[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_giant.insert(this, store, script)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	if not this.auras.list[1].disabled then
		local e = E:create_entity(this.auras.list[1].name)

		e.aura.source_id = this.id

		queue_insert(store, e)
	end

	return true
end

function scripts.hero_giant.update(this, store, script)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	local function do_stomp(attack, targets)
		if not targets then
			return
		end

		for _, t in pairs(targets) do
			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = t.id
			d.value = attack.damage
			d.damage_type = attack.damage_type

			queue_damage(store, d)

			local m = E:create_entity("mod_giant_slow")

			m.modifier.source_id = this
			m.modifier.target_id = t.id

			queue_insert(store, m)
		end

		local stun_targets = table.filter(targets, function(k, v)
			return v.vis and band(v.vis.bans, attack.stun_vis_flags) == 0 and band(v.vis.flags, attack.stun_vis_bans) == 0
		end)

		if #stun_targets > 0 and math.random() < attack.stun_chance then
			local t = table.random(stun_targets)
			local m = E:create_entity("mod_giant_stun")

			m.modifier.source_id = this
			m.modifier.target_id = t.id

			queue_insert(store, m)
		end
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			if band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE_BOSS, DAMAGE_HOST, DAMAGE_EAT)) == 0 then
				this.unit.hide_after_death = true

				local remains = E:create_entity("giant_death_remains")

				remains.pos.x, remains.pos.y = this.pos.x, this.pos.y
				remains.render.sprites[1].ts = store.tick_ts
				remains.render.sprites[2].ts = store.tick_ts

				queue_insert(store, remains)
			end

			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_282_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.stomp

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets then
					-- block empty
				else
					local targets_hp = table.map(targets, function(k, v)
						return v.health and v.health.hp or 0
					end)
					local max_target_hp_idx, max_target_hp = table.maxv(targets_hp)

					if #targets < a.trigger_min_enemies and max_target_hp < a.trigger_min_hp then
						SU.delay_attack(store, a, 0.13333333333333333)
					else
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						for i = 1, a.loops do
							if this.health.dead or this.nav_rally.new then
								break
							end

							local flip_sign = this.render.sprites[1].flip_x and -1 or 1
							local start_ts = store.tick_ts
							local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius, a.damage_flags, a.damage_bans)

							S:queue("HeroGiantStomp")
							U.animation_start(this, "stomp", nil, store.tick_ts, false)

							while store.tick_ts - start_ts < a.hit_times[1] do
								coroutine.yield()
							end

							do_stomp(a, targets)

							local fx = E:create_entity("giant_stomp_decal")

							fx.pos = V.v(this.pos.x - 20 * flip_sign, this.pos.y - 2)
							fx.render.sprites[1].ts = store.tick_ts

							queue_insert(store, fx)

							while store.tick_ts - start_ts < a.hit_times[2] do
								coroutine.yield()
							end

							do_stomp(a, targets)

							local fx = E:create_entity("giant_stomp_decal")

							fx.pos = V.v(this.pos.x + 19 * flip_sign, this.pos.y + 5)
							fx.render.sprites[1].ts = store.tick_ts

							queue_insert(store, fx)
							U.y_animation_wait(this)
						end

						goto label_282_0
					end
				end
			end

			brk, sta = SU.y_soldier_ranged_attacks(store, this)

			if brk then
				-- block empty
			else
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
		end

		::label_282_0::

		coroutine.yield()
	end
end

scripts.aura_giant_bastion = {}

function scripts.aura_giant_bastion.update(this, store, script)
	local hero = store.entities[this.aura.source_id]

	this.pos = hero.pos

	local enabled = false
	local last_level = hero.hero.level
	local added_damage = 0
	local attack = hero.melee.attacks[1]
	local last_tick = store.tick_ts
	local last_pos = V.vclone(this.pos)
	local s = this.render.sprites[1]

	local function add_damage(value)
		added_damage = added_damage + value
		attack.damage_min = attack.damage_min + value
		attack.damage_max = attack.damage_max + value
	end

	while true do
		local rally_pos = hero.nav_rally.pos

		if enabled then
			if hero.health.dead or V.dist(rally_pos.x, rally_pos.y, hero.pos.x, hero.pos.y) > this.max_distance then
				enabled = false

				add_damage(-added_damage)

				added_damage = 0
			elseif added_damage < this.max_damage and store.tick_ts - last_tick > this.tick_time then
				add_damage(this.damage_per_tick)

				last_tick = store.tick_ts
			end
		elseif not hero.health.dead and V.dist(rally_pos.x, rally_pos.y, hero.pos.x, hero.pos.y) < this.max_distance then
			enabled = true
			added_damage = 0
			last_tick = store.tick_ts
		end

		if last_level ~= hero.hero.level and added_damage > 0 then
			local prev = added_damage

			added_damage = 0

			add_damage(prev)

			last_level = hero.hero.level
		end

		s.hidden = added_damage == 0

		local new_scale

		new_scale = added_damage == this.max_damage and 1 or added_damage > 0 and 0.5 or 0

		if new_scale ~= s.scale.x then
			s.ts = store.tick_ts
			s.scale.x, s.scale.y = new_scale, new_scale
		end

		coroutine.yield()
	end
end

scripts.mod_giant_massivedamage = {}

function scripts.mod_giant_massivedamage.insert(this, store, script)
	local m = this.modifier
	local source = store.entities[m.source_id]
	local target = store.entities[m.target_id]

	if not source or not target or target.health.dead then
		return false
	end

	this.pos = V.vclone(target.pos)

	local s = this.render.sprites[1]

	s.name = s.name .. "_" .. s.size_names[target.unit.size]
	s.anchor.y = s.size_anchors_y[target.unit.size]
	s.flip_x = source.render.sprites[1].flip_x
	s.ts = store.tick_ts

	local d = E:create_entity("damage")

	d.source_id = this.id
	d.target_id = target.id
	d.damage_type = DAMAGE_TRUE
	d.value = math.ceil(source.unit.damage_factor * math.random(this.damage_min, this.damage_max))

	local protection = 0
	local predicted_damage = math.ceil(d.value * target.health.damage_factor * km.clamp(0, 1, 1 - protection))

	if band(target.vis.flags, F_BOSS) == 0 and (target.health.hp - predicted_damage <= 0 or target.health.hp - predicted_damage < this.instakill_min_hp and math.random() < this.instakill_chance) then
		d.damage_type = DAMAGE_INSTAKILL
	end

	queue_damage(store, d)

	return true
end

scripts.giant_boulder = {}

function scripts.giant_boulder.insert(this, store, script)
	if not scripts.bomb.insert(this, store, script) then
		return false
	end

	local b = this.bullet
	local target = store.entities[b.target_id]

	if not target then
		return false
	end

	if target.unit and target.unit.hit_offset then
		b.hit_fx_sort_y_offset = -1 - target.unit.hit_offset.y

		if target.unit.hit_offset.y > 23 then
			b.hit_decal = nil
		end
	end

	return true
end

scripts.hero_pirate = {}

function scripts.hero_pirate.get_info(this)
	local ma = this.melee.attacks[1]
	local ra = this.ranged.attacks[1]
	local min = ma.damage_min
	local max = ma.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_pirate.level_up(this, store, initial)
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

	s = this.hero.skills.swordsmanship

	if s.level > 0 then
		for i = 1, #this.melee.attacks do
			local ma = this.melee.attacks[i]

			ma.damage_min = ma.damage_min + s.extra_damage[s.level]
			ma.damage_max = ma.damage_max + s.extra_damage[s.level]
		end
	end

	s = this.hero.skills.looting

	if initial and s.level > 0 then
		local m = E:get_template("mod_pirate_loot")

		m.percent = s.percent[s.level]
	end

	s = this.hero.skills.kraken

	if initial and s.level > 0 then
		this.timed_attacks.list[1].disabled = false

		local ka = E:get_template("kraken_aura")

		ka.max_active_targets = s.max_enemies[s.level]

		local m = E:get_template("mod_slow_kraken")

		m.slow.factor = s.slow_factor[s.level]
	end

	s = this.hero.skills.scattershot

	if initial and s.level > 0 then
		this.timed_attacks.list[2].disabled = false

		local barrel = E:get_template("pirate_exploding_barrel")

		barrel.fragments = s.fragments[s.level]

		local bf = E:get_template("barrel_fragment")

		bf.bullet.damage_min = s.fragment_damage[s.level]
		bf.bullet.damage_max = bf.bullet.damage_min
	end

	s = this.hero.skills.toughness

	if s.level > 0 then
		this.health.hp_max = this.health.hp_max + s.hp_max[s.level]
		this.regen.health = this.regen.health + s.regen[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_pirate.insert(this, store, script)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	if this.hero.skills.looting.level > 0 then
		local a = E:create_entity("pirate_loot_aura")

		a.aura.source_id = this.id

		queue_insert(store, a)
	end

	return true
end

function scripts.hero_pirate.update(this, store, script)
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
					goto label_293_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = he.skills.kraken

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				targets = targets and table.filter(targets, function(_, e)
					local neighbors = U.find_enemies_in_range(store.entities, e.pos, 0, a.nearby_range, a.vis_flags, a.vis_bans, function(oe)
						return e.id ~= oe.id
					end)

					return neighbors and #neighbors >= a.min_enemies_nearby
				end)

				if targets and targets[1] then
					local target = targets[1]
					local start_ts = store.tick_ts
					local flip = target.pos.x < this.pos.x

					U.animation_start(this, a.animation, flip, store.tick_ts)
					S:queue(a.sound)

					while store.tick_ts - start_ts < a.shoot_time do
						if this.nav_rally.new then
							goto label_293_0
						end

						if this.health.dead then
							goto label_293_0
						end

						if this.unit.is_stunned then
							goto label_293_0
						end

						coroutine.yield()
					end

					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local k_aura = E:create_entity(a.bullet)

					k_aura.aura.source_id = this.id
					k_aura.aura.ts = store.tick_ts

					local ni = target.nav_path.ni + P:predict_enemy_node_advance(target, fts(8))

					k_aura.pos = P:node_pos(target.nav_path.pi, 1, ni)

					queue_insert(store, k_aura)

					local ks_aura = E:create_entity("kraken_aura_slow")

					ks_aura.aura.source_id = this.id
					ks_aura.aura.ts = store.tick_ts
					ks_aura.pos = k_aura.pos

					queue_insert(store, ks_aura)

					while not U.animation_finished(this) do
						if this.nav_rally.new then
							goto label_293_0
						end

						if this.health.dead then
							goto label_293_0
						end

						if this.unit.is_stunned then
							goto label_293_0
						end

						coroutine.yield()
					end

					a.ts = store.tick_ts
				end
			end

			a = this.timed_attacks.list[2]
			skill = he.skills.scattershot

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if targets then
					a.ts = store.tick_ts

					local target = targets[1]
					local pi = target.nav_path.pi
					local spi = target.nav_path.spi
					local ni = target.nav_path.ni + P:predict_enemy_node_advance(target, a.shoot_time + fts(20) + fts(18))
					local npos = P:node_pos(pi, spi, ni)

					npos.y = npos.y + 80

					local an, af, ai = U.animation_name_facing_point(this, a.animation, npos)

					U.animation_start(this, an, af, store.tick_ts, false)

					while store.tick_ts - a.ts < a.shoot_time do
						if this.health.dead then
							goto label_293_0
						end

						coroutine.yield()
					end

					SU.hero_gain_xp_from_skill(this, skill)

					local bullet = E:create_entity(a.bullet)

					bullet.pos = V.vclone(this.pos)

					if a.bullet_start_offset then
						local offset = a.bullet_start_offset[ai]

						bullet.pos.x, bullet.pos.y = bullet.pos.x + (af and -1 or 1) * offset.x, bullet.pos.y + offset.y
					end

					bullet.bullet.from = V.vclone(bullet.pos)
					bullet.bullet.to = npos

					queue_insert(store, bullet)

					while not U.animation_finished(this) do
						if this.nav_rally.new then
							goto label_293_0
						end

						if this.health.dead then
							goto label_293_0
						end

						if this.unit.is_stunned then
							goto label_293_0
						end

						coroutine.yield()
					end
				end
			end

			brk, sta = SU.y_soldier_ranged_attacks(store, this)

			if brk then
				-- block empty
			else
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
		end

		::label_293_0::

		coroutine.yield()
	end
end

scripts.kraken_aura = {}

function scripts.kraken_aura.insert(this, store, script)
	scripts.aura_apply_mod.insert(this, store, script)

	local e = E:create_entity("decal_kraken")

	e.pos.x, e.pos.y = this.pos.x, this.pos.y

	queue_insert(store, e)

	return true
end

scripts.decal_kraken = {}

function scripts.decal_kraken.update(this, store, script)
	local start_ts = store.tick_ts

	U.y_animation_play(this, "start", nil, store.tick_ts)
	U.animation_start(this, "loop", nil, store.tick_ts, true)

	while store.tick_ts - start_ts < this.duration do
		coroutine.yield()
	end

	U.y_animation_play(this, "end", nil, store.tick_ts, 1)
	queue_remove(store, this)
end

scripts.pirate_exploding_barrel = {}

function scripts.pirate_exploding_barrel.update(this, store, script)
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

		coroutine.yield()
	end

	if b.hit_fx then
		S:queue(this.sound_events.hit)

		local sfx = E:create_entity(b.hit_fx)

		sfx.pos = V.vclone(b.to)
		sfx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, sfx)
	end

	local center = V.v(this.pos.x, this.pos.y - 80)

	center.x, center.y = center.x + math.random(-4, 4), center.y + math.random(-4, 4)

	local angle = 0
	local min_angle = 2 * math.pi / this.fragments

	for i = 1, this.fragments do
		angle = angle + min_angle + U.frandom(0, math.pi / 6)

		local bf = E:create_entity("barrel_fragment")

		bf.bullet.from = V.vclone(this.pos)
		bf.bullet.to = U.point_on_ellipse(center, (50 * math.random() + 45) / 2, angle)
		bf.bullet.flight_time = U.frandom(fts(16), fts(20))
		bf.render.sprites[1].r = 100 * math.random() * (math.pi / 180)

		if i > 1 then
			bf.sound_events.hit = nil
		end

		queue_insert(store, bf)
	end

	queue_remove(store, this)
end

scripts.hero_wizard = {}

function scripts.hero_wizard.get_info(this)
	local m = E:get_template("mod_ray_wizard")
	local min, max = m.damage_min, m.damage_max

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

function scripts.hero_wizard.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local m = E:get_template("mod_ray_wizard")

	m.damage_max = ls.ranged_damage_max[hl]
	m.damage_min = ls.ranged_damage_min[hl]

	local s

	s = this.hero.skills.magicmissile

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.loops = s.count[s.level]

		local b = E:get_template("missile_wizard")

		b.bullet.damage_max = s.damage[s.level]
		b.bullet.damage_min = s.damage[s.level]
	end

	s = this.hero.skills.chainspell

	if initial and s.level > 0 then
		local a = this.ranged.attacks[2]

		a.disabled = nil

		local b = E:get_template("ray_wizard_chain")

		b.bounces = s.bounces[s.level]
	end

	s = this.hero.skills.disintegrate

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.total_damage = s.total_damage[s.level]
		a.count = s.count[s.level]

		if store then
			a.ts = store.tick_ts
		end
	end

	s = this.hero.skills.arcanereach

	if initial and s.level > 0 then
		local factor = 1 + s.extra_range_factor[s.level]

		this.ranged.attacks[1].max_range = this.ranged.attacks[1].max_range * factor
		this.ranged.attacks[2].max_range = this.ranged.attacks[2].max_range * factor
	end

	s = this.hero.skills.arcanefocus

	if s.level > 0 then
		local extra = s.extra_damage[s.level]
		local m = E:get_template("mod_ray_wizard")

		m.damage_max = m.damage_max + extra
		m.damage_min = m.damage_min + extra
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_wizard.insert(this, store, script)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

function scripts.hero_wizard.update(this, store, script)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		SU.alliance_merciless_upgrade(store, this)
		SU.alliance_corageous_upgrade(store, this)

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_302_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.disintegrate

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local triggers = U.find_enemies_in_range(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(v)
					return v.health.hp <= a.total_damage
				end)

				if not triggers then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius, a.vis_flags, a.vis_bans, function(v)
						return v.health.hp <= a.total_damage
					end)

					if not targets then
						SU.delay_attack(store, a, 0.13333333333333333)

						goto label_302_0
					end

					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
					S:queue(a.sound)
					U.animation_start(this, a.animation, nil, store.tick_ts)
					U.y_wait(store, a.hit_time)

					local remaining_damage = a.total_damage
					local count = a.count

					for _, t in pairs(targets) do
						if remaining_damage <= 0 or count == 0 then
							break
						end

						if remaining_damage >= t.health.hp then
							remaining_damage = remaining_damage - t.health.hp
							count = count - 1

							local d = E:create_entity("damage")

							d.damage_type = DAMAGE_EAT
							d.target_id = t.id
							d.source_id = this.id

							queue_damage(store, d)

							local fx = E:create_entity("fx_wizard_disintegrate")

							fx.pos.x, fx.pos.y = t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y
							fx.render.sprites[1].ts = store.tick_ts

							queue_insert(store, fx)
						end
					end

					U.y_animation_wait(this)

					goto label_302_0
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.magicmissile

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range, false, a.vis_flags, a.vis_bans)

				if target then
					local start_ts = store.tick_ts

					if SU.y_soldier_do_loopable_ranged_attack(store, this, target, a) then
						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)
					end

					goto label_302_0
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or U.is_blocked_valid(store, this) then
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

		::label_302_0::

		coroutine.yield()
	end
end

scripts.ray_wizard_chain = {}

function scripts.ray_wizard_chain.insert(this, store, script)
	if not store.entities[this.bullet.target_id] then
		return false
	end

	return true
end

function scripts.ray_wizard_chain.update(this, store, script)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local dest = b.to
	local ho = V.v(0, 0)

	s.scale = V.v(1, 1)

	local function update_sprite()
		if target and target.motion then
			if target.unit and target.unit.hit_offset and not b.ignore_hit_offset then
				ho.x, ho.y = target.unit.hit_offset.x, target.unit.hit_offset.y
			else
				ho.x, ho.y = 0, 0
			end

			local d = math.max(math.abs(target.pos.x + ho.x - dest.x), math.abs(target.pos.y + ho.y - dest.y))

			if d > b.max_track_distance then
				log.paranoid("(%s) ray_wizard_chain target (%s) out of max_track_distance", this.id, target.id)

				target = nil
			else
				dest.x, dest.y = target.pos.x + ho.x, target.pos.y + ho.y
			end
		end

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
	end

	s.ts = store.tick_ts

	update_sprite()

	local fx = SU.insert_sprite(store, b.hit_fx, dest)

	if target then
		fx.pos = target.pos

		if target.unit and target.unit.hit_offset then
			fx.render.sprites[1].offset = V.vclone(target.unit.hit_offset)
		end
	end

	if target then
		local mod = E:create_entity(b.mod)

		mod.modifier.source_id = b.source_id
		mod.modifier.target_id = target.id
		mod.xp_gain_factor = b.xp_gain_factor
		mod.xp_dest_id = b.source_id

		queue_insert(store, mod)
		table.insert(this.seen_targets, target.id)

		if this.bounces > 0 then
			local bounce_target = U.find_nearest_enemy(store.entities, target.pos, 0, this.bounce_range, this.bounce_vis_flags, this.bounce_vis_bans, function(v)
				return not table.contains(this.seen_targets, v.id)
			end)

			if bounce_target then
				log.paranoid("bounce from %s to %s dist:%s", target.id, bounce_target.id, V.dist(dest.x, dest.y, bounce_target.pos.x, bounce_target.pos.y))

				local r = E:create_entity(this.template_name)

				r.pos = V.vclone(dest)
				r.bullet.to = V.vclone(bounce_target.pos)

				if not b.ignore_hit_offset and bounce_target.unit and bounce_target.unit.hit_offset then
					r.bullet.to.x = r.bullet.to.x + bounce_target.unit.hit_offset.x
					r.bullet.to.y = r.bullet.to.y + bounce_target.unit.hit_offset.y
				end

				r.bullet.target_id = bounce_target.id
				r.bullet.source_id = b.source_id
				r.bounces = this.bounces - 1
				r.seen_targets = this.seen_targets

				queue_insert(store, r)
			end
		end
	end

	while not U.animation_finished(this) do
		update_sprite()
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.mod_ray_wizard = {}

function scripts.mod_ray_wizard.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	this.modifier.ts = store.tick_ts

	return true
end

function scripts.mod_ray_wizard.update(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]
	local total_damage = math.random(this.damage_min, this.damage_max)
	local final_damage = km.clamp(0, total_damage, total_damage - target.health.hp)
	local steps = math.floor(m.duration / this.damage_every)
	local step_damage = math.floor((total_damage - final_damage) / steps)
	local step = 0
	local last_ts = m.ts
	local tick_steps, cycle_damage, d

	if not target then
		queue_remove(store, this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead then
			queue_remove(store, this)

			return
		end

		tick_steps = math.floor((store.tick_ts - last_ts) / this.damage_every)

		if tick_steps < 1 then
			-- block empty
		else
			step = step + tick_steps
			last_ts = last_ts + tick_steps * this.damage_every
			cycle_damage = step_damage * tick_steps

			if steps <= step then
				cycle_damage = cycle_damage + final_damage
			end

			d = E:create_entity("damage")
			d.source_id = this.id
			d.target_id = target.id
			d.value = cycle_damage
			d.damage_type = this.damage_type
			d.pop = this.pop
			d.pop_chance = this.pop_chance
			d.pop_conds = this.pop_conds
			d.xp_gain_factor = this.xp_gain_factor
			d.xp_dest_id = this.xp_dest_id

			queue_damage(store, d)

			if steps <= step then
				queue_remove(store, this)

				return
			end
		end

		coroutine.yield()
	end
end

scripts.missile_wizard = {}

function scripts.missile_wizard.insert(this, store)
	local b = this.bullet

	if not store.entities[b.target_id] then
		return false
	end

	b.to = V.v(this.pos.x + math.random(10, 90) * (math.random() < 0.5 and -1 or 1), this.pos.y + math.random(100, 300))

	local ps = E:create_entity("ps_missile_wizard")

	ps.particle_system.track_id = this.id

	queue_insert(store, ps)

	for i = 1, 3 do
		local pss = E:create_entity("ps_missile_wizard_sparks")

		pss.particle_system.name = "missile_wizard_sparks" .. i
		pss.particle_system.track_id = this.id
		pss.particle_system.emit_ts = store.tick_ts + i / (3 * pss.particle_system.emission_rate)

		queue_insert(store, pss)
	end

	return true
end

scripts.hero_beastmaster = {}

function scripts.hero_beastmaster.get_info(this)
	local a = this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_beastmaster.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local s

	s = this.hero.skills.boarmaster

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.max = s.boars[s.level]

		local e = E:get_template(a.entity)

		e.health.hp_max = s.hp_max[s.level]
	end

	s = this.hero.skills.stampede

	if initial and s.level > 0 then
		this.timed_attacks.list[1].disabled = nil
		this.timed_attacks.list[1].count = s.rhinos[s.level]

		local r = E:get_template(this.timed_attacks.list[1].entity)

		r.duration = s.duration[s.level]
		r.attack.mod_chance = s.stun_chance[s.level]

		local m = E:get_template(r.attack.mod)

		m.modifier.duration = s.stun_duration[s.level]
	end

	s = this.hero.skills.falconer

	if initial and s.level > 0 then
		this.falcons_max = 1

		local f = E:get_template(this.falcons_name)

		f.fake_hp = s.fake_hp[s.level]
		f.custom_attack.max_range = s.max_range[s.level]
		f.custom_attack.damage_min = s.damage_min[s.level]
		f.custom_attack.damage_max = s.damage_max[s.level]
	end

	s = this.hero.skills.deeplashes

	if initial and s.level > 0 then
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.damage_min = s.damage[s.level]
		a.damage_max = s.damage[s.level]

		local m = E:get_template(a.mod)

		m.dps.damage_min = s.blood_damage[s.level] / m.modifier.duration
		m.dps.damage_max = s.blood_damage[s.level] / m.modifier.duration
	end

	s = this.hero.skills.regeneration

	if initial and s.level > 0 then
		local a = E:get_template("aura_beastmaster_regeneration")

		a.hps.heal_min = s.hp[s.level]
		a.hps.heal_max = s.hp[s.level]
		a.hps.heal_every = s.cooldown[s.level]
	end

	this.health.hp = this.health.hp_max

	if store then
		this.timed_attacks.list[2].ts = -this.timed_attacks.list[2].cooldown
		this.timed_attacks.list[1].ts = store.tick_ts
		this.melee.attacks[2].ts = store.tick_ts
	end
end

function scripts.hero_beastmaster.insert(this, store, script)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.boars = {}
	this.falcons = {}

	if this.hero.skills.regeneration.level > 0 then
		local e = E:create_entity("aura_beastmaster_regeneration")

		e.aura.source_id = this.id
		e.aura.ts = store.tick_ts

		queue_insert(store, e)
	end

	return true
end

function scripts.hero_beastmaster.update(this, store, script)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	local function distribute_boars(x, y, qty)
		if qty < 1 then
			return nil
		end

		local nodes = P:nearest_nodes(x, y, nil, nil, true)

		if #nodes < 1 then
			log.debug("cannot insert boars, no valid nodes nearby %s,%s", x, y)

			return nil
		end

		local opi, ospi, oni = unpack(nodes[1])
		local offset_options = {
			-4,
			-6,
			-8,
			4,
			6,
			8
		}
		local positions = {}

		for i, offset in ipairs(offset_options) do
			if qty <= #positions then
				break
			end

			local ni = oni + offset
			local spi = km.zmod(ospi + i, 3)
			local npos = P:node_pos(opi, spi, ni)

			if P:is_node_valid(opi, ni) and band(GR:cell_type(npos.x, npos.y), bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) == 0 then
				table.insert(positions, npos)
			end
		end

		if qty > #positions then
			log.debug("could not find valid offsets for boars around %s,%s", x, y)

			return nil
		end

		return positions
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			this.falcons = {}

			SU.y_hero_death_and_respawn(store, this)
		end

		if #this.falcons < this.falcons_max then
			local e = E:create_entity(this.falcons_name)

			e.pos = V.v(math.random(10, 30) * km.rand_sign(), math.random(-15, 15))
			e.pos.x, e.pos.y = e.pos.x + this.pos.x, e.pos.y + this.pos.y

			queue_insert(store, e)

			e.owner = this

			table.insert(this.falcons, e)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				local positions = distribute_boars(this.nav_rally.pos.x, this.nav_rally.pos.y, #this.boars)

				if positions then
					for i, boar in ipairs(this.boars) do
						local pos = positions[i]

						boar.nav_rally.center = pos
						boar.nav_rally.pos = pos
						boar.nav_rally.new = true
					end
				end

				if SU.y_hero_new_rally(store, this) then
					goto label_315_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.boarmaster

			if not a.disabled and #this.boars >= a.max then
				a.ts = store.tick_ts
			end

			if not a.disabled and store.tick_ts - a.ts > a.cooldown and #this.boars < a.max then
				local positions = distribute_boars(this.pos.x, this.pos.y, a.max)

				if not positions then
					-- block empty
				else
					local start_ts = store.tick_ts

					S:queue(a.sound)
					U.animation_start(this, a.animation, nil, store.tick_ts, false)

					while store.tick_ts - start_ts < a.spawn_time do
						if this.nav_rally.new then
							goto label_315_0
						end

						if this.health.dead then
							goto label_315_0
						end

						if this.unit.is_stunned then
							goto label_315_0
						end

						coroutine.yield()
					end

					a.ts = store.tick_ts

					while #this.boars < a.max do
						local e = E:create_entity(a.entity)

						e.pos = positions[#this.boars + 1]
						e.nav_rally.center = V.vclone(e.pos)
						e.nav_rally.pos = V.vclone(e.pos)
						e.melee.attacks[1].xp_dest_id = this.id
						e.render.sprites[1].flip_x = math.random() < 0.5

						queue_insert(store, e)

						e.owner = this

						table.insert(this.boars, e)
					end

					while not U.animation_finished(this) do
						if this.nav_rally.new then
							goto label_315_0
						end

						if this.health.dead then
							goto label_315_0
						end

						if this.unit.is_stunned then
							goto label_315_0
						end

						coroutine.yield()
					end

					a.ts = store.tick_ts
				end
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.stampede

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target_info = U.find_enemies_in_paths(store.entities, this.pos, a.range_nodes_min, a.range_nodes_max, 60, a.vis_flags, a.vis_bans, true)

				if not target_info then
					SU.delay_attack(store, a, 1)
				else
					local target = target_info[1].enemy
					local origin = target_info[1].origin
					local start_ts = store.tick_ts

					S:queue(a.sound)

					local flip = target.pos.x < this.pos.x

					U.animation_start(this, a.animation, flip, store.tick_ts)

					while store.tick_ts - start_ts < a.spawn_time do
						if this.nav_rally.new then
							goto label_315_0
						end

						if this.health.dead then
							goto label_315_0
						end

						if this.unit.is_stunned then
							goto label_315_0
						end

						coroutine.yield()
					end

					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local sni = origin[3] + 2

					for i = 1, a.count do
						local spawn = E:create_entity(a.entity)

						spawn.nav_path.pi = origin[1]
						spawn.nav_path.spi = km.zmod(i, 3)
						spawn.nav_path.ni = sni
						spawn.shared_enemies_hit = {}

						queue_insert(store, spawn)

						sni = km.clamp(1, origin[3] + 2, sni - 2)
					end

					while not U.animation_finished(this) do
						if this.nav_rally.new then
							goto label_315_0
						end

						if this.health.dead then
							goto label_315_0
						end

						if this.unit.is_stunned then
							goto label_315_0
						end

						coroutine.yield()
					end

					a.ts = store.tick_ts
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

		::label_315_0::

		coroutine.yield()
	end
end

scripts.aura_beastmaster_regeneration = {}

function scripts.aura_beastmaster_regeneration.update(this, store)
	local hps = this.hps
	local hero = store.entities[this.aura.source_id]

	if not hero then
		return
	end

	while true do
		if not hero.health.dead and store.tick_ts - hps.ts >= hps.heal_every then
			hps.ts = store.tick_ts
			hero.health.hp = km.clamp(0, hero.health.hp_max, hero.health.hp + hps.heal_max)
		end

		coroutine.yield()
	end
end

scripts.beastmaster_boar = {}

function scripts.beastmaster_boar.get_info(this)
	local min, max = this.melee.attacks[1].damage_min, this.melee.attacks[1].damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.owner.timed_attacks.list[2].cooldown
	}
end

function scripts.beastmaster_boar.insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.beastmaster_boar.update(this, store)
	local brk, sta

	U.y_animation_play(this, "spawn", nil, store.tick_ts)

	while true do
		if this.health.dead then
			table.removeobject(this.owner.boars, this)
			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			SU.soldier_courage_upgrade(store, this)

			while this.nav_rally.new do
				this.nav_grid.waypoints = GR:find_waypoints(this.pos, nil, this.nav_rally.pos, this.nav_grid.valid_terrains)

				if SU.y_hero_new_rally(store, this) then
					goto label_320_0
				end
			end

			if this.melee then
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_320_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_320_0::

		coroutine.yield()
	end
end

scripts.beastmaster_rhino = {}

function scripts.beastmaster_rhino.insert(this, store)
	this.pos = P:node_pos(this.nav_path)

	if not this.pos then
		return false
	end

	return true
end

function scripts.beastmaster_rhino.update(this, store)
	local attack = this.attack
	local start_ts = store.tick_ts

	this.tween.ts = store.tick_ts

	while true do
		local next, new = P:next_entity_node(this, store.tick_length)

		if not next then
			log.debug("  X not next for %s", this.id)
			queue_remove(store, this)

			return
		end

		if not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or band(GR:cell_type(next.x, next.y), bor(TERRAIN_CLIFF, TERRAIN_WATER)) ~= 0 then
			local twk = this.tween.props[1].keys

			if store.tick_ts - this.tween.ts < this.duration - 0.25 then
				log.debug("  FF finish early for %s", this.id)

				this.tween.ts = store.tick_ts - this.duration + 0.25
			end
		end

		U.set_destination(this, next)

		local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

		U.animation_start(this, an, af, store.tick_ts)
		U.walk(this, store.tick_length)

		if store.tick_ts - attack.ts >= attack.cooldown then
			attack.ts = store.tick_ts

			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, attack.damage_radius, attack.damage_flags, attack.damage_bans, function(v)
				return not table.contains(this.shared_enemies_hit, v)
			end)

			if not targets then
				-- block empty
			else
				for _, e in pairs(targets) do
					if band(e.vis.bans, F_STUN) == 0 and band(e.vis.flags, F_BOSS) == 0 and math.random() < attack.mod_chance then
						local m = E:create_entity(attack.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = e.id

						queue_insert(store, m)
					end

					local d = E:create_entity("damage")

					d.source_id = this.id
					d.target_id = e.id
					d.value = attack.damage
					d.damage_type = attack.damage_type

					queue_damage(store, d)
					table.insert(this.shared_enemies_hit, e)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.beastmaster_falcon = {}

function scripts.beastmaster_falcon.get_info(this)
	return {
		armor = 0,
		type = STATS_TYPE_SOLDIER,
		hp = this.fake_hp,
		hp_max = this.fake_hp,
		damage_min = this.custom_attack.damage_min,
		damage_max = this.custom_attack.damage_max
	}
end

function scripts.beastmaster_falcon.update(this, store)
	local sf = this.render.sprites[1]
	local h = this.owner
	local fm = this.force_motion
	local ca = this.custom_attack

	sf.offset.y = this.flight_height

	U.y_animation_play(this, "respawn", nil, store.tick_ts)
	U.animation_start(this, "idle", nil, store.tick_ts, true)

	while true do
		if h.health.dead then
			U.y_animation_play(this, "death", nil, store.tick_ts)
			queue_remove(store, this)

			return
		end

		if store.tick_ts - ca.ts > ca.cooldown then
			local target = U.find_nearest_enemy(store.entities, this.pos, ca.min_range, ca.max_range, ca.vis_flags, ca.vis_bans)

			if not target then
				SU.delay_attack(store, ca, 0.13333333333333333)
			else
				S:queue(ca.sound)
				U.animation_start(this, "attack_fly", af, store.tick_ts, false)

				local accel = 180
				local max_speed = 300
				local min_speed = 60
				local mspeed = min_speed
				local dist = V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y)
				local start_dist = dist
				local start_h = sf.offset.y
				local target_h = target.unit.hit_offset.y

				while dist > mspeed * store.tick_length and not target.health.dead do
					local tx, ty = target.pos.x, target.pos.y
					local dx, dy = V.mul(mspeed * store.tick_length, V.normalize(V.sub(tx, ty, this.pos.x, this.pos.y)))

					this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, dx, dy)
					sf.offset.y = km.clamp(0, this.flight_height * 1.5, start_h + (target_h - start_h) * (1 - dist / start_dist))
					sf.flip_x = dx < 0

					coroutine.yield()

					dist = V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y)
					mspeed = km.clamp(min_speed, max_speed, mspeed + accel * store.tick_length)
				end

				if target.health.dead then
					ca.ts = store.tick_ts
				else
					this.pos.x, this.pos.y = target.pos.x, target.pos.y - 1

					local d = E:create_entity("damage")

					d.source_id = this.id
					d.target_id = target.id
					d.value = math.random(ca.damage_min, ca.damage_max)
					d.damage_type = ca.damage_type
					d.xp_gain_factor = ca.xp_gain_factor
					d.xp_dest_id = h.id

					queue_damage(store, d)
					U.y_animation_play(this, "attack_hit", nil, store.tick_ts, 1)

					ca.ts = store.tick_ts
				end
			end
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true)

		local dx, dy = V.sub(h.pos.x, h.pos.y, this.pos.x, this.pos.y)

		if V.len(dx, dy) > 50 then
			fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(1440, V.mul(4, dx, dy)))
		end

		if V.len(fm.a.x, fm.a.y) > 1 then
			fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
			fm.a.x, fm.a.y = 0, 0
		else
			fm.v.x, fm.v.y = 0, 0
			fm.a.x, fm.a.y = 0, 0
		end

		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = V.trim(1800, V.mul(-0.75, fm.v.x, fm.v.y))
		sf.offset.y = km.clamp(0, this.flight_height, sf.offset.y + this.flight_speed * store.tick_length)
		sf.flip_x = fm.v.x < 0

		coroutine.yield()
	end
end

scripts.hero_alien = {}

function scripts.hero_alien.get_info(this)
	local a = this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_alien.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local s

	s = this.hero.skills.energyglaive

	if initial and s.level > 0 then
		local a = this.ranged.attacks[1]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.damage_min = s.damage[s.level]
		b.bullet.damage_max = s.damage[s.level]
		b.bounce_chance = s.bounce_chance[s.level]
	end

	s = this.hero.skills.purificationprotocol

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local e = E:get_template(a.entity)

		e.duration = s.duration[s.level]
	end

	s = this.hero.skills.abduction

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.total_hp = s.total_hp[s.level]
		a.total_targets = s.total_targets[s.level]
	end

	s = this.hero.skills.vibroblades

	if s.level > 0 then
		local a = this.melee.attacks[1]

		a.damage_min = a.damage_min + s.extra_damage[s.level]
		a.damage_max = a.damage_max + s.extra_damage[s.level]
		a.damage_type = s.damage_type
	end

	s = this.hero.skills.finalcountdown

	if initial and s.level > 0 then
		this.selfdestruct.disabled = nil
		this.selfdestruct.damage = s.damage[s.level]
	end

	this.health.hp = this.health.hp_max
	this.ranged.attacks[1].ts = -this.ranged.attacks[1].cooldown
	this.timed_attacks.list[1].ts = -this.timed_attacks.list[1].cooldown
	this.timed_attacks.list[2].ts = -this.timed_attacks.list[2].cooldown
end

function scripts.hero_alien.insert(this, store, script)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

function scripts.hero_alien.update(this, store, script)
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
					goto label_329_1
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.abduction

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local trigger = U.find_random_enemy(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans, function(v)
					return not table.contains(a.invalid_templates, v.template_name) and (skill.level == 3 or v.health.hp <= a.total_hp) and P:is_node_valid(v.nav_path.pi, v.nav_path.ni + 10) and P:is_node_valid(v.nav_path.pi, v.nav_path.ni - 10)
				end)

				if not trigger then
					SU.delay_attack(store, a, 0.13333333333333333)

					goto label_329_0
				end

				S:queue(a.sound)
				U.animation_start(this, a.animation, nil, store.tick_ts)

				if U.y_wait(store, a.spawn_time, function()
					return SU.hero_interrupted(this)
				end) then
					goto label_329_0
				end

				a.ts = store.tick_ts - a.spawn_time

				SU.hero_gain_xp_from_skill(this, skill)

				local abduction_hp, abduction_count = trigger.health.hp, 1
				local targets = U.find_enemies_in_range(store.entities, trigger.pos, 0, a.attack_radius, a.vis_flags, a.vis_bans, function(v)
					local ok = v ~= trigger and abduction_hp + v.health.hp <= a.total_hp and abduction_count < a.total_targets and not table.contains(a.invalid_templates, v.template_name) and P:is_node_valid(v.nav_path.pi, v.nav_path.ni + 10) and P:is_node_valid(v.nav_path.pi, v.nav_path.ni - 10)

					if ok then
						abduction_hp = abduction_hp + v.health.hp
						abduction_count = abduction_count + 1
					end

					return ok
				end)

				if targets then
					table.insert(targets, trigger)
				else
					targets = {
						trigger
					}
				end

				if targets then
					local e = E:create_entity(a.entity)

					e.pos = V.vclone(trigger.pos)
					e.targets = targets

					queue_insert(store, e)

					e.owner = this
				end

				U.y_animation_wait(this)

				goto label_329_1
			end

			::label_329_0::

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.purificationprotocol

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_random_enemy(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

				if not target then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					S:queue(a.sound)
					U.animation_start(this, a.animation, nil, store.tick_ts)

					if U.y_wait(store, a.spawn_time, function()
						return SU.hero_interrupted(this)
					end) then
						-- block empty
					else
						a.ts = store.tick_ts - a.spawn_time

						SU.hero_gain_xp_from_skill(this, skill)

						local e = E:create_entity(a.entity)

						e.pos = V.vclone(target.pos)
						e.target_id = target.id

						queue_insert(store, e)

						e.owner = this

						U.y_animation_wait(this)

						goto label_329_1
					end
				end
			end

			brk, sta = SU.y_soldier_ranged_attacks(store, this)

			if brk then
				-- block empty
			else
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
		end

		::label_329_1::

		coroutine.yield()
	end
end

scripts.alien_glaive = {}

function scripts.alien_glaive.update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local target, ps
	local bounce_count = 0

	U.animation_start(this, "alien_glaive", nil, store.tick_ts, true)

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	::label_334_0::

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead then
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

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

	if bounce_count == 0 or math.random() < this.bounce_chance then
		local target = U.find_random_enemy(store.entities, this.pos, 0, this.bounce_range, b.vis_flags, b.vis_bans, function(v)
			return v ~= target
		end)

		if target then
			S:queue("HeroAlienDiscoBounce")

			bounce_count = bounce_count + 1
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			b.target_id = target.id

			goto label_334_0
		end
	end

	queue_remove(store, this)
end

scripts.alien_purification_drone = {}

function scripts.alien_purification_drone.update(this, store)
	local sid = 2
	local attacking = false
	local target = store.entities[this.target_id]
	local start_ts, switch_ts

	local function y_switch_target(new_target)
		this.target_id = new_target.id
		attacking = false

		S:stop(this.sound_events.loop)

		this.render.sprites[1].hidden = true
		this.render.sprites[3].hidden = true

		U.y_animation_play(this, "disappear_short", nil, store.tick_ts, 1, sid)

		this.pos = new_target.pos

		U.y_animation_play(this, "appear_short", nil, store.tick_ts, 1, sid)

		switch_ts = store.tick_ts
	end

	if target and not target.health.dead then
		this.pos = target.pos
		this.render.sprites[2].flip_x = target.render.sprites[1].flip_x
	end

	U.y_animation_play(this, "appear_long", nil, store.tick_ts, 1, sid)

	start_ts = store.tick_ts
	switch_ts = store.tick_ts

	while true do
		if store.tick_ts - start_ts > this.duration + 1e-06 then
			break
		end

		target = store.entities[this.target_id]

		if target and store.tick_ts - switch_ts > this.switch_targets_every then
			local new_target = U.find_random_enemy(store.entities, this.pos, 0, this.jump_range, this.vis_flags, this.vis_bans, function(v)
				return v.id ~= target.id
			end)

			if new_target then
				target = new_target

				y_switch_target(new_target)
			end
		end

		if not target or store.tick_ts - switch_ts > 0.3 and (target.health.dead or band(this.vis_flags, target.vis.bans) ~= 0 or band(this.vis_bans, target.vis.flags) ~= 0) then
			target = U.find_random_enemy(store.entities, this.pos, 0, this.jump_range, this.vis_flags, this.vis_bans)

			if target then
				y_switch_target(target)
			else
				break
			end
		end

		if not attacking then
			attacking = true

			S:queue(this.sound_events.loop)

			this.pos = target.pos
			this.render.sprites[1].hidden = false
			this.render.sprites[3].hidden = false

			U.animation_start(this, "idle", target.render.sprites[1].flip_x, store.tick_ts, true, sid)
		end

		this.render.sprites[2].flip_x = target.render.sprites[1].flip_x

		if store.tick_ts - this.dps.ts >= this.dps.damage_every then
			this.dps.ts = store.tick_ts

			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = target.id
			d.value = this.dps.damage_max
			d.damage_type = this.dps.damage_type

			queue_damage(store, d)
		end

		coroutine.yield()
	end

	S:stop(this.sound_events.loop)
	S:queue(this.sound_events.finish)

	this.render.sprites[1].hidden = true
	this.render.sprites[3].hidden = true

	U.y_animation_play(this, "disappear_long", nil, store.tick_ts, 1, sid)
	queue_remove(store, this)
end

scripts.alien_abduction_ship = {}

function scripts.alien_abduction_ship.update(this, store)
	local enemy_decals = {}

	for _, e in pairs(this.targets) do
		U.animation_start(e, "idle", nil, store.tick_ts, true)

		local es = E:create_entity("abducted_enemy_decal")

		es.pos.x, es.pos.y = e.pos.x, e.pos.y
		es.render = table.deepclone(e.render)
		es.tween.disabled = true

		queue_insert(store, es)
		table.insert(enemy_decals, es)

		local d = E:create_entity("damage")

		d.damage_type = DAMAGE_EAT
		d.source_id = this.id
		d.target_id = e.id

		queue_damage(store, d)
	end

	this.tween.ts = store.tick_ts

	U.y_wait(store, 1.5)

	this.render.sprites[3].hidden = nil
	this.render.sprites[3].ts = store.tick_ts

	U.y_wait(store, fts(10))

	for i, ed in ipairs(enemy_decals) do
		ed.tween.disabled = nil
		ed.tween.ts = store.tick_ts + (i - 1) * 0.1
	end

	U.y_animation_wait(this, 3)

	this.render.sprites[3].hidden = true
end

scripts.hero_priest = {}

function scripts.hero_priest.get_info(this)
	local m = E:get_template("bolt_priest")
	local min, max = m.bullet.damage_min, m.bullet.damage_max

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

function scripts.hero_priest.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local b = E:get_template("bolt_priest")

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	local s

	s = this.hero.skills.holylight

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.max_per_cast = s.heal_count[s.level]
		a.revive_chance = s.revive_chance[s.level]

		local m = E:get_template(a.mod)

		m.hps.heal_min = s.heal_hp[s.level]
		m.hps.heal_max = s.heal_hp[s.level]
	end

	s = this.hero.skills.consecrate

	if initial and s.level > 0 then
		this.timed_attacks.list[2].disabled = nil

		local m = E:get_template("mod_priest_consecrate")

		m.modifier.duration = s.duration[s.level]
		m.extra_damage = s.extra_damage[s.level]
	end

	s = this.hero.skills.wingsoflight

	if initial and s.level > 0 then
		this.teleport.disabled = nil

		local m = E:get_template("mod_priest_armor")

		m.modifier.duration = s.duration[s.level]
	end

	s = this.hero.skills.blessedarmor

	if s.level > 0 then
		this.health.armor = s.armor[s.level]
	end

	s = this.hero.skills.divinehealth

	if s.level > 0 then
		this.health.hp_max = this.health.hp_max + s.extra_hp[s.level]
		this.regen.health = this.regen.health * s.regen_factor[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_priest.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.hero_priest.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	local function do_armor_buff(pos, out)
		local skill = this.hero.skills.wingsoflight

		if skill.level < 1 then
			return
		end

		local targets = U.find_soldiers_in_range(store.entities, pos, 0, skill.range, 0, 0, function(v)
			return v ~= this
		end)

		if targets then
			for i = 1, math.min(#targets, skill.count[skill.level]) do
				local target = targets[i]
				local m = E:create_entity("mod_priest_armor")

				m.modifier.target_id = target.id
				m.render.sprites[1].ts = store.tick_ts
				m.render.sprites[2].ts = store.tick_ts
				m.render.sprites[2].offset.y = target.health_bar.offset.y + 7

				queue_insert(store, m)
			end
		end

		local fx = E:create_entity("fx_priest_wave_" .. (out and "out" or "in"))

		fx.pos = V.vclone(pos)
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

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
				this.nav_rally.new = false

				U.unblock_target(store, this)
				S:queue(this.sound_events.change_rally_point)

				if SU.hero_will_teleport(this, this.nav_rally.pos) then
					local vis_bans = this.vis.bans

					this.vis.bans = F_ALL
					this.health_bar.hidden = true
					this.health.ignore_damage = true

					local tp = this.teleport

					S:queue(tp.sound)
					do_armor_buff(this.pos, true)
					U.y_animation_play(this, tp.animations[1], nil, store.tick_ts)

					this.pos.x, this.pos.y = this.nav_rally.pos.x, this.nav_rally.pos.y

					U.set_destination(this, this.pos)
					do_armor_buff(this.pos, false)
					U.y_animation_play(this, tp.animations[2], nil, store.tick_ts)

					this.health.ignore_damage = false
					this.health_bar.hidden = nil
					this.vis.bans = vis_bans

					goto label_343_0
				else
					local vis_bans = this.vis.bans

					this.vis.bans = F_ALL

					local out = SU.y_hero_walk_waypoints(store, this)

					U.animation_start(this, "idle", nil, store.tick_ts, true)

					this.vis.bans = vis_bans

					if out == true then
						goto label_343_0
					end
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.holylight

			if store.tick_ts - a.ts > a.cooldown then
				local targets = table.filter(store.entities, function(k, v)
					return v ~= this and v.soldier and v.health and v.health.hp < 0.7 * v.health.hp_max and not v.unit.hide_during_death and not v.unit.hide_after_death and not table.contains(a.excluded_templates, v.template_name) and U.is_inside_ellipse(v.pos, this.pos, a.range)
				end)

				if #targets < 1 then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					local dead_targets = table.filter(targets, function(k, v)
						return v.health and v.health.dead
					end)
					local will_revive = false

					for _, t in pairs(dead_targets) do
						if not t.reinforcement and math.random() < a.revive_chance then
							will_revive = true

							break
						end
					end

					if #dead_targets == #targets and not will_revive then
						SU.delay_attack(store, a, 0.13333333333333333)
					else
						table.sort(targets, function(e1, e2)
							if e1.health.dead and e2.health.dead then
								return false
							elseif e1.health.dead then
								return true
							elseif e2.health.dead then
								return false
							else
								return e1.health.hp_max - e1.health.hp > e2.health.hp_max - e2.health.hp
							end
						end)

						a.ts = store.tick_ts

						if skill.level == 0 then
							SU.hero_gain_xp(this, 7, "holylight level 0")
						else
							SU.hero_gain_xp_from_skill(this, skill)
						end

						S:queue(a.sound)
						U.animation_start(this, a.animation, nil, store.tick_ts)
						U.y_wait(store, a.shoot_time)

						local count = 0

						for _, s in pairs(targets) do
							if s.health.dead and not s.unit.hide_during_death and not s.unit.hide_after_death and (will_revive or math.random() < a.revive_chance) and not s.reinforcement and s.template_name ~= "soldier_djinn" and not s.hero then
								will_revive = false

								log.debug("reviving %s", s.id)

								s.health.dead = false
								s.health.hp = s.health.hp_max
								s.health_bar.hidden = nil
								s.ui.can_select = true

								if s.unit.hide_during_death then
									s.unit.hide_during_death = nil

									U.sprites_show(s)
								end

								s.main_script.runs = 1

								local fx = E:create_entity("fx_priest_revive")

								fx.pos = V.vclone(s.pos)
								fx.render.sprites[1].ts = store.tick_ts

								queue_insert(store, fx)
							elseif not s.health.dead then
								local m = E:create_entity(a.mod)

								m.modifier.target_id = s.id
								m.modifier.source_id = this.id

								queue_insert(store, m)

								count = count + 1
							end

							if count >= a.max_per_cast then
								break
							end
						end

						U.y_animation_wait(this)

						goto label_343_0
					end
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.consecrate

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local towers = table.filter(store.entities, function(_, e)
					return e.tower and e.tower.can_be_mod and not e.tower.blocked and not table.contains(a.excluded_templates, e.template_name) and V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < a.range
				end)

				if #towers < 1 then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					S:queue(a.sound)
					U.animation_start(this, a.animation, nil, store.tick_ts)

					if U.y_wait(store, a.shoot_time, function()
						return SU.hero_interrupted(this)
					end) then
						-- block empty
					else
						a.ts = store.tick_ts - a.shoot_time

						SU.hero_gain_xp_from_skill(this, skill)

						local buffed_tower_ids = {}

						for _, e in pairs(store.entities) do
							if e.modifier and e.template_name == "mod_priest_consecrate" then
								table.insert(buffed_tower_ids, e.modifier.target_id)
							end
						end

						local towers = table.filter(store.entities, function(_, e)
							return e.tower and e.tower.can_be_mod and not e.tower.blocked and not table.contains(a.excluded_templates, e.template_name) and V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < a.range
						end)

						table.sort(towers, function(e1, e2)
							return V.dist(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) < V.dist(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
						end)

						local buffed_tower, unbuffed_tower

						for _, t in pairs(towers) do
							if not buffed_tower and table.contains(buffed_tower_ids, t.id) then
								buffed_tower = t
							else
								unbuffed_tower = unbuffed_tower or t
							end
						end

						local tower = unbuffed_tower or buffed_tower

						if tower then
							local m = E:create_entity("mod_priest_consecrate")

							m.modifier.target_id = tower.id

							queue_insert(store, m)
						end

						U.y_animation_wait(this)

						goto label_343_0
					end
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or U.is_blocked_valid(store, this) then
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

		::label_343_0::

		coroutine.yield()
	end
end

scripts.mod_priest_consecrate = {}

function scripts.mod_priest_consecrate.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	this.pos = V.vclone(target.pos)
	m.ts = store.tick_ts
	this.tween.disabled = false
	this.tween.ts = store.tick_ts
	target.tower.damage_factor = target.tower.damage_factor + this.extra_damage

	while store.tick_ts - m.ts < m.duration do
		coroutine.yield()

		target = store.entities[m.target_id]

		if not target then
			goto label_353_0
		end
	end

	target.tower.damage_factor = target.tower.damage_factor - this.extra_damage

	::label_353_0::

	this.tween.reverse = true
	this.tween.ts = store.tick_ts
	this.tween.remove = true
end

scripts.mod_pirate_loot = {}

function scripts.mod_pirate_loot.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	this.extra_loot = math.ceil(target.enemy.gold * this.percent)
	target.enemy.gold = target.enemy.gold + this.extra_loot

	return true
end

function scripts.mod_pirate_loot.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	while store.tick_ts - m.ts < m.duration and target and not target.health.dead do
		coroutine.yield()
	end

	if target then
		if target.health.dead and target.enemy.gold > 0 then
			local fx = E:create_entity("fx_coin_jump")

			fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
			fx.render.sprites[1].ts = store.tick_ts

			if target.health_bar then
				fx.render.sprites[1].offset.y = target.health_bar.offset.y
			end

			queue_insert(store, fx)
		else
			target.enemy.gold = km.clamp(0, target.enemy.gold, target.enemy.gold - this.extra_loot)
		end
	end

	queue_remove(store, this)
end

scripts.mod_stun_kraken = {}

function scripts.mod_stun_kraken.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	local ka = store.entities[this.modifier.source_id]

	if ka and ka.max_active_targets and ka.active_targets_count >= ka.max_active_targets then
		return false
	end

	if target and target.unit and this.render then
		local s = this.render.sprites[1]

		if s.size_names then
			s.prefix = s.prefix .. "_" .. s.size_names[target.unit.size]
			s.flip_x = target.render.sprites[1].flip_x
		end

		if this.modifier.use_mod_offset and target.unit.mod_offset then
			s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		s.flip_x = false
	end

	this.modifier.duration = ka.aura.duration - (store.tick_ts - ka.aura.ts)
	ka.active_targets_count = ka.active_targets_count + 1
	this.modifier.ts = store.tick_ts

	log.paranoid("aura: %s, mod duration ttl: %f", ka.id, this.modifier.duration)

	local target = store.entities[this.modifier.target_id]

	if target and not target.health.dead then
		SU.stun_inc(target)
	end

	return true
end

function scripts.mod_stun_kraken.remove(this, store)
	local ka = store.entities[this.modifier.source_id]

	if ka and ka.max_active_targets and ka.active_targets_count > 0 then
		ka.active_targets_count = ka.active_targets_count - 1
	end

	local target = store.entities[this.modifier.target_id]

	if target then
		SU.stun_dec(target)
	end

	return true
end

function scripts.mod_stun_kraken.update(this, store)
	local m = this.modifier
	local target = store.entities[this.modifier.target_id]

	if target and not target.health.dead then
		this.pos = target.pos

		local s = this.render.sprites[1]

		s.anchor.y = s.size_anchors_y[target.unit.size]

		local dpsmod = E:create_entity("mod_dps_kraken")

		dpsmod.modifier.target_id = m.target_id

		queue_insert(store, dpsmod)
		U.animation_start(this, "grab", nil, store.tick_ts)

		while store.tick_ts - m.ts < m.duration - fts(10) and target and not target.health.dead do
			coroutine.yield()
		end

		U.y_animation_play(this, "end", nil, store.tick_ts, 1)
		queue_remove(store, dpsmod)
	end

	queue_remove(store, this)
end

scripts.hero_dragon = {}

function scripts.hero_dragon.get_info(this)
	local m = E:get_template("fireball_dragon")
	local min, max = m.bullet.damage_min, m.bullet.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = math.ceil(this.unit.damage_factor * min),
		damage_max = math.ceil(this.unit.damage_factor * max),
		damage_type = m.bullet.damage_type,
		damage_icon = this.info.damage_icon,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_dragon.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	local b = E:get_template("fireball_dragon")

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	local s

	s = this.hero.skills.blazingbreath

	if initial and s.level > 0 then
		local a = this.ranged.attacks[2]

		a.disabled = nil

		local b = E:get_template("breath_dragon")

		b.bullet.damage_min = s.damage[s.level]
		b.bullet.damage_max = s.damage[s.level]
	end

	s = this.hero.skills.feast

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage = s.damage[s.level]
		a.devour_chance = s.devour_chance[s.level]
	end

	s = this.hero.skills.fierymist

	if initial and s.level > 0 then
		local a = this.ranged.attacks[3]

		a.disabled = nil

		local aura = E:get_template("aura_fierymist_dragon")

		aura.aura.duration = s.duration[s.level]

		local m = E:get_template("mod_slow_fierymist")

		m.slow.factor = s.slow_factor[s.level]
	end

	s = this.hero.skills.wildfirebarrage

	if initial and s.level > 0 then
		local a = this.ranged.attacks[4]

		a.disabled = nil

		local b = E:get_template("wildfirebarrage_dragon")

		b.explosions = s.explosions[s.level]
	end

	s = this.hero.skills.reignoffire

	if initial and s.level > 0 then
		local b = E:get_template("fireball_dragon")

		b.bullet.mod = "mod_dragon_reign"

		local b = E:get_template("breath_dragon")

		b.bullet.mod = "mod_dragon_reign"

		local m = E:get_template("mod_dragon_reign")

		m.dps.damage_min = s.dps[s.level] * m.dps.damage_every / m.modifier.duration
		m.dps.damage_max = s.dps[s.level] * m.dps.damage_every / m.modifier.duration

		local b = E:get_template("wildfirebarrage_dragon")

		b.bullet.mod = "mod_dragon_reign"
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_dragon.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

function scripts.hero_dragon.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, force_idle_ts
	local upg_lf = UP:get_upgrade("heroes_lethal_focus")

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	force_idle_ts = true

	while true do
		if h.dead then
			-- this.render.sprites[1].z = Z_OBJECTS
			-- this.render.sprites[1].sort_y_offset = 0
			SU.y_hero_death_and_respawn(store, this)
			-- this.render.sprites[1].z = Z_FLYING_HEROES
			-- this.render.sprites[1].sort_y_offset = -200
			force_idle_ts = true
		end

		SU.alliance_merciless_upgrade(store, this)
		SU.alliance_corageous_upgrade(store, this)

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
		end

		a = this.timed_attacks.list[1]
		skill = this.hero.skills.feast

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local target = U.find_nearest_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if not target then
				SU.delay_attack(store, a, 0.13333333333333333)
			else
				SU.hero_gain_xp_from_skill(this, skill)

				a.ts = store.tick_ts

				SU.stun_inc(target)
				S:queue(a.sound)
				U.animation_start(this, "feast", target.pos.x < this.pos.x, store.tick_ts)

				local steps = math.floor(fts(9) / store.tick_length)
				local step_x, step_y = V.mul(1 / steps, target.pos.x - this.pos.x, target.pos.y - this.pos.y - 1)

				for i = 1, steps do
					this.pos.x, this.pos.y = this.pos.x + step_x, this.pos.y + step_y

					coroutine.yield()
				end

				local fx = E:create_entity("fx_dragon_feast")

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)

				local d = E:create_entity("damage")

				d.damage_type = skill.damage_type
				d.value = a.damage
				d.target_id = target.id
				d.source_id = this.id

				local actual_damage = U.predict_damage(target, d)

				if band(target.vis.bans, F_EAT) == 0 and (math.random() < a.devour_chance or actual_damage >= target.health.hp) then
					if target.unit.can_explode then
						d.damage_type = DAMAGE_EAT

						local fxn, default_fx

						if target.unit.explode_fx and target.unit.explode_fx ~= "fx_unit_explode" then
							fxn = target.unit.explode_fx
							default_fx = false
						else
							fxn = "fx_dragon_feast_explode"
							default_fx = true
						end

						local fx = E:create_entity(fxn)
						local fxs = fx.render.sprites[1]

						fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
						fxs.ts = store.tick_ts

						if default_fx then
							fxs.scale = fxs.size_scales[target.unit.size]
						else
							fxs.name = fxs.size_names[target.unit.size]
						end

						queue_insert(store, fx)
					else
						d.damage_type = DAMAGE_INSTAKILL
					end
				end

				queue_damage(store, d)
				SU.stun_dec(target)
				U.y_animation_wait(this)

				force_idle_ts = true

				goto label_362_1
			end
		end

		for _, i in pairs(this.ranged.order) do
			local a = this.ranged.attacks[i]

			if a.disabled then
				-- block empty
			elseif a.sync_animation and not this.render.sprites[1].sync_flag then
				-- block empty
			elseif store.tick_ts - a.ts < a.cooldown then
				-- block empty
			elseif math.random() > a.chance then
				-- block empty
			else
				local origin = V.v(this.pos.x, this.pos.y + a.bullet_start_offset[1].y)
				local bullet_t = E:get_template(a.bullet)
				local bullet_speed = bullet_t.bullet.min_speed
				local flight_time = bullet_t.bullet.flight_time
				local attack_filter = this.attack_filter
				local target
				if attack_filter then
					target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags,
						a.vis_bans, function(v)
						local v_pos = v.pos

						if not v.nav_path then
							return false
						end

						local n_pos = P:node_pos(v.nav_path)

						if V.dist(n_pos.x, n_pos.y, v_pos.x, v_pos.y) > 5 then
							return false
						end

						if a.nodes_limit and (P:get_start_node(v.nav_path.pi) + a.nodes_limit > v.nav_path.ni or P:get_end_node(v.nav_path.pi) - a.nodes_limit < v.nav_path.ni) then
							return false
						end

						if v.motion and v.motion.speed then
							local node_offset

							if flight_time then
								node_offset = P:predict_enemy_node_advance(v, flight_time + a.shoot_time)
							else
								local dist = V.dist(origin.x, origin.y, v.pos.x, v.pos.y)

								node_offset = P:predict_enemy_node_advance(v, dist / bullet_speed)
							end

							if a.name == "fierymist" or a.name == "blazingbreath" then
								v_pos = P:node_pos(v.nav_path.pi, 1, v.nav_path.ni + node_offset)
							else
								v_pos = P:node_pos(v.nav_path.pi, v.nav_path.spi, v.nav_path.ni + node_offset)
							end
						end

						local dist_x = math.abs(v_pos.x - this.pos.x)
						local dist_y = math.abs(v_pos.y - this.pos.y)

						if a.name == "fierymist" or a.name == "blazingbreath" then
							return dist_x > a.min_range and dist_y < 80
						else
							return dist_x > 65
						end
					end)
				else
					target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags,
						a.vis_bans, function(v)
						if not v.nav_path then
							return false
						end
						if a.nodes_limit and (P:get_start_node(v.nav_path.pi) + a.nodes_limit > v.nav_path.ni or P:get_end_node(v.nav_path.pi) - a.nodes_limit < v.nav_path.ni) then
							return false
						end
						return true
					end)
				end

				if target then
					local start_ts = store.tick_ts
					local b, emit_fx, emit_ps, emit_ts, node_offset

					if flight_time then
						node_offset = P:predict_enemy_node_advance(target, flight_time + a.shoot_time)
					else
						local dist = V.dist(origin.x, origin.y, target.pos.x, target.pos.y)

						node_offset = P:predict_enemy_node_advance(target, dist / bullet_speed)
					end

					local t_pos

					if a.name == "fierymist" or a.name == "blazingbreath" then
						t_pos = P:node_pos(target.nav_path.pi, 1, target.nav_path.ni + node_offset)
					else
						t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
					end

					local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

					U.animation_start(this, an, af, store.tick_ts)

					while store.tick_ts - start_ts < a.shoot_time do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_362_0
						end

						coroutine.yield()
					end

					S:queue(a.sound)

					b = E:create_entity(a.bullet)
					b.bullet.target_id = target.id
					b.bullet.source_id = this.id
					b.pos = V.vclone(this.pos)
					b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
					b.pos.y = b.pos.y + a.bullet_start_offset[ai].y
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = V.v(t_pos.x, t_pos.y)
					if b.bullet.use_unit_damage_factor then
						b.bullet.damage_factor = this.unit.damage_factor
					end

					if upg_lf and a.basic_attack then
						if not this._lethal_focus_deck then
							this._lethal_focus_deck = SU.deck_new(upg_lf.trigger_cards, upg_lf.total_cards)
						end

						local triggered_lethal_focus = SU.deck_draw(this._lethal_focus_deck)

						if triggered_lethal_focus then
							b.bullet.damage_factor = b.bullet.damage_factor * upg_lf.damage_factor_area
							b.bullet.pop = {
								"pop_crit"
							}
							b.bullet.pop_chance = 1
							b.bullet.pop_conds = DR_DAMAGE
						end
					end

					queue_insert(store, b)

					if a.xp_from_skill then
						SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
					end

					a.ts = start_ts

					if a.emit_ps and b.bullet.flight_time then
						local dest = V.vclone(b.bullet.to)

						if a.name == "fierymist" or a.name == "blazingbreath" then
							dest.y = dest.y + 15
						end

						emit_ts = store.tick_ts

						local ps = E:create_entity(a.emit_ps)
						local mspeed = V.dist(dest.x, dest.y, b.bullet.from.x, b.bullet.from.y) / b.bullet.flight_time

						ps.particle_system.emit_direction = V.angleTo(dest.x - b.bullet.from.x, dest.y - b.bullet.from.y)
						ps.particle_system.emit_speed = {
							mspeed,
							mspeed
						}
						ps.particle_system.flip_x = af
						ps.pos.x, ps.pos.y = b.bullet.from.x, b.bullet.from.y

						queue_insert(store, ps)

						emit_ps = ps
					end

					if a.emit_fx then
						local fx = E:create_entity(a.emit_fx)

						fx.pos.x, fx.pos.y = b.bullet.from.x, b.bullet.from.y
						fx.render.sprites[1].ts = store.tick_ts
						fx.render.sprites[1].flip_x = af

						if af and fx.render.sprites[1].offset.x then
							fx.render.sprites[1].offset.x = -1 * fx.render.sprites[1].offset.x
						end

						queue_insert(store, fx)

						emit_fx = fx
					end

					while not U.animation_finished(this) do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_362_0
						end

						coroutine.yield()
					end

					force_idle_ts = true

					::label_362_0::

					if emit_ps then
						emit_ps.particle_system.emit = false
						emit_ps.particle_system.source_lifetime = 0
					end

					if emit_fx then
						emit_fx.render.sprites[1].hidden = true
					end

					goto label_362_1
				end
			end
		end

		SU.soldier_idle(store, this, force_idle_ts)
		SU.soldier_regen(store, this)

		force_idle_ts = nil

		::label_362_1::

		coroutine.yield()
	end
end

scripts.fireball_dragon = {}

function scripts.fireball_dragon.update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local tl = store.tick_length
	local ps
	local targeted_hit_offset = false

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	local target = store.entities[b.target_id]

	if target then
		local dist = V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y)
		local node_offset = P:predict_enemy_node_advance(target, dist / mspeed)

		b.to = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)

		if band(target.vis.flags, F_FLYING) ~= 0 and target.unit and target.unit.hit_offset then
			targeted_hit_offset = true
			b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
		end
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * tl do
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	local hit_center = V.vclone(b.to)

	if target and target.unit and target.unit.hit_offset and targeted_hit_offset then
		hit_center.y = hit_center.y - target.unit.hit_offset.y
	end

	local targets = U.find_enemies_in_range(store.entities, hit_center, 0, b.damage_radius, b.vis_flags, b.vis_bans)

	if targets then
		for _, e in pairs(targets) do
			local d = SU.create_bullet_damage(b, e.id, this.id)

			d.xp_dest_id = b.source_id

			queue_damage(store, d)

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
		fx.render.sprites[1].ts = 0

		queue_insert(store, fx)
	end

	queue_remove(store, this)
end

scripts.breath_dragon = {}

function scripts.breath_dragon.update(this, store)
	local b = this.bullet
	local tl = store.tick_length
	local insert_ts = store.tick_ts
	local mspeed = V.dist(b.to.x, b.to.y, b.from.x, b.from.y) / b.flight_time

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * tl do
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl

		coroutine.yield()
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y
	this.render.sprites[1].hidden = false

	local start_ts = store.tick_ts
	local fx = E:create_entity("fx_breath_dragon_fire")

	fx.pos.x, fx.pos.y = b.to.x, b.to.y
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	local fx = E:create_entity("fx_breath_dragon_fire_decal")

	fx.pos.x, fx.pos.y = b.to.x, b.to.y
	fx.render.sprites[1].ts = store.tick_ts + fts(11)

	queue_insert(store, fx)

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, b.damage_radius, b.damage_flags, b.damage_bans)
	local every = fts(2)
	local steps = math.floor(this.duration / every)
	local damage_per_step = math.random(b.damage_min, b.damage_max) / steps
	local last_ts = 0

	while store.tick_ts - start_ts < this.duration do
		if targets and every < store.tick_ts - last_ts then
			last_ts = store.tick_ts

			for _, e in pairs(targets) do
				if e.health and not e.health.dead then
					local d = E:create_entity("damage")

					d.damage_type = b.damage_type
					d.value = damage_per_step
					d.target_id = e.id
					d.source_id = this.id
					d.xp_gain_factor = b.xp_gain_factor
					d.xp_dest_id = b.source_id

					queue_damage(store, d)

					if b.mod then
						local mod = E:create_entity(b.mod)

						mod.modifier.target_id = e.id

						queue_insert(store, mod)
					end
				end
			end
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.fierymist_dragon = {}

function scripts.fierymist_dragon.update(this, store)
	local b = this.bullet
	local tl = store.tick_length
	local insert_ts = store.tick_ts
	local node
	local target = store.entities[b.target_id]
	local mspeed = V.dist(b.to.x, b.to.y, b.from.x, b.from.y) / b.flight_time
	local nodes = P:nearest_nodes(b.to.x, b.to.y, nil, nil, true)

	if #nodes > 0 then
		node = {
			pi = nodes[1][1],
			spi = nodes[1][2],
			ni = nodes[1][3]
		}
	end

	if not node then
		log.debug("cannot deploy fierymist_dragon: no destination node")
		queue_remove(store, this)

		return
	end

	node.spi = 1

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * tl do
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl

		coroutine.yield()
	end

	local aura = E:create_entity(b.hit_payload)

	aura.pos = P:node_pos(node)

	queue_insert(store, aura)

	local spi = 1

	for i = 1, 14 do
		local ni = node.ni - 6 + i

		if P:is_node_valid(node.pi, ni) then
			local fx = E:create_entity("fx_aura_fierymist_dragon")

			fx.pos = P:node_pos(node.pi, spi, ni)
			fx.pos.x, fx.pos.y = fx.pos.x + math.random(0, 8), fx.pos.y + math.random(0, 8)

			local scale = U.frandom(0.9, 1.1)

			fx.render.sprites[1].scale = V.v(scale, scale)
			fx.render.sprites[1].time_offset = fts(i * 2)
			fx.duration = aura.aura.duration
			fx.tween.ts = store.tick_ts

			queue_insert(store, fx)
		end

		spi = km.zmod(spi + 2, 3)
	end

	queue_remove(store, this)
end

scripts.wildfirebarrage_dragon = {}

function scripts.wildfirebarrage_dragon.insert(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]

	if not target then
		log.debug("target removed before inserting wildfirebarrage")

		return false
	end

	local node_offset = P:predict_enemy_node_advance(target, b.flight_time)

	b.to = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)

	return true
end

function scripts.wildfirebarrage_dragon.update(this, store)
	local b = this.bullet
	local dradius = b.damage_radius
	local ps = E:create_entity(b.particles_name)

	ps.particle_system.track_id = this.id

	queue_insert(store, ps)

	while store.tick_ts - b.ts < b.flight_time do
		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)
		this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)

		coroutine.yield()
	end

	this.render.sprites[1].hidden = true
	ps.particle_system.emit = false

	local delays = {
		0,
		0.1,
		0,
		0.1,
		0,
		0.1,
		0,
		0.1,
		0,
		0,
		0,
		0.2,
		0,
		0
	}
	local node_offsets = {
		0,
		2,
		4,
		-4,
		0,
		0,
		6,
		-6,
		8,
		8,
		-8,
		-8,
		10,
		-10
	}
	local node_subpaths = {
		1,
		1,
		1,
		1,
		2,
		3,
		1,
		1,
		2,
		3,
		2,
		3,
		1,
		1
	}
	local node
	local nodes = P:nearest_nodes(b.to.x, b.to.y, nil, nil, true)

	if #nodes < 1 then
		-- block empty
	else
		node = {
			pi = nodes[1][1],
			spi = nodes[1][2],
			ni = nodes[1][3]
		}

		for i = 1, this.explosions do
			local fx, decal, pos, targets
			local n = {
				pi = node.pi,
				spi = node_subpaths[i],
				ni = node.ni + node_offsets[i]
			}
			local pos = P:node_pos(n)

			if not P:is_node_valid(n.pi, n.ni) then
				-- block empty
			else
				fx = E:create_entity("fx_wildfirebarrage_explosion_" .. ((i == 1 or i == 5 or i == 6) and "2" or "1"))
				fx.pos = pos
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)

				decal = E:create_entity("decal_wildfirebarrage_explosion")
				decal.pos = V.vclone(pos)
				decal.render.sprites[1].ts = store.tick_ts

				queue_insert(store, decal)

				targets = U.find_enemies_in_range(store.entities, pos, 0, b.damage_radius, b.damage_flags, b.damage_bans)

				if targets then
					for _, target in pairs(targets) do
						local d = SU.create_bullet_damage(b, target.id, this.id)

						d.xp_dest_id = b.source_id

						queue_damage(store, d)

						if b.mod then
							local mod = E:create_entity(b.mod)

							mod.modifier.target_id = target.id

							queue_insert(store, mod)
						end
					end
				end
			end

			if delays[i] > 0 then
				U.y_wait(store, delays[i])
			end
		end
	end

	queue_remove(store, this)
end

scripts.hero_monk = {}

function scripts.hero_monk.get_info(this)
	local a = this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_monk.level_up(this, store, initial)
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

	s = this.hero.skills.snakestyle

	if initial and s.level > 0 then
		local a = this.melee.attacks[4]

		a.disabled = nil
		a.damage_max = s.damage[s.level]
		a.damage_min = s.damage[s.level]

		local m = E:get_template("mod_monk_damage_reduction")

		m.reduction_factor = s.damage_reduction_factor[s.level]
	end

	s = this.hero.skills.dragonstyle

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end

	s = this.hero.skills.tigerstyle

	if initial and s.level > 0 then
		local a = this.melee.attacks[5]

		a.disabled = nil
		a.damage_max = s.damage[s.level]
		a.damage_min = s.damage[s.level]
	end

	s = this.hero.skills.leopardstyle

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.damage_max = s.damage_max[s.level]
		a.damage_min = s.damage_min[s.level]
		a.loops = s.loops[s.level]
	end

	s = this.hero.skills.cranestyle

	if initial and s.level > 0 then
		this.dodge.disabled = nil
		this.dodge.chance = s.chance[s.level]
		this.dodge.damage = s.damage[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_monk.insert(this, store, script)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.hero_monk.update(this, store, script)
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
			a = this.dodge
			skill = this.hero.skills.cranestyle

			if not a.disabled and a.active then
				a.active = false

				local target = store.entities[this.soldier.target_id]

				if not target or target.health.dead then
					-- block empty
				else
					local vis_bans = this.vis.bans

					this.vis.bans = F_ALL
					this.health_bar.hidden = true

					SU.hide_modifiers(store, this, true)

					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
					S:queue(a.sound, {
						delay = fts(15)
					})
					U.animation_start(this, a.animation, nil, store.tick_ts)

					if SU.y_hero_wait(store, this, a.hit_time) then
						this.vis.bans = vis_bans
						this.health_bar.hidden = this.health.dead

						goto label_372_2
					end

					local d = E:create_entity("damage")

					d.source_id = this.id
					d.target_id = target.id
					d.value = a.damage
					d.damage_type = a.damage_type

					queue_damage(store, d)

					this.vis.bans = vis_bans
					this.health_bar.hidden = false

					SU.show_modifiers(store, this, true)

					if SU.y_hero_animation_wait(this) then
						goto label_372_2
					end
				end
			end

			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_372_2
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.dragonstyle

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					local start_ts = store.tick_ts

					S:queue(a.sound, {
						delay = fts(5)
					})

					local an, af = U.animation_name_facing_point(this, a.animation, targets[1].pos)

					U.animation_start(this, an, af, store.tick_ts, false)

					while store.tick_ts - start_ts < a.hit_time do
						if SU.hero_interrupted(this) then
							goto label_372_2
						end

						coroutine.yield()
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius, a.damage_flags, a.damage_bans)

					if targets then
						for _, t in pairs(targets) do
							local d = E:create_entity("damage")

							d.source_id = this.id
							d.target_id = t.id
							d.value = math.random(a.damage_min, a.damage_max)
							d.damage_type = a.damage_type

							queue_damage(store, d)
						end
					end

					while not U.animation_finished(this) do
						if SU.hero_interrupted(this) then
							break
						end

						coroutine.yield()
					end

					goto label_372_2
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.leopardstyle

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

				if not targets then
					SU.delay_attack(store, a, 0.13333333333333333)

					goto label_372_1
				end

				U.unblock_target(store, this)

				this.health.ignore_damage = true
				this.health_bar.hidden = true

				local start_ts = store.tick_ts
				local start_pos = V.vclone(this.pos)
				local last_target
				local i = 1

				U.animation_start(this, "leopard_start", nil, store.tick_ts, false)

				while not U.animation_finished(this) do
					if SU.hero_interrupted(this) then
						goto label_372_0
					end

					coroutine.yield()
				end

				a.ts = start_ts

				SU.hero_gain_xp_from_skill(this, skill)

				while i <= a.loops do
					i = i + 1
					targets = U.find_enemies_in_range(store.entities, start_pos, 0, a.range, a.vis_flags, a.vis_bans)

					if not targets then
						break
					end

					if #targets > 1 then
						targets = table.filter(targets, function(k, v)
							return v ~= last_target
						end)
					end

					local target = table.random(targets)

					last_target = target

					local animation, animation_idx = table.random(a.hit_animations)
					local hit_time = a.hit_times[animation_idx]
					local hit_pos = U.melee_slot_position(this, target, 1)
					local last_ts = store.tick_ts

					this.pos.x, this.pos.y = hit_pos.x, hit_pos.y

					if band(target.vis.bans, F_STUN) == 0 then
						SU.stun_inc(target)
					end

					local sound = (i - 1) % 3 == 0 and "HeroMonkMultihitScream" or "HeroMonkMultihitPunch"

					S:queue(sound)

					local an, af = U.animation_name_facing_point(this, animation, target.pos)

					U.animation_start(this, an, af, store.tick_ts)

					while hit_time > store.tick_ts - last_ts do
						if SU.hero_interrupted(this) then
							SU.stun_dec(target)

							goto label_372_0
						end

						coroutine.yield()
					end

					local d = E:create_entity("damage")

					d.source_id = this.id
					d.target_id = target.id
					d.value = math.random(a.damage_min, a.damage_max)

					queue_damage(store, d)

					local poff = a.particle_pos[animation_idx]
					local fx = E:create_entity("fx")

					fx.pos.x, fx.pos.y = (af and -1 or 1) * poff.x + this.pos.x, poff.y + this.pos.y
					fx.render.sprites[1].name = "fx_hero_monk_particle"
					fx.render.sprites[1].ts = store.tick_ts
					fx.render.sprites[1].sort_y_offset = -2

					queue_insert(store, fx)

					while not U.animation_finished(this) do
						if SU.hero_interrupted(this) then
							SU.stun_dec(target)

							goto label_372_0
						end

						coroutine.yield()
					end

					SU.stun_dec(target)
				end

				::label_372_0::

				this.health.ignore_damage = nil
				this.health_bar.hidden = false
				this.pos.x, this.pos.y = start_pos.x, start_pos.y

				U.y_animation_play(this, "leopard_end", nil, store.tick_ts, 1)
			end

			::label_372_1::

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

		::label_372_2::

		coroutine.yield()
	end
end

scripts.mod_monk_damage_reduction = {}

function scripts.mod_monk_damage_reduction.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if target and target.unit then
		target.unit.damage_factor = target.unit.damage_factor * (1 - this.reduction_factor)
	end

	return false
end

scripts.hero_crab = {}

function scripts.hero_crab.get_info(this)
	local a = this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_crab.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]
	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local s

	s = this.hero.skills.battlehardened

	if initial and s.level > 0 then
		this.invuln.disabled = nil
		this.invuln.chance = s.chance[s.level]
	end

	s = this.hero.skills.pincerattack

	if initial and s.level > 0 then
		local pa = this.timed_attacks.list[1]

		pa.disabled = nil
		pa.damage_min = s.damage_min[s.level]
		pa.damage_max = s.damage_max[s.level]
	end

	s = this.hero.skills.shouldercannon

	if initial and s.level > 0 then
		local a = this.ranged.attacks[1]

		a.disabled = nil

		local b = E:get_template("crab_water_bomb")

		b.bullet.damage_max = s.damage[s.level]
		b.bullet.damage_min = s.damage[s.level]

		local m = E:get_template("mod_slow_water_bomb")

		m.modifier.duration = s.slow_duration[s.level]
		m.slow.factor = s.slow_factor[s.level]
	end

	s = this.hero.skills.burrow

	if initial and s.level > 0 then
		this.burrow.disabled = nil
		this.burrow.extra_speed = s.extra_speed[s.level]
		this.burrow.damage_radius = s.damage_radius[s.level]
		this.nav_grid.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER, TERRAIN_SHALLOW)
	end

	s = this.hero.skills.hookedclaw

	if initial and s.level > 0 then
		local pa = this.timed_attacks.list[1]

		if not pa.disabled then
			pa.damage_min = pa.damage_min + s.extra_damage[s.level]
			pa.damage_max = pa.damage_max + s.extra_damage[s.level]
		end
	end

	if s.level > 0 then
		this.melee.attacks[1].damage_min = this.melee.attacks[1].damage_min + s.extra_damage[s.level]
		this.melee.attacks[1].damage_max = this.melee.attacks[1].damage_max + s.extra_damage[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_crab.on_damage(this, store, damage)
	log.paranoid("  CRAB DAMAGE: %s", damage.value)

	local h = this.health
	local i = this.invuln

	if not i or i.disabled or this.unit.is_stunned or band(damage.damage_type, i.exclude_damage_types) ~= 0 or store.tick_ts - i.ts < i.cooldown or math.random() > i.chance then
		return true
	end

	if i.pending then
		return false
	end

	local predicted_damage = U.predict_damage(this, damage)

	if h.hp - predicted_damage < i.trigger_factor * h.hp_max then
		i.pending = true

		return false
	end

	return true
end

function scripts.hero_crab.insert(this, store, script)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.hero_crab.update(this, store, script)
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
				local b = this.burrow
				local r = this.nav_rally

				if not b.disabled and V.dist(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > b.min_distance then
					r.new = false

					U.unblock_target(store, this)

					local vis_bans = this.vis.bans

					this.vis.bans = F_ALL
					this.health.immune_to = F_ALL

					local original_speed = this.motion.max_speed

					this.motion.max_speed = this.motion.max_speed + b.extra_speed
					this.unit.marker_hidden = true

					S:queue(this.sound_events.change_rally_point)
					S:queue(this.sound_events.burrow_in)
					U.y_animation_play(this, "burrow_in", r.pos.x < this.pos.x, store.tick_ts)

					this.health_bar._orig_offset = this.health_bar.offset
					this.health_bar.offset = b.health_bar_offset
					this.unit._orig_hit_offset = this.unit.hit_offset
					this.unit.hit_offset = b.hit_offset
					this.unit._orig_mod_offset = this.unit.mod_offset
					this.unit.mod_offset = b.mod_offset

					local water_trail = E:create_entity("ps_water_trail")

					water_trail.particle_system.track_id = this.id
					water_trail.particle_system.emit = false
					water_trail.particle_system.z = Z_OBJECTS - 1

					queue_insert(store, water_trail)

					::label_379_0::

					local last_t = band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK)
					local dest = r.pos
					local n = this.nav_grid

					while not V.veq(this.pos, dest) do
						local w = table.remove(n.waypoints, 1) or dest

						U.set_destination(this, w)

						local ani = last_t == TERRAIN_WATER and "burrow_water" or "burrow_land"
						local an, af = U.animation_name_facing_point(this, ani, this.motion.dest)

						U.animation_start(this, an, af, store.tick_ts, true)

						while not this.motion.arrived do
							if r.new then
								r.new = false

								goto label_379_0
							end

							U.walk(this, store.tick_length)
							coroutine.yield()

							this.motion.speed.x, this.motion.speed.y = 0, 0

							local t = band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK)

							if t ~= last_t then
								if last_t and bor(last_t, t) == bor(TERRAIN_WATER, TERRAIN_LAND) then
									local fx = E:create_entity("fx_enemy_splash")

									fx.render.sprites[1].name = "big"
									fx.render.sprites[1].ts = store.tick_ts
									fx.render.sprites[1].sort_y_offset = 0
									fx.pos = V.vclone(this.pos)

									queue_insert(store, fx)

									if this.sound_events and this.sound_events.water_splash then
										S:queue(this.sound_events.water_splash)
									end
								end

								local in_water = t == TERRAIN_WATER
								local ani = in_water and "burrow_water" or "burrow_land"
								local an, af = U.animation_name_facing_point(this, ani, this.motion.dest)

								U.animation_start(this, an, af, store.tick_ts, true)

								water_trail.particle_system.emit = in_water
								last_t = t
							end
						end
					end

					this.health_bar.offset = this.health_bar._orig_offset
					this.unit.hit_offset = this.unit._orig_hit_offset
					this.unit.mod_offset = this.unit._orig_mod_offset

					SU.hero_gain_xp_from_skill(this, this.hero.skills.burrow)

					for i, pos in pairs({
						V.v(10, -16),
						V.v(-12, -14),
						V.v(22, -1),
						V.v(-24, -1)
					}) do
						local fx = E:create_entity("fx")

						fx.render.sprites[1].name = "fx_hero_crab_quake"
						fx.render.sprites[1].ts = store.tick_ts + (i - 1) * 0.1
						fx.render.sprites[1].scale = V.v(0.8, 0.8)
						fx.render.sprites[1].alpha = 166
						fx.render.sprites[1].anchor.y = 0.24
						fx.pos.x, fx.pos.y = this.pos.x + pos.x, this.pos.y + pos.y

						queue_insert(store, fx)
					end

					S:queue(this.sound_events.burrow_out)
					U.y_animation_play(this, "burrow_out", r.pos.x < this.pos.x, store.tick_ts)

					this.motion.max_speed = original_speed
					this.vis.bans = vis_bans
					this.health.immune_to = 0
					this.unit.marker_hidden = nil
				elseif SU.y_hero_new_rally(store, this) then
					goto label_379_2
				end
			end

			if this.invuln and this.invuln.pending then
				local e = E:create_entity(this.invuln.aura_name)

				e.aura.ts = store.tick_ts
				e.aura.source_id = this.id

				queue_insert(store, e)

				local skill = this.hero.skills.battlehardened

				SU.hero_gain_xp_from_skill(this, skill)
				S:queue(this.invuln.sound)
				U.y_animation_play(this, this.invuln.animation, nil, store.tick_ts)

				this.invuln.ts = store.tick_ts
				this.invuln.pending = nil
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.pincerattack

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local left_targets, right_targets = {}, {}
				local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(v)
					local px, py = this.pos.x, this.pos.y
					local vx, vy = v.pos.x, v.pos.y
					local rx, ry = a.damage_size.x, a.damage_size.y

					if vy >= py - ry / 2 and vy < py + ry / 2 then
						if px < vx and vx < px + rx then
							table.insert(right_targets, v)

							return true
						elseif vx < px and vx > px - rx then
							table.insert(left_targets, v)

							return true
						end
					end

					return false
				end)

				if not targets or #left_targets < a.min_count and #right_targets < a.min_count then
					SU.delay_attack(store, a, 0.13333333333333333)

					goto label_379_1
				end

				if #left_targets > #right_targets then
					targets = left_targets
				else
					targets = right_targets
				end

				local start_ts = store.tick_ts

				S:queue(a.sound)

				local an, af = U.animation_name_facing_point(this, a.animation, targets[1].pos)

				U.animation_start(this, an, af, store.tick_ts, false)

				local flip_x = this.render.sprites[1].flip_x

				while store.tick_ts - start_ts < a.hit_time do
					if SU.hero_interrupted(this) then
						goto label_379_2
					end

					coroutine.yield()
				end

				a.ts = start_ts

				SU.hero_gain_xp_from_skill(this, skill)

				targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(v)
					local px, py = this.pos.x, this.pos.y
					local vx, vy = v.pos.x, v.pos.y
					local rx, ry = a.damage_size.x, a.damage_size.y

					if vy >= py - ry / 2 and vy < py + ry / 2 then
						if not flip_x and px < vx and vx < px + rx then
							return true
						elseif flip_x and vx < px and vx > px - rx then
							return true
						end
					end

					return false
				end)

				if targets then
					for _, t in pairs(targets) do
						local d = E:create_entity("damage")

						d.source_id = this.id
						d.target_id = t.id
						d.value = math.random(a.damage_min, a.damage_max)
						d.damage_type = a.damage_type

						queue_damage(store, d)
					end
				end

				while not U.animation_finished(this) do
					if SU.hero_interrupted(this) then
						goto label_379_2
					end

					coroutine.yield()
				end

				goto label_379_2

				this.render.sprites[1].flip_x = flip_x
			end

			::label_379_1::

			brk, sta = SU.y_soldier_ranged_attacks(store, this)

			if brk then
				-- block empty
			else
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
		end

		::label_379_2::

		coroutine.yield()
	end
end

scripts.aura_crab_invuln = {}

function scripts.aura_crab_invuln.update(this, store)
	local hero = store.entities[this.aura.source_id]

	this.pos = hero.pos

	local invuln = hero.invuln
	local vis_bans = 0
	local a = this.aura

	vis_bans = hero.vis.bans
	hero.vis.bans = bor(hero.vis.bans, F_STUN)
	hero.health.immune_to = F_ALL
	this.tween.ts = store.tick_ts

	U.y_wait(store, fts(20))

	this.tween.props[3].disabled = true
	this.tween.props[4].disabled = nil

	while not this.interrupt and not hero.health.dead and not hero.nav_rally.new and store.tick_ts - a.ts < a.duration do
		coroutine.yield()
	end

	hero.vis.bans = vis_bans
	hero.health.immune_to = 0
	this.tween.ts = store.tick_ts - a.duration
	this.tween.props[4].disabled = true

	U.y_wait(store, fts(15))
	queue_remove(store, this)
end

scripts.hero_dracolich = {}

function scripts.hero_dracolich.get_info(this)
	local m = E:get_template("fireball_dracolich")
	local min, max = m.bullet.damage_min, m.bullet.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = math.ceil(this.unit.damage_factor * min),
		damage_max = math.ceil(this.unit.damage_factor * max),
		damage_type = DAMAGE_MAGICAL,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_dracolich.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	local b = E:get_template("fireball_dracolich")

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	local m = E:get_template("mod_dracolich_disease")

	m.dps.damage_min = ls.disease_damage[hl]
	m.dps.damage_max = ls.disease_damage[hl]

	local s

	s = this.hero.skills.spinerain

	if initial and s.level > 0 then
		this.timed_attacks.list[2].disabled = nil
		b = E:get_template("dracolich_spine")
		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end

	s = this.hero.skills.bonegolem

	if initial and s.level > 0 then
		this.timed_attacks.list[1].disabled = nil
		g = E:get_template("soldier_dracolich_golem")
		g.health.hp_max = s.hp_max[s.level]
		g.reinforcement.duration = s.duration[s.level]
		g.melee.attacks[1].damage_max = s.damage_max[s.level]
		g.melee.attacks[1].damage_min = s.damage_min[s.level]
	end

	s = this.hero.skills.plaguecarrier

	if initial and s.level > 0 then
		this.timed_attacks.list[4].disabled = nil
		this.timed_attacks.list[4].count = s.count[s.level]

		local a = E:get_template("dracolich_plague_carrier")

		a.aura.duration = s.duration[s.level]
		E:get_template("dracolich_spine").bullet.mod = "mod_dracolich_disease"
		E:get_template("fireball_dracolich").bullet.mod = "mod_dracolich_disease"
	end

	s = this.hero.skills.diseasenova

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end

	s = this.hero.skills.ultimate

	if initial and s.level > 0 then
		local u = E:get_template(s.controller_name)
		u.cooldown = s.cooldown[s.level]

		local e = E:get_template(u.entity)

		e.health.hp_max = s.soldier_hp_max[s.level]
		e.melee.attacks[1].damage_max = s.soldier_damage_max[s.level]
		e.melee.attacks[1].damage_min = s.soldier_damage_min[s.level]
		e.health.armor = s.soldier_armor[s.level]
		e.regen.health = s.soldier_regen_health[s.level]
		e.reinforcement.duration = s.soldier_duration[s.level]

		local a = E:get_template("mod_death_rider")

		a.inflicted_damage_factor = s.mod_inflicted_damage_factor[s.level]
		a.extra_armor = s.mod_extra_armor[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_dracolich.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

function scripts.hero_dracolich.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, force_idle_ts
	local upg_lf = UP:get_upgrade("heroes_lethal_focus")

	local function skeleton_glow_fx()
		local fx = E:create_entity("fx_dracolich_skeleton_glow")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x
		fx.render.sprites[1].anchor.y = this.render.sprites[1].anchor.y

		queue_insert(store, fx)
	end

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	force_idle_ts = true

	while true do
		if h.dead then
			this.render.sprites[1].z = Z_OBJECTS
			this.render.sprites[2].hidden = true
			SU.y_hero_death_and_respawn(store, this)
			this.render.sprites[1].z = Z_FLYING_HEROES
			this.render.sprites[2].hidden = nil
			force_idle_ts = true
		end

		SU.heroes_visual_learning_upgrade(store, this)
		SU.heroes_lone_wolves_upgrade(store, this)
		SU.alliance_merciless_upgrade(store, this)
		SU.alliance_corageous_upgrade(store, this)

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
		end

		a = this.timed_attacks.list[1]
		skill = this.hero.skills.bonegolem

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range * 1.5, a.vis_flags, a.vis_bans, function(v)
				local offset = P:predict_enemy_node_advance(v, a.spawn_time)
				local ppos = P:node_pos(v.nav_path.pi, v.nav_path.spi, v.nav_path.ni + offset)

				return P:is_node_valid(v.nav_path.pi, v.nav_path.ni + offset, NF_RALLY) and GR:cell_is_only(ppos.x, ppos.y, TERRAIN_LAND)
			end)
			local spawn_pos

			if target then
				local offset = P:predict_enemy_node_advance(target, a.spawn_time)

				spawn_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + offset)
			else
				local positions = P:get_all_valid_pos(this.pos.x, this.pos.y, a.min_range, a.max_range, TERRAIN_LAND, nil, NF_RALLY)

				spawn_pos = table.random(positions)
			end

			if not spawn_pos then
				SU.delay_attack(store, a, 0.4)
			else
				S:queue(a.sound)
				U.animation_start(this, "golem", nil, store.tick_ts)
				skeleton_glow_fx()
				U.y_wait(store, a.spawn_time)

				local e = E:create_entity(a.entity)

				e.pos = V.vclone(spawn_pos)
				e.nav_rally.pos = V.vclone(spawn_pos)
				e.nav_rally.center = V.vclone(spawn_pos)
				e.render.sprites[1].flip_x = math.random() < 0.5

				queue_insert(store, e)

				e.owner = this

				U.y_animation_wait(this)

				force_idle_ts = true
				a.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, skill)

				goto label_386_1
			end
		end

		a = this.timed_attacks.list[2]
		skill = this.hero.skills.spinerain

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if not target then
				SU.delay_attack(store, a, 0.4)
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

					U.animation_start(this, "spinerain", flip, store.tick_ts)
					skeleton_glow_fx()
					U.y_wait(store, a.spawn_time)

					local delay = 0
					local n_step = ni < s_ni and -2 or 2

					ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + 6 or ni)

					for i = 1, skill.count[skill.level] do
						local e = E:create_entity(a.entity)

						e.pos = P:node_pos(pi, spi, ni)
						e.render.sprites[1].prefix = e.render.sprites[1].prefix .. math.random(1, 3)
						e.render.sprites[1].flip_x = not flip
						e.delay = delay
						e.bullet.source_id = this.id

						queue_insert(store, e)

						delay = delay + fts(U.frandom(1, 3))
						ni = ni + n_step
						spi = km.zmod(spi + math.random(1, 2), 3)
					end

					U.y_animation_wait(this)

					force_idle_ts = true
					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)

					goto label_386_1
				end
			end
		end

		a = this.timed_attacks.list[3]
		skill = this.hero.skills.diseasenova

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if not targets or #targets < a.min_count then
				SU.delay_attack(store, a, 0.4)
			else
				local start_ts = store.tick_ts

				this.health_bar.hidden = true
				this.health.ignore_damage = true

				U.animation_start(this, "nova", nil, store.tick_ts)
				S:queue(a.sound, {
					delay = fts(10)
				})
				U.y_wait(store, a.hit_time)

				for _, target in pairs(targets) do
					local d = E:create_entity("damage")

					d.damage_type = a.damage_type
					d.source_id = this.id
					d.target_id = target.id
					d.value = math.random(a.damage_min, a.damage_max)

					queue_damage(store, d)

					if a.mod then
						local m = E:create_entity(a.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = target.id
						m.modifier.xp_dest_id = this.id

						queue_insert(store, m)
					end
				end

				local fi, fo = 10, 35

				for i = 1, 6 do
					local rx, ry = V.rotate(2 * math.pi * i / 6, 1, 0)
					local fx = E:create_entity("fx_dracolich_nova_cloud")

					fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
					fx.tween.props[2].keys = {
						{
							0,
							V.v(rx * fi, ry * fi)
						},
						{
							fts(20),
							V.v(rx * fo, ry * fo)
						}
					}
					fx.tween.ts = store.tick_ts

					queue_insert(store, fx)
				end

				local fx = E:create_entity("fx_dracolich_nova_explosion")

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)

				local fx = E:create_entity("fx_dracolich_nova_decal")

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)
				U.y_animation_wait(this)

				this.render.sprites[1].hidden = true

				U.y_wait(store, a.respawn_delay)

				this.render.sprites[1].hidden = nil

				S:queue(a.respawn_sound)
				U.y_animation_play(this, "respawn", nil, store.tick_ts)

				this.health_bar.hidden = false
				this.health.ignore_damage = false
				force_idle_ts = true
				a.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, skill)
			end
		end

		a = this.timed_attacks.list[4]
		skill = this.hero.skills.plaguecarrier

		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local targets_info = U.find_enemies_in_paths(store.entities, this.pos, a.range_nodes_min, a.range_nodes_max, nil, a.vis_flags, a.vis_bans)

			if not targets_info then
				SU.delay_attack(store, a, 0.4)
			else
				local target

				for _, ti in pairs(targets_info) do
					if GR:cell_is(ti.enemy.pos.x, ti.enemy.pos.y, TERRAIN_LAND) then
						target = ti.enemy

						break
					end
				end

				if not target then
					SU.delay_attack(store, a, 0.4)
				else
					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {
						pi
					}, nil, nil, NF_RALLY)

					if #nodes < 1 then
						SU.delay_attack(store, a, 0.4)
					else
						local s_pi, s_spi, s_ni = unpack(nodes[1])
						local dir = ni < s_ni and -1 or 1
						local offset = math.random(a.range_nodes_min, a.range_nodes_min + 5)

						s_ni = km.clamp(1, #P:path(s_pi), s_ni + (dir > 0 and offset or -offset))

						local flip = P:node_pos(s_pi, s_spi, s_ni, true).x < this.pos.x

						S:queue(a.sound)
						U.animation_start(this, "plague", flip, store.tick_ts)
						U.y_wait(store, a.spawn_time)

						local delay = 0

						for i = 1, a.count do
							local e = E:create_entity(a.entity)

							e.pos.x, e.pos.y = this.pos.x + (flip and -1 or 1) * a.spawn_offset.x, this.pos.y + a.spawn_offset.y
							e.nav_path.pi = s_pi
							e.nav_path.spi = math.random(1, 3)
							e.nav_path.ni = s_ni
							e.nav_path.dir = dir
							e.delay = delay
							e.aura.source_id = this.id

							queue_insert(store, e)

							delay = delay + fts(U.frandom(1, 3))
						end

						U.y_animation_wait(this)

						force_idle_ts = true
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						goto label_386_1
					end
				end
			end
		end

		for _, i in pairs(this.ranged.order) do
			local a = this.ranged.attacks[i]

			if a.disabled then
				-- block empty
			elseif a.sync_animation and not this.render.sprites[1].sync_flag then
				-- block empty
			elseif store.tick_ts - a.ts < a.cooldown then
				-- block empty
			elseif math.random() > a.chance then
				-- block empty
			else
				local origin = V.v(this.pos.x, this.pos.y + a.bullet_start_offset[1].y)
				local bullet_t = E:get_template(a.bullet)
				local bullet_speed = bullet_t.bullet.min_speed
				local flight_time = bullet_t.bullet.flight_time
				local attack_filter = bullet_t.bullet.attack_filter
				local target
				if attack_filter then
					target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags,
						a.vis_bans, function(v)
							local v_pos = v.pos

							if not v.nav_path then
								return false
							end

							local n_pos = P:node_pos(v.nav_path)

							if V.dist(n_pos.x, n_pos.y, v_pos.x, v_pos.y) > 5 then
								return false
							end

							if a.nodes_limit and (P:get_start_node(v.nav_path.pi) + a.nodes_limit > v.nav_path.ni or P:get_end_node(v.nav_path.pi) - a.nodes_limit < v.nav_path.ni) then
								return false
							end

							if v.motion and v.motion.speed then
								local node_offset

								if flight_time then
									node_offset = P:predict_enemy_node_advance(v, flight_time + a.shoot_time)
								else
									local dist = V.dist(origin.x, origin.y, v.pos.x, v.pos.y)

									node_offset = P:predict_enemy_node_advance(v, dist / bullet_speed)
								end

								v_pos = P:node_pos(v.nav_path.pi, v.nav_path.spi, v.nav_path.ni + node_offset)
							end

							local dist_x = math.abs(v_pos.x - this.pos.x)
							local dist_y = math.abs(v_pos.y - this.pos.y)

							return dist_x > 45
						end)
				else
					target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags,
						a.vis_bans, function(v)
							if not v.nav_path then
								return false
							end
							if a.nodes_limit and (P:get_start_node(v.nav_path.pi) + a.nodes_limit > v.nav_path.ni or P:get_end_node(v.nav_path.pi) - a.nodes_limit < v.nav_path.ni) then
								return false
							end
							return true
						end)
				end

				if target then
					local start_ts = store.tick_ts
					local b, emit_fx, emit_ps, emit_ts
					local dist = V.dist(origin.x, origin.y, target.pos.x, target.pos.y)
					local node_offset = P:predict_enemy_node_advance(target, dist / bullet_speed)
					local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
					local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

					U.animation_start(this, an, af, store.tick_ts)

					while store.tick_ts - start_ts < a.shoot_time do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_386_0
						end

						coroutine.yield()
					end

					S:queue(a.sound)

					b = E:create_entity(a.bullet)

					b.bullet.target_id = target.id
					b.bullet.source_id = this.id
					b.pos = V.vclone(this.pos)
					b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
					b.pos.y = b.pos.y + a.bullet_start_offset[ai].y
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = V.v(t_pos.x, t_pos.y)
					if b.bullet.use_unit_damage_factor then
						b.bullet.damage_factor = this.unit.damage_factor
					end

					if upg_lf and a.basic_attack then
						if not this._lethal_focus_deck then
							this._lethal_focus_deck = SU.deck_new(upg_lf.trigger_cards, upg_lf.total_cards)
						end

						local triggered_lethal_focus = SU.deck_draw(this._lethal_focus_deck)

						if triggered_lethal_focus then
							b.bullet.damage_factor = b.bullet.damage_factor * upg_lf.damage_factor_area
							b.bullet.pop = {
								"pop_crit"
							}
							b.bullet.pop_chance = 1
							b.bullet.pop_conds = DR_DAMAGE
						end
					end

					queue_insert(store, b)

					a.ts = start_ts

					while not U.animation_finished(this) do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_386_0
						end

						coroutine.yield()
					end

					force_idle_ts = true

					::label_386_0::

					goto label_386_1
				end
			end
		end

		SU.soldier_idle(store, this, force_idle_ts)
		SU.soldier_regen(store, this)

		force_idle_ts = nil

		::label_386_1::

		coroutine.yield()
	end
end

scripts.mod_dracolich_disease = {}

function scripts.mod_dracolich_disease.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	local has_mods, mods = U.has_modifiers(store, target, this.template_name)
	if has_mods then
		local mod = mods[1]
		mod.modifier.source_id = this.modifier.source_id
		mod.modifier.xp_dest_id = this.modifier.xp_dest_id
		if mod.render then
			local sprite = mod.render.sprites[1]
			sprite.ts = store.tick_ts
		end
		mod.modifier.ts = store.tick_ts
		return false
	end

	return scripts.mod_dps.insert(this, store, script)
end

function scripts.mod_dracolich_disease.update(this, store, script)
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

function scripts.mod_dracolich_disease.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if this.spread_active and target and target.health.dead and band(target.health.last_damage_types, DAMAGE_EAT) == 0 then
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.spread_radius, this.modifier.vis_flags, this.modifier.vis_bans)

		if targets then
			for _, t in pairs(targets) do
				local m = E:create_entity(this.template_name)

				m.modifier.target_id = t.id
				m.modifier.source_id = this.modifier.source_id
				m.modifier.xp_dest_id = this.modifier.xp_dest_id

				queue_insert(store, m)

				local d = E:create_entity("damage")

				d.source_id = this.id
				d.target_id = t.id
				d.value = this.spread_damage
				d.damage_type = this.dps.damage_type

				queue_damage(store, d)

				local h = store.entities[this.modifier.xp_dest_id]
			end
		end

		local fx = E:create_entity(this.spread_fx)

		fx.pos = V.vclone(this.pos)

		if target and this.modifier.use_mod_offset and target.unit.mod_offset then
			local mo = target.unit.mod_offset

			fx.pos.x, fx.pos.y = fx.pos.x + mo.x, fx.pos.y + mo.y
		end

		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	return true
end

scripts.dracolich_spine = {}

function scripts.dracolich_spine.update(this, store)
	local b = this.bullet

	U.sprites_hide(this)

	if this.delay then
		U.y_wait(store, this.delay)
	end

	U.sprites_show(this)

	local start_ts = store.tick_ts

	this.pos.x = this.pos.x + math.random(-4, 4)
	this.pos.y = this.pos.y + math.random(-5, 5)

	S:queue(this.sound_events.delayed_insert)
	U.animation_start(this, "start", nil, store.tick_ts, false, 1)

	this.tween.ts = store.tick_ts

	U.y_wait(store, b.hit_time)

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in pairs(targets) do
			local d = E:create_entity("damage")

			d.damage_type = b.damage_type
			d.source_id = this.id
			d.target_id = target.id
			d.value = math.random(b.damage_min, b.damage_max)

			queue_damage(store, d)

			if b.mod then
				local m = E:create_entity(b.mod)

				m.modifier.source_id = this.id
				m.modifier.target_id = target.id
				m.modifier.xp_dest_id = b.source_id

				queue_insert(store, m)
			end
		end
	end

	U.y_wait(store, b.duration - (store.tick_ts - start_ts))
	U.y_animation_play(this, "end", nil, store.tick_ts, 1, 1)
	queue_remove(store, this)
end

scripts.dracolich_plague_carrier = {}

function scripts.dracolich_plague_carrier.insert(this, store)
	local next_pos = P:node_pos(this.nav_path)

	if not next_pos then
		return false
	end

	return true
end

function scripts.dracolich_plague_carrier.update(this, store)
	local y_off = 20
	local a = this.aura
	local m = this.motion
	local nav = this.nav_path
	local dt = store.tick_length
	local start_ni = nav.ni
	local start_ts = store.tick_ts
	local hit_ts = 0

	a.duration = a.duration + U.frandom(-a.duration_var, 0)
	m.max_speed = m.max_speed + math.random(0, m.max_speed_var)

	local step = m.max_speed * dt
	local next_pos = P:node_pos(nav)

	next_pos.y = next_pos.y + y_off

	U.set_destination(this, next_pos)

	local v_heading = V.v(0, 0)

	v_heading.x, v_heading.y = V.normalize(next_pos.x - this.pos.x, next_pos.y - this.pos.y)

	local th_dist = 25
	local turn_speed = math.pi * 1.5
	local enemies_hit = {}

	if this.delay then
		this.render.sprites[1].hidden = true

		U.y_wait(store, this.delay)

		this.render.sprites[1].hidden = nil
	end

	local ps = E:create_entity("ps_dracolich_plague")

	ps.particle_system.track_id = this.id

	queue_insert(store, ps)

	while true do
		if this.tween.disabled and store.tick_ts - start_ts > a.duration then
			this.tween.disabled = nil
			this.tween.ts = store.tick_ts
			ps.particle_system.emit = false
		end

		if th_dist > V.len(m.dest.x - this.pos.x, m.dest.y - this.pos.y) then
			nav.ni = nav.ni + math.random(6, 11) * nav.dir

			local p_len = #P:path(nav.pi)

			if nav.ni <= 1 or p_len <= nav.ni then
				a.duration = 0
			end

			nav.ni = km.clamp(1, p_len, nav.ni)
			nav.spi = km.zmod(nav.spi + math.random(1, 2), 3)
			next_pos = P:node_pos(nav)
			next_pos.y = next_pos.y + y_off

			U.set_destination(this, next_pos)
		end

		local dx, dy = V.sub(m.dest.x, m.dest.y, this.pos.x, this.pos.y)
		local sa = km.short_angle(V.angleTo(dx, dy), V.angleTo(v_heading.x, v_heading.y))
		local angle_step = math.min(turn_speed * dt, math.abs(sa)) * km.sign(sa) * -1

		v_heading.x, v_heading.y = V.rotate(angle_step, v_heading.x, v_heading.y)

		local sx, sy = V.mul(step, v_heading.x, v_heading.y)

		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
		m.speed.x, m.speed.y = sx / dt, sy / dt
		this.render.sprites[1].r = V.angleTo(v_heading.x, v_heading.y)

		if store.tick_ts - hit_ts > a.damage_cycle then
			hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius, a.damage_flags, a.damage_bans, function(v)
				return not table.contains(enemies_hit, v)
			end)

			if not targets then
				-- block empty
			else
				for _, e in pairs(targets) do
					local d = E:create_entity("damage")

					d.source_id = this.id
					d.target_id = e.id
					d.value = math.random(a.damage_min, a.damage_max)
					d.damage_type = a.damage_type

					queue_damage(store, d)

					if a.mod then
						local m = E:create_entity(a.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = e.id
						m.modifier.xp_dest_id = a.source_id

						queue_insert(store, m)
					end

					table.insert(enemies_hit, e)
				end
			end
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.hero_dracolich_ultimate = {}

function scripts.hero_dracolich_ultimate.can_fire_fn(this, x, y, store)
	return GR:cell_is_only(x, y, TERRAIN_LAND) and P:valid_node_nearby(x, y, nil, NF_RALLY)
end

function scripts.hero_dracolich_ultimate.update(this, store)
	local x, y = this.pos.x, this.pos.y
	local e = E:create_entity(this.entity)

	e.pos.x = x
	e.pos.y = y
	e.nav_rally.center = V.v(x, y)
	e.nav_rally.pos = V.vclone(e.pos)

	queue_insert(store, e)
	queue_remove(store, this)
end

scripts.soldier_death_rider = {}

function scripts.soldier_death_rider.insert(this, store, script)
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

	if this.info and this.info.random_name_format then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""),
			math.random(this.info.random_name_count))
	end

	return true
end

function scripts.soldier_death_rider.update(this, store, script)
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

			if this.health.dead then
				this.reinforcement.fade = nil
				this.tween = nil
			else
				this.reinforcement.fade = true
			end

			this.health.hp = 0

			SU.remove_modifiers(store, this)

			this.ui.can_click = false

			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			SU.soldier_courage_upgrade(store, this)

			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_229_1
				end
			end

			if this.melee then
				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
					goto label_229_1
				end
			end

			if this.ranged then
				brk, star = SU.y_soldier_ranged_attacks(store, this)

				if brk or star == A_DONE then
					goto label_229_1
				elseif star == A_IN_COOLDOWN then
					goto label_229_0
				end
			end

			if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
				goto label_229_1
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_229_1
			end

			::label_229_0::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_229_1::

		coroutine.yield()
	end
end

scripts.kr2_soldier_reinforcement = {}

function scripts.kr2_soldier_reinforcement.insert(this, store, script)
	if this.melee then
		this.melee.order = U.attack_order(this.melee.attacks)
	end

	if this.ranged then
		this.ranged.order = U.attack_order(this.ranged.attacks)
	end

	if this.info and this.info.random_name_format then
		this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""),
		math.random(this.info.random_name_count))
	end

	return true
end

function scripts.kr2_soldier_reinforcement.update(this, store, script)
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

			SU.remove_modifiers(store, this)

			this.ui.can_click = false

			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			SU.soldier_courage_upgrade(store, this)

			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_34_1
				end
			end

			if this.melee then
				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
					goto label_34_1
				end
			end

			if this.ranged then
				brk, star = SU.y_soldier_ranged_attacks(store, this)

				if brk or star == A_DONE then
					goto label_34_1
				elseif star == A_IN_COOLDOWN then
					goto label_34_0
				end
			end

			if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
				goto label_34_1
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_34_1
			end

			::label_34_0::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_34_1::

		coroutine.yield()
	end
end

scripts.hero_van_helsing = {}

function scripts.hero_van_helsing.get_info(this)
	local a = this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_van_helsing.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	local a = this.melee.attacks[1]

	a.damage_max = ls.damage_max[hl]
	a.damage_min = ls.damage_min[hl]

	local b = E:get_template("van_helsing_shotgun")

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]
	a = this.timed_attacks.list[2]
	a.avg_dmg = (ls.ranged_damage_max[hl] + ls.ranged_damage_min[hl]) / 2

	local s

	s = this.hero.skills.multishoot

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.loops = s.loops[s.level]
	end

	s = this.hero.skills.silverbullet

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bullet.damage_max = s.damage[s.level]
		b.bullet.damage_min = s.damage[s.level]
	end

	s = this.hero.skills.holygrenade

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[3]

		a.disabled = nil

		local m = E:get_template("mod_van_helsing_silence")

		m.modifier.duration = s.silence_duration[s.level]
	end

	s = this.hero.skills.relicofpower

	if initial and s.level > 0 then
		local a = this.melee.attacks[2]

		a.disabled = nil

		local m = E:get_template("mod_van_helsing_relic")

		m.armor_reduce_factor = s.armor_reduce_factor[s.level]
	end

	s = this.hero.skills.beaconoflight

	if initial and s.level > 0 then
		local m = E:get_template("mod_van_helsing_beacon")

		m.inflicted_damage_factor = s.inflicted_damage_factor[s.level]
		this.info.hero_portrait_always_on = true
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_van_helsing.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.ranged.order = U.attack_order(this.ranged.attacks)
	this.melee.order = U.attack_order(this.melee.attacks)

	if this.hero.skills.beaconoflight.level > 0 then
		local a = E:create_entity("van_helsing_beacon_aura")

		a.aura.source_id = this.id

		queue_insert(store, a)

		this._beaconoflight_aura = a
	end

	return true
end

function scripts.hero_van_helsing.update(this, store)
	local h = this.health
	local he = this.hero
	local ra = this.ranged.attacks[1]
	local ra_ready = false
	local a, skill, brk, sta
	local sb_dummy_dmg = E:create_entity("damage")

	sb_dummy_dmg.type = DAMAGE_PHYSICAL

	local function is_werewolf(e)
		local t1 = e.template_name

		return t1 == "enemy_lycan" or t1 == "enemy_lycan_werewolf" or t1 == "enemy_werewolf"
	end

	local function eff_hp(e)
		return e.health.hp / (1 - km.clamp(0, 0.99, e.health.armor))
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			if this.hero.skills.beaconoflight.level > 0 and band(this.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE_BOSS)) == 0 then
				S:queue(this.sound_events.death)
				U.unblock_target(store, this)

				local death_ts = store.tick_ts
				local bans, flags = this.vis.bans, this.vis.flags
				local prefix = this.render.sprites[1].prefix

				this.vis.bans = F_ALL
				this.vis.flags = F_NONE
				this.render.sprites[1].prefix = prefix .. "_ghost"
				this.health.ignore_damage = true
				this.info.hero_portrait = this.info.hero_portrait_dead
				this.info.portrait = this.info.portrait_dead

				U.y_animation_play(this, "start", nil, store.tick_ts)
				U.animation_start(this, "idle", nil, store.tick_ts, true)

				while store.tick_ts - death_ts < this.health.dead_lifetime do
					SU.y_hero_new_rally(store, this)

					this.health.ignore_damage = true

					coroutine.yield()
				end

				this.vis.bans = bans
				this.vis.flags = flags
				this.render.sprites[1].prefix = prefix
				this.health.hp = this.health.hp_max
				this.health.dead = false
				this.health.ignore_damage = false
				this.info.hero_portrait = this.info.hero_portrait_alive
				this.info.portrait = this.info.portrait_alive

				S:queue(this.sound_events.respawn)
				U.y_animation_play(this, "respawn", nil, store.tick_ts)

				this.health_bar.hidden = false
			else
				local a = this._beaconoflight_aura

				if a then
					a.aura.requires_alive_source = true
				end

				SU.y_hero_death_and_respawn(store, this)

				if a then
					a.aura.requires_alive_source = false
				end
			end
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_398_2
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			ra_ready = store.tick_ts - ra.ts >= ra.cooldown
			a = this.timed_attacks.list[3]
			skill = this.hero.skills.holygrenade

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local g = E:get_template("van_helsing_grenade")
				local target, _, pred_pos = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range, a.shoot_time + g.bullet.flight_time, a.vis_flags, a.vis_bans, function(e)
					return band(e.vis.flags, F_SPELLCASTER) ~= 0 and e.enemy.can_do_magic and math.abs(this.pos.x - e.pos.x) > 20
				end)

				if not target then
					SU.delay_attack(store, a, 0.2)
				else
					local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

					U.animation_start(this, an, af, store.tick_ts, false)

					if U.y_wait(store, a.shoot_time, function()
						return SU.hero_interrupted(this)
					end) then
						-- block empty
					else
						local b = E:create_entity(a.bullet)

						b.pos.x = this.pos.x + (af and -1 or 1) * a.bullet_start_offset[1].x
						b.pos.y = this.pos.y + a.bullet_start_offset[1].y
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = V.vclone(pred_pos)
						b.bullet.target_id = target.id

						queue_insert(store, b)

						while not U.animation_finished(this) and not SU.hero_interrupted(this) do
							coroutine.yield()
						end

						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						goto label_398_2
					end
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.silverbullet

			if not a.disabled and store.tick_ts - a.ts > a.cooldown and ra_ready then
				sb_dummy_dmg.value = a.avg_dmg

				local target = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range, a.shoot_time, a.vis_flags, a.vis_bans, function(e)
					local effective_hp = eff_hp(e)
					local d_pred = U.predict_damage(e, sb_dummy_dmg) * a.filter_damage_factor

					return math.abs(P:nodes_to_defend_point(e.nav_path)) < a.nodes_to_defend and d_pred < effective_hp
				end)

				if not target then
					local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(e)
						local effective_hp = eff_hp(e)
						local d_pred = U.predict_damage(e, sb_dummy_dmg) * a.filter_damage_factor

						return d_pred < effective_hp
					end)

					if targets then
						table.sort(targets, function(e1, e2)
							local df = a.werewolf_damage_factor

							return eff_hp(e1) * (is_werewolf(e1) and df or 1) > eff_hp(e2) * (is_werewolf(e2) and df or 1)
						end)

						if #targets > 0 then
							target = targets[1]
						end
					end
				end

				if not target then
					SU.delay_attack(store, a, 0.2)
				else
					local an, af, aidx = U.animation_name_facing_point(this, a.animation, target.pos)

					U.animation_start(this, an, af, store.tick_ts, false)

					if U.y_wait(store, a.crosshair_time, function()
						return SU.hero_interrupted(this)
					end) then
						-- block empty
					else
						local m = E:create_entity(a.crosshair_name)

						m.modifier.source_id = this.id
						m.modifier.target_id = target.id
						m.render.sprites[1].ts = store.tick_ts

						queue_insert(store, m)

						if U.y_wait(store, a.shoot_time - a.crosshair_time, function()
							return SU.hero_interrupted(this)
						end) then
							queue_remove(store, m)
						else
							local b = E:create_entity(a.bullet)

							b.pos.x = this.pos.x + (af and -1 or 1) * a.bullet_start_offset[aidx].x
							b.pos.y = this.pos.y + a.bullet_start_offset[aidx].y
							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = V.vclone(target.pos)
							b.bullet.target_id = target.id
							b.bullet.damage_factor = is_werewolf(target) and a.werewolf_damage_factor or 1

							queue_insert(store, b)

							while not U.animation_finished(this) and not SU.hero_interrupted(this) do
								coroutine.yield()
							end

							a.ts = store.tick_ts

							SU.hero_gain_xp_from_skill(this, skill)

							ra.ts = store.tick_ts

							goto label_398_2
						end
					end
				end
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.multishoot

			if not a.disabled and store.tick_ts - a.ts > a.cooldown and ra_ready then
				local target, targets = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range, a.shoot_time, a.vis_flags, a.vis_bans, function(e)
					local center_pos = P:node_pos(e.nav_path.pi, 1, e.nav_path.ni)
					local nearby = U.find_enemies_in_range(store.entities, center_pos, 0, a.search_range, a.vis_flags, a.vis_bans)

					return nearby and #nearby >= a.search_min_count
				end)

				if not target then
					SU.delay_attack(store, a, 0.2)
				else
					local an, af = U.animation_name_facing_point(this, a.animations[1], target.pos)

					U.animation_start(this, an, af, store.tick_ts, false)

					while not U.animation_finished(this) do
						if SU.hero_interrupted(this) then
							goto label_398_1
						end

						coroutine.yield()
					end

					for i = 1, a.loops / 2 do
						log.paranoid("van_helsing multishoot target:%s (targets: %s)", target.id, table.concat(table.map(targets, function(k, v)
							return v.id
						end), ","))

						an, af, aidx = U.animation_name_facing_point(this, a.animations[2], target.pos)

						U.animation_start(this, an, af, store.tick_ts, false)

						for i = 1, 2 do
							U.y_wait(store, fts(2))

							local b = E:create_entity(a.bullet)

							b.pos.x = this.pos.x + (af and -1 or 1) * a.bullet_start_offset[aidx].x
							b.pos.y = this.pos.y + a.bullet_start_offset[aidx].y
							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = V.vclone(target.pos)
							b.bullet.target_id = target.id

							queue_insert(store, b)
						end

						while not U.animation_finished(this) do
							if SU.hero_interrupted(this) then
								goto label_398_0
							end

							coroutine.yield()
						end

						target = table.random(targets)

						if target.health.dead then
							local center_pos = P:node_pos(target.nav_path.pi, 1, target.nav_path.ni)
							local nearby = U.find_nearest_enemy(store.entities, center_pos, 0, a.search_range, a.vis_flags, a.vis_bans)

							if nearby then
								table.removeobject(targets, target)
								table.insert(targets, nearby)

								target = nearby
							end
						end
					end

					an, af = U.animation_name_facing_point(this, a.animations[3], target.pos)

					U.animation_start(this, an, af, store.tick_ts, false)

					while not U.animation_finished(this) and not SU.hero_interrupted(this) do
						coroutine.yield()
					end

					::label_398_0::

					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)

					ra.ts = store.tick_ts

					goto label_398_2
				end
			end

			::label_398_1::

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

		::label_398_2::

		coroutine.yield()
	end
end

function scripts.hero_van_helsing.can_relic(this, store, attack, target)
	return target.health.armor > 0 or target.health.magic_armor > 0
end

scripts.van_helsing_grenade = {}

function scripts.van_helsing_grenade.update(this, store)
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

	local target = store.entities[b.target_id]

	if target and not target.health.dead and U.is_inside_ellipse(this.pos, target.pos, b.damage_radius) then
		local mod = E:create_entity(b.mod)

		mod.modifier.target_id = target.id

		queue_insert(store, mod)
	end

	local fx = E:create_entity(b.hit_fx)

	fx.render.sprites[1].ts = store.tick_ts
	fx.pos = V.vclone(b.to)

	queue_insert(store, fx)
	queue_remove(store, this)
end

scripts.mod_van_helsing_relic = {}

function scripts.mod_van_helsing_relic.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	local factor = 1 - this.armor_reduce_factor

	if not target or not target.health or target.health.dead then
		-- block empty
	else
		for _, n in pairs(this.remove_mods) do
			SU.remove_modifiers(store, target, n)
		end

		if target.health.armor > 0 then
			target.health.armor = km.clamp(0, 1, target.health.armor * factor)
		elseif target.health.magic_armor > 0 then
			target.health.magic_armor = km.clamp(0, 1, target.health.magic_armor * factor)
		end

		this.pos.x, this.pos.y = target.pos.x, target.pos.y
		this.render.sprites[1].offset.y = target.health_bar.offset.y
		this.render.sprites[1].ts = store.tick_ts

		U.y_animation_wait(this)
	end

	queue_remove(store, this)
end

scripts.mod_van_helsing_beacon = {}

function scripts.mod_van_helsing_beacon.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor

	return true
end

function scripts.mod_van_helsing_beacon.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.unit.damage_factor = target.unit.damage_factor / this.inflicted_damage_factor
	end

	return true
end

scripts.hero_minotaur = {}

function scripts.hero_minotaur.get_info(this)
	local a = this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_minotaur.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	local a = this.melee.attacks[1]

	a.damage_max = ls.damage_max[hl]
	a.damage_min = ls.damage_min[hl]

	local s

	s = this.hero.skills.bullrush

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
		a.run_damage_min = s.run_damage_min[s.level]
		a.run_damage_max = s.run_damage_max[s.level]

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
	end

	s = this.hero.skills.bloodaxe

	if s.level > 0 then
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.damage_max = ls.damage_max[hl] * s.damage_factor[s.level]
		a.damage_min = ls.damage_min[hl] * s.damage_factor[s.level]
	end

	s = this.hero.skills.daedalusmaze

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[4]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
	end

	s = this.hero.skills.roaroffury

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.extra_damage = s.extra_damage[s.level]
	end

	s = this.hero.skills.doomspin

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_minotaur.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.hero_minotaur.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta
	local ps = E:create_entity("ps_minotaur_bullrush")

	ps.particle_system.track_id = this.id
	ps.particle_system.emit = false

	queue_insert(store, ps)

	local function do_rush_damage(target, a, final_hit)
		local d = E:create_entity("damage")

		d.source_id = this.id
		d.target_id = target.id

		if final_hit then
			d.value = math.random(a.damage_min, a.damage_max)
		else
			d.value = math.random(a.run_damage_min, a.run_damage_max)
		end

		d.damage_type = a.damage_type

		queue_damage(store, d)
	end

	local function do_rush_stun(target, a)
		local m = E:create_entity(a.mod)

		m.modifier.target_id = target.id
		m.modifier.source_id = this.id

		queue_insert(store, m)
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
					goto label_418_2
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.doomspin

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_count then
					SU.delay_attack(store, a, 0.2)
				else
					local target = targets[1]

					S:queue(a.sound)

					local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

					U.animation_start(this, an, af, store.tick_ts, false)

					if U.y_wait(store, a.hit_time, function()
						return SU.hero_interrupted(this)
					end) then
						-- block empty
					else
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						for _, e in pairs(targets) do
							local d = E:create_entity("damage")

							d.source_id = this.id
							d.target_id = e.id
							d.value = math.random(a.damage_min, a.damage_max)
							d.damage_type = a.damage_type

							queue_damage(store, d)
						end

						while not U.animation_finished(this) and not SU.hero_interrupted(this) do
							coroutine.yield()
						end

						goto label_418_2
					end
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.roaroffury

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local towers = table.filter(store.entities, function(_, e)
					return e.tower and e.tower.can_be_mod and not e.tower.blocked and not table.contains(a.excluded_templates, e.template_name)
				end)

				if #towers < 1 then
					SU.delay_attack(store, a, 0.2)
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

						local fx = E:create_entity(a.shoot_fx)

						fx.pos = V.vclone(this.pos)
						fx.render.sprites[1].anchor = V.vclone(this.render.sprites[1].anchor)
						fx.render.sprites[1].ts = store.tick_ts
						fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

						queue_insert(store, fx)

						for _, t in pairs(towers) do
							local m = E:create_entity(a.mod)

							m.modifier.target_id = t.id

							queue_insert(store, m)
						end

						while not U.animation_finished(this) and not SU.hero_interrupted(this) do
							coroutine.yield()
						end

						fx.render.sprites[1].hidden = true

						goto label_418_2
					end
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.bullrush

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_first_target(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(e)
					if not e.heading or not e.nav_path then
						return false
					end

					local dist = V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y)
					local ftime = dist / (this.motion.max_speed * a.speed_factor)
					local pni = e.nav_path.ni + P:predict_enemy_node_advance(e, ftime)
					local ppos = P:predict_enemy_pos(e, ftime)
					local slot_pos = U.melee_slot_position(this, e, 1)

					return P:nodes_to_goal(e.nav_path) > a.nodes_limit and P:is_node_valid(e.nav_path.pi, e.nav_path.ni) and P:is_node_valid(e.nav_path.pi, pni) and GR:cell_is_only(slot_pos.x, slot_pos.y, this.nav_grid.valid_terrains_dest) and GR:cell_is_only(ppos.x, ppos.y, this.nav_grid.valid_terrains_dest) and GR:find_line_waypoints(this.pos, ppos, this.nav_grid.valid_terrains) ~= nil
				end)

				if not target then
					SU.delay_attack(store, a, 0.2)

					goto label_418_0
				end

				local damaged_enemies = {}

				U.unblock_target(store, this)

				this.health_bar.hidden = true
				this.health.ignore_damage = true

				local vis_bans = this.vis.bans

				this.vis.bans = F_ALL
				this.motion.max_speed = this.motion.max_speed * a.speed_factor

				local an, af = U.animation_name_facing_point(this, a.animations[1], target.pos)

				U.y_animation_play(this, an, af, store.tick_ts, 1)

				ps.particle_system.emit = true

				local dust = E:create_entity("mod_minotaur_dust")

				dust.modifier.target_id = this.id

				queue_insert(store, dust)

				local interrupted = false

				S:queue(a.sound)
				U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

				local slot_pos, slot_flip = U.melee_slot_position(this, target, 1)

				U.set_destination(this, slot_pos)

				while not U.walk(this, store.tick_length) do
					local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.stun_range, a.stun_vis_flags, a.stun_vis_bans, function(v)
						return not table.contains(damaged_enemies, v)
					end)

					if targets then
						for _, t in pairs(targets) do
							table.insert(damaged_enemies, t)
							do_rush_damage(t, a, false)
							do_rush_stun(t, a)
						end
					end

					coroutine.yield()

					slot_pos = U.melee_slot_position(this, target, 1)

					if not GR:cell_is_only(slot_pos.x, slot_pos.y, this.nav_grid.valid_terrains_dest) or not P:is_node_valid(target.nav_path.pi, target.nav_path.ni) then
						log.debug("bullrush interrupted")

						interrupted = true

						break
					end

					U.set_destination(this, slot_pos)
				end

				this.nav_rally.center = V.vclone(this.pos)
				this.nav_rally.pos = V.vclone(this.pos)

				queue_remove(store, dust)

				ps.particle_system.emit = false
				an, af = U.animation_name_facing_point(this, a.animations[3], target.pos)

				U.animation_start(this, an, af, store.tick_ts, false)
				U.y_wait(store, fts(5))

				if not interrupted then
					do_rush_damage(target, a, true)

					if target.health and not target.health.dead and band(target.vis.flags, a.stun_vis_bans) == 0 and band(target.vis.bans, a.stun_vis_flags) == 0 then
						do_rush_stun(target, a)
					end
				end

				this.health_bar.hidden = nil
				this.health.ignore_damage = false
				this.vis.bans = vis_bans
				this.motion.max_speed = this.motion.max_speed / a.speed_factor
				a.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, skill)
				U.y_animation_wait(this)

				goto label_418_2
			end

			::label_418_0::

			a = this.timed_attacks.list[4]
			skill = this.hero.skills.daedalusmaze

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {
					1,
					2,
					3
				}, true, NF_NO_EXIT)

				if #nearest_nodes < 1 then
					SU.delay_attack(store, a, 0.2)

					goto label_418_1
				end

				local pi, spi, ni = unpack(nearest_nodes[1])

				ni = ni + a.node_offset

				local n_pos = P:node_pos(pi, spi, ni)

				if not U.is_inside_ellipse(this.pos, n_pos, this.melee.range) or not P:is_node_valid(pi, ni) or P:nodes_to_defend_point(pi, spi, ni) < a.nodes_limit or band(GR:cell_type(n_pos.x, n_pos.y), a.invalid_terrains) ~= 0 then
					SU.delay_attack(store, a, 0.2)

					goto label_418_1
				end

				local terrains = P:path_terrain_types(pi)

				terrains = band(terrains, bnot(TERRAIN_CLIFF))

				local target = U.find_foremost_enemy(store.entities, this.pos, a.min_range, a.max_range, false, a.vis_flags, a.vis_bans, function(v)
					return band(bnot(v.enemy.valid_terrains), terrains) == 0
				end)

				if not target then
					SU.delay_attack(store, a, 0.2)

					goto label_418_1
				end

				SU.remove_modifiers(store, target)

				local m = E:create_entity(a.mod)

				m.modifier.target_id = target.id
				m.modifier.source_id = this.id
				m.dest_pi = pi
				m.dest_spi = spi
				m.dest_ni = ni

				queue_insert(store, m)
				S:queue(a.sound)

				local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

				U.y_animation_play(this, an, af, store.tick_ts, 1)

				a.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, skill)

				goto label_418_2
			end

			::label_418_1::

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

		::label_418_2::

		coroutine.yield()
	end
end

scripts.mod_minotaur_daedalus = {}

function scripts.mod_minotaur_daedalus.queue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		target.vis._bans = target.vis.bans
		target.vis.bans = F_ALL
		target.health.ignore_damage = true

		SU.stun_inc(target)

		local s = this.render.sprites[1]
		local m = this.modifier

		if s.size_names then
			s.prefix = s.prefix .. "_" .. s.size_names[target.unit.size]
		end

		if s.size_anchor then
			s.anchor = s.size_anchors[target.unit.size]
		end

		if m.custom_offsets then
			s.offset = m.custom_offsets[target.template_name] or m.custom_offsets.default
		elseif m.use_mod_offset and target.unit.mod_offset then
			s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	else
		SU.stun_dec(target)

		if target.vis._bans then
			target.vis.bans = target.vis._bans
			target.vis._bans = nil
			target.health.ignore_damage = true
		end
	end
end

function scripts.mod_minotaur_daedalus.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	local fx = E:create_entity("decal_minotaur_daedalus")

	fx.pos = V.vclone(target.pos)
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)
	U.y_wait(store, 0.5)

	local es = E:create_entity("daedalus_enemy_decal")

	es.pos.x, es.pos.y = target.pos.x, target.pos.y
	es.render = table.deepclone(target.render)
	es.tween.ts = store.tick_ts

	queue_insert(store, es)
	coroutine.yield()
	U.sprites_hide(target)

	target.health_bar.hidden = true

	U.y_wait(store, 0.5)

	target.nav_path.pi = this.dest_pi
	target.nav_path.spi = this.dest_spi
	target.nav_path.ni = this.dest_ni

	local pos = P:node_pos(target.nav_path)

	target.pos.x, target.pos.y = pos.x, pos.y
	es.pos = V.vclone(pos)
	this.pos = V.vclone(pos)
	es.tween.reverse = true
	es.tween.ts = store.tick_ts
	fx = E:create_entity("decal_minotaur_daedalus")
	fx.pos = V.vclone(target.pos)
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)
	U.y_wait(store, 0.5)
	queue_remove(store, es)
	U.sprites_show(target)

	target.health_bar.hidden = nil
	target.health.ignore_damage = nil

	if target.vis._bans then
		target.vis.bans = target.vis._bans
		target.vis._bans = nil
	end

	local s = this.render.sprites[1]

	s.hidden = nil
	s.flip_x = target.render.sprites[1].flip_x
	m.ts = store.tick_ts

	while store.tick_ts - m.ts < m.duration and target and not target.health.dead do
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.hero_monkey_god = {}

function scripts.hero_monkey_god.get_info(this)
	local a = this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end

function scripts.hero_monkey_god.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	local a = this.melee.attacks[1]

	a.damage_max = ls.damage_max[hl]
	a.damage_min = ls.damage_min[hl]
	a = this.melee.attacks[2]
	a.damage_max = ls.damage_max[hl]
	a.damage_min = ls.damage_min[hl]

	local s

	s = this.hero.skills.spinningpole

	if initial and s.level > 0 then
		local a = this.melee.attacks[3]

		a.disabled = nil
		a.damage_min = s.damage[s.level]
		a.damage_max = s.damage[s.level]
		a.loops = s.loops[s.level]
	end

	s = this.hero.skills.tetsubostorm

	if initial and s.level > 0 then
		local a = this.melee.attacks[4]

		a.disabled = nil
		a.damage_min = s.damage[s.level]
		a.damage_max = s.damage[s.level]
	end

	s = this.hero.skills.monkeypalm

	if initial and s.level > 0 then
		local a = this.melee.attacks[5]

		a.disabled = nil

		local m = E:get_template(a.mod)

		m.modifier.duration = s.silence_duration[s.level]
		m.stun_duration = s.stun_duration[s.level]
	end

	s = this.hero.skills.angrygod

	if initial and s.level > 0 then
		a = this.timed_attacks.list[1]
		a.disabled = nil

		local m = E:get_template(a.mod)

		m.received_damage_factor = s.received_damage_factor[s.level]
	end

	s = this.hero.skills.divinenature

	if initial and s.level > 0 then
		local a = E:get_template("aura_monkey_god_divinenature")

		a.hps.heal_min = s.hp[s.level]
		a.hps.heal_max = s.hp[s.level]
		a.hps.heal_every = s.cooldown[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_monkey_god.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)

	if this.hero.skills.divinenature.level > 0 then
		local e = E:create_entity("aura_monkey_god_divinenature")

		e.aura.source_id = this.id
		e.aura.ts = store.tick_ts

		queue_insert(store, e)
	end

	return true
end

function scripts.hero_monkey_god.can_spinningpole(this, store, attack, target)
	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, attack.damage_radius, attack.vis_flags, attack.vis_bans)

	return targets and #targets >= attack.min_count
end

function scripts.hero_monkey_god.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta
	local cloud_trail = E:create_entity("ps_monkey_god_trail")

	cloud_trail.particle_system.track_id = this.id
	cloud_trail.particle_system.track_offset = V.v(0, 50)
	cloud_trail.particle_system.emit = false
	cloud_trail.particle_system.z = Z_OBJECTS

	queue_insert(store, cloud_trail)
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
				local r = this.nav_rally
				local cw = this.cloudwalk
				local force_cloudwalk = false

				for _, p in pairs(this.nav_grid.waypoints) do
					if GR:cell_is(p.x, p.y, bor(TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK)) then
						force_cloudwalk = true

						break
					end
				end

				if force_cloudwalk or V.dist(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > cw.min_distance then
					r.new = false

					U.unblock_target(store, this)

					local vis_bans = this.vis.bans

					this.vis.bans = F_ALL
					this.health.immune_to = F_ALL

					local original_speed = this.motion.max_speed

					this.motion.max_speed = this.motion.max_speed + cw.extra_speed
					this.unit.marker_hidden = true
					this.health_bar.hidden = true

					S:queue(this.sound_events.change_rally_point)
					S:queue(this.sound_events.cloud_start)
					SU.hide_modifiers(store, this, true)
					U.y_animation_play(this, cw.animations[1], r.pos.x < this.pos.x, store.tick_ts)
					SU.show_modifiers(store, this, true)
					S:queue(this.sound_events.cloud_loop)

					cloud_trail.particle_system.emit = true
					this.render.sprites[2].hidden = nil
					this.render.sprites[1].z = Z_BULLETS

					local ho = this.unit.hit_offset
					local mo = this.unit.mod_offset

					this.unit.hit_offset = cw.hit_offset
					this.unit.mod_offset = cw.mod_offset

					::label_433_0::

					local dest = r.pos
					local n = this.nav_grid

					while not V.veq(this.pos, dest) do
						local w = table.remove(n.waypoints, 1) or dest

						U.set_destination(this, w)

						local an, af = U.animation_name_facing_point(this, cw.animations[2], this.motion.dest)

						U.animation_start(this, an, af, store.tick_ts, true)

						while not this.motion.arrived do
							if r.new then
								r.new = false

								goto label_433_0
							end

							U.walk(this, store.tick_length)
							coroutine.yield()

							this.motion.speed.x, this.motion.speed.y = 0, 0
						end
					end

					cloud_trail.particle_system.emit = false

					S:stop(this.sound_events.cloud_loop)
					S:queue(this.sound_events.cloud_end, this.sound_events.cloud_end_args)
					SU.hide_modifiers(store, this, true)
					U.y_animation_play(this, cw.animations[3], nil, store.tick_ts)
					SU.show_modifiers(store, this, true)

					this.render.sprites[1].z = Z_OBJECTS
					this.render.sprites[2].hidden = true
					this.motion.max_speed = original_speed
					this.vis.bans = vis_bans
					this.health.immune_to = 0
					this.unit.marker_hidden = nil
					this.health_bar.hidden = nil
					this.unit.hit_offset = ho
					this.unit.mod_offset = mo
				elseif SU.y_hero_new_rally(store, this) then
					goto label_433_2
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.angrygod

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				if U.get_blocked(store, this) and U.is_blocked_valid(store, this) then
					SU.delay_attack(store, a, 0.3333333333333333)
				else
					local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

					if not targets or #targets < a.min_count then
						SU.delay_attack(store, a, 0.2)
					else
						S:queue(a.sound_start)
						U.y_animation_play(this, a.animations[1], nil, store.tick_ts, 1)

						local loop_ts = store.tick_ts

						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)
						S:queue(a.sound_loop)

						for i = 1, a.loops do
							U.animation_start(this, a.animations[2], nil, store.tick_ts, false)

							local targets = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

							if targets then
								for _, target in pairs(targets) do
									local m = E:create_entity(a.mod)

									m.modifier.target_id = target.id
									m.modifier.source_id = this.id
									m.modifier.duration = m.modifier.duration + U.frandom(-0.15, 0.15)
									m.render.sprites[1].ts = store.tick_ts

									queue_insert(store, m)
								end
							end

							while not U.animation_finished(this) do
								if SU.hero_interrupted(this) then
									goto label_433_1
								end

								coroutine.yield()
							end
						end

						::label_433_1::

						S:stop(a.sound_loop)
						U.y_animation_play(this, a.animations[3], nil, store.tick_ts, 1)

						goto label_433_2
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

		::label_433_2::

		coroutine.yield()
	end
end

scripts.mod_monkey_god_palm = {}

function scripts.mod_monkey_god_palm.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target and not target.health.dead then
		local sm = E:create_entity(this.stun_mod)

		sm.modifier.target_id = target.id
		sm.modifier.source_id = this.id
		sm.modifier.duration = this.stun_duration

		queue_insert(store, sm)

		if band(target.vis.flags, F_SPELLCASTER) ~= 0 then
			target.enemy.can_do_magic = false
			target.enemy.can_accept_magic = false

			local s = this.render.sprites[1]

			s.ts = store.tick_ts

			if target.unit and target.unit.mod_offset then
				s.offset.x = target.unit.mod_offset.x
				s.offset.y = target.unit.mod_offset.y
			end

			local s_offset = this.custom_offsets[target.template_name] or this.custom_offsets.default

			if s_offset then
				s.offset.x = s.offset.x + s_offset.x
				s.offset.y = s.offset.y + s_offset.y
			end

			s.offset.x = (target.render.sprites[1].flip_x and -1 or 1) * s.offset.x

			signal.emit("mod-applied", this, target)

			return true
		end
	end

	return false
end

function scripts.mod_monkey_god_palm.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target and target.enemy then
		target.enemy.can_do_magic = true
		target.enemy.can_accept_magic = true
	end

	return true
end

scripts.hero_voodoo_witch = {}

function scripts.hero_voodoo_witch.get_info(this)
	local a = this.melee.attacks[1]
	local min, max = a.damage_min, a.damage_max

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

function scripts.hero_voodoo_witch.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	local a = this.melee.attacks[1]

	a.damage_max = ls.damage_max[hl]
	a.damage_min = ls.damage_min[hl]

	local b = E:get_template("bolt_voodoo_witch")

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	local s

	s = this.hero.skills.laughingskulls

	if initial and s.level > 0 then
		local b = E:get_template("bolt_voodoo_witch_skull")

		b.bullet.damage_min = b.bullet.damage_min + s.extra_damage[s.level]
		b.bullet.damage_max = b.bullet.damage_max + s.extra_damage[s.level]
	end

	s = this.hero.skills.deathskull

	if initial and s.level > 0 then
		local sk = E:get_template("voodoo_witch_skull")

		sk.sacrifice.disabled = nil
		sk.sacrifice.damage = s.damage[s.level]
	end

	s = this.hero.skills.bonedance

	if initial and s.level > 0 then
		local a = E:get_template("voodoo_witch_skull_aura")

		a.skull_count = s.skull_count[s.level]

		local sp = E:get_template("mod_voodoo_witch_skull_spawn")

		sp.skull_count = s.skull_count[s.level]
	end

	s = this.hero.skills.deathaura

	if initial and s.level > 0 then
		local m = E:get_template("mod_voodoo_witch_aura_slow")

		m.slow.factor = s.slow_factor[s.level]
	end

	s = this.hero.skills.voodoomagic

	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage = s.damage[s.level]
	end

	this.health.hp = this.health.hp_max
end

function scripts.hero_voodoo_witch.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.ranged.order = U.attack_order(this.ranged.attacks)
	this.melee.order = U.attack_order(this.melee.attacks)

	if this.hero.skills.deathaura.level > 0 then
		local e = E:create_entity("voodoo_witch_death_aura")

		e.aura.source_id = this.id
		e.aura.ts = store.tick_ts

		queue_insert(store, e)
	end

	local e = E:create_entity("voodoo_witch_skull_aura")

	e.aura.source_id = this.id
	e.aura.ts = store.tick_ts

	queue_insert(store, e)

	return true
end

function scripts.hero_voodoo_witch.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		SU.alliance_merciless_upgrade(store,this)
		SU.alliance_corageous_upgrade(store,this)

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_439_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.voodoomagic

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local targets_in_range = U.find_enemies_in_range(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets_in_range then
					SU.delay_attack(store, a, 0.26666666666666666)
				else
					local targets_per_type = {}

					for _, t in pairs(store.entities) do
						if t and t.enemy and t.health and not t.health.dead then
							if not targets_per_type[t.template_name] then
								targets_per_type[t.template_name] = {
									t
								}
							else
								table.insert(targets_per_type[t.template_name], t)
							end
						end
					end

					local targets

					for _, t in pairs(targets_in_range) do
						local v = targets_per_type[t.template_name]

						if v and #v >= a.min_count then
							targets = v

							break
						end
					end

					if not targets then
						SU.delay_attack(store, a, 0.26666666666666666)
					else
						table.sort(targets, function(e1, e2)
							return V.dist(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) < V.dist(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
						end)

						targets = table.slice(targets, 1, a.count)

						S:queue(a.sound)
						U.animation_start(this, a.animation, nil, store.tick_ts)

						local start_ts = store.tick_ts

						while store.tick_ts - start_ts < fts(10) do
							if SU.hero_interrupted(this) then
								goto label_439_0
							end

							coroutine.yield()
						end

						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						for _, t in pairs(targets) do
							if not t.health.dead and store.entities[t.id] then
								local m = E:create_entity(a.mod_fx)

								m.modifier.target_id = t.id
								m.modifier.source_id = this.id

								queue_insert(store, m)
							end
						end

						U.y_wait(store, fts(16))

						for _, t in pairs(targets) do
							if not t.health.dead and store.entities[t.id] then
								local d = E:create_entity("damage")

								d.source_id = this.id
								d.target_id = t.id
								d.value = a.damage
								d.damage_type = a.damage_type

								queue_damage(store, d)

								local m = E:create_entity(a.mod_slow)

								m.modifier.target_id = t.id
								m.modifier.source_id = this.id

								queue_insert(store, m)
							end
						end

						while not U.animation_finished(this) do
							if SU.hero_interrupted(this) then
								break
							end

							coroutine.yield()
						end

						goto label_439_0
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

		::label_439_0::

		coroutine.yield()
	end
end

scripts.voodoo_witch_skull_aura = {}

function scripts.voodoo_witch_skull_aura.update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local last_ts = store.tick_ts
	local source = store.entities[a.source_id]
	local rot_phase = 0

	this.pos = source.pos

	local last_pos = V.vclone(this.pos)

	while true do
		if not source.health.dead and store.tick_ts - last_ts >= a.cycle_time then
			last_ts = store.tick_ts

			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, target in pairs(targets) do
					local m = E:create_entity("mod_voodoo_witch_skull_spawn")

					m.modifier.source_id = this.id
					m.modifier.target_id = target.id

					queue_insert(store, m)
				end
			end
		end

		if V.veq(source.pos, last_pos) then
			rot_phase = rot_phase + this.rot_speed * store.tick_length
		end

		last_pos.x, last_pos.y = this.pos.x, this.pos.y

		for i, t in ipairs(this.skulls) do
			local a = (i * 2 * math.pi / #this.skulls + rot_phase) % (2 * math.pi)

			t.rot_dest = U.point_on_ellipse(this.pos, this.rot_radius, a)
			t.rot_flip = source.render.sprites[1].flip_x
		end

		coroutine.yield()
	end
end

scripts.mod_voodoo_witch_skull_spawn = {}

function scripts.mod_voodoo_witch_skull_spawn.update(this, store)
	this.modifier.ts = store.tick_ts

	local cg = store.count_groups[this.count_group_type]

	while true do
		local target = store.entities[this.modifier.target_id]

		if not target or store.tick_ts - this.modifier.ts > this.modifier.duration then
			break
		end

		if target.health.dead and (not cg[this.count_group_name] or cg[this.count_group_name] < this.skull_count) then
			local s = E:create_entity("voodoo_witch_skull")

			s.owner_id = this.modifier.source_id
			s.spawner_id = target.id

			queue_insert(store, s)

			break
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.voodoo_witch_skull = {}

function scripts.voodoo_witch_skull.update(this, store)
	local spawner = store.entities[this.spawner_id]
	local owner = store.entities[this.owner_id]

	if not owner or not spawner then
		log.debug("no owner or spawner. removing skull")
		queue_remove(store, this)

		return
	end

	table.insert(owner.skulls, this)

	this.pos = V.vclone(spawner.pos)

	local hero = store.entities[owner.aura.source_id]
	local skill = hero.hero.skills[this.sacrifice.xp_from_skill]
	local s = this.render.sprites[1]

	s.offset.x = spawner.unit.mod_offset.x
	s.offset.y = spawner.unit.mod_offset.y

	local fm = this.force_motion
	local fl_dh = this.max_flight_height - this.min_flight_height
	local fl_h = this.min_flight_height + fl_dh / 2
	local fl_step = this.flight_speed * store.tick_length
	local fl_dest = fl_h
	local ps = E:create_entity("ps_voodoo_witch_skull")

	ps.particle_system.track_id = this.id
	ps.particle_system.emit = false
	ps.particle_system.track_offset = V.v(s.offset.x, s.offset.y)

	queue_insert(store, ps)

	local function move_step(dest, bob)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local df = (not fm.ramp_radius or dist > fm.ramp_radius) and 1 or math.max(dist / fm.ramp_radius, 0.1)

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step * df, dx, dy)))
		fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
		fm.v.x, fm.v.y = V.trim(fm.max_v, fm.v.x, fm.v.y)

		local sx, sy = V.mul(store.tick_length, fm.v.x, fm.v.y)

		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
		fm.a.x, fm.a.y = V.mul(-0.05 / store.tick_length, fm.v.x, fm.v.y)

		if bob then
			fl_dest = fl_h + 0.5 * fl_dh * math.sin(2 * math.pi * store.tick_ts / this.flight_period)
		end

		if math.abs(fl_dest - s.offset.y) < fl_step then
			s.offset.y = fl_dest
		else
			s.offset.y = s.offset.y + (fl_dest > s.offset.y and 1 or -1) * fl_step
		end

		ps.particle_system.track_offset.x = s.offset.x
		ps.particle_system.track_offset.y = s.offset.y

		return dist < fm.max_v * store.tick_length
	end

	while true do
		if hero.health.dead then
			break
		end

		if this.max_shots <= 0 then
			local sa = this.sacrifice

			if sa.disabled then
				break
			end

			local target = U.find_nearest_enemy(store.entities, this.pos, sa.min_range, sa.max_range, sa.vis_flags, sa.vis_bans)

			if not target then
				-- block empty
			else
				S:queue(sa.sound)

				fm.max_v = sa.max_v
				fm.max_a = sa.max_a
				fm.ramp_radius = nil
				fm.a_step = sa.a_step
				fl_dest = target.unit.hit_offset.y
				ps.particle_system.emit = true

				while not move_step(target.pos, false) do
					s.flip_x = this.pos.x > target.pos.x

					coroutine.yield()
				end

				S:queue(sa.sound_hit)

				local d = E:create_entity("damage")

				d.value = sa.damage
				d.source_id = this.id
				d.target_id = target.id
				d.damage_type = sa.damage_type

				queue_damage(store, d)

				if hero and skill then
					SU.hero_gain_xp_from_skill(hero, skill)
				end

				break
			end
		end

		local a = this.ranged.attacks[1]

		if store.tick_ts - a.ts > a.cooldown then
			local target = U.find_nearest_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if not target then
				-- block empty
			else
				a.ts = store.tick_ts

				local an, af, ai = U.animation_name_facing_point(this, a.animation, target.pos)

				U.animation_start(this, an, af, store.tick_ts, false)
				S:queue(a.sound)

				while store.tick_ts - a.ts < a.shoot_time do
					move_step(this.rot_dest, true)
					coroutine.yield()
				end

				local b = E:create_entity(a.bullet)

				b.pos.x, b.pos.y = this.pos.x, this.pos.y + this.render.sprites[1].offset.y
				b.bullet.from = V.vclone(b.pos)
				b.bullet.to = V.vclone(target.pos)
				b.bullet.to.x = b.bullet.to.x + target.unit.hit_offset.x
				b.bullet.to.y = b.bullet.to.y + target.unit.hit_offset.y
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id
				b.render.sprites[1].scale.x = 0.75
				b.render.sprites[1].scale.y = 0.75
				b.bullet.xp_dest_id = hero.id

				queue_insert(store, b)

				this.max_shots = this.max_shots - 1

				while not U.animation_finished(this) do
					move_step(this.rot_dest, true)
					coroutine.yield()
				end
			end
		end

		U.animation_start(this, "idle", this.rot_flip, store.tick_ts, true)
		move_step(this.rot_dest, true)
		coroutine.yield()
	end

	table.removeobject(owner.skulls, this)

	s.hidden = true

	local fx = E:create_entity("fx_voodoo_witch_skull_explosion")

	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y + this.render.sprites[1].offset.y
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	if ps.particle_system.emit then
		ps.particle_system.emit = false

		U.y_wait(store, ps.particle_system.particle_lifetime[2])
	end

	queue_remove(store, this)
end

scripts.voodoo_witch_death_aura = {}

function scripts.voodoo_witch_death_aura.update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local last_ts = store.tick_ts
	local source = store.entities[a.source_id]
	local inflicted_damage = 0

	this.pos = source.pos

	while true do
		if not source.health.dead and store.tick_ts - last_ts >= a.cycle_time then
			last_ts = store.tick_ts

			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, target in pairs(targets) do
					local d = E:create_entity("damage")

					d.damage_type = a.damage_type
					d.value = a.damage
					d.target_id = target.id
					d.source_id = this.id

					queue_damage(store, d)

					inflicted_damage = inflicted_damage + a.damage

					local m = E:create_entity(this.mod_slow)

					m.modifier.source_id = this.id
					m.modifier.target_id = target.id
					m.render.sprites[1].name = m.render.sprites[1].size_names[target.unit.size]
					m.render.sprites[1].flip_x = target.render.sprites[1].flip_x
					m.tween.ts = store.tick_ts

					queue_insert(store, m)
				end
			end
		end

		if inflicted_damage * a.xp_gain_factor > 1 then
			SU.hero_gain_xp(source, inflicted_damage * a.xp_gain_factor, this.template_name)

			inflicted_damage = 0
		end

		this.render.sprites[1].hidden = source.health.dead
		this.render.sprites[2].hidden = source.health.dead

		coroutine.yield()
	end
end

scripts.mod_voodoo_witch_magic = {}

function scripts.mod_voodoo_witch_magic.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	this.render.sprites[1].ts = store.tick_ts
	this.render.sprites[1].flip_x = not target.render.sprites[1].flip_x

	return true
end

scripts.hero_dwarf = {}

function scripts.hero_dwarf.insert(this, store, script)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.hero_dwarf.update(this, store, script)
	local h = this.health
	local he = this.hero
	local brk, sta
	
	local switch = this.timed_attacks.list[1]
	switch.ts = store.tick_ts

	local function go_big()
		SU.remove_modifiers(store, this)
		this.health_bar.offset = this.health_bar.offset_big
		this.unit.mod_offset.x, this.unit.mod_offset.y = this.mod_offset_big.x, this.mod_offset_big.y
		this.unit.hit_offset.x, this.unit.hit_offset.y = this.hit_offset_big.x, this.hit_offset_big.y
		this.soldier.melee_slot_offset.x = this.melee_slot_offset_x_big
		this.melee.attacks[1].damage_max = this.melee.attacks[1].damage_max + switch.damage_inc
		this.melee.attacks[1].damage_min = this.melee.attacks[1].damage_min + switch.damage_inc
		this.melee.attacks[2].hit_offset = this.melee.attacks[2].hit_offset_big
		this.health.armor = this.health.armor + switch.armor_inc
		U.animation_start(this, "idle", nil, store.tick_ts, 1)
		local decal = E:create_entity(switch.decal)
		decal.pos = this.pos
		decal.render.sprites[1] = table.deepclone(this.render.sprites[1])
		decal.render.sprites[1].name = "levelup"
		queue_insert(store, decal)
		decal.tween.disabled = nil
		decal.tween.ts = store.tick_ts
		U.y_wait(store, fts(1))
		this.render.sprites[1].hidden = true
		U.y_wait(store, (#decal.tween.props[1].keys - 2) * fts(1))
		this.render.sprites[1].prefix = "big_hero_dwarf"
		this.render.sprites[1].hidden = nil
		switch.ts = store.tick_ts
		this.is_big = true
		local hp = this.health.hp + switch.hp_inc
		this.health.hp = hp < this.health.hp_max and hp or this.health.hp_max
	end

	local function go_normal()
		SU.remove_modifiers(store, this)
		this.health_bar.offset = this.health_bar.offset_normal
		this.unit.mod_offset.x, this.unit.mod_offset.y = this.mod_offset_normal.x, this.mod_offset_normal.y
		this.unit.hit_offset.x, this.unit.hit_offset.y = this.hit_offset_normal.x, this.hit_offset_normal.y
		this.soldier.melee_slot_offset.x = this.melee_slot_offset_x_normal
		this.melee.attacks[1].damage_max = this.melee.attacks[1].damage_max - switch.damage_inc
		this.melee.attacks[1].damage_min = this.melee.attacks[1].damage_min - switch.damage_inc
		this.melee.attacks[2].hit_offset = this.melee.attacks[2].hit_offset_normal
		this.health.armor = this.health.armor - switch.armor_inc
		U.animation_start(this, "idle", nil, store.tick_ts, 1)
		local decal = E:create_entity(switch.decal)
		decal.pos = this.pos
		decal.render.sprites[1] = table.deepclone(this.render.sprites[1])
		decal.render.sprites[1].prefix = "hero_dwarf"
		decal.render.sprites[1].name = "idle"
		queue_insert(store, decal)
		decal.tween.reverse = true
		decal.tween.disabled = nil
		decal.tween.ts = store.tick_ts
		U.y_wait(store, fts(1))
		this.render.sprites[1].hidden = true
		U.y_wait(store, (#decal.tween.props[1].keys - 2) * fts(1))
		this.render.sprites[1].prefix = "hero_dwarf"
		this.render.sprites[1].hidden = nil
		switch.ts = store.tick_ts
		this.is_big = nil
		this.health.hp = this.health.hp_max < this.health.hp and this.health.hp_max or this.health.hp
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			if this.is_big then
				go_normal()
			end
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_448_0
				end
			end

			SU.alliance_merciless_upgrade(store, this)
			SU.alliance_corageous_upgrade(store, this)

			if not this.is_big and not switch.disabled and store.tick_ts - switch.ts >= switch.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, switch.range, switch.vis_flags, switch.vis_bans)

				if targets and #targets >= switch.min_count then
					go_big()
				end
			elseif this.is_big and store.tick_ts - switch.ts >= switch.duration then
				go_normal()
			end

			if this.melee then
				brk, sta = y_hero_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_448_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_448_0::

		coroutine.yield()
	end
end

scripts.hero_steam_frigate = {}

function scripts.hero_steam_frigate.get_info(this)
	local b = E:get_template("steam_frigate_barrel")
	local min, max = b.bullet.damage_min, b.bullet.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor
	}
end

function scripts.hero_steam_frigate.insert(this, store, script)
	return true
end

function scripts.hero_steam_frigate.update(this, store, script)
	local h = this.health
	local he = this.hero
	local ba = this.ranged.attacks[1]
	local ma = this.timed_attacks.list[1]
	local smoke_sprite = this.render.sprites[3]
	local throw_min_dist_x = 29
	local mines_alive = {}

	local function get_mine_targets()
		return P:get_all_valid_pos(this.pos.x, this.pos.y, ma.min_range, ma.max_range, ma.valid_terrains, function(x, y)
			return math.abs(this.pos.x - x) > throw_min_dist_x
		end)
	end

	local mine_targets = get_mine_targets()

	while true do
		mines_alive = table.filter(mines_alive, function(_, m)
			return store.entities[m.id] ~= nil
		end)

		while this.nav_rally.new do
			if SU.y_hero_new_rally(store, this) then
				goto label_451_0
			end

			mine_targets = get_mine_targets()
		end

		if store.tick_ts - ba.ts > ba.cooldown then
			local enemy, _, pred_pos = U.find_foremost_enemy(store.entities, this.pos, ba.min_range, ba.max_range, ba.node_prediction, ba.vis_flags, ba.vis_bans, function(entity)
				return math.abs(this.pos.x - entity.pos.x) > throw_min_dist_x
			end)

			if enemy then
				local start_ts = store.tick_ts
				local an, af, ai = U.animation_name_facing_point(this, ba.animation, pred_pos)

				U.animation_start(this, an, af, store.tick_ts)

				while store.tick_ts - start_ts < ba.shoot_time do
					if this.nav_rally.new then
						goto label_451_0
					end

					if this.health.dead then
						goto label_451_0
					end

					if this.unit.is_stunned then
						goto label_451_0
					end

					coroutine.yield()
				end

				ba.ts = start_ts

				local b = E:create_entity(ba.bullet)
				local offset = ba.bullet_start_offset[1]

				b.pos.x, b.pos.y = this.pos.x + (af and -1 or 1) * offset.x, this.pos.y + offset.y
				b.bullet.from = V.vclone(b.pos)
				b.bullet.to = pred_pos
				b.bullet.target_id = enemy.id

				queue_insert(store, b)

				while not U.animation_finished(this) do
					if this.nav_rally.new then
						goto label_451_0
					end

					if this.health.dead then
						goto label_451_0
					end

					if this.unit.is_stunned then
						goto label_451_0
					end

					coroutine.yield()
				end
			end
		end

		if store.tick_ts - ma.ts > ma.cooldown and #mines_alive < ma.max_mines and #mine_targets > 0 then
			local start_ts = store.tick_ts
			local target_pos = mine_targets[math.random(1, #mine_targets)]
			local an, af = U.animation_name_facing_point(this, ma.animation, target_pos)

			U.animation_start(this, an, af, store.tick_ts, false)

			while store.tick_ts - start_ts < ma.shoot_time do
				if this.nav_rally.new then
					goto label_451_0
				end

				if this.health.dead then
					goto label_451_0
				end

				if this.unit.is_stunned then
					goto label_451_0
				end

				coroutine.yield()
			end

			ma.ts = start_ts

			local m = E:create_entity(ma.bullet)
			local offset = ma.bullet_start_offset[1]

			m.pos.x, m.pos.y = this.pos.x + (af and -1 or 1) * offset.x, this.pos.y + offset.y
			m.bullet.from = V.vclone(m.pos)
			m.bullet.to = target_pos

			queue_insert(store, m)
			table.insert(mines_alive, m)

			while not U.animation_finished(this) do
				if this.nav_rally.new then
					goto label_451_0
				end

				if this.health.dead then
					goto label_451_0
				end

				if this.unit.is_stunned then
					goto label_451_0
				end

				coroutine.yield()
			end
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true)

		::label_451_0::

		coroutine.yield()
	end
end

scripts.steam_frigate_mine = {}

function scripts.steam_frigate_mine.update(this, store, script)
	local b = this.bullet

	this.lifespan.ts = store.tick_ts

	while store.tick_ts - b.ts < b.flight_time do
		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)
		this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length

		coroutine.yield()
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y

	S:queue("SpecialMermaid")

	this.render.sprites[1].hidden = true
	this.render.sprites[2].hidden = false

	U.y_animation_play(this, "splash", nil, store.tick_ts, 1, 2)
	U.animation_start(this, "idle", nil, store.tick_ts, -1, 2)

	while store.tick_ts - this.lifespan.ts < this.lifespan.duration do
		coroutine.yield()

		if U.find_enemies_in_range(store.entities, this.pos, 0, this.trigger_radius, b.vis_flags, b.vis_bans) then
			local fx

			if GR:cell_is(this.pos.x, this.pos.y, TERRAIN_WATER) then
				S:queue(this.sound_events.hit_water)

				fx = E:create_entity("fx_explosion_water")
			else
				S:queue(this.sound_events.hit)

				fx = E:create_entity("fx_explosion_fragment")
			end

			fx.pos = V.vclone(this.pos)
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)

			local enemies = U.find_enemies_in_range(store.entities, this.pos, 0, b.damage_radius, b.damage_flags, b.damage_bans)

			for _, enemy in pairs(enemies) do
				local d = E:create_entity("damage")

				d.damage_type = b.damage_type
				d.value = math.ceil(U.frandom(b.damage_min, b.damage_max))
				d.source_id = this.id
				d.target_id = enemy.id

				queue_damage(store, d)
			end

			queue_remove(store, this)

			return
		end
	end

	U.y_animation_play(this, "sink", nil, store.tick_ts, 1, 2)
	queue_remove(store, this)
end

scripts.hero_vampiress = {}

function scripts.hero_vampiress.insert(this, store, script)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.hero_vampiress.update(this, store, script)
	local h = this.health
	local he = this.hero
	local r = this.nav_rally
	local brk, sta, should_fly, already_flying
	local orig_prefix = this.render.sprites[1].prefix
	local orig_vis_bans = this.vis.bans
	local orig_speed = this.motion.max_speed

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while r.new do
				if not already_flying then
					should_fly = V.dist(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > this.fly_to.min_distance

					if should_fly then
						already_flying = true
						this.vis.bans = F_ALL
						this.health.ignore_damage = true
						this.render.sprites[1].prefix = this.fly_to.animation_prefix
						this.render.sprites[2].hidden = false
						this.motion.max_speed = this.motion.max_speed_bat

						U.animation_start(this, "enter", nil, store.tick_ts)
						U.y_wait(store, fts(7))

						local fx = E:create_entity("fx_vampiress_transform")

						fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
						fx.render.sprites[1].ts = store.tick_ts

						queue_insert(store, fx)
						U.y_animation_wait(this)
					end
				end

				if SU.y_hero_new_rally(store, this) then
					goto label_458_0
				end

				if already_flying and not r.new then
					already_flying = nil
					this.render.sprites[2].hidden = true

					U.y_animation_play(this, "exit", nil, store.tick_ts, 1)

					this.render.sprites[1].prefix = orig_prefix
					this.motion.max_speed = orig_speed
					this.vis.bans = orig_vis_bans
					this.health.ignore_damage = false
				end
			end

			a = this.timed_attacks.list[1]

			if store.tick_ts - a.ts > a.cooldown then
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.trigger_radius, a.vis_flags, a.vis_bans)

				if not targets then
					SU.delay_attack(store, a, 0.13333333333333333)
				else
					local start_ts = store.tick_ts

					S:queue(a.sound)
					U.animation_start(this, a.animation, nil, store.tick_ts, false)

					while store.tick_ts - start_ts < a.hit_time do
						if SU.hero_interrupted(this) then
							goto label_458_0
						end

						coroutine.yield()
					end

					targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius, a.vis_flags, a.vis_bans)

					if targets then
						for _, e in pairs(targets) do
							local d = E:create_entity("damage")

							d.source_id = this.id
							d.target_id = e.id
							d.value = math.random(a.damage_min, a.damage_max)
							d.damage_type = a.damage_type

							if table.contains(a.extra_damage_templates, e.template_name) then
								d.value = d.value * a.extra_damage_factor
							end

							queue_damage(store, d)
						end
					end

					a.ts = store.tick_ts

					while not U.animation_finished(this) do
						if SU.hero_interrupted(this) then
							goto label_458_0
						end

						coroutine.yield()
					end
				end
			end

			if this.melee then
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_458_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
				-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_458_0::

		coroutine.yield()
	end
end

return scripts