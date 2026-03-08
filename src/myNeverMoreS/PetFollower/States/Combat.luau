local TweenService = game:GetService("TweenService")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ReplicatedSorage = game:GetService("ReplicatedStorage")

local Evenets = ReplicatedSorage:WaitForChild("Events")
local Attacks = Evenets:WaitForChild("Attacks")
local DamageListener = Evenets:WaitForChild("DamageListener")
local PetBarEvent = Evenets:WaitForChild("PetBarEvent")

local ServerScriptService = game:GetService("ServerScriptService")
local Helpers = ServerScriptService:WaitForChild("Helpers")
local LevelScaling = require(Helpers:WaitForChild("LevelScaling"))
local ElementalMutchup = require(Helpers:WaitForChild("ElementalMatchup"))
local createBolt = require(ReplicatedSorage:WaitForChild("NPC"):WaitForChild("NpcHelpers"):WaitForChild("CreateBolt"))

local StateMachine = require(ReplicatedSorage.RobloxStateMachine)
local FrostBolt = ReplicatedSorage:WaitForChild("Effects"):WaitForChild("FrostBolt")

local GetTargetCF = require(Helpers:WaitForChild("GetTargetCF"))
local State = StateMachine.State
local Combat = State.new("Combat")

Combat.Transitions = {
	require(script.Parent.Parent.Transition.Killing),
}
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

function Combat:OnEnter(data)
	self.timer = 0
	self.lastTime = 0
	local enemy: Model = data.enemy
	local human: Humanoid = data.humanoid
	local rootPart = data.rootPart
	local player = data.playerOwner
	local pet = data.model

	data.dmgBase = pet:GetAttribute("dmgBase")
	--print("data ", data)
	data.celerity = pet:GetAttribute("celerity")

	local enemyState = require(enemy:FindFirstChild("NPCState"))
	enemyState:ChangeData("enemy", human)

	enemyState:ChangeData("enemyElement", data.petElement)
	enemyState:ChangeData("player", player)
	enemyState:ChangeData("enemyModel", pet)
	enemyState:ChangeData("enemyHealth", data.health.Value)
	enemyState:ChangeData("enemyProgress", data.progress)
	--enemyState:ChangeData("npcPos", npc)
	enemyState:ChangeState("PromptCombat")
	data.enemyElement = enemy:GetAttribute("element")
	-- Enemy position
	local enemyHRP = enemy:WaitForChild("HumanoidRootPart")
	local enemyPos = enemyHRP.Position
	data.enemyPosition = enemyPos
	data.enemyHumanoid = enemy:WaitForChild("Humanoid")
	local enemyPosCustom = Vector3.new(enemyPos.X, enemyPos.Y, enemyPos.Z)
	local targetCF = GetTargetCF(enemyHRP, rootPart)
	data.firstPos = rootPart.Position
	--local midpoint = (enemyPos + data.firstPos) / 2

	--local tween = TweenService:Create(
	--	rootPart,
	--	TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	--	{ Position = midpoint }
	--)
	smoothCFrame(pet.PrimaryPart, CFrame.lookAt(pet.PrimaryPart.Position, data.enemyModel.PrimaryPart.Position), 0.5)
	--local testPart = Instance.new("Part")
	--testPart.Size = Vector3.new(1,1,1)
	--testPart.Position = midpoint
	--testPart.Parent = workspace
	--tween:Play()
end

function Combat:OnHeartbeat(data, deltaTime)
	self.timer += deltaTime
	local celerity = data.celerityBuff or data.celerity

	if self.timer - self.lastTime >= celerity * 2 then
		self.lastTime = self.timer
		local rootPart = data.rootPart
		local enemy: Humanoid = data.enemyHumanoid
		--76278127626965
		local hitAnimation: Animation = Instance.new("Animation")

		hitAnimation.AnimationId = data.animationsData.hit
		local animator: Animator = data.animator
		local animationTracker: AnimationTrack = animator:LoadAnimation(hitAnimation)
		animationTracker:AdjustSpeed(celerity)
		animationTracker:Play()
		data.currentAnimation = animationTracker

		-- create damage
		if not enemy and not enemy:IsA("Humanoid") then
			warn("NO ENEMY ")
			return
		end
		local enemyModel: Model = data.enemy
		local enemyLVL = data.enemy.level.Value

		local dmgBase = data.dmgBaseBuff or data.dmgBase
		local damage = math.round(LevelScaling(data.lvl, enemyLVL, dmgBase))
		local finalDamage = ElementalMutchup(damage, data.petElement, data.enemyElement)
		print("-------------------------------------------------------")
		print("Pet name ", data.model.Name)
		print("Pet element ", data.petElement)
		print("Damage dealt ", finalDamage)
		print("Celerity ", celerity)
		print("Strength ", dmgBase)
		print("Health ", data.health.Value)
		-- 14:02:57.719
		-- change the name event of the stupid frosty hit animation
		local markerConnection = animationTracker:GetMarkerReachedSignal("hit"):Connect(function()
			--print("data state ", data)
			--[[
			local theEnemy: Humanoid = data.enemyHumanoid
			local model: Model = data.model
			local attack: Part = data.attack
			local attack = FrostBolt:Clone()
			]]
			-- CREATE BOLT ATTACK
			local boltVelocity = celerity / 2
			Attacks:FireClient(data.playerOwner, {
				npc = data.model,
				celerity = data.celerity,
				enemyHRP = data.enemyModel.PrimaryPart,
				petElement = data.petElement,
			})
			-- ATTACK REACH ENEMY
			task.delay(boltVelocity, function()
				local character = data.enemyHumanoid.Parent
				local enemyHRP = character:WaitForChild("HumanoidRootPart")
				--print("attack reach the enemy ", enemyHRP)

				local damageData = { enemyPart = enemyHRP, damage = finalDamage }
				local player = data.playerOwner
				DamageListener:FireClient(player, damageData)
				local newH = enemy.Health - finalDamage
				enemy:TakeDamage(finalDamage)
				--
				local enemyMaxH = data.enemyHumanoid.MaxHealth
				--print("newH ", newH)
				local HealthbarUpdate = {
					type = "Update",
					petId = enemyModel.Name,
					model = enemyModel,
					level = enemyLVL,
					health = newH,
					percent = math.clamp(newH / enemyMaxH, 0, 1),
					element = data.enemyElement,
				}
				PetBarEvent:FireClient(player, HealthbarUpdate)
				--if pet  then

				--end
			end)
		end)
	end
end

return Combat
