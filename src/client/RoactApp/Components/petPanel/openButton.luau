local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)
local Roact = require(ReplicatedStorage.Roact)

local context = script.Parent.Parent.Parent.Context
local InventoryContext = require(context.InventoryContext.InventoryContext)
local useContext = require(context.Utils.useContext)
local withCtx = useContext({ InventoryContext = InventoryContext })

local OpenButton = Roact.Component:extend("OpenButton")
function OpenButton:render()
	return withCtx(function(ctx)
		local inventoryCtx = ctx.InventoryContext

		return Roact.createElement("ImageButton", {
			Size = UDim2.new(0.1, 0, 0.2, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 16 / 300, 0.75, 0),
			BackgroundTransparency = 1,
			Image = assets.player_inventory.InventoryIcon,
			BorderSizePixel = 0,
			AutoButtonColor = true,
			[Roact.Event.Activated] = function()
				inventoryCtx.setPanelOpen(true)
				ReplicatedStorage.RemoteEvents.PlayerInventory:FireServer()
			end,
		})
	end)
end

return OpenButton
