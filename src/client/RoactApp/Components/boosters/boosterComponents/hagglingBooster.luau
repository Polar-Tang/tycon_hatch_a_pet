local Roact = require(game.ReplicatedStorage.Roact)

type Props = {
	data: { [string]: number },
}

local hagglingBooster = Roact.Component:extend("hagglingBooster")

function hagglingBooster:render()
	local data = self.props or {}

	-- First map: aggregate sums
	local tableToReturn: { [string]: number } = {}

	for name, value in pairs(data) do
		if tableToReturn[name] then
			tableToReturn[name] += value
		else
			tableToReturn[name] = value
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
	for _, value in pairs(tableToReturn) do
		totalSum += value
	end

	return Roact.createElement("TextLabel", {
		Size = UDim2.new(0, 200, 0, 50),
		Text = "X" .. tostring(totalSum),
		BackgroundTransparency = 1,
		TextScaled = true,
	}, {
		UIStroke = Roact.createElement("UIStroke", {
			Thickness = 2,
		}),
	})
end

return hagglingBooster
