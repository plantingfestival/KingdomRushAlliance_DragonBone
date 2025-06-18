-- chunkname: @./kr5/data/kui_templates/button_hero_skill.lua

return {
	default_image_name = "hero_room_image_skill_button_bg_0001",
	class = "HeroSkillItemView",
	focus_image_name = "hero_room_image_skill_button_bg_0003",
	image_offset = v(-50.4, -57.05),
	hit_rect = r(-50.4, -57.05, 100.35, 111.75),
	children = {
		{
			id = "hero_skill_icon",
			image_name = "hero_room_image_skill_icon_",
			class = "KImageView",
			pos = v(-0.45, 4.9),
			anchor = v(42, 42)
		},
		{
			id = "image_skill_level_up",
			image_name = "hero_room_image_skill_level_up_",
			class = "KImageView",
			pos = v(-38.9, -35.2),
			anchor = v(2.25, 2.2)
		},
		{
			id = "image_skill_level_up_disabled",
			image_name = "hero_room_image_skill_level_up_disabled_",
			class = "KImageView",
			pos = v(-38.9, -35.2),
			anchor = v(2.25, 2.2)
		},
		{
			id = "image_skill_border",
			image_name = "hero_room_image_skill_border_",
			class = "KImageView",
			pos = v(-38.3, -41.5),
			anchor = v(21, 13.45)
		},
		{
			id = "hero_skill_bullet_1",
			image_name = "hero_room_image_skill_bullet_off_",
			class = "KImageView",
			pos = v(-26.7, -43),
			anchor = v(11.35, 5.95)
		},
		{
			id = "hero_skill_bullet_2",
			image_name = "hero_room_image_skill_bullet_select_",
			class = "KImageView",
			pos = v(0.25, -43),
			anchor = v(11.3, 5.95)
		},
		{
			id = "hero_skill_bullet_3",
			image_name = "hero_room_image_skill_bullet_on_",
			class = "KImageView",
			pos = v(27.6, -43),
			anchor = v(11.3, 5.95)
		},
		{
			id = "hero_skill_flash",
			image_name = "hero_room_image_hero_room_skill_flash_",
			class = "KImageView",
			pos = v(-0.05, -0.05),
			anchor = v(48.65, 53.75)
		},
		{
			id = "image_skill_select",
			image_name = "hero_room_image_skill_select_",
			class = "KImageView",
			pos = v(-45.75, -52.85),
			anchor = v(10.85, 8.15)
		},
		{
			id = "image_skill_cost_bg_disabled",
			image_name = "hero_room_image_skill_cost_bg_disabled_",
			class = "KImageView",
			pos = v(-0.45, 46.8),
			anchor = v(30.85, 15.5)
		},
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "2",
			font_size = 23,
			text = "2",
			id = "label_hero_skill_cost_disabled",
			font_name = "fla_numbers",
			pos = v(-2.15, 31.5),
			size = v(24.75, 32.35),
			colors = {
				text = {
					148,
					145,
					32
				}
			}
		},
		{
			id = "image_skill_cost_bg",
			image_name = "hero_room_image_skill_cost_bg_",
			class = "KImageView",
			pos = v(-0.1, 47.75),
			anchor = v(31.2, 16.45)
		},
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "2",
			font_size = 23,
			text = "2",
			id = "label_hero_skill_cost",
			font_name = "fla_numbers",
			pos = v(-2.15, 31.5),
			size = v(24.75, 32.35),
			colors = {
				text = {
					255,
					248,
					2
				}
			}
		},
		{
			id = "image_skill_select_full",
			image_name = "hero_room_image_skill_select_full_",
			class = "KImageView",
			pos = v(-45.75, -52.85),
			anchor = v(4.8, 3.9)
		},
		{
			loop = true,
			class = "GGAni",
			id = "animation_skill_select_fx",
			pos = v(0.25, 7.25),
			scale = v(0.9227, 0.9227),
			anchor = v(47.35, 81.3),
			animation = {
				to = 18,
				prefix = "hero_room_animation_skill_select_fx",
				from = 1
			}
		}
	}
}
