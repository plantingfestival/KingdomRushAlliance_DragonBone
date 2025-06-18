-- chunkname: @./kr5/data/kui_templates/button_hero_room_big_disabled.lua

return {
	default_image_name = "hero_room_button_selected_bg _0001",
	class = "GG5Button",
	focus_image_name = "hero_room_button_selected_bg _0003",
	image_offset = v(-127.15, -56.95),
	hit_rect = r(-127.15, -56.95, 258, 116),
	children = {
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 36,
			line_height_extra = "2",
			fit_size = true,
			text = "equipped",
			text_key = "HERO_ROOM_selected",
			class = "GG5ShaderLabel",
			id = "label_button_selected",
			font_name = "fla_h",
			pos = v(-95.95, -29.5),
			scale = v(1, 1),
			size = v(190.95, 54.5),
			colors = {
				text = {
					32,
					42,
					49
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0.5373,
						0.6549,
						0.698,
						1
					}
				}
			}
		}
	}
}
