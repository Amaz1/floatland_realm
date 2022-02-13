-- Get setting or default
local mgv7_spflags = minetest.get_mapgen_setting("mgv7_spflags") or "mountains, ridges, floatlands, caverns"
local captures_float = string.match(mgv7_spflags, "floatlands")
local captures_nofloat = string.match(mgv7_spflags, "nofloatlands")

-- Make global for mods to use to register floatland biomes
default.mgv7_floatland_level = floatland_y
default.mgv7_shadow_limit = minetest.get_mapgen_setting("mgv7_shadow_limit") or 1024

minetest.clear_registered_biomes()
default.register_biomes(default.mgv7_shadow_limit - 1)

minetest.register_node("floatland_realm:grass", {
	description = "Float Grass",
	tiles = {"floatland_realm_grass.png", "floatland_realm_dirt.png",
		{name = "floatland_realm_dirt.png^floatland_realm_grass_side.png",
			tileable_vertical = false}},
	groups = {fcrumbly = 3, soil = 1, spreading_dirt_type = 1},
	drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.25},
	}),
})

minetest.register_node("floatland_realm:sand", {
	description = "Float Sand",
	tiles = {"floatland_realm_sand.png"},
	groups = {fcrumbly = 3, falling_node = 1, sand = 1},
	sounds = default.node_sound_sand_defaults(),
})

minetest.register_node("floatland_realm:dirt", {
	description = "Float Dirt",
	tiles = {"floatland_realm_dirt.png"},
	groups = {fcrumbly = 3, soil = 1},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("floatland_realm:stone", {
	description = "Float Stone",
	tiles = {"floatland_realm_stone.png"},
	groups = {fcracky = 3, stone = 1},
	drop = 'default:cobble',
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("floatland_realm:portal", {
	description = "Float Portal",
	drawtype = "glasslike",
	tiles = {
		{
			name = "floatland_realm_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 4.0,
			},
		},
	},
	alpha = 160,
	paramtype = "light",
	sunlight_propogates = true,
	light_source = 8,
	walkable = false,
	pointable = false,
	diggable = false,
	drop = "",
	groups = {not_in_creative_inventory = 1},
})

minetest.override_item("default:pick_diamond", {
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3},
			fcracky = {times={[3]=1.60}, uses=10, maxlevel=1},
		},
		damage_groups = {fleshy=5},
	},
})

minetest.override_item("default:shovel_diamond", {
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.10, [2]=0.50, [3]=0.30}, uses=30, maxlevel=3},
			fcrumbly = {times={[3]=1.00}, uses=10, maxlevel=1},
		},
		damage_groups = {fleshy=4},
	},
})

local function get_portal_blocks(pos, first_time)
	local max_x, max_z, min_x, min_z
	for i = -2, 2 do
		local node = minetest.get_node({x = pos.x + i, y = pos.y, z = pos.z}).name
		if node == "default:mese" or node == "default:diamondblock" then
			if not min_x then
			 	min_x = pos.x + i
		 	else
		 		max_x = pos.x + i
	 		end
 		end
	end
	for i = -2, 2 do
		local node = minetest.get_node({x = pos.x, y = pos.y, z = pos.z + i}).name
		if node == "default:mese" or node == "default:diamondblock" then
			if not min_z then
			 	min_z = pos.z + i
		 	else
		 		max_z = pos.z + i
	 		end
 		end
	end
	if not min_x or not min_z or not max_x or not max_z then
		return false
	end
	local a, b = minetest.find_nodes_in_area({x = min_x, y = pos.y, z = min_z},
		{x = max_x, y = pos.y, z = max_z},
		{"floatland_realm:portal", "default:mese", "default:diamondblock"})
	
	if b["default:mese"] == 6 and b["default:diamondblock"] == 6 
	and (b["floatland_realm:portal"] == 4 or first_time == true) then
		return true, min_x, min_z
	end
	return false
end

local function item_drop(itemstack, dropper, pos)
	if dropper and dropper:is_player() then
		local v = dropper:get_look_dir()
		local p = {x=pos.x, y=pos.y+1.2, z=pos.z}
		local cs = itemstack:get_count()
		local inv = dropper:get_inventory()
		local ind = dropper:get_wield_index()
		local item = itemstack:take_item(cs)
		local obj = minetest.add_item(p, item)
		if obj then
			v.x = v.x*2
			v.y = v.y*2 + 2
			v.z = v.z*2
			obj:setvelocity(v)
			obj:get_luaentity().dropped_by = dropper:get_player_name()
			return obj, itemstack
		end
	else
		if minetest.add_item(pos, itemstack) then
			return itemstack
		end
	end
end

local function build_portal(pos)
	for i = -1, 2 do
	for j = -1, 2 do
		if (i + j) % 2 == 0 then
			minetest.set_node({x = pos.x + i, y = pos.y - 3, z = pos.z + j}, {name = "default:mese"})
		else
			minetest.set_node({x = pos.x + i, y = pos.y - 3, z = pos.z + j}, {name = "default:diamondblock"})
		end
		for j = 0, 1 do
			if i == 0 or i == 1 then
				minetest.set_node({x = pos.x + i, y = pos.y - 3, z = pos.z + j}, {name = "floatland_realm:portal"})
			end
		end
		minetest.set_node({x = pos.x + i, y = pos.y - 4, z = pos.z + j}, {name = "default:stone"})
		for k = -2, 3 do
			minetest.set_node({x = pos.x + i, y = pos.y + k, z = pos.z + j}, {name = "air"})
		end
	end
	end
end

local n1 = {
	offset      = -0.6,
	scale       = 1.5,
	spread      = {x = 600, y = 600, z= 600},
	seed        = 114,
	octaves     = 5,
	persistence = 0.6,
	lacunarity  = 2.0,
	flags       = "eased"
}

local n2 = {
	offset      = 48,
	scale       = 24,
	spread      = {x = 300, y = 300, z = 300},
	seed        = 907,
	octaves     = 4,
	persistence = 0.7,
	lacunarity  = 2.0,
	flags       = "eased"
}

local n3 = {
	offset      = -0.6,
	scale       = 1,
	spread      = {x = 250, y = 350, z = 250},
	seed        = 5333,
	octaves     = 5,
	persistence = 0.63,
	lacunarity  = 2.0,
	flags       = ""
}

local noise_b = minetest.get_mapgen_setting_noiseparams("mgv7_np_floatland_base") or n1
local noise_h = minetest.get_mapgen_setting_noiseparams("mgv7_np_float_base_height") or n2
local noise_m = minetest.get_mapgen_setting_noiseparams("mgv7_np_mountain") or n3
local floatland_y = minetest.get_mapgen_setting("mgv7_floatland_level") or 1280
local mount_height = minetest.get_mapgen_setting("mgv7_float_mount_height") or 128
local mount_dens = minetest.get_mapgen_setting("mgv7_float_mount_density") or 0.6

local function spawn_point()
	local noise_base = minetest.get_perlin(noise_b)
	local noise_height = minetest.get_perlin(noise_h)
	local noise_mount = minetest.get_perlin(noise_m)
	local base_max = floatland_y
	local y = floatland_y + 3
	for i = 1, 10000 do
	    local x = math.random(-2000, 2000)
	    local z = math.random(-2000, 2000)
	    local n_base = noise_base:get2d({x = x, y = z})
	    local n_mount = noise_mount:get3d({x = x, y = y, z = z})
	    local density_gradient = -math.pow((y - floatland_y) / mount_height, 0.75)
	    local floatn = n_mount + mount_dens + density_gradient >= 0
		if n_base > 0 and floatn == false then -- If floatlands and not a mountain
			local n_base_height = math.max(noise_height:get2d({x = x, y = z}), 1)
			local amp = n_base * n_base_height
			local ridge = n_base_height / 3
			if amp < ridge * 2 then
				local diff = math.abs(amp - ridge) / ridge
				local smooth_diff = diff * diff * (3 - 2 * diff)
				base_max = floatland_y + ridge - smooth_diff * ridge
			end
			return {x = x, y = base_max + 2, z = z}
		end
	end
end

minetest.register_craftitem("floatland_realm:key", {
	description = minetest.colorize("gold", "A key to the floatland realm..."),
	inventory_image = "floatland_realm_key.png",
	stack_max = 1,
	on_drop = function(itemstack, dropper, pos)
		local obj, itemstack = item_drop(itemstack, dropper, pos)
		minetest.after(3, function()
			if obj ~= nil and obj:get_pos() and dropper and 
				minetest.get_node(obj:get_pos()).name == "air" then
				local opos = obj:get_pos()
				local dropper_pos = dropper:get_pos()
				if dropper_pos.y > default.mgv7_floatland_level - 400 then
					return
				end
				local blocks, min_x, min_z = get_portal_blocks(opos, true)
				if blocks == true then
					obj:set_properties({automatic_rotate = 31.4/2})
					obj:set_velocity({x = 0, y = 7, z = 0})
					for i = 1, 2 do
					for j = 1, 2 do
						minetest.set_node({x = min_x + i, y = opos.y, z = min_z + j}, {name = "floatland_realm:portal"})
					end
					end
					minetest.after(1.5, function()
						if obj then
							obj:remove()							
							local meta = minetest.get_meta({x = min_x, y = opos.y, z = min_z})
							local p = spawn_point()
							meta:set_int("floatrealm:x", p.x)
							meta:set_int("floatrealm:y", p.y)
							meta:set_int("floatrealm:z", p.z)
							dropper:set_pos(p)
							minetest.after(3, function()
								build_portal(p)
								local meta2 = minetest.get_meta({x = p.x - 1, y = p.y - 3, z = p.z - 1})
								meta2:set_int("floatrealm:x", min_x + 2)
								meta2:set_int("floatrealm:y", opos.y + 2)
								meta2:set_int("floatrealm:z", min_z + 2)
							end)
						end
					end)
				end
			end
		end)
		return itemstack
	end,
})

minetest.override_item("default:diamond", {
	on_drop = function(itemstack, dropper, pos)
		local obj, itemstack = item_drop(itemstack, dropper, pos)
		minetest.after(3, function()
			if obj ~= nil and obj:get_pos() and dropper and 
				minetest.get_node(obj:get_pos()).name == "floatland_realm:portal" then
				local opos = obj:get_pos()
				local dropper_pos = dropper:get_pos()
				local blocks, min_x, min_z = get_portal_blocks(opos, false)
				if blocks == true then
					obj:set_properties({automatic_rotate = 31.4/2})
					obj:set_velocity({x = 0, y = 7, z = 0})
					minetest.after(1.5, function()
						if obj then
							obj:remove()							
							local meta = minetest.get_meta({x = min_x, y = opos.y, z = min_z})
							if meta:get_int("floatrealm:x") ~= 0 and meta:get_int("floatrealm:y") ~= 0
							and meta:get_int("floatrealm:z") ~= 0 then
								dropper:set_pos({
									x = meta:get_int("floatrealm:x"),
									y = meta:get_int("floatrealm:y"),
									z = meta:get_int("floatrealm:z"),
								})
							end
						end
					end)
				end
			end
		end)
		return itemstack
	end,
})

minetest.register_chatcommand("portal", {
	func = function(name)
		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos()
		build_portal(pos)
	end,
})

minetest.register_biome({
	name = "floatland_grass",
	node_top = "floatland_realm:grass",
	depth_top = 1,
	node_filler = "floatland_realm:dirt",
	depth_filler = 2,
	node_stone = "floatland_realm:stone",
	y_min = floatland_y + 2,
	y_max = 31000,
	heat_point = 50,
	humidity_point = 50,
})

minetest.register_biome({
	name = "floatland_beach",
	node_top = "floatland_realm:sand",
	depth_top = 3,
	node_stone = "floatland_realm:stone",
	y_min = default.mgv7_shadow_limit,
	y_max = floatland_y + 2,
	heat_point = 50,
	humidity_point = 50,
})

