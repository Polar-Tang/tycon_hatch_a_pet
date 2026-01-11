local RS = game:GetService("ReplicatedStorage")

local packages = RS.Nevermore.Quenty
local BaseObject = require(packages.baseobject.Shared.BaseObject)
local SoundUtils = require(packages.sounds.Shared.SoundUtils)

local PetAnimatorController = setmetatable({}, BaseObject)
PetAnimatorController.__index = PetAnimatorController

function PetAnimatorController.new(data, serviceBag)
	local model = data.pet
	if not model then
		return nil
	end

	local base = BaseObject.new(model)
	local self = setmetatable(base, PetAnimatorController)
	self.Model = model
	self._serviceBag = serviceBag

	return self
end

function PetAnimatorController:getAnimHandler()
	local BinderProvider = self._serviceBag:GetService(_G.BinderProvider)

	-- local WeaponBinder = BinderProvider:Get("Armed")
	local AnimationBinder = BinderProvider:Get("AnimationHandler")
	self._AnimationHandler = AnimationBinder:Get(self.Model)
end

function PetAnimatorController:PlayIdle()
	self._animHandler:LoadAnimation(true, "idle")
end

return PetAnimatorController
