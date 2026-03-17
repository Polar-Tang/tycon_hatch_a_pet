type args = {
	Size: Vector3?,
	Color3: Color3?,
	Position: Vector3?,
	Duration: number?,
	Nate: boolean?,
	Name: string?,
	CFrame: CFrame?,
}

return function(data: args)
	local testPart = Instance.new("Part")
	testPart.Size = data.Size or Vector3.new(1, 1, 1)
	testPart.Color = data.Color3 or Color3.fromRGB(0, 0, 255)
	testPart.Material = Enum.Material.Neon
	testPart.CanCollide = false
	testPart.Anchored = true
	if data.Position then
		testPart.Position = data.Position
	end
	if data.CFrame then
		testPart.CFrame = data.CFrame
	end

	testPart.Parent = workspace
	if data.Nate then
		testPart.Name = data.Name
	end
end
