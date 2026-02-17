-- ConsumableItem.lua
local AbstractItem = require(script.Parent.AbstractItem)
local Aspects = script.Parent.Aspect
local ConsumableItem = setmetatable({}, AbstractItem)
ConsumableItem.__index = ConsumableItem

function ConsumableItem.new(name, rarity, dropId)
	local self = setmetatable(AbstractItem.new(name, rarity, "consumable", dropId), ConsumableItem)
	self.used = false
	local module = require(Aspects:FindFirstChild(name))
	self.description = module.createDesc(self)
	return self
end

function ConsumableItem:Use(target, player)
	local name = self.name
	local module = require(Aspects:FindFirstChild(name))
	self.type = "consumable"
	return module.Calculate(target, self.rarity, player)
end

function ConsumableItem:Improve(currentData)
	local name = self.name

	local module = require(Aspects:FindFirstChild(name))
	if module.calc then
		return module.calc(currentData, self.rarity)
	end
end

return ConsumableItem
