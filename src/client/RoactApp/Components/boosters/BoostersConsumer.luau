local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Roact)

local PetRegistryContext = require(script.Parent.Parent.Parent.Context.PetRegistryContext.PetRegistryContext)
local useContext = require(script.Parent.Parent.Parent.Context.Utils.useContext)

local BoostersConsumer = Roact.Component:extend("BoostersConsumer")

function BoostersConsumer:render()
	local withCtx = useContext({
		PetRegistryContext = PetRegistryContext,
	})

	return withCtx(function(ctx)
		local boosters = ctx.PetRegistryContext.boosters or {}
		return Roact.createFragment(boosters)
	end)
end

return BoostersConsumer
