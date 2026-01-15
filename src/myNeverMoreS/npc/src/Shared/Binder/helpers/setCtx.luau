-- Utility setting the npc context
local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Controllers = RS.NPC.Controllers
local TargetingController = require(Controllers.TargetController.TargetController)
local SoundController = require(Controllers.SoundController.SoundController)
local MovementController = require(Controllers.MovementController.MovementController)
local CurrencyController = require(Controllers.CurrencyController.CurrencyController)
local animData = require(ReplicatedStorage.Animations.animationsData)
local PetAnimatorController = require(ReplicatedStorage.NPC.Controllers.PetAnimatorController.PetAnimatorController)
local petStats = require(ServerScriptService.Pets.petData)

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

return function(parent: Model, serviceBag: any, player)
	local current_pet_stats = petStats[parent.Name]

	local petData = {} -- ctx for the controllers

	petData.animations = animData[parent.Name]
	petData.range = current_pet_stats.range
	petData.pet = parent
	petData.base = current_pet_stats.base
	petData.velocity = current_pet_stats.velocity
	petData.speed = current_pet_stats.speed

	for _, descendant in parent:GetDescendants() do
		if descendant:IsA("Model") then
			for _, descendant in parent:GetDescendants() do
				onDescendantAdded(descendant)
			end
		end
		onDescendantAdded(descendant)
	end

	return {
		pet = parent,
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
		CurrencyController = CurrencyController.new(petData, serviceBag, player),
		SoundController = SoundController.new(petData, serviceBag),
		MovementController = MovementController.new(petData, serviceBag),
		TargetingController = TargetingController.new(petData, serviceBag),
		PetAnimatorController = PetAnimatorController.new(petData, serviceBag),
	}
end
