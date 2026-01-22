local utils = {}
utils.ScaleToLvl = function(npc: Model, LVL: number)
	local baseScale = 1
	local growthPerLevel = 0.0134 -- 0.0134 * 150 = 2.01

	local scale = baseScale + growthPerLevel * (LVL - 1)
	npc:ScaleTo(scale)
end

utils.MoneyCalc = function(stamina)
	return (stamina ^ 1.8) * 2
end

utils.HealthCalc = function(health)
	return 50 + (50 * health) 
end

utils.MeleeCalc = function(melee)
	return 100 + (10 * melee) 
end

utils.setUpStats = function(model, stats)
	local melee = stats.Melee
	local stamina = stats.Stamina
	local health = stats.Health

	model:SetAttribute("Melee", utils.MeleeCalc(melee))
	model:SetAttribute("Health", utils.HealthCalc(health))
	model:SetAttribute("Stamina", stamina)

end

return utils
