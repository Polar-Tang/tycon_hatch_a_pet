local Roact = require(game.ReplicatedStorage.Roact)

local function LeftColumn(props)
	local images = props.images
	local sidesPadding = props.sidesPadding
	local yPadding = props.yPadding

	return Roact.createElement("ImageLabel", {
		Size = UDim2.fromScale(1 / 4, 1),
		LayoutOrder = props.LayoutOrder or 1,
		Image = images.ColumnBg,
		BackgroundTransparency = 1,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingRight = UDim.new(sidesPadding * 2, 0),
			PaddingLeft = UDim.new(sidesPadding * 2, 0),
			PaddingTop = UDim.new(0.019, 0),
			PaddingBottom = UDim.new(0.019, 0),
		}),

        Header = Roact.createElement("ImageLabel", {
            Size = UDim2.fromScale(1 - sidesPadding, yPadding * 4),
            Image = images.LeftHeader,
            Position = UDim2.fromScale(sidesPadding / 2, 0),
            BackgroundTransparency = 1,
        }, {
            Padding = Roact.createElement("UIPadding", {
            PaddingTop = UDim.new(yPadding / 2, 0),
            PaddingBottom = UDim.new(yPadding / 2, 0),
            PaddingLeft = UDim.new(sidesPadding / 2, 0),
            PaddingRight = UDim.new(sidesPadding / 2, 0),
            }),

            Layout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0.02, 0),
            }),

            Title = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(0.6, 1),
            BackgroundTransparency = 1,
            Font = Enum.Font.FredokaOne,
            TextScaled = true,
            Text = props.title or "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            LayoutOrder = 1,
            }, {
            Outline = Roact.createElement("UIStroke", {
                Thickness = 2,
                Color = Color3.fromRGB(0, 0, 0),
            }),

            Shadow = Roact.createElement("UIShadow", {
                Blur = 0,
                Transparency = 0.5,
                Offset = Vector2.new(2, 2),
            }),
            }),

            ImagesContainer = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.4, 1),
            BackgroundTransparency = 1,
            LayoutOrder = 2,
            }, {
            Layout = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0.05, 0),
            }),

            Image1 = Roact.createElement("ImageLabel", {
                Size = UDim2.fromScale(0.5, 1),
                Image = "",
                BackgroundTransparency = 1,
                LayoutOrder = 1,
            }),

            Image2 = Roact.createElement("ImageLabel", {
                Size = UDim2.fromScale(0.5, 1),
                Image = "",
                BackgroundTransparency = 1,
                LayoutOrder = 2,
            }),
            }),
        }),

		Content = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(1 - sidesPadding, 1 - (yPadding / 2 + yPadding * 4)),
			Image = images.ColumnPreview,
			Position = UDim2.fromScale(sidesPadding / 2, yPadding / 2 + yPadding * 4),
			BackgroundTransparency = 1,
		}, {
			Content = Roact.createElement("ScrollingFrame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ScrollBarThickness = 1,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,
				ZIndex = 3,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4),
				}),

				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(yPadding / 2, 0),
					PaddingBottom = UDim.new(yPadding / 2, 0),
					PaddingLeft = UDim.new(sidesPadding / 2, 0),
					PaddingRight = UDim.new(sidesPadding / 2, 0),
				}),
			}),
		}),
	})
end

return LeftColumn
