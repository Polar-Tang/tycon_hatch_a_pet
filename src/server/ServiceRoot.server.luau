--||Services||--
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

--||Nevermore Shit||--

----------------------------- getting servicebag and loader -----------------------------

local NeverMorePackages = ReplicatedStorage.Nevermore
local loader = NeverMorePackages:FindFirstChild("LoaderUtils", true).Parent
local Nevermore = require(loader).bootstrapGame(NeverMorePackages)

local ServiceBag = Nevermore("ServiceBag")

local serviceBag = ServiceBag.new()
local Registry = Nevermore("BestiaryList")

----------------------------- init process -----------------------------
_G.FistBag = serviceBag

---------- COLDOWNS ----------

----- ------------------------ INIT SERVICEBAG -----------------------------
serviceBag:Init()

serviceBag:Start()
_G.FistBag = nil
_G.ServiceBag = serviceBag

local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)
local Env = require(script.Parent.Env)
local Mediator = require(script.Parent.Mediator)
local utils = require(ReplicatedStorage.utils.utils)
local _ = require(script.Parent.ShopKeepers.npcMediator)
------------------Once initilized-------------------------------
local ds = DataStoreService:GetDataStore(Env.DB_URI)

local MAX_PLAYERS = 6

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

	-- Small wait to ensure --prints appear before connection ends
end)

-- set collisions group couse i don't feel like doing this manually from roblox studio
do
	local function onDescendantAdded(descendant)
		-- Set collision group for any part descendant

		if descendant:IsA("BasePart") then
			descendant.CanCollide = true
			descendant.CollisionGroup = "Npcs"
			descendant.Anchored = false
			if descendant.Name == "Rootpart" then
				descendant.Anchored = true
			end
		end
	end

	local setCollider = function(parent, cb)
		for _, descendant in parent:GetDescendants() do
			if descendant:IsA("Model") then
				for _, descendant in parent:GetDescendants() do
					cb(descendant)
				end
			end
			cb(descendant)
		end
	end

	local petsFolder: Folder = ServerStorage.Pets
	local pets = petsFolder:GetDescendants()

	for _, pet in pets do
		pet:SetAttribute("AnimatorName", "AnimationController")
		setCollider(pet, onDescendantAdded)
	end
	local petsFighterFolder: Folder = ReplicatedFirst.Pets
	local petsFighters = petsFighterFolder:GetDescendants()

	for _, pet in petsFighters do
		pet:SetAttribute("AnimatorName", "Humanoid")
		setCollider(pet, onDescendantAdded)
	end

	local function fullOptimized(descendant)
		-- Set collision group for any part descendant

		if descendant:IsA("BasePart") then
			local descendantPar: BasePart = descendant
			descendantPar.CanCollide = false
			descendantPar.CanQuery = false
			descendantPar.CanTouch = false
			descendantPar.CanTouch = false
			descendantPar.AudioCanCollide = false
			descendantPar.CastShadow = false
			descendantPar.Anchored = true
		end
	end

	local petsClientFolder = ServerStorage.Pets:Clone()
	petsClientFolder.Name = "PetsTemplates"
	
	local petsClient = petsClientFolder:GetDescendants()
	for _, pet in petsClient do
		setCollider(pet, fullOptimized)
	end
	petsClientFolder.Parent = ReplicatedFirst

	-- CLoning the server authorative pets in replicated storage for havin pets with animation controller avaible for rendering
	local petModels = ServerStorage.Pets:Clone()
	petModels.Name = "PetModels"
	petModels.Parent = ReplicatedFirst
end

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

PetLevel.OnServerEvent:Connect(function(player, petModel)
	local bestiaryHandler = Registry:GetHandler(player)

	-- TODO [pet leveling] : USE TIME STAMPS TO VERIFY THE REMOTE EVENT

	local petId = petModel.Name -- TODO [collectionable pets] use the code below instead
	-- local petId = petModel:GetAttribute("PetId")
	----print(" bestiaryHandler.pets ",  bestiaryHandler.pets)
	----print("petId ", petId)
	local petData = bestiaryHandler.pets[petId]

	if not petData then
		return
	end

	local lastLevel = petData.petLvl
	-- NEED to figure out how to create the XP based in the npc
	local newPetData = bestiaryHandler:increaseXP(petId, 100)
	if not newPetData then
		return
	end

	local data = { lvl = newPetData.petLvl, prog = newPetData.petProg }
	if lastLevel ~= newPetData.petLvl then
		data.isLvlUp = true

		if petId == bestiaryHandler.petClicked then
			PetClicked:FireClient(player, newPetData)
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
	local action = data.action

	----print(" bestiaryHandler.pets ",  bestiaryHandler.pets)
	----print("petId ", petId)
	-- NEED to figure out how to create the XP based in the npc
	local newPests = bestiaryHandler:spendPoint(petId, stat, action)
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

local _ = require(script.Parent.Pets.petMediator)
