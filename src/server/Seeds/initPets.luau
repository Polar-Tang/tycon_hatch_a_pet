local ServerScriptService = game:GetService("ServerScriptService")
local Registry = require(ServerScriptService.Pets.Registry.Registry)

local init_data = {
    ["Fox"] = {
		petProg = 0,
        character = workspace:FindFirstChild("Fox"),
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Fox", 
		petLvl = 1,
		petStats = {
            ["Health"] = 1,
            ["Melee"] = 1,
            ["Stamina"] = 1,
        },
	},
    ["Hippo"] = {
		petProg = 0,
        character = workspace:FindFirstChild("Hippo"),
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Hippo", 
		petLvl = 1,
		petStats = {
            ["Health"] = 1,
            ["Melee"] = 1,
            ["Stamina"] = 1,
        },
	},
     ["Rhino"] = {
		petProg = 0,
        character = workspace:FindFirstChild("Rhino"),
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Rhino", 
		petLvl = 1,
		petStats = {
            ["Health"] = 1,
            ["Melee"] = 1,
            ["Stamina"] = 1,
        },
	},
    ["Elephant"] = {
		petProg = 0,
        character = workspace:FindFirstChild("Elephant"),
		isInvoked = true,
		avaiblePoints = 0,
		petName = "Elephant", 
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