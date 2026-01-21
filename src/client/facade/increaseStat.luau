local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetClicked = ReplicatedStorage.RemoteEvents.PetClicked

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local maid = Maid.new()

PetClicked.OnClientEvent:Connect(function(petData)
	local screen = PlayerGui:WaitForChild("ScreenGui")

	if not screen.Stats.Visible then
		screen.Stats.Visible = true
	end
	screen.Stats.Header.Points.Text = "Points: " .. petData.avaiblePoints
	local Stamina = petData.petStats.Stamina
	local moneyPerSec = math.round((Stamina ^ 1.8) * 2)
	
	screen.Stats.Holder.Production.Text = MoneyLib.HandleMoney(moneyPerSec) .. "/s"

	local upgrade_path = screen.Stats.Holder.Upgrades.Scroller

	local innstance_names = { ["Health"] = "SlotHealth", ["Melee"] = "SlotMelee", ["Stamina"] = "SlotStamina" }
	maid:DoCleaning()

	for statName, name in pairs(innstance_names) do
		maid:GiveTask(upgrade_path:FindFirstChild(name).UpgradeButton.MouseButton1Click:Connect(function()
			ReplicatedStorage.RemoteEvents.PetStat:FireServer({
				stat = statName,
				petId = petData.petId
			})
		end))
	end
	-- PetStat.
end)
return {}
