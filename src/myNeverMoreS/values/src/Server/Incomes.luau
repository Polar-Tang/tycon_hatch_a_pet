local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--[[
    Income aggregate factory for per-player income value objects.
]]

local PetInformation = require(ServerScriptService.Pets.Pet.PetInformation)
local PetData = require(ServerScriptService.types.PetData)
local serverTypes = require(ServerScriptService.types.serverTypes)
local PlayerBinder = require(ReplicatedStorage.Nevermore.Custom.playerBinder.src.Server.PlayerBinder)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Rx = require(ReplicatedStorage.Nevermore.Quenty.rx.Shared.Rx)
local ValueObject = require(ReplicatedStorage.Nevermore.Quenty.valueobject.Shared.ValueObject)
local incomeUtils = require(ReplicatedStorage.utils.incomeUtils)

type ValueObject = ValueObject.ValueObject<number>

type Income = serverTypes.Income

local Income = {}
Income.__index = Income

function Income.new(bestiaryList, inventory)
	local self = setmetatable({
		Xp = ValueObject.new(1),
		CoinsFactor = ValueObject.new(1),
		EggRNG = ValueObject.new(1),
		EggDurationFactor = ValueObject.new(1),
		StorageSlot = ValueObject.new(1),
		Haggling = ValueObject.new(1),
		KiblyFactor = ValueObject.new(1),
		Luck = ValueObject.new(1),

		bestiaryList = bestiaryList,
		inventory = inventory, --inventory.cash/80
		_maid = Maid.new(),
	}, Income)

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
		probably need to tdo something more like thi
	]]
	bestiaryList.PetsValue:Observe():Subscribe(function()
		
		Rx.combineLatest(bestiaryList.PetObservables)
			:Pipe({
				Rx.where(function(petData): boolean
					print("petData ", petData)
					return isPetBoosterByTheMoment(petData)
				end),
			})
			:Subscribe(function(newPets)
				print("new pets ", newPets)
				for _, petValue in pairs(newPets) do
					self:_activeBonus(petValue)
				end
			end)
	end)

	-- -- Observe changes to the pets
	-- bestiaryList.PetsValue:Observe():Subscribe(function(newPets)
	-- 	local boosters = incomeUtils.mapPetsToBoosters(newPets)

	-- 	self.boosters = boosters
	-- 	self:_setCoinIncome(boosters["coinBooster"])
	-- end)

	return self
end

function Income._activeBonus(self: Income, petValue: ValueObject.ValueObject<PetData.PetData>)
	local value = petValue._value
	if not value then 
		return
	end
	local petId = value.petId

	if self._maid[petId] then
		return
	end
	

	petValue
		:ObserveBrio(function(value)
			return value ~= nil
		end)
		:Subscribe(function()
			local function GetRandTime()
				-- return math.random(60, 300) -- 1 between 5 minutes
				return math.random(5, 10)
			end
			local bonus
			bonus = function()
				if not petValue._value then 
					self._maid[petId] = task.spawn(function()end)
					return
				end
				local petName = petValue:GetValue().petName
				if PetInformation[petName].bonus then 
					PetInformation[petName].bonus(self)
				end
				local t = GetRandTime()
				local bonus = task.delay(t, bonus)
				-- petValue.maid 
				self._maid[petValue:GetValue().petId] = bonus
			end
			-- init the recursive task
			local t = GetRandTime()
			self._maid[petId] = task.delay(t, bonus)
		end)
end

function Income._setCoinIncome(self: Income, boosters: incomeUtils.boosterList)
	if not boosters or not next(boosters) then
		self.CoinsFactor.Value = 1
	end
	local _, total = incomeUtils.totalBoost(boosters)
	self.CoinsFactor.Value = total
end

return PlayerBinder.new(Income) :: serverTypes.PlayerBinder<Income>
