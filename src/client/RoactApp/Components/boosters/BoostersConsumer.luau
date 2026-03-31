local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local Roact = require(ReplicatedStorage.Roact)

local PetRegistryContext = require(script.Parent.Parent.Parent.Context.PetRegistryContext.PetRegistryContext)
local useContext = require(script.Parent.Parent.Parent.Context.Utils.useContext)

local BoostersConsumer = Roact.Component:extend("BoostersConsumer")

-- Define booster types and their pet mappings
local coinBooster = {
	["Pig"] = 2,
	["Elephant"] = 1.25,
	["Panda"] = 1.25,
}

local hagglingBooster = {
	["Giraffe"] = 1.5,
}

local boosterConfigs = {
	coinBooster = coinBooster,
	hagglingBooster = hagglingBooster,
}

-- Map pets to booster table by booster type
local function mapPetsToBooters(petsRegistry: PetTypes.PetsDataStore): { [string]: { [string]: PetTypes.PetData } }
	local result = {}

	-- Initialize each booster type with empty table
	for boosterType, _ in pairs(boosterConfigs) do
		result[boosterType] = {}
	end

	-- For each pet in registry, check which boosters it qualifies for
	for petId, petData in pairs(petsRegistry) do
		local petName = petData.petName

		-- Check each booster type
		for boosterType, boosterMap in pairs(boosterConfigs) do
			if boosterMap[petName] then
				local boostType = table.clone(result[boosterType])
				-- Insert pet into this booster type (preserves duplicates by using array-like insertion)
				boostType[petName] = boosterMap[petName]
				result[boosterType] = boostType
			end
		end
	end

	return result
end

function BoostersConsumer:render()
	local withCtx = useContext({
		PetRegistryContext = PetRegistryContext,
	})

	return withCtx(function(ctx)
		local pets = ctx.PetRegistryContext.pets :: PetTypes.PetsDataStore
		local boosters = mapPetsToBooters(pets)

		-- Create UI elements for each booster type
		local boosterComponents = {}
		for boosterType, boosterPets in pairs(boosters) do
			-- Could render booster component here with the mapped pets
			-- For now, just store the structure
			local module = require(script.Parent.boosterComponents[boosterType])
			boosterComponents[boosterType] = Roact.createElement(module, boosterPets)
		end
		print(" boosterComponents ", boosterComponents)
		return Roact.createFragment(boosterComponents)
	end)
end

return BoostersConsumer
