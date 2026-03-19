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

	-- EZ anti exploits checks
	do
		if not npcModel then
			print("npc model exists in only in the client")
			return
		end
		local theNpcInfo: npcTypes.npcMap = npcMap[(npcModel.Name or npcName)]
		if not theNpcInfo then
			print("no theNpcInfo")
			return
		end
		if theNpcInfo.id ~= id then
			print("no id")
			return
		end
		local RealNPC = theNpcInfo.model
		if not RealNPC then
			print("npc model not found")
			return
		end
		if RealNPC ~= npcModel then
			print("npc model false")
			return
		end
		local RealPrompt = RealNPC:FindFirstChildOfClass("ProximityPrompt")

		if RealPrompt ~= prompt then
			print("np prompt found in NPC")
			return
		end
		-- Validate distance (anti-teleport exploit)
		-- local distance = (player.Character.HumanoidRootPart.Position - npcModel.PrimaryPart.Position).Magnitude
		-- if distance > prompt.MaxActivationDistance + 5 then
		-- 	print("Too far from the npc")
		-- 	return
		-- end
	end

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

local Items = rs.RemoteEvents.ItemsEvent

Items.OnServerEvent:Connect(function(player: Player, data: ItemType.ItemFrontend)
	local playerInventory = PlayerInventory:GetHandler(player)
	local itemData = ItemData[data.itemName]
	print("data ", data)
	print("itemData ", itemData)
	if not itemData then
		print("Item ", data.itemName, " not found")
		return
	end
	local ItemsTemplate = rs.Items:FindFirstChild(data.itemName):Clone()

	playerInventory:DecreaseMoney(itemData.price)

	ItemsTemplate.Parent = player.Backpack
end)

return npcMediator
