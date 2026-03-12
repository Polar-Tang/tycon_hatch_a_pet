local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- use the real RemoteEvents folder rather than a custom Events folder
local Events = ReplicatedStorage:WaitForChild("RemoteEvents")
local Attacks: RemoteEvent = Events:WaitForChild("Attacks")

local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local Helpers = ServerScriptService:WaitForChild("Helpers")

local FadingText = require(StarterPlayer.StarterPlayerScripts.utils.FadingText)
local StateMachine = require(ReplicatedStorage.StateMachine)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)

local State = StateMachine.State
local Combat = State.new("Combat")

-- PLAYER PET
local function smoothCFrame(part, targetCFrame, duration)
	if not part then
		return
	end
	local tweenInfo = TweenInfo.new(duration or 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = { CFrame = targetCFrame }
	local tween = TweenService:Create(part, tweenInfo, goal)
	tween:Play()
	return tween
end

function Combat:OnEnter(data: NpcFighterTypes.petStateCtx)
	local rootPart = data.enemy:WaitForChild("HumanoidRootPart")
	data.enemy_hrp = rootPart

	local nerby_enemy = data.TargetController:getNearbyTo(data.enemy_hrp)
	-- Humanoid autorotate should look at this enemy
	data.MovementController:MoveTo(nerby_enemy)
end

function Combat:OnHeartbeat(data: NpcFighterTypes.petStateCtx, deltaTime)
	self.timer += deltaTime

	-- Uses hardcoded interval values for the moment
	if self.timer - self.lastTime >= 2 then
		self.lastTime = self.timer

		-- trigger attack animation and notify server when hit occurs
		--[[
			data._animHandler:LoadAnimation(true, "Attack")
			local hitFx = function()
				Attacks:FireServer(data.player, data)
			end
	
			data._animHandler:OnSignal({
				callback = hitFx,
				animationName = "Attack",
				animationEventName = "Hit",
			})
		]]
		Attacks:FireServer(Players.LocalPlayer, data)
		-- FadingText(data.pet.PrimaryPart, _G["pets_registry"] )
	end
end

return Combat
