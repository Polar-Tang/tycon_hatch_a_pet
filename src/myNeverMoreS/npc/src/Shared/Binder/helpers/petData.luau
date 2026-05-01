local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

local function merge<T, U>(a: T, b: U)
	local result = {}

	for k, v in pairs(b) do
		result[k] = v
	end

	for k, v in pairs(a) do
		result[k] = v
	end

	return result :: PetTypes.petInitFrontend
end

module["Fox"] = merge({
	walkSpeed = 10,
	["rarity"] = "common",
	CameraDistanceFactor = 0.8,

	CameraDistanceFactorPetPanel = 1,

	["velocity"] = 4,
	["speed"] = 2,
	["animationRunSpeed"] = 2.5,
	adorneeOffset = Vector3.new(0, 4, 0),
	YOffset = 0.5,
}, common_stats)

module["Giraffe"] = merge({
	walkSpeed = 10,
	["rarity"] = "rare",
	CameraDistanceFactor = 0.8,
	CameraDistanceFactorPetPanel = 1,

	["velocity"] = 4,
	["speed"] = 2,
	["animationRunSpeed"] = 2.5,
	adorneeOffset = Vector3.new(0, 4, 0),
	YOffset = 0.5,
}, common_stats)

module["Panda"] = merge({
	walkSpeed = 10,
	["rarity"] = "common",
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,

	-- ["eat_interval"] = 5,
	-- ["eat_duration"] = 4,
	-- ["patrol_interval"] = 6,
	-- ["patrol_duration"] = 500,
	-- ["range"] = 30,
	["velocity"] = 8,
	["speed"] = 1.25,
	["animationRunSpeed"] = 1.5,
	-- ["base"] = 4, -- money generation
	["adorneeOffset"] = Vector3.new(0, 5, 0),
	YOffset = 0.925,
}, common_stats)

module["Elephant"] = merge({
	walkSpeed = 10,
	["rarity"] = "common",
	CameraDistanceFactor = 1.1,
	CameraDistanceFactorPetPanel = 1,

	-- ["eat_interval"] = 6,
	-- ["eat_duration"] = 3,
	-- ["range"] = 30,
	["velocity"] = 4,
	["speed"] = 3,
	YOffset = 1.3,
	["animationRunSpeed"] = 4,

	-- ["patrol_interval"] = 8,
	-- ["patrol_duration"] = 500,
	-- ["base"] = 8,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
}, common_stats)

module["Hippo"] = merge({
	walkSpeed = 10,
	["rarity"] = "common",
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,

	["velocity"] = 8,

	["speed"] = 2,
	["animationRunSpeed"] = 2.5,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
}, common_stats)

module["Pig"] = merge({
	walkSpeed = 10,
	["rarity"] = "rare",
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,

	["velocity"] = 8,

	["speed"] = 2,
	["animationRunSpeed"] = 2.5,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
}, common_stats)

module["Lion"] = merge({
	walkSpeed = 10,
	["rarity"] = "uncommon",
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 0.9,

	["velocity"] = 6,

	["speed"] = 1,
	YOffset = -1.821,
	calcYOffset = function(Yoff)
		return 1.821
	end,
	--
	["adorneeOffset"] = Vector3.new(0, 6, 0),
}, common_stats)

module["Cat"] = merge({
	walkSpeed = 10,
	["velocity"] = 6,
	["rarity"] = "uncommon",
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,

	["speed"] = 1,
	["adorneeOffset"] = Vector3.new(0, 5, 0),

	YOffset = 0.726 + 0.725 - 0.208, -- +0.543+0.725,
}, common_stats)

module["Dog"] = merge({
	walkSpeed = 10,
	["velocity"] = 8,
	["rarity"] = "uncommon",
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,

	["speed"] = 1.2,
	YOffset = 0.42,
	--lvl38 0.543

	["adorneeOffset"] = Vector3.new(0, 5, 0),
}, common_stats)

local rhino: PetTypes.petInitFrontend = merge({
	walkSpeed = 10,
	-- ["eat_interval"] = 6,
	-- ["eat_duration"] = 5,
	-- ["range"] = 30,
	["velocity"] = 4,
	["speed"] = 3,
	["rarity"] = "common",
	CameraDistanceFactor = 1.2,
	CameraDistanceFactorPetPanel = 1,

	-- ["patrol_interval"] = 8,
	-- ["patrol_duration"] = 500,
	-- ["base"] = 6,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
	YOffset = 0.994,
}, common_stats)
module["Rhino"] = rhino
--
return module :: { [PetTypes.petNames]: PetTypes.petInitFrontend }
