local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local screenGui = PlayerGui:WaitForChild("ScreenGui")

local bottomLeft = {}

bottomLeft.SetMoney = function(total: number)
	screenGui.BottomLeft.CashAmount.Text = MoneyLib.HandleMoney(math.round(total))
end

return bottomLeft
