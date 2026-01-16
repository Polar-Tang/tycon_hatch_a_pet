--||Services||--
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local OfflineRewards = require(ServerScriptService.Pets.MoneyGeneration.OfflineRewards)
local petData = require(ServerScriptService.Pets.petData)

------------------Once initilized-------------------------------
local Inventory = ServerScriptService.Player.Inventory
local PlayerInventoryHandler = require(Inventory.PlayerInventory)
local ds = DataStoreService:GetDataStore("rise_a_pet_test")

local function onDescendantAdded(descendant)
	-- Set collision group for any part descendant

	if descendant:IsA("BasePart") then
		descendant.CollisionGroup = "Players"
	end
end

Players.PlayerAdded:Connect(function(player)
	local playerData = ds:GetAsync("data_" .. player.UserId)
	--print("playerData ", playerData)
	if not playerData then
		playerData = {
			inventory = {},
			cash = 0,
			pets = {},
		}
	end
	
	local character = player.Character or player.CharacterAdded:Wait()
	for _, descendant in character:GetDescendants() do
		onDescendantAdded(descendant)
	end

	local totalMoney = playerData.cash or 0
	if playerData.lastConnection then
		local offlineTime = os.time() - playerData.lastConnection 
		print("Player has been offline for ", offlineTime, " seconds")
		for petName, petStats in pairs(petData) do
			local money, eats = OfflineRewards:CalculateOfflineEarnings(petStats, offlineTime)
			if not money then
				break
			end
			print(petName, " ate " ,eats, " times and earned ", money , " coins")
			totalMoney += money
		end
	end

	local dataInit = {
		cash = totalMoney
	}
	
	PlayerInventoryHandler:InitPlayer(player, dataInit)

	local Amount = ReplicatedStorage.RemoteEvents.Amount
	Amount:FireClient(player, {
		amount = totalMoney,
	})
	character.DescendantAdded:Connect(onDescendantAdded)
end)

--||PlayerRemoving||--
Players.PlayerRemoving:Connect(function(player)
	local playerInventory = PlayerInventoryHandler:GetHandler(player)
	--print("playerInventory ", playerInventory)
	local newData = {}

	newData.cash = playerInventory.cash
	-- newData.cash = 0

	newData.lastConnection = os.time()
	--newData.inventory = {}
	PlayerInventoryHandler:RemovePlayer(player)
	ds:SetAsync("data_" .. player.UserId, newData)
end)

--print("Main loaded")
