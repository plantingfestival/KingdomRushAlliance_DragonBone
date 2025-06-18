-- chunkname: @./kr5/data/kui_templates/group_enemy_polaroid.lua

return {
	class = "KView",
	children = {
		{
			id = "ingame_notifications_image_enemy_polaroid",
			image_name = "ingame_notifications_image_enemy_polaroid_",
			class = "KImageView",
			pos = v(6.1, -4.85),
			anchor = v(165, 165)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_polaroid_frame_",
			pos = v(1.3, -0.45),
			anchor = v(193, 182.35)
		}
	}
}
