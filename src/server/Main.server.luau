--||Services||--
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

do
	--||Nevermore Shit||--
	----------------------------- getting servicebag and loader -----------------------------

	local NeverMorePackages = ReplicatedStorage.Nevermore
	local loader = NeverMorePackages:FindFirstChild("LoaderUtils", true).Parent
	local Nevermore = require(loader).bootstrapGame(NeverMorePackages)

	local ServiceBag = Nevermore("ServiceBag")
	local serviceBag = ServiceBag.new()

	----------------------------- init process -----------------------------
	_G.FistBag = serviceBag

	---------- COLDOWNS ----------

	----- ------------------------ INIT SERVICEBAG -----------------------------
	serviceBag:Init()

	serviceBag:Start()
	_G.FistBag = nil
	_G.ServiceBag = serviceBag
end

local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
local OfflineRewards = require(ServerScriptService.Pets.MoneyGeneration.OfflineRewards)
local initPets = require(script.Parent.Seeds.initPets)
local Registry = require(script.Parent.Pets.Registry.Registry)

------------------Once initilized-------------------------------
local Inventory = ServerScriptService.Player.Inventory
local PlayerInventoryHandler = require(Inventory.PlayerInventory)
local ds = DataStoreService:GetDataStore("rise_a_pet_test")

local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)

local function onDescendantAdded(descendant)
	-- Set collision group for any part descendant

	if descendant:IsA("BasePart") then
		descendant.CollisionGroup = "Players"
	end
end

Players.PlayerAdded:Connect(function(player)
	local playerData = ds:GetAsync("data_" .. player.UserId)
	----print("playerData ", playerData)
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
		--print("Player has been offline for ", offlineTime, " seconds")
		for petName, petStats in pairs(petData) do
			local money, eats = OfflineRewards:CalculateOfflineEarnings(petStats, offlineTime)
			if not money then
				break
			end
			--print(petName, " ate ", eats, " times and earned ", money, " coins")
			totalMoney += money
		end
	end

	local dataInit = {
		cash = totalMoney,
		pets = playerData.pets
	}

	PlayerInventoryHandler:InitPlayer(player, dataInit)
	Registry:InitPlayer(player, playerData.pets)
	-- local petsInitialized = initPets(player)
	
	local PetNew = ReplicatedStorage.RemoteEvents.PetNew
	PetNew:FireClient(player, {
		allPets = playerData.pets
	})
	local Amount = ReplicatedStorage.RemoteEvents.Amount
	Amount:FireClient(player, {
		amount = totalMoney,
	})
	character.DescendantAdded:Connect(onDescendantAdded)
end)

--||PlayerRemoving||--
Players.PlayerRemoving:Connect(function(player)
	local playerInventory = PlayerInventoryHandler:GetHandler(player)
	local bestiaryHandler = Registry:GetHandler(player)
	----print("playerInventory ", playerInventory)
	local newData = {}

	newData.cash = playerInventory.cash
	-- newData.cash = 0
	--print("bestiaryHandler.pets ", bestiaryHandler.pets)
	newData.pets = bestiaryHandler.pets

	newData.lastConnection = os.time()
	--newData.inventory = {}
	PlayerInventoryHandler:RemovePlayer(player)
	ds:SetAsync("data_" .. player.UserId, newData)
end)

local Events = ReplicatedStorage.RemoteEvents
local Amount: RemoteEvent = Events.Amount
-- TODO AND BUG: this is accepting any amount of cash, it needs some king of id for the pet and check if the pet can generate that amount of money
Amount.OnServerEvent:Connect(function(player: Player, data)
	local base = data.base
	local player_inventory = PlayerInventory:GetHandler(player)
	player_inventory:IncreaseMoney(base)
	Amount:FireClient(player, {
		amount = base,
	})
	----print("Main loaded")
end)
local PetClicked: RemoteEvent = Events.PetClicked

-- Handle the remote event
PetClicked.OnServerEvent:Connect(function(player, petModel)
	-- Validate the pet exists and belongs to the player (security check)
	if not petModel or not petModel:IsA("Model") then
		warn("Invalid pet model from", player.Name)
		return
	end
	
	-- Do whatever you need when the pet is clicked
	--print(player.Name, "clicked pet:", petModel.Name)

	-- TODO : really needs to create a new player binder to handle the pets
	local bestiaryHandler = Registry:GetHandler(player)

	-- TODO [pet leveling] : USE TIME STAMPS TO VERIFY THE REMOTE EVENT

	local petId = petModel.Name -- TODO [collectionable pets] use the code below instead
	-- local petId = petModel:GetAttribute("PetId")

	local petData = bestiaryHandler.pets[petId]
	PetClicked:FireClient(player, petData)
	-- Example actions:
	-- Award coins, open UI, trigger animation, etc.
end)

local PetLevel: RemoteEvent = Events.PetLevel
local ScaleToLvl = require(ReplicatedStorage.utils.utils).ScaleToLvl


PetLevel.OnServerEvent:Connect(function(player, petModel)
	local bestiaryHandler = Registry:GetHandler(player)

	-- TODO [pet leveling] : USE TIME STAMPS TO VERIFY THE REMOTE EVENT

	local petId = petModel.Name -- TODO [collectionable pets] use the code below instead
	-- local petId = petModel:GetAttribute("PetId")

	--print(" bestiaryHandler.pets ",  bestiaryHandler.pets)
	--print("petId ", petId)
	local lastLevel = bestiaryHandler.pets[petId].petLvl
	-- NEED to figure out how to create the XP based in the npc
	local newPests = bestiaryHandler:increaseXP(petId, 50)
	local petData = newPests[petId]
	
	local data = { lvl = petData.petLvl, prog = petData.petProg }
	if lastLevel ~= petData.petLvl then
		data.isLvlUp = true
		ScaleToLvl(petModel, petData.petLvl)
	end
end)