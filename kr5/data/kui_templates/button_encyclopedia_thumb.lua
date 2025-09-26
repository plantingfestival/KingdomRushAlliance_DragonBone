-- chunkname: @./kr5/data/kui_templates/button_encyclopedia_thumb.lua

return {
	default_image_name = "room_encyclopedia_image_encyclopedia_thumb_0001",
	class = "GG5Button",
	focus_image_name = "room_encyclopedia_image_encyclopedia_thumb_0003",
	image_offset = v(-55.65, -54.15),
	hit_rect = r(-55.65, -54.15, 114, 112),
	children = {
		{
			id = "image_thumb_mini_image",
			class = "KImageView",
			image_name = "room_encyclopedia_image_thumb_",
			anchor = v(51, 51)
		},
		{
			id = "image_thumb_frame",
			image_name = "room_encyclopedia_image_thumb_frame_",
			class = "KImageView",
			scale = v(1, 1),
			anchor = v(54.7, 53.45)
		},
		{
			id = "image_thumb_frame_highlight",
			class = "KImageView",
			image_name = "room_encyclopedia_image_frame_ightlight_",
			anchor = v(55.65, 54.15)
		}
	}
}
