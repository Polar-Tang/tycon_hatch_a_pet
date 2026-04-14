local Roact = require(game:GetService("ReplicatedStorage").Roact)

local InventoryContext = Roact.createContext({
	items = {},
	isPanelOpen = false,
	setPanelOpen = function() end,
})

return InventoryContext
