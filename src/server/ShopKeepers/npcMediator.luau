local ReplicatedStorage = game:GetService("ReplicatedStorage")
local npcMap = require(ReplicatedStorage.utils.npcMap)
local npcTypes = require(ReplicatedStorage.utils.npcTypes)

local Events = ReplicatedStorage.RemoteEvents

local npcMediator = {}

function initAllNpcs()
	for npcName, npcData in pairs(npcMap) do
		local prompt = Instance.new("ProximityPrompt")
		prompt.Style = Enum.ProximityPromptStyle.Default
		prompt.ActionText = "Shop"
		prompt.Name = "Shop"
		prompt.ObjectText = npcData.id
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.HoldDuration = 0
		prompt.Style = Enum.ProximityPromptStyle.Custom
		prompt.RequiresLineOfSight = false
		prompt.MaxActivationDistance = 24
		prompt.ClickablePrompt = true
		prompt.Parent = npcData.model
	end
end

initAllNpcs()
-- Server
Events.NPCs.OnServerEvent:Connect(function(player, promptInfo)
	local npcModel = promptInfo.Parent
	local id = promptInfo.ObjectText
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

	Events.NPCs:FireClient(player, {
		npc = npcModel,
		id = id,
		prompt = prompt,
	})
	return true
end)

return npcMediator
