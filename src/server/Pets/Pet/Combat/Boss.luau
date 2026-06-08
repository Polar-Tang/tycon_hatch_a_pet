--[=[
	@class Boss

	The boss fighter in the [Duel pets] fight. Extends [PetBase] with the trap
	registry: pets that cast a "trap" special register it here (`AddTrap`), and
	the boss consults/consumes it at the start of its own turn (`RunTraps`).

	Targeting differs from a pet: the boss attacks the first living pet on the
	team rather than the boss itself. Trap effects are STUBBED (structure only).
]=]

local PetBase = require(script.Parent.PetBase)
local PetAttacks = require(script.Parent.PetAttacks)

export type Boss = PetBase.PetBase & {
	_traps: { any },
	AddTrap: (self: Boss, trap: any) -> (),
	RunTraps: (self: Boss) -> (),
}

local Boss = setmetatable({}, PetBase)
Boss.__index = Boss

function Boss.new(session: any, info: PetBase.FighterInfo): Boss
	local self = setmetatable(PetBase.new(session, info), Boss)
	self._traps = {}
	return self :: any
end

-- The boss draws from its own pool so it can later diverge from the pet pool.
function Boss.GetAttackSet(self: Boss): PetAttacks.PetAttackSet
	return PetAttacks.getBoss(self.petName)
end

-- The boss hits the first living pet on the team.
function Boss._resolveTargets(self: Boss, _attack: PetAttacks.Attack, _isSpecial: boolean): { PetBase.PetBase }
	local target = self._session:_firstAlivePet()
	if not target then
		return {}
	end
	return { target }
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
