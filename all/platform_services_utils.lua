local log = require("klua.log"):new("platform_services_utils")
local signal = require("hump.signal")
local psu = {}

function psu:new_prq()
	local t = {}
	local mt = {}

	mt.__index = {
		add = function(this, rid, kind, callback, timeout)
			local item = {
				id = rid,
				kind = kind,
				callback = callback,
				ts = love.timer.getTime(),
				timeout = timeout
			}

			rawset(this, rid, item)

			return item
		end,
		remove = function(this, rid)
			local item = rawget(this, rid)

			rawset(this, rid, nil)

			return item
		end,
		contains = function(this, rid)
			return rawget(this, rid) ~= nil
		end
	}

	setmetatable(t, mt)

	return t
end

function psu:load_library(name, ffi)
	local osname = love.system.getOS()

	if osname == "iOS" then
		return ffi.C
	else
		local lib_name = self:get_library_file(name)

		return ffi.load(lib_name)
	end
end

function psu:get_library_path()
	if love.filesystem.isFused() then
		return ""
	else
		local osname = love.system.getOS()
		local path = love.filesystem.getSourceBaseDirectory() .. "/platform/bin"

		if osname == "Windows" then
			if DEBUG then
				local o = string.format("%s/%s.%s", path, osname, jit.arch)

				o = string.gsub(o, "/", "\\")

				return o
			else
				return ""
			end
		elseif osname == "OS X" then
			return string.format("%s/macOS", path)
		elseif osname == "iOS" then
			return string.format("%s/iOS", path)
		elseif osname == "Linux" or osname == "Android" then
			return string.format("%s/%s", path, osname)
		else
			return name
		end
	end
end

function psu:get_library_file(name)
	local osname = love.system.getOS()

	if love.filesystem.isFused() then
		if osname == "Windows" then
			return name .. ".dll"
		else
			return name
		end
	else
		local path = self:get_library_path()

		if osname == "Windows" then
			if DEBUG then
				local o = string.format("%s/%s.dll", path, name)

				o = string.gsub(o, "/", "\\")

				return o
			else
				return name .. ".dll"
			end
		elseif osname == "OS X" then
			return string.format("%s/lib%s.dylib", path, name)
		elseif osname == "iOS" then
			return string.format("%s/lib%s.a", path, name)
		elseif osname == "Linux" or osname == "Android" then
			return string.format("%s/lib%s.so", path, name)
		else
			return name
		end
	end
end

function psu:get_ffi_func_string(func, max_buf_size)
	local ffi = require("ffi")
	local buf_max_size = max_buf_size or 512
	local buffer = ffi.new("char[?]", buf_max_size)
	local buffer_length = func(buffer, buf_max_size)
	local s = ffi.string(buffer, buffer_length)

	return s
end

function psu:deliver_rewards(rewards)
	if not rewards then
		log.debug("rewards empty. skipping")

		return
	end

	local storage = require("storage")
	local slot = storage:load_slot()

	if not slot then
		log.error("error giving ad reward. slot could not be loaded")

		return
	end

	if rewards.items then
		local bag = slot.bag or {}

		for _, item in pairs(rewards.items) do
			bag[item] = (bag[item] or 0) + 1
		end

		slot.bag = bag
	end

	if rewards.crowns and rewards.crowns > 0 then
		slot.crowns = (slot.crowns or 0) + rewards.crowns
	end

	if rewards.gems and rewards.gems > 0 then
		slot.gems = (slot.gems or 0) + rewards.gems
	end

	storage:save_slot(slot, nil, true)
end

return psu
