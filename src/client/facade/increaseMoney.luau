local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
return function(amount)
	PlayerGui.ScreenGui.BottomLeft.CashAmount.Text = "$" .. amount
end
