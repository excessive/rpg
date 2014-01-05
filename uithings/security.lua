return {
	safe_load = function(data)
		local f = assert(loadstring("return (" .. data .. ")"))
		local count = 0
		debug.sethook(function()
			count = count + 1
			if count >= 3 then
				error "cannot call functions"
			end
		end, "c")
		local ok, res = pcall(f)
		count = 0
		debug.sethook()
		return ok, res
	end
}
