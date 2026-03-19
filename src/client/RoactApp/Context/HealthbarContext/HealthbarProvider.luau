local ReplicatedStorage = game:GetService("ReplicatedStorage")
local repStore = game.ReplicatedStorage
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local Roact = require(repStore.Roact)

local HealthbarContext = require(script.Parent.HealthbarContext)

local HealthCon: BindableEvent = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.HealthCon

local HealthbarProvider = Roact.Component:extend("HealthbarProvider")

function HealthbarProvider:init()
	print("HealthbarContext ", HealthbarContext)
	self:setState({
		HealthbarComponents = {},
	})
end

function HealthbarProvider:didMount()
	HealthCon.Event:Connect(function(data: NpcFighterTypes.HealthNetData)
		local clone = table.clone(self.state.HealthbarComponents)
		if not data.model then
			return
		end
		--print("data PetHealthEvent ", data)
		if data then
			if data.type == "Destroy" then
				clone[data.petId] = nil
			end

			if data.type == "Init" then
				clone[data.petId] = data
			end
			if data.type == "Update" then
				clone[data.petId] = data
			end
			self:setState({ HealthbarComponents = clone })
		end
	end)
end
function HealthbarProvider:render()
	return Roact.createElement(HealthbarContext.Provider, {
		value = self.state,
	}, self.props[Roact.Children])
end

return HealthbarProvider
