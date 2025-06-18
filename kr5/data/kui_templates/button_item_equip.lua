-- chunkname: @./kr5/data/kui_templates/button_item_equip.lua

return {
	default_image_name = "item_room_button_equip_bg _0001",
	class = "GG5Button",
	focus_image_name = "item_room_button_equip_bg _0003",
	image_offset = v(-123.15, -56.3),
	hit_rect = r(-123.15, -56.3, 258.05, 117),
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 37,
			line_height_extra = "2",
			text_key = "ITEM_ROOM_equip",
			text = "EQUIP",
			class = "GG5ShaderLabel",
			id = "label_button_select",
			font_name = "fla_h",
			pos = v(-90.85, -26.9),
			scale = v(1, 1),
			size = v(186.5, 37.45),
			colors = {
				text = {
					26,
					51,
					83
				}
			},
			shaders = {
				"p_outline"
			},
			shader_args = {
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0.4353,
						0.8431,
						1,
						1
					}
				}
			}
		}
	}
}
