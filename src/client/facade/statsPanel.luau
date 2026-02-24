local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local screen = PlayerGui:WaitForChild("ScreenGui")

local module = {}

module.open = function()
	if not screen.Stats.Visible then
		screen.Stats.Visible = true
	end
	screen.Stats.Position = UDim2.fromScale(0.5, 0.5)
end

module.getCloseButton = function()
	return screen.Stats.Header.CloseButton
end

module.getSellButton = function()
	return screen.Stats.Header.SellButton
end

module.setPoints = function(points: number)
	screen.Stats.Header.Points.Text = "Points: " .. points
end

module.setMoneyPerSec = function(money: number)
	screen.Stats.Holder.Production.Text = MoneyLib.HandleMoney(money) .. "/s"
end

module.getScroller = function()
	return screen.Stats.Holder.Upgrades.Scroller
end
return module
