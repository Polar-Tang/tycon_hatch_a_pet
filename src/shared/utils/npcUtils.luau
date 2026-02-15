local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local npcTypes = require(script.Parent.npcTypes)

local npcUtils = {}

function npcUtils.lookAt(from: BasePart, at: Vector3, to: Vector3)
	local lookAt = CFrame.lookAt(at, to)
	TweenService:Create(from, TweenInfo.new(2), { CFrame = lookAt }):Play()
end

function npcUtils.lookAtPlayer(from: Model)
	local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local playerPos = character.PrimaryPart.Position

	local selfHrp: BasePart? = from.PrimaryPart
	assert(selfHrp)

	npcUtils.lookAt(selfHrp, selfHrp.Position, playerPos)
end

return npcUtils
