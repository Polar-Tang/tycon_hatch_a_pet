local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--[[
    Income aggregate factory for per-player income value objects.
]]

local BestiaryList = require(ReplicatedStorage.Nevermore.Custom.bestiary.src.Server.BestiaryList)
local PetController = require(ReplicatedStorage.Nevermore.Custom.bestiary.src.Server.PetController)
local serverTypes = require(ServerScriptService.types.serverTypes)
local PlayerBinder = require(ReplicatedStorage.Nevermore.Custom.playerBinder.src.Server.PlayerBinder)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Observable = require(ReplicatedStorage.Nevermore.Quenty.rx.Shared.Observable)
local Rx = require(ReplicatedStorage.Nevermore.Quenty.rx.Shared.Rx)
local ValueObject = require(ReplicatedStorage.Nevermore.Quenty.valueobject.Shared.ValueObject)
local incomeUtils = require(ReplicatedStorage.utils.incomeUtils)

type ValueObject = ValueObject.ValueObject<number>

export type Income = {
	Xp: ValueObject,
	CoinsFactor: ValueObject,
	EggRNG: ValueObject,
	EggDurationFactor: ValueObject,
	StorageSlot: ValueObject,
	Haggling: ValueObject,
	KiblyFactor: ValueObject,
	Luck: ValueObject,

	pets: ValueObject.ValueObject<{}>,
	boosters: { boosterType: incomeUtils.boosterList },

	_maid: Maid.Maid,

	new: (self: Income) -> Income,
	Init: (self: Income, serviceBag: any) -> (),
}

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

		bestiaryList = bestiaryList,
		_maid = Maid.new(),
	}, Income)

	local isPetBoosterByTheMoment = function(petData)
		return petData.Petname == "Pig"
			or petData.Petname == "Elephant"
			or petData.Petname == "Giraffe"
			or petData.Petname == "Panda"
	end

	Rx.combineLatest(bestiaryList.PetsValue)
		:Pipe({
			Rx.where(isPetBoosterByTheMoment),
		})
		:Subscribe(function(newPets)
			print("new pets ", newPets)
		end)

		for _, petValue in pairs(bestiaryList.PetsValue) do
			print("isObservable", (petValue):isValueObject())
			self:_activeBonus(petValue)
		end
	-- -- Observe changes to the pets
	-- bestiaryList.PetsValue:Observe():Subscribe(function(newPets)
	-- 	local boosters = incomeUtils.mapPetsToBoosters(newPets)

	-- 	self.boosters = boosters
	-- 	self:_setCoinIncome(boosters["coinBooster"])
	-- end)

	return self
end

function Income._activeBonus(self: Income, petValue: ValueObject.ValueObject<PetController.PetController>)
	petValue
		:ObserveBrio(function(value)
			return value == nil
		end)
		:Subscribe(function()
			print("destroyed shit!")
			local petId = petValue:GetValue():getId()
			print("petId ", petId)
			self._maid[petId]:DoCleaning()
		end)

	petValue
		:ObserveBrio(function(value)
			return value ~= nil
		end)
		:Subscribe(function()
			print("re-run")
			local function GetRandTime()
				return math.random(60, 300) -- 1 between 5 minutes
			end
			local bonus
			bonus = function()
				print("do something")
				local t = GetRandTime()
				local bonus = task.delay(t, bonus)
				self._maid[petValue:GetValue():getId()] = bonus
			end
			-- init the recursive task
			local t = GetRandTime()
			self._maid[petValue:GetValue():getId()] = task.delay(t, bonus)
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
