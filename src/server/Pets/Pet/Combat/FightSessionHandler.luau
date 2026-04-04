local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local combatInstanceRegistryFolder = ReplicatedStorage.Pets.Fights

-- Local types
type PlayerPetInstance = {
	Health: IntValue,
	Id: StringValue,
}

type PlayerBossInstance = {
	Health: IntValue,
	Id: StringValue,
}

type FightSessionHandler = {
	_folderSession: Folder,
    _maid: Maid.Maid,

	PlayerPet: PlayerPetInstance,
	PlayerBoss: PlayerBossInstance,

	new: (player: Player, data: NpcFighterTypes.FightInfo) -> FightSessionHandler,
	GetHealth: (self: FightSessionHandler, nameInstance: string) -> IntValue?,
	Destroy: (self: FightSessionHandler) -> (),
}

local FightSessionHandler = {}
FightSessionHandler.__index = FightSessionHandler

function FightSessionHandler.new(player: Player): FightSessionHandler?
	local folder = FightSessionHandler._createFolder(player)
	if not folder then
		warn("Error creating folder")
        return nil
	end

	local self = setmetatable({
		_folderSession = folder,
        _maid = Maid.new()
	}, FightSessionHandler)


	return self
end

function FightSessionHandler._createFolder(player: Player): Folder?
	local instanceName = tostring(player.UserId)
	if combatInstanceRegistryFolder:FindFirstChild(instanceName) then
		print("player can be in a single instance at a single time")
		return nil
	end
	local newFolder = Instance.new("Folder", combatInstanceRegistryFolder)
	newFolder.Name = player.UserId
	return newFolder
end

function FightSessionHandler.Init(self: FightSessionHandler,player: Player, data: NpcFighterTypes.FightInfo)
	local playerRegistrer = Instance.new("StringValue", self._folderSession)
	playerRegistrer.Name = "PlayerId"
	playerRegistrer.Value = tostring(player.UserId)

	-- Create the player folder
	do
		local player_per = data.player_pet
		-- health values should live inside the session folder so clients can
		-- easily address them via CombatController.getPlayerSessionFolder
		local petPlayer = Instance.new("Folder", self._folderSession)
		petPlayer.Name = "PlayerPet"

		local petPlayerId = Instance.new("StringValue", petPlayer)
		petPlayerId.Value = player_per.petId
		petPlayerId.Name = "Id"

		local petPlayerHealth = Instance.new("IntValue", petPlayer)
		-- uses max health for rendering in the UI
		petPlayerHealth:SetAttribute("MaxHealth", data.player_pet.healthVal)
		petPlayerHealth.Value = player_per.healthVal
		petPlayerHealth.Name = "Health"        

		self.PlayerPet = {
			Health = petPlayerHealth,
			Id = petPlayerId,
		}
	end

	-- Create the player boss
	do
		local player_boss = data.player_boss
		local petBoss = Instance.new("Folder", self._folderSession)
		petBoss.Name = "PlayerBoss"

		local petBossId = Instance.new("StringValue", petBoss)
		petBossId.Value = player_boss.petId
		petBossId.Name = "Id"

		local petBossHealth = Instance.new("IntValue", petBoss)
		-- uses max health for rendering in the UI
		petBossHealth:SetAttribute("MaxHealth", data.player_boss.healthVal)
		petBossHealth.Value = player_boss.healthVal
		petBossHealth.Name = "Health"

        -- connect boss health
        self._maid:GiveTask(petBossHealth.Changed:Connect(function(a0: number)  
            if a0 >= 0 then 
                print("Reward")
                ReplicatedStorage.RemoteEvents.Notifier({
                    notification = ""
                })
            end
        end)) 

		self.PlayerBoss = {
			Health = petBossHealth,
			Id = petBossId,
		}
	end
end

function FightSessionHandler:GetHealth(nameInstance: NpcFighterTypes.healthBarId): IntValue?
	if typeof(nameInstance) ~= "string" then
		return nil
	end
	local target = self._folderSession:FindFirstChild(nameInstance)
	if not target then
		return nil
	end
	return target:FindFirstChild("Health")
end

function FightSessionHandler:Destroy()
	local playerId = self._folderSession:FindFirstChild("PlayerId")
	if playerId then
		game.ReplicatedStorage.RemoteEvents.BossRemoteEvent:FireClient(playerId.Value, { destroy = true })
	end
	self._folderSession:Destroy()
end

return FightSessionHandler