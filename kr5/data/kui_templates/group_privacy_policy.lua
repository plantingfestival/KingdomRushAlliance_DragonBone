-- chunkname: @./kr5/data/kui_templates/group_privacy_policy.lua

return {
	class = "KView",
	children = {
		{
			id = "button_privacy_policy",
			focus_image_name = "screen_slots_button_privacy_0003",
			class = "GG5Button",
			default_image_name = "screen_slots_button_privacy_0001",
			pos = v(115.1, -109.65),
			anchor = v(75, 66.75)
		},
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 30,
			line_height_extra = "0",
			fit_size = true,
			text = "privacy Policy",
			text_key = "PRIVACY_POLICY_LINK",
			class = "GG5ShaderLabel",
			id = "label_privacy_policy",
			font_name = "fla_h",
			pos = v(0, -74.35),
			scale = v(1, 1),
			size = v(241.15, 50.65),
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
