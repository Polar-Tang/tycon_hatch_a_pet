local HealthBar = require(script.Parent.HealthBar)
local billboardTypes = require(script.Parent.billboardTypes)
local Roact = require(game.ReplicatedStorage:WaitForChild("Roact"))
local HealthBars = Roact.Component:extend("HealthBars")

function HealthBars:render()
	local context = script.Parent.Parent.Parent.Context
	local HealthbarContext = require(context.HealthbarContext.HealthbarContext)
	local useContext = require(context.Utils.useContext)

	local withCtx = useContext({ HealthbarContext = HealthbarContext })

	return withCtx(function(ctx)
		local clone = {}
		for id, data: billboardTypes.HealthbarComponentData in pairs(ctx.HealthbarContext.HealthbarComponents) do
			if data.type == "Destroy" then
				clone[data.petId] = nil
			end

			if data.type == "Init" then
				clone[data.petId] = Roact.createElement(HealthBar, {
					model = data.model,
					percent = data.percent,
					petLevel = data.level,
					health = data.health,
					petId = data.petId,
					componentName = "HealthBar",
				})
			end
			if data.type == "Update" then
				clone[data.petId] = Roact.createElement(HealthBar, {
					model = data.model,
					percent = data.percent,
					health = data.health,
					petLevel = data.level,
					petId = data.petId,
					componentName = "HealthBar",
				})
			end
		end
		return Roact.createFragment(clone)
	end)
end

return HealthBars
