-- chunkname: @./kr5/data/kui_templates/gui_popups.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			class = "GG5PopUpOptions",
			template_name = "popup_options",
			id = "popup_options",
			pos = v(ctx.sw / 2, 379.35),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpLocaleList",
			template_name = "popup_locale_list",
			id = "popup_locale_list",
			pos = v(ctx.sw / 2, 362),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpMessage",
			template_name = "popup_message",
			id = "popup_message",
			pos = v(ctx.sw / 2, 363),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpIngameOptions",
			template_name = "popup_ingame_options",
			id = "popup_ingame_options",
			pos = v(ctx.sw / 2, 353.75),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpConfirm",
			template_name = "popup_confirm",
			id = "popup_confirm",
			pos = v(ctx.sw / 2, 367.85),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpError",
			template_name = "popup_error",
			id = "popup_error",
			pos = v(ctx.sw / 2, 367.85),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpBugReport",
			template_name = "popup_bugreport",
			id = "popup_bugreport",
			pos = v(ctx.sw / 2, 367.85),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpPurchasing",
			template_name = "popup_purchasing",
			id = "popup_purchasing",
			pos = v(ctx.sw / 2, 366.85),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpAcceptPrivacyPolicy",
			template_name = "popup_accept_privacy_policy",
			id = "popup_confirmage",
			pos = v(ctx.sw / 2, 369.7),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpNews",
			template_name = "popup_news",
			id = "popup_news",
			pos = v(ctx.sw / 2, 383.35),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpMessageGeneric",
			template_name = "popup_message_generic",
			id = "popup_message_generic",
			pos = v(ctx.sw / 2, 363),
			size = v(ctx.sw, ctx.sh)
		}
	}
}
