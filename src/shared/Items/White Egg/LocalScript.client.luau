--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local PlotService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local Constants = require(ReplicatedStorage.utils.Constants)

local tool = script.Parent
local handleTemplate = tool:WaitForChild("Handle") :: BasePart
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local plot = PlotService.GetPlotByUserId(tostring(player.UserId))

local previewHandle: BasePart? = nil
local inputConnection: RBXScriptConnection? = nil
local moveConnection: RBXScriptConnection? = nil

-- we need something like OOP identity
local selfData = {}

local function destroyPreview()
	if previewHandle then
		previewHandle:Destroy()
		previewHandle = nil
	end
end

local function createPreviewHandle(): BasePart
	local preview = handleTemplate:Clone() :: UnionOperation
	preview.Anchored = true
	preview.CanCollide = false
	preview.CanTouch = false
	preview.CanQuery = false
	preview.CastShadow = false

	preview.UsePartColor = true
	preview.Transparency = 0.5
	preview.Parent = Workspace
	selfData.OriginalColor = preview.Color
	return preview
end

local function getRaycastParams(): RaycastParams
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true

	local filterInstances = CollectionService:GetTagged("NPC")
	
	table.insert(filterInstances, tool)
	table.insert(filterInstances, character)


	params.FilterDescendantsInstances = filterInstances
	return params
end

local function updatePreview(mousePosition: Vector2)
	local camera = Workspace.CurrentCamera
	if not camera then
		destroyPreview()
		return
	end

	if not plot then
		destroyPreview()
		return
	end

	local ray = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local result : RaycastResult = Workspace:Raycast(ray.Origin, ray.Direction * 5000, getRaycastParams())
	if not result then
		destroyPreview()
		return
	end

	local preview: BasePart
	if previewHandle then
		preview = previewHandle
	else
		preview = createPreviewHandle()
		previewHandle = preview
	end

	-- local outpOs = Vector3.new(result.Position.X, Constants.GroundY, result.Position.Z)
	local placementPosition =  result.Position + Vector3.new(0, preview.Size.Y / 2, 0)
	preview.CFrame = CFrame.new(placementPosition)

	local isInside = PlotService.IsPositionInsideFenceBounds(plot, result.Position)
	if isInside then
		preview.Color = selfData.OriginalColor
	else
		preview.Color = Color3.fromRGB(255, 0, 0)
	end
end

local function onEquip()
	destroyPreview()

	
	inputConnection = RunService.Heartbeat:Connect(function(a0: number)
		
		updatePreview(UserInputService:GetMouseLocation())

	end)

	updatePreview(UserInputService:GetMouseLocation())
end

local function onUnequip()
	if inputConnection then
		inputConnection:Disconnect()
		inputConnection = nil
	end
	if moveConnection then
		moveConnection:Disconnect()
		inputConnection = nil
	end
	destroyPreview()
end

tool.Equipped:Connect(onEquip)
tool.Unequipped:Connect(onUnequip)
