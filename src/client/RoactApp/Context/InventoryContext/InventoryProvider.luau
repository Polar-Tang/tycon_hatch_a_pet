local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Roact)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)

local InventoryContext = require(script.Parent.InventoryContext)
local InventoryProvider = Roact.Component:extend("InventoryProvider")
local PlayerInventory = ReplicatedStorage.RemoteEvents.PlayerInventory

function InventoryProvider:init()
	self._maid = Maid.new()
	self:setState({
		items = {},
	})
end

function InventoryProvider:render()
	return Roact.createElement(InventoryContext.Provider, {
		value = {
			items = self.state.items :: { any },
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
