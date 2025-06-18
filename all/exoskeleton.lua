local log = require("klua.log"):new("exoskeleton")
local FS = love.filesystem
local A = require("klove.animation_db")
local EXO = {
	exos = {},
	db = {},
	missing_frames = {}
}

function EXO:load_kui(name)
	local exo = self:load_lua(name)

	self.exos[name] = exo

	self:load_fake_sprites_to_db(exo)

	local anis = {}
	local max_parts = 0

	for _, animation in ipairs(exo.animations) do
		local name = exo.name .. "_" .. animation.name

		anis[name] = {
			from = 1,
			to = #animation.frames,
			prefix = name
		}

		for _, frame in ipairs(animation.frames) do
			max_parts = max_parts < #frame.parts and #frame.parts or max_parts
		end
	end

	log.paranoid("%s", getfulldump(anis))

	return anis, max_parts
end

function EXO:load(exo_list)
	if not exo_list then
		return
	end

	log.info("EXO: Loading %s", tostring(required_exoskeletons))

	for _, exo_name in ipairs(exo_list) do
		local exo = self:load_lua(exo_name)

		self:load_fake_sprites_to_db(exo)
		self:load_animations_to_animation_db(exo)

		self.exos[exo_name] = exo

		for _, animation in ipairs(exo.animations) do
			log.info("EXO: animation %s_%s", exo.name, animation.name)
		end
	end
end

function EXO:destroy()
	return
end

function EXO:load_lua(path)
	local fn = KR_PATH_GAME .. "/data/exoskeletons/" .. path .. ".lua"

	if not FS.isFile(fn) then
		log.error("exoskeleton file not found for %s", fn)

		return
	end

	local f = FS.load(fn)
	local exo = f()

	exo.name = path

	return exo
end

function EXO:load_animations_to_animation_db(exo)
	for _, animation in ipairs(exo.animations) do
		local name = exo.name .. "_" .. animation.name

		A.db[name] = {
			from = 1,
			to = #animation.frames,
			prefix = name
		}
	end
end

function EXO:load_fake_sprites_to_db(exo)
	for _, animation in ipairs(exo.animations) do
		local ani_name = animation.name

		for idx, frame in ipairs(animation.frames) do
			local sprite_name = string.format("%s_%s_%04d", exo.name, ani_name, idx)

			self.db[sprite_name] = frame
			frame.exo = exo
		end
	end
end

function EXO:f(fn)
	if not fn or self.missing_frames[fn] then
		return nil
	end

	local exo_frame = self.db[fn]

	if not exo_frame then
		log.error("Could not find exo_frame called: %s", fn)
		self.missing_frames[fn] = true

		return nil
	end

	return exo_frame
end

return EXO
