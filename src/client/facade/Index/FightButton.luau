local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)

local player = Players.LocalPlayer

local PlayerGui = player:WaitForChild("PlayerGui")

local screen = PlayerGui:WaitForChild("ScreenGui")
local petScreen = screen.PetScreen

-- TODO : update this to the actual instance path
local FightButton = {}

function FightButton.open()
	petScreen.Visible = true
	petScreen.PetIndexBottom.Visible = true
	local fight_button: ImageButton = petScreen.PetIndexBottom.FightButton
	fight_button.Activated:Connect(function(a0: InputObject, a1: number)
		-- _G["petToFight"] is the ordered team of selected pet ids (1..3).
		local petIds = _G["petToFight"]
		local bossToFight = _G["bossToFight"]
		if type(petIds) ~= "table" or #petIds == 0 or not bossToFight then
			return
		end

		local dataFight: NpcFighterTypes.combatInstanceData = {
			petIds = petIds,
			bossName = bossToFight.petName,
		}
		game.ReplicatedStorage.RemoteEvents.BossRemoteEvent:FireServer(dataFight)
	end)
end

function FightButton.close()
	petScreen.PetIndexBottom.Visible = true
end

return FightButton
