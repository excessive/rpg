local Easing = require "libs.easing"
local Class = require "libs.hump.class"
local Security = require "security"

local Window_t = Class {}

function Window_t:load()
	local function mk_gradient(size, mode, start_color, end_color)
		assert(size > 0, "Can't make a zero-size gradient.")
		assert(start_color:typeOf("Color"), "Start color must be of type \"Color\"")
		assert(end_color:typeOf("Color"), "End color must be of type \"Color\"")
		assert(Easing[mode] ~= nil, "Invalid easing mode")

		local data = l.i.newImageData(1, size)
		local diff = end_color - start_color
		data:mapPixel(function(x, y, r, g, b, a)
			r = Easing[mode](y, start_color.r, diff.r, size)
			g = Easing[mode](y, start_color.g, diff.g, size)
			b = Easing[mode](y, start_color.b, diff.b, size)
			a = Easing[mode](y, start_color.a, diff.a, size)
			return r, g, b, a
		end)
		return data
	end

	local props = self.properties
	local style = self.style
	if not resources.window_gradient and style.header_size > 0 then
		resources.window_gradientData = mk_gradient(
			style.header_size,
			style.header_mode,
			style.header_top,
			style.header_bottom
		)
		resources.window_gradient = l.g.newImage(resources.window_gradientData)
	end
	Signal.register('draw', function()
		self:draw()
	end)
	self:update_box()
	if self.callback then
		self:callback()
	end
end

function Window_t:update_box(force_rebuild)
	local props = self.properties
	local style = self.style

	local newbox = {
		x = props.x + style.margin,
		y = props.y + style.margin,
		width = props.width - (style.margin * 2),
		height = props.height - (style.margin * 2),
	}

	if force_rebuild or not props.box or
		(props.box.width  ~= newbox.width or
		 props.box.height ~= newbox.height)
	then
		props.box = newbox
		self:rebuild()
	end
end

function Window_t:move(x, y)
	self.properties.x = x
	self.properties.y = x
	self:update_box()
end

function Window_t:resize(w, h)
	self.properties.width = w
	self.properties.height = h
	self:update_box()
end

function Window_t:rebuild()
	local props = self.properties
	local style = self.style

	-- top part (gradiated)
	local max_uv = math.min(props.box.height / style.header_size, 1.0)
	local verts = {}
	if style.header_size > 0 then
		verts[#verts+1] = { props.box.width, 0.0, 1.0, 0.0, 0, 0, 0 }
		verts[#verts+1] = { props.box.width, math.min(style.header_size, props.box.height), 0.0, max_uv, 0, 0, 0 }
		verts[#verts+1] = { 0.0, 0.0, 0.0, 0.0, 0, 0, 0 }
		verts[#verts+1] = { 0.0, math.min(style.header_size, props.box.height), 0.0, max_uv, 0, 0, 0 }
		verts[#verts+1] = { 0.0, math.min(style.header_size, props.box.height), 0.0, max_uv }
	end

	-- the rest
	if props.box.height > style.header_size then
		local height = props.box.height - style.header_size
		verts[#verts+1] = { 0.0, height + style.header_size, 0.0, 1.0 }
		verts[#verts+1] = { 0.0, style.header_size, 0.0, 1.0 }
		verts[#verts+1] = { props.box.width, height + style.header_size, 0.0, 1.0 }
		verts[#verts+1] = { props.box.width, style.header_size, 0.0, 1.0 }
	end
	self.resources.mesh = l.g.newMesh(verts, style.use_gradient and resources.window_gradient or nil, "strip")

	-- shadow
	local shadow_box = {
		x = -style.shadow.spread,
		y = -style.shadow.spread,
		width = props.box.width + style.shadow.spread,
		height = props.box.height + style.shadow.spread
	}
	local shadow_verts = {
		{ shadow_box.x, shadow_box.height,		0.0, 0.0,	0, 0, 0, 150 },
		{ shadow_box.x, shadow_box.y,			0.0, 0.0,	0, 0, 0, 150 },
		{ shadow_box.width, shadow_box.height,	0.0, 0.0,	0, 0, 0, 150 },
		{ shadow_box.width, shadow_box.y,		0.0, 0.0,	0, 0, 0, 150 }
	}

	self.resources.shadowMesh = l.g.newMesh(shadow_verts, nil, "strip")
end

function Window_t:draw()
	local props = self.properties
	local style = self.style

	-- window backing
	l.g.draw(
		self.resources.shadowMesh,
		props.box.x + style.shadow.x,
		props.box.y + style.shadow.y
	)
	l.g.draw(
		self.resources.mesh,
		props.box.x,
		props.box.y
	)

	l.g.setColor(0x00, 0x99, 0xcc, 255)
	l.g.rectangle("fill", props.box.x, props.box.y + 40, props.box.width, 2)

	-- title
	l.g.setFont(resources.fonts.heading)
	l.g.setColor(180, 180, 180, 255)
	l.g.print(self.title, props.box.x + 10, props.box.y + 6)

	l.g.setColor(255, 255, 255, 255)

	local child_box = self:child_box()

	l.g.push()
	l.g.translate(child_box.x, child_box.y)
	l.g.setScissor(child_box.x, child_box.y, child_box.width, child_box.height)
	for _,v in pairs(self.children) do
		v:draw()
	end
	l.g.setScissor()
	l.g.pop()
end

function Window_t:child_box()
	local props = self.properties
	local style = self.style
	local tmp = {
		x = props.box.x + style.padding,
		y = props.box.y + style.header_size + 2 + style.padding,
		width = props.box.width - style.padding * 2,
		height = props.box.height - style.header_size - 2 - style.padding * 2
	}
	return tmp
end

function Window_t:add_child(object)
	assert(object ~= nil)
	object:set_parent(self)
	table.insert(self.children, object)
end

local function read_config(file)
	assert(l.f.isFile(file))

	local file_contents = l.f.read(file)
	local status, data = Security.safe_load(file_contents)

	if not status then
		data = {}
	end

	return data
end

local function print_r(t, _level)
	local level = _level or 0
	for k,v in pairs(t) do
		local prefix = string.rep("\t", level)
		print(prefix .. k,v)
		if type(v) == "table" then
			print_r(v, level + 1)
		end
	end
end

function Window_t:load_style(file)
	local data = read_config(file)

	print_r(data)
end

function Window_t:load_layout(file)
	local data = read_config(file)

	print_r(data)
end

function Window_t:init(x, y, w, h, title, onload, style)
	assert(w > 0)
	assert(h > 0)
	assert(title)

	self.title = title
	self.style = {
		margin = 10,
		padding = 10,
		use_gradient = false,
		header_size = 40,
		header_mode = "outQuad",
		header_top = Color(255, 255, 255),
		header_bottom = Color(220, 220, 220),
		shadow = {
			spread = 2,
			x = 0,
			y = 0
		}
	}
	self.properties = {
		x = x, y = y,
		width = w, height = h,
		callback = onload
	}
	self.resources = {}
	self.children = {}

	self:load()
end

return Window_t
