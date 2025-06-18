-- chunkname: @./kr5/data/kui_templates/button_options_wide.lua

return {
	default_image_name = "gui_popups_desktop_button_wide_bg_0001",
	class = "GG5Button",
	focus_image_name = "gui_popups_desktop_button_wide_bg_0003",
	image_offset = v(-148.6, -48.85),
	hit_rect = r(-148.6, -48.85, 299, 102),
	children = {
		{
			vertical_align = "middle-caps",
			text_align = "center",
			class = "GG5ShaderLabel",
			font_size = 35,
			line_height_extra = "0",
			text = "BUTTON",
			id = "label_button_room_small",
			fit_size = true,
			font_name = "fla_h",
			pos = v(-124.75, -25.8),
			size = v(248.1, 48.55),
			colors = {
				text = {
					13,
					39,
					60
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0,
						0.8275,
						0.9961,
						1
					}
				}
			}
		}
	}
}
