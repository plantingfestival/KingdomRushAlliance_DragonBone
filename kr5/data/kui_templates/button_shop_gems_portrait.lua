-- chunkname: @./kr5/data/kui_templates/button_shop_gems_portrait.lua

return {
	default_image_name = "shop_room_image_shop_room_portrait_highlight_0001",
	class = "GG5Button",
	focus_image_name = "shop_room_image_shop_room_portrait_highlight_0003",
	image_offset = v(-163.2, -289.05),
	hit_rect = r(-163.2, -289.05, 330.35, 501),
	children = {
		{
			id = "image_shop_room_portrait",
			image_name = "shop_room_image_shop_room_portrait_",
			class = "KImageView",
			pos = v(-148.8, -209.15),
			anchor = v(0, 0)
		},
		{
			id = "image_shop_room_portrait_frame",
			image_name = "shop_room_image_shop_room_portrait_frame_",
			class = "KImageView",
			pos = v(-1.8, 58.85),
			anchor = v(162.8, 287.5)
		},
		{
			vertical_align = "middle",
			text_shadow = true,
			class = "GG5Label",
			font_size = 31,
			text_align = "left",
			line_height_extra = "0",
			text = "2200 ",
			id = "label_shop_portrait_gems_quantity",
			fit_size = true,
			font_name = "fla_numbers",
			pos = v(-29.8, -197.05),
			size = v(132.4, 42.2),
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
			vertical_align = "top",
			text_align = "center",
			line_height_extra = "0",
			font_size = 32,
			fit_size = true,
			text = "$999.99 ",
			class = "GG5Label",
			id = "label_shop_portrait_gems_cost",
			font_name = "fla_numbers",
			pos = v(-110.5, 173.9),
			scale = v(1, 1),
			size = v(216.85, 55.9),
			colors = {
				text = {
					222,
					247,
					255
				}
			}
		},
		{
			id = "image_shop_portrait_gems_quantity_gem",
			image_name = "shop_room_image_shop_portrait_gems_quantity_gem_",
			class = "KImageView",
			pos = v(-49.6, -174.6),
			anchor = v(20.95, 19.15)
		},
		{
			id = "image_shop_gems_tag",
			image_name = "shop_room_image_shop_gems_tag_",
			class = "KImageView",
			pos = v(44.5, -114.8),
			anchor = v(118.9, 34)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			font_size = 22,
			line_height_extra = "0",
			text_key = "SHOP_ROOM_MOST_POPULAR_TITLE",
			text = "MOST\nPOPULAR",
			class = "GG5ShaderLabel",
			id = "label_shop_most_popular",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-36.7, -143),
			size = v(180.15, 58.2),
			colors = {
				text = {
					222,
					247,
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
						0.0275,
						0.4314,
						0.6039,
						1
					}
				}
			}
		},
		{
			vertical_align = "middle",
			text_align = "center",
			font_size = 22,
			line_height_extra = "0",
			text_key = "SHOP_ROOM_BEST_VALUE_TITLE",
			text = "BEST\nVALUE",
			class = "GG5ShaderLabel",
			id = "label_shop_best_value",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-34.65, -143),
			size = v(179.45, 58.2),
			colors = {
				text = {
					222,
					247,
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
						0.0275,
						0.4314,
						0.6039,
						1
					}
				}
			}
		},
		{
			template_name = "group_shop_title_gems",
			class = "KView",
			transition_delay = 0.15,
			id = "group_shop_title_gems",
			transition = "scale",
			pos = v(-4.05, -249.1)
		}
	}
}
