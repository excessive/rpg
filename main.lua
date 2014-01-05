Gamestate = require "libs.hump.gamestate"
Signal = require "libs.hump.signal"

function love.load()
	local title = require "states.title"
	Gamestate.switch(title)
	Gamestate.registerEvents()
end
