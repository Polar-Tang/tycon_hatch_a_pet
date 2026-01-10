local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
return function(amount)
	PlayerGui:WaitForChild("ScreenGui").BottomLeft.CashAmount.Text = "$" .. amount
end
