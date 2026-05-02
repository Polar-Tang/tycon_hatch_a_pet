local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local petTemplates = ReplicatedFirst:WaitForChild("PetsTemplates") -- We wait for child because this instance is create by the server at runtime

local FightButton = require(script.FightButton)
local petBosses = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petBosses)
local petDetails = require(script.Parent.petDetails)
local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
local clientUtils = require(StarterPlayer.StarterPlayerScripts.utils.clientUtils)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local stringUtils = require(ReplicatedStorage.utils.stringUtils)
local utils = require(ReplicatedStorage.utils.utils)
local slotButtonHandler = require(script.slotButtonHandler)

local player = Players.LocalPlayer

local PlayerGui = player:WaitForChild("PlayerGui")

local screen = PlayerGui:WaitForChild("ScreenGui")

local Index = {}

local global_maid = Maid.new()
local slots_maid = Maid.new()
global_maid:GiveTask(slots_maid)

local slotNum = 0
local currentUiStroke

function Index.open()
	screen.Index.Visible = true

	do
		local close_button: ImageButton = screen.Index.Header.CloseButton
		local closeSignal = close_button.Activated:Connect(function(a0: InputObject, a1: number)
			Index.close()
		end)
		global_maid:GiveTask(closeSignal)
	end

	do
		local bossesButton: ImageButton = screen.Index.SideButtons.Bosses
		bossesButton.Activated:Connect(function(a0: InputObject, a1: number)
			Index.cleanSlots()
			for _, pet in pairs(petBosses) do
				Index.createSlot(pet, true)
			end
		end)
		local petsButton: ImageButton = screen.Index.SideButtons.Pets
		petsButton.Activated:Connect(function(a0: InputObject, a1: number)
			Index.cleanSlots()
			Index.createPets()
		end)
	end

	Index.createPets()
end

function Index.createPets()
	local pets = _G["pets_registry"]
	for _, pet in pairs(pets) do
		Index.createSlot(pet)
	end
end

function Index.cleanSlots()
	slots_maid:DoCleaning()
end

function Index.close()
	slotNum = 0
	screen.Index.Visible = false
	Index.cleanSlots()
	global_maid:DoCleaning()
	petDetails.close()
	_G["petToFight"] = nil
	_G["bossToFight"] = nil
end

function Index.createViewport(parentSLot, petName: PetTypes.petNames)
	-- local parentSLot = screen.Index.Slots.Scroller.Slot

	local createPivot = function()
		local modelCFrame = CFrame.new(1, 1, 0)
		local rad = 120
		local zrad = 0

		if petData[petName] then
			if petData[petName].radPivot then
				rad = petData[petName].radPivot
			elseif petData[petName].ZradPivot then
				zrad = petData[petName].ZradPivot
			end
		elseif petBosses[petName] then
			if petBosses[petName].radPivot and petBosses[petName].ZradPivot then
				rad = petBosses[petName].radPivot
				zrad = petBosses[petName].ZradPivot
			elseif petBosses[petName].radPivot then
				rad = petBosses[petName].radPivot
			elseif petBosses[petName].ZradPivot then
				zrad = petBosses[petName].ZradPivot
			end
		end
		return modelCFrame * CFrame.Angles(0, math.rad(rad), math.rad(zrad))
	end
	local cameraRotation = function(modelCFrame, modelSize)
		local petName = petName :: PetTypes.petNames

		local distance = math.max(modelSize.X, modelSize.Y, modelSize.Z)
			* (
				if petData[petName]
					then petData[petName].CameraDistanceFactor
					elseif petBosses[petName] then petBosses[petName].CameraDistanceFactor
					else 1.2
			)

		return CFrame.new(1, 1, 0)
			* CFrame.new(0, 0, -distance)
			* CFrame.Angles(math.rad(180), math.rad(0), math.rad(180))
	end
	local placeholder: ImageLabel = parentSLot.PlaceHolder

	local Viewport = Instance.new("ViewportFrame", parentSLot)
	Viewport.BackgroundTransparency = 1
	Viewport.AnchorPoint = placeholder.AnchorPoint
	Viewport.Size = placeholder.Size
	Viewport.Position = placeholder.Position

	local ImageButton = Instance.new("ImageButton", parentSLot)
	ImageButton.Name = "Button"
	ImageButton.BackgroundTransparency = 1
	ImageButton.AnchorPoint = placeholder.AnchorPoint
	ImageButton.Size = placeholder.Size
	ImageButton.Position = placeholder.Position
	ImageButton.Image = ""
	--local player = game.Players.LocalPlayer; local PlayerGui = player:WaitForChild("PlayerGui");  print("PlayerGui", PlayerGui); local Rhino = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Index"):WaitForChild("Slots"):WaitForChild("Scroller"):WaitForChild("Slot1"):WaitForChild("ViewportFrame"):WaitForChild("Rhino"); Rhino:PivotTo(Rhino.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(90), 0))
	local Camera = Instance.new("Camera", Viewport)
	Camera.CFrame = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)) * CFrame.Angles(0, math.rad(90), 0)
	Viewport.CurrentCamera = Camera

	-- model to copy
	local item = petTemplates:WaitForChild(petName)
	local itemClone: Model = item:Clone()
	itemClone.Parent = Viewport

	local modelCFrame, modelSize = itemClone:GetBoundingBox()
	itemClone:PivotTo(createPivot(modelCFrame, modelSize))

	Camera.CFrame = cameraRotation(modelCFrame, modelSize)
	Camera.FieldOfView = 70

	parentSLot.PlaceHolder:Destroy()
end

function Index.createSlot(data: PetTypes.PetData, isBoss: boolean?)
	slotNum += 1
	local local_maid = Maid.new()
	local new_slot = screen.Index.Slots.Scroller.Slot:Clone()
	new_slot.Name = "Slot" .. slotNum
	new_slot.Txt.Text = data.petName

	local createUIStroke = function(rarity)
		if currentUiStroke then
			currentUiStroke:Destroy()
		end
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.new(255, 255, 255)
		stroke.Thickness = 4
		stroke.Parent = new_slot

		local gradient = Instance.new("UIGradient")

		local color_seq = ColorSequence.new(clientUtils.getRarityColorSecuence(rarity))
		--[[
		 [1] = 0 0.862745 0.862745 0.862745 0 ,
                    [2] = 1 0.705882 0.705882 0.705882 0 
		]]
		gradient.Color = color_seq

		gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0),
		})
		gradient.Rotation = 180
		gradient.Offset = Vector2.new(0, 0)
		gradient.Parent = stroke
		currentUiStroke = stroke
	end

	-- TODO: [Epic Bosses] think if there's a cleanest way for handling this
	local rarety = utils.getPetRarity(data.petName) or (petBosses[data.petName] and petBosses[data.petName].rarity)
	local rariry_camelCase = stringUtils.toUpperCamelCase(rarety)

	if not isBoss and data == _G["petToFight"] then
		petDetails.open()
		petDetails.setPetData(data)
		createUIStroke(rariry_camelCase)
	end
	if data == _G["bossToFight"] then
		createUIStroke(rariry_camelCase)
	end
	if isBoss and data == _G["bossToFight"] then
		FightButton.open()
	end

	new_slot.Rarity.Text = rariry_camelCase

	local UIGradient = new_slot.Rarity.UIGradient
	UIGradient.Rotation = 90
	UIGradient.Offset = Vector2.new(0, 0)
	UIGradient.Color = ColorSequence.new(clientUtils.getRarityColorSecuence(rariry_camelCase))
	UIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 0),
	})

	Index.createViewport(new_slot, data.petName)
	local buy = new_slot.Button
	local con = slotButtonHandler.setupButtonActivated(buy, data, isBoss or false, createUIStroke, rariry_camelCase)

	new_slot.Parent = screen.Index.Slots.Scroller
	new_slot.Visible = true

	local_maid:GiveTask(new_slot)
	local_maid:GiveTask(con)
	slots_maid:GiveTask(local_maid)
end

function Index.isOpen()
	return screen.Index.Visible
end

return Index
