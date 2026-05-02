local ReplicatedStorage = game:GetService("ReplicatedStorage")
local repStore = game:getService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local types = require(ReplicatedStorage.utils.types)
local Roact = require(repStore.Roact)

local BillboardContext = require(script.Parent.BilldoardContext)
local BillboardProvider = Roact.Component:extend("BillboardProvider")

local Biilboard = game.ReplicatedStorage.RemoteEvents.Biilboard

function BillboardProvider:init()
	self._maid = Maid.new()
	self:setState({
		billboards = {},
	})
end

function BillboardProvider:render()
	return Roact.createElement(BillboardContext.Provider, {
		value = {
			billboards = self.state.billboards :: { types.billBoardContract },
		},
	}, self.props[Roact.Children])
end

function BillboardProvider:DisconnectPrompt(prompty) end

function BillboardProvider:didMount()
	-- Here we can blindly trust
	local billboardCreator = Biilboard.OnClientEvent:Connect(function(data: types.billBoardContract)
		local billboardsClone = table.clone(self.state.billboards)

		table.insert(billboardsClone, data)
		self:setState({
			billboards = billboardsClone,
		})
	end)
	self._maid:GiveTask(billboardCreator)
end

function BillboardProvider:unMount()
	self._maid:DoCleaning()
end

return BillboardProvider
