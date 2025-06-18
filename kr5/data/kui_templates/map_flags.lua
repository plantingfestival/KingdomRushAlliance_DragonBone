-- chunkname: @./kr5/data/kui_templates/map_flags.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			class = "KView",
			template_name = "group_map_paths",
			pos = v(310.9, 937.05)
		},
		{
			class = "KView",
			template_name = "group_map_flags",
			pos = v(272.55, 864.85)
		}
	}
}
