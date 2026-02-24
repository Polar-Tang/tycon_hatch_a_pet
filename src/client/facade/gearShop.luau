local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local itemTypes = require(script.Parent.itemTypes)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)
local player = Players.LocalPlayer

local PlayerGui = player:WaitForChild("PlayerGui")

local screen = PlayerGui:WaitForChild("ScreenGui")

local gearShop = {}

local global_maid = Maid.new()
local itemNum = 0

function gearShop.changeTitle(name: string)
	screen.GearShop.Header.Txt.Text = name
end

function gearShop.isDifferentShop(name: string)
	return screen.GearShop.Header.Txt.Text == name
end

function gearShop.open(name: string?)
	screen.GearShop.Visible = true

	if name then
		gearShop.changeTitle(name)
	end
	do
		local close_button: ImageButton = screen.GearShop.Header.CloseButton
		local closeSignal = close_button.Activated:Connect(function(a0: InputObject, a1: number)
			gearShop.close()
		end)
		global_maid:GiveTask(closeSignal)
	end
end

function gearShop.close()
	itemNum = 0
	screen.GearShop.Visible = false
	global_maid:DoCleaning()
end

function gearShop.createViewport(parentSLot, data: itemTypes.itemData)
	-- local parentSLot = screen.GearShop.Slots.Scroller.Slot

	local Viewport = Instance.new("ViewportFrame", parentSLot)
	Viewport.BackgroundTransparency = 1
	Viewport.AnchorPoint = Vector2.new(0, 0.5)
	Viewport.Size = UDim2.new(0.2, 0, 0.795, 0)
	Viewport.Position = UDim2.new(0.024, 0, 0.5, 0)

	local Camera = Instance.new("Camera", Viewport)
	Camera.CFrame = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))
	Viewport.CurrentCamera = Camera
	local item = data.template
	-- model to copy

	local itemClone: Model = item:Clone()

	itemClone.Parent = Viewport

	local modelCFrame, modelSize = itemClone:GetBoundingBox()
	itemClone:PivotTo(data.createPivot(modelCFrame, modelSize))

	if data.cameraRotation then
		Camera.CFrame = data.cameraRotation(modelCFrame, modelSize)
	end

	Camera.FieldOfView = 70

	parentSLot.PlaceHolder:Destroy()
end

function gearShop.createItem(data: itemTypes.itemData, cb: () -> ())
	itemNum += 1
	local local_maid = Maid.new()
	local new_slot = screen.GearShop.Slots.Scroller.Slot:Clone()
	new_slot.Name = "Slot" .. itemNum
	new_slot.Details.GearDescription.Text = data.description

	new_slot.Details.GearName.Text = data.title

	-- new_slot.PlaceHolder.Image = data.image
	gearShop.createViewport(new_slot, data)
	new_slot.Visible = true
	new_slot.Parent = screen.GearShop.Slots.Scroller
	local buy_button = new_slot.BuyButton
	local con = buy_button.Activated:Connect(function(a0: InputObject, a1: number)
		cb()
	end)

	if data.price == 0 then
		new_slot.BuyButton.Price.Text = "Get Free"
		buy_button.Txt.Text = "Free"
	else
		new_slot.BuyButton.Price.Text = MoneyLib.HandleMoney(data.price)
	end

	local_maid:GiveTask(new_slot)
	local_maid:GiveTask(con)
	global_maid:GiveTask(local_maid)
end

function gearShop.isOpen()
	return screen.GearShop.Visible
end

return gearShop
