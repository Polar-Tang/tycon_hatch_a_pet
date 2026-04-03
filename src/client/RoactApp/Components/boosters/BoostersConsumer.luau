local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)
local Roact = require(ReplicatedStorage.Roact)
local incomeUtils = require(ReplicatedStorage.utils.incomeUtils)

local PetRegistryContext = require(script.Parent.Parent.Parent.Context.PetRegistryContext.PetRegistryContext)
local useContext = require(script.Parent.Parent.Parent.Context.Utils.useContext)

local BoostersConsumer = Roact.Component:extend("BoostersConsumer")

type boosterCompenets = { [incomeUtils.boosterType]: any }
local components: boosterCompenets = {
	["coinBooster"] = require(script.Parent.boosterComponents.coinBooster),
	["hagglingBooster"] = require(script.Parent.boosterComponents.hagglingBooster),
}


function BoostersConsumer:render()
	local withCtx = useContext({
		PetRegistryContext = PetRegistryContext,
	})

	return withCtx(function(ctx)
		local pets = ctx.PetRegistryContext.pets :: PetTypes.PetsDataStore
		local boosters = incomeUtils.mapPetsToBoosters(pets)

		-- Create UI elements for each booster type
		local boosterComponents = {}
		for boosterType, boosterPets in pairs(boosters) do
			-- Could render booster component here with the mapped pets
			-- For now, just store the structure
			boosterComponents[boosterType] = Roact.createElement(components[boosterType], boosterPets)
		end
		return Roact.createFragment(boosterComponents)
	end)
end

return BoostersConsumer
