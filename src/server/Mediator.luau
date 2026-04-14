local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PlotService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local OfflineRewards = require(ServerScriptService.Pets.MoneyGeneration.OfflineRewards)
local PetService = require(ServerScriptService.Pets.Pet.PetService)
local Registry = require(ReplicatedStorage.Nevermore.Custom.bestiary.src.Server.BestiaryList)
local MoneyCalculator = require(ServerScriptService.Player.Currency.MoneyCalculator)
local Items = require(ServerScriptService.Player.Inventory.Items)
-- local Items = require(ServerScriptService.Player.Inventory.Items)
local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)
local InitPlot = require(ServerScriptService.Seeds.InitPlot)
local initPets = require(ServerScriptService.Seeds.initPets)
local FenceBoundsService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local Incomes = require(ReplicatedStorage.Nevermore.Custom.values.src.Server.Incomes)
local BinderProvider = require(ReplicatedStorage.Nevermore.Quenty.binder.Shared.BinderProvider)
local ServiceBag = require(ReplicatedStorage.Nevermore.Quenty.servicebag.Shared.ServiceBag)

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
			cash = 0,
			pets = petsInitialized,
			items = {
				["asd"] = {
					image = Items.speedCoil,
				},
			},
			--pets = {},
		}
	end

	local character = player.Character or player.CharacterAdded:Wait()
	for _, descendant in character:GetDescendants() do
		onDescendantAdded(descendant)
	end

	local totalMoney = playerData.cash or 0

	InitPlot(player, playerData.pets) -- creates the pet and set them in the plot

	-- instiatiate the player binders --
	local fakeServiceBag = {}
	Registry:InitPlayer(player, playerData.pets)
	local bestiaryList = Registry:GetHandler(player)
	fakeServiceBag["bestiaryList"] = bestiaryList

	PlayerInventory:InitPlayer(player, {
		cash = totalMoney,
		player = player,
		items = playerData.items,
	})
	local inventory = PlayerInventory:GetHandler(player)
	fakeServiceBag["inventory"] = inventory

	Incomes:InitPlayer(player, bestiaryList, inventory)
	local playerIncomes = Incomes:GetHandler(player)
	fakeServiceBag["playerIncomes"] = playerIncomes

	-- Offline rewards, needs pet registry
	if playerData.lastConnection then
		local offlineTime = os.time() - playerData.lastConnection
		local offlineMoney = OfflineRewards.GetOfflineRewards(player, offlineTime, totalMoney)
		inventory:IncreaseMoney(offlineMoney)
	end

	-- Init the player binders using DI --
	inventory:Init(fakeServiceBag, function()
		local pets = bestiaryList.pets
		local defaultEarning = MoneyCalculator.calculateEarnings(pets, 1)
		local boosted = defaultEarning * playerIncomes.CoinsFactor.Value
		return boosted
	end)

	playerIncomes:Init(fakeServiceBag)

	bestiaryList:Init(fakeServiceBag)

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
	newData.items = playerInventory.items

	newData.pets = bestiaryHandler.pets

	newData.lastConnection = os.time()

	playerInventory:Destoy()
	bestiaryHandler:Destroy()
	Incomes:GetHandler(player):Destroy()
	--print("========== SAVING DATA ==========")
	--print("Player:", player.Name)
	--print("Timestamp being saved:", newData.lastConnection)
	--print("=================================")

	-- CurrencyController:RemovePlayer(player)
	return newData
end

ReplicatedStorage.RemoteEvents.PlayerInventory.OnServerEvent:Connect(function(player: Player, ...)
	local inventory = PlayerInventory:GetHandler(player)
	print("inventory ", inventory)
	ReplicatedStorage.RemoteEvents.PlayerInventory:FireClient(player, inventory.items)
end)

return module
