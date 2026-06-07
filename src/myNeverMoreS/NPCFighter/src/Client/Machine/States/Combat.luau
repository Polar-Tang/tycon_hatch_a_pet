local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Events = ReplicatedStorage.RemoteEvents
local Attacks: RemoteEvent = Events.Attacks
local CombatTurn: RemoteEvent = Events.CombatTurn

local alert = require(StarterPlayer.StarterPlayerScripts.facade.alert)
local StateMachine = require(ReplicatedStorage.StateMachine)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)

-- See PetFollower Combat state: no real attack animation/hit marker yet.
local HIT_DELAY = 0.35

local State = StateMachine.State

local Combat = State.new("Combat")

Combat.Transitions = {
	require(script.Parent.Parent.Transition.Died),
	require(script.Parent.Parent.Transition.Killing),
}

-- Plays the boss attack gesture (if it has an animation handler), announces
-- specials, then confirms the hit so the server applies the stored damage.
local function performTurn(data: NpcFighterTypes.bossStateCtx, payload: NpcFighterTypes.CombatTurnData)
	if data.animationHandler then
		pcall(function()
			data.animationHandler:LoadAnimation(true, payload.animation)
		end)
	end

	if payload.isSpecial and payload.text then
		alert.alert(payload.text)
	end

	task.delay(HIT_DELAY, function()
		if data.animationHandler then
			pcall(function()
				data.animationHandler:LoadAnimation(false, payload.animation)
			end)
		end
		local pos = data.enemy_hrp and data.enemy_hrp.Position
		Attacks:FireServer({ hitToken = payload.token, position = pos })
	end)
end

-- Subscribe to the boss's turns ("PlayerBoss" band); connection on the binder maid.
local function armTurnListener(data: NpcFighterTypes.bossStateCtx)
	if data._turnConn then
		return
	end
	data._turnConn = CombatTurn.OnClientEvent:Connect(function(payload: NpcFighterTypes.CombatTurnData)
		if payload.band ~= data.band then
			return
		end
		performTurn(data, payload)
	end)
	data.maid:GiveTask(data._turnConn)
end

function Combat:OnEnter(data: NpcFighterTypes.bossStateCtx)
	armTurnListener(data)
end

return Combat
