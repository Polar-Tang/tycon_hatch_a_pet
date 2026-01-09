local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxStateMachine = require(ReplicatedStorage.StateMachine)

local Transition = RobloxStateMachine.Transition

local StartPatrol = Transition.new("Patrol")

function StartPatrol:OnEnter(data) end
function StartPatrol:OnDataChanged(data)
	local timeMachine = data.timer
	print("timeMachine ", timeMachine)
	if math.round(timeMachine) ~= 0 and math.round(timeMachine) % data.patrol_interval == 0 then
		return true
	end
	return false
end

return StartPatrol
