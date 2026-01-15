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

function TargetingController:_clampToBounds(position)
	local fenceCF = workspace.FenceBounds.CFrame
	local fenceSize = workspace.FenceBounds.Size

	local offset = position - fenceCF.Position

	local right = fenceCF.RightVector
	local up = fenceCF.UpVector
	local look = fenceCF.LookVector

	local x = offset:Dot(right)
	local y = offset:Dot(up)
	local z = offset:Dot(look)

	local half = fenceSize * 0.5

	x = math.clamp(x, -half.X, half.X)
	z = math.clamp(z, -half.Z, half.Z)
	local bouncedPosition = fenceCF.Position + right * x + up * y + look * z

	return bouncedPosition
end

function TargetingController:getRandomNearbyPosition(radius: number?): Vector3
	local origin = self._root.Position
	local angle = math.rad(math.random(0, 360))
	local range = radius or self._range
	local distance = math.random() * range
	local xOffset = math.cos(angle) * distance
	local zOffset = math.sin(angle) * distance
	local randPosition = Vector3.new(origin.X + xOffset, origin.Y, origin.Z + zOffset)
	local boundedPos = self:_clampToBounds(randPosition)
	if (boundedPos - origin).Magnitude < 2 then
		local fenceCF = workspace.FenceBounds.CFrame
		local center = fenceCF.Position

		-- direction from center to pet
		local away = (origin - center).Unit

		-- reverse it (go inward)
		local inward = -away

		-- add randomness (cone)
		local randomAngle = math.rad(math.random(-40, 40))
		local cos = math.cos(randomAngle)
		local sin = math.sin(randomAngle)

		local dir = Vector3.new(inward.X * cos - inward.Z * sin, 0, inward.X * sin + inward.Z * cos).Unit

		-- pick a distance that creates a long walk
		local bounceDistance = math.random(8, 18)
		local newPos = center + dir * bounceDistance
		return Vector3.new(newPos.X, origin.Y, newPos.Z)
	end
	return boundedPos
end

return TargetingController
