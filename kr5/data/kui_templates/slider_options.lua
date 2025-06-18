-- chunkname: @./kr5/data/kui_templates/slider_options.lua

return {
	class = "GG5Slider",
	children = {
		{
			class = "GG59View",
			image_name = "gui_popups_desktop_9slice_options_slider_bg_",
			id = "background",
			pos = v(-18.65, -0.3),
			size = v(805.3633, 51.6),
			anchor = v(395.2204, 26.2),
			slice_rect = r(31.35, 12.35, 24.8, 26.05)
		},
		{
			id = "bar",
			image_name = "gui_popups_desktop_image_slider_bar_",
			class = "KImageView",
			pos = v(-396.35, 0.3),
			anchor = v(-0.2, 4.7)
		},
		{
			id = "knob",
			class = "KView",
			pos = v(-218.6, 0),
			children = {
				{
					id = "image",
					class = "KImageView",
					image_name = "gui_popups_desktop_image_slider_knob_",
					anchor = v(75, 74.8)
				},
				{
					id = "glow",
					image_name = "gui_popups_desktop_image_slider_knob_glow_",
					class = "KImageView",
					pos = v(-0.15, 0.35),
					anchor = v(49, 48.8)
				}
			}
		}
	}
}
