-- chunkname: @./kr5/data/levels/level502.lua

local log = require("klua.log"):new("level01")
local signal = require("hump.signal")
local storage = require("storage")
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
		local slot = storage:load_slot(nil, true)
		local status = table.clone(slot.heroes.status.hero_king_denas)
		local hero = LU.insert_hero_kr5(store, "hero_king_denas", nil, status)

		LU.insert_relic_kr5(store, "relic_banner_of_command", hero)
		signal.emit("wave-notification", "view", "TUTORIAL_RELIC")

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		log.debug("-- WON")
	end
end

return level
