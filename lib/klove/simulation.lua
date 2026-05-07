local log = require("klua.log"):new("simulation")
local km = require("klua.macros")

simulation = {}

local A = require("klove.animation_db")
local I = require("klove.image_db")
local EXO = require("exoskeleton")
local U = require("utils")

local V = require("klua.vector")
local myExtension = require("myExtension")

local ffi = require("ffi")
ffi.cdef[[
typedef struct {
	const char* template_name;
	/* speed_x和speed_y都为0，代表无motion */
	double speed_x;
	double speed_y;
	/* pos_x为负无穷大时，代表无pos */
	double pos_x;
	double pos_y;
	uint32_t id;
	/* vis_flags为-1时，代表无vis */
	int32_t vis_flags;
	int32_t vis_bans;
	/* 生命最大值。hp_max为-1时，代表无health */
	int32_t hp_max;
	/* 生命值。hp为-1时，代表无health；为0时，代表死亡；大于0时，代表存活 */
	int32_t hp;
	uint16_t ni;
	/* pi为-1时，代表无nav_path */
	int8_t pi;
	int8_t spi;
	int8_t dir;
	/* entity_type为-1时，代表无tower_holder的防御塔；为-2时，代表有tower_holder的实体；为1时，代表敌方单位；为2时，代表友方单位；为0时，代表其他实体 */
	int8_t entity_type;
	/* is_blocked为true时，代表无法行动；为false时，代表能正常行动 */
	bool is_blocked;
	bool pending_removal;
	bool forced_waypoint;
} EntityInfo;

typedef struct {
	const char** allowed_templates;
	const char** excluded_templates;
	uint32_t allowed_templates_len;
	uint32_t excluded_templates_len;
	double origin_x;
	double origin_y;
	double min_range;
	double max_range;
	double prediction_time;
	double crowd_range;
	int32_t flags;
	int32_t bans;
	int32_t min_override_flags;
	uint32_t min_targets;
	uint32_t max_towers;
	/* type为-1，代表搜索防御塔；1代表搜索敌方单位；2代表搜索友方单位；3代表搜索所有单位；0代表搜索所有实体 */
	int8_t type;
	/* search_type为1，代表搜索最近的；2代表搜索最远的；3代表随机搜索；4代表搜索生命值最多的；5代表搜索生命值最少的；6代表搜索最接近终点的；7代表搜索最远离终点的；
	 * 8代表搜索最密集的；9代表搜索最大生命值最多的；10代表搜索最大生命值最少的；32代表自定义 */
	int8_t search_type;
	bool including_blocked;
	bool including_holder;
} SearchOrder;

typedef struct {
	double x;
	double y;
	uint32_t id;
} EntityPos;

typedef struct {
	EntityPos* entityPosions;
	uint32_t len;
	uint32_t number;
} SearchResult;

typedef struct {
	int8_t type;
} CompletedTask;

typedef struct SearchWorker SearchWorker;
typedef struct GridsOfTargets GridsOfTargets;
typedef struct PathDB PathDB;
SearchWorker* create_search_worker();
bool search_worker_can_submit_task_find_targets(SearchWorker* w);
void search_worker_submit_task_find_targets(SearchWorker* w, EntityInfo* entities, uint32_t entities_len, SearchOrder* orders, uint32_t orders_len, 
SearchResult* results, GridsOfTargets* grids, PathDB* pathdb);
bool search_worker_pop_completed(SearchWorker* w, CompletedTask* out);
void search_worker_destroy(SearchWorker* w);
void search_results_init(SearchResult* results, uint32_t results_len);
void search_results_clear(SearchResult* results, uint32_t results_len);
]]
local PSU = require("platform_services_utils")
local search_worker = PSU:load_library("search_worker", ffi)

local SearchOrderManager = {}
SearchOrderManager.__index = SearchOrderManager
local EntityInfoManager = {}
EntityInfoManager.__index = EntityInfoManager

function SearchOrderManager.new(initial_size, searchWorker)
	local self = setmetatable({}, SearchOrderManager)

	initial_size = initial_size or 16384
	self.search_orders = ffi.new("SearchOrder[?]", initial_size)
	self.search_results = ffi.new("SearchResult[?]", initial_size)
	search_worker.search_results_init(self.search_results, initial_size)
	ffi.gc(self.search_results, function(results)
		search_worker.search_results_clear(results, initial_size)
	end)

	self.current_size = initial_size
	self.max_observed_size = 0
	self.orders_len = 0
	self.searchWorker = searchWorker
	self.is_searching = nil

	return self
end

function EntityInfoManager.new(initial_size)
	local self = setmetatable({}, EntityInfoManager)

	self.entity_infos = ffi.new("EntityInfo[?]", initial_size or 16384)
	self.current_size = initial_size or 16384
	self.max_observed_size = 0
	self.entities_len = 0

	return self
end

function SearchOrderManager:ensure_capacity(required_size)
	if required_size <= self.current_size then return end

	local new_size = math.max(self.current_size * 2, required_size)
	local old_array = self.search_orders
	self.search_orders = ffi.new("SearchOrder[?]", new_size)
	ffi.copy(self.search_orders, old_array, ffi.sizeof("SearchOrder") * self.current_size)
	old_array = self.search_results
	self.search_results = ffi.new("SearchResult[?]", new_size)
	search_worker.search_results_init(self.search_results, new_size)
	ffi.gc(self.search_results, function(results)
		search_worker.search_results_clear(results, new_size)
	end)
	ffi.copy(self.search_results, old_array, ffi.sizeof("SearchResult") * self.current_size)
	self.current_size = new_size
end

function EntityInfoManager:ensure_capacity(required_size)
	if required_size <= self.current_size then return end

	local new_size = math.max(self.current_size * 2, required_size)
	local old_array = self.entity_infos
	self.entity_infos = ffi.new("EntityInfo[?]", new_size)
	ffi.copy(self.entity_infos, old_array, ffi.sizeof("EntityInfo") * self.current_size)
	self.current_size = new_size
end

function SearchOrderManager:submit_task_find_targets(store)
	if self.orders_len > 0 and search_worker.search_worker_can_submit_task_find_targets(self.searchWorker) then
		simulation.use_worker_thread = nil
		self.is_searching = true
		search_worker.search_worker_submit_task_find_targets(self.searchWorker, store.entity_info_manager.entity_infos, store.entity_info_manager.entities_len, 
		self.search_orders, self.orders_len, self.search_results, store.grids_of_targets, store.pathDB_ptr)
		self.max_observed_size = math.max(self.max_observed_size, self.orders_len)
		self.orders_len = 0
	end
end

function SearchOrderManager:check_search_is_completed()
	if self.is_searching then
		-- 检查 C++ 完成队列
		local completed = ffi.new("CompletedTask[1]")
		if search_worker.search_worker_pop_completed(self.searchWorker, completed) then
			self.is_searching = nil
			simulation.use_worker_thread = true
			return true
		end
		return false
	end
	return true
end

function EntityInfoManager:refresh_entity_infos(store)
	self:ensure_capacity(store.entity_count)

	local index = 0
	for id, e in pairs(store.entities) do
		local entity_info = self.entity_infos[index]
		entity_info.id = id
		entity_info.template_name = e.template_name
		if e.vis then
			entity_info.vis_flags = e.vis.flags
			entity_info.vis_bans = e.vis.bans
		else
			entity_info.vis_flags = -1
		end
		if e.motion and e.motion.speed then
			entity_info.speed_x = e.motion.speed.x
			entity_info.speed_y = e.motion.speed.y
			if not e.motion.forced_waypoint then
				entity_info.forced_waypoint = false
			else
				entity_info.forced_waypoint = true
			end
		else
			entity_info.speed_x = 0
			entity_info.speed_y = 0
			entity_info.forced_waypoint = false
		end
		if e.pos then
			entity_info.pos_x = e.pos.x
			entity_info.pos_y = e.pos.y
		else
			entity_info.pos_x = -math.huge
		end
		if e.nav_path then
			entity_info.pi = e.nav_path.pi - 1
			entity_info.spi = e.nav_path.spi - 1
			entity_info.ni = e.nav_path.ni - 1
			entity_info.dir = e.nav_path.dir
		else
			entity_info.pi = -1
		end
		if e.health then
			entity_info.hp_max = e.health.hp_max
			entity_info.hp = e.health.hp
		else
			entity_info.hp_max = -1
			entity_info.hp = -1
		end
		if not e.tower then
			if e.enemy then
				entity_info.entity_type = 1
			elseif e.soldier then
				entity_info.entity_type = 2
			else
				entity_info.entity_type = 0
			end
		elseif not e.tower_holder then
			entity_info.entity_type = -1
		else
			entity_info.entity_type = -2
		end
		if not (e.unit and e.unit.is_stunned or e.tower and e.tower.blocked) then
			entity_info.is_blocked = false
		else
			entity_info.is_blocked = true
		end
		if not e.pending_removal then
			entity_info.pending_removal = false
		else
			entity_info.pending_removal = true
		end

		index = index + 1
	end

	self.entities_len = index
	self.max_observed_size = math.max(self.max_observed_size, index)
end

function simulation:search_order_manager_is_searching()
	return self.store.search_order_manager.is_searching
end

function simulation:insert_order_find_enemies(origin, min_range, max_range, prediction_time, flags, bans, min_override_flags, crowd_range, min_targets, 
	allowed_templates, excluded_templates, search_type)
	local store = self.store
	if store.grids_of_targets and store.pathDB_ptr then
		local search_order_manager = store.search_order_manager
		local current_index = search_order_manager.orders_len
		search_order_manager.orders_len = current_index + 1
		search_order_manager:ensure_capacity(search_order_manager.orders_len)
		local search_order = search_order_manager.search_orders[current_index]
		search_order.origin_x, search_order.origin_y = origin.x, origin.y
		search_order.min_range = min_range
		search_order.max_range = max_range
		search_order.prediction_time = prediction_time or 0
		search_order.flags = flags
		search_order.bans = bans
		search_order.min_override_flags = min_override_flags
		search_order.crowd_range = crowd_range
		search_order.min_targets = min_targets
		search_order.allowed_templates, search_order.allowed_templates_len = U.string_table_to_c_string_array(allowed_templates, ffi)
		search_order.excluded_templates, search_order.excluded_templates_len = U.string_table_to_c_string_array(excluded_templates, ffi)
		search_order.search_type = search_type
		-- search_order.max_towers = 0
		-- search_order.including_blocked = true
		-- search_order.including_holder = false
		search_order.type = 1
		return current_index
	end
	self.use_worker_thread = nil
	return nil
end

function simulation:insert_order_find_soldiers(origin, min_range, max_range, prediction_time, flags, bans, crowd_range, min_targets, 
	allowed_templates, excluded_templates, search_type)
	local store = self.store
	if store.grids_of_targets and store.pathDB_ptr then
		local search_order_manager = store.search_order_manager
		local current_index = search_order_manager.orders_len
		search_order_manager.orders_len = current_index + 1
		search_order_manager:ensure_capacity(search_order_manager.orders_len)
		local search_order = search_order_manager.search_orders[current_index]
		search_order.origin_x, search_order.origin_y = origin.x, origin.y
		search_order.min_range = min_range
		search_order.max_range = max_range
		search_order.prediction_time = prediction_time or 0
		search_order.flags = flags
		search_order.bans = bans
		-- search_order.min_override_flags = min_override_flags
		search_order.crowd_range = crowd_range
		search_order.min_targets = min_targets
		search_order.allowed_templates, search_order.allowed_templates_len = U.string_table_to_c_string_array(allowed_templates, ffi)
		search_order.excluded_templates, search_order.excluded_templates_len = U.string_table_to_c_string_array(excluded_templates, ffi)
		search_order.search_type = search_type
		-- search_order.max_towers = 0
		-- search_order.including_blocked = true
		-- search_order.including_holder = false
		search_order.type = 2
		return current_index
	end
	self.use_worker_thread = nil
	return nil
end

function simulation:insert_order_find_targets(origin, min_range, max_range, flags, bans, allowed_templates, excluded_templates)
	local store = self.store
	if store.grids_of_targets and store.pathDB_ptr then
		local search_order_manager = store.search_order_manager
		local current_index = search_order_manager.orders_len
		search_order_manager.orders_len = current_index + 1
		search_order_manager:ensure_capacity(search_order_manager.orders_len)
		local search_order = search_order_manager.search_orders[current_index]
		search_order.origin_x, search_order.origin_y = origin.x, origin.y
		search_order.min_range = min_range
		search_order.max_range = max_range
		-- search_order.prediction_time = prediction_time or 0
		search_order.flags = flags
		search_order.bans = bans
		-- search_order.min_override_flags = min_override_flags
		-- search_order.crowd_range = crowd_range or 0
		-- search_order.min_targets = min_targets or 1
		search_order.allowed_templates, search_order.allowed_templates_len = U.string_table_to_c_string_array(allowed_templates, ffi)
		search_order.excluded_templates, search_order.excluded_templates_len = U.string_table_to_c_string_array(excluded_templates, ffi)
		-- search_order.search_type = search_type
		-- search_order.max_towers = 0
		-- search_order.including_blocked = true
		-- search_order.including_holder = false
		search_order.type = 3
		return current_index
	end
	self.use_worker_thread = nil
	return nil
end

function simulation:insert_order_find_towers(origin, min_range, max_range, including_blocked, including_holder, max_towers, 
	allowed_templates, excluded_templates)
	local store = self.store
	if store.grids_of_targets and store.pathDB_ptr then
		local search_order_manager = store.search_order_manager
		local current_index = search_order_manager.orders_len
		search_order_manager.orders_len = current_index + 1
		search_order_manager:ensure_capacity(search_order_manager.orders_len)
		local search_order = search_order_manager.search_orders[current_index]
		search_order.origin_x, search_order.origin_y = origin.x, origin.y
		search_order.min_range = min_range
		search_order.max_range = max_range
		-- search_order.prediction_time = prediction_time or 0
		-- search_order.flags = flags
		-- search_order.bans = bans
		-- search_order.min_override_flags = min_override_flags
		-- search_order.crowd_range = crowd_range or 0
		-- search_order.min_targets = min_targets or 1
		search_order.allowed_templates, search_order.allowed_templates_len = U.string_table_to_c_string_array(allowed_templates, ffi)
		search_order.excluded_templates, search_order.excluded_templates_len = U.string_table_to_c_string_array(excluded_templates, ffi)
		-- search_order.search_type = search_type
		search_order.max_towers = max_towers or -1
		search_order.including_blocked = including_blocked or false
		search_order.including_holder = including_holder or false
		search_order.type = -1
		return current_index
	end
	self.use_worker_thread = nil
	return nil
end

function simulation:get_search_result(index, entities, origin, filter_func, targets)
	local search_result = self.store.search_order_manager.search_results[index]
	local number = search_result.number
	for i = 0, number - 1 do
		local entity_pos = search_result.entityPosions[i]
		local id = entity_pos.id
		local e = entities[id]
		if e and (not filter_func or filter_func(e, origin)) then
			if e.__ffe_pos then
				e.__ffe_pos.x, e.__ffe_pos.y = entity_pos.x, entity_pos.y
			else
				e.__ffe_pos = V.v(entity_pos.x, entity_pos.y)
			end
			table.insert(targets, e)
		end
	end
end

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
	self.systems_on_queue = {}
	self.systems_on_dequeue = {}
	self.systems_on_insert = {}
	self.systems_on_remove = {}
	self.systems_on_update = {}
	self.systems_destroy = {}

	local systems_order = {}

	for _, name in pairs(active_system_names) do
		if not systems[name] then
			log.error("System named %s not found", name)
		else
			table.insert(systems_order, systems[name])
		end
	end

	-- if DEBUG then
		-- block empty
	-- end

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

			if s.destroy then
				table.insert(self.systems_destroy, s)
			end
		end
	end

	self.use_worker_thread = true
	d.entity_info_manager = EntityInfoManager.new(1024)
	d.search_order_manager = SearchOrderManager.new(1024, search_worker.create_search_worker())
end

function simulation:destroy()
	for _, sys in ipairs(self.systems_destroy) do
		sys:destroy(self.store)
	end
	search_worker.search_worker_destroy(self.store.search_order_manager.searchWorker)
end

function simulation:update(dt)
	myExtension.debug.flush_logs()
	myExtension.debug.push_error()

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

	local entities = d.entities

	while #d.pending_inserts > 0 do
		local e = table.remove(d.pending_inserts, 1)

		self:insert_entity(e)
	end

	while #d.pending_removals > 0 do
		local e = table.remove(d.pending_removals, 1)

		self:remove_entity(e)
	end

	if d.level.show_health_texts and d.entity_count > 1024 then
		d.level.show_health_texts = nil
	end

	for _, sys in ipairs(self.systems_on_update) do
		sys:on_update(d.tick_length, d.tick_ts, d)
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