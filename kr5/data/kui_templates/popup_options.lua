-- chunkname: @./kr5/data/kui_templates/popup_options.lua

return {
	class = "GG5PopUpOptions",
	children = {
		{
			id = "contents",
			class = "KView",
			children = {
				{
					class = "KView",
					template_name = "group_options_page_general",
					id = "group_options_page_general",
					pos = v(-494, -229.75),
					WHEN = not ctx.is_underage and not ctx.is_main and not ctx.is_e2w
				},
				{
					class = "KView",
					template_name = "group_options_page_general_underage",
					id = "group_options_page_general_underage",
					pos = v(-497.25, -160.75),
					WHEN = ctx.is_underage and not ctx.is_main and not ctx.is_e2w
				},
				{
					class = "KView",
					template_name = "group_options_page_general_e2w",
					id = "group_options_page_general",
					pos = v(-498, -160.75),
					WHEN = ctx.is_e2w and not ctx.is_main
				},
				{
					class = "KView",
					template_name = "group_options_page_general_main_",
					id = "group_options_page_general_main",
					pos = v(-494, -229.75),
					WHEN = ctx.is_main and not ctx.is_underage and not ctx.is_e2w
				},
				{
					class = "KView",
					template_name = "group_options_page_general_main_underage",
					id = "group_options_page_general_main_underage",
					pos = v(-494, -161.8),
					WHEN = ctx.is_underage and ctx.is_main and not ctx.is_e2w
				},
				{
					class = "KView",
					template_name = "group_options_page_general_main_e2w",
					id = "group_options_page_general_main",
					pos = v(-494, -161.8),
					WHEN = ctx.is_main and ctx.is_e2w
				}
			}
		}
	}
}
