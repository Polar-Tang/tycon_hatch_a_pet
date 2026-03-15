local ReplicatedSorage = game:GetService("ReplicatedStorage")

local StateMachine = require(ReplicatedSorage.StateMachine)

local State = StateMachine.State

local Idle = State.new("Idle")

function Idle:OnEnter(data) end

function Idle:OnHeartbeat(data, deltatime)
	data.timer += deltatime
	--print("changing data.timer")

	if data.timer - data.lastTriggerTime >= 1 then
		data.lastTriggerTime = data.timer
	end
end
return Idle
