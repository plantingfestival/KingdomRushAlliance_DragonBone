-- chunkname: @./all/challenges.lua

local log = require("klua.log"):new("challenges")

require("klua.table")

local storage = require("storage")
local RC = require("remote_config")
local rc4 = require("plc.rc4")
local bin = require("plc.bin")
local challenges = {}

challenges.spec_version = 3
challenges.enable_when_level_completed = 4
challenges.first_level_enabled = 2

local challenges_es = {
	"Ush0uldGETaL1F3!",
	"Ush0uldGETaL1F3!",
	"Ush0uldGETaL1F3!"
}
local hero_codes = {
	{},
	{
		"hero_alric",
		"hero_mirage",
		"hero_beastmaster",
		"hero_voodoo_witch",
		"hero_pirate",
		"hero_wizard",
		"hero_priest",
		"hero_giant",
		"hero_alien",
		"hero_crab",
		"hero_monk",
		"hero_van_helsing",
		"hero_minotaur",
		"hero_monkey_god",
		"hero_dragon",
		"hero_dracolich"
	},
	{}
}
local hero_skills_level = {
	{},
	{
		0,
		0,
		1,
		1,
		1,
		1,
		2,
		2,
		2,
		3
	},
	{
		0,
		0,
		1,
		1,
		1,
		1,
		2,
		2,
		2,
		3
	}
}
local tower_locks = {
	{},
	{
		{
			[0] = {
				"tower_build_archer",
				"tower_totem",
				"tower_crossbow"
			},
			{
				"tower_archer_2",
				"tower_totem",
				"tower_crossbow"
			},
			{
				"tower_archer_3",
				"tower_totem",
				"tower_crossbow"
			},
			{
				"tower_totem",
				"tower_crossbow"
			},
			{
				"tower_totem",
				"tower_crossbow"
			},
			{
				"tower_totem",
				"tower_crossbow"
			},
			{
				"tower_totem",
				"tower_crossbow"
			},
			{
				"tower_crossbow"
			},
			{
				"tower_totem"
			},
			[15] = {}
		},
		{
			[0] = {
				"tower_build_barrack",
				"tower_assassin",
				"tower_templar"
			},
			{
				"tower_barrack_2",
				"tower_assassin",
				"tower_templar"
			},
			{
				"tower_barrack_3",
				"tower_assassin",
				"tower_templar"
			},
			{
				"tower_assassin",
				"tower_templar"
			},
			{
				"tower_assassin",
				"tower_templar"
			},
			{
				"tower_assassin",
				"tower_templar"
			},
			{
				"tower_assassin",
				"tower_templar"
			},
			{
				"tower_templar"
			},
			{
				"tower_assassin"
			},
			[15] = {}
		},
		{
			[0] = {
				"tower_build_engineer",
				"tower_dwaarp",
				"tower_mech"
			},
			{
				"tower_engineer_2",
				"tower_dwaarp",
				"tower_mech"
			},
			{
				"tower_engineer_3",
				"tower_dwaarp",
				"tower_mech"
			},
			{
				"tower_dwaarp",
				"tower_mech"
			},
			{
				"tower_dwaarp",
				"tower_mech"
			},
			{
				"tower_dwaarp",
				"tower_mech"
			},
			{
				"tower_dwaarp",
				"tower_mech"
			},
			{
				"tower_mech"
			},
			{
				"tower_dwaarp"
			},
			[15] = {}
		},
		{
			[0] = {
				"tower_build_mage",
				"tower_archmage",
				"tower_necromancer"
			},
			{
				"tower_mage_2",
				"tower_archmage",
				"tower_necromancer"
			},
			{
				"tower_mage_3",
				"tower_archmage",
				"tower_necromancer"
			},
			{
				"tower_archmage",
				"tower_necromancer"
			},
			{
				"tower_archmage",
				"tower_necromancer"
			},
			{
				"tower_archmage",
				"tower_necromancer"
			},
			{
				"tower_archmage",
				"tower_necromancer"
			},
			{
				"tower_necromancer"
			},
			{
				"tower_archmage"
			},
			[15] = {}
		},
		{}
	},
	{}
}
local item_names = {
	{
		"coins",
		"hearts",
		"freeze",
		"dynamite",
		"atomic_freeze",
		"atomic_bomb"
	},
	{
		"coins",
		"hearts",
		"freeze",
		"dynamite",
		"atomic_freeze",
		"atomic_bomb"
	}
}
local reward_names = {
	{
		"gems",
		"coins",
		"hearts",
		"freeze",
		"dynamite"
	},
	{
		"gems",
		"coins",
		"hearts",
		"freeze",
		"dynamite"
	}
}
local item_locks = {
	{},
	{
		[0] = item_names[2],
		{
			"hearts",
			"freeze",
			"dynamite",
			"atomic_freeze",
			"atomic_bomb"
		},
		{
			"coins",
			"freeze",
			"dynamite",
			"atomic_freeze",
			"atomic_bomb"
		},
		{
			"coins",
			"hearts",
			"dynamite",
			"atomic_freeze",
			"atomic_bomb"
		},
		{
			"coins",
			"hearts",
			"freeze",
			"atomic_freeze",
			"atomic_bomb"
		},
		{
			"coins",
			"hearts",
			"freeze",
			"dynamite",
			"atomic_bomb"
		},
		{
			"coins",
			"hearts",
			"freeze",
			"dynamite",
			"atomic_freeze"
		},
		[10] = {
			"coins",
			"hearts",
			"atomic_freeze",
			"atomic_bomb"
		}
	},
	{}
}
local acid_format = {
	{
		{
			1,
			"spec_version"
		},
		{
			1,
			"game_id"
		},
		{
			2,
			"level_idx"
		},
		{
			1,
			"game_mode"
		},
		{
			1,
			"difficulty"
		},
		{
			2,
			"tower_count"
		},
		{
			1,
			"tower_1_level"
		},
		{
			1,
			"tower_2_level"
		},
		{
			1,
			"tower_3_level"
		},
		{
			1,
			"tower_4_level"
		},
		{
			1,
			"tower_5_level"
		},
		{
			2,
			"hero1"
		},
		{
			2,
			"hero2"
		},
		{
			1,
			"pow1"
		},
		{
			1,
			"pow2"
		},
		{
			1,
			"pow3"
		},
		{
			1,
			"items"
		},
		{
			1,
			function(v)
				return v == "R"
			end,
			{
				{
					3,
					"gems"
				},
				{
					1,
					"dynamite"
				},
				{
					1,
					"freeze"
				},
				{
					1,
					"hearts"
				},
				{
					1,
					"coins"
				}
			}
		}
	},
	{
		{
			1,
			"spec_version"
		},
		{
			1,
			"game_id"
		},
		{
			2,
			"level_idx"
		},
		{
			1,
			"game_mode"
		},
		{
			1,
			"difficulty"
		},
		{
			1,
			"upgrade_level"
		},
		{
			2,
			"tower_count"
		},
		{
			1,
			"tower_1_level"
		},
		{
			1,
			"tower_2_level"
		},
		{
			1,
			"tower_3_level"
		},
		{
			1,
			"tower_4_level"
		},
		{
			1,
			"tower_5_level"
		},
		{
			2,
			"hero1"
		},
		{
			2,
			"hero2"
		},
		{
			1,
			"pow1"
		},
		{
			1,
			"pow2"
		},
		{
			1,
			"pow3"
		},
		{
			1,
			"items"
		},
		{
			1,
			function(v)
				return v == "R"
			end,
			{
				{
					3,
					"gems"
				},
				{
					1,
					"dynamite"
				},
				{
					1,
					"freeze"
				},
				{
					1,
					"hearts"
				},
				{
					1,
					"coins"
				}
			}
		}
	},
	{
		{
			1,
			"spec_version"
		},
		{
			1,
			"game_id"
		},
		{
			2,
			"level_idx"
		},
		{
			1,
			"game_mode"
		},
		{
			1,
			"difficulty"
		},
		{
			1,
			"upgrade_level"
		},
		{
			2,
			"tower_count"
		},
		{
			1,
			"tower_1_level"
		},
		{
			1,
			"tower_2_level"
		},
		{
			1,
			"tower_3_level"
		},
		{
			1,
			"tower_4_level"
		},
		{
			1,
			"tower_5_level"
		},
		{
			2,
			"hero1"
		},
		{
			1,
			"hero1_level"
		},
		{
			2,
			"hero2"
		},
		{
			1,
			"hero2_level"
		},
		{
			1,
			"pow1"
		},
		{
			1,
			"pow2"
		},
		{
			1,
			"pow3"
		},
		{
			1,
			"items"
		},
		{
			1,
			function(v)
				return v == "R"
			end,
			{
				{
					3,
					"gems"
				},
				{
					1,
					"dynamite"
				},
				{
					1,
					"freeze"
				},
				{
					1,
					"hearts"
				},
				{
					1,
					"coins"
				}
			}
		}
	}
}

local function get_game_id()
	return tonumber(string.sub(KR_GAME, 3, 3))
end

local function get_hero_idx(name)
	for i, v in ipairs(hero_codes[get_game_id()]) do
		if v == name then
			return i
		end
	end

	return false
end

local function get_item_names()
	return item_names[get_game_id()]
end

function challenges:get_format_length(spec_version, with_optionals)
	local function count_format(f, inc_opts)
		local count = 0

		for _, token in pairs(f) do
			if type(token[2]) == "function" then
				if inc_opts then
					count = count + token[1] + count_format(token[3], inc_opts)
				end
			else
				count = count + token[1]
			end
		end

		return count
	end

	local f = acid_format[spec_version]

	return count_format(f, with_optionals)
end

function challenges:is_ofuscated(acid)
	return string.sub(acid, 1, 1) == "O"
end

function challenges:ofuscate(acid)
	if self:is_ofuscated(acid) then
		log.error("already ofuscated: %s", acid)

		return acid
	end

	local enc = rc4.rc4(challenges_es[self.spec_version], acid)
	local henc = bin.stohex(enc)

	return "O" .. henc
end

function challenges:deofuscate(oacid)
	if not self:is_ofuscated(oacid) then
		log.error("not ofuscated: %s", oacid)

		return oacid
	end

	local henc = string.sub(oacid, 2, #oacid)
	local enc = bin.hextos(henc)
	local acid = rc4.rc4(challenges_es[self.spec_version], enc)

	return acid
end

function challenges:validate(oacid)
	local acid = self:deofuscate(oacid)

	if not acid or acid == "" then
		return false
	end

	local spec_version = string.sub(acid, 1, 1)

	if not spec_version or spec_version == "" then
		return false
	end

	spec_version = tonumber(spec_version)

	return string.len(acid) == self:get_format_length(spec_version, string.find(acid, "R"))
end

function challenges:parse(acid, d, pos, format)
	d = d or {}
	pos = pos or 1

	local spec_version = tonumber(string.sub(acid, 1, 1), 16)

	format = format or acid_format[spec_version]

	for _, token in pairs(format) do
		local s = string.sub(acid, pos, pos + token[1] - 1)

		if type(token[2]) == "function" then
			log.paranoid("parsing optional part at pos:%s", pos)

			if token[2](s) then
				self:parse(acid, d, pos + token[1], token[3])
			end
		else
			log.paranoid("parsing %s at pos:%s of len:%s", token[2], pos, token[1])

			d[token[2]] = tonumber(s, 16)
			pos = pos + token[1]
		end
	end

	if spec_version < self.spec_version then
		local default = self:get_default_data(d.gems ~= nil)

		for k, v in pairs(default) do
			if not d[k] then
				log.info("migrating acid:%s : adding %s=%s", acid, k, v)

				d[k] = v
			end
		end
	end

	return d
end

function challenges:serialize(data)
	local acid = ""

	local function fmt(f, s)
		acid = acid .. string.format(f, s)
	end

	if self.spec_version >= 1 or self.spec_version <= 3 then
		if get_game_id() < 5 then
			data.tower_5_level = data.tower_5_level or 0
			data.hero2 = data.hero2 or 0

			if self.spec_version >= 3 then
				data.hero2_level = data.hero2_level or 0
			end
		end

		fmt("%01x", self.spec_version)
		fmt("%01x", get_game_id())
		fmt("%02x", data.level_idx)
		fmt("%01x", data.game_mode)
		fmt("%01x", data.difficulty)

		if self.spec_version >= 2 then
			fmt("%01x", data.upgrade_level)
		end

		fmt("%02x", data.tower_count)
		fmt("%01x", data.tower_1_level)
		fmt("%01x", data.tower_2_level)
		fmt("%01x", data.tower_3_level)
		fmt("%01x", data.tower_4_level)
		fmt("%01x", data.tower_5_level)
		fmt("%02x", data.hero1)

		if self.spec_version >= 3 then
			fmt("%01x", data.hero1_level)
		end

		fmt("%02x", data.hero2)

		if self.spec_version >= 3 then
			fmt("%01x", data.hero2_level)
		end

		fmt("%01x", data.pow1)
		fmt("%01x", data.pow2)
		fmt("%01x", data.pow3)
		fmt("%01x", data.items)

		if data.gems then
			fmt("%s", "R")
			fmt("%03x", data.gems)
			fmt("%01x", data.dynamite)
			fmt("%01x", data.freeze)
			fmt("%01x", data.hearts)
			fmt("%01x", data.coins)
		end
	end

	if not self:validate(acid) then
		log.error("acid did not validate:%s for data:\n%s", acid, getfulldump(data))
	end

	return acid
end

function challenges:get_default_data(with_rewards)
	local d = {
		pow3 = 0,
		tower_5_level = 0,
		tower_4_level = 0,
		level_idx = 2,
		pow1 = 0,
		items = 0,
		tower_2_level = 0,
		tower_1_level = 0,
		difficulty = 1,
		tower_3_level = 0,
		tower_count = 255,
		pow2 = 0,
		game_mode = 1,
		hero1 = 0,
		hero2 = 0,
		spec_version = self.spec_version,
		game_id = get_game_id()
	}

	if with_rewards then
		d.gems = 10
		d.dynamite = 1
		d.freeze = 1
		d.hearts = 0
		d.coins = 0
	end

	if self.spec_version >= 2 then
		d.upgrade_level = 15
	end

	if self.spec_version >= 3 then
		d.hero1_level = 15
		d.hero2_level = 15
	end

	return d
end

function challenges:get_default_acid(with_rewards)
	local d = self:get_default_data(with_rewards)

	return self:encode(d, true)
end

function challenges:strip_rewards(data)
	for _, k in pairs(reward_names[get_game_id()]) do
		data[k] = nil
	end
end

function challenges:decode_acid(oacid)
	local acid = oacid

	if string.sub(oacid, 1, 1) == "O" then
		acid = self:deofuscate(oacid)
	end

	local d = self:parse(acid)

	d.id = oacid
	d.acid = oacid

	return d
end

function challenges:decode_acid_for_game(acid)
	local d = self:decode_acid(acid)

	if not d then
		return nil
	end

	if d.spec_version ~= self.spec_version then
		log.warning("spec_version %s is older than current", d.spec_version)
	end

	if d.game_id ~= get_game_id() then
		log.error("game_id %s is not compatible with wirrent KR_GAME:%s", d.game_id, get_game_id())

		return
	end

	local o = {}

	o.id = acid
	o.acid = acid
	o.level_idx = d.level_idx
	o.game_mode = d.game_mode
	o.difficulty = d.difficulty

	local li

	if not item_locks[d.game_id] then
		log.error("could not find item_locks for game_id:%s", d.game_id)

		return
	end

	li = item_locks[d.game_id][d.items]

	local lh = {
		d.hero1 == 0,
		d.hero2 == 0
	}
	local fh = {
		false,
		false
	}
	local hl = {
		d.hero1_level and d.hero1_level ~= 15 and d.hero1_level or nil,
		d.hero2_level and d.hero2_level ~= 15 and d.hero2_level or nil
	}

	for i = 1, 2 do
		local k = "hero" .. i

		if d[k] ~= 255 and d[k] ~= 0 then
			if not hero_codes[d.game_id] then
				log.error("could not find hero_codes for game_id:%s", d.game_id)

				return nil
			end

			fh[i] = hero_codes[d.game_id][tonumber(d[k])]

			if not fh then
				log.error("could not find hero_codes for hero index:%s", d[k])

				return nil
			end
		end
	end

	local lt = {}

	for i = 1, 5 do
		local k = "tower_" .. i .. "_level"

		if not tower_locks[d.game_id] then
			log.error("could not find tower_locks for game_id:%s", d.game_id)

			return
		elseif not tower_locks[d.game_id][i] then
			log.error("could not find tower_locks for tower:%s", i)

			return
		elseif i == 5 and get_game_id() > 3 and not tower_locks[d.game_id][i][d[k]] then
			log.error("could not find tower_locks for %s", k)

			return
		end

		local list = tower_locks[d.game_id][i][d[k]]

		if list then
			lt = table.append(lt, list)
		end
	end

	o.restrictions = {
		tower_count = d.tower_count < 255 and d.tower_count or nil,
		upgrade_level = d.upgrade_level and d.upgrade_level < 15 and d.upgrade_level or nil,
		locked_towers = lt,
		locked_powers = {
			d.pow1 == 0,
			d.pow2 == 0,
			d.pow3 == 0
		},
		locked_items = li
	}

	if get_game_id() <= 3 then
		o.restrictions.locked_hero = lh[1]
		o.restrictions.forced_hero = fh[1]
		o.restrictions.forced_hero_level = hl[1]

		if hl[1] and get_game_id() >= 2 then
			o.restrictions.forced_hero_skills_level = hero_skills_level[get_game_id()][hl[1]]
		end
	else
		o.restrictions.locked_heroes = lh
		o.restrictions.forced_heroes = fh
		o.restrictions.forced_hero_levels = hl
	end

	if d.gems then
		o.rewards = {
			gems = d.gems,
			dynamite = d.dynamite,
			freeze = d.freeze,
			hearts = d.hearts,
			coins = d.coins
		}
	end

	return o
end

function challenges:encode(data, ofuscate)
	local acid = self:serialize(data)

	if ofuscate then
		acid = self:ofuscate(acid)
	end

	return acid
end

function challenges:filter_schedule(schedule)
	local out = {}
	local now = os.time()
	local duration = 604800
	local countdown_to

	if not schedule or type(schedule) ~= "table" then
		log.error("challenges_schedule is empty or not a table")

		return out, countdown_to
	end

	for _, row in pairs(schedule) do
		if type(row) ~= "table" or not row.from or not row.acids then
			log.error("challenges_schedule row is invalid. skipping...")
		else
			local from_parts = string.split(row.from, "-")

			if not from_parts or #from_parts ~= 3 then
				log.error("challenges_schedule \"from\" key is invalid. skipping...")
			else
				local from = os.time({
					year = from_parts[1],
					month = from_parts[2],
					day = from_parts[3]
				})
				local actual_duration = row.days and row.days * 24 * 60 * 60 or duration
				local diff = os.difftime(now, from)

				if diff > 0 and diff < actual_duration then
					countdown_to = from + actual_duration

					for _, acid in pairs(row.acids) do
						table.insert(out, acid)
					end
				end
			end
		end
	end

	return out, countdown_to
end

function challenges:extract_acid_from_url(url)
	if not url or url == "" then
		log.info("empty url")

		return
	end

	local acid = string.match(url, RC and RC.v.challenges_share_url_pattern or ".+%?acid=(.*)$")

	if not acid or acid == "" or string.len(acid) < 1 or not self:validate(acid) then
		log.error("could not find acid parameter in %s", url)

		return
	end

	local data = self:decode_acid(acid)

	self:strip_rewards(data)

	local nacid = self:encode(data, true)

	if nacid ~= acid then
		log.warning("cleanup modified the acid from %s --> %s", acid, nacid)
	end

	log.info("-- link pasted ---")
	log.info("ofuscated   acid: %s", nacid)
	log.info("deofuscated acid: %s", self:deofuscate(nacid))
	log.info("------------------")

	return nacid
end

function challenges:sort_list(list)
	table.sort(list, function(a1, a2)
		if a1.ts and a2.ts then
			return a1.ts > a2.ts
		else
			return a1.acid < a2.acid
		end
	end)
end

function challenges:list_completed()
	local out = {}
	local user_data = storage:load_slot()

	if not user_data.challenges_completed then
		return out
	end

	for k, v in pairs(user_data.challenges_completed) do
		table.insert(out, {
			acid = k,
			stars = v.stars,
			ts = v.ts
		})
	end

	self:sort_list(out)

	return out
end

function challenges:is_completed(acid)
	local user_data = storage:load_slot()
	local completed = user_data.challenges_completed and user_data.challenges_completed[acid] and user_data.challenges_completed[acid].stars and user_data.challenges_completed[acid].stars > 0
	local stars = completed and user_data.challenges_completed[acid].stars or nil
	local lives = completed and user_data.challenges_completed[acid].lives or nil

	return completed, stars, lives
end

function challenges:set_completed(acid, stars)
	local user_data = storage:load_slot()

	user_data.challenges_completed = user_data.challenges_completed or {}

	local previous = user_data.challenges_completed[acid]

	if previous and previous.stars and stars < previous.stars then
		log.debug("previous challenge has more stars, skipping save")

		return
	end

	user_data.challenges_completed[acid] = {
		stars = stars,
		ts = os.time()
	}

	storage:save_slot(user_data)
end

function challenges:get_from_list(list_name, decode)
	local out = {}
	local user_data = storage:load_slot()

	if list_name == "weekly" then
		if not RC and RC.v and RC.v.challenges_schedule then
			return out
		end

		local acids, countdown_to = self:filter_schedule(RC.v.challenges_schedule)

		out.countdown_to = countdown_to

		for _, acid in pairs(acids) do
			local data = self:decode_acid(acid)

			if not data then
				log.error("could not read challenge data for %s", acid)
			elseif user_data.levels[data.level_idx] and (user_data.levels[data.level_idx].stars or 0) > 0 then
				local row = {
					acid = acid
				}

				if decode then
					row.data = self:decode_acid(acid)
				end

				table.insert(out, row)
			end
		end
	elseif list_name == "created" or list_name == "received" then
		if not user_data.challenges_lists or not user_data.challenges_lists[list_name] then
			return out
		end

		local items = user_data.challenges_lists[list_name] or {}

		for k, v in pairs(items) do
			local row = {
				acid = k,
				ts = v.ts
			}

			if decode then
				row.data = self:decode_acid(k)
			end

			table.insert(out, row)
		end
	end

	self:sort_list(out)

	return out
end

function challenges:add_to_list(list_name, acid)
	if list_name ~= "created" and list_name ~= "received" then
		log.error("list_name unknown %s", list_name)

		return
	end

	local user_data = storage:load_slot()

	user_data.challenges_lists = user_data.challenges_lists or {}
	user_data.challenges_lists[list_name] = user_data.challenges_lists[list_name] or {}
	user_data.challenges_lists[list_name][acid] = {
		ts = os.time()
	}

	storage:save_slot(user_data)
end

function challenges:remove_from_list(list_name, acid)
	if list_name ~= "created" and list_name ~= "received" then
		log.error("list_name unknown %s", list_name)

		return
	end

	local user_data = storage:load_slot()

	if not user_data.challenges_lists or not user_data.challenges_lists[list_name] then
		return
	end

	user_data.challenges_lists[list_name][acid] = nil

	storage:save_slot(user_data)
end

function challenges:get_share_url(acid)
	local oacid = self:ofuscate(acid)

	return string.format(RC.v.challenges_share_url_fmt, acid)
end

challenges.test_data = {
	{
		s = string.gsub("1 2 02 1 1 ff 3 0 0 0 0 00 00 0 0 0 0 R 00a 1 1 0 0", " ", ""),
		d = {
			pow3 = 0,
			tower_5_level = 0,
			hearts = 0,
			tower_4_level = 0,
			level_idx = 2,
			pow1 = 0,
			items = 0,
			dynamite = 1,
			spec_version = 1,
			tower_2_level = 0,
			coins = 0,
			tower_1_level = 3,
			game_id = 2,
			difficulty = 1,
			tower_3_level = 0,
			tower_count = 255,
			pow2 = 0,
			gems = 10,
			game_mode = 1,
			hero1 = 0,
			freeze = 1,
			hero2 = 0
		},
		g = {
			level_idx = 2,
			game_mode = 1,
			difficulty = 1,
			restrictions = {
				forced_hero = false,
				locked_hero = true,
				locked_towers = {
					"tower_totem",
					"tower_crossbow",
					"tower_build_barrack",
					"tower_assassin",
					"tower_templar",
					"tower_build_engineer",
					"tower_dwaarp",
					"tower_mech",
					"tower_build_mage",
					"tower_archmage",
					"tower_necromancer"
				},
				locked_powers = {
					true,
					true,
					true
				},
				locked_items = item_names[2]
			},
			rewards = {
				coins = 0,
				dynamite = 1,
				hearts = 0,
				gems = 10,
				freeze = 1
			}
		}
	},
	{
		s = string.gsub("1 2 02 3 3 0a 3 2 1 f 0 01 00 f 0 0 1", " ", ""),
		d = {
			pow3 = 0,
			tower_5_level = 0,
			spec_version = 1,
			tower_4_level = 15,
			level_idx = 2,
			pow1 = 15,
			items = 1,
			tower_2_level = 2,
			tower_1_level = 3,
			game_id = 2,
			difficulty = 3,
			tower_3_level = 1,
			tower_count = 10,
			pow2 = 0,
			game_mode = 3,
			hero1 = 1,
			hero2 = 0
		},
		g = {
			level_idx = 2,
			difficulty = 3,
			game_mode = 3,
			restrictions = {
				forced_hero = "hero_alric",
				tower_count = 10,
				locked_hero = false,
				locked_towers = {
					"tower_totem",
					"tower_crossbow",
					"tower_barrack_3",
					"tower_assassin",
					"tower_templar",
					"tower_engineer_2",
					"tower_dwaarp",
					"tower_mech"
				},
				locked_powers = {
					false,
					true,
					true
				},
				locked_items = {
					"hearts",
					"freeze",
					"dynamite",
					"atomic_freeze",
					"atomic_bomb"
				}
			}
		}
	},
	{
		s = string.gsub("2 2 02 1 1 f ff 3 0 0 0 0 00 00 0 0 0 0 R 00a 1 1 0 0", " ", ""),
		d = {
			tower_5_level = 0,
			tower_4_level = 0,
			hearts = 0,
			tower_2_level = 0,
			upgrade_level = 15,
			pow1 = 0,
			items = 0,
			pow3 = 0,
			dynamite = 1,
			level_idx = 2,
			spec_version = 2,
			tower_1_level = 3,
			game_id = 2,
			coins = 0,
			difficulty = 1,
			tower_3_level = 0,
			tower_count = 255,
			pow2 = 0,
			gems = 10,
			game_mode = 1,
			hero1 = 0,
			freeze = 1,
			hero2 = 0
		},
		g = {
			level_idx = 2,
			game_mode = 1,
			difficulty = 1,
			restrictions = {
				forced_hero = false,
				locked_hero = true,
				locked_towers = {
					"tower_totem",
					"tower_crossbow",
					"tower_build_barrack",
					"tower_assassin",
					"tower_templar",
					"tower_build_engineer",
					"tower_dwaarp",
					"tower_mech",
					"tower_build_mage",
					"tower_archmage",
					"tower_necromancer"
				},
				locked_powers = {
					true,
					true,
					true
				},
				locked_items = item_names[2]
			},
			rewards = {
				coins = 0,
				dynamite = 1,
				hearts = 0,
				gems = 10,
				freeze = 1
			}
		}
	},
	{
		s = string.gsub("2 2 02 3 3 1 0a 3 2 1 f 0 01 00 f 0 0 1", " ", ""),
		d = {
			tower_5_level = 0,
			tower_4_level = 15,
			spec_version = 2,
			tower_2_level = 2,
			upgrade_level = 1,
			pow1 = 15,
			items = 1,
			pow3 = 0,
			level_idx = 2,
			tower_1_level = 3,
			game_id = 2,
			difficulty = 3,
			tower_3_level = 1,
			tower_count = 10,
			pow2 = 0,
			game_mode = 3,
			hero1 = 1,
			hero2 = 0
		},
		g = {
			level_idx = 2,
			difficulty = 3,
			game_mode = 3,
			restrictions = {
				forced_hero = "hero_alric",
				tower_count = 10,
				upgrade_level = 1,
				locked_hero = false,
				locked_towers = {
					"tower_totem",
					"tower_crossbow",
					"tower_barrack_3",
					"tower_assassin",
					"tower_templar",
					"tower_engineer_2",
					"tower_dwaarp",
					"tower_mech"
				},
				locked_powers = {
					false,
					true,
					true
				},
				locked_items = {
					"hearts",
					"freeze",
					"dynamite",
					"atomic_freeze",
					"atomic_bomb"
				}
			}
		}
	},
	{
		s = string.gsub("2 2 02 1 1 f ff 3 0 0 0 0 00f 00f 0 0 0 0 R 00a 1 1 0 0", " ", ""),
		d = {
			tower_1_level = 3,
			tower_5_level = 0,
			hearts = 0,
			pow1 = 0,
			hero2_level = 15,
			upgrade_level = 15,
			items = 0,
			pow3 = 0,
			pow2 = 0,
			level_idx = 2,
			dynamite = 1,
			tower_4_level = 0,
			game_id = 2,
			tower_2_level = 0,
			difficulty = 1,
			tower_3_level = 0,
			tower_count = 255,
			hero1_level = 15,
			coins = 0,
			spec_version = 3,
			gems = 10,
			game_mode = 1,
			hero1 = 0,
			freeze = 1,
			hero2 = 0
		},
		g = {
			level_idx = 2,
			game_mode = 1,
			difficulty = 1,
			restrictions = {
				forced_hero = false,
				locked_hero = true,
				locked_towers = {
					"tower_totem",
					"tower_crossbow",
					"tower_build_barrack",
					"tower_assassin",
					"tower_templar",
					"tower_build_engineer",
					"tower_dwaarp",
					"tower_mech",
					"tower_build_mage",
					"tower_archmage",
					"tower_necromancer"
				},
				locked_powers = {
					true,
					true,
					true
				},
				locked_items = item_names[2]
			},
			rewards = {
				coins = 0,
				dynamite = 1,
				hearts = 0,
				gems = 10,
				freeze = 1
			}
		}
	},
	{
		s = string.gsub("2 2 02 3 3 1 0a 3 2 1 f 0 011 00f f 0 0 1", " ", ""),
		d = {
			tower_1_level = 3,
			tower_5_level = 0,
			tower_2_level = 2,
			pow1 = 15,
			hero2_level = 15,
			upgrade_level = 1,
			items = 1,
			pow3 = 0,
			pow2 = 0,
			level_idx = 2,
			tower_4_level = 15,
			game_id = 2,
			difficulty = 3,
			tower_3_level = 1,
			tower_count = 10,
			hero1_level = 1,
			spec_version = 3,
			game_mode = 3,
			hero1 = 1,
			hero2 = 0
		},
		g = {
			level_idx = 2,
			difficulty = 3,
			game_mode = 3,
			restrictions = {
				forced_hero = "hero_alric",
				forced_hero_level = 1,
				tower_count = 10,
				upgrade_level = 1,
				locked_hero = false,
				locked_towers = {
					"tower_totem",
					"tower_crossbow",
					"tower_barrack_3",
					"tower_assassin",
					"tower_templar",
					"tower_engineer_2",
					"tower_dwaarp",
					"tower_mech"
				},
				locked_powers = {
					false,
					true,
					true
				},
				locked_items = {
					"hearts",
					"freeze",
					"dynamite",
					"atomic_freeze",
					"atomic_bomb"
				}
			}
		}
	}
}

function challenges:compare_test_s(idx, s)
	local ts = self.test_data[idx].s

	if ts ~= s then
		log.error("strings differ - test:%s vs s:%s", ts, s)

		return false
	else
		return true
	end
end

function challenges:compare_test_d(idx, d)
	local td = self.test_data[idx].d

	for k, v in pairs(td) do
		if not d[k] or d[k] ~= v then
			log.error("key %s differs: %s ~= %s", k, v, d[k])

			return false
		end
	end

	for k, v in pairs(d) do
		if not td[k] then
			log.error("key %s is missing from test_data", k)

			return false
		end
	end

	return true
end

function challenges:compare_test_g(g1, g2, msg)
	local ok = true

	local function cmp(key, t1, t2)
		if t1[key] ~= t2[key] then
			log.error("  TEST %s failed comparing %s", msg, key)

			ok = false
		end
	end

	local function cmp_sets(key, t1, t2)
		for _, p in pairs({
			{
				t1[key],
				t2[key]
			},
			{
				t2[key],
				t1[key]
			}
		}) do
			for _, v in pairs(p[1]) do
				if not table.contains(p[2], v) then
					log.error("  TEST %s failed. Set %s does not have %s", msg, key, v)

					ok = false
				end
			end
		end
	end

	local function cmp_arrays(key, t1, t2)
		for i, v in ipairs(t1[key]) do
			if t2[key][i] ~= v then
				log.error("  TEST %s failed. Array items %s at %s differ", msg, key, i)

				ok = false
			end
		end
	end

	cmp("level_idx", g1, g2)
	cmp("game_mode", g1, g2)
	cmp("difficulty", g1, g2)
	cmp_sets("locked_towers", g1.restrictions, g2.restrictions)
	cmp_arrays("locked_powers", g1.restrictions, g2.restrictions)

	if get_game_id() <= 3 then
		cmp("locked_hero", g1.restrictions, g2.restrictions)
		cmp("forced_hero", g1.restrictions, g2.restrictions)
	else
		cmp_arrays("locked_heroes", g1.restrictions, g2.restrictions)
		cmp_arrays("forced_heroes", g1.restrictions, g2.restrictions)
	end

	cmp("tower_count", g1.restrictions, g2.restrictions)
	cmp("upgrade_level", g1.restrictions, g2.restrictions)

	if type(g1.restrictions.locked_items) == "table" then
		cmp_sets("locked_items", g1.restrictions, g2.restrictions)
	else
		cmp("locked_items", g1.restrictions, g2.restrictions)
	end

	return ok
end

function challenges:run_tests()
	for i, item in pairs(challenges.test_data) do
		if item.d.spec_version > self.spec_version then
			log.error("version %s not supported!", item.d.spec_version)
		elseif item.d.spec_version < self.spec_version then
			if not self:compare_test_g(self:decode_acid_for_game(item.s), item.g, tostring(i)) then
				log.error("TEST decode_acid_for_game failed for %s", item.s)

				return false
			end
		else
			if self:serialize(self:parse(item.s)) ~= item.s then
				log.error("TEST acid->data->acid failed for %s", item.s)

				return false
			end

			if not self:compare_test_g(self:decode_acid_for_game(item.s), item.g, tostring(i)) then
				log.error("TEST decode_acid_for_game failed for %s", item.s)

				return false
			end
		end
	end

	log.info("all tests passed")

	return true
end

return challenges
