local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage.utils.utils)
local PetData = require(ReplicatedStorage.Pets.PetTypes)
local PetFrontend = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)

-- A distinct seed entry for every name in PetData.allPetNames. Each pet gets its
-- own GUID, rarity (from utils.getPetRarity) and CameraDistanceFactor (from the
-- frontend table), plus a hand-picked level / stat spread so no two are alike.
-- Shape matches PetData.PetData and is keyed by petId, the way InitPlot expects.

type SeedSpec = {
	petLvl: number,
	petProg: number,
	avaiblePoints: number,
	petStats: PetData.petStats,
}

-- Dog, Lion, Tiger, Bear, Gorilla, Wolf, Bull, Fox, Rhino

local specs: { [PetData.petNames]: SeedSpec } = {
	Panda = { petLvl = 80, petProg = 10, avaiblePoints = 60, petStats = { Health = 2, Melee = 3, Stamina = 1 } },
	Rhino = { petLvl = 80, petProg = 40, avaiblePoints = 60, petStats = { Health = 5, Melee = 7, Stamina = 4 } },
	Lion = { petLvl = 80, petProg = 80, avaiblePoints = 60, petStats = { Health = 6, Melee = 9, Stamina = 5 } },
	Dog = { petLvl = 80, petProg = 15, avaiblePoints = 60, petStats = { Health = 3, Melee = 3, Stamina = 2 } },
	Wolf = { petLvl = 80, petProg = 20, avaiblePoints = 60, petStats = { Health = 4, Melee = 7, Stamina = 5 } },
	Bear = { petLvl = 80, petProg = 70, avaiblePoints = 60, petStats = { Health = 8, Melee = 6, Stamina = 3 } },
	Bull = { petLvl = 80, petProg = 55, avaiblePoints = 60, petStats = { Health = 6, Melee = 8, Stamina = 4 } },
	Gorilla = { petLvl = 80, petProg = 65, avaiblePoints = 60, petStats = { Health = 7, Melee = 8, Stamina = 5 } },
}

local init_data: PetData.PetsDataStore = {}

for _, petName in ipairs(PetData.allPetNames) do
	local spec = specs[petName]
	if not spec then
		warn("initPets: no seed spec for pet", petName)
		continue
	end

	local petId = HttpService:GenerateGUID(false)
	local frontend = PetFrontend[petName]

	init_data[petId] = {
		petId = petId,
		petName = petName,
		petProg = spec.petProg,
		petLvl = spec.petLvl,
		avaiblePoints = spec.avaiblePoints,
		isInvoked = false,
		petStats = spec.petStats,
		rarity = utils.getPetRarity(petName) or "common",
		CameraDistanceFactor = frontend and frontend.CameraDistanceFactor or 1,
	}
end

return function(player)
	return init_data
end
