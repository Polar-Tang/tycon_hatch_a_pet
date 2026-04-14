local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Roact)

local tooltip = Roact.Component:extend("tooltip")
function tooltip:render()
    local size = self.props.size
    local Position = self.props.Position
    local item = self.props.item

	return Roact.createElement("Frame", {
		Size = size, -- Relative size, adjust as needed
		Position = Position, -- Position near the right panel
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		BorderSizePixel = 2,
		BorderColor3 = Color3.fromRGB(100, 100, 100),
		ZIndex = 10,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.1, 0),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		ItemName = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(0.4, 1),
			Text = item.itemName or "Unknown Item",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			Font = Enum.Font.SourceSansBold,
			BackgroundTransparency = 1,
		}),
		SellButton = Roact.createElement("TextButton", {
			Size = UDim2.fromScale(0.25, 0.8),
			Text = "Sell",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 12,
			Font = Enum.Font.SourceSans,
			BackgroundColor3 = Color3.fromRGB(255, 165, 0), -- Orange
			BorderSizePixel = 0,
			[Roact.Event.Activated] = function()
				-- TODO: Implement sell functionality
				print("Sell item:", item.itemName)
			end,
		}),
		EquipButton = Roact.createElement("TextButton", {
			Size = UDim2.fromScale(0.25, 0.8),
			Text = "Equip",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 12,
			Font = Enum.Font.SourceSans,
			BackgroundColor3 = Color3.fromRGB(0, 128, 0), -- Green
			BorderSizePixel = 0,
			[Roact.Event.Activated] = function()
				-- TODO: Implement equip functionality
				print("Equip item:", item.itemName)
			end,
		}),
	})
end
return tooltip