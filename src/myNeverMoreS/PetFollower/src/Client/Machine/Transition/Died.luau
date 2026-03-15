local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local RobloxStateMachine = require(ReplicatedStorage.StateMachine)

local Transition = RobloxStateMachine.Transition

local Died = Transition.new("Dead")

function Died:OnDataChanged(data: NpcFighterTypes.bossStateCtx)
	return data.Health.Value <= 0
end

return Died
