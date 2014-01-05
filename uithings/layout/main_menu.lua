--[[

[------------row-------------]
[------------row-------------]
[------------row-------------]
[-column-][-column-][-column-]

--]]
{
	type = "LinearLayout",
	orientation = "row",
	children = {
		{
			type = "List",
			class = "menu-item",
			children = {
				{
					action = "TODO"
				},
				{
					action = "TODO"
				},
				{
					action = "TODO"
				},
				{
					action = "TODO"
				}
			}
		},
		{
			type = "LinearLayout",
			orientation = "column",
			children = {
				{
					type = "Button",
					action = "run",
					icon = "check"
				},
				{
					type = "Button",
					action = "cancel",
					icon = "cross"
				}
			}
		}
	}
}
