-- chunkname: @./all/platform_services_xbox.lua

local log = require("klua.log"):new("platform_services_xbox")
local PSU = require("platform_services_utils")
local signal = require("hump.signal")
local storage = require("storage")
local xbox = {}

xbox.can_be_paused = false
xbox.update_interval = 10
xbox.call_default_update = true
xbox.essential = true
xbox.inited = false
xbox.lib = nil
xbox.prq = nil
xbox.JOYSTICK_RECONFIGURE_TIMEOUT = 2
xbox.no_joystick_present = true
xbox.excluded_settings_keys = {
	"fps",
	"fullscreen",
	"height",
	"highdpi",
	"large_pointer",
	"msaa",
	"pause_on_switch",
	"texture_size",
	"vsync",
	"width"
}
xbox.sync_times = {}
xbox.last_sync = nil
xbox.active_rids = {}
xbox.active_rids.do_signin_rid = nil
xbox.active_rids.sync_slots_rid = nil
xbox.signal_handlers = {
	achievements = {
		["got-achievement"] = function(ach_id)
			xbox:unlock_achievement(ach_id)
		end
	},
	cloudsave = {
		["focus-changed"] = function(focus)
			xbox:focus_changed(focus)
		end,
		["slot-saved"] = function(idx, should_sync)
			if should_sync then
				xbox:push_slot(idx)
			end
		end,
		["slot-deleted"] = function(idx)
			xbox:delete_slot(idx)
		end,
		["settings-saved"] = function(should_sync)
			if should_sync then
				xbox:push_settings()
			end
		end
	}
}

local ffi = require("ffi")

ffi.cdef("//const char* xbox_get_locale();\n\nbool xbox_initialize(const char* scid_c);\nvoid xbox_shutdown();\n\nint  xbox_get_request_status(int req_id);\nint  xbox_get_status();\nvoid xbox_delete_request(int req_id);\nconst char* xbox_get_cached_payload(int req_id);\n\nint  xbox_create_request_auth();\nint  xbox_get_gamertag(char* buf, int bufSize);\n\nint  xbox_create_request_ach_list();\nint  xbox_create_request_ach_get(char* id);   // returns progressState (0:unk, 1:achieved, 2:not started, 3:in progress)\nint  xbox_create_request_ach_update(char* id, int percent_complete);\n\nint  xbox_create_request_cloud_sync(const char* names_list);\nint  xbox_create_request_cloud_push(const char* name, const char* data);\nint  xbox_create_request_cloud_delete(const char* name);\nconst char* xbox_cloud_get_cached(const char* name);\ndouble xbox_cloud_get_last_sync(void);\nvoid xbox_focus_changed(bool active);\n\n")

function xbox:init(name, params)
	if self.inited then
		log.debug("service %s already initialized", name)
	else
		if params.required_libs then
			for _, ln in pairs(params.required_libs) do
				log.debug("loading required library: %s", ln)
				PSU:load_library(ln, ffi)
			end
		end

		self.lib = PSU:load_library(params.lib_name, ffi)

		if not self.lib then
			log.error("XBox library %s could not be loaded", params.lib_name)

			return false
		end

		do
			local ids = require("data.platform_services_ids")

			if not ids or not ids.xbox then
				log.error("data.platform_services_ids for gps not found")

				return nil
			end

			self.ids = ids.xbox
		end

		self.prq = PSU:new_prq()

		if params.scid and params.lib_name == "kxsapi" then
			self.inited = self.lib.xbox_initialize(params.scid)

			if not self.inited then
				log.error("Error initializing " .. params.lib_name)

				return false
			end

			self.native_inited = true
		else
			self.inited = true
		end
	end

	if self.signal_handlers and self.signal_handlers[name] then
		for sn, fn in pairs(self.signal_handlers[name]) do
			log.debug("registering signal %s", sn)
			signal.register(sn, fn)
		end
	end

	if not self.names then
		self.names = {}
	end

	if not table.contains(self.names, name) then
		table.insert(self.names, name)
	end

	if params.signin_on_init then
		self:do_signin()
	end

	return true
end

function xbox:shutdown(name)
	log.debug("Shutting down %s", name)

	if self.inited then
		if self.signal_handlers and self.signal_handlers[name] then
			for sn, fn in pairs(self.signal_handlers[name]) do
				log.debug("removing signal %s", sn)
				signal.remove(sn, fn)
			end
		end

		if self.native_inited then
			self.lib.xbox_shutdown()
		end
	end

	self.names = nil
	self.lib = nil
	self.inited = false
end

function xbox:update(dt)
	if self.delayed_focus_changed then
		local e = self.delayed_focus_changed[1]
		local time = os.time()

		if e and time >= e.ts then
			log.debug("triggering delayed focus change %s %s", e.ts, e.active)
			table.remove(self.delayed_focus_changed, 1)
			self.lib.xbox_focus_changed(e.active)
		end
	end
end

function xbox:get_status()
	if not self.inited then
		return nil
	end

	local result = self.lib.xbox_get_status()

	if result == 1 then
		return true
	else
		return nil
	end
end

function xbox:focus_changed(active)
	if self.inited then
		if KR_OS == "GDK Desktop" then
			self.delayed_focus_changed = self.delayed_focus_changed or {}

			table.insert(self.delayed_focus_changed, {
				ts = os.time() + 0.15,
				active = active
			})
		else
			self.lib.xbox_focus_changed(active)
		end
	end
end

function xbox:get_pending_requests()
	return self.prq
end

function xbox:get_request_status(rid)
	local result = self.lib.xbox_get_request_status(rid)

	log.paranoid("xbox_get_request_status service:%s rid:%s result:%s", self.name, rid, result)

	return result
end

function xbox:cancel_request(rid)
	log.debug("cancelling request %s", rid)

	if not rid then
		log.paranoid("xbox_cancel_request:%s rid:%s not found", self.name, rid)

		return
	end

	self.prq:remove(rid)
	self.lib.xbox_delete_request(rid)

	for k, v in pairs(self.active_rids) do
		if v == rid then
			self.active_rids[k] = nil
		end
	end
end

function xbox:late_update(dt)
	self:update_joysticks(dt)
end

function xbox:do_signin()
	if self:get_status() then
		return
	end

	local arid = self.active_rids.do_signin_rid

	if arid and self.prq:contains(arid) then
		log.debug("do_signin in progress with rid: %s", arid)

		return arid
	end

	local function cb_update_auth_request(status, req)
		xbox.active_rids.do_signin_rid = nil

		if not self.prq:contains(req.id) then
			return
		end

		log.debug("do_signin request finished. status:%s", status)
		signal.emit(SGN_PS_AUTH_FINISHED, "auth", status == 0, status, self:get_gamertag())
	end

	xbox.active_rids.do_signin_rid = nil

	local id = self.lib.xbox_create_request_auth()

	self.active_rids.do_signin_rid = id

	self.prq:add(id, "xbox_create_request_auth", cb_update_auth_request, -1)
	log.debug("do_signin started with rid: %s", arid)

	return id
end

function xbox:auth()
	return
end

function xbox:deauth()
	return
end

function xbox:is_auth()
	return self:get_status()
end

function xbox:get_gamertag()
	if not self:get_status() then
		return nil
	end

	local buf_max = 1024
	local buf = ffi.new("char[?]", buf_max)
	local buf_len = self.lib.xbox_get_gamertag(buf, buf_max)

	if buf == nil or buf_len == 0 then
		return nil
	end

	local s = ffi.string(buf, buf_len)

	if s == nil or s == "" then
		return nil
	end

	return s
end

function xbox:unlock_achievement(ach_id)
	local function cb_update_achievement_unlock_request(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		if status == 0 then
			log.debug("Unlocked achievement %s", ach_id)
		end
	end

	local xbox_id = self.ids.achievements[ach_id]

	if not xbox_id then
		log.error("xbox achievement id missing for %s", ach_id)

		return
	end

	local c_str = ffi.new("char[?]", #xbox_id + 1)

	ffi.copy(c_str, xbox_id)

	local rid = self.lib.xbox_create_request_ach_update(c_str, 100)

	self.prq:add(rid, "xbox_create_request_ach_update", cb_update_achievement_unlock_request)

	return rid
end

function xbox:show_achievements()
	log.info("unsupported by xbox")
end

function xbox:get_sync_status()
	if self.last_sync ~= self.lib.xbox_cloud_get_last_sync() then
		self.sync_times.slots = false
	end

	return self.sync_times
end

function xbox:sync_slots()
	local function cb_sync_slots(status, req)
		xbox.active_rids.sync_slots_rid = nil

		if not self.prq:contains(req.id) then
			return
		end

		local success

		if status == 0 then
			success = true
			self.last_sync = self.lib.xbox_cloud_get_last_sync()
			self.sync_times.slots = os.time()

			for i = 1, 3 do
				local lslot = storage:load_slot(i)
				local rdata = self.lib.xbox_cloud_get_cached(storage:get_slot_name(i))
				local rndata = rdata ~= nil and ffi.string(rdata) or nil

				log.paranoid("  rndata for slot %s:%s", i, rndata)

				local rslot = rndata ~= nil and storage:deserialize_lua(rndata) or nil

				if rslot then
					log.paranoid("  rslot:%s", rslot)
					log.paranoid("  lslot:%s", lslot)

					if storage:get_best_slot(lslot, rslot) == rslot then
						log.debug("remote slot %s is further along", i)
						storage:save_slot(rslot, i)
					else
						log.debug("local slot %s is further along", i)
					end
				end
			end

			local rdata = self.lib.xbox_cloud_get_cached(storage:get_settings_name())
			local rndata = rdata ~= nil and ffi.string(rdata) or nil

			log.paranoid("  rndata:%s", rndata)

			local rsettings = rndata ~= nil and storage:deserialize_lua(rndata) or nil
			local lsettings = storage:load_settings()

			if rsettings then
				local rt = rsettings.timestamp or 0
				local lt = lsettings.timestamp or 0

				log.debug("settings timestamps. remote:%s local:%s", rt, lt)

				if lt < rt then
					log.debug("remote setings are newer. merging them.")

					for k, v in pairs(rsettings) do
						if table.contains(xbox.excluded_settings_keys, k) then
							log.debug("  excluding remote setting %s", k)
						else
							lsettings[k] = rsettings[k]
						end
					end

					storage:save_settings(lsettings)
				end
			end
		else
			success = false
			self.sync_times.slots = false
		end

		signal.emit(SGN_PS_SYNC_SLOTS_FINISHED, "cloudsave", success, req.id, status)
		signal.emit(SGN_PS_SYNC_SETTINGS_FINISHED, "cloudsave", success, req.id, status)
	end

	local arid = self.active_rids.sync_slots_rid

	if arid and self.prq:contains(arid) then
		log.debug("sync_slots in progress with rid: %s", arid)

		return arid
	end

	log.debug("synchronizing all slots...")

	self.active_rids.sync_slots_rid = nil

	local names_list = {
		storage:get_slot_name(1),
		storage:get_slot_name(2),
		storage:get_slot_name(3),
		storage:get_settings_name()
	}
	local names = table.concat(names_list, ",")
	local rid = self.lib.xbox_create_request_cloud_sync(names)

	if rid < 0 then
		log.error("error creating request to sync slots")

		return nil
	else
		self.active_rids.sync_slots_rid = rid

		self.prq:add(rid, "sync_slots", cb_sync_slots, -1)

		return rid
	end
end

function xbox:push_slot(idx, overwrite)
	local function cb_push_slot(status, req)
		if self.prq:contains(req.id) then
			local success = status == 0

			signal.emit(SGN_PS_PUSH_SLOT_FINISHED, "cloudsave", success, req.id, req.slot_idx)
		end
	end

	local slot = storage:load_slot(idx)

	if not slot then
		return nil
	end

	local progress = storage:get_slot_progress(slot)
	local slot_data = storage:serialize_lua(slot)

	log.debug("pushing slot:%s progress:%s", idx, progress)

	local rid = self.lib.xbox_create_request_cloud_push(storage:get_slot_name(idx), slot_data)

	if rid < 0 then
		log.error("error creating request to push slot %s", idx)

		return nil
	else
		local req = self.prq:add(rid, "push_slot", cb_push_slot)

		req.slot_idx = idx

		return rid
	end
end

function xbox:delete_slot(idx)
	local function cb_delete_slot(status, req)
		if self.prq:contains(req.id) then
			local success = status == 0

			signal.emit(SGN_PS_DELETE_SLOT_FINISHED, "cloudsave", success, req.id, req.slot_idx)
		end
	end

	log.debug("deleting slot:%s", idx)

	local rid = self.lib.xbox_create_request_cloud_delete(storage:get_slot_name(idx))

	if rid < 0 then
		log.error("error creating request to delete slot %s", idx)

		return nil
	else
		local req = self.prq:add(rid, "delete_slot", cb_delete_slot)

		req.slot_idx = idx

		return rid
	end
end

function xbox:push_settings()
	local function cb_push_settings(status, req)
		if self.prq:contains(req.id) then
			local success = status == 0

			signal.emit(SGN_PS_PUSH_SETTINGS_FINISHED, "cloudsave", success, req.id)
		end
	end

	local settings = storage:load_settings()

	if not settings then
		log.debug("settings are empty. ignoring")

		return nil
	end

	local filtered_settings = {}

	for k, v in pairs(settings) do
		if not table.contains(xbox.excluded_settings_keys, k) then
			filtered_settings[k] = v
		end
	end

	local settings_data = storage:serialize_lua(filtered_settings)

	log.debug("pushing settings")

	local rid = self.lib.xbox_create_request_cloud_push(storage:get_settings_name(), settings_data)

	if rid < 0 then
		log.error("error creating request to push settings")

		return nil
	else
		local req = self.prq:add(rid, "push_settings", cb_push_settings)

		return rid
	end
end

function xbox:has_valid_joystick()
	return love.joystick.getJoystickCount() > 0
end

function xbox:should_show_joystick_dialog()
	return self.no_joystick_present
end

function xbox:update_joysticks(dt)
	local ts = love.timer.getTime()

	if self.no_joystick_present then
		if self:has_valid_joystick() then
			self.no_joystick_ts = nil
			self.no_joystick_present = nil

			log.debug("platform_services_xbox: joystick detected")
			signal.emit(SGN_PS_CONSOLE_JOYSTICK_PRESENT, "joystick")
		end
	elseif self:has_valid_joystick() then
		self.no_joystick_ts = nil
	else
		if not self.no_joystick_ts then
			self.no_joystick_ts = ts
		end

		if self.no_joystick_ts and ts - self.no_joystick_ts > self.JOYSTICK_RECONFIGURE_TIMEOUT then
			self.no_joystick_present = true

			log.debug("platform_services_xbox: showing no joystick dialog")
			signal.emit(SGN_PS_CONSOLE_NO_JOYSTICK_PRESENT, "joystick")
		end
	end
end

function xbox:sync_achievements()
	local function cb_sync_achievements(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		if status == 0 then
			self.sync_times.achievements = os.time()

			local achs = {}
			local achs_cd = self.lib.xbox_get_cached_payload(req.id)

			if achs_cd then
				local s = ffi.string(achs_cd)

				if s and s ~= "" then
					achs = string.split(s, ",")
				end
			end

			local out = {}

			for _, id in pairs(achs) do
				for aid, xid in pairs(self.ids.achievements) do
					if xid == id then
						table.insert(out, aid)
					end
				end
			end

			self.cached_achievements = out

			log.debug("achievements synchronized successfully")
		else
			self.sync_times.achievements = false
		end
	end

	local rid = self.lib.xbox_create_request_ach_list()

	self.prq:add(rid, "xbox_create_request_ach_list", cb_sync_achievements)

	return rid
end

function xbox:list_achievements()
	return self.cached_achievements
end

function xbox:reset_achievement(ach_id)
	local function update_achievement_reset_request(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		if status == 0 then
			log.debug("achievement reset %s", ach_id)
		end
	end

	local xbox_id = self.ids.achievements[ach_id]

	if not xbox_id then
		log.error("xbox achievement id missing for %s", ach_id)

		return
	end

	local c_str = ffi.new("char[?]", #xbox_id + 1)

	ffi.copy(c_str, xbox_id)

	local rid = self.lib.xbox_create_request_ach_updatet(c_str, 0)

	self.prq:add(rid, "xbox_create_request_ach_update", update_achievement_reset_request)

	return rid
end

function xbox:get_achievement(ach_id)
	return table.contains(self.cached_achievements, ach_id)
end

return xbox
