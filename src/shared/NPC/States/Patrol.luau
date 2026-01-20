local ReplicatedSorage = game:GetService("ReplicatedStorage")

local StateMachine = require(ReplicatedSorage.StateMachine)

local State = StateMachine.State

local Patrol = State.new("Patrol")

Patrol.Transitions = {
	require(script.Parent.Parent.Transitions.FinnishPatrol),
}

function Patrol:OnEnter(data)
	data.EatController:StopAnim()

	data.patrolStartTime = data.timer
	local goal: Vector3 = data.TargetingController:getRandomNearbyPosition(50)
	data.patrol_duration = data.MovementController:MoveTo(goal) +1
end

function Patrol:OnLeave(data)
	data.lastPatrolTime = data.timer -- Reset the patrol timer
end

function Patrol:OnHeartbeat(data, deltaTime)
	data.timer += deltaTime
end

return Patrol
