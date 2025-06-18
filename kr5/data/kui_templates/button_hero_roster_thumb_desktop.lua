-- chunkname: @./kr5/data/kui_templates/button_hero_roster_thumb_desktop.lua

return {
	default_image_name = "hero_room_image_roster_thumb_desktop_bg_0001",
	class = "HeroSliderItemView",
	focus_image_name = "hero_room_image_roster_thumb_desktop_bg_0003",
	image_offset = v(-70.45, -68.8),
	hit_rect = r(-70.45, -68.8, 143, 140),
	children = {
		{
			id = "image_roster_thumb",
			image_name = "hero_room_image_roster_thumb_",
			class = "KImageView",
			scale = v(1.2363, 1.2361),
			anchor = v(55, 54)
		},
		{
			id = "roster_flash",
			image_name = "hero_room_image_roster_flash_",
			class = "KImageView",
			scale = v(1.3522, 1.3425),
			anchor = v(50.3, 49.5)
		},
		{
			class = "KImageView",
			image_name = "hero_room_image_roster_thumb_tick_",
			id = "image_roster_thumb_tick",
			pos = v(38.2, 37.75),
			scale = v(1.2361, 1.2348),
			anchor = v(9, 7.95)
		},
		{
			class = "KImageView",
			image_name = "hero_room_image_roster_thumb_new_",
			id = "image_roster_thumb_new",
			pos = v(-0.1, 1),
			scale = v(1.2219, 1.2218),
			anchor = v(55.65, 55.85)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			font_size = 24,
			line_height_extra = "2",
			text_key = "HERO_ROOM_LABEL_ROSTER_THUMB_NEW",
			text = "New!",
			class = "GG5ShaderLabel",
			id = "label_roster_thumb_new",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-55.8, -66.4),
			size = v(112.15, 39.75),
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
			class = "KImageView",
			image_name = "hero_room_image_roster_thumb_locked_",
			id = "image_roster_thumb_locked",
			pos = v(-0.1, 1),
			scale = v(1.2219, 1.2219),
			anchor = v(55.65, 55.85)
		},
		{
			class = "KImageView",
			image_name = "hero_room_image_dlc_dwarf_badge_small_",
			id = "image_dlc_1_badge_small",
			pos = v(53.7, -46.3),
			scale = v(1.0537, 1.0537),
			anchor = v(43.45, 25.9)
		}
	}
}
