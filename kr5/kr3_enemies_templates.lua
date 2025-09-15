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
local kr3_scripts = require("kr3_game_scripts")

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

if H.command_line_has_arg("balance_override") then
    local balance_override_path = H.command_line_argv("balance_override")

    require(balance_override_path)
end

if game and game.store and game.store.level and game.store.level.test_case and game.store.level.test_case.patch_balance then
    local new_balance = game.store.level.test_case:patch_balance()

    if new_balance then
        balance = new_balance
    end
end

tt = RT("enemy_gnoll_bloodsydian", "enemy_KR5")

E:add_comps(tt, "melee")

tt.info.portrait = "bottom_info_image_enemies_0003"
tt.enemy.gold = 20
tt.enemy.melee_slot = v(32, 0)
tt.health.damage_factor_magical = 1.3
tt.health.hp_max = 550
tt.health_bar.offset = v(0, 38)
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(16)
tt.motion.max_speed = 2.5 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.3111111111111111)
tt.render.sprites[1].prefix = "bloodsydianGnoll"
tt.sound_events.death = "ElvesDeathGnolls"
tt.unit.hit_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)

tt = RT("enemy_bloodsydian_warlock", "enemy_KR5")

AC(tt, "melee", "timed_attacks")

tt.info.portrait = "bottom_info_image_enemies_0004"
tt.enemy.gold = 50
tt.enemy.melee_slot = v(37, 0)
tt.health.hp_max = 1500
tt.health.magic_armor = 0.75
tt.health_bar.offset = v(0, 58)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_bloodsydian_warlock.update
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 23
tt.melee.attacks[1].hit_time = fts(27)
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.16279069767441862)
tt.render.sprites[1].prefix = "bloodsydianWarlock"
tt.sound_events.death = "ElvesDeathGnolls"
tt.ui.click_rect = r(-20, 0, 40, 40)
tt.unit.hit_offset = v(0, 24)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 23)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].allowed_templates = {
	"enemy_acolyte"
}
tt.timed_attacks.list[1].mod = "mod_bloodsydian_warlock"
tt.timed_attacks.list[1].animation = "convert"
tt.timed_attacks.list[1].cast_time = fts(20)
tt.timed_attacks.list[1].hit_decal = "decal_bloodsydian_warlock"
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].max_count = 5
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].nodes_min = 30
tt.timed_attacks.list[1].nodes_limit = 20
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_MOD)

tt = RT("mod_bloodsydian_warlock", "modifier")

AC(tt, "render", "spawner", "sound_events")

tt.main_script.update = kr3_scripts.mod_bloodsydian_warlock.update
tt.render.sprites[1].prefix = "bloodsydianGnoll_respawn"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor.y = 0.3
tt.modifier.vis_flags = bor(F_MOD, F_RANGED)
tt.incubation_time = 1.5
tt.incubation_time_variance = 0.15
tt.spawn_name = "enemy_gnoll_bloodsydian"
tt.sound_events.insert = "ElvesCrystallizingGnoll"

tt = RT("decal_bloodsydian_warlock", "decal_tween")
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.25,
		0
	}
}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		v(1, 1)
	},
	{
		0.25,
		v(2.4, 2.4)
	}
}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "bloodsydianWarlock_convert_aura"
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("ps_bullet_twilight_evoker")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "twilight_evoker_bolt_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {
	0.25,
	0.25
}
tt.particle_system.alphas = {
	255,
	0
}
tt.particle_system.scales_y = {
	0.8,
	0.05
}
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true

tt = E:register_t("ps_bullet_twilight_heretic")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.names = {
	"bullet_twilight_heretic_particle_1",
	"bullet_twilight_heretic_particle_2"
}
tt.particle_system.animated = true
tt.particle_system.cycle_names = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 45
tt.particle_system.track_rotation = true
tt.particle_system.particle_lifetime = {
	fts(10),
	fts(10)
}

tt = E:register_t("ps_twilight_heretic_consume_ball_particle")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "twilight_heretic_consume_ball_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	fts(8),
	fts(8)
}
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true

tt = E:register_t("fx_bullet_twilight_evoker_hit", "fx")
tt.render.sprites[1].name = "bullet_twilight_evoker_hit"

tt = E:register_t("fx_twilight_heretic_consume", "fx")
tt.render.sprites[1].name = "fx_twilight_heretic_consume"

tt = E:register_t("fx_bullet_twilight_heretic_hit", "fx")
tt.render.sprites[1].name = "fx_bullet_twilight_heretic_hit"

tt = E:register_t("enemy_twilight_evoker", "enemy_KR5")

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.enemy.gold = 65
tt.enemy.melee_slot = v(15, 0)
tt.info.i18n_key = "ENEMY_EVOKER"
tt.info.portrait = "bottom_info_image_enemies_0006"
tt.health.hp_max = 700
tt.health.magic_armor = 0.9
tt.health_bar.offset = v(0, 38)
tt.motion.max_speed = 1.1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.175)
tt.render.sprites[1].prefix = "twilight_evoker"
tt.sound_events.death = "ElvesScourgerDeath"
tt.unit.hit_offset = v(0, 21)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_twilight_evoker.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 15
tt.melee.attacks[1].damage_min = 5
tt.melee.attacks[1].hit_time = fts(17)
tt.ranged.attacks[1].bullet = "bullet_twilight_evoker"
tt.ranged.attacks[1].bullet_start_offset = {
	v(3, 42)
}
tt.ranged.attacks[1].cooldown = 1.5 + fts(19)
tt.ranged.attacks[1].max_range = 110
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].hold_advance = true
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "towerAttack"
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].cooldown = 4
tt.timed_attacks.list[1].mod = "mod_twilight_evoker_silence"
tt.timed_attacks.list[1].range = 165
tt.timed_attacks.list[1].included_templates = {
	"tower_arcane_wizard_lvl4",
	"tower_barrel_lvl4",
	"tower_ballista_lvl4",
	"tower_arborean_emissary_lvl4",
	"tower_necromancer_lvl4",
	"tower_sand_lvl4",
	"tower_elven_stargazers_lvl4",
	"tower_flamespitter_lvl4",
	"tower_tricannon_lvl4",
	"tower_royal_archers_lvl4",
	"tower_royal_archer_and_musketeer",
	"tower_royal_archer_and_ranger",
	"tower_royal_archer_and_longbow",
	"tower_ray_lvl4",
	"tower_entwood",
	"tower_rock_thrower_lvl4",
	"tower_hermit_toad_lvl4",
	"tower_sparking_geode_lvl4",
	"tower_wild_magus",
	"tower_archer_dwarf",
	"tower_totem",
	"tower_crossbow",
	"tower_musketeer",
	"tower_spirit_mausoleum_lvl4",
	"tower_arcane_archer",
	"tower_silver",
	"tower_high_elven",
	"tower_ignis_altar_lvl4",
	"tower_bfg",
	"tower_dwaarp",
	"tower_mech",
	"tower_sorcerer",
	"tower_archmage",
	"tower_deep_devils_lvl4",
	"tower_ogres_barrack_lvl4",
}
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.timed_attacks.list[2] = E:clone_c("mod_attack")
tt.timed_attacks.list[2].cast_time = fts(16)
tt.timed_attacks.list[2].animation = "heal"
tt.timed_attacks.list[2].cooldown = 4
tt.timed_attacks.list[2].max_count = 4
tt.timed_attacks.list[2].hp_trigger_factor = 0.7
tt.timed_attacks.list[2].mod = "mod_twilight_evoker_heal"
tt.timed_attacks.list[2].range = 110
tt.timed_attacks.list[2].sound = "ElvesCreepEvokerHeal"
tt.timed_attacks.list[2].vis_flags = F_RANGED

tt = E:register_t("enemy_twilight_golem", "enemy_KR5")

E:add_comps(tt, "melee")

tt.enemy.gold = 125
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(20, 0)
tt.info.portrait = "bottom_info_image_enemies_0005"
tt.health.armor = 0.9
tt.health.hp_max = 5000
tt.health_bar.offset = v(0, 80)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.on_damage = kr3_scripts.enemy_twilight_golem.on_damage
tt.motion.max_speed = 1.8 * FPS
tt.motion.min_speed_sub_factor = 0.7
tt.render.sprites[1].anchor = v(0.5, 0.28448275862068967)
tt.render.sprites[1].prefix = "twilight_golem"
tt.sound_events.death = "ElvesCreepGolemDeath"
tt.sound_events.death_args = {
	delay = fts(10)
}
tt.ui.click_rect = r(-30, 0, 60, 60)
tt.unit.blood_color = BLOOD_NONE
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 30)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 30)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = F_INSTAKILL
tt.vis.flags = bor(tt.vis.flags, F_MINIBOSS)
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 180
tt.melee.attacks[1].damage_min = 120
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].count = 5
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].sound_hit = "ElvesCreepGolemAreaAttack"
tt.melee.attacks[1].hit_fx = "decal_twilight_golem_attack"

tt = E:register_t("enemy_twilight_heretic", "enemy_KR5")

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.info.portrait = "bottom_info_image_enemies_0007"
tt.enemy.gold = 150
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(23, 0)
tt.health.dead_lifetime = 3
tt.health.hp_max = 2250
tt.health.magic_armor = 0.9
tt.health_bar.offset = v(0, 40)
tt.motion.max_speed = 1.1 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.17567567567567569)
tt.render.sprites[1].prefix = "twilight_heretic"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = v(0, 17)
tt.unit.hide_after_death = true
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 14)
tt.unit.show_blood_pool = false
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_twilight_heretic.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(14)
tt.ranged.attacks[1].bullet = "bullet_twilight_heretic"
tt.ranged.attacks[1].bullet_start_offset = {
	v(3, 42)
}
tt.ranged.attacks[1].cooldown = 0.8 + fts(23)
tt.ranged.attacks[1].max_range = 100
tt.ranged.attacks[1].min_range = 5
tt.ranged.attacks[1].shoot_time = fts(15)
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].vis_bans = bor(F_SERVANT)
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animations = {
	"consumeStart",
	"consumeLoop",
	"consumeEnd"
}
tt.timed_attacks.list[1].cast_time = 0.4
tt.timed_attacks.list[1].cooldown = 4
tt.timed_attacks.list[1].mod = "mod_twilight_heretic_consume"
tt.timed_attacks.list[1].range = 125
tt.timed_attacks.list[1].nodes_limit = 45
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_HERO, F_ENEMY, F_SERVANT)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_MOD)
tt.timed_attacks.list[1].hit_fx = "fx_twilight_heretic_consume"
tt.timed_attacks.list[1].ball = "decal_twilight_heretic_consume_ball"
tt.timed_attacks.list[1].balls_count = 3
tt.timed_attacks.list[1].balls_dest_offset = v(20, 10)
tt.timed_attacks.list[2] = E:clone_c("mod_attack")
tt.timed_attacks.list[2].animation = "shadowCast"
tt.timed_attacks.list[2].cast_time = fts(15)
tt.timed_attacks.list[2].cooldown = 13
tt.timed_attacks.list[2].mod = "mod_twilight_heretic_servant"
tt.timed_attacks.list[2].range = 175
tt.timed_attacks.list[2].radius = 50
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_HERO, F_ENEMY, F_SERVANT)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_MOD)

tt = E:register_t("decal_twilight_golem_attack", "decal_tween")
tt.render.sprites[1].name = "gollem_attackFx"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset.x = 22
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].offset.x = -22
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		fts(12),
		0
	}
}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		vv(1)
	},
	{
		fts(12),
		vv(2.3)
	}
}
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 2
tt.tween.props[4] = table.deepclone(tt.tween.props[2])
tt.tween.props[4].sprite_id = 2

tt = E:register_t("decal_twilight_heretic_consume_ball", "decal_scripted")

E:add_comps(tt, "force_motion")

tt.render.sprites[1].name = "twilight_heretic_consumeProy"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].alpha = 100
tt.force_motion.max_a = 4500
tt.force_motion.max_v = 150
tt.force_motion.a_step = 10
tt.force_motion.max_flight_height = 60
tt.force_motion.a.x = 1
tt.main_script.update = kr3_scripts.decal_twilight_heretic_consume_ball.update
tt.particles_name = "ps_twilight_heretic_consume_ball_particle"

tt = E:register_t("bullet_twilight_evoker", "arrow")
tt.bullet.damage_min = 20
tt.bullet.damage_max = 30
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = false
tt.bullet.particles_name = "ps_bullet_twilight_evoker"
tt.bullet.hit_fx = "fx_bullet_twilight_evoker_hit"
tt.bullet.miss_fx = "fx_bullet_twilight_evoker_hit"
tt.bullet.hit_blood_fx = nil
tt.bullet.miss_decal = nil
tt.bullet.miss_fx_water = nil
tt.bullet.flight_time = fts(18)
tt.bullet.pop = nil
tt.render.sprites[1].name = "twilight_evoker_bolt_0001"

tt = E:register_t("bullet_twilight_heretic", "bolt_enemy")
tt.bullet.damage_min = 60
tt.bullet.damage_max = 80
tt.bullet.min_speed = 60
tt.bullet.max_speed = 360
tt.bullet.particles_name = "ps_bullet_twilight_heretic"
tt.bullet.hit_fx = "fx_bullet_twilight_heretic_hit"
tt.render.sprites[1].prefix = nil
tt.render.sprites[1].name = "twilight_heretic_proy_0001"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "BoltSorcererSound"

tt = E:register_t("mod_twilight_evoker_silence", "modifier")

E:add_comps(tt, "render", "tween")

tt.main_script.update = scripts.mod_tower_silence.update
tt.modifier.duration = 4
tt.modifier.replaces_lower = false
tt.modifier.resets_same = false
tt.render.sprites[1].name = "mod_twilight_evoker_silence_1"
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "mod_twilight_evoker_silence_2"
tt.render.sprites[2].draw_order = 10
tt.render.sprites[2].anchor.y = 0
tt.render.sprites[2].offset.y = 0
tt.tween.remove = false
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
tt.custom_offsets = {}
tt.custom_offsets.tower_arcane_wizard_lvl4 = v(0, 55)
tt.custom_offsets.tower_barrel_lvl4 = v(0, 55)
tt.custom_offsets.tower_ballista_lvl4 = v(0, 55)
tt.custom_offsets.tower_arborean_emissary_lvl4 = v(0, 50)
tt.custom_offsets.tower_necromancer_lvl4 = v(0, 55)
tt.custom_offsets.tower_sand_lvl4 = v(0, 50)
tt.custom_offsets.tower_elven_stargazers_lvl4 = v(0, 55)
tt.custom_offsets.tower_flamespitter_lvl4 = v(0, 55)
tt.custom_offsets.tower_tricannon_lvl4 = v(0, 50)
tt.custom_offsets.tower_royal_archers_lvl4 = v(0, 50)
tt.custom_offsets.tower_royal_archer_and_musketeer = v(0, 50)
tt.custom_offsets.tower_royal_archer_and_ranger = v(0, 50)
tt.custom_offsets.tower_royal_archer_and_longbow = v(0, 50)
tt.custom_offsets.tower_ray_lvl4 = v(0, 55)
tt.custom_offsets.tower_entwood = v(0, 50)
tt.custom_offsets.tower_rock_thrower_lvl4 = v(0, 55)
tt.custom_offsets.tower_hermit_toad_lvl4 = v(0, 50)
tt.custom_offsets.tower_sparking_geode_lvl4 = v(0, 60)
tt.custom_offsets.tower_wild_magus = v(0, 50)
tt.custom_offsets.tower_archer_dwarf = v(0, 50)
tt.custom_offsets.tower_totem = v(0, 55)
tt.custom_offsets.tower_crossbow = v(0, 50)
tt.custom_offsets.tower_musketeer = v(0, 50)
tt.custom_offsets.tower_spirit_mausoleum_lvl4 = v(0, 50)
tt.custom_offsets.tower_arcane_archer = v(0, 45)
tt.custom_offsets.tower_silver = v(0, 50)
tt.custom_offsets.tower_high_elven = v(0, 50)
tt.custom_offsets.tower_ignis_altar_lvl4 = v(0, 50)
tt.custom_offsets.tower_bfg = v(0, 50)
tt.custom_offsets.tower_dwaarp = v(0, 50)
tt.custom_offsets.tower_mech = v(0, 30)
tt.custom_offsets.tower_sorcerer = v(0, 50)
tt.custom_offsets.tower_archmage = v(0, 50)
tt.custom_offsets.tower_deep_devils_lvl4 = v(0, 60)
tt.custom_offsets.tower_ogres_barrack_lvl4 = v(0, 60)

tt = E:register_t("mod_twilight_evoker_heal", "modifier")

E:add_comps(tt, "hps", "render")

tt.modifier.duration = 1
tt.hps.heal_min = 16
tt.hps.heal_max = 16
tt.hps.heal_every = 0.2
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.render.sprites[1].prefix = "mod_twilight_evoker_heal"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[1].loop = false

tt = E:register_t("mod_twilight_heretic_consume", "modifier")

E:add_comps(tt, "render")

tt.modifier.duration = 3
tt.render.sprites[1].name = "twilight_heretic_fire"
tt.render.sprites[1].anchor.y = 0.17567567567567569
tt.render.sprites[1].sort_y_offset = 1
tt.speed_factor = 1.9
tt.mod_offset_y = 7
tt.health_bar_offset_y = 4
tt.nodes_limit = 45
tt.angles_walk = {
	"flyingRightLeft",
	"flyingUp",
	"flyingDown"
}
tt.main_script.insert = kr3_scripts.mod_twilight_heretic_consume.insert
tt.main_script.remove = kr3_scripts.mod_twilight_heretic_consume.remove
tt.main_script.update = kr3_scripts.mod_twilight_heretic_consume.update

tt = E:register_t("mod_twilight_heretic_servant", "mod_common_stun")

E:add_comps(tt, "render", "dps", "tween")

tt.dps.damage_min = 5
tt.dps.damage_max = 5
tt.dps.damage_every = fts(11)
tt.dps.damage_type = DAMAGE_PHYSICAL
tt.modifier.duration = 10
tt.modifier.use_mod_offset = nil
tt.main_script.insert = scripts.mod_stun.insert
tt.main_script.remove = scripts.mod_stun.remove
tt.main_script.update = kr3_scripts.mod_twilight_heretic_servant.update
tt.render.sprites[1].prefix = "mod_twilight_heretic_servant"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor.y = 0
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

tt = E:register_t("enemy_mantaray", "enemy_KR5")

E:add_comps(tt, "tween", "track_kills")

tt.info.portrait = "gui_bottom_info_image_enemies_0038"
tt.enemy.gold = 15
tt.enemy.max_blockers = 1
tt.enemy.melee_slot = v(17, 0)
tt.health.hp_max = 90
tt.health_bar.offset = v(0, 42)
tt.motion.max_speed = 3.5 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.07142857142857142)
tt.render.sprites[1].prefix = "mantaray"
tt.render.sprites[1].z = tt.render.sprites[1].z + 1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].animated = false
tt.sound_events.death = "DeathEplosion"
tt.ui.click_rect = r(-20, 15, 40, 25)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset_fly = v(0, 27)
tt.unit.mod_offset_facehug = v(0, 15)
tt.unit.mod_offset = tt.unit.mod_offset_fly
tt.unit.hit_offset_fly = v(0, 24)
tt.unit.hit_offset_facehug = v(0, 16)
tt.unit.hit_offset = tt.unit.hit_offset_fly
tt.unit.hide_after_death = true
tt.unit.fade_time_after_death = nil
tt.unit.show_blood_pool = false
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.vis.bans = bor(tt.vis.bans, F_SKELETON, F_BLOOD)
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_mantaray.update
tt.main_script.remove = kr3_scripts.enemy_mantaray.remove
tt.tween.props[1].name = "offset"
tt.tween.disabled = true
tt.tween.remove = false
tt.facehug_damage_cooldown = 1
tt.facehug_offsets = {}
tt.facehug_offsets.hero_default = v(0, 13)
tt.facehug_offsets.hero_builder = v(5, 13)
tt.facehug_offsets.hero_venom = v(5, 9)
tt.facehug_offsets.hero_10yr = v(2, 5)
tt.facehug_offsets.hero_spider = v(0, 46)
tt.facehug_offsets.hero_denas = v(0, 32)
tt.facehug_offsets.hero_hacksaw = v(0, 24)
tt.facehug_offsets.kr4_hero_alleria = v(0, 16)
tt.facehug_offsets.soldier_default = v(0, 9)
tt.facehug_offsets.soldier_forest = v(0, 13)
tt.facehug_offsets.soldier_druid_bear = v(15, 0)
tt.facehug_offsets.soldier_reinforcement_special_linirea = v(4, 13)
tt.facehug_offsets.soldier_hero_dragon_arb_spawn_lvl1 = v(0, 13)
tt.facehug_offsets.soldier_hero_dragon_arb_spawn_lvl2 = v(0, 13)
tt.facehug_offsets.soldier_hero_dragon_arb_spawn_lvl3 = v(0, 13)
tt.facehug_offsets.soldier_hero_dragon_arb_spawn_paragon_lvl1 = v(0, 13)
tt.facehug_offsets.soldier_hero_dragon_arb_spawn_paragon_lvl2 = v(0, 13)
tt.facehug_offsets.soldier_hero_dragon_arb_spawn_paragon_lvl3 = v(0, 13)
tt.facehug_offsets.soldier_death_rider = v(2, 17)
tt.facehug_offsets.hero_raelyn_ultimate_entity_1 = v(4, 19)
tt.facehug_offsets.hero_raelyn_ultimate_entity_2 = v(4, 19)
tt.facehug_offsets.hero_raelyn_ultimate_entity_3 = v(4, 19)
tt.facehug_offsets.hero_raelyn_ultimate_entity_4 = v(4, 19)
tt.facehug_offsets.soldier_dragon_bone_ultimate_dog = v(19, 0)
tt.facehug_offsets.soldier_dracolich_golem = v(15, 4)
tt.facehug_offsets.dark_army_soldier_knight_lvl4 = v(0, 13)
tt.facehug_offsets.fallen_ones_gargoyle = v(4, 9)
tt.facehug_offsets.soldier_dwarf = v(-2, 7)
tt.facehug_damage_soldier_min = 15
tt.facehug_damage_soldier_max = 20
tt.facehug_damage_hero_min = 10
tt.facehug_damage_hero_max = 30
tt.facehug_spawn_bans = {}

tt = RT("enemy_screecher_bat", "enemy_KR5")

E:add_comps(tt, "timed_attacks")

tt.enemy.gold = 14
tt.health.hp_max = 120
tt.health_bar.offset = v(0, 90)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "bottom_info_image_enemies_0018"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr3_scripts.enemy_screecher_bat.update
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.05)
tt.render.sprites[1].prefix = "screecher_bat"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor = v(0.5, 0.05)
tt.render.sprites[2].name = "screecher_bat_shadow"
tt.render.sprites[2].animated = false
tt.sound_events.death = "ElvesCreepScreecherDeath"
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "attack"
tt.timed_attacks.list[1].mod = "mod_screecher_bat_stun"
tt.timed_attacks.list[1].cooldown = 4.5
tt.timed_attacks.list[1].max_range = 50
tt.timed_attacks.list[1].attack_time = fts(10)
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY)
tt.timed_attacks.list[1].vis_flags = bor(F_STUN, F_RANGED)
tt.timed_attacks.list[1].sound = "ElvesCreepScreecherScream"
tt.ui.click_rect = r(-15, 45, 30, 35)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 54)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 54)
tt.unit.show_blood_pool = false
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.vis.bans = bor(F_BLOCK)

tt = RT("mod_screecher_bat_stun", "mod_common_stun")
tt.modifier.duration = 6
tt.modifier.duration_heroes = 3
tt.render.sprites[1].prefix = "mod_screecher_bat_stun"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].size_names = nil
tt.render.sprites[1].z = Z_EFFECTS

tt = E:register_t("enemy_rabbit", "enemy_KR5")
tt.info.portrait = "bottom_info_image_enemies_0024"
tt.enemy.gold = 7
tt.health.hp_max = 120
tt.health_bar.offset = v(0, 20)
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 0.9 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.21428571428571427)
tt.render.sprites[1].prefix = "rabbit"
tt.sound_events.death = "DeathEplosion"
tt.ui.click_rect = r(-10, -5, 20, 20)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.unit.size = UNIT_SIZE_SMALL
tt.vis.bans = bor(F_BLOCK, F_SKELETON)