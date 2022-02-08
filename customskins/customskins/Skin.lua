--- @class Skin
Skin = {
	parts = {},
	order = {},
	size = 1.0,
	width = 1.0,
	metatable = {}
}


--- Creates a new valid skin
-- @return default skin table
function Skin.new()
	local skin = {}
	setmetatable(skin, Skin.metatable)
	return skin
end


Skin.metatable.__tostring = function(self)
	local parts = {}
	for _, v in pairs(self.order) do
		table.insert(parts, tostring(self.parts[v]))
	end
	return "(" .. table.concat(parts, "^") .. ")"
end


Skin.metatable.__index = Skin


-- Example output: "{{{...};{...};{...}}:{1;3;2}:1.0:1.0}"
function Skin.serialize(self)
	if self then
		local parts = {}
		for _, v in pairs(self.parts) do
			table.insert(parts, v:serialize())
		end
		parts = "{" .. table.concat(parts, ";") .. "}"
		local order = "{" .. table.concat(self.order, ";") .. "}"
		return "{" .. table.concat({parts, order, self.size, self.width}, ":") .. "}"
	end
	return nil
end


-- Example input: "{{{...};{...};{...}}:{1;3;2}:1.0:1.0}"
function Skin.deserialize(str)
	if str then
		str = str:sub(2,-2)
		local words = {}
		for v in str:gmatch("[^:]+") do
			table.insert(words, v)
		end
		if #words == 4 then
			local skin = Skin.new()
			skin.parts = {}
			words[1] = words[1]:sub(2,-2)
			for v in words[1]:gmatch("[^;]+") do
				table.insert(skin.parts, Part.deserialize(v))
			end
			skin.order = {}
			words[2] = words[2]:sub(2,-2)
			for v in words[2]:gmatch("[^;]+") do
				table.insert(skin.order, tonumber(v))
			end
			skin.size = tonumber(words[3])
			skin.width = tonumber(words[4])
			if skin.parts and skin.order and skin.size and skin.width then
				return skin
			end
		end
	end
	return nil
end