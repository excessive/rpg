local exit = {}

function exit:enter(state)
	love.event.push("quit")
end

return exit
