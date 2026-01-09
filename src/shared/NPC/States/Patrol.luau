local ReplicatedSorage = game:GetService("ReplicatedStorage")

local StateMachine = require(ReplicatedSorage.StateMachine)

local State = StateMachine.State

local Patrol = State.new("Patrol")

Patrol.Transitions = {
	require(script.Parent.Parent.Transitions.FinnishPatrol),
	-- require(ReplicatedSorage.NPC.Transitions.StartEating),
}

function Patrol:OnEnter(data)
	--local moveTo: Tween?

	local goal: Vector3 = data.TargetingController:getRandomNearbyPosition(10)
	data.MovementController:MoveTo(goal)
end

function Patrol:OnHeartbeat(data, deltatime)
	data.timer += deltatime
	print(data.timer)
end

return Patrol
