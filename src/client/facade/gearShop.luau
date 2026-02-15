local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local screen = PlayerGui:WaitForChild("ScreenGui")

local gearShop = {}

function gearShop.open()
	screen.GearShop.Visible = true
end

function gearShop.close()
	screen.GearShop.Visible = false
end

export type itemData = {
	title: string,
	image: string,
	description: string,
	price: number,
}

function gearShop.createItem(data: itemData)
	local slot = screen.GearShop.Slots.Scroller.Slot:Clone()
	slot.Details.GearDescription.Text = data.description

	slot.Details.GearName.Text = data.title

	slot.BuyButton.Price.Text = MoneyLib.HandleMoney(data.price)
	slot.PlaceHolder.Image = data.image
	slot.Visible = true
end

return gearShop
