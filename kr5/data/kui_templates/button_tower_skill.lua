-- chunkname: @./kr5/data/kui_templates/button_tower_skill.lua

return {
	default_image_name = "tower_room_image_tower_skill_frame_0001",
	class = "TowerSkillItemView",
	focus_image_name = "tower_room_image_tower_skill_frame_0003",
	image_offset = v(-57.6, -54.1),
	hit_rect = r(-57.6, -54.1, 118, 116),
	children = {
		{
			id = "image_tower_skill_icon",
			class = "KImageView",
			image_name = "tower_room_image_tower_skill_icon_",
			anchor = v(50, 50)
		},
		{
			id = "image_tower_skill_frame",
			image_name = "tower_room_image_tower_skill_frame_front_",
			class = "KImageView",
			pos = v(0.05, 0.1),
			anchor = v(57.6, 54.1)
		},
		{
			id = "image_tower_skill_button_select",
			image_name = "tower_room_image_tower_skill_button_select_",
			class = "KImageView",
			pos = v(0.4, -0.6),
			anchor = v(51.45, 51.45)
		}
	}
}
