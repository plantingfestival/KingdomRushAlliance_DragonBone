-- chunkname: @./all/grid_a_star.lua

local log = require("klua.log"):new("grid_a_star")

require("klua.table")

local a = {}

function a.heuristic_cost(n1, n2)
	return math.sqrt(math.pow(n2.x - n1.x, 2) + math.pow(n2.y - n1.y, 2))
end

function a.get_lowest_node(nodes, cost_for_node)
	local best_score = 1 / 0
	local best_node

	for _, n in ipairs(nodes) do
		local score = cost_for_node[n]

		if score < best_score then
			best_score = score
			best_node = n
		end
	end

	return best_node
end

function a.get_neighbors(nodes, node, grid, valid_cell_fn)
	local result = {}

	for i = -1, 1 do
		for j = -1, 1 do
			if i ~= 0 or j ~= 0 then
				local cx, cy = node.x + i, node.y + j

				if cx > 1 and cx < #grid and cy > 1 and cy < #grid[cx] then
					local cell = grid[cx][cy]

					if valid_cell_fn(cx, cy, cell) then
						table.insert(result, a.get_node(nodes, cx, cy))
					end
				end
			end
		end
	end

	return result
end

function a.table_contains(table, node)
	for _, n in pairs(table) do
		if n.x == node.x and n.y == node.y then
			return true
		end
	end

	return false
end

function a.table_remove(t, node)
	local key

	for k, n in pairs(t) do
		if n.x == node.x and n.y == node.y then
			key = k

			break
		end
	end

	if key ~= nil then
		table.remove(t, key)
	end
end

function a.get_node(nodes, x, y)
	if nodes[x] == nil then
		nodes[x] = {}
		nodes[x][y] = {
			x = x,
			y = y
		}
	elseif nodes[x][y] == nil then
		nodes[x][y] = {
			x = x,
			y = y
		}
	end

	return nodes[x][y]
end

function a.find_nearest_valid(coords, grid, valid_cell_fn, max_dist)
	for dist = 0, max_dist do
		for i = -dist, dist do
			for j = -dist, dist do
				local cx, cy = coords.x + i, coords.y + j

				if cx > 1 and cx < #grid and cy > 1 and cy < #grid[cx] and valid_cell_fn(cx, cy, grid[cx][cy]) then
					return {
						x = cx,
						y = cy
					}
				end
			end
		end
	end

	return nil
end

function a.get_path(start_coords, goal_coords, grid, valid_cell_fn, debug_data)
	log.debug("start")

	local nodes = {}
	local start = a.get_node(nodes, start_coords.x, start_coords.y)
	local goal = a.get_node(nodes, goal_coords.x, goal_coords.y)
	local previous = {}
	local closed = {}
	local open = {
		start
	}
	local cost_back = {}
	local cost_forward = {}

	cost_back[start] = 0
	cost_forward[start] = cost_back[start] + a.heuristic_cost(start, goal)

	local current
	local iterations = 0

	while #open > 0 do
		iterations = iterations + 1
		current = a.get_lowest_node(open, cost_forward)

		if current == goal then
			break
		end

		local neighbors = a.get_neighbors(nodes, current, grid, valid_cell_fn)

		for _, neighbor in pairs(neighbors) do
			do
				local step_cost

				step_cost = (neighbor.x == current.x or neighbor.y == current.y) and 1 or 1.4142

				local n_cost_back = cost_back[current] + step_cost

				if a.table_contains(closed, neighbor) then
					if n_cost_back >= cost_back[neighbor] then
						goto label_8_0
					end

					a.table_remove(closed, neighbor)
				elseif a.table_contains(open, neighbor) and n_cost_back >= cost_back[neighbor] then
					goto label_8_0
				end

				previous[neighbor] = current
				cost_back[neighbor] = n_cost_back
				cost_forward[neighbor] = n_cost_back + a.heuristic_cost(neighbor, goal)

				if not a.table_contains(open, neighbor) then
					table.insert(open, neighbor)
				end
			end

			::label_8_0::
		end

		a.table_remove(open, current)
		table.insert(closed, current)
	end

	if debug_data then
		debug_data.iterations = iterations
		debug_data.grid = grid
		debug_data.start = start
		debug_data.goal = goal
		debug_data.nodes = nodes
		debug_data.cost_back = cost_back
		debug_data.cost_forward = cost_forward
		debug_data.closed = closed
	end

	log.debug("end. iterations %s", iterations)

	if current ~= goal then
		return nil
	else
		local result = {}

		while current ~= start do
			table.insert(result, 1, current)

			current = previous[current]
		end

		if debug_data then
			debug_data.result = result
		end

		return result
	end
end

function a.dump_costs(debug_data)
	local d = debug_data
	local out = ""

	for i = 1, #d.grid do
		for j = 1, #d.grid[i] do
			local n = a.get_node(d.nodes, i, j)
			local cost = d.cost_back[n]

			out = out .. (cost and string.format("%02i ", cost) or ".  ")
		end

		out = out .. "\n"
	end

	return out
end

function a.dump_path(path)
	local out = ""

	for _, n in ipairs(path) do
		out = out .. string.format("-> %s,%s ", n.x, n.y)
	end

	return out
end

return a
