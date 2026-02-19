local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local npcTypes = require(ReplicatedStorage.utils.npcTypes)
local Roact = require(game.ReplicatedStorage.Roact)
local nameToImage = require(StarterPlayer.StarterPlayerScripts.utils.nameToAction)

local CustomProximityPrompt = Roact.Component:extend("CustomProximityPrompt")
function CustomProximityPrompt:render()
	-- TODO: copy the roblox.create proximity prompt that is very very similar to the default one
	-- TODO: after that, see how to use the damn billboard for the egg

	local prompt = self.props.prompt

	local npc = prompt.Parent

	local npcUtility: npcTypes.nameToAction = nameToImage[npc.Name]
	local imagePrompt = npcUtility.image

	if prompt.Style ~= Enum.ProximityPromptStyle.Custom then
		return
	end
	-- npcUtility
	-- UDim2.new(1, 0, 1, 0)

	return Roact.createElement("BillboardGui", {
		AlwaysOnTop = true,
		Size = nameToImage[npc.Name].imageSize or UDim2.fromOffset(64, 64),
		StudsOffset = Vector3.new(0, -1, 0),
		Adornee = npc,
		Active = true,
	}, {
		button = Roact.createElement("ImageButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = imagePrompt,
			[Roact.Event.Activated] = function()
				npcUtility.promptTrigger()
			end,
		}),
	})
end

return CustomProximityPrompt
