assert(love and love.image, "love.image is required")
assert(jit, "LuaJIT is required")

local ffi = require("ffi")

ffi.cdef[[
typedef struct ImageData_Pixel
{
	uint8_t r;
	uint8_t g;
	uint8_t b;
	uint8_t a;
} ImageData_Pixel;
]]

local function inside(x, y, w, h)
	return x >= 0 and x < w and y >= 0 and y < h
end

local function ImageData_FFI_mapPixel(imagedata, func, ix, iy, iw, ih)
	local idw, idh = imagedata:getDimensions()
	
	ix = ix or 0
	iy = iy or 0
	iw = iw or idw
	ih = ih or idh
	
	assert(inside(ix, iy, idw, idh) and inside(ix+iw-1, iy+ih-1, idw, idh), "Invalid rectangle dimensions")
	
	local pixels = ffi.cast("ImageData_Pixel *", imagedata:getPointer())
	
	for y=iy, iy+ih-1 do
		for x=ix, ix+iw-1 do
			local p = pixels[y*idw+x]
			p.r, p.g, p.b, p.a = func(x, y, tonumber(p.r), tonumber(p.g), tonumber(p.b), tonumber(p.a))
			pixels[y*idw+x] = p
		end
	end
end

local mt
if debug then
	mt = debug.getregistry()["ImageData"]
else
	mt = getmetatable(love.image.newImageData(1,1))
end
mt.__index.mapPixel = ImageData_FFI_mapPixel
