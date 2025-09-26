-- chunkname: @./kr5/data/kui_templates/particle_system_editor_view.lua

local TW = ctx.pse_prop_w
local BH = ctx.pse_prop_h
local M = ctx.pse_margin
local FN = ctx.pse_font_name
local FS = ctx.pse_font_size
local H = 450

return {
	can_drag = "true",
	class = "RBView",
	id = "particle_system_editor_view",
	pos = v(30, 30),
	size = v(TW + 2 * M, H + M),
	colors = {
		background = {
			200,
			200,
			200,
			255
		}
	},
	children = {
		{
			class = "KButton",
			text = "X",
			id = "rb_close",
			font_name = FN,
			font_size = FS,
			colors = {
				background = {
					120,
					120,
					120,
					255
				}
			},
			size = {
				x = BH,
				y = BH
			},
			pos = {
				x = 0,
				y = 0
			},
			text_offset = {
				x = 0,
				y = 6
			}
		},
		{
			class = "KLabel",
			text_align = "left",
			text = "PARTICLE SYSTEM EDITOR",
			id = "rb_title",
			font_name = FN,
			font_size = FS,
			colors = {
				background = {
					180,
					180,
					180,
					255
				}
			},
			size = {
				x = TW - BH + 2 * M,
				y = BH
			},
			pos = {
				y = 0,
				x = BH
			},
			text_offset = {
				x = 10,
				y = 6
			}
		},
		{
			style = "vertical",
			class = "KELayout",
			pos = v(M, BH + M),
			children = {}
		}
	}
}
