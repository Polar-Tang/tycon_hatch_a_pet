local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxStateMachine = require(ReplicatedStorage.StateMachine)

local Transition = RobloxStateMachine.Transition

local FinnishPatrol = Transition.new("Idle")

-- Tracks the patrol time
function FinnishPatrol:OnEnter(data)
	self.timer = 0
end

function FinnishPatrol:OnDataChanged(data)
	self.timer += data.timer
	if self.timer > data.patrol_duration then
		data.MovementController:Stop()
		return true
	end
	return false
end

return FinnishPatrol
