local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.utils.Constants)
local FenceBoundsService = {}

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

local plots = CollectionService:GetTagged("plots")

function FenceBoundsService.GetPlotByUserId(Id: string): BasePart?
	for _, plot in pairs(plots) do
		local ownerShit = plot:WaitForChild("OwnerUserId")
		if ownerShit.Value and tostring(ownerShit.Value) == tostring(Id) then
			return plot
		end
	end
	return
end

return FenceBoundsService
