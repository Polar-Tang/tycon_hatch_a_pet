local Aspect = script.Name
local multipliers = require(script.Parent.multipliers)[Aspect]
local server = game.ServerScriptService
local playerRefReader = require(server:WaitForChild("Helpers"):WaitForChild("PlayerReferenceReaderHandler"))

local stamina = {}

function stamina.Calculate(target, rarity, dur, bestiaryHandler, petName)
	local targetData = target.Data
	local maxHealth = targetData.maxHealth
	local H: Humanoid = target.Data.humanoid
	local newmaxH = maxHealth + multipliers[rarity]
	H.MaxHealth = newmaxH
	local currentHealth = targetData.health.Value
	local newH = currentHealth + multipliers[rarity] * 2
	if newH > newmaxH then
		newH = newmaxH
	end

	target:ChangeData("maxHealthBuff", newmaxH)
	local player = target.Data.playerOwner
	local singletonPlayer = playerRefReader:GetHandler(player)
	print("singletonPlayer ", singletonPlayer)
	local healthHandler = target.Data.healthController
	print("presumably healthHandler singletonPlayer", healthHandler)
	local dataNewHealths = { health = newH, maxHealth = newmaxH }
	healthHandler:setNewH(dataNewHealths)

	-- targetData is a copy, hence after dur the original pet state data might be different
	task.delay(dur, function()
		local petStata = singletonPlayer.pet.state
		local data = petStata.Data
		local originalHealth = data.maxHealth
		--H.MaxHealth = originalHealth
		local healthHandler = data.healthController
		local petName = data.model.name

		healthHandler:setNewH({ maxHealth = originalHealth })
		bestiaryHandler:removeBuffH(petName)
		target:ChangeData("maxHealthBuff", nil)
		print("Health buff expire ", targetData)
	end)
	return dataNewHealths
end

function stamina.calc(data, rarity)
	local health = data.health
	print("health ", health)
	local maxHealth = (128 + data.petStats.stamina * 32)
	print("maxHealth ", maxHealth)

	local newH = health + multipliers[rarity] * 2
	local newMaxH = maxHealth + multipliers[rarity]
	if newH > newMaxH then
		newH = newMaxH
	end
	return {
		health = newH,
		maxHealth = newMaxH,
	}
end

function stamina.createDesc(itemData)
	local minuts = itemData.duration / 60
	return string.format(
		"This %s %s increase the pet health by %d health points during %d minutes",
		itemData.rarity,
		itemData.aspectName,
		multipliers[itemData.rarity],
		minuts
	)
end

return stamina
