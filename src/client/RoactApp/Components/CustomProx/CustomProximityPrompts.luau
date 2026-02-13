local Roact = require(game.ReplicatedStorage:WaitForChild("Roact"))
local CustomProximityPrompt = require(script.Parent.CustomProximityPrompt)
local CustomProximityPrompts = Roact.Component:extend("CustomProximityPrompts")

function CustomProximityPrompts:render()
	local context = script.Parent.Parent.Parent.Context
	local PromptContext = require(context.PromptContext.PromptContext)
	local useContext = require(context.Utils.useContext)

	local withCtx = useContext({ PromptContext = PromptContext })

	return withCtx(function(ctx)
		local dropCTX = ctx.dropItemCtx
		local prompCTX = ctx.PromptContext
		local customProxComponents = {}

		for id, prompt in pairs(prompCTX.prompts) do
			customProxComponents[id] = Roact.createElement(CustomProximityPrompt, {
				prompt = prompt,
				callClose = prompCTX.callClose,
				dropItems = dropCTX.dropItems,
				removerItem = dropCTX.removerItem,
			})
		end
		return Roact.createFragment(customProxComponents)
	end)
end

return CustomProximityPrompts
