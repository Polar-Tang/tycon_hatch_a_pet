--||Services||--
local DataStoreService = game:GetService("DataStoreService")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--||Nevermore Shit||--
----------------------------- getting servicebag and loader -----------------------------

local NeverMorePackages = RS.Nevermore
local loader = NeverMorePackages:FindFirstChild("LoaderUtils", true).Parent
local Nevermore = require(loader).bootstrapGame(NeverMorePackages)

local ServiceBag = Nevermore("ServiceBag")
local serviceBag = ServiceBag.new()

----------------------------- init process -----------------------------
_G.FistBag = serviceBag

---------- COLDOWNS ----------
---------- BINDERS ----------
local Binder = Nevermore("Binder")
local AnimationHandler = Nevermore("AnimationHandler")
local StateMachine = Nevermore("StateMachine")

local Binders = {
	["AnimationHandler"] = AnimationHandler,
	["NPC"] = StateMachine,
}
---------- USE BINDER PORVIDER ----------
local BinderProvider = Nevermore("BinderProvider")

local AllBinders = BinderProvider.new("Binders", function(self, serviceBag)
	for tag, contructor in pairs(Binders) do
		self:Add(Binder.new(tag, contructor), serviceBag)
	end
end)
----- ------------------------ INIT SERVICEBAG -----------------------------
serviceBag:GetService(AllBinders)
serviceBag:Init()

local BinderProviderStarted = serviceBag:GetService(AllBinders)
--print("BinderProviderStarted ", BinderProviderStarted)
local AnimBinder = BinderProviderStarted:Get("AnimationHandler")
local animationsData = require(ReplicatedStorage.Animations.animationsData)

-- Register all the animations registered with the models name
AnimBinder:GetClassAddedSignal():Connect(function(binder)
	--print("animationsData ", animationsData, binder.Char)
	binder:registryAnims(animationsData[binder.Char.Name])
	binder:PreloadAnims({ "eat", "walk", "idle" })
	binder:LoadAnimation(true, "idle")
end)

local MachineBinder = BinderProviderStarted:Get("NPC")

-- when it doesn't work _initialized and _started are true

-- Register all the animations registered with the models name
MachineBinder:GetClassAddedSignal():Connect(function(machine_binder)
	local player = Players:GetPlayers()[1]
	if not player then
		player = Players.PlayerAdded:Wait()
	end

	machine_binder:Init(player)
end)
----- ------------------------ START SERVICEBAG -----------------------------

serviceBag:Start()
_G.FistBag = nil
_G.ServiceBag = serviceBag
_G.BinderProvider = AllBinders

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
	PlayerInventoryHandler:InitPlayer(player, playerData)
	local Amount = ReplicatedStorage.RemoteEvents.Amount
	Amount:FireClient(player, {
		amount = playerData.cash,
	})
	local character = player.Character or player.CharacterAdded:Wait()
	for _, descendant in character:GetDescendants() do
		onDescendantAdded(descendant)
	end

	character.DescendantAdded:Connect(onDescendantAdded)
end)

--||PlayerRemoving||--
Players.PlayerRemoving:Connect(function(player)
	local playerInventory = PlayerInventoryHandler:GetHandler(player)
	--print("playerInventory ", playerInventory)
	local newData = {}

	newData.cash = playerInventory.cash

	--newData.inventory = {}
	PlayerInventoryHandler:RemovePlayer(player)

	ds:SetAsync("data_" .. player.UserId, newData)
end)

--print("Main loaded")
