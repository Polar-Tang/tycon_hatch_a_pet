local ReplicatedSorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StateMachine = require(ReplicatedSorage.StateMachine)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.utils.NpcFighterTypes)

local State = StateMachine.State

local Dead = State.new("Dead")

function Dead:OnEnter(data: NpcFighterTypes.bossStateCtx)
	-- reset the timers
	data.lastTriggerTime = 0
	data.timer = 0

	data.DeadController:CreateWhirpol()
end

function Dead:OnHeartbeat(data, deltatime)
	data.timer += deltatime

	if data.timer - data.lastTriggerTime >= 1 then
		data.lastTriggerTime = data.timer

		data.DeadController:DestroyNPC()
	end
end

return Dead
