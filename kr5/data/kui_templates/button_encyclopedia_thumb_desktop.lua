-- chunkname: @./kr5/data/kui_templates/button_encyclopedia_thumb_desktop.lua

return {
	default_image_name = "room_encyclopedia_image_encyclopedia_thumb_0001",
	class = "GG5Button",
	focus_image_name = "room_encyclopedia_image_encyclopedia_thumb_0003",
	image_offset = v(-55.8, -54.25),
	hit_rect = r(-55.8, -54.25, 111.6, 108.5),
	children = {
		{
			class = "KImageView",
			image_name = "room_encyclopedia_image_thumb_",
			id = "image_thumb_mini_image",
			pos = v(0, -0.35),
			scale = v(1, 1),
			anchor = v(50.95, 50.95)
		},
		{
			id = "image_thumb_frame",
			image_name = "room_encyclopedia_image_thumb_frame_",
			class = "KImageView",
			scale = v(1, 1),
			anchor = v(55.8, 54.5)
		},
		{
			id = "image_thumb_frame_highlight",
			class = "KImageView",
			image_name = "room_encyclopedia_image_frame_ightlight_",
			anchor = v(55.8, 54.25)
		}
	}
}
