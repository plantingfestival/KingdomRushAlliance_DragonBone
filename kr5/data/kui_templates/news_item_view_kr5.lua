-- chunkname: @./kr5/data/kui_templates/news_item_view_kr5.lua

local function v(x, y)
	return {
		x = x,
		y = y
	}
end

return {
	class = "KView",
	id = "news_item_border",
	size = v(1040, 530),
	colors = {
		background = {
			31,
			30,
			20,
			255
		}
	},
	children = {
		{
			class = "KView",
			id = "news_item_bg",
			size = v(1040.6707, 530),
			pos = v(2, 2),
			colors = {
				background = {
					200,
					200,
					200,
					100
				}
			},
			children = {
				{
					image_name = "gui_popups_image_loading_arrow_",
					class = "KImageView",
					id = "news_item_loading",
					pos = v(524.5, 273.5),
					anchor = v(52.5, 58)
				},
				{
					id = "news_item_image",
					class = "KImageView",
					pos = v(0, 0)
				},
				{
					text_align = "left",
					text = "TEST TITLE",
					font_size = 12,
					line_height = 0.8,
					class = "GGLabel",
					id = "news_item_text",
					font_name = "sans",
					pos = v(0, 0),
					size = v(1040, 530),
					text_size = v(380, 80),
					text_offset = v(10, 0),
					colors = {
						text = {
							231,
							214,
							182,
							255
						}
					}
				}
			}
		}
	}
}
