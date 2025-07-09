local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local E = require("entity_db")
local i18n = require("i18n")
local log = require("klua.log"):new("test_case")

require("constants")

local anchor_y = 0
local image_y = 0
local tt, b
local scripts = require("game_scripts")
local kr1_scripts = require("kr1_game_scripts")
local kr2_scripts = require("kr2_game_scripts")
local kr3_scripts = require("kr3_game_scripts")
local customScripts1 = require("custom_scripts_1")

require("templates")

local H = require("helpers")
local balance = require("balance/balance")
local IS_PHONE = KR_TARGET == "phone"
local IS_PHONE_OR_TABLET = KR_TARGET == "phone" or KR_TARGET == "tablet"
local IS_CONSOLE = KR_TARGET == "console"

local function v(v1, v2)
    return {
        x = v1,
        y = v2
    }
end

local function vv(v1)
    return {
        x = v1,
        y = v1
    }
end

local function r(x, y, w, h)
    return {
        pos = v(x, y),
        size = v(w, h)
    }
end

local function fts(v)
    return v / FPS
end

local function ady(v)
    return v - anchor_y * image_y
end

local function adx(v)
    return v - anchor_x * image_x
end

local function np(pi, spi, ni)
    return {
        dir = 1,
        pi = pi,
        spi = spi,
        ni = ni
    }
end

local function d2r(d)
    return d * math.pi / 180
end

local function RT(name, ref)
    return E:register_t(name, ref)
end

local function AC(tpl, ...)
    return E:add_comps(tpl, ...)
end

local function CC(comp_name)
    return E:clone_c(comp_name)
end

DO_ENEMY_BIG = 2
DO_SOLDIER_BIG = 3
DO_HEROES = 3
DO_MOD_FX = 4
DO_TOWER_MODS = 10

-- heroes
tt = RT("ps_missile_wilbur")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_wilburg_missile_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {
	1.6,
	1.8
}
tt.particle_system.alphas = {
	255,
	0
}
tt.particle_system.scales_x = {
	1,
	3
}
tt.particle_system.scales_y = {
	1,
	3
}
tt.particle_system.scale_var = {
	0.4,
	0.95
}
tt.particle_system.scale_same_aspect = false
tt.particle_system.emit_spread = math.pi
tt.particle_system.emission_rate = 30

tt = RT("fx_fireball_veznan_demon_hit_air", "fx")
tt.render.sprites[1].name = "fx_fireball_veznan_demon_hit_air"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = RT("fx_fireball_veznan_demon_hit", "fx")
tt.render.sprites[1].name = "fx_fireball_veznan_demon_hit"
tt.render.sprites[1].anchor.y = 0.25925925925925924

tt = RT("fx_box_wilbur_smoke_a", "fx")
tt.render.sprites[1].name = "fx_box_wilbur_smoke_a"
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_box_wilbur_smoke_b", "fx")
tt.render.sprites[1].name = "fx_box_wilbur_smoke_b"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = RT("fx_missile_wilbur_hit", "fx_fireball_veznan_demon_hit")
tt.render.sprites[1].scale = vv(1.4)
tt = RT("fx_missile_wilbur_hit_air", "fx_fireball_veznan_demon_hit_air")
tt.render.sprites[1].scale = vv(1.4)
tt = RT("fx_shot_wilbur_flash", "fx")
tt.render.sprites[1].name = "fx_shot_wilbur_flash"
tt = RT("fx_shot_wilbur_hit", "fx")
tt.render.sprites[1].name = "fx_shot_wilbur_hit"
tt.render.sprites[1].anchor.y = 0.19230769230769232
-- tt.render.sprites[1].z = Z_OBJECTS

tt = RT("drone_wilbur", "decal_scripted")

AC(tt, "force_motion", "custom_attack", "sound_events", "tween")

tt.main_script.update = kr3_scripts.drone_wilbur.update
tt.flight_height = 70
tt.force_motion.max_a = 1200
tt.force_motion.max_v = 360
tt.force_motion.ramp_radius = 30
tt.force_motion.fr = 0.05
tt.force_motion.a_step = 20
tt.duration = 14
tt.start_ts = nil
tt.render.sprites[1].prefix = "wilbur_drone"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.custom_attack.hit_time = fts(2)
tt.custom_attack.hit_cycles = 3
tt.custom_attack.hit_delay = fts(2)
tt.custom_attack.range_sets = {
	{
		0,
		100
	},
	{
		100,
		1e+99
	}
}
tt.custom_attack.max_shots = 16
tt.custom_attack.search_cooldown = 0.1
tt.custom_attack.cooldown = 0.25
tt.custom_attack.animation = "shoot"
tt.custom_attack.sound = "ElvesHeroGyroDronesAttack"
tt.custom_attack.sound_chance = 0.5
tt.custom_attack.damage_min = nil
tt.custom_attack.damage_max = nil
tt.custom_attack.damage_type = DAMAGE_TRUE
tt.custom_attack.vis_flags = F_RANGED
tt.custom_attack.vis_bans = 0
tt.custom_attack.shoot_range = 25
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {
	{
		0,
		v(0, tt.flight_height + 2)
	},
	{
		0.4,
		v(0, tt.flight_height - 2)
	},
	{
		0.8,
		v(0, tt.flight_height + 2)
	}
}
tt.tween.props[1].interp = "sine"

tt = RT("fx_rabbit_kamihare_explode", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_rabbit_kamihare_explode"
tt.render.sprites[1].anchor.y = 0.13793103448275862
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_events.insert = "BombExplosionSound"

tt = RT("rabbit_kamihare", "decal_scripted")

AC(tt, "nav_path", "motion", "custom_attack")

tt.render.sprites[1].prefix = "rabbit"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].anchor.y = 0.20512820512820512
tt.main_script.update = kr3_scripts.rabbit_kamihare.update
tt.nav_path.dir = -1
tt.motion.max_speed = 1.25 * FPS
tt.duration = 100
tt.custom_attack.max_range = 25
tt.custom_attack.vis_flags = bor(F_RANGED)
tt.custom_attack.vis_bans = bor(F_FLYING)
tt.custom_attack.aura = "aura_rabbit_kamihare"
tt.custom_attack.hit_fx = "fx_rabbit_kamihare_explode"

tt = RT("bomb_wilbur", "rabbit_kamihare")

AC(tt, "sound_events")

tt.render.sprites[1].prefix = "bomb_wilbur"
tt.render.sprites[1].anchor.y = 0.11666666666666667
tt.render.sprites[1].random_ts = 0.5
tt.main_script.update = kr3_scripts.rabbit_kamihare.update
tt.motion.max_speed = 2 * FPS
tt.duration = 100
tt.custom_attack.max_range = 30
tt.custom_attack.vis_flags = bor(F_RANGED)
tt.custom_attack.vis_bans = bor(F_FLYING)
tt.custom_attack.aura = "aura_bomb_wilbur"
tt.custom_attack.hit_fx = nil
tt.sound_events.insert = "ElvesHeroGyroBombsMarch"
tt.sound_events.remove_stop = "ElvesHeroGyroBombsMarch"

tt = E:register_t("soldier_chomp_bot", "soldier")

E:add_comps(tt, "melee", "reinforcement", "tween")

anchor_y = 0.21
tt.health.armor = 0.2
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 30)
tt.info.i18n_key = "SOLDIER_CHOMP_BOT"
tt.info.portrait = "bottom_info_image_soldiers_0007"
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.reinforcement.duration = nil
tt.main_script.insert = kr3_scripts.soldier_chomp_bot.insert
tt.main_script.update = kr3_scripts.soldier_chomp_bot.update
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(4)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.range = 50
tt.motion.max_speed = 39
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "chompbot"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "chompbot_shadow"
tt.render.sprites[2].anchor.y = anchor_y
tt.render.sprites[2].offset = v(0, -1)
tt.soldier.melee_slot_offset.x = 7
tt.sound_events.raise = "DwarvesSmokebeardRepair"
tt.sound_events.death = "DwarvesMechadwarfDeath"
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(0, 17)
tt.unit.explode_fx = nil
tt.vis.bans = bor(F_POISON, F_SKELETON, F_LYCAN, F_CANNIBALIZE)
tt.spawn_bullet = "smokebeard_engineer_ray"
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		255
	}
}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].disabled = nil
tt.tween.props[1].sprite_id = {
	1,
	2
}
tt.tween.remove = false
tt.tween.reverse = false
tt.tween.disabled = true

tt = E:register_t("aura_chomp_bot_transformation", "aura")
tt.aura.mod = "mod_chomp_bot_transformation"
tt.aura.cycle_time = fts(3)
tt.aura.duration = -1
tt.aura.radius = 256
tt.aura.track_source = true
tt.aura.track_dead = true
tt.aura.allowed_templates = {
	"soldier_chomp_bot",
	"soldier_frankenstein",
	"soldier_tower_rocket_gunners_lvl1",
	"soldier_tower_rocket_gunners_lvl2",
	"soldier_tower_rocket_gunners_lvl3",
	"soldier_tower_rocket_gunners_lvl4",
	"soldier_tower_dwarf_lvl1",
	"soldier_tower_dwarf_lvl2",
	"soldier_tower_dwarf_lvl3",
	"soldier_tower_dwarf_lvl4",
	"hero_robot",
	"hero_mecha",
	"hero_bolin",
	"enemy_blazefang",
	"enemy_sniper",
	"enemy_rolling_sentry",
	"enemy_mad_tinkerer",
	"enemy_scrap_drone",
	"enemy_scrap_speedster",
	"enemy_brute_welder",
	"enemy_darksteel_guardian"
}
tt.aura.vis_flags = F_MOD
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("mod_chomp_bot_transformation", "modifier")
tt.modifier.duration = fts(4)
tt.modifier.use_mod_offset = false
tt.main_script.insert = kr3_scripts.mod_chomp_bot_transformation.insert
tt.main_script.remove = kr3_scripts.mod_chomp_bot_transformation.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.vis_flags = F_MOD
tt.entity = "soldier_chomp_bot"

tt = E:register_t("smokebeard_engineer_ray", "bullet")
tt.image_width = 84
tt.main_script.update = kr3_scripts.smokebeard_engineer_ray.update
tt.render.sprites[1].name = "smokebeard_engineer_ray"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.bullet.hit_fx = "fx_smokebeard_engineer_ray_hit"

tt = E:register_t("fx_smokebeard_engineer_ray_hit", "fx")
tt.render.sprites[1].name = "smokebeard_engineer_ray_hit"
tt.render.sprites[1].anchor.y = 0.5

tt = RT("hero_wilbur", "hero5")
b = balance.heroes.hero_wilbur

AC(tt, "ranged", "timed_attacks", "auras")

tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.hp_max = {
	300,
	330,
	360,
	390,
	420,
	450,
	480,
	510,
	540,
	570
}
tt.hero.level_stats.melee_damage_max = {
	8,
	10,
	11,
	12,
	13,
	14,
	16,
	17,
	18,
	19
}
tt.hero.level_stats.melee_damage_min = {
	6,
	6,
	7,
	8,
	9,
	10,
	10,
	11,
	12,
	13
}
tt.hero.level_stats.regen_health = {
	18,
	19,
	21,
	22,
	24,
	25,
	27,
	28,
	30,
	31
}
tt.hero.level_stats.ranged_damage_max = {
	14,
	16,
	18,
	20,
	22,
	24,
	26,
	28,
	30,
	32
}
tt.hero.level_stats.ranged_damage_min = {
	10,
	11,
	12,
	13,
	15,
	16,
	17,
	19,
	20,
	21
}

tt.hero.skills.missile = E:clone_c("hero_skill")
tt.hero.skills.missile.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.missile.key = "MISSILE"
tt.hero.skills.missile.hr_order = 1
tt.hero.skills.missile.hr_available = true
tt.hero.skills.missile.damage_max = {
	40,
	80,
	120
}
tt.hero.skills.missile.damage_min = {
	28,
	56,
	84
}
tt.hero.skills.missile.xp_gain = {
	100,
	150,
	225
}

tt.hero.skills.smoke = E:clone_c("hero_skill")
tt.hero.skills.smoke.duration = b.smoke.duration
tt.hero.skills.smoke.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.smoke.key = "SMOKE"
tt.hero.skills.smoke.hr_order = 2
tt.hero.skills.smoke.hr_available = true
tt.hero.skills.smoke.slow_factor = {
	0.8,
	0.6,
	0.4
}
tt.hero.skills.smoke.xp_gain = {
	50,
	75,
	100
}

tt.hero.skills.box = E:clone_c("hero_skill")
tt.hero.skills.box.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.box.key = "BOX"
tt.hero.skills.box.hr_order = 3
tt.hero.skills.box.hr_available = true
tt.hero.skills.box.count = {
	1,
	2,
	3
}
tt.hero.skills.box.xp_gain = {
	50,
	100,
	200
}

tt.hero.skills.engine = E:clone_c("hero_skill")
tt.hero.skills.engine.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.engine.key = "ENGINE"
tt.hero.skills.engine.hr_order = 4
tt.hero.skills.engine.hr_available = true
tt.hero.skills.engine.max_chomp_bots = {
	4,
	6,
	8
}
tt.hero.skills.engine.chomp_bot_hp = {
	96,
	120,
	162
}

tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_wilbur_ultimate"
tt.hero.skills.ultimate.damage = {
	3,
	6,
	9,
	12
}
tt.hero.skills.ultimate.hr_cost = {
	1,
	3,
	3,
	3
}
tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown
tt.hero.skills.ultimate.hr_available = false
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.key = "DRONES"

tt.hero.team = TEAM_LINIREA
tt.health.dead_lifetime = 30
tt.health_bar.draw_order = -1
tt.health_bar.offset = v(0, 140)
tt.health_bar.sort_y_offset = -200
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.hero.fn_level_up = kr3_scripts.hero_wilbur.level_up
tt.hero.tombstone_decal = "decal_kr3_hero_tombstone"
tt.hero.tombstone_show_time = fts(45)
tt.hero.use_custom_spawn_point = true
tt.idle_flip.cooldown = 10
tt.info.fn = kr3_scripts.hero_wilbur.get_info
tt.info.hero_portrait = "hero_portraits_0102"
tt.info.i18n_key = "HERO_ELVES_GYRO"
tt.info.portrait = "portraits_hero_0102"
tt.info.ultimate_icon = "0102"
tt.info.stat_hp = 9
tt.info.stat_armor = 0
tt.info.stat_damage = 10
tt.info.stat_cooldown = 10
tt.main_script.insert = kr3_scripts.hero_wilbur.insert
tt.main_script.update = kr3_scripts.hero_wilbur.update
tt.motion.max_speed = b.speed
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = TERRAIN_ALL_MASK
tt.nav_grid.valid_terrains_dest = TERRAIN_ALL_MASK
tt.drag_line_origin_offset = v(0, 80)
tt.regen.cooldown = 1

for i = 1, 4 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].anchor.y = 0.065
	tt.render.sprites[i].prefix = "hero_wilbur_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].angles = {}
	tt.render.sprites[i].angles.walk = {
		"idle"
	}
	tt.render.sprites[i].group = i == 3 and "gun" or nil
	tt.render.sprites[i].z = Z_FLYING_HEROES
end

tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].alpha = 150
tt.render.sprites[5].anchor.y = 0.04032258064516129
tt.render.sprites[5].animated = false
tt.render.sprites[5].name = "decal_wilbur_shadow"
tt.render.sprites[5].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(0, 0)
tt.sound_events.change_rally_point = "ElvesHeroGyroTaunt"
tt.sound_events.death = "ElvesHeroGyroDeath"
tt.sound_events.hero_room_select = "ElvesHeroGyroTauntSelect"
tt.sound_events.insert = "ElvesHeroGyroTauntIntro"
tt.sound_events.respawn = "ElvesHeroGyroTauntIntro"
tt.ui.click_rect = r(-25, 50, 50, 55)
tt.unit.hit_offset = v(0, 90)
tt.unit.hide_after_death = true
tt.unit.mod_offset = v(0, 80)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].animations = {
	nil,
	"shoot"
}
tt.ranged.attacks[1].bullet = "shot_wilbur"
tt.ranged.attacks[1].bullet_start_offset = {
	v(19, 44)
}
tt.ranged.attacks[1].cooldown = 0.8
tt.ranged.attacks[1].loops = 1
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].shoot_times = {
	0,
	fts(6),
	fts(12)
}
tt.ranged.attacks[1].sprite_group = "gun"
tt.ranged.attacks[1].sound = "ElvesHeroGyroAttack"
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[2].animations = {
	nil,
	"projectile"
}
tt.ranged.attacks[2].bullet = "missile_wilbur"
tt.ranged.attacks[2].bullet_shot_start_offset = {
	v(-24, 87),
	v(-5, 123)
}
tt.ranged.attacks[2].cooldown = 25
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].filter_fn = kr3_scripts.hero_wilbur.missile_filter_fn
tt.ranged.attacks[2].loops = 1
tt.ranged.attacks[2].max_range = 500
tt.ranged.attacks[2].min_range = 20
tt.ranged.attacks[2].node_prediction = 2
tt.ranged.attacks[2].shoot_times = {
	fts(5),
	fts(8)
}
tt.ranged.attacks[2].xp_from_skill_once = "missile"
tt.timed_attacks.list[1] = CC("aura_attack")
tt.timed_attacks.list[1].animations = {
	"smokeStart",
	"smokeLoop",
	"smokeEnd"
}
tt.timed_attacks.list[1].bullet = "aura_smoke_wilbur"
tt.timed_attacks.list[1].cooldown = 15
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = 20
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].node_prediction = fts(24) + 0.25
tt.timed_attacks.list[1].sound = "ElvesHeroGyroSmokeLaunch"
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].vis_bans = F_FLYING
tt.timed_attacks.list[1].xp_from_skill = "smoke"
tt.timed_attacks.list[2] = CC("bullet_attack")
tt.timed_attacks.list[2].animation = "box"
tt.timed_attacks.list[2].bullet = "box_wilbur"
tt.timed_attacks.list[2].bullet_start_offset = v(35, 115)
tt.timed_attacks.list[2].cooldown = 22
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].payload = "aura_box_wilbur"
tt.timed_attacks.list[2].range_nodes_max = b.box.range_nodes_max
tt.timed_attacks.list[2].range_nodes_min = b.box.range_nodes_min
tt.timed_attacks.list[2].max_path_dist = 50
tt.timed_attacks.list[2].shoot_time = fts(12)
tt.timed_attacks.list[2].sound = "ElvesHeroGyroBoombBox"
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_BLOCK)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_NIGHTMARE)
tt.timed_attacks.list[2].xp_from_skill = "box"
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].cooldown = 0
tt.auras.list[1].name = "aura_chomp_bot_transformation"

tt = RT("hero_wilbur_ultimate")
AC(tt, "pos", "main_script", "sound_events")

tt.can_fire_fn = kr3_scripts.hero_wilbur_ultimate.can_fire_fn
tt.cooldown = 40
tt.main_script.update = kr3_scripts.hero_wilbur_ultimate.update
tt.sound_events.insert = "ElvesHeroGyroDronesSpawn"
tt.entity = "drone_wilbur"
tt.spawn_offsets = {
	v(0, 25),
	v(15, 0),
	v(-15, 0),
	v(0, -25)
}

tt = RT("missile_wilbur", "bullet")
tt.bullet.acceleration_factor = 0.05
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 60
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.first_retarget_range = 300
tt.bullet.hit_fx = "fx_missile_wilbur_hit"
tt.bullet.hit_fx_air = "fx_missile_wilbur_hit_air"
tt.bullet.max_speed = 360
tt.bullet.min_speed = 240
tt.bullet.particles_name = "ps_missile_wilbur"
tt.bullet.retarget_range = 99999
tt.bullet.turn_speed = 10 * math.pi / 180 * 30
tt.bullet.vis_bans = 0
tt.bullet.vis_flags = F_RANGED
tt.bullet.damage_flags = F_AREA
tt.bullet.max_seek_angle = 0.2
tt.bullet.rot_dir_from_long_angle = true
tt.main_script.insert = kr3_scripts.missile_wilbur.insert
tt.main_script.update = kr3_scripts.missile.update
tt.render.sprites[1].prefix = "missile_wilbur"
tt.render.sprites[1].scale = vv(0.75)
tt.sound_events.hit = "BombExplosionSound"
tt.sound_events.insert = "RocketLaunchSound"

tt = RT("box_wilbur", "bomb")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(30)
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.g = -1 / (fts(1) * fts(1))
tt.bullet.rotation_speed = -15 * FPS * math.pi / 180
tt.sound_events.insert = nil
tt.render.sprites[1].name = "hero_wilburg_box"
tt.render.sprites[1].animated = false

tt = RT("shot_wilbur", "bullet")
b = balance.heroes.hero_wilbur.basic_attack
tt.bullet.use_unit_damage_factor = true
tt.bullet.hit_fx = "fx_shot_wilbur_hit"
tt.bullet.shoot_fx = "fx_shot_wilbur_flash"
tt.bullet.flight_time = fts(8)
tt.bullet.damage_type = b.damage_type
tt.bullet.xp_gain_factor = 0.38
tt.main_script.update = kr3_scripts.shot_wilbur.update
tt.render = nil

tt = RT("aura_rabbit_kamihare", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = 30
tt.aura.damage_max = 40
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.radius = 37.5
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = scripts.aura_apply_damage.update

tt = RT("aura_bomb_wilbur", "aura_rabbit_kamihare")
b = balance.heroes.hero_wilbur.box
tt.aura.damage_min = 110
tt.aura.damage_max = 155
tt.aura.radius = 30
tt.aura.damage_type = b.damage_type
tt.sound_events.insert = "BombExplosionSound"

tt = RT("aura_bobbing_wilbur", "aura")
tt.aura.duration = -1
tt.main_script.update = kr3_scripts.aura_wilbur_bobbing.update

tt = RT("aura_box_wilbur", "decal_scripted")

AC(tt, "spawner", "sound_events")

tt.render.sprites[1].anchor.y = 0.25
tt.render.sprites[1].name = "box_wilbur_open"
tt.render.sprites[1].loop = false
tt.spawner.entity = "bomb_wilbur"
tt.spawner.spawn_time = fts(10)
tt.spawner.count = nil
tt.sound_events.insert = "ElvesHeroGyroBoombBoxTouchdown"
tt.main_script.update = kr3_scripts.aura_box_wilbur.update

tt = RT("aura_smoke_wilbur", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = 0.2
tt.aura.duration = nil
tt.aura.mod = "mod_slow_wilbur"
tt.aura.radius = 60
tt.aura.vis_bans = bor(F_FRIEND)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

for i, offset in ipairs({
	v(25, -20),
	v(-11, -20),
	v(7, 5)
}) do
	local s = CC("sprite")

	s.name = "decal_wilbur_smoke"
	s.offset = offset
	s.anchor.y = 0.15
	s.scale = v(1, 1)
	tt.render.sprites[i] = s
	tt.tween.props[2 * i - 1] = CC("tween_prop")
	tt.tween.props[2 * i - 1].keys = {
		{
			0,
			0
		},
		{
			0.6,
			255
		},
		{
			"this.aura.duration-0.6",
			255
		},
		{
			"this.aura.duration",
			0
		}
	}
	tt.tween.props[2 * i - 1].sprite_id = i
	tt.tween.props[2 * i] = CC("tween_prop")
	tt.tween.props[2 * i].keys = {
		{
			0,
			vv(0.3)
		},
		{
			fts(13),
			vv(1.1)
		},
		{
			fts(15),
			vv(1)
		}
	}
	tt.tween.props[2 * i].name = "scale"
	tt.tween.props[2 * i].sprite_id = i
end

tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].anchor.y = 0.14545454545454545
tt.render.sprites[4].name = "fx_wilbur_smoke_start"
tt.render.sprites[4].hide_after_runs = 1
tt.tween.remove = false

tt = RT("mod_slow_wilbur", "mod_slow")
tt.slow.factor = nil

tt = E:register_t("hero_elves_archer", "hero5")
E:add_comps(tt, "melee", "ranged", "dodge", "reinforcement")
image_y = 68
anchor_y = 16 / image_y
tt.hero.level_stats.hp_max = {
	220,
	240,
	260,
	280,
	300,
	320,
	340,
	360,
	380,
	400
}
tt.hero.level_stats.regen_health = {
	20,
	25,
	30,
	35,
	40,
	45,
	50,
	55,
	60,
	65
}
tt.hero.level_stats.armor = {
	0.1,
	0.15,
	0.2,
	0.25,
	0.3,
	0.35,
	0.4,
	0.45,
	0.5,
	0.55
}
tt.hero.level_stats.melee_damage_min = {
	8,
	9,
	10,
	10,
	11,
	12,
	13,
	14,
	14,
	15
}
tt.hero.level_stats.melee_damage_max = {
	12,
	13,
	14,
	16,
	17,
	18,
	19,
	20,
	22,
	23
}
tt.hero.level_stats.ranged_damage_min = {
	8,
	9,
	10,
	10,
	11,
	12,
	13,
	14,
	14,
	15
}
tt.hero.level_stats.ranged_damage_max = {
	12,
	13,
	14,
	16,
	17,
	18,
	19,
	20,
	22,
	23
}
tt.hero.skills.double_strike = E:clone_c("hero_skill")
tt.hero.skills.double_strike.damage_max = {
	80,
	160,
	240
}
tt.hero.skills.double_strike.damage_min = {
	40,
	80,
	120
}
tt.hero.skills.double_strike.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.double_strike.hr_icon = "0002"
tt.hero.skills.double_strike.hr_order = 4
tt.hero.skills.double_strike.key = "DOUBLE"
tt.hero.skills.double_strike.xp_gain_factor = 40
tt.hero.skills.multishot = E:clone_c("hero_skill")
tt.hero.skills.multishot.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.multishot.hr_icon = "0001"
tt.hero.skills.multishot.hr_order = 1
tt.hero.skills.multishot.key = "VOLLEY"
tt.hero.skills.multishot.loops = {
	3,
	6,
	9
}
tt.hero.skills.multishot.xp_gain_factor = 25
tt.hero.skills.nimble_fencer = E:clone_c("hero_skill")
tt.hero.skills.nimble_fencer.chance = {
	0.1,
	0.3,
	0.6
}
tt.hero.skills.nimble_fencer.hr_cost = {
	1,
	2,
	3
}
tt.hero.skills.nimble_fencer.hr_icon = "0003"
tt.hero.skills.nimble_fencer.hr_order = 3
tt.hero.skills.nimble_fencer.key = "NIMBLE"
tt.hero.skills.nimble_fencer.xp_gain = {
	25,
	25,
	25
}
tt.hero.skills.porcupine = E:clone_c("hero_skill")
tt.hero.skills.porcupine.damage_inc = {
	1,
	2,
	3
}
tt.hero.skills.porcupine.hr_cost = {
	1,
	1,
	1
}
tt.hero.skills.porcupine.hr_icon = "0004"
tt.hero.skills.porcupine.hr_order = 2
tt.hero.skills.porcupine.key = "PORCUPINE"
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_elves_archer_ultimate"
tt.hero.skills.ultimate.hr_cost = {
	4,
	5,
	6
}
tt.hero.skills.ultimate.hr_icon = "0005"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.key = "HAIL"
tt.hero.skills.ultimate.max_range = 250
tt.hero.skills.ultimate.range_nodes_max = 15
tt.hero.skills.ultimate.min_targets = 3
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_elves_archer.level_up
tt.hero.team = TEAM_LINIREA
tt.hero.tombstone_decal = "decal_kr3_hero_tombstone"
tt.hero.tombstone_show_time = fts(60)
tt.idle_flip.chance = 0.4
tt.idle_flip.cooldown = 1
tt.info.fn = scripts.hero_basic.get_info_ranged
-- tt.info.hero_portrait = "hero_portraits_0001"
tt.info.portrait = "portraits_hero_0112"
tt.info.ultimate_icon = "0001"
tt.info.ultimate_pointer_style = "area"
tt.main_script.insert = kr3_scripts.hero_elves_archer.insert
tt.main_script.update = kr3_scripts.hero_elves_archer.update
tt.motion.max_speed = 75
tt.regen.cooldown = 1
tt.regen.health = tt.hero.level_stats.regen_health[1]
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[1].angles.ranged = {
	"shoot"
}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_elves_archer"
tt.sound_events.change_rally_point = "ElvesHeroEridanTaunt"
tt.sound_events.death = "ElvesHeroEridanDeath"
tt.sound_events.respawn = "ElvesHeroEridanTauntIntro"
tt.sound_events.insert = "ElvesHeroEridanTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroEridanTauntSelect"
tt.soldier.melee_slot_offset.x = 5
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, -1)
tt.unit.mod_offset = v(0, 19.9)
tt.dodge.disabled = true
tt.dodge.counter_attack = E:clone_c("melee_attack")
tt.dodge.counter_attack.animation = "nimble_fencer"
tt.dodge.counter_attack.cooldown = 1
tt.dodge.counter_attack.damage_max = 40
tt.dodge.counter_attack.damage_min = 20
tt.dodge.counter_attack.hit_time = fts(8)
tt.dodge.counter_attack.sound = "ElvesHeroEridanNimbleFencing"
tt.melee.attacks[1] = E:clone_c("melee_attack")
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(7)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 0.62
tt.melee.attacks[2] = E:clone_c("melee_attack")
tt.melee.attacks[2].animation = "double_strike"
tt.melee.attacks[2].cooldown = 11
tt.melee.attacks[2].damage_max = nil
tt.melee.attacks[2].damage_min = nil
tt.melee.attacks[2].damage_type = bor(DAMAGE_PHYSICAL, DAMAGE_FX_EXPLODE)
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(14)
tt.melee.attacks[2].vis_bans = bor(F_CLIFF)
tt.melee.attacks[2].vis_flags = F_BLOCK
tt.melee.attacks[2].xp_from_skill = "double_strike"
tt.melee.attacks[2].sound = "ElvesHeroEridanDoubleStrike"
tt.melee.cooldown = 1
tt.melee.range = 67.5
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].bullet = "arrow_hero_elves_archer"
tt.ranged.attacks[1].bullet_start_offset = {
	v(9, 28)
}
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].max_range = 215
tt.ranged.attacks[1].min_range = 67.5
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[1].vis_bans = 0
tt.ranged.attacks[2] = E:clone_c("bullet_attack")
tt.ranged.attacks[2].animations = {
	"shoot_start",
	"shoot_loop",
	"shoot_end"
}
tt.ranged.attacks[2].bullet = "arrow_hero_elves_archer"
tt.ranged.attacks[2].bullet_start_offset = {
	v(9, 28)
}
tt.ranged.attacks[2].cooldown = 9
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].max_loops = nil
tt.ranged.attacks[2].max_range = 215
tt.ranged.attacks[2].min_range = 60
tt.ranged.attacks[2].shoot_times = {
	fts(3)
}
tt.ranged.attacks[2].xp_from_skill = "multishot"

tt = E:register_t("aura_elves_archer_regen", "aura")
tt.aura.duration = -1
tt.main_script.update = scripts.aura_hero_regen.update

tt = E:register_t("arrow_hero_elves_archer", "arrow")
tt.render.sprites[1].name = "archer_hero_proy_0001-f"
tt.bullet.use_unit_damage_factor = true
tt.bullet.miss_decal = "archer_hero_proy_0002-f"
tt.bullet.flight_time = fts(15)
tt.bullet.pop = {
	"pop_archer"
}
tt.bullet.hide_radius = 1
tt.bullet.xp_gain_factor = 0.62

tt = E:register_t("hero_elves_archer_ultimate")
E:add_comps(tt, "pos", "main_script")
tt.can_fire_fn = kr3_scripts.hero_elves_archer_ultimate.can_fire_fn
tt.cooldown = 28.8
tt.bullet = "arrow_hero_elves_archer_ultimate"
tt.spread = {
	[0] = 6,
	8,
	10,
	12
}
tt.damage = {
	[0] = 20,
	31,
	42,
	60
}
tt.main_script.update = kr3_scripts.hero_elves_archer_ultimate.update

tt = E:register_t("mod_hero_elves_archer_slow", "mod_slow")
tt.modifier.duration = 0.1
tt.slow.factor = 0.5

tt = E:register_t("arrow_hero_elves_archer_ultimate", "bullet")
tt.main_script.update = kr3_scripts.arrow_hero_elves_archer_ultimate.update
tt.bullet.damage_radius = 35
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_FRIEND
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.arrive_decal = "decal_hero_elves_archer_ultimate"
tt.bullet.max_speed = 1500
tt.bullet.mod = "mod_hero_elves_archer_slow"
tt.render.sprites[1].name = "archer_hero_arrows_proy-f"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.x = 0.9629629629629629
tt.sound_events.insert = "ArrowSound"

tt = E:register_t("decal_hero_elves_archer_ultimate", "decal_tween")
AC(tt, "main_script")
tt.main_script.insert = kr3_scripts.decal_hero_elves_archer_ultimate.insert
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		1,
		255
	},
	{
		4,
		0
	}
}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.render.sprites[1].name = "decal_hero_elves_archer_ultimate"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "fx_hero_elves_archer_ultimate_smoke"
tt.render.sprites[2].loop = false
tt.render.sprites[2].z = Z_OBJECTS

tt = E:register_t("hero_arivan", "hero5")
E:add_comps(tt, "melee", "ranged", "timed_attacks", "reinforcement")
tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.hp_max = {
	115,
	130,
	145,
	160,
	175,
	190,
	205,
	220,
	235,
	250
}
tt.hero.level_stats.melee_damage_max = {
	8,
	9,
	10,
	12,
	13,
	14,
	16,
	17,
	18,
	20
}
tt.hero.level_stats.melee_damage_min = {
	4,
	5,
	6,
	6,
	7,
	8,
	8,
	9,
	10,
	11
}
tt.hero.level_stats.ranged_damage_min = {
	9,
	10,
	11,
	12,
	14,
	15,
	16,
	17,
	18,
	19
}
tt.hero.level_stats.ranged_damage_max = {
	27,
	30,
	34,
	37,
	41,
	44,
	47,
	51,
	54,
	57
}
tt.hero.level_stats.regen_health = {
	8,
	9,
	10,
	11,
	12,
	13,
	14,
	15,
	16,
	17
}
tt.hero.skills.icy_prison = E:clone_c("hero_skill")
tt.hero.skills.icy_prison.damage = {
	35,
	70,
	105
}
tt.hero.skills.icy_prison.duration = {
	2,
	4,
	6
}
tt.hero.skills.icy_prison.hr_cost = {
	1,
	2,
	3
}
tt.hero.skills.icy_prison.hr_icon = "0008"
tt.hero.skills.icy_prison.hr_order = 3
tt.hero.skills.icy_prison.xp_gain = {
	20,
	60,
	120
}
tt.hero.skills.lightning_rod = E:clone_c("hero_skill")
tt.hero.skills.lightning_rod.damage_max = {
	80,
	180,
	340
}
tt.hero.skills.lightning_rod.damage_min = {
	40,
	100,
	180
}
tt.hero.skills.lightning_rod.hr_cost = {
	1,
	2,
	3
}
tt.hero.skills.lightning_rod.hr_icon = "0007"
tt.hero.skills.lightning_rod.hr_order = 2
tt.hero.skills.lightning_rod.xp_gain = {
	25,
	75,
	150
}
tt.hero.skills.seal_of_fire = E:clone_c("hero_skill")
tt.hero.skills.seal_of_fire.count = {
	1,
	2,
	3
}
tt.hero.skills.seal_of_fire.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.seal_of_fire.hr_icon = "0006"
tt.hero.skills.seal_of_fire.hr_order = 1
tt.hero.skills.seal_of_fire.xp_gain = {
	62,
	125,
	187
}
tt.hero.skills.stone_dance = E:clone_c("hero_skill")
tt.hero.skills.stone_dance.count = {
	1,
	2,
	3
}
tt.hero.skills.stone_dance.hr_cost = {
	1,
	1,
	1
}
tt.hero.skills.stone_dance.hr_icon = "0009"
tt.hero.skills.stone_dance.hr_order = 4
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_arivan_ultimate"
tt.hero.skills.ultimate.max_range = 200
tt.hero.skills.ultimate.range_nodes_max = 15
tt.hero.skills.ultimate.min_targets = 3
tt.hero.skills.ultimate.damage = {
	[0] = 6,
	8,
	10,
	12
}
tt.hero.skills.ultimate.duration = {
	[0] = 3,
	6,
	9,
	12
}
tt.hero.skills.ultimate.freeze_chance = {
	[0] = 0,
	0.3,
	0.6,
	0.9
}
tt.hero.skills.ultimate.freeze_duration = {
	[0] = 0,
	1,
	2,
	3
}
tt.hero.skills.ultimate.hr_cost = {
	4,
	5,
	6
}
tt.hero.skills.ultimate.hr_icon = "0010"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.key = "ELEMENTAL_STORM"
tt.hero.skills.ultimate.lightning_chance = {
	[0] = 0,
	0.5,
	0.65,
	0.8
}
tt.hero.skills.ultimate.lightning_cooldown = {
	[0] = fts(30),
	fts(30),
	fts(24),
	fts(21)
}
tt.health.dead_lifetime = 20
tt.health.on_damage = kr3_scripts.hero_arivan.on_damage
tt.health_bar.offset = v(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_arivan.level_up
tt.hero.team = TEAM_LINIREA
tt.hero.tombstone_decal = "decal_kr3_hero_tombstone"
tt.hero.tombstone_show_time = fts(90)
tt.info.damage_icon = "magic"
tt.info.fn = scripts.hero_basic.get_info_ranged
tt.info.i18n_key = "HERO_ELVES_ELEMENTALIST"
-- tt.info.hero_portrait = "hero_portraits_0002"
tt.info.portrait = "portraits_hero_0113"
tt.info.ultimate_icon = "0002"
tt.main_script.insert = kr3_scripts.hero_arivan.insert
tt.main_script.update = kr3_scripts.hero_arivan.update
tt.motion.max_speed = 2.8 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.083333333333333
tt.render.sprites[1].prefix = "hero_arivan"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[1].name = "idle"
tt.soldier.melee_slot_offset = v(4, 0)
tt.sound_events.change_rally_point = nil
tt.sound_events.death = "ElvesHeroArivanDeath"
tt.sound_events.respawn = "ElvesHeroArivanTauntIntro"
tt.sound_events.insert = "ElvesHeroArivanTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroArivanTauntSelect"
tt.unit.hit_offset = v(0, 13)
tt.unit.mod_offset = v(0, 13)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].xp_gain_factor = 0.64
tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.range = 50
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].max_range = 160
tt.ranged.attacks[1].node_prediction = fts(11)
tt.ranged.attacks[1].bullet = "ray_arivan_simple"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 35)
}
tt.ranged.attacks[1].shoot_time = fts(11)
tt.ranged.attacks[2] = E:clone_c("bullet_attack")
tt.ranged.attacks[2].animation = "rayShoot"
tt.ranged.attacks[2].cooldown = 20
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].min_range = 20
tt.ranged.attacks[2].max_range = 175
tt.ranged.attacks[2].node_prediction = fts(19)
tt.ranged.attacks[2].bullet = "lightning_arivan"
tt.ranged.attacks[2].bullet_start_offset = {
	v(1, 39)
}
tt.ranged.attacks[2].shoot_time = fts(19)
tt.ranged.attacks[2].sound = "ElvesHeroArivanLightingBolt"
tt.ranged.attacks[2].xp_from_skill = "lightning_rod"
tt.ranged.attacks[3] = E:clone_c("bullet_attack")
tt.ranged.attacks[3].animation = "freezeBall"
tt.ranged.attacks[3].cooldown = 15
tt.ranged.attacks[3].disabled = true
tt.ranged.attacks[3].min_range = 20
tt.ranged.attacks[3].max_range = 130
tt.ranged.attacks[3].node_prediction = fts(25)
tt.ranged.attacks[3].bullet = "bolt_freeze_arivan"
tt.ranged.attacks[3].bullet_start_offset = {
	v(1, 40)
}
tt.ranged.attacks[3].shoot_time = fts(25)
tt.ranged.attacks[3].sound = "ElvesHeroArivanIceShoot"
tt.ranged.attacks[3].xp_from_skill = "icy_prison"
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].cooldown = 25
tt.timed_attacks.list[1].min_range = 30
tt.timed_attacks.list[1].max_range = 160
tt.timed_attacks.list[1].bullet = "fireball_arivan"
tt.timed_attacks.list[1].bullet_start_offset = {
	v(-7, 50),
	v(7, 50)
}
tt.timed_attacks.list[1].shoot_times = {
	fts(4),
	fts(14)
}
tt.timed_attacks.list[1].animations = {
	"multiShootStart",
	"multiShootLoop",
	"multiShootEnd"
}
tt.timed_attacks.list[1].loops = 0
tt.timed_attacks.list[1].xp_from_skill = "seal_of_fire"
tt.timed_attacks.list[1].vis_bans = F_FLYING
tt.timed_attacks.list[2] = E:clone_c("custom_attack")
tt.timed_attacks.list[2].animation = "stoneCast"
tt.timed_attacks.list[2].cooldown = 20
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].hit_time = fts(13)
tt.timed_attacks.list[2].sound = "ElvesHeroArivanSummonRocks"

tt = E:register_t("ray_arivan_simple", "bullet")
tt.bullet.use_unit_damage_factor = true
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.hit_fx = "fx_ray_arivan_simple_hit"
tt.bullet.hit_time = fts(5)
tt.bullet.xp_gain_factor = 0.64
tt.image_width = 60
tt.track_target = true
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "arivan_ray_simple"
tt.sound_events.insert = "ElvesHeroArivanRegularRay"

tt = E:register_t("fx_ray_arivan_simple_hit", "fx")
tt.render.sprites[1].name = "arivan_ray_simple_hit"

tt = E:register_t("lightning_arivan", "bullet")
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.hit_fx = "fx_lighting_arivan_hit"
tt.bullet.hit_time = fts(5)
tt.image_width = 90
tt.track_target = true
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "arivan_lightning"
tt.sound_events.insert = nil

tt = E:register_t("fx_lighting_arivan_hit", "fx")
tt.render.sprites[1].name = "arivan_lightning_hit"

tt = E:register_t("ps_freeze_arivan")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "arivan_freeze_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	fts(8),
	fts(8)
}
tt.particle_system.emission_rate = 30
tt.particle_system.z = Z_BULLETS

tt = E:register_t("ps_fireball_arivan")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.names = {
	"arivan_fireball_particle_1",
	"arivan_fireball_particle_2"
}
tt.particle_system.loop = false
tt.particle_system.cycle_names = true
tt.particle_system.animated = true
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(10)
}
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true
tt.particle_system.z = Z_BULLETS

tt = E:register_t("bolt_freeze_arivan", "bolt")
tt.bullet.acceleration_factor = 0.3
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.hit_fx = "fx_bolt_freeze_arivan_hit"
tt.bullet.max_speed = 450
tt.bullet.min_speed = 150
tt.bullet.mod = "mod_arivan_freeze"
tt.bullet.particles_name = "ps_freeze_arivan"
tt.bullet.pop = nil
tt.render.sprites[1].prefix = "arivan_freeze"
tt.render.sprites[1].name = "travel"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.sound_events.insert = "ElvesHeroArivanLightingBolt"

tt = E:register_t("fx_bolt_freeze_arivan_hit", "fx")
E:add_comps(tt, "sound_events")
tt.render.sprites[1].name = "arivan_freeze_hit"
tt.sound_events.insert = "ElvesHeroArivanIceShootHit"

tt = E:register_t("mod_arivan_freeze", "mod_freeze")
E:add_comps(tt, "render", "tween")
tt.modifier.duration = nil
tt.modifier.vis_bans = F_BOSS
tt.render.sprites[1].name = "arivan_hero_freeze_decal"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {
	{
		"this.modifier.duration-0.5",
		255
	},
	{
		"this.modifier.duration",
		0
	}
}

tt = E:register_t("fireball_arivan", "bullet")
tt.bullet.acceleration_factor = 0.15
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 40
tt.bullet.damage_min = 20
tt.bullet.damage_radius = 60
tt.bullet.damage_type = bor(DAMAGE_EXPLOSION, DAMAGE_FX_NOT_EXPLODE)
tt.bullet.hit_fx = "fx_fireball_arivan_hit"
tt.bullet.max_speed = 450
tt.bullet.min_speed = 150
tt.bullet.particles_name = "ps_fireball_arivan"
tt.idle_time = fts(10)
tt.main_script.update = kr3_scripts.fireball_arivan.update
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "arivan_fireball"
tt.sound_events.hit = "ElvesHeroArivanFireballExplode"
tt.sound_events.insert = "ElvesHeroArivanFireballSummon"
tt.sound_events.travel = "ElvesHeroArivanFireball"

tt = E:register_t("fx_fireball_arivan_hit", "fx")
tt.render.sprites[1].name = "arivan_fireball_hit"
tt.render.sprites[1].sort_y_offset = -5
tt.render.sprites[1].anchor.y = 0.20930232558139536
tt.render.sprites[1].z = Z_OBJECTS

tt = E:register_t("aura_arivan_stone_dance", "aura")
E:add_comps(tt, "render")
tt.aura.duration = -1
tt.main_script.update = kr3_scripts.aura_arivan_stone_dance.update
tt.stones = {}
tt.max_stones = 0
tt.shield_active = false
tt.render.sprites[1].name = "arivan_shield"
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[1].hidden = true
tt.render.sprites[1].anchor.y = 0.083333333333333
tt.owner_vis_bans = bor(F_MOD, F_POISON, F_DRIDER_POISON)
tt.rot_speed = 3 * FPS * math.pi / 180
tt.rot_radius = 25

tt = E:register_t("arivan_stone", "decal_tween")
anchor_y = 0.11666666666666667
tt.render.sprites[1].name = "arivan_stone_%d"
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].loop = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "arivan_stone_1_0014"
tt.render.sprites[2].anchor.y = anchor_y
tt.render.sprites[2].z = Z_DECALS
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 0)
	},
	{
		0.5,
		v(0, 3)
	},
	{
		1,
		v(0, 0)
	},
	{
		1.5,
		v(0, -3)
	},
	{
		2,
		v(0, 0)
	}
}
tt.tween.props[1].loop = true
tt.tween.remove = false
tt.hp = 80

tt = E:register_t("fx_arivan_stone_explosion", "fx")
tt.render.sprites[1].name = "arivan_stone_explosion"
tt.render.sprites[1].anchor.y = 0.11666666666666667

tt = E:register_t("hero_arivan_ultimate", "aura")
E:add_comps(tt, "timed_attacks", "motion", "nav_path", "render", "sound_events")
tt.aura.duration = nil
tt.aura.range_nodes = 60
tt.aura.nodes_step = -5
tt.aura.vis_bans = bor(F_CLIFF, F_WATER)
tt.can_fire_fn = kr3_scripts.hero_arivan_ultimate.can_fire_fn
tt.cooldown = 57.6
tt.main_script.update = kr3_scripts.hero_arivan_ultimate.update
tt.motion.max_speed = 0.5 * FPS
tt.render.sprites[1].prefix = "arivan_twister"
tt.render.sprites[1].anchor.y = 0.15853658536585366
tt.sound_events.insert = "ElvesHeroArivanStorm"
tt.sound_events.remove_stop = "ElvesHeroArivanStorm"
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].cooldown = fts(5)
tt.timed_attacks.list[1].mod = "mod_slow"
tt.timed_attacks.list[1].max_range = 80
tt.timed_attacks.list[2] = E:clone_c("area_attack")
tt.timed_attacks.list[2].cooldown = fts(6)
tt.timed_attacks.list[2].max_range = 80
tt.timed_attacks.list[2].damage_max = nil
tt.timed_attacks.list[2].damage_min = nil
tt.timed_attacks.list[2].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[2].vis_bans = 0
tt.timed_attacks.list[3] = E:clone_c("mod_attack")
tt.timed_attacks.list[3].cooldown = fts(30)
tt.timed_attacks.list[3].max_range = 80
tt.timed_attacks.list[3].mod = "mod_arivan_ultimate_freeze"
tt.timed_attacks.list[3].chance = nil
tt.timed_attacks.list[3].vis_bans = F_BOSS
tt.timed_attacks.list[4] = E:clone_c("bullet_attack")
tt.timed_attacks.list[4].bullet = "lightning_arivan_ultimate"
tt.timed_attacks.list[4].bullet_start_offset = {
	v(6, 36)
}
tt.timed_attacks.list[4].max_range = 100
tt.timed_attacks.list[4].chance = nil

tt = E:register_t("lightning_arivan_ultimate", "bullet")
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.mod = "fx_lighting_arivan_ultimate_hit"
tt.bullet.hit_time = fts(4)
tt.image_width = 40
tt.track_target = true
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "arivan_twister_ray"
tt.sound_events.insert = "ElvesHeroArivanRegularRay"

tt = E:register_t("fx_lighting_arivan_ultimate_hit", "modifier")
E:add_comps(tt, "render")
tt.render.sprites[1].name = "arivan_twister_ray_hit"
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.remove = scripts.mod_track_target.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = fts(12)

tt = E:register_t("mod_arivan_ultimate_freeze", "mod_arivan_freeze")
tt.modifier.duration = nil

tt = E:register_t("controller_item_hero_elves_archer", "controller_item_hero")
tt.main_script.insert = customScripts1.controller_item_hero_elves_archer.insert
tt.entities = {
	"hero_elves_archer",
	"hero_arivan"
}

-- towers
tt = RT("tower_bastion", "KR5Tower")
AC(tt, "attacks", "powers", "tween", "nav_grid", "motion", "nav_rally")
tt.info.portrait = "portraits_towers_0145"
tt.info.i18n_key = "ELVES_TOWER_BASTION"
tt.info.fn = kr3_scripts.tower_bastion.get_info
tt.main_script.insert = customScripts1.mobile_tower_mage.insert
tt.main_script.update = kr3_scripts.tower_bastion.update
tt.motion.max_speed = 50
tt.nav_rally.delay_max = nil
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
tt.tower.type = "bastion"
tt.tower.level = 1
tt.tower.price = 0
tt.tower.menu_offset = v(0, 38)
tt.tower.range_offset = v(0, 45)
tt.tower.can_be_sold = false
tt.tower.kind = TOWER_KIND_ENGINEER
tt.tower.team = TEAM_LINIREA
tt.powers.razor_edge = CC("power")
tt.powers.razor_edge.max_level = 2
tt.powers.razor_edge.price = { 200, 200 }
tt.powers.razor_edge.attack_idx = 1
tt.render.sprites[1].name = ""
tt.render.sprites[1].animated = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "tower_bastion_shadow"
tt.render.sprites[2].scale = v(1.05, 1.05)
tt.render.sprites[2].offset = v(0, 28)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "tower_bastion_base"
tt.render.sprites[3].scale = v(1.05, 1.05)
tt.render.sprites[3].offset = v(0, 28)
for i = 1, 4 do
	local s = CC("sprite")
	s.prefix = "galahadriansBastion_layer" .. i
	s.name = "idle"
	s.anchor.y = 0.3153846153846154
	s.group = "animated"
	s.offset = v(0, 37)
	tt.render.sprites[i + 3] = s
end
tt.sound_events.mute_on_level_insert = true
tt.sound_events.insert = {
	"ElvesTowerBastionInsertTaunt",
	"GUITowerBuilding"
}
tt.sound_events.change_rally_point = "ElvesTowerBastionInsertTaunt"
tt.sound_events.change_flip_x = "Stage16OverseerTeleport"
tt.fx_offset = v(0, 38)
tt.fx_out = "tower_ghost_teleport_out"
tt.hidden_delay = fts(6)
tt.fx_in = "tower_ghost_teleport_in"
tt.fx_in_delay = fts(13)
tt.show_delay = fts(15)
tt.select_delay = fts(6)
tt.ui.click_rect = r(-50, -10, 100, 100)
tt.ui.has_nav_mesh = true
tt.attacks.hide_range = true
tt.attacks.range = 175
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "bullet_razor_edge"
tt.attacks.list[1].payload_name = "aura_razor_edge"
tt.attacks.list[1].bullet_start_offset = {
	v(28, 60)
}
tt.attacks.list[1].cooldown = 1.5
tt.attacks.list[1].shoot_time = fts(9)
tt.attacks.list[1].sound_shoot = "ElvesTowerBastionShot"
tt.attacks.list[1].vis_bans = bor(F_FLYING, F_FRIEND, F_NIGHTMARE)
tt.attacks.list[1].vis_flags = bor(F_RANGED)
tt.attacks.list[1].min_range = 45
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 27)
	},
	{
		1,
		v(0, 29)
	},
	{
		2,
		v(0, 27)
	}
}
tt.tween.props[1].sprite_id = 3
tt.tween.props[1].loop = true
tt.tween.props[1].ts = 0
for i = 2, 5 do
	tt.tween.props[i] = E:clone_c("tween_prop")
	tt.tween.props[i].name = "offset"
	tt.tween.props[i].keys = {
		{
			0,
			v(0, 36)
		},
		{
			1,
			v(0, 38)
		},
		{
			2,
			v(0, 36)
		}
	}
	tt.tween.props[i].sprite_id = i + 2
	tt.tween.props[i].loop = true
	tt.tween.props[i].ts = 0
end

tt = RT("bullet_razor_edge", "bolt")
tt.bullet.payload = "aura_razor_edge"
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.acceleration_factor = 0.3
tt.bullet.ignore_rotation = true
tt.bullet.hit_fx = nil
tt.bullet.max_speed = 450
tt.bullet.min_speed = 150
tt.bullet.pop = nil
tt.render.sprites[1].prefix = "bullet_razor_edge"
tt.render.sprites[1].name = "flying"
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.sound_events.insert = nil

tt = RT("aura_razor_edge", "aura")
AC(tt, "render", "tween")
tt.aura.cycle_time = fts(6)
tt.aura.damage_min = 3
tt.aura.damage_max = 5
tt.aura.damage_inc = 3
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.radius = 45
tt.aura.duration = 1
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.insert = kr3_scripts.aura_razor_edge.insert
tt.main_script.update = kr3_scripts.aura_apply_damage.update
tt.render.sprites[1].name = "bullet_razor_edge_flying"
tt.render.sprites[1].loop = true
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.2,
		255
	},
	{
		"this.aura.duration-0.2",
		255
	},
	{
		"this.aura.duration",
		0
	}
}
for i = 2, 4 do
	local s = CC("sprite")

	s.name = "bullet_razor_edge_smoke"
	s.loop = true
	s.random_ts = 0.4
	s.anchor.y = 0
	s.offset.x = ({
		0,
		-15,
		0,
		15
	})[i]
	s.offset.y = ({
		0,
		-20,
		-5,
		-20
	})[i]
	tt.render.sprites[i] = s
	tt.tween.props[i] = table.deepclone(tt.tween.props[1])
	tt.tween.props[i].sprite_id = i
	tt.tween.props[i].keys[1][2] = 0
end

tt = E:register_t("tower_entwood", "tower_KR5")
b = balance.towers.entwood
E:add_comps(tt, "attacks", "powers", "barrack", "vis")
tt.tower.type = "entwood"
tt.tower.kind = TOWER_KIND_ENGINEER
tt.tower.team = TEAM_LINIREA
tt.tower.level = 1
tt.tower.price = 480
tt.tower.range_offset = v(0, 10)
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = v(0, 25)
tt.info.portrait = "portraits_towers_0103"
tt.main_script.insert = kr3_scripts.tower_entwood.insert
tt.main_script.update = kr3_scripts.tower_entwood.update
tt.main_script.remove = scripts.tower_barrack.remove
tt.attacks.range = 210
tt.attacks.load_time = fts(54)
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].animation = "attack1"
tt.attacks.list[1].bullet = "rock_entwood"
tt.attacks.list[1].cooldown = 3.5
tt.attacks.list[1].shoot_time = fts(7)
tt.attacks.list[1].bullet_start_offset = v(-38, 94)
tt.attacks.list[1].vis_bans = bor(F_FLYING, F_NIGHTMARE)
tt.attacks.list[1].node_prediction = fts(33)
tt.attacks.list[2] = table.deepclone(tt.attacks.list[1])
tt.attacks.list[2].bullet = "rock_firey_nut"
tt.attacks.list[2].cooldown = b.fiery_nuts.cooldown
tt.attacks.list[2].animation = "special1"
tt.attacks.list[3] = E:clone_c("area_attack")
tt.attacks.list[3].animation = "special2"
tt.attacks.list[3].cooldown = b.clobber.cooldown
tt.attacks.list[3].damage_bans = F_FLYING
tt.attacks.list[3].damage_flags = F_AREA
tt.attacks.list[3].damage_radius = 225
tt.attacks.list[3].damage_type = DAMAGE_TRUE
tt.attacks.list[3].hit_time = fts(20)
tt.attacks.list[3].min_count = 2
tt.attacks.list[3].range = 195
tt.attacks.list[3].sound = "TowerEntwoodClobber"
tt.attacks.list[3].stun_chances = {
	1,
	1,
	1,
	1
}
tt.attacks.list[3].stun_mod = "mod_clobber"
tt.attacks.list[3].vis_bans = bor(F_FLYING, F_BOSS, F_NIGHTMARE)
tt.attacks.list[3].vis_flags = F_RANGED
tt.powers.clobber = E:clone_c("power")
tt.powers.clobber.price = { 175, 150, 150 }
tt.powers.clobber.attack_idx = 3
tt.powers.clobber.stun_durations = {
	1,
	2,
	3
}
tt.powers.clobber.damage_values = {
	75,
	100,
	125
}
tt.powers.fiery_nuts = E:clone_c("power")
tt.powers.fiery_nuts.price = { 185, 185, 185 }
tt.powers.fiery_nuts.attack_idx = 2
tt.powers.forest_keepers = E:clone_c("power")
tt.powers.forest_keepers.max_level = 2
tt.powers.forest_keepers.price = { 400, 400 }

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 8)

for i = 2, 10 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "tower_entwood_layer" .. i - 1
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].offset = v(0, 42)
	tt.render.sprites[i].group = "layers"
	tt.render.sprites[i].loop = false
end

tt.render.sprites[11] = E:clone_c("sprite")
tt.render.sprites[11].name = "tower_entwood_blink"
tt.render.sprites[11].loop = false
tt.render.sprites[11].offset = v(0, 42)
tt.sound_events.insert = "ElvesRockEntwoodTaunt"
tt.sound_events.change_rally_point = "ElvesBarrackForestKeeperTaunt"
tt.barrack.max_soldiers = 2
tt.barrack.soldier_type = "soldier_forest"
tt.barrack.rally_range = 145
tt.barrack.rally_angle_offset = math.pi / 3
tt.barrack.respawn_offset = v(0, 1)

tt = E:register_t("rock_1", "bombKR5")
tt.bullet.flight_time = fts(28)
tt.bullet.damage_radius = 60
tt.bullet.damage_max = 12
tt.bullet.damage_min = 7
tt.bullet.hit_fx = "fx_rock_explosion"
tt.bullet.hit_decal = "decal_rock_crater"
tt.bullet.pop = {
	"pop_artillery"
}
tt.render.sprites[1].name = "artillery_thrower_proy"
tt.sound_events.insert = "TowerStoneDruidBoulderThrow"
tt.sound_events.hit = "TowerStoneDruidBoulderExplote"
tt.sound_events.hit_water = "RTWaterExplosion"

tt = E:register_t("rock_entwood", "rock_1")
tt.bullet.damage_max = 106
tt.bullet.damage_min = 62
tt.bullet.damage_radius = 60
tt.bullet.pop = {
	"pop_entwood"
}
tt.render.sprites[1].name = "artillery_tree_proys_0001"
tt.sound_events.insert = "TowerEntwoodCocoThrow"
tt.sound_events.hit = "TowerEntwoodCocoExplosion"

tt = E:register_t("rock_firey_nut", "rock_entwood")
tt.bullet.damage_max = 0
tt.bullet.damage_max_inc = 135
tt.bullet.damage_min = 0
tt.bullet.damage_min_inc = tt.bullet.damage_max_inc
tt.bullet.damage_radius = 65
tt.bullet.hit_payload = "aura_fiery_nut"
tt.bullet.hit_fx = "fx_fiery_nut_explosion"
tt.bullet.hit_decal = nil
tt.render.sprites[1].name = "artillery_tree_proys_0002"
tt.sound_events.hit = "TowerEntwoodFieryExplote"

tt = E:register_t("mod_clobber", "mod_common_stun")

E:add_comps(tt, "render")

tt.main_script.insert = scripts.mod_stun.insert
tt.main_script.update = scripts.mod_stun.update
tt.main_script.remove = scripts.mod_stun.remove
tt.render.sprites[1].prefix = "stun"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 10

tt = E:register_t("aura_fiery_nut", "aura")

E:add_comps(tt, "render", "tween")

tt.aura.cycle_time = 0.3
tt.aura.duration = 5
tt.aura.mod = "mod_fiery_nut"
tt.aura.radius = 65
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "decal_fiery_nut_scorched"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		"this.aura.duration-1",
		255
	},
	{
		"this.aura.duration",
		0
	}
}

tt = E:register_t("mod_fiery_nut", "modifier")

E:add_comps(tt, "dps", "render")

tt.dps.damage_min = 0
tt.dps.damage_max = 0
tt.dps.damage_inc = 1
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = fts(3)
tt.dps.kill = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.duration = 6
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {
	"small",
	"medium",
	"large"
}
tt.render.sprites[1].draw_order = 10

tt = E:register_t("fx_rock_explosion", "fx")
tt.render.sprites[1].name = "fx_rock_explosion"
tt.render.sprites[1].anchor.y = 0.23684210526315788
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5

tt = E:register_t("fx_fiery_nut_explosion", "fx")
tt.render.sprites[1].name = "fx_fiery_nut_explosion"
tt.render.sprites[1].anchor.y = 0.19791666666666666
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5

tt = E:register_t("decal_rock_crater", "decal_tween")
tt.tween.props[1].keys = {
	{
		1,
		255
	},
	{
		2.5,
		0
	}
}
tt.render.sprites[1].name = "artillery_thrower_explosion_decal"
tt.render.sprites[1].animated = false

tt = E:register_t("decal_clobber_1", "decal_tween")
tt.render.sprites[1].name = "EarthquakeTower_HitDecal1"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		1,
		255
	},
	{
		2.5,
		0
	}
}

tt = E:register_t("decal_clobber_2", "decal_clobber_1")
tt.render.sprites[1].name = "EarthquakeTower_HitDecal2"

tt = E:register_t("fx_clobber_smoke", "fx")
tt.render.sprites[1].name = "fx_clobber_smoke"

tt = E:register_t("fx_clobber_smoke_ring", "fx")
tt.render.sprites[1].name = "fx_clobber_smoke_ring"
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("soldier_forest", "soldier_militia")

E:add_comps(tt, "powers", "timed_attacks", "ranged", "nav_grid")

image_y = 114
anchor_y = 31 / image_y
tt.health.armor = 0
tt.health.dead_lifetime = 12
tt.health.hp_max = 300
tt.health_bar.offset = v(0, 54)
tt.info.portrait = "bottom_info_image_soldiers_0006"
tt.info.random_name_format = "ELVES_SOLDIER_FOREST_KEEPER_%i_NAME"
tt.info.random_name_count = 9
tt.main_script.insert = kr3_scripts.soldier_forest.insert
tt.main_script.update = kr3_scripts.soldier_forest.update
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = 1.3
tt.melee.attacks[1].damage_max = 36
tt.melee.attacks[1].damage_min = 24
tt.melee.attacks[1].pop = {
	"pop_forest_keeper"
}
tt.melee.attacks[1].forced_cooldown = true
tt.melee.forced_cooldown = tt.melee.attacks[1].cooldown
tt.melee.range = 49.5
tt.motion.max_speed = 60
tt.powers.circle = E:clone_c("power")
tt.powers.eerie = E:clone_c("power")
tt.powers.oak = E:clone_c("power")
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].animation = "ranged_attack"
tt.ranged.attacks[1].bullet = "spear_forest"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 35)
}
tt.ranged.attacks[1].cooldown = 2.5 + fts(18)
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].shoot_time = fts(8)
tt.ranged.attacks[2] = table.deepclone(tt.ranged.attacks[1])
tt.ranged.attacks[2].animation = "oak_attack"
tt.ranged.attacks[2].bullet = "spear_forest_oak"
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].shoot_time = fts(14)
tt.regen.health = 35
tt.render.sprites[1].prefix = "soldier_forest"
tt.render.sprites[1].anchor.y = anchor_y
tt.soldier.melee_slot_offset = v(5, 0)
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "circle"
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].cooldown = 10
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].mod = "mod_forest_circle"
tt.timed_attacks.list[1].sound = "TowerForestKeeperCircleOfHealing"
tt.timed_attacks.list[1].trigger_hp_factor = 0.8
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY)
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.timed_attacks.list[2] = E:clone_c("aura_attack")
tt.timed_attacks.list[2].animation = "eerie"
tt.timed_attacks.list[2].cast_time = fts(20)
tt.timed_attacks.list[2].cooldown = 16
tt.timed_attacks.list[2].max_range = 110
tt.timed_attacks.list[2].max_range_inc = 15
tt.timed_attacks.list[2].bullet = "aura_forest_eerie"
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_BOSS, F_NIGHTMARE)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.ui.click_rect = r(-10, -2, 20, 35)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 25)
tt.unit.hit_offset = v(0, 25)
tt.powers.circle.level = 1
tt.powers.eerie.level = 1
tt.powers.oak.level = 1

tt = E:register_t("spear_forest", "arrow")
tt.bullet.damage_max = 69
tt.bullet.damage_min = 45
tt.bullet.miss_decal = "forestKeeper_proy_0002-f"
tt.bullet.miss_decal_anchor = v(1, 0.5)
tt.bullet.flight_time = fts(14)
tt.bullet.hide_radius = 1
tt.bullet.reset_to_target_pos = true
tt.render.sprites[1].name = "forestKeeper_proy_0001-f"
tt.render.sprites[1].anchor.x = 0.8260869565217391
tt.sound_events.insert = "TowerForestKeeperNormalSpear"

tt = E:register_t("spear_forest_oak", "spear_forest")
tt.bullet.damage_max = 55
tt.bullet.damage_min = 55
tt.bullet.damage_inc = 35
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.miss_decal = "forestKeeper_proySpecial_0002-f"
tt.bullet.hit_fx = "fx_spear_forest_oak_hit"
tt.render.sprites[1].name = "forestKeeper_proySpecial_0001-f"
tt.sound_events.insert = "TowerForestKeeperAncientSpear"

tt = E:register_t("fx_forest_circle", "fx")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "forestKeeper_circle1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "forestKeeper_circle1_0001"
tt.render.sprites[2].animated = false
tt.tween.remove = true
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(2),
		255
	},
	{
		fts(16),
		255
	},
	{
		fts(29),
		0
	}
}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		v(0.2, 0.2)
	},
	{
		fts(8),
		v(0.6, 0.6)
	}
}
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "r"
tt.tween.props[3].keys = {
	{
		0,
		0
	},
	{
		fts(20),
		-math.pi / 4
	}
}
tt.tween.props[3].loop = true
tt.tween.props[4] = table.deepclone(tt.tween.props[1])
tt.tween.props[4].sprite_id = 2
tt.tween.props[5] = table.deepclone(tt.tween.props[2])
tt.tween.props[5].keys = {
	{
		0,
		v(0.5, 0.5)
	},
	{
		fts(8),
		v(1, 1)
	}
}
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[3])
tt.tween.props[6].keys = {
	{
		0,
		0
	},
	{
		fts(20),
		math.pi / 4
	}
}
tt.tween.props[6].sprite_id = 2

tt = E:register_t("fx_spear_forest_oak_hit", "fx")
tt.render.sprites[1].name = "fx_spear_forest_oak_hit"

tt = E:register_t("mod_forest_circle", "modifier")

E:add_comps(tt, "hps", "render")

tt.render.sprites[1].name = "decal_mod_forest_circle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "forestKeeper_soldierBuff"
tt.render.sprites[2].animated = false
tt.render.sprites[2].sort_y_offset = -1
tt.render.sprites[2].anchor.y = 0.21428571428571427
tt.modifier.duration = 4
tt.modifier.use_mod_offset = false
tt.modifier.bans = {
	"mod_son_of_mactans_poison",
	"mod_drider_poison",
	"mod_dark_spitters",
	"mod_balrog",
	"mod_enemy_noxious_horror_poison",
	"mod_enemy_blinker_stun",
	"mod_dreadeye_viper_arrow_acidic",
	"mod_dreadeye_viper_basic_attack",
	"mod_cutthroat_rat_bleed",
	"mod_enemy_skunk_bombardier_basic_attack",
	"mod_enemy_rhino_charge_soldier"
}
tt.modifier.remove_banned = true
tt.hps.heal_min = 0
tt.hps.heal_max = 0
tt.hps.heal_inc = 4
tt.hps.heal_every = 0.2
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update

tt = E:register_t("mod_forest_eerie_slow", "mod_slow")
tt.modifier.duration = 0.5
tt.slow.factor = 0.5

tt = E:register_t("mod_forest_eerie_dps", "modifier")

E:add_comps(tt, "dps")

tt.dps.damage_max = 2
tt.dps.damage_min = 2
tt.dps.damage_inc = 1
tt.dps.damage_every = fts(5)
tt.modifier.duration = 0.5
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update

tt = E:register_t("aura_forest_eerie", "aura")
tt.aura.mods = {
	"mod_forest_eerie_slow",
	"mod_forest_eerie_dps"
}
tt.aura.radius = 60
tt.aura.duration = 1.5
tt.aura.duration_inc = 2
tt.aura.cycle_time = fts(5)
tt.aura.vis_flags = bor(F_MOD)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.main_script.insert = kr3_scripts.aura_forest_eerie.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.roots_count = 9
tt.roots_count_inc = 3
tt.sound_events.insert = "TowerForestKeeperEerieGarden"

tt = E:register_t("decal_eerie_root_1", "decal_scripted")
tt.render.sprites[1].prefix = "decal_eerie_roots_1"
tt.render.sprites[1].anchor.y = 0.1875
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].hidden = true
tt.main_script.update = kr3_scripts.decal_eerie_root.update
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = bor(F_FRIEND)

tt = E:register_t("decal_eerie_root_2", "decal_eerie_root_1")
tt.render.sprites[1].prefix = "decal_eerie_roots_2"
tt.render.sprites[1].anchor.y = 0.14285714285714285

tt = E:register_t("fx_rock_druid_launch", "fx")
tt.render.sprites[1].name = "fx_rock_druid_launch"

tt = E:register_t("rock_2", "rock_1")
tt.bullet.damage_max = 30
tt.bullet.damage_min = 18

tt = E:register_t("rock_3", "rock_1")
tt.bullet.damage_max = 50
tt.bullet.damage_min = 30

tt = E:register_t("rock_druid", "rock_1")

E:add_comps(tt, "tween")

tt.bullet.damage_max = 50
tt.bullet.damage_min = 30
tt.bullet.damage_radius = 60
tt.bullet.hit_decal = "decal_rock_crater"
tt.bullet.hit_fx = "fx_rock_explosion"
tt.bullet.flight_time = fts(35)
tt.bullet.pop = {
	"pop_druid_henge"
}
tt.render.sprites[1].prefix = "druid_stone%i"
tt.render.sprites[1].name = "load"
tt.render.sprites[1].animated = true
tt.render.sprites[1].sort_y_offset = -72
tt.sound_events.load = "TowerDruidHengeRockSummon"
tt.sound_events.hit = "TowerStoneDruidBoulderExplote"
tt.main_script.update = kr3_scripts.rock_druid.update
tt.main_script.insert = nil
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 0)
	},
	{
		0.8,
		v(0, 2)
	},
	{
		1.6,
		v(0, 0)
	}
}
tt.tween.props[1].loop = true

tt = E:register_t("ray_druid_sylvan", "bullet")
tt.image_width = 44
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].name = "ray_druid_sylvan"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_time = fts(5)
tt.bullet.mod = "mod_druid_sylvan_affected"
tt.bullet.track_damage = true

tt = E:register_t("ray_druid_bear", "ray_druid_sylvan")
tt.bullet.damage_type = DAMAGE_PHYSICAL

tt = E:register_t("mod_druid_sylvan", "modifier")

E:add_comps(tt, "render", "tween")

tt.render.sprites[1].name = "artillery_henge_curse_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "mod_druid_sylvan"
tt.render.sprites[2].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[2].name = "small"
tt.render.sprites[2].draw_order = 2
tt.modifier.duration = 10
tt.attack = E:clone_c("bullet_attack")
tt.attack.max_range = 120
tt.attack.bullet = "ray_druid_sylvan"
tt.attack.damage_factor = {
	0.333,
	0.666,
	1
}
tt.attack.vis_flags = bor(F_RANGED, F_MOD)
tt.ray_cooldown = fts(15)
tt.main_script.update = kr3_scripts.mod_druid_sylvan.update
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		v(1, 1)
	},
	{
		0.5,
		v(0.9, 0.9)
	},
	{
		1,
		v(1, 1)
	}
}
tt.tween.props[1].loop = true

tt = E:register_t("mod_druid_bear", "mod_druid_sylvan")
tt.modifier.duration = 5
tt.attack.max_range = 100
tt.attack.bullet = "ray_druid_bear"
tt.attack.damage_factor = {
	0.17,
	0.34,
	0.51
}

tt = E:register_t("mod_druid_sylvan_affected", "modifier")

E:add_comps(tt, "render")

tt.modifier.duration = fts(18)
tt.render.sprites[1].prefix = "mod_druid_sylvan_affected"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update

tt = E:register_t("tower_build_rock_thrower", "tower_build")
tt.build_name = "tower_rock_thrower_lvl1"
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[2].name = "build_artillery"
tt.render.sprites[2].offset = v(0, 26)

tt = E:register_t("tower_rock_thrower_lvl1", "tower_KR5")

E:add_comps(tt, "attacks", "vis")

tt.tower.type = "rock_thrower"
tt.tower.kind = TOWER_KIND_ENGINEER
tt.tower.team = TEAM_LINIREA
tt.tower.level = 1
tt.tower.price = 115
tt.tower.menu_offset = v(0, 20)
tt.tower.range_offset = v(0, 10)
tt.info.portrait = "portraits_towers_0106"
tt.info.i18n_key = "TOWER_ROCK_THROWER_1"
tt.main_script.update = kr3_scripts.tower_rock_thrower.update
tt.attacks.range = 150
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "rock_1"
tt.attacks.list[1].cooldown = 3
tt.attacks.list[1].shoot_time = fts(9)
tt.attacks.list[1].vis_bans = bor(F_FLYING, F_NIGHTMARE)
tt.attacks.list[1].bullet_start_offset = v(0, 46)
tt.attacks.list[1].node_prediction = fts(33)
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "artillery_base_0001"
tt.render.sprites[2].offset = v(0, 26)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "tower_rock_thrower_loading_stones"
tt.render.sprites[3].name = "play"
tt.render.sprites[3].offsets = {
	v(12, 32),
	v(-12, 32)
}
tt.render.sprites[3].draw_order = 7
tt.render.sprites[3].hide_after_runs = 1
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "tower_rock_thrower_shooter_l1"
tt.render.sprites[4].name = "idleDown"
tt.render.sprites[4].angles = {}
tt.render.sprites[4].angles.idle = {
	"idleUp",
	"idleDown"
}
tt.render.sprites[4].angles.shoot = {
	"shootUp",
	"shootDown"
}
tt.render.sprites[4].angles.load = {
	"loadUp",
	"loadDown"
}
tt.render.sprites[4].angles_flip_horizontal = {
	true,
	false
}
tt.render.sprites[4].anchor.y = 0
tt.render.sprites[4].offset = v(0, 12)
tt.render.sprites[4].group = "shooters"
tt.sound_events.insert = "ElvesRockTaunt"

tt = E:register_t("tower_rock_thrower_lvl2", "tower_rock_thrower_lvl1")
tt.tower.level = 2
tt.tower.price = 160
tt.info.i18n_key = "TOWER_ROCK_THROWER_2"
tt.attacks.range = 170
tt.attacks.list[1].bullet = "rock_2"
tt.attacks.list[1].bullet_start_offset = v(0, 47)
tt.render.sprites[2].name = "artillery_base_0002"
tt.render.sprites[3].offsets = {
	v(12, 33),
	v(-12, 33)
}
tt.render.sprites[4].offset = v(0, 13)
tt.render.sprites[5] = table.deepclone(tt.render.sprites[4])
tt.render.sprites[5].prefix = "tower_rock_thrower_shooter_l2"

tt = E:register_t("tower_rock_thrower_lvl3", "tower_rock_thrower_lvl2")
tt.tower.level = 3
tt.tower.price = 200
tt.tower.size = TOWER_SIZE_LARGE
tt.info.i18n_key = "TOWER_ROCK_THROWER_3"
tt.attacks.range = 190
tt.attacks.list[1].bullet = "rock_3"
tt.attacks.list[1].bullet_start_offset = v(0, 51)
tt.render.sprites[2].name = "artillery_base_0003"
tt.render.sprites[3].offsets = {
	v(12, 37),
	v(-12, 37)
}
tt.render.sprites[4].offset = v(0, 17)
tt.render.sprites[5].offset = v(0, 17)
tt.render.sprites[6] = table.deepclone(tt.render.sprites[4])
tt.render.sprites[6].prefix = "tower_rock_thrower_shooter_l3"

tt = E:register_t("tower_rock_thrower_lvl4", "tower_KR5")
b = balance.towers.rock_thrower
E:add_comps(tt, "attacks", "powers", "barrack", "vis")
tt.tower.type = "rock_thrower"
tt.tower.kind = TOWER_KIND_ENGINEER
tt.tower.team = TEAM_LINIREA
tt.tower.level = 4
tt.tower.price = 340
tt.tower.menu_offset = v(0, 20)
tt.tower.range_offset = v(0, 10)
tt.info.portrait = "portraits_towers_0106"
tt.info.i18n_key = "TOWER_STONE_DRUID"
tt.info.tower_portrait = "tower_room_portraits_big_tower_rock_thrower_0001"
tt.info.room_portrait = "quickmenu_tower_icons_0106_0001"
tt.info.stat_damage = 3
tt.info.stat_cooldown = 4
tt.info.stat_range = 6
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.update = kr3_scripts.tower_druid.update
tt.main_script.remove = kr3_scripts.tower_druid.remove
tt.attacks.range = 190
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "rock_druid"
tt.attacks.list[1].cooldown = 1.4
tt.attacks.list[1].shoot_time = fts(9)
tt.attacks.list[1].max_loaded_bullets = 3
tt.attacks.list[1].storage_offsets = {
	v(-25, 77),
	v(34, 72),
	v(5, 99)
}
tt.attacks.list[1].vis_bans = bor(F_FLYING, F_NIGHTMARE)
tt.attacks.list[1].sound = "TowerDruidHengeRockThrow"
tt.attacks.list[1].node_prediction = fts(37)
tt.barrack.rally_range = 145
tt.barrack.rally_radius = 25
tt.barrack.soldier_type = "soldier_druid_bear"
tt.barrack.max_soldiers = 1
tt.powers.nature = E:clone_c("power")
tt.powers.nature.price = { 250, 250 }
tt.powers.nature.max_level = 2
tt.powers.nature.entity = "druid_shooter_nature"
tt.powers.nature.enc_icon = 101
tt.powers.sylvan = E:clone_c("power")
tt.powers.sylvan.price = { 250, 250, 250 }
tt.powers.sylvan.entity = "druid_shooter_sylvan"
tt.powers.sylvan.enc_icon = 102
tt.powers.sylvan.cooldown = b.sylvan.cooldown
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "artillery_base_0005"
tt.render.sprites[2].offset = v(0, 26)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "tower_druid_shooter"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {}
tt.render.sprites[3].angles.idle = {
	"idleUp",
	"idleDown"
}
tt.render.sprites[3].angles.shoot = {
	"shootUp",
	"shootDown"
}
tt.render.sprites[3].angles.load = {
	"castUp",
	"castDown"
}
tt.render.sprites[3].anchor.y = 0.08333333333333333
tt.render.sprites[3].offset = v(0, 44)
tt.sound_events.insert = "ElvesRockHengeTaunt"
tt.sound_events.change_rally_point = "SoldierDruidBearRallyChange"
tt.sound_events.tower_room_select = "ElvesRockHengeTaunt"

tt = E:register_t("druid_shooter_sylvan", "decal_scripted")

E:add_comps(tt, "attacks")

tt.render.sprites[1].prefix = "tower_druid_shooter_sylvan"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].offset = v(-24, 23)
tt.render.sprites[1].anchor.y = 0.06818181818181818
tt.render.sprites[1].draw_order = 2
tt.attacks.list[1] = E:clone_c("spell_attack")
tt.attacks.list[1].spell = "mod_druid_sylvan"
tt.attacks.list[1].cooldown = 15
tt.attacks.list[1].min_targets = 2
tt.attacks.list[1].crowds_range = 100
tt.attacks.list[1].range = 175
tt.attacks.list[1].excluded_templates = {}
tt.attacks.list[1].cast_time = fts(20)
tt.attacks.list[1].sound = "TowerDruidHengeSylvanCurseCast"
tt.attacks.list[1].vis_flags = bor(F_RANGED, F_MOD)
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.main_script.update = kr3_scripts.druid_shooter_sylvan.update

tt = E:register_t("druid_shooter_nature", "decal_scripted")

E:add_comps(tt, "attacks")

tt.render.sprites[1].prefix = "tower_druid_shooter_nature"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].offset = v(22, 17)
tt.render.sprites[1].anchor.y = 0.15217391304347827
tt.render.sprites[1].draw_order = 2
tt.attacks.list[1] = E:clone_c("spawn_attack")
tt.attacks.list[1].animation = "cast"
tt.attacks.list[1].cooldown = 15
tt.attacks.list[1].entity = "soldier_druid_bear"
tt.attacks.list[1].spawn_time = fts(10)
tt.main_script.update = kr3_scripts.druid_shooter_nature.update

tt = E:register_t("soldier_druid_bear", "soldier_militia")

E:add_comps(tt, "melee", "count_group", "nav_grid")

tt.count_group.name = "soldier_druid_bear"
tt.count_group.type = COUNT_GROUP_CONCURRENT
tt.health.armor = 0.35
tt.health.hp_max = 250
tt.health_bar.offsets = {
	idle = v(0, 40),
	standing = v(0, 55)
}
tt.health_bar.offset = tt.health_bar.offsets.idle
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.dead_lifetime = 15
tt.info.fn = scripts.soldier_barrack.get_info
tt.info.portrait = "bottom_info_image_soldiers_0009"
tt.info.random_name_format = "ELVES_SOLDIER_BEAR_%i_NAME"
tt.info.random_name_count = 2
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.update = kr3_scripts.soldier_druid_bear.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "TowerDruidHengeBearAttack"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].mod_prefix = "mod_druid_bear"
tt.melee.range = 60
tt.motion.max_speed = 90
tt.regen.cooldown = 0.5
tt.regen.health = 25
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].anchor.y = 0.28125
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix = "soldier_druid_bear"
tt.soldier.melee_slot_offset = v(10, 0)
tt.sound_events.insert = "TowerDruidHengeBearSummon"
tt.sound_events.death = "TowerDruidHengeBearDeath"
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_POISON)

tt = E:register_t("fx_druid_bear_spawn_rune", "decal")

E:add_comps(tt, "tween")

tt.render.sprites[1].anchor = v(0.48148148148148145, 0.7291666666666666)
tt.render.sprites[1].name = "fx_druid_bear_spawn_rune"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_EFFECTS
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(9),
		255
	},
	{
		fts(15),
		255
	},
	{
		fts(25),
		64
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		fts(0),
		v(1, 1)
	},
	{
		fts(9),
		v(1, 1)
	},
	{
		fts(11),
		v(0.77, 0.77)
	},
	{
		fts(13),
		v(0.85, 0.85)
	},
	{
		fts(19),
		v(0.65, 0.45)
	}
}
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "offset"
tt.tween.props[3].keys = {
	{
		0,
		v(0, 32)
	},
	{
		fts(9),
		v(0, 32)
	},
	{
		fts(13),
		v(0, 32)
	},
	{
		fts(25),
		v(0, 4)
	}
}

tt = E:register_t("fx_druid_bear_spawn_effect", "fx")
tt.render.sprites[1].name = "fx_druid_bear_spawn_effect"
tt.render.sprites[1].anchor = v(0.5, 0.28125)

tt = E:register_t("fx_druid_bear_spawn_decal", "decal")

E:add_comps(tt, "tween")

tt.render.sprites[1].anchor = v(0.5, 0.28125)
tt.render.sprites[1].name = "fx_druid_bear_spawn_decal"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(6),
		0
	},
	{
		fts(7),
		255
	},
	{
		fts(26),
		255
	},
	{
		fts(36),
		102
	},
	{
		fts(41),
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		fts(0),
		v(0.35, 0.35)
	},
	{
		fts(6),
		v(0.35, 0.35)
	},
	{
		fts(10),
		v(1, 1)
	},
	{
		fts(16),
		v(0.8, 0.8)
	}
}

tt = E:register_t("fx_druid_bear_death_rune", "fx_druid_bear_spawn_rune")
tt.render.sprites[1].name = "fx_druid_bear_death_rune"
tt.render.sprites[1].time_offset = fts(-38)
tt.render.sprites[1].sort_y_offset = -1
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		255
	}
}
tt.tween.props[1].time_offset = fts(-28)
tt.tween.props[2].keys = {
	{
		0,
		v(1, 1)
	}
}
tt.tween.props[3].keys = {
	{
		0,
		v(0, 20)
	},
	{
		fts(10),
		v(0, 36)
	},
	{
		fts(19),
		v(0, 40)
	}
}
tt.tween.props[3].time_offset = fts(-28)

tt = E:register_t("fx_druid_bear_death_effect", "fx_druid_bear_spawn_effect")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "fx_druid_bear_death_effect"
tt.render.sprites[1].time_offset = fts(-28)
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(1),
		255
	}
}
tt.tween.props[1].time_offset = fts(-28)

tt = E:register_t("fx_druid_bear_death_decal", "fx_druid_bear_spawn_decal")
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(1),
		255
	},
	{
		fts(4),
		255
	},
	{
		fts(12),
		0
	}
}
tt.tween.props[1].time_offset = fts(-28)
tt.tween.props[2].keys = {
	{
		fts(0),
		v(0.4, 0.35)
	},
	{
		fts(6),
		v(0.77, 0.77)
	},
	{
		fts(10),
		v(0.86, 0.86)
	}
}
tt.tween.props[2].time_offset = fts(-28)

tt = E:register_t("tower_elven_barrack_lvl1", "tower_KR5")

E:add_comps(tt, "barrack", "vis")

tt.barrack.rally_range = 145
tt.barrack.respawn_offset = v(0, 0)
tt.barrack.soldier_type = "soldier_elven_barrack_lvl1"
tt.editor.props = table.append(tt.editor.props, {
	{
		"barrack.rally_pos",
		PT_COORDS
	}
}, true)
tt.info.fn = scripts.tower_barrack.get_info
tt.info.portrait = "portraits_towers_0107"
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.remove = scripts.tower_barrack.remove
tt.main_script.update = scripts.tower_barrack.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "barracks_towers_layer1_0001"
tt.render.sprites[2].offset = v(0, 34)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "close"
tt.render.sprites[3].offset = v(0, 34)
tt.render.sprites[3].prefix = "tower_barrack_1_door"
tt.sound_events.mute_on_level_insert = true
tt.sound_events.change_rally_point = "ElvesBarrackTaunt"
tt.sound_events.insert = "ElvesBarrackTaunt"
tt.tower.level = 1
tt.tower.price = 100
tt.tower.type = "elven_barrack"
tt.tower.kind = TOWER_KIND_BARRACK
tt.tower.team = TEAM_LINIREA
tt.tower.menu_offset = v(0, 22)

tt = E:register_t("tower_elven_barrack_lvl2", "tower_elven_barrack_lvl1")
tt.info.i18n_key = "TOWER_ELVEN_BARRACK_2"
tt.barrack.soldier_type = "soldier_elven_barrack_lvl2"
tt.render.sprites[2].name = "barracks_towers_layer1_0026"
tt.render.sprites[3].prefix = "tower_barrack_2_door"
tt.tower.level = 2
tt.tower.price = 130

tt = E:register_t("tower_elven_barrack_lvl3", "tower_elven_barrack_lvl1")
tt.info.i18n_key = "TOWER_ELVEN_BARRACK_3"
tt.barrack.soldier_type = "soldier_elven_barrack_lvl3"
tt.render.sprites[2].name = "barracks_towers_layer1_0051"
tt.render.sprites[3].prefix = "tower_barrack_3_door"
tt.tower.level = 3
tt.tower.price = 250

tt = E:register_t("tower_blade", "tower_elven_barrack_lvl1")

E:add_comps(tt, "powers")

tt.info.portrait = "portraits_towers_0109"
tt.barrack.soldier_type = "soldier_blade"
tt.powers.perfect_parry = E:clone_c("power")
tt.powers.perfect_parry.price = { 200, 200, 200 }
tt.powers.blade_dance = E:clone_c("power")
tt.powers.blade_dance.price = { 200, 200, 200 }
tt.powers.swirling = E:clone_c("power")
tt.powers.swirling.price = { 150 }
tt.powers.swirling.max_level = 1
tt.powers.swirling.name = "SWIRLING_EDGE"
tt.render.sprites[2].name = "barracks_towers_layer1_0076"
tt.render.sprites[3].prefix = "tower_blade_door"
tt.sound_events.change_rally_point = "ElvesBarrackBladesingerTaunt"
tt.sound_events.insert = "ElvesBarrackBladesingerTaunt"
tt.tower.price = 275
tt.tower.type = "blade"

tt = E:register_t("soldier_elven_barrack_lvl1", "soldier_militia")

E:add_comps(tt, "revive", "nav_grid")

image_y = 46
anchor_y = 11 / image_y
tt.health.armor = 0.3
tt.health.dead_lifetime = 14
tt.health.hp_max = 50
tt.health_bar.offset = v(0, 27)
tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
tt.idle_flip.chance = 0.4
tt.idle_flip.cooldown = 5
tt.info.fn = scripts.soldier_barrack.get_info
tt.info.portrait = "bottom_info_image_soldiers_0010"
tt.info.random_name_count = 25
tt.info.random_name_format = "ELVES_SOLDIER_BARRACKS_%i_NAME"
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.remove = scripts.soldier_barrack.remove
tt.main_script.update = scripts.soldier_barrack.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 4
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].pop = {
	"pop_barrack1",
	"pop_barrack2"
}
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.range = 60
tt.motion.max_speed = 75
tt.regen.cooldown = 1
tt.regen.health = 7
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"running"
}
tt.render.sprites[1].prefix = "soldier_barrack_1"
tt.revive.disabled = nil
tt.revive.chance = 0.1
tt.revive.health_recover = 1
tt.revive.fx = "fx_soldier_barrack_revive"
tt.soldier.melee_slot_offset = v(5, 0)
tt.ui.click_rect = r(-10, -2, 20, 25)
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)

tt = E:register_t("soldier_elven_barrack_lvl2", "soldier_elven_barrack_lvl1")

E:add_comps(tt, "ranged")

image_y = 46
anchor_y = 11 / image_y
tt.health.armor = 0.4
tt.health.hp_max = 90
tt.health_bar.offset = v(0, 27)
tt.info.portrait = "bottom_info_image_soldiers_0010"
tt.melee.attacks[1].damage_max = 8
tt.melee.attacks[1].damage_min = 4
tt.ranged.attacks[1].animation = "ranged_attack"
tt.ranged.attacks[1].bullet = "arrow_soldier_barrack_2"
tt.ranged.attacks[1].bullet_start_offset = {
	v(6, 10)
}
tt.ranged.attacks[1].cooldown = 1.2 + fts(15)
tt.ranged.attacks[1].max_range = 140
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].shoot_time = fts(5)
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.regen.health = 15
tt.render.sprites[1].prefix = "soldier_barrack_2"

tt = E:register_t("soldier_elven_barrack_lvl3", "soldier_elven_barrack_lvl2")
image_y = 46
anchor_y = 11 / image_y
tt.health.armor = 0.5
tt.health.hp_max = 140
tt.health_bar.offset = v(0, 32)
tt.info.portrait = "bottom_info_image_soldiers_0011"
tt.melee.attacks[1].damage_max = 14
tt.melee.attacks[1].damage_min = 9
tt.ranged.attacks[1].bullet = "arrow_soldier_barrack_3"
tt.ranged.attacks[1].cooldown = 1 + fts(15)
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 0
tt.regen.health = 15
tt.render.sprites[1].prefix = "soldier_barrack_3"
tt.unit.mod_offset = v(0, 12)

tt = E:register_t("fx_soldier_barrack_revive", "fx")
tt.render.sprites[1].name = "fx_soldier_barrack_revive"
tt.render.sprites[1].anchor.y = 0.15

tt = E:register_t("arrow_soldier_barrack_2", "arrow")
tt.bullet.damage_max = 8
tt.bullet.damage_min = 4
tt.bullet.miss_decal_anchor = v(1, 0.5)
tt.bullet.flight_time = fts(15)
tt.bullet.reset_to_target_pos = true
tt.bullet.use_unit_damage_factor = true

tt = E:register_t("arrow_soldier_barrack_3", "arrow_soldier_barrack_2")
tt.bullet.damage_max = 14
tt.bullet.damage_min = 9

tt = E:register_t("soldier_blade", "soldier_elven_barrack_lvl1")

E:add_comps(tt, "powers", "dodge", "timed_attacks")

image_y = 68
anchor_y = 15 / image_y
tt.dodge.animation = "dodge"
tt.dodge.chance = 0
tt.dodge.chance_inc = 0.1
tt.dodge.counter_attack = E:clone_c("area_attack")
tt.dodge.counter_attack.animation = "perfect_parry"
tt.dodge.counter_attack.duration = 2
tt.dodge.counter_attack.damage_every = fts(5)
tt.dodge.counter_attack.damage_max = 3
tt.dodge.counter_attack.damage_min = 3
tt.dodge.counter_attack.damage_radius = 50
tt.dodge.counter_attack.damage_type = DAMAGE_TRUE
tt.dodge.counter_attack.hit_time = fts(5)
tt.dodge.counter_attack.sound = "TowerBladesingerPerfectParry"
tt.dodge.power_name = "perfect_parry"
tt.dodge.ranged = true
tt.health.armor = 0.5
tt.health.dead_lifetime = 15
tt.health.hp_max = 200
tt.health.on_damage = kr3_scripts.soldier_blade.on_damage
tt.health_bar.offset = v(0, 32)
tt.info.portrait = "bottom_info_image_soldiers_0013"
tt.main_script.insert = kr3_scripts.soldier_blade.insert
tt.main_script.update = kr3_scripts.soldier_blade.update
tt.melee.attacks[1].animation = "attack1"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 16
tt.melee.attacks[1].damage_min = 11
tt.melee.attacks[1].damage_inc = 10
tt.melee.attacks[1].cooldown_inc = -0.2
tt.melee.attacks[1].pop = {
	"pop_bladesinger"
}
tt.melee.attacks[1].forced_cooldown = true
tt.melee.attacks[1].power_name = "swirling"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.33
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[3].animation = "attack3"
tt.melee.attacks[3].chance = 0.5
tt.melee.forced_cooldown = tt.melee.attacks[1].cooldown
tt.melee.range = 60
tt.motion.max_speed = 75
tt.powers.perfect_parry = E:clone_c("power")
tt.powers.blade_dance = E:clone_c("power")
tt.powers.blade_dance.damage_max = {
	35,
	47,
	59
}
tt.powers.blade_dance.damage_min = {
	25,
	35,
	45
}
tt.powers.blade_dance.hits = {
	2,
	3,
	4
}
tt.powers.swirling = E:clone_c("power")
tt.regen.health = 25
tt.render.sprites[1].prefix = "soldier_blade"
tt.render.sprites[1].anchor.y = anchor_y
tt.soldier.melee_slot_offset = v(5, 0)
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].cooldown = 9
tt.timed_attacks.list[1].damage_max = nil
tt.timed_attacks.list[1].damage_min = nil
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].max_range = 125
tt.timed_attacks.list[1].hits = nil
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_STUN)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_BOSS, F_WATER, F_NIGHTMARE)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_time = fts(5)
tt.timed_attacks.list[1].sound = "TowerBladesingerBladedance"
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 14)

tt = RT("tower_drow", "tower_elven_barrack_lvl1")

AC(tt, "powers")

tt.barrack.soldier_type = "soldier_drow"
tt.info.i18n_key = "ELVES_TOWER_SPECIAL_DROW"
tt.info.portrait = "portraits_towers_0110"
tt.powers.life_drain = CC("power")
tt.powers.life_drain.price = { 200, 175, 175 }
tt.powers.double_dagger = CC("power")
tt.powers.double_dagger.price = { 150 }
tt.powers.double_dagger.max_level = 1
tt.powers.blade_mail = CC("power")
tt.powers.blade_mail.price = { 135, 135, 135 }
tt.render.sprites[2].name = "mercenaryDraw_tower_layer1_0001"
tt.render.sprites[2].offset = v(0, 29)
tt.render.sprites[3].prefix = "tower_drow_door"
tt.render.sprites[3].offset = v(0, 29)
tt.sound_events.change_rally_point = "ElvesDrowTaunt"
tt.sound_events.insert = "ElvesDrowTaunt"
tt.sound_events.mute_on_level_insert = true
tt.tower.price = 280
tt.tower.type = "drow"
tt.tower.team = TEAM_DARK_ARMY

tt = RT("soldier_drow", "soldier_elven_barrack_lvl1")

AC(tt, "powers", "ranged", "track_damage")

tt.health.armor = 0.7
tt.health.dead_lifetime = 15
tt.health.hp_max = 180
tt.health.spiked_armor = 0
tt.health_bar.offset = v(0, 32)
tt.regen.health = 25
tt.revive.disabled = true
tt.info.portrait = "bottom_info_image_soldiers_0014"
tt.info.random_name_format = "ELVES_SOLDIER_DROW_%i_NAME"
tt.info.random_name_count = 15
tt.main_script.insert = kr3_scripts.soldier_drow.insert
tt.main_script.update = kr3_scripts.soldier_drow.update
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 16
tt.melee.attacks[1].damage_min = 11
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].forced_cooldown = true
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].animation = "healAttack"
tt.melee.attacks[2].track_damage = true
tt.melee.attacks[2].damage_max = 0
tt.melee.attacks[2].damage_min = 0
tt.melee.attacks[2].damage_inc = 50
tt.melee.attacks[2].cooldown = 5
tt.melee.attacks[2].hit_time = fts(12)
tt.melee.attacks[2].power_name = "life_drain"
tt.melee.forced_cooldown = tt.melee.attacks[1].cooldown
tt.melee.range = 55
tt.motion.max_speed = 75
tt.powers.life_drain = CC("power")
tt.powers.double_dagger = CC("power")
tt.powers.blade_mail = CC("power")
tt.powers.blade_mail.spiked_armor = {
	0.2,
	0.4,
	0.6
}
tt.ranged.attacks[1].bullet = "dagger_drow"
tt.ranged.attacks[1].animations = {
	"shoot_start",
	"shoot_loop",
	"shoot_end"
}
tt.ranged.attacks[1].bullet_start_offset = {
	v(14, 12)
}
tt.ranged.attacks[1].cooldown = 1 + fts(22)
tt.ranged.attacks[1].loops = 1
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].shoot_times = {
	0
}
tt.ranged.attacks[1].power_name = "double_dagger"
tt.render.sprites[1].prefix = "soldier_drow"
tt.render.sprites[1].anchor.y = 0.2037037037037037
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].hidden = true
tt.render.sprites[2].name = "soldier_drow_blade_mail_decal"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].ignore_start = true
tt.track_damage.mod = "mod_life_drain_drow"
tt.unit.mod_offset = v(0, 15)
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF)

tt = RT("dagger_drow", "bullet")
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_max = 16
tt.bullet.damage_min = 11
tt.bullet.hide_radius = 6
tt.bullet.hit_distance = 22
tt.bullet.hit_fx = "fx_dagger_drow_hit"
tt.bullet.particles_name = "ps_dagger_drow"
tt.bullet.predict_target_pos = true
tt.flight_time_range = {
	fts(9),
	fts(16)
}
tt.main_script.insert = kr3_scripts.dagger_drow.insert
tt.main_script.update = scripts.arrow.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "mercenaryDraw_proy"

tt = E:register_t("fx_dagger_drow_hit", "fx")
tt.render.sprites[1].name = "fx_dagger_drow_hit"

tt = RT("ps_dagger_drow")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "dagger_drow_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	fts(8),
	fts(8)
}
tt.particle_system.emission_rate = 30
tt.particle_system.z = Z_BULLET_PARTICLES

tt = RT("mod_life_drain_drow", "modifier")

AC(tt, "render")

tt.heal_factor = 1
tt.heal_remove_modifiers = {
	"mod_dreadeye_viper_arrow_acidic",
	"mod_dreadeye_viper_basic_attack",
	"mod_enemy_noxious_horror_poison"
}
tt.main_script.insert = scripts.mod_heal_on_damage.insert
tt.main_script.update = scripts.mod_heal_on_damage.update
tt.modifier.use_mod_offset = false
tt.render.sprites[1].name = "soldier_drow_heal"
tt.render.sprites[1].anchor.y = 0.2037037037037037
tt.render.sprites[1].hidden = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1

tt = E:register_t("fx_bolt_elves_hit", "fx")
tt.render.sprites[1].name = "bolt_elves_hit"

tt = E:register_t("fx_wild_magus_hit", "fx")
tt.render.sprites[1].name = "bolt_wild_magus_hit"

tt = E:register_t("fx_ray_wild_magus_hit", "fx")
tt.render.sprites[1].name = "fx_ray_wild_magus_hit"

tt = E:register_t("fx_teleport_violet", "fx")
tt.render.sprites[1].name = "fx_teleport_violet"
tt.render.sprites[1].size_scales = {
	vv(0.83),
	vv(1.2),
	vv(1.3)
}

tt = E:register_t("fx_teleport_orange", "fx")
tt.render.sprites[1].name = "fx_teleport_orange"
tt.render.sprites[1].size_scales = {
	vv(0.83),
	vv(1.2),
	vv(1.3)
}

tt = E:register_t("fx_eldritch_explosion", "fx")
E:add_comps(tt, "sound_events")
tt.render.sprites[1].name = "fx_eldritch_explosion"
tt.render.sprites[1].sort_y_offset = -5
tt.sound_events.insert = "TowerWildMagusDoomExplote"

tt = E:register_t("mod_teleport_mage", "mod_teleport")
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.modifier.vis_bans = bor(F_BOSS)
tt.max_times_applied = 2
tt.nodes_offset = -20
tt.nodeslimit = 10
tt.delay_start = fts(2)
tt.hold_time = 0.34
tt.delay_end = fts(2)
tt.fx_start = "fx_teleport_violet"
tt.fx_end = "fx_teleport_violet"

tt = E:register_t("mod_teleport_wild_magus", "mod_teleport_mage")
tt.fx_start = "fx_teleport_orange"
tt.fx_end = "fx_teleport_orange"

tt = E:register_t("mod_eldritch", "modifier")
E:add_comps(tt, "render")

tt.render.sprites[1].name = "mod_eldritch"
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.update = kr3_scripts.mod_eldritch.update
tt.modifier.vis_flags = bor(F_MOD, F_EAT)
tt.damage_levels = {
	100,
	200,
	300
}
tt.damage_radius = 90
tt.damage_flags = F_RANGED
tt.damage_bans = 0
tt.damage_type = DAMAGE_MAGICAL
tt.sound_events.loop = "TowerWildMagusDoomLoop"

tt = E:register_t("mod_ward", "modifier")
E:add_comps(tt, "render", "tween")

tt.main_script.insert = scripts.mod_silence.insert
tt.main_script.remove = scripts.mod_silence.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 10
tt.modifier.use_mod_offset = false
tt.render.sprites[1].name = "mage_wild_silence_fx"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "mod_ward_decal"
tt.render.sprites[2].animated = true
tt.render.sprites[2].scale = v(1, 0.4)
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "mage_wild_silence_decal_glow"
tt.render.sprites[3].animated = false
tt.render.sprites[3].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.25,
		255
	},
	{
		tt.modifier.duration - 0.25,
		255
	},
	{
		tt.modifier.duration,
		0
	}
}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.custom_offsets = {}
tt.custom_offsets.default = v(0, 40)
tt.custom_offsets.flying = v(0, 82)
tt.custom_offsets.enemy_arachnomancer = v(0, 41)
tt.custom_offsets.enemy_bloodsydian_warlock = v(0, 73)
tt.custom_offsets.enemy_ettin = v(0, 60)
tt.custom_offsets.enemy_gnoll_blighter = v(0, 39)
tt.custom_offsets.enemy_gnoll_bloodsydian = v(0, 39)
tt.custom_offsets.enemy_gnoll_reaver = v(0, 39)
tt.custom_offsets.enemy_hyena = v(0, 20)
tt.custom_offsets.enemy_ogre_magi = v(0, 78)
tt.custom_offsets.enemy_razorboar = v(0, 53)
tt.custom_offsets.enemy_satyr_cutthroat = v(0, 39)
tt.custom_offsets.enemy_satyr_hoplite = v(0, 55)
tt.custom_offsets.enemy_shroom_breeder = v(0, 67)
tt.custom_offsets.enemy_spider_arachnomancer = v(0, 39)
tt.custom_offsets.enemy_sword_spider = v(0, 39)
tt.custom_offsets.enemy_twilight_avenger = v(0, 47)
tt.custom_offsets.enemy_twilight_elf_harasser = v(0, 39)
tt.custom_offsets.enemy_twilight_evoker = v(0, 47)
tt.custom_offsets.enemy_twilight_golem = v(0, 80)
tt.custom_offsets.enemy_twilight_heretic = v(0, 45)
tt.custom_offsets.enemy_twilight_scourger = v(0, 40)
tt.custom_offsets.enemy_zealot = v(0, 39)
tt.custom_offsets.eb_drow_queen = v(0, 40)
tt.custom_offsets.eb_spider = v(0, 87)
tt.custom_offsets.enemy_blood_servant = v(0, 35)
tt.custom_offsets.enemy_grim_devourers = v(0, 39)
tt.custom_offsets.enemy_mounted_avenger = v(0, 63)
tt.custom_offsets.enemy_shadow_champion = v(0, 55)
tt.custom_offsets.enemy_shadows_spawns = v(0, 34)
tt.custom_offsets.eb_saurian_king = v(0, 77)
tt.custom_offsets.enemy_mantaray = v(0, 45)
tt.custom_offsets.enemy_corrupted_stalker = v(0, 95)
tt.custom_offsets.enemy_brute = v(0, 65)

tt = E:register_t("mod_ward_dps", "modifier")
E:add_comps(tt, "dps")
tt.modifier.duration = 10
tt.dps.damage_min = 10
tt.dps.damage_max = 10
tt.dps.damage_every = 0.5
tt.dps.damage_type = DAMAGE_MAGICAL
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update

tt = E:register_t("eldritch_enemy_decal", "decal_tween")
tt.render.sprites[1] = nil
tt.tween.disabled = true
tt.tween.remove = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {}

for i, s in ipairs({
	1.06,
	1.02,
	1.11,
	1.05,
	1.14,
	1.08,
	1.116,
	1.1,
	1.18,
	1.13,
	1.24
}) do
	tt.tween.props[1].keys[i] = {
		(i - 1) * fts(2),
		v(s, s)
	}
end

tt = E:register_t("ps_bolt_elves_1")
E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "mage_proy_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {
	fts(15),
	fts(15)
}
tt.particle_system.alphas = {
	255,
	0
}
tt.particle_system.scales_x = {
	0.8,
	0.25
}
tt.particle_system.scales_y = {
	0.8,
	0.25
}
tt.particle_system.emission_rate = 60

tt = E:register_t("ps_bolt_elves_2", "ps_bolt_elves_1")
tt.particle_system.scales_x = {
	0.9,
	0.25
}
tt.particle_system.scales_y = {
	0.9,
	0.25
}

tt = E:register_t("ps_bolt_elves_3", "ps_bolt_elves_1")
tt.particle_system.scales_x = {
	1,
	0.25
}
tt.particle_system.scales_y = {
	1,
	0.25
}

tt = E:register_t("ps_bolt_wild_magus")
E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "mage_wild_proy_particle"
tt.particle_system.alphas = {
	180,
	12
}
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(10)
}
tt.particle_system.scales_y = {
	1,
	0.5
}
tt.particle_system.scales_x = {
	1,
	0.5
}
tt.particle_system.emission_rate = 60

tt = E:register_t("bolt_elves", "bullet")
E:add_comps(tt, "force_motion")

tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.hit_fx = "fx_bolt_elves_hit"
tt.bullet.max_speed = 300
tt.bullet.min_speed = 30
tt.bullet.pop = {
	"pop_zap"
}
tt.bullet.pop_conds = DR_KILL
tt.bullet.pop_mage_el_empowerment = {
	"pop_crit_mages"
}
tt.initial_impulse = 15000
tt.initial_impulse_duration = 0.15
tt.initial_impulse_angle = math.pi / 3
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 300
tt.main_script.insert = kr3_scripts.bolt_elves.insert
tt.main_script.update = kr3_scripts.bolt_elves.update
tt.render.sprites[1].prefix = "bolt_elves"
tt.render.sprites[1].name = "travel"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset.y = -20
tt.render.sprites[2].animated = false
tt.sound_events.insert = "TowerWizardBasicBolt"

tt = E:register_t("bolt_elves_1", "bolt_elves")
tt.alter_reality_chance = 0.1
tt.alter_reality_mod = "mod_teleport_mage"
tt.bullet.damage_min = 4
tt.bullet.damage_max = 6
tt.bullet.particles_name = "ps_bolt_elves_1"
tt.render.sprites[1].scale = v(0.8, 0.8)

tt = E:register_t("bolt_elves_2", "bolt_elves_1")
tt.bullet.damage_min = 9
tt.bullet.damage_max = 15
tt.bullet.particles_name = "ps_bolt_elves_2"
tt.render.sprites[1].scale = v(0.9, 0.9)

tt = E:register_t("bolt_elves_3", "bolt_elves_1")
tt.bullet.damage_min = 17
tt.bullet.damage_max = 28
tt.bullet.particles_name = "ps_bolt_elves_3"
tt.render.sprites[1].scale = v(1, 1)

tt = E:register_t("bolt_wild_magus", "bolt")
E:add_comps(tt, "tween")

tt.alter_reality_chance = 0.1
tt.alter_reality_mod = "mod_teleport_wild_magus"
tt.render.sprites[1].prefix = "bolt_wild_magus"
tt.bullet.damage_max = 16
tt.bullet.damage_min = 8
tt.bullet.damage_same_target_inc = 0.5
tt.bullet.damage_same_target_max = 24
tt.bullet.acceleration_factor = 0.25
tt.bullet.min_speed = 30
tt.bullet.max_speed = 2100
tt.bullet.hit_fx = "fx_wild_magus_hit"
tt.bullet.particles_name = "ps_bolt_wild_magus"
tt.sound_events.insert = "TowerWildMagusBoltcast"
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(4),
		255
	}
}

tt = E:register_t("ray_wild_magus", "bullet")
tt.image_width = 144
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].name = "ray_wild_magus"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.bullet.mod = "mod_eldritch"
tt.bullet.hit_fx = "fx_ray_wild_magus_hit"
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_time = fts(2)
tt.track_target = true

tt = E:register_t("tower_mage_1", "tower_KR5")
E:add_comps(tt, "attacks", "tween", "nav_grid", "vis", "motion", "nav_rally")

tt.tower.type = "mobile_mage"
tt.tower.kind = TOWER_KIND_MAGE
tt.tower.team = TEAM_LINIREA
tt.tower.level = 1
tt.tower.price = 0
tt.tower.can_be_sold = false
tt.tower.menu_offset = v(0, 25)
tt.info.portrait = "portraits_towers_0112"
tt.info.fn = scripts.tower_mage.get_info
tt.main_script.insert = customScripts1.mobile_tower_mage.insert
tt.main_script.update = customScripts1.mobile_tower_mage.update
tt.motion.max_speed = 50
tt.nav_rally.delay_max = nil
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
tt.attacks.range = 140
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "bolt_elves_1"
tt.attacks.list[1].cooldown = 1.5
tt.attacks.list[1].shoot_time = fts(19)
tt.attacks.list[1].bullet_start_offset = {
	v(8, 68),
	v(-8, 68)
}
tt.attacks.list[1].loops = 2
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "mage_proy_0025"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "mage_towers_layer1_0001"
tt.render.sprites[2].offset = v(0, 36)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "tower_mage_1_platform"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].offset = v(0, 36)
tt.render.sprites[3].angles = {}
tt.render.sprites[3].angles.walk = {
	"shoot"
}
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "tower_mage_shooter"
tt.render.sprites[4].name = "idleDown"
tt.render.sprites[4].angles = {}
tt.render.sprites[4].angles.idle = {
	"idleUp",
	"idleDown"
}
tt.render.sprites[4].angles.walk = {
	"idleDown",
	"idleUp",
	"idleDown"
}
tt.render.sprites[4].angles.shoot = {
	"shootingUp",
	"shootingDown"
}
tt.render.sprites[4].anchor.y = 0
tt.render.sprites[4].offset = v(2, 35)
tt.render.sid_tower = 3
tt.render.sid_shooter = 4
tt.sound_events.mute_on_level_insert = true
tt.sound_events.insert = "ElvesMageTaunt"
tt.sound_events.change_rally_point = "ElvesMageTaunt"
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 35)
	},
	{
		1,
		v(0, 37)
	},
	{
		2,
		v(0, 35)
	}
}
tt.tween.props[1].sprite_id = 3
tt.tween.props[1].loop = true
tt.tween.props[1].ts = 0
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {
	{
		0,
		v(2, 34)
	},
	{
		1,
		v(2, 36)
	},
	{
		2,
		v(2, 34)
	}
}
tt.tween.props[2].sprite_id = 4
tt.tween.props[2].loop = true
tt.tween.props[2].ts = 0

tt = E:register_t("tower_mage_2", "tower_mage_1")
tt.tower.level = 2
tt.tower.price = 160
tt.attacks.list[1].bullet = "bolt_elves_2"
tt.attacks.list[1].bullet_start_offset = {
	v(10, 58),
	v(-10, 58)
}
tt.attacks.list[1].cooldown = 1.5
tt.attacks.range = 160
tt.render.sprites[2].name = "mage_towers_layer1_0001"
tt.render.sprites[3].prefix = "tower_mage_2_platform"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 37)
	},
	{
		1,
		v(0, 39)
	},
	{
		2,
		v(0, 37)
	}
}
tt.tween.props[2].keys = {
	{
		0,
		v(2, 38)
	},
	{
		1,
		v(2, 40)
	},
	{
		2,
		v(2, 38)
	}
}

tt = E:register_t("tower_mage_3", "tower_mage_1")
tt.tower.level = 3
tt.tower.price = 250
tt.attacks.list[1].bullet = "bolt_elves_3"
tt.attacks.list[1].bullet_start_offset = {
	v(10, 60),
	v(-10, 60)
}
tt.attacks.list[1].cooldown = 1.5
tt.attacks.range = 180
tt.render.sprites[2].name = "mage_towers_layer1_0001"
tt.render.sprites[3].prefix = "tower_mage_3_platform"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 39)
	},
	{
		1,
		v(0, 41)
	},
	{
		2,
		v(0, 39)
	}
}
tt.tween.props[2].keys = {
	{
		0,
		v(2, 42)
	},
	{
		1,
		v(2, 44)
	},
	{
		2,
		v(2, 42)
	}
}

tt = E:register_t("tower_wild_magus", "tower_KR5")
b = balance.towers.wild_magus
E:add_comps(tt, "attacks", "powers", "tween", "nav_grid", "vis", "motion", "nav_rally")
tt.info.i18n_key = "TOWER_MAGE_WILD_MAGUS"
tt.info.portrait = "portraits_towers_0113"
tt.info.fn = scripts.tower_mage.get_info
tt.main_script.insert = customScripts1.mobile_tower_mage.insert
tt.main_script.update = kr3_scripts.tower_wild_magus.update
tt.motion.max_speed = 50
tt.nav_rally.delay_max = nil
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
tt.tower.type = "wild_magus"
tt.tower.kind = TOWER_KIND_MAGE
tt.tower.team = TEAM_LINIREA
tt.tower.level = 1
tt.tower.price = 300
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = v(0, 25)
tt.tower.can_be_sold = false
tt.attacks.range = 180
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].animations = {
	"shoot_rh",
	"shoot_lh"
}
tt.attacks.list[1].bullet = "bolt_wild_magus"
tt.attacks.list[1].bullet_start_offset = {
	{
		v(10, 42),
		v(4, 24)
	},
	{
		v(-6, 38),
		v(12, 26)
	}
}
tt.attacks.list[1].cooldown = 0.3
tt.attacks.list[1].shoot_time = fts(4)
tt.attacks.list[1].max_interval = 1
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[2] = E:clone_c("bullet_attack")
tt.attacks.list[2].animation = "ray"
tt.attacks.list[2].bullet = "ray_wild_magus"
tt.attacks.list[2].bullet_start_offset = {
	v(0, 38),
	v(0, 32)
}
tt.attacks.list[2].cooldown = 28
tt.attacks.list[2].shoot_time = fts(20)
tt.attacks.list[2].sound = "TowerWildMagusDoomCast"
tt.attacks.list[2].vis_flags = bor(F_RANGED, F_INSTAKILL)
tt.attacks.list[2].vis_bans = bor(F_BOSS, F_MINIBOSS, F_NIGHTMARE)
tt.attacks.list[3] = E:clone_c("spell_attack")
tt.attacks.list[3].range = 225
tt.attacks.list[3].cooldown = b.ward.cooldown
tt.attacks.list[3].spell = {
	"mod_ward",
	"mod_ward_dps"
}
tt.attacks.list[3].animation = "ward"
tt.attacks.list[3].cast_time = fts(14)
tt.attacks.list[3].vis_bans = bor(F_BOSS, F_CLIFF, F_NIGHTMARE)
tt.attacks.list[3].vis_flags = bor(F_RANGED)
tt.attacks.list[3].sound = "TowerWildMagusDisruptionCast"
tt.powers.eldritch = E:clone_c("power")
tt.powers.eldritch.attack_idx = 2
tt.powers.eldritch.price = { 300, 175, 175 }
tt.powers.eldritch.cooldowns = b.eldritch.cooldowns
tt.powers.ward = E:clone_c("power")
tt.powers.ward.attack_idx = 3
tt.powers.ward.price = { 200, 200, 200 }
tt.powers.ward.target_count = {
	1,
	3,
	6
}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "mage_proy_0025"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "mage_towers_layer1_0097"
tt.render.sprites[2].offset = v(0, 36)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "mage_towers_layer2_0097"
tt.render.sprites[3].offset = v(0, 36)
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "tower_wild_magus_shooter"
tt.render.sprites[4].name = "idleDown"
tt.render.sprites[4].angles = {}
tt.render.sprites[4].angles.idle = {
	"idleUp",
	"idleDown"
}
tt.render.sprites[4].angles.walk = {
	"idleDown",
	"idleUp",
	"idleDown"
}
tt.render.sprites[4].angles.shoot_rh = {
	"rh_shootUp",
	"rh_shootDown"
}
tt.render.sprites[4].angles.shoot_lh = {
	"lh_shootUp",
	"lh_shootDown"
}
tt.render.sprites[4].angles.ray = {
	"rayUp",
	"rayDown"
}
tt.render.sprites[4].angles.ward = {
	"wardUp",
	"wardDown"
}
tt.render.sprites[4].anchor.y = 0
tt.render.sprites[4].offset = v(2, 22)
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].name = "mage_wild_shooter_0167"
tt.render.sprites[5].animated = false
tt.render.sprites[5].anchor.y = 0
tt.render.sprites[5].hidden = true
tt.render.sprites[5].offset = v(0, 22)
tt.render.sprites[6] = table.deepclone(tt.render.sprites[5])
tt.render.sprites[6].name = "mage_wild_shooter_0168"
tt.render.sprites[7] = E:clone_c("sprite")
tt.render.sprites[7].name = "tower_wild_magus_ward_rune"
tt.render.sprites[7].anchor.y = 0
tt.render.sprites[7].animated = true
tt.render.sprites[7].offset = v(0, 22)
tt.render.sprites[7].hidden = true

for i = 1, 10 do
	local s = E:clone_c("sprite")

	s.name = string.format("mage_wild_stones_%04i", i)
	s.animated = false
	s.offset.y = 36
	s.sort_y_offset = i < 4 and 1 or -1
	tt.render.sprites[#tt.render.sprites + 1] = s
end

tt.render.sid_tower = 3
tt.render.sid_shooter = 4
tt.render.sid_rune = 7
tt.sound_events.insert = "ElvesMageWildMagusTaunt"
tt.sound_events.change_rally_point = "ElvesMageWildMagusTaunt"
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 35)
	},
	{
		1,
		v(0, 37)
	},
	{
		2,
		v(0, 35)
	}
}
tt.tween.props[1].sprite_id = 3
tt.tween.props[1].loop = true
tt.tween.props[1].ts = 0
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {
	{
		0,
		v(0, 19)
	},
	{
		1,
		v(0, 21)
	},
	{
		2,
		v(0, 19)
	}
}
tt.tween.props[2].sprite_id = 4
tt.tween.props[2].loop = true
tt.tween.props[2].ts = 0
tt.tween.props[3] = table.deepclone(tt.tween.props[2])
tt.tween.props[3].sprite_id = 5
tt.tween.props[4] = table.deepclone(tt.tween.props[2])
tt.tween.props[4].sprite_id = 6
tt.tween.props[5] = table.deepclone(tt.tween.props[2])
tt.tween.props[5].sprite_id = 7
tt.tween.props[6] = E:clone_c("tween_prop")
tt.tween.props[6].keys = {
	{
		0,
		0
	},
	{
		fts(2),
		0
	},
	{
		fts(16),
		255
	},
	{
		fts(25),
		255
	},
	{
		fts(30),
		0
	}
}
tt.tween.props[6].sprite_id = 5
tt.tween.props[7] = table.deepclone(tt.tween.props[6])
tt.tween.props[7].sprite_id = 6

for i = 1, 10 do
	local t = E:clone_c("tween_prop")

	t.sprite_id = tt.render.sid_rune + i
	t.name = "offset"
	t.keys = {
		{
			0,
			v(0, 35)
		},
		{
			1,
			v(0, 37)
		},
		{
			2,
			v(0, 35)
		}
	}
	t.ts = math.random()
	t.loop = true
	tt.tween.props[#tt.tween.props + 1] = t
end

tt = E:register_t("tower_high_elven", "tower_KR5")
b = balance.towers.high_elven
E:add_comps(tt, "attacks", "powers", "tween", "vis")
tt.info.fn = kr3_scripts.tower_high_elven.get_info
tt.info.i18n_key = "TOWER_MAGE_HIGH_ELVEN"
tt.info.portrait = "portraits_towers_0137"
tt.main_script.update = kr3_scripts.tower_high_elven.update
tt.main_script.remove = kr3_scripts.tower_high_elven.remove
tt.tower.type = "high_elven"
tt.tower.kind = TOWER_KIND_MAGE
tt.tower.team = TEAM_LINIREA
tt.tower.level = 1
tt.tower.price = 300
tt.tower.size = TOWER_SIZE_LARGE
tt.attacks.range = 180
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "bolt_high_elven_strong"
tt.attacks.list[1].bullets = {
	"bolt_high_elven_strong",
	"bolt_high_elven_weak",
	"bolt_high_elven_weak"
}
tt.attacks.list[1].bullet_start_offset = v(0, 75)
tt.attacks.list[1].cooldown = 1.5
tt.attacks.list[1].shoot_time = fts(30)
tt.attacks.list[2] = E:clone_c("spell_attack")
tt.attacks.list[2].animation = "timelapse"
tt.attacks.list[2].spell = "mod_timelapse"
tt.attacks.list[2].cooldown = b.timelapse.cooldown
tt.attacks.list[2].shoot_time = fts(5)
tt.attacks.list[2].vis_flags = bor(F_RANGED)
tt.attacks.list[2].vis_bans = bor(F_BOSS, F_NIGHTMARE)
tt.attacks.list[2].sound = "TowerHighMageTimecast"
tt.attacks.list[3] = E:clone_c("custom_attack")
tt.powers.timelapse = E:clone_c("power")
tt.powers.timelapse.attack_idx = 2
tt.powers.timelapse.price = { 225, 225, 225 }
tt.powers.timelapse.target_count = {
	2,
	3,
	4
}
tt.powers.timelapse.duration = { 5, 7, 9 }
tt.powers.sentinel = E:clone_c("power")
tt.powers.sentinel.attack_idx = 3
tt.powers.sentinel.max_level = 2
tt.powers.sentinel.price = { 300, 300 }
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "mage_towers_layer1_0098"
tt.render.sprites[2].offset = v(0, 36)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "tower_high_elven_shooter"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {}
tt.render.sprites[3].angles.idle = {
	"idleUp",
	"idleDown"
}
tt.render.sprites[3].angles.shoot = {
	"shootUp",
	"shootDown"
}
tt.render.sprites[3].angles.timelapse = {
	"timeLapseUp",
	"timeLapseDown"
}
tt.render.sprites[3].anchor.y = 0
tt.render.sprites[3].offset = v(0, -5)
tt.render.sprites[3].draw_order = 5
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "mage_highElven_glow"
tt.render.sprites[4].animated = false
tt.render.sprites[4].offset = tt.render.sprites[2].offset
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.16,
		255
	},
	{
		0.42000000000000004,
		255
	},
	{
		0.68,
		0
	}
}
tt.tween.props[1].sprite_id = 4
tt.tween.props[1].ts = -10
tt.sound_events.insert = "ElvesMageHighElvenTaunt"

tt = E:register_t("high_elven_sentinel", "decal_scripted")
E:add_comps(tt, "force_motion", "ranged", "tween")
tt.charge_time = 4
tt.flight_height = 50
tt.force_motion.max_a = 135000
tt.force_motion.max_v = 450
tt.force_motion.ramp_radius = 10
tt.main_script.update = kr3_scripts.high_elven_sentinel.update
tt.owner = nil
tt.owner_idx = nil
tt.tower_rotation_speed = 7.5 * math.pi / 180 * 30
tt.tower_rotation_offset = v(0, -6)
tt.tower_rotation_radius = 20
tt.wait_time = 5
tt.wait_spent_time = 1
tt.particles_name = "ps_high_elven_sentinel"
tt.ranged.attacks[1].bullet = "ray_high_elven_sentinel"
tt.ranged.attacks[1].shoot_time = fts(9)
tt.ranged.attacks[1].cooldown = 0.5
tt.ranged.attacks[1].search_cooldown = 0.25
tt.ranged.attacks[1].shoot_range = 25
tt.ranged.attacks[1].launch_range = 300
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].bullet_start_offset = v(0, 0)
tt.ranged.attacks[1].vis_flags = F_RANGED
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].max_shots = 50
tt.render.sprites[1].prefix = "high_elven_sentinel"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].draw_order = 4
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].hidden = true
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		255
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		v(0.75, 1)
	},
	{
		fts(10),
		v(1, 1)
	}
}
tt.tween.props[2].name = "scale"

tt = E:register_t("fx_teleport_blue", "fx")
tt.render.sprites[1].name = "fx_teleport_blue"
tt.render.sprites[1].size_scales = {
	vv(0.83),
	vv(1.2),
	vv(1.3)
}

tt = E:register_t("fx_bolt_high_elven_weak_hit", "fx")
tt.render.sprites[1].name = "bolt_high_elven_weak_hit"

tt = E:register_t("fx_bolt_high_elven_strong_hit", "fx")
tt.render.sprites[1].name = "bolt_high_elven_strong_hit"

tt = E:register_t("bolt_high_elven_weak", "bolt_elves")
tt.alter_reality_chance = 0.03
tt.alter_reality_mod = "mod_teleport_high_elven"
tt.bullet.damage_max = 10
tt.bullet.damage_min = 5
tt.bullet.hit_fx = "fx_bolt_high_elven_weak_hit"
tt.bullet.particles_name = "ps_bolt_high_elven"
tt.bullet.pop = {
	"pop_mage"
}
tt.bullet.pop_mage_el_empowerment = {
	"pop_crit_high_elven"
}
tt.bullet.max_speed = 750
tt.render.sprites[1].prefix = "bolt_high_elven_weak"
tt.render.sprites[1].scale = v(0.8, 0.8)

tt = E:register_t("bolt_high_elven_strong", "bolt_elves")
tt.alter_reality_chance = 0.03
tt.alter_reality_mod = "mod_teleport_high_elven"
tt.bullet.align_with_trajectory = true
tt.bullet.damage_max = 54
tt.bullet.damage_min = 31
tt.bullet.hit_fx = "fx_bolt_high_elven_strong_hit"
tt.bullet.particles_name = "ps_bolt_high_elven"
tt.bullet.pop = {
	"pop_high_elven"
}
tt.bullet.pop_mage_el_empowerment = {
	"pop_crit_high_elven"
}
tt.bullet.max_speed = 750
tt.initial_impulse = nil
tt.render.sprites[1].prefix = "bolt_high_elven_strong"
tt.sound_events.insert = "TowerHighMageBoltCast"

tt = E:register_t("ray_high_elven_sentinel", "bullet")
tt.image_width = 72
tt.main_script.update = kr3_scripts.ray_simple.update
tt.render.sprites[1].name = "ray_high_elven_sentinel"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.bullet.mod = "mod_ray_high_elven_sentinel_hit"
tt.bullet.damage_min = 16
tt.bullet.damage_max = 32
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.hit_time = fts(4)
tt.sound_events.insert = "TowerHighMageSentinelShot"

tt = E:register_t("mod_timelapse", "modifier")
E:add_comps(tt, "render", "tween", "ranged")
tt.ranged.attacks[1].bullet = "ray_high_elven_sentinel"
tt.ranged.attacks[1].cooldown = 0.25
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].bullet_start_offset = v(0, 12)
tt.ranged.attacks[1].vis_flags = F_RANGED
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].disabled = true
tt.modifier.remove_banned = true
tt.modifier.bans = {
	"mod_faerie_dragon_l0",
	"mod_faerie_dragon_l1",
	"mod_faerie_dragon_l2",
	"mod_arivan_freeze",
	"mod_arivan_ultimate_freeze",
	"mod_crystal_arcane_freeze",
	"mod_blood_elves",
	"mod_bruce_sharp_claws",
	"mod_lynn_ultimate",
	"mod_ogre_magi_shield"
}
tt.modifier.type = MOD_TYPE_TIMELAPSE
tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.vis_bans = F_BOSS
tt.render.sprites[1].prefix = "mod_timelapse"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "mage_highElven_energyBall_shadow"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].anchor.y = 0.16666666666666666
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		0
	},
	{
		fts(15),
		255
	}
}
tt.tween.props[1].sprite_id = 2
tt.main_script.queue = kr3_scripts.mod_timelapse.queue
tt.main_script.dequeue = kr3_scripts.mod_timelapse.dequeue
tt.main_script.update = kr3_scripts.mod_timelapse.update
tt.main_script.insert = kr3_scripts.mod_timelapse.insert
tt.main_script.remove = kr3_scripts.mod_timelapse.remove
tt.damage_levels = {
	100,
	150,
	200
}
tt.damage_type = bor(DAMAGE_MAGICAL, DAMAGE_NO_KILL)
tt.modifier.duration = 5

tt = E:register_t("timelapse_enemy_decal", "decal_tween")
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.13,
		0
	}
}

tt = E:register_t("mod_ray_high_elven_sentinel_hit", "mod_track_target_fx")
tt.render.sprites[1].name = "fx_ray_high_elven_sentinel_hit"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt.modifier.duration = fts(11)

tt = E:register_t("ps_arrow_arcane_special")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "archer_arcane_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(10)
}
tt.particle_system.alphas = {
	255,
	0
}
tt.particle_system.scales_y = {
	1,
	0
}
tt.particle_system.emission_rate = 30

tt = E:register_t("ps_arrow_silver_mark")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.names = {
	"arrow_silver_mark_particle_1",
	"arrow_silver_mark_particle_2"
}
tt.particle_system.loop = false
tt.particle_system.cycle_names = true
tt.particle_system.animated = true
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(10)
}
tt.particle_system.scales_y = {
	0.85,
	0.85
}
tt.particle_system.scales_x = {
	0.85,
	0.85
}
tt.particle_system.emission_rate = 30

tt = E:register_t("fx_arrow_arcane_hit", "fx")
tt.render.sprites[1].name = "fx_arrow_arcane_hit"

tt = E:register_t("fx_arcane_slumber_explosion", "fx")
tt.render.sprites[1].name = "arcane_slumber_explosion"
tt.render.sprites[1].anchor.y = 0.32051282051282054

tt = E:register_t("aura_arcane_burst", "aura")
E:add_comps(tt, "render")
tt.aura.damage_inc = 80
tt.aura.damage_type = DAMAGE_MAGICAL
tt.aura.radius = 57.5
tt.main_script.update = kr3_scripts.aura_arcane_burst.update
tt.render.sprites[1].anchor.y = 0.2916666666666667
tt.render.sprites[1].name = "arcane_burst_explosion"
tt.render.sprites[1].sort_y_offset = -7
tt.render.sprites[1].z = Z_EFFECTS
tt.sound_events.insert = "TowerArcaneExplotion"

tt = E:register_t("fx_arrow_silver_mark_hit", "fx")
tt.render.sprites[1].name = "fx_arrow_silver_mark_hit"
tt.render.sprites[1].sort_y_offset = -20

tt = E:register_t("fx_arrow_silver_sentence_hit", "fx")
E:add_comps(tt, "sound_events")
tt.render.sprites[1].name = "fx_arrow_silver_sentence_hit"
tt.sound_events.insert = "TowerGoldenBowInstakill"

tt = E:register_t("fx_arrow_silver_sentence_shot", "fx")
tt.render.sprites[1].name = "fx_arrow_silver_sentence_shot"

tt = E:register_t("mod_arrow_arcane", "mod_damage")
tt.damage_min = 0.03
tt.damage_max = 0.03
tt.damage_type = DAMAGE_MAGICAL_ARMOR

tt = E:register_t("mod_arrow_arcane_slumber", "modifier")
E:add_comps(tt, "render")
tt.main_script.insert = kr3_scripts.mod_arrow_arcane_slumber.insert
tt.main_script.update = kr3_scripts.mod_stun.update
tt.main_script.remove = kr3_scripts.mod_stun.remove
tt.sound_events.insert = "TowerArcaneWaterEnergyBlast"
tt.modifier.duration = 6
tt.render.sprites[1].prefix = "arcane_slumber_bubbles"
tt.render.sprites[1].loop = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "arcane_slumber_z"
tt.render.sprites[2].loop = true

tt = E:register_t("mod_arrow_silver_mark", "modifier")
E:add_comps(tt, "tween", "render", "sound_events", "count_group")
tt.count_group.name = "mod_arrow_silver_mark"
tt.count_group.type = COUNT_GROUP_CONCURRENT
tt.received_damage_factor = 2
tt.main_script.insert = kr3_scripts.mod_arrow_silver_mark.insert
tt.main_script.update = kr3_scripts.mod_arrow_silver_mark.update
tt.main_script.remove = kr3_scripts.mod_arrow_silver_mark.remove
tt.modifier.durations = {
	5,
	10,
	15
}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "archer_silver_mark_effect_below"
tt.render.sprites[1].sort_y_offset = 10
tt.render.sprites[1].anchor.y = 0.08823529411764706
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "archer_silver_mark_effect_over"
tt.render.sprites[2].anchor.y = 0.08823529411764706
tt.render.sprites[2].sort_y_offset = 10
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		v(1, 1)
	},
	{
		fts(6),
		v(0.87, 1)
	},
	{
		fts(11),
		v(1, 1)
	}
}
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].loop = true
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].disabled = true
tt.tween.props[3].sprite_id = 1
tt.tween.props[3].keys = {
	{
		0,
		255
	},
	{
		0.25,
		0
	}
}
tt.tween.props[4] = table.deepclone(tt.tween.props[3])
tt.tween.props[4].sprite_id = 1
tt.sound_events.insert = "TowerGoldenBowFlareHit"

tt = E:register_t("elven_arrow_1", "arrow")
tt.bullet.damage_min = 2
tt.bullet.damage_max = 5
tt.bullet.flight_time_min = fts(11)
tt.bullet.flight_time_factor = fts(5) * 2
tt.bullet.pop = {
	"pop_archer"
}

tt = E:register_t("elven_arrow_2", "elven_arrow_1")
tt.bullet.damage_min = 4
tt.bullet.damage_max = 9

tt = E:register_t("elven_arrow_3", "elven_arrow_1")
tt.bullet.damage_min = 5
tt.bullet.damage_max = 11

tt = E:register_t("arrow_arcane", "elven_arrow_1")
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_max = 19
tt.bullet.damage_min = 12
tt.bullet.miss_decal = "archer_arcane_proy2_decal-f"
tt.bullet.mod = {
	"mod_arrow_arcane"
}
tt.bullet.hit_fx = "fx_arrow_arcane_hit"
tt.bullet.pop = {
	"pop_arcane"
}
tt.render.sprites[1].name = "archer_arcane_proy2_0001-f"

tt = E:register_t("arrow_arcane_burst", "arrow_arcane")
tt.bullet.flight_time_min = fts(21)
tt.bullet.miss_decal = "archer_arcane_proy_decal-f"
tt.bullet.mod = {
	"mod_arrow_arcane"
}
tt.bullet.particles_name = "ps_arrow_arcane_special"
tt.bullet.payload = "aura_arcane_burst"
tt.render.sprites[1].name = "archer_arcane_proy_0001-f"
tt.sound_events.insert = "TowerArcanePreloadAndTravel"

tt = E:register_t("arrow_arcane_slumber", "arrow_arcane")
tt.bullet.flight_time_min = fts(21)
tt.bullet.miss_decal = "archer_arcane_proy2_decal-f"
tt.bullet.hit_fx = "fx_arcane_slumber_explosion"
tt.bullet.mod = {
	"mod_arrow_arcane_slumber"
}
tt.bullet.particles_name = "ps_arrow_arcane_special"
tt.render.sprites[1].name = "archer_arcane_proy_0001-f"
tt.sound_events.insert = "TowerArcanePreloadAndTravel"

tt = E:register_t("arrow_silver", "elven_arrow_1")
tt.bullet.flight_time_min = fts(9)
tt.bullet.flight_time_factor = fts(0.016666666666666666)
tt.bullet.miss_decal = "archer_silver_proys_0002-f"
tt.bullet.damage_max = 28
tt.bullet.damage_min = 23
tt.bullet.pop = {
	"pop_golden"
}
tt.bullet.pop_conds = DR_KILL
tt.render.sprites[1].name = "archer_silver_proys_0001-f"
tt.sound_events.insert = "TowerGoldenBowArrowShot"

tt = E:register_t("arrow_silver_long", "arrow_silver")
tt.bullet.flight_time_factor = fts(0.08333333333333333)
tt.bullet.damage_max = 75
tt.bullet.damage_min = 60

tt = E:register_t("arrow_silver_sentence", "arrow_silver")
tt.render.sprites[1].name = "archer_silver_instaKill_bullet"
tt.bullet.g = 0
tt.bullet.hit_fx = "fx_arrow_silver_sentence_hit"
tt.bullet.flight_time_min = fts(4)
tt.bullet.flight_time_factor = fts(0.03333333333333333)
tt.bullet.damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_FX_NOT_EXPLODE)
tt.bullet.prediction_error = false
tt.bullet.pop = {
	"pop_headshot"
}
tt.bullet.pop_conds = DR_KILL

tt = E:register_t("arrow_silver_sentence_long", "arrow_silver_sentence")

tt = E:register_t("arrow_silver_mark", "arrow_silver")
tt.bullet.damage_max = 40
tt.bullet.damage_min = 40
tt.bullet.damage_type = bor(DAMAGE_MAGICAL)
tt.bullet.hit_fx = "fx_arrow_silver_mark_hit"
tt.bullet.mod = "mod_arrow_silver_mark"
tt.bullet.particles_name = "ps_arrow_silver_mark"
tt.bullet.miss_decal = "archer_silver_proys_0004-f"
tt.render.sprites[1].name = "archer_silver_proys_0003-f"
tt.sound_events.insert = nil

tt = E:register_t("arrow_silver_mark_long", "arrow_silver_mark")
tt.bullet.flight_time_factor = fts(0.08333333333333333)
tt.bullet.damage_max = 118
tt.bullet.damage_min = 118

tt = E:register_t("tower_elven_archer_1", "tower_KR5")
E:add_comps(tt, "attacks", "vis")
tt.tower.type = "elven_archer"
tt.tower.level = 1
tt.tower.price = 70
tt.info.portrait = "portraits_towers_0134"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "archer_towers_0001"
tt.render.sprites[2].offset = v(0, 33)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "tower_archer_shooter"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {}
tt.render.sprites[3].angles.idle = {
	"idleUp",
	"idleDown"
}
tt.render.sprites[3].angles.shoot = {
	"shootingUp",
	"shootingDown"
}
tt.render.sprites[3].offset = v(0, 42)
tt.main_script.insert = kr3_scripts.tower_archer.insert
tt.main_script.update = kr3_scripts.tower_archer.update
tt.main_script.remove = kr3_scripts.tower_archer.remove
tt.attacks.range = 160
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].bullet = "elven_arrow_1"
tt.attacks.list[1].cooldown = 0.7
tt.attacks.list[1].shoot_time = fts(5)
tt.attacks.list[1].bullet_start_offset = {
	v(0, 44)
}
tt.sound_events.insert = "ElvesArcherTaunt"

tt = E:register_t("tower_elven_archer_2", "tower_elven_archer_1")
tt.tower.level = 1
tt.tower.price = 60
tt.render.sprites[2].name = "archer_towers_0002"
tt.render.sprites[3].offset = v(-14, 43)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[4].offset = v(16, 48)
tt.attacks.range = 180
tt.attacks.list[1].bullet = "elven_arrow_2"
tt.attacks.list[1].bullet_start_offset = {
	v(-14, 45),
	v(16, 50)
}
tt.attacks.list[1].cooldown = 0.6

tt = E:register_t("tower_elven_archer_3", "tower_elven_archer_1")
tt.tower.level = 2
tt.tower.price = 160
tt.tower.size = TOWER_SIZE_LARGE
tt.render.sprites[2].name = "archer_towers_0003"
tt.render.sprites[3].offset = v(-14, 42)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[4].offset = v(-3, 62)
tt.render.sprites[5] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[5].offset = v(16, 49)
tt.attacks.range = 200
tt.attacks.list[1].bullet = "elven_arrow_3"
tt.attacks.list[1].bullet_start_offset = {
	v(-14, 44),
	v(-3, 64),
	v(16, 51)
}
tt.attacks.list[1].cooldown = 0.4

tt = E:register_t("tower_arcane_archer", "tower_KR5")
b = balance.towers.arcane_archer
E:add_comps(tt, "attacks", "powers", "vis")
image_y = 90
tt.tower.type = "arcane_archer"
tt.tower.level = 1
tt.tower.price = 230
tt.tower.size = TOWER_SIZE_LARGE
tt.info.fn = kr3_scripts.tower_arcane.get_info
tt.info.portrait = "portraits_towers_0135"
tt.info.damage_icon = "magic"
tt.powers.burst = E:clone_c("power")
tt.powers.burst.price = { 200, 200, 200 }
tt.powers.burst.attack_idx = 2
tt.powers.slumber = E:clone_c("power")
tt.powers.slumber.price = { 180, 120, 120 }
tt.powers.slumber.attack_idx = 3
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "archer_towers_0004"
tt.render.sprites[2].offset = v(0, 33)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "tower_arcane_shooter"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {}
tt.render.sprites[3].angles.idle = {
	"idleUp",
	"idleDown"
}
tt.render.sprites[3].angles.shoot = {
	"shootUp",
	"shootDown"
}
tt.render.sprites[3].angles.special = {
	"specialUp",
	"specialDown"
}
tt.render.sprites[3].offset = v(-9, 57)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[4].offset.x = 9
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].animated = false
tt.render.sprites[5].name = "archer_arcane_top"
tt.render.sprites[5].offset = v(0, 33)
tt.render.sprites[6] = E:clone_c("sprite")
tt.render.sprites[6].name = "tower_arcane_bubbles"
tt.render.sprites[6].offset = v(-15, 17)
tt.render.sprites[7] = table.deepclone(tt.render.sprites[6])
tt.render.sprites[7].offset.x = 13
tt.render.sprites[7].ts = fts(15)
tt.main_script.insert = kr3_scripts.tower_arcane.insert
tt.main_script.update = kr3_scripts.tower_arcane.update
tt.attacks.range = 200
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "arrow_arcane"
tt.attacks.list[1].cooldown = 0.8
tt.attacks.list[1].shoot_time = fts(4)
tt.attacks.list[1].shooters_delay = 0.1
tt.attacks.list[1].bullet_start_offset = {
	v(9, 4),
	v(6, -5)
}
tt.attacks.list[2] = table.deepclone(tt.attacks.list[1])
tt.attacks.list[2].animation = "special"
tt.attacks.list[2].bullet = "arrow_arcane_burst"
tt.attacks.list[2].cooldown = b.burst.cooldown
tt.attacks.list[2].cooldown_inc = 0
tt.attacks.list[2].shoot_time = fts(13)
tt.attacks.list[3] = table.deepclone(tt.attacks.list[1])
tt.attacks.list[3].animation = "special"
tt.attacks.list[3].cooldown = b.slumber.cooldown
tt.attacks.list[3].cooldown_inc = -4
tt.attacks.list[3].bullet = "arrow_arcane_slumber"
tt.attacks.list[3].shoot_time = fts(13)
tt.attacks.list[3].vis_bans = bor(F_BOSS, F_NIGHTMARE)
tt.attacks.list[3].vis_flags = bor(F_STUN)
tt.sound_events.insert = "ElvesArcherArcaneTaunt"

tt = E:register_t("tower_silver", "tower_KR5")
b = balance.towers.silver
E:add_comps(tt, "attacks", "powers", "vis")
image_y = 90
tt.tower.type = "silver"
tt.tower.level = 1
tt.tower.price = 275
tt.tower.size = TOWER_SIZE_LARGE
tt.attacks.range = 300
tt.attacks.short_range = 162.5
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].animations = {
	"shoot",
	"shoot_long"
}
tt.attacks.list[1].bullet = "arrow_silver_long"
tt.attacks.list[1].bullets = {
	"arrow_silver",
	"arrow_silver_long"
}
tt.attacks.list[1].cooldowns = {
	0.7,
	1.5
}
tt.attacks.list[1].cooldown = 0.7
tt.attacks.list[1].critical_chances = {
	0.12,
	0.12
}
tt.attacks.list[1].shoot_times = {
	fts(6),
	fts(15)
}
tt.attacks.list[1].bullet_start_offsets = {
	{
		v(9, 4),
		v(6, -5)
	},
	{
		v(9, 4),
		v(6, -5)
	}
}
tt.attacks.list[1].use_obsidian_upgrade = true
tt.attacks.list[2] = E:clone_c("bullet_attack")
tt.attacks.list[2].animations = {
	"sentence",
	"sentence"
}
tt.attacks.list[2].bullets = {
	"arrow_silver_sentence",
	"arrow_silver_sentence_long"
}
tt.attacks.list[2].chance = 0
tt.attacks.list[2].cooldowns = {
	0.7,
	1.25
}
tt.attacks.list[2].cooldown = 0.7
tt.attacks.list[2].shoot_times = {
	fts(13),
	fts(13)
}
tt.attacks.list[2].bullet_start_offsets = {
	{
		v(9, 4),
		v(6, -5)
	},
	{
		v(9, 4),
		v(6, -5)
	}
}
tt.attacks.list[2].vis_flags = bor(F_RANGED, F_INSTAKILL)
tt.attacks.list[2].vis_bans = bor(F_BOSS, F_MINIBOSS, F_NIGHTMARE)
tt.attacks.list[2].shot_fx = "fx_arrow_silver_sentence_shot"
tt.attacks.list[2].sound = "TowerGoldenBowInstakillArrowShot"
tt.attacks.list[2].use_obsidian_upgrade = true
tt.attacks.list[3] = E:clone_c("bullet_attack")
tt.attacks.list[3].animations = {
	"mark",
	"mark_long"
}
tt.attacks.list[3].cooldown = b.mark.cooldown
tt.attacks.list[3].bullets = {
	"arrow_silver_mark",
	"arrow_silver_mark_long"
}
tt.attacks.list[3].bullet_start_offsets = {
	{
		v(9, 4),
		v(6, -5)
	},
	{
		v(9, 4),
		v(6, -5)
	}
}
tt.attacks.list[3].shoot_times = {
	fts(21),
	fts(21)
}
tt.attacks.list[3].sound = "TowerGoldenBowFlareShot"
tt.attacks.list[3].sound_args = {
	delay = fts(15)
}
tt.attacks.list[3].vis_bans = bor(F_BOSS, F_NIGHTMARE)
tt.attacks.list[3].use_obsidian_upgrade = true
tt.info.portrait = "portraits_towers_0136"
tt.info.fn = kr3_scripts.tower_silver.get_info
tt.powers.sentence = E:clone_c("power")
tt.powers.sentence.attack_idx = 2
tt.powers.sentence.price = { 250, 250, 250 }
tt.powers.sentence.chances = {
	{
		0.03,
		0.06,
		0.09
	},
	{
		0.03,
		0.06,
		0.09
	}
}
tt.powers.mark = E:clone_c("power")
tt.powers.mark.attack_idx = 3
tt.powers.mark.price = { 200, 200, 200 }
tt.powers.mark.damage = { 40, 60, 80 }
tt.powers.mark.damage_long = { 118, 177, 236 }
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "archer_towers_0005"
tt.render.sprites[2].offset = v(0, 33)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "tower_silver_shooter"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {}
tt.render.sprites[3].angles.idle = {
	"idleUp",
	"idleDown"
}
tt.render.sprites[3].angles.shoot = {
	"shootShortUp",
	"shootShortDown"
}
tt.render.sprites[3].angles.shoot_long = {
	"shootUp",
	"shootDown"
}
tt.render.sprites[3].angles.mark = {
	"shootSpecialShortUp",
	"shootSpecialShortDown"
}
tt.render.sprites[3].angles.mark_long = {
	"shootSpecialUp",
	"shootSpecialDown"
}
tt.render.sprites[3].angles.sentence = {
	"instakillUp",
	"instakillDown"
}
tt.render.sprites[3].offset = v(0, 62)
tt.main_script.update = kr3_scripts.tower_silver.update
tt.sound_events.insert = "ElvesArcherGoldenBowTaunt"

tt = E:register_t("fx_bullet_pixie_instakill_hit_big", "fx")
E:add_comps(tt, "sound_events")
tt.render.sprites[1].anchor.y = 0.11764705882352941
tt.render.sprites[1].name = "fx_bullet_pixie_instakill_hit"
tt.sound_events.insert = "BombExplosionSound"

tt = E:register_t("fx_bullet_pixie_instakill_hit_small", "fx_bullet_pixie_instakill_hit_big")
tt.render.sprites[1].scale = vv(0.8)

tt = E:register_t("fx_bullet_pixie_poison_hit_big", "fx")
E:add_comps(tt, "sound_events")
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].name = "fx_bullet_pixie_poison_hit"
tt.sound_events.insert = "ElvesGnomePoison"

tt = E:register_t("fx_bullet_pixie_poison_hit_small", "fx_bullet_pixie_poison_hit_big")
tt.render.sprites[1].scale = vv(0.8)

tt = E:register_t("fx_mod_pixie_polymorph_big", "fx")
E:add_comps(tt, "sound_events")
tt.render.sprites[1].anchor.y = 0.11764705882352941
tt.render.sprites[1].name = "fx_mod_pixie_polymorph"
tt.sound_events.insert = "ElvesGnomePolymorf"

tt = E:register_t("fx_mod_pixie_polymorph_small", "fx_mod_pixie_polymorph_big")
tt.render.sprites[1].scale = vv(0.8)

tt = E:register_t("fx_mod_pixie_teleport", "fx")
tt.render.sprites[1].prefix = "fx_mod_pixie_teleport"
tt.render.sprites[1].size_names = {
	"small",
	"small",
	"big"
}

tt = E:register_t("bullet_pixie_instakill", "arrow")
tt.bullet.flight_time = fts(12)
tt.bullet.rotation_speed = 45 * FPS * math.pi / 180
tt.bullet.damage_type = bor(DAMAGE_EAT, DAMAGE_NO_SPAWNS)
tt.bullet.ignore_hit_offset = true
tt.bullet.hit_blood_fx = nil
tt.bullet.hit_fx = "fx_bullet_pixie_instakill_hit_"
tt.bullet.pop = nil
tt.render.sprites[1].name = "pixie_mushroom"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "ElvesGnomeDesintegrate"

tt = E:register_t("bullet_pixie_poison", "bullet_pixie_instakill")
tt.bullet.mod = "mod_pixie_poison"
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_fx = "fx_bullet_pixie_poison_hit_"
tt.render.sprites[1].name = "pixie_bottle"
tt.sound_events.insert = nil

tt = E:register_t("mod_pixie_poison", "mod_poison")
tt.dps.damage_every = fts(5)
tt.dps.damage_max = 10
tt.dps.damage_min = 10
tt.modifier.duration = 3

tt = E:register_t("mod_pixie_polymorph", "mod_polymorph")
tt.polymorph.custom_entity_names.default = "enemy_rabbit"
tt.polymorph.hit_fx_sizes = {
	"fx_mod_pixie_polymorph_small",
	"fx_mod_pixie_polymorph_big",
	"fx_mod_pixie_polymorph_big"
}

tt = E:register_t("mod_pixie_pickpocket", "modifier")
E:add_comps(tt, "pickpocket")
tt.modifier.level = 0
tt.main_script.insert = kr3_scripts.mod_pixie_pickpocket.insert
tt.pickpocket.steal_min = {
	[0] = 1,
	2,
	3,
	4
}
tt.pickpocket.steal_max = {
	[0] = 3,
	4,
	5,
	6
}
tt.pickpocket.fx = "fx_coin_jump"
tt.pickpocket.pop = {
	"pop_faerie_steal"
}

tt = E:register_t("mod_pixie_teleport", "mod_teleport_mage")
E:add_comps(tt, "sound_events")
tt.max_times_applied = nil
tt.hold_time = fts(10)
tt.nodes_offset = -50
tt.fx_start = "fx_mod_pixie_teleport"
tt.fx_end = "fx_mod_pixie_teleport"
tt.sound_events.insert = "ElvesGnomeTeleport"

tt = E:register_t("tower_pixie", "tower_KR5")
E:add_comps(tt, "powers", "attacks", "vis")
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet_start_offset = v(10, 21)
tt.attacks.list[1].bullet = "bullet_pixie_instakill"
tt.attacks.list[1].vis_bans = bor(F_BOSS, F_MINIBOSS, F_NIGHTMARE)
tt.attacks.list[1].vis_flags = bor(F_RANGED, F_STUN, F_INSTAKILL)
tt.attacks.list[1].chance = 0
tt.attacks.list[2] = table.deepclone(tt.attacks.list[1])
tt.attacks.list[2].animation = "shoot"
tt.attacks.list[2].bullet = "bullet_pixie_poison"
tt.attacks.list[2].vis_flags = bor(F_RANGED, F_STUN, F_POISON)
tt.attacks.list[2].chance = 0
tt.attacks.list[3] = E:clone_c("mod_attack")
tt.attacks.list[3].animation = "attack"
tt.attacks.list[3].mod = "mod_pixie_polymorph"
tt.attacks.list[3].vis_bans = bor(F_FLYING, F_BOSS, F_MINIBOSS, F_NIGHTMARE)
tt.attacks.list[3].vis_flags = bor(F_RANGED, F_STUN, F_POLYMORPH)
tt.attacks.list[3].chance = 0.2
tt.attacks.list[4] = E:clone_c("mod_attack")
tt.attacks.list[4].animation = "harvester"
tt.attacks.list[4].mod = "mod_pixie_pickpocket"
tt.attacks.list[4].vis_bans = bor(F_BOSS, F_NIGHTMARE)
tt.attacks.list[4].vis_flags = bor(F_RANGED, F_STUN)
tt.attacks.list[4].chance = 0.8
tt.attacks.list[4].check_gold_bag = true
tt.attacks.list[5] = E:clone_c("mod_attack")
tt.attacks.list[5].animation = "attack"
tt.attacks.list[5].mod = "mod_pixie_teleport"
tt.attacks.list[5].vis_bans = bor(F_BOSS, F_NIGHTMARE)
tt.attacks.list[5].vis_flags = bor(F_RANGED, F_STUN, F_TELEPORT)
tt.attacks.list[5].chance = 0
tt.attacks.hide_range = true
tt.attacks.range = 190
tt.attacks.cooldown = fts(10)
tt.attacks.enemy_cooldown = 3
tt.attacks.pixie_cooldown = 5
tt.attacks.excluded_templates = {
	"enemy_rabbit"
}
tt.info.i18n_key = "ELVES_TOWER_PIXIE"
tt.info.fn = kr3_scripts.tower_pixie.get_info
tt.info.portrait = "portraits_towers_0130"
tt.main_script.update = kr3_scripts.tower_pixie.update
tt.main_script.remove = kr3_scripts.tower_pixie.remove
tt.powers.cream = E:clone_c("power")
tt.powers.cream.price = { 200, 200 }
tt.powers.cream.max_level = 2
tt.powers.cream.idle_offsets = {
	v(-18, 9),
	v(21, 7),
	v(5, -1)
}
tt.powers.total = E:clone_c("power")
tt.powers.total.price = { 150, 150, 150 }
tt.powers.total.max_level = 3
tt.powers.total.chances = {
	{
		0,
		0,
		0.2
	},
	{
		0.2,
		0.2,
		0.2
	},
	{
		0.2,
		0.2,
		0.2
	},
	{
		0.6,
		0.4,
		0.2
	},
	{
		0,
		0.2,
		0.2
	}
}
tt.powers.plant_poison = E:clone_c("power")
tt.powers.plant_poison.max_level = 1
tt.powers.plant_poison.price = { 200 }
tt.powers.plant_poison.pos = {
	v(-47, -18),
	v(47, -18),
	v(-62, 24),
	v(62, 24)
}
tt.powers.plant_poison.template = "plant_poison_pumpkin"
tt.powers.plant_poison.plants = {}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "pixie_tower"
tt.render.sprites[2].offset = v(0, 25)
tt.render.sprites[2].sort_y_offset = 25
tt.sound_events.insert = nil
tt.tower.menu_offset = v(0, 16)
tt.tower.price = 0
tt.tower.type = "pixie"
tt.tower.kind = TOWER_KIND_MAGE
tt.tower.team = TEAM_LINIREA

tt = E:register_t("decal_pixie", "decal_scripted")
E:add_comps(tt, "idle_flip", "soldier", "unit")
tt.idle_flip.animations = {
	"idle",
	"scratch"
}
tt.idle_flip.cooldown = fts(90)
tt.idle_flip.loop = false
tt.main_script.update = kr3_scripts.decal_pixie.update
tt.render.sprites[1].prefix = "decal_pixie"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.09090909090909091
tt.soldier.melee_slot_offset = v(0, 0)
tt.attack_ts = 0
tt.target_id = nil
tt.attack = nil
tt.attack_level = nil

tt = E:register_t("fx_plant_poison_pumpkin_idle", "decal")
tt.render.sprites[1].name = "fx_plant_poison_pumpkin_particles"
tt.render.sprites[1].draw_order = 10

tt = E:register_t("fx_plant_poison_pumpkin_smoke_left", "fx")
tt.render.sprites[1].name = "fx_plant_poison_pumpkin_smoke_left"

tt = E:register_t("fx_plant_poison_pumpkin_smoke_down", "fx")
tt.render.sprites[1].name = "fx_plant_poison_pumpkin_smoke_down"

tt = E:register_t("fx_plant_poison_pumpkin_smoke_fill", "decal_tween")
tt.render.sprites[1].name = "plant_venom_smoke_fill"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		46
	},
	{
		fts(28),
		46
	},
	{
		fts(43),
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		v(0.5, 0.5)
	},
	{
		fts(43),
		v(1, 1)
	}
}
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "offset"
tt.tween.props[3].keys = {
	{
		0,
		v(0, 0)
	},
	{
		fts(28),
		v(20, 8)
	},
	{
		fts(43),
		v(26, 14)
	}
}

tt = E:register_t("mod_plant_poison_pumpkin_slow", "mod_slow")
tt.modifier.duration = 4
tt.slow.factor = 0.5

tt = E:register_t("mod_plant_poison_pumpkin", "mod_poison")
tt.render.sprites[1].prefix = "poison_violet"
tt.render.sprites[1].size_names = {
	"small",
	"medium",
	"big"
}
tt.modifier.duration = 4
tt.dps.damage_min = 4
tt.dps.damage_max = 4
tt.dps.kill = true
tt.dps.damage_every = fts(3)
tt.dps.damage_type = bor(DAMAGE_POISON, DAMAGE_MODIFIER)

tt = E:register_t("plant_poison_pumpkin", "decal_scripted")
E:add_comps(tt, "custom_attack", "ui", "plant", "editor")
tt.custom_attack.cooldown = 25
tt.custom_attack.range = 170
tt.custom_attack.mods = {
	"mod_plant_poison_pumpkin_slow",
	"mod_plant_poison_pumpkin"
}
tt.custom_attack.vis_flags = bor(F_RANGED, F_POISON)
tt.custom_attack.sound = "VenomPlantDischarge"
tt.editor.props = {
	{
		"ui.nav_mesh_id",
		PT_STRING
	}
}
tt.main_script.update = kr3_scripts.plant_poison_pumpkin.update
tt.render.sprites[1].prefix = "plant_poison_pumpkin"
tt.render.sprites[1].name = "loading"
tt.render.sprites[1].anchor.y = 0.0641025641025641
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-30, -5, 60, 54)
tt.ui.has_nav_mesh = true
tt.ui.hover_sprite_name = "plant_venom_0001_over_console"
tt.ui.hover_sprite_anchor = v(0.5, 0.43703703703703706)

tt = E:register_t("tower_faerie_dragon", "tower_KR5")
b = balance.towers.faerie_dragon
E:add_comps(tt, "powers", "attacks", "vis")
tt.attacks.list[1] = E:clone_c("custom_attack")
tt.attacks.list[1].cooldown = 2
tt.attacks.list[1].vis_flags = bor(F_RANGED, F_STUN, F_FREEZE)
tt.attacks.list[1].vis_bans = bor(F_BOSS)
tt.attacks.range = 250
tt.info.i18n_key = "ELVES_TOWER_SPECIAL_FAERIE_DRAGONS"
tt.info.fn = kr3_scripts.tower_faerie_dragon.get_info
tt.info.portrait = "portraits_towers_0131"
tt.main_script.update = kr3_scripts.tower_faerie_dragon.update
tt.powers.more_dragons = E:clone_c("power")
tt.powers.more_dragons.price = { 150, 150 }
tt.powers.more_dragons.max_level = 2
tt.powers.more_dragons.idle_offsets = {
	v(-12, 7),
	v(28, -3)
}
tt.powers.improve_shot = E:clone_c("power")
tt.powers.improve_shot.damage = b.improve_shot.damage
tt.powers.improve_shot.price = { 150, 150 }
tt.powers.improve_shot.max_level = 2
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "fairy_dragon_tower"
tt.render.sprites[2].offset = v(0, 36)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "tower_faerie_dragon_egg"
tt.render.sprites[3].offset = v(-19, 50)
tt.render.sprites[3].r = d2r(15)
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "tower_faerie_dragon_egg"
tt.render.sprites[4].offset = v(25, 41)
tt.render.sprites[4].r = d2r(-6)
tt.sound_events.insert = nil
tt.tower.menu_offset = v(2, 20)
tt.tower.price = 0
tt.tower.type = "faerie_dragon"
tt.tower.kind = TOWER_KIND_MAGE
tt.tower.team = TEAM_LINIREA

tt = E:register_t("faerie_dragon", "decal_scripted")
E:add_comps(tt, "force_motion", "custom_attack")
anchor_y = 0.5
image_y = 30
tt.flight_height = 80
tt.flight_speed_idle = 80
tt.flight_speed_busy = 120
tt.ramp_dist_idle = 80
tt.ramp_dist_busy = 80
tt.idle_pos = nil
tt.main_script.update = kr3_scripts.faerie_dragon.update
tt.custom_attack = E:clone_c("bullet_attack")
tt.custom_attack.bullet = "bolt_faerie_dragon"
tt.custom_attack.shoot_time = fts(12)
tt.custom_attack.bullet_start_offset = {
	v(13, -30)
}
tt.custom_attack.cooldown = 2
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "faerie_dragon"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop_forced = true
tt.render.sprites[1].sort_y_offset = -12
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.owner = nil

tt = E:register_t("bolt_faerie_dragon", "bolt")
tt.render.sprites[1].prefix = "faerie_dragon_proy"
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_max = 10
tt.bullet.damage_min = 10
tt.bullet.acceleration_factor = 0.25
tt.bullet.min_speed = 90
tt.bullet.max_speed = 180
tt.bullet.hit_fx = "fx_bolt_faerie_dragon"
tt.bullet.mod = "mod_faerie_dragon"
tt.sound_events.insert = "ElvesFaeryDragonAttack"

tt = E:register_t("fx_bolt_faerie_dragon", "fx")
tt.render.sprites[1].name = "faerie_dragon_proy_hit"

tt = E:register_t("fx_faerie_dragon_shoot", "fx")
tt.render.sprites[1].name = "faerie_dragon_shoot_fx"

tt = E:register_t("mod_faerie_dragon", "mod_freeze")
E:add_comps(tt, "render")
tt.modifier.duration = nil
tt.render.sprites[1].prefix = "mod_faerie_dragon"
tt.render.sprites[1].sort_y_offset = -2
tt.custom_offsets = {}
tt.custom_offsets.flying = v(-5, 28)
tt.custom_suffixes = {}
tt.custom_suffixes.flying = "_air"
tt.custom_animations = {
	"start",
	"end"
}
tt.freeze_decal_name = "decal_faerie_dragon_freeze_enemy"
tt.sound_events.insert = "ElvesFaeryDragonAttackCristalization"

tt = E:register_t("mod_faerie_dragon_l0", "mod_faerie_dragon")
tt.modifier.duration = 1

tt = E:register_t("mod_faerie_dragon_l1", "mod_faerie_dragon")
tt.modifier.duration = 2

tt = E:register_t("mod_faerie_dragon_l2", "mod_faerie_dragon")
tt.modifier.duration = 3

tt = E:register_t("decal_faerie_dragon_freeze_enemy", "decal_freeze_enemy")
tt.shader_args = {
	tint_color = {
		0.9725490196078431,
		0.6627450980392157,
		0.9882352941176471,
		1
	}
}

tt = E:register_t("ps_bolt_plant_magic_blossom", "ps_bolt_elves_1")
tt.particle_system.name = "plant_magicBlosom_particle"
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(15)
}
tt.particle_system.scales_y = {
	1,
	0.3
}
tt.particle_system.alphas = {
	190,
	120,
	0
}

tt = E:register_t("fx_plant_magic_blossom_loading", "decal")
tt.render.sprites[1].name = "fx_plant_magic_blossom_loading"
tt.render.sprites[1].offset.y = 34
tt.render.sprites[1].draw_order = 10

tt = E:register_t("fx_plant_magic_blossom_idle1", "decal")
tt.render.sprites[1].name = "fx_plant_magic_blossom_idle1"
tt.render.sprites[1].offset = v(4, 59)
tt.render.sprites[1].draw_order = 10

tt = E:register_t("fx_plant_magic_blossom_idle2", "decal")
tt.render.sprites[1].name = "fx_plant_magic_blossom_idle2"
tt.render.sprites[1].offset = v(4, 59)
tt.render.sprites[1].draw_order = 10

tt = E:register_t("fx_bolt_plant_magic_blossom_hit", "fx")
tt.render.sprites[1].name = "fx_bolt_plant_magic_blossom_hit"

tt = E:register_t("bolt_plant_magic_blossom", "bolt_elves")
tt.render.sprites[1].prefix = "bolt_plant_magic_blossom"
tt.bullet.max_speed = 390
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_min = 30
tt.bullet.damage_max = 60
tt.bullet.hit_fx = "fx_bolt_plant_magic_blossom_hit"
tt.bullet.particles_name = "ps_bolt_plant_magic_blossom"
tt.bullet.align_with_trajectory = true
tt.initial_impulse = 12000
tt.initial_impulse_duration = 0.15
tt.upgrades_disabled = true

tt = E:register_t("plant_magic_blossom", "decal_scripted")
E:add_comps(tt, "custom_attack", "ui", "plant", "editor")
tt.is_removed = nil
tt.custom_attack.cooldown = 15
tt.custom_attack.range = 200
tt.custom_attack.bullet = "bolt_plant_magic_blossom"
tt.custom_attack.bullet_count = 8
tt.custom_attack.vis_flags = bor(F_RANGED)
tt.custom_attack.bullet_start_offset = v(0, 55)
tt.custom_attack.sound = "ElvesPlantMissile"
tt.custom_attack.shoot_time = fts(6)
tt.editor.props = {
	{
		"ui.nav_mesh_id",
		PT_STRING
	}
}
tt.render.sprites[1].prefix = "plant_magic_blossom"
tt.render.sprites[1].name = "loading"
tt.render.sprites[1].anchor.y = 0.0641025641025641
tt.main_script.update = kr3_scripts.plant_magic_blossom.update
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-24, -5, 48, 78)
tt.ui.has_nav_mesh = true
tt.ui.hover_sprite_name = "plant_magicBlosom_0001_over_console"
tt.ui.hover_sprite_anchor = v(0.5, 0.4823529411764706)

tt = E:register_t("tower_ewok", "tower_KR5")
E:add_comps(tt, "barrack", "vis", "powers")
tt.powers.plant_magic_blossom = E:clone_c("power")
tt.powers.plant_magic_blossom.max_level = 2
tt.powers.plant_magic_blossom.price = { 120, 120 }
tt.powers.plant_magic_blossom.pos = {
	v(-47, -18),
	v(47, -18)
}
tt.powers.plant_magic_blossom.template = "plant_magic_blossom"
tt.powers.plant_magic_blossom.plants = {}
tt.info.portrait = "portraits_towers_0133"
tt.barrack.max_soldiers = 0
tt.barrack.rally_range = 150
tt.barrack.respawn_offset = v(12, 4)
tt.barrack.soldier_type = "soldier_ewok"
tt.editor.props = table.append(tt.editor.props, {
	{
		"barrack.rally_pos",
		PT_COORDS
	}
}, true)
tt.info.fn = scripts.tower_barrack_mercenaries.get_info
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.remove = customScripts1.tower_ewok.remove
tt.main_script.update = customScripts1.tower_ewok.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "ewok_hut_0002"
tt.render.sprites[2].offset = v(0, 32)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "close"
tt.render.sprites[3].offset = v(0, 32)
tt.render.sprites[3].prefix = "tower_ewok_door"
tt.render.door_sid = 3
tt.sound_events.change_rally_point = "ElvesEwokTaunt"
tt.sound_events.insert = nil
tt.sound_events.mute_on_level_insert = true
tt.tower.can_be_mod = true
tt.tower.level = 1
tt.tower.price = 0
tt.tower.terrain_style = nil
tt.tower.type = "ewok"
tt.tower.kind = TOWER_KIND_BARRACK
tt.tower.team = TEAM_LINIREA
tt.ui.click_rect = r(-40, -10, 80, 90)
tt.ui.has_nav_mesh = true

tt = E:register_t("soldier_ewok", "soldier_militia")
E:add_comps(tt, "dodge", "ranged", "nav_grid")
tt.dodge.animation_end = "shield_end"
tt.dodge.animation_hit = "shield_hit"
tt.dodge.animation_start = "shield_start"

function tt.dodge.can_dodge(store, this)
	this.dodge.last_hit_ts = store.tick_ts
	return this.health.hp <= this.health.hp_max * 0.6
end

tt.dodge.chance = 1
tt.dodge.cooldown = 20
tt.dodge.duration = 4
tt.dodge.ranged = true
tt.dodge.time_before_hit = 0
tt.health.armor = 0
tt.health.dead_lifetime = 13
tt.health.hp_max = 150
tt.health_bar.offset = v(0, 29)
tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
tt.idle_flip.chance = 0.4
tt.idle_flip.cooldown = 5
tt.info.portrait = "bottom_info_image_soldiers_0043"
tt.info.random_name_count = 6
tt.info.random_name_format = "ELVES_SOLDIER_EWOK_%i_NAME"
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.remove = scripts.soldier_barrack.remove
tt.main_script.update = kr3_scripts.soldier_ewok.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 7
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].pop = {
	"pop_ewoks"
}
tt.melee.attacks[1].pop_chance = 0.1
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.range = 50
tt.motion.max_speed = 75
tt.ranged.attacks[1].bullet = "bullet_soldier_ewok"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 10)
}
tt.ranged.attacks[1].cooldown = 1.3
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].shoot_time = fts(11)
tt.regen.cooldown = 0.5
tt.regen.health = 15
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].anchor.y = 0.19
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"running"
}
tt.render.sprites[1].prefix = "soldier_ewok"
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.insert = "ElvesEwokTaunt"
tt.ui.click_rect = r(-10, -2, 20, 25)
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.unit.price = {
	125,
	125,
	125,
	125
}

tt = E:register_t("bullet_soldier_ewok", "arrow")
tt.bullet.damage_max = 20
tt.bullet.damage_min = 16
tt.bullet.align_with_trajectory = true
tt.bullet.prediction_error = false
tt.bullet.reset_to_target_pos = true
tt.bullet.miss_decal = nil
tt.render.sprites[1].name = "bullet_soldier_ewok"
tt.render.sprites[1].animated = true

-- kr3 enemies
package.loaded.kr3_enemies_templates = nil
require("kr3_enemies_templates")

-- unmodified
tt = E:register_t("ps_bolt_high_elven", "ps_bolt_elves_1")
tt.particle_system.name = "mage_highElven_proy_particle"
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(10)
}
tt.particle_system.scales_y = {
	1,
	0.5
}
tt = E:register_t("ps_high_elven_sentinel")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "mage_highElven_balls_0020"
tt.particle_system.animated = false
tt.particle_system.alphas = {
	200,
	0
}
tt.particle_system.particle_lifetime = {
	fts(5),
	fts(5)
}
tt.particle_system.scales_y = {
	0.8,
	0.8
}
tt.particle_system.scales_x = {
	0.8,
	0.8
}
tt.particle_system.emission_rate = 60
tt.particle_system.z = Z_OBJECTS
tt.particle_system.draw_order = 4
tt.particle_system.sort_y = nil
tt = E:register_t("ps_arrow_multishot_hero_alleria")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_alleria_arrow_particle"
tt.particle_system.animated = false
tt.particle_system.alphas = {
	255,
	0
}
tt.particle_system.particle_lifetime = {
	0.1,
	0.1
}
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true
tt.particle_system.z = Z_BULLETS
tt = E:register_t("ps_shield_elves_denas")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "shield_elves_denas_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	fts(12),
	fts(12)
}
tt.particle_system.emission_rate = 60
tt.particle_system.scales_y = {
	1.5,
	0.5
}
tt.particle_system.scales_y = {
	1.5,
	0.5
}
tt.particle_system.track_rotation = true
tt.particle_system.z = Z_BULLETS
tt = E:register_t("ps_twilight_scourger_banshee")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.animation_fps = 15
tt.particle_system.emission_rate = 15
tt.particle_system.emit_offset = v(0, 24)
tt.particle_system.loop = false
tt.particle_system.name = "scourger_shadow_particle"
tt.particle_system.particle_lifetime = {
	fts(20),
	fts(20)
}
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.sort_y_offset = 2
tt.particle_system.z = Z_OBJECTS
tt = E:register_t("ps_nav_faerie_red")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 3
tt.particle_system.anchor.y = 0.28125
tt.particle_system.loop = false
tt.particle_system.name = "nav_faerie_particle_red"
tt.particle_system.particle_lifetime = {
	fts(12),
	fts(12)
}
tt.particle_system.z = Z_OBJECTS
tt = E:register_t("ps_nav_faerie_yellow", "ps_nav_faerie_red")
tt.particle_system.name = "nav_faerie_particle_yellow"
tt = E:register_t("ps_drow_queen_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.anchor.y = 0.35384615384615387
tt.particle_system.animated = true
tt.particle_system.cycle_names = true
tt.particle_system.emission_rate = 1
tt.particle_system.loop = false
tt.particle_system.names = {
	"s11_malicia_particle1",
	"s11_malicia_particle2"
}
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(10)
}
tt.particle_system.z = Z_OBJECTS
tt = E:register_t("ps_bolt_faustus")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "bolt_faustus_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(10)
}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
tt = E:register_t("ps_bolt_lance_faustus")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "bolt_lance_faustus_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(10)
}
tt.particle_system.emission_rate = 90
tt.particle_system.emit_rotation_spread = math.pi
tt = E:register_t("ps_bullet_liquid_fire_faustus")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.emission_rate = 20
tt.particle_system.emit_duration = fts(10)
tt.particle_system.emit_speed = {
	250,
	250
}
tt.particle_system.emit_rotation_spread = math.pi / 4
tt.particle_system.animated = true
tt.particle_system.animation_fps = 18
tt.particle_system.loop = false
tt.particle_system.name = "bullet_liquid_fire_faustus_particle"
tt.particle_system.particle_lifetime = {
	fts(9),
	fts(11)
}
tt.particle_system.alphas = {
	255,
	255,
	50
}
tt.particle_system.scales_x = {
	1,
	1,
	1.5
}
tt.particle_system.scales_y = {
	1,
	1,
	1.5
}
tt.particle_system.spin = {
	-math.pi / 2,
	math.pi / 2
}
tt.particle_system.sort_y_offsets = {
	-100,
	0
}
tt = E:register_t("ps_minidragon_faustus_fire", "ps_bullet_liquid_fire_faustus")
tt.particle_system.emit_duration = nil
tt.particle_system.emit_speed = {
	500,
	500
}
tt.particle_system.emit_rotation_spread = math.pi / 8
tt = E:register_t("ps_razorboar_rampage")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "razorboar_rampage_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	fts(9),
	fts(11)
}
tt.particle_system.emission_rate = 10
tt.particle_system.emit_area_spread = v(16, 6)
tt.particle_system.emit_offset = v(0, 28)
tt = E:register_t("ps_emit_breath_baby_ashbite")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "baby_ashbite_breath_particle"
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(10)
}
tt.particle_system.source_lifetime = fts(20)
tt = E:register_t("ps_emit_fiery_mist_baby_ashbite")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "baby_ashbite_fierymist_particle"
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(10)
}
tt.particle_system.source_lifetime = fts(20)
tt = RT("ps_fireball_veznan_demon")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {
	255,
	40
}
tt.particle_system.animated = false
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "veznan_hero_demon_proyParticle"
tt.particle_system.particle_lifetime = {
	fts(9),
	fts(11)
}
tt.particle_system.scales_x = {
	1,
	1.5
}
tt.particle_system.scales_y = {
	1,
	1.5
}
tt.particle_system.scale_same_aspect = false
tt.particle_system.scale_var = {
	0.35,
	0.8
}
tt = E:register_t("ps_veznan_soulburn")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "veznan_hero_soulBurn_particle"
tt.particle_system.animated = false
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.particle_lifetime = {
	fts(4),
	fts(12)
}
tt.particle_system.scales_x = {
	1,
	1.25
}
tt.particle_system.scales_y = {
	1,
	1.25
}
tt.particle_system.scale_var = {
	0.25,
	1
}
tt.particle_system.alphas = {
	255,
	0
}
tt = RT("ps_bullet_rag_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "razzAndRaggs_hero_proy_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {
	0.2,
	0.2
}
tt.particle_system.alphas = {
	255,
	12
}
tt.particle_system.scales_y = {
	0.8,
	0.05
}
tt.particle_system.emission_rate = 30
tt = RT("ps_durax_transfer")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "ps_durax_transfer"
tt.particle_system.animated = true
tt.particle_system.animation_fps = 15
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	fts(12),
	fts(12)
}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_offset = v(0, 16)
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.sort_y_offset = 2
tt = RT("ps_durax_clone_transfer", "ps_durax_transfer")
tt.particle_system.alphas = {
	150
}
tt = RT("ps_bullet_lilith_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "fallen_angel_hero_proy_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {
	0.2,
	0.2
}
tt.particle_system.alphas = {
	255,
	12
}
tt.particle_system.scales_y = {
	0.8,
	0.05
}
tt.particle_system.emission_rate = 30
tt = RT("ps_missile_phoenix")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.animation_fps = 50
tt.particle_system.emission_rate = 50
tt.particle_system.emit_area_spread = v(4, 4)
tt.particle_system.loop = false
tt.particle_system.name = "ps_missile_phoenix"
tt.particle_system.particle_lifetime = {
	0.14,
	0.18
}
tt.particle_system.spin = {
	-0.3,
	0.3
}
tt.particle_system.track_rotation = true
tt = RT("ps_missile_phoenix_small", "ps_missile_phoenix")
tt.particle_system.scale_var = {
	0.65,
	0.65
}
tt.particle_system.emit_area_spread = v(2, 2)
tt = RT("ps_bomb_lava_fireball")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {
	200,
	0
}
tt.particle_system.animated = false
tt.particle_system.emission_rate = 60
tt.particle_system.emit_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "Stage9_lavaShotParticle"
tt.particle_system.particle_lifetime = {
	0.4,
	0.6
}
tt.particle_system.scale_same_aspect = true
tt.particle_system.scale_var = {
	0.6,
	1.2
}
tt.particle_system.scales_x = {
	1,
	1.5
}
tt.particle_system.scales_y = {
	1,
	1.5
}
tt = RT("ps_bullet_balrog", "ps_fireball_arivan")
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(15)
}
tt.particle_system.animation_fps = 20
tt.particle_system.emit_area_spread = v(4, 4)
tt.particle_system.emission_rate = 60
tt.particle_system.track_rotation = true
tt = RT("ps_bullet_rod_dragon_fire")

AC(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 50
tt.particle_system.emit_area_spread = v(4, 4)
tt.particle_system.loop = false
tt.particle_system.name = "ps_rod_dragon_fire_particle"
tt.particle_system.particle_lifetime = {
	0.3,
	0.34
}
tt.particle_system.track_rotation = true
tt = E:register_t("fx_arrow_soldier_re_hit", "fx")
tt.render.sprites[1].name = "fx_arrow_soldier_re_hit"
tt = E:register_t("fx_faustus_start_attack", "fx")
tt.render.sprites[1].name = "fx_faustus_attack"
tt.render.sprites[1].anchor.y = 0.065
tt = E:register_t("fx_faustus_start_lance", "fx")
tt.render.sprites[1].name = "hero_faustus_rayShoot"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
tt = E:register_t("fx_faustus_start_teleport", "fx")
tt.render.sprites[1].name = "hero_faustus_teleport"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
tt = E:register_t("fx_faustus_start_enervation", "fx")
tt.render.sprites[1].name = "hero_faustus_silence"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
tt = E:register_t("fx_faustus_start_liquid_fire", "fx")
tt.render.sprites[1].name = "fx_faustus_start_liquid_fire"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
tt = E:register_t("fx_bolt_faustus_hit", "fx")
tt.render.sprites[1].name = "bolt_faustus_hit"
tt = E:register_t("fx_bolt_lance_faustus_hit", "fx")
tt.render.sprites[1].anchor.y = 0.21428571428571427
tt.render.sprites[1].prefix = "fx_bolt_lance_faustus_hit"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt = E:register_t("fx_teleport_faustus", "fx")
tt.render.sprites[1].name = "fx_teleport_faustus"
tt.render.sprites[1].size_scales = {
	vv(0.83),
	vv(1),
	vv(1)
}
tt = E:register_t("fx_bullet_liquid_fire_faustus_hit", "decal_tween")
tt.render.sprites[1].name = "fx_bullet_liquid_fire_faustus_hit"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt.tween.remove = true
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.1,
		255
	},
	{
		2,
		0
	}
}
tt = E:register_t("fx_bravebark_teleport_out", "decal_tween")

E:add_comps(tt, "sound_events")

tt.render.sprites[1].name = "bravebark_teleportOutFx"
tt.render.sprites[1].anchor.y = 0.15517241379310345
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "bravebark_hero_teleportDecal"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {
	{
		fts(12),
		0
	},
	{
		fts(13),
		255
	},
	{
		fts(44),
		0
	}
}
tt.sound_events.insert = "ElvesHeroForestElementalTeleportIn"
tt = E:register_t("fx_bravebark_teleport_in", "fx_bravebark_teleport_out")
tt.render.sprites[1].name = "bravebark_teleportInFx"
tt.tween.props[1].keys = {
	{
		fts(1),
		255
	},
	{
		fts(44),
		0
	}
}
tt.sound_events.insert = "ElvesHeroForestElementalTeleportOut"
tt = E:register_t("fx_bravebark_branchball_hit", "fx")
tt.render.sprites[1].name = "bravebark_superHit"
tt = RT("fx_bravebark_melee_hit", "fx")
tt.render.sprites[1].name = "bravebark_hitSmoke"
tt.render.sprites[1].anchor.y = 0.2
tt = E:register_t("fx_bravebark_ultimate", "fx")
tt.render.sprites[1].name = "bravebark_spikedRoots_spawnFx"
tt.render.sprites[1].anchor.y = 0.3181818181818182
tt = E:register_t("fx_xin_smoke_teleport_out", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_out"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = E:register_t("fx_xin_smoke_teleport_hit", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_hit"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = E:register_t("fx_xin_smoke_teleport_hit_out", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_hit_out"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = E:register_t("fx_xin_smoke_teleport_in", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_in"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = E:register_t("fx_xin_panda_style_smoke", "fx")
tt.render.sprites[1].name = "fx_xin_panda_style_smoke"
tt.render.sprites[1].anchor.y = 0.4
tt.render.sprites[1].z = Z_DECALS
tt = RT("fx_catha_ultimate", "fx")
tt.render.sprites[1].name = "fx_catha_soul"
tt.render.sprites[1].anchor.y = 0.373015873015873
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_catha_ultimate"
tt.render.sprites[2].z = Z_DECALS
tt = RT("fx_catha_soul", "fx")
tt.render.sprites[1].name = "fx_catha_soul"
tt.render.sprites[1].anchor.y = 0.373015873015873
tt = RT("fx_knife_catha_hit", "fx")
tt.render.sprites[1].name = "fx_knife_catha_hit"
tt = RT("fx_bolt_veznan_hit", "fx")
tt.render.sprites[1].name = "veznan_hero_bolt_hit"
tt = RT("fx_veznan_arcanenova", "fx")
tt.render.sprites[1].name = "fx_veznan_arcanenova"
tt.render.sprites[1].anchor.y = 0.11904761904761904
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_veznan_soulburn", "decal_tween")
tt.render.sprites[1].prefix = "veznan_hero_soulBurn_desintegrate"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].loop = false
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[1].anchor.y = 0.15217391304347827
tt.tween.props[1].keys = {
	{
		0.5,
		255
	},
	{
		1,
		0
	}
}
tt = RT("fx_veznan_soulburn_ball_spawn", "fx")
tt.render.sprites[1].prefix = "veznan_hero_soulBurn_proy_spawn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[1].z = Z_BULLETS
tt = RT("fx_rag_ultimate", "fx")
tt.render.sprites[1].name = "fx_rag_ultimate"
tt.render.sprites[1].anchor.y = 0.2
tt = RT("fx_rag_raggified", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "rag_polymorphed_fx"
tt.render.sprites[1].size_scales = {
	vv(0.75),
	vv(1),
	vv(1)
}
tt.sound_events.insert = "ElvesHeroRagTransform"
tt = RT("fx_bullet_rag_hit", "fx")
tt.render.sprites[1].name = "fx_bullet_rag_hit"
tt = RT("fx_durax_ultimate_fang_1", "decal_tween")
tt.render.sprites[1].name = "fx_durax_ultimate_fang_1"
tt.render.sprites[1].anchor.y = 0.26666666666666666
tt.render.sprites[1].loop = false
tt.render.sprites[1].size_scales = {
	vv(0.7),
	vv(1),
	vv(1)
}
tt.tween.props[1].keys = {
	{
		1,
		255
	},
	{
		1.2,
		0
	}
}
tt = RT("fx_durax_ultimate_fang_2", "fx_durax_ultimate_fang_1")
tt.render.sprites[1].name = "fx_durax_ultimate_fang_2"
tt = RT("fx_durax_ultimate_fang_extra_1", "decal_tween")
tt.render.sprites[1].name = "fx_durax_ultimate_fang_extra_1"
tt.render.sprites[1].anchor.y = 0.20588235294117646
tt.render.sprites[1].loop = false
tt.tween.props[1].keys = {
	{
		1,
		255
	},
	{
		1.2,
		0
	}
}
tt = RT("fx_durax_ultimate_fang_extra_2", "fx_durax_ultimate_fang_extra_1")
tt.render.sprites[1].name = "fx_durax_ultimate_fang_extra_2"
tt = E:register_t("fx_ray_durax_hit", "fx")
tt.render.sprites[1].name = "fx_ray_durax_hit"
tt = RT("fx_shardseed_hit", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_shardseed_hit"
tt.render.sprites[1].anchor.y = 0.46296296296296297
tt.sound_events.insert = "ElvesHeroDuraxShardSpearHit"
tt = RT("fx_meteor_lilith_explosion", "fx")
tt.render.sprites[1].name = "lilith_ultimate_meteor_explosion"
tt.render.sprites[1].anchor.y = 0.20930232558139536
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_lilith_soul_eater_ball_hit", "fx")
tt.render.sprites[1].name = "lilith_soul_eater_explosion_anim"
tt = RT("fx_lilith_ranged_hit", "fx")
tt.render.sprites[1].name = "fx_lilith_ranged_hit"
tt = RT("fx_lynn_explosion", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_lynn_explosion"
tt.render.sprites[1].anchor.y = 0.3706896551724138
tt.sound_events.insert = "BombExplosionSound"
tt = RT("fx_flaming_path_start", "fx")
tt.render.sprites[1].name = "fx_flaming_path_start"
tt.render.sprites[1].anchor.y = 0.26666666666666666
tt = RT("fx_flaming_path_end", "fx_flaming_path_start")
tt.render.sprites[1].name = "fx_flaming_path_end"
tt = RT("fx_phoenix_explosion", "fx")
tt.render.sprites[1].name = "hero_phoenix_explosion"
tt.render.sprites[1].anchor.y = 0.20588235294117646
tt = RT("fx_phoenix_inmolation", "decal_tween")
tt.render.sprites[1].name = "hero_phoenix_explosion"
tt.render.sprites[1].anchor.y = 0.20588235294117646
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "phoenix_hero_suicide_decals_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "phoenix_hero_suicide_decals_0002"
tt.render.sprites[3].z = Z_DECALS
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {
	{
		fts(20),
		255
	},
	{
		fts(34),
		0
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].sprite_id = 3
tt.tween.props[2].keys = {
	{
		fts(4),
		255
	},
	{
		fts(10),
		0
	}
}
tt = RT("fx_ray_phoenix_hit", "fx")
tt.render.sprites[1].name = "fx_ray_phoenix_hit"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt = E:register_t("fx_torch_gnoll_burner_explosion", "fx")
tt.render.sprites[1].name = "fx_torch_gnoll_burner_explosion"
tt.render.sprites[1].anchor.y = 0.25
tt = E:register_t("fx_bolt_gnoll_blighter_hit", "fx")
tt.render.sprites[1].name = "gnoll_blighter_proy_hit"
tt = E:register_t("fx_bandersnatch_spine", "decal_tween")
tt.render.sprites[1].name = "bandersnatch_spine_ground"
tt.render.sprites[1].anchor.y = 0.1
tt.render.sprites[1].loop = false
tt.tween.props[1].keys = {
	{
		fts(21),
		255
	},
	{
		fts(21) + 0.25,
		0
	}
}
tt = E:register_t("fx_bandersnatch_spines_blood", "fx")
tt.render.sprites[1].name = "bandersnatch_spines_blood"
tt.render.sprites[1].z = Z_EFFECTS
tt = E:register_t("fx_redcap_death_blow", "fx")
tt.render.sprites[1].name = "fx_redcap_death_blow"
tt.render.sprites[1].z = Z_EFFECTS
tt = E:register_t("fx_knife_satyr_hit", "fx")
tt.render.sprites[1].name = "fx_knife_satyr_hit"
tt.render.sprites[1].offset.y = 5
tt = E:register_t("fx_twilight_avenger_explosion", "fx")
tt.render.sprites[1].name = "fx_twilight_avenger_explosion"
tt.render.sprites[1].anchor.y = 0.26666666666666666
tt.render.sprites[1].sort_y_offset = -2
tt = E:register_t("fx_twilight_scourger_lash", "fx")
tt.render.sprites[1].name = "fx_twilight_scourger_lash"
tt.render.sprites[1].anchor.y = 0.19318181818181818
tt.render.sprites[1].sort_y_offset = -5
tt = E:register_t("fx_twilight_scourger_banshee_end", "fx")
tt.render.sprites[1].name = "fx_twilight_scourger_banshee_end"
tt.render.sprites[1].offset.y = 30
tt.render.sprites[1].sort_y_offset = -2
tt = E:register_t("fx_faerie_smoke", "fx")
tt.render.sprites[1].prefix = "fx_faerie_smoke"
tt.render.sprites[1].name = "yellow"
tt.render.sprites[1].sort_y_offset = -5
tt.render.sprites[1].anchor.y = 0.28
tt = RT("fx_bolt_ogre_magi_hit", "fx")
tt.render.sprites[1].name = "fx_bolt_ogre_magi_hit"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt.render.sprites[1].sort_y_offset = -2
tt = RT("fx_bolt_ogre_magi_hit_air", "fx")
tt.render.sprites[1].name = "fx_bolt_ogre_magi_hit_air"
tt.render.sprites[1].anchor.y = 0.5555555555555556
tt.render.sprites[1].sort_y_offset = -2
tt = RT("fx_bullet_dark_spitters_miss", "fx")
tt.render.sprites[1].name = "fx_bullet_dark_spitters_miss"
tt.render.sprites[1].anchor.y = 0.26666666666666666
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_bullet_balrog_hit", "fx")
tt.render.sprites[1].name = "balrog_aura_splash"
tt.render.sprites[1].anchor.y = 0.43636363636363634
tt = RT("fx_bullet_catapult_endless_spiked_explosion", "fx_rock_explosion")
tt.render.sprites[1].name = "catapult_endless_explosions_spikebomb"
tt.render.sprites[1].anchor.y = 0.36875
tt = RT("fx_bullet_catapult_endless_bomb_explosion", "fx_rock_explosion")
tt.render.sprites[1].name = "catapult_endless_explosions_bomb"
tt.render.sprites[1].anchor.y = 0.36875
tt = RT("fx_bullet_catapult_endless_barrel_explosion", "fx_rock_explosion")
tt.render.sprites[1].name = "catapult_endless_explosions_barrel"
tt.render.sprites[1].anchor.y = 0.36875
tt = RT("fx_block_tower_ainyl_end", "fx")
tt.render.sprites[1].name = "ainyl_block_end"
tt.render.sprites[1].offset.y = 30
tt.render.sprites[1].sort_y_offset = -2
tt = E:register_t("fx_crystal_arcane_buff", "decal_tween")
tt.render.sprites[1].name = "crystalArcane_towerBuff_fx_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.25
tt.render.sprites[1].scale = vv(0.9)
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "crystalArcane_towerBuff_fx_0002"
tt.render.sprites[2].animated = false
tt.render.sprites[2].scale = vv(0.9)
tt.render.sprites[2].sort_y_offset = -2
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		1,
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {
	{
		0,
		v(0, 10)
	},
	{
		1,
		v(0, 44)
	}
}
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 2
tt.tween.props[4] = table.deepclone(tt.tween.props[2])
tt.tween.props[4].sprite_id = 2
tt = RT("fx_crystal_unstable_ring", "decal_tween")
tt.render.sprites[1].name = "crystalUnstable_healAura_ring"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		51
	},
	{
		fts(5),
		255
	},
	{
		fts(20),
		0
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		vv(0.42)
	},
	{
		fts(5),
		vv(1.5)
	},
	{
		fts(20),
		vv(2)
	}
}
tt = RT("fx_crystal_unstable_glow", "decal_tween")
tt.render.sprites[1].name = "crystalUnstable_healAura_glow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(20),
		0
	}
}
tt = RT("fx_teleport_out_crystal_unstable", "fx")
tt.render.sprites[1].name = "fx_teleport_out_crystal_unstable"
tt = RT("fx_teleport_in_crystal_unstable", "fx")
tt.render.sprites[1].name = "fx_teleport_in_crystal_unstable"
tt = RT("fx_crystal_unstable_heal", "decal_tween")
tt.render.sprites[1].name = "crystalUnstable_healAura_glow"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(35),
		0
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		vv(1)
	},
	{
		fts(35),
		vv(0.23)
	}
}

for i = 0, 2 do
	local s = CC("sprite")

	s.name = "crystalUnstable_healAura_ring"
	s.animated = false
	s.z = Z_DECALS

	table.insert(tt.render.sprites, s)

	local p = CC("tween_prop")

	p.sprite_id = #tt.render.sprites
	p.keys = {
		{
			fts(0 + i * 4),
			51
		},
		{
			fts(10 + i * 4),
			255
		},
		{
			fts(20 + i * 4),
			0
		}
	}

	table.insert(tt.tween.props, p)

	p = CC("tween_prop")
	p.sprite_id = #tt.render.sprites
	p.name = "scale"
	p.keys = {
		{
			fts(0 + i * 4),
			vv(0.42)
		},
		{
			fts(10 + i * 4),
			vv(0.68)
		},
		{
			fts(20 + i * 4),
			vv(1)
		}
	}

	table.insert(tt.tween.props, p)
end

for i, pos in ipairs({
	v(-22, 8),
	v(7, 0),
	v(-2, 2),
	v(23, 15),
	v(-29, 5),
	v(11, -4),
	v(-4, 21)
}) do
	local s = CC("sprite")

	s.name = "fx_crystal_unstable_bubbles"
	s.time_offset = i * fts(1)
	s.offset = pos

	table.insert(tt.render.sprites, s)
end

tt = E:register_t("decal_arcane_burst_ground", "decal_tween")
tt.render.sprites[1].name = "archer_arcane_special_decal1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "archer_arcane_special_decal2"
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(4),
		255
	},
	{
		fts(6),
		0
	}
}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		v(1, 1)
	},
	{
		fts(4),
		v(1.84, 1.84)
	},
	{
		fts(6),
		v(2.17, 2.17)
	}
}
tt.tween.props[2].sprite_id = 1
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].keys = {
	{
		0,
		255
	},
	{
		fts(4),
		48
	},
	{
		fts(9),
		0
	}
}
tt.tween.props[3].sprite_id = 2
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {
	{
		0,
		v(1, 1)
	},
	{
		fts(4),
		v(1.64, 1.64)
	},
	{
		fts(6),
		v(2.07, 2.07)
	}
}
tt.tween.props[4].sprite_id = 2
tt = E:register_t("decal_bravebark_rootspikes_hit", "decal_tween")
tt.render.sprites[1].name = "bravebark_hero_handDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.45454545454545453
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		2,
		0
	}
}
tt = RT("decal_bravebark_melee_hit", "decal_bravebark_rootspikes_hit")
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		1,
		0
	}
}
tt = E:register_t("decal_bravebark_rootspike", "decal_scripted")
tt.render.sprites[1].prefix = "bravebark_spike"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.25
tt.main_script.update = kr3_scripts.decal_bravebark_rootspike.update
tt.hold_duration = 1
tt.hole_decal = "decal_bravebark_rootspike_hole"
tt.delay = 0
tt.scale = 1
tt = E:register_t("decal_bravebark_rootspike_hole", "decal_tween")
tt.render.sprites[1].name = "bravebark_hero_spikeDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		1,
		0
	}
}
tt = E:register_t("decal_bravebark_branchball_enemy_clone", "decal_tween")
tt.tween.disabled = true
tt.tween.remove = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.35,
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {
	{
		0,
		v(0, 0)
	},
	{
		0.35,
		v(0, 0)
	}
}
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "r"
tt.tween.props[3].keys = {
	{
		0,
		0
	},
	{
		0.35,
		0
	}
}
tt = E:register_t("decal_bravebark_ultimate", "decal_sequence")
tt.render.sprites[1].prefix = "bravebark_spikedRoots"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.3181818181818182
tt.render.sprites[1].scale = vv(0.75)
tt.sequence.steps = {
	"in",
	1,
	"out"
}
tt.sequence.fxs = {
	"fx_bravebark_ultimate",
	nil,
	"decal_bravebark_ultimate_crater"
}
tt = E:register_t("decal_bravebark_ultimate_crater", "decal_tween")
tt.render.sprites[1].name = "bravebark_hero_spikedRootsDecal"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		1,
		255
	},
	{
		2,
		0
	}
}
tt = E:register_t("decal_xin_inspire", "decal_tween")
tt.render.sprites[1].name = "xin_hero_scream_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		255
	},
	{
		fts(20),
		63
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		vv(0.5)
	},
	{
		fts(10),
		vv(0.68)
	},
	{
		fts(20),
		vv(1.25)
	}
}
tt = E:register_t("decal_xin_drink_circle", "decal_tween")
tt.render.sprites[1].name = "xin_hero_drink_auraCircle"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		255
	},
	{
		fts(20),
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		vv(0.7)
	},
	{
		fts(20),
		vv(1.5)
	}
}
tt = RT("decal_veznan_arcanenova", "decal_bomb_crater")
tt.render.sprites[1].name = "veznan_hero_arcaneNova_terrainDecal"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_veznan_arcanenova_terrain"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].z = Z_DECALS
tt = RT("decal_veznan_soulburn_ball", "decal_scripted")
tt.render.sprites[1].prefix = "veznan_hero_soulBurn_proy"
tt.render.sprites[1].name = "fly"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].hidden = true
tt.from = nil
tt.to = nil
tt.target = nil
tt.speed = 14 * FPS
tt.offset = v(-5, 5)
tt.particles_name = "ps_veznan_soulburn"
tt.spawn_fx = "fx_veznan_soulburn_ball_spawn"
tt.main_script.update = kr3_scripts.decal_veznan_soulburn_ball.update
tt = RT("decal_baby_malik_smash", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_baby_malik_ring"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].z = Z_DECALS
tt = RT("decal_baby_malik_earthquake", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_baby_malik_earthquake"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].anchor.y = 0.24
tt = RT("decal_rag_ultimate", "fx")
tt.render.sprites[1].name = "decal_rag_ultimate"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_durax", "decal")
tt.render.sprites[1].name = "aura_durax"
tt.render.sprites[1].scale = vv(1.3)
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_meteor_lilith_explosion", "decal_tween")
tt.render.sprites[1].name = "stage4_fire_decal_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vv(0.6)
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = true
tt.tween.props[1].keys = {
	{
		0,
		130
	},
	{
		2.5,
		130
	},
	{
		3.25,
		0
	}
}
tt = RT("decal_lilith_soul_eater_ball", "decal_scripted")

AC(tt, "force_motion", "sound_events")

tt.render.sprites[1].name = "lilith_soul_eater_ball_loop"
tt.render.sprites[1].offset.y = 10
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.force_motion.max_a = 5400
tt.force_motion.max_v = 240
tt.force_motion.a_step = 10
tt.force_motion.max_flight_height = 60
tt.main_script.update = kr3_scripts.decal_lilith_soul_eater_ball.update
tt.hit_fx = "fx_lilith_soul_eater_ball_hit"
tt.hit_mod = "mod_lilith_soul_eater_damage_factor"
tt.stolen_damage = nil
tt.sound_events.insert = "ElvesHeroLilithSoulEater"
tt = RT("decal_lilith_reapers_harvest", "decal_timed")
tt.render.sprites[1].name = "lilith_reapers_harvest_decal_anim"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_phoenix_ultimate", "decal_rock_crater")
tt.render.sprites[1].name = "phoenix_hero_egg_decal"
tt = RT("decal_phoenix_flaming_path_pulse", "decal_tween")
tt.render.sprites[1].name = "phoenix_hero_towerBurn_Circle"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		v(1, 1)
	},
	{
		0.32,
		v(2.4, 2.4)
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {
	{
		0,
		255
	},
	{
		0.32,
		0
	}
}
tt = E:register_t("decal_twilight_scourger_lash", "decal_tween")
tt.render.sprites[1].name = "scourger_special_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[4] = table.deepclone(tt.render.sprites[1])
tt.tween.props[1].keys = {
	{
		fts(11),
		153
	},
	{
		fts(16),
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		vv(0.312)
	},
	{
		fts(16),
		vv(0.725)
	}
}
tt.tween.props[2].sprite_id = 1
tt.tween.props[2].name = "scale"
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].keys = {
	{
		fts(11),
		153
	},
	{
		fts(16),
		0
	}
}
tt.tween.props[3].sprite_id = 2
tt.tween.props[4] = table.deepclone(tt.tween.props[2])
tt.tween.props[4].keys = {
	{
		0,
		vv(0.408)
	},
	{
		fts(16),
		vv(0.961)
	}
}
tt.tween.props[4].sprite_id = 2
tt.tween.props[5] = table.deepclone(tt.tween.props[1])
tt.tween.props[5].keys = {
	{
		fts(9),
		153
	},
	{
		fts(16),
		0
	}
}
tt.tween.props[5].sprite_id = 3
tt.tween.props[6] = table.deepclone(tt.tween.props[2])
tt.tween.props[6].keys = {
	{
		0,
		vv(0.766)
	},
	{
		fts(16),
		vv(1.265)
	}
}
tt.tween.props[6].sprite_id = 3
tt.tween.props[7] = table.deepclone(tt.tween.props[1])
tt.tween.props[7].keys = {
	{
		fts(9),
		153
	},
	{
		fts(16),
		0
	}
}
tt.tween.props[7].sprite_id = 4
tt.tween.props[8] = table.deepclone(tt.tween.props[2])
tt.tween.props[8].keys = {
	{
		0,
		vv(0.986)
	},
	{
		fts(16),
		vv(1.627)
	}
}
tt.tween.props[8].sprite_id = 4
tt = E:register_t("decal_drider_clone", "decal_timed")
tt.timed.duration = 1
tt = E:register_t("decal_drider_cocoon", "decal_scripted")
tt.render.sprites[1].prefix = "decal_drider_cocoon"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].size_scales = {
	vv(0.8),
	vv(1),
	vv(1)
}
tt.render.sprites[1].anchor.y = 0.16
tt.main_script.update = kr3_scripts.decal_drider_cocoon.update
tt.duration = 5
tt = E:register_t("decal_arachnomancer_mini_spider", "decal_scripted")

E:add_comps(tt, "motion")

tt.render.sprites[1].anchor.y = 0.25
tt.render.sprites[1].prefix = "arachnomancer_mini_spider"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.spider_offsets = {
	v(20, -5),
	v(-20, -5),
	v(0, 23)
}
tt.main_script.update = kr3_scripts.decal_arachnomancer_mini_spider.update
tt.motion.max_speed = 7.5
tt.max_delta_y = 10
tt = E:register_t("decal_webspawn_enemy_spider_arachnomancer", "decal_scripted")

E:add_comps(tt, "nav_path")

tt.main_script.insert = kr3_scripts.delayed_spawn.insert
tt.main_script.update = kr3_scripts.delayed_spawn.update
tt.render.sprites[1].prefix = "arachnomancer_webspawn"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[1].anchor.y = 0.1875
tt.render.sprites[1].sort_y_offset = -1
tt.delay = fts(8)
tt.entity = "enemy_spider_arachnomancer"
tt = E:register_t("decal_webspawn_enemy_sword_spider", "decal_webspawn_enemy_spider_arachnomancer")
tt.entity = "enemy_sword_spider"
tt = E:register_t("decal_webspawn_enemy_spider_son_of_mactans", "decal_webspawn_enemy_spider_arachnomancer")
tt.entity = "enemy_spider_son_of_mactans"
tt = RT("decal_shadow_spider_son_of_mactans", "decal_tween")
tt.render.sprites[1].name = "son_of_mactans_shadow"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		2,
		255
	},
	{
		2 + fts(21),
		255
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		vv(0)
	},
	{
		2,
		vv(1)
	}
}
tt.tween.props[2].name = "scale"
tt = RT("decal_mactans_path_web_1", "decal_tween")
tt.render.sprites[1].name = "spiderQueen_floorNet_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS - 1
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		"this.fade_duration",
		255
	},
	{
		"this.duration-this.fade_duration",
		255
	},
	{
		"this.duration",
		0
	}
}
tt = RT("decal_mactans_path_web_2", "decal_mactans_path_web_1")
tt.render.sprites[1].name = "spiderQueen_floorNet_0002"
tt = RT("decal_mactans_path_web_3", "decal_mactans_path_web_1")
tt.render.sprites[1].name = "spiderQueen_floorNet_0003"
tt = RT("decal_snare_hee_haw", "decal_tween")
tt.render.sprites[1].anchor = v(0.4785714285714286, 0.31)
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hee-haw_net_0031"
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		1,
		255
	},
	{
		fts(60),
		255
	},
	{
		fts(65),
		0
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {
	{
		fts(11),
		vv(0.3)
	},
	{
		fts(65),
		vv(0.6)
	}
}
tt.tween.props[2].name = "scale"
tt.tween.remove = true
tt = RT("decal_catapult_endless", "decal_scripted")

AC(tt, "ranged", "editor")

tt.editor.props = {
	{
		"x_inside",
		PT_NUMBER
	}
}
tt.duration = 2
tt.x_inside = 955
tt.transit_time = 8
tt.render.sprites[1].prefix = "catapult_endless_layer1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.14285714285714285
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "catapult_endless_layer2"
tt.main_script.update = kr3_scripts.decal_catapult_endless.update
tt.ranged.attacks[1].bullet = "rock_enemy_catapult"
tt.ranged.attacks[1].bullet_start_offset = {
	v(-30, 90)
}
tt.ranged.attacks[1].cooldown = 3
tt.ranged.attacks[1].max_x = 800
tt.ranged.attacks[1].min_x = 150
tt.ranged.attacks[1].shoot_time = fts(39)
tt.ranged.attacks[1].path_margins = {
	90,
	30
}
tt.ranged.attacks[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.ranged.attacks[1].count = 1
tt.ranged.attacks[1].barrel_payload_idx = nil
tt.ranged.attacks[1].munition_type = 0
tt.ranged.attacks[1].munition_settings = {
	[0] = {
		[0] = "catapult_endless_layer8",
		"catapult_endless_layer9",
		bullet = "bullet_catapult_endless_rock"
	},
	{
		[0] = "catapult_endless_layer6",
		"catapult_endless_layer3",
		bullet = "bullet_catapult_endless_spiked"
	},
	{
		[0] = "catapult_endless_layer5",
		"catapult_endless_layer2",
		bullet = "bullet_catapult_endless_bomb"
	},
	{
		[0] = "catapult_endless_layer7",
		"catapult_endless_layer4",
		bullet = "bullet_catapult_endless_barrel"
	}
}
tt.ranged.attacks[1].barrel_payloads = {
	"enemy_gnoll_reaver",
	"enemy_gnoll_burner",
	"enemy_gnoll_gnawer",
	"enemy_gnoll_blighter"
}
tt = E:register_t("decal_crystal_arcane_freeze_center", "decal_tween")
tt.render.sprites[1].name = "crystalArcane_groundFreeze_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		"this.duration",
		255
	},
	{
		"this.duration+0.3",
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		vv(0.2)
	},
	{
		0.2,
		vv(1)
	}
}
tt = E:register_t("decal_crystal_arcane_freeze_1", "decal_tween")
tt.render.sprites[1].name = "decal_crystal_arcane_freeze_1"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		"this.duration",
		255
	},
	{
		"this.duration+0.3",
		0
	}
}
tt = E:register_t("decal_crystal_arcane_freeze_2", "decal_crystal_arcane_freeze_1")
tt.render.sprites[1].name = "decal_crystal_arcane_freeze_2"
tt = E:register_t("tower_holder_elven_woods", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_ELVEN_WOODS
tt.render.sprites[1].name = "build_terrain_0001"
tt = E:register_t("tower_holder_faerie_grove", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_FAERIE_GROVE
tt.render.sprites[1].name = "build_terrain_0002"
tt = E:register_t("tower_holder_ancient_metropolis", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_ANCIENT_METROPOLIS
tt.render.sprites[1].name = "build_terrain_0003"
tt = E:register_t("tower_holder_hulking_rage", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_HULKING_RAGE
tt.render.sprites[1].name = "build_terrain_0004"
tt = E:register_t("tower_holder_bittering_rancor", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_BITTERING_RANCOR
tt.render.sprites[1].name = "build_terrain_0005"
tt = E:register_t("tower_holder_forgotten_treasures", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_FORGOTTEN_TREASURES
tt.render.sprites[1].name = "build_terrain_0006"
tt = E:register_t("tower_build_archer", "tower_build")
tt.build_name = "tower_archer_1"
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2].name = "build_archer"
tt.render.sprites[2].offset = v(0, 32)
tt = E:register_t("tower_build_barrack", "tower_build")
tt.build_name = "tower_barrack_1"
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2].name = "build_barracks"
tt.render.sprites[2].offset = v(0, 34)
tt = E:register_t("tower_build_mage", "tower_build")
tt.build_name = "tower_mage_1"
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2].name = "build_mage"
tt.render.sprites[2].offset = v(0, 24)

tt = E:register_t("tower_rock_thrower_1", "tower")

E:add_comps(tt, "attacks")

tt.tower.type = "rock_thrower"
tt.tower.level = 1
tt.tower.price = 125
tt.tower.range_offset = v(0, 10)
tt.info.enc_icon = 4
tt.info.portrait = (IS_PHONE and "portraits_towers" or "info_portraits_towers") .. "_0004"
tt.main_script.update = kr3_scripts.tower_rock_thrower.update
tt.attacks.range = 150
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "rock_1"
tt.attacks.list[1].cooldown = 3
tt.attacks.list[1].shoot_time = fts(9)
tt.attacks.list[1].vis_bans = bor(F_FLYING)
tt.attacks.list[1].bullet_start_offset = v(0, 46)
tt.attacks.list[1].node_prediction = true
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_%04i"
tt.render.sprites[1].offset = v(0, 26)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "artillery_base_0001"
tt.render.sprites[2].offset = v(0, 26)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "tower_rock_thrower_loading_stones"
tt.render.sprites[3].name = "play"
tt.render.sprites[3].offsets = {
	v(12, 32),
	v(-12, 32)
}
tt.render.sprites[3].draw_order = 7
tt.render.sprites[3].hide_after_runs = 1
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "tower_rock_thrower_shooter_l1"
tt.render.sprites[4].name = "idleDown"
tt.render.sprites[4].angles = {}
tt.render.sprites[4].angles.idle = {
	"idleUp",
	"idleDown"
}
tt.render.sprites[4].angles.shoot = {
	"shootUp",
	"shootDown"
}
tt.render.sprites[4].angles.load = {
	"loadUp",
	"loadDown"
}
tt.render.sprites[4].angles_flip_horizontal = {
	true,
	false
}
tt.render.sprites[4].anchor.y = 0
tt.render.sprites[4].offset = v(0, 12)
tt.render.sprites[4].group = "shooters"
tt.sound_events.insert = "ElvesRockTaunt"
tt = E:register_t("tower_rock_thrower_2", "tower_rock_thrower_1")
tt.info.enc_icon = 8
tt.tower.level = 2
tt.tower.price = 220
tt.attacks.range = 170
tt.attacks.list[1].bullet = "rock_2"
tt.attacks.list[1].bullet_start_offset = v(0, 47)
tt.render.sprites[2].name = "artillery_base_0002"
tt.render.sprites[3].offsets = {
	v(12, 33),
	v(-12, 33)
}
tt.render.sprites[4].offset = v(0, 13)
tt.render.sprites[5] = table.deepclone(tt.render.sprites[4])
tt.render.sprites[5].prefix = "tower_rock_thrower_shooter_l2"
tt = E:register_t("tower_rock_thrower_3", "tower_rock_thrower_2")
tt.info.enc_icon = 12
tt.tower.level = 3
tt.tower.price = 320
tt.tower.size = TOWER_SIZE_LARGE
tt.attacks.range = 190
tt.attacks.list[1].bullet = "rock_3"
tt.attacks.list[1].bullet_start_offset = v(0, 51)
tt.render.sprites[2].name = "artillery_base_0003"
tt.render.sprites[3].offsets = {
	v(12, 37),
	v(-12, 37)
}
tt.render.sprites[4].offset = v(0, 17)
tt.render.sprites[5].offset = v(0, 17)
tt.render.sprites[6] = table.deepclone(tt.render.sprites[4])
tt.render.sprites[6].prefix = "tower_rock_thrower_shooter_l3"
tt = RT("tower_bastion_holder")

AC(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "editor", "editor_script")

tt.editor.props = {
	{
		"tower.default_rally_pos",
		PT_COORDS
	},
	{
		"tower.holder_id",
		PT_STRING
	},
	{
		"ui.nav_mesh_id",
		PT_STRING
	},
	{
		"editor.game_mode",
		PT_NUMBER
	}
}
tt.editor_script.insert = kr3_scripts.editor_tower.insert
tt.editor_script.remove = kr3_scripts.editor_tower.remove
tt.tower.type = "holder_bastion"
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.tower.menu_offset = v(-10, 16)
tt.info.fn = kr3_scripts.tower_bastion.get_info
tt.info.portrait = (IS_PHONE and "portraits_towers" or "info_portraits_towers") .. "_0020"
tt.info.i18n_key = "ELVES_TOWER_BASTION_BROKEN"
tt.render.sprites[1].name = "galahadriansBastion_layer2_0054"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.3153846153846154
tt.render.sprites[1].offset = IS_CONSOLE and v(0, 24) or v(0, -9)
tt.render.sprites[1].hidden = true
tt.render.sprites[1].hover_off_hidden = true
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "galahadriansBastion_layer2_0054"
tt.render.sprites[2].animated = false
tt.render.sprites[2].anchor.y = 0.3153846153846154
tt.ui.click_rect = r(-40, -10, 80, 90)
tt.ui.has_nav_mesh = true

tt = E:register_t("soldier_barrack_1", "soldier_militia")

E:add_comps(tt, "revive")

image_y = 46
anchor_y = 11 / image_y
tt.health.armor = 0.3
tt.health.dead_lifetime = 14
tt.health.hp_max = 50
tt.health_bar.offset = v(0, 27)
tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
tt.idle_flip.chance = 0.4
tt.idle_flip.cooldown = 5
tt.info.fn = kr3_scripts.soldier_barrack.get_info
tt.info.portrait = "portraits_sc_0001"
tt.info.random_name_count = 25
tt.info.random_name_format = "ELVES_SOLDIER_BARRACKS_%i_NAME"
tt.main_script.insert = kr3_scripts.soldier_barrack.insert
tt.main_script.remove = kr3_scripts.soldier_barrack.remove
tt.main_script.update = kr3_scripts.soldier_barrack.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 4
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].pop = {
	"pop_barrack1",
	"pop_barrack2"
}
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.range = 60
tt.motion.max_speed = 75
tt.regen.cooldown = 1
tt.regen.health = 7
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"running"
}
tt.render.sprites[1].prefix = "soldier_barrack_1"
tt.revive.disabled = true
tt.revive.chance = 0.1
tt.revive.health_recover = 1
tt.revive.fx = "fx_soldier_barrack_revive"
tt.soldier.melee_slot_offset = v(5, 0)
tt.ui.click_rect = r(-10, -2, 20, 25)
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt = E:register_t("soldier_barrack_2", "soldier_barrack_1")

E:add_comps(tt, "ranged")

image_y = 46
anchor_y = 11 / image_y
tt.health.armor = 0.4
tt.health.hp_max = 90
tt.health_bar.offset = v(0, 27)
tt.info.portrait = "portraits_sc_0002"
tt.melee.attacks[1].damage_max = 7
tt.melee.attacks[1].damage_min = 3
tt.ranged.attacks[1].animation = "ranged_attack"
tt.ranged.attacks[1].bullet = "arrow_soldier_barrack_2"
tt.ranged.attacks[1].bullet_start_offset = {
	v(6, 10)
}
tt.ranged.attacks[1].cooldown = 1.2 + fts(15)
tt.ranged.attacks[1].max_range = 140
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].shoot_time = fts(5)
tt.regen.health = 15
tt.render.sprites[1].prefix = "soldier_barrack_2"
tt = E:register_t("soldier_barrack_3", "soldier_barrack_2")
image_y = 46
anchor_y = 11 / image_y
tt.health.armor = 0.5
tt.health.hp_max = 140
tt.health_bar.offset = v(0, 32)
tt.info.portrait = "portraits_sc_0003"
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 8
tt.ranged.attacks[1].bullet = "arrow_soldier_barrack_3"
tt.ranged.attacks[1].cooldown = 1 + fts(15)
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 25
tt.regen.health = 15
tt.render.sprites[1].prefix = "soldier_barrack_3"
tt.unit.mod_offset = v(0, 12)
tt = E:register_t("soldier_bravebark", "soldier_militia")

E:add_comps(tt, "reinforcement")

image_y = 58
anchor_y = 12 / image_y
tt.health.armor = 0
tt.health.hp_max = 50
tt.health_bar.offset = v(0, 44)
tt.health_bar.size = HEALTH_BAR_SIZE_MEDIUM
tt.info.fn = kr3_scripts.soldier_reinforcement.get_info
tt.info.portrait = "portraits_sc_0057"
tt.info.i18n_key = "HERO_ELVES_FOREST_ELEMENTAL_MINION"
tt.info.random_name_format = nil
tt.main_script.insert = kr3_scripts.soldier_reinforcement.insert
tt.main_script.update = kr3_scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(6)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 0
tt.melee.cooldown = 1
tt.melee.range = 60
tt.motion.max_speed = 75
tt.regen.cooldown = 1
tt.regen.health = 0
tt.reinforcement.duration = 20
tt.reinforcement.fade = nil
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "bravebark_mignon"
tt.render.sprites[1].name = "raise"
tt.soldier.melee_slot_offset = v(4, 0)
tt.sound_events.insert = nil
tt.unit.level = 0
tt.unit.mod_offset = v(0, 15)
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN, F_POISON)
tt = E:register_t("soldier_xin_shadow", "soldier")

E:add_comps(tt, "melee")

image_y = 64
anchor_y = 12 / image_y
tt.health.armor = 0
tt.health.hp_max = 50
tt.health.ignore_damage = true
tt.health_bar.hidden = true
tt.info.random_name_format = nil
tt.min_wait = 0.1
tt.max_wait = 0.4
tt.main_script.insert = kr3_scripts.soldier_xin_shadow.insert
tt.main_script.update = kr3_scripts.soldier_xin_shadow.update
tt.motion.max_speed = 90
tt.regen.cooldown = 1
tt.regen.health = 0
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "xin_shadow"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].sort_y_offset = -2
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.insert = nil
tt.sound_events.death = nil
tt.ui.can_click = false
tt.ui.can_select = false
tt.unit.level = 0
tt.unit.mod_offset = v(0, 15)
tt.vis.flags = bor(F_FRIEND)
tt.vis.bans = bor(F_ALL)
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].hit_time = fts(4)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 0
tt.melee.attacks[1].chance = 1

for i = 2, 4 do
	local a = table.deepclone(tt.melee.attacks[1])

	a.animation = "attack" .. i
	a.chance = 1 / i
	tt.melee.attacks[i] = a
end

tt.melee.cooldown = fts(15)
tt.melee.range = 60
tt = E:register_t("soldier_xin_ultimate", "soldier_xin_shadow")
tt.max_attack_count = 2
tt.min_wait = 0.1
tt.max_wait = 0.4

for i = 1, 4 do
	tt.melee.attacks[i].damage_type = DAMAGE_TRUE
	tt.melee.attacks[i].sound = "ElvesHeroXinPandamoniumHit"
end

tt.sound_events.insert = "ElvesHeroXinAfterTeleportIn"
tt.sound_events.death = "ElvesHeroXinAfterTeleportOut"
tt = RT("soldier_catha", "soldier_militia")

AC(tt, "reinforcement", "ranged", "tween")

tt.health.armor = 0
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 45)
tt.info.fn = kr3_scripts.soldier_reinforcement.get_info
tt.info.portrait = "portraits_sc_0066"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.info.i18n_key = "HERO_ELVES_PIXIE_SHADOW"
tt.main_script.insert = kr3_scripts.soldier_reinforcement.insert
tt.main_script.update = kr3_scripts.soldier_reinforcement.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 7
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.range = 60
tt.motion.max_speed = 90
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].bullet = "knife_soldier_catha"
tt.ranged.attacks[1].bullet_start_offset = {
	v(9, 27)
}
tt.ranged.attacks[1].shoot_time = fts(7)
tt.regen.cooldown = 1
tt.regen.health = 10
tt.reinforcement.duration = 10
tt.reinforcement.fade = nil
tt.render.sprites[1].anchor.y = 0.373
tt.render.sprites[1].prefix = "soldier_catha"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].angles.ranged = {
	"shoot",
	"shootUp",
	"shoot"
}
tt.render.sprites[1].angles_custom = {
	ranged = {
		45,
		135,
		210,
		315
	}
}
tt.render.sprites[1].angles_flip_vertical = {
	ranged = true
}
tt.soldier.melee_slot_offset = v(3, 0)
tt.sound_events.death = "ElvesHeroCathaTaleDeath"
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 0)
	},
	{
		fts(6),
		v(0, 0)
	}
}
tt.tween.remove = false
tt.tween.run_once = true
tt.ui.click_rect = r(-10, 0, 20, 30)
tt.unit.level = 0
tt.unit.hit_offset = v(0, 16)
tt.unit.mod_offset = v(0, 22)
tt.unit.hide_after_death = true
tt = RT("soldier_veznan_demon", "soldier_militia")

AC(tt, "reinforcement", "ranged")

tt.health.armor = 0
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 65)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.fn = kr3_scripts.soldier_reinforcement.get_info
tt.info.portrait = "portraits_sc_0058"
tt.info.random_name_count = 8
tt.info.random_name_format = "ELVES_SOLDIER_VEZNAN_DEMON_%i_NAME"
tt.main_script.insert = kr3_scripts.soldier_reinforcement.insert
tt.main_script.update = kr3_scripts.soldier_reinforcement.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].mod = "mod_veznan_demon_fire"
tt.melee.continue_in_cooldown = true

function tt.melee.fn_can_pick(soldier, target)
	return target.template_name ~= "enemy_mantaray"
end

tt.melee.range = 65
tt.motion.max_speed = 75
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 65
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].bullet = "fireball_veznan_demon"
tt.ranged.attacks[1].bullet_start_offset = {
	v(25, 42)
}
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].node_prediction = fts(25)
tt.regen = nil
tt.reinforcement.duration = 30
tt.reinforcement.fade = nil
tt.render.sprites[1].anchor.y = 0.1
tt.render.sprites[1].prefix = "veznan_demon"
tt.render.sprites[1].name = "raise"
tt.soldier.melee_slot_offset = v(10, 0)
tt.sound_events.death = "ElvesHeroVeznanDemonDeath"
tt.ui.click_rect = r(-10, 0, 20, 30)
tt.unit.level = 0
tt.unit.hit_offset = v(0, 30)
tt.unit.mod_offset = v(0, 28)
tt.unit.hide_after_death = true
tt.vis.flags = bor(tt.vis.flags, F_HERO)
tt.vis.bans = bor(F_POISON, F_NET, F_STUN, F_BURN, F_DRIDER_POISON)
tt = RT("soldier_rag", "soldier_militia")

AC(tt, "reinforcement")

tt.health.armor = 0
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 37)
tt.health_bar.size = HEALTH_BAR_SIZE_SMALL
tt.info.fn = kr3_scripts.soldier_reinforcement.get_info
tt.info.portrait = "portraits_sc_0068"
tt.info.i18n_key = "ELVES_SOLDIER_RAG_DOLL"
tt.info.random_name_format = nil
tt.main_script.insert = kr3_scripts.soldier_reinforcement.insert
tt.main_script.update = kr3_scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 0
tt.melee.cooldown = 1
tt.melee.range = 45
tt.motion.max_speed = 60
tt.regen.cooldown = 1
tt.regen.health = 0
tt.reinforcement.duration = nil
tt.reinforcement.fade = nil
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "rag_polymorphed"
tt.render.sprites[1].name = "idle"
tt.soldier.melee_slot_offset = v(4, 0)
tt.unit.level = 0
tt.unit.mod_offset = v(0, 15)
tt.unit.hide_after_death = true
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
tt = RT("soldier_lilith_angel", "soldier_xin_shadow")
tt.angel_damage_type = DAMAGE_TRUE
tt.sound_events.insert = "ElvesHeroLilithAngelsCast"
tt.render.sprites[1].prefix = "lilith_ultimate_angel"
tt.render.sprites[1].anchor.y = 0.1875
tt.max_attack_count = 2
tt.min_wait = 0
tt.max_wait = 0
tt.soldier.melee_slot_offset = v(-13, 0)
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].sound = "ElvesHeroLilithAngelsHit"
tt.melee.attacks[2] = nil
tt.melee.attacks[3] = nil
tt.melee.attacks[4] = nil
tt.melee.cooldown = 0
tt = E:register_t("soldier_re_0", "soldier_militia")

E:add_comps(tt, "reinforcement", "tween")

image_y = 54
anchor_y = 10 / image_y
tt.cooldown = 15
tt.health.armor = 0
tt.health.hp_max = 40
tt.health_bar.offset = v(0, 30)
tt.info.fn = kr3_scripts.soldier_reinforcement.get_info
tt.info.portrait_idxs = {
	38,
	42,
	46
}
tt.info.random_name_format = "ELVES_SOLDIER_REINFORCEMENT_%i_NAME"
tt.info.random_name_count = 20
tt.main_script.insert = kr3_scripts.soldier_reinforcement.insert
tt.main_script.update = kr3_scripts.soldier_reinforcement.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 3
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.range = 60
tt.motion.max_speed = 60
tt.regen.cooldown = 1
tt.regen.health = 15
tt.reinforcement.duration = 20
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "soldier_re_%s0"
tt.soldier.melee_slot_offset = v(3, 0)
tt.sound_events.insert = "ReinforcementTaunt"
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		255
	}
}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.reverse = false
tt.unit.hit_offset = v(0, 5)
tt.unit.mod_offset = v(0, 14)
tt.unit.level = 0
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
tt = E:register_t("soldier_re_1", "soldier_re_0")
tt.unit.level = 1
tt.health.hp_max = 60
tt.health.armor = 0.2
tt.melee.attacks[1].damage_max = 5
tt.melee.attacks[1].damage_min = 3
tt.render.sprites[1].prefix = "soldier_re_%s0"
tt = E:register_t("soldier_re_2", "soldier_re_1")

E:add_comps(tt, "ranged")

tt.unit.level = 2
tt.health.hp_max = 60
tt.health.armor = 0.2
tt.info.portrait_idxs = {
	39,
	43,
	47
}
tt.melee.attacks[1].damage_max = 5
tt.melee.attacks[1].damage_min = 3
tt.render.sprites[1].prefix = "soldier_re_%s1"
tt.ranged.attacks[1].bullet = "arrow_soldier_re_2"
tt.ranged.attacks[1].shoot_time = fts(10)
tt.ranged.attacks[1].cooldown = 1 + fts(18)
tt.ranged.attacks[1].max_range = 140
tt.ranged.attacks[1].min_range = 10
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 22)
}
tt = E:register_t("soldier_re_3", "soldier_re_2")
tt.unit.level = 3
tt.health.hp_max = 100
tt.health.armor = 0.35
tt.info.portrait_idxs = {
	40,
	44,
	48
}
tt.melee.attacks[1].damage_max = 10
tt.melee.attacks[1].damage_min = 5
tt.render.sprites[1].prefix = "soldier_re_%s2"
tt.ranged.attacks[1].bullet = "arrow_soldier_re_3"
tt.ranged.attacks[1].max_range = 150
tt = E:register_t("soldier_re_4", "soldier_re_3")
tt.cooldown = 10
tt.unit.level = 4
tt.health.hp_max = 100
tt.health.armor = 0.35
tt.info.portrait_idxs = {
	40,
	44,
	48
}
tt.melee.attacks[1].damage_max = 10
tt.melee.attacks[1].damage_min = 5
tt.render.sprites[1].prefix = "soldier_re_%s2"
tt.ranged.attacks[1].bullet = "arrow_soldier_re_4"
tt.ranged.attacks[1].max_range = 150
tt = E:register_t("soldier_re_5", "soldier_re_4")
tt.unit.level = 5
tt.health.hp_max = 150
tt.health.armor = 0.5
tt.health_bar.offset = v(0, 46)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait_idxs = {
	41,
	45,
	49
}
tt.melee.attacks[1].damage_max = 15
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(11)
tt.motion.max_speed = 84
tt.render.sprites[1].prefix = "soldier_re_%s3"
tt.ranged.attacks[1].bullet = "arrow_soldier_re_5"
tt.ranged.attacks[1].max_range = 160
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 36)
}
tt.soldier.melee_slot_offset = v(8, 0)
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(0, 22)

for i, k in ipairs({
	"A",
	"B",
	"C"
}) do
	for j = 0, 5 do
		local name = string.format("soldier_re_%i", j)
		local base_t = E:get_template(name)
		local fn = name .. "_" .. i
		local t = E:register_t(fn, base_t)

		t.render.sprites[1].prefix = string.format(t.render.sprites[1].prefix, k)
		t.info.portrait = string.format("portraits_sc_00%02d", t.info.portrait_idxs[i])
	end
end

-- for i = 1, 3 do
-- 	E:set_template("re_current_" .. i, E:get_template("soldier_re_0_" .. i))
-- end

tt = E:register_t("hero_elves_denas", "hero")

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {
	0.38,
	0.41,
	0.44,
	0.47,
	0.5,
	0.53,
	0.56,
	0.59,
	0.62,
	0.65
}
tt.hero.level_stats.hp_max = {
	265,
	280,
	295,
	310,
	325,
	340,
	355,
	370,
	385,
	400
}
tt.hero.level_stats.melee_damage_max = {
	14,
	17,
	19,
	21,
	23,
	25,
	27,
	30,
	32,
	34
}
tt.hero.level_stats.melee_damage_min = {
	10,
	11,
	12,
	14,
	15,
	17,
	18,
	20,
	21,
	23
}
tt.hero.level_stats.regen_health = {
	18,
	19,
	20,
	21,
	22,
	23,
	24,
	25,
	26,
	27
}
tt.hero.skills.celebrity = E:clone_c("hero_skill")
tt.hero.skills.celebrity.hr_cost = {
	1,
	2,
	3
}
tt.hero.skills.celebrity.hr_icon = "0022"
tt.hero.skills.celebrity.hr_order = 2
tt.hero.skills.celebrity.max_targets = {
	3,
	6,
	9
}
tt.hero.skills.celebrity.stun_duration = {
	1,
	2,
	3
}
tt.hero.skills.celebrity.xp_gain = {
	50,
	150,
	300
}
tt.hero.skills.mighty = E:clone_c("hero_skill")
tt.hero.skills.mighty.damage_max = {
	134,
	226,
	320
}
tt.hero.skills.mighty.damage_min = {
	70,
	122,
	171
}
tt.hero.skills.mighty.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.mighty.hr_icon = "0023"
tt.hero.skills.mighty.hr_order = 3
tt.hero.skills.mighty.xp_gain = {
	63,
	126,
	189
}
tt.hero.skills.shield_strike = E:clone_c("hero_skill")
tt.hero.skills.shield_strike.damage_max = {
	36,
	46,
	52
}
tt.hero.skills.shield_strike.damage_min = {
	20,
	26,
	30
}
tt.hero.skills.shield_strike.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.shield_strike.hr_icon = "0024"
tt.hero.skills.shield_strike.hr_order = 4
tt.hero.skills.shield_strike.rebounds = {
	3,
	4,
	5
}
tt.hero.skills.shield_strike.xp_gain = {
	25,
	50,
	75
}
tt.hero.skills.sybarite = E:clone_c("hero_skill")
tt.hero.skills.sybarite.heal_hp = {
	80,
	160,
	240
}
tt.hero.skills.sybarite.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.sybarite.hr_icon = "0021"
tt.hero.skills.sybarite.hr_order = 1
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_elves_denas_ultimate"
tt.hero.skills.ultimate.hr_cost = {
	4,
	4,
	4
}
tt.hero.skills.ultimate.hr_icon = "0025"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.key = "DEFENDER"
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 46)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_elves_denas.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.fn = kr3_scripts.hero_basic.get_info_melee
tt.info.hero_portrait = "hero_portraits_0005"
tt.info.i18n_key = "HERO_ELVES_DENAS"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0005"
tt.info.ultimate_icon = "0005"
tt.main_script.insert = kr3_scripts.hero_elves_denas.insert
tt.main_script.update = kr3_scripts.hero_elves_denas.update
tt.motion.max_speed = 2.5 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.21111111111111
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_elves_denas"
tt.soldier.melee_slot_offset = v(10, 0)
tt.sound_events.change_rally_point = "ElvesHeroDenasTaunt"
tt.sound_events.death = "ElvesHeroDenasDeath"
tt.sound_events.respawn = "ElvesHeroDenasTauntIntro"
tt.sound_events.insert = "ElvesHeroDenasTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroDenasTauntSelect"
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(0, 13)
tt.melee.attacks[1] = E:clone_c("melee_attack")
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 0.95
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = E:clone_c("melee_attack")
tt.melee.attacks[3].animation = "specialAttack"
tt.melee.attacks[3].cooldown = 18
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].hit_time = fts(25)
tt.melee.attacks[3].sound = "ElvesHeroDenasMighty"
tt.melee.attacks[3].sound_args = {
	delay = fts(17)
}
tt.melee.attacks[3].xp_from_skill = "mighty"
tt.melee.range = 72.5
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].bullet = "shield_elves_denas"
tt.ranged.attacks[1].bullet_start_offset = {
	v(22, 16)
}
tt.ranged.attacks[1].cooldown = 15
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].rebound_range = 125
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].animation = "shieldThrow"
tt.ranged.attacks[1].xp_from_skill = "shield_strike"
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "showOff"
tt.timed_attacks.list[1].cooldown = 25
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_time = fts(9)
tt.timed_attacks.list[1].mod = "mod_elves_denas_celebrity"
tt.timed_attacks.list[1].range = 100
tt.timed_attacks.list[1].sound = "ElvesHeroDenasCelebrity"
tt.timed_attacks.list[1].vis_bans = bor(F_BOSS)
tt.timed_attacks.list[1].vis_flags = bor(F_MOD, F_RANGED, F_STUN)
tt.timed_attacks.list[1].xp_from_skill = "celebrity"
tt.timed_attacks.list[2] = E:clone_c("mod_attack")
tt.timed_attacks.list[2].animation = "eat"
tt.timed_attacks.list[2].cooldown = 20
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].hit_time = fts(37)
tt.timed_attacks.list[2].lost_health = 100
tt.timed_attacks.list[2].mod = "mod_elves_denas_sybarite"
tt.timed_attacks.list[2].sound = "ElvesHeroDenasSybarite"
tt.wealthy = {}
tt.wealthy.animation = "coinThrow"
tt.wealthy.gold = 25
tt.wealthy.sound = "ElvesHeroDenasWealthy"
tt.wealthy.last_wave = 1
tt.wealthy.hit_time = fts(9)
tt.wealthy.fx = "fx_coin_jump"
tt = E:register_t("hero_elves_denas_ultimate")

E:add_comps(tt, "pos", "main_script", "sound_events")

tt.cooldown = 60
tt.guards_count = {
	[0] = 2,
	3,
	4,
	5
}
tt.guards_template = "soldier_elves_denas_guard"
tt.main_script.update = kr3_scripts.hero_elves_denas_ultimate.update
tt.sound_events.insert = "ElvesHeroDenasKingsguardTaunt"
tt.can_fire_fn = kr3_scripts.hero_elves_denas_ultimate.can_fire_fn
tt = E:register_t("soldier_elves_denas_guard", "soldier_militia")

E:add_comps(tt, "reinforcement", "tween")

image_y = 80
anchor_y = 12 / image_y
tt.health.armor = 0.4
tt.health.hp_max = 200
tt.health_bar.offset = v(0, 40)
tt.info.fn = kr3_scripts.soldier_reinforcement.get_info
tt.info.portrait = "portraits_sc_0059"
tt.info.random_name_count = 15
tt.info.random_name_format = "ELVES_SOLDIER_IMPERIAL_%i_NAME"
tt.main_script.insert = kr3_scripts.soldier_reinforcement.insert
tt.main_script.update = kr3_scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].chance = 0.5
tt.melee.attacks[1].xp_gain_factor = 0
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.cooldown = 1
tt.melee.range = 72.5
tt.motion.max_speed = 75
tt.regen.cooldown = 1
tt.regen.health = 20
tt.reinforcement.duration = 25
tt.reinforcement.fade = nil
tt.reinforcement.fade_out = true
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "elves_denas_guard"
tt.render.sprites[1].name = "raise"
tt.sound_events.insert = nil
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		255
	}
}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.disabled = true
tt.unit.level = 0
tt.vis.bans = bor(F_SKELETON, F_LYCAN)
tt = E:register_t("mod_elves_denas_celebrity", "mod_shock_and_awe")
tt.modifier.duration = nil
tt = E:register_t("mod_elves_denas_sybarite", "modifier")

E:add_comps(tt, "render")

tt.inflicted_damage_factor = 2
tt.heal_hp = nil
tt.main_script.insert = kr3_scripts.mod_elves_denas_sybarite.insert
tt.main_script.remove = kr3_scripts.mod_elves_denas_sybarite.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.modifier.bans = {
	"mod_son_of_mactans_poison",
	"mod_drider_poison",
	"mod_dark_spitters",
	"mod_balrog"
}
tt.modifier.duration = fts(22)
tt.render.sprites[1].name = "fx_elves_denas_heal"
tt = E:register_t("fx_elves_denas_flash", "fx")
tt.render.sprites[1].name = "fx_elves_denas_flash"
tt = E:register_t("shield_elves_denas", "bullet")
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.particles_name = "ps_shield_elves_denas"
tt.bullet.max_speed = 10 * FPS
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.hit_fx = "fx_shield_elves_denas_hit"
tt.main_script.update = kr3_scripts.shield_elves_denas.update
tt.render.sprites[1].name = "shield_elves_denas_loop"
tt.rebound_range = 125
tt = E:register_t("fx_shield_elves_denas_hit", "fx")
tt.render.sprites[1].name = "fx_shield_elves_denas_hit"
tt.render.sprites[1].z = Z_EFFECTS - 1
tt = E:register_t("hero_regson", "hero")

E:add_comps(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.hp_max = {
	300,
	320,
	340,
	360,
	380,
	400,
	420,
	440,
	460,
	480
}
tt.hero.level_stats.melee_damage_max = {
	9,
	10,
	11,
	12,
	13,
	14,
	15,
	16,
	17,
	18
}
tt.hero.level_stats.melee_damage_min = {
	6,
	6,
	7,
	8,
	9,
	9,
	10,
	11,
	12,
	12
}
tt.hero.level_stats.regen_health = {
	30,
	32,
	34,
	36,
	38,
	40,
	42,
	44,
	46,
	48
}
tt.hero.skills.blade = E:clone_c("hero_skill")
tt.hero.skills.blade.damage = {
	60,
	100,
	140
}
tt.hero.skills.blade.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.blade.hr_icon = "0017"
tt.hero.skills.blade.hr_order = 2
tt.hero.skills.blade.instakill_chance = {
	0.01,
	0.02,
	0.03
}
tt.hero.skills.blade.xp_gain = {
	90,
	180,
	270
}
tt.hero.skills.heal = E:clone_c("hero_skill")
tt.hero.skills.heal.heal_factor = {
	0.05,
	0.15,
	0.3
}
tt.hero.skills.heal.hr_cost = {
	1,
	2,
	3
}
tt.hero.skills.heal.hr_icon = "0016"
tt.hero.skills.heal.hr_order = 1
tt.hero.skills.path = E:clone_c("hero_skill")
tt.hero.skills.path.extra_hp = {
	40,
	80,
	120
}
tt.hero.skills.path.hr_cost = {
	1,
	1,
	1
}
tt.hero.skills.path.hr_icon = "0019"
tt.hero.skills.path.hr_order = 4
tt.hero.skills.slash = E:clone_c("hero_skill")
tt.hero.skills.slash.cooldown = {
	12
}
tt.hero.skills.slash.damage_max = {
	60,
	130,
	225
}
tt.hero.skills.slash.damage_min = {
	20,
	45,
	75
}
tt.hero.skills.slash.hr_cost = {
	2,
	3,
	4
}
tt.hero.skills.slash.hr_icon = "0018"
tt.hero.skills.slash.hr_order = 3
tt.hero.skills.slash.range = {
	200,
	200,
	200
}
tt.hero.skills.slash.targets = {
	3,
	3,
	3
}
tt.hero.skills.slash.xp_gain = {
	28,
	84,
	168
}
tt.hero.skills.slash.xp_gain_factor = 0
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_regson_ultimate"
tt.hero.skills.ultimate.cooldown = {
	[0] = 200,
	100,
	70,
	50
}
tt.hero.skills.ultimate.damage_boss = {
	[0] = 500,
	1000,
	1500,
	2000
}
tt.hero.skills.ultimate.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.ultimate.hr_icon = "0020"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.key = "VINDICATOR"
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_regson.level_up
tt.hero.tombstone_show_time = fts(90)
tt.idle_flip.animations = {
	"idle"
}
tt.info.fn = kr3_scripts.hero_basic.get_info_melee
tt.info.i18n_key = "HERO_ELVES_ELDRITCH"
tt.info.hero_portrait = "hero_portraits_0004"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0004"
tt.info.ultimate_icon = "0004"
tt.main_script.insert = kr3_scripts.hero_regson.insert
tt.main_script.update = kr3_scripts.hero_regson.update
tt.motion.max_speed = 3.5 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.3
tt.render.sprites[1].prefix = "hero_regson"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"run"
}
tt.render.sprites[1].name = "idle"
tt.soldier.melee_slot_offset = v(2, 0)
tt.sound_events.change_rally_point = "ElvesHeroEldritchTaunt"
tt.sound_events.death = "ElvesHeroEldritchDeath"
tt.sound_events.respawn = "ElvesHeroEldritchTauntIntro"
tt.sound_events.insert = "ElvesHeroEldritchTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroEldritchTauntSelect"
tt.unit.hit_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 14)
tt.melee.attacks[1].animation = "attack1"
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 0.93
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[3].animation = "attack3"
tt.melee.attacks[3].chance = 0.3333333333333333
tt.melee.attacks[4] = E:clone_c("melee_attack")
tt.melee.attacks[4].animations = {
	nil,
	"berserk_attack"
}
tt.melee.attacks[4].damage_type = DAMAGE_TRUE
tt.melee.attacks[4].disabled = true
tt.melee.attacks[4].hit_times = {
	fts(10),
	fts(24)
}
tt.melee.attacks[4].interrupt_on_dead_target = true
tt.melee.attacks[4].loops = 1
tt.melee.attacks[4].shared_cooldown = true
tt.melee.attacks[4].sound_hit = "ElvesHeroEldritchBlade"
tt.melee.attacks[4].xp_from_skill = "blade"
tt.melee.attacks[5] = table.deepclone(tt.melee.attacks[4])
tt.melee.attacks[5].chance = nil
tt.melee.attacks[5].disabled = true
tt.melee.attacks[5].instakill = true
tt.melee.attacks[5].vis_bans = bor(F_BOSS)
tt.melee.attacks[5].vis_flags = bor(F_INSTAKILL)
tt.melee.attacks[6] = E:clone_c("area_attack")
tt.melee.attacks[6].animation = "whirlwind"
tt.melee.attacks[6].cooldown = 12
tt.melee.attacks[6].count = 3
tt.melee.attacks[6].damage_radius = 100
tt.melee.attacks[6].damage_type = DAMAGE_NONE
tt.melee.attacks[6].disabled = true
tt.melee.attacks[6].hit_time = fts(5)
tt.melee.attacks[6].mod = "mod_regson_slash"
tt.melee.attacks[6].sound = "ElvesHeroEldritchSlash"
tt.melee.attacks[6].xp_from_skill = "slash"
tt.melee.cooldown = 0.6
tt.melee.range = 65
tt = E:register_t("aura_regson_blade", "aura")
tt.aura.duration = -1
tt.main_script.update = kr3_scripts.aura_regson_blade.update
tt.blade_cooldown = 25
tt.blade_duration = 5 + fts(17)
tt = E:register_t("aura_regson_heal", "aura")
tt.aura.duration = -1
tt.aura.radius = 150
tt.aura.cycle_time = fts(12)
tt.aura.vis_bans = bor(F_BOSS)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = kr3_scripts.aura_regson_heal.update
tt = E:register_t("mod_regson_heal", "modifier")
tt.modifier.duration = fts(40)
tt.main_script.update = kr3_scripts.mod_regson_heal.update
tt = E:register_t("decal_regson_heal_ball", "decal_scripted")

E:add_comps(tt, "force_motion")

tt.render.sprites[1].name = "regson_heal_ball_travel"
tt.render.sprites[1].offset.y = 10
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.hp_factor = nil
tt.force_motion.max_a = 5400
tt.force_motion.max_v = 180
tt.force_motion.a_step = 10
tt.force_motion.max_flight_height = 60
tt.main_script.update = kr3_scripts.decal_regson_heal_ball.update
tt = E:register_t("fx_regson_heal_ball_spawn", "fx")
tt.render.sprites[1].name = "fx_regson_heal_ball_spawn"
tt.render.sprites[1].anchor.y = 0.35
tt = E:register_t("fx_regson_heal", "fx")
tt.render.sprites[1].name = "fx_regson_heal"
tt.render.sprites[1].sort_y_offset = -1
tt = E:register_t("mod_regson_slash", "modifier")

E:add_comps(tt, "render")

tt.damage_type = DAMAGE_PHYSICAL
tt.damage_max = nil
tt.damage_min = nil
tt.delay_per_idx = 0.13
tt.hit_time = fts(4)
tt.main_script.update = kr3_scripts.mod_regson_slash.update
tt.modifier.duration = fts(11)
tt.render.sprites[1].name = "fx_regson_slash"
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].loop = false
tt = E:register_t("hero_regson_ultimate")

E:add_comps(tt, "pos", "main_script", "sound_events", "render")

tt.can_fire_fn = kr3_scripts.hero_regson_ultimate.can_fire_fn
tt.main_script.update = kr3_scripts.hero_regson_ultimate.update
tt.render.sprites[1].name = "fx_regson_ultimate"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_EFFECTS
tt.sound_events.insert = "ElvesHeroEldritchVindicator"
tt.range = 50
tt.vis_flags = F_RANGED
tt.vis_bans = 0
tt.hit_time = fts(20)
tt = E:register_t("hero_faustus", "hero")

E:add_comps(tt, "ranged", "timed_attacks")

tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.hp_max = {
	400,
	425,
	450,
	475,
	500,
	525,
	550,
	575,
	600,
	625
}
tt.hero.level_stats.melee_damage_max = {
	1,
	2,
	4,
	4,
	5,
	6,
	7,
	8,
	9,
	10
}
tt.hero.level_stats.melee_damage_min = {
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10
}
tt.hero.level_stats.regen_health = {
	20,
	21,
	23,
	24,
	25,
	26,
	28,
	29,
	30,
	31
}
tt.hero.level_stats.ranged_damage_min = {
	9,
	11,
	13,
	15,
	16,
	18,
	20,
	22,
	24,
	25
}
tt.hero.level_stats.ranged_damage_max = {
	14,
	16,
	19,
	22,
	24,
	27,
	30,
	33,
	35,
	38
}
tt.hero.skills.dragon_lance = E:clone_c("hero_skill")
tt.hero.skills.dragon_lance.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.dragon_lance.hr_icon = "0041"
tt.hero.skills.dragon_lance.hr_order = 1
tt.hero.skills.dragon_lance.damage_min = {
	105,
	185,
	270
}
tt.hero.skills.dragon_lance.damage_max = {
	195,
	345,
	500
}
tt.hero.skills.dragon_lance.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.teleport_rune = E:clone_c("hero_skill")
tt.hero.skills.teleport_rune.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.teleport_rune.hr_icon = "0042"
tt.hero.skills.teleport_rune.hr_order = 2
tt.hero.skills.teleport_rune.xp_gain = {
	75,
	150,
	225
}
tt.hero.skills.teleport_rune.max_targets = {
	2,
	4,
	6
}
tt.hero.skills.enervation = E:clone_c("hero_skill")
tt.hero.skills.enervation.duration = {
	6,
	9,
	12
}
tt.hero.skills.enervation.hr_cost = {
	1,
	2,
	3
}
tt.hero.skills.enervation.hr_icon = "0043"
tt.hero.skills.enervation.hr_order = 3
tt.hero.skills.enervation.max_targets = {
	1,
	2,
	3
}
tt.hero.skills.enervation.xp_gain = {
	30,
	90,
	180
}
tt.hero.skills.liquid_fire = E:clone_c("hero_skill")
tt.hero.skills.liquid_fire.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.liquid_fire.hr_icon = "0044"
tt.hero.skills.liquid_fire.hr_order = 4
tt.hero.skills.liquid_fire.flames_count = {
	6,
	12,
	18
}
tt.hero.skills.liquid_fire.mod_damage = {
	3,
	5,
	7
}
tt.hero.skills.liquid_fire.xp_gain = {
	120,
	240,
	360
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.ultimate.hr_icon = "0045"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.xp_gain = {
	0,
	0,
	0
}
tt.hero.skills.ultimate.mod_damage = {
	[0] = 2,
	3,
	5,
	7
}
tt.hero.skills.ultimate.controller_name = "hero_faustus_ultimate"
tt.hero.skills.ultimate.key = "DRAGON_RAGE"
tt.health.dead_lifetime = 30
tt.health_bar.draw_order = -1
tt.health_bar.offset = v(0, 189)
tt.health_bar.sort_y_offset = -200
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.hero.fn_level_up = kr3_scripts.hero_faustus.level_up
tt.hero.tombstone_show_time = nil
tt.hero.use_custom_spawn_point = true
tt.idle_flip.cooldown = 10
tt.info.damage_icon = "magic"
tt.info.fn = kr3_scripts.hero_faustus.get_info
tt.info.hero_portrait = "hero_portraits_0009"
tt.info.i18n_key = "HERO_ELVES_FAUSTUS"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0009"
tt.info.ultimate_icon = "0009"
tt.info.ultimate_pointer_style = "area"
tt.main_script.insert = kr3_scripts.hero_faustus.insert
tt.main_script.update = kr3_scripts.hero_faustus.update
tt.motion.max_speed = 6 * FPS
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = TERRAIN_ALL_MASK
tt.nav_grid.valid_terrains_dest = TERRAIN_ALL_MASK
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].prefix = "hero_faustus"
tt.render.sprites[1].angles.walk = {
	"idle"
}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "faustus_hero_0233"
tt.render.sprites[2].anchor.y = 0.045
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].alpha = 90
tt.soldier.melee_slot_offset = v(0, 0)
tt.sound_events.change_rally_point = "ElvesHeroFaustusTaunt"
tt.sound_events.death = "ElvesHeroFaustusDeath"
tt.sound_events.respawn = "ElvesHeroFaustusTauntIntro"
tt.sound_events.insert = "ElvesHeroFaustusTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroFaustusTauntSelect"
tt.ui.click_rect = IS_PHONE and r(-35, 90, 70, 75) or r(-25, 100, 50, 55)
tt.unit.hit_offset = v(0, 135)
tt.unit.hide_after_death = true
tt.unit.mod_offset = v(0, 134)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_faustus"
tt.ranged.attacks[1].bullet_start_offset = {
	v(26, 80)
}
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].bullet_count = 3
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].extra_range = 80
tt.ranged.attacks[1].shoot_time = fts(12)
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].animation = "attackBase"
tt.ranged.attacks[1].start_fx = "fx_faustus_start_attack"
tt.ranged.attacks[1].sound = "ElvesHeroFaustusAttack"
tt.ranged.attacks[2] = E:clone_c("bullet_attack")
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].bullet = "bolt_lance_faustus"
tt.ranged.attacks[2].bullet_start_offset = {
	v(22, 110)
}
tt.ranged.attacks[2].cooldown = 25
tt.ranged.attacks[2].min_range = 20
tt.ranged.attacks[2].max_range = 150
tt.ranged.attacks[2].shoot_time = fts(22)
tt.ranged.attacks[2].sync_animation = true
tt.ranged.attacks[2].animation = "altAttackBase"
tt.ranged.attacks[2].start_fx = "fx_faustus_start_lance"
tt.ranged.attacks[2].start_sound = "ElvesHeroFaustusRayKill"
tt.ranged.attacks[2].start_sound_args = {
	delay = fts(12)
}
tt.ranged.attacks[2].target_offset_rect = r(40, -80, 110, 160)
tt.ranged.attacks[2].estimated_flight_time = 1
tt.ranged.attacks[2].xp_from_skill = "dragon_lance"
tt.ranged.attacks[3] = E:clone_c("aura_attack")
tt.ranged.attacks[3].disabled = true
tt.ranged.attacks[3].bullet = "aura_teleport_faustus"
tt.ranged.attacks[3].cooldown = 28
tt.ranged.attacks[3].min_range = 0
tt.ranged.attacks[3].max_range = 100
tt.ranged.attacks[3].shoot_time = fts(16)
tt.ranged.attacks[3].sync_animation = true
tt.ranged.attacks[3].animation = "altAttackBase"
tt.ranged.attacks[3].start_fx = "fx_faustus_start_teleport"
tt.ranged.attacks[3].start_sound = "ElvesHeroFaustusTeleport"
tt.ranged.attacks[3].start_sound_args = {
	delay = fts(12)
}
tt.ranged.attacks[3].estimated_flight_time = 1
tt.ranged.attacks[3].vis_flags = bor(F_RANGED, F_TELEPORT)
tt.ranged.attacks[3].vis_bans = bor(F_BOSS)
tt.ranged.attacks[3].xp_from_skill = "teleport_rune"
tt.ranged.attacks[4] = E:clone_c("aura_attack")
tt.ranged.attacks[4].disabled = true
tt.ranged.attacks[4].bullet = "aura_enervation_faustus"
tt.ranged.attacks[4].cooldown = 20
tt.ranged.attacks[4].min_range = 25
tt.ranged.attacks[4].max_range = 100
tt.ranged.attacks[4].shoot_time = fts(4)
tt.ranged.attacks[4].sync_animation = true
tt.ranged.attacks[4].animation = "idle"
tt.ranged.attacks[4].start_fx = "fx_faustus_start_enervation"
tt.ranged.attacks[4].start_sound = "ElvesHeroFaustusEnervation"
tt.ranged.attacks[4].estimated_flight_time = 0
tt.ranged.attacks[4].vis_flags = bor(F_RANGED, F_SPELLCASTER)
tt.ranged.attacks[4].vis_bans = bor(F_BOSS)
tt.ranged.attacks[4].xp_from_skill = "enervation"
tt.ranged.attacks[5] = E:clone_c("bullet_attack")
tt.ranged.attacks[5].animation = "attackBase"
tt.ranged.attacks[5].bullet = "bullet_liquid_fire_faustus"
tt.ranged.attacks[5].bullet_start_offset = {
	v(30, 86)
}
tt.ranged.attacks[5].cooldown = 40
tt.ranged.attacks[5].disabled = true
tt.ranged.attacks[5].estimated_flight_time = fts(10)
tt.ranged.attacks[5].max_range = 180
tt.ranged.attacks[5].min_range = 50
tt.ranged.attacks[5].min_count = 3
tt.ranged.attacks[5].max_count_range = 120
tt.ranged.attacks[5].min_count_nodes_offset = -5
tt.ranged.attacks[5].shoot_time = fts(12)
tt.ranged.attacks[5].start_fx = "fx_faustus_start_liquid_fire"
tt.ranged.attacks[5].start_sound = "ElvesHeroFaustusFire"
tt.ranged.attacks[5].sync_animation = true
tt.ranged.attacks[5].target_offset_rect = r(50, -80, 130, 160)
tt.ranged.attacks[5].vis_bans = bor(F_FLYING)
tt.ranged.attacks[5].vis_flags = bor(F_RANGED)
tt.ranged.attacks[5].xp_from_skill = "liquid_fire"
tt = E:register_t("hero_faustus_ultimate")

E:add_comps(tt, "pos", "main_script", "sound_events")

tt.can_fire_fn = kr3_scripts.hero_faustus_ultimate.can_fire_fn
tt.cooldown = 40
tt.main_script.update = kr3_scripts.hero_faustus_ultimate.update
tt.sound_events.insert = "ElvesHeroFaustusUltimate"
tt.separation_nodes = 20
tt.show_delay = 0.5
tt = E:register_t("decal_minidragon_faustus", "decal_scripted")

E:add_comps(tt, "motion", "attacks")

tt.main_script.update = kr3_scripts.decal_minidragon_faustus.update
tt.motion.max_speed = 10 * FPS
tt.attacks.list[1] = E:clone_c("aura_attack")
tt.attacks.list[1].disabled = true
tt.attacks.list[1].bullet = "aura_minidragon_faustus"
tt.attacks.list[1].bullet_start_offset = v(25, 70)
tt.attacks.list[1].cooldown = fts(2)
tt.attacks.list[1].sound = "ElvesHeroFaustusFire"
tt.render.sprites[1].prefix = "minidragon_faustus_l1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].offset = v(0, 70)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "minidragon_faustus_l2"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = v(0, 70)
tt.emit_ox = 180
tt.cast_ox = 80
tt.image_w = 40
tt = E:register_t("hero_bravebark", "hero")

E:add_comps(tt, "melee", "teleport", "timed_attacks")

tt.hero.level_stats.armor = {
	0.04,
	0.08,
	0.12,
	0.16,
	0.2,
	0.24,
	0.28,
	0.32,
	0.36,
	0.4
}
tt.hero.level_stats.hp_max = {
	375,
	400,
	425,
	450,
	475,
	500,
	525,
	550,
	575,
	600
}
tt.hero.level_stats.melee_damage_max = {
	29,
	34,
	38,
	43,
	48,
	53,
	58,
	62,
	67,
	72
}
tt.hero.level_stats.melee_damage_min = {
	19,
	22,
	26,
	29,
	32,
	35,
	38,
	42,
	45,
	48
}
tt.hero.level_stats.regen_health = {
	19,
	20,
	21,
	23,
	24,
	25,
	26,
	28,
	29,
	30
}
tt.hero.skills.rootspikes = E:clone_c("hero_skill")
tt.hero.skills.rootspikes.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.rootspikes.hr_icon = "0031"
tt.hero.skills.rootspikes.hr_order = 1
tt.hero.skills.rootspikes.damage_max = {
	50,
	90,
	120
}
tt.hero.skills.rootspikes.damage_min = {
	30,
	50,
	80
}
tt.hero.skills.rootspikes.xp_gain = {
	100,
	200,
	300
}
tt.hero.skills.oakseeds = E:clone_c("hero_skill")
tt.hero.skills.oakseeds.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.oakseeds.hr_icon = "0032"
tt.hero.skills.oakseeds.hr_order = 2
tt.hero.skills.oakseeds.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.oakseeds.soldier_hp_max = {
	50,
	100,
	150
}
tt.hero.skills.oakseeds.soldier_damage_max = {
	4,
	8,
	12
}
tt.hero.skills.oakseeds.soldier_damage_min = {
	2,
	4,
	6
}
tt.hero.skills.branchball = E:clone_c("hero_skill")
tt.hero.skills.branchball.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.branchball.hr_icon = "0033"
tt.hero.skills.branchball.hr_order = 3
tt.hero.skills.branchball.hp_max = {
	200,
	500,
	9000000000
}
tt.hero.skills.branchball.xp_gain = {
	157,
	314,
	471
}
tt.hero.skills.springsap = E:clone_c("hero_skill")
tt.hero.skills.springsap.duration = {
	2,
	3,
	4
}
tt.hero.skills.springsap.hp_per_cycle = {
	7,
	14,
	21
}
tt.hero.skills.springsap.hr_cost = {
	1,
	2,
	3
}
tt.hero.skills.springsap.hr_icon = "0034"
tt.hero.skills.springsap.hr_order = 4
tt.hero.skills.springsap.xp_gain = {
	0,
	0,
	0
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.ultimate.hr_icon = "0035"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.controller_name = "hero_bravebark_ultimate"
tt.hero.skills.ultimate.count = {
	[0] = 6,
	9,
	12,
	15
}
tt.hero.skills.ultimate.damage = {
	[0] = 30,
	40,
	50,
	60
}
tt.hero.skills.ultimate.key = "NATURESWRAITH"
tt.health.dead_lifetime = 25
tt.health_bar.offset = v(0, 62)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_bravebark.level_up
tt.hero.hide_after_death = false
tt.hero.tombstone_show_time = nil
tt.info.i18n_key = "HERO_ELVES_FOREST_ELEMENTAL"
tt.info.ultimate_icon = "0007"
tt.info.ultimate_pointer_style = "area"
tt.info.fn = kr3_scripts.hero_basic.get_info_melee
tt.info.hero_portrait = "hero_portraits_0007"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0007"
tt.main_script.update = kr3_scripts.hero_bravebark.update
tt.motion.max_speed = 2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.15517241379310345
tt.render.sprites[1].prefix = "hero_bravebark"
tt.soldier.melee_slot_offset = v(24, 0)
tt.sound_events.change_rally_point = "ElvesHeroForestElementalTaunt"
tt.sound_events.death = "ElvesHeroForestElementalDeath"
tt.sound_events.respawn = "ElvesHeroForestElementalTauntIntro"
tt.sound_events.insert = "ElvesHeroForestElementalTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroForestElementalTauntSelect"
tt.teleport.min_distance = 140
tt.teleport.delay = fts(21)
tt.teleport.fx_out = "fx_bravebark_teleport_out"
tt.teleport.fx_in = "fx_bravebark_teleport_in"
tt.ui.click_rect = IS_PHONE and r(-35, -15, 70, 80) or r(-20, -5, 40, 60)
tt.unit.hit_offset = v(0, 25)
tt.unit.mod_offset = v(0, 25)
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].hit_time = fts(16)
tt.melee.attacks[1].hit_fx = "fx_bravebark_melee_hit"
tt.melee.attacks[1].hit_decal = "decal_bravebark_melee_hit"
tt.melee.attacks[1].hit_offset = v(42, 0)
tt.melee.attacks[1].xp_gain_factor = 0.39
tt.melee.attacks[1].sound_hit = "ElvesHeroForestElementalAttack"
tt.melee.attacks[2] = E:clone_c("melee_attack")
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].cooldown = 35
tt.melee.attacks[2].hp_max = nil
tt.melee.attacks[2].fn_can = function(t, s, a, target)
	return target.health.hp <= a.hp_max
end
tt.melee.attacks[2].mod = "mod_bravebark_branchball"
tt.melee.attacks[2].damage_type = bor(DAMAGE_NONE, DAMAGE_NO_DODGE)
tt.melee.attacks[2].animation = "branchBall"
tt.melee.attacks[2].hit_time = 0
tt.melee.attacks[2].ignore_rally_change = true
tt.melee.attacks[2].vis_bans = bor(F_BOSS)
tt.melee.attacks[2].vis_flags = bor(F_BLOCK, F_EAT, F_INSTAKILL)
tt.melee.attacks[2].xp_from_skill = "branchball"
tt.melee.range = 65
tt.timed_attacks.list[1] = E:clone_c("area_attack")
tt.timed_attacks.list[1].animation = "rootSpikes"
tt.timed_attacks.list[1].cooldown = 25
tt.timed_attacks.list[1].damage_radius = 100
tt.timed_attacks.list[1].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[1].decal_range = 50
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_decal = "decal_bravebark_rootspikes_hit"
tt.timed_attacks.list[1].hit_offset = v(35, 0)
tt.timed_attacks.list[1].hit_time = fts(17)
tt.timed_attacks.list[1].max_range = 75
tt.timed_attacks.list[1].sound = "ElvesHeroForestElementalSpikes"
tt.timed_attacks.list[1].trigger_count = 3
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_BLOCK)
tt.timed_attacks.list[1].xp_from_skill = "rootspikes"
tt.timed_attacks.list[2] = E:clone_c("spawn_attack")
tt.timed_attacks.list[2].animation = "oakSeeds"
tt.timed_attacks.list[2].bullet = "bullet_bravebark_seed"
tt.timed_attacks.list[2].cooldown = 25
tt.timed_attacks.list[2].count = 2
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entity = "soldier_bravebark"
tt.timed_attacks.list[2].max_range = 100
tt.timed_attacks.list[2].sound = "ElvesHeroForestElementalTrees"
tt.timed_attacks.list[2].spawn_offset = v(58, 65)
tt.timed_attacks.list[2].spawn_time = fts(12)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_BLOCK)
tt.timed_attacks.list[2].xp_from_skill = "oakseeds"
tt.springsap = {}
tt.springsap.disabled = true
tt.springsap.animations = {
	"springsap_start",
	"springsap_loop",
	"springsap_end"
}
tt.springsap.aura = "aura_bravebark_springsap"
tt.springsap.cooldown = 35
tt.springsap.trigger_hp_factor = 0.3
tt.springsap.sound = "ElvesHeroForestElementalHealing"
tt.springsap.ts = 0
tt = E:register_t("hero_bravebark_ultimate")

E:add_comps(tt, "pos", "main_script", "sound_events")

tt.can_fire_fn = kr3_scripts.hero_bravebark_ultimate.can_fire_fn
tt.cooldown = 40
tt.count = nil
tt.main_script.update = kr3_scripts.hero_bravebark_ultimate.update
tt.sound_events.insert = "ElvesHeroForestElementalUltimate"
tt.sep_nodes_min = 2
tt.sep_nodes_max = 4
tt.show_delay_min = 0.1
tt.show_delay_max = 0.2
tt.decal = "decal_bravebark_ultimate"
tt.damage = nil
tt.damage_radius = 40
tt.damage_type = DAMAGE_TRUE
tt.vis_flags = bor(F_STUN)
tt.vis_bans = bor(F_FLYING, F_BOSS)
tt.mod = "mod_bravebark_ultimate"
tt = E:register_t("hero_xin", "hero")

E:add_comps(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {
	0.25,
	0.25,
	0.25,
	0.25,
	0.25,
	0.25,
	0.25,
	0.25,
	0.25,
	0.25
}
tt.hero.level_stats.hp_max = {
	330,
	360,
	390,
	420,
	450,
	480,
	510,
	540,
	570,
	600
}
tt.hero.level_stats.melee_damage_max = {
	14,
	17,
	20,
	23,
	25,
	28,
	31,
	33,
	36,
	40
}
tt.hero.level_stats.melee_damage_min = {
	10,
	11,
	13,
	15,
	17,
	19,
	20,
	22,
	24,
	25
}
tt.hero.level_stats.regen_health = {
	22,
	24,
	26,
	28,
	30,
	32,
	34,
	36,
	38,
	40
}
tt.hero.skills.daring_strike = E:clone_c("hero_skill")
tt.hero.skills.daring_strike.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.daring_strike.hr_icon = "0036"
tt.hero.skills.daring_strike.hr_order = 1
tt.hero.skills.daring_strike.damage_max = {
	70,
	125,
	175
}
tt.hero.skills.daring_strike.damage_min = {
	50,
	80,
	115
}
tt.hero.skills.daring_strike.xp_gain = {
	45,
	90,
	135
}
tt.hero.skills.inspire = E:clone_c("hero_skill")
tt.hero.skills.inspire.duration = {
	3,
	5,
	7
}
tt.hero.skills.inspire.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.inspire.hr_icon = "0037"
tt.hero.skills.inspire.hr_order = 2
tt.hero.skills.inspire.xp_gain = {
	48,
	96,
	144
}
tt.hero.skills.mind_over_body = E:clone_c("hero_skill")
tt.hero.skills.mind_over_body.duration = {
	4,
	6,
	9
}
tt.hero.skills.mind_over_body.heal_every = {
	fts(10),
	fts(5),
	fts(5)
}
tt.hero.skills.mind_over_body.heal_hp = {
	5,
	4,
	4
}
tt.hero.skills.mind_over_body.hr_cost = {
	1,
	1,
	1
}
tt.hero.skills.mind_over_body.hr_icon = "0038"
tt.hero.skills.mind_over_body.hr_order = 3
tt.hero.skills.mind_over_body.xp_gain = {
	0,
	0,
	0
}
tt.hero.skills.panda_style = E:clone_c("hero_skill")
tt.hero.skills.panda_style.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.panda_style.hr_icon = "0039"
tt.hero.skills.panda_style.hr_order = 4
tt.hero.skills.panda_style.damage_max = {
	55,
	100,
	140
}
tt.hero.skills.panda_style.damage_min = {
	30,
	55,
	80
}
tt.hero.skills.panda_style.xp_gain = {
	78,
	156,
	234
}
tt.hero.skills.panda_style.key = "KINDRED_SPIRITS"
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.hr_cost = {
	4,
	4,
	4
}
tt.hero.skills.ultimate.hr_icon = "0040"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.controller_name = "hero_xin_ultimate"
tt.hero.skills.ultimate.count = {
	[0] = 2,
	4,
	5,
	6
}
tt.hero.skills.ultimate.damage = {
	[0] = 45,
	60,
	80,
	90
}
tt.hero.skills.ultimate.key = "PANDAMONIUM"
tt.health.dead_lifetime = 20
tt.health_bar.offset = v(0, 55)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_xin.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.fn = kr3_scripts.hero_basic.get_info_melee
tt.info.hero_portrait = "hero_portraits_0008"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0008"
tt.info.i18n_key = "HERO_ELVES_PANDA"
tt.info.ultimate_icon = "0008"
tt.info.ultimate_pointer_style = "area"
tt.main_script.update = kr3_scripts.hero_xin.update
tt.motion.max_speed = 2.5 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt.render.sprites[1].prefix = "hero_xin"
tt.soldier.melee_slot_offset = v(12, 0)
tt.sound_events.change_rally_point = "ElvesHeroXinTaunt"
tt.sound_events.death = "ElvesHeroXinDeath"
tt.sound_events.respawn = "ElvesHeroXinTauntIntro"
tt.sound_events.insert = "ElvesHeroXinTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroXinTauntSelect"
tt.unit.hit_offset = v(0, 18)
tt.unit.mod_offset = v(0, 23)
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].xp_gain_factor = 0.82
tt.melee.attacks[1].sound_hit = "ElvesHeroXinPoleHit"
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[3] = E:clone_c("area_attack")
tt.melee.attacks[3].animation = "buttStrike"
tt.melee.attacks[3].cooldown = 26
tt.melee.attacks[3].count = 999
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_radius = 60
tt.melee.attacks[3].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_fx = "fx_xin_panda_style_smoke"
tt.melee.attacks[3].hit_time = fts(19)
tt.melee.attacks[3].sound = "ElvesHeroXinPandaStyle"
tt.melee.attacks[3].xp_from_skill = "panda_style"
tt.melee.range = 65
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animations = {
	"teleport_out",
	"teleport_hit",
	"teleport_hit2",
	"teleport_hit_out",
	"teleport_in"
}
tt.timed_attacks.list[1].sounds = {
	"ElvesHeroXinAfterTeleportOut",
	"ElvesHeroXinDaringStrikeHit",
	nil,
	nil,
	"ElvesHeroXinAfterTeleportIn"
}
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].cooldown = 15
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_BLOCK)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_BOSS)
tt.timed_attacks.list[1].max_range = 9999
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].damage_max = nil
tt.timed_attacks.list[1].damage_min = nil
tt.timed_attacks.list[1].node_margin = 10
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[2] = E:clone_c("mod_attack")
tt.timed_attacks.list[2].animation = "inspire"
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].cast_time = fts(15)
tt.timed_attacks.list[2].cooldown = 16
tt.timed_attacks.list[2].max_count = 6
tt.timed_attacks.list[2].max_range = 90
tt.timed_attacks.list[2].min_count = 2
tt.timed_attacks.list[2].mod = "mod_xin_inspire"
tt.timed_attacks.list[2].sound = "ElvesHeroXinInspire"
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[3] = E:clone_c("mod_attack")
tt.timed_attacks.list[3].animation = "drink"
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].cooldown = 20
tt.timed_attacks.list[3].min_health_factor = 0.7
tt.timed_attacks.list[3].mod = "mod_xin_mind_over_body"
tt.timed_attacks.list[3].cast_time = fts(15)
tt.timed_attacks.list[3].sound = "ElvesHeroXinMindOverBody"
tt = E:register_t("hero_xin_ultimate")

E:add_comps(tt, "pos", "main_script", "sound_events")

tt.can_fire_fn = kr3_scripts.hero_xin_ultimate.can_fire_fn
tt.cooldown = 30
tt.range = 125
tt.spawn_delay = 0.5
tt.count = nil
tt.main_script.update = kr3_scripts.hero_xin_ultimate.update
tt.sound_events.insert = "ElvesHeroXinPandamonium"
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = bor(F_FLYING)
tt.entity = "soldier_xin_ultimate"
tt = E:register_t("hero_catha", "hero")

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {
	0,
	0.05,
	0.1,
	0.15,
	0.2,
	0.25,
	0.3,
	0.35,
	0.4,
	0.45
}
tt.hero.level_stats.hp_max = {
	210,
	220,
	230,
	240,
	250,
	260,
	270,
	280,
	290,
	300
}
tt.hero.level_stats.melee_damage_max = {
	8,
	9,
	10,
	12,
	13,
	14,
	16,
	17,
	18,
	20
}
tt.hero.level_stats.melee_damage_min = {
	4,
	5,
	6,
	6,
	7,
	8,
	8,
	9,
	10,
	11
}
tt.hero.level_stats.regen_health = {
	26,
	28,
	29,
	30,
	31,
	33,
	34,
	35,
	36,
	38
}
tt.hero.level_stats.ranged_damage_min = {
	4,
	5,
	6,
	6,
	7,
	8,
	8,
	9,
	10,
	11
}
tt.hero.level_stats.ranged_damage_max = {
	8,
	9,
	10,
	12,
	13,
	14,
	16,
	17,
	18,
	20
}
tt.hero.skills.soul = E:clone_c("hero_skill")
tt.hero.skills.soul.hr_cost = {
	1,
	2,
	3
}
tt.hero.skills.soul.hr_icon = "0011"
tt.hero.skills.soul.hr_order = 1
tt.hero.skills.soul.xp_gain = {
	24,
	72,
	144
}
tt.hero.skills.soul.heal_hp = {
	50,
	100,
	150
}
tt.hero.skills.tale = E:clone_c("hero_skill")
tt.hero.skills.tale.max_count = {
	2,
	3,
	4
}
tt.hero.skills.tale.hp_max = {
	30,
	40,
	50
}
tt.hero.skills.tale.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.tale.hr_icon = "0012"
tt.hero.skills.tale.hr_order = 2
tt.hero.skills.tale.xp_gain = {
	42,
	84,
	126
}
tt.hero.skills.tale.xp_gain_factor = 0
tt.hero.skills.fury = E:clone_c("hero_skill")
tt.hero.skills.fury.count = {
	2,
	3,
	4
}
tt.hero.skills.fury.damage_min = {
	10,
	12,
	18
}
tt.hero.skills.fury.damage_max = {
	30,
	40,
	50
}
tt.hero.skills.fury.hr_cost = {
	1,
	2,
	3
}
tt.hero.skills.fury.hr_icon = "0013"
tt.hero.skills.fury.hr_order = 3
tt.hero.skills.fury.xp_gain = {
	13,
	38,
	75
}
tt.hero.skills.fury.xp_gain_factor = 0
tt.hero.skills.curse = E:clone_c("hero_skill")
tt.hero.skills.curse.chance = {
	0.2,
	0.2,
	0.2
}
tt.hero.skills.curse.duration = {
	0.5,
	1,
	1.5
}
tt.hero.skills.curse.chance_factor_tale = 0.5
tt.hero.skills.curse.hr_cost = {
	1,
	1,
	1
}
tt.hero.skills.curse.hr_icon = "0014"
tt.hero.skills.curse.hr_order = 4
tt.hero.skills.curse.xp_gain = {
	0,
	0,
	0
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_catha_ultimate"
tt.hero.skills.ultimate.duration = {
	[0] = 1.5,
	3,
	4.5,
	6
}
tt.hero.skills.ultimate.duration_boss = {
	[0] = 0.75,
	1.5,
	2.25,
	3
}
tt.hero.skills.ultimate.range = {
	[0] = 160,
	180,
	200,
	220
}
tt.hero.skills.ultimate.hr_cost = {
	4,
	4,
	4
}
tt.hero.skills.ultimate.hr_icon = "0015"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.key = "DUST"
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_catha.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.damage_icon = "arrow"
tt.info.fn = kr3_scripts.hero_basic.get_info_ranged
tt.info.hero_portrait = "hero_portraits_0003"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0003"
tt.info.i18n_key = "HERO_ELVES_PIXIE"
tt.info.ultimate_icon = "0003"
tt.info.ultimate_pointer_style = "area"
tt.main_script.update = kr3_scripts.hero_catha.update
tt.motion.max_speed = 3.3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.37301587301587
tt.render.sprites[1].prefix = "hero_catha"
tt.render.sprites[1].angles.ranged = {
	"shoot",
	"shootUp",
	"shoot"
}
tt.render.sprites[1].angles_custom = {
	ranged = {
		45,
		135,
		210,
		315
	}
}
tt.render.sprites[1].angles_flip_vertical = {
	ranged = true
}
tt.soldier.melee_slot_offset = v(2, 0)
tt.sound_events.change_rally_point = "ElvesHeroCathaTaunt"
tt.sound_events.death = "ElvesHeroCathaDeath"
tt.sound_events.respawn = "ElvesHeroCathaTauntIntro"
tt.sound_events.insert = "ElvesHeroCathaTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroCathaTauntSelect"
tt.unit.hit_offset = v(0, 16)
tt.unit.mod_offset = v(0, 22)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].xp_gain_factor = 0.78
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.range = 50
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].bullet = "knife_catha"
tt.ranged.attacks[1].bullet_start_offset = {
	v(9, 27)
}
tt.ranged.attacks[1].shoot_time = fts(7)
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].animation = "explode"
tt.timed_attacks.list[1].bullet = "catha_fury"
tt.timed_attacks.list[1].cooldown = 10
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].min_range = 40
tt.timed_attacks.list[1].shoot_time = fts(13)
tt.timed_attacks.list[1].sound = "ElvesHeroCathaFurySummon"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "cloudSpell"
tt.timed_attacks.list[2].mod = "mod_catha_soul"
tt.timed_attacks.list[2].cooldown = 12
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_range = 100
tt.timed_attacks.list[2].max_count = 3
tt.timed_attacks.list[2].vis_flags = bor(F_FRIEND)
tt.timed_attacks.list[2].sound = "ElvesHeroCathaSoul"
tt.timed_attacks.list[2].shoot_time = fts(30)
tt.timed_attacks.list[2].shoot_fx = "fx_catha_soul"
tt.timed_attacks.list[2].excluded_templates = {
	"soldier_druid_bear",
	"soldier_veznan_demon",
	"soldier_bravebark",
	"soldier_xin_shadow",
	"soldier_xin_ultimate"
}
tt.timed_attacks.list[2].max_hp_factor = 0.7
tt.timed_attacks.list[3] = CC("spawn_attack")
tt.timed_attacks.list[3].animation = "cloneSpell"
tt.timed_attacks.list[3].cooldown = 16
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].entity = "soldier_catha"
tt.timed_attacks.list[3].entity_offsets = {
	v(30, 30),
	v(-30, -30),
	v(30, -30),
	v(-30, 30)
}
tt.timed_attacks.list[3].max_count = nil
tt.timed_attacks.list[3].max_range = 150
tt.timed_attacks.list[3].min_range = 20
tt.timed_attacks.list[3].sound = "ElvesHeroCathaTaleSummon"
tt.timed_attacks.list[3].sound_args = {
	delay = fts(15)
}
tt.timed_attacks.list[3].spawn_time = fts(26)
tt.timed_attacks.list[3].vis_bans = 0
tt.timed_attacks.list[3].vis_flags = F_RANGED
tt = E:register_t("hero_catha_ultimate")

E:add_comps(tt, "pos", "main_script", "sound_events", "render")

tt.can_fire_fn = kr3_scripts.hero_catha_ultimate.can_fire_fn
tt.cooldown = 25
tt.range = 80
tt.duration = 0
tt.duration_boss = 0
tt.mod = "mod_catha_ultimate"
tt.hit_fx = "fx_catha_ultimate"
tt.main_script.update = kr3_scripts.hero_catha_ultimate.update
tt.sound_events.insert = "ElvesHeroCathaDust"
tt.vis_flags = bor(F_RANGED, F_MOD)
tt.vis_bans = 0
tt.render.sprites[1].name = "hero_catha_ultimate"
tt.render.sprites[1].anchor.y = 0.373
tt.hit_time = fts(22)
tt = RT("hero_rag", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.hp_max = {
	350,
	375,
	400,
	425,
	450,
	475,
	500,
	525,
	550,
	575
}
tt.hero.level_stats.melee_damage_max = {
	12,
	14,
	16,
	17,
	19,
	21,
	23,
	25,
	26,
	28
}
tt.hero.level_stats.melee_damage_min = {
	8,
	9,
	10,
	12,
	13,
	14,
	15,
	16,
	18,
	19
}
tt.hero.level_stats.regen_health = {
	23,
	25,
	27,
	28,
	30,
	32,
	33,
	35,
	37,
	38
}
tt.hero.level_stats.ranged_damage_max = {
	12,
	14,
	16,
	17,
	19,
	21,
	23,
	25,
	26,
	28
}
tt.hero.level_stats.ranged_damage_min = {
	8,
	9,
	10,
	12,
	13,
	14,
	15,
	16,
	18,
	19
}
tt.hero.skills.raggified = E:clone_c("hero_skill")
tt.hero.skills.raggified.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.raggified.hr_icon = "0049"
tt.hero.skills.raggified.hr_order = 1
tt.hero.skills.raggified.max_target_hp = {
	200,
	600,
	10000
}
tt.hero.skills.raggified.xp_gain = {
	94,
	188,
	282
}
tt.hero.skills.raggified.doll_duration = {
	3,
	5,
	7
}
tt.hero.skills.kamihare = E:clone_c("hero_skill")
tt.hero.skills.kamihare.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.kamihare.hr_icon = "0046"
tt.hero.skills.kamihare.hr_order = 2
tt.hero.skills.kamihare.count = {
	4,
	8,
	12
}
tt.hero.skills.kamihare.xp_gain = {
	70,
	140,
	210
}
tt.hero.skills.angry_gnome = E:clone_c("hero_skill")
tt.hero.skills.angry_gnome.hr_cost = {
	1,
	1,
	1
}
tt.hero.skills.angry_gnome.hr_icon = "0047"
tt.hero.skills.angry_gnome.hr_order = 3
tt.hero.skills.angry_gnome.damage_max = {
	45,
	90,
	135
}
tt.hero.skills.angry_gnome.damage_min = {
	25,
	50,
	75
}
tt.hero.skills.angry_gnome.xp_gain = {
	21,
	42,
	63
}
tt.hero.skills.hammer_time = E:clone_c("hero_skill")
tt.hero.skills.hammer_time.duration = {
	3,
	4,
	5
}
tt.hero.skills.hammer_time.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.hammer_time.hr_icon = "0048"
tt.hero.skills.hammer_time.hr_order = 4
tt.hero.skills.hammer_time.xp_gain = {
	105,
	210,
	315
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_rag_ultimate"
tt.hero.skills.ultimate.hr_cost = {
	4,
	4,
	4
}
tt.hero.skills.ultimate.hr_icon = "0050"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.key = "ONE_GNOME_ARMY"
tt.hero.skills.ultimate.max_count = {
	[0] = 2,
	4,
	6,
	8
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 58)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_rag.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.fn = kr3_scripts.hero_basic.get_info_melee
tt.info.hero_portrait = "hero_portraits_0010"
tt.info.i18n_key = "HERO_ELVES_RAG"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0010"
tt.info.ultimate_icon = "0010"
tt.info.ultimate_pointer_style = "area"
tt.main_script.update = kr3_scripts.hero_rag.update
tt.motion.max_speed = 2 * FPS
tt.regen.cooldown = 1

for i = 1, 2 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].anchor.y = 0.239
	tt.render.sprites[i].prefix = "hero_rag_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].angles = {}
	tt.render.sprites[i].angles.walk = {
		"running"
	}
end

tt.soldier.melee_slot_offset = v(7, 0)
tt.sound_events.change_rally_point = "ElvesHeroRagTaunt"
tt.sound_events.death = "ElvesHeroRagDeath"
tt.sound_events.insert = "ElvesHeroRagTauntIntro"
tt.sound_events.respawn = "ElvesHeroRagTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroRagTauntSelect"
tt.unit.hit_offset = v(0, 16)
tt.unit.mod_offset = v(6, 20)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].hit_offset = v(32, -5)
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].damage_radius = 75
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].count = 5
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 0.38
tt.melee.attacks[1].sound_hit = "ElvesHeroRagGroundStomp"
tt.melee.range = 50
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].max_range = 110
tt.ranged.attacks[1].min_range = 45
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].bullet = "bullet_rag"
tt.ranged.attacks[1].bullet_start_offset = {
	v(3, 80)
}
tt.ranged.attacks[1].shoot_time = fts(5)
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].animation = "throw"
tt.timed_attacks.list[1].bullet_prefix = "bullet_rag_throw_"
tt.timed_attacks.list[1].bullet_start_offset = {
	v(3, 80)
}
tt.timed_attacks.list[1].cooldown = 17
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = 125
tt.timed_attacks.list[1].min_range = 45
tt.timed_attacks.list[1].shoot_time = fts(20)
tt.timed_attacks.list[1].sound = "ElvesHeroRagSpawn"
tt.timed_attacks.list[1].things = {
	"bolso",
	"anchor",
	"fungus",
	"pan",
	"chair"
}
tt.timed_attacks.list[1].vis_bans = 0
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].xp_from_skill = "angry_gnome"
tt.timed_attacks.list[2] = E:clone_c("spawn_attack")
tt.timed_attacks.list[2].animations = {
	"rabbitCall",
	"rabbitCallEnd"
}
tt.timed_attacks.list[2].bullet = "bullet_kamihare"
tt.timed_attacks.list[2].cooldown = 35
tt.timed_attacks.list[2].count = nil
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entity = "rabbit_kamihare"
tt.timed_attacks.list[2].range_nodes_max = 200
tt.timed_attacks.list[2].range_nodes_min = 5
tt.timed_attacks.list[2].sound = "ElvesHeroRagKamihare"
tt.timed_attacks.list[2].sound_delay = fts(12)
tt.timed_attacks.list[2].spawn_offset = v(0, 31)
tt.timed_attacks.list[2].spawn_time = fts(15)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_BLOCK)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].xp_from_skill = "kamihare"
tt.timed_attacks.list[3] = E:clone_c("area_attack")
tt.timed_attacks.list[3].animations = {
	"hammer_start",
	"hammer_walk",
	"hammer_end"
}
tt.timed_attacks.list[3].cooldown = 35
tt.timed_attacks.list[3].damage_every = fts(10)
tt.timed_attacks.list[3].damage_max = 15
tt.timed_attacks.list[3].damage_min = 10
tt.timed_attacks.list[3].damage_radius = 65
tt.timed_attacks.list[3].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].max_range = 100
tt.timed_attacks.list[3].mod = "mod_rag_hammer_time_stun"
tt.timed_attacks.list[3].nodes_range = 5
tt.timed_attacks.list[3].sound_hit = "ElvesHeroRagHammer"
tt.timed_attacks.list[3].sound_loop = "ElvesHeroRagHammerTime"
tt.timed_attacks.list[3].speed_factor = 1.25
tt.timed_attacks.list[3].trigger_hp = 100
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[3].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[3].xp_from_skill = "hammer_time"
tt.timed_attacks.list[4] = E:clone_c("bullet_attack")
tt.timed_attacks.list[4].animation = "polymorph"
tt.timed_attacks.list[4].bullet = "ray_rag"
tt.timed_attacks.list[4].bullet_start_offset = {
	v(5, 77)
}
tt.timed_attacks.list[4].cooldown = 25
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].max_range = 125
tt.timed_attacks.list[4].max_target_hp = nil
tt.timed_attacks.list[4].min_range = 60
tt.timed_attacks.list[4].shoot_time = fts(17)
tt.timed_attacks.list[4].sound = "ElvesHeroRagAttack"
tt.timed_attacks.list[4].vis_bans = bor(F_FLYING, F_BOSS)
tt.timed_attacks.list[4].vis_flags = bor(F_RANGED, F_MOD, F_RAGGIFY)
tt.timed_attacks.list[4].xp_from_skill = "raggified"
tt = RT("hero_rag_ultimate")

E:add_comps(tt, "pos", "main_script", "sound_events")

tt.can_fire_fn = kr3_scripts.hero_rag_ultimate.can_fire_fn
tt.cooldown = 60
tt.max_count = nil
tt.range = 100
tt.doll_duration = 10
tt.mod = "mod_rag_raggified"
tt.hit_fx = "fx_rag_ultimate"
tt.hit_decal = "decal_rag_ultimate"
tt.main_script.update = kr3_scripts.hero_rag_ultimate.update
tt.vis_flags = bor(F_RANGED, F_MOD, F_RAGGIFY)
tt.vis_bans = bor(F_BOSS, F_FLYING)
tt.hit_time = fts(2)
tt = RT("hero_veznan", "hero")

AC(tt, "melee", "ranged", "timed_attacks", "teleport")

tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.hp_max = {
	185,
	200,
	215,
	230,
	245,
	260,
	275,
	290,
	305,
	320
}
tt.hero.level_stats.melee_damage_max = {
	8,
	10,
	11,
	12,
	13,
	14,
	16,
	17,
	18,
	19
}
tt.hero.level_stats.melee_damage_min = {
	6,
	6,
	7,
	8,
	9,
	10,
	10,
	11,
	12,
	13
}
tt.hero.level_stats.regen_health = {
	12,
	13,
	14,
	15,
	16,
	17,
	18,
	19,
	20,
	21
}
tt.hero.level_stats.ranged_damage_min = {
	11,
	12,
	14,
	15,
	17,
	18,
	20,
	21,
	23,
	24
}
tt.hero.level_stats.ranged_damage_max = {
	32,
	36,
	41,
	45,
	50,
	54,
	59,
	63,
	68,
	72
}
tt.hero.skills.soulburn = E:clone_c("hero_skill")
tt.hero.skills.soulburn.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.soulburn.hr_icon = "0026"
tt.hero.skills.soulburn.hr_order = 1
tt.hero.skills.soulburn.total_hp = {
	250,
	500,
	750
}
tt.hero.skills.soulburn.xp_gain = {
	105,
	210,
	315
}
tt.hero.skills.shackles = E:clone_c("hero_skill")
tt.hero.skills.shackles.hr_cost = {
	1,
	2,
	3
}
tt.hero.skills.shackles.hr_icon = "0027"
tt.hero.skills.shackles.hr_order = 2
tt.hero.skills.shackles.max_count = {
	1,
	3,
	6
}
tt.hero.skills.shackles.xp_gain = {
	25,
	75,
	150
}
tt.hero.skills.hermeticinsight = E:clone_c("hero_skill")
tt.hero.skills.hermeticinsight.hr_cost = {
	1,
	1,
	1
}
tt.hero.skills.hermeticinsight.hr_icon = "0028"
tt.hero.skills.hermeticinsight.hr_order = 3
tt.hero.skills.hermeticinsight.range_factor = {
	1.1,
	1.2,
	1.3
}
tt.hero.skills.arcanenova = E:clone_c("hero_skill")
tt.hero.skills.arcanenova.damage_min = {
	28,
	46,
	64
}
tt.hero.skills.arcanenova.damage_max = {
	52,
	86,
	120
}
tt.hero.skills.arcanenova.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.arcanenova.hr_icon = "0029"
tt.hero.skills.arcanenova.hr_order = 4
tt.hero.skills.arcanenova.xp_gain = {
	45,
	90,
	135
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_veznan_ultimate"
tt.hero.skills.ultimate.stun_duration = {
	[0] = 2,
	3,
	4,
	5
}
tt.hero.skills.ultimate.soldier_hp_max = {
	[0] = 666,
	999,
	1337,
	1666
}
tt.hero.skills.ultimate.soldier_damage_max = {
	[0] = 50,
	90,
	115,
	130
}
tt.hero.skills.ultimate.soldier_damage_min = {
	[0] = 30,
	50,
	65,
	80
}
tt.hero.skills.ultimate.hr_cost = {
	4,
	4,
	4
}
tt.hero.skills.ultimate.hr_icon = "0030"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.key = "DARKPACT"
tt.health.dead_lifetime = 20
tt.health_bar.offset = v(0, 41)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_veznan.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.damage_icon = "magic"
tt.info.fn = kr3_scripts.hero_basic.get_info_ranged
tt.info.hero_portrait = "hero_portraits_0006"
tt.info.i18n_key = "HERO_ELVES_VEZNAN"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0006"
tt.info.ultimate_icon = "0006"
tt.main_script.update = kr3_scripts.hero_veznan.update
tt.motion.max_speed = 2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.125
tt.render.sprites[1].prefix = "veznan_hero"
tt.soldier.melee_slot_offset = v(3, 0)
tt.sound_events.change_rally_point = "ElvesHeroVeznanTaunt"
tt.sound_events.death = "ElvesHeroVeznanDeath"
tt.sound_events.respawn = "ElvesHeroVeznanTauntIntro"
tt.sound_events.insert = "ElvesHeroVeznanTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroVeznanTauntSelect"
tt.teleport.min_distance = 100
tt.teleport.sound = "ElvesHeroVeznanTeleport"
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(0, 15)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(7)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 0.38
tt.melee.range = 55
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].bullet = "bolt_veznan"
tt.ranged.attacks[1].bullet_start_offset = {
	v(20, 40)
}
tt.ranged.attacks[1].shoot_time = fts(11)
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animations = {
	"soulBurnStart",
	"soulBurnLoop",
	"soulBurnEnd"
}
tt.timed_attacks.list[1].ball = "decal_veznan_soulburn_ball"
tt.timed_attacks.list[1].balls_dest_offset = v(17, 36)
tt.timed_attacks.list[1].cast_time = fts(8)
tt.timed_attacks.list[1].cooldown = 35
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_fx = "fx_veznan_soulburn"
tt.timed_attacks.list[1].radius = 110
tt.timed_attacks.list[1].range = 140
tt.timed_attacks.list[1].sound = "ElvesHeroVeznanSoulBurn"
tt.timed_attacks.list[1].total_hp = nil
tt.timed_attacks.list[1].vis_bans = bor(F_BOSS)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_INSTAKILL)
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "shackles"
tt.timed_attacks.list[2].cast_sound = "ElvesHeroVeznanMagicSchackles"
tt.timed_attacks.list[2].cast_time = fts(14)
tt.timed_attacks.list[2].cooldown = 20
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_count = nil
tt.timed_attacks.list[2].mods = {
	"mod_veznan_shackles_stun",
	"mod_veznan_shackles_dps"
}
tt.timed_attacks.list[2].radius = 100
tt.timed_attacks.list[2].range = 150
tt.timed_attacks.list[2].vis_bans = bor(F_BOSS)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_MOD, F_STUN)
tt.timed_attacks.list[3] = CC("area_attack")
tt.timed_attacks.list[3].animation = "arcaneNova"
tt.timed_attacks.list[3].cast_sound = "ElvesHeroVeznanArcaneNova"
tt.timed_attacks.list[3].cooldown = 18
tt.timed_attacks.list[3].damage_max = nil
tt.timed_attacks.list[3].damage_min = nil
tt.timed_attacks.list[3].damage_radius = 125
tt.timed_attacks.list[3].damage_type = DAMAGE_MAGICAL
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].hit_decal = "decal_veznan_arcanenova"
tt.timed_attacks.list[3].hit_fx = "fx_veznan_arcanenova"
tt.timed_attacks.list[3].hit_time = fts(25)
tt.timed_attacks.list[3].max_range = 165
tt.timed_attacks.list[3].min_range = 75
tt.timed_attacks.list[3].min_count = 2
tt.timed_attacks.list[3].mod = "mod_veznan_arcanenova"
tt.timed_attacks.list[3].vis_bans = 0
tt.timed_attacks.list[3].vis_flags = bor(F_RANGED)
tt = RT("hero_veznan_ultimate")

E:add_comps(tt, "pos", "main_script", "sound_events")

tt.can_fire_fn = kr3_scripts.hero_veznan_ultimate.can_fire_fn
tt.cooldown = 120
tt.entity = "soldier_veznan_demon"
tt.main_script.update = kr3_scripts.hero_veznan_ultimate.update
tt.mod = "mod_veznan_ultimate_stun"
tt.range = 65
tt.sound_events.insert = "ElvesHeroVeznanDarkPact"
tt.vis_bans = bor(F_BOSS)
tt.vis_flags = bor(F_MOD, F_STUN)
tt = RT("hero_durax", "hero")

AC(tt, "melee", "ranged", "timed_attacks", "transfer")

tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.hp_max = {
	280,
	300,
	320,
	340,
	360,
	380,
	400,
	420,
	440,
	460
}
tt.hero.level_stats.melee_damage_max = {
	12,
	13,
	15,
	16,
	18,
	19,
	21,
	22,
	24,
	25
}
tt.hero.level_stats.melee_damage_min = {
	8,
	9,
	10,
	11,
	12,
	13,
	14,
	15,
	16,
	17
}
tt.hero.level_stats.regen_health = {
	23,
	25,
	27,
	28,
	30,
	32,
	33,
	35,
	37,
	38
}
tt.hero.skills.crystallites = E:clone_c("hero_skill")
tt.hero.skills.crystallites.duration = {
	25,
	50,
	75
}
tt.hero.skills.crystallites.hr_cost = {
	5,
	5,
	5
}
tt.hero.skills.crystallites.hr_icon = "0056"
tt.hero.skills.crystallites.hr_order = 1
tt.hero.skills.crystallites.xp_gain = {
	205,
	410,
	615
}
tt.hero.skills.armsword = E:clone_c("hero_skill")
tt.hero.skills.armsword.hr_cost = {
	1,
	1,
	2
}
tt.hero.skills.armsword.hr_icon = "0057"
tt.hero.skills.armsword.hr_order = 2
tt.hero.skills.armsword.xp_gain = {
	28,
	56,
	112
}
tt.hero.skills.armsword.damage = {
	60,
	100,
	180
}
tt.hero.skills.lethal_prism = E:clone_c("hero_skill")
tt.hero.skills.lethal_prism.hr_cost = {
	1,
	1,
	2
}
tt.hero.skills.lethal_prism.hr_icon = "0058"
tt.hero.skills.lethal_prism.hr_order = 3
tt.hero.skills.lethal_prism.damage_max = {
	40,
	45,
	55
}
tt.hero.skills.lethal_prism.damage_min = {
	20,
	25,
	35
}
tt.hero.skills.lethal_prism.ray_count = {
	2,
	3,
	5
}
tt.hero.skills.lethal_prism.xp_gain = {
	19,
	38,
	76
}
tt.hero.skills.shardseed = E:clone_c("hero_skill")
tt.hero.skills.shardseed.hr_cost = {
	1,
	1,
	2
}
tt.hero.skills.shardseed.hr_icon = "0059"
tt.hero.skills.shardseed.hr_order = 4
tt.hero.skills.shardseed.damage = {
	45,
	90,
	180
}
tt.hero.skills.shardseed.xp_gain = {
	28,
	56,
	112
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_durax_ultimate"
tt.hero.skills.ultimate.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.ultimate.hr_icon = "0060"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.key = "CRYSTAL_PRISON"
tt.hero.skills.ultimate.max_count = {
	[0] = 4,
	6,
	8,
	10
}
tt.hero.skills.ultimate.damage = {
	[0] = 300,
	400,
	800,
	1200
}
tt.health.dead_lifetime = 21
tt.health_bar.offset = v(0, 65)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_durax.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.fn = kr3_scripts.hero_durax.get_info
tt.info.hero_portrait = "hero_portraits_0012"
tt.info.i18n_key = "HERO_ELVES_DURAX"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0012"
tt.info.ultimate_icon = "0012"
tt.main_script.update = kr3_scripts.hero_durax.update
tt.motion.max_speed = 2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.2308
tt.render.sprites[1].prefix = "durax_hero"
tt.soldier.melee_slot_offset = v(0, 0)
tt.sound_events.change_rally_point = "ElvesHeroDuraxTaunt"
tt.sound_events.death = "ElvesHeroDuraxDeath"
tt.sound_events.insert = "ElvesHeroDuraxTauntIntro"
tt.sound_events.respawn = "ElvesHeroDuraxTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroDuraxTauntSelect"
tt.unit.hit_offset = v(0, 23)
tt.unit.mod_offset = v(0, 23)
tt.transfer.extra_speed = 5.5 * FPS
tt.transfer.min_distance = 100
tt.transfer.sound_loop = "ElvesHeroDuraxWalkLoop"
tt.transfer.animations = {
	"lethalPrismStart",
	"specialwalkLoop",
	"lethalPrismEnd"
}
tt.transfer.particles_name = "ps_durax_transfer"
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].xp_gain_factor = 0.66
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = CC("melee_attack")
tt.melee.attacks[3].animation = "armblade"
tt.melee.attacks[3].cooldown = 20
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_time = fts(27)
tt.melee.attacks[3].sound = "ElvesHeroDuraxArmblade"
tt.melee.attacks[3].xp_from_skill = "armsword"
tt.melee.cooldown = 1
tt.melee.range = 75
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "shardseed"
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].max_range = 250
tt.ranged.attacks[1].min_range = 125
tt.ranged.attacks[1].cooldown = 25
tt.ranged.attacks[1].bullet = "spear_durax"
tt.ranged.attacks[1].bullet_start_offset = {
	v(-17, 55)
}
tt.ranged.attacks[1].shoot_time = fts(9)
tt.ranged.attacks[1].xp_from_skill = "shardseed"
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].animations = {
	"lethalPrismStart",
	"lethalPrismLoop",
	"lethalPrismEnd"
}
tt.timed_attacks.list[1].bullet = "ray_durax"
tt.timed_attacks.list[1].bullet_start_offset = {
	v(0, 20)
}
tt.timed_attacks.list[1].cooldown = 20
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].range = 150
tt.timed_attacks.list[1].ray_cooldown = fts(10)
tt.timed_attacks.list[1].ray_count = nil
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].xp_from_skill = "lethal_prism"
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].animation = "crystallites"
tt.timed_attacks.list[2].cooldown = 50
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entity = "hero_durax_clone"
tt.timed_attacks.list[2].nodes_offset = {
	5,
	14
}
tt.timed_attacks.list[2].sound = "ElvesHeroDuraxCrystallites"
tt.timed_attacks.list[2].spawn_offset = v(22, 0)
tt.timed_attacks.list[2].spawn_time = fts(19)
tt.timed_attacks.list[2].xp_from_skill = "cristallites"
tt = RT("hero_durax_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.can_fire_fn = kr3_scripts.hero_durax_ultimate.can_fire_fn
tt.cooldown = 45
tt.max_count = nil
tt.range = 75
tt.main_script.update = kr3_scripts.hero_durax_ultimate.update
tt.damage = nil
tt.damage_type = DAMAGE_TRUE
tt.vis_flags = bor(F_MOD)
tt.vis_bans = bor(F_FLYING)
tt.sound_events.insert = "ElvesHeroDuraxUltimate"
tt.mod_slow = "mod_durax_slow"
tt.mod_stun = "mod_durax_stun"
tt.hit_blood_fx = "fx_blood_splat"
tt = RT("hero_durax_clone", "hero_durax")

AC(tt, "tween")

tt.clone = {}
tt.clone.duration = nil
tt.render.sprites[1].shader = "p_tint"
tt.render.sprites[1].shader_args = {
	tint_factor = 0.25,
	tint_color = {
		0,
		0.75,
		1,
		1
	}
}
tt.health.dead_lifetime = 3
tt.sound_events.change_rally_point = "ElvesHeroDuraxTaunt"
tt.sound_events.death = "ElvesHeroDuraxDeath"
tt.sound_events.insert = nil
tt.ranged.attacks[1].bullet = "spear_durax_clone"
tt.health.ignore_delete_after = nil
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		2,
		255
	},
	{
		3,
		0
	}
}
tt.transfer.particles_name = "ps_durax_clone_transfer"
tt = RT("hero_lilith", "hero")

E:add_comps(tt, "melee", "ranged", "timed_attacks", "revive")

tt.hero.level_stats.armor = {
	0.1,
	0.15,
	0.2,
	0.25,
	0.3,
	0.35,
	0.4,
	0.45,
	0.5,
	0.55
}
tt.hero.level_stats.hp_max = {
	240,
	260,
	280,
	300,
	320,
	340,
	360,
	380,
	400,
	420
}
tt.hero.level_stats.melee_damage_max = {
	14,
	16,
	17,
	18,
	19,
	20,
	22,
	23,
	24,
	25
}
tt.hero.level_stats.melee_damage_min = {
	10,
	10,
	11,
	12,
	13,
	14,
	14,
	15,
	16,
	17
}
tt.hero.level_stats.ranged_damage_max = {
	14,
	16,
	17,
	18,
	19,
	20,
	22,
	23,
	24,
	25
}
tt.hero.level_stats.ranged_damage_min = {
	10,
	10,
	11,
	12,
	13,
	14,
	14,
	15,
	16,
	17
}
tt.hero.level_stats.regen_health = {
	24,
	26,
	28,
	30,
	32,
	34,
	36,
	38,
	40,
	42
}
tt.hero.skills.reapers_harvest = E:clone_c("hero_skill")
tt.hero.skills.reapers_harvest.damage = {
	110,
	220,
	330
}
tt.hero.skills.reapers_harvest.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.reapers_harvest.hr_icon = "0071"
tt.hero.skills.reapers_harvest.hr_order = 1
tt.hero.skills.reapers_harvest.instakill_chance = {
	0.1,
	0.2,
	0.3
}
tt.hero.skills.reapers_harvest.xp_gain = {
	105,
	210,
	315
}
tt.hero.skills.soul_eater = E:clone_c("hero_skill")
tt.hero.skills.soul_eater.damage_factor = {
	0.3,
	0.6,
	0.9
}
tt.hero.skills.soul_eater.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.soul_eater.hr_icon = "0072"
tt.hero.skills.soul_eater.hr_order = 2
tt.hero.skills.soul_eater.xp_gain = {
	10,
	20,
	30
}
tt.hero.skills.infernal_wheel = E:clone_c("hero_skill")
tt.hero.skills.infernal_wheel.damage = {
	6,
	12,
	18
}
tt.hero.skills.infernal_wheel.hr_cost = {
	1,
	2,
	3
}
tt.hero.skills.infernal_wheel.hr_icon = "0073"
tt.hero.skills.infernal_wheel.hr_order = 3
tt.hero.skills.infernal_wheel.xp_gain = {
	30,
	60,
	120
}
tt.hero.skills.resurrection = E:clone_c("hero_skill")
tt.hero.skills.resurrection.chance = {
	0.1,
	0.2,
	0.3
}
tt.hero.skills.resurrection.hr_cost = {
	1,
	1,
	1
}
tt.hero.skills.resurrection.hr_icon = "0075"
tt.hero.skills.resurrection.hr_order = 4
tt.hero.skills.resurrection.xp_gain = {
	0,
	0,
	0
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_lilith_ultimate"
tt.hero.skills.ultimate.hr_cost = {
	4,
	4,
	4
}
tt.hero.skills.ultimate.hr_icon = "0074"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.key = "HEAVENLY_CHAOS"
tt.hero.skills.ultimate.angel_damage = {
	[0] = 25,
	32,
	40,
	50
}
tt.hero.skills.ultimate.angel_count = {
	[0] = 3,
	4,
	5,
	6
}
tt.hero.skills.ultimate.meteor_damage = {
	[0] = 40,
	80,
	120,
	160
}
tt.health.dead_lifetime = 18
tt.health_bar.offset = v(0, 54)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_lilith.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.fn = kr3_scripts.hero_basic.get_info_melee
tt.info.hero_portrait = "hero_portraits_0016"
tt.info.i18n_key = "HERO_ELVES_FALLEN_ANGEL"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0016"
tt.info.ultimate_icon = "0015"
tt.info.ultimate_pointer_style = "area"
tt.main_script.insert = kr3_scripts.hero_lilith.insert
tt.main_script.update = kr3_scripts.hero_lilith.update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.1666
tt.render.sprites[1].prefix = "hero_lilith"
tt.soldier.melee_slot_offset = v(0, 0)
tt.sound_events.change_rally_point = "ElvesHeroLilithTaunt"
tt.sound_events.death = "ElvesHeroLilithDeath"
tt.sound_events.insert = "ElvesHeroLilithTauntIntro"
tt.sound_events.respawn = "ElvesHeroLilithTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroLilithTauntSelect"
tt.unit.hit_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 22)
tt.revive.disabled = true
tt.revive.chance = 0
tt.revive.animation = "resurrection"
tt.revive.sound = "ElvesHeroLilithResurrection"
tt.soul_eater = {}
tt.soul_eater.last_ts = 0
tt.soul_eater.active = true
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 0.62
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = CC("melee_attack")
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].cooldown = 20
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].animation = "reapersHarvest"
tt.melee.attacks[3].hit_time = fts(30)
tt.melee.attacks[3].sound = "ElvesHeroLilithReapersHarvest"
tt.melee.attacks[3].sound_args = {
	delay = fts(7)
}
tt.melee.attacks[3].cooldown_group = "reapers_harvest"
tt.melee.attacks[3].xp_from_skill = "reapers_harvest"
tt.melee.attacks[3].hit_decal = "decal_lilith_reapers_harvest"
tt.melee.attacks[3].hit_offset = v(30, 0)
tt.melee.attacks[4] = table.deepclone(tt.melee.attacks[3])
tt.melee.attacks[4].instakill = true
tt.melee.attacks[4].chance = nil
tt.melee.attacks[4].vis_bans = bor(F_BOSS)
tt.melee.attacks[4].vis_flags = bor(F_INSTAKILL)
tt.melee.cooldown = 1
tt.melee.range = 57.5
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "throw"
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].bullet = "bullet_lilith"
tt.ranged.attacks[1].bullet_start_offset = {
	v(5, 40)
}
tt.ranged.attacks[1].shoot_time = fts(28)
tt.ranged.attacks[1].node_prediction = fts(28)
tt.timed_attacks.list[1] = E:clone_c("aura_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animation = "infernalWheel"
tt.timed_attacks.list[1].bullet = "aura_lilith_infernal_wheel"
tt.timed_attacks.list[1].cooldown = 22
tt.timed_attacks.list[1].shoot_time = fts(12)
tt.timed_attacks.list[1].range = 175
tt.timed_attacks.list[1].sound = "ElvesHeroLilithInfernalWheel"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt = RT("hero_lilith_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.can_fire_fn = kr3_scripts.hero_lilith_ultimate.can_fire_fn
tt.main_script.update = kr3_scripts.hero_lilith_ultimate.update
tt.cooldown = 50
tt.angel_range = 125
tt.angel_entity = "soldier_lilith_angel"
tt.angel_mod = "mod_lilith_angel_stun"
tt.angel_delay = 0.5
tt.angel_vis_flags = bor(F_RANGED)
tt.angel_vis_bans = bor(F_FRIEND, F_FLYING)
tt.meteor_bullet = "meteor_lilith"
tt.meteor_chance = 0.5
tt.meteor_node_spread = 5
tt = RT("hero_bruce", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {
	0.05,
	0.1,
	0.15,
	0.2,
	0.25,
	0.3,
	0.35,
	0.4,
	0.45,
	0.5
}
tt.hero.level_stats.hp_max = {
	365,
	390,
	415,
	440,
	465,
	490,
	515,
	540,
	565,
	590
}
tt.hero.level_stats.melee_damage_max = {
	27,
	31,
	34,
	38,
	41,
	45,
	49,
	52,
	56,
	59
}
tt.hero.level_stats.melee_damage_min = {
	18,
	20,
	23,
	25,
	28,
	30,
	32,
	35,
	37,
	40
}
tt.hero.level_stats.regen_health = {
	18,
	20,
	21,
	22,
	23,
	25,
	26,
	27,
	28,
	30
}
tt.hero.skills.sharp_claws = E:clone_c("hero_skill")
tt.hero.skills.sharp_claws.damage = {
	3,
	6,
	9
}
tt.hero.skills.sharp_claws.extra_damage = {
	15,
	30,
	45
}
tt.hero.skills.sharp_claws.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.sharp_claws.hr_icon = "0067"
tt.hero.skills.sharp_claws.hr_order = 1
tt.hero.skills.sharp_claws.xp_gain = {
	10,
	20,
	30
}
tt.hero.skills.kings_roar = E:clone_c("hero_skill")
tt.hero.skills.kings_roar.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.kings_roar.hr_icon = "0066"
tt.hero.skills.kings_roar.hr_order = 2
tt.hero.skills.kings_roar.stun_duration = {
	1,
	2,
	3
}
tt.hero.skills.kings_roar.xp_gain = {
	100,
	120,
	150
}
tt.hero.skills.lions_fur = E:clone_c("hero_skill")
tt.hero.skills.lions_fur.extra_hp = {
	30,
	60,
	90
}
tt.hero.skills.lions_fur.hr_cost = {
	1,
	1,
	1
}
tt.hero.skills.lions_fur.hr_icon = "0068"
tt.hero.skills.lions_fur.hr_order = 3
tt.hero.skills.grievous_bites = E:clone_c("hero_skill")
tt.hero.skills.grievous_bites.damage = {
	20,
	50,
	95
}
tt.hero.skills.grievous_bites.hr_cost = {
	1,
	2,
	3
}
tt.hero.skills.grievous_bites.hr_icon = "0069"
tt.hero.skills.grievous_bites.hr_order = 4
tt.hero.skills.grievous_bites.xp_gain = {
	30,
	60,
	90
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_bruce_ultimate"
tt.hero.skills.ultimate.hr_cost = {
	4,
	4,
	4
}
tt.hero.skills.ultimate.hr_icon = "0070"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.key = "GUARDIAN_LIONS"
tt.hero.skills.ultimate.damage_per_tick = {
	[0] = 8,
	12,
	14,
	16
}
tt.hero.skills.ultimate.damage_boss = {
	[0] = 150,
	200,
	350,
	500
}
tt.hero.skills.ultimate.count = {
	[0] = 2,
	3,
	4,
	5
}
tt.health.dead_lifetime = 18
tt.health_bar.offset = v(0, 53)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_bruce.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.fn = kr3_scripts.hero_basic.get_info_melee
tt.info.hero_portrait = "hero_portraits_0015"
tt.info.i18n_key = "HERO_ELVES_BRUCE"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0015"
tt.info.ultimate_icon = "0014"
tt.main_script.insert = kr3_scripts.hero_bruce.insert
tt.main_script.update = kr3_scripts.hero_bruce.update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.16666666666667
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_bruce"
tt.soldier.melee_slot_offset = v(12, -1)
tt.sound_events.change_rally_point = "ElvesHeroBruceTaunt"
tt.sound_events.death = "ElvesHeroBruceDeath"
tt.sound_events.hero_room_select = "ElvesHeroBruceTauntSelect"
tt.sound_events.insert = "ElvesHeroBruceTauntIntro"
tt.sound_events.respawn = "ElvesHeroBruceTauntIntro"
tt.unit.hit_offset = v(0, 16)
tt.unit.mod_offset = v(0, 22)
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 0.62
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[3].animation = "attack3"
tt.melee.attacks[3].chance = 0.1
tt.melee.attacks[3].fn_chance = kr3_scripts.hero_bruce.fn_chance_sharp_claws
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].mod = "mod_bruce_sharp_claws"
tt.melee.attacks[4] = CC("melee_attack")
tt.melee.attacks[4].animations = {
	nil,
	"eat"
}
tt.melee.attacks[4].cooldown = 20
tt.melee.attacks[4].damage_max = nil
tt.melee.attacks[4].damage_min = nil
tt.melee.attacks[4].damage_type = DAMAGE_TRUE
tt.melee.attacks[4].disabled = true
tt.melee.attacks[4].hit_times = {
	fts(8),
	fts(16),
	fts(25)
}
tt.melee.attacks[4].interrupt_on_dead_target = true
tt.melee.attacks[4].loops = 1
tt.melee.attacks[4].sound = "ElvesHeroBruceGriveousBites"
tt.melee.attacks[4].sound_args = {
	delay = fts(3)
}
tt.melee.attacks[4].xp_from_skill = "grievous_bites"
tt.melee.attacks[4].xp_gain_factor = 10
tt.melee.cooldown = 1
tt.melee.range = 55
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "specialAttack"
tt.timed_attacks.list[1].cooldown = 20
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_time = fts(17)
tt.timed_attacks.list[1].max_count = 6
tt.timed_attacks.list[1].min_count = 3
tt.timed_attacks.list[1].mod = "mod_bruce_kings_roar"
tt.timed_attacks.list[1].range = 125
tt.timed_attacks.list[1].sound = "ElvesHeroBruceKingsRoar"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(9)
}
tt.timed_attacks.list[1].vis_bans = bor(F_BOSS)
tt.timed_attacks.list[1].vis_flags = bor(F_MOD, F_STUN, F_RANGED)
tt.timed_attacks.list[1].xp_from_skill = "kings_roar"
tt = RT("hero_bruce_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.can_fire_fn = kr3_scripts.hero_bruce_ultimate.can_fire_fn
tt.cooldown = 45
tt.main_script.update = kr3_scripts.hero_bruce_ultimate.update
tt.sound_events.insert = "ElvesHeroBruceGuardianLionsCast"
tt.entity = "lion_bruce"
tt.count = nil
tt.range_nodes_min = 0
tt.range_nodes_max = 999
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = bor(F_FLYING)
tt = RT("lion_bruce", "decal_scripted")

AC(tt, "nav_path", "motion", "custom_attack", "sound_events", "tween")

tt.custom_attack.cooldown = fts(6)
tt.custom_attack.mods = {
	"mod_lion_bruce_stun",
	"mod_lion_bruce_damage"
}
tt.custom_attack.damage_boss = nil
tt.custom_attack.range = 40
tt.custom_attack.vis_flags = bor(F_RANGED, F_STUN, F_CUSTOM)
tt.custom_attack.vis_bans = bor(F_FLYING)
tt.custom_attack.damage_type = DAMAGE_TRUE
tt.duration = 5
tt.motion.max_speed = 150
tt.main_script.insert = kr3_scripts.lion_bruce.insert
tt.main_script.update = kr3_scripts.lion_bruce.update
tt.nav_path.dir = -1
tt.render.sprites[1].anchor.y = 0.22058823529411764
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.render.sprites[1].angles_custom = {
	walk = {
		55,
		135,
		240,
		315
	}
}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].loop_forced = true
tt.render.sprites[1].prefix = "bruce_ultimate"
tt.sound_events.custom_loop_end = "ElvesHeroBruceGuardianLionsLoopEnd"
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.5,
		255
	}
}
tt = RT("hero_lynn", "hero")

AC(tt, "dodge", "melee", "timed_attacks")

tt.hero.level_stats.armor = {
	0.04,
	0.08,
	0.12,
	0.16,
	0.2,
	0.24,
	0.28,
	0.32,
	0.36,
	0.4
}
tt.hero.level_stats.hp_max = {
	350,
	370,
	390,
	410,
	430,
	450,
	470,
	490,
	510,
	530
}
tt.hero.level_stats.melee_damage_max = {
	14,
	17,
	19,
	22,
	24,
	26,
	29,
	31,
	34,
	36
}
tt.hero.level_stats.melee_damage_min = {
	10,
	11,
	13,
	14,
	16,
	18,
	19,
	21,
	22,
	24
}
tt.hero.level_stats.regen_health = {
	25,
	27,
	28,
	30,
	32,
	33,
	35,
	37,
	38,
	40
}
tt.hero.skills.hexfury = E:clone_c("hero_skill")
tt.hero.skills.hexfury.hr_cost = {
	4,
	4,
	4
}
tt.hero.skills.hexfury.hr_icon = "0061"
tt.hero.skills.hexfury.hr_order = 1
tt.hero.skills.hexfury.extra_damage = 20
tt.hero.skills.hexfury.loops = {
	1,
	2,
	3
}
tt.hero.skills.hexfury.xp_gain = {
	30,
	60,
	90
}
tt.hero.skills.hexfury.xp_gain_factor = 10
tt.hero.skills.despair = E:clone_c("hero_skill")
tt.hero.skills.despair.duration = {
	4,
	6,
	8
}
tt.hero.skills.despair.damage_factor = {
	0.9,
	0.8,
	0.7
}
tt.hero.skills.despair.speed_factor = {
	0.7,
	0.6,
	0.5
}
tt.hero.skills.despair.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.despair.hr_icon = "0062"
tt.hero.skills.despair.hr_order = 2
tt.hero.skills.despair.xp_gain = {
	25,
	50,
	100
}
tt.hero.skills.weakening = E:clone_c("hero_skill")
tt.hero.skills.weakening.duration = {
	4,
	6,
	8
}
tt.hero.skills.weakening.armor_reduction = {
	0.3,
	0.5,
	0.7
}
tt.hero.skills.weakening.magic_armor_reduction = {
	0.3,
	0.5,
	0.7
}
tt.hero.skills.weakening.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.weakening.hr_icon = "0063"
tt.hero.skills.weakening.hr_order = 3
tt.hero.skills.weakening.xp_gain = {
	25,
	50,
	100
}
tt.hero.skills.charm_of_unluck = E:clone_c("hero_skill")
tt.hero.skills.charm_of_unluck.chance = {
	0.15,
	0.3,
	0.45
}
tt.hero.skills.charm_of_unluck.hr_cost = {
	1,
	1,
	1
}
tt.hero.skills.charm_of_unluck.hr_icon = "0064"
tt.hero.skills.charm_of_unluck.hr_order = 4
tt.hero.skills.charm_of_unluck.xp_gain = {
	10,
	10,
	10
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_lynn_ultimate"
tt.hero.skills.ultimate.damage = {
	[0] = 24,
	34,
	52,
	70
}
tt.hero.skills.ultimate.explode_damage = {
	[0] = 100,
	200,
	250,
	300
}
tt.hero.skills.ultimate.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.ultimate.hr_icon = "0065"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.key = "FATE_SEALED"
tt.dodge.chance = 0
tt.dodge.silent = true
tt.dodge.ranged = true
tt.dodge.time_before_hit = 0
tt.health.dead_lifetime = 18
tt.health.on_damage = kr3_scripts.hero_lynn.on_damage
tt.health_bar.offset = v(0, 43)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_lynn.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.fn = kr3_scripts.hero_basic.get_info_melee
tt.info.hero_portrait = "hero_portraits_0014"
tt.info.i18n_key = "HERO_ELVES_LYNN"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0014"
tt.info.ultimate_icon = "0013"
tt.main_script.insert = kr3_scripts.hero_basic.insert
tt.main_script.update = kr3_scripts.hero_lynn.update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.12
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_lynn"
tt.soldier.melee_slot_offset = v(0, -1)
tt.sound_events.change_rally_point = "ElvesHeroLynnTaunt"
tt.sound_events.death = "ElvesHeroLynnDeath"
tt.sound_events.hero_room_select = "ElvesHeroLynnTauntSelect"
tt.sound_events.insert = "ElvesHeroLynnTauntIntro"
tt.sound_events.respawn = "ElvesHeroLynnTauntIntro"
tt.unit.hit_offset = v(0, 16)
tt.unit.mod_offset = v(0, 15)
tt.unit.marker_offset = v(0, 0)
tt.melee.cooldown = 1
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].mod = nil
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 0.62
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = CC("melee_attack")
tt.melee.attacks[3].animations = {
	nil,
	"hexfury"
}
tt.melee.attacks[3].cooldown = 16
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].damage_max = 60
tt.melee.attacks[3].damage_min = 60
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].fn_damage = kr3_scripts.hero_lynn.fn_damage_melee
tt.melee.attacks[3].hit_times = {
	fts(13),
	fts(21)
}
tt.melee.attacks[3].interrupt_loop_on_dead_target = true
tt.melee.attacks[3].loops = nil
tt.melee.attacks[3].mod = nil
tt.melee.attacks[3].sound_loop = "ElvesHeroLynnHexfury"
tt.melee.attacks[3].sound_loop_args = {
	delay = fts(3)
}
tt.melee.attacks[3].xp_from_skill = "hexfury"
tt.melee.attacks[3].xp_gain_factor = 10
tt.melee.range = 60
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "curseOfDespair"
tt.timed_attacks.list[1].cooldown = 18
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_time = fts(21)
tt.timed_attacks.list[1].max_count = 5
tt.timed_attacks.list[1].min_count = 3
tt.timed_attacks.list[1].mod = "mod_lynn_despair"
tt.timed_attacks.list[1].range = 200
tt.timed_attacks.list[1].sound = "ElvesHeroLynnCurseDespair"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(4)
}
tt.timed_attacks.list[1].vis_flags = bor(F_MOD, F_RANGED)
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "weakeningCurse"
tt.timed_attacks.list[2].cooldown = 14
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].hit_time = fts(21)
tt.timed_attacks.list[2].mod = "mod_lynn_weakening"
tt.timed_attacks.list[2].hit_time = fts(21)
tt.timed_attacks.list[2].sound = "ElvesHeroLynnWeakening"
tt = RT("hero_lynn_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.can_fire_fn = kr3_scripts.hero_regson_ultimate.can_fire_fn
tt.main_script.update = kr3_scripts.hero_lynn_ultimate.update
tt.mod = "mod_lynn_ultimate"
tt.range = 50
tt.vis_flags = F_RANGED
tt.vis_bans = 0
tt.cooldown = 30
tt.sound_events.insert = "ElvesHeroLynnFateSealed"
tt = RT("hero_phoenix", "hero")

E:add_comps(tt, "ranged", "timed_attacks", "selfdestruct")

tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.hp_max = {
	350,
	370,
	390,
	410,
	430,
	450,
	470,
	490,
	510,
	530
}
tt.hero.level_stats.melee_damage_max = {
	1,
	2,
	4,
	4,
	5,
	6,
	7,
	8,
	9,
	10
}
tt.hero.level_stats.melee_damage_min = {
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10
}
tt.hero.level_stats.regen_health = {
	18,
	19,
	20,
	21,
	22,
	23,
	24,
	25,
	26,
	27
}
tt.hero.level_stats.ranged_damage_min = {
	16,
	19,
	22,
	24,
	27,
	30,
	33,
	35,
	38,
	41
}
tt.hero.level_stats.ranged_damage_max = {
	24,
	29,
	33,
	37,
	41,
	45,
	49,
	53,
	57,
	61
}
tt.hero.level_stats.egg_damage = {
	4,
	5,
	5,
	6,
	7,
	7,
	8,
	9,
	9,
	10
}
tt.hero.level_stats.egg_explosion_damage_max = {
	72,
	84,
	96,
	108,
	120,
	132,
	144,
	156,
	168,
	180
}
tt.hero.level_stats.egg_explosion_damage_min = {
	48,
	56,
	64,
	72,
	80,
	88,
	96,
	104,
	112,
	120
}
tt.hero.skills.inmolate = E:clone_c("hero_skill")
tt.hero.skills.inmolate.hr_cost = {
	3,
	3,
	3
}
tt.hero.skills.inmolate.hr_icon = "0051"
tt.hero.skills.inmolate.hr_order = 1
tt.hero.skills.inmolate.damage_max = {
	115,
	235,
	350
}
tt.hero.skills.inmolate.damage_min = {
	65,
	125,
	190
}
tt.hero.skills.inmolate.xp_gain = {
	170,
	340,
	510
}
tt.hero.skills.purification = E:clone_c("hero_skill")
tt.hero.skills.purification.hr_cost = {
	1,
	1,
	1
}
tt.hero.skills.purification.hr_icon = "0052"
tt.hero.skills.purification.hr_order = 2
tt.hero.skills.purification.damage_min = {
	15,
	25,
	35
}
tt.hero.skills.purification.damage_max = {
	15,
	25,
	35
}
tt.hero.skills.purification.max_targets = {
	3,
	5,
	7
}
tt.hero.skills.blazing_offspring = E:clone_c("hero_skill")
tt.hero.skills.blazing_offspring.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.blazing_offspring.hr_icon = "0053"
tt.hero.skills.blazing_offspring.hr_order = 3
tt.hero.skills.blazing_offspring.damage_max = {
	55,
	70,
	80
}
tt.hero.skills.blazing_offspring.damage_min = {
	30,
	40,
	45
}
tt.hero.skills.blazing_offspring.count = {
	2,
	3,
	4
}
tt.hero.skills.blazing_offspring.xp_gain = {
	36,
	72,
	108
}
tt.hero.skills.flaming_path = E:clone_c("hero_skill")
tt.hero.skills.flaming_path.damage = {
	20,
	40,
	60
}
tt.hero.skills.flaming_path.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.flaming_path.hr_icon = "0054"
tt.hero.skills.flaming_path.hr_order = 4
tt.hero.skills.flaming_path.xp_gain = {
	75,
	150,
	225
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.damage_max = {
	[0] = 45,
	105,
	220,
	400
}
tt.hero.skills.ultimate.damage_min = {
	[0] = 25,
	55,
	120,
	200
}
tt.hero.skills.ultimate.hr_cost = {
	3,
	4,
	5
}
tt.hero.skills.ultimate.hr_icon = "0055"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.xp_gain = {
	0,
	0,
	0
}
tt.hero.skills.ultimate.controller_name = "hero_phoenix_ultimate"
tt.hero.skills.ultimate.key = "EMBER"
tt.health.dead_lifetime = 5
tt.health_bar.draw_order = -1
tt.health_bar.offset = v(0, 160)
tt.health_bar.sort_y_offset = -200
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.hero.fn_level_up = kr3_scripts.hero_phoenix.level_up
tt.hero.tombstone_show_time = nil
tt.hero.use_custom_spawn_point = true
tt.idle_flip.cooldown = 10
tt.info.damage_icon = "fireball"
tt.info.fn = kr3_scripts.hero_phoenix.get_info
tt.info.hero_portrait = "hero_portraits_0011"
tt.info.i18n_key = "HERO_ELVES_PHOENIX"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0011"
tt.info.ultimate_icon = "0011"
tt.main_script.insert = kr3_scripts.hero_phoenix.insert
tt.main_script.update = kr3_scripts.hero_phoenix.update
tt.motion.max_speed = 3.5 * FPS
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = TERRAIN_ALL_MASK
tt.nav_grid.valid_terrains_dest = TERRAIN_ALL_MASK
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.19411764705882
tt.render.sprites[1].prefix = "hero_phoenix"
tt.render.sprites[1].angles.walk = {
	"idle"
}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "phoenix_hero_0192"
tt.render.sprites[2].anchor.y = 0.19117647058823528
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].alpha = 90
tt.soldier.melee_slot_offset = v(0, 0)
tt.sound_events.change_rally_point = "ElvesHeroPhoenixTaunt"
tt.sound_events.death = "ElvesHeroPhoenixDeath"
tt.sound_events.hero_room_select = "ElvesHeroPhoenixTauntSelect"
tt.sound_events.insert = "ElvesHeroPhoenixTauntIntro"
tt.sound_events.respawn = "ElvesHeroPhoenixTauntIntro"
tt.ui.click_rect = IS_PHONE and r(-35, 90, 70, 75) or r(-25, 80, 50, 55)
tt.unit.hit_offset = v(0, 100)
tt.unit.hide_after_death = true
tt.unit.mod_offset = v(0, 134)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON, F_BURN)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "ray_phoenix"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 100)
}
tt.ranged.attacks[1].cooldown = 1 + fts(17)
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].shoot_time = fts(23)
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].sound_shoot = "ElvesHeroPhoenixAttack"
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].bullet = "missile_phoenix"
tt.ranged.attacks[2].bullet_start_offset = {
	v(5, 115)
}
tt.ranged.attacks[2].cooldown = 22
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].min_range = 0
tt.ranged.attacks[2].max_range = 300
tt.ranged.attacks[2].shoot_times = {}
tt.ranged.attacks[2].sync_animation = true
tt.ranged.attacks[2].animations = {
	nil,
	"birdThrow"
}
tt.ranged.attacks[2].sound = "ElvesHeroPhoenixBlazingOffspringShoot"
tt.ranged.attacks[2].loops = 1
tt.ranged.attacks[2].xp_from_skill_once = "blazing_offspring"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].cooldown = 45
tt.timed_attacks.list[1].min_count = 3
tt.timed_attacks.list[1].range = 60
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].animation = "birdThrow"
tt.timed_attacks.list[2].cooldown = 30
tt.timed_attacks.list[2].max_count = 1
tt.timed_attacks.list[2].max_range = 150
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].mod = "mod_phoenix_flaming_path"
tt.timed_attacks.list[2].hit_time = fts(4)
tt.timed_attacks.list[2].sound = "ElvesHeroPhoenixRingOfFireSpawn"
tt.timed_attacks.list[2].enemies_min_count = 2
tt.timed_attacks.list[2].enemies_range = 125
tt.timed_attacks.list[2].enemies_vis_flags = F_RANGED
tt.timed_attacks.list[2].enemies_vis_bans = bor(F_FLYING)
tt.selfdestruct.animation = "suicide"
tt.selfdestruct.damage_radius = 80
tt.selfdestruct.damage_type = DAMAGE_PHYSICAL
tt.selfdestruct.damage_max = nil
tt.selfdestruct.damage_min = nil
tt.selfdestruct.disabled = true
tt.selfdestruct.hit_time = fts(29)
tt.selfdestruct.hit_fx = "fx_phoenix_inmolation"
tt.selfdestruct.sound = "ElvesHeroPhoenixImmolation"
tt.selfdestruct.sound_args = {
	delay = fts(10)
}
tt.selfdestruct.dead_lifetime = 5
tt.selfdestruct.xp_from_skill = "inmolate"
tt = RT("hero_phoenix_ultimate", "aura")

AC(tt, "render", "tween")

tt.aura.duration = 180
tt.aura.vis_flags = F_RANGED
tt.aura.vis_bans = F_FLYING
tt.aura.damage_vis_bans = 0
tt.aura.radius = 50
tt.aura.hit_fx = "fx_phoenix_explosion"
tt.aura.hit_decal = "decal_phoenix_ultimate"
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.damage_max = nil
tt.aura.damage_min = nil
tt.can_fire_fn = kr3_scripts.hero_phoenix_ultimate.can_fire_fn
tt.cooldown = 18
tt.main_script.update = kr3_scripts.hero_phoenix_ultimate.update
tt.sound_events.insert = "ElvesHeroPhoenixFireEggDrop"
tt.sound_events.activate = "ElvesHeroPhoenixFireEggActivate"
tt.sound_events.explode = "ElvesHeroPhoenixFireEggExplosion"
tt.render.sprites[1].prefix = "phoenix_ultimate"
tt.render.sprites[1].name = "place"
tt.render.sprites[1].anchor.y = 0.45
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "phoenix_hero_egg_0016"
tt.render.sprites[2].animated = false
tt.render.sprites[2].alpha = 0
tt.render.sprites[2].anchor.y = 0.45
tt.activate_delay = 2
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.9,
		255
	},
	{
		1.1,
		255
	},
	{
		2,
		0
	}
}
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].loop = true
tt = E:register_t("kr3_hero_alleria", "stage_hero")

E:add_comps(tt, "melee", "ranged")

image_y = 66
anchor_y = 15 / image_y
tt.health.armor = 0
tt.health.dead_lifetime = 15
tt.health.hp_max = 210
tt.health_bar.offset = v(0, 36)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.level = 3
tt.hero.xp = 11299
tt.hero.tombstone_show_time = fts(90)
tt.idle_flip.cooldown = 1
tt.info.fn = kr3_scripts.hero_basic.get_info_melee
tt.info.hero_portrait = "hero_portraits_0019"
tt.info.i18n_key = "HERO_ARCHER"
tt.info.portrait = "portraits_sc_0064"
tt.info.damage_icon = "arrow"
tt.fixed_mode = nil
tt.main_script.insert = kr3_scripts.hero_alleria.insert
tt.main_script.update = kr3_scripts.hero_alleria.update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.regen.health = 23
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_alleria"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[1].angles.ranged = {
	"shoot"
}
tt.soldier.melee_slot_offset.x = 2
tt.sound_events.change_rally_point = "ElvesHeroAlleriaTaunt"
tt.sound_events.death = "ElvesHeroAlleriaDeath"
tt.sound_events.insert = "ElvesHeroAlleriaTauntIntro"
tt.sound_events.respawn = "ElvesHeroAlleriaTauntIntro"
tt.unit.hit_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 13)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 15
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.range = 65
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].bullet = "arrow_hero_alleria"
tt.ranged.attacks[1].bullet_start_offset = {
	v(9, 24)
}
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].node_prediction = fts(11)
tt.ranged.attacks[1].shoot_time = fts(11)
tt.ranged.attacks[2] = E:clone_c("bullet_attack")
tt.ranged.attacks[2].animation = "shootSpecial"
tt.ranged.attacks[2].bullet = "arrow_multishot_hero_alleria"
tt.ranged.attacks[2].bullet_start_offset = {
	v(9, 24)
}
tt.ranged.attacks[2].cooldown = 5
tt.ranged.attacks[2].max_range = 200
tt.ranged.attacks[2].min_range = 40
tt.ranged.attacks[2].node_prediction = fts(13)
tt.ranged.attacks[2].shoot_time = fts(13)
tt.ranged.attacks[2].sound = "ElvesHeroAlleriaShoot"
tt = E:register_t("hero_alleria_fixed", "kr3_hero_alleria")
tt.fixed_mode = true
tt.health.ignore_damage = true
tt.health_bar.hidden = true
tt.vis.bans = F_ALL
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.ui.can_click = false
tt.ui.can_select = false
tt.ranged.attacks[1].bullet = "arrow_hero_alleria_fixed"
tt.ranged.attacks[1].filter_fn = kr3_scripts.hero_alleria.fixed_ranged_filter_fn
tt.ranged.attacks[1].max_range = 600
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[2].bullet = "arrow_multishot_hero_alleria_fixed"
tt.ranged.attacks[2].cooldown = 7
tt.ranged.attacks[2].filter_fn = kr3_scripts.hero_alleria.fixed_ranged_filter_fn
tt.ranged.attacks[2].max_range = 600
tt.ranged.attacks[2].min_range = 0
tt = E:register_t("arrow_hero_alleria", "arrow")
tt.bullet.flight_time = fts(22)
tt.bullet.damage_min = 10
tt.bullet.damage_max = 15
tt = E:register_t("arrow_multishot_hero_alleria", "arrow")
tt.bullet.particles_name = "ps_arrow_multishot_hero_alleria"
tt.bullet.damage_min = 10
tt.bullet.damage_max = 15
tt.bullet.damage_true = DAMAGE_TRUE
tt.bullet.flight_time = fts(22)
tt.extra_arrows_range = 100
tt.extra_arrows = 2
tt.main_script.insert = kr3_scripts.arrow_multishot_hero_alleria.insert
tt.render.sprites[1].name = "hero_alleria_arrow-f"
tt = E:register_t("arrow_hero_alleria_fixed", "arrow_hero_alleria")
tt.bullet.damage_min = 10
tt.bullet.damage_max = 30
tt.bullet.prediction_error = nil
tt = E:register_t("arrow_multishot_hero_alleria_fixed", "arrow_multishot_hero_alleria")
tt.bullet.damage_min = 10
tt.bullet.damage_max = 30
tt.bullet.prediction_error = nil
tt.extra_arrows = 3
tt = E:register_t("alleria_cat", "soldier")

E:add_comps(tt, "nav_grid")

anchor_y = 0.2619047619047619
image_y = 42
tt.behaviour_attack = {}
tt.behaviour_attack.min_cooldown = 2
tt.behaviour_attack.max_cooldown = 3
tt.behaviour_attack.cooldown = tt.behaviour_attack.min_cooldown
tt.behaviour_attack.animation = "attack"
tt.behaviour_attack.sound = "ElvesAlleriaCatHit"
tt.behaviour_attack.hit_time = fts(9)
tt.behaviour_attack.min_distance = 10
tt.behaviour_attack.max_distance = 100
tt.behaviour_attack.y_offset = -6
tt.behaviour_scared = {}
tt.behaviour_scared.min_cooldown = fts(150)
tt.behaviour_scared.max_cooldown = fts(160)
tt.behaviour_scared.cooldown = tt.behaviour_scared.min_cooldown
tt.behaviour_scared.animation = "scared"
tt.health.armor = 0
tt.health.hp_max = 150
tt.health.ignore_damage = true
tt.health_bar.hidden = true
tt.info.i18n_key = "HERO_ARCHER_WILDCAT"
tt.main_script.update = kr3_scripts.alleria_cat.update
tt.motion.max_speed = 69
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "alleria_wildcat"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.ui.can_click = false
tt.ui.can_select = false
tt.unit.hit_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.unit.hide_after_death = true
tt.unit.explode_fx = nil
tt.vis.bans = F_ALL
tt = RT("hero_baby_malik", "stage_hero")

AC(tt, "melee")

tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.hp_max = {
	320,
	345,
	370,
	395,
	420,
	445,
	470,
	495,
	520,
	545
}
tt.hero.level_stats.melee_damage_max = {
	17,
	18,
	20,
	21,
	23,
	24,
	25,
	27,
	28,
	30
}
tt.hero.level_stats.melee_damage_min = {
	11,
	12,
	13,
	14,
	15,
	16,
	17,
	18,
	19,
	20
}
tt.hero.level_stats.regen_health = {
	18,
	19,
	21,
	23,
	24,
	26,
	28,
	29,
	31,
	33
}
tt.hero.skills.smash = CC("hero_skill")
tt.hero.skills.smash.damage_min = {
	45,
	90,
	130
}
tt.hero.skills.smash.damage_max = {
	55,
	110,
	170
}
tt.hero.skills.smash.xp_gain = {
	1000,
	2000,
	3000
}
tt.hero.skills.smash.skill_upgrade_levels = {
	2,
	5,
	8
}
tt.hero.skills.fissure = CC("hero_skill")
tt.hero.skills.fissure.damage_radius = {
	16.5,
	33,
	49.5
}
tt.hero.skills.fissure.damage_min = {
	25,
	50,
	75
}
tt.hero.skills.fissure.damage_max = {
	25,
	50,
	75
}
tt.hero.skills.fissure.xp_gain = {
	2000,
	4000,
	8000
}
tt.hero.skills.fissure.skill_upgrade_levels = {
	4,
	7,
	10
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr3_scripts.hero_baby_malik.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.fn = kr3_scripts.hero_basic.get_info_melee
tt.info.hero_portrait = "hero_portraits_0013"
tt.info.i18n_key = "HERO_ELVES_MALIK"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0013"
tt.info.ultimate_icon = "0013"
tt.main_script.update = kr3_scripts.hero_baby_malik.update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.184
tt.render.sprites[1].prefix = "baby_malik"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[1].angles.ranged = {
	"shoot"
}
tt.render.sprites[1].name = "idle"
tt.soldier.melee_slot_offset = v(2, 0)
tt.sound_events.change_rally_point = "HeroReinforcementTaunt"
tt.sound_events.death = "HeroReinforcementDeath"
tt.sound_events.insert = {
	"HeroReinforcementTaunt",
	"HeroReinforcementTauntIntro"
}
tt.sound_events.respawn = "HeroReinforcementTauntIntro"
tt.unit.hit_offset = v(0, 16)
tt.unit.mod_offset = v(0, 13)
tt.melee.range = 65
tt.melee.cooldown = 1
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 6.5
tt.melee.attacks[1].sound_hit = "HeroReinforcementHit"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = CC("area_attack")
tt.melee.attacks[3].animation = "smash"
tt.melee.attacks[3].cooldown = 10
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_radius = 50
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_decal = "decal_baby_malik_smash"
tt.melee.attacks[3].hit_offset = v(22, 0)
tt.melee.attacks[3].hit_time = fts(14)
tt.melee.attacks[3].min_count = 3
tt.melee.attacks[3].sound = "HeroReinforcementSpecial"
tt.melee.attacks[3].xp_from_skill = "smash"
tt.melee.attacks[4] = CC("area_attack")
tt.melee.attacks[4].animation = "jumpSmash"
tt.melee.attacks[4].cooldown = 20
tt.melee.attacks[4].damage_type = DAMAGE_TRUE
tt.melee.attacks[4].disabled = true
tt.melee.attacks[4].hit_aura = "aura_baby_malik_fissure"
tt.melee.attacks[4].hit_offset = v(22, 0)
tt.melee.attacks[4].hit_time = fts(17)
tt.melee.attacks[4].sound = "HeroReinforcementJump"
tt.melee.attacks[4].xp_from_skill = "fissure"
tt = RT("hero_bolverk", "stage_hero")

AC(tt, "melee", "timed_attacks")

tt.health.armor = 0
tt.health.dead_lifetime = 15
tt.health.hp_max = 545
tt.health_bar.offset = v(0, 43)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.level = 10
tt.hero.xp = 115300
tt.hero.tombstone_show_time = fts(90)
tt.info.fn = kr3_scripts.hero_basic.get_info_melee
tt.info.hero_portrait = "hero_portraits_0018"
tt.info.i18n_key = "HERO_ELVES_BOLVERK"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "info_portraits_heroes") .. "_0018"
tt.main_script.insert = kr3_scripts.hero_bolverk.insert
tt.main_script.update = kr3_scripts.hero_bolverk.update
tt.motion.max_speed = 3 * FPS
tt.regen.health = 33
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.22727272727273
tt.render.sprites[1].prefix = "hero_bolverk"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[1].name = "idle"
tt.soldier.melee_slot_offset = v(2, 0)
tt.sound_events.change_rally_point = "ElvesHeroBolverkTaunt"
tt.sound_events.death = "ElvesHeroBolverkDeath"
tt.sound_events.insert = "ElvesHeroBolverkTauntIntro"
tt.sound_events.respawn = "ElvesHeroBolverkTauntIntro"
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(0, 20)
tt.melee.attacks[1].damage_max = 41
tt.melee.attacks[1].damage_min = 27
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].xp_gain_factor = 0
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "hit"
tt.melee.attacks[2].cooldown = 20
tt.melee.attacks[2].damage_max = 100
tt.melee.attacks[2].damage_min = 80
tt.melee.attacks[2].hit_time = fts(9)
tt.melee.attacks[2].sound = "ElvesHeroBolverkSlash"
tt.melee.attacks[2].vis_bans = F_BOSS
tt.melee.range = 55
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "scream"
tt.timed_attacks.list[1].cooldown = 10
tt.timed_attacks.list[1].max_range = 60
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].min_count = 3
tt.timed_attacks.list[1].mod = "mod_bolverk_scream"
tt.timed_attacks.list[1].hit_time = fts(9)
tt.timed_attacks.list[1].sound = "ElvesHeroBolverkCry"
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_BOSS)
tt = E:register_t("enemy_gnoll_reaver", "enemy")

E:add_comps(tt, "melee")

image_y = 54
anchor_y = 9 / image_y
tt.enemy.gold = 5
tt.enemy.melee_slot = v(18, 0)
tt.health.armor = 0
tt.health.hp_max = {
	40,
	50,
	60,
	80
}
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, ady(38))
tt.info.enc_icon = 1
tt.info.portrait = "portraits_sc_0004"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {
	6,
	6,
	6,
	7
}
tt.melee.attacks[1].damage_min = {
	3,
	3,
	3,
	4
}
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.5 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "gnoll_reaver"
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, ady(8))
tt.unit.mod_offset = v(0, ady(20))
tt = E:register_t("enemy_gnoll_burner", "enemy")

E:add_comps(tt, "melee", "ranged")

tt.info.enc_icon = 2
tt.info.portrait = "portraits_sc_0006"
tt.enemy.gold = 5
tt.enemy.melee_slot = v(27, 0)
tt.health.hp_max = {
	50,
	60,
	75,
	95
}
tt.health_bar.offset = v(0, 38)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {
	4,
	4,
	4,
	10
}
tt.melee.attacks[1].damage_min = {
	2,
	2,
	2,
	5
}
tt.melee.attacks[1].hit_time = fts(17)
tt.motion.max_speed = 1.5 * FPS
tt.ranged.attacks[1].bullet = "torch_gnoll_burner"
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[1].cooldown = 3
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 36)
}
tt.ranged.attacks[1].vis_flags = bor(F_RANGED, F_CUSTOM, F_BURN)
tt.render.sprites[1].anchor = v(0.5, 0.21428571428571427)
tt.render.sprites[1].prefix = "gnoll_burner"
tt.sound_events.death = "DeathGoblin"
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.unit.size = UNIT_SIZE_SMALL
tt = E:register_t("enemy_gnoll_gnawer", "enemy")

E:add_comps(tt, "melee", "auras")

tt.info.enc_icon = 3
tt.info.portrait = "portraits_sc_0005"
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_gnoll_gnawer"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 20
tt.enemy.melee_slot = v(35, 0)
tt.health.armor = {
	0.4,
	0.4,
	0.4,
	0.6
}
tt.health.hp_max = {
	200,
	250,
	300,
	300
}
tt.health_bar.offset = v(0, 47)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(17)
tt.motion.max_speed = 1.1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.25)
tt.render.sprites[1].prefix = "gnoll_gnawer"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect = r(-20, 0, 40, 40)
tt.unit.hit_offset = v(0, 22)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 19)
tt.unit.size = UNIT_SIZE_MEDIUM
tt = E:register_t("enemy_gnoll_blighter", "enemy")

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.info.portrait = "portraits_sc_0019"
tt.info.enc_icon = 4
tt.enemy.gold = 50
tt.enemy.melee_slot = v(30, 0)
tt.health.hp_max = {
	500,
	700,
	750,
	850
}
tt.health.magic_armor = {
	0.75,
	0.75,
	0.75,
	0.85
}
tt.health_bar.offset = v(0, 42)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_gnoll_blighter.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].hit_time = fts(23)
tt.motion.max_speed = 0.8 * FPS
tt.ranged.attacks[1].animation = "energy"
tt.ranged.attacks[1].bullet = "bullet_gnoll_blighter"
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].shoot_time = fts(20)
tt.ranged.attacks[1].cooldown = 1 + fts(23) + fts(6)
tt.ranged.attacks[1].max_range = 160
tt.ranged.attacks[1].min_range = 30
tt.ranged.attacks[1].bullet_start_offset = {
	v(14, 0)
}
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].vis_bans = F_FLYING
tt.ranged.attacks[1].requires_magic = true
tt.render.sprites[1].anchor = v(0.5, 0.1891891891891892)
tt.render.sprites[1].prefix = "gnoll_blighter"
tt.sound_events.death = "DeathBig"
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].mod = "mod_gnoll_blighter"
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].animation = "attackPlants"
tt.timed_attacks.list[1].range = 175
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt = E:register_t("enemy_hyena", "enemy")

E:add_comps(tt, "melee")

tt.info.enc_icon = 7
tt.info.portrait = "portraits_sc_0008"
tt.enemy.gold = 10
tt.enemy.melee_slot = v(10, 0)
tt.health.hp_max = {
	30,
	40,
	45
}
tt.health.magic_armor = {
	0.3,
	0.3,
	0.3,
	0.7
}
tt.health_bar.offset = v(0, 35)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_hyena.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 0
tt.melee.attacks[1].damage_min = 0
tt.melee.attacks[1].hit_time = fts(22)
tt.motion.max_speed = 2.6 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.3382352941176471)
tt.render.sprites[1].prefix = "hyena"
tt.render.sprites[1].angles.run = {
	"runningRightLeft",
	"runningUp",
	"runningDown"
}
tt.render.sprites[1].angles_stickiness.run = 10
tt.sound_events.death = "DeathGoblin"
tt.sound_events.insert = "ElvesCreepHyena"
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.coward_duration = 1.2
tt.coward_speed_factor = 1.5
tt = E:register_t("enemy_ettin", "enemy")

E:add_comps(tt, "melee", "auras", "endless")

tt.info.portrait = "portraits_sc_0014"
tt.info.enc_icon = 5
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_ettin_regen"
tt.auras.list[1].cooldown = 0
tt.endless.factor_map = {
	{
		"enemy_ettin.basicCooldownTime",
		"insane.cooldown_min",
		true
	},
	{
		"enemy_ettin.basicCooldownTime",
		"insane.cooldown_max",
		true
	}
}
tt.enemy.gold = 70
tt.enemy.lives_cost = {
	2,
	2,
	2,
	4
}
tt.enemy.melee_slot = v(35, 0)
tt.health.hp_max = {
	700,
	900,
	1000,
	1500
}
tt.health_bar.offset = v(0, 72)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_ettin.update
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_max = {
	95,
	95,
	95,
	105
}
tt.melee.attacks[1].damage_min = {
	85,
	85,
	85,
	85
}
tt.melee.attacks[1].hit_time = fts(23)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.1111111111111111)
tt.render.sprites[1].prefix = "ettin"
tt.sound_events.death = "DeathBig"
tt.unit.hit_offset = v(0, 32)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 30)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.insane = {}
tt.insane.cooldown_max = 22
tt.insane.cooldown_min = 12
tt.insane.damage_max = 10
tt.insane.damage_min = 5
tt.insane.damage_type = DAMAGE_TRUE
tt.insane.stun_duration = 2
tt.insane.hit_time = fts(28)
tt.ui.click_rect = r(-25, -5, 50, 60)
tt = E:register_t("enemy_perython", "enemy")
tt.info.enc_icon = 6
tt.info.portrait = "portraits_sc_0009"
tt.enemy.gold = 18
tt.health.hp_max = {
	90,
	120,
	120
}
tt.health_bar.offset = v(0, 90)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_passive.update
tt.motion.max_speed = {
	1.8 * FPS,
	1.8 * FPS,
	1.8 * FPS,
	2.4 * FPS
}
tt.render.sprites[1].anchor = v(0.5, 0.058823529411764705)
tt.render.sprites[1].prefix = "perython"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-15, 50, 30, 25)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 65)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 60)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt = E:register_t("enemy_perython_gnoll_gnawer", "enemy_perython")

E:add_comps(tt, "death_spawns")

tt.info.i18n_key = "ENEMY_PERYTHON"
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "gnoll_gnawer_flying"
tt.render.sprites[3].anchor = v(0.5, 0.25)
tt.death_spawns.name = "enemy_gnoll_gnawer"
tt.death_spawns.concurrent_with_death = false
tt.main_script.update = kr3_scripts.enemy_perython_carrier.update
tt.spawn_trigger_range = 100
tt = E:register_t("enemy_twilight_elf_harasser", "enemy")

E:add_comps(tt, "melee", "ranged", "dodge")

tt.info.enc_icon = 8
tt.info.portrait = "portraits_sc_0021"
tt.dodge.ranged = false
tt.dodge.cooldown = 7
tt.dodge.chance = 1
tt.dodge.max_nodes = -10
tt.dodge.min_nodes = -18
tt.dodge.nodeslimit = 10
tt.dodge.requires_magic = true
tt.enemy.gold = 25
tt.enemy.melee_slot = v(26, 0)
tt.health.armor = {
	0.3,
	0.3,
	0.3,
	0.5
}
tt.health.hp_max = {
	220,
	275,
	325
}
tt.health_bar.offset = v(0, 34)
tt.info.enc_icon = 8
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_twilight_elf_harasser.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {
	30,
	30,
	30,
	35
}
tt.melee.attacks[1].damage_min = {
	20,
	20,
	20,
	25
}
tt.melee.attacks[1].hit_time = fts(24)
tt.motion.max_speed = 1.5 * FPS
tt.ranged.attacks[1].animations = {
	"shoot_start",
	"shoot_loop",
	"shoot_end"
}
tt.ranged.attacks[1].bullet = "arrow_twilight_elf_harasser"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 27)
}
tt.ranged.attacks[1].cooldown = 10
tt.ranged.attacks[1].loops = 4
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 60
tt.ranged.attacks[1].repeat_cooldown = fts(20)
tt.ranged.attacks[1].shoot_time = fts(3)
tt.ranged.attacks[1].vis_flags = bor(F_RANGED, F_CUSTOM)
tt.render.sprites[1].anchor = v(0.5, 0.1891891891891892)
tt.render.sprites[1].prefix = "harraser"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt.shadow_shot = E:clone_c("bullet_attack")
tt.shadow_shot.bullet = "arrow_twilight_elf_harasser_shadowshot"
tt.shadow_shot.animation = "shadow_shot"
tt.shadow_shot.shoot_time = fts(14)
tt.shadow_shot.bullet_start_offset = {
	v(0, 27)
}
tt.shadow_shot.min_range = 25
tt.shadow_shot.max_range = 175
tt = E:register_t("enemy_catapult", "enemy")

E:add_comps(tt, "ranged")

tt.duration = nil
tt.enemy.gold = 100
tt.enemy.melee_slot = v(40, -10)
tt.enemy.remove_at_goal_line = false
tt.health.hp_max = {
	160,
	200,
	240
}
tt.health.dead_lifetime = 3
tt.health_bar.offset = v(0, 60)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_GNOLL_CATAPULT"
tt.info.portrait = "portraits_sc_0051"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_catapult.update
tt.motion.max_speed = 45
tt.phase_1_ni = nil
tt.ranged.attacks[1].bullet = "rock_enemy_catapult"
tt.ranged.attacks[1].bullet_start_offset = {
	v(30, 90)
}
tt.ranged.attacks[1].cooldown = 3 + fts(80)
tt.ranged.attacks[1].max_x = 800
tt.ranged.attacks[1].min_x = 150
tt.ranged.attacks[1].shoot_time = fts(33)
tt.ranged.attacks[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.render.sprites[1].anchor.y = 0.14285714285714285
tt.render.sprites[1].angles.walk = {
	"running"
}
tt.render.sprites[1].prefix = "catapult"
tt.ui.click_rect = r(-35, -10, 70, 60)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.mod_offset = v(0, 34)
tt.unit.hit_offset = v(0, 34)
tt.unit.marker_offset = v(0, -5)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_STUN, F_TELEPORT, F_DRILL, F_POISON, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt = E:register_t("rock_enemy_catapult", "bomb")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 200
tt.bullet.damage_min = 150
tt.bullet.damage_radius = 50
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time_base = fts(60)
tt.bullet.flight_time_factor = fts(0.04)
tt.bullet.hit_decal = "decal_rock_crater"
tt.bullet.hit_fx = "fx_rock_explosion"
tt.main_script.insert = kr3_scripts.enemy_bomb.insert
tt.main_script.update = kr3_scripts.enemy_bomb.update
tt.render.sprites[1].name = "catapult_proy"
tt.sound_events.insert = "TowerStoneDruidBoulderThrow"
tt = E:register_t("enemy_bandersnatch", "enemy")

E:add_comps(tt, "melee", "timed_attacks")

tt.info.enc_icon = 16
tt.info.portrait = "portraits_sc_0012"
tt.enemy.gold = 300
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(42, 0)
tt.health.hp_max = {
	2500,
	3000,
	3500,
	4500
}
tt.health_bar.offset = v(0, 63)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_radius = 100
tt.melee.attacks[1].damage_max = 60
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_time = fts(24)
tt.melee.attacks[1].fn_filter = kr3_scripts.enemy_bandersnatch.fn_filter_melee
tt.timed_attacks.list[1] = E:clone_c("aura_attack")
tt.timed_attacks.list[1].animation = "spineAttack"
tt.timed_attacks.list[1].bullet = "aura_bandersnatch_spines"
tt.timed_attacks.list[1].cooldown = 4
tt.timed_attacks.list[1].shoot_time = fts(31)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_bandersnatch.update
tt.motion.min_speed = 2.5 * FPS
tt.motion.max_speed = 2.5 * FPS
tt.motion.speed_limit = {
	3.5 * FPS,
	3.5 * FPS,
	3.5 * FPS,
	4.5 * FPS
}
tt.motion.accel = 0.2 * FPS
tt.motion.invulnerable = true
tt.render.sprites[1].anchor = v(0.5, 0.25862068965517243)
tt.render.sprites[1].prefix = "bandersnatch"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect = r(-20, -2, 40, 52)
tt.unit.hit_offset = v(0, 19)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 24)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans_rolling = bor(F_SKELETON, F_STUN, F_FREEZE)
tt.vis.bans_standing = bor(F_SKELETON)
tt.vis.bans = tt.vis.bans_standing
tt = E:register_t("enemy_boomshrooms", "enemy")

E:add_comps(tt, "death_spawns")

tt.info.enc_icon = 32
tt.info.portrait = "portraits_sc_0017"
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_boomshrooms_death"
tt.enemy.gold = 6
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = {
	60,
	75,
	90
}
tt.health.poison_armor = 0.5
tt.health_bar.offset = v(0, 25)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_boomshrooms.update
tt.motion.max_speed = {
	2 * FPS,
	2 * FPS,
	2 * FPS,
	2.2 * FPS
}
tt.render.sprites[1].anchor = v(0.5, 0.1956521739130435)
tt.render.sprites[1].prefix = "fungusRider_small"
tt.sound_events.death = "DeathPuff"
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 13)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)
tt = E:register_t("enemy_munchshrooms", "enemy")

E:add_comps(tt, "melee", "death_spawns")

tt.info.enc_icon = 31
tt.info.portrait = "portraits_sc_0016"
tt.death_spawns.name = "enemy_boomshrooms"
tt.death_spawns.delay = 0.93
tt.death_spawns.quantity = {
	2,
	2,
	2,
	3
}
tt.death_spawns.spread_nodes = 2
tt.enemy.gold = 12
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(23, 0)
tt.health.hp_max = {
	160,
	200,
	250
}
tt.health.poison_armor = 0.5
tt.health_bar.offset = v(0, 40)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {
	15,
	15,
	15,
	30
}
tt.melee.attacks[1].damage_min = 5
tt.melee.attacks[1].hit_time = fts(21)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.motion.max_speed = 1.5 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.17142857142857143)
tt.render.sprites[1].prefix = "fungusRider_medium"
tt.sound_events.death = "DeathEplosion"
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)
tt = E:register_t("enemy_shroom_breeder", "enemy")

E:add_comps(tt, "melee", "death_spawns", "timed_attacks")

tt.info.enc_icon = 15
tt.info.portrait = "portraits_sc_0015"
tt.death_spawns.name = "enemy_munchshrooms"
tt.death_spawns.delay = 0.5
tt.death_spawns.quantity = {
	2,
	2,
	2,
	3
}
tt.death_spawns.spread_nodes = 2
tt.enemy.gold = 25
tt.enemy.lives_cost = 4
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = {
	400,
	500,
	600,
	1000
}
tt.health.poison_armor = 0.5
tt.health_bar.offset = v(0, 58)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_shroom_breeder.update
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(25)
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.125)
tt.render.sprites[1].prefix = "fungusRider"
tt.sound_events.death = "DeathPuff"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].allowed_templates = {
	"enemy_boomshrooms"
}
tt.timed_attacks.list[1].spawn_name = "enemy_munchshrooms"
tt.timed_attacks.list[1].animation = "cast"
tt.timed_attacks.list[1].cast_time = fts(19)
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].max_range = 125
tt.timed_attacks.list[1].max_count = 5
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 15)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 22)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_SKELETON)
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt = E:register_t("enemy_gloomy", "enemy")

E:add_comps(tt, "melee", "timed_attacks", "count_group")

tt.info.enc_icon = 17
tt.info.portrait = "portraits_sc_0018"
tt.count_group.name = "enemy_gloomy"
tt.count_group.type = COUNT_GROUP_CONCURRENT
tt.enemy.gold = 5
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = {
	30,
	35,
	40
}
tt.health_bar.offset = v(0, 67)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_gloomy.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 0
tt.melee.attacks[1].damage_min = 0
tt.melee.attacks[1].hit_time = fts(19)
tt.motion.max_speed = {
	1.5 * FPS,
	1.5 * FPS,
	1.5 * FPS,
	1.7 * FPS
}
tt.render.sprites[1].anchor = v(0.5, 0.04054054054054054)
tt.render.sprites[1].prefix = "gloomy"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "DeathPuff"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].spawn_name = "enemy_gloomy"
tt.timed_attacks.list[1].animation = "castClone"
tt.timed_attacks.list[1].cast_time = fts(8)
tt.timed_attacks.list[1].cooldown_after = 5
tt.timed_attacks.list[1].cooldown = 3
tt.timed_attacks.list[1].count_group_max = 100
tt.timed_attacks.list[1].nodes_limit = 30
tt.timed_attacks.list[1].max_clones = {
	2,
	2,
	2,
	3
}
tt.ui.click_rect = r(-12, 24, 24, 36)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 32)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 37)
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt = E:register_t("enemy_redcap", "enemy")

E:add_comps(tt, "melee")

tt.info.enc_icon = 14
tt.info.portrait = "portraits_sc_0024"
tt.enemy.gold = 12
tt.enemy.melee_slot = v(27, 0)
tt.health.hp_max = {
	100,
	125,
	150
}
tt.health_bar.offset = v(0, 28)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1].damage_max = {
	25,
	25,
	25,
	35
}
tt.melee.attacks[1].damage_min = {
	15,
	15,
	15,
	25
}
tt.melee.attacks[1].hit_time = fts(23)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = E:clone_c("melee_attack")
tt.melee.attacks[2].animation = "special"
tt.melee.attacks[2].chance = 0.2
tt.melee.attacks[2].fn_can = function(t, s, a, target)
	return band(target.vis.flags, F_HERO) == 0
end
tt.melee.attacks[2].hit_time = fts(15)
tt.melee.attacks[2].hit_offset = v(24, 10)
tt.melee.attacks[2].instakill = true
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].mod = "mod_redcap_heal"
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[2])
tt.melee.attacks[3].chance = 0.1
tt.melee.attacks[3].damage_max = 100
tt.melee.attacks[3].damage_min = 100
tt.melee.attacks[3].fn_can = function(t, s, a, target)
	return band(target.vis.flags, F_HERO) ~= 0
end
tt.melee.attacks[3].instakill = nil
tt.melee.cooldown = 1.2
tt.motion.max_speed = 1.8 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.20833333333333334)
tt.render.sprites[1].prefix = "redcap"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = v(0, 10)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 12)
tt = E:register_t("enemy_satyr_cutthroat", "enemy")

E:add_comps(tt, "melee", "ranged")

tt.info.enc_icon = 12
tt.info.portrait = "portraits_sc_0025"
tt.enemy.gold = 15
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = {
	120,
	150,
	180,
	200
}
tt.health_bar.offset = v(0, 35)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 0.8
tt.melee.attacks[1].damage_max = 10
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].hit_time = fts(20)
tt.motion.max_speed = {
	2.2 * FPS,
	2.2 * FPS,
	2.2 * FPS,
	2.4 * FPS
}
tt.ranged.attacks[1].animations = {
	"shoot_start",
	"shoot_loop",
	"shoot_end"
}
tt.ranged.attacks[1].bullet = "knife_satyr"
tt.ranged.attacks[1].bullet_start_offset = {
	v(13, 15),
	v(13, 15)
}
tt.ranged.attacks[1].cooldown = {
	3,
	3,
	3,
	2.5
}
tt.ranged.attacks[1].loops = 1
tt.ranged.attacks[1].max_range = 90
tt.ranged.attacks[1].min_range = 10
tt.ranged.attacks[1].shoot_times = {
	fts(5),
	fts(15)
}
tt.render.sprites[1].anchor = v(0.5, 0.125)
tt.render.sprites[1].prefix = "satyr"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = v(0, 15)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 14)
tt = E:register_t("enemy_satyr_hoplite", "enemy")

E:add_comps(tt, "melee", "timed_attacks")

tt.info.enc_icon = 13
tt.info.portrait = "portraits_sc_0026"
tt.enemy.gold = 60
tt.enemy.melee_slot = v(32, 0)
tt.health.armor = {
	0.5,
	0.5,
	0.5,
	0.75
}
tt.health.hp_max = {
	450,
	600,
	700,
	1000
}
tt.health_bar.offset = v(0, 49)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_satyr_hoplite.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 35
tt.melee.attacks[1].damage_min = 25
tt.melee.attacks[1].hit_time = fts(24)
tt.motion.max_speed = 1.5 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.11666666666666667)
tt.render.sprites[1].prefix = "satyrHoplite"
tt.timed_attacks.list[1] = E:clone_c("spawn_attack")
tt.timed_attacks.list[1].entity = "satyr_hoplite_spawner"
tt.timed_attacks.list[1].animation = "cast"
tt.timed_attacks.list[1].spawn_time = fts(16)
tt.timed_attacks.list[1].cooldown = {
	8,
	8,
	8,
	6
}
tt.timed_attacks.list[1].count_group_name = "enemy_satyr_cutthroat_from_hoplite"
tt.timed_attacks.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_attacks.list[1].count_group_max = 12
tt.timed_attacks.list[1].nodes_limit = 60
tt.timed_attacks.list[1].sound = "ElvesCreepHoplite"
tt.sound_events.death = "DeathHuman"
tt.ui.click_rect = r(-25, 0, 50, 60)
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt = E:register_t("satyr_hoplite_spawner")

E:add_comps(tt, "pos", "spawner", "main_script")

tt.main_script.update = kr3_scripts.enemies_spawner.update
tt.spawner.count = 3
tt.spawner.random_cycle = {
	0,
	1
}
tt.spawner.entity = "enemy_satyr_cutthroat"
tt.spawner.random_node_offset_range = {
	-12,
	-7
}
tt.spawner.random_subpath = true
tt.spawner.initial_spawn_animation = "raise"
tt.spawner.check_node_valid = true
tt.spawner.use_node_pos = true
tt = E:register_t("enemy_twilight_avenger", "enemy")

E:add_comps(tt, "melee", "timed_attacks")

tt.info.enc_icon = 9
tt.info.portrait = "portraits_sc_0032"
tt.enemy.gold = 30
tt.enemy.melee_slot = v(30, 0)
tt.health.armor = 0.5
tt.health.hp_max = {
	900,
	1100,
	1300
}
tt.health_bar.offset = v(0, 47)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_twilight_avenger.update
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = {
	75,
	75,
	75,
	125
}
tt.melee.attacks[1].damage_min = {
	50,
	50,
	50,
	100
}
tt.melee.attacks[1].hit_time = fts(24)
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "cast"
tt.timed_attacks.list[1].cast_time = fts(16)
tt.timed_attacks.list[1].cooldown = 7
tt.timed_attacks.list[1].vis_bans = bor(F_BOSS, F_DARK_ELF)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_ENEMY)
tt.timed_attacks.list[1].max_range = 125
tt.timed_attacks.list[1].mod = "mod_twilight_avenger_last_service"
tt.timed_attacks.list[1].sound = "ElvesCreepAvenger"
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF)
tt.motion.max_speed = 1.1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[1].prefix = "twilight_avenger"
tt.sound_events.death = "DeathHuman"
tt.shield_extra_armor = 0.4
tt.shield_off_armor = tt.health.armor
tt.shield_on_armor = tt.health.armor + tt.shield_extra_armor
tt.ui.click_rect = r(-20, 0, 40, 40)
tt.unit.hit_offset = v(0, 22)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 23)
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt = E:register_t("enemy_twilight_scourger", "enemy")

E:add_comps(tt, "melee", "death_spawns", "timed_attacks")

tt.info.enc_icon = 11
tt.info.portrait = "portraits_sc_0027"
tt.death_spawns.name = "enemy_twilight_scourger_banshee"
tt.death_spawns.delay = fts(5)
tt.death_spawns.quantity = 1
tt.enemy.gold = 40
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = {
	360,
	400,
	550,
	650
}
tt.health.magic_armor = {
	0.8,
	0.8,
	0.8,
	0.9
}
tt.health_bar.offset = v(0, 37)
tt.health.dead_lifetime = 2.5
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_twilight_scourger.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 35
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(23)
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "special"
tt.timed_attacks.list[1].event_times = {
	fts(8),
	fts(14),
	fts(16),
	fts(24)
}
tt.timed_attacks.list[1].cooldown = {
	7,
	7,
	7,
	5
}
tt.timed_attacks.list[1].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[1].damage_min = 5
tt.timed_attacks.list[1].damage_max = 10
tt.timed_attacks.list[1].vis_bans = bor(F_BOSS)
tt.timed_attacks.list[1].excluded_templates = {
	"enemy_twilight_scourger",
	"enemy_twilight_scourger_banshee"
}
tt.timed_attacks.list[1].max_range = 75
tt.timed_attacks.list[1].max_cast_range = 50
tt.timed_attacks.list[1].mod = "mod_twilight_scourger_lash"
tt.timed_attacks.list[1].sound = "ElvesCreepScreecher"
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].loops = 3
tt.timed_attacks.list[1].cast_fx = "fx_twilight_scourger_lash"
tt.timed_attacks.list[1].cast_decal = "decal_twilight_scourger_lash"
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.14705882352941177)
tt.render.sprites[1].prefix = "scourger"
tt.sound_events.death = "ElvesScourgerDeath"
tt.unit.hit_offset = v(0, 20)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 18)
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt = E:register_t("enemy_twilight_scourger_banshee", "enemy")

E:add_comps(tt, "mod_attack", "tween")

tt.info.portrait = "portraits_sc_0028"
tt.mod_attack.cooldown = 1
tt.mod_attack.mod = "mod_twilight_scourger_banshee"
tt.mod_attack.max_range = 180
tt.mod_attack.excluded_templates = {
	"tower_baby_ashbite",
	"tower_black_baby_dragon"
}
tt.mod_attack.max_speed = 12 * FPS
tt.enemy.gold = 0
tt.enemy.lives_cost = 0
tt.enemy.melee_slot = v(29, 0)
tt.fade_nodes_to_defend_point = 25
tt.health.armor = 1
tt.health.hp_max = 90
tt.health.immune_to = DAMAGE_ALL_TYPES
tt.health_bar.offset = v(0, 42)
tt.health_bar.hidden = true
tt.main_script.update = kr3_scripts.enemy_twilight_scourger_banshee.update
tt.motion.max_speed = 6 * FPS
tt.particles_name = "ps_twilight_scourger_banshee"
tt.sound_events.death = nil
tt.render.sprites[1].anchor = v(0.5, 0.13043478260869565)
tt.render.sprites[1].prefix = "scourger_shadow"
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].animated = false
tt.unit.blood_color = BLOOD_NONE
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 18)
tt.vis.flags = 0
tt.vis.bans = band(F_ALL, bnot(bor(F_MOD, F_TELEPORT)))
tt.tween.disabled = true
tt.tween.remove = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		2,
		0
	}
}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt = E:register_t("enemy_webspitting_spider", "enemy")

E:add_comps(tt, "melee", "timed_attacks")

tt.info.enc_icon = 18
tt.info.portrait = "portraits_sc_0035"
tt.enemy.gold = 60
tt.enemy.melee_slot = v(36, 0)
tt.health.hp_max = {
	400,
	550,
	700
}
tt.health.magic_armor = 0.85
tt.health.poison_armor = 0.5
tt.health_bar.offset = v(0, 40)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 14
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(18)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_webspitting_spider.update
tt.motion.max_speed = 1.7 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.2714285714285714)
tt.render.sprites[1].prefix = "webspitting_spider"
tt.sound_events.death = "DeathEplosion"
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "spitWeb"
tt.timed_attacks.list[1].cast_time = fts(11)
tt.timed_attacks.list[1].cooldown = {
	6,
	6,
	6,
	4
}
tt.timed_attacks.list[1].mod = "mod_spider_web"
tt.timed_attacks.list[1].vis_flags = bor(F_NET, F_STUN)
tt.ui.click_rect = r(-20, 0, 40, 30)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 12)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_SKELETON)
tt = E:register_t("enemy_sword_spider", "enemy")

E:add_comps(tt, "melee")

tt.info.enc_icon = 10
tt.info.portrait = "portraits_sc_0007"
tt.enemy.gold = 16
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = {
	100,
	130,
	180,
	200
}
tt.health.magic_armor = {
	0.75,
	0.75,
	0.75,
	0.9
}
tt.health.poison_armor = 0.5
tt.health_bar.offset = v(0, 28)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].hit_time = fts(17)
tt.motion.max_speed = 1.7 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.13157894736842105)
tt.render.sprites[1].prefix = "sword_spider"
tt.sound_events.death = "DeathEplosion"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 12)
tt.vis.bans = bor(F_SKELETON)
tt = E:register_t("enemy_zealot", "enemy")

E:add_comps(tt, "melee", "tween")

tt.enemy.gold = 40
tt.enemy.lives_cost = 0
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = 0
tt.health_bar.offset = v(0, 36)
tt.info.portrait = "portraits_sc_0063"
tt.info.i18n_key = "ENEMY_BOSS_DROW_QUEEN_ZEALOT"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_zealot.update
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.078125)
tt.render.sprites[1].prefix = "zealot"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "zealot_glow_0001"
tt.render.sprites[2].anchor.y = 0.06666666666666667
tt.render.sprites[2].draw_order = 2
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "zealot_glow_0002"
tt.render.sprites[3].anchor.y = 0.06666666666666667
tt.render.sprites[3].draw_order = -2
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.3,
		0
	}
}
tt.tween.props[1].sprite_id = 2
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 3
tt.unit.hit_offset = v(0, 15)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.unit.show_blood_pool = false
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF)
tt = E:register_t("enemy_drider", "enemy")

E:add_comps(tt, "melee")

tt.info.portrait = "portraits_sc_0053"
tt.info.enc_icon = 20
tt.enemy.gold = 50
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = {
	400,
	500,
	600,
	700
}
tt.health_bar.offset = v(0, 47)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.motion.max_speed = 1.7 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.15517241379310345)
tt.render.sprites[1].prefix = "drider"
tt.sound_events.death = "DeathEplosion"
tt.ui.click_rect = r(-20, 0, 40, 35)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.show_blood_pool = false
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, 3)
tt.unit.mod_offset = v(0, 17)
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1 - fts(12)
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[2] = E:clone_c("melee_attack")
tt.melee.attacks[2].animation = "poison"
tt.melee.attacks[2].cooldown = {
	5,
	5,
	5,
	4
}
tt.melee.attacks[2].cooldown_inc = 5
tt.melee.attacks[2].hit_time = fts(15)
tt.melee.attacks[2].mod = "mod_drider_poison"
tt.generation = 0
tt = E:register_t("enemy_razorboar", "enemy")

E:add_comps(tt, "melee", "timed_attacks", "auras")

tt.info.enc_icon = 23
tt.info.portrait = "portraits_sc_0052"
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_razorboar_rage"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 75
tt.enemy.melee_slot = v(35, 0)
tt.health.armor = {
	0.6,
	0.6,
	0.6,
	0.75
}
tt.health.hp_max = {
	1000,
	1250,
	1500
}
tt.health_bar.offset = v(0, 47)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.motion.max_speed = 1.1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.15625)
tt.render.sprites[1].prefix = "razorboar"
tt.render.sprites[1].angles.run = {
	"runningRightLeft",
	"runningDown",
	"runningUp"
}
tt.render.sprites[1].angles_stickiness.run = 10
tt.sound_events.death = "DeathBig"
tt.ui.click_rect = r(-20, 0, 40, 30)
tt.unit.hit_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_SKELETON)
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_razorboar.update
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = {
	40,
	40,
	40,
	80
}
tt.melee.attacks[1].damage_min = {
	30,
	30,
	30,
	60
}
tt.melee.attacks[1].hit_time = fts(14)
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].nodes_limit = 35
tt.timed_attacks.list[1].vis_flags_enemies = bor(F_MOD, F_RANGED)
tt.timed_attacks.list[1].vis_bans_enemies = bor(F_FLYING, F_BOSS)
tt.timed_attacks.list[1].vis_flags_soldiers = bor(F_MOD, F_RANGED)
tt.timed_attacks.list[1].vis_bans_soldiers = bor(F_FLYING)
tt.timed_attacks.list[1].trigger_range = 50
tt.timed_attacks.list[1].range = 37.5
tt.timed_attacks.list[1].sound = "ElvesCreepRazorboarCharge"
tt.timed_attacks.list[1].duration = 1.2
tt.timed_attacks.list[1].mod_enemy = "mod_razorboar_rampage_enemy"
tt.timed_attacks.list[1].mod_soldier = "mod_razorboar_rampage_soldier"
tt.timed_attacks.list[1].mod_self = "mod_razorboar_rampage_speed"
tt.timed_attacks.list[1].particles_name = "ps_razorboar_rampage"
tt = E:register_t("enemy_arachnomancer", "enemy")

E:add_comps(tt, "melee", "timed_attacks", "death_spawns")

tt.info.portrait = "portraits_sc_0010"
tt.info.enc_icon = 22
tt.death_spawns.name = "bullet_arachnomancer_spawn"
tt.death_spawns.delay = fts(26)
tt.death_spawns.spread_nodes = 3
tt.death_spawns.offset = v(0, 6)
tt.death_spawns.quantity = 3
tt.enemy.gold = 110
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(22, 0)
tt.health.hp_max = {
	750,
	900,
	1100
}
tt.health_bar.offset = v(0, 33)
tt.motion.max_speed = 1.3 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.13636363636363635)
tt.render.sprites[1].prefix = "arachnomancer"
tt.sound_events.death = "DeathHuman"
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 16)
tt.unit.mod_offset = v(0, 15)
tt.unit.can_explode = false
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt.vis.bans = bor(tt.vis.bans, F_POLYMORPH)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_arachnomancer.update
tt.melee.attacks[1].cooldown = 1 - fts(23)
tt.melee.attacks[1].damage_max = 24
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].hit_time = fts(23)
tt.timed_attacks.list[1] = E:clone_c("spawn_attack")
tt.timed_attacks.list[1].entity = "arachnomancer_random_spawner"
tt.timed_attacks.list[1].animation = "summon"
tt.timed_attacks.list[1].spawn_time = fts(20)
tt.timed_attacks.list[1].cooldown = {
	7,
	7,
	7,
	5
}
tt.timed_attacks.list[1].nodes_limit = 40
tt.timed_attacks.list[1].spawn_sets = {
	{
		4,
		"decal_webspawn_enemy_spider_arachnomancer"
	},
	{
		3,
		"decal_webspawn_enemy_sword_spider"
	},
	{
		2,
		"decal_webspawn_enemy_spider_son_of_mactans"
	}
}
tt = E:register_t("arachnomancer_random_spawner")

E:add_comps(tt, "pos", "spawner", "main_script", "sound_events")

tt.main_script.update = kr3_scripts.enemies_spawner.update
tt.spawner.count = nil
tt.spawner.random_cycle = {
	0,
	fts(2)
}
tt.spawner.entity = nil
tt.spawner.random_node_offset_range = {
	-8,
	2
}
tt.spawner.random_subpath = true
tt.spawner.initial_spawn_animation = "idle"
tt.spawner.check_node_valid = true
tt.spawner.use_node_pos = true
tt.sound_events.insert = "ElvesCreepArachnomancerSpiderSpawn"
tt = E:register_t("enemy_spider_arachnomancer", "enemy")

E:add_comps(tt, "melee")

tt.enemy.gold = 15
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = {
	80,
	100,
	100
}
tt.health.magic_armor = 0.5
tt.health_bar.offset = v(0, 21)
tt.info.portrait = "portraits_sc_0054"
tt.info.i18n_key = "ENEMY_ARACHNOMANCER_SPIDER"
tt.info.enc_icon = 30
tt.motion.max_speed = 2.4 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.15625)
tt.render.sprites[1].prefix = "arachnomancer_spider"
tt.sound_events.death = "DeathEplosion"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 12)
tt.vis.bans = bor(tt.vis.bans, F_POISON, F_SKELETON)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 6
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].hit_time = fts(14)
tt = RT("spider_arachnomancer_egg_spawner", "decal_scripted")

AC(tt, "spawner", "sound_events", "tween", "editor")

tt.render.sprites[1].prefix = "spider_egg_spawner"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0.4
tt.spawner.entity = "enemy_spider_arachnomancer"
tt.spawner.eternal = true
tt.spawner.random_subpath = true
tt.spawner.cycle_time = fts(10)
tt.main_script.update = kr3_scripts.spider_arachnomancer_egg_spawner.update
tt.sound_events.open = "ElvesSpecialSpiderEggs"
tt.idle_range = {
	5,
	15
}
tt.spawn_time = fts(8)
tt.spawn_once = nil
tt.spawn_data = nil
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(10),
		0
	}
}
tt = E:register_t("enemy_spider_son_of_mactans", "enemy")

E:add_comps(tt, "melee")

tt.info.portrait = "portraits_sc_0031"
tt.info.enc_icon = 29
tt.enemy.gold = 35
tt.enemy.melee_slot = v(32, 0)
tt.health.hp_max = {
	240,
	325,
	375
}
tt.health.magic_armor = 0.9
tt.health_bar.offset = v(0, 32)
tt.info.i18n_key = "ENEMY_SON_OF_MACTANS"
tt.motion.max_speed = {
	2 * FPS,
	2 * FPS,
	2 * FPS,
	2.2 * FPS
}
tt.render.sprites[1].anchor = v(0.5, 0.12857142857142856)
tt.render.sprites[1].prefix = "son_of_mactans"
tt.sound_events.death = "DeathEplosion"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = v(0, 15)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].mod = "mod_son_of_mactans_poison"
tt.melee.attacks[2].cooldown = 6
tt = RT("spider_son_of_mactans_drop_spawner", "decal_scripted")

AC(tt, "nav_path", "motion", "spawner", "sound_events")

tt.spawn = "enemy_spider_son_of_mactans"
tt.main_script.update = kr3_scripts.spider_son_of_mactans_drop_spawner.update
tt.sound_events.insert = "ElvesCreepSonOfMactansLanding"
tt.render.sprites[1].prefix = "son_of_mactans"
tt.render.sprites[1].name = "netDescend"
tt.render.sprites[1].anchor.y = 0.12857142857142856
tt.render.sprites[1].z = Z_OBJECTS_SKY

for i = 1, math.ceil(REF_H / 18) do
	local s = E:clone_c("sprite")

	s.prefix = "son_of_mactans_thread_" .. (i % 2 == 0 and "1" or "2")
	s.name = "idle"
	s.loop = false
	s.anchor.y = 0
	s.offset.y = (i - 1) * 18 + 40
	s.z = Z_OBJECTS_SKY - 1
	tt.render.sprites[i + 1] = s
end

tt = RT("enemy_mactans", "decal_scripted")

AC(tt, "ui", "tween", "editor")

tt.render.sprites[1].prefix = "mactans"
tt.render.sprites[1].name = "falling"
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].z = Z_OBJECTS_SKY + 1
tt.drop_duration = 2
tt.retreat_duration = 1.5
tt.netting_duration = 2.6
tt.main_script.update = kr3_scripts.enemy_mactans.update
tt.ui.can_select = false
tt.ui.can_click = true
tt.ui.click_rect = r(-40, 30, 80, 80)
tt.ui.z = 1
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		0,
		vv(0)
	},
	{
		fts(2),
		v(0, 7)
	},
	{
		fts(4),
		v(0, 2)
	},
	{
		fts(6),
		v(0, 1)
	},
	{
		fts(8),
		v(0, -3)
	},
	{
		fts(10),
		v(0, -8)
	},
	{
		fts(12),
		v(0, -2)
	},
	{
		fts(14),
		v(0, 3)
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "r"
tt.tween.props[2].keys = {
	{
		0,
		0
	},
	{
		fts(2),
		d2r(-6)
	},
	{
		fts(4),
		d2r(-1)
	},
	{
		fts(6),
		d2r(3)
	},
	{
		fts(8),
		d2r(5)
	},
	{
		fts(10),
		d2r(0)
	},
	{
		fts(12),
		d2r(0)
	},
	{
		fts(14),
		d2r(0)
	}
}
tt.editor.overrides = {
	["render.sprites[1].name"] = "retreat"
}
tt = RT("enemy_perython_rock_thrower", "enemy_perython")

AC(tt, "death_spawns")

tt.info.i18n_key = "ENEMY_PERYTHON"
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "perython_rock"
tt.render.sprites[3].name = "flySide"
tt.render.sprites[3].anchor = v(0.5, 0.5)
tt.render.sprites[3].offset.y = 10
tt.death_spawns.name = "rock_perython"
tt.death_spawns.concurrent_with_death = true
tt.main_script.update = kr3_scripts.enemy_perython_carrier.update
tt.spawn_trigger_range = 50
tt.drop_delay = {
	0.5,
	0.9
}
tt = RT("enemy_ogre_magi", "enemy")

AC(tt, "ranged", "auras")

tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_ogre_magi_shield"
tt.auras.list[1].cooldown = 0
tt.auras.list[2] = CC("aura_attack")
tt.auras.list[2].name = "aura_ogre_magi_regen"
tt.auras.list[2].cooldown = 0
tt.info.enc_icon = 36
tt.info.portrait = "portraits_sc_0050"
tt.enemy.gold = 100
tt.enemy.lives_cost = {
	2,
	2,
	2,
	3
}
tt.enemy.melee_slot = v(38, 0)
tt.health.hp_max = {
	1500,
	2000,
	2500
}
tt.health.magic_armor = {
	0.75,
	0.75,
	0.75,
	0.8
}
tt.health_bar.offset = v(0, 63)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_ogre_magi.update
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].damage_max = 72
tt.ranged.attacks[1].damage_min = 48
tt.ranged.attacks[1].shoot_time = fts(17)
tt.ranged.attacks[1].bullet = "bolt_ogre_magi"
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].bullet_start_offset = {
	v(-25, 53)
}
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.17777777777777778)
tt.render.sprites[1].prefix = "ogre_mage"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect = r(-20, 0, 40, 45)
tt.unit.hit_offset = v(0, 27)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 25)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt = RT("enemy_ogre_magi_custody_ettin", "enemy_ettin")
tt.motion.max_speed = 1 * FPS
tt.info.i18n_key = "ENEMY_ETTIN"
tt = RT("enemy_ogre_magi_custody_gnoll_gnawer", "enemy_gnoll_gnawer")
tt.motion.max_speed = 1 * FPS
tt.info.i18n_key = "ENEMY_GNOLL_GNAWER"
tt = RT("enemy_ogre_magi_custody_warlock", "enemy_bloodsydian_warlock")
tt.motion.max_speed = 1 * FPS
tt.info.i18n_key = "ENEMY_BLOODSYDIAN_WARLOCK"
tt = RT("enemy_blood_servant", "enemy")

E:add_comps(tt, "melee")

tt.enemy.gold = 20
tt.enemy.melee_slot = v(30, 0)
tt.health.hp_max = {
	100,
	200,
	300
}
tt.health_bar.offset = v(0, 30)
tt.info.enc_icon = 39
tt.info.portrait = "portraits_sc_0073"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {
	24,
	24,
	24,
	30
}
tt.melee.attacks[1].damage_min = {
	16,
	16,
	16,
	20
}
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 2.7 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.14285714285714285)
tt.render.sprites[1].prefix = "bloodServant"
tt.sound_events.death = "ElvesCreepServantDeath"
tt.unit.hit_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 14)
tt = RT("enemy_mounted_avenger", "enemy")

E:add_comps(tt, "melee", "death_spawns")

tt.death_spawns.name = "enemy_twilight_avenger"
tt.death_spawns.delay = fts(21)
tt.death_spawns.no_spawn_damage_types = bor(DAMAGE_INSTAKILL)
tt.death_spawns.offset = v(0, 7)
tt.enemy.gold = 60
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(35, 0)
tt.health.hp_max = {
	1000,
	1200,
	1400
}
tt.health.magic_armor = {
	0.5,
	0.5,
	0.5,
	0.7
}
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 65)
tt.info.enc_icon = 40
tt.info.portrait = "portraits_sc_0074"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {
	90,
	90,
	90,
	110
}
tt.melee.attacks[1].damage_min = {
	60,
	60,
	60,
	70
}
tt.melee.attacks[1].hit_time = fts(19)
tt.motion.max_speed = 1.7 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.1875)
tt.render.sprites[1].prefix = "mountedAvenger"
tt.ui.click_rect = r(-20, 0, 40, 50)
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 21)
tt.unit.marker_offset = v(0, -2)
tt.unit.mod_offset = v(0, 27)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF)
tt.sound_events.death = "ElvesCreepMountedAvengerDeath"
tt.sound_events.death_args = {
	delay = fts(15)
}
tt = RT("enemy_dark_spitters", "enemy")

AC(tt, "melee", "ranged")

tt.enemy.gold = 70
tt.enemy.melee_slot = v(27, 0)
tt.health.armor = {
	0.5,
	0.5,
	0.5,
	0.8
}
tt.health.hp_max = {
	600,
	800,
	1000,
	1100
}
tt.health_bar.offset = v(0, 53)
tt.info.enc_icon = 45
tt.info.portrait = "portraits_sc_0080"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 36
tt.melee.attacks[1].damage_min = 24
tt.melee.attacks[1].hit_time = fts(17)
tt.motion.max_speed = 1 * FPS
tt.ranged.attacks[1].bullet = "bullet_dark_spitters"
tt.ranged.attacks[1].bullet_start_offset = {
	v(8, 36)
}
tt.ranged.attacks[1].cooldown = 1.5 + fts(19)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].shoot_time = fts(11)
tt.ranged.attacks[1].vis_flags = bor(F_RANGED, F_BURN)
tt.render.sprites[1].anchor = v(0.5, 0.12857142857142856)
tt.render.sprites[1].prefix = "dark_spitters"
tt.sound_events.death = "ElvesDarkSpitterDeath"
tt.ui.click_rect = r(-15, 0, 30, 40)
tt.unit.blood_color = BLOOD_ORANGE
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt = RT("enemy_shadows_spawns", "enemy")

AC(tt, "melee")

tt.enemy.gold = 20
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = {
	200,
	350,
	450,
	500
}
tt.health_bar.offset = v(0, 34)
tt.info.enc_icon = 44
tt.info.portrait = "portraits_sc_0079"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 24
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].hit_time = fts(17)
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.29411764705882354)
tt.render.sprites[1].prefix = "shadow_spawn"
tt.sound_events.death = "ElvesShadowSpawnDeath"
tt.sound_events.raise = "ElvesShadowSpawnSpawn"
tt.sound_events.raise_args = {
	delay = fts(2)
}
tt.unit.blood_color = BLOOD_ORANGE
tt.unit.hit_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt = RT("enemy_grim_devourers", "enemy")

AC(tt, "melee")

tt.cannibalize = {}
tt.cannibalize.extra_hp = 50
tt.cannibalize.cycles = 26
tt.cannibalize.hp_per_cycle = 2
tt.enemy.gold = 40
tt.enemy.melee_slot = v(23, 0)
tt.health.armor = {
	0.3,
	0.3,
	0.3,
	0.6
}
tt.health.hp_max = {
	500,
	600,
	700
}
tt.health_bar.offset = v(0, 42)
tt.info.enc_icon = 46
tt.info.portrait = "portraits_sc_0081"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_grim_devourers.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {
	48,
	48,
	48,
	55
}
tt.melee.attacks[1].damage_min = {
	32,
	32,
	32,
	40
}
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.5 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.14705882352941177)
tt.render.sprites[1].prefix = "grim_devourers"
tt.sound_events.death = "ElvesGrimDevourerDeath"
tt.sound_events.cannibalize = "ElvesGrimDevourerConsume"
tt.unit.blood_color = BLOOD_ORANGE
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt = RT("enemy_shadow_champion", "enemy")

AC(tt, "melee", "death_spawns")

tt.death_spawns.name = "aura_shadow_champion_death"
tt.death_spawns.delay = fts(26)
tt.death_spawns.no_spawn_damage_types = bor(DAMAGE_EXPLOSION, DAMAGE_FX_EXPLODE)
tt.enemy.gold = 140
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(40, 0)
tt.health.armor = 0.9
tt.health.hp_max = {
	2200,
	2500,
	2800,
	3000
}
tt.health_bar.offset = v(0, 55)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.enc_icon = 47
tt.info.portrait = "portraits_sc_0082"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 50
tt.melee.attacks[1].damage_max = 96
tt.melee.attacks[1].damage_min = 64
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].hit_offset = v(40, 0)
tt.melee.attacks[1].sound_hit = "ElvesShadowChampionAttack"
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.203125)
tt.render.sprites[1].prefix = "shadow_champion"
tt.sound_events.death = "ElvesShadowChampionDeath"
tt.ui.click_rect = r(-20, 0, 40, 45)
tt.unit.blood_color = BLOOD_ORANGE
tt.unit.hit_offset = v(0, 27)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 27)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = F_INSTAKILL
tt = RT("enemy_gnoll_warleader", "enemy")

AC(tt, "melee", "death_spawns")

tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "fx_coin_shower"
tt.death_spawns.offset = v(0, 60)
tt.enemy.gold = 250
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(43, 0)
tt.health.hp_max = 2500
tt.health_bar.offset = v(0, 65)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.enc_icon = 34
tt.info.i18n_key = "ENEMY_ENDLESS_MINIBOSS_GNOLL"
tt.info.portrait = "portraits_sc_0069"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 80
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_offset = v(43, 0)
tt.melee.attacks[1].sound_hit = "EndlessWarleaderDoubleSword"
tt.melee.attacks[1].hit_time = fts(11)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.2222222222222222)
tt.render.sprites[1].prefix = "enemy_gnoll_warleader"
tt.sound_events.death = "EndlessWarleaderDeath"
tt.unit.hit_offset = v(0, 27)
tt.unit.mod_offset = v(0, 25)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_TELEPORT, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt = RT("enemy_twilight_brute", "enemy")

AC(tt, "melee", "auras", "death_spawns")

tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_twilight_brute"
tt.auras.list[1].cooldown = 0
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "fx_coin_shower"
tt.death_spawns.offset = v(0, 60)
tt.enemy.gold = 250
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(43, 0)
tt.health.hp_max = 2500
tt.health_bar.offset = v(0, 65)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.enc_icon = 43
tt.info.i18n_key = "ENEMY_ENDLESS_MINIBOSS_TWILIGHT"
tt.info.portrait = "portraits_sc_0077"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mixed.update
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 80
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_offset = v(43, 3)
tt.melee.attacks[1].hit_time = fts(11)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.1875)
tt.render.sprites[1].prefix = "enemy_twilight_bannerbearer"
tt.sound_events.death = "EndlessBruteDeath"
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 25)
tt.unit.mod_offset = v(0, 25)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_TELEPORT, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt = E:register_t("eb_gnoll", "boss")

E:add_comps(tt, "melee", "timed_attacks", "auras")

tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "gnoll_boss_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 1
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.armor = 0.6
tt.health.dead_lifetime = 100
tt.health.hp_max = {
	5000,
	7000,
	8000,
	12000
}
tt.health_bar.offset = v(0, 100)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.enc_icon = 26
tt.info.i18n_key = "ENEMY_BOSS_GNOLL"
tt.info.portrait = "portraits_sc_0013"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.eb_gnoll.update
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.2948717948717949)
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.render.sprites[1].prefix = "eb_gnoll"
tt.sound_events.death = "ElvesHyenaDeath"
tt.ui.click_rect = r(-35, 0, 70, 80)
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 50)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 40)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_SKELETON, F_POLYMORPH)
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = 90
tt.melee.attacks[1].damage_min = 70
tt.melee.attacks[1].hit_time = fts(22)
tt.melee.attacks[1].uninterruptible = true
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].cooldown = {
	7,
	7,
	7,
	5
}
tt.timed_attacks.list[1].hit_time = fts(55)
tt.timed_attacks.list[1].animation = "specialAttack"
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 9e+99
tt.timed_attacks.list[1].damage_max = {
	180,
	180,
	180,
	1000
}
tt.timed_attacks.list[1].damage_min = 150
tt.timed_attacks.list[1].damage_max_hero = 120
tt.timed_attacks.list[1].damage_min_hero = 100
tt.timed_attacks.list[1].damage_type = bor(DAMAGE_PHYSICAL, DAMAGE_NO_DODGE)
tt.timed_attacks.list[1].sound = "ElvesHyenaStomp"
tt.timed_attacks.list[2] = E:clone_c("custom_attack")
tt.timed_attacks.list[2].animation = "scream"
tt.timed_attacks.list[2].nis = {
	85,
	135,
	180
}
tt.timed_attacks.list[2].wave_names = {
	"Boss_Path_1",
	"Boss_Path_2",
	"Boss_Path_3",
	"Boss_Path_4"
}
tt.timed_attacks.list[2].hit_time = fts(8)
tt.timed_attacks.list[2].sound = "ElvesHyenaGrowl"
tt = E:register_t("gnoll_boss_aura", "aura")

E:add_comps(tt, "render", "tween")

tt.aura.cycle_time = fts(5)
tt.aura.duration = -1
tt.aura.filter_source = true
tt.aura.mod = "mod_gnoll_boss"
tt.aura.radius = 150
tt.aura.track_source = true
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = F_MOD
tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt.render.sprites[1].name = "bossHiena_aura_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "bossHiena_aura_ring"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		102
	},
	{
		fts(9),
		173
	},
	{
		fts(21),
		20
	},
	{
		fts(30),
		20
	}
}
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].loop = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		v(0.65, 0.65)
	},
	{
		fts(30),
		v(1.57, 1.57)
	}
}
tt.tween.props[2].name = "scale"
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].loop = true
tt = E:register_t("mod_gnoll_boss", "modifier")

E:add_comps(tt, "render")

tt.render.sprites[1].name = "bossHiena_creepFx"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.main_script.insert = kr3_scripts.mod_gnoll_boss.insert
tt.main_script.remove = kr3_scripts.mod_gnoll_boss.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.modifier.duration = fts(6)
tt.modifier.use_mod_offset = false
tt.extra_health_factor = 0.5
tt.inflicted_damage_factor = 1.5
tt = E:register_t("eb_drow_queen", "boss")

E:add_comps(tt, "melee", "taunts", "tween")

tt.info.enc_icon = 27
tt.info.i18n_key = "ENEMY_BOSS_DROW_QUEEN"
tt.info.portrait = "portraits_sc_0062"
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = {
	6000,
	9000,
	11000
}
tt.health.hp_max_rounds = {
	{
		6000,
		4000,
		2000
	},
	{
		9000,
		6000,
		3000
	},
	{
		11000,
		7500,
		4000
	},
	{
		11000,
		7500,
		4000
	}
}
tt.health.on_damage = kr3_scripts.eb_drow_queen.on_damage
tt.health.dead_lifetime = 100
tt.health_bar.hidden = true
tt.health_bar.offset = v(0, 49)
tt.health_bar.sort_y_offset = -2
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.update = kr3_scripts.eb_drow_queen.update
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_radius = 30
tt.melee.attacks[1].damage_max = {
	120,
	120,
	120,
	500
}
tt.melee.attacks[1].damage_min = 120
tt.melee.attacks[1].damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_DODGE)
tt.melee.attacks[1].hit_offset = v(29, 0)
tt.melee.attacks[1].hit_time = fts(24)
tt.melee.attacks[1].uninterruptible = true
tt.motion.max_speed = 1.1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.15384615384615385)
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[1].prefix = "s11_malicia"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "malicia_glow_0001"
tt.render.sprites[2].anchor.y = 0.058823529411764705
tt.render.sprites[2].draw_order = 2
tt.render.sprites[2].alpha = 0
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "malicia_glow_0002"
tt.render.sprites[3].anchor.y = 0.058823529411764705
tt.render.sprites[3].draw_order = -2
tt.render.sprites[3].alpha = 0
tt.sound_events.death = "ElvesMaliciaDeath"
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(16),
		0
	}
}
tt.tween.props[1].disabled = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		255
	},
	{
		0.3,
		0
	}
}
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[2])
tt.tween.props[3].sprite_id = 3
tt.ui.click_rect = r(-20, 0, 40, 50)
tt.ui.click_rect_default = r(-20, 0, 40, 50)
tt.ui.click_rect_sitting = r(20, 0, 40, 50)
tt.unit.hit_offset = v(0, 17)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 17)
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF)
tt.vis.bans = bor(F_BLOCK, F_RANGED, F_MOD, F_TELEPORT)
tt.fly_speed_normal = 5 * FPS
tt.fly_speed_fight = 3 * FPS
tt.fly_speed_return = 7 * FPS
tt.fly_speed_return_die = 9 * FPS
tt.fly_loop_time = 7 / FPS
tt.fly_offset_y = 26
tt.pos_fighting = v(347, 396)
tt.pos_casting = v(684, 404)
tt.pos_sitting = v(924, 416)
tt.tower_block_sets = {
	{
		"12",
		"13",
		"14"
	},
	{
		"12",
		"13",
		"14",
		"6"
	},
	{
		"12",
		"13",
		"14",
		"6",
		"9",
		"5"
	}
}
tt.power_block_duration = {
	8,
	8,
	8,
	15
}
tt.taunts.delay_min = 15
tt.taunts.delay_max = 20
tt.taunts.duration = 4
tt.taunts.sets = {
	welcome = {},
	prebattle = {},
	casting = {},
	sitting = {}
}
tt.taunts.sets.welcome.format = "ELVES_ENEMY_DROW_QUEEN_TAUNT_KIND_WELCOME_%04d"
tt.taunts.sets.welcome.start_idx = 1
tt.taunts.sets.welcome.end_idx = 2
tt.taunts.sets.prebattle.format = "ELVES_ENEMY_DROW_QUEEN_TAUNT_KIND_PREBATTLE_%04d"
tt.taunts.sets.prebattle.start_idx = 1
tt.taunts.sets.prebattle.end_idx = 3
tt.taunts.sets.casting.format = "ELVES_ENEMY_DROW_QUEEN_TAUNT_KIND_CASTING_%04d"
tt.taunts.sets.casting.start_idx = 1
tt.taunts.sets.casting.end_idx = 4
tt.taunts.sets.casting.pos = v(791, 348)
tt.taunts.sets.casting.decal_name = "decal_drow_queen_shoutbox_casting"
tt.taunts.sets.sitting.format = "ELVES_ENEMY_DROW_QUEEN_TAUNT_KIND_SITTING_%04d"
tt.taunts.sets.sitting.start_idx = 1
tt.taunts.sets.sitting.end_idx = 5
tt.taunts.decal_name = "decal_drow_queen_shoutbox"
tt.taunts.offset = v(0, 0)
tt.taunts.pos = v(870, 376)
tt = E:register_t("decal_drow_queen_shoutbox", "decal_tween")

E:add_comps(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "malicia_taunt_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "malicia_taunt_0002"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].z = Z_BULLETS
tt.render.sprites[3].offset = v(0, 1)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(180, 58)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = 20
tt.texts.list[1].color = {
	233,
	189,
	255
}
tt.texts.list[1].line_height = i18n:cjk(0.8, 0.9, 1.1, 0.7)
tt.texts.list[1].sprite_id = 3
tt.texts.list[1].fit_height = true
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.25,
		255
	},
	{
		"this.duration-0.25",
		255
	},
	{
		"this.duration",
		0
	}
}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {
	{
		0,
		v(1.01, 1.01)
	},
	{
		0.4,
		v(0.99, 0.99)
	},
	{
		0.8,
		v(1.01, 1.01)
	}
}
tt.tween.props[4].sprite_id = 1
tt.tween.props[4].loop = true
tt.tween.props[5] = table.deepclone(tt.tween.props[4])
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[4])
tt.tween.props[6].sprite_id = 3
tt.tween.remove = true
tt = E:register_t("decal_drow_queen_shoutbox_casting", "decal_drow_queen_shoutbox")
tt.render.sprites[2].name = "malicia_taunt_0003"
tt = E:register_t("decal_drow_queen_flying", "decal")
tt.render.sprites[1].name = "s11_malicia_teleportLoop"
tt.render.sprites[1].anchor.y = 0.35384615384615387
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = -24
tt = E:register_t("decal_drow_queen_shield", "decal_scripted")

E:add_comps(tt, "tween", "health_bar", "health")

tt.health.hp = 0
tt.health_bar.hidden = true
tt.health_bar.offset = v(0, 52)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.colors = {}
tt.health_bar.colors.fg = {
	255,
	65,
	240,
	255
}
tt.health_bar.colors.bg = {
	51,
	18,
	53,
	255
}
tt.health_bar.sort_y_offset = -2
tt.health.ignore_damage = true
tt.main_script.update = kr3_scripts.decal_drow_queen_shield.update
tt.render.sprites[1].name = "s11_malicia_shield_idle"
tt.render.sprites[1].anchor.y = 0.15384615384615385
tt.render.sprites[1].offset = v(-5, 0)
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].sort_y_offset = -1
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		vv(1)
	},
	{
		fts(10),
		vv(1.1)
	},
	{
		fts(20),
		vv(1)
	}
}
tt.tween.props[1].loop = true
tt.tween.props[1].ignore_reverse = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		0
	},
	{
		fts(11),
		153
	}
}
tt.shield_hp = 0
tt = E:register_t("fx_drow_queen_shield_break", "fx")

E:add_comps(tt, "sound_events")

tt.render.sprites[1].name = "s11_malicia_shield_break"
tt.render.sprites[1].anchor.y = 0.15384615384615385
tt.render.sprites[1].offset.x = -5
tt.sound_events.insert = "ElvesMaliciaShieldBreak"
tt = E:register_t("fx_drow_queen_cast", "fx")
tt.render.sprites[1].name = "s11_malicia_castFx"
tt.render.sprites[1].anchor.y = 0.15384615384615385
tt = E:register_t("mod_drow_queen_tower_block", "modifier")

E:add_comps(tt, "render", "tween")

tt.main_script.update = kr3_scripts.mod_tower_block.update
tt.modifier.duration = 8
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].name = "start"
tt.render.sprites[1].prefix = "malicia_tower_block"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "malicia_towerNet_decal"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(8),
		204
	},
	{
		fts(16),
		255
	}
}
tt.tween.props[1].loop = true
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		vv(1)
	},
	{
		fts(8),
		vv(1.015)
	},
	{
		fts(16),
		vv(1)
	}
}
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 2
tt.tween.props[4] = table.deepclone(tt.tween.props[2])
tt.tween.props[4].sprite_id = 2
tt = RT("eb_spider", "boss")

AC(tt, "ranged", "timed_attacks", "taunts")

tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(53, 0)
tt.health.dead_lifetime = 100
tt.health.hp_max = {
	12000,
	15000,
	18000
}
tt.health.hp_max_rounds = {
	{
		12000,
		9000,
		6000,
		3000
	},
	{
		15000,
		11000,
		7000,
		3000
	},
	{
		18000,
		14000,
		10000,
		6000
	},
	{
		18000,
		14000,
		10000,
		6000
	}
}
tt.health.magic_armor = 0.5
tt.health_bar.offset = v(0, 106)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.enc_icon = 33
tt.info.portrait = "portraits_sc_0067"
tt.info.i18n_key = "ENEMY_BOSS_SPIDER"
tt.info.fn = kr3_scripts.eb_spider.get_info
tt.main_script.update = kr3_scripts.eb_spider.update
tt.motion.max_speed = 1 * FPS

for i = 1, 6 do
	local s = E:clone_c("sprite")

	s.prefix = "eb_spider_layer" .. i
	s.name = "idle"
	s.anchor.y = 0.3
	s.angles = {}
	s.angles.walk = {
		"walkingRightLeft",
		"walkingDown",
		"walkingDown"
	}
	tt.render.sprites[i] = s
end

tt.sound_events.death = "ElvesFinalBossDeath"
tt.ui.click_rect = r(-40, 0, 80, 80)
tt.unit.hit_offset = v(0, 38)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 38)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF)
tt.vis.bans = bor(tt.vis.bans, F_STUN)
tt.taunts.decal_name = "decal_eb_spider_shoutbox"
tt.taunts.duration = 2
tt.taunts.offset = v(130, 120)
tt.taunts.sets = {
	intro = CC("taunt_set"),
	death = CC("taunt_set")
}
tt.taunts.sets.intro.format = "ELVES_ENEMY_QUEEN_TAUNT_KIND_OURS"
tt.taunts.sets.death.format = "ENEMY_BOSS_SPIDER_DEATH_TAUNT"
tt.ranged.attacks[1].bullet = "ray_eb_spider"
tt.ranged.attacks[1].cooldown = 0.5 + fts(29)
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].bullet_start_offset = {
	v(24, 101)
}
tt.ranged.attacks[1].ignore_hit_offset = true
tt.timed_attacks.list[1] = table.deepclone(tt.ranged.attacks[1])
tt.timed_attacks.list[1].cooldown = {
	7,
	7,
	7,
	6
}
tt.timed_attacks.list[1].min_range = 30
tt.timed_attacks.list[1].max_range = 225
tt.timed_attacks.list[1].shoot_time = fts(13)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].cooldown = {
	8,
	8,
	8,
	7
}
tt.timed_attacks.list[2].animation = "blockTower"
tt.timed_attacks.list[2].hit_time = fts(13)
tt.timed_attacks.list[2].power_block_duration = 5
tt.timed_attacks.list[2].hit_sound = "ElvesFinalBossCastSpell"
tt.timed_attacks.list[2].tower_count = {
	1,
	2,
	3,
	3
}
tt.timed_attacks.list[2].mod = "mod_eb_spider_tower_block"
tt.timed_attacks.list[3] = CC("bullet_attack")
tt.timed_attacks.list[3].bullet = "ray_eb_spider_tower"
tt.timed_attacks.list[3].max_range = 200
tt.timed_attacks.list[3].excluded_templates = {
	"tower_drow"
}
tt.timed_attacks.list[3].shoot_time = fts(8)
tt.timed_attacks.list[3].animations = {
	"shootTower_start",
	"shootTower_loop",
	"shootTower_end"
}
tt.timed_attacks.list[3].sound = "ElvesFinalBossSpiderSuperrayCharge"
tt.timed_attacks.list[3].bullet_start_offset = {
	v(19, 42)
}
tt = RT("ray_eb_spider", "bullet")
tt.bullet.damage_max = 120
tt.bullet.damage_min = 80
tt.bullet.damage_radius = 45
tt.bullet.damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_DODGE)
tt.bullet.hit_fx = "fx_ray_eb_spider_explosion"
tt.bullet.hit_time = fts(5)
tt.bullet.ignore_hit_offset = true
tt.bullet.vis_bans = bor(F_ENEMY)
tt.image_width = 248
tt.main_script.update = kr3_scripts.ray_enemy.update
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "ray_eb_spider"
tt.sound_events.insert = "ElvesFinalBosskillray"
tt = RT("ray_eb_spider_tower", "ray_eb_spider")
tt.bullet.damage_radius = 0
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_fx = nil
tt.bullet.mod = "mod_eb_spider_tower_remove"
tt.image_width = 230
tt.render.sprites[1].name = "ray_eb_spider_tower"
tt.sound_events.insert = "ElvesFinalBossSpiderSuperrayDischarge"
tt = RT("mod_eb_spider_tower_block", "mod_drow_queen_tower_block")
tt.modifier.duration = 5
tt.render.sprites[1].prefix = "eb_spider_tower_block"
tt.render.sprites[2].name = "spiderQueen_towerNet_decal"
tt = RT("mod_eb_spider_tower_remove", "modifier")

AC(tt, "render", "tween")

tt.main_script.update = kr3_scripts.mod_tower_remove.update
tt.modifier.hide_time = fts(27)
tt.render.sprites[1].name = "mod_eb_spider_tower_remove_explosion"
tt.render.sprites[1].anchor.y = 0.375
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "spiderQueen_towerExplosion_ring"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		fts(23),
		0
	},
	{
		fts(24),
		255
	},
	{
		fts(28),
		255
	},
	{
		fts(35),
		0
	}
}
tt.tween.props[1].sprite_id = 2
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		fts(24),
		vv(0.24)
	},
	{
		fts(28),
		vv(1)
	},
	{
		fts(35),
		vv(1.2)
	}
}
tt.tween.props[2].sprite_id = 2
tt = RT("fx_ray_eb_spider_explosion", "fx")
tt.render.sprites[1].name = "fx_ray_eb_spider_explosion"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_ray_eb_spider_decal"
tt.render.sprites[2].loop = false
tt.render.sprites[2].z = Z_DECALS
tt = RT("fx_eb_spider_spawn", "decal_tween")
tt.render.sprites[1].name = "fx_eb_spider_spawn"
tt.render.sprites[1].offset.y = 43
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		fts(0),
		255
	},
	{
		fts(5),
		0
	}
}
tt = RT("fx_eb_spider_jump_smoke", "fx")
tt.render.sprites[1].name = "fx_eb_spider_jump_smoke"
tt.render.sprites[1].anchor.y = 0.12
tt = RT("decal_shadow_eb_spider", "decal_tween")
tt.render.sprites[1].name = "spiderQueen_shadow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.31153846153846154
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.55,
		255
	},
	{
		0.6,
		255
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		vv(0)
	},
	{
		0.55,
		vv(1)
	},
	{
		0.6,
		vv(1)
	}
}
tt.tween.props[2].name = "scale"
tt = RT("decal_eb_spider_death_second_rays", "decal_tween")
tt.tween.remove = false

local angles = {
	32,
	-48,
	118,
	-128
}

for i = 1, 4 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].name = "spiderQueen_deathShapes_0001"
	tt.render.sprites[i].animated = false
	tt.render.sprites[i].r = d2r(angles[i])
	tt.render.sprites[i].z = Z_OBJECTS + 1

	local d = (i - 1) * 9 + (i == 4 and 2 or 0)

	tt.tween.props[2 * i - 1] = CC("tween_prop")
	tt.tween.props[2 * i - 1].name = "scale"
	tt.tween.props[2 * i - 1].keys = {
		{
			fts(0),
			v(1, 1.25)
		},
		{
			fts(2),
			vv(0.75)
		},
		{
			fts(4),
			v(1, 1.25)
		}
	}
	tt.tween.props[2 * i - 1].sprite_id = i
	tt.tween.props[2 * i - 1].time_offset = fts(i - 1)
	tt.tween.props[2 * i - 1].loop = true
	tt.tween.props[2 * i] = CC("tween_prop")
	tt.tween.props[2 * i].name = "scale"
	tt.tween.props[2 * i].keys = {
		{
			fts(d),
			vv(0)
		},
		{
			fts(d + 2),
			vv(0.4)
		},
		{
			fts(d + 3),
			vv(1)
		}
	}
	tt.tween.props[2 * i].sprite_id = i
	tt.tween.props[2 * i].multiply = true
end

tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].name = "spiderQueen_deathShapes_0002"
tt.render.sprites[5].animated = false
tt.render.sprites[5].z = Z_OBJECTS + 1
tt.tween.props[9] = CC("tween_prop")
tt.tween.props[9].name = "scale"
tt.tween.props[9].keys = {
	{
		0,
		vv(0.8)
	},
	{
		fts(2),
		vv(1)
	},
	{
		fts(4),
		vv(0.8)
	}
}
tt.tween.props[9].loop = true
tt.tween.props[9].sprite_id = 5
tt = RT("decal_eb_spider_death_white_circle", "decal_tween")
tt.render.sprites[1].name = "spiderQueen_deathShapes_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_GUI - 2
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		vv(1.5)
	},
	{
		fts(7),
		vv(70)
	}
}
tt = RT("decal_eb_spider_shoutbox", "decal_drow_queen_shoutbox")
tt.render.sprites[1].name = "stage15_taunts_0001"
tt.render.sprites[2].name = "stage15_taunts_0003"
tt.render.sprites[3].offset = v(13, -13)
tt.texts.list[1].font_size = i18n:cjk(28, nil, 22, nil)
tt.texts.list[1].size = v(158, 56)
tt.texts.list[1].fit_height = true
tt = RT("eb_bram", "boss")

AC(tt, "melee", "timed_attacks", "taunts")

tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.dead_lifetime = 100
tt.health.hp_max = {
	7500,
	10000,
	13000,
	16000
}
tt.health_bar.offset = v(0, 98)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.hidden = true
tt.info.enc_icon = 38
tt.info.portrait = "portraits_sc_0072"
tt.info.i18n_key = "ENEMY_BOSS_BRAM"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.eb_bram.update
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.24691358024691357)
tt.render.sprites[1].prefix = "eb_bram"
tt.render.sprites[1].name = "sitting"
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingDown",
	"walkingDown"
}
tt.render.sprites[1].angles_custom = {
	walk = {
		45,
		120,
		240,
		315
	}
}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.sound_events.death = "ElvesBossBramDeath"
tt.unit.click_rect = r(-35, 0, 70, 65)
tt.unit.hit_offset = v(0, 50)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 45)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.flags = bor(tt.vis.flags)
tt.vis.bans = bor(F_SKELETON, F_POLYMORPH)
tt.pos_sitting = v(716, 584)
tt.nav_path.pi = 7
tt.nav_path.spi = 1
tt.nav_path.ni = 1
tt.spawn_at_nodes = {
	15,
	40,
	70
}
tt.spawn_wave_names = {
	"Boss_Path_1",
	"Boss_Path_2",
	"Boss_Path_3",
	"Boss_Path_4"
}
tt.melee.cooldown = 1.5
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].damage_max = {
	150,
	150,
	150,
	250
}
tt.melee.attacks[1].damage_min = {
	100,
	100,
	100,
	200
}
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].fn_can = function(t, s, a, target)
	return band(target.vis.flags, F_HERO) ~= 0
end
tt.melee.attacks[2] = E:clone_c("melee_attack")
tt.melee.attacks[2].animation = "attack"
tt.melee.attacks[2].damage_type = bor(DAMAGE_NONE, DAMAGE_NO_DODGE)
tt.melee.attacks[2].hit_time = fts(11)
tt.melee.attacks[2].mod = "mod_bram_slap"
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].sound_hit = "ElvesBossBramSlap"
tt.melee.attacks[2].fn_can = function(t, s, a, target)
	return band(target.vis.flags, F_HERO) == 0
end
tt.melee.attacks[2].vis_flags = bor(F_BLOCK, F_EAT, F_INSTAKILL)
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].allowed_templates = {
	"enemy_gnoll_burner",
	"enemy_gnoll_reaver"
}
tt.timed_attacks.list[1].mod = "mod_bloodsydian_warlock"
tt.timed_attacks.list[1].animation = "special"
tt.timed_attacks.list[1].cast_time = fts(18)
tt.timed_attacks.list[1].hit_decal = "decal_bloodsydian_warlock"
tt.timed_attacks.list[1].cooldown = {
	7,
	7,
	7,
	5
}
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].max_count = 10
tt.timed_attacks.list[1].min_count = 3
tt.timed_attacks.list[1].nodes_limit = 0
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_MOD)
tt.timed_attacks.list[1].sound = "ElvesBossBramGroundStomp"
tt.taunts.delay_min = 15
tt.taunts.delay_max = 20
tt.taunts.duration = 3.7
tt.taunts.decal_name = "decal_s18_shoutbox"
tt.taunts.offset = v(0, 0)
tt.taunts.pos = v(736, 719)
tt.taunts.sets.welcome = CC("taunt_set")
tt.taunts.sets.welcome.format = "BOSS_BRAM_TAUNT_WELCOME_%04d"
tt.taunts.sets.welcome.end_idx = 2
tt.taunts.sets.sitting = CC("taunt_set")
tt.taunts.sets.sitting.format = "BOSS_BRAM_TAUNT_GENERIC_%04d"
tt.taunts.sets.sitting.end_idx = 5
tt.taunts.sets.prebattle = CC("taunt_set")
tt.taunts.sets.prebattle.format = "BOSS_BRAM_TAUNT_PREBATTLE_%04d"
tt.taunts.sets.prebattle.end_idx = 3
tt = E:register_t("mod_bram_slap", "modifier")
tt.main_script.queue = kr3_scripts.mod_bram_slap.queue
tt.main_script.update = kr3_scripts.mod_bram_slap.update
tt.custom_anchors = {}
tt.custom_anchors.default = v(0.5, 0.45)
tt = E:register_t("decal_bram_enemy_clone", "decal_bravebark_branchball_enemy_clone")
tt = RT("eb_bajnimen", "boss")

AC(tt, "melee", "ranged", "timed_attacks")

tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(60, 0)
tt.health.dead_lifetime = 100
tt.health.magic_armor = {
	0,
	0,
	0,
	0.5
}
tt.health.hp_max = {
	7500,
	10000,
	13000,
	15000
}
tt.health.on_damage = kr3_scripts.eb_bajnimen.on_damage
tt.health_bar.offset = v(-15, 145)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.enc_icon = 42
tt.info.i18n_key = "ENEMY_BOSS_BAJNIMEN"
tt.info.portrait = "portraits_sc_0076"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.eb_bajnimen.update
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.1336206896551724)
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.render.sprites[1].prefix = "eb_bajnimen"
tt.sound_events.death = "ElvesBajNimenBossDeath"
tt.ui.click_rect = r(-35, 0, 70, 130)
tt.unit.can_explode = false
tt.unit.hit_offset = v(-17, 86)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(17, 75)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_SKELETON, F_POLYMORPH)
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = {
	150,
	150,
	150,
	250
}
tt.melee.attacks[1].damage_min = {
	120,
	120,
	120,
	200
}
tt.melee.attacks[1].hit_time = fts(20)
tt.melee.attacks[1].sound = "ElvesBajNimenBossTail"
tt.melee.attacks[1].sound_args = {
	delay = fts(5)
}
tt.melee.attacks[1].uninterruptible = true
tt.ranged.attacks[1].bullet = "bolt_bajnimen"
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].bullet_start_offset = {
	v(30, 135)
}
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animations = {
	"shadowStorm_start",
	"shadowStorm_loop",
	"shadowStorm_end"
}
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY, F_BOSS)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].sound = "ElvesBajNimenBossShadowCast"
tt.timed_attacks.list[1].spread = 5
tt.timed_attacks.list[1].cooldown = 4
tt.timed_attacks.list[1].max_range = 9e+99
tt.timed_attacks.list[1].bullet = "meteor_bajnimen"
tt.timed_attacks.list[2] = E:clone_c("custom_attack")
tt.timed_attacks.list[2].animations = {
	"charge_start",
	"charge_loop",
	"charge_end"
}
tt.timed_attacks.list[2].current_step = 1
tt.timed_attacks.list[2].active = false
tt.timed_attacks.list[2].steps = {
	{},
	{},
	{}
}
tt.timed_attacks.list[2].steps[1].hp_threshold = 0.8
tt.timed_attacks.list[2].steps[1].hp_heal = 30
tt.timed_attacks.list[2].steps[2].hp_threshold = 0.5
tt.timed_attacks.list[2].steps[2].hp_heal = 40
tt.timed_attacks.list[2].steps[3].hp_threshold = 0.2
tt.timed_attacks.list[2].steps[3].hp_heal = 50
tt.timed_attacks.list[2].heal_every = fts(3)
tt.timed_attacks.list[2].duration = 3
tt.timed_attacks.list[2].sound = "ElvesBajNimenBossHeal"
tt.timed_attacks.list[2].hit_offset = v(0, 40)
tt.timed_attacks.list[2].mod_offset = v(0, 35)
tt = RT("meteor_bajnimen", "arrow_hero_elves_archer_ultimate")
tt.bullet.arrive_decal = "decal_bomb_crater"
tt.bullet.hit_fx = "fx_meteor_bajnimen_explosion"
tt.bullet.max_speed = 750
tt.bullet.mod = nil
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_max = {
	80,
	80,
	80,
	200
}
tt.bullet.damage_min = {
	80,
	80,
	80,
	120
}
tt.render.sprites[1].name = "bajnimen_boss_storm_meteor"
tt.sound_events.insert = "ElvesBajNimenBossShadowTravel"
tt = RT("fx_meteor_bajnimen_explosion", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_meteor_bajnimen_explosion"
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_events.insert = "ElvesBajNimenBossShadowImpact"
tt = RT("bolt_bajnimen", "bolt_enemy")
tt.bullet.damage_min = {
	72,
	72,
	72,
	200
}
tt.bullet.damage_max = {
	96,
	96,
	96,
	300
}
tt.bullet.hit_fx = "fx_bolt_bajnimen_hit"
tt.bullet.max_speed = 360
tt.render.sprites[1].prefix = "bolt_bajnimen"
tt.sound_events.insert = "BoltSorcererSound"
tt = RT("fx_bolt_bajnimen_hit", "fx")

AC(tt, "sound_events")

tt.sound_events.insert = "ElvesBajNimenBossRangedAttack"
tt.render.sprites[1].name = "fx_bolt_bajnimen_hit"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt = RT("eb_balrog", "boss")

AC(tt, "melee", "timed_attacks")

tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(60, 0)
tt.health.dead_lifetime = 100
tt.health.hp_max = {
	8000,
	12000,
	15000,
	15000
}
tt.health_bar.offset = v(0, 100)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.info.enc_icon = 48
tt.info.i18n_key = "ENEMY_BOSS_BALROG"
tt.info.portrait = "portraits_sc_0083"
tt.main_script.insert = kr3_scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.eb_balrog.update
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.13)
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.render.sprites[1].prefix = "eb_balrog"
tt.sound_events.death = "ElvesBalrogDeath"
tt.ui.click_rect = r(-35, 0, 70, 80)
tt.unit.blood_color = BLOOD_ORANGE
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 40)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 45)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_SKELETON, F_POLYMORPH)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = 250
tt.melee.attacks[1].damage_min = 200
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].hit_offset = v(60, -2)
tt.melee.attacks[1].sound = "ElvesBalrogAttack"
tt.melee.attacks[1].uninterruptible = true
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].bullet = "bullet_balrog"
tt.timed_attacks.list[1].animation = "spit"
tt.timed_attacks.list[1].cooldown = {
	10,
	10,
	10,
	9
}
tt.timed_attacks.list[1].shoot_time = fts(9)
tt.timed_attacks.list[1].max_range = 1e+99
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].bullet_start_offset = {
	v(23, 82)
}
tt.timed_attacks.list[1].sound = "ElvesBalrogSpit"
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.timed_attacks.list[1].vis_flag = F_RANGED
tt = RT("eb_hee_haw", "decal_scripted")

AC(tt, "taunts", "attacks")

tt.main_script.update = kr3_scripts.eb_hee_haw.update
tt.render.sprites[1].prefix = "eb_hee_haw_layer1"
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = 0
tt.render.sprites[2].prefix = "eb_hee_haw_layer2"
tt.taunts.delay_min = 15
tt.taunts.delay_max = 20
tt.taunts.duration = 3.7
tt.taunts.sets = {
	welcome = {},
	prebattle = {},
	battle = {}
}
tt.taunts.sets.welcome.format = "ENDLESS_BOSS_GNOLL_TAUNT_WELCOME_%04d"
tt.taunts.sets.welcome.start_idx = 1
tt.taunts.sets.welcome.end_idx = 2
tt.taunts.sets.prebattle.format = "ENDLESS_BOSS_GNOLL_TAUNT_PREBATTLE_%04d"
tt.taunts.sets.prebattle.start_idx = 1
tt.taunts.sets.prebattle.end_idx = 5
tt.taunts.sets.battle.format = "ENDLESS_BOSS_GNOLL_TAUNT_GENERIC_%04d"
tt.taunts.sets.battle.start_idx = 1
tt.taunts.sets.battle.end_idx = 11
tt.taunts.decal_name = "decal_endless_shoutbox"
tt.taunts.offset = v(0, 0)
tt.taunts.pos = v(919, 533)
tt.attacks.list[1] = CC("custom_attack")
tt.attacks.list[1].animation = "shout"
tt.attacks.list[1].multishot_counts = {
	3,
	4,
	5
}
tt.attacks.list[1].munition_type = 3
tt.attacks.list[1].sound = "EndlessHeeHawCall"
tt.attacks.list[2] = CC("custom_attack")
tt.attacks.list[2].animation = "shout"
tt.attacks.list[2].multishot_counts = {
	3,
	4,
	5
}
tt.attacks.list[2].sound = "EndlessHeeHawCall"
tt.attacks.list[3] = CC("bullet_attack")
tt.attacks.list[3].shoot_time = fts(19)
tt.attacks.list[3].bullet = "snare_hee_haw"
tt.attacks.list[3].bullet_start_offset = v(36, 160)
tt = RT("eb_ainyl", "decal_scripted")

AC(tt, "taunts", "attacks")

tt.main_script.update = kr3_scripts.eb_ainyl.update
tt.render.sprites[1].prefix = "eb_ainyl"
tt.render.sprites[1].anchor.y = 0
tt.taunts.delay_min = 15
tt.taunts.delay_max = 20
tt.taunts.duration = 3.7
tt.taunts.sets = {
	welcome = {},
	prebattle = {},
	battle = {}
}
tt.taunts.sets.welcome.format = "ENDLESS_BOSS_TWILIGHT_TAUNT_WELCOME_%04d"
tt.taunts.sets.welcome.start_idx = 1
tt.taunts.sets.welcome.end_idx = 2
tt.taunts.sets.prebattle.format = "ENDLESS_BOSS_TWILIGHT_TAUNT_PREBATTLE_%04d"
tt.taunts.sets.prebattle.start_idx = 1
tt.taunts.sets.prebattle.end_idx = 1
tt.taunts.sets.battle.format = "ENDLESS_BOSS_TWILIGHT_TAUNT_GENERIC_%04d"
tt.taunts.sets.battle.start_idx = 1
tt.taunts.sets.battle.end_idx = 5
tt.taunts.decal_name = "decal_endless_shoutbox"
tt.taunts.offset = v(0, 0)
tt.taunts.pos = v(610, 630)
tt.attacks.list[1] = CC("mod_attack")
tt.attacks.list[1].animation = "teleport"
tt.attacks.list[1].shoot_time = fts(53)
tt.attacks.list[1].vis_bans = bor(F_BOSS)
tt.attacks.list[1].vis_flags = bor(F_RANGED, F_TELEPORT)
tt.attacks.list[1].nodes_limit = 60
tt.attacks.list[1].sound = "EndlessAinylTeleport"
tt.attacks.list[1].mod = "mod_teleport_ainyl"
tt.attacks.list[2] = CC("mod_attack")
tt.attacks.list[2].animation = "block"
tt.attacks.list[2].shoot_time = fts(20)
tt.attacks.list[2].max_range = 1e+99
tt.attacks.list[2].min_range = 0
tt.attacks.list[2].mod = "mod_block_tower_ainyl"
tt.attacks.list[2].sound = "EndlessAinylDisable"
tt.attacks.list[3] = CC("mod_attack")
tt.attacks.list[3].animation = "shield"
tt.attacks.list[3].shoot_time = fts(21)
tt.attacks.list[3].mod = "mod_shield_ainyl"
tt.attacks.list[3].vis_bans = bor(F_BOSS, F_FLYING)
tt.attacks.list[3].vis_flags = bor(F_RANGED)
tt.attacks.list[3].sound = "EndlessAinylShield"
tt = E:register_t("crystal_arcane", "decal_scripted")

E:add_comps(tt, "attacks", "ui", "crystal", "editor", "tween")

tt.editor.props = {
	{
		"ui.nav_mesh_id",
		PT_STRING
	}
}
tt.main_script.update = kr3_scripts.crystal_arcane.update
tt.attacks.cooldown = math.floor(19.148936170212767) * 47 / 30
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].animation = "lightning"
tt.attacks.list[1].bullet = "ray_crystal_arcane"
tt.attacks.list[1].bullet_count = 5
tt.attacks.list[1].chance = 0.3
tt.attacks.list[1].range = 195
tt.attacks.list[1].sound = "ElvesCrystalRay"
tt.attacks.list[1].bullet_start_offset = v(0, 40)
tt.attacks.list[2] = E:clone_c("aura_attack")
tt.attacks.list[2].animations = {
	"freeze_start",
	"freeze_loop",
	"freeze_end"
}
tt.attacks.list[2].aura = "aura_crystal_arcane_freeze"
tt.attacks.list[2].chance = 0.4
tt.attacks.list[2].range = 195
tt.attacks.list[2].hit_time = fts(15)
tt.attacks.list[2].duration = math.floor(8) * 15 / 30
tt.attacks.list[2].sound = "ElvesCrystalIce"
tt.attacks.list[2].fx_center = "decal_crystal_arcane_freeze_center"
tt.attacks.list[2].fxs = {
	"decal_crystal_arcane_freeze_1",
	"decal_crystal_arcane_freeze_2"
}
tt.attacks.list[3] = E:clone_c("aura_attack")
tt.attacks.list[3].animation = "buff"
tt.attacks.list[3].mod = "mod_crystal_arcane_buff"
tt.attacks.list[3].mod_soldier = "mod_crystal_arcane_buff_soldier"
tt.attacks.list[3].chance = 0.3
tt.attacks.list[3].hit_time = fts(30)
tt.attacks.list[3].range = 225
tt.attacks.list[3].sound = "ElvesCrystalBuff"
tt.attacks.list[3].tower_count = 1
tt.attacks.list[3].fx_base = "fx_crystal_arcane_buff"
tt.attacks.list[3].excluded_templates = {}

for i = 1, 11 do
	local s = E:clone_c("sprite")

	s.prefix = "crystal_arcane_layer" .. i
	s.name = "loading"
	s.anchor.y = 0.38461538461538464
	tt.render.sprites[i] = s
end

tt.tween.remove = false
tt.tween.props[1].keys_loading = {
	{
		0,
		0
	},
	{
		fts(23),
		255
	},
	{
		fts(47),
		0
	}
}
tt.tween.props[1].keys_ready = {
	{
		0,
		0
	},
	{
		fts(15),
		255
	}
}
tt.tween.props[1].keys_lightning = {
	{
		0,
		0
	},
	{
		fts(10),
		200
	},
	{
		fts(34),
		0
	}
}
tt.tween.props[1].keys_freeze = {
	{
		0,
		0
	},
	{
		fts(13),
		255
	},
	{
		fts(16),
		0
	}
}
tt.tween.props[1].keys_buff = {
	{
		0,
		0
	},
	{
		fts(24),
		255
	},
	{
		fts(45),
		0
	}
}
tt.tween.props[1].keys = tt.tween.props[1].keys_loading
tt.tween.props[1].loop = true
tt.tween.props[1].sprite_id = 2
tt.ui.click_rect = r(-30, -15, 60, 55)
tt.ui.can_select = false
tt.ui.has_nav_mesh = true
tt.ui.hover_sprite_name = "crystalArcane_layer1_0001_over_console"
tt.ui.hover_sprite_anchor = v(0.5, 0.38461538461538464)
tt = RT("crystal_unstable", "decal_scripted")

AC(tt, "attacks", "crystal", "editor")

tt.main_script.update = kr3_scripts.crystal_unstable.update
tt.attacks.cooldown = 15
tt.attacks.list[1] = CC("mod_attack")
tt.attacks.list[1].animation = "teleport"
tt.attacks.list[1].cast_time = fts(26)
tt.attacks.list[1].chance = 0.3
tt.attacks.list[1].good_chance = 0.5
tt.attacks.list[1].max_count = 5
tt.attacks.list[1].max_nodes = 20
tt.attacks.list[1].min_count = 3
tt.attacks.list[1].min_nodes = 10
tt.attacks.list[1].mod = "mod_crystal_unstable_teleport"
tt.attacks.list[1].range = 125
tt.attacks.list[1].vis_flags = bor(F_TELEPORT, F_RANGED)
tt.attacks.list[1].vis_bans = bor(F_BOSS)
tt.attacks.list[2] = CC("mod_attack")
tt.attacks.list[2].allowed_templates = {
	"enemy_gnoll_reaver",
	"enemy_gnoll_burner"
}
tt.attacks.list[2].mod = "mod_crystal_unstable_infuse"
tt.attacks.list[2].animation = "infuse"
tt.attacks.list[2].cast_time = fts(26)
tt.attacks.list[2].chance = 0.3
tt.attacks.list[2].good_chance = 0.5
tt.attacks.list[2].max_count = 3
tt.attacks.list[2].min_count = 3
tt.attacks.list[2].range = 175
tt.attacks.list[2].vis_flags = bor(F_RANGED)
tt.attacks.list[3] = CC("mod_attack")
tt.attacks.list[3].mod = "mod_crystal_unstable_heal"
tt.attacks.list[3].animation = "heal"
tt.attacks.list[3].cast_time = fts(26)
tt.attacks.list[3].chance = 0.4
tt.attacks.list[3].aura_range = 75
tt.attacks.list[3].max_count = 6
tt.attacks.list[3].min_count = 4
tt.attacks.list[3].range = 175
tt.attacks.list[3].sound = "ElvesUnstableCrystalHealing"
tt.attacks.list[3].trigger_hp_factor = 0.99
tt.attacks.list[3].vis_flags = bor(F_RANGED)
tt.attacks.list[3].vis_bans = bor(F_BOSS)

for i = 1, 4 do
	local s = E:clone_c("sprite")

	s.prefix = "crystal_unstable_layer" .. i
	s.name = "loading"
	s.anchor.y = 0.18828451882845187
	tt.render.sprites[i] = s
end

tt = RT("paralyzing_tree", "decal_scripted")

E:add_comps(tt, "custom_attack", "ui", "plant", "editor")

tt.editor.props = {
	{
		"ui.nav_mesh_id",
		PT_STRING
	}
}
tt.render.sprites[1].anchor.y = 0.31976744186046513
tt.render.sprites[1].prefix = "paralyzing_tree"
tt.render.sprites[1].name = "loading"
tt.main_script.update = kr3_scripts.paralyzing_tree.update
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-40, -5, 80, 80)
tt.ui.has_nav_mesh = true
tt.ui.hover_sprite_name = "paralyzingTree_0001_over_console"
tt.ui.hover_sprite_anchor = v(0.5, 0.5879120879120879)
tt.custom_attack.cooldown = 15
tt.custom_attack.range = 160
tt.custom_attack.vis_flags = bor(F_RANGED, F_STUN)
tt.custom_attack.vis_bans = bor(F_BOSS)
tt.custom_attack.shoot_time = fts(6)
tt.custom_attack.animation = "shoot"
tt.custom_attack.mod = "mod_paralyzing_tree"
tt = RT("mod_paralyzing_tree", "mod_stun")
tt.modifier.duration = 4
tt.render.sprites[1].prefix = "mod_paralyzing_tree"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].size_names = nil
tt = RT("fx_paralyzing_tree_1", "fx")
tt.render.sprites[1].name = "fx_paralyzing_tree_1"
tt.render.sprites[1].z = Z_DECALS
tt = RT("fx_paralyzing_tree_2", "fx_paralyzing_tree_1")
tt.render.sprites[1].name = "fx_paralyzing_tree_2"
tt = RT("fx_paralyzing_tree_3", "fx_paralyzing_tree_1")
tt.render.sprites[1].name = "fx_paralyzing_tree_3"
tt = E:register_t("arrow_soldier_re_2", "arrow")
tt.bullet.damage_max = 10
tt.bullet.damage_min = 6
tt.bullet.reset_to_target_pos = true
tt.bullet.flight_time = fts(13)
tt.bullet.hide_radius = 2
tt.bullet.hit_fx = "fx_arrow_soldier_re_hit"
tt.bullet.miss_decal = "reinforce_proy_0010"
tt.bullet.rotation_speed = 40 * FPS * math.pi / 180
tt.render.sprites[1].name = "reinforce_proy_0001"
tt = E:register_t("arrow_soldier_re_3", "arrow_soldier_re_2")
tt.bullet.damage_max = 20
tt.bullet.damage_min = 10
tt = E:register_t("arrow_soldier_re_4", "arrow_soldier_re_2")
tt.bullet.damage_max = 20
tt.bullet.damage_min = 10
tt = E:register_t("arrow_soldier_re_5", "arrow_soldier_re_2")
tt.bullet.damage_max = 30
tt.bullet.damage_min = 20
tt = E:register_t("bolt_faustus", "bolt_elves")
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_bolt_faustus_hit"
tt.bullet.particles_name = "ps_bolt_faustus"
tt.bullet.xp_gain_factor = 0.38
tt.initial_impulse = 2100
tt.render.sprites[1].prefix = "bolt_faustus"
tt.sound_events.insert = nil
tt.upgrades_disabled = true
tt = E:register_t("bolt_lance_faustus", "bolt")
tt.bullet.acceleration_factor = 0.25
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_bolt_lance_faustus_hit"
tt.bullet.ignore_hit_offset = true
tt.bullet.max_speed = 600
tt.bullet.min_speed = 600
tt.bullet.pop = nil
tt.bullet.particles_name = "ps_bolt_lance_faustus"
tt.render.sprites[1].prefix = "bolt_lance_faustus"
tt.render.sprites[1].hidden = true
tt.sound_events.insert = nil
tt = E:register_t("bullet_liquid_fire_faustus", "bullet")
tt.main_script.update = kr3_scripts.bullet_liquid_fire_faustus.update
tt.render = nil
tt.bullet.particles_name = "ps_bullet_liquid_fire_faustus"
tt.bullet.flight_time = fts(10)
tt.flames_count = nil
tt.bullet.hit_fx = "fx_bullet_liquid_fire_faustus_hit"
tt = E:register_t("bullet_bravebark_seed", "bomb")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(22)
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.render.sprites[1].name = "bravebark_hero_mignonSeed"
tt = RT("catha_fury", "bullet")
tt.animations = {
	loop = "dashLoop",
	start = "dashStart",
	attack = "dashHit"
}
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.max_speed = 240
tt.bullet.min_speed = 210
tt.bullet.mod = nil
tt.lead_time = fts(12)
tt.main_script.insert = kr3_scripts.bullet_illusion.insert
tt.main_script.update = kr3_scripts.bullet_illusion.update
tt.render.sprites[1].anchor.y = 0.373015873015873
tt.render.sprites[1].name = "dashStart"
tt.render.sprites[1].prefix = "hero_catha"
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_events.hit = "ElvesHeroCathaFuryHit"
tt = RT("knife_catha", "arrow")
tt.render.sprites[1].name = "catha_hero_proy_0001"
tt.render.sprites[1].animated = false
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.flight_time = fts(9)
tt.bullet.hit_fx = "fx_knife_catha_hit"
tt.bullet.miss_decal = nil
tt.bullet.mod = nil
tt.bullet.xp_gain_factor = 0.78
tt = RT("knife_soldier_catha", "knife_catha")
tt.bullet.xp_gain_factor = nil
tt = RT("fireball_veznan_demon", "bullet")
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_radius = 40
tt.bullet.damage_max = nil
tt.bullet.damage_mix = nil
tt.bullet.mod = "mod_veznan_demon_fire"
tt.bullet.node_prediction = nil
tt.bullet.flight_time = fts(12)
tt.bullet.particles_name = "ps_fireball_veznan_demon"
tt.bullet.hit_fx_air = "fx_fireball_veznan_demon_hit_air"
tt.bullet.hit_fx = "fx_fireball_veznan_demon_hit"
tt.bullet.vis_flags = F_RANGED
tt.main_script.update = kr3_scripts.fireball.update
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor.x = 0.7352941176470589
tt.render.sprites[1].name = "fireball_veznan_demon"
tt.sound_events.insert = "ElvesHeroVeznanDemonFireballThrow"
tt.sound_events.hit = "ElvesHeroVeznanDemonFireballHit"
tt = RT("bolt_veznan", "bolt")
tt.render.sprites[1].prefix = "veznan_hero_bolt"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.acceleration_factor = 0.1
tt.bullet.min_speed = 30
tt.bullet.max_speed = 300
tt.bullet.hit_fx = "fx_bolt_veznan_hit"
tt.bullet.xp_gain_factor = 0.38
tt.sound_events.insert = "ElvesHeroVeznanRangeShoot"
tt.bullet.pop = {
	"pop_mage"
}
tt.bullet.pop_conds = DR_KILL
tt = RT("ray_rag", "bullet")
tt.image_width = 164
tt.main_script.update = kr3_scripts.ray_simple.update
tt.render.sprites[1].name = "ray_rag"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_time = fts(5)
tt.bullet.mod = "mod_rag_raggified"
tt = RT("bullet_rag", "arrow")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.flight_time = fts(18)
tt.bullet.hit_blood_fx = nil
tt.bullet.hit_fx = "fx_bullet_rag_hit"
tt.bullet.miss_decal = nil
tt.bullet.miss_fx = "fx_bullet_rag_hit"
tt.bullet.miss_fx_water = nil
tt.bullet.particles_name = "ps_bullet_rag_trail"
tt.bullet.pop = nil
tt.bullet.predict_target_pos = true
tt.bullet.prediction_error = false
tt.bullet.xp_gain_factor = 0.38
tt.render.sprites[1].name = "razzAndRaggs_hero_proy-f"
tt.sound_events.insert = "ElvesHeroRagGnomeShot"
tt = RT("bullet_rag_throw", "arrow")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = fts(12)
tt.bullet.miss_decal = nil
tt.bullet.miss_fx = nil
tt.bullet.miss_fx_water = nil
tt.bullet.pop = nil
tt.bullet.predict_target_pos = true
tt.bullet.prediction_error = false
tt.bullet.rotation_speed = 15 * FPS * math.pi / 180
tt = RT("bullet_rag_throw_bolso", "bullet_rag_throw")
tt.render.sprites[1].name = "razzAndRaggs_hero_throw_proys_0001"
tt = RT("bullet_rag_throw_anchor", "bullet_rag_throw")
tt.render.sprites[1].name = "razzAndRaggs_hero_throw_proys_0002"
tt = RT("bullet_rag_throw_fungus", "bullet_rag_throw")
tt.render.sprites[1].name = "razzAndRaggs_hero_throw_proys_0003"
tt = RT("bullet_rag_throw_pan", "bullet_rag_throw")
tt.render.sprites[1].name = "razzAndRaggs_hero_throw_proys_0004"
tt = RT("bullet_rag_throw_chair", "bullet_rag_throw")
tt.render.sprites[1].name = "razzAndRaggs_hero_throw_proys_0005"
tt = RT("bullet_kamihare", "bomb")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(17)
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.g = -1.25 / (fts(1) * fts(1))
tt.bullet.rotation_speed = nil
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.render.sprites[1].name = "bullet_kamihare"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0.20512820512820512
tt = RT("ray_durax", "bullet")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_ray_durax_hit"
tt.bullet.hit_time = fts(5)
tt.image_width = 164
tt.track_target = true
tt.main_script.update = kr3_scripts.ray_simple.update
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "ray_durax"
tt.sound_events.insert = "ElvesHeroDuraxLethalPrismShoot"
tt = RT("spear_durax", "arrow")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.flight_time = fts(16)
tt.bullet.hide_radius = 1
tt.bullet.hit_fx = "fx_shardseed_hit"
tt.bullet.miss_decal = "durax_hero_proy_0002-f"
tt.bullet.miss_decal_anchor = v(1, 0.5)
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = true
tt.bullet.reset_to_target_pos = true
tt.bullet.xp_gain_factor = 0.35
tt.render.sprites[1].anchor.x = 0.8214285714285714
tt.render.sprites[1].name = "durax_hero_proy_0001-f"
tt.sound_events.insert = "ElvesHeroDuraxShardSpearThrow"
tt = RT("spear_durax_clone", "spear_durax")
tt.render.sprites[1].shader = "p_tint"
tt.render.sprites[1].shader_args = {
	tint_color = {
		0,
		1,
		1,
		1
	}
}
tt = RT("bullet_lilith", "arrow")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.flight_time = fts(10)
tt.bullet.hide_radius = 1
tt.bullet.hit_fx = "fx_lilith_ranged_hit"
tt.bullet.miss_fx = "fx_lilith_ranged_hit"
tt.bullet.miss_decal = nil
tt.bullet.particles_name = "ps_bullet_lilith_trail"
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = true
tt.bullet.use_unit_damage_factor = true
tt.bullet.xp_gain_factor = 0.62
tt.render.sprites[1].name = "fallen_angel_hero_proy_0001-f"
tt.sound_events.insert = "ElvesHeroLilithRangeShoot"
tt = RT("meteor_lilith", "bullet")
tt.main_script.update = kr3_scripts.meteor_lilith.update
tt.bullet.damage_max = nil
tt.bullet.damage_radius = 45
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.arrive_decal = "decal_meteor_lilith_explosion"
tt.bullet.arrive_fx = "fx_meteor_lilith_explosion"
tt.bullet.max_speed = 1050
tt.bullet.mod = "mod_hero_elves_archer_slow"
tt.render.sprites[1].name = "fallen_angel_hero_ultimate_meteor"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.x = 0.9166666666666666
tt.sound_events.hit = "ElvesHeroLilithMeteorsHit"
tt = RT("ray_phoenix", "bullet")
tt.image_width = 120
tt.main_script.update = kr3_scripts.ray_simple.update
tt.render.sprites[1].name = "ray_phoenix"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.bullet.hit_fx = "fx_ray_phoenix_hit"
tt.bullet.hit_fx_ignore_hit_offset = true
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_time = fts(4)
tt.bullet.hit_payload = "aura_ray_phoenix"
tt.track_target = true
tt = RT("missile_phoenix", "bullet")
tt.bullet.acceleration_factor = 0.05
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = nil
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.first_retarget_range = 300
tt.bullet.hit_fx = "fx_ray_phoenix_hit"
tt.bullet.hit_fx_ignore_hit_offset = true
tt.bullet.max_speed = 540
tt.bullet.min_speed = 420
tt.bullet.particles_name = "ps_missile_phoenix"
tt.bullet.retarget_range = 99999
tt.bullet.speed_var = 60
tt.bullet.turn_helicoidal_factor = 2
tt.bullet.turn_speed = 10 * math.pi / 180 * 30
tt.bullet.vis_bans = 0
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_flags = F_RANGED
tt.bullet.xp_gain_factor = 0.12
tt.main_script.insert = kr3_scripts.missile_phoenix.insert
tt.main_script.update = kr3_scripts.missile.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "phoenix_hero_bird"
tt.sound_events.hit = "ElvesHeroPhoenixBlazingOffspringHit"
tt = RT("missile_phoenix_small", "missile_phoenix")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.particles_name = "ps_missile_phoenix_small"
tt.bullet.xp_gain_factor = 0.12
tt.render.sprites[1].scale = vv(0.65)
tt = E:register_t("torch_gnoll_burner", "arrow")
tt.bullet.mod = "mod_gnoll_burner"
tt.bullet.damage_max = 6
tt.bullet.damage_min = 2
tt.bullet.hit_blood_fx = nil
tt.bullet.rotation_speed = 30 * FPS * math.pi / 180
tt.bullet.pop = nil
tt.bullet.miss_decal = nil
tt.bullet.flight_time = fts(12)
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = false
tt.bullet.hit_fx = "fx_torch_gnoll_burner_explosion"
tt.bullet.miss_fx = "fx_torch_gnoll_burner_explosion"
tt.render.sprites[1].name = "torch_gnoll_burner"
tt.render.sprites[1].animated = true
tt.render.sprites[1].r = math.pi
tt = E:register_t("bullet_gnoll_blighter", "bullet")
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor.y = 0.15625
tt.render.sprites[1].prefix = "gnoll_blighter_energy"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.travel = {
	"travel",
	"travelUp",
	"travelDown"
}
tt.render.sprites[1].angles_stickiness = {
	travel = 10
}
tt.bullet.hit_fx = "fx_bolt_gnoll_blighter_hit"
tt.bullet.damage_max = 75
tt.bullet.damage_min = 50
tt.bullet.min_speed = 60
tt.bullet.max_speed = 240
tt.bullet.acceleration_factor = 0.1
tt.main_script.update = kr3_scripts.bullet_gnoll_blighter.update
tt.sound_events.insert = "BoltSorcererSound"
tt = E:register_t("arrow_twilight_elf_harasser", "arrow")
tt.bullet.damage_max = 30
tt.bullet.damage_min = 20
tt.main_script.insert = kr3_scripts.arrow_twilight_elf_harasser.insert
tt.flight_time_range = {
	fts(15),
	fts(26)
}
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = false
tt = E:register_t("arrow_twilight_elf_harasser_shadowshot", "arrow")
tt.bullet.damage_max = 35
tt.bullet.damage_min = 25
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = false
tt = E:register_t("knife_satyr", "arrow")
tt.render.sprites[1].name = "satyr_knife_0001-f"
tt.render.sprites[1].animated = false
tt.bullet.asymmetrical = true
tt.bullet.damage_min = 4
tt.bullet.damage_max = 7
tt.bullet.flight_time = fts(10)
tt.bullet.g = -0.7 / (fts(1) * fts(1))
tt.bullet.hit_fx = "fx_knife_satyr_hit"
tt.bullet.miss_decal = "satyr_knife_0002-f"
tt.bullet.pop = nil
tt.bullet.predict_target_pos = false
tt = E:register_t("bullet_arachnomancer_spawn", "bomb")

E:add_comps(tt, "nav_path")

tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(17)
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.rotation_speed = 0
tt.bullet.y = -1.25 / (fts(1) * fts(1))
tt.sound_events.insert = "ElvesCreepArachnomancerSpiderSpawn"
tt.sound_events.hit = nil
tt.render.sprites[1].name = "arachnomancer_spider_0054"
tt.render.sprites[1].anchor.y = 0.15625
tt.main_script.insert = kr3_scripts.bullet_arachnomancer_spawn.insert
tt.payload_entity = "enemy_spider_arachnomancer"
tt = RT("rock_perython", "bullet")
tt.render.sprites[1].prefix = "perython_rock"
tt.render.sprites[1].name = "drop"
tt.main_script.update = kr3_scripts.rock_perython.update
tt.bullet.damage_min = 75
tt.bullet.damage_max = 100
tt.bullet.damage_radius = 75
tt.bullet.hit_fx = "fx_rock_explosion"
tt.bullet.hit_decal = "decal_rock_crater"
tt.sound_events.hit = "TowerStoneDruidBoulderExplote"
tt = E:register_t("bolt_ogre_magi", "bolt_enemy")
tt.bullet.damage_max = 72
tt.bullet.damage_min = 48
tt.bullet.align_with_trajectory = true
tt.bullet.hit_fx = "fx_bolt_ogre_magi_hit"
tt.bullet.hit_fx_ignore_offset = true
tt.bullet.hit_fx_air = "fx_bolt_ogre_magi_hit_air"
tt.bullet.ignore_rotation = false
tt.bullet.max_speed = 540
tt.bullet.min_speed = 60
tt.render.sprites[1].prefix = "ogre_mage_proy"
tt.render.sprites[1].name = "flying"
tt.sound_events.insert = "BoltSorcererSound"
tt = RT("bullet_dark_spitters", "arrow")
tt.bullet.damage_min = 48
tt.bullet.damage_max = 72
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = false
tt.bullet.hit_fx = nil
tt.bullet.mod = "mod_dark_spitters"
tt.bullet.miss_fx = "fx_bullet_dark_spitters_miss"
tt.bullet.hit_blood_fx = nil
tt.bullet.miss_decal = nil
tt.bullet.miss_fx_water = nil
tt.bullet.flight_time = fts(12)
tt.bullet.pop = nil
tt.render.sprites[1].name = "dark_spitters_proy"
tt.render.sprites[1].animated = true
tt.sound_events.insert = "ElvesDarkSpitterSpit"
tt = RT("bullet_balrog", "bomb")
tt.bullet.align_with_trajectory = true
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.damage_bans = bor(F_ENEMY, F_FRIEND)
tt.bullet.hit_fx = "fx_bullet_balrog_hit"
tt.bullet.hit_decal = "aura_bullet_balrog"
tt.bullet.flight_time_base = fts(3)
tt.bullet.flight_time_factor = fts(0.04)
tt.bullet.particles_name = "ps_bullet_balrog"
tt.render.sprites[1].name = "bullet_balrog"
tt.render.sprites[1].animated = true
tt.main_script.insert = kr3_scripts.enemy_bomb.insert
tt.main_script.update = kr3_scripts.enemy_bomb.update
tt.sound_events.insert = nil
tt.sound_events.hit = "ElvesBalrogBloodpool"
tt = RT("snare_hee_haw", "bullet")
tt.main_script.update = kr3_scripts.snare_hee_haw.update
tt.render.sprites[1].anchor.y = 0.3418803418803419
tt.render.sprites[1].prefix = "snare_hee_haw"
tt.render.sprites[1].name = "falling"
tt.render.sprites[1].scale = vv(0.5)
tt.render.sprites[1].z = Z_BULLETS
tt.sound_events.insert = "EndlessHeeHawNetHit"
tt.sound_events.falling = "EndlessHeeHawNetFalling"
tt.sound_events.hit = "EndlessHeeHawNetHit"
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = bor(F_ENEMY, F_FLYING)
tt.bullet.mod = "mod_snare_hee_haw"
tt.bullet.mod_radius = 5
tt = RT("bullet_catapult_endless_rock", "rock_enemy_catapult")
tt.render.sprites[1].name = "catapult_endless_proy_0001"
tt.bullet.damage_max = 100
tt.bullet.damage_min = 100
tt.bullet.damage_radius = 60
tt.bullet.hit_fx = "fx_rock_explosion"
tt = RT("bullet_catapult_endless_spiked", "rock_enemy_catapult")
tt.render.sprites[1].name = "catapult_endless_proy_0002"
tt.bullet.damage_max = 200
tt.bullet.damage_min = 200
tt.bullet.damage_radius = 60
tt.bullet.hit_fx = "fx_bullet_catapult_endless_spiked_explosion"
tt = RT("bullet_catapult_endless_bomb", "rock_enemy_catapult")
tt.render.sprites[1].name = "bullet_catapult_endless_bomb"
tt.render.sprites[1].animated = true
tt.bullet.damage_max = 300
tt.bullet.damage_min = 300
tt.bullet.damage_radius = 60
tt.bullet.hit_fx = "fx_bullet_catapult_endless_bomb_explosion"
tt = RT("bullet_catapult_endless_barrel", "rock_enemy_catapult")
tt.render.sprites[1].name = "catapult_endless_proy_0003"
tt.bullet.hit_fx = "fx_bullet_catapult_endless_barrel_explosion"
tt = E:register_t("ray_crystal_arcane", "bullet")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.mod = "mod_ray_crystal_arcane"
tt.bullet.hit_time = fts(4)
tt.image_width = 92
tt.track_target = true
tt.main_script.update = kr3_scripts.ray_simple.update
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "ray_crystal_arcane"
tt = E:register_t("aura_liquid_fire_flame_faustus", "aura")

E:add_comps(tt, "render", "tween")

tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt.aura.mod = "mod_liquid_fire_faustus"
tt.aura.duration = 6
tt.aura.cycle_time = fts(10)
tt.aura.radius = 35
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.vis_bans = bor(F_FRIEND)
tt.render.sprites[1].name = "aura_liquid_fire_flame_faustus"
tt.sound_events.insert = "ElvesHeroFaustusFireLoop"
tt.sound_events.remove_stop = "ElvesHeroFaustusFireLoop"
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.25,
		255
	},
	{
		"this.aura.duration-1",
		255
	},
	{
		"this.aura.duration",
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		vv(0.5)
	},
	{
		0.5,
		vv(1)
	}
}
tt = E:register_t("aura_minidragon_faustus", "aura_liquid_fire_flame_faustus")
tt.aura.mod = "mod_minidragon_faustus"
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.05,
		255
	},
	{
		"this.aura.duration-1",
		255
	},
	{
		"this.aura.duration",
		0
	}
}
tt.tween.props[2] = nil
tt = E:register_t("aura_enervation_faustus", "aura")
tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt.aura.mod = "mod_enervation_faustus"
tt.aura.cycle_time = 0
tt.aura.cycles = 1
tt.aura.radius = 100
tt.aura.vis_flags = bor(F_RANGED, F_SPELLCASTER)
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND, F_HERO)
tt.aura.targets_per_cycle = nil
tt = E:register_t("aura_teleport_faustus", "aura")

E:add_comps(tt, "render", "tween")

tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt.aura.mod = "mod_teleport_faustus"
tt.aura.cycle_time = 1000000000
tt.aura.duration = fts(20)
tt.aura.radius = 50
tt.aura.vis_flags = bor(F_RANGED, F_TELEPORT)
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND, F_HERO, F_FREEZE)
tt.aura.targets_per_cycle = nil
tt.render.sprites[1].name = "aura_teleport_faustus"
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		55
	},
	{
		fts(5),
		255
	},
	{
		fts(15),
		255
	},
	{
		fts(20),
		0
	}
}
tt = E:register_t("aura_bravebark_springsap", "aura")

E:add_comps(tt, "render", "tween")

tt.aura.cycle_time = fts(3)
tt.aura.mod = "mod_bravebark_springsap"
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.excluded_templates = {
	"kr3_hero_alleria",
	"soldier_bravebark",
	"soldier_xin_shadow",
	"soldier_druid_bear",
	"soldier_veznan_demon"
}
tt.aura.radius = 100
tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt.render.sprites[1].name = "bravebark_hero_springSapDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "bravebark_springSapBubbles"
tt.render.sprites[2].anchor.y = 0
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.85,
		0
	}
}
tt.tween.props[1].loop = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		vv(0.5)
	},
	{
		0.85,
		vv(1.25)
	}
}
tt.tween.props[2].loop = true
tt = RT("aura_baby_malik_fissure", "aura")
tt.aura.fx = "decal_baby_malik_earthquake"
tt.aura.damage_radius = nil
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.vis_flags = bor(F_RANGED, F_STUN)
tt.aura.spread_delay = fts(4)
tt.aura.spread_nodes = 4
tt.main_script.update = kr3_scripts.aura_baby_malik_fissure.update
tt.stun = {}
tt.stun.vis_flags = bor(F_RANGED, F_STUN)
tt.stun.vis_bans = bor(F_FLYING, F_BOSS)
tt.stun.mod = "mod_baby_malik_stun"
tt = RT("aura_lilith_infernal_wheel", "aura")

AC(tt, "render", "tween")

tt.aura.duration = 5
tt.aura.cycle_time = fts(10)
tt.aura.mod = "mod_lilith_infernal_wheel"
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.radius = 50
tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt.render.sprites[1].name = "lilith_infernal_base_decal_loop"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].loop = false
tt.render.sprites[2].name = "lilith_infernal_base_fireIn_loop"
tt.render.sprites[2].hide_after_runs = 1
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(5),
		255
	},
	{
		"this.aura.duration-0.5",
		255
	},
	{
		"this.aura.duration",
		0
	}
}
tt = RT("aura_lilith_soul_eater", "aura")
tt.aura.duration = -1
tt.aura.cooldown = 30
tt.aura.cycle_time = fts(5)
tt.aura.radius = 200
tt.aura.vis_bans = bor(F_BOSS, F_FLYING)
tt.aura.vis_flags = bor(F_MOD, F_RANGED)
tt.aura.excluded_templates = {
	"enemy_hyena"
}
tt.aura.mod = "mod_lilith_soul_eater_track"
tt.main_script.update = kr3_scripts.aura_lilith_soul_eater.update
tt = RT("aura_bruce_hps", "aura")

AC(tt, "hps")

tt.aura.duration = -1
tt.main_script.update = kr3_scripts.aura_bruce_hps.update
tt.hps.heal_max = 1
tt.hps.heal_every = fts(20)
tt = RT("aura_phoenix_egg", "aura")

AC(tt, "render")

tt.render.sprites[1].prefix = "hero_phoenix_egg"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].hidden = true
tt.main_script.update = kr3_scripts.aura_phoenix_egg.update
tt.aura.cycle_time = fts(6)
tt.aura.radius = 50
tt.aura.vis_flags = F_RANGED
tt.aura.vis_bans = F_FLYING
tt.aura.mod = "mod_phoenix_egg"
tt.aura.duration = 5
tt.custom_attack = CC("custom_attack")
tt.custom_attack.radius = 90
tt.custom_attack.damage_max = nil
tt.custom_attack.damage_min = nil
tt.custom_attack.damage_type = DAMAGE_TRUE
tt.custom_attack.vis_flags = F_RANGED
tt.custom_attack.hit_fx = "fx_phoenix_explosion"
tt = RT("aura_phoenix_purification", "aura")
tt.aura.cycle_time = fts(9)
tt.aura.duration = -1
tt.aura.mod = "mod_phoenix_purification"
tt.aura.radius = 125
tt.aura.targets_per_cycle = nil
tt.aura.track_source = true
tt.aura.track_dead = true
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
tt.aura.vis_bans = bor(F_FRIEND)
tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt = RT("aura_ray_phoenix", "aura")
tt.main_script.insert = kr3_scripts.aura_ray_phoenix.insert
tt.main_script.update = kr3_scripts.aura_apply_damage.update
tt.aura.cycles = 1
tt.aura.damage_min = nil
tt.aura.damage_max = nil
tt.aura.damage_inc = nil
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.radius = 45
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.mod = "mod_veznan_demon_fire"
tt.aura.xp_gain_factor = 0.35
tt = E:register_t("aura_gnoll_gnawer", "aura")
tt.main_script.update = kr3_scripts.aura_gnoll_gnawer.update
tt.min_count = 4
tt.aura.radius = 100
tt.aura.cycle_time = 0.25
tt.aura.mod = "mod_gnoll_gnawer"
tt.aura.vis_flags = F_RANGED
tt = E:register_t("aura_ettin_regen", "aura")

E:add_comps(tt, "regen")

tt.main_script.update = kr3_scripts.aura_unit_regen.update
tt.regen.ignore_stun = true
tt.regen.ignore_freeze = false
tt.regen.cooldown = fts(5)
tt.regen.health = 4
tt = E:register_t("aura_bandersnatch_spines", "aura")
tt.main_script.update = kr3_scripts.aura_bandersnatch_spines.update
tt.aura.radius = 125
tt.aura.damage_max = 200
tt.aura.damage_min = 140
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.hit_fx = "fx_bandersnatch_spines_blood"
tt.spines_count = 27
tt = E:register_t("aura_boomshrooms_death", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = {
	40,
	40,
	40,
	50
}
tt.aura.damage_max = {
	40,
	40,
	40,
	60
}
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.radius = 87.5
tt.aura.vis_bans = bor(F_FLYING, F_ENEMY)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = kr3_scripts.aura_apply_damage.update
tt = E:register_t("aura_razorboar_rage", "aura")
tt.main_script.update = kr3_scripts.aura_razorboar_rage.update
tt.main_script.insert = kr3_scripts.aura_razorboar_rage.insert
tt.main_script.remove = kr3_scripts.aura_razorboar_rage.remove
tt.damage_hp_factor = 1
tt.aura.track_source = true
tt = RT("aura_spider_sprint", "aura")

AC(tt, "editor", "editor_script")

tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt.aura.duration = -1
tt.aura.mod = "mod_spider_sprint"
tt.aura.cycle_time = fts(10)
tt.aura.allowed_templates = {
	"enemy_drider",
	"enemy_spider_tarantula",
	"enemy_spider_arachnomancer",
	"enemy_spider_son_of_mactans",
	"enemy_sword_spider",
	"enemy_webspitting_spider"
}
tt.editor.components = {
	"render"
}
tt.editor.overrides = {
	["render.sprites[1].hidden"] = false,
	["render.sprites[1].animated"] = false,
	["render.sprites[1].name"] = "editor_red_circle"
}
tt.editor.props = {
	{
		"aura.radius",
		PT_NUMBER
	}
}
tt.editor_script.update = kr3_scripts.editor_aura_spider_sprint.update
tt = RT("aura_mactans_path_web", "aura")
tt.main_script.update = kr3_scripts.aura_mactans_path_web.update
tt.steps_count = 5
tt.steps_count_auras = 4
tt.step_nodes = 4
tt.step_delay = fts(7)
tt.fade_duration = fts(10)
tt.aura.duration = nil
tt.aura.radius = 63
tt.aura.vis_flags = bor(F_NET, F_STUN)
tt.aura.vis_bans = bor(F_FLYING)
tt.pi = nil
tt.ni = nil
tt = RT("aura_eb_spider_path_web", "aura_mactans_path_web")
tt.steps_count = 3
tt.steps_count_auras = 2
tt.step_delay = fts(0.5)
tt.aura.duration = 5
tt.fade_duration = fts(3)
tt = RT("aura_ogre_magi_regen", "aura")

AC(tt, "regen")

tt.main_script.update = kr3_scripts.aura_unit_regen.update
tt.regen.cooldown = fts(5)
tt.regen.health = 5
tt.regen.ignore_stun = true
tt.regen.ignore_freeze = false
tt = RT("aura_ogre_magi_shield", "aura")

AC(tt, "render")

tt.aura.cast_resets_sprite_id = 2
tt.aura.cycle_time = 1.5
tt.aura.duration = -1
tt.aura.filter_source = true
tt.aura.mod = "mod_ogre_magi_shield"
tt.aura.radius = 100
tt.aura.requires_magic = true
tt.aura.source_vis_flags = F_RANGED
tt.aura.track_source = true
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
tt.aura.excluded_templates = {
	"enemy_ogre_magi"
}
tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt.fx_cooldown = fts(10)
tt.last_fx_ts = 0
tt.render.sprites[1].name = "ogre_mage_shield_damage"
tt.render.sprites[1].loop = false
tt.render.sprites[1].ts = -10
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "ogre_mage_aura"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].loop = false
tt = RT("aura_shadow_champion_death", "aura")
tt.main_script.update = kr3_scripts.aura_shadow_champion_death.update
tt.aura.radius = 80
tt.aura.vis_flags = bor(F_MOD, F_RANGED)
tt.aura.enemy_mod = "mod_shadow_champion"
tt.aura.soldier_mod = "mod_dark_spitters"
tt.aura.include_enemies = {
	"enemy_shadows_spawns",
	"enemy_dark_spitters",
	"enemy_grim_devourers"
}
tt = RT("aura_bullet_balrog", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = fts(10)
tt.aura.duration = 10
tt.aura.mod = "mod_balrog"
tt.aura.radius = 50
tt.aura.vis_bans = bor(F_ENEMY, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt.render.sprites[1].name = "balrog_aura_loop"
tt.render.sprites[1].anchor.y = 0.41818181818181815
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "balrog_aura_bubble_pop"
tt.render.sprites[2].loop = true
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(12),
		255
	},
	{
		10,
		255
	},
	{
		10.5,
		0
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		vv(0.42)
	},
	{
		fts(12),
		vv(1)
	}
}
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "offset"
tt.tween.props[3].keys = {
	{
		0,
		v(0, -10)
	},
	{
		fts(55),
		v(30, -20)
	},
	{
		fts(110),
		v(35, -5)
	},
	{
		fts(165),
		v(-35, -8)
	},
	{
		fts(220),
		v(25, -20)
	},
	{
		fts(275),
		v(-30, -20)
	}
}
tt.tween.props[3].loop = true
tt.tween.props[3].sprite_id = 2
tt.tween.props[3].interp = "step"
tt.tween.remove = false
tt = RT("aura_twilight_brute", "aura")

AC(tt, "render")

tt.aura.cycle_time = fts(10)
tt.aura.duration = -1
tt.aura.filter_source = true
tt.aura.mod = "mod_twilight_brute"
tt.aura.radius = 60
tt.aura.requires_magic = false
tt.aura.track_source = true
tt.aura.use_mod_offset = false
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt.render.sprites[1].name = "aura_twilight_bannerbearer"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].anchor.y = 0.33783783783783783
tt = E:register_t("aura_crystal_arcane_freeze", "aura")
tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt.aura.mod = "mod_crystal_arcane_freeze"
tt.aura.radius = 195
tt.aura.cycles_count = 1
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
tt = E:register_t("mod_teleport_high_elven", "mod_teleport_mage")
tt.fx_start = "fx_teleport_blue"
tt.fx_end = "fx_teleport_blue"
tt = E:register_t("mod_blood_elves", "mod_blood")
tt.modifier.allows_duplicates = true
tt.modifier.max_of_same = 5
tt.modifier.source_damage = nil
tt.modifier.type = MOD_TYPE_BLEED
tt.chance = 0.15
tt.damage_factor = 0.1
tt.dps.damage_every = fts(4)
tt.dps.damage_inc = 0
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.fx_every = fts(12)
tt.main_script.insert = kr3_scripts.mod_blood_elves.insert
tt = E:register_t("mod_shocking_impact", "mod_slow")
tt.modifier.duration = 0.5
tt.slow.factor = 0.5

for _, n in pairs({
	"barrack_1",
	"barrack_2",
	"barrack_3",
	"blade",
	"forest",
	"drow"
}) do
	tt = E:register_t("mod_moon_forged_blades_" .. n, "mod_damage")
	tt.damage_max = math.ceil(0.15 * E:get_template("soldier_" .. n).melee.attacks[1].damage_min)
	tt.damage_min = math.ceil(0.15 * E:get_template("soldier_" .. n).melee.attacks[1].damage_max)
	tt.damage_type = DAMAGE_MAGICAL
end

tt = E:register_t("mod_teleport_faustus", "mod_teleport")
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.modifier.vis_bans = bor(F_BOSS)
tt.max_times_applied = nil
tt.nodes_offset = -35
tt.nodeslimit = 10
tt.delay_start = fts(2)
tt.hold_time = 0.4
tt.delay_end = fts(2)
tt.fx_start = "fx_teleport_faustus"
tt.fx_end = "fx_teleport_faustus"
tt = E:register_t("mod_enervation_faustus", "modifier")

E:add_comps(tt, "render", "tween")

tt.main_script.insert = kr3_scripts.mod_silence.insert
tt.main_script.remove = kr3_scripts.mod_silence.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.modifier.duration = nil
tt.render.sprites[1].prefix = "mod_enervation_faustus"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.25,
		255
	}
}
tt = E:register_t("mod_liquid_fire_faustus", "modifier")

E:add_comps(tt, "dps", "render")

tt.dps.damage_max = nil
tt.dps.damage_min = nil
tt.dps.damage_type = bor(DAMAGE_TRUE, DAMAGE_MODIFIER)
tt.dps.damage_every = fts(6)
tt.dps.kill = true
tt.main_script.insert = kr3_scripts.mod_dps.insert
tt.main_script.update = kr3_scripts.mod_dps.update
tt.modifier.duration = 1
tt.render.sprites[1].prefix = "mod_liquid_fire_faustus"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[1].draw_order = 10
tt = E:register_t("mod_minidragon_faustus", "mod_liquid_fire_faustus")
tt = E:register_t("mod_bravebark_branchball", "modifier")

E:add_comps(tt, "render")

tt.main_script.queue = kr3_scripts.mod_bravebark_branchball.queue
tt.main_script.update = kr3_scripts.mod_bravebark_branchball.update
tt.custom_anchors = {}
tt.custom_anchors.default = v(0.5, 0.45)
tt.render.sprites[1].name = "bravebark_paralyzeRoots"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].anchor.y = 0.22727272727272727
tt = E:register_t("mod_bravebark_ultimate", "mod_shock_and_awe")
tt.modifier.duration = 1
tt = E:register_t("mod_bravebark_springsap", "modifier")

E:add_comps(tt, "hps", "render", "tween")

tt.modifier.use_mod_offset = false
tt.modifier.duration = 3 * fts(3)
tt.modifier.bans = {
	"mod_son_of_mactans_poison",
	"mod_drider_poison",
	"mod_dark_spitters",
	"mod_balrog"
}
tt.modifier.remove_banned = true
tt.hps.heal_min = nil
tt.hps.heal_max = nil
tt.hps.heal_every = fts(3)
tt.main_script.insert = kr3_scripts.mod_bravebark_springsap.insert
tt.main_script.update = kr3_scripts.mod_hps.update
tt.render.sprites[1].name = "bravebark_hero_healFx"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.1
tt.render.sprites[1].sort_y_offset = -1
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.15,
		255
	}
}
tt = E:register_t("mod_xin_stun", "mod_shock_and_awe")
tt.modifier.duration = 1.3
tt = E:register_t("mod_xin_inspire", "modifier")

E:add_comps(tt, "render")

tt.modifier.duration = nil
tt.modifier.use_mod_offset = false
tt.inflicted_damage_factor = 2
tt.main_script.insert = kr3_scripts.mod_damage_factors.insert
tt.main_script.remove = kr3_scripts.mod_damage_factors.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.render.sprites[1].name = "mod_xin_inspire"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("mod_xin_mind_over_body", "modifier")

E:add_comps(tt, "render", "hps")

tt.hps.heal_min = nil
tt.hps.heal_max = nil
tt.hps.heal_every = nil
tt.main_script.insert = kr3_scripts.mod_hps.insert
tt.main_script.update = kr3_scripts.mod_hps.update
tt.modifier.duration = nil
tt.modifier.use_mod_offset = false
tt.render.sprites[1].name = "fx_xin_drink_bubbles"
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "xin_hero_drink_decal"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt = RT("mod_catha_curse", "mod_stun")
tt.main_script.insert = kr3_scripts.mod_catha_curse.insert
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.vis_flags = bor(F_STUN, F_MOD)
tt.modifier.duration = nil
tt.modifier.resets_same = false
tt.render.sprites[1].keep_flip_x = true
tt.render.sprites[1].size_names = nil
tt.render.sprites[1].prefix = "mod_catha_curse"
tt.render.sprites[1].name = "loop"
tt.chance = 0
tt.xp_from_skill = "curse"
tt = RT("mod_soldier_catha_curse", "mod_catha_curse")
tt.xp_from_skill = nil
tt = RT("mod_catha_ultimate", "mod_catha_curse")
tt.main_script.insert = kr3_scripts.mod_stun.insert
tt.modifier.vis_bans = 0
tt.xp_from_skill = nil
tt = RT("mod_catha_soul", "modifier")

AC(tt, "render", "hps")

tt.hps.heal_every = 9e+99
tt.hps.heal_max = nil
tt.hps.heal_min = nil
tt.main_script.insert = kr3_scripts.mod_hps.insert
tt.main_script.update = kr3_scripts.mod_hps.update
tt.modifier.duration = fts(25)
tt.modifier.bans = {
	"mod_son_of_mactans_poison",
	"mod_drider_poison",
	"mod_dark_spitters",
	"mod_balrog"
}
tt.modifier.remove_banned = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "mod_catha_soul"
tt.render.sprites[1].anchor.y = 0.2631578947368421
tt = RT("mod_veznan_ultimate_stun", "mod_stun")
tt.modifier.duration = 2
tt = RT("mod_veznan_demon_fire", "modifier")

E:add_comps(tt, "render")

tt.main_script.insert = kr3_scripts.mod_track_target.insert
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.modifier.duration = fts(29)
tt.modifier.resets_same = true
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {
	"small",
	"medium",
	"large"
}
tt.render.sprites[1].draw_order = 10
tt = RT("mod_veznan_arcanenova", "mod_slow")
tt.modifier.duration = 2
tt.slow.factor = 0.5
tt = RT("mod_veznan_shackles_stun", "mod_stun")
tt.render.sprites[1].prefix = "veznan_hero_shackles"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[1].name = "start"
tt.render.sprites[1].size_anchors = {
	v(0.5, 0.7222222222222222),
	v(0.5, 0.5483870967741935),
	v(0.5, 0.4838709677419355)
}
tt.modifier.animation_phases = true
tt.modifier.duration = 3
tt = RT("mod_veznan_shackles_dps", "modifier")

AC(tt, "dps")

tt.modifier.duration = 3
tt.dps.damage_min = 2
tt.dps.damage_max = 2
tt.dps.damage_every = fts(5)
tt.dps.damage_type = DAMAGE_TRUE
tt.main_script.insert = kr3_scripts.mod_dps.insert
tt.main_script.update = kr3_scripts.mod_dps.update
tt = RT("mod_baby_malik_stun", "mod_stun")
tt = RT("mod_rag_raggified", "modifier")
tt.main_script.update = kr3_scripts.mod_rag_raggified.update
tt.modifier.bans = {
	"mod_twilight_avenger_last_service"
}
tt.modifier.remove_banned = true
tt.entity_name = "soldier_rag"
tt.fx = "fx_rag_raggified"
tt.doll_duration = nil
tt = RT("mod_rag_hammer_time_stun", "mod_stun")
tt.modifier.duration = 2
tt.modifier.vis_bans = F_BOSS
tt = RT("mod_durax_slow", "mod_slow")
tt.modifier.duration = fts(15)
tt.slow.factor = 0.9
tt = RT("mod_durax_stun", "mod_stun")
tt.modifier.duration = fts(20)
tt.modifier.vis_bans = F_BOSS
tt = RT("mod_lilith_angel_stun", "mod_stun")
tt.modifier.duration = fts(34)
tt = RT("mod_lilith_soul_eater_track", "modifier")
tt.main_script.update = kr3_scripts.mod_lilith_soul_eater_track.update
tt.modifier.duration = fts(11)
tt = RT("mod_lilith_soul_eater_damage_factor", "modifier")

AC(tt, "render", "tween")

tt.inflicted_damage_factor = nil
tt.soul_eater_factor = nil
tt.modifier.duration = 12
tt.modifier.use_mod_offset = false
tt.main_script.insert = kr3_scripts.mod_damage_factors.insert
tt.main_script.remove = kr3_scripts.mod_damage_factors.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.render.sprites[1].name = "lilith_soul_eater_decal_loop"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fallen_angel_hero_soul_eater_sword"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(0, 12)
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].offset = v(-18, 22)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].offset = v(18, 22)
tt.tween.remove = false
tt.tween.props[1] = CC("tween_prop")
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.3,
		255
	},
	{
		"this.modifier.duration-0.3",
		255
	},
	{
		"this.modifier.duration",
		0
	}
}

for i = 2, 4 do
	tt.tween.props[i] = table.deepclone(tt.tween.props[1])
	tt.tween.props[i].sprite_id = i
end

tt.tween.props[5] = CC("tween_prop")
tt.tween.props[5].name = "anchor"
tt.tween.props[5].keys = {
	{
		0,
		v(0.5, 0.6538461538461539)
	},
	{
		fts(12),
		v(0.5, 0.34615384615384615)
	},
	{
		fts(24),
		v(0.5, 0.6538461538461539)
	}
}
tt.tween.props[5].loop = true
tt.tween.props[5].interp = "sine"
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[5])
tt.tween.props[6].sprite_id = 3
tt.tween.props[7] = table.deepclone(tt.tween.props[5])
tt.tween.props[7].sprite_id = 4
tt = RT("mod_lilith_infernal_wheel", "mod_lava")
tt.modifier.duration = fts(31)
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(10)
tt = RT("mod_bruce_sharp_claws", "mod_blood_elves")
tt.modifier.allows_duplicates = true
tt.modifier.replaces_lower = false
tt.modifier.resets_same = false
tt.modifier.duration = 5
tt.main_script.insert = kr3_scripts.mod_bruce_sharp_claws.insert
tt.dps.damage_every = fts(11)
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.extra_bleeding_damage = nil
tt.xp_from_skill = "sharp_claws"
tt = RT("mod_bruce_kings_roar", "mod_stun")
tt.modifier.duration = nil
tt.modifier.vis_bans = F_BOSS
tt.modifier.health_bar_offset = v(0, -3)
tt.modifier.use_mod_offset = false
tt.render.sprites[1].prefix = "mod_bruce_kings_roar"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].size_names = nil
tt = RT("mod_lion_bruce_stun", "mod_stun")
tt.modifier.duration = 3
tt.modifier.animation_phases = true
tt.modifier.use_mod_offset = false
tt.render.sprites[1].size_names = nil
tt.render.sprites[1].anchor.y = 0.0975609756097561
tt.render.sprites[1].prefix = "bruce_ultimate_twister"
tt.sound_events.insert_args = {
	ignore = 1
}
tt.sound_events.insert = {
	"ElvesHeroBruceGuardianLionsLoopStart",
	"ElvesHeroBruceGuardianLionsLoop"
}
tt.sound_events.remove_stop = "ElvesHeroBruceGuardianLionsLoop"
tt.sound_events.remove = "ElvesHeroBruceGuardianLionsLoopEnd"
tt = RT("mod_lion_bruce_damage", "modifier")

AC(tt, "dps", "mark_flags")

tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_every = fts(10)
tt.dps.damage_type = DAMAGE_TRUE
tt.mark_flags.vis_bans = F_CUSTOM
tt.modifier.duration = 3
tt.main_script.insert = kr3_scripts.mod_dps.insert
tt.main_script.update = kr3_scripts.mod_dps.update
tt.main_script.queue = kr3_scripts.mod_mark_flags.queue
tt.main_script.dequeue = kr3_scripts.mod_mark_flags.dequeue
tt = RT("mod_lynn_ultimate", "modifier")

AC(tt, "dps", "render", "tween", "dps")

tt.render.sprites[1].name = "mod_lynn_ultimate"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "mod_lynn_ultimate_decal_loop"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "mod_lynn_ultimate_over"
tt.render.sprites[3].draw_order = 10
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.3,
		255
	},
	{
		"this.modifier.duration-0.3",
		255
	},
	{
		"this.modifier.duration",
		0
	}
}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 3
tt.tween.remove = false
tt.main_script.insert = kr3_scripts.mod_lynn_ultimate.insert
tt.main_script.update = kr3_scripts.mod_lynn_ultimate.update
tt.modifier.allows_duplicates = true
tt.modifier.vis_flags = bor(F_MOD, F_RANGED)
tt.modifier.vis_bans = 0
tt.modifier.duration = 5
tt.modifier.health_bar_offset = v(0, 10)
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_every = fts(15)
tt.dps.damage_type = DAMAGE_TRUE
tt.explode_fx = "fx_lynn_explosion"
tt.explode_range = 75
tt.explode_damage = nil
tt.explode_damage_type = DAMAGE_TRUE
tt.explode_vis_flags = F_RANGED
tt.explode_vis_bans = 0
tt = RT("mod_lynn_curse", "modifier")
tt.modifier.chance = 0.25
tt.modifier.duration = 2
tt.main_script.insert = kr3_scripts.mod_lynn_curse.insert
tt.main_script.update = kr3_scripts.mod_lynn_curse.update
tt = RT("mod_lynn_despair", "modifier")

AC(tt, "tween", "render")

tt.modifier.health_bar_offset = v(0, 11)
tt.modifier.duration = 8
tt.speed_factor = 0.5
tt.inflicted_damage_factor = 0.7
tt.main_script.insert = kr3_scripts.mod_lynn_despair.insert
tt.main_script.remove = kr3_scripts.mod_lynn_despair.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.render.sprites[1].name = "mod_lynn_despair"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "mod_lynn_despair_decal_loop"
tt.render.sprites[2].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.3,
		255
	},
	{
		"this.modifier.duration-0.3",
		255
	},
	{
		"this.modifier.duration",
		0
	}
}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt = RT("mod_lynn_weakening", "modifier")

AC(tt, "tween", "render")

tt.armor_reduction = 0.7
tt.magic_armor_reduction = 0.7
tt.main_script.insert = kr3_scripts.mod_lynn_weakening.insert
tt.main_script.remove = kr3_scripts.mod_lynn_weakening.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.modifier.duration = 8
tt.modifier.health_bar_offset = v(0, 11)
tt.render.sprites[1].name = "mod_lynn_weakening"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "mod_lynn_weakening_decal_loop"
tt.render.sprites[2].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.3,
		255
	},
	{
		"this.modifier.duration-0.3",
		255
	},
	{
		"this.modifier.duration",
		0
	}
}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt = RT("mod_phoenix_egg", "mod_lava")
tt.modifier.duration = 2
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(6)
tt = RT("mod_phoenix_flaming_path", "modifier")

AC(tt, "custom_attack", "render", "tween")

tt.main_script.update = kr3_scripts.mod_phoenix_flaming_path.update
tt.modifier.duration = 6.5
tt.custom_attack = CC("custom_attack")
tt.custom_attack.damage = nil
tt.custom_attack.cooldown = 2
tt.custom_attack.fx = "decal_phoenix_flaming_path_pulse"
tt.custom_attack.fx_start = "fx_flaming_path_start"
tt.custom_attack.fx_end = "fx_flaming_path_end"
tt.custom_attack.hit_time = 0.1
tt.custom_attack.mod = "mod_veznan_demon_fire"
tt.custom_attack.radius = 125
tt.custom_attack.damage_type = DAMAGE_TRUE
tt.custom_attack.sound = "ElvesHeroPhoenixRingOfFireExplode"
tt.custom_attack.vis_flags = F_RANGED
tt.custom_attack.vis_bans = F_FLYING
tt.custom_offsets = {}
tt.custom_offsets.tower_pixie = v(0, -10)
tt.render.sprites[1].name = "phoenix_hero_towerBurn_towerFx"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.19166666666666668
tt.render.sprites[1].offset.y = -5
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_flaming_path_fire"
tt.render.sprites[2].anchor.y = 0.19166666666666668
tt.render.sprites[2].offset.y = -5
tt.render.sprites[2].draw_order = 20
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		v(1, 1)
	},
	{
		0.5,
		v(1.05, 1.05)
	},
	{
		1,
		v(1, 1)
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		0
	},
	{
		0.3,
		255
	},
	{
		"this.modifier.duration-0.3",
		255
	},
	{
		"this.modifier.duration",
		0
	}
}
tt.tween.props[3] = table.deepclone(tt.tween.props[2])
tt.tween.props[3].sprite_id = 2
tt = RT("mod_phoenix_purification", "modifier")
tt.modifier.duration = fts(11)
tt.fx = "fx_ray_phoenix_hit"
tt.entity = "missile_phoenix_small"
tt.main_script.update = kr3_scripts.mod_phoenix_purification.update
tt = RT("mod_bolverk_scream", "modifier")

AC(tt, "render")

tt.received_damage_factor = 1.5
tt.modifier.duration = 20
tt.modifier.resets_same = false
tt.modifier.use_mod_offset = false
tt.main_script.insert = kr3_scripts.mod_damage_factors.insert
tt.main_script.remove = kr3_scripts.mod_damage_factors.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.render.sprites[1].prefix = "mod_weakness"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("mod_gnoll_burner", "modifier")

E:add_comps(tt, "dps", "render", "mark_flags")

tt.dps.damage_min = 4
tt.dps.damage_max = 4
tt.dps.damage_type = bor(DAMAGE_TRUE, DAMAGE_MODIFIER)
tt.dps.damage_every = fts(12)
tt.dps.kill = true
tt.mark_flags.vis_bans = F_CUSTOM
tt.main_script.queue = kr3_scripts.mod_mark_flags.queue
tt.main_script.dequeue = kr3_scripts.mod_mark_flags.dequeue
tt.main_script.insert = kr3_scripts.mod_dps.insert
tt.main_script.update = kr3_scripts.mod_dps.update
tt.modifier.duration = 2
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {
	"small",
	"medium",
	"large"
}
tt.render.sprites[1].draw_order = 10
tt = E:register_t("mod_gnoll_gnawer", "modifier")

E:add_comps(tt, "render")

tt.modifier.duration = fts(10)
tt.modifier.use_mod_offset = false
tt.inflicted_damage_factor = 1.5
tt.main_script.insert = kr3_scripts.mod_damage_factors.insert
tt.main_script.remove = kr3_scripts.mod_damage_factors.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.render.sprites[1].name = "mod_gnoll_gnawer"
tt.render.sprites[1].anchor = v(0.5, 0.28125)
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("mod_gnoll_blighter", "modifier")

E:add_comps(tt, "render", "tween")

tt.main_script.update = kr3_scripts.mod_gnoll_blighter.update
tt.modifier.duration = 4.9
tt.render.sprites[1].name = "mod_gnoll_blighter"
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor.y = 0.28
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].draw_order = 10
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.3,
		255
	},
	{
		tt.modifier.duration - 0.3,
		255
	},
	{
		tt.modifier.duration,
		0
	}
}
tt.tween.remove = false
tt = E:register_t("mod_twilight_elf_harasser", "modifier")

E:add_comps(tt, "mark_flags")

tt.mark_flags.vis_bans = F_CUSTOM
tt.main_script.queue = kr3_scripts.mod_mark_flags.queue
tt.main_script.dequeue = kr3_scripts.mod_mark_flags.dequeue
tt.main_script.update = kr3_scripts.mod_mark_flags.update
tt.modifier.duration = fts(20)
tt = E:register_t("mod_redcap_heal", "modifier")

E:add_comps(tt, "hps")

tt.main_script.insert = kr3_scripts.mod_redcap_heal.insert
tt.main_script.update = kr3_scripts.mod_hps.update
tt.hps.heal_min = 25
tt.hps.heal_max = 25
tt.hps.heal_every = fts(3)
tt.modifier.duration = 2
tt.hit_fx = "fx_redcap_death_blow"
tt = E:register_t("mod_twilight_avenger_last_service", "modifier")

E:add_comps(tt, "render")

tt.modifier.duration = -1
tt.render.sprites[1].prefix = "mod_twilight_avenger_last_service"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 10
tt.main_script.insert = kr3_scripts.mod_track_target.insert
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.main_script.remove = kr3_scripts.mod_twilight_avenger_last_service.remove
tt.explode_fx = "fx_twilight_avenger_explosion"
tt.explode_range = 60
tt.explode_damage = 80
tt.explode_vis_bans = bor(F_DARK_ELF, F_BOSS)
tt.explode_vis_flags = F_RANGED
tt.explode_excluded_templates = {
	"hero_regson"
}
tt = E:register_t("mod_twilight_scourger_lash", "modifier")

E:add_comps(tt, "render")

tt.render.sprites[1].prefix = "mod_twilight_scourger_lash"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "scourger_buff_glow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].sort_y_offset = 1
tt.modifier.duration = 5
tt.modifier.use_mod_offset = true
tt.main_script.insert = kr3_scripts.mod_twilight_scourger_lash.insert
tt.main_script.remove = kr3_scripts.mod_twilight_scourger_lash.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.speed_factor = 1.4
tt.damage_factor = 2
tt = E:register_t("mod_twilight_scourger_banshee", "modifier")

E:add_comps(tt, "render", "tween")

tt.main_script.update = kr3_scripts.mod_twilight_scourger_banshee.update
tt.modifier.hide_tower = false
tt.modifier.duration = 10
tt.render.sprites[1].name = "mod_twilight_scourger_banshee_base"
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].anchor.y = 0.05
tt.render.sprites[1].offset.y = -10
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].sort_y_offset = -2
tt.render.sprites[2].anchor = v(0.9545454545454546, 0.5)
tt.render.sprites[2].offset.y = 21
tt.render.sprites[2].name = "mod_twilight_scourger_banshee_fx"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].scale = v(-1, 1)
tt.render.sprites[3].time_offset = fts(6)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].offset.y = 48
tt.render.sprites[5] = table.deepclone(tt.render.sprites[4])
tt.render.sprites[5].scale = v(-1, 1)
tt.render.sprites[5].time_offset = fts(6)
tt.tween.remove = false

for i = 1, 5 do
	local p = E:clone_c("tween_prop")

	p.keys = {
		{
			0,
			0
		},
		{
			0.2,
			255
		},
		{
			"this.modifier.duration-0.2",
			255
		},
		{
			"this.modifier.duration",
			0
		}
	}
	p.sprite_id = i
	tt.tween.props[i] = p
end

tt = E:register_t("mod_spider_web", "modifier")

E:add_comps(tt, "render")

tt.main_script.insert = kr3_scripts.mod_spider_web.insert
tt.main_script.update = kr3_scripts.mod_stun.update
tt.main_script.remove = kr3_scripts.mod_stun.remove
tt.modifier.animation_phases = true
tt.modifier.bans = {
	"mod_dark_spitters"
}
tt.modifier.remove_banned = true
tt.modifier.duration = 3
tt.modifier.duration_heroes = 2
tt.modifier.hide_target_delay = fts(5)
tt.modifier.use_mod_offset = false
tt.render.sprites[1].prefix = "mod_spider_web"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor = v(0.5, 0.14285714285714285)
tt.modifier.custom_scales = {}
tt.modifier.custom_scales.default = vv(0.55)
tt.modifier.custom_scales.hero_elves_denas = vv(0.75)
tt.modifier.custom_scales.hero_bravebark = vv(1)
tt.modifier.custom_scales.hero_xin = vv(1)
tt.modifier.custom_scales.soldier_forest = vv(0.75)
tt.modifier.custom_scales.soldier_druid_bear = vv(0.75)
tt = E:register_t("mod_mactans_spider_web", "mod_spider_web")
tt.modifier.duration = 5
tt.modifier.duration_heroes = 3
tt = E:register_t("mod_drider_poison", "modifier")

E:add_comps(tt, "render", "dps")

tt.modifier.duration = 10
tt.modifier.vis_flags = bor(F_MOD, F_DRIDER_POISON)
tt.render.sprites[1].name = "mod_drider_poison"
tt.main_script.insert = kr3_scripts.mod_dps.insert
tt.main_script.update = kr3_scripts.mod_drider_poison.update
tt.dps.damage_every = fts(7)
tt.dps.damage_max = 2
tt.dps.damage_min = 2
tt.dps.damage_type = DAMAGE_POISON
tt = E:register_t("mod_razorboar_rampage_enemy", "modifier")

E:add_comps(tt, "dps", "render")

tt.dps.damage_min = 125
tt.dps.damage_max = 155
tt.dps.damage_every = fts(30)
tt.modifier.duration = fts(25)
tt.modifier.use_mod_offset = true
tt.render.sprites[1].name = "mod_razorboar_rampage"
tt.render.sprites[1].anchor.y = 0.34
tt.main_script.insert = kr3_scripts.mod_dps.insert
tt.main_script.update = kr3_scripts.mod_dps.update
tt = E:register_t("mod_razorboar_rampage_soldier", "mod_razorboar_rampage_enemy")
tt.dps.damage_min = 80
tt.dps.damage_max = 120
tt = E:register_t("mod_razorboar_rampage_speed", "modifier")
tt.modifier.duration = 1.2
tt.speed_factor = 2.818181818181818
tt.main_script.insert = kr3_scripts.mod_razorboar_rampage_speed.insert
tt.main_script.remove = kr3_scripts.mod_razorboar_rampage_speed.remove
tt.main_script.update = kr3_scripts.mod_razorboar_rampage_speed.update
tt = E:register_t("mod_son_of_mactans_poison", "mod_poison")
tt.dps.damage_every = fts(4)
tt.dps.damage_max = 6
tt.dps.damage_min = 6
tt.dps.kill = true
tt.modifier.duration = 3
tt = RT("mod_spider_sprint", "mod_slow")
tt.slow.factor = 2
tt.modifier.duration = fts(12)
tt = RT("mod_mactans_tower_block", "modifier")

AC(tt, "render", "tween")

tt.main_script.update = kr3_scripts.mod_mactans_tower_block.update
tt.modifier.duration = 5

for i = 1, 4 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].anchor.y = 0.18461538461538463
	tt.render.sprites[i].draw_order = 10
	tt.render.sprites[i].sort_y_offset = -2
	tt.render.sprites[i].name = "mactans_towerWebs_000" .. i
	tt.render.sprites[i].animated = false
	tt.tween.props[i] = CC("tween_prop")
	tt.tween.props[i].keys = {
		{
			fts(17) * (i - 1),
			0
		},
		{
			fts(17) * i,
			255
		}
	}
	tt.tween.props[i].sprite_id = i
end

tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].anchor.y = 0.18461538461538463
tt.render.sprites[5].draw_order = 10
tt.render.sprites[5].sort_y_offset = -2
tt.render.sprites[5].prefix = "mod_mactans_tower_block"
tt.render.sprites[5].name = "end"
tt.render.sprites[5].hidden = true
tt.tween.remove = false
tt = RT("mod_ogre_magi_shield", "modifier")

AC(tt, "render")

tt.modifier.duration = 6
tt.modifier.deflect_factor = 0.5
tt.main_script.insert = kr3_scripts.mod_ogre_magi_shield.insert
tt.main_script.remove = kr3_scripts.mod_ogre_magi_shield.remove
tt.main_script.update = kr3_scripts.mod_ogre_magi_shield.update
tt.fx_cooldown = fts(10)
tt.last_fx_ts = 0
tt.source_vis_flags = F_RANGED
tt.render.sprites[1].name = "ogre_mage_shield_damage"
tt.render.sprites[1].loop = false
tt.render.sprites[1].ts = -10
tt.render.sprites[1].size_scales = {
	vv(0.8),
	vv(1),
	vv(1)
}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = 0.05555555555555555
tt.render.sprites[2].animated = false
tt.render.sprites[2].draw_order = 5
tt.render.sprites[2].name = "ogre_mage_shield"
tt = RT("mod_dark_spitters", "modifier")

AC(tt, "render", "dps")

tt.explode_fx = "fx_unit_explode"
tt.modifier.duration = 3 - fts(11)
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt.nodes_limit = 20
tt.spawn_entity = "enemy_shadows_spawns"
tt.render.sprites[1].name = "mod_dark_spitters"
tt.render.sprites[1].draw_order = 10
tt.main_script.insert = kr3_scripts.mod_dps.insert
tt.main_script.update = kr3_scripts.mod_dark_spitters.update
tt.dps.damage_every = fts(11)
tt.dps.damage_max = 10
tt.dps.damage_min = 10
tt.dps.damage_type = DAMAGE_POISON
tt = RT("mod_shadow_champion", "mod_gnoll_boss")
tt.main_script.insert = kr3_scripts.mod_shadow_champion.insert
tt.main_script.remove = kr3_scripts.mod_shadow_champion.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.modifier.duration = 120
tt.inflicted_damage_factor = 1.2
tt.heal_factor = 1
tt = RT("mod_balrog", "mod_dark_spitters")
tt.modifier.duration = 5 - fts(11)
tt = RT("mod_snare_hee_haw", "mod_spider_web")
tt.render.sprites[1].prefix = "mod_snare_hee_haw"
tt.render.sprites[1].anchor = v(0.5, 0.295)
tt.modifier.hide_target_delay = nil
tt.modifier.custom_scales = {}
tt.modifier.custom_scales.default = vv(0.5)
tt.modifier.custom_scales.hero_elves_denas = v(0.7)
tt.modifier.custom_scales.hero_bravebark = vv(1)
tt.modifier.custom_scales.hero_xin = vv(1)
tt.modifier.custom_scales.soldier_forest = vv(0.7)
tt.modifier.custom_scales.soldier_druid_bear = vv(0.7)
tt = RT("mod_twilight_brute", "modifier")

AC(tt, "render", "tween")

tt.inflicted_damage_factor = 1.25
tt.main_script.insert = kr3_scripts.mod_damage_factors.insert
tt.main_script.remove = kr3_scripts.mod_damage_factors.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.modifier.duration = 3
tt.modifier.use_mod_offset = false
tt.modifier.resets_same_tween = true
tt.modifier.resets_same_tween_offset = fts(10)
tt.render.sprites[1].name = "mod_twilight_bannerbearer"
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		255
	},
	{
		"this.modifier.duration-(10/30)",
		255
	},
	{
		"this.modifier.duration",
		0
	}
}
tt = RT("mod_teleport_ainyl", "mod_teleport")
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.max_times_applied = nil
tt.delay_start = fts(2)
tt.hold_time = 0.4
tt.delay_end = fts(2)
tt.fx_start = "fx_teleport_scroll"
tt.fx_end = "fx_teleport_scroll"
tt = RT("mod_block_tower_ainyl", "modifier")

AC(tt, "render", "tween")

tt.main_script.update = kr3_scripts.mod_block_tower_ainyl.update
tt.modifier.hide_tower = false
tt.modifier.duration = 10
tt.render.sprites[1].name = "ainyl_block_decal"
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].anchor.y = 0.28125
tt.render.sprites[1].offset.y = -8
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].sort_y_offset = -2
tt.render.sprites[2].anchor = v(0.9655172413793104, 0.5)
tt.render.sprites[2].offset.y = 21
tt.render.sprites[2].name = "ainyl_block_fx"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].scale = v(-1, 1)
tt.render.sprites[3].time_offset = fts(6)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].offset.y = 48
tt.render.sprites[4].hidden = true
tt.render.sprites[5] = table.deepclone(tt.render.sprites[4])
tt.render.sprites[5].scale = v(-1, 1)
tt.render.sprites[5].time_offset = fts(6)
tt.tween.remove = false

for i = 1, 5 do
	local p = E:clone_c("tween_prop")

	p.keys = {
		{
			0,
			0
		},
		{
			0.2,
			255
		},
		{
			"this.modifier.duration-0.2",
			255
		},
		{
			"this.modifier.duration",
			0
		}
	}
	p.sprite_id = i
	tt.tween.props[i] = p
end

tt = RT("mod_shield_ainyl", "modifier")

AC(tt, "render")

tt.modifier.duration = nil
tt.main_script.insert = kr3_scripts.mod_damage_factors.insert
tt.main_script.remove = kr3_scripts.mod_damage_factors.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.received_damage_factor = 0.001
tt.render.sprites[1].prefix = "ainyl_shield"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].anchor.y = 0.4
tt = E:register_t("mod_ray_crystal_arcane", "modifier")

E:add_comps(tt, "dps")

tt.modifier.duration = fts(16)
tt.dps.damage_every = fts(4)
tt.dps.damage_min = 150 / (tt.modifier.duration / tt.dps.damage_every)
tt.dps.damage_max = 200 / (tt.modifier.duration / tt.dps.damage_every)
tt.dps.damage_type = bor(DAMAGE_TRUE, DAMAGE_MODIFIER)
tt.dps.kill = false
tt.main_script.insert = kr3_scripts.mod_dps.insert
tt.main_script.update = kr3_scripts.mod_dps.update
tt = E:register_t("mod_crystal_arcane_freeze", "mod_freeze")

E:add_comps(tt, "render")

tt.modifier.duration = 4
tt.modifier.vis_bans = F_BOSS
tt.render.sprites[1].prefix = "freeze_creep"
tt.render.sprites[1].sort_y_offset = -2
tt.custom_offsets = {}
tt.custom_offsets.flying = v(-5, 28)
tt.custom_offsets.enemy_gloomy = v(-5, 22)
tt.custom_offsets.enemy_mantaray = v(-5, 16)
tt.custom_offsets.enemy_perython_rock_thrower = v(-5, 46)
tt.custom_offsets.enemy_perython_gnoll_gnawer = v(-5, 46)
tt.custom_suffixes = {}
tt.custom_suffixes.flying = "_air"
tt.custom_animations = {
	"start",
	"end"
}
tt = E:register_t("mod_crystal_arcane_buff", "modifier")

E:add_comps(tt, "render", "tween")

tt.damage_factor = 1.75
tt.modifier.duration = 5
tt.main_script.insert = kr3_scripts.mod_tower_factors.insert
tt.main_script.remove = kr3_scripts.mod_tower_factors.remove
tt.main_script.update = kr3_scripts.mod_tower_factors.update
tt.render.sprites[1].name = "crystalArcane_towerBuff_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.11666666666666667
tt.render.sprites[1].z = Z_TOWER_BASES + 1

local offsets = {
	nil,
	v(-30, 10),
	v(-10, 0),
	v(10, 0),
	v(30, 10)
}

for i = 2, 5 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].name = "fx_crystal_arcane_tower"
	tt.render.sprites[i].anchor.y = 0.11666666666666667
	tt.render.sprites[i].sort_y_offset = -2
	tt.render.sprites[i].offset = offsets[i]
	tt.render.sprites[i].flip_x = i >= 4
	tt.tween.props[i] = E:clone_c("tween_prop")
	tt.tween.props[i].keys = {
		{
			0,
			0
		},
		{
			0.3,
			255
		},
		{
			"this.modifier.duration-0.3",
			255
		},
		{
			"this.modifier.duration",
			0
		}
	}
	tt.tween.props[i].sprite_id = i
end

tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		vv(1)
	},
	{
		0.5,
		vv(1.15)
	},
	{
		1,
		vv(1)
	}
}
tt.tween.props[1].loop = true
tt.tween.props[6] = E:clone_c("tween_prop")
tt.tween.props[6].keys = {
	{
		0,
		0
	},
	{
		0.3,
		255
	},
	{
		"this.modifier.duration-0.3",
		255
	},
	{
		"this.modifier.duration",
		0
	}
}
tt = E:register_t("mod_crystal_arcane_buff_soldier", "modifier")

E:add_comps(tt, "render")

tt.main_script.insert = kr3_scripts.mod_damage_factors.insert
tt.main_script.remove = kr3_scripts.mod_damage_factors.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.inflicted_damage_factor = 1.75
tt.modifier.duration = 5
tt.modifier.use_mod_offset = false
tt.render.sprites[1].name = "decal_crystal_arcane_soldier_base"
tt.render.sprites[1].anchor.y = 0.23529411764705882
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "decal_crystal_arcane_soldier_bubbles"
tt.render.sprites[2].anchor.y = 0.23529411764705882
tt.render.sprites[2].sort_y_offset = -1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "fx_crystal_arcane_soldier"
tt.render.sprites[3].anchor.y = 0.17647058823529413
tt.render.sprites[3].sort_y_offset = -1
tt.render.sprites[3].loop = false
tt = RT("mod_crystal_unstable_teleport", "mod_teleport")
tt.delay_start = fts(5)
tt.delay_end = fts(5)
tt.fx_start = "fx_teleport_out_crystal_unstable"
tt.fx_end = "fx_teleport_in_crystal_unstable"
tt.hold_time = fts(16)
tt.max_times_applied = nil
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT, F_RANGED)
tt.modifier.vis_bans = bor(F_BOSS)
tt.nodes_offset = -10
tt = RT("mod_crystal_unstable_infuse", "mod_bloodsydian_warlock")
tt = RT("mod_crystal_unstable_heal", "modifier")

AC(tt, "hps", "render")

tt.hps.heal_every = 1000000000
tt.hps.heal_max = 200
tt.hps.heal_min = 200
tt.main_script.insert = kr3_scripts.mod_hps.insert
tt.main_script.update = kr3_scripts.mod_hps.update
tt.modifier.duration = fts(25)
tt.modifier.use_mod_offset = true
tt.modifier.vis_flags = bor(F_MOD, F_RANGED)
tt.modifier.vis_bans = bor(F_BOSS)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "fx_heal_crystal_unstable"
tt = RT("mactans_controller")

AC(tt, "main_script")

tt.main_script.insert = kr3_scripts.mactans_controller.insert
tt.main_script.update = kr3_scripts.mactans_controller.update
tt.sequence = nil
tt.sequence_groups = nil
tt = E:register_t("power_thunder_control")

E:add_comps(tt, "user_power", "pos", "main_script", "user_selection")

tt.cooldown = 70
tt.flash_delay_max = 0.3
tt.flash_delay_min = 0.1
tt.flash_duration_max = 0.15
tt.flash_duration_min = 0.1
tt.flash_l1_max_alphas = {
	0,
	0
}
tt.flash_l2_max_alpha = 70
tt.flash_l2_min_alpha = 60
tt.flash_delta = 0.02
tt.main_script.update = kr3_scripts.power_thunder_control.update
tt.nodes_spread = 10
tt.rain = {}
tt.rain.alpha_max = 255
tt.rain.alpha_min = 150
tt.rain.angle_between = 2 * math.pi / 180
tt.rain.angle_max = -60 * math.pi / 180
tt.rain.angle_min = -80 * math.pi / 180
tt.rain.cooldown = 0.1
tt.rain.count = 20
tt.rain.delay_max = 0.2
tt.rain.disabled = true
tt.rain.distance_max = 550
tt.rain.distance_min = 450
tt.rain.duration = 0.2
tt.rain.ts = 0
tt.slow = {}
tt.slow.cooldown = 0.24
tt.slow.disabled = true
tt.slow.mod = "mod_power_thunder_slow"
tt.slow.range = 9999
tt.slow.ts = 0
tt.thunders = {
	{},
	{}
}
tt.thunders[1].cooldown = 0
tt.thunders[1].count = 3
tt.thunders[1].created = 0
tt.thunders[1].damage_max = 90
tt.thunders[1].damage_min = 50
tt.thunders[1].damage_radius = 100
tt.thunders[1].damage_type = DAMAGE_TRUE
tt.thunders[1].delay_max = 0.4
tt.thunders[1].delay_min = 0.2
tt.thunders[1].pop = {
	"pop_lightning1",
	"pop_lightning2",
	"pop_lightning3"
}
tt.thunders[1].pop_chance = 0.3
tt.thunders[1].range = 150
tt.thunders[1].targeting = "nearest"
tt.thunders[1].ts = 0
tt.thunders[2] = table.deepclone(tt.thunders[1])
tt.thunders[2].count = 0
tt.thunders[2].pop = nil
tt.thunders[2].range = 9999
tt.thunders[2].targeting = "random"
tt.user_selection.can_select_point_fn = kr3_scripts.power_thunder_control.can_select_point
tt.vis_bans = bor(F_FRIEND)
tt.vis_flags = bor(F_RANGED)
tt = E:register_t("mod_power_thunder_slow", "mod_slow")
tt.modifier.duration = 0.25
tt.slow.factor = 0.4
tt = E:register_t("fx_power_thunder_1", "decal_tween")

E:add_comps(tt, "sound_events")

tt.image_h = 496
tt.render.sprites[1].name = "ray_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(3),
		255
	},
	{
		fts(8),
		0
	}
}
tt.sound_events.insert = "CommonLightning"
tt = E:register_t("fx_power_thunder_2", "fx_power_thunder_1")
tt.image_h = 456
tt.render.sprites[1].name = "ray_0002"
tt = E:register_t("fx_power_thunder_explosion", "fx")
tt.render.sprites[1].name = "fx_power_thunder_explosion_half"
tt.render.sprites[1].anchor.y = 0.15714285714285714
tt.render.sprites[1].sort_y_offset = -5
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].flip_x = true
tt = E:register_t("fx_power_thunder_explosion_decal", "fx")
tt.render.sprites[1].name = "decal_power_thunder_explosion"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("overlay_power_thunder_flash", "decal_tween")

E:add_comps(tt, "tween")

image_y = 64
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "square_ffffff"
tt.render.sprites[1].scale = v(math.ceil(REF_H * 16 / 9 * 1.1 / image_y), math.ceil(REF_H / image_y))
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].alpha = 0
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "square_b8b8b8"
tt.render.sprites[2].alpha = 0
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt.ts = 0
tt.cooldown = 0
tt = E:register_t("fx_power_thunder_drop", "fx")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "lightning_storm_rain_drop"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.x = 1
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t("fx_power_thunder_rain_splash", "fx")
tt.render.sprites[1].name = "fx_power_thunder_rain_splash"
tt = E:register_t("power_hero_control")

E:add_comps(tt, "user_power", "pos", "main_script", "user_selection")

tt.main_script.insert = kr3_scripts.power_hero_control.insert
tt.user_selection.can_select_point_fn = kr3_scripts.power_hero_control.can_select_point

-- E:set_template("user_power_1", E:get_template("power_thunder_control"))
-- E:set_template("user_power_2", E:get_template("power_reinforcements_control"))
-- E:set_template("user_power_3", E:get_template("power_hero_control"))

tt = RT("user_item_teleport_scroll", "user_item")

AC(tt, "aura", "render", "tween", "sound_events")

tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt.aura.mod = "mod_teleport_scroll"
tt.aura.cycle_time = 1000000000
tt.aura.duration = fts(30)
tt.aura.radius = 35
tt.aura.targets_per_cycle = 10
tt.aura.vis_flags = bor(F_RANGED, F_TELEPORT)
tt.aura.vis_bans = bor(F_FRIEND, F_HERO, F_FREEZE)
tt.aura.targets_per_cycle = nil
tt.render.sprites[1].name = "decal_user_power_teleport"

for i, o in ipairs({
	v(-20, 26),
	v(-4, 36),
	v(19, 29),
	v(-24, -3),
	v(-3, 6),
	v(26, 6),
	v(-11, -15),
	v(4, -15)
}) do
	tt.render.sprites[i + 1] = CC("sprite")
	tt.render.sprites[i + 1].name = "fx_user_power_teleport_bubbles"
	tt.render.sprites[i + 1].offset = o
	tt.render.sprites[i + 1].loop = false
	tt.render.sprites[i + 1].hide_after_runs = 1
	tt.render.sprites[i + 1].scale = math.random() < 0.5 and v(-1, 1) or v(1, 1)
	tt.render.sprites[i + 1].anchor.y = 0.078125
end

tt.sound_events.insert = "ElvesInAppTeleportScroll"
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		55
	},
	{
		fts(5),
		255
	},
	{
		fts(15),
		255
	},
	{
		fts(20),
		0
	},
	{
		fts(30),
		0
	}
}
tt = RT("mod_teleport_scroll", "mod_teleport")
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.max_times_applied = nil
tt.boss_nodes_offset = -20
tt.nodes_offset = -35
tt.nodeslimit = 10
tt.delay_start = fts(2)
tt.hold_time = 0.4
tt.delay_end = fts(2)
tt.fx_start = "fx_teleport_scroll"
tt.fx_end = "fx_teleport_scroll"
tt = RT("fx_teleport_scroll", "fx")
tt.render.sprites[1].name = "fx_user_power_teleport"
tt.render.sprites[1].size_scales = {
	vv(0.8),
	vv(1),
	vv(1.5)
}
tt = RT("user_item_gem_timewarp", "user_item")

AC(tt, "aura", "sound_events")

tt.main_script.update = kr3_scripts.user_item_gem_timewarp.update
tt.aura.custom_fx = "fx_gem_timewarp_bubble"
tt.aura.mod_teleport = "mod_teleport_gem"
tt.aura.mod_slow = "mod_slow_gem"
tt.aura.duration = fts(30)
tt.aura.radius = 1e+99
tt.aura.vis_flags = bor(F_RANGED, F_TELEPORT)
tt.aura.vis_bans = bor(F_FRIEND, F_HERO, F_FREEZE)
tt.aura.extra_slow_duration_random = {
	0,
	2
}
tt.aura.extra_slow_duration_per_clamped_node = 0.3
tt.sound_events.insert = "ElvesInAppTeleportGemEnemiesOut"
tt = RT("mod_teleport_gem", "mod_teleport_scroll")
tt.hold_time = 0.3
tt.boss_nodes_offset = -35
tt.nodes_offset = -50
tt.nodeslimit = 0
tt = RT("mod_slow_gem", "mod_slow")
tt.modifier.duration = 10
tt.slow.factor = 0.5
tt = RT("fx_gem_timewarp_bubble", "fx")

for i, o in ipairs({
	v(-20, 26),
	v(-4, 36),
	v(19, 29),
	v(-24, -3),
	v(-3, 6),
	v(26, 6),
	v(-11, -15),
	v(4, -15)
}) do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].name = "fx_user_power_teleport_bubbles"
	tt.render.sprites[i].offset = o
	tt.render.sprites[i].loop = false
	tt.render.sprites[i].hide_after_runs = 1
	tt.render.sprites[i].scale = math.random() < 0.5 and v(-1, 1) or v(1, 1)
	tt.render.sprites[i].anchor.y = 0.078125
end

tt = RT("user_item_wrath_of_elynia", "user_item")

AC(tt, "aura", "sound_events")

tt.main_script.update = kr3_scripts.user_item_wrath_of_elynia.update
tt.aura.mod_slow = "mod_slow_elynia"
tt.aura.mod_kill = "mod_kill_elynia"
tt.aura.radius = REF_W * 1.5
tt.aura.spread_speed = 1200
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.vis_bans = bor(F_FRIEND, F_HERO)
tt.sound_events.insert = "ElvesInAppTearOfElynie"
tt = RT("mod_slow_elynia", "mod_slow")
tt.modifier.duration = 10
tt.slow.factor = 0.7
tt = RT("mod_kill_elynia", "modifier")
tt.main_script.queue = kr3_scripts.mod_kill_elynia.queue
tt.main_script.update = kr3_scripts.mod_kill_elynia.update
tt.modifier.damage_boss = 3000
tt = RT("decal_elynia_ray", "decal_tween")
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "elynia_ray"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = 0
tt.render.sprites[2].name = "square_ffffff"
tt.render.sprites[2].animated = false
tt.render.sprites[2].scale = v(0.1875, 5.953125)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].anchor.y = 0.40625
tt.render.sprites[3].name = "decal_elynia_ray_hit"
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 1)
	},
	{
		fts(4),
		v(1, 1)
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		v(0.046875, 5.953125)
	},
	{
		fts(2),
		v(0.09375, 5.953125)
	},
	{
		fts(4),
		v(0.046875, 5.953125)
	}
}
tt.tween.props[2].loop = true
tt = RT("decal_elynia_big_explosion", "decal_tween")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "elynia_explosion_ring"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "elynia_base"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "elynia_sphere"
tt.render.sprites[3].offset.y = 16
tt.render.sprites[3].z = Z_EFFECTS
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].animated = false
tt.render.sprites[4].name = "elynia_sphere_border"
tt.render.sprites[4].offset.y = 16
tt.render.sprites[4].z = Z_EFFECTS
tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].animated = false
tt.render.sprites[5].name = "elynia_boom"
tt.render.sprites[5].offset.y = 10
tt.render.sprites[5].z = Z_EFFECTS

for _, d in pairs({
	{
		v(6, 12),
		2
	},
	{
		v(-30, 36),
		4
	},
	{
		v(13, -41),
		6
	},
	{
		v(-31, 45),
		8
	}
}) do
	local s = CC("sprite")

	s.hide_after_runs = 1
	s.loop = false
	s.name = "fx_elynia_particle"
	s.offset.x, s.offset.y = d[1].x, d[1].y
	s.scale = vv(1.2)
	s.time_offset = -1 * fts(d[2])

	table.insert(tt.render.sprites, s)
end

tt.tween.remove = true
tt.tween.props = {
	{
		name = "alpha",
		sprite_id = 1,
		keys = {
			{
				0,
				255
			},
			{
				fts(17),
				0
			}
		}
	},
	{
		name = "scale",
		sprite_id = 1,
		keys = {
			{
				0,
				vv(1)
			},
			{
				fts(17),
				vv(4.7)
			}
		}
	},
	{
		name = "alpha",
		sprite_id = 2,
		keys = {
			{
				0,
				255
			},
			{
				fts(26),
				0
			}
		}
	},
	{
		name = "alpha",
		sprite_id = 3,
		keys = {
			{
				0,
				255
			},
			{
				fts(22),
				0
			}
		}
	},
	{
		name = "scale",
		sprite_id = 3,
		keys = {
			{
				0,
				vv(1)
			},
			{
				fts(22),
				vv(2.1)
			}
		}
	},
	{
		name = "alpha",
		sprite_id = 4,
		keys = {
			{
				0,
				255
			},
			{
				fts(17),
				255
			},
			{
				fts(22),
				0
			}
		}
	},
	{
		name = "scale",
		sprite_id = 4,
		keys = {
			{
				0,
				vv(1)
			},
			{
				fts(22),
				vv(2.1)
			}
		}
	},
	{
		name = "alpha",
		sprite_id = 5,
		keys = {
			{
				0,
				255
			},
			{
				fts(16),
				0
			}
		}
	},
	{
		name = "scale",
		sprite_id = 5,
		keys = {
			{
				0,
				vv(1)
			},
			{
				fts(16),
				vv(3.5)
			}
		}
	}
}
tt = RT("fx_elynia_creep_explosion", "decal_tween")
tt.render.sprites[1].name = "elynia_creepExplosion_glowDecal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_wrath_of_elynia_creep_explosion"
tt.render.sprites[2].anchor.y = 0.34615384615384615
tt.render.sprites[2].loop = false
tt.tween.remove = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(25),
		0
	}
}
tt = RT("fx_elynia_creep_ashes", "decal_tween")
tt.render.sprites[1].name = "fx_wrath_of_elynia_creep_explosion_ashes"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0.2076923076923077
tt.tween.remove = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(25) + 1,
		255
	},
	{
		fts(25) + 1.2,
		0
	}
}
tt = RT("user_item_horn_heroism", "user_item")

AC(tt, "aura", "mod_attack", "sound_events", "render", "tween")

tt.main_script.update = kr3_scripts.user_item_horn_heroism.update
tt.aura.mod = "mod_horn_heroism_soldier"
tt.aura.radius = 250
tt.aura.max_soldiers = 10
tt.aura.vis_flags = bor(F_RANGED)
tt.mod_attack.max_range = 250
tt.mod_attack.min_range = 0
tt.mod_attack.max_towers = 10
tt.mod_attack.mod = "mod_horn_heroism_tower"
tt.sound_events.insert = "ElvesInAppHornOfHeroism"
tt.sound_events.insert_args = {
	delay = fts(17)
}
tt.render.sprites[1].name = "hornOfHeroism_guy_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = 0.1111111111111111
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].loop = false
tt.render.sprites[2].name = "decal_horn_heroism_guy_layer1"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].name = "decal_horn_heroism_guy_layer2"
tt.tween.remove = false
tt.tween.props = {
	{
		name = "alpha",
		sprite_id = 1,
		keys = {
			{
				fts(12),
				0
			},
			{
				fts(13),
				255
			},
			{
				fts(29),
				0
			}
		}
	},
	{
		name = "scale",
		sprite_id = 1,
		keys = {
			{
				fts(13),
				vv(1)
			},
			{
				fts(29),
				vv(2.7)
			}
		}
	}
}
tt = RT("mod_horn_heroism_soldier", "modifier")

AC(tt, "render", "tween")

tt.modifier.duration = 10
tt.modifier.use_mod_offset = false
tt.modifier.resets_same_tween = true
tt.immune_to = DAMAGE_BASE_TYPES
tt.inflicted_damage_factor = 2
tt.main_script.insert = kr3_scripts.mod_horn_heroism_soldier.insert
tt.main_script.remove = kr3_scripts.mod_horn_heroism_soldier.remove
tt.main_script.update = kr3_scripts.mod_track_target.update
tt.render.sprites[1].name = "mod_horn_heroism_soldier"
tt.render.sprites[1].anchor.y = 0.15384615384615385
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		255
	},
	{
		10 - fts(10),
		255
	},
	{
		10,
		0
	}
}
tt = RT("mod_horn_heroism_tower", "modifier")

AC(tt, "render", "tween")

tt.modifier.duration = 15
tt.modifier.resets_same_tween = true
tt.main_script.insert = kr3_scripts.mod_tower_factors.insert
tt.main_script.remove = kr3_scripts.mod_tower_factors.remove
tt.main_script.update = kr3_scripts.mod_tower_factors.update
tt.damage_factor = 2
tt.render.sprites[1].name = "mod_horn_heroism_tower_left"
tt.render.sprites[1].anchor.y = 0.14285714285714285
tt.render.sprites[1].draw_order = 20
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].flip_x = true
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "hornOfHeroism_towerBuff_topDeco"
tt.render.sprites[3].animated = false
tt.render.sprites[3].anchor.y = 0.14285714285714285
tt.render.sprites[3].draw_order = 20
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "mod_horn_heroism_tower_flame"
tt.render.sprites[4].anchor.y = 0.14285714285714285
tt.render.sprites[4].draw_order = 20
tt.tween.props = {
	{
		loop = true,
		name = "alpha",
		sprite_id = {
			1,
			2,
			3,
			4
		},
		keys = {
			{
				0,
				255
			},
			{
				fts(10),
				200
			},
			{
				fts(20),
				255
			}
		}
	},
	{
		loop = true,
		name = "scale",
		sprite_id = {
			1,
			2,
			3,
			4
		},
		keys = {
			{
				0,
				vv(1)
			},
			{
				fts(10),
				vv(1.05)
			},
			{
				fts(20),
				vv(1)
			}
		}
	},
	{
		name = "alpha",
		multiply = true,
		sprite_id = {
			1,
			2,
			3,
			4
		},
		keys = {
			{
				0,
				0
			},
			{
				fts(10),
				1
			},
			{
				15 - fts(10),
				1
			},
			{
				15,
				0
			}
		}
	}
}
tt = RT("user_item_rod_dragon_fire", "user_item")

AC(tt, "aura", "render", "attacks")

tt.aura.duration = 10
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].cooldown = 0.6
tt.attacks.list[1].bullet = "bullet_rod_dragon_fire"
tt.attacks.list[1].bullet_start_offset = v(0, 63)
tt.attacks.list[1].node_prediction = 0.5
tt.attacks.list[1].range = 175
tt.main_script.update = kr3_scripts.user_item_rod_dragon_fire.update
tt.render.sprites[1].anchor.y = 0.058333333333333334
tt.render.sprites[1].prefix = "rod_dragon_fire"
tt.render.sprites[1].name = "start"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = 0.058333333333333334
tt.render.sprites[2].name = "rod_dragon_fire_flame"
tt.render.sprites[2].hidden = true
tt.user_selection.can_select_point_fn = kr3_scripts.user_item_rod_dragon_fire.can_select_point
tt = E:register_t("bullet_rod_dragon_fire", "fireball_arivan")
tt.bullet.damage_max = 320
tt.bullet.damage_min = 100
tt.bullet.damage_radius = 55
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_bullet_rod_dragon_fire_hit"
tt.bullet.particles_name = "ps_bullet_rod_dragon_fire"
tt.idle_time = 0
tt.render.sprites[1].prefix = "bullet_rod_dragon_fire"
tt.sound_events.hit = "ElvesInAppRodDragon"
tt = RT("fx_bullet_rod_dragon_fire_hit", "fx")
tt.render.sprites[1].name = "bullet_rod_dragon_fire_explosion"
tt.render.sprites[1].anchor.y = 0.19791666666666666
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("user_item_hand_midas", "user_item")
tt.gold_bonus_factor = 1
tt.duration = 35
tt.user_selection.can_select_point_fn = kr3_scripts.user_item_hand_midas.can_select_point
tt.main_script.update = kr3_scripts.user_item_hand_midas.update
tt = E:register_t("decal_water_sparks", "decal_loop")
tt.render.sprites[1].name = "decal_water_sparks_idle"
tt = E:register_t("decal_water_sparks_small", "decal_loop")
tt.render.sprites[1].name = "decal_water_sparks_idle"
tt.render.sprites[1].scale = v(0.6, 0.6)
tt = E:register_t("decal_jumping_fish", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_fish"
tt.render.sprites[1].name = "jump"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS + 1
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 10
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "jump"
tt = E:register_t("decal_water_wave_delayed_2", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_water_wave_2"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS
tt.delayed_play.min_delay = 1
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "play"
tt = E:register_t("decal_water_wave_1", "decal_loop")
tt.render.sprites[1].name = "decal_water_wave_1_play"
tt = E:register_t("decal_water_wave_2", "decal_loop")
tt.render.sprites[1].name = "decal_water_wave_2_play"
tt = E:register_t("decal_water_wave_3", "decal_loop")
tt.render.sprites[1].name = "decal_water_wave_3_play"
tt = E:register_t("decal_water_wave_4", "decal_loop")
tt.render.sprites[1].name = "decal_water_wave_4_play"
tt = E:register_t("decal_water_splash", "decal_loop")
tt.render.sprites[1].name = "decal_water_splash_play"
tt = E:register_t("decal_stage01_gandalf", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_gandalf"
tt.render.sprites[1].name = "idle"
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 15
tt.delayed_play.idle_animation = "idle"
tt.delayed_play.play_animation = "smoke"
tt = E:register_t("decal_stage01_bird1", "decal_delayed_play")

E:add_comps(tt, "tween")

tt = E:register_t("decal_bird_1", "decal_tween")
tt.render.sprites[1].prefix = "decal_bird_1"
tt.render.sprites[1].name = "play"
tt.tween.remove = true
tt.tween.props[1].name = "offset"
tt = E:register_t("decal_bird_2", "decal_bird_1")
tt.render.sprites[1].prefix = "decal_bird_2"
tt = E:register_t("birds_controller")

E:add_comps(tt, "main_script")

tt.main_script.update = kr3_scripts.birds_controller.update
tt.origins = {}
tt.destinations = {}
tt.bird_templates = {
	"decal_bird_1",
	"decal_bird_2"
}
tt.delay = {
	20,
	40
}
tt.batch_count = 2
tt.batch_delay = {
	1,
	5
}
tt.fly_speed = 116
tt = E:register_t("decal_stage_02_waterfall_1", "decal")
tt.render.sprites[1].name = "decal_stage_02_waterfall_1_idle"
tt = E:register_t("decal_stage_02_waterfall_2", "decal")
tt.render.sprites[1].name = "decal_stage_02_waterfall_2_idle"
tt = E:register_t("decal_stage_02_waterfall_3", "decal")
tt.render.sprites[1].name = "decal_stage_02_waterfall_3_idle"
tt = E:register_t("decal_stage_02_waterfall_4", "decal")
tt.render.sprites[1].name = "decal_stage_02_waterfall_4_idle"
tt = E:register_t("decal_stage_02_bigwaves", "decal")
tt.render.sprites[1].name = "decal_stage_02_bigwaves_idle"

for i = 1, 6 do
	tt = E:register_t("decal_stage_02_stone_" .. i, "decal")
	tt.render.sprites[1].name = "stage2_stones_000" .. i
	tt.render.sprites[1].animated = false
end

tt = E:register_t("decal_stage_02_bridge_mask", "decal")
tt.render.sprites[1].name = "stage2_bridge"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_stage_02_bridge_shadows", "decal")
tt.render.sprites[1].name = "stage2_shadows"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_bambi", "decal_scripted")

E:add_comps(tt, "ui", "motion")

tt.render.sprites[1].prefix = "decal_bambi"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0.1
tt.main_script.update = kr3_scripts.decal_bambi.update
tt.ui.can_click = true
tt.ui.click_rect = r(-15, 0, 30, 30)
tt.ui.can_select = false
tt.run_offset = nil
tt.motion.max_speed = 99.9
tt = E:register_t("decal_rabbit", "decal_scripted")

E:add_comps(tt, "ui", "tween")

tt.render.sprites[1].prefix = "decal_rabbit"
tt.render.sprites[1].name = "ears"
tt.render.sprites[1].loop = false
tt.ui.can_click = true
tt.ui.click_rect = r(-20, -20, 40, 30)
tt.ui.can_select = false
tt.main_script.update = kr3_scripts.decal_rabbit.update
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.25,
		255
	}
}
tt.tween.ts = 0
tt.ani_sequence = {
	{
		"ears",
		5,
		15
	},
	{
		"popout",
		1,
		3,
		"hide1"
	},
	{
		"travel1",
		1,
		3,
		"hide2"
	},
	{
		"travel2",
		1.5,
		3,
		"hide3"
	},
	{
		"travel3",
		1,
		3,
		"hide1"
	},
	{
		"hide1"
	},
	{
		nil,
		10,
		20
	}
}
tt = E:register_t("decal_s03_bridge", "decal_static")

E:add_comps(tt, "ui")

tt.ui.click_rect = r(-83, -48, 166, 96)
tt.ui.can_select = false
tt.render.sprites[1].name = "stage3_bridge"
tt.render.sprites[1].z = Z_DECALS + 2
tt.render.sprites[1].sort_y_offset = 48
tt = E:register_t("decal_crane", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "decal_crane"
tt.render.sprites[1].name = "idle"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "decal_crane_fx"
tt.render.sprites[2].loop = true
tt.render.sprites[2].draw_order = -1
tt.ui.click_rect = r(-20, -40, 40, 40)
tt.ui.can_select = false
tt.main_script.update = kr3_scripts.decal_crane.update
tt.play_animation = "play"
tt.click_animation = "click"
tt.final_click_animation = "final_click"
tt.play_time = {
	10,
	45
}
tt.final_clicks = {
	3,
	6
}
tt = E:register_t("river_object_controller")

E:add_comps(tt, "main_script")

tt.main_script.update = kr3_scripts.river_object_controller.update
tt.river_objects = {
	"barrel",
	"barrel",
	"chest",
	"wilson",
	"submarine"
}
tt.min_time = 12
tt.max_time = 24
tt.max_chests = 3
tt.max_hobbits = 13
tt = E:register_t("decal_river_object", "decal_scripted")

E:add_comps(tt, "nav_path", "motion", "ui", "tween", "sound_events")

tt.main_script.update = kr3_scripts.decal_river_object.update
tt.motion.max_speed = 1.5 * FPS
tt.ui.click_rect = r(-18, -5, 36, 36)
tt.ui.can_select = false
tt.ui.z = -1
tt.render.sprites[1].z = Z_DECALS + 1
tt.nav_path.pi = 5
tt.nav_path.spi = 1
tt.nav_path.ni = 1
tt.sink_nodes = 5
tt.falls = 1
tt.fall_time = 0.5
tt.fall_wait = 0.6
tt.fall_1_tween = {
	{
		0,
		255
	},
	{
		0.4,
		255
	},
	{
		0.5,
		0
	}
}
tt.travel_2_tween = {
	{
		0,
		0
	},
	{
		1,
		255
	}
}
tt.tween.disabled = true
tt.tween.remove = false
tt.sound_events.fall = "ElvesWaterfallStrong"
tt = E:register_t("decal_river_object_hobbit", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_hobbit"
tt.render.sprites[1].anchor.y = 0.2818181818181818
tt.falls = 2
tt.sink_nodes = nil
tt.achievement_inc = "DWARF_FALL"
tt.sound_events.save = "ElvesAchievementHobbit"
tt.sound_events.crash = "ElvesAchievementDwarfFall"
tt = E:register_t("decal_river_object_barrel", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_barrel"
tt.render.sprites[1].anchor.y = 0.45454545454545453
tt.sound_events.save = "ElvesWaterfallMid"
tt = E:register_t("decal_river_object_chest", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_chest"
tt.render.sprites[1].anchor.y = 0.20588235294117646
tt.gold = 20
tt.sound_events.save = "ElvesGoldCoin"
tt = E:register_t("decal_river_object_wilson", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_wilson"
tt.render.sprites[1].anchor.y = 0.1527777777777778
tt.sound_events.save = "ElvesAchievementWilson"
tt = E:register_t("decal_river_object_submarine", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_submarine"
tt.render.sprites[1].anchor.y = 0.20454545454545456
tt.sound_events.save = "ElvesAchievementYellowSubmarine"
tt = E:register_t("fx_waterfall_splash", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_waterfall_splash"
tt.render.sprites[1].anchor.y = 0.21875
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_events.insert = "ElvesWaterfallMid"
tt = E:register_t("decal_s04_land_1", "decal_background")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "Stage04_0003"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.editor.game_mode = 1
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.26,
		0
	}
}
tt = E:register_t("decal_s04_land_2", "decal_s04_land_1")
tt.render.sprites[1].name = "Stage04_0004"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_s04_tree_burn", "decal_timed")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "decal_s04_tree_burn"
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].scale = v(1, 1)
tt.timed.disabled = true
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {
	{
		"render.sprites[1].scale",
		PT_COORDS
	},
	{
		"editor.game_mode",
		PT_NUMBER
	},
	{
		"editor.tag",
		PT_NUMBER
	}
}
tt = E:register_t("decal_s04_charcoal_1", "decal_tween")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "stage4_fire_decal_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = v(1, 1)
tt.render.sprites[1].z = Z_BACKGROUND + 1
tt.tween.disabled = true
tt.tween.remove = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.4,
		255
	},
	{
		1.7,
		0
	}
}
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {
	{
		"render.sprites[1].scale",
		PT_COORDS
	},
	{
		"editor.game_mode",
		PT_NUMBER
	},
	{
		"editor.tag",
		PT_NUMBER
	}
}
tt = E:register_t("decal_s04_charcoal_2", "decal_s04_charcoal_1")
tt.render.sprites[1].name = "stage4_fire_decal_0002"
tt = E:register_t("decal_s04_charcoal_3", "decal_s04_charcoal_1")
tt.render.sprites[1].name = "stage4_fire_decal_0003"
tt = E:register_t("decal_gnoll_burner", "decal")
tt.render.sprites[1].anchor = v(0.5, 0.21428571428571427)
tt.render.sprites[1].prefix = "gnoll_burner"
tt.render.sprites[1].name = "idle"
tt = E:register_t("fx_torch_gnoll_burner_explosion_stage04", "fx")
tt.render.sprites[1].name = "fx_torch_gnoll_burner_explosion_stage04"
tt = E:register_t("fx_s04_tree_fire_1", "decal_timed")

E:add_comps(tt, "editor")

tt.timed.disabled = true
tt.render.sprites[1].name = "fx_s04_tree_fire_1"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_EFFECTS
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {
	{
		"render.sprites[1].r",
		PT_NUMBER,
		math.pi / 180
	},
	{
		"editor.game_mode",
		PT_NUMBER
	},
	{
		"editor.tag",
		PT_NUMBER
	}
}
tt.editor.overrides = {
	["render.sprites[1].hidden"] = false,
	["render.sprites[1].loop"] = true
}
tt = E:register_t("fx_s04_tree_fire_2", "fx_s04_tree_fire_1")
tt.render.sprites[1].name = "fx_s04_tree_fire_2"
tt = E:register_t("decal_george_jungle", "decal_scripted")

E:add_comps(tt, "ui", "tween")

tt.main_script.update = kr3_scripts.decal_george_jungle.update
tt.render.sprites[1].anchor.y = 1
tt.render.sprites[1].prefix = "decal_george_jungle_liana"
tt.render.sprites[1].r = 50 * math.pi / 180
tt.render.sprites[1].offset = v(768, 830)
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "decal_george_jungle"
tt.render.sprites[2].name = "fall"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].offset = v(566, 457)
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y = 343
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "decal_george_jungle_bush"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].anchor.y = 0
tt.render.sprites[3].offset = v(553, 296)
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[3].sort_y = 296
tt.final_clicks = {
	3,
	5
}
tt.play_time = {
	3,
	5
}
tt.ui.click_rect = r(0, 0, 200, 120)
tt.ui.can_select = false
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].name = "r"
tt.tween.props[1].keys = {
	{
		0,
		50 * math.pi / 180
	},
	{
		0.3,
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {
	{
		0
	},
	{
		0.3
	}
}
tt.achievement = "GEORGE_FALL"
tt = E:register_t("decal_tree_ewok", "decal_scripted")

E:add_comps(tt, "motion", "nav_path", "ranged", "unit", "health")

tt.main_script.update = kr3_scripts.decal_tree_ewok.update
tt.render.sprites[1].anchor.y = 0.08333333333333333
tt.render.sprites[1].prefix = "decal_tree_ewok"
tt.ranged.attacks[1].min_range = 150
tt.ranged.attacks[1].max_range = 300
tt.ranged.attacks[1].bullet = "spear_tree_ewok"
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 15)
}
tt.wait_time = 5
tt.dance_animations = {
	"dance1",
	"dance2"
}
tt.ranged_center = v(550, 380)
tt.motion.max_speed = 45
tt = E:register_t("spear_tree_ewok", "arrow")
tt.bullet.damage_max = 10
tt.bullet.damage_max = 10
tt.bullet.hit_chance = 0.4
tt.bullet.miss_decal = "ewok_2_proy_0002"
tt.bullet.flight_time = fts(33)
tt.bullet.prediction_error = false
tt.render.sprites[1].name = "ewok_2_proy_0001"
tt.sound_events.insert = "AxeSound"
tt = E:register_t("tower_ewok_holder")

E:add_comps(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "editor", "editor_script")

tt.tower.type = "holder_ewok"
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.info.i18n_key = "ELVES_EWOK_TOWER"
tt.info.fn = kr3_scripts.tower_ewok_holder.get_info
tt.info.portrait = (IS_PHONE and "portraits_towers" or "info_portraits_towers") .. "_0013"
tt.render.sprites[1].name = "terrains_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "ewok_hut_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(0, 32)
tt.ui.click_rect = r(-40, -10, 80, 90)
tt.ui.has_nav_mesh = true
tt.editor.props = {
	{
		"tower.terrain_style",
		PT_NUMBER
	},
	{
		"tower.default_rally_pos",
		PT_COORDS
	},
	{
		"tower.holder_id",
		PT_STRING
	},
	{
		"ui.nav_mesh_id",
		PT_STRING
	},
	{
		"editor.game_mode",
		PT_NUMBER
	}
}
tt.editor_script.insert = kr3_scripts.editor_tower.insert
tt.editor_script.remove = kr3_scripts.editor_tower.remove
tt = E:register_t("decal_s05_tree_round", "decal")
tt.render.sprites[1].name = "stage5_tree"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.13953488372093023
tt = E:register_t("decal_s05_tree_pine", "decal")
tt.render.sprites[1].name = "stage5_pine"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.08333333333333333
tt = E:register_t("decal_bush_statue", "decal_scripted")

E:add_comps(tt, "ui")

tt.main_script.insert = kr3_scripts.decal_bush_statue.insert
tt.main_script.update = kr3_scripts.decal_bush_statue.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage5_bushes_0001"
tt.render.sprites[1].anchor.y = 0.1744186046511628
tt.bush_frame_prefix = "stage5_bushes_"
tt.bush_frames = {
	"0001",
	"0002",
	"0003",
	"0004",
	"0005",
	"0006",
	"0007"
}
tt.bush_indexes = nil
tt.bush_idx = nil
tt.ui.click_rect = r(-40, 0, 80, 66)
tt.ui.can_select = false
tt = E:register_t("fx_bush_statue_click", "fx")

E:add_comps(tt, "sound_events")

tt.render.sprites[1].name = "fx_bush_statue_click"
tt.render.sprites[1].offset.y = 34
tt.sound_events.insert = "ElvesAchievementScissorFingers"
tt = E:register_t("decal_s06_eagle", "decal_delayed_sequence")

E:add_comps(tt, "editor")

tt.delayed_sequence.animations = {
	"1",
	"2",
	"3",
	"4"
}
tt.delayed_sequence.random = true
tt.delayed_sequence.max_delay = 3
tt.render.sprites[1].prefix = "decal_s06_eagle"
tt.render.sprites[1].name = "1"
tt.render.sprites[1].z = Z_OBJECTS + 1
tt = E:register_t("decal_s06_boxed_boss", "decal_delayed_play")

E:add_comps(tt, "editor")

tt.delayed_play.min_delay = 5
tt.delayed_play.min_delay = 10
tt.render.sprites[1].prefix = "decal_s06_boxed_boss_l1"
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "decal_s06_boxed_boss_l2"
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "decal_s06_boxed_boss_l3"
tt.render.sprites[3].z = Z_OBJECTS + 1
tt = E:register_t("decal_s06_jailed_boss", "decal")

for i = 1, 6 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "decal_s06_jailed_boss_l" .. i
	tt.render.sprites[i].name = "walk"
	tt.render.sprites[i].anchor.y = 0.26373626373626374
end

tt.render.sprites[6].sort_y_offset = -10
tt = E:register_t("soldier_gryphon_guard", "soldier_barrack_1")

E:add_comps(tt, "ranged")

tt.health.hp_max = 1
tt.health.immune_to = DAMAGE_ALL_TYPES
tt.health_bar = nil
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.range = 0
tt.motion.max_speed = 75
tt.ranged.attacks[1].bullet = "arrow_soldier_gryphon_guard"
tt.ranged.attacks[1].bullet_start_offset = {
	v(5, 10)
}
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].max_range = 1000
tt.ranged.attacks[1].min_range = 1
tt.ranged.attacks[1].shoot_time = fts(7)
tt.render.sprites[1].prefix = "soldier_gryphon_guard"
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.ui = nil
tt.unit.hit_offset = v(0, 10)
tt.unit.level = 1
tt.unit.mod_offset = v(0, 21)
tt.vis.bans = bor(tt.vis.bans, F_RANGED)
tt.vis.bans = bor(F_BLOCK, F_RANGED)
tt = E:register_t("arrow_soldier_gryphon_guard", "arrow")
tt.bullet.damage_max = 10
tt.bullet.damage_min = 10
tt.bullet.flight_time = fts(12)
tt.bullet.reset_to_target_pos = true
tt = E:register_t("soldier_gryphon_guard_upper", "soldier_gryphon_guard")

E:add_comps(tt, "auras")

tt.ranged.attacks[1].filter_fn = kr3_scripts.soldier_gryphon_guard.upper_ranged_filter_fn
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_soldier_gryphon_guard_upper"
tt.auras.list[1].cooldown = 0
tt = E:register_t("soldier_gryphon_guard_lower", "soldier_gryphon_guard")

E:add_comps(tt, "auras", "tween")

tt.ranged.attacks[1].filter_fn = kr3_scripts.soldier_gryphon_guard.lower_ranged_filter_fn
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_soldier_gryphon_guard_lower"
tt.auras.list[1].cooldown = 0
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.25,
		255
	},
	{
		0.5,
		255
	}
}
tt.render.sprites[1].alpha = 0
tt = E:register_t("aura_soldier_gryphon_guard_upper", "aura")
tt.main_script.update = kr3_scripts.aura_soldier_gryphon_guard_upper.update
tt.aura.duration = -1
tt.patch_cooldown_min = fts(20)
tt.patch_cooldown_max = fts(35)
tt = E:register_t("aura_soldier_gryphon_guard_lower", "aura")
tt.main_script.update = kr3_scripts.aura_soldier_gryphon_guard_lower.update
tt.hide_pos = v(459, 563)
tt.show_pos = v(440, 550)
tt.hidden_max = 3
tt.hidden_min = 1
tt.idle_time_to_hide = 5
tt = E:register_t("decal_gryphon", "decal_scripted")

E:add_comps(tt, "attacks", "ui", "sound_events")

tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].cooldown = fts(3)
tt.attacks.list[1].bullet = "bullet_gryphon"
tt.attacks.list[1].loops = 3
tt.attacks.list[1].bullet_start_offset = v(102, -22)
tt.main_script.update = kr3_scripts.decal_gryphon.update
tt.render.sprites[1].prefix = "gryphon_l1"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].group = "layers"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "gryphon_l2"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].group = "layers"
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "ally_gryphon_0000"
tt.render.sprites[3].alpha = 60
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].hidden = true
tt.render.sprites[4].loop = false
tt.render.sprites[4].name = "gryphon_attack_flash"
tt.ui.click_rect = r(-40, -106, 80, 100)
tt.ui.can_select = false
tt.ui.can_click = true
tt.custom = {
	left = {},
	right = {}
}
tt.custom.left.initial_duration = 4.6
tt.custom.left.default_duration = 4
tt.custom.left.approach_duration = 0.7
tt.custom.left.attack_ranges = {
	{
		-50,
		500
	}
}
tt.custom.left.initial_curve_id = 5
tt.custom.left.default_curve_id = 6
tt.custom.left.land_curve_id = 7
tt.custom.right.initial_duration = 5
tt.custom.right.default_duration = 4.5
tt.custom.right.approach_duration = 0.7
tt.custom.right.attack_ranges = {
	{
		1050,
		750
	},
	{
		600,
		200
	}
}
tt.custom.right.initial_curve_id = 8
tt.custom.right.default_curve_id = 9
tt.custom.right.land_curve_id = 10
tt = E:register_t("bullet_gryphon", "bullet")
tt.main_script.update = kr3_scripts.bullet_gryphon.update
tt.render.sprites[1].name = "bolt_gryphon_travel"
tt.render.sprites[1].anchor.x = 0.8857142857142857
tt.render.sprites[1].loop = false
tt.render.sprites[1].fps = 10
tt.bullet.max_speed = 300
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_min = 100
tt.bullet.damage_max = 120
tt.bullet.damage_radius = 30
tt.bullet.damage_flags = bor(F_RANGED)
tt.bullet.hit_fx = "fx_bolt_gryphon_hit"
tt.bullet.hit_decal = "decal_bomb_crater"
tt = E:register_t("fx_bolt_gryphon_hit", "fx")
tt.render.sprites[1].name = "fx_bolt_gryphon_hit"
tt.render.sprites[1].anchor.y = 0.23809523809523808
tt = E:register_t("fx_bolt_gryphon_flash", "fx")
tt.render.sprites[1].name = "fx_bolt_gryphon_flash"
tt = E:register_t("decal_gryphon_sign", "decal_tween")
tt.render.sprites[1].name = "ally_gryphon_sign"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -110
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(4),
		255
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		v(0.75, 0.75)
	},
	{
		fts(4),
		v(1.075, 1.075)
	},
	{
		fts(7),
		v(0.96, 0.96)
	},
	{
		fts(9),
		v(1, 1)
	}
}
tt = E:register_t("gryphon_controller")

E:add_comps(tt, "main_script")

tt.main_script.update = kr3_scripts.gryphon_controller.update
tt = E:register_t("decal_obelix", "decal_delayed_click_play")
tt.render.sprites[1].prefix = "decal_obelix"
tt.ui.click_rect = r(-50, -40, 100, 80)
tt.ui.can_select = false
tt.delayed_play.min_delay = 2
tt.delayed_play.max_delay = 3
tt.delayed_play.clicked_animation = "eat"
tt.delayed_play.clicked_sound = "ElvesObelix"
tt.delayed_play.play_animation = "hammer"
tt.delayed_play.required_clicks = 1

for i = 1, 4 do
	tt = E:register_t("kr3_decal_wisp_" .. i, "decal")
	tt.render.sprites[1].name = string.format("decal_wisp_%i_l1", i)
	tt.render.sprites[1].random_ts = 3
	tt.render.sprites[2] = E:clone_c("sprite")
	tt.render.sprites[2].name = string.format("decal_wisp_%i_l2", i)
	tt.render.sprites[2].random_ts = 3

	if i ~= 4 then
		tt.render.sprites[3] = E:clone_c("sprite")
		tt.render.sprites[3].name = string.format("decal_wisp_%i_l3", i)
		tt.render.sprites[3].random_ts = 3
	end

	if i == 2 or i == 3 then
		tt.render.sprites[3] = E:clone_c("sprite")
		tt.render.sprites[3].name = string.format("decal_wisp_%i_l4", i)
		tt.render.sprites[3].random_ts = 3
	end
end

for i = 5, 10 do
	tt = E:register_t("kr3_decal_wisp_" .. i, "decal_delayed_play")
	tt.render.sprites[1].prefix = "decal_wisp_" .. i
	tt.render.sprites[1].name = "play"
	tt.delayed_play.min_delay = 3
	tt.delayed_play.max_delay = 6
	tt.delayed_play.idle_animation = nil
end

tt = E:register_t("decal_s08_magic_bean", "decal_scripted")

E:add_comps(tt, "ui")

tt.achievement_id = "BEANS"
tt.main_script.update = kr3_scripts.decal_s08_magic_bean.update
tt.ui.click_rect = r(-25, -25, 50, 50)
tt.ui.can_select = false
tt.reward_gold = 150
tt.reward_fx = "fx_coin_jump"

for i = 1, 5 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "decal_s08_magic_bean_l" .. i
	tt.render.sprites[i].name = "step1"
	tt.render.sprites[i].loop = false
	tt.render.sprites[i].anchor.y = 0.1076923076923077
end

tt = E:register_t("decal_s08_peekaboo", "decal_scripted")

E:add_comps(tt, "ui")

tt.main_script.update = kr3_scripts.decal_s08_peakaboo.update
tt.render.sprites[1].name = "out"
tt.ui.click_rect = r(-30, -25, 60, 50)
tt.ui.can_select = false
tt.pos_list = nil
tt.sound = "ElvesPeekaboo"
tt = E:register_t("decal_s08_peekaboo_wolf", "decal_s08_peekaboo")
tt.render.sprites[1].prefix = "decal_s08_peekaboo_wolf"
tt.achievement_flag = {
	"PEEKABOO",
	1
}
tt = E:register_t("decal_s08_peekaboo_rrh", "decal_s08_peekaboo")
tt.render.sprites[1].prefix = "decal_s08_peekaboo_rrh"
tt.achievement_flag = {
	"PEEKABOO",
	2
}
tt = E:register_t("decal_s08_peekaboo_pork", "decal_s08_peekaboo")
tt.render.sprites[1].prefix = "decal_s08_peekaboo_pork"
tt.achievement_flag = {
	"PEEKABOO",
	4
}
tt = E:register_t("decal_s08_hansel_gretel", "decal_scripted")

E:add_comps(tt, "ui")

tt.main_script.update = kr3_scripts.decal_s08_hansel_gretel.update
tt.ui.click_rect = r(-70, -60, 140, 120)
tt.ui.can_select = false
tt.render.sprites[1].name = "stage10_witchHouse_layer1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "decal_s08_hansel_gretel_door"
tt.render.sprites[2].name = "close"
tt.render.sprites[2].loop = false
tt = E:register_t("decal_s08_witch", "decal_scripted")

E:add_comps(tt, "ui", "motion")

tt.render.sprites[1].prefix = "decal_s08_witch"
tt.render.sprites[1].anchor.y = 0.07407407407407407
tt.ui.click_rect = r(-30, -25, 60, 50)
tt.ui.can_select = false
tt.motion.max_speed = 90
tt = E:register_t("decal_s08_hansel", "decal_tween")
tt.render.sprites[1].name = "decal_s08_hansel_walk"
tt.render.sprites[1].anchor.y = 0.07692307692307693
tt.render.sprites[1].draw_order = 2
tt.tween.props[1].keys = {
	{
		fts(26),
		255
	},
	{
		fts(37),
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {
	{
		0,
		v(47, -46)
	},
	{
		fts(37),
		v(182, -58)
	}
}
tt = E:register_t("decal_s08_gretel", "decal_s08_hansel")
tt.render.sprites[1].name = "decal_s08_gretel_walk"
tt.tween.props[2].keys = {
	{
		0,
		v(31, -44)
	},
	{
		fts(37),
		v(166, -56)
	}
}
tt = E:register_t("aura_waterfall_entrance", "aura")
tt.main_script.update = kr3_scripts.aura_waterfall_entrance.update
tt.waterfall_nodes = nil
tt.show_fx = "fx_waterfall_splash"
tt = E:register_t("decal_s09_land_3", "decal_background")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "Stage09_0002"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.editor.game_mode = 1
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		fts(9),
		255
	},
	{
		fts(18),
		0
	}
}
tt = E:register_t("decal_s09_land_2", "decal_s09_land_3")
tt.render.sprites[1].name = "Stage09_0003"
tt = E:register_t("decal_s09_land_1", "decal_s09_land_3")
tt.render.sprites[1].name = "Stage09_0004"
tt = E:register_t("decal_s09_crystal_1", "decal_timed")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "decal_s09_crystal_1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.3941176470588235
tt.render.sprites[1].loop = false
tt.render.sprites[1].scale = v(1, 1)
tt.timed.disabled = true
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {
	{
		"editor.game_mode",
		PT_NUMBER
	},
	{
		"editor.tag",
		PT_NUMBER
	}
}
tt.debris_pos = v(-5, 1)
tt = E:register_t("decal_s09_crystal_2", "decal_s09_crystal_1")
tt.render.sprites[1].prefix = "decal_s09_crystal_2"
tt.debris_pos = v(9, 4)
tt = E:register_t("decal_s09_crystal_3", "decal_s09_crystal_1")
tt.render.sprites[1].prefix = "decal_s09_crystal_3"
tt.debris_pos = v(9, -5)
tt = E:register_t("decal_s09_crystal_4", "decal_s09_crystal_1")
tt.render.sprites[1].prefix = "decal_s09_crystal_4"
tt.debris_pos = v(-6, 6)
tt = E:register_t("decal_s09_crystal_debris", "decal_tween")
tt.render.sprites[1].name = "decal_s09_crystal_debris_1"
tt.render.sprites[1].loop = false
tt.render.sprites[1].offset = v(16, 12)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].loop = false
tt.render.sprites[2].name = "decal_s09_crystal_debris_1"
tt.render.sprites[2].flip_x = true
tt.render.sprites[2].offset = v(-14, 9)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "decal_s09_crystal_debris_2"
tt.render.sprites[3].offset = v(2, 42)
tt.render.sprites[3].time_offset = fts(-2)
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].loop = false
tt.render.sprites[4].name = "decal_s09_crystal_debris_2"
tt.render.sprites[4].flip_x = true
tt.render.sprites[4].offset = v(-32, 46)
tt.render.sprites[4].time_offset = fts(-2)
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].name = "stage9_crystals_smoke"
tt.render.sprites[5].animated = false
tt.render.sprites[5].offset = v(0, 30)
tt.tween.props[1].sprite_id = {
	1,
	2,
	3,
	4
}
tt.tween.props[1].keys = {
	{
		fts(27),
		255
	},
	{
		fts(35),
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].sprite_id = 5
tt.tween.props[2].keys = {
	{
		0,
		0
	},
	{
		fts(1),
		255
	},
	{
		fts(8),
		255
	},
	{
		fts(16),
		0
	}
}
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].sprite_id = 5
tt.tween.props[3].keys = {
	{
		0,
		v(0.3, 0.3)
	},
	{
		fts(16),
		v(1.03, 1.03)
	}
}
tt = E:register_t("decal_s09_crystal_debris_mod", "decal_s09_crystal_debris")
tt.render.sprites[3].sort_y_offset = 1
tt.render.sprites[4].sort_y_offset = 1
tt = E:register_t("decal_s09_crystal_serpent_back", "decal_tween")

E:add_comps(tt, "sound_events")

tt.render.sprites[1].name = "crystal_serpent_appear"
tt.render.sprites[1].loop = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 0)
	},
	{
		fts(80),
		v(0, 0)
	},
	{
		fts(114),
		v(0, 0)
	}
}
tt.sound_events.insert = "ElvesCrystalSerpentPassby"
tt = E:register_t("decal_s09_crystal_serpent_attack", "decal_scripted")
tt.render.sprites[1].prefix = "crystal_serpent"
tt.main_script.update = kr3_scripts.decal_s09_crystal_serpent_attack.update
tt = E:register_t("decal_s09_crystal_serpent_scream", "decal_s09_crystal_serpent_attack")
tt.main_script.update = kr3_scripts.decal_s09_crystal_serpent_scream.update
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].hidden = true
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].hidden = true
tt = E:register_t("bullet_crystal_serpent", "bullet")
tt.render.sprites[1].hidden = true
tt.bullet.mod = "mod_crystal_serpent"
tt.bullet.flight_time = fts(17)
tt.bullet.particles_name = "ps_bullet_crystal_serpent_fly"
tt.main_script.update = kr3_scripts.bullet_crystal_serpent.update
tt = E:register_t("mod_crystal_serpent", "modifier")

E:add_comps(tt, "render")

tt.main_script.update = kr3_scripts.mod_tower_block.update
tt.modifier.hide_tower = false
tt.modifier.duration = 7
tt.render.sprites[1].anchor.y = 0.234375
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].name = "start"
tt.render.sprites[1].prefix = "crystal_serpent_block_tower"
tt = E:register_t("ps_bullet_crystal_serpent_fly")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.alphas = {
	255,
	255,
	0
}
tt.particle_system.emission_rate = 10
tt.particle_system.emit_area_spread = v(10, 10)
tt.particle_system.name = "crystalSerpent_smokeParticle"
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	fts(20),
	fts(35)
}
tt.particle_system.scale_var = {
	1,
	1.3
}
tt.particle_system.scales_x = {
	0.3,
	1,
	1.05
}
tt.particle_system.scales_y = {
	0.3,
	1,
	1.05
}
tt.particle_system.scale_same_aspect = true
tt = E:register_t("ps_bullet_crystal_serpent_hit")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.alphas = {
	255,
	255,
	255,
	0
}
tt.particle_system.emission_rate = 120
tt.particle_system.emit_area_spread = v(90, 60)
tt.particle_system.names = {
	"crystalSerpent_smokeParticleHit",
	"crystalSerpent_smokeParticle"
}
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	fts(30),
	fts(45)
}
tt.particle_system.scale_var = {
	1,
	1.3
}
tt.particle_system.scales_x = {
	0.2,
	1,
	1.15
}
tt.particle_system.scales_y = {
	0.2,
	1,
	1.15
}
tt.particle_system.scale_same_aspect = true
tt = E:register_t("decal_s09_waterfall", "decal_scripted")
tt.render.sprites[1].name = "decal_s09_waterfall_lines1"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "decal_s09_waterfall_lines2"
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "decal_s09_waterfall_top"
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "decal_s09_waterfall_bottom"
tt = E:register_t("decal_crystal_water_waves2", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_water_wave_2"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS
tt.delayed_play.min_delay = 1
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "play"
tt = E:register_t("decal_s10_gnome", "decal_scripted")

E:add_comps(tt, "ui")

tt.ui.click_rect = r(-23, -19, 46, 38)
tt.ui.can_select = false
tt.render.sprites[1].prefix = "decal_s10_gnome"
tt.render.sprites[1].anchor.y = 0.23684210526315788
tt.main_script.update = kr3_scripts.decal_s10_gnome.update
tt.min_delay = 5
tt.max_delay = 20
tt.gnome_actions = {
	"guitar",
	"diamond",
	"sleep",
	"teleport",
	"flip"
}
tt = E:register_t("decal_s10_gnome_walking", "decal_s10_gnome")
tt.walk_points = nil
tt.walk_time = 1.5

table.insert(tt.gnome_actions, "walk")

tt = E:register_t("decal_faerie_crystal", "decal_scripted")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "fairy_crystals_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].alpha = 0
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "fairy_crystals_0001"
tt.render.sprites[2].alpha = 255
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "faerie_grove_crystal_fx"
tt.render.sprites[3].name = "yellow"
tt.render.sprites[3].loop = false
tt.render.sprites[3].hidden = true
tt.render.sprites[3].hide_after_runs = 1
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		fts(0),
		0
	},
	{
		fts(10),
		255
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {
	{
		fts(0),
		255
	},
	{
		fts(10),
		0
	}
}
tt.tween.props[2].sprite_id = 2
tt.main_script.update = kr3_scripts.decal_faerie_crystal.update
tt = E:register_t("faerie_trails")

E:add_comps(tt, "main_script")

tt.main_script.insert = kr3_scripts.faerie_trails.insert
tt.main_script.update = kr3_scripts.faerie_trails.update
tt.path_speeds = {
	[0] = 1 * FPS,
	2.5 * FPS
}
tt.path_speed_per_wave = nil
tt = E:register_t("nav_faerie")

E:add_comps(tt, "pos", "render", "nav_path", "motion", "main_script", "tween")

tt.main_script.update = kr3_scripts.nav_faerie.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "fairy_energyBall_red_0016"
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "fairy_energyBall_yellow_0016"
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "nav_faerie_red"
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "nav_faerie_yellow"
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {
	{
		0,
		vv(1)
	},
	{
		fts(10),
		vv(0.8)
	},
	{
		fts(20),
		vv(1)
	}
}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt = E:register_t("simon_controller")

E:add_comps(tt, "main_script")

tt.main_script.update = kr3_scripts.simon_controller.update
tt.initial_sequence_length = 4
tt.reward_base = 25
tt.reward_inc = 15
tt.achievement_id = "SIMON"
tt.achievement_count = 9
tt = E:register_t("simon_mushroom_1", "decal_tween")

E:add_comps(tt, "ui", "sound_events", "editor")

tt.ui.click_rect = r(-20, 10, 40, 30)
tt.ui.can_select = false
tt.ui.has_nav_mesh = true
tt.editor.props = {
	{
		"ui.nav_mesh_id",
		PT_STRING
	}
}
tt.ui.hover_sprite_name = "stage8_symon_fungus1_0001_over_console"
tt.ui.hover_sprite_anchor = v(0.5, 0.1619047619047619)
tt.render.sprites[1].name = "stage8_symon_fungus1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "stage8_symon_fungus1_0002"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].name = "stage8_symon_fungus1_0003"
tt.tween.props[1].keys = {
	{
		0,
		0
	}
}
tt.tween.props[1].sprite_id = 2
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		0
	}
}
tt.tween.props[2].sprite_id = 3
tt.tween.remove = false
tt.sound_events.touch = "ElvesSimonYellow"
tt = E:register_t("simon_mushroom_2", "simon_mushroom_1")
tt.render.sprites[1].name = "stage8_symon_fungus2_0001"
tt.render.sprites[2].name = "stage8_symon_fungus2_0002"
tt.render.sprites[3].name = "stage8_symon_fungus2_0003"
tt.sound_events.touch = "ElvesSimonGreen"
tt.ui.hover_sprite_name = "stage8_symon_fungus2_0001_over_console"
tt = E:register_t("simon_mushroom_3", "simon_mushroom_1")
tt.render.sprites[1].name = "stage8_symon_fungus3_0001"
tt.render.sprites[2].name = "stage8_symon_fungus3_0002"
tt.render.sprites[3].name = "stage8_symon_fungus3_0003"
tt.sound_events.touch = "ElvesSimonRed"
tt.ui.hover_sprite_name = "stage8_symon_fungus3_0001_over_console"
tt = E:register_t("simon_mushroom_4", "simon_mushroom_1")
tt.render.sprites[1].name = "stage8_symon_fungus4_0001"
tt.render.sprites[2].name = "stage8_symon_fungus4_0002"
tt.render.sprites[3].name = "stage8_symon_fungus4_0003"
tt.sound_events.touch = "ElvesSimonBlue"
tt.ui.hover_sprite_name = "stage8_symon_fungus4_0001_over_console"
tt = E:register_t("simon_gnome_mushrooom_glow", "decal_tween")

E:add_comps(tt, "ui", "editor")

tt.editor.props = {
	{
		"ui.nav_mesh_id",
		PT_STRING
	}
}
tt.ui.can_select = false
tt.ui.click_rect = r(-20, -20, 40, 50)
tt.ui.has_nav_mesh = true
tt.ui.hover_sprite_name = "stage8_symon_big_over_console"
tt.ui.hover_sprite_anchor = v(0.5, 0.6)
tt.render.sprites[1].name = "stage8_symon_bigGlow"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {
	{
		0,
		0
	}
}
tt.tween.remove = false
tt = E:register_t("simon_gnome", "decal")
tt.render.sprites[1].prefix = "simon_gnome"
tt.render.sprites[1].sort_y_offset = -38
tt = E:register_t("simon_gnome_fx", "fx")
tt.render.sprites[1].name = "simon_gnome_fx"
tt = E:register_t("simon_gnome_sign", "fx")
tt.render.sprites[1].name = "simon_gnome_sign"
tt.render.sprites[1].offset = v(30, 15)
tt = E:register_t("decal_drow_queen_portal", "decal_scripted")

E:add_comps(tt, "editor", "tween")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage11_portal_0001"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "stage11_portal_0002"
tt.render.sprites[2].alpha = 0
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].name = "stage11_portal_0003"
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].name = "stage11_portal_0004"
tt.main_script.update = kr3_scripts.decal_drow_queen_portal.update
tt.spawn_offsets = {
	v(0, 0),
	v(0, -20),
	v(0, 20)
}
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(7),
		255
	}
}
tt.tween.props[1].sprite_id = 2
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 3
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 4
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].sprite_id = 4
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {
	{
		0,
		vv(1)
	},
	{
		fts(23),
		vv(1.2)
	}
}
tt.tween.props[4].loop = true
tt.tween.props[4].ignore_reverse = true
tt.pack_pi = nil
tt.pack = nil
tt.pack_finished = nil
tt = E:register_t("fx_drow_queen_portal", "fx")
tt.render.sprites[1].name = "fx_drow_queen_portal"
tt.render.sprites[1].anchor.y = 0.22
tt = E:register_t("decal_s11_door_glow", "decal_tween")

E:add_comps(tt, "editor")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage11_doorGlow"
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].sort_y_offset = -30
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		100
	},
	{
		0.3,
		200
	},
	{
		0.6,
		130
	},
	{
		0.9,
		255
	},
	{
		1.2,
		100
	}
}
tt.tween.props[1].loop = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		0
	},
	{
		0.5,
		1
	},
	{
		4.8,
		1
	},
	{
		6,
		0
	}
}
tt.tween.props[2].multiply = true
tt.editor.tag = 1
tt.editor.props = {
	{
		"editor.tag",
		PT_NUMBER
	}
}
tt.editor.overrides = {
	["render.sprites[1].alpha"] = 255
}
tt = E:register_t("decal_s11_zealot_rune", "decal_tween")

E:add_comps(tt, "editor")

tt.render.sprites[1].animated = false
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].offset = v(-40, 0)
tt.render.sprites[1].name = "stage11_zealotRune"
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(5),
		255
	}
}
tt.editor.tag = 1
tt.editor.props = {
	{
		"editor.tag",
		PT_NUMBER
	}
}
tt.editor.overrides = {
	["render.sprites[1].alpha"] = 255
}
tt = E:register_t("decal_s11_mactans", "decal")
tt.render.sprites[1].prefix = "mactans"
tt.render.sprites[1].name = "falling"
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].z = Z_OBJECTS_SKY + 1
tt.drop_duration = 4
tt.retreat_duration = 4
tt.netting_duration = 2.6
tt = E:register_t("decal_mactans_thread", "decal")

for i = 1, math.ceil(48) do
	local s = E:clone_c("sprite")

	s.name = i % 2 == 0 and "mactans_particles_0010" or "mactans_particles_0010"
	s.animated = false
	s.anchor.y = 0
	s.offset.y = i * 16 + 60
	s.flip_x = math.random() < 0.5
	s.z = Z_OBJECTS_SKY
	tt.render.sprites[i] = s
end

tt = E:register_t("decal_mactans_shadow", "decal_tween")
tt.render.sprites[1].name = "mactans_shadow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		4,
		255
	}
}
tt = E:register_t("decal_mactans_webbing", "decal")
tt.render.sprites[1].name = "mactans_decal1"
tt.render.sprites[1].time_offset = 0
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "mactans_decal2"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].name = "mactans_decal3"
tt.render.sprites[4] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[4].name = "mactans_decal4"
tt = E:register_t("decal_s11_drow_queen_cocoon", "decal")
tt.render.sprites[1].prefix = "s11_malicia"
tt.render.sprites[1].name = "spiderNet"
tt.render.sprites[1].loop = false
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].offset = v(-8, 15)
tt.render.sprites[1].anchor.y = 0.15384615384615385
tt.render.sprites[1].z = Z_OBJECTS_SKY - 1
tt = E:register_t("decal_metropolis_floating_rock", "decal_tween")
tt.render.sprites[1].animated = false
tt.tween.random_ts = fts(80)
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 1)
	},
	{
		fts(20),
		v(0, 2)
	},
	{
		fts(40),
		v(0, 1)
	},
	{
		fts(60),
		v(0, 0)
	},
	{
		fts(80),
		v(0, 1)
	}
}
tt.tween.props[1].loop = true
tt = E:register_t("decal_s12_lemur", "decal_scripted")

E:add_comps(tt, "nav_path", "motion", "tween", "ui")

tt.render.sprites[1].prefix = "decal_s12_lemur"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.13333333333333333
tt.render.sprites[1].alpha = 0
tt.motion.max_speed = 60
tt.achievement = "LIKE_TO_MOVE_IT"
tt.action_ni = 12
tt.fade_ni = 18
tt.wait_time = {
	5,
	10
}
tt.show_time = {
	1,
	3
}
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -1
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.5,
		255
	}
}
tt.main_script.update = kr3_scripts.decal_s12_lemur.update
tt.ui.click_rect = r(-15, 0, 30, 30)
tt = E:register_t("birds_formation_controller")

E:add_comps(tt, "main_script")

tt.main_script.update = kr3_scripts.birds_formation_controller.update
tt.wait_time = {
	20,
	60
}
tt.bird_template = "decal_bird_formation"
tt = E:register_t("decal_bird_formation", "decal_tween")
tt.tween.remove = true
tt.tween.props[1].name = "offset"
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t("decal_metropolis_portal", "decal_scripted")

E:add_comps(tt, "tween", "editor")

tt.main_script.update = kr3_scripts.decal_metropolis_portal.update
tt.render.sprites[1].prefix = "decal_metropolis_portal"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "fx_metropolis_portal"
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].anchor.y = 0.07142857142857142
tt.render.sprites[2].alpha = 0
tt.render.sprites[2].random_ts = 0.5
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].offset = v(-27, -5)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].offset = v(27, -19)
tt.render.sprites[5] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[5].offset = v(12, 0)
tt.render.sprites[6] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[6].offset = v(-11, -19)
tt.tween.ts = -1
tt.tween.reverse = true
tt.tween.remove = false

for i = 1, 6 do
	tt.tween.props[i] = E:clone_c("tween_prop")
	tt.tween.props[i].keys = {
		{
			0,
			0
		},
		{
			0.5,
			255
		}
	}
	tt.tween.props[i].sprite_id = i
end

tt.editor.props = {
	{
		"editor.tag",
		PT_NUMBER
	}
}
tt.editor.overrides = {
	["render.sprites[1].name"] = "loop"
}
tt.detection_tags = {}
tt.detection_pahts = nil
tt.detection_rect = r(-60, -40, 120, 80)
tt.vis_flags = 0
tt.vis_bans = F_BOSS
tt = E:register_t("aura_metropolis_portal", "aura")
tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt.aura.duration = -1
tt.aura.mod = "mod_metropolis_portal"
tt.aura.cycle_time = fts(1)
tt.aura.radius = 35
tt.aura.vis_bans = bor(F_FRIEND, F_BOSS)
tt.aura.vis_flags = bor(F_TELEPORT)
tt = E:register_t("mod_metropolis_portal", "mod_teleport")
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.max_times_applied = nil
tt.jump_connection = true
tt.delay_start = fts(2)
tt.hold_time = 0
tt.fx_start = "fx_teleport_metropolis"
tt.fx_end = "fx_teleport_metropolis"
tt = E:register_t("fx_teleport_metropolis", "fx")
tt.render.sprites[1].name = "fx_teleport_metropolis"
tt.render.sprites[1].size_scales = {
	vv(0.83),
	vv(1),
	vv(1.5)
}
tt = E:register_t("decal_s13_relic_book", "decal_delayed_click_play")

E:add_comps(tt, "tween")

tt.render.sprites[1].prefix = "decal_s13_relic_book"
tt.ui.click_rect = r(-20, -30, 40, 30)
tt.delayed_play.min_delay = 3
tt.delayed_play.max_delay = 6
tt.delayed_play.required_clicks = 1
tt.delayed_play.achievement_flag = {
	"SORCERERS_APPRENTICE",
	1
}
tt.delayed_play.play_once = true
tt.delayed_play.clicked_sound = "ElvesAchievementSorcapprenticeBook"
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {
	{
		0,
		v(0, 0)
	},
	{
		fts(20),
		v(0, 1)
	},
	{
		fts(60),
		v(0, -1)
	},
	{
		fts(80),
		v(0, 0)
	}
}
tt = E:register_t("decal_s13_relic_broom", "decal_click_play")
tt.render.sprites[1].prefix = "decal_s13_relic_broom"
tt.ui.click_rect = r(24, 0, 40, 50)
tt.click_play.achievement_flag = {
	"SORCERERS_APPRENTICE",
	2
}
tt.click_play.play_once = true
tt.click_play.clicked_sound = "ElvesAchievementSorcapprenticeBroom"
tt = E:register_t("decal_s13_relic_hat", "decal_click_play")

E:add_comps(tt, "tween")

tt.render.sprites[1].prefix = "decal_s13_relic_hat"
tt.ui.click_rect = r(-20, -40, 40, 30)
tt.tween.remove = false
tt.tween.props[1].loop = true
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 0)
	},
	{
		fts(20),
		v(0, 1)
	},
	{
		fts(60),
		v(0, -1)
	},
	{
		fts(80),
		v(0, 0)
	}
}
tt.click_play.achievement_flag = {
	"SORCERERS_APPRENTICE",
	4
}
tt.click_play.play_once = true
tt.click_play.clicked_sound = "ElvesAchievementSorcapprenticeHat"
tt = E:register_t("decal_s13_black_baby_dragon_placeholder", "decal_static")

E:add_comps(tt, "ui")

tt.ui.can_click = false
tt.ui.can_select = false
tt.ui.can_hover = false
tt.ui.has_nav_mesh = true
tt.render.sprites[1].name = "stage13_ironHeroicDecals_0002"
tt = E:register_t("decal_s13_baby_ashbite_placeholder", "decal_static")

E:add_comps(tt, "ui")

tt.ui.can_click = false
tt.ui.can_select = false
tt.ui.can_hover = false
tt.ui.has_nav_mesh = true
tt.render.sprites[1].name = "stage13_ironHeroicDecals_0001"
tt = E:register_t("tower_black_baby_dragon", "tower")

E:add_comps(tt, "attacks", "user_selection")

tt.tower.type = "baby_black_dragon"
tt.tower.can_be_mod = false
tt.tower.can_hover = IS_CONSOLE
tt.tower.terrain_style = nil
tt.info.i18n_key = "ELVES_BABY_BERESAD"
tt.info.fn = kr3_scripts.tower_black_baby_dragon.get_info
tt.info.portrait = (IS_PHONE and "portraits_towers_" or "info_portraits_towers_") .. "0015"
tt.main_script.update = kr3_scripts.tower_black_baby_dragon.update
tt.attacks.list[1] = E:clone_c("custom_attack")
tt.attacks.list[1].price = 100
tt.render = nil
tt.user_selection.ignore_point = true
tt.ui.has_nav_mesh = true
tt.ui.hover_sprite_name = "babyBeresad_0001_over_console"
tt.ui.hover_sprite_anchor = v(0.5, 0.25268817204301075)
tt = E:register_t("decal_black_baby_dragon", "decal_scripted")

E:add_comps(tt, "motion", "attacks", "tween", "sound_events", "nav_path")

tt.main_script.update = kr3_scripts.decal_black_baby_dragon.update
tt.motion.max_speed = 10 * FPS
tt.attacks.list[1] = E:clone_c("aura_attack")
tt.attacks.list[1].cooldown = 0.2
tt.attacks.list[1].range = 30
tt.attacks.list[1].aura = "aura_black_baby_dragon"
tt.render.sprites[1].prefix = "babyBeresad"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor.y = 0.10227272727272728
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "babyBeresad"
tt.render.sprites[2].name = "zzz"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].loope = false
tt.render.sprites[2].anchor.y = 0.10227272727272728
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "Stage12_Dragon_Shadow"
tt.render.sprites[3].animated = false
tt.render.sprites[3].hidden = true
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[3].draw_order = -1
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "baby_beresad_flame_hit"
tt.render.sprites[4].hidden = true
tt.render.sprites[4].sort_y_offset = -10
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(8),
		0
	}
}
tt.tween.props[1].sprite_id = 2
tt.wakeup_cooldown_min = 5
tt.wakeup_cooldown_max = 16
tt.sleep_pos = nil
tt.dragon_passes = {
	{
		path_id = 8,
		ranges = {
			{
				10,
				75
			},
			{
				125,
				220
			}
		}
	},
	{
		path_id = 9,
		ranges = {
			{
				80,
				120
			}
		}
	},
	{
		path_id = 10,
		ranges = {
			{
				80,
				140
			}
		}
	}
}
tt.sound_events.fire_loop = "ElvesBlackBabyFirebreathLoop"
tt.sound_events.fire_start = "ElvesBlackBabyFirebreathLoopStart"
tt.sound_events.fire_stop = "ElvesBlackBabyFirebreathLoopEnd"
tt = E:register_t("aura_black_baby_dragon", "aura")

E:add_comps(tt, "render", "tween")

tt.aura.duration = 5
tt.aura.mod = "mod_black_baby_dragon"
tt.aura.radius = 50
tt.aura.cycle_time = fts(6)
tt.aura.vis_bans = bor(F_FRIEND)
tt.render.sprites[1].name = "babyBeresad_fireDecal_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "aura_baby_beresad_fire"
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = true
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(5),
		255
	},
	{
		"this.aura.duration-0.7",
		255
	},
	{
		"this.aura.duration",
		0
	}
}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.main_script.insert = kr3_scripts.aura_apply_mod.insert
tt.main_script.update = kr3_scripts.aura_apply_mod.update
tt = E:register_t("mod_black_baby_dragon", "mod_lava")
tt.render.sprites[1].size_names = nil
tt.render.sprites[1].size_scales = {
	vv(0.85),
	vv(1),
	vv(1)
}
tt.render.sprites[1].prefix = "mod_baby_beresad"
tt.render.sprites[1].name = "big"
tt.modifier.duration = 1
tt.dps.damage_min = 5
tt.dps.damage_max = 5
tt.dps.damage_inc = 0
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = 0.2
tt.insert_damage = 150
tt.main_script.insert = kr3_scripts.mod_black_baby_dragon.insert
tt = E:register_t("ps_baby_black_dragon_flame")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 30
tt.particle_system.emit_direction = -math.pi / 6
tt.particle_system.emit_area_spread = v(4, 4)
tt.particle_system.emit_spread = math.pi / 24
tt.particle_system.emit_rotation = 0
tt.particle_system.emit_speed = {
	18 * FPS,
	22 * FPS
}
tt.particle_system.loop = false
tt.particle_system.name = "ps_baby_beresad_flame"
tt.particle_system.particle_lifetime = {
	fts(5),
	fts(5)
}
tt.particle_system.scale_same_aspect = true
tt.particle_system.scales_x = {
	1,
	1
}
tt.particle_system.z = Z_OBJECTS
tt = E:register_t("fx_baby_black_dragon_flame_hit", "decal_tween")
tt.render.sprites[1].name = "baby_beresad_flame_hit"
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(20),
		0
	}
}
tt = E:register_t("tower_holder_baby_ashbite", "tower")

E:add_comps(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "tween")

tt.tower.level = 1
tt.tower.type = "holder_baby_ashbite"
tt.tower.can_be_mod = false
tt.info.fn = kr3_scripts.tower_baby_ashbite.get_info
tt.info.portrait = (IS_PHONE and "portraits_towers_" or "info_portraits_towers_") .. "0019"
tt.info.i18n_key = "ELVES_BABY_ASHBITE_TOWER"
tt.info.damage_icon = "fireball"
tt.render.sprites[1].name = "babyAshbite_tower_layer1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = v(0, 26)
tt.render.sprites[1].hidden = true
tt.render.sprites[1].hover_off_hidden = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "babyAshbite_tower_layer1_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(0, 26)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "babyAshbite_tower_layer2_0001"
tt.render.sprites[3].animated = false
tt.render.sprites[3].offset = v(0, 26)
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "babyAshbite_tower_layer2_0004"
tt.render.sprites[4].animated = false
tt.render.sprites[4].offset = v(0, 26)
tt.ui.click_rect = r(-40, -10, 80, 90)
tt.ui.has_nav_mesh = true
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		2,
		255
	},
	{
		2.5,
		255
	},
	{
		4.5,
		0
	}
}
tt.tween.props[1].sprite_id = 4
tt.tween.props[1].loop = true
tt = E:register_t("tower_baby_ashbite", "tower")

E:add_comps(tt, "barrack", "powers")

tt.tower.can_be_mod = false
tt.tower.hide_dust = true
tt.tower.type = "baby_ashbite"
tt.tower.level = 1
tt.tower.price = 250
tt.info.fn = kr3_scripts.tower_baby_ashbite.get_info
tt.info.portrait = (IS_PHONE and "portraits_towers_" or "info_portraits_towers_") .. "0019"
tt.info.i18n_key = "ELVES_BABY_ASHBITE_TOWER"
tt.info.damage_icon = "fireball"
tt.render.sprites[1].name = "babyAshbite_tower_layer1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = v(0, 26)
tt.render.sprites[1].hidden = true
tt.render.sprites[1].hover_off_hidden = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "babyAshbite_tower_layer1_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(0, 26)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "babyAshbite_tower_layer2_0005"
tt.render.sprites[3].animated = false
tt.render.sprites[3].offset = v(0, 26)
tt.barrack.soldier_type = "soldier_baby_ashbite"
tt.barrack.rally_range = 350
tt.barrack.rally_anywhere = true
tt.barrack.respawn_offset = v(-4, 26)
tt.barrack.max_soldiers = 1
tt.main_script.insert = kr3_scripts.tower_barrack.insert
tt.main_script.update = kr3_scripts.tower_baby_ashbite.update
tt.main_script.remove = kr3_scripts.tower_barrack.remove
tt.sound_events.insert = "ElvesAshbiteDeath"
tt.sound_events.change_rally_point = "ElvesAshbiteConfirm"
tt.powers.blazing_breath = E:clone_c("power")
tt.powers.blazing_breath.price_base = 250
tt.powers.blazing_breath.price_inc = 200
tt.powers.blazing_breath.max_level = 3
tt.powers.fiery_mist = E:clone_c("power")
tt.powers.fiery_mist.price_base = 250
tt.powers.fiery_mist.price_inc = 0
tt.powers.fiery_mist.max_level = 1
tt = E:register_t("soldier_baby_ashbite", "soldier")

E:add_comps(tt, "ranged", "powers")

tt.health.armor = 0.5
tt.health.dead_lifetime = 10
tt.health.hp_max = 450
tt.health.ignore_delete_after = true
tt.health_bar.offset = v(0, 120)
tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
tt.idle_flip.chance = 0.4
tt.idle_flip.cooldown = 1
tt.info.fn = kr3_scripts.soldier_baby_ashbite.get_info
tt.info.portrait = (IS_PHONE and "portraits_towers" or "info_portraits_towers") .. "_0014"
tt.info.i18n_key = "ELVES_BABY_ASHBITE"
tt.info.damage_icon = "fireball"
tt.main_script.insert = kr3_scripts.soldier_baby_ashbite.insert
tt.main_script.update = kr3_scripts.soldier_baby_ashbite.update
tt.motion.max_speed = 90
tt.regen.cooldown = 0.5
tt.regen.health = 15
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].anchor.y = 0.0625
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"idle"
}
tt.render.sprites[1].prefix = "babyAshbite"
tt.render.sprites[1].sync_idx = 8
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "babyAshbite_0099"
tt.render.sprites[2].anchor.y = 0.0625
tt.soldier.melee_slot_offset = v(0, 0)
tt.ui.click_rect = r(-40, 70, 80, 30)
tt.unit.hit_offset = v(0, 84)
tt.unit.hide_after_death = false
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, ady(25))
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON)
tt.vis.flags = bor(tt.vis.flags, F_HERO, F_FLYING)
tt.powers.blazing_breath = E:clone_c("power")
tt.powers.fiery_mist = E:clone_c("power")
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].bullet = "fireball_baby_ashbite"
tt.ranged.attacks[1].bullet_start_offset = {
	v(28, 70)
}
tt.ranged.attacks[1].cooldown = 1.3 + fts(28)
tt.ranged.attacks[1].min_range = 30
tt.ranged.attacks[1].max_range = 100
tt.ranged.attacks[1].filter_fn = kr3_scripts.soldier_baby_ashbite.ranged_filter_fn
tt.ranged.attacks[1].shoot_time = fts(12)
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].sound_shoot = "ElvesAshbiteSpit"
tt.ranged.attacks[1].node_prediction = nil
tt.ranged.attacks[2] = E:clone_c("bullet_attack")
tt.ranged.attacks[2].level = 0
tt.ranged.attacks[2].power_name = "blazing_breath"
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].bullet = "breath_baby_ashbite"
tt.ranged.attacks[2].bullet_start_offset = {
	v(24, 66)
}
tt.ranged.attacks[2].cooldown = 8
tt.ranged.attacks[2].min_range = 30
tt.ranged.attacks[2].max_range = 150
tt.ranged.attacks[2].filter_fn = kr3_scripts.soldier_baby_ashbite.blazing_breath_filter_fn
tt.ranged.attacks[2].shoot_time = fts(9)
tt.ranged.attacks[2].sync_animation = true
tt.ranged.attacks[2].animation = "special"
tt.ranged.attacks[2].sound = "ElvesAshbiteFlameThrower"
tt.ranged.attacks[2].vis_bans = F_FLYING
tt.ranged.attacks[3] = E:clone_c("bullet_attack")
tt.ranged.attacks[3].level = 0
tt.ranged.attacks[3].power_name = "fiery_mist"
tt.ranged.attacks[3].disabled = true
tt.ranged.attacks[3].bullet = "fierymist_baby_ashbite"
tt.ranged.attacks[3].bullet_start_offset = {
	v(24, 66)
}
tt.ranged.attacks[3].cooldown = 10
tt.ranged.attacks[3].min_range = 40
tt.ranged.attacks[3].max_range = 150
tt.ranged.attacks[3].shoot_time = fts(9)
tt.ranged.attacks[3].sync_animation = true
tt.ranged.attacks[3].animation = "special"
tt.ranged.attacks[3].vis_bans = F_FLYING
tt.ranged.attacks[3].sound = "ElvesAshbiteSmoke"
tt = E:register_t("fireball_baby_ashbite", "bullet")
tt.render.sprites[1].name = "fireball_baby_ashbite"
tt.render.sprites[1].z = Z_BULLETS
tt.bullet.damage_min = 83
tt.bullet.damage_max = 125
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_radius = 30
tt.bullet.min_speed = 240
tt.bullet.max_speed = 240
tt.bullet.node_prediction = true
tt.bullet.g = nil
tt.bullet.hit_fx = "fx_fireball_baby_ashbite_hit"
tt.bullet.hit_fx_air = "fx_fireball_baby_ashbite_hit_air"
tt.bullet.vis_flags = F_RANGED
tt.main_script.update = kr3_scripts.fireball.update
tt.sound_events.hit = "ElvesAshbiteFireball"
tt = E:register_t("fx_fireball_baby_ashbite_hit", "fx")
tt.render.sprites[1].name = "fx_fireball_baby_ashbite_hit"
tt.render.sprites[1].anchor.y = 0.24
tt = E:register_t("fx_fireball_baby_ashbite_hit_air", "fx")
tt.render.sprites[1].name = "fx_fireball_baby_ashbite_hit_air"
tt.render.sprites[1].anchor.y = 0.24
tt = E:register_t("breath_baby_ashbite", "bullet")
tt.render = nil
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.min_speed = 240
tt.bullet.max_speed = 240
tt.bullet.g = nil
tt.bullet.vis_flags = F_RANGED
tt.bullet.emit_decal = "decal_emit_breath_baby_ashbite"
tt.bullet.node_prediction = true
tt.bullet.hit_fx = "fx_breath_baby_ashbite_hit"
tt.bullet.hit_decal = "aura_breath_baby_ashbite"
tt.main_script.update = kr3_scripts.fireball.update
tt = E:register_t("decal_emit_breath_baby_ashbite", "decal_scripted")
tt.duration = fts(18)
tt.render.sprites[1].name = "babyAshbite_0158"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.6909090909090909, 0.5416666666666666)
tt.render.sprites[1].z = Z_EFFECTS
tt.emit_ps = "ps_emit_breath_baby_ashbite"
tt.main_script.update = kr3_scripts.decal_emit_breath_baby_ashbite.update
tt.flight_time = nil
tt = E:register_t("fx_breath_baby_ashbite_hit", "fx")
tt.render.sprites[1].name = "baby_ashbite_breath_fire"
tt.render.sprites[1].anchor.y = 0.35714285714285715
tt = E:register_t("aura_breath_baby_ashbite", "aura")

E:add_comps(tt, "tween", "render")

tt.main_script.update = kr3_scripts.aura_apply_damage.update
tt.aura.duration = fts(30)
tt.aura.damage_inc = 16.666666666666668
tt.aura.damage_min = 8.333333333333334
tt.aura.damage_max = 8.333333333333334
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.radius = 60
tt.aura.cycle_time = fts(5)
tt.aura.vis_bans = bor(F_FRIEND)
tt.render.sprites[1].name = "baby_ashbite_breath_fire_decal"
tt.render.sprites[1].anchor.y = 0.38095238095238093
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "babyAshbite_specialFire_decal"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(20),
		0
	}
}
tt = E:register_t("fierymist_baby_ashbite", "breath_baby_ashbite")
tt.bullet.emit_decal = "decal_emit_fiery_mist_baby_ashbite"
tt.bullet.hit_decal = "aura_fiery_mist_baby_ashbite"
tt.bullet.hit_fx = nil
tt = E:register_t("decal_emit_fiery_mist_baby_ashbite", "decal_emit_breath_baby_ashbite")
tt.duration = fts(18)
tt.render.sprites[1].hidden = true
tt.emit_ps = "ps_emit_fiery_mist_baby_ashbite"
tt = E:register_t("aura_fiery_mist_baby_ashbite", "aura")
tt.main_script.update = kr3_scripts.aura_fiery_mist_baby_ashbite.update
tt.fx = "decal_fiery_mist_baby_ashbite"
tt.aura.duration = 2.5
tt.aura.mod = "mod_slow_baby_ashbite"
tt.aura.cycle_time = 0.25
tt.aura.damage_inc = 25 * tt.aura.cycle_time / tt.aura.duration
tt.aura.damage_min = 75 * tt.aura.cycle_time / tt.aura.duration
tt.aura.damage_max = 75 * tt.aura.cycle_time / tt.aura.duration
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.radius = 50
tt.aura.vis_bans = bor(F_FRIEND)
tt = E:register_t("mod_slow_baby_ashbite", "mod_slow")
tt.slow.factor = 0.3
tt.slow.factor_inc = 0.1
tt = E:register_t("decal_fiery_mist_baby_ashbite", "decal_tween")
tt.render.sprites[1].name = "baby_ashbite_fierymist_decal"
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor.y = 0.25
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(6),
		255
	},
	{
		"this.duration-0.2",
		255
	},
	{
		"this.duration",
		0
	}
}
tt = RT("decal_s14_break_egg", "decal_scripted")

AC(tt, "ui", "click_play", "tween")

tt.render.sprites[1].prefix = "decal_s14_break_egg"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.38235294117647056
tt.main_script.update = kr3_scripts.decal_s14_break_spider.update
tt.click_play.required_clicks = 5
tt.ui.can_select = false
tt.ui.click_rect = r(-15, -5, 30, 30)
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		vv(1)
	},
	{
		fts(1),
		vv(1.2)
	},
	{
		fts(6),
		vv(1)
	}
}
tt = RT("decal_s14_break_spider", "decal_scripted")

AC(tt, "tween")

tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].name = "decal_s14_break_spider"
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.75,
		255
	},
	{
		1,
		0
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {
	{
		0,
		v(0, 0)
	},
	{
		2,
		v(1, 1)
	}
}
tt = RT("decal_s15_mactans", "decal_scripted")

AC(tt, "editor")

tt.render.sprites[1].prefix = "stage15_mactans_l1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.09047619047619047
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "stage15_mactans_l2"
tt.main_script.update = kr3_scripts.decal_s15_mactans.update
tt = RT("decal_s15_malicia", "decal_scripted")

AC(tt, "editor")

tt.render.sprites[1].prefix = "stage15_malicia"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.057692307692307696
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "stage15_malicia_ray"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].anchor = v(0.64, 0.21666666666666667)
tt.render.sprites[2].offset = v(-2, 57)
tt.main_script.update = kr3_scripts.decal_s15_malicia.update
tt = RT("decal_s15_statue", "decal_scripted")

AC(tt, "editor")

tt.main_script.update = kr3_scripts.decal_s15_statue.update
tt.render.sprites[1].prefix = "stage15_shield"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.20161290322580644
tt = RT("decal_s15_crystal", "decal_tween")

AC(tt, "editor")

tt.render.sprites[1].name = "stage15_crystal"
tt.render.sprites[1].animated = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 2)
	},
	{
		fts(25),
		v(0, -2)
	},
	{
		fts(50),
		v(0, 2)
	}
}
tt.tween.props[1].loop = true
tt.tween.props[1].interp = "sine"
tt = RT("fx_s15_crystal_shine", "fx")
tt.render.sprites[1].name = "stage15_crystal_fx"
tt = RT("fx_s15_crystal_transformation", "fx")

for i = 1, 4 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "stage15_crystal_l" .. i
	tt.render.sprites[i].name = "explosion"
end

tt = RT("fx_s15_white_circle", "decal_tween")
tt.render.sprites[1].name = "spiderQueen_deathShapes_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_GUI - 2
tt.tween.remove = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		fts(3),
		vv(0.3)
	},
	{
		fts(6),
		vv(70)
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		255
	},
	{
		1,
		255
	},
	{
		2,
		0
	}
}
tt = RT("decal_s15_finished_gem", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "stage15_bossDecal_gem"
tt.render.sprites[1].anchor.y = 0.22580645161290322
tt.render.sprites[1].animated = false
tt = RT("decal_s15_finished_veznan", "decal_delayed_play")

AC(tt, "editor")

tt.render.sprites[1].prefix = "decal_s15_finished_veznan"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.1111111111111111
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 15
tt = RT("decal_s15_finished_guard", "decal_delayed_sequence")

AC(tt, "editor")

for i = 1, 4 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "decal_s15_finished_guard_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].anchor.y = 0.12195121951219512
	tt.render.sprites[i].loop = i > 2
	tt.render.sprites[i].hidden = i == 4
end

tt.delayed_sequence.animations = {
	"idle",
	"blink",
	"blink",
	"sleep"
}
tt.delayed_sequence.min_delay = 5
tt.delayed_sequence.max_delay = 15
tt.delayed_sequence.random = nil
tt = RT("decal_s15_finished_guard_flipped", "decal_s15_finished_guard")

for i = 1, 4 do
	tt.render.sprites[i].flip_x = true
	tt.render.sprites[i].hidden = i == 3
end

tt = RT("kr3_taunts_s15_controller")

AC(tt, "main_script", "taunts", "editor")

tt.load_file = "level15_taunts"
tt.main_script.insert = kr3_scripts.taunts_controller.insert
tt.main_script.update = kr3_scripts.taunts_controller.update
tt.taunts.delay_min = 10
tt.taunts.delay_max = 20
tt.taunts.sets = {}
tt.taunts.sets.mactans = CC("taunt_set")
tt.taunts.sets.mactans.format = "ELVES_ENEMY_MACTANS_TAUNT_%04i"
tt.taunts.sets.mactans.end_idx = 8
tt.taunts.sets.mactans.decal_name = "decal_s15_mactans_shoutbox"
tt.taunts.sets.mactans.pos = v(453, 591)
tt.taunts.sets.malicia = CC("taunt_set")
tt.taunts.sets.malicia.format = "ELVES_ENEMY_MALICIA_TAUNT_%04i"
tt.taunts.sets.malicia.end_idx = 8
tt.taunts.sets.malicia.decal_name = "decal_s15_malicia_shoutbox"
tt.taunts.sets.malicia.pos = v(653, 591)
tt.taunts.sets.welcome_mactans = table.deepclone(tt.taunts.sets.mactans)
tt.taunts.sets.welcome_mactans.format = "ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_WELCOME_0001"
tt.taunts.sets.welcome_malicia = table.deepclone(tt.taunts.sets.malicia)
tt.taunts.sets.welcome_malicia.format = "ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_WELCOME_0002"
tt.taunts.sets.pre_mactans = table.deepclone(tt.taunts.sets.mactans)
tt.taunts.sets.pre_mactans.format = "ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_PREBATTLE_%04i"
tt.taunts.sets.pre_mactans.idxs = {
	2,
	4
}
tt.taunts.sets.pre_malicia = table.deepclone(tt.taunts.sets.malicia)
tt.taunts.sets.pre_malicia.format = "ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_PREBATTLE_%04i"
tt.taunts.sets.pre_malicia.idxs = {
	1,
	3
}
tt.taunts.sets.custom_malicia = table.deepclone(tt.taunts.sets.malicia)
tt.taunts.sets.custom_malicia.format = "ELVES_ENEMY_MALICIA_TAUNT_KIND_%s"
tt.taunts.sets.custom_mactans = table.deepclone(tt.taunts.sets.mactans)
tt.taunts.sets.custom_mactans.format = "ELVES_ENEMY_MALICIA_TAUNT_KIND_%s"
tt = RT("decal_s15_mactans_shoutbox", "decal_eb_spider_shoutbox")
tt.render.sprites[1].name = "stage15_taunts_0004"
tt.render.sprites[2].name = "stage15_taunts_0005"
tt.texts.list[1].font_size = 28
tt.texts.list[1].color = {
	247,
	133,
	102
}
tt = RT("decal_s15_malicia_shoutbox", "decal_eb_spider_shoutbox")
tt.render.sprites[2].name = "stage15_taunts_0002"
tt.texts.list[1].font_size = 28
tt = RT("decal_hr_crystal_skull", "decal_delayed_click_play")
tt.render.sprites[1].prefix = "decal_hr_crystal_skull"
tt.delayed_play.play_once = true
tt.delayed_play.required_clicks = 1
tt.delayed_play.click_interrupts = true
tt.delayed_play.clicked_sound = "ElvesCrystalSkull"
tt.ui.can_select = false
tt.ui.click_rect = r(-13, -13, 28, 24)
tt = RT("decal_s16_land_1", "decal_background")

AC(tt, "tween")

tt.render.sprites[1].name = "Stage16_0003"
tt.render.sprites[1].z = Z_DECALS + 1
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.26,
		0
	}
}
tt = RT("decal_s16_land_2", "decal_s16_land_1")
tt.render.sprites[1].name = "Stage04_0002"
tt.render.sprites[1].z = Z_DECALS - 1
tt = RT("decal_s16_ground_archers_land", "decal_tween")

AC(tt, "editor")

tt.render.sprites[1].name = "groundArchers"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2857142857142857
tt.render.sprites[1].z = Z_DECALS - 1
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.26,
		0
	}
}
tt = RT("soldier_s16_ground_archer", "soldier_gryphon_guard_upper")

AC(tt, "editor")

tt.ranged.attacks[1].filter_fn = nil
tt.render.sprites[1].prefix = "soldier_s16_ground_archer"
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 30
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("decal_s16_bush_holder", "decal_tween")

AC(tt, "editor")

tt.render.sprites[1].name = "stage16_bushHolders"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2857142857142857
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.26,
		0
	}
}
tt = RT("decal_s16_bush_burner", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "stage16_bushGnollBurner"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2777777777777778
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {
	{
		"editor.game_mode",
		PT_NUMBER
	},
	{
		"editor.tag",
		PT_NUMBER
	}
}
tt = RT("fx_s16_bush_burner", "fx")
tt.render.sprites[1].name = "fx_s16_bush_burner"
tt.render.sprites[1].anchor.y = 0.3548387096774194
tt = E:register_t("fx_s16_burner_explosion", "decal_timed")

E:add_comps(tt, "editor")

tt.timed.disabled = true
tt.render.sprites[1].name = "fx_s16_burner_explosion"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].anchor.y = 0.09740259740259741
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {
	{
		"render.sprites[1].r",
		PT_NUMBER,
		math.pi / 180
	},
	{
		"editor.game_mode",
		PT_NUMBER
	},
	{
		"editor.tag",
		PT_NUMBER
	}
}
tt.editor.overrides = {
	["render.sprites[1].hidden"] = false,
	["render.sprites[1].loop"] = true
}
tt = RT("gnoll_bush_spawner", "decal_scripted")

AC(tt, "spawner", "editor")

tt.render.sprites[1].name = "stage16_bushSpawner"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2833333333333333
tt.spawner.eternal = true
tt.spawner.entity = "gnoll_bush"
tt.spawner.allowed_subpaths = {
	1
}
tt.spawner.ni = 1
tt.main_script.update = kr3_scripts.gnoll_bush_spawner.update
tt.spawn_node_offset = 0
tt.spawn_once = nil
tt.spawn_data = nil
tt.editor.props = {
	{
		"spawner.name",
		PT_STRING
	},
	{
		"spawner.pi",
		PT_NUMBER
	}
}
tt = RT("gnoll_bush", "decal_scripted")

AC(tt, "nav_path", "motion", "main_script", "spawner", "unit")

tt.render.sprites[1].prefix = "gnollBush"
tt.render.sprites[1].anchor.y = 0.3548387096774194
tt.render.sprites[1].name = "idle"
tt.main_script.update = kr3_scripts.gnoll_bush.update
tt.motion.max_speed = 75
tt.spawn_sound = "ElvesGnollTrailOut"
tt.spawner.entity = nil
tt.spawner.count = 1
tt.spawner.random_subpath = true
tt.spawner.patch_props = {
	enemy = {
		gold = 0
	}
}
tt.walk_nodes_range = {
	5,
	10
}
tt.walk_wait = 1
tt = RT("decal_hr_cart", "decal")
tt.render.sprites[1].name = "stage17_carret"
tt.render.sprites[1].anchor.y = 0.08333333333333333
tt.render.sprites[1].animated = false
tt = RT("decal_hr_worker_a", "decal")
tt.render.sprites[1].name = "decal_hr_worker_a"
tt.render.sprites[1].anchor.y = 0.027777777777777776
tt = RT("decal_hr_worker_b", "decal")
tt.render.sprites[1].name = "decal_hr_worker_b"
tt.render.sprites[1].anchor.y = 0.20833333333333334
tt = RT("malik_slave_controller", "decal_scripted")

AC(tt, "editor")

tt.fn_can_power = kr3_scripts.malik_slave_controller.fn_can_power
tt.hero_spawn_pos = v(736, 639)
tt.main_script.update = kr3_scripts.malik_slave_controller.update
tt.starting_wave = 2
tt.thunder_rect = r(655, 595, 164, 56)
tt.wait_time = fts(159)
tt.achievement_id = "FREEDOM_FIGHTER"
tt.walk_points = {
	malik = {
		v(973, 655),
		v(808, 632),
		v(748, 666)
	},
	gnoll_left = {
		v(935, 651),
		v(700, 605)
	},
	gnoll_right = {
		v(1016, 673),
		v(795, 631)
	}
}
tt = RT("decal_gnoll_gnawer", "decal_scripted")

AC(tt, "motion", "nav_grid", "motion", "tween")

tt.render.sprites[1].anchor = v(0.5, 0.25)
tt.render.sprites[1].prefix = "gnoll_gnawer"
tt.render.sprites[1].name = "idle"
tt.motion.max_speed = 2 * FPS
tt.main_script.update = kr3_scripts.decal_walking.update
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		1,
		0
	}
}
tt = RT("decal_baby_malik_slave", "decal_scripted")

AC(tt, "motion", "nav_grid", "motion")

tt.render.sprites[1].anchor.y = 0.184
tt.render.sprites[1].prefix = "decal_baby_malik"
tt.render.sprites[1].name = "idle"
tt.main_script.update = kr3_scripts.decal_walking.update
tt.motion.max_speed = 2 * FPS
tt.main_script.update = kr3_scripts.decal_walking.update
tt = RT("decal_baby_malik_slave_banner", "decal_tween")
tt.render.sprites[1].name = "malikAfro_sign"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = v(30, 66)
tt.tween.ts = -10
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		100
	},
	{
		fts(4),
		255
	},
	{
		fts(71),
		255
	},
	{
		fts(75),
		0
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		vv(0.75)
	},
	{
		fts(4),
		vv(1.075)
	},
	{
		fts(7),
		vv(0.9625)
	},
	{
		fts(9),
		vv(1)
	},
	{
		fts(69),
		vv(1)
	},
	{
		fts(71),
		vv(1.075)
	},
	{
		fts(75),
		vv(0.75)
	}
}
tt = RT("decal_baby_malik_slave_free", "decal")
tt.render.sprites[1].name = "decal_baby_malik_free"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0.33101851851851855, 0.27976190476190477)
tt = RT("decal_s18_statue", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "stage18_statue"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.176056338028169
tt = RT("decal_s18_roadrunner_bush", "decal_scripted")

AC(tt, "editor", "ui")

tt.render.sprites[1].name = "decal_s18_roadrunner_bush_shake"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0.3
tt.main_script.update = kr3_scripts.decal_s18_roadrunner_bush.update
tt.required_clicks = {
	3,
	5
}
tt.shake_cooldown = {
	3,
	5
}
tt.sound_clicked = "ElvesGnollTrailOut"
tt.ui.click_rect = r(-22, -10, 44, 40)
tt.ui.can_select = false
tt = RT("fx_roadruner_bush_explode", "fx")
tt.render.sprites[1].name = "gnollBush_explode"
tt.render.sprites[1].anchor.y = 0.3548387096774194
tt = RT("decal_s18_roadrunner", "decal_tween")

AC(tt, "sound_events")

tt.render.sprites[1].name = "decal_s18_roadrunner_run"
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor.y = 0.125
tt.pos = v(464, 473)
tt.sound_events.insert = "ElvesRoadRunner"
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 0)
	},
	{
		2.2,
		v(-369, 14)
	}
}
tt = RT("decal_s18_coyote", "decal")

AC(tt, "sound_events")

tt.render.sprites[1].prefix = "decal_s18_coyote"
tt.render.sprites[1].name = "pull"
tt.render.sprites[1].anchor.y = 0.19230769230769232
tt.pos = v(138, 383)
tt.sound_events.push = "BombExplosionSound"
tt = RT("decal_s18_flag_head", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "decal_s18_flag_head"
tt = RT("decal_s18_boss_head", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "stage_18_head"
tt.render.sprites[1].animated = false
tt = RT("taunts_s18_defeated_controller")

AC(tt, "main_script", "taunts", "editor")

tt.load_file = "level18_taunts"
tt.main_script.insert = kr3_scripts.taunts_controller.insert
tt.main_script.update = kr3_scripts.taunts_controller.update
tt.taunts.delay_min = 10
tt.taunts.delay_max = 20
tt.taunts.sets = {}
tt.taunts.sets.left_head = CC("taunt_set")
tt.taunts.sets.left_head.end_idx = 8
tt.taunts.sets.left_head.format = "ELVES_ENEMY_BRAM_TAUNT_%04i"
tt.taunts.sets.left_head.decal_name = "decal_s18_shoutbox"
tt.taunts.sets.left_head.pos = v(727, 700)
tt.taunts.sets.right_head = CC("taunt_set")
tt.taunts.sets.right_head.end_idx = 8
tt.taunts.sets.right_head.format = "ELVES_ENEMY_DEATH_TAUNT_%04i"
tt.taunts.sets.right_head.decal_name = "decal_s18_shoutbox"
tt.taunts.sets.right_head.pos = v(791, 680)
tt = E:register_t("decal_s18_shoutbox", "decal_tween")

E:add_comps(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "theBeheader_taunt"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = v(0, 1)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(180, 58)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = 22
tt.texts.list[1].color = {
	229,
	86,
	86
}
tt.texts.list[1].line_height = i18n:cjk(0.8, 0.9, 1.1, 0.7)
tt.texts.list[1].sprite_id = 2
tt.texts.list[1].fit_height = true
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.25,
		255
	},
	{
		"this.duration-0.25",
		255
	},
	{
		"this.duration",
		0
	}
}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].keys = {
	{
		0,
		v(1.01, 1.01)
	},
	{
		0.4,
		v(0.99, 0.99)
	},
	{
		0.8,
		v(1.01, 1.01)
	}
}
tt.tween.props[3].sprite_id = 1
tt.tween.props[3].loop = true
tt.tween.props[4] = table.deepclone(tt.tween.props[3])
tt.tween.props[4].sprite_id = 2
tt.tween.remove = true
tt = RT("decal_s19_drizzt", "decal_scripted")

AC(tt, "editor", "ui")

tt.render.sprites[1].prefix = "decal_s19_drizzt"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.main_script.update = kr3_scripts.decal_s19_drizzt.update
tt.idle_cooldown = {
	3,
	5
}
tt.spawn_cooldown = {
	10,
	15
}
tt.sound_clicked = "ElvesDrizztGrowl"
tt.sound_chase = "ElvesDrizztUnsheathe"
tt.sound_chase_params = {
	delay = fts(23)
}
tt.ui.click_rect = r(90, -30, 40, 30)
tt.ui.can_select = false
tt = RT("decal_s19_drizzt_gnoll", "decal_scripted")
tt.render.sprites[1].prefix = "decal_s19_drizzt_gnoll"
tt.render.sprites[1].name = "idle"
tt.main_script.update = kr3_scripts.decal_s19_drizzt_gnoll.update
tt = RT("decal_s21_lava_bubble", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_s21_lava_bubble"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].alpha = 200
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].scale = vv(1.5)
tt.delayed_play.min_delay = 2
tt.delayed_play.max_delay = 5
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.idle_animation = nil
tt = RT("decal_s22_lava_bubble", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_s22_lava_bubble"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].alpha = 200
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].scale = vv(1.5)
tt.delayed_play.min_delay = 2
tt.delayed_play.max_delay = 5
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.idle_animation = nil
tt = RT("decal_s22_lava_hole", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_s22_lava_hole"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].scale = vv(1)
tt.delayed_play.min_delay = 1
tt.delayed_play.max_delay = 2
tt.delayed_play.idle_animation = nil
tt = RT("decal_s22_lava_smoke", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_s22_lava_smoke"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].alpha = 200
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].scale = vv(1)
tt.delayed_play.min_delay = 3
tt.delayed_play.max_delay = 8
tt.delayed_play.idle_animation = nil
tt = RT("lava_fireball_controller")

AC(tt, "main_script")

tt.main_script.update = kr3_scripts.lava_fireball_controller.update
tt.bullet = "bomb_lava_fireball"
tt.launch_fx = "fx_bomb_lava_fireball_launch"
tt = RT("bomb_lava_fireball", "bullet")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 250
tt.bullet.damage_min = 200
tt.bullet.damage_radius = 45
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time_base = fts(25)
tt.bullet.flight_time_factor = fts(0.05)
tt.bullet.g = -0.8 / (fts(1) * fts(1))
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.hit_fx = "fx_bomb_lava_fireball_explosion"
tt.bullet.mod = "mod_veznan_demon_fire"
tt.bullet.particles_name = "ps_bomb_lava_fireball"
tt.bullet.pop = {
	"pop_entwood"
}
tt.bullet.rotation_speed = 20 * FPS * math.pi / 180
tt.main_script.insert = kr3_scripts.enemy_bomb.insert
tt.main_script.update = kr3_scripts.enemy_bomb.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "Stage9_lavaShot"
tt.sound_events.hit = "BombExplosionSound"
tt = RT("fx_bomb_lava_fireball_launch", "fx")
tt.render.sprites[1].name = "fx_bomb_lava_fireball_launch"
tt = RT("fx_bomb_lava_fireball_explosion", "fx")
tt.render.sprites[1].name = "fireball_explosion"
tt.render.sprites[1].anchor.y = 0.15
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("decal_stage81_burner", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "decal_s81_burner"
tt = E:register_t("decal_endless_shoutbox", "decal_s18_shoutbox")
tt.render.sprites[1].name = "hee-haw_taunt"
tt.texts.list[1].color = {
	233,
	189,
	255
}
tt.texts.list[1].size = v(180, 58)
tt.texts.list[1].font_size = 20