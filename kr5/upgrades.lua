local log = require("klua.log"):new("upgrades")
local E = require("entity_db")
local bit = require("bit")

require("constants")

local balance = require("balance/balance")
local storage = require("storage")
local GS = require("game_settings")
local km = require("klua.macros")
local U = require("utils")
local V = require("klua.vector")

local function T(name)
	return E:get_template(name)
end

local function fts(v)
	return v / FPS
end

local epsilon = 1e-09
local upgrades = {}

upgrades.max_level = nil
upgrades.levels = {}
upgrades.levels.towers = 0
upgrades.levels.heroes = 0
upgrades.levels.reinforcements = 0
upgrades.levels.alliance = 0
upgrades.display_order = {
	"towers",
	"heroes",
	"reinforcements",
	"alliance"
}
upgrades.list = {
	towers_war_rations = {
		key = "towers_war_rations",
		class = "towers",
		id = 1,
		price = 1,
		level = 1,
		next = {
			3
		}
	},
	towers_wise_investment = {
		key = "towers_wise_investment",
		class = "towers",
		id = 2,
		price = 1,
		level = 2,
		next = {
			4
		}
	},
	towers_scoping_mechanism = {
		key = "towers_scoping_mechanism",
		class = "towers",
		id = 3,
		price = 2,
		level = 2,
		next = {
			2,
			5
		}
	},
	towers_golden_time = {
		key = "towers_golden_time",
		class = "towers",
		id = 4,
		price = 2,
		level = 3,
		next = {
			6
		}
	},
	towers_royal_training = {
		key = "towers_royal_training",
		class = "towers",
		id = 5,
		price = 2,
		level = 4,
		next = {
			7
		}
	},
	towers_favorite_customer = {
		key = "towers_favorite_customer",
		class = "towers",
		id = 6,
		price = 3,
		level = 4,
		next = {}
	},
	towers_improved_formulas = {
		key = "towers_improved_formulas",
		class = "towers",
		id = 7,
		price = 3,
		level = 3,
		next = {
			8
		}
	},
	towers_keen_accuracy = {
		key = "towers_keen_accuracy",
		class = "towers",
		id = 8,
		price = 4,
		level = 5,
		next = {}
	},
	heroes_desperate_effort = {
		key = "heroes_desperate_effort",
		class = "heroes",
		id = 1,
		price = 1,
		level = 1,
		next = {
			2,
			3
		}
	},
	heroes_lone_wolves = {
		key = "heroes_lone_wolves",
		class = "heroes",
		id = 2,
		price = 1,
		level = 2,
		next = {
			4
		},
		check_cooldown = fts(25)
	},
	heroes_visual_learning = {
		key = "heroes_visual_learning",
		class = "heroes",
		id = 3,
		price = 1,
		level = 2,
		next = {
			4
		},
		check_cooldown = fts(30)
	},
	heroes_unlimited_vigor = {
		key = "heroes_unlimited_vigor",
		class = "heroes",
		id = 4,
		price = 2,
		level = 3,
		next = {
			5,
			6
		}
	},
	heroes_lethal_focus = {
		key = "heroes_lethal_focus",
		class = "heroes",
		id = 5,
		price = 2,
		level = 4,
		next = {
			7
		}
	},
	heroes_nimble_physique = {
		key = "heroes_nimble_physique",
		class = "heroes",
		id = 6,
		price = 2,
		level = 4,
		next = {
			7
		}
	},
	heroes_limit_pushing = {
		key = "heroes_limit_pushing",
		class = "heroes",
		id = 7,
		price = 3,
		level = 5,
		next = {}
	},
	reinforcements_master_blacksmiths = {
		key = "reinforcements_master_blacksmiths",
		class = "reinforcements",
		id = 1,
		price = 1,
		level = 1,
		next = {
			2
		}
	},
	reinforcements_intense_workout = {
		key = "reinforcements_intense_workout",
		class = "reinforcements",
		id = 2,
		price = 1,
		level = 2,
		next = {
			3,
			4
		}
	},
	reinforcements_rebel_militia = {
		class = "reinforcements",
		key = "reinforcements_rebel_militia",
		id = 3,
		price = 2,
		level = 3,
		next = {
			5
		},
		blocks = {
			4
		}
	},
	reinforcements_shadow_archer = {
		class = "reinforcements",
		key = "reinforcements_shadow_archer",
		id = 4,
		price = 2,
		level = 3,
		next = {
			6
		},
		blocks = {
			3
		}
	},
	reinforcements_thorny_armor = {
		key = "reinforcements_thorny_armor",
		class = "reinforcements",
		id = 5,
		price = 2,
		level = 4,
		next = {
			7
		}
	},
	reinforcements_night_veil = {
		key = "reinforcements_night_veil",
		class = "reinforcements",
		id = 6,
		price = 2,
		level = 4,
		next = {
			8
		}
	},
	reinforcements_power_trio = {
		key = "reinforcements_power_trio",
		class = "reinforcements",
		id = 7,
		price = 4,
		level = 5,
		next = {}
	},
	reinforcements_power_trio_dark = {
		key = "reinforcements_power_trio_dark",
		class = "reinforcements",
		id = 8,
		price = 4,
		level = 5,
		next = {}
	},
	alliance_corageous_stand = {
		key = "alliance_corageous_stand",
		class = "alliance",
		id = 1,
		price = 1,
		level = 1,
		next = {
			3
		},
		check_cooldown = fts(40)
	},
	alliance_merciless = {
		key = "alliance_merciless",
		class = "alliance",
		id = 2,
		price = 1,
		level = 1,
		next = {
			4
		},
		check_cooldown = fts(35)
	},
	alliance_friends_of_the_crown = {
		key = "alliance_friends_of_the_crown",
		class = "alliance",
		id = 3,
		price = 2,
		level = 2,
		next = {
			5
		}
	},
	alliance_shady_company = {
		key = "alliance_shady_company",
		class = "alliance",
		id = 4,
		price = 2,
		level = 2,
		next = {
			5
		}
	},
	alliance_shared_reserves = {
		key = "alliance_shared_reserves",
		class = "alliance",
		id = 5,
		price = 2,
		level = 3,
		next = {
			6,
			7
		}
	},
	alliance_flux_altering_coils = {
		key = "alliance_flux_altering_coils",
		class = "alliance",
		id = 6,
		price = 3,
		level = 4,
		next = {
			8
		}
	},
	alliance_seal_of_punishment = {
		key = "alliance_seal_of_punishment",
		class = "alliance",
		id = 7,
		price = 3,
		level = 4,
		next = {
			9
		}
	},
	alliance_display_of_true_might_linirea = {
		key = "alliance_display_of_true_might_linirea",
		class = "alliance",
		id = 8,
		price = 3,
		level = 5,
		next = {}
	},
	alliance_display_of_true_might_dark = {
		key = "alliance_display_of_true_might_dark",
		class = "alliance",
		id = 9,
		price = 3,
		level = 5,
		next = {}
	}
}

function upgrades:get_by_group_idx(group, idx)
	for _, v in pairs(self.list) do
		if v.class == group and v.id == idx then
			return v
		end
	end

	return nil
end

function upgrades:set_levels(levels)
	for k, v in pairs(levels) do
		self.levels[k] = v
	end
end

function upgrades:get_upgrade(name)
	local u = self.list[name]

	if u and table.contains(self.levels[u.class], u.id) then
		return u
	end

	return nil
end

function upgrades:get_previous_upgrades(group, idx)
	local prev_idx = {}

	for _, v in pairs(self.list) do
		if v.class == group and v.next and table.contains(v.next, idx) then
			table.insert(prev_idx, v)
		end
	end

	return prev_idx
end

function upgrades:get_spent_points()
	local spent_points = 0
	local user_data = storage:load_slot()

	for _, u in pairs(self.list) do
		for _, uidx in pairs(user_data.upgrades[u.class]) do
			if uidx == u.id then
				spent_points = spent_points + u.price

				break
			end
		end
	end

	return spent_points
end

function upgrades:get_current_points_by_level()
	local last_level = 1
	local user_data = storage:load_slot()

	for lvl, value in ipairs(user_data.levels) do
		if value[1] ~= nil then
			last_level = lvl
		end
	end

	if DEBUG and storage.active_slot_idx == "1" then
		return 60
	end

	if last_level > GS.main_campaign_levels then
		last_level = GS.main_campaign_levels
	end

	local b = balance.upgrades

	return b.points_distribution[last_level]
end

function upgrades:set_upgrades_current_for(level)
	if DEBUG then
		local function block_item(upgrade, bought, class)
			for _, bougth_id in pairs(bought) do
				local item = self:get_by_group_idx(class, bougth_id)

				if item.blocks and table.contains(item.blocks, upgrade.id) then
					return true
				end
			end

			return false
		end

		local function get_next_buy(bought, level, class)
			for _, v in pairs(self.list) do
				if v.class == class and level >= v.level then
					for _, bougth_id in pairs(bought) do
						local upgrade = self:get_by_group_idx(class, bougth_id)

						if table.contains(upgrade.next, v.id) and not table.contains(bought, v.id) and not block_item(v, bought, class) then
							return v
						end
					end
				end
			end

			return nil
		end

		local user_data = storage:load_slot()
		local b = balance.upgrades

		if level <= 1 then
			level = 2
		end

		local points = b.points_distribution[km.clamp(1, 16, level - 1)]

		user_data.upgrades = {
			towers = {
				1
			},
			heroes = {
				1
			},
			reinforcements = {
				1
			},
			alliance = {
				1,
				2
			}
		}

		if level > 6 then
			if math.random() > 0.5 then
				table.insert(user_data.upgrades.reinforcements, 3)
			else
				table.insert(user_data.upgrades.reinforcements, 4)
			end
		end

		local upgrade_found = false
		local level = 2

		points = points - 5

		repeat
			upgrade_found = false

			for class, list in pairs(user_data.upgrades) do
				local idx = 1
				local upgrade = get_next_buy(list, level, class)

				if upgrade and points > upgrade.price then
					points = points - upgrade.price

					table.insert(user_data.upgrades[class], upgrade.id)

					upgrade_found = true

					log.info("buy upgrade " .. class .. " id " .. upgrade.id .. " points remain " .. points)
				end
			end

			level = level + 1
		until points <= 0 or not upgrade_found
	end
end

function upgrades:get_points_by_level(level_idx)
	local b = balance.upgrades

	return b.points_distribution[km.clamp(1, 16, level_idx)]
end

function upgrades:get_upgrade_bitfield(class)
	local out = 0
	local user_data = storage:load_slot()
	local u = user_data.upgrades

	if not u[class] then
		log.error("upgrade class %s not found", class)

		return out
	end

	for _, v in pairs(u[class]) do
		out = bit.bor(out, 2^(v - 1))
	end

	return out
end

function upgrades:get_upgrade_array(bitfield)
	local out = {}

	for i = 0, 15 do
		if bit.band(bitfield, 2^i) ~= 0 then
			table.insert(out, i + 1)
		end
	end

	return out
end

function upgrades:patch_templates(max_level)
	balance = nil
	balance = require("balance/balance")
	if max_level then
		self.max_level = max_level
	end

	local b = balance.upgrades
	local u
	local all_towers = {
		"tower_paladin_covenant_lvl",
		"tower_demon_pit_lvl",
		"tower_tricannon_lvl",
		"tower_royal_archers_lvl",
		"tower_arborean_emissary_lvl",
		"tower_elven_stargazers_lvl",
		"tower_arcane_wizard_lvl",
		"tower_necromancer_lvl",
		"tower_ballista_lvl",
		"tower_flamespitter_lvl",
		"tower_rocket_gunners_lvl",
		"tower_barrel_lvl",
		"tower_sand_lvl",
		"tower_ghost_lvl",
		"tower_ray_lvl",
		"tower_dark_elf_lvl",
		"tower_hermit_toad_lvl",
		"tower_dwarf_lvl",
		"tower_sparking_geode_lvl",
		"tower_rock_thrower_lvl",
		"tower_warmongers_barrack_lvl",
		"tower_ignis_altar_lvl",
		"tower_deep_devils_lvl",
		"tower_ogres_barrack_lvl",
	}

	u = self:get_upgrade("towers_war_rations")

	if u then
		local st = T(T("tower_arborean_emissary_lvl1").barrack.soldier_type)
		st.health._hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_arborean_emissary_lvl1").barrack.standby_soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)

		st = T("pirates_soldier_ogre_cook_lvl2")
		st.health._hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T("pirates_soldier_goblin_deckhand_lvl2")
		st.health._hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T("pirates_soldier_goblin_launched")
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T("pirates_soldier_goblin_launched_better_crew")
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)

		for _, n in pairs(all_towers) do
			for i = 1, 4 do
				local barrack = T(n .. i).barrack
				if barrack then
					if type(barrack.soldier_type) == "table" then
						for _, sn in ipairs(barrack.soldier_type) do
							st = T(sn)
							st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
						end
					else
						st = T(barrack.soldier_type)
						st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
					end
				end
			end
		end

		for i = 1, 4 do
			for _, n in pairs({
				"soldier_tower_necromancer_skeleton_lvl",
				"soldier_tower_necromancer_skeleton_golem_lvl",
				"soldier_tower_demon_pit_basic_attack_lvl"
			}) do
				T(n .. i).health.hp_max = km.round(T(n .. i).health.hp_max * b.towers_war_rations.hp_factor)
			end
		end

		T("big_guy_tower_demon_pit_lvl4").health.hp_max = km.round(T("big_guy_tower_demon_pit_lvl4").health.hp_max * b.towers_war_rations.hp_factor)
		T("soldier_tower_barrel_skill_warrior").war_rations_hp_factor = b.towers_war_rations.hp_factor
		T("tower_paladin_covenant_soldier_lvl4").powers.lead.b.hp = T("tower_paladin_covenant_soldier_lvl4").powers.lead.b.hp * b.towers_war_rations.hp_factor
		T("soldier_tower_dark_elf").war_rations_hp_factor = b.towers_war_rations.hp_factor

		st = T(T("tower_paladin").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_wildling").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_barbarian").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_templar").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_assassin").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_barrack_dwarf").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_arborean_emissary_lvl1").barrack.soldier_type)
		st.health.hp_max = st.health._hp_max
		st.health._hp_max = nil
		st = T(T("tower_entwood").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_frankenstein").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		for i = 2, 3 do
			st = T(T("tower_elven_barrack_lvl" .. i).barrack.soldier_type)
			st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		end
		st = T(T("tower_blade").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_special_elf").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_drow").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		for i = 2, 4 do
			st = T(T("tower_twilight_elves_barrack_lvl" .. i).barrack.soldier_type)
			st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		end
		st = T(st.death_spawns.name)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_spirit_mausoleum_lvl4").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		for i, hp in ipairs(T("tower_spirit_mausoleum_lvl4").powers.spectral_communion.hp) do
			T("tower_spirit_mausoleum_lvl4").powers.spectral_communion.hp[i] = km.round(hp * b.towers_war_rations.hp_factor)
		end
		st = T(T("tower_warmongers_barrack_lvl4").powers.promotion.unit_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_hammerhold_archer").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		for i, name in ipairs(T("tower_hammerhold_archer").powers.war_elephants.unit_type) do
			st = T(name)
			st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		end
		st = T(T("tower_barrack_amazonas").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_barrack_pirates").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_barrack_pirates_w_flamer").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_barrack_pirates_w_anchor").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_stage_28_priests_barrack").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_barrack_mercenaries").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_ewok").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_stage_20_arborean_honey").attacks.list[2].entity)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T(T("tower_sorcerer").barrack.soldier_type)
		st.health.hp_max = km.round(st.health.hp_max * b.towers_war_rations.hp_factor)
		st = T("pirates_soldier_ogre_cook_lvl2")
		st.health.hp_max = st.health._hp_max
		st.health._hp_max = nil
		st = T("pirates_soldier_goblin_deckhand_lvl2")
		st.health.hp_max = st.health._hp_max
		st.health._hp_max = nil
	end

	u = self:get_upgrade("towers_wise_investment")

	if u then
		for _, n in pairs(all_towers) do
			for i = 1, 4 do
				T(n .. i).tower.refund_factor = b.towers_wise_investment.refund_factor
			end
		end

		T("tower_paladin").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_wildling").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_barbarian").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_templar").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_assassin").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_archer_dwarf").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_barrack_dwarf").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_entwood").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_frankenstein").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_tesla").tower.refund_factor = b.towers_wise_investment.refund_factor
		for i = 2, 3 do
			T("tower_elven_barrack_lvl" .. i).tower.refund_factor = b.towers_wise_investment.refund_factor
		end
		T("tower_blade").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_special_elf").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_drow").tower.refund_factor = b.towers_wise_investment.refund_factor
		for i = 2, 4 do
			T("tower_twilight_elves_barrack_lvl" .. i).tower.refund_factor = b.towers_wise_investment.refund_factor
		end
		for i = 1, 3 do
			T("tower_mage_" .. i).tower.refund_factor = b.towers_wise_investment.refund_factor
		end
		T("tower_wild_magus").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_high_elven").tower.refund_factor = b.towers_wise_investment.refund_factor
		for i = 2, 3 do
			T("tower_archer_" .. i).tower.refund_factor = b.towers_wise_investment.refund_factor
		end
		T("tower_totem").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_crossbow").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_musketeer").tower.refund_factor = b.towers_wise_investment.refund_factor
		for i = 2, 4 do
			T("tower_spirit_mausoleum_lvl" .. i).tower.refund_factor = b.towers_wise_investment.refund_factor
		end
		T("tower_hammerhold_archer").tower.refund_factor = b.towers_wise_investment.refund_factor
		for i = 2, 3 do
			T("tower_elven_archer_" .. i).tower.refund_factor = b.towers_wise_investment.refund_factor
		end
		T("tower_arcane_archer").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_silver").tower.refund_factor = b.towers_wise_investment.refund_factor
		for i = 2, 3 do
			T("tower_engineer_" .. i).tower.refund_factor = b.towers_wise_investment.refund_factor
		end
		T("tower_bfg").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_dwaarp").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_mech").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_pirate_watchtower").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_pixie").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_faerie_dragon").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_ewok").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_royal_archer_and_musketeer").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_royal_archer_and_ranger").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_royal_archer_and_longbow").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_sorcerer").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_archmage").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_sunray").tower.refund_factor = b.towers_wise_investment.refund_factor
		T("tower_bastion").tower.refund_factor = b.towers_wise_investment.refund_factor
	end

	u = self:get_upgrade("towers_scoping_mechanism")

	if u then
		local range_factor = b.towers_scoping_mechanism.range_factor
		local rally_range_factor = b.towers_scoping_mechanism.rally_range_factor

		for _, n in pairs(all_towers) do
			for i = 1, 4 do
				local t = T(n .. i)

				if t.barrack then
					t.barrack.rally_range = t.barrack.rally_range * rally_range_factor
				end

				if t.attacks then
					t.attacks.range = t.attacks.range * range_factor
				end

				if t.shooters then
					for _, s in ipairs(t.shooters) do
						if type(s) == "string" then
							s = T(s)
						end
						if s.attacks then
							s.attacks.range = s.attacks.range * range_factor
						end
					end
				end
			end
		end

		local attacks = T("tower_entwood").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_frankenstein").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_tesla").attacks
		attacks.range = attacks.range * range_factor
		attacks.list[1].range = attacks.range
		T(attacks.list[2].aura).aura.radius = attacks.range
		for i = 1, 3 do
			attacks = T("tower_mage_" .. i).attacks
			attacks.range = attacks.range * range_factor
		end
		attacks = T("tower_wild_magus").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_high_elven").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_archer_dwarf").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_totem").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_crossbow").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_musketeer").attacks
		attacks.range = attacks.range * range_factor
		attacks.list[2].range = attacks.list[2].range * range_factor
		attacks.list[3].range = attacks.list[3].range * range_factor
		attacks.list[4].range = attacks.list[4].range * range_factor
		for i = 2, 4 do
			attacks = T("tower_spirit_mausoleum_lvl" .. i).attacks
			attacks.range = attacks.range * range_factor
		end
		attacks = T("tower_hammerhold_archer").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_pirate_watchtower").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_pixie").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_faerie_dragon").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_stage_13_sunray").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_stage_20_arborean_honey").attacks
		attacks.range = attacks.range * range_factor
		for i = 2, 3 do
			attacks = T("tower_elven_archer_" .. i).attacks
			attacks.range = attacks.range * range_factor
		end
		attacks = T("tower_arcane_archer").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_silver").attacks
		attacks.range = attacks.range * range_factor
		for i = 2, 3 do
			attacks = T("tower_engineer_" .. i).attacks
			attacks.range = attacks.range * range_factor
		end
		attacks = T("tower_bfg").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_dwaarp").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_royal_archer_and_musketeer").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("shooter_musketeer").attacks
		attacks.range = attacks.range * range_factor
		attacks.list[2].range = attacks.list[2].range * range_factor
		attacks.list[3].range = attacks.list[3].range * range_factor
		attacks.list[4].range = attacks.list[4].range * range_factor
		attacks = T("tower_royal_archer_and_ranger").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("shooter_ranger").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_royal_archer_and_longbow").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("shooter_longbow").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_sorcerer").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_archmage").attacks
		attacks.range = attacks.range * range_factor
		attacks = T("tower_bastion").attacks
		attacks.range = attacks.range * range_factor

		local barrack = T("tower_paladin").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_wildling").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_barbarian").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_templar").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_assassin").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_barrack_dwarf").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_entwood").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_frankenstein").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		for i = 2, 3 do
			barrack = T("tower_elven_barrack_lvl" .. i).barrack
			barrack.rally_range = barrack.rally_range * rally_range_factor
		end
		barrack = T("tower_blade").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_special_elf").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_drow").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		for i = 2, 4 do
			barrack = T("tower_twilight_elves_barrack_lvl" .. i).barrack
			barrack.rally_range = barrack.rally_range * rally_range_factor
		end
		barrack = T("tower_spirit_mausoleum_lvl4").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_hammerhold_archer").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_barrack_amazonas").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_barrack_pirates").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_barrack_pirates_w_flamer").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_barrack_pirates_w_anchor").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_stage_28_priests_barrack").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_barrack_mercenaries").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_ewok").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_mech").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
		barrack = T("tower_sorcerer").barrack
		barrack.rally_range = barrack.rally_range * rally_range_factor
	end

	u = self:get_upgrade("towers_golden_time")

	if u then
		GS.early_wave_reward_per_second = GS.early_wave_reward_per_second_default * b.towers_golden_time.early_wave_reward_per_second_factor
	else
		GS.early_wave_reward_per_second = GS.early_wave_reward_per_second_default
	end

	u = self:get_upgrade("towers_improved_formulas")

	if u then
		local r_factor = b.towers_improved_formulas.range_factor

		for _, n in pairs({
			"soldier_tower_demon_pit_basic_attack_lvl"
		}) do
			for i = 1, 4 do
				for j = 1, 4 do
					T(n .. i).explosion_range[j] = T(n .. i).explosion_range[j] * r_factor
				end
			end
		end

		for i = 1, 4 do
			T("tower_tricannon_bomb_" .. i).bullet.damage_radius = T("tower_tricannon_bomb_" .. i).bullet.damage_radius * r_factor
		end

		T("tower_tricannon_bomb_bombardment_bomb").bullet.damage_radius = T("tower_tricannon_bomb_bombardment_bomb").bullet.damage_radius * r_factor
		T("soldier_tower_rocket_gunners_lvl4").melee.attacks[2].damage_radius = T("soldier_tower_rocket_gunners_lvl4").melee.attacks[2].damage_radius * r_factor
		T("bullet_tower_ballista_skill_bomb").bullet.damage_radius = T("bullet_tower_ballista_skill_bomb").bullet.damage_radius * r_factor
		T("bullet_tower_flamespitter_skill_bomb").bullet.damage_radius = T("bullet_tower_flamespitter_skill_bomb").bullet.damage_radius * r_factor
		T("controller_tower_flamespitter_column").radius_in = T("controller_tower_flamespitter_column").radius_in * r_factor
		T("controller_tower_flamespitter_column").radius_out = T("controller_tower_flamespitter_column").radius_out * r_factor

		for i = 1, 4 do
			T("bullet_tower_barrel_lvl" .. i).bullet.damage_radius = T("bullet_tower_barrel_lvl" .. i).bullet.damage_radius * r_factor
		end

		T("aura_bullet_tower_barrel_skill_barrel").explosion_damage_radius = T("aura_bullet_tower_barrel_skill_barrel").explosion_damage_radius * r_factor

		for i = 1, 4 do
			T("bullet_tower_hermit_toad_engineer_basic_lvl" .. i).bullet.damage_radius = T("bullet_tower_hermit_toad_engineer_basic_lvl" .. i).bullet.damage_radius * r_factor
		end
		T("rock_entwood").bullet.damage_radius = T("rock_entwood").bullet.damage_radius * r_factor
		T("rock_firey_nut").bullet.damage_radius = T("rock_firey_nut").bullet.damage_radius * r_factor
		for i = 1, 4 do
			local t = T("tower_rock_thrower_lvl" .. i)
			local b = T(t.attacks.list[1].bullet)
			b.bullet.damage_radius = b.bullet.damage_radius * r_factor
		end
		T("dwarf_barrel").bullet.damage_radius = T("dwarf_barrel").bullet.damage_radius * r_factor
		T("bomb_musketeer").bullet.damage_radius = T("bomb_musketeer").bullet.damage_radius * r_factor
		T("pirate_watchtower_bomb").bullet.damage_radius = T("pirate_watchtower_bomb").bullet.damage_radius * r_factor
		T("bullet_stage_20_arborean_honey").bullet.damage_radius = T("bullet_stage_20_arborean_honey").bullet.damage_radius * r_factor
		T("aura_arcane_burst").aura.radius = T("aura_arcane_burst").aura.radius * r_factor
		T("bomb_dynamite").bullet.damage_radius = T("bomb_dynamite").bullet.damage_radius * r_factor
		T("bomb_black").bullet.damage_radius = T("bomb_black").bullet.damage_radius * r_factor
		T("bomb_bfg").bullet.damage_radius = T("bomb_bfg").bullet.damage_radius * r_factor
		T("missile_bfg").bullet.damage_radius = T("missile_bfg").bullet.damage_radius * r_factor
		T("bomb_mecha").bullet.damage_radius = T("bomb_mecha").bullet.damage_radius * r_factor
		T("missile_mecha").bullet.damage_radius = T("missile_mecha").bullet.damage_radius * r_factor
		T("bolt_blast").bullet.damage_radius = T("bolt_blast").bullet.damage_radius * r_factor
		T("bomb_goblin_bomber").bullet.damage_radius = T("bomb_goblin_bomber").bullet.damage_radius * r_factor
		T("bomb_skill_goblin_lvl1").bullet.damage_radius = T("bomb_skill_goblin_lvl1").bullet.damage_radius * r_factor
		T("bomb_skill_goblin_lvl2").bullet.damage_radius = T("bomb_skill_goblin_lvl2").bullet.damage_radius * r_factor
	end

	u = self:get_upgrade("towers_favorite_customer")

	if u then
		u.refund_cost_factor = b.towers_favorite_customer.refund_cost_factor
		u.refund_cost_factor_one_level = b.towers_favorite_customer.refund_cost_factor_one_level
	end

	u = self:get_upgrade("towers_keen_accuracy")

	if u then
		for _, n in pairs(all_towers) do
			local template = T(n .. 4)

			for _, p in pairs(T(n .. 4).powers) do
				if p.cooldown then
					for k, _ in pairs(p.cooldown) do
						p.cooldown[k] = p.cooldown[k] * b.towers_keen_accuracy.cooldown_mult
					end
				end
			end
		end

		local t = T("tower_entwood")
		t.attacks.list[2].cooldown = t.attacks.list[2].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.entwood.fiery_nuts.cooldown = t.attacks.list[2].cooldown
		t.attacks.list[3].cooldown = t.attacks.list[3].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.entwood.clobber.cooldown = t.attacks.list[3].cooldown

		t = T("tower_wild_magus")
		local p = t.powers.eldritch
		for i, cd in ipairs(p.cooldowns) do
			p.cooldowns[i] = p.cooldowns[i] * b.towers_keen_accuracy.cooldown_mult
		end
		t.attacks.list[3].cooldown = t.attacks.list[3].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.wild_magus.ward.cooldown = t.attacks.list[3].cooldown

		t = T("tower_high_elven")
		t.attacks.list[2].cooldown = t.attacks.list[2].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.high_elven.timelapse.cooldown = t.attacks.list[2].cooldown

		t = T("tower_archer_dwarf")
		t.attacks.list[2].cooldown = t.attacks.list[2].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.archer_dwarf.barrel.cooldown = t.attacks.list[2].cooldown

		t = T("tower_totem")
		t.attacks.list[2].cooldown = t.attacks.list[2].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.totem.weakness.cooldown = t.attacks.list[2].cooldown
		t.attacks.list[3].cooldown = t.attacks.list[3].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.totem.silence.cooldown = t.attacks.list[3].cooldown

		t = T("tower_crossbow")
		t.attacks.list[2].cooldown = t.attacks.list[2].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.crossbow.multishot.cooldown = t.attacks.list[2].cooldown

		t = T("tower_musketeer")
		t.attacks.list[2].cooldown = t.attacks.list[2].cooldown * b.towers_keen_accuracy.cooldown_mult
		t.attacks.list[3].cooldown = t.attacks.list[3].cooldown * b.towers_keen_accuracy.cooldown_mult
		t.attacks.list[4].cooldown = t.attacks.list[4].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.musketeer.sniper.cooldown = t.attacks.list[2].cooldown
		balance.towers.musketeer.shrapnel.cooldown = t.attacks.list[4].cooldown

		t = T("tower_spirit_mausoleum_lvl4")
		for _, p in pairs(t.powers) do
			if p.cooldown then
				for k, _ in pairs(p.cooldown) do
					p.cooldown[k] = p.cooldown[k] * b.towers_keen_accuracy.cooldown_mult
				end
			end
		end

		t = T("tower_pixie")
		t.attacks.enemy_cooldown = t.attacks.enemy_cooldown * b.towers_keen_accuracy.cooldown_mult
		t.attacks.pixie_cooldown = t.attacks.pixie_cooldown * b.towers_keen_accuracy.cooldown_mult

		t = T("tower_arcane_archer")
		t.attacks.list[2].cooldown = t.attacks.list[2].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.arcane_archer.burst.cooldown = t.attacks.list[2].cooldown
		t.attacks.list[3].cooldown = t.attacks.list[3].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.arcane_archer.slumber.cooldown = t.attacks.list[3].cooldown

		t = T("tower_silver")
		t.attacks.list[3].cooldown = t.attacks.list[3].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.silver.mark.cooldown = t.attacks.list[3].cooldown

		t = T("tower_bfg")
		t.attacks.list[2].cooldown = t.attacks.list[2].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.bfg.missile.cooldown = t.attacks.list[2].cooldown
		t.attacks.list[3].cooldown = t.attacks.list[3].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.bfg.cluster.cooldown = t.attacks.list[3].cooldown

		t = T("tower_dwaarp")
		t.attacks.list[2].cooldown = t.attacks.list[2].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.dwaarp.lava.cooldown = t.attacks.list[2].cooldown
		t.attacks.list[3].cooldown = t.attacks.list[3].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.dwaarp.drill.cooldown = t.attacks.list[3].cooldown
		t.attacks.list[4].cooldown = t.attacks.list[4].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.dwaarp.batteries.cooldown = t.attacks.list[4].cooldown

		t = T("soldier_mecha")
		t.attacks.list[2].cooldown = t.attacks.list[2].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.mecha.missile.cooldown = t.attacks.list[2].cooldown
		t.attacks.list[3].cooldown = t.attacks.list[3].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.mecha.oil.cooldown = t.attacks.list[3].cooldown

		t = T("shooter_musketeer")
		t.attacks.list[2].cooldown = t.attacks.list[2].cooldown * b.towers_keen_accuracy.cooldown_mult
		t.attacks.list[3].cooldown = t.attacks.list[3].cooldown * b.towers_keen_accuracy.cooldown_mult
		t.attacks.list[4].cooldown = t.attacks.list[4].cooldown * b.towers_keen_accuracy.cooldown_mult

		t = T("aura_ranger_thorn")
		t.aura.cooldown = t.aura.cooldown * b.towers_keen_accuracy.cooldown_mult

		t = T("shooter_longbow")
		t.attacks.list[3].cooldown = t.attacks.list[3].cooldown * b.towers_keen_accuracy.cooldown_mult

		t = T("tower_sorcerer")
		balance.towers.sorcerer.polymorph.cooldown = balance.towers.sorcerer.polymorph.cooldown * b.towers_keen_accuracy.cooldown_mult
		t.powers.polymorph.cooldown_base = balance.towers.sorcerer.polymorph.cooldown - t.powers.polymorph.cooldown_inc

		t = T("tower_archmage")
		t.attacks.list[2].cooldown = t.attacks.list[2].cooldown * b.towers_keen_accuracy.cooldown_mult
		balance.towers.archmage.twister.cooldown = t.attacks.list[2].cooldown
	end

	local all_heroes = {
		"hero_10yr",
		"hero_dracolich",
		"hero_wilbur",
		"hero_dianyun",
		"hero_eiskalt",
		"hero_vesper",
		"hero_raelyn",
		"hero_muyrn",
		"hero_venom",
		"hero_builder",
		"hero_hunter",
		"hero_space_elf",
		"hero_robot",
		"hero_mecha",
		"hero_lumenir",
		"hero_dragon_gem",
		"hero_bird",
		"hero_dragon_bone",
		"hero_dragon_arb",
		"hero_spider",
		"hero_witch",
		"hero_lava",
		"hero_bolin",
		"hero_gerald",
		"hero_ignus",
		"hero_elora",
		"hero_oni",
		"hero_thor",
		"hero_magnus",
		"hero_denas",
		"hero_hacksaw",
		"hero_ingvar",
		"kr4_hero_malik",
		"hero_voodoo_witch",
		"hero_beastmaster",
		"hero_priest",
		"hero_wizard",
		"hero_dragon",
		"hero_dwarf",
		"hero_elves_archer",
		"hero_arivan",
		"hero_phoenix",
		"hero_veznan",
		"hero_faustus",
		"hero_jack_o_lantern",
	}

	u = self:get_upgrade("heroes_desperate_effort")

	if u then
		local armor_p = b.heroes_desperate_effort.armor_penetration
		local all_bullets = {}

		function all_bullets:contains(value)
			for _, v in ipairs(self) do
			  if v == value then
				  return true
			  end
			end
			return false
		end

		for _, h in pairs(all_heroes) do
			if T(h).melee then
				for _, ma in pairs(T(h).melee.attacks) do
					if ma.basic_attack then
						ma.reduce_armor = ma.reduce_armor + armor_p
						ma.reduce_magic_armor = ma.reduce_magic_armor + armor_p
					end
				end
			end

			if T(h).ranged then
				for _, ra in pairs(T(h).ranged.attacks) do
					if ra.basic_attack then
						if ra.bullet and T(ra.bullet) and not all_bullets:contains(ra.bullet) then
							table.insert(all_bullets, ra.bullet)
							local bt = T(ra.bullet)
							bt.bullet.reduce_armor = bt.bullet.reduce_armor + armor_p
							bt.bullet.reduce_magic_armor = bt.bullet.reduce_magic_armor + armor_p
						elseif ra.bullets then
							for i, b in ipairs(ra.bullets) do
								local bullet = T(b)
								if bullet and not all_bullets:contains(b) then
									table.insert(all_bullets, b)
									bullet.bullet.reduce_armor = bullet.bullet.reduce_armor + armor_p
									bullet.bullet.reduce_magic_armor = bullet.bullet.reduce_magic_armor + armor_p
								end
							end
						end
					end
				end
			end

			if T(h).timed_attacks then
				for _, ta in pairs(T(h).timed_attacks.list) do
					if ta.basic_attack then
						if ta.bullet and T(ta.bullet) and not all_bullets:contains(ta.bullet) then
							table.insert(all_bullets, ta.bullet)
							local bt = T(ta.bullet)
							bt.bullet.reduce_armor = bt.bullet.reduce_armor + armor_p
							bt.bullet.reduce_magic_armor = bt.bullet.reduce_magic_armor + armor_p
						elseif ta.bullets then
							for i, b in ipairs(ta.bullets) do
								local bullet = T(b)
								if bullet and not all_bullets:contains(b) then
									table.insert(all_bullets, b)
									bullet.bullet.reduce_armor = bullet.bullet.reduce_armor + armor_p
									bullet.bullet.reduce_magic_armor = bullet.bullet.reduce_magic_armor + armor_p
								end
							end
						end
					end
				end
			end
		end
	end

	u = self:get_upgrade("heroes_visual_learning")

	if u then
		u.modifier = "mod_upgrade_visual_learning"
		u.distance_to_trigger = b.heroes_visual_learning.distance_to_trigger
	end

	u = self:get_upgrade("heroes_lone_wolves")

	if u then
		u.modifier = "mod_upgrade_lone_wolves"
		u.distance_to_trigger = b.heroes_lone_wolves.distance_to_trigger
	end

	u = self:get_upgrade("heroes_unlimited_vigor")

	if u then
		local cd_factor = b.heroes_unlimited_vigor.cooldown_factor

		for _, h in pairs(all_heroes) do
			local ultimate = T(h).hero.skills.ultimate
			if ultimate and ultimate.cooldown and type(ultimate.cooldown) == "table" and ultimate.cooldown[1] then
				for i = 1, 4 do
					T(h).hero.skills.ultimate.cooldown[i] = T(h).hero.skills.ultimate.cooldown[i] * cd_factor
				end
			end
		end
	end

	u = self:get_upgrade("heroes_nimble_physique")

	if u then
		local c_upg = E:create_entity("controller_upgrade_heroes_nimble_physique")

		simulation:queue_insert_entity(c_upg)
	end

	u = self:get_upgrade("heroes_lethal_focus")

	if u then
		u.total_cards = b.heroes_lethal_focus.deck_data.total_cards
		u.trigger_cards = b.heroes_lethal_focus.deck_data.trigger_cards
		u.damage_factor = b.heroes_lethal_focus.damage_factor
		u.damage_factor_area = b.heroes_lethal_focus.damage_factor_area
	end

	u = self:get_upgrade("heroes_limit_pushing")

	if u then
		u.total_cards = b.heroes_limit_pushing.deck_data.total_cards
		u.trigger_cards = b.heroes_limit_pushing.deck_data.trigger_cards
	end

	u = self:get_upgrade("reinforcements_master_blacksmiths")

	if u then
		local portrait_idxs = {
			25,
			26,
			27
		}

		for i = 1, 3 do
			local t = T("soldier_reinforcement_basic_0" .. i)

			t.unit.damage_factor = b.reinforcements_master_blacksmiths.damage_factor
			t.health.armor = b.reinforcements_master_blacksmiths.armor
			t.render.sprites[1].prefix = "reinforcements_lvl2_0" .. i
			t.info.portrait = "gui_bottom_info_image_soldiers_00" .. portrait_idxs[i]
		end
	end

	u = self:get_upgrade("reinforcements_intense_workout")

	if u then
		for i = 1, 3 do
			local t = T("soldier_reinforcement_basic_0" .. i)

			t.health.hp_max = t.health.hp_max * b.reinforcements_intense_workout.hp_factor
			t.reinforcement.duration = t.reinforcement.duration + b.reinforcements_intense_workout.duration_extra
		end
	end

	u = self:get_upgrade("reinforcements_rebel_militia")

	if u then
		for i = 1, 2 do
			local num = km.zmod(i, 2)

			E:set_template("re_current_" .. i, E:get_template("soldier_reinforcement_rebel_militia_0" .. num))
		end
	end

	u = self:get_upgrade("reinforcements_shadow_archer")

	if u then
		for i = 1, 1 do
			local num = km.zmod(i, 2)

			E:set_template("re_current_" .. i, E:get_template("soldier_reinforcement_shadow_archer_0" .. num))
		end
	end

	u = self:get_upgrade("towers_royal_training")

	if u then
		local st = T(T("tower_arborean_emissary_lvl1").barrack.soldier_type)
		st.health._dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_arborean_emissary_lvl1").barrack.standby_soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown

		st = T("pirates_soldier_ogre_cook_lvl2")
		st.health._dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T("pirates_soldier_goblin_deckhand_lvl2")
		st.health._dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown

		for _, n in pairs(all_towers) do
			for i = 1, 4 do
				local barrack = T(n .. i).barrack
				if barrack then
					if type(barrack.soldier_type) == "table" then
						for _, sn in ipairs(barrack.soldier_type) do
							st = T(sn)
							st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
						end
					else
						st = T(barrack.soldier_type)
						st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
					end
				end
			end
		end

		for i = 1, 3 do
			T("tower_barrel_lvl4").attacks.list[3].cooldown[i] = T("tower_barrel_lvl4").attacks.list[3].cooldown[i] - b.towers_royal_training.reinforcements_cooldown
		end

		T("re_current_1").cooldown = T("re_current_1").cooldown - b.towers_royal_training.reinforcements_cooldown

		st = T(T("tower_paladin").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_wildling").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_barbarian").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_templar").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_assassin").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_barrack_dwarf").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_arborean_emissary_lvl1").barrack.soldier_type)
		st.health.dead_lifetime = st.health._dead_lifetime
		st.health._dead_lifetime = nil
		st = T(T("tower_entwood").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_frankenstein").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		for i = 2, 3 do
			st = T(T("tower_elven_barrack_lvl" .. i).barrack.soldier_type)
			st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		end
		st = T(T("tower_blade").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_special_elf").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_drow").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		for i = 2, 4 do
			st = T(T("tower_twilight_elves_barrack_lvl" .. i).barrack.soldier_type)
			st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		end
		local dead_lifetime = st.health.dead_lifetime
		st = T(st.death_spawns.name)
		st.health.dead_lifetime = dead_lifetime - st.reinforcement.duration
		st = T(T("tower_spirit_mausoleum_lvl4").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_warmongers_barrack_lvl4").powers.promotion.unit_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_hammerhold_archer").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_barrack_amazonas").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_barrack_pirates").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_barrack_pirates_w_flamer").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_barrack_pirates_w_anchor").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_stage_28_priests_barrack").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_barrack_mercenaries").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_ewok").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T(T("tower_sorcerer").barrack.soldier_type)
		st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
		st = T("pirates_soldier_ogre_cook_lvl2")
		st.health.dead_lifetime = st.health._dead_lifetime
		st.health._dead_lifetime = nil
		st = T("pirates_soldier_goblin_deckhand_lvl2")
		st.health.dead_lifetime = st.health._dead_lifetime
		st.health._dead_lifetime = nil
	end

	u = self:get_upgrade("reinforcements_thorny_armor")

	if u then
		local portrait_idxs = {
			31,
			33
		}

		for i = 1, 2 do
			local num = km.zmod(i, 2)
			local t = T("soldier_reinforcement_rebel_militia_0" .. num)

			t.health.spiked_armor = b.reinforcements_thorny_armor.spiked_armor
			t.render.sprites[1].prefix = "reinforcements_lvl4_0" .. num
			t.info.portrait = "gui_bottom_info_image_soldiers_00" .. portrait_idxs[i]
		end
	end

	u = self:get_upgrade("reinforcements_night_veil")

	if u then
		for i = 1, 1 do
			local num = km.zmod(i, 2)
			local t = T("soldier_reinforcement_shadow_archer_0" .. num)

			t.ranged.attacks[1].max_range = t.ranged.attacks[1].max_range + b.reinforcements_night_veil.extra_range
			t.ranged.attacks[1].cooldown = t.ranged.attacks[1].cooldown - b.reinforcements_night_veil.cooldown_red
			t.render.sprites[1].prefix = "reinforcements_lvl4_0" .. num + 2
			t.info.portrait = "gui_bottom_info_image_soldiers_0032"

			local t = T("arrow_soldier_re_shadow_archer")

			t.render.sprites[1].name = "reinforcements_lvl4_03_arrow"
		end
	end

	u = self:get_upgrade("alliance_merciless")

	if u then
		u.damage_factor_per_tower = b.alliance_merciless.damage_factor_per_tower
	end

	u = self:get_upgrade("alliance_corageous_stand")

	if u then
		u.hp_factor_per_tower = b.alliance_corageous_stand.hp_factor_per_tower
	end

	u = self:get_upgrade("alliance_shady_company")

	if u then
		local slot = storage:load_slot()
		local heroes = 0

		for _, h in ipairs(slot.heroes.team) do
			if T(h).hero.team == TEAM_DARK_ARMY then
				heroes = heroes + 1
			end
		end

		if heroes > 0 then
			local tower_t, bullet_t, soldier_t
			local d_mult = 1 + b.alliance_shady_company.damage_extra * heroes

			for i = 1, 4 do
				tower_t = T("tower_royal_archers_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			tower_t = T("tower_arcane_wizard_lvl1")
			bullet_t = T(tower_t.attacks.list[1].bullet)

			for i = 1, 4 do
				bullet_t.bullet.damage_min_config[i] = math.ceil(bullet_t.bullet.damage_min_config[i] * d_mult)
				bullet_t.bullet.damage_max_config[i] = math.ceil(bullet_t.bullet.damage_max_config[i] * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_paladin_covenant_lvl" .. i)
				soldier_t = T(tower_t.barrack.soldier_type)
				soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
				soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
				if soldier_t.powers then
					soldier_t = soldier_t.powers.lead.b
					soldier_t.basic_attack.damage_min = math.ceil(soldier_t.basic_attack.damage_min * d_mult)
					soldier_t.basic_attack.damage_max = math.ceil(soldier_t.basic_attack.damage_max * d_mult)
				end
			end

			for i = 1, 4 do
				tower_t = T("tower_arborean_emissary_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			tower_t = T("tower_elven_stargazers_lvl1")
			bullet_t = T(tower_t.attacks.list[1].bullet)

			for i = 1, 4 do
				bullet_t.bullet.damage_min_config[i] = math.ceil(bullet_t.bullet.damage_min_config[i] * d_mult)
				bullet_t.bullet.damage_max_config[i] = math.ceil(bullet_t.bullet.damage_max_config[i] * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_tricannon_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
				if i == 4 then
					bullet_t = T(tower_t.attacks.list[1].bullet_overheated)
					bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
					bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
				end
			end

			for i = 1, 4 do
				tower_t = T("tower_demon_pit_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				soldier_t = T(bullet_t.bullet.hit_payload)
				soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
				soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_ballista_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_rocket_gunners_lvl" .. i)
				soldier_t = T(tower_t.barrack.soldier_type)
				soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
				soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
				bullet_t = T(soldier_t.ranged.attacks[1].bullet)
				bullet_t.bullet.damage_min_config[i] = math.ceil(bullet_t.bullet.damage_min_config[i] * d_mult)
				bullet_t.bullet.damage_max_config[i] = math.ceil(bullet_t.bullet.damage_max_config[i] * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_necromancer_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_flamespitter_lvl" .. i)

				local aura_t = T(tower_t.attacks.list[1].aura)

				aura_t.damage_min_config[i] = math.ceil(aura_t.damage_min_config[i] * d_mult)
				aura_t.damage_max_config[i] = math.ceil(aura_t.damage_max_config[i] * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_barrel_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_sand_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_ghost_lvl" .. i)
				soldier_t = T(tower_t.barrack.soldier_type)
				soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
				soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_ray_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			tower_t = T("tower_ray_lvl4")
			bullet_t = T(tower_t.attacks.list[2].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			for i = 1, 4 do
				tower_t = T("tower_dark_elf_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_dwarf_lvl" .. i)
				soldier_t = T(tower_t.barrack.soldier_type)
				soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
				soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_hermit_toad_lvl" .. i)

				for b_i = 1, 2 do
					bullet_t = T(tower_t.attacks.list[b_i].bullet)
					bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
					bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
				end
			end

			for i = 1, 4 do
				tower_t = T("tower_sparking_geode_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			soldier_t = T(T("tower_paladin").barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			soldier_t.melee.attacks[2].damage_min = math.ceil(soldier_t.melee.attacks[2].damage_min * d_mult)
			soldier_t.melee.attacks[2].damage_max = math.ceil(soldier_t.melee.attacks[2].damage_max * d_mult)

			soldier_t = T(T("tower_wildling").barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			soldier_t = T(T("tower_barbarian").barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			bullet_t = T(soldier_t.ranged.attacks[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			soldier_t = T(T("tower_templar").barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			soldier_t = T(T("tower_assassin").barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			tower_t = T("tower_archer_dwarf")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			soldier_t = T(T("tower_barrack_dwarf").barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			soldier_t = T(T("tower_arborean_emissary_lvl1").barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			soldier_t = T(T("tower_arborean_emissary_lvl1").barrack.standby_soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			bullet_t = T(soldier_t.ranged.attacks[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			tower_t = T("tower_entwood")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			bullet_t = T(tower_t.attacks.list[2].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			soldier_t = T(tower_t.barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			bullet_t = T(soldier_t.ranged.attacks[2].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			tower_t = T("tower_frankenstein")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			local mod = T(bullet_t.bullet.mod)
			mod.dps.damage_min = math.ceil(mod.dps.damage_min * d_mult)
			mod.dps.damage_max = math.ceil(mod.dps.damage_max * d_mult)
			soldier_t = T(tower_t.barrack.soldier_type)
			for index, value in ipairs(soldier_t.melee.attacks[1].damage_min_lvls) do
				soldier_t.melee.attacks[1].damage_min_lvls[index] = math.ceil(value * d_mult)
			end
			for index, value in ipairs(soldier_t.melee.attacks[1].damage_max_lvls) do
				soldier_t.melee.attacks[1].damage_max_lvls[index] = math.ceil(value * d_mult)
			end

			tower_t = T("tower_tesla")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bounce_damage_min = math.ceil(bullet_t.bounce_damage_min * d_mult)
			bullet_t.bounce_damage_max = math.ceil(bullet_t.bounce_damage_max * d_mult)

			for i = 1, 4 do
				tower_t = T("tower_rock_thrower_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
				if tower_t.barrack then
					soldier_t = T(tower_t.barrack.soldier_type)
					soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
					soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
				end
			end

			for i = 2, 3 do
				soldier_t = T(T("tower_elven_barrack_lvl" .. i).barrack.soldier_type)
				soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
				soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
				bullet_t = T(soldier_t.ranged.attacks[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			soldier_t = T(T("tower_blade").barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			soldier_t = T(T("tower_special_elf").barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			bullet_t = T(soldier_t.timed_attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			soldier_t = T(T("tower_drow").barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			soldier_t.melee.attacks[2].damage_inc = math.ceil(soldier_t.melee.attacks[2].damage_inc * d_mult)
			bullet_t = T(soldier_t.ranged.attacks[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			for i = 2, 4 do
				soldier_t = T(T("tower_twilight_elves_barrack_lvl" .. i).barrack.soldier_type)
				for i, a in ipairs(soldier_t.melee.attacks) do
					a.damage_min = math.ceil(a.damage_min * d_mult)
					a.damage_max = math.ceil(a.damage_max * d_mult)
				end
				bullet_t = T(soldier_t.ranged.attacks[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end
			soldier_t = T(soldier_t.death_spawns.name)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			for i = 1, 3 do
				tower_t = T("tower_mage_" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end
			tower_t = T("tower_wild_magus")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			tower_t = T("tower_high_elven")
			for i, bn in ipairs(tower_t.attacks.list[1].bullets) do
				bullet_t = T(bn)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 2, 3 do
				tower_t = T("tower_archer_" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end
			tower_t = T("tower_totem")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			tower_t = T("tower_crossbow")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			tower_t = T("tower_musketeer")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			soldier_t = T(T("tower_spirit_mausoleum_lvl4").barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			soldier_t = T(T("tower_spirit_mausoleum_lvl4").powers.spectral_communion.unit_type[1])
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			for i = 2, 4 do
				tower_t = T("tower_spirit_mausoleum_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_warmongers_barrack_lvl" .. i)
				soldier_t = T(tower_t.barrack.soldier_type)
				soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
				soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
				if tower_t.powers then
					soldier_t = T(tower_t.powers.promotion.unit_type)
					soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
					soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
				end
			end

			tower_t = T("tower_hammerhold_archer")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			soldier_t = T(tower_t.barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			bullet_t = T(soldier_t.ranged.attacks[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			soldier_t = T(tower_t.powers.war_elephants.unit_type[1])
			soldier_t.ranged.attacks[1].damage_min = math.ceil(soldier_t.ranged.attacks[1].damage_min * d_mult)
			soldier_t.ranged.attacks[1].damage_max = math.ceil(soldier_t.ranged.attacks[1].damage_max * d_mult)

			tower_t = T("tower_pirate_watchtower")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			bullet_t = T(T("pirate_watchtower_parrot").custom_attack.bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			tower_t = T("tower_faerie_dragon")
			for i, d in ipairs(tower_t.powers.improve_shot.damage) do
				tower_t.powers.improve_shot.damage[i] = math.ceil(d * d_mult)
			end
			soldier_t = T("faerie_dragon")
			bullet_t = T(soldier_t.custom_attack.bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			tower_t = T("tower_barrack_amazonas")
			soldier_t = T(tower_t.barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			tower_t = T("tower_barrack_pirates")
			soldier_t = T(tower_t.barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			tower_t = T("tower_barrack_pirates_w_flamer")
			soldier_t = T(tower_t.barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			bullet_t = T(soldier_t.ranged.attacks[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			tower_t = T("tower_barrack_pirates_w_anchor")
			soldier_t = T(tower_t.barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			tower_t = T("tower_stage_28_priests_barrack")
			soldier_t = T(tower_t.barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			bullet_t = T(soldier_t.ranged.attacks[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			soldier_t = T(soldier_t.death_spawns.name)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			tower_t = T("tower_barrack_mercenaries")
			soldier_t = T(tower_t.barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			tower_t = T("tower_ewok")
			soldier_t = T(tower_t.barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			bullet_t = T(soldier_t.ranged.attacks[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			tower_t = T("tower_stage_13_sunray")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			local mod_t = T(bullet_t.bullet.mod)
			mod_t.dps.damage_min = math.ceil(mod_t.dps.damage_min * d_mult)
			mod_t.dps.damage_max = math.ceil(mod_t.dps.damage_max * d_mult)

			tower_t = T("tower_stage_20_arborean_honey")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			soldier_t = T(tower_t.attacks.list[2].entity)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			for i = 2, 3 do
				tower_t = T("tower_elven_archer_" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			tower_t = T("tower_arcane_archer")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			tower_t = T("tower_silver")
			for i, name in ipairs(tower_t.attacks.list[1].bullets) do
				bullet_t = T(name)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			local mod = T("mod_ignis_altar_damage")
			for i = 1, #mod.damages do
				mod.damages[i] = math.ceil(mod.damages[i] * d_mult)
			end
			tower_t = T("tower_ignis_altar_lvl4")
			soldier_t = T(tower_t.barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			for i = 2, 3 do
				tower_t = T("tower_engineer_" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			tower_t = T("tower_bfg")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			tower_t = T("tower_dwaarp")
			tower_t.attacks.list[1].damage_min = math.ceil(tower_t.attacks.list[1].damage_min * d_mult)
			tower_t.attacks.list[1].damage_max = math.ceil(tower_t.attacks.list[1].damage_max * d_mult)
			tower_t.attacks.list[4].damage_min = math.ceil(tower_t.attacks.list[4].damage_min * d_mult)
			tower_t.attacks.list[4].damage_max = math.ceil(tower_t.attacks.list[4].damage_max * d_mult)

			soldier_t = T("soldier_mecha")
			bullet_t = T(soldier_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			soldier_t = T("shooter_ranger")
			bullet_t = T(soldier_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			tower_t = T("tower_sorcerer")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			soldier_t = T(tower_t.barrack.soldier_type)
			soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
			soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)

			tower_t = T("tower_archmage")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			tower_t = T("tower_sunray")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			tower_t = T("tower_bastion")
			bullet_t = T(tower_t.attacks.list[1].payload_name)
			bullet_t.aura.damage_min = math.ceil(bullet_t.aura.damage_min * d_mult)
			bullet_t.aura.damage_max = math.ceil(bullet_t.aura.damage_max * d_mult)

			for i = 1, 4 do
				tower_t = T("tower_deep_devils_lvl" .. i)
				soldier_t = T(tower_t.barrack.soldier_type)
				soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
				soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
				bullet_t = T(soldier_t.ranged.attacks[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("deep_devils_shooter_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_ogres_barrack_lvl" .. i)
				for _, sn in ipairs(tower_t.barrack.soldier_type) do
					soldier_t = T(sn)
					soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
					soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
				end
			end
			tower_t = T("pirates_soldier_ogre_musket_lvl3")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			tower_t = T("pirates_soldier_ogre_slinger_lvl4")
			bullet_t = T(tower_t.attacks.list[1].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			bullet_t = T(tower_t.attacks.list[2].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
		end
	end

	u = self:get_upgrade("alliance_friends_of_the_crown")

	if u then
		local slot = storage:load_slot()
		local cost_red = 0

		for _, h in ipairs(slot.heroes.team) do
			if T(h).hero.team == TEAM_LINIREA then
				cost_red = cost_red + b.alliance_friends_of_the_crown.cost_red_per_hero
			end
		end

		if cost_red > 0 then
			for _, n in pairs(all_towers) do
				for i = 1, 4 do
					T(n .. i).tower.price = T(n .. i).tower.price - cost_red
				end
			end

			T("tower_paladin").tower.price = T("tower_paladin").tower.price - cost_red
			T("tower_wildling").tower.price = T("tower_wildling").tower.price - cost_red
			T("tower_barbarian").tower.price = T("tower_barbarian").tower.price - cost_red
			T("tower_templar").tower.price = T("tower_templar").tower.price - cost_red
			T("tower_assassin").tower.price = T("tower_assassin").tower.price - cost_red
			T("tower_archer_dwarf").tower.price = T("tower_archer_dwarf").tower.price - cost_red
			T("tower_barrack_dwarf").tower.price = T("tower_barrack_dwarf").tower.price - cost_red
			T("tower_entwood").tower.price = T("tower_entwood").tower.price - cost_red
			T("tower_tesla").tower.price = T("tower_tesla").tower.price - cost_red
			T("tower_frankenstein").tower.price = T("tower_frankenstein").tower.price - cost_red
			for i = 2, 3 do
				T("tower_elven_barrack_lvl" .. i).tower.price = T("tower_elven_barrack_lvl" .. i).tower.price - cost_red
			end
			T("tower_blade").tower.price = T("tower_blade").tower.price - cost_red
			T("tower_special_elf").tower.price = T("tower_special_elf").tower.price - cost_red
			T("tower_drow").tower.price = T("tower_drow").tower.price - cost_red
			for i = 2, 4 do
				T("tower_twilight_elves_barrack_lvl" .. i).tower.price = T("tower_twilight_elves_barrack_lvl" .. i).tower.price - cost_red
			end
			for i = 1, 3 do
				T("tower_mage_" .. i).tower.price = T("tower_mage_" .. i).tower.price - cost_red
			end
			T("tower_wild_magus").tower.price = T("tower_wild_magus").tower.price - cost_red
			T("tower_high_elven").tower.price = T("tower_high_elven").tower.price - cost_red
			for i = 2, 3 do
				T("tower_archer_" .. i).tower.price = T("tower_archer_" .. i).tower.price - cost_red
			end
			T("tower_totem").tower.price = T("tower_totem").tower.price - cost_red
			T("tower_crossbow").tower.price = T("tower_crossbow").tower.price - cost_red
			T("tower_musketeer").tower.price = T("tower_musketeer").tower.price - cost_red
			for i = 2, 4 do
				T("tower_spirit_mausoleum_lvl" .. i).tower.price = T("tower_spirit_mausoleum_lvl" .. i).tower.price - cost_red
			end
			T("tower_hammerhold_archer").tower.price = T("tower_hammerhold_archer").tower.price - cost_red
			T("tower_random_lvl4").tower.price = T("tower_random_lvl4").tower.price - cost_red
			T("tower_stage_13_sunray").tower.price = T("tower_stage_13_sunray").tower.price - cost_red
			T("tower_stage_20_arborean_honey").tower.price = T("tower_stage_20_arborean_honey").tower.price - cost_red
			for i = 2, 3 do
				T("tower_elven_archer_" .. i).tower.price = T("tower_elven_archer_" .. i).tower.price - cost_red
			end
			T("tower_arcane_archer").tower.price = T("tower_arcane_archer").tower.price - cost_red
			T("tower_silver").tower.price = T("tower_silver").tower.price - cost_red
			for i = 2, 3 do
				T("tower_engineer_" .. i).tower.price = T("tower_engineer_" .. i).tower.price - cost_red
			end
			T("tower_bfg").tower.price = T("tower_bfg").tower.price - cost_red
			T("tower_dwaarp").tower.price = T("tower_dwaarp").tower.price - cost_red
			T("tower_mech").tower.price = T("tower_mech").tower.price - cost_red
			T("tower_sorcerer").tower.price = T("tower_sorcerer").tower.price - cost_red
			T("tower_archmage").tower.price = T("tower_archmage").tower.price - cost_red
		end
	end

	u = self:get_upgrade("alliance_shared_reserves")

	local c_upg

	if u then
		c_upg = E:create_entity("controller_upgrades_alliance")

		simulation:queue_insert_entity(c_upg)
	end

	u = self:get_upgrade("alliance_seal_of_punishment")

	if u and c_upg then
		c_upg.seal = "decal_upgrade_alliance_seal_of_punishment"
	end

	u = self:get_upgrade("alliance_flux_altering_coils")

	if u and c_upg then
		c_upg.coil = "decal_upgrade_alliance_flux_altering_coils"
	end

	u = self:get_upgrade("alliance_display_of_true_might_linirea")

	if u then
		u.mod_linirea = "mod_upgrade_alliance_display_of_true_might_linirea"
		u.overlay_linirea = "decal_upgrade_alliance_display_of_true_might_linirea_overlay"
	end

	u = self:get_upgrade("alliance_display_of_true_might_dark")

	if u then
		u.mod_dark_army = "mod_upgrade_alliance_display_of_true_might_dark_army"
		u.overlay_dark_army = "decal_upgrade_alliance_display_of_true_might_dark_army_overlay"
	end
end

return upgrades
