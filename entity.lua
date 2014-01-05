local Class = require "libs.hump.class"
local Timer = require "libs.hump.timer"
local Vector = require "libs.hump.vector"

Entity = Class {}

function Entity:init(entity, pos)
	self.name			= entity.name
	self.image			= love.graphics.newImage(entity.image)
	self.offset			= entity.offset
	self.hitbox_start	= entity.hitbox_start
	self.hitbox_end		= entity.hitbox_end
	self.position		= pos:clone() * 32
	self.facing			= "down"
	self.sprites		= {}
	self.timer			= Timer.new()
end

function Entity:closest_tile()
	return Vector(
		math.floor((self.position.x + 16) / 32) * 32,
		math.floor((self.position.y + 16) / 32) * 32
	)
end

function Entity:update(dt)
	self.sprites[self.facing]:update(dt)
	self.timer:update(dt)
end

function Entity:draw()
	if self.show_tile then
		local nearest = self:closest_tile()
		love.graphics.rectangle("line", nearest.x, nearest.y, 32, 32)
	end
	
	local pos = Vector(
		math.floor(self.position.x + self.offset.x),
		math.floor(self.position.y + self.offset.y)
	)
	
	if self.facing == "drop" then
		self.sprites[self.facing]:draw(self.drop, pos.x, pos.y)
	else
		self.sprites[self.facing]:draw(self.image, pos.x, pos.y)
	end
end

function Entity:reset()
	self.sprites[self.facing]:pauseAtStart()
	self.facing = self.facing:sub(1, self.facing:len()-5)
	
	self:resume()
end

function Entity:resume()
	self.sprites[self.facing]:resume()
end
