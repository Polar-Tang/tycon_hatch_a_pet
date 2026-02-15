local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)
local player = Players.LocalPlayer

local PlayerGui = player:WaitForChild("PlayerGui")

local screen = PlayerGui:WaitForChild("ScreenGui")

local gearShop = {}

local global_maid = Maid.new()

function gearShop.open()
	screen.GearShop.Visible = true

	do
		local close_button: ImageButton = screen.GearShop.Header.CloseButton
		local closeSignal = close_button.Activated:Connect(function(a0: InputObject, a1: number)
			gearShop.close()
		end)
		global_maid:GiveTask(closeSignal)
	end
end

function gearShop.close()
	screen.GearShop.Visible = false
	global_maid:DoCleaning()
end

export type itemData = {
	title: string,
	image: string,
	description: string,
	price: number,
	itemName: string,
}

function gearShop.createViewport(parentSLot, itemName: string)
	-- local parentSLot = screen.GearShop.Slots.Scroller.Slot

	local Viewport = Instance.new("ViewportFrame", parentSLot)
	Viewport.BackgroundTransparency = 1
	Viewport.AnchorPoint = Vector2.new(0, 0.5)
	Viewport.Size = UDim2.new(0.2, 0, 0.795, 0)
	Viewport.Position = UDim2.new(0.024, 0, 0.5, 0)

	local Camera = Instance.new("Camera", Viewport)
	Camera.CFrame = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))
	Viewport.CurrentCamera = Camera

	-- model to copy
	local speedCoil = game.ReplicatedStorage:WaitForChild("Items"):WaitForChild("SpeedCoil")
	local speedCoilClone: Model = speedCoil:Clone()

	speedCoilClone.Parent = Viewport

	local _, modelSize = speedCoilClone:GetBoundingBox()
	local modelCFrame = CFrame.new(1, 1, 0)
	speedCoilClone:PivotTo(modelCFrame * CFrame.Angles(0, math.rad(315), 0))

	local distance = math.max(modelSize.X, modelSize.Y, modelSize.Z) * 0.8

	Camera.CFrame = modelCFrame
		* CFrame.new(0, 0, -distance)
		* CFrame.Angles(math.rad(180), math.rad(350), math.rad(180))
	Camera.FieldOfView = 70

	parentSLot.PlaceHolder:Destroy()
end

local Items = ReplicatedStorage.RemoteEvents.ItemsEvent

function gearShop.createItem(data: itemData)
	local local_maid = Maid.new()

	local new_slot = screen.GearShop.Slots.Scroller.Slot:Clone()
	new_slot.Details.GearDescription.Text = data.description

	new_slot.Details.GearName.Text = data.title

	new_slot.BuyButton.Price.Text = MoneyLib.HandleMoney(data.price)
	-- new_slot.PlaceHolder.Image = data.image
	gearShop.createViewport(new_slot, data.itemName)
	new_slot.Visible = true
	new_slot.Parent = screen.GearShop.Slots.Scroller
	local buy_button: ImageButton = new_slot.BuyButton
	local con = buy_button.Activated:Connect(function(a0: InputObject, a1: number)
		Items:FireServer(data)
	end)
	local_maid:GiveTask(con)
	global_maid:GiveTask(local_maid)
end

return gearShop
