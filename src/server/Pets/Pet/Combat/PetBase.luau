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
	-- active buffs/debuffs this fighter carries; each ages on its own turn and
	-- mirrors its remaining rounds onto a `Health` attribute for the client icon
	_effects: { PetAttacks.Effect },
	-- this fighter's abilities, bound once by Init
	_attacks: PetAttacks.PetAttackSet,

	Init: (self: PetBase) -> (),
	IsAlive: (self: PetBase) -> boolean,
	BasicAttack: (self: PetBase, session: any) -> (),
	SpecialAttack: (self: PetBase, session: any) -> (),
	Outgoing: (self: PetBase, multiplier: number) -> number,
	TickEffects: (self: PetBase) -> (),
	Apply: (self: PetBase, damage: number) -> number,
	TakeDamage: (self: PetBase, damage: number, position: Vector3?, fadeText: string?) -> (),
	AddEffect: (self: PetBase, effect: PetAttacks.Effect) -> (),
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
		_effects = {},
	}, PetBase)

	return self :: any
end

--[=[
	Binds this fighter's abilities once. Cloned so a future per-instance tweak can't
	leak across pets that share a name. `Boss` overrides this to bind a rotating pool.
]=]
function PetBase.Init(self: PetBase)
	self._attacks = table.clone(PetAttacks.get(self.petName))
end

function PetBase.IsAlive(self: PetBase): boolean
	return self.health.Value > 0
end

-- Run a turn. The bound callback does the maths and drives the session primitives.
function PetBase.BasicAttack(self: PetBase, session: any)
	self._attacks.basicAttack(self, session)
end

function PetBase.SpecialAttack(self: PetBase, session: any)
	self._attacks.specialAttack(self, session)
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
end

function PetBase._tickEffects(self: PetBase)
	local health = self.health
	for index = #self._effects, 1, -1 do
		local effect = self._effects[index]
		effect._remaining = (effect._remaining or effect.rounds) - 1
		if effect._remaining <= 0 then
			table.remove(self._effects, index)
			if health and health.Parent then
				health:SetAttribute(effect.id, nil)
			end
		elseif health and health.Parent then
			health:SetAttribute(effect.id, effect._remaining)
		end
	end
end

--[=[
	Incoming side. Reduces `damage` by this fighter's own active buffs (each a private
	`incomingMultiplier`) and returns the final number. Does NOT write health — the
	session registers the pending hit and the write happens in `TakeDamage` once the
	client confirms.
]=]
function PetBase.Apply(self: PetBase, damage: number): number
	return self:_mitigate(damage)
end

function PetBase._mitigate(self: PetBase, damage: number): number
	local result = damage or 0
	print("damage incomming: ", result)
	-- mitigation is private to the pet being hit (was a session-global accumulator)
	print("self._effects: ", self._effects)
	for _, effect in ipairs(self._effects) do
		if effect.incomingMultiplier then
			result *= effect.incomingMultiplier
		end
	end
	print("damage processed: ", result)

	return math.max(0, math.floor(result))
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
	print("add a buff ", self._effects)
	for _, existing in ipairs(self._effects) do
		if existing.id == effect.id then
			existing._remaining = effect.rounds
			if self.health and self.health.Parent then
				self.health:SetAttribute(existing.id, existing._remaining)
			end
			return
		end
	end

	effect._remaining = effect.rounds
	table.insert(self._effects, effect)
	if self.health and self.health.Parent then
		self.health:SetAttribute(effect.id, effect._remaining)
	end
end

return PetBase
