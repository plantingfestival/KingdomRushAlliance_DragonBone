-- chunkname: @./kr1/data/levels/level12.lua

local log = require("klua.log"):new("level21")
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

function level:fn_can_power(store, power_id, pos)
	return V.is_inside(pos, V.r(95, 318, 117, 58))
end

function level:update(store)
	local function check_spawn_boss()
		local has_alive, alive_count, pending_count = LU.has_alive_enemies(store, {"eb_veznan"})
		return alive_count == 0 and pending_count == 0
	end
	if store.level_mode == GAME_MODE_CAMPAIGN then
		local boss = E:create_entity("eb_veznan")

		boss.pos = V.vclone(boss.pos_castle)

		LU.queue_insert(store, boss)

		self.boss = boss

		U.mark_seen(store, boss.template_name)
		coroutine.yield()
		U.y_wait(store, 1)

		self.boss.phase_signal = "welcome"

		while self.boss.phase ~= "castle" do
			coroutine.yield()
		end

		local print_veznan = 0

		local ts = store.tick_ts

		--while not store.waves_finished or LU.has_alive_enemies(store, {"eb_veznan"}) do
		while not store.waves_finished or not check_spawn_boss() do
			coroutine.yield()
		end

		S:queue("KR1_MusicBossFight")

		self.boss.phase_signal = "descend"

		while self.boss.phase ~= "death" do
			coroutine.yield()
		end

		for _, e in pairs(store.entities) do
			if e and e.tower then
				e.tower.blocked = true
			end
		end

		while self.boss.phase ~= "death-end" do
			coroutine.yield()
		end
		
	else
		while store.wave_group_number < 1 do
			coroutine.yield()
		end

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end
	end
end

return level
