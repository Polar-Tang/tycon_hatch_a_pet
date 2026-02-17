-- ItemFactory.lua
local BuffItem = require(script.Parent.BuffItem)
local ConsumableItem = require(script.Parent.ConsumableItem)

local ItemFactory = {}

function ItemFactory.Create(itemData)
	local itemType = itemData.type
	local name = itemData.name
	local rarity = itemData.rarity
	local dropId = itemData.dropId

	if itemType == "buff" then
		return BuffItem.new(name, rarity, dropId)
	elseif itemType == "consumable" then
		return ConsumableItem.new(name, rarity, dropId)
	else
		warn("Unknown item type: ", itemType)
	end
end

return ItemFactory
