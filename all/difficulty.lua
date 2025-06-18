-- chunkname: @./all/difficulty.lua

local E = require("entity_db")
local GS = require("game_settings")

require("constants")

local difficulty = {}

function difficulty:set_level(level)
	self.level = level
end

function difficulty:patch_templates()
	local function PT(t, key)
		if t and t[key] and type(t[key]) == "table" then
			t[key] = t[key][self.level] or t[key][3]

			return true
		end

		return false
	end

	if KR_GAME == "kr1" then
		local hp_factor_soldier = GS.difficulty_soldier_hp_max_factor[self.level]

		for _, t in pairs(E:filter_templates("soldier")) do
			if t.hero and t.hero.level_stats and t.hero.level_stats.hp_max then
				local m = t.hero.level_stats.hp_max

				for i = 1, #m do
					m[i] = math.floor(m[i] * hp_factor_soldier)
				end
			elseif not PT(t.health, "hp_max") and hp_factor_soldier and hp_factor_soldier ~= 1 then
				if not t.health.hp_max then
					log.debug("no hp_max in %s", t.template_name)
				else
					t.health.hp_max = math.floor(t.health.hp_max * hp_factor_soldier)
				end
			end
		end
	end

	local hp_factor_enemy = GS.difficulty_enemy_hp_max_factor[self.level]
	local speed_factor_enemy = GS.difficulty_enemy_speed_factor[self.level]

	for _, t in pairs(E:filter_templates("enemy")) do
		if not PT(t.health, "hp_max") and hp_factor_enemy ~= 1 then
			if KR_GAME == "kr1" then
				t.health.hp_max = math.floor(t.health.hp_max * hp_factor_enemy)
			else
				t.health.hp_max = 10 * math.ceil(t.health.hp_max * hp_factor_enemy / 10)
			end
		end

		if not PT(t.motion, "max_speed") and speed_factor_enemy ~= 1 then
			t.motion.max_speed = t.motion.max_speed * speed_factor_enemy
		end

		PT(t.death_spawns, "quantity")
		PT(t.enemy, "lives_cost")
		PT(t.health, "armor")
		PT(t.health, "magic_armor")
		PT(t.motion, "max_speed")
		PT(t.motion, "speed_limit")

		if t.melee then
			for i, a in ipairs(t.melee.attacks) do
				PT(a, "damage_max")
				PT(a, "damage_min")
				PT(a, "cooldown")
			end
		end

		if t.ranged then
			for i, a in ipairs(t.ranged.attacks) do
				PT(a, "cooldown")
			end
		end

		if t.timed_attacks then
			for i, a in ipairs(t.timed_attacks.list) do
				PT(a, "cooldown")
				PT(a, "damage_max")
				PT(a, "damage_min")
				PT(a, "max_clones")
			end
		end

		PT(t, "power_block_duration")
	end

	for _, t in pairs(E:filter_templates("aura")) do
		PT(t.aura, "damage_max")
		PT(t.aura, "damage_min")
	end

	for _, t in pairs(E:filter_templates("modifier")) do
		PT(t.modifier, "duration")
	end

	for _, t in pairs(E:filter_templates("bullet")) do
		PT(t.bullet, "damage_max")
		PT(t.bullet, "damage_min")
	end
end

return difficulty
