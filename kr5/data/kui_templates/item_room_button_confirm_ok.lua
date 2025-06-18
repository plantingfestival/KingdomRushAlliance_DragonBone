-- chunkname: @./kr5/data/kui_templates/item_room_button_confirm_ok.lua

return {
	class = "KView",
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
			pos = v(-98.2, -26.2),
			scale = v(1, 1),
			size = v(195, 40.6),
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
