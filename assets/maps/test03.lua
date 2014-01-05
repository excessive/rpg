require "player"
require "enemy"
require "npc"
require "item"
require "terrain"

require "db.enemy"
require "db.npc"
require "db.item"
require "db.terrain"

local Vector = require "libs.hump.vector"

local objects = {
	player	= Player("assets/browserquest/goldenarmor.png", Vector(41, 58)),
	enemies	= {
		Enemy(EnemyDB.jeff,		Vector(38, 34)),
		Enemy(EnemyDB.kevin,	Vector(22, 10)),
		Enemy(EnemyDB.kevin,	Vector(23, 10)),
		Enemy(EnemyDB.kevin,	Vector(30, 10)),
		Enemy(EnemyDB.kevin,	Vector(31, 10)),
		Enemy(EnemyDB.kevin,	Vector(38, 10)),
		Enemy(EnemyDB.kevin,	Vector(39, 10)),
	},
	npcs	= {
		NPC(NPCDB.smith,	Vector(10, 58)),
		NPC(NPCDB.priest,	Vector(5, 36)),
		NPC(NPCDB.dead,		Vector(2, 34)),
		NPC(NPCDB.dead,		Vector(4, 34)),
		NPC(NPCDB.dead,		Vector(6, 34)),
		NPC(NPCDB.dead,		Vector(8, 34)),
		NPC(NPCDB.dead,		Vector(2, 38)),
		NPC(NPCDB.dead,		Vector(4, 38)),
		NPC(NPCDB.dead,		Vector(6, 38)),
		NPC(NPCDB.dead,		Vector(8, 38)),
	},
	items	= {
		Item(ItemDB.blue_sword,	Vector(30, 53)),
	},
	terrain	= {
		Terrain(TerrainDB.house1,	Vector(19, 2)),
		Terrain(TerrainDB.house2,	Vector(27, 1)),
		Terrain(TerrainDB.house3,	Vector(35, 1)),
		Terrain(TerrainDB.tree1,	Vector(17, 8)),
		Terrain(TerrainDB.tree1,	Vector(25, 8)),
		Terrain(TerrainDB.tree1,	Vector(33, 8)),
		Terrain(TerrainDB.tree1,	Vector(41, 8)),
		Terrain(TerrainDB.well1,	Vector(37, 30)),
		Terrain(TerrainDB.rock3,	Vector(28, 52)),
		Terrain(TerrainDB.rock4,	Vector(32, 52)),
		Terrain(TerrainDB.grave1,	Vector(2, 32)),
		Terrain(TerrainDB.grave1,	Vector(4, 32)),
		Terrain(TerrainDB.grave1,	Vector(6, 32)),
		Terrain(TerrainDB.grave1,	Vector(8, 32)),
		Terrain(TerrainDB.grave1,	Vector(2, 36)),
		Terrain(TerrainDB.grave2,	Vector(4, 36)),
		Terrain(TerrainDB.grave1,	Vector(6, 36)),
		Terrain(TerrainDB.grave1,	Vector(8, 36)),
		Terrain(TerrainDB.tent1,	Vector(40, 54)),
	},
}

return objects
