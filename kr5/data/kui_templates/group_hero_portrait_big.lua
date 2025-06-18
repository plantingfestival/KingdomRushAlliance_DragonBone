-- chunkname: @./kr5/data/kui_templates/group_hero_portrait_big.lua

return {
	class = "KView",
	children = {
		{
			id = "hero_room_portrait",
			class = "KImageView",
			pos = v(12.35, 33.3),
			anchor = v(0, 0)
		},
		{
			class = "KImageView",
			image_name = "hero_room_image_hero_room_portrait_flash_",
			id = "hero_room_portrait_flash",
			pos = v(12.15, 34.55),
			scale = v(14.6464, 14.6469),
			anchor = v(0, 0)
		},
		{
			id = "image_hero_portrait_frame",
			image_name = "hero_room_image_portrait_frame_",
			class = "KImageView",
			pos = v(171, 302.2),
			anchor = v(176, 288.2)
		},
		{
			class = "GG5Button",
			template_name = "button_hero_room_big_locked",
			id = "button_hero_room_big_locked",
			pos = v(170.3, 519.15),
			scale = v(1, 1)
		},
		{
			class = "GG5Button",
			template_name = "button_hero_room_big_buy",
			id = "button_hero_room_big_buy",
			pos = v(169.3, 519),
			scale = v(1, 1)
		},
		{
			class = "GG5Button",
			template_name = "button_hero_room_big_select",
			id = "button_hero_room_big_select",
			pos = v(171.1, 518.85),
			scale = v(1, 1)
		},
		{
			id = "button_hero_room_big_disabled",
			class = "GG5Button",
			template_name = "button_hero_room_big_disabled",
			pos = v(171, 518.9)
		},
		{
			id = "image_heroroom_badside",
			image_name = "hero_room_image_heroroom_badside_",
			class = "KImageView",
			pos = v(37.4, 21.65),
			anchor = v(20.3, 15.65)
		},
		{
			id = "image_heroroom_goodside",
			image_name = "hero_room_image_heroroom_goodside_",
			class = "KImageView",
			pos = v(37.4, 21.65),
			anchor = v(20.3, 15.65)
		},
		{
			class = "KView",
			id = "group_sale_label_big",
			pos = v(255.35, 103.5),
			WHEN = ctx.is_mobile,
			children = {
				{
					image_name = "hero_room_image_sale_bg_big_",
					class = "KImageView",
					pos = v(-82.85, 83.4),
					scale = v(1.3318, 1.3318),
					anchor = v(0, 125.25)
				},
				{
					vertical_align = "middle-caps",
					line_height_extra = "2",
					text = "descuento",
					class = "GG5ShaderLabel",
					text_key = "DISCOUNT",
					fit_size = true,
					font_name = "fla_h",
					r = -0.7701,
					font_size = 28,
					text_align = "center",
					id = "label_discount",
					pos = v(8.9, -48),
					scale = v(0.8926, 0.8926),
					size = v(145.7, 39.2),
					colors = {
						text = {
							244,
							227,
							52
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 2.5,
							outline_color = {
								0.8588,
								0,
								0,
								1
							}
						}
					},
					anchor = v(44.6, 5.95)
				},
				{
					line_height_extra = "0",
					vertical_align = "top",
					text = "50%",
					class = "GG5ShaderLabel",
					fit_size = true,
					font_name = "fla_numbers_2",
					r = -0.7613,
					font_size = 38,
					text_align = "center",
					id = "label_sale_big",
					pos = v(50.3, -59.75),
					scale = v(0.8671, 0.8671),
					size = v(84.9, 33.25),
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
								0.8588,
								0,
								0,
								1
							}
						}
					},
					anchor = v(37.15, 0.8)
				}
			}
		},
		{
			class = "KImageView",
			image_name = "hero_room_image_dlc_dwarf_badge_big_",
			id = "image_dlc_1_badge_big",
			pos = v(284.8, 47.9),
			scale = v(1, 1),
			anchor = v(51.75, 31.2)
		},
		{
			id = "group_dlc_tooltip",
			class = "KView",
			pos = v(383.15, 61.95),
			children = {
				{
					class = "KImageView",
					image_name = "hero_room_image_dlc_tooltip_arrow_",
					id = "image_mode_tooltip_arrow",
					pos = v(-61.85, -8.3),
					scale = v(1, 1),
					anchor = v(9.3, 10.4)
				},
				{
					class = "GG59View",
					image_name = "hero_room_9slice_offer_info_tooltip_bg_",
					id = "hero_room_skill_tooltip_bg",
					pos = v(145.2, 12),
					size = v(393.3765, 122.2021),
					anchor = v(196.6882, 61.1011),
					slice_rect = r(20, 20, 40, 40)
				},
				{
					vertical_align = "middle",
					text_align = "center",
					class = "GG5Label",
					line_height_extra = "0",
					font_size = 21,
					text = "COLOSAL DWARFARE CAMPAIGN",
					id = "label_info_tooltip_title",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-38.75, -39.4),
					size = v(369.15, 33.7),
					colors = {
						text = {
							45,
							94,
							152
						}
					}
				},
				{
					vertical_align = "middle",
					text_align = "center",
					class = "GG5Label",
					line_height_extra = "-2",
					font_size = 21,
					text = "This hero is included in the colosal dwarfare campaign",
					id = "label_info_tooltip_desc",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-38.75, -2.3),
					size = v(369.15, 66.05),
					colors = {
						text = {
							48,
							46,
							38
						}
					}
				}
			}
		}
	}
}
