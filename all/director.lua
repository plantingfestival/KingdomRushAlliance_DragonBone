-- chunkname: @./all/director.lua

local log = require("klua.log"):new("director")
local km = require("klua.macros")
local signal = require("hump.signal")

require("klua.dump")

local features = require("features")
local i18n = require("i18n")
local V = require("klua.vector")
local I = require("klove.image_db")
local F = require("klove.font_db")
local SH = require("klove.shader_db")
local KDB = require("klove.kui_db")
local S = require("sound_db")
local G = love.graphics
local AC = require("achievements")
local LU = require("level_utils")
local RC = require("remote_config")
local ISM = require("klove.input_state_machine")
local marketing = require("marketing")
local PP = require("privacy_policy_consent")
local storage = require("storage")
local services = require("platform_services")
local director_data = require("data.director_data")

local function replace_locale(list, locale)
	local out = {}

	for _, v in pairs(list) do
		local ns = string.gsub(v, "LOCALE", locale or i18n.current_locale)

		table.insert(out, ns)
	end

	return out
end

director = {}
director.item_props = director_data.item_props

function director:init(params)
	self.postponed_unloads = {}

	local global = storage:load_global()

	if not global.launch_count then
		global.launch_count = 1
	else
		global.launch_count = global.launch_count + 1
	end

	log.debug("Launch count: %s", global.launch_count)
	storage:save_global(global)

	local kdb_path

	if IS_TRILOGY then
		kdb_path = KR_PATH_GAME_TARGET .. "/data/kui_templates" .. ";" .. KR_PATH_ALL_TARGET .. "/data/kui_templates"
	else
		kdb_path = KR_PATH_GAME_TARGET .. "/data/kui_templates" .. ";" .. KR_PATH_GAME .. "/data/kui_templates" .. ";" .. KR_PATH_ALL_TARGET .. "/data/kui_templates" .. ";" .. KR_PATH_ALL .. "/data/kui_templates"
	end

	KDB:init(kdb_path, DEBUG)
	SH:init(KR_PATH_ASSETS_ALL_TARGET .. "/shaders", true)

	local sound_paths = KR_PATH_ASSETS_GAME_FALLBACK or {
		{
			path = KR_PATH_ASSETS_GAME_TARGET
		}
	}

	for _, v in pairs(sound_paths) do
		local p = v.path .. "/sounds"

		if love.filesystem.exists(p .. "/sounds.lua") then
			S:init(p)

			break
		end
	end

	I.use_canvas = params.image_db_uses_canvas
	I.release_compressed_data = params.image_db_releases_compressed_data

	RC:init()
	AC:init()

	if (KR_TARGET == "phone" or KR_TARGET == "tablet") and KR_PLATFORM == "ios" then
		storage:import_plist("NSUserDefaults")
	end

	services:init(true)
	PP:init()

	if PP:has_consent() and not features.delay_services_init then
		services:init()
		marketing:init()
	end

	self.params = params

	self:reset_screen_params()

	if params.locale then
		main:set_locale(params.locale)
		love.window.setTitle(_("GAME_TITLE_" .. string.upper(KR_GAME)))
	end

	if features.overrides and (table.contains(features.overrides, "censored_cn") or table.contains(features.overrides, "yodo1sdk")) then
		BLOOD_RED = BLOOD_GRAY
	end

	if KR_TARGET == "phone" and KR_PLATFORM == "android" then
		local filename = "/data/data/" .. version.bundle_id .. "/files/.Defaults.plist"

		storage:import_plist(filename)
	elseif KR_TARGET == "desktop" and KR_GAME == "kr1" and services.services then
		local dir

		if services.services.steam then
			dir = services.services.steam:get_install_dir()
		elseif services.services.gamecenter then
			dir = services.services.gamecenter:get_install_dir()
		elseif services.services.kart then
			dir = services.services.kart:get_install_dir()
		end

		if not dir then
			log.error("Could not find original install dir. Skipping savegame import")
		else
			storage:import_dotnet(dir)
		end
	end

	self.next_item_name = "splash"

	if params.level or params.screen or params.challenge then
		if not storage:load_slot(1) then
			storage:create_slot(1)
		end

		storage:set_active_slot(1)

		if params.screen then
			self.next_item_name = params.screen
			self.next_item_args = {
				custom = params.custom,
				texture_size = params.texture_size
			}
		elseif params.level then
			self.next_item_name = "game"
			self.next_item_args = {
				level_idx = tonumber(params.level),
				level_mode = params.mode and tonumber(params.mode) or GAME_MODE_CAMPAIGN,
				level_difficulty = params.diff and tonumber(params.diff) or DIFFICULTY_NORMAL
			}
		elseif params.challenge then
			local ch_id = params.challenge

			if not RC.v.challenges then
				log.error("challenges are not defined")
			end

			local found = false

			for _, c in pairs(RC.v.challenges) do
				if c.id == ch_id then
					local ch = RC.v.challenges[ch_id]

					self.next_item_name = "game"
					self.next_item_args = {
						level_idx = c.level_idx,
						level_mode = c.game_mode,
						level_challenge = c,
						level_difficulty = c.difficulty
					}
					found = true
				end
			end

			if not found then
				log.error("could not find challenge definition for %s", ch_id)
				love.event.quit()
			end
		end
	end

	if KR_TARGET == "desktop" and KR_PLATFORM ~= "uwp" then
		if params.screen == "game_editor" then
			local c = love.mouse.newCursor(KR_PATH_ASSETS_ALL_TARGET .. "/cursors/crosshair.png", 16, 16)

			love.mouse.setCursor(c)
		else
			local cursor_name = "hand_32"

			if params.large_pointer then
				cursor_name = params.height < 1080 and "hand_48" or "hand_64"
			end

			if IS_TRILOGY then
				self.cursor_up = love.mouse.newCursor(string.format(KR_PATH_ASSETS_ALL_TARGET .. "/cursors/%s_0001.png", cursor_name), 3, 2)
				self.cursor_down = love.mouse.newCursor(string.format(KR_PATH_ASSETS_ALL_TARGET .. "/cursors/%s_0002.png", cursor_name), 3, 2)
			else
				self.cursor_up = love.mouse.newCursor(string.format(KR_PATH_ASSETS_GAME_TARGET .. "/cursors/pointer_%s_0001.png", cursor_name), 3, 2)
				self.cursor_down = love.mouse.newCursor(string.format(KR_PATH_ASSETS_GAME_TARGET .. "/cursors/pointer_%s_0002.png", cursor_name), 3, 2)
			end

			love.mouse.setCursor(self.cursor_up)
		end
	end
end

function director:on_quit()
	log.debug("quitting...")
	signal.emit("quit")
	services:shutdown()

	return false
end

function director:get_texture_scale(item_name, ref_res, forced_texture_size)
	local tsize = string.split(self.params.texture_size, "_")[1]
	local ftsize = forced_texture_size and string.split(forced_texture_size, "_")[1] or nil
	local scale = ref_res / TEXTURE_SIZE_ALIAS[ftsize or tsize]
	local factors = TEXTURE_SIZE_FACTOR[ftsize or tsize]

	if factors and factors[item_name] then
		scale = scale / factors[item_name]
	end

	log.debug("item:%s ref_res:%s texture_size:%s forced_texture_size:%s-> scale:%s", item_name, ref_res, self.params.texture_size, forced_texture_size, scale)

	return scale
end

function director:get_comic_data_file(comic_idx)
	local suffix = string.format("/data/comics/%02i.csv", comic_idx)
	local file = KR_PATH_GAME_TARGET .. suffix

	if not love.filesystem.isFile(file) then
		file = KR_PATH_GAME .. suffix
	end

	return file
end

function director:reset_screen_params(force_scissor)
	local params = self.params
	local aw, ah = love.graphics.getDimensions()

	params.width, params.height = aw, ah

	local screen_aspect = params.width / params.height
	local max_aspect = MAX_SCREEN_ASPECT
	local min_aspect = MIN_SCREEN_ASPECT

	if screen_aspect < min_aspect then
		self.scissor_w = params.width
		self.scissor_h = params.width / min_aspect
		self.scissor_x = 0
		self.scissor_y = (params.height - self.scissor_h) / 2
		self.scissor_enabled = true
	elseif max_aspect < screen_aspect then
		self.scissor_w = params.height * max_aspect
		self.scissor_h = params.height
		self.scissor_x = (params.width - self.scissor_w) / 2
		self.scissor_y = 0
		self.scissor_enabled = true
	else
		self.scissor_enabled = false
	end

	if force_scissor ~= nil then
		log.info("forcing scissor value to %s", force_scissor)

		self.scissor_enabled = force_scissor
	end

	log.info("resetting screen params. w,h:%s,%s scissor:%s %s,%s,%s,%s", aw, ah, self.scissor_enabled, self.scissor_x, self.scissor_y, self.scissor_w, self.scissor_h)
end

function director:item_done_callback(item_name, outcome)
	if self.active_item and self.active_item.done_callback_called then
		log.error("  Done callback already called... Ignoring!")

		return
	end

	self.active_item.done_callback_called = true

	if self.active_item then
		local w = self.active_item.game_gui and self.active_item.game_gui.window or self.active_item.window

		if w then
			log.debug("disabling events for item:%s window:%s", self.active_item.item_name, w)
			w:disable(false)

			if ISM then
				ISM:destroy(w)
			end
		end
	end

	log.debug("DONE CALLBACK FROM %s with outcome %s", item_name, getdump(outcome))

	if outcome then
		if outcome.quit then
			love.event.quit()

			return
		elseif outcome.next_item_name then
			self.next_item_name = outcome.next_item_name
			self.next_item_args = outcome

			return
		elseif outcome.prevent_loading then
			self.next_item_prevent_loading = true
		end

		if outcome.privacy_policy_accepted then
			PP:give_consent_with_age(outcome.birth_month, outcome.birth_year)
			services:init()
			marketing:init()
		end

		if outcome.simple_privacy_policy_accepted then
			local global = storage:load_global()

			global.simple_privacy_policy_accepted = true

			storage:save_global(global)
		end

		if outcome.splash_done and features.delay_services_init and not features.requires_privacy_policy then
			services:init()
			marketing:init()
		end
	end

	if item_name == "comics" then
		self.queued_item = self.active_item.game_item

		return
	end

	local props = self.item_props[item_name]

	::label_7_0::

	if props.next then
		local props_next = self.item_props[props.next]

		if props_next and props_next.skip_check and director.skip_checks[props_next.skip_check] and director.skip_checks[props_next.skip_check]() then
			log.debug("skipping screen %s. %s passed", props.next, props_next.skip_check)

			props = props_next

			goto label_7_0
		end

		self.next_item_name = props.next
		self.next_item_args = {}

		return
	end
end

function director:unload_item(item, postponed)
	local function unload(list)
		for _, row in pairs(list) do
			if row.type == "sound" then
				S:unload_group(row.group)
			elseif row.type == "groups" then
				self:unload_texture_groups(row.groups, row.texture_size, row.ref_res, row.item_name)
			elseif row.type == "atlas" then
				I:unload_atlas(row.atlas_name, row.scale)
			end
		end
	end

	local function postpone(list)
		if not self.pending_unloads then
			self.pending_unloads = {}
		end

		table.merge(self.pending_unloads, list)
	end

	if self.pending_unloads then
		unload(self.pending_unloads)

		self.pending_unloads = nil
	end

	if not item then
		log.debug("item nil")

		return
	end

	local list = {}

	if item.item_name == "game" then
		local game = item

		table.insert(list, {
			item_name = "game_gui",
			type = "groups",
			groups = replace_locale(game.game_gui.required_textures),
			texture_size = self.params.texture_size,
			ref_res = game.game_gui.ref_res
		})

		local groups = {}

		groups = table.append(groups, replace_locale(game.required_textures))
		groups = table.append(groups, replace_locale(game.store.level.required_textures))

		if game.store.selected_team then
			for _, hero_name in ipairs(game.store.selected_team) do
				table.insert(groups, "go_" .. hero_name)
			end
		elseif game.store.selected_hero then
			table.insert(groups, "go_" .. game.store.selected_hero)
		end

		local slot = storage:load_slot()

		if slot.towers and slot.towers.selected then
			if game.store.level.available_towers then
				for _, tower in ipairs(game.store.level.available_towers) do
					local tower_name = tower:gsub("tower_build_", "")
					local tower_texture = "go_towers_" .. tower_name

					table.insert(groups, tower_texture)
				end
			else
				for _, tower in ipairs(slot.towers.selected) do
					table.insert(groups, "go_towers_" .. tower)
				end
			end
		end

		if slot.items and slot.items.selected then
			for _, item in ipairs(slot.items.selected) do
				table.insert(groups, "go_items_" .. item)
			end
		end

		table.insert(list, {
			item_name = "game",
			type = "groups",
			groups = groups,
			texture_size = self.params.texture_size,
			ref_res = game.ref_res
		})
		table.insert(list, {
			atlas_name = "temp_game_texts",
			type = "atlas",
			scale = game.store.screen_scale
		})

		if item.required_sounds then
			for _, group in pairs(item.required_sounds) do
				table.insert(list, {
					type = "sound",
					group = group
				})
			end
		end

		if game.store.level.required_sounds then
			for _, group in pairs(game.store.level.required_sounds) do
				table.insert(list, {
					type = "sound",
					group = group
				})
			end
		end

		if game.store.selected_team then
			for _, hero_name in ipairs(game.store.selected_team) do
				table.insert(list, {
					type = "sound",
					group = hero_name
				})
			end
		elseif game.store.selected_hero then
			table.insert(list, {
				type = "sound",
				group = game.store.selected_hero
			})
		end

		if slot.towers and slot.towers.selected then
			for _, tower in ipairs(slot.towers.selected) do
				table.insert(list, {
					type = "sound",
					group = "tower_" .. tower
				})
			end
		end

		if slot.items and slot.items.selected then
			for _, item in ipairs(slot.items.selected) do
				table.insert(list, {
					type = "sound",
					group = "item_" .. item
				})
			end
		end

		if postponed then
			postpone(list)
		else
			unload(list)
		end

		game:destroy()

		game.store = nil
		package.loaded.exoskeleton = nil

		collectgarbage()
	elseif not item.keep_loaded then
		local textures = item.required_textures

		if textures then
			local scale = self:get_texture_scale(item.item_name, item.ref_res)

			for _, group in pairs(replace_locale(textures, item.locale_at_requirement)) do
				table.insert(list, {
					type = "atlas",
					atlas_name = group,
					scale = scale
				})
			end
		end

		if item.required_sounds then
			for _, group in pairs(item.required_sounds) do
				table.insert(list, {
					type = "sound",
					group = group
				})
			end
		end

		if postponed then
			postpone(list)
		else
			unload(list)
		end

		if item.destroy then
			item:destroy()
		end

		collectgarbage()
	end
end

function director:queue_load_item_named(name, force_reload)
	local function _require(name, force)
		if force_reload or force then
			if package.loaded[name].reload_list then
				for _, n in pairs(package.loaded[name].reload_list) do
					package.loaded[n] = nil
				end
			end

			package.loaded[name] = nil
		end

		local r = require(name)

		r.locale_at_requirement = i18n.current_locale

		return r
	end

	local props = self.item_props[name]

	self:reset_screen_params(props and props.scissor)

	if DBG_REPLACE_MISSING_TEXTURES then
		self:load_texture_groups({
			"_debug_textures"
		}, self.params.texture_size, 480, false)
	end

	local show_loading = props.show_loading

	if self.next_item_prevent_loading then
		show_loading = false
		self.next_item_prevent_loading = nil
	end

	if show_loading then
		local loading = _require("screen_loading")
		local level_idx

		if game and game.store and game.store.level_idx then
			level_idx = game.store.level_idx
		elseif self.next_item_args then
			level_idx = self.next_item_args.level_idx
		end

		if loading.update_required_textures then
			loading:update_required_textures(name, level_idx)
		end

		self:load_texture_groups(loading.required_textures, self.params.texture_size, loading.ref_res, false)

		if loading.required_sounds then
			self:load_sound_groups(loading.required_sounds)
		end

		loading:init(self.params.width, self.params.height)
		loading:close()

		self.queue_unload_item = self.active_item
		self.active_item = loading
	end

	if props.type == "screen" then
		local item = _require(props.src, self.next_item_args and self.next_item_args.force_reload)

		item.item_name = name
		item.args = self.next_item_args

		if item.required_textures then
			self:load_texture_groups(replace_locale(item.required_textures), self.params.texture_size, item.ref_res, true, name)
		end

		if item.ref_res then
			item.screen_scale = self:get_texture_scale(name, item.ref_res)
		end

		self.queued_item = item

		if item.required_sounds then
			self:load_sound_groups(item.required_sounds)
		end
	elseif props.type == "comic" then
		local args = self.next_item_args
		local comic_idx = args.custom
		local item = _require("screen_comics")

		item.item_name = "comics"
		item.required_textures = {
			"loading_common",
			"comic_" .. comic_idx
		}

		local comic_data_file = self:get_comic_data_file(comic_idx)

		item.comic_data = love.filesystem.read(comic_data_file)

		self:load_texture_groups(replace_locale(item.required_textures), self.params.texture_size, item.ref_res, true)

		self.queued_item = item
	elseif props.type == "game" then
		local game_gui = _require("game_gui")
		local game = _require("game")

		game.item_name = "game"
		game.max_fps = DRAW_FPS

		local args = self.next_item_args

		game.store = {}
		game.store.level_idx = args.level_idx
		game.store.level_name = "level" .. string.format("%02i", args.level_idx)
		game.store.level_mode = args.level_mode
		game.store.level_challenge = args.level_challenge
		game.store.level_difficulty = args.level_difficulty
		game.store.screen_scale = self:get_texture_scale("game", REF_H)
		game.store.texture_size = self.params.texture_size
		game.store.level = LU.load_level(game.store, game.store.level_name)

		self:load_texture_groups(replace_locale(game.required_textures), self.params.texture_size, game.ref_res, true, "game")
		self:load_texture_groups(replace_locale(game.store.level.required_textures), self.params.texture_size, game.ref_res, true, "game")
		self:load_texture_groups(replace_locale(game_gui.required_textures), self.params.texture_size, game_gui.ref_res, true, "game_gui")
		self:load_sound_groups(game.required_sounds)
		self:load_sound_groups(game.store.level.required_sounds)

		local slot = storage:load_slot()
		local heroes = {}

		if slot.heroes.team then
			table.append(heroes, slot.heroes.team)
		elseif slot.heroes.selected then
			if args.level_challenge and args.level_challenge.restrictions and args.level_challenge.restrictions.forced_hero then
				heroes = {
					args.level_challenge.restrictions.forced_hero
				}
			else
				table.insert(heroes, slot.heroes.selected)
			end
		end

		for _, hero in ipairs(heroes) do
			local hero_textures = {
				"go_" .. hero
			}

			self:load_texture_groups(hero_textures, self.params.texture_size, game.ref_res, true, "game")
			self:load_sound_groups({
				hero
			})
		end

		if slot.towers and slot.towers.selected then
			if game.store.level.available_towers then
				for _, tower in ipairs(game.store.level.available_towers) do
					local tower_name = tower:gsub("tower_build_", "")
					local tower_texture = {
						"go_towers_" .. tower_name
					}

					self:load_texture_groups(tower_texture, self.params.texture_size, game.ref_res, true, "game")
					self:load_sound_groups({
						"tower_" .. tower_name
					})
				end
			else
				for _, tower in ipairs(slot.towers.selected) do
					local tower_texture = {
						"go_towers_" .. tower
					}

					self:load_texture_groups(tower_texture, self.params.texture_size, game.ref_res, true, "game")
					self:load_sound_groups({
						"tower_" .. tower
					})
				end
			end
		end

		if slot.items and slot.items.selected then
			for _, item in ipairs(slot.items.selected) do
				local item_texture = {
					"go_items_" .. item
				}

				self:load_texture_groups(item_texture, self.params.texture_size, game.ref_res, true, "game")
				self:load_sound_groups({
					"item_" .. item
				})
			end
		end

		if game.store.level.show_comic_idx and game.store.level_mode == GAME_MODE_CAMPAIGN and not args.level_challenge then
			local comic_idx = game.store.level.show_comic_idx
			local item = _require("screen_comics")

			item.item_name = "comics"
			item.required_textures = {
				"comic_" .. comic_idx
			}
			item.level_idx = game.store.level_idx

			local comic_data_file = self:get_comic_data_file(comic_idx)

			item.comic_data = love.filesystem.read(comic_data_file)

			self:load_texture_groups(replace_locale(item.required_textures), self.params.texture_size, item.ref_res, true, "comic")

			self.queued_item = item
			item.game_item = game
		else
			self.queued_item = game
		end
	end

	log.debug("queued item: %s", self.queued_item.item_name)
end

function director:unload_texture_groups(groups, texture_size, ref_height, item_name)
	local forced_texture_size

	for _, group in pairs(groups) do
		if KR_PATH_ASSETS_GAME_FALLBACK then
			local texture_path = KR_PATH_ASSETS_GAME_TARGET .. "/images/" .. texture_size

			if love.filesystem.exists(texture_path .. "/" .. group .. ".lua") then
				-- block empty
			else
				for _, v in pairs(KR_PATH_ASSETS_GAME_FALLBACK) do
					texture_path = v.path .. "/images/" .. v.texture_size

					if love.filesystem.exists(texture_path .. "/" .. group .. ".lua") then
						log.debug(" --- texture group %s fallback to %s", group, texture_path)

						forced_texture_size = v.texture_size

						break
					end
				end
			end
		end

		local scale = 1

		if ref_height then
			scale = self:get_texture_scale(item_name, ref_height, forced_texture_size)
		end

		I:unload_atlas(group, scale)
	end
end

function director:load_texture_groups(groups, texture_size, ref_height, queue, item_name)
	local function override_ov(texture_path, group)
		if features.overrides then
			for _, n in pairs(features.overrides) do
				local ov_path = texture_path .. "/_ov/" .. n

				if love.filesystem.exists(ov_path .. "/" .. group .. ".lua") then
					log.debug("  +++ texture group %s overriden by %s", group, n)

					texture_path = ov_path
				end
			end
		end

		return texture_path
	end

	local scale = 1

	for _, group in pairs(groups) do
		local texture_path, forced_texture_size

		if KR_PATH_ASSETS_GAME_FALLBACK then
			texture_path = KR_PATH_ASSETS_GAME_TARGET .. "/images/" .. texture_size
			texture_path = override_ov(texture_path, group)

			if love.filesystem.exists(texture_path .. "/" .. group .. ".lua") then
				-- block empty
			else
				for _, v in pairs(KR_PATH_ASSETS_GAME_FALLBACK) do
					texture_path = v.path .. "/images/" .. v.texture_size
					texture_path = override_ov(texture_path, group)

					if love.filesystem.exists(texture_path .. "/" .. group .. ".lua") then
						log.debug("  +++ texture group %s fallback to %s (size:%s)", group, texture_path, v.texture_size)

						forced_texture_size = v.texture_size

						break
					end
				end
			end
		else
			texture_path = KR_PATH_ASSETS_GAME_TARGET .. "/images/" .. texture_size
			texture_path = override_ov(texture_path, group)
		end

		if ref_height then
			scale = self:get_texture_scale(item_name, ref_height, forced_texture_size)
		end

		if queue then
			I:queue_load_atlas(scale, texture_path, group)
		else
			I:load_atlas(scale, texture_path, group)
		end
	end
end

function director:load_sound_groups(groups)
	S.global_source_mode = self.params.audio_mode

	if groups then
		for _, group in pairs(groups) do
			S:queue_load_group(group)
		end
	end
end

function director:queued_item_ready(dt)
	return I:queue_load_done() and S:queue_load_done()
end

function director:update(dt)
	S:update(dt)

	if self.next_item_name then
		self:queue_load_item_named(self.next_item_name, self.force_reload)

		self.queued_item_init = false
		self.queued_item_first_draw = false
		self.last_item_name = self.next_item_name
		self.next_item_name = nil
		self.force_reload = nil
	end

	if self.active_item then
		local ai = self.active_item

		ai:update(dt)
	end

	local ai = self.active_item
	local aits = ai and ai.is_transition and ai.transition_state or nil

	if aits == "closing" or aits == "opening" then
		-- block empty
	else
		if self.queue_unload_item and (not aits or aits == "closed") then
			self:unload_item(self.queue_unload_item)

			self.queue_unload_item = nil
		end

		if self.queued_item and self:queued_item_ready(dt) then
			local ai = self.active_item

			if ai and ai.hold_enabled then
				-- block empty
			else
				if not self.queued_item_init then
					local item = self.queued_item

					local function cb(outcome)
						self:item_done_callback(item.item_name, outcome)
					end

					self.queued_item:init(self.params.width, self.params.height, cb)

					self.queued_item.done_callback_called = nil
					self.queued_item_init = true
					self.queued_item_first_draw = false

					self.queued_item:update(2 * TICK_LENGTH)

					goto label_18_0
				end

				if ai then
					if ai.transition_state == "closing" then
						goto label_18_0
					elseif ai.transition_state == "closed" and self.queued_item_first_draw then
						ai:open()

						goto label_18_0
					elseif ai.transition_state == "opening" then
						goto label_18_0
					end
				end

				self:unload_item(self.active_item, self.next_item_args and self.next_item_args.postpone_unload)

				self.active_item = self.queued_item
				self.queued_item = nil
				self.queued_item_init = nil

				signal.emit(SGN_DIRECTOR_ITEM_SHOWN, self.active_item.item_name, self.active_item)

				local item = self.active_item
				local fps

				if item.max_fps then
					fps = item.max_fps
				else
					fps = not self.params.vsync and 60 or nil
				end

				item.limit_fps = fps
			end
		end
	end

	::label_18_0::

	if ISM then
		local state = self.active_item and self.active_item.get_ism_state and self.active_item:get_ism_state()

		ISM:update(dt, state)
	end

	services:update(dt)
end

function director:draw()
	if self.active_item then
		if self.scissor_w and self.scissor_enabled then
			G.setScissor(self.scissor_x, self.scissor_y, self.scissor_w, self.scissor_h)
		end

		local ai = self.active_item

		if ai.transition_state == "closing" and self.queue_unload_item then
			self.queue_unload_item:draw()
		elseif self.queued_item and self.queued_item_init then
			self.queued_item:draw()

			self.queued_item_first_draw = true
		end

		ai:draw()

		if self.scissor_w and self.scissor_enabled then
			G.setScissor()
		end
	end
end

function director:limit_fps(start_ts, sleep_delay)
	if self.active_item then
		local ai = self.active_item

		if ai.limit_fps then
			local limit_interval = 1 / ai.limit_fps
			local next_frame_ts = start_ts + limit_interval - sleep_delay
			local current_ts = love.timer.getTime()

			if next_frame_ts <= current_ts then
				return
			end

			local interval = km.clamp(0, limit_interval, next_frame_ts - current_ts)

			love.timer.sleep(interval)
		end
	end
end

function director:keypressed(key, isrepeat)
	if ISM then
		ISM:set_last_input(I_KEYBOARD)
	end

	if key == "tab" and love.window.getFullscreen() and love.system.getOS() == "OS X" and (love.keyboard.isDown("lgui") or love.keyboard.isDown("rgui")) then
		love.window.minimize()

		return
	end

	if DEBUG and key == "r" and love.keyboard.isDown("lshift") and not isrepeat then
		RC:reload()

		if self.active_item and self.active_item.item_name == "game" then
			if love.keyboard.isDown("lctrl") then
				self.next_item_name = "game"
				self.force_reload = true
				self.next_item_args = {
					level_idx = game.store.level_idx,
					level_mode = game.store.level_mode,
					level_difficulty = game.store.level_difficulty
				}
			else
				log.error("FORCING RELOAD OF GUI ONLY")
				game:reload_gui()
			end
		else
			log.error("FORCING RELOAD OF %s", self.last_item_name)

			self.force_reload = true
			self.next_item_name = self.last_item_name
		end

		return
	end

	if self.active_item and self.active_item.keypressed and self.active_item:keypressed(key, isrepeat) then
		return
	end

	if ISM then
		local state = self.active_item and self.active_item.get_ism_state and self.active_item:get_ism_state()

		ISM:proc_key(state, key, isrepeat)
	end
end

function director:keyreleased(key, isrepeat)
	if self.active_item and self.active_item.keyreleased then
		self.active_item:keyreleased(key, isrepeat)
	end
end

function director:textinput(t)
	if self.active_item and self.active_item.textinput then
		self.active_item:textinput(t)
	end
end

function director:mousepressed(x, y, button, istouch)
	if ISM and not istouch then
		ISM:set_last_input(I_MOUSE)
	end

	if DEBUG_CLICK then
		log.debug("mouspressed at (%i,%i)", x, y)
	end

	if self.cursor_down then
		love.mouse.setCursor(self.cursor_down)
	end

	if self.active_item and self.active_item.mousepressed then
		self.active_item:mousepressed(x, y, button, istouch)
	end
end

function director:mousereleased(x, y, button, istouch)
	if self.cursor_up then
		love.mouse.setCursor(self.cursor_up)
	end

	if self.active_item and self.active_item.mousereleased then
		self.active_item:mousereleased(x, y, button, istouch)
	end
end

function director:wheelmoved(dx, dy)
	if ISM then
		ISM:set_last_input(I_MOUSE)
	end

	if self.active_item and self.active_item.wheelmoved then
		self.active_item:wheelmoved(dx, dy)
	end
end

function director:touchpressed(id, x, y, dx, dy, pressure)
	if ISM then
		ISM:set_last_input(I_TOUCH)
	end

	if self.active_item and self.active_item.touchpressed then
		self.active_item:touchpressed(id, x, y, dx, dy, pressure)
	end
end

function director:touchreleased(id, x, y, dx, dy, pressure)
	if self.active_item and self.active_item.touchreleased then
		self.active_item:touchreleased(id, x, y, dx, dy, pressure)
	end
end

function director:touchmoved(id, x, y, dx, dy, pressure)
	if ISM then
		ISM:set_last_input(I_TOUCH)
	end

	if self.active_item and self.active_item.touchmoved then
		self.active_item:touchmoved(id, x, y, dx, dy, pressure)
	end
end

function director:gamepadaxis(joystick, axis, value)
	if self.active_item and self.active_item.gamepadaxis then
		self.active_item:gamepadaxis(joystick, axis, value)
	end
end

function director:gamepadpressed(joystick, button)
	if ISM then
		ISM:set_last_input(I_GAMEPAD)
	end

	if self.active_item then
		if self.active_item.gamepadpressed then
			self.active_item:gamepadpressed(joystick, button)
		end

		local state = self.active_item and self.active_item.get_ism_state and self.active_item:get_ism_state()

		if ISM then
			ISM:proc_button(state, joystick, button)
		end
	end
end

function director:gamepadreleased(joystick, button)
	if self.active_item and self.active_item.gamepadreleased then
		self.active_item:gamepadreleased(joystick, button)
	end
end

function director:joystickpressed(joystick, button)
	if self.active_item and self.active_item.joystickpressed then
		self.active_item:joystickpressed(joystick, button)
	end
end

function director:joystickreleased(joystick, button)
	if self.active_item and self.active_item.joystickreleased then
		self.active_item:joystickreleased(joystick, button)
	end
end

function director:joystickadded(joystick)
	if ISM then
		ISM:joystickadded(joystick)
	end

	if self.active_item and self.active_item.joystickadded then
		self.active_item:joystickadded(joystick)
	end

	signal.emit("joystick-added", joystick)
end

function director:joystickremoved(joystick)
	if ISM then
		ISM:joystickremoved(joystick)
	end

	if self.active_item and self.active_item.joystickremoved then
		self.active_item:joystickremoved(joystick)
	end

	signal.emit("joystick-removed", joystick)
end

function director:resize(w, h)
	log.debug(">>>>>>>>> screen size changed to %s,%s", w, h)
	self:reset_screen_params()
end

function director:focus(focus)
	log.paranoid("++++++++++ focus changed to :%s ++++++++++", focus)

	if self.active_item and self.active_item.focus then
		self.active_item:focus(focus)
	end

	signal.emit("focus-changed", focus)
end

director.skip_checks = {}

function director.skip_checks.check_skip_consent()
	return not PP:should_ask()
end

function director.skip_checks.check_skip_splash_custom()
	return not features.show_splash_custom
end

function director.skip_checks.check_skip_consent_simple()
	if not features.show_consent_simple then
		return true
	end

	local global = storage:load_global()

	if global.simple_privacy_policy_accepted then
		return true
	end

	return false
end

function director.skip_checks.check_skip_china_advise()
	return not features.censored_cn
end

return director
