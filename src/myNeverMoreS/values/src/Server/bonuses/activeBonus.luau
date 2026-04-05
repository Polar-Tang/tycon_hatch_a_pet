local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Brio = require(ReplicatedStorage.Nevermore.Quenty.brio.Shared.Brio)
local bonusBase = require(script.Parent.bonusBase)
local PetBonuses = require(ServerScriptService.Pets.Pet.PetBonuses)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)

local activeBonus = setmetatable({}, bonusBase)
activeBonus.__index = activeBonus

export type activeBonus = bonusBase.bonusBase & {
	new: (petValue: Brio.Brio<any>, petName: PetTypes.petNames) -> activeBonus,
}

function activeBonus.new(petValue, petName)
	local self = setmetatable(bonusBase.new(petValue, petName), activeBonus)
	return self
end

function activeBonus.setActiveBonus(self: activeBonus, income)
	if self.petValue:IsDead() then
		return
	end

	if not PetBonuses[self.petName] then
		return
	end

	local bonus
	bonus = function()
		if self.petValue:IsDead() then
			self._maid._cleanup = task.spawn(function() end)
			return
		end
		PetBonuses[self.petName].bonus(income)
		local t = PetBonuses[self.petName].GetRandTime()
		local bonusTask = task.delay(t, bonus)
		self._maid._cleanup = bonusTask
	end
	-- init the recursive task
	local t = PetBonuses[self.petName].GetRandTime()
	self._maid._cleanup = task.delay(t, bonus)
end

return activeBonus
