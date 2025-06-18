-- chunkname: @./kr5/data/kui_templates/button_ingame_shop_gems_portrait.lua

return {
	default_image_name = "ingame_shop_kui_image_ingame_shop_shop_room_portrait_highlight_0001",
	class = "GG5Button",
	focus_image_name = "ingame_shop_kui_image_ingame_shop_shop_room_portrait_highlight_0003",
	image_offset = v(-163.2, -289.05),
	hit_rect = r(-163.2, -289.05, 330.35, 501),
	children = {
		{
			id = "image_shop_room_portrait",
			image_name = "ingame_shop_kui_image_ingame_shop_shop_room_portrait_",
			class = "KImageView",
			pos = v(-148.8, -209.15),
			anchor = v(-1, -0.05)
		},
		{
			id = "image_gem_pack_portrait",
			class = "KImageView",
			pos = v(-1.5, 17.85),
			anchor = v(147.5, 227.5)
		},
		{
			class = "KView",
			pos = v(12.4, -4),
			children = {
				{
					_disabled = true,
					class = "GG59View",
					image_name = "ingame_shop_kui_9slice_shadow_roster_",
					id = "MovieClip1149",
					pos = v(-13.95, 27.25),
					size = v(338.7549, 478.8691),
					anchor = v(169.3774, 239.3101),
					slice_rect = r(50.6, 29.95, 23, 40.5)
				},
				{
					class = "KView"
				},
				{
					image_name = "ingame_shop_kui_image_ingame_shop_frame_side_02_",
					class = "KImageView",
					pos = v(132.2, 22),
					scale = v(1, 1.3306),
					anchor = v(9.15, 154)
				},
				{
					class = "KImageView",
					image_name = "ingame_shop_kui_image_ingame_shop_rivet_",
					pos = v(132.3, -119.5),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "ingame_shop_kui_image_ingame_shop_rivet_",
					pos = v(131.9, 158.75),
					anchor = v(8.1, 8.85)
				},
				{
					image_name = "ingame_shop_kui_image_ingame_shop_frame_side_01_",
					class = "KImageView",
					pos = v(-16, -208.15),
					scale = v(0.4133, 1),
					anchor = v(319.95, 11.2)
				},
				{
					image_name = "ingame_shop_kui_image_ingame_shop_frame_side_03_",
					class = "KImageView",
					pos = v(-160.35, 23.25),
					scale = v(1, 1.6213),
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
					pos = v(118.75, -195),
					scale = v(2.0261, 2.0261),
					anchor = v(10.1, 10.6)
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
					pos = v(-159.7, 158.75),
					anchor = v(8.1, 8.85)
				},
				{
					image_name = "ingame_shop_kui_image_ingame_shop_frame_side_04_",
					class = "KImageView",
					pos = v(-13.6, 251.15),
					scale = v(1, 1),
					anchor = v(136.25, 11.2)
				},
				{
					class = "KImageView",
					r = 0,
					id = "image_corner_04",
					image_name = "ingame_shop_kui_image_ingame_shop_corner_05_",
					pos = v(-147.4, 238.3),
					scale = v(2.0258, 2.0258),
					anchor = v(10.6, 10.1)
				},
				{
					image_name = "ingame_shop_kui_image_ingame_shop_corner_03_",
					class = "KImageView",
					pos = v(120.15, 238.6),
					scale = v(2.0259, 2.0259),
					anchor = v(10.6, 10.1)
				}
			}
		},
		{
			class = "KView"
		},
		{
			vertical_align = "top",
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
			size = v(103.25, 42.2),
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
			text_shadow = true,
			font_size = 31,
			fit_size = true,
			text_align = "center",
			text = "$999.99 ",
			line_height_extra = "0",
			class = "GG5Label",
			id = "label_shop_portrait_gems_cost",
			font_name = "fla_numbers",
			pos = v(-123.25, 177.9),
			scale = v(1.1205, 1),
			size = v(243.35, 42.2),
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
			id = "image_shop_portrait_gems_quantity_gem",
			image_name = "ingame_shop_kui_image_ingame_shop_shop_portrait_gems_quantity_gem_",
			class = "KImageView",
			pos = v(-49.6, -174.6),
			anchor = v(20.95, 19.15)
		},
		{
			id = "image_shop_gems_tag",
			image_name = "ingame_shop_kui_image_ingame_shop_shop_gems_tag_",
			class = "KImageView",
			pos = v(44.5, -114.8),
			anchor = v(118.9, 34)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			class = "GG5ShaderLabel",
			font_size = 22,
			line_height_extra = "0",
			text = "BEST\nVALUE",
			id = "label_shop_gems_tag",
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
			vertical_align = "top",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "0",
			font_size = 24,
			text = "Handful of Gems",
			id = "label_shop_title_gems",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-154.05, -266.2),
			size = v(306.2, 33.55),
			colors = {
				text = {
					222,
					247,
					255
				}
			}
		}
	}
}
