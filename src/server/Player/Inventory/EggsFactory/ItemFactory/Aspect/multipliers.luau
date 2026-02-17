return {
	-- experience gained = baseXP * buffXP
	XP = {
		common = 1.5,
		uncommon = 2,
		rare = 3,
		epic = 4,
	},
	-- dmg = dmg + dmgBuff
	DMG = {
		common = 4,
		uncommon = 8,
		rare = 16,
		epic = 32,
	},
	-- actualSpeed = actualSpeed - (actualSpeed*speedBuff)

	speed = {
		common = 1 / 16,
		uncommon = 1 / 8,
		rare = 1 / 4,
		epic = 1 / 2,
	},
	-- maxLife = maxLife + buffLife
	stamina = {
		common = 64,
		uncommon = 128,
		rare = 256,
		epic = 512,
	},
	-- consumable
	-- actualLife = actualLife + buffSpeed
	poisonHealth = {
		common = 128,
		uncommon = 256,
		rare = 512,
		epic = 1024,
	},
}
