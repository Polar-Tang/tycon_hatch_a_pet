local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Roact)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)

local InventoryContext = require(script.Parent.InventoryContext)
local InventoryProvider = Roact.Component:extend("InventoryProvider")
local PlayerInventory = ReplicatedStorage.RemoteEvents.PlayerInventory

function InventoryProvider:init()
	self._maid = Maid.new()
	self:setState({
		items = {},
		isPanelOpen = false,
		selectedPetData = nil :: PetTypes.PetData?,
	})
end

function InventoryProvider:setPanelOpen(isOpen)
	self:setState({
		isPanelOpen = isOpen,
	})
end

function InventoryProvider:setSelectedPetData(petData: PetTypes.PetData?)
	self:setState({
		selectedPetData = petData,
	})
end

function InventoryProvider:render()
	return Roact.createElement(InventoryContext.Provider, {
		value = {
			items = self.state.items :: { any },
			isPanelOpen = self.state.isPanelOpen,
			selectedPetData = self.state.selectedPetData,
			setPanelOpen = function(isOpen)
				self:setPanelOpen(isOpen)
			end,
			setSelectedPetData = function(petData)
				self:setSelectedPetData(petData)
			end,
		},
	}, self.props[Roact.Children])
end

function InventoryProvider:didMount()
	local itemsConnection = PlayerInventory.OnClientEvent:Connect(function(data)
		self:setState({
			items = data,
		})
	end)

	self._maid:GiveTask(itemsConnection)
end

function InventoryProvider:willUnmount()
	self._maid:DoCleaning()
end

return InventoryProvider
