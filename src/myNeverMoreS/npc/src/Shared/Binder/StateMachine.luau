local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StateMachine = require(ReplicatedStorage.StateMachine)
local setCTX = require(script.Parent.helpers.setCtx)
local StatesFolder = ReplicatedStorage.NPC.States

local StateMachineBinder = {}
StateMachineBinder.ServiceName = "StateMachine"
StateMachineBinder.__index = StateMachineBinder

function StateMachineBinder.new(char: Model, serviceBag)
	local self = setmetatable({}, StateMachineBinder)
	local proxPrompt = char:FindFirstAncestorOfClass("ProximityPrompt")
	self.id = HttpService:GenerateGUID()
	if not proxPrompt then
		local new_prompt: ProximityPrompt = Instance.new("ProximityPrompt")
		new_prompt.ObjectText = self.id
		new_prompt.MaxActivationDistance = 80
		new_prompt.Enabled = true
		new_prompt.Style = Enum.ProximityPromptStyle.Custom
		new_prompt.Parent = char
	end
	char:AddTag(self.id)
	self.char = char
	self.state = nil
	self._initialized = false
	self._players = {}
	self.serviceBag = serviceBag
	print()
	return self
end

-- this method is called on nearby players
function StateMachineBinder:Init()
	-- the state machine is like the npc's brain

	local state = StateMachine.new("Idle", StateMachine:LoadDirectory(StatesFolder), setCTX(self.char, self.serviceBag))
	self.state = state
	self._initialized = true
	return self
end

function StateMachineBinder:Destroy()
	self.state:Destroy()
end
return StateMachineBinder
