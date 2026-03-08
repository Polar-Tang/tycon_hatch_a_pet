local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatControllerClient =
	require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.CombatControllerClient)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.utils.NpcFighterTypes)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local StateMachine = require(ReplicatedStorage.StateMachine)

local StatesFolder = ReplicatedStorage.NPC.States
local PetFollower = {}
PetFollower.__index = PetFollower
PetFollower.ClassName = "PetFollower"

function PetFollower.new(char: Model, serviceBag)
	local self = setmetatable({}, PetFollower)

	self.char = char
	self.state = nil
	self._initialized = false
	self._players = {}
	self.serviceBag = serviceBag
	self.maid = Maid.new()

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
	return self
end

function PetFollower:Destroy()
	print("State machine cleaned")
	-- TODO: test this
	self.maid:DoCleaning()
	if self.state then
		self.state:Destroy()
	end
end
return PetFollower
