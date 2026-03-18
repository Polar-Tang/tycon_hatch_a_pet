local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local clientUtils = require(StarterPlayer.StarterPlayerScripts.utils.clientUtils)
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local Promise = require(ReplicatedStorage.Nevermore.Quenty.promise.Shared.Promise)
-- local PathFindCustom = require(ReplicatedStorage.utils.PathFindCustom)
local testPart = require(ReplicatedStorage.utils.testPart)
local utils = require(ReplicatedStorage.utils.utils)

local TargetController = {}
TargetController.__index = TargetController

function TargetController.new(data: NpcFighterTypes.controllerdataInint, serviceBag: any, player)
	local dataShit = table.clone(data)
	local self = setmetatable(dataShit, TargetController)
	local playerChar = self.player_character

	local player_hrp = playerChar and playerChar.PrimaryPart
	self._player_hrp = player_hrp
	self._lastGoalPos = self:_getGoalPos()

	self.modelHeight = 4.5 -- utils.GetModelHeight(self.pet)

	return self
end

function TargetController.GetGoal(self: NpcFighterTypes.TargetController): Vector3?
	local currentGoal = self:_getGoalPos()

	-- player should move at least 2 studs for the pet to GetGoal its path, this is to prevent constant path recalculations when the player is standing still or making minor movements
	if (self._lastGoalPos - currentGoal).Magnitude > 3 then
		self._lastGoalPos = currentGoal

		return currentGoal
	end
	return nil
end

function TargetController.CalculatePath(self: NpcFighterTypes.TargetController, goal: Vector3): Promise.Promise<Path>
	local Path = PathfindingService:CreatePath({
		AgentCanJump = true,
		AgentRadius = self.pet:GetExtentsSize().X, -- tighter for a small pet
		AgentHeight = self.pet:GetExtentsSize().Y, -- try 0 because primary part has 0 height above the ground
		WaypointSpacing = 2, -- tighter spacing = smoother path on uneven ground
		Costs = {
			-- need to test in different materials
			GroundPlastic = 1,
			Snow = math.huge,
			Metal = math.huge,
		},
	})
	local currentPos = self.hrp.Position

	--testPart({ Position = currentPos, Name = "StartPos", Color3 = Color3.new(0, 1, 0) })

	-- prove setting the same y to both positions to see if path is still an empty array
	--testPart({ Position = goal, Name = "EndPos", Color3 = Color3.new(1, 0, 0) })
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

-- This is producing the goal position used to calculate the path from the movement controller
function TargetController._getGoalPos(self: NpcFighterTypes.TargetController): Vector3
	-- get nearby to player position
	local nearPlayer = clientUtils.petGoal(self.player_character, 3)

	return nearPlayer
end

return TargetController
