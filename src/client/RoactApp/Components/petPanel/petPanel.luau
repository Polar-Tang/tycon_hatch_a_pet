local StarterPlayer = game:GetService("StarterPlayer")
local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)
local Roact = require(game.ReplicatedStorage.Roact)

local images = assets.player_inventory

local function InventoryUI()
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
			Size = UDim2.fromScale(1, 10 / 165),
			Image = images.Header,
		}, {

			Close = Roact.createElement("ImageButton", {
				Size = UDim2.fromScale(10 / 300, 1),
				Position = UDim2.fromScale(1, 0),
				AnchorPoint = Vector2.new(1, 0),
				Image = images.Close,
				BackgroundTransparency = 1,
			}),
		}),

		-- Content
		Content = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(1, 1 - (10 / 165)),
			Position = UDim2.fromScale(0, 10 / 165),
			Image = images.MainFrame,
		}, {

			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(4 / 165, 0),
				PaddingBottom = UDim.new(4 / 165, 0),
				PaddingLeft = UDim.new(4 / 300, 0),
				PaddingRight = UDim.new(4 / 300, 0),
			}),

			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(2 / 300, 0),
                SortOrder = Enum.SortOrder.LayoutOrder
			}),

			-- LEFT (1fr)
			LeftPanel = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(1 / 4, 1),
				LayoutOrder = 1,
				Image = images.ColumnPreview,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(2 / 165, 0),
					PaddingBottom = UDim.new(2 / 165, 0),
					PaddingLeft = UDim.new(4 / 300, 0),
					PaddingRight = UDim.new(4 / 300, 0),
				}),

				Content = Roact.createElement("ImageLabel", {
					Size = UDim2.fromScale(1, 1),
					Image = images.ColumnBg,
				}),
			}),

			-- CENTER (2fr)
			CenterPanel = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(2 / 4, 1),
				Image = images.MainColumnBg,
				LayoutOrder = 2,
			}),

			-- RIGHT (1fr, grid)
			RightPanel = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(1 / 4, 1),
				Image = images.ColumnBg,
				ClipsDescendants = true,
				LayoutOrder = 2,
			}, {

				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(2 / 165, 0),
					PaddingBottom = UDim.new(2 / 165, 0),
					PaddingLeft = UDim.new(4 / 300, 0),
					PaddingRight = UDim.new(4 / 300, 0),
				}),

				Grid = Roact.createElement("UIGridLayout", {
					CellSize = UDim2.fromScale(1 / 4, 0.15),
 					CellPadding = UDim2.fromScale(2 / 300, 2 / 165),
					FillDirectionMaxCells = 4,
				}),
			}),
		}),
	})
end

return InventoryUI
