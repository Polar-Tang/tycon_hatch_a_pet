local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local packages = RS.Nevermore.Quenty
local Observable = require(ReplicatedStorage.Nevermore.Quenty.rx.Shared.Observable)
local Rx = require(ReplicatedStorage.Nevermore.Quenty.rx.Shared.Rx)
local PlayerInventory = require(ServerScriptService.Player.Inventory.PlayerInventory)
local BaseObject = require(packages.baseobject.Shared.BaseObject)
-- TEST IF this doesn't break
local Amount: RemoteEvent = RS.RemoteEvents.Amount

local CurrencyController = setmetatable({}, BaseObject)
CurrencyController.__index = CurrencyController

function CurrencyController.new(data, serviceBag: any, player)
	local self = setmetatable(BaseObject.new() :: any, CurrencyController)
	local character = data.pet

	self._character = character
	self._root = character.PrimaryPart
	self._range = data.range
	self._serviceBag = serviceBag
	self.base = data.base

	self._currentPlayer = nil
	self._humanoidTracker = nil

	self._player = player

	return self
end

function CurrencyController:getAnimHandler()
	local BinderProvider = self._serviceBag:GetService(_G.BinderProvider)

	-- local WeaponBinder = BinderProvider:Get("Armed")
	local AnimationBinder = BinderProvider:Get("AnimationHandler")
	self._AnimationHandler = AnimationBinder:Get(self._character)
end

function CurrencyController:GenerateCurrency()
	if not self._AnimationHandler then
		self:getAnimHandler()
	end
	-- BUG: if there are invited players this will be an issue because it also updates the amount of money thing

	self._AnimationHandler:LoadAnimation(true, "eat")
	self._AnimationHandler:OnSignal({
		callback = function()
			self:_generateCurrency()
		end,
		animationName = "eat",
		animationEventName = "Eat",
	})
end

function CurrencyController:_generateCurrency()
	local player_inventory = PlayerInventory:GetHandler(self._player)
	player_inventory:IncreaseMoney(self.base)
end

function CurrencyController:StopAnim()
	if not self._AnimationHandler then
		return -- GenerateCurrency haven't be called yet
	end
	self._AnimationHandler:LoadAnimation(false, "eat")
	--print("create the floating number that are at capture pet")
end

return CurrencyController
