local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PetBonuses = require(ServerScriptService.Pets.Pet.PetBonuses)
local Brio = require(ReplicatedStorage.Nevermore.Quenty.brio.Shared.Brio)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local ValueObject = require(ReplicatedStorage.Nevermore.Quenty.valueobject.Shared.ValueObject)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)

local bonusBase = {}
bonusBase.__index = bonusBase

export type bonusBase = {
	petValue: Brio.Brio<any>,
	petName: PetTypes.petNames,
	_maid: Maid.Maid,
	new: (petValue: ValueObject.ValueObject<any>, petName: PetTypes.petNames) -> bonusBase,
	setActiveBonus: (self: bonusBase, income: any) -> (),
	Destroy: (self: bonusBase) -> (),
}

function bonusBase.new(petValue: Brio.Brio<any>, petName: PetTypes.petNames): bonusBase
	local self = setmetatable({}, bonusBase)
	self.petValue = petValue
	self.petName = petName
	self._maid = Maid.new()
	return self
end

function bonusBase:setActiveBonus()
	-- To be overridden by children
end

function bonusBase:Destroy()
	self._maid:DoCleaning()
	if PetBonuses[self.petName] and PetBonuses[self.petName].destroy then
		PetBonuses[self.petName].destroy()
	end
end

return bonusBase
