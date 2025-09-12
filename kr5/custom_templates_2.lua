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

tt = E:register_t("enemy_bone_carrier", "enemy_KR5")
E:add_comps(tt, "melee", "moon", "death_spawns", "auras", "regen")
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "moon_enemy_aura"
tt.auras.list[1].cooldown = 0
tt.auras.list[2] = E:clone_c("aura_attack")
tt.auras.list[2].name = "aura_bone_carrier_damage_multiplier"
tt.auras.list[2].cooldown = 0
tt.death_spawns.name = "bone_carrier_death_aura"
tt.death_spawns.concurrent_with_death = true
tt.enemy.lives_cost = 2
tt.enemy.gold = 95
tt.enemy.melee_slot = v(27, 0)
tt.health.armor = 0.8
tt.health.hp_max = 1400
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 48)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.info.portrait = "bottom_info_image_enemies_0067"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.kr4_enemy_mixed.update
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 160
tt.melee.attacks[1].damage_min = 120
tt.melee.attacks[1].hit_time = fts(13)
tt.moon.speed_factor = 2
tt.moon.regen_hp = 4
tt.motion.max_speed = 15
tt.regen.cooldown = 0.25
tt.regen.health = 0
tt.render.sprites[1].prefix = "bone_carrier"
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "bone_carrier_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.22)
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.death = "dwarves_sulfur_alchemist_death"
tt.ui.click_rect = r(-35, -5, 70, 54)
tt.unit.blood_color = BLOOD_RED
tt.unit.hit_offset = v(0, 20)
tt.unit.head_offset = v(0, 46)
tt.unit.mod_offset = v(0, 21)
tt.unit.marker_offset = v(0, 0)
tt.unit.size = UNIT_SIZE_MEDIUM

tt = E:register_t("bone_carrier_death_aura", "aura")
tt.aura.duration = 0.1
tt.aura.mods = {
	"mod_bone_carrier_death_heal"
}
tt.aura.cycle_time = 1e+99
tt.aura.radius = 125
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("mod_bone_carrier_death_heal", "modifier")
E:add_comps(tt, "hps", "render", "tween")
tt.modifier.duration = 1
tt.modifier.allows_duplicates = true
tt.modifier.use_mod_offset = false
tt.hps.heal_min = 300
tt.hps.heal_max = 300
tt.hps.heal_every = 1e+99
tt.render.sprites[1].name = "haunted_skeleton_modifier_damage_fx_run"
tt.render.sprites[1].anchor = v(0.5, 0)
tt.render.sprites[1].loop = true
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].size_scales = {
	vv(1),
	vv(1.3),
	vv(1.5)
}
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
tt.tween.remove = nil
tt.fade_in = true
tt.fade_out = true
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps_with_fade.update

tt = E:register_t("aura_bone_carrier_damage_multiplier", "aura")
tt.aura.duration = -1
tt.aura.mods = {
	"mod_bone_carrier_damage_multiplier"
}
tt.aura.cycle_time = 0.2
tt.aura.radius = 75
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = 0
tt.aura.targets_per_cycle = 12
tt.aura.track_source = true
tt.aura.allowed_templates = {
	"enemy_haunted_skeleton"
}
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("mod_bone_carrier_damage_multiplier", "modifier")
E:add_comps(tt, "render", "tween")
tt.modifier.duration = 1
tt.modifier.use_mod_offset = false
tt.inflicted_damage_factor = 1.5
tt.render.sprites[1].name = "bone_carrier_modifier_loop"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS + 2
tt.fade_in = true
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
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {
	{
		0,
		v(0, 0)
	},
	{
		fts(6),
		v(1, 1)
	}
}
tt.main_script.insert = scripts.mod_fury.insert
tt.main_script.remove = scripts.mod_fury.remove
tt.main_script.update = scripts.mod_track_target_with_fade.update

tt = E:register_t("enemy_haunted_skeleton", "enemy_KR5")
E:add_comps(tt, "melee", "moon", "death_spawns", "auras", "regen")
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "moon_enemy_aura"
tt.auras.list[1].cooldown = 0
tt.death_spawns.name = "haunted_skeleton_death_aura"
tt.death_spawns.concurrent_with_death = true
tt.enemy.lives_cost = 1
tt.enemy.gold = 22
tt.enemy.melee_slot = v(10, 0)
tt.health.armor = 0
tt.health.magic_armor = 0.8
tt.health.hp_max = 160
tt.health_bar.offset = v(0, 30)
tt.info.portrait = "bottom_info_image_enemies_0069"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.kr4_enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(9)
tt.moon.speed_factor = 5 / 3
tt.moon.regen_hp = 4
tt.motion.max_speed = 30
tt.regen.cooldown = 0.25
tt.regen.health = 0
tt.render.sprites[1].prefix = "haunted_skeleton"
tt.render.sprites[1].anchor.y = 0.257
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[1].name = "raise"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "haunted_skeleton_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.257)
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.death = "haunted_skeleton_death"
tt.ui.click_rect = r(-21, -5, 42, 33)
tt.unit.blood_color = BLOOD_RED
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 28)
tt.unit.mod_offset = v(0, 17)
tt.unit.marker_offset = v(0, 0)

tt = E:register_t("haunted_skeleton_death_aura", "bone_carrier_death_aura")
tt.aura.mods = {
	"mod_haunted_skeleton_death_heal",
	"mod_haunted_skeleton_damage_multiplier"
}

tt = E:register_t("mod_haunted_skeleton_death_heal", "mod_bone_carrier_death_heal")
tt.hps.heal_min = 100
tt.hps.heal_max = 100

tt = E:register_t("mod_haunted_skeleton_damage_multiplier", "modifier")
tt.modifier.duration = 3
tt.modifier.allows_duplicates = true
tt.inflicted_damage_factor = 1.2
tt.main_script.insert = scripts.mod_fury.insert
tt.main_script.remove = scripts.mod_fury.remove
tt.main_script.update = scripts.mod_track_target_with_fade.update

tt = E:register_t("enemy_kr4_ghost", "enemy_KR5")
E:add_comps(tt, "auras")
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "ghost_sound_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 16
tt.enemy.melee_slot = v(10, 0)
tt.health.armor = 1
tt.health.hp_max = 110
tt.health.immune_to = bor(DAMAGE_PHYSICAL, DAMAGE_EXPLOSION, DAMAGE_ELECTRICAL, DAMAGE_POISON)
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 47)
tt.info.portrait = "bottom_info_image_enemies_0068"
tt.info.i18n_key = "ENEMY_GHOST"
tt.motion.max_speed = 35
tt.render.sprites[1].prefix = "ghost"
tt.render.sprites[1].anchor.y = 0.166
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[1].name = "raise"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "ghost_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.166)
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.unit.blood_color = BLOOD_NONE
tt.unit.show_blood_pool = false
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 30)
tt.unit.head_offset = v(0, 45)
tt.unit.mod_offset = v(0, 30)
tt.unit.marker_offset = v(0, 0)
tt.sound_events.death = "puff_death_sound"
tt.sound_events.insert = nil
tt.ui.click_rect = r(-32, -5, 64, 42)
tt.vis.bans = bor(F_SKELETON, F_BLOOD, F_DRILL, F_POISON, F_STUN, F_BLOCK, F_THORN, F_POLYMORPH)
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.kr4_enemy_mixed.update

tt = E:register_t("enemy_corrosive_soul", "enemy_KR5")
E:add_comps(tt, "melee", "moon", "auras", "regen")
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "moon_enemy_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.lives_cost = 1
tt.enemy.gold = 70
tt.enemy.melee_slot = v(18, 0)
tt.health.armor = 0.5
tt.health.magic_armor = 0
tt.health.hp_max = 700
tt.health_bar.offset = v(0, 42)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "bottom_info_image_enemies_0066"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.kr4_enemy_mixed.update
tt.melee.attacks[1].cooldown = 0.6
tt.melee.attacks[1].damage_max = 45
tt.melee.attacks[1].damage_min = 35
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_time = fts(14)
tt.moon.speed_factor = 1.5
tt.moon.regen_hp = 4
tt.motion.max_speed = 65
tt.regen.cooldown = 0.25
tt.regen.health = 0
tt.render.sprites[1].prefix = "corrosive_soul"
tt.render.sprites[1].anchor.y = 0.125
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "corrosive_soul_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.125)
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.death = "corrosive_soul_death"
tt.ui.click_rect = r(-31, -5, 62, 40)
tt.unit.blood_color = BLOOD_NONE
tt.unit.hit_offset = v(0, 20)
tt.unit.head_offset = v(0, 30)
tt.unit.mod_offset = v(0, 21)
tt.unit.marker_offset = v(0, 0)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.particle = "ps_corrosive_soul_fx"

tt = E:register_t("ps_corrosive_soul_fx")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "corrosive_soul_fx_run"
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.track_offset = v(0, 30)
tt.particle_system.emission_rate = 3
tt.particle_system.animation_fps = 30
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_OBJECTS + 2

tt = RT("enemy_lich", "enemy_KR5")
AC(tt, "melee", "ranged", "timed_attacks", "moon", "auras", "regen")
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "moon_enemy_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 85
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(12, 0)
tt.health.armor = 0
tt.health.magic_armor = 0.9
tt.health.hp_max = 400
tt.health_bar.offset = v(0, 42)
tt.info.portrait = "bottom_info_image_enemies_0070"
tt.motion.max_speed = 18
tt.moon.speed_factor = 5 / 3
tt.moon.regen_hp = 4
tt.regen.cooldown = 0.25
tt.regen.health = 0
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 70
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(14)
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].bullet = "lich_ray"
tt.ranged.attacks[1].bullet_start_offset = {
	v(15, 48)
}
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].shoot_time = fts(19)
tt.ranged.attacks[1].animation = "shoot"
tt.timed_attacks.list[1] = E:clone_c("spawn_attack")
tt.timed_attacks.list[1].skill = "spawner"
tt.timed_attacks.list[1].can_be_silenced = true
tt.timed_attacks.list[1].disabled_if_having_modifiers = {
	"mod_possession"
}
tt.timed_attacks.list[1].melee_break = nil
tt.timed_attacks.list[1].ranged_break = true
tt.timed_attacks.list[1].cooldown = 10
tt.timed_attacks.list[1].animation = "special"
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].spawn_delay = fts(3)
tt.timed_attacks.list[1].nodes_to_entrance = 1
tt.timed_attacks.list[1].nodes_to_exit = 40
tt.timed_attacks.list[1].min_nodes = 5
tt.timed_attacks.list[1].max_nodes = 5
tt.timed_attacks.list[1].use_center = nil
tt.timed_attacks.list[1].random_subpath = true
tt.timed_attacks.list[1].max_count = 1
tt.timed_attacks.list[1].entity_chances = {
	1,
}
tt.timed_attacks.list[1].entity_names = {
	"enemy_haunted_skeleton",
}
tt.render.sprites[1].anchor = v(0.5, 0.176)
tt.render.sprites[1].prefix = "lich"
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "lich_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.176)
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.unit.blood_color = BLOOD_RED
tt.unit.hit_offset = v(0, 18)
tt.unit.head_offset = v(0, 40)
tt.unit.mod_offset = v(0, 17)
tt.ui.click_rect = r(-25, -5, 50, 42)
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.sound_events.death = "frog_erudite_shot"
tt.main_script.update = scripts.kr4_enemy_mixed.update

tt = E:register_t("lich_ray", "bullet")
tt.image_width = 98
tt.main_script.update = scripts.ray_enemy.update
tt.render.sprites[1].name = "lich_ray_travel"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_min = 60
tt.bullet.damage_max = 90
tt.bullet.hit_time = fts(6)
tt.bullet.hit_fx = "lich_ray_hit_fx"
tt.sound_events.insert = nil

tt = RT("lich_ray_hit_fx", "fx")
tt.render.sprites[1].name = "lich_ray_hit_fx_run"

tt = E:register_t("swamp_spawner", "decal_scripted")
E:add_comps(tt, "spawner", "render", "sound_events", "editor")
tt.animation_group = "animation"
tt.render.sprites[1].name = ""
tt.render.sprites[1].anchor.y = 0.390625
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].hidden = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = ""
tt.render.sprites[2].anchor.y = 0.390625
tt.render.sprites[2].animated = true
tt.render.sprites[2].loop = nil
tt.render.sprites[2].hidden = true
tt.render.sprites[2].group = tt.animation_group
tt.spawn_animation = "decal_swamp_bubble_jump"
tt.spawn_sound = nil
tt.spawn_sound_args = nil
tt.main_script.update = scripts.swamp_spawner.update

tt = E:register_t("decal_spider_rotten_egg_shooter", "decal_scripted")
E:add_comps(tt, "ranged", "spawner", "editor")
tt.ranged.attacks[1].bullet = "bomb_spider_rotten_egg"
tt.ranged.attacks[1].cooldown = 10
tt.main_script.update = scripts.decal_spider_rotten_egg_shooter.update

tt = E:register_t("bomb_spider_rotten_egg", "bomb")
tt.bullet.damage_min = 100
tt.bullet.damage_max = 100
tt.bullet.damage_radius = 60
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.pop = nil
tt.bullet.hit_fx = "fx_explosion_rotten_shot"
tt.bullet.hit_decal = nil
tt.bullet.hit_payload = "enemy_spider_rotten_egg"
tt.bullet.flight_time = fts(30)
tt.bullet.rotation_speed = 2 * math.pi
tt.render.sprites[1].name = "rotten_egg_0001"
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].animated = false
tt.sound_events.insert = "swamp_thing_bomb_shot"
tt.sound_events.hit = "swamp_thing_bomb_explosion"
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update

tt = RT("enemy_chaser", "enemy")

AC(tt, "melee", "timed_attacks")

tt.enemy.gold = 16
tt.enemy.lives_cost = 1
tt.enemy.melee_slot = v(13, 0)
tt.health.armor = 0.5
tt.health.hp_max = 400
tt.health_bar.offset = v(0, 25)
tt.info.i18n_key = "ENEMY_ANURIAN_CHASER"
tt.info.portrait = "gui_bottom_info_image_enemies_0099"
tt.motion.max_speed = 26
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].hit_time = fts(18)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.timed_attacks.list[1] = E:clone_c("jump_attack")
tt.timed_attacks.list[1].skill = "jump_target"
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].damage_max = 60
tt.timed_attacks.list[1].damage_min = 60
tt.timed_attacks.list[1].max_range = 260
tt.timed_attacks.list[1].min_range = 30
tt.timed_attacks.list[1].is_area_damage = true
tt.timed_attacks.list[1].damage_radius = 60
tt.timed_attacks.list[1].flight_time = fts(18)
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].node_limit = 80
tt.timed_attacks.list[1].search_type = U.search_type.nearest
tt.timed_attacks.list[1].search_stream = U.search_stream.only_upstream
tt.timed_attacks.list[1].cast_time = fts(19)
tt.timed_attacks.list[1].need_back = false
tt.timed_attacks.list[1].backed_attack = true
tt.timed_attacks.list[1].loops = 1
tt.timed_attacks.list[1].animations = {
	"jumpIn",
	"loop",
	"jumpOut"
}
tt.timed_attacks.list[1].sound = "frog_chaser_jump"
tt.timed_attacks.list[1].hit_fx = "chaser_jump_hit_fx"
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.render.sprites[1].anchor = v(0.5, 0.176)
tt.render.sprites[1].prefix = "chaser"
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[1].animated = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "chaser_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.176)
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.unit.blood_color = BLOOD_RED
tt.unit.hit_offset = v(0, 18)
tt.unit.mod_offset = v(0, 4)
tt.unit.head_offset = v(0, 40)
tt.ui.click_rect = r(-30, -8, 45, 30)
tt.vis.flags = bor(F_ENEMY)
tt.main_script.update = scripts.kr4_enemy_mixed.update

tt = E:register_t("chaser_jump_hit_fx", "fx")

tt.render.sprites[1].prefix = "chaser_jump_hit_fx"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true

tt = E:register_t("enemy_warden", "enemy")

AC(tt, "melee", "timed_attacks")

tt.enemy.gold = 55
tt.enemy.lives_cost = 1
tt.enemy.melee_slot = v(8, 0)
tt.health.armor = 0.8
tt.health.hp_max = 600
tt.health_bar.offset = v(0, 40)
tt.info.i18n_key = "ENEMY_ANURIAN_WARDEN"
tt.info.portrait = "gui_bottom_info_image_enemies_0102"
tt.motion.max_speed = 25
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].animation = "hit"
tt.melee.attacks[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.render.sprites[1].anchor = v(0.5, 0.176)
tt.render.sprites[1].prefix = "warden"
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[1].animated = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "warden_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.176)
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.unit.blood_color = BLOOD_RED
tt.unit.hit_offset = v(0, 5)
tt.unit.mod_offset = v(0, 20)
tt.unit.head_offset = v(0, 40)
tt.ui.click_rect = r(-23, 3, 45, 40)
tt.vis.flags = bor(F_ENEMY)
tt.main_script.update = scripts.kr4_enemy_mixed.update

tt = E:register_t("enemy_amphiptere", "enemy")

tt.enemy.gold = 7
tt.health.hp_max = 70
tt.health_bar.offset = v(0, 42)
tt.info.i18n_key = "ENEMY_CRYSTAL_AMPHIPTERE"
tt.info.portrait = "gui_bottom_info_image_enemies_0101"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 60
tt.render.sprites[1].prefix = "amphiptere"
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[1].offset = v(0, 30)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "amphiptere_shadow"
tt.render.sprites[2].offset = v(0, 30)
tt.ui.click_rect = r(-18, 10, 28, 30)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, 35)
tt.unit.mod_offset = v(0, 30)
tt.unit.hide_after_death = true
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_THORN, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)

tt = RT("enemy_crystal_demolisher", "enemy")

AC(tt, "melee")

tt.enemy.gold = 80
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(12, 0)
tt.health.armor = 0
tt.health.hp_max = 1400
tt.health_bar.offset = v(0, 60)
tt.info.i18n_key = "ENEMY_CRYSTAL_DEMOLISHER"
tt.info.portrait = "gui_bottom_info_image_enemies_0102"
tt.motion.max_speed = 16
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].damage_max = 240
tt.melee.attacks[1].damage_min = 130
tt.melee.attacks[1].hit_time = fts(20)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.render.sprites[1].anchor = v(0.5, 0.176)
tt.render.sprites[1].prefix = "bullywags_golem"
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[1].animated = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "bullywags_golem_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.176)
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.unit.blood_color = BLOOD_RED
tt.unit.hit_offset = v(0, 10)
tt.unit.mod_offset = v(0, 25)
tt.unit.head_offset = v(0, 40)
tt.ui.click_rect = r(-12, 12, 53, 65)
tt.vis.flags = bor(F_ENEMY)
tt.main_script.update = scripts.kr4_enemy_mixed.update
