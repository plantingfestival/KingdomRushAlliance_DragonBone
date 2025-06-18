-- chunkname: @./kr5/data/kui_templates/popup_acceptpp_agemonth.lua

return {
	class = "GG5PopupAcceptPPAgemonth",
	children = {
		{
			image_name = "gui_popups_image_ui_age_bg_month_",
			class = "KImageView",
			pos = v(-65.65, -44.7),
			scale = v(1.7661, 1.7661),
			anchor = v(1.6, -4.4)
		},
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5ShaderLabel",
			font_size = 39,
			line_height_extra = "0",
			text = "MM",
			id = "label_agemonth",
			fit_size = true,
			font_name = "fla_numbers_2",
			pos = v(-47.9, -19.3),
			size = v(74.35, 39.2),
			colors = {
				text = {
					231,
					244,
					251
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 2.5,
					outline_color = {
						0.1255,
						0.2039,
						0.2471,
						1
					}
				}
			}
		}
	}
}
