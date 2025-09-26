-- chunkname: @./kr5/data/kui_templates/group_shop_gems_special_offer_title_wukong.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_special_offer_title_bg_wukong_",
			pos = v(2.05, -1.1),
			anchor = v(344.85, 28.55)
		},
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 34,
			line_height_extra = "0",
			fit_size = true,
			text = "WUKONGs journey CAMPAIGN!",
			text_key = "SHOP_ROOM_DLC_2_TITLE",
			class = "GG5ShaderLabel",
			id = "label_shop_special_offer_title",
			font_name = "fla_h",
			pos = v(-298.25, -25.65),
			scale = v(1, 1),
			size = v(600.85, 42.65),
			colors = {
				text = {
					255,
					240,
					41
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 2.0833333333333335,
					outline_color = {
						0.4,
						0,
						0,
						1
					}
				}
			}
		}
	}
}
