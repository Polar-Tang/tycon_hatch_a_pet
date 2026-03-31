local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Roact = require(ReplicatedStorage.Roact)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)

local PetRegistryContext = require(script.Parent.PetRegistryContext)
local PetRegistryProvider = Roact.Component:extend("PetRegistryProvider")

function PetRegistryProvider:init()
	self._maid = Maid.new()
	self:setState({
		pets = _G["pets_registry"] or {} :: PetTypes.PetsDataStore,
		boosters = {},
	})
end

function PetRegistryProvider:render()
	return Roact.createElement(PetRegistryContext.Provider, {
		value = {
			pets = self.state.pets :: PetTypes.PetsDataStore,
			boosters = self.state.boosters :: { any },
		},
	}, self.props[Roact.Children])
end

local isPetBoosterByTheMoment = function(name: string)
	return name == "Pig" or name == "Elephant" or name == "Giraffe" or name == "Panda"
end

function PetRegistryProvider:didMount()
	type filteresPets = { [PetTypes.petNames]: PetTypes.PetData }
	local function filter_pets(newPets: PetTypes.PetsDataStore): filteresPets
		local pets = {}
		for petId, pet in pairs(newPets) do
			if not isPetBoosterByTheMoment(pet.petName) then
				continue
			end
			pets[pet.petName] = pet
		end
		return pets
	end
	if _G.pets_registry_value and _G.pets_registry_value.Changed then
		local connection = _G.pets_registry_value:Observe():Subscribe(function(newPets)
			self:setState(filter_pets(newPets))
		end)

		self._maid:GiveTask(connection)
	end
end

function PetRegistryProvider:unMount()
	self._maid:DoCleaning()
end

return PetRegistryProvider
