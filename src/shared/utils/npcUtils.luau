local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local types = require(script.Parent.types)

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

export type proximityPromptInfo = {
	npcId: string,
	Name: string,
	ActionText: string,
	cb: ((model: Model) -> ())?,
	HoldDuration : number?,
}

function npcUtils.createProximityPrompt(model: Model, data: proximityPromptInfo)
	local prompt = Instance.new("ProximityPrompt")
	-- prompt.Style = Enum.ProximityPromptStyle.Default
	prompt.ActionText = data.ActionText
	prompt.Name = data.npcId --
	prompt.ObjectText = data.Name
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = data.HoldDuration and data.HoldDuration or 0
	prompt.Style = Enum.ProximityPromptStyle.Custom
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 24
	prompt.ClickablePrompt = true
	prompt.Parent = model

	prompt.Triggered:Connect(function(_player)
		if data.cb then
			data.cb(model)
		end
	end)
end

function npcUtils.createBillboard(model: Model, data: types.billBoardContract)
	game.ReplicatedStorage.RemoteEvents.Biilboard:FireAllClients(data)
end

return npcUtils
