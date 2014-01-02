require "entity"
local Class = require "libs.hump.class"
local Vector = require "libs.hump.vector"

Item = Class {}
Item:include(Entity)

function Item:init(item, pos)
	Entity.init(self, item, pos)

	self.drop			= love.graphics.newImage(item.drop)
	self.type			= item.type
	self.req_level		= item.req_level
	self.stats			= item.stats
	self.lore			= item.lore

	self.facing			= "drop"
	self:newSprite("rightswing",	self.image, 96, 96, 0, 0, 5, 0.1)
	self:newSprite("rightmove",		self.image, 96, 96, 0, 1, 4, 0.2)
	self:newSprite("right",			self.image, 96, 96, 0, 2, 2, 0.5)
	self:newSprite("leftswing",		self.image, 96, 96, 0, 0, 5, 0.1)
	self:newSprite("leftmove",		self.image, 96, 96, 0, 1, 4, 0.2)
	self:newSprite("left",			self.image, 96, 96, 0, 2, 2, 0.5)
	self:newSprite("upswing",		self.image, 96, 96, 0, 3, 5, 0.1)
	self:newSprite("upmove",		self.image, 96, 96, 0, 4, 4, 0.2)
	self:newSprite("up",			self.image, 96, 96, 0, 5, 2, 0.5)
	self:newSprite("downswing",		self.image, 96, 96, 0, 6, 5, 0.1)
	self:newSprite("downmove",		self.image, 96, 96, 0, 7, 4, 0.2)
	self:newSprite("down",			self.image, 96, 96, 0, 8, 2, 0.5)
	self:newSprite("drop",			self.drop,  32, 32, 0, 0, 6, 0.16)
end

function Item:draw()
	if self.in_range then
		love.graphics.setColor(0, 90, 250, 120)
		love.graphics.circle("fill", self.position.x+16, self.position.y+16, 16, 16)
		love.graphics.setColor(255, 255, 255, 255)
	end

	if self.facing == "drop" then
		self.offset = Vector(0, 0)
	else
		self.offset = Vector(-32, -40)
	end

	if self.facing:find("left") then
		Entity.drawReverseX(self)
	else
		Entity.draw(self)
	end

	--[[
	local size = Vector(
		self.sprites[self.facing].image.fw,
		self.sprites[self.facing].image.fh * 4
	)
	love.graphics.push()
	love.graphics.translate(
		math.floor(self.position.x + self.offset.x + size.x / 2),
		math.floor(self.position.y + self.offset.y)
	)
	love.graphics.setFont(FontDB.roboto.small.medium)
	local function drawText(offset)
		local position = math.floor(-size.y / 2 + offset)
		--love.graphics.printf(("%s: %s"):format(self.name, self.lore), -12, position, 300, "left")
		--love.graphics.printf(("LV: %d"):format(self.req_level), -12, position + 16, 200, "left")
		--love.graphics.printf(("ATK: %d"):format(self.stats.attack), -12, position + 32, 200, "left")
		--love.graphics.printf(("RNG: %1.1f"):format(self.stats.range), -12, position + 48, 200, "left")
	end
	love.graphics.setColor(0, 0, 0, 180)
	drawText(1)
	love.graphics.setColor(255, 255, 255, 255)
	drawText(0)
	love.graphics.pop()
	--]]
end