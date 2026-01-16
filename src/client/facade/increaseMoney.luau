local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
return function(amount)
	if not PlayerGui:WaitForChild("ScreenGui").BottomLeft.CashAmount.Visible then
	PlayerGui:WaitForChild("ScreenGui").BottomLeft.CashAmount.Visible = true
	end
	PlayerGui:WaitForChild("ScreenGui").BottomLeft.CashAmount.Text = MoneyLib.HandleMoney(amount)
end
