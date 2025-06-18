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

tt = RT("enemy_sheep_ground", "enemy_KR5")
anchor_y = 0.2
image_y = 38
tt.enemy.gold = 0
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 80
tt.health_bar.offset = v(0, ady(32))
tt.info.i18n_key = "ENEMY_SHEEP"
tt.info.portrait = "bottom_info_image_enemies_0025"
tt.info.enc_icon = nil
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.enemy_sheep.update
tt.motion.max_speed = 1.5 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_sheep_ground"
tt.sound_events.insert = "Sheep"
tt.sound_events.death = "DeathEplosion"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 10)
tt.unit.mod_offset = v(0, ady(15))
tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_EAT, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY)
tt.clicks_to_destroy = 6

tt = RT("enemy_sheep_fly", "enemy_sheep_ground")
anchor_y = 0.038461538461538464
image_y = 78
tt.enemy.gold = 80
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = 389
tt.health_bar.offset = v(0, ady(68))
tt.motion.max_speed = 2.08 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_sheep_fly"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.ui.click_rect.pos.y = 40
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, ady(56))
tt.unit.mod_offset = v(0, ady(48))
tt.unit.show_blood_pool = false
tt.vis.flags = bor(F_ENEMY, F_FLYING)

tt = RT("enemy_greenmuck", "enemy_KR5")
AC(tt, "melee", "timed_attacks")
tt.enemy.gold = 80
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = v(28, 0)
tt.health.dead_lifetime = 8
tt.health.hp_max = 1800
tt.health_bar.offset = v(0, 96)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.info.fn = kr1_scripts.eb_greenmuck.get_info
tt.info.i18n_key = "ENEMY_GREENMUCK"
-- tt.info.enc_icon = 45
tt.info.portrait = "bottom_info_image_enemies_0050"
tt.main_script.insert = kr1_scripts.enemy_basic.insert
tt.main_script.update = kr1_scripts.enemy_greenmuck.update
tt.motion.max_speed = 0.3 * FPS
tt.render.sprites[1].anchor = v(0.5, 0.1402439024390244)
tt.render.sprites[1].prefix = "enemy_greenmuck"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walkingRightLeft",
	"walkingUp",
	"walkingDown"
}
tt.sound_events.death = "DeathSkeleton"
tt.sound_events.insert = nil
tt.ui.click_rect = r(-21, 0, 42, 77)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = v(0, 26)
tt.unit.marker_offset = v(0, 0)
tt.unit.marker_hidden = true
tt.unit.mod_offset = v(0, 26)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_POLYMORPH, F_EAT, F_DISINTEGRATED, F_INSTAKILL, F_MOD)
tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
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
tt.timed_attacks.list[1].bullet = "bomb_greenmuck_small"
tt.timed_attacks.list[1].count = 3
tt.timed_attacks.list[1].bullet_start_offset = v(0, 84)
tt.timed_attacks.list[1].cooldown = 6
tt.timed_attacks.list[1].shoot_time = fts(13)
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].vis_bans = F_ENEMY

tt = RT("bomb_greenmuck_small", "bomb")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_max = 80
tt.bullet.damage_min = 40
tt.bullet.damage_radius = 47.25
tt.bullet.flight_time_base = fts(17)
tt.bullet.flight_time_factor = fts(0.07142857142857142)
tt.bullet.hit_fx = "fx_explosion_rotten_shot"
tt.bullet.hit_decal = nil
tt.bullet.pop = nil
tt.main_script.insert = kr1_scripts.enemy_bomb.insert
tt.main_script.update = kr1_scripts.enemy_bomb.update
tt.render.sprites[1].name = "EnemyGreenmuckProjectile"
tt.sound_events.hit = "swamp_thing_bomb_explosion"
