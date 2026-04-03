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
				local delayClose = task.delay(0.5, function()
					if not self.state.isHoveringToolTip then
						self:setState({ hovering = false })
					end
				end)
				self._maid._cleanup = delayClose
			end,
		}),
		Tooltip = self.state.hovering and Roact.createElement(Card, {
			Title = self.props.cardTitle,
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Size = self.props.ToolTipSize,
			Position = self.props.ToolTipPosition,
			petsValue = self.props.petsValue,
			petsBooster = self.props.petsBooster,
			isHoveringToolTip = self.props.isHoveringToolTip,
			MouseEnter = function()
				self:setState({ isHoveringToolTip = true })
			end,
			MouseLeave = function()
				self:setState({ isHoveringToolTip = false, hovering = false })
			end,
		}) or nil,
	})
end

return TooltipExample
