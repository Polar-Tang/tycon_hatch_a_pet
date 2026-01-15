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
	self._root = model.PrimaryPart
	self._serviceBag = serviceBag
	self.anims = data.animations
	self.speed = data.speed

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

function MovementController:_clampToBounds(position)
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

	-- GETTING THE POSITION, REALLY HOPE TO VOID VECTOR HAPPEN HERE
	local possibleInf = (bouncedPosition - self._root.Position).Magnitude / self.velocity
	if possibleInf ~= possibleInf or bouncedPosition.Y < 20 or self._root.Position.Y < 20 then
		print(self.Model.Name, "self._root.Position ", self._root.Position)
		print(
			self.Model.Name,
			"all the types ",
			typeof(self._root.Position.X),
			typeof(self._root.Position.Y),
			typeof(self._root.Position.Z)
		)

		print(self.Model.Name, "self._root.Position ", bouncedPosition)
		print(
			self.Model.Name,
			"all the types ",
			typeof(bouncedPosition.X),
			typeof(bouncedPosition.Y),
			typeof(bouncedPosition.Z)
		)
	end
	return bouncedPosition
end

function MovementController:MoveTo(targetPosition)
	if (self._lastTarget and ((self._lastTarget - targetPosition).Magnitude > 0)) or self.isMoving then
		self:Stop()
	end
	self._lastTarget = targetPosition
	targetPosition = self:_clampToBounds(targetPosition)
	if targetPosition.Y < 20 then
		targetPosition = workspace.FenceBounds.CFrame.Position
	end
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
	--[[
		print(self.Model.Name, "targetPosition.Y ", targetPosition)
		print(
			self.Model.Name,
			"targetPosition ",
			typeof(targetPosition.X),
			typeof(targetPosition.Y),
			typeof(targetPosition.Z)
		)
	
		print(self.Model.Name, "type of ", typeof(targetPosition.Y))
	]]

	return Promise.new(function(resolve, reject)
		-- Cancel any existing movement
		if self._currentTween then
			self._currentTween:Cancel()
		end

		-- BEFORE SPINNING
		local possibleInf = (targetPosition - self._root.Position).Magnitude / self.velocity
		if possibleInf ~= possibleInf or targetPosition.Y < 20 or self._root.Position.Y < 20 then
			reject("root position corruption")

			print(self.Model.Name, "self._root.Position ", self._root.Position)
			print(
				self.Model.Name,
				"all the types ",
				typeof(self._root.Position.X),
				typeof(self._root.Position.Y),
				typeof(self._root.Position.Z)
			)

			print(self.Model.Name, "self._root.Position ", targetPosition)
			print(
				self.Model.Name,
				"all the types ",
				typeof(targetPosition.X),
				typeof(targetPosition.Y),
				typeof(targetPosition.Z)
			)
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

			-- AFTER SPINING, BEFORE MOVE AND CALCULATE VELOCIITY
			local possibleInf = (targetPosition - self._root.Position).Magnitude / self.velocity
			if possibleInf ~= possibleInf or targetPosition.Y < 20 or self._root.Position.Y < 20 then
				reject("root position corruption")
				print(self.Model.Name, "self._root.Position ", self._root.Position)
				print(
					self.Model.Name,
					"all the types ",
					typeof(self._root.Position.X),
					typeof(self._root.Position.Y),
					typeof(self._root.Position.Z)
				)

				print(self.Model.Name, "self._root.Position ", targetPosition)
				print(
					self.Model.Name,
					"all the types ",
					typeof(targetPosition.X),
					typeof(targetPosition.Y),
					typeof(targetPosition.Z)
				)
			end
			--[[
			6  self._root.Position DELAY 0, -3.4028234663852886e+38, 0  -  Server - MovementController:139
 			all the types DELAY number number number  -  Server - MovementController:140
  			self._root.Position DELAY  10.600006103515625, 22.39059829711914, 102.79998779296875  -  Server - MovementController:146
  			all the types DELAY number number number  -  Server - MovementController:147
			]]

			local distance = (targetPosition - self._root.Position).Magnitude
			local timeToReach = distance / self.velocity
			local animationController: AnimationTrack = self._AnimationHandler:LoadAnimation(true, "walk")
			animationController:AdjustSpeed(self.speed)

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
