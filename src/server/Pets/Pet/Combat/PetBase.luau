--[=[
	@class PetBase

	Base combatant for the [Duel pets] turn-based fight. A `PetBase` owns everything
	about a single fighter's combat internals — its `Health`, its melee, and its
	private buff/debuff state — so the session (`FightSessionHandler`) is left as a
	pure orchestrator.

	A fighter binds its abilities once (`Init`) into `self._attacks`, then runs a
	turn via `BasicAttack(session)` / `SpecialAttack(session)` — each just invokes the
	bound callback with `(self, session)`. The callback is where the per-ability maths
	lives (see [PetAttacks]).

	Two combat-facing helpers the callbacks lean on:
	- **Outgoing** (the attacker): `Outgoing(multiplier)` is the damage this fighter
	  deals from its own melee and active debuffs.
	- **Incoming** (the target): `Apply` reduces a hit by this fighter's own active
	  buffs, and `TakeDamage` (on client-confirmed hit) writes its own `Health`.
	  Mitigation is private to the pet being hit, never global.

	`PlayerPet` and `Boss` extend this with `setmetatable(Sub, PetBase)`; `Boss`
	overrides `Init` (a rotating pool) and adds its own `Attack`.
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetAttacks = require(script.Parent.PetAttacks)
local PetPassives = require(script.Parent.PetPassives)
local FightEffects = require(ReplicatedStorage.Pets.Fights.FightEffects)

-- turns a fighter must spend on its basic attack after casting its special: the
-- counter is set on cast and ages once per turn (TickEffects, same beat as effects),
-- and the round loop falls back to the basic attack while it is above zero
local SPECIAL_COOLDOWN_TURNS = 3

-- One fighter the session tracks (built by Init from a pet/boss entry).
export type FighterInfo = {
	id: string,
	petName: string,
	meleeVal: number,
	band: string,
	health: IntValue,
}

export type PetBase = {
	_session: any,
	id: string,
	petName: string,
	meleeVal: number,
	band: string,
	health: IntValue,
	-- fractional damage reduction applied in `_mitigate`: positive softens incoming
	-- hits, negative (e.g. the boss while "Armor Broken") amplifies them. Default 0.
	_defense: number,
	-- active buffs/debuffs this fighter carries; each ages on its own turn and
	-- mirrors its remaining rounds onto a `Health` attribute for the client icon
	_effects: { PetAttacks.Effect },
	-- this fighter's abilities, bound once by Init
	_attacks: PetAttacks.PetAttackSet,
	-- this fighter's passive (always-on), bound once by Init
	_passive: PetPassives.Passive,
	-- turns left before the special may be cast again (0 = ready)
	_specialCooldown: number,

	Init: (self: PetBase) -> (),
	IsAlive: (self: PetBase) -> boolean,
	GetEffect: (self: PetBase, id: string) -> PetAttacks.Effect?,
	ApplyPassive: (self: PetBase, session: any) -> (),
	BasicAttack: (self: PetBase, session: any) -> (),
	SpecialAttack: (self: PetBase, session: any) -> (),
	CanCastSpecial: (self: PetBase) -> boolean,
	Outgoing: (self: PetBase, multiplier: number) -> number,
	TickEffects: (self: PetBase) -> (),
	Apply: (self: PetBase, damage: number) -> (number, boolean),
	TakeDamage: (self: PetBase, damage: number, position: Vector3?, fadeText: string?) -> (),
	AddEffect: (self: PetBase, effect: PetAttacks.Effect) -> (),
	HasHealth: (self: PetBase) -> boolean,
	_tickEffects: (self: PetBase) -> (),
}

local PetBase = {}
PetBase.__index = PetBase

function PetBase.new(session: any, info: FighterInfo): PetBase
	local self = setmetatable({
		_session = session,
		id = info.id,
		petName = info.petName or info.id,
		meleeVal = info.meleeVal,
		band = info.band,
		health = info.health,
		-- per-fighter combat state (was session-global before the refactor)
		_defense = 0,
		_effects = {},
		_specialCooldown = 0,
	}, PetBase)

	return self :: any
end

--[=[
	Binds this fighter's abilities once. Cloned so a future per-instance tweak can't
	leak across pets that share a name. `Boss` overrides this to bind a rotating pool.
]=]
function PetBase.Init(self: PetBase)
	self._attacks = table.clone(PetAttacks.get(self.petName))
	-- shared (not cloned): a passive is read-only state, the same for every pet of
	-- a species, and its onTurnEnd/onIncoming closures hold no per-instance data.
	self._passive = PetPassives.get(self.petName)
end

function PetBase.IsAlive(self: PetBase): boolean
	return self.health.Value > 0
end

-- Returns this fighter's active effect with the given id (or nil). Lets an ability
-- read/stack an effect it already applied (e.g. Lion's growing Alpha Roar).
function PetBase.GetEffect(self: PetBase, id: string): PetAttacks.Effect?
	for _, effect in ipairs(self._effects) do
		if effect.id == id then
			return effect
		end
	end
	return nil
end

function PetBase.HasHealth(self)
	return self.health and self.health.Parent
end

--[=[
	Announces this fighter's passive at the very start of combat: alerts the player
	with the passive's name, mirrors it onto a `Health` attribute (keyed by name) so
	the client can render a permanent icon, then runs its one-time `onStart` hook.
	A fighter without a passive (empty name) does nothing.
]=]
function PetBase.ApplyPassive(self: PetBase, session: any)
	local passive = self._passive
	if not passive or passive.name == "" then
		return
	end

	ReplicatedStorage.RemoteEvents.Notifier:FireClient(session.player, {
		notification = (self.petName or self.id) .. "'s passive: " .. passive.name,
	})
	
	if self:HasHealth() then
		self.health:SetAttribute(passive.id, true)
	end

	if passive.onStart then
		passive.onStart(self, session)
	end
end

-- Run a turn. The bound callback does the maths and drives the session primitives.
function PetBase.BasicAttack(self: PetBase, session: any)
	self._attacks.basicAttack(self, session)
end

-- Casting puts the special on cooldown; the counter ages once per turn in
-- TickEffects, so the next SPECIAL_COOLDOWN_TURNS turns fall back to the basic.
-- Padded by one because the counter also ages on this very cast turn's tick
-- (same idea as SELF_BUFF_OFFSET in PetAttacks).
function PetBase.SpecialAttack(self: PetBase, session: any)
	self._specialCooldown = SPECIAL_COOLDOWN_TURNS + 1
	self._attacks.specialAttack(self, session)
end

function PetBase.CanCastSpecial(self: PetBase): boolean
	return self._specialCooldown <= 0
end

--[=[
	The damage this fighter deals for a given multiplier: `multiplier * melee`, then
	scaled down by any active outgoing debuff (e.g. the boss's "Weakened").
]=]
function PetBase.Outgoing(self: PetBase, multiplier: number): number
	local base = (multiplier or 0) * (self.meleeVal or 0)
	for _, effect in ipairs(self._effects) do
		if effect.outgoingMultiplier then
			base *= effect.outgoingMultiplier
		end
		-- a named effect may reshape outgoing damage (scale or flat add)
		local entry = FightEffects.get(effect.id)
		if entry.outgoing then
			base = entry.outgoing(self, effect, base)
		end
	end
	return math.max(0, math.floor(base))
end

--[=[
	Ages this fighter's effects by one of its turns (call AFTER it has acted, so an
	effect with `rounds = N` modifies exactly N of the holder's attacks). Expired
	effects are dropped and their `Health` attribute cleared; survivors refresh the
	attribute to their remaining rounds so the client icon can count down.
]=]
function PetBase.TickEffects(self: PetBase)
	self:_tickEffects()
	-- the special cooldown ages on the same per-turn beat as the effects
	if self._specialCooldown > 0 then
		self._specialCooldown -= 1
	end
	-- a passive's per-turn hook (regen, escalating melee) fires on the same beat as
	-- effect aging — after this fighter has acted
	if self._passive and self._passive.onTurnEnd then
		self._passive.onTurnEnd(self, self._session)
	end
end

function PetBase._tickEffects(self: PetBase)
	local health = self.health
	for index = #self._effects, 1, -1 do
		local effect = self._effects[index]
		local entry = FightEffects.get(effect.id)
		-- per-turn behaviour (e.g. Bleed damage) fires before the effect ages, so a
		-- 2-round bleed lands exactly 2 ticks
		if entry.onTick then
			entry.onTick(self, effect, self._session)
		end
		effect._remaining = (effect._remaining or effect.rounds) - 1
		if effect._remaining <= 0 then
			table.remove(self._effects, index)
			-- a teardown hook (e.g. Armor Broken restoring defense) runs once on expiry
			if entry.onExpire then
				entry.onExpire(self, effect, self._session)
			end
			if self:HasHealth() then
				health:SetAttribute(effect.id, nil)
			end
		elseif self:HasHealth() then
			health:SetAttribute(effect.id, effect._remaining)
		end
	end
end

--[=[
	Incoming side. Reduces `damage` by this fighter's own active buffs (each a private
	`incomingMultiplier`) and returns the final number plus whether a block (the Fox's
	decoy) soaked the hit entirely. Does NOT write health — the session registers the
	pending hit and the write happens in `TakeDamage` once the client confirms.
]=]
function PetBase.Apply(self: PetBase, damage: number): (number, boolean)
	return self:_mitigate(damage)
end

function PetBase._mitigate(self: PetBase, damage: number): (number, boolean)
	local result = damage or 0
	local blocked = false
	-- a persistent defense factor (private to this pet): positive softens the hit,
	-- negative (the boss while "Armor Broken") amplifies it.
	result *= (1 - (self._defense or 0))
	-- per-effect mitigation: legacy inline multipliers, named-table reshaping, and a
	-- full block. Iterate in reverse so a spent block can be removed in place.
	for index = #self._effects, 1, -1 do
		local effect = self._effects[index]
		if effect.incomingMultiplier then
			result *= effect.incomingMultiplier
		end
		local entry = FightEffects.get(effect.id)
		if entry.block and result > 0 then
			-- a decoy soaks the whole hit, then is spent (removed + icon cleared)
			result = 0
			blocked = true
			table.remove(self._effects, index)
			if self:HasHealth() then
				self.health:SetAttribute(effect.id, nil)
			end
		elseif entry.incoming then
			result = entry.incoming(self, effect, result)
		end
	end
	-- a passive may reshape the hit last (Rhino flat reduction, Fox dodge → 0)
	if self._passive and self._passive.onIncoming then
		result = self._passive.onIncoming(self, result)
	end

	return math.max(0, math.floor(result)), blocked
end

--[=[
	Applies a client-confirmed hit to this fighter's own `Health` and floats text
	where the client reported it landed. `fadeText` overrides the damage number, so a
	non-damaging move (e.g. a debuff) can show "Weakened!" instead of "0".
]=]
function PetBase.TakeDamage(self: PetBase, damage: number, position: Vector3?, fadeText: string?)
	local health = self.health
	if not health or not health.Parent then
		return
	end
	health.Value = math.max(0, health.Value - damage)

	if position then
		ReplicatedStorage.RemoteEvents.TextFade:FireClient(self._session.player, {
			text = fadeText or tostring(damage),
			position = position,
		})
	end
end

--[=[
	Registers a buff/debuff on this fighter. Re-applying the same `id` refreshes its
	duration rather than stacking, and the remaining rounds are mirrored onto a
	`Health` attribute (keyed by `id`) so the client can render an icon.
]=]
function PetBase.AddEffect(self: PetBase, effect: PetAttacks.Effect)
	for _, existing in ipairs(self._effects) do
		if existing.id == effect.id then
			existing._remaining = effect.rounds
			-- refresh any per-cast params on re-application (e.g. a bumped Alpha Roar
			-- multiplier, or a fresh bleed amount) — but NOT onApply, which is one-shot
			if effect.multiplier then
				existing.multiplier = effect.multiplier
			end
			if effect.amount then
				existing.amount = effect.amount
			end
			if self:HasHealth() then
				self.health:SetAttribute(existing.id, existing._remaining)
			end
			return
		end
	end

	effect._remaining = effect.rounds
	table.insert(self._effects, effect)
	-- a one-time hook on first application (e.g. Armor Broken lowering the boss's defense)
	local entry = FightEffects.get(effect.id)
	if entry.onApply then
		entry.onApply(self, effect, self._session)
	end
	if self:HasHealth() then
		self.health:SetAttribute(effect.id, effect._remaining)
	end
end

return PetBase
