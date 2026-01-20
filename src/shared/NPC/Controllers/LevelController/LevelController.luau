local Events = game.ReplicatedStorage.RemoteEvents
local PetLevel: RemoteEvent = Events.PetLevel

local LevelController = {}

LevelController.__index = LevelController

function LevelController.new(petData)
	local self = setmetatable({}, LevelController)
	self.model = petData.pet
	return self
end

function LevelController:gainXp()
	PetLevel:FireServer(self.model)
end

return LevelController