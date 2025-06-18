-- chunkname: @./all/safe_frame_override.lua

local sfo = {}

sfo.db = {
	{
		device = "iPhone14",
		platform = "ios",
		target = "phone",
		safe_factors = {
			0.75,
			nil,
			0.75,
			nil,
			0.55,
			0.55,
			0.55,
			0.55,
			nil,
			nil,
			0,
			0
		}
	},
	{
		device = "iPhone15",
		platform = "ios",
		target = "phone",
		safe_factors = {
			0.85,
			nil,
			0.85,
			nil,
			0.51,
			0.51,
			0.51,
			0.51,
			nil,
			nil,
			0,
			0
		}
	},
	{
		device = "iPhone10,3",
		platform = "ios",
		target = "phone",
		safe_frame = {
			nil,
			nil,
			nil,
			nil,
			25,
			25,
			25,
			25,
			25,
			25,
			25,
			25
		}
	},
	{
		device = "iPhone10,6",
		platform = "ios",
		target = "phone",
		safe_frame = {
			nil,
			nil,
			nil,
			nil,
			25,
			25,
			25,
			25,
			25,
			25,
			25,
			25
		}
	},
	{
		device = "iPhone1[1-9],",
		platform = "ios",
		target = "phone",
		safe_factors = {
			0.75,
			nil,
			0.75,
			nil,
			0.63,
			0.63,
			0.63,
			0.63,
			nil,
			nil,
			0,
			0
		}
	}
}

function sfo:get_override(game, target, platform, os, device)
	for _, row in pairs(self.db) do
		if (not row.game or row.game == game) and (not row.target or row.target == target) and (not row.platform or row.platform == platform) and (not device or not row.device or string.match(device, row.device)) then
			return row
		end
	end
end

return sfo
