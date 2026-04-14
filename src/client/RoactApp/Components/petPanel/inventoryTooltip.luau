local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Roact)

local tooltip = Roact.Component:extend("tooltip")
function tooltip:render()
	local size = self.props.toolTipsize
	local position = self.props.toolTipPosition
	local item = self.props.selectedItemData
	local layer = 5

	return Roact.createElement("Frame", {
		Size = size, -- Relative size, adjust as needed
		Position = position, -- Position near the right panel
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		BorderSizePixel = 2,
		BorderColor3 = Color3.fromRGB(100, 100, 100),
		ZIndex = layer,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 5),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Header = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.15),
			BackgroundTransparency = 1,
			ZIndex = layer,
			LayoutOrder = 1,
		}, {
			HeaderLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 5),
			}),
			ItemName = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(0.8, 1),
				Text = item.itemName or "Unknown Item",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				Font = Enum.Font.SourceSansBold,
				BackgroundTransparency = 1,
				ZIndex = layer + 1,
			}),
			CloseButton = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(0.2, 1),
				Text = "X",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 12,
				Font = Enum.Font.SourceSansBold,
				BackgroundColor3 = Color3.fromRGB(200, 50, 50),
				BorderSizePixel = 0,
				ZIndex = layer + 1,
				[Roact.Event.Activated] = function()
					self.props.closeToolTip()
				end,
			}),
		}),
		Buttons = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.2),
			BackgroundTransparency = 1,
			ZIndex = layer,
			LayoutOrder = 2,
		}, {
			ButtonLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 5),
			}),
			SellButton = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(0.5, 1),
				Text = "Sell",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 12,
				Font = Enum.Font.SourceSans,
				BackgroundColor3 = Color3.fromRGB(255, 165, 0),
				BorderSizePixel = 0,
				ZIndex = layer + 1,
				[Roact.Event.Activated] = function()
					print("Sell item:", item.itemName)
				end,
			}),
			EquipButton = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(0.5, 1),
				Text = "Equip",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 12,
				Font = Enum.Font.SourceSans,
				BackgroundColor3 = Color3.fromRGB(0, 128, 0),
				BorderSizePixel = 0,
				ZIndex = layer + 1,
				[Roact.Event.Activated] = function()
					print("Equip item:", item.itemName)
				end,
			}),
		}),
	})
end
return tooltip
