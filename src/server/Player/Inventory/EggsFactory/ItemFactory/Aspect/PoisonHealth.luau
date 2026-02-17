local Aspect = script.Name
local multipliers = require(script.Parent.multipliers)[Aspect]

local poisonHealth = {}

function poisonHealth.Calculate(target, rarity, player)
	local data = target.Data
	local newH = data.health.Value + multipliers[rarity]
	if newH > data.maxHealth then
		newH = data.maxHealth
	end
	print("newH ", newH, data.health.Value)
	print("target ", target)
	print("data ", data)
	local HU: Humanoid = data.humanoid
	local maxH = HU.MaxHealth
	data.healthListener:Fire(newH, maxH)
	return { health = newH }
end

function poisonHealth.calc(data, rarity)
	local health = data.health
	local newH = data.health + multipliers[rarity]
	local maxH = data.petStats["stamina"] * 32 + 128
	if newH > maxH then
		newH = maxH
	end
	return { health = newH }
end

function poisonHealth.createDesc(itemData)
	return string.format(
		"This %s %s healths the pet by %d",
		itemData.rarity,
		itemData.aspectName,
		multipliers[itemData.rarity]
	)
end
return poisonHealth
