-- chunkname: @./kr5/data/kui_templates/group_more_games.lua

return {
	class = "KView",
	children = {
		{
			id = "button_more_games",
			focus_image_name = "screen_slots_button_more_games_0003",
			class = "GG5Button",
			default_image_name = "screen_slots_button_more_games_0001",
			pos = v(-129.45, -113.7),
			anchor = v(104.8, 85.5)
		},
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 30,
			line_height_extra = "0",
			fit_size = true,
			text = "more games",
			text_key = "MORE_GAMES",
			class = "GG5ShaderLabel",
			id = "label_more_games",
			font_name = "fla_h",
			pos = v(-251.1, -76.45),
			scale = v(1, 1),
			size = v(242.1, 45),
			colors = {
				text = {
					54,
					219,
					255
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0.098,
						0.2039,
						0.2235,
						1
					}
				}
			}
		}
	}
}
