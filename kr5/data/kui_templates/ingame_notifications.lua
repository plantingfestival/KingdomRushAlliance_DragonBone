-- chunkname: @./kr5/data/kui_templates/ingame_notifications.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			id = "popup_notification_specials",
			class = "KView",
			template_name = "group_popup_notification_specials",
			pos = v(ctx.sw / 2, 372.6)
		},
		{
			id = "popup_notification_enemy",
			class = "KView",
			template_name = "group_popup_notification_enemy",
			pos = v(ctx.sw / 2, 372.6)
		},
		{
			id = "popup_notification_hero",
			class = "KView",
			template_name = "group_popup_notification_hero",
			pos = v(ctx.sw / 2, 372.6)
		},
		{
			id = "popup_notification_rally_point",
			class = "KView",
			template_name = "group_popup_notification_rally_point",
			pos = v(ctx.sw / 2, 372.6)
		},
		{
			id = "popup_notification_armored_enemies",
			class = "KView",
			template_name = "group_popup_notification_armored_enemies",
			pos = v(ctx.sw / 2, 372.6)
		},
		{
			id = "popup_notification_magic_resistant_enemies",
			class = "KView",
			template_name = "group_popup_notification_magic_resistant_enemies",
			pos = v(ctx.sw / 2, 371.5)
		}
	}
}
