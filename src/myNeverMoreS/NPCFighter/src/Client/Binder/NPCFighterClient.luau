local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatControllerClient =
	require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.CombatControllerClient)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.utils.NpcFighterTypes)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local StateMachine = require(ReplicatedStorage.StateMachine)

local StatesFolder = ReplicatedStorage.NPC.States
local NPCFighterClient = {}
NPCFighterClient.__index = NPCFighterClient
NPCFighterClient.ClassName = "StateMachine"

function NPCFighterClient.new(char: Model, serviceBag)
	local self = setmetatable({}, NPCFighterClient)

	self.char = char
	self.state = nil
	self._initialized = false
	self._players = {}
	self.serviceBag = serviceBag
	self.maid = Maid.new()

	return self
end

-- this method is called on nearby players
function NPCFighterClient:Init(player, initData: NpcFighterTypes.petStats)
	-- the state machine is like the npc's brain

	local state = StateMachine.new(
		"Idle",
		StateMachine:LoadDirectory(StatesFolder),
		CombatControllerClient.setBossCtx(self.char, self.serviceBag, player, self.maid, initData)
	)
	self.state = state
	self._initialized = true
	return self
end

function NPCFighterClient:Destroy()
	print("State machine cleaned")
	-- TODO: test this
	self.maid:DoCleaning()
	if self.state then
		self.state:Destroy()
	end
end
return NPCFighterClient
