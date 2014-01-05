require "libs.TEsound"
local Timer = require "libs.hump.timer"

local title = {}

function title:enter(state)
	self.current = 1

	self.fading = true
	self.lock_input = false

	self.actions = {
		{ name="Play",    screen="gameplay" },
		{ name="Options", screen="options" },
		{ name="Exit",    screen="exit" }
	}

	self.bgm = TEsound.playLooping("assets/bgm/title.ogg")
	TEsound.volume(self.bgm, 0.5)

	self.default_font = love.graphics.getFont()
	self.font = love.graphics.newFont("assets/fonts/roboto-regular.ttf", 28)
	love.graphics.setFont(self.font)

	self.check = love.graphics.newImage("assets/sprites/check.png")
	self.nepgear = love.graphics.newImage("assets/sprites/nepgear.jpg")
	self.spinner = love.graphics.newImage("assets/sprites/spinna.png")
	self.spinner_spin = 0.0

	self.timer = Timer.new()
	self.fade_params = { opacity = 255 }
	self.bgm_params = { volume = 0.5 }
	self.timer:add(1/60, function()
		self.timer:tween(0.25, self.fade_params, { opacity = 0 }, 'in-out-sine')
		self.timer:add(0.25, function()
			self.fading = false
		end)
	end)
end

function title:leave()
	TEsound.stop(self.bgm)
	TEsound.cleanup()
	love.graphics.setFont(self.default_font)
end

function title:update(dt)
	if self.fading then
		TEsound.volume(self.bgm, self.bgm_params.volume)
	end
	self.spinner_spin = self.spinner_spin + 0.25 * dt

	self.timer:update(dt)
end

function title:draw()
	local scale_factor	= love.graphics.getHeight()	/ 600
	local screen_width	= love.graphics.getWidth()	/ scale_factor
	local screen_height	= love.graphics.getHeight()	/ scale_factor

	love.graphics.push()
	love.graphics.scale(scale_factor, scale_factor)

	local scale = 0.75
	local nepW = (screen_width / 2) - (self.nepgear:getWidth() / 2 * scale)
	love.graphics.setBackgroundColor(255, 255, 255, 100)
	love.graphics.clear()
	love.graphics.setColor(255, 255, 255, 100)
	love.graphics.draw(self.nepgear, nepW, 0, 0, scale, scale)
		
	love.graphics.push()
	love.graphics.translate(screen_width/2, screen_height/2)
	love.graphics.rotate(self.spinner_spin)
	love.graphics.translate(-self.spinner:getWidth()/2, -self.spinner:getHeight()/2)
	love.graphics.draw(self.spinner, 0, 0)
	love.graphics.pop()
	
	love.graphics.push()
	love.graphics.translate(25, screen_height/3)
	for i, v in ipairs(self.actions) do
		local spacing = 30
		love.graphics.setColor(0, 0, 0, 120)
		if i == self.current then
			love.graphics.setColor(0, 0, 0, 255)
		end
	
		love.graphics.print(v.name, 72, i*spacing+20)
	end
	love.graphics.pop()

	love.graphics.pop()

	if self.fading then
		love.graphics.setColor(255, 255, 255, self.fade_params.opacity)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	end
end

function title:keypressed(key, unicode)
	if self.lock_input then return end
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
			self.lock_input = true
			self.fading = true
			self.timer:tween(0.25, self.fade_params, { opacity = 255 }, 'in-out-sine')
			self.timer:tween(0.25, self.bgm_params, { volume = 0.0 })
			self.timer:add(0.25, function()
				Gamestate.switch(require("states."..action.screen))
			end)
		end
	end
end

return title
