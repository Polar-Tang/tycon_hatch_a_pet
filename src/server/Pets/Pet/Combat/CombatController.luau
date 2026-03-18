local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
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
		-- health values should live inside the session folder so clients can
		-- easily address them via CombatController.getPlayerSessionFolder
		local petPlayer = Instance.new("Folder", Folder)
		petPlayer.Name = "PlayerPet"

		local petPlayerId = Instance.new("StringValue", petPlayer)
		petPlayerId.Value = player_per.petId
		petPlayerId.Name = "Id"

		local petPlayerHealth = Instance.new("IntValue", petPlayer)
		-- uses max health for rendering in the UI
		petPlayerHealth:SetAttribute("MaxHealth", data.player_pet.healthVal)
		petPlayerHealth.Value = player_per.healthVal
		petPlayerHealth.Name = "Health"
	end

	-- Create the player boss
	do
		local player_boss = data.player_boss
		local petBoss = Instance.new("Folder", Folder)
		petBoss.Name = "PlayerBoss"

		local petBossId = Instance.new("StringValue", petBoss)
		petBossId.Value = player_boss.petId
		petBossId.Name = "Id"

		local petBossHealth = Instance.new("IntValue", petBoss)
		-- uses max health for rendering in the UI
		petBossHealth:SetAttribute("MaxHealth", data.player_boss.healthVal)
		petBossHealth.Value = player_boss.healthVal
		petBossHealth.Name = "Health"
	end
end

CombotCotroller.getPlayerSessionFolder = function(player: Player)
	local id = tostring(player.UserId)
	return combatInstanceRegistryFolder:FindFirstChild(id)
end

-- returns the IntValue that represents the health of either the
-- player pet or the boss.  `nameInstance` must be "PlayerPet" or
-- "PlayerBoss".
CombotCotroller.getHealth = function(player: Player, nameInstance: NpcFighterTypes.healthBarId)
	if typeof(nameInstance) ~= "string" then
		return nil
	end
	local folder = CombotCotroller.getPlayerSessionFolder(player)
	if not folder then
		return nil
	end
	local target = folder:FindFirstChild(nameInstance)
	if not target then
		return nil
	end
	return target:FindFirstChild("Health")
end

CombotCotroller.destroyFightSession = function(player: Player)
	local folder = CombotCotroller.getPlayerSessionFolder(player)
	if not folder then
		print("No active fight session found for player: " .. tostring(player.UserId))
		return
	end
	game.ReplicatedStorage.RemoteEvents.BossRemoteEvent:FireClient(player, { destroy = true })

	folder:Destroy()
end

return CombotCotroller
