local map = require(script.map)
type twoDMap = {
	X: number,
	Z: number,
}

return function(start: twoDMap, goal: twoDMap)
	local path = map:find(start, goal)
	for key, value in next, path do
		local p = Instance.new("Part")
		p.Position = value
		p.Anchored = true
		p.Size = Vector3.new(4, 4, 4)
		p.Color = Color3.new(0, 0, 1)
		p.Parent = workspace
	end
	return path
end
