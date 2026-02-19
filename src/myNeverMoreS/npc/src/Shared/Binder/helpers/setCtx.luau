-- Utility setting the npc context
local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controllers = RS.NPC.Controllers
local TargetingController = require(Controllers.TargetController.TargetController)
local SoundController = require(Controllers.SoundController.SoundController)
local MovementController = require(Controllers.MovementController.MovementController)
local EatController = require(Controllers.EatController.EatController)
local animData = require(ReplicatedStorage.Animations.animationsData)
local LevelController = require(ReplicatedStorage.NPC.Controllers.LevelController.LevelController)
local PetAnimatorController = require(ReplicatedStorage.NPC.Controllers.PetAnimatorController.PetAnimatorController)
local BillboardService = require(ReplicatedStorage.NPC.Servicies.BillboardService.BillboardService)
local utils = require(ReplicatedStorage.utils.utils)
local petStats = require(script.Parent.petData)

-- EVENTS
local petClickedEvent = ReplicatedStorage.RemoteEvents.PetClicked

local function onDescendantAdded(descendant)
	-- Set collision group for any part descendant

	if descendant:IsA("BasePart") then
		descendant.CanCollide = true
		descendant.CollisionGroup = "Npcs"

		if descendant.Name == "Rootpart" then
			descendant.Anchored = true
		end
	end
end

local setUpAtt = function(parent, petInfo)
	local stats = petInfo.petStats
	parent:SetAttribute("Melee", utils.MeleeCalc(stats.Melee))
	parent:SetAttribute("Health", utils.HealthCalc(stats.Health))
	parent:SetAttribute("Stamina", stats.Stamina)
end

local function createProximityPrompt(parent)
	-- Create ProximityPrompt
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.MaxActivationDistance = 8
	proximityPrompt.ActionText = "See stats"
	proximityPrompt.ObjectText = parent:GetAttribute("petName")
	proximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
	proximityPrompt.Style = Enum.ProximityPromptStyle.Default
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Name = "See Stats"
	proximityPrompt.Parent = parent

	-- Handle triggered event
	proximityPrompt.Triggered:Connect(function(playerWhoTriggered)
		-- Fire to server with the pet/NPC that was interacted with
		petClickedEvent:FireServer(parent)
	end)
end

local setCollider = function(parent)
	for _, descendant in parent:GetDescendants() do
		if descendant:IsA("Model") then
			for _, descendant in parent:GetDescendants() do
				onDescendantAdded(descendant)
			end
		end
		onDescendantAdded(descendant)
	end
end

local getStats = function(parent, maid, isOwnerLocal)
	local root = parent:WaitForChild("Rootpart") -- CLIENT CANT SEE THE ROOTPART FOR A WHILE

	local current_pet_stats = petStats[parent:GetAttribute("petName")]
	-- global
	local petData = {} -- ctx for the controllers

	petData.animations = animData[parent:GetAttribute("petName")]
	petData.range = current_pet_stats.range
	petData.pet = parent
	petData.base = current_pet_stats.base
	petData.velocity = current_pet_stats.velocity
	petData.speed = current_pet_stats.speed
	petData.root = root
	petData.isOwnerLocal = isOwnerLocal
	petData.YOffset = current_pet_stats.YOffset
	-- global

	return petData
end

return function(parent, serviceBag: any, player, maid)
	local current_pet_stats = petStats[parent:GetAttribute("petName")]

	local player_owner = parent:WaitForChild("Owner").Value
	local isOwnerLocal = tostring(player_owner) == tostring(player.UserId)

	local petData = getStats(parent, maid, isOwnerLocal)
	setCollider(parent)

	if isOwnerLocal then
		createProximityPrompt(parent)

		-- TODO: pets_registry is a table of player.UserId = petData
		repeat
			task.wait()
		until _G["pets_registry"] and _G["pets_registry"][parent.Name]
		local petInfo = _G["pets_registry"][parent.Name] -- This will be need a better way

		local billboardService = BillboardService.new(parent, maid, petInfo)
		billboardService:resizes()
		petData.billboardService = billboardService
		setUpAtt(parent, petInfo, maid, current_pet_stats)
	end

	return {
		maid = maid,
		pet = parent,
		isOwnerLocal = isOwnerLocal,
		-- timers
		timer = 0,
		lastIdleTime = 0,
		lastTriggerTime = 0,
		lastEatTime = 0,
		lastPatrolTime = 0,
		-------------------
		patrolStartTime = 0,
		eatingStartTime = 0,
		---- Saves the last time an state where trigger, the we can know to trigger the state based in that substracction
		patrol_interval = current_pet_stats.patrol_interval,
		eat_interval = current_pet_stats.eat_interval,
		patrol_duration = current_pet_stats.patrol_duration,
		eat_duration = current_pet_stats.eat_duration,
		-------- Controlles --------
		SoundController = isOwnerLocal and SoundController.new(petData, serviceBag) or nil,
		LevelController = isOwnerLocal and LevelController.new(petData) or nil,
		EatController = EatController.new(petData, serviceBag, player),
		MovementController = MovementController.new(petData, serviceBag),
		TargetingController = TargetingController.new(petData, serviceBag),
		PetAnimatorController = PetAnimatorController.new(petData, serviceBag),
	}
end
