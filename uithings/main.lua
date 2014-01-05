Signal = require "libs.hump.signal"
Color = require "color"
local Class = require "libs.hump.class"

require "extensions.filesystem"
require "extensions.shorthand"

-- global resource pool
resources = {}

local Window = require "window"

-- Use faster ImageData:mapPixel implementation if possible.
if jit then
	print "Using FFI mapPixel"
	require "libs.fastmap"
else
	print "Using non-FFI mapPixel. Loading might take a bit longer..."
end

function l.keypressed(k, isrepeat)
	if k == "escape" then
		--signal.emit('keypressed', remap(k))
		l.e.push("quit")
	end
	if k == "up" then
		Signal.emit('menu-up')
	end
	if k == "down" then
		Signal.emit('menu-down')
	end
end

function l.load()
	l.g.setBackgroundColor(120, 120, 120)

	resources.fonts = {
		normal = l.g.newFont("assets/fonts/OpenSans-Regular.ttf", 14),
		heading = l.g.newFont("assets/fonts/OpenSans-Semibold.ttf", 18),
	}

	print(l.f.getSaveDirectory())

	local w = Window(0, 0, 350, 500, "Menu")
	w:load_style("style/default.lua")
	w:load_layout("layout/main_menu.lua")
end

function l.update(dt)
	Signal.emit('update', dt)
end

function l.draw()
	l.g.setColor(255, 255, 255, 255)
	l.g.setFont(resources.fonts.normal)
	Signal.emit('draw')
end
