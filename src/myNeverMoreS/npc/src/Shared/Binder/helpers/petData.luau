local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Table = require(ReplicatedStorage.Nevermore.Quenty.table.Shared.Table)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local module = {}

local common_stats = {
	["eat_interval"] = 6,
	["eat_duration"] = 5,
	["range"] = 30,
	["patrol_interval"] = 8,
	["patrol_duration"] = 500,
	["base"] = 6,
}


local function merge(a: any, b: any): PetTypes.petInitFrontend
	local result = {} :: any

	for k, v in pairs(b) do
		result[k] = v
	end

	for k, v in pairs(a) do
		result[k] = v
	end

	return result :: PetTypes.petInitFrontend
end

local PetsByRarity = require(ReplicatedStorage.Pets.PetsByRarity)
local PetsByClassification = require(ReplicatedStorage.Pets.PetsByClassification)

local function determineRarityFromPetTypes(name: PetTypes.petNames): PetTypes.rarity
	for r, list in pairs(PetsByRarity) do
		if type(list) == "table" then
			for _, pn in ipairs(list) do
				if pn == name then
					return r
				end
			end
		end
	end

	for _, cls in pairs(PetsByClassification) do
		if type(cls) == "table" then
			for r, list in pairs(cls) do
				if type(list) == "table" then
					for _, pn in ipairs(list) do
						if pn == name then
							return r
						end
					end
				end
			end
		end
	end

	return "common"
end

local function addPet(name: PetTypes.petNames, data: any)
	local merged = merge(data, common_stats)
	if merged.rarity == nil then
		merged.rarity = determineRarityFromPetTypes(name)
	end
	module[name] = merged
end

addPet("Fox", {
	walkSpeed = 10,
	CameraDistanceFactor = 0.8,
	CameraDistanceFactorPetPanel = 1,
	["velocity"] = 4,
	["speed"] = 2,
	["animationRunSpeed"] = 2.5,
	adorneeOffset = Vector3.new(0, 4, 0),
	YOffset = 0.5,
})

addPet("Giraffe", {
	walkSpeed = 10,
	CameraDistanceFactor = 0.8,
	CameraDistanceFactorPetPanel = 1,
	["velocity"] = 4,
	["speed"] = 2,
	["animationRunSpeed"] = 2.5,
	adorneeOffset = Vector3.new(0, 4, 0),
	YOffset = 0.5,
})

addPet("Panda", {
	walkSpeed = 10,
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,
	["velocity"] = 8,
	["speed"] = 1.25,
	["animationRunSpeed"] = 1.5,
	["adorneeOffset"] = Vector3.new(0, 5, 0),
	YOffset = 0.925,
})

addPet("Elephant", {
	walkSpeed = 10,
	CameraDistanceFactor = 1.1,
	CameraDistanceFactorPetPanel = 1,
	["velocity"] = 4,
	["speed"] = 3,
	YOffset = 1.3,
	["animationRunSpeed"] = 4,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
})

addPet("Hippo", {
	walkSpeed = 10,
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,
	["velocity"] = 8,
	["speed"] = 2,
	["animationRunSpeed"] = 2.5,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
})

addPet("Pig", {
	walkSpeed = 10,
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,
	["velocity"] = 8,
	["speed"] = 2,
	["animationRunSpeed"] = 2.5,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
})

addPet("Lion", {
	walkSpeed = 10,
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 0.9,
	["velocity"] = 6,
	["speed"] = 1,
	YOffset = -1.821,
	calcYOffset = function(Yoff)
		return 1.821
	end,
	["adorneeOffset"] = Vector3.new(0, 6, 0),
})

addPet("Cat", {
	walkSpeed = 10,
	["velocity"] = 6,
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,
	["speed"] = 1,
	["adorneeOffset"] = Vector3.new(0, 5, 0),
	YOffset = 0.726 + 0.725 - 0.208,
})

addPet("Dog", {
	walkSpeed = 10,
	["velocity"] = 8,
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,
	["speed"] = 1.2,
	YOffset = 0.42,
	["adorneeOffset"] = Vector3.new(0, 5, 0),
})

addPet("Rhino", {
	walkSpeed = 10,
	["velocity"] = 4,
	["speed"] = 3,
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
	YOffset = 0.994,
})

addPet("Wolf", {
	walkSpeed = 10,
	["velocity"] = 8,
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,
	["speed"] = 1.2,
	YOffset = 0.42,
	["adorneeOffset"] = Vector3.new(0, 5, 0),
})

addPet("Bear", {
	walkSpeed = 10,
	["velocity"] = 8,
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,
	["speed"] = 1.2,
	YOffset = 0.42,
	["adorneeOffset"] = Vector3.new(0, 5, 0),
})

addPet("Turtle", {
	walkSpeed = 10,
	["velocity"] = 4,
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,
	["speed"] = 1,
	["adorneeOffset"] = Vector3.new(0, 5, 0),
	YOffset = 0.726 + 0.725 - 0.208,
})

addPet("Alpaca", {
	walkSpeed = 10,
	["velocity"] = 6,
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,
	["speed"] = 1,
	["adorneeOffset"] = Vector3.new(0, 5, 0),
	YOffset = 0.726 + 0.725 - 0.208,
})

addPet("Bull", {
	walkSpeed = 10,
	["velocity"] = 6,
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,
	["speed"] = 1,
	["adorneeOffset"] = Vector3.new(0, 5, 0),
	YOffset = 0.726 + 0.725 - 0.208,
})

addPet("Gorilla", {
	walkSpeed = 10,
	["velocity"] = 6,
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,
	["speed"] = 1,
	["adorneeOffset"] = Vector3.new(0, 5, 0),
	YOffset = 0.726 + 0.725 - 0.208,
})

-- This is to detect if the table is rewrited by accident
table.freeze(module)

return module :: { [PetTypes.petNames]: PetTypes.petInitFrontend }
