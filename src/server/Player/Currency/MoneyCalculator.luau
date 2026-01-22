local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local utils = require(ReplicatedStorage.utils.utils)
local Registry = require(ServerScriptService.Pets.Registry.Registry)
local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)
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

		local base = utils.MoneyCalc(Stamina)
		moneyPerSecond += base
	end
	
	-- Total money = money per second * time elapsed
	return moneyPerSecond * timeElapsed
end

-- Helper function to get time since last registration and calculate earnings
function MoneyCalculator.calculatePendingMoney(player)
	local inventory = PlayerInventory:GetHandler(player)
	local registry = Registry:GetHandler(player)
	
	local currentTime = os.time()
	local lastRegister = inventory:getRegisterTime()
	local timeElapsed = currentTime - lastRegister
	
	local pets = registry.pets
	local moneyEarned = MoneyCalculator.calculateEarnings(pets, timeElapsed)
	print("earned ", moneyEarned, "for ", timeElapsed)
	return moneyEarned, timeElapsed
end

-- Full workflow: calculate and apply pending money
function MoneyCalculator.collectPendingMoney(player)
	local inventory = PlayerInventory:GetHandler(player)
	local moneyEarned, timeElapsed = MoneyCalculator.calculatePendingMoney(player)
	
	-- Add the money
	inventory:IncreaseMoney(moneyEarned)
	
	-- Reset the register time
	inventory:setRegisterTime()
	
	return moneyEarned, timeElapsed
end

return MoneyCalculator