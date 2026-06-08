--[=[
	@class PlayerPet

	A player's pet in the [Duel pets] fight. Extends [PetBase] with the special
	routing: when this pet casts its special, `ApplySpecial` dispatches by the
	attack's `kind` onto the right registry. Effects are STUBBED (text/structure
	only); the `apply` callback on the attack is the real plug-in surface.

	- "defensive" → registers a buff on THIS pet and bumps its own private
	  `_defense` (the defense that mitigates incoming damage in `Apply`).
	- "instant"   → resolves immediately at cast time.
	- "trap"      → registers a trap on the boss, consulted on the boss turn.
]=]

local PetBase = require(script.Parent.PetBase)
local PetAttacks = require(script.Parent.PetAttacks)

export type PlayerPet = PetBase.PetBase & {
	ApplySpecial: (self: PlayerPet, attack: PetAttacks.Attack) -> (),
}

local PlayerPet = setmetatable({}, PetBase)
PlayerPet.__index = PlayerPet

function PlayerPet.new(session: any, info: PetBase.FighterInfo): PlayerPet
	local self = setmetatable(PetBase.new(session, info), PlayerPet)
	return self :: any
end

--[=[
	Routes the pet's special by its `kind`. Effects stubbed; the registry entry
	is what later real logic reads.
]=]
function PlayerPet.ApplySpecial(self: PlayerPet, attack: PetAttacks.Attack)
	self:_applySpecial(attack)
end

function PlayerPet._applySpecial(self: PlayerPet, attack: PetAttacks.Attack)
	local kind = attack.kind or "instant"

	if kind == "defensive" then
		self:AddBuff({ kind = "defensive", attack = attack })
		-- stub: real damage-reduction value plugs in here (private to this pet)
		self._defense += 0
	elseif kind == "trap" then
		-- the boss owns the trap registry it consults on its turn
		self._session.boss:AddTrap({ caster = self, attack = attack })
	end
	-- instant resolves immediately; all numeric effects are stubbed for now

	if attack.apply then
		attack.apply(self._session, self)
	end
end

return PlayerPet
