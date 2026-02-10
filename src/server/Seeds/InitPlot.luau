local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local FenceBoundsService = require(ReplicatedStorage.NPC.Servicies.FenceBoundsService)
local Env = require(ServerScriptService.Env)
local PetData = require(ServerScriptService.types.PetData)
local ds = DataStoreService:GetDataStore(Env.DB_URI)

return function(player: Player, playerPets: PetData.InitData)
	local plot = FenceBoundsService:GetAvailablePlot()
	FenceBoundsService:AssignPlot(plot, player)

	local playerData: PetData.InitData = ds:GetAsync("data_" .. player.UserId).pets

	for petId, petInfo in pairs(playerData) do
		-- TODO: Improve fenced bounce migrate its logic living in stateMachine/something to a service module
		local pet: Model = ServerStorage.Pets[petInfo.petName]:Clone()
		assert(pet.PrimaryPart, "model " .. pet.Name .. " has no primary part")
		pet:SetAttribute("petName", pet.Name)
		pet.Name = petId
		pet.PrimaryPart.Position = FenceBoundsService:GetRandPosition(plot)
		pet.Parent = workspace
		CollectionService:AddTag(pet, "NPC")
	end
end
