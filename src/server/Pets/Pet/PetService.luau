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
	pet.PrimaryPart.Position = position or PlotService:GetRandPosition(plot)
	pet.Parent = workspace
	CollectionService:AddTag(pet, "NPC")
	CollectionService:AddTag(pet, "AnimationHandler")

	CollectionService:AddTag(pet, "plot_" .. plot:FindFirstChild("PlotId").Value)
	CollectionService:AddTag(pet, "pets_" .. userId)
	utils.ScaleToLvl(pet, petInfo.petLvl)
end

function PetService.createPet(Owner: Player, petName, position: Vector3?)
	assert(petName and typeof(petName) == "string")

	local bestiaryHandler = Registry:GetHandler(Owner)
	local newPet = PetInformation[petName]
	assert(newPet, "Pet '" .. petName .. "' is not registered")
	local petId = HttpService:GenerateGUID(false)
	newPet.petId = petId

	bestiaryHandler:listNewPet(petId, newPet)
	PetService.fromDataToWorld(Owner, newPet, position)

	local dataToReplica = {}
	dataToReplica.newPet = table.clone(newPet)
	ReplicatedStorage.RemoteEvents.PetNew:FireClient(Owner, dataToReplica)
end

return PetService
