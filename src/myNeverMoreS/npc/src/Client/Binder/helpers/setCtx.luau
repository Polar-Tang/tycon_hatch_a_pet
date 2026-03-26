-- Utility setting the npc context
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local npcFolder = ReplicatedStorage.Nevermore.Custom.npc.src.Client.NPC
local Controllers = npcFolder.Controllers
local TargetController = require(Controllers.TargetController.TargetController)
local SoundController = require(Controllers.SoundController.SoundController)
local MovementController = require(Controllers.MovementController.MovementController)
local EatController = require(Controllers.EatController.EatController)
local animData = require(ReplicatedStorage.Animations.animationsData)
local PetAnimatorController = require(Controllers.PetAnimatorController.PetAnimatorController)
local BillboardService = require(npcFolder.Servicies.BillboardService.BillboardService)
local utils = require(ReplicatedStorage.utils.utils)
local petStats = require(script.Parent.petData)

-- EVENTS
local petClickedEvent = ReplicatedStorage.RemoteEvents.PetClicked

local setUpAtt = function(parent, petInfo)
	local stats = petInfo.petStats
	parent:SetAttribute("Melee", utils.MeleeCalc(stats.Melee))
	parent:SetAttribute("Health", utils.HealthCalc(stats.Health))
	parent:SetAttribute("Stamina", stats.Stamina)

	-- The server should do this
	--[[
		parent:GetAttributeChangedSignal("Level"):Connect(function(newValue)
			local thisValue = parent:GetAttribute("Level")
			ScaleToLvl(parent, thisValue)
		end)
	
	]]
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
	return proximityPrompt.Triggered:Connect(function(playerWhoTriggered)
		-- Fire to server with the pet/NPC that was interacted with
		petClickedEvent:FireServer(parent)
	end)
end

local getStats = function(parent, maid, isOwnerLocal)
	local root = parent:WaitForChild("HumanoidRootPart") -- CLIENT CANT SEE THE ROOTPART FOR A WHILE

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
	petData.calcYOffset = current_pet_stats.calcYOffset
	-- global

	return petData
end

return function(parent, serviceBag: any, player, maid)
	local current_pet_stats = petStats[parent:GetAttribute("petName")]

	local player_owner = parent:WaitForChild("Owner").Value
	local isOwnerLocal = tostring(player_owner) == tostring(player.UserId)

	local petData = getStats(parent, maid, isOwnerLocal)

	if isOwnerLocal then
		maid:GiveTask(createProximityPrompt(parent))

		-- TODO: pets_registry is a table of player.UserId = petData
		repeat
			task.wait()
		until _G["pets_registry"] and _G["pets_registry"][parent.Name]
		local petInfo = _G["pets_registry"][parent.Name]

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
		EatController = EatController.new(petData, serviceBag, player),
		MovementController = MovementController.new(petData, serviceBag),
		TargetController = TargetController.new(petData, serviceBag),
		PetAnimatorController = PetAnimatorController.new(petData, serviceBag),
	}
end
