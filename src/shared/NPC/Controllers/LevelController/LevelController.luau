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
	if self.model:GetAttribute("Level") >= 150 then
		return
	end
	PetLevel:FireServer(self.model)
end

return LevelController
