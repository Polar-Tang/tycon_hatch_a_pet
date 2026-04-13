local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- COMPONENTS
local Components = script.Parent.Components
local Roact = require(ReplicatedStorage.Roact)
local openButton = require(Components.petPanel.openButton)
local HealthBars = require(Components.billboards.HealthBars)
local petPanel = require(Components.petPanel.petPanel)
local CustomProximityPrompts = require(Components.CustomProx.CustomProximityPrompts)
local Billboards = require(Components.billboards.Billboards)
local BoostersConsumer = require(Components.boosters.BoostersConsumer)

local App = Roact.Component:extend("App")
function App:init()
	self:setState({
		running = true,
	})
end

function App:render()
	return Roact.createFragment({
		CustomProximityPrompts = Roact.createElement(CustomProximityPrompts),
		Billboards = Roact.createElement(Billboards),
		HealthBars = Roact.createElement(HealthBars),
		Boosters = Roact.createElement(BoostersConsumer),
		PetPanel = Roact.createElement(petPanel),
		OpenButton = Roact.createElement(openButton),
	})
end

function App:didMount()
	self.running = true
end

return App
