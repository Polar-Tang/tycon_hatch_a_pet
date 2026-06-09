--[=[
	@class FightEffects

	The named buff/debuff registry for the [Duel pets] turn-based combat. It is the
	single place that maps an effect *name* to both its **presentation** (the `text`
	and `icon` a client renders for the matching `Health` attribute) and its
	**behaviour** (a handful of optional server-side hooks), so a special never has to
	encode behaviour as data — it just `AddEffect`s a name and lets this table drive it
	(the same "call them like pet abilities" idea behind [PetAttacks] / [PetPassives]).

	```lua
	FightEffects[name] = {
		kind     = "buff" | "debuff",                 -- buffs help the holder, debuffs are dealt to the target (the boss)
		text     = "Bleeding",                        -- label/banner for the client
		icon     = "rbxassetid://...",                -- icon ref for the client (placeholder for now)
		outgoing = function(holder, effect, base) ... end,    -- reshape the damage the holder DEALS
		incoming = function(holder, effect, damage) ... end,  -- reshape the damage the holder TAKES
		onApply  = function(holder, effect, session) ... end, -- once, when first added
		onExpire = function(holder, effect, session) ... end, -- once, when it ages out
		onTick   = function(holder, effect, session) ... end, -- each of the holder's turns
		block    = true,                              -- soak the next incoming hit entirely, then spend
	}
	```

	`holder` is the `PetBase` carrying the effect, `effect` the live instance (so a hook
	can read the per-cast `amount` / `multiplier` the special stored on it), and
	`session` the `FightSessionHandler`. [PetBase] consults this table from `Outgoing`,
	`_mitigate`, `_tickEffects` and `AddEffect`.

	This module lives under `ReplicatedStorage.Pets.Fights` so the client can read a
	debuff's `text`/`icon` for the icon it shows next to a fighter's health.
]=]

-- A registered effect: presentation plus optional behaviour hooks. Every field but
-- `kind`/`text`/`icon` is optional, so a purely cosmetic entry (a mechanic still
-- driven by a legacy inline multiplier) is just metadata.
export type Effect = {
	kind: "buff" | "debuff",
	text: string,
	icon: string,
	outgoing: ((holder: any, effect: any, base: number) -> number)?,
	incoming: ((holder: any, effect: any, damage: number) -> number)?,
	onApply: ((holder: any, effect: any, session: any) -> ())?,
	onExpire: ((holder: any, effect: any, session: any) -> ())?,
	onTick: ((holder: any, effect: any, session: any) -> ())?,
	block: boolean?,
}

-- Shared hooks. The magnitudes live on the casting special (passed as the effect's
-- `amount` / `multiplier`), so several named effects can reuse one behaviour and
-- differ only in their text/icon.

-- Scales the damage dealt by the holder (Rally / Alpha Roar / Frenzy).
local function outgoingScale(_holder: any, effect: any, base: number): number
	return base * (effect.multiplier or 1)
end

-- Adds a flat bonus to the damage dealt by the holder (Bear's Rage attack).
local function outgoingAdd(_holder: any, effect: any, base: number): number
	return base + (effect.amount or 0)
end

-- Cuts a flat amount off the damage the holder takes (Bear's Rage defense).
local function incomingReduce(_holder: any, effect: any, damage: number): number
	return damage - (effect.amount or 0)
end

-- Damage-over-time: chips the holder's own health each of its turns (Bleed).
local function tickDamage(holder: any, effect: any, _session: any)
	local health = holder.health
	if not health or not health.Parent then
		return
	end
	health.Value = math.max(0, health.Value - (effect.amount or 0))
end

-- Armor break: lowers the holder's defense factor while active (so it takes more),
-- and restores it on expiry. With defense negative the holder is amplified, not cut.
local function defenseBreakApply(holder: any, effect: any, _session: any)
	holder._defense -= (effect.amount or 0)
end
local function defenseBreakExpire(holder: any, effect: any, _session: any)
	holder._defense += (effect.amount or 0)
end

local module: { [string]: Effect } = {}

-- Buffs (help the holder; cast on the player's own pets) ----------------------------

-- Dog · Rally: a one-turn team damage bump (the +health half is one-time, done by the special).
module["Rally"] = { kind = "buff", text = "Rallied", icon = "", outgoing = outgoingScale }
-- Lion · Alpha Roar: team damage that ratchets up each time the roar fires (growing multiplier).
module["AlphaRoar"] = { kind = "buff", text = "Emboldened", icon = "", outgoing = outgoingScale }
-- Wolf · Pack Frenzy: a sharp one-turn damage spike for the caster.
module["Frenzy"] = { kind = "buff", text = "Frenzied", icon = "", outgoing = outgoingScale }
-- Bear · Rage Mode (offense): a flat add to the Bear's damage.
module["RageAttack"] = { kind = "buff", text = "Enraged", icon = "", outgoing = outgoingAdd }
-- Bear · Rage Mode (defense): a flat cut to the damage the Bear takes.
module["RageDefense"] = { kind = "buff", text = "Hardened", icon = "", incoming = incomingReduce }
-- Fox · Clone Trick: a decoy that soaks the next hit entirely, then is spent.
module["CloneTrick"] = { kind = "buff", text = "Decoy", icon = "", block = true }

-- Debuffs (dealt to the target — always the boss) ----------------------------------

-- Tiger · Pounce / Rhino · Rampage: a bleed that chips the boss each of its turns.
module["Bleed"] = { kind = "debuff", text = "Bleeding", icon = "", onTick = tickDamage }
-- Bull · Stampede: cracks the boss's armor so it takes extra damage for a couple of turns.
module["DefenseBreak"] = { kind = "debuff", text = "Armor Broken", icon = "", onApply = defenseBreakApply, onExpire = defenseBreakExpire }

-- Metadata-only entries: mechanics still driven by legacy inline multipliers on the
-- effect instance (so no hook here, or they'd double-apply) — registered purely so the
-- client can resolve their text/icon by name.
module["DamageReduction"] = { kind = "debuff", text = "Weakened", icon = "" }
module["Guard"] = { kind = "buff", text = "Guarded", icon = "" }

-- No-op default so callers can index `.outgoing` / `.onTick` etc. without a nil check.
local DEFAULT: Effect = { kind = "buff", text = "", icon = "" }

local FightEffects = {}

--[=[
	Returns the registered effect for a name, falling back to a no-op default so the
	combat machinery (Outgoing / mitigate / tick / apply) can stay effect-agnostic.
]=]
function FightEffects.get(name: string?): Effect
	return (name and module[name]) or DEFAULT
end

return FightEffects
