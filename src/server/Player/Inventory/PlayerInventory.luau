local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerBinder = require(ReplicatedStorage.Nevermore.Custom.playerBinder.src.Server.PlayerBinder)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local serverTypes = require(script.Parent.Parent.Parent.types.serverTypes)
local PlayerInventory = {}
-- PlayerQuestHandler.lua
PlayerInventory.__index = PlayerInventory

function PlayerInventory.new(data: serverTypes.PlayerInventoryInit): serverTypes.PlayerInventory
	local cash = data.cash

	if not cash then
		warn("Player inventory intiliaziated as zero")
	end
	local self = setmetatable({}, PlayerInventory)
	self.cash = cash or 0
	self.player = data.player
	self.items = data.items

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

function PlayerInventory:Init(fakeServiceBag, money_cb: () -> number)
	local increaseMoneyFunc
	increaseMoneyFunc = function()
		self:setRegisterTime()
		local moneyGenerated = money_cb()
		self.cash += moneyGenerated
		local increaseMoneyTask = task.delay(1, increaseMoneyFunc)
		self._maid._cleanup = increaseMoneyTask
	end
	increaseMoneyFunc()
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


return PlayerBinder.new(PlayerInventory) :: serverTypes.PlayerBinder<serverTypes.PlayerInventory>
