--||Services||--
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
print("BinderProviderStarted ", BinderProviderStarted)
local AnimBinder = BinderProviderStarted:Get("AnimationHandler")
local animationsData = require(ReplicatedStorage.Animations.animationsData)

-- Register all the animations registered with the models name
AnimBinder:GetClassAddedSignal():Connect(function(binder)
	print("animationsData ", animationsData, binder.Char)
	binder:registryAnims(animationsData[binder.Char.Name])
end)

local MachineBinder = BinderProviderStarted:Get("NPC")

-- when it doesn't work _initialized and _started are true

-- Register all the animations registered with the models name
MachineBinder:GetClassAddedSignal():Connect(function(machine_binder)
	print("added")
	machine_binder:Init()
end)
----- ------------------------ START SERVICEBAG -----------------------------

serviceBag:Start()
_G.FistBag = nil
_G.ServiceBag = serviceBag
_G.BinderProvider = AllBinders

------------------Once initilized-------------------------------
----Do binder stuff-------------------------------

Players.PlayerAdded:Connect(function(player) end)
--||PlayerRemoving||--
Players.PlayerRemoving:Connect(function(player)
	-- PlayerAnimationHandler:RemovePlayer({ player = player })
end)

print("Main loaded")
