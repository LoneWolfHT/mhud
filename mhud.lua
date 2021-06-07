local hud = {
	huds = {}
}

local function get_playerobj(player)
	if type(player) == "string" then
		return minetest.get_player_by_name(player)
	else
		return player
	end
end

local function convert_def(def, type)
	if type == "text" then
		def.number = def.number or      def.color
		def.size   = def.size   or {x = def.text_scale}
	elseif type == "image" then
		def.text  = def.text  or      def.texture
		def.scale = def.scale or {x = def.image_scale}
	elseif type == "statbar" then
		if def.textures then
			def.text  = def.textures[1]
			def.text2 = def.textures[2]
		else
			def.text = def.text or def.texture
		end

		if def.lengths then
			def.number = def.lengths[1]
			def.item   = def.lengths[2]
		else
			def.number = def.number or def.length
		end

		def.size = def.size or def.force_image_size
	elseif type == "inventory" then
		def.text   = def.text   or def.listname
		def.number = def.number or def.size
		def.item   = def.item   or def.selected
	elseif type == "waypoint" then
		def.name   = def.name   or def.waypoint_text
		def.text   = def.text   or def.suffix
		def.number = def.number or def.color
	elseif type == "image_waypoint" then
		def.text  = def.text  or      def.texture
		def.scale = def.scale or {x = def.image_scale}
	end

	if def.alignment then
		for axis, val in pairs(def.alignment) do
			if val == "left" or val == "up" then
				def.alignment[axis] = -1
			elseif val == "center" then
				def.alignment[axis] = 0
			elseif val == "right" or val == "down" then
				def.alignment[axis] = 1
			end
		end
	end

	if def.direction then
		for axis, val in pairs(def.alignment) do
			if val == "right" then
				def.direction[axis] = 0
			elseif val == "left" then
				def.direction[axis] = 1
			elseif val == "down" then
				def.direction[axis] = 2
			elseif val == "up" then
				def.direction[axis] = 3
			end
		end
	end

	return def
end

function hud.add(self, player, name, def)
	player = get_playerobj(player)
	local pname = player:get_player_name()

	if not def then
		def, name = name, false
	end

	if not self.huds[pname] then
		self.huds[pname] = {}
	end

	def = convert_def(def, def.hud_elem_type)

	local id = player:hud_add(def)

	if name then
		self.huds[pname][name] = {id = id, def = def}
	else
		self.huds[pname][id] = {id = id, def = def}
	end

	return id
end

function hud.get(self, player, name)
	player = get_playerobj(player)
	local pname = player:get_player_name()

	if self.huds[pname] then
		return self.huds[pname][name]
	end
end
hud.exists = hud.get

function hud.change(self, player, name, def)
	player = get_playerobj(player)
	local pname = player:get_player_name()

	assert(self.huds[pname][name], "Attempt to change hud that doesn't exist!")

	def = convert_def(def, def.hud_elem_type or self.huds[pname][name].def.hud_elem_type)

	for stat, val in pairs(def) do
		player:hud_change(self.huds[pname][name].id, stat, val)
		self.huds[pname][name].def[stat] = val
	end
end

function hud.remove(self, player, name)
	player = get_playerobj(player)
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
hud.clear = hud.remove

function hud.remove_all(self)
	for player in pairs(self.huds) do
		self:clear(player)
	end
end
hud.clear_all = hud.remove_all

minetest.register_on_leaveplayer(function(player)
	hud:remove(player)
end)

return hud
