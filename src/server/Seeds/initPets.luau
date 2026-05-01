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
	["579ef0e3-ddaa-4f92-8aef-cde22480a7dd"] = {
		["avaiblePoints"] = 100,
		["isInvoked"] = false,
		["petId"] = "579ef0e3-ddaa-4f92-8aef-cde22480a7dd",
		["petLvl"] = 101,
		["petName"] = "Panda",
		["petProg"] = 0,
		["petStats"] = {
			["Health"] = 3,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
		["rarity"] = "common",
	},
	["9ba5e89d-d21b-4884-88fc-a949ec52ae88"] = {
		["avaiblePoints"] = 96,
		["isInvoked"] = false,
		["petId"] = "9ba5e89d-d21b-4884-88fc-a949ec52ae88",
		["petLvl"] = 97,
		["petName"] = "Panda",
		["petProg"] = 0,
		["petStats"] = {
			["Health"] = 2,
			["Melee"] = 1,
			["Stamina"] = 2,
		},
		["rarity"] = "rare",
	},
	["aee2a7bf-06f7-4d46-8a70-bf9b9dc2b8e6"] = {
		["avaiblePoints"] = 70,
		["isInvoked"] = false,
		["petId"] = "aee2a7bf-06f7-4d46-8a70-bf9b9dc2b8e6",
		["petLvl"] = 116,
		["petName"] = "Panda",
		["petProg"] = 0,
		["petStats"] = {
			["Health"] = 21,
			["Melee"] = 26,
			["Stamina"] = 3,
		},
		["rarity"] = "rare",
	},
	["db56a6a8-5c4d-4a9c-ac00-8ae3d10e8cf6"] = {
		["avaiblePoints"] = 36,
		["isInvoked"] = false,
		["petId"] = "db56a6a8-5c4d-4a9c-ac00-8ae3d10e8cf6",
		["petLvl"] = 150,
		["petName"] = "Panda",
		["petProg"] = 18,
		["petStats"] = {
			["Health"] = 20,
			["Melee"] = 12,
			["Stamina"] = 86,
		},
		["rarity"] = "common",
	},
	["e7bb3293-6a1f-4486-b11f-c3552a0c0128"] = {
		["avaiblePoints"] = 123,
		["isInvoked"] = false,
		["petId"] = "e7bb3293-6a1f-4486-b11f-c3552a0c0128",
		["petLvl"] = 124,
		["petName"] = "Panda",
		["petProg"] = 0,
		["petStats"] = {
			["Health"] = 3,
			["Melee"] = 2,
			["Stamina"] = 0,
		},
		["rarity"] = "common",
	},
	["fe5b484e-b68e-4a1b-ba0e-45869a7e79b3"] = {
		["avaiblePoints"] = 93,
		["isInvoked"] = false,
		["petId"] = "fe5b484e-b68e-4a1b-ba0e-45869a7e79b3",
		["petLvl"] = 94,
		["petName"] = "Panda",
		["petProg"] = 0,
		["petStats"] = {
			["Health"] = 0,
			["Melee"] = 5,
			["Stamina"] = 0,
		},
		["rarity"] = "rare",
	},
}

return function(player)
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
