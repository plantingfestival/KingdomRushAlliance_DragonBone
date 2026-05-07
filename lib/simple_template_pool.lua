-- ============================================
-- 简单模板对象池
-- ============================================
local SimpleTemplatePool = {}
-- 哨兵值，标记要保留的字段
SimpleTemplatePool.KEEP = {}
local deepclone = table.deepclone
local remove = table.remove

local function reset_by_template(obj, template)
	-- 删除对象中所有不在模板键集合中的字段
	for k in pairs(obj) do
		if template[k] == nil then
			obj[k] = nil
		end
	end

	-- 按模板覆盖
	for k, v in pairs(template) do
		if type(v) ~= "table" then
			obj[k] = v
		elseif v ~= SimpleTemplatePool.KEEP then
			if type(obj[k]) == "table" then
				-- block empty
			else
				obj[k] = {}
			end
			reset_by_template(obj[k], v)
		end
	end
end

-- 生成不含 KEEP 的纯净副本，用于新表拷贝
local function make_clean_template(tpl)
	local clean = {}
	for k, v in pairs(tpl) do
		if v ~= SimpleTemplatePool.KEEP then
			if type(v) ~= "table" then
				clean[k] = v
			else
				clean[k] = make_clean_template(v)
			end
		end
	end
	return clean
end

-- 创建池
-- template : 模板表
-- max_size : 池最大空闲对象数，默认 4096
-- prefill  : 预创建对象数量，默认等于 max_size（且 ≤ max_size）
function SimpleTemplatePool.new(template, max_size, prefill)
	max_size = max_size or 4096
	prefill  = prefill or max_size
	prefill  = math.min(prefill, max_size)

	-- 生成纯净模板（预留用于新表拷贝）
	local clean_template = make_clean_template(template)

	local items = {}
	for i = 1, prefill do
		items[i] = deepclone(clean_template)
	end

	local pool = {
		_template = template,       -- 原始模板（带哨兵值）
		_clean_template = clean_template, -- 纯净模板（仅用于 acquire 函数的拷贝）
		_items = items,
		_max_size = max_size,
		_trim_timer = 0,
		_trim_interval = 2.0,
		_trim_count = 256,
	}
	setmetatable(pool, { __index = SimpleTemplatePool })
	return pool
end

-- 获取对象
function SimpleTemplatePool:acquire(params)
	local obj
	if #self._items > 0 then
		obj = remove(self._items)
	else
		obj = deepclone(self._clean_template)
	end

	if params then
		for k, v in pairs(params) do
			if type(k) ~= "string" or not k:find("%.") then
				obj[k] = v
			else
				local code = "obj." .. k .. " = value"
				local func = loadstring(code)
				local env = { obj = obj, value = v }
				setfenv(func, env)
				func()
			end
		end
	end
	return obj
end

-- 回收对象（重置后入池，先不检查上限）
function SimpleTemplatePool:release(obj)
	reset_by_template(obj, self._template)
	self._items[#self._items + 1] = obj
end

-- 每帧调用，dt 为时间增量（秒）
function SimpleTemplatePool:update(dt)
	self._trim_timer = self._trim_timer + dt
	if self._trim_timer < self._trim_interval then return end

	local excess = #self._items - self._max_size
	if excess > 0 then
		for _ = 1, math.min(excess, self._trim_count) do
			remove(self._items)
		end
	end

	-- 清理完成，重置定时器为 0
	self._trim_timer = 0
end

-- 手动清理至上限
function SimpleTemplatePool:trim_all()
	if #self._items <= self._max_size then return end

	local new_items = {}
	for i = 1, self._max_size do
		new_items[i] = self._items[i]
	end
	self._items = new_items
end

return SimpleTemplatePool