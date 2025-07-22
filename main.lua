local lldebugger = nil
if arg[2] == "debug" then
	lldebugger = require("lldebugger")
	lldebugger.start()
end

local dok, deval = pcall(require, "debug_eval")

if not dok or not deval then
	require("main_globals")
end

KR_OS = love.system.getOS()

if KR_TARGET == "dynamic" then
	if KR_PLATFORM == "android" then
		local jnia = require("all.jni_android")
		local px = jnia.get_system_property("X_PIXELS")
		local py = jnia.get_system_property("Y_PIXELS")
		local w = px / jnia.get_system_property("X_DPI")
		local h = py / jnia.get_system_property("Y_DPI")
		local d = math.sqrt(w * w + h * h)

		print("DYNAMIC: d:" .. tostring(d) .. " px/py:" .. tostring(px / py))

		if d >= 6.9 and px / py <= 1.788888888888889 then
			KR_TARGET = "tablet"
		else
			KR_TARGET = "phone"
		end
	elseif KR_PLATFORM == "ios" then
		local ffi = require("ffi")

		ffi.cdef(" size_t kr_get_device_model(char* buf, size_t bufSize); ")

		local buf_max_size = 1024
		local buffer = ffi.new("char[?]", buf_max_size)
		local buffer_length = ffi.C.kr_get_device_model(buffer, buf_max_size)
		local device_model = ffi.string(buffer, buffer_length)
		local m = {
			string.match(device_model, "(%a+)(%d+),")
		}

		if m[1] == "iPad" then
			KR_TARGET = "tablet"
		else
			KR_TARGET = "phone"
		end
	else
		print("DYNAMIC ERROR! THIS PLATFORM HAS NO DYNAMIC TARGET RESOLUTION")
	end

	print("DYNAMIC TARGET SOLVED TO ", KR_TARGET)
end

local base_dir = love.filesystem.getSourceBaseDirectory()
local work_dir = love.filesystem.getWorkingDirectory()
local ppref

if love.filesystem.isFused() then
	ppref = ""
elseif KR_PLATFORM == "xbox" or KR_PLATFORM == "uwp" then
	ppref = ""
elseif KR_PLATFORM == "android" then
	ppref = base_dir .. "/lovegame/"
else
	ppref = base_dir ~= work_dir and "" or "src/"
end

local apref = ppref .. "_assets/"
local rel_ppref = ""
local rel_apref = "_assets/"
local jpref = "joint_apk"

if love.filesystem.isFused() and KR_PLATFORM == "android" and love.filesystem.isDirectory(jpref) then
	local ffi = require("ffi")
	local arch = ffi.abi("gc64") and "64" or "32"

	ppref = jpref .. "/gc" .. arch .. "/"
	apref = jpref .. "/"
	rel_ppref = ppref
	rel_apref = apref

	print(string.format("main.lua - joint_apk found: configuring ppref:%s apref:%s", ppref, apref))
end

local additional_paths = {
	string.format("%s?.lua", ppref),
	string.format("%s%s-%s/?.lua", ppref, KR_GAME, KR_TARGET),
	string.format("%s%s/?.lua", ppref, KR_GAME),
	string.format("%sall-%s/?.lua", ppref, KR_TARGET),
	string.format("%sall/?.lua", ppref),
	string.format("%slib/?.lua", ppref),
	string.format("%slib/?/init.lua", ppref),
	string.format("%s%s-%s/?.lua", apref, KR_GAME, KR_TARGET),
	string.format("%sall-%s/?.lua", apref, KR_TARGET)
}

package.path = package.path .. ";" .. table.concat(additional_paths, ";")

love.filesystem.setRequirePath("?.lua;?/init.lua" .. ";" .. table.concat(additional_paths, ";"))

KR_FULLPATH_BASE = base_dir .. "/src"
KR_PATH_ROOT = string.format("%s", rel_ppref)
KR_PATH_ALL = string.format("%s%s", rel_ppref, "all")
KR_PATH_ALL_TARGET = string.format("%s%s-%s", rel_ppref, "all", KR_TARGET)
KR_PATH_GAME = string.format("%s%s", rel_ppref, KR_GAME)
KR_PATH_GAME_TARGET = string.format("%s%s-%s", rel_ppref, KR_GAME, KR_TARGET)
KR_PATH_ASSETS_ROOT = string.format("%s", rel_apref)
KR_PATH_ASSETS_ALL_TARGET = string.format("%s%s-%s", rel_apref, "all", KR_TARGET)
KR_PATH_ASSETS_GAME_TARGET = string.format("%s%s-%s", rel_apref, KR_GAME, KR_TARGET)

local log = require("klua.log")

require("klua.table")
require("klua.dump")
require("version")
require("constants")

if version.build == "RELEASE" then
	DEBUG = nil
	log.level = log.WARNING_LEVEL

	local ok, l = pcall(require, "log_levels_release")

	log.default_level_by_name = ok and l or {}
else
	DEBUG = true
	log.level = log.WARNING_LEVEL

	local ok, l = pcall(require, "log_levels_debug")

	log.default_level_by_name = ok and l or {}

	love.filesystem.setSymlinksEnabled(true)
end

if KR_PLATFORM == "android" then
	function log.print_fn(s)
		print(s)
	end
elseif (KR_PLATFORM == "xbox" or KR_PLATFORM == "uwp") and KR_OS == "UWP" or KR_OS == "GDK Xbox" or KR_OS == "GDK Desktop" then
	local ffi = require("ffi")

	ffi.cdef("void SDL_Log(const char* fmt, ...);")

	local lib = ffi.load("SDL2.dll")

	if lib then
		function log.print_fn(s)
			lib.SDL_Log(s)
		end
	end
end

local features = require("features")
local storage = require("storage")
local F = require("klove.font_db")
local MU = require("main_utils")
local i18n = require("i18n")

if features.asset_all_fallback then
	KR_PATH_ASSETS_ALL_FALLBACK = {}

	for _, v in pairs(features.asset_all_fallback) do
		table.insert(KR_PATH_ASSETS_ALL_FALLBACK, {
			path = string.format("%s%s", rel_apref, v.path)
		})
	end
end

if features.asset_game_fallback then
	KR_PATH_ASSETS_GAME_FALLBACK = {}

	for _, v in pairs(features.asset_game_fallback) do
		table.insert(KR_PATH_ASSETS_GAME_FALLBACK, {
			path = string.format("%s%s", rel_apref, v.path),
			texture_size = v.texture_size
		})
	end
end

nil_handler_mt = {
	__index = function()
		return function()
			return
		end
	end
}
nil_handler = {}

setmetatable(nil_handler, nil_handler_mt)

main = {}
main.handler = nil
main.profiler = nil
main.profiler_displayed = false
main.draw_stats = nil
main.draw_stats_displayed = false
main.log_output = nil

function main:set_locale(locale)
	if features.forced_locale then
		locale = features.forced_locale
	end

	i18n.load_locale(locale)

	if DEBUG then
		package.loaded["data.font_subst"] = nil
	end

	local fs = require("data.font_subst")

	for _, v in pairs(fs.global) do
		F:set_font_subst(unpack(v))
	end

	local locale_subst = fs[locale] or fs.default

	for _, v in pairs(locale_subst) do
		F:set_font_subst(unpack(v))
	end
end

local function close_log()
	if main.log_output then
		log.error("<< closing >>")
		io.stderr:write("Closing log file\n")
		io.flush()
		main.log_output:close()
		io.stderr:write("Bye\n")
	end
end

local function load_director()
	if features.asset_game_fallback_for_texture_size and features.asset_game_fallback_for_texture_size[main.params.texture_size] then
		KR_PATH_ASSETS_GAME_FALLBACK = {}

		local fallbacks = features.asset_game_fallback_for_texture_size[main.params.texture_size]

		for _, v in pairs(fallbacks) do
			table.insert(KR_PATH_ASSETS_GAME_FALLBACK, {
				path = string.format("%s%s", rel_apref, v.path),
				texture_size = v.texture_size
			})
		end
	end

	love.window.setMode(main.params.width, main.params.height, {
		centered = false,
		fullscreen = main.params.fullscreen,
		fullscreentype = main.params.fullscreentype,
		vsync = main.params.vsync,
		msaa = main.params.msaa,
		highdpi = main.params.highdpi,
		display = main.params.display
	})

	local aw, ah = love.graphics.getDimensions()

	if aw and ah and (aw ~= main.params.width or ah ~= main.params.height) then
		log.debug("patching width/height from %s,%s, to %s,%s dpi scale:%s", main.params.width, main.params.height, aw, ah, love.window.getPixelScale())

		main.params.width, main.params.height = aw, ah
	end

	if main.params.wpos then
		local x, y = unpack(main.params.wpos)

		love.window.setPosition(x or 1, y or 1)
	end

	_defer_init_director = 2
	main.handler = nil_handler
end

local function load_app_settings()
	local I = require("klove.image_db")
	local settings = require("screen_settings")

	for _, t in pairs(settings.required_textures) do
		I:load_atlas(1, KR_PATH_ASSETS_GAME_TARGET .. "/images/fullhd", t)
	end

	local function done_cb()
		storage:save_settings(main.params)

		main.handler = nil

		for _, t in pairs(settings.required_textures) do
			I:unload_atlas(t, 1)
		end

		settings:destroy()
		collectgarbage()
		load_director()
	end

	local w, h = settings.w, settings.h
	local dw, dh = love.window.getDesktopDimensions()

	if dh and dh > 2 * h then
		local scale = 0.4 * dh / h

		w = w * scale
		h = h * scale
	end

	settings:init(w, h, main.params, done_cb)

	main.handler = settings

	if KR_PLATFORM == "uwp" then
		local ow = w

		w = 800
		settings.window.origin.x = (w - ow) / 2
	end

	love.window.setMode(w, h, {
		centered = true,
		vsync = false
	})
end

function love.load(arg)
	love.filesystem.setIdentity(version.identity)

	if love.filesystem.isFused() and not love.filesystem.exists(KR_PATH_ALL_TARGET) then
		log.info("")
		log.info("mounting asset files...")
		log.debug("mounting base_dir")

		if not love.filesystem.mount(base_dir, "/", true) then
			log.error("error mounting assets base_dir: %s", base_dir)

			return
		end

		for _, n in pairs({
			KR_PATH_ALL_TARGET,
			KR_PATH_GAME_TARGET
		}) do
			local fn = string.format("%s.dat", n)
			local dn = string.format("%s", n)

			log.debug("mounting %s -> %s", fn, dn)

			if not love.filesystem.mount(fn, dn, true) then
				log.error("error mounting assets file: %s", fn)

				return
			end
		end
	end

	main.params = table.deepclone(storage:load_settings())

	MU.basic_init()

	if DEBUG and love.filesystem.isFile(KR_PATH_ROOT .. "args.lua") then
		if KR_TARGET == "desktop" then
			print("WARNING: Appending parameters from args.lua with command line args.")

			arg = table.append(arg, require("args"), true)
		else
			print("WARNING: Reading parameters from args.lua. Overrides all cmdline arguments")

			arg = require("args")
		end
	end

	MU.parse_args(arg, main.params)
	MU.default_params(main.params, KR_GAME, KR_TARGET, KR_PLATFORM)
	MU.apply_params(main.params, KR_GAME, KR_TARGET, KR_PLATFORM)

	if main.params.log_level then
		log.level = tonumber(main.params.log_level)
	end

	main.log_output = MU.redirect_output(main.params)

	if main.log_output then
		log.error(MU.get_version_info(version))
		log.error(MU.get_graphics_features())
	end

	MU.start_debugger(main.params)

	if DEBUG then
		log.info(MU.get_debug_info(main.params))
	end

	local font_paths = KR_PATH_ASSETS_ALL_FALLBACK or {
		{
			stop = true,
			path = KR_PATH_ASSETS_GAME_TARGET
		},
		{
			path = KR_PATH_ASSETS_ALL_TARGET
		}
	}

	for _, v in pairs(font_paths) do
		local p = v.path .. "/fonts"

		if love.filesystem.exists(p .. "/ObelixPro.ttf") then
			F:init(p)
			F:load()

			if v.stop then
				break
			end
		end
	end

	main:set_locale(main.params.locale)
	love.window.setTitle(_("GAME_TITLE_" .. string.upper(KR_GAME)))

	local icon = KR_PATH_ASSETS_GAME_TARGET .. "/icons/icon256.png"

	if love.filesystem.isFile(icon) then
		love.window.setIcon(love.image.newImageData(icon))
	end

	if not main.params.skip_settings_dialog or main.params.show_settings_dialog then
		main.params.show_settings_dialog = nil

		load_app_settings()
	else
		load_director()
	end

	MU.apply_colorspace(main.params, KR_GAME, KR_TARGET, KR_PLATFORM)

	if main.params.profiler then
		main.profiler = require("klove.profiler")
	end

	if main.params.draw_stats then
		log.error("---- LOADING DRAW STATS ----")

		main.draw_stats = require("klove.draw_stats")
		main.draw_stats_displayed = true

		main.draw_stats:init(main.params.width, main.params.height)
	end

	if DEBUG then
		require("debug_tools")

		if main.params.localuser then
			log.error("---- LOADING LOCALUSER -----")
			require("localuser")
		end
	end

	if main.params.custom_script then
		log.error("---- LOADING CUSTOM SCRIPT %s ----", main.params.custom_script)
		require(main.params.custom_script)

		if custom_script.init then
			custom_script:init()
		end
	end

	if KR_PLATFORM == "ios" then
		local ffi = require("ffi")

		ffi.cdef(" void kr_init_ios(); ")
		ffi.C.kr_init_ios()
	end
end

function love.update(dt)
	if _defer_init_director then
		if _defer_init_director > 0 then
			_defer_init_director = _defer_init_director - 1

			return
		else
			_defer_init_director = nil

			local director = require("director")

			director:init(main.params)

			main.handler = director
		end
	end

	if DEBUG and not main.params.debug and main.params.repl then
		repl_t()
	end

	storage:update(dt)
	main.handler:update(dt)

	if DEBUG and main.params.localuser and localuser_update then
		localuser_update(dt)
	end

	if custom_script and custom_script.update then
		custom_script:update(dt)
	end
end

function love.draw()
	main.handler:draw()

	if main.profiler and main.profiler_displayed then
		main.profiler.draw(main.params.width, main.params.height, F:f("DroidSansMono", 14))
	end

	if main.draw_stats and main.draw_stats_displayed then
		main.draw_stats:draw(main.params.width, main.params.height)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if main.profiler then
		if key == "f1" then
			main.profiler.start()
		elseif key == "f2" then
			main.profiler.stop()
		elseif key == "f3" then
			main.profiler_displayed = not main.profiler_displayed
		elseif key == "f4" then
			main.profiler.flag_l2_shown = not main.profiler.flag_l2_shown
			main.profiler.flag_dirty = true
		end
	end

	if main.draw_stats and key == "f" then
		main.draw_stats_displayed = not main.draw_stats_displayed
	end

	if custom_script and custom_script.keypressed then
		custom_script:keypressed(key, isrepeat)
	end

	if main.params.debug and key == "\\" then
		if not ENABLE_BREAKPOINTS then
			require("mobdebug").on()

			ENABLE_BREAKPOINTS = true
		else
			require("mobdebug").off()

			ENABLE_BREAKPOINTS = false
		end
	end

	main.handler:keypressed(key, isrepeat)
end

function love.keyreleased(key, scancode)
	main.handler:keyreleased(key)
end

function love.textinput(t)
	if main.handler.textinput then
		main.handler:textinput(t)
	end
end

function love.mousepressed(x, y, button, istouch)
	if custom_script and custom_script.mousepressed then
		custom_script:mousepressed(x, y, button, istouch)
	end

	main.handler:mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
	main.handler:mousereleased(x, y, button, istouch)
end

function love.wheelmoved(dx, dy)
	if main.handler.wheelmoved then
		main.handler:wheelmoved(dx, dy, button)
	end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
	if main.handler.touchpressed then
		main.handler:touchpressed(id, x, y, dx, dy, pressure)
	end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
	if main.handler.touchreleased then
		main.handler:touchreleased(id, x, y, dx, dy, pressure)
	end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
	if main.handler.touchmoved then
		main.handler:touchmoved(id, x, y, dx, dy, pressure)
	end
end

function love.gamepadaxis(joystick, axis, value)
	if main.handler.gamepadaxis then
		main.handler:gamepadaxis(joystick, axis, value)
	end
end

function love.gamepadpressed(joystick, button)
	if custom_script and custom_script.gamepadpressed then
		custom_script:gamepadpressed(joystick, button)
	end

	if main.handler.gamepadpressed then
		main.handler:gamepadpressed(joystick, button)
	end
end

function love.gamepadreleased(joystick, button)
	if main.handler.gamepadreleased then
		main.handler:gamepadreleased(joystick, button)
	end
end

function love.joystickpressed(joystick, button)
	if main.handler.joystickpressed then
		main.handler:joystickpressed(joystick, button)
	end
end

function love.joystickreleased(joystick, button)
	if main.handler.joystickreleased then
		main.handler:joystickreleased(joystick, button)
	end
end

function love.joystickadded(joystick)
	if main.handler.joystickadded then
		main.handler:joystickadded(joystick)
	end
end

function love.joystickremoved(joystick)
	if main.handler.joystickremoved then
		main.handler:joystickremoved(joystick)
	end
end

function love.resize(w, h)
	if main.handler.resize then
		main.handler:resize(w, h)
	end
end

function love.focus(focus)
	if main.handler.focus then
		main.handler:focus(focus)
	end
end

function love.quit()
	log.info("Quitting...")
	close_log()

	if main.handler and main.handler.on_quit then
		return main.handler:on_quit()
	else
		return false
	end
end

function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())

		for i = 1, 3 do
			love.math.random()
		end
	end

	if love.load then
		love.load(arg)
	end
	my_data_processing()

	if love.timer then
		love.timer.step()
	end

	local dt = 0
	local starti, updatei, updatef, presi, presf, drawi, drawf
	local sleep_delay = KR_PLATFORM == "xbox" and 0 or 0.001
	local nx, nx_on = love.nx

	while true do
		if love.timer then
			starti = love.timer.getTime()
		end

		if main.profiler and nx and nx.isProfiling() then
			nx_on = true
		end

		if nx_on then
			nx.profilerHeartbeat()
		end

		if love.event then
			love.event.pump()

			for e, a, b, c, d in love.event.poll() do
				if e == "quit" and (not love.quit or not love.quit()) then
					return a or 0
				end

				love.handlers[e](a, b, c, d)
			end
		end

		if love.timer then
			love.timer.step()

			dt = love.timer.getDelta()
		end

		if main.draw_stats then
			updatei = love.timer.getTime()
		end

		if nx_on then
			nx.profilerEnterCodeBlock("update")
		end

		if love.update then
			love.update(dt)
		end

		if nx_on then
			nx.profilerExitCodeBlock("update")
		end

		if main.draw_stats then
			updatef = love.timer.getTime()

			main.draw_stats:update_lap(dt, updatei, updatef)
		end

		if love.window and love.graphics and love.window.isCreated() and love.graphics.isActive() then
			if nx_on then
				nx.profilerEnterCodeBlock("clear")
			end

			love.graphics.clear()
			love.graphics.origin()

			if nx_on then
				nx.profilerExitCodeBlock("clear")
			end

			if love.draw then
				if main.draw_stats then
					drawi = love.timer.getTime()
				end

				if nx_on then
					nx.profilerEnterCodeBlock("draw")
				end

				love.draw()

				if nx_on then
					nx.profilerExitCodeBlock("draw")
				end

				if main.draw_stats then
					drawf = love.timer.getTime()

					main.draw_stats:draw_lap(drawi, drawf)
				end
			end

			collectgarbage("step")

			if main.draw_stats then
				presi = love.timer.getTime()
			end

			if nx_on then
				nx.profilerEnterCodeBlock("present")
			end

			love.graphics.present()

			if nx_on then
				nx.profilerExitCodeBlock("present")
			end

			if main.draw_stats then
				presf = love.timer.getTime()

				main.draw_stats:present_lap(presi, presf)
			end

			if main.handler.limit_fps then
				if nx_on then
					nx.profilerEnterCodeBlock("limit_fps")
				end

				main.handler:limit_fps(starti, sleep_delay)

				if nx_on then
					nx.profilerExitCodeBlock("limit_fps")
				end
			end
		end

		if love.timer and sleep_delay > 0 then
			love.timer.sleep(sleep_delay)
		end

		if KR_OS == "GDK Xbox" then
			while love.graphics and not love.graphics.isActive() do
				log.info("suspended ...")
				love.timer.sleep(0.1)
			end
		end
	end
end

local function get_error_stack(msg, layer)
	return (debug.traceback("Error: " .. tostring(msg), 1 + (layer or 1)):gsub("\n[^\n]+$", ""))
end

local function crash_report(str)
	if KR_PLATFORM == "android" then
		local jnia = require("all.jni_android")

		jnia.crashlytics_log_and_crash(str)
	elseif KR_PLATFORM == "ios" then
		local PS = require("platform_services")

		if PS.services.analytics then
			PS.services.analytics:log_and_crash(str)
		end
	end
end

function love.errhand(msg)
	local last_log_msg = log.last_log_msgs and table.concat(log.last_log_msgs, "")

	msg = tostring(msg)

	local stack_msg = get_error_stack(msg, 2)

	stack_msg = (stack_msg or "") .. "\n" .. last_log_msg

	print(stack_msg)
	log.error(stack_msg)
	close_log()
	pcall(crash_report, stack_msg)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)

		if not success or not status then
			return
		end
	end

	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)

		if love.mouse.hasCursor() then
			love.mouse.setCursor()
		end
	end

	if love.joystick then
		for i, v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end

	if love.audio then
		love.audio.stop()
	end

	love.graphics.reset()

	local font = love.graphics.setNewFont(math.floor(love.window.toPixels(15)))

	love.graphics.setBackgroundColor(89, 157, 220)
	love.graphics.setColor(255, 255, 255, 255)

	local trace = debug.traceback()

	love.graphics.clear(love.graphics.getBackgroundColor())
	love.graphics.origin()

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, msg .. "\n\n")

	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback\n")

			table.insert(err, l)
		end
	end

	if love.nx then
		table.insert(err, "\n\nFree memory:" .. love.nx.allocGetTotalFreeSize() .. "\n")
	end

	table.insert(err, "\n\nLast error msgs\n")
	table.insert(err, last_log_msg)

	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

	local function draw()
		if love.graphics.isActive() then
			local pos = love.window.toPixels(70)

			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
			love.graphics.present()
		end
	end

	while true do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			elseif e == "keypressed" and a == "escape" then
				return
			elseif e == "touchpressed" then
				local name = love.window.getTitle()

				if #name == 0 or name == "Untitled" then
					name = "Game"
				end

				local buttons = {
					"OK",
					"Cancel"
				}
				local pressed = love.window.showMessageBox("Quit " .. name .. "?", "", buttons)

				if pressed == 1 then
					return
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end

-- customization
function my_data_processing()
	local function to_xml(t, level)
		local function indent(l)
			local v = ""
	
			for i = 1, l do
				v = v .. "\t"
			end
	
			return v
		end
	
		local o = ""
	
		if type(t) == "table" then
			if #t > 0 then
				o = o .. indent(level) .. "<array>\n"
	
				for k, v in pairs(t) do
					o = o .. to_xml(v, level + 1)
				end
	
				o = o .. indent(level) .. "</array>\n"
			else
				o = o .. indent(level) .. "<dict>\n"
	
				for k, v in pairs(t) do
					o = o .. indent(level + 1) .. "<key>" .. k .. "</key>\n"
					o = o .. to_xml(v, level + 1)
				end
	
				o = o .. indent(level) .. "</dict>\n"
			end
		elseif type(t) == "boolean" then
			o = o .. indent(level) .. (t and "<true/>" or "<false/>") .. "\n"
		elseif type(t) == "number" then
			o = o .. indent(level) .. "<real>" .. tostring(t) .. "</real>\n"
		elseif type(t) == "string" then
			o = o .. indent(level) .. "<string>" .. tostring(t) .. "</string>\n"
		end
	
		return o
	end
	
	local function to_plist(t, a_name, size)
		local o = ""
	
		o = o .. "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
		o = o .. "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
		o = o .. "<plist version=\"1.0\">\n"
		o = o .. "\t<dict>\n"
		o = o .. "\t\t<key>frames</key>\n"
		o = o .. to_xml(t, 2)
		o = o .. "\t\t<key>metadata</key>\n"
		o = o .. "\t\t<dict>\n"
		o = o .. "\t\t\t<key>format</key>\n"
		o = o .. "\t\t\t<integer>3</integer>\n"
		o = o .. "\t\t\t<key>pixelFormat</key>\n"
		o = o .. "\t\t\t<string>RGBA8888</string>\n"
		o = o .. "\t\t\t<key>premultiplyAlpha</key>\n"
		o = o .. "\t\t\t<false/>\n"
		o = o .. "\t\t\t<key>realTextureFileName</key>\n"
		o = o .. "\t\t\t<string>" .. a_name .. "</string>\n"
		o = o .. "\t\t\t<key>size</key>\n"
		o = o .. "\t\t\t<string>" .. size .. "</string>\n"
		o = o .. "\t\t\t<key>textureFileName</key>\n"
		o = o .. "\t\t\t<string>" .. a_name .. "</string>\n"
		o = o .. "\t\t</dict>\n"
		o = o .. "\t</dict>\n"
		o = o .. "</plist>\n"
	
		return o
	end
	
	local function split_atlas(t)
		local atlases = {}
		local names = {}
		for k, v in pairs(t) do
			if not table.contains(names, v.a_name) then
				table.insert(names, v.a_name)
				local newAtlas = {}
				newAtlas.size = "{" .. v.a_size[1] .. "," .. v.a_size[2] .. "}"
				atlases[v.a_name] = newAtlas
			end
			local atlas = atlases[v.a_name]
			local newTable = {}
			local spriteWidth, spriteHeight, spriteSourceWidth, spriteSourceHeight, spriteOffsetX, spriteOffsetY
			spriteWidth = v.f_quad[3]
			spriteHeight = v.f_quad[4]
			spriteSourceWidth = v.size[1]
			spriteSourceHeight = v.size[2]
			spriteOffsetX = math.ceil(v.trim[1] - (spriteSourceWidth - spriteWidth) / 2)
			spriteOffsetY = math.floor((spriteSourceHeight - spriteHeight) / 2 - v.trim[2])
			newTable.spriteOffset = "{" .. tostring(spriteOffsetX) .. "," .. tostring(spriteOffsetY) .. "}"
			newTable.spriteSize = "{" .. tostring(spriteWidth) .. "," .. tostring(spriteHeight) .. "}"
			newTable.spriteSourceSize = "{" .. tostring(spriteSourceWidth) .. "," .. tostring(spriteSourceHeight) .. "}"
			newTable.textureRect = "{{" .. tostring(v.f_quad[1]) .. "," .. tostring(v.f_quad[2]) .. "}," .. newTable.spriteSize .. "}"
			newTable.textureRotated = v.textureRotated or false
			atlas[k .. ".png"] = newTable
			if v.alias and #v.alias > 0 then
				for i, alias in ipairs(v.alias) do
					atlas[alias .. ".png"] = newTable
				end
			end
		end
		return atlases
	end
	
	local fs = love.filesystem
	local inputPath = "atlas/input/"
	local outputPath = "atlas/output/"
	local toPlist = true
	if not fs.exists(inputPath) or not fs.exists(outputPath) then
		toPlist = nil
	end
	local inputFiles
	if toPlist then
		inputFiles = fs.getDirectoryItems(inputPath)
		if not inputFiles or #inputFiles == 0 then
			toPlist = nil
		end
	end
	if toPlist then
		inputFiles = table.filter(inputFiles, function(k, v)
			return string.match(v, "[^.]-%.lua$")
		end)
		if not inputFiles or #inputFiles == 0 then
			toPlist = nil
		end
	end
	if toPlist then
		for i, v in ipairs(inputFiles) do
			local inputFile = inputPath .. v
			if fs.isFile(inputFile) then
				local chunk = fs.load(inputFile)
				local atlases = split_atlas(chunk())
				for a_name, atlas in pairs(atlases) do
					local size = atlas.size
					atlas.size = nil
					local startPos = string.find(a_name, "%.png$")
					if not startPos then
						startPos = string.find(a_name, "%.dds$")
						if not startPos then
							startPos = string.find(a_name, "%.pkm$")
							if not startPos then
								startPos = string.find(a_name, "%.pkm.lz4$")
								if not startPos then
									break
								end
							end
						end
					end
					local fileName = outputPath .. string.sub(a_name, 1, startPos - 1) .. ".plist"
					local data = to_plist(atlas, a_name, size)
					local success, message = fs.write(fileName, data)
					if not success then
						log.error("file not created: " .. message)
					end
				end
			end
		end
	end
	
	inputPath = "animations/immutable/"
	outputPath = "animations/alterable/"
	local removeAnimations = true
	if not fs.exists(inputPath) or not fs.exists(outputPath) then
		removeAnimations = nil
	end
	local outputFiles
	if removeAnimations then
		inputFiles = fs.getDirectoryItems(inputPath)
		outputFiles = fs.getDirectoryItems(outputPath)
		if not inputFiles or #inputFiles == 0 or not outputFiles or #outputFiles == 0 then
			removeAnimations = nil
		end
	end
	if removeAnimations then
		inputFiles = table.filter(inputFiles, function(k, v)
			return string.match(v, "[^.]-%.lua$")
		end)
		outputFiles = table.filter(outputFiles, function(k, v)
			return string.match(v, "[^.]-%.lua$")
		end)
		if not inputFiles or #inputFiles == 0 or not outputFiles or #outputFiles == 0 then
			removeAnimations = nil
		end
	end
	local outputFile
	if removeAnimations then
		outputFile = outputPath .. outputFiles[1]
		if not fs.isFile(outputFile) then
			removeAnimations = nil
		end
	end
	
	local function value_to_string(t, level, key)
		local function indent(l)
			local v = ""
	
			for i = 1, l do
				v = v .. "\t"
			end
	
			return v
		end
	
		local o = indent(level) .. (key and (key .. " = ") or "")
	
		if type(t) == "table" then
			if #t > 0 then
				o = o .. "{\n"
	
				for i, v in ipairs(t) do
					o = o .. value_to_string(v, level + 1)
				end
	
				o = o .. indent(level) .. "},\n"
			else
				o = o .. "{\n"
	
				for k, v in pairs(t) do
					o = o .. value_to_string(v, level + 1, k)
				end
	
				o = o .. indent(level) .. "},\n"
			end
		elseif type(t) == "boolean" then
			o = o .. (t and "true" or "false") .. ",\n"
		elseif type(t) == "number" then
			o = o .. tostring(t) .. ",\n"
		elseif type(t) == "string" then
			o = o .. "\"" .. t .. "\",\n"
		else
			return ""
		end
	
		return o
	end
	
	if removeAnimations then
		local chunk = fs.load(outputFile)
		local output_animations = chunk()
		local animations = {}
		for i, v in ipairs(inputFiles) do
			local inputFile = inputPath .. v
			if fs.isFile(inputFile) then
				local chunk = fs.load(inputFile)
				table.merge(animations, chunk())
			end
		end
		for key, value in pairs(output_animations) do
			for k, v in pairs(animations) do
				if key == k then
					output_animations[key] = nil
					break
				end
			end
		end
	
		local o = "return {\n"
		for k, v in pairs(output_animations) do
			o = o .. value_to_string(v, 1, k)
		end
		o = o .. "}"
		local success, message = fs.write(outputFile, o)
		if not success then
			log.error("file not created: " .. message)
		end
	end
	
	inputPath = "dds2pkm_lz4/"
	local dds2pkm = true
	if not fs.exists(inputPath) then
		dds2pkm = nil
	end
	if dds2pkm then
		inputFiles = fs.getDirectoryItems(inputPath)
		if not inputFiles or #inputFiles == 0 then
			dds2pkm = nil
		end
	end
	if dds2pkm then
		inputFiles = table.filter(inputFiles, function(k, v)
			return string.match(v, "[^.]-%.lua$")
		end)
		if not inputFiles or #inputFiles == 0 then
			dds2pkm = nil
		end
	end
	if dds2pkm then
		for i, v in ipairs(inputFiles) do
			local inputFile = inputPath .. v
			if fs.isFile(inputFile) then
				local chunk = fs.load(inputFile)
				local atlas = chunk()
				local o = "return {\n"
				local keys = {}
				for k, v in pairs(atlas) do
					table.insert(keys, k)
				end
				table.sort(keys, function(e1, e2)
					return tostring(e1) < tostring(e2)
				end)
				for i, k in ipairs(keys) do
					local v = atlas[k]
					v.a_name = string.gsub(v.a_name, "%.dds$", "%.pkm.lz4", 1)
					o = o .. value_to_string(v, 1, "[\"" .. k .. "\"]")
				end
				o = o .. "}"
				local success, message = fs.write(inputFile, o)
				if not success then
					log.error("file not created: " .. message)
				end
			end
		end
	end
end