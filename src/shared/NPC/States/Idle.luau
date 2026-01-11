local ReplicatedSorage = game:GetService("ReplicatedStorage")
local StateMachine = require(ReplicatedSorage.StateMachine)

local State = StateMachine.State

local Idle = State.new("Idle")

Idle.Transitions = {
	require(script.Parent.Parent.Transitions.StartPatrol),
	require(ReplicatedSorage.NPC.Transitions.StartEating),
}

function Idle:OnInit(data)
	-- data.PetAnimatorController:Init()
end

function Idle:OnEnter(data)
	data.lastIdleTime = data.timer
end

function Idle:OnHeartbeat(data, deltatime)
	data.timer += deltatime
end

return Idle
