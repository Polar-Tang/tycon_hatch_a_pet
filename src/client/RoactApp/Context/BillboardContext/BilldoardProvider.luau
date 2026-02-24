local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local repStore = game:getService("ReplicatedStorage")

local billboardTypes = require(StarterPlayer.StarterPlayerScripts.RoactApp.Components.billboards.billboardTypes)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
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
			billboards = self.state.billboards :: { billboardTypes.billboardShit },
		},
	}, self.props[Roact.Children])
end

function BillboardProvider:DisconnectPrompt(prompty) end

function BillboardProvider:didMount()
	-- Here we can blindly trust
	local billboardCreator = Biilboard.OnClientEvent:Connect(function(data)
		local billboardsClone = table.clone(self.state.billboards)
		local billboardData: billboardTypes.billboardShit = {
			componentName = data.componentName,
			model = data.npc,
		}

		table.insert(billboardsClone, billboardData)
		self:setState({
			billboards = billboardsClone,
		})
		print("self.state.billboards ", self.state.billboards)
	end)
	self._maid:GiveTask(billboardCreator)
end

function BillboardProvider:unMount()
	self._maid:DoCleaning()
end

return BillboardProvider
