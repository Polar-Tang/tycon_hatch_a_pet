local ItemFactory = require(script.Parent.ItemFactory.ItemFactory)
local InventoryHandler = require(script.Parent.PlayerInventoryHandler)
local Event = game.ReplicatedStorage.Events
local NewItems: RemoteEvent = Event:WaitForChild("NewItems")
local ItemClient = {}

function ItemClient.destroyItems(player, ...)
	local PlayerInventory = InventoryHandler:GetHandler(player)
	local items = PlayerInventory.inventory
	local targets = { ... }
	--print("targets item ", targets)
	for _, invItem in pairs(items) do
		for _, targetItem in ipairs(targets) do
			if invItem.itemId == targetItem.itemId then
				invItem.destroy = true
				PlayerInventory:RemoveItem(targetItem.itemId)
				break
			end
		end
	end
	NewItems:FireClient(player, { items = items })
end
local rarityMap = {
	["common"] = 1,
	["uncommon"] = 2,
	["rare"] = 3,
	["epic"] = 4,
}

local rarityArr = {
	"common",
	"uncommon",
	"rare",
	"epic",
}

function ItemClient.createItem(data)
	local itemData = data
	itemData.type = data.type or data.category
	--print("itemData ", itemData)

	return ItemFactory.Create(data)
end

function ItemClient.mixture(player, item1, item2)
	if not item1 or not item2 then
		return warn("No items")
	end
	local isItemEquivalent = item1.rarity == item2.rarity and string.lower(item1.name) == string.lower(item2.name)
	local isTheSameItem = item1.itemId == item2.itemId

	if not isItemEquivalent or isTheSameItem then
		return warn("isItemEquivalent ", isItemEquivalent, "isTheSameItem ", isTheSameItem)
	end
	local rarityLVL = rarityMap[item1.rarity] + 1
	if rarityLVL > 4 then
		return warn("Items cannot be more than epic")
	end
	local newItem = {
		type = item2.category,
		name = item2.name,
		rarity = rarityArr[rarityLVL],
	}
	local newItem = ItemFactory.Create(newItem)
	local PlayerInventory = InventoryHandler:GetHandler(player)

	PlayerInventory:AddItem(newItem)

	ItemClient.destroyItems(player, item1, item2)
end

return ItemClient
