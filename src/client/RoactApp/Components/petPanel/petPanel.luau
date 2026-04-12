local Roact = require(game.ReplicatedStorage.Roact)

local function InventoryUI()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1), -- container scales to screen
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	}, {

		-- Aspect ratio to preserve 300x165 proportions
		Aspect = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 300/165
		}),

		-- Topbar
		Topbar = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 10/165),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
		}, {
			Title = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(80/300, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Text = "Player Inventory",
				BackgroundTransparency = 1,
				TextScaled = true,
			}),

			Close = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(10/300, 1),
				Position = UDim2.fromScale(1, 0),
				AnchorPoint = Vector2.new(1, 0),
				Text = "X",
				BackgroundColor3 = Color3.fromRGB(200, 50, 50),
			})
		}),

		-- Content
		Content = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1 - (10/165)),
			Position = UDim2.fromScale(0, 10/165),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        }, {

            Padding = Roact.createElement("UIPadding", {
                PaddingTop = UDim.new(4/165, 0),
                PaddingBottom = UDim.new(4/165, 0),
                PaddingLeft = UDim.new(4/300, 0),
                PaddingRight = UDim.new(4/300, 0),
            }),

            Layout = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(2/300, 0),
            }),

            -- LEFT (1fr)
            LeftPanel = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1/4, 1),
                BackgroundColor3 = Color3.fromRGB(200, 200, 200),
            }, {
                Padding = Roact.createElement("UIPadding", {
                    PaddingTop = UDim.new(2/165, 0),
                    PaddingBottom = UDim.new(2/165, 0),
                    PaddingLeft = UDim.new(4/300, 0),
                    PaddingRight = UDim.new(4/300, 0),
                }),

                Content = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1,1),
                    BackgroundColor3 = Color3.fromRGB(180,180,180),
                })
            }),

            -- CENTER (2fr)
            CenterPanel = Roact.createElement("Frame", {
                Size = UDim2.fromScale(2/4, 1),
                BackgroundColor3 = Color3.fromRGB(220, 220, 220),
            }),

            -- RIGHT (1fr, grid)
            RightPanel = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1/4, 1),
                BackgroundColor3 = Color3.fromRGB(200, 200, 200),
                ClipsDescendants = true,
            }, {

                Padding = Roact.createElement("UIPadding", {
                    PaddingTop = UDim.new(2/165, 0),
                    PaddingBottom = UDim.new(2/165, 0),
                    PaddingLeft = UDim.new(4/300, 0),
                    PaddingRight = UDim.new(4/300, 0),
                }),

                Grid = Roact.createElement("UIGridLayout", {
                    CellSize = UDim2.fromScale(1/4, 0.15),
                    CellPadding = UDim2.fromScale(2/300, 2/165),
                    FillDirectionMaxCells = 4,
                }),
            })
		})
	})
end

return InventoryUI