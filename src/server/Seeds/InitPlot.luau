local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local FenceBoundsService = require(ReplicatedStorage.NPC.Servicies.FenceBoundsService)
local utils = require(ReplicatedStorage.utils.utils)
local PetData = require(ServerScriptService.types.PetData)

return function(player: Player, playerPets: PetData.InitData)
	local plot = FenceBoundsService:GetAvailablePlot()

	if not plot then 
		player:Kick("This server is full (6/6).")
	end

	FenceBoundsService:AssignPlot(plot, player)

	for petId, petInfo in pairs(playerPets) do
		-- TODO: Improve fenced bounce migrate its logic living in stateMachine/something to a service module
		local pet: Model = ServerStorage.Pets[petInfo.petName]:Clone()
		assert(pet.PrimaryPart, "model " .. pet.Name .. " has no primary part")
		pet:SetAttribute("petName", pet.Name)

		local playerRegistry = Instance.new("StringValue", pet)
		playerRegistry.Value = tostring(player.UserId)
		playerRegistry.Name = "Owner"
		

		pet.Name = petId
		pet.PrimaryPart.Position = FenceBoundsService:GetRandPosition(plot)
		pet.Parent = workspace
		CollectionService:AddTag(pet, "NPC")
		CollectionService:AddTag(pet, "AnimationHandler")

		CollectionService:AddTag(pet, "plot_" .. plot:FindFirstChild("PlotId").Value)
		CollectionService:AddTag(pet, "pets_" .. player.UserId)
		utils.ScaleToLvl(pet, petInfo.petLvl)
	end
end
