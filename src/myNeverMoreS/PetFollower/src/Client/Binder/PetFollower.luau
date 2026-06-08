local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCBase = require(ReplicatedStorage.Nevermore.Custom.NPCBase.src.Client.NPCBase)
local CombatControllerClient =
	require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.CombatControllerClient)
local healthBarListener = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.healthBarListener)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local StateMachine = require(ReplicatedStorage.StateMachine)

local CombatCon = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.PetCombatCon
local StatesFolder = ReplicatedStorage.Nevermore.Custom.PetFollower.src.Client.Machine.States
local PetFollower = setmetatable({}, NPCBase)
PetFollower.__index = PetFollower
PetFollower.ClassName = "PetFollower"

function PetFollower.new(char: Model, serviceBag)
	local self = setmetatable(NPCBase.new(char, serviceBag), PetFollower)

	return self
end

-- this method is called on nearby players
function PetFollower:Init(player, initData: NpcFighterTypes.petStats)
	-- the state machine is like the npc's brain

	local state = StateMachine.new(
		"Following",
		StateMachine:LoadDirectory(StatesFolder),
		CombatControllerClient.setPetCtx(self.char, self.serviceBag, player, self.maid, initData)
	)
	self.state = state
	self._initialized = true

	-- A single life connection. We don't notify the server here: the round loop
	-- must start only once the whole team has reached its slots, which the boss
	-- gates on (BossCombatCon). Here we just send this pet walking to its slot.
	self.combat_connection = CombatCon.Event:Connect(function(data)
		self:StartCombat(data.enemy, data.enemy_hrp, data.enemy_health)
		self.combat_connection:Disconnect()
	end)

	-- pet follower should listen to its own band's health bar ("PlayerPetN"), not the boss
	healthBarListener(player, self.char, initData.band or "PlayerPet1")

	return self
end

return PetFollower
