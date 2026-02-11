local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local utils = require(ReplicatedStorage.utils.utils)
local PetData = require(ServerScriptService.types.PetData)

local foxId = HttpService:GenerateGUID(false)
local RhinoId = HttpService:GenerateGUID(false)
local ElephantId = HttpService:GenerateGUID(false)
local PandaId = HttpService:GenerateGUID(false)
local HippoId = HttpService:GenerateGUID(false)

local init_data: PetData.InitData = {
	[foxId] = {
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Fox",
		petId = foxId,
		petLvl = 1,
		petStats = {
			["Health"] = 1,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
	},

	[HippoId] = {
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Hippo",
		petId = HippoId,
		petLvl = 1,
		petStats = {
			["Health"] = 1,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
	},
	[RhinoId] = {
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Rhino",
		petId = RhinoId,
		petLvl = 1,
		petStats = {
			["Health"] = 1,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
	},
	[ElephantId] = {
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Elephant",
		petId = ElephantId,
		petLvl = 1,
		petStats = {
			["Health"] = 1,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
	},
	[PandaId] = {
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Panda",
		petId = PandaId,
		petLvl = 1,
		petStats = {
			["Health"] = 1,
			["Melee"] = 1,
			["Stamina"] = 1,
		},
	},
}

return function(player): PetData.InitData
	-- local bestiaryHandler = Registry:GetHandler(player)

	-- local newPets

	local idArr = {
		foxId,
		HippoId,
		RhinoId,
		ElephantId,
		PandaId,
	}

	local petShit = {}
	for i = 1, 3 do -- i, petId in ipairs(idArr) do
		local rand = math.random(1, 5)
		local petId = idArr[rand]
		local petData = init_data[petId]
		-- newPets = bestiaryHandler:listNewPet(petName, petData)
		petData.petStats = utils.GenerateRandStats(5)
		petShit[petId] = petData
	end
	return petShit
end
