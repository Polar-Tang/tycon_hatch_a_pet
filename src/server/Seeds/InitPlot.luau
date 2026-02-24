local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PetService = require(ServerScriptService.Pets.Pet.PetService)
local FenceBoundsService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local PetData = require(ReplicatedStorage.Pets.PetTypes)

return function(player: Player, playerPets: PetData.PetsDataStore)
	local plot = FenceBoundsService:GetAvailablePlot()

	if not plot then
		player:Kick("This server is full (6/6).")
	end

	FenceBoundsService:AssignPlot(plot, player)

	for petId, petInfo in pairs(playerPets) do
		PetService.fromDataToWorld(player, petInfo)
	end
end
