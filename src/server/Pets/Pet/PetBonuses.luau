local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local utils = require(ReplicatedStorage.utils.utils)
local serverTypes = require(ServerScriptService.types.serverTypes)
local module = {}

local rand = {
	["instant"] = 0,
	["common"] = math.random(10, 60),
	["uncommon"] = math.random(30, 120),
	["rare"] = math.random(60, 300),
}

export type bonusType = "passive" | "active"

module["Pig"] = {
	bonus = function(incomes: serverTypes.Income)
		local extraCoins = utils.getPercentage(incomes.inventory.cash, 10)

		incomes.ExtraCoinBoss.Value = incomes:_checkIncreases(extraCoins)
	end,
	passive = function(incomes: serverTypes.Income)
		incomes.CoinsFactor.Value += 2
	end,
	bonusType = "active",
	GetRandTime = function()
		return rand["common"]
	end,
}

module["Elephant"] = {
	bonus = function(incomes: serverTypes.Income)
		local elephantBoost = utils.bossCoins(incomes.inventory.cash) * 2
		incomes.DoubledCoin.Value = incomes:_checkIncreases(elephantBoost)
	end,
	bonusType = "active",

	GetRandTime = function()
		return rand["rare"]
	end,
}

module["Panda"] = {
	bonus = function(incomes: serverTypes.Income)
		incomes._slightlyIncreased.Value += 1
	end,
	destroy = function(incomes: serverTypes.Income)
		incomes._slightlyIncreased.Value -= 1
	end,
	bonusType = "passive",
	GetRandTime = function()
		return rand["instant"]
	end,
}

return module
