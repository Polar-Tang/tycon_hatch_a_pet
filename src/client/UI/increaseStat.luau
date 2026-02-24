local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetClicked = ReplicatedStorage.RemoteEvents.PetClicked
local PetStat = ReplicatedStorage.RemoteEvents.PetStat

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local statsPanel = require(StarterPlayer.StarterPlayerScripts.facade.statsPanel)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local utils = require(ReplicatedStorage.utils.utils)
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local maid = Maid.new()

PetClicked.OnClientEvent:Connect(function(petData)
	local screen = PlayerGui:WaitForChild("ScreenGui")

	statsPanel.open()

	maid:DoCleaning()

	-- Set up button conns
	do
		local closeButton = statsPanel.getCloseButton()
		maid:GiveTask(closeButton.MouseButton1Click:Connect(function()
			screen.Stats.Visible = false
			PetStat:FireServer({
				close = true,
			})
		end))

		local sellButton = statsPanel.getSellButton()
		maid:GiveTask(sellButton.MouseButton1Click:Connect(function()
			screen.Stats.Visible = false
			ReplicatedStorage.RemoteEvents.PetSell:FireServer({
				sell = true,
				petData = petData,
			})
		end))
	end

	statsPanel.setPoints(petData.avaiblePoints)
	local Stamina = petData.petStats.Stamina
	local moneyPerSec = math.round(utils.MoneyCalc(Stamina))

	statsPanel.setMoneyPerSec(moneyPerSec)

	local scroller = statsPanel.getScroller()

	local innstance_names = { ["Health"] = "SlotHealth", ["Melee"] = "SlotMelee", ["Stamina"] = "SlotStamina" }

	for statName, name in pairs(innstance_names) do
		maid:GiveTask(scroller:FindFirstChild(name).UpgradeButton.MouseButton1Click:Connect(function()
			ReplicatedStorage.RemoteEvents.PetStat:FireServer({
				stat = statName,
				petId = petData.petId,
			})
		end))
	end
	-- PetStat.
end)
return {}
