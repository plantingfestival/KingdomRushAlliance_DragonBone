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
local scripts = require("custom_scripts_2")

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

local IS_KR1 = false
if true then
	tt = E:register_t("abomination_explosion_aura", "aura")
	tt.main_script.update = scripts.abomination_explosion_aura.update
	tt.sound_events.insert = "HWAbominationExplosion"
	tt.aura.damage_min = 250
	tt.aura.damage_max = 250
	tt.aura.damage_type = DAMAGE_TRUE
	tt.aura.radius = 100
	tt.aura.hit_time = fts(10)

	tt = E:register_t("werewolf_regen_aura", "aura")
	tt.main_script.update = scripts.werewolf_regen_aura.update
	
	tt = E:register_t("mod_lycanthropy", "modifier")
	E:add_comps(tt, "moon")
	tt.moon.transform_name = "enemy_werewolf"
	tt.main_script.insert = scripts.mod_lycanthropy.insert
	tt.main_script.update = scripts.mod_lycanthropy.update
	tt.spawn_hp = nil
	tt.active = false
	tt.nodeslimit = 30
	tt.extra_health = 700
	tt.modifier.vis_flags = bor(F_MOD, F_LYCAN)
	tt.modifier.vis_bans = bor(F_HERO)
	tt.sound_events.transform = "HWWerewolfTransformation"
	
	tt = E:register_t("enemy_abomination", "enemy_KR5")
	E:add_comps(tt, "melee", "moon", "death_spawns")
	E:add_comps(tt, "auras")
	anchor_y = 0.13157894736842105
	image_y = 115
	tt.auras.list[1] = E:clone_c("aura_attack")
	tt.auras.list[1].name = "moon_enemy_aura"
	tt.auras.list[1].cooldown = 0
	tt.death_spawns.name = "abomination_explosion_aura"
	tt.death_spawns.concurrent_with_death = true
	tt.enemy.lives_cost = 3
	tt.enemy.gold = 50
	tt.enemy.melee_slot = v(38, 0)
	tt.health.armor = 0.3
	tt.health.hp_max = 2500
	tt.health.magic_armor = 0
	tt.health_bar.offset = v(0, 66)
	tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
	tt.info.portrait = "bottom_info_image_enemies_0060"
	tt.main_script.insert = scripts.enemy_basic.insert
	tt.main_script.update = scripts.enemy_mixed.update
	tt.melee.attacks[1].cooldown = 2
	tt.melee.attacks[1].damage_max = IS_KR1 and 45 or 55
	tt.melee.attacks[1].damage_min = IS_KR1 and 35 or 45
	tt.melee.attacks[1].hit_time = fts(12)
	tt.moon.speed_factor = 2
	tt.motion.max_speed = (IS_KR1 and 1 or 1.28) * 0.5 * FPS
	tt.render.sprites[1].prefix = "enemy_abomination"
	tt.render.sprites[1].anchor.y = anchor_y
	tt.sound_events.death = "HWAbominationExplosion"
	tt.ui.click_rect = r(-25, -10, 50, 60)
	tt.unit.blood_color = BLOOD_RED
	tt.unit.can_explode = false
	tt.unit.hit_offset = v(0, 30)
	tt.unit.marker_offset = v(0, 2)
	tt.unit.mod_offset = v(0, 30)
	tt.unit.hide_after_death = true
	tt.unit.size = UNIT_SIZE_LARGE

	tt = E:register_t("enemy_werewolf", "enemy_KR5")
	E:add_comps(tt, "melee", "moon", "auras", "regen")
	anchor_y = 0.18181818181818182
	image_y = 66
	tt.auras.list[1] = E:clone_c("aura_attack")
	tt.auras.list[1].name = "werewolf_regen_aura"
	tt.auras.list[1].cooldown = 0
	tt.auras.list[2] = E:clone_c("aura_attack")
	tt.auras.list[2].name = "moon_enemy_aura"
	tt.auras.list[2].cooldown = 0
	tt.enemy.gold = 25
	tt.enemy.melee_slot = v(24, 0)
	tt.health.armor = 0
	tt.health.hp_max = 700
	tt.health.magic_armor = 0.3
	tt.health_bar.offset = v(0, 38)
	tt.info.portrait = "bottom_info_image_enemies_0056"
	tt.main_script.insert = scripts.enemy_basic.insert
	tt.main_script.update = scripts.enemy_mixed.update
	tt.melee.attacks[1].cooldown = 1
	tt.melee.attacks[1].damage_max = 60
	tt.melee.attacks[1].damage_min = 40
	tt.melee.attacks[1].hit_time = fts(12)
	tt.moon.regen_hp = 4
	tt.motion.max_speed = (IS_KR1 and 1 or 1.28) * 1.3 * FPS
	tt.render.sprites[1].prefix = "enemy_werewolf"
	tt.render.sprites[1].anchor.y = anchor_y
	tt.regen.cooldown = 0.25
	tt.regen.health = 2
	tt.unit.blood_color = BLOOD_RED
	tt.unit.hit_offset = v(0, 14)
	tt.unit.marker_offset = v(0, 0)
	tt.unit.mod_offset = v(0, 14)

	tt = E:register_t("enemy_halloween_zombie", "enemy_KR5")
	E:add_comps(tt, "melee", "moon")
	E:add_comps(tt, "auras")
	anchor_y = 0.18
	image_y = 50
	tt.auras.list[1] = E:clone_c("aura_attack")
	tt.auras.list[1].name = "moon_enemy_aura"
	tt.auras.list[1].cooldown = 0
	tt.enemy.gold = 7
	tt.enemy.melee_slot = v(18, 0)
	tt.health.armor = 0
	tt.health.hp_max = 300
	tt.health.magic_armor = 0
	tt.health_bar.offset = v(0, 32)
	tt.info.portrait = "bottom_info_image_enemies_0058"
	tt.main_script.insert = scripts.enemy_basic.insert
	tt.main_script.update = scripts.enemy_mixed.update
	tt.melee.attacks[1].cooldown = 1
	tt.melee.attacks[1].damage_max = 15
	tt.melee.attacks[1].damage_min = 5
	tt.melee.attacks[1].hit_time = fts(12)
	tt.melee.attacks[1].sound = "HWZombieAmbient"
	tt.motion.max_speed = (IS_KR1 and 1 or 1.28) * 0.5 * FPS
	tt.moon.speed_factor = 2
	tt.render.sprites[1].prefix = "enemy_halloween_zombie"
	tt.render.sprites[1].name = "raise"
	tt.render.sprites[1].anchor.y = anchor_y
	tt.unit.blood_color = BLOOD_GRAY
	tt.unit.hit_offset = v(0, 12)
	tt.unit.marker_offset = v(0, ady(10))
	tt.unit.mod_offset = v(0, 12)
	tt.sound_events.death = "DeathSkeleton"
	tt.sound_events.insert = "HWZombieAmbient"
	tt.vis.bans = bor(F_POISON)

	tt = E:register_t("enemy_lycan", "enemy_KR5")
	E:add_comps(tt, "melee", "moon", "auras")
	anchor_y = 0.14516129032258066
	image_y = 62
	tt.auras.list[1] = E:clone_c("aura_attack")
	tt.auras.list[1].name = "moon_enemy_aura"
	tt.auras.list[1].cooldown = 0
	tt.enemy.gold = 65
	tt.enemy.melee_slot = v(18, 0)
	tt.health.armor = 0
	tt.health.hp_max = 400
	tt.health.magic_armor = 0.3
	tt.health.on_damage = scripts.enemy_lycan.on_damage
	tt.health_bar.offset = v(0, 37)
	tt.info.portrait = "bottom_info_image_enemies_0063"
	tt.main_script.insert = scripts.enemy_basic.insert
	tt.main_script.update = scripts.enemy_mixed.update
	tt.melee.attacks[1].cooldown = 1
	tt.melee.attacks[1].damage_max = 20
	tt.melee.attacks[1].damage_min = 10
	tt.melee.attacks[1].hit_time = fts(10)
	tt.moon.transform_name = "enemy_lycan_werewolf"
	tt.motion.max_speed = (IS_KR1 and 1 or 1.28) * 1 * FPS
	tt.render.sprites[1].prefix = "enemy_lycan"
	tt.render.sprites[1].anchor.y = anchor_y
	tt.unit.blood_color = BLOOD_RED
	tt.unit.hit_offset = v(0, 14)
	tt.unit.marker_offset = v(0, 0)
	tt.unit.mod_offset = v(0, 14)
	tt.sound_events.death = nil
	tt.lycan_trigger_factor = 0.25

	tt = E:register_t("enemy_lycan_werewolf", "enemy_KR5")
	E:add_comps(tt, "melee", "moon", "auras", "regen")
	anchor_y = 0.18181818181818182
	image_y = 66
	tt.auras.list[1] = E:clone_c("aura_attack")
	tt.auras.list[1].name = "werewolf_regen_aura"
	tt.auras.list[1].cooldown = 0
	tt.auras.list[2] = E:clone_c("aura_attack")
	tt.auras.list[2].name = "moon_enemy_aura"
	tt.auras.list[2].cooldown = 0
	tt.enemy.gold = 65
	tt.enemy.melee_slot = v(24, 0)
	tt.health.armor = 0
	tt.health.hp_max = 1100
	tt.health.magic_armor = 0.6
	tt.health_bar.offset = v(0, 47)
	tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
	tt.info.i18n_key = "ENEMY_HALLOWEEN_LYCAN"
	tt.info.portrait = "bottom_info_image_enemies_0064"
	tt.main_script.insert = scripts.enemy_basic.insert
	tt.main_script.update = scripts.enemy_mixed.update
	tt.melee.attacks[1].cooldown = 1
	tt.melee.attacks[1].damage_max = 70
	tt.melee.attacks[1].damage_min = 50
	tt.melee.attacks[1].hit_time = fts(12)
	tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
	tt.melee.attacks[2].mod = "mod_lycanthropy"
	tt.melee.attacks[2].chance = 0.2
	tt.moon.regen_hp = 8
	tt.motion.max_speed = (IS_KR1 and 1 or 1.28) * 2 * FPS
	tt.render.sprites[1].prefix = "enemy_lycan_werewolf"
	tt.render.sprites[1].anchor.y = anchor_y
	tt.regen.cooldown = 0.25
	tt.regen.health = 4
	tt.ui.click_rect = r(-20, -10, 40, 50)
	tt.unit.blood_color = BLOOD_RED
	tt.unit.hit_offset = v(0, 22)
	tt.unit.marker_offset = v(0, 0)
	tt.unit.mod_offset = v(0, 22)
	tt.unit.size = UNIT_SIZE_MEDIUM
	tt.sound_events.insert = "HWAlphaWolf"

	tt = E:register_t("user_item_atomic_bomb")
	E:add_comps(tt, "user_item", "pos", "main_script", "user_selection")
	tt.main_script.update = scripts.user_item_atomic_bomb.update
	tt.plane_transit_duration = 5
	tt.plane_dest = nil
	tt.bomb_dest = nil

	tt = E:register_t("decal_atomic_bomb_plane", "decal_scripted")
	E:add_comps(tt, "motion", "sound_events")
	tt.render.sprites[1].name = "atomicBomb_plane"
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].z = Z_OBJECTS_SKY
	tt.render.sprites[2] = E:clone_c("sprite")
	tt.render.sprites[2].name = "atomic_bomb_plane_engine"
	tt.render.sprites[2].offset = v(52, -8)
	tt.render.sprites[2].z = Z_OBJECTS_SKY
	tt.render.sprites[3] = E:clone_c("sprite")
	tt.render.sprites[3].name = "atomicBomb_bomb"
	tt.render.sprites[3].animated = false
	tt.render.sprites[3].offset = v(16, -38)
	tt.render.sprites[3].z = Z_OBJECTS_SKY + 1
	tt.render.sprites[4] = E:clone_c("sprite")
	tt.render.sprites[4].name = "atomic_bomb_plane_wing"
	tt.render.sprites[4].offset = v(9, -27)
	tt.render.sprites[4].z = Z_OBJECTS_SKY + 2
	tt.render.sprites[5] = E:clone_c("sprite")
	tt.render.sprites[5].name = "atomicBomb_shadow"
	tt.render.sprites[5].animated = false
	tt.render.sprites[5].scale = v(0.6, 0.6)
	tt.render.sprites[5].alpha = 100
	tt.render.sprites[5].offset = v(0, 0)
	tt.render.sprites[5].z = Z_DECALS
	tt.main_script.insert = scripts.decal_atomic_bomb_plane.insert
	tt.main_script.update = scripts.decal_atomic_bomb_plane.update
	tt.sound_events.insert = "InAppAtomicBomb"

	tt = E:register_t("atomic_bomb", "bullet")
	tt.bullet.damage_min = 3000
	tt.bullet.damage_max = 3000
	tt.bullet.damage_type = bor(DAMAGE_EXPLOSION, DAMAGE_FX_EXPLODE, DAMAGE_NO_SPAWNS, DAMAGE_IGNORE_SHIELD)
	tt.bullet.flight_time = fts(26)
	tt.bullet.hit_decal = "decal_atomic_bomb_crater"
	tt.bullet.hit_fx = "fx_explosion_big"
	tt.render.sprites[1].name = "atomicBomb_bomb"
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].z = Z_OBJECTS_SKY + 1
	tt.render.sprites[2] = E:clone_c("sprite")
	tt.render.sprites[2].name = "atomicBomb_shadow"
	tt.render.sprites[2].animated = false
	tt.render.sprites[2].z = Z_DECALS
	tt.render.sprites[2].alpha = 0
	tt.main_script.insert = scripts.atomic_bomb.insert
	tt.main_script.update = scripts.atomic_bomb.update
	tt.sound_events.insert = "InAppAtomicBombFalling"

	tt = E:register_t("decal_atomic_bomb_crater", "decal_tween")
	tt.render.sprites[1].name = "atomicBomb_decal"
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].z = Z_DECALS
	tt.tween.props[1].keys = {
		{
			2,
			255
		},
		{
			3.5,
			0
		}
	}

	tt = E:register_t("user_item_atomic_freeze")
	E:add_comps(tt, "user_item", "pos", "main_script", "user_selection")
	tt.duration = 15
	tt.main_script.insert = scripts.user_item_atomic_freeze.insert
	tt.main_script.update = scripts.user_item_atomic_freeze.update
	tt.excluded_templates = {
		"eb_umbra",
		"enemy_umbra_piece",
		"enemy_umbra_piece_flying",
		"enemy_tremor",
		"enemy_headless_horseman"
	}
	tt.vis_flags = bor(F_RANGED, F_FREEZE)
	tt.vis_bans = 0
	tt.mod = "mod_user_item_freeze"

	tt = E:register_t("decal_user_item_atomic_freeze_slab", "decal_tween")
	tt.render.sprites[1].name = "freeze_decals_%04d"
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].z = Z_DECALS
	tt.tween.props[1].keys = {
		{
			"this.duration",
			255
		},
		{
			"this.duration+0.5",
			0
		}
	}
	tt.decals_count = 4

	tt = E:register_t("user_item_freeze", "bullet")
	E:add_comps(tt, "sound_events", "user_item", "user_selection")
	tt.bullet.flight_time = fts(21)
	tt.bullet.g = -1.4 / (fts(1) * fts(1))
	tt.bullet.rotation_speed = 20 * FPS * math.pi / 180
	tt.bullet.hit_fx = "fx_user_item_freeze_explosion"
	tt.bullet.hit_decal = "decal_user_item_freeze"
	tt.bullet.damage_radius = 60
	tt.bullet.mod = "mod_user_item_freeze"
	tt.bullet.hide_radius = 4
	tt.bullet.excluded_templates = E:get_template("user_item_atomic_freeze").excluded_templates
	tt.bullet.half_time_templates = {
		"enemy_demon_cerberus",
		"enemy_hobgoblin"
	}
	tt.bullet.vis_flags = bor(F_RANGED, F_FREEZE)
	tt.render.sprites[1].name = "small_freeze_bomb"
	tt.render.sprites[1].animated = false
	tt.user_selection.can_select_point_fn = scripts.user_item_freeze.can_select_point
	tt.main_script.insert = scripts.user_item_freeze.insert
	tt.main_script.update = scripts.user_item_freeze.update
	tt.sound_events.insert = "InAppFreeze"

	tt = E:register_t("mod_user_item_freeze", "mod_freeze")
	E:add_comps(tt, "render")
	tt.modifier.duration = 5
	tt.render.sprites[1].prefix = "freeze_creep"
	tt.render.sprites[1].sort_y_offset = -2
	tt.custom_offsets = {}
	tt.custom_offsets.flying = v(-5, 32)
	tt.custom_offsets.enemy_wasp_queen = v(-5, 38)
	tt.custom_offsets.eb_efreeti = v(100, 15)
	tt.custom_suffixes = {}
	tt.custom_suffixes.flying = "_air"
	tt.custom_animations = {
		"start",
		"end"
	}

	tt = E:register_t("decal_user_item_freeze", "decal_tween")
	tt.render.sprites[1].name = "small_freeze_decal"
	tt.render.sprites[1].animated = false
	tt.tween.props[1].keys = {
		{
			0.8,
			255
		},
		{
			2.1,
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
			0.2,
			v(1, 1)
		}
	}

	tt = E:register_t("fx_user_item_freeze_explosion", "fx")
	tt.render.sprites[1].name = "small_freeze_explosion"
	tt.render.sprites[1].anchor.y = 0.29
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -2

	tt = E:register_t("user_item_hearts")
	E:add_comps(tt, "pos", "user_item", "user_selection")
	tt.reward = 5

	tt = E:register_t("user_item_coins")
	E:add_comps(tt, "pos", "user_item", "user_selection")
	tt.reward = 500

	tt = E:register_t("user_item_dynamite", "bomb")
	E:add_comps(tt, "user_item", "user_selection")
	tt.user_selection.can_select_point_fn = scripts.user_item_dynamite.can_select_point
	tt.main_script.insert = scripts.user_item_dynamite.insert
	tt.render.sprites[1].name = "dynamite"
	tt.bullet.damage_min = 150
	tt.bullet.damage_max = 250
	tt.bullet.damage_radius = 45
	tt.bullet.flight_time = fts(21)
	tt.bullet.g = -1.4 / (fts(1) * fts(1))
end

tt = RT("holder_roots_lands_blocked", "tower_holder_blocked")
E:add_comps(tt, "main_script")
tt.tower.type = "holder_roots_lands_blocked"
tt.tower_holder.unblock_price = 20
tt.animation_group = "animation"
tt.render.sprites[2].prefix = "roots_holder_back"
tt.render.sprites[2].animated = true
tt.render.sprites[2].offset = v(0, 13)
tt.render.sprites[2].sort_y_offset = 0
tt.render.sprites[2].z = Z_DECALS + 1
tt.render.sprites[2].group = tt.animation_group
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "roots_holder_front"
tt.render.sprites[3].animated = true
tt.render.sprites[3].offset = v(0, 13)
tt.render.sprites[3].z = Z_DECALS + 1
tt.render.sprites[3].group = tt.animation_group
tt.main_script.update = scripts.holder_roots_lands_blocked.update

tt = RT("holder_roots_lands_removed", "holder_roots_lands_blocked")
tt.ui.click_rect = r(0, 0, 0, 0)
tt.ui.can_click = nil
tt.ui.can_select = nil
tt.tower.type = nil
tt.controller = "controller_holder_roots_lands_blocked"
tt.upgrade_to = "tower_holder"
tt.sound_events.remove = nil
tt.main_script.update = scripts.holder_roots_lands_removed.update

tt = RT("tower_roots_lands_blocked", "holder_roots_lands_blocked")
tt.tower.type = "tower_roots_lands_blocked"
tt.render.sprites[2].prefix = "roots_tower_back"
tt.render.sprites[2].anchor.y = 0.4
tt.render.sprites[2].z = Z_OBJECTS + 2
tt.render.sprites[3].prefix = "roots_tower_front"
tt.render.sprites[3].anchor.y = 0.4
tt.render.sprites[3].z = Z_OBJECTS + 2
tt.cycle_time = 0.2
tt.mod = "mod_tower_block_halloween_roots"
tt.sound_events.remove = "GUITowerSell"
tt.main_script.update = scripts.tower_roots_lands_blocked.update

tt = RT("tower_roots_lands_removed", "tower_roots_lands_blocked")
tt.controller = "controller_holder_roots_lands_blocked"
tt.ui.click_rect = r(0, 0, 0, 0)
tt.ui.can_click = nil
tt.ui.can_select = nil
tt.tower.type = nil
tt.cycle_time = nil
tt.mod = nil
tt.sound_events.remove = nil
tt.main_script.update = scripts.holder_roots_lands_removed.update

tt = RT("mod_tower_block_halloween_roots", "mod_tower_common")
tt.cooldown_factor = 2
tt.modifier.duration = 0.3
tt.render.sprites[1].name = "roots_fog_tower_run"
tt.render.sprites[1].anchor = v(0.5, 0.4)
tt.render.sprites[1].offset = v(0, 13)
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "roots_cloud_tower_run"
tt.render.sprites[2].anchor = v(0.5, 0.05)
tt.render.sprites[2].offset = v(0, 13)
tt.render.sprites[2].loop = true
tt.render.sprites[2].z = Z_EFFECTS
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = {
	1,
	2
}
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.7,
		255
	}
}

tt = RT("controller_holder_roots_lands_blocked")
E:add_comps(tt, "main_script", "pos")
tt.holder_id = nil
tt.terrain_style = nil
tt.default_rally_pos = nil
tt.nav_mesh_id = nil
tt.cooldown_min = 15
tt.cooldown_max = 25
tt.main_script.update = scripts.controller_holder_roots_lands_blocked.update