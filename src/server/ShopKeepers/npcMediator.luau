local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local npcMap = require(ReplicatedStorage.utils.npcMap)
local npcTypes = require(ReplicatedStorage.utils.npcTypes)

local Events = ReplicatedStorage.RemoteEvents

local npcMediator = {}

function initAllNpcs()
	for npcName, npcData in pairs(npcMap) do
		npcData.init()
	end
end

initAllNpcs()

export type promptyInfo = {
	npc: Model,
	id: string,
	prompt: ProximityPrompt,
	inputType: EnumItem,
}

local sendProximityPrompt = function(player, promptInfo: promptyInfo)
	local npcModel = promptInfo.npc
	local id = promptInfo.id
	local prompt = promptInfo.prompt

	Events.ProximityPrompt:FireClient(player, {
		npc = npcModel,
		id = id,
		prompt = prompt,
		inputType = promptInfo.inputType,
	})
end

-- Server
Events.ProximityPrompt.OnServerEvent:Connect(function(player, promptInfo)
	local npcModel = promptInfo.Parent
	local npcName = promptInfo.npcName
	local id = promptInfo.id
	local prompt = promptInfo.prompt
	local inputType = promptInfo.inputType

	local prompt_contract: promptyInfo = {
		id = id,
		npc = npcModel,
		prompt = prompt,
		inputType = inputType,
	}
	sendProximityPrompt(player, prompt_contract)
	return true
end)

function sendDataToFrontend(npcData: npcMap.NpcEntry, inputType: EnumItem, player: Player)
	local poxyPrompt = npcData.get_prompty()
	assert(poxyPrompt, "Server npcs were not initialized")

	local prompt_contract: promptyInfo = {
		id = npcData.id,
		npc = npcData.model,
		prompt = poxyPrompt,
		inputType = inputType,
	}
	sendProximityPrompt(player, prompt_contract)
end

game.ReplicatedStorage.RemoteEvents.RemoteSync.OnServerEvent:Connect(function(player: Player, info)
	local inputType = info.inputType
	sendDataToFrontend(npcMap["Kibly Shop Keeper"], inputType, player)
	sendDataToFrontend(npcMap["Egg Shop Keeper"], inputType, player)
end)

local rs = game:GetService("ReplicatedStorage")
local ItemType = require(ServerScriptService.Player.Inventory.ItemType)
local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)
local ItemData = require(ReplicatedStorage.Items.ItemData)

local ItemsEvent = rs.RemoteEvents.ItemsEvent

ItemsEvent.OnServerEvent:Connect(function(player: Player, data: ItemType.ItemFrontend)
	local playerInventory = PlayerInventory:GetHandler(player)
	local itemData = ItemData[data.itemName]
	if not itemData then
		return
	end

	if itemData.price > playerInventory.cash then
		return
	end

	local ItemsTemplate = rs.Items:FindFirstChild(data.itemName):Clone()

	playerInventory:DecreaseMoney(itemData.price)
	playerInventory:AddItem(itemData)

	ItemsTemplate.Parent = player.Backpack
end)

return npcMediator
