local boosterDefault = require(script.Parent.boosterDefault)
local Roact = require(game.ReplicatedStorage.Roact)

type Props = {
	data: { [string]: number },
}

local coinBooster = Roact.Component:extend("coinBooster")

function coinBooster:render()
	return Roact.createElement(boosterDefault, {
		cardTitle = "Coin Boost",

		ToolTipSize = UDim2.new(2, 0, 1.25, 0),
		ToolTipPosition = UDim2.new(0, 0, -1, 0),
		boosterPets = self.props,
		formatText = function(totalSum)
			return "X" .. tostring(totalSum)
		end,
		Position = UDim2.new(0.1, 0, 0.78, 0),
		Size = UDim2.new(0.1, 0, 0.25, 0),
	})
end
--[[
]]

return coinBooster
