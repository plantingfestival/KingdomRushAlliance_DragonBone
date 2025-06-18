-- chunkname: @./kr5/data/kui_templates/button_achievement_room_amount_indicator.lua

return {
	focus_image_name = "achievements_room_undefined_0003",
	default_image_name = "achievements_room_undefined_0001",
	class = "GG5Button",
	children = {
		{
			id = "image_achievement_room_amount_indicator",
			image_name = "achievements_room_image_achievement_room_amount_indicator_",
			class = "KImageView",
			pos = v(1.65, -1.65),
			anchor = v(52.15, 42.65)
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 45,
			fit_size = true,
			line_height_extra = "2",
			text = "2",
			class = "GG5ShaderLabel",
			id = "label_achievement_room_amount_indicator",
			font_name = "fla_h",
			pos = v(-40.95, -30.9),
			scale = v(1, 1),
			size = v(65.3, 45.65),
			colors = {
				text = {
					231,
					244,
					251
				}
			},
			shaders = {
				"p_outline",
				"p_outline"
			},
			shader_args = {
				{
					thickness = 1.6666666666666667,
					outline_color = {
						0,
						0.2667,
						0.4745,
						1
					}
				},
				{
					thickness = 1.6666666666666667,
					outline_color = {
						0.8431,
						0.5804,
						0,
						1
					}
				}
			}
		}
	}
}
