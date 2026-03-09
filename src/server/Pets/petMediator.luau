local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Egg = require(ServerScriptService.Pets.Egg.Egg)
local EggTypes = require(ServerScriptService.Pets.Egg.EggTypes)
local PetService = require(ServerScriptService.Pets.Pet.PetService)
local Registry = require(ServerScriptService.Pets.Registry.Registry)
local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)
local PlotService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.utils.NpcFighterTypes)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local PetTypesContract = require(ReplicatedStorage.Pets.PetTypesContract)
local Constants = require(ReplicatedStorage.utils.Constants)
local utils = require(ReplicatedStorage.utils.utils)
local remotes = ReplicatedStorage.RemoteEvents

local BuyEggRemote: RemoteEvent = remotes.BuyEggRemote

BuyEggRemote.OnServerEvent:Connect(function(player: Player, color: string)
	if typeof(color) ~= "string" then
		return
	end

	local our_egg_color = "blue" :: EggTypes.EggColor
	if EggTypes.isEggColor(color) then
		our_egg_color = color
	else
		return
	end

	-- ensure player has a plot
	local plot = PlotService.GetPlotByUserId(tostring(player.UserId))
	if not plot then
		warn("Player has no plot")
		return
	end

	-- optional: check currency here
	-- if not CurrencyService:CanAfford(player, color) then return end

	-- create egg domain object
	local egg = Egg.new(player, plot, our_egg_color, 60)

	-- random position inside plot
	local randPos = PlotService:GetRandPosition(plot)

	egg:CloneModel()
	egg:Spawn(randPos)
	egg:StartHatching()
end)

local function calculatePriceByStats(petStats: PetTypes.petStats, petRarity: PetTypes.rarity)
	local sum = 1
	for statName, petStat in pairs(petStats) do
		-- local stat = if petStat == 0 then 1 else petStat
		sum = sum + petStat
	end

	type rarityM = {
		[PetTypes.rarity]: number,
	}
	local rarirty_multiplier: rarityM = {
		["common"] = 1.0,
		["uncommon"] = 1.1,
		["rare"] = 1.2,
		["epic"] = 1.3,
		["legendary"] = 1.4,
	}

	-- local price = reduce * rarirty_multiplier[petRarity]
	local base = sum * 400
	-- todo: remove this if statement
	local price = base ^ (if rarirty_multiplier[petRarity] then rarirty_multiplier[petRarity] else 1.0)
	return price
end

ReplicatedStorage.RemoteEvents.PetSell.OnServerEvent:Connect(
	function(player: Player, petSellContract: PetTypesContract.PetSell)
		if not petSellContract then
			return
		end
		if not petSellContract.petData then
			return
		end

		local petLists = Registry:GetHandler(player)
		local petId = petSellContract.petData.petId
		local petStats = petLists:getPetStats(petId)
		if not petStats then
			warn(petSellContract.petData, " not found")
			return
		end

		local petRarity = petLists:getPetRarity(petId)

		local price = calculatePriceByStats(petStats, petRarity)
		petLists:removePet(petId)
		PetService.destroyPet(player, petId)

		local inventory = PlayerInventory:GetHandler(player)
		inventory:IncreaseMoney(price)
	end
)

ReplicatedStorage.RemoteEvents.NPCFighter.OnServerEvent:Connect(function(a0: Player, ...)
	local playerPet = CollectionService:GetTagged("FollowerPet_" .. a0.UserId)
	if not playerPet then
		return
	end

	-- Get the binder
	local playerPet: Model = playerPet.state.Data.model
	local petPlayerModule = require(playerPet:WaitForChild("PetState"))
	local PetPlayerState = petPlayerModule.state

	PetPlayerState:ChangeData("enemyHumanoid", npc:WaitForChild("Humanoid"))
	PetPlayerState:ChangeData("enemy", npc)
	PetPlayerState:ChangeState("Combat")

	local npcState = require(npc:WaitForChild("NPCState"))

	local petElement = PetPlayerState.Data.petElement
	local damageBase = PetPlayerState.Data.dmgBase
	local NPCLevel = npcState.Data.level
	print("pet state ", PetPlayerState)
	PetPlayerState:ChangeData("enemyElement", petElement)
	PetPlayerState:ChangeData("enemyLevel", NPCLevel)

	npcState:ChangeData("PetPlayerState", PetPlayerState)
	npcState:ChangeData("level", npc:GetAttribute("level"))
	npcState:ChangeData("enemyHH", PetPlayerState.Data.healthController)
	PetPlayerState:ChangeData("enemyModel", npc)

	local enemyElement = PetPlayerState.Data.petElement
	local damageMatchup = ElementalDamage(damageBase, petElement, enemyElement)
	npcState:ChangeData("dmgBase", damageMatchup)
	-- IDK where this is triggered but its triggered somewhere else
	--npcState:ChangeState("PromptCombat")
	local enemyDMG = ElementalDamage(damageBase, enemyElement, petElement)
	PetPlayerState:ChangeData("matchupDMG", enemyDMG)
end)

-- This is the event triggered on boss teleport, it confirms player can go to the instance, register it, teleport the player to the instance and tell the client to create all the npcs that just lives in the client
local CombatController = ServerScriptService.Pets.Pet.Combat.CombatController
local BossRemoteEvent = ReplicatedStorage.RemoteEvents.BossRemoteEvent
BossRemoteEvent.OnServerEvent:Connect(function(a0: Player, data: NpcFighterTypes.combatInstanceData)
	print("data ", data)
	local petId = data.petId
	local bossName = data.bossName

	local folderSession = CombatController.createAFightSession(a0, data)
	if not folderSession then
		return
	end

	local bestiaryHandler = Registry:GetHandler(a0)
	local pets_stats = bestiaryHandler:getPetStats(petId)

	do
		local petInformation = {
			healthVal = utils.HealthCalc(pets_stats.Health),
			meleeVal = utils.MeleeCalc(pets_stats.Melee),
			petId = petId,
		}
		local bossInformation = {
			healthVal = 500,
			meleeVal = 200,
			petId = bossName,
		}

		local fightInfo = {
			player_pet = petInformation,
			player_boss = bossInformation,
		}
		CombatController.initFightSession(a0, folderSession, fightInfo)
		BossRemoteEvent:FireClient(a0, fightInfo)
	end

	local point_name = Constants.teleportPointSuffix .. bossName
	local teleportpoint: { BasePart } = point_name

	CollectionService:GetTagged(teleportpoint)
	local character: Model = a0.Character or a0.CharacterAdded:Wait()
	character:PivotTo(teleportpoint[1].CFrame)
end)

-- This is the event that confirms the pét player can do the damage, all the health values should be instances that lives in the Replicated storage and the server handles it while the client only renders it
ReplicatedStorage.RemoteEvents.Attacks.OnServerEvent:Connect(function(a0: Player, ...) end)

return {}
