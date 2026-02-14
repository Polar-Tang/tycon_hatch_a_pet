local StarterPlayer = game:GetService("StarterPlayer")

local Roact = require(game.ReplicatedStorage.Roact)
local nameToImage = require(StarterPlayer.StarterPlayerScripts.utils.nameToAction)

local CustomProximityPrompt = Roact.Component:extend("CustomProximityPrompt")
function CustomProximityPrompt:render()
	local prompt = self.props.prompt

	local npc = prompt.Parent

	local imagePrompt = nameToImage[npc.Name].image

	if prompt.Style ~= Enum.ProximityPromptStyle.Custom then
		return
	end
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
				print("Hello World!")
			end,
		}),
	})
end

return CustomProximityPrompt
