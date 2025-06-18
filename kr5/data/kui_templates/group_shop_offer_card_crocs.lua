-- chunkname: @./kr5/data/kui_templates/group_shop_offer_card_crocs.lua

return {
	class = "KView",
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 20,
			line_height_extra = "0",
			fit_size = true,
			text = "schriftrolle der raumverschiebung",
			text_key = "SHOP_ROOM_OFFER_CARD_TITLE",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_card_title",
			font_name = "fla_h",
			pos = v(-117.95, 90.95),
			scale = v(1, 1),
			size = v(238.95, 59.5),
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
						0.2,
						0,
						1
					}
				}
			}
		},
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_offer_card_",
			id = "image_shop_offer_card",
			pos = v(-0.5, -15.4),
			scale = v(1, 1),
			anchor = v(77.2, 110.65)
		},
		{
			id = "group_gems_label",
			class = "KView",
			pos = v(7.7, -81.6),
			children = {
				{
					class = "GG5Label",
					text_shadow = true,
					line_height_extra = "0",
					font_size = 22,
					text_align = "left",
					text = "2200 ",
					id = "label_shop_offer_gems_amount",
					fit_size = true,
					font_name = "fla_numbers",
					pos = v(-27.25, -17.4),
					size = v(81.5, 34.8),
					colors = {
						text = {
							222,
							247,
							255
						}
					},
					text_shadow_offset = v(-0.5, 0.866)
				},
				{
					class = "KImageView",
					image_name = "shop_room_image_shop_portrait_gems_quantity_gem_",
					id = "image_shop_offer_gems_amount_icon",
					pos = v(-42.55, -0.45),
					scale = v(0.649, 0.649),
					anchor = v(20.95, 19.15)
				}
			}
		}
	}
}
