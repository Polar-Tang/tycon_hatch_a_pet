local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local clientUtils = require(StarterPlayer.StarterPlayerScripts.utils.clientUtils)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local stringUtils = require(ReplicatedStorage.utils.stringUtils)
local player = Players.LocalPlayer

local PlayerGui = player:WaitForChild("PlayerGui")

local screen = PlayerGui:WaitForChild("ScreenGui")

-- One detail sign per team slot; the team caps at three pets.
local MAX_DETAILS = 3

-- Fight-order hint shown on each sign. Index 1 is the pet that attacks first.
local ORDER_LABELS = { "goes first", "goes second", "goes third" }

local PetScreen = {}

-- The team currently shown, in order. We keep the whole petData (not just ids)
-- because every sign's name/label depends on its position, so the entire stack
-- is re-rendered after any add/remove.
local stack: { PetTypes.PetData } = {}

-- `PetScreen.PetDetails` is the container; its child `PetDetails` is the hidden
-- prototype every stacked sign is cloned from.
local function getContainer(): Frame
	return screen.PetScreen.PetDetails
end

local function getTemplate(): Frame
	return getContainer().PetDetails
end

-- Fills a single sign with one pet's info and its fight-order hint.
local function fillSign(sign: Instance, petData: PetTypes.PetData, orderText: string)
	sign.PetName.Text = petData.petName

	local rarityText: TextLabel = sign.Rarity
	local rariry_camelCase = stringUtils.toUpperCamelCase(petData.rarity)
	rarityText.Text = rariry_camelCase

	local UIGradient = rarityText:FindFirstChild("UIGradient")
	if UIGradient then
		UIGradient.Rotation = 90
		UIGradient.Offset = Vector2.new(0, 0)
		UIGradient.Color = ColorSequence.new(clientUtils.getRarityColorSecuence(rariry_camelCase))
		UIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0),
		})
	end

	sign.Description.Text =
		`This {string.lower(petData.petName)} of level {petData.petLvl} has {petData.petStats.Health} points of health and {petData.petStats.Melee} of melee`

	-- The sign may carry an "Order" label for the "goes first/second/..." hint.
	local orderLabel = sign:FindFirstChild("Order")
	if orderLabel and orderLabel:IsA("TextLabel") then
		orderLabel.Text = orderText
	end
end

-- Rebuilds every sign from `stack`. Each clone is named `PetDetailsN` so the
-- container's layout sorts them alphabetically into fight order.
local function renderStack()
	local container = getContainer()
	local template = getTemplate()
	template.Visible = false

	-- Only clear our own previously-rendered clones (PetDetails1, PetDetails2, ...),
	-- leaving the prototype and any decorative siblings in place.
	for _, child in ipairs(container:GetChildren()) do
		if child ~= template and child.Name:match("^PetDetails%d+$") then
			child:Destroy()
		end
	end

	for index, petData in ipairs(stack) do
		local sign = template:Clone()
		sign.Name = "PetDetails" .. index
		fillSign(sign, petData, ORDER_LABELS[index] or "")
		sign.Visible = true
		sign.Parent = container
	end
end

function PetScreen.open(name: string?)
	screen.PetScreen.Visible = true
	getContainer().Visible = true

end

--[[
	Adds a pet to the detail stack and re-renders the order labels. Idempotent
	(the same pet won't stack twice) and capped at MAX_DETAILS.
]]
function PetScreen.addPet(petData: PetTypes.PetData)
	for _, existing in ipairs(stack) do
		if existing.petId == petData.petId then
			return
		end
	end
	if #stack >= MAX_DETAILS then
		return
	end
	table.insert(stack, petData)
	renderStack()
end

-- Removes a pet's sign (by id) and re-renders so the order labels stay contiguous.
function PetScreen.removePet(petId: string)
	for index, existing in ipairs(stack) do
		if existing.petId == petId then
			table.remove(stack, index)
			break
		end
	end
	renderStack()
end

-- Empties the stack (e.g. when the index closes).
function PetScreen.clear()
	table.clear(stack)
	renderStack()
end

function PetScreen.close()
	PetScreen.clear()
	screen.PetScreen.Visible = false
end

return PetScreen
