local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PetData = require(ServerScriptService.types.PetData)
local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
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

function BestiaryList.new(pets: PetData.InitData)
	local self = setmetatable({}, BestiaryList)
	self.pets = pets or {}

	return self
end

function BestiaryList:listController(petId: string, controller)
	self.pets[petId] = controller
end

function BestiaryList:listNewPet(petId: string, data: PetData.PetData)
	self.pets[petId] = data
	return self.pets
end

function BestiaryList:died(petId: string, isLive: boolean)
	local pet = self.pets[petId]
	pet.isDeath = isLive
	pet.health = 0
	self.pets[petId] = pet
	return self.pets
end

function BestiaryList:registerHealth(petId: string, newH, maxH)
	local pet = self.pets[petId]

	pet.health = newH
	if maxH then
		pet.maxHealth = maxH
	end
	if newH <= 0 then
		self:died(petId, false)
		pet.health = 0
	end
	--print("pet ", pet)
	--print("petInfo ", pet)
	self.pets[petId] = pet
end

function BestiaryList:removeBuffH(petId: string)
	local pet = self.pets[petId]
	pet.maxHealth = nil
	self.pets[petId] = pet
	--print("self.pets ",self.pets)
end

function BestiaryList:spendPoint(petId: string, abillityName: string): PetData.InitData | nil
	local pet = self.pets[petId]
	if 0 >= pet.avaiblePoints then
		return
	end
	pet.avaiblePoints = pet.avaiblePoints - 1
	pet.petStats[abillityName] = pet.petStats[abillityName] + 1
	return self.pets
end

function BestiaryList:_levelUpPet(pet)
	if pet.petLvl >= 150 then
		warn("max level reached")
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
	print("last eat - now ", puddingTime)
	local petInformation = petData[pet.petName]
	-- substract by 1 just in case
	local isValidEat = puddingTime > (petInformation.eat_interval + petInformation.eat_duration - 1)
	if isValidEat then
		pet.lastEat = tick()
		self.pets[petId] = pet
	end

	return isValidEat
end

function BestiaryList:increaseXP(petId: string, newPetProg)
	local pet = table.clone(self.pets[petId])
	local petModel = workspace:FindFirstChild(petId)
	if pet.petLvl >= 150 then
		warn("max level reached")
		petModel:SetAttribute("Level", pet.petLvl)
		return
	end
	if not self:_ensureValidEat(petId) then
		print("invalid interval")
		return
	end

	pet.petProg += newPetProg

	while pet.petProg >= 100 do
		self:_levelUpPet(pet)
	end

	self.pets[petId] = pet
	petModel:SetAttribute("Level", pet.petLvl)
	return pet
end

function BestiaryList:setPetClicked(petId: string)
	self.petClicked = petId
end

function BestiaryList:unsetPetClicked()
	self.petClicked = nil
end

function BestiaryList:listBuff(petId: string, item)
	local pet = self.pets[petId]
	if not pet then
		return
	end

	local clone = table.clone(pet)
	clone.buffs = shallowCopy(pet.buffs) or {}
	clone.buffs[item.itemId] = item
	--print("data.item ", item)
	self.pets[petId] = clone
	return self.pets
end

function BestiaryList:deleteBuff(petId: string, itemId: string)
	local pet = self.pets[petId]
	if not pet then
		return
	end

	local clone = table.clone(pet)
	clone.buffs = shallowCopy(pet.buffs) or {}
	clone.buffs[itemId] = nil
	self.pets[petId] = clone

	return self.pets
end

--function BestiaryList:getMaxH(petId: string)
--	local pet = self.pets[petName]
--	return pet.petStats["stamina"]*32 +128

--end

local BestiaryListHandler = {}

BestiaryListHandler.__index = BestiaryListHandler

BestiaryListHandler._players = {}

type PlayerData = {
	player: Player,
	character: Model & { Humanoid: Humanoid, Health: NumberValue },
	pets: {},
}

function BestiaryListHandler:InitPlayer(player, pets)
	local handler = BestiaryList.new(pets)
	self._players[player.UserId] = handler
end

-- accept a player
-- Get the player handler
-- return the particular player handler
function BestiaryListHandler:GetHandler(player)
	return self._players[player.UserId]
end

-- accept a player
-- remove the player instance
-- return nil
function BestiaryListHandler:RemovePlayer(player)
	self._players[player.UserId] = nil
end

return BestiaryListHandler
