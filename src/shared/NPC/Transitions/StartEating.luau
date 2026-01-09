local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxStateMachine = require(ReplicatedStorage.StateMachine)

local Transition = RobloxStateMachine.Transition

local StartEat = Transition.new("Eat")

function StartEat:OnEnter(data) end
function StartEat:OnDataChanged(data)
	local timeMachine = data.timer

	if math.round(timeMachine) ~= 0 and math.round(timeMachine) % data.eat_interval == 0 then
		return true
	end
	return false
end

return StartEat
