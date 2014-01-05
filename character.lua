require "entity"
local Class = require "libs.hump.class"
local Vector = require "libs.hump.vector"

Character = Class {}
Character:include(Entity)

function Character:init(character, pos)
	Entity.init(self, character, pos)

	self.velocity		= Vector(0, 0)
	self.attack_cooldown = 1.0
	self.cooldown		= false
	self.show_tile		= false
	self.in_range		= false
	self.width			= 1
	self.height			= 1
	self.level			= 1
	self.exp			= 0 -- exp in current level
	self.dead			= false
	self.base_stats		= {
		hp		= 10,
		attack	= 1,
		exp		= 0 -- exp needed to level
	}
	self.aptitudes		= {
		hp		= 0.5,
		attack	= 0.5,
		exp		= 1.0
	}
	self.stats 			= {} -- stat cache
end

function Character:hit(attacker)
	if self.dead then return end

	local attack = attacker.stats.attack

	print( ("hit %s for %d hp"):format(self.name, attack))

	self.hp = math.max(self.hp - attack, 0)

	if self.hp <= 0 then
		print(("killed %s for %d exp"):format(self.name, self.stats.exp))
		self.dead = true
		attacker.exp = attacker.exp + self.stats.exp
		attacker:update_stats()
	end
end

function Character:attack()
	if self.cooldown then return false end

	self.cooldown = true
	
	local facing = self.facing
	
	if self.facing:find("move") then
		self.facing = self.facing:sub(1, self.facing:len()-4)
	end
	self.facing = self.facing .. "swing"

	if self.equipment and self.equipment.weapon then
		self.equipment.weapon.facing = self.facing
		self.equipment.weapon:resume()
	end
	
	if facing ~= self.facing then
		self.sprites[facing]:pauseAtStart()
		
		if self.equipment and self.equipment.weapon then
			self.equipment.weapon.sprites[facing]:pauseAtStart()
		end
	end
	
	self:resume()
	
	self.timer:add(self.attack_cooldown, function()
		self.cooldown = false
	end)

	return true
end

function Character:equip_item(slot, item)
	if self.equipment and self.equipment[slot] then
		table.insert(self.inventory, self.equipment[slot])
	end

	print(self.name .. " picked up " .. item.name .. ". " .. item.lore)
	self.equipment[slot] = item
	self:update_stats()
end

function Character:update_stats()
	local stats = {}
	local pow, floor = math.pow, math.floor

	for i, v in pairs(self.base_stats) do
		stats[i] = floor(self.base_stats[i] + pow(self.level-1, 2) * 3 * self.aptitudes[i])
	end

	if self.exp >= stats.exp then
		self.level = self.level + 1
		self.exp = self.exp - stats.exp

		return Character.update_stats(self)
	end

	self.stats = stats
end

function Character:print_stats()
	print("level", self.level)

	for k,v in pairs(self.stats) do
		print(k, v)
	end
end

-- in tiles/second
function Character:move(pos, collision)
	if self.dead then return end
	
	local facing = self.facing
	
	if pos.x > 0 then
		self.facing = "rightmove"
	elseif pos.x < 0 then
		self.facing = "leftmove"
	elseif pos.y > 0 then
		self.facing = "downmove"
	elseif pos.y < 0 then
		self.facing = "upmove"
	end

	if pos.x == 0 and pos.y == 0 then
		if self.facing:find("move") then
			self.facing = self.facing:sub(1, self.facing:len()-4)
		end
	end
	
	if facing ~= self.facing then
		self.sprites[facing]:pauseAtStart()
		self:resume()
		
		if self.equipment and self.equipment.weapon then
			self.equipment.weapon.sprites[facing]:pauseAtStart()
			self.equipment.weapon:resume()
		end
	end
	
	local old = self.position:clone()
	self.position = self.position + pos * 32

	local closest = self:closest_tile() / 32

	if	closest.x < 0 or closest.y < 0 or
		closest.x > collision.width or closest.y > collision.height or
		collision[closest.y][closest.x] == 1 or
		collision[closest.y][closest.x] == nil
	then
		self.position = old
	end
end

function Character:update(dt)
	if self.equipment and self.equipment.weapon then
		self.equipment.weapon.facing = self.facing
		self.equipment.weapon:update(dt)
	end

	Entity.update(self, dt)
end
