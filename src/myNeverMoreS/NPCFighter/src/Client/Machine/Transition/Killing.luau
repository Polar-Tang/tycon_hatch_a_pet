local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local RobloxStateMachine = require(ReplicatedStorage.StateMachine)

local Transition = RobloxStateMachine.Transition

local Killing = Transition.new("Idle")

function Killing:OnDataChanged(data: NpcFighterTypes.bossStateCtx)
	print("data.enemy_health.Value ", data.enemy_health.Value)
	return data.enemy_health and data.enemy_health.Value <= 0
end

return Killing
