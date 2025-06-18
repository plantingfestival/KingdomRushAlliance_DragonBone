-- chunkname: @./kr5/data/kui_templates/group_defeattext.lua

return {
	class = "KView",
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 75,
			line_height_extra = "2",
			text_key = "DEFEAT",
			text = "defeat",
			class = "GG5ShaderLabel",
			id = "label_defeat",
			fit_size = true,
			font_name = "fla_h",
			pos = v(-194.95, -35.65),
			size = v(385.7, 80.1),
			colors = {
				text = {
					51,
					51,
					51
				}
			},
			shaders = {
				"p_bands",
				"p_outline_tint"
			},
			shader_args = {
				{
					margin = 1,
					p1 = 0.5,
					p2 = 0.99,
					c1 = {
						1,
						0.6431,
						0.1608,
						1
					},
					c2 = {
						0.8784,
						0.4118,
						0.1176,
						1
					},
					c3 = {
						0.8784,
						0.4118,
						0.1176,
						1
					}
				},
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0.5137,
						0.1725,
						0,
						1
					}
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "TXT_VICTORY_GEMS",
			font_size = 32,
			line_height_extra = "2",
			text = "999",
			class = "GG5Label",
			id = "label_gems_amount",
			font_name = "fla_numbers",
			pos = v(-15, 76.15),
			size = v(113.05, 43.4),
			colors = {
				text = {
					255,
					255,
					255
				}
			}
		}
	}
}
