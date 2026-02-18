local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PetService = require(ServerScriptService.Pets.Pet.PetService)
local FenceBoundsService = require(ReplicatedStorage.NPC.Servicies.FenceBoundsService)
local PetData = require(ServerScriptService.types.PetData)

return function(player: Player, playerPets: PetData.InitData)
	local plot = FenceBoundsService:GetAvailablePlot()

	if not plot then
		player:Kick("This server is full (6/6).")
	end

	FenceBoundsService:AssignPlot(plot, player)

	for petId, petInfo in pairs(playerPets) do
		if not petInfo.petId then
			petInfo.petId = petId
		end

		PetService.fromDataToWorld(player, petInfo)
	end
end
