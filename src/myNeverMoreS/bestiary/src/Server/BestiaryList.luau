local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetData = require(ReplicatedStorage.Pets.PetTypes)
local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
local PlayerBinder = require(ReplicatedStorage.Nevermore.Custom.playerBinder.src.Server.PlayerBinder)
local Rx = require(ReplicatedStorage.Nevermore.Quenty.rx.Shared.Rx)
local ValueObject = require(ReplicatedStorage.Nevermore.Quenty.valueobject.Shared.ValueObject)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local ScaleToLvl = require(ReplicatedStorage.utils.utils).ScaleToLvl

local BestiaryList = {}
-- PlayerQuestHandler.lua
BestiaryList.__index = BestiaryList
--local petRegistry = require(script.Parent.PetRegistry)

local function shallowCopy(t)
	local out = {}
	for k, v in pairs(t or {}) do
		out[k] = v
	end
	return out
end

export type BestiaryList = {
	-- ===== State =====
	pets: PetData.PetsDataStore,
	petClicked: string?,
	PetsValue: ValueObject.ValueObject<PetData.PetsDataStore>,
	-- ===== Core API =====

	listController: (self: BestiaryList, petId: string, controller: any) -> (),

	listNewPet: (self: BestiaryList, petId: string, data: PetData.PetData) -> PetData.PetsDataStore,

	spendPoint: (self: BestiaryList, petId: string, abillityName: string) -> PetData.PetsDataStore?,

	increaseXP: (self: BestiaryList, petId: string, newPetProg: number) -> PetData.PetData?,

	setPetClicked: (self: BestiaryList, petId: string) -> (),

	unsetPetClicked: (self: BestiaryList) -> (),

	getPetRarity: (self: BestiaryList, petId: string) -> PetTypes.rarity?,

	removePet: (self: BestiaryList, petId: string) -> (),

	-- ===== Internal Methods =====

	_levelUpPet: (self: BestiaryList, pet: PetData.PetData) -> PetData.PetData?,
	getPetStats: (self: BestiaryList, petId: string) -> PetData.petStats?,
	_ensureValidEat: (self: BestiaryList, petId: string) -> boolean,
	getPetModel: (self: BestiaryList, petId: string) -> PetData.PetData?,
}

function BestiaryList.new(pets: PetData.PetsDataStore)
	local self = setmetatable({}, BestiaryList)
	self.PetsValue = ValueObject.new(pets)

	self.pets = pets or {}

	return self
end

function BestiaryList:listController(petId: string, controller)
	self.pets[petId] = controller
end

function BestiaryList:listNewPet(petId: string, data: PetData.PetData)
	self.pets[petId] = data
	--print(self.pets, "self.pets ")
	self.PetsValue.Changed:Fire(self.pets)

	return self.pets
end

function BestiaryList.removePet(self: BestiaryList, petId: string)
	-- TODO: USE PET SERVICE TO REMOVE THE PET FROM WORKSPACE
	self.pets[petId] = nil
	self.PetsValue.Changed:Fire(self.pets)
end

function BestiaryList.getPetRarity(self: BestiaryList, petId: string): PetTypes.rarity?
	local pet = self.pets[petId]
	if not pet then
		return
	end
	print("pet ", pet.rarity)
	return pet.rarity
end

function BestiaryList.spendPoint(self: BestiaryList, petId: string, abillityName: string): PetData.PetsDataStore | nil
	local pet = self.pets[petId]
	if 0 >= pet.avaiblePoints then
		return
	end
	pet.avaiblePoints = pet.avaiblePoints - 1
	pet.petStats[abillityName] = pet.petStats[abillityName] + 1
	return self.pets
end

function BestiaryList._levelUpPet(self: BestiaryList, pet): PetData.PetData?
	if pet.petLvl >= 150 then
		return
	end
	pet.avaiblePoints += 1
	pet.petLvl += 1
	pet.petProg -= 100 -- carry over excess XP

	return pet
end

-- The state machine uses remote event, check the intervals between the eat time is the same that the state machine use
function BestiaryList:_ensureValidEat(petId: string): boolean
	local pet = table.clone(self.pets[petId])
	if not pet.startTrack then
		pet.lastEat = tick()
		pet.startTrack = true

		self.pets[petId] = pet
		return true
	end
	local puddingTime = tick() - pet.lastEat
	--print("last eat - now ", puddingTime)
	local petInformation = petData[pet.petName]
	-- substract by 1 just in case
	local isValidEat = puddingTime > (petInformation.eat_interval + petInformation.eat_duration - 1)
	if isValidEat then
		pet.lastEat = tick()
		self.pets[petId] = pet
	end

	return isValidEat
end

function BestiaryList:getPetStats(petId: string)
	return self.pets[petId].petStats
end

function BestiaryList.getPetModel(self: BestiaryList, petId: string): PetData.PetData?
	return workspace:WaitForChild(petId)
end

function BestiaryList.increaseXP(self: BestiaryList, petId: string, newPetProg): PetData.PetData?
	local pet = table.clone(self.pets[petId])
	local petModel = self:getPetModel(petId)
	--print(petModel)
	if pet.petLvl >= 150 then
		-- warn("max level reached")
		-- petModel:SetAttribute("Level", pet.petLvl)
		return
	end
	if not self:_ensureValidEat(petId) then
		--print("invalid interval")
		return
	end

	pet.petProg += newPetProg
	--print("pet ", pet)
	while pet.petProg >= 100 do
		self:_levelUpPet(pet)
	end
	--print("pet ", pet)

	self.pets[petId] = pet
	--print("self.pets[petId] ", self.pets[petId])
	ScaleToLvl(petModel, pet.petLvl)
	-- petModel:SetAttribute("Level", pet.petLvl)
	return pet
end

function BestiaryList:setPetClicked(petId: string)
	self.petClicked = petId
end

function BestiaryList:unsetPetClicked()
	self.petClicked = nil
end

-- function BestiaryList:listBuff(petId: string, item)
-- 	local pet = self.pets[petId]
-- 	if not pet then
-- 		return
-- 	end

-- 	local clone = table.clone(pet)
-- 	clone.buffs = shallowCopy(pet.buffs) or {}
-- 	clone.buffs[item.itemId] = item
-- 	----print("data.item ", item)
-- 	self.pets[petId] = clone
-- 	return self.pets
-- end

-- function BestiaryList:deleteBuff(petId: string, itemId: string)
-- 	local pet = self.pets[petId]
-- 	if not pet then
-- 		return
-- 	end

-- 	local clone = table.clone(pet)
-- 	clone.buffs = shallowCopy(pet.buffs) or {}
-- 	clone.buffs[itemId] = nil
-- 	self.pets[petId] = clone

-- 	return self.pets
-- end

--function BestiaryList:getMaxH(petId: string)
--	local pet = self.pets[petName]
--	return pet.petStats["stamina"]*32 +128

--end

return PlayerBinder.new(BestiaryList)
