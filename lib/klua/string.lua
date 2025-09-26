-- chunkname: @./lib/klua/string.lua

function string.split(s, sepchars)
	local ret = {}

	for w in string.gmatch(s, "[^" .. sepchars .. "]+") do
		ret[#ret + 1] = w
	end

	return ret
end

function string.split_by_char(s, sepchar)
	local ret = {}
	local si = 1

	for i = 1, #s do
		if string.sub(s, i, i) == sepchar then
			table.insert(ret, string.sub(s, si, i - 1))

			si = i + 1
		end
	end

	table.insert(ret, string.sub(s, si, #s))

	return ret
end

function string.trim(s)
	return string.gsub(string.gsub(s, "%s+$", ""), "^%s+", "")
end

function string.starts(s, a)
	if s == a then
		return true
	end

	if not s or not a or a == "" or string.len(s) < string.len(a) then
		return false
	end

	local sa = string.sub(s, 1, string.len(a))

	return sa == a
end

function string.ends(s, a)
	if s == a then
		return true
	end

	if not s or not a or a == "" or string.len(s) < string.len(a) then
		return false
	end

	local sa = string.sub(s, string.len(s) - string.len(a) + 1, string.len(s))

	return sa == a
end
