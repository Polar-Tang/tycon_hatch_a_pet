local ReplicatedSorage = game:GetService("ReplicatedStorage")

local StateMachine = require(ReplicatedSorage.StateMachine)

local State = StateMachine.State

local Eat = State.new("Eat")

-- Transitions

Eat.Transitions = {
	require(ReplicatedSorage.NPC.Transitions.StartPatrol),
	require(ReplicatedSorage.NPC.Transitions.FinnishEating),
}

function Eat:OnEnter(data)
	data.MovementController:Stop()
	print("play eating animation")
	print("generate currency")
end

function Eat:OnHeartbeat(data, deltaTime)
	data.timer += deltaTime
end
return Eat
