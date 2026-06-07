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

local alert = require(StarterPlayer.StarterPlayerScripts.facade.alert)
local clientUtils = require(StarterPlayer.StarterPlayerScripts.utils.clientUtils)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local MovementController =
	require(ReplicatedStorage.Nevermore.Custom.PetFollower.src.Client.Machine.Controllers.MovementController)
local TargetController =
	require(ReplicatedStorage.Nevermore.Custom.PetFollower.src.Client.Machine.Controllers.TargetController)
local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
local PetCombatCon: BindableEvent = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.PetCombatCon

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
		proximityPrompt.ObjectText = parent.Name
		proximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
		proximityPrompt.Style = Enum.ProximityPromptStyle.Default
		proximityPrompt.RequiresLineOfSight = false
		proximityPrompt.Name = "Fight"
		local hrp = parent.PrimaryPart or parent:WaitForChild("HumanoidRootPart")
		proximityPrompt.Parent = hrp

		-- Handle prompt trigger

		-- Handle triggered event
		return proximityPrompt.Triggered:Connect(function(playerWhoTriggered)
			-- Fire to server with the pet/NPC that was interacted with
			proximityPrompt.Enabled = false
			PetCombatCon:Fire({
				enemy = parent,
				enemy_hrp = hrp,
				enemy_health = CombatControllerClient.getHealth(playerWhoTriggered, "PlayerBoss"),
			})
			alert.alert("the fight is about to start!")
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
		controllerdataInint.band = band
		controllerdataInint.hrp = parent.PrimaryPart or parent:FindFirstChild("RootPart")
		controllerdataInint.player = player
		controllerdataInint.player_character = playerCharacter
		controllerdataInint.Health = CombatControllerClient.getHealth(player, band)
		local BinderProvider = _G.ServiceBag:GetService(_G.BinderProvider)
		local animationHandler = BinderProvider:Get(Constants.animationHandler)
		controllerdataInint.animationHandler = animationHandler:Get(parent)
		local petName = parent:GetAttribute("petName")
		if petData[petName] and petData[petName].animationRunSpeed then
			controllerdataInint.animationRunSpeed = petData[petName].animationRunSpeed
		end
		controllerdataInint.hrp = parent.PrimaryPart or parent:WaitForChild("HumanoidRootPart")
		controllerdataInint.player = player
		controllerdataInint.timer = 0
		controllerdataInint.lastTriggerTime = 0
		controllerdataInint.Humanoid = parent:FindFirstChildOfClass("Humanoid") or parent:WaitForChild("Humanoid")

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
		CollectionService:AddTag(parent, "bossAgainst" .. tostring(player.UserId))

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
		local data = table.clone(controllerdataInint)
		data.DeadController = DeadController.new(controllerdataInint, serviceBag) or nil
		-- Hand the controller to the binder maid so NPCBase:Destroy tears it down
		maid:GiveTask(data.DeadController)
		return data
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
		-- each follower addresses its own health value via its band ("PlayerPetN")
		local band = combatInitData.band or parent:GetAttribute(Constants.CombatBand) or "PlayerPet1"
		local controllerdataInint = setCOntroler(parent, serviceBag, player, maid, combatInitData, band)

		CollectionService:AddTag(parent, "petFollower" .. tostring(player.UserId))
		local data = table.clone(controllerdataInint)

		data.DeadController = DeadController.new(controllerdataInint, serviceBag) or nil
		data.TargetController = TargetController.new(controllerdataInint, serviceBag, player)
		data.MovementController = MovementController.new(controllerdataInint, serviceBag, player)

		-- Give every controller to the binder maid (NPCBase already :DoCleaning()s
		-- it when the pet model is removed), instead of a parallel maid with its
		-- own duplicate AncestryChanged connection.
		local controllers = {
			DeadController = data.DeadController,
			TargetController = data.TargetController,
			MovementController = data.MovementController,
		}
		for _, controller in controllers do
			maid:GiveTask(controller)
		end
		return data
	end
end

function CombatControllerClient.cleanupInstances()
	local userId = Players.LocalPlayer.UserId
	local petFollowers = CollectionService:GetTagged("petFollower" .. tostring(userId))
	for _, pet in ipairs(petFollowers) do
		pet:Destroy()
	end

	local bosses = CollectionService:GetTagged("bossAgainst" .. tostring(userId))
	for _, boss in ipairs(bosses) do
		boss:Destroy()
	end
end

-- Clones one player pet follower from its reference model in the workspace,
-- copies scale/attributes, stamps the band so the binder can address its health,
-- tags it for the PetFollower binder, and parks it near the player.
local function spawnPetFollower(petEntry: NpcFighterTypes.petStats, index: number, band: string)
	-- Get reference pet from workspace to copy attributes and scale
	local petToClone = workspace:FindFirstChild(petEntry.petId)
	if not petToClone then
		print("reference pet not found in workspace")
		return
	end

	local petTemplateModel = ReplicatedFirst.Pets:FindFirstChild(petToClone:GetAttribute("petName"))
	if not petTemplateModel then
		print("pet template not found in ReplicatedFirst.Pets")
		return
	end

	-- Clone the template
	local petTemplate = petTemplateModel:Clone()
	if not petTemplate then
		print("petTemplate not found")
		return
	end

	local MAX_SIZE_THRESHOLD = 20.0 -- studs, adjust as needed
	-- Apply the same scale factor from the reference pet
	local referenceScale = petToClone:GetScale()
	local currentSize = petToClone:GetExtentsSize()

	if currentSize.Magnitude > MAX_SIZE_THRESHOLD then
		warn(
			string.format(
				"PetSystem: Extents magnitude %.2f exceeds threshold %.2f, skipping ScaleTo",
				currentSize.Magnitude,
				MAX_SIZE_THRESHOLD
			)
		)
		local clampedScale = referenceScale * (MAX_SIZE_THRESHOLD / currentSize.Magnitude)
		petTemplate:ScaleTo(clampedScale)
	else
		petTemplate:ScaleTo(referenceScale)
	end

	local humanoid: Humanoid = petTemplate:WaitForChild("Humanoid")
	humanoid.WalkSpeed = 6

	local hrp = petTemplate.PrimaryPart
	hrp.Anchored = false
	-- Copy attributes from the reference pet
	do
		for attributeName, attributeValue in pairs(petToClone:GetAttributes()) do
			if attributeName == "AnimatorName" then
				continue
			end
			petTemplate:SetAttribute(attributeName, attributeValue)
		end
	end

	-- band lets the binder pick this follower's health value ("PlayerPetN")
	petTemplate:SetAttribute(Constants.CombatBand, band)

	petTemplate.Parent = workspace

	-- spread the team out laterally so they don't stack on one spot
	local nearPlayer = clientUtils.petGoal(Players.LocalPlayer.Character, 3 + (index - 1) * 2)
		+ Vector3.new(0, humanoid.HipHeight, 0)
	nearPlayer = CFrame.new(nearPlayer) * Players.LocalPlayer.Character.PrimaryPart.CFrame.Rotation
	petTemplate:PivotTo(nearPlayer)

	petTemplate:AddTag(Constants.PetFollower)
	petTemplate:AddTag(Constants.animationHandler)
end

-- Clone an instance of the boss, creates it in the clinet, tagged for the binder and call init on classAdded signal
-- Do the same with the player pet but using FindFIrstChild(petid):Clone()
function CombatControllerClient.createInstances(data: NpcFighterTypes.FightInfo)
	local bossName = data.player_boss.petId
	local bossFolder: Folder = ReplicatedFirst.Pets
	local bossTempla = bossFolder:FindFirstChild(bossName)
	if not bossTempla then
		print("Boss not found")
		return
	end

	--setup boss
	do
		local ourBoss = bossTempla:Clone()
		ourBoss.Parent = workspace
		local lower_name = string.lower(bossName)
		local tag_name = "boss_point_" .. lower_name
		local point_to_spawn_boss = workspace:WaitForChild(tag_name)
		ourBoss:PivotTo(point_to_spawn_boss.CFrame)

		ourBoss:AddTag(Constants.combatBet)
		-- ourBoss:AddTag(Constants.animationHandler)
	end

	-- Spawn every pet in the team. Each gets a "PlayerPetN" band attribute so the
	-- binder can address its own health value.
	for index, petEntry in ipairs(data.player_pets) do
		local band = "PlayerPet" .. index
		spawnPetFollower(petEntry, index, band)
	end
end

function CombatControllerClient.initFighters(data: NpcFighterTypes.FightInfo) end

function CombatControllerClient.getPlayerSessionFolder(player: Player)
	return combatInstanceRegistryFolder:WaitForChild(tostring(player.UserId))
end

function CombatControllerClient.getHealth(player: Player, nameInstance: NpcFighterTypes.healthBarId): IntValue?
	if not nameInstance or typeof(nameInstance) ~= "string" then
		warn("invalid name instance ", nameInstance)
		return nil
	end
	-- "PlayerBoss" or "PlayerPet1".."PlayerPet3"
	if not (nameInstance == "PlayerBoss" or string.match(nameInstance, "^PlayerPet%d+$")) then
		warn("invalid name instance name " .. nameInstance)
		return nil
	end
	return combatInstanceRegistryFolder
		:WaitForChild(tostring(player.UserId))
		:WaitForChild(nameInstance)
		:WaitForChild("Health")
end

return CombatControllerClient
