local RepStore = game:GetService("ReplicatedStorage")
local Amount: RemoteEvent = RepStore.RemoteEvents.Amount

local Facade = script.Parent.facade -- a facade that is not a class
local increaseMoney = require(Facade.increaseMoney)
local FadingText = require(script.Parent.utils.FadingText)
local increaseStat = require(Facade.increaseStat)

local currentAmount = 0 -- this data should come from the server
Amount.OnClientEvent:Connect(function(data)
	local newAmount = data.amount
	currentAmount += newAmount
	increaseMoney(currentAmount)

end)
