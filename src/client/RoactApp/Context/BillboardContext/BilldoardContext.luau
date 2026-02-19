local RS = game:GetService("ReplicatedStorage")
local Roact = require(RS.Roact)

local BillboardContext = Roact.createContext({
	billboards = {},
})

return BillboardContext
