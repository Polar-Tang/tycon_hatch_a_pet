local StarterPlayer = game:GetService("StarterPlayer")
local Roact = require(game.ReplicatedStorage.Roact)
local images = require(StarterPlayer.StarterPlayerScripts.Public.assets).player_inventory

local context = script.Parent.Parent.Parent.Context
local InventoryContext = require(context.InventoryContext.InventoryContext)
local useContext = require(context.Utils.useContext)

local withCtx = useContext({ InventoryContext = InventoryContext })

local function InventoryItems()
	return withCtx(function(ctx)
		local inventoryCtx = ctx.InventoryContext
		local items = inventoryCtx.items or {}


		-- Sort items by timestamp (oldest to newest)
		local sortedItems = {}
		for i, item in pairs(items) do
			table.insert(sortedItems, item)
		end
		table.sort(sortedItems, function(a, b)
			return (a.timestamp or 0) < (b.timestamp or 0)
		end)
		print(sortedItems, " sortedItems")
		local slots = {}
		for i, item in ipairs(sortedItems) do
			if i > 64 then break end
			slots["Slot" .. i] = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = images.InventorySlot,
				LayoutOrder = i,
			}, {
				Item = item and item.image and Roact.createElement("ImageLabel", {
					Size = UDim2.fromScale(0.9, 0.9),
					Position = UDim2.fromScale(0.05, 0.05),
					BackgroundTransparency = 1,
					Image = item.image,
				}) or nil,
			})
		end

		-- Fill remaining empty slots
		for i = #sortedItems + 1, 64 do
			slots["Slot" .. i] = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = images.InventorySlot,
				LayoutOrder = i,
			})
		end

		return Roact.createFragment(slots)
	end)
end

return InventoryItems
