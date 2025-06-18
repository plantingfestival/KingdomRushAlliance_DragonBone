-- chunkname: @./all/restore_views.lua

local log = require("klua.log"):new("restore_views")

require("klua.table")

local class = require("middleclass")
local storage = require("storage")
local GS = require("game_settings")
local PS = require("platform_services")
local S = require("sound_db")
local RC = require("remote_config")
local ERROR_RESTORE_REQUEST_FAILED = 1
local ERROR_RESTORE_REQUEST_DATA_EMPTY = 2
local ERROR_RESTORE_JSON_PARSE_FAILED = 3
local ERROR_RESTORE_INVALID_LINK = 4
local ERROR_RESTORE_DATA_STRUCTURE_INVALID = 5

RestoreView = class("RestoreView", KView)

function RestoreView:initialize(size)
	KView.initialize(self, size)

	self:ci("restore_view_close_button").on_click = function(this)
		S:queue("GUIButtonCommon")
		self:hide()
	end
end

function RestoreView:show(link)
	local function cb_restore(status, req, url, code, header, data)
		log.debug("cb_restore(status:%s, req.id:%s url:%s http_code:%s)", status, req.id, url, code)

		local ok, restore_data

		if status ~= 0 then
			local msg = string.format("http error: request failed. status:%s url:%s", status, url)

			log.error(msg)
			self:show_error(ERROR_RESTORE_REQUEST_FAILED, msg)

			return
		elseif not data then
			local msg = string.format("http error: data is empty for url %s", url)

			log.error(msg)
			self:show_error(ERROR_RESTORE_REQUEST_DATA_EMPTY, msg)

			return
		end

		self.data = data
		ok, restore_data = PS.services.http:parse_json(data)

		if not ok then
			local msg = string.format("http error: failed parsing json %s", data)

			log.error(msg)
			self:show_error(ERROR_RESTORE_JSON_PARSE_FAILED, msg)

			return
		else
			self:refresh(restore_data)
		end
	end

	log.debug("requesting restore data...")

	local token = string.match(link, RC.v.restore_extract_token_regex)

	if not token then
		local msg = string.format("link error: failed to extract the token from %s", link)

		log.error(msg)
		self:show_error(ERROR_RESTORE_INVALID_LINK, msg)

		return
	end

	local slink = string.format(RC.v.restore_url_fmt, token)
	local headers = {
		accept = "application/text",
		["ih-bundleId"] = version.bundle_id,
		ih_bundle = version.bundle_id,
		ih_appversion = version.string_short
	}

	self.rid = PS.services.http:get(slink, headers, cb_restore, 30)
	self:ci("restore_in_progress").hidden = false

	for _, n in pairs({
		"restore_error_label",
		"restore_error_code_label",
		"restore_pick_slot_label",
		"restore_new_stats",
		"restore_slots"
	}) do
		local v = self:ci(n)

		if v then
			v.hidden = true
		end
	end

	self.hidden = false
end

function RestoreView:hide()
	self.hidden = true
end

function RestoreView:refresh(restore_data)
	log.debug("restore_data data:%s", restore_data)

	local new_slot = storage:restore_slot(restore_data)

	if DEBUG then
		self._new_slot = new_slot
	end

	if not new_slot then
		local msg = string.format("the restore data is invalid")

		log.error(msg)
		self:show_error(ERROR_RESTORE_DATA_STRUCTURE_INVALID, msg)

		return
	end

	self:ci("restore_in_progress").hidden = true
	self:ci("restore_error_label").hidden = true
	self:ci("restore_error_code_label").hidden = true
	self:ci("restore_slots").hidden = false
	self:ci("restore_pick_slot_label").hidden = false

	local pstars, pheroic, piron = storage:get_slot_stats(new_slot)
	local ns = self:ci("restore_new_stats")

	ns.hidden = false
	ns:ci("l_stars").text = tostring(pstars) .. "/" .. tostring(GS.max_stars)
	ns:ci("l_heroic").text = tostring(pheroic)
	ns:ci("l_iron").text = tostring(piron)

	for _, b in pairs(self:ci("restore_slots").children) do
		b:ci("button_slot").on_click = function()
			log.debug("replacing slot %s with new restore data", b.slot_idx)
			storage:delete_slot(b.slot_idx)
			storage:save_slot(new_slot, b.slot_idx, true)
			self:hide()
		end
		b:ci("button_slot_new").on_click = function()
			log.debug("using empty slot %s with new restore data", b.slot_idx)
			storage:save_slot(new_slot, b.slot_idx, true)
			self:hide()
		end
		b:ci("button_slot_delete_yes").on_click = function()
			return
		end
		b:ci("button_slot_delete_no").on_click = function()
			return
		end

		b:show()
	end
end

function RestoreView:show_error(code, msg)
	log.error("showing error code %s : %s", code, msg)

	self:ci("restore_error_label").hidden = false
	self:ci("restore_error_code_label").hidden = false
	self:ci("restore_error_code_label").text = "ERROR CODE:" .. tostring(code)

	for _, n in pairs({
		"restore_in_progress",
		"restore_pick_slot_label",
		"restore_new_stats",
		"restore_slots"
	}) do
		local v = self:ci(n)

		if v then
			v.hidden = true
		end
	end
end
