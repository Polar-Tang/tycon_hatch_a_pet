local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local StateMachine = require(ReplicatedStorage.StateMachine)
local setCTX = require(script.Parent.helpers.setCtx)
local StatesFolder = ReplicatedStorage.NPC.States
local StateMachineBinder = {}
StateMachineBinder.ServiceName = "StateMachine"
StateMachineBinder.__index = StateMachineBinder

function StateMachineBinder.new(char: Model, serviceBag)
	local self = setmetatable({}, StateMachineBinder)
	self.id = HttpService:GenerateGUID()
	
	char:AddTag(self.id)
	self.char = char
	self.state = nil
	self._initialized = false
	self._players = {}
	self.serviceBag = serviceBag
	self.maid = Maid.new()
	return self
end

-- this method is called on nearby players
function StateMachineBinder:Init(player)
	-- the state machine is like the npc's brain

	local state =
		StateMachine.new("Idle", StateMachine:LoadDirectory(StatesFolder), setCTX(self.char, self.serviceBag, player, self.maid))
	self.state = state
	self._initialized = true
	return self
end

function StateMachineBinder:Destroy()
	print("State machine cleaned")
	-- TODO: test this
	self.maid:DoCleaning()
	self.state:Destroy()
end
return StateMachineBinder
