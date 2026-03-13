local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local stringUtils = require(ReplicatedStorage.utils.stringUtils)
local player = Players.LocalPlayer

local PlayerGui = player:WaitForChild("PlayerGui")

local screen = PlayerGui:WaitForChild("ScreenGui")

local ExclusiveShop = {}

function ExclusiveShop.open(name: string?)
	screen.ExclusiveShop.Visible = true
end

function ExclusiveShop.setPetData(petData: PetTypes.PetData)
	screen.ExclusiveShop.PetDetails.PetName.Text = petData.petName
	screen.ExclusiveShop.PetDetails.Rarity.Text = stringUtils.toUpperCamelCase(petData.rarity)
end

function ExclusiveShop.close()
	screen.ExclusiveShop.Visible = false
end

return ExclusiveShop
