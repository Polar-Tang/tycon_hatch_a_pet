local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- PlotService.lua
local FenceBoundsService = {}
FenceBoundsService.__index = FenceBoundsService

local Constants = require(ReplicatedStorage.utils.Constants)
local FenceBounds = require(script.FenceBounds)

local plots = CollectionService:GetTagged("plots")
local plotCount = 0

-- Utility
local function isFree(plot)
	return not plot:WaitForChild("IsOnline").Value
end

local function isCached(plot)
	return not plot:WaitForChild("IsOnline").Value and plot:WaitForChild("OwnerUserId") ~= nil
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

function FenceBoundsService:EvitPlayerPlot(player) end

function FenceBoundsService:AssignPlot(plot, player)
	local userId: StringValue = plot:WaitForChild("OwnerUserId")
	userId.Value = player.UserId

	local isOn: BoolValue = plot:WaitForChild("IsOnline")
	isOn.Value = true

	plot:SetAttribute("CachedAt", nil)
	CollectionService:AddTag(plot, "plot_" .. player.UserId)

	local plotId = plot:WaitForChild("PlotId")
	if plotId.Value == 0 then
		plotCount = plotCount + 1
		plotId.Value = plotCount
	end
end

function FenceBoundsService:MarkOffline(plot)
	local isOn: BoolValue = plot:WaitForChild("IsOnline")
	isOn.Value = false
	plot:SetAttribute("CachedAt", os.time())
end

function FenceBoundsService:_resetPlot(plot)
	local userId: StringValue = plot:WaitForChild("OwnerUserId")
	userId.Value = ""

	local isOn: BoolValue = plot:WaitForChild("IsOnline")
	isOn.Value = false

	plot:SetAttribute("CachedAt", nil)
end

function FenceBoundsService.GetPlotByUserId(Id: string): BasePart?
	for _, plot in pairs(plots) do
		local ownerShit = plot:WaitForChild("OwnerUserId")
		if ownerShit.Value and tostring(ownerShit.Value) == tostring(Id) then
			return plot
		end
	end
	return
end

function FenceBoundsService:ClampToBounds(plot, position)
	local fenceCF = plot.CFrame
	local fenceSize = plot.Size

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

function FenceBoundsService:GetRandPosition(plot: BasePart, YOffset): Vector3
	local fencePos = Vector3.new(plot.Position.X, plot.Position.Y, plot.Position.Z)

	local fenceSize = Vector3.new(plot.Size.X, plot.Size.Y, plot.Size.Z)

	local half = fenceSize * 0.5
	local minX = fencePos.X - half.X
	local maxX = fencePos.X + half.X
	local minZ = fencePos.Z - half.Z
	local maxZ = fencePos.Z + half.Z

	local x = math.random(minX, maxX)
	local z = math.random(minZ, maxZ)
	return Vector3.new(x, Constants.GroundY, z)
end

return FenceBoundsService :: FenceBounds.FenceBoundsService
