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
		isPanelOpen = false,
		--==
		isOpenTooltip = false,
		toolTipsize = UDim2.new(0, 0, 0, 0),
		toolTipPosition = UDim2.new(0, 0, 0, 0),
		selectedItemData = {}, -- TODO: see item Data type
	})
end

function InventoryProvider:setPanelOpen(isOpen)
	self:setState({
		isPanelOpen = isOpen,
	})
end

function InventoryProvider:render()
	return Roact.createElement(InventoryContext.Provider, {
		value = {
			items = self.state.items :: { any },
			isPanelOpen = self.state.isPanelOpen,
			setPanelOpen = function(isOpen)
				self:setPanelOpen(isOpen)
			end,

			openToolTip = function(imageRef, item, tooltip)
				local uiRef = self.inventoryUIRef:getValue()
				local slotRef = imageRef:getValue()
				if not uiRef or not slotRef then
					return
				end

				local toolTipWidth = slotRef.AbsoluteSize.X * 2
				local toolTipHeight = slotRef.AbsoluteSize.Y * 2

				-- Calculate offset relative to the InventoryUI Frame
				local offsetX = slotRef.AbsolutePosition.X - uiRef.AbsolutePosition.X - toolTipWidth -- Position to the left
				local offsetY = slotRef.AbsolutePosition.Y
					- uiRef.AbsolutePosition.Y
					+ slotRef.AbsoluteSize.Y / 2
					- toolTipHeight / 2 -- Center vertically

				self:setState({
					isOpenTooltip = true,
					toolTipsize = UDim2.new(0, toolTipWidth, 0, toolTipHeight),
					toolTipPosition = UDim2.new(0, offsetX, 0, offsetY),
					selectedItemData = item,
				})
			end,
			isOpenTooltip = self.state.isOpenTooltip,
			toolTipsize = self.state.toolTipsize,
			toolTipPosition = self.state.toolTipPosition,
			selectedItemData = self.state.selectedItemData,
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
