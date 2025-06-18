-- chunkname: @./kr5/data/kui_templates/group_loading_desktop.lua

return {
	class = "KView",
	children = {
		{
			id = "loading_bg",
			class = "KImageView",
			pos = v(-0.25, 0),
			anchor = v(682.75, 384)
		},
		{
			image_name = "screen_loading_desktop_9slice_bottom_overlay_",
			class = "GG59View",
			pos = v(2.2, 319.75),
			size = v(1399.5889, 146.7),
			anchor = v(701.9813, 73.35),
			slice_rect = r(6, 36.65, 20.15, 73.4)
		},
		{
			class = "KImageView",
			image_name = "screen_loading_desktop_image_loading_bar_bg_",
			pos = v(0, 300.5),
			anchor = v(96.55, 7.3)
		},
		{
			class = "KImageView",
			image_name = "screen_loading_desktop_image_loading_bar_desktop_",
			id = "loading_bar",
			pos = v(-93.1, 294.15),
			scale = v(0.9999, 1),
			anchor = v(0, -2.05)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			class = "GG5ShaderLabel",
			font_size = 14,
			line_height_extra = "0",
			text = "Boulder explosions can damage flying enemies although they cannot target them directly.\n",
			id = "label_tip",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-339.1, 316.95),
			size = v(678.25, 49.3),
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
					thickness = 1.25,
					outline_color = {
						0,
						0,
						0,
						1
					}
				}
			}
		}
	}
}
