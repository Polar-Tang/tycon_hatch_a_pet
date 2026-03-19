local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local screen = PlayerGui:WaitForChild("ScreenGui")

local _maid = Maid.new()

local module = {}

local function applyHoverEffect(frame: Frame)
	local titleLabel = frame.Header.Title

	_maid:GiveTask(frame.MouseEnter:Connect(function()
		titleLabel.Visible = true
	end))

	_maid:GiveTask(frame.MouseLeave:Connect(function()
		titleLabel.Visible = false
	end))
end

module.open = function()
	if not screen.Stats.Visible then
		screen.Stats.Visible = true
	end
	screen.Stats.Position = UDim2.fromScale(0.5, 0.5)
	applyHoverEffect(screen.Stats)
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

module.destroy = function()
	_maid:Destroy()
end

return module
