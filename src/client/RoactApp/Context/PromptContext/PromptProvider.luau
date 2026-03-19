local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local repStore = game:getService("ReplicatedStorage")

local DefaultProximityPrompt =
	require(StarterPlayer.StarterPlayerScripts.RoactApp.Components.CustomProx.DefaultProximityPrompt)
local nameToAction = require(StarterPlayer.StarterPlayerScripts.utils.nameToAction)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local npcTypes = require(ReplicatedStorage.utils.npcTypes)
local Roact = require(repStore.Roact)

local PromptContext = require(script.Parent.PromptContext)

local PromptProvider = Roact.Component:extend("PromptProvider")

local PromptController = require(script.Parent.PromptController)

local Events = repStore.RemoteEvents
local ProximityPrompt = Events.ProximityPrompt

function PromptProvider:init()
	self.distanceCheckConnections = {}
	self.__prompts = {}
	self._maid = Maid.new()

	self:setState({
		isPromptShown = false,
		prompts = {},
	})
end

function PromptProvider:render()
	return Roact.createElement(PromptContext.Provider, {
		value = {

			prompt = self.state.prompt,
			callClose = function(prompty)
				self:DisconnectPrompt(prompty)
			end,
			prompts = self.state.prompts,
		},
	}, self.props[Roact.Children])
end

function PromptProvider:DisconnectPrompt(prompty)
	if not prompty then
		warn("noPrompty")
		return
	end
	local promptId = prompty.ObjectText

	self.__prompts[promptId] = nil
	local clone = table.clone(self.state.prompts)
	clone[promptId] = nil
	self:setState({
		prompts = clone,
	})
end

function PromptProvider:didMount()
	local promptCon = game:GetService("ProximityPromptService").PromptShown
		:Connect(function(prompty: ProximityPrompt, inputType)
			local promptParent = prompty.Parent
			if promptParent then
				ProximityPrompt:FireServer({
					prompt = prompty,
					Parent = promptParent,
					id = prompty.Name,
					inputType = inputType,
					npcName = promptParent.Name,
				})
			end
		end)

	-- Here we can blindly trust
	local promptCreator = ProximityPrompt.OnClientEvent:Connect(function(data)
		local npc: Model = data.npc
		local id = data.id
		local prompty: ProximityPrompt = data.prompt

		if
			(Players.LocalPlayer.Character.PrimaryPart.Position - data.npc.PrimaryPart.Position).Magnitude
			> prompty.MaxActivationDistance
		then
			return
		end

		local npcInterface: npcTypes.nameToAction = nameToAction[npc.Name]

		if npcInterface.default then
			npcInterface.greetings(npc)
			DefaultProximityPrompt(prompty, data.inputType, npcInterface)
			return
		end

		if self.__prompts[id] then
			return
		end

		local PromptController = PromptController.new(prompty, function(p)
			self:DisconnectPrompt(p)
		end)

		if npc:HasTag("NPC") then
			PromptController = PromptController.new(prompty, function(p)
				self:DisconnectPrompt(p)
				ProximityPrompt:FireServer(prompty, true)
			end)
		end

		self.__prompts[id] = PromptController
		PromptController:StartCheckDistance()
		local clone = table.clone(self.state.prompts)
		clone[id] = prompty

		self:setState({
			prompts = clone,
		})
	end)
	self._maid:GiveTask(promptCon)
	self._maid:GiveTask(promptCreator)
end

function PromptProvider:unMount()
	self.promptCon:Disconnect()
end

return PromptProvider
