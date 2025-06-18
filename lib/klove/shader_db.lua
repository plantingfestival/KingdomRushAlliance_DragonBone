-- chunkname: @./lib/klove/shader_db.lua

local log = require("klua.log"):new("shader_db")

require("klua.string")

local FS = love.filesystem
local G = love.graphics
local bgfx_paths = {
	D3D11 = "bgfx/Direct3D11",
	Metal = "bgfx/Metal",
	D3D12 = "bgfx/Direct3D11"
}
local shader_db = {}

function shader_db:init(shader_path, preload)
	self.shaders = {}

	local riok, renderer = pcall(love.graphics.getRendererInfo)

	if not riok then
		log.error("error calling love.graphics.getRendererInfo(). using defaults")
	elseif string.starts(renderer, "BGFX") then
		local renderer_type = string.split(renderer, " ")[2]

		if not renderer_type then
			log.error("error finding bgfx compiled shaders path for renderer %s", renderer)

			return
		end

		shader_db.bgfx_subpath = bgfx_paths[renderer_type]
	end

	self.path = shader_path

	if self.bgfx_subpath then
		self.path = self.path .. "/" .. self.bgfx_subpath
	end

	if not preload then
		return
	end

	local files = FS.getDirectoryItems(self.path)

	for i = 1, #files do
		local name = files[i]
		local f = self.path .. "/" .. name

		if self.bgfx_subpath then
			if FS.isFile(f) and string.match(f, ".vbin$") then
				self:get(string.gsub(name, ".vbin$", ""))
			end
		elseif FS.isFile(f) and string.match(f, ".c$") then
			self:get(string.gsub(name, ".c$", ""))
		end
	end
end

function shader_db:get(name)
	if self.bgfx_subpath then
		return self:get_bgfx(name)
	else
		return self:get_c(name)
	end
end

function shader_db:get_c(name)
	if not self.shaders[name] then
		local filename = self.path .. "/" .. name .. ".c"
		local start_ts = love.timer.getTime()

		log.debug("loading shader:%s from file %s", name, filename)

		local ok, sh = pcall(love.graphics.newShader, filename)

		if not ok then
			log.error("error loading shader:%s from file:%s\n%s", name, filename, tostring(sh))

			return nil
		end

		self.shaders[name] = sh

		log.debug("    time:%s", love.timer.getTime() - start_ts)
	end

	return self.shaders[name]
end

function shader_db:get_bgfx(name)
	if not self.shaders[name] then
		local vf = self.path .. "/" .. name .. ".vbin"
		local ff = self.path .. "/" .. name .. ".fbin"
		local start_ts = love.timer.getTime()

		log.debug("loading shader:%s from files %s %s", name, vf, ff)

		local ok, sh = pcall(love.graphics.newShader, vf, ff)

		if not ok then
			log.error("error loading shader:%s from files:%s,%s\n%s", name, vf, ff, tostring(sh))

			return nil
		end

		self.shaders[name] = sh

		log.debug("    time:%s", love.timer.getTime() - start_ts)
	end

	return self.shaders[name]
end

return shader_db
