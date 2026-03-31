local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[[
    Income aggregate factory for per-player income value objects.
]]

local PlayerBinder = require(ReplicatedStorage.Nevermore.Custom.playerBinder.src.Server.PlayerBinder)
local Brio = require(ReplicatedStorage.Nevermore.Quenty.brio.Shared.Brio)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Rx = require(ReplicatedStorage.Nevermore.Quenty.rx.Shared.Rx)
local ValueObject = require(ReplicatedStorage.Nevermore.Quenty.valueobject.Shared.ValueObject)

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

	-- Observe changes to the pets
	bestiaryList.PetsValue:Observe():Subscribe(function(newPets)
		-- self.pets
		print("here we change tha values ", newPets)
		for _, pet in newPets do
			print("  -", pet.Name)
		end
	end)

	return self
end

return PlayerBinder.new(Income)
