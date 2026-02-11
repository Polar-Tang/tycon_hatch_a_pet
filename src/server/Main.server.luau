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

local Env = require(script.Parent.Env)
local Mediator = require(script.Parent.Mediator)
local utils = require(ReplicatedStorage.utils.utils)
local Registry = require(script.Parent.Pets.Registry.Registry)

------------------Once initilized-------------------------------
local ds = DataStoreService:GetDataStore(Env.DB_URI)

local MAX_PLAYERS = 8

local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)

-- 🔥 CRITICAL: Server shutdown handler
game:BindToClose(function()
	-- Yield is allowed here
	task.wait(2)
end)

--||PlayerRemoving||--
Players.PlayerRemoving:Connect(function(player)
	local newData = Mediator.PlayerRemoving(player)
	--print("========== BEFORE SetAsync ==========")
	--print("Data about to save:", game:GetService("HttpService"):JSONEncode(newData))
	--print("lastConnection:", newData)

	local success, errorMessage = pcall(function()
		ds:SetAsync("data_" .. player.UserId, newData)
	end)

	if success then
		--print("========== AFTER SetAsync ==========")
		--print("SetAsync completed successfully")
		--print("=====================================")
	else
		warn("========== SetAsync FAILED ==========")
		warn("Error:", errorMessage)
		warn("Player:", player.Name)
		warn("UserId:", player.UserId)
		warn("====================================")
	end

	-- TODO : 	In Game Settings → Basic Settings: Set Max Players = 8
	if #Players:GetPlayers() > MAX_PLAYERS then
		player:Kick("This server is full (8/8).")
	end

	-- Small wait to ensure --prints appear before connection ends
end)

Players.PlayerAdded:Connect(function(player)
	local playerData = ds:GetAsync("data_" .. player.UserId)
	--print("========== LOADING DATA ==========")
	--print("playerData:", playerData)
	--print("Raw data received:", game:GetService("HttpService"):JSONEncode(playerData or {}))
	--print("lastConnection received:", "NIL")

	--print("==================================")
	Mediator.PlayerAdded(player, playerData)
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
	------print("Main loaded")
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
	----print(player.Name, "clicked pet:", petModel.Name)

	-- TODO : really needs to create a new player binder to handle the pets
	local bestiaryHandler = Registry:GetHandler(player)

	-- TODO [pet leveling] : USE TIME STAMPS TO VERIFY THE REMOTE EVENT

	local petId = petModel.Name -- TODO [collectionable pets] use the code below instead
	-- local petId = petModel:GetAttribute("PetId")

	bestiaryHandler:setPetClicked(petId)
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
	print("petId ", petId)
	----print(" bestiaryHandler.pets ",  bestiaryHandler.pets)
	----print("petId ", petId)
	local lastLevel = bestiaryHandler.pets[petId].petLvl
	-- NEED to figure out how to create the XP based in the npc
	local petData = bestiaryHandler:increaseXP(petId, 50)
	if not petData then
		return
	end

	local data = { lvl = petData.petLvl, prog = petData.petProg }
	if lastLevel ~= petData.petLvl then
		data.isLvlUp = true
		ScaleToLvl(petModel, petData.petLvl)
		if petId == bestiaryHandler.petClicked then
			PetClicked:FireClient(player, petData)
		end
	end
end)

local PetStat: RemoteEvent = Events.PetStat
PetStat.OnServerEvent:Connect(function(player, data)
	local bestiaryHandler = Registry:GetHandler(player)
	if data.close then
		bestiaryHandler:unsetPetClicked()
		return
	end
	-- TODO [pet leveling] : USE TIME STAMPS TO VERIFY THE REMOTE EVENT

	local petId = data.petId
	local stat = data.stat

	----print(" bestiaryHandler.pets ",  bestiaryHandler.pets)
	----print("petId ", petId)
	-- NEED to figure out how to create the XP based in the npc
	local newPests = bestiaryHandler:spendPoint(petId, stat)
	if not newPests then
		return
	end
	local petData = newPests[petId]
	-- TODO: [collectionable pets] get the pet model by its id
	local petModel = workspace:FindFirstChild(petId)
	utils.setUpStats(petModel, petData.petStats)

	if petId == bestiaryHandler.petClicked then
		PetClicked:FireClient(player, petData)
	end
end)
