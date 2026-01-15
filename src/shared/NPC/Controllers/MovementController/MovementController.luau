-- MovementController.lua
-- TODO: Implement a method for completly stop moving the character
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Promise = require(ReplicatedStorage.Nevermore.Quenty.promise.Shared.Promise)

local MovementController = {}
MovementController.__index = MovementController

local function isValidPosition(pos)
	return pos == pos -- Check for NaN (NaN ~= NaN)
		and pos.Y > -1000 -- Not in the void
		and pos.Y < 10000 -- Not absurdly high
		and math.abs(pos.X) < 100000 -- Not extreme values
		and math.abs(pos.Z) < 100000
end

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

function MovementController:MoveTo(targetPosition)
	if (self._lastTarget and ((self._lastTarget - targetPosition).Magnitude > 0)) or self.isMoving then
		self:Stop()
	end
	self._lastTarget = targetPosition
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

	-- Cancel previous movement
	if self._currentMovePromise then
		self._currentMovePromise:Destroy()
	end
	local startPos = self._root.Position
	local delta = targetPosition - startPos
	local dir = delta.Unit
	local distance = delta.Magnitude
	local timeToReach = distance / self.velocity

	self._currentMovePromise = Promise.new(function(resolve, reject)
		-- CLEAN
		self._maid:DoCleaning()

		-- Do some checks because we fear to NaN values
		do
			if not isValidPosition(startPos) then
				reject("Root position corrupted (void vector)")
				return
			end

			if not isValidPosition(targetPosition) then
				reject("Target position invalid")
				return
			end

			if timeToReach ~= timeToReach then -- Check for NaN
				reject("TimeToReach is NaN (infinite distance)")
				return
			end
		end

		-- ✅ Create cancellable delay using thread
		local rotateTime = 0.5

		local lookThatShit = CFrame.lookAt(startPos, targetPosition) * CFrame.Angles(0, math.rad(90), 0)
		local rotateTween = TweenService:Create(
			self._root,
			TweenInfo.new(rotateTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
			{ CFrame = lookThatShit }
		)
		-- TODO: add this task to maid
		-- CONNECT THE MOTION PIVOTING AFTER THE ROTATION
		local rotationCOmplete = rotateTween.Completed:Once(function(playbackState)
			self.isMoving = true

			-- Walking anim
			local animationTrask = self._AnimationHandler:LoadAnimation(true, "walk")
			animationTrask:AdjustSpeed(self.speed)
			local elapsed = 0

			self._moveConn = RunService.Heartbeat:Connect(function(dt)
				elapsed += dt

				if elapsed >= timeToReach then
					self._moveConn:Disconnect()
					self._moveConn = nil
					resolve(timeToReach)
					self._AnimationHandler:LoadAnimation(false, "walk")
					self.isMoving = false
					return
				end

				local newPos = startPos + dir * self.velocity * elapsed
				self.Model:PivotTo(CFrame.lookAt(newPos, targetPosition) * CFrame.Angles(0, math.rad(90), 0))
			end)
			self._maid:GiveTask(self._moveConn)
		end)
		self._maid:GiveTask(rotationCOmplete)
		rotateTween:Play()
	end)

	return timeToReach
end

function MovementController:GetMoveDuration()
	return self.timeToReach
end
function MovementController:Destroy()
	self:Stop()
	self._maid:DoCleaning()
	if self._currentMovePromise then
		self._currentMovePromise:Destroy()
	end

	if self._currentTween then
		self._currentTween:Cancel()
	end

	if self._AnimationHandler then
		self._AnimationHandler:LoadAnimation(false, "walk")
	end

	self.isMoving = false
end

return MovementController
