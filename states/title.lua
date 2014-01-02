require "libs.TEsound"
local Vector = require "libs.hump.vector"

local title = {}

function title:enter(state)
	self.current = 1

	self.fading = true
	self.fading_back = true
	self.fade_progress = 0.0

	self.action = nil
	self.actions = {
		{ name="Play",    screen="gameplay" },
		{ name="Options", screen="options" },
		{ name="Exit",    screen="exit" }
	}
	self.default_font = love.graphics.getFont()
	self.font = love.graphics.newFont("assets/fonts/roboto-regular.ttf", 28)
	love.graphics.setFont(self.font)
	self.nepgear = love.graphics.newImage("assets/sprites/nepgear.jpg")
	self.bgm = TEsound.playLooping("assets/bgm/title.ogg")
	TEsound.volume(self.bgm, 0.5)
	self.spinner = love.graphics.newImage("assets/sprites/spinna.png")
	self.spinner_spin = 0.0
	self.check = love.graphics.newImage("assets/sprites/check.png")
end

function title:leave()
	TEsound.stop(self.bgm)
	TEsound.cleanup()
	love.graphics.setFont(self.default_font)
end

function title:update(dt)
	if self.fading then
		local speed = 0.25
		self.fade_progress = self.fade_progress + 1.0/speed * dt
		if self.action then
			TEsound.volume(self.bgm, 0.5 * (1.0 - self.fade_progress))
		end
		if self.fade_progress >= 1.0 then
			self.fading = false
			if not self.fading_back then
				Gamestate.switch(self.action)
			end
		end
	end
	self.spinner_spin = self.spinner_spin + 0.25 * dt
end

function title:draw()
	local scale = 0.75
	local nepW = (love.graphics.getWidth() / 2) - (self.nepgear:getWidth() / 2 * scale)
	love.graphics.setBackgroundColor(255, 255, 255, 100)
	love.graphics.clear()
	love.graphics.setColor(255, 255, 255, 100)
	love.graphics.draw(self.nepgear, nepW, 0, 0, scale, scale)
	
	local width = self.spinner:getWidth()
	local height = self.spinner:getHeight()
	local angle = self.spinner_spin
	
	love.graphics.push()
	love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	love.graphics.rotate(angle)
	love.graphics.translate(-width/2, -height/2)
	love.graphics.draw(self.spinner, 0, 0, 0)
	love.graphics.pop()
	
	love.graphics.push()
	love.graphics.translate(25, love.graphics.getHeight()/3)
	for i, v in ipairs(self.actions) do
		local spacing = 30
		love.graphics.setColor(0, 0, 0, 120)
		if i == self.current then
			if self.action then
				love.graphics.setColor(255, 255, 255, 255)
				love.graphics.push()
				local offset = Vector(self.check:getWidth()/2, i*spacing + self.check:getHeight()/2)
				love.graphics.translate(offset.x, offset.y)
				love.graphics.scale(1 + self.fade_progress * 0.5, 1 + self.fade_progress * 0.5)
				love.graphics.translate(-offset.x, -offset.y)
				love.graphics.setColor(255, 255, 255, 255 - self.fade_progress * 255)
				love.graphics.draw(self.check, 0, i*spacing)
				love.graphics.pop()
			end
			love.graphics.setColor(0, 0, 0, 255)
		end
	
		love.graphics.print(v.name, 72, i*spacing+20)
	end
	love.graphics.pop()
	if self.fading then
		local alpha = self.fade_progress * 255
		if self.fading_back then
			alpha = 255 - alpha
		end
		love.graphics.setColor(255, 255, 255, alpha)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	end
end

function title:keypressed(key, unicode)
	if self.action then return end
	if key == "up" then
		self.current = self.current - 1
		if self.current < 1 then
			self.current = #self.actions
		end
	elseif key == "down" then
		self.current = (self.current % #self.actions) + 1
	end
	
	if key == "return" then
		local action = self.actions[self.current]
		if action then
			self.fading = true
			self.fading_back = false
			self.fade_progress = 0.0
			self.action = require("states."..action.screen)
		end
	end
end

return title
