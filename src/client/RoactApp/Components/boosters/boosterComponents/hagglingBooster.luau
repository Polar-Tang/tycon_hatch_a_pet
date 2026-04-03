local StarterPlayer = game:GetService("StarterPlayer")
local ToolTip = require(StarterPlayer.StarterPlayerScripts.RoactApp.Lib.ToolTip)
local boosterDefault = require(script.Parent.boosterDefault)
local Roact = require(game.ReplicatedStorage.Roact)

type Props = {
	data: { [string]: number },
}

local hagglingBooster = Roact.Component:extend("hagglingBooster")

function hagglingBooster:init()
	self:setState({
		isOpenGearshop = false,
	})
end

function hagglingBooster:didMount()

	local boolVal: IntValue = _G.ui_context.isOpen
	local connection = boolVal.Changed:Connect(function(value)
		self:setState({
			isOpenGearshop = value,
		})
	end)
	self._connection = connection
end

function hagglingBooster:willUnmount()
	if self._connection then
		self._connection:Disconnect()
	end
end

function hagglingBooster:render()
	
	if not (self.state.isOpenGearshop ) then
		return
	end

	return Roact.createElement(boosterDefault, {
		cardTitle = "Haggling Boost",
		ToolTipSize = UDim2.new(2, 0, 1.25, 0),
		ToolTipPosition = UDim2.new(0.25, 0, 1, 0),
		boosterPets = self.props,
		Size = UDim2.new(0.1, 0, 0.25, 0), --{0.1, 0},{0.25, 0}
		Position = UDim2.new(0.6, 0, 0, 0),
		formatText = function(totalSum)
			return "%" .. tostring(totalSum) .. " off"
		end,
	})
end

return hagglingBooster
