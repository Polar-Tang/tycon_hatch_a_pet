--!strict
local StarterPlayer = game:GetService("StarterPlayer")

local FightButton = require(script.Parent.FightButton)
local petDetails = require(StarterPlayer.StarterPlayerScripts.facade.petDetails)
local alert = require(script.Parent.Parent.alert)

local SlotButtonHandler = {}

-- The fight team can hold at most this many pets.
local MAX_PETS = 3

function SlotButtonHandler.setupButtonActivated(button, data, isBoss, strokes, rarity)
	local con = button.Activated:Connect(function(a0: InputObject, a1: number)
		if not isBoss then
			-- _G["petToFight"] is the ordered team of selected pet ids. Each click
			-- toggles this pet: insert it (+ highlight) on the first click, remove it
			-- (+ un-highlight) on the second.
			local selected = _G["petToFight"]
			if type(selected) ~= "table" then
				selected = {}
				_G["petToFight"] = selected
			end

			local existingIndex = table.find(selected, data.petId)
			if existingIndex then
				table.remove(selected, existingIndex)
				petDetails.removePet(data.petId)
				strokes.remove()
				return
			end

			if #selected >= MAX_PETS then
				alert.alert("you can only bring " .. MAX_PETS .. " pets to the fight")
				return
			end

			table.insert(selected, data.petId)
			petDetails.open()
			petDetails.addPet(data)
			strokes.create(rarity)
		else
			strokes.createBoss(rarity)
			local selected = _G["petToFight"]
			local isPetSeletected = type(selected) == "table" and #selected > 0
			_G["bossToFight"] = data
			local isBossSeletect = _G["bossToFight"] and next(_G["bossToFight"])
			if isPetSeletected and isBossSeletect then
				FightButton.open()
			else
				alert.alert("select a pet to fight with")
			end
		end
	end)
	return con
end

return SlotButtonHandler
