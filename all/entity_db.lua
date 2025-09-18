local log = require("klua.log"):new("entity_db")

require("klua.table")

local copy = table.deepclone
local entity_db = {}

entity_db.last_id = 1
entity_db.debug_info = false

function entity_db:load()
	self.last_id = 1
	self.components = {}
	self.entities = {}
	package.loaded.components = nil
	package.loaded.game_templates = nil
	package.loaded.custom_templates_0 = nil
	package.loaded.templates = nil
	package.loaded.game_scripts = nil
	package.loaded.scripts = nil
	package.loaded.script_utils = nil

	require("components")
	require("templates")
	require("game_templates")
	require("custom_templates_0")
end

-- local redundant = {}
function entity_db:register_t(name, base)
	if self.entities[name] then
		log.error("template %s already exists", name)
		-- table.insert(redundant, name)
		return
	end

	local t

	if base then
		if type(base) == "string" then
			base = self.entities[base]
		end

		if base == nil then
			log.error("template base %s does not exist", base)

			return
		end

		t = copy(base)
	else
		t = {}
	end

	if self.debug_info then
		if t.hierarchy_debug then
			t.hierarchy_debug = t.hierarchy_debug .. "|" .. name
		else
			t.hierarchy_debug = name
		end
	end

	t.template_name = name
	self.entities[name] = t

	return t
end

-- function entity_db:write_redundant()
-- 	local fs = love.filesystem
-- 	local o = "return {\n"
-- 	for i, name in ipairs(redundant) do
-- 		o = o .. "\t\"" .. name .. "\",\n"
-- 	end
-- 	o = o .. "}"
-- 	local fileName = "redundant.lua"
-- 	local success, message = fs.write(fileName, o)
-- 	if not success then
-- 		log.error("file not created: " .. message)
-- 	end	
-- end

function entity_db:register_c(name, ...)
	if self.components[name] then
		log.error("component %s already exists", name)

		return
	end

	local bases = { ... }
	local c = {}

	if bases then
		for _, base in pairs(bases) do
			if type(base) == "string" then
				base = self.components[base]
			end

			if base == nil then
				log.error("component base %s does not exist", base)
			end

			if next(c) == nil then
				c = copy(base)
			else
				c = table.merge(c, base)
			end
		end
	end

	self.components[name] = c

	if self.debug_info then
		if c.hierarchy_debug then
			c.hierarchy_debug = c.hierarchy_debug .. "|" .. name
		else
			c.hierarchy_debug = name
		end

		c.debug_component_name = name
	end

	return c
end

function entity_db:clone_c(name)
	if not self.components[name] then
		log.error("component %s does not exist", name)

		return
	end

	return copy(self.components[name])
end

function entity_db:add_comps(entity, ...)
	if entity == nil then
		log.error("entity is nil")

		return
	end

	for _, v in pairs({
		...
	}) do
		if not self.components[v] then
			log.error("component %s does not exist", v)

			return
		end

		entity[v] = copy(self.components[v])
	end
end

function entity_db:create_entity(t)
	local tpl

	if type(t) == "string" then
		tpl = self.entities[t]
	else
		tpl = t
	end

	if not tpl then
		log.error("template %s not found", t)

		return nil
	end

	local out = copy(tpl)

	out.id = self.last_id
	self.last_id = self.last_id + 1

	return out
end

function entity_db:clone_entity(e)
	local out = copy(e)

	e.id = self.last_id
	self.last_id = self.last_id + 1

	return out
end

function entity_db:append_templates(entity, ...)
	if entity == nil then
		log.error("entity is nil")

		return
	end

	for _, tn in pairs({
		...
	}) do
		local tpl = self.entities[tn]

		if not tpl then
			log.error("template %s not found", tn)

			return
		end

		for k, v in pairs(tpl) do
			entity[k] = copy(v)
		end
	end
end

function entity_db:get_component(c)
	local cmp

	if type(c) == "string" then
		cmp = self.components[c]
	else
		cmp = c
	end

	if not cmp then
		log.error("component %s not found", c)

		return nil
	end

	return cmp
end

function entity_db:get_template(t)
	local tpl

	if type(t) == "string" then
		tpl = self.entities[t]
	else
		tpl = t
	end

	if not tpl then
		log.error("template %s not found", t)

		return nil
	end

	return tpl
end

function entity_db:set_template(name, t)
	self.entities[name] = t
end

function entity_db:filter(entities, ...)
	local result = {}

	for id, e in pairs(entities) do
		for _, n in pairs({
			...
		}) do
			if not e[n] then
				goto label_12_0
			end
		end

		table.insert(result, e)

		::label_12_0::
	end

	return result
end

function entity_db:filter_iter(entities, c1, c2, c3)
	local function next_entity(t, i)
		local k, v = i

		while true do
			::label_14_0::

			k, v = next(t, k)

			if not k then
				return nil
			end

			if c1 and not v[c1] then
				goto label_14_0
			end

			if c2 and not v[c2] then
				goto label_14_0
			end

			if c3 and not v[c3] then
				goto label_14_0
			end

			return k, v
		end
	end

	return next_entity, entities, nil
end

function entity_db:filter_templates(...)
	return self:filter(self.entities, ...)
end

function entity_db:search_entity(p)
	local results = {}

	for k, e in pairs(self.entities) do
		if string.match(k, p) then
			table.insert(results, k)
		end
	end

	return results
end

return entity_db
