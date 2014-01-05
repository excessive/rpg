require "character"
local Class = require "libs.hump.class"
local Vector = require "libs.hump.vector"
local anim8 = require "libs.anim8"

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

	local g = anim8.newGrid(64, 64, self.image:getWidth(), self.image:getHeight())
	
	self.sprites = {
		rightswing	= anim8.newAnimation(g('1-5',1), 0.1, function() self:reset() end),
		rightmove	= anim8.newAnimation(g('1-4',2), 0.2),
		right		= anim8.newAnimation(g('1-2',3), 0.5),
		leftswing	= anim8.newAnimation(g('1-5',1), 0.1, function() self:reset() end):flipH(),
		leftmove	= anim8.newAnimation(g('1-4',2), 0.2):flipH(),
		left		= anim8.newAnimation(g('1-2',3), 0.5):flipH(),
		upswing		= anim8.newAnimation(g('1-5',4), 0.1, function() self:reset() end),
		upmove		= anim8.newAnimation(g('1-4',5), 0.2),
		up			= anim8.newAnimation(g('1-2',6), 0.5),
		downswing	= anim8.newAnimation(g('1-5',7), 0.1, function() self:reset() end),
		downmove	= anim8.newAnimation(g('1-4',8), 0.2),
		down		= anim8.newAnimation(g('1-2',9), 0.5),
	}
end

function Player:update_stats()
	Character.update_stats(self)

	if self.equipment and self.equipment.weapon then
		self.stats.attack = self.stats.attack + self.equipment.weapon.stats.attack
		self.attack_range = self.equipment.weapon.stats.range
	end
end

function Player:draw()
	love.graphics.push()
	love.graphics.translate(
		self.position.x + self.offset.x,
		self.position.y + self.offset.y --+ self.sprites[self.facing].image.fh
	)
	love.graphics.scale(1, 0.5)
	love.graphics.setColor(0, 0, 0, 50)
    love.graphics.circle("fill", 32, -22, 14, 16)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.pop()

	Character.draw(self)

	if self.equipment and self.equipment.weapon then
		self.equipment.weapon.position = self.position
		self.equipment.weapon:draw()
	end
end
