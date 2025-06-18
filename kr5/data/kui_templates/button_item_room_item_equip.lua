-- chunkname: @./kr5/data/kui_templates/button_item_room_item_equip.lua

return {
	default_image_name = "item_room_button_equip_bg _0001",
	class = "GG5Button",
	focus_image_name = "item_room_button_equip_bg _0003",
	image_offset = v(-127.6, -56),
	hit_rect = r(-127.6, -56, 257, 117),
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 37,
			line_height_extra = "2",
			fit_size = true,
			text = "EQUIP",
			text_key = "ITEM_ROOM_equip",
			class = "GG5ShaderLabel",
			id = "label_button_select",
			font_name = "fla_h",
			pos = v(-91.85, -26.75),
			scale = v(1, 1),
			size = v(186.5, 52.45),
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
