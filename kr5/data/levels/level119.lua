-- chunkname: @./kr3/data/levels/level22.lua

local log = require("klua.log"):new("level09")
local km = require("klua.macros")
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

function level:load(store)
	return
end

function level:update(store)
	coroutine.yield()

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	if store.level_mode == GAME_MODE_CAMPAIGN then
		while store.wave_group_number ~= 16 do
			coroutine.yield()
		end

		U.y_wait(store, 20)

		local boss = E:create_entity("eb_ulgukhai")

		boss.nav_path.pi = 2
		boss.nav_path.ni = P:get_start_node(boss.nav_path.pi)

		LU.queue_insert(store, boss)
		coroutine.yield()
		
		end

		megaspawner.interrupt = true

		while boss.phase ~= "death_end" do
			coroutine.yield()
		end

		U.y_wait(store, 1)
	end

	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end
end

return level
