local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local module = {}

module.checkModelRegister = function(petId)
	-- Changes to ID this
	local petInfo = _G["pets_registry"][petId]
	if not petInfo.model then
		petInfo.model = workspace:FindFirstChild(petId)
	end
end

local rarityColors = {
	Common = Color3.fromRGB(200, 200, 200),
	Uncommon = Color3.fromRGB(100, 220, 100),
	Rare = Color3.fromRGB(100, 150, 255),
	Epic = Color3.fromRGB(180, 80, 255),
	Legendary = Color3.fromRGB(255, 200, 50),
	Mythic = Color3.fromRGB(255, 80, 80),
}

local rarityGradient = {

	Uncommon = {
		ColorSequenceKeypoint.new(0, Color3.fromRGB(81, 255, 102)),
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(40, 192, 58)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(43, 164, 57)),
	},
}
rarityGradient.Common = {
	ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 220)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180)),
}

rarityGradient.Rare = {
	ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 100, 200)),
}

rarityGradient.Epic = {
	ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 80, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 40, 200)),
}

rarityGradient.Legendary = {
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 0)),
}

rarityGradient.Mythic = {
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 30, 30)),
}
module.getRarityColor = function(rarity: PetTypes.rarity)
	return rarityColors[rarity] or Color3.new(1, 1, 1)
end

module.getRarityColorSecuence = function(rarity: PetTypes.rarity)
	return rarityGradient[rarity] or rarityGradient["Common"]
end

return module
