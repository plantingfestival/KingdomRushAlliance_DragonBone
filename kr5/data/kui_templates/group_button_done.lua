-- chunkname: @./kr5/data/kui_templates/group_button_done.lua

return {
	class = "KView",
	children = {
		{
			id = "button_notification_done",
			focus_image_name = "ingame_notifications_button_ok_0003",
			class = "GG5Button",
			default_image_name = "ingame_notifications_button_ok_0001",
			anchor = v(170.1, 61.75)
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 40,
			line_height_extra = "0",
			text_key = "NOTIFICATION_button_ok",
			text = "Ok",
			class = "GG5ShaderLabel",
			id = "label_button_ok",
			font_name = "fla_h",
			pos = v(-143.6, -33.5),
			scale = v(1.1537, 1.1537),
			size = v(295.45, 50.1),
			colors = {
				text = {
					250,
					253,
					255
				}
			},
			shaders = {
				"p_glow"
			},
			shader_args = {
				{
					thickness = 2,
					glow_color = {
						0.1176,
						0.2157,
						0.3059,
						1
					}
				}
			}
		}
	}
}
