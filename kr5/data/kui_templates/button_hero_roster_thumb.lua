-- chunkname: @./kr5/data/kui_templates/button_hero_roster_thumb.lua

return {
	default_image_name = "hero_room_image_roster_thumb_bg_0001",
	class = "HeroSliderItemView",
	focus_image_name = "hero_room_image_roster_thumb_bg_0003",
	image_offset = v(-57.15, -55.9),
	hit_rect = r(-57.15, -55.9, 117, 114),
	children = {
		{
			id = "image_roster_thumb",
			class = "KImageView",
			image_name = "hero_room_image_roster_thumb_",
			anchor = v(55, 54)
		},
		{
			id = "roster_flash",
			image_name = "hero_room_image_roster_flash_",
			class = "KImageView",
			scale = v(1.1036, 1.0961),
			anchor = v(50.3, 49.5)
		},
		{
			id = "image_roster_thumb_tick",
			image_name = "hero_room_image_roster_thumb_tick_",
			class = "KImageView",
			pos = v(27.4, 27.25),
			anchor = v(9, 7.95)
		},
		{
			id = "image_roster_thumb_new",
			image_name = "hero_room_image_roster_thumb_new_",
			class = "KImageView",
			pos = v(-0.15, 1.05),
			anchor = v(55.65, 55.85)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			font_size = 25,
			line_height_extra = "2",
			text_key = "HERO_ROOM_LABEL_ROSTER_THUMB_NEW",
			text = "New!",
			class = "GG5ShaderLabel",
			id = "label_roster_thumb_new",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-47.5, -56.35),
			size = v(95.8, 40.7),
			colors = {
				text = {
					247,
					212,
					65
				}
			},
			shaders = {
				"p_glow"
			},
			shader_args = {
				{
					thickness = 2,
					glow_color = {
						0.7804,
						0.3098,
						0,
						1
					}
				}
			}
		},
		{
			id = "image_roster_thumb_locked",
			image_name = "hero_room_image_roster_thumb_locked_",
			class = "KImageView",
			pos = v(-0.15, 1.05),
			anchor = v(55.65, 55.85)
		},
		{
			id = "group_sale_label_small",
			class = "KView",
			pos = v(19.2, -17.05),
			children = {
				{
					class = "KImageView",
					image_name = "hero_room_image_sale_bg_small_",
					pos = v(-1.65, 1.3),
					anchor = v(37.5, 38.55)
				},
				{
					line_height_extra = "2",
					vertical_align = "middle-caps",
					text = "50%",
					class = "GG5ShaderLabel",
					fit_size = true,
					font_name = "fla_numbers_2",
					r = -0.7963,
					font_size = 24,
					text_align = "center",
					id = "label_sale_small",
					pos = v(12.05, -24.95),
					scale = v(0.8758, 0.8758),
					size = v(52.55, 27.4),
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
							thickness = 1.6666666666666667,
							outline_color = {
								0.8588,
								0,
								0,
								1
							}
						}
					},
					anchor = v(18.25, 5.05)
				}
			}
		},
		{
			class = "KImageView",
			image_name = "hero_room_image_dlc_dwarf_badge_small_",
			id = "image_dlc_1_badge_small",
			pos = v(41.8, -33.35),
			scale = v(1, 1),
			anchor = v(43.45, 25.9)
		}
	}
}
