local Aspect = script.Name
local multipliers = require(script.Parent.multipliers)[Aspect]

local DMG = {}

function DMG.Calculate(target, rarity, dur)
	print("target ", target)
	local baseDMG = target.Data.dmgBase
	local increase = baseDMG + multipliers[rarity]

	target:ChangeData("dmgBaseBuff", increase)
	task.delay(dur, function()
		target:ChangeData("dmgBaseBuff", nil)
	end)
	--return {health = newH}
end

function DMG.createDesc(itemData)
	local minuts = itemData.duration / 60
	return string.format(
		"This %s %s increase the pets points damage by %d during %d minutes",
		itemData.rarity,
		itemData.aspectName,
		multipliers[itemData.rarity],
		minuts
	)
end

return DMG
