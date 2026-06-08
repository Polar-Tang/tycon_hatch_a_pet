--[=[
	@class PetBase

	Base combatant for the [Duel pets] turn-based fight. A `PetBase` owns
	everything about a single fighter's combat internals — its `Health`, its
	melee, and its private buff/debuff/defense state — so the session
	(`FightSessionHandler`) is left as a pure orchestrator.

	Two combat-facing responsibilities live here:
	- **Outgoing** (the attacker): `CastAttack` asks the fighter for the damage it
	  deals from its own state plus the targets it hits.
	- **Incoming** (the target): `Apply` reduces the damage by this fighter's own
	  private `_defense`, and `TakeDamage` (on client-confirmed hit) writes its own
	  `Health`. Mitigation is private to the pet being hit, never global.

	`PlayerPet` and `Boss` extend this with `setmetatable(Sub, PetBase)`.

	Effects are STUBBED (text/structure only) for now; every numeric effect is a
	no-op, so this class re-homes the logic without changing behaviour.
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
	_buff: { any },
	_debuff: { any },
	_defense: number,

	IsAlive: (self: PetBase) -> boolean,
	GetAttackSet: (self: PetBase) -> PetAttacks.PetAttackSet,
	SelectAttack: (self: PetBase, isSpecial: boolean) -> PetAttacks.Attack,
	TickEffects: (self: PetBase) -> (),
	CastAttack: (self: PetBase, attack: PetAttacks.Attack, isSpecial: boolean) -> (number, { PetBase }),
	Apply: (self: PetBase, damage: number) -> number,
	TakeDamage: (self: PetBase, damage: number, position: Vector3?) -> (),
	AddBuff: (self: PetBase, buff: any) -> (),
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
		_buff = {},
		_debuff = {},
		_defense = 0,
	}, PetBase)

	return self :: any
end

function PetBase.IsAlive(self: PetBase): boolean
	return self.health.Value > 0
end

-- Which attack pool this fighter draws from. Boss overrides to `getBoss`.
function PetBase.GetAttackSet(self: PetBase): PetAttacks.PetAttackSet
	return PetAttacks.get(self.petName)
end

function PetBase.SelectAttack(self: PetBase, isSpecial: boolean): PetAttacks.Attack
	local attackSet = self:GetAttackSet()
	return isSpecial and attackSet.specialAttack or attackSet.basicAttack
end

--[=[
	Plays this fighter's registered buffs/debuffs for the round (stub: structure
	only — each effect's per-round behaviour plugs in here).
]=]
function PetBase.TickEffects(self: PetBase)
	self:_tickEffects()
end

function PetBase._tickEffects(self: PetBase)
	for _, _effect in ipairs(self._buff) do
		-- stub: buff per-round behaviour plugs in here
	end
	for _, _effect in ipairs(self._debuff) do
		-- stub: debuff per-round behaviour plugs in here
	end
end

--[=[
	Outgoing side. Returns the damage this fighter deals (from its own state) and
	the targets it hits. The session never writes health here — it fires
	`CombatTurn` and waits for the client to confirm the swing landed.
]=]
function PetBase.CastAttack(self: PetBase, attack: PetAttacks.Attack, isSpecial: boolean): (number, { PetBase })
	return self:_castAttack(attack), self:_resolveTargets(attack, isSpecial)
end

function PetBase._castAttack(self: PetBase, attack: PetAttacks.Attack): number
	local base = (attack.damageMultiplier or 0) * (self.meleeVal or 0)
	-- stub: outgoing buffs/debuffs modify `base` here
	return math.max(0, math.floor(base))
end

-- Who this fighter hits. Default: the boss (a pet attacking). Boss overrides.
function PetBase._resolveTargets(self: PetBase, _attack: PetAttacks.Attack, _isSpecial: boolean): { PetBase }
	return { self._session.boss }
end

--[=[
	Incoming side. Reduces `damage` by this fighter's own private `_defense` and
	returns the final number. Does NOT write health — the session registers the
	pending hit and the write happens in `TakeDamage` once the client confirms.
]=]
function PetBase.Apply(self: PetBase, damage: number): number
	return self:_mitigate(damage)
end

function PetBase._mitigate(self: PetBase, damage: number): number
	-- defense is private to the pet being hit (was a session-global accumulator)
	return math.max(0, math.floor((damage or 0) - self._defense))
end

--[=[
	Applies a client-confirmed hit to this fighter's own `Health` and shows the
	damage number where the client reported the hit landed.
]=]
function PetBase.TakeDamage(self: PetBase, damage: number, position: Vector3?)
	local health = self.health
	if not health or not health.Parent then
		return
	end
	health.Value = math.max(0, health.Value - damage)

	if position then
		ReplicatedStorage.RemoteEvents.TextFade:FireClient(self._session.player, {
			text = tostring(damage),
			position = position,
		})
	end
end

function PetBase.AddBuff(self: PetBase, buff: any)
	table.insert(self._buff, buff)
end

return PetBase
