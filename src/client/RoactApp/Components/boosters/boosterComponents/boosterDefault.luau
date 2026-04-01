local StarterPlayer = game:GetService("StarterPlayer")
local ToolTip = require(StarterPlayer.StarterPlayerScripts.RoactApp.Lib.ToolTip)
local Roact = require(game.ReplicatedStorage.Roact)

type Props = {
	data: { [string]: number },
}

local boosterDefault = Roact.Component:extend("boosterDefault")

function boosterDefault:render()
	local data = self.props or {}

	if not next(data) then
		return
	end

	-- First map: aggregate sums
	local petsValue: { [string]: number } = {}
	for name, value in pairs(data) do
		if petsValue[name] then
			petsValue[name] += value
		else
			petsValue[name] = value
		end
	end

	-- Second map: count repetitions
	local repetitions: { [string]: number } = {}

	for name, _ in pairs(data) do
		if repetitions[name] then
			repetitions[name] += 1
		else
			repetitions[name] = 1
		end
	end

	-- Total sum of first map
	local totalSum = 0
	for _, value in pairs(petsValue) do
		totalSum += value
	end

	return Roact.createElement("TextLabel", {
		Size = UDim2.new(0.1, 0, 0.25, 0), --{0.1, 0},{0.25, 0}
		Text = "X" .. tostring(totalSum),
		Position = UDim2.new(0.1, 0, 0.78, 0),
		BackgroundTransparency = 1,
		TextScaled = true,
	}, {
		UIStroke = Roact.createElement("UIStroke", {
			Thickness = 2,
		}),
		ToolTip = Roact.createElement(ToolTip, {
			petsValue = petsValue,
			petsRepetitions = repetitions,
			ToolTipSize = self.props.ToolTipSize,
			ToolTipPosition = self.props.ToolTipPosition,
		}),
	})
end

return boosterDefault
