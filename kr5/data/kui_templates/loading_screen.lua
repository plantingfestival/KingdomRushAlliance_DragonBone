-- chunkname: @./kr5/data/kui_templates/loading_screen.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			loop = false,
			exo_animation = "doors_in",
			class = "GGExo",
			id = "exo",
			exo_name = "ScreenLoadingDoorsDef",
			WHEN = ctx.is_mobile,
			pos = v(ctx.sw / 2, ctx.sh / 2)
		},
		{
			class = "KView",
			template_name = "group_loading_doors_bottom",
			id = "bottom_half",
			WHEN = ctx.is_mobile,
			pos = v(ctx.sw / 2, 384)
		},
		{
			class = "KView",
			template_name = "group_loading_doors_top",
			id = "top_half",
			WHEN = ctx.is_mobile,
			pos = v(ctx.sw / 2, 384)
		},
		{
			template_name = "group_loading_desktop",
			class = "KView",
			id = "group_loading_desktop",
			UNLESS = ctx.is_mobile,
			pos = v(ctx.sw / 2, ctx.sh / 2)
		}
	}
}
