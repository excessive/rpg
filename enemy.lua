require "db.font"
require "character"
require "item"
local Class = require "libs.hump.class"
local Vector = require "libs.hump.vector"
local anim8 = require "libs.anim8"

Enemy = Class {}
Enemy:include(Character)

function Enemy:init(enemy, pos)
	Character.init(self, enemy, pos)
	
	self.level			= enemy.level
	self.base_stats		= enemy.base_stats
	self.equipment		= {}
	for k, v in pairs(enemy.equipment) do
		self.equipment[k] = Item(v, pos)
	end
	self.lore			= enemy.lore
	
	self.sight_range	= 6
	self.sees_player	= false
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

function Enemy:draw()
	local position = self.position + self.offset
	position.x = position.x + 32
	position.y = position.y + 64

	love.graphics.push()
	love.graphics.translate(position.x, position.y)
	love.graphics.scale(1, 0.5)

	if self.in_range and not self.dead then
		love.graphics.setColor(200, 0, 0, 150)
	else
		if self.sees_player then
			love.graphics.setColor(0, 0, 200, 150)
		else
			love.graphics.setColor(0, 0, 0, 50)
		end
	end

    love.graphics.circle("fill", 0, -22, 14, 16)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.pop()

	if self.dead then
		love.graphics.setColor(255, 0, 0, 255)
	end

	Character.draw(self)

	if self.equipment and self.equipment.weapon then
		self.equipment.weapon.position = self.position
		self.equipment.weapon:draw()
	end

	--[[
	love.graphics.push()
	love.graphics.translate(
		math.floor(self.position.x + self.offset.x),
		math.floor(self.position.y + self.offset.y)
	)
	love.graphics.setFont(FontDB.roboto.small.medium)
	local function drawText(offset)
		local position = math.floor(offset)
		love.graphics.printf(("%s: %s"):format(self.name, self.lore), -12, position, 200, "left")
		--love.graphics.printf(("HP: %d/%d"):format(self.hp, self.stats.hp), -12, position + 16, 200, "left")
		--love.graphics.printf(("EXP: %d"):format(self.stats.exp), -12, position + 32, 200, "left")
		--love.graphics.printf(("ATK: %d"):format(self.stats.attack), -12, position + 48, 200, "left")
	end
	love.graphics.setColor(0, 0, 0, 180)
	drawText(1)
	love.graphics.setColor(255, 255, 255, 255)
	drawText(0)
	love.graphics.pop()
	--]]
end
