local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local packages = RS.Nevermore.Quenty
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
local Promise = require(ReplicatedStorage.Nevermore.Quenty.promise.Shared.Promise)
local BaseObject = require(packages.baseobject.Shared.BaseObject)

local MovementController = setmetatable({}, BaseObject)
MovementController.__index = MovementController

function MovementController.new(data: NpcFighterTypes.controllerdataInint, serviceBag: any, player)
	local self = setmetatable(data, MovementController)
	self._currentMovePromise = nil
	self.velocity = 10
	local petName = self.pet:GetAttribute("petName")

	self.speed = assert(petData[petName], "invalid petName").speed

	return self
end

function MovementController._getAtt(self: NpcFighterTypes.MovementController): Attachment
	local attachmentAlignPos = self.pet:FindFirstChild("attachmentDash")
	if not attachmentAlignPos then
		attachmentAlignPos = Instance.new("Attachment")
		attachmentAlignPos.Name = "attachmentDash"
		attachmentAlignPos.Visible = true
		attachmentAlignPos.CFrame = self.hrp.CFrame
		attachmentAlignPos.Parent = self.hrp
	end
	return attachmentAlignPos
end

function MovementController.MoveTo(self: NpcFighterTypes.MovementController, targetPosition: Vector3)
	self.animationHandler:LoadAnimation(true, "walk")
	-- TODO : MIGRATE THIS TO USE HUMANOID:MOVETO
	-- Cancel previous movement
	if self._currentMovePromise then
		self._currentMovePromise:Destroy()
	end
	local startPos = self.hrp.Position
	local delta = targetPosition - startPos
	local dir = delta.Unit
	local distance = delta.Magnitude
	local timeToReach = distance / self.velocity

	self._currentMovePromise = Promise.new(function(resolve, reject)
		-- CLEAN
		self.maid:DoCleaning()

		-- ✅ Create cancellable delay using thread
		local rotateTime = 0.5

		local lookThatShit = CFrame.lookAt(startPos, targetPosition) * CFrame.Angles(0, math.rad(90), 0)
		local rotateTween = TweenService:Create(
			self.hrp,
			TweenInfo.new(rotateTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
			{ CFrame = lookThatShit }
		)
		-- TODO: add this task to maid
		-- CONNECT THE MOTION PIVOTING AFTER THE ROTATION
		local rotationCOmplete = rotateTween.Completed:Once(function(playbackState)
			self.isMoving = true

			-- Walking anim
			local animationTrask = self.animationHandler:LoadAnimation(true, "walk")
			animationTrask:AdjustSpeed(self.speed)
			local elapsed = 0

			self._moveConn = RunService.Heartbeat:Connect(function(dt)
				elapsed += dt

				if elapsed >= timeToReach and self._moveConn then
					self._moveConn:Disconnect()
					self._moveConn = nil
					resolve(timeToReach)
					self.animationHandler:LoadAnimation(false, "walk")
					self.isMoving = false
					return
				end

				local newPos = startPos + dir * self.velocity * elapsed
				self.pet:PivotTo(CFrame.lookAt(newPos, targetPosition) * CFrame.Angles(0, math.rad(90), 0))
			end)
			self.maid:GiveTask(self._moveConn)
		end)
		self.maid:GiveTask(rotationCOmplete)
		rotateTween:Play()
	end)
end

function MovementController.DestroyNPC(self: NpcFighterTypes.MovementController)
	self.maid:DoCleaning()
	self.pet:Destroy()
end

return MovementController
