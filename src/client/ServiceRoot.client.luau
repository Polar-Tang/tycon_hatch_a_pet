local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
	local petName = binder.Char:GetAttribute("petName")
	binder:registryAnims(animationsData[petName])
	binder:PreloadAnims({ "eat", "walk", "idle" })
	binder:LoadAnimation(true, "idle")
end)

local MachineBinder = BinderProviderStarted:Get("NPC")

-- when it doesn't work _initialized and _started are true

-- Register all the animations registered with the models name
MachineBinder:GetClassAddedSignal():Connect(function(machine_binder)
	local player = Players.LocalPlayer
	task.delay(2, function()
		machine_binder:Init(player)
	end)
end)
----- ------------------------ START SERVICEBAG -----------------------------

serviceBag:Start()
_G.FistBag = nil
_G.ServiceBag = serviceBag
_G.BinderProvider = AllBinders

local PetNew = ReplicatedStorage.RemoteEvents.PetNew

PetNew.OnClientEvent:Connect(function(data)
	print("data ", data)
	if data.allPets then
		-- TODO [Collectionable Pets task]: pets should be tagged and placed in a slot here, with data from the server
		_G["pets_registry"] = data.allPets
	elseif data.newPet then
		table.insert(_G["pets_registry"], data.newPet)
	else
		warn("Unkown attribute")
	end
end)
