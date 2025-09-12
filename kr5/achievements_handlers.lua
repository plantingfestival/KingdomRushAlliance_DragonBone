local log = require("klua.log"):new("achievements_handlers")
local signal = require("hump.signal")
local bit = require("bit")
local E = require("entity_db")
local GS = require("game_settings")
local storage = require("storage")
local P = require("path_db")
local U = require("utils")
local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local special_templates = {
	"tower_arcane",
	"tower_silver",
	"tower_wild_magus",
	"tower_high_elven",
	"tower_druid",
	"tower_entwood",
	"tower_blade",
	"tower_forest"
}
local ah = {}

function ah:register_handlers(A)
	self.A = A

	local function reg(name, fn)
		signal.register(name, function(...)
			fn(ah, ...)
		end)
	end

	reg("boss-killed", ah.h_boss_killed)
	reg("count-group-changed", ah.h_count_group_changed)
	reg("early-wave-called", ah.h_early_wave_called)
	reg("entity-damaged", ah.h_entity_damaged)
	reg("entity-killed", ah.h_entity_killed)
	reg("game-victory", ah.h_game_victory)
	reg("hero-level-increased", ah.h_hero_level_increased)
	reg("mod-applied", ah.h_mod_applied)
	reg("notification-shown", ah.h_notification_shown)
	reg("power-used", ah.h_power_used)
	reg("tower-upgraded", ah.h_tower_upgraded)
	reg("next-wave-sent", ah.h_next_wave_sent)
	reg("achievements_custom_event", ah.h_custom_event)
	reg("tower-spawn", ah.h_tower_spawn)
	reg("spawned-reinforcement", ah.h_spawned_reinforcement)
	reg("robin-stage01", ah.h_robin_stage01)
	reg("bonfire-stage01", ah.h_bonfire_stage01)
	reg("link-stage02", ah.h_link_stage02)
	reg("lion_king-stage02", ah.h_lion_king_stage02)
	reg("heartless-stage03", ah.h_heartless_stage03)
	reg("playful_friends-stage03", ah.h_playful_friends_stage03)
	reg("most_delicious-stage03", ah.h_most_delicious_stage03)
	reg("arboreans-stage04", ah.h_arboreans_stage04)
	reg("rubble-stage05", ah.h_rubble_stage05)
	reg("door-stage06", ah.h_door_stage06)
	reg("minecraft-stage06", ah.h_minecraft_stage06)
	reg("no_jump_boss-stage06", ah.h_no_jump_boss_stage06)
	reg("crows-stage07", ah.h_crows_stage07)
	reg("witcher-stage07", ah.h_witcher_stage07)
	reg("elves-stage08", ah.h_elves_stage08)
	reg("baskets-stage08", ah.h_baskets_stage8)
	reg("portal_not_spawned-stage09", ah.h_portal_not_spawned_stage09)
	reg("ymca-stage10", ah.h_ymca_stage10)
	reg("lotr-stage11", ah.h_lotr_stage11)
	reg("no_projections_bossfight-stage11", ah.h_no_projections_bossfight_stage11)
	reg("stranger_things-stage12", ah.h_stranger_things_stage12)
	reg("sunray_kills-stage13", ah.h_sunray_kills_stage13)
	reg("no_amalgams_spawned-stage14", ah.h_no_amalgams_spawned_stage14)
	reg("rickmorty-stage14", ah.h_rickmorty_stage14)
	reg("no_soldiers_grabbed-stage15", ah.h_no_soldiers_grabbed_stage15)
	reg("goblintap-stage15", ah.h_goblintap_stage15)
	reg("tree-hugger-stage17", ah.h_tree_hugger_stage17)
	reg("rock-paper-scissors-stage19", ah.h_rock_paper_scissors_stage19)
	reg("no-anim-armored-respawn", ah.h_no_anim_armored_respawn)
	reg("no-flowers-lost-stage20", ah.h_no_flowers_lost_stage20)
	reg("boat-croc-stage21", ah.h_boat_croc_stage21)
	reg("flying-king-croc-stage22", ah.h_flying_king_croc_stage22)
	reg("cheshine-cat-terrain4", ah.h_cheshine_cat_terrain_4)
	reg("sheepy_tap_achievement", ah.h_sheepy_tap)
	reg("crane-stage23", ah.h_crane_stage23)
	reg("factory-stage24", ah.h_factory_stage24)
	reg("fist-stage25", ah.h_fist_stage25)
	reg("snake-stage25", ah.h_snake_stage25)
	reg("mewtwo-stage26", ah.h_mewtwo_stage26)
	reg("workers-stage27", ah.h_workers_stage27)
	reg("exodia-terrain6", ah.h_exodia_terrain_6)
	reg("head-stage27", ah.h_head_stage27)
	reg("spiders-into-the-ogreverse", ah.h_into_the_ogreverse)
	reg("spiders-a-coon-of-surprises", ah.h_a_coon_of_surprises)
	reg("spiders-lucas-spider", ah.h_lucas_spider)
end

function ah:h_custom_event(event)
	local current_runes = self.A:get_count("RUNEQUEST")

	if event == "RUNEQUEST_1" then
		self.A:flag_check("RUNEQUEST", bit.bor(current_runes, 1))
	elseif event == "RUNEQUEST_2" then
		self.A:flag_check("RUNEQUEST", bit.bor(current_runes, 2))
	elseif event == "RUNEQUEST_3" then
		self.A:flag_check("RUNEQUEST", bit.bor(current_runes, 4))
	elseif event == "RUNEQUEST_4" then
		self.A:flag_check("RUNEQUEST", bit.bor(current_runes, 8))
	elseif event == "RUNEQUEST_5" then
		self.A:flag_check("RUNEQUEST", bit.bor(current_runes, 16))
	elseif event == "RUNEQUEST_6" then
		self.A:flag_check("RUNEQUEST", bit.bor(current_runes, 32))
	end
end

function ah:h_boss_killed(entity)
	if entity.template_name == "boss_pig" then
		self.A:got("PORKS_OFF_THE_MENU")
	elseif entity.template_name == "boss_corrupted_denas" then
		self.A:got("CLEANSE_THE_KING")
	elseif entity.template_name == "boss_cult_leader" then
		self.A:got("BYE_BYE_BEAUTIFUL")
	elseif entity.template_name == "controller_stage_16_overseer" then
		self.A:got("CONJUNTIVICTORY")
	elseif entity.template_name == "boss_navira" then
		self.A:got("SPECTRAL_FURY")
	elseif entity.template_name == "boss_crocs_lvl5" then
		self.A:got("SEE_YA_LATER_ALLIGATOR")
	elseif entity.template_name == "boss_grymbeard" then
		self.A:got("DLC1_WIN_BOSS")
	elseif entity.template_name == "boss_spider_queen" then
		self.A:got("ARACHNED")
	end
end

function ah:h_count_group_changed(entity, group_count, increment)
	-- if entity.count_group.name == "mod_arrow_silver_mark" and increment > 0 then
	-- 	self.A:high_check("VALAR_MORGHULIS", group_count)
	-- elseif entity.count_group.name == "soldier_druid_bear" and increment > 0 then
	-- 	self.A:high_check("BEORNINGS", group_count)
	-- end
end

function ah:h_early_wave_called(group, reward, remaining_time)
	self.A:inc_check("NOT_A_MOMENT_TO_WASTE")
end

function ah:h_entity_damaged(entity, damage)
	-- if damage and damage.source_id then
	-- 	local s = game.store.entities[damage.source_id]

	-- 	if s and s.template_name == "ray_druid_sylvan" then
	-- 		self.A:inc_check("NOPAINGAIN", damage.value)
	-- 	end
	-- end
end

function ah:h_entity_killed(entity, damage)
	if not entity then
		log.debug("nil entity")

		return
	end

	if U.has_modifiers(game.store, entity, "mod_glare") then
		self.A:inc_check("TURN_A_BLIND_EYE", 1)
	end

	if entity.template_name == "enemy_blinker" then
		self.A:inc_check("ALL_THE_SMALL_THINGS")
	elseif entity.template_name == "enemy_lesser_sister" then
		if entity.spawned_nightmares == 0 then
			self.A:inc_check("WE_RE_NOT_GONNA_TAKE_IT")
		end
	elseif entity.template_name == "enemy_unblinded_priest" then
		self.A:inc_check("PROMOTION_DENIED")
	elseif entity.template_name == "enemy_glareling" then
		self.A:inc_check("PEST_CONTROL")
	elseif entity.template_name == "enemy_crocs_basic_egg" then
		self.A:inc_check("SCRAMBLED_EGGS")
	elseif entity.template_name == "enemy_mad_tinkerer" then
		if entity.spawned_drones == 0 then
			self.A:inc_check("GARBAGE_DISPOSAL")
		end
	elseif string.find(entity.template_name, "enemy_ballooning_spider") and U.flag_has(entity.vis.flags, F_FLYING) then
		self.A:inc_check("NO_FLY_ZONE")
	end

	if entity.hero then
		entity._death_count = (entity._death_count or 0) + 1
	end

	if entity.soldier and (entity.hero or true) then
		-- block empty
	elseif entity.enemy then
		self.A:inc_check("MIGHTY_I", 1)
		self.A:inc_check("MIGHTY_II", 1)
		self.A:inc_check("MIGHTY_III", 1)

		if entity.enemy.gold > 0 then
			self.A:inc_check("UNENDING_RICHES", entity.enemy.gold)
		end
	end

	if damage and damage.source_id then
		local s = game.store.entities[damage.source_id]

		if s then
			if entity.hero then
				if s.template_name == "enemy_ettin" then
					self.A:inc("BRAVE_TAILOR")
				end
			elseif s.template_name == "bullet_stage_03_heart_of_the_arborean" then
				self.A:inc_check("NATURES_WRATH")
				log.info("KILLED WITH HEART")
			elseif entity.enemy then
				if s.template_name == "bolt_plant_magic_blossom" then
					self.A:inc_check("GATHERING_MAGIC")
				end

				-- if s.template_name == "mod_plant_poison_pumpkin" then
					-- self.A:inc_check("KILLER_TOMATOES")
				-- end

				if s.template_name == "mod_razorboar_rampage_enemy" then
					self.A:inc_check("CALL_ME_PIG")
				end

				if s.template_name == "fireball_baby_ashbite" then
					self.A:inc_check("DND")
				end

				if s.template_name == "aura_breath_baby_ashbite" then
					self.A:inc_check("DND")
				end

				if s.template_name == "mod_black_baby_dragon" then
					self.A:inc_check("DND")
				end

				if s.template_name == "power_thunder_control" then
					self.A:inc_check("LIGHTNING_KILL")
				end

				-- if s.template_name == "hero_bolverk" then
				-- 	self.A:inc_check("KILL_BOLJARK")
				-- end

				-- if string.starts(s.template_name, "arrow_soldier_re_") then
				-- 	self.A:inc_check("GREEN_ARROW")
				-- end

				-- if string.starts(s.template_name, "arrow_silver_sentence") then
				-- 	self.A:inc_check("KILLTACULAR")
				-- end

				if U.flag_has(entity.vis.flags, F_FLYING) and (s.template_name == "arrow_arcane_burst" or s.template_name == "aura_arcane_burst") then
					self.A:inc_check("ARCANE_BURST")
				end

				if table.contains({
					"soldier_drow",
					"dagger_drow"
				}, s.template_name) and table.contains({
					"enemy_arachnomancer",
					"enemy_twilight_avenger",
					"enemy_twilight_elf_harasser",
					"enemy_twilight_evoker",
					"enemy_twilight_heretic",
					"enemy_twilight_scourger"
				}, entity.template_name) then
					self.A:inc_check("JAGGED_ALLIANCE")
				end

				if string.starts(entity.template_name, "enemy_perython") and s.template_name == "bullet_gryphon" then
					self.A:inc_check("DOGFIGHT")
				end
			end
		end
	end

	if game.store.level_idx == 81 then
		if entity.enemy then
			self.A:inc_check("COME_AND_GET_THEM")
		elseif entity.soldier and not entity.hero then
			self.A:inc_check("WITH_YOUR_SHIELD")
		end
	end
end

function ah:h_game_victory(store)
	local slot = storage:load_slot()
	local go = store.game_outcome

	if store.level_idx == 1 and store.game_outcome and go.stars == 3 then
		self.A:got("LEARNING_THE_ROPES")
	end

	if slot and slot.levels and go.level_mode == GAME_MODE_CAMPAIGN then
		local areas = {
			{
				ach = "SAVIOUR_OF_THE_GREEN",
				to = 6,
				from = 1
			},
			{
				ach = "CRYSTAL_CLEAR",
				to = 11,
				from = 7
			},
			{
				ach = "CONQUEROR_OF_THE_VOID",
				to = 16,
				from = 12
			}
			-- {
			-- 	ach = "STARFIELD",
			-- 	to = 15,
			-- 	from = 1
			-- }
		}

		for _, area in pairs(areas) do
			if not self.A:have(area.ach) then
				local count = 0

				for i = area.from, area.to do
					local l = slot.levels[i]

					if not l then
						log.debug("level %i missing in slot.levels", i)

						break
					elseif i == go.level_idx then
						if math.max(l.stars or 0, go.stars or 0) == 3 then
							count = count + 1
						end
					elseif l.stars == 3 then
						count = count + 1
					end
				end

				self.A:high_check(area.ach, count)
			end
		end
	end

	if store.level_idx <= GS.main_campaign_levels then
		if store.level_mode == GAME_MODE_CAMPAIGN then
			if store.level_difficulty == DIFFICULTY_HARD then
				local hard_completed = self.A:get_count("SEASONED_GENERAL")

				self.A:flag_check("SEASONED_GENERAL", bit.bor(hard_completed, 2^(store.level_idx - 1)))
			elseif store.level_difficulty == DIFFICULTY_IMPOSSIBLE then
				local impossible_completed = self.A:get_count("MASTER_TACTICIAN")

				self.A:flag_check("MASTER_TACTICIAN", bit.bor(impossible_completed, 2^(store.level_idx - 1)))

				local hard_completed = self.A:get_count("SEASONED_GENERAL")

				self.A:flag_check("SEASONED_GENERAL", bit.bor(hard_completed, 2^(store.level_idx - 1)))
			end
		elseif store.level_mode == GAME_MODE_HEROIC then
			local age_completed = self.A:get_count("AGE_OF_HEROES")

			self.A:flag_check("AGE_OF_HEROES", bit.bor(age_completed, 2^(store.level_idx - 1)))
		elseif store.level_mode == GAME_MODE_IRON then
			local iron_completed = self.A:get_count("IRONCLAD")

			self.A:flag_check("IRONCLAD", bit.bor(iron_completed, 2^(store.level_idx - 1)))
		end
	end

	local towers = store.selected_towers
	local heroes = store.selected_team
	local all_dark, all_linirea = true, true

	for _, tower in ipairs(towers) do
		local tower_template = E:get_template("tower_" .. tower .. "_lvl1")

		if tower_template then
			all_dark = all_dark and tower_template.tower.team == TEAM_DARK_ARMY
			all_linirea = all_linirea and tower_template.tower.team == TEAM_LINIREA
		end
	end

	for _, hero in ipairs(heroes) do
		local hero_template = E:get_template(hero)

		all_dark = all_dark and hero_template.hero.team == TEAM_DARK_ARMY
		all_linirea = all_linirea and hero_template.hero.team == TEAM_LINIREA
	end

	if all_dark then
		self.A:got("DARK_RUTHLESSNESS")
	end

	if all_linirea then
		self.A:got("LINIREAN_RESISTANCE")
	end
end

function ah:h_hero_level_increased(entity)
	if not self.A:have("DING_DING") then
		local slot = storage:load_slot()
		local list = {
			"hero_elves_archer",
			"hero_arivan",
			"hero_catha"
		}
		local pass = true

		for _, hn in pairs(list) do
			local xp

			if entity.template_name == hn then
				xp = entity.hero.xp or 0
			else
				local h = slot.heroes.status[hn]

				xp = h and h.xp or 0
			end

			local hl = U.get_hero_level(xp, GS.hero_xp_thresholds)

			if hl < 10 then
				pass = false

				break
			end
		end

		if pass then
			self.A:got("DING_DING")
		end
	end

	local function save_slot(template_name)
		local slot = storage:load_slot()

		for _, hero in ipairs(game.store.hero_team) do
			slot.heroes.status[template_name].xp = hero.hero.xp
		end

		storage:save_slot(slot)
	end

	if entity.hero.level == 10 then
		if not self.A:have("ROYAL_CAPTAIN") and entity.template_name == "hero_vesper" then
			self.A:got("ROYAL_CAPTAIN")
			save_slot(entity.template_name)

			return
		end

		if not self.A:have("DARK_LIEUTENANT") and entity.template_name == "hero_raelyn" then
			self.A:got("DARK_LIEUTENANT")
			save_slot(entity.template_name)

			return
		end

		if not self.A:have("FOREST_PROTECTOR") and entity.template_name == "hero_muyrn" then
			self.A:got("FOREST_PROTECTOR")
			save_slot(entity.template_name)

			return
		end

		if not self.A:have("UNTAMED_BEAST") and entity.template_name == "hero_venom" then
			self.A:got("UNTAMED_BEAST")
			save_slot(entity.template_name)

			return
		end
	end
end

function ah:h_mod_applied(mod, target)
	-- if not self.A:have("DARK_CRYSTAL") and string.starts(mod.template_name, "mod_faerie_dragon_l") then
	-- 	target._mod_faerie_dragon_total = (target._mod_faerie_dragon_total or 0) + mod.modifier.duration

	-- 	self.A:high_check("DARK_CRYSTAL", target._mod_faerie_dragon_total)
	-- end

	if mod.template_name == "mod_crystal_arcane_freeze" then
		self.A:inc_check("FROZEN")
	end

	-- if mod.template_name == "mod_forest_circle" then
	-- 	target._mod_forest_circle_count = (target._mod_forest_circle_count or 0) + 1

	-- 	self.A:high_check("KINGSFOIL", target._mod_forest_circle_count)
	-- end

	-- if mod.template_name == "mod_timelapse" then
	-- 	self.A:inc_check("PHANTOMZONED", mod.modifier.duration)
	-- end

	-- if mod.template_name == "mod_eldritch" then
	-- 	self.A:inc_check("ELDRITCH_DOOM")
	-- end

	if mod.template_name == "mod_paralyzing_tree" then
		self.A:inc_check("NIMLOTH")
	end
end

function ah:h_notification_shown(n)
	if n.ach_id and n.ach_flag then
		self.A:flag_check(n.ach_id, n.ach_flag)
	end
end

function ah:h_power_used(power_id)
	if power_id == 1 then
		self.A:reset_counters(P_POWER_1)
	elseif power_id == 2 or power_id == 3 then
		self.A:inc_check("SIGNATURE_TECHNIQUES")
	end
end

function ah:h_tower_upgraded(new_tower, old_tower)
	if not self.A:have("ACE_SPADES") and new_tower.template_name == "tower_barrack_1" then
		self.A:inc("ACE_SPADES")
	end

	if string.find(new_tower.template_name, "lvl1") then
		self.A:inc_check("WAR_MASONRY")
	end

	if not self.A:have("SIMCITY") then
		local excluded_templates = {
			"tower_faerie_dragon,",
			"tower_pixie",
			"tower_black_baby_dragon",
			"tower_holder_baby_ashbite",
			"tower_baby_ashbite",
			"tower_drow",
			"tower_bastion_holder",
			"tower_bastion"
		}
		local towers = E:filter(game.store.entities, "tower")

		table.insert(towers, new_tower)

		local pass = true

		for _, t in pairs(towers) do
			if t.id ~= old_tower.id and not table.contains(excluded_templates, t.template_name) and not table.contains(special_templates, t.template_name) then
				pass = false

				break
			end
		end

		if pass then
			self.A:got("SIMCITY")
		end
	end
end

function ah:h_next_wave_sent(group)
	if game.store.level_idx == 81 then
		self.A:inc_check("HOLD_THE_LINE")
		self.A:inc_check("NOT_YET")
		self.A:inc_check("THE_ODDS")
	elseif game.store.level_idx == 82 then
		self.A:inc_check("STAND_YOUR_GROUND")
		self.A:inc_check("RED_SUN")
	end
end

function ah:h_entity_revived(entity, count)
	return
end

function ah:h_entity_healed(mod, entity, amount)
	return
end

function ah:h_enemy_reached_goal(entity)
	return
end

function ah:h_health_regen(entity, amount)
	return
end

function ah:h_next_wave_ready(group)
	return
end

function ah:h_rally_point_changed(tower)
	return
end

function ah:h_soldier_attack(entity, attack, signal_prop)
	return
end

function ah:h_soldier_dodge(entity)
	return
end

function ah:h_soldier_pickpocket(entity, amount)
	return
end

function ah:h_tower_spawn(tower, entity)
	if entity.template_name == "soldier_arborean_sentinels_spearmen" then
		self.A:inc_check("GREENLIT_ALLIES")
		log.info("ARBOREAN THORNSPEAR SPAWN")
	end
end

function ah:h_tower_removed(tower)
	return
end

function ah:h_minecraft_stage06(entity)
	self.A:got("CRAFTING_IN_THE_MINES")
end

function ah:h_robin_stage01(entity)
	self.A:got("TIPPING_THE_SCALES")
end

function ah:h_link_stage02(entity)
	self.A:inc_check("ITS_A_SECRET_TO_EVERYONE")
end

function ah:h_lion_king_stage02(entity)
	self.A:got("CIRCLE_OF_LIFE")
end

function ah:h_playful_friends_stage03(entity)
	self.A:got("PLAYFUL_FRIENDS")
end

function ah:h_most_delicious_stage03(entity)
	self.A:got("MOST_DELICIOUS")
end

function ah:h_door_stage06(entity)
	self.A:got("NONE_SHALL_PASS")
end

function ah:h_witcher_stage07(entity)
	self.A:got("SILVER_FOR_MONSTERS")
end

function ah:h_crows_stage07(entity)
	self.A:got("CROW_SCARER")
end

function ah:h_lotr_stage11(entity)
	self.A:got("STARLIGHT")
end

function ah:h_rubble_stage05(entity)
	self.A:got("CLEANUP_IS_OPTIONAL")
end

function ah:h_elves_stage08(entity)
	self.A:got("BREAKER_OF_CHAINS")
end

function ah:h_ymca_stage10(entity)
	self.A:got("GET_THE_PARTY_STARTED")
end

function ah:h_bonfire_stage01(entity)
	self.A:got("FIELD_TRIP_RUINER")
end

function ah:h_arboreans_stage04(entity)
	self.A:got("OVER_THE_EDGE")
end

function ah:h_baskets_stage8(entity)
	self.A:got("GEM_SPILLER")
end

function ah:h_portal_not_spawned_stage09(entity)
	self.A:got("UNBOUND_VICTORY")
end

function ah:h_sunray_kills_stage13(entity)
	self.A:got("ONE_SHOT_TOWER")
end

function ah:h_no_amalgams_spawned_stage14(entity)
	self.A:got("CROWD_CONTROL")
end

function ah:h_no_soldiers_grabbed_stage15(entity)
	self.A:got("BUTTERTENTACLES")
end

function ah:h_rickmorty_stage14(entity)
	self.A:got("WOBBA_LUBBA_DUB_DUB")
end

function ah:h_stranger_things_stage12(entity)
	self.A:got("WEIRDER_THINGS")
end

function ah:h_goblintap_stage15(entity)
	self.A:got("TAKE_ME_HOME")
end

function ah:h_spawned_reinforcement(entity)
	self.A:inc_check("THE_CAVALRY_IS_HERE")
end

function ah:h_no_projections_bossfight_stage11(entity)
	if entity.projections_in_bossfight == 0 then
		self.A:got("YOU_SHALL_NOT_CAST")
	end
end

function ah:h_tree_hugger_stage17(entity)
	self.A:got("TREE_HUGGER")
end

function ah:h_rock_paper_scissors_stage19(entity)
	self.A:got("ROCK_BEATS_ROCK")
end

function ah:h_no_anim_armored_respawn(entity)
	self.A:got("RUST_IN_PEACE")
end

function ah:h_no_flowers_lost_stage20(entity)
	self.A:got("SAVIOUR_OF_THE_FOREST")
end

function ah:h_boat_croc_stage21(entity)
	self.A:got("SMOOTH_OPER_GATOR")
end

function ah:h_flying_king_croc_stage22(entity)
	self.A:got("HAIL_TO_THE_K_BABY")
end

function ah:h_into_the_ogreverse(entity)
	self.A:got("INTO_THE_OGREVERSE")
end

function ah:h_a_coon_of_surprises(entity)
	self.A:got("A_COON_OF_SURPRISES")
end

function ah:h_lucas_spider(entity)
	self.A:got("LUCAS_SPIDER")
end

function ah:h_cheshine_cat_terrain_4(level)
	local current_cheshine_cat_taps = self.A:get_count("WE_ARE_ALL_MAD_HERE")

	self.A:flag_check("WE_ARE_ALL_MAD_HERE", bit.bor(current_cheshine_cat_taps, 2^level))
end

function ah:h_sheepy_tap(level)
	local current_sheepy_taps = self.A:get_count("OVINE_JOURNALISM")

	self.A:flag_check("OVINE_JOURNALISM", bit.bor(current_sheepy_taps, 2^level))
end

function ah:h_no_jump_boss_stage06(jumps)
	if jumps == 1 then
		self.A:got("OUTBACK_BARBEQUICK")
	end
end

function ah:h_crane_stage23(entity)
	self.A:got("MECHANICAL_BURNOUT")
end

function ah:h_factory_stage24(entity)
	self.A:got("FACTORY_STRIKE")
end

function ah:h_fist_stage25(count)
	self.A:inc_check("DOMO_ARIGATO", count)
end

function ah:h_snake_stage25(entity)
	self.A:got("KEPT_YOU_WAITING")
end

function ah:h_mewtwo_stage26(entity)
	self.A:got("GIFT_OF_LIFE")
end

function ah:h_workers_stage27(entity)
	self.A:got("DISTURBING_THE_PEACE")
end

function ah:h_exodia_terrain_6(level)
	local current_exodia_parts = self.A:get_count("OBLITERATE")

	log.info("FOUND EXODIA PART! CURRENT PARTS: " .. current_exodia_parts)
	log.info("CURRENT LEVEL: " .. level)
	self.A:flag_check("OBLITERATE", bit.bor(current_exodia_parts, 2^level))
end

function ah:h_head_stage27(entity)
	self.A:got("SHUT_YOUR_MOUTH")
end

function ah:h_kermit_stage417(entity)
	self.A:got("KERMIT")
end

return ah
