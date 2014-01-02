require "entity"
local Class = require "libs.hump.class"
local Vector = require "libs.hump.vector"

Character = Class {}
Character:include(Entity)

function Character:init(character, pos)
	Entity.init(self, character, pos)

	self.velocity		= Vector(0, 0)
	self.attacking		= false
	self.attack_time	= -1
	self.attack_length	= 0.5
	self.show_tile		= false
	self.in_range		= false
	self.width			= 1
	self.height			= 1
	self.level			= 1
	self.exp			= 0 -- exp in current level
	self.dead			= false
	self.died_at		= 0
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

function Character:hit(attack)
	if self.dead then return 0 end

	print( ("hit %s for %d hp"):format(self.name, attack))

	self.hp = math.max(self.hp - attack, 0)

	if self.hp <= 0 then
		print(("killed %s for %d exp"):format(self.name, self.stats.exp))
		self.dead = true
		self.died_at = love.timer.getTime()
		return self.stats.exp
	end

	return 0
end

function Character:attack()
	if love.timer.getTime() - self.attack_time > 1 then
		self.attacking = true
		self.attack_time = love.timer.getTime()
		return true
	end
	
	return false
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
	if self.attacking then
		if self.facing:find("right") then
			self.facing = "rightswing"
		elseif self.facing:find("left") then
			self.facing = "leftswing"
		elseif self.facing:find("down") then
			self.facing = "downswing"
		elseif self.facing:find("up") then
			self.facing = "upswing"
		end

		if love.timer.getTime() - self.attack_time > self.attack_length then
			self.attacking = false
		end
	end

	if self.equipment and self.equipment.weapon then
		self.equipment.weapon.facing = self.facing
		self.equipment.weapon:update(dt)
	end

	Entity.update(self, dt)
end
