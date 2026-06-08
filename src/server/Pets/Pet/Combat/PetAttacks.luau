--[=[
	@class PetAttacks

	Attack pool for the [Duel pets] turn-based combat. Each entry is keyed by pet
	name and exposes two **callbacks** rather than data tables:

	```lua
	PetAttacks[petName] = {
		basicAttack   = function(ctx, session) ... end,
		specialAttack = function(ctx, session) ... end,
	}
	```

	`ctx` is the casting fighter (a `PlayerPet` or `Boss`) and `session` is the
	`FightSessionHandler` driving the round. An ability is therefore "merely maths
	regarding the fight": from those two arguments it can read its own stats/effects,
	pick targets off the session, apply buffs/debuffs, and fire the turn through the
	session primitives (`Strike` / `StrikeAll` / `Announce`). The round loop no longer
	inspects attack fields — it just calls `pet:BasicAttack(session)` /
	`pet:SpecialAttack(session)`, so adding a pet or ability never touches the loop.

	The boss is keyed separately (`getBoss`) and draws from an ordered **pool** of
	callbacks it rotates through, one ability per turn.

	There is no real "attack" animation yet (only eat/walk/idle), so the session
	primitives default to the "eat" gesture until VFX/animations land.
]=]

-- A buff/debuff a fighter carries for a number of its own turns. The id doubles as
-- the attribute key written on the target's `Health` so the client can render an
-- icon. A multiplier of `nil` means that side is untouched.
export type Effect = {
	id: string,
	kind: "buff" | "debuff",
	rounds: number,
	-- scales the damage the holder DEALS while active (debuff < 1)
	outgoingMultiplier: number?,
	-- scales the damage the holder TAKES while active (buff < 1)
	incomingMultiplier: number?,
	-- runtime: rounds left, seeded from `rounds` by AddEffect
	_remaining: number?,
}

-- An ability. Runs the whole turn (fire + pacing) through `session`. Returns nothing.
export type AttackFn = (ctx: any, session: any) -> ()

export type PetAttackSet = {
	basicAttack: AttackFn,
	specialAttack: AttackFn,
}

-- The boss rotates through an ordered pool, one ability per turn.
export type BossAttackSet = {
	pool: { AttackFn },
}

local module: { [string]: PetAttackSet } = {}

-- Default set used by any pet without a bespoke entry, so the round loop can stay
-- pet-agnostic.
local DEFAULT: PetAttackSet = {
	basicAttack = function(ctx, session)
		session:Strike(ctx, session.boss, { multiplier = 1, text = "attacks!", duration = 3 })
	end,
	specialAttack = function(ctx, session)
		-- no bespoke special yet: a slightly heavier hit, announced
		session:Strike(ctx, session.boss, {
			multiplier = 1.5,
			text = "uses a special move!",
			isSpecial = true,
			duration = 3,
		})
	end,
}

-- A defensive example: the special guards THIS pet instead of dealing damage.
module["Rhino"] = {
	basicAttack = function(ctx, session)
		session:Strike(ctx, session.boss, { multiplier = 1, text = "rams the boss!", duration = 3 })
	end,
	specialAttack = function(ctx, session)
		-- guard: halve incoming damage on this pet for its next 2 turns. AddEffect
		-- mirrors the remaining rounds onto the pet's Health attribute (a shield icon).
		ctx:AddEffect({ id = "Guard", kind = "buff", rounds = 2, incomingMultiplier = 0.5 })
		session:Announce(ctx, { text = "raises a stone guard!", duration = 2 })
	end,
}

-- An instant example: the special resolves a heavier hit right now.
module["Lion"] = {
	basicAttack = function(ctx, session)
		session:Strike(ctx, session.boss, { multiplier = 1, text = "claws the boss!", duration = 2 })
	end,
	specialAttack = function(ctx, session)
		session:Strike(ctx, session.boss, {
			multiplier = 2,
			text = "unleashes a roar!",
			isSpecial = true,
			duration = 3,
		})
	end,
}

-- A trap example: the special registers a pending trap the boss consults on its turn.
module["Fox"] = {
	basicAttack = function(ctx, session)
		session:Strike(ctx, session.boss, { multiplier = 1, text = "bites the boss!", duration = 3 })
	end,
	specialAttack = function(ctx, session)
		-- the boss owns the trap registry it consults on its turn (trigger stubbed)
		session.boss:AddTrap({ caster = ctx })
		session:Announce(ctx, { text = "lays a snare!", duration = 2 })
	end,
}

-- Builds the standard 3-ability boss pool. Each boss gets its OWN copy (a fresh
-- call) so the four bosses can diverge later without sharing state. Order of rotation:
--   1. weaken  — debuff EVERY living pet's outgoing damage for 2 of their turns.
--   2. execute — a single heavy hit on the WEAKEST (lowest-health) living pet.
--   3. quake   — lighter damage to EVERY living pet at once.
local function buildBossPool(): BossAttackSet
	return {
		pool = {
			function(ctx, session)
				local targets = session:_allAlivePets()
				for _, target in ipairs(targets) do
					target:AddEffect({
						id = "DamageReduction",
						kind = "debuff",
						rounds = 2,
						outgoingMultiplier = 0.5,
					})
				end
				-- no damage: float "Weakened!" instead of a number on each pet
				session:StrikeAll(ctx, targets, {
					multiplier = 0,
					text = "lets out a withering roar!",
					fadeText = "Weakened!",
					isSpecial = true,
					duration = 3,
				})
			end,
			function(ctx, session)
				local target = session:_lowestHealthPet()
				if not target then
					return
				end
				session:Strike(ctx, target, {
					multiplier = 1.5,
					text = "lunges at the weakest!",
					isSpecial = true,
					duration = 4,
				})
			end,
			function(ctx, session)
				session:StrikeAll(ctx, session:_allAlivePets(), {
					multiplier = 0.6,
					text = "slams the ground!",
					isSpecial = true,
					duration = 4,
				})
			end,
		},
	}
end

-- The four bosses, keyed by id. Same pool today, separate copies so each can be
-- tuned independently later.
local bossModule: { [string]: BossAttackSet } = {
	["x-rhino"] = buildBossPool(),
	["goaterberus"] = buildBossPool(),
	["ghidra"] = buildBossPool(),
	["croakan"] = buildBossPool(),
}

local PetAttacks = {}

--[=[
	Returns the attack set for a pet, falling back to a shared default so the round
	loop can stay pet-agnostic.
]=]
function PetAttacks.get(petName: string?): PetAttackSet
	return (petName and module[petName]) or DEFAULT
end

--[=[
	Boss attack pool, keyed by boss id (`x-rhino`, `goaterberus`, `ghidra`,
	`croakan`). Unknown bosses get a fresh standard pool so the round loop never has
	to special-case a missing entry.
]=]
function PetAttacks.getBoss(bossName: string?): BossAttackSet
	return (bossName and bossModule[bossName]) or buildBossPool()
end

return PetAttacks
