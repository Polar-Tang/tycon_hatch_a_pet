return function(rootPart: BasePart, text: string, textColor: Color3?, size: UDim2?)
	print("text ", text)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CustomHumanoidBar"
	billboard.Adornee = rootPart
	billboard.Size = size or UDim2.new(1, 0, 1, 0)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = rootPart

	local DamageLabel = Instance.new("TextLabel")
	DamageLabel.Name = "Label"
	DamageLabel.Size = UDim2.new(1, 0, 1, 0)
	DamageLabel.BackgroundTransparency = 1
	DamageLabel.Text = tostring(text)
	DamageLabel.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
	DamageLabel.Position = UDim2.new(0, 0, 0, 0)
	DamageLabel.Font = Enum.Font.GothamBold
	DamageLabel.ZIndex = 2
	DamageLabel.TextScaled = true
	DamageLabel.Parent = billboard
	-- Animation: float up and fade out
	task.spawn(function()
		local duration = 1.0 -- seconds
		local startTime = tick()
		local startOffset = billboard.StudsOffset
		local floatDistance = 2 -- studs to move up
		while true do
			local elapsed = tick() - startTime
			local alpha = math.clamp(elapsed / duration, 0, 1)
			-- Move up
			billboard.StudsOffset = startOffset + Vector3.new(0, floatDistance * alpha, 0)
			-- Fade out
			DamageLabel.TextTransparency = alpha
			DamageLabel.TextStrokeTransparency = alpha
			if alpha >= 1 then
				break
			end
			task.wait()
		end
		billboard:Destroy()
	end)
end
