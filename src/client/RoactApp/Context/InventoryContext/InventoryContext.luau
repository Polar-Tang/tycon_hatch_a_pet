local Roact = require(game:GetService("ReplicatedStorage").Roact)

local InventoryContext = Roact.createContext({
	items = {},
	isPanelOpen = false,
	setPanelOpen = function() end,

	--== Tooltip shit ==--
	openToolTip = function(iamgeRef, item) end,
	isOpenTooltip = false,
	toolTipsize = UDim2.new(0,0,0,0),
	toolTipPosition = UDim2.new(0,0,0,0),
	selectedItemData = {},
})

return InventoryContext
