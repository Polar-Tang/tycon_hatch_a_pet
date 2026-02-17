local itemType = require(script.Parent.ItemType).Item

local PlayerInventory = {}
-- PlayerQuestHandler.lua
PlayerInventory.__index = PlayerInventory
type PlayerData = {
	player: Player,
	gold: number,
	items: item,
}

function PlayerInventory.new(player: Player, gold: number, inventory: { itemType }): PlayerData
	if not gold or not inventory then
		warn("Player inventory intiliaziated as zero")
	end
	local self = setmetatable({}, PlayerInventory)
	self.gold = gold or 0
	self.inventory = inventory or {}
	return self
end

function PlayerInventory:AddItem(newItem: itemType, key: string): PlayerData | nil
	--print("New item ", newItem)
	local index = key or newItem.itemId
	if not newItem then
		warn("No item to add to the player's inventory")
		return
	end
	self.inventory[index] = newItem
	return self
end

function PlayerInventory:RemoveItem(ItemId: string): PlayerData | nil
	if not ItemId then
		warn("No item name")
		return
	end

	local itemToEliminate = self.inventory[ItemId]
	if not itemToEliminate then
		warn("The item to eliminate was not found")
		return
	end
	self.inventory[ItemId] = nil
	return self
end

function PlayerInventory:IncreaseMoney(amount): IntValue
	self.gold = self.gold + amount
	return self.gold
end

function PlayerInventory:DecreaseMoney(amount): IntValue
	self.gold = self.gold - amount
	if self.gold < 0 then
		warn("The player's money is negative")
		return
	end
	return self.gold
end
function PlayerInventory:findItem(itemId)
	print("self.inventory ", self.inventory)
	return self.inventory[itemId]
end

function PlayerInventory:InvokePet(pet: Model)
	self.invokedPet = pet
end

function PlayerInventory:SaveBackPack(backpack)
	self.playerBackpack = backpack
end

return PlayerInventory
