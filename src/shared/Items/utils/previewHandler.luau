local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local PlotService = require(ReplicatedStorage.NPC.Servicies.PlotService)
local Brio = require(ReplicatedStorage.Nevermore.Quenty.brio.Shared.Brio)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)

export type EggPreviewHandlerType = {
	tool: Tool,
	player: Player,
	character: Model,
	plot: BasePart?,
	handleTemplate: BasePart,
	previewHandle: BasePart?,
	originalColor: Color3,
	maid: Maid.Maid,

	_brio: Brio.Brio<boolean>,

	_createPreviewHandle: (self: EggPreviewHandlerType) -> BasePart,
	_getRaycastParams: (self: EggPreviewHandlerType) -> RaycastParams,
	_destroyPreview: (self: EggPreviewHandlerType) -> (),
	updatePreview: (self: EggPreviewHandlerType, mousePosition: Vector2) -> (),
	Destroy: (self: EggPreviewHandlerType) -> (),
	ConnectBrio: (self: EggPreviewHandlerType, cb: () -> ()) -> (),
}

local EggPreviewHandler = {}
EggPreviewHandler.__index = EggPreviewHandler

function EggPreviewHandler.new(toolRef: Tool, playerRef: Player, eggTypeColor): EggPreviewHandlerType
	local self = setmetatable({}, EggPreviewHandler) :: any
	self.tool = toolRef
	self.player = playerRef
	self.character = playerRef.Character or playerRef.CharacterAdded:Wait()
	self.plot = PlotService.GetPlotByUserId(tostring(playerRef.UserId))
	self.handleTemplate = toolRef:WaitForChild("Handle") :: BasePart
	self.previewHandle = nil
	self.originalColor = Color3.new(1, 1, 1)
	self.maid = Maid.new()
	self.eggTypeColor = eggTypeColor

	self:_createPreviewHandle()

	self.maid.previewHandler = RunService.Heartbeat:Connect(function()
		self:updatePreview(UserInputService:GetMouseLocation())
	end)

	self:updatePreview(UserInputService:GetMouseLocation())

	self._brio = Brio.new()

	return self :: EggPreviewHandlerType
end

function EggPreviewHandler:_destroyPreview()
	local typedSelf = self :: EggPreviewHandlerType
	local preview: BasePart? = typedSelf.previewHandle
	if not preview then
		return
	end

	preview:Destroy()
	typedSelf.previewHandle = nil
end

function EggPreviewHandler:_createPreviewHandle(): BasePart
	local typedSelf = self :: EggPreviewHandlerType
	if typedSelf.previewHandle then
		return typedSelf.previewHandle
	end

	local preview = typedSelf.handleTemplate:Clone() :: BasePart
	preview.Anchored = true
	preview.CanCollide = false
	preview.CanTouch = false
	preview.CanQuery = false
	preview.CastShadow = false

	if preview:IsA("UnionOperation") then
		preview.UsePartColor = true
	end
	preview.Transparency = 0.5
	preview.Parent = Workspace
	typedSelf.originalColor = preview.Color
	typedSelf.previewHandle = preview
	return preview
end

function EggPreviewHandler:_getRaycastParams(): RaycastParams
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true

	local filterInstances = CollectionService:GetTagged("NPC")

	table.insert(filterInstances, self.tool)
	table.insert(filterInstances, self.character)

	params.FilterDescendantsInstances = filterInstances
	return params
end

function EggPreviewHandler:updatePreview(mousePosition: Vector2)
	local camera = Workspace.CurrentCamera
	if not camera then
		self:_destroyPreview()
		return
	end

	if not self.plot then
		self.plot = PlotService.GetPlotByUserId(tostring(self.player.UserId))
	end

	if not self.plot then
		self:_destroyPreview()
		return
	end

	local ray = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local result: RaycastResult? = Workspace:Raycast(ray.Origin, ray.Direction * 5000, self:_getRaycastParams())
	if not result then
		self:_destroyPreview()
		return
	end

	local preview: BasePart = self:_createPreviewHandle()

	local placementPosition = result.Position + Vector3.new(0, preview.Size.Y / 2, 0)
	preview.CFrame = CFrame.new(placementPosition)

	local isInside = PlotService.IsPositionInsideFenceBounds(self.plot, result.Position)
	if isInside then
		preview.Color = self.originalColor
	else
		preview.Color = Color3.fromRGB(255, 0, 0)
	end
	local isDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

	if isDown and isInside then
		ReplicatedStorage.RemoteEvents.BuyEggRemote:FireServer({
			color = self.eggTypeColor,
			position = placementPosition,
			itemId = self.tool:GetAttribute("itemId"),
		})
		self:Destroy()
	end
end

function EggPreviewHandler.ConnectBrio(self: EggPreviewHandlerType, cb: () -> ())
	self._brio:GetDiedSignal():Connect(cb)
end

-- TODO need to suscribe to the tool and call some kind of predicate that do unequip the tool.
-- TODO: implement the items ids, use the id for items as a server sign. Probably will also need a handler for every item
-- TODO: test the pet spawn from the eggs
function EggPreviewHandler.Destroy(self: EggPreviewHandlerType)
	self:_destroyPreview()
	self.maid:DoCleaning()
	self._brio:Kill()
end

return EggPreviewHandler
