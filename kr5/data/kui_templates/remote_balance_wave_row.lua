-- chunkname: @./kr5/data/kui_templates/remote_balance_wave_row.lua

return {
	id = "wave_row",
	class = "KView",
	pos = v(10, 10),
	children = {
		{
			font_size = 12,
			class = "KLabel",
			id = "title",
			text_align = "left",
			font_name = "body",
			size = v(40, ctx.row_height),
			text = ctx.row_title
		},
		{
			text_align = "left",
			class = "KLabel",
			font_size = 12,
			id = "desc",
			font_name = "body",
			pos = v(40, 0),
			size = v(ctx.row_width - 40, ctx.row_height),
			text = ctx.row_title
		}
	}
}
