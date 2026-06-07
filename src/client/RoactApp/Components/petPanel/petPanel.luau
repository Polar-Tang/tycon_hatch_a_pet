local StarterPlayer = game:GetService("StarterPlayer")
local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)
local Roact = require(game.ReplicatedStorage.Roact)
local InventoryItems = require(script.Parent.InventoryItems)
local LeftColumn = require(script.Parent.LeftColumn)
local CenterPanel = require(script.Parent.CenterPanel)
local inventoryTooltip = require(script.Parent.inventoryTooltip)

local context = script.Parent.Parent.Parent.Context
local InventoryContext = require(context.InventoryContext.InventoryContext)
local useContext = require(context.Utils.useContext)
local withCtx = useContext({ InventoryContext = InventoryContext })

local images = assets.player_inventory

local InventoryUI = Roact.Component:extend("InventoryUI")

function InventoryUI:init()
	self.inventoryUIRef = Roact.createRef()
	self:setState({
		isOpenTooltip = false,
		toolTipsize = UDim2.new(0, 0, 0, 0),
		toolTipPosition = UDim2.new(0, 0, 0, 0),
		selectedItemData = {},
	})
end

function InventoryUI:openToolTip(imageRef, item)
	local uiRef = self.inventoryUIRef:getValue()
	local slotRef = imageRef:getValue()
	if not uiRef or not slotRef then
		return
	end

	local toolTipWidth = slotRef.AbsoluteSize.X * 2
	local toolTipHeight = slotRef.AbsoluteSize.Y * 2

	-- Calculate offset relative to the InventoryUI Frame
	local offsetX = slotRef.AbsolutePosition.X - uiRef.AbsolutePosition.X - toolTipWidth -- Position to the left
	local offsetY = slotRef.AbsolutePosition.Y
		- uiRef.AbsolutePosition.Y
		+ slotRef.AbsoluteSize.Y / 2
		- toolTipHeight / 2 -- Center vertically

	self:setState({
		isOpenTooltip = true,
		toolTipsize = UDim2.new(0, toolTipWidth, 0, toolTipHeight),
		toolTipPosition = UDim2.new(0, offsetX, 0, offsetY),
		selectedItemData = item,
	})
end

function InventoryUI:closeToolTip()
	self:setState({
		isOpenTooltip = false,
	})
end

function InventoryUI:render()
	return withCtx(function(ctx)
		local inventoryCtx = ctx.InventoryContext
		if not inventoryCtx.isPanelOpen then
			return Roact.createFragment({})
		end

		local sidesPadding = 4 / 300
		local yPadding = 4 / 165

		return Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.85, 0.85), -- container scales to screen
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
			[Roact.Ref] = self.inventoryUIRef, -- Ref for position calculations
		}, {

			-- Aspect ratio to preserve 300x165 proportions
			Aspect = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 300 / 165,
			}),

			-- Topbar
			Topbar = Roact.createElement("ImageLabel", {
				Size = UDim2.new(1, 0, 0.1,0),
				BackgroundTransparency = 1,
				ScaleType = Enum.ScaleType.Stretch,
				Image = images.Header,
			}, {

				Close = Roact.createElement("ImageButton", {
					Size = UDim2.fromScale(10 / 300, 0.65),
					Position = UDim2.fromScale(1 - sidesPadding / 2, 0.175),
					AnchorPoint = Vector2.new(1, 0),
					Image = images.Close,
					BackgroundTransparency = 1,
					[Roact.Event.Activated] = function()
						inventoryCtx.setPanelOpen(false)
					end,
				}),
			}),

			Tooltip = self.state.isOpenTooltip and  Roact.createElement(inventoryTooltip, {
				closeToolTip = function()
					self:closeToolTip()
				end,
				selectedItemData = self.state.selectedItemData,
				toolTipPosition = self.state.toolTipPosition,
				toolTipsize = self.state.toolTipsize,
			}),

			-- Content
			Content = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(1, 1 - (16 / 165)),
				Position = UDim2.fromScale(0, 16 / 165),
				Image = images.MainFrame,
				BackgroundTransparency = 1,
			}, {

				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0.019, 0),
					PaddingLeft = UDim.new(yPadding / 2),
					PaddingBottom = UDim.new(0.019, 0),
				}),

				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(sidesPadding / 2, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				-- LEFT (1fr)
				LeftPanel = Roact.createElement(LeftColumn, {
					LayoutOrder = 1,
					images = images,
					sidesPadding = sidesPadding,
					yPadding = yPadding,
					petRegistry = _G["pets_registry"],
					selectPetData = inventoryCtx.setSelectedPetData,
					is2dPreview = inventoryCtx.is2dPreview,
					setIs2dPreview = inventoryCtx.setIs2dPreview,
				}),

				-- CENTER (2fr)
				CenterPanel = Roact.createElement(CenterPanel, {
					LayoutOrder = 2,
					images = images,
					sidesPadding = sidesPadding,
					yPadding = yPadding
				}),

				-- RIGHT (1fr, grid)
				RightPanel = Roact.createElement("ImageLabel", {
					Size = UDim2.fromScale(1 / 4, 1),
					Image = images.ColumnBg,
					ClipsDescendants = true,
					LayoutOrder = 2,
					BackgroundTransparency = 1,
				}, {

					Padding = Roact.createElement("UIPadding", {
						PaddingTop = UDim.new(0.019, 0),
						PaddingBottom = UDim.new(0.019, 0),
						-- PaddingRight = UDim.new(-0.01, 0),
					}),

					gradientTransparencyFrame = Roact.createElement("Frame", {
						Size = UDim2.new(0.94, 0, 1, 0),
						Position = UDim2.new(0.03, 0, 0, 0),
						BackgroundTransparency = 0,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						ZIndex = 2,
						BorderSizePixel = 0,
					}, {
						Gradient = Roact.createElement("UIGradient", {
							Rotation = 90,
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
							}),
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(0.8, 1),
								NumberSequenceKeypoint.new(1, 0),
							}),
						}),
					}),

					ScrollingFrame = Roact.createElement("ScrollingFrame", {
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						ScrollBarThickness = 1,
						CanvasSize = UDim2.new(0, 0, 0, 0),
						BackgroundTransparency = 1,
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						BorderSizePixel = 0,
						ZIndex = 3,
					}, {
						Grid = Roact.createElement("UIGridLayout", {
							CellSize = UDim2.new(0.215, 0, 0.13, 0),
							CellPadding = UDim2.new(0.025, 0, 0.005, 0),
							FillDirectionMaxCells = 4,
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Top,
						}),

						InventoryItems = Roact.createElement(InventoryItems, {
							openToolTip = function(ref, item)
								self:openToolTip(ref, item)
							end,
							closeToolTip = function()
								self:closeToolTip()
							end,
						}),
					}),
				}),
			}),
		})
	end)
end

return InventoryUI
