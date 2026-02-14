local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local npcTypes = require(ServerScriptService.ShopKeepers.npcTypes)
local npcUtils = {}

function npcUtils.lookAt(from: BasePart, at: Vector3, to: Vector3)
	local lookAt = CFrame.lookAt(at, to)
	TweenService:Create(from, TweenInfo.new(2), { CFrame = lookAt })
end

function npcUtils.lookAtPlayer(from: Model)
	local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local playerPos = character.PrimaryPart.Position

	local selfHrp: BasePart? = from.PrimaryPart
	assert(selfHrp)

	npcUtils.lookAt(selfHrp, selfHrp.Position, playerPos)
end

function npcUtils.initNpc(npcData: npcTypes.npcMap)
	-- TODO : create a proximity prompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.Style = Enum.ProximityPromptStyle.Default
	prompt.ActionText = "Shop"
	prompt.Name = "Shop"
	prompt.ObjectText = npcData.id
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.Style = Enum.ProximityPromptStyle.Custom
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 24
	prompt.ClickablePrompt = true
	prompt.Parent = npcData.model
end

return npcUtils
