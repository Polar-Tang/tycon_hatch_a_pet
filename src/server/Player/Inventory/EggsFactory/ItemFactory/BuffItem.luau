-- BuffItem.lua
local AbstractItem = require(script.Parent.AbstractItem)
local BuffItem = setmetatable({}, AbstractItem)
BuffItem.__index = BuffItem
local Aspects = script.Parent.Aspect

local durationTable = {
	common = 60,
	uncommon = 120,
	rare = 300,
	epic = 600,
}

function BuffItem.new(name, rarity, dropId)
	local self = setmetatable(AbstractItem.new(name, rarity, "buff", dropId), BuffItem)
	self.duration = durationTable[rarity]
	local module = require(Aspects:FindFirstChild(name))
	self.description = module.createDesc(self)

	return self
end

function BuffItem:Use(target, player)
	local name = self.name
	local module = require(Aspects:FindFirstChild(name))
	self.type = "buff"
	print("target ", target)
	return module.Calculate(target, self.rarity, self.duration, player)
	--module.func()
end

function BuffItem:Improve(currentData)
	local name = self.name

	local module = require(Aspects:FindFirstChild(name))
	if module.calc then
		return module.calc(currentData, self.rarity)
	end
end

return BuffItem
