local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local ItemData = require(ReplicatedStorage.Items.ItemData)
local npcTypes = require(ReplicatedStorage.utils.npcTypes)
local npcUtils = require(ReplicatedStorage.utils.npcUtils)
local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)
local gearShop = require(StarterPlayer.StarterPlayerScripts.facade.gearShop)

local ItemsEvent = ReplicatedStorage.RemoteEvents.ItemsEvent

local module = {}

local kibly: Model = workspace:WaitForChild("ShopKeepers"):WaitForChild("Kibly Shop Keeper")
local kibly_primaryPart = kibly.PrimaryPart or kibly:WaitForChild("HumanoidRootPart")
local kibly_original_CF = kibly_primaryPart.CFrame

module["Kibly Shop Keeper"] = {
	image = assets["store_icon"],
	name = "Gear Shop",
	greetings = function(selfParent: Model)
		npcUtils.lookAtPlayer(selfParent)

		local animator: Animator = selfParent:WaitForChild("Humanoid"):WaitForChild("Animator")

		local cheerAnimation: Animation = Instance.new("Animation")
		cheerAnimation.AnimationId = "http://www.roblox.com/asset/?id=507770677"
		local anim_track: AnimationTrack = animator:LoadAnimation(cheerAnimation)
		anim_track:Play()
		local animEnded: RBXScriptConnection
		animEnded = anim_track.Ended:Connect(function(...)
			anim_track:Stop()

			animEnded:Disconnect()
		end)
	end,
	promptTrigger = function()
		if not gearShop.isDifferentShop("Gear Shop") then
			gearShop.close()
		elseif gearShop.isOpen() then
			return
		end
		gearShop.open()
		gearShop.createItem(ItemData["SpeedCoil"], function()
			ItemsEvent:FireServer(ItemData["SpeedCoil"])
		end)
	end,
	updatePrompt = function()
		npcUtils.lookAtPlayer(kibly)
	end,
	finishPrompt = function()
		kibly_primaryPart.CFrame = kibly_original_CF
	end,
	imageSize = UDim2.fromOffset(128, 86),
	default = true,
	checkIsOpen = function()
		return gearShop.isOpen()
	end,
}

module["Egg"] = {
	name = "Egg",
	greetings = function(selfParent: Model)
		
	end,
	promptTrigger = function(_, egg)
		ReplicatedStorage.RemoteEvents.HatchEgg:FireServer(egg)

	end,
	
	finishPrompt = function()
		kibly_primaryPart.CFrame = kibly_original_CF
	end,
	imageSize = UDim2.fromOffset(128, 86),
	default = true,
	checkIsOpen = function()
		return gearShop.isOpen()
	end,
}

local egg = workspace:WaitForChild("ShopKeepers"):WaitForChild("Egg Shop Keeper")

local egg_primaryPart = egg.PrimaryPart or egg:WaitForChild("HumanoidRootPart")
local egg_original_CF = egg_primaryPart.CFrame

module["Egg Shop Keeper"] = {
	image = assets["egg_icon"],
	name = "Egg Shop",
	greetings = function(selfParent: Model)
		npcUtils.lookAtPlayer(selfParent)

		local animator: Animator = selfParent:WaitForChild("Humanoid"):WaitForChild("Animator")

		local cheerAnimation: Animation = Instance.new("Animation")
		cheerAnimation.AnimationId = "http://www.roblox.com/asset/?id=507770239"
		local anim_track: AnimationTrack = animator:LoadAnimation(cheerAnimation)
		anim_track.Looped = false
		anim_track:Play()
	end,
	originalCF = workspace:FindFirstChild("ShopKeepers"):FindFirstChild("Egg Shop Keeper").PrimaryPart.CFrame,

	promptTrigger = function()
		if not gearShop.isDifferentShop("Egg Shop") then
			gearShop.close()
		elseif gearShop.isOpen() then
			return
		end
		gearShop.open("Egg Shop")
		gearShop.createItem(ItemData["White Egg"], function()
			-- ReplicatedStorage.RemoteEvents.BuyEggRemote:FireServer("white")
			ItemsEvent:FireServer(ItemData["White Egg"])

		end)
		gearShop.createItem(ItemData["Red Egg"], function()
			-- ReplicatedStorage.RemoteEvents.BuyEggRemote:FireServer("red")
			ItemsEvent:FireServer(ItemData["Red Egg"])

		end)
	end,
	updatePrompt = function()
		npcUtils.lookAtPlayer(egg)
	end,
	finishPrompt = function()
		egg_primaryPart.CFrame = egg_original_CF
	end,
	imageSize = UDim2.fromOffset(128, 86),
	default = true,
	checkIsOpen = function()
		return gearShop.isOpen()
	end,
}

return module :: { [string]: npcTypes.nameToAction }
