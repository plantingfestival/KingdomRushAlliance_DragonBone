-- chunkname: @./sequels/tutorial_utils.lua

local signal = require("hump.signal")
local P = require("path_db")
local V = require("klua.vector")
local E = require("entity_db")
local LU = require("level_utils")
local TU = {}
local zoom_in_depth = KR_TARGET == "phone" and 1.75 or 1.25

local function pan_zoom(duration, x, y, ox, oy, zoom)
	signal.emit("pan-zoom-camera", duration, V.v(x + ox, y + oy), zoom)
end

local function focus_circle(x, y)
	signal.emit("show-focus-circle-xy", x, y)
end

local function get_holder_by_id(store, id)
	return table.filter(store.entities, function(_, v)
		return v.tower and v.tower.holder_id == id
	end)[1]
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

		e._frozen = true
	end
end

local function unfreeze_enemies()
	local enemies = table.filter(game.store.entities, function(k, v)
		return v.enemy and v._frozen
	end)

	if not enemies then
		return
	end

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

TU.find_functions = {}

local function process_find_params(params)
	table.remove(params, #params)

	for i = #params, 1, -1 do
		if params[i] == "" then
			table.remove(params, i)
		end
	end

	local fn = TU.find_functions[params[1]]

	if not fn then
		log.error("that function find name doesnt exist, did you write it wrong?")

		return V.v(0, 0), params
	end

	local pos = fn(select(2, unpack(params)))

	if string.find(params[1], "_with_id") then
		table.remove(params, 2)
	end

	return pos, params
end

function TU.find_functions.first_dead_enemy(...)
	return table.filter(game.store.entities, function(_, v)
		return v.enemy and v.health and v.health.dead
	end)[1].pos
end

function TU.find_functions.next_wave_with_id(path, ...)
	path = tonumber(path)

	local p = P:node_pos(path, 1, 1)

	return p
end

function TU.find_functions.flags_with_id(path, ...)
	path = tonumber(path)

	local ng = P:nodes_to_goal(path, 1, 1)

	return P:node_pos(path, 1, ng + 1)
end

function TU.find_functions.stage(...)
	return V.v(580, 450)
end

function TU.find_functions.holder_with_id(holder_id, ...)
	return get_holder_by_id(game.store, holder_id).pos
end

TU.signal_handlers = {
	["tutorial-pan-zoom-center-find"] = function(...)
		local function override_zoom(v, def)
			return v == 0 and def or v
		end

		local params = {
			...
		}
		local pos

		pos, params = process_find_params(params)

		if not params[2] then
			log.error("missing zoom parameter for centering camera.")

			return
		end

		local time = tonumber(params[2])
		local ox = (not params[3] or params[3] == "") and 0 or tonumber(params[3])
		local oy = (not params[4] or params[4] == "") and 0 or tonumber(params[4])
		local ov_zoom = (not params[5] or params[5] == "") and 0 or tonumber(params[5])

		pan_zoom(time, pos.x, pos.y, ox, oy, override_zoom(ov_zoom, zoom_in_depth))
	end,
	["tutorial-show-balloon-find"] = function(...)
		local params = {
			...
		}
		local pos

		pos, params = process_find_params(params)

		local key = params[2]

		if not key then
			log.error("need a key to show balloon.")

			return
		end

		local ox = (not params[3] or params[3] == "") and 0 or tonumber(params[3])
		local oy = (not params[4] or params[4] == "") and 0 or tonumber(params[4])

		signal.emit("show-balloon_tutorial-pos", key, false, V.v(pos.x + ox, pos.y + oy))
	end,
	["tutorial-show-balloon-xy"] = function(key, sx, sy)
		local x, y = tonumber(sx), tonumber(sy)

		signal.emit("show-balloon_tutorial-pos", key, false, V.v(x, y))
	end,
	["tutorial-hide-balloon"] = function(key)
		signal.emit("hide-balloon-tutorial", key)
	end,
	["tutorial-show-focus-circle-find"] = function(...)
		local params = {
			...
		}
		local pos

		pos, params = process_find_params(params)

		local ox = (not params[2] or params[2] == "") and 0 or tonumber(params[2])
		local oy = (not params[3] or params[3] == "") and 0 or tonumber(params[3])

		focus_circle(pos.x + ox, pos.y + oy)
	end,
	["tutorial-freeze-enemies"] = function()
		freeze_enemies(game.store)
	end,
	["tutorial-unfreeze-enemies"] = function()
		unfreeze_enemies()
	end,
	["tutorial-highlight-entity-find"] = function(...)
		local params = {
			...
		}
		local pos

		pos, params = process_find_params(params)

		local ox = (not params[2] or params[2] == "") and 0 or tonumber(params[2])
		local oy = (not params[3] or params[3] == "") and 0 or tonumber(params[3])

		if params[1] == "first_dead_enemy" then
			local enemy_decal = E:create_entity("stage_01_dead_enemy_indicator")

			enemy_decal.pos = V.v(pos.x + ox, pos.y + oy)
			enemy_decal.tween.ts = game.store.tick_ts

			LU.queue_insert(game.store, enemy_decal)
		elseif params[1] == "all_flags" then
			local flags = table.filter(game.store.entities, function(k, e)
				return e.template_name == "decal_defense_flag5"
			end)

			for _, value in pairs(flags) do
				local flag_decal = E:create_entity("stage_01_dead_enemy_indicator")

				flag_decal.pos = V.v(value.pos.x + ox, value.pos.y + oy)
				flag_decal.tween.ts = game.store.tick_ts

				LU.queue_insert(game.store, flag_decal)
			end
		end
	end,
	["tutorial-send-next-wave"] = function(walk_x, walk_y)
		game.store.send_next_wave = true
	end,
	["tutorial-stop-wave-spawn"] = function(walk_x, walk_y)
		game.store.send_next_wave = false
	end
}

function TU:register_signals()
	for sn, fn in pairs(self.signal_handlers) do
		signal.register(sn, fn)
	end
end

function TU:unregister_signals()
	for sn, fn in pairs(self.signal_handlers) do
		signal.remove(sn, fn)
	end

	TU.signal_handlers = {}
end

return TU
