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
local kr2_scripts = require("kr2_game_scripts")

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

tt = E:register_t("enemy_blacksurge", "enemy_KR5")

E:add_comps(tt, "melee", "timed_attacks", "water", "regen")

anchor_y = 0.31
tt.enemy.gold = 50
tt.enemy.melee_slot = v(35, 0)
tt.enemy.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER)
tt.health.armor = 0.7
tt.health.hp_max = 1200
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 49)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hidden = {}
tt.hidden.cooldown = 20
tt.hidden.duration = 12
tt.hidden.nodeslimit = 20
tt.hidden.trigger_health_factor = 0.3
tt.hidden.vis_bans = bor(F_BLOCK, F_STUN, F_BLOOD, F_TWISTER, F_LETHAL)
tt.hidden.sprite_suffix = "_hidden"
tt.hidden.ts = 0
tt.info.portrait = "bottom_info_image_enemies_0001"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr2_scripts.enemy_blacksurge.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(28)
tt.motion.max_speed = 19.2
tt.regen.cooldown = 0.1
tt.regen.duration = 3
tt.regen.health = 20
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_blacksurge"
tt.sound_events.death_water = "RTWaterDead"
tt.sound_events.water_splash = "SpecialMermaid"
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.timed_attacks.list[1].animation = "curse"
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].max_count = 2
tt.timed_attacks.list[1].mod = "mod_blacksurge"
tt.timed_attacks.list[1].range = 200
tt.timed_attacks.list[1].shoot_time = fts(26)
tt.timed_attacks.list[1].sound = "RTBlacksurgeHoldTower"
tt.ui.click_rect = r(-30, -10, 60, 55)
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 15)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 19)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.water.health_bar_offset = v(0, tt.health_bar.offset.y - 8)
tt.water.hit_offset = v(0, 15)
tt.water.mod_offset = v(0, 14)
tt.water.speed_factor = 2
tt.water.splash_fx = "fx_enemy_splash_crocs"

local mod_blacksurge = E:register_t("mod_blacksurge", "modifier")

E:add_comps(mod_blacksurge, "render")

mod_blacksurge.modifier.duration = 7
mod_blacksurge.main_script.update = scripts.mod_tower_block.update
mod_blacksurge.render.sprites[1].prefix = "blacksurge_curse"
mod_blacksurge.render.sprites[1].name = "start"
mod_blacksurge.render.sprites[1].anchor.y = 0.24
mod_blacksurge.render.sprites[1].draw_order = 10

tt = E:register_t("enemy_bloodshell", "enemy_KR5")

E:add_comps(tt, "melee", "water")

anchor_y = 0.26
tt.enemy.gold = 75
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(34, 0)
tt.enemy.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER)
tt.health.armor = 0.95
tt.health.hp_max = 3200
tt.health.immune_to = bor(DAMAGE_EXPLOSION, DAMAGE_ELECTRICAL)
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 57)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "bottom_info_image_enemies_0002"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed_water.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 120
tt.melee.attacks[1].damage_min = 100
tt.melee.attacks[1].hit_time = fts(16)
tt.motion.max_speed = 26.879999999999995
tt.render.sprites[1].anchor.y = 0.26
tt.render.sprites[1].prefix = "enemy_bloodshell"
tt.sound_events.death_water = "RTWaterDead"
tt.sound_events.water_splash = "SpecialMermaid"
tt.ui.click_rect = r(-30, -10, 60, 60)
tt.unit.hit_offset = v(0, 30)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 28)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = F_DRILL
tt.water.health_bar_offset = v(0, tt.health_bar.offset.y - 28)
tt.water.hit_offset = v(0, 7)
tt.water.mod_offset = v(0, 14)
tt.water.speed_factor = 1.43
tt.water.vis_bans = bor(F_BLOCK, F_SKELETON, F_DRILL)
tt.water.splash_fx = "fx_enemy_splash_crocs"

local mod_bluegale_damage = E:register_t("mod_bluegale_damage", "modifier")

E:add_comps(mod_bluegale_damage, "dps")

mod_bluegale_damage.modifier.duration = 0.9
mod_bluegale_damage.dps.damage_min = 15
mod_bluegale_damage.dps.damage_max = 15
mod_bluegale_damage.dps.damage_type = DAMAGE_ELECTRICAL
mod_bluegale_damage.dps.damage_every = 1
mod_bluegale_damage.main_script.insert = scripts.mod_dps.insert
mod_bluegale_damage.main_script.update = scripts.mod_dps.update

local mod_bluegale_heal = E:register_t("mod_bluegale_heal", "modifier")

E:add_comps(mod_bluegale_heal, "hps")

mod_bluegale_heal.modifier.duration = 0.9
mod_bluegale_heal.hps.heal_min = 15
mod_bluegale_heal.hps.heal_max = 15
mod_bluegale_heal.hps.heal_every = 1
mod_bluegale_heal.main_script.insert = scripts.mod_hps.insert
mod_bluegale_heal.main_script.update = scripts.mod_hps.update

tt = E:register_t("ray_bluegale", "bullet")
tt.image_width = 120
tt.main_script.update = scripts.ray_enemy.update
tt.render.sprites[1].name = "ray_bluegale"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_min = 25
tt.bullet.damage_max = 45
tt.bullet.max_track_distance = 50
tt.bullet.hit_time = fts(5)
tt.sound_events.insert = "SaurianSavantAttack"

tt = E:register_t("bluegale_clouds_aura", "aura")

E:add_comps(tt, "sound_events")

tt.main_script.insert = kr2_scripts.bluegale_clouds.insert
tt.main_script.update = kr2_scripts.bluegale_clouds.update
tt.aura.duration = 10
tt.clouds_min_radius = 35
tt.clouds_max_radius = 55
tt.clouds_count = 6
tt.sound_events.insert = "RTBluegaleStormSummon"

tt = E:register_t("decal_bluegale_cloud_dark", "decal_tween")

E:add_comps(tt, "ui")

tt.ui.click_rect = r(-58, -31, 116, 62)
tt.ui.z = 999
tt.tween.remove = true
tt.tween.props[1].name = "alpha"
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		v(0, 3)
	},
	{
		1,
		v(0, -3)
	},
	{
		2,
		v(0, 3)
	}
}
tt.tween.props[2].name = "offset"
tt.tween.props[2].loop = true
tt.render.sprites[1].name = "Bluegale_stormCloud_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY

tt = E:register_t("decal_bluegale_cloud_bright", "decal_tween")
tt.tween.remove = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].loop = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {
	{
		0,
		v(0, 3)
	},
	{
		1,
		v(0, -3)
	},
	{
		2,
		v(0, 3)
	}
}
tt.tween.props[2].name = "offset"
tt.tween.props[2].loop = true
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "hidden"
tt.render.sprites[1].name = "Bluegale_stormCloud_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY

tt = E:register_t("decal_bluegale_cloud_shadow", "decal_tween")
tt.tween.remove = true
tt.tween.props[1].name = "alpha"
tt.render.sprites[1].name = "atomicBomb_shadow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY

tt = E:register_t("bluegale_heal_aura", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_bluegale_heal"
tt.aura.vis_bans = F_FRIEND
tt.aura.vis_flags = F_MOD
tt.aura.cycle_time = 1
tt.aura.duration = 10
tt.aura.radius = 50

tt = E:register_t("bluegale_damage_aura", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_bluegale_damage"
tt.aura.vis_bans = F_ENEMY
tt.aura.vis_flags = F_MOD
tt.aura.cycle_time = 1
tt.aura.duration = 10
tt.aura.radius = 50

tt = E:register_t("enemy_bluegale", "enemy_KR5")

E:add_comps(tt, "melee", "ranged", "timed_attacks", "water")

anchor_y = 0.20689655172413793
image_y = 116
tt.enemy.gold = 60
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(30, 0)
tt.enemy.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER)
tt.health.armor = 0
tt.health.hp_max = 2400
tt.health.immune_to = DAMAGE_MAGICAL
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 57)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "bottom_info_image_enemies_0023"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr2_scripts.enemy_bluegale.update
tt.motion.max_speed = 30.72
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_bluegale"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].anchor.y = anchor_y
tt.render.sprites[2].prefix = "bluegale_lightning"
tt.sound_events.death_water = "RTWaterDead"
tt.sound_events.water_splash = "SpecialMermaid"
tt.ui.click_rect = r(-25, -10, 50, 60)
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(0, 20)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.water.health_bar_offset = v(0, tt.health_bar.offset.y - 30)
tt.water.hit_offset = v(0, 5)
tt.water.mod_offset = v(0, 12)
tt.water.speed_factor = 1.625
tt.water.splash_fx = "fx_enemy_splash_crocs"
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 120
tt.melee.attacks[1].damage_min = 60
tt.melee.attacks[1].hit_time = fts(30)
tt.ranged.attacks[1].animation = "rangedAttack"
tt.ranged.attacks[1].bullet = "ray_bluegale"
tt.ranged.attacks[1].bullet_start_offset = {
	v(27, 70)
}
tt.ranged.attacks[1].cooldown = 0
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].shoot_time = fts(18)
tt.timed_attacks.list[1] = E:clone_c("aura_attack")
tt.timed_attacks.list[1].animation = "castStorm"
tt.timed_attacks.list[1].bullet = "bluegale_clouds_aura"
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].node_random_max = 30
tt.timed_attacks.list[1].node_random_min = 15
tt.timed_attacks.list[1].nodes_limit = 40
tt.timed_attacks.list[1].shoot_time = fts(14)

tt = E:register_t("enemy_redspine", "enemy_KR5")

E:add_comps(tt, "melee", "ranged", "water")

anchor_y = 0.22
image_y = 64
tt.enemy.gold = 40
tt.enemy.melee_slot = v(32, 0)
tt.enemy.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER)
tt.health.armor = 0
tt.health.hp_max = 1700
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 49)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "bottom_info_image_enemies_0022"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed_water.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 35
tt.melee.attacks[1].damage_min = 25
tt.melee.attacks[1].hit_time = fts(20)
tt.motion.max_speed = 38.4
tt.ranged.attacks[1].animation = "rangedAttack"
tt.ranged.attacks[1].bullet = "harpoon_redspine"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 40)
}
tt.ranged.attacks[1].cooldown = 3
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].shoot_time = fts(8)
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_redspine"
tt.sound_events.death_water = "RTWaterDead"
tt.sound_events.water_splash = "SpecialMermaid"
tt.ui.click_rect = r(-20, -5, 40, 60)
tt.unit.hit_offset = v(0, 17)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 18)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.water.health_bar_offset = v(0, tt.health_bar.offset.y - 20)
tt.water.hit_offset = v(0, 5)
tt.water.mod_offset = v(0, 12)
tt.water.speed_factor = 1.5
tt.water.splash_fx = "fx_enemy_splash_crocs"

tt = E:register_t("harpoon_redspine", "arrow")
tt.render.sprites[1].name = "Redspine_spear"
tt.render.sprites[1].animated = false
tt.bullet.damage_min = 100
tt.bullet.damage_max = 130
tt.bullet.flight_time = fts(10)
tt.bullet.miss_decal = "Redspine_spear_decal"
tt.bullet.pop = nil

tt = E:register_t("mod_greenfin_net", "modifier")

E:add_comps(tt, "render")

tt.main_script.insert = scripts.mod_stun.insert
tt.main_script.update = scripts.mod_stun.update
tt.main_script.remove = scripts.mod_stun.remove
tt.modifier.duration = 6
tt.modifier.duration_heroes = 1
tt.modifier.animation_phases = true
tt.render.sprites[1].prefix = "greenfin_net"
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}
tt.render.sprites[1].name = "start"
tt.render.sprites[1].size_anchors = {
	v(0.5, 1),
	v(0.5, 0.8409090909090909),
	v(0.5, 0.8409090909090909)
}
tt.render.sprites[1].anchor = v(0.5, 1)
tt.modifier.custom_offsets = {}
tt.modifier.custom_offsets.default = v(0, 28)
tt.modifier.custom_offsets.soldier_death_rider = v(5, 31)
tt.modifier.custom_offsets.soldier_frankenstein = v(0, 31)

tt = E:register_t("enemy_greenfin", "enemy_KR5")

E:add_comps(tt, "melee", "water")

anchor_y = 0.185
tt.enemy.gold = 20
tt.enemy.melee_slot = v(26, 0)
tt.enemy.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER)
tt.health.armor = 0
tt.health.hp_max = 450
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 37)
tt.info.portrait = "bottom_info_image_enemies_0020"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed_water.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 14
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[2] = E:clone_c("melee_attack")
tt.melee.attacks[2].animation = "netAttack"
tt.melee.attacks[2].cooldown = 8
tt.melee.attacks[2].hit_time = fts(9)
tt.melee.attacks[2].mod = "mod_greenfin_net"
tt.melee.attacks[2].vis_flags = bor(F_STUN, F_NET)
tt.motion.max_speed = 57.599999999999994
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_greenfin"
tt.sound_events.death_water = "RTWaterDead"
tt.sound_events.water_splash = "SpecialMermaid"
tt.unit.hit_offset = v(0, 20)
tt.unit.marker_offset = v(0, -1)
tt.unit.mod_offset = v(2, 13)
tt.water.health_bar_offset = v(0, tt.health_bar.offset.y - 15)
tt.water.hit_offset = v(0, 5)
tt.water.mod_offset = v(2, 10)
tt.water.speed_factor = 1.2
tt.water.splash_fx = "fx_enemy_splash_crocs"

tt = E:register_t("enemy_deviltide", "enemy_greenfin")
tt.enemy.gold = 20
tt.health.armor = 0.5
tt.health.hp_max = 500
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "bottom_info_image_enemies_0021"
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.motion.max_speed = 49.92
tt.render.sprites[1].prefix = "enemy_deviltide"
tt.sound_events.water_splash = "SpecialMermaid"
tt.water.speed_factor = 1.15

tt = E:register_t("enemy_deviltide_shark", "enemy_KR5")
anchor_y = 0.19230769230769232
image_y = 104
tt.enemy.gold = 20
tt.enemy.valid_terrains = TERRAIN_WATER
tt.health.armor = 0.5
tt.health.hp_max = 500
tt.health_bar.offset = v(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.fn = kr2_scripts.enemy_deviltide_shark.get_info
tt.info.portrait = "bottom_info_image_enemies_0021"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr2_scripts.enemy_deviltide_shark.update
tt.motion.max_speed = 84.48
tt.payload = "enemy_deviltide"
tt.payload_time = fts(24)
tt.render.sprites[1].anchor = v(0.44660194174757284, 0.19230769230769232)
tt.render.sprites[1].prefix = "enemy_deviltide_shark"
tt.sound_events.death_water = "RTWaterDead"
tt.sound_events.deploy = "RTWaterExplosion"
tt.ui.click_rect = r(-30, -10, 60, 40)
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(0, 15)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(tt.vis.flags, F_WATER)

tt = E:register_t("enemy_sniper", "enemy_KR5")

E:add_comps(tt, "melee", "ranged")

anchor_y = 0.16666666666666666
tt.info.portrait = "bottom_info_image_enemies_0016"
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 14)
tt.main_script.insert = kr2_scripts.enemy_sniper.insert
tt.main_script.update = kr2_scripts.enemy_sniper.update
tt.health.hp_max = 500
tt.health.armor = 0
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 37)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.render.sprites[1].prefix = "enemy_sniper"
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles.ranged_start = {
	"ranged_start_side",
	"ranged_start_up",
	"ranged_start_down"
}
tt.render.sprites[1].angles.ranged_loop = {
	"ranged_loop_side",
	"ranged_loop_up",
	"ranged_loop_down"
}
tt.render.sprites[1].angles.ranged_end = {
	"ranged_end_side",
	"ranged_end_up",
	"ranged_end_down"
}
tt.render.sprites[1].angles_flip_vertical = {
	ranged_end = true,
	ranged_loop = true,
	ranged_start = true
}
tt.render.sprites[1].angles_custom = {
	ranged = {
		35,
		145,
		210,
		335
	}
}
tt.motion.max_speed = 1.92 * FPS
tt.enemy.gold = 40
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(25, 0)
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].damage_max = 22
tt.ranged.attacks[1].bullet = "bolt_sniper"
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].shoot_time = fts(5)
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].max_range = 350
tt.ranged.attacks[1].min_range = 51
tt.ranged.attacks[1].range_var = 50
tt.ranged.attacks[1].animations = {
	"ranged_start",
	"ranged_loop",
	"ranged_end"
}
tt.ranged.attacks[1].bullet_start_offset = {
	v(14, 14),
	v(10, 27),
	v(8, 3)
}

tt = E:register_t("bolt_sniper", "bolt_enemy")
tt.render.sprites[1].prefix = "bolt_sniper"
tt.bullet.align_with_trajectory = true
tt.bullet.damage_max = 100
tt.bullet.damage_min = 100
tt.bullet.max_speed = 30 * FPS
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.max_track_distance = 50
tt.sound_events.insert = "SaurianSniperBullet"

tt = E:register_t("enemy_razorwing", "enemy_KR5")

E:add_comps(tt, "cliff")

anchor_y = 0
tt.cliff.hide_sprite_ids = {
	2
}
tt.enemy.gold = 5
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 100
tt.health_bar.offset = v(0, 79)
tt.info.portrait = "bottom_info_image_enemies_0013"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 1.6640000000000001 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_razorwing"
tt.render.sprites[1].angles_flip_vertical = {
	walk = true
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-20, 44, 40, 50)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 64)
tt.unit.marker_offset = v(0, 1)
tt.unit.mod_offset = v(0, 56)
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_EAT)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)

tt = E:register_t("enemy_quetzal", "enemy_KR5")

E:add_comps(tt, "timed_attacks")

anchor_y = 0
tt.enemy.gold = 100
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 500
tt.health_bar.offset = v(0, 97)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "bottom_info_image_enemies_0014"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr2_scripts.enemy_quetzal.update
tt.motion.max_speed = 2.56 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_quetzal"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "DeathPuff"
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].bullet = "quetzal_egg"
tt.timed_attacks.list[1].max_cooldown = 1.5
tt.timed_attacks.list[1].min_cooldown = 1.5
tt.timed_attacks.list[1].max_count = 8
tt.ui.click_rect = r(-20, 42, 40, 50)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 68)
tt.unit.marker_offset = v(0, 1)
tt.unit.mod_offset = v(0, 70)
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_EAT)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)

tt = E:register_t("quetzal_egg", "decal_scripted")

E:add_comps(tt, "render", "spawner", "tween")

tt.main_script.update = scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.18
tt.render.sprites[1].prefix = "quetzal_egg"
tt.render.sprites[1].loop = false
tt.spawner.count = 1
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_razorwing"
tt.spawner.allowed_subpaths = nil
tt.spawner.animation_start = "start"
tt.spawner.initial_spawn_animation = "raise"
tt.spawner.keep_gold = true
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

tt = E:register_t("enemy_broodguard", "enemy_KR5")

E:add_comps(tt, "melee", "cliff", "auras")

anchor_y = 0.19
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_damage_sprint"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 20
tt.enemy.melee_slot = v(18, 0)
tt.health.armor = 0
tt.health.hp_max = 300
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 36)
tt.info.portrait = "bottom_info_image_enemies_0008"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed_cliff.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 22
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.28 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_broodguard"
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = v(0, 16)
tt.unit.marker_offset = v(0, 1)
tt.unit.mod_offset = v(0, 12)
tt.damage_sprint_factor = 0.78125

tt = E:register_t("enemy_myrmidon", "enemy_KR5")

E:add_comps(tt, "melee")

anchor_y = 0.21
tt.enemy.gold = 50
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(25, 0)
tt.health.armor = 0.6
tt.health.hp_max = 800
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "bottom_info_image_enemies_0011"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 34
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[2] = E:clone_c("melee_attack")
tt.melee.attacks[2].animation = "bite_attack"
tt.melee.attacks[2].cooldown = 12
tt.melee.attacks[2].damage_max = 150
tt.melee.attacks[2].damage_min = 75
tt.melee.attacks[2].mod = "mod_myrmidon_lifesteal"
tt.melee.attacks[2].sound_hit = "SaurianMyrmidonBite"
tt.melee.attacks[2].hit_time = fts(5)
tt.motion.max_speed = 1.024 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_myrmidon"
tt.ui.click_rect = r(-25, -10, 50, 50)
tt.unit.can_explode = false
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, -1)
tt.unit.mod_offset = v(0, 17)

tt = E:register_t("mod_myrmidon_lifesteal", "modifier")
tt.heal_hp = 125
tt.main_script.insert = scripts.mod_simple_lifesteal.insert

tt = E:register_t("enemy_blazefang", "enemy_KR5")

E:add_comps(tt, "melee", "ranged", "death_spawns")

anchor_y = 0.2
tt.death_spawns.name = "blazefang_explosion"
tt.death_spawns.quantity = 1
tt.death_spawns.concurrent_with_death = true
tt.enemy.gold = 40
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(25, 0)
tt.health.armor = 0
tt.health.hp_max = 600
tt.health.magic_armor = 0.7
tt.health_bar.offset = v(0, 48.4)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "bottom_info_image_enemies_0017"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 22
tt.melee.attacks[1].damage_min = 18
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.024 * FPS
tt.ranged.cooldown = 1 + fts(32)
tt.ranged.attacks[1].bullet = "bolt_blazefang"
tt.ranged.attacks[1].bullet_start_offset = {
	v(25, 10),
	v(12, 22),
	v(6, 4)
}
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 147.20000000000002
tt.ranged.attacks[1].min_range = 25.6
tt.ranged.attacks[1].shoot_time = fts(24)
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[2] = table.deepclone(tt.ranged.attacks[1])
tt.ranged.attacks[2].bullet = "bolt_blazefang_instakill"
tt.ranged.attacks[2].chance = 0.2
tt.ranged.attacks[2].vis_flags = bor(F_DISINTEGRATED, F_RANGED)
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_blazefang"
tt.render.sprites[1].angles.ranged = {
	"ranged_side",
	"ranged_up",
	"ranged_down"
}
tt.render.sprites[1].angles_flip_vertical = {
	ranged = true
}
tt.render.sprites[1].angles_custom = {
	ranged = {
		35,
		145,
		210,
		335
	}
}
tt.sound_events.death = "SaurianBlazefangDeath"
tt.ui.click_rect = r(-25, -10, 50, 55)
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, -1.6)
tt.unit.mod_offset = v(0, 18.4)

tt = E:register_t("blazefang_explosion", "bullet")
tt.render = nil
tt.sound_events = nil
tt.main_script.update = kr2_scripts.blazefang_explosion.update
tt.bullet.damage_min = 100
tt.bullet.damage_max = 100
tt.bullet.damage_radius = 76.8

tt = E:register_t("bolt_blazefang", "bolt_enemy")
tt.render.sprites[1].prefix = "bolt_blazefang"
tt.render.sprites[1].anchor = v(0.53, 0.58)
tt.bullet.align_with_trajectory = true
tt.bullet.damage_max = 100
tt.bullet.damage_min = 60
tt.bullet.max_speed = 1200
tt.bullet.acceleration_factor = 0.3
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.hit_fx = "fx_bolt_blazefang_hit"
tt.bullet.max_track_distance = 50
tt.sound_events.insert = "SaurianBlazefangAttack"

tt = E:register_t("bolt_blazefang_instakill", "bolt_blazefang")
tt.bullet.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_INSTAKILL)

tt = E:register_t("fx_bolt_blazefang_hit", "fx")
tt.render.sprites[1].name = "bolt_blazefang_hit"

tt = E:register_t("enemy_nightscale", "enemy_KR5")

E:add_comps(tt, "melee", "cliff")

anchor_y = 0.26
tt.enemy.gold = 25
tt.enemy.melee_slot = v(18, 0)
tt.health.armor = 0
tt.health.hp_max = 350
tt.health.magic_armor = 0.5
tt.health_bar.offset = v(0, 35.52)
tt.info.portrait = "bottom_info_image_enemies_0012"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr2_scripts.enemy_nightscale.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 42
tt.melee.attacks[1].damage_min = 28
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.536 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_nightscale"
tt.sound_events.hide = "SaurianNightscaleInvisible"
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, -0.48)
tt.unit.mod_offset = v(0, 9.52)
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.hidden = {}
tt.hidden.trigger_health_factor = 0.6
tt.hidden.duration = 8
tt.hidden.max_times = 1
tt.hidden.nodeslimit = 25
tt.hidden.ts = 0

tt = E:register_t("enemy_darter", "enemy_KR5")

E:add_comps(tt, "melee", "cliff")

anchor_y = 0.19
tt.enemy.gold = 20
tt.enemy.melee_slot = v(18, 0)
tt.health.armor = 0
tt.health.hp_max = 250
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 32)
tt.info.portrait = "bottom_info_image_enemies_0009"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr2_scripts.enemy_darter.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 22
tt.melee.attacks[1].damage_min = 18
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.92 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_darter"
tt.sound_events.blink = "SaurianDarterTeleporth"
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = v(0, 8)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 9)
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.blink = {}
tt.blink.cooldown = 4
tt.blink.nodeslimit = 45
tt.blink.nodeslimit_conn = 15
tt.blink.nodes_offset_min = 15
tt.blink.nodes_offset_max = 25
tt.blink.travel_time = fts(11)
tt.blink.fx = "fx_darter_blink"
tt.blink.ts = 0

tt = E:register_t("fx_darter_blink", "fx")
tt.render.sprites[1].name = "darter_blink"
tt.render.sprites[1].anchor.y = 0.22

tt = E:register_t("enemy_brute", "enemy_KR5")

E:add_comps(tt, "melee")

anchor_y = 0.16
tt.enemy.gold = 200
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(29, 0)
tt.health.armor = 0
tt.health.hp_max = 4400
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 61)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "bottom_info_image_enemies_0010"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 120
tt.melee.attacks[1].damage_min = 60
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].dodge_time = fts(6)
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].sound_hit = "SaurianBruteAttack"
tt.melee.attacks[2] = E:clone_c("area_attack")
tt.melee.attacks[2].animation = "area_attack"
tt.melee.attacks[2].cooldown = 13.333333333333334
tt.melee.attacks[2].damage_max = 120
tt.melee.attacks[2].damage_min = 80
tt.melee.attacks[2].damage_radius = 38.4
tt.melee.attacks[2].damage_type = DAMAGE_ELECTRICAL
tt.melee.attacks[2].hit_offset = v(30, 0)
tt.melee.attacks[2].hit_times = {
	fts(10),
	fts(20),
	fts(30)
}
tt.melee.attacks[2].sound_hit = "SaurianBruteAttack"
tt.motion.max_speed = 0.768 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_brute"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect = r(-25, -10, 50, 65)
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 18)
tt.unit.marker_offset = v(0, 1)
tt.unit.mod_offset = v(0, 16)
tt.unit.size = UNIT_SIZE_MEDIUM

tt = E:register_t("enemy_savant", "enemy_KR5")

E:add_comps(tt, "melee", "ranged", "timed_attacks")

anchor_y = 0.26
tt.enemy.gold = 100
tt.enemy.melee_slot = v(22, 0)
tt.health.armor = 0
tt.health.hp_max = 1000
tt.health.magic_armor = 0.5
tt.health_bar.offset = v(0, 34)
tt.info.portrait = "bottom_info_image_enemies_0015"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr2_scripts.enemy_savant.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 66
tt.melee.attacks[1].damage_min = 34
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.768 * FPS
tt.ranged.attacks[1].bullet = "savant_ray"
tt.ranged.attacks[1].shoot_time = fts(18)
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].max_range = 147.20000000000002
tt.ranged.attacks[1].min_range = 44.800000000000004
tt.ranged.attacks[1].bullet_start_offset = {
	v(28, 17)
}
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_savant"
tt.timed_attacks.list[1] = E:clone_c("spawn_attack")
tt.timed_attacks.list[1].animations = {
	"portal_start",
	"portal_loop",
	"portal_end"
}
tt.timed_attacks.list[1].min_cooldown = 5
tt.timed_attacks.list[1].max_cooldown = 10
tt.timed_attacks.list[1].entity = "savant_portal"
tt.timed_attacks.list[1].nodes_limit = 20
tt.timed_attacks.list[1].node_offset = 12
tt.timed_attacks.list[1].count_group_name = "savant_portals"
tt.timed_attacks.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_attacks.list[1].count_group_max = 25
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, -2)
tt.unit.mod_offset = v(0, 11)
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)

tt = E:register_t("savant_portal", "decal_scripted")

E:add_comps(tt, "render", "spawner", "sound_events")

tt.main_script.update = kr2_scripts.savant_portal.update
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].prefix = "savant_portal"
tt.render.sprites[1].z = Z_DECALS
tt.portal = {}
tt.portal.entities = {
	{
		0.02,
		"enemy_brute"
	},
	{
		0.1,
		"enemy_blazefang"
	},
	{
		0.2,
		"enemy_darter"
	},
	{
		0.4,
		"enemy_nightscale"
	},
	{
		1,
		"enemy_broodguard"
	}
}
tt.portal.node_var = {
	-5,
	5
}
tt.portal.cycle_time = 1
tt.portal.duration = 6
tt.portal.max_count = 20
tt.portal.spawn_fx = "fx_darter_blink"
tt.portal.pi = nil
tt.portal.spi = nil
tt.portal.ni = nil
tt.portal.finished = false
tt.sound_events.insert = "SaurianSavantOpenPortal"
tt.sound_events.spawn = "SaurianSavantTeleporth"
tt.sound_events.loop = "SaurianSavantPortalLoop"

tt = E:register_t("savant_ray", "bullet")
tt.image_width = 121
tt.main_script.update = scripts.ray_enemy.update
tt.render.sprites[1].name = "savant_ray"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_min = 90
tt.bullet.damage_max = 160
tt.bullet.hit_time = fts(3)
tt.bullet.max_track_distance = 50
tt.sound_events.insert = "SaurianSavantAttack"

tt = E:register_t("enemy_saurian_king", "enemy_KR5")
E:add_comps(tt, "melee", "timed_attacks")
image_y = 120
anchor_y = 0.16666666666666666
tt.enemy.gold = 250
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(25, 0)
tt.health.armor = 0.5
tt.health.dead_lifetime = fts(200)
tt.health.hp_max = 5500
tt.health_bar.offset = v(0, 82)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = kr2_scripts.eb_saurian_king.get_info
tt.info.portrait = "bottom_info_image_enemies_0019"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr2_scripts.eb_saurian_king.update
tt.motion.max_speed = 1.7919999999999998 * FPS
tt.render.sprites[1] = E:clone_c("sprite")
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
tt.render.sprites[1].prefix = "enemy_saurian_king"
tt.ui.click_rect = r(-28, 0, 56, 64)
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 36)
tt.unit.mod_offset = v(0, 36)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_SKELETON, F_STUN)
tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
tt.sound_events.death = "SaurianKingBossDeath"
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 0
tt.melee.attacks[1].damage_min = 0
tt.melee.attacks[1].damage_radius = 25
tt.melee.attacks[1].hit_time = fts(6)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].mod = "mod_saurian_king_tongue"
tt.melee.attacks[1].sound = "SaurianKingBossTongue"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animations = {
	"hammer_start",
	"hammer_loop"
}
tt.timed_attacks.list[1].cooldown = 10
tt.timed_attacks.list[1].damage_radius = 250
tt.timed_attacks.list[1].damage_type = DAMAGE_ELECTRICAL
tt.timed_attacks.list[1].hit_times = {
	fts(11),
	fts(18)
}
tt.timed_attacks.list[1].max_damage_radius = 50
tt.timed_attacks.list[1].max_damages = {
	10,
	15,
	25,
	40,
	65,
	100,
	145,
	200
}
tt.timed_attacks.list[1].min_damages = {
	5,
	7,
	12,
	20,
	30,
	50,
	70,
	100
}
tt.timed_attacks.list[1].sound = "SaurianKingBossHammer"
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].fx_offsets = {
	v(38, -9),
	v(50, 1)
}

tt = E:register_t("decal_enemy_saurian_king_hammer", "fx")
tt.render.sprites[1].name = "decal_enemy_saurian_king_hammer"
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("mod_saurian_king_tongue", "modifier")
tt.main_script.insert = kr2_scripts.mod_saurian_king_tongue.insert
tt.modifier.damage_radius = 25
tt.modifier.damage_max = 150
tt.modifier.damage_min = 100
tt.modifier.vis_flags = F_MOD
tt.modifier.vis_bans = bor(F_ENEMY, F_FLYING)

tt = E:register_t("eb_saurian_king", "boss")
E:add_comps(tt, "melee", "timed_attacks")
image_y = 150
anchor_y = 0.16666666666666666
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(25, 0)
tt.health.armor = 0.5
tt.health.dead_lifetime = fts(200)
tt.health.hp_max = 11000
tt.health_bar.offset = v(0, 103)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = kr2_scripts.eb_saurian_king.get_info
tt.info.portrait = "bottom_info_image_enemies_0019"
-- tt.info.enc_icon = 60
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr2_scripts.eb_saurian_king.update
tt.motion.max_speed = 1.7919999999999998 * FPS
tt.render.sprites[1] = E:clone_c("sprite")
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
tt.render.sprites[1].prefix = "eb_saurian_king"
tt.ui.click_rect = r(-35, 0, 70, 80)
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 45)
tt.unit.mod_offset = v(0, 45)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.sound_events.insert = "MusicBossFight"
tt.sound_events.death = "SaurianKingBossDeath"
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 0
tt.melee.attacks[1].damage_min = 0
tt.melee.attacks[1].damage_radius = 25
tt.melee.attacks[1].hit_time = fts(6)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].mod = "mod_saurian_king_tongue"
tt.melee.attacks[1].sound = "SaurianKingBossTongue"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animations = {
	"hammer_start",
	"hammer_loop"
}
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].damage_radius = 500
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].hit_times = {
	fts(11),
	fts(18)
}
tt.timed_attacks.list[1].max_damage_radius = 50
tt.timed_attacks.list[1].max_damages = {
	10,
	15,
	25,
	40,
	65,
	100,
	145,
	200
}
tt.timed_attacks.list[1].min_damages = {
	5,
	7,
	12,
	20,
	30,
	50,
	70,
	100
}
tt.timed_attacks.list[1].sound = "SaurianKingBossHammer"
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].fx_offsets = {
	v(48, -11),
	v(62, 1)
}

tt = E:register_t("decal_saurian_king_hammer", "fx")
tt.render.sprites[1].name = "decal_saurian_king_hammer"
tt.render.sprites[1].z = Z_DECALS