local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local bottomLeft = require(StarterPlayer.StarterPlayerScripts.facade.bottomLeft)
local utils = require(ReplicatedStorage.utils.utils)
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

		local pets = CollectionService:GetTagged("pets_" .. player.UserId)
		if not pets then
			return
		end

		for _, petInstance in ipairs(pets) do
			if not _G["pets_registry"] then
				continue
			end
			local petData = _G["pets_registry"][petInstance.Name]
			if not petData then
				continue
			end
			local Stamina = petData.petStats.Stamina
			if petData.petStats.Stamina <= 0 then
				Stamina = 1
			end

			local base = utils.MoneyCalc(Stamina)
			total += base
		end
		bottomLeft.SetMoney(total)
	end
end)

return function(amount)
	local BottomLeft = screenGui:WaitForChild("BottomLeft")
	if not BottomLeft.Visible then
		BottomLeft.Visible = true
		BottomLeft.CashAmount.Visible = true
		BottomLeft.FriendBoost.Visible = true
	end
	total = amount
	bottomLeft.SetMoney(total)
end
