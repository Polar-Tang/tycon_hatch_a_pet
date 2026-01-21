local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Registry = require(ServerScriptService.Pets.Registry.Registry)
local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)
local CurrencyController = {}
-- PlayerQuestHandler.lua
CurrencyController.__index = CurrencyController
type PlayerData = {
	player: Player,
	cash: number,
}

function CurrencyController.new(player): PlayerData
	local self = setmetatable({}, CurrencyController)
	self._timer = 0
	self._lastTime = 0
	self._player = player

	self:_init()
	return self
end

local Amount = ReplicatedStorage.RemoteEvents.Amount
function CurrencyController:_init()
	self._mainCon = RunService.Heartbeat:Connect(function(dt: number)
		self._timer += dt
		if self._timer - self._lastTime >= 1 then
			self._lastTime = self._timer

			local player = self._player

			local bestiary = Registry:GetHandler(player)
			local pets = bestiary.pets

			local count = 0
			for petName, petData in pairs(pets) do
				local Melee = petData.petStats.Melee
				if petData.petStats.Melee <= 0 then
					Melee = 1
				end
				local Stamina = petData.petStats.Stamina
				if petData.petStats.Stamina <= 0 then
					Stamina = 1
				end

				local base = (Melee ^ 1.5) * (Stamina ^ 1.4) * 2
				-- print(petName .. "produces " .. base)
				count += base
			end

			local inventory = PlayerInventory:GetHandler(player)
			local amount = inventory:IncreaseMoney(count)
			Amount:FireClient(player, {
				amount = amount,
			})
		end
	end)
end

function CurrencyController:Destroy()
	self._mainCon:Disconnect()
	print("self._mainCon ", self._mainCon)
end

local CurrencyHandler = {}

CurrencyHandler.__index = CurrencyHandler

CurrencyHandler._players = {}

function CurrencyHandler:InitPlayer(player)
	local handler = CurrencyController.new(player)
	self._players[player.UserId] = handler
end

-- accept a player
-- Get the player handler
-- return the particular player handler
function CurrencyHandler:GetHandler(player)
	return self._players[player.UserId]
end

-- accept a player
-- remove the player instance
-- return nil
function CurrencyHandler:RemovePlayer(player)
	self._players[player.UserId]:Destroy()
	self._players[player.UserId] = nil
end

return CurrencyHandler
