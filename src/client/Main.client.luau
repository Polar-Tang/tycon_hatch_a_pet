local RepStore = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Amount: RemoteEvent = RepStore.RemoteEvents.Amount

local increaseMoney = require(StarterPlayer.StarterPlayerScripts.UI.increaseMoney)
local _ = require(StarterPlayer.StarterPlayerScripts.UI.increaseStat)

Amount.OnClientEvent:Connect(function(data)
	local newAmount = data.amount
	increaseMoney(newAmount)
end)
