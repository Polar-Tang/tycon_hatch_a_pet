--Settings
local size = 20
local height = size
local yOffset = 30
local thickness = 2
local mazeWidth = 60
local mazeHeight = 60
print("Num Nodes:", mazeWidth * mazeHeight)
--End Settings

--Externals
local random = math.random
local floor = math.floor
local vector = Vector3.new
local cframe = CFrame.new
--END Externals

--Constants
local sqrt3 = 3 ^ 0.5
local alpha = size * 0.25
local alpha2 = alpha * 2
local beta = alpha * sqrt3
local beta2 = beta * 2
local length = alpha * 2 + thickness / sqrt3
local wallSize = vector(length, height, thickness)
local xSideLength = beta * mazeWidth - beta * 0.5
local ySideLength = 1.5 * alpha * mazeHeight - alpha * 0.5
--END Constants

--Snipits
local function shuffle(array)
	local num = #array
	for i = 1, num do
		local j = random(i, num)
		array[i], array[j] = array[j], array[i]
	end
end
local function hexToRect(hX, hY)
	local rX = hX * beta * 2 + hY * beta
	local rY = hY * beta * sqrt3
	return rX, rY
end
local function rectToHex(rX, rY)
	local hY = rY / (beta * sqrt3)
	local hX = (rX - hY * beta) / (beta * 2)
	return hX, hY
end
local function createPart(cFrame, size)
	local part = Instance.new("Part")
	part.Anchored = true
	part.FormFactor = "Custom"
	part.Size = size
	part.CFrame = cFrame
	part.Parent = workspace
end
local function getGroup(node)
	if node.group then
		node.group = getGroup(node.group)
		return node.group
	else
		return node
	end
end
--END Snipits

local function createWall(wall)
	local c1x, c1y = hexToRect(wall[1].x, wall[1].y)
	local c2x, c2y = hexToRect(wall[2].x, wall[2].y)
	local wallPos = vector(c1x + (c2x - c1x) * 0.5, yOffset, c1y + (c2y - c1y) * 0.5)
	local lookAt = vector(c2x, yOffset, c2y)
	return createPart(cframe(wallPos, lookAt), wallSize)
end
local function generateMaze()
	local maze = {}
	for x = 1, mazeWidth do
		for y = 1, mazeHeight do
			local x = x - floor(y * 0.5)
			if not maze[x] then
				maze[x] = {}
			end
			maze[x][y] = { x = x, y = y, adjacent = {} }
		end
	end
	local walls = {}
	for x = 1, mazeWidth do
		for y = 1, mazeHeight do
			local x = x - floor(y * 0.5)
			local curCol = maze[x]
			local nxtCol = maze[x + 1]
			local cell = curCol[y]
			walls[#walls + 1] = curCol[y + 1] and { cell, curCol[y + 1] } or nil
			walls[#walls + 1] = nxtCol and nxtCol[y] and { cell, nxtCol[y] } or nil
			walls[#walls + 1] = nxtCol and nxtCol[y - 1] and { cell, nxtCol[y - 1] } or nil
		end
	end
	shuffle(walls)
	for i = 1, #walls do
		local wall = walls[i]
		local group1 = getGroup(wall[1])
		local group2 = getGroup(wall[2])
		if group1 ~= group2 then
			group2.group = group1
			wall[1].adjacent[wall[2]] = 1
			wall[2].adjacent[wall[1]] = 1
			walls[i] = nil
		end
	end
	return walls, maze
end
local function createMaze(walls)
	createPart( --Bottom Side
		cframe(vector(xSideLength + beta2, yOffset, alpha2), vector(xSideLength + beta2, yOffset, alpha2 + 1)),
		vector(xSideLength * 2, height, thickness)
	)
	createPart( --Top Side
		cframe(
			vector(xSideLength + beta2, yOffset, ySideLength * 2 + alpha2),
			vector(xSideLength + beta2, yOffset, ySideLength * 2 - 1 + alpha2)
		),
		vector(xSideLength * 2, height, thickness)
	)
	createPart( --Left Side
		cframe(vector(beta2, yOffset, ySideLength + alpha2), vector(beta2 + 1, yOffset, ySideLength + alpha2)),
		vector(ySideLength * 2, height, thickness)
	)
	createPart( --Right Side
		cframe(
			vector(xSideLength * 2 + beta2, yOffset, ySideLength + alpha2),
			vector(xSideLength * 2 + beta2 - 1, yOffset, ySideLength + alpha2)
		),
		vector(ySideLength * 2, height, thickness)
	)
	for _, wall in next, walls do
		createWall(wall)
	end
end

local walls, cells = generateMaze()
createMaze(walls)
return {
	hexToRect = hexToRect,
	rectToHex = rectToHex,
	yOffset = yOffset,
	cells = cells,
}
