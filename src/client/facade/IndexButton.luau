local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local screen = PlayerGui:WaitForChild("ScreenGui")

local IndexButton = {}

local HOVER_SCALE = 1.1
local NORMAL_SCALE = 1.0
local TWEEN_DURATION = 0.15
local TWEEN_STYLE = Enum.EasingStyle.Quad
local TWEEN_DIR = Enum.EasingDirection.Out

local _maid = Maid.new()

local function applyHoverEffect(button: ImageButton)
	local originalSize = button.Size

	local function scaledSize(factor: number): UDim2
		return UDim2.new(
			originalSize.X.Scale * factor,
			originalSize.X.Offset * factor,
			originalSize.Y.Scale * factor,
			originalSize.Y.Offset * factor
		)
	end
	-- {0.016, 0},{0.471, 0}
	local function tweenSize(targetSize: UDim2)
		local info = TweenInfo.new(TWEEN_DURATION, TWEEN_STYLE, TWEEN_DIR)
		local tween = TweenService:Create(button, info, { Size = targetSize })
		tween:Play()
	end

	-- Anchor to center so it scales from the middle
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.Position = UDim2.new(
		button.Position.X.Scale + button.Size.X.Scale / 2,
		button.Position.X.Offset,
		button.Position.Y.Scale + button.Size.Y.Scale / 2,
		button.Position.Y.Offset
	)

	_maid:GiveTask(button.MouseEnter:Connect(function()
		tweenSize(scaledSize(HOVER_SCALE))
	end))

	_maid:GiveTask(button.MouseLeave:Connect(function()
		tweenSize(scaledSize(NORMAL_SCALE))
	end))

	-- Safety: snap back if button is pressed and released quickly
	_maid:GiveTask(button.MouseButton1Down:Connect(function()
		tweenSize(scaledSize(NORMAL_SCALE))
	end))
end

function IndexButton.getIndexButton(): ImageButton
	return screen.IndexButton
end

function IndexButton.rotate(rotation: number)
	screen.IndexButton.Rotation = rotation
end

function IndexButton.init()
	applyHoverEffect(screen.IndexButton)
end

function IndexButton.destroy()
	_maid:Destroy()
end

return IndexButton
