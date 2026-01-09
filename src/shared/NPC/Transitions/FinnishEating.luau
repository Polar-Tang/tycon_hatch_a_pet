local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxStateMachine = require(ReplicatedStorage.StateMachine)

local Transition = RobloxStateMachine.Transition

local FinnishEating = Transition.new("Idle")

-- Tracks the patrol time
function FinnishEating:OnEnter(data)
	self.timer = 0
end

function FinnishEating:OnDataChanged(data)
	self.timer += data.timer
	if self.timer > data.eat_duration then
		return true
	end
	return false
end

return FinnishEating
