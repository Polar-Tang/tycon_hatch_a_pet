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
-- Server
Events.ProximityPrompt.OnServerEvent:Connect(function(player, promptInfo)
	local npcModel = promptInfo.Parent
	local id = promptInfo.id
	local prompt = promptInfo.prompt

	-- EZ anti exploits checks
	do
		local theNpcInfo: npcTypes.npcMap = npcMap[npcModel.Name]
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

	Events.ProximityPrompt:FireClient(player, {
		npc = npcModel,
		id = id,
		prompt = prompt,
		inputType = promptInfo.inputType,
	})
	return true
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
