local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PetData = require(ReplicatedStorage.Pets.PetTypes)
local PlayerBinder = require(ReplicatedStorage.Nevermore.Custom.playerBinder.src.Server.PlayerBinder)
local Brio = require(ReplicatedStorage.Nevermore.Quenty.brio.Shared.Brio)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local ValueObject = require(ReplicatedStorage.Nevermore.Quenty.valueobject.Shared.ValueObject)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local PetController = require(script.Parent.PetController)
local serverTypes = require(ServerScriptService.types.serverTypes)

local BestiaryList = {}
-- PlayerQuestHandler.lua
BestiaryList.__index = BestiaryList
--local petRegistry = require(script.Parent.PetRegistry)

local function _shallowCopy(t)
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

	_petControllers: { [string]: serverTypes.PetController },
	PetObservables: { Brio.Brio<PetData.PetsDataStore> },
	-- ===== Core API =====

	listController: (self: BestiaryList, petId: string, controller: any) -> (),

	listNewPet: (self: BestiaryList, petId: string, data: PetData.PetData) -> PetData.PetsDataStore,

	spendPoint: (self: BestiaryList, petId: string, abillityName: string) -> PetData.PetsDataStore?,

	increaseXP: (self: BestiaryList, petId: string, newPetProg: number) -> PetData.PetData?,

	setPetClicked: (self: BestiaryList, petId: string) -> (),

	unsetPetClicked: (self: BestiaryList) -> (),

	removePet: (self: BestiaryList, petId: string) -> (),

	-- ===== Internal Methods =====

	getPetStats: (self: BestiaryList, petId: string) -> PetData.petStats?,
	getPetModel: (self: BestiaryList, petId: string) -> PetData.PetData?,
}

function BestiaryList.new(pets: PetData.PetsDataStore)
	local self = setmetatable({}, BestiaryList)
	self.PetsValue = ValueObject.new(pets)

	self.pets = pets or {}
	self._petControllers = {}
	self.PetObservables = {}
	self._maid = Maid.new()

	return self
end

function BestiaryList:Init()
	for petId, pet in pairs(self.pets) do
		self:listController(petId, pet)
	end
end

function BestiaryList:listController(petId: string, data)
	if not self._petControllers[petId] then
		local controller = PetController.new(petId, data)
		self._petControllers[petId] = controller
		self._maid:Add(controller.ValueObject:GetDiedSignal():Connect(function()
			self._petControllers[petId] = nil
			self.PetObservables[petId] = nil
		end))
		self.PetObservables[petId] = controller.ValueObject
	end
end

function BestiaryList:listNewPet(petId: string, data: PetData.PetData)
	self:listController(petId, data)
	self.pets[petId] = data
	self.PetsValue.Changed:Fire(self.pets)

	return self.pets
end

function BestiaryList.removePet(self: BestiaryList, petId: string)
	-- TODO: USE PET SERVICE TO REMOVE THE PET FROM WORKSPACE
	self.pets[petId] = nil
	self._petControllers[petId]:Destroy()
	self._petControllers[petId] = nil
	self.PetsValue.Changed:Fire(self.pets)
end

function BestiaryList.spendPoint(self: BestiaryList, petId: string, abillityName: string, action: string?): PetData.PetsDataStore | nil
	local controller = self._petControllers[petId]
	if not controller then
		return nil
	end
	if controller:spendPoint(abillityName, action) then
		self.pets[petId] = controller:getData()
		self.PetsValue.Changed:Fire(self.pets)
		return self.pets
	end
	return nil
end

function BestiaryList.getPetModel(self: BestiaryList, petId: string): PetData.PetData?
	return workspace:WaitForChild(petId)
end

function BestiaryList.increaseXP(self: BestiaryList, petId: string, newPetProg): PetData.PetData?
	local controller = self._petControllers[petId]
	if not controller then
		return nil
	end
	local petModel = self:getPetModel(petId)
	local updated = controller:increaseXP(newPetProg, petModel)
	if updated then
		self.pets[petId] = updated
		self.PetsValue.Changed:Fire(self.pets)
		return updated
	end
	return nil
end

function BestiaryList.getPetStats(self: BestiaryList, petId: string): PetData.petStats?
	return self._petControllers[petId]:getStats()
end

function BestiaryList:setPetClicked(petId: string)
	self.petClicked = petId
end

function BestiaryList:unsetPetClicked()
	self.petClicked = nil
end

function BestiaryList:Destroy()
	self._maid:DoCleaning()
	setmetatable(self, nil)
end

return PlayerBinder.new(BestiaryList)
