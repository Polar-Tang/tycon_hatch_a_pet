local ReplicatedStorage = game:GetService("ReplicatedStorage")
local petClickedEvent = ReplicatedStorage.RemoteEvents.PetClicked

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

petClickedEvent.OnClientEvent:Connect(function(petStats)
	if not PlayerGui:WaitForChild("ScreenGui").BottomLeft.CashAmount.Visible then
		PlayerGui:WaitForChild("ScreenGui").BottomLeft.CashAmount.Visible = true
		PlayerGui:WaitForChild("ScreenGui").BottomLeft.FriendBoost.Visible = true
	end
	print("this are the pet stats ", petStats)
end)
