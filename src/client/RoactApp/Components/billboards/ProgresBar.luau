local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Roact)

local ultiBar = Roact.Component:extend("ultiBar")

local PERCENTAGE = 10

function ultiBar:init()
	self.initialized = false
	self.char_name = nil

	self:setState({
		percentage = 0,
	})
end

function ultiBar:didMount()
	local player = Players.LocalPlayer
	local player_char = player.Character or player.CharacterAdded:Wait()

	self._increaseConnection = game:GetService("RunService").Heartbeat:Connect(function()
		local newPercentage = math.max(0, self.state.percentage + 1)
		if tick() % 1 < 0.016 then
			self:setState({
				percentage = newPercentage,
			})
			if newPercentage <= 0 then
				player_char:SetAttribute("IsTransformed", false)
			end
		end
	end)
	local parent: Model = self.props.model
	self._ancestryConnection = parent.AncestryChanged:Connect(function(a0: Instance, a1: Instance?)
		if not a0.Parent then
			self:unMount()
		end
	end)
end

function ultiBar:unMount()
	self._increaseConnection:Disconnect()
	self._ancestryConnection:Disconnect()
end

function ultiBar:render()
	local adornee = self.props.model
	return Roact.createElement("BillboardGui", {
		Adornee = adornee,
		Parent = adornee,
		Size = UDim2.fromOffset(200, 40),
		StudsOffset = Vector3.new(0, 4, 0),
		AlwaysOnTop = true,
		LightInfluence = 0,
		MaxDistance = 100,
	}, {

		BarBackground = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
			BackgroundTransparency = 0.6,
		}, {

			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),

			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			}),

			Bar = Roact.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(0, 225, 255),
				BackgroundTransparency = 0.2,
				Size = UDim2.fromScale(math.min(PERCENTAGE, self.state.percentage) / PERCENTAGE, 1),
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
			}),
		}),
	})
end

function ultiBar:willUnmount()
	if self._connection then
		self._connection:Disconnect()
	end
	if self._increaseConnection then
		self._increaseConnection:Disconnect()
	end
end
return ultiBar
