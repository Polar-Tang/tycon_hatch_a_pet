local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local HealthCon: BindableEvent = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.HealthCon

local CombatControllerClient = require(script.Parent.CombatControllerClient)
return function(player: Player, model: Model, id: NpcFighterTypes.healthBarId)
	-- This acts as a bridge between the new health value and the healthBar components in the client
	local healthVal: IntValue? = CombatControllerClient.getHealth(player, id)
	if not healthVal then
		print("An error has occurred please alert UI an error has ocurred and need to retry")
		return
	end

	local currentHealth = healthVal.Value
	local healthbarInfo: NpcFighterTypes.HealthNetData = {
		health = currentHealth,
		petId = id,
		model = model,
		type = "Init",
		level = model:GetAttribute("Level"),
		percent = 100,
	}

	HealthCon:Fire(healthbarInfo)

	healthVal.Changed:Connect(function(a0: number)
		local newHealth = healthVal.Value
		local maxH = healthVal:GetAttribute("MaxHealth")

		local healthbarInfo: NpcFighterTypes.HealthNetData = {
			health = newHealth,
			petId = id,
			model = model,
			type = "Update",
			level = model:GetAttribute("Level"),
			percent = newHealth / maxH,
		}

		HealthCon:Fire(healthbarInfo)
	end)
end
