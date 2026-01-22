local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetClicked = ReplicatedStorage.RemoteEvents.PetClicked
local PetStat = ReplicatedStorage.RemoteEvents.PetStat

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local utils = require(ReplicatedStorage.utils.utils)
local MoneyLib = require(StarterPlayer.StarterPlayerScripts.utils.MoneyLib)
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local maid = Maid.new()

PetClicked.OnClientEvent:Connect(function(petData)
	local screen = PlayerGui:WaitForChild("ScreenGui")

	if not screen.Stats.Visible then
		screen.Stats.Visible = true
	end
	screen.Stats.Position = UDim2.fromScale(0.5, 0.5)

	maid:DoCleaning()
	
	maid:GiveTask(screen.Stats.Header.CloseButton.MouseButton1Click:Connect(function()
		screen.Stats.Visible = false
		PetStat:FireServer({
			close = true
		})
	end))

	screen.Stats.Header.Points.Text = "Points: " .. petData.avaiblePoints
	local Stamina = petData.petStats.Stamina
	local moneyPerSec = math.round(utils.MoneyCalc(Stamina))

	screen.Stats.Holder.Production.Text = MoneyLib.HandleMoney(moneyPerSec) .. "/s"

	local upgrade_path = screen.Stats.Holder.Upgrades.Scroller

	local innstance_names = { ["Health"] = "SlotHealth", ["Melee"] = "SlotMelee", ["Stamina"] = "SlotStamina" }

	for statName, name in pairs(innstance_names) do
		maid:GiveTask(upgrade_path:FindFirstChild(name).UpgradeButton.MouseButton1Click:Connect(function()
			ReplicatedStorage.RemoteEvents.PetStat:FireServer({
				stat = statName,
				petId = petData.petId,
			})
		end))
	end
	-- PetStat.
end)
return {}
