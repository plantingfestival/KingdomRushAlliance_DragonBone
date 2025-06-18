-- chunkname: @./lib/klua/nolfs.lua

nolfs = {}

function nolfs.ls(path, patterns)
	local is_windows = love.system.getOS() == "Windows"
	local SEP = is_windows and "\\" or "/"
	local o = {}
	local lines = {}

	if is_windows then
		for n in io.popen("dir /b \"" .. path .. "\""):lines() do
			table.insert(lines, n)
		end
	else
		for n in io.popen("ls " .. path):lines() do
			table.insert(lines, n)
		end
	end

	if patterns then
		for _, n in pairs(lines) do
			for _, k in pairs(patterns) do
				if string.match(n, k) then
					table.insert(o, n)
				end
			end
		end

		return o
	else
		return lines
	end
end

return nolfs
