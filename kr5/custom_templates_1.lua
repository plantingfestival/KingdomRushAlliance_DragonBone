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
local customScripts1 = require("custom_scripts_1")

require("templates")

local U = require("utils")
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

tt = E:register_t("controller_item_kr4_hero_malik", "controller_item_hero")
tt.entity = "kr4_hero_malik"

tt = E:register_t("kr4_hero_malik", "hero5")
AC(tt, "melee", "timed_attacks", "launch_movement")
tt.health.armor = 0.5
tt.health.dead_lifetime = 15
tt.health.hp_max = 720
tt.health_bar.offset = v(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.hero.team = TEAM_LINIREA
tt.hero.respawn_animation = "taunt"
tt.hero.death_loop_animation = "deathLoop"
tt.info.i18n_key = "HERO_MALIK"
tt.info.fn = scripts.hero_basic.get_info_melee
tt.info.portrait = "portraits_hero_0119"
tt.main_script.update = customScripts1.kr4_hero_malik.update
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = 108
tt.melee.attacks[1].damage_min = 86
tt.melee.attacks[1].hit_time = 0.85
tt.melee.attacks[1].damage_radius = 60
tt.melee.attacks[1].sound = "malik_melee_attack"
tt.melee.attacks[1].sound_args = {
	delay = 0.8
}
tt.melee.attacks[1].hit_offset = v(30, 10)
tt.melee.attacks[1].hit_decal = "malik_attack_decal"
tt.melee.attacks[1].animation = "melee"
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].skill = "range_unit"
tt.timed_attacks.list[1].melee_break = true
tt.timed_attacks.list[1].animation = "range"
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 245
tt.timed_attacks.list[1].cooldown = 4.5
tt.timed_attacks.list[1].cast_time = 0.59
tt.timed_attacks.list[1].bullet = "malik_attack_ray"
tt.timed_attacks.list[1].search_type = U.search_type.max_health
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND, F_NIGHTMARE)
tt.timed_attacks.list[2] = CC("bullet_attack")
tt.timed_attacks.list[2].animation = "special"
tt.timed_attacks.list[2].cooldown = 13
tt.timed_attacks.list[2].cast_time = 1.21
tt.timed_attacks.list[2].bullet = "malik_tower_destruction_ray"
tt.launch_movement.min_distance = 150
tt.launch_movement.animations = {
	"jumpLaunch",
	"jumpTravel",
	"jumpLand"
}
tt.launch_movement.flight_time = fts(35)
tt.launch_movement.loop_on_the_way = true
tt.launch_movement.launch_sound = "malik_jump_charge"
tt.launch_movement.launch_args = {
	delay = 0
}
tt.launch_movement.launch_entity = "malik_jump_decal"
tt.launch_movement.launch_entity_delay = nil
tt.launch_movement.land_sound = "malik_jump_hit"
tt.launch_movement.land_entity = "aura_malik_land"
tt.launch_movement.land_entity_offset = v(25, 0)
tt.launch_movement.land_args = {
	delay = 0
}
tt.melee.range = 65
tt.motion.max_speed = 28
tt.regen.cooldown = 1
tt.regen.health = 180
tt.render.sprites[1].anchor.y = 0.34
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "malik_layer2"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "malik_shadow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].anchor.y = 0.34
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.change_rally_point = "HeroReinforcementTaunt"
tt.sound_events.insert = "HeroReinforcementTauntIntro"
tt.sound_events.respawn = "HeroReinforcementTauntIntro"
tt.sound_events.death = "HeroReinforcementDeath"
tt.sound_events.after_death = {
	"malik_death_hammerfall",
	"malik_death_body_fall"
}
tt.sound_events.after_death_args = {
	{
		delay = 0.3
	},
	{
		delay = 0.5
	}
}
tt.soldier.melee_slot_offset.x = 15
tt.unit.hit_offset = v(0, 19)
tt.unit.mod_offset = v(0, 16)
tt.unit.head_offset = v(0, 28)
tt.unit.marker_offset = v(0, 0)
tt.unit.hide_after_death = nil

tt = E:register_t("malik_attack_decal", "decal_tween")
tt.render.sprites[1].name = "malik_attack_decal_run"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(27),
		0
	}
}

tt = E:register_t("malik_attack_ray", "lightning_ray")
tt.render.sprites[1].name = "malik_attack_ray_travel"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].r = -math.pi / 2
tt.bullet.damage_min = 260
tt.bullet.damage_max = 320
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.use_unit_damage_factor = true
tt.bullet.hit_time = fts(2)
tt.bullet.mod = "mod_malik_attack_ray"
tt.bullet.pop = {
	"pop_zap_sorcerer",
	"pop_crit_wild_magus"
}
tt.bullet.pop_chance = 0.5
tt.sound_events.insert = "malik_ranged_attack"
tt.spawn_pos_offset = v(0, 107)

tt = E:register_t("mod_malik_attack_ray", "mod_slow")
E:add_comps(tt, "render")
tt.slow.factor = 0.65
tt.modifier.duration = 2
tt.modifier.vis_bans = bor(F_BOSS)
tt.render.sprites[1].prefix = "malik_attack_ray_modifier"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop = true

tt = E:register_t("malik_tower_destruction_ray", "lightning_ray")
tt.render.sprites[1].name = "malik_towerdestroction_ray_run"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0.5, 0.04)
tt.bullet.damage_min = 390
tt.bullet.damage_max = 480
tt.bullet.damage_radius = 80
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.use_unit_damage_factor = nil
tt.bullet.hit_time = fts(2)
tt.bullet.mod = "mod_malik_attack_ray"
tt.bullet.hit_payload = "malik_jump_decal"
tt.bullet.ignore_hit_offset = true
tt.sound_events.insert = "malik_tower_destroy_oneshot"
tt.spawn_pos_offset = v(0, 0)

tt = E:register_t("malik_jump_decal", "decal_timed")
tt.render.sprites[1].name = "malik_jump_decal_run"
tt.render.sprites[1].anchor = v(0.5, 0.32)
tt.render.sprites[1].offset = v(0, -2)
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("aura_malik_land", "aura")
E:add_comps(tt, "render")
tt.render.sprites[1].name = "malik_attack_decal_run"
tt.render.sprites[1].anchor = v(0.5, 0.45)
tt.render.sprites[1].offset = v(0, 0)
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.aura.duration = fts(27)
tt.aura.mods = {
	"mod_malik_attack_ray",
	"mod_malik_land_damage"
}
tt.aura.cycle_time = 1e+99
tt.aura.radius = 80
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = bor(F_MOD, F_AREA)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("mod_malik_land_damage", "mod_damage")
tt.damage_min = 137
tt.damage_max = 164
tt.damage_type = DAMAGE_PHYSICAL

tt = E:register_t("hero_eiskalt", "hero5")
b = balance.heroes.hero_eiskalt
E:add_comps(tt, "ranged", "timed_attacks")
tt.hero.level_stats.hp_max = {
	300,
	325,
	350,
	375,
	400,
	425,
	450,
	475,
	500,
	525
}
tt.hero.level_stats.regen_health = {
	22,
	25,
	28,
	31,
	34,
	37,
	40,
	43,
	46,
	49
}
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
tt.hero.level_stats.ranged_damage_min = {
	14,
	19,
	24,
	29,
	34,
	39,
	44,
	49,
	54,
	59
}
tt.hero.level_stats.ranged_damage_max = {
	22,
	29,
	36,
	43,
	50,
	57,
	64,
	71,
	78,
	85
}
-- fierce_breath
tt.hero.skills.fierce_breath = E:clone_c("hero_skill")
tt.hero.skills.fierce_breath.hr_cost = {
	3,
	2,
	1
}
tt.hero.skills.fierce_breath.max_effects = {
	3,
	4,
	5
}
tt.hero.skills.fierce_breath.max_air_effects = {
	6,
	7,
	8
}
tt.hero.skills.fierce_breath.effect_range = {
	15,
	25,
	35
}
tt.hero.skills.fierce_breath.air_effect_range = {
	35,
	37.5,
	40
}
tt.hero.skills.fierce_breath.hr_order = 1
tt.hero.skills.fierce_breath.hr_available = true
tt.hero.skills.fierce_breath.damage_area = b.fierce_breath.damage_area
tt.hero.skills.fierce_breath.key = "FIERCE_BREATH"
-- cold_fury
tt.hero.skills.cold_fury = E:clone_c("hero_skill")
tt.hero.skills.cold_fury.hr_cost = {
	3,
	2,
	1
}
tt.hero.skills.cold_fury.hr_order = 2
tt.hero.skills.cold_fury.hr_available = true
tt.hero.skills.cold_fury.cooldown = {
	20,
	16,
	12
}
tt.hero.skills.cold_fury.xp_gain = {
	80,
	120,
	160
}
tt.hero.skills.cold_fury.key = "COLD_FURY"
-- ice_ball
tt.hero.skills.ice_ball = E:clone_c("hero_skill")
tt.hero.skills.ice_ball.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.ice_ball.hr_order = 3
tt.hero.skills.ice_ball.hr_available = true
tt.hero.skills.ice_ball.xp_gain = {
	90,
	135,
	180
}
tt.hero.skills.ice_ball.duration = {
	7.5,
	7.5,
	7.5
}
tt.hero.skills.ice_ball.damage_over_time = b.ice_ball.damage_over_time
tt.hero.skills.ice_ball.key = "ICE_BALL"
-- ice_peaks
tt.hero.skills.ice_peaks = E:clone_c("hero_skill")
tt.hero.skills.ice_peaks.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.ice_peaks.hr_order = 4
tt.hero.skills.ice_peaks.hr_available = true
tt.hero.skills.ice_peaks.hp_damage_factor = {
	0.1,
	0.2,
	0.3
}
tt.hero.skills.ice_peaks.damage_boss = b.ice_peaks.damage_boss
tt.hero.skills.ice_peaks.key = "ICE_PEAKS"
tt.hero.skills.ice_peaks.xp_gain = {
	137,
	206,
	274
}
-- ultimate
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.hr_cost = {
	1,
	4,
	4,
	4
}
tt.hero.skills.ultimate.controller_name = "hero_eiskalt_ultimate"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.hr_available = true
tt.hero.skills.ultimate.key = "ULTIMATE"
tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown
tt.hero.skills.ultimate.duration = b.ultimate.duration

tt.hero.team = TEAM_DARK_ARMY
tt.health.dead_lifetime = 30
tt.health_bar.draw_order = -1
tt.health_bar.offset = v(0, 175)
tt.health_bar.sort_y_offset = -200
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.z = Z_FLYING_HEROES
tt.hero.fn_level_up = customScripts1.hero_eiskalt.level_up
tt.hero.tombstone_show_time = nil
tt.hero.tombstone_decal = nil
tt.hero.use_custom_spawn_point = true
tt.idle_flip.chance = 0
tt.info.fn = scripts.hero_basic.get_info_ranged
tt.info.damage_icon = "magic"
tt.info.hero_portrait = "hero_portraits_0120"
tt.info.i18n_key = "HERO_EISKALT"
tt.info.portrait = "portraits_hero_0120"
tt.info.ultimate_icon = "0120"
tt.info.stat_hp = 8
tt.info.stat_armor = 0
tt.info.stat_damage = 10
tt.info.stat_cooldown = 4
tt.main_script.update = customScripts1.hero_eiskalt.update
tt.motion.max_speed = 90
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
tt.drag_line_origin_offset = v(0, 100)
tt.regen.cooldown = 2
tt.render.sprites[1].anchor.y = 0.04
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_eiskalt"
tt.render.sprites[1].angles.walk = {
	"idle"
}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].name = "hero_eiskalt_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.change_rally_point = "group_hero_eiskalt_taunt"
tt.sound_events.death = "hero_eiskalt_taunt_death"
tt.sound_events.respawn = "HeroLevelUp"
tt.sound_events.hero_room_select = "hero_eiskalt_taunt_1"
tt.ui.click_rect = r(-45, 30, 90, 90)
tt.unit.head_offset = v(0, 130)
tt.unit.hit_offset = v(0, 92)
tt.unit.mod_offset = v(0, 91)
tt.unit.hide_after_death = nil
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)

tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].bullet = "bolt_eiskalt"
tt.ranged.attacks[1].bullet_start_offset = {
	v(55, 65)
}
tt.ranged.attacks[1].min_range = b.basic_attack.min_range
tt.ranged.attacks[1].max_range = b.basic_attack.max_range
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].shoot_time = fts(16)
tt.ranged.attacks[1].node_prediction = fts(32)
-- cold_fury
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].skill = "range_unit"
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].bullet = "flame_cold_fury"
tt.timed_attacks.list[1].min_range = b.cold_fury.min_range
tt.timed_attacks.list[1].max_range = b.cold_fury.max_range
tt.timed_attacks.list[1].cooldown = 20
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].node_prediction = fts(17)
tt.timed_attacks.list[1].sync_animation = true
tt.timed_attacks.list[1].animation = "coldFury"
tt.timed_attacks.list[1].sound = "hero_jigou_breath"
tt.timed_attacks.list[1].bullet_start_offset = {
	v(41, 72)
}
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND, F_NIGHTMARE, F_FLYING, F_CLIFF)
tt.timed_attacks.list[1].xp_from_skill = "cold_fury"
-- ice_ball
tt.timed_attacks.list[2] = E:clone_c("bullet_attack")
tt.timed_attacks.list[2].skill = "range_unit"
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].search_type = U.search_type.find_max_crowd
tt.timed_attacks.list[2].use_center = true
tt.timed_attacks.list[2].bullet = "bomb_ice_ball"
tt.timed_attacks.list[2].min_range = b.ice_ball.min_range
tt.timed_attacks.list[2].max_range = b.ice_ball.max_range
tt.timed_attacks.list[2].cooldown = 18
tt.timed_attacks.list[2].cast_time = 0.72
tt.timed_attacks.list[2].node_prediction = fts(41)
tt.timed_attacks.list[2].sync_animation = true
tt.timed_attacks.list[2].animation = "frosty"
tt.timed_attacks.list[2].sound = "hero_eiskalt_frosty_throw"
tt.timed_attacks.list[2].sound_args = {
	delay = 0.5
}
tt.timed_attacks.list[2].min_targets = 2
tt.timed_attacks.list[2].crowd_range = 60
tt.timed_attacks.list[2].bullet_start_offset = {
	v(20, 98)
}
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[2].vis_bans = bor(F_FRIEND, F_NIGHTMARE, F_FLYING, F_CLIFF, F_WATER)
tt.timed_attacks.list[2].xp_from_skill = "ice_ball"
-- ice_peaks
tt.timed_attacks.list[3] = E:clone_c("aura_attack")
tt.timed_attacks.list[3].skill = "object_on_target"
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].use_caster_position = true
tt.timed_attacks.list[3].use_center = true
tt.timed_attacks.list[3].entity = "controller_aura_ice_peak"
tt.timed_attacks.list[3].animation = "icePeaks"
tt.timed_attacks.list[3].sync_animation = true
tt.timed_attacks.list[3].cast_time = fts(11)
tt.timed_attacks.list[3].cooldown = b.ice_peaks.cooldown
tt.timed_attacks.list[3].sound = "hero_eiskalt_icepeaks"
tt.timed_attacks.list[3].min_range = b.ice_peaks.min_range
tt.timed_attacks.list[3].max_range = b.ice_peaks.max_range
tt.timed_attacks.list[3].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[3].vis_bans = bor(F_FRIEND, F_NIGHTMARE, F_CLIFF, F_FLYING)
tt.timed_attacks.list[3].xp_from_skill = "ice_peaks"

tt = E:register_t("bolt_eiskalt", "bolt")
E:add_comps(tt, "force_motion")
tt.bullet.damage_type = b.basic_attack.damage_type
tt.bullet.xp_gain_factor = 2
tt.bullet.level = 0
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_radius = 0
tt.bullet.particles_name = "ps_bolt_eiskalt"
tt.bullet.hit_fx = "rain_controller_fx_hero_eiskalt_explosion"
tt.bullet.hit_fx_air = "rain_controller_fx_hero_eiskalt_explosion_air"
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.mod = "mod_eiskalt_frozen_throat_slow"
tt.bullet.flip_x = true
tt.bullet.align_with_trajectory = true
tt.bullet.pop = {
	"pop_lightning1",
	"pop_lightning2",
	"pop_lightning3"
}
tt.bullet.pop_chance = 0.1
tt.bullet.shot_index = 1
tt.bullet.use_unit_damage_factor = true
tt.bullet.ignore_hit_offset = true
tt.initial_impulse = 10
tt.initial_impulse_duration = 10
tt.initial_impulse_angle = math.pi / 6
tt.force_motion.a_step = 35
tt.force_motion.max_a = 3500
tt.force_motion.max_v = 350
tt.render.sprites[1].name = "hero_eiskalt_proyectile_travel"
tt.render.sprites[1].prefix = nil
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BULLETS
function tt.main_script.insert(this, store, script)
	return true
end
tt.main_script.update = customScripts1.custom_bolt.update
tt.sound_events.insert = "hero_beresad_attack_shot"
tt.sound_events.hit = "bomb_hit_sound"

tt = E:register_t("mod_eiskalt_frozen_throat_slow", "mod_slow")
tt.shader = "p_tint"
tt.shader_args = {
	tint_color = {
		0.6235294117647059,
		0.9176470588235294,
		1,
		1
	}
}
tt.slow.factor = 0.7
tt.modifier.duration = 3
tt.main_script.update = customScripts1.mod_eiskalt_frozen_throat_slow.update
tt.main_script.remove = customScripts1.mod_eiskalt_frozen_throat_slow.remove

tt = E:register_t("mod_cold_fury_ice", "mod_eiskalt_frozen_throat_slow")
tt.slow.factor = 0.3
tt.modifier.duration = 0.3

tt = E:register_t("mod_ice_peak", "mod_eiskalt_frozen_throat_slow")
tt.slow.factor = 0.5
tt.modifier.duration = 0.2

tt = E:register_t("ps_bolt_eiskalt")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "hero_eiskalt_particle_run"
tt.particle_system.anchor.x = 0.9
tt.particle_system.anchor.y = 0.5
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.track_rotation = true
tt.particle_system.emission_rate = 15
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(10)
}
tt.particle_system.z = tt.particle_system.z - 1

tt = E:register_t("fx_hero_eiskalt_explosion", "fx")
tt.render.sprites[1].name = "hero_eiskalt_explosion_run"
tt.render.sprites[1].anchor.y = 0.314
tt.render.sprites[1].sort_y_offset = -3

tt = E:register_t("rain_controller_fx_hero_eiskalt_explosion", "rain_controller")
tt.main_script.update = customScripts1.rain_controller_fx_hero_eiskalt_explosion.update
tt.entity_name = "fx_hero_eiskalt_explosion"
tt.max_entities = 1
tt.delay_between_objects = 0.07
tt.radius = 0

tt = E:register_t("fx_hero_eiskalt_explosion_air", "fx")
tt.render.sprites[1].name = "hero_eiskalt_explosion_air_run"
tt.render.sprites[1].scale = v(0.7, 0.7)

tt = E:register_t("rain_controller_fx_hero_eiskalt_explosion_air", "rain_controller_fx_hero_eiskalt_explosion")
tt.entity_name = "fx_hero_eiskalt_explosion_air"
tt.max_entities = 1
tt.delay_between_objects = 0.07
tt.radius = 0

tt = E:register_t("flame_cold_fury", "flame")
tt.render = nil
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_min = b.cold_fury.damage_min
tt.bullet.damage_max = b.cold_fury.damage_max
tt.bullet.damage_radius = 65
tt.bullet.hit_payload = {
	"aura_cold_fury_ice",
	"controller_aura_cold_fury_ice"
}
tt.bullet.flight_time = fts(15)
tt.bullet.ignore_hit_offset = true
tt.delay_betweeen_flames = fts(2)
tt.flame_bullet = "flame_bullet_cold_fury"
tt.flames_count = 12

tt = E:register_t("flame_bullet_cold_fury", "flame_bullet")
tt.render.sprites[1].name = "hero_eiskalt_cold_fury_particle_travel"
tt.render.sprites[1].fps = 15

tt = E:register_t("controller_aura_cold_fury_ice", "controller_spawn_on_path")
tt.exclude_first_position = true
tt.nodes_between_objects = 3
tt.delay_between_objects = 0.12
tt.max_entities = 4
tt.entity_name = "aura_cold_fury_ice_with_delay"

tt = E:register_t("aura_cold_fury_ice", "aura")
E:add_comps(tt, "render", "tween")
tt.render.sprites[1].name = "hero_eiskalt_cold_fury_ice"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.325
tt.render.sprites[1].offset.y = -25
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "hero_eiskalt_cold_fury_smoke_run"
tt.render.sprites[2].loop = true
tt.render.sprites[2].anchor.y = 0.21
tt.render.sprites[2].offset.y = -25
tt.aura.duration = 8
tt.aura.mods = {
	"mod_cold_fury_ice"
}
tt.aura.cycle_time = 0.2
tt.aura.radius = 40
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = bor(F_MOD, F_AREA)
tt.tween.props[1].name = "alpha"
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
		tt.aura.duration - 0.3,
		255
	},
	{
		tt.aura.duration,
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].name = "alpha"
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
		1.3,
		255
	},
	{
		1.6,
		0
	}
}
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("aura_cold_fury_ice_with_delay", "aura_cold_fury_ice")
tt.aura.duration = 6
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
		tt.aura.duration - 0.3,
		255
	},
	{
		tt.aura.duration,
		0
	}
}

tt = E:register_t("bomb_ice_ball", "bombKR5")
tt.bullet.damage_min = b.ice_ball.damage_min
tt.bullet.damage_max = b.ice_ball.damage_max
tt.bullet.damage_radius = 75
tt.bullet.flight_time = fts(35)
tt.bullet.rotation_speed = 6 * FPS * math.pi / 35
tt.bullet.hit_fx = "fx_frosty_explosion"
tt.bullet.hit_fx_water = "fx_frosty_explosion"
tt.bullet.hit_decal = nil
tt.bullet.hit_payload = "hero_eiskalt_frosty"
tt.sound_events.hit = "hero_eiskalt_frosty_impact_loopstart"
tt.render.sprites[1].name = "hero_eiskalt_frosty_projectile"

tt = E:register_t("fx_frosty_explosion", "fx")
tt.render.sprites[1].name = "hero_eiskalt_frosty_explotion_run"
tt.render.sprites[1].anchor.y = 0.136
tt.render.sprites[1].sort_y_offset = -3

tt = RT("hero_eiskalt_frosty", "aura_wander")
tt.render.sprites[1].prefix = "hero_eiskalt_frosty"
tt.render.sprites[1].name = "walk"
tt.render.sprites[1].anchor.y = 0.162
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].name = "hero_eiskalt_frosty_shadow"
tt.render.sprites[2].anchor.y = 0.162
tt.render.sprites[2].z = Z_DECALS + 1
tt.nav_path.dir = -1
tt.nav_path.pi = 1
tt.nav_path.spi = 1
tt.nav_path.ni = 1
tt.motion.max_speed = 40
tt.aura.duration = 7.5
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.cycle_time = 0.25
tt.aura.radius = 60
tt.aura.damage_min = 0
tt.aura.damage_max = 0
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.hit_blood_fx = "fx_blood_splat"
tt.dead_lifetime = 5
tt.sound_events.death = "hero_eiskalt_frosty_explodes"
tt.fade_in = nil
tt.fade_out = true

tt = E:register_t("aura_ice_peak", "aura")
E:add_comps(tt, "render")
tt.render.sprites[1].prefix = "hero_eiskalt_ice_peaks"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0.186
tt.render.sprites[1].sort_y_offset = -1
tt.random_flip_x = true
tt.random_scale = 0.8
tt.hp_damage_factor = 0
tt.damage_boss = 0
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.duration = 0.86
tt.aura.mods = {
	"mod_ice_peak"
}
tt.aura.cycle_time = 0.1
tt.aura.radius = 27.5
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = bor(F_MOD, F_AREA)
tt.main_script.update = customScripts1.aura_ice_peak.update

tt = E:register_t("controller_aura_ice_peak", "controller_spawn_on_path")
tt.entity_name = "aura_ice_peak"
tt.max_entities = 12
tt.delay_between_objects = 0.08
tt.random_offset.x.min = -4
tt.random_offset.x.max = 4

tt = E:register_t("mod_hero_eiskalt_ultimate_freeze", "mod_item_winter_age_freeze")
tt.modifier.duration = 0.3

tt = E:register_t("hero_eiskalt_ultimate")
E:add_comps(tt, "pos", "main_script", "sound_events", "render")
function tt.can_fire_fn(this, x, y, store)
	return true
end
tt.render.sprites[1].name = "white_rectangle"
tt.render.sprites[1].scale = v(2800, 1536)
tt.render.sprites[1].animated = false
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.period = 1
tt.alpha_min = 95
tt.alpha_max = 127
tt.main_script.update = customScripts1.hero_eiskalt_ultimate.update
tt.mods = {
	"mod_hero_eiskalt_ultimate_freeze"
}
tt.cycle_time = 0.2
tt.vis_bans = bor(F_BOSS, F_FRIEND)
tt.vis_flags = bor(F_MOD)
tt.freeze_delay_min = 3
tt.freeze_delay_max = 5
tt.cooldown = 70
tt.duration = 0
tt.particle_name = "hero_eiskalt_ultimate_snow"
tt.particles = {}
tt.max_particles = 2000
tt.speed = 750
tt.emission = 5
tt.life = 5
tt.life_var = 1
tt.position = v(-100, REF_H + 8)
tt.position_var_x = 1500
tt.radian = -3 / 4 * math.pi
tt.radian_var = 18 / 180 * math.pi
tt.sound_events.insert = "level10_icestorm"

tt = RT("hero_eiskalt_ultimate_snow")
AC(tt, "render", "pos")
tt.render.sprites[1].name = "hero_eiskalt_copo"
tt.render.sprites[1].scale = v(0.4375, 0.4375)
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS + 1
tt.scale = 0.4375
tt.scale_var = 0.0625
tt.speed = {}

tt = E:register_t("controller_item_hero_jack_o_lantern", "controller_item_hero")
tt.entity = "hero_jack_o_lantern"

tt = E:register_t("hero_jack_o_lantern", "hero5")
E:add_comps(tt, "melee", "timed_attacks", "teleport")
tt.hero.level_stats.hp_max = {
	175,
	192,
	210,
	228,
	245,
	262,
	280,
	298,
	315,
	333
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
tt.hero.level_stats.armor = {
	0.05,
	0.09,
	0.13,
	0.17,
	0.21,
	0.25,
	0.29,
	0.33,
	0.37,
	0.41
}
tt.hero.level_stats.melee_damage_min = {
	12,
	15,
	19,
	22,
	26,
	30,
	33,
	37,
	40,
	44
}
tt.hero.level_stats.melee_damage_max = {
	20,
	27,
	33,
	40,
	46,
	52,
	59,
	65,
	72,
	79
}
-- explosive_head
tt.hero.skills.explosive_head = E:clone_c("hero_skill")
tt.hero.skills.explosive_head.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.explosive_head.hr_order = 1
tt.hero.skills.explosive_head.hr_available = true
tt.hero.skills.explosive_head.damage = {
	40,
	80,
	120
}
tt.hero.skills.explosive_head.key = "EXPLOSIVE_HEAD"
tt.hero.skills.explosive_head.xp_gain = {
	40,
	40,
	40
}
-- haunted_blade
tt.hero.skills.haunted_blade = E:clone_c("hero_skill")
tt.hero.skills.haunted_blade.hr_cost = {
	1,
	1,
	1
}
tt.hero.skills.haunted_blade.hr_order = 2
tt.hero.skills.haunted_blade.hr_available = true
tt.hero.skills.haunted_blade.cooldown = {
	16,
	8,
	4
}
tt.hero.skills.haunted_blade.xp_gain = {
	90,
	180,
	270
}
tt.hero.skills.haunted_blade.key = "HAUNTED_BLADE"
-- hero_jacko_melee
tt.hero.skills.hero_jacko_melee = E:clone_c("hero_skill")
tt.hero.skills.hero_jacko_melee.hr_cost = {
	2,
	1,
	1
}
tt.hero.skills.hero_jacko_melee.accumulated_damage_factor = {
	0.4,
	0.7,
	1
}
tt.hero.skills.hero_jacko_melee.hr_order = 3
tt.hero.skills.hero_jacko_melee.hr_available = true
tt.hero.skills.hero_jacko_melee.key = "HERO_JACKO_MELEE"
-- hero_jacko_thriller
tt.hero.skills.hero_jacko_thriller = E:clone_c("hero_skill")
tt.hero.skills.hero_jacko_thriller.hr_cost = {
	3,
	2,
	2
}
tt.hero.skills.hero_jacko_thriller.hr_order = 4
tt.hero.skills.hero_jacko_thriller.hr_available = true
tt.hero.skills.hero_jacko_thriller.max_bullets = {
	2,
	3,
	4
}
tt.hero.skills.hero_jacko_thriller.xp_gain = {
	100,
	200,
	300
}
tt.hero.skills.hero_jacko_thriller.key = "HERO_JACKO_THRILLER"
-- ultimate
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.hr_cost = {
	1,
	6,
	5,
	5
}
tt.hero.skills.ultimate.controller_name = "hero_jack_o_lantern_ultimate"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.hr_available = true
tt.hero.skills.ultimate.key = "ULTIMATE"
tt.hero.skills.ultimate.cooldown = {
	40,
	40,
	40,
	40
}
tt.hero.skills.ultimate.damage_over_time = {
	4,
	7,
	13,
	20
}
tt.hero.skills.ultimate.max_range = 250
tt.hero.skills.ultimate.range_nodes_max = 45
tt.hero.skills.ultimate.min_targets = 5

tt.hero.team = TEAM_DARK_ARMY
tt.hero.fn_level_up = customScripts1.hero_jack_o_lantern.level_up
tt.hero.tombstone_show_time = nil
tt.hero.tombstone_decal = nil
tt.hero.use_custom_spawn_point = true
tt.hero.death_loop_animation = "idleDeath"
tt.health.dead_lifetime = 20
tt.health.accumulated_damage_factor = 0
tt.health_bar.draw_order = -1
tt.health_bar.offset = v(0, 53)
tt.health_bar.sort_y_offset = -200
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.z = Z_FLYING_HEROES
tt.idle_flip.chance = 0
tt.info.fn = scripts.hero_basic.get_info_melee
-- tt.info.hero_portrait = "hero_portraits_0120"
tt.info.i18n_key = "HERO_JACK_O_LANTERN"
tt.info.portrait = "bottom_info_image_enemies_0057"
-- tt.info.ultimate_icon = "0120"
tt.info.stat_hp = 5
tt.info.stat_armor = 4
tt.info.stat_damage = 10
tt.info.stat_cooldown = 4
tt.main_script.update = customScripts1.hero_jack_o_lantern.update
tt.motion.max_speed = 80
tt.drag_line_origin_offset = v(0, 0)
tt.regen.cooldown = 2
tt.render.sprites[1].anchor.y = 0.281
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_jack_o_lantern"
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].name = "hero_jack_o_lantern_shadow"
tt.render.sprites[2].anchor.y = 0.281
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.change_rally_point = "group_hero_jacko_taunt"
tt.sound_events.death = "hero_jacko_taunt_death"
tt.sound_events.respawn = "HeroLevelUp"
tt.sound_events.insert = "hero_jacko_taunt_1"
-- tt.sound_events.hero_room_select = "hero_jacko_taunt_1"
tt.teleport.min_distance = 150
tt.teleport.delay = 0
tt.teleport.sound = "group_hero_jacko_teleport"
tt.teleport.animations = {
	"teleportOut",
	"teleportIn"
}
tt.teleport.fx_out = "hero_jack_o_lantern_teleportfx"
tt.ui.click_rect = r(-29, -5, 58, 105)
tt.unit.head_offset = v(0, 48)
tt.unit.hit_offset = v(0, 30)
tt.unit.mod_offset = v(0, 30)
tt.unit.hide_after_death = nil
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET)
tt.soldier.melee_slot_offset = v(25, 0)
tt.melee.range = 60
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].fn_damage = function(this, store, attack, target)
	local value = math.ceil(this.unit.damage_factor * math.random(attack.damage_min, attack.damage_max)) + this.health.accumulated_damage
	this.health.accumulated_damage = 0
	return value
end
tt.melee.attacks[1].damage_min = 180
tt.melee.attacks[1].damage_max = 180
tt.melee.attacks[1].hit_time = fts(7)
tt.melee.attacks[1].cooldown = 2
-- tt.melee.attacks[1].xp_gain_factor = 20
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].basic_attack = nil
tt.melee.attacks[2].animation = "hauntedBlade"
tt.melee.attacks[2].hit_time = fts(15)
tt.melee.attacks[2].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[2].cooldown = 4
tt.melee.attacks[2].mod = "mod_hero_jacko_reduce_armor"
-- tt.melee.attacks[2].xp_gain_factor = 270
-- explosive_head
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].skill = "range_unit"
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].melee_break = true
tt.timed_attacks.list[1].search_type = U.search_type.find_max_crowd
tt.timed_attacks.list[1].min_targets = 1
tt.timed_attacks.list[1].bullet = "bomb_explosive_head"
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 175
tt.timed_attacks.list[1].cooldown = 4
tt.timed_attacks.list[1].extra_cooldown = -5
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].node_prediction = fts(22)
tt.timed_attacks.list[1].animation = "explosiveHead"
tt.timed_attacks.list[1].bullet_start_offset = {
	v(22, 36)
}
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND, F_NIGHTMARE, F_CLIFF)
-- tt.timed_attacks.list[1].xp_from_skill = "explosive_head"
-- hero_jacko_thriller
tt.timed_attacks.list[2] = E:clone_c("bullet_attack")
tt.timed_attacks.list[2].skill = "range_at_path"
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].use_center = nil
tt.timed_attacks.list[2].melee_break = true
tt.timed_attacks.list[2].bullet = "hero_jack_o_lantern_spawner_seed"
tt.timed_attacks.list[2].max_bullets = 4
tt.timed_attacks.list[2].range_nodes = 25
tt.timed_attacks.list[2].min_targets = 2
tt.timed_attacks.list[2].cooldown = 30
tt.timed_attacks.list[2].min_nodes = -3
tt.timed_attacks.list[2].max_nodes = -1
tt.timed_attacks.list[2].cast_time = fts(10)
tt.timed_attacks.list[2].animation = "spawnGhouls"
tt.timed_attacks.list[2].bullet_start_offset = {
	v(19, 55)
}
tt.timed_attacks.list[2].vis_bans = bor(F_FRIEND, F_FLYING)
-- tt.timed_attacks.list[2].xp_from_skill = "hero_jacko_thriller"

tt = RT("mod_hero_jacko_reduce_armor", "mod_damage_magical_armor")
tt.damage_min = 1
tt.damage_max = 1

tt = E:register_t("hero_jack_o_lantern_teleportfx", "fx")
tt.render.sprites[1].name = "hero_jack_o_lantern_teleportfx_run"
tt.render.sprites[1].anchor.y = 0.281

tt = E:register_t("bomb_explosive_head", "KR5Bomb")
tt.bullet.damage_min = 120
tt.bullet.damage_max = 120
tt.bullet.damage_radius = 75
tt.bullet.flight_time = fts(20)
tt.bullet.rotation_speed = 3 * FPS * math.pi / 20
tt.bullet.pop_chance = 0.1
tt.bullet.hit_fx = "fx_hero_jack_o_lantern_explosion"
tt.bullet.hit_fx_water = "fx_hero_jack_o_lantern_explosion"
tt.render.sprites[1].name = "hero_jack_o_lantern_head_proyectile"

tt = E:register_t("fx_hero_jack_o_lantern_explosion", "fx")
tt.render.sprites[1].name = "hero_jack_o_lantern_explotion_run"
tt.render.sprites[1].anchor.y = 0.169
tt.render.sprites[1].sort_y_offset = -2

tt = E:register_t("hero_jack_o_lantern_spawner_seed", "KR5Bomb")
tt.bullet.damage_min = 64
tt.bullet.damage_max = 64
tt.bullet.damage_radius = 50
tt.bullet.flight_time = fts(22)
tt.bullet.rotation_speed = 2 * FPS * math.pi / 22
tt.bullet.hit_fx = "fx_hero_jack_o_lantern_spawner_hit"
tt.bullet.hit_fx_water = "fx_hero_jack_o_lantern_spawner_hit"
tt.bullet.hit_decal = "hero_jack_o_lantern_spawner_seed_decal"
tt.bullet.hit_payload = "hero_jacko_ghoul"
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil
tt.render.sprites[1].name = "hero_jack_o_lantern_spawner_seed_travel"
tt.render.sprites[1].animated = true

tt = E:register_t("fx_hero_jack_o_lantern_spawner_hit", "fx_fade")
tt.render.sprites[1].name = "hero_jack_o_lantern_spawner_hit_run"
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].z = Z_OBJECTS
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(56),
		255
	},
	{
		fts(71),
		0
	}
}

tt = E:register_t("hero_jack_o_lantern_spawner_seed_decal", "decal_timed")
tt.render.sprites[1].name = "hero_jack_o_lantern_spawner_seed_decal_run"
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].z = Z_DECALS

tt = RT("hero_jacko_ghoul", "soldier_hover")
E:add_comps(tt, "reinforcement")
tt.health.armor = 0.2
tt.health.magic_armor = 0
tt.health.hp_max = 320
tt.health_bar.offset = v(0, 32)
tt.unit.hit_offset = v(0, 16)
tt.unit.head_offset = v(0, 29)
tt.unit.mod_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.portrait = "bottom_info_image_soldiers_0048"
tt.info.random_name_format = nil
tt.info.random_name_count = nil
tt.motion.max_speed = 30
tt.render.sprites[1].prefix = "hero_jack_o_lantern_ghoul"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.125
tt.render.sprites[1].angles.walk = {
	"walk",
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_jack_o_lantern_ghoul_shadow"
tt.render.sprites[2].anchor.y = 0.125
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(16, 0)
tt.melee.range = 75
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(9)
tt.regen.health = 8
tt.regen.cooldown = 0.5
tt.reinforcement.duration = 20
tt.ui.click_rect = r(-20, -5, 40, 28)
tt.hover.cooldown_min = 5
tt.hover.cooldown_max = 15
tt.hover.random_ni = 6
tt.fade_out = true
tt.insert_delay = 1.2

tt = E:register_t("hero_jack_o_lantern_ultimate")
E:add_comps(tt, "pos", "main_script", "sound_events")
tt.can_fire_fn = customScripts1.summoning_hero_ultimate.can_fire_fn
tt.main_script.update = customScripts1.hero_jack_o_lantern_ultimate.update
tt.cooldown = 40
tt.entity = "hero_jacko_horse"
tt.sound_events.insert = "hero_jacko_horses"

tt = RT("hero_jacko_horse", "aura_wander")
tt.render.sprites[1].prefix = "hero_jack_o_lantern_ultimate_horse"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.3
tt.render.sprites[1].sort_y_offset = -32
tt.render.sprites[2] = nil
tt.motion.max_speed = 90
tt.aura.duration = 6
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.cycle_time = 0.25
tt.aura.radius = 65
tt.aura.damage_min = 0
tt.aura.damage_max = 0
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.mods = {
	"mod_hero_jacko_horse_intimidation"
}
tt.aura.hit_blood_fx = nil
tt.spawn_animation = nil
tt.death_animation = nil
tt.dead_lifetime = nil
tt.fade_in = true
tt.fade_out = true
tt.particle = {
	"ps_hero_jack_o_lantern_ultimate_particle",
	"ps_hero_jack_o_lantern_ultimate_smoke"
}

tt = E:register_t("ps_hero_jack_o_lantern_ultimate_particle")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "hero_jack_o_lantern_ultimate_particle_run"
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.track_offset = v(0, 29)
tt.particle_system.emission_rate = 3
tt.particle_system.animation_fps = 30
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_OBJECTS + 1

tt = E:register_t("ps_hero_jack_o_lantern_ultimate_smoke")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "hero_jack_o_lantern_ultimate_smoke_run"
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.track_offset = v(0, 29)
tt.particle_system.emission_rate = 2
tt.particle_system.animation_fps = 46
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_OBJECTS + 2

tt = RT("mod_hero_jacko_horse_intimidation", "mod_intimidation")
E:add_comps(tt, "render")
tt.modifier.duration = fts(8)
tt.modifier.health_bar_offset = v(0, -8)
tt.speed_factor = 3
tt.main_script.update = customScripts1.mod_track_target_with_fade.update
tt.render.sprites[1].name = "hero_jack_o_lantern_ultimate_fear_modifier_run"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].loop = true
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].size_scales = {
	vv(1),
	vv(1.3),
	vv(1.5)
}

tt = E:register_t("hero_dianyun", "hero5")
b = balance.heroes.hero_dianyun
E:add_comps(tt, "ranged", "timed_attacks", "auras")
tt.hero.level_stats.hp_max = {
	320,
	338,
	356,
	374,
	392,
	410,
	428,
	446,
	464,
	482
}
tt.hero.level_stats.regen_health = {
	22,
	25,
	28,
	31,
	34,
	37,
	40,
	43,
	46,
	49
}
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
tt.hero.level_stats.ranged_damage_min = {
	2,
	4,
	6,
	8,
	10,
	12,
	14,
	16,
	18,
	20
}
tt.hero.level_stats.ranged_damage_max = {
	6,
	10,
	14,
	18,
	22,
	27,
	31,
	35,
	39,
	43
}
-- ricochet
tt.hero.skills.ricochet = E:clone_c("hero_skill")
tt.hero.skills.ricochet.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.ricochet.hr_order = 1
tt.hero.skills.ricochet.hr_available = true
tt.hero.skills.ricochet.damage_min = b.ricochet.damage_min
tt.hero.skills.ricochet.damage_max = b.ricochet.damage_max
tt.hero.skills.ricochet.bounce = b.ricochet.bounce
tt.hero.skills.ricochet.cooldown = {
	18,
	18,
	18
}
tt.hero.skills.ricochet.xp_gain = {
	60,
	120,
	180
}
tt.hero.skills.ricochet.key = "RICOCHET"
-- lord storm
tt.hero.skills.lord_storm = E:clone_c("hero_skill")
tt.hero.skills.lord_storm.hr_cost = {
	1,
	1,
	1
}
tt.hero.skills.lord_storm.hr_order = 2
tt.hero.skills.lord_storm.hr_available = true
tt.hero.skills.lord_storm.max_targets = {
	2,
	3,
	4
}
tt.hero.skills.lord_storm.key = "LORD_STORM"
-- divine rain
tt.hero.skills.divine_rain = E:clone_c("hero_skill")
tt.hero.skills.divine_rain.hr_cost = {
	2,
	1,
	1
}
tt.hero.skills.divine_rain.hr_order = 3
tt.hero.skills.divine_rain.hr_available = true
tt.hero.skills.divine_rain.xp_gain = {
	104,
	208,
	312
}
tt.hero.skills.divine_rain.cooldown = {
	15,
	15,
	15
}
tt.hero.skills.divine_rain.duration = {
	5,
	5,
	5
}
tt.hero.skills.divine_rain.healing_points_tick = b.divine_rain.healing_points_tick
tt.hero.skills.divine_rain.key = "DIVINE_RAIN"
-- supreme wave
tt.hero.skills.supreme_wave = E:clone_c("hero_skill")
tt.hero.skills.supreme_wave.hr_cost = {
	3,
	2,
	2
}
tt.hero.skills.supreme_wave.hr_order = 4
tt.hero.skills.supreme_wave.hr_available = true
tt.hero.skills.supreme_wave.cooldown = {
	21,
	21,
	21
}
tt.hero.skills.supreme_wave.stun = {
	2,
	3,
	4
}
tt.hero.skills.supreme_wave.xp_gain = {
	70,
	140,
	210
}
tt.hero.skills.supreme_wave.key = "SUPREME_WAVE"
-- ultimate
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_dianyun_ultimate"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.hr_cost = {
	1,
	6,
	5,
	5
}
tt.hero.skills.ultimate.hr_available = true
tt.hero.skills.ultimate.key = "ULTIMATE"
tt.hero.skills.ultimate.bullets_to_death = {
	3,
	5,
	10,
	15
}
tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown

tt.hero.team = TEAM_DARK_ARMY
tt.health.dead_lifetime = 30
tt.health_bar.draw_order = -1
tt.health_bar.offset = v(0, 130)
tt.health_bar.sort_y_offset = -200
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
-- tt.health_bar.z = Z_FLYING_HEROES
tt.hero.fn_level_up = customScripts1.hero_dianyun.level_up
tt.hero.tombstone_show_time = nil
tt.hero.tombstone_decal = nil
tt.hero.use_custom_spawn_point = true
tt.idle_flip.chance = 0
tt.info.damage_icon = "magic"
tt.info.fn = customScripts1.hero_dianyun.get_info
tt.info.hero_portrait = "hero_portraits_0103"
tt.info.i18n_key = "HERO_DIANYUN"
tt.info.portrait = "portraits_hero_0103"
tt.info.ultimate_icon = "0103"
tt.info.stat_hp = 8
tt.info.stat_armor = 0
tt.info.stat_damage = 5
tt.info.stat_cooldown = 4
tt.main_script.insert = customScripts1.hero_dianyun.insert
tt.main_script.update = customScripts1.hero_dianyun.update
tt.motion.max_speed = 42
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
tt.drag_line_origin_offset = v(0, 80)
tt.regen.cooldown = 2
tt.render.sprites[1].anchor.y = 0.04
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "hero_dianyun"
tt.render.sprites[1].angles.walk = {
	"idle"
}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].name = "hero_dianyun_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
-- cloud 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[3].offset = v(15, 50)
tt.render.sprites[3].alpha = 204
tt.render.sprites[3].z = Z_FLYING_HEROES + 1
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "hero_storm_dragon_cloud_l2"
tt.render.sprites[4].offset = v(15, 50)
tt.render.sprites[4].alpha = 204
tt.render.sprites[4].z = Z_FLYING_HEROES + 1
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].prefix = "hero_storm_dragon_cloud_l3"
tt.render.sprites[5].offset = v(15, 50)
tt.render.sprites[5].alpha = 204
tt.render.sprites[5].z = Z_FLYING_HEROES + 1
-- cloud 2
tt.render.sprites[6] = E:clone_c("sprite")
tt.render.sprites[6].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[6].scale = v(0.75, 0.75)
tt.render.sprites[6].offset = v(-20, 60)
tt.render.sprites[6].alpha = 204
tt.render.sprites[6].z = Z_FLYING_HEROES
-- cloud 3
tt.render.sprites[7] = E:clone_c("sprite")
tt.render.sprites[7].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[7].scale = v(0.666, 0.666)
tt.render.sprites[7].offset = v(5, 70)
tt.render.sprites[7].alpha = 204
tt.render.sprites[7].z = Z_FLYING_HEROES + 1
-- cloud 4
tt.render.sprites[8] = E:clone_c("sprite")
tt.render.sprites[8].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[8].scale = v(0.6, 0.6)
tt.render.sprites[8].offset = v(-5, 83)
tt.render.sprites[8].alpha = 204
tt.render.sprites[8].z = Z_FLYING_HEROES
-- cloud 5
tt.render.sprites[9] = E:clone_c("sprite")
tt.render.sprites[9].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[9].scale = v(0.666, 0.666)
tt.render.sprites[9].offset = v(50, 60)
tt.render.sprites[9].alpha = 204
tt.render.sprites[9].z = Z_FLYING_HEROES - 2
-- cloud 6
tt.render.sprites[10] = E:clone_c("sprite")
tt.render.sprites[10].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[10].scale = v(0.6, 0.6)
tt.render.sprites[10].offset = v(57, 70)
tt.render.sprites[10].alpha = 204
tt.render.sprites[10].z = Z_FLYING_HEROES - 1
-- cloud 7
tt.render.sprites[11] = E:clone_c("sprite")
tt.render.sprites[11].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[11].scale = v(0.75, 0.75)
tt.render.sprites[11].offset = v(40, 80)
tt.render.sprites[11].alpha = 204
tt.render.sprites[11].z = Z_FLYING_HEROES - 2
-- cloud 8
tt.render.sprites[12] = E:clone_c("sprite")
tt.render.sprites[12].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[12].scale = v(0.6, 0.6)
tt.render.sprites[12].offset = v(-40, 75)
tt.render.sprites[12].alpha = 204
tt.render.sprites[12].z = Z_FLYING_HEROES
-- cloud 9
tt.render.sprites[13] = E:clone_c("sprite")
tt.render.sprites[13].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[13].scale = v(0.6, 0.6)
tt.render.sprites[13].offset = v(-40, 88)
tt.render.sprites[13].alpha = 204
tt.render.sprites[13].z = Z_FLYING_HEROES
-- cloud 10
tt.render.sprites[14] = E:clone_c("sprite")
tt.render.sprites[14].prefix = "hero_storm_dragon_cloud_l1"
tt.render.sprites[14].scale = v(0.6, 0.6)
tt.render.sprites[14].offset = v(-55, 88)
tt.render.sprites[14].alpha = 204
tt.render.sprites[14].z = Z_FLYING_HEROES + 1

tt.sound_events.change_rally_point = "HeroDianyunTaunt"
tt.sound_events.death = "HeroDianyunTauntDeath"
tt.sound_events.respawn = "HeroLevelUp"
tt.sound_events.hero_room_select = "HeroDianyunTauntSelect"
tt.ui.click_rect = r(-60, 30, 120, 90)
tt.unit.hide_after_death = nil
tt.unit.head_offset = v(0, 120)
tt.unit.hit_offset = v(0, 85)
tt.unit.mod_offset = v(0, 90)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
-- lord storm
tt.ranged.attacks[1] = E:clone_c("spawn_attack")
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].entity = "controller_lord_storm"
tt.ranged.attacks[1].bullet = "hero_dianyun_lightning"
tt.ranged.attacks[1].min_range = b.basic_attack.min_range
tt.ranged.attacks[1].max_range = b.basic_attack.max_range
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[1].xp_gain_factor = 1.5
-- ricochet
tt.ranged.attacks[2] = E:clone_c("bullet_attack")
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].cooldown = 18
tt.ranged.attacks[2].min_cooldown = 1
tt.ranged.attacks[2].min_range = b.ricochet.min_range
tt.ranged.attacks[2].max_range = b.ricochet.max_range
tt.ranged.attacks[2].bullet = "hero_dianyun_lightning_ricochet_cloud"
tt.ranged.attacks[2].spawn_pos_offset = v(0, 81)
tt.ranged.attacks[2].start_fx = "fx_hero_dianyun_lightning_ricochet"
tt.ranged.attacks[2].start_offset = v(0, 90)
tt.ranged.attacks[2].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[2].vis_flags = bor(F_RANGED)
tt.ranged.attacks[2].min_targets = 2
tt.ranged.attacks[2].crowds_range = 90
tt.ranged.attacks[2].xp_from_skill = "ricochet"
-- divine rain
tt.timed_attacks.list[1] = E:clone_c("aura_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].aura = "aura_hero_dianyun_divine_rain"
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].crowds_range = 50
tt.timed_attacks.list[1].health_trigger_factor = 0.75
tt.timed_attacks.list[1].min_range = b.divine_rain.min_range
tt.timed_attacks.list[1].max_range = b.divine_rain.max_range
tt.timed_attacks.list[1].cast_time = fts(20)
tt.timed_attacks.list[1].animation = "healingRain"
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY)
tt.timed_attacks.list[1].xp_from_skill = "divine_rain"
-- supreme wave
tt.timed_attacks.list[2] = E:clone_c("aura_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].cast_time = fts(24)
tt.timed_attacks.list[2].entity = "aura_hero_dianyun_supreme_wave"
tt.timed_attacks.list[2].floor_decal = "floor_decal_hero_dianyun_supreme_wave"
tt.timed_attacks.list[2].controller = "controller_decal_hero_dianyun_supreme_wave_spawner"
tt.timed_attacks.list[2].animation = "supremeWave"
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[2].vis_bans = bor(F_NIGHTMARE, F_CLIFF, F_BOSS)
tt.timed_attacks.list[2].min_range = b.supreme_wave.min_range
tt.timed_attacks.list[2].max_range = b.supreme_wave.max_range
tt.timed_attacks.list[2].min_targets = 3
tt.timed_attacks.list[2].crowds_range = 150
tt.timed_attacks.list[2].start_nodes_offset = 3
tt.timed_attacks.list[2].distance_to_start_node = 20
tt.timed_attacks.list[2].max_objects = 5
tt.timed_attacks.list[2].nodes_between_objects = 6
tt.timed_attacks.list[2].delay_between_objects = fts(3)
tt.timed_attacks.list[2].xp_from_skill = "supreme_wave"
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].cooldown = 0
tt.auras.list[1].name = "aura_dianyun_passive"

tt = E:register_t("hero_dianyun_lightning", "bullet")
tt.main_script.update = customScripts1.hero_dianyun_lightning.update
tt.render.sprites[1].name = "hero_storm_dragon_lightning"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].r = -math.pi / 2
tt.bullet.hit_time = fts(2)
tt.bullet.hit_fx = "fx_hero_dianyun_lightning_hit"
tt.bullet.mod = "mod_hero_dianyun_lightning"
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.use_unit_damage_factor = true
tt.sound_events.insert = "WarmongerMageAttack"

tt = E:register_t("fx_hero_dianyun_lightning_hit", "fx")
tt.render.sprites[1].name = "hero_storm_dragon_lightning_hit"
tt.render.sprites[1].anchor = v(0.5, 0.5)

tt = E:register_t("mod_hero_dianyun_lightning", "mod_common_stun")
E:add_comps(tt, "tween")
tt.modifier.duration = fts(20)
tt.render.sprites[1].prefix = "hero_storm_dragon_lightning_modifier"
tt.render.sprites[1].anchor = v(0.5, 0.625)
tt.render.sprites[1].size_names = nil
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {
	{
		tt.modifier.duration - fts(8),
		255
	},
	{
		tt.modifier.duration,
		0
	}
}

tt = E:register_t("controller_lord_storm")
E:add_comps(tt, "pos", "main_script", "sound_events")
tt.bullet = "hero_dianyun_lightning"
tt.spawn_pos_offset = v(0, 81)
tt.delay_between_rays = 0.5
tt.max_targets = 1
tt.main_script.update = customScripts1.controller_lord_storm.update

tt = E:register_t("hero_dianyun_lightning_ricochet_cloud", "bullet")
tt.main_script.update = customScripts1.hero_dianyun_lightning_ricochet_cloud.update
tt.render.sprites[1].name = "hero_storm_dragon_lightning_ricochet_cloud"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].r = -math.pi / 2
tt.bullet.hit_time = fts(2)
tt.bullet.hit_fx = "fx_hero_dianyun_lightning_ricochet_hit"
tt.bullet.mod = "mod_hero_dianyun_storm_ray"
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bounce_bullet = "hero_dianyun_lightning_ricochet"
tt.bounce_range = 90
tt.bounce_vis_flags = bor(F_RANGED)
tt.bounce_vis_bans = bor(F_NIGHTMARE)
tt.bounce_delay = fts(2)
tt.sound_events.insert = "WarmongerMageAttack"

tt = E:register_t("fx_hero_dianyun_lightning_ricochet_hit", "fx")
tt.render.sprites[1].name = "hero_storm_dragon_lightning_ricochet_hit"
tt.render.sprites[1].anchor = v(0.5, 0.5)

tt = E:register_t("mod_hero_dianyun_storm_ray", "mod_hero_dianyun_lightning")
tt.render.sprites[1].prefix = "hero_storm_ray_modifier"

tt = E:register_t("hero_dianyun_lightning_ricochet", "bullet")
tt.main_script.update = customScripts1.hero_dianyun_lightning_ricochet.update
tt.render.sprites[1].name = "hero_storm_dragon_lightning_ricochet"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.image_width = 69
tt.bullet.hit_time = fts(2)
tt.bullet.hit_fx = "fx_hero_dianyun_lightning_ricochet_hit"
tt.bullet.mod = "mod_hero_dianyun_storm_ray"
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.sound_events.insert = "WarmongerMageAttack"

tt = E:register_t("fx_hero_dianyun_lightning_ricochet", "fx")
for i = 1, 3, 1 do
	if i > 1 then
		tt.render.sprites[i] = E:clone_c("sprite")
	end
	tt.render.sprites[i].name = "hero_storm_dragon_lightning_ricochet_fx_l" .. tostring(i)
	tt.render.sprites[i].anchor = v(0.5, 0.5)
	tt.render.sprites[i].z = Z_FLYING_HEROES + 1
end

tt = E:register_t("aura_hero_dianyun_divine_rain", "aura")
E:add_comps(tt, "render", "tween")
tt.render.sprites[1].prefix = "hero_dianyun_health_rain"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].anchor = v(0.5, 0)
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.aura.duration = 5
tt.aura.mods = {
	"mod_kr4_heal"
}
tt.aura.cycle_time = 0.5
tt.aura.radius = b.divine_rain.radius
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_MOD, F_AREA)
tt.tween.props[1].name = "alpha"
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
		tt.aura.duration - 0.3,
		255
	},
	{
		tt.aura.duration,
		0
	}
}
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("mod_kr4_heal", "modifier")
E:add_comps(tt, "hps", "render")
tt.modifier.duration = 0.6
tt.hps.heal_min = nil
tt.hps.heal_max = nil
tt.hps.heal_every = 0.5
tt.render.sprites[1].name = "kr4_heal_loop"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].loop = true
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update

tt = E:register_t("aura_hero_dianyun_supreme_wave", "aura")
E:add_comps(tt, "render")
tt.render.sprites[1].name = "hero_storm_dragon_supreme_wave"
tt.render.sprites[1].anchor = v(0.5, 0.2)
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS + 1
tt.aura.duration = fts(71)
tt.aura.mods = {
	"mod_kr4_stun",
	"mod_supreme_wave_damage"
}
tt.aura.cycle_time = 1e+99
tt.aura.radius = 50
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = bor(F_MOD, F_AREA)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("mod_kr4_stun", "mod_common_stun")
tt.render.sprites[1].prefix = "kr4_stun"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].size_names = nil
tt.modifier.use_mod_offset = nil
tt.modifier.health_bar_offset = v(0, -2)

tt = E:register_t("mod_supreme_wave_damage", "mod_damage")
b = balance.heroes.hero_dianyun
tt.damage_max = b.supreme_wave.damage
tt.damage_min = b.supreme_wave.damage
tt.damage_type = b.supreme_wave.damage_type

tt = E:register_t("floor_decal_hero_dianyun_supreme_wave", "decal_tween")
tt.render.sprites[1].name = "hero_storm_dragon_supreme_wave_decal"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(14),
		0
	},
	{
		fts(14),
		255
	},
	{
		fts(49),
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		v(0, 0)
	},
	{
		fts(14),
		v(0, 0)
	},
	{
		fts(14),
		v(0.7, 0.7)
	},
	{
		fts(49),
		v(1, 1)
	}
}
tt.tween.props[2].sprite_id = 1

tt = E:register_t("controller_decal_hero_dianyun_supreme_wave_spawner")
E:add_comps(tt, "main_script")
tt.main_script.update = customScripts1.controller_decal_hero_dianyun_supreme_wave_spawner.update

tt = E:register_t("aura_dianyun_passive", "aura")
tt.aura.mod = "mod_dianyun_passive"
tt.aura.cycle_time = fts(3)
tt.aura.duration = -1
tt.aura.radius = 200
tt.aura.track_source = true
tt.aura.track_dead = true
tt.aura.vis_flags = F_MOD
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("mod_dianyun_passive", "modifier")
tt.modifier.duration = fts(4)
tt.modifier.vis_flags = F_MOD
tt.main_script.insert = customScripts1.mod_dianyun_passive.insert
tt.main_script.remove = customScripts1.mod_dianyun_passive.remove
tt.main_script.update = scripts.mod_track_target.update
tt.fx = "fx_hero_dianyun_lantern"
tt.gold_reward = b.passive.gold_reward

tt = E:register_t("fx_hero_dianyun_lantern", "fx")
tt.render.sprites[1].name = "hero_storm_dragon_lantern"
tt.render.sprites[1].anchor = v(0.5, 0.111)
tt.render.sprites[1].draw_order = DO_MOD_FX

tt = E:register_t("hero_dianyun_ultimate")
E:add_comps(tt, "pos", "main_script", "sound_events")
tt.can_fire_fn = customScripts1.summoning_hero_ultimate.can_fire_fn
tt.main_script.update = customScripts1.summoning_hero_ultimate.update
tt.cooldown = 45
tt.entity = "hero_dianyun_electric_son"
tt.sound_events.insert = "HeroDianyunSon"

tt = E:register_t("hero_dianyun_electric_son", "decal_scripted")
E:add_comps(tt, "ranged", "idle_flip")
tt.main_script.update = customScripts1.hero_dianyun_electric_son.update
tt.duration = b.ultimate.duration
tt.render.sprites[1].prefix = "hero_storm_dragon_electric_son"
tt.render.sprites[1].anchor = v(0.5, 0.16)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "hero_storm_dragon_electric_son_shadow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].anchor = v(0.5, 0.16)
tt.render.sprites[2].offset = v(0, 0)
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].max_range = b.ultimate.max_range
tt.ranged.attacks[1].min_range = b.ultimate.min_range
tt.ranged.attacks[1].bullet = "bolt_hero_dianyun_electric_son"
tt.ranged.attacks[1].shoot_time = 0.4
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[1].bullet_start_offset = v(10, 40)

tt = E:register_t("initial_bolt", "bolt")
tt.render.sprites[1].prefix = nil
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.flip_x = nil
tt.sound_events.insert = nil
tt.main_script.insert = nil
tt.main_script.update = customScripts1.initial_bolt.update

tt = E:register_t("bolt_hero_dianyun_electric_son", "bolt")
E:add_comps(tt, "force_motion")
tt.bullet.damage_type = b.ultimate.damage_type
tt.bullet.damage_min = 120
tt.bullet.damage_max = 180
tt.bullet.hit_fx = "fx_hero_dianyun_lightning_hit"
tt.bullet.mod = "mod_stun_electric_son"
tt.bullet.max_speed = 600
tt.bullet.align_with_trajectory = true
tt.bullet.min_speed = 30
tt.bullet.pop_chance = 0
tt.bullet.shot_index = 1
tt.initial_impulse = 10
tt.initial_impulse_duration = 10
tt.initial_impulse_angle = math.pi / 4
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 600
tt.render.sprites[1].name = "hero_storm_dragon_electric_son_bolt"
tt.render.sprites[1].prefix = nil
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS
function tt.main_script.insert(this, store, script)
	return true
end
tt.main_script.update = customScripts1.custom_bolt.update
tt.sound_events.insert = "BoltReleaseSound"

tt = E:register_t("mod_stun_electric_son", "mod_common_stun")
tt.modifier.duration = b.ultimate.stun

tt = E:register_t("decal_kr1_hero_tombstone", "decal_hero_tombstone")
tt.render.sprites[1].name = "hero_tombstone_0001"
tt.render.sprites[1].anchor = v(0.5, 0.5)

tt = E:register_t("decal_kr3_hero_tombstone", "decal_kr1_hero_tombstone")
tt.render.sprites[1].name = "hero_tombstone_0003"

-- towers
tt = E:register_t("tower_twilight_elves_barrack_lvl2", "tower_KR5")
E:add_comps(tt, "barrack", "vis")
tt.barrack.rally_range = 180
tt.barrack.respawn_offset = v(0, 0)
tt.barrack.soldier_type = "elves_soldier_harasser_lvl2"
tt.barrack.max_soldiers = 2
tt.info.fn = scripts.tower_barrack.get_info
tt.info.portrait = "portraits_towers_0111"
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.remove = scripts.tower_barrack.remove
tt.main_script.update = scripts.tower_barrack.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].anchor.y = 0.13
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "twilight_elves_barrack_tower_lvl2_layer1_0001"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].anchor.y = 0.13
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "close"
tt.render.sprites[3].offset = v(0, 0)
tt.render.sprites[3].prefix = "twilight_elves_barrack_tower_lvl2"
tt.sound_events.mute_on_level_insert = true
tt.sound_events.change_rally_point = "kr4_elves_barrack_taunt"
tt.sound_events.insert = "kr4_elves_barrack_taunt"
tt.sound_events.open_door = "open_door_sound"
tt.tower.level = 1
tt.tower.price = 160
tt.tower.type = "twilight_elves_barrack"
tt.tower.kind = TOWER_KIND_BARRACK
tt.tower.team = TEAM_DARK_ARMY
tt.tower.menu_offset = v(0, 15)
tt.ui.click_rect = r(-40, 0, 80, 70)

tt = E:register_t("tower_twilight_elves_barrack_lvl3", "tower_twilight_elves_barrack_lvl2")
tt.barrack.soldier_type = "elves_soldier_harasser_lvl3"
tt.render.sprites[2].name = "twilight_elves_barrack_tower_lvl3_layer1_0001"
tt.render.sprites[3].prefix = "twilight_elves_barrack_tower_lvl3"
tt.tower.level = 2
tt.tower.price = 200

tt = E:register_t("tower_twilight_elves_barrack_lvl4", "tower_twilight_elves_barrack_lvl3")
E:add_comps(tt, "powers")
tt.powers.backstab = E:clone_c("power")
tt.powers.backstab.price = { 120, 120 }
tt.powers.backstab.max_level = 2
tt.powers.arrow_storm = E:clone_c("power")
tt.powers.arrow_storm.price = { 140, 140, 140 }
tt.powers.last_breath = E:clone_c("power")
tt.powers.last_breath.price = { 250 }
tt.powers.last_breath.max_level = 1
tt.barrack.soldier_type = "elves_soldier_harasser_lvl4"
tt.render.sprites[2].name = "twilight_elves_barrack_tower_lvl4_layer1_0001"
tt.render.sprites[2].anchor.y = 0.11
tt.render.sprites[2].offset = v(0, 3)
tt.render.sprites[3].prefix = "twilight_elves_barrack_tower_lvl4"
tt.render.sprites[3].anchor.y = 0.11
tt.render.sprites[3].offset = v(0, 3)
tt.tower.level = 3
tt.tower.price = 250

tt = E:register_t("elves_soldier_harasser_lvl2", "soldier_militia")
E:add_comps(tt, "dodge", "ranged", "nav_grid")
tt.health.armor = 0
tt.health.dead_lifetime = 12
tt.health.hp_max = 130
tt.health_bar.offset = v(0, 31)
tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
tt.idle_flip.chance = 0.4
tt.idle_flip.cooldown = 5
tt.info.fn = scripts.soldier_barrack.get_info
tt.info.portrait = "bottom_info_image_soldiers_0016"
tt.info.random_name_count = 10
tt.info.random_name_format = "ELVES_SOLDIER_HARASSER_%i_NAME"
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.update = customScripts1.kr4_soldier_barrack.update
tt.main_script.remove = scripts.soldier_barrack.remove
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = 0.8
tt.melee.attacks[1].damage_max = 13
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = 0.33
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].hit_time = 0.3
tt.melee.attacks[2].chance = 0.5
tt.melee.range = 50
tt.melee.cooldown = 0.8
tt.dodge.animation = "dodge"
tt.dodge.hide_shadow = true
tt.dodge.chance = 0.3
tt.dodge.chance_inc = 0.1
tt.dodge.power_name = "backstab"
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].bullet = "elves_soldier_harasser_arrow_lvl2"
tt.ranged.attacks[1].bullet_start_offset = {
	v(6, 24)
}
tt.ranged.attacks[1].cooldown = 0.9
tt.ranged.attacks[1].max_range = 180
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = 0.3
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.motion.max_speed = 85
tt.regen.cooldown = 2
tt.regen.health = 13
tt.render.sprites[1].anchor.y = 0.142
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[1].prefix = "elves_soldier_harasser_lvl2"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "elves_soldier_harasser_lvl2_shadow"
tt.render.sprites[2].anchor.y = 0.142
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(11, 0)
tt.ui.click_rect = r(-10, -2, 20, 25)
tt.unit.hit_offset = v(0, 9)
tt.unit.head_offset = v(0, 29)
tt.unit.mod_offset = v(0, 13)
tt.unit.marker_offset = v(0, 0)
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF)

tt = E:register_t("elves_soldier_harasser_lvl3", "elves_soldier_harasser_lvl2")
tt.health.hp_max = 160
tt.health_bar.offset = v(0, 31)
tt.info.portrait = "bottom_info_image_soldiers_0017"
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[2].damage_max = 25
tt.melee.attacks[2].damage_min = 15
tt.ranged.attacks[1].bullet = "elves_soldier_harasser_arrow_lvl3"
tt.ranged.attacks[1].bullet_start_offset = {
	v(7, 24)
}
tt.regen.health = 16
tt.render.sprites[1].prefix = "elves_soldier_harasser_lvl3"
tt.render.sprites[2].name = "elves_soldier_harasser_lvl3_shadow"

tt = E:register_t("elves_soldier_harasser_lvl4", "elves_soldier_harasser_lvl3")
E:add_comps(tt, "powers", "death_spawns")
tt.health.hp_max = 220
tt.health_bar.offset = v(0, 28)
tt.unit.head_offset = v(0, 27)
tt.info.portrait = "bottom_info_image_soldiers_0018"
tt.powers.backstab = E:clone_c("power")
tt.powers.arrow_storm = E:clone_c("power")
tt.powers.last_breath = E:clone_c("power")
tt.melee.attacks[1].damage_max = 35
tt.melee.attacks[1].damage_min = 25
tt.melee.attacks[2].damage_max = 35
tt.melee.attacks[2].damage_min = 25
tt.dodge.animation = "backstab"
tt.dodge.counter_attack = E:clone_c("melee_attack")
tt.dodge.counter_attack.animation = "backstabHit"
tt.dodge.counter_attack.cooldown = 0.5
tt.dodge.counter_attack.damage_type = DAMAGE_TRUE
tt.dodge.counter_attack.damage_max = 15
tt.dodge.counter_attack.damage_min = 10
tt.dodge.counter_attack.damage_max_config = { 15, 30 }
tt.dodge.counter_attack.damage_min_config = { 10, 20 }
tt.dodge.counter_attack.hit_time = 0.1
tt.dodge.counter_attack.power_name = "backstab"
tt.ranged.attacks[1].bullet = "elves_soldier_harasser_arrow_lvl4"
tt.ranged.attacks[1].bullet_start_offset = {
	v(5, 23)
}
tt.ranged.attacks[2] = E:clone_c("bullet_attack")
tt.ranged.attacks[2].vis_bans = bor(F_FRIEND, F_NIGHTMARE)
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].power_name = "arrow_storm"
tt.ranged.attacks[2].bullet = "elves_soldier_harasser_arrow_multishoot"
tt.ranged.attacks[2].bullet_start_offset = {
	v(4, 22)
}
tt.ranged.attacks[2].animations = {
	"inshoot",
	"multishoot",
	"outshoot"
}
tt.ranged.attacks[2].loops = 5
tt.ranged.attacks[2].shoot_times = {
	0.1
}
tt.ranged.attacks[2].cooldown = 12
tt.ranged.attacks[2].max_range = 200
tt.ranged.attacks[2].min_range = 50
tt.regen.health = 22
tt.render.sprites[1].anchor.y = 0.125
tt.render.sprites[1].prefix = "elves_soldier_harasser_lvl4"
tt.render.sprites[2].anchor.y = 0.125
tt.render.sprites[2].name = "elves_soldier_harasser_lvl4_shadow"
tt.soldier.melee_slot_offset = v(12, 0)
tt.death_spawns.name = "elves_soldier_espectral_harasser"
tt.death_spawns.quantity = 1
tt.main_script.update = customScripts1.elves_soldier_harasser_lvl4.update

tt = E:register_t("elves_soldier_espectral_harasser", "soldier_militia")
E:add_comps(tt, "reinforcement", "nav_grid")
tt.health.armor = 0
tt.health.hp_max = 330
tt.health.dead_lifetime = 6
tt.health_bar.offset = v(0, 33)
tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
tt.idle_flip.chance = 0.4
tt.idle_flip.cooldown = 5
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.portrait = "bottom_info_image_soldiers_0019"
tt.reinforcement.duration = 6
tt.reinforcement.fade = false
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = customScripts1.elves_soldier_espectral_harasser.update
tt.sound_events.raise = "elves_eliteharassers_lastbreath1"
tt.sound_events.raise_args = {
	delay = fts(13)
}
tt.sound_events.death = "elves_eliteharassers_lastbreath2"
tt.sound_events.death_args = {
	delay = fts(10)
}
tt.melee.range = 65
tt.melee.attacks[1].cooldown = 0.5
tt.melee.attacks[1].damage_min = 32
tt.melee.attacks[1].damage_max = 48
tt.melee.attacks[1].hit_time = 0.3
tt.motion.max_speed = 150
tt.regen.health = 0
tt.render.sprites[1].anchor.y = 0.116
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[1].prefix = "elves_soldier_espectral_harasser"
tt.render.sprites[1].name = "raise"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "elves_soldier_espectral_harasser_shadow"
tt.render.sprites[2].anchor.y = 0.116
tt.render.sprites[2].offset = v(0, 0)
tt.soldier.melee_slot_offset = v(12, 0)
tt.ui.click_rect = r(-10, -2, 20, 25)
tt.unit.hit_offset = v(0, 11)
tt.unit.head_offset = v(0, 31)
tt.unit.mod_offset = v(0, 13)
tt.unit.marker_offset = v(0, 0)
tt.unit.hide_after_death = true
tt.particle = "ps_elves_soldier_espectral_harasser_run_effect"

tt = E:register_t("ps_elves_soldier_espectral_harasser_run_effect")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "elves_soldier_espectral_harasser_run_effect_run"
tt.particle_system.anchor = v(0.5, 0.116)
tt.particle_system.sort_y_offset = -5
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.animation_fps = 20
tt.particle_system.emission_rate = 35
tt.particle_system.z = Z_DECALS + 1

tt = E:register_t("elves_soldier_harasser_arrow_lvl2", "arrow5_fixed_height")
tt.render.sprites[1].name = "elves_soldier_harasser_arrow"
tt.bullet.miss_decal = "elves_soldier_harasser_arrow_decal_0009"
tt.bullet.miss_decal_anchor = v(1, 0.5)
tt.bullet.damage_max = 13
tt.bullet.damage_min = 10
tt.bullet.fixed_height = 35
tt.bullet.g = -1000
tt.bullet.hide_radius = 1
tt.bullet.reset_to_target_pos = true
tt.bullet.use_unit_damage_factor = true

tt = E:register_t("elves_soldier_harasser_arrow_lvl3", "elves_soldier_harasser_arrow_lvl2")
tt.bullet.damage_max = 25
tt.bullet.damage_min = 15

tt = E:register_t("elves_soldier_harasser_arrow_lvl4", "elves_soldier_harasser_arrow_lvl3")
tt.bullet.damage_max = 35
tt.bullet.damage_min = 25

tt = E:register_t("elves_soldier_harasser_arrow_multishoot", "arrow5_45degrees")
tt.render.sprites[1].name = "elves_soldier_harasser_arrow_multishoot"
tt.bullet.miss_decal = "elves_soldier_harasser_arrow_multishoot_decal_0009"
tt.bullet.miss_decal_anchor = v(1, 0.5)
tt.bullet.damage_max = 24
tt.bullet.damage_min = 16
tt.bullet.damage_max_inc = 24
tt.bullet.damage_min_inc = 16
tt.sound_events.insert = "elves_arrow_release_sound"
tt.bullet.flight_time = fts(10)
tt.bullet.g = -0.7 / (fts(1) * fts(1))
tt.bullet.reset_to_target_pos = true

tt = E:register_t("dark_army_soldier_knight_lvl1", "soldier_militia")
E:add_comps(tt, "nav_grid", "reinforcement", "tween")
b = balance.heroes.hero_raelyn
tt.info.portrait = "bottom_info_image_soldiers_0020"
tt.info.random_name_count = 9
tt.info.random_name_format = "DARK_ARMY_SOLDIER_%i_NAME"
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.hero_raelyn_command_orders_dark_knight.update
tt.render.sprites[1].prefix = "dark_army_soldier_knight_lvl1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = v(0.5, 0.164)
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].anchor = v(0.5, 0.164)
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "darkarmy_soldier_lvl1_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.unit.marker_offset = v(0, 0)
tt.unit.hit_offset = v(0, 13)
tt.unit.mod_offset = v(0, 16)
tt.health.dead_lifetime = 2
tt.unit.fade_time_after_death = tt.health.dead_lifetime
tt.reinforcement.duration = b.ultimate.entity.duration
tt.reinforcement.fade = nil
tt.reinforcement.fade_out = nil
tt.soldier.melee_slot_offset = v(15, 0)
tt.soldier.melee_slot_spread = v(-8, -8)
tt.health_bar.offset = v(0, 31)
tt.health.hp_max = 100
tt.health.armor = 0.4
tt.regen.cooldown = 2
tt.regen.health = 10
tt.motion.max_speed = 75
tt.melee.range = 60
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 2
tt.melee.attacks[1].damage_max = 3
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
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
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		0
	},
	{
		fts(10),
		255
	}
}
tt.tween.props[2].name = "alpha"
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt.tween.reverse = false
tt.tween.disabled = true
tt.ui.click_rect = r(-10, -2, 20, 25)

tt = E:register_t("dark_army_soldier_knight_lvl2", "dark_army_soldier_knight_lvl1")
tt.info.portrait = "bottom_info_image_soldiers_0021"
tt.render.sprites[1].prefix = "dark_army_soldier_knight_lvl2"
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[2].name = "darkarmy_soldier_lvl2_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.15)
tt.unit.hit_offset = v(0, 12)
tt.unit.mod_offset = v(0, 15)
tt.soldier.melee_slot_offset = v(18, 0)
tt.health.hp_max = 140
tt.health.armor = 0.5
tt.regen.health = 13
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].damage_max = 10

tt = E:register_t("dark_army_soldier_knight_lvl3", "dark_army_soldier_knight_lvl2")
tt.info.portrait = "bottom_info_image_soldiers_0022"
tt.render.sprites[1].prefix = "dark_army_soldier_knight_lvl3"
tt.render.sprites[1].anchor = v(0.5, 0.112)
tt.render.sprites[2].name = "darkarmy_soldier_lvl3_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.112)
tt.soldier.melee_slot_offset = v(15, 0)
tt.health_bar.offset = v(0, 33)
tt.health.hp_max = 200
tt.health.armor = 0.6
tt.regen.health = 18
tt.melee.range = 65
tt.melee.attacks[1].damage_min = 7
tt.melee.attacks[1].damage_max = 20

tt = E:register_t("dark_army_soldier_knight_lvl4", "dark_army_soldier_knight_lvl3")
tt.info.portrait = "bottom_info_image_soldiers_0023"
for i = 1, 3 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].prefix = "darkarmy_soldier_lvl4_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].group = "layers"
	tt.render.sprites[i].anchor = v(0.5, 0.242)
end
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].anchor = v(0.5, 0.242)
tt.render.sprites[4].is_shadow = true
tt.render.sprites[4].animated = false
tt.render.sprites[4].name = "darkarmy_soldier_lvl4_shadow"
tt.render.sprites[4].offset = v(0, 0)
for i = 3, #tt.render.sprites do
	tt.tween.props[i] = E:clone_c("tween_prop")
	tt.tween.props[i].keys = {
		{
			0,
			0
		},
		{
			fts(10),
			255
		}
	}
	tt.tween.props[i].name = "alpha"
	tt.tween.props[i].sprite_id = i
end
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(0, 17)
tt.soldier.melee_slot_offset = v(17, 0)
tt.health_bar.offset = v(0, 42)
tt.health.hp_max = 260
tt.health.armor = 0.75
tt.health.spiked_armor_damage = 45
tt.health.spiked_armor_damage_type = DAMAGE_TRUE
tt.regen.health = 24
tt.melee.range = 70
tt.melee.attacks[1].cooldown = 1.6
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].damage_max = 36
tt.melee.attacks[1].forced_cooldown = true
tt.melee.attacks[2] = E:clone_c("melee_attack")
tt.melee.attacks[2].animation = "merciless"
tt.melee.attacks[2].chance = 0.1
tt.melee.attacks[2].cooldown = 1.5
tt.melee.attacks[2].hit_time = fts(50)
tt.melee.attacks[2].instakill = true
tt.melee.attacks[2].pop = {
	"pop_instakill"
}
tt.melee.attacks[2].forced_cooldown = true
tt.melee.attacks[2].sound = "DarkArmyBarrackBrutalStrike"
tt.melee.attacks[2].sound_args = {
	delay = 0.7
}
tt.melee.attacks[2].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER, F_BOSS, F_MINIBOSS)
tt.melee.forced_cooldown = tt.melee.attacks[1].cooldown
tt.ui.click_rect = r(-15, -2, 30, 35)

local tower_archer_1 = E:register_t("tower_archer_1", "tower_KR5")
E:add_comps(tower_archer_1, "attacks", "vis")
tower_archer_1.tower.kind = TOWER_KIND_ARCHER
tower_archer_1.tower.team = TEAM_LINIREA
tower_archer_1.tower.menu_offset = v(0, 20)
tower_archer_1.tower.type = "archer"
tower_archer_1.tower.level = 1
tower_archer_1.tower.price = 70
tower_archer_1.info.portrait = "portraits_towers_0118"
tower_archer_1.render.sprites[1].animated = false
tower_archer_1.render.sprites[1].name = "terrains_%04i"
tower_archer_1.render.sprites[1].offset = v(0, 14)
tower_archer_1.render.sprites[2] = E:clone_c("sprite")
tower_archer_1.render.sprites[2].animated = false
tower_archer_1.render.sprites[2].name = "archer_tower_0001"
tower_archer_1.render.sprites[2].offset = v(0, 39)
tower_archer_1.render.sprites[3] = E:clone_c("sprite")
tower_archer_1.render.sprites[3].prefix = "shooterarcherlvl1"
tower_archer_1.render.sprites[3].name = "idleDown"
tower_archer_1.render.sprites[3].angles = {}
tower_archer_1.render.sprites[3].angles.idle = {
	"idleUp",
	"idleDown"
}
tower_archer_1.render.sprites[3].angles.shoot = {
	"shootingUp",
	"shootingDown"
}
tower_archer_1.render.sprites[3].offset = v(-9, 53)
tower_archer_1.render.sprites[4] = E:clone_c("sprite")
tower_archer_1.render.sprites[4].prefix = "shooterarcherlvl1"
tower_archer_1.render.sprites[4].name = "idleDown"
tower_archer_1.render.sprites[4].angles = {}
tower_archer_1.render.sprites[4].angles.idle = {
	"idleUp",
	"idleDown"
}
tower_archer_1.render.sprites[4].angles.shoot = {
	"shootingUp",
	"shootingDown"
}
tower_archer_1.render.sprites[4].offset = v(9, 53)
tower_archer_1.main_script.insert = scripts.tower_archer.insert
tower_archer_1.main_script.update = scripts.tower_archer.update
tower_archer_1.main_script.remove = scripts.tower_archer.remove
tower_archer_1.attacks.range = 140
tower_archer_1.attacks.list[1] = E:clone_c("bullet_attack")
tower_archer_1.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tower_archer_1.attacks.list[1].bullet = "arrow_1"
tower_archer_1.attacks.list[1].cooldown = 0.8
tower_archer_1.attacks.list[1].shoot_time = fts(5)
tower_archer_1.attacks.list[1].bullet_start_offset = {
	v(-10, 52),
	v(10, 52)
}
tower_archer_1.sound_events.insert = "ArcherTaunt"

local arrow_2 = E:register_t("arrow_2", "arrow")
arrow_2.bullet.damage_min = 7
arrow_2.bullet.damage_max = 11

local tower_archer_2 = E:register_t("tower_archer_2", "tower_archer_1")
tower_archer_2.tower.level = 2
tower_archer_2.tower.price = 110
tower_archer_2.render.sprites[2].name = "archer_tower_0002"
tower_archer_2.render.sprites[3].prefix = "shooterarcherlvl2"
tower_archer_2.render.sprites[3].offset = v(-9, 54)
tower_archer_2.render.sprites[4].prefix = "shooterarcherlvl2"
tower_archer_2.render.sprites[4].offset = v(9, 54)
tower_archer_2.attacks.range = 160
tower_archer_2.attacks.list[1].bullet = "arrow_2"
tower_archer_2.attacks.list[1].cooldown = 0.6

local arrow_3 = E:register_t("arrow_3", "arrow")
arrow_3.bullet.damage_min = 10
arrow_3.bullet.damage_max = 16

local tower_archer_3 = E:register_t("tower_archer_3", "tower_archer_1")
tower_archer_3.tower.level = 3
tower_archer_3.tower.price = 160
tower_archer_3.render.sprites[2].name = "archer_tower_0003"
tower_archer_3.render.sprites[3].prefix = "shooterarcherlvl3"
tower_archer_3.render.sprites[3].offset = v(-9, 59)
tower_archer_3.render.sprites[4].prefix = "shooterarcherlvl3"
tower_archer_3.render.sprites[4].offset = v(9, 59)
tower_archer_3.attacks.range = 180
tower_archer_3.attacks.list[1].bullet = "arrow_3"
tower_archer_3.attacks.list[1].cooldown = 0.5

tt = E:register_t("ps_tower_spirit_mausoleum_bolt")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "spirit_mausoleum_particle"
tt.particle_system.animated = false
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	0.25,
	0.25
}
tt.particle_system.emission_rate = 50
tt.particle_system.scales_y = {
	1,
	0.1
}
tt.particle_system.scales_x = {
	1,
	1
}
tt.particle_system.alphas = {
	255,
	12
}

tt = E:register_t("fx_tower_spirit_mausoleum_bolt_hit", "fx")
tt.render.sprites[1].name = "spirit_mausoleum_bolt_hit"

tt = E:register_t("tower_spirit_mausoleum_lvl2_bolt", "initial_bolt")
E:add_comps(tt, "force_motion")
tt.render.sprites[1].name = "spirit_mausoleum_bolt_0001"
tt.render.sprites[1].prefix = nil
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_max = 20
tt.bullet.damage_min = 13
tt.bullet.hit_fx = "fx_tower_spirit_mausoleum_bolt_hit"
tt.bullet.particles_name = "ps_tower_spirit_mausoleum_bolt"
tt.bullet.align_with_trajectory = true
tt.bullet.max_speed = 90
tt.bullet.destination_offsets = {
	v(-25, 5),
	v(25, -5),
	v(-25, -5),
	v(25, 5)
}
tt.bullet.destination_index = 1
tt.initial_angle = math.pi * 5 / 12
tt.travel_impulse = 360
tt.max_acceleration = 600
tt.travel_step = 5
tt.travel_peak = 1
tt.travel_impulse_duration = fts(25)
tt.step_y = -2
tt.step_times = 12
tt.target_found = nil
tt.main_script.insert = nil
tt.main_script.update = customScripts1.tower_spirit_mausoleum_bolt.update
tt.initial_impulse = 848
tt.initial_impulse_duration = 0.1
tt.initial_impulse_angle = math.pi / 4
tt.force_motion.a_step = 10
tt.force_motion.max_a = 12000
tt.force_motion.max_v = 500
tt.sound_events.insert = nil

tt = E:register_t("tower_spirit_mausoleum_lvl3_bolt", "tower_spirit_mausoleum_lvl2_bolt")
tt.bullet.damage_max = 38
tt.bullet.damage_min = 26

tt = E:register_t("tower_spirit_mausoleum_lvl4_bolt", "tower_spirit_mausoleum_lvl2_bolt")
tt.bullet.damage_max = 71
tt.bullet.damage_min = 48

tt = E:register_t("fx_bolt_possession_spawn", "fx")
tt.render.sprites[1].name = "spirit_mausoleum_lvl4_possession_spawn_run"
tt.render.sprites[1].anchor = v(0.5, 0.14)
tt.render.sprites[1].z = Z_OBJECTS + 1

tt = E:register_t("fx_bolt_possession_hit", "fx")
tt.render.sprites[1].name = "spirit_mausoleum_lvl4_possession_proyectile_hit"

tt = RT("mod_possession", "modifier")
E:add_comps(tt, "render")
b = balance.towers.spirit_mausoleum
tt.render.sprites[1].prefix = "spirit_mausoleum_lvl4_possession_decal"
tt.render.sprites[1].anchor = v(0.5, 0.211)
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].size_scales = {
	vv(0.8),
	vv(1.1),
	vv(1.5)
}
tt.possession_duration = b.possession.duration
tt.modifier.duration = 10
tt.modifier.use_mod_offset = nil
tt.main_script.insert = customScripts1.mod_possession.insert
tt.main_script.update = customScripts1.mod_possession.update
tt.main_script.remove = customScripts1.mod_possession.remove

tt = E:register_t("bolt_possession", "initial_bolt")
E:add_comps(tt, "tween")
tt.render.sprites[1].name = "spirit_mausoleum_lvl4_possession_proyectile_travel"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.2,
		255
	}
}
tt.bullet.damage_type = 0
tt.bullet.acceleration_factor = 0.01
tt.bullet.min_speed = 100
tt.bullet.max_speed = 200
tt.bullet.max_track_distance = REF_H / 2
tt.bullet.flip_x = true
tt.bullet.mod = "mod_possession"
tt.bullet.hit_fx = "fx_bolt_possession_hit"
tt.sound_events.insert = "fallen_ones_spirit_mausoleum_possession_cast"
tt.sound_events.hit = "fallen_ones_spirit_mausoleum_possession_hit"

tt = E:register_t("fx_gargoyle_spawn", "fx")
tt.render.sprites[1].name = "spirit_mausoleum_lvl4_gargoyle_spawn_run"
tt.render.sprites[1].anchor = v(0.5, 0.14)
tt.render.sprites[1].offset = v(0, 2)
tt.render.sprites[1].z = Z_OBJECTS + 1

tt = RT("fallen_ones_gargoyle", "soldier_militia")
E:add_comps(tt, "nav_grid")
tt.health.armor = 0.6
tt.health.dead_lifetime = 15
tt.health.hp_max = 200
tt.health_bar.offset = v(0, 34)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.unit.hit_offset = v(0, 15)
tt.unit.head_offset = v(0, 24)
tt.unit.mod_offset = v(0, 15)
tt.unit.marker_offset = v(0, 0)
tt.info.portrait = "bottom_info_image_soldiers_0028"
tt.info.random_name_count = 7
tt.info.random_name_format = "FALLEN_ONES_ZOMBIE_%i_NAME"
tt.motion.max_speed = 50
tt.regen.health = 30
tt.regen.cooldown = 2
tt.render.sprites[1].prefix = "spirit_mausoleum_lvl4_gargoyle"
tt.render.sprites[1].anchor.y = 0.14
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "spirit_mausoleum_lvl4_gargoyle_shadow"
tt.render.sprites[2].anchor.y = 0.14
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(15, 0)
tt.melee.range = 60
tt.melee.attacks[1].damage_max = 24
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(14)
tt.ui.click_rect = r(-15, -2, 30, 35)
tt.main_script.update = customScripts1.kr4_soldier_barrack.update

tt = RT("draugr", "soldier_militia")
E:add_comps(tt, "nav_path", "reinforcement", "tween")
tt.health.armor = 0
tt.health.magic_armor = 0.8
tt.health.hp_max = 150
tt.health_bar.offset = v(0, 35)
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(-9, 30)
tt.unit.mod_offset = v(0, 13)
tt.unit.marker_offset = v(0, 0)
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.portrait = "bottom_info_image_soldiers_0029"
tt.info.random_name_count = 7
tt.info.random_name_format = "FALLEN_ONES_ZOMBIE_%i_NAME"
tt.motion.max_speed = 24
tt.render.sprites[1].prefix = "draugr"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].anchor.y = 0.24
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "draugr_shadow"
tt.render.sprites[2].anchor.y = 0.24
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].sort_y_offset = -1
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(10, 0)
tt.melee.range = 60
tt.melee.attacks[1].damage_max = 9
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].hit_time = fts(11)
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
tt.tween.disabled = true
tt.nav_path.dir = -1
tt.main_script.update = customScripts1.soldier_wander.update

tt = E:register_t("tower_spirit_mausoleum_lvl2", "tower_KR5")
E:add_comps(tt, "attacks", "vis")
tt.tower.type = "spirit_mausoleum"
tt.tower.kind = TOWER_KIND_MAGE
tt.tower.team = TEAM_DARK_ARMY
tt.tower.level = 1
tt.tower.price = 150
tt.tower.menu_offset = v(0, 19)
tt.info.i18n_key = "TOWER_SPIRIT_MAUSOLEUM_2"
tt.info.portrait = "portraits_towers_0124"
tt.info.fn = scripts.tower_mage.get_info
tt.main_script.update = customScripts1.tower_spirit_mausoleum.update
tt.main_script.remove = customScripts1.tower_spirit_mausoleum.remove
tt.attacks.range = 175
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].animation = "shootEmpty"
tt.attacks.list[1].charge_animation = "shoot"
tt.attacks.list[1].bullet = "tower_spirit_mausoleum_lvl2_bolt"
tt.attacks.list[1].max_charges = 3
tt.attacks.list[1].stored_bullets = {}
tt.attacks.list[1].cooldown = 1.45
tt.attacks.list[1].shoot_time = 0.9
tt.attacks.list[1].bullet_start_offset = v(-3, 65)
tt.attacks.list[1].node_prediction = 0
tt.attacks.list[1].sound = "fallen_ones_spirit_mausoleum_attack_preload"
tt.attacks.list[1].release_sound = "fallen_ones_spirit_mausoleum_attack"
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 13)
for i = 2, 4 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "spirit_mausoleum_lvl2_layer" .. i - 1
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].offset = v(0, 11)
	tt.render.sprites[i].anchor.y = 0.228
	tt.render.sprites[i].group = "layers"
end
tt.sound_events.insert = "fallen_ones_spirit_mausoleum_build_taunt"
tt.ui.click_rect = r(-37, 0, 74, 62)

tt = E:register_t("tower_spirit_mausoleum_lvl3", "tower_spirit_mausoleum_lvl2")
tt.tower.level = 2
tt.tower.price = 170
tt.info.i18n_key = "TOWER_SPIRIT_MAUSOLEUM_3"
tt.attacks.list[1].bullet = "tower_spirit_mausoleum_lvl3_bolt"
for i = 2, 4 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "spirit_mausoleum_lvl3_layer" .. i - 1
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].offset = v(0, 11)
	tt.render.sprites[i].anchor.y = 0.228
	tt.render.sprites[i].group = "layers"
end
tt.ui.click_rect = r(-39, 0, 78, 64)

tt = E:register_t("tower_spirit_mausoleum_lvl4", "tower_spirit_mausoleum_lvl2")
b = balance.towers.spirit_mausoleum
E:add_comps(tt, "barrack", "powers")
tt.tower.level = 3
tt.tower.price = 230
tt.info.i18n_key = "TOWER_SPIRIT_MAUSOLEUM_4"
tt.barrack.soldier_type = "fallen_ones_gargoyle"
tt.barrack.rally_range = 160
tt.barrack.max_soldiers = 0
tt.sound_events.change_rally_point = "fallen_ones_spirit_mausoleum_build_taunt"
tt.powers.spectral_communion = E:clone_c("power")
tt.powers.spectral_communion.price = { 175, 175 }
tt.powers.spectral_communion.max_level = 2
tt.powers.spectral_communion.max_charges = {
	4,
	5
}
tt.powers.spectral_communion.unit_type = {
	"draugr",
	"draugr"
}
tt.powers.spectral_communion.hp = b.spectral_communion.hp
tt.powers.spectral_communion.cooldown = b.spectral_communion.cooldown
tt.powers.possession = E:clone_c("power")
tt.powers.possession.price = { 200, 100, 100 }
tt.powers.possession.cooldown = b.possession.cooldown
tt.powers.gargoyles = E:clone_c("power")
tt.powers.gargoyles.price = { 250, 250 }
tt.powers.gargoyles.max_level = 2
tt.powers.gargoyles.spawn_positions = {
	v(2, -5),
	v(35, 3)
}
tt.powers.gargoyles.spawn_fx = "fx_gargoyle_spawn"
tt.powers.gargoyles.spawn_time = 0.26
tt.attacks.list[1].bullet = "tower_spirit_mausoleum_lvl4_bolt"
tt.attacks.list[1].bullet_start_offset = v(-7, 85)
tt.attacks.list[2] = E:clone_c("bullet_attack")
tt.attacks.list[2].animation = "cast"
tt.attacks.list[2].bullet_start_offset = {
	v(27, 17),
	v(29, 34)
}
tt.attacks.list[2].bullet = {
	"fx_bolt_possession_spawn",
	"bolt_possession"
}
tt.attacks.list[2].cooldown = 23
tt.attacks.list[2].vis_bans = bor(F_BOSS, F_MINIBOSS, F_FLYING, F_NIGHTMARE, F_CLIFF, F_WATER)
tt.attacks.list[2].vis_flags = bor(F_RANGED, F_BLOCK, F_POLYMORPH)
tt.attacks.list[2].shoot_time = 0.6
tt.attacks.list[2].hp_min = 240
tt.attacks.list[2].excluded_templates = {}
tt.attacks.list[3] = E:clone_c("custom_attack")
tt.attacks.list[3].animation = "cast"
tt.attacks.list[3].cooldown = 30
tt.attacks.list[3].cast_time = 0.6
tt.attacks.list[3].entity = "draugr"
tt.attacks.list[3].spawn_offset = v(25, 0)
tt.attacks.list[3].range = 120

for i = 2, 4 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "spirit_mausoleum_lvl4_layer" .. i - 1
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].offset = v(0, 8)
	tt.render.sprites[i].anchor.y = 0.24
	tt.render.sprites[i].group = "layers"
end
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].animated = false
tt.render.sprites[5].hidden = false
tt.render.sprites[5].name = "spirit_mausoleum_lvl4_gargoyle_idle_left"
tt.render.sprites[5].anchor.y = 0.07000000000000001
tt.render.sprites[5].offset = v(2, -5)
tt.render.sprites[6] = E:clone_c("sprite")
tt.render.sprites[6].animated = false
tt.render.sprites[6].hidden = false
tt.render.sprites[6].name = "spirit_mausoleum_lvl4_gargoyle_idle_right"
tt.render.sprites[6].anchor.y = 0.07000000000000001
tt.render.sprites[6].offset = v(35, 3)
tt.main_script.insert = scripts.tower_barrack.insert
tt.ui.click_rect = r(-43, 0, 86, 68)

tt = E:register_t("warmongers_soldier_orc_lvl1", "soldier_militia")
E:add_comps(tt, "nav_grid")
tt.info.portrait = "bottom_info_image_soldiers_0030"
tt.info.random_name_count = 10
tt.info.random_name_format = "WARMONGERS_SOLDIER_%i_NAME"
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.update = customScripts1.kr4_soldier_barrack.update
tt.main_script.remove = scripts.soldier_barrack.remove
tt.render.sprites[1].prefix = "warmongers_soldier_orc_lvl1"
tt.render.sprites[1].anchor = v(0.5, 0.167)
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "warmongers_soldier_orc_lvl1_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.167)
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.unit.hit_offset = v(0, 13)
tt.unit.head_offset = v(0, 29)
tt.unit.mod_offset = v(0, 13)
tt.unit.marker_offset = v(0, 0)
tt.health_bar.offset = v(0, 31)
tt.health.hp_max = 72
tt.health.armor = 0
tt.health.dead_lifetime = 10
tt.regen.health = 7
tt.regen.cooldown = 2
tt.motion.max_speed = 75
tt.melee.range = 60
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].damage_max = 3
tt.melee.attacks[1].hit_time = fts(5)
tt.soldier.melee_slot_offset = v(15, 0)
tt.soldier.melee_slot_spread = v(-8, -8)
tt.sound_events.death = "orcs_death_sound"
tt.ui.click_rect = r(-10, -2, 20, 25)

tt = E:register_t("warmongers_soldier_orc_lvl2", "warmongers_soldier_orc_lvl1")
tt.info.portrait = "bottom_info_image_soldiers_0031"
tt.render.sprites[1].prefix = "warmongers_soldier_orc_lvl2"
tt.render.sprites[2].name = "warmongers_soldier_orc_lvl2_shadow"
tt.unit.hit_offset = v(0, 12)
tt.unit.head_offset = v(0, 27)
tt.unit.mod_offset = v(0, 15)
tt.health.hp_max = 120
tt.health.armor = 0.1
tt.regen.health = 15
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].damage_max = 4
tt.melee.attacks[1].hit_time = fts(6)
tt.soldier.melee_slot_offset = v(18, 0)

tt = E:register_t("warmongers_soldier_orc_lvl3", "warmongers_soldier_orc_lvl1")
tt.info.portrait = "bottom_info_image_soldiers_0032"
tt.render.sprites[1].prefix = "warmongers_soldier_orc_lvl3"
tt.render.sprites[2].name = "warmongers_soldier_orc_lvl3_shadow"
tt.health.hp_max = 180
tt.health.armor = 0.15
tt.regen.health = 23
tt.melee.attacks[1].damage_min = 5
tt.melee.attacks[1].damage_max = 7
tt.soldier.melee_slot_offset = v(15, 0)

tt = E:register_t("warmongers_soldier_orc_lvl4", "warmongers_soldier_orc_lvl1")
E:add_comps(tt, "powers")
tt.info.portrait = "bottom_info_image_soldiers_0033"
tt.render.sprites[1].prefix = "warmongers_soldier_orc_lvl4"
tt.render.sprites[1].anchor = v(0.5, 0.158)
tt.render.sprites[2].name = "warmongers_soldier_orc_lvl4_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.158)
tt.unit.hit_offset = v(0, 12)
tt.unit.head_offset = v(0, 34)
tt.unit.mod_offset = v(0, 10)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.health_bar.offset = v(0, 36)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.hp_max = 240
tt.health.armor = 0.2
tt.regen.health = 31
tt.melee.attacks[1].damage_min = 11
tt.melee.attacks[1].damage_max = 16
tt.melee.attacks[1].hit_time = fts(5)
tt.soldier.melee_slot_offset = v(22, 0)
tt.powers.seal_of_blood = E:clone_c("power")
tt.powers.seal_of_blood.healing_points = {
    5,
    10
}
tt.powers.battlewits = E:clone_c("power")
tt.powers.battlewits.modifier_on_melee = "mod_battlewits"
tt.powers.battlewits.damage_multiplier = {
    1.4,
    1.8
}
tt.main_script.update = customScripts1.warmongers_soldier_orc_captain.update

tt = E:register_t("warmongers_soldier_orc_captain", "warmongers_soldier_orc_lvl4")
AC(tt, "timed_attacks")
tt.info.portrait = "bottom_info_image_soldiers_0034"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.render.sprites[1].prefix = "warmongers_soldier_orc_captain"
tt.render.sprites[1].anchor = v(0.5, 0.172)
tt.render.sprites[2].name = "warmongers_soldier_orc_captain_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.172)
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 28)
tt.unit.mod_offset = v(0, 12)
tt.health_bar.offset = v(0, 41)
tt.health.hp_max = 360
tt.health.armor = 0.5
tt.regen.health = 46
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].damage_max = 23
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "raise"
tt.timed_attacks.list[1].cooldown = 20
tt.timed_attacks.list[1].min_count = 1
tt.timed_attacks.list[1].mod = "mod_promotion"
tt.timed_attacks.list[1].range = 150
tt.timed_attacks.list[1].cast_time = fts(9)
tt.timed_attacks.list[1].sound = "warmonger_barrack_unit_swap_upgrade"
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_MOD)
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY)
tt.timed_attacks.list[1].allowed_templates = {
	"warmongers_soldier_orc_lvl1",
	"warmongers_soldier_orc_lvl2",
	"warmongers_soldier_orc_lvl3",
	"warmongers_soldier_orc_lvl4",
	"warmongers_soldier_orc_captain"
}
tt.soldier.melee_slot_offset = v(25, 0)

tt = E:register_t("mod_battlewits", "modifier")
E:add_comps(tt, "render", "tween")
tt.inflicted_damage_factor = nil
tt.modifier.replaces_lower = true
tt.modifier.duration = 2
tt.modifier.use_mod_offset = false
tt.main_script.insert = scripts.mod_fury.insert
tt.main_script.remove = scripts.mod_fury.remove
tt.main_script.update = customScripts1.mod_track_target_with_fade.update
tt.render.sprites[1].name = "warmongers_soldier_orc_captain_rage"
tt.render.sprites[1].anchor = v(0.5, 0.337)
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS + 2
tt.fade_in = nil
tt.fade_out = true
tt.tween.props[1].keys = {
	{
		fts(0),
		0
	},
	{
		fts(6),
		255
	}
}

tt = E:register_t("mod_promotion", "modifier")
E:add_comps(tt, "render")
tt.mod = "mod_promotion_damage"
tt.modifier.duration = 12
tt.modifier.use_mod_offset = false
tt.render.sprites[1].prefix = "warmongers_soldier_orc_captain_weakness"
tt.render.sprites[1].anchor = v(0.5, 0)
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.main_script.update = customScripts1.mod_promotion.update

tt = E:register_t("mod_promotion_damage", "mod_damage")
tt.damage_max = 20
tt.damage_min = 20
tt.damage_type = DAMAGE_MAGICAL

tt = E:register_t("tower_warmongers_barrack_lvl1", "tower_KR5")
E:add_comps(tt, "barrack", "vis")
tt.tower.type = "warmongers_barrack"
tt.tower.kind = TOWER_KIND_BARRACK
tt.tower.team = TEAM_DARK_ARMY
tt.tower.level = 1
tt.tower.price = 70
tt.tower.menu_offset = v(0, 20)
tt.info.portrait = "portraits_towers_0125"
tt.info.tower_portrait = "tower_room_portraits_big_tower_warmongers_barrack_0001"
tt.info.room_portrait = "quickmenu_tower_icons_0107_0001"
tt.info.stat_damage = 1
tt.info.stat_hp = 8
tt.info.stat_armor = 2
tt.info.fn = scripts.tower_barrack.get_info
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "warmongers_barrack_towers_lvl1_layer1_0001"
tt.render.sprites[2].anchor.y = 0.16
tt.render.sprites[2].offset = v(0, 2)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "warmongers_barrack_towers_lvl1"
tt.render.sprites[3].name = "close"
tt.render.sprites[3].anchor.y = 0.16
tt.render.sprites[3].offset = v(0, 2)
tt.render.sprites[3].loop = false
tt.barrack.soldier_type = "warmongers_soldier_orc_lvl1"
tt.barrack.rally_range = 145
tt.barrack.respawn_offset = v(0, 0)
tt.barrack.max_soldiers = 3
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.update = scripts.tower_barrack.update
tt.main_script.remove = scripts.tower_barrack.remove
tt.sound_events.mute_on_level_insert = true
tt.sound_events.insert = "warmonger_barrack_build_taunt"
tt.sound_events.change_rally_point = "warmonger_barrack_build_taunt"
tt.sound_events.open_door = "open_door_sound"
tt.sound_events.tower_room_select = "warmonger_barrack_build_taunt_4"
tt.ui.click_rect = r(-40, 0, 80, 70)

tt = E:register_t("tower_warmongers_barrack_lvl2", "tower_warmongers_barrack_lvl1")
tt.tower.menu_offset = v(0, 21)
tt.tower.level = 2
tt.tower.price = 110
tt.render.sprites[2].name = "warmongers_barrack_towers_lvl2_layer1_0001"
tt.render.sprites[3].prefix = "warmongers_barrack_towers_lvl2"
tt.barrack.soldier_type = "warmongers_soldier_orc_lvl2"

tt = E:register_t("tower_warmongers_barrack_lvl3", "tower_warmongers_barrack_lvl1")
tt.tower.menu_offset = v(0, 22)
tt.tower.level = 3
tt.tower.price = 160
tt.render.sprites[2].name = "warmongers_barrack_towers_lvl3_layer1_0001"
tt.render.sprites[3].prefix = "warmongers_barrack_towers_lvl3"
tt.barrack.soldier_type = "warmongers_soldier_orc_lvl3"
tt.ui.click_rect = r(-40, 0, 80, 80)

tt = E:register_t("tower_warmongers_barrack_lvl4", "tower_warmongers_barrack_lvl1")
E:add_comps(tt, "powers")
tt.info.i18n_key = "TOWER_WARMONGERS_BARRACK_LVL4"
tt.tower.menu_offset = v(0, 25)
tt.tower.level = 4
tt.tower.price = 220
tt.render.sprites[2].name = "warmongers_barrack_towers_lvl4_layer1_0001"
tt.render.sprites[3].prefix = "warmongers_barrack_towers_lvl4"
tt.barrack.soldier_type = "warmongers_soldier_orc_lvl4"
tt.powers.seal_of_blood = E:clone_c("power")
tt.powers.seal_of_blood.price = { 100, 100 }
tt.powers.seal_of_blood.enc_icon = 103
tt.powers.seal_of_blood.max_level = 2
tt.powers.battlewits = E:clone_c("power")
tt.powers.battlewits.price = { 180, 180 }
tt.powers.battlewits.enc_icon = 104
tt.powers.battlewits.max_level = 2
tt.powers.promotion = E:clone_c("power")
tt.powers.promotion.unit_type = "warmongers_soldier_orc_captain"
tt.powers.promotion.promotion_index = { 1 }
tt.powers.promotion.price = { 150 }
tt.powers.promotion.max_level = 1
tt.main_script.update = customScripts1.tower_warmongers_barrack.update
tt.sound_events.insert = "warmonger_barrack_build_taunt_4"
tt.sound_events.change_rally_point = "warmonger_barrack_move_taunt"
tt.ui.click_rect = r(-42, 0, 84, 90)

tt = E:register_t("tower_build_warmongers_barrack", "tower_build")
tt.build_name = "tower_warmongers_barrack_lvl1"
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2].name = "warmongers_barrack_towers_lvl1_layer1_0008"
tt.render.sprites[2].anchor.y = 0.16
tt.render.sprites[2].offset = v(0, 2)
tt.render.sprites[3].offset.y = 62
tt.render.sprites[4].offset.y = 62

tt = E:register_t("tower_build_random", "tower_build")
tt.build_name = "tower_random_lvl4"
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[2].name = "random_tower_constructing"
tt.render.sprites[2].offset = v(0, 39)

tt = E:register_t("tower_random_lvl4", "tower_KR5")
b = balance.towers.random
E:add_comps(tt, "powers", "vis")
tt.info.i18n_key = "TOWER_RANDOM"
tt.info.fn = customScripts1.tower_random.get_info
tt.tower.type = "random"
tt.tower.kind = TOWER_KIND_ARCHER
tt.tower.team = TEAM_LINIREA
tt.info.tower_portrait = "tower_room_portraits_big_tower_random_0001"
tt.info.room_portrait = "quickmenu_tower_icons_0108_0001"
tt.info.stat_damage = 0
tt.info.stat_cooldown = 0
tt.info.stat_range = 0
tt.tower.price = 400
tt.powers.unknown1 = E:clone_c("power")
tt.powers.unknown1.price = { 0 }
tt.powers.unknown1.enc_icon = 105
tt.powers.unknown1.max_level = 1
tt.powers.unknown2 = E:clone_c("power")
tt.powers.unknown2.price = { 0 }
tt.powers.unknown2.enc_icon = 105
tt.powers.unknown2.max_level = 1
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.main_script.insert = customScripts1.tower_random.insert
tt.sound_events.insert = nil
tt.sound_events.tower_room_select = nil
tt.allowed_templates = b.allowed_templates

tt = E:register_t("tower_hammerhold_archer", "tower_royal_archers_lvl1")
E:add_comps(tt, "barrack", "powers")
tt.tower.price = 270
tt.tower.type = "hammerhold_archer"
tt.tower.menu_offset = v(0, 20)
tt.tower.long_idle_cooldown = 6
tt.info.portrait = "portraits_towers_0126"
tt.info.i18n_key = "TOWER_HAMMERHOLD_ARCHER"
tt.barrack.soldier_type = "legion_archer"
tt.barrack.rally_range = 145
tt.barrack.max_soldiers = 3
tt.barrack.respawn_offset = v(0, 1)
tt.sound_events.insert = "legionnaire_taunt_1"
tt.sound_events.change_rally_point = "legionnaire_move_taunt"
tt.powers.formation = E:clone_c("power")
tt.powers.formation.price = { 175, 175, 175 }
tt.powers.war_elephants = E:clone_c("power")
tt.powers.war_elephants.disappear_on_upgrade = true
tt.powers.war_elephants.price = { 300 }
tt.powers.war_elephants.unit_type = {
    "elephant_lancer",
    "war_elephant"
}
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hammerhold_archer_tower_0001"
tt.render.sprites[2].offset = v(0, 5)
tt.render.sprites[2].anchor.y = 0.156
tt.render.sprites[3].prefix = "hammerhold_archer_tower_shooter"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].anchor.y = 0.325
tt.render.sprites[3].offset = v(0, 41)
tt.render.sprites[3].angles = {}
tt.render.sprites[3].angles.idle = {
	"idleUp",
	"idle"
}
tt.render.sprites[3].angles.shoot = {
	"shootUp",
	"shootDown"
}
table.remove(tt.render.sprites, 5)
table.remove(tt.render.sprites, 4)
tt.shooter_sid = 3
tt.attacks.range = 290
tt.attacks.list[1].bullet = "hammerhold_archer_arrow"
tt.attacks.list[1].cooldown = 0.7
tt.attacks.list[1].shoot_time = 0.4
tt.attacks.list[1].bullet_start_offset = {
	v(4, 7),
	v(4, 9)
}
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.update = customScripts1.tower_hammerhold_archer.update
tt.main_script.remove = scripts.tower_barrack.remove
tt.ui.click_rect = r(-30, 3, 63, 67)

tt = E:register_t("hammerhold_archer_arrow", "arrow5_fixed_height")
tt.bullet.fixed_height = 40
tt.bullet.g = -1000
tt.bullet.pop = {
	"pop_archer"
}
tt.bullet.damage_min = 14
tt.bullet.damage_max = 18
tt.bullet.miss_decal = "hammerhold_archer_arrow_0005"
tt.bullet.hide_radius = 1
tt.bullet.reset_to_target_pos = true
tt.bullet.use_unit_damage_factor = true
tt.render.sprites[1].name = "hammerhold_archer_arrow"
tt.render.sprites[1].animated = true

tt = E:register_t("legion_archer_arrow", "hammerhold_archer_arrow")
tt.bullet.fixed_height = 20
tt.bullet.damage_min = 8
tt.bullet.damage_max = 12

tt = E:register_t("legion_archer", "soldier_militia")
E:add_comps(tt, "ranged", "nav_grid")
tt.health.armor = 0
tt.health.dead_lifetime = 14
tt.health.hp_max = 140
tt.health_bar.offset = v(0, 30)
tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
tt.idle_flip.chance = 0.4
tt.idle_flip.cooldown = 5
tt.info.fn = scripts.soldier_barrack.get_info
tt.info.portrait = "bottom_info_image_soldiers_0035"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.remove = scripts.soldier_barrack.remove
tt.main_script.update = customScripts1.kr4_soldier_barrack.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].hit_time = 0.3
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.range = 50
tt.ranged.attacks[1].animation = "range"
tt.ranged.attacks[1].bullet = "legion_archer_arrow"
tt.ranged.attacks[1].bullet_start_offset = {
	v(5, 17)
}
tt.ranged.attacks[1].cooldown = fts(22)
tt.ranged.attacks[1].max_range = 140
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(14)
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.motion.max_speed = 78
tt.regen.cooldown = 1
tt.regen.health = 9
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk",
    "walkUp",
    "walkDown"
}
tt.render.sprites[1].prefix = "legion_archer"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "legion_archer_shadow"
tt.render.sprites[2].anchor.y = 0.2
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(10, 0)
tt.unit.hit_offset = v(0, 12)
tt.unit.head_offset = v(0, 28)
tt.unit.mod_offset = v(0, 11)
tt.unit.marker_offset = v(0, 0)
tt.ui.click_rect = r(-10, -2, 20, 25)

tt = E:register_t("elephant_lancer", "soldier_militia")
E:add_comps(tt, "ranged", "reinforcement", "nav_grid", "tween")
tt.respawn = true
tt.health.ignore_delete_after = true
tt.health.dead_lifetime = 30
tt.health.armor = 0.8
tt.health.hp_max = 380
tt.health_bar.offset = v(0, 90)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.random_name_format = nil
tt.info.random_name_count = nil
tt.info.portrait = "bottom_info_image_soldiers_0036"
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.main_script.insert = customScripts1.elephant_lancer.insert
tt.main_script.remove = customScripts1.elephant_lancer.remove
tt.main_script.update = customScripts1.elephant_lancer.update
tt.melee = nil
tt.motion.max_speed = 28
tt.regen.cooldown = 1
tt.regen.health = 20
tt.render.sprites[1].prefix = "war_elephant_archers"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].anchor = v(0.5, 0.1)
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "war_elephant_archers_shadow"
tt.render.sprites[2].anchor.y = 0.1
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "war_elephant_archer_unit"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].anchor = v(0.5, 0.08)
tt.render.sprites[3].offset = v(-27, 46)
tt.render.sprites[3].hidden = true
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "war_elephant_archer_unit"
tt.render.sprites[4].name = "idle"
tt.render.sprites[4].anchor = v(0.5, 0.08)
tt.render.sprites[4].offset = v(-10, 46)
tt.render.sprites[4].hidden = true
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].name = "war_elephant_archer_mount_layer1_0001"
tt.render.sprites[5].animated = false
tt.render.sprites[5].anchor = v(0.5, 0.5)
tt.render.sprites[5].offset = v(-21, 43)
tt.render.sprites[5].hidden = true
tt.shooter_sid = {
	3,
	4
}
tt.ranged.attacks[1].animation = "range"
tt.ranged.attacks[1].bullet = "legion_archer_arrow"
tt.ranged.attacks[1].controller = "controller_war_elephant_archer"
tt.ranged.attacks[1].bullet_start_offset = {
	v(5, 14)
}
tt.ranged.attacks[1].cooldown = fts(22)
tt.ranged.attacks[1].max_range = 250
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].damage_min = 8
tt.ranged.attacks[1].damage_max = 12
tt.ranged.attacks[2] = table.deepclone(tt.ranged.attacks[1])
tt.sound_events.insert = nil
tt.sound_events.change_rally_point = "sandstorm_elephant_ambient"
tt.sound_events.death = "kr4_enemies_sandstorm_elephant_death"
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
tt.unit.hit_offset = v(0, 30)
tt.unit.head_offset = v(0, 60)
tt.unit.mod_offset = v(0, 30)
tt.unit.size = UNIT_SIZE_LARGE
tt.nav_rally.delay_max = nil
tt.aura = "aura_war_elephant"
tt.vis.bans = bor(F_SKELETON, F_LYCAN, F_INSTAKILL, F_EAT, F_NET)
tt.ui.click_rect = r(-20, -2, 40, 50)

tt = E:register_t("controller_war_elephant_archer")
E:add_comps(tt, "pos", "main_script", "idle_flip")
tt.shot_index = nil
tt.owner = nil
tt.main_script.update = customScripts1.controller_war_elephant_archer.update

tt = E:register_t("aura_war_elephant", "aura")
tt.aura.track_source = true
tt.aura.track_dead = true
tt.aura.duration = -1
tt.aura.cycle_time = 0.2
tt.aura.radius = 35
tt.aura.mods = {
	"mod_war_elephant_damage"
}
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING, F_NIGHTMARE)
tt.aura.vis_flags = bor(F_MOD, F_AREA)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("mod_war_elephant_damage", "mod_damage")
tt.damage_min = 11
tt.damage_max = 11
tt.damage_type = DAMAGE_PHYSICAL

tt = E:register_t("mod_war_elephant_heal", "modifier")
E:add_comps(tt, "hps")
tt.modifier.duration = 6
tt.hps.heal_min = 15
tt.hps.heal_max = 15
tt.hps.heal_every = 0.5
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update

tt = E:register_t("mod_war_elephant_buff", "modifier")
E:add_comps(tt, "render", "tween")
tt.modifier.duration = 6
tt.modifier.use_mod_offset = false
tt.inflicted_damage_factor = 1.5
tt.speed_factor = 1.5
tt.main_script.insert = scripts.mod_fury.insert
tt.main_script.remove = scripts.mod_fury.remove
tt.main_script.update = customScripts1.mod_track_target_with_fade.update
tt.render.sprites[1].name = "war_elephant_drummer_buff_unit"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt.fade_in = true
tt.fade_out = true
tt.tween.props[1].keys = {
	{
		fts(0),
		0
	},
	{
		fts(15),
		255
	}
}

tt = E:register_t("mod_war_elephant_on_elephant", "mod_war_elephant_buff")
tt.inflicted_damage_factor = 1.75
tt.render.sprites[1].name = "war_elephant_drummer_decal"
tt.render.sprites[1].anchor = v(0.5, 0.5)

tt = E:register_t("war_elephant", "soldier_militia")
E:add_comps(tt, "timed_attacks", "reinforcement", "nav_grid", "tween")
tt.respawn = true
tt.health.ignore_delete_after = true
tt.health.dead_lifetime = 30
tt.health.armor = 0.8
tt.health.hp_max = 380
tt.health_bar.offset = v(0, 90)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.random_name_format = nil
tt.info.random_name_count = nil
tt.info.portrait = "bottom_info_image_soldiers_0037"
tt.info.fn = customScripts1.war_elephant.get_info
tt.main_script.insert = customScripts1.war_elephant.insert
tt.main_script.remove = customScripts1.war_elephant.remove
tt.main_script.update = customScripts1.war_elephant.update
tt.melee = nil
tt.motion.max_speed = 28
tt.regen.cooldown = 1
tt.regen.health = 20
tt.render.sprites[1].prefix = "war_elephant_drummer"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].anchor = v(0.5, 0.1)
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "war_elephant_drummer_shadow"
tt.render.sprites[2].anchor.y = 0.1
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "war_elephant_drummer_only"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].anchor = v(0.5, 0.5)
tt.render.sprites[3].offset = v(-16, 58)
tt.render.sprites[3].hidden = true
tt.drummer_sid = 3
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].controller = "controller_war_elephant_drummer"
tt.timed_attacks.list[1].animation_start = "playIn"
tt.timed_attacks.list[1].animation_loop = "playLoop"
tt.timed_attacks.list[1].animation_end = "playOut"
tt.timed_attacks.list[1].loop_times = 3
tt.timed_attacks.list[1].cooldown = 10
tt.timed_attacks.list[1].cast_time = 0.3
tt.timed_attacks.list[1].max_targets = 10
tt.timed_attacks.list[1].range = 150
tt.timed_attacks.list[1].mods = {
	"mod_war_elephant_heal",
	"mod_war_elephant_buff"
}
tt.timed_attacks.list[1].mods_on_elephant = {
	"mod_war_elephant_heal",
	"mod_war_elephant_on_elephant"
}
tt.timed_attacks.list[1].elephant_templates = {
	"elephant_lancer",
	"war_elephant"
}
tt.timed_attacks.list[1].sound = "kr4_enemies_sandstorm_elephant_drums"
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY)
-- tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.sound_events.insert = nil
tt.sound_events.change_rally_point = "sandstorm_elephant_ambient"
tt.sound_events.death = "kr4_enemies_sandstorm_elephant_death"
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
tt.unit.hit_offset = v(0, 30)
tt.unit.head_offset = v(0, 60)
tt.unit.mod_offset = v(0, 30)
tt.unit.size = UNIT_SIZE_LARGE
tt.nav_rally.delay_max = nil
tt.aura = "aura_war_elephant"
tt.vis.bans = bor(F_SKELETON, F_LYCAN, F_INSTAKILL, F_EAT, F_NET)
tt.ui.click_rect = r(-20, -2, 40, 50)

tt = E:register_t("controller_war_elephant_drummer")
E:add_comps(tt, "pos", "main_script")
tt.owner = nil
tt.main_script.update = customScripts1.controller_war_elephant_drummer.update

tt = E:register_t("tower_build_ignis_altar", "tower_build")
tt.build_name = "tower_ignis_altar_lvl1"
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 13)
tt.render.sprites[2].name = "ignis_altar_lvl1_build_0001"
tt.render.sprites[2].exo = true
tt.render.sprites[2].anchor = v(0.53, 0.16)
tt.render.sprites[2].offset = v(0, 4)
tt.render.sprites[3].offset.y = 62
tt.render.sprites[4].offset.y = 62

tt = E:register_t("tower_ignis_altar_lvl1", "tower_KR5")
E:add_comps(tt, "attacks", "vis")
tt.tower.type = "ignis_altar"
tt.tower.kind = TOWER_KIND_ENGINEER
tt.tower.team = TEAM_DARK_ARMY
tt.tower.level = 1
tt.tower.price = 120
tt.tower.menu_offset = v(0, 20)
tt.info.portrait = "portraits_towers_0138"
tt.info.tower_portrait = "tower_room_portraits_big_tower_ignis_altar_0001"
tt.info.room_portrait = "quickmenu_tower_icons_0109_0001"
tt.info.stat_damage = 10
tt.info.stat_range = 7
tt.info.stat_cooldown = 2
tt.info.fn = customScripts1.tower_ignis_altar.get_info
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 13)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "ignis_altar_lvl1"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].anchor = v(0.53, 0.16)
tt.render.sprites[2].offset = v(0, 4)
tt.sound_events.mute_on_level_insert = true
tt.sound_events.insert = "dinos_ignis_altar_build_taunt"
tt.sound_events.tower_room_select = "ignis_altar_build_taunt_4"
tt.attacks.range = 150
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "bullet_ignis_altar"
tt.attacks.list[1].vis_flags = bor(F_RANGED, F_AREA)
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE, F_FLYING)
tt.attacks.list[1].cooldown = 4.0
tt.attacks.list[1].shoot_time = fts(11)
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].charge_animation = "carga"
tt.attacks.list[1].sound = "dinos_ignis_altar_attack_shoot"
tt.attacks.list[1].sound_args = {
	delay = 0.3
}
tt.attacks.list[1].bullet_start_offset = v(6, 73)
tt.attacks.list[1].node_prediction = fts(49)
tt.main_script.update = customScripts1.tower_ignis_altar.update
tt.main_script.remove = customScripts1.tower_ignis_altar.remove
tt.ui.click_rect = r(-40, 0, 80, 70)

tt = E:register_t("tower_ignis_altar_lvl2", "tower_ignis_altar_lvl1")
tt.tower.level = 2
tt.tower.price = 160
tt.render.sprites[2].prefix = "ignis_altar_lvl2"
tt.attacks.range = 165

tt = E:register_t("tower_ignis_altar_lvl3", "tower_ignis_altar_lvl1")
tt.tower.level = 3
tt.tower.price = 220
tt.render.sprites[2].prefix = "ignis_altar_lvl3"
tt.attacks.range = 180
tt.attacks.list[1].cooldown = 3.5

tt = E:register_t("tower_ignis_altar_lvl4", "tower_ignis_altar_lvl1")
b = balance.towers.ignis_altar
E:add_comps(tt, "barrack", "powers")
tt.info.i18n_key = "TOWER_IGNIS_ALTAR_LVL4"
tt.tower.menu_offset = v(0, 25)
tt.tower.level = 4
tt.tower.price = 300
tt.render.sprites[2].prefix = "ignis_altar_lvl4"
tt.shooter = "ignis_altar_lvl4_subunit"
tt.powers.burning_elemental = E:clone_c("power")
tt.powers.burning_elemental.price = { 300 }
tt.powers.burning_elemental.max_level = 1
tt.powers.burning_elemental.sound = "dinos_ignis_altar_summon_elemental"
tt.powers.burning_elemental.sound_args = {
	delay = fts(37)
}
tt.powers.single_extinction = E:clone_c("power")
tt.powers.single_extinction.price = { 180, 100, 100 }
tt.powers.single_extinction.cooldown = b.single_extinction.cooldown
tt.powers.single_extinction.enc_icon = 106
tt.powers.true_fire = E:clone_c("power")
tt.powers.true_fire.price = { 300 }
tt.powers.true_fire.enc_icon = 107
tt.powers.true_fire.max_level = 1
tt.attacks.range = 195
tt.attacks.list[1].cooldown = 3.5
tt.attacks.list[1].bullet_start_offset = v(-1, 90)
tt.barrack.soldier_type = "tower_ignis_altar_ablaze_elemental"
tt.barrack.rally_range = 195
tt.barrack.max_soldiers = 0
tt.sound_events.change_rally_point = "dinos_ignis_altar_elemental_spawn"
tt.main_script.insert = scripts.tower_barrack.insert
tt.ui.click_rect = r(-42, 0, 84, 90)

tt = E:register_t("tower_ignis_altar_ablaze_elemental", "soldier_militia")
E:add_comps(tt, "nav_grid")
tt.health.armor = 0.15
tt.health.dead_lifetime = 10
tt.health.hp_max = 450
tt.health_bar.offset = v(0, 60)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.idle_flip.chance = 0.4
tt.idle_flip.cooldown = 5
tt.info.fn = scripts.soldier_barrack.get_info
tt.info.portrait = "bottom_info_image_soldiers_0044"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.remove = scripts.soldier_barrack.remove
tt.main_script.update = customScripts1.tower_ignis_altar_ablaze_elemental.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 19
tt.melee.attacks[1].damage_max = 43
tt.melee.attacks[1].hit_time = 0.3
tt.melee.attacks[1].mod_prefix = "mod_ignis_altar_burning_elemental_"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.range = 70
tt.motion.max_speed = 30
tt.regen.cooldown = 2
tt.regen.health = 30
tt.raise_animation = "spawn"
tt.respawn_animation = "respawn"
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "ignis_altar_lava_golem"
tt.render.sprites[1].name = tt.respawn_animation
tt.render.sprites[1].exo = true
tt.render.sprites[1].anchor = v(0.5, 0.0881)
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "asst_lavagolem_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.5)
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(35, 0)
tt.unit.hit_offset = v(0, 21)
tt.unit.head_offset = v(13.7, 40.65)
tt.unit.mod_offset = v(0, 21)
tt.unit.marker_offset = v(0, 0)
tt.unit.fade_time_after_death = nil
tt.unit.blood_color = BLOOD_ORANGE
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_SKELETON, F_LYCAN)
tt.ui.click_rect = r(-25, -2, 50, 52)
tt.sound_events.insert = nil
tt.sound_events.insert_args = nil
tt.sound_events.raise = "dinos_ignis_altar_elemental_spawn"
tt.sound_events.raise_args = {
	delay = fts(2)
}
tt.sound_events.respawn = "dinos_ignis_altar_elemental_respawn"
tt.sound_events.respawn_args = {
	delay = fts(2)
}

tt = E:register_t("ignis_altar_lvl4_subunit", "decal_scripted")
b = balance.towers.ignis_altar
E:add_comps(tt, "attacks")
tt.render.sprites[1].prefix = "ignis_altar_lvl4_subunit"
tt.render.sprites[1].name = "idleDown"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].offset = v(28, 33)
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].draw_order = 2
tt.attacks.list[1] = E:clone_c("spell_attack")
tt.attacks.list[1].disabled = true
tt.attacks.list[1].spell_prefix = "mod_ignis_altar_single_extinction_"
tt.attacks.list[1].spell = nil
tt.attacks.list[1].animation = "shootDebuff"
tt.attacks.list[1].cooldown = b.single_extinction.cooldown[1]
tt.attacks.list[1].range = 195
tt.attacks.list[1].excluded_templates = {}
tt.attacks.list[1].cast_time = fts(38)
tt.attacks.list[1].sound = "dinos_ignis_altar_single_extinction_1"
tt.attacks.list[1].sound_args = {
	delay = fts(38)
}
tt.attacks.list[1].vis_flags = bor(F_RANGED, F_MOD)
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE, F_BOSS)
tt.owner = nil
tt.main_script.update = customScripts1.ignis_altar_lvl4_subunit.update

tt = E:register_t("mod_ignis_altar_single_extinction", "modifier")
E:add_comps(tt, "render")
tt.modifier.duration = 10
tt.modifier.use_mod_offset = true
tt.modifier.vis_flags = F_MOD
tt.modifier.vis_bans = bor(F_NIGHTMARE, F_BOSS)
tt.received_damage_factor = nil
tt.explosion_damage = nil
tt.explosion_damage_type = DAMAGE_MAGICAL
tt.explosion_range = 50
tt.explosion_vis_flags = bor(F_AREA)
tt.explosion_vis_bans = bor(F_FRIEND)
tt.explosion_fx = "fx_ignis_altar"
tt.explosion_sound = "dinos_ignis_altar_single_extinction_explotion"
tt.render.sprites[1].prefix = "ignis_altar_debuff"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].size_scales = {
	vv(1),
	vv(1.3),
	vv(1.5)
}
tt.render.sprites[1].offset = v(0, -10)
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.main_script.insert = scripts.mod_fury.insert
tt.main_script.remove = customScripts1.mod_ignis_altar_single_extinction.remove
tt.main_script.update = scripts.mod_track_target.update

tt = E:register_t("mod_ignis_altar_single_extinction_1", "mod_ignis_altar_single_extinction")
tt.received_damage_factor = 1.5
tt.explosion_damage = 64

tt = E:register_t("mod_ignis_altar_single_extinction_2", "mod_ignis_altar_single_extinction")
tt.received_damage_factor = 1.75
tt.explosion_damage = 100

tt = E:register_t("mod_ignis_altar_single_extinction_3", "mod_ignis_altar_single_extinction")
tt.received_damage_factor = 2
tt.explosion_damage = 136

tt = E:register_t("mod_ignis_altar_burning_elemental_1", "mod_ignis_altar_single_extinction")
tt.modifier.duration = 2
tt.received_damage_factor = 1.25
tt.explosion_damage = 32

tt = E:register_t("mod_ignis_altar_burning_elemental_2", "mod_ignis_altar_burning_elemental_1")
tt.received_damage_factor = 1.375
tt.explosion_damage = 50

tt = E:register_t("mod_ignis_altar_burning_elemental_3", "mod_ignis_altar_burning_elemental_1")
tt.received_damage_factor = 1.5
tt.explosion_damage = 68

tt = E:register_t("bullet_ignis_altar", "bombKR5")
tt.bullet.level = 1
tt.bullet.flight_time = fts(25)
tt.bullet.pop = nil
tt.bullet.hit_decal = nil
tt.bullet.hit_fx = "fx_ignis_altar"
tt.bullet.hit_payload = "aura_bullet_ignis_altar"
tt.bullet.particles_name = "ps_bullet_ignis_altar"
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_radius = 0
tt.bullet.hide_radius = 1
tt.render.sprites[1].name = "ignis_altar_proyectile_run_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].exo = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.sound_events.insert = nil
tt.sound_events.hit = "dinos_ignis_altar_attack_dot"

tt = E:register_t("fx_ignis_altar", "fx")
tt.render.sprites[1].name = "ignis_altar_fx_run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = v(0, 2)

tt = E:register_t("ps_bullet_ignis_altar")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "ignis_altar_proyectile_particle_run"
tt.particle_system.exo = true
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.track_rotation = true
tt.particle_system.emission_rate = 33
tt.particle_system.particle_lifetime = {
	fts(15),
	fts(15)
}
tt.particle_system.z = tt.particle_system.z - 1

tt = E:register_t("aura_bullet_ignis_altar", "aura")
E:add_comps(tt, "render", "tween")
tt.aura.level = 1
tt.aura.mods = {
	"mod_ignis_altar_damage"
}
tt.aura.radius = 50
tt.aura.duration = 3.5
tt.aura.cycle_time = 0.4
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.render.sprites[1].prefix = "ignis_altar_decal"
tt.render.sprites[1].prefix_upgraded = "ignis_altar_decal_lava"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.cycle_times = {
	0.4,
	0.35,
	0.3,
	0.2
}
tt.mods_upgraded = {
	"mod_ignis_altar_damage",
	"mod_ignis_altar_slow"
}
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
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = customScripts1.aura_bullet_ignis_altar.update

tt = E:register_t("mod_ignis_altar_damage", "mod_damage")
tt.level = 1
tt.damage_min = 2
tt.damage_max = 2
tt.damages = {
	2,
	4,
	6,
	8
}
tt.damage_type = DAMAGE_ELECTRICAL

tt = E:register_t("mod_ignis_altar_slow", "mod_slow")
E:add_comps(tt, "render")
tt.render.sprites[1].name = "ignis_altar_slow_idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.slow.factor = 0.5
tt.modifier.duration = 0.3
tt.modifier.use_mod_offset = false
function tt.main_script.insert(this, store, script)
	if scripts.mod_slow.insert(this, store, script) then
		return scripts.mod_track_target.insert(this, store, script)
	end
	return false
end
tt.main_script.update = scripts.mod_track_target.update

tt = E:register_t("royal_archers_tower_combination_controller")
E:add_comps(tt, "main_script")
tt.main_script.update = customScripts1.royal_archers_tower_combination_controller.update
tt.sound = nil
tt.sound_args = nil
tt.tower_1 = nil
tt.tower_2 = nil
tt.delay = 0.15
tt.towers = {
	[TOWER_KIND_ENGINEER] = "tower_royal_archer_and_musketeer",
	[TOWER_KIND_ARCHER] = "tower_royal_archer_and_ranger",
	[TOWER_KIND_MAGE] = "tower_royal_archer_and_longbow"
}

tt = E:register_t("royal_archers_decal_preview_controller")
E:add_comps(tt, "main_script")
tt.owner = nil
tt.excluded_templates = {}
tt.tower_kinds = {
	TOWER_KIND_ENGINEER,
	TOWER_KIND_ARCHER,
	TOWER_KIND_MAGE
}
function tt:filter_func(entity)
	return self.owner ~= entity and entity.tower.can_be_sold and table.contains(self.tower_kinds, entity.tower.kind) and 
	not table.contains(self.excluded_templates, entity.template_name)
end
tt.template_hover = "decal_tower_arcane_wizard_empowerment_preview"
tt.main_script.insert = customScripts1.royal_archers_decal_preview_controller.insert
tt.main_script.remove = customScripts1.royal_archers_decal_preview_controller.remove

tt = E:register_t("decal_scripted_shooter", "decal_scripted")
E:add_comps(tt, "attacks", "powers")
tt.owner = nil

tt = E:register_t("tower_royal_archer_and_musketeer", "tower_royal_archers_lvl4")
tt.main_script.insert = customScripts1.tower_royal_archer_and_musketeer.insert
tt.main_script.update = customScripts1.tower_royal_archer_and_musketeer.update
tt.main_script.remove = customScripts1.tower_royal_archer_and_musketeer.remove
tt.info.i18n_key = "TOWER_ROYAL_ARCHER_AND_MUSKETEER"
tt.tower.level = 1
tt.tower.price = 0
tt.tower.type = "archer_and_musketeer"
table.remove(tt.render.sprites, 4)
tt.sid_rapacious_hunter = 5
tt.shooters = {
	"shooter_musketeer"
}
tt.sound_events.insert = "ArcherMusketeerTaunt"

tt = E:register_t("shooter_musketeer", "decal_scripted_shooter")
b = balance.towers.musketeer
tt.main_script.update = customScripts1.shooter_musketeer.update
tt.powers.sniper = CC("power")
tt.powers.sniper.damage_factor_inc = 0.2
tt.powers.sniper.instakill_chance_inc = 0.2
tt.powers.shrapnel = CC("power")
tt.render.sprites[1].prefix = "tower_musketeer_shooter"
tt.render.sprites[1].name = "idleDown"
tt.render.sprites[1].scale = v(1.12, 1.12)
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.idle = {
	"idleUp",
	"idleDown"
}
tt.render.sprites[1].angles.shoot = {
	"shootingUp",
	"shootingDown"
}
tt.render.sprites[1].angles.sniper_shoot = {
	"sniperShootUp",
	"sniperShootDown"
}
tt.render.sprites[1].angles.sniper_seek = {
	"sniperSeekUp",
	"sniperSeekDown"
}
tt.render.sprites[1].angles.cannon_shoot = {
	"cannonShootUp",
	"cannonShootDown"
}
tt.render.sprites[1].angles.cannon_fuse = {
	"cannonFuseUp",
	"cannonFuseDown"
}
tt.render.sprites[1].offset = v(12, 66)
tt.attacks.range = 235
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "shotgun_musketeer"
tt.attacks.list[1].cooldown = 1.5
tt.attacks.list[1].shoot_time = fts(6)
tt.attacks.list[1].shooters_delay = 0.1
tt.attacks.list[1].bullet_start_offset = {
	v(6, 8),
	v(4, -5)
}
tt.attacks.list[2] = CC("bullet_attack")
tt.attacks.list[2].ts = nil
tt.attacks.list[2].animation = "sniper_shoot"
tt.attacks.list[2].animation_seeker = "sniper_seek"
tt.attacks.list[2].bullet = "shotgun_musketeer_sniper"
tt.attacks.list[2].bullet_start_offset = tt.attacks.list[1].bullet_start_offset
tt.attacks.list[2].cooldown = b.sniper.cooldown
tt.attacks.list[2].power_name = "sniper"
tt.attacks.list[2].shoot_time = fts(22)
tt.attacks.list[2].vis_flags = bor(F_INSTAKILL)
tt.attacks.list[2].vis_bans = bor(F_BOSS, F_MINIBOSS, F_NIGHTMARE)
tt.attacks.list[2].range = tt.attacks.range * 1.5
tt.attacks.list[3] = table.deepclone(tt.attacks.list[2])
tt.attacks.list[3].chance = 0
tt.attacks.list[3].bullet = "shotgun_musketeer_sniper_instakill"
tt.attacks.list[4] = CC("bullet_attack")
tt.attacks.list[4].ts = nil
tt.attacks.list[4].animation = "cannon_shoot"
tt.attacks.list[4].animation_seeker = "cannon_fuse"
tt.attacks.list[4].bullet = "bomb_musketeer"
tt.attacks.list[4].loops = 6
tt.attacks.list[4].bullet_start_offset = tt.attacks.list[1].bullet_start_offset
tt.attacks.list[4].cooldown = b.shrapnel.cooldown
tt.attacks.list[4].power_name = "shrapnel"
tt.attacks.list[4].range = tt.attacks.range * 0.5
tt.attacks.list[4].shoot_time = fts(16)
tt.attacks.list[4].node_prediction = fts(8)
tt.attacks.list[4].min_spread = 12.5
tt.attacks.list[4].max_spread = 32.5
tt.attacks.list[4].vis_bans = bor(F_FLYING, F_NIGHTMARE)
tt.attacks.list[4].shoot_fx = "fx_rifle_smoke"

tt = E:register_t("tower_royal_archer_and_ranger", "tower_royal_archers_lvl4")
tt.main_script.insert = customScripts1.tower_royal_archer_and_ranger.insert
tt.main_script.update = customScripts1.tower_royal_archer_and_musketeer.update
tt.main_script.remove = customScripts1.tower_royal_archer_and_musketeer.remove
tt.info.i18n_key = "TOWER_ROYAL_ARCHER_AND_RANGER"
tt.tower.level = 1
tt.tower.price = 0
tt.tower.type = "archer_and_ranger"
table.remove(tt.render.sprites, 4)
tt.sid_rapacious_hunter = 5
tt.shooters = {
	"shooter_ranger"
}
tt.sound_events.insert = "ArcherRangerTaunt"

tt = E:register_t("shooter_ranger", "decal_scripted_shooter")
tt.main_script.update = customScripts1.shooter_ranger.update
tt.powers.poison = CC("power")
tt.powers.poison.mod = "mod_ranger_poison"
tt.powers.thorn = CC("power")
tt.powers.thorn.aura = "aura_ranger_thorn"
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "tower_ranger_shooter"
tt.render.sprites[1].name = "idleDown"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.idle = {
	"idleUp",
	"idleDown"
}
tt.render.sprites[1].angles.shoot = {
	"shootingUp",
	"shootingDown"
}
tt.render.sprites[1].offset = v(12, 70)
tt.render.sprites[1].scale = v(0.915, 0.915)
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "royal_archer_tower_lvl4_tower_rapacious_hunter_base"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(-1, 13)
tt.render.sprites[2].flip_x = true
tt.render.sprites[2].sort_y_offset = -1
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "tower_ranger_druid"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].hidden = true
tt.render.sprites[3].offset = v(-41, 15)
tt.render.sprites[3].scale = v(1.05, 1.05)
tt.render.sprites[3].sort_y_offset = -1
tt.attacks.range = 200
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "arrow_ranger"
tt.attacks.list[1].cooldown = 0.4
tt.attacks.list[1].shoot_time = fts(4)
tt.attacks.list[1].shooters_delay = 0.1
tt.attacks.list[1].bullet_start_offset = {
	v(8, 6),
	v(4, -3)
}

tt = E:register_t("tower_royal_archer_and_longbow", "tower_royal_archers_lvl4")
tt.main_script.insert = customScripts1.tower_royal_archer_and_longbow.insert
tt.main_script.update = customScripts1.tower_royal_archer_and_musketeer.update
tt.main_script.remove = customScripts1.tower_royal_archer_and_musketeer.remove
tt.info.i18n_key = "TOWER_ROYAL_ARCHER_AND_LONGBOW"
tt.tower.level = 1
tt.tower.price = 0
tt.tower.type = "archer_and_longbow"
table.remove(tt.render.sprites, 4)
tt.render.sprites[4].sort_y_offset = -2
tt.sid_rapacious_hunter = 5
tt.shooters = {
	"shooter_longbow"
}
tt.sound_events.insert = "ElvesArcherGoldenBowTaunt"

tt = E:register_t("shooter_longbow", "decal_scripted_shooter")
b = balance.towers.silver
tt.main_script.update = customScripts1.shooter_longbow.update
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
		v(9, 12),
		v(6, 3)
	},
	{
		v(9, 12),
		v(6, 3)
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
		v(9, 12),
		v(6, 3)
	},
	{
		v(9, 12),
		v(6, 3)
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
		v(9, 12),
		v(6, 3)
	},
	{
		v(9, 12),
		v(6, 3)
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
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "tower_silver_shooter"
tt.render.sprites[1].name = "idleDown"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.idle = {
	"idleUp",
	"idleDown"
}
tt.render.sprites[1].angles.shoot = {
	"shootShortUp",
	"shootShortDown"
}
tt.render.sprites[1].angles.shoot_long = {
	"shootUp",
	"shootDown"
}
tt.render.sprites[1].angles.mark = {
	"shootSpecialShortUp",
	"shootSpecialShortDown"
}
tt.render.sprites[1].angles.mark_long = {
	"shootSpecialUp",
	"shootSpecialDown"
}
tt.render.sprites[1].angles.sentence = {
	"instakillUp",
	"instakillDown"
}
tt.render.sprites[1].offset = v(12, 70)
tt.render.sprites[1].sort_y_offset = -1

tt = E:register_t("veznan_crystal", "decal_scripted")
E:add_comps(tt, "ui", "attacks", "tween")
tt.ui.can_click = true
tt.ui.click_rect = r(-37, -16, 74, 65)
tt.tween.disabled = true
tt.tween.remove = nil
tt.tween.reverse = nil
tt.tween.props[1].sprite_id = {}
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
tt.tween_duration = 0.5
tt.animation_group1 = "veznan_crystal_layer"
tt.animation_group2 = "veznan_crystal_range"
for i = 1, 11 do
	if i > 1 then
		tt.render.sprites[i] = E:clone_c("sprite")
	end
	tt.render.sprites[i].prefix = "veznan_crystal_layer" .. i
	tt.render.sprites[i].name = "ready"
	tt.render.sprites[i].anchor = v(0.5, 0.246)
	tt.render.sprites[i].group = tt.animation_group1
end
local scale = 175 / 108
for i = 12, 15 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].name = "veznan_crystal_range"
	tt.render.sprites[i].animated = nil
	tt.render.sprites[i].anchor = v(1, 0)
	tt.render.sprites[i].scale = v(scale * 0.7 ^ ((i % 2)), scale * 0.7 ^ (1 - (i % 2)))
	tt.render.sprites[i].r = math.pi / 2 * (i - 12)
	tt.render.sprites[i].hidden = true
	tt.render.sprites[i].group = tt.animation_group2
	table.insert(tt.tween.props[1].sprite_id, i)
end
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].vis_flags = bor(F_RANGED)
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "veznan_crystal_ray"
tt.attacks.list[1].bullet_start_offset = {
	v(0, 32)
}
tt.attacks.list[1].max_targets = 3
tt.attacks.list[1].cooldown = 15
tt.attacks.list[1].range = 175
tt.attacks.list[1].sound = "dark_army_blazing_mage_attack_loopstart"
tt.attacks.list[1].sound_args = {
	delay = fts(2)
}
tt.main_script.update = customScripts1.veznan_crystal.update

tt = E:register_t("veznan_crystal_ray", "continuous_ray")
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_min = 60
tt.bullet.damage_max = 60
tt.bullet.mods = {
	"mod_veznan_crystal_ray",
}
tt.image_width = 65
tt.ray_duration = 1.4
tt.render.sprites[1].prefix = "veznan_crystal_ray"
tt.render.sprites[1].name = "in"

tt = E:register_t("mod_veznan_crystal_ray", "mod_continuous_ray")
tt.animation_start = "veznan_crystal_hit_start_run"
tt.animation_loop = "veznan_crystal_hit_end_run"
tt.render.sprites[1].name = "veznan_crystal_hit_start_run"
