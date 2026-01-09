local RS = game:GetService("ReplicatedStorage")

local packages = RS.Nevermore.Quenty
local BaseObject = require(packages.baseobject.Shared.BaseObject)
local SoundUtils = require(packages.sounds.Shared.SoundUtils)

local SoundController = setmetatable({}, BaseObject)
SoundController.__index = SoundController

function SoundController.new(model, serviceBag)
	if not model then
		return nil
	end

	local base = BaseObject.new(model)
	local self = setmetatable(base, SoundController)
	self._serviceBag = serviceBag

	return self
end

function SoundController:RegistrySounds(config)
	self._sounds = config
end

function SoundController:_getRandomSound(soundIds)
	local index = math.random(1, #soundIds)
	return soundIds[index]
end

-- Give a key to play it from the _sounds registry
function SoundController:PlayRandSound(category)
	assert(self._sounds, "registry sounds to this instance using ReagistrySounds")

	local sounds = self._sounds[category]
	assert(sounds, "that sound key does not exists")
	local SoundUtils = self._serviceBag:GetService(SoundUtils)

	local soundId = self._getRandomSound(sounds)
	local sound = SoundUtils.playFromIdInParent(soundId, self.model.Head)
	sound.Volume = 1
	sound.RollOffMode = Enum.RollOffMode.Linear
	sound.RollOffMaxDistance = 100
	sound.RollOffMinDistance = 10
	sound.PlayOnRemove = true
end

return SoundController
