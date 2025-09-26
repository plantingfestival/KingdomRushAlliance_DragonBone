-- chunkname: @./lib/klove/animation_db.lua

local ANI_DB_LUA = true
local log = require("klua.log"):new("animation_db")
local km = require("klua.macros")

require("klua.table")
require("klua.dump")

local G = love.graphics
local FS = love.filesystem
local KRN = KR_NATIVE and require("krn")

require("constants")

local animation_db = {}

animation_db.db = {}
animation_db.fps = FPS
animation_db.tick_length = TICK_LENGTH
animation_db.missing_animations = {}

function animation_db:unload(groups)
	local ag = groups and table.clone(groups) or {}

	if not table.contains(ag, "main") then
		table.insert(ag, "main")
	end

	if not table.contains(ag, "all") then
		table.insert(ag, "all")
	end

	if KRN then
		KRN.ani_db_unload(ag)
	end

	for k, a in pairs(self.db) do
		if table.contains(ag, a.group) then
			self.db[k] = nil
		end
	end
end

function animation_db:unload_all()
	if KRN then
		KRN.ani_db_unload_all()
	end

	self.db = nil
end

function animation_db:load(groups)
	local fext = KR_NATIVE and not ANI_DB_LUA and ".mp" or ".lua"
	local base_path = string.format("%s/data/animations", KR_PATH_GAME)

	if KRN and not ANI_DB_LUA then
		local _start_time = love.timer.getTime()

		if IS_TRILOGY then
			KRN.ani_db_load_file(string.format("%s/data/game_animations" .. fext, KR_PATH_GAME), "main")
		end

		local ag = groups and table.clone(groups) or {}

		if not table.contains(ag, "all") then
			table.insert(ag, "all")
		end

		KRN.ani_db_load_groups(ag, base_path)
		log.todo("ani load %s total time:%sms #groups:%s : %s", ANI_DB_LUA and "lua" or "native", (love.timer.getTime() - _start_time) * 1000, #ag, getdump(ag))
		log.debug("finished loading animations")

		return
	end

	local function load_ani_file(f, g)
		local ok, achunk = pcall(FS.load, f)

		if not ok then
			assert(false, string.format("Failed to load animation file %s.\n%s", f, achunk))
		end

		local ok, atable = pcall(achunk)

		if not ok then
			assert(false, string.format("Failed to eval animation chunk for file:%s", f, atable))
		end

		if not atable then
			assert(false, string.format("Failed to load animation file %s. Could not find .animations", f))
		end

		if atable.animations then
			atable = atable.animations
		end

		for k, v in pairs(atable) do
			if self.db[k] then
				assert(false, string.format("Animation %s already exists. Not loading it from file %s", k, f))
			else
				v.group = g
				self.db[k] = v
			end
		end

		log.info("Loaded animation group:%s file:%s", g, f)
	end

	local function append_tree(out, path)
		if FS.isDirectory(path) then
			table.insert(out, path)

			local items = FS.getDirectoryItems(path)

			for i = 1, #items do
				local fp = path .. "/" .. items[i]

				if FS.isDirectory(fp) then
					append_tree(out, fp)
				end
			end
		end
	end

	local _start_time = love.timer.getTime()

	self.db = {}

	load_ani_file(string.format("%s/data/game_animations" .. fext, KR_PATH_GAME), "main")

	local ani_group_paths = {}
	local ani_paths = {}

	append_tree(ani_paths, base_path .. "/all")

	ani_group_paths.all = ani_paths

	if groups then
		for _, g in pairs(groups) do
			local tree = {}

			append_tree(tree, base_path .. "/" .. g)

			ani_group_paths[g] = tree
		end
	end

	for g, l in pairs(ani_group_paths) do
		for _, p in pairs(l) do
			local files = FS.getDirectoryItems(p)

			for i = 1, #files do
				local f = p .. "/" .. files[i]

				if FS.isFile(f) and string.match(f, fext .. "$") then
					load_ani_file(f, g)
				end
			end
		end
	end

	local expanded_keys = {}
	local deleted_keys = {}

	for k, v in pairs(self.db) do
		if v.layer_from and v.layer_to and v.layer_prefix then
			for i = v.layer_from, v.layer_to do
				local nk = string.gsub(k, "layerX", "layer" .. i)
				local nv = {
					group = v.group,
					pre = v.pre,
					post = v.post,
					from = v.from,
					to = v.to,
					ranges = v.ranges,
					frames = v.frames,
					prefix = string.format(v.layer_prefix, i)
				}

				expanded_keys[nk] = nv

				table.insert(deleted_keys, k)
			end

			table.insert(expanded_keys, k)
		end
	end

	for k, v in pairs(expanded_keys) do
		self.db[k] = v
	end

	for k, v in pairs(deleted_keys) do
		self.db[k] = nil
	end

	for k, v in pairs(self.db) do
		if not v.frames then
			self:expand_frames(v)
		end
	end

	if KRN and ANI_DB_LUA then
		local _nc_start_time = love.timer.getTime()

		KRN.ani_db_load(self.db)
		log.debug("ani load %s native copy time:%sms", ANI_DB_LUA and "lua" or "native", (love.timer.getTime() - _nc_start_time) * 1000)
	end

	log.debug("finished loading animations")

	if DEBUG then
		log.debug("animations load %s - total time:%sms #groups:%s + all : %s", ANI_DB_LUA and "lua" or "native", (love.timer.getTime() - _start_time) * 1000, #groups, getdump(groups))
	end
end

function animation_db:has_animation(animation_name)
	if KRN then
		return KRN.ani_db_has_animation(animation_name)
	end

	return self.db[animation_name] ~= nil
end

function animation_db:expand_frames(animation)
	local a = animation
	local frames = {}

	if a.ranges then
		for _, range in pairs(a.ranges) do
			if #range == 2 then
				local from, to = unpack(range)
				local inc = to < from and -1 or 1

				for i = from, to, inc do
					table.insert(frames, i)
				end
			else
				table.append(frames, range)
			end
		end
	else
		if a.pre then
			table.append(frames, a.pre)
		end

		if a.from and a.to then
			local inc = a.from > a.to and -1 or 1

			for i = a.from, a.to, inc do
				table.insert(frames, i)
			end
		end

		if a.post then
			table.append(frames, a.post)
		end
	end

	a.frames = frames
end

function animation_db:fn(animation_name, time_offset, loop, fps)
	if KRN then
		return KRN.ani_db_fn(animation_name, time_offset, loop, fps)
	end

	local a = self.db[animation_name]

	if not a then
		if not animation_name and self.missing_animations["nil"] or self.missing_animations[animation_name] then
			return nil
		end

		log.error("animation %s not found", animation_name)

		self.missing_animations[animation_name or "nil"] = true

		return nil
	end

	return self:fni(a, time_offset, loop, fps)
end

function animation_db:fni(animation, time_offset, loop, fps, tick_length)
	local a = animation

	fps = fps or self.fps
	tick_length = tick_length or self.tick_length

	if not a.frames then
		self:expand_frames(a)
	end

	local frames = a.frames
	local eps = 1e-09
	local len = #frames
	local elapsed_frames = math.ceil(time_offset * fps + eps)
	local next_elapsed = math.ceil((time_offset + tick_length) * fps + eps)
	local runs = math.max(0, math.floor((next_elapsed - 1) / len))
	local idx

	if loop then
		idx = math.floor(time_offset * fps + eps) % len + 1
	else
		idx = km.clamp(1, len, elapsed_frames)
	end

	local frame = frames[idx]

	return string.format("%s_%04i", a.prefix, frame), runs, idx
end

function animation_db:duration(animation_name)
	local a = self.db[animation_name]

	if not a then
		if not animation_name and self.missing_animations["nil"] or self.missing_animations[animation_name] then
			return nil
		end

		log.error("animation %s not found", animation_name)

		self.missing_animations[animation_name or "nil"] = true

		return nil
	end

	if not a.frames then
		self:expand_frames(a)
	end

	return #a.frames / self.fps, #a.frames
end

return animation_db
