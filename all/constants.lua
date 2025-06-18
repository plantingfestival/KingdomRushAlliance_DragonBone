IS_KR1 = KR_GAME == "kr1"
IS_KR2 = KR_GAME == "kr2"
IS_KR3 = KR_GAME == "kr3"
IS_KR5 = KR_GAME == "kr5"
IS_TRILOGY = IS_KR1 or IS_KR2 or IS_KR3
IS_PHONE = KR_TARGET == "phone"
IS_TABLET = KR_TARGET == "tablet"
IS_DESKTOP = KR_TARGET == "desktop"
IS_CONSOLE = KR_TARGET == "console"
IS_MOBILE = IS_PHONE or IS_TABLET
NULL = "__NULL__"
FPS = 30
ASPECT = 0.7
REF_W = 1024
REF_H = 768
REF_OX = math.floor((REF_H * 16 / 9 - REF_W) / 2)

if IS_TRILOGY then
	if KR_TARGET == "phone" then
		GUI_REF_W = 480
		GUI_REF_H = 320
	else
		GUI_REF_W = 1024
		GUI_REF_H = 768
	end
else
	GUI_REF_W = 1728
	GUI_REF_H = 768
end

WIDE_SCREEN_ASPECT = 1.775
ULTRAWIDE_SCREEN_ASPECT = 2.053125
ASPECT_16_9 = WIDE_SCREEN_ASPECT
ASPECT_2_053 = ULTRAWIDE_SCREEN_ASPECT
MIN_SCREEN_ASPECT = KR_TARGET == "phone" and 1.5 or 1.3333333333333333

if IS_TRILOGY then
	MAX_SCREEN_ASPECT = KR_TARGET == "phone" and 2.165 or 1.7777777777777777
else
	MAX_SCREEN_ASPECT = KR_TARGET == "phone" and 2.25 or 1.7777777777777777
end

if IS_TRILOGY then
	SAFE_FRAME_DEFAULTS = {
		[ULTRAWIDE_SCREEN_ASPECT] = KR_PLATFORM == "ios" and {
			b = 10,
			l = 25,
			r = 25,
			t = 6
		} or {
			b = 10,
			l = 14,
			r = 14,
			t = 6
		},
		[WIDE_SCREEN_ASPECT] = {
			b = 0,
			l = 0,
			r = 0,
			t = 0
		},
		[0] = {
			b = 0,
			l = 0,
			r = 0,
			t = 0
		}
	}
else
	SAFE_FRAME_DEFAULTS = {
		[ULTRAWIDE_SCREEN_ASPECT] = {
			b = 10,
			l = 14,
			r = 14,
			t = 6
		},
		[WIDE_SCREEN_ASPECT] = {
			b = 6,
			l = 4,
			r = 4,
			t = 6
		},
		[0] = {
			b = 6,
			l = 4,
			r = 4,
			t = 6
		}
	}
end

if IS_TRILOGY then
	HUD_SCALE_STEPS = {
		{
			ULTRAWIDE_SCREEN_ASPECT,
			1
		},
		{
			WIDE_SCREEN_ASPECT,
			1
		},
		{
			0,
			0.85
		}
	}
end

TEXTURE_SIZE_ALIAS = {
	iphone = 480,
	ipadhd = 1536,
	ipad = 768,
	iphonehd = 960,
	fullhd = 1080
}
TEXTURE_SIZE_FACTOR = {
	iphonehd = {
		game = 0.95,
		game_editor = 0.95
	}
}
HOVER_PULSE_PERIOD = 0.66
HOVER_PULSE_ALPHA_MAX = 1
HOVER_PULSE_ALPHA_MIN = 0.6
HOVER_PULSE_ALPHA_MAX_INGAME = 229.5
HOVER_PULSE_ALPHA_MIN_INGAME = 153
Z_BACKGROUND = 1000
Z_BACKGROUND_BETWEEN = 1100
Z_BACKGROUND_COVERS = 1200
Z_TOWER_BASES = 1300
Z_DECALS = 1400
Z_GUI_DECALS = 2000
Z_OBJECTS = 3000
Z_OBJECTS_COVERS = 3100
Z_FLYING_HEROES = 3150
Z_BULLET_PARTICLES = 3200
Z_EFFECTS = 3300
Z_BULLETS = 3400
Z_OBJECTS_SKY = 3500
Z_SCREEN_FIXED = 3900
Z_GUI = 4000
GUI_MODE_IDLE = "IDLE"
GUI_MODE_RALLY_TOWER = "RALLY_TOWER"
GUI_MODE_RALLY_HERO = "RALLY_HERO"
GUI_MODE_RALLY_RE = "RALLY_RE"
GUI_MODE_POWER_1 = "POWER_1"
GUI_MODE_POWER_2 = "POWER_2"
GUI_MODE_POWER_3 = "POWER_3"
GUI_MODE_BAG = "BAG"
GUI_MODE_BAG_ITEM = "BAG_ITEM"
GUI_MODE_TOWER_MENU = "TOWER_MENU"
GUI_MODE_PAUSE = "PAUSE"
GUI_MODE_SHOP_INGAME = "SHOP_INGAME"
GUI_MODE_NOTIFICATION = "NOTIFICATION"
GUI_MODE_WAVE_FLAG = "WAVE_FLAG"
GUI_MODE_SELECT_POINT = "SELECT_POINT"
GUI_MODE_POINTER = "POINTER"
GUI_MODE_DISABLED = "DISABLED"
GUI_MODE_FINISHED = "FINISHED"
GUI_MODE_TUTORIAL_LOCK = "TUTORIAL_LOCK"
GUI_MODE_CINEMATIC_LOCK = "CINEMATIC_LOCK"
GUI_MODE_ITEM_1 = "ITEM_1"
GUI_MODE_ITEM_2 = "ITEM_2"
GUI_MODE_ITEM_3 = "ITEM_3"
GUI_MODE_DRAG_ENTITY = "DRAG_ENTITY"
GUI_MODE_DRAG_RALLY_TOWER = "DRAG_RALLY_TOWER"
GUI_MODE_SWAP_TOWER = "SWAP_TOWER"
GUI_MODE_TOWER_COMBINATION = "TOWER_COMBINATION"
STATS_TYPE_ENEMY = 1
STATS_TYPE_SOLDIER = 2
STATS_TYPE_TOWER = 3
STATS_TYPE_TOWER_BARRACK = 4
STATS_TYPE_TOWER_MAGE = 5
STATS_TYPE_TOWER_NO_RANGE = 6
STATS_TYPE_TEXT = 9
DAMAGE_TRUE = 1
DAMAGE_PHYSICAL = 2
DAMAGE_MAGICAL = 4
DAMAGE_EXPLOSION = 8
DAMAGE_ELECTRICAL = 16
DAMAGE_POISON = 32
DAMAGE_ARMOR = 256
DAMAGE_MAGICAL_ARMOR = 512
DAMAGE_INSTAKILL = 1024
DAMAGE_DISINTEGRATE = 2048
DAMAGE_EAT = 4096
DAMAGE_HOST = 8192
DAMAGE_DISINTEGRATE_BOSS = 16384
DAMAGE_MODIFIER = 32768
DAMAGE_NO_KILL = 8388608
DAMAGE_NO_SPAWNS = 16777216
DAMAGE_NO_DODGE = 33554432
DAMAGE_NO_LIFESTEAL = 67108864
DAMAGE_NO_SHIELD_HIT = 134217728
DAMAGE_ONE_SHIELD_HIT = 268435456
DAMAGE_IGNORE_SHIELD = 536870912
DAMAGE_FX_NOT_EXPLODE = 1073741824
DAMAGE_FX_EXPLODE = 2147483648
DAMAGE_BASE_TYPES = 255
DAMAGE_ALL_TYPES = 16777215
DAMAGE_ALL_FLAGS = 4278190080
DAMAGE_ALL = 4294967295
DAMAGE_NONE = 0
DR_NONE = 0
DR_DAMAGE = 1
DR_KILL = 2
DR_ARMOR = 4
DR_MAGICAL_ARMOR = 8
TERRAIN_STYLE_GRASS = 101
TERRAIN_STYLE_SNOW = 102
TERRAIN_STYLE_WASTELAND = 103
TERRAIN_STYLE_DESERT = 4
TERRAIN_STYLE_JUNGLE = 5
TERRAIN_STYLE_UNDERGROUND = 6
TERRAIN_STYLE_BEACH = 7
TERRAIN_STYLE_HALLOWEEN = 8
TERRAIN_STYLE_ELVEN_WOODS = 1
TERRAIN_STYLE_FAERIE_GROVE = 2
TERRAIN_STYLE_ANCIENT_METROPOLIS = 3
TERRAIN_STYLE_HULKING_RAGE = 4
TERRAIN_STYLE_BITTERING_RANCOR = 5
TERRAIN_STYLE_FORGOTTEN_TREASURES = 6
TERRAIN_STYLE_BLACKBURN = 108
TERRAIN_STYLE_SEA_OF_TREES = 1
TERRAIN_STYLE_SEA_OF_TREES_2 = 2
TERRAIN_STYLE_SEA_OF_TREES_3 = 3
TERRAIN_STYLE_SEA_OF_TREES_4 = 4
TERRAIN_STYLE_SEA_OF_TREES_5 = 5
TERRAIN_STYLE_SEA_OF_TREES_6 = 6
TERRAIN_STYLE_SEA_OF_TREES_7 = 7
TERRAIN_STYLE_SEA_OF_TREES_8 = 8
TERRAIN_STYLE_SEA_OF_TREES_9 = 9
TERRAIN_STYLES = {
	grass = TERRAIN_STYLE_GRASS,
	snow = TERRAIN_STYLE_SNOW,
	wasteland = TERRAIN_STYLE_WASTELAND,
	desert = TERRAIN_STYLE_DESERT,
	jungle = TERRAIN_STYLE_JUNGLE,
	underground = TERRAIN_STYLE_UNDERGROUND,
	beach = TERRAIN_STYLE_BEACH,
	halloween = TERRAIN_STYLE_HALLOWEEN,
	elvenwoods = TERRAIN_STYLE_ELVEN_WOODS,
	faeriegrove = TERRAIN_STYLE_FAERIE_GROVE,
	metropolis = TERRAIN_STYLE_ANCIENT_METROPOLIS,
	hulkingrage = TERRAIN_STYLE_HULKING_RAGE,
	blackburn = TERRAIN_STYLE_BLACKBURN,
	bitteringrancor = TERRAIN_STYLE_BITTERING_RANCOR,
	forgottentreasures = TERRAIN_STYLE_FORGOTTEN_TREASURES,
	seaoftrees = TERRAIN_STYLE_SEA_OF_TREES
}
TERRAIN_NONE = 0
TERRAIN_LAND = 1
TERRAIN_WATER = 2
TERRAIN_CLIFF = 4
TERRAIN_NOWALK = 256
TERRAIN_SHALLOW = 512
TERRAIN_FAERIE = 1024
TERRAIN_ICE = 2048
TERRAIN_FLYING_NOWALK = 4096
TERRAIN_PROPS_COUNT = 4
TERRAIN_TYPES_MASK = 255
TERRAIN_PROPS_MASK = 65280
TERRAIN_ALL_MASK = 65535
F_BLOCK = 1
F_RANGED = 2
F_MOD = 4
F_AREA = 8
F_HERO = 16
F_BOSS = 32
F_MINIBOSS = 64
F_FLYING = 128
F_CLIFF = 256
F_WATER = 512
F_FRIEND = 1024
F_ENEMY = 2048
F_CUSTOM = 4096
F_LETHAL = 8192
F_LAVA = 16384
F_BURN = 16384
F_CANNIBALIZE = 32768
F_BLOOD = 65536
F_DRILL = 131072
F_DRIDER_POISON = 131072
F_EAT = 262144
F_INSTAKILL = 524288
F_POISON = 1048576
F_POLYMORPH = 2097152
F_STUN = 4194304
F_TELEPORT = 8388608
F_THORN = 16777216
F_TWISTER = 16777216
F_RAGGIFY = 16777216
F_NIGHTMARE = 16777216
F_SKELETON = 33554432
F_NET = 67108864
F_DISINTEGRATED = 134217728
F_FREEZE = 268435456
F_ZOMBIE = 536870912
F_SERVANT = 536870912
F_LYCAN = 1073741824
F_DARK_ELF = 1073741824
F_SPELLCASTER = 2147483648
F_NONE = 0
F_ALL = 4294967295
NF_NONE = 0
NF_ALL = 4294967295
NF_RALLY = 1
NF_RANGE = 2
NF_POWER_1 = 128
NF_POWER_2 = 256
NF_POWER_3 = 512
NF_NO_SHADOW = 32768
NF_TWISTER = 65536
NF_NO_EXIT = 131072
UNIT_SIZE_NONE = 0
UNIT_SIZE_SMALL = 1
UNIT_SIZE_MEDIUM = 2
UNIT_SIZE_LARGE = 3
TOWER_SIZE_NONE = 0
TOWER_SIZE_SMALL = 1
TOWER_SIZE_LARGE = 3
TOWER_KIND_ARCHER = 1
TOWER_KIND_BARRACK = 2
TOWER_KIND_ENGINEER = 3
TOWER_KIND_MAGE = 4
TEAM_LINIREA = 1
TEAM_DARK_ARMY = 2
HEALTH_BAR_SIZE_SMALL = "small"
HEALTH_BAR_SIZE_MEDIUM = "med"
HEALTH_BAR_SIZE_MEDIUM_MEDIUM = "med_med"
HEALTH_BAR_SIZE_MEDIUM_LARGE = "med_big"
HEALTH_BAR_SIZE_LARGE = "big"
HEALTH_BAR_SIZES = {
	fullhd = {
		[HEALTH_BAR_SIZE_SMALL] = {
			x = 22,
			y = 3
		},
		[HEALTH_BAR_SIZE_MEDIUM] = {
			x = 34,
			y = 3
		},
		[HEALTH_BAR_SIZE_MEDIUM_MEDIUM] = {
			x = 42,
			y = 4
		},
		[HEALTH_BAR_SIZE_MEDIUM_LARGE] = {
			x = 62,
			y = 4
		},
		[HEALTH_BAR_SIZE_LARGE] = {
			x = 110,
			y = 4
		}
	},
	default = {
		[HEALTH_BAR_SIZE_SMALL] = {
			x = 16,
			y = 2
		},
		[HEALTH_BAR_SIZE_MEDIUM] = {
			x = 24,
			y = 2
		},
		[HEALTH_BAR_SIZE_MEDIUM_MEDIUM] = {
			x = 30,
			y = 3
		},
		[HEALTH_BAR_SIZE_MEDIUM_LARGE] = {
			x = 44,
			y = 3
		},
		[HEALTH_BAR_SIZE_LARGE] = {
			x = 78,
			y = 3
		}
	}
}
HEALTH_BAR_COLORS = {
	black = {
		0,
		0,
		0,
		255
	},
	bg = {
		126,
		0,
		12,
		255
	},
	fg = {
		68,
		174,
		50,
		255
	}
}
HEALTH_BAR_COLORS_KR5 = {
	black = {
		0,
		0,
		0,
		255
	},
	bg = {
		208,
		0,
		23,
		255
	},
	fg = {
		0,
		186,
		0,
		255
	}
}
HEALTH_BAR_COLORS_KR5_CENSORED_CN = {
	black = {
		0,
		0,
		0,
		255
	},
	bg = {
		0,
		0,
		23,
		255
	},
	fg = {
		0,
		186,
		0,
		255
	}
}
HEALTH_BAR_CORNER_DOT_QUAD = {
	0,
	0,
	1,
	1,
	1,
	1
}
BLOOD_NONE = nil
BLOOD_RED = "red"
BLOOD_GREEN = "green"
BLOOD_GRAY = "gray"
BLOOD_VIOLET = "violet"
BLOOD_ORANGE = "orange"
GAME_MODE_CAMPAIGN = 1
GAME_MODE_HEROIC = 2
GAME_MODE_IRON = 3
GAME_MODE_ENDLESS = 4
DIFFICULTY_EASY = 1
DIFFICULTY_NORMAL = 2
DIFFICULTY_HARD = 3
DIFFICULTY_IMPOSSIBLE = 4
COUNT_GROUP_CONCURRENT = 1
COUNT_GROUP_CUMULATIVE = 2
N_ENEMY = 1
N_POWER = 2
N_TIP = 3
N_TOWER = 4
N_TOWER_2 = 5
N_TOWER_4 = 6
N_TUTORIAL = 7
P_LIFETIME = 1
P_LEVEL = 2
P_WAVE = 3
P_SESSION = 4
P_POWER_1 = 5
A_NO_TARGET = 1
A_IN_COOLDOWN = 2
A_DONE = 3
KEYPRESS_ESCAPE = "escape"
KEYPRESS_SPACE = "space"
KEYPRESS_RETURN = "return"
KEYPRESS_1 = "1"
KEYPRESS_2 = "2"
KEYPRESS_3 = "3"
KEYPRESS_4 = "4"
KEYPRESS_5 = "5"
KEYPRESS_6 = "6"
KEYPRESS_Q = "q"
KEYPRESS_W = "w"
KEYPRESS_E = "e"
KEYPRESS_R = "r"
KEYPRESS_F1 = "f1"
KEYPRESS_F2 = "f2"
KEYPRESS_F3 = "f3"
KEYPRESS_F4 = "f4"
KEYPRESS_F5 = "f5"
KEYPRESS_F6 = "f6"
DEFAULT_KEY_MAPPINGS = {
	key_hero_2 = "5",
	key_up = "up",
	key_down = "down",
	key_left = "left",
	key_pow_3 = "3",
	key_wave_info = "q",
	key_pointer = ".",
	key_wave = "w",
	key_right = "right",
	key_pow_1 = "1",
	key_hero_3 = "6",
	key_show_noti = "e",
	key_hero_1 = "4",
	key_pow_2 = "2"
}
I_MOUSE = "mouse"
I_KEYBOARD = "keyboard"
I_GAMEPAD = "gamepad"
I_TOUCH = "touch"
PT_NUMBER = "number"
PT_STRING = "string"
PT_COORDS = "coords"
PT_COLOR = "color"
DEVICE_PROFILE_LOW = 1
DEVICE_PROFILE_MEDIUM = 2
DEVICE_PROFILE_HIGH = 3
ALERT_NODES_TO_DEFEND = 35
MOD_TYPE_BLEED = "bleed"
MOD_TYPE_FAST = "fast"
MOD_TYPE_FREEZE = "freeze"
MOD_TYPE_POISON = "poison"
MOD_TYPE_POLYMORPH = "polymorph"
MOD_TYPE_RAGE = "rage"
MOD_TYPE_SLOW = "slow"
MOD_TYPE_STUN = "stun"
MOD_TYPE_TELEPORT = "teleport"
MOD_TYPE_TIMELAPSE = "timelapse"
AD_TYPE_REWARDED = "rewarded"
AD_TYPE_INTERSTITIAL = "interstitial"
SGN_PS_STATUS_CHANGED = "platform-service-status-changed"
SGN_PS_SYNC_SLOTS_FINISHED = "platform-service-sync-slots-finished"
SGN_PS_SYNC_SETTINGS_FINISHED = "platform-service-sync-settings-finished"
SGN_PS_PUSH_SLOT_FINISHED = "platform-service-push-slot-finished"
SGN_PS_DELETE_SLOT_FINISHED = "platform-service-delete-slot-finished"
SGN_PS_PUSH_SETTINGS_FINISHED = "platform-service-push-settings-finished"
SGN_PS_SYNC_PRODUCTS_FINISHED = "platform-service-sync-products-finished"
SGN_PS_SYNC_PURCHASES_FINISHED = "platform-service-sync-purchases-finished"
SGN_PS_SYNC_PURCHASE_HISTORY_FINISHED = "platform-service-sync-purchase-history-finished"
SGN_PS_PURCHASE_PRODUCT_FINISHED = "platform-service-purchase-product-finished"
SGN_PS_PURCHASE_PRODUCT_PENDING = "platform-service-purchase-product-pending"
SGN_PS_RESTORE_PURCHASES_FINISHED = "platform-service-restore-purchases-finished"
SGN_PS_PREMIUM_UNLOCKED = "platform-service-premium-unlocked"
SGN_PS_AD_SHOW_VIDEO_STARTED = "platform-service-ad-show-video-started"
SGN_PS_AD_SHOW_VIDEO_FINISHED = "platform-service-ad-show-video-finished"
SGN_PS_REMOTE_CONFIG_SYNC_FINISHED = "platform-service-remote-config-sync-finished"
SGN_PS_SYNC_ACHIEVEMENTS_FINISHED = "platform-service-achievements-sync-finished"
SGN_PS_CHECK_DRM_FINISHED = "platform-service-check-drm-finished"
SGN_PS_NEWS_CACHED = "platfor-service-news-cached"
SGN_PS_NEWS_IMAGE_CACHED = "platfor-service-news-image-cached"
SGN_PS_NEWS_URL_SHOWN = "platform-service-url-shown"
SGN_PS_NEWS_URL_CLICKED = "platform-service-url-clicked"
SGN_PS_HTTP_GET_FINISHED = "platform-service-http-get-finished"
SGN_PS_AUTH_STARTED = "platform-service-auth-started"
SGN_PS_AUTH_FINISHED = "platform-service-auth-finished"
SGN_PS_CHANNEL_QUIT_REQUESTED = "platform-service-channel-quit-requested"
SGN_PS_CONSOLE_NO_JOYSTICK_PRESENT = "platform-service-console-no-joystick-present"
SGN_PS_CONSOLE_JOYSTICK_PRESENT = "platform-service-console-joystick-present"
SGN_FS_COMMIT_STARTED = "filesystem-commit-started"
SGN_FS_COMMIT_ENDED = "filesystem-commit-ended"
SGN_REMOTE_CONFIG_UPDATED = "remote-config-updated"
SGN_MARKETING_OFFER_SHOWN = "marketing-offer-shown"
SGN_MARKETING_OFFER_ICON_TOUCHED = "marketing-offer-icon-touched"
SGN_MARKETING_OFFER_CLICKED = "marketing-offer-clicked"
SGN_DIRECTOR_ITEM_SHOWN = "director-item-shown"
SGN_GAME_GUI_PAUSE_SHOW = "game-gui-pause-show"
SGN_GAME_GUI_PAUSE_HIDE = "game-gui-pause-hide"
SGN_SHOP_GEMS_CHANGED = "shop-gems-changed"
SGN_SHOP_SHOW_IAP_PROGRESS = "shop-show-iap-progress"
SGN_SHOP_SHOW_MESSAGE = "shop-show-message"
SGN_SHOW_GEMS_STORE = "show-gems-store"
SGN_SHOP_SHOWN = "shop-shown"
SGN_SHOP_HIDDEN = "shop-hidden"
SGN_FULLADS_WORKFLOW_ICON_TOUCHED = "fullads-workflow-icon-touched"
SGN_FULLADS_SHOW_MESSAGE = "fullads-show-message"
SGN_FULLADS_REWARDS_SHOWN = "fullads-rewards-shown"
SGN_FULLADS_REWARDS_HIDDEN = "fullads-rewards-hidden"
SGN_PS_DEEP_LINK_CHANGED = "deep-link-changed"
SGN_PS_SYNC_CONSENT_STATUS_FINISHED = "platform-service-sync-consent-status-finished"
SGN_PS_SHOW_CONSENT_FORM_FINISHED = "platform-service-show-consent-form-finished"
SGN_PS_SHOW_CONSENT_OPTIONS_FINISHED = "platform-service-show-consent-options-finished"
SGN_PS_SCREEN_SLOTS_READY = "screen_slots-ready"
SGN_PS_SCREEN_MAP_READY = "screen_map-ready"
SGN_PS_PUSH_NOTI_SHOULD_SHOW_RATIONALE = "platform-service-push-noti-should-show-rationale"
SGN_PS_PUSH_NOTI_PERMISSION_FINISHED = "platform-service-push-noti-permission-finished"
SGN_PS_GOLIATH_LIBRA_RESPONSE_RECEIVED = "platgorm-service-goliath-libra-response-received"
SGN_PS_REMOTE_BALANCE_SYNC_STARTED = "platform-service-remote-balance-sync-started"
SGN_PS_REMOTE_BALANCE_WAVES_CACHED = "platform-service-remote-balance-sheets-cached"

function OV(dimension, default, ...)
	local dims = {
		game = KR_GAME,
		target = KR_TARGET,
		platform = KR_PLATFORM,
		os = KR_OS
	}
	local dimv = dims[dimension]

	if not dimv then
		return default
	end

	local args = {
		...
	}

	if #args > 0 then
		for i, a in ipairs(args) do
			if i % 2 == 1 and a == dimv then
				return args[i + 1]
			end
		end
	end

	return default
end

function OVG(default, ...)
	return OV("game", default, ...)
end

function OVT(default, ...)
	return OV("target", default, ...)
end

function OVP(default, ...)
	return OV("platform", default, ...)
end

function OVO(default, ...)
	return OV("os", default, ...)
end

OV_PHONE = "phone"
OV_TABLET = "tablet"
OV_DESKTOP = "desktop"
OV_CONSOLE = "console"

function OVtargets(default, phone, tablet, desktop, console)
	return OVT(default, OV_PHONE, phone, OV_TABLET, tablet, OV_DESKTOP, desktop, OV_CONSOLE, console)
end

function OVm(default, mobile)
	return OVT(default, OV_PHONE, mobile, OV_TABLET, mobile)
end

function OVnm(default, notmobile)
	return OVT(default, OV_DESKTOP, notmobile, OV_DESKTOP, notmobile)
end