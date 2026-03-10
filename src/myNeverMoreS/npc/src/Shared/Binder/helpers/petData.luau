local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Table = require(ReplicatedStorage.Nevermore.Quenty.table.Shared.Table)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local module = {}

--[[
The eat interval is always less than the patrol interval
The eat interval + eat duration >= eat_interval
]]

--[[

-- completly OP
module["Fox"] =  {
["rarity"] = "common",
	["eat_interval"] = 2,
	["eat_duration"] = 3,
	["range"] = 30,
	["velocity"] = 4,
	["speed"] = 2,
	["patrol_interval"] = 7,
	["patrol_duration"] = 500,
	["base"] = 2,
	["adorneeOffset"] = Vector3.new(0, 4, 0),
	YOffset = 0.5,
},

module["Panda"] = {
["rarity"] = "common",
	["eat_interval"] = 5,
	["eat_duration"] = 4,
	["patrol_interval"] = 6,
	["patrol_duration"] = 500,
	["range"] = 30,
	["velocity"] = 8,
	["speed"] = 1.25,
	["base"] = 4, -- money generation
	["adorneeOffset"] = Vector3.new(0, 5, 0),
	YOffset = 0.925,
}

module["Hippo"] = {
["rarity"] = "common",
	["eat_interval"] = 6,
	["eat_duration"] = 5,
	["range"] = 30,
	["patrol_interval"] = 8,
	["velocity"] = 8,
	["speed"] = 2,
	["patrol_duration"] = 500,
	["base"] = 6,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
}

module["Rhino"] = {
["rarity"] = "common",
	["eat_interval"] = 6,
	["eat_duration"] = 5,
	["range"] = 30,
	["velocity"] = 4,
	["speed"] = 3,
	["patrol_interval"] = 8,
	["patrol_duration"] = 500,
	["base"] = 6,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
	YOffset = 0.994,
}

]]

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
	["rarity"] = "common",
	["velocity"] = 4,
	["speed"] = 2,
	adorneeOffset = Vector3.new(0, 4, 0),
	YOffset = 0.5,
}, common_stats)

module["Panda"] = merge({
	["rarity"] = "common",
	-- ["eat_interval"] = 5,
	-- ["eat_duration"] = 4,
	-- ["patrol_interval"] = 6,
	-- ["patrol_duration"] = 500,
	-- ["range"] = 30,
	["velocity"] = 8,
	["speed"] = 1.25,
	-- ["base"] = 4, -- money generation
	["adorneeOffset"] = Vector3.new(0, 5, 0),
	YOffset = 0.925,
}, common_stats)

module["Elephant"] = merge({
	["rarity"] = "common",
	-- ["eat_interval"] = 6,
	-- ["eat_duration"] = 3,
	-- ["range"] = 30,
	["velocity"] = 4,
	["speed"] = 3,
	YOffset = 1.3,

	-- ["patrol_interval"] = 8,
	-- ["patrol_duration"] = 500,
	-- ["base"] = 8,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
}, common_stats)

module["Hippo"] = merge({
	["rarity"] = "common",
	["velocity"] = 8,

	["speed"] = 2,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
}, common_stats)

module["Lion"] = merge({
	["rarity"] = "uncommon",

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
	["velocity"] = 6,
	["rarity"] = "uncommon",

	["speed"] = 1,
	["adorneeOffset"] = Vector3.new(0, 5, 0),
	YOffset = 0.726+0.725-0.208 -- +0.543+0.725,
}, common_stats)

module["Dog"] = merge({
	["velocity"] = 8,
	["rarity"] = "uncommon",

	["speed"] = 1.2,
	YOffset = -0.488, -- lvl 9
	--lvl38 0.543

	["adorneeOffset"] = Vector3.new(0, 5, 0),
}, common_stats)

local rhino: PetTypes.petInitFrontend = merge({
	-- ["eat_interval"] = 6,
	-- ["eat_duration"] = 5,
	-- ["range"] = 30,
	["velocity"] = 4,
	["speed"] = 3,
	["rarity"] = "common",
	-- ["patrol_interval"] = 8,
	-- ["patrol_duration"] = 500,
	-- ["base"] = 6,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
	YOffset = 0.994,
}, common_stats)
module["Rhino"] = rhino
--
return module
