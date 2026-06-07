--[=[
	@class PetAttacks

	Decoupled attack pool for the [Duel pets] turn-based combat. Mirrors the
	`PetBonuses` style: a `module[petName]` table plus a `.get(petName)` accessor
	that falls back to a safe default so *any* pet can fight even without an entry.

	The round loop in `FightSessionHandler` only ever reads generic fields off an
	attack table — `duration`, `damageMultiplier`, `kind`, `animation`, `text`,
	`apply` — so adding a new pet or a new ability never touches the loop.

	Each pet exposes two attacks:
	- `basicAttack`   — deals `damageMultiplier * Melee` damage.
	- `specialAttack` — routed by `kind`. Effects are STUBBED for now (text only),
	  but the plug-in surface is ready:
	    * "defensive" — register a buff on the caster (e.g. damage reduction); the
	      boss turn reads the accumulated `session.defense`.
	    * "instant"   — resolve immediately at cast time (e.g. burst / heal).
	    * "trap"      — register a pending trap consulted when the boss attacks
	      (reflect / block). This is what the boss defense check is for.

	There is no real "attack" animation in `animationsData` yet (only eat/walk/idle),
	so attacks default to the "eat" gesture as a placeholder until VFX/animations land.
]=]

export type specialKind = "defensive" | "instant" | "trap"

export type Attack = {
	duration: number,
	damageMultiplier: number,
	animation: string,
	text: string?,
	-- only meaningful on specials
	kind: specialKind?,
	apply: ((session: any, caster: any) -> ())?,
}

export type PetAttackSet = {
	basicAttack: Attack,
	specialAttack: Attack,
}

local PLACEHOLDER_ANIM = "eat"

local module: { [string]: PetAttackSet } = {}

-- Default set used by any pet without a bespoke entry. Keeps the framework total:
-- the loop never has to special-case a missing pet.
local DEFAULT: PetAttackSet = {
	basicAttack = {
		duration = 3,
		damageMultiplier = 1,
		animation = PLACEHOLDER_ANIM,
		text = "attacks!",
	},
	specialAttack = {
		duration = 3,
		damageMultiplier = 0,
		kind = "instant",
		animation = PLACEHOLDER_ANIM,
		text = "uses a special move!",
		apply = function(_session, _caster)
			-- stub: no numeric effect yet
		end,
	},
}

-- A defensive example: caster buffs the team's damage reduction. Stubbed — the
-- buff entry is registered by `_applySpecial`; the numeric effect lands later.
module["Rhino"] = {
	basicAttack = {
		duration = 3,
		damageMultiplier = 1,
		animation = PLACEHOLDER_ANIM,
		text = "rams the boss!",
	},
	specialAttack = {
		duration = 2,
		damageMultiplier = 0,
		kind = "defensive",
		animation = PLACEHOLDER_ANIM,
		text = "raises a stone guard!",
		apply = function(_session, _caster)
			-- stub: real damage-reduction value plugs in here
		end,
	},
}

-- An instant example: resolves at cast time (e.g. a quick burst).
module["Lion"] = {
	basicAttack = {
		duration = 2,
		damageMultiplier = 1,
		animation = PLACEHOLDER_ANIM,
		text = "claws the boss!",
	},
	specialAttack = {
		duration = 3,
		damageMultiplier = 0,
		kind = "instant",
		animation = PLACEHOLDER_ANIM,
		text = "unleashes a roar!",
		apply = function(_session, _caster)
			-- stub: instant burst/heal plugs in here
		end,
	},
}

-- A trap example: registers a pending trap the boss turn checks (reflect / block).
module["Fox"] = {
	basicAttack = {
		duration = 3,
		damageMultiplier = 1,
		animation = PLACEHOLDER_ANIM,
		text = "bites the boss!",
	},
	specialAttack = {
		duration = 2,
		damageMultiplier = 0,
		kind = "trap",
		animation = PLACEHOLDER_ANIM,
		text = "lays a snare!",
		apply = function(_session, _caster)
			-- stub: trap trigger logic plugs in here
		end,
	},
}

-- Boss attack pool (single basic for now; respects the team's `defense`).
local BOSS_ATTACK: PetAttackSet = {
	basicAttack = {
		duration = 4,
		damageMultiplier = 1,
		animation = PLACEHOLDER_ANIM,
		text = "strikes!",
	},
	specialAttack = DEFAULT.specialAttack,
}

local PetAttacks = {}

--[=[
	Returns the attack set for a pet, falling back to a shared default so the
	round loop can stay pet-agnostic.
]=]
function PetAttacks.get(petName: string?): PetAttackSet
	return (petName and module[petName]) or DEFAULT
end

--[=[
	Boss attack set. Kept separate so bosses can later diverge from the pet pool.
]=]
function PetAttacks.getBoss(_bossName: string?): PetAttackSet
	return BOSS_ATTACK
end

return PetAttacks
