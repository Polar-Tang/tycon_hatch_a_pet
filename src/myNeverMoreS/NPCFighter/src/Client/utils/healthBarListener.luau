local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local HealthCon: BindableEvent = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.HealthCon

local CombatControllerClient = require(script.Parent.CombatControllerClient)
return function(player: Player, model: Model, id: NpcFighterTypes.healthBarId)
	-- This acts as a bridge between the new health value and the healthBar components in the client
	local healthBar = CombatControllerClient.getHealth(player, id)
	if not healthBar then
		print("An error has occurred please alert UI an error has ocurred and need to retry")
		return
	end

	local currentHealth = healthBar.Value
	local healthbarInfo: NpcFighterTypes.HealthNetData = {
		health = currentHealth,
		petId = id,
		model = model,
		type = "Init",
		level = 150,
		percent = 100,
	}

	HealthCon:Fire(healthbarInfo)

	healthBar.AttributeChanged:Connect(function(a0: string)
		local newHealth = healthBar.Value
		local maxH = healthBar:GetAttribute("MaxHealth")

		local healthbarInfo: NpcFighterTypes.HealthNetData = {
			health = newHealth,
			petId = id,
			model = model,
			type = "Update",
			level = 150,
			percent = newHealth / maxH,
		}

		HealthCon:Fire(healthbarInfo)
	end)
end
