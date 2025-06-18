-- chunkname: @./kr5/data/kui_templates/screen_splash.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			id = "image_logo_ih",
			class = "KImageView",
			pos = v(-0.1, -2.8),
			anchor = v(252.1, 260.55)
		}
	}
}
