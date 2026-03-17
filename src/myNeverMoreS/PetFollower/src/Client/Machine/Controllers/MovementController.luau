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

function MovementController._rotate(self: NpcFighterTypes.MovementController, timer): CFrame
	local rotateTime = 0.5 -- use a hardcoded rotate time for now, can be changed to be based on the angle between the current forward vector and the target direction
	local t = math.clamp(timer / rotateTime, 0, 1)
	return self.hrp.CFrame:Lerp(self.goalRotation, t)
end

function MovementController.ForgotPath(self: NpcFighterTypes.MovementController)
	if self._currentMovePromise then
		self._currentMovePromise:Destroy()
	end
end

function MovementController.MoveTo(self: NpcFighterTypes.MovementController, path: Path)
	self._currentMovePromise = Promise.new(function(resolve, reject)
		self.maid:DoCleaning()
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
			-- Ensure there a single movement connection at a time
			if self.moveConn then
				self.moveConn:Disconnect()
			end

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

	-- Set up rotation towards the target
	do
		self.startCFrame = self.hrp.CFrame
		self.goalRotation = CFrame.lookAt(startPos, targetPosition)
	end

	local rotateTime = 0.5
	testPart({ Position = targetPosition })
	local dir = delta.Unit
	local t = 0 -- Time elapsed since starting movement towards the waypoint

	self.moveConn = RunService.Heartbeat:Connect(function(dt)
		t += dt
		local newPos = startPos + dir * self.velocity * t
		newPos = Vector3.new(newPos.X, targetPosition.Y, newPos.Z)

		-- Determine rotation: apply rotation lerp until rotateTime is reached, then use final rotation
		local isRotated = t >= rotateTime
		local rotation = isRotated and self.goalRotation.Rotation --or self:_rotate(t).Rotation

		if t >= timeToReach then
			if self.moveConn then
				self.moveConn:Disconnect()
			end
			-- Do this cause path finding love to do unecesary walking
			if (self.hrp.Position - assert(self.player_character.PrimaryPart).Position).Magnitude > 3 then
				onComplete()
			end
		end

		local newCF = CFrame.new(newPos) * CFrame.Angles(0, math.rad(90), 0)
		self.pet:PivotTo(newCF)
	end)
end

function MovementController.DestroyNPC(self: NpcFighterTypes.MovementController)
	self.maid:DoCleaning()
	self.pet:Destroy()
end

return MovementController
