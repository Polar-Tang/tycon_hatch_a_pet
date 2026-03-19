local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage.RemoteEvents
local Attacks: RemoteEvent = Events.Attacks

--local moveRoot = require(Helpers:WaitForChild("MoveRoot"))
local StateMachine = require(ReplicatedStorage.StateMachine)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)

local State = StateMachine.State

local Combat = State.new("Combat")

Combat.Transitions = {
	require(script.Parent.Parent.Transition.Died),
	require(script.Parent.Parent.Transition.Killing),
}

function Combat:OnEnter(data: NpcFighterTypes.bossStateCtx) end

function Combat:OnHeartbeat(data: NpcFighterTypes.bossStateCtx, deltatime: number)
	data.timer += deltatime

	if data.timer - data.lastTriggerTime >= 2 then
		data.lastTriggerTime = data.timer

		local attackData = table.clone(data)
		attackData.position = data.enemy_hrp.Position
		Attacks:FireServer(attackData)
	end
end
return Combat
