local hud = {
	huds = {}
}

local function Obj(player)
	if type(player) == "string" then
		return minetest.get_player_by_name(player)
	else
		return player
	end
end

function hud.add(self, player, name, def)
	player = Obj(player)
	local pname = player:get_player_name()

	if not def then
		def = name
		name = false
	end

	if not self.huds[pname] then
		self.huds[pname] = {}
	end

	local id = player:hud_add(def)

	if name then
		self.huds[pname][name] = {id = id, def = def}
	else
		self.huds[pname][id] = {id = id, def = def}
	end

	return id
end

function hud.get(self, player, name)
	player = Obj(player)
	local pname = player:get_player_name()

	return assert(self.huds[pname][name], "Attempt to get hud that doesn't exist!")
end

function hud.change(self, player, name, def)
	player = Obj(player)
	local pname = player:get_player_name()

	assert(self.huds[pname][name], "Attempt to change hud that doesn't exist!")

	for stat, val in pairs(def) do
		player:hud_change(self.huds[pname][name].id, stat, val)
	end
end

function hud.remove(self, player, name)
	player = Obj(player)
	local pname = player:get_player_name()

	if name then
		assert(self.huds[pname][name], "Attempt to remove hud that doesn't exist!")

		player:hud_remove(self.huds[pname][name].id)
		self.huds[pname][name] = nil
	elseif self.huds[pname] then
		for _, def in pairs(self.huds[pname]) do
			player:hud_remove(def.id)
		end

		self.huds[pname] = nil
	end
end

minetest.register_on_leaveplayer(function(player)
	hud:remove(player)
end)

return hud
