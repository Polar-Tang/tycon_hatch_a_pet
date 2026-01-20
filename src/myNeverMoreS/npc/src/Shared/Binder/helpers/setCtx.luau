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

local function createClickDecteor(parent)
	-- Create ClickDetector
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 32 -- Adjust distance as needed
	clickDetector.Parent = parent
	
	-- Handle click event
	clickDetector.MouseClick:Connect(function(playerWhoClicked)
		-- Fire to server with the pet/NPC that was clicked
		petClickedEvent:FireServer(parent)
		
		-- Optional: Visual feedback
		print("Clicked NPC:", parent.Name)
	end)	
end

return function(parent: Model, serviceBag: any, player)
	local root = parent:WaitForChild("Rootpart") -- CLIENT CANT SEE THE ROOTPART FOR A WHILE
	local current_pet_stats = petStats[parent.Name]

	local petData = {} -- ctx for the controllers

	petData.animations = animData[parent.Name]
	petData.range = current_pet_stats.range
	petData.pet = parent
	petData.base = current_pet_stats.base
	petData.velocity = current_pet_stats.velocity
	petData.speed = current_pet_stats.speed
	petData.root = root 

	createClickDecteor(parent)

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
		EatController = EatController.new(petData, serviceBag, player),
		SoundController = SoundController.new(petData, serviceBag),
		MovementController = MovementController.new(petData, serviceBag),
		TargetingController = TargetingController.new(petData, serviceBag),
		PetAnimatorController = PetAnimatorController.new(petData, serviceBag),
		LevelController = LevelController.new(petData)
	}
end
