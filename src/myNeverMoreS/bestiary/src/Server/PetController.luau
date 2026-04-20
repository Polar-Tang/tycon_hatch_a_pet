local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local serverTypes = require(ServerScriptService.types.serverTypes)
local PetData = require(ReplicatedStorage.Pets.PetTypes)
local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
local Brio = require(ReplicatedStorage.Nevermore.Quenty.brio.Shared.Brio)
local ScaleToLvl = require(ReplicatedStorage.utils.utils).ScaleToLvl

local PetController = {}
PetController.__index = PetController

function PetController.new(petId: string, data: PetData.PetData): serverTypes.PetController
	local self = setmetatable({
		_petId = petId,
		_data = table.clone(data), -- clone to avoid modifying original
        ValueObject = Brio.new(data)
    }, PetController)
	return self
end


function PetController:spendPoint(abillityName: string, action: string?): boolean
	if not self._data.petStats[abillityName] then
		return false
	end

	if action == "subtract" then
		if self._data.petStats[abillityName] <= 0 then
			return false
		end
		self._data.petStats[abillityName] = self._data.petStats[abillityName] - 1
		self._data.avaiblePoints = self._data.avaiblePoints + 1
		return true
	end

	if self._data.avaiblePoints <= 0 then
		return false
	end

	self._data.avaiblePoints = self._data.avaiblePoints - 1
	self._data.petStats[abillityName] = self._data.petStats[abillityName] + 1
	return true
end

function PetController:increaseXP(newPetProg: number, petModel: Model?): PetData.PetData?
	if self._data.petLvl >= 150 then
		return nil
	end
	if not self:_ensureValidEat() then
		return nil
	end

	self._data.petProg = self._data.petProg + newPetProg
	while self._data.petProg >= 100 do
		self:_levelUpPet()
	end

	if petModel then
		ScaleToLvl(petModel, self._data.petLvl)
	end
	return self._data
end

function PetController:_levelUpPet()
	if self._data.petLvl >= 150 then
		return
	end
	self._data.avaiblePoints = self._data.avaiblePoints + 1
	self._data.petLvl = self._data.petLvl + 1
	self._data.petProg = self._data.petProg - 100
end

function PetController:_ensureValidEat(): boolean
	if not self._data.startTrack then
		self._data.lastEat = tick()
		self._data.startTrack = true
		return true
	end
	local puddingTime = tick() - self._data.lastEat
	local petInformation = petData[self._data.petName]
	local isValidEat = puddingTime > (petInformation.eat_interval + petInformation.eat_duration - 1)
	if isValidEat then
		self._data.lastEat = tick()
	end
	return isValidEat
end

function PetController:getStats(): PetData.petStats
	return self._data.petStats
end

function PetController:getData(): PetData.PetData
	return self._data
end

function PetController:getId(): string
	return self._petId
end

function PetController.Destroy(self: serverTypes.PetController)
	self.ValueObject:Kill()
    setmetatable(self, nil)
end

return PetController