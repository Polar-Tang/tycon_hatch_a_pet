--[=[
	@class PlayerPet

	A player's pet in the [Duel pets] fight. Extends [PetBase] with nothing of its
	own yet — its behaviour is entirely in the ability callbacks bound by `Init` (see
	[PetAttacks]), so a pet's basic/special is data-driven per pet name. It stays a
	distinct type so the session can tell a player's fighters apart from the [Boss].
]=]

local PetBase = require(script.Parent.PetBase)

export type PlayerPet = PetBase.PetBase

local PlayerPet = setmetatable({}, PetBase)
PlayerPet.__index = PlayerPet

function PlayerPet.new(session: any, info: PetBase.FighterInfo): PlayerPet
	local self = setmetatable(PetBase.new(session, info), PlayerPet)
	self:Init()
	return self :: any
end

return PlayerPet
