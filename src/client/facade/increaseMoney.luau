local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
return function(amount)
	local screenGui = PlayerGui:WaitForChild("ScreenGui")

	print("new amount ", amount)
	if not screenGui.BottomLeft.Visible then
		screenGui.BottomLeft.Visible = true	
		screenGui.BottomLeft.CashAmount.Visible = true
		screenGui.BottomLeft.FriendBoost.Visible = true
	end
	screenGui.BottomLeft.CashAmount.Text = MoneyLib.HandleMoney(amount)
end
