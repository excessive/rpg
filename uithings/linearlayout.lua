local Class = require "libs.hump.class"
local LinearLayout_t = Class {}
local Security = require "security"

function LinearLayout_t:init(parent)
	self.parent = parent
	signal.register('resize', function()
		self:resize()
	end)
end

-- untested
function LinearLayout_t:resize(x, y)
	if self.parent then
		self.box = self.parent:child_box()
	end
end

function LinearLayout_t:set_parent(object, update_box)
	self.parent = object
	self.box = object:child_box()
end

function LinearLayout_t:draw()
	l.g.setColor(230, 230, 230, 255)
	for i=0,9 do
		l.g.rectangle("fill", 0, 64*i+(10*i), self.box.width, 64)
	end
end

return LinearLayout_t
