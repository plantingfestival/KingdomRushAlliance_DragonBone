-- chunkname: @./kr5/data/kui_templates/button_level_select_buy.lua

return {
	default_image_name = "level_select_button_buy_bg_0001",
	class = "GG5Button",
	focus_image_name = "level_select_button_buy_bg_0003",
	image_offset = v(-143.05, -65.25),
	hit_rect = r(-143.05, -65.25, 299, 133),
	children = {
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 44,
			line_height_extra = "2",
			fit_size = true,
			text = "buy",
			text_key = "BUTTON_LEVEL_SELECT_FIGHT",
			class = "GG5ShaderLabel",
			id = "label_campaign_fight",
			font_name = "fla_h",
			pos = v(-105.5, -37.25),
			scale = v(1, 1),
			size = v(213.3, 65.4),
			colors = {
				text = {
					61,
					18,
					13
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0.9765,
						0.8667,
						0.1176,
						1
					}
				}
			}
		}
	}
}
