local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
--||Nevermore Shit||--
----------------------------- getting servicebag and loader -----------------------------

local NeverMorePackages = ReplicatedStorage.Nevermore
local loader = NeverMorePackages:FindFirstChild("LoaderUtils", true).Parent
local Nevermore = require(loader).bootstrapGame(NeverMorePackages)
local Index = require(StarterPlayer.StarterPlayerScripts.facade.Index)
local IndexButton = require(StarterPlayer.StarterPlayerScripts.facade.IndexButton)
local Constants = require(ReplicatedStorage.utils.Constants)

local ServiceBag = Nevermore("ServiceBag")
local serviceBag = ServiceBag.new()

----------------------------- init process -----------------------------
_G.FistBag = serviceBag

---------- COLDOWNS ----------
---------- BINDERS ----------
local Binder = Nevermore("Binder")
local AnimationHandler = Nevermore("AnimationHandler")
local StateMachine = Nevermore("PlotPet")
local NPCFighterClient = Nevermore("NPCFighterClient")
local PetFollower = Nevermore("PetFollower")
local Binders = {
	["AnimationHandler"] = AnimationHandler,
	["NPC"] = StateMachine,
	[Constants.combatBet] = NPCFighterClient,
	[Constants.PetFollower] = PetFollower,
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
----print("BinderProviderStarted ", BinderProviderStarted)
local AnimBinder = BinderProviderStarted:Get("AnimationHandler")

local animationsData = require(ReplicatedStorage.Animations.animationsData)
local PlotServiceClient = require(ReplicatedStorage.Nevermore.Custom.npc.src.Client.NPC.Servicies.PlotServiceClient)
local utils = require(ReplicatedStorage.utils.utils)

-- Register all the animations registered with the models name
AnimBinder:GetClassAddedSignal():Connect(function(binder)
	----print("animationsData ", animationsData, binder.Char)
	local petName = binder.Char:GetAttribute("petName")
	--print("petName ", petName)
	binder:Init(binder.Char:WaitForChild(binder.Char:GetAttribute("AnimatorName")))
	binder:registryAnims(animationsData[petName])
	binder:PreloadAnims({ "eat", "walk", "idle" })
	binder:LoadAnimation(true, "idle")
end)

local MachineBinder = BinderProviderStarted:Get("NPC")

-- when it doesn't work _initialized and _started are true

-- Register all the animations registered with the models name
MachineBinder:GetClassAddedSignal():Connect(function(machine_binder)
	local player = Players.LocalPlayer
	machine_binder:Init(player)
end)

----- ------------------------ START SERVICEBAG -----------------------------

serviceBag:Start()
_G.FistBag = nil
_G.ServiceBag = serviceBag
_G.BinderProvider = AllBinders

-- do
-- 	for _, npc in CollectionService:GetTagged("NPC") do
-- 		print("is a model i guess ", npc)
-- 		local binder = MachineBinder:Get(npc)
-- 		binder:Init(Players.LocalPlayer)
-- 	end
-- end

local PetNew = ReplicatedStorage.RemoteEvents.PetNew
PetNew.OnClientEvent:Connect(function(data)
	--print("data ", data)
	if data.allPets then
		-- TODO [Collectionable Pets task]: pets should be tagged and placed in a slot here, with data from the server
		_G["pets_registry"] = data.allPets
		-- Pet service from data to world

		-- function PetService.fromDataToWorld(Owner: Player, petInfo: PetTypes.PetData, position: Vector3?)
		for _, petInfo in pairs(_G["pets_registry"]) do
			local userId = tostring(Players.LocalPlayer.UserId)
			local pet: Model = ReplicatedFirst.Pets[petInfo.petName]:Clone()
			assert(pet.PrimaryPart, "model " .. pet.Name .. " has no primary part")
			pet:SetAttribute("petName", pet.Name)

			local playerRegistry = Instance.new("StringValue", pet)
			playerRegistry.Value = userId
			playerRegistry.Name = "Owner"

			local plot = PlotServiceClient.GetPlotByUserId(userId)

			pet.Name = petInfo.petId

			-- pet.PrimaryPart.Position = position or PlotService:GetRandPosition(plot)
			local endPos = PlotServiceClient:GetRandPosition(plot)

			pet.Parent = workspace

			pet:PivotTo(CFrame.new(endPos))

			pet:MoveTo(endPos)

			CollectionService:AddTag(pet, "NPC")
			CollectionService:AddTag(pet, "AnimationHandler")

			CollectionService:AddTag(pet, "plot_" .. plot:FindFirstChild("PlotId").Value)
			CollectionService:AddTag(pet, "pets_" .. userId)
			utils.ScaleToLvl(pet, petInfo.petLvl)
		end
	elseif data.newPet then
		_G["pets_registry"][data.newPet.petId] = data.newPet
	else
		warn("Unkown attribute")
	end
	print("_G['pets_registry'] ", _G["pets_registry"])
end)

-- REPLICATE THE PETS TO OTHER PLAYERS
do
	workspace:WaitForChild("FenceBounds1")
	workspace:WaitForChild("FenceBounds2")
	workspace:WaitForChild("FenceBounds3")
	workspace:WaitForChild("FenceBounds4")
	workspace:WaitForChild("FenceBounds5")
	workspace:WaitForChild("FenceBounds6")

	for i = 1, 6 do
		CollectionService:GetInstanceAddedSignal("plot_" .. i):Connect(function(model)
			CollectionService:AddTag(model, "NPC")

			-- Observe ancestry: fires whenever parent changes
			local sub = model.AncestryChanged:Connect(function(_, newParent)
				if newParent == nil then
					-- model was removed from the tree, destroy its binder
					local binder = MachineBinder:Get(model) -- or however you retrieve it
					if binder then
						binder:Destroy()
					end
					local anim_binder = AnimBinder:Get(model)
					if anim_binder then
						anim_binder:Destroy()
					end
				end
			end)

			-- Also clean up the connection itself when model is destroyed
			model.Destroying:Connect(function()
				sub:Disconnect()
			end)
		end)
	end
end

local _ = require(script.Parent.RoactApp)

local function getInputType(): EnumItem
	local lastInput = UserInputService:GetLastInputType()

	if lastInput == Enum.UserInputType.Touch then
		return Enum.ProximityPromptInputType.Touch
	elseif lastInput.Name:find("Gamepad") then
		return Enum.ProximityPromptInputType.Gamepad
	else
		return Enum.ProximityPromptInputType.Keyboard
	end
end

game.ReplicatedStorage.RemoteEvents.RemoteSync:FireServer({ loaded = "all", inputType = getInputType() })
local TopButtons = require(StarterPlayer.StarterPlayerScripts.facade.TopButtons)

do
	TopButtons.init({
		["PlotButton"] = function()
			game.ReplicatedStorage.RemoteEvents.TeleportRemote:FireServer("plot")
		end,
		["EggButton"] = function()
			game.ReplicatedStorage.RemoteEvents.TeleportRemote:FireServer("eggShop")
		end,
		["UtilityButton"] = function()
			game.ReplicatedStorage.RemoteEvents.TeleportRemote:FireServer("kiblyShop")
		end,
	})
	local _ = require(StarterPlayer.StarterPlayerScripts.UI.petMediatorClient)

	IndexButton.init()
	IndexButton.getIndexButton().Activated:Connect(function(a0: InputObject, a1: number)
		if Index.isOpen() then
			Index.close()
			IndexButton.rotate(180)
		else
			Index.open()
			IndexButton.rotate(0)
		end
	end)
end

-- Setup teleporting for boss fights
do
	local TeleportRemote = ReplicatedStorage.RemoteEvents.TeleportRemote

	local function setupTeleporter(teleporter: Instance)
		local destination = "plot"

		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Teleport"
		prompt.ObjectText = destination
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 8
		prompt.Parent = teleporter

		prompt.Triggered:Connect(function(player: Player)
			TeleportRemote:FireServer(destination)
		end)
	end

	-- Setup existing teleporters
	for _, teleporter in CollectionService:GetTagged("teleporter") do
		setupTeleporter(teleporter)
	end
end

-- Do some weird tecnique for avoiding pet colliding with the camera
--[[
	
do
	local camera = workspace.CurrentCamera
	local player_character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local function updatePetTransparency(pet, character)
		local origin = camera.CFrame.Position
		local target = character.HumanoidRootPart.Position

		local params = RaycastParams.new()
		params.FilterDescendantsInstances = { character }
		params.FilterType = Enum.RaycastFilterType.Exclude

		local result = workspace:Raycast(origin, target - origin, params)

		if result and result.Instance:GetAttribute("petName") then
			for _, part in pet:GetDescendants() do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 0.7
				end
			end
		else
			for _, part in pet:GetDescendants() do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 0
				end
			end
		end
	end

	RunService.RenderStepped:Connect(function()
		for _, pet in CollectionService:GetTagged(Constants.PetFollower) do
			updatePetTransparency(pet, player_character)
		end
	end)
end
]]

-- FADING TEXT EVENT
do
	local fadingText = function(rootPart: BasePart, text: string, textColor: Color3?, size: UDim2?)
		print("text ", text)
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "CustomHumanoidBar"
		billboard.Adornee = rootPart
		billboard.Size = size or UDim2.new(1, 0, 1, 0)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = rootPart

		local DamageLabel = Instance.new("TextLabel")
		DamageLabel.Name = "Label"
		DamageLabel.Size = UDim2.new(1, 0, 1, 0)
		DamageLabel.BackgroundTransparency = 1
		DamageLabel.Text = tostring(text)
		DamageLabel.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
		DamageLabel.Position = UDim2.new(0, 0, 0, 0)
		DamageLabel.Font = Enum.Font.GothamBold
		DamageLabel.ZIndex = 2
		DamageLabel.TextScaled = true
		DamageLabel.Parent = billboard
		-- Animation: float up and fade out
		task.spawn(function()
			local duration = 1.0 -- seconds
			local startTime = tick()
			local startOffset = billboard.StudsOffset
			local floatDistance = 2 -- studs to move up
			while true do
				local elapsed = tick() - startTime
				local alpha = math.clamp(elapsed / duration, 0, 1)
				-- Move up
				billboard.StudsOffset = startOffset + Vector3.new(0, floatDistance * alpha, 0)
				-- Fade out
				DamageLabel.TextTransparency = alpha
				DamageLabel.TextStrokeTransparency = alpha
				if alpha >= 1 then
					break
				end
				task.wait()
			end
			billboard:Destroy()
		end)
	end
	ReplicatedStorage.RemoteEvents.TextFade.OnClientEvent:Connect(function(data)
		local rootPart
		if data.source then
			rootPart = data.source
		elseif data.position then
			rootPart = Instance.new("Part")
			rootPart.CanCollide = false
			rootPart.CanQuery = false
			rootPart.CanTouch = false
			rootPart.CanTouch = false
			rootPart.AudioCanCollide = false
			rootPart.CastShadow = false
			rootPart.Anchored = true
			rootPart.Size = Vector3.new(1, 1, 1)
			rootPart.Transparency = 1
			rootPart.Position = data.position
			rootPart.Parent = workspace
		end
		local damage = data.text
		print("this damage shuld be printed ", damage)
		fadingText(rootPart, damage)
	end)
end
