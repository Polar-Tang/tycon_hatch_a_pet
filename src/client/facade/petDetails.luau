local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local clientUtils = require(StarterPlayer.StarterPlayerScripts.utils.clientUtils)
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
	local petScreen = screen.PetScreen
	local PetDetails = petScreen.PetDetails
	PetDetails.Visible = true
	PetDetails.PetName.Text = petData.petName
	local rarityText: TextLabel = screen.PetScreen.PetDetails.Rarity
	local rariry_camelCase = stringUtils.toUpperCamelCase(petData.rarity)
	rarityText.Text = rariry_camelCase

	local UIGradient = rarityText:FindFirstChild("UIGradient")

	UIGradient.Rotation = 90
	UIGradient.Offset = Vector2.new(0, 0)

	UIGradient.Color = ColorSequence.new(clientUtils.getRarityColorSecuence(rariry_camelCase))

	UIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 0),
	})
	screen.PetScreen.PetDetails.Description.Text =
		`This {string.lower(petData.petName)} of level {petData.petLvl} has {petData.petStats.Health} points of health and {petData.petStats.Melee} of melee`
end

function PetScreen.close()
	screen.PetScreen.Visible = false
end

return PetScreen
