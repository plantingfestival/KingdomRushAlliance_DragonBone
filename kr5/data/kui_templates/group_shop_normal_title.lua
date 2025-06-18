-- chunkname: @./kr5/data/kui_templates/group_shop_normal_title.lua

return {
	class = "KView",
	children = {
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 28,
			line_height_extra = "0",
			fit_size = true,
			text = "crush your enemies from the start with these must have awesome content!",
			text_key = "SHOP_ROOM_OFFER_DESC",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_desc",
			font_name = "fla_h",
			pos = v(-312.3, -33.15),
			scale = v(1, 1),
			size = v(624.55, 81.8),
			colors = {
				text = {
					255,
					255,
					255
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 2.5,
					outline_color = {
						0.5137,
						0.2784,
						0,
						1
					}
				}
			}
		}
	}
}
