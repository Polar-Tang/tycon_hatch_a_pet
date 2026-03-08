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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.utils.NpcFighterTypes)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Constants = require(ReplicatedStorage.utils.Constants)

-- CONTROLLERS
local Controllers = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.Machine.Controllers
local DeadController = require(Controllers.DeadController)

-- EVENTS

local CombatControllerClient = {}

do
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
			ReplicatedStorage.RemoteEvents.NPCFighter:FireServer(parent)
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

	local setCOntroler = function(
		parent: Model,
		serviceBag: any,
		player: Player,
		maid: Maid.Maid,
		combatInitData: NpcFighterTypes.petStats
	)
		local playerCharacter = player.Character or player.CharacterAdded:Wait()

		local controllerdataInint = table.clone(combatInitData)
		controllerdataInint.pet = parent
		controllerdataInint.maid = maid
		controllerdataInint.hrp = parent.PrimaryPart or parent:FindFirstChild("RootPart")
		controllerdataInint.player = player
		controllerdataInint.player_character = playerCharacter
		local BinderProvider = _G.ServiceBag:GetService(_G.BinderProvider)
		local animationHandler = BinderProvider:Get(Constants.animationHandler)
		controllerdataInint.animationHandler = animationHandler:Get(parent)
		print("check if the pet is cloned with the same attributes")

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

		local bossSpotName = Constants.spawnPoitSuffix .. bossName
		local bossSpot: BasePart = CollectionService:GetTagged(bossSpotName)[1]

		parent:PivotTo(bossSpot.CFrame)
		parent.Parent = workspace

		setCollider(parent)

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

		-- TODO: may need billdboard serrvice or not
		-- local billboardService = BillboardService.new(parent, maid, petInfo)
		-- billboardService:resizes()
		-- petData.billboardService = billboardService
		-- setUpAtt(parent, petInfo, maid, current_pet_stats)
		local controllerdataInint = setCOntroler(parent, serviceBag, player, maid, combatInitData)
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
		local playerCharacter = player.Character or player.CharacterAdded:Wait()

		local nearPlayerPoint = playerCharacter.PrimaryPart.Position
			+ (playerCharacter.PrimaryPart.CFrame.RightVector * 3)
		local nearCF = CFrame.new(nearPlayerPoint)
		parent:PivotTo(nearCF)
		parent.Parent = workspace

		setCollider(parent)

		-- Check if the path of Nevermore.src.client is right for perfect isolation, if the print is true i will need to move the entire folder to a player scriupts
		do
			print(player.UserId)
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
		local controllerdataInint = setCOntroler(parent, serviceBag, player, maid, combatInitData)
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
end

-- Clone an instance of the boss, creates it in the clinet, tagged for the binder and call init on classAdded signal
-- Do the same with the player pet but using FindFIrstChild(petid):Clone()
function CombatControllerClient.createInstances(data: NpcFighterTypes.FightInfo)
	local bossName = data.player_boss.petId
	local bossFolder: Folder = ReplicatedStorage.Bosses
	local bossTempla = bossFolder:FindFirstChild(bossName)
	if not bossTempla then
		return
	end

	local ourBoss = bossTempla:Clone()
	ourBoss:AddTag(Constants.combatBet)
	-- ourBoss:AddTag(Constants.animationHandler)

	local petTemplate = workspace:FindFirstChild(data.player_pet.petId):Clone()
	if not petTemplate then
		print("petTemplate not found")
		return
	end
	petTemplate:AddTag(Constants.combatBet)
	petTemplate:AddTag(Constants.animationHandler)
end

function CombatControllerClient.initFighters(data: NpcFighterTypes.FightInfo) end

return CombatControllerClient
