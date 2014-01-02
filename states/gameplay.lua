require "player"
require "enemy"
require "npc"
require "item"
require "terrain"
require "db.font"
require "db.enemy"
require "db.npc"
require "db.item"
require "db.terrain"
local Vector = require "libs.hump.vector"

local gameplay = {}

function gameplay:enter(state)
	-- Colby's fading nonsense
	self.fading = true
	self.fading_back = false
	self.fade_progress = 0.0

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
	self.objects = {
		player	= Player("assets/browserquest/goldenarmor.png", Vector(41, 58)),
		enemies	= {
			Enemy(EnemyDB.jeff,		Vector(38, 34)),
			Enemy(EnemyDB.kevin,	Vector(22, 10)),
			Enemy(EnemyDB.kevin,	Vector(23, 10)),
			Enemy(EnemyDB.kevin,	Vector(30, 10)),
			Enemy(EnemyDB.kevin,	Vector(31, 10)),
			Enemy(EnemyDB.kevin,	Vector(38, 10)),
			Enemy(EnemyDB.kevin,	Vector(39, 10)),
		},
		npcs	= {
			NPC(NPCDB.smith,	Vector(10, 58)),
			NPC(NPCDB.priest,	Vector(5, 36)),
			NPC(NPCDB.dead,		Vector(2, 34)),
			NPC(NPCDB.dead,		Vector(4, 34)),
			NPC(NPCDB.dead,		Vector(6, 34)),
			NPC(NPCDB.dead,		Vector(8, 34)),
			NPC(NPCDB.dead,		Vector(2, 38)),
			NPC(NPCDB.dead,		Vector(4, 38)),
			NPC(NPCDB.dead,		Vector(6, 38)),
			NPC(NPCDB.dead,		Vector(8, 38)),
		},
		items	= {
			Item(ItemDB.sword,	Vector(30, 54)),
		},
		terrain	= {
			Terrain(TerrainDB.house1,	Vector(19, 2)),
			Terrain(TerrainDB.house2,	Vector(27, 1)),
			Terrain(TerrainDB.house3,	Vector(35, 1)),
			Terrain(TerrainDB.tree1,	Vector(17, 8)),
			Terrain(TerrainDB.tree1,	Vector(25, 8)),
			Terrain(TerrainDB.tree1,	Vector(33, 8)),
			Terrain(TerrainDB.tree1,	Vector(41, 8)),
			Terrain(TerrainDB.well1,	Vector(37, 30)),
			Terrain(TerrainDB.rock3,	Vector(28, 51)),
			Terrain(TerrainDB.rock4,	Vector(32, 51)),
			Terrain(TerrainDB.grave1,	Vector(2, 32)),
			Terrain(TerrainDB.grave1,	Vector(4, 32)),
			Terrain(TerrainDB.grave1,	Vector(6, 32)),
			Terrain(TerrainDB.grave1,	Vector(8, 32)),
			Terrain(TerrainDB.grave1,	Vector(2, 36)),
			Terrain(TerrainDB.grave2,	Vector(4, 36)),
			Terrain(TerrainDB.grave1,	Vector(6, 36)),
			Terrain(TerrainDB.grave1,	Vector(8, 36)),
			Terrain(TerrainDB.tent1,	Vector(40, 54)),
		},
	}

	self.objects_sorted = {}

	self.show_debug_overlay = true
	self.show_hitboxes = false

	local Grid = require "libs.jumper.grid"
	local Pathfinder = require "libs.jumper.pathfinder"
	local map = {
		{0,1,0,1,0},
		{0,1,0,1,0},
		{0,1,1,1,0},
		{0,0,0,0,0},
	}
	local walkable = 0
	local grid = Grid(map)
	local myFinder = Pathfinder(grid, "JPS", walkable)
	local start = Vector(1,1)
	local finish = Vector(5,1)
	local path = myFinder:getPath(start.x, start.y, finish.x, finish.y)

	if path then
		print(("Path found! Length: %.2f"):format(path:getLength()))
		for node, count in path:nodes() do
			print(("Step: %d - x: %d - y: %d"):format(count, node:getX(), node:getY()))
		end
	end
end

function gameplay:update(dt)
	-- fade overlay
	local speed = 5.0

	if self.fading then
		local speed = 0.25
		self.fade_progress = self.fade_progress + 1.0/speed * dt
		if self.fade_progress >= 1.0 then
			self.fading = false
			if self.fading_back then
				Gamestate.switch(require "states.title")
			end
		end
	end

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
			o.player.exp = o.player.exp + v:hit(o.player.stats.attack)
			o.player:update_stats()
		end
	end

	for k, v in pairs(o.enemies) do
		if v.dead and love.timer.getTime() - v.died_at > 1.0 then
			local position = o.enemies[k].position
			collision[position.y/32][position.x/32] = 0
			o.enemies[k] = nil
			print "Goodbye, my friend."
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
end

function clamp(num, low, high)
	return math.min(math.max(num, low), high)
end

function gameplay:draw()
	-- Link Players to Sprites Layer
	self.map.layers.Sprites.objects = self.objects_sorted

	local size = Vector(love.graphics.getWidth(), love.graphics.getHeight() - 64)
	local player = self.objects.player

	-- Draw World + Entities
	love.graphics.push()
	love.graphics.setColor(255, 255, 255, 255)
	local tx = math.floor(player.position.x - size.x / 2)
	local ty = math.floor(player.position.y - size.y / 2)
	tx = -clamp(tx, 0, self.map.width * self.map.tileWidth - size.x)
	ty = -clamp(ty, 0, self.map.height * self.map.tileHeight - size.y)
	love.graphics.translate(tx, ty + 32)
	self.map:setDrawRange(-tx, -ty, love.graphics.getWidth(), love.graphics.getHeight() - 64)
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

	-- overlay fade
	if self.fading then
		local alpha = self.fade_progress * 255
		if not self.fading_back then
			alpha = 255 - alpha
		end
		love.graphics.setColor(255, 255, 255, alpha)
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
		self.fading = true
		self.fading_back = true
		self.fade_progress = 0.0
	end
end

return gameplay
