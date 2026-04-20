local Roact = require(game.ReplicatedStorage.Roact)
local StarterPlayer = game:GetService("StarterPlayer")
local TextService = game:GetService("TextService")
local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)

local UpgradeSet = Roact.Component:extend("UpgradeSet")

function UpgradeSet:init() end

function UpgradeSet:render()
	local props = self.props

	local title = props.Title or "Speed"
	local level = props.Level or 5
	local maxLevel = props.MaxLevel or 7

	local font = Enum.Font.FredokaOne

	local textSize = TextService:GetTextSize(title, 30, font, Vector2.new(math.huge, math.huge))

	local refSize = Vector2.new(264, 171)
	local buttonWidth = 21

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0.3333333333334, 0),
	}, {

		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		-- TITLE
		Title = Roact.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Text = title,
			Font = font,
			-- TextSize = textSize,
			TextColor3 = Color3.fromRGB(235, 235, 235),
			Size = UDim2.new(0, textSize.X, 0, textSize.Y),
			LayoutOrder = 1,
			TextScaled = true,
			TextStrokeTransparency = 0.8,
			TextWrapped = true,
		}, {
			Outline = Roact.createElement("UIStroke", {
				Thickness = 2,
				Color = Color3.fromRGB(0, 0, 0),
			}),

			Shadow = Roact.createElement("UIShadow", {
				BlurRadius = UDim.new(0, 0),
				Transparency = 0.5,
				Offset = UDim2.new(0, 2, 0, 2),
			}),
		}),

		--[[
            0/264 , 0/171 - 7
            SCREENWIDTH - X
        ]]
		-- ROW
		Row = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, -7),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
		}, {

			RowLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(5 / refSize.Y, 0),
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceAround,
			}),

			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 0),
				PaddingBottom = UDim.new(0.019, 0),
				PaddingLeft = UDim.new(0.007, 0),
				PaddingRight = UDim.new(0.007, 0),
			}),

			-- MINUS
			Minus = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(21 / 300, 56 / 165),
				BackgroundTransparency = 1,
				Image = assets.player_inventory.MinusIcon,
				LayoutOrder = 1,
			}),

			-- UPGRADES
			Upgrades = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1 - (buttonWidth / 300 * 4), 0, 56 / 165, 0),
				LayoutOrder = 2,
			}, { --0.672

				Padding = Roact.createElement("UIPadding", {
					PaddingRight = UDim.new(0.037, 0),
				}),

				List = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 2),
				}),

				Icons = Roact.createFragment((function()
					local children = {}

					for i = 1, maxLevel do
						children["U" .. i] = Roact.createElement("ImageLabel", {
							Size = UDim2.new(1 / maxLevel, 0, 1, 0),

							BackgroundTransparency = 1,
							Image = i <= level and assets.player_inventory.DoneUpgrade
								or assets.player_inventory.BlankUpgrade,
						})
					end

					return children
				end)()),
			}),

			-- PLUS
			Plus = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(21 / 300, 56 / 165),
				BackgroundTransparency = 1,
				Image = assets.player_inventory.PlusIcon,
				LayoutOrder = 3,
			}),
		}),
	})
end

return UpgradeSet
