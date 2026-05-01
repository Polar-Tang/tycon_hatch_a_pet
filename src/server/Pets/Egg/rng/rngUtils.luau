local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetTypes = require(ReplicatedStorage.Pets.PetTypes)

type rarity = PetTypes.rarity

local rngUtils = {}

rngUtils.DropPercentages = {
	common = 70,
	rare = 90,
	epic = 95.5,
	legendary = 99.99,
}

local orderedRarities: { { rarity: rarity, maxPercentage: number } } = {
	{ rarity = "common", maxPercentage = rngUtils.DropPercentages.common },
	{ rarity = "rare", maxPercentage = rngUtils.DropPercentages.rare },
	{ rarity = "epic", maxPercentage = rngUtils.DropPercentages.epic },
	{ rarity = "legendary", maxPercentage = rngUtils.DropPercentages.legendary },
}

function rngUtils.getDrop()
	local drop = math.random(0, 99999)
	local percentage = drop / 1000
	return percentage
end

function rngUtils.getRarity(percentage: number): rarity
	for _, rarityInfo in ipairs(orderedRarities) do
		if percentage <= rarityInfo.maxPercentage then
			return rarityInfo.rarity
		end
	end

	return "legendary"
end

return rngUtils