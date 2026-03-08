local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.utils.NpcFighterTypes)
local combatInstanceRegistryFolder = ReplicatedStorage.Pets.Fights

local CombotCotroller = {}

CombotCotroller.createAFightSession = function(player: Player, data: NpcFighterTypes.combatInstanceData): Folder?
	local instanceName = tostring(player.UserId)
	if combatInstanceRegistryFolder:FindFirstChild(instanceName) then
		print("player can be in a single instance at a single time")
		return nil
	end
	local newFolder = Instance.new("Folder", combatInstanceRegistryFolder)
	newFolder.Name = player.UserId

	return newFolder
end

CombotCotroller.initFightSession = function(player: Player, Folder, data: NpcFighterTypes.FightInfo)
	local playerRegistrer = Instance.new("StringValue", Folder)
	playerRegistrer.Name = "PlayerId"
	playerRegistrer.Value = tostring(player.UserId)

	-- Create the player folder
	do
		local player_per = data.player_pet
		local petPlayer = Instance.new("Folder", combatInstanceRegistryFolder)
		petPlayer.Name = "PlayerPet"

		local petPlayerId = Instance.new("StringValue", petPlayer)
		petPlayerId.Value = player_per.petId
		petPlayerId.Name = "Id"

		local petPlayerHealth = Instance.new("IntValue", petPlayer)
		petPlayerHealth.Value = player_per.healthVal
		petPlayerHealth.Name = "Health"
	end

	-- Create the player boss
	do
		local player_boss = data.player_boss
		local petBoss = Instance.new("Folder", combatInstanceRegistryFolder)
		petBoss.Name = "PlayerBoss"

		local petBossId = Instance.new("StringValue", petBoss)
		petBossId.Value = player_boss.petId
		petBossId.Name = "Id"

		local petBossHealth = Instance.new("IntValue", petBoss)
		petBossHealth.Value = player_boss.healthVal
		petBossHealth.Name = "Health"
	end
end

CombotCotroller.getPlayerSessionFolder = function(player: Player)
	local id = tostring(player.UserId)
	return combatInstanceRegistryFolder:FindFirstChild(id)
end

return CombotCotroller
