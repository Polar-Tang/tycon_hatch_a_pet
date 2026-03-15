local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local player = Players.LocalPlayer

local PlayerGui = player:WaitForChild("PlayerGui")

local screen = PlayerGui:WaitForChild("ScreenGui")

local IndexButton = {}

function IndexButton.getIndexButton(): ImageButton
	return screen.IndexButton
end

function IndexButton.rotate(rotation: number)
	screen.IndexButton.Rotation = rotation
end

return IndexButton
