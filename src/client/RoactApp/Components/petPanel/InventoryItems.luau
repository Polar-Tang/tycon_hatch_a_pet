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
		local slots = {}

		for i = 1, 64 do
			local item = items[i]
			slots["Slot" .. i] = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = images.InventorySlot,
			}, {
				Item = item and Roact.createElement("ImageLabel", {
					Size = UDim2.new(0.9, 0.9),
					Position = UDim2.new(0.05, 0.05),
					BackgroundTransparency = 1,
					Image = item.image,
				}) or nil,
			})
		end

		return Roact.createFragment(slots)
	end)
end

return InventoryItems
