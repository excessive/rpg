local Vector = require "libs.hump.vector"

ItemDB = {
	-- swords
	sword = {
		name			= "Sword",
		image			= "assets/browserquest/sword2.png",
		drop			= "assets/browserquest/item-sword2.png",
		type			= "sword",
		req_level		= 1,
		stats			= {
			attack	= 5,
			range	= 1.75,
		},
		lore			= "This isn't very sharp...",
		offset			= Vector(0, 0),
		hitbox_start	= Vector(0, 0),
		hitbox_end		= Vector(0, 0),
	},
	blue_sword = {
		name			= "Blue Sword",
		image			= "assets/browserquest/bluesword.png",
		drop			= "assets/browserquest/item-bluesword.png",
		type			= "sword",
		req_level		= 5,
		stats			= {
			attack	= 32,
			range	= 1.75,
		},
		lore			= "DA BA DEE, DA BA DIE!",
		offset			= Vector(0, 0),
		hitbox_start	= Vector(0, 0),
		hitbox_end		= Vector(0, 0),
	},
	red_sword = {
		name			= "Red Sword",
		image			= "assets/browserquest/redsword.png",
		drop			= "assets/browserquest/item-redsword.png",
		type			= "sword",
		req_level		= 11,
		stats			= {
			attack	= 83,
			range	= 1.75,
		},
		lore			= "One does not simply cut down Mordor",
		offset			= Vector(0, 0),
		hitbox_start	= Vector(0, 0),
		hitbox_end		= Vector(0, 0),
	},
	gold_sword = {
		name			= "Golden Sword",
		image			= "assets/browserquest/goldensword.png",
		drop			= "assets/browserquest/item-goldensword.png",
		type			= "sword",
		req_level		= 20,
		stats			= {
			attack	= 9001,
			range	= 2,
		},
		lore			= "FUCK THIS AREA IN PARTICULAR!",
		offset			= Vector(0, 0),
		hitbox_start	= Vector(0, 0),
		hitbox_end		= Vector(0, 0),
	},
	-- axes
	axe = {
		name			= "Axe",
		image			= "assets/browserquest/axe.png",
		drop			= "assets/browserquest/item-axe.png",
		type			= "axe",
		req_level		= 1,
		stats			= {
			attack	= 5,
			range	= 1.75,
		},
		lore			= "AND MY AXE!",
		offset			= Vector(0, 0),
		hitbox_start	= Vector(0, 0),
		hitbox_end		= Vector(0, 0),
	},
	morning_star = {
		name			= "Morning Star",
		image			= "assets/browserquest/morningstar.png",
		drop			= "assets/browserquest/item-morningstar.png",
		type			= "axe",
		req_level		= 5,
		stats			= {
			attack	= 47,
			range	= 1.75,
		},
		lore			= "Rise and shine.",
		offset			= Vector(0, 0),
		hitbox_start	= Vector(0, 0),
		hitbox_end		= Vector(0, 0),
	}
}
