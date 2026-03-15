local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCBase = require(ReplicatedStorage.Nevermore.Custom.NPCBase.src.Client.NPCBase)
local CombatControllerClient =
	require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.CombatControllerClient)
local healthBarListener = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.healthBarListener)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local StateMachine = require(ReplicatedStorage.StateMachine)

local CombatCon = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.CombatCon

local StatesFolder = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.Machine.States
local NPCFighterClient = setmetatable({}, NPCBase)
NPCFighterClient.__index = NPCFighterClient
NPCFighterClient.ClassName = "NPCFighterClient"

function NPCFighterClient.new(char: Model, serviceBag)
	local self = setmetatable(NPCBase.new(char, serviceBag), NPCFighterClient)

	return self
end

function NPCFighterClient.Init(self: NpcFighterTypes.NPCFighterClient, player, initData: NpcFighterTypes.petStats)
	-- the state machine is like the npc's brain

	local state = StateMachine.new(
		"Idle",
		StateMachine:LoadDirectory(StatesFolder),
		CombatControllerClient.setBossCtx(self.char, self.serviceBag, player, self.maid, initData)
	)
	self.state = state

	-- A single life connection
	self.combat_connection = CombatCon.Event:Connect(function(...)
		-- Notify the server the combat has started
		ReplicatedStorage.RemoteEvents.NPCFighter:FireServer(player, self.char)
		self:StartCombat()
		self.combat_connection:Disconnect()
	end)
	-- if the pet destroyed and the connection doesn't trigger it will clean anyway
	self.maid:GiveTask(self.combat_connection)

	healthBarListener(player, self.char, "PlayerBoss")

	self._initialized = true

	return self
end

return NPCFighterClient
