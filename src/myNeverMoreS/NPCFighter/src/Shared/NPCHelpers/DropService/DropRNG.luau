type aspects = {
	rarity: "common" | "uncommon" | "rare" | "epic",
	buffKind: "XP" | "DMG" | "speed" | "stamina" | "poisonHealth",
	type: "consumable" | "buff",
	name: "ExperienceSeed" | "GemOfPower" | "SpeedPoison" | "EnchantedFood" | "PoisonHealth",
	buff: number,
}

local Inventory = game:GetService("ServerScriptService"):WaitForChild("Player"):WaitForChild("Inventory")
local Item = require(Inventory:WaitForChild("ItemClient"))

--type buffKind: "XP" | "DMG" | "speed" | "stamina" | "poisonHealth"

local function determineBuffKInd(index: number): string
	if index == 1 then
		return "XP"
	elseif index == 2 then
		return "DMG"
	elseif index == 3 then
		return "speed"
	elseif index == 4 then
		return "stamina"
	elseif index == 5 then
		return "poisonHealth"
	end
end

local function determineRararety(index: number): string
	if index <= 70 then
		return "common"
	elseif index <= 95 then
		return "uncommon"
	elseif index <= 99 then
		return "rare"
	elseif index >= 100 then
		return "epic"
	end
end

local function createAItem(itemChance: number, dropId: string)
	local newItem: aspects = {
		rarity = "",
		buffKind = "",
		type = "",
	}
	local buffKindIndex = math.random(1, 5)

	local buffKind = determineBuffKInd(buffKindIndex)
	newItem.buffKind = buffKind
	if buffKind == "poisonHealth" then
		newItem.type = "consumable"
	else
		newItem.type = "buff"
	end
	local randomnessRarirty = math.random(1, 100) + itemChance * 5
	local rarity = determineRararety(randomnessRarirty)
	newItem.rarity = rarity

	local newItem = Item.createItem({ rarity = rarity, type = newItem.type, dropId = dropId, name = newItem.buffKind })
	return newItem
end

return function(data)
	-- 7 - 6
	local diffFactor = data.npc.level.Value - data.PetPlayerState.Data.lvl

	local itemQuantityDice = math.random(1, 100) + diffFactor * 10
	local itemsQuantity = 1
	if itemQuantityDice <= 50 then
		itemsQuantity = 1
	elseif itemQuantityDice <= 100 then
		itemsQuantity = 2
	elseif itemQuantityDice <= 150 then
		itemsQuantity = 3
	elseif itemQuantityDice >= 200 then
		itemsQuantity = 4
	end

	local items = {}
	for i = 1, itemsQuantity do
		local newItem = createAItem(diffFactor, data.dropId)
		print("CREATEAITEM", newItem)

		items[newItem.itemId] = newItem
	end
	return items
end
