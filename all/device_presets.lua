-- chunkname: @./all/device_presets.lua

local log = require("klua.log")

require("klua.table")

local device_presets = {}

device_presets.db = {
	reference = {
		height = 768,
		width = 1366,
		safe_frame = {
			0,
			0,
			0,
			0
		}
	},
	iphone10 = {
		height = 1125,
		width = 2436,
		safe_frame = {
			132,
			0,
			132,
			63,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		}
	},
	iphone11 = {
		height = 828,
		width = 1792,
		safe_frame = {
			60,
			0,
			0,
			20,
			0,
			0,
			0,
			0
		}
	},
	ipad = {
		height = 768,
		width = 1024,
		safe_frame = {
			0,
			0,
			0,
			0
		}
	},
	ipadmini6a = {
		height = 768,
		width = 1170,
		safe_frame = {
			0,
			0,
			0,
			0
		}
	}
}

function device_presets:get_config(device_id)
	return self.db[device_id]
end

return device_presets
