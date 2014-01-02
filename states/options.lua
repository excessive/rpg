local options = {}

function options:enter(state)
	love.event.push("quit")
end

return options
