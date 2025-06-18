-- chunkname: @./kr5/data/kui_templates/popup_purchasing.lua

return {
	class = "GG5PopUpPurchasing",
	children = {
		{
			id = "contents",
			class = "KView",
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					text_key = "POPUP_label_purchasing",
					font_size = 40,
					line_height_extra = "0",
					text = "purchasing...",
					class = "GG5Label",
					id = "label_purchasing",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-278.4, 49.8),
					size = v(559.1, 40.15),
					colors = {
						text = {
							231,
							244,
							251
						}
					}
				},
				{
					id = "loading_arrow",
					image_name = "gui_popups_image_loading_arrow_",
					class = "KImageView",
					pos = v(-1.9, -62.05),
					anchor = v(52.25, 63.25)
				}
			}
		}
	}
}
