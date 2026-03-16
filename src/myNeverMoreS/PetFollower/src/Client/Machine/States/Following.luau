local ReplicatedSorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateMachine = require(ReplicatedSorage.StateMachine)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)

local State = StateMachine.State
local Following = State.new("Following")

function Following:OnEnter(data) end

function Following:OnHeartbeat(data: NpcFighterTypes.petStateCtx, deltaTime)
	data.timer += deltaTime
	if data.timer - data.lastTriggerTime >= 1 then
		local timerPhto = data.timer
		data.lastTriggerTime = timerPhto

		local goalPos = data.TargetController:GetGoal()
		if goalPos then
			data.TargetController:CalculatePath(goalPos):Then(function(path: Path): ...any
				data.MovementController:ForgotPath()
				data.MovementController:MoveTo(path)
			end)
		end
	end
end

return Following
