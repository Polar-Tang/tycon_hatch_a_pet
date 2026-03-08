local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxStateMachine = require(ReplicatedStorage.StateMachine)

local Transition = RobloxStateMachine.Transition

local Died = Transition.new("Dead")

function Died:OnDataChanged(data)
	local humanoid = data.humanoid

	return humanoid.Health <= 0
end

return Died
