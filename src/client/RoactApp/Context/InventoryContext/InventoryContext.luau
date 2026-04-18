local Roact = require(game:GetService("ReplicatedStorage").Roact)
local PetTypes = require(game:GetService("ReplicatedStorage").Pets.PetTypes)

local InventoryContext = Roact.createContext({
	items = {},
	isPanelOpen = false,
	is2dPreview = true,
	selectedPetData = nil :: PetTypes.PetData?,
	setPanelOpen = function() end,
	setSelectedPetData = function(_petData) end,
	setIs2dPreview = function(_is2d) end,
})

return InventoryContext
