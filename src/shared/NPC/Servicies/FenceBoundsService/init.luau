local CollectionService = game:GetService("CollectionService")
-- FenceBoundsService.lua
local FenceBoundsService = {}
FenceBoundsService.__index = FenceBoundsService

local FenceBounds = require(script.FenceBounds)

local plots = CollectionService:GetTagged("plots")
local plotCount = 0

-- Utility
local function isFree(plot)

	return not plot:FindFirstChild("IsOnline").Value and plot:FindFirstChild("OwnerUserId").Value == ""
end

local function isCached(plot)
	return not plot:FindFirstChild("IsOnline").Value and plot:FindFirstChild("OwnerUserId").Value
end

-- MAIN ENTRY POINT
function FenceBoundsService:GetAvailablePlot()
	-- 1️⃣ Prefer free plots
	local oldestPlot
	for _, plot in ipairs(plots) do
		if isFree(plot) then
			return plot
		elseif isCached(plot) then
			oldestPlot = plot
		end
	end

	return oldestPlot
end

function FenceBoundsService:AssignPlot(plot, player)
	if isCached(plot) then 
		self:_resetPlot(plot)
	end

	local userId: StringValue = plot:FindFirstChild("OwnerUserId")
	userId.Value = player.UserId

	local isOn: BoolValue = plot:FindFirstChild("IsOnline")
	isOn.Value = true

	CollectionService:AddTag(plot, "plot_" .. player.UserId)

	local plotId = plot:FindFirstChild("PlotId")
	if plotId.Value == 0 then
		plotCount = plotCount + 1
		plotId.Value = plotCount
		print("plotId.Value ", plotId.Value)
	end
end

function FenceBoundsService:MarkOffline(plot)
	local isOn: BoolValue = plot:FindFirstChild("IsOnline")
	isOn.Value = false
	plot:SetAttribute("CachedAt", os.time())
end

function FenceBoundsService:_resetPlot(plot)
	
	local plotId: StringValue = plot:FindFirstChild("PlotId")
	local plot_tag = "plot_"..tostring(plotId.Value)
	local pets = CollectionService:GetTagged(plot_tag)
	for _, model in ipairs(pets) do 
		model:Destroy()
	end
	plot:SetAttribute("CachedAt", nil)
end

function FenceBoundsService.GetPlotByUserId(Id: string): BasePart?
	for _, plot in pairs(plots) do
		if tostring(plot:FindFirstChild("OwnerUserId").Value) == tostring(Id) then
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
