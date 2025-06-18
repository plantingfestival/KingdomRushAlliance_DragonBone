-- chunkname: @./kr5/screen_splash.lua

local log = require("klua.log"):new("screen_splash")
local V = require("klua.vector")
local F = require("klove.font_db")
local FS = love.filesystem
local SU = require("screen_utils")
local PS = require("platform_services")
local timer = require("hump.timer").new()

require("klove.kui")

local storage = require("storage")
local features = require("features")
local ktw = require("klove.tween").new(timer)
local kui_db = require("klove.kui_db")
local class = require("middleclass")

require("gg_views")

local S = require("sound_db")
local screen = {}

screen.required_sounds = {
	"splash"
}
screen.required_textures = {
	"screen_splash"
}
screen.ref_w = 1728
screen.ref_h = 768
screen.ref_res = TEXTURE_SIZE_ALIAS.ipad
screen.base_scale_list = {
	splash_screen = V.vv(OVT(1, OV_PHONE, 1, OV_TABLET, 0.6))
}
screen.base_scale_aspect_factors = {}

function screen:init(w, h, done_callback)
	self.done_callback = done_callback

	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)

	self.w, self.h = w, h
	self.sw = sw
	self.sh = sh
	self.bs = SU.factor_base_scale_list(self.base_scale_list, self.base_scale_aspect_factors, sw / sh)

	local ctx = SU.new_screen_ctx(self)

	ctx.hud_scale = SU.get_hud_scale(w, h, self.ref_w, self.ref_h)
	ctx.premium = not PS.services.iap or PS.services.iap:is_premium()
	ctx.fullads = PS.services.fullads ~= nil
	ctx.bs = self.bs

	local tt = kui_db:get_table("splash_screen", ctx)
	local window = KWindow:new_from_table(tt)

	window.scale = V.v(scale, scale)
	window.size = {
		x = sw,
		y = sh
	}
	window.origin = origin
	window.timer = timer
	window.ktw = ktw

	window:set_responder(window)

	self.window = window

	local global = storage:load_global()

	if not global or not global.launch_count or global.launch_count == 1 then
		self.first_launch = true
	end

	local splash_anim

	if features.censored_cn then
		splash_anim = SplashAnim(nil, "SplashScreenAnimationCnCensoredDef", "idle", nil, self)
	else
		splash_anim = SplashAnim(nil, "SplashScreenAnimationDef", "idle", nil, self)
	end

	splash_anim.pos = V.v(ctx.sw / 2, ctx.sh / 2)

	self.window:add_child(splash_anim, 1)
	splash_anim:start()

	local overlay = KView:new(V.v(sw, sh))

	overlay.colors.background = {
		0,
		0,
		0,
		255
	}
	overlay.alpha = 0
	overlay.hidden = true
	overlay.propagate_on_down = true
	overlay.propagate_on_up = true
	overlay.propagate_on_click = true

	self.window:add_child(overlay)

	self.overlay = overlay

	local st = storage:load_settings()

	S:set_main_gain_music(st and st.volume_music or 1)
	S:set_main_gain_fx(st and st.volume_fx or 1)

	if not features.censored_cn then
		S:queue("GUISplash")
	end

	if features.splash_video_service then
		timer:after(0.1, function()
			self:play_video_hw()
		end)
	elseif features.splash_video_path then
		self:play_video_sw()
	end
end

function screen:update(dt)
	timer:update(dt)
	self.window:update(dt)

	if self.video_service and self.video_service:is_finished() then
		log.debug("video_service playback finihed!")
		self.video_service:stop()

		self.video_service = nil

		timer:after(0.25, function()
			self:fade_out()
		end)
	elseif self.video and love.timer.getTime() - self.video_start_ts > 0.5 and not self.video.video:isPlaying() then
		self.window:remove_child(self.video)

		self.video = nil

		timer:after(0.25, function()
			self:fade_out()
		end)
	end
end

function screen:destroy()
	timer:clear()
	self.window:destroy()

	self.window = nil
end

function screen:draw()
	self.window:draw()
end

function screen:keypressed(key, isrepeat)
	if not isrepeat and (key == "ralt" or key == "lalt") then
		self.alt_pressed_ts = love.timer.getTime()
	else
		self:skip()
	end
end

function screen:mousepressed(x, y, button)
	self:skip()
end

function screen:joystickpressed(joystick, button)
	self:skip()
end

function screen:skip()
	if self.first_launch then
		log.debug("cannot skip in first launch")

		return
	end

	if self.skipped then
		return
	end

	log.debug("skipping...")

	self.skipped = true

	timer:clear()
	S:stop_all()

	if self.video_service then
		self.video_service:stop()

		self.video_service = nil
	end

	self.overlay.hidden = false
	self.overlay.alpha = 0

	timer:tween(0.33, self.overlay, {
		alpha = 1
	}, "linear", function()
		self:done()
	end)
end

function screen:done()
	if (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) and self.alt_pressed_ts and love.timer.getTime() - self.alt_pressed_ts > 1 then
		log.error("ALT KEY pressed: showing launcher")

		local mparams = {}

		mparams.show_settings_dialog = true
		mparams.width = 1024
		mparams.height = 768
		mparams.fullscreen = false
		mparams.player_customized = true

		storage:save_settings(mparams)
		love.event.quit("restart")
	else
		local outcome = {
			splash_done = true
		}

		outcome.prevent_loading = true

		self.done_callback(outcome)
	end
end

function screen:fade_out()
	if self.skipped then
		return
	end

	self.overlay.hidden = false
	self.overlay.alpha = 0

	timer:tween(0.33, self.overlay, {
		alpha = 1
	}, "linear", function()
		self:done()
	end)
end

function screen:play_video_hw()
	local aspect_list = {}

	for _, v in pairs(features.splash_video_service_items) do
		local aspect_str = string.split(v, "_")
		local parts = string.split(aspect_str[1], "x")

		table.insert(aspect_list, {
			tonumber(parts[1]) / tonumber(parts[2]),
			aspect_str[1]
		})
	end

	table.sort(aspect_list, function(i1, i2)
		return i1[1] < i2[1]
	end)
	log.paranoid("aspect_list: %s", getfulldump(aspect_list))

	local aspect = self.sw / self.sh
	local aspect_string = "4x3"
	local dist = 9999

	for _, v in pairs(aspect_list) do
		local this_dist = math.abs(aspect - v[1])

		if this_dist < dist then
			aspect_string = v[2]
			dist = this_dist
		end
	end

	log.debug("picked aspect %s dist:%s", aspect_string, dist)

	local orientation = "Landscape"
	local current_res = 99999
	local current_dist = 99999
	local video_name

	for _, file in pairs(features.splash_video_service_items) do
		local basename = string.sub(file, 1, #file - 4)
		local parts = string.split(basename, "_")

		log.debug("  %s %s %s w:%s", parts[1], parts[2], parts[3], self.w)

		if parts[1] ~= aspect_string then
			-- block empty
		elseif parts[2] ~= orientation then
			-- block empty
		elseif parts[3] == nil then
			video_name = file

			break
		else
			local p3 = tonumber(parts[3])
			local dist = math.abs(p3 - self.w)

			if dist < current_dist then
				current_res = p3
				current_dist = dist
				video_name = file
			end
		end
	end

	if not video_name then
		log.error("could not find video")

		return
	else
		log.debug("found video_name: %s", video_name)
	end

	local absolute = not love.filesystem.isFused()

	if absolute then
		local parts = {
			"file://",
			KR_FULLPATH_BASE,
			"_assets/_resources",
			version.bundle_id,
			"splash_videos",
			video_name
		}

		video_name = table.concat(parts, "/")

		log.error("PLAYING ABSOLUTE VIDEO: %s", video_name)
	elseif features.splash_video_service_path then
		video_name = features.splash_video_service_path .. "/" .. video_name
	end

	self.video_service = PS.services[features.splash_video_service]

	self.video_service:set_video_name(video_name, absolute)
	self.video_service:play()
end

function screen:play_video_sw()
	local video_file = KR_PATH_ASSETS_ROOT .. "/" .. features.splash_video_path

	if string.sub(video_file, #video_file) == "*" then
		local video_path = string.sub(video_file, 1, #video_file - 2)
		local aspect_list = {
			{
				2.1666666666666665,
				"19.5x9"
			},
			{
				1.7777777777777777,
				"16x9"
			},
			{
				1.6,
				"16x10"
			},
			{
				1.4333333333333333,
				"4.3x3"
			},
			{
				1.3333333333333333,
				"4x3"
			}
		}

		log.paranoid("aspect_list: %s", getfulldump(aspect_list))

		local aspect = self.w / self.h
		local aspect_string = "4x3"
		local dist = 9999

		for _, v in pairs(aspect_list) do
			local this_dist = math.abs(aspect - v[1])

			if this_dist < dist then
				aspect_string = v[2]
				dist = this_dist
			end
		end

		log.debug("picked aspect %s dist:%s", aspect_string, dist)

		local orientation = "Landscape"
		local files = FS.getDirectoryItems(video_path)
		local current_res = 99999
		local current_dist = 99999
		local video_name

		for _, file in pairs(files) do
			local basename = string.sub(file, 1, #file - 4)
			local parts = string.split(basename, "_")

			log.debug("  %s %s %s w:%s", parts[1], parts[2], parts[3], self.sw)

			if parts[1] ~= aspect_string then
				-- block empty
			elseif parts[2] ~= orientation then
				-- block empty
			elseif parts[3] == nil then
				video_name = file

				break
			else
				local p3 = tonumber(parts[3])
				local dist = math.abs(p3 - self.sw)

				if dist < current_dist then
					current_res = p3
					current_dist = dist
					video_name = file
				end
			end
		end

		if not video_name then
			log.error("could not find video")
		else
			log.debug("found video_name: %s", video_name)
		end

		video_file = video_path .. "/" .. video_name
	end

	log.debug("loading video " .. video_file)

	self.video = KVideoView:new(video_file)

	local scale = 1
	local screen_a = self.sw / self.sh
	local video_a = self.video.size.x / self.video.size.y

	if video_a <= screen_a then
		scale = self.sw / self.video.size.x
	else
		scale = self.sh / self.video.size.y
	end

	self.video.scale = V.v(scale, scale)
	self.video.pos = V.v((self.sw - self.video.size.x * scale) / 2, (self.sh - self.video.size.y * scale) / 2)

	self.video.video:play()
	self.content:add_child(self.video)

	self.video_start_ts = love.timer.getTime()
end

SplashAnim = class("SplashAnim", GGExo)

function SplashAnim:initialize(size, exo_name, exo_animation, exo_scale_factor, screen)
	GGExo.initialize(self, size, exo_name, exo_animation, exo_scale_factor)

	self.hidden = true
	self.ts = 0
	self.runs = 0
	self.exo_animation = "idle"
	self.screen = screen
	self.scale = V.v(1.3, 1.3)
end

function SplashAnim:update(dt)
	GGExo.update(self, dt)
end

function SplashAnim:on_exo_finished(runs)
	return
end

function SplashAnim:start()
	self.exo_animation = "idle"
	self.ts = 0.2
	self.runs = 0
	self.hidden = false

	function self.on_exo_finished()
		self.exo_animation = "idle"
		self.loop = false

		if features.censored_cn then
			timer:after(2, function()
				self.screen:fade_out()
			end)
		else
			self.screen:fade_out()
		end
	end
end

function SplashAnim:open()
	return
end

function SplashAnim:close()
	return
end

return screen
