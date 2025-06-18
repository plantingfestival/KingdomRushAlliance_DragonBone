-- chunkname: @./lib/klove/tween.lua

local log = require("klua.log"):new("klove.tween")

require("klua.table")

local tween = {}

local function check_init(k, o)
	log.assert(k._timer ~= nil, "ktween not properly initialized. must call .new(timer) first")

	if not k._timer then
		return false
	end

	if not o then
		log.error("requires a valid object: %s", o)

		return false
	end

	return true
end

function tween.new(timer)
	if not timer then
		log.error("tween: new requires a hump timer instance")

		return
	end

	tween.__index = tween

	local new_tween = setmetatable({}, tween)

	new_tween._subjects = {}
	new_tween._timer = timer

	return new_tween
end

function tween:clear()
	self._subjects = {}
end

function tween:destroy()
	self._subjects = nil
	self._timer = nil
end

function tween:cancel(o)
	if not check_init(self, o) then
		return
	end

	if not self._subjects[o] then
		log.debug("could not find timer handle to cancel for %s", o)

		return
	end

	for _, h in pairs(self._subjects[o]) do
		if h.co then
			self._timer:cancel(h.h)
		else
			self._timer:cancel(h)
		end
	end

	self._subjects[o] = nil
end

function tween:tween(o, len, subject, target, method, fn, ...)
	if not check_init(self, o) then
		return
	end

	if not self._subjects[o] then
		self._subjects[o] = {}
	end

	subject = subject or o

	local h = self._timer:tween(len, subject, target, method, fn, ...)
	local handles = self._subjects[o]

	table.insert(handles, h)

	return h
end

function tween:after(o, delay, fn)
	if not check_init(self, o) then
		return
	end

	if not self._subjects[o] then
		self._subjects[o] = {}
	end

	local h = self._timer:after(delay, fn)
	local handles = self._subjects[o]

	table.insert(handles, h)

	return h
end

function tween:script(o, fn)
	if not check_init(self, o) then
		return
	end

	if not self._subjects[o] then
		self._subjects[o] = {}
	end

	local co_w = {}

	table.insert(self._subjects[o], co_w)

	co_w.co = coroutine.wrap(fn)

	co_w.co(function(t)
		co_w.h = self:after(o, t, co_w.co)

		coroutine.yield()
	end)

	return co_w
end

return tween
