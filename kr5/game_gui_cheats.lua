local log = require("klua.log"):new("game_gui_cheats")
local kui_db = require("klove.kui_db")
local utf8_string = require("klove.utf8_string")
local class = require("middleclass")
local F = require("klove.font_db")
local I = require("klove.image_db")
local SU = require("screen_utils")
local E = require("entity_db")
local U = require("utils")
local V = require("klua.vector")
local P = require("path_db")
local GR = require("grid_db")
local GS = require("game_settings")
local GU = require("gui_utils")
local storage = require("storage")
local km = require("klua.macros")
local A = require("klove.animation_db")
local signal = require("hump.signal")
local G = love.graphics
local gui_visible = true

require("constants")

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

local function queue_damage(store, damage)
	table.insert(store.damage_queue, damage)
end

local function fts(v)
	return v / FPS
end

local function v(v1, v2)
	return {
		x = v1,
		y = v2
	}
end

local cheat_view = {}

cheat_view.views = {}

function cheat_view:init()
	require("game_editor_classes")

	local tt = kui_db:get_table("game_gui_cheats")
	local view = KView:new_from_table(tt.main_ui)

	self.view = view

	if not game.dbg_active_pi then
		game.dbg_active_pi = 1
	end

	if not game.dbg_use_random_subpath then
		game.dbg_use_random_subpath = true
	end

	if not game.DBG_TIME_MULT then
		game.DBG_TIME_MULT = 1
	end

	if not game.dbg_enemies_page then
		game.dbg_enemies_page = 1
	end

	view:ci("close").on_click = function(this)
		view.hidden = true
	end
	view:ci("cheat_gold_button").on_click = function(this)
		game.store.player_gold = game.store.player_gold + 1000
	end
	view:ci("cheat_lives_button").on_click = function(this)
		game.store.lives = 999
	end
	view:ci("cheat_skip_wave_button").on_click = function(this)
		game.store.force_next_wave = true
	end
	view:ci("cheat_kill_button").on_click = function(this)
		if game.game_gui and game.game_gui.selected_entity then
			local e = game.game_gui.selected_entity
			local damage = E:create_entity("damage")

			damage.value = e.health.hp
			damage.target_id = e.id
			damage.damage_type = DAMAGE_TRUE

			table.insert(game.store.damage_queue, damage)
		end
	end
	view:ci("cheat_damage_button").on_click = function(this)
		if game.game_gui and game.game_gui.selected_entity then
			local e = game.game_gui.selected_entity
			local damage = E:create_entity("damage")

			damage.value = math.floor(0.9 * e.health.hp - 1)
			damage.target_id = e.id

			table.insert(game.store.damage_queue, damage)
		end
	end
	view:ci("cheat_hide_ui_button").on_click = function(this)
		if gui_visible then
			signal.emit("hide-gui", true)
			signal.emit("tutorial-resume-input")
		else
			signal.emit("show-gui")
		end

		gui_visible = not gui_visible
	end
	view:ci("cheat_safe_area").on_click = function(this)
		if game.game_gui then
			game.game_gui.window:ci("safe_area").hidden = not game.game_gui.window:ci("safe_area").hidden
		end
	end
	view:ci("cheat_change_fps_ui_button"):ci("label").text = game.limit_fps .. "fps"
	view:ci("cheat_change_fps_ui_button").on_click = function(this)
		if game.limit_fps == 30 then
			game.force_change_fps = 60
			this:ci("label").text = "60fps"

			log.info("new 60fps")
		else
			game.force_change_fps = 30
			this:ci("label").text = "30fps"

			log.info("new 30fps")
		end
	end
	view:ci("cheat_stop_auto_play").on_click = function(this)
		for k, v in pairs(game.store.entities) do
			if v.auto_player then
				queue_remove(game.store, v)
			end
		end
	end
	view:ci("cheat_win_button").on_click = function(this)
		local outcome = {
			lives_left = 10,
			victory = true,
			stars = game.store.level_mode == 1 and 3 or 1,
			level_idx = game.store.level_idx,
			level_mode = game.store.level_mode,
			level_difficulty = game.store.level_difficulty
		}

		game.store.game_outcome = outcome

		signal.emit("game-victory", game.store)
		signal.emit("game-victory-after", game.store)

		return true
	end
	view:ci("cheat_auto_play").on_click = function(this)
		local auto_player = E:create_entity("tool_auto_player")

		queue_insert(game.store, auto_player)

		return true
	end
	view:ci("cheat_speed").on_click = function(this)
		local time_view = cheat_view.time_cheat_view

		if time_view then
			time_view.parent:remove_child(time_view)
			table.remove(cheat_view.views, table.find(cheat_view.views, time_view))

			cheat_view.time_cheat_view = nil

			return true
		end

		game.DBG_TIME_MULT = 1
		time_view = KView:new_from_table(tt.time_control_ui)

		view.parent:add_child(time_view)
		table.insert(cheat_view.views, time_view)

		cheat_view.time_cheat_view = time_view

		local time_label = time_view:ci("time-label"):ci("text")
		local step_button = time_view:ci("step")

		step_button.colors.background = game.store.paused and step_button.color_enabled or step_button.color_disabled

		local function update_dbg_time_mult(factor)
			if factor == 0 then
				game.DBG_TIME_MULT = 1
				time_label.text = "x1"
				game.store.paused = false
				step_button.colors.background = step_button.color_disabled
			else
				game.DBG_TIME_MULT = km.clamp(0, 64, game.DBG_TIME_MULT * factor)
				time_label.text = "x" .. tostring(game.DBG_TIME_MULT)
			end
		end

		function time_label.on_click(this)
			update_dbg_time_mult(0)

			return true
		end

		time_view:ci("time-1").on_click = function(this)
			update_dbg_time_mult(0.5)

			return true
		end
		time_view:ci("time+1").on_click = function(this)
			update_dbg_time_mult(2)

			return true
		end

		function step_button.on_click(this)
			game.store.paused = true
			game.store.step = true
			this.colors.background = this.color_enabled

			return true
		end

		return true
	end
	view:ci("cheat_unlock_towers").on_click = function(this)
		DEBUG_UNLOCK_ALL_TOWERS = not DEBUG_UNLOCK_ALL_TOWERS

		return true
	end

	do
		local cheat_dump_entities = view:ci("cheat_dump_entities")

		if DEBUG then
			function cheat_dump_entities.on_click(this)
				local t = {}

				for key, entity in pairs(game.store.entities) do
					table.insert(t, "Entity (" .. entity.id .. ") - " .. entity.template_name)
					pcall(function()
						local dump = getfulldump(entity)

						table.insert(t, dump)
					end)
				end

				local fulldump = table.concat(t, "\n")

				love.system.setClipboardText(fulldump)

				return true
			end
		else
			cheat_dump_entities.hidden = true
		end
	end

	local function update_enemies_bar(page_number)
		if page_number == 1 then
			for i = 1, 5 do
				local enemies_bar = view:ci("cheat_view_enemies_" .. i)
				local enemy_button_template = table.deepclone(tt.enemy_button)
				local enemy_names = require("data.game_debug_data").enemy_pages[i]
				enemies_bar:remove_children()
		
				for index, template_name in ipairs(enemy_names) do
					local enemy = E:get_template(template_name)
					local button = KView:new_from_table(enemy_button_template)
		
					button:ci("enemy_image"):set_image(enemy.info.portrait)
		
					function button.on_click(this)
						log.info("Spawning bichito %s on path %i", template_name, game.dbg_active_pi)
		
						local e = E:create_entity(template_name)
		
						if e and e.enemy then
							e.enemy.wave_group_idx = km.clamp(1, 99999, game.store.wave_group_number)
							e.nav_path.pi = game.dbg_active_pi
							e.nav_path.spi = game.dbg_use_random_subpath and math.random(1, 3) or 1
							e.nav_path.ni = P:get_start_node(game.dbg_active_pi)
		
							game.simulation:queue_insert_entity(e)
						end
					end
		
					enemies_bar:add_child(button)
				end
		
				enemies_bar:update_layout()
			end

			local enemy_button_template = table.deepclone(tt.enemy_button)
			local enemies_bar = view:ci("cheat_view_enemies_4")
			local enemy_names = require("data.game_debug_data").enemy_pages[6]
	
			for i = 1, #enemy_names do
				local template_name = enemy_names[i]
				local enemy = E:get_template(template_name)
				local button = KView:new_from_table(enemy_button_template)
	
				button:ci("enemy_image"):set_image(enemy.info.portrait)
	
				function button.on_click(this)
					log.info("Spawning bichito %s on path %i", template_name, game.dbg_active_pi)
	
					local e = E:create_entity(template_name)
	
					if e and e.enemy then
						e.enemy.wave_group_idx = km.clamp(1, 99999, game.store.wave_group_number)
						e.nav_path.pi = game.dbg_active_pi
						e.nav_path.spi = game.dbg_use_random_subpath and math.random(1, 3) or 1
						e.nav_path.ni = P:get_start_node(game.dbg_active_pi)
	
						game.simulation:queue_insert_entity(e)
					end
				end
	
				enemies_bar:add_child(button)
			end
	
			enemies_bar:update_layout()
	
			enemies_bar = view:ci("cheat_view_enemies_2")
			enemy_names = require("data.game_debug_data").enemy_pages[7]
	
			for i = 1, #enemy_names do
				local template_name = enemy_names[i]
				local enemy = E:get_template(template_name)
				local button = KView:new_from_table(enemy_button_template)
	
				button:ci("enemy_image"):set_image(enemy.info.portrait)
	
				function button.on_click(this)
					log.info("Spawning bichito %s on path %i", template_name, game.dbg_active_pi)
	
					local e = E:create_entity(template_name)
	
					if e and e.enemy then
						e.enemy.wave_group_idx = km.clamp(1, 99999, game.store.wave_group_number)
						e.nav_path.pi = game.dbg_active_pi
						e.nav_path.spi = game.dbg_use_random_subpath and math.random(1, 3) or 1
						e.nav_path.ni = P:get_start_node(game.dbg_active_pi)
	
						game.simulation:queue_insert_entity(e)
					end
				end
	
				enemies_bar:add_child(button)
			end
	
			enemies_bar:update_layout()
	
			enemies_bar = view:ci("cheat_view_enemies_6")
			enemy_names = require("data.game_debug_data").enemy_pages[8]
	
			for i = 1, #enemy_names do
				local template_name = enemy_names[i]
				local enemy = E:get_template(template_name)
				local button = KView:new_from_table(enemy_button_template)
	
				button:ci("enemy_image"):set_image(enemy.info.portrait)
	
				function button.on_click(this)
					log.info("Spawning bichito %s on path %i", template_name, game.dbg_active_pi)
	
					local e = E:create_entity(template_name)
	
					if e and e.enemy then
						e.enemy.wave_group_idx = km.clamp(1, 99999, game.store.wave_group_number)
						e.nav_path.pi = game.dbg_active_pi
						e.nav_path.spi = game.dbg_use_random_subpath and math.random(1, 3) or 1
						e.nav_path.ni = P:get_start_node(game.dbg_active_pi)
	
						game.simulation:queue_insert_entity(e)
					end
				end
	
				enemies_bar:add_child(button)
			end
	
			enemies_bar:update_layout()
		elseif page_number == 2 then
			local data = require("data.game_debug_data")
			for i = 1, 6 do
				local enemies_bar = view:ci("cheat_view_enemies_" .. i)
				local enemy_button_template = table.deepclone(tt.enemy_button)
				enemies_bar:remove_children()
				if i <= 3 then
					local enemy_names = data.enemy_pages[i + 8]
					for index, template_name in ipairs(enemy_names) do
						local enemy = E:get_template(template_name)
						local button = KView:new_from_table(enemy_button_template)
						button:ci("enemy_image"):set_image(enemy.info.portrait)
			
						function button.on_click(this)
							log.info("Spawning bichito %s on path %i", template_name, game.dbg_active_pi)
							local e = E:create_entity(template_name)
							if e and e.enemy then
								e.enemy.wave_group_idx = km.clamp(1, 99999, game.store.wave_group_number)
								e.nav_path.pi = game.dbg_active_pi
								e.nav_path.spi = game.dbg_use_random_subpath and math.random(1, 3) or 1
								e.nav_path.ni = P:get_start_node(game.dbg_active_pi)
								game.simulation:queue_insert_entity(e)
							end
						end
						enemies_bar:add_child(button)
					end
					enemies_bar:update_layout()
				end
			end
		end
	end
	update_enemies_bar(game.dbg_enemies_page)

	do
		local paths_bar = view:ci("cheat_view_paths")
		local paths_button_template = table.deepclone(tt.path_button)

		for pi, path in ipairs(P.paths) do
			local button = KView:new_from_table(paths_button_template)

			button:ci("path_number").text = tostring(pi)
			button.default_background = button.colors.background

			function button.on_click(this)
				if this.selected then
					log.info("Deselecting path  %i", pi)

					game.DBG_DRAW_PATHS = nil
					button.colors.background = button.default_background
					this.selected = nil
				else
					log.info("Selecting path  %i", pi)

					for _, otherbutton in ipairs(paths_bar.children) do
						otherbutton.colors.background = otherbutton.default_background
						otherbutton.selected = nil
					end

					button.colors.background = button.selected_color
					game.DBG_DRAW_PATHS = 1
					game.dbg_active_pi = pi
					game.path_canvas = nil
					this.selected = true
				end
			end

			paths_bar:add_child(button)
		end

		paths_bar:update_layout()
	end

	local cheat_preview_animation_button = view:ci("cheat_preview_animations_button")

	function cheat_preview_animation_button.on_click(this)
		local animation_view = KView:new_from_table(tt.animation_view)

		view.parent:add_child(animation_view)

		view.hidden = true

		table.insert(cheat_view.views, animation_view)

		animation_view:ci("animation_view_search_button").on_click = function(this)
			local list = animation_view:ci("animation_view_list")
			local str = love.system.getClipboardText()

			log.info("Searching for animations: %s", str)

			if str and string.len(str) >= 3 then
				local results = {}

				for k, _ in pairs(require("klove.animation_db").db) do
					if string.match(k, str) then
						table.insert(results, k)
					end
				end

				list:clear_rows()

				for i = 1, 10 do
					local tn = results[i]

					if not tn then
						break
					end

					local l = GGLabel:new(V.v(list.size.x - 20, 20))

					l.font_name = "DroidSansMono"
					l.font_size = 8
					l.text_align = "left"
					l.text = tn
					l.fit_lines = 1

					function l.on_click()
						function DEBUG_RIGHT_CLICK(wx, wy)
							local animation_to_use = tn

							log.error("Spawning animation (%s): %s,%s", animation_to_use, wx, wy)

							local E = require("entity_db")
							local e = E:create_entity("fx")

							e.render.sprites[1].name = animation_to_use
							e.render.sprites[1].ts = game.store.tick_ts
							e.pos = {
								x = wx,
								y = wy
							}

							game.simulation:queue_insert_entity(e)
						end

						for index, value in ipairs(list.children) do
							log.info("Checking label %s == %s", tn, value.text)

							value.colors.background = {
								255,
								255,
								255,
								value.text == tn and 255 or 0
							}
						end
					end

					list:add_row(l)
				end
			end
		end
	end

	cheat_preview_animation_button.hidden = nil

	do
		local text_button_template = table.deepclone(tt.text_button)
		local button_bar = view:ci("cheat_view_custom")

		for index, e in E:filter_iter(game.store.entities, "cheats") do
			if e.cheats.buttons then
				for _, button_data in ipairs(e.cheats.buttons) do
					local button = KView:new_from_table(text_button_template)

					button:ci("text").text = tostring(button_data.text)

					function button.on_click(this)
						button_data.fn(this, game.store, e)
					end

					button_bar:add_child(button)
				end
			end
		end

		button_bar:update_layout()
	end

	do
		local pages = { "P1", "P2" }
		local pages_bar = view:ci("cheat_view_pages")
		local pages_button_template = table.deepclone(tt.text_button)

		for i, group in ipairs(pages) do
			local button = KView:new_from_table(pages_button_template)
			button:ci("text").text = tostring(group)
			button.default_background = button.colors.background
			button.page_number = i

			function button.on_click(this)
				if not pages_bar.selected_page or pages_bar.selected_page ~= this.page_number then
					game.dbg_enemies_page = this.page_number
					update_enemies_bar(game.dbg_enemies_page)
					for _, btn in ipairs(pages_bar.children) do
						btn.colors.background = btn.default_background
					end
					this.colors.background = this.selected_color
				end
			end
			pages_bar:add_child(button)
		end
		pages_bar:update_layout()
		for _, btn in ipairs(pages_bar.children) do
			if btn.page_number == game.dbg_enemies_page then
				btn.colors.background = btn.selected_color
			end
		end
	end

	table.insert(cheat_view.views, view)

	return view
end

return cheat_view
