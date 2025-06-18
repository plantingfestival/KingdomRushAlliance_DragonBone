-- chunkname: @./kr5/data/kui_templates/map_path_dot.lua

return {
	class = "KView",
	children = {
		{
			class = "GGAni",
			pos = v(0.05, 0.05),
			anchor = v(6, 3.9),
			animation = {
				to = 10,
				prefix = "map_flags_animation_path_dot",
				from = 1
			},
			sounds = {
				{
					duration = 10,
					name = "kra_sfx_ui_mapDotsAppear_op2_v2",
					f = 1
				}
			},
			animations = {
				run = {
					from = 1,
					to = 9
				},
				idle = {
					from = 10,
					to = 10
				}
			}
		}
	}
}
