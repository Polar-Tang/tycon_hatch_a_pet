local ReplicatedSorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateMachine = require(ReplicatedSorage.StateMachine)

local State = StateMachine.State

local ourTransitions = ReplicatedStorage.Nevermore.Custom.npc.src.Client.NPC

local Eat = State.new("Eat")

-- Transitions

Eat.Transitions = {
	require(ourTransitions.Transitions.FinnishEating),
}

function Eat:OnEnter(data)
	data.MovementController:Stop()
	data.eatingStartTime = data.timer
	data.EatController:LevelUp()
end

function Eat:OnLeave(data)
	data.lastEatTime = data.timer -- Reset the patrol timer
end
function Eat:OnHeartbeat(data, deltaTime)
	data.timer += deltaTime
end
return Eat
