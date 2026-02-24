local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage.utils.utils)
local MoneyCalculator = {}

-- Calculate money earned based on pets and time elapsed
-- Calculate money on demand is a little buggy cause the calculation is taking the last pet stamina
function MoneyCalculator.calculateEarnings(pets, timeElapsed)
	local moneyPerSecond = 0

	for petName, petData in pairs(pets) do
		local Melee = petData.petStats.Melee
		if Melee <= 0 then
			Melee = 1
		end

		local Stamina = petData.petStats.Stamina
		if Stamina <= 0 then
			Stamina = 1
		end

		local base = utils.MoneyCalc(Stamina)
		moneyPerSecond += base
	end

	-- Total money = money per second * time elapsed
	return moneyPerSecond * timeElapsed
end

return MoneyCalculator
