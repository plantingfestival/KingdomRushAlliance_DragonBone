-- chunkname: @./kr5/data/levels/level501.lua

local log = require("klua.log"):new("level01")
local signal = require("hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("klua.vector")
local P = require("path_db")

require("constants")

local function fts(v)
	return v / FPS
end

local level = {}

function level:init(store)
	if store.level_mode == GAME_MODE_CAMPAIGN then
		self.manual_hero_insertion = true
	end
end

function level:update(store)
	if store.level.sublevel then
		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		return
	end

	if store.level_mode == GAME_MODE_CAMPAIGN then
		signal.emit("wave-notification", "view", "TUTORIAL_1")

		self.show_next_wave_balloon = false

		while store.wave_group_number < 1 do
			coroutine.yield()
		end

		while store.wave_group_number < 2 do
			coroutine.yield()
		end

		signal.emit("wave-notification", "view", "POWER_REINFORCEMENT")

		while store.wave_group_number < 3 do
			coroutine.yield()
		end

		local insert_denas = true

		if insert_denas then
			signal.emit("wave-notification", "view", "TIP_HEROES")

			while store.paused do
				coroutine.yield()
			end

			log.debug("-- Move hero to the left of the screen")

			local dp = store.level.locations.exits[1].pos
			local hero = LU.insert_hero_kr5(store, "hero_king_denas", dp)

			hero.pos = V.v(-REF_OX - 50, dp.y)
			hero.nav_rally.center = V.v(dp.x, dp.y)
			hero.nav_rally.pos = V.vclone(hero.nav_rally.center)

			signal.emit("wave-notification", "view", "POWER_HERO")

			while store.paused do
				coroutine.yield()
			end
		end

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		log.debug("-- WON")
	end
end

return level
