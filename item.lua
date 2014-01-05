require "entity"
local Class = require "libs.hump.class"
local Vector = require "libs.hump.vector"
local anim8 = require "libs.anim8"

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

	local g = anim8.newGrid(96, 96, self.image:getWidth(), self.image:getHeight())
	local gdrop = anim8.newGrid(32, 32, self.drop:getWidth(), self.drop:getHeight())
	
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
		drop		= anim8.newAnimation(gdrop('1-6',1), 0.16),
	}
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
	
	Entity.draw(self)
end
