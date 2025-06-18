-- chunkname: @./kr5/data/kui_templates/splash_screen.lua

local BG_W = 1728
local BG_H = 768
local SF = ctx.safe_frame
local BS_SPLASH = ctx.bs.splash_screen

return {
	{
		x = ctx.sw,
		y = ctx.sh
	},
	class = "KWindow",
	children = {
		{
			hidden = false,
			template_name = "screen_splash",
			class = "KView",
			id = "screen_splash",
			pos = v(ctx.sw / 2, 384),
			size = v(ctx.sw, ctx.sh),
			base_scale = BS_SPLASH
		}
	}
}
