local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = RS.Nevermore.Quenty
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)

local BaseObject = require(packages.baseobject.Shared.BaseObject)
local Maid = require(packages.maid.Shared.Maid)

local DeadController = setmetatable({}, BaseObject)
DeadController.__index = DeadController

function DeadController.new(data: NpcFighterTypes.controllerdataInint, serviceBag: any, player)
	local self = setmetatable(data, DeadController)
	-- BaseObject.new() is never called (we adopt the shared ctx table), so seed
	-- the _maid ourselves; otherwise the inherited BaseObject.Destroy indexes nil
	-- when the binder maid cleans this controller up.
	self._maid = self._maid or Maid.new()
	self.Humanoid.BreakJointsOnDeath = true

	return self
end

function DeadController.CreateWhirpol(self: NpcFighterTypes.DeadController)
	-- local StuntWhir: Model = Whirpool:clone()
	-- local rootpart = StuntWhir.PrimaryPart
	-- rootpart.Massless = false
	-- rootpart.CastShadow = false
	-- rootpart.Anchored = true
	-- StuntWhir.Name = "StuntWhir"

	-- rootpart.Position = Vector3.new(npc.Head.Position.X, npc.Head.Position.Y + 1, npc.Head.Position.Z)
	-- StuntWhir.Parent = npc.Head
	-- local angle = 0
	-- task.spawn(function()
	-- 	while StuntWhir.Parent do
	-- 		local pos = StuntWhir.PrimaryPart.Position
	-- 		angle += math.rad(5)
	-- 		local animDuration = 0.2
	-- 		-- StuntWhir.PrimaryPart.CFrame
	-- 		local newCF = StuntWhir.PrimaryPart.CFrame * CFrame.Angles(0, angle, 0)
	-- 		local tween = TweenService:Create(StuntWhir.PrimaryPart, TweenInfo.new(animDuration), { CFrame = newCF })
	-- 		tween:Play()
	-- 		task.wait(animDuration)
	-- 	end
	-- end)
end

function DeadController.DestroyNPC(self: NpcFighterTypes.DeadController)
	self.pet:Destroy()
end

return DeadController
