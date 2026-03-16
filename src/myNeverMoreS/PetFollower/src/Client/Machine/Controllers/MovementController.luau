local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local packages = RS.Nevermore.Quenty
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
local Promise = require(ReplicatedStorage.Nevermore.Quenty.promise.Shared.Promise)
local testPart = require(ReplicatedStorage.utils.testPart)
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

function MovementController.Stop(self: NpcFighterTypes.MovementController)
	self.maid:DoCleaning()

	self.isMoving = false

	if self.animationHandler then
		self.animationHandler:LoadAnimation(false, "walk")
	end
	-- Fire an event to report the last position to the server
end

function MovementController.getAnimHandler(self: NpcFighterTypes.MovementController)
	local animHandler = self.animationHandler
	if animHandler then
		return animHandler
	end
	local BinderProvider = _G.ServiceBag:GetService(_G.BinderProvider)

	-- local WeaponBinder = BinderProvider:Get("Armed")
	local AnimationBinder = BinderProvider:Get("AnimationHandler")
	self.animationHandler = AnimationBinder:Get(self.pet)
	return self.animationHandler
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

function MovementController._lookTo(self: NpcFighterTypes.MovementController, targetPosition)
	local startPos = self.hrp.Position
	local currentCFrame = self.hrp.CFrame
	local targetCFrame = CFrame.lookAt(startPos, targetPosition) * CFrame.Angles(0, math.rad(90), 0)

	-- Calculate the angle difference
	local currentLook = currentCFrame.LookVector
	local targetLook = targetCFrame.LookVector
	local angle = math.acos(math.clamp(currentLook:Dot(targetLook), -1, 1))
	local rotateMaxTime = 3

	-- Assuming 360° (rotateMaxTime*pi radians) takes rotateMaxTime seconds
	local rotateTime = (angle / (rotateMaxTime * math.pi)) * 2

	local tween = TweenService:Create(
		self.hrp,
		TweenInfo.new(rotateTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{ CFrame = targetCFrame }
	)
	tween:Play()

	return tween.Completed
end

function MovementController.ForgotPath(self: NpcFighterTypes.MovementController)
	if self._currentMovePromise then
		self._currentMovePromise:Destroy()
	end
end

function MovementController.MoveTo(self: NpcFighterTypes.MovementController, path: Path)
	self._currentMovePromise = Promise.new(function(resolve, reject)
		local waypoints = path:GetWaypoints()
		if #waypoints == 0 then
			resolve()
			return
		end

		--[[
			local finalWaypoint = waypoints[#waypoints]
			testPart({
				Position = finalWaypoint.Position,
				Color3 = Color3.new(0.129412, 0.521569, 0.168627),
				Size = Vector3.new(2, 2, 2),
				Duration = 2,
				Name = "FinalWaypoint",
			})
		
		]]
		-- local rotationComplete = self:_lookTo(finalWaypoint.Position)

		-- rotationComplete:Once(function()
		self.elapsed = 0
		local animHandler = self:getAnimHandler()
		animHandler:LoadAnimation(true, "walk")
		self.isMoving = true

		local currentIndex = 1
		local function moveNext()
			if currentIndex > #waypoints then
				animHandler:LoadAnimation(false, "walk")
				self.isMoving = false
				resolve()
				return
			end

			local waypoint = waypoints[currentIndex]
			self:_moveToWaypoint(waypoint.Position, function()
				currentIndex += 1
				moveNext()
			end)
		end
		moveNext()
		-- end)
	end)
	return self._currentMovePromise
end

function MovementController._moveToWaypoint(self: NpcFighterTypes.MovementController, targetPosition, onComplete)
	local startPos = self.hrp.Position
	local delta = targetPosition - startPos
	local distance = delta.Magnitude
	local timeToReach = distance / self.velocity

	if timeToReach ~= timeToReach or timeToReach <= 0 then
		onComplete()
		return
	end
	testPart({ Position = targetPosition })
	local dir = delta.Unit
	local elapsed = self.elapsed
	local moveConn
	moveConn = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		local newPos = startPos + dir * self.velocity * elapsed
		newPos = Vector3.new(newPos.X, targetPosition.Y, newPos.Z)
		--testPart({ Position = newPos, Color3 = Color3.new(1, 0, 0) })

		if elapsed >= timeToReach then
			moveConn:Disconnect()

			self.pet:MoveTo(newPos)
			onComplete()
			return
		end

		self.pet:MoveTo(newPos)
	end)
end

function MovementController.DestroyNPC(self: NpcFighterTypes.MovementController)
	self.maid:DoCleaning()
	self.pet:Destroy()
end

return MovementController
