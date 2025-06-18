-- chunkname: @./kr5/data/kui_templates/group_shop_gems_dlc_title_dwarves.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_dlc_title_bg_dwarves_",
			pos = v(2.05, 1.7),
			anchor = v(498.85, 110.75)
		},
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 32,
			line_height_extra = "0",
			fit_size = true,
			text = "COLOSSAL DWARFARE CAMPAIGN!",
			text_key = "SHOP_ROOM_DLC_1_DESCRIPTION",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_desc",
			font_name = "fla_h",
			pos = v(-298.25, -25.65),
			scale = v(1, 1),
			size = v(600.85, 51.2),
			colors = {
				text = {
					255,
					244,
					235
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 2.0833333333333335,
					outline_color = {
						0,
						0.0471,
						0.4,
						1
					}
				}
			}
		}
	}
}
