local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetTypes = require(ReplicatedStorage.Pets.PetTypes)

type rarity = PetTypes.rarity
type petNames = PetTypes.petNames

local PetsByRarity: { [rarity]: { petNames } } = {
	common = {
		"Turtle",
		"Alpaca",
		-- "Elk",
		"Gorilla",
		"Fox",
	},

	rare = {
		-- "Bunny",
		"Elephant",
		"Panda",
		"Cat",
	},

	epic = {
		"Pig",
		"Giraffe",
		"Bull",
		-- "Parrot",
		"Dog",
		"Bear",
		"Wolf",
	},

	legendary = {
		"Rhino",
		"Lion",
		-- "Tiger",
	},
}

return PetsByRarity