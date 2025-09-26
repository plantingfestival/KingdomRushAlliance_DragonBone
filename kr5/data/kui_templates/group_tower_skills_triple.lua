-- chunkname: @./kr5/data/kui_templates/group_tower_skills_triple.lua

return {
	class = "KView",
	children = {
		{
			image_name = "tower_room_image_tower_skills_bar_",
			class = "KImageView",
			pos = v(144.95, 57.8),
			scale = v(2.2712, 1),
			anchor = v(51.75, 6.1)
		},
		{
			id = "button_tower_skill_01",
			class = "TowerSkillItemView",
			template_name = "button_tower_skill",
			pos = v(-2.05, 56.4)
		},
		{
			id = "button_tower_skill_02",
			class = "TowerSkillItemView",
			template_name = "button_tower_skill",
			pos = v(291.55, 56.4)
		},
		{
			id = "button_tower_skill_03",
			class = "TowerSkillItemView",
			template_name = "button_tower_skill",
			pos = v(144.8, 56.4)
		}
	}
}
