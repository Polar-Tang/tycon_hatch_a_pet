local Roact = require(game.ReplicatedStorage.Roact)

local Card = Roact.Component:extend("Card")

function Card:render()
	local Position = self.props.Position
	local Size = self.props.Size
	local Title = self.props.Title

	local function createPetValueLabels()
		local texts = {
			Font = Enum.Font.Gotham,
			TextWrapped = true,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(120, 120, 120),
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 24),
		}

		local petsValue: { [string]: number } = self.props.petsValue or {}

		local elements = {}

		for petValueKey, petValueValue in pairs(petsValue) do
			-- plural check
			local name = petValueKey
			local petsRepetition = #self.props.petsBooster[name]
			if petsRepetition > 1 then
				name = name .. "s"
			end

			local textString = string.format("%-8s for %s (%s)", "X" .. tostring(petValueValue), name, tostring(petsRepetition))

			elements[petValueKey] = Roact.createElement("TextLabel", {
				Text = textString,
				LayoutOrder = petValueValue, -- optional (helps ordering)
				-- merge shared props
				Font = texts.Font,
				TextWrapped = texts.TextWrapped,
				TextScaled = texts.TextScaled,
				TextColor3 = texts.TextColor3,
				BackgroundTransparency = texts.BackgroundTransparency,
				Size = texts.Size,
			})
		end

		return elements
	end

	return Roact.createElement("Frame", {
		Size = Size,
		Position = Position,
		BackgroundColor3 = Color3.fromRGB(240, 240, 240),
		[Roact.Event.MouseEnter] = self.props.MouseEnter,
		[Roact.Event.MouseLeave] = self.props.MouseLeave,
	}, {
		Corner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),

		Stroke = Roact.createElement("UIStroke", {
			Color = Color3.fromRGB(40, 40, 40),
			Thickness = 3,
		}),

		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
		}),

		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),

		Title = Roact.createElement("TextLabel", {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			Text = Title,
			Font = Enum.Font.GothamBold,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(40, 40, 40),
		}),

		Description = Roact.createElement("ScrollingFrame", {
			LayoutOrder = 2,
			Size = UDim2.new(0.799, 0, 0.75, 0),
			BackgroundTransparency = 1,
			CanvasSize = UDim2.new(0, 0, 0, 0), -- will be updated automatically
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 6,
		}, {
			ListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
			}),

			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 4),
			}),
			Items = Roact.createFragment(createPetValueLabels()),
		}),
	})
end

return Card
