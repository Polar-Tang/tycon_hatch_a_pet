local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PlotService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local OfflineRewards = require(ServerScriptService.Pets.MoneyGeneration.OfflineRewards)
local PetService = require(ServerScriptService.Pets.Pet.PetService)
local Registry = require(ReplicatedStorage.Nevermore.Custom.bestiary.src.Server.BestiaryList)
local MoneyCalculator = require(ServerScriptService.Player.Currency.MoneyCalculator)
-- local Items = require(ServerScriptService.Player.Inventory.Items)
local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)
local InitPlot = require(ServerScriptService.Seeds.InitPlot)
local initPets = require(ServerScriptService.Seeds.initPets)
local FenceBoundsService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local Incomes = require(ReplicatedStorage.Nevermore.Custom.values.src.Server.Incomes)

-- local initPets = require(ServerScriptService.Seeds.initPets)
local module = {}

local function onDescendantAdded(descendant)
	-- Set collision group for any part descendant

	if descendant:IsA("BasePart") then
		descendant.CollisionGroup = "Players"
	end
end

function module.PlayerAdded(player: Player, playerData)
	------print("playerData ", playerData)

	if not playerData then
		local petsInitialized = initPets(player)
		playerData = {
			inventory = {},
			cash = 0,
			pets = petsInitialized,
			--pets = {},
		}
	end

	local character = player.Character or player.CharacterAdded:Wait()
	for _, descendant in character:GetDescendants() do
		onDescendantAdded(descendant)
	end

	local totalMoney = playerData.cash or 0

	InitPlot(player, playerData.pets) -- creates the pet and set them in the plot

	-- start a registry for the player
	Registry:InitPlayer(player, playerData.pets)
	local bestiaryList = Registry:GetHandler(player)
	Incomes:InitPlayer(player, bestiaryList)

	PlayerInventory:InitPlayer(player, {
		cash = totalMoney,
		player = player,
	})
	local inventory = PlayerInventory:GetHandler(player)

	-- Offline rewards, needs pet registry
	if playerData.lastConnection then
		local offlineTime = os.time() - playerData.lastConnection

		local offlineMoney, _, _ = OfflineRewards.CalculatePerMinuteEarnings(player, offlineTime)
		if offlineMoney then
			totalMoney += offlineMoney
		end

		inventory:IncreaseMoney(offlineMoney)
		OfflineRewards.CalculateXP(player, offlineTime)
	end

	inventory:Init(function()
		local pets = bestiaryList.pets
		return MoneyCalculator.calculateEarnings(pets, 1)
	end)

	local PetNew = ReplicatedStorage.RemoteEvents.PetNew
	PetNew:FireClient(player, {
		allPets = playerData.pets,
	})

	character.DescendantAdded:Connect(onDescendantAdded)

	local spawnPoint = PlotService.GetSpawnPlot(player)
	if spawnPoint then
		character:PivotTo(spawnPoint)
	else
		warn("No spawn point found for player ", player.UserId)
		player:Kick("[Error] No plot. Please connect again.")
	end
end

function module.PlayerRemoving(player)
	local playerInventory = PlayerInventory:GetHandler(player)
	local bestiaryHandler = Registry:GetHandler(player)
	local newData = {}
	local plot = FenceBoundsService.GetPlotByUserId(player.UserId)
	FenceBoundsService:MarkOffline(plot)

	local playerPets = PetService.getPlayerPets(player)
	for _, pet in playerPets do
		PetService.destroyPet(player, pet.Name)
	end
	local allTheCash = playerInventory.cash
	-- --print("last monet ", playerInventory.cash, "all the cash earned ", allTheCash)
	newData.cash = allTheCash

	newData.pets = bestiaryHandler.pets

	newData.lastConnection = os.time()

	playerInventory:Destoy()
	--print("========== SAVING DATA ==========")
	--print("Player:", player.Name)
	--print("Timestamp being saved:", newData.lastConnection)
	--print("=================================")

	-- CurrencyController:RemovePlayer(player)
	return newData
end

return module
