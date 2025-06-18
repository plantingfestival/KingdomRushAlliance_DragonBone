-- chunkname: @./lib/klove/simulation.lua

local log = require("klua.log"):new("simulation")
local km = require("klua.macros")
local A = require("klove.animation_db")

simulation = {}

function simulation:init(store, systems, active_system_names, tick_length)
	self.store = store

	local d = store

	d.tick_length = tick_length
	d.tick = 0
	d.tick_ts = 0
	d.ts = 0
	d.to = 0
	d.paused = false
	d.step = false
	d.entities = {}
	d.pending_inserts = {}
	d.pending_removals = {}
	d.entity_count = 0
	d.entity_max = 0
	self.max_count = 60
	self.last_time = 0
	self.counter = 0
	self.systems_on_queue = {}
	self.systems_on_dequeue = {}
	self.systems_on_insert = {}
	self.systems_on_remove = {}
	self.systems_on_update = {}

	local systems_order = {}

	for _, name in pairs(active_system_names) do
		if not systems[name] then
			log.error("System named %s not found", name)
		else
			table.insert(systems_order, systems[name])
		end
	end

	if DEBUG then
		-- block empty
	end

	for _, s in ipairs(systems_order) do
		if not s then
			log.error("system %s could not be found", s)
		elseif s.init and s:init(self.store) == "skip" then
			-- block empty
		else
			if s.on_queue then
				table.insert(self.systems_on_queue, s)
			end

			if s.on_dequeue then
				table.insert(self.systems_on_dequeue, s)
			end

			if s.on_insert then
				table.insert(self.systems_on_insert, s)
			end

			if s.on_remove then
				table.insert(self.systems_on_remove, s)
			end

			if s.on_update then
				table.insert(self.systems_on_update, s)
			end
		end
	end
end

function simulation:update(dt)
	local d = self.store

	if d.paused and not d.step then
		return
	end

	local tl = d.tick_length

	d.dt = dt
	d.ts = d.ts + dt
	d.to = d.to + dt

	if tl < d.to then
		d.to = km.clamp(0, tl, d.to - tl)

		self:do_tick()

		d.step = false
	end
end

function simulation:do_tick()
	local d = self.store

	d.tick = d.tick + 1
	d.tick_ts = d.tick * d.tick_length

	while #d.pending_inserts > 0 do
		local e = table.remove(d.pending_inserts, 1)

		self:insert_entity(e)
	end

	while #d.pending_removals > 0 do
		local e = table.remove(d.pending_removals, 1)

		self:remove_entity(e)
	end

	if IS_KR5 and game then
		local dt = d.tick_ts - self.last_time

		self.last_time = d.tick_ts

		if d.dt > 0.02 and game.limit_fps and game.limit_fps > 30 then
			self.counter = self.counter + 1

			if self.counter > self.max_count then
				game.limit_fps = 30
				d.tick_length = 0.03333333333333333
				A.tick_length = 0.03333333333333333
				d.tick = d.tick * 0.5
				d.tick_ts = d.tick * d.tick_length
			end
		else
			self.counter = 0
		end

		if game.force_change_fps then
			game.limit_fps = game.force_change_fps
			d.tick_length = 1 / game.force_change_fps
			A.tick_length = 1 / game.force_change_fps

			if game.force_change_fps == 60 then
				d.tick = d.tick * 2
			end

			if game.force_change_fps == 30 then
				d.tick = d.tick * 0.5
			end

			d.tick_ts = d.tick * d.tick_length
			game.force_change_fps = nil
		end
	end

	for _, sys in ipairs(self.systems_on_update) do
		sys:on_update(d.tick_length, d.tick_length * d.tick, d)
	end
end

function simulation:queue_insert_entity(e)
	if not e then
		return
	end

	local d = self.store

	for _, sys in ipairs(self.systems_on_queue) do
		sys:on_queue(e, d, true)
	end

	e.pending_removal = nil

	table.insert(d.pending_inserts, e)
end

function simulation:queue_remove_entity(e)
	if not e then
		return
	end

	local d = self.store

	if e.pending_removal then
		log.debug("prevented double remove of (%s) %s", e.id, e.template_name)

		return
	end

	for _, sys in ipairs(self.systems_on_queue) do
		sys:on_queue(e, d, false)
	end

	e.pending_removal = true

	table.insert(self.store.pending_removals, e)
end

function simulation:insert_entity(e)
	local d = self.store

	for _, sys in ipairs(self.systems_on_insert) do
		if not sys:on_insert(e, d) then
			for _, dqsys in ipairs(self.systems_on_dequeue) do
				dqsys:on_dequeue(e, d, true)
			end

			log.debug("entity %s %s NOT added by sys %s", e.id, e.template_name, sys.name)

			return
		end
	end

	e.pending_removal = nil
	d.entities[e.id] = e
	d.entity_count = d.entity_count + 1
	d.entity_max = d.entity_count >= d.entity_max and d.entity_count or d.entity_max

	log.debug("tick: %i - entity (%s) %s added", d.tick, e.id, e.template_name)
end

function simulation:remove_entity(e)
	local d = self.store

	for _, sys in ipairs(self.systems_on_remove) do
		if not sys:on_remove(e, d) then
			for _, dqsys in ipairs(self.systems_on_dequeue) do
				dqsys:on_dequeue(e, d, false)
			end

			log.debug("tick: %i - entity (%s) %s NOT removed by sys %s", d.tick, e.id, e.template_name, sys.name)

			return
		end
	end

	e.pending_removal = nil
	d.entities[e.id] = nil
	d.entity_count = d.entity_count - 1

	log.debug("tick: %i - entity (%s) %s removed", d.tick, e.id, e.template_name)
end

return simulation
