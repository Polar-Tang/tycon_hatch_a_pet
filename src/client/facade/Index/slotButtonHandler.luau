--!strict
local StarterPlayer = game:GetService("StarterPlayer")

local FightButton = require(script.Parent.FightButton)
local petDetails = require(StarterPlayer.StarterPlayerScripts.facade.petDetails)
local alert = require(script.Parent.Parent.alert)

local SlotButtonHandler = {}

function SlotButtonHandler.setupButtonActivated(button, data, isBoss, createUIStroke, rarity)
	local con = button.Activated:Connect(function(a0: InputObject, a1: number)
		if not isBoss then
			_G["petToFight"] = data
			petDetails.open()
			petDetails.setPetData(data)
			createUIStroke(rarity)
		else
			createUIStroke(rarity)
			if _G["petToFight"] then
				_G["bossToFight"] = data
				FightButton.open()
			else
				alert.alert("select a pet for the combat first")
			end
		end
	end)
	return con
end

return SlotButtonHandler
