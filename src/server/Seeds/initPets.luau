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
