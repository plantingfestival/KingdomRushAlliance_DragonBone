-- customization
function table.getTableLength(table)
	local count = 0
	for k, v in pairs(table) do
		count = count + 1
	end
	return count
end
-- customization

function table.keys(t)
	local kk = {}
	local count = 0

	for k, _ in pairs(t) do
		count = count + 1
		kk[count] = k
	end

	return kk
end

function table.keyforobject(t, o)
	local key

	for k, v in pairs(t) do
		if o == v then
			key = k

			break
		end
	end

	return key
end

function table.contains(t, o)
	return table.keyforobject(t, o) ~= nil
end

function table.clone(t)
	local t2 = {}

	for k, v in pairs(t) do
		t2[k] = v
	end

	return t2
end

-- function table.deepclone(t)
-- 	if type(t) == "table" then
-- 		local out = {}

-- 		for k, v in pairs(t) do
-- 			out[k] = table.deepclone(v)
-- 		end

-- 		return out
-- 	else
-- 		return t
-- 	end
-- end

function table.deepclone(t)
	if type(t) ~= "table" then
		return t
	end

	-- 将全局函数局部化，减少哈希查找成本
	local type = type
	local getmetatable = getmetatable
	local setmetatable = setmetatable
	-- local rawget = rawget
	local next = next  -- 比 pairs 快 5~10%，且不产生闭包

	local visited = {}
	local stack_o = {}  -- original 栈
	local stack_c = {}  -- copy 栈
	local top = 1

	local root = {}
	visited[t] = root
	stack_o[1] = t
	stack_c[1] = root

	while top > 0 do
		local original = stack_o[top]
		local copy = stack_c[top]
		top = top - 1

		local k = next(original)
		while k ~= nil do
			local v = original[k]

			-- === 深拷贝键 ===
			local newKey = k
			if type(k) == "table" then
				local cached = visited[k]
				if cached then
					newKey = cached
				else
					newKey = {}
					visited[k] = newKey
					top = top + 1
					stack_o[top] = k
					stack_c[top] = newKey

					local keyMt = getmetatable(k)
					if keyMt then
						setmetatable(newKey, keyMt)
					end
				end
			end

			-- === 深拷贝值 ===
			if type(v) == "table" then
				local cached = visited[v]
				if cached then
					copy[newKey] = cached
				else
					local newTable = {}
					copy[newKey] = newTable
					visited[v] = newTable
					top = top + 1
					stack_o[top] = v
					stack_c[top] = newTable

					local subMt = getmetatable(v)
					if subMt then
						setmetatable(newTable, subMt)
					end
				end
			else
				copy[newKey] = v
			end

			k = next(original, k)
		end
	end

	local rootMt = getmetatable(t)
	if rootMt then
		setmetatable(root, rootMt)
	end

	return root
end

function table.equals(t1, t2)
	if type(t1) == "table" and type(t2) == "table" then
		for k1, v1 in pairs(t1) do
			if not table.equals(v1, t2[k1]) then
				return false
			end
		end

		for k2, v2 in pairs(t2) do
			if not t1[k2] then
				return false
			end
		end

		return true
	else
		return t1 == t2
	end
end

function table.merge(t1, t2, new)
	local m = new and table.clone(t1) or t1

	for k, v in pairs(t2) do
		m[k] = v
	end

	return m
end

function table.deepmerge(t1, t2, new)
	local m = new and table.deepclone(t1) or t1

	for k, v in pairs(t2) do
		v = new and table.deepclone(v) or v

		if type(v) == "table" and m[k] and type(m[k]) == "table" then
			table.deepmerge(m[k], v)
		else
			m[k] = v
		end
	end

	return m
end

function table.append(t1, t2, new)
	local m = new and table.clone(t1) or t1

	for i, v in ipairs(t2) do
		table.insert(m, v)
	end

	return m
end

function table.reverse(t1, deep)
	local t2 = {}
	local l_t1 = #t1

	for i = 1, l_t1 do
		local e_t1 = t1[l_t1 - i + 1]

		t2[i] = deep and table.deepclone(e_t1) or e_t1
	end

	return t2
end

function table.count(t, filter)
	local ct = 0

	if filter then
		for k, v in pairs(t) do
			if filter(k, v) then
				ct = ct + 1
			end
		end
	else
		for k, v in pairs(t) do
			ct = ct + 1
		end
	end

	return ct
end

function table.find(t, filter)
	if type(filter) == "function" then
		for k, v in pairs(t) do
			if filter(k, v) then
				return k
			end
		end
	else
		for k, v in pairs(t) do
			if filter == v then
				return k
			end
		end
	end

	return nil
end

function table.filter(t, filter)
	local t2 = {}

	for k, v in pairs(t) do
		if filter(k, v) then
			t2[#t2 + 1] = v
		end
	end

	return t2
end

function table.map(t, m)
	local t2 = {}

	for k, v in pairs(t) do
		local ra, rb = m(k, v)

		if rb ~= nil then
			t2[ra] = rb
		else
			t2[#t2 + 1] = ra
		end
	end

	return t2
end

function table.reduce(t, fn)
	local s = 0

	for _, v in pairs(t) do
		s = fn(v, s)
	end

	return s
end

function table.maxv(t)
	local max, max_k

	for k, v in pairs(t) do
		if max == nil or max < v then
			max = v
			max_k = k
		end
	end

	return max_k, max
end

function table.minv(t)
	local min, min_k

	for k, v in pairs(t) do
		if min == nil or v < min then
			min = v
			min_k = k
		end
	end

	return min_k, min
end

function table.slice(t, i1, i2)
	local out = {}
	local n = #t

	i1 = i1 or 1
	i2 = i2 or n

	if i2 < 0 then
		i2 = n + i2 + 1
	elseif n < i2 then
		i2 = n
	end

	if i1 < 1 or n < i1 then
		return {}
	end

	local k = 1

	for i = i1, i2 do
		out[k] = t[i]
		k = k + 1
	end

	return out
end

function table.insert_mt(t, o)
	local mt = getmetatable(t)

	if mt then
		t[#mt + 1] = o
	else
		table.insert(t, o)
	end
end

function table.removeobject(t, o)
	local k = table.keyforobject(t, o)

	if k ~= nil then
		table.remove(t, k)
	end
end

function table.random(t)
	if not t or #t < 1 then
		return nil
	else
		local idx = math.random(1, #t)

		return t[idx], idx
	end
end

function table.random_order(t)
	if not t or #t < 1 then
		return nil
	end

	local tt = table.clone(t)
	local o = {}

	for i = 1, #t do
		local ri = math.random(1, #tt)

		table.insert(o, table.remove(tt, ri))
	end

	return o
end

function table.safe_index(t, index)
	local size = #t

	if not t or size < 1 then
		return nil
	else
		local idx = math.min(index, size)

		return t[idx], idx
	end
end
