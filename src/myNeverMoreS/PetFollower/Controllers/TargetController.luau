local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = RS.Nevermore.Quenty
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.utils.NpcFighterTypes)
local BaseObject = require(packages.baseobject.Shared.BaseObject)

local TargetController = setmetatable({}, BaseObject)
TargetController.__index = TargetController

function TargetController.new(data: NpcFighterTypes.controllerdataInint, serviceBag: any, player)
	local self = setmetatable(data, TargetController)
	self._playerLastPos = nil
	return self
end

function TargetController.Update(self: NpcFighterTypes.TargetController): Vector3?
	local playerChar = self.player_character
	local playerPos = playerChar.PrimaryPart.Position

	if not self._playerLastPos or self._playerLastPos ~= playerPos then
		self._playerLastPos = playerPos

		return self._playerLastPos
	end
	return nil
end

function TargetController.DestroyNPC(self: NpcFighterTypes.TargetController)
	self.pet:Destroy()
end

return TargetController
