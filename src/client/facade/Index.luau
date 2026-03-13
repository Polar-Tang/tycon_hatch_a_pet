local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local petTemplates = ReplicatedStorage.Pets.Templates

local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
local clientUtils = require(StarterPlayer.StarterPlayerScripts.utils.clientUtils)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local stringUtils = require(ReplicatedStorage.utils.stringUtils)
local player = Players.LocalPlayer

local PlayerGui = player:WaitForChild("PlayerGui")

local screen = PlayerGui:WaitForChild("ScreenGui")

local Index = {}

local global_maid = Maid.new()
local slotNum = 0

function Index.open()
	screen.Index.Visible = true

	do
		local close_button: ImageButton = screen.Index.Header.CloseButton
		local closeSignal = close_button.Activated:Connect(function(a0: InputObject, a1: number)
			Index.close()
		end)
		global_maid:GiveTask(closeSignal)
	end

	local pets = _G["pets_registry"]
	for _, pet in pairs(pets) do
		Index.createSlot(pet)
	end
end

function Index.close()
	slotNum = 0
	screen.Index.Visible = false
	global_maid:DoCleaning()
end

function Index.createViewport(parentSLot, data: PetTypes.PetData)
	-- local parentSLot = screen.Index.Slots.Scroller.Slot

	local createPivot = function()
		local modelCFrame = CFrame.new(1, 1, 0)

		return modelCFrame * CFrame.Angles(0, math.rad(120), 0)
	end
	local cameraRotation = function(modelCFrame, modelSize)
		local petName = data.petName :: PetTypes.petNames

		local distance = math.max(modelSize.X, modelSize.Y, modelSize.Z) * petData[petName].CameraDistanceFactor

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
	local item = petTemplates:WaitForChild(data.petName)
	local itemClone: Model = item:Clone()
	itemClone.Parent = Viewport

	local modelCFrame, modelSize = itemClone:GetBoundingBox()
	itemClone:PivotTo(createPivot(modelCFrame, modelSize))

	Camera.CFrame = cameraRotation(modelCFrame, modelSize)
	Camera.FieldOfView = 70

	parentSLot.PlaceHolder:Destroy()
end

function Index.createSlot(data: PetTypes.PetData)
	slotNum += 1
	local local_maid = Maid.new()
	local new_slot = screen.Index.Slots.Scroller.Slot:Clone()
	new_slot.Name = "Slot" .. slotNum
	new_slot.Txt.Text = data.petName

	local rariry_camelCase = stringUtils.toUpperCamelCase(data.rarity)
	new_slot.Rarity.Text = rariry_camelCase
	local UIGradient = new_slot.Rarity.UIGradient

	UIGradient.Rotation = 90
	UIGradient.Offset = Vector2.new(0, 0)

	UIGradient.Color = ColorSequence.new(clientUtils.getRarityColorSecuence(rariry_camelCase))

	UIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 0),
	})
	-- new_slot.PlaceHolder.Image = data.image
	Index.createViewport(new_slot, data)
	new_slot.Visible = true
	new_slot.Parent = screen.Index.Slots.Scroller
	local buy = new_slot.Button
	local con = buy.Activated:Connect(function(a0: InputObject, a1: number)
		_G["petToFight"] = data
	end)

	local_maid:GiveTask(new_slot)
	local_maid:GiveTask(con)
	global_maid:GiveTask(local_maid)
end

function Index.isOpen()
	return screen.Index.Visible
end

return Index
