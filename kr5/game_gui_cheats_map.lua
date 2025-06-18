-- chunkname: @./kr5/game_gui_cheats_map.lua

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

	local tt = kui_db:get_table("game_gui_cheats_map")
	local view = KView:new_from_table(tt.main_ui)

	self.view = view

	local margin_x = 16
	local button_x = 48
	local between_buttons = 10

	self.view.size.x = margin_x * 2 + button_x * 3 + between_buttons * 2
	view:ci("close").on_click = function(this)
		view.hidden = true
	end
	view:ci("unlock_all").on_click = function(this)
		local user_data = storage:load_slot()

		for k, v in pairs(user_data.items) do
			if k ~= "selected" then
				user_data.items.status[k] = 99
			end
		end

		user_data.levels = {}

		for i = 1, GS.last_level do
			table.insert(user_data.levels, {
				2,
				2,
				2,
				stars = 3
			})
		end

		user_data.last_victory = {
			level_difficulty = 1,
			level_mode = 1,
			stars = 3,
			level_idx = GS.last_level
		}

		if #user_data.towers.selected < 4 then
			table.insert(user_data.towers.selected, "tricannon")
		end

		if #user_data.towers.selected < 5 then
			table.insert(user_data.towers.selected, "ballista")
		end

		storage:save_slot(user_data)
		screen_map.done_callback({
			next_item_name = "map"
		})
	end
	view:ci("next_level").on_click = function(this)
		local user_data = storage:load_slot()
		local last_level_won = 0

		for i, v in ipairs(user_data.levels) do
			if v.stars ~= nil then
				last_level_won = i
			else
				break
			end
		end

		if last_level_won < GS.last_level and user_data.levels[last_level_won + 1] then
			user_data.levels[last_level_won + 1] = {
				2,
				2,
				2,
				stars = 3
			}
			user_data.last_victory = {
				level_difficulty = 1,
				level_mode = 1,
				stars = 3,
				level_idx = last_level_won + 1
			}
		end

		storage:save_slot(user_data)
		screen_map.done_callback({
			next_item_name = "map"
		})
	end

	if love.system.getOS() == "Android" then
		view:ci("consume_iaps").on_click = function(this)
			if love.system.getOS() == "Android" then
				local jnia = require("all.jni_android")
				local last_purchase = jnia.get_cached_purchases(2)
				local PS = require("platform_services")
				local purchases = PS.services.iap:parse_purchases(last_purchase)

				for i, v in ipairs(purchases) do
					jnia.create_request_consume_product(2, v.token)
				end

				screen_map.done_callback({
					next_item_name = "map"
				})
			end
		end
	else
		view:ci("consume_iaps").hidden = true
	end

	table.insert(cheat_view.views, view)

	return view
end

return cheat_view
