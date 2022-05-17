customskins = {}
customskins.modpath = minetest.get_modpath("customskins")
local storage = minetest.get_mod_storage()

if not customskins.workingSkin then
	customskins.workingSkin = {}
	customskins.appliedSkin = {}
	customskins.selectedTab = {}
	customskins.previewBackview = {}
end




dofile(customskins.modpath.."/Skin.lua")
dofile(customskins.modpath.."/Part.lua")
dofile(customskins.modpath.."/Helper.lua")

local order_str = "skin,face,legs,body1,body2,hair,shoes,misc"
local categorys = nil
local tabContents = nil
local tabHeader = nil
local ordered_keys = {}

local preview_x = 1.05
local preview_y = 0.85
local preview_w = 2.4
local preview_h = preview_w * 2
local preview_px_size = preview_w / 16


function sortedKeys(query, sortFunction)
  local keys, len = {}, 0
  for k,_ in pairs(query) do
    len = len + 1
    keys[len] = k
  end
  table.sort(keys, sortFunction)
  return keys
end


minetest.register_on_joinplayer(
	function (ObjectRef, last_login)
		local name = ObjectRef:get_player_name()
		if storage:contains(name) then
			customskins.workingSkin[name] = Skin.deserialize(storage:get_string(name))
		else
			customskins.workingSkin[name] = customskins.getDefaultSkin()
		end
		customskins.appliedSkin[name] = nil
		minetest.after(3, function(name)
			if minetest.get_player_by_name(name) ~= nil then
				customskins.setPlayerSkin(name, tostring(customskins.workingSkin[name]))
			end
		end, name)
	end
)


minetest.register_on_leaveplayer(
	function(ObjectRef, timed_out)
		local name = ObjectRef:get_player_name()
		if customskins.appliedSkin[name] then
			storage:set_string(name, customskins.appliedSkin[name]:serialize())
		end
		customskins.workingSkin[name] = nil
		customskins.appliedSkin[name] = nil
		customskins.selectedTab[name] = nil
		customskins.previewBackview[name] = nil
	end
)


minetest.register_chatcommand("skin", {
	func = function(name, param)
		customskins.selectedTab[name] = "1"
		customskins.previewBackview[name] = false
		minetest.show_formspec(name, "customskins:skineditor", customskins.getFormspec(name))
	end
})


minetest.register_chatcommand("skin-info", {
	func = function(name, param)
		if customskins.workingSkin[name] then
			minetest.chat_send_all("customskins.workingSkin[name]: " .. customskins.workingSkin[name]:serialize())
		else
			minetest.chat_send_all("customskins.workingSkin[name]: nil")
		end
		if customskins.appliedSkin[name] then
			minetest.chat_send_all("customskins.appliedSkin[name]: " .. customskins.appliedSkin[name]:serialize())
		else
			minetest.chat_send_all("customskins.appliedSkin[name]: nil")
		end
	end
})


function customskins.getPlayerSkin(name)
	if customskins.appliedSkin[name] then
		return tostring(customskins.appliedSkin[name])
	elseif storage:contains(name) then
		return tostring(Skin.deserialize(storage:get_string(name)))
	end
	return tostring(customskins.getDefaultSkin()) 
end


function customskins.getPlayerPreview(name)
	local player_preview = {}
	local texture = tostring(customskins.workingSkin[name])
	if not customskins.previewBackview[name] then
		player_preview = {
			"[combine:8x8:-8,-8="    .. texture, -- head
			"[combine:8x12:-20,-20=" .. texture, -- body
			"[combine:4x12:-4,-20="  .. texture, -- left_leg
			"[combine:4x12:-4,-20="  .. texture .. "^[transformFX", -- right_leg
			"[combine:4x12:-44,-20=" .. texture, -- left_hand
			"[combine:4x12:-44,-20=" .. texture .. "^[transformFX" -- right_hand
		}
	else
		player_preview = {
			"[combine:8x8:-24,-8="   .. texture, -- head_back
			"[combine:8x12:-32,-20=" .. texture, -- body_back
			"[combine:4x12:-12,-20=" .. texture, -- left_leg_back
			"[combine:4x12:-12,-20=" .. texture .. "^[transformFX", -- right_leg_back
			"[combine:4x12:-52,-20=" .. texture, -- left_hand_back
			"[combine:4x12:-52,-20=" .. texture .. "^[transformFX" -- right_hand_back
		}
	end
	return table.concat( {
		"image[" .. (preview_x+(4*preview_px_size))  .. "," .. preview_y                        .. ";" .. (8*preview_px_size) .. "," .. (8*preview_px_size)  .. ";" .. player_preview[1] .. "]",
		"image[" .. (preview_x+(4*preview_px_size))  .. "," .. (preview_y+(8*preview_px_size))  .. ";" .. (8*preview_px_size) .. "," .. (12*preview_px_size) .. ";" .. player_preview[2] .. "]",
		"image[" .. (preview_x+(4*preview_px_size))  .. "," .. (preview_y+(20*preview_px_size)) .. ";" .. (4*preview_px_size) .. "," .. (12*preview_px_size) .. ";" .. player_preview[3] .. "]",
		"image[" .. (preview_x+(8*preview_px_size))  .. "," .. (preview_y+(20*preview_px_size)) .. ";" .. (4*preview_px_size) .. "," .. (12*preview_px_size) .. ";" .. player_preview[4] .. "]",
		"image[" .. preview_x                        .. "," .. (preview_y+(8*preview_px_size))  .. ";" .. (4*preview_px_size) .. "," .. (12*preview_px_size) .. ";" .. player_preview[5] .. "]",
		"image[" .. (preview_x+(12*preview_px_size)) .. "," .. (preview_y+(8*preview_px_size))  .. ";" .. (4*preview_px_size) .. "," .. (12*preview_px_size) .. ";" .. player_preview[6] .. "]"
	}, "")
end


function customskins.getFormspec(name)
	return table.concat({
        "formspec_version[4]",
        "size[16,10]",
		"label[0.5,0.35;customskins v.0.4.4(wip) by Herkules]",
		-- Player preview
		"box[0.5,0.5;3.5,6;#737373]",
		--"model[0.5,0.5;3.5,6;preview_mesh;character.b3d;character.png]",
		--customcustomskins.get_player_preview(name),
		customskins.getPlayerPreview(name),
		"button[0.5,6;1.75,0.5;btn_front;Front]",
		"button[2.25,6;1.75,0.5;btn_back;Back]",
		-- Part select
		"box[4.5,0.5;9,6;#737373]",
		tabHeader,
		--customskins.get_tabheader(selected_feature_tab[name]),
		--"tabheader[4.5,1;7,0.5;feature;Skin,Face,Hair,Body,Legs,Shoes,Misc.;Skin;false;true]",
		"scrollbaroptions[arrows=hide]",
		"scrollbar[14,1;0.75,5.5;vertical;feature_scrollbar;0.1]",      --"scrollbar[10.75,1;0.75,5.5;vertical;feature_scrollbar;0.1]",
		"scroll_container[4.5,1;6,5.5;feature_scrollbar;vertical;0.05]",
		--customskins.get_features(selected_feature_tab[name]),
		tabContents[customskins.selectedTab[name]],
		"scroll_container_end[]",
		-- Color sliders
		--"label[4.5,4.75;color]",
		--"label[4.5,5.5;lightness]",
		--"label[4.5,6.25;saturation]",
		--"scrollbar[6,4.5;5.5,0.5;horizontal;color_h;0.1]",
		--"scrollbar[6,5.25;5.5,0.5;horizontal;color_s;0.1]",
		--"scrollbar[6,6;5.5,0.5;horizontal;color_v;0.1]",	
		-- Buttons
		"button_exit[0.5,7;1.5,0.75;btn_exit;Exit]",
		--"button[2.5,7;1.5,0.75;btn_reset;Reset]",
		--"button[4.5,7;1.5,0.75;btn_random;Random]",
		--"button[6.5,7;1.5,0.75;btn_default;Default]",
		"button[8.5,7;3,0.75;btn_apply;Apply]"
    }, "")
end


function customskins.getDefaultSkin()
	local skin = Skin.new()
	local index = 1
	for k, v in pairs(ordered_keys) do
		for _, vv in pairs(categorys[v]) do
			if vv:find("default") then
				local part = Part.new()
				part.texture = vv:sub(1,-5)
				skin.parts[k] = part
				break
			end
		end
		skin.order[k] = k
	end
	--skin.order = {[1]=2,[2]=6,[3]=1,[4]=4,[5]=5,[6]=7,[7]=3} -- TODO: Remove hardcoded order
	--skin.order = {[1]=3,[2]=6,[3]=7,[4]=1,[5]=8,[6]=5,[7]=2,[8]=4}
	return skin
end


function customskins.fileExists(fileName)
	local f = io.open(fileName,"r")
	if f then
		io.close(f)
		return true
	end
	return false
end


minetest.register_on_player_receive_fields(
	function(player, formname, fields)
		if formname == "customskins:skineditor" then
			local name = player:get_player_name()
			if fields.part then
				customskins.selectedTab[name] = fields.part
			elseif fields.btn_front then
				customskins.previewBackview[name] = false;
			elseif fields.btn_back then
				customskins.previewBackview[name] = true;
			elseif fields.btn_apply then
				customskins.appliedSkin[name] = copy(customskins.workingSkin[name], nil)
				customskins.setPlayerSkin(name, tostring(customskins.appliedSkin[name]))
				storage:set_string(name, customskins.appliedSkin[name]:serialize())
				minetest.close_formspec(name, "customskins:skineditor")
				return
			elseif fields.btn_default then
				customskins.workingSkin[name] = nil
				customskins.workingSkin[name] = customskins.getDefaultSkin()
			elseif fields.btn_reset then
				customskins.workingSkin[name] = nil
				if customskins.appliedSkin[name] then
					customskins.workingSkin[name] = copy(customskins.appliedSkin[name], nil)
				else
					if storage:contains(name) then
						customskins.workingSkin[name] = Skin.deserialize(storage:get_string(name))
					else
						customskins.workingSkin[name] = customskins.getDefaultSkin()
					end
				end
			else -- All parts
				for k, v in pairs(ordered_keys) do
					local part = nil
					for kk, vv in pairs(categorys[v]) do
						if fields[vv:sub(1,-5)] then
							local part = Part.new()
							part.texture = vv:sub(1,-5)
							customskins.workingSkin[name].parts[k] = part
							break
						end
					end
					if part then
						break
					end
				end
			end
			minetest.show_formspec(name, "customskins:skineditor", customskins.getFormspec(name))
		end
	end
)


function customskins.init()
	-- Create categorys
	local files = minetest.get_dir_list(customskins.modpath .. "/textures", false)
	categorys = {}
	for _, v in pairs(files) do
		if not v:find("icon") then
			local str = v:match("%w+")
			if not categorys[str] then
				categorys[str] = {}
			end
			table.insert(categorys[str], v)
		end
	end
	-- Create ordered_keys
	local index = 1
	for word in order_str:gmatch("%w+") do
		if categorys[word] then
			ordered_keys[index] = word
			index = index + 1
		end
	end
	-- Header for the tabs
	tabHeader = {}
	for _, v in pairs(ordered_keys) do
		table.insert(tabHeader, v)
	end
	tabHeader = table.concat({
			"tabheader[4.5,1;7,0.5;part",
			table.concat(tabHeader,","),
			tabHeader[1],
			"false;true]"
		}, ";")
	-- Content for the tabs
	tabContents = {}
	for index, v in pairs(ordered_keys) do
		tabContents[tostring(index)] = {}
		for kk, vv in pairs(categorys[v]) do
			local buttons = {
					"image_button[", --1
					tostring( (((kk)-1)%4)*1.5 ),
					",", --3
					tostring( math.floor(((kk)-1)/4)*1.5 ),
					";1.5,1.5;", --5
					vv:sub(1,-5),
					"_icon.png", --7 texture
					";",
					vv:sub(1,-5), --9 fieldname
					";]"}
			if not customskins.fileExists(customskins.modpath .. "/textures/" .. vv:sub(1,-5) .. "_icon.png") then
				buttons[1] = "button["
				buttons[6] = ""
				buttons[7] = ""
				buttons[8] = ""
				buttons[10] = ";" .. vv:sub(1,-5):match("_(.*)") .. "]" -- text on button
			end
			table.insert(tabContents[tostring(index)], table.concat(buttons, ""))
		end
		tabContents[tostring(index)] = table.concat(tabContents[tostring(index)], "")
	end
end


customskins.init()
