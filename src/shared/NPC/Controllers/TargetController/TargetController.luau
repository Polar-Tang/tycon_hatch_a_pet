local CollectionService = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = RS.Nevermore.Quenty
local FenceBoundsService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local BaseObject = require(packages.baseobject.Shared.BaseObject)
-- TEST IF this doesn't break

local TargetingController = setmetatable({}, BaseObject)
TargetingController.__index = TargetingController

function TargetingController.new(data, serviceBag: any)
	local self = setmetatable(BaseObject.new() :: any, TargetingController)
	local character = data.pet
	self._character = character
	self._root = data.root
	self.startPos = self._root.Position

	self._range = data.range
	self._serviceBag = serviceBag

	self._currentPlayer = nil
	self._humanoidTracker = nil
	self.YOffset = data.YOffset

	return self
end

-- GET A RANDOM POINT FROM THE PLOT
function TargetingController:getRandomNearbyPosition(radius: number?): Vector3?
	local origin = self._root.Position

	local owner: string = self._character:FindFirstChild("Owner").Value

	-- owner may be not initialized yet
	if not owner then
		return
	end

	local plot = assert(CollectionService:GetTagged("plot_" .. owner)[1], "player not initialized")

	local boundedPos = FenceBoundsService:GetRandPosition(plot, self.YOffset)

	-- patrol long distances
	if (boundedPos - origin).Magnitude < 5 then
		local fenceCF = plot.CFrame
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
