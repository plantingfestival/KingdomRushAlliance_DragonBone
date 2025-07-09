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
local scripts = require("custom_scripts_0")

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

tt = E:register_t("entities_delay_controller")
E:add_comps(tt, "pos", "main_script", "sound_events")
tt.main_script.update = scripts.entities_delay_controller.update
tt.start_ts = nil
tt.delays = nil
tt.entities = nil

tt = E:register_t("controller_spawn_on_path", "entities_delay_controller")
tt.main_script.update = scripts.controller_spawn_on_path.update
tt.path_index = nil
tt.direction = -1
tt.start_nodes_offset = 0
tt.exclude_first_position = nil
tt.nodes_between_objects = 2
tt.delay_between_objects = fts(1)
tt.entities = {}
tt.delays = {}
tt.max_entities = 1
tt.entity_name = nil
tt.random_offset = {}
tt.random_offset.x = {}
tt.random_offset.x.min = 0
tt.random_offset.x.max = 0
tt.random_offset.y = {}
tt.random_offset.y.min = 0
tt.random_offset.y.max = 0

tt = E:register_t("rain_controller", "entities_delay_controller")
tt.main_script.update = scripts.rain_controller.update
tt.entities = {}
tt.delays = {}
tt.delay_between_objects = fts(1)
tt.radius = 0
tt.max_entities = 1
tt.entity_name = nil

tt = E:register_t("flame", "bullet")
tt.bullet.flight_time = 1
tt.delay_betweeen_flames = fts(1)
tt.flame_bullet = nil
tt.flames_count = 30
tt.main_script.insert = scripts.flame.insert
tt.main_script.update = scripts.flame.update

tt = E:register_t("flame_bullet")
E:add_comps(tt, "pos", "render")
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BULLETS

tt = E:register_t("controller_item_hero", "controller_item")
tt.main_script.insert = scripts.controller_item_hero.insert
tt.can_fire_fn = scripts.controller_item_summon_blackburn.can_fire_fn
tt.vis_bans = 0
tt.vis_flags = 0
tt.allowed_templates = nil
tt.excluded_templates = nil
tt.entity = nil

tt = E:register_t("KR5Tower", "tower_KR5")
E:add_comps(tt, "vis")

tt = RT("kr4_tower_holder", "tower_holder")
tt.tower.terrain_style = 401

tt = RT("fx_repeat_forever")
E:add_comps(tt, "main_script", "render")
tt.main_script.update = scripts.fx_repeat_forever.update
tt.random_shift = nil
tt.max_delay = nil
tt.min_delay = nil
tt.render.sprites[1].loop = nil
tt.render.sprites[1].time_offset = 0

tt = RT("controller_teleport_enemies")
E:add_comps(tt, "main_script")
tt.path = nil
tt.start_ni = nil
tt.end_ni = nil
tt.duration = nil
tt.main_script.update = scripts.controller_teleport_enemies.update


-- custom_templates_1
package.loaded.custom_templates_1 = nil
require("custom_templates_1")

-- custom_templates_2
package.loaded.custom_templates_2 = nil
require("custom_templates_2")

-- kr3_game_templates
package.loaded.kr3_game_templates = nil
require("kr3_game_templates")

-- kr2_game_templates
package.loaded.kr2_game_templates = nil
require("kr2_game_templates")

-- kr1_game_templates
package.loaded.kr1_game_templates = nil
require("kr1_game_templates")
