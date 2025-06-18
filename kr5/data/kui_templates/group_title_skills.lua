-- chunkname: @./kr5/data/kui_templates/group_title_skills.lua

return {
	class = "KView",
	children = {
		{
			image_name = "tower_room_9slice_info_bg_",
			class = "GG59View",
			pos = v(0, 1.9),
			size = v(462.1893, 38.8663),
			anchor = v(0, 0),
			slice_rect = r(15.2, 15, 9.75, 10.2)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			font_size = 26,
			line_height_extra = "2",
			fit_size = true,
			text = "skills",
			text_key = "TOWER_ROOM_SKILLS_TITLE",
			class = "GG5ShaderLabel",
			id = "label_title_skills",
			font_name = "fla_body",
			pos = v(15.3, -1.15),
			scale = v(1, 1),
			size = v(432.9, 43.75),
			colors = {
				text = {
					255,
					212,
					64
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 2.5,
					outline_color = {
						0.2471,
						0.2314,
						0.2,
						1
					}
				}
			}
		}
	}
}
