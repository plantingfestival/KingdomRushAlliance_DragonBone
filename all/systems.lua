local log = require("klua.log"):new("systems")
local log_xp = log.xp or log:new("xp")
local log_hp = log.hp or log:new("hp")
local km = require("klua.macros")
local signal = require("hump.signal")

require("klua.table")
require("klua.dump")

local A = require("klove.animation_db")
local AC = require("achievements")
local DI = require("difficulty")
local I = require("klove.image_db")
local SH = require("klove.shader_db")
local E = require("entity_db")
local P = require("path_db")
local F = require("klove.font_db")
local GR = require("grid_db")
local GS = require("game_settings")
local S = require("sound_db")
local UP = require("upgrades")
local W = require("wave_db")
local U = require("utils")
local SU = require("script_utils")
local LU = require("level_utils")
local V = require("klua.vector")
local storage = require("storage")
local EXO = require("exoskeleton")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local balance = require("balance/balance")

require("constants")

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

local function fts(v)
	return v / FPS
end

local sys = {}

sys.level = {}
sys.level.name = "level"

function sys.level:init(store)
	local slot = storage:load_slot(nil, true)
	local upgrade_levels = table.deepclone(slot.upgrades)

	if store.level_challenge and store.level_challenge.restrictions and store.level_challenge.restrictions.upgrade_level then
		local fl = store.level_challenge.restrictions.upgrade_level

		for k, v in pairs(upgrade_levels) do
			upgrade_levels[k] = fl
		end

		log.debug("challenge: forcing all upgrades level to %s", fl)
	end

	UP:set_levels(upgrade_levels)
	DI:set_level(store.level_difficulty)
	GR:load(store.level_name)
	P:load(store.level_name, store.visible_coords)
	W:load(store.level_name, store.level_mode, store.current_wave_ss_data)
	A:load()
	E:load()

	if store.level.data then
		EXO:load(store.level.data.required_exoskeletons)
	end

	if IS_KR5 then
		for k, v in pairs(slot.items.selected) do
			if GS.items_required_exoskeletons[v] then
				EXO:load(GS.items_required_exoskeletons[v])
			end
		end
	end

	local function load_exoskeletons(prefix)
		local FS = love.filesystem
		local path = string.format("%s/data/exoskeletons", KR_PATH_GAME)
		local files = FS.getDirectoryItems(path)
		if not files or #files == 0 then
			return
		end
		files = table.filter(files, function(k, v)
			return string.match(v, "^" .. prefix .. "[^.]-%.lua$")
		end)
		if not files or #files == 0 then
			return
		end
		for i = 1, #files do
			local name = files[i]
			local startPos, endPos = string.find(name, "%.lua$")
			files[i] = string.sub(name, 1, startPos - 1)
		end
	
		EXO:load(files)
	end

	if slot.heroes.team then
		store.selected_team = table.clone(slot.heroes.team)
		store.hero_team = {}
		store.selected_towers = table.clone(slot.towers.selected)
		store.selected_items = table.clone(slot.items.selected)
		store.selected_team_status = {}

		for k, v in ipairs(store.selected_team) do
			store.selected_team_status[v] = table.clone(slot.heroes.status[v])
			load_exoskeletons(v)
		end

		for k, v in ipairs(store.selected_towers) do
			load_exoskeletons(v)
		end
	elseif slot.heroes.selected then
		local hero_name = slot.heroes.selected

		if store.level_challenge and store.level_challenge.restrictions and store.level_challenge.restrictions.forced_hero then
			hero_name = store.level_challenge.restrictions.forced_hero
		end

		local hero_status = table.deepclone(slot.heroes.status[hero_name])

		if store.level_challenge and store.level_challenge.restrictions then
			local fl = store.level_challenge.restrictions.forced_hero_level
			local fsl = store.level_challenge.restrictions.forced_hero_skills_level

			if fl and fl >= 1 and fl <= 10 then
				hero_status.level = fl
				hero_status.xp = GS.hero_xp_thresholds[fl - 1] or 0
			end

			if fsl then
				for k, v in pairs(hero_status.skills) do
					hero_status.skills[k] = fsl
				end
			end

			log.debug("forcing hero level to %s, skills to:%s", fl, fsl)
		end

		store.selected_hero = hero_name
		store.selected_hero_status = hero_status
	end

	if store.level.init then
		store.level:init(store)
	end

	if store.level_challenge and store.level_challenge.restrictions and store.level_challenge.restrictions.upgrade_level then
		store.level.max_upgrade_level = store.level_challenge.restrictions.upgrade_level
	end

	UP:patch_templates(store.level.max_upgrade_level)
	DI:patch_templates()

	if store.level.data then
		store.level.locations = {}

		LU.insert_entities(store, store.level.data.entities_list)
		LU.insert_invalid_path_ranges(store, store.level.data.invalid_path_ranges)

		if not IS_TRILOGY and store.level.data.custom_start_pos then
			LU.set_custom_start_pos(store, store.level.data.custom_start_pos, not IS_MOBILE)
		end
	end

	if store.level_challenge and store.level_challenge.restrictions then
		for k, v in pairs(store.level_challenge.restrictions) do
			store.level[k] = type(v) == "table" and table.deepclone(v) or v
		end
	end

	if store.level.load then
		store.level:load(store)
	end

	store.level.co = nil
	store.level.run_complete = nil
	store.player_gold = math.floor(W:initial_gold() * ((4 - store.level_difficulty) * 0.3 + 1))

	if store.level_mode == GAME_MODE_CAMPAIGN then
		store.lives = 20
	elseif store.level_mode == GAME_MODE_HEROIC then
		store.lives = 1
	elseif store.level_mode == GAME_MODE_IRON then
		store.lives = 1
	elseif store.level_mode == GAME_MODE_ENDLESS then
		store.lives = W:initial_lives() or 10
	end

	store.gems_collected = 0
	store.player_score = 0
	store.game_outcome = nil
	store.main_hero = nil

	if KR_GAME == "kr5" and #store.hero_team == 0 and not store.level.manual_hero_insertion then
		for _, hero_name in ipairs(store.selected_team) do
			LU.insert_hero_kr5(store, hero_name, nil, store.selected_team_status[hero_name])
		end
	end
	
	store.level_init_finished = true

	log.info("level_idx:%02d, level_mode:%d, level_difficulty:%d", store.level_idx, store.level_mode, store.level_difficulty)
end

function sys.level:on_update(dt, ts, store)
	local function store_hero_xp(slot)
		if store.level_challenge then
			log.info("Playing challenge, so skip saving hero xp")

			return
		end

		if KR_GAME == "kr5" then
			for _, hero in ipairs(store.hero_team) do
				local hn = hero.template_name

				if not slot.heroes or not slot.heroes.status or not slot.heroes.status[hn] then
					log.error("Active slot has no heroes status information. Skipping save")
				elseif hero.hero.xp > slot.heroes.status[hn].xp then
					slot.heroes.status[hn].xp = hero.hero.xp
				end
			end
		elseif store.main_hero and store.main_hero.hero and not GS.hero_xp_ephemeral then
			local hn = store.main_hero.template_name

			if not slot.heroes or not slot.heroes.status or not slot.heroes.status[hn] then
				log.error("Active slot has no heroes status information. Skipping save")
			elseif store.main_hero.hero.xp > slot.heroes.status[hn].xp then
				slot.heroes.status[hn].xp = store.main_hero.hero.xp
			end
		end
	end

	if not store.level.update then
		store.level.run_complete = true
	else
		if not store.level.co and not store.level.run_complete then
			store.level.co = coroutine.create(store.level.update)
		end

		if store.level.co then
			local success, error = coroutine.resume(store.level.co, store.level, store)

			if coroutine.status(store.level.co) == "dead" or error ~= nil then
				if error ~= nil then
					log.error("Error running level coro: %s", debug.traceback(store.level.co, error))
				end

				store.level.co = nil
				store.level.run_complete = true
			end
		end
	end

	if not store._common_notifications then
		local slot = storage:load_slot()

		store._common_notifications = true

		if store.level_mode == GAME_MODE_IRON or store.level_mode == GAME_MODE_HEROIC then
			signal.emit("wave-notification", "view", "TIP_UPGRADES")
		elseif store.level_mode == GAME_MODE_ENDLESS then
			signal.emit("wave-notification", "view", "TIP_SURVIVAL")
		elseif KR_GAME == "kr1" and store.selected_hero and not U.is_seen(store, "TIP_HEROES") then
			signal.emit("wave-notification", "icon", "TIP_HEROES")
		elseif KR_GAME == "kr1" and store.level_mode == GAME_MODE_CAMPAIGN and store.level_idx >= 13 and U.count_stars(slot) < 50 and not U.is_seen(store, "TIP_ELITE") then
			signal.emit("wave-notification", "view", "TIP_ELITE")
		end
	end

	if KR_GAME == "kr5" then
		if not store.level.manual_hero_insertion then
			local first_hero

			for _, v in pairs(store.entities) do
				if v.template_name == store.selected_team[1] then
					first_hero = v
				end
			end

			if first_hero then
				signal.emit("hero-added", first_hero)
			end

			local second_hero

			for _, v in pairs(store.entities) do
				if v.template_name == store.selected_team[2] then
					second_hero = v
				end
			end

			if second_hero then
				signal.emit("hero-added", second_hero)
			end
		end
	elseif not store.main_hero and not store.level.locked_hero and not store.level.manual_hero_insertion then
		LU.insert_hero(store)
	end

	if not store.game_outcome then
		if store.lives < 1 then
			log.info("++++ DEFEAT ++++")

			store.game_outcome = {
				victory = false,
				level_idx = store.level_idx,
				level_mode = store.level_mode,
				level_difficulty = store.level_difficulty
			}
			store.paused = true
			store.defeat_count = (store.defeat_count or 0) + 1

			local slot = storage:load_slot()

			slot.last_victory = nil

			store_hero_xp(slot)

			slot.gems = (slot.gems or 0) + store.gems_collected

			if store.level_mode == GAME_MODE_ENDLESS then
				local slot_level = slot.levels[store.level_idx]

				slot_level = slot_level or {}

				if not slot_level[store.level_difficulty] then
					slot_level[store.level_difficulty] = {
						waves_survived = 0,
						high_score = 0
					}
					slot.levels[store.level_idx] = slot_level
				end

				if slot_level[store.level_difficulty].high_score < store.player_score then
					slot_level[store.level_difficulty].high_score = store.player_score
					slot_level[store.level_difficulty].waves_survived = store.wave_group_number
				end
			end

			signal.emit("game-defeat", store)
			signal.emit("game-defeat-after", store)
			storage:save_slot(slot, nil, true)
		elseif store.level.run_complete and store.waves_finished and not LU.has_alive_enemies(store) then
			log.info("++++ VICTORY ++++")

			local stars = 1

			if store.level_mode == GAME_MODE_CAMPAIGN then
				if store.lives >= 18 then
					stars = 3
				elseif store.lives >= 6 then
					stars = 2
				end
			end

			store.game_outcome = {
				victory = true,
				lives_left = store.lives,
				stars = stars,
				level_idx = store.level_idx,
				level_mode = store.level_mode,
				level_difficulty = store.level_difficulty
			}

			local slot = storage:load_slot()

			store_hero_xp(slot)

			slot.gems = (slot.gems or 0) + store.gems_collected

			local challenge = store.level_challenge

			if challenge then
				slot.challenges_completed = slot.challenges_completed or {}

				local already_won = slot.challenges_completed[challenge.id] ~= nil

				store.game_outcome.already_won = already_won
				slot.challenges_completed[challenge.id] = slot.challenges_completed[challenge.id] or {}

				local comp = slot.challenges_completed[challenge.id]

				if not comp.stars or not comp.lives or stars >= comp.stars and comp.lives <= store.lives then
					comp.ts = os.time()
					comp.stars = stars
					comp.lives = store.lives
					comp.diff = store.level_difficulty
				end

				if challenge.rewards then
					local rewards = challenge.rewards

					for k, v in pairs(rewards) do
						log.debug("adding reward %s of %s to slot", k, v)

						if k == "gems" then
							slot.gems = (slot.gems and slot.gems or 0) + v
						elseif not already_won then
							slot.bag[k] = (slot.bag[k] and slot.bag[k] or 0) + v
						end
					end
				end
			else
				slot.last_victory = {
					level_idx = store.level_idx,
					level_difficulty = store.level_difficulty,
					level_mode = store.level_mode,
					stars = stars
				}
			end

			signal.emit("game-victory", store)
			signal.emit("game-victory-after", store)
			storage:save_slot(slot, nil, true)
		end
	end
end

sys.events = {}
sys.events.name = "events"

function sys.events:init(store)
	store.event_handlers = {}
end

function sys.events:on_insert(entity, store)
	if entity.events then
		for _, ev in pairs(entity.events.list) do
			if not store.event_handlers[ev.name] then
				store.event_handlers[ev.name] = {}
			end

			ev.entity_id = entity.id

			table.insert(store.event_handlers[ev.name], ev)
			log.debug("sys.events: ++ registered handler for %s entity:(%s)%s", ev.name, entity.id, entity.template_name)
		end
	end

	return true
end

function sys.events:on_remove(entity, store)
	if entity.events then
		for _, ev in pairs(entity.events.list) do
			if store.event_handlers[ev.name] then
				table.removeobject(store.event_handlers[ev.name], ev)
				log.debug("sys.events: -- removed handler for %s entity:(%s)%s", ev.name, entity.id, entity.template_name)
			end
		end
	end

	return true
end

sys.wave_spawn_tsv = {}
sys.wave_spawn_tsv.name = "wave_spawn_tsv"
sys.wave_spawn_tsv.cmd_fns = {}

function sys.wave_spawn_tsv.cmd_fns.column_names(store, cmd)
	if cmd.time_columns then
		W.db.time_columns = table.deepclone(cmd.time_columns)
	end

	if cmd.path_columns then
		W.db.path_columns = table.deepclone(cmd.path_columns)
	end
end

function sys.wave_spawn_tsv.cmd_fns.flags(store, cmd)
	if not cmd.flags_visibility then
		return
	end

	W.db.flags_visibility = cmd.flags_visibility
end

function sys.wave_spawn_tsv.cmd_fns.manual_wave(store, cmd)
	log.debug("manual_wave started: %s", cmd.wave_name)
end

function sys.wave_spawn_tsv.cmd_fns.manual_wave_repeat(store, cmd)
	local mws = W:get_wave_status(cmd.wave_name)

	if not mws then
		log.error("manual_wave_repeat: manual_wave_index[%s] not found", cmd.wave_name)

		return
	end

	if mws.repeat_remaining == -1 then
		mws.current_idx = mws.first_idx
	elseif mws.repeat_remaining and mws.repeat_remaining > 0 then
		mws.current_idx = mws.first_idx
		mws.repeat_remaining = mws.repeat_remaining - 1
	else
		mws.status = W.WS_DONE
	end
end

function sys.wave_spawn_tsv.cmd_fns.call_manual_wave(store, cmd)
	log.debug("call_manual_wave: %s", cmd.value)
	W:start_manual_wave(cmd.value)
end

function sys.wave_spawn_tsv.cmd_fns.wave(store, cmd)
	local group = W:create_wave_group_from_tsv(cmd)

	group.group_idx = store.wave_group_number + 1
	store.next_wave_group_ready = group

	signal.emit("next-wave-ready", group)

	local wave_number = store.wave_group_number
	local wait_time = cmd.wait_time
	local start_ts = store.tick_ts

	if wait_time < 0 then
		while not store.send_next_wave and not store.force_next_wave do
			coroutine.yield()
		end
	else
		U.y_wait(store, wait_time, function(store, wait_time)
			return store.send_next_wave or store.force_next_wave
		end)
	end

	local actual_wait_time = store.tick_ts - start_ts

	store.wave_group_number = store.wave_group_number + 1

	if store.force_next_wave then
		store.force_next_wave = false
	end

	if store.send_next_wave == true and store.wave_group_number > 1 then
		local score_reward
		local remaining_secs = km.round(wait_time - actual_wait_time)

		if store.level_mode == GAME_MODE_ENDLESS then
			store.early_wave_reward = math.ceil(remaining_secs * GS.early_wave_reward_per_second * W:get_endless_early_wave_reward_factor())

			local conf = W:get_endless_score_config()
			local time_factor = km.clamp(0, 1, remaining_secs / fts(group.interval))

			score_reward = km.round((wave_number - 1) * conf.scorePerWave * conf.scoreNextWaveMultiplier * time_factor * #group.waves)
			store.player_score = store.player_score + score_reward

			log.debug("ENDLESS: early wave %s reward %s (time_factor:%s scorePerWave:%s scoreNextWaveMultiplier:%s flags:%s", wave_number, score_reward, time_factor, conf.scorePerWave, conf.scoreNextWaveMultiplier, #group.waves)
		else
			store.early_wave_reward = math.ceil(remaining_secs * GS.early_wave_reward_per_second)
		end

		store.player_gold = store.player_gold + store.early_wave_reward

		signal.emit("early-wave-called", group, store.early_wave_reward, remaining_secs, score_reward)
	else
		store.early_wave_reward = 0
	end

	if store.level_mode == GAME_MODE_ENDLESS and wave_number > 1 then
		local conf = W:get_endless_score_config()
		local reward = (wave_number - 1) * conf.scorePerWave

		store.player_score = store.player_score + reward

		local gems = GS.endless_gems_for_wave * (wave_number - 1)

		store.gems_collected = store.gems_collected + gems

		log.debug("ENDLESS: wave %s reward:%s gems:%s", wave_number, reward, gems)
	end

	if store.level_mode ~= GAME_MODE_ENDLESS then
		local gems_keeper_random = store.level_mode == GAME_MODE_CAMPAIGN
		local spawns = W:get_spawns_for_wave(store.wave_group_number)
		local gem_keepers = W:get_gem_keepers()

		if gems_keeper_random then
			store.gems_spawn_idx = km.rand_uniq(gem_keepers, 1, #spawns)
		else
			store.gems_spawn_idx = {}

			for i = #spawns, #spawns - gem_keepers + 1, -1 do
				table.insert(store.gems_spawn_idx, i)
			end
		end

		log.debug("GEMS: assigned gems to spawn indexes %s for wave %s", getdump(store.gems_spawn_idx), store.wave_group_number)
	end

	store.current_spawn_idx = 0
	store.send_next_wave = false
	store.current_wave_group = group

	signal.emit("next-wave-sent", group)
end

function sys.wave_spawn_tsv.cmd_fns.spawn(store, cmd, wave_name)
	local wait_time = cmd.wait_time

	if wait_time and wait_time > 0 then
		U.y_wait(store, wait_time, function(store, wait_time)
			return store.force_next_wave
		end)
	end

	if store.force_next_wave then
		log.debug("skipping spawn command due to force_next_wave")

		return
	end

	for _, o in pairs(cmd.spawns) do
		if not U.is_seen(store, o.enemy) then
			signal.emit("wave-notification", "icon", o.enemy)
			U.mark_seen(store, o.enemy)
		end

		local e = E:create_entity(o.enemy)

		if e then
			store.current_spawn_idx = store.current_spawn_idx + 1

			local path = P.paths[o.pi]

			e.nav_path.pi = o.pi
			e.nav_path.spi = o.spi == "*" and math.random(#path) or o.spi
			e.nav_path.ni = P:get_start_node(o.pi)

			if e.enemy and table.contains(store.gems_spawn_idx, store.current_spawn_idx) then
				e.enemy.gems = math.floor(store.gems_per_wave / #store.gems_spawn_idx * (1 + km.rand_sign() * 0.2))

				log.debug("GEMS: %s gems to enemy: (%s)%s spawn_idx:%s", e.enemy.gems, e.id, e.template_name, store.current_spawn_idx)
			end

			queue_insert(store, e)
		else
			log.error("Entity template %s not found", o.enemy)
		end

		if store.extra_enemies and store.extra_enemies > 0 then
			for i = 1, store.extra_enemies do
				e = E:create_entity(o.enemy)
				if e then
					local path = P.paths[o.pi]
					e.nav_path.pi = o.pi
					e.nav_path.spi = o.spi == "*" and math.random(#path) or km.zmod(o.spi + i, 3)
					e.nav_path.ni = P:get_start_node(o.pi)
					if e.health then
						e.health.hp_max = math.ceil(e.health.hp_max * (store.extra_enemies * 0.15 + 1))
					end
					if e.enemy then
						e.enemy.gold = km.round(e.enemy.gold * 0.6 * 0.85 ^ (store.extra_enemies - 1))
					end
					U.y_wait(store, fts(2))
					queue_insert(store, e)
				end
			end
		end
	end
end

function sys.wave_spawn_tsv.cmd_fns.event(store, cmd)
	local wait_time = cmd.wait_time

	if wait_time and wait_time > 0 then
		U.y_wait(store, wait_time, function(store, wait_time)
			return store.force_next_wave
		end)
	end

	local handlers = store.event_handlers

	if cmd.event_name and handlers and handlers[cmd.event_name] then
		for _, ev in pairs(handlers[cmd.event_name]) do
			local entity = store.entities[ev.entity_id]

			ev.on_event(entity, store, ev.name, unpack(cmd.event_params or {}))
		end
	end
end

function sys.wave_spawn_tsv.cmd_fns.signal(store, cmd)
	local wait_time = cmd.wait_time

	if wait_time and wait_time > 0 then
		U.y_wait(store, wait_time, function(store, wait_time)
			return store.force_next_wave
		end)
	end

	if cmd.signal_name then
		signal.emit(cmd.signal_name, unpack(cmd.signal_params or {}))
	end
end

function sys.wave_spawn_tsv.cmd_fns.wait_signal(store, cmd)
	local signal_name = cmd.signal_name

	store.wait_signal_done = nil

	local function fn(...)
		store.wait_signal_done = "arrived"
	end

	if signal_name then
		signal.register(signal_name, fn)
	end

	if cmd.wait_time < 0 then
		while not store.wait_signal_done and not store.force_next_wave do
			coroutine.yield()
		end
	else
		U.y_wait(store, cmd.wait_time, function(store, wait_time)
			if store.wait_signal_done or store.force_next_wave then
				store.wait_signal_done = "interrupted"

				return true
			end
		end)
	end

	signal.remove(signal_name, fn)
end

function sys.wave_spawn_tsv.cmd_fns.wait(store, cmd)
	local wait_time = cmd.wait_time

	if wait_time and wait_time > 0 then
		U.y_wait(store, wait_time, function(store, wait_time)
			return store.force_next_wave
		end)
	end
end

function sys.wave_spawn_tsv.y_run_wave(store, wave_name)
	local cmd_fns = sys.wave_spawn_tsv.cmd_fns
	local cmd = W:get_next_cmd(wave_name)

	while cmd do
		if cmd_fns[cmd.name] then
			cmd_fns[cmd.name](store, cmd, wave_name)
		elseif cmd.wait_time then
			if cmd.wait_time < 0 then
				while not store.send_next_wave and not store.force_next_wave do
					coroutine.yield()
				end
			else
				U.y_wait(store, cmd.wait_time, function(store, wait_time)
					return store.force_next_wave
				end)
			end
		end

		cmd = W:get_next_cmd(wave_name)
	end

	return true
end

function sys.wave_spawn_tsv:init(store)
	if W.format ~= "tsv" then
		log.warning("Wave format is not tsv, skipping wave_spawn_tsv system")

		return "skip"
	end

	if store.level_mode == GAME_MODE_ENDLESS then
		log.error("ENDLESS mode not supported yet in wave_spawn_tsv")

		return "skip"
	end

	store.wave_group_number = 0
	store.waves_finished = false
	store.last_wave_ts = 0
	store.send_next_wave = false
	store.manual_wave_cos = {}

	do
		local cmd_fns = sys.wave_spawn_tsv.cmd_fns
		local cmd = W:peek_next_cmd()

		while cmd and cmd.name ~= "wave" and cmd.name ~= "manual_wave" and not cmd.wait_time do
			if cmd_fns[cmd.name] then
				cmd_fns[cmd.name](store, cmd)
			end

			cmd = W:get_next_cmd()
			cmd = W:peek_next_cmd()
		end
	end

	if store.level_mode == GAME_MODE_ENDLESS then
		store.gems_per_wave = 0
		store.wave_group_total = 0
	else
		store.gems_per_wave = math.floor((GS.gems_per_level[store.level_idx] or 100) * GS.gems_factor_per_mode[store.level_mode] / W:all_waves_count())
		store.wave_group_total = W:groups_count()
	end

	store.wave_spawn_co = coroutine.create(sys.wave_spawn_tsv.y_run_wave)
end

function sys.wave_spawn_tsv:on_update(dt, ts, store)
	if store.force_next_wave then
		LU.kill_all_enemies(store, nil, true)
	end

	if store.wave_spawn_co then
		local ok, done = coroutine.resume(store.wave_spawn_co, store)

		if ok and done then
			store.wave_spawn_co = nil
			store.waves_finished = true

			log.debug("wave_spawn_tsv: waves finished")
		end

		if not ok then
			log.error("wave_spawn_tsv: Error resuming wave_spawn_co co:%s", debug.traceback(store.wave_spawn_co, done))

			store.wave_spawn_co = nil
		end
	end

	if W:has_pending_manual_waves() then
		for _, name in pairs(W:list_pending_manual_waves()) do
			local ws = W:get_wave_status(name)

			ws.state = W.WS_RUNNING
			store.manual_wave_cos = store.manual_wave_cos or {}
			store.manual_wave_cos[name] = coroutine.create(sys.wave_spawn_tsv.y_run_wave)
		end
	end

	if store.manual_wave_cos then
		local to_remove

		for name, co in pairs(store.manual_wave_cos) do
			local ws = W:get_wave_status(name)

			if ws and ws.state == W.WS_DONE then
				to_remove = to_remove or {}

				table.insert(to_remove, name)
			else
				local ok, done = coroutine.resume(co, store, name)

				if ok and done then
					to_remove = to_remove or {}

					table.insert(to_remove, name)
				end

				if not ok then
					log.error("wave_spawn_tsv: Error resuming manual_wave_cos[%s]:%s", name, debug.traceback(co, done))

					store.wave_spawn_co = nil
				end
			end
		end

		if to_remove then
			for _, name in pairs(to_remove) do
				store.manual_wave_cos[name] = nil

				local ws = W:get_wave_status(name)

				if ws then
					ws.state = W.WS_REMOVED
				end
			end

			to_remove = nil
		end
	end

	store.force_next_wave = false
end

sys.wave_spawn = {}
sys.wave_spawn.name = "wave_spawn"

local function spawner(store, wave)
	log.debug("spawner thread(%s) for wave(%s) starting", coroutine.running(), tostring(wave))

	local spawns = wave.spawns
	local pi = wave.path_index
	local last_spawn_ts = 0
	local gems_creep_idx
	local gems_keeper_random = store.level_mode == GAME_MODE_CAMPAIGN
	local gems_spawn_idx = gems_keeper_random and math.random(1, #spawns) or #spawns
	local max_creeps = spawns[gems_spawn_idx].max

	if max_creeps > 0 then
		gems_creep_idx = gems_keeper_random and math.random(1, max_creeps) or max_creeps

		log.debug("GEMS: gems_spawn_idx:%s gems_creep_idx:%s", gems_spawn_idx, gems_creep_idx)
	else
		log.debug("GEMS: assigned to spawner with max_creeps = 0, so not in play.")
	end

	for i = 1, #spawns do
		local current_count = 0
		local current_creep
		local s = spawns[i]
		local path = P.paths[pi]

		if not U.is_seen(store, s.creep) then
			signal.emit("wave-notification", "icon", s.creep)
			U.mark_seen(store, s.creep)
		end

		if s.creep_aux and not U.is_seen(store, s.creep_aux) then
			signal.emit("wave-notification", "icon", s.creep_aux)
			U.mark_seen(store, s.creep_aux)
		end

		for j = 1, s.max do
			U.y_wait(store, fts(s.interval or 0))

			if not current_creep then
				current_creep = s.creep
			elseif s.creep_aux and s.max_same and s.max_same > 0 and current_count >= s.max_same then
				current_creep = s.creep == current_creep and s.creep_aux or s.creep
				current_count = 0
			end

			local e = E:create_entity(current_creep)

			if e then
				e.nav_path.pi = pi
				e.nav_path.spi = s.fixed_sub_path == 1 and s.path or math.random(#path)
				e.nav_path.ni = P:get_start_node(pi)
				e.spawn_data = s.spawn_data

				if e.enemy and gems_spawn_idx == i and gems_creep_idx == j then
					e.enemy.gems = math.floor(store.gems_per_wave * (1 + km.rand_sign() * 0.2))

					log.debug("GEMS: %s gems to enemy: (%s)%s spawn:%s creep:%s", e.enemy.gems, e.id, e.template_name, i, j)
				end

				queue_insert(store, e)

				current_count = current_count + 1
			else
				log.error("Entity template not found for %s.", s.crep)
			end

			if store.extra_enemies and store.extra_enemies > 0 then
				for i = 1, store.extra_enemies do
					e = E:create_entity(current_creep)
					if e then
						e.nav_path.pi = pi
						e.nav_path.spi = s.fixed_sub_path == 1 and km.zmod(s.path + i, 3) or math.random(#path)
						e.nav_path.ni = P:get_start_node(pi)
						e.spawn_data = s.spawn_data
						if e.health then
							e.health.hp_max = math.ceil(e.health.hp_max * (store.extra_enemies * 0.15 + 1))
						end
						if e.enemy then
							e.enemy.gold = km.round(e.enemy.gold * 0.6 * 0.85 ^ (store.extra_enemies - 1))
						end
						U.y_wait(store, fts(2))
						queue_insert(store, e)
					end
				end
			end
		end

		if s.max == 0 then
			U.y_wait(store, fts(s.interval or 0))
		end

		local oes = s.on_end_signal

		if oes then
			log.info("Sending spawner on_end_signal: %s", oes)

			store.wave_signals[oes] = {}
		end

		if i < #spawns then
			U.y_wait(store, fts(s.interval_next or 0))
		end
	end

	log.debug("spawner thread(%s) for wave(%s) about to finish", coroutine.running(), tostring(wave))

	return true
end

function sys.wave_spawn:init(store)
	if W.format ~= "lua" then
		log.warning("Wave format is not lua, skipping wave_spawn system")

		return "skip"
	end

	store.wave_group_number = 0
	store.waves_finished = false
	store.last_wave_ts = 0
	store.waves_active = {}
	store.wave_signals = {}
	store.send_next_wave = false

	if store.level_mode == GAME_MODE_ENDLESS then
		store.gems_per_wave = 0
		store.wave_group_total = 0
	else
		store.gems_per_wave = math.floor((GS.gems_per_level[store.level_idx] or 100) * GS.gems_factor_per_mode[store.level_mode] / W:all_waves_count())
		store.wave_group_total = W:groups_count()
	end

	local function run(store)
		log.info("Wave group spawn thread STARTING")

		local i = 1

		while W:has_group(i) do
			local group = W:get_group(i)

			group.group_idx = i
			store.next_wave_group_ready = group

			signal.emit("next-wave-ready", group)

			store.tutorial_hold_wave = false

			if i == 1 then
				for _, wave in pairs(group.waves) do
					if wave.notification and wave.notification ~= "" then
						signal.emit("wave-notification", "view", wave.notification)
					end
				end

				while not store.send_next_wave do
					coroutine.yield()
				end

				log.debug("Sending first WAVE. (Started by player)")
			else
				while not store.send_next_wave and not (store.tick_ts - store.last_wave_ts >= fts(group.interval)) and not store.force_next_wave do
					coroutine.yield()
				end
			end

			log.info("sending WAVE group %02d (%02d waves)", i, #group.waves)

			store.next_wave_group_ready = nil
			store.wave_group_number = i

			if store.send_next_wave == true and i > 1 then
				local score_reward
				local remaining_secs = km.round(fts(group.interval) - (store.tick_ts - store.last_wave_ts))

				if store.level_mode == GAME_MODE_ENDLESS then
					store.early_wave_reward = math.ceil(remaining_secs * GS.early_wave_reward_per_second * W:get_endless_early_wave_reward_factor())

					local conf = W:get_endless_score_config()
					local time_factor = km.clamp(0, 1, remaining_secs / fts(group.interval))

					score_reward = km.round((i - 1) * conf.scorePerWave * conf.scoreNextWaveMultiplier * time_factor * #group.waves)
					store.player_score = store.player_score + score_reward

					log.debug("ENDLESS: early wave %s reward %s (time_factor:%s scorePerWave:%s scoreNextWaveMultiplier:%s flags:%s", i, score_reward, time_factor, conf.scorePerWave, conf.scoreNextWaveMultiplier, #group.waves)
				else
					store.early_wave_reward = math.ceil(remaining_secs * GS.early_wave_reward_per_second)
				end

				store.player_gold = store.player_gold + store.early_wave_reward

				signal.emit("early-wave-called", group, store.early_wave_reward, remaining_secs, score_reward)
			else
				store.early_wave_reward = 0
			end

			if store.level_mode == GAME_MODE_ENDLESS and i > 1 then
				local conf = W:get_endless_score_config()
				local reward = (i - 1) * conf.scorePerWave

				store.player_score = store.player_score + reward

				local gems = GS.endless_gems_for_wave * (i - 1)

				store.gems_collected = store.gems_collected + gems

				log.debug("ENDLESS: wave %s reward:%s gems:%s", i, reward, gems)
			end

			store.send_next_wave = false
			store.current_wave_group = group

			signal.emit("next-wave-sent", group)

			for j, wave in pairs(group.waves) do
				wave.group_idx = i

				if i ~= 1 and wave.notification and wave.notification ~= "" then
					signal.emit("wave-notification", "view", wave.notification)
				end

				if wave.notification_second_level and wave.notification_second_level ~= "" then
					signal.emit("wave-notification", "icon", wave.notification_second_level)
				end

				local sco = coroutine.create(function()
					local wave_start_ts = store.tick_ts

					while store.tick_ts < wave_start_ts + fts(wave.delay) do
						coroutine.yield()
					end

					return spawner(store, wave)
				end)

				store.waves_active[sco] = sco
			end

			log.info("WAVE group %d about to wait for all its spawner threads to finish", i)

			while store.tutorial_hold_wave or next(store.waves_active) do
				coroutine.yield()
			end

			store.current_wave_group = nil
			store.last_wave_ts = store.tick_ts
			i = i + 1
		end

		log.info("WAVE spawn thread FINISHED")

		return true
	end

	store.wave_spawn_thread = coroutine.create(run)
end

function sys.wave_spawn:force_next_wave(store)
	local function kill_all_enemies(store, discard_gold, keep_spawners)
		for _, list in pairs({
			store.entities,
			store.pending_inserts
		}) do
			local all = E:filter(list, "enemy")

			for _, e in pairs(all) do
				if e and e.vis and bit.band(e.vis.flags, F_BOSS) == 0 and e.vis.bans ~= F_ALL and e.health.immune_to ~= DAMAGE_ALL then
					e.health.hp = 0

					if e.death_spawns then
						e.health.last_damage_types = DAMAGE_NO_SPAWNS
					end

					if discard_gold and e.enemy then
						e.enemy.gold = 0
					end

					e.vis.bans = bor(e.vis.bans, F_MOD)

					if e.regen then
						e.regen.cooldown = 1e+99
					end
				end
			end

			local soldier_names = {
				"soldier_rag"
			}
			local entities = table.filter(list, function(k, v)
				return table.contains(soldier_names, v.template_name)
			end)

			for _, e in pairs(entities) do
				e.health.hp = 0
			end

			if not keep_spawners then
				local spawners = E:filter(list, "spawner")

				for _, e in pairs(spawners) do
					e.spawner.interrupt = true
				end

				local names = {
					"graveyard_controller",
					"swamp_controller"
				}
				local entities = table.filter(list, function(k, v)
					return table.contains(names, v.template_name)
				end)

				for _, e in pairs(entities) do
					e.interrupt = true
				end
			end

			local interrupt_names = {
				"twister",
				"mod_timelapse",
				"aura_bullet_balrog"
			}
			local entities = table.filter(list, function(k, v)
				return table.contains(interrupt_names, v.template_name)
			end)

			for _, e in pairs(entities) do
				e.interrupt = true
			end

			local remove_names = {
				"nav_faerie",
				"mod_drider_poison",
				"decal_drider_cocoon",
				"mod_dark_spitters",
				"mod_balrog"
			}
			local entities = table.filter(list, function(k, v)
				return table.contains(remove_names, v.template_name)
			end)

			for _, e in pairs(entities) do
				LU.queue_remove(store, e)
			end
		end
	end

	if store.force_next_wave then
		store.waves_active = {}

		kill_all_enemies(store, nil, true)
	end
end

function sys.wave_spawn:on_insert(entity, store)
	if store.level_mode == GAME_MODE_ENDLESS and (entity.enemy or entity.endless) and not entity._entity_progression_done then
		W:set_entity_progression(entity, store.wave_group_number)

		entity._entity_progression_done = true
	end

	return true
end

function sys.wave_spawn:on_update(dt, ts, store)
	sys.wave_spawn:force_next_wave(store)

	if store.wave_spawn_thread then
		local ok, done = coroutine.resume(store.wave_spawn_thread, store)

		if ok and done then
			store.wave_spawn_thread = nil
			store.waves_finished = true

			log.debug("++++ WAVES FINISHED")
		end

		if not ok then
			log.error("Error resuming wave_spawn_thread co: %s", debug.traceback(store.wave_spawn_thread, done))

			store.wave_spawn_thread = nil
		end
	end

	local to_cleanup

	for _, co in pairs(store.waves_active) do
		local ok, done = coroutine.resume(co, store)

		if ok and done then
			log.debug("thread (%s) finished after resume()", tostring(co))

			to_cleanup = to_cleanup or {}
			to_cleanup[#to_cleanup + 1] = co
		end

		if not ok then
			local err = done

			log.error("Error resuming spawner thread (%s): %s", tostring(co), debug.traceback(co, err))
		end
	end

	if to_cleanup then
		for _, co in pairs(to_cleanup) do
			log.debug("removing spawner thread (%s)", co)

			store.waves_active[co] = nil
		end

		to_cleanup = nil
	end

	store.force_next_wave = false
end

sys.mod_lifecycle = {}
sys.mod_lifecycle.name = "mod_lifecycle"

function sys.mod_lifecycle:on_insert(entity, store)
	if not entity.modifier then
		return true
	end

	local this = entity
	local target_id = this.modifier.target_id
	local modifiers = table.filter(store.entities, function(k, v)
		return v.modifier and v.modifier.target_id == target_id
	end)

	for _, m in pairs(modifiers) do
		if m.modifier.bans and table.contains(m.modifier.bans, this.template_name) then
			log.debug("modifier %s not allowed by %s for target entity %s", this.template_name, m.template_name, this.modifier.target_id)

			return false
		end
	end

	if this.modifier.remove_banned then
		for _, m in pairs(modifiers) do
			if this.modifier.bans and table.contains(this.modifier.bans, m.template_name) then
				m.modifier.removed_by_ban = true

				queue_remove(store, m)
				log.debug("banned modifier (%s) %s removed by (%s) %s for target entity %s", m.id, m.template_name, this.id, this.template_name, this.modifier.target_id)
			end

			if this.modifier.ban_types and table.contains(this.modifier.ban_types, m.modifier.type) then
				m.modifier.removed_by_ban = true

				queue_remove(store, m)
				log.debug("banned modifier (%s) %s of type %s removed by (%s) %s for target entity %s", m.id, m.template_name, this.id, m.modifier.type, this.template_name, this.modifier.target_id)
			end
		end
	end

	this.modifier.ts = store.tick_ts

	if this.render then
		for i = 1, #this.render.sprites do
			this.render.sprites[i].ts = store.tick_ts
		end
	end

	for _, m in pairs(modifiers) do
		if m.template_name == this.template_name then
			if this.modifier.level == m.modifier.level and this.modifier.allows_duplicates then
				log.paranoid("adding a duplicate modifier (%s)-%s", this.id, this.template_name)

				return true
			elseif this.modifier.level > m.modifier.level and this.modifier.replaces_lower then
				log.paranoid("replacing existing modifier (%s)-%s with (%s)-%s", m.id, m.template_name, this.id, this.template_name)
				queue_remove(store, m)

				if m.render then
					for i = 1, #this.render.sprites do
						this.render.sprites[i].ts = m.render.sprites[i].ts
					end
				end
			elseif this.modifier.level == m.modifier.level and this.modifier.resets_same then
				log.paranoid("resetting ts for modifier (%s)-%s instead of inserting (%s)-%s", m.id, m.template_name, this.id, this.template_name)

				m.modifier.ts = store.tick_ts

				if this.modifier.resets_same_tween and m.tween then
					m.tween.ts = store.tick_ts - (this.modifier.resets_same_tween_offset or 0)
				end

				return false
			else
				return false
			end
		end
	end

	return true
end

sys.tower_upgrade = {}
sys.tower_upgrade.name = "tower_upgrade"

function sys.tower_upgrade:on_update(dt, ts, store)
	for _, e in E:filter_iter(store.entities, "tower") do
		if e.tower.sell or e.tower.destroy then
			log.debug("selling %s", e.id)

			if e.tower.sell then
				local refund = store.wave_group_number == 0 and e.tower.spent or km.round(e.tower.refund_factor * e.tower.spent)

				store.player_gold = store.player_gold + refund
			end

			if e.tower.sell then
				local mods = table.filter(store.entities, function(_, ee)
					return ee.modifier and ee.modifier.target_id == e.id
				end)

				for _, mod in pairs(mods) do
					queue_remove(store, mod)
				end
			end

			local th = E:create_entity("tower_holder")

			th.pos = V.vclone(e.pos)
			th.tower.holder_id = e.tower.holder_id
			th.tower.flip_x = e.tower.flip_x

			if e.tower.default_rally_pos then
				th.tower.default_rally_pos = e.tower.default_rally_pos
			end

			if e.tower.terrain_style then
				th.tower.terrain_style = e.tower.terrain_style
				th.render.sprites[1].name = string.format(th.render.sprites[1].name, e.tower.terrain_style)

				if IS_KR5 then
					th.render.sprites[2].name = string.format(th.render.sprites[2].name, e.tower.terrain_style)
				end
			end

			if th.ui and e.ui then
				th.ui.nav_mesh_id = e.ui.nav_mesh_id
			end

			queue_insert(store, th)
			queue_remove(store, e)
			signal.emit("tower-removed", e, th)

			if e.tower.sell then
				local dust = E:create_entity("fx_tower_sell_dust")

				dust.pos.x, dust.pos.y = th.pos.x, th.pos.y + 35
				dust.render.sprites[1].ts = store.tick_ts

				queue_insert(store, dust)

				if e.sound_events and e.sound_events.sell then
					S:queue(e.sound_events.sell, e.sound_events.sell_args)
				end
			end
		elseif e.tower.upgrade_to then
			log.debug("upgrading %s to %s", e.id, e.tower.upgrade_to)

			local mods = table.filter(store.entities, function(_, ee)
				return ee.modifier and ee.modifier.target_id == e.id and not ee.modifier.keep_on_tower_upgrade
			end)

			for _, mod in pairs(mods) do
				queue_remove(store, mod)
			end

			local ne = E:create_entity(e.tower.upgrade_to)

			ne.pos = e.pos
			ne.tower.holder_id = e.tower.holder_id
			ne.tower.flip_x = e.tower.flip_x

			if e.tower.default_rally_pos then
				ne.tower.default_rally_pos = V.vclone(e.tower.default_rally_pos)
			end

			if e.tower.terrain_style then
				ne.tower.terrain_style = e.tower.terrain_style
				ne.render.sprites[1].name = string.format(ne.render.sprites[1].name, e.tower.terrain_style)

				if IS_KR5 then
					ne.render.sprites[2].name = string.format(ne.render.sprites[2].name, e.tower.terrain_style)
				end
			end

			if ne.ui and e.ui then
				ne.ui.nav_mesh_id = e.ui.nav_mesh_id
			end

			queue_insert(store, ne)
			queue_remove(store, e)
			signal.emit("tower-upgraded", ne, e)

			local price = ne.tower.price

			if ne.tower.type == "build_animation" then
				local bt = E:get_template(ne.build_name)

				price = bt.tower.price
			elseif e.tower.type == "build_animation" then
				price = 0
			elseif e.tower_holder and e.tower_holder.unblock_price > 0 then
				price = e.tower_holder.unblock_price
			end

			store.player_gold = store.player_gold - price

			if not e.tower_holder or not e.tower_holder.blocked then
				ne.tower.spent = e.tower.spent + price
			end

			if e.tower and e.tower.type == "engineer" and ne.tower.type == "engineer" then
				if ne.ranged_attack then
					ne.ranged_attack.ts = e.ranged_attack.ts
				elseif ne.area_attack then
					ne.area_attack.ts = e.ranged_attack.ts
				end
			elseif e.barrack and ne.barrack then
				ne.barrack.rally_pos = V.vclone(e.barrack.rally_pos)

				for i, s in ipairs(e.barrack.soldiers) do
					if s.health.dead then
						-- block empty
					else
						if i > ne.barrack.max_soldiers then
							U.unblock_target(store, s)
						else
							local ns = E:create_entity(ne.barrack.soldier_type)

							ns.info.i18n_key = s.info.i18n_key
							ns.soldier.tower_id = ne.id
							ns.soldier.tower_soldier_idx = i
							ns.pos = V.vclone(s.pos)
							ns.motion.dest = V.vclone(s.motion.dest)
							ns.motion.arrived = s.motion.arrived
							ns.render.sprites[1].flip_x = s.render.sprites[1].flip_x
							ns.render.sprites[1].flip_y = s.render.sprites[1].flip_y
							ns.render.sprites[1].name = s.render.sprites[1].name
							ns.render.sprites[1].loop = s.render.sprites[1].loop
							ns.render.sprites[1].ts = s.render.sprites[1].ts
							ns.render.sprites[1].runs = s.render.sprites[1].runs
							ns.nav_rally.pos = V.vclone(s.nav_rally.pos)
							ns.nav_rally.center = V.vclone(s.nav_rally.center)
							ns.nav_rally.new = s.nav_rally.new

							for i, a in ipairs(ns.melee.attacks) do
								if s.melee.attacks[i] then
									a.ts = s.melee.attacks[i].ts
								end
							end

							U.replace_blocker(store, s, ns)

							ne.barrack.soldiers[i] = ns

							queue_insert(store, ns)
						end

						s.health.dead = true

						queue_remove(store, s)
					end
				end
			elseif ne.barrack then
				ne.barrack.rally_pos = V.vclone(ne.tower.default_rally_pos)
			end

			if ne.attacks and e.attacks and e.attacks._last_target_pos then
				ne.attacks._last_target_pos = e.attacks._last_target_pos
			end

			local mods_to_apply = table.filter(store.entities, function(_, ee)
				return ee.modifier and ee.modifier.target_id == e.id and ee.modifier.keep_on_tower_upgrade
			end)

			for _, mod in pairs(mods_to_apply) do
				mod.modifier.target_id = ne.id
			end

			if e.tower_upgrade_persistent_data and ne.tower_upgrade_persistent_data then
				ne.tower_upgrade_persistent_data = e.tower_upgrade_persistent_data
			end

			if ne.tower.type ~= "build_animation" and not ne.tower.hide_dust then
				local dust = E:create_entity("fx_tower_buy_dust")

				dust.pos.x, dust.pos.y = ne.pos.x, ne.pos.y + 10
				dust.render.sprites[1].ts = store.tick_ts

				queue_insert(store, dust)
			end
		end
	end
end

sys.game_upgrades = {}
sys.game_upgrades.name = "game_upgrades"

function sys.game_upgrades:init(store)
	store.game_upgrades_data = {}
	store.game_upgrades_data.mage_towers_count = 0
end

function sys.game_upgrades:on_insert(entity, store)
	local mage_tower_types = {
		"mage",
		"archmage",
		"necromancer"
	}
	local mage_bullet_names = {
		"bolt_1",
		"bolt_2",
		"bolt_3",
		"bolt_archmage",
		"bolt_necromancer"
	}
	local u = UP:get_upgrade("mage_brilliance")

	if u and entity.tower and table.contains(mage_tower_types, entity.tower.type) then
		local existing_towers = table.filter(store.entities, function(_, e)
			return e.tower and table.contains(mage_tower_types, e.tower.type)
		end)

		if #existing_towers == 0 then
			for _, bn in pairs(mage_bullet_names) do
				local b = E:get_template(bn).bullet

				b._orig_damage_min = b.damage_min
				b._orig_damage_max = b.damage_max
			end
		else
			local f = u.damage_factors[km.clamp(1, #u.damage_factors, #existing_towers + 1)]

			for _, bn in pairs(mage_bullet_names) do
				local b = E:get_template(bn).bullet

				b.damage_min = math.ceil(b._orig_damage_min * f)
				b.damage_max = math.ceil(b._orig_damage_max * f)
			end
		end
	end

	return true
end

function sys.game_upgrades:on_remove(entity, store)
	local mage_tower_types = {
		"mage",
		"archmage",
		"necromancer"
	}
	local mage_bullet_names = {
		"bolt_1",
		"bolt_2",
		"bolt_3",
		"bolt_archmage",
		"bolt_necromancer"
	}
	local u = UP:get_upgrade("mage_brilliance")

	if u and entity.tower and table.contains(mage_tower_types, entity.tower.type) then
		local existing_towers = table.filter(store.entities, function(_, e)
			return e.tower and table.contains(mage_tower_types, e.tower.type)
		end)
		local f = u.damage_factors[km.clamp(1, #u.damage_factors, #existing_towers - 1)]

		for _, bn in pairs(mage_bullet_names) do
			local b = E:get_template(bn).bullet

			b.damage_min = math.ceil(b._orig_damage_min * f)
			b.damage_max = math.ceil(b._orig_damage_max * f)
		end
	end

	return true
end

sys.main_script = {}
sys.main_script.name = "main_script"

function sys.main_script:on_queue(entity, store, insertion)
	if entity.main_script and entity.main_script.queue then
		entity.main_script.queue(entity, store, insertion)
	end
end

function sys.main_script:on_dequeue(entity, store, insertion)
	if entity.main_script and entity.main_script.dequeue then
		entity.main_script.dequeue(entity, store, insertion)
	end
end

function sys.main_script:on_insert(entity, store)
	if entity.main_script and entity.main_script.insert then
		return entity.main_script.insert(entity, store, entity.main_script)
	else
		return true
	end
end

function sys.main_script:on_update(dt, ts, store)
	if balance.enemies.frame_splitting then
		math.randomseed(math.ceil(store.tick_ts * 30))
		local count = 0
		for _, e in E:filter_iter(store.entities, "main_script") do
			local s = e.main_script
	
			if not s.update then
				-- block empty
			else
				if not s.co and s.runs ~= 0 then
					s.runs = s.runs - 1
					s.co = coroutine.create(s.update)
				end
	
				local resume = false
				if s.co then
					if not e.aura and not e.vis or e.vis and (band(e.vis.flags, bor(F_FRIEND, F_ENEMY)) == 0 or band(e.vis.flags, bor(F_HERO, F_BOSS)) ~= 0) 
					or count < 256 then
						resume = true
					else
						local chance = math.random()
						if e.aura then
							if chance <= 0.3 then
								resume = true
							end
						elseif chance <= 0.5 then
							resume = true
						end
					end
				end
				if resume then
					local success, error = coroutine.resume(s.co, e, store, s)
					if coroutine.status(s.co) == "dead" or error ~= nil then
						if error ~= nil then
							log.error("Error running coro. id:%s template:%s trace:%s", e.id, e.template_name, debug.traceback(s.co, error))
						end
	
						s.co = nil
					end
				end

				if e.vis and band(e.vis.flags, bor(F_FRIEND, F_ENEMY)) ~= 0 then
					if band(e.vis.flags, bor(F_HERO)) ~= 0 then
						count = count + 4
					elseif band(e.vis.flags, bor(F_BOSS, F_MINIBOSS)) ~= 0 then
						count = count + 2
					else
						count = count + 1
					end
				elseif e.tower then
					count = count + 4
				elseif e.aura then
					count = count + 4
				end
			end
		end
		return
	end
	for _, e in E:filter_iter(store.entities, "main_script") do
		local s = e.main_script

		if not s.update then
			-- block empty
		else
			if not s.co and s.runs ~= 0 then
				s.runs = s.runs - 1
				s.co = coroutine.create(s.update)
			end

			if s.co then
				local success, error = coroutine.resume(s.co, e, store, s)

				if coroutine.status(s.co) == "dead" or error ~= nil then
					if error ~= nil then
						log.error("Error running coro. id:%s template:%s trace:%s", e.id, e.template_name, debug.traceback(s.co, error))
					end

					s.co = nil
				end
			end
		end
	end
end

function sys.main_script:on_remove(entity, store)
	if entity.health then
		local health_text = sys.health.health_texts[entity.id]
		if health_text then
			queue_remove(store, health_text)
			sys.health.health_texts[entity.id] = nil
		end
	end
	
	if entity.main_script and entity.main_script.remove then
		return entity.main_script.remove(entity, store, entity.main_script)
	else
		return true
	end
end

sys.health = {}
sys.health.name = "health"
sys.health.health_texts = {}

function sys.health:init(store)
	store.damage_queue = {}
end

function sys.health:on_insert(entity, store)
	if entity.health and not entity.health.hp then
		entity.health.hp = entity.health.hp_max
	end

	if entity.unit and entity.health and not entity.health.dead and entity.health.hp_max and ((entity.enemy and entity.health.hp_max >= 900) or 
	(entity.vis and entity.vis.flags and band(entity.vis.flags, F_HERO) ~= 0)) then
		local e = E:create_entity("debug_damage_text")
		e.tween = nil
		e.pos = V.v(entity.pos.x, entity.pos.y)
		if entity.health_bar then
			if entity.health_bar.offset then
				e.pos.y = e.pos.y + entity.health_bar.offset.y + 14
			elseif entity.health_bar.y_offset then
				e.pos.y = e.pos.y + entity.health_bar.y_offset + 14
			end
		else
			e.pos.y = e.pos.y + 64
		end
		local text = e.texts.list[1]
		e.hp = km.round(entity.health.hp)
		if entity.enemy then
			text.color = { 255, 0, 0 }
			local show_health_texts = store.level.show_health_texts
			if show_health_texts then
				text.text = tostring(e.hp)
			else
				text.text = ""
			end
		else
			text.color = { 0, 255, 128 }
			text.text = ""
		end
		self.health_texts[entity.id] = e
		queue_insert(store, e)
	end

	return true
end

function sys.health:on_update(dt, ts, store)
	for i = #store.damage_queue, 1, -1 do
		local d = store.damage_queue[i]

		if d.damage_applied ~= nil then
			table.remove(store.damage_queue, i)
		else
			d.damage_applied = 0

			local e = store.entities[d.target_id]

			if not e then
				-- block empty
			else
				local h = e.health

				if h.dead or band(bnot(h.immune_to), d.damage_type) == 0 or h.ignore_damage or h.on_damage and not h.on_damage(e, store, d) then
					log_hp.paranoid("entity: (%s) %s dead:%s - ignoring damage: \n%s", e.id, e.template_name, e.health.dead, getfulldump(d))
				else
					local starting_hp = h.hp

					h.last_damage_types = bor(h.last_damage_types, d.damage_type)

					log_hp.paranoid("(%s) %s - last_damage_types: %x", e.id, e.template_name, d.damage_type)

					if band(d.damage_type, bor(DAMAGE_INSTAKILL, DAMAGE_EAT)) ~= 0 then
						d.damage_applied = h.hp
						d.damage_result = bor(d.damage_result, DR_KILL)
						h.hp = 0
					elseif band(d.damage_type, DAMAGE_ARMOR) ~= 0 then
						SU.armor_dec(e, d.value)

						d.damage_result = bor(d.damage_result, DR_ARMOR)
					elseif band(d.damage_type, DAMAGE_MAGICAL_ARMOR) ~= 0 then
						SU.magic_armor_dec(e, d.value)

						d.damage_result = bor(d.damage_result, DR_MAGICAL_ARMOR)
					else
						local actual_damage = U.predict_damage(e, d)

						h.hp = h.hp - actual_damage
						d.damage_applied = actual_damage

						log_hp.paranoid("(%s) %s - damage_applied: %s", e.id, e.template_name, actual_damage)

						if starting_hp > 0 and h.hp <= 0 then
							d.damage_result = bor(d.damage_result, DR_KILL)
						end

						if actual_damage > 0 then
							d.damage_result = bor(d.damage_result, DR_DAMAGE)

							if e.regen then
								e.regen.last_hit_ts = store.tick_ts
							end

							if d.track_damage then
								signal.emit("entity-damaged", e, d)

								local source = store.entities[d.source_id]

								if source and source.track_damage then
									table.insert(source.track_damage.damaged, {
										e.id,
										actual_damage
									})
								end
							end
						end

						if e and (h.spiked_armor > 0 or h.spiked_armor_damage > 0) and e.soldier and e.soldier.target_id then
							local t = store.entities[e.soldier.target_id]

							if t and t.health and not t.health.dead then
								local sad = E:create_entity("damage")

								if h.spiked_armor > 0 then
									sad.damage_type = DAMAGE_TRUE
									sad.value = math.ceil(h.spiked_armor * d.value)
								else
									sad.value = h.spiked_armor_damage
									sad.damage_type = h.spiked_armor_damage_type
								end
								sad.damage_applied = sad.value
								sad.source_id = e.id
								sad.target_id = t.id

								table.insert(store.damage_queue, sad)
							end
						end
					end

					if starting_hp > 0 and h.hp <= 0 then
						signal.emit("entity-killed", e, d)

						if d.track_kills then
							local source = store.entities[d.source_id]

							if source and source.track_kills then
								table.insert(source.track_kills.killed, e.id)
							end
						end
					end
				end
			end
		end
	end

	for _, e in E:filter_iter(store.entities, "health") do
		local h = e.health

		if h.hp <= 0 and not h.dead and not h.ignore_damage then
			h.hp = 0
			h.dead = true
			h.death_ts = store.tick_ts
			h.delete_after = store.tick_ts + h.dead_lifetime

			if e.health_bar then
				e.health_bar.hidden = true
			end

			if e.enemy then
				store.player_gold = store.player_gold + e.enemy.gold

				signal.emit("got-enemy-gold", e, e.enemy.gold)
			end

			if e.enemy and e.enemy.gems > 0 then
				store.gems_collected = store.gems_collected + e.enemy.gems

				signal.emit("show-gems-reward", e, e.enemy.gems)
			end

			if e.enemy and store.level_mode == GAME_MODE_ENDLESS then
				local conf = W:get_endless_score_config()
				local score = (1 + math.max(h.armor, h.magic_armor)) * h.hp_max * conf.scoreEnemyMultiplier

				if e.motion then
					score = score * e.motion.max_speed / FPS
				end

				score = km.round(score)
				store.player_score = store.player_score + score

				log.debug("ENDLESS: kill score %s (%s)%s - armor:%s magic_armor:%s hp_max:%s speed:%s", score, e.id, e.template_name, h.armor, h.magic_armor, h.hp_max, e.motion and e.motion.max_speed or 0)
			end
		end

		if not h.dead then
			h.last_damage_types = 0
		end

		local health_text = self.health_texts[e.id]
		if health_text then
			local show_health_texts = store.level.show_health_texts
			local text = health_text.texts.list[1]
			health_text.hp = km.round(h.hp)
			local new_text
			if show_health_texts then
				if (e.hero and h.hp == h.hp_max) or h.hp <= 0 or h.dead then
					new_text = ""
				else
					new_text = tostring(health_text.hp)
				end
			else
				new_text = ""
			end
			if new_text ~= text.text then
				text.text = new_text
				queue_insert(store, health_text)
			end
			health_text.pos.x = e.pos.x
			if e.health_bar then
				if e.health_bar.offset then
					health_text.pos.y = e.pos.y + e.health_bar.offset.y + 14
				elseif e.health_bar.y_offset then
					health_text.pos.y = e.pos.y + e.health_bar.y_offset + 14
				end
			else
				health_text.pos.y = e.pos.y + 64
			end
		end

		if h.dead and not e.hero and not h.ignore_delete_after and (h.delete_after and store.tick_ts > h.delete_after or h.delete_now) then
			queue_remove(store, e)
		end
	end
end

sys.count_groups = {}
sys.count_groups.name = "count_groups"

function sys.count_groups:init(store)
	store.count_groups = {}
	store.count_groups[COUNT_GROUP_CONCURRENT] = {}
	store.count_groups[COUNT_GROUP_CUMULATIVE] = {}
end

function sys.count_groups:on_queue(entity, store, insertion)
	if insertion and entity.count_group then
		local c = entity.count_group

		if c.in_limbo then
			c.in_limbo = nil

			return true
		end

		local g = store.count_groups

		if not g[c.type][c.name] then
			g[c.type][c.name] = 0
		end

		g[c.type][c.name] = g[c.type][c.name] + 1

		signal.emit("count-group-changed", entity, g[c.type][c.name], 1)
	end
end

function sys.count_groups:on_dequeue(entity, store, insertion)
	if insertion then
		self:on_remove(entity, store)
	end
end

function sys.count_groups:on_remove(entity, store)
	if entity.count_group and not entity.count_group.in_limbo and entity.count_group.type == COUNT_GROUP_CONCURRENT then
		local c = entity.count_group
		local g = store.count_groups

		g[c.type][c.name] = km.clamp(0, 1000000000, g[c.type][c.name] - 1)

		signal.emit("count-group-changed", entity, g[c.type][c.name], -1)
	end

	return true
end

sys.hero_xp_tracking = {}
sys.hero_xp_tracking.name = "hero_xp_tracking"

function sys.hero_xp_tracking:on_update(dt, ts, store)
	for _, d in pairs(store.damage_queue) do
		if d.xp_gain_factor and d.xp_gain_factor > 0 and d.damage_applied and d.damage_applied > 0 then
			local id = d.xp_dest_id or d.source_id
			local e = store.entities[id]

			if not e or not e.hero then
				-- block empty
			else
				local amount = d.damage_applied * d.xp_gain_factor

				e.hero.xp_queued = e.hero.xp_queued + amount

				if log_xp.level >= log_xp.DEBUG_LEVEL then
					local t = store.entities[d.target_id]

					log_xp.debug("XP QUEUE DAMAGE: (%s)%s xp:%.2f damage:%.2f factor:%.2f to:(%s)%s via:%s", e.id, e.template_name, amount, d.damage_applied, d.xp_gain_factor, d.target_id, t and t.template_name or "?", d.source_id)
				end
			end
		end
	end
end

sys.pops = {}
sys.pops.name = "pops"

function sys.pops:on_update(dt, ts, store)
	for _, d in pairs(store.damage_queue) do
		if not d.pop or not d.target_id then
			-- block empty
		else
			local source = store.entities[d.source_id]
			local target = store.entities[d.target_id]
			local pop_entity

			if source and (source.enemy or source.soldier) then
				pop_entity = source
			elseif target then
				pop_entity = target
			else
				goto label_63_0
			end

			if (not d.pop_chance or math.random() < d.pop_chance) and (not d.pop_conds or band(d.damage_result, d.pop_conds) ~= 0) then
				local name = d.pop[math.random(1, #d.pop)]
				local e = E:create_entity(name)

				if e.pop_over_target and target then
					pop_entity = target
				end

				e.pos = V.v(pop_entity.pos.x, pop_entity.pos.y)

				if pop_entity.unit and pop_entity.unit.pop_offset then
					e.pos.y = e.pos.y + pop_entity.unit.pop_offset.y
				elseif pop_entity == target and pop_entity.unit and pop_entity.unit.hit_offset then
					e.pos.y = e.pos.y + pop_entity.unit.hit_offset.y
				end

				e.pos.y = e.pos.y + e.pop_y_offset
				e.render.sprites[1].r = math.random(-21, 21) * math.pi / 180
				e.render.sprites[1].ts = store.tick_ts

				queue_insert(store, e)
			end
		end

		::label_63_0::
	end
end

sys.timed = {}
sys.timed.name = "timed"

function sys.timed:on_update(dt, ts, store)
	for _, e in E:filter_iter(store.entities, "timed") do
		local s = e.render.sprites[e.timed.sprite_id]

		if e.timed.disabled then
			-- block empty
		elseif s.ts == store.tick_ts then
			-- block empty
		elseif e.timed.runs and s.runs == e.timed.runs or e.timed.duration and store.tick_ts - s.ts > e.timed.duration then
			queue_remove(store, e)
		end
	end
end

sys.tween = {}
sys.tween.name = "tween"

function sys.tween:on_insert(entity, store)
	if entity.tween then
		for _, p in pairs(entity.tween.props) do
			for _, n in pairs(p.keys) do
				for i = 1, 2 do
					if type(n[i]) == "string" then
						local nf = loadstring("return " .. n[i])
						local env = {}

						env.this = entity
						env.store = store
						env.math = math
						env.U = U
						env.V = V

						setfenv(nf, env)

						n[i] = nf()
					end
				end
			end
		end

		if entity.tween.random_ts then
			entity.tween.ts = U.frandom(-1 * entity.tween.random_ts, 0)
		end
	end

	return true
end

function sys.tween:on_update(dt, ts, store)
	local fns = {}

	function fns.step(s)
		return 0
	end

	function fns.linear(s)
		return s
	end

	function fns.quad(s)
		return s * s
	end

	function fns.sine(s)
		return 0.5 * (1 - math.cos(s * math.pi))
	end

	local function lerp(a, b, t, fn)
		fn = fn or "linear"

		local ta = type(a)

		if ta == "table" then
			return V.v(lerp(a.x, b.x, t, fn), lerp(a.y, b.y, t, fn))
		elseif ta == "boolean" then
			return a
		else
			return a + (b - a) * fns[fn](t)
		end
	end

	for _, e in E:filter_iter(store.entities, "tween") do
		if e.tween.disabled then
			-- block empty
		else
			local finished = true

			for _, t in pairs(e.tween.props) do
				if t.disabled then
					-- block empty
				else
					local sids = type(t.sprite_id) == "table" and t.sprite_id or {
						t.sprite_id
					}

					for _, sid in pairs(sids) do
						local value
						local s = e.render.sprites[sid]
						local keys = t.keys
						local ka = keys[1]
						local kb = keys[#keys]
						local start_time = keys[1][1]
						local end_time = keys[#keys][1]
						local duration = end_time - start_time
						local time_ref = t.ts or e.tween.ts or s.ts
						local time = store.tick_ts - time_ref

						if t.time_offset then
							time = time + t.time_offset
						end

						if t.loop then
							time = time % duration
						end

						if e.tween.reverse and not t.ignore_reverse then
							time = duration - time
						end

						time = km.clamp(start_time, end_time, time)

						for i = 1, #keys do
							local ki = keys[i]

							if time >= ki[1] then
								ka = ki
							end

							if time <= ki[1] then
								kb = ki

								break
							end
						end

						if ka == kb then
							value = ka[2]
						else
							value = lerp(ka[2], kb[2], (time - ka[1]) / (kb[1] - ka[1]), ka[3] or t.interp)
						end

						if t.multiply then
							if type(value) == "boolean" then
								s[t.name] = value and s[t.name]
							elseif type(value) == "table" then
								s[t.name].x = value.x * s[t.name].x
								s[t.name].y = value.y * s[t.name].y
							else
								s[t.name] = value * s[t.name]
							end
						else
							s[t.name] = value
						end

						if t.loop then
							finished = finished and t.loop
						elseif e.tween.reverse then
							finished = finished and kb == keys[1]
						else
							finished = finished and ka == keys[#keys]
						end
					end
				end
			end

			if finished then
				if e.tween.remove then
					queue_remove(store, e)
				end

				if e.tween.run_once then
					e.tween.disabled = true
				end
			end
		end
	end
end

sys.goal_line = {}
sys.goal_line.name = "goal_line"

function sys.goal_line:on_update(dt, ts, store)
	for _, e in E:filter_iter(store.entities, "nav_path") do
		local node_index = e.nav_path.ni
		local end_node = P:get_end_node(e.nav_path.pi)

		if end_node <= node_index and not P.path_connections[e.nav_path.pi] and e.enemy and e.enemy.remove_at_goal_line then
			log.debug("enemy %s reached goal", e.id)
			signal.emit("enemy-reached-goal", e)

			store.lives = km.clamp(0, 10000, store.lives - e.enemy.lives_cost)
			store.player_gold = store.player_gold + e.enemy.gold

			queue_remove(store, e)
		end
	end
end

sys.texts = {}
sys.texts.name = "texts"

function sys.texts:on_insert(entity, store)
	if entity.texts then
		for _, t in pairs(entity.texts.list) do
			local sprite_id = t.sprite_id
			local image_name = string.format("text_%s_%s_%s", entity.id, sprite_id, store.tick)
			local image = F:create_text_image(t.text, t.size, t.alignment, t.font_name, t.font_size, t.color, t.line_height, store.screen_scale, t.fit_height, t.debug_bg)

			I:add_image(image_name, image, "temp_game_texts", store.screen_scale)

			if t.image_name then
				I:remove_image(t.image_name)
			end
			t.image_name = image_name
			t.image_group = "texts"
			entity.render.sprites[sprite_id].name = image_name
			entity.render.sprites[sprite_id].animated = false
		end
	end

	return true
end

function sys.texts:on_remove(entity, store)
	if entity.texts then
		for _, t in pairs(entity.texts.list) do
			if t.image_name then
				I:remove_image(t.image_name)
			end
		end
	end

	return true
end

sys.particle_system = {}
sys.particle_system.name = "particle_system"

function sys.particle_system:on_insert(entity, store)
	if entity.particle_system then
		local s = entity.particle_system

		s.emit_ts = (s.emit_ts and s.emit_ts or store.tick_ts - 1 / s.emission_rate) + s.ts_offset
		s.ts = store.tick_ts
	end

	return true
end

function sys.particle_system:on_remove(entity, store)
	if entity.particle_system then
		local s = entity.particle_system

		for i = #s.particles, 1, -1 do
			local p = entity.particle_system.particles[i]

			table.removeobject(s.particles, p)
			table.removeobject(store.render_frames, p.f)
		end
	end

	return true
end

function sys.particle_system:on_update(dt, ts, store)
	local function new_frame(draw_order, z, sort_y_offset, sort_y)
		local f = {}

		f.ss = nil
		f.flip_x = false
		f.flip_y = false
		f.pos = {
			x = 0,
			y = 0
		}
		f.r = 0
		f.scale = {
			x = 1,
			y = 1
		}
		f.anchor = {
			x = 0.5,
			y = 0.5
		}
		f.offset = {
			x = 0,
			y = 0
		}
		f.draw_order = draw_order
		f.z = z
		f.sort_y = sort_y
		f.sort_y_offset = sort_y_offset
		f.alpha = 255
		f.hidden = nil

		return f
	end

	local function new_particle(ts)
		local p = {}

		p.pos = {
			x = 0,
			y = 0
		}
		p.r = 0
		p.speed = {
			x = 0,
			y = 0
		}
		p.spin = 0
		p.scale_factor = {
			x = 1,
			y = 1
		}
		p.ts = ts
		p.last_ts = ts

		return p
	end

	local function phase_interp(values, phase, default)
		if not values or #values == 0 then
			return default
		end

		if #values == 1 then
			return values[1]
		end

		local intervals = #values - 1
		local interval = math.floor(phase * intervals)
		local interval_phase = phase * intervals - interval
		local a = values[interval + 1]
		local b = values[interval + 2]
		local ta = type(a)

		if ta == "table" then
			local out = {}

			for i = 1, #a do
				out[i] = a[i] + (b[i] - a[i]) * interval_phase
			end

			return out
		elseif ta == "boolean" then
			return a
		elseif a ~= nil and b ~= nil then
			return a + (b - a) * interval_phase
		else
			log.error("sys.particle_system:update phase_interp has nil values in %s", getdump(values))

			return default
		end
	end

	for _, e in E:filter_iter(store.entities, "particle_system") do
		local s = e.particle_system
		local tl = store.tick_length
		local to_remove = {}
		local target, target_rot

		if s.track_id then
			target = store.entities[s.track_id]

			if target then
				if not s.last_pos then
					s.last_pos = V.v(target.pos.x, target.pos.y)

					if s.track_offset then
						s.last_pos = V.v(target.pos.x + s.track_offset.x, target.pos.y + s.track_offset.y)
					end
				end

				e.pos.x, e.pos.y = target.pos.x, target.pos.y

				if s.track_offset then
					e.pos.x, e.pos.y = e.pos.x + s.track_offset.x, e.pos.y + s.track_offset.y
				end

				if target.render and target.render.sprites[1] then
					target_rot = target.render.sprites[1].r
				end
			else
				s.emit = false
				s.source_lifetime = 0
			end
		elseif not s.last_pos then
			s.last_pos = {
				x = e.pos.x,
				y = e.pos.y
			}
		end

		if s.emit_duration and s.emit then
			if not s.emit_duration_ts then
				s.emit_duration_ts = store.tick_ts
			end

			if store.tick_ts - s.emit_duration_ts > s.emit_duration then
				s.emit = false
			end
		end

		if not s.emit then
			s.emit_ts = store.tick_ts + s.ts_offset

			if s.last_pos then
				s.last_pos.x = e.pos.x
				s.last_pos.y = e.pos.y
			end
		end

		if s.emit and ts - s.emit_ts > 1 / s.emission_rate then
			local count_frac = (ts - s.emit_ts) * s.emission_rate
			local stepx = (e.pos.x - s.last_pos.x) / count_frac
			local stepy = (e.pos.y - s.last_pos.y) / count_frac
			local count = math.floor(count_frac)

			for i = 1, count do
				local pts = s.emit_ts + i * 1 / s.emission_rate
				local draw_order = s.draw_order and 100000 * s.draw_order + e.id or math.floor(pts * 100)
				local f = new_frame(draw_order, s.z, s.sort_y_offset, s.sort_y)

				table.insert(store.render_frames, f)

				local p = new_particle(pts)

				f.anchor.x, f.anchor.y = s.anchor.x, s.anchor.y

				table.insert(s.particles, p)

				p.f = f
				p.lifetime = U.frandom(s.particle_lifetime[1], s.particle_lifetime[2])

				if s.track_id then
					p.pos.x, p.pos.y = s.last_pos.x + stepx * i, s.last_pos.y + stepy * i
				else
					p.pos.x, p.pos.y = e.pos.x, e.pos.y
				end

				if s.emit_area_spread then
					local sp = s.emit_area_spread

					p.pos.x = p.pos.x + U.frandom(-sp.x / 2, sp.x / 2)
					p.pos.y = p.pos.y + U.frandom(-sp.y / 2, sp.y / 2)
				end

				if s.emit_offset then
					p.pos.x = p.pos.x + s.emit_offset.x
					p.pos.y = p.pos.y + s.emit_offset.y
				end

				if s.emit_speed then
					p.speed.x, p.speed.y = V.rotate(s.emit_direction + U.frandom(-s.emit_spread, s.emit_spread), U.frandom(s.emit_speed[1], s.emit_speed[2]), 0)
				end

				if s.emit_rotation then
					p.r = s.emit_rotation
				elseif s.track_rotation and target_rot then
					p.r = target_rot
				else
					p.r = s.emit_direction + U.frandom(-s.emit_rotation_spread, s.emit_rotation_spread)
				end

				f.flip_x = s.flip_x

				if s.spin then
					p.spin = U.frandom(s.spin[1], s.spin[2])
				end

				if s.scale_var then
					local factor = U.frandom(s.scale_var[1], s.scale_var[2])

					p.scale_factor = V.v(factor, factor)

					if not s.scale_same_aspect then
						p.scale_factor.y = U.frandom(s.scale_var[1], s.scale_var[2])
					end
				end

				if s.names then
					if s.cycle_names then
						if not s._last_name_idx then
							s._last_name_idx = 0
						end

						s._last_name_idx = km.zmod(s._last_name_idx + 1, #s.names)
						p.name_idx = s._last_name_idx
					else
						p.name_idx = math.random(1, #s.names)
					end
				end
			end

			s.emit_ts = s.emit_ts + count * 1 / s.emission_rate
			s.last_pos.x = s.last_pos.x + stepx * count
			s.last_pos.y = s.last_pos.y + stepy * count
		end

		for _, p in pairs(s.particles) do
			do
				local tp = ts - p.last_ts
				local phase = (ts - p.ts) / p.lifetime

				if phase >= 1 then
					table.insert(to_remove, p)

					goto label_77_0
				elseif phase < 0 then
					phase = 0
				end

				local f = p.f

				p.last_ts = ts
				p.pos.x, p.pos.y = p.pos.x + p.speed.x * tp, p.pos.y + p.speed.y * tp
				f.pos.x, f.pos.y = p.pos.x, p.pos.y
				p.r = p.r + p.spin * tp
				f.r = p.r

				local scale_x = phase_interp(s.scales_x, phase, 1)
				local scale_y = phase_interp(s.scales_y, phase, 1)

				f.scale.x, f.scale.y = scale_x * p.scale_factor.x, scale_y * p.scale_factor.y
				f.alpha = phase_interp(s.alphas, phase, 255)

				if s.sort_y_offsets then
					f.sort_y_offset = phase_interp(s.sort_y_offsets, phase, 1)
				end

				local fn

				if s.animated then
					local to = ts - p.ts
					if s.animation_fps then
						to = to * s.animation_fps / FPS
					end
					if p.name_idx then
						fn = A:fn(s.names[p.name_idx], to, s.loop)
					else
						fn = A:fn(s.name, to, s.loop)
					end
				elseif p.name_idx then
					fn = s.names[p.name_idx]
				else
					fn = s.name
				end

				if s.exo then
					local exo_frame = EXO:f(fn)
					if exo_frame then
						f.exo_frame = exo_frame
						f.exo = exo_frame.exo
						if s.exo_hide_prefix then
							for _, p in ipairs(f.exo_frame.parts) do
								p.hidden = false
								for _, prefix in ipairs(s.exo_hide_prefix) do
									if string.find(p.name, prefix, 1, true) then
										p.hidden = true
										break
									end
								end
							end
						end
					end
				else
					f.ss = I:s(fn)
				end
			end

			::label_77_0::
		end

		for _, p in pairs(to_remove) do
			table.removeobject(s.particles, p)
			table.removeobject(store.render_frames, p.f)
		end

		if s.source_lifetime and ts - s.ts > s.source_lifetime then
			s.emit = false

			if #s.particles == 0 then
				queue_remove(store, e)
			end
		end
	end
end

sys.render = {}
sys.render.name = "render"

function sys.render:init(store)
	store.render_frames = {}

	local hb_quad = love.graphics.newQuad(unpack(HEALTH_BAR_CORNER_DOT_QUAD))

	self._hb_ss = {
		ref_scale = 1,
		quad = hb_quad,
		trim = {
			0,
			0,
			0,
			0
		},
		size = {
			1,
			1
		},
		atlas = "white_rectangle"
	}
	self._hb_sizes = HEALTH_BAR_SIZES[store.texture_size] or HEALTH_BAR_SIZES.default
	self._hb_colors = HEALTH_BAR_COLORS

	if KR_GAME == "kr5" then
		self._hb_colors = HEALTH_BAR_COLORS_KR5

		local features = require("features")

		if features.censored_cn then
			self._hb_colors = HEALTH_BAR_COLORS_KR5_CENSORED_CN
		end
	end
end

function sys.render:on_insert(entity, store)
	if entity.render then
		for i, s in ipairs(entity.render.sprites) do
			local f = {}

			f.ss = nil
			f.flip_x = false
			f.flip_y = false
			f.pos = {
				x = 0,
				y = 0
			}
			f.anchor = {
				x = 0,
				y = 0
			}
			f.offset = {
				x = 0,
				y = 0
			}
			f.draw_order = 100000 * (s.draw_order or i) + entity.id
			f.z = s.z or Z_OBJECTS
			f.sort_y = s.sort_y
			f.sort_y_offset = s.sort_y_offset

			if s.random_ts then
				s.ts = U.frandom(-1 * s.random_ts, 0)
			end

			if s.color then
				f.color = s.color
			end

			if s.shader then
				f.shader = SH:get(s.shader)
				f.shader_args = s.shader_args
			end

			if entity.render.frames[i] then
				table.removeobject(store.render_frames, entity.render.frames[i])
			end

			entity.render.frames[i] = f

			table.insert(store.render_frames, f)
		end
	end

	if entity.health_bar then
		local hb = entity.health_bar
		local fk = hb.black_bar_hp and {} or nil

		if fk then
			fk.flip_x = false
			fk.pos = {
				x = 0,
				y = 0
			}
			fk.r = 0
			fk.alpha = 255
			fk.anchor = {
				x = 0,
				y = 0
			}
			fk.offset = V.vclone(hb.offset)
			fk.draw_order = (hb.draw_order and 100000 * hb.draw_order or 200001) + entity.id
			fk.z = Z_OBJECTS
			fk.sort_y_offset = hb.sort_y_offset
			fk.ss = self._hb_ss
			fk.color = hb.colors and hb.colors.black or self._hb_colors.black

			local hbsize = self._hb_sizes[hb.type]

			fk.bar_width = hbsize.x
			fk.scale = V.v(hbsize.x, hbsize.y)
			fk.offset.x = fk.offset.x - hbsize.x / 2
		end

		local fb = {}

		fb.flip_x = false
		fb.pos = {
			x = 0,
			y = 0
		}
		fb.r = 0
		fb.alpha = 255
		fb.anchor = {
			x = 0,
			y = 0
		}
		fb.offset = V.vclone(hb.offset)
		fb.draw_order = (hb.draw_order and 100000 * hb.draw_order + 1 or 200002) + entity.id
		fb.z = Z_OBJECTS
		fb.sort_y_offset = hb.sort_y_offset
		fb.ss = self._hb_ss
		fb.color = hb.colors and hb.colors.bg or self._hb_colors.bg

		local hbsize = self._hb_sizes[hb.type]

		fb.bar_width = hbsize.x
		fb.scale = V.v(hbsize.x, hbsize.y)
		fb.offset.x = fb.offset.x - hbsize.x * fb.ss.ref_scale / 2

		local ff = {}

		ff.flip_x = false
		ff.pos = {
			x = 0,
			y = 0
		}
		ff.r = 0
		ff.alpha = 255
		ff.anchor = {
			x = 0,
			y = 0
		}
		ff.offset = V.vclone(hb.offset)
		ff.draw_order = (hb.draw_order and 100000 * hb.draw_order + 2 or 200003) + entity.id
		ff.z = Z_OBJECTS
		ff.sort_y_offset = hb.sort_y_offset
		ff.ss = self._hb_ss
		ff.color = hb.colors and hb.colors.fg or self._hb_colors.fg

		local hbsize = self._hb_sizes[hb.type]

		ff.bar_width = hbsize.x
		ff.scale = V.v(hbsize.x, hbsize.y)
		ff.offset.x = ff.offset.x - hbsize.x * ff.ss.ref_scale / 2

		for i = #hb.frames, 1, -1 do
			table.removeobject(store.render_frames, hb.frames[i])
		end

		hb.frames[1] = fb
		hb.frames[2] = ff

		table.insert(store.render_frames, fb)
		table.insert(store.render_frames, ff)

		if fk then
			hb.frames[3] = fk

			table.insert(store.render_frames, fk)
		end
	end

	return true
end

function sys.render:on_remove(entity, store)
	if entity.render then
		for i = #entity.render.frames, 1, -1 do
			local f = entity.render.frames[i]

			table.removeobject(store.render_frames, f)

			entity.render.frames[i] = nil
		end
	end

	if entity.health_bar then
		for i = #entity.health_bar.frames, 1, -1 do
			local f = entity.health_bar.frames[i]

			table.removeobject(store.render_frames, f)

			entity.health_bar.frames[i] = nil
		end
	end

	return true
end

function sys.render:on_update(dt, ts, store)
	local d = store
	local entities = d.entities

	for _, e in E:filter_iter(entities, "render") do
		for i, s in ipairs(e.render.sprites) do
			local f = e.render.frames[i]
			local last_runs = s.runs
			local fn, runs, idx

			if s.animation then
				fn, runs, idx = A:fni(s.animation, ts - s.ts + s.time_offset, s.loop, s.fps)
				s.runs = runs
				s.frame_idx = idx
			elseif s.animated then
				local full_name

				if s.prefix then
					full_name = s.prefix .. "_" .. s.name
				else
					full_name = s.name
				end

				fn, runs, idx = A:fn(full_name, ts - s.ts + s.time_offset, s.loop, s.fps)
				s.runs = runs
				s.frame_idx = idx
				s.frame_name = fn
			else
				s.runs = 0
				s.frame_idx = 1
				fn = s.name
			end

			if s.sync_idx then
				s.sync_flag = s.frame_idx == s.sync_idx
			elseif s.sync_flag == nil then
				s.sync_flag = s.frame_idx == 1
			else
				s.sync_flag = last_runs ~= s.runs
			end

			if s.exo then
				local exo_frame = EXO:f(fn)

				if exo_frame then
					f.exo_frame = exo_frame
					f.exo = exo_frame.exo

					if s.exo_hide_prefix then
						for _, p in ipairs(f.exo_frame.parts) do
							p.hidden = false

							for _, prefix in ipairs(s.exo_hide_prefix) do
								if string.find(p.name, prefix, 1, true) then
									p.hidden = true

									break
								end
							end
						end
					end
				end
			else
				local ss = I:s(fn)

				f.ss = ss
			end

			f.flip_x = s.flip_x
			f.flip_y = s.flip_y

			if s.pos then
				f.pos.x, f.pos.y = s.pos.x, s.pos.y
			else
				f.pos.x, f.pos.y = e.pos.x, e.pos.y
			end

			f.r = s.r
			f.scale = s.scale
			f.anchor.x, f.anchor.y = s.anchor.x, s.anchor.y
			f.offset.x, f.offset.y = s.offset.x, s.offset.y
			f.z = s.z or Z_OBJECTS
			f.sort_y = s.sort_y
			f.sort_y_offset = s.sort_y_offset
			f.draw_order = 100000 * (s.draw_order or i) + e.id
			f.alpha = s.alpha

			if s.hide_after_runs and s.runs >= s.hide_after_runs then
				s.hidden = true
			end

			f.hidden = s.hidden

			if ts < s.ts then
				f.hidden = true
			end
		end

		if e.health_bar then
			local hb = e.health_bar
			local fb = hb.frames[1]
			local ff = hb.frames[2]
			local fk = hb.black_bar_hp and hb.frames[3] or nil

			if hb.hidden then
				fb.hidden = true
				ff.hidden = true

				if fk then
					fk.hidden = true
				end
			else
				if not hb.disable_fade then
					if e.health.hp == e.health.hp_max then
						if hb.alpha > 0 then
							if not hb.fade_ts then
								hb.fade_ts = ts
							end

							hb.alpha = 255 * km.clamp(0, 1, 1 - (ts - hb.fade_ts) / hb.hide_duration)
						else
							hb.fade_ts = nil
						end
					elseif hb.alpha < 255 then
						if not hb.fade_ts then
							hb.fade_ts = ts
						end

						hb.alpha = 255 * km.clamp(0, 1, (ts - hb.fade_ts) / hb.show_duration)
					else
						hb.fade_ts = nil
					end

					fb.alpha = hb.alpha
					ff.alpha = hb.alpha

					if fk then
						fk.alpha = hb.alpha
					end
				end

				fb.hidden = false
				ff.hidden = false

				if fk then
					fk.hidden = false
				end

				fb.pos.x, fb.pos.y = math.floor(e.pos.x), math.ceil(e.pos.y)
				ff.pos.x, ff.pos.y = math.floor(e.pos.x), math.ceil(e.pos.y)
				fb.offset.x, fb.offset.y = hb.offset.x - fb.bar_width * fb.ss.ref_scale / 2, hb.offset.y
				ff.offset.x, ff.offset.y = hb.offset.x - ff.bar_width * ff.ss.ref_scale / 2, hb.offset.y
				fb.z = hb.z or Z_OBJECTS
				ff.z = hb.z or Z_OBJECTS
				fb.draw_order = (hb.draw_order and 100000 * hb.draw_order + 1 or 200002) + e.id
				ff.draw_order = (hb.draw_order and 100000 * hb.draw_order + 2 or 200003) + e.id
				fb.sort_y_offset = hb.sort_y_offset
				ff.sort_y_offset = hb.sort_y_offset

				if fk then
					fk.pos.x, fk.pos.y = math.floor(e.pos.x), math.floor(e.pos.y)
					fk.offset.x, fk.offset.y = hb.offset.x - fk.bar_width * fk.ss.ref_scale / 2, hb.offset.y
					fk.z = hb.z or Z_OBJECTS
					fk.sort_y_offset = hb.sort_y_offset
					fk.draw_order = (hb.draw_order and 100000 * hb.draw_order or 200001) + e.id
					ff.scale.x = e.health.hp / hb.black_bar_hp * ff.bar_width
					fb.scale.x = e.health.hp_max / hb.black_bar_hp * fb.bar_width
				else
					ff.scale.x = e.health.hp / e.health.hp_max * ff.bar_width
				end
			end
		end
	end

	local function insertsort(a)
		local len = #a

		for i = 2, len do
			local f1_lte_f2
			local f1 = a[i]
			local y1 = f1.sort_y or (f1.sort_y_offset and f1.sort_y_offset or 0) + f1.pos.y

			for j = i - 1, 0, -1 do
				if j == 0 then
					a[j + 1] = f1

					break
				end

				local f2 = a[j]
				local y2 = f2.sort_y or (f2.sort_y_offset and f2.sort_y_offset or 0) + f2.pos.y

				if f1.z == f2.z then
					if y1 == y2 then
						if f1.draw_order == f2.draw_order then
							f1_lte_f2 = f1.pos.x < f2.pos.x
						else
							f1_lte_f2 = f1.draw_order < f2.draw_order
						end
					else
						f1_lte_f2 = y2 < y1
					end
				else
					f1_lte_f2 = f1.z < f2.z
				end

				if f1_lte_f2 then
					a[j + 1] = a[j]
				else
					a[j + 1] = f1

					break
				end
			end
		end
	end

	insertsort(store.render_frames)
end

sys.sound_events = {}
sys.sound_events.name = "sound_events"

function sys.sound_events:on_insert(entity, store)
	local se = entity.sound_events

	if se and se.insert then
		local sounds = se.insert

		if type(sounds) ~= "table" then
			sounds = {
				sounds
			}
		end

		for _, s in pairs(sounds) do
			S:queue(s, se.insert_args)
		end
	end

	return true
end

function sys.sound_events:on_remove(entity, store)
	local se = entity.sound_events

	if se then
		if se.remove then
			local sounds = se.remove

			if type(sounds) ~= "table" then
				sounds = {
					sounds
				}
			end

			for _, s in pairs(sounds) do
				S:queue(s, se.remove_args)
			end
		end

		if se.remove_stop then
			local sounds = se.remove_stop

			if type(sounds) ~= "table" then
				sounds = {
					sounds
				}
			end

			for _, s in pairs(sounds) do
				S:stop(s, se.remove_stop_args)
			end
		end
	end

	return true
end

sys.seen_tracker = {}
sys.seen_tracker.name = "seen_tracker"

function sys.seen_tracker:init(store)
	local slot = storage:load_slot()

	store.seen = slot.seen and slot.seen or {}
	store.seen_dirty = nil
end

function sys.seen_tracker:on_insert(entity, store)
	if (entity.tower or entity.enemy) and not entity.ignore_seen_tracker then
		U.mark_seen(store, entity.template_name)
	end

	return true
end

function sys.seen_tracker:on_update(dt, ts, store)
	if store.seen_dirty then
		local slot = storage:load_slot()

		slot.seen = store.seen

		storage:save_slot(slot)

		store.seen_dirty = false
	end
end

sys.dbg_enemy_tracker = {}
sys.dbg_enemy_tracker.name = "dbg_enemy_tracker"

local function format_stats(det)
	local diff = det.c_removed - (det.c_killed + det.c_end_node_reached)

	return string.format("enemy tracker - ins:%s | rem:%s (kill:%s + reach:%s = %s) %s", det.c_inserted, det.c_removed, det.c_killed, det.c_end_node_reached, diff, diff ~= 0 and "ERROR" or "")
end

function sys.dbg_enemy_tracker:init(store)
	store.det = {}
	store.det.c_inserted = 0
	store.det.c_removed = 0
	store.det.c_killed = 0
	store.det.c_end_node_reached = 0
end

function sys.dbg_enemy_tracker:on_insert(entity, store)
	if entity.enemy then
		store.det.c_inserted = store.det.c_inserted + 1

		log.debug(format_stats(store.det))
	end

	return true
end

function sys.dbg_enemy_tracker:on_remove(entity, store)
	if entity.enemy then
		store.det.c_removed = store.det.c_removed + 1

		if entity.enemy and entity.health.dead then
			store.det.c_killed = store.det.c_killed + 1
		end

		if entity.nav_path then
			local pi = entity.nav_path.pi
			local ni = entity.nav_path.ni
			local end_ni = P:get_end_node(pi)

			if end_ni <= ni then
				store.det.c_end_node_reached = store.det.c_end_node_reached + 1
			end
		end

		log.debug(format_stats(store.det))

		if store.det.c_removed ~= store.det.c_killed + store.det.c_end_node_reached then
			log.debug("DBG_ENEMY_TRACKER: ENEMY REMOVAL UNKNOWN: (%s) %s", entity.id, entity.template_name)
		end
	end

	return true
end

sys.dbg_damage_full_track = {}
sys.dbg_damage_full_track.name = "dbg_damage_full_track"

function sys.dbg_damage_full_track:on_update(dt, ts, store)
	if DEBUG_DAMAGE_FULL_TRACK then
		for i = #store.damage_queue, 1, -1 do
			local d = store.damage_queue[i]

			d.track_damage = true
		end
	end
end

sys.editor_overrides = {}
sys.editor_overrides.name = "editor_overrides"

function sys.editor_overrides:on_insert(entity, store)
	if entity.editor and entity.editor.components then
		for _, c in pairs(entity.editor.components) do
			E:add_comps(entity, c)
		end
	end

	if entity.editor and entity.editor.overrides then
		for k, v in pairs(entity.editor.overrides) do
			LU.eval_set_prop(entity, k, v)
		end
	end

	return true
end

sys.editor_script = {}
sys.editor_script.name = "editor_script"

function sys.editor_script:on_insert(entity, store)
	if entity.editor_script and entity.editor_script.insert then
		return entity.editor_script.insert(entity, store, entity.editor_script.insert)
	else
		return true
	end
end

function sys.editor_script:on_remove(entity, store)
	if entity.editor_script and entity.editor_script.remove then
		return entity.editor_script.remove(entity, store, entity.editor_script.remove)
	else
		return true
	end
end

function sys.editor_script:on_update(dt, ts, store)
	for _, e in E:filter_iter(store.entities, "editor_script") do
		local s = e.editor_script

		if not s.update then
			-- block empty
		else
			if not s.co and s.runs ~= 0 then
				s.runs = s.runs - 1
				s.co = coroutine.create(s.update)
			end

			if s.co then
				local success, error = coroutine.resume(s.co, e, store, s)

				if coroutine.status(s.co) == "dead" or error ~= nil then
					if error ~= nil then
						log.error("Error running editor_script coro: %s", debug.traceback(s.co, error))
					end

					s.co = nil
				end
			end
		end
	end
end

sys.damage_texts = {}
sys.damage_texts.name = "damage_texts"
sys.damage_texts.template = "debug_damage_text"
sys.damage_texts.colors = {
	[DAMAGE_PHYSICAL] = {
		255,
		0,
		0
	},
	[DAMAGE_MAGICAL] = {
		0,
		0,
		255
	},
	[DAMAGE_EXPLOSION] = {
		0,
		255,
		255
	},
	[DAMAGE_ELECTRICAL] = {
		0,
		255,
		255
	},
	[DAMAGE_TRUE] = {
		255,
		255,
		0
	}
}

function sys.damage_texts:on_update(dt, ts, store)
	if not DEBUG_SHOW_DAMAGES then
		return
	end

	local damage_template = self.template
	local color_config = self.colors

	for _, d in pairs(store.damage_queue) do
		if not d.target_id then
			-- block empty
		else
			local source = store.entities[d.source_id]
			local target = store.entities[d.target_id]
			local e = E:create_entity(damage_template)
			local target_entity = target

			e.pos = V.v(target_entity.pos.x, target_entity.pos.y)
			e.pos.y = e.pos.y + 20
			e.pos.y = e.pos.y + 0

			local text = e.texts.list[1]

			text.text = tostring(d.damage_applied)
			e.tween.ts = store.tick_ts

			for damage_type, color in pairs(color_config) do
				if band(damage_type, d.damage_type) ~= 0 then
					text.color = table.deepclone(color)

					break
				end
			end

			if d.damage_applied < d.value then
				text.color[1] = 0.65 * text.color[1]
				text.color[2] = 0.65 * text.color[2]
				text.color[3] = 0.65 * text.color[3]
			end

			queue_insert(store, e)
		end
	end
end

return sys
