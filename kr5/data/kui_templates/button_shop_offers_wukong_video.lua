-- chunkname: @./kr5/data/kui_templates/button_shop_offers_wukong_video.lua

return {
	default_image_name = "shop_room_button_offer_big_bg_0001",
	class = "GG5Button",
	focus_image_name = "shop_room_button_offer_big_bg_0003",
	image_offset = v(-418.4, -214.35),
	hit_rect = r(-418.4, -214.35, 832.8, 430.75),
	children = {
		{
			class = "KView",
			id = "cards_4",
			pos = v(0, 1),
			UNLESS = ctx.custom_offer,
			children = {
				{
					image_name = "shop_room_image_dlc_wukong_screenshots_video_",
					class = "KImageView",
					id = "image_dlc_wukong_screenshots",
					feature_video_container = true,
					pos = v(-2.2, -13),
					anchor = v(409.15, 152)
				}
			}
		},
		{
			class = "KImageView",
			image_name = "shop_room_image_price_shadow_video_",
			pos = v(-6.6, 197.15),
			anchor = v(427.85, 29.2)
		},
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 40,
			fit_size = true,
			line_height_extra = "1",
			text = "$4.99",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_cost",
			font_name = "fla_numbers_2",
			pos = v(-403.3, 177.45),
			scale = v(1, 1),
			size = v(804.95, 49.45),
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
					thickness = 2.0833333333333335,
					outline_color = {
						0,
						0,
						0,
						1
					}
				}
			}
		},
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 40,
			fit_size = true,
			line_height_extra = "1",
			text = "comprado",
			class = "GG5ShaderLabel",
			id = "label_shop_dlc_purchased",
			font_name = "fla_h",
			pos = v(-166.25, 177.45),
			scale = v(1, 1),
			size = v(323.4, 49.45),
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
					thickness = 2.0833333333333335,
					outline_color = {
						0,
						0,
						0,
						1
					}
				}
			}
		},
		{
			focus_image_name = "shop_room_button_buy_dlc_bg_0003",
			class = "GG5Button",
			id = "button_buy_dlc",
			default_image_name = "shop_room_button_buy_dlc_bg_0001",
			pos = v(-6.5, 188.7),
			image_offset = v(-128, -48.75),
			hit_rect = r(-128, -48.75, 260, 98),
			children = {
				{
					vertical_align = "middle-caps",
					text_align = "center",
					font_size = 37,
					line_height_extra = "0",
					fit_size = true,
					text = "comprar",
					text_key = "SHOP_DESKTOP_GET_DLC_BUTTON",
					class = "GG5ShaderLabel",
					id = "label_button_price",
					font_name = "fla_h",
					pos = v(-92.55, -25.75),
					scale = v(1, 1),
					size = v(186.5, 50.05),
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
							thickness = 2.0833333333333335,
							outline_color = {
								0.5373,
								0.2196,
								0,
								1
							}
						}
					}
				}
			}
		}
	}
}
