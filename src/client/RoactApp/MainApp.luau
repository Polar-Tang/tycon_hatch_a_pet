local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- COMPONENTS
local Components = script.Parent.Components
local HealthBars = require(StarterPlayer.StarterPlayerScripts.RoactApp.Components.billboards.HealthBars)
local Roact = require(ReplicatedStorage.Roact)
local CustomProximityPrompts = require(Components.CustomProx.CustomProximityPrompts)
local Billboards = require(Components.billboards.Billboards)

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
	})
end

function App:didMount()
	self.running = true
end

return App
