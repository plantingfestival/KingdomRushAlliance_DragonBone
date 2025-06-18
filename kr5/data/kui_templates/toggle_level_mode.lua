-- chunkname: @./kr5/data/kui_templates/toggle_level_mode.lua

return {
	class = "LevelSelectModeButton",
	true_image_name = "level_select_image_mode_button_bg_0001",
	focus_image_name = "level_select_image_mode_button_bg_0003",
	false_image_name = "level_select_image_mode_button_bg_0002",
	image_offset = v(-49.15, -50.25),
	hit_rect = r(-49.15, -50.25, 102, 104),
	children = {
		{
			id = "image_mode_icon",
			image_name = "level_select_image_level_select_mode_icons_",
			class = "KImageView",
			scale = v(1, 1),
			anchor = v(40.15, 39.95)
		},
		{
			loop = false,
			class = "GGAni",
			id = "notification_dot",
			pos = v(27.8, -41.85),
			scale = v(0.84, 0.84),
			anchor = v(9.65, 6.55),
			animation = {
				to = 12,
				prefix = "level_select_animation_notification_dot",
				from = 1
			}
		}
	}
}
