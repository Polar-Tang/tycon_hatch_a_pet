local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local PetInformation = require(script.Parent.PetInformation)
local Registry = require(ServerScriptService.Pets.Registry.Registry)
local PlotService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local utils = require(ReplicatedStorage.utils.utils)
local PetData = require(ServerScriptService.types.PetData)

local PetService = {}
PetService.__index = PetService

function PetService.fromDataToWorld(Owner: Player, petInfo: PetData.PetData, position: Vector3?)
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

	pet.PrimaryPart.Position = position or PetService.fixPetY(plot, petInfo.petName)

	pet.Parent = workspace
	CollectionService:AddTag(pet, "NPC")
	CollectionService:AddTag(pet, "AnimationHandler")

	CollectionService:AddTag(pet, "plot_" .. plot:FindFirstChild("PlotId").Value)
	CollectionService:AddTag(pet, "pets_" .. userId)
	utils.ScaleToLvl(pet, petInfo.petLvl)
end

function PetService.fixPetYFromPLayer(player: Player, petName: string): Vector3
	local userId = tostring(player.UserId)

	local plot = PlotService.GetPlotByUserId(userId)

	return PetService.fixPetY(plot, petName)
end

function PetService.fixPetY(plot, petName): Vector3
	local pet: Model = ServerStorage.Pets[petName]:Clone()
	assert(pet.PrimaryPart)
	local originalY = pet.PrimaryPart.Position.Y

	local randPos = PlotService:GetRandPosition(plot)
	local fixedPoint = Vector3.new(randPos.X, originalY, randPos.Z)
	return fixedPoint
end

function PetService.createPet(Owner: Player, petName, position: Vector3?)
	assert(petName and typeof(petName) == "string")

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

return PetService
