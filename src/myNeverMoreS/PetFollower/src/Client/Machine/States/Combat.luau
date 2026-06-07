local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Events = ReplicatedStorage.RemoteEvents
local Attacks: RemoteEvent = Events.Attacks
local CombatTurn: RemoteEvent = Events.CombatTurn

local alert = require(StarterPlayer.StarterPlayerScripts.facade.alert)
local CombatControllerClient =
	require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.CombatControllerClient)
local StateMachine = require(ReplicatedStorage.StateMachine)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local BossCombatCon: BindableEvent = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.BossCombatCon

-- Delay between starting the attack gesture and reporting the hit. There is no
-- "attack" animation with a hit marker yet, so we use a small fixed delay so the
-- health bar drops a beat after the swing starts.
local HIT_DELAY = 0.35

local State = StateMachine.State

local Combat = State.new("Combat")

Combat.Transitions = {
	require(script.Parent.Parent.Transition.Died),
	require(script.Parent.Parent.Transition.Killing),
}

-- Plays the attack gesture, announces specials, and confirms the hit (with the
-- target position so the server can render the damage number) once it lands.
-- The server decides every turn; the client only renders and confirms.
local function performTurn(data: NpcFighterTypes.petStateCtx, payload: NpcFighterTypes.CombatTurnData)
	if data.animationHandler then
		pcall(function()
			data.animationHandler:LoadAnimation(true, payload.animation)
		end)
	end

	if data.MovementController and data.enemy_hrp then
		data.MovementController:LookTo(data.enemy_hrp.Position)
	end

	-- specials have no VFX yet, so announce them with text
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

-- Subscribe to this fighter's turns. Filter by band so each pet only reacts to
-- its own attack events. Connection lives on the binder maid (data.maid).
local function armTurnListener(data: NpcFighterTypes.petStateCtx)
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

function Combat:OnEnter(data: NpcFighterTypes.petStateCtx)
	local new_goal =
		data.TargetController:GetTo(data.enemy_hrp, (data.pet:GetExtentsSize().X + data.enemy:GetExtentsSize().X) / 2)
	data.TargetController:CalculatePath(new_goal):Then(function(path): ...any
		data.MovementController:ForgotPath()
		data.MovementController:MoveTo(path):Then(function()
			data.MovementController:LookTo(data.enemy_hrp.Position)
			BossCombatCon:Fire({
				enemy = data.pet,
				enemy_hrp = data.hrp,
				enemy_health = CombatControllerClient.getHealth(data.player, data.band),
			})
		end)
	end)

	armTurnListener(data)
end

return Combat
