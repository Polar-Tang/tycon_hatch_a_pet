local ReplicatedSorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local alert = require(StarterPlayer.StarterPlayerScripts.facade.alert)
local StateMachine = require(ReplicatedSorage.StateMachine)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)

local State = StateMachine.State

local Dead = State.new("Dead")

function Dead:OnEnter(data: NpcFighterTypes.bossStateCtx)
	-- reset the timers
	data.lastTriggerTime = 0
	data.timer = 0
	data.Humanoid:TakeDamage(100)
	data.pet:BreakJoints()
	alert.alert(data.pet.Name .. " have died!")
	-- A single pet dying just despawns its own rig; it no longer ends the fight. The
	-- session lives as long as one teammate (or the boss) is alive, and the SERVER
	-- decides when combat is over (boss dead / team wiped) and teleports the player out.
	task.delay(5, function()
		data.DeadController:DestroyNPC()
	end)
end

return Dead
