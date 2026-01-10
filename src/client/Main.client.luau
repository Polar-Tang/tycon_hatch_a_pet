local RepStore = game:GetService("ReplicatedStorage")
local Amount: RemoteEvent = RepStore.RemoteEvents.Amount

local Facade = script.Parent.facade -- a facade that is not a class
local increaseMoney = require(Facade.increaseMoney)
local FadingText = require(script.Parent.utils.FadingText)

local currentAmount = 0 -- this data should come from the server
Amount.OnClientEvent:Connect(function(data)
	print("data ", data)
	local newAmount = data.amount
	currentAmount += newAmount
	increaseMoney(currentAmount)

	local model: Model = data.model
	if model then
		local rootPart = model.PrimaryPart
		FadingText(rootPart, newAmount, Color3.fromRGB(57, 228, 5), UDim2.new(12, 0, 2, 0))
	end
end)
