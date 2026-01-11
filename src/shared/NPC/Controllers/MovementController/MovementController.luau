-- MovementController.lua
-- TODO: Implement a method for completly stop moving the character
local ReplicatedSorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local PathfindingUtils = require(ReplicatedStorage.Nevermore.Quenty.pathfindingutils.Shared.PathfindingUtils)
local Promise = require(ReplicatedStorage.Nevermore.Quenty.promise.Shared.Promise)

local STOP_DISTANCE = 6

local MovementController = {}
MovementController.__index = MovementController

function MovementController.new(data, serviceBag: any)
	local self = setmetatable({}, MovementController)
	local model = data.pet
	self.Model = model
	self.velocity = data.velocity
	assert("model.PrimaryPart ", model.PrimaryPart)
	self._root = model.PrimaryPart
	self._serviceBag = serviceBag
	self.anims = data.animations

	self._maid = Maid.new()
	self._pathMaid = Maid.new()
	self._lastTarget = nil
	self._currentPath = nil

	return self
end

function MovementController:getAnimHandler()
	local BinderProvider = self._serviceBag:GetService(_G.BinderProvider)

	-- local WeaponBinder = BinderProvider:Get("Armed")
	local AnimationBinder = BinderProvider:Get("AnimationHandler")
	self._AnimationHandler = AnimationBinder:Get(self.Model)
end

function MovementController:ChangeVelocity(v: number)
	self.velocity = v
end

local function clampToBounds(position, boundsPart)
	local relative = boundsPart.CFrame:PointToObjectSpace(position)
	local halfSize = boundsPart.Size * 0.5

	relative = Vector3.new(
		math.clamp(relative.X, -halfSize.X, halfSize.X),
		relative.Y,
		math.clamp(relative.Z, -halfSize.Z, halfSize.Z)
	)

	return boundsPart.CFrame:PointToWorldSpace(relative)
end

function MovementController:MoveTo(targetPosition)
	if (self._lastTarget and ((self._lastTarget - targetPosition).Magnitude > 0)) or self.isMoving then
		self:Stop()
	end
	self._lastTarget = targetPosition
	targetPosition = clampToBounds(targetPosition, workspace.FenceBounds)
	print("wtf?")
	return self:PlainMove(targetPosition)
end

function MovementController:Stop()
	self._pathMaid:DoCleaning()
	self._currentPath = nil
	self._waypoints = nil
	self.isMoving = false
	if self._currentTween then
		self._currentTween:Cancel()
	end
	if self._AnimationHandler then
		self._AnimationHandler:LoadAnimation(false, "walk")
	end
	-- Fire an event to report the last position to the server
end

function MovementController:PlainMove(targetPosition)
	if not self._AnimationHandler then
		self:getAnimHandler()
	end

	return Promise.new(function(resolve, reject)
		-- Cancel any existing movement
		if self._currentTween then
			self._currentTween:Cancel()
		end

		-- Rotation phase
		local rotateTime = 0.5
		local lookThatShit = CFrame.lookAt(self._root.Position, targetPosition) * CFrame.Angles(0, math.rad(90), 0)
		local rotateTween = TweenService:Create(
			self._root,
			TweenInfo.new(rotateTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
			{ CFrame = lookThatShit }
		)
		rotateTween:Play()

		-- Wait for rotation to complete, then move
		task.delay(rotateTime, function()
			self.isMoving = true

			local distance = (targetPosition - self._root.Position).Magnitude
			local timeToReach = distance / self.velocity

			self._AnimationHandler:LoadAnimation(true, "walk")
			self._currentTween = TweenService:Create(
				self._root,
				TweenInfo.new(timeToReach, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
				{ Position = targetPosition }
			)
			self._currentTween:Play()

			task.delay(timeToReach, function()
				self._AnimationHandler:LoadAnimation(false, "walk")
				self.isMoving = false
				-- ✅ Resolve with timeToReach
				resolve(timeToReach)
			end)
		end)
	end)
end

function MovementController:GetMoveDuration()
	return self.timeToReach
end
function MovementController:Destroy()
	self:Stop()
	self._maid:DoCleaning()
end

return MovementController
