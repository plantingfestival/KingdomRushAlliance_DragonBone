-- chunkname: @./kr5/data/kui_templates/group_shop_gems_offer_title.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_offer_title_bg_",
			pos = v(2.05, -1.1),
			anchor = v(344.7, 28.7)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			font_size = 34,
			line_height_extra = "1",
			text_key = "SHOP_ROOM_OFFER_TITLE",
			text = "STARTER PACK!",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_title",
			font_name = "fla_h",
			pos = v(-298.75, -20.95),
			scale = v(1, 1),
			size = v(600.85, 34.7),
			colors = {
				text = {
					242,
					235,
					255
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 1.6666666666666667,
					outline_color = {
						0.1569,
						0.3529,
						0.5216,
						1
					}
				}
			}
		}
	}
}
