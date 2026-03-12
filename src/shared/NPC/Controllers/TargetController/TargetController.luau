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

function TargetingController:getRandomNearbyPosition(radius: number?): Vector3?
	local origin = self._root.Position
	-- local angle = math.rad(math.random(0, 360))
	-- local range = radius or self._range
	-- local distance = math.random() * range
	-- local xOffset = math.cos(angle) * distance
	-- local zOffset = math.sin(angle) * distance
	-- local randPosition = Vector3.new(origin.X + xOffset, origin.Y, origin.Z + zOffset)

	local owner: string = self._character:FindFirstChild("Owner").Value

	-- owner may be not initialized yet
	if not owner then
		return
	end

	-- if not owner then
	-- 	print("Player has left ", owner)
	-- 	return
	-- end

	local plot = assert(CollectionService:GetTagged("plot_" .. owner)[1], "player not initialized")

	-- if self.calcYOffset then
	-- 	self.YOffset = self.calcYOffset(self.YOffset)
	-- end
	local boundedPos = FenceBoundsService:GetRandPosition(plot, self.YOffset)

	return boundedPos
end

return TargetingController
