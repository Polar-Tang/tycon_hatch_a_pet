local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

	return self
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
			if currentIndex > #waypoints then
				animHandler:LoadAnimation(false, "walk")
				self.isMoving = false
				resolve()
				return
			end

			local waypoint = waypoints[currentIndex]
			if waypoint.Action ~= Enum.PathWaypointAction.Jump then
				self.humanoid.Jump = true
			end
			self:_moveToWaypoint(waypoint.Position, function(reached)
				if reached then
					currentIndex += 1
					moveNext()
				else
					reject("Failed to reach waypoint")
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
	if not self.humanoid then
		onComplete(false)
		return
	end

	local conn = self.humanoid.MoveToFinished:Once(function(reach)
		onComplete(reach)
	end)
	self._maid:GiveTask(conn)

	self.humanoid:MoveTo(targetPosition)
end

function MovementController.DestroyNPC(self: NpcFighterTypes.MovementController)
	self._maid:DoCleaning()
	self.pet:Destroy()
end

return MovementController
