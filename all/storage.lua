-- chunkname: @./all/storage.lua

local log = require("klua.log"):new("storage")
local km = require("klua.macros")
local FS = love.filesystem
local persistence = require("klua.persistence")
local signal = require("hump.signal")

require("klua.string")

local GS = require("game_settings")
local features = require("features")

require("version")

local sio = require(features.storage_io or "storage_io_generic")
local storage = {}

storage.active_slot_idx = nil
storage.slot = nil
storage.SETTINGS_FILE = "settings.lua"
storage.GLOBAL_FILE = "global.lua"
storage.CACHE_FILE = "cache.lua"
storage.SLOT_FILE_FMT = "slot_%d.lua"

local SETTINGS_PARAMS = {
	"fps",
	"fullscreen",
	"fullscreentype",
	"display",
	"height",
	"texture_size",
	"volume_fx",
	"volume_music",
	"volume_vibration",
	"vsync",
	"width",
	"msaa",
	"locale",
	"large_pointer",
	"highdpi",
	"pause_on_switch",
	"key_pow_1",
	"key_pow_2",
	"key_pow_3",
	"key_hero_1",
	"key_hero_2",
	"key_hero_3",
	"key_wave",
	"key_wave_info",
	"key_show_noti",
	"key_pointer",
	"key_up",
	"key_down",
	"key_left",
	"key_right",
	"joy_pointer_power",
	"joy_pointer_speed",
	"joy_pointer_threshold",
	"joy_pointer_accel",
	"joy_pointer_accel_max",
	"joy_pointer_accel_timeout",
	"joy_rate_limit_delay",
	"joy_rate_limit_delay_repeat",
	"joy_y_axis_factor",
	"nav_key_step",
	"nav_key_step_alt",
	"player_customized",
	"show_settings_dialog"
}
local SLOT_ADDITIONAL_DATA = {
	gems = 0,
	bag = {}
}
local SLOT_MANDATORY_KEYS = {
	"levels",
	"upgrades",
	"heroes"
}

if GS.default_towers then
	table.insert(SLOT_MANDATORY_KEYS, "towers")
end

if GS.default_items then
	table.insert(SLOT_MANDATORY_KEYS, "items")
end

if GS.claimable_achievements then
	table.insert(SLOT_MANDATORY_KEYS, "achievements_claimed")
end

function storage:deserialize_lua(data)
	if not data then
		log.error("Error deserializing. data is nil")

		return nil
	end

	local chunk, err = loadstring(data)

	if not chunk then
		log.error("Error loading chunk. %s", err)

		return nil
	end

	local env = {}

	setfenv(chunk, env)

	local ok, result = pcall(chunk)

	if not ok then
		log.error("Error parsing chunk. %s", tostring(result))

		return nil
	end

	return result
end

function storage:serialize_lua(data_table)
	return persistence.serialize_to_string(data_table)
end

function storage:load_lua(filename, force_load)
	local ok, data_table = sio:load_file(filename, force_load)

	if not ok or not data_table then
		return nil
	end

	return data_table
end

function storage:write_lua(filename, data_table, commit)
	local ok = sio:write_file(filename, data_table)

	if not ok then
		log.error("Error writing %s", filename)
	end

	if ok and commit then
		sio:commit()
	end

	return ok
end

function storage:remove(filename, commit)
	local ok = sio:remove_file(filename)

	if ok and commit then
		sio:commit()
	end

	return ok
end

function storage:is_busy()
	return sio:is_busy()
end

function storage:update(dt)
	if sio.update then
		sio:update(dt)
	end
end

function storage:load_settings()
	local input = self:load_lua(self.SETTINGS_FILE)

	if not input or not type(input) == "table" then
		return {}
	else
		return input
	end
end

function storage:save_settings(data_table, should_sync)
	local out = {}

	for _, p in pairs(SETTINGS_PARAMS) do
		out[p] = data_table[p]
	end

	out.timestamp = os.time()

	local success = self:write_lua(self.SETTINGS_FILE, out, should_sync)

	if success then
		signal.emit("settings-saved", should_sync)
	else
		log.error("error saving settings")
	end

	return success
end

function storage:load_global()
	local input = self:load_lua(self.GLOBAL_FILE)

	if not input or not type(input) == "table" then
		input = {}
	end

	return input
end

function storage:save_global(data_table, should_sync)
	local result = self:write_lua(self.GLOBAL_FILE, data_table, should_sync)

	return result
end

function storage:load_cache()
	local input = self:load_lua(self.CACHE_FILE)

	if not input or not type(input) == "table" then
		input = {}
	end

	return input
end

function storage:save_cache(data_table, should_sync)
	local result = self:write_lua(self.CACHE_FILE, data_table, should_sync)

	return result
end

function storage:load_slot(idx, force)
	idx = idx or self.active_slot_idx

	if not idx then
		log.error("slot idx is nil")

		return nil
	end

	local input = self:load_lua(string.format(self.SLOT_FILE_FMT, idx), force)

	if not input or not type(input) == "table" then
		return nil
	end

	for _, v in pairs(SLOT_MANDATORY_KEYS) do
		if not input[v] then
			log.error("loaded slot %s has invalid data for %s. removing.", idx, v)
			self:delete_slot(idx)

			return nil
		end
	end

	for k, v in pairs(SLOT_ADDITIONAL_DATA) do
		if not input[k] then
			input[k] = v
		end
	end

	local tpl = self:new_slot(idx)
	local sets = {}

	if tpl.heroes and tpl.heroes.selected then
		table.insert(sets, {
			"heroes",
			tpl.heroes.selected
		})
	end

	if tpl.towers and tpl.towers.selected then
		table.insert(sets, {
			"towers",
			tpl.towers.selected
		})
	end

	if tpl.items and tpl.items.selected then
		table.insert(sets, {
			"items",
			tpl.items.selected
		})
	end

	for _, set in pairs(sets) do
		local sk, sv = unpack(set)

		if not input[sk].status and tpl[sk].status then
			input[sk].status = table.deepclone(tpl[sk].status)
		end

		if input[sk].status then
			for k, v in pairs(tpl[sk].status) do
				if not input[sk].status[k] then
					log.warning("adding missing %s %s to slot", sk, k)

					input[sk].status[k] = table.deepclone(v)
				end
			end
		end

		if not input[sk].selected then
			input[sk].selected = table.deepclone(sv)
		else
			for _, k in pairs(type(input[sk].selected) == "table" and input[sk].selected or {
				input[sk].selected
			}) do
				if not tpl[sk].status[k] then
					log.warning("selected %s %s is not part of slot_template... resetting", sk, k)

					input[sk].selected = table.deepclone(sv)

					break
				end
			end
		end
	end

	if input.heroes and input.heroes.status then
		for kh, vh in pairs(input.heroes.status) do
			if vh.skills and tpl.heroes.status[kh] then
				for kst, vst in pairs(tpl.heroes.status[kh].skills) do
					if not vh.skills[kst] then
						log.warning("adding missing skill %s to hero %s in slot", kst, kh)

						vh.skills[kst] = kst == "ultimate" and GS.default_hero_ultimate_level or 0
					end
				end

				for ks, vs in pairs(vh.skills) do
					local min_value = ks == "ultimate" and GS.default_hero_ultimate_level or 0
					local max_value = ks == "ultimate" and GS.max_hero_ultimate_level or 3

					if type(vs) ~= "number" or vs < min_value or max_value < vs then
						log.warning("hero %s skill %s outside valid range... patching it to %s.", kh, ks, min_value)

						vh.skills[ks] = min_value
					end
				end
			end
		end
	end

	if input.heroes and GS.default_team then
		if not input.heroes.team then
			input.heroes.team = table.deepclone(GS.default_team)
		else
			for _, kh in pairs(input.heroes.team) do
				if not tpl.heroes.status[kh] then
					log.error("hero %s in team is not part of the slot_template... resetting.", kh)

					input.heroes.team = table.deepclone(GS.default_team)

					break
				end
			end
		end
	end

	return input
end

function storage:save_slot(data_table, idx, should_sync)
	idx = idx or self.active_slot_idx

	if not idx then
		log.error("slot idx is nil")

		return nil
	end

	if data_table then
		data_table.version_string = version.string
	end

	log.debug("saving slot:%s should sync:%s", idx, should_sync)

	local fn = string.format(self.SLOT_FILE_FMT, idx)
	local success = self:write_lua(fn, data_table, should_sync)

	if success then
		signal.emit("slot-saved", idx, should_sync)
	else
		log.error("error saving slot %s", idx)
	end

	return success
end

function storage:delete_slot(idx)
	if not idx then
		log.error("slot idx is nil")

		return nil
	end

	local success = storage:remove(string.format(self.SLOT_FILE_FMT, idx), true)

	if success then
		signal.emit("slot-deleted", idx)
	end

	return success
end

function storage:new_slot(idx)
	local template

	if DEBUG and idx == 1 then
		template = require("data.slot_template_debug")
	else
		template = require("data.slot_template")
	end

	template = table.deepclone(template)

	return template
end

function storage:create_slot(idx)
	local template = storage:new_slot(idx)

	storage:save_slot(template, idx, true)

	return storage:load_slot(idx)
end

function storage:set_active_slot(idx)
	if not idx then
		log.error("slot idx is nil")

		return
	end

	if not self:load_slot(idx) then
		log.error("slot %s must exist before setting it as active", idx)

		return
	end

	self.active_slot_idx = idx

	signal.emit("slot-changed", idx)
end

function storage:get_settings_name()
	return storage.SETTINGS_FILE
end

function storage:get_slot_name(idx)
	return string.format(self.SLOT_FILE_FMT, idx)
end

function storage:get_slot_progress(slot)
	if not slot then
		log.paranoid("slot is nil")

		return -1
	end

	local total = 0

	for i = 1, GS.last_level do
		local v = slot.levels[i]

		if v then
			total = total + (v.stars or 0) + (v[GAME_MODE_HEROIC] and 1 or 0) + (v[GAME_MODE_IRON] and 1 or 0)
		end
	end

	if slot.last_victory then
		local vidx = slot.last_victory.level_idx
		local vmode = slot.last_victory.level_mode
		local vstars = slot.last_victory.stars or 0
		local ll = slot.levels[vidx]
		local lstars = ll and ll.stars or 0

		if ll and ll[vmode] then
			if vmode == GAME_MODE_CAMPAIGN and lstars < vstars then
				total = total - lstars + vstars
			end
		else
			total = total + vstars
		end
	end

	total = km.clamp(0, GS.last_level * 5, total)

	log.paranoid("slot progress %s\nlevels:%s\nlast_victory:%s", total, getfulldump(slot.levels), getfulldump(slot.last_victory or {}))

	return total
end

function storage:get_slot_stats(slot)
	local num_progress = storage:get_slot_progress(slot)
	local num_heroic = 0
	local num_iron = 0

	for _d, l in pairs(slot.levels) do
		num_heroic = num_heroic + (l[2] and type(l[2]) == "number" and 1 or 0)
		num_iron = num_iron + (l[3] and type(l[3]) == "number" and 1 or 0)
	end

	return num_progress, num_heroic, num_iron
end

function storage:get_challenge_progress(slot)
	if not slot or not slot.challenges_completed then
		return 0
	end

	local total = 0

	for k, v in pairs(slot.challenges_completed) do
		total = total + (v.stars or 0)
	end

	return total
end

function storage:get_best_slot(slot_a, slot_b)
	if not slot_a and not slot_b then
		return nil
	end

	if not slot_a then
		return slot_b
	end

	if not slot_b then
		return slot_a
	end

	local prog_a = self:get_slot_progress(slot_a)
	local prog_b = self:get_slot_progress(slot_b)
	local ch_a = self:get_challenge_progress(slot_a)
	local ch_b = self:get_challenge_progress(slot_b)
	local gems_a = slot_a.gems or 0
	local gems_b = slot_b.gems or 0
	local crowns_a = slot_a.crowns or 0
	local crowns_b = slot_b.crowns or 0

	if prog_a < prog_b then
		return slot_b
	elseif prog_b < prog_a then
		return slot_a
	end

	if ch_a < ch_b then
		return slot_b
	elseif ch_b < ch_a then
		return slot_a
	end

	if gems_a < gems_b then
		return slot_b
	elseif gems_b < gems_a then
		return slot_a
	end

	if crowns_a < crowns_b then
		return slot_b
	elseif crowns_b < crowns_a then
		return slot_a
	end

	return slot_a
end

function storage:restore_slot(data)
	if not data or type(data) ~= "table" then
		log.error("restore data is invalid :%s", data)

		return nil
	end

	if data.game ~= KR_GAME then
		log.error("restore data is not for this game")

		return nil
	end

	local only_gems = true

	for k, v in pairs(data) do
		if k ~= "game" and k ~= "restore_gems" then
			only_gems = false

			break
		end
	end

	local new_slot = storage:new_slot(0)

	if data.restore_achievements then
		new_slot.achievements = new_slot.achievements or {}

		if GS.claimable_achievements then
			new_slot.achievements_claimed = new_slot.achievements_claimed or {}

			for _, k in pairs(data.restore_achievements) do
				table.insert(new_slot.achievements_claimed, k)

				new_slot.achievements[k] = true
			end
		else
			for _, k in pairs(data.restore_achievements) do
				new_slot.achievements[k] = true
			end
		end
	end

	if data.restore_levels and data.restore_levels.last_unlocked_index then
		local l = {}
		local dif = data.restore_levels.difficulty or DIFFICULTY_NORMAL
		local stars = data.restore_levels.stars or 3

		for i = 1, math.min(data.restore_levels.last_unlocked_index, GS.last_level) do
			local difhi = dif

			if GS.campaign_only_levels and table.contains(GS.campaign_only_levels, i) then
				difhi = nil
			end

			l[i] = {
				dif,
				difhi,
				difhi,
				stars = stars
			}
		end

		if data.restore_levels.last_unlocked_index < GS.last_level then
			l[data.restore_levels.last_unlocked_index + 1] = {}
		end

		new_slot.levels = l
		new_slot.difficulty = dif
	end

	if data.restore_hero_levels and not GS.hero_xp_ephemeral then
		for k, v in pairs(data.restore_hero_levels) do
			if new_slot.heroes.status[k] then
				new_slot.heroes.status[k].xp = v < 2 and 0 or GS.hero_xp_thresholds[km.clamp(2, 10, v) - 1]
			else
				log.error("could not find hero %s", k)
			end
		end
	end

	if data.restore_gems then
		new_slot.gems = data.restore_gems
	end

	return new_slot, only_gems
end

function storage:import_plist(filename)
	local plist = require("klua.plist")
	local storage_mappings = require("storage_mappings")
	local global = storage:load_global()

	if filename and self:patch_applied(global, filename) then
		global.plist_imported = version.string

		storage:save_global(global)

		return
	elseif global.plist_imported then
		log.debug("plist was already imported. skipping")

		return
	end

	local fs

	if filename == "NSUserDefaults" then
		log.info("importing plist from nsuserdefaults")

		local function get_nsuserdefaults_data()
			local ffi = require("ffi")

			ffi.cdef(" size_t kr_get_nsuserdefaults_data(char* buf, size_t bufSize); ")

			local buf_max_size = 524288
			local buffer = ffi.new("char[?]", buf_max_size)
			local buffer_length = ffi.C.kr_get_nsuserdefaults_data(buffer, buf_max_size)
			local s = ffi.string(buffer, buffer_length)

			return s
		end

		local ok, result = pcall(get_nsuserdefaults_data)

		if not ok then
			log.error("error loading plist from ns_userdefaults: %s", tostring(result))

			return
		end

		fs = result
	else
		log.info("importing plist from %s", filename)

		local f = io.open(filename, "r")

		if not f then
			log.debug("plist file could not be found at %s", filename)

			return
		end

		fs = f:read("*a")

		f:close()
	end

	local p = plist:parse(fs)

	if not p then
		log.error("error parsing plist file %s", filename)

		return
	end

	if KR_PLATFORM == "android" then
		if KR_GAME == "kr1" and p.KingdomRush then
			p = p.KingdomRush
		elseif KR_GAME == "kr2" and p.KingdomRushFrontiers then
			p = p.KingdomRushFrontiers
		elseif KR_GAME == "kr3" and p.KingdomRushOrigins then
			p = p.KingdomRushOrigins
		end
	end

	for i = 1, 3 do
		local src_slot_name = string.format("slot_%i", i - 1)
		local src_slot = p[src_slot_name]

		if not src_slot then
			log.error("Slot %s could not be found", src_slot_name)
		else
			local dst_slot = self:load_slot(i) or self:create_slot(i)

			storage_mappings:append_slot(src_slot, dst_slot)
			self:save_slot(dst_slot, i)
		end
	end

	local src_global = p.global_data

	if not src_global then
		log.error("Global data could not be found in plist file %s", filename)
	else
		storage_mappings:append_global(src_global, global)
	end

	local src_pp = p.privacy_policy_token

	if not src_pp then
		log.error("Privacy Policy token data could not be found in plist file %s", filename)
	else
		storage_mappings:append_pp_token(src_pp, global)
	end

	global.plist_imported = version.string

	storage:save_global(global)
	log.info("plist import finished")
end

function storage:patch_applied(global, filename)
	if global and global.plist_imported then
		if table.contains({
			"kr2-phone-3.0.19",
			"kr2-phone-3.0.20",
			"kr2-phone-3.0.21",
			"kr2-phone-3.0.22",
			"kr2-phone-3.0.23"
		}, global.plist_imported) then
			for i = 1, 3 do
				local slot = self:load_slot(i)

				if slot and slot.heroes and slot.heroes.status then
					local s = slot.heroes.status

					if s.hero_voodoowitch and s.hero_voodoo_witch then
						log.info("patching hero_voodoowitch xp")

						s.hero_voodoo_witch.xp = math.max(s.hero_voodoowitch.xp, s.hero_voodoo_witch.xp)
						s.hero_voodoowitch = nil
					end

					if s.hero_vanhelsing and s.hero_van_helsing then
						log.info("patching hero_vanhelsing xp")

						s.hero_van_helsing.xp = math.max(s.hero_vanhelsing.xp, s.hero_van_helsing.xp)
						s.hero_vanhelsing = nil
					end
				end

				self:save_slot(slot, i)
			end
		elseif table.contains({
			"kr3-phone-4.0.09",
			"kr3-phone-4.0.08",
			"kr3-phone-4.0.07"
		}, global.plist_imported) then
			for i = 1, 3 do
				local slot = self:load_slot(i)

				if slot and slot.heroes and slot.heroes.selected and slot.heroes.selected == "hero_gyro" then
					log.info("patching hero_gyro as hero_wilbur")

					slot.heroes.selected = "hero_wilbur"
				end

				self:save_slot(slot, i)
			end
		end
	end
end

function storage:import_dotnet(dirname)
	if KR_GAME ~= "kr1" and KR_PLATFORM ~= "desktop" then
		log.debug("only for legacy kr1-desktop. skipping")

		return
	end

	local global = storage:load_global()

	if global.dotnet_imported then
		log.debug("dotnet was already imported. skipping")

		return
	end

	log.info("importing dotnet from dir %s", dirname)

	local parser = require("dotnet_slot_parser")

	for i = 1, 3 do
		local src_name = string.format("%s/slot%i.data", dirname, i)

		log.debug("importing %s", src_name)

		local f = io.open(src_name, "rb")

		if not f then
			log.debug("dotnet slot could not be found at %s", src_name)
		else
			local fs = f:read("*a")

			f:close()

			local p, err = parser:parse(fs)

			if not p then
				log.error("error parsing dotnet slot file %s. %s", src_name, err)
			else
				local slot = self:load_slot(i, true) or self:create_slot(i)

				slot = table.deepmerge(slot, p)

				self:save_slot(slot, i, true)

				global.dotnet_imported = version.string
			end
		end
	end

	storage:save_global(global, true)
	log.info("dotnet import finished")
end

return storage
