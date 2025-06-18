-- chunkname: @./kr5/data/kui_templates/button_tower_room_big_locked.lua

return {
	default_image_name = "tower_room_button_locked_bg _0001",
	class = "GG5Button",
	focus_image_name = "tower_room_button_locked_bg _0003",
	image_offset = v(-127.15, -56.95),
	hit_rect = r(-127.15, -56.95, 258, 116),
	children = {
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 26,
			line_height_extra = "2",
			fit_size = true,
			text = "unlock at level 5",
			text_key = "HERO_ROOM_locked",
			class = "GG5ShaderLabel",
			id = "label_button_locked",
			font_name = "fla_h",
			pos = v(-86.75, -34.05),
			scale = v(1, 1),
			size = v(173.25, 62.25),
			colors = {
				text = {
					47,
					14,
					9
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0.9059,
						0.4745,
						0.4196,
						1
					}
				}
			}
		}
	}
}
