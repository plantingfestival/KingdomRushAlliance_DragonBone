-- chunkname: @./kr5/data/kui_templates/button_room_big_locked.lua

return {
	default_image_name = "hero_room_button_locked_bg _0001",
	class = "GG5Button",
	focus_image_name = "hero_room_button_locked_bg _0003",
	image_offset = v(-124.05, -56.3),
	hit_rect = r(-124.05, -56.3, 258, 117),
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 28,
			line_height_extra = "2",
			text = "unlock at level 5",
			class = "GG5ShaderLabel",
			id = "label_button_locked",
			font_name = "fla_h",
			pos = v(-88.9, -37),
			scale = v(1, 1),
			size = v(189.8, 56.6),
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
