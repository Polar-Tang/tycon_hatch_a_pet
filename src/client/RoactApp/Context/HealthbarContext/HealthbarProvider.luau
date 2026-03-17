local ReplicatedStorage = game:GetService("ReplicatedStorage")
local repStore = game.ReplicatedStorage
local NpcFighterTypes = require(ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Shared.utils.NpcFighterTypes)
local Roact = require(repStore.Roact)

local HealthbarContext = require(script.Parent.HealthbarContext)
local HealthbarComponent = require(script.Parent.Parent.Parent.Components.billboards.HealthBar)

local HealthCon: BindableEvent = ReplicatedStorage.Nevermore.Custom.NPCFighter.src.Client.utils.HealthCon

local HealthbarProvider = Roact.Component:extend("HealthbarProvider")

function HealthbarProvider:init()
	self:setState({
		HealthbarComponents = {},
	})
end

function HealthbarProvider:didMount()
	HealthCon.Event:Connect(function(data: NpcFighterTypes.HealthNetData)
		local clone = self.state.HealthbarComponents
		if not data.model then
			return
		end
		--print("data PetHealthEvent ", data)
		if data then
			if data.type == "Destroy" then
				clone[data.petId] = nil
			end

			if data.type == "Init" then
				clone[data.petId] = Roact.createElement(HealthbarComponent, {
					model = data.model,
					percent = data.percent,
					petLevel = data.level,
					health = data.health,
					petId = data.petId,
				})
			end
			if data.type == "Update" then
				clone[data.petId] = Roact.createElement(HealthbarComponent, {
					model = data.model,
					percent = data.percent,
					health = data.health,
					petLevel = data.level,
					petId = data.petId,
				})
			end
			self:setState({ HealthbarComponents = clone })
		end
	end)
end
function HealthbarProvider:render()
	return Roact.createElement(HealthbarContext.Provider, {
		value = {
			HealthbarComponents = self.state.HealthbarComponents,
		},
	}, self.props[Roact.Children])
end

return HealthbarProvider
