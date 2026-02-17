local Aspect = script.Name
local multipliers = require(script.Parent.multipliers)[Aspect]

local ExperienceSeed = {}

function ExperienceSeed.Calculate(target, rarity, dur)
	target:ChangeData("XPBuff", multipliers[rarity])
	task.delay(dur, function()
		target:ChangeData("XPBuff", nil)
	end)
end

function ExperienceSeed.createDesc(itemData)
	local minuts = itemData.duration / 60
	return string.format(
		"This %s %s increase the gained experience %d times more during %d minutes",
		itemData.rarity,
		itemData.aspectName,
		multipliers[itemData.rarity],
		minuts
	)
end

return ExperienceSeed
