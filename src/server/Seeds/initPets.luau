local ServerScriptService = game:GetService("ServerScriptService")
local Registry = require(ServerScriptService.Pets.Registry.Registry)

local init_data = {
    ["Fox"] = {
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Fox", 
        petId = "Fox",
		petLvl = 1,
		petStats = {
            ["Health"] = 1,
            ["Melee"] = 1,
            ["Stamina"] = 1,
        },
	},
    ["Hippo"] = {
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Hippo", 
        petId = "Hippo",
		petLvl = 1,
		petStats = {
            ["Health"] = 1,
            ["Melee"] = 1,
            ["Stamina"] = 1,
        },
	},
     ["Rhino"] = {
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Rhino", 
        petId = "Rhino",
		petLvl = 1,
		petStats = {
            ["Health"] = 1,
            ["Melee"] = 1,
            ["Stamina"] = 1,
        },
	},
    ["Elephant"] = {
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Elephant", 
        petId = "Elephant", 
		petLvl = 1,
		petStats = {
            ["Health"] = 1,
            ["Melee"] = 1,
            ["Stamina"] = 1,
        },
	},
    ["Panda"] = {
		petProg = 0,
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Panda", 
        petId = "Panda", 
		petLvl = 1,
		petStats = {
            ["Health"] = 1,
            ["Melee"] = 1,
            ["Stamina"] = 1,
        },
	},
}

return function(player)
    local bestiaryHandler = Registry:GetHandler(player)

    local newPets
    for petName, petData in pairs(init_data) do 
        newPets = bestiaryHandler:listNewPet(petName, petData)
    end
    return newPets
end