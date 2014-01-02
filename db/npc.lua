local Vector = require "libs.hump.vector"

NPCDB = {
	smith = {
		name			= "Smith",
		image			= "assets/browserquest/agent.png",
		offset			= Vector(-8, -22),
		hitbox_start	= Vector(0, 0),
		hitbox_end		= Vector(0, 0),
	},
	priest = {
		name			= "Priest",
		image			= "assets/browserquest/priest.png",
		offset			= Vector(-8, -22),
		hitbox_start	= Vector(0, 0),
		hitbox_end		= Vector(0, 0),
	},
	dead = {
		name			= "lolded",
		image			= "assets/browserquest/lavanpc.png",
		offset			= Vector(-10, -10),
		shadow_offset	= Vector(0, -12),
		hitbox_start	= Vector(0, 0),
		hitbox_end		= Vector(0, 0),
	},
}
