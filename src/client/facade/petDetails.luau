local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local stringUtils = require(ReplicatedStorage.utils.stringUtils)
local player = Players.LocalPlayer

local PlayerGui = player:WaitForChild("PlayerGui")

local screen = PlayerGui:WaitForChild("ScreenGui")

local PetScreen = {}

function PetScreen.open(name: string?)
	screen.PetScreen.Visible = true
end

function PetScreen.setPetData(petData: PetTypes.PetData)
	screen.PetScreen.PetDetails.PetName.Text = petData.petName
	screen.PetScreen.PetDetails.Rarity.Text = stringUtils.toUpperCamelCase(petData.rarity)
end

function PetScreen.close()
	screen.PetScreen.Visible = false
end

return PetScreen
