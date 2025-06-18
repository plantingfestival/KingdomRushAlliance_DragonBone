-- chunkname: @./kr5/data/kui_templates/button_confirm_ok.lua

return {
	default_image_name = "item_room_button_confirm_yes_bg_0001",
	class = "GG5Button",
	focus_image_name = "item_room_button_confirm_yes_bg_0003",
	image_offset = v(-112.05, -47.7),
	hit_rect = r(-112.05, -47.7, 231, 114),
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 35,
			line_height_extra = "0",
			text_key = "BUTTON_OK",
			text = "Done",
			class = "GG5ShaderLabel",
			id = "label_button_ok",
			font_name = "fla_h",
			pos = v(-85.25, -23.6),
			scale = v(1, 1),
			size = v(168.15, 37.2),
			colors = {
				text = {
					26,
					70,
					94
				}
			},
			shaders = {
				"p_bevel"
			},
			shader_args = {
				{
					distance = 2,
					angle = 300,
					c1 = {
						0.7922,
						0.9647,
						1,
						1
					},
					c2 = {
						0,
						0,
						0,
						1
					}
				}
			}
		}
	}
}
