local ReplicatedSorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local alert = require(StarterPlayer.StarterPlayerScripts.facade.alert)
local StateMachine = require(ReplicatedSorage.StateMachine)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)

local State = StateMachine.State

local Dead = State.new("Dead")

function Dead:OnEnter(data: NpcFighterTypes.petStateCtx)
	-- reset the timers
	data.lastTriggerTime = 0
	data.timer = 0
	-- simulate deth to brak joints
	data.Humanoid:TakeDamage(100)
	data.pet:BreakJoints()

	-- The boss only despawns its own rig here; the SERVER detects the boss is dead,
	-- waits a short beat, then teleports the player back to their plot and tears the
	-- session down (see FightSessionHandler finish handling).
	task.delay(5, function()
		data.DeadController:DestroyNPC()
	end)
end
return Dead
