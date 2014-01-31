require "entity"
local Class = require "libs.hump.class"
local Vector = require "libs.hump.vector"

Terrain = Class {}
Terrain:include(Entity)

function Terrain:init(terrain, pos)
	terrain.pos = pos
	
	Entity.init(self, terrain)
	
	self.start			= terrain.start
	self["end"]			= terrain["end"]
	self.width			= self["end"].x - self.start.x + 1
	self.height			= self["end"].y - self.start.y + 1
	self.quad			= love.graphics.newQuad(self.start.x*32, self.start.y*32, self.width*32, self.height*32, 1024, 1024)
end

function Terrain:update(dt) end

function Terrain:draw()
	love.graphics.draw(self.image, self.quad, self.position.x, self.position.y)
end
