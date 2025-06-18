-- chunkname: @./kr5/data/kui_templates/button_tower_roster_thumb_desktop.lua

return {
	default_image_name = "tower_room_image_roster_thumb_desktop_bg_0001",
	class = "TowerSliderItemView",
	focus_image_name = "tower_room_image_roster_thumb_desktop_bg_0003",
	image_offset = v(-61.45, -59.9),
	hit_rect = r(-61.45, -59.9, 125, 123),
	children = {
		{
			class = "KImageView",
			id = "image_roster_thumb",
			pos = v(-0.05, -0.05),
			scale = v(1.0721, 1.0721),
			anchor = v(55, 54)
		},
		{
			class = "KImageView",
			image_name = "tower_room_image_roster_flash_",
			id = "roster_flash",
			pos = v(-0.05, -0.05),
			scale = v(1.1832, 1.1751),
			anchor = v(50.3, 49.5)
		},
		{
			class = "KImageView",
			image_name = "tower_room_image_roster_thumb_tick_",
			id = "image_roster_thumb_tick",
			pos = v(29.25, 29.1),
			scale = v(1.0721, 1.0721),
			anchor = v(9, 7.95)
		},
		{
			class = "KImageView",
			image_name = "tower_room_image_roster_thumb_new_",
			id = "image_roster_thumb_new",
			pos = v(-0.15, 1),
			scale = v(1.0721, 1.0721),
			anchor = v(55.65, 55.85)
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 24,
			line_height_extra = "2",
			fit_size = true,
			text = "New!",
			text_key = "TOWER_ROOM_LABEL_ROSTER_THUMB_NEW",
			class = "GG5ShaderLabel",
			id = "label_roster_thumb_new",
			font_name = "fla_body",
			pos = v(-50.15, -57.45),
			scale = v(1.0721, 1.0721),
			size = v(101.25, 45.15),
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
			image_name = "tower_room_image_roster_thumb_locked_",
			id = "image_roster_thumb_locked",
			pos = v(-0.15, 1),
			scale = v(1.0721, 1.0721),
			anchor = v(55.65, 55.85)
		},
		{
			class = "KImageView",
			image_name = "tower_room_image_dlc_dwarf_badge_small_",
			id = "image_dlc_1_badge_small",
			pos = v(44.65, -38.3),
			scale = v(1, 1),
			anchor = v(43.45, 25.9)
		}
	}
}
