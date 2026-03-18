local utils = {}
utils.ScaleToLvl = function(npc: Model, LVL: number)
	local baseScale = 1
	local growthPerLevel = 0.007 -- 0.0134 * 150 = 2.01

	local scale = baseScale + growthPerLevel * (LVL - 1)
	npc:ScaleTo(scale)
end

utils.fixPetY = function(model: Model, root: BasePart)
	-- local cf, size = model:GetBoundingBox()

	local rootY = root.Position.Y

	local groundOffset = rootY - root.Size.Y / 2
	return root.Position.Y
end

utils.MoneyCalc = function(stamina)
	local staminaGT1 = stamina
	if stamina == 0 then
		staminaGT1 = 1
	end
	return (staminaGT1 ^ 1.8) * 2
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

utils.GenerateRandStats = function(LVL)
	local statsMap = {
		0,
		0,
		0,
	}

	while LVL > 0 do
		LVL -= 1
		local rand = math.random(1, 3)
		statsMap[rand] += 1
	end
	return {
		["Health"] = statsMap[1],
		["Melee"] = statsMap[2],
		["Stamina"] = statsMap[3],
	}
end

utils.GetModelHeight = function(model: Model): number
	local lowestPart: BasePart?
	local highestPart: BasePart?

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			if not lowestPart or part.Position.Y - part.Size.Y / 2 < lowestPart.Position.Y - lowestPart.Size.Y / 2 then
				lowestPart = part
			end
			if
				not highestPart
				or part.Position.Y + part.Size.Y / 2 > highestPart.Position.Y + highestPart.Size.Y / 2
			then
				highestPart = part
			end
		end
	end

	if not lowestPart or not highestPart then
		return 0
	end

	local bottomOfLowest = lowestPart.Position.Y - lowestPart.Size.Y / 2
	local topOfHighest = highestPart.Position.Y + highestPart.Size.Y / 2
	local otherHeight = topOfHighest - bottomOfLowest
	print("Model Height: ", otherHeight)

	local height = model:GetExtentsSize().Y
	print("Model Height: ", height)
	return height
end

return utils
