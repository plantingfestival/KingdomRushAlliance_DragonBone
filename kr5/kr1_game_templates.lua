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

-- heroes
tt = RT("projectile_denas", "arrow")
AC(tt, "sound_events")
tt.bullet.flight_time = fts(20)
tt.bullet.rotation_speed = 15 * FPS * math.pi / 180
tt.bullet.predict_target_pos = nil
tt.bullet.use_unit_damage_factor = true
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_min = 11
tt.bullet.damage_max = 19
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.miss_decal = nil
tt.bullet.miss_fx = "fx_smoke_bullet"
tt.bullet.track_kills = true
tt.bullet.xp_gain_factor = 2.42
tt.render.sprites[1].name = "hero_king_projectiles_0001"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "AxeSound"

tt = RT("projectile_denas_barrell", "projectile_denas")
tt.render.sprites[1].name = "hero_king_projectiles_0002"

tt = RT("projectile_denas_chicken", "projectile_denas")
tt.render.sprites[1].name = "hero_king_projectiles_0003"

tt = RT("projectile_denas_bottle", "projectile_denas")
tt.render.sprites[1].name = "hero_king_projectiles_0004"

tt = RT("projectile_denas_melee", "projectile_denas")
tt.bullet.flight_time = fts(13)

tt = RT("projectile_denas_melee_barrell", "projectile_denas_barrell")
tt.bullet.flight_time = fts(13)

tt = RT("projectile_denas_melee_chicken", "projectile_denas_chicken")
tt.bullet.flight_time = fts(13)

tt = RT("projectile_denas_melee_bottle", "projectile_denas_bottle")
tt.bullet.flight_time = fts(13)

tt = E:register_t("controller_item_hero_denas", "controller_item_hero")
tt.entity = "hero_denas"

tt = RT("hero_denas", "hero5")
AC(tt, "melee", "ranged", "timed_attacks")
anchor_x, anchor_y = 0.5, 0.26
image_x, image_y = 152, 108
tt.hero.fixed_stat_attack = 6
tt.hero.fixed_stat_health = 5
tt.hero.fixed_stat_range = 6
tt.hero.fixed_stat_speed = 3
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
	19,
	23,
	28,
	33,
	38,
	42,
	47,
	52,
	56,
	61
}
tt.hero.level_stats.melee_damage_min = {
	11,
	14,
	17,
	20,
	23,
	25,
	28,
	31,
	34,
	37
}
tt.hero.level_stats.ranged_damage_max = {
	19,
	23,
	28,
	33,
	38,
	42,
	47,
	52,
	56,
	61
}
tt.hero.level_stats.ranged_damage_min = {
	11,
	14,
	17,
	20,
	23,
	25,
	28,
	31,
	34,
	37
}
tt.hero.level_stats.regen_health = {
	75,
	80,
	85,
	90,
	95,
	100,
	105,
	110,
	115,
	120
}
tt.hero.skills.tower_buff = CC("hero_skill")
tt.hero.skills.tower_buff.duration = {
	5,
	10,
	15
}
tt.hero.skills.tower_buff.xp_level_steps = {
	[10] = 3,
	[2] = 1,
	[5] = 2
}
tt.hero.skills.tower_buff.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.catapult = CC("hero_skill")
tt.hero.skills.catapult.count = {
	3,
	6,
	9
}
tt.hero.skills.catapult.damage_min = {
	10,
	20,
	30
}
tt.hero.skills.catapult.damage_max = {
	30,
	40,
	50
}
tt.hero.skills.catapult.xp_level_steps = {
	[10] = 3,
	[4] = 1,
	[7] = 2
}
tt.hero.skills.catapult.xp_gain = {
	100,
	200,
	300
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 60)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr1_scripts.hero_denas.level_up
tt.hero.tombstone_decal = "decal_kr1_hero_tombstone"
tt.hero.tombstone_show_time = fts(60)
tt.info.i18n_key = "HERO_DENAS"
tt.info.fn = kr1_scripts.hero_basic.get_info_ranged
tt.info.portrait = "portraits_hero_0118"
tt.main_script.update = kr1_scripts.hero_denas.update
tt.motion.max_speed = 2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "hero_denas"
tt.soldier.melee_slot_offset = v(22, 0)
tt.sound_events.change_rally_point = "HeroDenasTaunt"
tt.sound_events.death = "HeroDenasDeath"
tt.sound_events.hero_room_select = "HeroDenasTauntSelect"
tt.sound_events.insert = "HeroRainOfFireTauntIntro"
tt.sound_events.respawn = "HeroRainOfFireTauntIntro"
tt.ui.click_rect = r(-22, 0, 44, 47)
tt.unit.hit_offset = v(0, 31)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 30)
tt.melee.range = 45
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animations = {
	"attack",
	"attackBarrell",
	"attackChicken",
	"attackBottle"
}
tt.ranged.attacks[1].bullet = "projectile_denas"
tt.ranged.attacks[1].bullets = {
	"projectile_denas",
	"projectile_denas_barrell",
	"projectile_denas_chicken",
	"projectile_denas_bottle"
}
tt.ranged.attacks[1].bullet_start_offset = {
	v(10, 36)
}
tt.ranged.attacks[1].cooldown = fts(19)
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 45
tt.ranged.attacks[1].node_prediction = fts(27)
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].basic_attack = true
tt.timed_attacks.list[1] = table.deepclone(tt.ranged.attacks[1])
tt.timed_attacks.list[1].vis_bans = 0
tt.timed_attacks.list[1].bullets = {
	"projectile_denas_melee",
	"projectile_denas_melee_barrell",
	"projectile_denas_melee_chicken",
	"projectile_denas_melee_bottle"
}
tt.timed_attacks.list[1].cooldown = 1.5
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "buffTowers"
tt.timed_attacks.list[2].cooldown = 10 + fts(51)
tt.timed_attacks.list[2].cast_time = fts(13)
tt.timed_attacks.list[2].curse_time = fts(2)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_range = 165
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].mod = "mod_denas_tower"
tt.timed_attacks.list[2].aura = "denas_buff_aura"
tt.timed_attacks.list[2].sound = "HeroDenasBuff"
tt.timed_attacks.list[2].xp_from_skill = "buff_towers"
tt.timed_attacks.list[3] = CC("spawn_attack")
tt.timed_attacks.list[3].animation = "catapult"
tt.timed_attacks.list[3].entity = "denas_catapult_controller"
tt.timed_attacks.list[3].cooldown = 10 + fts(40)
tt.timed_attacks.list[3].cast_time = fts(15)
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].max_range = 180
tt.timed_attacks.list[3].min_range = 50
tt.timed_attacks.list[3].crowd_range = 100
tt.timed_attacks.list[3].min_targets = 3
tt.timed_attacks.list[3].sound = "HeroDenasAttack"
tt.timed_attacks.list[3].vis_bans = bor(F_FRIEND, F_NIGHTMARE)
tt.timed_attacks.list[3].vis_flags = F_RANGED
tt.timed_attacks.list[3].xp_from_skill = "catapult"
tt.timed_attacks.list[3].search_type = U.search_type.find_max_crowd

tt = E:register_t("denas_catapult_rock", "bombKR5")
tt.bullet.flight_time = fts(45)
tt.bullet.damage_radius = 50
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.g = -0.8 / (fts(1) * fts(1))
tt.bullet.particles_name = "ps_power_fireball"
tt.render.sprites[1].name = "hero_king_catapultProjectile"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = v(0.7, 0.7)
tt.sound_events.insert = nil

tt = RT("denas_catapult_controller", "decal_scripted")
AC(tt, "tween", "sound_events")
tt.count = nil
tt.bullet = "denas_catapult_rock"
tt.main_script.update = kr1_scripts.denas_catapult_controller.update
tt.initial_angle = d2r(0)
tt.initial_delay = 0.25
tt.rock_delay = {
	fts(2),
	fts(8)
}
tt.angle_increment = d2r(60)
tt.rock_offset = v(90, 100)
tt.exit_time = 0.5 + fts(45)
tt.render.sprites[1].name = "hero_king_catapultDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "alpha"
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
tt.tween.remove = false
tt.sound_events.shoot = "BombShootSound"

tt = E:register_t("controller_item_hero_hacksaw", "controller_item_hero")
tt.entity = "hero_hacksaw"

tt = RT("hero_hacksaw", "hero5")
AC(tt, "melee", "ranged")
anchor_x, anchor_y = 0.5, 0.13636363636363635
image_x, image_y = 90, 110
tt.hero.fixed_stat_attack = 7
tt.hero.fixed_stat_health = 8
tt.hero.fixed_stat_range = 0
tt.hero.fixed_stat_speed = 3
tt.hero.level_stats.armor = {
	0.5,
	0.5,
	0.5,
	0.6,
	0.6,
	0.6,
	0.7,
	0.7,
	0.7,
	0.8
}
tt.hero.level_stats.hp_max = {
	420,
	440,
	460,
	480,
	500,
	520,
	540,
	560,
	580,
	600
}
tt.hero.level_stats.melee_damage_max = {
	27,
	30,
	33,
	36,
	39,
	42,
	45,
	48,
	51,
	54
}
tt.hero.level_stats.melee_damage_min = {
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
tt.hero.level_stats.regen_health = {
	105,
	110,
	115,
	120,
	125,
	130,
	135,
	140,
	145,
	150
}
tt.hero.skills.timber = CC("hero_skill")
tt.hero.skills.timber.cooldown = {
	35 + fts(35),
	23 + fts(35),
	12 + fts(35)
}
tt.hero.skills.timber.xp_level_steps = {
	[10] = 3,
	[4] = 1,
	[7] = 2
}
tt.hero.skills.timber.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.sawblade = CC("hero_skill")
tt.hero.skills.sawblade.bounces = {
	2,
	4,
	6
}
tt.hero.skills.sawblade.xp_level_steps = {
	[10] = 3,
	[2] = 1,
	[5] = 2
}
tt.hero.skills.sawblade.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 15
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 58)
tt.hero.fn_level_up = kr1_scripts.hero_hacksaw.level_up
tt.hero.tombstone_decal = "decal_kr1_hero_tombstone"
tt.hero.tombstone_show_time = fts(150)
tt.info.fn = kr1_scripts.hero_basic.get_info_melee
-- tt.info.i18n_key = "HERO_ROBOT"
tt.info.portrait = "portraits_hero_0117"
tt.main_script.update = kr1_scripts.hero_hacksaw.update
tt.motion.max_speed = 1.8 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.13636363636363635)
tt.render.sprites[1].prefix = "hero_hacksaw"
tt.soldier.melee_slot_offset = v(13, 0)
tt.sound_events.change_rally_point = "HeroHacksawTaunt"
tt.sound_events.death = "BombExplosionSound"
tt.sound_events.death2 = "HeroHacksawDeath"
tt.sound_events.hero_room_select = "HeroHacksawTauntSelect"
tt.sound_events.insert = "HeroHacksawTauntIntro"
tt.sound_events.respawn = "HeroHacksawTauntIntro"
tt.unit.hit_offset = v(0, 38)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 25)
tt.unit.pop_offset = v(0, 15)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.melee.order = {
	2,
	1
}
tt.melee.range = 65
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "timber"
tt.melee.attacks[2].cooldown = nil
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(14)
tt.melee.attacks[2].pop = {
	"pop_splat"
}
tt.melee.attacks[2].pop_chance = 1
tt.melee.attacks[2].sound = "HeroHacksawDrill"
tt.melee.attacks[2].sound_args = {
	delay = fts(7)
}
tt.melee.attacks[2].damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_NO_DODGE)
tt.melee.attacks[2].xp_from_skill = "timber"
tt.melee.attacks[2].vis_flags = bor(F_INSTAKILL)
tt.melee.attacks[2].vis_bans = bor(F_BOSS, F_MINIBOSS)
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].animation = "sawblade"
tt.ranged.attacks[1].bullet = "hacksaw_sawblade"
tt.ranged.attacks[1].bullet_start_offset = {
	v(25, 21)
}
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].max_range = 180
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(16)
tt.ranged.attacks[1].sound_shoot = "HeroHacksawShoot"
tt.ranged.attacks[1].cooldown = 8 + fts(32)
tt.ranged.attacks[1].xp_from_skill = "sawblade"
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)

tt = E:register_t("hacksaw_sawblade", "bullet")
tt.main_script.update = kr1_scripts.hacksaw_sawblade.update
tt.bullet.particles_name = "ps_hacksaw_sawblade"
tt.bullet.acceleration_factor = 0.05
tt.bullet.min_speed = 390
tt.bullet.max_speed = 390
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.bullet.damage_min = 135
tt.bullet.damage_max = 135
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.hit_fx = "fx_hacksaw_sawblade_hit"
tt.bullet.max_speed = 390
tt.bullet.damage_type = DAMAGE_TRUE
tt.bounces_max = nil
tt.bounce_range = 150
tt.render.sprites[1].prefix = "hacksaw_sawblade"
tt.sound_events.insert = "HeroAlienDiscoThrow"
tt.sound_events.bounce = "HeroAlienDiscoBounce"

tt = RT("aura_ingvar_bear_regenerate", "aura")
AC(tt, "regen")
tt.aura.duration = 0
tt.main_script.update = kr1_scripts.aura_ingvar_bear_regenerate.update
tt.regen.cooldown = 0.5
tt.regen.health = 2

tt = E:register_t("controller_item_hero_ingvar", "controller_item_hero")
tt.entity = "hero_ingvar"

tt = RT("hero_ingvar", "hero5")
AC(tt, "melee", "timed_attacks", "auras")
anchor_x, anchor_y = 0.5, 0.19
image_x, image_y = 142, 116
tt.hero.fixed_stat_attack = 8
tt.hero.fixed_stat_health = 8
tt.hero.fixed_stat_range = 0
tt.hero.fixed_stat_speed = 5
tt.hero.level_stats.armor = {
	0.1,
	0.1,
	0.15,
	0.15,
	0.2,
	0.2,
	0.25,
	0.25,
	0.3,
	0.4
}
tt.hero.level_stats.hp_max = {
	430,
	460,
	490,
	520,
	550,
	580,
	610,
	640,
	670,
	670
}
tt.hero.level_stats.melee_damage_max = {
	38,
	41,
	45,
	49,
	53,
	56,
	60,
	64,
	68,
	71
}
tt.hero.level_stats.melee_damage_min = {
	23,
	25,
	27,
	29,
	32,
	34,
	36,
	38,
	41,
	43
}
tt.hero.level_stats.regen_health = {
	108,
	115,
	123,
	130,
	138,
	145,
	153,
	160,
	168,
	175
}
tt.hero.skills.ancestors_call = CC("hero_skill")
tt.hero.skills.ancestors_call.count = {
	1,
	2,
	3
}
tt.hero.skills.ancestors_call.hp_max = {
	100,
	200,
	300
}
tt.hero.skills.ancestors_call.damage_min = {
	3,
	6,
	9
}
tt.hero.skills.ancestors_call.damage_max = {
	6,
	12,
	18
}
tt.hero.skills.ancestors_call.xp_level_steps = {
	[10] = 3,
	[2] = 1,
	[5] = 2
}
tt.hero.skills.ancestors_call.xp_gain = {
	100,
	200,
	300
}
tt.hero.skills.bear = CC("hero_skill")
tt.hero.skills.bear.damage_min = {
	20,
	40,
	60
}
tt.hero.skills.bear.damage_max = {
	40,
	60,
	80
}
tt.hero.skills.bear.duration = {
	10,
	15,
	20
}
tt.hero.skills.bear.xp_level_steps = {
	[10] = 3,
	[4] = 1,
	[7] = 2
}
tt.hero.skills.bear.xp_gain = {
	100,
	200,
	300
}
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_ingvar_bear_regenerate"
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, ady(68))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr1_scripts.hero_ingvar.level_up
tt.hero.team = TEAM_LINIREA
tt.hero.tombstone_decal = "decal_kr1_hero_tombstone"
tt.hero.tombstone_show_time = fts(60)
tt.info.fn = kr1_scripts.hero_ingvar.get_info
tt.info.i18n_key = "HERO_VIKING"
tt.info.portrait = "portraits_hero_0116"
tt.main_script.update = kr1_scripts.hero_ingvar.update
tt.motion.max_speed = 2.5 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "hero_ingvar"
tt.soldier.melee_slot_offset = v(14, 0)
tt.sound_events.change_rally_point = "HeroVikingTaunt"
tt.sound_events.change_rally_point_viking = "HeroVikingTaunt"
tt.sound_events.change_rally_point_bear = "HeroVikingBearTransform"
tt.sound_events.death = "HeroVikingDeath"
tt.sound_events.hero_room_select = "HeroVikingTauntSelect"
tt.sound_events.insert = "HeroVikingTauntIntro"
tt.sound_events.respawn = "HeroVikingTauntIntro"
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.unit.hit_offset = v(0, 20)
tt.melee.range = 83.2
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "HeroVikingAttackHit"
tt.melee.attacks[1].hit_decal = "decal_ingvar_attack"
tt.melee.attacks[1].hit_offset = v(48, -1)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].hit_time = fts(15)
tt.melee.attacks[2].hit_offset = v(-25, 2)
tt.melee.attacks[3] = CC("melee_attack")
tt.melee.attacks[3].animations = {
	nil,
	"attack"
}
tt.melee.attacks[3].cooldown = 3
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].hit_times = {
	fts(10),
	fts(25),
	fts(41)
}
tt.melee.attacks[3].loopable = true
tt.melee.attacks[3].loops = 1
tt.melee.attacks[3].sound_hit = "HeroVikingAttackHit"
tt.melee.attacks[3].sound = "HeroVikingBearAttackStart"
tt.melee.attacks[3].vis_flags = F_BLOCK
tt.melee.attacks[3].xp_gain_factor = 2
tt.melee.attacks[3].basic_attack = true
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "ancestors"
tt.timed_attacks.list[1].cooldown = 14 + fts(40)
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_ingvar_ancestor"
tt.timed_attacks.list[1].sound = "HeroVikingCall"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(5)
}
tt.timed_attacks.list[1].nodes_offset = {
	4,
	8
}
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].cooldown = 10
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].duration = nil
tt.timed_attacks.list[2].transform_health_factor = 0.6
tt.timed_attacks.list[2].immune_to = bor(DAMAGE_BASE_TYPES, DAMAGE_MODIFIER)
tt.timed_attacks.list[2].sound = "HeroVikingBearTransform"

tt = RT("soldier_ingvar_ancestor", "soldier_militia")
AC(tt, "reinforcement", "melee")
image_x, image_y = 72, 60
anchor_y = 0.17
tt.health.armor = 0.25
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 46)
tt.health.dead_lifetime = fts(30)
tt.info.portrait = "bottom_info_image_soldiers_0046"
tt.info.fn = kr1_scripts.soldier_mercenary.get_info
tt.info.i18n_key = "HERO_VIKING_ANCESTOR"
tt.info.random_name_format = nil
tt.main_script.insert = kr1_scripts.soldier_reinforcement.insert
tt.main_script.remove = kr1_scripts.soldier_reinforcement.remove
tt.main_script.update = kr1_scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.range = 128
tt.motion.max_speed = 2.3 * FPS
tt.reinforcement.duration = 12
tt.reinforcement.fade = nil
tt.regen.cooldown = 1
tt.render.sprites[1].prefix = "soldier_ingvar_ancestor"
tt.ui.click_rect = r(-13, 0, 26, 30)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.unit.price = 0
tt.vis.bans = bor(F_LYCAN, F_SKELETON, F_CANNIBALIZE)

tt = E:register_t("mod_ray_tesla", "modifier")
E:add_comps(tt, "render", "dps")
tt.modifier.duration = fts(14)
tt.modifier.vis_flags = F_MOD
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = bor(DAMAGE_ELECTRICAL, DAMAGE_ONE_SHIELD_HIT)
tt.dps.damage_every = fts(2)
tt.dps.cocos_frames = 14
tt.dps.cocos_cycles = 13
tt.dps.pop = {
	"pop_bzzt"
}
tt.dps.pop_chance = 1
tt.dps.pop_conds = DR_KILL
tt.dps.kill = true
tt.render.sprites[1].prefix = "mod_tesla_hit"
tt.render.sprites[1].size_names = {
	"small",
	"medium",
	"large"
}
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update

tt = E:register_t("controller_item_hero_thor", "controller_item_hero")
tt.entity = "hero_thor"

tt = RT("hero_thor", "hero5")
AC(tt, "melee", "ranged")
anchor_x, anchor_y = 0.5, 0.25
image_x, image_y = 120, 96
tt.hero.fixed_stat_attack = 8
tt.hero.fixed_stat_health = 7
tt.hero.fixed_stat_range = 0
tt.hero.fixed_stat_speed = 5
tt.hero.level_stats.armor = {
	0.4,
	0.4,
	0.4,
	0.5,
	0.5,
	0.5,
	0.6,
	0.6,
	0.6,
	0.7
}
tt.hero.level_stats.hp_max = {
	380,
	410,
	440,
	470,
	500,
	530,
	560,
	590,
	620,
	650
}
tt.hero.level_stats.melee_damage_max = {
	31,
	34,
	36,
	39,
	42,
	44,
	47,
	49,
	52,
	55
}
tt.hero.level_stats.melee_damage_min = {
	25,
	27,
	29,
	32,
	34,
	36,
	38,
	40,
	42,
	44
}
tt.hero.level_stats.regen_health = {
	95,
	103,
	110,
	118,
	125,
	133,
	140,
	148,
	155,
	163
}
tt.hero.skills.chainlightning = CC("hero_skill")
tt.hero.skills.chainlightning.count = {
	2,
	3,
	4
}
tt.hero.skills.chainlightning.damage_max = {
	40,
	80,
	120
}
tt.hero.skills.chainlightning.xp_level_steps = {
	[10] = 3,
	[2] = 1,
	[5] = 2
}
tt.hero.skills.chainlightning.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.thunderclap = CC("hero_skill")
tt.hero.skills.thunderclap.damage_max = {
	80,
	160,
	240
}
tt.hero.skills.thunderclap.secondary_damage_max = {
	50,
	100,
	150
}
tt.hero.skills.thunderclap.max_range = {
	70,
	75,
	80
}
tt.hero.skills.thunderclap.stun_duration = {
	3,
	4,
	6
}
tt.hero.skills.thunderclap.xp_level_steps = {
	[10] = 3,
	[4] = 1,
	[7] = 2
}
tt.hero.skills.thunderclap.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 53)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.team = TEAM_LINIREA
tt.hero.fn_level_up = kr1_scripts.hero_thor.level_up
tt.hero.tombstone_decal = "decal_kr1_hero_tombstone"
tt.hero.tombstone_show_time = fts(150)
tt.info.fn = kr1_scripts.hero_basic.get_info_melee
tt.info.i18n_key = "HERO_THOR"
tt.info.portrait = "portraits_hero_0114"
tt.main_script.update = kr1_scripts.hero_thor.update
tt.motion.max_speed = 2.7 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.25)
tt.render.sprites[1].prefix = "hero_thor"
tt.soldier.melee_slot_offset = v(13, 0)
tt.sound_events.change_rally_point = "HeroThorTaunt"
tt.sound_events.death = "HeroThorDeath"
tt.sound_events.hero_room_select = "HeroThorTauntSelect"
tt.sound_events.insert = "HeroThorTauntIntro"
tt.sound_events.respawn = "HeroThorTauntIntro"
tt.unit.hit_offset = v(0, 22)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.melee.range = 65
tt.melee.cooldown = 1.5
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2.1
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "chain"
tt.melee.attacks[2].chance = 0.25
tt.melee.attacks[2].cooldown = 1.5 + fts(34)
tt.melee.attacks[2].damage_type = DAMAGE_NO_DODGE
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(16)
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].sound = "HeroThorElectricAttack"
tt.melee.attacks[2].mod = "mod_hero_thor_chainlightning"
tt.melee.attacks[2].xp_from_skill = "chainlightning"
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].animation = "thunderclap"
tt.ranged.attacks[1].bullet = "hammer_hero_thor"
tt.ranged.attacks[1].bullet_start_offset = {
	v(25, 10)
}
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].cooldown = 14 + fts(28)
tt.ranged.attacks[1].max_range = 250
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].shoot_time = fts(12)
tt.ranged.attacks[1].search_type = U.search_type.max_health
tt.ranged.attacks[1].sound_shoot = "HeroThorHammer"
tt.ranged.attacks[1].xp_from_skill = "thunderclap"

tt = E:register_t("mod_ray_hero_thor", "mod_ray_tesla")
tt.modifier.duration = fts(16)
tt.dps.damage_every = fts(2)
tt.dps.damage_min = 5
tt.dps.damage_max = 5
tt.dps.damage_type = DAMAGE_MAGICAL

tt = RT("mod_hero_thor_chainlightning", "modifier")
tt.chainlightning = {}
tt.chainlightning.bullet = "ray_hero_thor"
tt.chainlightning.count = 2
tt.chainlightning.damage = 40
tt.chainlightning.offset = v(25, -1)
tt.chainlightning.damage_type = DAMAGE_TRUE
tt.chainlightning.chain_delay = fts(2)
tt.chainlightning.max_range = 110
tt.chainlightning.min_range = 40
tt.chainlightning.mod = "mod_tesla_overcharge"
tt.main_script.update = kr1_scripts.mod_hero_thor_chainlightning.update

tt = E:register_t("hammer_hero_thor", "bolt")
tt.bullet.acceleration_factor = 0.05
tt.bullet.min_speed = 300
tt.bullet.max_speed = 900
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.hit_blood_fx = nil
tt.bullet.hit_fx = nil
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.mod = "mod_hero_thor_thunderclap"
tt.bullet.pop = nil
tt.render.sprites[1].prefix = "hammer_hero_thor"
tt.sound_events.insert = nil

tt = RT("mod_hero_thor_thunderclap", "modifier")
AC(tt, "render")
tt.thunderclap = {}
tt.thunderclap.damage = 60
tt.thunderclap.offset = v(0, 10)
tt.thunderclap.damage_type = DAMAGE_TRUE
tt.thunderclap.explosion_delay = fts(3)
tt.thunderclap.secondary_damage = 50
tt.thunderclap.secondary_damage_type = DAMAGE_MAGICAL
tt.thunderclap.radius = 70
tt.thunderclap.stun_duration_max = 3
tt.thunderclap.stun_duration_min = 3
tt.thunderclap.mod_stun = "mod_hero_thor_stun"
tt.thunderclap.mod_fx = "mod_tesla_overcharge"
tt.thunderclap.fx = "fx_hero_thor_thunderclap_disipate"
tt.thunderclap.sound = "HeroThorThunder"
tt.main_script.update = kr1_scripts.mod_hero_thor_thunderclap.update
tt.main_script.insert = kr1_scripts.mod_track_target.insert
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[1].name = "mod_hero_thor_thunderclap"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].loop = false
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "mod_hero_thor_thunderclap_explosion"

tt = RT("mod_hero_thor_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)

tt = RT("ps_hero_10yr_idle", "particle_system")
tt.particle_system.name = "ps_hero_10yr_particle_fire"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	0.5,
	0.5
}
tt.particle_system.alphas = {
	255,
	255
}
tt.particle_system.emit_duration = nil
tt.particle_system.emit_direction = d2r(90)
tt.particle_system.emit_speed = {
	30,
	30
}
tt.particle_system.emission_rate = 2.5
tt.particle_system.source_lifetime = nil
tt.particle_system.z = Z_OBJECTS

tt = RT("hero_10yr", "hero5")
AC(tt, "melee", "ranged", "timed_attacks", "teleport", "launch_movement")
b = balance.heroes.hero_10yr
tt.hero.level_stats.armor = {
	0.2,
	0.23,
	0.26,
	0.3,
	0.33,
	0.36,
	0.4,
	0.43,
	0.46,
	0.5
}
tt.hero.level_stats.hp_max = {
	380,
	400,
	420,
	440,
	460,
	480,
	500,
	520,
	540,
	560
}
tt.hero.level_stats.regen_health_normal = {
	95,
	100,
	105,
	110,
	115,
	120,
	125,
	130,
	135,
	140
}
tt.hero.level_stats.regen_health_buffed = {
	95,
	100,
	105,
	110,
	115,
	120,
	125,
	130,
	135,
	140
}
tt.hero.level_stats.regen_health = tt.hero.level_stats.regen_health_normal
tt.hero.level_stats.melee_damage_max = {
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
tt.hero.level_stats.melee_damage_min = {
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

tt.hero.skills.rain = CC("hero_skill")
tt.hero.skills.rain.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.rain.hr_order = 1
tt.hero.skills.rain.hr_available = true
tt.hero.skills.rain.loops = {
	2,
	3,
	4
}
tt.hero.skills.rain.damage_min = {
	30,
	45,
	60
}
tt.hero.skills.rain.damage_max = {
	60,
	75,
	90
}
tt.hero.skills.rain.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.rain.key = "RAIN"

tt.hero.skills.waterball = CC("hero_skill")
tt.hero.skills.waterball.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.waterball.hr_order = 2
tt.hero.skills.waterball.hr_available = true
tt.hero.skills.waterball.damage_min = {
	32,
	64,
	96
}
tt.hero.skills.waterball.damage_max = {
	49,
	98,
	147
}
tt.hero.skills.waterball.key = "WATERBALL"

tt.hero.skills.buffed = CC("hero_skill")
tt.hero.skills.buffed.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.buffed.hr_order = 3
tt.hero.skills.buffed.hr_available = true
tt.hero.skills.buffed.xp_gain = {
	50,
	75,
	100
}
tt.hero.skills.buffed.spin_damage_min = {
	18,
	27,
	36
}
tt.hero.skills.buffed.spin_damage_max = {
	36,
	46,
	56
}
tt.hero.skills.buffed.duration = {
	6,
	9,
	12
}
tt.hero.skills.buffed.key = "BUFFED"

tt.hero.skills.bomb = CC("hero_skill")
tt.hero.skills.bomb.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.bomb.hr_order = 4
tt.hero.skills.bomb.hr_available = true
tt.hero.skills.bomb.xp_gain = {
	50,
	75,
	100
}
tt.hero.skills.bomb.bomb_steps = {
	3,
	4,
	6
}
tt.hero.skills.bomb.bomb_step_damage_min = {
	10,
	15,
	20
}
tt.hero.skills.bomb.bomb_step_damage_max = {
	20,
	30,
	40
}
tt.hero.skills.bomb.bomb_damage_min = {
	50,
	60,
	70
}
tt.hero.skills.bomb.bomb_damage_max = {
	70,
	85,
	100
}
tt.hero.skills.bomb.key = "BOMB"

tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_10yr_ultimate"
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.hr_cost = {
	1,
	4,
	4,
	4
}
tt.hero.skills.ultimate.hr_available = true
tt.hero.skills.ultimate.damage_min = {
	30,
	50,
	90,
	150
}
tt.hero.skills.ultimate.damage_max = {
	60,
	80,
	120,
	180
}
tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown
tt.hero.skills.ultimate.key = "ULTIMATE"

tt.hero.team = TEAM_LINIREA
tt.hero.fn_level_up = kr1_scripts.hero_10yr.level_up
tt.hero.tombstone_decal = "decal_kr1_hero_tombstone"
tt.hero.tombstone_show_time = fts(90)
tt.health.dead_lifetime = 30
tt.health_bar.offset = v(0, 37)
tt.health_bar.offset_buffed = v(0, 51)
tt.health_bar.offset_normal = tt.health_bar.offset
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.fn = kr1_scripts.hero_10yr.get_info
tt.info.i18n_key = "HERO_10YR"
tt.info.hero_portrait = "hero_portraits_0105"
tt.info.portrait = "portraits_hero_0105"
tt.info.ultimate_icon = "0105"
tt.info.ultimate_pointer_style = "area"
tt.info.stat_hp = 9
tt.info.stat_armor = 5
tt.info.stat_damage = 7
tt.info.stat_cooldown = 6
tt.main_script.update = kr1_scripts.hero_10yr.update
tt.motion.max_speed_normal = 1.6 * FPS
tt.motion.max_speed_buffed = 2.2 * FPS
tt.motion.max_speed = tt.motion.max_speed_normal
tt.particles_aura = "aura_10yr_idle"
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.20161290322580644)
tt.render.sprites[1].prefix = "hero_10yr"
tt.render.sprites[1].sort_y_offset = -3
tt.normal_melee_slot_offset = v(10, 2)
tt.buffed_melee_slot_offset = v(18, 0)
tt.soldier.melee_slot_offset = tt.normal_melee_slot_offset
tt.sound_events.change_rally_point = "TenShiTaunt"
tt.sound_events.change_rally_point_normal = "TenShiTaunt"
tt.sound_events.change_rally_point_buffed = "TenShiTauntBuffed"
tt.sound_events.death = "TenShiDeathSfx"
tt.sound_events.death_args = {
	delay = fts(5)
}
tt.sound_events.hero_room_select = "TenShiTauntSelect"
tt.sound_events.insert = "TenShiTauntIntro"
tt.sound_events.respawn = "TenShiRespawn"
tt.teleport.min_distance = 100
tt.teleport.delay = 0
tt.teleport.sound = "TenShiTeleportSfx"
tt.launch_movement.min_distance = 150
tt.launch_movement.disabled = true
tt.launch_movement.launch_sound = "HeroTraminLand"
tt.launch_movement.launch_args = {
	delay = 0.5
}
tt.launch_movement.launch_entity = "decal_ground_slam"
tt.launch_movement.land_sound = "HeroBeresadSpawnImpact"
tt.land_entity = "aura_10yr_land"
tt.normal_mod_offset = v(0, 15)
tt.normal_hit_offset = v(0, 16)
tt.buffed_mod_offset = v(0, 20)
tt.buffed_hit_offset = v(0, 20)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.unit.hit_offset = v(0, 16)
tt.unit.hide_after_death = true
tt.melee.range_normal = 55
tt.melee.range_buffed = 85
tt.melee.range = tt.melee.range_normal
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].cooldown = 1.35
tt.melee.attacks[1].hit_time = fts(19)
tt.melee.attacks[1].sound = "TenShiAttack1"
tt.melee.attacks[1].hit_offset = v(20, 0)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 1.5
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].hit_time = fts(28)
tt.melee.attacks[2].hit_offset = v(20, 2)
tt.melee.attacks[2].sound = "TenShiAttack2"
tt.melee.attacks[2].disabled = true
tt.melee.attacks[3] = CC("area_attack")
tt.melee.attacks[3].basic_attack = true
tt.melee.attacks[3].animations = {
	"spin_start",
	"spin_loop",
	"spin_end"
}
tt.melee.attacks[3].cooldown = 2
tt.melee.attacks[3].loops = 2
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_radius = 60
tt.melee.attacks[3].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[3].hit_times = {
	fts(2),
	fts(6)
}
tt.melee.attacks[3].sound = "TenShiBuffedSpinAttack"
tt.melee.attacks[3].vis_flags = F_BLOCK
tt.melee.attacks[3].xp_gain_factor = 1.5
tt.ranged.attacks[1].animation = "attack2"
tt.ranged.attacks[1].cooldown = 4
tt.ranged.attacks[1].shoot_time = fts(26)
tt.ranged.attacks[1].bullet = "hero_10yr_waterball"
tt.ranged.attacks[1].bullet_start_offset = {
	v(18, 18)
}
tt.ranged.attacks[1].min_range = 65
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].xp_gain_factor = 5
tt.ranged.attacks[1].disabled = true
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animations = {
	"power_rain_start",
	"power_rain_loop",
	"power_rain_end"
}
tt.timed_attacks.list[1].cooldown = 25
tt.timed_attacks.list[1].entity = "aura_10yr_fireball"
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].sound_start = "TenShiRainOfFireStart"
tt.timed_attacks.list[1].sound_end = "TenShiRainOfFireEnd"
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].trigger_range = 150
tt.timed_attacks.list[1].max_range = 200
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND, F_NIGHTMARE)
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].xp_from_skill = "rain"
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].cooldown = 10
tt.timed_attacks.list[2].min_count = 3
tt.timed_attacks.list[2].range = 100
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].duration = nil
tt.timed_attacks.list[2].immune_to = bor(DAMAGE_BASE_TYPES, DAMAGE_MODIFIER)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_NIGHTMARE)
tt.timed_attacks.list[2].sounds_buffed = {
	"TenShiTransformToBuffed",
	"TenShiTransformToBuffedSfx"
}
tt.timed_attacks.list[2].sounds_normal = {
	"TenShiTransformToNormalSfx"
}
tt.timed_attacks.list[2].xp_from_skill = "buffed"
tt.timed_attacks.list[3] = CC("area_attack")
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].cooldown = 9
tt.timed_attacks.list[3].animation = "bomb"
tt.timed_attacks.list[3].count = 16
tt.timed_attacks.list[3].damage_max = nil
tt.timed_attacks.list[3].damage_min = nil
tt.timed_attacks.list[3].damage_radius = 60
tt.timed_attacks.list[3].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[3].hit_decal = "decal_ground_hit"
tt.timed_attacks.list[3].hit_fx = "fx_ground_hit"
tt.timed_attacks.list[3].hit_offset = v(0, 0)
tt.timed_attacks.list[3].hit_time = fts(28)
tt.timed_attacks.list[3].hit_aura = "aura_10yr_bomb"
tt.timed_attacks.list[3].min_count = 2
tt.timed_attacks.list[3].min_range = 80
tt.timed_attacks.list[3].max_range = 150
tt.timed_attacks.list[3].min_nodes = 0
tt.timed_attacks.list[3].max_nodes = 20
tt.timed_attacks.list[3].pop = {
	"pop_kapow",
	"pop_whaam"
}
tt.timed_attacks.list[3].pop_chance = 0.3
tt.timed_attacks.list[3].pop_conds = DR_KILL
tt.timed_attacks.list[3].sound_short = "TenShiBuffedBombAttack"
tt.timed_attacks.list[3].sound_long = "TenShiBuffedBombAttackLong"
tt.timed_attacks.list[3].sound = tt.timed_attacks.list[3].sound_short
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING, F_NIGHTMARE)
tt.timed_attacks.list[3].xp_from_skill = "bomb"

tt = E:register_t("aura_10yr_fireball", "aura")
tt.main_script.update = kr1_scripts.aura_10yr_fireball.update
tt.aura.entity = "fireball_10yr"
tt.aura.delay = fts(15)
tt.aura.loops = nil
tt.aura.min_range = E:get_template("hero_10yr").timed_attacks.list[1].min_range
tt.aura.max_range = E:get_template("hero_10yr").timed_attacks.list[1].max_range
tt.aura.vis_flags = E:get_template("hero_10yr").timed_attacks.list[1].vis_flags
tt.aura.vis_bans = E:get_template("hero_10yr").timed_attacks.list[1].vis_bans

tt = E:register_t("fireball_10yr", "bullet")
tt.bullet.min_speed = 24 * FPS
tt.bullet.max_speed = 24 * FPS
tt.bullet.acceleration_factor = 0.05
tt.bullet.hit_fx = "fx_fireball_explosion"
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_radius = 75
tt.bullet.damage_min = 30
tt.bullet.damage_max = 60
tt.bullet.damage_flags = F_AREA
tt.render.sprites[1].name = "fireball_proyectile"
tt.main_script.update = scripts.power_fireball.update
tt.scorch_earth = false
tt.sound_events.insert = "FireballRelease"
tt.sound_events.hit = "FireballHit"

tt = RT("aura_10yr_bomb", "aura")
tt.aura.fx = "decal_10yr_spike"
tt.aura.damage_radius = 40
tt.aura.last_attack_damage_radius = 50
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.step_delay = fts(2)
tt.aura.step_nodes = 5
tt.aura.steps = 3
tt.main_script.update = kr1_scripts.aura_10yr_bomb.update
tt.stun = {}
tt.stun.vis_flags = bor(F_RANGED, F_STUN)
tt.stun.vis_bans = bor(F_BOSS)
tt.stun.mod = "mod_10yr_stun"
tt.aura.damage_min = 10
tt.aura.damage_max = 20
tt.aura.stun_chance = 1
tt.aura.min_nodes = 0
tt.aura.max_nodes = 25
tt.aura.min_count = 1

tt = RT("aura_10yr_land", "aura")
tt.aura.fx = "decal_10yr_spike"
tt.aura.damage_radius = 50
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.damage_min = 10
tt.aura.damage_max = 20
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.vis_bans = bor(F_FRIEND)
tt.stun = {}
tt.stun.vis_flags = bor(F_RANGED, F_STUN)
tt.stun.vis_bans = bor(F_BOSS)
tt.stun.mod = "mod_10yr_stun"
tt.stun.duration = 1
tt.main_script.update = kr1_scripts.aura_10yr_land.update

tt = RT("mod_10yr_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.duration = 3

tt = RT("decal_10yr_spike", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_10yr_bomb_spike"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].anchor.y = 0.24
tt.render.sprites[2].z = Z_OBJECTS + 1

tt = RT("aura_10yr_idle", "aura")
tt.aura.duration = 0
tt.particles_name = "ps_hero_10yr_idle"
tt.emit_states = {
	"idle",
	"running"
}
tt.main_script.update = kr1_scripts.aura_10yr_particles.update
tt.particle_offsets = {
	v(-25.714285714285715, 25.714285714285715),
	v(-15.714285714285715, 37.142857142857146),
	v(0, 45.714285714285715),
	v(8.571428571428571, 42.85714285714286),
	v(14.285714285714286, 32.85714285714286),
	v(21.42857142857143, 21.42857142857143)
}
tt.flip_offset = v(3, 0)

tt = E:register_t("fx_hero_10yr_waterball_hit", "fx")
tt.render.sprites[1].name = "hero_10yr_waterball_hit"
tt.render.sprites[1].anchor = v(0.5, 0.5)

tt = E:register_t("hero_10yr_waterball", "bolt")
E:add_comps(tt, "force_motion")
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_radius = 30
tt.bullet.use_unit_damage_factor = true
tt.bullet.hit_fx = "fx_hero_10yr_waterball_hit"
tt.bullet.particles_name = "ps_bullet_hero_dragon_arb_water"
tt.bullet.align_with_trajectory = nil
tt.bullet.max_speed = 300
tt.bullet.min_speed = 30
tt.bullet.pop_chance = 0
tt.bullet.shot_index = 1
tt.initial_impulse = 15000
tt.initial_impulse_duration = 0.15
tt.initial_impulse_angle = math.pi / 6
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 300
tt.render.sprites[1].prefix = "hero_dragon_arborean_water_projectile"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_BULLETS
function tt.main_script.insert(this, store, script)
	return true
end
tt.main_script.update = customScripts1.custom_bolt.update
tt.sound_events.insert = "EmberLordsMageAttack"

tt = E:register_t("decal_ground_slam", "decal_tween")
tt.render.sprites[1].name = "hero_tank_GroundSlam_ground"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		3.4,
		0
	}
}

tt = E:register_t("hero_10yr_ultimate")
E:add_comps(tt, "pos", "main_script", "user_power")
tt.entity = "power_fireball"
tt.can_fire_fn = kr1_scripts.hero_10yr_ultimate.can_fire_fn
tt.main_script.update = scripts.power_fireball_control.update
tt.cooldown = 80
tt.max_spread = 20
tt.fireball_count = 5
tt.cataclysm_count = 0

tt = E:register_t("controller_item_hero_bolin", "controller_item_hero")
tt.entity = "hero_bolin"

tt = RT("hero_bolin", "hero5")
AC(tt, "melee", "timed_attacks")

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
	430,
	460,
	490,
	520,
	550,
	580,
	610,
	640,
	670
}
tt.hero.level_stats.melee_damage_max = {
	30,
	36,
	40,
	46,
	50,
	56,
	60,
	66,
	70,
	76
}
tt.hero.level_stats.melee_damage_min = {
	18,
	22,
	24,
	28,
	30,
	34,
	36,
	40,
	42,
	46
}
tt.hero.level_stats.ranged_damage_max = {
	30,
	36,
	40,
	46,
	50,
	56,
	60,
	66,
	70,
	76
}
tt.hero.level_stats.ranged_damage_min = {
	18,
	22,
	24,
	28,
	30,
	34,
	36,
	40,
	42,
	46
}
tt.hero.level_stats.regen_health = {
	100,
	108,
	115,
	123,
	130,
	138,
	145,
	153,
	160,
	168
}
tt.hero.skills.mines = CC("hero_skill")
tt.hero.skills.mines.xp_gain = {
	12,
	24,
	36
}
tt.hero.skills.mines.damage_min = {
	30,
	60,
	90
}
tt.hero.skills.mines.damage_max = {
	60,
	90,
	120
}
tt.hero.skills.tar = CC("hero_skill")
tt.hero.skills.tar.duration = {
	4,
	6,
	8
}
tt.hero.skills.tar.xp_gain = {
	25,
	50,
	75
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 35)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.team = TEAM_LINIREA
tt.hero.fn_level_up = kr1_scripts.hero_bolin.level_up
tt.hero.tombstone_decal = "decal_kr1_hero_tombstone"
tt.hero.tombstone_show_time = fts(60)
tt.info.damage_icon = "shot"
tt.info.fn = kr1_scripts.hero_bolin.get_info
tt.info.i18n_key = "HERO_RIFLEMAN"
tt.info.portrait = "portraits_hero_0106"
tt.melee.range = 65
tt.main_script.update = kr1_scripts.hero_bolin.update
tt.motion.max_speed = 2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.24)
tt.render.sprites[1].prefix = "hero_bolin"
tt.render.sprites[1].angles.shoot = {
	"shootRightLeft",
	"shootUp",
	"shootDown"
}
tt.render.sprites[1].angles.shootAim = {
	"shootAimRightLeft",
	"shootAimUp",
	"shootAimDown"
}
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "HeroRiflemanTaunt"
tt.sound_events.death = "HeroRiflemanDeath"
tt.sound_events.hero_room_select = "HeroRiflemanTauntSelect"
tt.sound_events.insert = "HeroRiflemanTauntIntro"
tt.sound_events.respawn = "HeroRiflemanTauntIntro"
tt.ui.click_rect = r(-15, -5, 30, 35)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].xp_gain_factor = 1.5
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].basic_attack = true
tt.timed_attacks.list[1].bullet = "shotgun_bolin"
tt.timed_attacks.list[1].aim_animation = "shootAim"
tt.timed_attacks.list[1].shoot_animation = "shoot"
tt.timed_attacks.list[1].bullet_start_offset = {
	v(0, 20),
	v(0, 20),
	v(0, 20)
}
tt.timed_attacks.list[1].cooldown = 2
tt.timed_attacks.list[1].shoot_times = {
	fts(10),
	fts(12),
	fts(12)
}
tt.timed_attacks.list[1].max_shoots = 3
tt.timed_attacks.list[1].min_range = 50
tt.timed_attacks.list[1].max_range = 180
tt.timed_attacks.list[1].shoot_time = fts(2)
tt.timed_attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].xp_gain_factor = 1.5
tt.timed_attacks.list[2] = CC("bullet_attack")
tt.timed_attacks.list[2].bullet = "bomb_tar_bolin"
tt.timed_attacks.list[2].bullet_start_offset = v(0, 30)
tt.timed_attacks.list[2].cooldown = 14 + fts(27)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].min_range = 100
tt.timed_attacks.list[2].max_range = 200
tt.timed_attacks.list[2].shoot_time = fts(13)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[3] = CC("bullet_attack")
tt.timed_attacks.list[3].bullet = "bomb_mine_bolin"
tt.timed_attacks.list[3].bullet_start_offset = v(0, 12)
tt.timed_attacks.list[3].count = 5
tt.timed_attacks.list[3].cooldown = 6 + fts(19)
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].max_range = 60
tt.timed_attacks.list[3].shoot_time = fts(3)
tt.timed_attacks.list[3].node_offset = {
	-12,
	12
}

tt = RT("shotgun_bolin", "shotgun")
tt.bullet.damage_max = 65
tt.bullet.damage_min = 35
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.miss_fx = "fx_smoke_bullet"
tt.bullet.start_fx = nil
tt.bullet.min_speed = 20 * FPS
tt.bullet.max_speed = 20 * FPS
tt.bullet.xp_gain_factor = 1.5
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.use_unit_damage_factor = true
tt.sound_events.insert = "ShotgunSound"

tt = RT("bomb_tar_bolin", "bomb")
tt.bullet.damage_bans = F_ALL
tt.bullet.damage_flags = 0
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.damage_radius = 1
tt.bullet.flight_time_base = fts(34)
tt.bullet.flight_time_factor = fts(0.016666666666666666)
tt.bullet.pop = nil
tt.bullet.hit_payload = "aura_bolin_tar"
tt.main_script.insert = scripts.bomb.insert
tt.main_script.update = scripts.bomb.update
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.hide_radius = nil
tt.render.sprites[1].name = "hero_artillery_brea_shot"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "HeroRiflemanBrea"
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil

tt = RT("aura_bolin_tar", "aura")
AC(tt, "render", "tween")

tt.aura.cycle_time = fts(10)
tt.aura.duration = 4
tt.aura.mod = "mod_bolin_slow"
tt.aura.radius = 80
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_ENEMY)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = kr1_scripts.aura_slow_bolin.update
tt.render.sprites[1].prefix = "decal_bolin_tar"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = true
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

tt = RT("mod_bolin_slow", "mod_slow")
tt.modifier.duration = 1
tt.slow.factor = 0.5

tt = RT("bomb_mine_bolin", "bomb")
tt.bullet.damage_bans = F_ALL
tt.bullet.damage_flags = 0
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.damage_radius = 1
tt.bullet.flight_time = fts(24)
tt.bullet.pop = nil
tt.bullet.hit_payload = "decal_bolin_mine"
tt.main_script.insert = scripts.bomb.insert
tt.main_script.update = scripts.bomb.update
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.hide_radius = nil
tt.render.sprites[1].name = "hero_artillery_mine_proy"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "HeroRiflemanMine"
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil

tt = RT("decal_bolin_mine", "decal_scripted")
tt.check_interval = fts(3)
tt.damage_max = nil
tt.damage_min = nil
tt.damage_type = DAMAGE_EXPLOSION
tt.duration = 50
tt.hit_decal = "decal_bomb_crater"
tt.hit_fx = "fx_explosion_fragment"
tt.main_script.update = kr1_scripts.decal_bolin_mine.update
tt.trigger_radius = 40
tt.explosion_radius = 50
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "decal_bolin_mine"
tt.render.sprites[1].z = Z_DECALS
tt.sound = "BombExplosionSound"
tt.vis_bans = bor(F_FRIEND, F_FLYING)
tt.vis_flags = bor(F_ENEMY)

tt = E:register_t("controller_item_hero_gerald", "controller_item_hero")
tt.entity = "hero_gerald"

tt = RT("hero_gerald", "hero5")
AC(tt, "melee", "timed_attacks", "dodge")

tt.hero.level_stats.armor = {
	0.3,
	0.3,
	0.4,
	0.4,
	0.5,
	0.5,
	0.6,
	0.6,
	0.7,
	0.8
}
tt.hero.level_stats.hp_max = {
	400,
	420,
	440,
	460,
	480,
	500,
	520,
	540,
	560,
	580
}
tt.hero.level_stats.melee_damage_max = {
	18,
	20,
	23,
	25,
	28,
	30,
	33,
	35,
	38,
	40
}
tt.hero.level_stats.melee_damage_min = {
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
tt.hero.level_stats.regen_health = {
	100,
	105,
	110,
	115,
	120,
	125,
	130,
	135,
	140,
	145
}
tt.hero.skills.block_counter = CC("hero_skill")
tt.hero.skills.block_counter.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.courage = CC("hero_skill")
tt.hero.skills.courage.xp_gain = {
	25,
	50,
	75
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 36)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.team = TEAM_LINIREA
tt.hero.fn_level_up = kr1_scripts.hero_gerald.level_up
tt.hero.tombstone_decal = "decal_kr1_hero_tombstone"
tt.hero.tombstone_show_time = fts(90)
tt.info.fn = scripts.hero_basic.get_info_melee
tt.info.i18n_key = "HERO_PALADIN"
tt.info.portrait = "portraits_hero_0107"
tt.main_script.update = kr1_scripts.hero_gerald.update
tt.motion.max_speed = 2.2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.12)
tt.render.sprites[1].prefix = "hero_gerald"
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "HeroPaladinTaunt"
tt.sound_events.death = "HeroPaladinDeath"
tt.sound_events.hero_room_select = "HeroPaladinTauntSelect"
tt.sound_events.insert = "HeroPaladinTauntIntro"
tt.sound_events.respawn = "HeroPaladinTauntIntro"
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].xp_gain_factor = 1.5
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.range = 65
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "courage"
tt.timed_attacks.list[1].cooldown = 6 + fts(55)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].mod = "mod_gerald_courage"
tt.timed_attacks.list[1].range = 150
tt.timed_attacks.list[1].shoot_time = fts(17)
tt.timed_attacks.list[1].sound = "HeroPaladinValor"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(3)
}
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_MOD)
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY)
tt.dodge.animation = "counter"
tt.dodge.can_dodge = kr1_scripts.hero_gerald.fn_can_dodge
tt.dodge.chance = 0
tt.dodge.chance_base = 0
tt.dodge.chance_inc = 0.2
tt.dodge.time_before_hit = fts(4)
tt.dodge.low_chance_factor = 1
tt.dodge.counter_attack = E:clone_c("melee_attack")
tt.dodge.counter_attack.animation = "counter"
tt.dodge.counter_attack.damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_DODGE)
tt.dodge.counter_attack.reflected_damage_factor = 0.5
tt.dodge.counter_attack.reflected_damage_factor_inc = 0.5
tt.dodge.counter_attack.hit_time = fts(5)
tt.dodge.counter_attack.sound = "HeroPaladinDeflect"

tt = RT("mod_gerald_courage", "modifier")
AC(tt, "render")

tt.courage = {}
tt.courage.heal_once_factor = 0.15
tt.courage.damage_min_inc = 2
tt.courage.damage_max_inc = 2
tt.courage.armor_inc = 0.05
tt.courage.magic_armor_inc = 0
tt.modifier.duration = 6
tt.modifier.use_mod_offset = false
tt.main_script.insert = kr1_scripts.mod_gerald_courage.insert
tt.main_script.remove = kr1_scripts.mod_gerald_courage.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "mod_gerald_courage"
tt.render.sprites[1].anchor = v(0.51, 0.17307692307692307)
tt.render.sprites[1].draw_order = 2

tt = E:register_t("controller_item_hero_elora", "controller_item_hero")
tt.entity = "hero_elora"

tt = RT("hero_elora", "hero5")
AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {
	0.2,
	0.2,
	0.2,
	0.3,
	0.3,
	0.3,
	0.4,
	0.4,
	0.4,
	0.5
}
tt.hero.level_stats.hp_max = {
	270,
	290,
	310,
	330,
	350,
	370,
	390,
	410,
	430,
	450
}
tt.hero.level_stats.melee_damage_max = {
	2,
	4,
	6,
	8,
	11,
	13,
	16,
	18,
	20,
	23
}
tt.hero.level_stats.melee_damage_min = {
	1,
	2,
	4,
	6,
	7,
	9,
	10,
	12,
	14,
	15
}
tt.hero.level_stats.ranged_damage_max = {
	41,
	47,
	54,
	61,
	68,
	74,
	81,
	88,
	95,
	101
}
tt.hero.level_stats.ranged_damage_min = {
	34,
	36,
	38,
	40,
	43,
	45,
	47,
	49,
	52,
	54
}
tt.hero.level_stats.regen_health = {
	68,
	73,
	78,
	83,
	88,
	93,
	98,
	103,
	108,
	113
}
tt.hero.skills.chill = CC("hero_skill")
tt.hero.skills.chill.slow_factor = {
	0.4,
	0.30000000000000004,
	0.19999999999999996
}
tt.hero.skills.chill.max_range = {
	153.6,
	166.4,
	179.20000000000002
}
tt.hero.skills.chill.count = {
	6,
	8,
	10
}
tt.hero.skills.chill.xp_gain = {
	62,
	125,
	188
}
tt.hero.skills.ice_storm = CC("hero_skill")
tt.hero.skills.ice_storm.count = {
	3,
	5,
	8
}
tt.hero.skills.ice_storm.damage_max = {
	40,
	50,
	60
}
tt.hero.skills.ice_storm.damage_min = {
	20,
	30,
	40
}
tt.hero.skills.ice_storm.max_range = {
	153.6,
	166.4,
	179.20000000000002
}
tt.hero.skills.ice_storm.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 46)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.team = TEAM_LINIREA
tt.hero.fn_level_up = kr1_scripts.hero_elora.level_up
tt.hero.tombstone_decal = "decal_kr1_hero_tombstone"
tt.hero.tombstone_show_time = fts(60)
tt.info.i18n_key = "HERO_FROST_SORCERER"
tt.info.fn = scripts.hero_basic.get_info_ranged
tt.info.portrait = "portraits_hero_0109"
tt.main_script.update = kr1_scripts.hero_elora.update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.17)
tt.render.sprites[1].prefix = "hero_elora"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_elora_frostEffect"
tt.render.sprites[2].anchor = v(0.5, 0.1)
tt.render.sprites[2].hidden = true
tt.render.sprites[2].loop = true
tt.render.sprites[2].ignore_start = true
tt.run_particles_name = "ps_elora_run"
tt.soldier.melee_slot_offset = v(12, 0)
tt.sound_events.change_rally_point = "HeroFrostTaunt"
tt.sound_events.death = "HeroFrostDeath"
tt.sound_events.hero_room_select = "HeroFrostTauntSelect"
tt.sound_events.insert = "HeroFrostTauntIntro"
tt.sound_events.respawn = "HeroFrostTauntIntro"
tt.ui.click_rect = r(-15, -5, 30, 40)
tt.unit.mod_offset = v(0, 15)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 1
tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
tt.melee.range = 45
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[1].cooldown = fts(54)
tt.ranged.attacks[1].bullet = "bolt_elora_freeze"
tt.ranged.attacks[1].bullet_start_offset = {
	v(18, 36)
}
tt.ranged.attacks[1].chance = 0.2
tt.ranged.attacks[1].filter_fn = kr1_scripts.hero_elora.freeze_filter_fn
tt.ranged.attacks[1].min_range = 23.04
tt.ranged.attacks[1].max_range = 166.4
tt.ranged.attacks[1].shoot_time = fts(19)
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[1].vis_bans = bor(F_BOSS)
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].xp_gain_factor = 1
tt.ranged.attacks[2] = table.deepclone(tt.ranged.attacks[1])
tt.ranged.attacks[2].bullet = "bolt_elora_slow"
tt.ranged.attacks[2].chance = 1
tt.ranged.attacks[2].filter_fn = nil
tt.ranged.attacks[2].vis_bans = 0
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "iceStorm"
tt.timed_attacks.list[1].bullet = "elora_ice_spike"
tt.timed_attacks.list[1].cast_time = fts(24)
tt.timed_attacks.list[1].cooldown = 10 + fts(39)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = nil
tt.timed_attacks.list[1].min_range = 38.4
tt.timed_attacks.list[1].node_prediction = fts(27)
tt.timed_attacks.list[1].sound = "HeroFrostIceRainSummon"
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND)
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].xp_from_skill = "ice_storm"
tt.timed_attacks.list[2] = CC("aura_attack")
tt.timed_attacks.list[2].animation = "chill"
tt.timed_attacks.list[2].bullet = "aura_chill_elora"
tt.timed_attacks.list[2].cast_time = fts(18)
tt.timed_attacks.list[2].cooldown = 8 + fts(28)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_range = nil
tt.timed_attacks.list[2].min_range = 19.2
tt.timed_attacks.list[2].sound = "HeroFrostGroundFreeze"
tt.timed_attacks.list[2].step = 3
tt.timed_attacks.list[2].nodes_offset = 6
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_FRIEND)
tt.timed_attacks.list[2].vis_flags = F_RANGED
tt.timed_attacks.list[2].xp_from_skill = "chill"

tt = RT("ps_elora_run")
AC(tt, "pos", "particle_system")
tt.particle_system.alphas = {
	255,
	0
}
tt.particle_system.animated = true
tt.particle_system.emission_rate = 10
tt.particle_system.loop = false
tt.particle_system.z = Z_DECALS + 1
tt.particle_system.name = "ps_hero_elora_run"
tt.particle_system.particle_lifetime = {
	0.8,
	1
}

tt = RT("bolt_elora_freeze", "bolt")
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "bolt_elora"
tt.bullet.hit_fx = "fx_bolt_elora_hit"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.mod = "mod_elora_bolt_freeze"
tt.bullet.damage_min = 14
tt.bullet.damage_max = 41
tt.bullet.xp_gain_factor = 1
tt.bullet.use_unit_damage_factor = true

tt = RT("bolt_elora_slow", "bolt_elora_freeze")
tt.bullet.mod = "mod_elora_bolt_slow"

tt = RT("aura_chill_elora", "aura")
AC(tt, "render", "tween")
tt.aura.cycle_time = fts(10)
tt.aura.duration = 3
tt.aura.mod = "mod_elora_chill"
tt.aura.radius = 44.800000000000004
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_ENEMY)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = kr1_scripts.aura_chill_elora.update
tt.render.sprites[1].prefix = "decal_elora_chill_"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.2,
		0
	}
}

tt = RT("mod_elora_chill", "mod_slow")
tt.modifier.duration = fts(11)
tt.slow.factor = 0.8

tt = RT("mod_elora_bolt_freeze", "mod_freeze")
AC(tt, "render")
tt.modifier.duration = 2
tt.render.sprites[1].prefix = "freeze_creep"
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].loop = false
tt.custom_offsets = {}
tt.custom_offsets.flying = v(-5, 32)
tt.custom_suffixes = {}
tt.custom_suffixes.flying = "_air"
tt.custom_animations = {
	"start",
	"end"
}

tt = RT("mod_elora_bolt_slow", "mod_slow")
tt.modifier.duration = 2
tt.slow.factor = 0.5

tt = RT("fx_bolt_elora_hit", "fx")
tt.render.sprites[1].prefix = "fx_bolt_elora"
tt.render.sprites[1].name = "hit"

tt = RT("elora_ice_spike", "bullet")
tt.main_script.update = kr1_scripts.elora_ice_spike.update
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 51.2
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_FRIEND
tt.bullet.mod = nil
tt.bullet.hit_time = 0.1
tt.bullet.duration = 2
tt.spike_1_anchor_y = 0.16
tt.render.sprites[1].prefix = "elora_ice_spike_"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].anchor.y = 0.2
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_frost_spikes_decal"
tt.render.sprites[2].z = Z_DECALS
tt.sound_events.delayed_insert = "HeroFrostIceRainDrop"
tt.sound_events.ice_break = "HeroFrostIceRainBreak"

tt = RT("ps_hero_ignus_idle", "particle_system")
tt.particle_system.name = "ps_hero_ignus_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	0.5,
	0.5
}
tt.particle_system.alphas = {
	255,
	255
}
tt.particle_system.emit_duration = nil
tt.particle_system.emit_direction = d2r(90)
tt.particle_system.emit_speed = {
	30,
	30
}
tt.particle_system.emission_rate = 2.5
tt.particle_system.source_lifetime = nil
tt.particle_system.z = Z_OBJECTS

tt = RT("ps_ignus_run")
AC(tt, "pos", "particle_system")
tt.particle_system.alphas = {
	255,
	200,
	0
}
tt.particle_system.anchor = v(0.5, 0.1)
tt.particle_system.animated = true
tt.particle_system.emission_rate = 10
tt.particle_system.loop = false
tt.particle_system.z = Z_DECALS + 1
tt.particle_system.name = "ps_hero_ignus_run"
tt.particle_system.particle_lifetime = {
	0.6,
	0.8
}

tt = RT("ps_hero_ignus_smoke", "ps_power_fireball")
tt.particle_system.scales_x = {
	2,
	3
}
tt.particle_system.scales_y = {
	2,
	3
}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_offset = v(0, 17)
tt.particle_system.name = "ps_hero_ignus_smoke"
tt.particle_system.sort_y_offset = -16
tt.particle_system.z = Z_OBJECTS

tt = E:register_t("controller_item_hero_ignus", "controller_item_hero")
tt.entity = "hero_ignus"

tt = RT("hero_ignus", "hero5")
AC(tt, "melee", "timed_attacks")
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
	430,
	460,
	490,
	520,
	550,
	580,
	610,
	640,
	670
}
tt.hero.level_stats.melee_damage_max = {
	30,
	33,
	35,
	38,
	40,
	43,
	45,
	48,
	50,
	53
}
tt.hero.level_stats.melee_damage_min = {
	18,
	20,
	21,
	23,
	24,
	26,
	27,
	29,
	30,
	32
}
tt.hero.level_stats.regen_health = {
	100,
	108,
	115,
	123,
	130,
	138,
	145,
	153,
	160,
	168
}
tt.hero.skills.flaming_frenzy = CC("hero_skill")
tt.hero.skills.flaming_frenzy.damage_max = {
	30,
	50,
	70
}
tt.hero.skills.flaming_frenzy.damage_min = {
	20,
	40,
	60
}
tt.hero.skills.flaming_frenzy.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.surge_of_flame = CC("hero_skill")
tt.hero.skills.surge_of_flame.damage_max = {
	20,
	30,
	40
}
tt.hero.skills.surge_of_flame.damage_min = {
	10,
	20,
	30
}
tt.hero.skills.surge_of_flame.xp_gain = {
	25,
	50,
	75
}
tt.health.dead_lifetime = 12
tt.health_bar.offset = v(0, 41)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.team = TEAM_LINIREA
tt.hero.fn_level_up = kr1_scripts.hero_ignus.level_up
tt.hero.tombstone_decal = "decal_kr1_hero_tombstone"
tt.hero.tombstone_show_time = fts(60)
tt.info.fn = scripts.hero_basic.get_info_melee
tt.info.i18n_key = "HERO_FIRE"
tt.info.portrait = "portraits_hero_0108"
tt.main_script.update = kr1_scripts.hero_ignus.update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.1)
tt.render.sprites[1].prefix = "hero_ignus"
tt.run_particles_name = "ps_ignus_run"
tt.particles_aura = "aura_ignus_idle"
tt.soldier.melee_slot_offset = v(6, 0)
tt.sound_events.change_rally_point = "HeroRainOfFireTaunt"
tt.sound_events.death = "HeroRainOfFireDeath"
tt.sound_events.hero_room_select = "HeroRainOfFireTauntSelect"
tt.sound_events.insert = "HeroRainOfFireTauntIntro"
tt.sound_events.respawn = "HeroRainOfFireTauntIntro"
tt.unit.hit_offset = v(0, 19)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.vis.bans = bor(tt.vis.bans, F_BURN)
tt.melee.range = 60
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].xp_gain_factor = 1
tt.melee.attacks[1].sound_hit = "HeroReinforcementHit"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "flamingFrenzy"
tt.timed_attacks.list[1].cast_time = fts(8)
tt.timed_attacks.list[1].chance = 0.5
tt.timed_attacks.list[1].cooldown = 4 + fts(24)
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].decal = "decal_ignus_flaming"
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].heal_factor = 0.2
tt.timed_attacks.list[1].hit_fx = "fx_ignus_burn"
tt.timed_attacks.list[1].max_range = 90
tt.timed_attacks.list[1].sound = "HeroRainOfFireArea"
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND)
tt.timed_attacks.list[1].vis_flags = bor(F_AREA)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animations = {
	"surgeOfFlame",
	"surgeOfFlame_end"
}
tt.timed_attacks.list[2].aura = "aura_ignus_surge_of_flame"
tt.timed_attacks.list[2].cooldown = 4
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].nodes_margin = 8
tt.timed_attacks.list[2].min_range = 40
tt.timed_attacks.list[2].max_range = 130
tt.timed_attacks.list[2].speed_factor = 3.3333333333333335
tt.timed_attacks.list[2].sound = "HeroRainOfFireFireball1"
tt.timed_attacks.list[2].sound_end = "HeroRainOfFireFireball2"
tt.timed_attacks.list[2].vis_bans = bor(F_FRIEND)
tt.timed_attacks.list[2].vis_flags = bor(F_ENEMY, F_BLOCK)

tt = RT("aura_ignus_idle", "aura")
tt.aura.duration = 0
tt.particles_name = "ps_hero_ignus_idle"
tt.emit_states = {
	"idle",
	"attack"
}
tt.main_script.update = kr1_scripts.aura_ignus_particles.update
tt.particle_offsets = {
	v(-17, 16),
	v(-12, 27),
	v(4, 37),
	v(2, 35),
	v(12, 22),
	v(14, 13)
}
tt.flip_offset = v(3, 0)

tt = RT("aura_ignus_surge_of_flame", "aura")
tt.aura.cycle_time = fts(1)
tt.aura.duration = 0
tt.aura.damage_min = nil
tt.aura.damage_max = nil
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.damage_radius = 25
tt.aura.hit_fx = "fx_ignus_burn"
tt.damage_state = "surgeOfFlame"
tt.main_script.update = kr1_scripts.aura_ignus_surge_of_flame.update
tt.particles_name = "ps_hero_ignus_smoke"

tt = E:register_t("fx_ignus_burn", "fx")
tt.render.sprites[1].prefix = "fx_burn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}

tt = RT("decal_ignus_flaming", "decal_timed")
tt.render.sprites[1].name = "decal_ignus_flaming"
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("controller_item_hero_oni", "controller_item_hero")
tt.entity = "hero_oni"

tt = RT("hero_oni", "hero5")
AC(tt, "melee", "timed_attacks")
tt.hero.level_stats.armor = {
	0.3,
	0.3,
	0.3,
	0.4,
	0.4,
	0.4,
	0.5,
	0.5,
	0.6,
	0.6
}
tt.hero.level_stats.hp_max = {
	425,
	450,
	475,
	500,
	525,
	550,
	575,
	600,
	625,
	650
}
tt.hero.level_stats.melee_damage_max = {
	41,
	45,
	49,
	53,
	56,
	60,
	64,
	68,
	71,
	75
}
tt.hero.level_stats.melee_damage_min = {
	14,
	15,
	16,
	18,
	19,
	20,
	21,
	23,
	24,
	25
}
tt.hero.level_stats.regen_health = {
	106,
	113,
	119,
	125,
	131,
	138,
	144,
	150,
	156,
	163
}
tt.hero.skills.death_strike = CC("hero_skill")
tt.hero.skills.death_strike.chance = {
	0.1,
	0.2,
	0.3
}
tt.hero.skills.death_strike.damage = {
	180,
	360,
	540
}
tt.hero.skills.death_strike.xp_level_steps = {
	[10] = 3,
	[4] = 1,
	[7] = 2
}
tt.hero.skills.death_strike.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.torment = CC("hero_skill")
tt.hero.skills.torment.min_damage = {
	50,
	100,
	150
}
tt.hero.skills.torment.max_damage = {
	80,
	160,
	240
}
tt.hero.skills.torment.xp_level_steps = {
	[10] = 3,
	[2] = 1,
	[5] = 2
}
tt.hero.skills.torment.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 18
tt.health.on_damage = kr1_scripts.hero_oni.on_damage
tt.health_bar.offset = v(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr1_scripts.hero_oni.level_up
tt.hero.tombstone_decal = "decal_kr1_hero_tombstone"
tt.hero.tombstone_show_time = fts(150)
tt.hero.team = TEAM_LINIREA
tt.info.fn = scripts.hero_basic.get_info_melee
tt.info.i18n_key = "HERO_SAMURAI"
tt.info.portrait = "portraits_hero_0111"
tt.melee.range = 65
tt.main_script.update = kr1_scripts.hero_oni.update
tt.motion.max_speed = 2.7 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].prefix = "hero_oni"
tt.render.sprites[1].anchor = v(0.5, 0.14285714285714285)
tt.soldier.melee_slot_offset = v(8, 0)
tt.sound_events.change_rally_point = "HeroSamuraiTaunt"
tt.sound_events.death = "HeroSamuraiDeath"
tt.sound_events.hero_room_select = "HeroSamuraiTauntSelect"
tt.sound_events.insert = "HeroSamuraiTauntIntro"
tt.sound_events.respawn = "HeroSamuraiTauntIntro"
tt.unit.hit_offset = v(0, 21)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.unit.pop_offset = v(0, 10)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "deathStrike"
tt.melee.attacks[2].chance = 0.1
tt.melee.attacks[2].cooldown = 10 + fts(48)
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].damage_min = 180
tt.melee.attacks[2].damage_max = 180
tt.melee.attacks[2].damage_type = bor(DAMAGE_NO_DODGE, DAMAGE_INSTAKILL)
tt.melee.attacks[2].hit_time = fts(28)
tt.melee.attacks[2].pop = {
	"pop_splat"
}
tt.melee.attacks[2].pop_chance = 1
tt.melee.attacks[2].sound = "HeroSamuraiDeathStrike"
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].xp_from_skill = "death_strike"
tt.melee.attacks[2].vis_flags = bor(F_INSTAKILL)
tt.melee.attacks[2].vis_bans = bor(F_BOSS, F_MINIBOSS)
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[2])
tt.melee.attacks[3].chance = 1
tt.melee.attacks[3].damage_type = bor(DAMAGE_NO_DODGE, DAMAGE_TRUE)
tt.melee.attacks[3].pop = {
	"pop_sok",
	"pop_pow"
}
tt.melee.attacks[3].pop_chance = 0.1
tt.melee.attacks[3].vis_flags = F_RANGED
tt.melee.attacks[3].vis_bans = 0
tt.timed_attacks.list[1] = E:clone_c("area_attack")
tt.timed_attacks.list[1].animation = "torment"
tt.timed_attacks.list[1].cooldown = 14 + fts(68)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].damage_min = 50
tt.timed_attacks.list[1].damage_max = 80
tt.timed_attacks.list[1].damage_type = bor(DAMAGE_NO_DODGE, DAMAGE_TRUE)
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].max_range = 100
tt.timed_attacks.list[1].damage_radius = 100
tt.timed_attacks.list[1].hit_time = fts(16)
tt.timed_attacks.list[1].damage_delay = 0.15
tt.timed_attacks.list[1].sound_hit = "HeroSamuraiTorment"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].torment_swords = {
	{
		0.01,
		20,
		8
	},
	{
		0.2,
		37.5,
		8
	},
	{
		0.3,
		55,
		8
	}
}

tt = E:register_t("decal_oni_torment_sword", "decal_scripted")
tt.render.sprites[1].prefix = "decal_oni_torment_sword_1"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt.main_script.update = kr1_scripts.decal_oni_torment_sword.update
tt.duration = 0.5
tt.delay = 0.01
tt.sword_names = {
	"decal_oni_torment_sword_1",
	"decal_oni_torment_sword_2",
	"decal_oni_torment_sword_3",
	"decal_oni_torment_sword_1"
}

tt = RT("fx_bolt_magnus_hit", "fx")
tt.render.sprites[1].name = "bolt_magnus_hit"

tt = RT("magnus_arcane_rain_controller", "decal_scripted")
AC(tt, "tween")
tt.main_script.update = kr1_scripts.magnus_arcane_rain_controller.update
tt.duration = nil
tt.count = nil
tt.spawn_time = fts(6)
tt.initial_angle = d2r(0)
tt.angle_increment = d2r(70)
tt.entity = "magnus_arcane_rain"
tt.decal = "decal_magnus_arcane_rain"
tt.render.sprites[1].name = "hero_mage_rain_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "alpha"
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
tt.tween.remove = false
tt.tween.disabled = true

tt = E:register_t("magnus_arcane_rain")
AC(tt, "render", "main_script", "pos")
tt.damage_type = DAMAGE_TRUE
tt.damage_radius = 40
tt.damage_min = 20
tt.damage_max = 20
tt.hit_time = fts(10)
tt.damage_flags = F_AREA
tt.main_script.update = kr1_scripts.magnus_arcane_rain.update
tt.render.sprites[1].prefix = "magnus_arcane_rain"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0.5, 0.07)
tt.sound = "HeroMageRainDrop"

tt = RT("soldier_magnus_illusion", "soldier_militia")
AC(tt, "reinforcement", "ranged", "tween")
image_x, image_y = 60, 76
anchor_y = 0.14
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 33)
tt.health.dead_lifetime = fts(14)
tt.info.portrait = "portraits_hero_0115"
tt.info.i18n_key = "HERO_MAGE_SHADOW"
tt.info.random_name_format = nil
tt.info.fn = kr1_scripts.soldier_magnus_illusion.get_info
tt.main_script.insert = kr1_scripts.soldier_reinforcement.insert
tt.main_script.update = kr1_scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.range = 45
tt.reinforcement.duration = 10
tt.reinforcement.fade = nil
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_magnus_illusion"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 23)
}
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].damage_max = nil
tt.ranged.attacks[1].damage_min = nil
tt.ranged.attacks[1].shoot_time = fts(18)
tt.ranged.attacks[1].cooldown = fts(33)
tt.regen.cooldown = 1
tt.render.sprites[1].prefix = "soldier_magnus_illusion"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].alpha = 180
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
tt.ui.click_rect = r(-13, -5, 26, 32)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.unit.price = 0
tt.vis.bans = bor(F_LYCAN, F_SKELETON, F_CANNIBALIZE)

tt = RT("bolt_magnus", "bolt")
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "bolt_magnus"
tt.bullet.hit_fx = "fx_bolt_magnus_hit"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.damage_min = 9
tt.bullet.damage_max = 27
tt.bullet.max_speed = 360
tt.bullet.xp_gain_factor = 2.1

tt = RT("bolt_magnus_illusion", "bolt_magnus")
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.xp_gain_factor = nil

tt = E:register_t("controller_item_hero_magnus", "controller_item_hero")
tt.entity = "hero_magnus"

tt = RT("hero_magnus", "hero5")
AC(tt, "melee", "ranged", "timed_attacks", "teleport")
anchor_x, anchor_y = 0.5, 0.14
image_x, image_y = 60, 76
tt.hero.fixed_stat_attack = 2
tt.hero.fixed_stat_health = 2
tt.hero.fixed_stat_range = 8
tt.hero.fixed_stat_speed = 8
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
	170,
	190,
	210,
	230,
	250,
	270,
	290,
	310,
	330,
	350
}
tt.hero.level_stats.melee_damage_max = {
	2,
	4,
	5,
	6,
	7,
	8,
	10,
	11,
	12,
	13
}
tt.hero.level_stats.melee_damage_min = {
	1,
	2,
	2,
	3,
	4,
	5,
	6,
	6,
	7,
	8
}
tt.hero.level_stats.ranged_damage_max = {
	27,
	32,
	36,
	41,
	45,
	50,
	54,
	59,
	63,
	68
}
tt.hero.level_stats.ranged_damage_min = {
	9,
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
	43,
	48,
	53,
	58,
	63,
	68,
	73,
	78,
	83,
	88
}
tt.hero.skills.mirage = CC("hero_skill")
tt.hero.skills.mirage.count = {
	1,
	2,
	3
}
tt.hero.skills.mirage.health_factor = 0.35
tt.hero.skills.mirage.damage_factor = 0.35
tt.hero.skills.mirage.xp_level_steps = {
	[10] = 3,
	[2] = 1,
	[5] = 2
}
tt.hero.skills.mirage.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.arcane_rain = CC("hero_skill")
tt.hero.skills.arcane_rain.count = {
	6,
	12,
	18
}
tt.hero.skills.arcane_rain.damage = {
	20,
	40,
	60
}
tt.hero.skills.arcane_rain.xp_level_steps = {
	[10] = 3,
	[4] = 1,
	[7] = 2
}
tt.hero.skills.arcane_rain.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 33)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr1_scripts.hero_magnus.level_up
tt.hero.tombstone_decal = "decal_kr1_hero_tombstone"
tt.hero.tombstone_show_time = fts(60)
tt.info.fn = kr1_scripts.hero_basic.get_info_ranged
tt.info.i18n_key = "HERO_MAGE"
tt.info.portrait = "portraits_hero_0115"
tt.main_script.update = kr1_scripts.hero_magnus.update
tt.motion.max_speed = 1.2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "hero_magnus"
tt.soldier.melee_slot_offset = v(4, 0)
tt.sound_events.death = "HeroMageDeath"
tt.sound_events.insert = "HeroMageTauntIntro"
tt.sound_events.respawn = "HeroMageTauntIntro"
tt.sound_events.change_rally_point = "HeroMageTaunt"
tt.sound_events.hero_room_select = "HeroMageTauntSelect"
tt.teleport.min_distance = 100
tt.teleport.delay = 0
tt.teleport.sound = "TeleporthSound"
tt.ui.click_rect = r(-13, -5, 26, 32)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.melee.range = 45
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].xp_gain_factor = 2.1
tt.melee.attacks[1].basic_attack = true
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_magnus"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 23)
}
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(18)
tt.ranged.attacks[1].cooldown = fts(33)
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].basic_attack = true
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].max_range = 175
tt.timed_attacks.list[1].animation = "mirage"
tt.timed_attacks.list[1].cooldown = 10 + fts(29)
tt.timed_attacks.list[1].cast_time = fts(12)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_magnus_illusion"
tt.timed_attacks.list[1].entity_rotations = {
	{
		d2r(0)
	},
	{
		d2r(0),
		d2r(180)
	},
	{
		d2r(0),
		d2r(120),
		d2r(240)
	}
}
tt.timed_attacks.list[1].sound = "HeroMageShadows"
tt.timed_attacks.list[1].spawn_time = fts(19)
tt.timed_attacks.list[1].initial_rally = v(0, 30)
tt.timed_attacks.list[1].initial_pos = v(0, 33)
tt.timed_attacks.list[1].radius = 30
tt.timed_attacks.list[1].spawn_time = fts(19)
tt.timed_attacks.list[1].spawn_time = fts(19)
tt.timed_attacks.list[1].xp_from_skill = "mirage"
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].animation = "arcaneRain"
tt.timed_attacks.list[2].entity = "magnus_arcane_rain_controller"
tt.timed_attacks.list[2].cooldown = 14 + fts(25)
tt.timed_attacks.list[2].cast_time = fts(15)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].crowd_range = 55
tt.timed_attacks.list[2].max_range = 200
tt.timed_attacks.list[2].min_range = 50
tt.timed_attacks.list[2].min_targets = 3
tt.timed_attacks.list[2].node_prediction = fts(55)
tt.timed_attacks.list[2].sound = "HeroMageRainCharge"
tt.timed_attacks.list[2].vis_bans = bor(F_FRIEND, F_NIGHTMARE)
tt.timed_attacks.list[2].vis_flags = F_RANGED
tt.timed_attacks.list[2].xp_from_skill = "arcane_rain"

-- towers
tt = RT("tower_sunray", "KR5Tower")
AC(tt, "powers", "attacks")
tt.tower.level = 1
tt.tower.type = "sunray"
tt.tower.price = 0
tt.tower.can_be_mod = true
tt.tower.kind = TOWER_KIND_MAGE
tt.tower.team = TEAM_LINIREA
tt.info.portrait = "portraits_towers_0144"
tt.info.fn = kr1_scripts.tower_sunray.get_info
tt.info.i18n_key = "SPECIAL_SUNRAY"
tt.ui.click_rect = r(-55, -40, 110, 130)
tt.powers.ray = E:clone_c("power")
tt.powers.ray.level = 0
tt.powers.ray.max_level = 4
tt.powers.ray.price = { 100, 100, 100, 100 }
tt.main_script.insert = kr1_scripts.tower_sunray.insert
tt.main_script.update = kr1_scripts.tower_sunray.update
tt.render.sprites[1].name = "sunrayTower_layer1_0068"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = v(0, 0)
tt.render.sprites[1].hidden = true
tt.render.sprites[1].hover_off_hidden = true
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "sunrayTower_layer1_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(-6, 35)
for i = 3, 6 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].name = "disabled"
	tt.render.sprites[i].offset = v(-6, 35)
	tt.render.sprites[i].prefix = "tower_sunray_layer" .. i - 1
	tt.render.sprites[i].group = "tower"
end
for i = 7, 10 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].hidden = true
	tt.render.sprites[i].anchor.y = 0.11764705882352941
	tt.render.sprites[i].prefix = "tower_sunray_shooter_" .. (i % 2 == 0 and "down" or "up")
end
tt.render.sprites[7].offset = v(33, 0)
tt.render.sprites[8].offset = v(-25, 32)
tt.render.sprites[9].offset = v(-29, -1)
tt.render.sprites[10].offset = v(30, 32)
tt.sound_events.mute_on_level_insert = true
-- tt.user_selection.can_select_point_fn = kr1_scripts.tower_sunray.can_select_point
-- tt.user_selection.custom_pointer_name = "sunray_tower"
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].vis_flags = bor(F_RANGED)
tt.attacks.list[1].bullet = "ray_sunray"
tt.attacks.list[1].cooldown = 10
tt.attacks.list[1].cooldown_base = 11.25
tt.attacks.list[1].cooldown_inc = -1.25
tt.attacks.list[1].bullet_start_offset = v(0, 90)
tt.attacks.list[1].range = 2000
tt.attacks.list[1].shoot_time = fts(3)

tt = RT("ray_sunray", "bullet")
tt.bullet.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_TRUE)
tt.bullet.hit_time = fts(1)
tt.bullet.mod = "mod_ray_sunray_hit"
tt.bullet.damage_max = 75
tt.bullet.damage_min = 25
tt.bullet.damage_inc = 50
tt.image_width = 82
tt.main_script.update = kr1_scripts.ray_simple.update
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].name = "ray_sunray"
tt.render.sprites[1].loop = false
tt.sound_events.insert = "PolymorphSound"
tt.track_target = true
tt.ray_duration = fts(9)
tt.ray_y_scales = {
	0.4,
	0.6,
	0.8,
	1
}

tt = RT("tower_sorcerer", "KR5Tower")
b = balance.towers.sorcerer
AC(tt, "attacks", "powers", "barrack")
image_y = 74
tt.tower.type = "sorcerer"
tt.tower.level = 1
tt.tower.price = 300
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = v(0, 14)
tt.tower.kind = TOWER_KIND_MAGE
tt.tower.team = TEAM_LINIREA
tt.info.i18n_key = "TOWER_SORCERER"
tt.info.portrait = "portraits_towers_0142"
tt.barrack.soldier_type = "soldier_elemental"
tt.barrack.rally_range = 180
tt.powers.polymorph = CC("power")
tt.powers.polymorph.price = { 300, 65, 65 }
tt.powers.polymorph.cooldown_inc = -3
tt.powers.polymorph.cooldown_base = b.polymorph.cooldown - tt.powers.polymorph.cooldown_inc
tt.powers.polymorph.name = "POLIMORPH"
tt.powers.elemental = CC("power")
tt.powers.elemental.price = { 350, 150, 150 }
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "tower_sorcerer"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = v(0, 34)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "tower_sorcerer_shooter"
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
tt.render.sprites[3].angles.polymorph = {
	"polymorphUp",
	"polymorphDown"
}
tt.render.sprites[3].offset = v(1, 64)
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "fx_tower_sorcerer_polymorph"
tt.render.sprites[4].loop = false
tt.render.sprites[4].ts = -10
tt.render.sprites[4].offset = v(0, 80)
tt.render.sprites[4].hidden = true
tt.render.sprites[4].hide_after_runs = 1
tt.main_script.insert = kr1_scripts.tower_barrack.insert
tt.main_script.update = kr1_scripts.tower_sorcerer.update
tt.main_script.remove = kr1_scripts.tower_barrack.remove
tt.sound_events.insert = "MageSorcererTaunt"
tt.sound_events.change_rally_point = "RockElementalRally"
tt.attacks.range = 200
tt.attacks.min_cooldown = 1.5
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "bolt_sorcerer"
tt.attacks.list[1].bullet_start_offset = {
	v(8, 68),
	v(-6, 68)
}
tt.attacks.list[1].cooldown = 1.5
tt.attacks.list[1].shoot_time = fts(11)
tt.attacks.list[2] = CC("bullet_attack")
tt.attacks.list[2].bullet_start_offset = {
	v(0, 78),
	v(0, 78)
}
tt.attacks.list[2].animation = "polymorph"
tt.attacks.list[2].bullet = "ray_sorcerer_polymorph"
tt.attacks.list[2].cooldown = 20
tt.attacks.list[2].shoot_time = fts(9)
tt.attacks.list[2].vis_bans = bor(F_BOSS, F_MINIBOSS, F_NIGHTMARE, F_WATER, F_CLIFF, F_POLYMORPH)
tt.attacks.list[2].vis_flags = bor(F_MOD, F_RANGED, F_POLYMORPH)

tt = RT("ray_sorcerer_polymorph", "bullet")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_time = fts(3)
tt.bullet.mod = "mod_polymorph_sorcerer"
tt.image_width = 130
tt.main_script.update = kr1_scripts.ray_simple.update
tt.ray_duration = fts(10)
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "ray_sorcerer_polymorph"
tt.sound_events.insert = "PolymorphSound"
tt.track_target = true

tt = RT("mod_polymorph_sorcerer", "mod_polymorph")
tt.modifier.duration = 1e+99
tt.modifier.use_mod_offset = true
tt.modifier.remove_banned = true
tt.modifier.ban_types = {
	MOD_TYPE_FAST
}
tt.polymorph.custom_entity_names.default = "enemy_sheep_ground"
tt.polymorph.custom_entity_names.default_flying = "enemy_sheep_fly"
tt.polymorph.custom_entity_names.enemy_demon_imp = "enemy_sheep_fly"
tt.polymorph.custom_entity_names.enemy_gargoyle = "enemy_sheep_fly"
tt.polymorph.custom_entity_names.enemy_rocketeer = "enemy_sheep_fly"
tt.polymorph.custom_entity_names.enemy_witch = "enemy_sheep_fly"
tt.polymorph.hit_fx_sizes = {
	"fx_mod_polymorph_sorcerer_small",
	"fx_mod_polymorph_sorcerer_big",
	"fx_mod_polymorph_sorcerer_big"
}
tt.polymorph.pop = {
	"pop_puff"
}
tt.polymorph.transfer_gold_factor = 1
tt.polymorph.transfer_health_factor = 0.5
tt.polymorph.transfer_lives_cost_factor = 1
tt.polymorph.transfer_speed_factor = 1.5

tt = RT("soldier_elemental", "soldier_militia")
AC(tt, "melee", "nav_grid")
image_y = 64
anchor_y = 0.15384615384615385
tt.health.armor = 0.3
tt.health.armor_inc = 0.1
tt.health.dead_lifetime = 8
tt.health.hp_max = 500
tt.health.hp_inc = 100
tt.health_bar.offset = v(0, 55)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "SOLDIER_ELEMENTAL"
tt.info.portrait = "bottom_info_image_soldiers_0045"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
-- tt.melee.attacks[1].count = 4
tt.melee.attacks[1].damage_inc = 10
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].damage_radius = 48
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(35, 0)
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].pop = {
	"pop_whaam",
	"pop_kapow"
}
tt.melee.attacks[1].pop_chance = 0.3
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.melee.range = 75
tt.motion.max_speed = 39
tt.regen.health = 20
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"running"
}
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix = "soldier_elemental"
tt.soldier.melee_slot_offset = v(15, 0)
tt.sound_events.insert = "RockElementalDeath"
tt.sound_events.death = "RockElementalDeath"
tt.ui.click_rect = r(-25, -2, 50, 52)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.hit_offset = v(0, 15)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.vis.bans = bor(F_LYCAN)

tt = RT("aura_ranger_thorn", "aura")
tt.aura.mods = {
	"mod_thorn",
	"mod_ranger_poison"
}
tt.aura.duration = -1
tt.aura.radius = 200
tt.aura.vis_flags = bor(F_THORN, F_MOD)
tt.aura.vis_bans = bor(F_FLYING, F_BOSS, F_NIGHTMARE, F_CLIFF, F_WATER)
tt.aura.cooldown = 8 + fts(34)
-- tt.aura.max_times = 3
tt.aura.max_count = 2
tt.aura.max_count_inc = 2
tt.aura.min_count = 2
tt.aura.owner_animation = "shoot"
tt.aura.owner_sid = 3
tt.aura.hit_time = fts(17)
tt.aura.hit_sound = "ThornSound"
tt.main_script.update = kr1_scripts.aura_ranger_thorn.update

tt = RT("tower_bfg", "tower_KR5")
b = balance.towers.bfg
AC(tt, "attacks", "powers", "vis")
image_y = 120
tt.tower.type = "bfg"
tt.tower.kind = TOWER_KIND_ENGINEER
tt.tower.team = TEAM_LINIREA
tt.tower.level = 1
tt.tower.price = 360
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = v(0, 14)
tt.info.i18n_key = "TOWER_BFG"
tt.info.portrait = "portraits_towers_0140"
tt.powers.missile = CC("power")
tt.powers.missile.price = { 250, 100, 100 }
tt.powers.missile.range_inc_factor = 0.2
tt.powers.missile.damage_inc = 40
tt.powers.cluster = CC("power")
tt.powers.cluster.price = { 225, 150, 150 }
tt.powers.cluster.fragment_count_base = 1
tt.powers.cluster.fragment_count_inc = 2
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "tower_bfg"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = v(0, 51)
tt.main_script.update = kr1_scripts.tower_bfg.update
tt.sound_events.insert = "EngineerBfgTaunt"
tt.attacks.min_cooldown = 1
tt.attacks.range = 180
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "bomb_bfg"
tt.attacks.list[1].bullet_start_offset = v(0, 64)
tt.attacks.list[1].cooldown = 3.65
tt.attacks.list[1].node_prediction = fts(37)
tt.attacks.list[1].range = 180
tt.attacks.list[1].shoot_time = fts(23)
tt.attacks.list[1].vis_bans = bor(F_FLYING, F_NIGHTMARE)
tt.attacks.list[2] = CC("bullet_attack")
tt.attacks.list[2].animation = "missile"
tt.attacks.list[2].bullet = "missile_bfg"
tt.attacks.list[2].bullet_start_offset = v(-24, 64)
tt.attacks.list[2].cooldown = b.missile.cooldown
tt.attacks.list[2].cooldown_mixed = 14.1
tt.attacks.list[2].cooldown_flying = 6.5
tt.attacks.list[2].launch_vector = v(12, 110)
tt.attacks.list[2].range_base = 180
tt.attacks.list[2].range = nil
tt.attacks.list[2].shoot_time = fts(14)
tt.attacks.list[2].vis_flags = bor(F_MOD, F_RANGED)
tt.attacks.list[2].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[3] = table.deepclone(tt.attacks.list[1])
tt.attacks.list[3].bullet = "bomb_bfg_cluster"
tt.attacks.list[3].cooldown = b.cluster.cooldown
tt.attacks.list[3].node_prediction = fts(44)
tt.attacks.list[3].vis_bans = bor(F_NIGHTMARE)

tt = RT("missile_bfg", "bullet")
tt.render.sprites[1].prefix = "missile_bfg"
tt.render.sprites[1].loop = true
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.min_speed = 300
tt.bullet.max_speed = 450
tt.bullet.turn_speed = 10 * math.pi / 180 * 30
tt.bullet.acceleration_factor = 0.1
tt.bullet.hit_fx = "fx_explosion_air"
tt.bullet.hit_fx_air = "fx_explosion_air"
tt.bullet.damage_min = 60
tt.bullet.damage_max = 100
tt.bullet.damage_radius = 41.25
tt.bullet.vis_flags = F_RANGED
tt.bullet.damage_flags = F_AREA
tt.bullet.particles_name = "ps_missile"
tt.bullet.retarget_range = 1e+99
tt.main_script.insert = kr1_scripts.missile.insert
tt.main_script.update = kr1_scripts.missile.update
tt.sound_events.insert = "RocketLaunchSound"
tt.sound_events.hit = "BombExplosionSound"

tt = RT("bomb_bfg_cluster", "bullet")
AC(tt, "sound_events")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(29)
tt.bullet.fragment_count = 1
tt.bullet.fragment_name = "bomb_bfg_fragment"
tt.bullet.hide_radius = 2
tt.bullet.hit_fx = "fx_explosion_air"
tt.bullet.rotation_speed = 20 * FPS * math.pi / 180
tt.bullet.fragment_node_spread = 7
tt.bullet.fragment_pos_spread = v(6, 6)
tt.bullet.dest_pos_offset = v(0, 85)
tt.bullet.dest_prediction_time = 1
tt.main_script.insert = kr1_scripts.bomb_cluster.insert
tt.main_script.update = kr1_scripts.bomb_cluster.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "bombs_0005"
tt.sound_events.hit = "BombExplosionSound"
tt.sound_events.insert = "BombShootSound"

tt = RT("bomb_bfg_fragment", "bombKR5")
tt.bullet.damage_max = 80
tt.bullet.damage_min = 60
tt.bullet.damage_radius = 52.5
tt.bullet.flight_time = fts(10)
tt.bullet.hide_radius = 2
tt.bullet.hit_fx = "fx_explosion_fragment"
tt.bullet.pop = nil
tt.render.sprites[1].name = "bombs_0006"
tt.sound_events.hit_water = nil

tt = RT("tower_elf_holder")
AC(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "editor", "editor_script")
tt.tower.type = "holder_elf"
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.tower.can_be_sold = false
tt.info.i18n_key = "TOWER_ELF_HOLDER"
tt.info.fn = scripts.tower_barrack_mercenaries.get_info
tt.info.portrait = "portraits_towers_0108"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 12)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "elfTower_layer1_0026"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(0, 30)
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
tt.editor_script.insert = kr1_scripts.editor_tower.insert
tt.editor_script.remove = kr1_scripts.editor_tower.remove

tt = RT("tower_special_elf", "tower_KR5")
AC(tt, "barrack", "vis")
tt.info.portrait = "portraits_towers_0108"
tt.barrack.max_soldiers = 0
tt.barrack.rally_range = 145
tt.barrack.respawn_offset = v(0, 0)
tt.barrack.soldier_type = "kr4_elven_warrior"
tt.editor.props = table.append(tt.editor.props, {
	{
		"barrack.rally_pos",
		PT_COORDS
	}
}, true)
tt.info.i18n_key = "SPECIAL_ELF"
tt.info.fn = scripts.tower_barrack_mercenaries.get_info
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.remove = scripts.tower_barrack.remove
tt.main_script.update = customScripts1.tower_special_mercenaries.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 12)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "elfTower_layer1_0001"
tt.render.sprites[2].offset = v(0, 30)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "close"
tt.render.sprites[3].offset = v(0, 30)
tt.render.sprites[3].prefix = "tower_elf_door"
tt.render.door_sid = 3
tt.sound_events.change_rally_point = "ElfTaunt"
tt.sound_events.insert = "GUITowerBuilding"
tt.sound_events.mute_on_level_insert = true
tt.tower.can_be_mod = true
tt.tower.level = 1
tt.tower.price = 100
tt.tower.type = "special_elf"
tt.tower.kind = TOWER_KIND_BARRACK
tt.tower.team = TEAM_LINIREA
tt.tower.menu_offset = v(0, 22)
tt.ui.click_rect = r(-40, -10, 80, 90)

tt = RT("kr4_elven_warrior", "soldier_militia")

E:add_comps(tt, "powers", "dodge", "ranged", "revive", "nav_grid")

anchor_y = 0.267
tt.health.hp_max = 100
tt.health.armor = 0.3
tt.health.dead_lifetime = 13
tt.health.on_damage = customScripts1.kr4_elven_warrior.on_damage
tt.health_bar.offset = v(0, 33)
tt.motion.max_speed = 63
tt.revive.disabled = nil
tt.revive.chance = 0.2
tt.revive.health_recover = 1
tt.revive.animation = "raise"
tt.info.portrait = "bottom_info_image_soldiers_0012"
tt.info.random_name_count = 10
tt.info.random_name_format = "SOLDIER_ELVES_RANDOM_%i_NAME"
tt.powers.counter = E:clone_c("power")
tt.powers.counter.level = 1
tt.dodge.chance = 0.4
tt.dodge.animation = "hit2"
tt.dodge.ranged = true
tt.dodge.counter_attack = E:clone_c("melee_attack")
tt.dodge.counter_attack.animation = "hit2"
tt.dodge.counter_attack.cooldown = 1
tt.dodge.counter_attack.damage_max = 38
tt.dodge.counter_attack.damage_min = 26
tt.dodge.counter_attack.hit_time = fts(15)
tt.dodge.counter_attack.power_name = "counter"
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 25
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].track_damage = true
tt.melee.attacks[1].animation = "hit1"
tt.melee.range = 50
tt.soldier.melee_slot_offset = v(8, 0)
tt.ranged.go_back_during_cooldown = true
tt.ranged.attacks[1].bullet = "kr4_elven_warrior_arrow"
tt.ranged.attacks[1].bullet_start_offset = {
	v(4, 21)
}
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].max_range = 205
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].sprite_group = "shoot"
tt.ranged.attacks[1].loops = 1
tt.ranged.attacks[1].shoot_times = {
	fts(4),
	fts(9),
	fts(16)
}
tt.ranged.attacks[1].animations = {
	"shootPrep",
	"multiShoot",
	"shootEnd"
}
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.regen.cooldown = 1
tt.regen.health = 20
tt.render.sprites[1].prefix = "kr4_elven_warrior"
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.render.sprites[1].group = "shoot"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "kr4_elven_warrior_shadow"
tt.render.sprites[2].anchor.y = anchor_y
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.insert = "ElfTaunt"
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(0, 11)
tt.unit.head_offset = v(0, 28)
tt.unit.marker_offset = v(0, 0)
tt.unit.price = {
	100,
	125,
	150,
	175
}
tt.main_script.update = customScripts1.kr4_soldier_barrack.update

tt = RT("kr4_elven_warrior_arrow", "arrow5_45degrees")
tt.render.sprites[1].name = "kr4_elven_warrior_arrow"
tt.bullet.miss_decal = "kr4_elven_warrior_arrow_decal_0009"
tt.bullet.miss_decal_anchor = v(1, 0.5)
tt.bullet.damage_min = 12
tt.bullet.damage_max = 22
tt.bullet.flight_time = fts(10)
tt.bullet.g = -0.7 / (fts(1) * fts(1))
tt.bullet.reset_to_target_pos = true
tt.bullet.use_unit_damage_factor = true

tt = RT("tower_tesla", "tower_KR5")
AC(tt, "attacks", "powers", "vis")
image_y = 96
tt.tower.type = "tesla"
tt.tower.kind = TOWER_KIND_ENGINEER
tt.tower.team = TEAM_LINIREA
tt.tower.level = 1
tt.tower.price = 375
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = v(0, 25)
tt.info.fn = kr1_scripts.tower_tesla.get_info
tt.info.i18n_key = "TOWER_TESLA"
tt.info.portrait = "portraits_towers_0105"
tt.powers.bolt = CC("power")
tt.powers.bolt.price = { 100, 100 }
tt.powers.bolt.max_level = 2
tt.powers.bolt.name = "CHARGED_BOLT"
tt.powers.overcharge = CC("power")
tt.powers.overcharge.price = { 190, 125, 125 }
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "tower_tesla"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = v(0, 40)
tt.main_script.update = kr1_scripts.tower_tesla.update
tt.sound_events.insert = "EngineerTeslaTaunt"
tt.attacks.min_cooldown = 2.2
tt.attacks.range = 165
tt.attacks.range_check_factor = 1.2
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "ray_tesla"
tt.attacks.list[1].bullet_start_offset = v(7, 79)
tt.attacks.list[1].cooldown = 2.2
tt.attacks.list[1].node_prediction = fts(18)
tt.attacks.list[1].range = 165
tt.attacks.list[1].shoot_time = fts(48)
tt.attacks.list[1].sound_shoot = "TeslaAttack"
tt.attacks.list[2] = CC("aura_attack")
tt.attacks.list[2].aura = "aura_tesla_overcharge"
tt.attacks.list[2].bullet_start_offset = v(0, 15)

tt = RT("aura_tesla_overcharge", "aura")
tt.aura.duration = fts(22)
tt.aura.mod = "mod_tesla_overcharge"
tt.aura.radius = 165
tt.aura.damage_min = 0
tt.aura.damage_max = 10
tt.aura.damage_inc = 10
tt.aura.damage_type = DAMAGE_ELECTRICAL
tt.aura.excluded_templates = {}
tt.main_script.update = kr1_scripts.aura_tesla_overcharge.update
tt.particles_name = "ps_tesla_overcharge"

tt = RT("ray_tesla", "bullet")
tt.bullet.hit_time = fts(1)
tt.bullet.mod = "mod_ray_tesla"
tt.bounces = nil
tt.bounces_lvl = {
	[0] = 2,
	3,
	4
}
tt.bounce_range = 95
tt.bounce_vis_flags = F_RANGED
tt.bounce_vis_bans = bor(F_NIGHTMARE)
tt.bounce_damage_min = 60
tt.bounce_damage_max = 110
tt.bounce_damage_factor = 1
tt.bounce_damage_factor_min = 1
tt.bounce_damage_factor_inc = 0
tt.bounce_delay = fts(2)
tt.bounce_scale_y = 1
tt.bounce_scale_y_factor = 0.88
tt.excluded_templates = {}
tt.image_width = 112
tt.seen_targets = {}
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].name = "ray_tesla"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BULLETS
tt.main_script.update = kr1_scripts.ray_tesla.update

tt = RT("mod_tesla_overcharge", "modifier")

AC(tt, "render")

tt.modifier.duration = fts(20)
tt.modifier.vis_flags = F_MOD
tt.render.sprites[1].prefix = "mod_tesla_hit"
tt.render.sprites[1].size_names = {
	"small",
	"medium",
	"large"
}
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update

tt = RT("ps_tesla_overcharge", "particle_system")
tt.particle_system.name = "decal_tesla_overcharge"
tt.particle_system.animated = true
tt.particle_system.particle_lifetime = {
	0.9,
	1.3
}
tt.particle_system.alphas = {
	0,
	255,
	255,
	0
}
tt.particle_system.scales_x = {
	1,
	0.45
}
tt.particle_system.scales_y = {
	1,
	0.45
}
tt.particle_system.scale_same_aspect = true
tt.particle_system.scale_var = {
	0.5,
	1.5
}
tt.particle_system.emit_spread = 2 * math.pi
tt.particle_system.emit_duration = fts(7)
tt.particle_system.emit_rotation = 0
tt.particle_system.emit_speed = {
	120,
	120
}
tt.particle_system.emission_rate = 90
tt.particle_system.source_lifetime = 2
tt.particle_system.z = Z_OBJECTS

tt = RT("tower_paladin", "tower_paladin_covenant_lvl1")
AC(tt, "powers")
tt.info.portrait = "portraits_towers_0117"
tt.info.i18n_key = "TOWER_PALADINS"
tt.tower.type = "paladin"
tt.tower.price = 230
tt.powers.healing = E:clone_c("power")
tt.powers.healing.price = { 150, 150, 150 }
tt.powers.shield = E:clone_c("power")
tt.powers.shield.price = { 250 }
tt.powers.shield.max_level = 1
tt.powers.holystrike = E:clone_c("power")
tt.powers.holystrike.price = { 200, 150, 150 }
tt.powers.holystrike.name = "HOLY_STRIKE"
tt.barrack.soldier_type = "soldier_paladin"
tt.barrack.rally_range = 145
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2].name = "tower_barracks_lvl4_Paladins_layer1_0001"
tt.render.sprites[2].offset = v(0, 42)
tt.render.sprites[3].prefix = "towerbarracklvl4_paladin_door"
tt.render.sprites[3].offset = v(0, 42)
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "tower_paladin_flag"
tt.render.sprites[4].offset = v(7, 77)
tt.sound_events.insert = "BarrackPaladinTaunt"
tt.sound_events.change_rally_point = "BarrackPaladinTaunt"
tt.ui.click_rect = r(-42, 0, 84, 90)

tt = RT("soldier_paladin", "soldier_militia")
E:add_comps(tt, "powers", "timed_actions", "nav_grid")
tt.health.armor = 0.5
tt.health.dead_lifetime = 14
tt.health.hp_max = 200
tt.health.armor_power_name = "shield"
tt.health.armor_inc = 0.25
tt.health_bar.offset = v(0, 33)
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.info.portrait = "bottom_info_image_soldiers_0027"
tt.info.random_name_count = 20
tt.info.random_name_format = "SOLDIER_PALADIN_RANDOM_%i_NAME"
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].hit_time = fts(11)
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = E:clone_c("area_attack")
tt.melee.attacks[3].animation = "holystrike"
tt.melee.attacks[3].chance = 0.1
tt.melee.attacks[3].damage_max = 0
tt.melee.attacks[3].damage_min = 0
tt.melee.attacks[3].damage_max_inc = 45
tt.melee.attacks[3].damage_min_inc = 25
tt.melee.attacks[3].damage_radius = 50
tt.melee.attacks[3].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_decal = "decal_paladin_holystrike"
tt.melee.attacks[3].hit_offset = v(26, 0)
tt.melee.attacks[3].hit_time = fts(13)
tt.melee.attacks[3].level = 0
tt.melee.attacks[3].pop = nil
tt.melee.attacks[3].power_name = "holystrike"
tt.melee.attacks[3].shared_cooldown = true
tt.melee.attacks[3].signal = "holystrike"
tt.melee.attacks[3].vis_bans = bor(F_FLYING)
tt.melee.attacks[3].vis_flags = bor(F_BLOCK)
tt.melee.cooldown = 1 + fts(13)
tt.melee.range = 60
tt.motion.max_speed = 60
tt.powers.healing = E:clone_c("power")
tt.powers.shield = E:clone_c("power")
tt.powers.holystrike = E:clone_c("power")
tt.regen.health = 25
tt.render.sprites[1].prefix = "soldier_paladin"
tt.render.sprites[1].anchor.y = 0.211
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "paladin_shadow"
tt.render.sprites[2].anchor.y = 0.211
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(9, 0)
tt.timed_actions.list[1] = CC("mod_attack")
tt.timed_actions.list[1].animation = "healing"
tt.timed_actions.list[1].cast_time = fts(13)
tt.timed_actions.list[1].cooldown = 10
tt.timed_actions.list[1].disabled = true
tt.timed_actions.list[1].fn_can = function(t, s, a)
	return t.health.hp < a.min_health_factor * t.health.hp_max
end
tt.timed_actions.list[1].level = 0
tt.timed_actions.list[1].min_health_factor = 0.45
tt.timed_actions.list[1].mod = "mod_healing_paladin"
tt.timed_actions.list[1].power_name = "healing"
tt.timed_actions.list[1].sound = "HealingSound"
tt.main_script.update = customScripts1.kr4_soldier_barrack.update

tt = RT("decal_paladin_holystrike", "decal_timed")
tt.render.sprites[1].name = "paladin_ground_attack_decal"
tt.render.sprites[1].z = Z_DECALS

tt = RT("mod_healing_paladin", "modifier")
E:add_comps(tt, "hps", "render")
tt.hps.heal_every = 1e+99
tt.hps.heal_min = 0
tt.hps.heal_max = 0
tt.hps.heal_min_inc = 40
tt.hps.heal_max_inc = 60
function tt.main_script.insert(this, store, script)
    local target = store.entities[this.modifier.target_id]
	if not target or not target.health or target.health.dead then
		return false
	end
    if target.health.hp >= target.health.hp_max then
		return false
	end
    local decal = E:create_entity("paladin_modifier_decal")
    decal.pos = target.pos
    decal.render.sprites[1].ts = store.tick_ts
	simulation:queue_insert_entity(decal)
	return scripts.mod_hps.insert(this, store, script)
end
tt.main_script.update = scripts.mod_hps.update
tt.modifier.duration = fts(20)
tt.render.sprites[1].name = "paladin_modifier_effect"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].loop = true
tt.render.sprites[1].draw_order = DO_MOD_FX

tt = E:register_t("paladin_modifier_decal", "decal_timed")
tt.render.sprites[1].name = "paladin_modifier_decal"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS

tt = RT("tower_wildling", "tower_paladin_covenant_lvl1")
tt.info.portrait = "portraits_towers_0101"
tt.info.i18n_key = "TOWER_WILDLING"
tt.tower.type = "wildling"
tt.tower.level = 1
tt.tower.price = 160
tt.tower.menu_offset = v(0, 22)
tt.barrack.soldier_type = "northern_wildling"
tt.barrack.rally_range = 145
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2].name = "ogre_shipwreck_tower_lvl1_layer1_0002"
tt.render.sprites[2].offset = v(0, 43)
tt.render.sprites[3].prefix = "ogre_shipwreck_tower_lvl1"
tt.render.sprites[3].offset = v(0, 43)
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "ogre_shipwreck_tower_lvl1_layer3_0002"
tt.render.sprites[4].animated = false
tt.render.sprites[4].offset = v(0, 43)
tt.sound_events.insert = "TowerBarrelSkillATaunt"
tt.sound_events.change_rally_point = "TowerBarrelTaunt"
tt.ui.click_rect = r(-40, 0, 80, 80)

tt = RT("northern_wildling", "soldier_militia")
E:add_comps(tt, "nav_grid")

tt.health.armor = 0.2
tt.health.dead_lifetime = 10
tt.health.hp_max = 125
tt.health_bar.offset = v(0, 37)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.unit.hit_offset = v(0, 12)
tt.unit.head_offset = v(0, 28)
tt.unit.mod_offset = v(0, 13)
tt.unit.marker_offset = v(0, 0)
tt.info.portrait = "bottom_info_image_soldiers_0024"
tt.info.random_name_count = 20
tt.info.random_name_format = "SOLDIER_BARBARIAN_RANDOM_%i_NAME"
tt.motion.max_speed = 66
tt.regen.health = 10
tt.render.sprites[1].prefix = "northern_wildling"
tt.render.sprites[1].anchor.y = 0.16
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "northern_wildling_shadow"
tt.render.sprites[2].anchor.y = 0.16
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(10, 0)
tt.melee.range = 60
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(10)
tt.main_script.update = customScripts1.kr4_soldier_barrack.update

tt = RT("tower_barbarian", "tower_paladin_covenant_lvl1")
E:add_comps(tt, "powers")

tt.info.portrait = "portraits_towers_0101"
tt.info.i18n_key = "TOWER_BARBARIANS"
tt.tower.type = "barbarian"
tt.tower.level = 1
tt.tower.price = 230
tt.tower.menu_offset = v(0, 25)
tt.powers.dual = E:clone_c("power")
tt.powers.dual.price = { 100, 100, 100 }
tt.powers.dual.name = "DOUBLE_AXE"
tt.powers.twister = E:clone_c("power")
tt.powers.twister.price = { 150, 100, 100 }
tt.powers.throwing = E:clone_c("power")
tt.powers.throwing.price = { 200, 100, 100 }
tt.powers.throwing.name = "THROWING_AXES"
tt.barrack.soldier_type = "soldier_barbarian"
tt.barrack.rally_range = 145
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2].name = "tower_barrack_lvl4_Barbarians_layer1_0001"
tt.render.sprites[2].offset = v(0, 45)
tt.render.sprites[3].prefix = "towerbarracklvl4_barbarian_door"
tt.render.sprites[3].offset = v(0, 45)
tt.sound_events.insert = "BarrackBarbarianTaunt"
tt.sound_events.change_rally_point = "BarrackBarbarianTaunt"
tt.ui.click_rect = r(-42, 0, 84, 90)

tt = RT("soldier_barbarian", "soldier_militia")
E:add_comps(tt, "powers", "ranged", "nav_grid")
tt.health.armor = 0.1
tt.health.dead_lifetime = 8
tt.health.hp_max = 250
tt.health_bar.offset = v(0, 42)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 13)
tt.info.portrait = "bottom_info_image_soldiers_0004"
tt.info.random_name_count = 20
tt.info.random_name_format = "SOLDIER_BARBARIAN_RANDOM_%i_NAME"
tt.motion.max_speed = 75
tt.powers.dual = E:clone_c("power")
tt.powers.twister = E:clone_c("power")
tt.powers.throwing = E:clone_c("power")
tt.regen.health = 20
tt.render.sprites[1].prefix = "soldier_barbarian"
tt.render.sprites[1].anchor.y = 0.211111
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "northern_berserker_shadow"
tt.render.sprites[2].anchor.y = 0.211111
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(10, 0)
tt.melee.cooldown = 1 + fts(11)
tt.melee.range = 60
tt.melee.attacks[1].damage_inc = 10
tt.melee.attacks[1].damage_max = 24
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].power_name = "dual"
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = E:clone_c("area_attack")
tt.melee.attacks[2].animation = "twister"
tt.melee.attacks[2].chance = 0.1
tt.melee.attacks[2].chance_inc = 0.1
tt.melee.attacks[2].damage_inc = 15
tt.melee.attacks[2].damage_max = 30
tt.melee.attacks[2].damage_min = 10
tt.melee.attacks[2].damage_radius = 50
tt.melee.attacks[2].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[2].sound = "whirlwindattack"
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(7)
tt.melee.attacks[2].level = 0
tt.melee.attacks[2].pop = nil
tt.melee.attacks[2].power_name = "twister"
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].vis_bans = bor(F_FLYING)
tt.melee.attacks[2].vis_flags = bor(F_BLOCK)
tt.ranged.go_back_during_cooldown = true
tt.ranged.range_while_blocking = true
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].bullet = "axe_barbarian"
tt.ranged.attacks[1].bullet_start_offset = {
	v(-5, 18)
}
tt.ranged.attacks[1].cooldown = 3 + fts(14)
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].level = 0
tt.ranged.attacks[1].max_range = 155
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].power_name = "throwing"
tt.ranged.attacks[1].range_inc = 13
tt.ranged.attacks[1].shoot_time = fts(7)
tt.main_script.update = customScripts1.kr4_soldier_barrack.update

tt = RT("axe_barbarian", "arrow")
tt.bullet.damage_min = 24
tt.bullet.damage_max = 32
tt.bullet.damage_inc = 10
tt.bullet.flight_time = fts(23)
tt.bullet.rotation_speed = 30 * FPS * math.pi / 180
tt.bullet.miss_decal = "decal_axe"
tt.bullet.miss_decal_anchor = v(0.5, 0.08889)
tt.bullet.reset_to_target_pos = true
tt.render.sprites[1].name = "barbarian_axe_0001"
tt.render.sprites[1].animated = false
tt.bullet.pop = nil
tt.sound_events.insert = "AxeSound"

tt = RT("ps_shotgun_musketeer", "particle_system")
tt.particle_system.animated = true
tt.particle_system.emission_rate = 20
tt.particle_system.loop = false
tt.particle_system.name = "ps_shotgun_musketeer"
tt.particle_system.particle_lifetime = {
	fts(13),
	fts(13)
}
tt.particle_system.track_rotation = true

tt = RT("fx_explosion_shrapnel", "fx")
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].prefix = "explosion"
tt.render.sprites[1].name = "shrapnel"

tt = RT("bomb_musketeer", "bombKR5")
tt.bullet.damage_max = 0
tt.bullet.damage_max_inc = 40
tt.bullet.damage_min = 0
tt.bullet.damage_min_inc = 10
tt.bullet.damage_radius = 48
tt.bullet.flight_time_min = fts(4)
tt.bullet.flight_time_max = fts(8)
tt.bullet.hit_fx = "fx_explosion_shrapnel"
tt.bullet.pop = nil
tt.render.sprites[1].name = "bombs_0007"
tt.sound_events.insert = "ShrapnelSound"
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil

tt = RT("shotgun_musketeer", "shotgun")
tt.bullet.damage_max = 65
tt.bullet.damage_min = 35
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.miss_fx = "fx_smoke_bullet"
tt.bullet.start_fx = "fx_rifle_smoke"
tt.bullet.min_speed = 20 * FPS
tt.bullet.max_speed = 20 * FPS
tt.sound_events.insert = "ShotgunSound"

tt = RT("shotgun_musketeer_sniper", "shotgun_musketeer")
tt.bullet.particles_name = "ps_shotgun_musketeer"
tt.sound_events.insert = "SniperSound"
tt.bullet.damage_type = bor(DAMAGE_EXPLOSION, DAMAGE_FX_EXPLODE)
tt.bullet.pop = nil
tt.bullet.ignore_upgrades = true

tt = RT("shotgun_musketeer_sniper_instakill", "shotgun_musketeer_sniper")
tt.bullet.damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_FX_EXPLODE)
tt.bullet.pop = {
	"pop_headshot"
}

tt = RT("tower_musketeer", "tower_archer_1")
b = balance.towers.musketeer
AC(tt, "attacks", "powers")
tt.tower.type = "musketeer"
tt.tower.level = 1
tt.tower.price = 230
tt.tower.size = TOWER_SIZE_LARGE
tt.info.i18n_key = "TOWER_MUSKETEERS"
tt.info.portrait = "portraits_towers_0122"
tt.powers.sniper = CC("power")
tt.powers.sniper.attack_idx = 2
tt.powers.sniper.price = { 250, 250, 250 }
tt.powers.sniper.damage_factor_inc = 0.2
tt.powers.sniper.instakill_chance_inc = 0.2
tt.powers.shrapnel = CC("power")
tt.powers.shrapnel.attack_idx = 3
tt.powers.shrapnel.price = { 300, 300, 300 }
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 14)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "archer_tower_0004"
tt.render.sprites[2].offset = v(0, 37)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "tower_musketeer_shooter"
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
tt.render.sprites[3].angles.sniper_shoot = {
	"sniperShootUp",
	"sniperShootDown"
}
tt.render.sprites[3].angles.sniper_seek = {
	"sniperSeekUp",
	"sniperSeekDown"
}
tt.render.sprites[3].angles.cannon_shoot = {
	"cannonShootUp",
	"cannonShootDown"
}
tt.render.sprites[3].angles.cannon_fuse = {
	"cannonFuseUp",
	"cannonFuseDown"
}
tt.render.sprites[3].offset = v(-8, 56)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[4].offset.x = 8
tt.main_script.update = kr1_scripts.tower_musketeer.update
tt.sound_events.insert = "ArcherMusketeerTaunt"
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

-- kr1 enemies
package.loaded.kr1_enemies_templates = nil
require("kr1_enemies_templates")

-- unmodified
tt = RT("ps_bolt_sorcerer", "particle_system")
tt.particle_system.alphas = {
	255,
	0
}
tt.particle_system.animated = false
tt.particle_system.emit_area_spread = v(6, 6)
tt.particle_system.emission_rate = 60
tt.particle_system.name = "sorcererbolt_particle"
tt.particle_system.particle_lifetime = {
	fts(2),
	fts(5)
}
tt.particle_system.rotation_spread = math.pi
tt.particle_system.scale_var = {
	0.8,
	0.6
}
tt.particle_system.scales_x = {
	1,
	0.3
}
tt.particle_system.scales_y = {
	1,
	0.3
}
tt = E:register_t("ps_flare_flareon", "particle_system")
tt.particle_system.alphas = {
	255,
	0
}
tt.particle_system.animated = false
tt.particle_system.emission_rate = 40
tt.particle_system.emit_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "Stage9_lavaShotParticle"
tt.particle_system.particle_lifetime = {
	0.35,
	0.7
}
tt.particle_system.scale_same_aspect = true
tt.particle_system.scale_var = {
	0.6,
	0.8
}
tt.particle_system.scales_x = {
	0.8,
	1.6
}
tt.particle_system.scales_y = {
	0.8,
	1.6
}
tt.particle_system.emit_rotation_spread = math.pi
tt = RT("ps_veznan_soul", "particle_system")
tt.particle_system.alphas = {
	255,
	0
}
tt.particle_system.animated = false
tt.particle_system.emission_rate = 60
tt.particle_system.emission_spread = v(6, 6)
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.emit_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "boss_veznan_soul_particle"
tt.particle_system.particle_lifetime = {
	fts(4),
	fts(8)
}
tt.particle_system.scale_same_aspect = true
tt.particle_system.scale_var = {
	0.8,
	1.2
}
tt.particle_system.scales_x = {
	1,
	0.3
}
tt.particle_system.scales_y = {
	1,
	0.3
}
tt = RT("ps_hacksaw_sawblade")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {
	255,
	200,
	0,
	0
}
tt.particle_system.animated = true
tt.particle_system.emission_rate = 120
tt.particle_system.emit_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "ps_hacksaw_sawblade"
tt.particle_system.particle_lifetime = {
	fts(12),
	fts(12)
}
tt.particle_system.scales_x = {
	1,
	0.5
}
tt.particle_system.scales_y = {
	1.5,
	0.5
}
tt = RT("ps_stage_snow")

AC(tt, "pos", "particle_system")

tt.pos = v(512, 768)
tt.particle_system.alphas = {
	255,
	255,
	255,
	0
}
tt.particle_system.emission_rate = 8
tt.particle_system.emit_area_spread = v(1200, 10)
tt.particle_system.emit_direction = 3 * math.pi / 2
tt.particle_system.emit_speed = {
	30,
	40
}
tt.particle_system.emit_spread = math.pi / 8
tt.particle_system.particle_lifetime = {
	20,
	30
}
tt.particle_system.scale_var = {
	0.4,
	0.7
}
tt.particle_system.ts_offset = -20
tt.particle_system.z = Z_OBJECTS_SKY
tt.particle_system.name = "Copo"
tt = RT("fx_teleport_arcane", "fx")
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].prefix = "fx_teleport_arcane"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt = RT("fx_bolt_sorcerer_hit", "fx")
tt.render.sprites[1].prefix = "bolt_sorcerer"
tt.render.sprites[1].name = "hit"
tt = RT("fx_mod_polymorph_sorcerer_small", "fx")
tt.render.sprites[1].name = "fx_mod_polymorph_sorcerer_small"
tt.render.sprites[1].anchor.y = 0.5
tt = RT("fx_mod_polymorph_sorcerer_big", "fx_mod_polymorph_sorcerer_small")
tt.render.sprites[1].name = "fx_mod_polymorph_sorcerer_big"
tt = RT("fx_hacksaw_sawblade_hit", "fx")
tt.render.sprites[1].prefix = "fx_hacksaw_sawblade"
tt.render.sprites[1].name = "hit"
tt = RT("fx_hero_thor_thunderclap_disipate", "fx")
tt.render.sprites[1].name = "fx_hero_thor_thunderclap_disipate"
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[1].z = Z_EFFECTS
tt = RT("fx_juggernaut_smoke", "fx")
tt.render.sprites[1].name = "fx_juggernaut_smoke"
tt.render.sprites[1].anchor.y = 0.27
tt = RT("fx_jt_tower_click", "fx")
tt.render.sprites[1].name = "fx_jt_tower_click"
tt.render.sprites[1].anchor.y = 0.3
tt = RT("fx_moloch_ring", "fx")
tt.render.sprites[1].name = "fx_moloch_ring"
tt.render.sprites[1].z = Z_DECALS
tt = RT("fx_moloch_rocks", "fx")
tt.render.sprites[1].name = "fx_moloch_rocks"
tt.render.sprites[1].anchor.y = 0.24242424242424243
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_myconid_spores", "fx")
tt.render.sprites[1].name = "fx_myconid_spores"
tt.render.sprites[1].anchor.y = 0.8
tt = RT("fx_blackburn_smash", "fx")
tt.render.sprites[1].name = "fx_blackburn_smash"
tt.render.sprites[1].anchor.y = 0.1588785046728972
tt = RT("fx_veznan_demon_fire", "fx")
tt.render.sprites[1].name = "fx_veznan_demon_fire"
tt = E:register_t("fx_explosion_rotten_shot", "fx")
tt.render.sprites[1].name = "explosion_rotten_shot"
tt.render.sprites[1].anchor = v(0.5, 0.33783783783783783)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -2
tt = E:register_t("fx_explosion_flareon_flare", "fx")
tt.render.sprites[1].name = "explosion_flare_flareon"
tt.render.sprites[1].anchor = v(0.5, 0.25)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -2
tt = RT("kr1_fx_bolt_necromancer_hit", "fx")
tt.render.sprites[1].prefix = "bolt_necromancer"
tt.render.sprites[1].name = "hit"
tt = RT("fx_demon_portal_out", "fx")
tt.render.sprites[1].prefix = "fx_demon_portal_out"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {
	"small",
	"big"
}
tt = RT("fx_bolt_witch_hit", "fx")
tt.render.sprites[1].name = "fx_bolt_witch_hit"
tt = E:register_t("fx_hobgoblin_ground_hit", "fx")
tt.render.sprites[1].name = "fx_hobgoblin_ground_hit"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].draw_order = 2
tt = RT("decal_malik_ring", "decal_timed")
tt.render.sprites[1].name = "decal_malik_ring"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_malik_earthquake", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_malik_earthquake"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].anchor.y = 0.24

tt = RT("denas_cursing", "decal_scripted")
tt.render.sprites[1].name = "hero_denas_cursing"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS
tt.duration = fts(36)
tt.offset = v(0, 25)
tt.main_script.update = kr1_scripts.denas_cursing.update

tt = RT("denas_buffing_circle", "decal_timed")

AC(tt, "tween")

tt.render.sprites[1].name = "hero_king_glow"
tt.render.sprites[1].anchor = v(0.5, 0.26)
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {
	{
		0,
		25.5
	},
	{
		0.33,
		255
	},
	{
		1,
		0
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		v(0.7, 0.7)
	},
	{
		1,
		v(1.8, 1.8)
	}
}
tt.tween.remove = true
tt = RT("decal_ingvar_attack", "decal_tween")
tt.render.sprites[1].name = "hero_viking_axeDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {
	{
		0,
		200
	},
	{
		1,
		200
	},
	{
		1.5,
		0
	}
}
tt = RT("decal_jt_ground_hit", "decal_timed")
tt.render.sprites[1].name = "decal_jt_ground_hit"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_jt_tap", "decal_loop")
tt.render.sprites[1].random_ts = fts(7)
tt.render.sprites[1].name = "decal_jt_tap"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y = -40
tt.render.sprites[1].offset = v(20, 40)
tt = RT("decal_blackburn_smash_ground", "decal_timed")
tt.render.sprites[1].name = "fx_blackburn_smash_ground"
tt.render.sprites[1].z = Z_DECALS
tt = RT("veznan_portal", "decal_scripted")

AC(tt, "editor")

tt.render.sprites[1].prefix = "veznan_portal"
tt.render.sprites[1].z = Z_DECALS
tt.fx_out = "fx_demon_portal_out"
tt.main_script.update = kr1_scripts.veznan_portal.update
tt.out_nodes = nil
tt.spawn_groups = {
	{
		{
			0.5,
			{
				{
					4,
					7,
					"enemy_demon"
				}
			}
		},
		{
			0.8,
			{
				{
					3,
					3,
					"enemy_demon_wolf"
				}
			}
		},
		{
			1,
			{
				{
					5,
					5,
					"enemy_demon"
				},
				{
					1,
					1,
					"enemy_demon_mage"
				}
			}
		}
	},
	{
		{
			0.5,
			{
				{
					2,
					5,
					"enemy_demon"
				}
			}
		},
		{
			0.8,
			{
				{
					2,
					2,
					"enemy_demon_wolf"
				}
			}
		},
		{
			1,
			{
				{
					3,
					3,
					"enemy_demon"
				}
			}
		}
	},
	{
		{
			1,
			{
				{
					3,
					3,
					"enemy_demon"
				}
			}
		}
	}
}
tt.portal_idx = 1
tt.spawn_interval = fts(30)
tt.pi = 1
tt = E:register_t("decal_s12_shoutbox", "decal_tween")

E:add_comps(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "boss_veznan_taunts_love_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = v(-3, 6)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(164, 70)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = 24
tt.texts.list[1].color = {
	233,
	189,
	255
}
tt.texts.list[1].line_height = i18n:cjk(1, 1)
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
tt = RT("decal_veznan_strike", "decal_timed")
tt.render.sprites[1].name = "decal_veznan_strike"
tt.render.sprites[1].z = Z_DECALS
tt = RT("veznan_soul", "decal_scripted")
tt.angle_variation = d2r(5)
tt.duration = 8
tt.main_script.update = kr1_scripts.veznan_soul.update
tt.max_angle = d2r(70)
tt.min_angle = d2r(-70)
tt.particles_name = "ps_veznan_soul"
tt.render.sprites[1].name = "decal_veznan_soul"
tt.render.sprites[1].z = Z_EFFECTS
tt.speed = {
	6 * FPS,
	15 * FPS
}
tt = RT("decal_eb_veznan_white_circle", "decal_tween")
tt.render.sprites[1].name = "decal_veznan_white_circle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		vv(1)
	},
	{
		fts(65),
		vv(1)
	},
	{
		fts(65) + 0.5,
		vv(20)
	},
	{
		fts(65) + 4.5,
		vv(20)
	}
}
tt = RT("decal_hobgoblin_ground_hit", "decal_tween")
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
tt.render.sprites[1].name = "hobgoblin_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false

tt = RT("tower_holder_grass", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_GRASS
tt.render.sprites[1].name = "terrains_holders_0101"
tt.render.sprites[2].name = "terrains_holders_0101_flag"

tt = RT("tower_holder_snow", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_SNOW
tt.render.sprites[1].name = "terrains_holders_0102"
tt.render.sprites[2].name = "terrains_holders_0102_flag"

tt = RT("tower_holder_wasteland", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_WASTELAND
tt.render.sprites[1].name = "terrains_holders_0103"
tt.render.sprites[2].name = "terrains_holders_0103_flag"

tt = RT("tower_holder_blackburn", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_BLACKBURN
tt.render.sprites[1].name = "terrains_holders_0108"
tt.render.sprites[2].name = "terrains_holders_0108_flag"

tt = RT("tower_arcane_wizard", "tower_mage_1")

AC(tt, "attacks", "powers")

image_y = 90
tt.tower.type = "arcane_wizard"
tt.tower.level = 1
tt.tower.price = 300
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = v(0, 14)
tt.info.enc_icon = 15
tt.info.i18n_key = "TOWER_ARCANE"
tt.info.fn = kr1_scripts.tower_arcane_wizard.get_info
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_towers_0005" or "info_portraits_towers_0008"
tt.powers.disintegrate = CC("power")
tt.powers.disintegrate.price_base = 350
tt.powers.disintegrate.price_inc = 200
tt.powers.disintegrate.cooldown_base = 22
tt.powers.disintegrate.cooldown_inc = -2
tt.powers.disintegrate.enc_icon = 15
tt.powers.disintegrate.name = "DESINTEGRATE"
tt.powers.teleport = CC("power")
tt.powers.teleport.price_base = 300
tt.powers.teleport.price_inc = 100
tt.powers.teleport.max_count_base = 3
tt.powers.teleport.max_count_inc = 1
tt.powers.teleport.enc_icon = 16
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_mage_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "tower_arcane_wizard"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = v(0, 40)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "tower_arcane_wizard_shooter"
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
tt.render.sprites[3].angles.teleport = {
	"teleportUp",
	"teleportDown"
}
tt.render.sprites[3].offset = v(0, 58)
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "fx_tower_arcane_wizard_teleport"
tt.render.sprites[4].loop = false
tt.render.sprites[4].ts = -10
tt.render.sprites[4].offset = v(-1, 90)
tt.main_script.update = kr1_scripts.tower_arcane_wizard.update
tt.sound_events.insert = "MageArcaneTaunt"
tt.attacks.range = 200
tt.attacks.min_cooldown = 2
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "ray_arcane"
tt.attacks.list[1].cooldown = 2
tt.attacks.list[1].node_prediction = fts(5)
tt.attacks.list[1].shoot_time = fts(20)
tt.attacks.list[1].bullet_start_offset = v(0, 76)
tt.attacks.list[2] = table.deepclone(tt.attacks.list[1])
tt.attacks.list[2].bullet = "ray_arcane_disintegrate"
tt.attacks.list[2].cooldown = 20
tt.attacks.list[2].vis_flags = bor(F_DISINTEGRATED)
tt.attacks.list[2].vis_bans = bor(F_BOSS)
tt.attacks.list[3] = CC("aura_attack")
tt.attacks.list[3].animation = "teleport"
tt.attacks.list[3].shoot_time = fts(4)
tt.attacks.list[3].cooldown = 10
tt.attacks.list[3].aura = "aura_teleport_arcane"
tt.attacks.list[3].min_nodes = 15
tt.attacks.list[3].node_prediction = fts(4)
tt.attacks.list[3].vis_flags = bor(F_RANGED, F_MOD, F_TELEPORT)
tt.attacks.list[3].vis_bans = bor(F_BOSS, F_FREEZE)

tt = RT("tower_ranger", "tower_archer_1")

AC(tt, "attacks", "powers")

image_y = 90
tt.tower.type = "ranger"
tt.tower.level = 1
tt.tower.price = 230
tt.tower.size = TOWER_SIZE_LARGE
tt.info.enc_icon = 13
tt.info.i18n_key = "TOWER_RANGERS"
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_towers_0010" or "info_portraits_towers_0006"
tt.powers.poison = CC("power")
tt.powers.poison.price_base = 250
tt.powers.poison.price_inc = 250
tt.powers.poison.mod = "mod_ranger_poison"
tt.powers.poison.enc_icon = 8
tt.powers.thorn = CC("power")
tt.powers.thorn.price_base = 300
tt.powers.thorn.price_inc = 150
tt.powers.thorn.aura = "aura_ranger_thorn"
tt.powers.thorn.enc_icon = 9
tt.powers.thorn.name = "thorns"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_archer_ranger_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "archer_tower_0005"
tt.render.sprites[2].offset = v(0, 40)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "tower_ranger_shooter"
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
tt.render.sprites[3].offset = v(-8, 65)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[4].offset.x = 8
tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].prefix = "tower_ranger_druid"
tt.render.sprites[5].name = "idle"
tt.render.sprites[5].hidden = true
tt.render.sprites[5].offset = v(31, 15)
tt.main_script.update = kr1_scripts.tower_ranger.update
tt.attacks.range = 200
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "arrow_ranger"
tt.attacks.list[1].cooldown = 0.4
tt.attacks.list[1].shoot_time = fts(4)
tt.attacks.list[1].shooters_delay = 0.1
tt.attacks.list[1].bullet_start_offset = {
	v(8, 4),
	v(4, -5)
}
tt.sound_events.insert = "ArcherRangerTaunt"

tt = RT("tower_elf", "tower")

AC(tt, "barrack")

tt.info.portrait = (IS_PHONE_OR_TABLET and "portraits_towers" or "info_portraits_towers") .. "_0013"
tt.barrack.max_soldiers = 4
tt.barrack.rally_range = 145
tt.barrack.respawn_offset = v(0, 0)
tt.barrack.soldier_type = "soldier_elf"
tt.editor.props = table.append(tt.editor.props, {
	{
		"barrack.rally_pos",
		PT_COORDS
	}
}, true)
tt.info.i18n_key = "SPECIAL_ELF"
tt.info.fn = kr1_scripts.tower_elf_holder.get_info
tt.main_script.insert = kr1_scripts.tower_barrack.insert
tt.main_script.remove = kr1_scripts.tower_barrack.remove
tt.main_script.update = kr1_scripts.tower_barrack_mercenaries.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_barrack_%04i"
tt.render.sprites[1].offset = v(0, 2)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "elfTower_layer1_0001"
tt.render.sprites[2].offset = v(0, 20)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "close"
tt.render.sprites[3].offset = v(0, 20)
tt.render.sprites[3].prefix = "tower_elf_door"
tt.render.door_sid = 3
tt.sound_events.change_rally_point = "ElfTaunt"
tt.sound_events.insert = "GUITowerBuilding"
tt.sound_events.mute_on_level_insert = true
tt.tower.can_be_mod = false
tt.tower.level = 1
tt.tower.price = 100
tt.tower.terrain_style = nil
tt.tower.type = "elf"
tt.ui.click_rect = r(-40, -10, 80, 90)
tt = RT("tower_sasquash_holder")

AC(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "editor", "main_script")

tt.tower.type = "holder_sasquash"
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.main_script.update = kr1_scripts.tower_sasquash_holder.update
tt.info.i18n_key = "SPECIAL_SASQUASH_REPAIR"
tt.info.fn = kr1_scripts.tower_barrack_mercenaries.get_info
tt.info.portrait = (IS_PHONE_OR_TABLET and "portraits_towers" or "info_portraits_towers") .. "_0014"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "sasquash_frozen_0001"
tt.render.sprites[1].offset = v(-9, 13)
tt.render.sprites[1].z = Z_TOWER_BASES - 2
tt.ui.click_rect = r(-40, -30, 80, 90)
tt.unfreeze_radius = 60
tt.unfreeze_fx = "fx_tower_sasquash_unfreeze"
tt.unfreeze_upgrade_to = "tower_sasquash"
tt.unfreeze_rect = r(290, 480, 120, 90)
tt = RT("fx_tower_sasquash_unfreeze", "fx")
tt.render.sprites[1].name = "tower_sasquash_unfreeze"
tt.render.sprites[1].offset = v(-9, 13)
tt.render.sprites[1].z = Z_EFFECTS
tt = RT("tower_sasquash", "tower")

AC(tt, "barrack")

tt.info.portrait = (IS_PHONE_OR_TABLET and "portraits_towers" or "info_portraits_towers") .. "_0014"
tt.barrack.max_soldiers = 1
tt.barrack.rally_range = 288
tt.barrack.respawn_offset = v(-60, 0)
tt.barrack.soldier_type = "soldier_sasquash"
tt.barrack.has_door = nil
tt.editor.props = table.append(tt.editor.props, {
	{
		"barrack.rally_pos",
		PT_COORDS
	}
}, true)
tt.info.i18n_key = "SPECIAL_SASQUASH"
tt.info.fn = kr1_scripts.tower_sasquash_holder.get_info
tt.main_script.insert = kr1_scripts.tower_barrack.insert
tt.main_script.remove = kr1_scripts.tower_barrack.remove
tt.main_script.update = kr1_scripts.tower_barrack_mercenaries.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "sasquash_cave_inside"
tt.render.sprites[1].offset = v(-9, 13)
tt.render.sprites[1].z = Z_TOWER_BASES - 2
tt.sound_events.change_rally_point = "SasquashRally"
tt.sound_events.insert = nil
tt.sound_events.mute_on_level_insert = true
tt.tower.can_be_mod = false
tt.tower.can_be_sold = false
tt.tower.level = 1
tt.tower.price = 0
tt.tower.terrain_style = nil
tt.tower.type = "sasquash"
tt.ui.click_rect = r(-40, -30, 80, 90)
tt.ui.has_nav_mesh = true

tt = RT("soldier_elf", "soldier_militia")

AC(tt, "ranged")

image_y = 32
anchor_y = 0.19
tt.health.hp_max = 100
tt.health_bar.offset = v(0, ady(31))
tt.health.dead_lifetime = 3
tt.info.fn = kr1_scripts.soldier_mercenary.get_info
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0044" or "info_portraits_sc_0044"
tt.info.random_name_count = 10
tt.info.random_name_format = "SOLDIER_ELVES_RANDOM_%i_NAME"
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 25
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].track_damage = true
tt.melee.range = 75
tt.ranged.go_back_during_cooldown = true
tt.ranged.attacks[1].bullet = "arrow_elf"
tt.ranged.attacks[1].bullet_start_offset = {
	v(4, 16)
}
tt.ranged.attacks[1].cooldown = 1 + fts(15)
tt.ranged.attacks[1].max_range = 205
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(7)
tt.regen.cooldown = 1
tt.regen.health = 20
tt.render.sprites[1].prefix = "soldier_elf"
tt.sound_events.insert = "ElfTaunt"
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, ady(22))
tt.unit.price = 100
tt = RT("soldier_sasquash", "soldier_militia")
image_y = 80
anchor_y = 0.17
tt.health.hp_max = 2500
tt.health_bar.offset = v(0, ady(73))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.dead_lifetime = 3
tt.info.fn = kr1_scripts.soldier_mercenary.get_info
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0034" or "info_portraits_sc_0034"
tt.info.i18n_key = "SOLDIER_SASQUASH"
tt.info.random_name_format = nil
tt.main_script.insert = kr1_scripts.soldier_sasquash.insert
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 110
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 35
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(35, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].pop = {
	"pop_kapow",
	"pop_whaam"
}
tt.melee.attacks[1].pop_chance = 0.3
tt.melee.attacks[1].pop_conds = DR_KILL
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.melee.range = 83
tt.motion.max_speed = 49.5
tt.regen.cooldown = 1
tt.regen.health = 250
tt.render.sprites[1].prefix = "soldier_sasquash"
tt.soldier.melee_slot_offset = v(25, 0)
tt.sound_events.insert = "SasquashReady"
tt.ui.click_rect = r(-20, 0, 40, 40)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, ady(30))
tt.unit.price = 400
tt = RT("soldier_s6_imperial_guard", "soldier_militia")

AC(tt, "editor")

anchor_x, anchor_y = 0.5, 0.15
image_x, image_y = 58, 41
tt.health.armor = 0.4
tt.health.dead_lifetime = 3
tt.health.hp_max = 250
tt.health_bar.offset = v(adx(28), ady(40))
tt.info.fn = kr1_scripts.soldier_mercenary.get_info
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0026" or "info_portraits_sc_0026"
tt.info.random_name_count = 20
tt.info.random_name_format = "SOLDIER_PALADIN_RANDOM_%i_NAME"
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].hit_time = fts(6)
tt.melee.cooldown = 1
tt.melee.range = 72.5
tt.motion.max_speed = 60
tt.regen.health = 25
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "soldier_s6_imperial_guard"
tt.soldier.melee_slot_offset = v(8, 0)
tt.unit.mod_offset = v(adx(27), ady(22))
tt.editor.props = {
	{
		"editor.game_mode",
		PT_NUMBER
	}
}
tt.editor.overrides = {
	["health.hp"] = 250
}

tt = RT("soldier_alleria_wildcat", "soldier")

E:add_comps(tt, "melee", "nav_grid")

anchor_y = 0.28
image_y = 42
tt.fn_level_up = kr1_scripts.soldier_alleria_wildcat.level_up
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_hero_0007" or "info_portraits_hero_0007"
tt.health.armor = 0
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 35)
tt.info.fn = kr1_scripts.soldier_alleria_wildcat.get_info
tt.info.i18n_key = "HERO_ARCHER_WILDCAT"
tt.main_script.insert = kr1_scripts.soldier_alleria_wildcat.insert
tt.main_script.update = kr1_scripts.soldier_alleria_wildcat.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].vis_bans = bor(F_FLYING)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].sound = "HeroArcherWildCatHit"
tt.melee.range = 80
tt.motion.max_speed = 90
tt.regen.health = 75
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].prefix = "soldier_alleria"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"running"
}
tt.soldier.melee_slot_offset.x = 5
tt.ui.click_rect = IS_PHONE_OR_TABLET and r(-20, -10, 40, 40) or r(-15, -5, 30, 30)
tt.unit.hit_offset = v(0, 12)
tt.unit.mod_offset = v(0, 14)
tt.unit.hide_after_death = true
tt.unit.explode_fx = nil
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE)

tt = RT("kr1_hero_alleria", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

anchor_x, anchor_y = 0.5, 0.14
image_x, image_y = 60, 76
tt.hero.fixed_stat_attack = 3
tt.hero.fixed_stat_health = 3
tt.hero.fixed_stat_range = 6
tt.hero.fixed_stat_speed = 6
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
	250,
	270,
	290,
	310,
	330,
	350,
	370,
	390,
	410,
	430
}
tt.hero.level_stats.melee_damage_max = {
	4,
	6,
	8,
	11,
	13,
	16,
	18,
	20,
	23,
	25
}
tt.hero.level_stats.melee_damage_min = {
	2,
	4,
	6,
	7,
	9,
	10,
	12,
	14,
	15,
	17
}
tt.hero.level_stats.ranged_damage_max = {
	12,
	14,
	15,
	17,
	18,
	20,
	21,
	23,
	24,
	26
}
tt.hero.level_stats.ranged_damage_min = {
	7,
	8,
	9,
	10,
	11,
	12,
	13,
	14,
	14,
	15
}
tt.hero.level_stats.regen_health = {
	63,
	68,
	73,
	78,
	83,
	88,
	93,
	98,
	103,
	108
}
tt.hero.skills.multishot = CC("hero_skill")
tt.hero.skills.multishot.count_base = 1
tt.hero.skills.multishot.count_inc = 1
tt.hero.skills.multishot.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.multishot.xp_gain = {
	25,
	50,
	75
}
tt.hero.skills.callofwild = CC("hero_skill")
tt.hero.skills.callofwild.damage_max_base = 4
tt.hero.skills.callofwild.damage_min_base = 2
tt.hero.skills.callofwild.damage_inc = 4
tt.hero.skills.callofwild.hp_base = 0
tt.hero.skills.callofwild.hp_inc = 200
tt.hero.skills.callofwild.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.callofwild.xp_level_steps = {
	[10] = 3,
	[4] = 1,
	[7] = 2
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 33)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr1_scripts.hero_alleria.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.damage_icon = "arrow"
tt.info.hero_portrait = IS_PHONE_OR_TABLET and "hero_portraits_0004" or "heroPortrait_portraits_0004"
tt.info.fn = kr1_scripts.hero_basic.get_info_ranged
tt.info.i18n_key = "HERO_ARCHER"
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_hero_0004" or "info_portraits_hero_0001"
tt.main_script.update = kr1_scripts.hero_alleria.update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.14)
tt.render.sprites[1].prefix = "hero_alleria"
tt.soldier.melee_slot_offset = v(4, 0)
tt.sound_events.change_rally_point = "HeroArcherTaunt"
tt.sound_events.death = "HeroArcherDeath"
tt.sound_events.hero_room_select = "HeroArcherTauntSelect"
tt.sound_events.insert = "HeroArcherTauntIntro"
tt.sound_events.respawn = "HeroArcherTauntIntro"
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2.5
tt.melee.range = 45
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].bullet = "kr1_arrow_hero_alleria"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 12)
}
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 45
tt.ranged.attacks[1].shoot_time = fts(6)
tt.ranged.attacks[1].cooldown = 0.6
tt.ranged.attacks[2] = E:clone_c("bullet_attack")
tt.ranged.attacks[2].animation = "multishot"
tt.ranged.attacks[2].bullet = "kr1_arrow_multishot_hero_alleria"
tt.ranged.attacks[2].bullet_start_offset = {
	v(0, 12)
}
tt.ranged.attacks[2].cooldown = 3 + fts(29)
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].max_range = 150
tt.ranged.attacks[2].min_range = 45
tt.ranged.attacks[2].node_prediction = fts(13)
tt.ranged.attacks[2].shoot_time = fts(13)
tt.ranged.attacks[2].sound = "HeroArcherShoot"
tt.ranged.attacks[2].xp_from_skill = "multishot"
tt.timed_attacks.list[1] = E:clone_c("spawn_attack")
tt.timed_attacks.list[1].animation = "callofwild"
tt.timed_attacks.list[1].cooldown = 20
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_alleria_wildcat"
tt.timed_attacks.list[1].pet = nil
tt.timed_attacks.list[1].sound = "HeroArcherSummon"
tt.timed_attacks.list[1].spawn_time = fts(17)
tt.timed_attacks.list[1].min_range = 30
tt.timed_attacks.list[1].max_range = 50

tt = RT("hero_malik", "hero")

AC(tt, "melee")

anchor_x, anchor_y = 0.5, 0.1
image_x, image_y = 96, 100
tt.hero.fixed_stat_attack = 7
tt.hero.fixed_stat_health = 8
tt.hero.fixed_stat_range = 0
tt.hero.fixed_stat_speed = 4
tt.hero.level_stats.armor = {
	0,
	0.1,
	0.1,
	0.2,
	0.2,
	0.3,
	0.3,
	0.4,
	0.4,
	0.5
}
tt.hero.level_stats.hp_max = {
	450,
	480,
	510,
	540,
	570,
	600,
	630,
	660,
	690,
	720
}
tt.hero.level_stats.melee_damage_max = {
	22,
	24,
	26,
	29,
	31,
	34,
	36,
	38,
	41,
	43
}
tt.hero.level_stats.melee_damage_min = {
	14,
	16,
	18,
	19,
	21,
	22,
	24,
	26,
	27,
	29
}
tt.hero.level_stats.regen_health = {
	113,
	120,
	128,
	135,
	143,
	150,
	158,
	165,
	173,
	180
}
tt.hero.skills.smash = CC("hero_skill")
tt.hero.skills.smash.damage_min = {
	20,
	40,
	60
}
tt.hero.skills.smash.damage_max = {
	40,
	60,
	80
}
tt.hero.skills.smash.xp_level_steps = {
	nil,
	1,
	nil,
	nil,
	2,
	nil,
	nil,
	3
}
tt.hero.skills.smash.xp_gain = {
	50,
	100,
	150
}
tt.hero.skills.fissure = CC("hero_skill")
tt.hero.skills.fissure.damage_min = {
	10,
	20,
	30
}
tt.hero.skills.fissure.damage_max = {
	30,
	40,
	50
}
tt.hero.skills.fissure.xp_level_steps = {
	[10] = 3,
	[4] = 1,
	[7] = 2
}
tt.hero.skills.fissure.xp_gain = {
	50,
	100,
	150
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 38)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = kr1_scripts.hero_malik.level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = IS_PHONE_OR_TABLET and "hero_portraits_0001" or "heroPortrait_portraits_0001"
tt.info.i18n_key = "HERO_REINFORCEMENT"
tt.info.fn = kr1_scripts.hero_basic.get_info_melee
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_hero_0001" or "info_portraits_hero_0006"
tt.main_script.update = kr1_scripts.hero_malik.update
tt.motion.max_speed = 2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = v(0.5, 0.1)
tt.render.sprites[1].prefix = "hero_malik"
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "HeroReinforcementTaunt"
tt.sound_events.death = "HeroReinforcementDeath"
tt.sound_events.hero_room_select = "HeroReinforcementTauntSelect"
tt.sound_events.insert = "HeroReinforcementTauntIntro"
tt.sound_events.respawn = "HeroReinforcementTauntIntro"
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.melee.range = 65
tt.melee.cooldown = 1
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 1.9549999999999998
tt.melee.attacks[1].sound_hit = "HeroReinforcementHit"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = CC("area_attack")
tt.melee.attacks[3].animation = "smash"
tt.melee.attacks[3].cooldown = 6 + fts(28)
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_radius = 60
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_decal = "decal_bomb_crater"
tt.melee.attacks[3].hit_fx = "decal_malik_ring"
tt.melee.attacks[3].hit_time = fts(14)
tt.melee.attacks[3].hit_offset = v(22, 0)
tt.melee.attacks[3].min_count = 3
tt.melee.attacks[3].sound = "HeroReinforcementSpecial"
tt.melee.attacks[3].xp_from_skill = "smash"
tt.melee.attacks[4] = CC("area_attack")
tt.melee.attacks[4].animation = "fissure"
tt.melee.attacks[4].cooldown = 14 + fts(37)
tt.melee.attacks[4].damage_max = 0
tt.melee.attacks[4].damage_min = 0
tt.melee.attacks[4].damage_radius = 40
tt.melee.attacks[4].damage_type = DAMAGE_NONE
tt.melee.attacks[4].disabled = true
tt.melee.attacks[4].hit_aura = "aura_malik_fissure"
tt.melee.attacks[4].hit_offset = v(22, 0)
tt.melee.attacks[4].hit_time = fts(17)
tt.melee.attacks[4].sound = "HeroReinforcementJump"
tt.melee.attacks[4].xp_from_skill = "fissure"

tt = RT("enemy_goblin", "enemy_KR5")

AC(tt, "melee")

image_x, image_y = 46, 32
anchor_x, anchor_y = 0.5, 0.2
tt.enemy.gold = 3
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 20
tt.health_bar.offset = v(0, 25)
tt.info.i18n_key = "ENEMY_GOBLIN"
tt.info.enc_icon = 1
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0006" or "info_portraits_sc_0006"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 4
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = v(0.5, anchor_y)
tt.render.sprites[1].prefix = "goblin"
tt.sound_events.death = "DeathGoblin"
tt.unit.hit_offset = v(0, 8)
tt.unit.mod_offset = v(adx(22), ady(15))
tt = RT("enemy_fat_orc", "enemy_KR5")

AC(tt, "melee")

anchor_x, anchor_y = 0.5, 0.19
image_x, image_y = 58, 42
tt.enemy.gold = 9
tt.enemy.melee_slot = v(18, 0)
tt.health.armor = 0.3
tt.health.hp_max = 80
tt.health_bar.offset = v(0, 30)
tt.info.i18n_key = "ENEMY_FAT_ORC"
tt.info.enc_icon = 2
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0007" or "info_portraits_sc_0007"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 8
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].hit_time = fts(6)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.19)
tt.render.sprites[1].prefix = "enemy_fat_orc"
tt.sound_events.death = "DeathOrc"
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(adx(30), ady(20))

tt = RT("enemy_wolf_small", "enemy_KR5")
AC(tt, "dodge", "melee")
anchor_x, anchor_y = 0.5, 0.21
image_x, image_y = 38, 28
tt.dodge.chance = 0.3
tt.dodge.silent = true
tt.enemy.gold = 5
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 35
tt.health_bar.offset = v(0, 25)
tt.info.i18n_key = "ENEMY_WULF"
-- tt.info.enc_icon = 13
tt.info.portrait = "bottom_info_image_enemies_0049"
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].damage_max = 3
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 2.5 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.21)
tt.render.sprites[1].prefix = "enemy_wolf_small"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.unit.can_explode = false
tt.unit.show_blood_pool = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 11)
tt.unit.mod_offset = v(adx(22), ady(14))
tt.vis.bans = bor(F_SKELETON)

tt = RT("enemy_wolf", "enemy_KR5")
AC(tt, "dodge", "melee")
anchor_x, anchor_y = 0.5, 0.26
image_x, image_y = 60, 50
tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.enemy.gold = 12
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = 120
tt.health.magic_armor = 0.5
tt.health_bar.offset = v(0, 35)
tt.info.i18n_key = "ENEMY_WORG"
-- tt.info.enc_icon = 14
tt.info.portrait = "bottom_info_image_enemies_0048"
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.26)
tt.render.sprites[1].prefix = "enemy_wolf"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.unit.can_explode = false
tt.unit.show_blood_pool = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 13)
tt.unit.marker_offset.y = 2
tt.unit.mod_offset = v(adx(29), ady(26))
tt.vis.bans = bor(F_SKELETON)

tt = RT("enemy_shadow_archer", "enemy_KR5")
AC(tt, "melee", "ranged")
anchor_x, anchor_y = 0.5, 0.2
image_x, image_y = 54, 36
tt.enemy.gold = 16
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 180
tt.health.magic_armor = 0.3
tt.health_bar.offset = v(0, 31)
tt.info.i18n_key = "ENEMY_SHADOW_ARCHER"
-- tt.info.enc_icon = 11
tt.info.portrait = "gui_bottom_info_image_soldiers_0029"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(4)
tt.motion.max_speed = 1.2 * FPS
tt.ranged.attacks[1].bullet = "arrow_shadow_archer"
tt.ranged.attacks[1].bullet_start_offset = {
	v(4, 12.5)
}
tt.ranged.attacks[1].cooldown = 1 + fts(12)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 145
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(7)
tt.render.sprites[1].anchor = v(0.5, 0.2)
tt.render.sprites[1].prefix = "enemy_shadow_archer"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(adx(26), ady(20))
tt.unit.marker_offset.y = 1
tt = RT("enemy_shaman", "enemy_KR5")

AC(tt, "melee", "timed_attacks")

anchor_x, anchor_y = 0.5, 0.2
image_x, image_y = 60, 60
tt.enemy.gold = 10
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 100
tt.health.magic_armor = 0.85
tt.health_bar.offset = v(0, 33)
tt.info.i18n_key = "ENEMY_SHAMAN"
tt.info.enc_icon = 3
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0009" or "info_portraits_sc_0009"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.enemy_shaman.update
tt.melee.attacks[1].cooldown = 1 + fts(18)
tt.melee.attacks[1].damage_max = 5
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.2)
tt.render.sprites[1].prefix = "enemy_shaman"
tt.sound_events.death = "DeathGoblin"
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "heal"
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = 8
tt.timed_attacks.list[1].max_count = 3
tt.timed_attacks.list[1].max_range = 95
tt.timed_attacks.list[1].mod = "mod_shaman_heal"
tt.timed_attacks.list[1].sound = "EnemyHealing"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, -2)
tt.unit.mod_offset = v(adx(30), ady(20))

tt = RT("enemy_gargoyle", "enemy_KR5")
anchor_x, anchor_y = 0.5, 0
image_x, image_y = 58, 88
tt.enemy.gold = 12
tt.health.hp_max = 90
tt.health_bar.offset = v(adx(29), ady(69))
tt.info.i18n_key = "ENEMY_GARGOYLE"
tt.info.enc_icon = 10
tt.info.portrait = "bottom_info_image_enemies_0040"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.enemy_passive.update
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_gargoyle"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-14, 34, 28, 30)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, 52)
tt.unit.hide_after_death = true
tt.unit.mod_offset = v(adx(31), ady(50))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_THORN, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)

tt = RT("enemy_ogre", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.2
image_x, image_y = 86, 80
tt.enemy.gold = 50
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(24, 0)
tt.health.hp_max = 800
tt.health_bar.offset = v(0, 53)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_OGRE"
tt.info.enc_icon = 4
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0011" or "info_portraits_sc_0011"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 60
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(16)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_ogre"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(34, 45)
tt.ui.click_rect.pos.x = -17
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(adx(42), ady(33))
tt.unit.size = UNIT_SIZE_MEDIUM

tt = RT("enemy_spider_tiny", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.25
image_x, image_y = 30, 24
tt.enemy.gold = 1
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = 10
tt.health.magic_armor = 0.5
tt.health_bar.offset = v(0, 16)
tt.info.i18n_key = "ENEMY_SPIDERTINY"
tt.info.portrait = "bottom_info_image_enemies_0047"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 5
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider_tiny"
tt.sound_events.death = "DeathEplosionShortA"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = v(0, 8)
tt.unit.marker_offset = v(0, ady(5))
tt.unit.mod_offset = v(adx(18), ady(13))
tt.vis.bans = bor(F_SKELETON, F_POISON)

tt = RT("enemy_spider_small", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.25
image_x, image_y = 36, 28
tt.enemy.gold = 6
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = 60
tt.health.magic_armor = 0.65
tt.health_bar.offset = v(0, 22)
tt.info.i18n_key = "ENEMY_SPIDERSMALL"
-- tt.info.enc_icon = 8
tt.info.portrait = "bottom_info_image_enemies_0046"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 1.5 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider_small"
tt.sound_events.death = "DeathEplosion"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = v(0, 8)
tt.unit.marker_offset = v(0, -1)
tt.unit.mod_offset = v(adx(20), ady(15))
tt.vis.bans = bor(F_SKELETON, F_POISON)

tt = RT("enemy_spider_big", "enemy_KR5")
AC(tt, "melee", "timed_attacks")
anchor_x, anchor_y = 0.5, 0.25
image_x, image_y = 56, 40
tt.enemy.gold = 20
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(24, 0)
tt.health.hp_max = 250
tt.health.magic_armor = 0.8
tt.health_bar.offset = v(0, 32)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_SPIDER"
-- tt.info.enc_icon = 9
tt.info.portrait = "bottom_info_image_enemies_0045"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.enemy_spider_big.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider"
tt.sound_events.death = "DeathEplosion"
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].bullet = "enemy_spider_egg"
tt.timed_attacks.list[1].max_cooldown = 10
tt.timed_attacks.list[1].max_count = 3
tt.timed_attacks.list[1].min_cooldown = 5
tt.ui.click_rect = r(-20, -5, 40, 30)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = v(0, 8)
tt.unit.marker_offset = v(-0.4, -2.2)
tt.unit.mod_offset = v(adx(26), ady(18))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_SKELETON, F_POISON)

tt = RT("enemy_brigand", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.2
image_x, image_y = 50, 38
tt.enemy.gold = 15
tt.enemy.melee_slot = v(18, 0)
tt.health.armor = 0.5
tt.health.hp_max = 160
tt.health_bar.offset = v(0, 31)
tt.info.i18n_key = "ENEMY_BRIGAND"
tt.info.enc_icon = 6
tt.info.portrait = "bottom_info_image_enemies_0039"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 10
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_brigand"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(adx(24), ady(19))

tt = RT("enemy_dark_knight", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.2
image_x, image_y = 64, 46
tt.enemy.gold = 25
tt.enemy.melee_slot = v(24, 0)
tt.health.armor = 0.8
tt.health.hp_max = 300
tt.health_bar.offset = v(0, 35)
tt.info.i18n_key = "ENEMY_DARK_KNIGHT"
tt.info.enc_icon = 12
tt.info.portrait = "bottom_info_image_soldiers_0022"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(7)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_dark_knight"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = v(0, 16)
tt.unit.mod_offset = v(adx(32), ady(20))
tt.unit.marker_offset.y = -2

tt = RT("enemy_marauder", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.22
image_x, image_y = 78, 56
tt.enemy.gold = 40
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(24, 0)
tt.health.armor = 0.6
tt.health.hp_max = 600
tt.health_bar.offset = v(0, 48)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_MARAUDER"
tt.info.enc_icon = 7
tt.info.portrait = "bottom_info_image_enemies_0042"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 24
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].hit_time = fts(10)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_marauder"
tt.sound_events.death = "DeathHuman"
tt.ui.click_rect = r(-20, -5, 40, 40)
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(adx(39), ady(24))
tt.unit.size = UNIT_SIZE_MEDIUM

tt = RT("enemy_bandit", "enemy_KR5")
AC(tt, "melee", "dodge")
anchor_x, anchor_y = 0.5, 0.2
image_x, image_y = 48, 34
tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.enemy.gold = 8
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 70
tt.health_bar.offset = v(0, 30)
tt.info.i18n_key = "ENEMY_BANDIT"
tt.info.enc_icon = 5
tt.info.portrait = "bottom_info_image_enemies_0038"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(4)
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_bandit"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, 2)
tt.unit.mod_offset = v(adx(24), ady(17))

tt = RT("enemy_slayer", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.22
image_x, image_y = 74, 66
tt.enemy.gold = 100
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(24, 0)
tt.health.armor = 0.95
tt.health.hp_max = 1200
tt.health_bar.offset = v(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_SLAYER"
tt.info.enc_icon = 22
tt.info.portrait = "bottom_info_image_soldiers_0023"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 76
tt.melee.attacks[1].damage_min = 24
tt.melee.attacks[1].hit_time = fts(7)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_slayer"
tt.sound_events.death = "DeathHuman"
tt.ui.click_rect.size = v(32, 42)
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(adx(37), ady(25))
tt.unit.size = UNIT_SIZE_MEDIUM

tt = RT("enemy_rocketeer", "enemy_KR5")
anchor_x, anchor_y = 0.5, 0
image_x, image_y = 80, 88
tt.enemy.gold = 30
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 340
tt.health.on_damage = kr1_scripts.enemy_rocketeer.on_damage
tt.health_bar.offset = v(0, 78)
tt.info.i18n_key = "ENEMY_ROCKETEER"
-- tt.info.enc_icon = 21
tt.info.portrait = "gui_bottom_info_image_soldiers_0017"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.enemy_passive.update
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = v(0.5, 0)
tt.render.sprites[1].prefix = "enemy_rocketeer"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "BombExplosionSound"
tt.ui.click_rect = r(-14, 40, 28, 34)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 58)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(40), ady(56))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_THORN, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)

tt = RT("enemy_troll", "enemy_KR5")

AC(tt, "melee", "auras")

anchor_x, anchor_y = 0.5, 0.22727272727272727
image_x, image_y = 60, 44
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_troll_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 25
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 280
tt.info.i18n_key = "ENEMY_TROLL"
tt.info.enc_icon = 17
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0029" or "info_portraits_sc_0029"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(7)
tt.motion.max_speed = 0.9 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll"
tt.sound_events.death = "DeathTroll"
tt.unit.hit_offset = v(0, 13)
tt.unit.mod_offset = v(adx(28), ady(23))
tt = RT("enemy_whitewolf", "enemy_KR5")

AC(tt, "melee", "dodge")

anchor_x, anchor_y = 0.5, 0.3275862068965517
image_x, image_y = 64, 58
tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.enemy.gold = 35
tt.enemy.melee_slot = v(24, 0)
tt.health.hp_max = 350
tt.health.magic_armor = 0.5
tt.health_bar.offset = v(0, 39)
tt.info.i18n_key = "ENEMY_WHITE_WOLF"
tt.info.enc_icon = 16
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0032" or "info_portraits_sc_0032"
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_whitewolf"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.ui.click_rect.size.x = 32
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 13)
tt.unit.mod_offset = v(adx(32), ady(32))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)
tt = RT("enemy_yeti", "enemy_KR5")

AC(tt, "melee")

anchor_x, anchor_y = 0.5, 0.19
image_x, image_y = 100, 80
tt.enemy.gold = 120
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = 2000
tt.health_bar.offset = v(0, 56)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_YETI"
tt.info.enc_icon = 20
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0033" or "info_portraits_sc_0033"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 150
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(30, 0)
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].sound = "AreaAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(13)
}
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_yeti"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(50, 50)
tt.ui.click_rect.pos.x = -25
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 24)
tt.unit.mod_offset = v(adx(47), ady(35))
tt.unit.size = UNIT_SIZE_LARGE
tt = RT("enemy_forest_troll", "enemy_KR5")

AC(tt, "melee", "auras")

anchor_x, anchor_y = 0.5, 0.21
image_x, image_y = 156, 100
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_forest_troll_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 200
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(35, 0)
tt.health.hp_max = 4000
tt.health_bar.offset = v(0, 76)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_FOREST_TROLL"
tt.info.enc_icon = 39
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0062" or "info_portraits_sc_0060"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 150
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "AreaAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(15)
}
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_forest_troll"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(58, 55)
tt.ui.click_rect.pos = v(-30, 3)
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 30)
tt.unit.marker_offset = v(1, 2)
tt.unit.mod_offset = v(adx(78), ady(45))
tt.unit.size = UNIT_SIZE_LARGE
tt = RT("enemy_orc_armored", "enemy_KR5")

AC(tt, "melee")

anchor_x, anchor_y = 0.5, 0.14
image_x, image_y = 70, 48
tt.enemy.gold = 30
tt.enemy.melee_slot = v(18, 0)
tt.health.armor = 0.8
tt.health.hp_max = 400
tt.health_bar.offset = v(0, 36)
tt.info.i18n_key = "ENEMY_ORC_ARMORED"
tt.info.enc_icon = 36
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0060" or "info_portraits_sc_0059"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(6)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_orc_armored"
tt.sound_events.death = "DeathOrc"
tt.ui.click_rect.size.y = 28
tt.ui.click_rect.pos.y = 3
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset.y = 2
tt.unit.mod_offset = v(adx(34), ady(21))
tt = RT("enemy_orc_rider", "enemy_KR5")

AC(tt, "melee", "death_spawns")

anchor_x, anchor_y = 0.5, 0.14
image_x, image_y = 62, 62
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "enemy_orc_armored"
tt.enemy.gold = 25
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(30, 0)
tt.health.hp_max = 400
tt.health.magic_armor = 0.8
tt.health_bar.offset = v(0, 48)
tt.info.i18n_key = "ENEMY_ORC_RIDER"
tt.info.enc_icon = 37
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0060" or "info_portraits_sc_0059"
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 1.4 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_orc_rider"
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect.size = v(32, 38)
tt.ui.click_rect.pos = v(-16, 2)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 23)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(31), ady(29))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)
tt = RT("enemy_troll_axe_thrower", "enemy_KR5")

AC(tt, "melee", "ranged", "auras")

anchor_x, anchor_y = 0.5, 0.2
image_x, image_y = 60, 50
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].cooldown = 0
tt.auras.list[1].name = "aura_troll_axe_thrower_regen"
tt.enemy.gold = 50
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 600
tt.health_bar.offset = v(0, 43)
tt.info.i18n_key = "ENEMY_TROLL_AXE_THROWER"
tt.info.enc_icon = 18
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0030" or "info_portraits_sc_0030"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 0.8 * FPS
tt.ranged.attacks[1].bullet = "axe_troll_axe_thrower"
tt.ranged.attacks[1].bullet_start_offset = {
	v(4, 15)
}
tt.ranged.attacks[1].cooldown = 1 + fts(15)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 145
tt.ranged.attacks[1].min_range = 55
tt.ranged.attacks[1].shoot_time = fts(7)
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll_axe_thrower"
tt.sound_events.death = "DeathTroll"
tt.ui.click_rect.size = v(30, 40)
tt.ui.click_rect.pos.x = -15
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(29), ady(21))
tt.unit.size = UNIT_SIZE_MEDIUM
tt = RT("enemy_raider", "enemy_KR5")

AC(tt, "melee", "ranged")

anchor_x, anchor_y = 0.5, 0.23
image_x, image_y = 88, 68
tt.enemy.gold = 50
tt.enemy.melee_slot = v(23, 0)
tt.health.armor = 0.95
tt.health.hp_max = 1000
tt.health_bar.offset = v(0, 49)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_RAIDER"
tt.info.enc_icon = 46
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0070" or "info_portraits_sc_0070"
tt.melee.attacks[1].cooldown = 3
tt.melee.attacks[1].damage_max = 80
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(6)
tt.ranged.attacks[1].bullet = "ball_raider"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 24)
}
tt.ranged.attacks[1].cooldown = 1.5 + fts(15)
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 55
tt.ranged.attacks[1].shoot_time = fts(15)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_raider"
tt.sound_events.death = "DeathHuman"
tt.ui.click_rect.size = v(32, 44)
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 20)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(43), ady(34))
tt.unit.size = UNIT_SIZE_MEDIUM
tt = RT("enemy_pillager", "enemy_KR5")

AC(tt, "melee")

anchor_x, anchor_y = 0.5, 0.23
image_x, image_y = 154, 118
tt.enemy.gold = 100
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(33, 0)
tt.health.hp_max = 2800
tt.health.magic_armor = 0.9
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 61)
tt.info.i18n_key = "ENEMY_PILLAGER"
tt.info.enc_icon = 47
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0071" or "info_portraits_sc_0071"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 100
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_offset = v(30, 0)
tt.melee.attacks[1].hit_time = fts(14)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_pillager"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(44, 58)
tt.ui.click_rect.pos.x = -22
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 30)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(75), ady(47))
tt.unit.size = UNIT_SIZE_MEDIUM
tt = RT("enemy_troll_brute", "enemy_KR5")

AC(tt, "melee", "auras")

anchor_x, anchor_y = 0.5, 0.2125
image_x, image_y = 104, 80
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_troll_brute_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 150
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(35, 0)
tt.health.armor = 0.6
tt.health.hp_max = 2800
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 54)
tt.info.i18n_key = "ENEMY_TROLL_BRUTE"
tt.info.enc_icon = 51
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0074" or "info_portraits_sc_0074"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 3
tt.melee.attacks[1].damage_max = 165
tt.melee.attacks[1].damage_min = 95
tt.melee.attacks[1].damage_radius = 44.800000000000004
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll_brute"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(30, 40)
tt.ui.click_rect.pos.x = -15
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 14)
tt.unit.size = UNIT_SIZE_MEDIUM
tt = RT("enemy_troll_chieftain", "enemy_KR5")

AC(tt, "melee", "auras", "timed_attacks")

anchor_x, anchor_y = 0.5, 0.2
image_x, image_y = 78, 58
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_troll_chieftain_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 70
tt.enemy.lives_cost = 6
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 1200
tt.health_bar.offset = v(0, 46)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_TROLL_CHIEFTAIN"
tt.info.enc_icon = 19
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0031" or "info_portraits_sc_0031"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.enemy_troll_chieftain.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(16)
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "special"
tt.timed_attacks.list[1].cooldown = 6
tt.timed_attacks.list[1].cast_sound = "EnemyChieftain"
tt.timed_attacks.list[1].cast_time = fts(8)
tt.timed_attacks.list[1].loops = 3
tt.timed_attacks.list[1].max_count = 3
tt.timed_attacks.list[1].max_range = 180
tt.timed_attacks.list[1].mods = {
	"mod_troll_rage",
	"mod_troll_heal"
}
tt.timed_attacks.list[1].exclude_with_mods = {
	"mod_troll_rage"
}
tt.timed_attacks.list[1].allowed_templates = {
	"enemy_troll",
	"enemy_troll_axe_thrower",
	"enemy_troll_skater"
}
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll_chieftain"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(32, 40)
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(adx(37), ady(18))
tt.unit.size = UNIT_SIZE_MEDIUM
tt = RT("enemy_golem_head", "enemy_KR5")

AC(tt, "melee")

anchor_x, anchor_y = 0.5, 0.20588235294117646
image_x, image_y = 40, 34
tt.enemy.gold = 10
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = 125
tt.health_bar.offset = v(0, 23)
tt.info.i18n_key = "ENEMY_GOLEM_HEAD"
tt.info.enc_icon = 15
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0028" or "info_portraits_sc_0028"
tt.melee.attacks[1].cooldown = 1 + fts(20)
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_golem_head"
tt.sound_events.death = "DeathPuff"
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 8)
tt.unit.mod_offset = v(adx(22), ady(15))
tt.unit.show_blood_pool = false
tt = RT("enemy_goblin_zapper", "enemy_KR5")

AC(tt, "melee", "ranged", "death_spawns")

anchor_x, anchor_y = 0.5, 0.22
image_x, image_y = 52, 58
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_goblin_zapper_death"
tt.death_spawns.delay = 0.11
tt.enemy.gold = 10
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 140
tt.health_bar.offset = v(0, 34)
tt.info.i18n_key = "ENEMY_GOBLIN_ZAPPER"
tt.info.enc_icon = 38
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0061" or "info_portraits_sc_0061"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 1.2 * FPS
tt.ranged.attacks[1].bullet = "bomb_goblin_zapper"
tt.ranged.attacks[1].bullet_start_offset = {
	v(4, 12.5)
}
tt.ranged.attacks[1].cooldown = 1 + fts(12)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 60
tt.ranged.attacks[1].shoot_time = fts(7)
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_goblin_zapper"
tt.sound_events.death = "BombExplosionSound"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 13)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(26), ady(22))
tt.unit.show_blood_pool = false

tt = RT("enemy_demon", "enemy_KR5")
AC(tt, "melee", "death_spawns")
anchor_x, anchor_y = 0.5, 0.2
image_x, image_y = 44, 38
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_death"
tt.death_spawns.delay = 0.11
tt.enemy.gold = 20
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 250
tt.health.magic_armor = 0.6
tt.health_bar.offset = v(0, 29)
tt.info.i18n_key = "ENEMY_DEMON"
tt.info.enc_icon = 23
tt.info.portrait = "bottom_info_image_enemies_0033"
tt.main_script.insert = kr1_scripts.enemy_base_portal.insert
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(7)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon"
tt.sound_events.death = "DeathPuff"
tt.unit.blood_color = BLOOD_RED
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(adx(22), ady(19))
tt.unit.show_blood_pool = false

tt = RT("enemy_demon_mage", "enemy_KR5")
AC(tt, "melee", "death_spawns", "timed_attacks")
anchor_x, anchor_y = 0.5, 0.15
image_x, image_y = 58, 56
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_mage_death"
tt.death_spawns.delay = 0.11
tt.enemy.gold = 60
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(24, 0)
tt.health.hp_max = 1000
tt.health.magic_armor = 0.6
tt.health_bar.offset = v(0, 43)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_DEMON_MAGE"
tt.info.enc_icon = 24
tt.info.portrait = "bottom_info_image_enemies_0034"
tt.main_script.insert = kr1_scripts.enemy_base_portal.insert
tt.main_script.update = kr1_scripts.enemy_demon_mage.update
tt.melee.attacks[1].cooldown = 1 + fts(20)
tt.melee.attacks[1].damage_max = 75
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_mage"
tt.sound_events.death = "DeathPuff"
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "special"
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].cooldown = 6
tt.timed_attacks.list[1].max_count = 4
tt.timed_attacks.list[1].max_range = 180
tt.timed_attacks.list[1].mod = "mod_demon_shield"
tt.timed_attacks.list[1].sound = "EnemyHealing"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.timed_attacks.list[1].allowed_templates = {
	"enemy_demon_imp",
	"enemy_demon",
	"enemy_demon_cerberus",
	"enemy_demon_flareon",
	"enemy_demon_gulaemon",
	"enemy_demon_legion",
	"enemy_demon_wolf",
	"enemy_demon_mage",
	"enemy_rotten_lesser"
}
tt.ui.click_rect.size = v(32, 40)
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(adx(30), ady(20))
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM

tt = RT("enemy_demon_wolf", "enemy_KR5")
AC(tt, "melee", "death_spawns", "dodge")
anchor_x, anchor_y = 0.5, 0.15
image_x, image_y = 58, 40
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_wolf_death"
tt.death_spawns.delay = 0.11
tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.enemy.gold = 25
tt.enemy.melee_slot = v(24, 0)
tt.health.hp_max = 350
tt.health.magic_armor = 0.6
tt.health_bar.offset = v(0, 31)
tt.info.i18n_key = "ENEMY_DEMON_WOLF"
tt.info.enc_icon = 25
tt.info.portrait = "bottom_info_image_enemies_0035"
tt.main_script.insert = kr1_scripts.enemy_base_portal.insert
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 1.5 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_wolf"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.ui.click_rect.size.x = 32
tt.ui.click_rect.pos = v(-16, 0.5)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 13)
tt.unit.mod_offset = v(adx(30), ady(20))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)

tt = RT("enemy_demon_imp", "enemy_KR5")
anchor_x, anchor_y = 0.5, 0
image_x, image_y = 78, 96
tt.enemy.gold = 25
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 350
tt.health_bar.offset = v(0, 72)
tt.info.i18n_key = "ENEMY_DEMON_IMP"
tt.info.enc_icon = 26
tt.info.portrait = "bottom_info_image_enemies_0036"
tt.main_script.insert = kr1_scripts.enemy_base_portal.insert
tt.main_script.update = kr1_scripts.enemy_passive.update
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_imp"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-14, 35, 30, 32)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 58)
tt.unit.mod_offset = v(adx(38), ady(50))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_THORN, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)

tt = RT("enemy_lava_elemental", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.19
image_x, image_y = 108, 84
tt.enemy.gold = 100
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = 2500
tt.health_bar.offset = v(0, 62)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "bottom_info_image_enemies_0037"
tt.info.i18n_key = "ENEMY_LAVA_ELEMENTAL"
tt.info.enc_icon = 30
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 150
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.motion.max_speed = 0.5 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_lava_elemental"
tt.sound_events.death = "RockElementalDeath"
tt.ui.click_rect.size = v(50, 56)
tt.ui.click_rect.pos.x = -25
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 24)
tt.unit.mod_offset = v(adx(53), ady(38))
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_POISON)

tt = RT("enemy_sarelgaz_small", "enemy_KR5")

AC(tt, "melee")

anchor_x, anchor_y = 0.5, 0.19
image_x, image_y = 96, 68
tt.enemy.gold = 80
tt.enemy.melee_slot = v(35, 0)
tt.health.armor = 0.7
tt.health.hp_max = 1250
tt.health.magic_armor = 0.7
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 51)
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0058" or "info_portraits_sc_0058"
tt.info.i18n_key = "ENEMY_SARELGAZ_SMALL"
tt.info.enc_icon = 31
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 100
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].sound = "SpiderAttack"
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.19)
tt.render.sprites[1].prefix = "enemy_sarelgaz_small"
tt.sound_events.death = "DeathEplosion"
tt.ui.click_rect.size = v(54, 50)
tt.ui.click_rect.pos.x = -27
tt.unit.blood_color = BLOOD_GREEN
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 23)
tt.unit.mod_offset = v(adx(45), ady(35))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_POISON, F_SKELETON)

tt = RT("enemy_rotten_lesser", "enemy_KR5")
AC(tt, "melee", "death_spawns")
anchor_x, anchor_y = 0.5, 0.21621621621621623
image_x, image_y = 90, 74
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_rotten_lesser_death"
tt.enemy.gold = 20
tt.enemy.melee_slot = v(26, 0)
tt.health.hp_max = 500
tt.info.i18n_key = "ENEMY_ROTTEN_LESSER"
tt.info.enc_icon = 58
tt.info.portrait = "bottom_info_image_enemies_0026"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.21621621621621623)
tt.render.sprites[1].prefix = "enemy_rotten_lesser"
tt.sound_events.death = "EnemyMushroomDeath"
tt.ui.click_rect = r(-15, -5, 30, 30)
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false

tt = RT("enemy_swamp_thing", "enemy_KR5")
AC(tt, "melee", "ranged", "auras")
anchor_x, anchor_y = 0.5, 0.24
image_x, image_y = 108, 87
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_swamp_thing_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 200
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(40, 0)
tt.health.hp_max = 3000
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 69)
tt.info.i18n_key = "ENEMY_SWAMP_THING"
tt.info.enc_icon = 44
tt.info.portrait = "bottom_info_image_enemies_0029"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 100
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.motion.max_speed = 0.6 * FPS
tt.ranged.attacks[1].bullet = "bomb_swamp_thing"
tt.ranged.attacks[1].bullet_start_offset = {
	v(adx(66), ady(86))
}
tt.ranged.attacks[1].cooldown = 1 + fts(32)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 110
tt.ranged.attacks[1].shoot_time = fts(13)
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_swamp_thing"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = v(50, 54)
tt.ui.click_rect.pos.x = -25
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 30)
tt.unit.mod_offset = v(0, 24)
tt.unit.size = UNIT_SIZE_LARGE

tt = RT("enemy_spider_rotten", "enemy_KR5")
AC(tt, "melee", "timed_attacks")
anchor_x, anchor_y = 0.5, 0.20967741935483872
image_x, image_y = 82, 62
tt.enemy.gold = 40
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(34, 0)
tt.health.hp_max = 1000
tt.health.magic_armor = 0.6
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 47)
tt.info.portrait = "bottom_info_image_enemies_0027"
tt.info.i18n_key = "ENEMY_SPIDER_ROTTEN"
tt.info.enc_icon = 42
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.enemy_spider_big.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider_rotten"
tt.sound_events.death = "DeathEplosion"
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].bullet = "enemy_spider_rotten_egg"
tt.timed_attacks.list[1].max_cooldown = 10
tt.timed_attacks.list[1].max_count = 6
tt.timed_attacks.list[1].min_cooldown = 5
tt.ui.click_rect.size = v(44, 40)
tt.ui.click_rect.pos = v(-22, -1)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = v(0, 15)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(40), ady(28))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_POISON, F_SKELETON)

tt = RT("enemy_spider_rotten_tiny", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.1875
image_x, image_y = 42, 32
tt.enemy.gold = 0
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = 80
tt.health.magic_armor = 0.3
tt.health_bar.offset = v(0, 20)
tt.info.portrait = "bottom_info_image_enemies_0028"
tt.info.i18n_key = "ENEMY_SPIDERTINY_ROTTEN"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider_rotten_tiny"
tt.sound_events.death = "DeathEplosionShortA"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, ady(5))
tt.unit.mod_offset = v(adx(1), ady(14))
tt.unit.mod_offset = v(adx(18), ady(13))
tt.vis.bans = bor(F_POISON, F_SKELETON)

tt = RT("enemy_rotten_tree", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.18421052631578946
image_x, image_y = 82, 76
tt.enemy.gold = 60
tt.enemy.melee_slot = v(25, 0)
tt.health.armor = 0.8
tt.health.hp_max = 1000
tt.health_bar.offset = v(0, 57)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_ROTTEN_TREE"
tt.info.enc_icon = 43
tt.info.portrait = "bottom_info_image_enemies_0030"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(11)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_rotten_tree"
tt.sound_events.death = "DeathSkeleton"
tt.ui.click_rect.size = v(44, 40)
tt.ui.click_rect.pos = v(-22, -1)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.show_blood_pool = false

tt = RT("enemy_giant_rat", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.275
image_x, image_y = 64, 40
tt.enemy.gold = 10
tt.enemy.melee_slot = v(26, 0)
tt.health.hp_max = 100
tt.health_bar.offset = v(0, 26)
tt.info.i18n_key = "ENEMY_GIANT_RAT"
-- tt.info.enc_icon = 61
tt.info.portrait = "bottom_info_image_enemies_0053"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].mod = "mod_poison_giant_rat"
tt.melee.attacks[1].sound_hit = "EnemyBlackburnGiantRat"
tt.melee.attacks[1].sound_hit_args = {
	chance = 0.1
}
tt.motion.max_speed = 1.3950892857142858 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_giant_rat"
tt.sound_events.death = nil
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 13)

tt = RT("enemy_wererat", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.17647058823529413
image_x, image_y = 94, 68
tt.enemy.gold = 25
tt.enemy.melee_slot = v(26, 0)
tt.health.armor = 0.3
tt.health.hp_max = 450
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 47)
tt.info.i18n_key = "ENEMY_WERERAT"
-- tt.info.enc_icon = 62
tt.info.portrait = "bottom_info_image_enemies_0054"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 35
tt.melee.attacks[1].damage_min = 25
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].mod = "mod_wererat_poison"
tt.motion.max_speed = 1.6622340425531914 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_wererat"
tt.sound_events.death = nil
tt.ui.click_rect.size = v(32, 40)
tt.ui.click_rect.pos = v(-16, -1)
tt.unit.hit_offset = v(0, 20)
tt.unit.marker_offset = v(0, 2)
tt.unit.mod_offset = v(0, 22)
tt.unit.size = UNIT_SIZE_MEDIUM

tt = RT("enemy_skeleton", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.2
image_x, image_y = 50, 38
tt.enemy.gold = 2
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 120
tt.health_bar.offset = v(0, 30)
tt.info.i18n_key = "ENEMY_SKELETON"
-- tt.info.enc_icon = 27
tt.info.portrait = "gui_bottom_info_image_soldiers_0018"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_skeleton"
tt.sound_events.death = "DeathSkeleton"
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(adx(25), ady(17))
tt.vis.bans = bor(F_SKELETON, F_POISON, F_POLYMORPH)
tt.unit.show_blood_pool = false

tt = RT("enemy_skeleton_big", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.2
image_x, image_y = 58, 50
tt.enemy.gold = 10
tt.enemy.melee_slot = v(23, 0)
tt.health.armor = 0.3
tt.health.hp_max = 400
tt.health_bar.offset = v(0, 39)
tt.info.portrait = "bottom_info_image_enemies_0044"
tt.info.i18n_key = "ENEMY_SKELETON_BIG"
-- tt.info.enc_icon = 28
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_skeleton_big"
tt.sound_events.death = "DeathSkeleton"
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 18)
tt.unit.mod_offset = v(adx(30), ady(22))
tt.vis.bans = bor(F_SKELETON, F_POISON, F_POLYMORPH)
tt.unit.show_blood_pool = false

tt = RT("enemy_zombie", "enemy_KR5")
AC(tt, "melee")
anchor_x, anchor_y = 0.5, 0.22
image_x, image_y = 42, 48
tt.enemy.gold = 10
tt.enemy.melee_slot = v(18, 0)
tt.health.armor = 0.4
tt.health.hp_max = 250
tt.health_bar.offset = v(0, 35)
tt.info.i18n_key = "ENEMY_ZOMBIE"
tt.info.enc_icon = 41
tt.info.portrait = "bottom_info_image_enemies_0031"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 15
tt.melee.attacks[1].damage_min = 5
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.5 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_zombie"
tt.render.sprites[1].name = "raise"
tt.sound_events.death = "DeathSkeleton"
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(adx(23), ady(20))
tt.vis.bans = bor(F_SKELETON, F_POISON, F_POLYMORPH)
tt.unit.show_blood_pool = false
tt = RT("enemy_demon_flareon", "enemy_KR5")

AC(tt, "melee", "ranged", "death_spawns")

anchor_x, anchor_y = 0.5, 0.16666666666666666
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_flareon_death"
tt.enemy.gold = 20
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 250
tt.health.magic_armor = 0.8
tt.health_bar.offset.y = 34
tt.info.i18n_key = "ENEMY_DEMON_FLAREON"
tt.info.enc_icon = 54
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0076" or "info_portraits_sc_0076"
tt.main_script.insert = kr1_scripts.enemy_base_portal.insert
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.2 * FPS
tt.ranged.attacks[1].bullet = "flare_flareon"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 25)
}
tt.ranged.attacks[1].cooldown = 3 + fts(36)
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(9)
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_flareon"
tt.render.sprites[1].offset.y = 1
tt.sound_events.death = "DeathPuff"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 12)
tt.unit.show_blood_pool = false
tt = RT("enemy_demon_legion", "enemy_KR5")

AC(tt, "melee", "timed_attacks", "death_spawns")

image_x, image_y = 106, 86
anchor_x, anchor_y = 0.5, 0.1511627906976744
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_death"
tt.enemy.gold = 60
tt.enemy.melee_slot = v(23, 0)
tt.health.armor = 0.8
tt.health.hp_max = 666
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset.y = 42
tt.info.i18n_key = "ENEMY_DEMON_LEGION"
tt.info.enc_icon = 56
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0077" or "info_portraits_sc_0077"
tt.main_script.insert = kr1_scripts.enemy_base_portal.insert
tt.main_script.update = kr1_scripts.enemy_demon_legion.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_legion"
tt.sound_events.death = "DeathPuff"
tt.timed_attacks.list[1] = E:clone_c("spawn_attack")
tt.timed_attacks.list[1].spawn_time = fts(5)
tt.timed_attacks.list[1].clone_time = fts(31)
tt.timed_attacks.list[1].generation = 2
tt.timed_attacks.list[1].animation = "summon"
tt.timed_attacks.list[1].spawn_animation = "spawn"
tt.timed_attacks.list[1].entity = "enemy_demon_legion"
tt.timed_attacks.list[1].cooldown = 15
tt.timed_attacks.list[1].cooldown_after = 10
tt.timed_attacks.list[1].spawn_offset_nodes = {
	5,
	10
}
tt.timed_attacks.list[1].nodes_limit = 20
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 12)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt = RT("enemy_demon_gulaemon", "enemy_KR5")

AC(tt, "melee", "timed_actions", "death_spawns")

anchor_x, anchor_y = 0.5, 0.21296296296296297
image_x, image_y = 108, 108
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_gulaemon_death"
tt.enemy.gold = 80
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = 2500
tt.health.magic_armor = 0.6
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset.y = 68
tt.info.i18n_key = "ENEMY_DEMON_GULAEMON"
tt.info.enc_icon = 53
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0078" or "info_portraits_sc_0078"
tt.main_script.insert = kr1_scripts.enemy_base_portal.insert
tt.main_script.update = kr1_scripts.enemy_demon_gulaemon.update
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 80
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix_ground = "enemy_demon_gulaemon"
tt.render.sprites[1].prefix_air = "enemy_demon_gulaemon_fly"
tt.render.sprites[1].prefix = tt.render.sprites[1].prefix_ground
tt.render.sprites[1].angles.takeoff = {
	"initFlyRightLeft",
	"initFlyUp",
	"initFlyDown"
}
tt.render.sprites[1].angles.land = {
	"endFlyRightLeft",
	"endFlyUp",
	"endFlyDown"
}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "Inferno_FatDemon_0178"
tt.render.sprites[2].offset = v(0.5, 30)
tt.render.sprites[2].z = Z_DECALS
tt.sound_events.death = "DeathPuff"
tt.timed_actions.list[1] = CC("mod_attack")
tt.timed_actions.list[1].cooldown = 15
tt.timed_actions.list[1].charge_time = fts(3)
tt.timed_actions.list[1].mod = "mod_gulaemon_fly"
tt.timed_actions.list[1].nodes_limit_start = 20
tt.timed_actions.list[1].off_health_bar_y = 17
tt.timed_actions.list[1].off_click_rect_y = 24
tt.timed_actions.list[1].off_mod_offset_y = 23
tt.timed_actions.list[1].off_hit_offset_y = 23
tt.timed_actions.list[1].flags_air = bor(F_FLYING)
tt.timed_actions.list[1].bans_air = bor(F_BLOCK, F_THORN)
tt.ui.click_rect = r(-20, 0, 40, 56)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 30)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM

tt = RT("enemy_necromancer", "enemy_KR5")
AC(tt, "melee", "ranged", "timed_actions")
anchor_x, anchor_y = 0.5, 0.2
image_x, image_y = 44, 38
tt.enemy.gold = 50
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 700
tt.health_bar.offset = v(0, 30)
tt.info.i18n_key = "ENEMY_NECROMANCER"
tt.info.enc_icon = 29
tt.info.portrait = "bottom_info_image_enemies_0043"
tt.main_script.update = kr1_scripts.enemy_necromancer.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(10)
tt.motion.max_speed = 0.6 * FPS
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].bullet = "kr1_bolt_necromancer"
tt.ranged.attacks[1].bullet_start_offset = {
	v(-8, 22)
}
tt.ranged.attacks[1].cooldown = 1 + fts(23)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 145
tt.ranged.attacks[1].min_range = 60
tt.ranged.attacks[1].shoot_time = fts(9)
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_necromancer"
tt.sound_events.death = "DeathPuff"
tt.timed_actions.list[1] = E:clone_c("spawn_attack")
tt.timed_actions.list[1].cooldown = 8
tt.timed_actions.list[1].spawn_time = fts(12)
tt.timed_actions.list[1].spawn_delay = fts(4)
tt.timed_actions.list[1].entity_chances = {
	0.05,
	1
}
tt.timed_actions.list[1].entity_names = {
	"enemy_skeleton_big",
	"enemy_skeleton"
}
tt.timed_actions.list[1].animation = "summon"
tt.timed_actions.list[1].spawn_animation = "raise"
tt.timed_actions.list[1].max_count = 5
tt.timed_actions.list[1].count_group_name = "necromancer_skeletons"
tt.timed_actions.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_actions.list[1].count_group_max = 35
tt.timed_actions.list[1].summon_offsets = {
	{
		2,
		0,
		0
	},
	{
		3,
		0,
		0
	},
	{
		1,
		3,
		8
	},
	{
		2,
		3,
		8
	},
	{
		3,
		3,
		8
	},
	{
		1,
		-3,
		-8
	},
	{
		2,
		-3,
		-8
	},
	{
		3,
		-3,
		-8
	}
}
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(adx(23), ady(17))
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)

tt = RT("enemy_skeleton_blackburn", "enemy_skeleton")
tt = RT("enemy_zombie_blackburn", "enemy_halloween_zombie")
tt = RT("enemy_skeleton_warrior", "enemy_skeleton_big")
tt = RT("enemy_demon_cerberus", "enemy_KR5")

AC(tt, "melee", "death_spawns")

anchor_x, anchor_y = 0.5, 0.14285714285714285
image_x, image_y = 128, 70
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_cerberus_death"
tt.death_spawns.delay = 0.11
tt.enemy.gold = 350
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(41, 0)
tt.health.armor = 0.8
tt.health.hp_max = 6000
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 57)
tt.info.i18n_key = "ENEMY_DEMON_CERBERUS"
tt.info.enc_icon = 55
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0079" or "info_portraits_sc_0079"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.enemy_demon_cerberus.update
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 90
tt.melee.attacks[1].damage_min = 70
tt.melee.attacks[1].damage_radius = 57.6
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].dodge_time = fts(7)
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].hit_offset = v(20, 0)
tt.motion.max_speed = 1.3 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_cerberus"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.ui.click_rect.size = v(45, 43)
tt.ui.click_rect.pos = v(-22.5, 2)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 25)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_STUN, F_TELEPORT, F_THORN, F_POLYMORPH, F_DISINTEGRATED, F_INSTAKILL)
tt.vis.flags = bor(F_ENEMY, F_BOSS, F_MINIBOSS)

tt = RT("enemy_witch", "enemy_KR5")
AC(tt, "ranged")
anchor_x, anchor_y = 0.5, 0.05319148936170213
image_x, image_y = 88, 94
tt.enemy.gold = 80
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(26, 0)
tt.health.hp_max = 600
tt.health.magic_armor = 0.9
tt.health_bar.offset = v(0, 72)
tt.info.i18n_key = "ENEMY_WITCH"
-- tt.info.enc_icon = 66
tt.info.portrait = "bottom_info_image_enemies_0055"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.enemy_mixed.update
tt.motion.max_speed = 1.4960106382978726 * FPS
tt.ranged.attacks[1].bullet = "bolt_witch"
tt.ranged.attacks[1].bullet_start_offset = {
	v(13, 45)
}
tt.ranged.attacks[1].cooldown = fts(60) + fts(34)
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].max_range = 319.1489361702128
tt.ranged.attacks[1].min_range = 35.46099290780142
tt.ranged.attacks[1].shoot_time = fts(23)
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_witch"
tt.sound_events.death = "EnemyBlackburnWitchDeath"
tt.sound_events.insert = "EnemyBlackburnWitch"
tt.ui.click_rect = r(-14, 30, 30, 32)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 45)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 47)
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_THORN)
tt.vis.flags = bor(F_ENEMY, F_FLYING)

tt = RT("enemy_spectral_knight", "enemy_KR5")
AC(tt, "melee", "auras")
image_x, image_y = 128, 94
anchor_x, anchor_y = 0.5, 0.1595744680851064
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].cooldown = 0
tt.auras.list[1].name = "aura_spectral_knight"
tt.enemy.gold = 40
tt.enemy.melee_slot = v(26, 0)
tt.health.armor = 1
tt.health.hp_max = 500
tt.health.immune_to = bor(DAMAGE_PHYSICAL, DAMAGE_EXPLOSION, DAMAGE_ELECTRICAL, DAMAGE_POISON)
tt.health_bar.offset = v(0, 61)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_SPECTRAL_KNIGHT"
-- tt.info.enc_icon = 64
tt.info.portrait = "bottom_info_image_enemies_0052"
tt.main_script.insert = kr1_scripts.enemy_spectral_knight.insert
tt.main_script.update = kr1_scripts.enemy_spectral_knight.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 76
tt.melee.attacks[1].damage_min = 24
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 0.775709219858156 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spectral_knight"
tt.sound_events.death = nil
tt.sound_events.insert = "CBSpectralKnight"
tt.sound_events.insert_args = {
	delay = 0.5
}
tt.ui.click_rect = r(-20, 0, 40, 45)
tt.unit.blood_color = BLOOD_NONE
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 20)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 21)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_THORN, F_POLYMORPH, F_STUN, F_SKELETON, F_BLOOD, F_POISON)
tt.vis.flags = bor(F_ENEMY)

tt = RT("enemy_spectral_knight_spawn", "enemy_spectral_knight")
tt.enemy.gold = 0

tt = RT("enemy_fallen_knight", "enemy_KR5")
AC(tt, "melee", "death_spawns")
anchor_x, anchor_y = 0.5, 0.1595744680851064
image_x, image_y = 128, 94
tt.death_spawns.name = "enemy_spectral_knight_spawn"
tt.death_spawns.spawn_animation = "raise"
tt.death_spawns.delay = fts(11)
tt.enemy.gold = 40
tt.enemy.melee_slot = v(26, 0)
tt.health.dead_lifetime = 1
tt.health.hp_max = 1000
tt.health.magic_armor = 1
tt.health_bar.offset = v(0, 56)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_FALLEN_KNIGHT"
-- tt.info.enc_icon = 63
tt.info.portrait = "bottom_info_image_enemies_0051"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 76
tt.melee.attacks[1].damage_min = 24
tt.melee.attacks[1].hit_time = fts(13)
tt.motion.max_speed = 0.44326241134751776 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_fallen_knight"
tt.sound_events.death = nil
tt.sound_events.death_by_explosion = nil
tt.ui.click_rect = r(-15, 0, 30, 45)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 20)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 19)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM

tt = RT("enemy_troll_skater", "enemy_KR5")

AC(tt, "melee", "auras")

anchor_x, anchor_y = 0.5, 0.18
image_x, image_y = 82, 50
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_troll_skater_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 30
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 350
tt.info.i18n_key = "ENEMY_TROLL_SKATER"
tt.info.enc_icon = 50
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0073" or "info_portraits_sc_0073"
tt.main_script.update = kr1_scripts.enemy_troll_skater.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 70
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll_skater"
tt.sound_events.death = "DeathTroll"
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 13)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 13)
tt.skate = {}
tt.skate.mod = "mod_troll_skater"
tt.skate.vis_bans_extra = bor(F_BLOCK)
tt.skate.prefix = "enemy_troll"
tt.skate.walk_angles = {
	"skateRightLeft",
	"skateUp",
	"skateDown"
}
tt = RT("enemy_hobgoblin", "enemy_KR5")

AC(tt, "melee", "death_spawns")

anchor_x, anchor_y = 0.5, 0.17532467532467533
image_x, image_y = 224, 154
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "fx_coin_shower"
tt.death_spawns.offset = v(0, 60)
tt.enemy.gold = 250
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.hp_max = 2000
tt.health_bar.offset = v(0, 82)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.i18n_key = "ENEMY_ENDLESS_MINIBOSS_ORC"
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0094" or "info_portraits_sc_0094"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 90
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_hobgoblin_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_hobgoblin_ground_hit"
tt.melee.attacks[1].hit_offset = v(72, -9)
tt.melee.attacks[1].hit_time = fts(24)
tt.melee.attacks[1].sound = "AreaAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(24)
}
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_hobgoblin"
tt.sound_events.death = "DeathJuggernaut"
tt.ui.click_rect = r(-30, 0, 60, 70)
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 34)
tt.unit.mod_offset = v(0, 34)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH, F_DISINTEGRATED, F_INSTAKILL)
tt.vis.flags = bor(F_ENEMY, F_BOSS, F_MINIBOSS)
tt = RT("eb_juggernaut", "boss")

AC(tt, "melee", "timed_attacks")

anchor_x, anchor_y = 0.5, 0.08
image_x, image_y = 144, 128
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.dead_lifetime = 10
tt.health.hp_max = 10000
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.offset = v(0, ady(120))
tt.info.fn = kr1_scripts.eb_juggernaut.get_info
tt.info.i18n_key = "ENEMY_JUGGERNAUT"
tt.info.enc_icon = 32
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0027" or "info_portraits_sc_0027"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.eb_juggernaut.update
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.08)
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.render.sprites[1].prefix = "eb_juggernaut"
tt.sound_events.death = "DeathJuggernaut"
tt.sound_events.insert = "KR1_MusicBossFight"
tt.ui.click_rect = r(-35, 0, 70, 80)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.hit_offset = v(0, ady(50))
tt.unit.mod_offset = v(adx(70), ady(50))
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 250
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].hit_fx = "fx_juggernaut_smoke"
tt.melee.attacks[1].sound_hit = "juggernaut_punch"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "shoot"
tt.timed_attacks.list[1].bullet = "missile_juggernaut"
tt.timed_attacks.list[1].bullet_start_offset = v(-30, 82)
tt.timed_attacks.list[1].cooldown = 11
tt.timed_attacks.list[1].launch_vector = v(12, 170)
tt.timed_attacks.list[1].max_range = 99999
tt.timed_attacks.list[1].min_range = 100
tt.timed_attacks.list[1].shoot_time = fts(24)
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[2] = table.deepclone(tt.timed_attacks.list[1])
tt.timed_attacks.list[2].bullet = "bomb_juggernaut"
tt.timed_attacks.list[2].cooldown = 4
tt = RT("eb_jt", "boss")

AC(tt, "melee", "timed_attacks", "auras")

anchor_x, anchor_y = 0.5, 0.19
image_x, image_y = 260, 200
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "jt_spawner_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(55, 0)
tt.health.dead_lifetime = 100
tt.health.hp_max = 11000
tt.health.on_damage = kr1_scripts.eb_jt.on_damage
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.offset = v(0, ady(172))
tt.info.fn = kr1_scripts.eb_jt.get_info
tt.info.i18n_key = "ENEMY_YETI_BOSS"
tt.info.enc_icon = 33
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0047" or "info_portraits_sc_0047"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.eb_jt.update
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.08)
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.render.sprites[1].prefix = "eb_jt"
tt.tap_decal = "decal_jt_tap"
tt.tap_timeout = 1.5
tt.sound_events.death = "JtDeath"
tt.sound_events.death_explode = "JtExplode"
tt.sound_events.insert = "KR1_MusicBossFight"
tt.ui.click_rect = r(-38, 0, 76, 95)
tt.unit.hit_offset = v(0, 60)
tt.unit.marker_hidden = true
tt.unit.mod_offset = v(adx(130), ady(90))
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 5
tt.melee.attacks[1].damage_max = 200
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_EAT
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "JtEat"
tt.melee.attacks[1].sound_args = {
	delay = fts(6)
}
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].cooldown = 10 + fts(29)
tt.timed_attacks.list[1].count = 4
tt.timed_attacks.list[1].exhausted_duration = 4
tt.timed_attacks.list[1].exhausted_sound = "JtRest"
tt.timed_attacks.list[1].exhausted_sound_args = {
	delay = fts(34)
}
tt.timed_attacks.list[1].hit_decal = "decal_jt_ground_hit"
tt.timed_attacks.list[1].hit_offset = v(80, -10)
tt.timed_attacks.list[1].hit_time = fts(16)
tt.timed_attacks.list[1].max_range = 192
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].mod = "mod_jt_tower"
tt.timed_attacks.list[1].sound = "JtAttack"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(6)
}
tt = RT("eb_veznan", "boss")

AC(tt, "melee", "timed_attacks", "taunts")

anchor_x, anchor_y = 0.5, 0.17010309278350516
image_x, image_y = 214, 194
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = {
	5333,
	6666,
	7999
}
tt.health.on_damage = kr1_scripts.eb_veznan.on_damage
tt.health.ignore_damage = true
tt.health_bar.hidden = true
tt.health_bar.offset = v(0, 43)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.info.i18n_key = "ENEMY_VEZNAN"
tt.info.enc_icon = 34
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0056" or "info_portraits_sc_0056"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.eb_veznan.update
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_veznan"
tt.render.sprites[1].name = "idleDown"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.sound_events.death = "VeznanDeath"
tt.ui.click_rect = r(-11, -2, 22, 38)
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH, F_ALL)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.pos_castle = v(518, 677)
tt.souls_aura = "veznan_souls_aura"
tt.white_circle = "decal_eb_veznan_white_circle"
tt.taunts.animation = "laught"
tt.taunts.delay_min = fts(400)
tt.taunts.delay_max = fts(700)
tt.taunts.duration = 4
tt.taunts.decal_name = "decal_s12_shoutbox"
tt.taunts.offset = v(0, 0)
tt.taunts.pos = v(525, 608)
tt.taunts.sets.welcome = CC("taunt_set")
tt.taunts.sets.welcome.format = "VEZNAN_TAUNT_%04d"
tt.taunts.sets.welcome.end_idx = 5
tt.taunts.sets.welcome.delays = {
	fts(60),
	fts(140),
	fts(450),
	fts(250)
}
tt.taunts.sets.castle = CC("taunt_set")
tt.taunts.sets.castle.format = "VEZNAN_TAUNT_%04d"
tt.taunts.sets.castle.start_idx = 6
tt.taunts.sets.castle.end_idx = 25
tt.taunts.sets.damage = CC("taunt_set")
tt.taunts.sets.damage.format = "VEZNAN_TAUNT_%04d"
tt.taunts.sets.damage.start_idx = 26
tt.taunts.sets.damage.end_idx = 29
tt.taunts.sets.pre_battle = CC("taunt_set")
tt.taunts.sets.pre_battle.format = "VEZNAN_TAUNT_%04d"
tt.taunts.sets.pre_battle.start_idx = 30
tt.taunts.sets.pre_battle.end_idx = 30
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 8
tt.melee.attacks[1].damage_min = 666
tt.melee.attacks[1].damage_max = 999
tt.melee.attacks[1].damage_radius = 75
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_offset = v(-10, -2)
tt.melee.attacks[1].hit_time = fts(17)
tt.melee.attacks[1].hit_decal = "decal_veznan_strike"
tt.melee.attacks[1].sound_hit = "VeznanAttack"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].cooldown = 2.5
tt.melee.attacks[2].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_decal = nil
tt.melee.attacks[2].hit_fx = "fx_veznan_demon_fire"
tt.melee.attacks[2].hit_fx_offset = v(20, 9)
tt.melee.attacks[2].hit_fx_once = true
tt.melee.attacks[2].hit_fx_flip = true
tt.melee.attacks[2].hit_times = {
	fts(20),
	fts(24),
	fts(28),
	fts(32),
	fts(36),
	fts(38),
	fts(42),
	fts(44)
}
tt.melee.attacks[2].hit_offset = v(40, 0)
tt.melee.attacks[2].sound_hit = nil
tt.melee.attacks[2].sound = "VeznanDemonFire"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].cooldown = 13
tt.timed_attacks.list[1].animation = "spellDown"
tt.timed_attacks.list[1].hit_time = fts(14)
tt.timed_attacks.list[1].mod = "mod_veznan_tower"
tt.timed_attacks.list[1].sound = "VeznanHoldCast"
tt.timed_attacks.list[1].attack_duration = fts(44)
tt.timed_attacks.list[1].data = {
	[9] = {
		13,
		2
	},
	[10] = {
		13,
		3
	},
	[11] = {
		14,
		4
	},
	[12] = {
		14,
		5
	},
	[13] = {
		16,
		6
	},
	[14] = {
		16,
		7
	},
	[15] = {
		18,
		8
	}
}
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "spellDown"
tt.timed_attacks.list[2].cooldown = 15
tt.timed_attacks.list[2].hit_time = fts(14)
tt.timed_attacks.list[2].portal_name = "veznan_portal"
tt.timed_attacks.list[2].sound = "VeznanPortalSummon"
tt.timed_attacks.list[2].attack_duration = fts(44)
tt.timed_attacks.list[2].data = {
	[6] = {
		15,
		3,
		{
			1,
			0,
			0
		}
	},
	[7] = {
		10,
		2,
		{
			1,
			0,
			0
		}
	},
	[8] = {
		20,
		3,
		{
			0,
			1,
			0
		}
	},
	[9] = {
		15,
		3,
		{
			1,
			0,
			0
		}
	},
	[10] = {
		20,
		3,
		{
			1,
			1,
			0
		}
	},
	[11] = {
		15,
		3,
		{
			1,
			1,
			0
		}
	},
	[12] = {
		15,
		3,
		{
			1,
			1,
			0
		}
	},
	[13] = {
		15,
		3,
		{
			0,
			0,
			1
		}
	},
	[14] = {
		15,
		3,
		{
			1,
			1,
			1
		}
	},
	[15] = {
		15,
		3,
		{
			1,
			1,
			1
		}
	}
}
tt.battle = {}
tt.battle.ba_animation = "spell"
tt.battle.pa_animation = "spell"
tt.battle.pa_cooldown = 10
tt.battle.pa_max_count = 40
tt.demon = {}
tt.demon.health_bar_offset = v(0, 118)
tt.demon.health_bar_scale = 1.8
tt.demon.melee_slot = v(50, 0)
tt.demon.speed = 0.6 * FPS
tt.demon.sprites_prefix = "eb_veznan_demon"
tt.demon.transform_sound = "VeznanToDemon"
tt.demon.ui_click_rect = r(-25, -5, 50, 110)
tt.demon.unit_hit_offset = v(0, 55)
tt.demon.unit_mod_offset = v(0, 45)
tt.demon.unit_size = UNIT_SIZE_LARGE
tt.demon.info_portrait = IS_PHONE_OR_TABLET and "portraits_sc_0056" or "info_portraits_sc_0093"
tt = RT("eb_sarelgaz", "boss")

AC(tt, "melee")

anchor_x, anchor_y = 0.5, 0.1484375
image_x, image_y = 220, 128
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(80, 0)
tt.health.dead_lifetime = 8
tt.health.hp_max = 18000
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.offset = v(0, 108)
tt.info.i18n_key = "ENEMY_SARELGAZ"
tt.info.enc_icon = 35
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0057" or "info_portraits_sc_0057"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 500
tt.melee.attacks[1].damage_min = 300
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].damage_type = DAMAGE_EAT
tt.melee.attacks[1].sound = "SpiderAttack"
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_sarelgaz"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.sound_events.death = "DeathEplosion"
tt.sound_events.insert = "KR1_MusicBossFight"
tt.ui.click_rect = r(-45, 0, 90, 80)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.can_explode = false
tt.unit.can_disintegrate = false
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = v(0, 45)
tt.unit.marker_hidden = true
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 45)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt = RT("eb_gulthak", "boss")

AC(tt, "melee", "timed_attacks")

anchor_x, anchor_y = 0.5, 0.11
tt.enemy.gold = 0
image_x, image_y = 340, 196
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(60, 0)
tt.health.dead_lifetime = 8
tt.health.hp_max = 12000
tt.health_bar.offset = v(0, 95)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.i18n_key = "ENEMY_BOSS_GOBLIN_CHIEFTAIN"
tt.info.enc_icon = 40
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0063" or "info_portraits_sc_0063"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.enemy_shaman.update
tt.melee.attacks[1].cooldown = 1 + fts(20)
tt.melee.attacks[1].damage_max = 600
tt.melee.attacks[1].damage_min = 200
tt.melee.attacks[1].hit_time = fts(11)
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_gulthak"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles_flip_vertical = {
	walk = true
}
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.sound_events.death = "DeathBig"
tt.sound_events.insert = "KR1_MusicBossFight"
tt.ui.click_rect = r(-50, 0, 90, 60)
tt.unit.can_explode = false
tt.unit.can_disintegrate = false
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = v(0, 30)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 27)
tt.unit.marker_hidden = true
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "heal"
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = 8
tt.timed_attacks.list[1].max_count = 20
tt.timed_attacks.list[1].max_range = 320
tt.timed_attacks.list[1].mod = "mod_gulthak_heal"
tt.timed_attacks.list[1].sound = "EnemyHealing"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)

tt = RT("eb_greenmuck", "boss")
AC(tt, "melee", "timed_attacks")
anchor_x, anchor_y = 0.5, 0.1402439024390244
image_x, image_y = 244, 232
tt.enemy.gold = 0
tt.enemy.lives_cost = 999
tt.enemy.melee_slot = v(40, 0)
tt.health.dead_lifetime = 8
tt.health.armor = 0.8
tt.health.hp_max = 10000
tt.health_bar.offset = v(0, 135)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = kr1_scripts.eb_greenmuck.get_info
tt.info.i18n_key = "ENEMY_ROTTEN_TREE_BOSS"
tt.info.enc_icon = 45
tt.info.portrait = "bottom_info_image_enemies_0050"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.eb_greenmuck.update
tt.motion.max_speed = 0.3 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_greenmuck"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.sound_events.death = nil
tt.sound_events.insert = "KR1_MusicBossFight"
tt.ui.click_rect = r(-30, 0, 60, 110)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = v(0, 37)
tt.unit.marker_offset = v(0, -10)
tt.unit.marker_hidden = true
tt.unit.mod_offset = v(0, 37)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH, F_EAT, F_DISINTEGRATED, F_INSTAKILL, F_STUN)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 250
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].damage_radius = 60
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "shoot"
tt.timed_attacks.list[1].bullet = "bomb_greenmuck"
tt.timed_attacks.list[1].count = 7
tt.timed_attacks.list[1].bullet_start_offset = v(0, 120)
tt.timed_attacks.list[1].cooldown = 6
tt.timed_attacks.list[1].shoot_time = fts(13)
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].vis_bans = F_ENEMY

tt = RT("eb_kingpin", "enemy_KR5")
AC(tt, "melee", "timed_attacks", "auras")
anchor_x, anchor_y = 0.5, 0.13
image_x, image_y = 218, 204
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "kingpin_damage_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(60, 0)
tt.health.dead_lifetime = 12
tt.health.hp_max = 8000
tt.health_bar.offset = v(0, 125)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = kr1_scripts.eb_kingpin.get_info
tt.info.i18n_key = "ENEMY_BOSS_BANDIT"
tt.info.enc_icon = 48
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0072" or "info_portraits_sc_0072"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.eb_kingpin.update
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.13)
tt.render.sprites[1].prefix = "eb_kingpin"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.sound_events.death = "DeathJuggernaut"
tt.sound_events.insert = "KR1_MusicBossFight"
tt.stop_time = 5
tt.stop_cooldown = 5
tt.stop_wait = fts(25)
tt.ui.click_rect = r(-50, 0, 100, 75)
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = v(0, 80)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 82)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH, F_BLOCK)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1 + fts(20)
tt.melee.attacks[1].damage_max = 100
tt.melee.attacks[1].damage_min = 100
tt.melee.attacks[1].damage_radius = 65
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].hit_fx = "fx_juggernaut_smoke"
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "eat"
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].max_count = 1
tt.timed_attacks.list[1].max_range = 320
tt.timed_attacks.list[1].mod = "mod_kingpin_heal_self"
tt.timed_attacks.list[1].sound = "EnemyHealing"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.timed_attacks.list[2] = table.deepclone(tt.timed_attacks.list[1])
tt.timed_attacks.list[2].animation = "heal"
tt.timed_attacks.list[2].max_count = 9999
tt.timed_attacks.list[2].max_range = 100
tt.timed_attacks.list[2].mod = "mod_kingpin_heal_others"
tt = RT("eb_ulgukhai", "boss")

AC(tt, "melee", "auras")

anchor_x, anchor_y = 0.5, 0.1792452830188679
image_x, image_y = 240, 150
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_ulgukhai_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.dead_lifetime = 12
tt.health.hp_max = 10000
tt.health_bar.offset = v(0, 90)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = kr1_scripts.eb_ulgukhai.get_info
tt.info.i18n_key = "ENEMY_TROLL_BOSS"
tt.info.enc_icon = 52
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0075" or "info_portraits_sc_0075"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.eb_ulgukhai.update
tt.motion.max_speed = 0.3 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_ulgukhai"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.sound_events.death = "DeathBig"
tt.sound_events.insert = "KR1_MusicBossFight"
tt.unit.blood_color = BLOOD_GRAY
tt.ui.click_rect = r(-25, 5, 50, 65)
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = v(0, 30)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 26)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.shielded_extra_vis_bans = bor(F_MOD, F_POISON)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 3
tt.melee.attacks[1].damage_max = 350
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].damage_radius = 57.6
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(16)
tt.melee.attacks[1].hit_offset = v(60, 0)
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt = RT("eb_moloch", "boss")

AC(tt, "melee", "timed_attacks")

anchor_x, anchor_y = 0.5, 0.105
image_x, image_y = 282, 282
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(33, 0)
tt.health.dead_lifetime = 100
tt.health.ignore_damage = true
tt.health.hp_max = {
	8889,
	11111,
	13333
}
tt.health_bar.offset = v(0, 125)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.i18n_key = "ENEMY_DEMON_MOLOCH"
tt.info.enc_icon = 57
tt.info.fn = kr1_scripts.eb_moloch.get_info
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0080" or "info_portraits_sc_0080"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.eb_moloch.update
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_moloch"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.sound_events.death = "EnemyInfernoBossDeath"
tt.ui.click_rect = r(-25, 0, 50, 100)
tt.unit.hit_offset = v(0, 60)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 45)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_ALL)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.stand_up_wait_time = fts(14)
tt.stand_up_sound = "KR1_MusicBossFight"
tt.pos_sitting = v(526, 614)
tt.nav_path.pi = 2
tt.nav_path.spi = 1
tt.nav_path.ni = 1
tt.wave_active = 16
tt.active_vis_bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1.5 + fts(25)
tt.melee.attacks[1].damage_max = 120
tt.melee.attacks[1].damage_min = 80
tt.melee.attacks[1].damage_radius = 40
tt.melee.attacks[1].count = nil
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].hit_fx = "fx_moloch_ring"
tt.melee.attacks[1].sound_hit = "EnemyInfernoStomp"
tt.timed_attacks.list[1] = CC("area_attack")
tt.timed_attacks.list[1].cooldown = 7
tt.timed_attacks.list[1].animation = "horn_attack"
tt.timed_attacks.list[1].damage_radius = 100
tt.timed_attacks.list[1].damage_type = DAMAGE_INSTAKILL
tt.timed_attacks.list[1].hit_time = fts(15)
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].fx_list = {
	{
		"fx_moloch_rocks",
		{
			{
				36,
				-30
			},
			{
				1,
				-10
			},
			{
				90,
				-23
			},
			{
				87,
				5
			},
			{
				49,
				-3
			},
			{
				54,
				17
			}
		}
	},
	{
		"fx_moloch_ring",
		{
			{
				45,
				0
			}
		}
	}
}
tt.timed_attacks.list[1].hit_offset = v(20, 0)
tt.timed_attacks.list[1].sound = "EnemyInfernoHorns"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(5)
}

tt = RT("eb_myconid", "boss")
AC(tt, "melee", "timed_attacks")
anchor_x, anchor_y = 0.5, 0.16428571428571428
image_x, image_y = 174, 140
tt.enemy.gold = 0
tt.enemy.lives_cost = 999
tt.enemy.melee_slot = v(40, 0)
tt.health.dead_lifetime = 12
tt.health.armor = 0.6
tt.health.magic_armor = 0.6
tt.health.hp_max = 4500
tt.health_bar.offset = v(0, 100)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = kr1_scripts.eb_myconid.get_info
tt.info.i18n_key = "ENEMY_ROTTEN_MYCONID"
-- tt.info.enc_icon = 59
tt.info.portrait = "bottom_info_image_enemies_0032"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.eb_myconid.update
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_myconid"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.sound_events.death = "EnemyMushroomBossDeath"
tt.sound_events.insert = "KR1_MusicBossFight"
tt.ui.click_rect = r(-25, 0, 50, 80)
tt.unit.fade_time_after_death = 4
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = v(0, 33)
tt.unit.mod_offset = v(0, 33)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH, F_EAT, F_DISINTEGRATED, F_INSTAKILL, F_STUN)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.spawner_entity = "myconid_spawner"
tt.on_death_spawn_count = 12
tt.on_death_spawn_wait = fts(40)
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 350
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].hit_time = fts(9)
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "spores"
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].final_wait = fts(20)
tt.timed_attacks.list[1].fx = "fx_myconid_spores"
tt.timed_attacks.list[1].fx_offset = v(0, 40)
tt.timed_attacks.list[1].min_nodes = 25
tt.timed_attacks.list[1].mod = "mod_myconid_poison"
tt.timed_attacks.list[1].radius = 110
tt.timed_attacks.list[1].sound = "EnemyMushroomGas"
tt.timed_attacks.list[1].summon_counts = {
	2,
	3,
	3,
	4,
	4,
	4,
	3,
	2
}
tt.timed_attacks.list[1].vis_bans = F_ENEMY
tt.timed_attacks.list[1].vis_flags = bor(F_MOD, F_POISON)
tt.timed_attacks.list[1].wait_times = {
	fts(15),
	fts(3),
	fts(6)
}

tt = RT("eb_blackburn", "boss")
AC(tt, "melee", "timed_attacks", "auras")
anchor_x, anchor_y = 0.5, 0.16993464052287582
image_x, image_y = 314, 308
tt.first_death = false
tt.first_death_duration = 3
tt.second_life = false
tt.second_life_hp_factor = 1.2
tt.second_life_armor = 0.35
tt.second_life_magic_armor = 0.75
tt.enemy.gold = 0
tt.enemy.lives_cost = 999
tt.enemy.melee_slot = v(40, 0)
tt.health.dead_lifetime = 100
tt.health.armor = 0.75
tt.health.hp_max = 9000
tt.health_bar.offset = v(0, 125)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = kr1_scripts.eb_blackburn.get_info
tt.info.i18n_key = "ENEMY_BOSS_BLACKBURN"
-- tt.info.enc_icon = 69
tt.info.portrait = "gui_bottom_info_image_soldiers_0044"
tt.health.on_damage = kr1_scripts.eb_blackburn.on_damage
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.eb_blackburn.update
tt.motion.max_speed = 0.5540780141843972 * FPS
tt.render.sprites[1].anchor = v(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_blackburn"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.sound_events.death = "EnemyBlackburnBossDeath"
tt.sound_events.insert = "KR1_MusicBossFight"
tt.ui.click_rect.pos.y = 9
tt.unit.hit_offset = v(adx(150), ady(115))
tt.unit.marker_offset = v(0, 11)
tt.unit.mod_offset = v(0, ady(115))
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH, F_STUN, F_EAT, F_DISINTEGRATED, F_INSTAKILL, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "blackburn_aura"
tt.auras.list[1].cooldown = 0
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1.3 + fts(40)
tt.melee.attacks[1].damage_max = 200
tt.melee.attacks[1].damage_min = 100
tt.melee.attacks[1].damage_radius = 63.829787234042556
tt.melee.attacks[1].dodge_time = fts(13)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound_hit = "EnemyBlackburnBossSwing"
tt.melee.attacks[1].vis_bans = bor(F_STUN)
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].after_hit_wait = fts(20)
tt.timed_attacks.list[1].animation = "smash"
tt.timed_attacks.list[1].aura_shake = "aura_screen_shake"
tt.timed_attacks.list[1].cooldown = fts(300)
tt.timed_attacks.list[1].after_cooldown = fts(150)
tt.timed_attacks.list[1].damage_max = 50
tt.timed_attacks.list[1].damage_min = 10
tt.timed_attacks.list[1].second_life_damage_max = 100
tt.timed_attacks.list[1].second_life_damage_min = 50
tt.timed_attacks.list[1].second_life_entity = "enemy_fallen_knight"
tt.timed_attacks.list[1].entity_node_offset = -5
tt.timed_attacks.list[1].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[1].damage_radius = 106.38297872340426
tt.timed_attacks.list[1].fx = "fx_blackburn_smash"
tt.timed_attacks.list[1].fx_offset = v(26, 7)
tt.timed_attacks.list[1].hit_decal = "decal_blackburn_smash_ground"
tt.timed_attacks.list[1].hit_time = fts(24)
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 283.68794326241135
tt.timed_attacks.list[1].mod = "mod_blackburn_stun"
tt.timed_attacks.list[1].mod_towers = "mod_blackburn_tower"
tt.timed_attacks.list[1].sound = "EnemyBlackburnBossSpecialStomp"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(13)
}
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)

tt = E:register_t("eb_elder_shaman", "decal_scripted")

E:add_comps(tt, "attacks")

tt.attacks.animation = "cast"
tt.attacks.delay = {
	0.6,
	0.9
}
tt.attacks.list[1] = E:clone_c("aura_attack")
tt.attacks.list[1].aura = "aura_elder_shaman_healing"
tt.attacks.list[1].node_offset = {
	10,
	30
}
tt.attacks.list[1].path_margins = {
	40,
	10
}
tt.attacks.list[1].power_name = "healing"
tt.attacks.list[1].vis_bans = bor(F_FLYING, F_BOSS, F_FRIEND)
tt.attacks.list[1].vis_flags = bor(F_MOD)
tt.attacks.list[2] = E:clone_c("aura_attack")
tt.attacks.list[2].aura = "aura_elder_shaman_damage"
tt.attacks.list[2].power_name = "damage"
tt.attacks.list[2].vis_bans = bor(F_FLYING, F_BOSS, F_ENEMY)
tt.attacks.list[2].vis_flags = bor(F_MOD)
tt.attacks.list[2].enemy_vis_bans = bor(F_FLYING, F_BOSS)
tt.attacks.list[2].enemy_vis_flags = bor(F_MOD)
tt.attacks.list[3] = E:clone_c("aura_attack")
tt.attacks.list[3].aura = "aura_elder_shaman_speed"
tt.attacks.list[3].node_offset = {
	10,
	30
}
tt.attacks.list[3].path_margins = {
	25,
	40
}
tt.attacks.list[3].power_name = "speed"
tt.attacks.list[3].vis_bans = bor(F_FLYING, F_BOSS, F_FRIEND)
tt.attacks.list[3].vis_flags = bor(F_MOD)
tt.main_script.update = kr1_scripts.eb_elder_shaman.update
tt.render.sprites[1].prefix = "eb_elder_shaman"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.09259259259259259
tt.taunt = {}
tt.taunt.delay_min = 15
tt.taunt.delay_max = 20
tt.taunt.duration = 4
tt.taunt.sets = {
	welcome = {},
	prebattle = {},
	battle = {},
	life_lost = {},
	totem = {}
}
tt.taunt.sets.welcome.format = "ENDLESS_BOSS_ORC_TAUNT_WELCOME_%04d"
tt.taunt.sets.welcome.start_idx = 1
tt.taunt.sets.welcome.end_idx = 2
tt.taunt.sets.prebattle.format = "ENDLESS_BOSS_ORC_TAUNT_PREBATTLE_%04d"
tt.taunt.sets.prebattle.start_idx = 1
tt.taunt.sets.prebattle.end_idx = 4
tt.taunt.sets.battle.format = "ENDLESS_BOSS_ORC_TAUNT_GENERIC_%04d"
tt.taunt.sets.battle.start_idx = 1
tt.taunt.sets.battle.end_idx = 9
tt.taunt.sets.life_lost.format = "ENDLESS_BOSS_ORC_TAUNT_LIFE_LOST_%04d"
tt.taunt.sets.life_lost.start_idx = 1
tt.taunt.sets.life_lost.end_idx = 1
tt.taunt.sets.totem.format = "ENDLESS_BOSS_ORC_TAUNT_TOTEM_%04d"
tt.taunt.sets.totem.start_idx = 1
tt.taunt.sets.totem.end_idx = 1
tt.taunt.offset = v(0, -75)
tt.taunt.ts = 0
tt.taunt.next_ts = 0
tt = RT("decal_elder_shaman_shoutbox", "decal_tween")

AC(tt, "texts")

tt.render.sprites[1].name = "HalloweenBoss_tauntBox"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = v(0, -9)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(172, 62)
tt.texts.list[1].font_name = "body_bold"
tt.texts.list[1].font_size = 20
tt.texts.list[1].color = {
	255,
	114,
	114
}
tt.texts.list[1].line_height = 0.8
tt.texts.list[1].sprite_id = 2
tt.texts.list[1].fit_height = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
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
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].loop = true
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].keys = {
	{
		0,
		0
	},
	{
		0.25,
		255
	}
}
tt.tween.props[3].sprite_id = 1
tt.tween.props[4] = table.deepclone(tt.tween.props[3])
tt.tween.props[4].sprite_id = 2
tt.tween.remove = false
tt = RT("spear_legionnaire", "arrow")
tt.bullet.damage_min = 24
tt.bullet.damage_max = 40
tt.bullet.flight_time = fts(20)
tt.bullet.miss_decal = "decal_spear"
tt.render.sprites[1].name = "spear"
tt.sound_events.insert = "AxeSound"
tt = RT("arrow_ranger", "arrow")
tt.bullet.damage_min = 13
tt.bullet.damage_max = 19
tt = RT("arrow_elf", "arrow")
tt.bullet.damage_min = 25
tt.bullet.damage_max = 50
tt.bullet.flight_time = fts(15)
tt = RT("arrow_shadow_archer", "arrow")
tt.bullet.damage_min = 20
tt.bullet.damage_max = 30
tt = RT("kr1_arrow_hero_alleria", "arrow")
tt.bullet.xp_gain_factor = 2.875
tt.bullet.prediction_error = false
tt = E:register_t("kr1_arrow_multishot_hero_alleria", "arrow")
tt.bullet.particles_name = "ps_arrow_multishot_hero_alleria"
tt.bullet.damage_min = 10
tt.bullet.damage_max = 15
tt.bullet.damage_true = DAMAGE_TRUE
tt.bullet.prediction_error = false
tt.extra_arrows_range = 100
tt.extra_arrows = 2
tt.main_script.insert = kr1_scripts.arrow_multishot_hero_alleria.insert
tt.render.sprites[1].name = "hero_archer_arrow"
tt = RT("axe_troll_axe_thrower", "arrow")
tt.bullet.damage_min = 40
tt.bullet.damage_max = 80
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.flight_time = fts(23)
tt.bullet.rotation_speed = 30 * FPS * math.pi / 180
tt.bullet.miss_decal = "troll_axethrower_proyectiles_0002"
tt.bullet.reset_to_target_pos = true
tt.render.sprites[1].name = "troll_axethrower_proyectiles_0001"
tt.render.sprites[1].animated = false
tt.bullet.pop = nil
tt.sound_events.insert = "AxeSound"
tt = RT("ball_raider", "arrow")
tt.bullet.damage_min = 80
tt.bullet.damage_max = 120
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.flight_time = fts(23)
tt.bullet.rotation_speed = 30 * FPS * math.pi / 180
tt.bullet.miss_decal = "RaiderBall_0002"
tt.bullet.reset_to_target_pos = true
tt.render.sprites[1].name = "RaiderBall_0001"
tt.render.sprites[1].animated = false
tt.bullet.pop = nil
tt.sound_events.insert = "AxeSound"
tt = RT("flare_flareon", "arrow")
tt.bullet.damage_max = 30
tt.bullet.damage_min = 20
tt.bullet.flight_time = fts(16)
tt.bullet.hit_blood_fx = nil
tt.bullet.miss_decal = nil
tt.bullet.miss_fx = "fx_explosion_flareon_flare"
tt.bullet.mod = "mod_flareon_burn"
tt.bullet.particles_name = "ps_flare_flareon"
tt.bullet.pop = nil
tt.render.sprites[1].name = "demon_flareon_flare"
tt.render.sprites[1].animated = true
tt = RT("bolt_sorcerer", "bolt")
tt.bullet.damage_max = 78
tt.bullet.damage_min = 42
tt.bullet.hit_fx = "fx_bolt_sorcerer_hit"
tt.bullet.max_speed = 600
tt.bullet.mods = {
	"mod_sorcerer_curse_dps",
	"mod_sorcerer_curse_armor"
}
tt.bullet.particles_name = "ps_bolt_sorcerer"
tt.bullet.pop = {
	"pop_zap_sorcerer"
}
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].prefix = "bolt_sorcerer"
tt.sound_events.insert = "BoltSorcererSound"
tt = RT("kr1_bolt_necromancer", "bolt_enemy")
tt.bullet.align_with_trajectory = true
tt.bullet.damage_max = 40
tt.bullet.damage_min = 20
tt.bullet.hit_fx = "kr1_fx_bolt_necromancer_hit"
tt.bullet.max_speed = 450
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].prefix = "bolt_necromancer"
tt.sound_events.insert = "BoltSorcererSound"
tt = RT("bolt_witch", "bolt_enemy")
tt.bullet.damage_max = 60
tt.bullet.damage_min = 40
tt.bullet.hit_fx = "fx_bolt_witch_hit"
tt.bullet.min_speed = 450
tt.bullet.max_speed = 750
tt.bullet.mod = "mod_witch_frog"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].prefix = "bolt_witch"
tt.sound_events.insert = "kr4_tower_wickedsisters_attack_v1"

tt = RT("bomb_bfg", "bomb")
tt.bullet.damage_max = 100
tt.bullet.damage_min = 50
tt.bullet.damage_radius = 67.5
tt.bullet.flight_time = fts(35)
tt.bullet.hit_fx = "fx_explosion_big"
tt.render.sprites[1].name = "bombs_0005"
tt.sound_events.hit_water = nil

tt = RT("bomb_goblin_zapper", "bomb")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 60
tt.bullet.damage_min = 30
tt.bullet.damage_radius = 67.5
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = "fx_explosion_fragment"
tt.bullet.pop = {
	"pop_kboom"
}
tt.main_script.insert = kr1_scripts.enemy_bomb.insert
tt.main_script.update = kr1_scripts.enemy_bomb.update
tt.render.sprites[1].name = "zapperbomb"
tt.sound_events.insert = nil
tt.sound_events.hit = "BombExplosionSound"
tt = RT("bomb_swamp_thing", "bomb")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 100
tt.bullet.damage_min = 40
tt.bullet.damage_radius = 67.5
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = "fx_explosion_rotten_shot"
tt.bullet.hit_decal = nil
tt.bullet.pop = nil
tt.main_script.insert = kr1_scripts.enemy_bomb.insert
tt.main_script.update = kr1_scripts.enemy_bomb.update
tt.render.sprites[1].name = "Proyectile_RottenShot"
tt.sound_events.insert = "swamp_thing_bomb_shot"
tt.sound_events.hit = "swamp_thing_bomb_explosion"
tt = RT("bomb_juggernaut", "bomb")
tt.bullet.damage_bans = F_ALL
tt.bullet.damage_flags = 0
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.damage_radius = 1
tt.bullet.flight_time_base = fts(45)
tt.bullet.flight_time_factor = fts(0.025)
tt.bullet.pop = nil
tt.bullet.hit_payload = "juggernaut_bomb_spawner"
tt.main_script.insert = kr1_scripts.enemy_bomb.insert
tt.main_script.update = kr1_scripts.enemy_bomb.update
tt.bullet.hit_fx = nil
tt.render.sprites[1].name = "bossJuggernaut_bomb_"
tt.sound_events.hit = "BombExplosionSound"
tt = RT("bomb_greenmuck", "bomb")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_max = 160
tt.bullet.damage_min = 80
tt.bullet.damage_radius = 47.25
tt.bullet.flight_time_base = fts(17)
tt.bullet.flight_time_factor = fts(0.07142857142857142)
tt.bullet.hit_fx = "fx_explosion_rotten_shot"
tt.bullet.hit_decal = nil
tt.bullet.pop = nil
tt.main_script.insert = kr1_scripts.enemy_bomb.insert
tt.main_script.update = kr1_scripts.enemy_bomb.update
tt.render.sprites[1].name = "Proyectile_RottenBoss"
tt.sound_events.hit = "swamp_thing_bomb_explosion"

tt = RT("missile_juggernaut", "bullet")
tt.bullet.acceleration_factor = 0.1
tt.bullet.damage_bans = bor(F_ENEMY, F_BOSS)
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 250
tt.bullet.damage_min = 150
tt.bullet.damage_radius = 41.25
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.hit_fx = "fx_explosion_air"
tt.bullet.hit_fx_air = "fx_explosion_air"
tt.bullet.max_speed = 450
tt.bullet.min_speed = 300
tt.bullet.particles_name = "ps_missile"
tt.bullet.retarget_range = 99999
tt.bullet.rot_dir_from_long_angle = true
tt.bullet.turn_speed = 10 * math.pi / 180 * 30
tt.bullet.vis_bans = bor(F_ENEMY)
tt.bullet.vis_flags = F_RANGED
tt.main_script.update = kr1_scripts.enemy_missile.update
tt.render.sprites[1].prefix = "missile_bfg"
tt.render.sprites[1].name = "flying"
tt.sound_events.insert = "RocketLaunchSound"
tt.sound_events.hit = "BombExplosionSound"
tt = RT("ray_arcane", "bullet")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.mod = "mod_ray_arcane"
tt.bullet.hit_time = 0
tt.image_width = 150
tt.main_script.update = kr1_scripts.ray_simple.update
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].name = "ray_arcane"
tt.render.sprites[1].loop = true
tt.sound_events.insert = "ArcaneRaySound"
tt.track_target = true
tt.ray_duration = fts(10)
tt = RT("ray_arcane_disintegrate", "ray_arcane")
tt.bullet.mod = "mod_ray_arcane_disintegrate"
tt.image_width = 166
tt.render.sprites[1].name = "ray_arcane_disintegrate"
tt.render.sprites[1].loop = false
tt.sound_events.insert = "DesintegrateSound"

tt = RT("ray_hero_thor", "ray_tesla")
tt.bullet.mod = "mod_ray_hero_thor"
tt.render.sprites[1].name = "ray_hero_thor"
tt.main_script.update = kr1_scripts.ray_thor.update

tt = E:register_t("enemy_spider_egg", "decal_scripted")
E:add_comps(tt, "render", "spawner", "tween")
tt.main_script.update = kr1_scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "enemy_spider_egg"
tt.render.sprites[1].loop = false
tt.spawner.count = 3
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_spider_tiny"
tt.spawner.node_offset = 5
tt.spawner.pos_offset = v(0, 1)
tt.spawner.allowed_subpaths = {
	1,
	2,
	3
}
tt.spawner.random_subpath = false
tt.spawner.animation_start = "start"
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		4,
		0
	}
}
tt.tween.remove = true

tt = E:register_t("enemy_spider_rotten_egg", "decal_scripted")
E:add_comps(tt, "render", "spawner", "tween")
tt.main_script.update = kr1_scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "enemy_spider_rotten_egg"
tt.render.sprites[1].loop = false
tt.spawner.count = 3
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_spider_rotten_tiny"
tt.spawner.node_offset = 5
tt.spawner.pos_offset = v(0, 1)
tt.spawner.allowed_subpaths = {
	1,
	2,
	3
}
tt.spawner.random_subpath = false
tt.spawner.animation_start = "start"
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		4,
		0
	}
}
tt.tween.remove = true

tt = RT("juggernaut_bomb_spawner", "decal_scripted")

E:add_comps(tt, "render", "spawner", "tween")

tt.main_script.update = kr1_scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "bomb_juggernaut_spawner"
tt.render.sprites[1].loop = false
tt.spawner.animation_concurrent = "open"
tt.spawner.count = 7
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_golem_head"
tt.spawner.keep_gold = true
tt.spawner.node_offset = 2
tt.spawner.pos_offset = v(0, 0)
tt.spawner.allowed_subpaths = {
	1,
	2,
	3
}
tt.spawner.random_subpath = false
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		4,
		0
	}
}
tt.tween.remove = true
tt = E:register_t("myconid_spawner")

E:add_comps(tt, "pos", "spawner", "main_script")

tt.main_script.update = kr1_scripts.enemies_spawner.update
tt.spawner.count = 2
tt.spawner.random_cycle = {
	0,
	1
}
tt.spawner.entity = "enemy_rotten_lesser"
tt.spawner.random_node_offset_range = {
	-2,
	9
}
tt.spawner.random_subpath = true
tt.spawner.initial_spawn_animation = "raise"
tt.spawner.spawn_sound = "EnemyMushroomBorn"
tt.spawner.spawn_sound_args = {
	delay = fts(29)
}
tt.spawner.check_node_valid = true
tt.spawner.use_node_pos = true

tt = RT("aura_teleport_arcane", "aura")

AC(tt, "render")

tt.aura.mod = "mod_teleport_arcane"
tt.aura.duration = fts(23)
tt.aura.apply_delay = fts(5)
tt.aura.apply_duration = fts(10)
tt.aura.max_count = 4
tt.aura.cycle_time = fts(2)
tt.aura.radius = 32.5
tt.aura.vis_flags = bor(F_RANGED, F_MOD, F_TELEPORT)
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND, F_HERO, F_FREEZE)
tt.main_script.insert = kr1_scripts.aura_apply_mod.insert
tt.main_script.update = kr1_scripts.aura_apply_mod.update
tt.render.sprites[1].name = "aura_teleport_arcane"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].anchor.y = 0.375
tt.sound_events.insert = "TeleporthSound"
tt = RT("aura_malik_fissure", "aura")
tt.aura.fx = "decal_malik_earthquake"
tt.aura.damage_radius = 40
tt.aura.damage_types = {
	DAMAGE_TRUE,
	DAMAGE_PHYSICAL
}
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.spread_delay = fts(4)
tt.aura.spread_nodes = 4
tt.main_script.update = kr1_scripts.aura_malik_fissure.update
tt.stun = {}
tt.stun.vis_flags = bor(F_RANGED, F_STUN)
tt.stun.vis_bans = bor(F_FLYING, F_BOSS)
tt.stun.mod = "mod_malik_stun"
tt = RT("denas_buff_aura", "aura")

AC(tt, "main_script", "render", "tween")

tt.aura.duration = 1.63
tt.entity = "denas_buffing_circle"
tt.main_script.update = kr1_scripts.denas_buff_aura.update
tt.render.sprites[1].name = "hero_king_glowShadow"
tt.render.sprites[1].anchor = v(0.5, 0.26)
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.13,
		255
	},
	{
		1.63,
		255
	},
	{
		2.76,
		0
	}
}
tt.tween.remove = true

tt = E:register_t("aura_troll_regen", "aura")

AC(tt, "regen")

tt.main_script.update = kr1_scripts.aura_unit_regen.update
tt.regen.cooldown = fts(6)
tt.regen.health = 1
tt.regen.ignore_stun = true
tt.regen.ignore_freeze = false
tt = E:register_t("aura_forest_troll_regen", "aura_troll_regen")

AC(tt, "regen")

tt.main_script.update = kr1_scripts.aura_unit_regen.update
tt.regen.cooldown = fts(4)
tt.regen.health = 4
tt = E:register_t("aura_troll_axe_thrower_regen", "aura_troll_regen")

AC(tt, "regen")

tt.main_script.update = kr1_scripts.aura_unit_regen.update
tt.regen.cooldown = fts(6)
tt.regen.health = 2
tt = E:register_t("aura_troll_brute_regen", "aura_forest_troll_regen")
tt = E:register_t("aura_troll_chieftain_regen", "aura_troll_regen")
tt.regen.cooldown = fts(6)
tt.regen.health = 4
tt = E:register_t("aura_ulgukhai_regen", "aura_forest_troll_regen")
tt.regen.ignore_mods = true
tt = E:register_t("aura_goblin_zapper_death", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = 50
tt.aura.damage_max = 150
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.radius = 60
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = kr1_scripts.aura_apply_damage.update
tt = E:register_t("aura_demon_death", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = 50
tt.aura.damage_max = 100
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.excluded_templates = {
	"hero_oni"
}
tt.aura.radius = 60
tt.aura.track_damage = true
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = kr1_scripts.aura_apply_damage.update
tt = E:register_t("aura_demon_mage_death", "aura_demon_death")
tt.aura.damage_min = 200
tt.aura.damage_max = 400
tt = E:register_t("aura_demon_wolf_death", "aura_demon_death")
tt.aura.damage_min = 70
tt.aura.damage_max = 140
tt = E:register_t("aura_rotten_lesser_death", "aura")
tt.aura.cycles = 1
tt.aura.radius = 60
tt.aura.mod = "mod_rotten_lesser_pestilence"
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_MOD, F_POISON)
tt.main_script.insert = kr1_scripts.aura_apply_mod.insert
tt.main_script.update = kr1_scripts.aura_apply_mod.update

tt = E:register_t("aura_swamp_thing_regen", "aura")
AC(tt, "regen")
tt.main_script.update = kr1_scripts.aura_unit_regen.update
tt.regen.cooldown = fts(3)
tt.regen.health = 2
tt.regen.ignore_stun = true
tt.regen.ignore_freeze = true

tt = E:register_t("aura_flareon_death", "aura_demon_death")
tt.aura.damage_min = 40
tt.aura.damage_max = 80
tt = E:register_t("aura_gulaemon_death", "aura_demon_death")
tt.aura.damage_min = 200
tt.aura.damage_max = 400
tt = E:register_t("aura_burning_floor", "aura")

E:add_comps(tt, "render", "tween")

tt.aura.active = false
tt.aura.cycle_time = 0.3
tt.aura.mod = "mod_burning_floor_burn"
tt.aura.radius = 75
tt.aura.vis_flags = bor(F_MOD, F_BURN, F_RANGED)
tt.aura.vis_bans = bor(F_ENEMY)
tt.main_script.update = kr1_scripts.aura_burning_floor.update
tt.render.sprites[1].name = "InfernoDecal_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "InfernoDecal_0002"
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -10
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {
	{
		fts(0),
		0
	},
	{
		fts(30),
		255
	}
}
tt.tween.props[1].loop = false
tt.tween.props[1].sprite_id = 2
tt = E:register_t("burning_floor_controller")

E:add_comps(tt, "main_script")

tt.main_script.update = kr1_scripts.burning_floor_controller.update
tt = E:register_t("aura_demon_cerberus_death", "aura_demon_death")
tt.aura.damage_min = 666
tt.aura.damage_max = 666
tt.aura.radius = 120

tt = RT("aura_spectral_knight", "aura")
AC(tt, "render", "tween")
tt.aura.active = false
tt.aura.allowed_templates = {
	"enemy_fallen_knight",
	"enemy_skeleton_big",
	"enemy_skeleton",
}
tt.aura.cooldown = 0
tt.aura.delay = fts(30)
tt.aura.duration = -1
tt.aura.mods = {
	"mod_spectral_knight",
	"mod_spectral_knight_heal",
}
tt.aura.radius = 106.38297872340426
tt.aura.track_source = true
tt.aura.use_mod_offset = false
tt.main_script.insert = kr1_scripts.aura_apply_mod.insert
tt.main_script.update = kr1_scripts.aura_spectral_knight.update
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].anchor = v(0.5, 0.28125)
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "CB_DeathKnight_aura_0001"
tt.render.sprites[1].offset = v(0, -16)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].alpha = 0
tt.render.sprites[2].animated = true
tt.render.sprites[2].name = "spectral_knight_aura"
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(20),
		255
	}
}
tt.tween.props[1].name = "alpha"
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false

tt = E:register_t("aura_troll_skater_regen", "aura_troll_regen")

AC(tt, "regen")

tt.regen.cooldown = fts(4)
tt.regen.health = 1
tt = RT("graveyard_controller")

AC(tt, "graveyard", "main_script")

tt.main_script.update = kr1_scripts.graveyard_controller.update
tt.graveyard.dead_time = 0.5
tt.graveyard.check_interval = 0.25
tt.graveyard.keep_gold = true
tt.graveyard.spawn_interval = 0.1
tt.graveyard.spawns_by_health = {
	{
		"enemy_skeleton",
		299
	},
	{
		"enemy_skeleton_big",
		9e+99
	}
}
tt.graveyard.vis_has = F_ENEMY
tt.graveyard.vis_flags = F_SKELETON
tt.graveyard.vis_bans = F_BOSS
tt = RT("swamp_controller", "graveyard_controller")
tt.graveyard.spawns_by_health = {
	{
		"enemy_zombie",
		400
	},
	{
		"enemy_swamp_thing",
		9e+99
	}
}
tt.graveyard.excluded_templates = {
	"soldier_alleria_wildcat",
	"soldier_magnus_illusion"
}
tt.graveyard.keep_gold = false
tt.graveyard.vis_has = F_FRIEND
tt.graveyard.vis_flags = 0
tt.graveyard.vis_bans = F_HERO
tt = RT("s15_rotten_spawner")

AC(tt, "main_script", "editor")

tt.main_script.update = kr1_scripts.s15_rotten_spawner.update
tt.entity = "enemy_rotten_tree"
tt.spawn_margin = {
	30,
	60
}
tt.spawn_timers = {
	{
		10,
		0
	},
	[11] = {
		15,
		1
	},
	[14] = {
		10,
		0
	},
	[15] = {
		15,
		2
	},
	[17] = {
		15,
		3
	},
	[20] = {
		15,
		6
	}
}
tt = RT("s11_lava_spawner")

AC(tt, "main_script")

tt.main_script.update = kr1_scripts.s11_lava_spawner.update
tt.entity = "enemy_lava_elemental"
tt.cooldown = 400
tt.cooldown_after = 120
tt.pi = 4
tt.sound = "RockElementalDeath"
tt = RT("jt_spawner_aura", "aura")
tt.main_script.update = kr1_scripts.jt_spawner_aura.update
tt.aura.track_source = true
tt.spawn_data = {
	{
		"enemy_whitewolf",
		8,
		0,
		2,
		1
	},
	{
		"enemy_whitewolf",
		8,
		fts(20),
		2,
		2
	},
	{
		"enemy_yeti",
		19,
		0,
		3,
		1
	}
}
tt = E:register_t("blackburn_aura", "aura")
tt.main_script.update = kr1_scripts.blackburn_aura.update
tt.aura.cycle_time = 0.5
tt.aura.duration = -1
tt.aura.radius = 106.38297872340426
tt.aura.raise_entity = "enemy_skeleton_big"
tt.count_group_name = "blackburn_skeletons"
tt.count_group_type = COUNT_GROUP_CONCURRENT
tt.count_group_max = 15
tt = RT("veznan_souls_aura", "aura")
tt.main_script.update = kr1_scripts.veznan_souls_aura.update
tt.aura.track_source = true
tt.souls = {}
tt.souls.angles = {
	d2r(30),
	d2r(130)
}
tt.souls.count = 60
tt.souls.delay_frames = 10
tt.souls.entity = "veznan_soul"
tt = RT("kingpin_damage_aura", "aura")
tt.main_script.update = kr1_scripts.aura_apply_damage.update
tt.aura.duration = -1
tt.aura.cycle_time = fts(2)
tt.aura.damage_min = 100
tt.aura.damage_max = 100
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.radius = 65
tt.aura.track_source = true
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_RANGED)
tt = RT("aura_elder_shaman_healing", "aura")

AC(tt, "render", "tween")

tt.aura.mod = "mod_elder_shaman_heal"
tt.aura.mod_args = nil
tt.aura.cycle_time = 0.5
tt.aura.duration = nil
tt.aura.radius = nil
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND)
tt.aura.vis_flags = F_MOD
tt.render.sprites[1].alpha = 50
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "totem_groundeffect-orange_0002"
tt.render.sprites[1].scale = v(0.64, 0.64)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "totem_groundeffect-orange_0001"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].anchor = v(0.5, 0.12264150943396226)
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "start"
tt.render.sprites[3].prefix = "elder_shaman_totem_orange"
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].anchor = v(0.5, 0.12264150943396226)
tt.render.sprites[4].hidden = true
tt.render.sprites[4].loop = true
tt.render.sprites[4].name = "elder_shaman_totem_orange_fx"
tt.main_script.update = kr1_scripts.aura_elder_shaman.update
tt.sound_events.insert = "EndlessOrcsTotemHealing"
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		v(0.64, 0.64)
	},
	{
		fts(15),
		v(1, 1)
	},
	{
		fts(30),
		v(1.6, 1.6)
	}
}
tt.tween.props[1].loop = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		50
	},
	{
		fts(10),
		255
	},
	{
		fts(20),
		255
	},
	{
		fts(30),
		0
	}
}
tt.tween.props[2].loop = true
tt = RT("aura_elder_shaman_damage", "aura_elder_shaman_healing")
tt.aura.mod = "mod_elder_shaman_damage"
tt.aura.cycle_time = 0.2
tt.aura.vis_bans = bor(F_BOSS, F_ENEMY)
tt.render.sprites[1].name = "totem_groundeffect-red_0002"
tt.render.sprites[2].name = "totem_groundeffect-red_0001"
tt.render.sprites[3].prefix = "elder_shaman_totem_red"
tt.render.sprites[4].name = "elder_shaman_totem_red_fx"
tt.sound_events.insert = "EndlessOrcsTotemDamage"
tt = RT("aura_elder_shaman_speed", "aura_elder_shaman_healing")
tt.aura.mod = "mod_elder_shaman_speed"
tt.aura.cycle_time = 0.2
tt.render.sprites[1].name = "totem_groundeffect-ligthBlue_0002"
tt.render.sprites[2].name = "totem_groundeffect-lightBlue_0001"
tt.render.sprites[3].prefix = "elder_shaman_totem_blue"
tt.render.sprites[4].name = "elder_shaman_totem_blue_fx"
tt.sound_events.insert = "EndlessOrcsTotemSpeed"
tt = RT("mod_arcane_shatter", "mod_damage")
tt.damage_min = 0.03
tt.damage_max = 0.03
tt.damage_type = bor(DAMAGE_ARMOR, DAMAGE_NO_SHIELD_HIT)
tt = RT("mod_slow_curse", "mod_slow")
tt.main_script.insert = kr1_scripts.mod_slow_curse.insert
tt.modifier.excluded_templates = {
	"enemy_demon_cerberus"
}
tt = RT("mod_thorn", "modifier")

AC(tt, "render")

tt.animation_start = "thorn"
tt.animation_end = "thornFree"
tt.modifier.duration = 0
tt.modifier.duration_inc = 1
tt.modifier.type = MOD_TYPE_FREEZE
tt.modifier.vis_flags = bor(F_THORN, F_MOD)
tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)
tt.max_times_applied = 3
tt.damage_min = 40
tt.damage_max = 40
tt.damage_type = DAMAGE_PHYSICAL
tt.damage_every = 1
tt.render.sprites[1].prefix = "mod_thorn_small"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].size_prefixes = {
	"mod_thorn_small",
	"mod_thorn_big",
	"mod_thorn_big"
}
tt.render.sprites[1].size_scales = {
	vv(0.7),
	vv(0.8),
	vv(1)
}
tt.render.sprites[1].anchor.y = 0.22
tt.main_script.queue = kr1_scripts.mod_thorn.queue
tt.main_script.dequeue = kr1_scripts.mod_thorn.dequeue
tt.main_script.insert = kr1_scripts.mod_thorn.insert
tt.main_script.update = kr1_scripts.mod_thorn.update
tt.main_script.remove = kr1_scripts.mod_thorn.remove
tt = RT("mod_ray_arcane", "modifier")

AC(tt, "render", "dps")

tt.dps.damage_min = 76
tt.dps.damage_max = 140
tt.dps.damage_type = bor(DAMAGE_MAGICAL, DAMAGE_ONE_SHIELD_HIT)
tt.dps.damage_every = fts(2)
tt.dps.pop = {
	"pop_zap_arcane"
}
tt.dps.pop_conds = DR_KILL
tt.main_script.update = kr1_scripts.mod_ray_arcane.update
tt.modifier.duration = fts(10)
tt.modifier.allows_duplicates = true
tt.render.sprites[1].name = "mod_ray_arcane"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_BULLETS
tt = RT("mod_ray_arcane_disintegrate", "modifier")

AC(tt, "render")

tt.main_script.update = kr1_scripts.mod_ray_arcane_disintegrate.update
tt.modifier.pop = {
	"pop_zap_arcane"
}
tt.modifier.pop_conds = DR_KILL
tt.modifier.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS)
tt.modifier.damage = 1
tt.modifier.duration = fts(10)
tt.render.sprites[1].name = "mod_ray_arcane"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BULLETS
tt = RT("mod_teleport_arcane", "mod_teleport")
tt.delay_end = fts(6)
tt.delay_start = fts(1)
tt.fx_end = "fx_teleport_arcane"
tt.fx_start = "fx_teleport_arcane"
tt.max_times_applied = 3
tt.modifier.use_mod_offset = true
tt.modifier.vis_bans = bor(F_BOSS, F_FREEZE)
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.nodes_offset_min = -26
tt.nodes_offset_max = -17
tt.nodes_offset_inc = -5
tt = RT("mod_sorcerer_curse_armor", "modifier")

AC(tt, "armor_buff")

tt.modifier.duration = 5
tt.modifier.vis_flags = F_MOD
tt.armor_buff.magic = false
tt.armor_buff.factor = -0.5
tt.armor_buff.cycle_time = 1e+99
tt.main_script.insert = kr1_scripts.mod_armor_buff.insert
tt.main_script.remove = kr1_scripts.mod_armor_buff.remove
tt.main_script.update = kr1_scripts.mod_armor_buff.update
tt = RT("mod_sorcerer_curse_dps", "modifier")

AC(tt, "render", "dps")

tt.modifier.duration = 4.9
tt.modifier.vis_flags = F_MOD
tt.dps.damage_min = 10
tt.dps.damage_max = 10
tt.dps.damage_every = 1.25
tt.dps.damage_type = DAMAGE_TRUE
tt.main_script.insert = kr1_scripts.mod_dps.insert
tt.main_script.update = kr1_scripts.mod_dps.update
tt.render.sprites[1].name = "small"
tt.render.sprites[1].prefix = "mod_sorcerer_curse"
tt.render.sprites[1].size_names = {
	"small",
	"medium",
	"large"
}
tt.render.sprites[1].size_scales = {
	vv(1),
	vv(1),
	vv(1.5)
}
tt.render.sprites[1].sort_y_offset = -3

tt = RT("mod_ray_sunray_hit", "modifier")

AC(tt, "render")

tt.modifier.duration = fts(22)
tt.render.sprites[1].name = "fx_ray_sunray_hit"
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].loop = false
tt.main_script.insert = kr1_scripts.mod_track_target.insert
tt.main_script.update = kr1_scripts.mod_track_target.update
tt = RT("mod_malik_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)

tt = RT("mod_denas_tower", "modifier")

AC(tt, "render", "tween")

tt.range_factor = 1.2
tt.cooldown_factor = 0.8
tt.main_script.insert = kr1_scripts.mod_denas_tower.insert
tt.main_script.remove = kr1_scripts.mod_denas_tower.remove
tt.main_script.update = kr1_scripts.mod_denas_tower.update
tt.modifier.duration = nil
tt.modifier.use_mod_offset = false
tt.render.sprites[1].draw_order = 11
tt.render.sprites[1].name = "mod_denas_tower"
tt.render.sprites[1].anchor = v(0.5, 0.32)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].offset.y = 7
tt.tween.props[1].name = "alpha"
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
tt.tween.remove = false
tt = E:register_t("mod_shaman_heal", "modifier")

E:add_comps(tt, "hps", "render")

tt.hps.heal_min = 50
tt.hps.heal_max = 50
tt.hps.heal_every = 9e+99
tt.render.sprites[1].prefix = "healing"
tt.render.sprites[1].size_names = {
	"small",
	"medium",
	"large"
}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].loop = false
tt.main_script.insert = kr1_scripts.mod_hps.insert
tt.main_script.update = kr1_scripts.mod_hps.update
tt.modifier.duration = fts(24)
tt.modifier.allows_duplicates = true
tt = E:register_t("mod_rocketeer_speed_buff", "modifier")

AC(tt, "fast")

tt.main_script.insert = kr1_scripts.mod_rocketeer_speed_buff.insert
tt.main_script.remove = kr1_scripts.mod_rocketeer_speed_buff.remove
tt.main_script.update = kr1_scripts.mod_track_target.update
tt.modifier.duration = 2
tt.modifier.type = MOD_TYPE_FAST
tt.sound_events.insert = "EnemyRocketeer"
tt.fast.factor = 3.6041666666666665
tt.walk_angles = {
	"walkingRightLeft_fast",
	"walkingUp_fast",
	"walkingDown_fast"
}
tt = RT("mod_troll_rage", "modifier")

AC(tt, "render")

tt.extra_armor = 0.5
tt.extra_damage_max = 30
tt.extra_damage_min = 15
tt.extra_speed = 30.72
tt.main_script.insert = kr1_scripts.mod_troll_rage.insert
tt.main_script.remove = kr1_scripts.mod_troll_rage.remove
tt.main_script.update = kr1_scripts.mod_track_target.update
tt.modifier.duration = 6
tt.modifier.type = MOD_TYPE_RAGE
tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.use_mod_offset = false
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].name = "mod_troll_rage"
tt = RT("mod_troll_heal", "mod_shaman_heal")
tt = RT("mod_demon_shield", "modifier")

AC(tt, "render")

tt.modifier.bans = {
	"mod_sorcerer_curse_dps",
	"mod_sorcerer_curse_armor"
}
tt.modifier.remove_banned = true
tt.modifier.duration = 1e+99
tt.modifier.vis_flags = bor(F_MOD)
tt.shield_ignore_hits = 4
tt.main_script.insert = kr1_scripts.mod_demon_shield.insert
tt.main_script.remove = kr1_scripts.mod_demon_shield.remove
tt.main_script.update = kr1_scripts.mod_track_target.update
tt.render.sprites[1].name = "fx_shield_small"
tt = RT("mod_rotten_lesser_pestilence", "mod_poison")
tt.dps.damage_every = fts(4)
tt.dps.damage_max = 2
tt.dps.damage_min = 2
tt.modifier.duration = 5 - fts(4)
tt.render.sprites[1].prefix = "poison_violet"
tt = RT("mod_poison_giant_rat", "mod_poison")
tt.dps.damage_every = fts(7)
tt.dps.damage_max = 10
tt.dps.damage_min = 10
tt.modifier.duration = 2
tt.reduced_damage_factor = 0.5
tt.render.sprites[1].prefix = "poison_violet"
tt.main_script.insert = kr1_scripts.mod_giant_rat_poison.insert
tt.main_script.remove = kr1_scripts.mod_giant_rat_poison.remove
tt = RT("mod_wererat_poison", "mod_poison_giant_rat")
tt.dps.damage_max = 15
tt.dps.damage_min = 15
tt = RT("mod_flareon_burn", "mod_lava")
tt.dps.damage_min = 20
tt.dps.damage_max = 20
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(11)
tt.dps.damage_type = DAMAGE_POISON
tt.modifier.duration = 3
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt = RT("mod_gulaemon_fly", "modifier")
tt.main_script.queue = kr1_scripts.mod_gulaemon_fly.queue
tt.main_script.dequeue = kr1_scripts.mod_gulaemon_fly.dequeue
tt.main_script.insert = kr1_scripts.mod_gulaemon_fly.insert
tt.main_script.remove = kr1_scripts.mod_gulaemon_fly.remove
tt.main_script.update = kr1_scripts.mod_gulaemon_fly.update
tt.modifier.duration = 2
tt.modifier.type = MOD_TYPE_FAST
tt.speed_factor = 3.666666666666667
tt.nodes_limit = 20
tt = RT("mod_troll_skater", "modifier")
tt.main_script.queue = kr1_scripts.mod_gulaemon_fly.queue
tt.main_script.dequeue = kr1_scripts.mod_gulaemon_fly.dequeue
tt.main_script.insert = kr1_scripts.mod_gulaemon_fly.insert
tt.main_script.update = kr1_scripts.mod_gulaemon_fly.update
tt.modifier.type = MOD_TYPE_FAST
tt.speed_factor = 2.4166666666666665
tt.nodes_limit = 1
tt.modifier.duration = 1000000000
tt = RT("mod_burning_floor_burn", "mod_flareon_burn")
tt.modifier.duration = 0.5
tt = RT("mod_witch_frog", "modifier")

AC(tt, "render", "tween")

tt.animation_delay = 0.8
tt.main_script.insert = kr1_scripts.mod_witch_frog.insert
tt.main_script.update = kr1_scripts.mod_witch_frog.update
tt.modifier.damage_max = 60
tt.modifier.damage_min = 40
tt.modifier.damage_type = DAMAGE_EAT
tt.modifier.hero_damage_type = DAMAGE_MAGICAL
tt.render.sprites[1].anchor.y = 0.24
tt.render.sprites[1].hidden = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "mod_witch_frog"
tt.frog_delay = fts(4)
tt.fx_delay = fts(19)
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		v(0, 0)
	},
	{
		1.5,
		v(16, 0)
	}
}
tt.tween.props[1].name = "offset"
tt.tween.remove = false

tt = RT("mod_spectral_knight", "modifier")
AC(tt, "render")
tt.damage_factor_increase = 1.2
tt.armor_increase = 0.35
tt.speed_factor = 1.75
tt.main_script.insert = kr1_scripts.mod_spectral_knight.insert
tt.main_script.remove = kr1_scripts.mod_spectral_knight.remove
tt.main_script.update = kr1_scripts.mod_track_target.update
tt.modifier.duration = 6
tt.modifier.use_mod_offset = false
tt.modifier.vis_flags = bor(F_MOD)
tt.render.sprites[1].achor = v(0, 0)
tt.render.sprites[1].name = "mod_spectral_knight_fx"
tt.render.sprites[1].offset = v(0, 32)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "CB_DeathKnight_buffed"

tt = E:register_t("mod_spectral_knight_heal", "modifier")
E:add_comps(tt, "hps")
tt.modifier.allows_duplicates = true
tt.modifier.duration = 6
tt.hps.heal_min = 5
tt.hps.heal_max = 5
tt.hps.heal_every = 0.5
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update

tt = E:register_t("mod_jt_tower", "modifier")

E:add_comps(tt, "render", "tween", "ui")

tt.main_script.update = kr1_scripts.mod_jt_tower.update
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].offset.y = 36
tt.render.sprites[1].prefix = "mod_jt"
tt.render.sprites[1].z = Z_OBJECTS

if IS_CONSOLE then
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].alpha = 150
	tt.render.sprites[2].alpha_focused = 255
	tt.render.sprites[2].alpha_unfocused = 150
	tt.render.sprites[2].animated = false
	tt.render.sprites[2].name = "joystick_shortcuts_hud_0007"
	tt.render.sprites[2].name_focused = "joystick_shortcuts_hud_halo_0007"
	tt.render.sprites[2].name_unfocused = "joystick_shortcuts_hud_0007"
	tt.render.sprites[2].offset.y = 20
	tt.render.sprites[2].scale = vv(1.6)
else
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].name = "decal_jt_tap"
	tt.render.sprites[2].offset = v(10, 20)
	tt.render.sprites[2].random_ts = fts(7)
end

tt.render.sprites[2].draw_order = 11
tt.render.sprites[2].hidden = true
tt.render.sprites[2].z = Z_OBJECTS
tt.required_clicks = IS_PHONE_OR_TABLET and 5 or 3
tt.end_delay = fts(5)
tt.sound_events.click = "JtHitIce"
tt.tween.remove = false
tt.tween.props[1].disabled = true
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

if IS_CONSOLE then
	tt.tween.props[2] = CC("tween_prop")
	tt.tween.props[2].name = "scale"
	tt.tween.props[2].keys = {
		{
			0,
			vv(1.6)
		},
		{
			0.25,
			vv(1.9)
		},
		{
			0.5,
			vv(1.6)
		}
	}
	tt.tween.props[2].sprite_id = 2
	tt.tween.props[2].loop = true
end

tt.ui.can_select = false
tt.ui.can_click = true
tt.ui.click_rect = r(-40, 0, 80, 60)
tt.ui.click_fx = "fx_jt_tower_click"
tt.ui.z = 1
tt = E:register_t("mod_gulthak_heal", "mod_shaman_heal")
tt.hps.heal_min = 200
tt.hps.heal_max = 200
tt = E:register_t("mod_kingpin_heal_self", "mod_shaman_heal")
tt.hps.heal_min = 500
tt.hps.heal_max = 500
tt.render.sprites[1].anchor.y = 0.3
tt = E:register_t("mod_kingpin_heal_others", "mod_shaman_heal")
tt.hps.heal_min = 50
tt.hps.heal_max = 50
tt = RT("mod_myconid_poison", "mod_poison")
tt.dps.damage_every = fts(2)
tt.dps.damage_max = 4
tt.dps.damage_min = 4
tt.modifier.duration = 5
tt.render.sprites[1].prefix = "poison_violet"
tt = RT("mod_blackburn_stun", "mod_stun")
tt.modifier.duration = 4
tt.modifier.duration_heroes = 2
tt = RT("mod_blackburn_tower", "modifier")

AC(tt, "render", "tween", "main_script")

tt.main_script.update = kr1_scripts.mod_blackburn_tower.update
tt.modifier.duration = 4
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].loop = true
tt.render.sprites[1].offset.y = 36
tt.render.sprites[1].name = "mod_blackburn_tower"
tt.render.sprites[1].z = Z_OBJECTS
tt.tween.remove = false
tt.tween.disabled = true
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
tt = E:register_t("mod_veznan_tower", "modifier")

E:add_comps(tt, "render", "ui")

if IS_CONSOLE then
	E:add_comps(tt, "tween")
end

tt.click_time = 4
tt.duration = 6
tt.main_script.update = kr1_scripts.mod_veznan_tower.update
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].offset.y = 36
tt.render.sprites[1].prefix = "mod_veznan"
tt.render.sprites[1].z = Z_OBJECTS

if IS_CONSOLE then
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].alpha = 150
	tt.render.sprites[2].alpha_focused = 255
	tt.render.sprites[2].alpha_unfocused = 150
	tt.render.sprites[2].animated = false
	tt.render.sprites[2].name = "joystick_shortcuts_hud_0007"
	tt.render.sprites[2].name_focused = "joystick_shortcuts_hud_halo_0007"
	tt.render.sprites[2].name_unfocused = "joystick_shortcuts_hud_0007"
	tt.render.sprites[2].offset.y = 20
	tt.render.sprites[2].scale = vv(1.6)
else
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].name = "decal_veznan_tap"
	tt.render.sprites[2].offset = v(10, 20)
	tt.render.sprites[2].random_ts = fts(7)
end

tt.render.sprites[2].draw_order = 11
tt.render.sprites[2].hidden = true
tt.render.sprites[2].z = Z_OBJECTS
tt.required_clicks = IS_PHONE_OR_TABLET and 5 or IS_CONSOLE and 1 or 3
tt.sound_blocked = "VeznanHoldTrap"
tt.sound_click = "VeznanHoldHit"
tt.sound_released = "VeznanHoldDissipate"

if IS_CONSOLE then
	tt.tween.remove = false
	tt.tween.props[1] = CC("tween_prop")
	tt.tween.props[1].name = "scale"
	tt.tween.props[1].keys = {
		{
			0,
			vv(1.6)
		},
		{
			0.25,
			vv(1.9)
		},
		{
			0.5,
			vv(1.6)
		}
	}
	tt.tween.props[1].sprite_id = 2
	tt.tween.props[1].loop = true
end

tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-40, 0, 80, 60)
tt.ui.z = 1
tt = RT("mod_elder_shaman_heal", "mod_shaman_heal")
tt.hps.heal_min = nil
tt.hps.heal_max = nil
tt = RT("mod_elder_shaman_damage", "mod_lava")
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_every = fts(15)
tt.modifier.duration = 1
tt = RT("mod_elder_shaman_speed", "mod_slow")

AC(tt, "render")

tt.slow.factor = nil
tt.modifier.duration = 3
tt.render.sprites[1].name = "mod_elder_shaman_speed"

-- E:set_template("user_power_1", E:get_template("power_fireball_control"))
-- E:set_template("user_power_2", E:get_template("power_reinforcements_control"))

tt = RT("decal_sheep_big", "decal_delayed_click_play")

AC(tt, "tween")

tt.delayed_play.achievement_inc = "SHEEP_KILLER"
tt.delayed_play.click_interrupts = true
tt.delayed_play.click_tweens = true
tt.delayed_play.click_sound = "Sheep"
tt.delayed_play.clicked_animation = nil
tt.delayed_play.clicked_sound = "DeathEplosion"
tt.delayed_play.clicked_sound_alt = "BombExplosionSound"
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.play_once = true
tt.delayed_play.required_clicks = 8
tt.delayed_play.required_clicks_fx = "fx_unit_explode"
tt.delayed_play.required_clicks_fx_alt = "fx_explosion_small"
tt.delayed_play.required_clicks_fx_alt_chance = 0.1
tt.delayed_play.required_clicks_hide = true
tt.main_script.insert = kr1_scripts.decal_sheep_big.insert
tt.render.sprites[1].anchor.y = 0.1
tt.render.sprites[1].prefix = "decal_sheep_big"
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		v(1, 1)
	},
	{
		0.12,
		v(1.2, 1.2)
	},
	{
		0.16,
		v(1, 1)
	}
}
tt.tween.props[1].name = "scale"
tt.tween.remove = false
tt.ui.click_rect = r(-10, -5, 20, 20)
tt.ui.can_select = false
tt = RT("decal_sheep_small", "decal_sheep_big")
tt.render.sprites[1].prefix = "decal_sheep_small"
tt = RT("decal_mill_big", "decal_click_pause")
tt.render.sprites[1].name = "decal_mill_big"
tt.ui.can_select = false
tt.ui.click_rect = r(-10, -30, 40, 65)
tt = RT("decal_mill_small", "decal_mill_big")
tt.render.sprites[1].name = "decal_mill_small"
tt.ui.click_rect = r(-10, -25, 35, 55)
tt = RT("decal_s01_trees", "decal")
tt.render.sprites[1].name = "stage1_trees"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.234375
tt = RT("decal_boat_big", "decal_loop")
tt.render.sprites[1].name = "decal_boat_big_idle"
tt = RT("decal_boat_small", "decal_loop")
tt.render.sprites[1].name = "decal_boat_small_idle"
tt = RT("decal_fish", "decal_scripted")

AC(tt, "ui")

tt.render.sprites[1].prefix = "decal_fish"
tt.render.sprites[1].name = "jump"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.main_script.update = kr1_scripts.decal_fish.update
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-24, -17, 48, 34)
tt.achievement_id = "CATCH_A_FISH"
tt = RT("decal_water_spark", "decal_loop")
tt.render.sprites[1].name = "decal_water_spark_play"
tt = RT("decal_goat", "decal_sheep_big")
tt.render.sprites[1].prefix = "decal_goat"
tt = RT("kr1_decal_tunnel_light", "decal_scripted")

AC(tt, "tween")

tt.main_script.update = kr1_scripts.decal_tunnel_light.update
tt.render.sprites[1].name = "cave_light_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true
tt.tween.remove = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.15,
		200
	},
	{
		0.3,
		255
	},
	{
		0.4,
		220
	},
	{
		0.7,
		255
	}
}
tt.track_names = nil
tt.track_ids = nil
tt = RT("decal_burner_big", "decal_loop")
tt.render.sprites[1].anchor = v(0.5, 0.13)
tt.render.sprites[1].name = "decal_burner_big_idle"
tt = RT("decal_burner_small", "decal_loop")
tt.render.sprites[1].anchor = v(0.5, 0.11)
tt.render.sprites[1].name = "decal_burner_small_idle"
tt = E:register_t("decal_fredo", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "decal_fredo"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = v(0.5, 0.1)
tt.render.sprites[1].loop = false
tt.main_script.update = kr1_scripts.decal_fredo.update
tt.ui.can_click = true
tt.ui.click_rect = r(-33, 104, 30, 30)
tt = RT("decal_orc_burner", "decal_loop")
tt.render.sprites[1].name = "decal_orc_burner_idle"
tt.render.sprites[1].random_ts = fts(14)
tt = RT("decal_orc_flag", "decal_loop")
tt.render.sprites[1].anchor = v(0.5, 0.07)
tt.render.sprites[1].random_ts = fts(14)
tt.render.sprites[1].name = "decal_orc_flag_idle"
tt = RT("decal_swamp_bubble", "decal_delayed_play")
tt.render.sprites[1].name = "decal_swamp_bubble_jump"
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.min_delay = fts(150)
tt.delayed_play.max_delay = fts(400)
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_swamp_bubble_jump"
tt = E:register_t("decal_demon_portal_big", "decal_scripted")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "decal_demon_portal_big_active"
tt.main_script.update = kr1_scripts.decal_demon_portal_big.update
tt.fx_out = "fx_demon_portal_out"
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -10
tt.tween.props[1].name = "alpha"
tt.tween.props[1].loop = false
tt.tween.props[1].keys = {
	{
		fts(0),
		0
	},
	{
		fts(30),
		180
	},
	{
		fts(40),
		255
	}
}
tt.out_nodes = nil
tt.shutdown_timeout = 5
tt = E:register_t("decal_s17_barricade", "decal")

E:add_comps(tt, "editor", "main_script")

tt.boss_name = "eb_kingpin"
tt.boss_spawn_wave = 15
tt.main_script.update = kr1_scripts.decal_s17_barricade.update
tt.render.sprites[1].prefix = "decal_s17_barricade"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.x = 0.4
tt.render.sprites[1].loop = false
tt.editor.props = {
	{
		"editor.game_mode",
		PT_NUMBER
	}
}
tt = RT("decal_bandits_flag", "decal_loop")
tt.render.sprites[1].random_ts = fts(14)
tt.render.sprites[1].name = "decal_bandits_flag_idle"
tt = E:register_t("decal_scrat", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "decal_scrat"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "decal_scrat_ice"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].anchor = v(0.5, 0.5)
tt.render.sprites[2].loop = false
tt.touch_fx = "fx_decal_scrat_touch"
tt.main_script.update = kr1_scripts.decal_scrat.update
tt.ui.can_click = true
tt.ui.click_rect = r(-45, 5, 40, 40)
tt = RT("fx_decal_scrat_touch", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "decal_scrat_touch_fx"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.sound_events.insert = "JtHitIce"
tt = RT("decal_troll_flag", "decal_loop")
tt.render.sprites[1].random_ts = fts(18)
tt.render.sprites[1].name = "decal_troll_flag_idle"
tt = RT("decal_troll_burner", "decal_loop")
tt.render.sprites[1].random_ts = fts(11)
tt.render.sprites[1].name = "decal_troll_burner_idle"
tt = E:register_t("decal_frozen_mushroom", "decal_click_play")
tt.render.sprites[1].prefix = "decal_frozen_mushroom"
tt.click_play.required_clicks = 1
tt.click_play.clicked_sound = "MushroomPoof"
tt.click_play.play_once = true
tt = RT("decal_lava_fall", "decal_loop")
tt.render.sprites[1].name = "decal_lava_fall_idle"
tt = RT("decal_inferno_bubble", "decal_delayed_play")
tt.render.sprites[1].name = "decal_inferno_bubble_jump"
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.min_delay = fts(150)
tt.delayed_play.max_delay = fts(400)
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_inferno_bubble_jump"
tt = RT("decal_lava_splash", "decal_inferno_bubble")
tt.render.sprites[1].name = "decal_lava_splash_jump"
tt.delayed_play.play_animation = "decal_lava_splash_jump"
tt = E:register_t("decal_inferno_portal", "decal_demon_portal_big")
tt.render.sprites[1].name = "decal_inferno_portal_active"
tt = E:register_t("decal_inferno_ground_portal", "decal_demon_portal_big")
tt.render.sprites[1].name = "decal_inferno_ground_portal_active"
tt = E:register_t("decal_s21_veznan", "decal")
tt.render.sprites[1].name = "Inferno_Stg21_Veznan_0001"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_s21_veznan_free", "decal")
tt.render.sprites[1].name = "Inferno_Stg21_Veznan_0002"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_s21_hellboy", "decal")
tt.render.sprites[1].name = "decal_s21_hellboy_idle"
tt = E:register_t("background_sounds_blackburn", "background_sounds")
tt.min_delay = 20
tt.max_delay = 30
tt.sounds = {}
tt = E:register_t("decal_s23_splinter", "decal_click_play")
tt.render.sprites[1].prefix = "decal_s23_splinter"
tt.render.sprites[1].loop = false
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect.pos.x = -6
tt.ui.click_rect.size.x = 25
tt = E:register_t("decal_s23_splinter_pizza", "decal_s23_splinter")
tt.main_script.update = kr1_scripts.decal_s23_splinter_pizza.update
tt.render.sprites[1].prefix = "decal_s23_splinter_pizza"

tt = E:register_t("decal_s24_nevermore", "decal_click_play")

E:add_comps(tt, "tween")

tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].scale = v(0.7, 0.7)
tt.render.sprites[1].prefix = "decal_s24_nevermore"
tt.render.sprites[1].z = Z_OBJECTS
tt.leave_time = 2
tt.main_script.update = kr1_scripts.decal_s24_nevermore.update
tt.sound = "ExtraBlackburnCrow"
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -10
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {
	{
		fts(0),
		v(0, 0)
	},
	{
		fts(60),
		v(334, 44)
	}
}
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect.pos.y = -26
tt = RT("decal_blackburn_weed", "decal_loop")
tt.render.sprites[1].random_ts = fts(34)
tt.render.sprites[1].name = "decal_blackburn_weed_idle"
tt = RT("decal_blackburn_waves", "decal_delayed_play")
tt.render.sprites[1].name = "decal_blackburn_waves_jump"
tt.delayed_play.min_delay = 0
tt.delayed_play.max_delay = 1
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_blackburn_waves_jump"
tt = RT("decal_blackburn_bubble", "decal_delayed_play")
tt.render.sprites[1].name = "decal_blackburn_bubble_jump"
tt.delayed_play.min_delay = 0
tt.delayed_play.max_delay = 1
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_blackburn_bubble_jump"
tt = RT("decal_blackburn_smoke", "decal_loop")
tt.render.sprites[1].random_ts = fts(21)
tt.render.sprites[1].name = "decal_blackburn_smoke_jump"
tt = E:register_t("decal_s25_nessie", "decal_click_play")
tt.render.sprites[1].anchor = v(0.5, 0.43478260869565216)
tt.render.sprites[1].prefix = "decal_s25_nessie"
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.update = kr1_scripts.decal_s25_nessie.update
tt.out_pos = {
	v(555, 600),
	v(131, 530),
	v(415, 450)
}
tt.animation_duration = {
	3,
	4
}
tt.pause_duration = {
	7,
	10
}
tt.sound = "ExtraBlackburnNessie"
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect.pos = v(-22, 2)
tt.ui.click_rect.size = v(30, 20)
tt = RT("decal_s26_cage", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_s26_cage"
tt.delayed_play.min_delay = 2
tt.delayed_play.max_delay = 6
tt.delayed_play.idle_animation = "idle"
tt.delayed_play.play_animation = "play"
tt = RT("decal_s26_hangmen", "decal_s26_cage")
tt.render.sprites[1].prefix = "decal_s26_hangmen"
tt = RT("decal_endless_burner", "decal_loop")
tt.render.sprites[1].name = "decal_orc_burner_idle"
tt.render.sprites[1].random_ts = fts(14)
tt = RT("decal_s81_percussionist", "decal_scripted")
tt.render.sprites[1].prefix = "decal_s81_percussionist"
tt.render.sprites[1].anchor.y = 0.125
tt.render.sprites[1].loop = false
tt.main_script.update = kr1_scripts.decal_s81_percussionist.update
tt.play_loops = 0