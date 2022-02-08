Part = {
	texture = "",
	color = 1.0,
	lightness = 1.0,
	saturation = 1.0,
	metatable = {}
}


function Part.new()
	local part = {}
	setmetatable(part, Part.metatable)
	return part
end


Part.metatable.__tostring = function(self)
	return "(" .. self.texture .. ".png)"
end


Part.metatable.__index = Part


-- Example output: "{skin_default,1.0,1.0,1.0}"
function Part.serialize(self)
	if self then
		return "{" .. table.concat({self.texture, self.color, self.lightness, self.saturation}, "," ) .. "}"
	end
	return nil
end


-- Example input: "{skin_default,1.0,1.0,1.0}"
function Part.deserialize(str)
	str = str:sub(2,-2)
	local words = {}
	for v in str:gmatch("[^,]+") do
		table.insert(words, v)
	end
	if #words == 4 then
		local part = Part.new()
		part.texture = words[1]
		part.color = tonumber(words[2])
		part.lightness = tonumber(words[3])
		part.saturation = tonumber(words[4])
		if part.texture and part.color and part.lightness and part.saturation then
			return part
		end
	end
	return nil
end