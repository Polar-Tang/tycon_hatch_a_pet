local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetTypes = require(ReplicatedStorage.Pets.PetTypes)

type rarity = PetTypes.rarity
type classification = "Carnivore" | "Herbivore"

export type EggColorData = {
	rarity: rarity?,
	classification: classification?,
}

local EggsByColor: { [string]: EggColorData } = {
	white = {
		rarity = "common",
	},
	blue = {
		rarity = "rare",
	},
	purple = {
		rarity = "epic",
	},
	orange = {
		rarity = "legendary",
	},
	red = {
		classification = "Carnivore",
	},
	green = {
		classification = "Herbivore",
	},
}

return EggsByColor