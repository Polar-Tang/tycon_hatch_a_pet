local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local StarterPlayer = game:GetService("StarterPlayer")
local RunService = game:GetService("RunService")
local ItemData = require(ReplicatedStorage.Items.ItemData)
local Constants = require(ReplicatedStorage.utils.Constants)
local npcTypes = require(ReplicatedStorage.utils.npcTypes)
local npcUtils = require(ReplicatedStorage.utils.npcUtils)
local EggsByColor = require(ReplicatedStorage.Pets.EggsByColor)
local PetsByRarity = require(ReplicatedStorage.Pets.PetsByRarity)
local PetsByClassificationArray = require(ReplicatedStorage.Pets.PetsByClassificationArray)
local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)
local gearShop = require(StarterPlayer.StarterPlayerScripts.facade.gearShop)

local ItemsEvent = ReplicatedStorage.RemoteEvents.ItemsEvent
local HatchEggRemote = ReplicatedStorage.RemoteEvents:WaitForChild("HatchEgg")
local petTemplates = ReplicatedFirst:WaitForChild("PetsTransparentTemplates")

local module = {}

local function getEggPetNames(egg: Model): { string }
	local eggCategory = egg:GetAttribute(Constants.EggCategory)
	if typeof(eggCategory) ~= "string" then
		return {}
	end

	local eggData = EggsByColor[eggCategory]
	if not eggData then
		return {}
	end

	if eggData.rarity then
		local pets = PetsByRarity[eggData.rarity]
		if pets then
			return pets :: { string }
		end
	end

	if eggData.classification then
		local petsByClassification = PetsByClassificationArray[eggData.classification]
		if petsByClassification then
			local pets = {}
			for _, petList in pairs(petsByClassification) do
				for _, petName in ipairs(petList) do
					table.insert(pets, petName)
				end
			end
			return pets :: { string }
		end
	end

	return {}
end

local function playEggPreview(egg: Model, startTime: number)
	local petNames = getEggPetNames(egg)
	if #petNames == 0 then
		return
	end

	local previewFolder = Instance.new("Folder")
	previewFolder.Name = "EggHatchPreview"
	previewFolder.Parent = workspace

	local clonedPets = {}
	for _, petName in ipairs(petNames) do
		local template = petTemplates:FindFirstChild(petName)
		if template and template:IsA("Model") then
			local clone = template:Clone()
			clone.Parent = previewFolder
			table.insert(clonedPets, clone)
		end
	end

	if #clonedPets == 0 then
		previewFolder:Destroy()
		return
	end

	local eggPivot = egg:GetPivot()
	local endTime = startTime + 5
	local timer = startTime
	local nextSpawnTime = startTime
	local previewConnection: RBXScriptConnection?

	local function animateClone(clone: Model)
		clone:PivotTo(eggPivot)
		clone:ScaleTo(0.5)

		local elapsed = 0
		local animationConnection: RBXScriptConnection?
		animationConnection = RunService.Heartbeat:Connect(function(deltaTime)
			if not clone.Parent then
				if animationConnection then
					animationConnection:Disconnect()
				end
				return
			end

			elapsed += deltaTime
			local alpha = math.clamp(elapsed, 0, 1)
			clone:ScaleTo(0.5 + 0.5 * alpha)

			if elapsed >= 1 then
				clone:ScaleTo(1)
				if animationConnection then
					animationConnection:Disconnect()
				end
			end
		end)

		Debris:AddItem(clone, 1.1)
	end

	previewConnection = RunService.Heartbeat:Connect(function(deltaTime)
		timer += deltaTime

		while nextSpawnTime <= timer and nextSpawnTime < endTime do
			local petName = petNames[math.random(1, #petNames)]
			local template = petTemplates:FindFirstChild(petName)
			if template and template:IsA("Model") then
				local clone = template:Clone()
				clone.Parent = previewFolder
				table.insert(clonedPets, clone)
				animateClone(clone)
			end

			nextSpawnTime += 1
		end

		if timer > endTime then
			if previewConnection then
				previewConnection:Disconnect()
			end
			previewFolder:Destroy()
		end
	end)
end

local kibly: Model = workspace:WaitForChild("ShopKeepers"):WaitForChild("Kibly Shop Keeper")
local kibly_primaryPart = kibly.PrimaryPart or kibly:WaitForChild("HumanoidRootPart")
local kibly_original_CF = kibly_primaryPart.CFrame

module["Kibly Shop Keeper"] = {
	image = assets["store_icon"],
	name = "Gear Shop",
	greetings = function(selfParent: Model)
		npcUtils.lookAtPlayer(selfParent)

		local animator = selfParent:WaitForChild("Humanoid"):WaitForChild("Animator") :: Animator

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
	greetings = function(selfParent: Model) end,
	promptTrigger = function(_, egg: Model)
		if not egg then
			return
		end

		local hatchStartTime = workspace:GetServerTimeNow()
		HatchEggRemote:FireServer(egg, hatchStartTime)
		playEggPreview(egg, hatchStartTime)
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

		local animator = selfParent:WaitForChild("Humanoid"):WaitForChild("Animator") :: Animator

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
