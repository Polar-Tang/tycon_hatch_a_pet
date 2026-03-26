local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local PlayerInventory = {}
-- PlayerQuestHandler.lua
PlayerInventory.__index = PlayerInventory

export type InventoryItem = {
	itemId: string,
	-- add other item fields here
	[string]: any,
}

export type PlayerData = {
	-- Core state
	player: Player,
	cash: number,

	lastRegisterTime: number,

	-- Internal runtime state
	_timer: number,
	_last_timer: number,
	_maid: any, -- Maid

	-- ===== Methods =====

	getRegisterTime: (self: PlayerData) -> number,
	setRegisterTime: (self: PlayerData) -> (),

	Init: (self: PlayerData, money_cb: (number) -> () -> number) -> (),
	Destoy: (self: PlayerData) -> (),
}

export type PlayerInventoryInit = {
	player: Player,
	cash: number?,
}

function PlayerInventory.new(data: PlayerInventoryInit): PlayerData
	local cash = data.cash

	if not cash then
		warn("Player inventory intiliaziated as zero")
	end
	local self = setmetatable({}, PlayerInventory)
	self.cash = cash or 0
	self.player = data.player

	self.lastRegisterTime = os.time()

	self._maid = Maid.new()
	return self
end

function PlayerInventory:getRegisterTime()
	return self.lastRegisterTime
end

function PlayerInventory:setRegisterTime()
	self.lastRegisterTime = os.time()
end

function PlayerInventory:Init(money_cb: () -> number)
	local thread
	thread = function()
		task.delay(1, function()
			local moneyGenerated = money_cb()
			-- the player may log out and the thread is still alive
			if not self or not self.cash then
				return
			end

			self.cash += moneyGenerated
			thread()
		end)
	end

	thread()
end

function PlayerInventory:Destoy()
	self._maid:DoCleaning()
end

function PlayerInventory:IncreaseMoney(amount): number
	self.cash = self.cash + amount
	game.ReplicatedStorage.RemoteEvents.Amount:FireClient(self.player, {
		amount = self.cash,
	})
	return self.cash
end

function PlayerInventory:DecreaseMoney(amount): IntValue?
	local newMoney = self.cash - amount
	if newMoney < 0 then
		warn("The player's money is negative")
		return
	end
	self.cash = newMoney
	game.ReplicatedStorage.RemoteEvents.Amount:FireClient(self.player, {
		amount = self.cash,
	})
	return self.cash
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
