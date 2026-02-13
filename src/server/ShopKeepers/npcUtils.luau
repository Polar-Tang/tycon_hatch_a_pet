local npcTypes = require(script.Parent.npcTypes)
local npcUtils = {}

function npcUtils.initNpc(npcData: npcTypes.npcMap)
	-- TODO : create a proximity prompt
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

return npcUtils
