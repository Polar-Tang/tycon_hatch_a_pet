local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Card = require(script.Parent.Card)
local Roact = require(game.ReplicatedStorage:WaitForChild("Roact"))

local TooltipExample = Roact.Component:extend("TooltipExample")

function TooltipExample:init()
	self:setState({ hovering = false, mousePos = Vector2.new(0, 0), isHoveringToolTip = false })
	self._maid = Maid.new()
end

function TooltipExample:render()
	local pos = self.props.Position
	local Size = self.props.Size
	local image = self.props.Image
	local Title = self.props.Title
	local layer = self.props.layer or 0

	return Roact.createFragment({
		Image = Roact.createElement("ImageLabel", {
			Image = "",
			Size = Size or UDim2.new(1, 0, 1, 0),
			Position = pos or UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			ZIndex = layer,
			[Roact.Event.MouseEnter] = function()
				self:setState({ hovering = true })
			end,
			[Roact.Event.MouseLeave] = function()
				task.delay(0.2, function()
					self:setState({ testing = true })
				end)
				local delayClose = task.delay(0.5, function()
					print(self.state)
					if not self.state.isHoveringToolTip then
						self:setState({ hovering = false })
					end
				end)
				self._maid._cleanup = delayClose
			end,
		}),

		Tooltip = self.state.hovering and Roact.createElement(Card, {
			Title = "Coin Boost",
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(3, 0, 1.25, 0),
			Position = UDim2.new(0, 0, -1, 0),
			petsValue = self.props.petsValue,
			petsRepetitions = self.props.petsRepetitions,
			isHoveringToolTip = self.props.isHoveringToolTip,
			MouseEnter = function()
				self:setState({ isHoveringToolTip = true })
			end,
			MouseLeave = function()
				self:setState({ isHoveringToolTip = false })
			end,
		}) or nil,
	})
end

return TooltipExample
