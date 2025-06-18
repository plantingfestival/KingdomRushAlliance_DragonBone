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
					WHEN = not ctx.is_underage and not ctx.is_main and not ctx.is_censored_cn
				},
				{
					template_name = "group_options_page_general_underage",
					class = "KView",
					id = "group_options_page_general_underage",
					pos = v(-497.25, -160.75),
					WHEN = ctx.is_underage,
					UNLESS = ctx.is_main and ctx.is_censored_cn
				},
				{
					template_name = "group_options_page_general_main_",
					class = "KView",
					id = "group_options_page_general_main",
					pos = v(-494, -229.75),
					UNLESS = ctx.is_underage or ctx.is_censored_cn,
					WHEN = ctx.is_main
				},
				{
					template_name = "group_options_page_general_main_underage",
					class = "KView",
					id = "group_options_page_general_main_underage",
					pos = v(-494, -161.8),
					WHEN = ctx.is_underage and ctx.is_main,
					UNLESS = ctx.is_censored_cn
				},
				{
					template_name = "group_options_page_general_cn_censored",
					class = "KView",
					id = "group_options_page_general",
					pos = v(-498, -160.75),
					WHEN = ctx.is_censored_cn,
					UNLESS = ctx.is_main
				},
				{
					class = "KView",
					template_name = "group_options_page_general_main_cn_censored",
					id = "group_options_page_general_main",
					pos = v(-494, -161.8),
					WHEN = ctx.is_main and ctx.is_censored_cn
				}
			}
		}
	}
}
