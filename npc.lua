require "character"
local Class = require "libs.hump.class"
local Vector = require "libs.hump.vector"
local anim8 = require "libs.anim8"

NPC = Class {}
NPC:include(Character)

function NPC:init(npc, pos)
	Character.init(self, npc, pos)

	local g = anim8.newGrid(48, 48, self.image:getWidth(), self.image:getHeight())
	
	self.sprites = {
		down = anim8.newAnimation(g(1,1), 0.5)
	}
	--self:newSprite("down",	self.image, 50, 48, 0, 0, 2, 0.5)
	self.shadow_offset = npc.shadow_offset or Vector(0, 0)
end

function NPC:draw()
	local position = self.position + self.offset + self.shadow_offset
--	position.x = position.x + 32 - 6
--	position.y = position.y + self.sprites[self.facing].image.fh + 6

	love.graphics.push()
	love.graphics.translate(position.x, position.y)
	love.graphics.scale(1, 0.5)
	love.graphics.setColor(0, 0, 0, 50)
    love.graphics.circle("fill", 0, -22, 14, 16)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.pop()

	Character.draw(self)
end
