local ReplicatedSorage = game:GetService("ReplicatedStorage")
local StateMachine = require(ReplicatedSorage.StateMachine)

local State = StateMachine.State

local Idle = State.new("Idle")

Idle.Transitions = {
	require(script.Parent.Parent.Transitions.StartPatrol),
	-- require(ReplicatedSorage.NPC.Transitions.StartEating),
}

function Idle:OnEnter(data) end

function Idle:OnHeartbeat(data, deltatime)
	data.timer += deltatime
	print("idle", data.timer)
end
return Idle
