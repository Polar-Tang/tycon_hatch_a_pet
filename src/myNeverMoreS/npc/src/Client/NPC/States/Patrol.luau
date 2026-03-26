local ReplicatedSorage = game:GetService("ReplicatedStorage")

local StateMachine = require(ReplicatedSorage.StateMachine)

local State = StateMachine.State

local Patrol = State.new("Patrol")

Patrol.Transitions = {
	require(script.Parent.Parent.Transitions.FinnishPatrol),
}

function Patrol:OnEnter(data)
	data.EatController:StopAnim()
	data.lastTriggerTime = data.timer

	local goalPos = data.TargetController:GetGoal()
	print("go to")
	if goalPos then
		data.TargetController:CalculatePath(goalPos):Then(function(path: Path): ...any
			data.MovementController:ForgotPath()
			-- TODO : calculate wayponts[#waypoints].Position using walkSpeed and self.hrp.Position as start position to calclulate
			data.patrol_duration = data.MovementController:MoveTo(path)
		end)
	end
end

function Patrol:OnLeave(data)
	data.lastPatrolTime = data.timer -- Reset the patrol timer
end

function Patrol:OnHeartbeat(data, deltaTime)
	data.timer += deltaTime
end

return Patrol
