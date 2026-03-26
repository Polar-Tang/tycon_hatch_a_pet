local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxStateMachine = require(ReplicatedStorage.StateMachine)

local Transition = RobloxStateMachine.Transition

local FinishPatrol = Transition.new("Idle")

function FinishPatrol:OnDataChanged(data)
	local timePatrolling = data.timer - data.patrolStartTime
	if not data.patrol_duration then
		warn("Partol duration wasn't calculated")
		return
	end
	if timePatrolling >= data.patrol_duration then
		return true
	end
	return false
end

return FinishPatrol
