-- chunkname: @./kr5/data/kui_templates/item_veznan_wrath.lua

return {
	class = "KView",
	children = {
		{
			propagate_on_down = true,
			hidden = true,
			alpha = 0.39215686274509803,
			propagate_on_click = true,
			propagate_on_up = true,
			class = "GG5AlphaTweenView",
			id = "layer_user_item_veznan_wrath_overlay_dark",
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
					image_name = "item_veznan_wrath_overlay",
					pos = v(0, 0),
					scale = v(ctx.sw * 2, ctx.sh * 2)
				}
			}
		},
		{
			propagate_on_down = true,
			hidden = true,
			alpha = 0.39215686274509803,
			propagate_on_click = true,
			propagate_on_up = true,
			class = "KView",
			id = "layer_user_item_veznan_wrath_overlay_green",
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
					image_name = "item_veznan_wrath_overlay_green",
					pos = v(0, 0),
					scale = v(ctx.sw * 2, ctx.sh * 2)
				}
			}
		},
		{
			propagate_on_down = true,
			hidden = false,
			alpha = 1,
			propagate_on_click = true,
			propagate_on_up = true,
			class = "KView",
			id = "layer_user_item_veznan_wrath_veznan",
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
					exo_animation = "anim",
					hidden = true,
					class = "GGExo",
					id = "item_veznan_wrath_exo",
					exo_name = "veznan_wrath_exoskeleton",
					pos = v(ctx.sw * 0.58, ctx.sh),
					scale = v(1.5, 1.5)
				}
			}
		}
	}
}
