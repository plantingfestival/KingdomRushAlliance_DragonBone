-- chunkname: @./kr5/data/kui_templates/button_item_room_item_equipped.lua

return {
	default_image_name = "item_room_button_equipped_bg _0001",
	class = "GG5Button",
	focus_image_name = "item_room_button_equipped_bg _0003",
	image_offset = v(-127.6, -56),
	hit_rect = r(-127.6, -56, 257, 117),
	children = {
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 36,
			line_height_extra = "0",
			fit_size = true,
			text = "equipped",
			text_key = "ITEM_ROOM_selected",
			class = "GG5ShaderLabel",
			id = "label_button_selected",
			font_name = "fla_h",
			pos = v(-93.45, -27.1),
			scale = v(1, 1),
			size = v(187.75, 50.45),
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
