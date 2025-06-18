-- chunkname: @./kr5/data/kui_templates/group_news.lua

return {
	class = "KView",
	children = {
		{
			id = "button_news",
			focus_image_name = "screen_slots_button_news_0003",
			class = "GG5Button",
			default_image_name = "screen_slots_button_news_0001",
			pos = v(-97.65, 105.75),
			anchor = v(134.4, 138.95)
		},
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 30,
			line_height_extra = "0",
			fit_size = true,
			text = "NEWS",
			text_key = "NEWS",
			class = "GG5ShaderLabel",
			id = "label_news",
			font_name = "fla_h",
			pos = v(-209.6, 136.7),
			scale = v(1, 1),
			size = v(193.4, 45),
			colors = {
				text = {
					54,
					219,
					255
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0.098,
						0.2039,
						0.2235,
						1
					}
				}
			}
		}
	}
}
