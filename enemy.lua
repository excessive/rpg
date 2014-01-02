require "db.font"
require "character"
require "item"
local Class = require "libs.hump.class"
local Vector = require "libs.hump.vector"

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

function Enemy:move(pos)
	Character.move(self, pos)

	if pos.x > 0 then
		self.facing = "rightmove"
	elseif pos.x < 0 then
		self.facing = "leftmove"
	elseif pos.y > 0 then
		self.facing = "downmove"
	elseif pos.y < 0 then
		self.facing = "upmove"
	end
end

function Enemy:update(dt)
	Character.update(self, dt)
end

function Enemy:draw()
	local position = self.position + self.offset
	position.x = position.x + 32
	position.y = position.y + self.sprites[self.facing].image.fh

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

	if self.facing:find("left") then
		Character.drawReverseX(self)
	else
		Character.draw(self)
	end

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
