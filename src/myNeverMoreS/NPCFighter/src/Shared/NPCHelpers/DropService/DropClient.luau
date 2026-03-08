local dropItems = require(script.Parent.dropItems)
local dropRNG = require(script.Parent.DropRNG)
local GoldQuantity = require(script.Parent.GoldQuantity)
local repStore = game.ReplicatedStorage

local Public = repStore:WaitForChild("Public")
local data = require(Public:WaitForChild("AssetsId"))

local Events = repStore:WaitForChild("Events")
local DropItems = Events:WaitForChild("DropItems")
local HttpService = game:GetService("HttpService")
local Helpers = game:GetService("ServerScriptService"):WaitForChild("Helpers")
local dropsIds = require(Helpers.IdDrops)

local module = {}
function module.CreateDrop(data, dropsIds)
	print("create drops with these data ", data)
	local player = data.player
	if not player or not data.PetPlayerState then
		return
	end
	local id = HttpService:GenerateGUID(false)
	data.dropId = id
	dropsIds[id] = 0

	local itemsDroper = dropRNG(data)

	local goldId = HttpService:GenerateGUID(false)
	local gold = {
		dropId = id,
		name = "gold",
		quantity = GoldQuantity(data),
		image = data.goldIcon,
		itemId = goldId,
	}
	itemsDroper[goldId] = gold
	print("itemsDroper ", itemsDroper)
	data.itemsDroper = itemsDroper
	DropItems:FireClient(player, { originalPos = data.originalPos, items = itemsDroper })
	return itemsDroper
end

function module.DestroyDrops(data, id)
	DropItems:FireClient(data.player, { originalPos = data.originalPos, items = data.itemsDroper, destroy = true })
	dropsIds[id] = nil
	data.dropId = nil
end

function module.DestroyDrop(player, itemData)
	DropItems:FireClient(player, { itemData = itemData, destroy = true })
	dropsIds[itemData.itemId] = nil
end
return module
