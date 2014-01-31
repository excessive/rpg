require "character"
require "item"
require "db.item"
local Class = require "libs.hump.class"
local Vector = require "libs.hump.vector"
local anim8 = require "libs.anim8"

Player = Class {}
Player:include(Character)

function Player:init(player)
	Character.init(self, player)

	self.level			= player.level
	self.attack_range	= player.attack_range
	self.use_range		= player.use_range
	self.base_stats		= player.base_stats
	self.aptitudes		= player.aptitudes
	self.inventory		= player.inventory
	self.equipment		= {}
	
	for k,v in pairs(player.equipment) do
		self.equipment[k] = Item(ItemDB[v], player.pos)
	end

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
		self.position.y + self.offset.y + 64
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
