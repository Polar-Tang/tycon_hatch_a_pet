local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxStateMachine = require(ReplicatedStorage.StateMachine)

local Transition = RobloxStateMachine.Transition

local FinnishEating = Transition.new("Idle")

function FinnishEating:OnDataChanged(data)
	local timeEating = data.timer - data.eatingStartTime
	if timeEating >= data.eat_duration then
		return true
	end
	return false
end

return FinnishEating
