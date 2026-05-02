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

function rngUtils.getDrop(bias: number?): number
	local luck = bias or 1
	local L = math.clamp(luck, 1, 5)

    local u = math.random()
    -- core idea
    local skewed = u ^ (1 / L)

    return skewed * 100
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