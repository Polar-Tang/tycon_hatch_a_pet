local utils = {}
utils.ScaleToLvl = function(npc: Model, LVL: number)
	local currentSize = npc:GetExtentsSize().Magnitude

	local newScale = currentSize * ((0.1 / 19) * (LVL - 1) + 0.2)
	npc:ScaleTo(newScale)
end

return utils