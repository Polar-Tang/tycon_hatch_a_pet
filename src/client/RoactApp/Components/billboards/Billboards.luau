local billboardTypes = require(script.Parent.billboardTypes)
local Roact = require(game.ReplicatedStorage:WaitForChild("Roact"))
local CustomProximityPrompts = Roact.Component:extend("CustomProximityPrompts")

function CustomProximityPrompts:render()
	local context = script.Parent.Parent.Parent.Context
	local BillboardContext = require(context.BillboardContext.BilldoardContext)
	local useContext = require(context.Utils.useContext)

	local withCtx = useContext({ BillboardContext = BillboardContext })

	return withCtx(function(ctx)
		local billboardCtx = ctx.BillboardContext
		print("billboardCtx ", billboardCtx)
		local customProxComponents = {}

		for id, billboard: billboardTypes.billboardShit in ipairs(billboardCtx.billboards) do
			local component = require(script.Parent:FindFirstChild(billboard.componentName))

			if not component then
				print(billboard.componentName, "Not found")
				return
			else
				return Roact.createElement(component, {
					model = billboard.model,
				})
			end
		end
		return Roact.createFragment(customProxComponents)
	end)
end

return CustomProximityPrompts
