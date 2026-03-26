local CollectionService = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local packages = RS.Nevermore.Quenty
local PlotServiceClient = require(ReplicatedStorage.Nevermore.Custom.npc.src.Client.NPC.Servicies.PlotServiceClient)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local BaseObject = require(packages.baseobject.Shared.BaseObject)
local Promise = require(packages.promise.Shared.Promise)

type TargetController = {
	GetGoal: (self: TargetController) -> Vector3?,
	CalculatePath: (self: TargetController, goal: Vector3) -> any,
	_getRandomNearbyPosition: (self: TargetController, radius: number?) -> Vector3?,
	_character: Model,
	_root: BasePart,
	startPos: Vector3,
	_range: number,
	_serviceBag: any,
	_currentPlayer: Player?,
	_humanoidTracker: any,
	YOffset: number,
	maid: any,
	_lastGoalPos: Vector3?,
}

local TargetController = setmetatable({}, BaseObject)
TargetController.__index = TargetController

function TargetController.new(data, serviceBag: any)
	local self = setmetatable(BaseObject.new() :: any, TargetController)
	local character = data.pet
	self._character = character
	self._root = data.root
	self.startPos = self._root.Position

	self._range = data.range
	self._serviceBag = serviceBag

	self._currentPlayer = nil
	self._humanoidTracker = nil
	self.YOffset = data.YOffset

	self.maid = Maid.new()
	self._lastGoalPos = self.startPos

	return self
end

-- GET A RANDOM POINT FROM THE PLOT
function TargetController:_getRandomNearbyPosition(radius: number?): Vector3?
	local origin = self._root.Position

	local owner: string = self._character:FindFirstChild("Owner").Value

	-- owner may be not initialized yet
	if not owner then
		return
	end

	local plot = assert(CollectionService:GetTagged("plot_" .. owner)[1], "player not initialized")

	local boundedPos = PlotServiceClient:GetRandPosition(plot, self.YOffset)

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

function TargetController:GetGoal(): Vector3?
	local currentGoal = self:_getRandomNearbyPosition()

	if not self._lastGoalPos or (self._lastGoalPos - currentGoal).Magnitude > 3 then
		self._lastGoalPos = currentGoal
		return currentGoal
	end
	return nil
end

function TargetController:CalculatePath(goal: Vector3): Promise.Promise<Path>
	local Path = PathfindingService:CreatePath({
		AgentCanJump = true,
		AgentRadius = self._character:GetExtentsSize().X,
		AgentHeight = self._character:GetExtentsSize().Y,
		WaypointSpacing = 2,
		Costs = {
			GroundPlastic = 1,
			Snow = math.huge,
			Metal = math.huge,
		},
	})
	local currentPos = self._root.Position

	self.maid:DoCleaning()
	local blocked = Path.Blocked:Connect(function(blockedWaypointIndex)
		self:CalculatePath(goal)
	end)
	self.maid:GiveTask(blocked)

	return Promise.spawn(function(resolve, reject)
		local ok, err = pcall(function()
			Path:ComputeAsync(currentPos, goal)
		end)
		if not ok then
			reject(err or "Failed to compute path")
			return
		end
		return resolve(Path)
	end)
end

return TargetController
