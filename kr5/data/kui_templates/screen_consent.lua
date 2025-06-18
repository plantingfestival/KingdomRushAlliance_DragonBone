-- chunkname: @./kr5/data/kui_templates/screen_consent.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			loop = true,
			exo_animation = "idle",
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
			loop = true,
			exo_animation = "idle",
			id = "bg_exo_logo",
			exo_name = "ScreenSlotsLogoDef",
			pos = v(ctx.sw / 2, ctx.sh / 2),
			pos_shown = v(ctx.sw / 2, ctx.OVT(ctx.sh / 2, "desktop", ctx.sh / 2 + 40)),
			pos_up = v(ctx.sw / 2, ctx.OVT(ctx.sh / 2, "desktop", ctx.sh / 2 - 70)),
			scale_up = v(1, 1)
		},
		{
			loop = true,
			exo_animation = "idle",
			class = "GGExo",
			ts = 0.2,
			id = "bg_exo_tentacles",
			exo_name = "ScreenSlotsTentaclesDef",
			pos = v(ctx.sw / 2, ctx.sh / 2),
			pos_shown = v(ctx.sw / 2, ctx.OVT(ctx.sh / 2, "desktop", ctx.sh / 2 + 50))
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
		}
	}
}
