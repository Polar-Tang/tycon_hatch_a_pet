local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PetBonuses = require(ServerScriptService.Pets.Pet.PetBonuses)
local bonusBase = require(script.Parent.bonusBase)
local ValueObject = require(ReplicatedStorage.Nevermore.Quenty.valueobject.Shared.ValueObject)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)

local passiveBonus = setmetatable({}, bonusBase)
passiveBonus.__index = passiveBonus

export type passiveBonus = bonusBase.bonusBase & {
	new: (petValue: ValueObject.ValueObject<any>, petName: PetTypes.petNames) -> passiveBonus,
}

function passiveBonus.new(petValue, petName)
	local self = setmetatable(bonusBase.new(petValue, petName), passiveBonus)
	return self
end

function passiveBonus:setActiveBonus(income)
	PetBonuses[self.petName].bonus(income)
end

return passiveBonus