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

local specs: { [PetData.petNames]: SeedSpec } = {
	Fox = { petLvl = 3, petProg = 10, avaiblePoints = 1, petStats = { Health = 2, Melee = 3, Stamina = 1 } },
	Hippo = { petLvl = 5, petProg = 0, avaiblePoints = 0, petStats = { Health = 6, Melee = 2, Stamina = 2 } },
	Rhino = { petLvl = 12, petProg = 40, avaiblePoints = 3, petStats = { Health = 5, Melee = 7, Stamina = 4 } },
	Elephant = { petLvl = 8, petProg = 25, avaiblePoints = 2, petStats = { Health = 7, Melee = 3, Stamina = 3 } },
	Panda = { petLvl = 6, petProg = 60, avaiblePoints = 1, petStats = { Health = 4, Melee = 2, Stamina = 4 } },
	Lion = { petLvl = 15, petProg = 80, avaiblePoints = 4, petStats = { Health = 6, Melee = 9, Stamina = 5 } },
	Cat = { petLvl = 2, petProg = 50, avaiblePoints = 0, petStats = { Health = 1, Melee = 2, Stamina = 2 } },
	Dog = { petLvl = 4, petProg = 15, avaiblePoints = 1, petStats = { Health = 3, Melee = 3, Stamina = 2 } },
	Pig = { petLvl = 7, petProg = 35, avaiblePoints = 2, petStats = { Health = 5, Melee = 1, Stamina = 6 } },
	Giraffe = { petLvl = 9, petProg = 45, avaiblePoints = 2, petStats = { Health = 6, Melee = 4, Stamina = 4 } },
	Wolf = { petLvl = 10, petProg = 20, avaiblePoints = 3, petStats = { Health = 4, Melee = 7, Stamina = 5 } },
	Bear = { petLvl = 11, petProg = 70, avaiblePoints = 3, petStats = { Health = 8, Melee = 6, Stamina = 3 } },
	Turtle = { petLvl = 1, petProg = 0, avaiblePoints = 0, petStats = { Health = 3, Melee = 1, Stamina = 1 } },
	Alpaca = { petLvl = 3, petProg = 30, avaiblePoints = 1, petStats = { Health = 2, Melee = 2, Stamina = 3 } },
	Bull = { petLvl = 13, petProg = 55, avaiblePoints = 4, petStats = { Health = 6, Melee = 8, Stamina = 4 } },
	Gorilla = { petLvl = 14, petProg = 65, avaiblePoints = 4, petStats = { Health = 7, Melee = 8, Stamina = 5 } },
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
