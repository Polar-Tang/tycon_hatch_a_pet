local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage.utils.utils)
local PetData = require(ReplicatedStorage.Pets.PetTypes)

local foxId = HttpService:GenerateGUID(false)
local RhinoId = HttpService:GenerateGUID(false)
local ElephantId = HttpService:GenerateGUID(false)
local PandaId = HttpService:GenerateGUID(false)
local HippoId = HttpService:GenerateGUID(false)

local LionId = HttpService:GenerateGUID(false)
local CatId = HttpService:GenerateGUID(false)
local DogId = HttpService:GenerateGUID(false)

local init_data = {
	[foxId] = {
		rarity = "common",
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 150,
		petName = "Fox",
		petId = foxId,
		petLvl = 150,
		petStats = {
			["Health"] = 1,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
	},

	[HippoId] = {
		rarity = "common",
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 150,
		petName = "Hippo",
		petId = HippoId,
		petLvl = 150,
		petStats = {
			["Health"] = 1,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
	},
	[RhinoId] = {
		rarity = "common",
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 150,
		petName = "Rhino",
		petId = RhinoId,
		petLvl = 150,
		petStats = {
			["Health"] = 1,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
	},
	[ElephantId] = {
		rarity = "common",
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 150,
		petName = "Elephant",
		petId = ElephantId,
		petLvl = 150,
		petStats = {
			["Health"] = 1,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
	},
	[PandaId] = {
		rarity = "common",
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 150,
		petName = "Panda",
		petId = PandaId,
		petLvl = 150,
		petStats = {
			["Health"] = 1,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
	},
	[DogId] = {
		rarity = "uncommon",
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 150,
		petName = "Dog",
		petId = DogId,
		petLvl = 150,
		petStats = {
			["Health"] = 1,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
	},
	[LionId] = {
		rarity = "uncommon",
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 150,
		petName = "Lion",
		petId = LionId,
		petLvl = 150,
		petStats = {
			["Health"] = 1,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
	},
	[CatId] = {
		rarity = "uncommon",
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 150,
		petName = "Cat",
		petId = CatId,
		petLvl = 150,
		petStats = {
			["Health"] = 1,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
	},
}

return function(player): PetData.PetsDataStore
	-- -- local bestiaryHandler = Registry:GetHandler(player)

	-- -- local newPets

	-- local idArr = {
	-- 	foxId,
	-- 	HippoId,
	-- 	RhinoId,
	-- 	ElephantId,
	-- 	PandaId,
	-- }

	-- local petShit = {
	-- -- for i = 1, 3 do
	-- local rand = math.random(1, 5)
	-- local petId = idArr[rand]
	-- local petData = init_data[foxId] --init_data[petId]
	-- -- newPets = bestiaryHandler:listNewPet(petName, petData)
	-- petData.petStats = utils.GenerateRandStats(5)
	-- petShit[petId] = petData
	-- end
	return init_data
end
