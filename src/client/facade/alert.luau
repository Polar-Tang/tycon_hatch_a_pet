--!strict

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Alert = {}

local activeAlerts = {}

local function getAlertGui()
	local player = Players.LocalPlayer
	if not player then
		return nil
	end

	local playerGui = player:WaitForChild("PlayerGui")
	local gui = playerGui:FindFirstChild("AlertGui")
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "AlertGui"
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = playerGui
	end

	return gui
end

local function removeAlert(container)
	local index = nil
	for i, alert in ipairs(activeAlerts) do
		if alert.frame == container then
			index = i
			break
		end
	end
	if not index then return end

	-- Tween hide
	local hideGoals = {
		Position = UDim2.new(0.5, 0, 0, -40),
		BackgroundTransparency = 1,
	}
	local hideTextGoals = {
		TextTransparency = 1,
	}

	local hideTween = TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), hideGoals)
	local hideTextTween = TweenService:Create(activeAlerts[index].label, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), hideTextGoals)
	hideTween:Play()
	hideTextTween:Play()
	hideTween.Completed:Connect(function()
		container:Destroy()
	end)

	-- Remove from table
	table.remove(activeAlerts, index)

	-- Shift remaining alerts up
	for i = index, #activeAlerts do
		local alert = activeAlerts[i]
		local newY = 14 + (i - 1) * 40
		local shiftGoals = {
			Position = UDim2.new(0.5, 0, 0, newY),
		}
		local shiftTween = TweenService:Create(alert.frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), shiftGoals)
		shiftTween:Play()
	end
end

function Alert.alert(notification: string)
	local gui = getAlertGui()
	if not gui then
		return
	end

	local container = Instance.new("Frame")
	container.Name = "Notification"
	container.AnchorPoint = Vector2.new(0.5, 0)
	container.Position = UDim2.new(0.5, 0, 0, -40)
	container.Size = UDim2.new(0.5, 0, 0, 40)
	container.BackgroundColor3 = Color3.new(1, 1, 1)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Parent = gui

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, 0, 0.5, 0)
	label.Size = UDim2.new(0.95, 0, 0.9, 0)
	label.BackgroundTransparency = 1
	label.Text = notification or ""
	label.TextColor3 = Color3.new(0, 0, 0)
	label.Font = Enum.Font.SourceSansSemibold
	label.TextSize = 18
	label.TextWrapped = true
	label.TextScaled = true
	label.TextTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = container

	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local stackedY = 14 + (#activeAlerts * 40)
	local showGoals = {
		Position = UDim2.new(0.5, 0, 0, stackedY),
		BackgroundTransparency = 0,
	}
	local showTextGoals = {
		TextTransparency = 0,
	}

	local showTween = TweenService:Create(container, tweenInfo, showGoals)
	local showTextTween = TweenService:Create(label, tweenInfo, showTextGoals)
	showTween:Play()
	showTextTween:Play()

	-- Add to active alerts
	table.insert(activeAlerts, {frame = container, label = label})

	-- Schedule removal
	task.delay(3, function()
		removeAlert(container)
	end)
end

return Alert
