-- chunkname: @./kr5/data/kui_templates/group_special_polaroid.lua

return {
	class = "KView",
	children = {
		{
			image_name = "ingame_notifications_image_special_polaroid_",
			class = "KImageView",
			pos = v(5.5, -4.9),
			scale = v(0.5, 0.5),
			anchor = v(330.55, 330)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_polaroid_frame_",
			pos = v(1.3, -0.45),
			anchor = v(193, 182.35)
		}
	}
}
