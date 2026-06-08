--[=[
	@class Boss

	The boss fighter in the [Duel pets] fight. Extends [PetBase] but draws its
	abilities from an ordered **pool** (keyed per boss in [PetAttacks]) that it rotates
	through one ability per turn, rather than a basic/special pair. The pool callbacks
	pick their own targets off the session (`_allAlivePets` / `_lowestHealthPet`).

	Also owns the trap registry: pets that cast a "trap" special register it here
	(`AddTrap`), and the boss consults/consumes it at the start of its own turn
	(`RunTraps`). Trap effects are STUBBED (structure only).
]=]

local PetBase = require(script.Parent.PetBase)
local PetAttacks = require(script.Parent.PetAttacks)

export type Boss = PetBase.PetBase & {
	_pool: { PetAttacks.AttackFn },
	_attackIndex: number,
	_traps: { any },
	Attack: (self: Boss, session: any) -> (),
	AddTrap: (self: Boss, trap: any) -> (),
	RunTraps: (self: Boss) -> (),
}

local Boss = setmetatable({}, PetBase)
Boss.__index = Boss

function Boss.new(session: any, info: PetBase.FighterInfo): Boss
	local self = setmetatable(PetBase.new(session, info), Boss)
	self._traps = {}
	self:Init()
	return self :: any
end

-- The boss binds its own keyed pool (a fresh copy) so each boss can later diverge.
function Boss.Init(self: Boss)
	self._pool = table.clone(PetAttacks.getBoss(self.petName).pool)
	self._attackIndex = 1
end

-- Runs the boss's turn: the current pool ability, then advance the rotation. The
-- ability callback does the maths (targets, damage, effects) and the pacing.
function Boss.Attack(self: Boss, session: any)
	local attack = self._pool[self._attackIndex]
	self._attackIndex = (self._attackIndex % #self._pool) + 1
	attack(self, session)
end

function Boss.AddTrap(self: Boss, trap: any)
	table.insert(self._traps, trap)
end

--[=[
	Consumes pending traps at the start of the boss turn (stub: the trap trigger —
	reflect / block — plugs in here).
]=]
function Boss.RunTraps(self: Boss)
	self:_runTraps()
end

function Boss._runTraps(self: Boss)
	for index = #self._traps, 1, -1 do
		-- stub: trap trigger (reflect / block) plugs in here
		table.remove(self._traps, index)
	end
end

return Boss
