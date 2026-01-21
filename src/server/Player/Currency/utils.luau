local MoneyCalculator = {}

-- Calculate money earned based on pets and time elapsed
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

		local base = (Stamina ^ 1.8) * 2
		moneyPerSecond += base
	end
	
	-- Total money = money per second * time elapsed
	return moneyPerSecond * timeElapsed
end

-- Helper function to get time since last registration and calculate earnings
function MoneyCalculator.calculatePendingMoney(player, Registry, PlayerInventory)
	local inventory = PlayerInventory:GetHandler(player)
	local registry = Registry:GetHandler(player)
	
	local currentTime = os.time()
	local lastRegister = inventory:getRegisterTime()
	local timeElapsed = currentTime - lastRegister
	
	local pets = registry.pets
	local moneyEarned = MoneyCalculator.calculateEarnings(pets, timeElapsed)
	
	return moneyEarned, timeElapsed
end

-- Full workflow: calculate and apply pending money
function MoneyCalculator.collectPendingMoney(player, Registry, PlayerInventory)
	local inventory = PlayerInventory:GetHandler(player)
	local moneyEarned, timeElapsed = MoneyCalculator.calculatePendingMoney(player, Registry, PlayerInventory)
	
	-- Add the money
	inventory:increaseMoney(moneyEarned)
	
	-- Reset the register time
	inventory:setRegisterTime()
	
	return moneyEarned, timeElapsed
end

return MoneyCalculator