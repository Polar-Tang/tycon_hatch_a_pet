local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local player = Players.LocalPlayer
local nameToAction = require(StarterPlayer.StarterPlayerScripts.utils.nameToAction)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)

local PromptController = {}
-- PlayerQuestHandler.lua
PromptController.__index = PromptController

function PromptController.new(prompt: ProximityPrompt, disconnectPrompt)
	local self = setmetatable({}, PromptController)
	self.prompt = prompt
	self.promptId = prompt.Name
	self.hiddePrompt = disconnectPrompt

	self._maid = Maid.new()
	self.distanceCheckConnection = nil
	self.timer = 0
	self.lastTime = 0

	return self
end

function PromptController:StartCheckDistance()
	local distanceCheckConnection = RunService.Heartbeat:Connect(function(deltaTime)
		local timer = self.timer
		local lastTime = self.lastTime
		self.timer = timer + deltaTime
		if timer - lastTime >= 1 then
			self.lastTime = timer
			local hrp = player.Character and player.Character.PrimaryPart
			--print("hrp prompty", hrp)
			--print("prompy parent ", prompty.Parent)
			local prompty = self.prompt

			if not hrp or not prompty.Parent then
				return
			end
			local promptHRP
			if prompty.Parent:IsA("BasePart") then
				promptHRP = prompty.Parent
			elseif prompty.Parent:IsA("Model") then
				promptHRP = prompty.Parent.PrimaryPart
			else
				print("Unkown prompt parent type ", prompty.Parent)
			end

			local distance = (promptHRP.Position - hrp.Position).Magnitude
			if distance > 25 then
				print("disconnect con")
				nameToAction[prompty.Parent.Name].finishPrompt()
				self:DisconnectPrompt(prompty)
			else
				nameToAction[prompty.Parent.Name].updatePrompt()
			end
		end
	end)
	self._maid:GiveTask(distanceCheckConnection)
end

function PromptController:DisconnectPrompt()
	self.hiddePrompt(self.prompt)
	self._maid:DoCleaning()
end

return PromptController
