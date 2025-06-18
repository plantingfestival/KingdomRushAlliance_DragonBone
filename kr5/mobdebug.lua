-- chunkname: @./kr5/mobdebug.lua

local require = require

local function prequire(name)
	local ok, m = pcall(require, name)

	return ok and m or nil
end

local socket = require("socket")
local table = table or require("table")
local string = string or require("string")
local coroutine = coroutine or require("coroutine")
local debug = debug or require("debug")
local io = io or prequire("io")
local os = os or prequire("os")
local mobdebug = {
	yieldtimeout = 0.02,
	_DESCRIPTION = "Mobile Remote Debugger for the Lua programming language",
	_NAME = "mobdebug",
	_VERSION = "0.801",
	_COPYRIGHT = "Paul Kulchenko",
	checkcount = 200,
	connecttimeout = 2,
	port = os and os.getenv and tonumber((os.getenv("MOBDEBUG_PORT"))) or 8172
}
local HOOKMASK = "lcr"
local error = error
local getfenv = getfenv
local setfenv = setfenv
local loadstring = loadstring or load
local pairs = pairs
local setmetatable = setmetatable
local tonumber = tonumber
local unpack = table.unpack or unpack
local rawget = rawget
local string_format = string.format
local string_sub = string.sub
local string_find = string.find
local string_lower = string.lower
local string_gsub = string.gsub
local string_match = string.match
local genv = _G or _ENV
local jit = rawget(genv, "jit")
local MOAICoroutine = rawget(genv, "MOAICoroutine")
local ngx = rawget(genv, "ngx")
local corocreate = ngx and coroutine._create or coroutine.create
local cororesume = ngx and coroutine._resume or coroutine.resume
local coroyield = ngx and coroutine._yield or coroutine.yield
local corostatus = ngx and coroutine._status or coroutine.status
local corowrap = coroutine.wrap

if not setfenv then
	local function findenv(f)
		local level = 1

		repeat
			local name, value = debug.getupvalue(f, level)

			if name == "_ENV" then
				return level, value
			end

			level = level + 1
		until name == nil

		return nil
	end

	function getfenv(f)
		return select(2, findenv(f)) or _G
	end

	function setfenv(f, t)
		local level = findenv(f)

		if level then
			debug.setupvalue(f, level, t)
		end

		return f
	end
end

local win = os and os.getenv and (os.getenv("WINDIR") or (os.getenv("OS") or ""):match("[Ww]indows")) and true or false
local mac = not win and (os and os.getenv and os.getenv("DYLD_LIBRARY_PATH") or not io.open("/proc")) and true or false
local iscasepreserving = win or mac and io.open("/library") ~= nil
local coroutines = {}

setmetatable(coroutines, {
	__mode = "k"
})

local events = {
	RESTART = 3,
	WATCH = 2,
	STACK = 4,
	BREAK = 1
}
local PROTOCOLS = {
	VSCODE = 2,
	MOBDEBUG = 1
}
local deferror = "execution aborted at default debugee"

if jit and jit.off then
	jit.off()
end

local state = {
	stack_level = 0,
	basedir = "",
	logging = false,
	step_into = false,
	watchescnt = 0,
	step_over = false,
	step_level = 0,
	seen_hook = false,
	breakpoints = {},
	watches = {},
	debugee = function()
		local a = 1

		for _ = 1, 10 do
			a = a + 1
		end

		error(deferror)
	end,
	outputs = {}
}
local server, coro_debugger, coro_debugee, abort
local iobase = {
	print = print
}

local function q(s)
	return string_gsub(s, "([%(%)%.%%%+%-%*%?%[%^%$%]])", "%%%1")
end

local serpent = (function()
	local n, v = "serpent", "0.302"
	local c, d = "Paul Kulchenko", "Lua serializer and pretty printer"
	local snum = {
		[tostring(1 / 0)] = "1/0 --[[math.huge]]",
		[tostring(-1 / 0)] = "-1/0 --[[-math.huge]]",
		[tostring(0 / 0)] = "0/0"
	}
	local badtype = {
		userdata = true,
		cdata = true,
		thread = true
	}
	local getmetatable = debug and debug.getmetatable or getmetatable

	local function pairs(t)
		return next, t
	end

	local keyword = {}
	local globals = {}
	local keyword, globals, G = keyword, globals, _G or _ENV

	for _, k in ipairs({
		"and",
		"break",
		"do",
		"else",
		"elseif",
		"end",
		"false",
		"for",
		"function",
		"goto",
		"if",
		"in",
		"local",
		"nil",
		"not",
		"or",
		"repeat",
		"return",
		"then",
		"true",
		"until",
		"while"
	}) do
		keyword[k] = true
	end

	for k, v in pairs(G) do
		globals[v] = k
	end

	for _, g in ipairs({
		"coroutine",
		"debug",
		"io",
		"math",
		"string",
		"table",
		"os"
	}) do
		for k, v in pairs(type(G[g]) == "table" and G[g] or {}) do
			globals[v] = g .. "." .. k
		end
	end

	local function s(t, opts)
		local name, indent, fatal, maxnum = opts.name, opts.indent, opts.fatal, opts.maxnum
		local sparse, custom, huge = opts.sparse, opts.custom, not opts.nohuge
		local space = opts.compact and "" or " "
		local space, maxl = space, opts.maxlevel or math.huge
		local maxlen, metatostring = tonumber(opts.maxlength), opts.metatostring
		local iname = "_" .. (name or "")
		local iname, comm = iname, opts.comment and (tonumber(opts.comment) or math.huge)
		local numformat = opts.numformat or "%.17g"
		local seen, sref, syms, symn = {}, {
			"local " .. iname .. "={}"
		}, {}, 0

		local function gensym(val)
			return "_" .. tostring(tostring(val)):gsub("[^%w]", ""):gsub("(%d%w+)", function(s)
				if not syms[s] then
					symn = symn + 1
					syms[s] = symn
				end

				return tostring(syms[s])
			end)
		end

		local function safestr(s)
			return type(s) == "number" and tostring(huge and snum[tostring(s)] or numformat:format(s)) or type(s) ~= "string" and tostring(s) or ("%q"):format(s):gsub("\n", "n"):gsub("\x1A", "\\026")
		end

		local function comment(s, l)
			return comm and (l or 0) < comm and " --[[" .. select(2, pcall(tostring, s)) .. "]]" or ""
		end

		local function globerr(s, l)
			return globals[s] and globals[s] .. comment(s, l) or not fatal and safestr(select(2, pcall(tostring, s))) or error("Can't serialize " .. tostring(s))
		end

		local function safename(path, name)
			local n = name == nil and "" or name
			local plain = type(n) == "string" and n:match("^[%l%u_][%w_]*$") and not keyword[n]
			local safe = plain and n or "[" .. safestr(n) .. "]"

			return (path or "") .. (plain and path and "." or "") .. safe, safe
		end

		local alphanumsort = type(opts.sortkeys) == "function" and opts.sortkeys or function(k, o, n)
			local maxn, to = tonumber(n) or 12, {
				string = "b",
				number = "a"
			}

			local function padnum(d)
				return ("%0" .. tostring(maxn) .. "d"):format(tonumber(d))
			end

			table.sort(k, function(a, b)
				return (k[a] ~= nil and 0 or to[type(a)] or "z") .. tostring(a):gsub("%d+", padnum) < (k[b] ~= nil and 0 or to[type(b)] or "z") .. tostring(b):gsub("%d+", padnum)
			end)
		end

		local function val2str(t, name, indent, insref, path, plainindex, level)
			local ttype, level, mt = type(t), level or 0, getmetatable(t)
			local spath, sname = safename(path, name)
			local tag = plainindex and (type(name) == "number" and "" or name .. space .. "=" .. space) or name ~= nil and sname .. space .. "=" .. space or ""

			if seen[t] then
				sref[#sref + 1] = spath .. space .. "=" .. space .. seen[t]

				return tag .. "nil" .. comment("ref", level)
			end

			if type(mt) == "table" and metatostring ~= false then
				local to, tr = pcall(function()
					return mt.__tostring(t)
				end)
				local so, sr = pcall(function()
					return mt.__serialize(t)
				end)

				if to or so then
					seen[t] = insref or spath
					t = so and sr or tr
					ttype = type(t)
				end
			end

			if ttype == "table" then
				if level >= maxl then
					return tag .. "{}" .. comment("maxlvl", level)
				end

				seen[t] = insref or spath

				if next(t) == nil then
					return tag .. "{}" .. comment(t, level)
				end

				if maxlen and maxlen < 0 then
					return tag .. "{}" .. comment("maxlen", level)
				end

				local maxn, o, out = math.min(#t, maxnum or #t), {}, {}

				for key = 1, maxn do
					o[key] = key
				end

				if not maxnum or #o < maxnum then
					local n = #o

					for key in pairs(t) do
						if o[key] ~= key then
							n = n + 1
							o[n] = key
						end
					end
				end

				if maxnum and #o > maxnum then
					o[maxnum + 1] = nil
				end

				if opts.sortkeys and maxn < #o then
					alphanumsort(o, t, opts.sortkeys)
				end

				local sparse = sparse and maxn < #o

				for n, key in ipairs(o) do
					local value = t[key]
					local ktype = type(key)
					local value, ktype, plainindex = value, ktype, n <= maxn and not sparse

					if opts.valignore and opts.valignore[value] or opts.keyallow and not opts.keyallow[key] or opts.keyignore and opts.keyignore[key] or opts.valtypeignore and opts.valtypeignore[type(value)] or sparse and value == nil then
						-- block empty
					elseif ktype == "table" or ktype == "function" or badtype[ktype] then
						if not seen[key] and not globals[key] then
							sref[#sref + 1] = "placeholder"

							local sname = safename(iname, gensym(key))

							sref[#sref] = val2str(key, sname, indent, sname, iname, true)
						end

						sref[#sref + 1] = "placeholder"

						local path = seen[t] .. "[" .. tostring(seen[key] or globals[key] or gensym(key)) .. "]"

						sref[#sref] = path .. space .. "=" .. space .. tostring(seen[value] or val2str(value, nil, indent, path))
					else
						out[#out + 1] = val2str(value, key, indent, nil, seen[t], plainindex, level + 1)

						if maxlen then
							maxlen = maxlen - #out[#out]

							if maxlen < 0 then
								break
							end
						end
					end
				end

				local prefix = string.rep(indent or "", level)
				local head = indent and "{\n" .. prefix .. indent or "{"
				local body = table.concat(out, "," .. (indent and "\n" .. prefix .. indent or space))
				local tail = indent and "\n" .. prefix .. "}" or "}"

				return (custom and custom(tag, head, body, tail, level) or tag .. head .. body .. tail) .. comment(t, level)
			elseif badtype[ttype] then
				seen[t] = insref or spath

				return tag .. globerr(t, level)
			elseif ttype == "function" then
				seen[t] = insref or spath

				if opts.nocode then
					return tag .. "function() --[[..skipped..]] end" .. comment(t, level)
				end

				local ok, res = pcall(string.dump, t)
				local func = ok and "((loadstring or load)(" .. safestr(res) .. ",'@serialized'))" .. comment(t, level)

				return tag .. (func or globerr(t, level))
			else
				return tag .. safestr(t)
			end
		end

		local sepr = indent and "\n" or ";" .. space
		local body = val2str(t, name, indent)
		local tail = #sref > 1 and table.concat(sref, sepr) .. sepr or ""
		local warn = opts.comment and #sref > 1 and space .. "--[[incomplete output with shared/self-references skipped]]" or ""

		return not name and body .. warn or "do local " .. body .. sepr .. tail .. "return " .. name .. sepr .. "end"
	end

	local function deserialize(data, opts)
		local env = opts and opts.safe == false and G or setmetatable({}, {
			__index = function(t, k)
				return t
			end,
			__call = function(t, ...)
				error("cannot call functions")
			end
		})
		local f, res = (loadstring or load)("return " .. data, nil, nil, env)

		if not f then
			f, res = (loadstring or load)(data, nil, nil, env)
		end

		if not f then
			return f, res
		end

		if setfenv then
			setfenv(f, env)
		end

		return pcall(f)
	end

	local function merge(a, b)
		if b then
			for k, v in pairs(b) do
				a[k] = v
			end
		end

		return a
	end

	return {
		_NAME = n,
		_COPYRIGHT = c,
		_DESCRIPTION = d,
		_VERSION = v,
		serialize = s,
		load = deserialize,
		dump = function(a, opts)
			return s(a, merge({
				sparse = true,
				name = "_",
				compact = true
			}, opts))
		end,
		line = function(a, opts)
			return s(a, merge({
				sortkeys = true,
				comment = true
			}, opts))
		end,
		block = function(a, opts)
			return s(a, merge({
				sortkeys = true,
				indent = "  ",
				comment = true
			}, opts))
		end
	}
end)()
local Log = {}

do
	local io_open = io and io.open
	local io_flush = io and io.flush or function()
		return
	end
	local table_format_params = {
		comment = false,
		nocode = true
	}

	local function table_format(t)
		return serpent.block(t, table_format_params)
	end

	function Log.format(...)
		if not state.logging then
			return
		end

		Log.write("[MOBDEBUG]" .. string_format(...))
	end

	function Log.table(name, t)
		if not state.logging then
			return
		end

		Log.format("%s: %s", name, table_format(t))
	end

	function Log.write(msg)
		if state.logfile then
			local f = io_open(state.logfile, "a+")

			if f then
				f:write(msg, "\n")
				f:close()
			end
		end

		if mobdebug.print then
			mobdebug.print(msg)
			io_flush()
		end
	end
end

local Socket = {}

function Socket.new(s)
	local self = {}

	for k, v in pairs(Socket) do
		self[k] = v
	end

	self.s = s
	self.buf = nil

	return self
end

function Socket:buffer_append(data)
	if data and data ~= "" then
		if self.buf then
			self.buf = self.buf .. data
		else
			self.buf = data
		end
	end
end

function Socket:buffer_readn(n)
	if n == 0 then
		return ""
	end

	if not self.buf or n > #self.buf then
		return nil
	end

	local data = self.buf:sub(1, n)

	if #self.buf == n then
		self.buf = nil
	else
		self.buf = self.buf:sub(n + 1)
	end

	return data
end

function Socket:buffer_read_line()
	if not self.buf then
		return
	end

	local n = string_find(self.buf, "\n", nil, true)

	if not n then
		return
	end

	local line = self.buf:sub(1, n)

	self.buf = self.buf:sub(n + 2)

	if self.buf == "" then
		self.buf = nil
	end

	return line
end

function Socket:buffer_read_all()
	local data = self.buf

	self.buf = nil

	return data
end

function Socket:buffer_peek(n)
	if n == 0 then
		return ""
	end

	if not self.buf then
		return nil
	end

	if n > #self.buf then
		return nil
	end

	local res = self.buf:sub(1, n)

	return res
end

function Socket:buffer_size()
	return self.buf and #self.buf or 0
end

function Socket:settimeout(...)
	return self.s:settimeout(...)
end

function Socket:receive(...)
	return self.s:receive(...)
end

function Socket:peek(n, sync)
	local data = self:buffer_peek(n)

	if data then
		return data
	end

	local more = n - self:buffer_size()

	if sync == false then
		self:settimeout(0)
	end

	local res, err, partial = self:receive(n)

	if sync == false then
		self:settimeout()
	end

	self:buffer_append(res or partial)

	return self:buffer_peek(n)
end

function Socket:receive_line(sync)
	local line = self:buffer_read_line()

	if line then
		return line
	end

	if sync == false then
		self:settimeout(0)
	end

	local res, err, partial = self:receive("*l")

	if sync == false then
		self:settimeout()
	end

	self:buffer_append(res or partial)

	if not res then
		return nil, err
	end

	return self:buffer_read_all()
end

function Socket:receive_nread(n, sync)
	local data = self:buffer_readn(n)

	if data then
		return data
	end

	local more = n - self:buffer_size()

	if sync == false then
		self:settimeout(0)
	end

	local res, err, partial = self:receive(n)

	if sync == false then
		self:settimeout()
	end

	self:buffer_append(res or partial)

	data = self:buffer_readn(n)

	if not data then
		return nil, err
	end

	return data
end

function Socket:send(...)
	return self.s:send(...)
end

function Socket:nsend(str)
	local total_sent, attempt = 0, 5

	while total_sent < #str do
		local sent, err = self:send(str, total_sent + 1)

		if sent then
			if send == 0 then
				attempt = attempt - 1

				if attempt == 0 then
					return nil, err or "no progress"
				end
			else
				total_sent = total_sent + sent
			end
		else
			return nil, err, total_sent
		end
	end

	return true
end

function Socket:is_pending()
	if self:buffer_size() == 0 and self.checkcount >= mobdebug.checkcount then
		self:settimeout(0)

		local res, err, part = self:receive(1)

		self:settimeout()
		self:buffer_append(res or part)

		self.checkcount = 0
	else
		self.checkcount = self.checkcount + 1
	end

	return self:buffer_size() > 0
end

function Socket:enforce_pending_check()
	self.checkcount = mobdebug.checkcount
end

function Socket:close()
	if self.s then
		self.s:close()

		self.buf = nil
		self.s = nil
	end
end

local debugger = {}

mobdebug.line = serpent.line
mobdebug.dump = serpent.dump
mobdebug.linemap = nil
mobdebug.loadstring = loadstring
mobdebug.print = print

local function is_abs_path(file)
	return string_match(file, "^\\\\") or string_match(file, "^/") or string_match(file, "^.:")
end

local function removebasedir(path, basedir)
	if not iscasepreserving then
		return string_gsub(path, "^" .. q(basedir), "")
	end

	if string_find(string_lower(path), "^" .. q(string_lower(basedir))) then
		return string_sub(path, #basedir + 1)
	end

	return path
end

local function normalize_path(file)
	local n

	repeat
		file, n = file:gsub("/+%.?/+", "/")
	until n == 0

	repeat
		file, n = file:gsub("[^/]+/%.%./", "", 1)
	until n == 0

	return (file:gsub("^(/?)%.%./", "%1"))
end

local function is_soucer_file_path(file)
	return string_find(file, "^@") or not string_find(file, "[\r\n]")
end

local function normalize_source_file(file)
	file = string_gsub(string_gsub(file, "^@", ""), "\\", "/")

	if string_find(file, "^%.%.?/") then
		file = state.basedir .. file
	end

	if string_find(file, "/%.%.?/") then
		file = normalize_path(file)
	end

	if string_find(file, "^%./") then
		file = string_sub(file, 3)
	end

	if iscasepreserving then
		file = string_lower(file)
	end

	file = string_gsub(file, "^" .. q(state.basedir), "")
	file = string_gsub(file, "\n", " ")

	return file
end

local function set_basedir(dir)
	if iscasepreserving then
		dir = string_lower(dir)
	end

	dir = string_gsub(dir, "\\", "/")
	dir = string_gsub(dir, "/+$", "") .. "/"
	state.basedir = dir
	state.lastsource = nil

	Log.format("Base dir: %s", state.basedir)
end

local function stack(start)
	local function vars(f)
		local func = debug.getinfo(f, "f").func
		local i = 1
		local locals = {}

		while true do
			local name, value = debug.getlocal(f, i)

			if not name then
				break
			end

			if string_sub(name, 1, 1) ~= "(" then
				locals[name] = {
					value,
					select(2, pcall(tostring, value))
				}
			end

			i = i + 1
		end

		i = 1

		while true do
			local name, value = debug.getlocal(f, -i)

			if not name then
				break
			end

			locals[name:gsub("%)$", " " .. i .. ")")] = {
				value,
				select(2, pcall(tostring, value))
			}
			i = i + 1
		end

		i = 1

		local ups = {}

		while func do
			local name, value = debug.getupvalue(func, i)

			if not name then
				break
			end

			ups[name] = {
				value,
				select(2, pcall(tostring, value))
			}
			i = i + 1
		end

		return locals, ups
	end

	local stack = {}
	local linemap = mobdebug.linemap

	for i = start or 0, 100 do
		local source = debug.getinfo(i, "Snl")

		if not source then
			break
		end

		local src = source.source

		if src:find("@") == 1 then
			src = src:sub(2):gsub("\\", "/")

			if src:find("%./") == 1 then
				src = src:sub(3)
			end
		end

		table.insert(stack, {
			{
				source.name,
				removebasedir(src, state.basedir),
				linemap and linemap(source.linedefined, source.source) or source.linedefined,
				linemap and linemap(source.currentline, source.source) or source.currentline,
				source.what,
				source.namewhat,
				source.short_src
			},
			vars(i + 1)
		})
	end

	return stack
end

local function set_breakpoint(file, line)
	if file == "-" and state.lastfile then
		file = state.lastfile
	elseif iscasepreserving then
		file = string_lower(file)
	end

	if not state.breakpoints[line] then
		state.breakpoints[line] = {}
	end

	state.breakpoints[line][file] = true
end

local function remove_breakpoint(file, line)
	if file == "-" and state.lastfile then
		file = state.lastfile
	elseif file == "*" and line == 0 then
		state.breakpoints = {}
	elseif iscasepreserving then
		file = string_lower(file)
	end

	if state.breakpoints[line] then
		state.breakpoints[line][file] = nil
	end
end

local function remove_file_breakpoint(file)
	if iscasepreserving then
		file = string_lower(file)
	end

	for line, file_breakpoints in pairs(state.breakpoints) do
		file_breakpoints[file] = nil
	end
end

local function has_breakpoint(file, line)
	return state.breakpoints[line] and state.breakpoints[line][iscasepreserving and string_lower(file) or file]
end

local function restore_vars(vars)
	if type(vars) ~= "table" then
		return
	end

	local i = 1

	while true do
		local name = debug.getlocal(3, i)

		if not name then
			break
		end

		i = i + 1
	end

	i = i - 1

	local written_vars = {}

	while i > 0 do
		local name = debug.getlocal(3, i)

		if not written_vars[name] then
			if string_sub(name, 1, 1) ~= "(" then
				debug.setlocal(3, i, rawget(vars, name))
			end

			written_vars[name] = true
		end

		i = i - 1
	end

	i = 1

	local func = debug.getinfo(3, "f").func

	while true do
		local name = debug.getupvalue(func, i)

		if not name then
			break
		end

		if not written_vars[name] then
			if string_sub(name, 1, 1) ~= "(" then
				debug.setupvalue(func, i, rawget(vars, name))
			end

			written_vars[name] = true
		end

		i = i + 1
	end
end

local function capture_vars(level, thread)
	level = (level or 0) + 2

	local func = (thread and debug.getinfo(thread, level, "f") or debug.getinfo(level, "f") or {}).func

	if not func then
		return {}
	end

	local vars = {
		["..."] = {}
	}
	local i = 1

	while true do
		local name, value = debug.getupvalue(func, i)

		if not name then
			break
		end

		if string_sub(name, 1, 1) ~= "(" then
			vars[name] = value
		end

		i = i + 1
	end

	i = 1

	while true do
		local name, value

		if thread then
			name, value = debug.getlocal(thread, level, i)
		else
			name, value = debug.getlocal(level, i)
		end

		if not name then
			break
		end

		if string_sub(name, 1, 1) ~= "(" then
			vars[name] = value
		end

		i = i + 1
	end

	i = 1

	while true do
		local name, value

		if thread then
			name, value = debug.getlocal(thread, level, -i)
		else
			name, value = debug.getlocal(level, -i)
		end

		if not name then
			break
		end

		vars["..."][i] = value
		i = i + 1
	end

	setmetatable(vars, {
		__mode = "v",
		__index = getfenv(func),
		__newindex = getfenv(func)
	})

	return vars
end

local function stack_depth(start_depth)
	for i = start_depth, 0, -1 do
		if debug.getinfo(i, "l") then
			return i + 1
		end
	end

	return start_depth
end

local function is_safe(stack_level)
	if stack_level == 3 then
		return true
	end

	for i = 3, stack_level do
		local info = debug.getinfo(i, "S")

		if not info then
			return true
		end

		if info.what == "C" then
			return false
		end
	end

	return true
end

local function in_debugger()
	local this = debug.getinfo(1, "S").source

	for i = 3, 9 do
		local info = debug.getinfo(i, "S")

		if not info then
			return false
		end

		if info.source == this then
			return true
		end
	end

	return false
end

local function debug_hook(event, line)
	if jit and (not ngx or type(ngx) ~= "table" or not ngx.say) then
		local coro, main = coroutine.running()

		if not coro or main then
			coro = "main"
		end

		local disabled = coroutines[coro] == false or coroutines[coro] == nil and coro ~= (coro_debugee or "main")

		if coro_debugee and disabled or not coro_debugee and (disabled or in_debugger()) then
			return
		end
	end

	if abort and is_safe(state.stack_level) then
		error(abort)
	end

	if not state.seen_hook and in_debugger() then
		return
	end

	if event == "call" then
		state.stack_level = state.stack_level + 1
	elseif event == "return" or event == "tail return" then
		state.stack_level = state.stack_level - 1
	elseif event == "line" then
		if mobdebug.linemap then
			local ok, mappedline = pcall(mobdebug.linemap, line, debug.getinfo(2, "S").source)

			if ok then
				line = mappedline
			end

			if not line then
				return
			end
		end

		if not state.step_into and not state.step_over and not state.breakpoints[line] and not (state.watchescnt > 0) and not server:is_pending() then
			return
		end

		server:enforce_pending_check()

		state.stack_level = stack_depth(state.stack_level + 1)

		local caller = debug.getinfo(2, "S")

		if caller.source == "=(command line)" then
			return
		end

		local file = state.lastfile

		if state.lastsource ~= caller.source then
			file, state.lastsource = caller.source, caller.source

			if is_soucer_file_path(file) then
				file = normalize_source_file(file)
			else
				file = mobdebug.line(file)
			end

			Log.format("NORM: %s -> %s", state.lastsource, file)

			state.seen_hook = true
			state.lastfile = file
		end

		local possible_pending_io = debugger.loop_pending_io()
		local vars, status, res

		if state.watchescnt > 0 then
			vars = capture_vars(1)

			for index, value in pairs(state.watches) do
				setfenv(value, vars)

				local ok, fired = pcall(value)

				if ok and fired then
					status, res = cororesume(coro_debugger, events.WATCH, vars, file, line, index)

					break
				end
			end
		end

		local getin = status == nil and (state.step_into or state.step_over and state.step_over == (coroutine.running() or "main") and state.stack_level <= state.step_level or has_breakpoint(file, line) or possible_pending_io == true)

		if getin then
			vars = vars or capture_vars(1)
			state.step_into = false
			state.step_over = false
			status, res = cororesume(coro_debugger, events.BREAK, vars, file, line)
		end

		while status and res == "stack" do
			if vars then
				restore_vars(vars)
			end

			status, res = cororesume(coro_debugger, events.STACK, stack(3), file, line)
		end

		if status and res and res ~= "stack" then
			if not abort and res == "exit" then
				mobdebug.onexit(1, true)

				return
			end

			if not abort and res == "done" then
				mobdebug.done()

				return
			end

			abort = res

			if is_safe(state.stack_level) then
				error(abort)
			end
		elseif not status and res then
			error(res, 2)
		end

		if vars then
			restore_vars(vars)
		end

		if state.step_over == true then
			state.step_over = coroutine.running() or "main"
		end
	end
end

local function isrunning()
	return coro_debugger and (corostatus(coro_debugger) == "suspended" or corostatus(coro_debugger) == "running")
end

local function done()
	if not isrunning() or not server then
		return
	end

	if not jit then
		for co, debugged in pairs(coroutines) do
			if debugged then
				debug.sethook(co)
			end
		end
	end

	debug.sethook()
	server:close()

	coro_debugger = nil
	state.seen_hook = nil
	abort = nil
	state.basedir = ""
end

local mobdebug_debugger = {}

do
	local function stringify_results(params, status, ...)
		if not status then
			return status, ...
		end

		params = params or {}

		if params.nocode == nil then
			params.nocode = true
		end

		if params.comment == nil then
			params.comment = 1
		end

		local t = {
			...
		}

		for i, v in pairs(t) do
			local ok, res = pcall(mobdebug.line, v, params)

			t[i] = ok and res or ("%q"):format(res):gsub("\n", "n"):gsub("\x1A", "\\026")
		end

		return pcall(mobdebug.dump, t, {
			sparse = false
		})
	end

	function mobdebug_debugger.path_to_ide(file)
		return file
	end

	function mobdebug_debugger.path_from_ide(file)
		return file
	end

	function mobdebug_debugger.send_response(status, message, data)
		if data then
			local msg = string_format("%d %s %d\n", status, message, #data)
			local ok, err = server:nsend(msg)

			if not ok then
				return nil, err
			end

			return server:nsend(data)
		end

		local msg = string_format("%d %s\n", status, message)

		return server:nsend(msg)
	end

	function mobdebug_debugger.send_ok_response(data)
		return mobdebug_debugger.send_response(200, "OK", data)
	end

	function mobdebug_debugger.send_bad_request_response(data)
		return mobdebug_debugger.send_response(400, "Bad Request", data)
	end

	function mobdebug_debugger.send_expression_error_response(data)
		return mobdebug_debugger.send_response(401, "Error in Expression", data)
	end

	function mobdebug_debugger.send_execution_error_response(data)
		return mobdebug_debugger.send_response(401, "Error in Execution", data)
	end

	function mobdebug_debugger.send_params_response(code, ...)
		return mobdebug_debugger.send_response(code, string_format(...))
	end

	function mobdebug_debugger.load_params(line)
		local params = string.match(line, "--%s*(%b{})%s*$")
		local pfunc = params and loadstring("return " .. params)

		params = pfunc and pfunc()
		params = type(params) == "table" and params or {}

		return params
	end

	function mobdebug_debugger.parse_breackpoint_command(line)
		local _, _, cmd, file, line_no = string_find(line, "^([A-Z]+)%s+(.-)%s+(%d+)%s*$")
		local local_file = mobdebug_debugger.path_from_ide(file)

		Log.format("breakpoint path: %s -> %s", file, local_file)

		return local_file, tonumber(line_no), cmd
	end

	function mobdebug_debugger.parse_exec_command(line)
		local _, _, chunk = string_find(line, "^[A-Z]+%s+(.+)$")

		if not chunk then
			return
		end

		local params = mobdebug_debugger.load_params(line)

		return chunk, params
	end

	function mobdebug_debugger.parse_load_command(line)
		local _, _, size, name = string_find(line, "^[A-Z]+%s+(%d+)%s+(%S.-)%s*$")

		size = tonumber(size)

		local chunk = server:receive_nread(size)

		return size, name, chunk
	end

	function mobdebug_debugger.parse_set_watch_command(line)
		local _, _, exp = string_find(line, "^[A-Z]+%s+(.+)%s*$")

		return exp
	end

	function mobdebug_debugger.parse_del_watch_command(line)
		local _, _, index = string_find(line, "^[A-Z]+%s+(%d+)%s*$")

		return tonumber(index)
	end

	function mobdebug_debugger.parse_set_basedir_command(line)
		local _, _, dir = string_find(line, "^[A-Z]+%s+(.+)%s*$")

		return dir
	end

	function mobdebug_debugger.parse_stack_command(line)
		return mobdebug_debugger.load_params(line)
	end

	function mobdebug_debugger.parse_output_command(line)
		local _, _, stream, mode = string_find(line, "^[A-Z]+%s+(%w+)%s+([dcr])%s*$")

		return stream, mode
	end

	function mobdebug_debugger.loop(sev, svars, sfile, sline)
		local command, arguments
		local eval_env = svars or {}

		local function emptyWatch()
			return false
		end

		local loaded = {}

		for k in pairs(package.loaded) do
			loaded[k] = true
		end

		while true do
			local line, err

			if mobdebug.yield and server.settimeout then
				server:settimeout(mobdebug.yieldtimeout)
			end

			while true do
				line, err = server:receive_line()

				if line then
					break
				end

				if err == "timeout" then
					if mobdebug.yield then
						mobdebug.yield()
					end
				elseif err == "closed" then
					error("Debugger connection closed", 0)
				else
					error(("Unexpected socket error: %s"):format(err), 0)
				end
			end

			if server.settimeout then
				server:settimeout()
			end

			command = string_sub(line, string_find(line, "^[A-Z]+"))

			if command == "SETB" then
				local file, line = mobdebug_debugger.parse_breackpoint_command(line)

				if file and line then
					set_breakpoint(file, line)
					mobdebug_debugger.send_ok_response()
				else
					mobdebug_debugger.send_bad_request_response()
				end
			elseif command == "DELB" then
				local file, line = mobdebug_debugger.parse_breackpoint_command(line)

				if file and line then
					remove_breakpoint(file, tonumber(line))
					mobdebug_debugger.send_ok_response()
				else
					mobdebug_debugger.send_bad_request_response()
				end
			elseif command == "EXEC" then
				local chunk, params = mobdebug_debugger.parse_exec_command(line)

				if chunk then
					local func, res = mobdebug.loadstring(chunk)
					local status

					if func then
						local stack = tonumber(params.stack)
						local env = stack and coro_debugee and capture_vars(stack - 1, coro_debugee) or eval_env

						setfenv(func, env)

						status, res = stringify_results(params, pcall(func, unpack(rawget(env, "...") or {})))

						if status and mobdebug.onscratch then
							mobdebug.onscratch(res)
						end
					end

					if status then
						mobdebug_debugger.send_ok_response(res)
					else
						res = res or "Unknown error"

						mobdebug_debugger.send_expression_error_response(res)
					end
				else
					mobdebug_debugger.send_bad_request_response()
				end
			elseif command == "LOAD" then
				local size, name, chunk = mobdebug_debugger.parse_load_command(line)

				if not size then
					mobdebug_debugger.send_bad_request_response()
				elseif abort == nil then
					if sfile and sline then
						mobdebug_debugger.send_params_response(201, "Started %s %d", sfile, sline)
					else
						mobdebug_debugger.send_ok_response("")
					end
				else
					for k in pairs(package.loaded) do
						if not loaded[k] then
							package.loaded[k] = nil
						end
					end

					if size == 0 and name == "-" then
						mobdebug_debugger.send_ok_response("")
						coroyield("load")
					elseif chunk then
						local func, res = mobdebug.loadstring(chunk, "@" .. name)

						if func then
							mobdebug_debugger.send_ok_response("")

							state.debugee = func

							coroyield("load")
						else
							mobdebug_debugger.send_expression_error_response(res)
						end
					else
						mobdebug_debugger.send_bad_request_response()
					end
				end
			elseif command == "SETW" then
				local exp = mobdebug_debugger.parse_set_watch_command(line)

				if exp then
					local func, res = mobdebug.loadstring("return(" .. exp .. ")")

					if func then
						state.watchescnt = state.watchescnt + 1

						local newidx = #state.watches + 1

						state.watches[newidx] = func

						mobdebug_debugger.send_params_response(200, "OK %d", newidx)
					else
						mobdebug_debugger.send_expression_error_response(res)
					end
				else
					mobdebug_debugger.send_bad_request_response()
				end
			elseif command == "DELW" then
				local index = mobdebug_debugger.parse_del_watch_command(line)

				if index and index > 0 and index <= #state.watches then
					state.watchescnt = state.watchescnt - (state.watches[index] ~= emptyWatch and 1 or 0)
					state.watches[index] = emptyWatch

					mobdebug_debugger.send_ok_response()
				else
					mobdebug_debugger.send_bad_request_response()
				end
			elseif command == "RUN" or command == "STEP" or command == "OVER" or command == "OUT" then
				mobdebug_debugger.send_ok_response()

				if command == "RUN" then
					state.step_into = false
					state.step_over = false
				elseif command == "STEP" then
					state.step_into = true
					state.step_over = false
				elseif command == "OVER" or command == "OUT" then
					state.step_into = false
					state.step_over = true
					state.step_level = command == "OVER" and state.stack_level or state.stack_level - 1
				end

				local ev, vars, file, line, idx_watch = coroyield()

				if ev == events.BREAK or ev == events.WATCH then
					file = file and mobdebug_debugger.path_to_ide(file)
				end

				eval_env = vars

				if ev == events.BREAK then
					mobdebug_debugger.send_params_response(202, "Paused %s %d", file, line)
				elseif ev == events.WATCH then
					mobdebug_debugger.send_params_response(203, "Paused %s %d %d", file, line, idx_watch)
				elseif ev == events.RESTART then
					-- block empty
				else
					mobdebug_debugger.send_execution_error_response(file)
				end
			elseif command == "BASEDIR" then
				local dir = mobdebug_debugger.parse_set_basedir_command(line)

				if dir then
					set_basedir(dir)
					mobdebug_debugger.send_ok_response()
				else
					mobdebug_debugger.send_bad_request_response()
				end
			elseif command == "SUSPEND" then
				-- block empty
			elseif command == "DONE" then
				coroyield("done")

				return
			elseif command == "STACK" then
				local ev, vars

				if state.seen_hook then
					ev, vars = coroyield("stack")
				else
					ev, vars = events.STACK, {}
				end

				if ev ~= events.STACK then
					mobdebug_debugger.send_execution_error_response(vars)
				else
					local params = mobdebug_debugger.parse_stack_command(line)

					if params.nocode == nil then
						params.nocode = true
					end

					if params.sparse == nil then
						params.sparse = false
					end

					if tonumber(params.maxlevel) then
						params.maxlevel = tonumber(params.maxlevel) + 4
					end

					local ok, res = pcall(mobdebug.dump, vars, params)

					if ok then
						mobdebug_debugger.send_params_response(200, "OK %s", tostring(res))
					else
						mobdebug_debugger.send_execution_error_response(res)
					end
				end
			elseif command == "OUTPUT" then
				local stream, mode = mobdebug_debugger.parse_output_command(line)

				if stream and mode and stream == "stdout" then
					local default = mode == "d"

					genv.print = default and iobase.print or corowrap(function()
						while true do
							local tbl = {
								coroutine.yield()
							}

							if mode == "c" then
								iobase.print(unpack(tbl))
							end

							for n = 1, #tbl do
								tbl[n] = select(2, pcall(mobdebug.line, tbl[n], {
									comment = false,
									nocode = true
								}))
							end

							local file = table.concat(tbl, "\t") .. "\n"

							mobdebug_debugger.send_response(204, "Output " .. stream, file)
						end
					end)

					if not default then
						genv.print()
					end

					mobdebug_debugger.send_ok_response()
				else
					mobdebug_debugger.send_bad_request_response()
				end
			elseif command == "EXIT" then
				mobdebug_debugger.send_ok_response()
				coroyield("exit")
			else
				mobdebug_debugger.send_bad_request_response()
			end
		end
	end

	function mobdebug_debugger.pending_io()
		local possible_pending_io = false

		while server:is_pending() do
			server:enforce_pending_check()

			local ch = server:peek(1, false)

			if ch ~= "S" and ch ~= "D" then
				break
			end

			local err

			ch, err = server:peek(2, false)

			if ch ~= "SE" and ch ~= "DE" then
				possible_pending_io = err == "timeout"

				break
			end

			ch, err = server:peek(5, false)

			if ch ~= "SETB " and ch ~= "DELB " then
				possible_pending_io = err == "timeout"

				break
			end

			local line

			line, err = server:receive_line(true)

			if not line then
				possible_pending_io = err == "timeout"

				break
			end

			local file, line_no, cmd = mobdebug_debugger.parse_breackpoint_command(line)

			if cmd == "SETB" then
				set_breakpoint(file, line_no)
			elseif cmd == "DELB" then
				remove_breakpoint(file, line_no)
			else
				Log.format("unexpected command: %s", line)

				break
			end
		end

		if possible_pending_io then
			return false
		end

		return not not server:is_pending()
	end
end

local vscode_debugger = {}

do
	local json = prequire("dkjson")
	local vscode_message_size
	local vscode_thread_id = 0
	local vscode_thread_name = "main"
	local vscode_init_failure = false
	local vscode_scope_offset = 1000000
	local vscode_scope_types = {
		Locals = 1,
		Upvalues = 2
	}
	local vscode_variables_ref, vscode_variables_map, vscode_fetched_message, vscode_dir_sep
	local vscode_stop_on_entry = false
	local vscode_pathmap

	local function pcall_vararg_pack(status, ...)
		if not status then
			return status, ...
		end

		return status, {
			n = select("#", ...),
			...
		}
	end

	local fix_file_name

	do
		local function isSameAs(f1, f2)
			return f1 == f2 or iscaseinsensitive and string_lower(f1) == string_lower(f2)
		end

		local function filePathMatch(file, pattern)
			return #file >= #pattern and isSameAs(string_sub(file, 1, #pattern), pattern)
		end

		function fix_file_name(reverse, file)
			if vscode_pathmap then
				for _, map in ipairs(vscode_pathmap) do
					local pattern, substitution = map[reverse and 2 or 1], map[reverse and 1 or 2]

					if filePathMatch(file, pattern) then
						file = substitution .. string_sub(file, #pattern + 1)

						break
					end
				end
			end

			return file
		end
	end

	function vscode_debugger.path_to_ide(file)
		if not is_abs_path(file) then
			file = state.basedir .. file
		end

		file = fix_file_name(false, file)
		file = string_gsub(file, "/", vscode_dir_sep)

		return file
	end

	function vscode_debugger.path_from_ide(file)
		file = normalize_source_file(file)

		return fix_file_name(true, file)
	end

	function vscode_debugger.proto_error(message)
		error("[MOBDEBUG][PROTOCOL ERROR] " .. message, 2)
	end

	function vscode_debugger.receive_message(sync)
		if vscode_fetched_message then
			local res = vscode_fetched_message

			vscode_fetched_message = nil

			return res
		end

		if sync == false and not server:is_pending() then
			return
		end

		if not vscode_message_size then
			local header, err = server:receive_line(sync, sync)

			if not header then
				return nil, err
			end

			if string_sub(header, 1, 1) ~= "#" then
				return vscode_debugger.proto_error("Invalid header:" .. header)
			end

			vscode_message_size = tonumber(string_sub(header, 2))

			if not vscode_message_size or vscode_message_size < 0 then
				return vscode_debugger.proto_error("Invalid header:" .. header)
			end
		end

		local message, err = server:receive_nread(vscode_message_size, sync)

		if not message then
			return nil, err
		end

		vscode_message_size = nil

		local decoded_message = json.decode(message)

		if not decoded_message then
			return vscode_debugger.proto_error("Invalid message:" .. message)
		end

		return decoded_message
	end

	function vscode_debugger.push_back_message(msg)
		vscode_fetched_message = msg
	end

	function vscode_debugger.send_message(msg)
		local data = json.encode(msg)
		local ok, err = server:nsend(string_format("#%d\n%s", #data, data))

		if not ok then
			error("[MOBDEUG][SEND ERROR]: " .. err)
		end
	end

	function vscode_debugger.send_success(req, body)
		vscode_debugger.send_message({
			type = "response",
			success = true,
			request_seq = req.seq,
			command = req.command,
			body = body
		})
	end

	function vscode_debugger.send_failure(req, msg)
		vscode_debugger.send_message({
			type = "response",
			success = false,
			request_seq = req.seq,
			command = req.command,
			message = msg
		})
	end

	function vscode_debugger.send_event(eventName, body)
		vscode_debugger.send_message({
			type = "event",
			event = eventName,
			body = body
		})
	end

	function vscode_debugger.send_console(str)
		vscode_debugger.send_event("output", {
			category = "console",
			output = str
		})
	end

	function vscode_debugger.send_stdout(str)
		vscode_debugger.send_event("output", {
			category = "stdout",
			output = str
		})
	end

	function vscode_debugger.send_stderr(str)
		vscode_debugger.send_event("output", {
			category = "stderr",
			output = str
		})
	end

	function vscode_debugger.send_stop_event(reason)
		vscode_debugger.send_event("stopped", {
			allThreadsStopped = true,
			reason = reason,
			threadId = vscode_thread_id
		})
	end

	function vscode_debugger.loop(sev, svars, sfile, sline)
		local command, args
		local eval_env = svars or {}
		local loaded = {}

		for k in pairs(package.loaded) do
			loaded[k] = true
		end

		while true do
			local req, err

			if mobdebug.yield and server.settimeout then
				server:settimeout(mobdebug.yieldtimeout)
			end

			while true do
				req, err = vscode_debugger.receive_message()

				if req then
					break
				end

				if err == "timeout" then
					if mobdebug.yield then
						mobdebug.yield()
					end
				elseif err == "closed" then
					error("Debugger connection closed", 0)
				else
					error(("Unexpected socket error: %s"):format(err), 0)
				end
			end

			if server.settimeout then
				server:settimeout()
			end

			command, args = req.command, req.arguments or {}

			Log.format("New command: %s", tostring(command))

			if command == "welcome" then
				set_basedir(args.sourceBasePath)

				vscode_dir_sep = args.directorySeperator
				vscode_stop_on_entry = args.stopOnEntry
				vscode_pathmap = args.pathMap
				vscode_init_failure = false
			elseif command == "configurationDone" then
				if vscode_init_failure then
					vscode_debugger.send_failure(req, "Initialization failure")
				else
					vscode_debugger.send_success(req, {})

					if vscode_stop_on_entry then
						vscode_debugger.send_stop_event("entry")
					else
						state.step_into = false
						state.step_over = false

						local ev, vars, file, line, idx_watch = coroyield()

						eval_env = vars

						if ev == events.BREAK then
							vscode_debugger.send_stop_event("breakpoint")
						elseif ev == events.WATCH then
							vscode_debugger.send_stop_event("breakpoint")
						elseif ev == events.RESTART then
							-- block empty
						else
							vscode_debugger.send_stop_event("exception")
							vscode_debugger.send_stderr(file)
						end
					end
				end
			elseif command == "threads" then
				local result = {
					{
						id = vscode_thread_id,
						name = vscode_thread_name
					}
				}

				vscode_debugger.send_success(req, {
					threads = result
				})
			elseif command == "setBreakpoints" then
				local file = vscode_debugger.path_from_ide(args.source.path)

				remove_file_breakpoint(file)

				local result = {}

				for i, breakpoint in ipairs(args.breakpoints) do
					set_breakpoint(file, breakpoint.line)

					result[i] = {
						verified = true,
						line = breakpoint.line
					}
				end

				vscode_debugger.send_success(req, {
					breakpoints = result
				})
			elseif command == "stackTrace" then
				vscode_variables_ref = {}

				if not state.seen_hook then
					vscode_debugger.send_success(req, {
						stackFrames = {}
					})
				else
					local ev, frames = coroyield("stack")

					if ev ~= events.STACK then
						vscode_debugger.send_failure(req, tostring(frames))
					else
						local result = {}
						local start_frame = args.startFrame or 0
						local levels = args.levels or 20

						for i = 0, levels - 1 do
							local level = start_frame + i
							local stack = frames[level + 1]

							if not stack then
								break
							end

							local frame = stack[1]
							local source_name = frame[1]
							local file_path = frame[2]
							local linedefined = frame[3]
							local currentline = frame[4]
							local source_what = frame[5]
							local source_namewhat = frame[6]
							local source_short_src = frame[7]

							if not frames[level + 2] and source_what == "C" then
								break
							end

							result[#result + 1] = {
								column = 1,
								id = level,
								name = source_name or "?",
								source = {
									path = vscode_debugger.path_to_ide(file_path)
								},
								line = currentline
							}
						end

						vscode_debugger.send_success(req, {
							stackFrames = result
						})
					end
				end
			elseif command == "scopes" then
				local frameId = args.frameId or 0
				local scopes = {}

				scopes[#scopes + 1] = {
					expensive = false,
					name = "Locals",
					variablesReference = (frameId + 1) * vscode_scope_offset + vscode_scope_types.Locals
				}
				scopes[#scopes + 1] = {
					expensive = false,
					name = "Upvalues",
					variablesReference = (frameId + 1) * vscode_scope_offset + vscode_scope_types.Upvalues
				}

				local result = {
					scopes = scopes
				}

				vscode_debugger.send_success(req, result)
			elseif command == "variables" then
				if not state.seen_hook then
					vscode_debugger.send_success(req, {
						variables = {}
					})
				else
					local ref, result, vars = args.variablesReference, {}
					local is_scope = ref > vscode_scope_offset

					if is_scope then
						local ev, frames = coroyield("stack")

						if ev ~= events.STACK then
							vscode_debugger.send_failure(req, tostring(frames))
						else
							local frameId = math.floor(ref / vscode_scope_offset) - 1
							local scopeType = ref % vscode_scope_offset + 1
							local frame = frames[frameId + 1]

							vars = frame[scopeType]
						end
					else
						vars = vscode_variables_ref[ref]
					end

					if vars then
						for name, var in pairs(vars) do
							if type(name) == "number" then
								name = "[" .. tostring(name) .. "]"
							else
								name = tostring(name)
							end

							local value, string_value

							if is_scope then
								value, string_value = var[1], var[2]
							else
								value, string_value = var, tostring(var)
							end

							local vt = type(value)

							if vt == "table" then
								ref = #vscode_variables_ref + 1
								vscode_variables_ref[ref] = value
							else
								ref = -1
							end

							result[#result + 1] = {
								name = name,
								type = vt,
								variablesReference = ref,
								value = string_value
							}
						end

						vscode_debugger.send_success(req, {
							variables = result
						})
					end
				end
			elseif command == "evaluate" then
				if not state.seen_hook then
					vscode_debugger.send_failure(req, "Invalid state")
				else
					Log.table("evaluate", req)

					local chunk = args.expression
					local func, res = mobdebug.loadstring(string_format("return (%s)", chunk))
					local status

					if func then
						local stack = args.frameId

						if stack == 0 then
							stack = nil
						end

						local env = stack and coro_debugee and capture_vars(stack - 1, coro_debugee) or eval_env

						setfenv(func, env)

						status, res = pcall_vararg_pack(pcall(func, unpack(rawget(env, "...") or {})))
					end

					if status then
						Log.table("res", res)

						if res.n == 0 then
							vscode_debugger.send_success(req, {})
						else
							local value = res[1]
							local vt, ref = type(value), -1

							if vt == "table" then
								ref = #vscode_variables_ref + 1
								vscode_variables_ref[ref] = value
							end

							vscode_debugger.send_success(req, {
								result = tostring(value),
								type = vt,
								variablesReference = ref
							})
						end
					else
						res = res or "Unknown error"
						res = string_gsub(res, ".-:%d+:%s*", "")

						vscode_debugger.send_failure(req, res)
					end
				end
			elseif command == "continue" or command == "next" or command == "stepIn" or command == "stepOut" then
				vscode_debugger.send_success(req, {})

				if command == "continue" then
					state.step_into = false
					state.step_over = false
				elseif command == "stepIn" then
					state.step_into = true
					state.step_over = false
				elseif command == "next" or command == "stepOut" then
					state.step_into = false
					state.step_over = true
					state.step_level = command == "next" and state.stack_level or state.stack_level - 1
				end

				local ev, vars, file, line, idx_watch = coroyield()

				eval_env = vars

				if ev == events.BREAK then
					vscode_debugger.send_stop_event("breakpoint")
				elseif ev == events.WATCH then
					vscode_debugger.send_stop_event("breakpoint")
				elseif ev == events.RESTART then
					-- block empty
				else
					vscode_debugger.send_stop_event("exception")
					vscode_debugger.send_stderr(file)
				end
			elseif command == "disconnect" then
				vscode_debugger.send_success(req, {})
				coroyield("done")

				return
			else
				Log.format("Unsupported command: %s", tostring(command or "<UNKNOWN>"))
				vscode_debugger.send_failure(req, "Unsupported command")
			end
		end
	end

	function vscode_debugger.pending_io()
		local possible_pending_io = false

		while server:is_pending() do
			server:enforce_pending_check()

			local req, err = vscode_debugger.receive_message(false)

			if not req then
				Log.format("  %s", err or "unknown")

				possible_pending_io = err == "timeout"

				break
			end

			local command, args = req.command, req.arguments

			if command == "setBreakpoints" then
				local file = vscode_debugger.path_from_ide(args.source.path)

				remove_file_breakpoint(file)

				local result = {}

				for i, breakpoint in ipairs(args.breakpoints) do
					set_breakpoint(file, breakpoint.line)

					result[i] = {
						verified = true,
						line = breakpoint.line
					}
				end

				vscode_debugger.send_success(req, {
					breakpoints = result
				})
			elseif command == "threads" then
				local result = {
					{
						id = vscode_thread_id,
						name = vscode_thread_name
					}
				}

				vscode_debugger.send_success(req, {
					threads = result
				})
			elseif command == "pause" then
				state.step_into = true
				state.step_over = false

				vscode_debugger.send_success(req, {})
			else
				Log.format("Unsupported pending command: %s", command)
				vscode_debugger.push_back_message(req)

				return true
			end
		end

		if possible_pending_io then
			return false
		end

		return not not server:is_pending()
	end
end

function debugger.loop_detect_protocol()
	if mobdebug.yield and server.settimeout then
		server:settimeout(mobdebug.yieldtimeout)
	end

	local data, err

	while true do
		data, err = server:peek(1, true)

		if data then
			break
		end

		if err == "timeout" then
			if mobdebug.yield then
				mobdebug.yield()
			end
		elseif err == "closed" then
			error("Debugger connection closed", 1)
		else
			error(("Unexpected socket error: %s"):format(err), 1)
		end
	end

	if server.settimeout then
		server:settimeout()
	end

	state.protocol = data == "#" and PROTOCOLS.VSCODE or PROTOCOLS.MOBDEBUG
end

function debugger.loop(sev, svars, sfile, sline)
	debugger.loop_detect_protocol()

	if state.protocol == PROTOCOLS.VSCODE then
		return vscode_debugger.loop(sev, svars, sfile, sline)
	end

	if state.protocol == PROTOCOLS.MOBDEBUG then
		return mobdebug_debugger.loop(sev, svars, sfile, sline)
	end
end

function debugger.loop_pending_io()
	if state.protocol == PROTOCOLS.VSCODE then
		return vscode_debugger.pending_io()
	end

	if state.protocol == PROTOCOLS.MOBDEBUG then
		return mobdebug_debugger.pending_io()
	end
end

local function output(stream, data)
	if server then
		return server:send("204 Output " .. stream .. " " .. tostring(#data) .. "\n" .. data)
	end
end

local function connect(controller_host, controller_port)
	local sock, err = socket.tcp()

	if not sock then
		return nil, err
	end

	if sock.settimeout then
		sock:settimeout(mobdebug.connecttimeout)
	end

	local res, err = sock:connect(controller_host, tostring(controller_port))

	if sock.settimeout then
		sock:settimeout()
	end

	if not res then
		return nil, err
	end

	return sock
end

local lasthost, lastport

local function start(controller_host, controller_port)
	if isrunning() then
		return
	end

	lasthost = controller_host or lasthost
	lastport = controller_port or lastport
	controller_host = lasthost or "localhost"
	controller_port = lastport or mobdebug.port

	local err

	server, err = mobdebug.connect(controller_host, controller_port)

	if server then
		server = Socket.new(server)
		state.stack_level = stack_depth(16)
		coro_debugger = corocreate(debugger.loop)

		debug.sethook(debug_hook, HOOKMASK)

		state.seen_hook = nil
		state.step_into = true

		return true
	else
		mobdebug.print(("Could not connect to %s:%s: %s"):format(controller_host, controller_port, err or "unknown error"))
	end
end

local function controller(controller_host, controller_port, scratchpad)
	if isrunning() then
		return
	end

	lasthost = controller_host or lasthost
	lastport = controller_port or lastport
	controller_host = lasthost or "localhost"
	controller_port = lastport or mobdebug.port

	local exitonerror = not scratchpad
	local err

	server, err = mobdebug.connect(controller_host, controller_port)

	if server then
		server = Socket.new(server)

		local function report(trace, err)
			local msg = err .. "\n" .. trace

			server:send("401 Error in Execution " .. tostring(#msg) .. "\n")
			server:send(msg)

			return err
		end

		state.seen_hook = true
		coro_debugger = corocreate(debugger.loop)

		while true do
			state.step_into = true
			abort = false

			if scratchpad then
				server:enforce_pending_check()
			end

			coro_debugee = corocreate(state.debugee)

			debug.sethook(coro_debugee, debug_hook, HOOKMASK)

			local status, err = cororesume(coro_debugee, unpack(arg or {}))

			if abort then
				if tostring(abort) == "exit" then
					break
				end
			elseif status then
				if corostatus(coro_debugee) == "suspended" then
					error("attempt to yield from the main thread", 3)
				end

				break
			elseif err and not string_find(tostring(err), deferror) then
				report(debug.traceback(coro_debugee), tostring(err))

				if exitonerror then
					break
				end

				if not coro_debugger then
					break
				end

				local status, err = cororesume(coro_debugger, events.RESTART, capture_vars(0))

				if not status or status and err == "exit" then
					break
				end
			end
		end
	else
		print(("Could not connect to %s:%s: %s"):format(controller_host, controller_port, err or "unknown error"))

		return false
	end

	return true
end

local function scratchpad(controller_host, controller_port)
	return controller(controller_host, controller_port, true)
end

local function loop(controller_host, controller_port)
	return controller(controller_host, controller_port, false)
end

local function on()
	if not isrunning() or not server then
		return
	end

	local co, main = coroutine.running()

	if main then
		co = nil
	end

	if co then
		coroutines[co] = true

		debug.sethook(co, debug_hook, HOOKMASK)
	else
		if jit then
			coroutines.main = true
		end

		debug.sethook(debug_hook, HOOKMASK)
	end
end

local function off()
	if not isrunning() or not server then
		return
	end

	local co, main = coroutine.running()

	if main then
		co = nil
	end

	if co then
		coroutines[co] = false

		if not jit then
			debug.sethook(co)
		end
	else
		if jit then
			coroutines.main = false
		end

		if not jit then
			debug.sethook()
		end
	end

	if jit then
		local remove = true

		for _, debugged in pairs(coroutines) do
			if debugged then
				remove = false

				break
			end
		end

		if remove then
			debug.sethook()
		end
	end
end

local function handle(params, client, options)
	local verbose = not options or options.verbose ~= nil and options.verbose
	local print = verbose and (type(verbose) == "function" and verbose or print) or function()
		return
	end
	local file, line, watch_idx
	local _, _, command = string_find(params, "^([a-z]+)")

	if command == "run" or command == "step" or command == "out" or command == "over" or command == "exit" then
		client:send(string.upper(command) .. "\n")
		client:receive("*l")

		while true do
			local done = true
			local breakpoint = client:receive("*l")

			if not breakpoint then
				print("Program finished")

				return nil, nil, false
			end

			local _, _, status = string_find(breakpoint, "^(%d+)")

			if status == "200" then
				-- block empty
			elseif status == "202" then
				_, _, file, line = string_find(breakpoint, "^202 Paused%s+(.-)%s+(%d+)%s*$")

				if file and line then
					print("Paused at file " .. file .. " line " .. line)
				end
			elseif status == "203" then
				_, _, file, line, watch_idx = string_find(breakpoint, "^203 Paused%s+(.-)%s+(%d+)%s+(%d+)%s*$")

				if file and line and watch_idx then
					print("Paused at file " .. file .. " line " .. line .. " (watch expression " .. watch_idx .. ": [" .. state.watches[watch_idx] .. "])")
				end
			elseif status == "204" then
				local _, _, stream, size = string_find(breakpoint, "^204 Output (%w+) (%d+)$")

				if stream and size then
					local size = tonumber(size)
					local msg = size > 0 and client:receive(size) or ""

					print(msg)

					if state.outputs[stream] then
						state.outputs[stream](msg)
					end

					done = false
				end
			elseif status == "401" then
				local _, _, size = string_find(breakpoint, "^401 Error in Execution (%d+)$")

				if size then
					local msg = client:receive(tonumber(size))

					print("Error in remote application: " .. msg)

					return nil, nil, msg
				end
			else
				print("Unknown error")

				return nil, nil, "Debugger error: unexpected response '" .. breakpoint .. "'"
			end

			if done then
				break
			end
		end
	elseif command == "done" then
		client:send(string.upper(command) .. "\n")
	elseif command == "setb" or command == "asetb" then
		_, _, _, file, line = string_find(params, "^([a-z]+)%s+(.-)%s+(%d+)%s*$")

		if file and line then
			if not file:find("^\".*\"$") then
				file = string_gsub(file, "\\", "/")
				file = removebasedir(file, state.basedir)
			end

			client:send("SETB " .. file .. " " .. line .. "\n")

			if command == "asetb" or client:receive("*l") == "200 OK" then
				set_breakpoint(file, line)
			else
				print("Error: breakpoint not inserted")
			end
		else
			print("Invalid command")
		end
	elseif command == "setw" then
		local _, _, exp = string_find(params, "^[a-z]+%s+(.+)$")

		if exp then
			client:send("SETW " .. exp .. "\n")

			local answer = client:receive("*l")
			local _, _, watch_idx = string_find(answer, "^200 OK (%d+)%s*$")

			if watch_idx then
				state.watches[watch_idx] = exp

				print("Inserted watch exp no. " .. watch_idx)
			else
				local _, _, size = string_find(answer, "^401 Error in Expression (%d+)$")

				if size then
					local err = client:receive(tonumber(size)):gsub(".-:%d+:%s*", "")

					print("Error: watch expression not set: " .. err)
				else
					print("Error: watch expression not set")
				end
			end
		else
			print("Invalid command")
		end
	elseif command == "delb" or command == "adelb" then
		_, _, _, file, line = string_find(params, "^([a-z]+)%s+(.-)%s+(%d+)%s*$")

		if file and line then
			if not file:find("^\".*\"$") then
				file = string_gsub(file, "\\", "/")
				file = removebasedir(file, state.basedir)
			end

			client:send("DELB " .. file .. " " .. line .. "\n")

			if command == "adelb" or client:receive("*l") == "200 OK" then
				remove_breakpoint(file, line)
			else
				print("Error: breakpoint not removed")
			end
		else
			print("Invalid command")
		end
	elseif command == "delallb" then
		local file, line = "*", 0

		client:send("DELB " .. file .. " " .. tostring(line) .. "\n")

		if client:receive("*l") == "200 OK" then
			remove_breakpoint(file, line)
		else
			print("Error: all breakpoints not removed")
		end
	elseif command == "delw" then
		local _, _, index = string_find(params, "^[a-z]+%s+(%d+)%s*$")

		if index then
			client:send("DELW " .. index .. "\n")

			if client:receive("*l") == "200 OK" then
				state.watches[index] = nil
			else
				print("Error: watch expression not removed")
			end
		else
			print("Invalid command")
		end
	elseif command == "delallw" then
		for index, exp in pairs(state.watches) do
			client:send("DELW " .. index .. "\n")

			if client:receive("*l") == "200 OK" then
				state.watches[index] = nil
			else
				print("Error: watch expression at index " .. index .. " [" .. exp .. "] not removed")
			end
		end
	elseif command == "eval" or command == "exec" or command == "load" or command == "loadstring" or command == "reload" then
		local _, _, exp = string_find(params, "^[a-z]+%s+(.+)$")

		if exp or command == "reload" then
			if command == "eval" or command == "exec" then
				exp = exp:gsub("\n", "\r")

				if command == "eval" then
					exp = "return " .. exp
				end

				client:send("EXEC " .. exp .. "\n")
			elseif command == "reload" then
				client:send("LOAD 0 -\n")
			elseif command == "loadstring" then
				local _, _, _, file, lines = string_find(exp, "^([\"'])(.-)%1%s(.+)")

				if not file then
					_, _, file, lines = string_find(exp, "^(%S+)%s(.+)")
				end

				client:send("LOAD " .. tostring(#lines) .. " " .. file .. "\n")
				client:send(lines)
			else
				local file = io.open(exp, "r")

				if not file and pcall(require, "winapi") then
					winapi.set_encoding(winapi.CP_UTF8)

					local shortp = winapi.short_path(exp)

					file = shortp and io.open(shortp, "r")
				end

				if not file then
					return nil, nil, "Cannot open file " .. exp
				end

				local lines = file:read("*all"):gsub("^#!.-\n", "\n")

				file:close()

				local fname = string_gsub(exp, "\\", "/")

				fname = removebasedir(fname, state.basedir)

				client:send("LOAD " .. tostring(#lines) .. " " .. fname .. "\n")

				if #lines > 0 then
					client:send(lines)
				end
			end

			while true do
				local params, err = client:receive("*l")

				if not params then
					return nil, nil, "Debugger connection " .. (err or "error")
				end

				local done = true
				local _, _, status, len = string_find(params, "^(%d+).-%s+(%d+)%s*$")

				if status == "200" then
					len = tonumber(len)

					if len > 0 then
						local status, res
						local str = client:receive(len)
						local func, err = loadstring(str)

						if func then
							status, res = pcall(func)

							if not status then
								err = res
							elseif type(res) ~= "table" then
								err = "received " .. type(res) .. " instead of expected 'table'"
							end
						end

						if err then
							print("Error in processing results: " .. err)

							return nil, nil, "Error in processing results: " .. err
						end

						print(unpack(res))

						return res[1], res
					end
				elseif status == "201" then
					_, _, file, line = string_find(params, "^201 Started%s+(.-)%s+(%d+)%s*$")
				elseif status == "202" or params == "200 OK" then
					-- block empty
				elseif status == "204" then
					local _, _, stream, size = string_find(params, "^204 Output (%w+) (%d+)$")

					if stream and size then
						local size = tonumber(size)
						local msg = size > 0 and client:receive(size) or ""

						print(msg)

						if state.outputs[stream] then
							state.outputs[stream](msg)
						end

						done = false
					end
				elseif status == "401" then
					len = tonumber(len)

					local res = client:receive(len)

					print("Error in expression: " .. res)

					return nil, nil, res
				else
					print("Unknown error")

					return nil, nil, "Debugger error: unexpected response after EXEC/LOAD '" .. params .. "'"
				end

				if done then
					break
				end
			end
		else
			print("Invalid command")
		end
	elseif command == "listb" then
		for l, v in pairs(state.breakpoints) do
			for f in pairs(v) do
				print(f .. ": " .. l)
			end
		end
	elseif command == "listw" then
		for i, v in pairs(state.watches) do
			print("Watch exp. " .. i .. ": " .. v)
		end
	elseif command == "suspend" then
		client:send("SUSPEND\n")
	elseif command == "stack" then
		local opts = string.match(params, "^[a-z]+%s+(.+)$")

		client:send("STACK" .. (opts and " " .. opts or "") .. "\n")

		local resp = client:receive("*l")
		local _, _, status, res = string_find(resp, "^(%d+)%s+%w+%s+(.+)%s*$")

		if status == "200" then
			local func, err = loadstring(res)

			if func == nil then
				print("Error in stack information: " .. err)

				return nil, nil, err
			end

			local ok, stack = pcall(func)

			if not ok then
				print("Error in stack information: " .. stack)

				return nil, nil, stack
			end

			for _, frame in ipairs(stack) do
				print(mobdebug.line(frame[1], {
					comment = false
				}))
			end

			return stack
		elseif status == "401" then
			local _, _, len = string_find(resp, "%s+(%d+)%s*$")

			len = tonumber(len)

			local res = len > 0 and client:receive(len) or "Invalid stack information."

			print("Error in expression: " .. res)

			return nil, nil, res
		else
			print("Unknown error")

			return nil, nil, "Debugger error: unexpected response after STACK"
		end
	elseif command == "output" then
		local _, _, stream, mode = string_find(params, "^[a-z]+%s+(%w+)%s+([dcr])%s*$")

		if stream and mode then
			client:send("OUTPUT " .. stream .. " " .. mode .. "\n")

			local resp, err = client:receive("*l")

			if not resp then
				print("Unknown error: " .. err)

				return nil, nil, "Debugger connection error: " .. err
			end

			local _, _, status = string_find(resp, "^(%d+)%s+%w+%s*$")

			if status == "200" then
				print("Stream " .. stream .. " redirected")

				state.outputs[stream] = type(options) == "table" and options.handler or nil
			elseif type(options) == "table" and options.handler then
				state.outputs[stream] = options.handler
			else
				print("Unknown error")

				return nil, nil, "Debugger error: can't redirect " .. stream
			end
		else
			print("Invalid command")
		end
	elseif command == "basedir" then
		local _, _, dir = string_find(params, "^[a-z]+%s+(.+)$")

		if dir then
			dir = string_gsub(dir, "\\", "/")

			if not string_find(dir, "/$") then
				dir = dir .. "/"
			end

			local remdir = dir:match("\t(.+)")

			if remdir then
				dir = dir:gsub("/?\t.+", "/")
			end

			state.basedir = dir

			client:send("BASEDIR " .. (remdir or dir) .. "\n")

			local resp, err = client:receive("*l")

			if not resp then
				print("Unknown error: " .. err)

				return nil, nil, "Debugger connection error: " .. err
			end

			local _, _, status = string_find(resp, "^(%d+)%s+%w+%s*$")

			if status == "200" then
				print("New base directory is " .. state.basedir)
			else
				print("Unknown error")

				return nil, nil, "Debugger error: unexpected response after BASEDIR"
			end
		else
			print(state.basedir)
		end
	elseif command == "help" then
		print("setb <file> <line>    -- sets a breakpoint")
		print("delb <file> <line>    -- removes a breakpoint")
		print("delallb               -- removes all breakpoints")
		print("setw <exp>            -- adds a new watch expression")
		print("delw <index>          -- removes the watch expression at index")
		print("delallw               -- removes all watch expressions")
		print("run                   -- runs until next breakpoint")
		print("step                  -- runs until next line, stepping into function calls")
		print("over                  -- runs until next line, stepping over function calls")
		print("out                   -- runs until line after returning from current function")
		print("listb                 -- lists breakpoints")
		print("listw                 -- lists watch expressions")
		print("eval <exp>            -- evaluates expression on the current context and returns its value")
		print("exec <stmt>           -- executes statement on the current context")
		print("load <file>           -- loads a local file for debugging")
		print("reload                -- restarts the current debugging session")
		print("stack                 -- reports stack trace")
		print("output stdout <d|c|r> -- capture and redirect io stream (default|copy|redirect)")
		print("basedir [<path>]      -- sets the base path of the remote application, or shows the current one")
		print("done                  -- stops the debugger and continues application execution")
		print("exit                  -- exits debugger and the application")
	else
		local _, _, spaces = string_find(params, "^(%s*)$")

		if spaces then
			return nil, nil, "Empty command"
		else
			print("Invalid command")

			return nil, nil, "Invalid command"
		end
	end

	return file, line
end

local function listen(host, port)
	host = host or "*"
	port = port or mobdebug.port

	local socket = require("socket")

	print("Lua Remote Debugger")
	print("Run the program you wish to debug")

	local server = socket.bind(host, port)
	local client = server:accept()

	client:send("STEP\n")
	client:receive("*l")

	local breakpoint = client:receive("*l")
	local _, _, file, line = string_find(breakpoint, "^202 Paused%s+(.-)%s+(%d+)%s*$")

	if file and line then
		print("Paused at file " .. file)
		print("Type 'help' for commands")
	else
		local _, _, size = string_find(breakpoint, "^401 Error in Execution (%d+)%s*$")

		if size then
			print("Error in remote application: ")
			print(client:receive(size))
		end
	end

	while true do
		io.write("> ")

		local file, _, err = handle(io.read("*line"), client)

		if not file and err == false then
			break
		end
	end

	client:close()
end

local cocreate

local function coro()
	if cocreate then
		return
	end

	cocreate = cocreate or coroutine.create

	function coroutine.create(f, ...)
		return cocreate(function(...)
			mobdebug.on()

			return f(...)
		end, ...)
	end
end

local moconew

local function moai()
	if moconew then
		return
	end

	moconew = moconew or MOAICoroutine and MOAICoroutine.new

	if not moconew then
		return
	end

	function MOAICoroutine.new(...)
		local thread = moconew(...)
		local mt = thread.run and thread or getmetatable(thread)
		local patched = mt.run

		function mt:run(f, ...)
			return patched(self, function(...)
				mobdebug.on()

				return f(...)
			end, ...)
		end

		return thread
	end
end

mobdebug.setbreakpoint = set_breakpoint
mobdebug.removebreakpoint = remove_breakpoint
mobdebug.listen = listen
mobdebug.loop = loop
mobdebug.scratchpad = scratchpad
mobdebug.handle = handle
mobdebug.connect = connect
mobdebug.start = start
mobdebug.on = on
mobdebug.off = off
mobdebug.moai = moai
mobdebug.coro = coro
mobdebug.done = done

function mobdebug.pause()
	state.step_into = true
end

mobdebug.yield = nil
mobdebug.output = output
mobdebug.onexit = os and os.exit or done
mobdebug.onscratch = nil

function mobdebug.basedir(b)
	if b then
		state.basedir = b
	end

	return state.basedir
end

function mobdebug.logging(on, file)
	state.logging = on
	state.logfile = file
end

return mobdebug
