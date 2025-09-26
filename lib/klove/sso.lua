-- chunkname: @./lib/klove/sso.lua

local log = require("klua.log"):new("sso")
local SSO = {}

SSO.persistent_lists = {}

function SSO:reset_p_lists()
	self.persistent_lists = {
		alive_enemies = {},
		graveyards = {},
		modifiers = {}
	}
end

function SSO:get_p_list(name)
	local l = self.persistent_lists and self.persistent_lists[name]

	if DEBUG and not l then
		log.error("SSO list %s does not exist", name)
	end

	return l
end

SSO.bb_mode = true

if SSO.bb_mode then
	SSO.grids = {}
	SSO.bb_step = 128

	function SSO:reset(entities)
		self.bb_all_entities = entities
		self.bb_grids = {}
	end

	function SSO:is_all_entities(entities)
		if entities == self.bb_all_entities then
			return true
		elseif DEBUG then
			log.traceall("WARNING: the following find cannot be optimized as it does not pass store.entities")
		end
	end

	function SSO:create(name, x, y, w, h)
		local g = {}

		g.x = x
		g.y = y
		g.w = w
		g.h = h
		g.min_ix = 0
		g.max_ix = 0
		g.min_iy = 0
		g.max_iy = 0
		g.grid = {}
		g.name = name
		self.bb_grids[name] = g

		return g
	end

	function SSO:insert(g, x, y, v)
		local box, boy, bstep = g.x, g.y, self.bb_step
		local ix = math.ceil((x - box) / bstep)
		local iy = math.ceil((y - boy) / bstep)
		local gg = g.grid

		if not gg[ix] then
			gg[ix] = {}
		end

		if not gg[ix][iy] then
			gg[ix][iy] = {}
		end

		local gxy = gg[ix][iy]

		table.insert(gxy, v)

		g.min_ix = math.min(g.min_ix, ix)
		g.max_ix = math.max(g.max_ix, ix)
		g.min_iy = math.min(g.min_iy, iy)
		g.max_iy = math.max(g.max_iy, iy)
	end

	function SSO:filter(out, name, x, y, range, filter_fn)
		local g = self.bb_grids[name]

		if not g then
			log.error("bb_grid %s not found", name)

			return
		end

		local box, boy, bstep = g.x, g.y, self.bb_step
		local ix0 = math.max(g.min_ix, math.ceil((x - range - box) / bstep))
		local ix1 = math.min(g.max_ix, math.ceil((x + range - box) / bstep))
		local iy0 = math.max(g.min_iy, math.ceil((y - range - boy) / bstep))
		local iy1 = math.min(g.max_iy, math.ceil((y + range - boy) / bstep))
		local gg = g.grid

		for ix = ix0, ix1 do
			if gg[ix] then
				for iy = iy0, iy1 do
					if gg[ix][iy] then
						for _, v in pairs(gg[ix][iy]) do
							if v and (not filter_fn or filter_fn(_, v)) then
								table.insert(out, v)
							end
						end
					end
				end
			end
		end
	end
else
	SSO.trees = {}
	SSO.max_depth = 8
	SSO.max_count = 4

	function SSO:reset()
		self.trees = {}
	end

	function SSO:create(name, x, y, w, h)
		local n = {
			x,
			y,
			w,
			h,
			0,
			{}
		}

		n.name = name
		self.trees[name] = n

		return n
	end

	function SSO:insert(n, x, y, v)
		local nx, ny, nw, nh, nd = unpack(n)
		local nptrs = n[6]
		local nch = n[7]

		if x <= nx or x > nx + nw or y <= ny or y > ny + nh then
			return false
		end

		if nptrs and (#nptrs < SSO.max_count or nd >= SSO.max_depth) then
			table.insert(nptrs, {
				x,
				y,
				v
			})

			return true
		end

		if not nch then
			local ch_w, ch_h = nw / 2, nh / 2
			local new_depth = nd + 1

			nch = {
				{
					nx + ch_w,
					ny + ch_h,
					ch_w,
					ch_h,
					new_depth,
					{}
				},
				{
					nx,
					ny + ch_h,
					ch_w,
					ch_h,
					new_depth,
					{}
				},
				{
					nx,
					ny,
					ch_w,
					ch_h,
					new_depth,
					{}
				},
				{
					nx + ch_w,
					ny,
					ch_w,
					ch_h,
					new_depth,
					{}
				}
			}
			n[6] = nil
			n[7] = nch

			if not nptrs then
				-- block empty
			end

			for _, pptr in pairs(nptrs) do
				for _, nnch in pairs(nch) do
					if self:insert(nnch, pptr[1], pptr[2], pptr[3]) then
						break
					end
				end
			end
		end

		for _, nnch in pairs(nch) do
			if self:insert(nnch, x, y, v) then
				return true
			end
		end

		return false
	end

	function SSO:filter(out, name, x, y, range, filter_fn)
		local n = self.trees[name]

		if not n then
			log.error("quadtree %s not found", name)

			return
		end

		SSO:filter_node(out, n, x, y, range, filter_fn)
	end

	function SSO:filter_node(out, n, x, y, range, filter_fn)
		local nx, ny, nw, nh, nd = unpack(n)
		local nptrs = n[6]
		local nch = n[7]
		local clx = math.max(nx, math.min(x, nx + nw))
		local cly = math.max(ny, math.min(y, ny + nh))
		local dx = x - clx
		local dy = y - cly

		if dx * dx + dy * dy > range * range then
			return
		end

		if nptrs then
			for _, ptr in ipairs(nptrs) do
				local vx, vy, v = unpack(ptr)
				local dx = x - vx
				local dy = y - vy

				if dx * dx + dy * dy <= range * range and (not filter_fn or filter_fn(_, v)) then
					table.insert(out, v)
				end
			end
		end

		if nch then
			for _, nnch in pairs(nch) do
				self:filter_node(out, nnch, x, y, range)
			end
		end
	end
end

return SSO
