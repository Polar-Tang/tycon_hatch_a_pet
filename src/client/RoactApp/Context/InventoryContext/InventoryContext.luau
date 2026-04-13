local Roact = require(game:GetService("ReplicatedStorage").Roact)

local InventoryContext = Roact.createContext({
	items = {},
})

return InventoryContext
