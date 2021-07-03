mhud = {}

local hud = dofile(minetest.get_modpath("mhud").."/mhud.lua")

function mhud.init()
	return table.copy(hud)
end
