local CollectionService = game:GetService("CollectionService")

local function initOtherPlots()
	workspace:WaitForChild("FenceBounds1")
	workspace:WaitForChild("FenceBounds2")
	workspace:WaitForChild("FenceBounds3")
	workspace:WaitForChild("FenceBounds4")
	workspace:WaitForChild("FenceBounds5")
	workspace:WaitForChild("FenceBounds6")

	for i = 1, 6 do
		CollectionService:GetInstanceAddedSignal("plot_" .. i):Connect(function(model)
			CollectionService:AddTag(model, "NPC")
		end)
	end
end

return initOtherPlots
