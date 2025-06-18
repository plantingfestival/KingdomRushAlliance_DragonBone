-- chunkname: @./kr5/data/kui_templates/group_victorytextchallenges.lua

return {
	class = "KView",
	children = {
		{
			id = "group_victorytext1",
			class = "KView",
			template_name = "group_victorytext1",
			pos = v(-7.55, -0.45)
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "TXT_VICTORY_GEMS",
			font_size = 32,
			line_height_extra = "2",
			text = "999",
			class = "GG5Label",
			id = "label_gems_amount",
			font_name = "fla_numbers",
			pos = v(-15, 77.7),
			size = v(113.05, 48.95),
			colors = {
				text = {
					255,
					255,
					255
				}
			}
		}
	}
}
