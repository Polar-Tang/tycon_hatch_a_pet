local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpgradeSet = require(script.Parent.UpgradeSet)
local Roact = require(ReplicatedStorage.Roact)

-- local petsPhisics =
local petData = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petData)
local petBosses = require(ReplicatedStorage.Nevermore.Custom.npc.src.Shared.Binder.helpers.petBosses)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)

local context = script.Parent.Parent.Parent.Context
local InventoryContext = require(context.InventoryContext.InventoryContext)
local useContext = require(context.Utils.useContext)
local withCtx = useContext({ InventoryContext = InventoryContext })

local CenterPanel = Roact.Component:extend("CenterPanel")

function CenterPanel:init()
	self.viewportRef = Roact.createRef()
	self.camRef = Roact.createRef()
	self.worldModelRef = Roact.createRef()

	self.currentPetId = nil
	self.currentViewportModel = nil
end

function CenterPanel:_getPivotCFrame(petName: PetTypes.petNames, modelSize): CFrame
	local modelCFrame = CFrame.new(0, -modelSize.Y / 5, 0)
	local rad = 120
	local zrad = 0

	if petData[petName] then
		if petData[petName].radPivot then
			rad = petData[petName].radPivot
		elseif petData[petName].ZradPivot then
			zrad = petData[petName].ZradPivot
		end
	elseif petBosses[petName] then
		if petBosses[petName].radPivot and petBosses[petName].ZradPivot then
			rad = petBosses[petName].radPivot
			zrad = petBosses[petName].ZradPivot
		elseif petBosses[petName].radPivot then
			rad = petBosses[petName].radPivot
		elseif petBosses[petName].ZradPivot then
			zrad = petBosses[petName].ZradPivot
		end
	end

	return modelCFrame * CFrame.Angles(0, math.rad(rad), math.rad(zrad))
end

function CenterPanel:_getCameraRotation(petName: PetTypes.petNames, extendSize: Vector3): CFrame
	local distance = extendSize.Magnitude * 0.7

	return CFrame.new(0.6, 0.6, 0)
		* CFrame.new(0, 0, -distance)
		* CFrame.Angles(math.rad(0), math.rad(170), math.rad(0))
end
--WorldModel

function CenterPanel:_clearViewport()
	local viewport = self.viewportRef and self.viewportRef:getValue()
	if not viewport then
		return
	end

	for _, child in ipairs(viewport:GetChildren()) do
		if not child:IsA("Camera") then
			child:Destroy()
		end
	end

	self.currentViewportModel = nil
	self.currentPetId = nil
end

function CenterPanel:createViewport()
	local viewport = self.viewportRef and self.viewportRef:getValue()
	local camera = self.camRef and self.camRef:getValue()
	local selectedPetData = self.selectedPetData
	local is2dPreview = if self.is2dPreview == nil then true else self.is2dPreview

	if not viewport or not camera or not selectedPetData then
		self:_clearViewport()
		return
	end

	self:_clearViewport()

	local petName = selectedPetData.petName
	local template: Model = ReplicatedFirst.PetModels:FindFirstChild(petName)
	if not template then
		return
	end

	local petClone: Model = template:Clone()
	local rootpart = petClone:FindFirstChild("Rootpart")
	if rootpart and rootpart:IsA("BasePart") then
		petClone.PrimaryPart = rootpart
	end

	if is2dPreview then
		petClone.Parent = viewport
	else
		local worldModel = Instance.new("WorldModel")
		worldModel.Parent = viewport
		petClone.Parent = worldModel
	end

	do
		local IdleAnimId = require(ReplicatedStorage.Animations.animationsData)[petName].idle
		local anim = Instance.new("Animation", petClone)
		anim.AnimationId = IdleAnimId

		local animator = petClone:WaitForChild("AnimationController"):WaitForChild("Animator")
		local track = animator:LoadAnimation(anim)
		track.Looped = true
		track:Play()
	end

	local _modelCFrame, modelSize = petClone:GetBoundingBox()
	petClone:PivotTo(self:_getPivotCFrame(petName, modelSize))
	camera.CFrame = self:_getCameraRotation(petName, modelSize)
	camera.FieldOfView = 70
	viewport.CurrentCamera = camera

	self.currentPetId = selectedPetData.petId
	self.currentViewportModel = petClone
end

function CenterPanel:render()
	return withCtx(function(ctx)
		local inventoryCtx = ctx.InventoryContext
		local selectedPetData = inventoryCtx.selectedPetData
		local is2dPreview = inventoryCtx.is2dPreview
		self.selectedPetData = selectedPetData
		self.is2dPreview = is2dPreview

		local titleText = selectedPetData and tostring(selectedPetData.petName) or ""

		return Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(2 / 4 - self.props.sidesPadding * 2, 1),
			Image = self.props.images.MainColumnBg,
			LayoutOrder = self.props.LayoutOrder or 2,
			BackgroundTransparency = 1,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(self.props.sidesPadding / 2),
				PaddingRight = UDim.new(self.props.sidesPadding / 2),

				PaddingBottom = UDim.new(0.019, 0),
			}),

			TopHalf = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.4),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			}, {
				HeaderTitle = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 0.3),
					Position = UDim2.fromScale(0, 0),
					BackgroundTransparency = 1,
					Text = titleText,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.FredokaOne,
					TextScaled = true,
					TextColor3 = Color3.fromRGB(27, 42, 53),
				}),

				PlaceHolderImage = Roact.createElement("ViewportFrame", {
					Size = UDim2.fromScale(1, 0.7),
					Position = UDim2.fromScale(0, 0.3),
					BackgroundTransparency = 1,
					[Roact.Ref] = self.viewportRef,
				}, {
					Camera = Roact.createElement("Camera", {
						[Roact.Ref] = self.camRef,
					}),
				}),
			}),

			BottomHalf = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.6),
				Position = UDim2.fromScale(0, 0.4),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				HealthSet = Roact.createElement(UpgradeSet, {
					LayoutOrder = 1,
					Title = "Health",
					statTitle = "Health",
				}),
				MeleeSet = Roact.createElement(UpgradeSet, {
					LayoutOrder = 2,
					Title = "Melee",
					statTitle = "Melee",
				}),
				StaminaSet = Roact.createElement(UpgradeSet, {
					LayoutOrder = 3,
					Title = "Stamina",
					statTitle = "Stamina",
				}),
			}),
		})
	end)
end

function CenterPanel:didMount()
	self:createViewport()
end

function CenterPanel:didUpdate(previousProps)
	self:createViewport()
end

function CenterPanel:willUnmount()
	self:_clearViewport()
end

return CenterPanel
