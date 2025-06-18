-- chunkname: @./kr5/data/kui_templates/group_victorytext1.lua

return {
	class = "KView",
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 75,
			line_height_extra = "2",
			text_key = "VICTORY",
			text = "VICTORY",
			class = "GG5ShaderLabel",
			id = "label_victor",
			fit_size = true,
			font_name = "fla_h",
			pos = v(-193, -36.4),
			size = v(397, 76.15),
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
						0.9961,
						1,
						0.4784,
						1
					},
					c2 = {
						0.9765,
						0.8706,
						0.1059,
						1
					},
					c3 = {
						0.9765,
						0.8706,
						0.1059,
						1
					}
				},
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0.6902,
						0.4,
						0,
						1
					}
				}
			}
		}
	}
}
