local RepStore = game:GetService("ReplicatedStorage")
local Amount: RemoteEvent = RepStore.RemoteEvents.Amount

local Facade = script.Parent.facade -- a facade that is not a class
local increaseMoney = require(Facade.increaseMoney)
local FadingText = require(script.Parent.utils.FadingText)

local currentAmount = 0 -- this data should come from the server
Amount.OnClientEvent:Connect(function(data)
	local model: Model = data.model
	local rootPart = model.PrimaryPart
	local newAmount = data.amount
	currentAmount += newAmount
	increaseMoney(currentAmount)
	FadingText(rootPart, newAmount, Color3.fromRGB(0, 128, 0), UDim2.new(6, 0, 1, 0))
end)
