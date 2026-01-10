local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxStateMachine = require(ReplicatedStorage.StateMachine)

local Transition = RobloxStateMachine.Transition

local StartEating = Transition.new("Eat")

function StartEating:OnEnter(data)
	-- Track when we last entered Idle (or whichever state this transitions from)
end

function StartEating:OnDataChanged(data)
	local timeInIdle = data.timer - data.lastIdleTime

	if timeInIdle >= data.eat_interval then
		return true
	end
	return false
end

return StartEating
