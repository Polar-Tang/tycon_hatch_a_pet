local Roact = require(game:GetService("ReplicatedStorage").Roact)
local PetTypes = require(game:GetService("ReplicatedStorage").Pets.PetTypes)

local InventoryContext = Roact.createContext({
	items = {},
	isPanelOpen = false,
	selectedPetData = nil :: PetTypes.PetData?,
	setPanelOpen = function() end,
	setSelectedPetData = function(_petData) end,
})

return InventoryContext
