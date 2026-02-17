-- AbstractItem.lua
local AbstractItem = {}
AbstractItem.__index = AbstractItem
local HttpService = game:GetService("HttpService")

local AspectNames = {
	XP = "Experience Seed",
	DMG = "Gem Of Power",
	speed = "Speed Poison",
	stamina = "Enchanted Food",
	poisonHealth = "Poison Health",
}
local imageMap = require(script.Parent.ImageMap)
local Aspects = script.Parent.Aspect

function AbstractItem.new(name, rarity, category, dropId)
	if getmetatable(AbstractItem) == AbstractItem then
		error("Cannot instantiate abstract class 'AbstractItem' directly.")
	end
	--print("name, rarity, category, dropId ", name, rarity, category, dropId)

	local self = setmetatable({}, AbstractItem)
	self.aspectName = AspectNames[name]
	local id = HttpService:GenerateGUID(false)

	self.itemId = id
	self.name = name
	self.rarity = rarity
	self.image = imageMap[name][rarity]
	self.category = category
	self.dropId = dropId

	return self
end

function AbstractItem:GetItem()
	return self
end

-- Abstract: must be implemented
function AbstractItem:Use(target, player)
	error("Abstract method 'Use' must be implemented by subclass.")
end

return AbstractItem
