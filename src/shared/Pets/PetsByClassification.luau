local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetTypes = require(ReplicatedStorage.Pets.PetTypes)

type rarity = PetTypes.rarity
type petNames = PetTypes.petNames

type petsByRarity = { [rarity]: { petNames } }
type petsByClassification = {
	Carnivore: petsByRarity,
	Herbivore: petsByRarity,
}

local PetsByClassification: petsByClassification = {
	Carnivore = {
		common = { "Gorilla", "Fox" },
		rare = { "Cat" },
		epic = { "Parrot", "Dog", "Bear", "Wolf" },
		legendary = { "Lion", "Tiger" },
	},
	Herbivore = {
		common = { "Turtle", "Alpaca", "Elk" },
		rare = { "Bunny", "Elephant", "Panda" },
		epic = { "Pig", "Giraffe", "Bull" },
		legendary = { "Rhino" },
	},
}

return PetsByClassification