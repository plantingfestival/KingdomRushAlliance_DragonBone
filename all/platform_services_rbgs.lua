-- chunkname: @./all/platform_services_rbgs.lua

local log = require("klua.log"):new("platform_services_rbgs")
local signal = require("hump.signal")
local json = require("json")

require("klua.table")
require("klua.string")
require("constants")

local PS = require("platform_services")
local PSU = require("platform_services_utils")
local srv = {}

srv.can_be_paused = true
srv.update_interval = 1
srv.SRV_DISPLAY_NAME = "Remote Balance Google Sheets"
srv.data = {}
srv.sync_errors = nil

function srv:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		if not PS.services.http or not PS.services.http.inited then
			log.error("%s requires platform_services_http inited", name)

			return nil
		end

		if not params or not params.api_key or not params.sheet_id then
			log.error("%s requires: api_key, sheet_id")

			return nil
		end

		self.api_key = params.api_key
		self.sheet_id = params.sheet_id
		self.settings_sheet_name = params.settings_sheet_name or "settings"
		self.inited = true

		if params.sync_on_init then
			self:sync(true)
		end
	end

	return true
end

function srv:shutdown(name)
	self.inited = nil
end

function srv:log_sync_error(fmt, ...)
	if not self.sync_errors then
		self.sync_errors = {}
	end

	table.insert(self.sync_errors, string.format(fmt or "", ...))
	log.error(fmt, ...)
end

function srv:get_sheet_url(name)
	return string.format("https://sheets.googleapis.com/v4/spreadsheets/%s/values/%s?key=%s", self.sheet_id, name, self.api_key)
end

function srv:parse_json_waves_index(data)
	local ok, dl = PS.services.http:parse_json(data)

	if not ok then
		self:log_sync_error("Error parsing waves index for data %s", data)

		return nil
	end

	if not dl.values[1] then
		self:log_sync_error("Sheet has no first row")

		return nil
	end

	log.debug("parsing waves_index %s", getdump(dl))

	local cn = {}

	for ci, cell in ipairs(dl.values[1]) do
		local v = string.trim(cell)

		if v and v ~= "" and not string.starts(v, "#") then
			cn[v] = ci
		end
	end

	if not cn.level or not cn.mode or not cn.default or not cn.alternatives then
		self:log_sync_error("Sheet should have the first row defining colums named: level, mode, default, alternatives")

		return nil
	end

	local out = {}

	for ri, row in ipairs(dl.values) do
		if ri == 1 or row[1] and string.starts(string.trim(row[1]), "#") then
			-- block empty
		else
			local level = tonumber(row[cn.level])
			local mode = tonumber(row[cn.mode])
			local default = row[cn.default]
			local alts = row[cn.alternatives]

			if not level or not mode or not default then
				self:log_sync_error("waves_index row %s is empty: %s", ri, row)
			else
				out[level] = out[level] or {}
				out[level][mode] = {}
				out[level][mode].default = default

				if alts then
					out[level][mode].alternatives = string.split(alts, " ")
				end
			end
		end
	end

	return out
end

function srv:json2tsv(data)
	local ok, dl = PS.services.http:parse_json(data)

	if not ok then
		self:log_sync_error("Error converting json to tsv for data %s", data)

		return nil
	end

	if not dl.values then
		self:log_sync_error("Error. data.values is nil for data %s", data)

		return nil
	end

	local tsv = ""

	for _, row in pairs(dl.values) do
		tsv = tsv .. table.concat(row, "\t") .. "\n"
	end

	return tsv
end

function srv:get_sheet_desc(data)
	return string.match(data or "", "description\t([^\t\r\n]+)")
end

function srv:cache_wave_sheets(list)
	local function cb_dl_wave(status, req, url, code, header, data)
		log.debug("cb_dl_wave(status%s, req.id:%s", status, req.id)

		local success = status == 0

		if success then
			local sheet_name = self.rids_waves_in_progress[req.id]

			if not sheet_name then
				self:log_sync_error("sheet was not found in rids_waves_in_progress for rid %s", req.id)

				success = false
			else
				local sheet_tsv = srv:json2tsv(data)

				sheet_tsv = sheet_tsv and "\tsheet_name\t" .. sheet_name .. "\n" .. sheet_tsv
				self.data.waves[sheet_name] = sheet_tsv
				self.data.waves_desc[sheet_name] = srv:get_sheet_desc(sheet_tsv)
				self.rids_waves_in_progress[req.id] = nil
			end
		end

		if #table.keys(self.rids_waves_in_progress) == 0 then
			log.debug("SGN_PS_REMOTE_BALANCE_WAVES_CACHED done for wave sheets. success:%s", success)
			signal.emit(SGN_PS_REMOTE_BALANCE_WAVES_CACHED, "rgbs", success, req.id)
		end
	end

	log.debug("caching wave sheets :%s", getdump(list))

	self.rids_waves_in_progress = {}
	self.data.waves = {}
	self.data.waves_desc = {}
	self.sync_errors = {}

	for _, name in pairs(list) do
		local url = self:get_sheet_url(name)
		local rid = PS.services.http:get(url, nil, cb_dl_wave)

		self.rids_waves_in_progress[rid] = name
	end
end

function srv:is_in_progress()
	if not self.rids_waves_in_progress then
		return false
	end

	return #table.keys(self.rids_waves_in_progress) > 0
end

function srv:sync(deep)
	local function cb_dl_waves_index(status, req, url, code, header, data)
		log.debug("cb_dl_waves_index(status%s, req.id:%s", status, req.id)

		local success = status == 0

		if success and data then
			local iw = srv:parse_json_waves_index(data)

			if iw then
				self.data.waves_index = iw

				if deep then
					local sheet_names = {}

					for level_idx, l in pairs(iw) do
						for mode_idx, m in pairs(l) do
							log.todo(" level:%s mode:%s data:%s", level_idx, mode_idx, getdump(m))

							if m.default and m.default ~= "" then
								table.insert(sheet_names, m.default)
							end

							if m.alternatives and type(m.alternatives) == "table" then
								for _, n in pairs(m.alternatives) do
									table.insert(sheet_names, n)
								end
							end
						end
					end

					self:cache_wave_sheets(sheet_names)
				end
			else
				success = false
				self.data.waves_index = nil
				self.data.waves = {}
				self.data.waves_desc = {}
			end
		end

		if not deep then
			log.debug("SGN_PS_REMOTE_BALANCE_WAVES_CACHED done for indexes only. success:%s", success)
			signal.emit(SGN_PS_REMOTE_BALANCE_WAVES_CACHED, "rgbs", success, req.id)
		end
	end

	local waves_url = self:get_sheet_url("waves_index")
	local wid = PS.services.http:get(waves_url, nil, cb_dl_waves_index)

	log.debug("caching waves_index sheet from %s via req %s", waves_url, wid)
	signal.emit(SGN_PS_REMOTE_BALANCE_SYNC_STARTED, "rgbs", wid)

	return {
		wid
	}
end

return srv
