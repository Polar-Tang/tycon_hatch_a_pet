local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local screenGui = PlayerGui:WaitForChild("ScreenGui")

local timer = 0
local lastTime = 0
local total = 0

RunService.Heartbeat:Connect(function(dt: number)
	timer += dt
	if timer - lastTime >= 1 then
		lastTime = timer

		local pets = _G["pets_registry"]
		if not pets then
			return
		end

		for petName, petData in pairs(pets) do
			if petData.petStats.Melee <= 0 then
				Melee = 1
			end
			local Stamina = petData.petStats.Stamina
			if petData.petStats.Stamina <= 0 then
				Stamina = 1
			end

			local base = (Stamina ^ 1.8) * 2
			total += base
		end
		screenGui.BottomLeft.CashAmount.Text = MoneyLib.HandleMoney(total)
	end
end)

return function(amount)
	if not screenGui.BottomLeft.Visible then
		screenGui.BottomLeft.Visible = true
		screenGui.BottomLeft.CashAmount.Visible = true
		screenGui.BottomLeft.FriendBoost.Visible = true
	end
	total = amount
	screenGui.BottomLeft.CashAmount.Text = MoneyLib.HandleMoney(amount)
end
