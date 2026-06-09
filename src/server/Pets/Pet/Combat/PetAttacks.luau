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
	-- per-cast params the named FightEffects hooks read: a flat magnitude (bleed/turn,
	-- flat add/cut, defense shred) and/or a scalar (Rally/Roar/Frenzy damage multiplier)
	amount: number?,
	multiplier: number?,
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

-- Special-attack tuning. Damage bases are a multiple of the caster's melee; bleed
-- fractions are a slice of that base dealt each of the boss's turns; the rest are
-- buff/debuff magnitudes. Kept here (not in FightEffects) so the numbers sit with the
-- ability that casts them — the named effects just apply whatever `amount`/`multiplier`
-- the special hands them.
local TIGER_BASE = 3 -- Pounce Strike base = 3 × melee
local RHINO_BASE = 3 -- Rampage Charge base = 3 × melee
local BULL_BASE = 3 -- Stampede base = 3 × melee
local TIGER_BLEED = 0.2 -- bleed/turn = 20% of the Pounce base
local RHINO_BLEED = 0.05 -- bleed/turn = 5% of the Rampage base
local DOG_HEALTH = 0.25 -- Rally one-time team health bump
local DOG_DAMAGE = 1.25 -- Rally team damage ×1.25 next turn
local LION_ROAR_STEP = 0.15 -- Alpha Roar adds +15% team damage each cast
local BEAR_DEFENSE = 0.2 -- Rage flat damage cut = 20% of the Bear's health
local BEAR_ATTACK = 0.2 -- Rage flat damage add = 20% of the Bear's melee
local WOLF_FRENZY = 1.5 -- Pack Frenzy damage ×1.5 next turn
local BULL_DEFENSE_BREAK = 0.25 -- Stampede makes the boss take +25% for 2 turns

-- A self/team buff applied during the holder's OWN turn is aged once immediately after
-- (the post-attack TickEffects), so we pad its rounds by one to still cover the intended
-- number of *future* turns. Boss debuffs don't need this (the boss acts after the pets).
local SELF_BUFF_OFFSET = 1

local module: { [string]: PetAttackSet } = {}

-- Default set used by any pet without a bespoke entry, so the round loop can stay
-- pet-agnostic.
local DEFAULT: PetAttackSet = {
	basicAttack = function(ctx, session)
		session:Strike(ctx, session.boss, { multiplier = 1, text = "attacks!", duration = 4 })
	end,
	specialAttack = function(ctx, session)
		-- no bespoke special yet: a slightly heavier hit, announced
		session:Strike(ctx, session.boss, {
			multiplier = 1.5,
			text = "uses a special move!",
			isSpecial = true,
			duration = 4,
		})
	end,
}

-- Dog · Rally — boosts the whole team at the start of a fight: a one-time +25% health
-- and a one-turn +25% damage buff on every player pet.
module["Dog"] = {
	basicAttack = function(ctx, session)
		session:Strike(ctx, session.boss, { multiplier = 1, text = "bites the boss!", duration = 4 })
	end,
	specialAttack = function(ctx, session)
		for _, pet in ipairs(session.pets) do
			local health = pet.health
			if health and health.Parent then
				local maxHealth = health:GetAttribute("MaxHealth") or health.Value
				health:SetAttribute("MaxHealth", math.floor(maxHealth * (1 + DOG_HEALTH)))
				health.Value = math.floor(health.Value * (1 + DOG_HEALTH))
			end
			pet:AddEffect({ id = "Rally", kind = "buff", rounds = 1 + SELF_BUFF_OFFSET, multiplier = DOG_DAMAGE })
		end
		session:Announce(ctx, { text = "rallies the team!", duration = 4 })
	end,
}

-- Lion · Alpha Roar — periodically ratchets the whole team's damage up another 15%,
-- stacking the buff's multiplier each time the roar fires.
module["Lion"] = {
	basicAttack = function(ctx, session)
		print("")
		session:Strike(ctx, session.boss, { multiplier = 1, text = "claws the boss!", duration = 4 })
	end,
	specialAttack = function(ctx, session)
		for _, pet in ipairs(session.pets) do
			local roar = pet:GetEffect("AlphaRoar")
			if roar then
				roar.multiplier = (roar.multiplier or 1) + LION_ROAR_STEP
				pet:AddEffect(roar) -- refresh duration; multiplier already bumped
			else
				pet:AddEffect({
					id = "AlphaRoar",
					kind = "buff",
					rounds = 2 + SELF_BUFF_OFFSET,
					multiplier = 1 + LION_ROAR_STEP,
				})
			end
		end
		session:Announce(ctx, { text = "lets out an alpha roar!", duration = 4 })
	end,
}

-- Tiger · Pounce Strike — a heavy burst (200 × melee) that also leaves a 2-turn bleed
-- worth 20% of the hit each of the boss's turns.
module["Tiger"] = {
	basicAttack = function(ctx, session)
		session:Strike(ctx, session.boss, { multiplier = 1, text = "swipes the boss!", duration = 4 })
	end,
	specialAttack = function(ctx, session)
		local base = math.floor(TIGER_BASE * ctx.meleeVal)
		session.boss:AddEffect({ id = "Bleed", kind = "debuff", rounds = 2, amount = math.floor(base * TIGER_BLEED) })
		session:Strike(ctx, session.boss, { damage = base, text = "pounces with a vicious strike!", isSpecial = true, duration = 4 })
	end,
}

-- Bear · Rage Mode — toughens up (flat cut = 20% of its health) and hits harder (flat
-- add = 20% of its melee) for 2 turns.
module["Bear"] = {
	basicAttack = function(ctx, session)
		session:Strike(ctx, session.boss, { multiplier = 1, text = "mauls the boss!", duration = 4 })
	end,
	specialAttack = function(ctx, session)
		local curHealth = (ctx.health and ctx.health.Value) or 0
		ctx:AddEffect({ id = "RageDefense", kind = "buff", rounds = 2 + SELF_BUFF_OFFSET, amount = math.floor(curHealth * BEAR_DEFENSE) })
		ctx:AddEffect({ id = "RageAttack", kind = "buff", rounds = 2 + SELF_BUFF_OFFSET, amount = math.floor(ctx.meleeVal * BEAR_ATTACK) })
		session:Announce(ctx, { text = "enters a rage!", duration = 4 })
	end,
}

-- Bull · Stampede — a heavy hit (300 × melee) that cracks the boss's armor, making it
-- take +25% for 2 turns.
module["Bull"] = {
	basicAttack = function(ctx, session)
		session:Strike(ctx, session.boss, { multiplier = 1, text = "gores the boss!", duration = 4 })
	end,
	specialAttack = function(ctx, session)
		local base = math.floor(BULL_BASE * ctx.meleeVal)
		session.boss:AddEffect({ id = "DefenseBreak", kind = "debuff", rounds = 2, amount = BULL_DEFENSE_BREAK })
		session:Strike(ctx, session.boss, { damage = base, text = "stampedes through the boss!", isSpecial = true, duration = 4 })
	end,
}

-- Wolf · Pack Frenzy — a one-turn +50% damage spike for the Wolf.
module["Wolf"] = {
	basicAttack = function(ctx, session)
		session:Strike(ctx, session.boss, { multiplier = 1, text = "snaps at the boss!", duration = 4 })
	end,
	specialAttack = function(ctx, session)
		ctx:AddEffect({ id = "Frenzy", kind = "buff", rounds = 1 + SELF_BUFF_OFFSET, multiplier = WOLF_FRENZY })
		session:Announce(ctx, { text = "whips into a frenzy!", duration = 4 })
	end,
}

-- Rhino · Rampage Charge — a heavy hit (300 × melee) plus a lighter 2-turn bleed worth
-- 5% of the hit each of the boss's turns.
module["Rhino"] = {
	basicAttack = function(ctx, session)
		session:Strike(ctx, session.boss, { multiplier = 1, text = "rams the boss!", duration = 4 })
	end,
	specialAttack = function(ctx, session)
		local base = math.floor(RHINO_BASE * ctx.meleeVal)
		session.boss:AddEffect({ id = "Bleed", kind = "debuff", rounds = 2, amount = math.floor(base * RHINO_BLEED) })
		session:Strike(ctx, session.boss, { damage = base, text = "charges with a rampage!", isSpecial = true, duration = 4 })
	end,
}

-- Fox · Clone Trick — a decoy that fully blocks the next hit the Fox would take
-- (consumed on block, see FightEffects "CloneTrick").
module["Fox"] = {
	basicAttack = function(ctx, session)
		session:Strike(ctx, session.boss, { multiplier = 1, text = "bites the boss!", duration = 4 })
	end,
	specialAttack = function(ctx, session)
		ctx:AddEffect({ id = "CloneTrick", kind = "buff", rounds = 3 + SELF_BUFF_OFFSET })
		session:Announce(ctx, { text = "splits into a decoy!", duration = 4 })
	end,
}

-- Gorilla · Ground Slam — the only trap for now: registers a "skip" the boss consults on
-- its turn, which makes it forfeit that attack entirely.
module["Gorilla"] = {
	basicAttack = function(ctx, session)
		session:Strike(ctx, session.boss, { multiplier = 1, text = "pummels the boss!", duration = 4 })
	end,
	specialAttack = function(ctx, session)
		session.boss:AddTrap({ kind = "skip", caster = ctx })
		session:Announce(ctx, { text = "stuns the boss with a ground slam!", duration = 4 })
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
					duration = 4,
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
