local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxStateMachine = require(ReplicatedStorage.StateMachine)

local Transition = RobloxStateMachine.Transition

local StartEating = Transition.new("Eat")

function StartEating:OnEnter(data)
	-- Track when we last entered Idle (or whichever state this transitions from)
end

function StartEating:OnDataChanged(data)
	local timeSinceLastEat = data.timer - data.lastEatTime
	return timeSinceLastEat >= data.eat_interval
end

return StartEating
