local module = {}

--[[
The eat interval is always less than the patrol interval
The eat interval + eat duration >= eat_interval
]]

--[[

-- completly OP
module["Fox"] =  {
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

local function merge<T, U>(a: T, b: U): T & U
	local result = {}

	for k, v in pairs(b) do
		result[k] = v
	end

	for k, v in pairs(a) do
		result[k] = v
	end

	return result :: T & U
end

module["Fox"] = merge({
	["velocity"] = 4,
	["speed"] = 2,
	adorneeOffset = Vector3.new(0, 4, 0),
	YOffset = 0.5,
}, common_stats)

module["Panda"] = merge({
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
	-- ["eat_interval"] = 6,
	-- ["eat_duration"] = 3,
	-- ["range"] = 30,
	["velocity"] = 4,
	["speed"] = 3,
	-- ["patrol_interval"] = 8,
	-- ["patrol_duration"] = 500,
	-- ["base"] = 8,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
}, common_stats)

module["Hippo"] = merge({
	["velocity"] = 8,

	["speed"] = 2,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
}, common_stats)

module["Rhino"] = merge({
	-- ["eat_interval"] = 6,
	-- ["eat_duration"] = 5,
	-- ["range"] = 30,
	["velocity"] = 4,
	["speed"] = 3,
	-- ["patrol_interval"] = 8,
	-- ["patrol_duration"] = 500,
	-- ["base"] = 6,
	["adorneeOffset"] = Vector3.new(0, 9, 0),
	YOffset = 0.994,
}, common_stats)
--
return module
