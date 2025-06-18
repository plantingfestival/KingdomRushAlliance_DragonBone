-- chunkname: @./kr5/data/kui_templates/screen_slots.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			loop = false,
			exo_animation = "in",
			class = "GGExo",
			ts = 0.2,
			id = "bg_exo_main",
			exo_name = "ScreenSlotsBGDef",
			pos = v(ctx.sw / 2, ctx.sh / 2),
			pos_shown = v(ctx.sw / 2, ctx.OVT(ctx.sh / 2, "desktop", ctx.sh / 2 + 40))
		},
		{
			ts = 0.2,
			class = "GGExo",
			loop = false,
			exo_animation = "in",
			id = "bg_exo_logo",
			exo_name = "ScreenSlotsLogoDef",
			pos = v(ctx.sw / 2, ctx.sh / 2),
			pos_shown = v(ctx.sw / 2, ctx.OVT(ctx.sh / 2, "desktop", ctx.sh / 2 + 40)),
			pos_up = v(ctx.sw / 2, ctx.OVT(ctx.sh / 2, "desktop", ctx.sh / 2 - 70)),
			scale_up = v(1, 1)
		},
		{
			loop = false,
			exo_animation = "in",
			class = "GGExo",
			ts = 0.2,
			id = "bg_exo_tentacles",
			exo_name = "ScreenSlotsTentaclesDef",
			pos = v(ctx.sw / 2, ctx.sh / 2),
			pos_shown = v(ctx.sw / 2, ctx.OVT(ctx.sh / 2, "desktop", ctx.sh / 2 + 50))
		},
		{
			class = "GG59View",
			image_name = "screen_slots_9slice_black_fade_left_",
			id = "image_black_gradient_left",
			pos = v(0, 365.35),
			size = v(407.25, 912.5501),
			anchor = v(66.55, 457.4853),
			slice_rect = r(58.8, 4.7, 418.35, 9.45)
		},
		{
			class = "GG59View",
			image_name = "screen_slots_9slice_black_fade_right_",
			id = "image_black_gradient_right",
			pos = v(ctx.sw, 365.35),
			size = v(407.25, 912.5501),
			anchor = v(341.95, 457.4853),
			slice_rect = r(-117.8, 4.7, 472.75, 9.45)
		},
		{
			id = "button_start",
			focus_image_name = "screen_slots_button_start_bg_0003",
			class = "GG5Button",
			hidden = true,
			default_image_name = "screen_slots_button_start_bg_0001",
			WHEN = ctx.is_mobile,
			pos = v(ctx.sw / 2, 700.6),
			image_offset = v(-210.7, -68.85),
			hit_rect = r(-ctx.sw, -ctx.sh, ctx.sw * 2, ctx.sh * 2),
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 40,
					fit_size = true,
					line_height_extra = "2",
					text = "tap to start",
					class = "GG5ShaderLabel",
					id = "label_start",
					font_name = "fla_body",
					pos = v(-231.775, -40.65),
					scale = v(1, 1),
					size = v(463.55, 73.45),
					colors = {
						text = {
							69,
							233,
							255
						}
					},
					shaders = {
						"p_bands",
						"p_outline_tint"
					},
					shader_args = {
						{
							margin = 1,
							p1 = 0.5,
							p2 = 0.99,
							c1 = {
								0.9804,
								1,
								0.5882,
								1
							},
							c2 = {
								0.7098,
								0.9922,
								0.2667,
								1
							},
							c3 = {
								0.7098,
								0.9922,
								0.2667,
								1
							}
						},
						{
							thickness = 3.75,
							outline_color = {
								0.1059,
								0.2078,
								0.0431,
								1
							}
						}
					}
				}
			}
		},
		{
			id = "group_start_desktop",
			hidden = true,
			class = "KView",
			alpha = 0,
			template_name = "group_start_desktop",
			UNLESS = ctx.is_mobile,
			pos = v(ctx.sw / 2, 0.97 * ctx.sh)
		},
		{
			class = "KView",
			template_name = "group_slots_menu",
			id = "group_slots_list",
			pos = v(ctx.sw / 2, 336),
			pos_shown = v(ctx.sw / 2, ctx.OVT(336, "tablet", 536, "desktop", 510)),
			pos_hidden = v(ctx.sw / 2, ctx.sh)
		},
		{
			id = "group_news",
			class = "KView",
			template_name = "group_news",
			pos = v(ctx.sw - ctx.safe_frame.r, 1.15)
		},
		{
			class = "KView",
			template_name = "group_more_games",
			id = "group_more_games",
			pos = v(ctx.sw - ctx.safe_frame.r, 776.65),
			scale = v(1, 1)
		},
		{
			id = "group_privacy_policy",
			class = "KView",
			template_name = "group_privacy_policy",
			pos = v(ctx.safe_frame.l, 765.95)
		},
		{
			id = "group_options",
			class = "KView",
			template_name = "group_options",
			pos = v(ctx.safe_frame.l, 2.45)
		},
		{
			class = "KView",
			template_name = "group_8plus",
			id = "group_8plus",
			pos = v(ctx.sw - ctx.safe_frame.r, 126.65),
			WHEN = ctx.is_censored_cn
		},
		{
			class = "RestoreView",
			template_name = "group_restore",
			id = "group_restore",
			pos = v(ctx.sw / 2, 336),
			pos_shown = v(ctx.sw / 2, 336),
			pos_hidden = v(ctx.sw / 2, ctx.sh)
		},
		{
			class = "GG5PopUpNews",
			template_name = "popup_news",
			id = "popup_news",
			pos = v(ctx.sw / 2, 384),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpOptions",
			template_name = "popup_options",
			id = "popup_options",
			WHEN = ctx.is_mobile,
			pos = v(ctx.sw / 2, 384),
			size = v(ctx.sw, ctx.sh)
		},
		{
			template_name = "popup_options_desktop",
			class = "GG5PopUpOptionsDesktop",
			id = "popup_options",
			UNLESS = ctx.is_mobile,
			context = ctx.context,
			pos = v(ctx.sw / 2, ctx.sh / 2),
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
			initial_focus_id = "button_popup_no",
			class = "GG5PopUpMessage",
			template_name = "popup_message",
			id = "popup_message",
			pos = v(ctx.sw / 2, 362),
			size = v(ctx.sw, ctx.sh)
		},
		{
			id = "intro_overlay",
			propagate_on_down = true,
			class = "KView",
			hidden = false,
			propagate_on_up = true,
			propagate_on_click = true,
			size = v(ctx.sw, ctx.sh),
			colors = {
				background = {
					0,
					0,
					0,
					255
				}
			}
		},
		{
			hidden = true,
			class = "GG5PopUpBugReport",
			template_name = "popup_bugreport",
			id = "error_report_view",
			pos = v(ctx.sw / 2, 362),
			size = v(ctx.sw, ctx.sh)
		},
		{
			initial_focus_id = "button_popup_no",
			class = "GG5PopUpMessageChina",
			template_name = "popup_message_china",
			id = "popup_message_china",
			pos = v(ctx.sw / 2, 362),
			size = v(ctx.sw, ctx.sh)
		}
	}
}
