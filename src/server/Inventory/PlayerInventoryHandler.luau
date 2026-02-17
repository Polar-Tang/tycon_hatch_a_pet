local PlayerInventory = require(script.Parent.PlayerInventory)

local PlayerInventoryHandler = {}

PlayerInventoryHandler.__index = PlayerInventoryHandler

PlayerInventoryHandler._players = {}
local item = require(script.Parent.ItemType).Item

type PlayerData = PlayerInventoryType.PlayerData

function PlayerInventoryHandler:InitPlayer(player, inventory)
	local gold = inventory.gold or 0
	local items = inventory.inventory or {}
	local handler = PlayerInventory.new(player, gold, items)
	self._players[player.UserId] = handler
end

-- accept a player
-- Get the player handler
-- return the particular player handler
function PlayerInventoryHandler:GetHandler(player): PlayerData
	local thePlayer = self._players[player.UserId]
	return self._players[player.UserId]
end

-- accept a player
-- remove the player instance
-- return nil
function PlayerInventoryHandler:RemovePlayer(player)
	self._players[player.UserId] = nil
end

return PlayerInventoryHandler
