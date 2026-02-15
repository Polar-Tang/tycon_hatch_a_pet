local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local OfflineRewards = require(ServerScriptService.Pets.MoneyGeneration.OfflineRewards)
local Registry = require(ServerScriptService.Pets.Registry.Registry)
local MoneyCalculator = require(ServerScriptService.Player.Currency.MoneyCalculator)
local Items = require(ServerScriptService.Player.Inventory.Items)
local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)
local InitPlot = require(ServerScriptService.Seeds.InitPlot)
local initPets = require(ServerScriptService.Seeds.initPets)
local module = {}

local function onDescendantAdded(descendant)
	-- Set collision group for any part descendant

	if descendant:IsA("BasePart") then
		descendant.CollisionGroup = "Players"
	end
end

function module.PlayerAdded(player, playerData)
	----print("playerData ", playerData)
	if not playerData then
		local petsInitialized = initPets(player)
		playerData = {
			inventory = {},
			cash = 0,
			pets = petsInitialized,
		}
		print("INIT WITH NEW DATA")
	end

	local character = player.Character or player.CharacterAdded:Wait()
	for _, descendant in character:GetDescendants() do
		onDescendantAdded(descendant)
	end

	local totalMoney = playerData.cash or 0

	InitPlot(player, playerData.pets)
	print(playerData.pets, "playerData.pets has petId or petName as key?")
	Registry:InitPlayer(player, playerData.pets)
	PlayerInventory:InitPlayer(player, {
		cash = totalMoney,
	})
	local inventory = PlayerInventory:GetHandler(player)

	if playerData.lastConnection then
		local offlineTime = os.time() - playerData.lastConnection

		local offlineMoney, _, _ = OfflineRewards.CalculatePerMinuteEarnings(player, offlineTime)
		if offlineMoney then
			totalMoney += offlineMoney
		end

		inventory:IncreaseMoney(offlineMoney)
		OfflineRewards.CalculateXP(player, offlineTime)
	end

	-- CurrencyController:InitPlayer(player)
	-- local petsInitialized = initPets(player)

	local PetNew = ReplicatedStorage.RemoteEvents.PetNew
	PetNew:FireClient(player, {
		allPets = playerData.pets,
	})
	local Amount = ReplicatedStorage.RemoteEvents.Amount
	Amount:FireClient(player, {
		amount = inventory.cash,
	})
	character.DescendantAdded:Connect(onDescendantAdded)
end

function module.PlayerRemoving(player)
	local playerInventory = PlayerInventory:GetHandler(player)
	local bestiaryHandler = Registry:GetHandler(player)
	local newData = {}
	local newMoney = MoneyCalculator.collectPendingMoney(player)
	local allTheCash = playerInventory.cash + newMoney
	print("last monet ", playerInventory.cash, "all the cash earned ", allTheCash)
	newData.cash = allTheCash
	newData.pets = bestiaryHandler.pets

	newData.lastConnection = os.time()

	print("========== SAVING DATA ==========")
	print("Player:", player.Name)
	print("Timestamp being saved:", newData.lastConnection)
	print("=================================")

	-- CurrencyController:RemovePlayer(player)
	return newData
end

return module
