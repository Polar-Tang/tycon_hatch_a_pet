local GetRandPos = require(script.Parent.Parent.GetRandPos)

return function(data)
	print("Called drop items")
	local startPos = data.originalPos
	local drop = Instance.new("Part")
	drop.Size = Vector3.new(1, 1, 1)
	drop.Position = startPos
	drop.CanCollide = true
	--drop.Transparency = 1

	local billBoard = Instance.new("BillboardGui")
	billBoard.Adornee = drop
	billBoard.Size = UDim2.new(0, 50, 0, 50)
	billBoard.StudsOffset = Vector3.new(0, 3, 0)
	billBoard.AlwaysOnTop = true

	local ImageItem = Instance.new("ImageLabel")
	ImageItem.Size = UDim2.new(1, 0, 1, 0)
	ImageItem.BackgroundTransparency = 1
	ImageItem.Image = "rbxassetid://73014785414372"

	ImageItem.Parent = billBoard
	billBoard.Parent = drop
	drop.Parent = workspace

	local RunService = game:GetService("RunService")

	local goal = GetRandPos(startPos, 10)
	-- goal - origin - 0.5*gravity*T^2/T
	local T = 0.5
	local gravity = Vector3.new(0, -workspace.Gravity, 0)

	local initialVelocity = (goal - startPos - 0.5 * gravity * T ^ 2) / T
	local t: number = 0
	local connection: RBXScriptSignal | nil = nil
	connection = RunService.Heartbeat:Connect(function(deltaTime)
		t += deltaTime

		--// s = s0 + v0*t + 0.5*a*t^2

		local newPos = startPos + (initialVelocity * t) + 0.5 * gravity * (t ^ 2)
		drop:PivotTo(CFrame.new(newPos))
		if t >= T then
			connection:Disconnect()
		end
	end)
end
