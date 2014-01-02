require "db.item"
local Vector = require "libs.hump.vector"

EnemyDB = {
	jeff = {
		name			= "Jeff",
		image			= "assets/browserquest/mailarmor.png",
		level			= 1,
		equipment		= {
			weapon	= ItemDB.red_sword,
		},
		base_stats		= {
			hp		= 20,
			attack	= 3,
			exp		= 25
		},
		aptitudes		= {
			hp		= 1.5,
			attack	= 1.0,
			exp		= 1.0
		},
		lore			= "The Undefeated",
		offset			= Vector(-16, -32),
		hitbox_start	= Vector(0, 0),
		hitbox_end		= Vector(0, 0),
	},
	kevin = {
		name			= "Kevin",
		image			= "assets/browserquest/platearmor.png",
		level			= 99,
		equipment		= {
			weapon	= ItemDB.red_sword,
		},
		base_stats		= {
			hp		= 37,
			attack	= 1,
			exp		= 119
		},
		aptitudes		= {
			hp		= 1.5,
			attack	= 1.0,
			exp		= 1.0
		},
		lore			= "The jerk who won't come up every weekend anymore because he has a girlfriend",
		offset			= Vector(-16, -32),
		hitbox_start	= Vector(0, 0),
		hitbox_end		= Vector(0, 0),
	},
}
