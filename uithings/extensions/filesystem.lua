local _lfsgdi = love.filesystem.getDirectoryItems or love.filesystem.enumerate
function love.filesystem.getDirectoryItems(dir, callback)
	if not callback then
		return _lfsgdi(dir)
	else
		local files = _lfsgdi(dir)
		for i, path in ipairs(files) do
			callback(path)
		end
	end
end
