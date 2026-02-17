local Aspect = script.Name
local multipliers = require(script.Parent.multipliers)[Aspect]

local ExperienceSeed = {}

function ExperienceSeed.Calculate(target, rarity, dur)
	local factor = multipliers[rarity]
	local increase = target.Data.celerity - target.Data.celerity * factor
	target:ChangeData("celerityBuff", increase)
	task.delay(dur, function()
		target:ChangeData("celerityBuff", nil)
	end)
end
