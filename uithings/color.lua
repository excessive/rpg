return function(r, g, b, a)
	assert(r ~= nil)
	assert(g ~= nil)
	assert(b ~= nil)
	if a == nil then
		a = 255
	end
	local ret = {
		r = r,
		g = g,
		b = b,
		a = a,
		type = function(self) return "Color" end,
		typeOf = function(self, s) return self:type() == s end
	}
	local function add(a, b)
		local ret = setmetatable({}, a)
		ret.r = a.r + b.r
		ret.g = a.g + b.g
		ret.b = a.b + b.b
		ret.a = a.a + b.a
		return ret
	end
	local function sub(a, b)
		local ret = setmetatable({}, a)
		ret.r = a.r - b.r
		ret.g = a.g - b.g
		ret.b = a.b - b.b
		ret.a = a.a - b.a
		return ret
	end
	setmetatable(ret, {
		__add = add,
		__sub = sub
	})
	return ret
end
