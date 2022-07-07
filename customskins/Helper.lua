function customskins.writeSkinToStorage(storage, name, skin)
	if skin then
		storage:set_string(name, skin:serialize())
	end
end


function customskins.getSkinFromStorage(storage, name)
	if storage:contains(name) then
		return Skin.deserialize(storage:get_string(name))
	end
	return Skin.new();
end


function customskins.setPlayerSkin(name, str)
	if minetest.get_modpath("3d_armor") then
		armor.textures[name].skin = str
		armor:update_skin(name)
	else
		player_api.set_textures(minetest.get_player_by_name(name), {str})
	end
end


function copy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
	return res
end
