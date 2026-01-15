local RS = game:GetService("ReplicatedStorage")
local packages = RS.Nevermore.Quenty
local BaseObject = require(packages.baseobject.Shared.BaseObject)
-- TEST IF this doesn't break

local TargetingController = setmetatable({}, BaseObject)
TargetingController.__index = TargetingController

function TargetingController.new(data, serviceBag: any)
	local self = setmetatable(BaseObject.new() :: any, TargetingController)
	local character = data.pet

	self._character = character
	self._root = character.PrimaryPart
	self.startPos = character.PrimaryPart.Position

	self._range = data.range
	self._serviceBag = serviceBag

	self._currentPlayer = nil
	self._humanoidTracker = nil

	return self
end

function TargetingController:getRandomNearbyPosition(radius: number?): Vector3
	local origin = self._root.Position
	local angle = math.rad(math.random(0, 360))
	local range = radius or self._range
	local distance = math.random() * range
	local xOffset = math.cos(angle) * distance
	local zOffset = math.sin(angle) * distance
	return Vector3.new(origin.X + xOffset, origin.Y, origin.Z + zOffset)
end

return TargetingController
