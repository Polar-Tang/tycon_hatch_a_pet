local boosterDefault = require(script.Parent.boosterDefault)
local Roact = require(game.ReplicatedStorage.Roact)

type Props = {
	data: { [string]: number },
}

local coinBooster = Roact.Component:extend("coinBooster")

function coinBooster:render()
	return Roact.createElement(boosterDefault, {
		ToolTipSize = UDim2.new(3, 0, 1.25, 0),
		ToolTipPosition = UDim2.new(0, 0, -1, 0),
	})
end

return coinBooster
