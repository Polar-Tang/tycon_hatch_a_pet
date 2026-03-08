return function(origin: Vector3, radius: number): Vector3
	local angle = math.rad(math.random(0, 360))
	local distance = math.random() * radius
	local xOffset = math.cos(angle) * distance
	local zOffset = math.sin(angle) * distance
	return Vector3.new(origin.X + xOffset, origin.Y, origin.Z + zOffset)
end
