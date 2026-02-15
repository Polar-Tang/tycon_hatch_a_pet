local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rs = game:GetService("ReplicatedStorage")
local ItemData = require(ReplicatedStorage.Items.ItemData)
local ItemType = require(script.Parent.ItemType)
local PlayerInventory = require(script.Parent.PlayerInventory)

local Items = rs.RemoteEvents.Items

Items.OnServerEvent:Connect(function(player: Player, data: ItemType.ItemFrontend)
	local playerInventory = PlayerInventory:GetHandler(player)

	local itemData = ItemData[data.itemName]
	if not itemData then
		print("Item ", data.itemName, " not found")
		return
	end
	local ItemsTemplate = rs.Items:FindFirstChild(data.itemName):Clone()

	playerInventory:DecreaseMoney(itemData.price)

	ItemsTemplate.Parent = player.Backpack
end)

return {}
