local itemType = require(script.Parent.ItemType).Item

local PlayerInventory = {}
-- PlayerQuestHandler.lua
PlayerInventory.__index = PlayerInventory
type PlayerData = {
	player: Player,
	cash: number,
	items: item,
}

function PlayerInventory.new(data): PlayerData
	local cash = data.cash
	local inventory = data.inventory

	if not cash or not inventory then
		warn("Player inventory intiliaziated as zero")
	end
	local self = setmetatable({}, PlayerInventory)
	self.cash = cash or 0
	self.inventory = inventory or {}
	self.lastRegisterTime = os.time()

	return self
end

function PlayerInventory:getRegisterTime()
	return self.lastRegisterTime
end

function PlayerInventory:setRegisterTime()
	self.lastRegisterTime = os.time()
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
	-- print("self.cash ", self.cash)
	self.cash = self.cash + amount
	return self.cash
end

function PlayerInventory:DecreaseMoney(amount): IntValue?
	self.cash = self.cash - amount
	if self.cash < 0 then
		warn("The player's money is negative")
		return
	end
	return self.cash
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

local PlayerInventoryHandler = {}

PlayerInventoryHandler.__index = PlayerInventoryHandler

PlayerInventoryHandler._players = {}

function PlayerInventoryHandler:InitPlayer(player, data)
	local handler = PlayerInventory.new(data)
	self._players[player.UserId] = handler
end

-- accept a player
-- Get the player handler
-- return the particular player handler
function PlayerInventoryHandler:GetHandler(player): PlayerData
	return self._players[player.UserId]
end

-- accept a player
-- remove the player instance
-- return nil
function PlayerInventoryHandler:RemovePlayer(player)
	self._players[player.UserId] = nil
end

return PlayerInventoryHandler
