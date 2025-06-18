-- chunkname: @./kr5/data/levels/level01.lua

local log = require("klua.log"):new("level01")
local signal = require("hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("klua.vector")
local P = require("path_db")
local G = love.graphics
local SU = require("script_utils")
local storage = require("storage")
local W = require("wave_db")

require("constants")

local tower_menus = require("data.tower_menus_data")

local function fts(v)
	return v / FPS
end

local function set_can_click_on_all_holders(store, can_click)
	local holders = table.filter(store.entities, function(_, v)
		return v.tower and v.tower.holder_id
	end)

	for _, h in ipairs(holders) do
		h.ui.can_click = can_click
		h.tower.can_hover = can_click
	end
end

local function get_holder_by_id(store, id)
	return table.filter(store.entities, function(_, v)
		return v.tower and v.tower.holder_id == id
	end)[1]
end

local function show_focus_circle(store, pos)
	local screen_focus_circle = E:create_entity("screen_focus_circle")

	screen_focus_circle.circle_pos = pos
	screen_focus_circle.circle_radius = 200

	LU.queue_insert(store, screen_focus_circle)

	return screen_focus_circle
end

local function remove_focus_circle(store, circle)
	circle.tween.remove = true
	circle.tween.ts = store.tick_ts
	circle.tween.reverse = true
end

local function freeze_enemies(store)
	local enemies = table.filter(store.entities, function(k, e)
		return e.enemy and not e.health.dead
	end)

	for _, e in ipairs(enemies) do
		e._lastfps = e.render.sprites[1].fps
		e._lastmaxspeed = e.motion.max_speed
		e.render.sprites[1].fps = 0
		e.motion.max_speed = 0
		e.un_freez_flags = e.vis.flags
		e.vis.flags = F_CUSTOM

		if e.ui then
			e.ui.can_click = false
			e.ui.can_select = false
		end
	end

	return enemies
end

local function unfreeze_enemies(enemies)
	for _, e in ipairs(enemies) do
		e.render.sprites[1].fps = e._lastfps
		e.motion.max_speed = e._lastmaxspeed

		if e.un_freez_flags then
			e.vis.flags = e.un_freez_flags
		end

		if e.ui then
			e.ui.can_click = true
			e.ui.can_select = true
		end
	end
end

local function restore_all_holders_and_builds(store)
	signal.emit("tutorial-tower-enable-all")
	set_can_click_on_all_holders(store, true)
end

local level = {}
local holder_to_enable_archer = {}
local holder_to_enable_barrack = {}

level.tower_menu_hiding = true
level.hide_notifications = false

local zoom_in_depth = KR_TARGET == "phone" and 1.75 or 1.25
local signal_handlers

local function unregister_signals()
	for _, row in pairs(signal_handlers) do
		local id, name, fn = unpack(row)

		log.debug("unregistering signal: %s:%s", id, name)
		signal.remove(name, fn)
	end

	signal_handlers = {}
end

function level:init(store)
	for _, towerItem in pairs(tower_menus) do
		for _, levelItem in pairs(towerItem) do
			for _, actionItem in pairs(levelItem) do
				if actionItem.action_arg ~= "tower_build_royal_archers" then
					actionItem.action = "tw_none"
				end
			end
		end
	end

	self.manual_hero_insertion = false

	local user_data = storage:load_slot()
	local already_passed_tutorial = user_data.levels[1] and user_data.levels[1][1] ~= nil
	local unlocked_raelyn = user_data.levels[2] and user_data.levels[2][1] ~= nil

	if store.level_mode == GAME_MODE_CAMPAIGN then
		if not already_passed_tutorial or not unlocked_raelyn then
			self.manual_hero_insertion = true

			if already_passed_tutorial then
				local hero = LU.insert_hero_kr5(store, store.selected_team[1], V.v(-68, 382), store.selected_team_status[store.selected_team[1]])

				hero.nav_rally.new = true
				hero.nav_rally.center = V.vclone(hero.pos)
				hero.nav_rally.pos = V.vclone(hero.nav_rally.center)
			end
		end
	elseif not unlocked_raelyn then
		self.manual_hero_insertion = true

		local hero = LU.insert_hero_kr5(store, store.selected_team[1], V.v(-68, 382), store.selected_team_status[store.selected_team[1]])

		hero.nav_rally.new = true
		hero.nav_rally.center = V.vclone(hero.pos)
		hero.nav_rally.pos = V.vclone(hero.nav_rally.center)
	end
end

function level:preprocess(store)
	if store.level_mode == GAME_MODE_CAMPAIGN then
		level.show_comic_idx = 1
	end
end

function level:load(store)
	signal_handlers = {
		{
			"_game_restart",
			"game-restart",
			function()
				unregister_signals()
			end
		},
		{
			"_game_quit",
			"game-quit",
			function()
				unregister_signals()
			end
		}
	}

	for _, row in pairs(signal_handlers) do
		local id, sn, sf = unpack(row)

		signal.register(sn, sf)
	end
end

function level:update(store)
	local function sig_reg(id, name, fn)
		signal.register(name, fn)
		table.insert(signal_handlers, {
			id,
			name,
			fn
		})
	end

	local function sig_del(id)
		for i, row in ipairs(signal_handlers) do
			local sid, name, fn = unpack(row)

			if id == sid then
				log.debug("unregistering signal: %s:%s", id, name)
				signal.remove(name, fn)
				table.remove(signal_handlers, i)

				return
			end
		end
	end

	local function y_wait_enemy_dead()
		local enemies

		while true do
			enemies = table.filter(store.entities, function(k, e)
				return e.enemy
			end)

			if enemies then
				local enemy_dead_found

				for i, v in pairs(enemies) do
					if v.health.dead then
						enemy_dead_found = true

						break
					end
				end

				if enemy_dead_found then
					break
				end
			end

			coroutine.yield()
		end

		return enemies
	end

	local user_data = storage:load_slot()
	local already_passed_tutorial = user_data.levels[1] and user_data.levels[1][1] ~= nil
	local unlocked_raelyn = user_data.levels[2] and user_data.levels[2][1] ~= nil

	if not unlocked_raelyn then
		signal.emit("hide-second-hero")
	end

	local first_hero

	for _, v in pairs(store.entities) do
		if v.template_name == store.selected_team[1] then
			first_hero = v
		end
	end

	if store.level_mode == GAME_MODE_CAMPAIGN and already_passed_tutorial then
		W:get_group(2).interval = 300

		if self.manual_hero_insertion then
			signal.emit("hero-added", first_hero)
		end

		signal.emit("fade-in", 2)

		local custom_start_pos = {
			zoom = 1.2,
			pos = {
				x = -10,
				y = 368
			}
		}

		LU.set_custom_start_pos(store, custom_start_pos)

		local bushes = table.filter(store.entities, function(k, e)
			return e.template_name == "stage_01_bush"
		end)

		for _, bush in ipairs(bushes) do
			simulation:queue_remove_entity(bush)
		end

		while store.wave_group_number < 1 do
			coroutine.yield()
		end

		signal.emit("unlock-user-power", 1)
		signal.emit("unlock-user-power", 2)

		if unlocked_raelyn then
			signal.emit("unlock-user-power", 3)
		end

		while store.wave_group_number < 3 do
			coroutine.yield()
		end

		while store.wave_group_number < 4 do
			coroutine.yield()
		end

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		store.custom_game_outcome = {
			postpone_unload = true,
			next_item_name = "tutorial_end"
		}
	elseif store.level_mode == GAME_MODE_CAMPAIGN then
		local function T(name)
			return E:get_template(name)
		end

		T("enemy_hog_invader").health.hp_max = 48

		signal.emit("ftue-step", "tutorial_begins")

		local c_taunt = E:create_entity("taunts_s01_controller")

		LU.queue_insert(store, c_taunt)
		signal.emit("start-tutorial")
		signal.emit("tutorial-stop-input")
		signal.emit("tutorial-stop-movement")
		set_can_click_on_all_holders(store, false)
		signal.emit("tutorial-tower-enable-only", "tower_build_royal_archers")
		signal.emit("lock-items", 1)
		signal.emit("lock-items", 2)
		signal.emit("lock-items", 3)
		U.y_wait(store, 3)

		holder_to_enable_archer = get_holder_by_id(store, "6")
		holder_to_enable_archer.ui.can_click = true
		holder_to_enable_archer.tower.can_hover = true

		signal.emit("pan-zoom-camera", 2, {
			x = 724,
			y = 451
		}, zoom_in_depth)

		local circle = show_focus_circle(store, V.v(694, 451))

		U.y_wait(store, 2.5)
		signal.emit("tutorial-resume-input")
		signal.emit("tutorial-hover-id", holder_to_enable_archer.id)

		local tower_build_indicator
		local royal_archer_tower = {}

		while true do
			if level.tower_menu_hiding and not holder_to_enable_archer.tower.upgrade_to then
				if not tower_build_indicator then
					tower_build_indicator = E:create_entity("stage_01_tower_build_indicator")
					tower_build_indicator.pos = holder_to_enable_archer.pos
					tower_build_indicator.tween.ts = store.tick_ts

					LU.queue_insert(store, tower_build_indicator)

					holder_to_enable_archer.ui.can_click = true
					holder_to_enable_archer.tower.can_hover = true
				end
			elseif tower_build_indicator then
				signal.emit("show-balloon_tutorial", "TB_BUILD", false)

				holder_to_enable_archer.ui.can_click = false
				holder_to_enable_archer.tower.can_hover = false
				tower_build_indicator.tween.reverse = true
				tower_build_indicator.tween.ts = store.tick_ts
				tower_build_indicator.tween.remove = true

				U.y_wait(store, 0.5)

				tower_build_indicator = nil
			end

			local towers = table.filter(store.entities, function(k, e)
				return e.tower and not e.tower_holder
			end)

			if towers and #towers > 0 then
				royal_archer_tower = towers[1]

				if royal_archer_tower.template_name == "tower_royal_archers_lvl1" then
					royal_archer_tower.ui.can_click = false
					royal_archer_tower.tower.can_hover = false

					local b = E:get_template(royal_archer_tower.attacks.list[1].bullet)

					b._damage_min = b.bullet.damage_min
					b._damage_max = b.bullet.damage_max
					b.bullet.damage_min = 6
					b.bullet.damage_max = 6
					royal_archer_tower.attacks.list[1].vis_bans = F_CUSTOM

					break
				end
			end

			coroutine.yield()
		end

		signal.emit("ftue-step", "click_archers_build")
		remove_focus_circle(store, circle)
		U.y_wait(store, 2)
		signal.emit("tutorial-show-wave")
		signal.emit("tutorial-stop-input")
		signal.emit("pan-zoom-camera", 1, {
			x = 800,
			y = 450
		}, zoom_in_depth)

		circle = show_focus_circle(store, V.v(1100, 450))

		U.y_wait(store, 1)
		signal.emit("show-balloon_tutorial", "TB_START", false)
		signal.emit("tutorial-resume-input")
		signal.emit("tutorial-focus-wave")

		while store.wave_group_number < 1 do
			coroutine.yield()
		end

		signal.emit("ftue-step", "click_instacall_confirm_1_wave")
		signal.emit("hide-balloon-tutorial", "TB_START")

		store.tutorial_hold_wave = true

		signal.emit("tutorial-stop-input")
		signal.emit("pan-zoom-camera", 1, {
			x = 800,
			y = 450
		}, zoom_in_depth)
		remove_focus_circle(store, circle)

		local enemies = y_wait_enemy_dead()

		signal.emit("highlight-gold", 5)

		for _, value in pairs(enemies) do
			local enemy_decal = E:create_entity("stage_01_dead_enemy_indicator")

			enemy_decal.pos = V.v(value.pos.x, value.pos.y)

			if v.health and v.health.dead then
				enemy_decal.pos.x = enemy_decal.pos.x + 22
			end

			enemy_decal.tween.ts = store.tick_ts

			LU.queue_insert(store, enemy_decal)
		end

		local enemies = freeze_enemies(store)

		signal.emit("pan-zoom-camera", 1, {
			x = 656,
			y = 500
		}, zoom_in_depth)

		circle = show_focus_circle(store, V.v(680, 557))

		U.y_wait(store, 1)
		signal.emit("show-balloon_tutorial", "TB_GOLD", false)
		U.y_wait(store, 3)
		signal.emit("turn-off-balloon")
		remove_focus_circle(store, circle)
		unfreeze_enemies(enemies)

		while LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		signal.emit("ftue-step", "kill_first_enemy")
		signal.emit("pan-zoom-camera", 2, {
			x = 244,
			y = 360
		}, zoom_in_depth)

		circle = show_focus_circle(store, V.v(-15, 384))

		U.y_wait(store, 2)
		signal.emit("show-balloon_tutorial", "TB_GOAL", false)

		flags = table.filter(store.entities, function(k, e)
			return e.template_name == "decal_defense_flag5"
		end)

		for _, value in pairs(flags) do
			local flag_decal = E:create_entity("stage_01_dead_enemy_indicator")

			flag_decal.pos = V.v(value.pos.x, value.pos.y)
			flag_decal.tween.ts = store.tick_ts

			LU.queue_insert(store, flag_decal)
		end

		U.y_wait(store, 3.5)
		signal.emit("turn-off-balloon")
		remove_focus_circle(store, circle)
		signal.emit("pan-zoom-camera", 2, {
			x = 739,
			y = 500
		}, zoom_in_depth)
		U.y_wait(store, 2)

		store.tutorial_hold_wave = false

		while store.wave_group_number < 2 do
			coroutine.yield()
		end

		signal.emit("ftue-step", "click_instacall_confirm_2_wave")
		U.y_wait(store, 0.5)

		store.tutorial_hold_wave = true

		local entites_shaman = table.filter(store.entities, function(k, e)
			return e.template_name == "stage_01_shaman"
		end)
		local shaman = entites_shaman[1]

		U.y_wait(store, 4)
		S:queue("Stage01ArboreanSageAppear")
		S:queue("Stage01ArboreanSageCast")
		U.y_animation_play(shaman, "spawn", false, store.tick_ts, false, 1)
		U.y_animation_play(shaman, "ability_start", false, store.tick_ts, false, 1)
		U.animation_start(shaman, "idle3", false, store.tick_ts, true, 1)
		signal.emit("show-balloon_tutorial", "LV01_ARBOREAN01", false)

		local bush_barrack = table.filter(store.entities, function(_, v)
			return v.bush_id == "1"
		end)[1]

		S:queue("Stage01ArboreanSageShrubDisappear")
		U.animation_start(bush_barrack, "out", false, store.tick_ts, false, 1)
		U.y_wait(store, 0.3)
		U.y_wait(store, 0.2)
		U.y_animation_play(shaman, "ability_end", false, store.tick_ts, false, 1)
		U.animation_start(shaman, "idle2", false, store.tick_ts, true, 1)
		U.y_wait(store, 1)
		simulation:queue_remove_entity(bush_barrack)

		enemies = freeze_enemies(store)
		circle = show_focus_circle(store, V.v(850, 550))

		U.y_wait(store, 2)
		signal.emit("tutorial-resume-input")
		signal.emit("tutorial-stop-movement")

		holder_to_enable_barrack = get_holder_by_id(store, "7")
		holder_to_enable_barrack.ui.can_click = true
		holder_to_enable_barrack.tower.can_hover = true

		signal.emit("tutorial-tower-enable-only", "tower_build_paladin_covenant")
		signal.emit("tutorial-hover-id", holder_to_enable_barrack.id)

		while true do
			if level.tower_menu_hiding and not holder_to_enable_barrack.tower.upgrade_to then
				if not tower_build_indicator then
					tower_build_indicator = E:create_entity("stage_01_tower_build_indicator")
					tower_build_indicator.pos = holder_to_enable_barrack.pos
					tower_build_indicator.tween.ts = store.tick_ts

					LU.queue_insert(store, tower_build_indicator)
				end
			elseif tower_build_indicator then
				tower_build_indicator.tween.reverse = true
				tower_build_indicator.tween.ts = store.tick_ts
				tower_build_indicator.tween.remove = true

				U.y_wait(store, 0.5)

				tower_build_indicator = nil
			end

			if holder_to_enable_barrack.tower.upgrade_to or store.wave_group_number < 2 then
				holder_to_enable_barrack.ui.can_click = false
				holder_to_enable_barrack.tower.can_hover = false

				break
			end

			coroutine.yield()
		end

		remove_focus_circle(store, circle)
		unfreeze_enemies(enemies)
		signal.emit("ftue-step", "click_paladin_build")

		local towers = table.filter(store.entities, function(k, e)
			return e.tower and not e.tower_holder and e.template_name == "tower_paladin_covenant_lvl1"
		end)

		signal.emit("tutorial-stop-input")

		holder_to_enable_barrack.ui.can_click = true
		holder_to_enable_barrack.tower.can_hover = true

		signal.emit("pan-zoom-camera", 1, {
			x = 739,
			y = 500
		}, zoom_in_depth)

		while true do
			enemies = table.filter(store.entities, function(k, e)
				return e.enemy and not e.health.dead
			end)

			if #enemies == 0 then
				break
			end

			coroutine.yield()
		end

		if towers and #towers > 0 then
			royal_archer_tower.ui.can_click = true
			royal_archer_tower.tower.can_hover = true

			local b = E:get_template(royal_archer_tower.attacks.list[1].bullet)

			b.bullet.damage_min = b._damage_min
			b.bullet.damage_max = b._damage_max

			restore_all_holders_and_builds(store)
		end

		royal_archer_tower.ui.can_click = true
		royal_archer_tower.tower.can_hover = true

		local b = E:get_template(royal_archer_tower.attacks.list[1].bullet)

		b.bullet.damage_min = b._damage_min
		b.bullet.damage_max = b._damage_max

		signal.emit("pan-zoom-camera", 2, {
			x = 850,
			y = 450
		}, 1.1)
		U.y_wait(store, 2)
		S:queue("Stage01ArboreanSageCast")
		U.y_animation_play(shaman, "ability_start", false, store.tick_ts, false, 1)
		U.animation_start(shaman, "idle3", false, store.tick_ts, true, 1)
		signal.emit("show-balloon_tutorial", "LV01_ARBOREAN02", false)

		local bushes = table.filter(store.entities, function(k, e)
			return e.template_name == "stage_01_bush"
		end)

		table.sort(bushes, function(e1, e2)
			return e1.pos.x > e2.pos.x
		end)
		U.y_wait(store, 0.2)

		for _, bush in pairs(bushes) do
			U.animation_start(bush, "out", false, store.tick_ts, false, 1)
			S:queue("Stage01ArboreanSageShrubDisappear")
			U.y_wait(store, 0.3)
		end

		U.y_wait(store, 0.2)
		U.y_animation_play(shaman, "ability_end", false, store.tick_ts, false, 1)
		S:queue("Stage01ArboreanSageDisappear")
		U.animation_start(shaman, "out", false, store.tick_ts, false, 1)
		signal.emit("tutorial-resume-input")
		signal.emit("tutorial-resume-movement")
		signal.emit("show-gui")
		restore_all_holders_and_builds(store)

		store.tutorial_hold_wave = false

		while store.wave_group_number < 3 do
			coroutine.yield()
		end

		signal.emit("ftue-step", "click_instacall_confirm_3_wave")
		U.y_wait(store, 7)
		signal.emit("wave-notification", "view", "POWER_REINFORCEMENT")
		U.y_wait(store, 1)
		signal.emit("show-balloon_tutorial", "TB_POWER1", false)

		local function remove_holder()
			if tower_build_indicator then
				tower_build_indicator.tween.reverse = true
				tower_build_indicator.tween.ts = store.tick_ts
				tower_build_indicator.tween.remove = true
			end
		end

		local ignore_finger_power = false

		sig_reg("reinforcements_power_selected", "power-selected", function(mode)
			if mode == GUI_MODE_POWER_1 and not ignore_finger_power then
				tower_build_indicator = E:create_entity("stage_01_tower_build_indicator")
				tower_build_indicator.pos = V.v(805, 430)
				tower_build_indicator.tween.ts = store.tick_ts

				LU.queue_insert(store, tower_build_indicator)
			end
		end)
		sig_reg("reinforcements_power_used", "power-used", function()
			signal.emit("ftue-step", "drop_reinforcements")
			remove_holder()
			sig_del("reinforcements_power_used")
			sig_del("reinforcements_power_selected")
		end)
		sig_reg("reinforcements_power_deselected", "power-deselected", function()
			remove_holder()
			sig_del("reinforcements_power_deselected")
			sig_del("reinforcements_power_selected")
		end)
		signal.emit("unlock-user-power", 1)

		while store.wave_group_number < 4 do
			coroutine.yield()
		end

		signal.emit("ftue-step", "click_instacall_confirm_4_wave")

		local notification_close = false

		sig_reg("hero_notification_closed", "notification-close", function()
			notification_close = true
		end)
		signal.emit("wave-notification", "view", "TUTORIAL_HERO")

		while not notification_close do
			coroutine.yield()
		end

		sig_del("hero_notification_closed")

		local h = LU.insert_hero_kr5(store, "hero_vesper", V.v(-200, 383), {
			xp = 0,
			skills = {
				ultimate = 1
			}
		})

		h.nav_rally.center = V.v(60, 333)
		h.nav_rally.pos = V.vclone(h.nav_rally.center)
		ignore_finger_power = true

		signal.emit("power-selected", GUI_MODE_POWER_1)
		signal.emit("tutorial-stop-input")
		signal.emit("pan-zoom-camera", 2, {
			x = -100,
			y = 343
		}, 1)
		U.y_wait(store, 4)
		signal.emit("tutorial-resume-input")

		local drag_tutorial = E:create_entity("stage_01_drag_tutorial")

		drag_tutorial.pos = V.vclone(h.nav_rally.center)
		drag_tutorial.hero_ref = h
		drag_tutorial.hero_initial_pos = V.vclone(h.nav_rally.center)
		drag_tutorial.render.sprites[1].ts = store.tick_ts

		LU.queue_insert(store, drag_tutorial)
		U.y_wait(store, 2)
		U.y_wait(store, 3)
		signal.emit("unlock-user-power", 2)
		signal.emit("show-balloon_tutorial", "TB_POWER2", false)
		sig_reg("hero_power_used", "power-used", function(power_id)
			if power_id == 2 then
				signal.emit("ftue-step", "use_hero_power")
				sig_del("hero_power_used")
			end
		end)

		store.custom_game_outcome = {
			postpone_unload = true,
			next_item_name = "tutorial_end"
		}
	elseif self.manual_hero_insertion then
		signal.emit("hero-added", first_hero)
	end

	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end

	log.debug("-- WON")

	if store.level_mode == GAME_MODE_CAMPAIGN then
		U.y_wait(store, 2)
		signal.emit("fade-out", 1)

		if not already_passed_tutorial then
			local user_data = storage:load_slot()

			if #user_data.towers.selected < 4 then
				table.insert(user_data.towers.selected, "tricannon")
				storage:save_slot(user_data)
			end
		end

		U.y_wait(store, 1)
	else
		U.y_wait(store, 2)
	end

	signal.emit("ftue-step", "tutorial_ends")
	unregister_signals()
end

return level
