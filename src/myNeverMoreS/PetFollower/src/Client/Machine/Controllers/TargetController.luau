local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local Promise = require(ReplicatedStorage.Nevermore.Quenty.promise.Shared.Promise)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
-- local PathFindCustom = require(ReplicatedStorage.utils.PathFindCustom)

-- Base distance from the player each follower stands; the pet's own size is
-- added on top so larger pets don't clip into the player.
local FORMATION_RANGE = 3

local TargetController = {}
TargetController.__index = TargetController

function TargetController.new(data: NpcFighterTypes.controllerdataInint, serviceBag: any, player)
	local dataShit = table.clone(data)
	local self = setmetatable(dataShit, TargetController)
	-- Own a private maid. `data.maid` is the binder maid (owns the controllers +
	-- the pet's teardown); CalculatePath/Destroy DoCleaning their maid, and cleaning
	-- the binder maid here would destroy the pet mid-path. Keep them separate.
	self.maid = Maid.new()
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

	self.maid:DoCleaning()
	local blocked = Path.Blocked:Connect(function(blockedWaypointIndex)
		self:CalculatePath(goal)
	end)
	self.maid:GiveTask(blocked)

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

-- This is producing the goal position used to calculate the path from the movement controller.
-- Each follower stands in a band-relative slot around the player:
--   band 1 -> player's right  ( RightVector * range)
--   band 2 -> player's left   (-RightVector * range)
--   band 3 -> player's back   (-LookVector  * range)
-- A little extra range is added from the pet's own magnitude so bigger pets sit
-- further out and don't overlap the player.
function TargetController._getGoalPos(self: NpcFighterTypes.TargetController): Vector3
	local player_hrp = self.player_character.PrimaryPart
	local band = tonumber(string.match(self.band or "", "%d+")) or 1

	local range = FORMATION_RANGE + (self.pet:GetExtentsSize().Magnitude)/2

	local offset
	if band == 2 then
		offset = player_hrp.CFrame.RightVector * -range -- left
	elseif band == 3 then
		offset = player_hrp.CFrame.LookVector * -range -- back
	else
		offset = player_hrp.CFrame.RightVector * range -- right
	end

	local goal = player_hrp.Position + offset

	-- keep the goal on the player's ground plane (avoid any Y offset)
	return Vector3.new(goal.X, player_hrp.Position.Y, goal.Z)
end

function TargetController.Destroy(self: NpcFighterTypes.TargetController)
	self.maid:DoCleaning()
	self.pet:Destroy()
end

function TargetController:GetTo(basePart: BasePart, distance: number?): Vector3
	distance = distance or 3

	local targetPos = basePart.Position
	local myPos = self.hrp.Position

	-- Direction from target → NPC
	local direction = (myPos - targetPos).Unit

	-- Position in front of the target
	local goalPos = targetPos + direction * distance

	-- Face the target
	return goalPos
end

return TargetController
