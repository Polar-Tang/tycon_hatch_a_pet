local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local PetInformation = require(script.Parent.PetInformation)
local Registry = require(ServerScriptService.Pets.Registry.Registry)
local PlotService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
-- local testPart = require(ReplicatedStorage.utils.testPart)
local utils = require(ReplicatedStorage.utils.utils)

local PetService = {}
PetService.__index = PetService

function PetService.fromDataToWorld(Owner: Player, petInfo: PetTypes.PetData, position: Vector3?)
	local userId = tostring(Owner.UserId)
	local pet: Model = ServerStorage.Pets[petInfo.petName]:Clone()
	assert(pet.PrimaryPart, "model " .. pet.Name .. " has no primary part")
	pet:SetAttribute("petName", pet.Name)

	local playerRegistry = Instance.new("StringValue", pet)
	playerRegistry.Value = userId
	playerRegistry.Name = "Owner"

	local plot = PlotService.GetPlotByUserId(userId)

	pet.Name = petInfo.petId

	-- pet.PrimaryPart.Position = position or PlotService:GetRandPosition(plot)
	local endPos = position or PlotService:GetRandPosition(plot)
	
	pet.Parent = workspace
	-- pet.PrimaryPart.Position = endPos
	if position then 
		local bottomY = pet.PrimaryPart.Position.Y - pet.PrimaryPart.Size.Y/2
		position= Vector3.new(position.X, bottomY, position.Z)
		
		-- testPart({Position = position})
		pet:PivotTo(CFrame.new(endPos))

	else
		pet:MoveTo(endPos)
	end

	CollectionService:AddTag(pet, "NPC")
	CollectionService:AddTag(pet, "AnimationHandler")

	CollectionService:AddTag(pet, "plot_" .. plot:FindFirstChild("PlotId").Value)
	CollectionService:AddTag(pet, "pets_" .. userId)
	utils.ScaleToLvl(pet, petInfo.petLvl)
end

function PetService.getPlayerPets(player: Player): {Model}
	local tag = "pets_" .. player.UserId
	return CollectionService:GetTagged(tag)
end

function PetService.fixPetYFromPLayer(player: Player, petName: string): Vector3
	local userId = tostring(player.UserId)

	local plot = PlotService.GetPlotByUserId(userId)

	return PetService.fixPetY(plot, petName)
end

function PetService.fixPetY(plot, petName): Vector3
	local pet: Model = ServerStorage.Pets[petName]
	assert(pet.PrimaryPart)
	local originalY = pet.PrimaryPart.Position.Y

	local randPos = PlotService:GetRandPosition(plot)
	local fixedPoint = Vector3.new(randPos.X, originalY, randPos.Z)
	return fixedPoint
end

function PetService.createPet(Owner: Player, maybePetName: string, position: Vector3?)
	local tPetName = function(name)
		for _, petName in ipairs(PetTypes.allPetNames) do
			print("petName ", petName)
			if name ~= petName then
				continue
			else
				return true
			end
		end
		return false
	end

	local petName = "Fox" :: PetTypes.petNames
	if tPetName(maybePetName) then
		petName = maybePetName
	else
		warn(maybePetName, " is not a valide name")
		return
	end

	local bestiaryHandler = Registry:GetHandler(Owner)
	local newPet = table.clone(PetInformation[petName])
	assert(newPet, "Pet '" .. petName .. "' is not registered")
	local petId = HttpService:GenerateGUID(false)
	print(petId, "petId")
	newPet.petId = petId
	newPet.petStats = utils.GenerateRandStats(5)

	bestiaryHandler:listNewPet(petId, newPet)
	PetService.fromDataToWorld(Owner, newPet, position)
	print("FUCKING PETS ", bestiaryHandler.pets)
	local dataToReplica = {}
	dataToReplica.newPet = table.clone(newPet)
	ReplicatedStorage.RemoteEvents.PetNew:FireClient(Owner, dataToReplica)
end

function PetService.destroyPet(Owner: Player, petName: string)
	local petModel = workspace:FindFirstChild(petName)
	if not petModel then
		return
	end
	petModel:Destroy()
end

return PetService
