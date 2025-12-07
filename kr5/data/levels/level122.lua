-- chunkname: @C:\\Users\\dev02\\Desktop\\Customized KR5\\Kingdom Rush Alliance\\kr5\\data\\levels\\level122.lua

local log = require("klua.log"):new("level122")
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

function level:update(store)
	coroutine.yield()

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	if store.level_mode == GAME_MODE_CAMPAIGN then
		while store.wave_group_number ~= 15 do
			coroutine.yield()
		end

		U.y_wait(store, 20)

		local boss = E:create_entity("eb_myconid")

		boss.nav_path.pi = 2
		boss.nav_path.ni = P:get_start_node(boss.nav_path.pi)

		LU.queue_insert(store, boss)
		coroutine.yield()

		local megaspawner = LU.list_entities(store.entities, "mega_spawner")[1]
		local spawn_nodes = table.deepclone(megaspawner.spawn_nodes)
		local spawn_idx = 1

		while not boss.health.dead do
			if spawn_nodes[1] and boss.nav_path.ni >= spawn_nodes[1] then
				table.remove(spawn_nodes, 1)

				megaspawner.manual_wave = megaspawner.spawn_waves[spawn_idx]
				spawn_idx = km.zmod(spawn_idx + 1, #megaspawner.spawn_waves)
			end

			coroutine.yield()
		end

		megaspawner.interrupt = true

		while boss.phase ~= "death_end" do
			coroutine.yield()
		end

		U.y_wait(store, 1)
	end
	
	if store.level_mode == GAME_MODE_CAMPAIGN then
		while store.wave_group_number ~= store.wave_group_total do
			coroutine.yield()
		end

		local boss

		log.debug("+++++++++++++++ wait for boss")

		while not boss do
			boss = LU.list_entities(store.entities, "eb_myconid")[1]

			coroutine.yield()
		end

		log.debug("+++++++++++++++ wait for boss death")

		while not boss.health.dead do
			coroutine.yield()
		end

		log.debug("+++++++++++++++ wait for spawns")
		U.y_wait(store, boss.on_death_spawn_wait)

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		log.debug("++++++++++++++++ done")
	end
end

return level
