require "character"
local Class = require "libs.hump.class"
local Vector = require "libs.hump.vector"

Player = Class {}
Player:include(Character)

function Player:init(image, pos)
	local player = { -- this will eventually be pulled from a save file
		name			= "Nepgear",
		image			= image,
		offset			= Vector(-16, -24),
		hitbox_start	= Vector(0, 0),
		hitbox_end		= Vector(0, 0),
		level			= 1,
		attack_range	= 1,
		use_range		= 1.5,
		base_stats		= {
			hp		= 10,
			attack	= 1,
			exp		= 20,
		},
		aptitudes		= {
			hp		= 1.2,
			attack	= 1.5,
			exp		= 2.0,
		},
		inventory		= {},
		equipment		= {
			weapon	= nil,
		},
	}

	Character.init(self, player, pos)

	self.level			= player.level
	self.attack_range	= player.attack_range
	self.use_range		= player.use_range
	self.base_stats		= player.base_stats
	self.aptitudes		= player.aptitudes
	self.inventory		= player.inventory
	self.equipment		= player.equipment

	self.can_pickup		= false
	self:update_stats()
	self.hp				= self.stats.hp

	self.facing			= "down"
	self:newSprite("rightswing",	self.image, 64, 64, 0, 0, 5, 0.1)
	self:newSprite("rightmove",		self.image, 64, 64, 0, 1, 4, 0.2)
	self:newSprite("right",			self.image, 64, 64, 0, 2, 2, 0.5)
	self:newSprite("leftswing",		self.image, 64, 64, 0, 0, 5, 0.1)
	self:newSprite("leftmove",		self.image, 64, 64, 0, 1, 4, 0.2)
	self:newSprite("left",			self.image, 64, 64, 0, 2, 2, 0.5)
	self:newSprite("upswing",		self.image, 64, 64, 0, 3, 5, 0.1)
	self:newSprite("upmove",		self.image, 64, 64, 0, 4, 4, 0.2)
	self:newSprite("up",			self.image, 64, 64, 0, 5, 2, 0.5)
	self:newSprite("downswing",		self.image, 64, 64, 0, 6, 5, 0.1)
	self:newSprite("downmove",		self.image, 64, 64, 0, 7, 4, 0.2)
	self:newSprite("down",			self.image, 64, 64, 0, 8, 2, 0.5)
end

function Player:update_stats()
	Character.update_stats(self)

	if self.equipment and self.equipment.weapon then
		self.stats.attack = self.stats.attack + self.equipment.weapon.stats.attack
		self.attack_range = self.equipment.weapon.stats.range
	end
end

function Player:move(pos, collision)
	if self.dead then return end

	Character.move(self, pos, collision)

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
		if self.facing:find("right") then
			self.facing = "right"
		elseif self.facing:find("left") then
			self.facing = "left"
		elseif self.facing:find("down") then
			self.facing = "down"
		elseif self.facing:find("up") then
			self.facing = "up"
		end
	end
end

function Player:update(dt)
	Character.update(self, dt)
end

function Player:draw()
	love.graphics.push()
	love.graphics.translate(
		self.position.x + self.offset.x,
		self.position.y + self.offset.y + self.sprites[self.facing].image.fh
	)
	love.graphics.scale(1, 0.5)
	love.graphics.setColor(0, 0, 0, 50)
    love.graphics.circle("fill", 32, -22, 14, 16)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.pop()

	if self.facing:find("left") then
		Character.drawReverseX(self)
	else
		Character.draw(self)
	end

	if self.equipment and self.equipment.weapon then
		self.equipment.weapon.position = self.position
		self.equipment.weapon:draw()
	end
end
