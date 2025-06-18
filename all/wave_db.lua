-- chunkname: @./all/wave_db.lua

local log = require("klua.log"):new("wave_db")
local km = require("klua.macros")
local FS = love.filesystem
local E = require("entity_db")
local tsv = require("klua.tsv")

require("constants")
require("klua.string")

local wave_db = {}

wave_db.format = nil
wave_db.db = nil
wave_db.game_mode = nil
wave_db.parse_errors = nil

local WS_IDLE = "idle"
local WS_PENDING = "pending"
local WS_RUNNING = "running"
local WS_DONE = "done"
local WS_REMOVED = "removed"

wave_db.WS_IDLE = WS_IDLE
wave_db.WS_PENDING = WS_PENDING
wave_db.WS_RUNNING = WS_RUNNING
wave_db.WS_DONE = WS_DONE
wave_db.WS_REMOVED = WS_REMOVED
wave_db.gms = {
	[GAME_MODE_CAMPAIGN] = "campaign",
	[GAME_MODE_HEROIC] = "heroic",
	[GAME_MODE_IRON] = "iron",
	[GAME_MODE_ENDLESS] = "endless"
}

local tsv_cmd_col = 2
local tsv_value_col = 3

local function log_e(fmt, ...)
	if not wave_db.parse_errors then
		wave_db.parse_errors = {}
	end

	table.insert(wave_db.parse_errors, string.format(fmt or "", ...))
	log.error(fmt, ...)
end

function wave_db:parse_column_names(cmd, row, row_idx)
	local function col_letter(idx)
		local first = string.byte("A")
		local last = string.byte("Z")
		local base = last - first + 1
		local r = ""
		local q = idx - 1

		while q >= 0 do
			local rem = q % base

			r = string.char(rem + first) .. r
			q = math.floor(q / base) - 1
		end

		return r
	end

	local time_columns = {}
	local path_columns = {}

	for i, col in ipairs(row) do
		col = string.trim(col)

		if col == "column_names" or col == "" then
			-- block empty
		else
			local parts = string.split(col, ":")

			if parts[1] == "inc" then
				time_columns.inc = i
			elseif parts[1] == "abs" then
				time_columns.abs = i
			elseif tonumber(parts[1]) then
				local pi = tonumber(parts[1])
				local spi = tonumber(parts[2]) or "*"

				path_columns[pi] = path_columns[pi] or {}
				path_columns[pi][spi] = i
			else
				return true, string.format("unknown column type: %s at column %s", col, col_letter(i))
			end
		end
	end

	cmd.time_columns = time_columns
	cmd.path_columns = path_columns
end

function wave_db:parse_flags(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, "flags cmd requires a path command before"
	end

	local pc = cmd_cols.path_columns

	if not pc then
		return true, "flags cmd requires path cmd with path_columns"
	end

	local out = {}

	for pi in pairs(pc) do
		out[pi] = {}

		for spi, col_index in pairs(pc[pi]) do
			local flag = string.lower(row[col_index] or "")
			local v = flag ~= "n" and flag ~= "false" and flag ~= "hide" and flag ~= "hidden"

			if spi == "*" then
				out[pi][1] = v
				out[pi][2] = v
				out[pi][3] = v

				break
			else
				local spin = tonumber(spi)

				out[pi][spin] = v
			end
		end
	end

	cmd.flags_visibility = out
end

function wave_db:parse_wave(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_i = self:find_prev_cmd("interval", cmd)
	local cmd_di = self:find_prev_cmd("default_interval", cmd)
	local tc = cmd_cols.time_columns

	cmd.wait_time = tonumber(row[tc.inc]) or cmd_i and cmd_i.value or cmd_di and cmd_di.value
end

function wave_db:parse_spawn(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_enemy_prefix = self:find_prev_cmd("enemy_prefix", cmd)
	local enemy_prefix = cmd_enemy_prefix.value or ""
	local cmd_default_increment = self:find_prev_cmd("default_increment", cmd)
	local default_increment = cmd_default_increment.value or 1
	local tc = cmd_cols.time_columns
	local row_increment = tonumber(row[tc.inc])

	cmd.wait_time = row_increment or default_increment
	cmd.absolute = row[tc.abs]
	cmd.spawns = {}

	local pc = cmd_cols.path_columns

	for pi in pairs(pc) do
		for spi, col_index in pairs(pc[pi]) do
			local enemy_suffix = row[col_index] and string.trim(row[col_index]) or ""

			if enemy_suffix and enemy_suffix ~= "" then
				table.insert(cmd.spawns, {
					pi = pi,
					spi = spi,
					enemy = enemy_prefix .. enemy_suffix
				})
			end
		end
	end
end

function wave_db:parse_event(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_default_increment = self:find_prev_cmd("default_increment", cmd)
	local default_increment = cmd_default_increment.value or 1
	local event_name = row[tsv_value_col]
	local increment = row[cmd_cols.time_columns.inc] or default_increment
	local params = {}

	for i = tsv_value_col + 1, #row do
		if i ~= cmd_cols.path_columns.inc then
			table.insert(params, row[i])
		end
	end

	cmd.event_name = event_name
	cmd.event_params = params
	cmd.wait_time = tonumber(increment)
end

function wave_db:parse_signal(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_default_increment = self:find_prev_cmd("default_increment", cmd)
	local default_increment = cmd_default_increment.value or 1
	local signal_name = row[tsv_value_col]
	local increment = row[cmd_cols.path_columns.inc] or default_increment
	local params = {}

	for i = tsv_value_col + 1, #row do
		if i ~= cmd_cols.path_columns.inc then
			table.insert(params, row[i])
		end
	end

	cmd.signal_name = signal_name
	cmd.signal_params = params
	cmd.wait_time = increment
end

function wave_db:parse_wait_signal(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_default_increment = self:find_prev_cmd("default_increment", cmd)
	local default_increment = cmd_default_increment.value or 1
	local signal_name = row[tsv_value_col]
	local increment = row[cmd_cols.path_columns.inc] or default_increment

	log.debug("waiting for signal %s...", signal_name)

	cmd.signal_name = signal_name
	cmd.wait_time = increment
end

function wave_db:parse_number(cmd, row, row_idx)
	local value = row[tsv_value_col]

	cmd.value = tonumber(value)
end

function wave_db:parse_manual_wave(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local wave_name = row[tsv_value_col]

	if not wave_name or string.trim(wave_name) == "" then
		return true, string.format("%s cmd requires a value with the name of the manual_wave", cmd.name)
	end

	local ws = self:get_wave_status(wave_name)

	if ws then
		return true, string.format("manual waves must be unique. name: %s already exists", wave_name)
	end

	cmd.wave_name = wave_name
	cmd.wait_time = 0
end

function wave_db:parse_manual_wave_repeat(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_mw = self:find_prev_cmd("manual_wave", cmd)

	if not cmd_mw then
		return true, string.format("%s cmd requires a manual command before", cmd.name)
	end

	local mws = self:get_wave_status(cmd_mw.wave_name)

	if not mws then
		return true, string.format("%s cmd requires manual_wave %s before", cmd.name, cmd_mw.wave_name)
	end

	cmd.wave_name = cmd_mw.wave_name

	local value = tonumber(row[tsv_value_col])

	cmd.repeat_count = value or 0
	mws.repeat_count = cmd.repeat_count
	mws.repeat_remaining = cmd.repeat_count
end

function wave_db:parse_wait(cmd, row, row_idx)
	local cmd_cols = self:find_prev_cmd("column_names", cmd)

	if not cmd_cols then
		return true, string.format("%s cmd requires a path command before", cmd.name)
	end

	local cmd_default_increment = self:find_prev_cmd("default_increment", cmd)
	local default_increment = cmd_default_increment and cmd_default_increment.value or 1
	local tc = cmd_cols.time_columns
	local row_increment = tonumber(row[tc.inc])

	cmd.wait_time = row_increment or default_increment
end

wave_db.tsv_cmds = {
	["#"] = {},
	sheet_name = {},
	description = {},
	lives = {
		parse_fn = wave_db.parse_number
	},
	gold = {
		parse_fn = wave_db.parse_number
	},
	gems = {
		parse_fn = wave_db.parse_number
	},
	gem_keepers = {
		parse_fn = wave_db.parse_number
	},
	enemy_prefix = {},
	default_increment = {
		parse_fn = wave_db.parse_number
	},
	default_interval = {
		parse_fn = wave_db.parse_number
	},
	interval = {
		parse_fn = wave_db.parse_number
	},
	column_names = {
		parse_fn = wave_db.parse_column_names
	},
	flags = {
		parse_fn = wave_db.parse_flags
	},
	wave = {
		parse_fn = wave_db.parse_wave
	},
	spawn = {
		parse_fn = wave_db.parse_spawn
	},
	wait = {
		parse_fn = wave_db.parse_wait
	},
	event = {
		parse_fn = wave_db.parse_event
	},
	signal = {
		parse_fn = wave_db.parse_signal
	},
	wait_signal = {
		parse_fn = wave_db.parse_wait_signal
	},
	manual_wave = {
		parse_fn = wave_db.parse_manual_wave
	},
	manual_wave_repeat = {
		parse_fn = wave_db.parse_manual_wave_repeat
	},
	call_manual_wave = {}
}

function wave_db:create_wave_group_from_tsv(wave_cmd)
	local path_columns = self:find_prev_cmd("column_names", wave_cmd)

	if not path_columns then
		log_e("%s cmd requires a path command before", wave_cmd.name)

		return
	end

	local group = {
		waves = {},
		interval = (wave_cmd.wait_time or 0) * FPS
	}
	local out = {}
	local w
	local delay = 0
	local has_flying = false
	local wave_idx = self:get_cmd_idx(wave_cmd)

	for i = wave_idx + 1, #self.db_cmds do
		local cmd = self.db_cmds[i]

		if cmd.name == "wave" or cmd.name == "manual_wave" then
			break
		elseif cmd.name == "spawn" then
			local interval = cmd.wait_time

			delay = delay + interval

			for _, es in pairs(cmd.spawns) do
				if w and w.path_index ~= es.pi then
					w.delay = delay * FPS
					w.some_flying = has_flying

					table.insert(group.waves, w)

					w = nil
					has_flying = false
				end

				w = w or {
					path_index = es.pi,
					spawns = {}
				}

				table.insert(w.spawns, {
					max_same = 0,
					interval_next = 0,
					max = 1,
					creep = es.enemy,
					fixed_sub_path = es.spi == "*" and 0 or 1,
					interval = interval * FPS,
					path = es.spi == "*" and 1 or es.spi
				})

				local tpl = E:get_template(es.enemy)

				if tpl and bit.band(tpl.vis.flags, F_FLYING) ~= 0 then
					has_flying = true
				end
			end

			if w then
				w.delay = delay * FPS
				w.some_flying = has_flying

				table.insert(group.waves, w)

				w = nil
				has_flying = false
			end
		end
	end

	if log.level == log.PARANOID_LEVEL then
		log.paranoid("group:%s", getfulldump(group))
	end

	return group
end

function wave_db:get_spawns_for_wave(idx)
	local wave_count = 0
	local start_idx

	for i, cmd in pairs(self.db_cmds) do
		if cmd.name == "wave" then
			wave_count = wave_count + 1

			if wave_count == idx then
				start_idx = i

				break
			end
		end
	end

	if not start_idx then
		log.paranoid("wave %s not found", idx)

		return
	end

	local spawns = {}

	for i = start_idx + 1, #self.db_cmds do
		local cmd = self.db_cmds[i]

		if cmd.name == "wave" then
			return spawns
		elseif cmd.name == "spawn" then
			table.append(spawns, cmd.spawns)
		end
	end

	return spawns
end

function wave_db:parse_cmd(row, row_idx)
	log.paranoid("-- row: | %s | %s | %s |", row[1], row[2], row[3])

	for _, col in ipairs(row) do
		if string.starts(col, "#") then
			log.paranoid("comment found. skipping row %s", table.concat(row, " "))

			return {
				name = "#"
			}
		elseif string.trim(col) ~= "" then
			break
		end
	end

	local cname
	local path_cmd = self:find_prev_cmd("column_names", self.db_cmds[#self.db_cmds])

	if path_cmd and row[tsv_cmd_col] == "" then
		local pc = path_cmd.path_columns

		for pi in pairs(pc) do
			for spi, col_index in pairs(pc[pi]) do
				if row[col_index] and row[col_index] ~= "" and row[col_index] ~= "\r" then
					log.paranoid("spawn found.")

					cname = "spawn"

					goto label_16_0
				end
			end
		end
	end

	cname = row[tsv_cmd_col]

	::label_16_0::

	if not cname or cname == "" then
		return
	elseif not self.tsv_cmds[cname] then
		return nil, string.format("cmd %s not found in tsv_cmds", cname)
	end

	local parse_fn = self.tsv_cmds[cname].parse_fn
	local cmd = {}

	cmd.name = cname
	cmd.tsv_row = row
	cmd.tsv_row_idx = row_idx

	if parse_fn then
		local err, msg = parse_fn(self, cmd, row, row_idx)

		if err then
			return nil, msg
		end
	else
		cmd.value = row[tsv_value_col]
	end

	return cmd
end

function wave_db:get_cmd_idx(start_cmd)
	for i, cmd in ipairs(self.db_cmds) do
		if start_cmd == cmd then
			return i
		end
	end

	return nil
end

function wave_db:find_prev_cmd(cname, start_cmd)
	if not self.db_cmds or not cname or not start_cmd then
		return
	end

	local start_idx = self:get_cmd_idx(start_cmd) or #self.db_cmds

	for i = start_idx, 1, -1 do
		local cmd = self.db_cmds[i]

		if cmd.name == cname then
			return cmd
		end
	end
end

function wave_db:find_first_cmd(cname)
	for _, cmd in pairs(self.db_cmds) do
		if cmd.name == cname then
			return cmd
		end
	end
end

function wave_db:peek_next_cmd(wave_name)
	local ws = self:get_wave_status(wave_name)

	if not ws then
		log.error("wave %s does not exist", wave_name)

		return nil
	end

	if ws.state == WS_DONE or ws.state == WS_REMOVED then
		log.debug("wave %s finished", wave_name)

		return nil
	end

	local next_idx = ws.current_idx + 1
	local next_cmd = self.db_cmds[next_idx]

	if not next_cmd or next_cmd.name == "manual_wave" then
		return nil
	end

	return next_cmd, next_idx
end

function wave_db:get_next_cmd(wave_name)
	local next_cmd, next_idx = self:peek_next_cmd(wave_name)

	if not next_cmd then
		return nil
	end

	local ws = self:get_wave_status(wave_name)

	ws.current_idx = next_idx

	return next_cmd, next_idx
end

function wave_db:load_tsv(level_name, game_mode, wave_ss_data)
	self.parse_errors = nil

	local rows

	if wave_ss_data then
		rows = tsv.parse_tsv(wave_ss_data)
	else
		local suffix = self.gms[game_mode]
		local wn = string.format("%s/data/waves/%s_waves_%s", KR_PATH_GAME, level_name, suffix)
		local wf = string.format("%s.tsv", wn)

		if not love.filesystem.isFile(wf) then
			log.info("wave file in tsv format not found: %s", wf)

			return
		end

		log.debug("Loading %s", wn)

		rows = tsv.load(wf)

		if not rows or #rows == 0 then
			log_e("Failed to load %s", wf)

			return
		end
	end

	self.format = "tsv"
	self.game_mode = game_mode
	self.db_rows = rows
	self.db_cmds = {}
	self.db_waves_status = {}

	local ws = self:create_wave_status("main")

	ws.state = WS_RUNNING

	local db = {
		interval = -1,
		path_columns = {},
		flags_visibility = {}
	}

	self.db = db

	log.paranoid("parsing rows")

	local sheet_name

	for i = 1, #rows do
		local cmd, err = self:parse_cmd(rows[i], i)

		if cmd then
			log.paranoid(" row[%s] = %s", i, getdump(cmd))

			if cmd.name == "sheet_name" then
				sheet_name = cmd.value
			end

			if cmd.name ~= "#" then
				table.insert(self.db_cmds, cmd)
			end

			if cmd.name == "manual_wave" then
				local mws = self:create_wave_status(cmd.wave_name)

				mws.first_idx = #self.db_cmds
				mws.current_idx = mws.first_idx
			end
		else
			log_e("error at %s#%s:  %s", sheet_name, i, err)
		end
	end

	if log.level == log.PARANOID_LEVEL then
		local out = ""

		for i, cmd in ipairs(self.db_cmds) do
			out = out .. string.format("(%02i) - %s : value:%s wait_time:%s\n", i, cmd.name, cmd.value, cmd.wait_time)
		end

		log.paranoid("wave cmds:\n%s", out)
	end

	return true
end

function wave_db:load_lua(level_name, game_mode)
	local suffix = self.gms[game_mode]
	local wn = string.format("%s/data/waves/%s_waves_%s", KR_PATH_GAME, level_name, suffix)
	local wf = string.format("%s.lua", wn)

	log.debug("Loading %s", wn)

	local ok, wchunk, wtable, extraw

	ok, wchunk = pcall(FS.load, wf)

	if not ok then
		log.error("Failed to load %s: error: %s", wf, wchunk)

		return
	end

	ok, wtable = pcall(wchunk)

	if not ok then
		log.error("Failed to eval chunk for %s: error: %s", wf, wtable)

		return
	end

	wave_db.format = "lua"
	wave_db.game_mode = game_mode
	wave_db.db = wtable

	local wen = string.format("%s_extra", wn)
	local wef = string.format("%s.lua", wen)

	if FS.isFile(wef) then
		log.info("Found extra waves: %s", wef)

		ok, wchunk = pcall(FS.load, wef)

		if not ok then
			log.error("Failed to load %s: error: %s", wef, wchunk)

			return
		end

		ok, extraw = pcall(wchunk)

		if not ok then
			log.error("Failed to eval extra waves chunk for %s: error: %s", wef, extraw)

			return
		end

		self:add_waves_to_groups(extraw)
	end

	return true
end

function wave_db:load(level_name, game_mode, wave_ss_data)
	if self:load_tsv(level_name, game_mode, wave_ss_data) then
		log.debug("loaded waves file in tsv format")

		return "tsv"
	end

	if self:load_lua(level_name, game_mode) then
		log.debug("loaded waves file in lua format")

		return "lua"
	end

	return nil
end

function wave_db:add_waves_to_groups(gwaves)
	if self.format ~= "lua" then
		log.error("TODO: Only implemented for lua format")

		return
	end

	if self.db.groups then
		for g, more_waves in pairs(gwaves) do
			log.info("adding %d extra waves to group %d", #more_waves.waves, g)

			if not self.db.groups[g] then
				log.warning("Adding waves to inexistent group %d", g)

				self.db.groups[g] = {
					waves = {}
				}
			end

			for _, w in pairs(more_waves.waves) do
				table.insert(self.db.groups[g].waves, w)
			end
		end
	else
		log.error("Unable to add waves. No wave groups have been loaded yet.")
	end
end

function wave_db:groups()
	if self.format ~= "lua" then
		log.error("TODO: Only implemented for lua format")

		return {}
	end

	return self.db.groups
end

function wave_db:group(group_number)
	if self.format ~= "lua" then
		log.error("TODO: Only implemented for lua format")

		return nil
	end

	return self.db.groups[group_number]
end

function wave_db:initial_gold()
	if self.format == "tsv" then
		local cmd = self:find_first_cmd("gold")

		if cmd then
			return cmd.value
		else
			return 0
		end
	else
		return self.db.cash or self.db.gold
	end
end

function wave_db:initial_lives()
	return self.db.lifes
end

function wave_db:get_gem_keepers()
	if self.format == "tsv" then
		local cmd = self:find_first_cmd("gem_keepers")

		if cmd then
			return cmd.value
		end
	end

	return 1
end

function wave_db:groups_count()
	if self.game_mode == GAME_MODE_ENDLESS then
		return 0
	elseif self.format == "tsv" then
		local count = 0

		for _, cmd in ipairs(self.db_cmds) do
			if cmd.name == "wave" then
				count = count + 1
			end
		end

		return count
	else
		return #self.db.groups
	end
end

function wave_db:all_waves_count()
	if self.game_mode == GAME_MODE_ENDLESS then
		return 0
	elseif self.format == "tsv" then
		return self:groups_count()
	else
		local result = 0

		for __, group in pairs(self.db.groups) do
			result = result + #group.waves
		end

		return result
	end
end

function wave_db:has_group(i)
	if self.game_mode == GAME_MODE_ENDLESS then
		return i > 0
	else
		return i <= self:groups_count()
	end
end

function wave_db:get_group(i)
	if self.game_mode == GAME_MODE_ENDLESS then
		return self:get_endless_group(i)
	elseif self.format == "tsv" then
		log.error("Not implemented for tsv format")

		return nil
	else
		return self.db.groups[i]
	end
end

function wave_db:is_flag_visible(pi, spi)
	if self.db and self.db.flags_visibility and self.db.flags_visibility[pi] then
		return self.db.flags_visibility[pi][spi or 1]
	else
		return true
	end
end

function wave_db:create_wave_status(wave_name)
	local ws = {
		repeat_count = 0,
		current_idx = 0,
		state = WS_IDLE,
		name = wave_name
	}

	self.db_waves_status[wave_name] = ws

	return ws
end

function wave_db:get_wave_status(wave_name)
	wave_name = wave_name or "main"

	return self.db_waves_status[wave_name]
end

function wave_db:stop_manual_wave(wave_name)
	if not wave_name or wave_name == "main" or wave_name == "" then
		log.error("cannot stop main waves")

		return
	end

	local s = self:get_wave_status(wave_name)

	if not s then
		log.error("manual wave %s does not exist", wave_name)

		return
	end

	if table.contains({
		WS_PENDING,
		WS_RUNNING
	}, s.state) then
		s.state = WS_DONE
	else
		log.error("manual wave %s cannot be stopped in state %s", wave_name, s.state)
	end
end

function wave_db:start_manual_wave(wave_name)
	if not wave_name or wave_name == "main" or wave_name == "" then
		log.error("cannot start main waves")

		return
	end

	local s = self:get_wave_status(wave_name)

	if not s then
		log.error("manual wave %s does not exist", wave_name)

		return
	end

	if table.contains({
		WS_PENDING,
		WS_RUNNING,
		WS_DONE
	}, s.state) then
		log.error("manual wave %s pending or still running. cannot have more than one at a time.", wave_name)

		return
	end

	s.state = WS_PENDING
	s.current_idx = s.first_idx
	s.repeat_remaining = s.repeat_count
end

function wave_db:has_pending_manual_waves()
	for k, v in pairs(self.db_waves_status) do
		if k ~= "main" and v.state == WS_PENDING then
			return true
		end
	end
end

function wave_db:list_pending_manual_waves()
	local names = {}

	for k, v in pairs(self.db_waves_status) do
		if v.state == WS_PENDING then
			table.insert(names, k)
		end
	end

	return names
end

function wave_db:get_endless_early_wave_reward_factor()
	if self.db and self.db.nextWaveRewardMoneyMultiplier then
		return self.db.nextWaveRewardMoneyMultiplier
	else
		return 1
	end
end

function wave_db:get_endless_score_config()
	if self.db and self.db.score then
		return table.deepclone(self.db.score)
	else
		return nil
	end
end

function wave_db:get_endless_boss_config(i)
	local out = {}
	local db = self.db
	local dif_max = #db.difficulties
	local dif_level = math.ceil(i / 10)
	local dif_idx = km.clamp(1, dif_max, dif_level)
	local dif = db.difficulties[dif_idx]
	local dbc = dif.bossConfig

	out.chance = dbc.powerChance + dbc.powerChanceIncrement * dif_level
	out.cooldown = math.random(dbc.powerCooldownMin, dbc.powerCooldownMax)
	out.multiple_attacks_chance = dbc.powerMultiChance
	out.power_chances = dbc.powerDistribution
	out.powers_config_dif = dbc.powerConfig
	out.boss_config_dif = dbc
	out.powers_config = db.bossConfig.powerConfig

	return out
end

function wave_db:get_endless_group(i)
	local db = self.db

	if not db.vars then
		db.vars = {
			dif_idx = 1,
			next_dif_uses = 0,
			used_waves = {},
			first_entity_wave = {}
		}
	end

	local paths_order = {}

	for _, v in pairs(table.random_order(db.pathConfig)) do
		local rv, rvi = table.random(v)

		table.insert(paths_order, rv + 1)
	end

	local waves_per_load = 10
	local used_waves = db.vars.used_waves
	local dif_idx = db.vars.dif_idx
	local dif_max = #db.difficulties
	local dif = db.difficulties[dif_idx]
	local dif_next = db.difficulties[km.clamp(1, dif_max, dif_idx + 1)]
	local max_paths = dif.max_paths
	local boss_waves_count = i % waves_per_load ~= 0 and 0 or #dif.bossWaves
	local multipath_chance = i == 1 and 0 or (dif.multiple_paths_chance + dif.multiple_paths_chance_increment * i) / 100
	local next_dif_chances = db.chancesToUseNextDifficulty
	local next_dif_uses = db.vars.next_dif_uses
	local o_group = {
		waves = {}
	}
	local wave_interval = 0

	for pi = 1, max_paths do
		if pi > 1 and boss_waves_count == 0 and multipath_chance < math.random() then
			-- block empty
		else
			local cycle_index = km.zmod(i, waves_per_load)
			local waves

			if boss_waves_count > 0 then
				waves = dif.bossWaves
				boss_waves_count = boss_waves_count - 1
			else
				local next_dif_chance = next_dif_chances[cycle_index - waves_per_load + #next_dif_chances] or 0

				next_dif_chance = next_dif_chance * math.pow(0.5, next_dif_uses)

				log.paranoid("  ENDLESS NORMAL WAVE. next_dif_chance:%s next_dif_uses:%s  chances:%s", next_dif_chance, next_dif_uses, getfulldump(next_dif_chances))

				if next_dif_chance > math.random() then
					next_dif_uses = next_dif_uses + 1
					waves = dif_next.waves
					cycle_index = 1
				else
					waves = dif.waves
				end
			end

			local candidate_waves = table.filter(waves, function(k, v)
				return not table.contains(used_waves, v)
			end)

			if #candidate_waves == 0 then
				candidate_waves = waves
				used_waves = {}
			end

			local wave = table.random(candidate_waves)

			table.insert(used_waves, wave)

			wave_interval = math.max(wave_interval, wave.next_wave_interval)

			local o_wave = {
				delay = 0,
				spawns = {}
			}
			local has_some_flying = false

			for _, spawn in pairs(wave.spawns) do
				local o_spawn = {
					creep = spawn.creep,
					creep_aux = spawn.creep_aux,
					max_same = spawn.max_same,
					max = spawn.cant + (spawn.cant_cicle == 0 and 0 or spawn.cant_increment * math.floor(math.min(cycle_index, waves_per_load) / spawn.cant_cicle)),
					interval = spawn.interval,
					interval_next = spawn.interval_next,
					fixed_sub_path = spawn.use_fixed_path,
					path = spawn.path + 1
				}

				table.insert(o_wave.spawns, o_spawn)

				local tpl = E:get_template(spawn.creep)

				if tpl and bit.band(tpl.vis.flags, F_FLYING) ~= 0 then
					has_some_flying = true
				end

				log.paranoid("   ENDLESS SPAWN index:%03i - max:%03i creep:%s  maxSame:%i interval:%i interval_next:%i path:%i cycle_index:%i", i, o_spawn.max, o_spawn.creep, o_spawn.max_same, o_spawn.interval, o_spawn.interval_next, o_spawn.path, cycle_index)
			end

			o_wave.path_index = paths_order[km.zmod(pi, #paths_order)]
			o_wave.some_flying = has_some_flying

			table.insert(o_group.waves, o_wave)
		end
	end

	o_group.interval = wave_interval == 0 and 100 or wave_interval

	if i > 0 and i % waves_per_load == 0 then
		dif_idx = km.clamp(1, dif_max, dif_idx + 1)
		next_dif_uses = 0
		used_waves = {}
	end

	db.vars.dif_idx = dif_idx
	db.vars.next_dif_uses = next_dif_uses
	db.vars.used_waves = used_waves

	log.paranoid("group %s:\n %s", i, getfulldump(o_group))

	return o_group
end

function wave_db:set_entity_progression(e, wave_idx)
	local function prog_value(key, raw_value)
		local t
		local tall = self.db.enemyProgression
		local tdefault = self.db.enemyProgression.DEFAULT

		if string.find(key, ".", 1, true) ~= nil then
			local parts = string.split(key, ".")

			t = self.db.enemyProgression

			for i = 1, #parts do
				t = t[parts[i]]
			end

			if not t then
				log.error("entity progression not found for key %s", key)

				return raw_value
			end
		elseif tall[e.template_name] and tall[e.template_name][key] then
			t = table.merge(tdefault[key] or {}, tall[e.template_name][key], true)
		else
			t = tdefault[key] or {}
		end

		if not self.db.vars.first_entity_wave[e.template_name] then
			self.db.vars.first_entity_wave[e.template_name] = wave_idx
		end

		local waves_count = wave_idx

		if t.activeAfterWave then
			if wave_idx < t.activeAfterWave then
				log.paranoid("(%s)%s - %s activeAfterWave %s", e.id, e.template_name, key, t.activeAfterWave)

				return raw_value
			end

			waves_count = waves_count - t.activeAfterWave
		else
			waves_count = waves_count - self.db.vars.first_entity_wave[e.template_name]
		end

		local mult, val

		if t.factor_steps and #t.factor_steps > 0 then
			local cycle = t.cicle or 1
			local step_idx = math.ceil(waves_count / cycle)

			step_idx = km.clamp(1, #t.factor_steps, step_idx)
			mult = t.factor_steps[step_idx]
			val = mult * raw_value
		else
			local factor = t.factor or 1
			local base = t.base or 1
			local cycle = t.cicle or 1

			mult = base * math.pow(factor, math.floor(waves_count / cycle))

			local limit = t.limit or factor > 1 and 99999 or -99999

			if factor > 1 then
				mult = math.min(mult, limit)
			elseif factor < 1 then
				mult = math.max(mult, limit)
			end

			val = mult * raw_value

			if t.limit_value then
				if factor < 1 then
					val = math.max(val, t.limit_value)
				else
					val = math.min(val, t.limit_value)
				end
			end
		end

		return val
	end

	local function prog_factor(key)
		return prog_value(key, 1)
	end

	if e.enemy then
		e.enemy.gold = km.clamp(0, e.enemy.gold, km.round(prog_value("gold", e.enemy.gold)))

		if e.health then
			e.health.hp_max = km.round(prog_value("health", e.health.hp_max))
			e.health.hp_max = km.round(prog_factor("megaHealth") * e.health.hp_max)
			e.health.armor = prog_value("armor", e.health.armor)
			e.health.magic_armor = prog_value("magicArmor", e.health.magic_armor)
		end

		if e.melee and e.melee.attacks[1] then
			local damage_factor = prog_factor("damage")

			e.melee.attacks[1].damage_max = km.round(damage_factor * e.melee.attacks[1].damage_max)
			e.melee.attacks[1].damage_min = km.round(damage_factor * e.melee.attacks[1].damage_min)
		end
	end

	if e.endless and e.endless.factor_map then
		for _, item in pairs(e.endless.factor_map) do
			local fmt

			fmt = item[3] and "e.%s = round(prog_value('%s', e.%s))" or "e.%s = prog_value('%s', e.%s)"

			local n = string.format(fmt, item[2], item[1], item[2])
			local nf = loadstring(n)
			local env = {}

			env.e = e
			env.wave_idx = wave_idx
			env.prog_value = prog_value
			env.round = km.round

			setfenv(nf, env)
			nf()
			log.paranoid("  ENDLESS - factor_map: %s", n)
		end
	end

	log.paranoid("ENDLESS - w:%s (%s)%s | factors - health:%s damage:%s gold:%s armor:%s magic_armor:%s megaHealth:%s ", wave_idx, e.id, e.template_name, prog_factor("health"), prog_factor("damage"), prog_factor("gold"), prog_factor("armor"), prog_factor("magicArmor"), prog_factor("megaHealth"))
end

return wave_db
