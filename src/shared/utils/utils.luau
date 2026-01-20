local utils = {}
utils.ScaleToLvl = function(npc: Model, LVL: number)
	local baseScale = 1
	local growthPerLevel = 0.02 -- 10%

	local scale = baseScale + growthPerLevel * (LVL - 1)
	npc:ScaleTo(scale)
end

return utils
