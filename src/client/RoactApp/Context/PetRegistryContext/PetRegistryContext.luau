local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Roact)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)

local PetRegistryContext = Roact.createContext({
	pets = {} :: PetTypes.PetsDataStore,
	boosters = {} :: { any },
})

return PetRegistryContext
