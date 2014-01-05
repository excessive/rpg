require "db.font"
local Timer = require "libs.hump.timer"
local Vector = require "libs.hump.vector"

local gameplay = {}

function gameplay:enter(state)
	--[[
	Signal.register("death", somefunc())
	Signal.register("kill", somefunc())
	Signal.register("move", somefunc())
	Signal.register("interact", somefunc()) -- generic interaction with entities
	Signal.register("attack", somefunc())
	Signal.register("pickup", somefunc()) -- emit from interact
	Signal.register("talk", somefunc()) -- emit from interact
	Signal.register("collision", somefunc())
	Signal.register("konami", somefunc()) -- max 300 step chart
	Signal.register("input", somefunc())
	Signal.register("death", somefunc())
	]]--
	
	-- Map stuff
	local function createCollisionMap(map, layer)
		local w, h = map.width-1, map.height-1
		local walk = {}
		for y=0, h do
			walk[y] = {}
			for x=0, w do
				walk[y][x] = 0
			end
		end
		for x, y, tile in map.layers[layer]:iterate() do
			walk[y][x] = 1
		end
		return walk
	end

	local loader = require "libs.ATL.Loader"
	loader.path = "assets/maps/"
	self.map = loader.load("test03.tmx")
	self.collisionMap = createCollisionMap(self.map, "Collision")
	self.collisionMap.width = self.map.width
	self.collisionMap.height = self.map.height-1

	-- Custom Layer for Sprite Objects
	local spriteLayer = self.map:newCustomLayer("Sprites", 3)
	function spriteLayer:draw()
		for _, v in pairs(self.objects) do
			v:draw()
		end
	end

	-- On-screen objects
	self.objects = require "assets.maps.test03"
	self.objects_sorted = {}

	self.show_debug_overlay = true
	self.show_hitboxes = false

	self.fading = true
	self.lock_input = false

	self.timer = Timer.new()
	self.fade_params = { opacity = 255 }

	-- HACK: loading time botches the timer, but we want to see the fade!
	self.timer:add(1/60, function()
		self.timer:tween(0.25, self.fade_params, { opacity = 0 }, 'in-out-sine')
		self.timer:add(0.25, function()
			self.fading = false
		end)
	end)
end

function gameplay:update(dt)
	local speed = 5.0

	-- Shortcuts!
	local o			= self.objects
	local collision	= self.collisionMap
	local velocity	= Vector(0, 0)
	local pressed	= love.keyboard.isDown
	local keys		= {
		up		= pressed "up"    or pressed "w",
		down	= pressed "down"  or pressed "s",
		left	= pressed "left"  or pressed "a",
		right	= pressed "right" or pressed "d"
	}

	if keys["left"]		then velocity.x = velocity.x - 1 end
	if keys["right"]	then velocity.x = velocity.x + 1 end
	if keys["up"]		then velocity.y = velocity.y - 1 end
	if keys["down"]		then velocity.y = velocity.y + 1 end

	for k, v in pairs{o.enemies, o.npcs, o.items} do
		for k2, v2 in pairs(v) do
			collision[v2.position.y/32][v2.position.x/32] = 1
		end
	end

	for k, v in pairs(o.terrain) do
		for i = v.hitbox_start.y, v.hitbox_end.y do
			for j = v.hitbox_start.x, v.hitbox_end.x do
				local x = j + v.position.x/32
				local y = i + v.position.y/32
				if x > self.map.width or y > self.map.height then
					print "out of bounds"
				else
					collision[y][x] = 1
				end
			end
		end
	end

	o.player:move(velocity:normalized() * speed * dt, collision)

	-- scan for/pick up items in range
	o.player.can_pickup = false
	local items = {}
	for k, v in pairs(o.items) do
		local distance = v.position - o.player.position
		if distance:len() / 32 <= o.player.use_range then
			items[k] = v
			o.player.can_pickup = true
			v.in_range = true
		else
			v.in_range = false
		end
	end

	if pressed "e" and o.player.can_pickup then
		for k, v in pairs(items) do
			o.player:equip_item("weapon", v)
			v.in_range = false
			local position = o.items[k].position
			collision[position.y/32][position.x/32] = 0
			o.items[k] = nil
		end
	end

	local enemies = {}
	for k, v in pairs(o.enemies) do
			local direction = v.position - o.player.position
			local distance = direction:len() / 32
			if distance <= o.player.attack_range then
				enemies[k] = v
				v.in_range = true
			else
				v.in_range = false
			end

			-- TODO: make not shitty
			if distance <= v.sight_range then
				v.sees_player = true
			else
				v.sees_player = false
			end
	end

	-- TODO: directional hits
	if pressed " " and o.player:attack() then
		for k, v in pairs(enemies) do
			if not v.dead then
				v:hit(o.player)
				if v.dead then
					self.timer:add(1.0, function()
						-- I CAN NEST FOREVER
						local position = o.enemies[k].position
						collision[position.y/32][position.x/32] = 0
						o.enemies[k] = nil
						print "Goodbye, my friend."
					end)
				end
			end
		end
	end

	local objects = {}
	local count = 0
	for k, v in pairs(o) do
		if v.position then
			count = count + 1
			objects[count] = v
		else
			for k2, v2 in pairs(v) do
				count = count + 1
				objects[count] = v2
			end
		end
	end

	table.sort(objects, function(a, b)
		local ay = a.hitbox_start.y * 32 + a.position.y
		local by = b.hitbox_start.y * 32 + b.position.y
		return ay < by
	end)

	for _, v in pairs(objects) do
		v:update(dt)
	end

	self.objects_sorted = objects

	self.timer:update(dt)
end

function clamp(num, low, high)
	return math.min(math.max(num, low), high)
end

function gameplay:draw()
	-- Link Players to Sprites Layer
	self.map.layers.Sprites.objects = self.objects_sorted

	local scale_factor	= love.graphics.getHeight()	/ 600
	local screen_width	= love.graphics.getWidth()	/ scale_factor
	local screen_height	= love.graphics.getHeight()	/ scale_factor
	local size			= Vector(screen_width, screen_height)
	local player		= self.objects.player
	
	-- Draw World + Entities
	love.graphics.push()
	love.graphics.scale(scale_factor, scale_factor)
	love.graphics.setColor(255, 255, 255, 255)
	local tx = math.floor(player.position.x - size.x / 2)
	local ty = math.floor(player.position.y - size.y / 2)
	tx = -clamp(tx, 0, self.map.width * self.map.tileWidth - size.x)
	ty = -clamp(ty, 0, self.map.height * self.map.tileHeight - size.y)
	love.graphics.translate(tx, ty)
	self.map:setDrawRange(-tx, -ty, screen_width, screen_height)
	self.map:draw()

	if self.show_hitboxes then
		-- Draw Collision Map
		love.graphics.setColor(255,255,255,128)
		for y=0, #self.collisionMap do
			for x=0, #self.collisionMap[y] do
				if self.collisionMap[y][x] == 1 then
					love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)
				end
			end
		end
	end

	love.graphics.setColor(255,255,255,255)
	love.graphics.pop()
	
	-- repositioned to get a clearer view of what needs to be signalified
	self:draw_gui()

	-- overlay fade
	if self.fading then
		love.graphics.setColor(255, 255, 255, self.fade_params.opacity)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	end
end

function gameplay:keypressed(key, unicode)
	if key == "f3" then
		self.show_debug_overlay = not self.show_debug_overlay
	end
	
	if key == "h" then
		self.show_hitboxes = not self.show_hitboxes
	end
	
	if key == "escape" then
		self.lock_input = true
		self.fading = true
		self.timer:tween(0.25, self.fade_params, { opacity = 255 }, 'in-out-sine')
		self.timer:add(0.25, function()
			Gamestate.switch(require("states.title"))
		end)
	end
end

function gameplay:draw_gui()
	local player = self.objects.player
	
	-- gui
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 32)
	love.graphics.setColor(120, 120, 120, 180)
	love.graphics.rectangle("fill", 0, 32, love.graphics.getWidth(), 4)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle("fill", 0, love.graphics.getHeight()-32, love.graphics.getWidth(), 32)
	love.graphics.setColor(120, 120, 120, 180)
	love.graphics.rectangle("fill", 0, love.graphics.getHeight()-36, love.graphics.getWidth(), 4)

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.setFont(FontDB.roboto.medium.regular)
	local spacing = 90
	love.graphics.print(("LV %d"):format(player.level), 8, 8)
	love.graphics.print(("HP %d/%d"):format(player.hp, player.stats.hp), spacing*1+8, 8)
	love.graphics.print(("ATK %d"):format(player.stats.attack), spacing*3+8, 8)
	
	love.graphics.print(("XP %d/%d"):format(player.exp, player.stats.exp), 8, love.graphics.getHeight()-24)

	if player.equipment.weapon then
		love.graphics.print(("%s: %s"):format(player.equipment.weapon.name, player.equipment.weapon.lore), 278, love.graphics.getHeight()-24)
	end

	-- debug overlay
	if self.show_debug_overlay then
		local pos = Vector(love.graphics.getWidth()-256-8, 40)
		local spacing = 24
		local lines = {
			("FPS: %d"):format(love.timer.getFPS()),
			"H: Toggle Hitboxes"
		}
		local size = Vector(256, spacing*#lines+8)
		love.graphics.setColor(0, 0, 0, 150)
		love.graphics.rectangle("fill", pos.x, pos.y, size.x, size.y)
		love.graphics.setColor(255, 255, 255, 255)
		pos = pos + Vector(8, 8)
		size = size - Vector(16, 16)
		for k, v in ipairs(lines) do
			love.graphics.print(v, pos.x, pos.y + (k-1) * spacing)
		end
	end

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print("F3: Toggle Debug Menu", love.graphics.getWidth() - 256, 8)
end

return gameplay
