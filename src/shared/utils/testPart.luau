type args = {
	Size: Vector3?,
	Color3: Color3?,
	Position: Vector3,
	Duration: number?,
	Nate: boolean?,
	Name: string?,
}

return function(data: args)
	local testPart = Instance.new("Part")
	testPart.Size = data.Size or Vector3.new(1, 1, 1)
	testPart.Color = data.Color3 or Color3.fromRGB(0, 0, 255)
	testPart.Material = Enum.Material.Neon
	testPart.CanCollide = false
	testPart.Anchored = true
	testPart.Position = data.Position
	testPart.Parent = workspace
	if data.Nate then
		testPart.Name = data.Name
	end
end
