local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage.RemoteEvents
local Attacks: RemoteEvent = Events.Attacks

--local moveRoot = require(Helpers:WaitForChild("MoveRoot"))
local StateMachine = require(ReplicatedStorage.StateMachine)
local TweenService = game:GetService("TweenService")

local State = StateMachine.State

local Combat = State.new("PromptCombat")

Combat.Transitions = {
	require(script.Parent.Parent.Transition.Died),
}

function Combat:OnEnter(data)
	data.timer = 0
	data.lastTriggerTime = 0
	local npc = data.npc
	local hrp = npc:FindFirstChild("HumanoidRootPart")

	local petPosition = hrp.Position
	data.originalPos = petPosition

	data.enemyHRP = data.enemyModel:WaitForChild("HumanoidRootPart")
	local enemyXZ = Vector3.new(data.enemyHRP.Position.X, 0, data.enemyHRP.Position.Z)
	local lookAtCF = CFrame.lookAt(petPosition, enemyXZ)

	local tween: Tween = TweenService:Create(hrp, TweenInfo.new(0.5), { CFrame = lookAtCF })
	tween:Play()
end

function Combat:OnHeartbeat(data, deltatime)
	data.timer += deltatime
	local celerity = data.celerity
	--local celerity = 1.5
	if data.timer - data.lastTriggerTime >= celerity * 2 then
		data.lastTriggerTime = data.timer

		--[[
	EVERY BOSS is clooned from as a template from the client, totally required by the client, server only do validations from remotes events to confirm
		need to use healthListener or directly handle the damge in the client
]]

		print("npc data ", data)

		-- ask the server for damaga
		do
			print("-------------------------------------------------------")
			print("NPC name ", data.npc.Name)
			print("NPC  MaxHealth ", data.humanoid.MaxHealth)
			print("NPC element ", data.petElement)
			print("NPC  Celerity ", data.celerity)
			print("NPC  Strength ", data.dmgBaseBuff or data.dmgBase)
			print("NPC Health ", data.humanoid.Health)
			print("enemy maxHealth ", data.enemy.MaxHealth)
			print("-------------------------------------------------------")
		end

		-- TODO: How do i insert other service using
		data._animHandler:LoadAnimation(true, "Attack")
		-- TODO Fire server, server does some validations and do HumanoidTakeDamage
		local hitFx = function()
			Attacks:FireServer(data.player, data)
		end

		-- TODO: How do i insert other service using
		data._animHandler:OnSignal({
			callback = hitFx,
			animationName = "Attack",
			animationEventName = "Hit",
		})
	end
end
return Combat
