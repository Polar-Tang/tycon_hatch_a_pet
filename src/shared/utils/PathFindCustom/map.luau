local maze = require(script.Parent.maze)
local map = {}

function map:getNode(pos)
	return maze.cells[pos.X][pos.Z]
end

local t = 0
local fringe
local i = 0
local c = 0
local len = 0
local function remove(key)
	len = len - 1
	key.next.prev = key.prev
	key.prev.next = key.next
end
local function getMin()
	local s = tick()
	local key
	key = fringe.key
	remove(fringe)
	fringe = fringe.next
	t = t + tick() - s
	return key
end
local function insert(key)
	c = c + len
	i = i + 1
	len = len + 1
	local s = tick()
	local cur = fringe
	while key.value > cur.value do
		cur = cur.next
	end
	key.prev = cur.prev
	key.next = cur
	cur.prev = key
	key.prev.next = key
	if cur == fringe then
		fringe = key
	end
	t = t + tick() - s
end
local function decrease(key)
	local s = tick()
	remove(key)
	insert(key)
	t = t + tick() - s
end

local function distance(n1, n2)
	local dx = math.abs(n1.x - n2.x)
	local dy = math.abs(n1.y - n2.y)
	return math.max(dx, dy)
end

local EMPTY = {}
EMPTY.next = EMPTY
EMPTY.prev = EMPTY
EMPTY.value = math.huge
function map:find(startPos, goalPos)
	local s = tick()
	local start = self:getNode(startPos)
	local goal = self:getNode(goalPos)

	local from = {}
	local closed = {}
	local cost = { [start] = 0 }
	fringe = EMPTY
	start.value = 0
	insert(start)

	local n = 0
	while fringe ~= EMPTY do
		local cur = fringe
		fringe = fringe.next
		closed[cur] = true
		n = n + 1

		if cur == goal then
			local path = {}
			while cur do
				local x, z = maze.hexToRect(cur.x, cur.y)
				path[#path + 1] = Vector3.new(x, maze.yOffset, z)
				cur = from[cur]
			end
			local f = tick()
			print("Run time:", f - s)
			print("Percent time spend in queue ops:", t / (f - s))
			print("Num inserts:", i)
			print("Avg nodes in queue during insert:", c / i)
			print("Num nodes visited:", n)
			return path
		end

		local curCost = cost[cur]
		for node, toCost in next, cur.adjacent do
			local nodeCost = curCost + toCost
			if closed[node] == nil then
				if node.value then
					if nodeCost < node.value then
						node.value = nodeCost + node.value - cost[node]
						decrease(node)
						cost[node] = nodeCost
						from[node] = cur
					end
				else
					node.value = nodeCost + distance(node, goal)
					insert(node)
					cost[node] = nodeCost
					from[node] = cur
				end
			end
		end
	end
end

return map
