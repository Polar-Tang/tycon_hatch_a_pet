local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)

local bottomLeft = {}

bottomLeft.SetMoney = function(total: number)
	local player = Players.LocalPlayer
	local PlayerGui = player:WaitForChild("PlayerGui")
	local screenGui = PlayerGui:WaitForChild("ScreenGui")

	local BottomLeft = screenGui:WaitForChild("BottomLeft")
	BottomLeft.CashAmount.Text = MoneyLib.HandleMoney(math.round(total))
end

return bottomLeft
