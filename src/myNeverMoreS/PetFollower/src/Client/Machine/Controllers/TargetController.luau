local PathfindingService = game:GetService("PathfindingService")
local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = RS.Nevermore.Quenty
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local PathfindingUtils = require(ReplicatedStorage.Nevermore.Quenty.pathfindingutils.Shared.PathfindingUtils)
local Promise = require(ReplicatedStorage.Nevermore.Quenty.promise.Shared.Promise)
local BaseObject = require(packages.baseobject.Shared.BaseObject)

local TargetController = setmetatable({}, BaseObject)
TargetController.__index = TargetController

function TargetController.new(data: NpcFighterTypes.controllerdataInint, serviceBag: any, player)
	local self = setmetatable(data, TargetController)
	self._playerLastPos = nil
	return self
end

function TargetController.Update(self: NpcFighterTypes.TargetController): Vector3?
	local playerChar = self.player_character
	local playerPos = playerChar.PrimaryPart.Position

	if not self._playerLastPos or self._playerLastPos ~= playerPos then
		self._playerLastPos = playerPos

		return self._playerLastPos
	end
	return nil
end

function TargetController.GetWaypoints(self: NpcFighterTypes.TargetController, goal): Promise.Promise<Path>
	local Path = PathfindingService:CreatePath({
		AgentRadius = 3,
		AgentHeight = 6,
		AgentCanJump = true,
		Costs = {
			Snow = math.huge,
			Metal = math.huge,
		},
	})
	return PathfindingUtils.promiseComputeAsync(Path, self.hrp.Position, goal)
end

-- MOVE NEARBY A GIVEN BASEPART
function TargetController:getNearbyTo(targetPart: BasePart, radius: number?)
	radius = radius or 5

	local targetPos = targetPart.Position

	local angle = math.rad(math.random(0, 360))
	local distance = math.random(2, radius)

	local offsetX = math.cos(angle) * distance
	local offsetZ = math.sin(angle) * distance

	local destination = Vector3.new(targetPos.X + offsetX, targetPos.Y + self.YOffset, targetPos.Z + offsetZ)

	return destination
end

function TargetController.DestroyNPC(self: NpcFighterTypes.TargetController)
	self.pet:Destroy()
end

return TargetController
