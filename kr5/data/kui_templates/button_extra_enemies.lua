return {
	default_image_name = "level_select_button_fight_bg_0001",
	class = "GG5Button",
	focus_image_name = "level_select_button_fight_bg_0003",
	base_scale = v(0.75, 0.5),
	image_offset = v(-115, -33.25),
	hit_rect = r(-115, -33.25, 280, 133),
	children = {
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 24,
			line_height_extra = "2",
			fit_size = true,
			text = "Fight!",
			text_key = "TEXT_EXTRA_ENEMIES",
			class = "GG5ShaderLabel",
			id = "label_extra_enemies",
			font_name = "fla_h",
			pos = v(-100, -33.25),
			scale = v(1.3334, 2),
			size = v(200, 66.5),
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