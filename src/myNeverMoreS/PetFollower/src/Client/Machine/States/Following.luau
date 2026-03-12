local ReplicatedSorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateMachine = require(ReplicatedSorage.StateMachine)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)

local State = StateMachine.State
local Following = State.new("Following")

function Following:OnEnter(data)
	self.timer = 0
	self.lastTime = 0
	self.PlayerLastPos = nil
	-- Disconnect old connections
	if data.movetoFinish then
		data.movetoFinish:Disconnect()
		data.movetoFinish = nil
	end
	--wait(1)
end

function Following:OnHeartbeat(data: NpcFighterTypes.petStateCtx, deltaTime)
	self.timer += deltaTime
	if self.timer - self.lastTime >= 1 then
		local timerPhto = self.timer
		self.lastTime = timerPhto

		local playerPos = data.TargetController:Update()
		if playerPos then
			data.TargetController:GetWaypoints(playerPos):Then(function(data): ...any
				print(data, " this is the path")
				data.MovementController:MoveTo(playerPos)
			end)
		end
		--local newHealth = data.model.Health.Value + math.round(data.MaxHealth*1/64)
		--healthChangeEvent:Fire(newHealth)
	end
end

return Following
