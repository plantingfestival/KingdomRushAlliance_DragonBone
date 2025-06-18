-- chunkname: @./kr5/data/kui_templates/group_tower_skills.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "tower_room_image_tower_skills_bar_",
			pos = v(144.6, 57.8),
			anchor = v(51.75, 6.1)
		},
		{
			id = "button_tower_skill_01",
			class = "TowerSkillItemView",
			template_name = "button_tower_skill",
			pos = v(57.05, 56.4)
		},
		{
			id = "button_tower_skill_02",
			class = "TowerSkillItemView",
			template_name = "button_tower_skill",
			pos = v(233.35, 56.4)
		}
	}
}
