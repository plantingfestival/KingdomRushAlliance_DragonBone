local log = require("klua.log"):new("render_utils")
local I = require("klove.image_db")
local G = love.graphics
local EXO = require("exoskeleton")
local RU = {}

RU.BATCHES_COUNT = 30
RU.BATCH_SIZE = 50
RU.batches = {}
RU.bi = 1

function RU.init()
	RU.add_batches(RU.BATCHES_COUNT)

	RU.bi = 1
	RU.last_texture = nil
end

function RU.destroy()
	RU.batches = {}
	RU.last_texture = nil
end

function RU.new_frame()
	RU.bi = 1
end

function RU.add_batches(count)
	if #RU.batches > 1000 and not RU.too_many_batches then
		log.error("1000 sprite batches per frame exceeded! Way too many batches!")

		RU.too_many_batches = true
	end

	local temp_canvas = G.newCanvas(2, 2)

	for i = 1, count do
		table.insert(RU.batches, G.newSpriteBatch(temp_canvas, RU.BATCH_SIZE, "stream"))
	end
end

function RU.frame_draw_params(f)
	local ss = f.ss
	local x = f.pos.x + f.offset.x
	local y = REF_H - (f.pos.y + f.offset.y)

	local r = -f.r

	local ref_scale = ss.ref_scale or 1
	local sy, sx, ox, oy
	if ss.textureRotated then
		r = r - math.pi / 2
		ox = f.anchor.y * ss.size[2] - ss.trim[4]
		oy = f.anchor.x * ss.size[1] - ss.trim[1]
		sy = (f.flip_x and -1 or 1) * ref_scale
		sx = (f.flip_y and -1 or 1) * ref_scale
		if f.scale then
			sy = sy * f.scale.x
			sx = sx * f.scale.y
		end
	else
		sy = (f.flip_y and -1 or 1) * ref_scale
		sx = (f.flip_x and -1 or 1) * ref_scale
		if f.scale then
			sy = sy * f.scale.y
			sx = sx * f.scale.x
		end
		ox = f.anchor.x * ss.size[1] - ss.trim[1]
		oy = (1 - f.anchor.y) * ss.size[2] - ss.trim[2]
	end

	return ss.quad, x, y, r, sx, sy, ox, oy
end

function RU.draw_frames_range(frames, start_idx, max_z)
	local current_atlas, lr, lg, lb, la
	local r, g, b, a = 255, 255, 255, 255
	local batch_count = 0
	local batches_count = 0
	local BATCH_SIZE = RU.BATCH_SIZE
	local last_idx = start_idx
	local frame_draw_params = RU.frame_draw_params
	local batches = RU.batches
	local bi = RU.bi
	local bi_count = #RU.batches
	local batch = batches[bi]
	local last_texture = RU.last_texture
	local current_shader

	batch:clear()

	if last_texture then
		batch:setTexture(last_texture)
	end

	G.setColor(255, 255, 255, 255)

	for i = start_idx, #frames do
		local f = frames[i]

		if max_z <= f.z then
			break
		end

		last_idx = i

		local ss = f.ss

		if f.hidden then
			-- block empty
		elseif f.exo then
			for part_idx, part in ipairs(f.exo_frame.parts) do
				local ss = I:s(part.name)

				if part.hidden then
					-- block empty
				else
					if batch_count == BATCH_SIZE or f.shader ~= current_shader or ss.atlas and ss.atlas ~= current_atlas then
						if batch_count > 0 then
							G.draw(batch)

							bi = bi + 1

							if bi_count < bi then
								RU.add_batches(10)

								bi_count = #RU.batches
							end

							batch = batches[bi]

							if last_texture then
								batch:setTexture(last_texture)
							end
						end

						batch:clear()

						lr, lg, lb, la = nil

						if ss.atlas then
							local im, w, h = I:i(ss.atlas)

							current_atlas = ss.atlas
							last_texture = im

							batch:setTexture(im)
						end

						batch_count = 0
						batches_count = batches_count + 1

						if f.shader ~= current_shader then
							G.setShader(f.shader)

							if f.shader_args then
								for k, v in pairs(f.shader_args) do
									f.shader:send(k, v)
								end
							end

							current_shader = f.shader
						end
					end

					if f.color then
						r, g, b = f.color[1], f.color[2], f.color[3]
					else
						r, g, b = 255, 255, 255
					end

					a = f.alpha * (part.alpha or 1)

					if a ~= la or r ~= lr or g ~= lg or b ~= lb then
						batch:setColor(r, g, b, a)

						lr, lg, lb, la = r, g, b, a
					end

					local exo_part = f.exo.parts[part.name]
					local pox, poy = exo_part.offsetX, exo_part.offsetY
					local quad = ss.quad
					local ref_scale = ss.ref_scale or 1
					local xf = part.xform
					local x, y, r, sx, sy, kx, ky = xf.x, xf.y, xf.r, xf.sx, xf.sy, xf.kx, xf.ky

					r = -f.r + r
					local f_sx = f.flip_x and -1 or 1
					local f_sy = f.flip_y and -1 or 1
					local ox, oy
					if ss.textureRotated then
						r = r - math.pi / 2
						ox = 0.5 * ss.size[2] - ss.trim[4] + poy / ref_scale
						oy = 0.5 * ss.size[1] - ss.trim[1] - pox / ref_scale
						sy = xf.sx * f_sx * ref_scale
						sx = xf.sy * f_sy * ref_scale
						if f.scale then
							sy = sy * f.scale.x
							sx = sx * f.scale.y
						end
					else
						sy = sy * (f.flip_y and -1 or 1) * ref_scale
						sx = sx * (f.flip_x and -1 or 1) * ref_scale

						if f.scale then
							sy = sy * f.scale.y
							sx = sx * f.scale.x
							f_sx = f_sx * f.scale.x
							f_sy = f_sy * f.scale.y
						end

						ox = 0.5 * ss.size[1] - ss.trim[1] - pox / ref_scale
						oy = 0.5 * ss.size[2] - ss.trim[2] - poy / ref_scale
					end

					x = x * f_sx + f.pos.x + f.offset.x
					y = REF_H - (-y * f_sy + f.pos.y + f.offset.y)

					batch:add(quad, x, y, r * (f.flip_x and -1 or 1), sx, sy, ox, oy, kx, ky)

					batch_count = batch_count + 1
				end
			end
		elseif not ss then
			-- block empty
		else
			if batch_count == BATCH_SIZE or f.shader ~= current_shader or ss.atlas and ss.atlas ~= current_atlas then
				if batch_count > 0 then
					G.draw(batch)

					bi = bi + 1

					if bi_count < bi then
						RU.add_batches(10)

						bi_count = #RU.batches
					end

					batch = batches[bi]

					if last_texture then
						batch:setTexture(last_texture)
					end
				end

				batch:clear()

				lr, lg, lb, la = nil

				if ss.atlas then
					local im, w, h = I:i(ss.atlas)

					current_atlas = ss.atlas
					last_texture = im

					batch:setTexture(im)
				end

				batch_count = 0
				batches_count = batches_count + 1

				if f.shader ~= current_shader then
					G.setShader(f.shader)

					if f.shader_args then
						for k, v in pairs(f.shader_args) do
							f.shader:send(k, v)
						end
					end

					current_shader = f.shader
				end
			end

			if f.color then
				r, g, b = f.color[1], f.color[2], f.color[3]
			else
				r, g, b = 255, 255, 255
			end

			a = f.alpha

			if a ~= la or r ~= lr or g ~= lg or b ~= lb then
				batch:setColor(r, g, b, a)

				lr, lg, lb, la = r, g, b, a
			end

			batch:add(frame_draw_params(f))

			batch_count = batch_count + 1
		end
	end

	if batch_count > 0 then
		G.draw(batch)

		bi = bi + 1

		if bi_count < bi then
			RU.add_batches(10)

			bi_count = #RU.batches
		end

		batch = batches[bi]
		batches_count = batches_count + 1
	end

	G.setColor(255, 255, 255, 255)

	if current_shader then
		G.setShader()
	end

	RU.bi = bi
	RU.last_texture = last_texture

	return last_idx
end

return RU
