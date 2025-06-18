-- chunkname: @./kr5/data/kui_templates/toggle_difficulty_level.lua

return {
	class = "GG5ToggleButton",
	true_image_name = "difficulty_room_image_toggle_difficulty_bg_0001",
	focus_image_name = "difficulty_room_image_toggle_difficulty_bg_0003",
	false_image_name = "difficulty_room_image_toggle_difficulty_bg_0002",
	image_offset = v(-180.05, -264.75),
	hit_rect = r(-180.05, -264.75, 362, 532),
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5ShaderLabel",
			font_size = 36,
			line_height_extra = "1",
			text = "casual",
			id = "label_difficulty_title",
			fit_size = true,
			font_name = "fla_h",
			pos = v(-134, 88.25),
			size = v(266, 36.55),
			colors = {
				text = {
					221,
					246,
					254
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 2.916666666666667,
					outline_color = {
						0.1843,
						0.2824,
						0.3059,
						1
					}
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "0",
			font_size = 20,
			text = "For begginers to strategy games.\nA fair challange!",
			id = "label_difficulty_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-126.55, 134.45),
			size = v(252.35, 94.45),
			colors = {
				text = {
					169,
					223,
					238
				}
			}
		},
		{
			id = "image_difficulty_icon",
			image_name = "difficulty_room_image_difficulty_icon_",
			class = "KImageView",
			pos = v(14, -105.8),
			anchor = v(178.05, 138.7)
		}
	}
}
