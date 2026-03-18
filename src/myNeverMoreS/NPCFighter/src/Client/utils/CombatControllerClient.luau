-- Utility setting the npc context
-- The NPCFigther will starts totally in the client with fully isolation
--[[
	Phases
	1- Start combat PLACE
    server teleports the player and fires client
	-> client creates the npcFigther and its pet follower
	2- StartCombat
    After promptTrigger of boss it fires server
    server change the states to the pets
	
    This is the client setUp
	
	]]
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local clientUtils = require(StarterPlayer.StarterPlayerScripts.utils.clientUtils)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local MovementController =
	require(ReplicatedStorage.Nevermore.Custom.PetFollower.src.Client.Machine.Controllers.MovementController)
local TargetController =
	require(ReplicatedStorage.Nevermore.Custom.PetFollower.src.Client.Machine.Controllers.TargetController)
local CombatCon: BindableEvent = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.CombatCon

local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Constants = require(ReplicatedStorage.utils.Constants)

-- FOLDER
local combatInstanceRegistryFolder = ReplicatedStorage.Pets.Fights

-- CONTROLLERS
local Controllers = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.Machine.Controllers
local DeadController = require(Controllers.DeadController)

-- EVENTS

local CombatControllerClient = {}

do
	local function createProximityPrompt(parent)
		-- Create ProximityPrompt
		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.MaxActivationDistance = 8
		proximityPrompt.ActionText = "Start Fight"
		proximityPrompt.ObjectText = parent:GetAttribute("petName")
		proximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
		proximityPrompt.Style = Enum.ProximityPromptStyle.Default
		proximityPrompt.RequiresLineOfSight = false
		proximityPrompt.Name = "Fight"
		proximityPrompt.Parent = parent

		-- Handle triggered event
		return proximityPrompt.Triggered:Connect(function(playerWhoTriggered)
			-- Fire to server with the pet/NPC that was interacted with
			CombatCon:Fire()
		end)
	end

	local setCOntroler = function(
		parent: Model,
		serviceBag: any,
		player: Player,
		maid: Maid.Maid,
		combatInitData: NpcFighterTypes.petStats,
		band: NpcFighterTypes.healthBarId
	)
		local playerCharacter = player.Character or player.CharacterAdded:Wait()

		local controllerdataInint = table.clone(combatInitData)
		controllerdataInint.pet = parent
		controllerdataInint.maid = maid
		controllerdataInint.hrp = parent.PrimaryPart or parent:FindFirstChild("RootPart")
		controllerdataInint.player = player
		controllerdataInint.player_character = playerCharacter
		controllerdataInint.Health = CombatControllerClient.getHealth(player, band)
		local BinderProvider = _G.ServiceBag:GetService(_G.BinderProvider)
		local animationHandler = BinderProvider:Get(Constants.animationHandler)
		controllerdataInint.animationHandler = animationHandler:Get(parent)

		return controllerdataInint
	end

	local testMe = false

	function CombatControllerClient.setBossCtx(
		parent: Model,
		serviceBag: any,
		player: Player,
		maid: Maid.Maid,
		combatInitData: NpcFighterTypes.petStats
	)
		local bossName = combatInitData.petId

		local bossSpotName = Constants.spawnPoitSuffix .. string.lower(bossName)
		local bossSpot: BasePart = CollectionService:GetTagged(bossSpotName)[1]

		parent:PivotTo(bossSpot.CFrame)
		parent.Parent = workspace

		-- Check if the path of Nevermore.src.client is right for perfect isolation, if the print is true i will need to move the entire folder to a player scriupts
		do
			print(player.UserId)
			if player.UserId == -1 then
				testMe = true
			elseif player.UserId == -2 then
				print("Should i need to move this folder to PlayerScripts?? ", testMe)
			end
		end

		maid:GiveTask(createProximityPrompt(parent))

		-- TODO: Should we use a health billboard for the pets
		-- local billboardService = BillboardService.new(parent, maid, petInfo)
		-- billboardService:resizes()
		-- petData.billboardService = billboardService
		-- setUpAtt(parent, petInfo, maid, current_pet_stats)
		local controllerdataInint = setCOntroler(parent, serviceBag, player, maid, combatInitData, "PlayerBoss")
		return {
			maid = maid,
			pet = parent,

			-- timers
			timer = 0,
			lastTriggerTime = 0,
			-------------------

			-------- Controlles --------

			DeadController = DeadController.new(controllerdataInint, serviceBag) or nil,
		}
	end

	function CombatControllerClient.setPetCtx(
		parent: Model,
		serviceBag: any,
		player: Player,
		maid: Maid.Maid,
		combatInitData: NpcFighterTypes.petStats
	)
		-- Check if the path of Nevermore.src.client is right for perfect isolation, if the print is true i will need to move the entire folder to a player scriupts
		do
			if player.UserId == -1 then
				testMe = true
			elseif player.UserId == -2 then
				print("Should i need to move this folder to PlayerScripts?? ", testMe)
			end
		end

		-- TODO: may need billdboard serrvice or not
		-- local billboardService = BillboardService.new(parent, maid, petInfo)
		-- billboardService:resizes()
		-- petData.billboardService = billboardService
		-- setUpAtt(parent, petInfo, maid, current_pet_stats)
		local controllerdataInint = setCOntroler(parent, serviceBag, player, maid, combatInitData, "PlayerPet")
		return {
			maid = maid,
			pet = parent,

			-- timers
			timer = 0,
			lastTriggerTime = 0,
			-------------------

			-------- Controlles --------

			DeadController = DeadController.new(controllerdataInint, serviceBag) or nil,
			TargetController = TargetController.new(controllerdataInint, serviceBag, player),
			MovementController = MovementController.new(controllerdataInint, serviceBag, player),
		}
	end
end

-- Clone an instance of the boss, creates it in the clinet, tagged for the binder and call init on classAdded signal
-- Do the same with the player pet but using FindFIrstChild(petid):Clone()
function CombatControllerClient.createInstances(data: NpcFighterTypes.FightInfo)
	local bossName = data.player_boss.petId
	local bossFolder: Folder = ReplicatedFirst.PetsTemplates.Bosses
	local bossTempla = bossFolder:FindFirstChild(bossName)
	if not bossTempla then
		return
	end

	--setup boss
	do
		local ourBoss = bossTempla:Clone()
		local lower_name = string.lower(bossName)
		local tag_name = "boss_point_" .. lower_name
		local point_to_spawn_boss = workspace:WaitForChild(tag_name)
		ourBoss:PivotTo(point_to_spawn_boss.CFrame)

		ourBoss:AddTag(Constants.combatBet)
		-- ourBoss:AddTag(Constants.animationHandler)
	end

	do
		-- Get reference pet from workspace to copy attributes and scale
		local petToClone = workspace:FindFirstChild(data.player_pet.petId)
		if not petToClone then
			print("reference pet not found in workspace")
			return
		end

		-- Find template model in ReplicatedStorage.Pets.Models
		local modelsFolder = ReplicatedFirst.Pets
		if not modelsFolder then
			print("Pets.Models folder not found")
			return
		end

		local petTemplateModel = ReplicatedFirst.Pets:FindFirstChild(petToClone:GetAttribute("petName"))
		if not petTemplateModel then
			print("pet template not found in ReplicatedStorage.Pets.Models")
			return
		end

		-- Clone the template
		local petTemplate = petTemplateModel:Clone()
		if not petTemplate then
			print("petTemplate not found")
			return
		end

		-- Apply the same scale factor from the reference pet
		local referenceScale = petToClone:GetScale()
		-- petTemplate:ScaleTo(referenceScale)
		local hrp = petTemplate.PrimaryPart
		hrp.Anchored = false
		-- Copy attributes from the reference pet
		for attributeName, attributeValue in pairs(petToClone:GetAttributes()) do
			petTemplate:SetAttribute(attributeName, attributeValue)
		end

		petTemplate.Parent = workspace

		local nearPlayer = clientUtils.petGoal(Players.LocalPlayer.Character, 3)
		nearPlayer = CFrame.new(nearPlayer) * Players.LocalPlayer.Character.PrimaryPart.CFrame.Rotation
		petTemplate:PivotTo(nearPlayer)

		petTemplate:AddTag(Constants.PetFollower)
		petTemplate:AddTag(Constants.animationHandler)
	end
end

function CombatControllerClient.initFighters(data: NpcFighterTypes.FightInfo) end

function CombatControllerClient.getPlayerSessionFolder(player: Player)
	return combatInstanceRegistryFolder:WaitForChild(tostring(player.UserId))
end

function CombatControllerClient.getHealth(player: Player, nameInstance: NpcFighterTypes.healthBarId): IntValue?
	if not nameInstance or typeof(nameInstance) ~= "string" then
		print("invalid name instance ", nameInstance)
		return nil
	end
	if not (nameInstance == "PlayerBoss" or nameInstance == "PlayerPet") then
		print("invalid name instance name " .. nameInstance)
		return nil
	end
	return combatInstanceRegistryFolder
		:WaitForChild(tostring(player.UserId))
		:WaitForChild(nameInstance)
		:WaitForChild("Health")
end

return CombatControllerClient
