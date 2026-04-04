local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
--[[
    handle the current PetData table to return the incomes
]]

local module = {}


-- Define booster types and their pet mappings
local coinBooster = {
	["Pig"] = 2,
	["Elephant"] = 1.25,
	["Panda"] = 1.25,
}

local hagglingBooster = {
	["Giraffe"] = 10,
}

export type boosterType = "coinBooster" | "hagglingBooster"

local boosterConfigs = {
	coinBooster = coinBooster,
	hagglingBooster = hagglingBooster,
}

--[=[
	Filterthe pets thataren't used
	@param string
	@return boolean
]=]
local isPetBoosterByTheMoment = function(name: string)
	return name == "Pig" or name == "Elephant" or name == "Giraffe" or name == "Panda"
end



export type boosterList = { [PetTypes.petNames]: { number} }
--[=[
	Returns a boosterList for a boosterType.
	@param PetTypes.PetsDataStore
	@return boosterList
]=]
function module.mapPetsToBoosters(petsRegistry: PetTypes.PetsDataStore): {boosterType : boosterList}
	local result = {}

	-- Initialize each booster type with empty table
	for boosterType, _ in pairs(boosterConfigs) do
		result[boosterType] = {}
	end

	-- For each pet in registry, check which boosters it qualifies for
	for petId, petData in pairs(petsRegistry) do
		local petName = petData.petName
		if not isPetBoosterByTheMoment(petName) then 
			continue
		end
		-- Check each booster type
		for boosterType, boosterMap in pairs(boosterConfigs) do
			if boosterMap[petName] then
				local boostType = table.clone(result[boosterType])
				-- Insert pet into this booster type (preserves duplicates by using array-like insertion)
				
				do 
					local newPet = boostType[petName] and table.clone(boostType[petName]) or {}
					table.insert( newPet, boosterMap[petName]) 
					boostType[petName] = newPet
				end

				result[boosterType] = boostType
			end
		end
	end

	return result
end

export type petsValue = { [string]: number }

--[=[
	Returns the total boost for each pet and the total boost from a boosterList
	@param PetTypes.PetsDataStore
	@return boosterList
]=]
function module.totalBoost(boosterList: boosterList)
    -- First map: aggregate sums
	local petsValue: { [string]: number } = {}
	for petName, petsBooster in pairs(boosterList) do
		for _, value in ipairs(petsBooster) do
			if petsValue[petName] then
				petsValue[petName] += value
			else
				petsValue[petName] = value
			end
		end
	end

	

	-- Total sum of first map
	local totalSum = 0
	for _, value in pairs(petsValue) do
		totalSum += value
	end
    return petsValue, totalSum
end

return module