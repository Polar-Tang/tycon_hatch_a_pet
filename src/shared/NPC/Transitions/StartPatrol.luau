local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxStateMachine = require(ReplicatedStorage.StateMachine)

local Transition = RobloxStateMachine.Transition

local StartPatrol = Transition.new("Patrol")

function StartPatrol:OnDataChanged(data)
	local timeSinceLastPatrol = data.timer - data.lastPatrolTime
	if timeSinceLastPatrol >= data.patrol_interval then
		return true
	end
	return false
end

return StartPatrol
