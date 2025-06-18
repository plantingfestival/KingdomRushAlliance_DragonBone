-- chunkname: @./kr5/data/kui_templates/button_shop_offers_dwarves.lua

return {
	default_image_name = "shop_room_button_offer_big_bg_0001",
	class = "GG5Button",
	focus_image_name = "shop_room_button_offer_big_bg_0003",
	image_offset = v(-418.4, -214.35),
	hit_rect = r(-418.4, -214.35, 832.8, 430.75),
	children = {
		{
			image_name = "shop_room_9slice_shop_offer_green_frame_dwarves_",
			class = "GG59View",
			pos = v(-2.1, 13.75),
			size = v(850.7268, 435.2586),
			anchor = v(424.709, 227.7238),
			slice_rect = r(20.45, 90.8, 23.6, 15.7)
		},
		{
			image_name = "shop_room_9slice_shop_offer_bottom_frame_dwarves_",
			class = "GG59View",
			pos = v(-1.95, 181.15),
			size = v(812.263, 65.05),
			anchor = v(406.1315, 32.5),
			slice_rect = r(7.95, 16.25, 15.9, 32.55)
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
			pos = v(-403.3, 152.5),
			scale = v(1, 1),
			size = v(804.95, 59.55),
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
						0.5137,
						0.2784,
						0,
						1
					}
				}
			}
		},
		{
			class = "KView",
			id = "cards_3",
			pos = v(-0.95, 10.45),
			UNLESS = ctx.custom_offer,
			children = {
				{
					class = "KImageView",
					image_name = "shop_room_image_dlc_dwarves_screenshots_",
					id = "image_dlc_dwarves_screenshots",
					pos = v(-1.6, -11.9),
					scale = v(1, 1),
					anchor = v(409.15, 152.95)
				}
			}
		},
		{
			focus_image_name = "shop_room_button_buy_dlc_bg_0003",
			class = "GG5Button",
			id = "button_buy_dlc",
			default_image_name = "shop_room_button_buy_dlc_bg_0001",
			pos = v(-6.5, 183.2),
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
			font_name = "fla_numbers_2",
			pos = v(-166.25, 153.7),
			scale = v(1, 1),
			size = v(323.4, 59.55),
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
