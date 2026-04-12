local StarterPlayer = game:GetService("StarterPlayer")
local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)
local Roact = require(game.ReplicatedStorage.Roact)
local InventoryItems = require(script.Parent.InventoryItems)

local images = assets.player_inventory

local function InventoryUI()
	local sidesPadding = 4 / 300
	local yPadding = 4 / 165
	local cellPadding = Vector2.new(sidesPadding / 2, yPadding / 2)

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(0.9, 0.9), -- container scales to screen
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	}, {

		-- Aspect ratio to preserve 300x165 proportions
		Aspect = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 300 / 165,
		}),

		-- Topbar
		Topbar = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(1, 16 / 165),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Stretch,
			Image = images.Header,
		}, {

			Close = Roact.createElement("ImageButton", {
				Size = UDim2.fromScale(10 / 300, 0.75),
				Position = UDim2.fromScale(1 - sidesPadding / 2, 0.125),
				AnchorPoint = Vector2.new(1, 0),
				Image = images.Close,
				BackgroundTransparency = 1,
			}),
		}),

		-- Content
		Content = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(1, 1 - (16 / 165)),
			Position = UDim2.fromScale(0, 16 / 165),
			Image = images.MainFrame,
			BackgroundTransparency = 1,
		}, {

			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(yPadding, 0),
				PaddingBottom = UDim.new(yPadding, 0),
				PaddingLeft = UDim.new(sidesPadding / 2, 0),
				PaddingRight = UDim.new(sidesPadding / 2, 0),
			}),

			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(sidesPadding / 2, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			-- LEFT (1fr)
			LeftPanel = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(1 / 4, 1),
				LayoutOrder = 1,
				Image = images.ColumnPreview,
				BackgroundTransparency = 1,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(yPadding / 2, 0),
					PaddingBottom = UDim.new(yPadding / 2, 0),
					PaddingLeft = UDim.new(sidesPadding / 2, 0),
					PaddingRight = UDim.new(sidesPadding / 2, 0),
				}),
				-- Layout = Roact.createElement("UIListLayout", {
				-- 	FillDirection = Enum.FillDirection.Horizontal,
				-- 	Padding = UDim.new(sidesPadding / 2, yPadding / 2),
				-- 	SortOrder = Enum.SortOrder.LayoutOrder,
				-- }),

				Content = Roact.createElement("ImageLabel", {
					Size = UDim2.fromScale(1 - sidesPadding, 1 - yPadding),
					Image = images.ColumnBg,
					Position = UDim2.fromScale(sidesPadding / 2, yPadding / 2), -- Center horizontally and vertically

					BackgroundTransparency = 1,
				}),
			}),

			-- CENTER (2fr)
			CenterPanel = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(2 / 4 - 4 / 300, 1),
				Image = images.MainColumnBg,
				LayoutOrder = 2,
				BackgroundTransparency = 1,
			}),

			-- RIGHT (1fr, grid)
			RightPanel = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(1 / 4, 1),
				Image = images.ColumnBg,
				ClipsDescendants = true,
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				-- ZIndex = 1,
			}, {

				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0.019, 0),
					PaddingRight = UDim.new(-0.01, 0),
					PaddingBottom = UDim.new(0.019, 0),
				}),

				gradientTransparencyFrame = Roact.createElement("Frame", {
					Size = UDim2.new(0.94, 0, 1, 0),
					Position = UDim2.new(0.03, 0, 0, 0),
					BackgroundTransparency = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					ZIndex = 2,
                    BorderSizePixel = 0,

				}, {
					-- Gradient transparency effect
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
					CanvasSize = UDim2.new(0, 0, 0, 0), -- Auto-calculated by UIGridLayout
					BackgroundTransparency = 1,
                    BorderSizePixel = 0,
					ZIndex = 3,
				}, {
					Grid = Roact.createElement("UIGridLayout", {
						CellSize = UDim2.new(0.215, 0, 0.13, 0),
						CellPadding = UDim2.new(0.025, 0, 0.005, 0),
						FillDirectionMaxCells = 4,

						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
					}),

					InventoryItems = Roact.createElement(InventoryItems),
				}),
			}),
		}),
	})
end

return InventoryUI
