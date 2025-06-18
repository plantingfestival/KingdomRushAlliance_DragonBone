-- chunkname: @./kr5/data/kui_templates/group_ingame_shop_item_portrait.lua

return {
	class = "KView",
	children = {
		{
			id = "image_icon_bg_greyscale",
			image_name = "ingame_shop_kui_image_ingame_shop_icon_bg_greyscale_",
			class = "KImageView",
			pos = v(-1.65, 378.45),
			anchor = v(156, 196)
		},
		{
			id = "image_item_icon",
			class = "KImageView",
			pos = v(-1.75, 384.1),
			anchor = v(156, 196)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			class = "GG5ShaderLabel",
			font_size = 30,
			line_height_extra = "-4",
			text = "SCROLL OF SPACESHIFT",
			id = "label_item_title",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-177.75, 78.15),
			size = v(355.8, 87),
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
					thickness = 3.3333333333333335,
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
			image_name = "ingame_shop_kui_9slice_info_bg_",
			class = "GG59View",
			pos = v(75.35, 186.45),
			size = v(77.5946, 43.9116),
			anchor = v(0, 0),
			slice_rect = r(15.2, 15, 9.75, 10.2)
		},
		{
			image_name = "ingame_shop_kui_9slice_shadow_roster_",
			class = "GG59View",
			pos = v(1.2, 383.8),
			size = v(361.415, 414.5471),
			anchor = v(180.7075, 207.1658),
			slice_rect = r(50.6, 29.95, 23, 40.5)
		},
		{
			image_name = "ingame_shop_kui_9slice_shadow_roster_",
			class = "GG59View",
			pos = v(0.6, 603.6),
			size = v(267.0336, 89.8707),
			anchor = v(133.5168, 44.912),
			slice_rect = r(50.6, 29.95, 23, 40.5)
		},
		{
			image_name = "ingame_shop_kui_image_ingame_shop_shadow_diagonal_",
			class = "KImageView",
			r = 0.7465,
			pos = v(128.2, 594.6),
			scale = v(2.1674, 0.9346),
			anchor = v(12.9, 3.35)
		},
		{
			image_name = "ingame_shop_kui_image_ingame_shop_shadow_diagonal_",
			class = "KImageView",
			pos = v(-129.4, 594.55),
			scale = v(2.1674, 0.9347),
			anchor = v(12.9, 3.35)
		},
		{
			class = "KView",
			pos = v(0.65, 199.95),
			children = {
				{
					class = "KView"
				}
			}
		},
		{
			class = "KView",
			pos = v(148.75, 401.15),
			children = {
				{
					class = "KView"
				}
			}
		},
		{
			class = "KView",
			pos = v(-143.95, 401.15),
			children = {
				{
					class = "KView"
				}
			}
		},
		{
			class = "KView",
			pos = v(4.4, 570.1),
			children = {
				{
					class = "KView"
				}
			}
		},
		{
			class = "KImageView",
			image_name = "ingame_shop_kui_image_ingame_shop_item_portrait_flash_",
			id = "item_room_portrait_flash",
			pos = v(-157.4, 188.2),
			scale = v(315.8208, 382.3092),
			anchor = v(0, 0)
		},
		{
			class = "KView",
			pos = v(-0.2, 392.35),
			children = {
				{
					class = "KImageView",
					image_name = "ingame_shop_kui_image_button_union_01_",
					pos = v(122.85, 199.6),
					anchor = v(21.4, 17.5)
				},
				{
					class = "KImageView",
					image_name = "ingame_shop_kui_image_button_union_02_",
					pos = v(-120.8, 199.6),
					anchor = v(21.4, 17.5)
				},
				{
					image_name = "ingame_shop_kui_image_ingame_shop_frame_side_02_",
					class = "KImageView",
					pos = v(158.35, -14.4),
					scale = v(1, 1.0933),
					anchor = v(9.15, 154)
				},
				{
					class = "KImageView",
					image_name = "ingame_shop_kui_image_ingame_shop_rivet_",
					pos = v(158.45, -119.5),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "ingame_shop_kui_image_ingame_shop_rivet_",
					pos = v(158.05, 84.45),
					anchor = v(8.1, 8.85)
				},
				{
					image_name = "ingame_shop_kui_image_ingame_shop_frame_side_01_",
					class = "KImageView",
					pos = v(2.6, -207.5),
					scale = v(0.4517, 1),
					anchor = v(319.95, 11.2)
				},
				{
					image_name = "ingame_shop_kui_image_ingame_shop_frame_side_03_",
					class = "KImageView",
					pos = v(-158.6, -15.6),
					scale = v(1, 1.3322),
					anchor = v(9.05, 126.5)
				},
				{
					image_name = "ingame_shop_kui_image_ingame_shop_corner_01_",
					class = "KImageView",
					r = -1.5708,
					pos = v(-125.4, -175.35),
					scale = v(2.0261, 2.0261),
					anchor = v(19.9, 0.2)
				},
				{
					image_name = "ingame_shop_kui_image_ingame_shop_corner_02_",
					class = "KImageView",
					r = -1.5708,
					pos = v(146.8, -195),
					scale = v(2.0261, 2.0261),
					anchor = v(10.1, 10.6)
				},
				{
					image_name = "ingame_shop_kui_image_frame_side_04_",
					class = "KImageView",
					pos = v(3.95, 163.4),
					scale = v(2.0823, 2.0823),
					anchor = v(82.1, 13.7)
				},
				{
					class = "KImageView",
					image_name = "ingame_shop_kui_image_ingame_shop_rivet_",
					pos = v(-160.25, -119.5),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "ingame_shop_kui_image_ingame_shop_rivet_",
					pos = v(-159.7, 84.45),
					anchor = v(8.1, 8.85)
				}
			}
		},
		{
			class = "GG5Button",
			template_name = "button_ingame_shop_item_price",
			id = "button_ingame_shop_item_price",
			pos = v(-1.95, 592.45),
			scale = v(1, 1)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			line_height_extra = "2",
			font_size = 26,
			fit_size = true,
			text = "8",
			class = "GG5Label",
			id = "label_amount",
			font_name = "fla_numbers",
			pos = v(77.8, 191.95),
			scale = v(1, 1),
			size = v(70.65, 36),
			colors = {
				text = {
					222,
					247,
					255
				}
			}
		},
		{
			loop = true,
			id = "animation_item_buy_fx",
			class = "GGAni",
			pos = v(114.85, 211.25),
			anchor = v(178.4, 178.4),
			animation = {
				to = 12,
				prefix = "ingame_shop_kui_animation_item_buy_fx",
				from = 1
			}
		}
	}
}
