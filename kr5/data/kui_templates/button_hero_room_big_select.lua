-- chunkname: @./kr5/data/kui_templates/button_hero_room_big_select.lua

return {
	default_image_name = "hero_room_button_select_bg _0001",
	class = "GG5Button",
	focus_image_name = "hero_room_button_select_bg _0003",
	image_offset = v(-127.1, -57.2),
	hit_rect = r(-127.1, -57.2, 258, 117),
	children = {
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 37,
			line_height_extra = "2",
			fit_size = true,
			text = "EQUIP",
			text_key = "HERO_ROOM_select",
			class = "GG5ShaderLabel",
			id = "label_button_select",
			font_name = "fla_h",
			pos = v(-93.25, -30.75),
			scale = v(1, 1),
			size = v(186.5, 56),
			colors = {
				text = {
					13,
					39,
					60
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0,
						0.8275,
						0.9961,
						1
					}
				}
			}
		}
	}
}
