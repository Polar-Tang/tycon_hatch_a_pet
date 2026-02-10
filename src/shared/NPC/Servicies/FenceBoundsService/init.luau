local CollectionService = game:GetService("CollectionService")
-- FenceBoundsService.lua
local FenceBoundsService = {}
FenceBoundsService.__index = FenceBoundsService

local FenceBounds = require(script.FenceBounds)

local plots = CollectionService:GetTagged("plots")

-- Utility
local function isFree(plot)
	return not plot:FindFirstChild("IsOnline").Value
end

local function isCached(plot)
	return not plot:FindFirstChild("IsOnline").Value and plot:FindFirstChild("OwnerUserId") ~= nil
end

-- MAIN ENTRY POINT
function FenceBoundsService:GetAvailablePlot()
	-- 1️⃣ Prefer free plots
	for _, plot in ipairs(plots) do
		if isFree(plot) then
			return plot
		end
	end

	-- 2️⃣ Evict oldest cached plot
	local oldestPlot
	local oldestTime = math.huge

	for _, plot in ipairs(plots) do
		if isCached(plot) then
			local cachedAt = plot:GetAttribute("CachedAt")
			if cachedAt and cachedAt < oldestTime then
				oldestTime = cachedAt
				oldestPlot = plot
			end
		end
	end

	if oldestPlot then
		self:_resetPlot(oldestPlot)
		return oldestPlot
	end

	return nil
end

function FenceBoundsService:AssignPlot(plot, player)
	local userId: StringValue = plot:FindFirstChild("OwnerUserId")
	userId.Value = player.UserId

	local isOn: BoolValue = plot:FindFirstChild("IsOnline")
	isOn.Value = true

	plot:SetAttribute("CachedAt", nil)
end

function FenceBoundsService:MarkOffline(plot)
	local isOn: BoolValue = plot:FindFirstChild("IsOnline")
	isOn.Value = false
	plot:SetAttribute("CachedAt", os.time())
end

function FenceBoundsService:_resetPlot(plot)
	local userId: StringValue = plot:FindFirstChild("OwnerUserId")
	userId.Value = ""

	local isOn: BoolValue = plot:FindFirstChild("IsOnline")
	isOn.Value = false

	plot:SetAttribute("CachedAt", nil)
end

function FenceBoundsService:ClampToBounds(position)
	local fenceCF = workspace.FenceBounds.CFrame
	local fenceSize = workspace.FenceBounds.Size

	local offset = position - fenceCF.Position

	local right = fenceCF.RightVector
	local up = fenceCF.UpVector
	local look = fenceCF.LookVector

	local x = offset:Dot(right)
	local y = offset:Dot(up)
	local z = offset:Dot(look)

	local half = fenceSize * 0.5

	x = math.clamp(x, -half.X, half.X)
	z = math.clamp(z, -half.Z, half.Z)
	local bouncedPosition = fenceCF.Position + right * x + up * y + look * z

	return bouncedPosition
end

function FenceBoundsService:GetRandPosition(plot): Vector3
	local fenceCF = plot.CFrame
	local fenceSize = plot.Size

	local half = fenceSize * 0.5
	local minX = fenceCF.Position.X - half.X
	local maxX = fenceCF.Position.X + half.X
	local minZ = fenceCF.Position.Z - half.Z
	local maxZ = fenceCF.Position.Z + half.Z

	local x = math.random(minX, maxX)
	local z = math.random(minZ, maxZ)

	return Vector3.new(x, fenceCF.Position.Y, z)
end

return FenceBoundsService :: FenceBounds.FenceBoundsService
