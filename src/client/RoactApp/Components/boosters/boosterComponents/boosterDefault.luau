local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local incomeUtils = require(ReplicatedStorage.utils.incomeUtils)
local ToolTip = require(StarterPlayer.StarterPlayerScripts.RoactApp.Lib.ToolTip)
local Roact = require(game.ReplicatedStorage.Roact)

type Props = {
	data: { [string]: number },
}

local boosterDefault = Roact.Component:extend("boosterDefault")

function boosterDefault:render()

	local formatText = self.props.formatText

	local data = self.props.boosterPets

	if not next(data) then
		return
	end

	local petsValue, totalSum = incomeUtils.totalBoost(data) 


	return Roact.createElement("TextLabel", {
		Size = self.props.Size, --{0.1, 0},{0.25, 0}
		Text = formatText(totalSum), --Text
		Position = self.props.Position,
		BackgroundTransparency = 1,
		TextScaled = true,
	}, {
		UIStroke = Roact.createElement("UIStroke", {
			Thickness = 2,
		}),
		ToolTip = Roact.createElement(ToolTip, {
			cardTitle = self.props.cardTitle,
			petsValue = petsValue,
			petsBooster = data,
			ToolTipSize = self.props.ToolTipSize,
			ToolTipPosition = self.props.ToolTipPosition,
		}),
	})
end

return boosterDefault
