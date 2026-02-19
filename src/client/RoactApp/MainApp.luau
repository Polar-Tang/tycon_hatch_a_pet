local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- COMPONENTS
local Components = script.Parent.Components
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
	})
end

function App:didMount()
	self.running = true
end

return App
