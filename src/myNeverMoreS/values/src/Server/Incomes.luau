local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--[[
    Income aggregate factory for per-player income value objects.
]]

local PetBonuses = require(ServerScriptService.Pets.Pet.PetBonuses)
local serverTypes = require(ServerScriptService.types.serverTypes)
local PlayerBinder = require(ReplicatedStorage.Nevermore.Custom.playerBinder.src.Server.PlayerBinder)
local bonusBase = require(ReplicatedStorage.Nevermore.Custom.values.src.Server.bonuses.bonusBase)
local Brio = require(ReplicatedStorage.Nevermore.Quenty.brio.Shared.Brio)

local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local ValueObject = require(ReplicatedStorage.Nevermore.Quenty.valueobject.Shared.ValueObject)
local incomeUtils = require(ReplicatedStorage.utils.incomeUtils)
local utils = require(ReplicatedStorage.utils.utils)

type ValueObject = ValueObject.ValueObject<number>

type Income = serverTypes.Income

local Income = {}
Income.__index = Income

function Income.new(bestiaryList)
	local self = setmetatable({
		Xp = ValueObject.new(1),
		CoinsFactor = ValueObject.new(1),
		EggRNG = ValueObject.new(1),
		EggDurationFactor = ValueObject.new(1),
		StorageSlot = ValueObject.new(1),
		Haggling = ValueObject.new(1),
		KiblyFactor = ValueObject.new(1),
		Luck = ValueObject.new(1),
		ExtraCoinBoss = ValueObject.new(0),
		DoubledCoin = ValueObject.new(0),
		_slightlyIncreased = ValueObject.new(0),

		_bonuses = {},
		_maid = Maid.new(),
	}, Income)

	return self
end

local bonusesModule = {
	["active"] = require(ReplicatedStorage.Nevermore.Custom.values.src.Server.bonuses.activeBonus),
	["passive"] = require(ReplicatedStorage.Nevermore.Custom.values.src.Server.bonuses.passiveBonus),
}

function Income.Init(self, fakeServiceBag)
	self.bestiaryList = fakeServiceBag.bestiaryList
	self.inventory = fakeServiceBag.inventory --inventory.cash/80

	local isPetBoosterByTheMoment = function(petData)
		local filteredPets = {}
		for _, petInfo in pairs(petData) do
			-- stylua: ingore
			if
				petData.petName == "Pig"
				or petData.petName == "Elephant"
				or petData.petName == "Giraffe"
				or petData.petName == "Panda"
			then
				table.insert(filteredPets, petInfo)
			end
		end
		return filteredPets
	end

	-- This is probably wrong but it works
	--[[
		probably need to to use some kind of Brio/ValuObject wrapping the pets. Unpack that table in a Rx.CombineLatest and have come kind of predicate for each pet value
	]]
	self.bestiaryList.PetsValue:Observe():Subscribe(function(petsRegistry)
		for petId, petValue in pairs(petsRegistry) do
			local petBrio: Brio.Brio<serverTypes.PetData> = self.bestiaryList.PetObservables[petId]
			if not petBrio then
				continue
			end
			if not isPetBoosterByTheMoment(petValue) then
				continue
			end
			if not self._bonuses[petId] then
				local petName = petValue.petName
				local petBonuses = PetBonuses[petName]
				if petBonuses then
					local bonus: bonusBase.bonusBase = bonusesModule[petBonuses.bonusType].new(petBrio, petName)
					self._bonuses[petId] = bonus
					self._maid[petId] = Maid.new()
					self._maid[petId]:GiveTask(bonus)
					local died = petBrio:GetDiedSignal():Connect(function()
						self._maid[petId]:DoCleaning()
						if PetBonuses[petName] and PetBonuses[petName].destroy then
							PetBonuses[petName].destroy(self)
						end
					end)
					self._maid[petId]:GiveTask(died)
					bonus:setActiveBonus(self)
				end
			end
		end

		local boosters = incomeUtils.mapPetsToBoosters(petsRegistry)

		self.boosters = boosters
		self:_setCoinIncome(boosters["coinBooster"])
	end)
end

function Income._setCoinIncome(self: Income, boosters: incomeUtils.boosterList)
	if not boosters or not next(boosters) then
		self.CoinsFactor.Value = 1
	end
	local _, total = incomeUtils.totalBoost(boosters)
	self.CoinsFactor.Value = total
end

function Income.GetExtraCoins(self: Income, boosters: incomeUtils.boosterList)
	task.defer(function()
		self.ExtraCoinBoss.Value = 0
	end)
	return self.ExtraCoinBoss.Value
end

function Income.GetDoubleCoins(self: Income, boosters: incomeUtils.boosterList)
	task.defer(function()
		self.DoubledCoin.Value = 0
	end)
	if self.DoubledCoin.Value >= 0 then
		return false
	end
	return self.DoubledCoin.Value
end

function Income.GetEggFactor(self: Income)
	print("self.Luck.Value ", self.Luck.Value)
	return self.Luck.Value * self.EggRNG.Value
end

function Income._checkIncreases(self, input)
	local increasedInt = input
	if self._slightlyIncreased.Value > 0 then
		for i = 1, self._slightlyIncreased.Value do
			increasedInt += utils.getPercentage(increasedInt, 12.5)
		end
	end
	print(increasedInt, " increasedInt")
	return increasedInt
end

function Income.Destroy(self: Income)
	self._maid:DoCleaning()
end

return PlayerBinder.new(Income) :: serverTypes.PlayerBinder<Income>
