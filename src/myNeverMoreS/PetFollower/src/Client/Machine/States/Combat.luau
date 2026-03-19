local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage.RemoteEvents
local Attacks: RemoteEvent = Events.Attacks

--local moveRoot = require(Helpers:WaitForChild("MoveRoot"))
local CombatControllerClient =
	require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.CombatControllerClient)
local StateMachine = require(ReplicatedStorage.StateMachine)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local BossCombatCon: BindableEvent = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.BossCombatCon

local State = StateMachine.State

local Combat = State.new("Combat")

Combat.Transitions = {
	require(script.Parent.Parent.Transition.Died),
	require(script.Parent.Parent.Transition.Killing),
}

function Combat:OnEnter(data: NpcFighterTypes.petStateCtx)
	local new_goal = data.TargetController:GetTo(data.enemy_hrp, data.pet:GetExtentsSize().X * 2)
	data.TargetController:CalculatePath(new_goal):Then(function(path): ...any
		data.MovementController:ForgotPath()
		data.MovementController:MoveTo(path):Then(function()
			data.MovementController:LookTo(data.enemy_hrp.Position)
			BossCombatCon:Fire({
				enemy = data.pet,
				enemy_hrp = data.hrp,
				enemy_health = CombatControllerClient.getHealth(data.player, "PlayerBoss"),
			})
			self.reached = true
		end)
	end)
end

function Combat:OnHeartbeat(data: NpcFighterTypes.bossStateCtx, deltatime: number)
	if not self.reached then
		return
	end
	data.timer += deltatime

	if data.timer - data.lastTriggerTime >= 2 then
		data.lastTriggerTime = data.timer
		local attackData = table.clone(data)
		attackData.position = data.enemy_hrp.Position
		Attacks:FireServer(attackData)
	end
end
return Combat
