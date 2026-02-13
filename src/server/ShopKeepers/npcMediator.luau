local ReplicatedStorage = game:GetService("ReplicatedStorage")
local npcMap = require(script.Parent.npcMap)
local npcTypes = require(script.Parent.npcTypes)
local npcUtils = require(script.Parent.npcUtils)

local Events = ReplicatedStorage.RemoteEvents

local npcMediator = {}

function initAllNpcs()
	for npcName, npcData in pairs(npcMap) do
		npcUtils.initNpc(npcData)
	end
end

initAllNpcs()
-- Server
Events.NPCs.OnServerEvent:Connect(function(player, prompt)
	local npcModel = prompt.Parent
	local id = prompt.ObjectText
	-- EZ anti exploits checks
	do
		local theNpcInfo: npcTypes.npcMap = npcMap[npcModel.Name]
		if theNpcInfo.id ~= id then
			return
		end
		local RealNPC = theNpcInfo.model
		if not RealNPC then
			return
		end
		if RealNPC ~= npcModel then
			return
		end
		local RealPrompt = RealNPC:FindFirstChildOfClass("ProximityPrompt")

		if RealPrompt ~= prompt then
			return
		end
		-- Validate distance (anti-teleport exploit)
		local distance = (player.Character.HumanoidRootPart.Position - npcModel.PrimaryPart.Position).Magnitude
		if distance > prompt.MaxActivationDistance + 5 then
			return
		end
	end

	Events.NPCs:FireClient(player, {
		npc = npcModel,
		id = id,
		prompt = prompt,
	})
	return true
end)

return npcMediator
