-- chunkname: @./kr5/data/levels/level9001.lua

local log = require("klua.log"):new("level9001")
local signal = require("hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("klua.vector")
local P = require("path_db")

require("constants")

local TU = require("test.test_utils")

local function fts(v)
	return v / FPS
end

local km = require("klua.macros")
local GS = require("game_settings")
local level = {
	sublevel = {}
}
local relic_shorcuts = {
	mirror = "relic_mirror_of_inversion",
	locket = "relic_locket_of_the_unforgiven",
	necro = "relic_locket_of_the_unforgiven",
	hammer = "relic_hammer_of_the_blessed",
	guardian = "relic_guardian_orb",
	banner = "relic_banner_of_command"
}
local configs = string.split(main.params.custom2, "#")
local heroe_configs = string.split(configs[1], "|")
local parsed_configs = {}

for index, raw_config in ipairs(heroe_configs) do
	local parsed_config = {}
	local data = string.split(raw_config, "/")

	print(getfulldump(data))

	parsed_config.hero_id = data[1]
	parsed_config.relic = data[2]
	parsed_config.level = tonumber(data[3] or 1)
	parsed_config.skills = nil

	local skills_string = data[4]

	if skills_string then
		parsed_config.skills = {}

		for i = 1, #skills_string do
			table.insert(parsed_config.skills, skills_string:sub(i, i))
		end
	end

	table.insert(parsed_configs, parsed_config)
end

print(getfulldump(parsed_configs))

local level_config = {}

do
	local raw_config = configs[2]

	if raw_config then
		local data = string.split(raw_config, "|")
		local wave = tonumber(data[1])
		local gold = tonumber(data[2])

		level_config.wave = wave
		level_config.gold = gold
	end
end

function level:preprocess(store)
	store.level_name = "level" .. main.params.custom
	self.sublevel = LU.load_level(store, store.level_name)

	for k, v in pairs(self.sublevel) do
		if k ~= "load" and k ~= "preprocess" and k ~= "update" then
			self[k] = v
		end
	end

	for k, hero_config in pairs(parsed_configs) do
		log.info(getfulldump(hero_config))
		table.insert(level.required_textures, "go_" .. hero_config.hero_id)
	end
end

function level:init(store)
	level.manual_hero_insertion = true
end

function level:load(store)
	if self.sublevel.load then
		self.sublevel:load(store)
	end

	if level_config.wave then
		local W = require("wave_db")

		W.db.groups = table.slice(W.db.groups, level_config.wave)
	end
end

function level:update(store)
	if level_config.gold then
		game.store.player_gold = level_config.gold
	end

	coroutine.yield()

	local exits = store.level.locations.exits
	local heroes = {}

	signal.emit("unlock-user-power", 1)

	for k, hero_config in ipairs(parsed_configs) do
		log.info("Hero: %s - relic: %s - relic_template: %s", hero_config.hero_id, hero_config.relic, relic_shorcuts[hero_config.relic])

		local pos = exits[km.zmod(k + 1, #exits)].pos
		local ht = E:get_template(hero_config.hero_id)
		local skills

		if hero_config.skills then
			skills = {}

			for k, v in pairs(ht.hero.skills) do
				local skill_config = hero_config.skills[v.hr_order]

				if skill_config then
					skills[k] = tonumber(skill_config)
				end
			end
		end

		local status = TU.create_status_for_hero_kr5(skills)

		log.info("Hero: %s - status: %s", hero_config.hero_id, getfulldump(status))

		local h = LU.insert_hero_kr5(store, hero_config.hero_id, pos, status)

		signal.emit("unlock-user-power", k + 1)

		if hero_config.relic and relic_shorcuts[hero_config.relic] then
			LU.insert_relic_kr5(store, relic_shorcuts[hero_config.relic], h)
		end

		table.insert(heroes, h)
	end

	coroutine.yield()

	if self.sublevel.update then
		self.sublevel:update(store)
	end
end

return level
