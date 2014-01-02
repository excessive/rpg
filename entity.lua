require "libs.AnAL"
local Class = require "libs.hump.class"
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
end

function Entity:closest_tile()
	return Vector(
		math.floor((self.position.x + 16) / 32) * 32,
		math.floor((self.position.y + 16) / 32) * 32
	)
end

function Entity:update(dt)
	self.sprites[self.facing].image:update(dt)
end

function Entity:draw()
	if self.show_tile then
		local nearest = self:closest_tile()
		love.graphics.rectangle("line", nearest.x, nearest.y, 32, 32)
	end
	local v = Vector(
		math.floor(self.position.x + self.offset.x),
		math.floor(self.position.y + self.offset.y)
	)
	self.sprites[self.facing].image:draw(v.x, v.y)
end

function Entity:drawReverseX()
	if self.show_tile then
		local nearest = self:closest_tile()
		love.graphics.rectangle("line", nearest.x, nearest.y, 32, 32)
	end
	local v = Vector(
		math.floor(self.position.x + self.offset.x),
		math.floor(self.position.y + self.offset.y)
	)
	self.sprites[self.facing].image:draw(v.x, v.y, 0, -1, 1, self.sprites[self.facing].width, 0)
end

function Entity:drawReverseY()
	if self.show_tile then
		local nearest = self:closest_tile()
		love.graphics.rectangle("line", nearest.x, nearest.y, 32, 32)
	end
	local v = Vector(
		math.floor(self.position.x + self.offset.x),
		math.floor(self.position.y + self.offset.y)
	)
	self.sprites[self.facing].image:draw(v.x, v.y, 0, 1, -1, 0, self.sprites[self.facing].height)
end

--[[
	New Sprites
	
	name	- Name of sprite
	img		- Spritemap
	w		- Sprite width
	h		- Sprite height
	ox		- Frame Offset: X
	oy		- Frame Offset: Y
	f		- Number of frames
	ft		- Time to display each frame (in seconds)
]]--
function Entity:newSprite(name, img, w, h, ox, oy, f, ft)
	local a = newAnimation(img, w, h, ft, 1)
	a.frames = {}

	for i = 0, f - 1 do
		a:addFrame(i * w + ox * w, oy * h, w, h, ft)
	end

	self.sprites[name] = {}
	self.sprites[name].image	= a
	self.sprites[name].width	= w
	self.sprites[name].height	= h
end