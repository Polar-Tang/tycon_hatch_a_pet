local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = RS.Nevermore.Quenty
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Promise = require(ReplicatedStorage.Nevermore.Quenty.promise.Shared.Promise)
local BaseObject = require(packages.baseobject.Shared.BaseObject)

local MovementController = setmetatable({}, BaseObject)
MovementController.__index = MovementController

function MovementController.new(data: NpcFighterTypes.controllerdataInint, serviceBag: any, player)
	local self = setmetatable(data, MovementController)
	self._currentMovePromise = nil
	local petName = self.pet:GetAttribute("petName")
	self.speed = assert(petData[petName], "invalid petName").walkSpeed
	self._maid = Maid.new()

	-- Assume the pet has a Humanoid
	local humanoid = self.pet:WaitForChild("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
		humanoid.WalkSpeed = self.speed
	end
	self.humanoid = humanoid
	self.maid_waypoints = Maid.new()
	self.maid:GiveTask(self.maid_waypoints)
	return self
end

-- constsants
local GRAVITY = Vector3.new(0, -workspace.Gravity, 0)
local T = 0.5 -- use a fixed time for the ball to reach the target

function MovementController._jumpToWaypoint(
	self: NpcFighterTypes.MovementController,
	targetPosition: Vector3,
	onComplete
)
	self.maid_waypoints:DoCleaning()

	local startPosition = self.hrp.Position

	--V1 = P1 - P0 - 0.5*G*T^2/T
	local initialVelocity = (targetPosition - startPosition - 0.5 * GRAVITY * T ^ 2) / T
	local t = 0
	local moveConn
	moveConn = RunService.Heartbeat:Connect(function(deltaTime)
		t += deltaTime

		if t > T then
			onComplete(true)
			moveConn:Disconnect()
			return
		end

		--// s = s0 + v0*t + 0.5*a*t^2
		local newPos = startPosition + (initialVelocity * t) + 0.5 * GRAVITY * (t ^ 2)

		self.pet:MoveTo(newPos)
	end)
	self.maid:GiveTask(moveConn)
end

function MovementController.Stop(self: NpcFighterTypes.MovementController)
	self._maid:DoCleaning()
	self.isMoving = false
	if self.animationHandler then
		self.animationHandler:LoadAnimation(false, "walk")
	end
end

function MovementController.getAnimHandler(self: NpcFighterTypes.MovementController)
	local animHandler = self.animationHandler
	if animHandler then
		return animHandler
	end
	local BinderProvider = _G.ServiceBag:GetService(_G.BinderProvider)
	local AnimationBinder = BinderProvider:Get("AnimationHandler")
	self.animationHandler = AnimationBinder:Get(self.pet)
	return self.animationHandler
end

function MovementController.ForgotPath(self: NpcFighterTypes.MovementController)
	if self._currentMovePromise then
		self._currentMovePromise:Destroy()
	end
end

function MovementController.MoveTo(self: NpcFighterTypes.MovementController, path: Path)
	self._maid:DoCleaning()
	self._currentMovePromise = Promise.new(function(resolve, reject)
		local waypoints = path:GetWaypoints()

		if #waypoints == 0 then
			resolve()
			return
		end

		local animHandler = self:getAnimHandler()
		animHandler:LoadAnimation(true, "walk")
		self.isMoving = true

		local currentIndex = 1
		local function moveNext()
			-- clean previous move connections and promises

			if currentIndex > #waypoints then
				animHandler:LoadAnimation(false, "walk")
				self.isMoving = false
				resolve()
				self.maid_waypoints:DoCleaning()
				return
			end

			local waypoint = waypoints[currentIndex]

			self:_moveToWaypoint(waypoint.Position, function(reached)
				if reached then
					currentIndex += 1
					moveNext()
				else
					self:_jumpToWaypoint(waypoint.Position, function(reached)
						if reached then
							currentIndex += 1
							moveNext()
						else
							reject("Failed to reach waypoint")
						end
					end)
				end
			end)
		end
		moveNext()
	end)
	return self._currentMovePromise
end

function MovementController._moveToWaypoint(
	self: NpcFighterTypes.MovementController,
	targetPosition: Vector3,
	onComplete: (boolean) -> ()
)
	self.maid_waypoints:DoCleaning()

	task.defer(function()
		local timer
		local time_out = Promise.new(function(resolve, reject)
			local t = 0

			timer = RunService.Heartbeat:Connect(function(dt)
				t += dt
				if t >= 1 then
					resolve()
				end
			end)
		end)
			:Then(function()
				onComplete(false)
				timer:Disconnect()
			end)
			:Finally(function(...): ...any
				timer:Disconnect()
			end)
			:Catch(function(...): ...any
				print("rejeccted")
				timer:Disconnect()
			end)

		self.maid_waypoints:GiveTask(timer)
		local conn = self.humanoid.MoveToFinished:Once(function(reach)
			onComplete(reach)
		end)
		self.maid_waypoints:GivePromise(time_out)
		self.maid_waypoints:GiveTask(conn)

		self.humanoid:MoveTo(targetPosition)
	end)
end

function MovementController.DestroyNPC(self: NpcFighterTypes.MovementController)
	self._maid:DoCleaning()
	self.pet:Destroy()
end

return MovementController
