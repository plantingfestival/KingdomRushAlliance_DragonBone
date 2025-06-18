-- chunkname: @./kr5/data/kui_templates/item_winter_age.lua

return {
	propagate_on_down = true,
	hidden = true,
	alpha = 0,
	propagate_on_click = true,
	propagate_on_up = true,
	class = "KView",
	id = "layer_user_item_winter_age",
	pos = v(0, 0),
	size = v(ctx.sw, ctx.sh),
	colors = {
		background = {
			0,
			0,
			0,
			0
		}
	},
	children = {
		{
			class = "KImageView",
			image_name = "winter_age_ice_border_a",
			pos = v(-15, ctx.sh - 242 + 15)
		},
		{
			class = "KImageView",
			image_name = "winter_age_ice_border_a",
			pos = v(227, -15),
			r = rad(270)
		},
		{
			class = "KImageView",
			image_name = "winter_age_ice_border_a",
			pos = v(ctx.sw + 15, 227),
			r = rad(180)
		},
		{
			class = "KImageView",
			image_name = "winter_age_ice_border_a",
			pos = v(ctx.sw - 242 + 15, ctx.sh + 15),
			r = rad(90)
		},
		{
			class = "KImageView",
			image_name = "winter_age_ice_border_b",
			pos = v(ctx.sw * 0.3, ctx.sh - 86 + 15)
		},
		{
			class = "KImageView",
			image_name = "winter_age_ice_border_c",
			pos = v(ctx.sw * 0.6, ctx.sh - 72 + 15)
		},
		{
			class = "KImageView",
			image_name = "winter_age_ice_border_c",
			pos = v(ctx.sw * 0.4, 57),
			r = rad(180)
		},
		{
			class = "KImageView",
			image_name = "winter_age_ice_border_b",
			pos = v(ctx.sw * 0.7, 71),
			r = rad(180)
		}
	}
}
