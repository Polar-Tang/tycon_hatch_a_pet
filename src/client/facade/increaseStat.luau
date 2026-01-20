local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetClicked = ReplicatedStorage.RemoteEvents.PetClicked

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

PetClicked.OnClientEvent:Connect(function(petStats)
	if not PlayerGui:WaitForChild("ScreenGui").Stats.Visible then
		PlayerGui:WaitForChild("ScreenGui").Stats.Visible = true
	end
	PlayerGui:WaitForChild("ScreenGui").Stats.Header.Points.Text = "Points: " .. petStats.avaiblePoints
end)
return{}