--[=[
	@class PetPassives

	Passive abilities for the [Duel pets] turn-based combat — the always-on
	counterpart to [PetAttacks]. Where an attack runs on a pet's turn, a passive is
	announced once at the start of combat and then quietly shapes the fight through
	one of three hooks (all optional):

	```lua
	PetPassives[petName] = {
		name      = "Loyalty Boost",                  -- shown in the start-of-combat alert + Health attribute
		onStart   = function(ctx, session) ... end,   -- once, when combat begins
		onTurnEnd = function(ctx, session) ... end,   -- after THIS fighter acts each round
		onIncoming = function(ctx, damage) ... end,   -- transforms a hit this fighter takes (in Apply)
	}
	```

	`ctx` is the holder (a `PlayerPet`), `session` is the `FightSessionHandler`.
	`PetBase` binds the passive once in `Init` (`self._passive`), announces it via
	`ApplyPassive` (alert + `Health` attribute keyed by `name` for the client icon),
	runs `onTurnEnd` from `TickEffects`, and consults `onIncoming` inside `Apply`.

	Tuning knobs are the LOUD_SNAKE_CASE constants below so the numbers stay in one
	place. The stat boosts are additive percentages of the fighter's own stat
	(e.g. `+= meleeVal * 0.25` is +25%).
]=]

-- A passive hook that mutates fight state. Returns nothing.
export type PassiveFn = (ctx: any, session: any) -> ()
-- Incoming-damage hook: given the post-effect damage, returns the final number to
-- apply (e.g. a flat reduction, or 0 for a dodge).
export type IncomingFn = (ctx: any, damage: number) -> number

export type Passive = {
	-- space-free Health attribute key for the client icon (Roblox attribute names
	-- reject spaces/punctuation, so this is NOT `name`). "" means "no passive".
	id: string,
	-- human-readable label shown in the start-of-combat alert
	name: string,
	onStart: PassiveFn?,
	onTurnEnd: PassiveFn?,
	onIncoming: IncomingFn?,
}

-- Stat boosts (added fractions of the fighter's own stat).
local DOG_MELEE_BOOST = 0.25 -- +25% to the Dog's melee
local DOG_TEAM_HEALTH_BOOST = 0.25 -- +25% max/current health to every team pet
local LION_MELEE_BOOST = 0.75 -- +75% to the Lion's melee
local TIGER_MELEE_BOOST = 0.75 -- +75% to the Tiger's melee
local WOLF_MELEE_GROWTH = 0.1 -- +10% to the Wolf's melee each turn end (escalating)

-- Sustain / mitigation.
local BEAR_REGEN = 0.15 -- restore 15% of max health each turn end
local FOX_DODGE_CHANCE = 0.25 -- 25% chance to take 0 from a hit
local RHINO_DAMAGE_REDUCTION = 0.25 -- take 25% less from every hit

-- Offensive (boss-facing).
local BULL_ARMOR_BREAK = 0.15 -- shave 15% of the boss's max health at combat start

-- Bumps every team pet's health by `fraction` (max attribute + current value), once.
-- This is a one-time bonus, not a heal-over-time.
local function boostTeamHealth(session: any, fraction: number)
	for _, pet in ipairs(session.pets) do
		local health = pet.health
		if health and health.Parent then
			local maxHealth = health:GetAttribute("MaxHealth") or health.Value
			health:SetAttribute("MaxHealth", math.floor(maxHealth * (1 + fraction)))
			health.Value = math.floor(health.Value * (1 + fraction))
		end
	end
end

local module: { [string]: Passive } = {}

-- Dog — Loyalty Boost: lifts the whole team's health and its own melee, once.
module["Dog"] = {
	id = "LoyaltyBoost",
	name = "Loyalty Boost",
	onStart = function(ctx, session)
		ctx.meleeVal += ctx.meleeVal * DOG_MELEE_BOOST
		boostTeamHealth(session, DOG_TEAM_HEALTH_BOOST)
	end,
}

-- Lion — King's Strength: a flat, one-time melee jump for consistent high damage.
module["Lion"] = {
	id = "KingsStrength",
	name = "King's Strength",
	onStart = function(ctx, session)
		ctx.meleeVal += ctx.meleeVal * LION_MELEE_BOOST
	end,
}

-- Tiger — Predator Instinct: same one-time melee jump (crit stand-in until crits land).
module["Tiger"] = {
	id = "PredatorInstinct",
	name = "Predator Instinct",
	onStart = function(ctx, session)
		ctx.meleeVal += ctx.meleeVal * TIGER_MELEE_BOOST
	end,
}

-- Bear — Regeneration: heals a slice of its max health after each of its turns.
module["Bear"] = {
	id = "Regeneration",
	name = "Regeneration",
	onTurnEnd = function(ctx, session)
		local health = ctx.health
		if not health or not health.Parent then
			return
		end
		local maxHealth = health:GetAttribute("MaxHealth") or health.Value
		local regen = math.floor(maxHealth * BEAR_REGEN)
		health.Value = math.min(maxHealth, health.Value + regen)
	end,
}

-- Gorilla — Unshaken: stun/knockback resistance has no mechanic yet, so the passive
-- is alert-only (name set, no hooks).
module["Gorilla"] = {
	id = "Unshaken",
	name = "Unshaken",
}

-- Wolf — Blood Hunt: melee compounds a little every turn, so damage climbs the
-- longer the duel runs.
module["Wolf"] = {
	id = "BloodHunt",
	name = "Blood Hunt",
	onTurnEnd = function(ctx, session)
		ctx.meleeVal += ctx.meleeVal * WOLF_MELEE_GROWTH
	end,
}

-- Bull — Armor Break: cracks the boss's armor at the outset, shaving its health.
-- (Stub for the future "reduce defense on every attack" version.)
module["Bull"] = {
	id = "ArmorBreak",
	name = "Armor Break",
	onStart = function(ctx, session)
		local bossHealth = session.boss.health
		if not bossHealth or not bossHealth.Parent then
			return
		end
		local maxHealth = bossHealth:GetAttribute("MaxHealth") or bossHealth.Value
		bossHealth.Value = math.max(0, bossHealth.Value - math.floor(maxHealth * BULL_ARMOR_BREAK))
		bossHealth:SetAttribute("ArmorBreak", true)
	end,
}

-- Fox — Evasion: a chance to shrug a hit entirely (the "extra field on Apply").
module["Fox"] = {
	id = "Evasion",
	name = "Evasion",
	onIncoming = function(ctx, damage)
		if math.random() < FOX_DODGE_CHANCE then
			return 0 -- dodged
		end
		return damage
	end,
}

-- Rhino — Thick Hide: a flat reduction on every incoming hit (stacks with the
-- Guard special's temporary buff).
module["Rhino"] = {
	id = "ThickHide",
	name = "Thick Hide",
	onIncoming = function(ctx, damage)
		return math.floor(damage * (1 - RHINO_DAMAGE_REDUCTION))
	end,
}

-- Default: no passive (empty name → ApplyPassive announces nothing). Lets a fighter
-- without a bespoke passive (and the boss) tick harmlessly.
local DEFAULT: Passive = {
	id = "",
	name = "",
}

local PetPassives = {}

--[=[
	Returns the passive for a pet, falling back to a no-op default so the round loop
	and combat-start hook can stay pet-agnostic.
]=]
function PetPassives.get(petName: string?): Passive
	return (petName and module[petName]) or DEFAULT
end

return PetPassives
