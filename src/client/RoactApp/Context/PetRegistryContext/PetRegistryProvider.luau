local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetData = require(ReplicatedStorage.Pets.PetTypes)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Rx = require(ReplicatedStorage.Nevermore.Quenty.rx.Shared.Rx)
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
	local function on_registry_change(newPets: PetTypes.PetsDataStore)
		local boosters = {}
		for petId, petData in pairs(newPets) do
			local componentName = petData.petName .. "Booster"
			local boosterRoot = script.Parent.Parent.Parent.Components.boosters

			local moduleScript = boosterRoot:FindFirstChild(componentName)
			if moduleScript then
				local ok, comp = pcall(require, moduleScript)
				if ok then
					boosterModule = comp
				end
			end

			if boosterModule then
				boosters[#boosters + 1] = Roact.createElement(boosterModule, { petData = petData })
			end
		end

		self:setState({
			pets = newPets,
			boosters = boosters,
		})
	end
	if _G.pets_registry_value and _G.pets_registry_value.Changed then
		local connection = _G.pets_registry_value
			:Observe()
			:Pipe({
				Rx.where(function(pets: { string: PetData.PetData })
					local notRepeat = {}
					local counter_registry = {}

					for _, pet in pairs(pets) do
						local name = pet.petName

						if not isPetBoosterByTheMoment(name) then
							continue
						end

						if not counter_registry[name] then
							counter_registry[name] = 1
							notRepeat[name] = pet
						else
							counter_registry[name] += 1
						end

						return {
							listNotRepeat = notRepeat,
							listRepeats = counter_registry,
						}
					end
				end),
			})
			:Subscribe(function(newPets)
				on_registry_change(newPets)
			end)

		self._maid:GiveTask(connection)
	end

	-- apply initial value on mount
	on_registry_change(_G["pets_registry"] or {} :: PetTypes.PetsDataStore)
end

function PetRegistryProvider:unMount()
	self._maid:DoCleaning()
end

return PetRegistryProvider
