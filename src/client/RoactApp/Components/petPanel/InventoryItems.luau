local StarterPlayer = game:GetService("StarterPlayer")
local Roact = require(game.ReplicatedStorage.Roact)
local images = require(StarterPlayer.StarterPlayerScripts.Public.assets).player_inventory

local function InventoryItems()
    local slots = {}

    for i = 1, 32 do
        slots["Slot" .. i] = Roact.createElement("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Image = images.InventorySlot,
        })
    end

    return Roact.createFragment(slots)
end

return InventoryItems
